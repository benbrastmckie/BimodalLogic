# Research Report: Task #273

**Task**: chronicle_gap_contradiction_proof — BracketFormula ordering design flaw analysis
**Date**: 2026-06-15
**Mode**: Team Research (4 teammates)

## Summary

Four teammates investigated the BracketFormula ordering design flaw in `enriched_vecEA2_until`, the impact of replacing the bracket encoding, the sorry-free backward direction, and whether `enriched_bypass_since` is closeable independently. Key consensus: the ordering flaw is real and fundamental (all 4 confirm); the naive conjunction-of-existentials replacement is **unsound** (loses the y < x bound); simple permutation invariance fails because pointTypes are SSN-indexed (not identical); the Since case is completely independent of the bracket flaw and can be proved first, BUT `enriched_bypass_since` has its own interval-bounding unsoundness for positive between_xt SSNs. The recommended fix is to change `enriched_vecEA2_until` pointTypes to a disjunction over all positive between_tx NFs, making the bracket permutation-invariant. The backward direction then uses NF-distinctness to sort witnesses; the forward direction uses NF mutual-exclusivity to reconstruct individual SSN witnesses.

## Key Findings

### 1. The Ordering Problem Is Real and Fundamental (ALL — HIGH confidence)

`IntervalPattern.holds` (ExistsForallNF.lean:117) requires witnesses `Fin (n+1) → M.carrier` to be strictly increasing (`i < j → witnesses i < witnesses j`). The `enriched_vecEA2_until` bracket at KampBypass.lean:468-471 builds `BracketFormula n` where `n = pos_between.length` and `pointTypes i = nfPred(nf_y_proj(pos_between[i]))`. For the backward direction, `h_eval_quant` provides independent existential witnesses for each positive between_tx SSN — but these witnesses have no guaranteed ordering relationship matching the `Fintype.elems`-determined `pos_between` index order.

The problem is NOT specific to `Fintype.elems` ordering (Teammate C's correction). The fundamental issue: independently-extracted existential witnesses in a linear order have no inherent relative ordering. Two SSNs `ssn_a, ssn_b` with witnesses `y_a, y_b ∈ (t, x)` satisfy no ordering constraint between them.

### 2. Naive Conjunction-of-Existentials Is UNSOUND (A, C — HIGH confidence)

The initially-proposed fix — replacing `BracketFormula n` with individual `Formula.untl char_y Formula.top` conjuncts — is semantically wrong. `Formula.untl char_y top` at `t` gives `∃ y > t, char_y(y)` with **no upper bound** `y < x`. The bracket's essential semantic contribution is constraining witnesses to the open interval `(t, x)`. The temporal language cannot express `∃ y ∈ (t, x)` as a formula at `t` or `x` alone — this is precisely why the VecEA2/BracketFormula machinery was introduced (Teammate A's critical realization at L229-230 of their report).

The same unsoundness appears in `enriched_bypass_since` (L588): `Formula.untl char_y top` at `x` for positive `x < y < t` SSNs gives `∃ y > x, char_y` without guaranteeing `y < t`.

### 3. Permutation Invariance Fails for Non-Identical PointTypes (C — HIGH confidence)

Teammate B proposed a `bracket_holds_perm` lemma exploiting the uniform `segmentTypes := fun _ => seg_guard`. While segment types ARE uniform (confirmed at L470), the pointTypes are SSN-indexed: `pointTypes i = nfPred(nf_y_proj(pos_between[i]))`, and different SSNs can have different y-predicate profiles. After sorting witnesses by model order, the witness at position `j` satisfies `pos_between[σ(j)]`'s NF, NOT `pos_between[j]`'s NF. Permutation invariance holds for segments but NOT for the point-type/witness pairing (Teammate C Finding 2).

**Exception**: If ALL positive between_tx SSNs have identical `nf_y_proj` values, permutation works. But this is not guaranteed in general.

### 4. The Since Case Is Independent — But Has Its Own Soundness Issue (C, D — HIGH confidence)

`existPart_succ_n1_bypass_k0_since` (L2285-2308) uses `enriched_bypass_since` (L515-594), which constructs formulas via `formula_disjList` and `Formula.snce` — completely separate from the VecEA2/BracketFormula code path. The bracket design flaw is isolated to `enriched_vecEA2_until` (called only by `enriched_bypass_until`). **The Since case can be attempted independently.**

**However**, Teammate C identified that `enriched_bypass_since` has its own soundness flaw: at L588, positive between_xt SSNs are encoded as `Formula.untl char_y top` at `x`, giving `∃ y > x, char_y` without upper bound `y < t`. The backward direction (formula → ∃ x, nf_eval) cannot reconstruct the interval constraint. This is the mirror of the conjunction-of-existentials unsoundness in Finding 2.

