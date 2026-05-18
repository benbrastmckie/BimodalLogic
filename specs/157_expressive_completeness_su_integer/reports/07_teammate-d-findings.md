# Teammate D (Horizons) Findings: Task #157 Round 7

**Focus**: Strategic assessment of axiom elimination track (Phases 6B/6C/8)
**Date**: 2026-05-17

## Key Findings

### 1. The 9 Axioms Will Propagate to bx_completeness

**Critical discovery**: `US_expressively_complete_over_Z` (ExpressiveCompleteness.lean:2247) calls `proper_separation_theorem_int` which calls `all_properly_separable` — using all 4 `is_properly_separable` axioms. It also calls `proper_separation_preserves_atoms` (the 9th axiom). Currently `US_expressively_complete_over_Z` is NOT imported anywhere, but task 155 Phase 3B **will** import it for Theorem 14 (gap elimination). This means:

- When task 155 Phase 3B wires expressive completeness into the Reynolds pipeline, the 9 axioms propagate through `bx_completeness`
- `#print axioms bx_completeness` will show 9 `SeparationThm` axioms plus any `sorryAx` from tasks 139/140
- Task 155's definition of done explicitly says: "`#print axioms bx_completeness` shows no `sorryAx`"
- Lean 4's `#print axioms` shows ALL axioms — including custom `axiom` declarations, not just `sorryAx`

**Implication**: The 9 axioms are **not just cosmetic debt**. They are custom `axiom` declarations that will appear in `#print axioms bx_completeness`. While task 155's DoD only says "no `sorryAx`" (and these are technically not `sorryAx` — they are named axioms), any reviewer running `#print axioms` will see 9 unproved assumptions. For a formalization meant to establish sorry-free completeness, this is a significant blemish.

### 2. Roadmap Assessment

From `specs/ROADMAP.md` (line 55):
> **Phase 2 — Frame hierarchy + axiom cleanup**: Four-tier hierarchy... Then remove TF (task 124), remove A4a (task 115), redefine G/H/F/P via U/S (task 116). Reduces primitives to {S, U, □, →, ⊥}.

Axiom elimination in SeparationThm.lean is **not explicitly on the roadmap**. The roadmap's "axiom cleanup" refers to the BX axiom system itself (reducing the axiom count from 42 to fewer), not to eliminating Lean `axiom` declarations in the separation stack.

However, the roadmap Phase 3 mentions expressive completeness as a building block — and a building block built on 9 axioms undermines the overall formalization quality.

### 3. Task 155 Dependency Analysis

Task 155 (state.json) lists dependencies: `[154, 157]`. Phase 3B is "blocked on 157." But examining what Phase 3B actually needs:

- **It needs `US_expressively_complete_over_Z`** — specifically, the ability to convert monadic FO formulas to temporal formulas
- **It does NOT need axiom-free separation** — the theorem works with axioms
- **Phase 3B's DoD**: Wire gap elimination using expressive completeness; achieve `#print axioms bx_completeness` with no `sorryAx`

Since `US_expressively_complete_over_Z` is already proved (with axiom dependencies, not `sorry`), **task 155 Phase 3B is technically unblocked right now**. The axioms make `bx_completeness` depend on 9 custom axioms, but these are sound and technically not `sorryAx`.

### 4. Infrastructure Already Built — Phase 6 Cost-Benefit

From the code (Hierarchy.lean, 1054 lines):

**Already built (Phase 6A, ~418 new lines)**:
- `abstract_snce` and `abstract_snce_correct` (semantic roundtrip)
- 4 preservation lemmas (U-free, S-free, no-U-nested, makes-S-free)
- 10+ junction-depth monotonicity lemmas
- `abstract_snce_inside_untl_jd_lt` (the key WF decrease theorem)
- `snce_achieves_max_jdU`, `snce_inside_U_arg` predicates

**Remaining (Phase 6B)**:
- `no_S_nested_in_U_separable` — needs Cases 5-8 via Lemma 10.2.4
- `junction_depth_separable` — needs the subroutine above

