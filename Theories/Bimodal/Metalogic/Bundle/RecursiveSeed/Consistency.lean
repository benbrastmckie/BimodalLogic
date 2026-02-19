import Bimodal.Metalogic.Bundle.RecursiveSeed.Worklist

/-!
# RecursiveSeed Consistency Proofs

WorklistInvariant, processWorkItem_preserves_consistent, and buildSeedComplete_consistent.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
### Phase 4: Consistency Proofs

The worklist algorithm preserves consistency through processing.
We prove that processWorkItem and processWorklist preserve seed consistency.

**Key Insight**: The worklist algorithm only adds formulas that are:
1. The original formula itself (at the start)
2. Subformulas of formulas already in the seed
3. Derived from axioms (T, 4) applied to existing formulas

Since the original formula is consistent, all these derived formulas are also
consistent, and adding them preserves consistency.

**Approach**: We use a strengthened invariant that tracks:
- Seed consistency (existing `SeedConsistent`)
- Formula consistency of all formulas in the worklist

This is implemented using existing lemmas:
- `singleton_consistent_iff`: Singleton set consistency ↔ formula consistency
- `addFormula_seed_preserves_consistent`: Adding formula to seed preserves consistency
- `createNewFamily_preserves_seedConsistent`: Creating new family preserves consistency
- `createNewTime_preserves_seedConsistent`: Creating new time preserves consistency
-/

/--
A stronger worklist invariant: the seed is consistent AND all formulas
appearing in work items are consistent AND formulas are already in the seed.

The third condition (`∀ item ∈ state.worklist, item.formula ∈ state.seed.getFormulas item.famIdx item.timeIdx`)
ensures that when we process a work item, the formula is already in the seed at that position.
This makes h_compat trivial: insert phi entry.formulas = entry.formulas when phi is already there.
-/
def WorklistInvariant (state : WorklistState) : Prop :=
  SeedConsistent state.seed ∧
  SeedWellFormed state.seed ∧
  ∀ item ∈ state.worklist, FormulaConsistent item.formula ∧
    item.formula ∈ state.seed.getFormulas item.famIdx item.timeIdx

/--
Empty seed is consistent (trivially - no entries).
-/
theorem empty_seed_consistent' : SeedConsistent ModelSeed.empty := by
  intro entry he
  simp only [ModelSeed.empty, List.not_mem_nil] at he

/--
Subformula consistency: If Box psi is consistent, then psi is consistent.

This follows from the T axiom: Box psi -> psi. If psi were inconsistent,
we'd have psi ⊢ ⊥, which combined with Box psi ⊢ psi (from T axiom)
gives Box psi ⊢ ⊥ by cut, contradicting Box psi being consistent.

Proof uses: Axiom.modal_t, modus_ponens, and cut rule (derived via deduction).
-/
theorem box_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.box psi)) :
    FormulaConsistent psi := by
  -- T axiom gives us Box psi -> psi, so from Box psi we can derive psi
  -- If psi ⊢ ⊥, then combined with Box psi ⊢ psi, we get Box psi ⊢ ⊥
  intro h_incons
  apply h
  obtain ⟨d, _⟩ := h_incons
  have h_psi_bot : ⊢ psi.imp Formula.bot :=
    Bimodal.Metalogic.Core.deduction_theorem [] psi Formula.bot d
  have h_t : ⊢ (Formula.box psi).imp psi :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_t psi)
  have h_chain : ⊢ (Formula.box psi).imp Formula.bot :=
    Bimodal.Theorems.Combinators.imp_trans h_t h_psi_bot
  have d_box_bot : [Formula.box psi] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [Formula.box psi] _ _
      (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
      (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp))
  exact ⟨d_box_bot, trivial⟩

/--
Subformula consistency for G (all_future): If G psi is consistent, then psi is consistent.
This follows from the temporal T axiom (reflexivity): G psi -> psi.
-/
theorem all_future_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.all_future psi)) :
    FormulaConsistent psi := by
  intro h_incons
  apply h
  obtain ⟨d, _⟩ := h_incons
  have h_psi_bot : ⊢ psi.imp Formula.bot :=
    Bimodal.Metalogic.Core.deduction_theorem [] psi Formula.bot d
  have h_t : ⊢ (Formula.all_future psi).imp psi :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future psi)
  have h_chain : ⊢ (Formula.all_future psi).imp Formula.bot :=
    Bimodal.Theorems.Combinators.imp_trans h_t h_psi_bot
  have d_g_bot : [Formula.all_future psi] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [Formula.all_future psi] _ _
      (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
      (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp))
  exact ⟨d_g_bot, trivial⟩

