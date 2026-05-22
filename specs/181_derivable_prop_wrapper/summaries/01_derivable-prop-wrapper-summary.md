# Implementation Summary: Derivable Prop-Valued Wrapper

- **Task**: 181 - derivable_prop_wrapper
- **Status**: Implemented
- **Plan**: plans/01_derivable-prop-wrapper.md
- **Session**: sess_1779468897_2cf3b1

## Changes

### New File: `Theories/Bimodal/ProofSystem/Derivable.lean`

Created ~165-line file containing:

1. **Core definition**: `def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)`
2. **Coercion**: `Derivable.ofTree` -- any `DerivationTree` witnesses `Derivable`
3. **7 constructor-mirroring lemmas**:
   - `Derivable.ax` -- axiom rule (`@[aesop safe apply, simp]`)
   - `Derivable.assume` -- assumption rule (`@[aesop safe apply, simp]`)
   - `Derivable.mp` -- modus ponens (`@[aesop unsafe 50% apply]`)
   - `Derivable.weaken` -- weakening (`@[aesop safe apply]`)
   - `Derivable.nec` -- modal necessitation (`@[aesop safe apply]`)
   - `Derivable.temp_nec` -- temporal necessitation (`@[aesop safe apply]`)
   - `Derivable.temp_dual` -- temporal duality (`@[aesop safe apply]`)
4. **Notation**: `G |-! p` and `|-! p` for Prop-valued derivability
5. **Consistent bridge**: Documented as doc comment (circular import prevents theorem in this file; verified via `lean_run_code` that `Consistent G <-> -Derivable G Formula.bot := Iff.rfl` holds)
6. **Test examples**: Aesop on assumptions, axiom application, modus ponens chain, weakening

### Modified File: `Theories/Bimodal/ProofSystem.lean`

Added `import Bimodal.ProofSystem.Derivable` to the aggregator.

## Verification

- `lake build Bimodal.ProofSystem.Derivable` -- passes (no errors, no warnings)
- `lake build` -- only pre-existing errors in `ExpressivenessGeneral.lean` (unrelated)
- Zero sorries in modified files
- Zero vacuous definitions
- Zero new axioms
- All 9 plan goals found in Theories/
- Consistent bridge verified via standalone snippet

## Plan Deviations

1. **Bridge lemma (altered)**: `consistent_iff_not_derivable_bot` placed as doc comment instead of formal theorem due to circular import (MaximalConsistent imports ProofSystem). Verified the definitional equality holds when both modules are imported together.
2. **Aesop test example (altered)**: Plan proposed `aesop` closing an axiom goal, but aesop cannot synthesize `Axiom` instances without additional rules on the `Axiom` inductive. Replaced with assumption-based aesop test (which works) plus explicit axiom application test.
3. **Weaken signature (altered)**: Research code used `G <= D` but `List Formula` has no `LE` instance; changed to `G ⊆ D` which matches `DerivationTree.weakening`.
