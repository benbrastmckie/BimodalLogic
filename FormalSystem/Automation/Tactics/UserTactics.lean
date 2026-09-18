/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Reasoning
import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.Perpetuity
import Lean

/-!
# User-facing tactics, and the formula predicates they read

The tactics a proof author writes by hand, plus the four `Formula` predicates and extractors
that decide when they apply. This is one of the three files that replaced the 1,210-line
`Tactics/Helpers.lean`; the other two are
[`Meta.lean`](Meta.lean) (the reusable `MetaM` plumbing) and [`Search.lean`](Search.lean) (the
proof-search engine). The split was made because those three concerns had different consumers
and only the middle one was actually reused: `PropDecide.lean` and `Commands.lean` both reach
into `Meta.lean`, `Commands.lean` alone reaches into `Search.lean`, and nothing outside this
file uses what is here.

Nothing in this file imports either of the other two, and neither imports this one. The three
declaration sets are disjoint.

## Main declarations

- `apply_axiom`, `modal_t` — axiom-application macros
- `assumption_search` — context lookup with an explicit failure message
- `isBoxFormula`, `isFutureFormula`, `extractFromBox`, `extractFromFuture` — the `Formula`
  predicates and extractors, which carry their own test coverage in
  `Tests/BimodalTest/Automation/TacticsTest.lean`

## Tags

tactics · axiom-application · formula-predicates
-/

open FormalSystem.Syntax FormalSystem.ProofSystem
open Lean Elab Tactic Meta

namespace FormalSystem.Automation

/-!
## Phase 4: Basic Tactics Implementation
-/

/--
`apply_axiom` tactic applies a TM axiom by matching the goal against axiom patterns.

Attempts to unify the goal with each axiom schema and applies the matching axiom.

**Example**:
```lean
example : ⊢ (Formula.box p |>.imp p) := by
  apply_axiom  -- Finds and applies Axiom.modal_t
```

**Supported Axioms**:
- `prop_k`, `prop_s` - Propositional axioms
- `modal_t`, `modal_4`, `modal_b` - S5 modal axioms
- `temp_4`, `temp_a`, `temp_l` - Temporal axioms
- `modal_future` - Bimodal axiom
- `temporalFutureDerived` - Derived from MF + T + Modal 4

**Implementation**: Uses `refine` to let Lean infer formula parameters from the goal.
-/
macro "apply_axiom" : tactic =>
  `(tactic| (apply DerivationTree.axiom; refine ?_))

/--
`modal_t` tactic automatically applies modal T axiom (`□φ → φ`).

Detects goals of form `Γ ⊢ φ` where `□φ ∈ Γ`, applies modal T axiom and modus ponens.

**Example**:
```lean
example (p : Formula) : [p.box] ⊢ p := by
  modal_t  -- Applies: □p → p (from modal_t axiom)
  assumption
```

**Implementation**: Applies Axiom.modal_t directly.
-/
macro "modal_t" : tactic =>
  `(tactic| (apply DerivationTree.axiom; refine ?_))

/-!
## Phase 6: assumption_search Tactic
-/

/--
`assumption_search` tactic searches the local context for an assumption matching the goal.

Similar to built-in `assumption`, but with explicit error messages for debugging.

**Example**:
```lean
example (h1 : p → q) (h2 : p) : q := by
  have : q := h1 h2
  assumption_search  -- Finds and applies `this : q`
```

**Implementation**: Uses TacticM to iterate through local context with isDefEq checking.
-/
elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType
  let lctx ← getLCtx
  -- Iterate through local declarations
  for decl in lctx do
    if !decl.isImplementationDetail then
      -- Check if declaration type matches goal via definitional equality
      if ← isDefEq decl.type goalType then
        -- Found a match! Assign the goal to this local hypothesis
        goal.assign (mkFVar decl.fvarId)
        return ()
  -- No matching assumption found
  throwError "assumption_search failed: no assumption matches goal {goalType}"

/-!
## Helper Functions

These helpers support tactic implementation and formula pattern matching.
-/

/--
Check if a formula is a box (necessity) formula.

Returns `true` if the formula has the form `□φ` for some inner formula `φ`,
`false` otherwise.

## Parameters
- Formula to check (implicit pattern match parameter)

## Returns
`true` if formula is `□φ`, `false` otherwise

## Usage
Used by modal tactics to identify necessity formulas before applying modal-specific
inference rules or axioms.