/--
Subformula consistency for H (all_past): If H psi is consistent, then psi is consistent.
This follows from the temporal T axiom (reflexivity): H psi -> psi.
-/
theorem all_past_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.all_past psi)) :
    FormulaConsistent psi := by
  intro h_incons
  apply h
  obtain ⟨d, _⟩ := h_incons
  have h_psi_bot : ⊢ psi.imp Formula.bot :=
    Bimodal.Metalogic.Core.deduction_theorem [] psi Formula.bot d
  have h_t : ⊢ (Formula.all_past psi).imp psi :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past psi)
  have h_chain : ⊢ (Formula.all_past psi).imp Formula.bot :=
    Bimodal.Theorems.Combinators.imp_trans h_t h_psi_bot
  have d_h_bot : [Formula.all_past psi] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [Formula.all_past psi] _ _
      (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
      (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp))
  exact ⟨d_h_bot, trivial⟩

/--
If neg(Box psi) is consistent, then neg psi is consistent.

Proof sketch: If neg psi is inconsistent, then psi is a theorem.
By necessitation, Box psi is a theorem.
A theorem is consistent with anything, so neg(Box psi) would be inconsistent
(since neg(Box psi) + Box psi ⊢ ⊥).
-/
theorem neg_box_neg_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.neg (Formula.box psi))) :
    FormulaConsistent (Formula.neg psi) := by
  intro h_incons
  apply h
  obtain ⟨d, _⟩ := h_incons
  have h_neg_neg_psi : ⊢ psi.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] psi.neg Formula.bot d
  have h_dne : ⊢ psi.neg.neg.imp psi := Bimodal.Theorems.Propositional.double_negation psi
  have h_psi : ⊢ psi := Bimodal.ProofSystem.DerivationTree.modus_ponens [] psi.neg.neg psi h_dne h_neg_neg_psi
  have h_box_psi : ⊢ Formula.box psi := Bimodal.ProofSystem.DerivationTree.necessitation psi h_psi
  have d_neg_box_bot : [Formula.neg (Formula.box psi)] ⊢ Formula.bot :=
    derives_bot_from_phi_neg_phi
      (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_box_psi (List.nil_subset _))
      (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp))
  exact ⟨d_neg_box_bot, trivial⟩

/--
If neg(G psi) is consistent, then neg psi is consistent.
-/
theorem neg_future_neg_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.neg (Formula.all_future psi))) :
    FormulaConsistent (Formula.neg psi) := by
  intro h_incons
  apply h
  obtain ⟨d, _⟩ := h_incons
  have h_neg_neg_psi : ⊢ psi.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] psi.neg Formula.bot d
  have h_dne : ⊢ psi.neg.neg.imp psi := Bimodal.Theorems.Propositional.double_negation psi
  have h_psi : ⊢ psi := Bimodal.ProofSystem.DerivationTree.modus_ponens [] psi.neg.neg psi h_dne h_neg_neg_psi
  have h_g_psi : ⊢ Formula.all_future psi := Bimodal.ProofSystem.DerivationTree.temporal_necessitation psi h_psi
  have d_neg_g_bot : [Formula.neg (Formula.all_future psi)] ⊢ Formula.bot :=
    derives_bot_from_phi_neg_phi
      (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_g_psi (List.nil_subset _))
      (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp))
  exact ⟨d_neg_g_bot, trivial⟩

/--
If neg(H psi) is consistent, then neg psi is consistent.
-/
theorem neg_past_neg_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.neg (Formula.all_past psi))) :
    FormulaConsistent (Formula.neg psi) := by
  intro h_incons
  apply h
  obtain ⟨d, _⟩ := h_incons
  have h_neg_neg_psi : ⊢ psi.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] psi.neg Formula.bot d
  have h_dne : ⊢ psi.neg.neg.imp psi := Bimodal.Theorems.Propositional.double_negation psi
  have h_psi : ⊢ psi := Bimodal.ProofSystem.DerivationTree.modus_ponens [] psi.neg.neg psi h_dne h_neg_neg_psi
  have h_h_psi : ⊢ Formula.all_past psi := Bimodal.Theorems.past_necessitation psi h_psi
  have d_neg_h_bot : [Formula.neg (Formula.all_past psi)] ⊢ Formula.bot :=
    derives_bot_from_phi_neg_phi
      (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_h_psi (List.nil_subset _))
      (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp))
  exact ⟨d_neg_h_bot, trivial⟩

