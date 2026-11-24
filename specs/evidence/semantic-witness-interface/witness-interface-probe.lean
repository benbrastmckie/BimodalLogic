/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.StarLanguage.StarNonValidities

/-!
# Two witness interfaces, compared on the initial clients

A measurement probe for the witness-interface decision of `records/semantic-proof-mode.md`. The
two elaborators below are throwaway: they close a goal completely or fail, cover only the clauses
the four clients use (no Until, Since or store), and return no goals. Neither is the evaluator.

Each client is proved four ways over one set of valuation facts, which is therefore counted apart
from clause recursion: the library's proof, the clause lemmas alone, the clause-ordered pattern
and the labelled entries. `refute_sentDet` has no clause to recurse through, so its lemmas-only
version is its reference proof. The last section prints the token counts and term sizes.
-/

open Lean Elab Tactic Meta
open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.StarLanguage FormalSystem.Semantics

namespace SemanticWitness

/-! ## Directional clause lemmas, generic over the clause classes -/

section Lemmas
variable {L : Type} [TruthEnv L] {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
  {t : F.Duration} {e : TruthEnv.Env L F} {A B : L}

theorem atom_true [AtomClause L] {p : Atom} (h : M.valuation (τ.state t) p) :
    TruthEnv.T M τ t e (AtomClause.atom p : L) := (AtomClause.atom_clause M τ t e p).mpr h
theorem atom_false [AtomClause L] {p : Atom} (h : ¬ M.valuation (τ.state t) p) :
    ¬ TruthEnv.T M τ t e (AtomClause.atom p : L) := mt (AtomClause.atom_clause M τ t e p).mp h
theorem imp_true [ImpClause L] (h : TruthEnv.T M τ t e A → TruthEnv.T M τ t e B) :
    TruthEnv.T M τ t e (ImpClause.imp A B) := (ImpClause.imp_clause M τ t e A B).mpr h
theorem imp_false [ImpClause L] (hA : TruthEnv.T M τ t e A) (hB : ¬ TruthEnv.T M τ t e B) :
    ¬ TruthEnv.T M τ t e (ImpClause.imp A B) := fun h =>
  hB ((ImpClause.imp_clause M τ t e A B).mp h hA)
theorem box_true [BoxClause L] (h : ∀ σ, TruthEnv.T M σ t e A) :
    TruthEnv.T M τ t e (BoxClause.box A) := (BoxClause.box_clause M τ t e A).mpr h
theorem box_false [BoxClause L] (σ) (h : ¬ TruthEnv.T M σ t e A) :
    ¬ TruthEnv.T M τ t e (BoxClause.box A) := fun k => h ((BoxClause.box_clause M τ t e A).mp k σ)
theorem stab_true [StabClause L] (h : ∀ σ, τ.state t = σ.state t → TruthEnv.T M σ t e A) :
    TruthEnv.T M τ t e (StabClause.stab A) := (StabClause.stab_clause M τ t e A).mpr h
theorem stab_false [StabClause L] (σ) (hs : τ.state t = σ.state t) (h : ¬ TruthEnv.T M σ t e A) :
    ¬ TruthEnv.T M τ t e (StabClause.stab A) := fun k =>
  h ((StabClause.stab_clause M τ t e A).mp k σ hs)
variable [BotClause L] [ImpClause L]
theorem future_true [UntlClause L] (h : ∀ s, t < s → TruthEnv.T M τ s e A) :
    TruthEnv.T M τ t e (TruthClauses.allFuture A) := (TruthClauses.allFuture_iff M τ t e A).mpr h
theorem future_false [UntlClause L] (s) (hs : t < s) (h : ¬ TruthEnv.T M τ s e A) :
    ¬ TruthEnv.T M τ t e (TruthClauses.allFuture A) := fun k =>
  h ((TruthClauses.allFuture_iff M τ t e A).mp k s hs)
theorem past_true [SnceClause L] (s) (hs : s < t) (h : TruthEnv.T M τ s e A) :
    TruthEnv.T M τ t e (TruthClauses.somePast A) :=
  (TruthClauses.somePast_iff M τ t e A).mpr ⟨s, hs, h⟩
theorem past_false [SnceClause L] (h : ∀ s, s < t → ¬ TruthEnv.T M τ s e A) :
    ¬ TruthEnv.T M τ t e (TruthClauses.somePast A) := fun k =>
  let ⟨s, hs, hA⟩ := (TruthClauses.somePast_iff M τ t e A).mp k; h s hs hA
end Lemmas

/-! Recall has no clause class; its rules are L⋆'s own. -/
section Recall
variable {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
  {e : TruthEnv.Env StarFormula F} {A : StarFormula} {i : ℕ}
theorem recall_true (h : TruthEnv.T M τ (e i) e A) : TruthEnv.T M τ t e (.timeRecall i A) := h
theorem recall_false (h : ¬ TruthEnv.T M τ (e i) e A) : ¬ TruthEnv.T M τ t e (.timeRecall i A) := h
end Recall

/-! ## A clause recursion shared by both interfaces -/

/-- What a clause needs from the script. -/
inductive Need | bind (n : Nat) | give (n : Nat) | close | branch | pass
  deriving BEq

structure Rule where
  label : Name
  need : Need
  thm : Name

/-- Rules by operator and polarity. -/
def rules : List (Name × Bool × Rule) := [
  (`atom, true, ⟨`atom, .close, ``atom_true⟩), (`atom, false, ⟨`atom, .close, ``atom_false⟩),
  (`imp, true, ⟨`imp, .bind 1, ``imp_true⟩), (`imp, false, ⟨`imp, .branch, ``imp_false⟩),
  (`box, true, ⟨`box, .bind 1, ``box_true⟩), (`box, false, ⟨`box, .give 1, ``box_false⟩),
  (`stab, true, ⟨`stab, .bind 2, ``stab_true⟩), (`stab, false, ⟨`stab, .give 2, ``stab_false⟩),
  (`allFuture, true, ⟨`future, .bind 2, ``future_true⟩),
  (`allFuture, false, ⟨`future, .give 2, ``future_false⟩),
  (`somePast, true, ⟨`past, .give 2, ``past_true⟩),
  (`somePast, false, ⟨`past, .bind 2, ``past_false⟩),
  (`timeRecall, true, ⟨`recall, .pass, ``recall_true⟩),
  (`timeRecall, false, ⟨`recall, .pass, ``recall_false⟩)]

/-- Restate a native truth goal over `TruthEnv.T` and find its clause. -/
def clause (goal : MVarId) : TacticM (MVarId × Rule) := goal.withContext do
  let type ← whnfR (← instantiateMVars (← goal.getType))
  let (negated, body) := match type.not? with | some b => (true, b) | none => (false, type)
  let args := body.getAppArgs
  let (truth, formula) ← match body.getAppFn.constName? with
    | some ``PlusTruthAt => pure (← mkAppOptM ``TruthEnv.T #[mkConst ``PlusFormula, none, args[0]!,
        args[1]!, args[2]!, args[3]!, mkConst ``PUnit.unit [1], args[4]!], args[4]!)
    | some ``StarTruthAt => pure (← mkAppOptM ``TruthEnv.T #[mkConst ``StarFormula, none, args[0]!,
        args[1]!, args[2]!, args[3]!, args[4]!, args[5]!], args[5]!)
    | some ``TruthEnv.T => pure (body, args[args.size - 1]!)
    | _ => throwError "no truth goal here:{indentExpr type}"
  let goal ← goal.change (if negated then mkNot truth else truth)
  let mut formula := formula
  for _ in [:8] do
    if let some name := formula.getAppFn.constName? then
      if let some (_, _, rule) := rules.find? fun (op, pos, _) =>
          op == name.componentsRev.head! && pos == !negated then
        return (goal, rule)
    let some next ← unfoldDefinition? formula | break
    formula := next.headBeta
  throwError "no clause rule for{indentExpr formula}"

