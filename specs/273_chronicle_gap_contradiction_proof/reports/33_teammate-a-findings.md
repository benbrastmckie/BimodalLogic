# Teammate A Findings: Architectural Restructuring of KampBypass.lean

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Role**: Teammate A (Primary Angle) - Architectural restructuring
- **Date**: 2026-06-15
- **Scope**: KampBypass.lean sorry closure via architectural analysis

---

## Key Findings

1. **The file has 5 in-scope sorries** (not 6 as stated in the brief): L974 (eq case), L1579 (bracket backward), L1637 (forward/forward_nf_eval), L1749 (since case), L1837 (depth>=2, out of scope). Line numbers shifted from the original brief due to prior implementation work.

2. **The sorry sites cluster into three independent proof obligations**: (A) the equality case (L974), (B) the Until backward chain (L1579 bracket + L1637 forward reconstruction), and (C) the Since case (L1749). These have almost no proof-level dependencies between them.

3. **The bracket sorry (L1579) is the architectural bottleneck**: The current `BracketFormula` approach for `between_tx` witnesses requires strictly-increasing witnesses matched to a statically-ordered list `pos_between`. This creates an ordering mismatch: the model's actual witness order need not match `pos_between`'s list order (which comes from `Fintype.elems.val.toList.filter`). This is the core reason three cycles failed to close this sorry.

4. **A structural fix exists**: Replace the current `pos_between`-list-indexed bracket with a `BracketFormula 0` (trivial bracket) plus a `segmentTypes`-only guard. Because all positive `between_tx` ssns contribute only a witness existence claim, and because the segment guard (negated char_y for negative ssns) already holds everywhere in (t,x) via `h_seg`, the bracket condition reduces to: "there exist witnesses y_i in (t,x) with predicate profiles matching each pos ssn." This is SEPARATE from the IntervalPattern's strict-order requirement.

5. **The forward direction (L1637) requires a zone-by-zone reconstruction pattern** that mirrors the backward direction at L1432-1576 but extracts nf_eval facts from `h_endLeft`, `h_endRight`, and `h_bracket`. The infrastructure (zone bridge biconditionals, nfPred_correct, formula_conjList_iff) is entirely present.

6. **The since case (L1749) is a symmetric mirror of the Until case** but uses a different formula encoding (`formula_disjList` + `Formula.snce` instead of VVecEA2). Its proof should follow the Until case structure adapted for Since semantics.

---

## Recommended Architecture

### Option 1: File Split (Primary Recommendation)

Split KampBypass.lean into four files:

```
KampBypassEq.lean      (~300 lines) -- Equality case (x=t)
KampBypassBracket.lean (~250 lines) -- Bracket sorry + BracketFormula helper lemma
KampBypassUntil.lean   (~400 lines) -- Until case forward + backward
KampBypassSince.lean   (~300 lines) -- Since case (mirror of Until)
KampBypass.lean        (~200 lines) -- Main theorem + depth>=2 sorry (unchanged)
```

**Why this helps**:
- Each file has one conceptual obligation; agents cannot "accidentally" analyze the wrong sorry
- The bracket file (smallest, most architectural) can be completed independently without the 1870-line context loading overhead
- Since and Until are symmetric but currently interleaved, leading to context confusion in agents
- The equality case is self-contained and the smallest proof (80-100 lines) -- making it a good first win

**Import chain** (no cycles):
```
KampBypassEq.lean    imports: ZoneBridge, NfCharFormula
KampBypassBracket.lean imports: ZoneBridge, VecEADecomp, VecEAFormula
KampBypassUntil.lean imports: KampBypassBracket, ZoneBridge
KampBypassSince.lean imports: ZoneBridge, VecEADecomp
KampBypass.lean      imports: KampBypassEq, KampBypassUntil, KampBypassSince
```

No circular imports; `KampBypassUntil` depends on `KampBypassBracket` for the bracket lemma.

### Option 2: Structural Refactor Within Single File