/--
processWorkItem preserves seed consistency when the processed formula is consistent
and the formula is already in the seed at the work item's position.

This is the main lemma for Phase 4. It proceeds by case analysis on the
formula classification and uses the existing `addFormula_seed_preserves_consistent`,
`createNewFamily_preserves_seedConsistent`, and `createNewTime_preserves_seedConsistent`.

The key insight is that `h_in_seed` ensures that when we add a formula to an existing
entry, we're inserting something already present (so insert is identity) or adding
to a new position (where h_compat is vacuous).
-/
theorem processWorkItem_preserves_consistent (item : WorkItem) (state : WorklistState)
    (h_cons : SeedConsistent state.seed)
    (h_wf : SeedWellFormed state.seed)
    (h_item_cons : FormulaConsistent item.formula)
    (h_in_seed : item.formula ∈ state.seed.getFormulas item.famIdx item.timeIdx) :
    SeedConsistent (processWorkItem item state).2.seed := by
  unfold processWorkItem
  -- Case split on formula classification
  match h_class : classifyFormula item.formula with
  | .atomic _ =>
    -- Just adds atomic formula to seed - trivially consistent
    simp only
    apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons h_item_cons
    -- Compatibility: formula already in entry, so insert is identity
    intro entry h_entry h_fam h_time
    have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
    -- Use well-formedness to show item.formula ∈ entry.formulas
    have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
      state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
    have h_formula_in_entry : item.formula ∈ entry.formulas := by
      rw [← h_getFormulas_eq]; exact h_in_seed
    rw [Set.insert_eq_of_mem h_formula_in_entry]
    exact h_entry_cons
  | .bottom =>
    -- Bottom case: formula already in entry by h_in_seed
    simp only
    apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons h_item_cons
    intro entry h_entry h_fam h_time
    have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
    have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
      state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
    have h_formula_in_entry : item.formula ∈ entry.formulas := by
      rw [← h_getFormulas_eq]; exact h_in_seed
    rw [Set.insert_eq_of_mem h_formula_in_entry]
    exact h_entry_cons
  | .implication _ _ =>
    -- Implication case: formula already in entry by h_in_seed
    simp only
    apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons h_item_cons
    intro entry h_entry h_fam h_time
    have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
    have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
      state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
    have h_formula_in_entry : item.formula ∈ entry.formulas := by
      rw [← h_getFormulas_eq]; exact h_in_seed
    rw [Set.insert_eq_of_mem h_formula_in_entry]
    exact h_entry_cons
  | .negation _ =>
    -- Negation case: formula already in entry by h_in_seed
    simp only
    apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons h_item_cons
    intro entry h_entry h_fam h_time
    have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
    have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
      state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
    have h_formula_in_entry : item.formula ∈ entry.formulas := by
      rw [← h_getFormulas_eq]; exact h_in_seed
    rw [Set.insert_eq_of_mem h_formula_in_entry]
    exact h_entry_cons
  | .boxPositive psi =>
    -- Box psi: add Box psi and psi to all families
    simp only
    sorry -- boxPositive case - multiple additions, complex
  | .boxNegative psi =>
    -- neg(Box psi): add to current, create new family with neg psi
    simp only
    -- Establish item.formula = neg(Box psi) from h_class
    -- The match-on-hf approach handles all formula patterns
    have h_eq : item.formula = psi.box.neg := by
      match hf : item.formula with
      | Formula.imp (Formula.box inner) Formula.bot =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- neg psi is consistent since neg(Box psi) is consistent
    have h_neg_psi_cons : FormulaConsistent psi.neg :=
      neg_box_neg_inner_consistent psi (h_eq ▸ h_item_cons)
    -- Define intermediate seed
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx psi.box.neg .universal_target
    -- seed1 is consistent
    have h_seed1_cons : SeedConsistent seed1 := by
      apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons (h_eq ▸ h_item_cons)
      intro entry h_entry h_fam h_time
      have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
      have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
        state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
      have h_formula_in_entry : psi.box.neg ∈ entry.formulas := by
        rw [← h_getFormulas_eq, ← h_eq]; exact h_in_seed
      rw [Set.insert_eq_of_mem h_formula_in_entry]
      exact h_entry_cons
    -- Result is consistent by createNewFamily_preserves_seedConsistent
    exact createNewFamily_preserves_seedConsistent seed1 item.timeIdx psi.neg h_seed1_cons h_neg_psi_cons
  | .futurePositive psi =>
    simp only
    sorry -- futurePositive case
  | .futureNegative psi =>
    -- neg(G psi): create new time with neg psi
    simp only
    -- Establish item.formula = neg(G psi) from h_class
    have h_eq : item.formula = psi.all_future.neg := by
      match hf : item.formula with
      | Formula.imp (Formula.all_future inner) Formula.bot =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- neg psi is consistent since neg(G psi) is consistent
    have h_neg_psi_cons : FormulaConsistent psi.neg :=
      neg_future_neg_inner_consistent psi (h_eq ▸ h_item_cons)
    -- Define intermediate seed
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx psi.all_future.neg .universal_target
    -- seed1 is consistent
    have h_seed1_cons : SeedConsistent seed1 := by
      apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons (h_eq ▸ h_item_cons)
      intro entry h_entry h_fam h_time
      have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
      have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
        state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
      have h_formula_in_entry : psi.all_future.neg ∈ entry.formulas := by
        rw [← h_getFormulas_eq, ← h_eq]; exact h_in_seed
      rw [Set.insert_eq_of_mem h_formula_in_entry]
      exact h_entry_cons
    -- newTime has no existing entry (fresh)
    let newTime := seed1.freshFutureTime item.famIdx item.timeIdx
    -- Result is consistent by createNewTime_preserves_seedConsistent
    exact createNewTime_preserves_seedConsistent seed1 item.famIdx newTime psi.neg h_seed1_cons h_neg_psi_cons
  | .pastPositive psi =>
    simp only
    sorry -- pastPositive case
  | .pastNegative psi =>
    -- neg(H psi): create new time with neg psi
    simp only
    -- Establish item.formula = neg(H psi) from h_class
    have h_eq : item.formula = psi.all_past.neg := by
      match hf : item.formula with
      | Formula.imp (Formula.all_past inner) Formula.bot =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- neg psi is consistent since neg(H psi) is consistent
    have h_neg_psi_cons : FormulaConsistent psi.neg :=
      neg_past_neg_inner_consistent psi (h_eq ▸ h_item_cons)
    -- Define intermediate seed
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx psi.all_past.neg .universal_target
    -- seed1 is consistent
    have h_seed1_cons : SeedConsistent seed1 := by
      apply addFormula_seed_preserves_consistent _ _ _ _ _ h_cons (h_eq ▸ h_item_cons)
      intro entry h_entry h_fam h_time
      have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
      have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position
        state.seed entry item.famIdx item.timeIdx h_wf h_entry h_fam h_time
      have h_formula_in_entry : psi.all_past.neg ∈ entry.formulas := by
        rw [← h_getFormulas_eq, ← h_eq]; exact h_in_seed
      rw [Set.insert_eq_of_mem h_formula_in_entry]
      exact h_entry_cons
    -- newTime has no existing entry (fresh)
    let newTime := seed1.freshPastTime item.famIdx item.timeIdx
    -- Result is consistent by createNewTime_preserves_seedConsistent
    exact createNewTime_preserves_seedConsistent seed1 item.famIdx newTime psi.neg h_seed1_cons h_neg_psi_cons