**Impact**: The Since sorry at L2308 is a standalone `∃ A, ...` obligation. If `enriched_bypass_since` is unsound for positive between_xt SSNs, the formula `A` it produces is wrong. The Since case may require a VecEA2 `holdsRight` redesign analogous to the Until case, or verification that no positive between_xt SSNs exist in practice for the Since direction.

### 5. The k>0 Sorry Blocks the Full Chain (D — HIGH confidence)

Even closing all three in-scope sorries (L2081, L2151, L2308), `existPart_succ_n1_bypass` still has a sorry at L2396 (k>0 case, marked out-of-scope). The chain to `completeness_discrete` via `kamp_prior_expressive_completeness → US_expressively_complete_over_prior` remains blocked until k>0 is handled. This is a scoping decision (expand task 273 or create task 273b), not a technical obstacle for the current work.

### 6. Blast Radius of Any Bracket Redesign Is Contained (D — HIGH confidence)

- **Eq case** (sorry-free): uses `enriched_bypass_eq` — completely separate code path. Zero impact.
- **Since case**: uses `enriched_bypass_since` — separate code path. Zero impact from bracket changes.
- **Until case only**: approximately 200-400 lines of Until-specific code affected (definitions L444-512, backward L1934-2081, forward L2083-2151).
- Task 273 is a prerequisite for task 202 (Reynolds bypass) since task 202 uses `US_expressively_complete_over_prior`.

## Synthesis

### Conflicts Resolved

1. **Permutation invariance (B) vs. non-identical pointTypes (C)**:
   
   B argues `bracket_holds_perm` works because segmentTypes are uniform. C argues it fails because pointTypes differ by SSN index. **Resolution**: C is correct. Sorting witnesses produces `witnesses j = y_{σ(j)}` satisfying `pos_between[σ(j)]`'s NF, but the bracket requires `pointTypes j = pos_between[j]`'s NF at position `j`. The permutation changes which NF each position requires, but the bracket definition is fixed. B's approach would need the bracket DEFINITION to change (model-dependent pointTypes), which is not possible since the definition is model-independent.

2. **Conjunction approach (A initial) vs. unsoundness (A later, C)**:
   
   A initially proposed conjunction-of-existentials, then realized it's unsound (the bracket exists precisely because `∃ y ∈ (t,x)` can't be expressed at `t` alone). C independently confirmed unsoundness. **Resolution**: Unanimous agreement — the bracket is semantically necessary; the flaw is in the PROOF, not the formula.

3. **Since independence (D) vs. Since unsoundness (C)**:
   
   D says Since can be proved first (independent code path). C says the Since formula itself is unsound for positive between_xt SSNs. **Resolution**: Both are correct and compatible. The Since code path IS independent of the bracket flaw, but it has its OWN soundness issue. The Since case should be investigated first (verify soundness) before attempting the proof.

### Recommended Fix: Disjunction PointTypes (C's Proposal)

The most promising architectural fix is to change `enriched_vecEA2_until`'s bracket construction:

**Current** (L468-471):
```lean
let bracket : BracketFormula n :=
  { pointTypes := fun i =>
      nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]'(by omega)))
    segmentTypes := fun _ => seg_guard }
```

**Proposed**:
```lean
let bracket : BracketFormula n :=
  { pointTypes := fun _ =>
      ⟨formula_disjList (pos_between.map fun ssn =>
        nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn))⟩
    segmentTypes := fun _ => seg_guard }
```

With identical pointTypes (all = disjunction), the bracket is trivially permutation-invariant. **Backward direction**: extract n witnesses from `h_eval_quant`, each satisfying its own NF (hence the disjunction). Witnesses at distinct points (by NF mutual exclusivity — see below), sort them, provide as strictly increasing witnesses. **Forward direction**: each witness satisfies the disjunction, hence satisfies exactly one NF (by NF mutual exclusivity). Combined with n distinct witnesses and n distinct NFs, pigeonhole gives all NFs covered.

**Critical dependency**: NF mutual exclusivity. Two different `nf_y_proj(ssn)` values give different predicate profiles, so they cannot be simultaneously satisfied by the same point. This needs to be proved as a lemma (~20-30 lines) using the fact that `NormalForm sig 0 1` values are complete boolean assignments.

**Open question for forward direction**: Can two different SSNs in `pos_between` have the SAME `nf_y_proj` value? If `nf_y_proj` is NOT injective on `pos_between`, then two witnesses could satisfy the same NF disjunct, leaving another NF unwitnessed. This must be resolved — either prove `nf_y_proj` is injective on `pos_between`, or handle the non-injective case.

