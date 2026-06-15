# Teammate B Findings: Impact of BracketFormula Encoding Change on Backward Direction

## Key Findings

### 1. The Backward Proof Structure

`backward_holdsLeft_of_nf_eval` (L1934-2081) is structured as follows:

- **Goal**: `(∃ x, nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf) → ∃ vea ∈ filterMap(...), VecEA2.holdsLeft M atomMap vea.snd t`
- **L1964-1970**: Takes witness `x`, derives `nf_x = nf_characteristic M 1 1 (fun _ => x)` and shows compatibility
- **L1972-1975**: Builds `nf_x_1var : NormalForm sig 0 1` and `vea := enriched_vecEA2_until ...`
- **L1977-1989**: Shows `vea ∈ filterMap(...)` via `rfl` (membership proof by reflexivity)
- **L1991**: `refine ⟨vea, h_vea_mem, ?_⟩` — now must prove `VecEA2.holdsLeft M atomMap vea.snd t`
- **L1993**: `simp only [VecEA2.holdsLeft, enriched_vecEA2_until]` unfolds both definitions
- **L2000**: `refine ⟨?endLeft, x, h_t_lt_x, ?endRight, ?bracket⟩` — splits into three cases
- **L2001-2015**: `case endLeft` — fully proved, ~15 lines
- **L2016-2077**: `case endRight` — fully proved, ~61 lines covering `eq_x`/`above_x` zone cases (positive and negative)
- **L2078-2081**: `case bracket` — **the only sorry**, 4 lines

### 2. What `VecEA2.holdsLeft` Requires

From `VecEATranslation.lean` (L250-256):
```
VecEA2.holdsLeft M atomMap vea t :=
  vea.endpointLeft.eval_at M atomMap t ∧
  ∃ z1, t < z1 ∧ vea.endpointRight.eval_at M atomMap z1 ∧ vea.bracket.holds M atomMap t z1
```

The bracket case (L2078-2081) must prove:
```
vea.bracket.holds M atomMap t x
```

where `vea.bracket : BracketFormula n` with `n = pos_between.length` and:
- `pointTypes i = nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]))`
- `segmentTypes _ = seg_guard`

and `BracketFormula.holds` requires witnessess `y_0 < ... < y_{n-1}` in `(t, x)` where each `y_i` satisfies the `pos_between[i]` normal form.

### 3. The Ordering Flaw's Impact on the Bracket Case

The ordering problem is in `enriched_vecEA2_until` (L453-456):
```lean
let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
  ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
  (ssn_zone_until ssn == .between_tx) &&
  sub_nf.2 ssn
```

`pos_between` is ordered by `Fintype.elems` (the canonical `Fintype` enumeration of `NormalForm sig 0 3`). The bracket requires witnesses in STRICTLY INCREASING order, but `IntervalPattern.holds` requires `witnesses i < witnesses j` for `i < j` — meaning the i-th witness must satisfy `pos_between[i]` and be strictly after `pos_between[i-1]`'s witness.

**The flaw**: There is no guarantee that a model witnesses can be found in the order dictated by `Fintype.elems`. Given two `NormalForm` values `ssn_a` and `ssn_b` where `ssn_a` comes before `ssn_b` in `Fintype.elems` ordering, the backward proof must produce `y_a < y_b`. But `y_a` satisfies `ssn_a` and `y_b` satisfies `ssn_b` — there is no structural reason a model satisfying both SSNs must place `y_a` before `y_b` in the real line.

**Why the sorry exists**: To prove `bracket.holds t x`, the backward proof would need to pick actual model elements satisfying each `pos_between[i]` and arrange them in increasing order. The `nf_eval_quant` hypothesis provides the existence of such witnesses (∃ y, nf_eval_nf M 0 3 (y,x,t) ssn_i for each positive between_tx SSN), but not in any particular relative order.

### 4. Categorical Assessment: Lines Reusable vs. Lines Affected