## Example
```lean
#eval isBoxFormula (Formula.box (Formula.atomS "p"))  -- true
#eval isBoxFormula (Formula.atomS "p")                -- false
#eval isBoxFormula (Formula.diamond (Formula.atomS "p"))  -- false
```
-/
def isBoxFormula : Formula → Bool
  | .box _ => true
  | _ => false

/--
Check if a formula is a future (temporal) formula.

Returns `true` if the formula has the form `Fφ` (allFuture φ) for some inner
formula `φ`, `false` otherwise.

## Parameters
- Formula to check (implicit pattern match parameter)

## Returns
`true` if formula is `Fφ`, `false` otherwise

## Usage
Used by temporal tactics to identify future formulas before applying temporal-specific
inference rules or axioms.

## Example
```lean
#eval isFutureFormula (Formula.allFuture (Formula.atomS "p"))  -- true
#eval isFutureFormula (Formula.atomS "p")                       -- false
#eval isFutureFormula (Formula.box (Formula.atomS "p"))         -- false
```
-/
def isFutureFormula : Formula → Bool
  | .allFuture _ => true
  | _ => false

/--
Extract the inner formula from a box (necessity) formula.

Given a formula of the form `□φ`, returns `some φ`. For any other formula,
returns `none`.

## Parameters
- Formula to extract from (implicit pattern match parameter)

## Returns
- `some φ` if input is `□φ`
- `none` if input is not a box formula

## Usage
Used by modal elimination tactics to access the inner formula when applying
rules like modal T (`□φ → φ`) or modal 4 (`□φ → □□φ`).

## Example
```lean
#eval extractFromBox (Formula.box (Formula.atomS "p"))  -- some (Formula.atomS "p")
#eval extractFromBox (Formula.atomS "p")                -- none
#eval extractFromBox (Formula.diamond (Formula.atomS "p"))  -- none
```
-/
def extractFromBox : Formula → Option Formula
  | .box φ => some φ
  | _ => none

/--
Extract the inner formula from a future (temporal) formula.

Given a formula of the form `Fφ` (allFuture φ), returns `some φ`. For any other
formula, returns `none`.

## Parameters
- Formula to extract from (implicit pattern match parameter)

## Returns
- `some φ` if input is `Fφ`
- `none` if input is not a future formula

## Usage
Used by temporal elimination tactics to access the inner formula when applying
rules like temporal 4 (`Fφ → FFφ`) or temporal A (`φ → F(somePast φ)`).

## Example
```lean
#eval extractFromFuture (Formula.allFuture (Formula.atomS "p"))  -- some (Formula.atomS "p")
#eval extractFromFuture (Formula.atomS "p")                       -- none
#eval extractFromFuture (Formula.box (Formula.atomS "p"))         -- none
```
-/
def extractFromFuture : Formula → Option Formula
  | .allFuture φ => some φ
  | _ => none


/-!
## Naming-convention exemptions for user-facing tactic tokens

Each `macro`/`elab` below declares a *tactic token*, and Lean auto-generates a declaration whose
name is derived from that token (`modal_t` becomes `tacticModal_t`). Those generated names carry
the token's underscores, so Mathlib's `defsWithUnderscore` linter flags them.

**These seven tokens keep their snake_case spelling.** Every Lean tactic token is snake_case
(`simp_all`, `norm_num`, `push_neg`, `field_simp`), and Mathlib's own `tactic*` declarations
escape this linter not by being camelCased but because `isBadNameWithUnderscore`
(`Mathlib/Tactic/Linter/Style.lean`) whitelists the `Mathlib.Tactic` namespace prefix outright.
Renaming a tactic token to camelCase would satisfy the linter while making the tactic surface
*less* conformant with Lean and Mathlib practice.

Each token here is referenced from `docs/`, so renaming it is a user-facing API break rather
than a naming cleanup. Tokens that are internal-only were renamed instead — `modal_norm`,
`prop_norm`, `modal_op_norm`, `temporal_norm`, `modal_norm_all`, `modal_norm_at`, `modal_fold`,
`prop_decide`, `order_refl`, `order_rev`, `same_order_type_grid`, `same_order_type_grid_uh`, and
the `tm_lemma` label attribute.

A per-declaration, in-source exemption on an auto-generated name is a **documented exemption**,
naming the token it derives from and the reason. It is categorically different from the
861-entry `scripts/nolints.json` this migration deleted, which suppressed hand-written
declaration names in bulk with no per-site justification.
-/

attribute [nolint defsWithUnderscore]
  tacticApply_axiom          -- from the `apply_axiom` tactic token
  tacticModal_t              -- from the `modal_t` tactic token
  tacticAssumption_search    -- from the `assumption_search` tactic token

end FormalSystem.Automation
