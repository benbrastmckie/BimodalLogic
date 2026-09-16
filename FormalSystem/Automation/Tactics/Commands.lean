/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.Meta
import FormalSystem.Automation.Tactics.Search
import FormalSystem.Automation.Tactics.Deduction

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open Lean Elab Tactic Meta

/-!
### Phase 1.6: Configuration Structure
-/

/--
Configuration options for proof search tactics.

Controls search depth and the node-visit limit. Both fields are read by
`runModalSearch`; there are no other knobs. Earlier revisions also declared five
strategy-weight fields (`axiomWeight`, `assumptionWeight`, `mpWeight`,
`modalKWeight`, `temporalKWeight`) and two presets built from them
(`SearchConfig.temporal`, `SearchConfig.propositional`), but `searchProof` never
read a weight, so the presets were behaviourally identical to the default and
have been removed. The separate, genuinely-read weight structure lives in
`FormalSystem.Automation.ProofSearch.Core` and is untouched by this note.
-/
structure SearchConfig where
  /-- Maximum search depth (default: 10) -/
  depth : Nat := 10
  /-- Maximum nodes to visit before giving up (default: 1000) -/
  visitLimit : Nat := 1000
  deriving Repr, Inhabited

/-- Default configuration for modal_search -/
def SearchConfig.default : SearchConfig := {}

/-!
### Main Tactic Definitions
-/

/--
`modal_search` - Bounded proof search for TM formulas.

Attempts to solve derivability goals (`Γ ⊢ φ`) using bounded depth-first search
with axiom matching and assumption lookup.

**Syntax**:
```lean
modal_search                   -- Default depth 10
modal_search 5                 -- Custom depth 5
modal_search (depth := 20)     -- Named depth parameter
modal_search (depth := 20) (visitLimit := 2000)  -- Multiple named parameters
```

**Named Parameters**:
- `depth`: Maximum search depth (default: 10)
- `visitLimit`: Maximum nodes to visit before aborting (default: 1000). Enforced
  via an `IO.Ref` counter threaded through `searchProof`; bounds total search
  cost independently of `depth` so pathological goals terminate promptly.

`depth` and `visitLimit` are the only parameters; any other name is ignored.

**Example**:
```lean
-- Prove modal T axiom
example (p : Formula) : ⊢ (p.box).imp p := by
  modal_search

-- Prove with custom depth
example (p : Formula) : ⊢ (p.box).imp (p.box.box) := by
  modal_search 3

-- Prove with named parameters
example (p : Formula) : ⊢ (p.box).imp p := by
  modal_search (depth := 5)
```

**Algorithm**:
1. Extract goal type and validate it's a `DerivationTree Γ φ` goal
2. Try axiom matching against 42 of the 45 axiom schemata (`tryAxiomMatch`'s list
   omits the three Layer-9 Reynolds Dedekind axioms)
3. Try assumption matching if formula is in context
4. Try modus ponens decomposition
5. Try modal K rule (reduce □Γ ⊢ □φ to Γ ⊢ φ)
6. Try temporal K rule (reduce FΓ ⊢ Fφ to Γ ⊢ φ)

**Implementation Note**: This tactic works at the meta-level in TacticM,
avoiding the Axiom Prop vs Type issue by constructing proof
terms directly via `mkAppM` rather than returning proof witnesses.
-/

-- Simple syntax: just a number
syntax "modal_search" (num)? : tactic

-- Named parameters syntax
/-- A named search parameter, written `(name := value)`, as accepted by the
`modal_search` tactic. -/
syntax modalSearchParam := "(" ident " := " num ")"

/-- `modal_search (depth := n) (visitLimit := m) …` — the named-parameter form of
`modal_search`, overriding individual fields of the default `SearchConfig`. -/
syntax "modal_search" modalSearchParam* : tactic

/-- Parse named parameter value from TSyntax -/
def parseSearchParam (stx : TSyntax `FormalSystem.Automation.modalSearchParam) : TacticM
    (String × Nat) := do
  match stx with
  | `(modalSearchParam| ( $name:ident := $val:num )) =>
    return (name.getId.toString, val.getNat)
  | _ => throwError "invalid parameter syntax"

/-- Apply named parameters to config -/
def applyParams (cfg : SearchConfig) (params : List (String × Nat)) : SearchConfig :=
  params.foldl (fun c (name, val) =>
    match name with
    | "depth" => { c with depth := val }
    | "visitLimit" => { c with visitLimit := val }
    | _ => c  -- Ignore unknown parameters
  ) cfg

/-- Run modal_search with given configuration -/
def runModalSearch (cfg : SearchConfig) : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- Validate goal type
  let some (_fc, _ctx, _formula) ← extractDerivationGoal goalType
    | throwError "modal_search: goal must be a derivability relation `Γ ⊢ φ`, got {goalType}"

  -- Attempt recursive proof search. `visitLimit` bounds total node visits via
  -- an `IO.Ref` counter threaded through `searchProof`.
  let counter ← IO.mkRef cfg.visitLimit
  let found ← searchProof counter goal cfg.depth
  if !found then
    throwError
        "modal_search: no proof found within depth {cfg.depth} (visitLimit {cfg.visitLimit}) for \
            goal {goalType}"

elab_rules : tactic
  | `(tactic| modal_search $[$d]?) => do
    let depth := d.map (·.getNat) |>.getD 10
    runModalSearch { SearchConfig.default with depth := depth }

elab_rules : tactic
  | `(tactic| modal_search $params:modalSearchParam*) => do
    let paramList ← params.toList.mapM parseSearchParam
    let cfg := applyParams SearchConfig.default paramList
    runModalSearch cfg

/-!
### Tests

The `modal_search` syntax, configuration and axiom/derived-theorem coverage tests live in
`Tests/BimodalTest/Automation/TacticsTest.lean` (section `CommandsTests`).
-/

end FormalSystem.Automation