#### If `enriched_vecEA2_until` is redesigned to return a plain formula (conjunction approach):

**Lines that become UNNECESSARY (the entire backward function dissolves):**

The backward proof's raison d'être is to map from `∃ x, nf_eval` to `∃ vea ∈ filterMap(...), VecEA2.holdsLeft vea t`. If `enriched_vecEA2_until` no longer produces a `Σ n, VecEA2 n` but instead a plain `Formula`, then:

- `backward_holdsLeft_of_nf_eval` (L1934-2081, ~148 lines) — **entirely eliminated**
- `forward_nf_eval_of_holdsLeft` (L2086-2151, ~66 lines) — **entirely eliminated**
- The `VVecEA2.holdsLeft` / `VecEA2.holdsLeft` layer in `existPart_succ_n1_bypass_k0_until` becomes unnecessary

**Lines that are preserved as-is:**

- `endLeft` case (L2001-2015, ~15 lines) — The pre-conditions-at-t proof logic is independent of the bracket encoding. It would be reused verbatim or with minor variable renaming in a new direct proof.
- `endRight` case (L2016-2077, ~61 lines) — The eq_x/above_x zone dispatch logic is equally independent of the bracket. It would be reused verbatim.
- The filterMap membership machinery (L1977-1989, ~12 lines) — **eliminated**: conjunctions don't need `filterMap` membership.

**Lines that must be completely rewritten:**

- The `case bracket` (L2078-2081) — already sorry, becomes the locus of the new proof
- The structural setup lines (L1964-1993, ~29 lines) — must be rearchitected; the disjunct-selection mechanism changes fundamentally

#### If the conjunction approach is adopted, the new backward proof structure would be:

1. Take `x`, derive `nf_x`, derive `nf_x_1var` — same as before (~10 lines)
2. The new formula for between_tx is a conjunction `⋀_{ssn ∈ pos_between} (∃ y in (t,x), char(ssn)(y))` — prove this conjunction holds by providing witnesses for each SSN individually from `h_eval_quant` (~15 lines per SSN, but automated)
3. No membership proof needed, no bracket needed
4. endLeft and endRight subcases — reused from existing proof

**Net assessment**: ~148 lines of backward proof and ~66 lines of forward proof (total ~214 lines) are refactored. The content of `endLeft` (~15 lines) and `endRight` (~61 lines) is fully reusable logic; it moves to a new home with identical structure.

### 5. Alternative Approaches to Preserve the Existing Proof

#### Alternative A: Permutation Invariance of IntervalPattern.holds

**Question**: Can we prove that when all segment types are equal (as here — `segmentTypes _ = seg_guard` for all i), `IntervalPattern.holds` is invariant under permutation of the ordered witness list?

**Analysis**:

When all `beta_i = seg_guard` (a fixed uniform segment guard), the predicate `beta_i` holds on all segments if and only if `seg_guard` holds on the entire interval `(t, x)`. In that case, the bracket reduces to:
```
(∃ witnesses with alpha_i(w_i)) ∧ (∀ y ∈ (t,x), seg_guard(y))
```
The segment condition decouples from the witness ordering. The point conditions require only existence of witnesses satisfying each alpha_i, NOT that they are in any particular order.

**Formalizable?**: Yes — if `segmentTypes _ = seg_guard` for all indices (which is exactly the case here: `segmentTypes := fun _ => seg_guard`), then the ordering of the witnesses is irrelevant for the segment condition. The bracket holds iff:
1. `∀ y ∈ (t,x), seg_guard(y)` holds (for all segments simultaneously)
2. For each `i`, `∃ w ∈ (t,x), alpha_i(w)` (each point type is witnessed)

This means: **the `pos_between` ordering issue is a non-issue when all segment types are the same** — we can freely permute witnesses to get the strictly increasing order required by `IntervalPattern.holds`.

