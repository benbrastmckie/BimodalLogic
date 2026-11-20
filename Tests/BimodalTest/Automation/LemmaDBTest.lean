/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.Commands

/-!
# LemmaDB Tests

Tests for the `@[tmLemma]` attribute database and the `tryLemmaMatch`
backward-chaining strategy in `modal_search`.

Organized in three groups:
1. **Label-count smoke check**: the attribute enumerates the expected declarations.
2. **Migration regression**: every goal formerly closed by the static
   `tryDerivedMatch` list (26 theorems) still closes via `modal_search`.
3. **Chaining tests** (Phase 3): goals only provable by recursing through
   lemma premises, plus the weakening fallback and a negative test.

NOTE: These tests live in a dedicated file (not `TacticsTest.lean`, which has
pre-existing errors from the frame-class generalization). Build gate:
`lake build BimodalTest.Automation.LemmaDBTest`.
-/

namespace BimodalTest.Automation.LemmaDBTest

open Lean
open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Automation

/-!
## Group 1: Label-count smoke check

Phase 1 tags exactly the 26 theorems from the former static list in
`tryDerivedMatch`. This check fails the build if the count drifts
unexpectedly (update deliberately when expanding the database).
-/

-- The database starts from the 26 former static-list theorems (Phase 1) and
-- grows with Phase 4's expanded tagging (currently 35). We assert a lower
-- bound so migration coverage is guaranteed without pinning the exact total
-- (tagging more theorems must never silently drop below the migration set).
#eval show CoreM Unit from do
  let names ← Lean.labelled `tmLemma
  unless names.size ≥ 26 do
    throwError "expected ≥ 26 @[tmLemma] declarations, found {names.size}:\n{names}"

/-!
## Group 2: Migration regression

Every goal formerly closed by the static `tryDerivedMatch` list must still
close after the switch to the `@[tmLemma]` attribute database. One test per
former list entry, exercising each theorem's empty-context statement via
`modal_search`. If any of these fails, the migration invariant is broken.
-/

-- Tier 1: Propositional combinators

-- identity: A → A
example (p : Formula) : ⊢ p.imp p := by modal_search

-- doubleNegation: ¬¬φ → φ
example (p : Formula) : ⊢ p.neg.neg.imp p := by modal_search

-- impNegImp: A → (¬A → B)
example (p q : Formula) : ⊢ p.imp (p.neg.imp q) := by modal_search

-- negImp / impOfNeg: ¬A → (A → B)
example (p q : Formula) : ⊢ p.neg.imp (p.imp q) := by modal_search

-- lceImp: (A ∧ B) → A
noncomputable example (p q : Formula) : ⊢ (p.and q).imp p := by modal_search

-- rceImp: (A ∧ B) → B
noncomputable example (p q : Formula) : ⊢ (p.and q).imp q := by modal_search

-- contraposeImp: (A → B) → (¬B → ¬A)
example (p q : Formula) : ⊢ (p.imp q).imp (q.neg.imp p.neg) := by modal_search

-- pairing: A → (B → (A ∧ B))
example (p q : Formula) : ⊢ p.imp (q.imp (p.and q)) := by modal_search

-- notNotIntro: A → ¬¬A
example (p : Formula) : ⊢ p.imp p.neg.neg := by modal_search

-- bCombinator: (B→C) → ((A→B) → (A→C))
example (p q r : Formula) : ⊢ (q.imp r).imp ((p.imp q).imp (p.imp r)) := by modal_search

-- theoremFlip: (A→(B→C)) → (B→(A→C))
example (p q r : Formula) : ⊢ (p.imp (q.imp r)).imp (q.imp (p.imp r)) := by modal_search

-- theoremApp1: A → ((A→B) → B)
example (p q : Formula) : ⊢ p.imp ((p.imp q).imp q) := by modal_search

-- Tier 2: Modal and temporal derived theorems

-- temporalKDistDerived: G(φ→ψ) → (Gφ→Gψ)
noncomputable example (p q : Formula) :
    ⊢ (p.imp q).allFuture.imp (p.allFuture.imp q.allFuture) := by modal_search

-- temporal4Derived: Gφ → GGφ
noncomputable example (p : Formula) : ⊢ p.allFuture.imp p.allFuture.allFuture := by modal_search

-- hDistribution: H(φ→ψ) → (Hφ→Hψ)
noncomputable example (p q : Formula) :
    ⊢ (p.imp q).allPast.imp (p.allPast.imp q.allPast) := by modal_search

-- hTransitivity: Hφ → HHφ
noncomputable example (p : Formula) : ⊢ p.allPast.imp p.allPast.allPast := by modal_search

-- tBoxToDiamond: □A → ◇A
example (p : Formula) : ⊢ p.box.imp p.diamond := by modal_search

-- kDistDiamond: □(A→B) → (◇A → ◇B)
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.diamond.imp q.diamond) := by modal_search

-- diamond4: ◇◇φ → ◇φ
example (p : Formula) : ⊢ p.diamond.diamond.imp p.diamond := by modal_search

-- modal5: ◇φ → □◇φ
example (p : Formula) : ⊢ p.diamond.imp p.diamond.box := by modal_search

-- boxToFuture: □φ → Gφ
example (p : Formula) : ⊢ p.box.imp p.allFuture := by modal_search

-- boxToPast: □φ → Hφ
example (p : Formula) : ⊢ p.box.imp p.allPast := by modal_search

-- formulaOrComm: (A ∨ B) → (B ∨ A)
noncomputable example (p q : Formula) : ⊢ (p.or q).imp (q.or p) := by modal_search

-- biImp: (A→B) → ((B→A) → ((A→B) ∧ (B→A)))
example (p q : Formula) :
    ⊢ (p.imp q).imp ((q.imp p).imp ((p.imp q).and (q.imp p))) := by modal_search

-- classicalMerge: (P→Q) → ((¬P→Q) → Q)
noncomputable example (p q : Formula) : ⊢ (p.imp q).imp ((p.neg.imp q).imp q) := by modal_search

-- temporalFutureDerived: □φ → G□φ
example (p : Formula) : ⊢ p.box.imp p.box.allFuture := by modal_search

/-!
## Group 3: New backward-chaining capability (Phase 3)

These goals were NOT closable by the old static `tryDerivedMatch` (which
required `apply` to leave zero subgoals and never recursed or weakened).

- **(c) Weakening fallback**: a closed lemma `⊢[fc] φ` applies under a
  non-empty context via `DerivationTree.weakening`, recursing into the
  empty-context premise. This exercises the new recursion machinery.
- **(d) Depth-exhaustion / non-derivability**: unprovable goals fail (and
  terminate — the weakening recursion cannot loop) rather than hang. Tested
  with `fail_if_success` so a correct failure keeps the build green.

**Not tested**: chaining through a free-middle inference rule like
`impTrans` — see the note at `Combinators.impTrans`. The greedy,
backtrack-free search cannot select the undetermined middle term, so such
rules are intentionally left untagged. Determined-premise recursion (the
weakening fallback below) is the demonstrated new capability.
-/

-- (c) identity under a non-empty context — only closes via weakening fallback
example (X Y : Formula) : [Y] ⊢ X.imp X := by modal_search 6

-- (c) boxToFuture under a non-empty context — weakening + direct lemma
example (X Y : Formula) : [Y] ⊢ X.box.imp X.allFuture := by modal_search 6

-- (c) weakening fallback recursing through modus-ponens under context
example (X Y : Formula) : [Y] ⊢ X.diamond.imp X.diamond.box := by modal_search 6

-- (d) an underivable bare atom fails (and terminates) at empty context
example : True := by
  fail_if_success (have : ⊢ (Formula.atomS "p") := by modal_search 3)
  trivial

-- (d) an underivable goal under a non-empty context fails AND terminates —
-- confirms the weakening fallback does not loop on unprovable goals
example : True := by
  fail_if_success
    (have : [Formula.atomS "q"] ⊢ (Formula.atomS "p") := by modal_search 4)
  trivial

/-!
## Group 4: visitLimit abort (Phase 4)

`SearchConfig.visitLimit` bounds total node visits via an `IO.Ref` counter.
With a zero budget the search aborts immediately even on a provable goal;
with an adequate budget the same goal closes. This proves the counter is a
real abort, not a no-op.
-/

-- visitLimit := 0 aborts before visiting any node — even a trivial axiom goal
example : True := by
  fail_if_success
    (have : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by
      modal_search (depth := 10) (visitLimit := 0))
  trivial

-- the same goal closes with an adequate budget
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by
  modal_search (depth := 10) (visitLimit := 1000)

/-!
## Group 5: expanded tagging spot-check (Phase 4)

A few of the newly tagged premise-free theorems, closing directly via the
`@[tmLemma]` database.
-/

-- em: A ∨ ¬A
noncomputable example (p : Formula) : ⊢ p.or p.neg := by modal_search

-- peirceAxiom: ((φ→ψ)→φ)→φ
example (p q : Formula) : ⊢ ((p.imp q).imp p).imp p := by modal_search

-- boxToPresent: □φ → φ
example (p : Formula) : ⊢ p.box.imp p := by modal_search

-- mbDiamond: φ → ◇φ.box  (i.e. modal B via diamond)
example (p : Formula) : ⊢ p.imp p.diamond.box := by modal_search

/-!
## Group 6: `FormalSystem/Tactic/Meta.lean`'s `MetaM` helpers

The first coverage of `FormalSystem/Tactic/Meta.lean`. It is covered here rather than in
`TacticsTest.lean` because this file already runs a metaprogramming probe, and because its own
header records that such probes were moved out of `TacticsTest.lean` deliberately.

**A `MetaM` helper's failure is a runtime failure of the elaborator, never a compile error**, so
`#check` alone proves nothing about behaviour: these helpers can be broken while the whole project
builds clean. Hence the two executed `#eval` blocks below — one positive, one negative — rather
than signature pins alone.

