# Implementation Summary: Task #116 (Partial)

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Status**: [PARTIAL]
- **Phases**: 5 of 12 completed
- **Session**: sess_1779147423_788df8

## Changes Made

### Core Redefinition (Formula.lean)
- Removed `all_past` and `all_future` constructors from `Formula` inductive (8 to 6 constructors)
- Added `@[match_pattern] def some_future (phi) := untl phi top` (Burgess: F = U(phi, top))
- Added `@[match_pattern] def some_past (phi) := snce phi top` (Burgess: P = S(phi, top))
- Added `@[match_pattern] def all_future (phi) := (some_future phi.neg).neg` (Burgess: G = not F(not phi))
- Added `@[match_pattern] def all_past (phi) := (some_past phi.neg).neg` (Burgess: H = not P(not phi))
- Added canonical `Formula.top := bot.imp bot`
- Updated `beq_refl`, `eq_of_beq`, `swap_temporal`, `swap_temporal_involution`, `atoms`, `predFormulas` for 6 constructors
- Added swap_temporal lemmas: `swap_temporal_all_future`, `swap_temporal_all_past`, `swap_temporal_some_future`, `swap_temporal_some_past`, `swap_temporal_top`

### Semantics (Truth.lean)
- Removed `all_past`/`all_future` arms from `truth_at` (8 to 6 cases)
- Added bridge lemmas: `Truth.past_iff`, `Truth.future_iff`, `Truth.some_future_iff`, `Truth.some_past_iff`, `Truth.top_true`, `Truth.neg_iff`
- Bridge lemmas prove semantic equivalence: `truth_at(all_past phi) <-> forall s < t, truth_at(phi, s)`

### SubformulaClosure
- Updated `f_nesting_depth`, `p_nesting_depth` to match new `some_future`/`some_past` (untl/snce patterns)
- Updated `extractFutureInner`, `extractPastInner` for new patterns
- Sorry'd 8 deferralClosure proofs where `Formula.noConfusion` no longer discriminates (G/H are `imp` forms)

### Downstream Files Fixed (~15 files)
- Subformulas.lean, Validity.lean, GeneralizedNecessitation.lean, Perpetuity/Helpers.lean
- SignedFormula.lean, MCSProperties.lean, TemporalDerived.lean
- SuccessPatterns.lean, Quasimodel/SubformulaClosure.lean
- Pattern: moved `@[match_pattern]` arms before `.imp` in function definitions

## Remaining Work

### Failing Files (5 files, ~114 errors)
1. **SoundnessLemmas.lean** (~100 errors): truth_at expansion
2. **Table.lean** (2 errors): induction proof restructuring
3. **Bridge.lean** (3 errors): swap_temporal simp
4. **TemporalCoherence.lean**: truth_at expansion
5. **TemporalContent.lean**: truth_at expansion

### Fix Pattern
Replace `simp only [..., truth_at]` with `rw [Truth.past_iff]` / `rw [Truth.future_iff]` bridge lemma calls.

### Sorry Markers Introduced
- 8 in SubformulaClosure.lean (deferralClosure noConfusion proofs)
- 1 in SoundnessLemmas.lean (swap_axiom_ta_valid)
- These are all marked with FIX comments

## Plan Deviations
- Phase 2 deferred: temp_k_dist/temp_4 remain as axiom constructors (compatible with new defs)
- SubformulaClosure deferralClosure proofs sorry'd instead of fully reworked
- SoundnessLemmas.lean not fully updated (needs bridge lemma propagation)

## Key Insight
The `@[match_pattern]` attribute works for pattern matching in `match`/`def` expressions but NOT for `induction` tactic arms. This means:
- ~200 pattern-match arms survive unchanged (when reordered before `.imp`)
- ~200 induction proof arms must be removed (handled by the 6 real constructors)
- Proofs using `truth_at` unfolding need bridge lemmas instead of direct constructor matching

## Files Modified
- `Theories/Bimodal/Syntax/Formula.lean` (core change)
- `Theories/Bimodal/Syntax/Subformulas.lean`
- `Theories/Bimodal/Syntax/SubformulaClosure.lean`
- `Theories/Bimodal/Semantics/Truth.lean`
- `Theories/Bimodal/Semantics/Validity.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean` (unchanged, compiles)
- `Theories/Bimodal/Theorems/TemporalDerived.lean`
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`
- `Theories/Bimodal/Theorems/Perpetuity/Helpers.lean`
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (partial)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (partial)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean`
- `Theories/Bimodal/Automation/SuccessPatterns.lean`
