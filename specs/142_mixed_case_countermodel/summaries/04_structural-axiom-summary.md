# Implementation Summary: Add U(T,bot) -> box(U(T,bot)) Structural Axiom

- **Task**: 142 - mixed_case_countermodel
- **Status**: Implemented
- **Plan**: specs/142_mixed_case_countermodel/plans/04_structural-axiom-plan.md

## What Was Done

Added the structural axiom `discrete_box_necessity` (U(T,bot) -> box(U(T,bot))) to the BX axiom system and used it to eliminate the mixed-case sorry in `bx_completeness`.

### Phase 1: Add Axiom Constructor (COMPLETED)
- Added `discrete_box_necessity` constructor to `Axiom` inductive in Axioms.lean
- Updated axiom count from 41 to 42 (Layer 5 uniformity: 4 -> 5)
- Fixed all exhaustive pattern matches in Soundness.lean (6 blocks), SoundnessLemmas.lean (4 blocks), and Substitution.lean (1 block)
- Added soundness proof `discrete_box_necessity_valid` and swap-validity proofs

### Phase 2: Prove Soundness (COMPLETED)
- Merged into Phase 1 since the proof is trivial: box quantifies over histories at the same time t, and U(T,bot) depends only on D's order structure

### Phase 3: Derive MCS Consequence (COMPLETED)
- Proved `mcs_mixed_case_absurd`: the mixed-case hypotheses lead to False
- Derivation chain: axiom -> contrapositive -> necessitation -> K-distribution -> MCS closure
- S5 negative introspection provides box(neg(box(U(T,bot)))) from neg(box(U(T,bot)))
- This derives box(F'T) which contradicts neg(box(F'T))

### Phase 4: Eliminate Sorry (COMPLETED)
- Replaced `sorry` in `dd_countermodel_chronicle_mixed_sorry` with `False.elim (mcs_mixed_case_absurd ...)`

### Phase 5: Verification and Documentation (COMPLETED)
- Full `lake build` passes (1648 jobs)
- `mcs_mixed_case_absurd` verified sorry-free via `lean_verify`
- `dd_countermodel_chronicle_mixed_sorry` verified sorry-free via `lean_verify`
- Updated ROADMAP.md, Completeness.lean docstrings, Axioms.lean doc header

## Verification Results

| Check | Result |
|-------|--------|
| `lake build` | Pass (1648 jobs) |
| sorry count (modified files) | 0 |
| vacuous definitions | 0 |
| new Lean axiom declarations | 0 |
| `mcs_mixed_case_absurd` axioms | {propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound} |
| `dd_countermodel_chronicle_mixed_sorry` axioms | {propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound} |
| Plan compliance | Passed |

## Files Modified

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- new axiom constructor, updated doc counts
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- new case in axiom substitution
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness proof + 5 match block updates
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- 4 match block updates (swap + local validity)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- mcs_mixed_case_absurd + sorry elimination
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- updated docstrings
- `specs/ROADMAP.md` -- updated sorry counts, axiom count, uniformity section

## Plan Deviations

- Phase 1: Axiom predicates (frameClass, isBase, isDenseCompatible, isDiscreteCompatible) use wildcard matches that already return correct values for the new constructor -- no explicit updates needed
- Phase 1: DenseSoundness.lean and DiscreteSoundness.lean do not exist -- skipped
- Phase 1: Derivation.lean isDenseCompatible/isDiscreteCompatible use wildcard matches -- skipped
- Phase 2: Merged entirely into Phase 1 since the soundness proof was trivial (5 lines)
- Phase 3: Used the direct False approach (mcs_mixed_case_absurd) rather than the disjunction approach (mcs_box_dense_or_discrete)
- Phase 4: No restructuring of bx_completeness needed -- the existing call to dd_countermodel_chronicle_mixed_sorry works since it now uses False.elim internally