**Proof strategy**: Given witnesses `w_0, ..., w_{n-1}` (not necessarily ordered) where each `alpha_i(w_i)`, we can sort them. Call the sorted version `w_{sigma(0)} < ... < w_{sigma(n-1)}`. The point type `alpha_i` still holds at position `sigma(i)`, but the bracket requires `pointTypes ⟨j, _⟩` holds at witness `j`. Since we can permute the `pos_between` list to match the sorted witness order, we need `pointTypes` to be permutation-invariant with respect to the witnesses.

**Obstacle**: `BracketFormula.pointTypes : Fin n → TemporalPred` is an indexed assignment — witness `i` gets `pointTypes i`. If we sort the witnesses, witness `sigma^{-1}(0)` (the smallest) must satisfy `pointTypes 0`. But `pointTypes 0 = nfPred atomMap h_surj (nf_y_proj (pos_between[0]))` — the 0th SSN in `Fintype.elems` order. The smallest actual witness may satisfy any `pos_between[j]`. So permutation alone doesn't save us unless we ALSO permute the pointTypes.

**Can we permute pointTypes?**: `IntervalPattern.holds` cares about which `alpha_i` matches which witness position. If we define `pos_between_sorted` as the same multiset but sorted by some canonical model-independent order, and all segment types are equal, then we need a lemma:

```
bracket_holds_perm : ∀ (sigma : Fin n ≃ Fin n),
  (bf.segmentTypes is constant) →
  bf.holds M atomMap t x ↔
  { pointTypes := fun i => bf.pointTypes (sigma i), segmentTypes := bf.segmentTypes }.holds M atomMap t x
```

This would be true and provable: swap the witness roles. This lemma would let us define `enriched_vecEA2_until` with `pos_between` in any order, then prove the backward direction by sorting witnesses and applying the permutation lemma.

**Verdict**: This approach IS viable and preserves the VecEA2 architecture. It avoids changing the return type of `enriched_vecEA2_until`. The cost is proving `bracket_holds_perm` (~30-50 lines), but this is a clean, reusable lemma.

#### Alternative B: Sort pos_between at Definition Time

Instead of using `Fintype.elems` order, define `pos_between` with an explicit sort by some canonical model-independent total order on `NormalForm sig 0 3`. This is a purely definitional change that doesn't affect the type of `enriched_vecEA2_until`.

**Issue**: The backward proof still needs to produce witnesses in the sorted order. The sorting at definition time doesn't help unless the model witnesses also respect that order. The fundamental problem remains: the backward proof extracts witnesses one per SSN, and they may not be in the order dictated by the sorted `pos_between` list.

**Verdict**: This does not solve the underlying problem unless combined with the permutation invariance argument.

#### Alternative C: Sort at the Proof Level (Finite Choice)

In the backward `case bracket`, use `Fintype.elems` to enumerate all `n!` orderings of witnesses, pick the one that is strictly increasing, and show one exists. This uses the axiom of choice implicitly already present in `nf_eval_quant` (which gives ∃ witnesses, not a specific constructive choice).

More concretely: given `n` witnesses `w_0, ..., w_{n-1}` (each satisfying the corresponding `alpha_i`), since they are elements of a linear order, they have a unique non-repeating sorted order. Sort them to get `w_{sigma(0)} < ... < w_{sigma(n-1)}`. Apply the permutation invariance lemma (Alternative A) to swap `pointTypes` accordingly.

**This reduces Alternative C to Alternative A**: the key lemma needed is `bracket_holds_perm`.

#### Alternative D: HEq Transport (Rejected)

The comment at L2149-2151 in `forward_nf_eval_of_holdsLeft` notes that HEq transport is the obstacle. The `n` in `Σ n, VecEA2 n` depends on `pos_between.length` which is a definitionally computed natural number. The forward direction's HEq difficulty arises because `h_eq : enriched_vecEA2_until ... = ⟨n, vea⟩` means `n = pos_between.length` but Lean can't always compute this at the type level for dependent elimination.

