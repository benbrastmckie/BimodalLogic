# Implementation Summary: Task #198

- **Task**: 198 - Prove frame-class indicator forcing in MCS
- **Status**: Implemented
- **Plan**: plans/01_frame-class-indicator-forcing.md

## Changes

### Phase 1: Add dense_indicator Axiom and Soundness Proof
- Added `dense_indicator` constructor to `Axiom` inductive in `Axioms.lean`: `Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg`
- Set `minFrameClass` for `dense_indicator` to `.Dense`
- Proved soundness: `dense_indicator_valid` in `Soundness.lean` (valid on dense orders because `DenselyOrdered` prevents empty open intervals)
- Proved swap-validity in `SoundnessLemmas.lean` (swap of `neg(U(T,bot))` is `neg(S(T,bot))`, equally valid on dense orders)
- Updated all exhaustive matches on `Axiom` across 6 files:
  - `Soundness.lean` (4 match blocks)
  - `SoundnessLemmas.lean` (6 match blocks)
  - `ExtDerivation.lean` (embedAxiom + minFrameClass)
  - `Lifting.lean` (3 conversion functions)
  - `Substitution.lean` (axiom_subst)
  - `ConservativeExtension/Substitution.lean` (substAxiom)
- Updated axiom count docstrings from 41 to 42

### Phase 2: Prove completeness_dense Sorry
- Eliminated the sorry at the non-dense branch of `completeness_dense`
- Proof: `dense_indicator` axiom gives `neg(U(T,bot))` as a Dense theorem; `necessitation` gives `box(neg(U(T,bot)))`; `theorem_in_mcs` places it in M; contradiction with `h_not_box_dense : neg(box(neg(U(T,bot)))) in M` via `set_consistent_not_both`
- 4 lines of proof code

### Phase 3: Prove completeness_discrete Sorry
- Eliminated the sorry at the dense-case branch of `completeness_discrete`
- Proof: derived `next_top` (= `U(T,bot)`) in the Discrete proof system via a 10-step derivation chain:
  1. `identity bot` -> T
  2. `serial_future` + MP -> F(T)
  3. `prior_UZ(T)` + MP -> U(T, neg(T))
  4. Deduction theorem: `neg(T) -> bot`
  5. `temporal_necessitation` -> G(neg(T) -> bot)
  6. `left_mono_until_G` + MP -> U(T, neg(T)) -> U(T, bot)
  7. MP -> U(T, bot) = next_top
- Then `theorem_in_mcs` places `next_top` in M
- Modal T (`box(neg(next_top)) -> neg(next_top)`) extracts `neg(next_top)` from `h_box_dense`
- Contradiction via `set_consistent_not_both`

### Phase 4: Full Build Verification
- `lake build` passes with 0 errors (1649 jobs)
- `lean_verify completeness_dense`: axioms = `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` (no `sorryAx`)
- `lean_verify completeness_discrete`: inherits `sorryAx` from Chronicle pipeline (pre-existing, not from our sorry site)
- No new sorries introduced in any modified file
- Updated docstrings to reflect resolved sorry status

## Plan Deviations
- None (implementation followed plan)

## Verification Results
- sorry_count in modified files: 0
- vacuous_count: 0
- axiom_count: 0 (no new `axiom` declarations)
- build_passed: true
- compliance_check: passed

## Files Modified
- `Theories/Bimodal/ProofSystem/Axioms.lean` — added `dense_indicator` constructor + updated minFrameClass + docstrings
- `Theories/Bimodal/Metalogic/Soundness.lean` — added `dense_indicator_valid` + updated 4 match blocks
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — added swap-validity proof + updated 6 match blocks
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — eliminated 2 sorries + updated docstrings
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` — added ExtAxiom.dense_indicator + embedAxiom case
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` — added 3 lifting cases
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` — added substAxiom case
- `Theories/Bimodal/ProofSystem/Substitution.lean` — added axiom_subst case
