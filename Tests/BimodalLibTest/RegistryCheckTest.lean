/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Registry.Complete
import BimodalLibTest.Fixtures.UnregisteredDerivation

/-!
# Tests of the registration check

The check is aimed at the fixture module, which declares one closed derivation that nothing
registers. It must fail and name the derivation. The derivation is then registered here, and
the same check must pass.
-/

/-! ### The check fails on an unregistered closed derivation -/

/--
info: modules under BimodalLibTest.Fixtures, excluding BimodalLibTest.Fixtures.Excluded: 1 closed derivations, 0 of them registered; 0 context-form derivations and 0 rules, which are not registered
---
error: 1 closed derivation(s) under BimodalLibTest.Fixtures have no registry row; add a `register_theorem` line for each:
  BimodalLibTest.Fixtures.unregisteredIdentity
-/
#guard_msgs in
assert_registry_complete BimodalLibTest.Fixtures excluding BimodalLibTest.Fixtures.Excluded

/-! ### It passes once the derivation is registered -/

register_theorem BimodalLibTest.Fixtures.unregisteredIdentity

/--
info: modules under BimodalLibTest.Fixtures, excluding BimodalLibTest.Fixtures.Excluded: 1 closed derivations, 1 of them registered; 0 context-form derivations and 0 rules, which are not registered
-/
#guard_msgs in
assert_registry_complete BimodalLibTest.Fixtures excluding BimodalLibTest.Fixtures.Excluded

/-! ### A declaration that is not a closed derivation is refused -/

/--
error: register_theorem: FormalSystem.Theorems.Combinators.impTrans is not a closed derivation: it takes a premise of type
  ⊢[fc] (v 0).imp (v 1)
-/
#guard_msgs in
register_theorem FormalSystem.Theorems.Combinators.impTrans

/--
error: register_theorem: Nat.add_comm is not a derivation: its type ends in
  n + m = m + n
-/
#guard_msgs in
register_theorem Nat.add_comm
