# Implementation Plan: Task #306

- **Task**: 306 - Add combinatorial BracketFormula conjunction to VecEAClosure
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/03_spawn-analysis.md
- **Artifacts**: plans/01_bracket-conj-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Add structural (model-independent, non-existential) conjunction operations for BracketFormula, VBracketFormula, and VVecEA2 to VecEAClosure.lean. The existing existential conjunction proofs (`conj_to_bracket_exists`, `conj_holds_vbracket`, `conj_holds_vvecEA2`) return witnesses inside existential quantifiers, preventing their use in the VecEA2 negation closure induction (task 305, Phase 4). The structural versions return fixed syntactic objects that can be used as concrete terms in the induction.

### Research Integration

The spawn analysis from task 305 identified this as a root cause blocker: the three-case proof in `neg_bracket_is_vbracket` produces VVecEA2 disjunct collections from each case, which must be combined by conjunction into a single VVecEA2. Existential witnesses cannot serve this role because the induction requires a fixed syntactic object.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define `BracketFormula.conjStruct` as a pure syntactic operation returning `BracketFormula (n1 + n2)`
- Prove `conjStruct_holds`: if both bracket formulas hold on an interval, the conjunction holds
- Define `VBracketFormula.conj_struct` via pairwise product of disjunct lists
- Define `VVecEA2.conj_struct` combining endpoint predicates and bracket conjunctions
- Prove semantic forward direction for all three conjunction operations

**Non-Goals**:
- Backward direction (conjunction implies both hold) -- not needed for negation closure
- Optimality of witness count in conjStruct (using n1+n2 is acceptable even if fewer suffice)
- Changes to VecEAFormula.lean or any file other than VecEAClosure.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fin arithmetic complexity in conjStruct pointTypes/segmentTypes | M | H | Use `Fin.addCases` or explicit `if i < n1 then ... else ...` with omega |
| Witness merge in conjStruct_holds requires sorted interleaving | H | M | Use Finset.sort on union of witnesses; leverage Mathlib's sorted-list lemmas |
| IntervalPattern.holds unfolding produces large goals | M | M | Work with the holds API directly, avoid unfolding to raw quantifier soup |
| Lean type-level n1+n2 arithmetic (associativity, commutativity) | M | M | Use `Nat.add_comm`, cast where needed, keep definitions simple |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: BracketFormula.conjStruct definition and holds theorem [COMPLETED]

**Goal**: Define the structural conjunction of two bracket formulas and prove its semantic correctness (forward direction).

**Tasks**:
- [ ] Define `BracketFormula.conjStruct (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) : BracketFormula (n1 + n2)` with:
  - `pointTypes i` = `bf1.pointTypes` for `i.val < n1`, `bf2.pointTypes` for `i.val >= n1`
  - `segmentTypes i` = `bf1.segmentTypes` conjoined with `bf2.segmentTypes` at appropriate positions, using `top` for non-overlapping ranges. Specifically: segment `i` covers a sub-interval; map it to the corresponding bf1 segment (or `top` if outside bf1's range) conjoined with the corresponding bf2 segment (or `top` if outside bf2's range)
- [ ] Prove `BracketFormula.conjStruct_holds`: given `bf1.holds M atomMap z0 z1` and `bf2.holds M atomMap z0 z1`, show `(conjStruct bf1 bf2).holds M atomMap z0 z1`. The proof strategy:
  - Case split on `n1` and `n2` (following the pattern in `conj_to_bracket_exists`)
  - For (0, 0): no witnesses needed, segment type is conjunction
  - For (0, n2+1): use bf2's witnesses, conjoin bf1's single segment with each bf2 segment
  - For (n1+1, 0): symmetric, use bf1's witnesses
  - For (n1+1, n2+1): merge bf1 and bf2 witnesses using `Finset.sort` on their union (or direct construction with `List.merge`), then verify point types and segment types at each merged position. Alternative simpler approach: concatenate bf1 witnesses then bf2 witnesses, which is monotone if bf1's last witness < bf2's first witness. Use a Finset.sort-based construction for the general case.
- [ ] Verify with `lean_goal` and `lean_multi_attempt` that all proof obligations close
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure` to verify

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` - Add conjStruct definition and holds theorem after the existing `conj_to_bracket_exists` section (after line 98)

**Verification**:
- `lean_goal` shows no remaining goals at end of `conjStruct_holds`
- `lean_verify BracketFormula.conjStruct_holds` shows no sorry, no sorryAx
- Scoped `lake build` passes for VecEAClosure module

**Implementation notes**:

The key design decision for `conjStruct` is how to handle segment types. Consider `BracketFormula n1` with segments `s1_0, ..., s1_{n1}` and `BracketFormula n2` with segments `s2_0, ..., s2_{n2}`. The result `BracketFormula (n1+n2)` needs segments `r_0, ..., r_{n1+n2}`. The witnesses of the result are w1_0, ..., w1_{n1-1}, w2_0, ..., w2_{n2-1} (after sorting). Segment `r_i` covers the interval between the (i-1)-th and i-th witness of the merged sequence.