/-- Components of an anonymous-constructor item, or the single term. -/
def components (item : Term) : Array Term :=
  match item with
  | `(⟨$parts,*⟩) => parts.getElems
  | item => #[item]

def describe (rule : Rule) : String := match rule.need with
  | .bind n => s!"`{rule.label}` binds {n} name(s) here"
  | .give n => s!"`{rule.label}` needs {n} witness component(s) here"
  | .close => s!"`{rule.label}` needs its valuation evidence here"
  | _ => s!"`{rule.label}`"

/-- Apply a clause lemma with the supplied item; return the remaining goals. -/
def step (goal : MVarId) (rule : Rule) (item : Option Term) : TacticM (List MVarId) := do
  let lem := mkIdent rule.thm
  let parts := item.map components |>.getD #[]
  let tac ← match rule.need with
    | .close => `(tactic| exact $lem $(item.get!))
    | .branch => `(tactic| refine $lem ?_ ?_)
    | .pass => `(tactic| refine $lem ?_)
    | .give n =>
      unless parts.size == n do throwErrorAt item.get! "{describe rule}"
      `(tactic| refine $lem $parts* ?_)
    | .bind n =>
      unless parts.size == n do throwErrorAt item.get! "{describe rule}"
      let names ← parts.mapM fun part => match part with
        | `($x:ident) => pure x
        | _ => throwErrorAt part "{describe rule}"
      `(tactic| refine $lem fun $names* => ?_)
  evalTacticAt tac goal

/-! ## Interface one: a clause-ordered pattern -/

/-- `seval_pat [i, …]`: items are consumed in the order the recursion meets clauses. A branching
clause consumes the rest of the list, which must be one list for each branch. -/
syntax (name := sevalPat) "seval_pat" ppSpace term:max : tactic

partial def runPat (ref : Syntax) (goal : MVarId) (items : List Term) : TacticM Unit := do
  let (goal, rule) ← clause goal
  match rule.need with
  | .pass => for g in ← step goal rule none do runPat ref g items
  | .branch =>
    let [left, right] := items
      | throwErrorAt ref
          "`{rule.label}` branches here: expected two lists, found {items.length} item(s)"
    let [g, g'] ← step goal rule none | throwError "two goals expected"
    for (g, side) in [(g, left), (g', right)] do
      match side with
      | `([$sub,*]) => runPat side g sub.getElems.toList
      | _ => throwErrorAt side "`{rule.label}` branches here: expected a list"
  | need =>
    let item :: rest := items | throwErrorAt ref "pattern ends early: {describe rule}"
    let goals ← step goal rule item
    if need == .close then
      if let extra :: _ := rest then throwErrorAt extra "pattern continues after the last clause"
    for g in goals do runPat ref g rest