/--
New work items from processWorkItem have formulas that are consistent
when the original item's formula is consistent.

This follows from the key insight that new work items are always subformulas
(or negations of subformulas) of the original formula, and subformulas of
consistent formulas are consistent.
-/
theorem processWorkItem_newWork_consistent (item : WorkItem) (state : WorklistState)
    (h_item_cons : FormulaConsistent item.formula)
    (w : WorkItem) (hw : w ∈ (processWorkItem item state).1) :
    FormulaConsistent w.formula := by
  unfold processWorkItem at hw
  match h_class : classifyFormula item.formula with
  | .atomic _ =>
    simp only [h_class] at hw
    simp at hw
  | .bottom =>
    simp only [h_class] at hw
    simp at hw
  | .implication _ _ =>
    simp only [h_class] at hw
    simp at hw
  | .negation _ =>
    simp only [h_class] at hw
    simp at hw
  | .boxPositive psi =>
    -- classifyFormula returns boxPositive psi implies item.formula = Box psi
    -- New work items have formula psi, which is consistent by box_inner_consistent
    -- From h_class, item.formula = Box psi
    have h_eq : item.formula = psi.box := by
      match hf : item.formula with
      | Formula.box inner =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- psi is consistent since Box psi is consistent
    have h_psi_cons : FormulaConsistent psi := box_inner_consistent psi (h_eq ▸ h_item_cons)
    -- hw : w is in newWork, which maps psi to all families
    simp only [processWorkItem, h_class, List.mem_map, WorkItem.mk.injEq] at hw
    have h_w_formula : w.formula = psi := by
      obtain ⟨_, _, h_eq_w⟩ := hw
      rw [← h_eq_w]
    rw [h_w_formula]
    exact h_psi_cons
  | .boxNegative psi =>
    -- item.formula = neg(Box psi), new work has formula neg psi
    -- From h_class, item.formula = neg(Box psi)
    have h_eq : item.formula = psi.box.neg := by
      match hf : item.formula with
      | Formula.imp (Formula.box inner) Formula.bot =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- neg psi is consistent since neg(Box psi) is consistent
    have h_neg_psi_cons : FormulaConsistent psi.neg :=
      neg_box_neg_inner_consistent psi (h_eq ▸ h_item_cons)
    -- hw : w is in newWork = [neg psi at new family]
    simp only [h_class] at hw
    simp only [List.mem_singleton] at hw
    rw [hw]
    exact h_neg_psi_cons
  | .futurePositive psi =>
    -- item.formula = G psi, new work items have formula psi
    have h_eq : item.formula = psi.all_future := by
      match hf : item.formula with
      | Formula.all_future inner =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- psi is consistent since G psi is consistent
    have h_psi_cons : FormulaConsistent psi := all_future_inner_consistent psi (h_eq ▸ h_item_cons)
    -- hw : w is in (psi at current) :: (psi at future times)
    simp only [processWorkItem, h_class, List.mem_cons, List.mem_map, WorkItem.mk.injEq] at hw
    cases hw with
    | inl h_head =>
      rw [h_head]
      exact h_psi_cons
    | inr h_tail =>
      obtain ⟨_, _, h_eq_w⟩ := h_tail
      rw [← h_eq_w]
      exact h_psi_cons
  | .futureNegative psi =>
    -- item.formula = neg(G psi), new work has formula neg psi
    have h_eq : item.formula = psi.all_future.neg := by
      match hf : item.formula with
      | Formula.imp (Formula.all_future inner) Formula.bot =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- neg psi is consistent since neg(G psi) is consistent
    have h_neg_psi_cons : FormulaConsistent psi.neg :=
      neg_future_neg_inner_consistent psi (h_eq ▸ h_item_cons)
    -- hw : w is in newWork = [neg psi at new time]
    simp only [h_class] at hw
    simp only [List.mem_singleton] at hw
    rw [hw]
    exact h_neg_psi_cons
  | .pastPositive psi =>
    -- item.formula = H psi, new work items have formula psi
    have h_eq : item.formula = psi.all_past := by
      match hf : item.formula with
      | Formula.all_past inner =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_past _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- psi is consistent since H psi is consistent
    have h_psi_cons : FormulaConsistent psi := all_past_inner_consistent psi (h_eq ▸ h_item_cons)
    -- hw : w is in (psi at current) :: (psi at past times)
    simp only [processWorkItem, h_class, List.mem_cons, List.mem_map, WorkItem.mk.injEq] at hw
    cases hw with
    | inl h_head =>
      rw [h_head]
      exact h_psi_cons
    | inr h_tail =>
      obtain ⟨_, _, h_eq_w⟩ := h_tail
      rw [← h_eq_w]
      exact h_psi_cons
  | .pastNegative psi =>
    -- item.formula = neg(H psi), new work has formula neg psi
    have h_eq : item.formula = psi.all_past.neg := by
      match hf : item.formula with
      | Formula.imp (Formula.all_past inner) Formula.bot =>
        simp only [classifyFormula, hf] at h_class
        cases h_class; rfl
      | Formula.atom _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.box _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_future _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.all_past _ => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.atom _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp Formula.bot Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.imp _ _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.box _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp (Formula.all_future _) Formula.bot => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.atom _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.imp _ _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.box _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_future _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
      | Formula.imp _ (Formula.all_past _) => simp only [classifyFormula, hf] at h_class; nomatch h_class
    -- neg psi is consistent since neg(H psi) is consistent
    have h_neg_psi_cons : FormulaConsistent psi.neg :=
      neg_past_neg_inner_consistent psi (h_eq ▸ h_item_cons)
    -- hw : w is in newWork = [neg psi at new time]
    simp only [h_class] at hw
    simp only [List.mem_singleton] at hw
    rw [hw]
    exact h_neg_psi_cons

