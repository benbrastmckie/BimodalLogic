/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Aesop

/-!
# TMLogic Aesop rule set

Declares the `TMLogic` Aesop rule set that `FormalSystem/Automation/AesopRules.lean` registers
its TM axiom, forward-chaining and normalization rules into.

**Why this is a separate module.** An Aesop rule set is not visible in the compilation unit that
declares it — measured here, not assumed: `declare_aesop_rule_sets [X]` followed in the same file
by `@[aesop safe apply (rule_sets := [X])]` fails with `no such rule set: 'X'`, and Aesop's own
error text says "Declared rule sets are not visible in the current file; they only become visible
once you import the declaring file." Mathlib takes the same route, putting each rule set in its
own `Init.lean`-style module (`Mathlib/Tactic/Bound/Init.lean`,
`Mathlib/CategoryTheory/Category/Init.lean`). This module must not acquire any other content.

**Why the rules are not in the default set.** `AesopRules.lean`'s rules build `DerivationTree`
terms, and Aesop's proof reconstruction over `DerivationTree` is what made `tm_auto` abandon
Aesop in the first place. Left in Aesop's *default* rule set they were picked up by every plain
`aesop` call in every consumer of `FormalSystem.Automation`, whether or not that call had
anything to do with TM derivations. Reaching them now takes an explicit
`aesop (rule_sets := [TMLogic])`.
-/

declare_aesop_rule_sets [TMLogic]