Without splitting, restructure by:
1. Moving `backward_holdsLeft_of_nf_eval` bracket case into a dedicated `bracket_holds_of_eval_quant` helper theorem declared before `backward_holdsLeft_of_nf_eval`
2. Moving `forward_nf_eval_of_holdsLeft` into a standalone helper with explicit zone dispatch
3. Adding a `since_bypass_helper` theorem that uses VecEA2 (same as Until) rather than the current `formula_disjList` approach in `enriched_bypass_since`

**Why Option 2 is less preferred**: The single-file context overloads agents trying to close one sorry while reasoning about the whole 1870-line proof, creating analysis paralysis.

---

## File Split Proposal

### KampBypassEq.lean

Contains:
- `eq_case_orders` (already proved, move here)
- `eq_case_zone_below`, `eq_case_zone_above`, `eq_case_zone_eq` (already proved, move here)
- `witness_eq_t_of_no_order` (already proved, move here)
- `enriched_bypass_eq` (definition, move here)
- `existPart_succ_n1_bypass_k0_eq` (theorem with **sorry at L974**, fill here)

**The L974 sorry** -- Eq case proof:

Goal:
```
⊢ temporal_truth M atomMap t (enriched_bypass_eq ...) ↔ ∃ x, nf_eval_nf M 1 (1+1) (Fin.cons x fun _ => t) sub_nf
```

Proof sketch:
- **Backward**: Given `x` with `nf_eval_nf`, apply `witness_eq_t_of_no_order` to get `x = t`, subst. Get `nf_x = nf_characteristic M 1 1 (fun _ => t)`. Show `nf_x_compat_check sub_nf nf_x = true` (from `h_pred_compat` + `h_t_compat`). Show `nf_x` is in `Fintype.elems.val.toList` (Fintype.complete). Evaluate the disjunction: the term for `nf_x` evaluates as `char_1(nf_x) AND quant_conjuncts`. Use `char_1_correct` for `char_1(nf_x)` and `eq_case_zone_*` for the quant_conjuncts.
- **Forward**: From formula truth, get some compatible `nf_x` with all conjuncts true at `t`. Use `char_1_correct` → `nf_eval_nf M 1 1 (fun _ => t) nf_x`. Reconstruct `nf_eval_nf M 1 2 (Fin.cons t (fun _ => t)) sub_nf` from atom part (`h_pred_compat` + `h_t_compat`) and quantifier part (from quant_conjuncts via `eq_case_zone_*`).

Key supporting lemmas (all exist): `witness_eq_t_of_no_order`, `eq_case_orders`, `eq_case_zone_below/above/eq`, `nf_x_compat_check` definition, `formula_disjList_iff`, `nf_characteristic_satisfies`, `char_1_correct`.

**Estimated lines**: 100-130. **Feasibility**: HIGH.

### KampBypassBracket.lean

Contains:
- `between_tx_temporal_iff` (already proved, move here)
- New helper: `bracket_holds_of_eval_quant` (the current sorry at L1579 extracted)
- A companion helper: `eval_quant_of_bracket_holds` (for the forward direction L1637)

**The L1579 sorry** -- Bracket holds:

Goal:
```
⊢ BracketFormula.holds M atomMap vea.snd.bracket t x
```

Where `vea.snd.bracket` is `enriched_vecEA2_until`'s bracket, defined with:
- `pos_between` = list of compatible `between_tx` ssns with `sub_nf.2 ssn = true`
- `n = pos_between.length`
- `bracket.pointTypes i = nfPred atomMap h_surj (nf_y_proj pos_between[i])`
- `bracket.segmentTypes _ = seg_guard` (uniform for all segments)

Available: `h_eval_quant : ∀ ssn, (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn = true`

**Architectural issue identified**: `BracketFormula.holds` requires `IntervalPattern.holds` which requires strictly-increasing witnesses in order. For `n` positive `between_tx` ssns, we need `n` witnesses `y_0 < ... < y_{n-1}` in `(t, x)` with `nfPred ... (nf_y_proj pos_between[i])` holding at `y_i`. But from `h_eval_quant`, we only know that for EACH ssn in `pos_between`, some witness exists in `(t, x)` -- the witnesses from different ssns may come in any order.