For the backward direction specifically, HEq is NOT the issue — the backward direction calls `enriched_vecEA2_until` directly and provides the result as the witness. The type is `Σ n, VecEA2 n` and `vea : Σ n, VecEA2 n` is exactly what's stored. The only sorry is in `case bracket` which is a semantic problem (producing witnesses in the right order), not a type-theory problem.

**Verdict**: HEq transport does not help the backward direction's sorry.

### 6. What Happens to VVecEA2.translateLeft Pipeline

`enriched_bypass_until` (L497-511) wraps `enriched_vecEA2_until` into a `VVecEA2`:
```lean
let vvec : VVecEA2 :=
  { disjuncts := Fintype.elems.val.toList.filterMap fun nf_x =>
      if nf_x_compat_check sub_nf nf_x then
        some (enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms)
      else none }
vvec.translateLeft
```

`VVecEA2.translateLeft` (VecEATranslation.lean L272-273) builds:
```lean
translateVEF1 (v.disjuncts.map fun ⟨_, vea⟩ => vea.translateLeft)
```

where `VecEA2.translateLeft vea = Formula.and vea.endpointLeft.formula (bracketBuildRight vea.bracket vea.endpointRight)`.

The correctness chain is:
```
temporal_truth M t vvec.translateLeft
↔ vvec.holdsLeft M t          [VVecEA2.translateLeft_correct]
↔ ∃ vea ∈ disjuncts, VecEA2.holdsLeft M vea.snd t
↔ ∃ x, nf_eval ...            [backward + forward helper lemmas]
```

**If enriched_vecEA2_until is redesigned as plain Formula:**

The entire `VVecEA2`/`VecEA2` layer would be bypassed. Instead:
```lean
enriched_bypass_until := Formula.disj_list (Fintype.elems.val.toList.filterMap fun nf_x =>
  if nf_x_compat_check sub_nf nf_x then
    some (direct_formula_for nf_x ...)
  else none)
```

The `VVecEA2.translateLeft_correct`, `VecEA2.translateLeft_correct`, `VecEA2.holdsLeft`, `bracketBuildRight`, `bracketBuildRight_correct`, `chainHolds`, `bracket_prepend_witness`, `bracket_extract_first_witness`, `chainHolds_iff_holds` — all of these in `VecEATranslation.lean` (~297 lines) would become unused for the between_tx case.

**Affected files if conjunction approach adopted:**
- `VecEAFormula.lean` — `BracketFormula`, `VecEA2`, `VVecEA2` still needed for other parts? Possibly yes, for the general Rabinovich formalism.
- `VecEATranslation.lean` — entire file bypassed for this specific application
- `KampBypass.lean` — `backward_holdsLeft_of_nf_eval`, `forward_nf_eval_of_holdsLeft` (L1929-2151, ~222 lines) deleted; replaced by a direct biconditional proof

## Recommended Approach

**Recommendation: Permutation Invariance (Alternative A) — minimal surgery, maximum preservation**

The cleanest fix is to prove a `bracket_holds_perm` lemma that shows `BracketFormula.holds` is invariant under simultaneous permutation of witnesses and pointTypes, when segmentTypes is constant. This:

1. **Preserves the entire VecEA2/VVecEA2/translateLeft pipeline** — no architecture changes
2. **Preserves the `endLeft` and `endRight` subcases of `backward_holdsLeft_of_nf_eval`** — these ~76 lines are reusable as-is
3. **Replaces only `case bracket` (4 lines of sorry)** — the new proof:
   - Extracts witnesses from `h_eval_quant` for each `pos_between[i]`
   - Sorts them (by the linear order on `M.carrier`)
   - Applies `bracket_holds_perm` to permute `pointTypes` to match sorted witnesses
   - Concludes `bracket.holds t x`
4. **Requires one new lemma** (`bracket_holds_perm`, ~40 lines) but this is a clean reusable utility in `VecEAFormula.lean`