**The blocker chain**: `junction_depth_separable` → `no_S_nested_in_U_separable` → Lemma 10.2.4 → Cases 5-8 → `all_separable` (CIRCULAR, currently uses the axioms)

### 5. Mathematical Insight: Cases 5-8 Are NOT Standalone

Re-reading GHR94 carefully (ch10.md lines 80-120), Cases 5-8 are described as **reductions**, not terminal formulas:

- **Case 6**: "Eliminations (3) and (5) can be used to finish the separating."
- **Case 7**: "The first disjunct can be further eliminated by eliminations (8) and (4)."
- **Case 8**: "can be reduced to cases already discussed... especially elimination (5)."

This means Cases 5-8 produce intermediate formulas that STILL have U nested under S. The GHR94 proof works because these intermediate formulas have **lower junction depth** (or fewer U occurrences at this nesting level). The `all_separable` used in NormalForm.lean is correct but circular — it should be the IH of the junction-depth induction instead.

**Key insight**: Cases 5-8 don't need "correct explicit separated equivalents." They only need correct **intermediate** equivalents that have lower measure. The counterexample in Eliminations.lean:460-494 shows the explicit formula is wrong, but the correct approach is an intermediate formula + IH application — NOT a single-step formula.

### 6. Option F (Inline Elimination) Is the Most Promising

**Option F: Inline Cases 5-8 within the junction-depth induction**

The GHR94 proof of Lemma 10.2.3 produces intermediate formulas, not separated formulas. The current code treats Cases 5-8 as producing separated output (`is_separable`), which is why it needs the full `all_separable` axiom. Instead:

1. Within the junction-depth induction, when we encounter S(C, F) with U(A,B) at top level:
2. Apply Cases 1-4 to forms with U in only one position → these DO produce separated output (proved in Eliminations.lean)
3. Apply Cases 5-8 to forms with U in both positions → these produce **intermediate** formulas with **U still under S but at lower depth**
4. Apply the **IH** (from the junction-depth induction) to these intermediate formulas