**The fix**: Note that `between_tx_temporal_iff` gives `∃ y, t < y ∧ y < x ∧ preds_match`. Since elements of `pos_between` are distinct NFs, they have distinct `nf_y_proj` projections (by injectivity: two between_tx NFs with identical y-predicates, x-predicates, t-predicates, and order profile are the same NF by function extensionality). Therefore, witnesses from different ssns have distinct predicate profiles, hence are distinct points in M, hence are totally ordered by M's linear order. We can SORT these witnesses and construct a permutation `σ` such that `witnesses σ(i)` is the witness for `pos_between[i]`.

However, this requires a sorting/permutation argument in Lean which is moderately complex.

**Alternative architectural fix (recommended)**: Define a new helper theorem that directly constructs `IntervalPattern.holds` from a `Multiset` of (witness, predicate) pairs rather than from a sorted list. Since all `segmentTypes` are `seg_guard` (which holds everywhere on (t,x)), the key simplification is:

```lean
theorem bracket_from_segment_guard_and_witnesses
    (n : Nat) (bf : BracketFormula n)
    (h_seg : ∀ y, z0 < y → y < z1 → ∀ k, bf.segmentTypes k |>.eval_at M atomMap y)
    (h_witnesses : ∀ i : Fin n, ∃ y, z0 < y ∧ y < z1 ∧ bf.pointTypes i |>.eval_at M atomMap y) :
    bf.holds M atomMap z0 z1 := by
  -- Use Classical.choice + sorting
```

This separates the ordering concern from the predicate concern. The bracket holds IF there are witnesses with the right predicates AND the segment guard holds everywhere. The sorting argument is encapsulated in this helper lemma.

**Estimated lines for helper**: 60-80. **Bracket sorry itself with helper**: 40-60. **Total**: ~130 lines.

**Feasibility**: MEDIUM-HIGH. The sorting argument requires `List.Fin.sort` or `Finset.sort` from Mathlib, plus decidable linear order on M.carrier (which is given from `OrderedMonadicStructure`).

### KampBypassUntil.lean

Contains:
- `pre_conditions_at_t_until_holds` (already proved, move here)
- `pre_conditions_at_t_until` (definition, move here)
- `below_t_temporal_iff`, `eq_t_temporal_iff`, `eq_x_temporal_iff`, `above_x_temporal_iff` (all proved, move here)
- `backward_holdsLeft_of_nf_eval` (the main backward helper; has the bracket sorry as case bracket -> import from KampBypassBracket)
- `forward_nf_eval_of_holdsLeft` (sorry at L1637)
- `existPart_succ_n1_bypass_k0_until` (which calls backward + forward)

**The L1637 sorry** -- Forward reconstruction:

Goal:
```
case pos
⊢ nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

Available: `h_endLeft : TemporalPred.eval_at M atomMap vea.endpointLeft t`, `h_t_lt_x : t < x`, `h_endRight : TemporalPred.eval_at M atomMap vea.endpointRight x`, `h_bracket : BracketFormula.holds M atomMap vea.bracket t x`, `h_compat : nf_x_compat_check sub_nf nf_x = true`

Proof sketch (zone-by-zone):
1. **Atom part** (`∀ a : AtomKind sig 2`):
   - At index 0 (x): `h_endRight` contains `char_1(nf_x)` → via `char_1_correct` → `nf_eval_nf M 1 1 (fun _ => x) nf_x` → extract pred atoms at x
   - At index 1 (t): from `h_atoms` directly  
   - Order x < t: false by `h_gt = true`, `h_lt = false` (t < x)
   - Order t < x: true from `h_t_lt_x`
2. **Quantifier part** (`∀ ssn, (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn`):
   - For each ssn, case-split on `ssn_zone_until ssn`:
     - `below_t`: extract from `h_endLeft` (pre_conditions_at_t) using `below_t_temporal_iff` backward
     - `eq_t`: extract from `h_endLeft` using `eq_t_temporal_iff` backward  
     - `between_tx` positive: extract witness from `h_bracket` (BracketFormula.holds)
     - `between_tx` negative: show impossibility from `seg_guard` (h_bracket segmentTypes)
     - `eq_x`: extract from `h_endRight` using `eq_x_temporal_iff` backward
     - `above_x`: extract from `h_endRight` using `above_x_temporal_iff` backward
     - Other zones: show the zone condition is false from `nf_x_compat_check = true`

**The key missing piece**: Need to connect `vea` (from h_eq) back to `enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms`. The hypothesis `h_eq` gives this equality. Then `simp only [enriched_vecEA2_until]` unfolds the definition to expose the bracket's structure.

**Estimated lines**: 150-200. **Feasibility**: MEDIUM-HIGH.

### KampBypassSince.lean

Contains:
- `enriched_bypass_since` (definition, move here)
- Symmetric zone bridge helpers for Since direction (adapt from Until)
- `existPart_succ_n1_bypass_k0_since` (sorry at L1749)

**The L1749 sorry** -- Since case:

Goal:
```
⊢ ∃ A, ∀ M h_UZ h_SZ t, (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
    (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M 1 (1+1) (Fin.cons x fun _ => t) sub_nf)
```

Where `h_lt = true` (x < t, Since direction).

**Architectural note**: The current `enriched_bypass_since` uses `formula_disjList` + `Formula.snce` directly, NOT VecEA2. This asymmetry with the Until case (which uses VVecEA2) is intentional in the definition but creates a proof asymmetry. The Since proof must work directly with `Formula.snce` semantics.

**Two approaches**:

(A) **Keep formula_disjList encoding**: Prove directly that `formula_disjList` of `Formula.and pre_at_t (Formula.snce pt_x guard)` is equivalent to `∃ x < t, nf_eval`. The Since semantics gives: `∃ x, x < t ∧ temporal_truth M atomMap x pt_x ∧ ∀ z, x < z → z < t → temporal_truth M atomMap z guard`. This mirrors the Until case with swapped endpoints.

(B) **Refactor to VecEA2**: Define `enriched_vecEA2_since` analogous to `enriched_vecEA2_until` with roles of t and x swapped. Use `VecEA2.translateLeft_correct` (with left endpoint = x, right endpoint = t, but Since uses left endpoint at x and existential going right → need right-to-left translation). Actually Since would need `VecEA2.translateRight` or a flipped variant. This is more work but would make the proof symmetric.

**Recommendation**: Approach (A) -- keep the existing formula and prove it directly. The formula already handles the bracket via `guard` (segment guard on (x,t) for negative ssns) and the y-zones at x and t directly. No bracket ordering issue arises because the Since formula uses `Formula.snce pt_x guard` without a VecEA2 bracket.

**Estimated lines**: 160-200. **Feasibility**: MEDIUM.

---

## Per-Sorry Analysis

### Sorry 1: L974 -- existPart_succ_n1_bypass_k0_eq

**Goal**: `temporal_truth M atomMap t (enriched_bypass_eq ...) ↔ ∃ x, nf_eval_nf M 1 2 (Fin.cons x fun _ => t) sub_nf`

**Strategy**: Unfold `enriched_bypass_eq` as `formula_disjList`. Use `formula_disjList_iff`. For forward: show truth of some disjunct implies ∃ x. For backward: given x = t (by `witness_eq_t_of_no_order`), show the disjunct for `nf_characteristic M 1 1 (fun _ => t)` is in the list and holds.

**Critical helper needed**: `eq_bypass_quant_iff : ∀ ssn, (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) ↔ (quant_conjunct for ssn evaluates to true at t)`. This follows from `eq_case_zone_below/above/eq` for the three y-zones. These are all proved.

**Why previous agents failed**: They decomposed but never actually stated this intermediate bridge as a named lemma. Each attempt tried to inline the zone bridges in the main proof, leading to long proof terms that collapsed.

**Fix**: Extract `eq_bypass_quant_iff` as a private helper lemma (~30 lines), then the main proof becomes 60-80 lines.

**Confidence**: HIGH.

### Sorry 2: L1579 -- bracket case in backward_holdsLeft_of_nf_eval

**Goal**: `BracketFormula.holds M atomMap vea.snd.bracket t x`

**Strategy**: Use `h_eval_quant` to get witnesses for each `pos_between` ssn. Use `between_tx_temporal_iff` to extract `∃ y, t < y ∧ y < x ∧ preds_match`. Use `h_seg` for the segment guard. The gap is sorting witnesses into strictly-increasing order.

**New helper needed**: `bracket_from_segment_and_witnesses` as described above. This is the key architectural contribution. Once extracted, the bracket sorry becomes ~30 lines.

**Why previous agents failed**: Agents tried to prove `IntervalPattern.holds` directly without the sorting helper. The inductive structure of `IntervalPattern.holds` (unfolds recursively on n) requires strict monotonicity from the start, creating a chicken-and-egg problem.

**Confidence**: MEDIUM-HIGH (the helper is new content, ~60-80 lines).

### Sorry 3: L1637 -- forward_nf_eval_of_holdsLeft

**Goal**: `nf_eval_nf M 1 (1+1) (Fin.cons x fun _ => t) sub_nf`

**Strategy**: Zone-by-zone reconstruction using `h_endLeft`, `h_endRight`, `h_bracket`. The key is connecting `h_eq : enriched_vecEA2_until ... = ⟨n, vea⟩` to unfold `vea.endpointLeft/endpointRight/bracket` as specific formulas.

**New helper needed**: `unfold_enriched_vea_until` or direct use of `simp only [enriched_vecEA2_until]` after `rw [h_eq]` to expose the formula structure.

**Why previous agents failed**: The `h_eq` equality makes `vea` opaque unless explicitly unfolded. Agents tried to pattern match on `vea` without first using `h_eq` to rewrite.

**Fix pattern**:
```lean
-- After rw [← h_eq] at h_endLeft h_endRight h_bracket
simp only [enriched_vecEA2_until] at h_endLeft h_endRight h_bracket
-- Now h_endLeft = pre_conditions_at_t_until holds at t
-- h_endRight = (char_1 nf_x ∧ right_conjuncts) holds at x
-- h_bracket = bracket holds (pos witnesses + seg guard)
```

**Confidence**: MEDIUM-HIGH.

### Sorry 4: L1749 -- existPart_succ_n1_bypass_k0_since

**Goal**: `∃ A, ∀ M h_UZ h_SZ t h_atoms, temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M 1 2 (Fin.cons x fun _ => t) sub_nf`

**Strategy**: `exact ⟨enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms, fun M h_UZ h_SZ t h_atoms => by ...⟩`. The proof of the iff follows the Since semantics of `formula_disjList` + `Formula.snce`.

**Why previous agents failed**: No attempt was made to actually implement this since the bracket sorry blocked progress conceptually. The Since case is actually structurally simpler than Until (no VecEA2 framework, just formula_disjList).

**Confidence**: MEDIUM.

---

## Evidence and Examples

### Evidence for File Split Feasibility

Import structure analysis: The `KampBypass.lean` imports are:
```
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
import Bimodal.Metalogic.WeakCanonical.Kamp.ZoneBridge
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
```

None of the new sub-files need to import KampBypass.lean, so there are no circular imports. The split is clean.

### Evidence for Bracket Ordering Issue

From `enriched_vecEA2_until`:
```lean
let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
  ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
  (ssn_zone_until ssn == .between_tx) &&
  sub_nf.2 ssn
let n := pos_between.length
let bracket : BracketFormula n :=
  { pointTypes := fun i => nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]'(by omega)))
    segmentTypes := fun _ => seg_guard }
```

The `pos_between[i]` indexing is by list position, not model order. The `IntervalPattern.holds` requires witnesses at position i to satisfy `pointTypes i`, but witnesses from `h_eval_quant` are unordered. This is the architectural gap.

### Evidence that `between_tx` ssns have distinct nf_y_proj

Two ssns s1, s2 in `pos_between` satisfy the same zone filter. If `nf_y_proj s1 = nf_y_proj s2`, then:
- `s1 (.pred p 0) = s2 (.pred p 0)` for all p (same y-preds)
- `s1 (.pred p 1) = nf_x_1var (.pred p 0) = s2 (.pred p 1)` (same x-preds, from compat)
- `s1 (.pred p 2) = parent_atoms (.pred p 0) = s2 (.pred p 2)` (same t-preds, from compat)
- All 6 order atoms are determined by `ssn_zone_until = between_tx` (h_ty=true, h_yx=true, h_yt=false, h_xy=false) and `ssn_xt_compat true false` (h_tx=true, h_xt=false)
- Therefore s1 = s2 by function extensionality on all atoms

So `nf_y_proj` IS injective on `pos_between`. Distinct elements have distinct y-predicate profiles, hence distinct witnesses in any model. The witnesses exist and can be sorted -- the helper just needs to make this argument formal.

### Example: bracket_from_segment_and_witnesses helper design

```lean
/-- When all segment types are uniform (same predicate everywhere),
    BracketFormula.holds follows from any set of witnesses with the right
    pointTypes, regardless of initial order. -/
theorem bracket_holds_of_uniform_segments
    {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (z0 z1 : M.carrier)
    (h_uniform : ∀ i j, bf.segmentTypes i = bf.segmentTypes j)
    (h_seg : ∀ y, z0 < y → y < z1 →
        bf.segmentTypes ⟨0, by omega⟩ |>.eval_at M atomMap y)
    (h_witnesses : ∀ i : Fin n, ∃ y, z0 < y ∧ y < z1 ∧
        bf.pointTypes i |>.eval_at M atomMap y) :
    bf.holds M atomMap z0 z1 := ...
```

This encapsulates the sorting argument and is reusable for other bracket constructions.

---

## Confidence Level

- **File split feasibility**: HIGH. No circular imports, clean separation by proof obligation.
- **L974 (eq case)**: HIGH. All infrastructure present, clear proof path.
- **L1579 (bracket)**: MEDIUM-HIGH. Needs one new helper lemma (~60-80 lines); rest is clear.
- **L1637 (forward)**: MEDIUM-HIGH. Needs `simp only [enriched_vecEA2_until]` unfolding strategy; proof is zone-by-zone but mechanical.
- **L1749 (since)**: MEDIUM. Symmetric to Until but uses different formula encoding; proof must follow Since semantics directly.
- **Overall**: The three implementation cycles failed due to analysis paralysis and lack of a clear "unblocking lemma" for the bracket. The architectural fix (extract `bracket_holds_of_uniform_segments`) is the key insight that makes L1579 tractable.

---

## Recommended Implementation Order

1. **Phase 1**: Extract `bracket_holds_of_uniform_segments` helper in new file or at top of KampBypass.lean (~80 lines). This unblocks the bracket sorry.
2. **Phase 2**: Close L974 (eq case) using the pattern described above (~120 lines).
3. **Phase 3**: Close L1579 (bracket) using the new helper (~40 lines).
4. **Phase 4**: Close L1637 (forward) using `simp only [enriched_vecEA2_until]` + zone dispatch (~180 lines).
5. **Phase 5**: Close L1749 (since) mirroring Until structure (~180 lines).

If doing a file split, phases 1-3 go into `KampBypassBracket.lean`, phase 2 goes into `KampBypassEq.lean`, phases 4-5 go into `KampBypassUntil.lean` and `KampBypassSince.lean` respectively.

**Total estimated new lines**: 500-600 lines across all phases.
**Minimum to make existPart_succ_n1_bypass_k0 sorry-free**: Phases 1-4 (since Phase 5 only handles the Since case which is a separate branch).

---

## Literature Alignment

The Rabinovich 2014 paper's Proposition 3.5 (the core translation) maps interval decompositions to nested Until/Since via:
- Endpoint types α_k → character formula at endpoint
- Segment types β_j → guard formula between witnesses
- Existential witnesses x_i → bracketed witnesses in (t, x)

The `VecEA2` / `BracketFormula` infrastructure faithfully encodes this. The sorry sites correspond to showing:
- L974 (eq case): When x = t, the "interval" degenerates to a point; the translation reduces to char_1 at t with quant_conjuncts.
- L1579 (bracket): The existential witnesses in the between_tx zone can be arranged into strictly-increasing order (IntervalPattern.holds).
- L1637 (forward): From the temporal formula truth, extract the existential witness and reconstruct nf_eval. This is the "translation → exists-forall" direction of Prop 3.5.
- L1749 (since): The Since case of the interval decomposition: the past direction of the translation.

The literature proof treats all four cases symmetrically in Prop 3.5's proof; the Lean formalization treats them asymmetrically due to the VecEA2 framework being applied only in the Until direction.