**Why conjunction approach is more expensive despite seeming simpler:**
- Eliminates ~222 lines of existing backward+forward code
- Requires redesigning `enriched_vecEA2_until` (return type change cascades through `enriched_bypass_until` and `existPart_succ_n1_bypass_k0_until`)
- The conjunction formula needs its own correctness proof connecting `Formula.and` chains to `nf_eval_quant` — similar total proof effort, but starting from scratch
- The `endLeft`/`endRight` content (76 lines) still needs to be reproduced in the new structure

## Evidence / Examples

**Uniform segment type (the crucial fact):**

`enriched_vecEA2_until` at L463-465:
```lean
let seg_guard : TemporalPred :=
  ⟨formula_conjList (neg_between.map fun ssn =>
    (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
```
and at L470:
```lean
segmentTypes := fun _ => seg_guard
```

ALL segment slots get the SAME `seg_guard`. This is the key structural fact enabling permutation invariance: the segment predicate is positionally independent, so reordering witnesses doesn't change which segment predicate applies to each gap.

**`IntervalPattern.holds` with uniform segments decomposes:**

For `n+1` witnesses with uniform `beta_i = seg_guard`:
```
∃ witnesses (strictly increasing in (t,x)),
  (∀ y in (t, x), seg_guard(y)) ∧   -- since all beta_i are the same
  (∀ i, alpha_i(witnesses_i))
```

The segment condition becomes `∀ y ∈ (t,x), seg_guard(y)` independently of witness ordering. The point conditions require only that each `alpha_i` is witnessed somewhere in `(t,x)`. Sorting the witnesses then gives the required strict monotonicity.

**Forward direction already uses sorry for different reason:**

`forward_nf_eval_of_holdsLeft` (L2149-2151) uses sorry explicitly because of HEq transport difficulty when extracting the VecEA2 structure from the `Σ n, VecEA2 n` via `h_eq`. This is a distinct problem from the backward direction's bracket ordering issue — the forward direction's sorry is caused by dependent type elimination on the existential `n`, not by ordering.

## Confidence Level

**High** — the structural analysis is based on direct reading of all relevant code. The key facts are:

1. The backward proof's sorry is ONLY in `case bracket` (line 2081)
2. `segmentTypes` is uniformly `seg_guard` — confirmed at L470
3. The permutation invariance approach is mathematically sound for uniform segments
4. The VecEA2 pipeline is well-factored and independent of the ordering flaw (the flaw is in how witnesses are constructed, not in the correctness of `VecEA2.translateLeft_correct`)

## Risk Assessment

| Risk | Level | Details |
|------|-------|---------|
| Permutation lemma difficulty | Low-Medium | Standard finite permutation argument; Lean's `Finset.sort` and `List.Perm` infrastructure should help |
| Sorting within `M.carrier` | Low | `M.carrier` has `<` which is a strict linear order; any finite set of elements can be sorted |
| Forward sorry (HEq) | High | The forward direction (L2151) has a SEPARATE sorry from HEq that is independent of this fix — it needs its own resolution. Even after fixing the backward bracket case, the forward direction remains sorry |
| Since direction symmetry | Medium | `existPart_succ_n1_bypass_k0_since` at L2308 is entirely sorry — this is a separate task with symmetric structure; the permutation approach works there too |
| k>0 case | High | `existPart_succ_n1_bypass` at L2396 is sorry for k>0 — this is a deeper inductive case not addressed here |

**Critical finding**: There are FOUR active sorries in the file:
1. L2081 — backward bracket case (addressable via permutation invariance)
2. L2151 — forward HEq issue (independent problem)
3. L2308 — since direction (symmetric to until, needs same work)
4. L2396 — general k>0 case (deeper inductive step)

The conjunction redesign would fix L2081 and potentially L2151 (no more HEq), but L2308 and L2396 remain unaffected by either approach.
