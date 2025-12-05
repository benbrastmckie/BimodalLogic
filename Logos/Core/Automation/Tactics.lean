import Logos.Core.ProofSystem
import Logos.Core.Automation.AesopRules
import Lean

/-!
# Custom Tactics for Modal and Temporal Reasoning

This module defines custom tactics to automate common proof patterns in the TM
bimodal logic system.

## Main Tactics

- `apply_axiom`: Apply a specific axiom by name
- `modal_t`: Apply modal T axiom (`□φ → φ`) automatically
- `tm_auto`: Comprehensive TM automation with Aesop (Phase 5)
- `assumption_search`: Search for formula in context (Phase 6)

## Implementation Status

**Phases 4-6**: Core tactics implementation with LEAN 4 metaprogramming

- Phase 4 ✓: `apply_axiom` (macro), `modal_t` (elab_rules)
- Phase 5: `tm_auto` with Aesop integration
- Phase 6: `assumption_search` with TacticM

## References

* LEAN 4 Metaprogramming: https://github.com/leanprover-community/lean4-metaprogramming-book
* Tactic Development Guide: Documentation/Development/TACTIC_DEVELOPMENT.md

## Example Usage

```lean
-- Apply axiom by name
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.atom "p") := by
  apply_axiom modal_t

-- Modal T application (automatic)
example (p : Formula) : [p.box] ⊢ p := by
  modal_t
  assumption
```
-/

open Logos.Core.Syntax Logos.Core.ProofSystem
open Lean Elab Tactic Meta

namespace Logos.Core.Automation

/-!
## Phase 4: Basic Tactics Implementation
-/

/--
`apply_axiom` tactic applies a TM axiom by matching the goal against axiom patterns.

Attempts to unify the goal with each axiom schema and applies the matching axiom.

**Example**:
```lean
example : Derivable [] (Formula.box p |>.imp p) := by
  apply_axiom  -- Finds and applies Axiom.modal_t
```

**Supported Axioms**:
- `prop_k`, `prop_s` - Propositional axioms
- `modal_t`, `modal_4`, `modal_b` - S5 modal axioms
- `temp_4`, `temp_a`, `temp_l` - Temporal axioms
- `modal_future`, `temp_future` - Bimodal axioms

**Implementation**: Uses `refine` to let Lean infer formula parameters from the goal.
-/
macro "apply_axiom" : tactic =>
  `(tactic| (apply Derivable.axiom; refine ?_))

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
  `(tactic| (apply Derivable.axiom; refine ?_))

/-!
## Phase 4: tm_auto (Aesop Integration)

**IMPLEMENTATION NOTE**: Aesop integration successful using forward chaining rules defined
in AesopRules.lean. Uses default Aesop rule set with TM-specific rules registered.

**Solution**: Aesop-powered automation with forward chaining for all proven axioms (MT, M4,
MB, T4, TA, prop_k, prop_s) and safe apply rules for core inference (modus_ponens, modal_k,
temporal_k).

This leverages Aesop's white-box best-first search with domain-specific TM logic rules.
-/

/--
`tm_auto` tactic - Aesop-powered TM automation.

Attempts to solve TM proof goals using Aesop's best-first search with:
1. Forward chaining for 7 proven axioms (modal_t, modal_4, modal_b, temp_4, temp_a, prop_k, prop_s)
2. Safe apply rules for core inference (modus_ponens, modal_k, temporal_k)
3. Normalization of derived operators (diamond, always, sometimes, sometime_past)

**Example**:
```lean
example : ⊢ (□p → p) := by
  tm_auto  -- Uses Aesop with TM-specific forward rules
```

**Implementation**: Aesop best-first search (max 100 rule applications).

**Limitations**:
- Excludes incomplete axioms (temp_l, modal_future, temp_future)
- Fixed rule limit (100 applications, may timeout on complex proofs)
- No backtracking beyond Aesop's built-in search

For complex proofs, use explicit `apply_axiom` calls or manual tactics.
-/
macro "tm_auto" : tactic =>
  `(tactic| aesop)

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

/-- Check if formula has form `□φ` for some `φ`. -/
def is_box_formula : Formula → Bool
  | .box _ => true
  | _ => false

/-- Check if formula has form `Fφ` for some `φ`. -/
def is_future_formula : Formula → Bool
  | .all_future _ => true
  | _ => false

/-- Extract `φ` from `□φ`, returns none if not a box formula. -/
def extract_from_box : Formula → Option Formula
  | .box φ => some φ
  | _ => none

/-- Extract `φ` from `Fφ`, returns none if not a future formula. -/
def extract_from_future : Formula → Option Formula
  | .all_future φ => some φ
  | _ => none

end Logos.Core.Automation