This approach:
- Avoids needing correct "separated equivalents" for Cases 5-8
- Uses the GHR94 intermediate formulas directly (which MAY be correct even if the final single-step formula isn't)
- Leverages the IH to handle the remaining nesting
- Is exactly what GHR94 describes but our codebase misimplemented as standalone lemmas

**Risk**: The intermediate formulas from GHR94 Cases 5-8 might also be incorrect for integers. But the counterexample only tested the FINAL separated formula, not the intermediate reductions.

## Recommended Approach

**Primary recommendation: Option F (Inline Elimination)**

Rearchitect Phases 6B as a single unified induction rather than standalone case lemmas. The junction-depth induction provides the IH that Cases 5-8 need.

**Implementation sketch**:
1. In `junction_depth_separable`, proceed by `Nat.strongRecOn` on `junction_depth (expand_temporal φ)`
2. For jd = 0, 1: existing infrastructure handles this
3. For jd ≥ 2: find S-under-U (or U-under-S), abstract with fresh atom, separated form has lower jd
4. Within the subroutine `no_S_nested_in_U_separable`, decompose S(C,F) into normal form
5. Cases 1-4: apply existing `elim_case_1/2/3/4` theorems
6. Cases 5-8: apply the GHR94 intermediate reductions, then apply the IH (available because we're inside the induction)

**Secondary recommendation: If Option F fails, pursue Option E (Partial Elimination)**

Eliminate only the 4 `is_separable` axioms by proving `all_separable` without axioms, while keeping the 5 `is_properly_separable` axioms. The bridge from `is_separable` to `is_properly_separable` is a separate (easier) theorem.

**Fallback: Option D (Document and Move On)**

If both F and E fail, document the axioms as sound, well-understood limitations. Ship task 155 Phase 3B with the axioms. The axioms appear in `#print axioms` but are not `sorryAx`.

## Strategic Assessment

### Value of Full Axiom Elimination

| Factor | Assessment |
|--------|-----------|
| Mathematical value | HIGH — first formalization of GHR94 separation hierarchy for Z |
| Downstream impact | MEDIUM — bx_completeness gets 9 fewer axioms |
| Publication quality | HIGH — "axiom-free" vs "9 axioms" is a significant difference |
| Risk | MEDIUM — Option F changes the architecture but the math is well-understood |
| Effort | ~300-500 LOC (Option F), ~2-3 days |
| Opportunity cost | LOW — task 155 Phase 3B is the only dependent, and it can proceed in parallel |

### Value of Not Doing It

| Factor | Assessment |
|--------|-----------|
| Time saved | 2-3 days |
| Risk avoided | Medium (no chance of introducing new bugs) |
| Downstream impact | 9 axioms in bx_completeness's `#print axioms` |
| Publication quality | Acceptable but not ideal |
| Task 155 unblocked | Already unblocked (axioms are not sorryAx) |

### Unconventional Ideas

1. **Two-phase approach**: Prove `all_separable` (the 4 simpler axioms) now, defer `all_properly_separable` (needs bridge theorem) to a later task. This gives 4-axiom elimination immediately.

2. **Redefine proper separation**: If `is_properly_separated` could be shown equivalent to `is_syntactically_separated` (which it likely is after `expand_temporal`), then `all_properly_separable` follows from `all_separable` + `expand_temporal_equiv`. This reduces 8 axioms to 4.

3. **Accept axioms but add verification**: Add `lean_verify` assertions in CI that the axioms are consistent (no `False` derivable). This doesn't eliminate them but increases trust.

4. **Merge task 157 Phase 6 with task 155 Phase 3B**: The junction-depth induction for separation and the gap elimination for completeness share the same mathematical universe. A combined implementation might find synergies.

## Evidence/Examples

### Counterexample Only Targets Final Formula

The counterexample (Eliminations.lean:460-494) shows:
- LHS: S(a ∧ U(A,B), q ∨ U(A,B))(3) = TRUE
- RHS (GHR94 formula): S(a, B) ∧ [A ∨ (B ∧ U(A,B))] ∨ ... = FALSE

But this tests the **final separated equivalent**. The intermediate reduction in Case 5 produces:
```
S(a, B) ∧ [A ∨ (B ∧ U(A,B))]
∨ S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A)) ∧ [A ∨ (B ∧ U(A,B))] ∧ ¬S(¬q, ¬A)
```

This IS an intermediate formula — it still contains `U(A,B)` and `S(...)` but the U(A,B) occurrences are NOT under S. The formula reduces junction depth. Whether it is CORRECT for integers is the key question that needs verification (the counterexample didn't test this specific formula as an intermediate step, only as a final equivalence).

### Infrastructure Already Invested

418 lines of junction-depth infrastructure (abstract_snce, preservation lemmas, decrease lemmas) are already in Hierarchy.lean. Abandoning Phase 6 means this code is dead weight. Completing Phase 6 amortizes the investment.

## Confidence Level

- **Option F feasibility**: Medium-High (the math is sound, the architecture change is well-defined, but requires careful implementation)
- **Intermediate GHR94 formulas being correct for Z**: Medium (not yet verified, but GHR94 claims validity for integer time)
- **Overall axiom elimination being worth the effort**: High (the 9 axioms will propagate to bx_completeness)
- **Task 155 Phase 3B can proceed without axiom elimination**: High (axioms are not sorryAx)

## References

- GHR94 Ch 10.2, Lemma 10.2.3 Cases 5-8 (intermediate reductions, not terminal formulas)
- GHR94 Ch 10.2, Lemmas 10.2.4-10.2.8 (hierarchical induction structure)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (1054 lines of existing infrastructure)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (9 axiom declarations)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean:460-494` (Case 5 counterexample)
- `specs/ROADMAP.md` (Phase 2 axiom cleanup, Phase 3 expressive extensions)
- `specs/155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md` (Phase 3B dependency on task 157)
- `specs/157_expressive_completeness_su_integer/summaries/06_implementation-summary.md` (partial completion status)