elab_rules : tactic
  | `(tactic| seval_pat $pattern) => do
    let `([$items,*]) := pattern | throwErrorAt pattern "expected a list"
    let goal ← getMainGoal
    runPat pattern goal items.getElems.toList
    replaceMainGoal []

/-! ## Interface two: labelled entries -/

syntax sevalEntry := ident " := " term
/-- `seval_lab [label := i, …]`: an entry is looked up by its operator and branch, so entries may
be in any order. `prem` and `concl` name the branches of a refuted implication; a repeated operator
is numbered. -/
syntax (name := sevalLab) "seval_lab" ppSpace "[" sevalEntry,* "]" : tactic

abbrev Entries := Array (Name × Term × Syntax)

partial def runLab (ref : Syntax) (entries : Entries) (path : Name) (seen : List Name)
    (goal : MVarId) : StateT (List Name) TacticM Unit := do
  let (goal, rule) ← clause goal
  let n := (seen.filter (· == rule.label)).length
  let base := if n == 0 then rule.label else rule.label.appendAfter (toString (n + 1))
  let label := path ++ base
  match rule.need with
  | .pass => for g in ← step goal rule none do runLab ref entries path (rule.label :: seen) g
  | .branch =>
    let [g, g'] ← step goal rule none | throwError "two goals expected"
    runLab ref entries (path ++ `prem) [] g
    runLab ref entries (path ++ `concl) [] g'
  | _ =>
    let some (_, item, _) := entries.find? (·.1 == label)
      | throwErrorAt ref "no entry `{label}`: {describe rule}"
    modify (label :: ·)
    for g in ← step goal rule (some item) do
      runLab ref entries path (rule.label :: seen) g

elab_rules : tactic
  | `(tactic| seval_lab%$tk [$es,*]) => do
    let entries : Entries ← es.getElems.mapM fun entry => match entry with
      | `(sevalEntry| $label:ident := $item) => pure (label.getId, item, label.raw)
      | _ => throwUnsupportedSyntax
    let goal ← getMainGoal
    let ((), used) ← (runLab tk entries .anonymous [] goal).run []
    for (label, _, ref) in entries do
      unless used.contains label do throwErrorAt ref "unused entry `{label}`"
    replaceMainGoal []

end SemanticWitness

namespace SemanticWitness
open PlusFormula PlusTruth

/-! ## The three-clause client `refute_stab_allFuture_past`: `⊡GPp → G⊡Pp` -/

/-- State agreement of the refuting history at time `1`. -/
theorem agree_one : (natHist fun _ => 0).state (1 : ℤ) =
    (natHist fun s => if s = 1 then 0 else 1).state (1 : ℤ) := by
  change (0 : ℕ) = (if (1 : ℤ) = 1 then 0 else 1); simp

/-- The refuting history fails every atom before time `1`. -/
theorem atom_fails {s : ℤ} (hs : s < 1) (p : Atom) :
    ¬ natModel.valuation ((natHist fun s => if s = 1 then 0 else 1).state s) p := by
  intro h
  have h : (if (s : ℤ) = 1 then (0 : ℕ) else 1) = 0 := h
  rw [if_neg (ne_of_lt hs)] at h
  exact one_ne_zero h

/-- The proof in the library with its two valuation obligations shared. -/
theorem sap_reference (p : Atom) :
    ¬ PlusValid (.imp (.stab (allFuture (somePast (.atom p))))
        (allFuture (.stab (somePast (.atom p))))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0
      (.stab (allFuture (somePast (.atom p)))) := by
    intro σ hs
    rw [allFuture_iff]
    intro y hy
    rw [somePast_iff]
    exact ⟨0, hy, hs.symm⟩
  have hB := hv hA
  rw [allFuture_iff] at hB
  have hC := hB (1 : ℤ) (one_pos : (0 : ℤ) < 1) (natHist fun s => if s = 1 then 0 else 1) agree_one
  rw [somePast_iff] at hC
  obtain ⟨s, hs1, hat⟩ := hC
  exact atom_fails hs1 p hat

/-- Clause lemmas alone. -/
theorem sap_control (p : Atom) :
    ¬ PlusValid (.imp (.stab (allFuture (somePast (.atom p))))
        (allFuture (.stab (somePast (.atom p))))) := by
  refine fun h => absurd (h.apply NF natModel (natHist fun _ => 0) 0) ?_
  exact imp_false (L := PlusFormula) (e := PUnit.unit)
    (stab_true fun _ hs => future_true fun _ hy => past_true 0 hy (atom_true hs.symm))
    (future_false 1 one_pos (stab_false (natHist fun s => if s = 1 then 0 else 1) agree_one
      (past_false fun _ hs => atom_false (atom_fails hs p))))

/-- The clause-ordered pattern. -/
theorem sap_pattern (p : Atom) :
    ¬ PlusValid (.imp (.stab (allFuture (somePast (.atom p))))
        (allFuture (.stab (somePast (.atom p))))) := by
  refine fun h => absurd (h.apply NF natModel (natHist fun _ => 0) 0) ?_
  seval_pat [[⟨_σ, hs⟩, ⟨_y, hy⟩, ⟨0, hy⟩, hs.symm],
    [⟨1, one_pos⟩, ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩, ⟨_s, hs⟩,
      atom_fails hs p]]

/-- Labelled entries. -/
theorem sap_labelled (p : Atom) :
    ¬ PlusValid (.imp (.stab (allFuture (somePast (.atom p))))
        (allFuture (.stab (somePast (.atom p))))) := by
  refine fun h => absurd (h.apply NF natModel (natHist fun _ => 0) 0) ?_
  seval_lab [prem.stab := ⟨_σ, hs⟩, prem.future := ⟨_y, hy⟩, prem.past := ⟨0, hy⟩,
    prem.atom := hs.symm, concl.future := ⟨1, one_pos⟩,
    concl.stab := ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩,
    concl.past := ⟨_s, hs⟩, concl.atom := atom_fails hs p]

end SemanticWitness

namespace SemanticWitness
open PlusFormula PlusTruth

/-! ## `refute_allFuture_stab`: `G⊡p → ⊡Gp` -/

theorem agree_zero : (natHist fun _ => 0).state (0 : ℤ) =
    (natHist fun s => if s = 1 then 1 else 0).state (0 : ℤ) := by
  change (0 : ℕ) = (if (0 : ℤ) = 1 then 1 else 0); simp

theorem atom_fails_one (p : Atom) :
    ¬ natModel.valuation ((natHist fun s => if s = 1 then 1 else 0).state (1 : ℤ)) p := by
  intro h
  have h : (if (1 : ℤ) = 1 then (1 : ℕ) else 0) = 0 := h
  simp at h

theorem afs_reference (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (allFuture (.stab (.atom p))) := by
    rw [allFuture_iff]
    intro y _ ρ hs
    exact hs.symm
  have hB := hv hA (natHist fun s => if s = 1 then 1 else 0) agree_zero
  rw [allFuture_iff] at hB
  exact atom_fails_one p (hB (1 : ℤ) (one_pos : (0 : ℤ) < 1))

theorem afs_control (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  refine fun h => absurd (h.apply NF natModel (natHist fun _ => 0) 0) ?_
  exact imp_false (L := PlusFormula) (e := PUnit.unit)
    (future_true fun _ _ => stab_true fun _ hs => atom_true hs.symm)
    (stab_false (natHist fun s => if s = 1 then 1 else 0) agree_zero
      (future_false 1 one_pos (atom_false (atom_fails_one p))))

theorem afs_pattern (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  refine fun h => absurd (h.apply NF natModel (natHist fun _ => 0) 0) ?_
  seval_pat [[⟨_y, _hy⟩, ⟨_σ, hs⟩, hs.symm],
    [⟨natHist fun s => if s = 1 then 1 else 0, agree_zero⟩, ⟨1, one_pos⟩, atom_fails_one p]]

theorem afs_labelled (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  refine fun h => absurd (h.apply NF natModel (natHist fun _ => 0) 0) ?_
  seval_lab [prem.future := ⟨_y, _hy⟩, prem.stab := ⟨_σ, hs⟩, prem.atom := hs.symm,
    concl.stab := ⟨natHist fun s => if s = 1 then 1 else 0, agree_zero⟩,
    concl.future := ⟨1, one_pos⟩, concl.atom := atom_fails_one p]

/-! ## `refute_modal_future` in L⋆: `□(↓¹p → p) → □G(↓¹p → p)` -/

theorem atom_holds (p : Atom) :
    natModel.valuation ((natHist fun s => if s ≤ 0 then 0 else 1).state (0 : ℤ)) p := by
  change (if (0 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0; simp

theorem atom_lost (p : Atom) :
    ¬ natModel.valuation ((natHist fun s => if s ≤ 0 then 0 else 1).state (1 : ℤ)) p := by
  intro h
  have h : (if (1 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0 := h
  simp at h

theorem mf_reference (p : Atom) :
    ¬ NF.StarValidOn
      ((StarFormula.box (mfWitness p)).imp
        (StarFormula.box (StarFormula.allFuture (mfWitness p)))) := by
  intro h
  have hv := h natModel (natHist fun _ => 0) (0 : ℤ) (fun _ => (0 : ℤ))
  have hA : StarTruthAt natModel (natHist fun _ => 0) (0 : ℤ) (fun _ => (0 : ℤ))
      (StarFormula.box (mfWitness p)) := by
    intro σ hrec
    exact hrec
  have hB := hv hA (natHist fun s => if s ≤ 0 then 0 else 1)
  rw [StarTruth.allFuture_iff] at hB
  exact atom_lost p (hB (1 : ℤ) (one_pos : (0 : ℤ) < 1) (atom_holds p))

theorem mf_control (p : Atom) :
    ¬ NF.StarValidOn
      ((StarFormula.box (mfWitness p)).imp
        (StarFormula.box (StarFormula.allFuture (mfWitness p)))) := by
  refine fun h => absurd (h natModel (natHist fun _ => 0) 0 fun _ => 0) ?_
  exact imp_false (L := StarFormula) (box_true fun _ => imp_true id)
    (box_false (natHist fun s => if s ≤ 0 then 0 else 1) (future_false 1 one_pos
      (imp_false (recall_true (atom_true (atom_holds p))) (atom_false (atom_lost p)))))

theorem mf_pattern (p : Atom) :
    ¬ NF.StarValidOn
      ((StarFormula.box (mfWitness p)).imp
        (StarFormula.box (StarFormula.allFuture (mfWitness p)))) := by
  refine fun h => absurd (h natModel (natHist fun _ => 0) 0 fun _ => 0) ?_
  seval_pat [[⟨_σ⟩, ⟨hrec⟩, hrec], [⟨natHist fun s => if s ≤ 0 then 0 else 1⟩, ⟨1, one_pos⟩,
    [atom_holds p], [atom_lost p]]]

theorem mf_labelled (p : Atom) :
    ¬ NF.StarValidOn
      ((StarFormula.box (mfWitness p)).imp
        (StarFormula.box (StarFormula.allFuture (mfWitness p)))) := by
  refine fun h => absurd (h natModel (natHist fun _ => 0) 0 fun _ => 0) ?_
  seval_lab [prem.box := ⟨_σ⟩, prem.imp := ⟨hrec⟩, prem.atom := hrec,
    concl.box := ⟨natHist fun s => if s ≤ 0 then 0 else 1⟩, concl.future := ⟨1, one_pos⟩,
    concl.prem.atom := atom_holds p, concl.concl.atom := atom_lost p]

end SemanticWitness

namespace SemanticWitness
open PlusFormula

/-! ## `refute_sentDet`: an existing witness theorem and two atom obligations -/

theorem sd_fails (p : Atom) :
    ¬ natModel.valuation ((natHist fun s => if s ≤ 0 then 0 else 1).state (1 : ℤ)) p := by
  intro h
  have h : (if (1 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0 := h
  simp at h
theorem sd_agree : (natHist fun _ => 0).state (0 : ℤ) =
    (natHist fun s => if s ≤ 0 then 0 else 1).state (0 : ℤ) := by
  change (0 : ℕ) = (if (0 : ℤ) ≤ 0 then 0 else 1); simp

theorem sd_reference (p : Atom) :
    ¬ NF.StarValidOn (sentDet (ofPlus (PlusFormula.atom p))) := by
  refine not_starValidOn_sentDet natModel (natHist fun _ => 0)
    (0 : ℤ) (1 : ℤ) (one_pos : (0 : ℤ) < 1)
    (natHist fun _ => 0) (natHist fun s => if s ≤ 0 then 0 else 1) rfl sd_agree ?_ ?_
  · exact fun _ => (rfl : (0 : ℕ) = 0)
  · exact fun _ => sd_fails p

theorem sd_pattern (p : Atom) :
    ¬ NF.StarValidOn (sentDet (ofPlus (PlusFormula.atom p))) := by
  refine not_starValidOn_sentDet natModel (natHist fun _ => 0)
    (0 : ℤ) (1 : ℤ) (one_pos : (0 : ℤ) < 1)
    (natHist fun _ => 0) (natHist fun s => if s ≤ 0 then 0 else 1) rfl sd_agree ?_ ?_
  · intro _; seval_pat [(rfl : (0 : ℕ) = 0)]
  · intro _; seval_pat [sd_fails p]

theorem sd_labelled (p : Atom) :
    ¬ NF.StarValidOn (sentDet (ofPlus (PlusFormula.atom p))) := by
  refine not_starValidOn_sentDet natModel (natHist fun _ => 0)
    (0 : ℤ) (1 : ℤ) (one_pos : (0 : ℤ) < 1)
    (natHist fun _ => 0) (natHist fun s => if s ≤ 0 then 0 else 1) rfl sd_agree ?_ ?_
  · intro _; seval_lab [atom := (rfl : (0 : ℕ) = 0)]
  · intro _; seval_lab [atom := sd_fails p]

end SemanticWitness

/-! ## Where faults are reported

The same fault in the three-clause client under each interface. Positions are relative to the
`#guard_msgs` line. -/

namespace SemanticWitness
open PlusFormula PlusTruth

/-- The refutation both interfaces are asked for. -/
abbrev SapGoal (p : Atom) : Prop :=
  ¬ PlusTruthAt natModel (natHist fun _ => 0) (0 : ℤ)
    (.imp (.stab (allFuture (somePast (.atom p)))) (allFuture (.stab (somePast (.atom p)))))

-- A missing item. The pattern reports the next item; the labelled form names the missing entry.
/--
@ +2:25...26
error: `future` binds 2 name(s) here
-/
#guard_msgs (error, positions := true) in
example (p : Atom) : SapGoal p := by
  seval_pat [[⟨_σ, hs⟩, ⟨0, hy⟩, hs.symm],
    [⟨1, one_pos⟩, ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩, ⟨_s, hs⟩,
      atom_fails hs p]]

/--
@ +2:2...11
error: no entry `prem.future`: `future` binds 2 name(s) here
-/
#guard_msgs (error, positions := true) in
example (p : Atom) : SapGoal p := by
  seval_lab [prem.stab := ⟨_σ, hs⟩, prem.past := ⟨0, hy⟩, prem.atom := hs.symm,
    concl.future := ⟨1, one_pos⟩,
    concl.stab := ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩,
    concl.past := ⟨_s, hs⟩, concl.atom := atom_fails hs p]

-- An extra item.
/--
@ +2:52...54
error: pattern continues after the last clause
-/
#guard_msgs (error, positions := true) in
example (p : Atom) : SapGoal p := by
  seval_pat [[⟨_σ, hs⟩, ⟨_y, hy⟩, ⟨0, hy⟩, hs.symm, hs],
    [⟨1, one_pos⟩, ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩, ⟨_s, hs⟩,
      atom_fails hs p]]

/--
@ +3:26...34
error: unused entry `prem.box`
-/
#guard_msgs (error, positions := true) in
example (p : Atom) : SapGoal p := by
  seval_lab [prem.stab := ⟨_σ, hs⟩, prem.future := ⟨_y, hy⟩, prem.past := ⟨0, hy⟩,
    prem.atom := hs.symm, prem.box := hs, concl.future := ⟨1, one_pos⟩,
    concl.stab := ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩,
    concl.past := ⟨_s, hs⟩, concl.atom := atom_fails hs p]

-- Two binding items of equal length exchanged. The pattern binds the wrong names and reports at
-- a later use; the labelled form is indifferent to order.
/--
@ +2:38...40
error: Application type mismatch: The argument
  hy
has type
  (natHist fun x ↦ 0).state 0 = _y.state 0
but is expected to have type
  0 < _σ
in the application
  past_true 0 hy
-/
#guard_msgs (error, positions := true) in
example (p : Atom) : SapGoal p := by
  seval_pat [[⟨_y, hy⟩, ⟨_σ, hs⟩, ⟨0, hy⟩, hy.symm],
    [⟨1, one_pos⟩, ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩, ⟨_s, hs⟩,
      atom_fails hs p]]

#guard_msgs in
example (p : Atom) : SapGoal p := by
  seval_lab [prem.future := ⟨_y, hy⟩, prem.stab := ⟨_σ, hs⟩, prem.past := ⟨0, hy⟩,
    prem.atom := hs.symm, concl.future := ⟨1, one_pos⟩,
    concl.stab := ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩,
    concl.past := ⟨_s, hs⟩, concl.atom := atom_fails hs p]

-- A wrong witness with valid evidence of its own is reported at the evidence depending on it.
/--
@ +3:61...70
error: Application type mismatch: The argument
  agree_one
has type
  (natHist fun x ↦ 0).state 1 = (natHist fun s ↦ if s = 1 then 0 else 1).state 1
but is expected to have type
  (natHist fun x ↦ 0).state 2 = (natHist fun s ↦ if s = 1 then 0 else 1).state 2
in the application
  stab_false (natHist fun s ↦ if s = 1 then 0 else 1) agree_one
---
@ +4:17...19
error: Application type mismatch: The argument
  hs
has type
  _s < 2
but is expected to have type
  _s < 1
in the application
  atom_fails hs
-/
#guard_msgs (error, positions := true) in
example (p : Atom) : SapGoal p := by
  seval_pat [[⟨_σ, hs⟩, ⟨_y, hy⟩, ⟨0, hy⟩, hs.symm],
    [⟨2, two_pos⟩, ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩, ⟨_s, hs⟩,
      atom_fails hs p]]

end SemanticWitness

/-! ## Counts

Source tokens are the leaves of the syntax tree Lean's parser gives the proof, after `:=`. Term
size is the node count of the elaborated proof with sharing ignored. Run from the repository
root. -/

namespace SemanticWitness
open Lean Parser

/-- Leaves of a syntax tree. -/
partial def leaves : Syntax → Nat
  | .node _ _ args => args.foldl (fun n s => n + leaves s) 0
  | .atom _ v => if v.isEmpty then 0 else 1
  | .ident .. => 1
  | .missing => 0

/-- The first subtree of a kind. -/
partial def findKind (k : Name) (s : Syntax) : Option Syntax :=
  if s.getKind == k then some s else s.getArgs.findSome? (findKind k)

/-- Nodes of a term, without sharing. -/
partial def nodes : Expr → Nat
  | .app f a => nodes f + nodes a + 1
  | .lam _ t b _ | .forallE _ t b _ => nodes t + nodes b + 1
  | .letE _ t v b _ => nodes t + nodes v + nodes b + 1
  | .mdata _ e => nodes e
  | .proj _ _ e => nodes e + 1
  | _ => 1

#eval show CoreM Unit from do
  let path : System.FilePath :=
    "specs/evidence/semantic-witness-interface/witness-interface-probe.lean"
  let context := mkInputContext (← IO.FS.readFile path) path.toString
  let (_, start, start') ← parseHeader context
  let mut state := start
  let mut messages := start'
  let mut rows := #[]
  repeat
    let (command, state', messages') :=
      parseCommand context { env := ← getEnv, options := {} } state messages
    state := state'
    messages := messages'
    if isTerminalCommand command then break
    let some name := (findKind ``Command.declId command).map (·[0].getId) | continue
    let some value := findKind ``Command.declValSimple command | continue
    let some info := (← getEnv).find? (`SemanticWitness ++ name) | continue
    let size := (info.value? (allowOpaque := true)).map nodes |>.getD 0
    if ["reference", "control", "pattern", "labelled"].any
        fun kind => name.toString.endsWith kind then
      rows := rows.push s!"{name}: {leaves value - 1} tokens, {size} nodes"
    else if [`rules, `clause, `components, `describe, `step, `runPat, `runLab].contains name then
      rows := rows.push s!"{name}: {leaves value - 1} tokens"
  logInfo ("\n".intercalate rows.toList)

end SemanticWitness