/--
processWorklistAux preserves the worklist invariant.
-/
theorem processWorklistAux_preserves_invariant (fuel : Nat) (state : WorklistState)
    (h_inv : WorklistInvariant state) :
    SeedConsistent (processWorklistAux fuel state) := by
  induction fuel generalizing state with
  | zero =>
    simp only [processWorklistAux]
    exact h_inv.1
  | succ fuel' ih =>
    simp only [processWorklistAux]
    match h_wl : state.worklist with
    | [] =>
      simp only [h_wl]
      exact h_inv.1
    | item :: rest =>
      simp only [h_wl]
      by_cases h_proc : item ∈ state.processed
      · -- Already processed, skip
        simp only [h_proc, ↓reduceIte]
        apply ih
        refine ⟨h_inv.1, h_inv.2.1, ?_⟩
        intro w hw
        -- hw : w ∈ rest (from the modified state's worklist)
        -- Need: w ∈ state.worklist = item :: rest
        have h_w_in_state : w ∈ state.worklist := h_wl ▸ List.mem_cons_of_mem item hw
        exact h_inv.2.2 w h_w_in_state
      · -- Process the item
        simp only [h_proc, ↓reduceIte]
        apply ih
        have h_item_in_state : item ∈ state.worklist := by simp [h_wl]
        have h_item_inv := h_inv.2.2 item h_item_in_state
        refine ⟨?_, ?_, ?_⟩
        · -- Seed consistency after processWorkItem
          exact processWorkItem_preserves_consistent item { state with worklist := rest }
            h_inv.1 h_inv.2.1 h_item_inv.1 h_item_inv.2
        · -- Well-formedness after processWorkItem
          sorry -- Need: processWorkItem preserves well-formedness
        · -- All work items in updated worklist have consistent formulas in seed
          intro w hw
          -- w is either from rest (original) or from newWork
          simp only [List.mem_append] at hw
          cases hw with
          | inl h_rest =>
            have h_w_in_state : w ∈ state.worklist := by simp [h_wl, h_rest]
            have h_w_inv := h_inv.2.2 w h_w_in_state
            -- Need: w.formula ∈ new_seed.getFormulas w.famIdx w.timeIdx
            -- This requires showing processWorkItem preserves membership
            sorry -- Need: formula membership preserved through processWorkItem
          | inr h_new =>
            -- w is from filtered newWork
            simp only [List.mem_filter] at h_new
            have h_in_new := h_new.1
            -- New work item: need to show its formula is consistent and in seed
            sorry -- Need: new work items have formulas in updated seed

/--
processWorklist preserves seed consistency when starting from a consistent state.
-/
theorem processWorklist_preserves_consistent (state : WorklistState)
    (h_inv : WorklistInvariant state) :
    SeedConsistent (processWorklist state) := by
  unfold processWorklist
  apply processWorklistAux_preserves_invariant
  exact h_inv

/--
buildSeedComplete produces a consistent seed if the input formula is consistent.
-/
theorem buildSeedComplete_consistent (phi : Formula) (h_cons : FormulaConsistent phi) :
    SeedConsistent (buildSeedComplete phi) := by
  unfold buildSeedComplete
  apply processWorklist_preserves_consistent
  -- Show WorklistInvariant for initial state
  refine ⟨?_, ?_, ?_⟩
  · -- Initial seed consistency uses existing lemma
    simp only [WorklistState.initial]
    exact initialSeedConsistent phi h_cons
  · -- Initial seed well-formedness
    simp only [WorklistState.initial]
    exact initialSeedWellFormed phi
  · -- All work items (just phi) are consistent and in seed
    intro item h_item
    simp only [WorklistState.initial, List.mem_singleton] at h_item
    rw [h_item]
    simp only [WorkItem.formula, WorkItem.famIdx, WorkItem.timeIdx]
    constructor
    · exact h_cons
    · -- phi ∈ (ModelSeed.initial phi).getFormulas 0 0
      simp only [WorklistState.initial, ModelSeed.initial, ModelSeed.getFormulas, ModelSeed.findEntry,
        List.find?_cons, beq_self_eq_true, Bool.and_self, cond_true, Set.mem_singleton_iff]


end Bimodal.Metalogic.Bundle