### Gaps Identified

1. **nf_y_proj injectivity on pos_between**: Must determine whether `nf_y_proj` is injective on `pos_between`. If two different SSNs `ssn_a ≠ ssn_b` in pos_between have `nf_y_proj(ssn_a) = nf_y_proj(ssn_b)`, the disjunction approach's forward direction has a gap. These SSNs would differ only in x-t ordering/compatibility bits, not in y-predicates. Investigate: can `pos_between` contain two SSNs with the same y-projection?

2. **enriched_bypass_since soundness for positive between_xt**: Teammate C identified that `Formula.untl char_y top` at `x` (L588) loses the upper bound `y < t`. Must verify whether positive between_xt SSNs actually occur in the Since direction for valid inputs. If they do, `enriched_bypass_since` needs redesign (parallel VecEA2 holdsRight approach).

3. **`between_tx_temporal_iff` unused in bracket case**: Teammate A identified this existing lemma (L1900-1925) as the exact bridge needed for both directions but currently unused in the bracket case. Any fix should leverage this lemma.

4. **n=0 case is trivially provable**: When pos_between is empty (no positive between_tx SSNs), the bracket reduces to a universal with seg_guard — no witness ordering issue. This subcase should be closed first regardless of approach.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Bracket fix design, definition analysis, HEq transport | completed | HIGH (diagnosis), MEDIUM (full fix) |
| B | Backward proof impact, permutation invariance, rework quantification | completed | HIGH (analysis), MEDIUM (perm approach — challenged by C) |
| C | Challenge assumptions: ordering reality, conjunction soundness, perm failure, Since independence | completed | HIGH |
| D | Strategic sequencing, sorry chain verification, blast radius, k>0 scoping | completed | HIGH |

## Actionable Recommendations

### Phase A: Verify Since Soundness + Close Since Case (L2308)

1. **Verify**: Check whether `pos_between` (filtered with `false true` for Since direction) can contain positive between_xt SSNs. If not, the soundness concern is moot and Since can be proved directly.
2. **If sound**: Provide `enriched_bypass_since` as witness `A`, prove biconditional from `formula_disjList_iff` + Since semantics + zone bridges.
3. **If unsound**: Redesign `enriched_bypass_since` to use VecEA2 holdsRight or verify that between_xt positives don't occur.
4. **Estimated effort**: 150-250 lines.

### Phase B: Disjunction PointTypes Redesign (Until Bracket)

1. **Prove nf_y_proj injectivity** (or non-injectivity) on `pos_between` — this determines whether the forward direction has a gap.
2. **Change `enriched_vecEA2_until`** pointTypes to disjunction of all positive between_tx NFs.
3. **The formula changes** — so `VVecEA2.translateLeft_correct` produces a different temporal formula. The correctness chain (translateLeft_correct → holdsLeft → nf_eval) must be re-proved for the new definition.
4. **Estimated effort**: 150-300 lines (definition change + backward proof + forward proof).

### Phase C: Close Bracket and Forward Sorries

1. **Backward (L2081)**: Sort witnesses by model order, provide as strictly increasing. NF exclusivity ensures distinctness. Each satisfies the disjunction. Segment guard holds everywhere in (t,x).
2. **Forward (L2151)**: Extract witnesses from bracket. Each satisfies exactly one NF (exclusivity). Pigeonhole + injectivity gives all SSNs covered. Use `between_tx_temporal_iff` to reconstruct `nf_eval_nf`.
3. **Estimated effort**: 200-350 lines total.

### Scoping Decision: k>0 (L2396)

The three in-scope sorries (L2081, L2151, L2308) make `existPart_succ_n1_bypass_k0` sorry-free, but `existPart_succ_n1_bypass` still has a sorry at L2396 for k>0. The full Kamp chain to `completeness_discrete` is blocked until k>0 is handled. Decision needed: expand task 273 or create task 273b.

## References

- Rabinovich 2014: Proposition 3.5 (EF → TL via nested Until/Since), Notation 5.2 (bracket formula)
- KampBypass.lean: L444-492 (enriched_vecEA2_until), L515-594 (enriched_bypass_since), L1934-2081 (backward), L2083-2151 (forward), L2285-2308 (Since), L2319-2365 (main theorem)
- ExistsForallNF.lean: L106-132 (IntervalPattern.holds)
- VecEAFormula.lean: BracketFormula, VecEA2, VVecEA2 definitions
- Prior reports: 33_team-research.md (architecture, root cause), 34_kamp-sorry-closure.md (plan v34 with BLOCKER)