For the holds proof, the simplest correct approach mirrors the existing (n1+1, n2+1) case: for each segment, determine which bf1 and bf2 segments overlap with it, and conjoin the appropriate temporal predicates. Since we need `conjStruct` to be model-independent, the segment types must be pre-computed from bf1 and bf2's segment types alone.

A practical simplification: for segment `i` in [0, n1+n2], define `r_i = (corresponding bf1 segment or top) conj (corresponding bf2 segment or top)`. The "corresponding" mapping depends on the witness ordering, but since `conjStruct` is syntactic, we can use a fixed mapping: bf1 "owns" segments 0..n1 (before, between, and after bf1's witnesses) and bf2 "owns" segments 0..n2. In the merged sequence, segment i maps to bf1 segment `min(i, n1)` and bf2 segment `max(0, i - n1)`.

Actually the cleanest approach: define segment types so that each segment in the result conjoins `top` from one side and the actual segment from the other:
- Segments 0..n1 (before bf2's witnesses start): use `bf1.segmentTypes j` conjoined with `bf2.segmentTypes 0` (everything before bf2's first witness)
- Wait, this doesn't quite work because the witnesses aren't guaranteed to interleave that way.

The simplest correct approach that avoids witness-ordering complexity in the definition: for the (n1+1, n2+1) case, use bf1's n1+1 witnesses and set all segment types to `top`, giving a `BracketFormula (n1+1)`. But this changes the witness count from n1+n2 to n1+1. If we want exactly n1+n2, we need the merge approach.

Given the complexity, the implementation agent should:
1. Start with the case-split approach matching `conj_to_bracket_exists`
2. For (0,0), (0,n2+1), (n1+1,0): direct construction (matching existing proof structure)
3. For (n1+1, n2+1): use the merge approach with Finset.sort OR use the simpler "just use bf1's witnesses with top segments" approach, accepting that the result has fewer witnesses than n1+n2

If the n1+n2 witness count is essential for downstream compatibility, the merge approach is required. If any witness count works (as long as the formula holds), the simpler approach suffices.

---

### Phase 2: VBracketFormula and VVecEA2 structural conjunction [COMPLETED]

**Goal**: Lift `conjStruct` to disjunction-list types (VBracketFormula, VVecEA2) and prove semantic forward direction.

**Tasks**:
- [ ] Define `VBracketFormula.conj_struct (v1 v2 : VBracketFormula) : VBracketFormula` whose disjuncts are all pairwise `conjStruct d1 d2` for `d1 in v1.disjuncts`, `d2 in v2.disjuncts`. Use `List.bind` or `List.flatMap` for the Cartesian product.
- [ ] Prove `VBracketFormula.conj_struct_holds`: if `v1.holds M atomMap z0 z1` and `v2.holds M atomMap z0 z1`, then `(conj_struct v1 v2).holds M atomMap z0 z1`. The proof extracts the holding disjuncts from v1 and v2, applies `conjStruct_holds`, and shows the result is in the pairwise product list.
- [ ] Define `VVecEA2.conj_struct (v1 v2 : VVecEA2) : VVecEA2` whose disjuncts are all pairwise combinations with conjoined endpoints and bracket conjStruct.
- [ ] Prove `VVecEA2.conj_struct_holds`: if both hold, the conjunction holds. The proof conjoins the endpoint temporal predicates (using `TemporalPred.eval_at_conj`) and applies `conjStruct_holds` for the bracket component.
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure` to verify
- [ ] Run `lake build` for full project verification

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` - Add VBracketFormula.conj_struct and VVecEA2.conj_struct after the bracket-level conjunction section

**Verification**:
- `lean_verify VBracketFormula.conj_struct_holds` shows no sorry, no sorryAx
- `lean_verify VVecEA2.conj_struct_holds` shows no sorry, no sorryAx
- Full `lake build` passes with zero errors

## Testing & Validation

- [ ] `lean_verify BracketFormula.conjStruct` -- no sorry, no sorryAx
- [ ] `lean_verify BracketFormula.conjStruct_holds` -- no sorry, no sorryAx
- [ ] `lean_verify VBracketFormula.conj_struct_holds` -- no sorry, no sorryAx
- [ ] `lean_verify VVecEA2.conj_struct_holds` -- no sorry, no sorryAx
- [ ] `lake build` passes with zero new errors
- [ ] No new axioms introduced (check `#print axioms` on key theorems)

## Artifacts & Outputs

- `plans/01_bracket-conj-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean`

## Rollback/Contingency

All changes are in a single file (VecEAClosure.lean). If implementation fails, revert to the current version. The existing existential conjunction proofs are preserved and unchanged. If the full merge approach for (n1+1, n2+1) proves intractable in Lean's type system, fall back to the simpler approach (reuse bf1's witnesses with top segments), accepting a smaller witness count than n1+n2 but retaining semantic correctness.