`buildContextExpr` is covered the same way, by an invoked `#eval` probe rather than a signature
pin. A `#check` fixes only the declaration's type, which is `List Expr → MetaM Expr` whatever the
body does; an `AppBuilder` arity mistake inside that body type-checks fine and throws only when
the function is actually run. So the probe below applies it to the empty list and to a two-element
list, runs `Meta.check` on each resulting `Expr`, confirms the empty case really is a `Context`,
and pins both against `Meta.mkListLit`, which builds the list expression this helper is supposed to
build. The three `modal_search` examples closing this section are the tactic-level counterpart:
`buildContextExpr`'s only consumers are `tryModalK` and `tryTemporalK`, so a box-headed and an
`allFuture`-headed goal are what exercise it through the elaborator rather than directly.
-/

section MetaHelperProbes

#check @extractDerivationGoal
#check @formulaHead
#check @lemmaConclusionHead
#check @isNilContext
#check @buildContextExpr

-- Positive probe: elaborate a real `DerivationTree` goal type and check that each helper reads
-- the component it is supposed to read off it.
#eval show Elab.Term.TermElabM Unit from do
  let stx ← `(DerivationTree FrameClass.Base (([] : FormalSystem.Syntax.Context))
      ((Formula.atomS "p").imp (Formula.atomS "p")))
  let goalType ← Elab.Term.elabTerm stx none
  Elab.Term.synthesizeSyntheticMVarsNoPostponing
  let goalType ← instantiateMVars goalType
  match ← extractDerivationGoal goalType with
  | none => throwError "extractDerivationGoal failed to recognise {goalType}"
  | some (_, ctx, formula) =>
    unless isNilContext ctx do
      throwError "isNilContext rejected the literal empty context {ctx}"
    unless formulaHead formula == some ``Formula.imp do
      throwError "formulaHead read {formulaHead formula}, expected Formula.imp"
    let head ← lemmaConclusionHead ``FormalSystem.Theorems.ModalS5.tBoxToDiamond
    unless head == some ``Formula.imp do
      throwError "lemmaConclusionHead read {head}, expected Formula.imp"

-- Negative probe: both recognisers must reject a type that is not a derivability goal. A
-- recogniser that accepted everything would pass the positive probe above.
#eval show MetaM Unit from do
  let notAGoal := mkConst ``Nat
  unless (← extractDerivationGoal notAGoal).isNone do
    throwError "extractDerivationGoal accepted a non-derivability type"
  if isNilContext notAGoal then
    throwError "isNilContext accepted a non-list expression"

-- Invoked probe for `buildContextExpr`: a `#check` cannot distinguish a working body from one
-- that throws on every input, so apply it to both the empty and a non-empty list, type-check the
-- results, and pin them against `Meta.mkListLit`.
#eval show MetaM Unit from do
  let p := mkApp (mkConst ``Formula.atomS) (mkStrLit "p")
  let q := mkApp (mkConst ``Formula.atomS) (mkStrLit "q")
  let nil ← buildContextExpr []
  Meta.check nil
  unless (← Meta.isDefEq (← Meta.inferType nil) (mkConst ``Context)) do
    throwError "buildContextExpr [] : {← Meta.inferType nil}, expected Context"
  unless nil == (← Meta.mkListLit (mkConst ``Formula) []) do
    throwError "buildContextExpr [] built {nil}"
  let two ← buildContextExpr [p, q]
  Meta.check two
  unless two == (← Meta.mkListLit (mkConst ``Formula) [p, q]) do
    throwError "buildContextExpr [p, q] built {two}"

-- Acceptance coverage through the tactic: `buildContextExpr`'s only consumers are `tryModalK`
-- and `tryTemporalK`, reached from a box-headed and an `allFuture`-headed goal respectively.

-- box-headed, empty context
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).box := by modal_search

-- box-headed, non-empty all-boxed context: exercises the map-box/cons path, not just nil
example : [(Formula.atomS "p").box] ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).box := by
  modal_search

-- allFuture-headed: covers tryTemporalK, the second consumer
example : ⊢ ((Formula.atomS "p").imp (Formula.atomS "p")).allFuture := by modal_search

end MetaHelperProbes

end BimodalTest.Automation.LemmaDBTest
