/-
  ARCHIVED CODE - F-Preserving Seed Construction

  Original location: Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean
  Original lines: 2485-3473
  Archived: 2026-03-31 (Task 80)

  REASON FOR ARCHIVAL:
  Task #69 proved this approach FALSE. The box_F_seed_chain produces
  chains that are NOT F-preserving in general. The fundamental assumption
  that F-preservation can be maintained through temporal box operations
  was mathematically incorrect.

  This code is preserved for historical reference only.
  It contains 2 sorries that represent the unfixable gaps.

  TO USE THIS CODE (not recommended):
  - Would need to import Bimodal.Metalogic.Algebraic.UltrafilterChain
  - These definitions would need to be adapted to compile standalone
-/

-- BEGIN ARCHIVED CODE (989 lines)
-- ===================================

/-!
### F-Preserving Seeds

The standard `temporal_theory_witness_exists` uses seed = {phi} ∪ G_theory ∪ box_theory.
This allows Lindenbaum to add G(neg psi) = neg(F(psi)) when consistent with the seed,
even when F(psi) was present in the original MCS.

F-preserving seeds include unresolved F-formulas in the seed, preventing Lindenbaum
from adding their negations.

**Key Insight**: If G(neg psi) were derivable from the original seed when F(psi) ∈ M,
then by the G-lift argument G(neg psi) ∈ M. But F(psi) = neg(G(neg psi)) ∈ M contradicts
this. Therefore adding F(psi) to the seed is safe.
-/

/--
The set of unresolved F-formulas in an MCS M.

F(psi) is unresolved in M if F(psi) ∈ M but psi ∉ M. These formulas represent
temporal obligations that haven't been satisfied yet.
-/
def F_unresolved_theory (M : Set Formula) : Set Formula :=
  { f | ∃ psi, f = Formula.some_future psi ∧ Formula.some_future psi ∈ M ∧ psi ∉ M }

/-!
### Helper Lemmas for F-Preserving Seed Consistency

**DEAD CODE** (Task #69, report 17 counterexample):
The F-preserving seed approach was abandoned after Task #69 discovered a counterexample
proving `f_preserving_seed_consistent` is FALSE. The counterexample uses M = MCS({F(p)})
where F(p) is unresolved (p not in M). The F-preserving seed then includes F(p), but
consistency cannot be guaranteed because G-lifting F-formulas is not derivable in TM.

See: specs/069_explore_ultrafilter_construction/reports/17_f-preserving-counterexample.md

These lemmas are retained for historical documentation but should not be used.
The correct approach is the separate-direction witness construction in SuccChainFMCS.lean.
-/

/--
If a disjunction of G-formulas is in an MCS, then at least one of the G-formulas is in the MCS.

This follows from the T-axiom (G(φ) → φ) and the MCS disjunction property.
-/
theorem G_disjunction_in_mcs_elim (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (As : List Formula)
    (h : (As.map Formula.all_future).foldr Formula.or Formula.bot ∈ M) :
    ∃ a ∈ As, Formula.all_future a ∈ M := by
  -- Use disjunction_elim repeatedly
  induction As with
  | nil =>
    -- foldr on [] gives ⊥
    simp only [List.map_nil, List.foldr_nil] at h
    -- ⊥ ∈ M contradicts MCS consistency
    exfalso
    -- MCS consistency means no finite subset derives ⊥
    -- If ⊥ ∈ M, then [⊥] ⊆ M and [⊥] ⊢ ⊥ trivially
    have h_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption [Formula.bot] Formula.bot (List.mem_singleton.mpr rfl)
    exact h_mcs.1 [Formula.bot] (fun x hx => by simp at hx; rw [hx]; exact h) ⟨h_deriv⟩
  | cons a rest ih =>
    simp only [List.map_cons, List.foldr_cons] at h
    -- h : (G(a) ∨ rest...) ∈ M
    cases SetMaximalConsistent.disjunction_elim h_mcs h with
    | inl h_Ga => exact ⟨a, .head _, h_Ga⟩
    | inr h_rest =>
      have ⟨b, h_b_rest, h_Gb⟩ := ih h_rest
      exact ⟨b, .tail _ h_b_rest, h_Gb⟩

/--
If G of a disjunction of G-formulas is in an MCS, then at least one of the G-formulas is in the MCS.

This combines the T-axiom with G_disjunction_in_mcs_elim.
-/
theorem G_of_disjunction_in_mcs_elim (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (As : List Formula)
    (h : Formula.all_future ((As.map Formula.all_future).foldr Formula.or Formula.bot) ∈ M) :
    ∃ a ∈ As, Formula.all_future a ∈ M := by
  -- By T-axiom: G(φ) → φ
  have h_T : [] ⊢ (Formula.all_future ((As.map Formula.all_future).foldr Formula.or Formula.bot)).imp
                  ((As.map Formula.all_future).foldr Formula.or Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future _)
  -- Apply to M
  have h_disj : (As.map Formula.all_future).foldr Formula.or Formula.bot ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h
  exact G_disjunction_in_mcs_elim M h_mcs As h_disj

/--
The F-preserving seed for temporal witness construction.

This extends the standard temporal_box_seed with unresolved F-formulas,
ensuring that Lindenbaum cannot add G(neg psi) = neg(F(psi)) for any
unresolved F(psi) in the original MCS.
-/
def f_preserving_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M

/--
Elements of G_theory are in the F-preserving seed.
-/
theorem G_theory_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    G_theory M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_right _ (Set.mem_union_left _ hx))

/--
Elements of box_theory are in the F-preserving seed.
-/
theorem box_theory_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    box_theory M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_right _ (Set.mem_union_right _ hx))

/--
Elements of F_unresolved_theory are in the F-preserving seed.
-/
theorem F_unresolved_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    F_unresolved_theory M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_right _ hx

/--
The witness formula is in the F-preserving seed.
-/
theorem phi_in_f_preserving_seed (M : Set Formula) (phi : Formula) :
    phi ∈ f_preserving_seed M phi := by
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton phi))

/--
The temporal_box_seed is contained in the F-preserving seed.
-/
theorem temporal_box_seed_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    temporal_box_seed M ⊆ f_preserving_seed M phi := by
  intro x hx
  unfold f_preserving_seed
  exact Set.mem_union_left _ (Set.mem_union_right _ hx)

/--
All elements of F_unresolved_theory are F-formulas that are in M.
-/
theorem F_unresolved_theory_subset_M (M : Set Formula) :
    F_unresolved_theory M ⊆ M := by
  intro f hf
  simp only [F_unresolved_theory, Set.mem_setOf_eq] at hf
  obtain ⟨psi, rfl, h_in, _⟩ := hf
  exact h_in

/--
The standard seed ({phi} ∪ G_theory ∪ box_theory) is a subset of the F-preserving seed.
-/
theorem standard_seed_subset_f_preserving_seed (M : Set Formula) (phi : Formula) :
    {phi} ∪ temporal_box_seed M ⊆ f_preserving_seed M phi := by
  intro x hx
  simp only [Set.mem_union, Set.mem_singleton_iff] at hx
  rcases hx with rfl | hx
  · exact phi_in_f_preserving_seed M x
  · exact temporal_box_seed_subset_f_preserving_seed M phi hx

/--
The F-preserving seed is consistent when F(phi) ∈ M.

**Proof Strategy**:
Suppose the F-preserving seed is inconsistent. Then there exists finite
L ⊆ f_preserving_seed M phi with L ⊢ ⊥.

Partition L into:
- L_core ⊆ {phi} ∪ temporal_box_seed M (the standard seed)
- L_F ⊆ F_unresolved_theory M (the F-formulas we added)

By deduction theorem, extracting all F-formulas from L_F:
  L_core ⊢ F(psi_1) → F(psi_2) → ... → F(psi_k) → ⊥

This is equivalent to:
  L_core ⊢ neg(F(psi_1)) ∨ neg(F(psi_2)) ∨ ... ∨ neg(F(psi_k))
  = L_core ⊢ G(neg psi_1) ∨ G(neg psi_2) ∨ ... ∨ G(neg psi_k)

Since L_core ⊆ standard seed and all elements have their G in M,
by G-lift: G(G(neg psi_1) ∨ ...) ∈ M.
By the K axiom for G: G(G(neg psi_1)) ∨ ... ∨ G(G(neg psi_k)) ∈ M.
By T axiom: G(neg psi_i) ∈ M for some i.

But F(psi_i) ∈ M (since F(psi_i) ∈ F_unresolved_theory M ⊆ M), contradiction.

Note: The actual proof is simpler - we show that inconsistency of the F-preserving
seed would imply inconsistency of {phi} ∪ temporal_box_seed M, contradicting
temporal_theory_witness_consistent.
-/
theorem f_preserving_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (f_preserving_seed M phi) := by
  -- The F-preserving seed extends the standard seed with F_unresolved_theory.
  -- We show this extension preserves consistency.

  -- Key insight: f_preserving_seed M phi ⊆ {phi} ∪ temporal_box_seed M ∪ M
  -- And any inconsistency must come from the interaction between components.

  -- The proof uses that adding F-formulas that are already in M cannot break
  -- the consistency of the standard seed.

  intro L h_L_sub ⟨d⟩

  -- Classify each element of L based on where it comes from
  -- We'll show: either L ⊆ standard seed (contradicts temporal_theory_witness_consistent)
  -- or we can extract F-formulas using deduction theorem and derive contradiction

  -- Check if any element of L is from F_unresolved_theory but not in standard seed
  by_cases h_all_standard : ∀ x ∈ L, x ∈ {phi} ∪ temporal_box_seed M

  · -- Case 1: All elements are from the standard seed
    exact temporal_theory_witness_consistent M h_mcs phi h_F L h_all_standard ⟨d⟩

  · -- Case 2: Some element is from F_unresolved_theory
    push_neg at h_all_standard
    obtain ⟨x, hx_L, hx_not_standard⟩ := h_all_standard

    -- x ∈ f_preserving_seed M phi but x ∉ {phi} ∪ temporal_box_seed M
    -- So x ∈ F_unresolved_theory M
    have hx_seed := h_L_sub x hx_L
    simp only [f_preserving_seed, Set.mem_union] at hx_seed

    have hx_F : x ∈ F_unresolved_theory M := by
      rcases hx_seed with (h | h) | h
      · -- x ∈ {phi}
        exfalso; apply hx_not_standard
        exact Set.mem_union_left _ h
      · -- x ∈ temporal_box_seed M
        exfalso; apply hx_not_standard
        exact Set.mem_union_right _ h
      · -- x ∈ F_unresolved_theory M
        exact h

    -- x ∈ F_unresolved_theory M, so x = F(psi) for some psi with F(psi) ∈ M and psi ∉ M
    simp only [F_unresolved_theory, Set.mem_setOf_eq] at hx_F
    obtain ⟨psi, rfl, h_Fpsi_M, h_psi_not_M⟩ := hx_F

    -- Now we use the key argument:
    -- If L ⊢ ⊥ and F(psi) ∈ L, then L \ {F(psi)} ⊢ neg(F(psi)) = G(neg psi)

    -- Filter out F(psi) from L
    let L_no_F := L.filter (· ≠ Formula.some_future psi)

    have h_L_sub_cons : ∀ y ∈ L, y ∈ (Formula.some_future psi) :: L_no_F := by
      intro y hy
      by_cases h_eq : y = Formula.some_future psi
      · rw [h_eq]; exact .head _
      · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hy, decide_eq_true h_eq⟩)

    have d_weak : DerivationTree ((Formula.some_future psi) :: L_no_F) Formula.bot :=
      DerivationTree.weakening L _ Formula.bot d h_L_sub_cons

    -- By deduction theorem: L_no_F ⊢ neg(F(psi))
    have d_neg_F : DerivationTree L_no_F (Formula.neg (Formula.some_future psi)) :=
      Bimodal.Metalogic.Core.deduction_theorem L_no_F (Formula.some_future psi) Formula.bot d_weak

    -- neg(F(psi)) = G(neg psi)
    -- So L_no_F ⊢ G(neg psi)

    -- All elements of L_no_F are still in f_preserving_seed M phi
    have h_L_no_F_sub : ∀ y ∈ L_no_F, y ∈ f_preserving_seed M phi := by
      intro y hy
      exact h_L_sub y (List.mem_of_mem_filter hy)

    -- Key insight: All elements of L_no_F except possibly phi are in M.
    -- - temporal_box_seed M ⊆ M (by definition of G_theory and box_theory)
    -- - F_unresolved_theory M ⊆ M (F(sigma) ∈ M for each element)
    -- - Only phi may not be in M

    -- First, check if phi is in M - if so, the entire seed is in M
    by_cases h_phi_M : phi ∈ M

    · -- phi ∈ M: The entire seed is a subset of M, hence consistent
      -- All elements of f_preserving_seed M phi are in M:
      -- - {phi} ⊆ M by h_phi_M
      -- - temporal_box_seed M ⊆ M
      -- - F_unresolved_theory M ⊆ M
      -- So L ⊆ M, and L ⊢ bot. By MCS derivation closure, bot ∈ M.
      -- But MCS doesn't contain bot. Contradiction.
      have h_L_in_M : ∀ x ∈ L, x ∈ M := by
        intro x hx
        have hx_seed := h_L_sub x hx
        simp only [f_preserving_seed, Set.mem_union] at hx_seed
        rcases hx_seed with (h | h) | h
        · -- x ∈ {phi}
          simp only [Set.mem_singleton_iff] at h
          rw [h]; exact h_phi_M
        · -- x ∈ temporal_box_seed M
          simp only [temporal_box_seed, Set.mem_union] at h
          rcases h with hG | hBox
          · -- x ∈ G_theory M: x = G(a) with G(a) ∈ M
            simp only [G_theory, Set.mem_setOf_eq] at hG
            obtain ⟨a, rfl, ha⟩ := hG
            exact ha
          · -- x ∈ box_theory M - use box_theory_subset_mcs
            exact box_theory_subset_mcs M h_mcs hBox
        · -- x ∈ F_unresolved_theory M: x = F(sigma) with F(sigma) ∈ M
          simp only [F_unresolved_theory, Set.mem_setOf_eq] at h
          obtain ⟨sigma, rfl, h_Fsigma_M, _⟩ := h
          exact h_Fsigma_M
      -- Now derive contradiction
      have h_bot_M : Formula.bot ∈ M :=
        SetMaximalConsistent.closed_under_derivation h_mcs L h_L_in_M d
      exact h_mcs.1 [Formula.bot] (fun x hx => by simp at hx; rw [hx]; exact h_bot_M)
        ⟨DerivationTree.assumption [Formula.bot] Formula.bot (List.mem_singleton.mpr rfl)⟩

    · -- phi ∉ M: All elements of L_no_F except phi are in M
      -- By MCS completeness, neg(phi) ∈ M
      have h_neg_phi_M : Formula.neg phi ∈ M := by
        rcases SetMaximalConsistent.negation_complete h_mcs phi with h | h
        · exact absurd h h_phi_M
        · exact h

      -- Filter L_no_F to remove phi
      let L_no_phi := L_no_F.filter (· ≠ phi)

      -- All elements of L_no_phi are in M
      have h_L_no_phi_in_M : ∀ x ∈ L_no_phi, x ∈ M := by
        intro x hx
        have hx_L_no_F := List.mem_of_mem_filter hx
        have hx_ne_phi : x ≠ phi := of_decide_eq_true (List.mem_filter.mp hx).2
        have hx_seed := h_L_no_F_sub x hx_L_no_F
        simp only [f_preserving_seed, Set.mem_union] at hx_seed
        rcases hx_seed with (h | h) | h
        · -- x ∈ {phi}
          simp only [Set.mem_singleton_iff] at h
          exact absurd h hx_ne_phi
        · -- x ∈ temporal_box_seed M
          simp only [temporal_box_seed, Set.mem_union] at h
          rcases h with hG | hBox
          · simp only [G_theory, Set.mem_setOf_eq] at hG
            obtain ⟨a, rfl, ha⟩ := hG
            exact ha
          · -- x ∈ box_theory M - use box_theory_subset_mcs
            exact box_theory_subset_mcs M h_mcs hBox
        · -- x ∈ F_unresolved_theory M
          simp only [F_unresolved_theory, Set.mem_setOf_eq] at h
          obtain ⟨sigma, rfl, h_Fsigma_M, _⟩ := h
          exact h_Fsigma_M

      -- Now we show: L_no_phi ⊢ neg(F(psi))
      -- And since L_no_phi ⊆ M, we get neg(F(psi)) = G(neg psi) ∈ M
      -- This contradicts F(psi) ∈ M

      -- Check if phi ∈ L_no_F
      by_cases h_phi_L_no_F : phi ∈ L_no_F

      · -- phi ∈ L_no_F: extract it using deduction theorem
        have h_L_no_F_sub_phi : ∀ y ∈ L_no_F, y ∈ phi :: L_no_phi := by
          intro y hy
          by_cases h_eq : y = phi
          · rw [h_eq]; exact .head _
          · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hy, decide_eq_true h_eq⟩)

        have d_weak' : DerivationTree (phi :: L_no_phi) (Formula.neg (Formula.some_future psi)) :=
          DerivationTree.weakening L_no_F _ _ d_neg_F h_L_no_F_sub_phi

        have d_imp : DerivationTree L_no_phi (phi.imp (Formula.neg (Formula.some_future psi))) :=
          Bimodal.Metalogic.Core.deduction_theorem L_no_phi phi _ d_weak'

        -- Since L_no_phi ⊆ M, we get phi → G(neg psi) ∈ M
        have h_imp_M : phi.imp (Formula.neg (Formula.some_future psi)) ∈ M :=
          SetMaximalConsistent.closed_under_derivation h_mcs L_no_phi h_L_no_phi_in_M d_imp

        -- By MCS implication property with neg(phi) ∈ M:
        -- We have phi → G(neg psi) ∈ M and need to conclude about G(neg psi)
        -- Actually, by MCS we have: either neg(phi) ∈ M or (phi → X) → X ∈ M... no that's wrong

        -- Better: (A → B) ∈ M and neg(A) ∈ M doesn't directly give B ∈ M
        -- But we can use: neg(phi) ∈ M implies phi ∉ M (which we have)
        -- And (phi → G(neg psi)) ∈ M with phi ∉ M...
        -- By MCS dichotomy: for any formula, either it or its negation is in MCS
        -- So either G(neg psi) ∈ M or neg(G(neg psi)) = F(psi) ∈ M
        -- We know F(psi) ∈ M. So this doesn't give us G(neg psi) ∈ M directly.

        -- But wait! We can derive: neg(phi) → (phi → X) → X is a tautology? No, that's not right.
        -- neg(A) ∧ (A → B) → ? We get: A is false, so A → B is vacuously true.
        -- This doesn't tell us about B.

        -- Actually, the key is: neg(phi) ∈ M means phi ∉ M.
        -- And L_no_phi ⊢ phi → G(neg psi).
        -- What if we add phi to M? Then M ∪ {phi} would be inconsistent (since neg(phi) ∈ M).
        -- So {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M might be inconsistent?
        -- No wait, that's what we're trying to prove is consistent!

        -- Let me think differently. We have:
        -- d_neg_F : L_no_F ⊢ G(neg psi)
        -- And we're trying to derive False.

        -- Key: L_no_F ⊆ f_preserving_seed M phi.
        -- If L_no_F ⊆ {phi} ∪ temporal_box_seed M:
        --   By temporal_theory_witness_consistent (modified), we can handle this.
        -- If L_no_F still has elements from F_unresolved_theory M \ {F(psi)}:
        --   We need to recurse.

        -- Since we're in case 2 (some element not in standard seed), and we extracted F(psi),
        -- check if L_no_F has more elements from F_unresolved_theory

        -- Simpler approach: show L_no_phi ⊆ M, and L_no_F ⊢ G(neg psi)
        -- Want to show G(neg psi) ∈ M.
        -- If phi ∉ L_no_F (i.e., L_no_F = L_no_phi), then L_no_F ⊆ M, so G(neg psi) ∈ M. Done.
        -- If phi ∈ L_no_F, we need different argument.

        -- Actually, let's use the contrapositive.
        -- We have F(psi) ∈ M, so neg(G(neg psi)) ∈ M.
        -- If G(neg psi) ∈ M too, then M inconsistent. Contradiction since M is MCS.
        -- So G(neg psi) ∉ M.
        -- By MCS dichotomy, neg(G(neg psi)) = F(psi) ∈ M. Which we know.

        -- So the question is: can we derive G(neg psi) ∈ M from our data?

        -- We have: L_no_phi ⊢ phi → G(neg psi) with L_no_phi ⊆ M
        -- So (phi → G(neg psi)) ∈ M.
        -- By MCS dichotomy applied to G(neg psi):
        --   Either G(neg psi) ∈ M (contradiction with F(psi) ∈ M)
        --   Or F(psi) ∈ M (which we know)
        -- This doesn't give us what we want directly.

        -- The issue is that (phi → G(neg psi)) ∈ M with phi ∉ M doesn't force G(neg psi) ∈ M.

        -- Let's try: Can we show the assumption "L ⊢ bot" leads to contradiction
        -- without needing G(neg psi) ∈ M?

        -- Actually, here's the key insight:
        -- L_no_phi ⊆ M (all elements are either temporal_box_seed or F_unresolved, both ⊆ M)
        -- L_no_phi ⊢ phi → G(neg psi)
        -- So (phi → G(neg psi)) ∈ M.

        -- Claim: phi → G(neg psi) leads to contradiction with F(psi) ∈ M and F(phi) ∈ M.

        -- Actually no. phi → G(neg psi) just says "if phi then always neg psi".
        -- F(phi) ∈ M says "eventually phi".
        -- F(psi) ∈ M says "eventually psi".

        -- The key temporal reasoning:
        -- G(neg psi) means "always neg psi" including the future
        -- phi → G(neg psi) means "if phi (now), then always neg psi (forever)"
        -- F(phi) means "eventually phi"
        -- F(psi) means "eventually psi"

        -- If "eventually phi" and "phi implies always neg psi", then after phi holds,
        -- we have "always neg psi" from that point. So psi never holds after phi.
        -- But "eventually psi" says psi holds at some point.
        -- This is consistent if psi holds BEFORE phi.

        -- So the semantic argument doesn't give us a direct contradiction in general.

        -- Hmm, this is tricky. Let me reconsider the mathematical argument.

        -- Actually, I think the issue is that we can't prove this in full generality.
        -- The f_preserving_seed is specifically designed for the case where
        -- F-formulas preserve through the chain construction.

        -- Let me look at the existing temporal_theory_witness_consistent proof again
        -- to see if we can adapt it.

        -- In temporal_theory_witness_consistent:
        -- We have L ⊆ {phi} ∪ temporal_box_seed M with L ⊢ bot.
        -- We extract phi: L_no_phi ⊢ neg(phi).
        -- G-lift: G(neg phi) ∈ M (since L_no_phi ⊆ temporal_box_seed, all G-liftable).
        -- Contradiction: F(phi) = neg(G(neg phi)) ∈ M contradicts G(neg phi) ∈ M.

        -- In our case:
        -- We have L ⊆ f_preserving_seed M phi with L ⊢ bot.
        -- We extracted F(psi) to get L_no_F ⊢ G(neg psi).
        -- L_no_F may contain phi and other F-formulas from F_unresolved_theory.

        -- If we could G-lift from L_no_F, we'd get G(G(neg psi)) ∈ M, hence G(neg psi) ∈ M.
        -- But phi and F-formulas don't have their G in M.

        -- The strategy should be to extract ALL non-G-liftable elements.
        -- After extracting all F-formulas and phi, the remaining context is G-liftable.

        -- Actually, wait. We already have L_no_phi ⊆ M. And L_no_phi consists of:
        -- - Elements from temporal_box_seed M (G-liftable)
        -- - Elements from F_unresolved_theory M \ {F(psi)} (NOT G-liftable)

        -- If L_no_phi has no elements from F_unresolved_theory, then L_no_phi ⊆ temporal_box_seed M,
        -- and we can G-lift (phi → G(neg psi)) to get G(phi → G(neg psi)) ∈ M.

        -- But if L_no_phi has F-formulas, we can't G-lift directly.

        -- This suggests we need INDUCTION on the number of F-formulas in L.

        -- For now, let's see if we can at least handle the case where L_no_phi ⊆ temporal_box_seed M:

        by_cases h_L_no_phi_standard : ∀ x ∈ L_no_phi, x ∈ temporal_box_seed M

        · -- L_no_phi ⊆ temporal_box_seed M: can G-lift
          have h_G_liftable : ∀ x ∈ L_no_phi, Formula.all_future x ∈ M :=
            fun x hx => G_of_temporal_box_seed M h_mcs x (h_L_no_phi_standard x hx)

          -- G-lift: G(phi → G(neg psi)) ∈ M
          have h_G_imp : Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi))) ∈ M :=
            G_lift_from_context M h_mcs L_no_phi _ d_imp h_G_liftable

          -- By K-axiom: G(A → B) → (G(A) → G(B))
          -- So G(phi → G(neg psi)) → (G(phi) → G(G(neg psi)))
          have h_K : [] ⊢ (Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))).imp
              ((Formula.all_future phi).imp (Formula.all_future (Formula.neg (Formula.some_future psi)))) :=
            DerivationTree.axiom [] _ (Axiom.temp_k_dist phi _)

          have h_G_phi_imp_GG : (Formula.all_future phi).imp (Formula.all_future (Formula.neg (Formula.some_future psi))) ∈ M :=
            SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_K) h_G_imp

          -- By 4-axiom: G(G(X)) → G(X), or equivalently G(neg(F(psi))) → neg(F(psi))
          -- Note: neg(F(psi)) = G(neg psi) is an all_future formula

          -- Actually, let's simplify. We have G(G(neg psi)) → G(neg psi) by 4-axiom.
          -- And G(phi) → G(G(neg psi)) ∈ M.
          -- So G(phi) → G(neg psi) ∈ M (by transitivity).

          -- Now, by MCS dichotomy: either G(phi) ∈ M or neg(G(phi)) = F(neg phi) ∈ M.

          -- Case: G(phi) ∈ M. Then G(neg psi) ∈ M by modus ponens.
          -- Contradiction with F(psi) ∈ M.

          -- Case: F(neg phi) ∈ M.
          -- F(neg phi) = neg(G(neg(neg phi))) = neg(G(phi)).
          -- So G(phi) ∉ M.
          -- And we have G(phi) → G(neg psi) ∈ M.
          -- This is consistent with G(neg psi) ∉ M (since G(phi) ∉ M, implication holds vacuously).

          -- Hmm, so this case doesn't give us contradiction either.

          -- Wait, but we're trying to prove f_preserving_seed is CONSISTENT.
          -- We assumed it's inconsistent (L ⊢ bot) and are deriving contradiction.
          -- In this branch, we've shown that under our assumptions, either:
          -- - G(neg psi) ∈ M (contradiction), or
          -- - F(neg phi) ∈ M

          -- If F(neg phi) ∈ M, what does that tell us about the seed's consistency?

          -- F(neg phi) ∈ M means neg(phi) ∉ M (otherwise F(neg phi) would be "resolved").
          -- Wait, F_unresolved_theory has F(X) where X ∉ M. So F(neg phi) ∈ M with neg phi ∉ M
          -- means F(neg phi) ∈ F_unresolved_theory M.

          -- But we also have neg(phi) ∈ M (from h_neg_phi_M)!
          -- Actually wait, h_neg_phi_M says neg(phi) ∈ M.
          -- And F(neg phi) ∈ M says neg(G(neg(neg phi))) = neg(G(phi)) ∈ M.
          -- These are different. neg(phi) and F(neg phi) are different formulas.

          -- So we have:
          -- - neg(phi) ∈ M (because phi ∉ M, by MCS dichotomy)
          -- - F(neg phi) ∈ M (from our case analysis)
          -- - F(phi) ∈ M (given)

          -- This is consistent! neg(phi) now, but phi eventually. Also neg phi eventually.
          -- Semantically: currently phi is false. In the future, phi will be true (F(phi)).
          -- Also in the future, phi will be false again (F(neg phi)). Compatible with phi true later.

          -- So we can't derive contradiction from F(neg phi) ∈ M alone.

          -- I think the issue is that we need a different approach for this case.

          -- Actually, wait. Let me reconsider.

          -- We have h_phi_L_no_F : phi ∈ L_no_F.
          -- And L_no_F ⊢ G(neg psi).
          -- After extracting phi: L_no_phi ⊢ phi → G(neg psi).
          -- We're in the case h_L_no_phi_standard: L_no_phi ⊆ temporal_box_seed M.

          -- So L_no_phi ⊆ temporal_box_seed M, and L_no_phi ⊆ L_no_F.
          -- And L_no_F ⊆ f_preserving_seed M phi.
          -- And L_no_F is a subset of the original L (minus F(psi)).

          -- Now, the question is: does L_no_phi ⊢ phi → G(neg psi) lead to contradiction
          -- with the consistency of f_preserving_seed?

          -- Actually, I realize the argument should be different.
          -- We should use the fact that F(psi) was extracted because F(psi) ∈ L
          -- and F(psi) ∈ F_unresolved_theory M.

          -- The key is: F(psi) ∈ M means psi ∉ M (by definition of F_unresolved_theory).
          -- Wait no, F_unresolved_theory requires F(psi) ∈ M AND psi ∉ M.
          -- So psi ∉ M.

          -- We have: L_no_phi ⊢ phi → G(neg psi) with L_no_phi ⊆ temporal_box_seed M.
          -- G-lift: G(phi → G(neg psi)) ∈ M.
          -- By K and 4: G(phi) → G(neg psi) ∈ M (derived above).

          -- Now, by contrapositive: neg(G(neg psi)) → neg(G(phi)) ∈ M.
          -- i.e., F(psi) → F(neg phi) ∈ M.

          -- We have F(psi) ∈ M. So F(neg phi) ∈ M by modus ponens.

          -- Does F(neg phi) ∈ M contradict anything?
          -- F(neg phi) = neg(G(phi)).
          -- So G(phi) ∉ M.

          -- And we have F(phi) ∈ M (given).
          -- F(phi) = neg(G(neg phi)).
          -- So G(neg phi) ∉ M.

          -- So both G(phi) ∉ M and G(neg phi) ∉ M.
          -- This is fine - it just means phi's G-value is not determined in M.

          -- I don't see an immediate contradiction.

          -- Let me try yet another approach. The issue might be that we need to
          -- track the F-formulas more carefully.

          -- INSIGHT: We have F(psi) ∈ M with psi ∉ M (from F_unresolved_theory).
          -- And we derived G(neg psi) is "forced" in some sense from the seed.
          -- The contradiction should come from F(psi) ∧ G(neg psi) being inconsistent.

          -- F(psi) = neg(G(neg psi)).
          -- So F(psi) ∧ G(neg psi) is indeed inconsistent!

          -- We need to show G(neg psi) ∈ M to get contradiction.

          -- We have: G(phi) → G(neg psi) ∈ M (from above).
          -- Case: G(phi) ∈ M. Then G(neg psi) ∈ M. Done.
          -- Case: G(phi) ∉ M.

          -- In case G(phi) ∉ M:
          -- By MCS dichotomy, F(neg phi) ∈ M (i.e., neg(G(phi)) ∈ M).

          -- Hmm, but we can't directly get G(neg psi) from this.

          -- OK here's a different idea. Let me check if the issue is with phi specifically.
          -- What if phi = G(a) for some a? Then G(phi) = G(G(a)), and by 4-axiom, G(G(a)) → G(a),
          -- so G(G(a)) ∈ M iff G(a) ∈ M.

          -- For general phi, we don't have special structure.

          -- I think the proof might need strong induction after all, handling the phi case
          -- specially. Let me try implementing a helper lemma for this.

          -- For now, let me just leave a sorry for this subcase and continue structuring the proof.
          cases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future phi) with
          | inl h_G_phi =>
            -- G(phi) ∈ M: Apply modus ponens to get G(G(neg psi)) ∈ M
            -- Note: h_G_phi_imp_GG : G(phi) → G(G(neg psi)) ∈ M
            -- since neg(F(psi)) = neg(neg(G(neg psi))) = G(neg psi) definitionally
            -- h_G_phi_imp_GG : G(phi) → G(neg(F(psi))) ∈ M
            -- h_G_phi : G(phi) ∈ M
            -- So G(neg(F(psi))) ∈ M
            -- Note: neg(F(psi)) = neg(neg(G(neg psi))) = G(neg psi) by double negation
            -- Actually: some_future psi = neg(all_future(neg psi))
            -- So neg(some_future psi) = neg(neg(all_future(neg psi))) which normalizes to all_future(neg psi)
            -- But in Lean's representation, some_future.neg = (psi.neg.all_future.neg).neg
            -- Let's directly work with the types we have

            -- h_G_neg_F_psi will be: (psi.some_future.neg).all_future ∈ M
            -- which is G(neg(F(psi)))
            have h_G_neg_F_psi : Formula.all_future (Formula.neg (Formula.some_future psi)) ∈ M :=
              SetMaximalConsistent.implication_property h_mcs h_G_phi_imp_GG h_G_phi

            -- Apply T-axiom: G(X) → X specialized to X := neg(F(psi))
            -- This gives us neg(F(psi)) ∈ M
            have h_T : [] ⊢ (Formula.all_future (Formula.neg (Formula.some_future psi))).imp
                (Formula.neg (Formula.some_future psi)) :=
              DerivationTree.axiom [] _ (Axiom.temp_t_future (Formula.neg (Formula.some_future psi)))
            have h_neg_F_psi : Formula.neg (Formula.some_future psi) ∈ M :=
              SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_neg_F_psi

            -- neg(F(psi)) ∈ M and F(psi) ∈ M contradicts MCS consistency
            exact set_consistent_not_both h_mcs.1 (Formula.some_future psi) h_Fpsi_M h_neg_F_psi
          | inr h_neg_G_phi =>
            -- neg(G(phi)) = F(neg phi) ∈ M
            -- This doesn't immediately give us contradiction.
            -- However, we can derive a contradiction via a different route.

            -- Actually, F(neg phi) ∈ M is compatible with F(phi) ∈ M.
            -- The issue is that our proof attempt assumes we can get G(neg psi) ∈ M,
            -- but in this branch we can't.

            -- Let me reconsider the whole structure. The key insight should be:
            -- If L ⊢ bot and L ⊆ f_preserving_seed M phi, then we can find some G(neg X) ∈ M
            -- where F(X) ∈ M, giving contradiction.

            -- The issue is the phi extraction. When we extract phi, we go from
            -- L ⊢ bot to L_no_phi ⊢ neg(phi). This doesn't involve F-formulas directly.

            -- Wait, actually in this case we had:
            -- L ⊢ bot with F(psi) ∈ L (from F_unresolved_theory)
            -- L_no_F ⊢ G(neg psi) (after extracting F(psi))
            -- And phi ∈ L_no_F

            -- If all elements of L_no_phi are from temporal_box_seed, we can G-lift.
            -- G(phi → G(neg psi)) ∈ M.

            -- Now, here's the key: we should think about what this means for the SEED.
            -- The seed is {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M.

            -- G(phi → G(neg psi)) ∈ M means: "always, if phi then always neg psi".
            -- This puts a constraint: whenever phi holds, psi cannot hold afterwards.

            -- Now, F(psi) ∈ F_unresolved_theory M ⊆ seed.
            -- And phi ∈ seed.
            -- And G(phi → G(neg psi)) ∈ M.

            -- If phi ∈ seed and F(psi) ∈ seed, then in any MCS extending the seed:
            -- phi ∈ W and F(psi) ∈ W (since W extends seed).
            -- But G(phi → G(neg psi)) ∈ M. Is G(phi → G(neg psi)) ∈ W?

            -- Wait, the witness W is obtained from Lindenbaum extending f_preserving_seed.
            -- G_theory M ⊆ f_preserving_seed, so G_theory M ⊆ W.
            -- In particular, G(phi → G(neg psi)) ∈ M... but is this in G_theory M?

            -- G_theory M = { G(a) | G(a) ∈ M }.
            -- So G(phi → G(neg psi)) ∈ G_theory M iff G(phi → G(neg psi)) ∈ M.
            -- We showed G(phi → G(neg psi)) ∈ M above (h_G_imp).

            -- So G(phi → G(neg psi)) ∈ G_theory M ⊆ f_preserving_seed M phi.

            -- Now, in any MCS W extending f_preserving_seed:
            -- - phi ∈ W (since phi ∈ f_preserving_seed)
            -- - F(psi) ∈ W (since F(psi) ∈ F_unresolved_theory M ⊆ f_preserving_seed)
            -- - G(phi → G(neg psi)) ∈ W (since G(phi → G(neg psi)) ∈ G_theory M ⊆ f_preserving_seed)

            -- From G(phi → G(neg psi)) ∈ W and phi ∈ W:
            -- By T-axiom: (phi → G(neg psi)) ∈ W.
            -- By modus ponens with phi ∈ W: G(neg psi) ∈ W.

            -- But F(psi) = neg(G(neg psi)) ∈ W.
            -- So both G(neg psi) and neg(G(neg psi)) are in W.
            -- This contradicts W being consistent.

            -- Therefore, no MCS extends f_preserving_seed M phi.
            -- This means f_preserving_seed M phi is inconsistent!

            -- But we're trying to prove it's CONSISTENT. So we have a contradiction.

            -- Let me formalize this argument.

            -- h_G_imp : G(phi → G(neg psi)) ∈ M
            -- This means G(phi → G(neg psi)) ∈ G_theory M
            have h_G_imp_in_seed : Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi))) ∈ f_preserving_seed M phi := by
              apply G_theory_subset_f_preserving_seed
              simp only [G_theory, Set.mem_setOf_eq]
              exact ⟨phi.imp (Formula.neg (Formula.some_future psi)), rfl, h_G_imp⟩

            -- Now, the seed contains:
            -- - phi
            -- - G(phi → neg(F(psi)))
            -- - F(psi) (since F(psi) ∈ F_unresolved_theory M)

            -- We can derive bot from these!
            -- G(A → B) and A derive B (by T-axiom and modus ponens)
            -- So G(phi → G(neg psi)) and phi derive G(neg psi)
            -- And G(neg psi) and F(psi) derive bot (since F(psi) = neg(G(neg psi)))

            -- Let's construct this derivation
            have h_phi_in_seed : phi ∈ f_preserving_seed M phi := phi_in_f_preserving_seed M phi

            have h_Fpsi_in_seed : Formula.some_future psi ∈ f_preserving_seed M phi := by
              apply F_unresolved_subset_f_preserving_seed
              simp only [F_unresolved_theory, Set.mem_setOf_eq]
              exact ⟨psi, rfl, h_Fpsi_M, h_psi_not_M⟩

            -- Derivation: [G(phi → G(neg psi)), phi, F(psi)] ⊢ bot

            -- Step 1: T-axiom: G(phi → G(neg psi)) → (phi → G(neg psi))
            have h_T : [] ⊢ (Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))).imp
                (phi.imp (Formula.neg (Formula.some_future psi))) :=
              DerivationTree.axiom [] _ (Axiom.temp_t_future _)

            -- Step 2: From G(phi → G(neg psi)), derive phi → G(neg psi)
            have h_d1 : [Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))] ⊢
                phi.imp (Formula.neg (Formula.some_future psi)) :=
              DerivationTree.modus_ponens [_] _ _ (DerivationTree.weakening [] _ _ h_T (fun _ h => nomatch h))
                (DerivationTree.assumption _ _ (List.mem_singleton.mpr rfl))

            -- Step 3: From phi → G(neg psi) and phi, derive G(neg psi)
            have h_d2 : [phi, Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))] ⊢
                Formula.neg (Formula.some_future psi) := by
              apply DerivationTree.modus_ponens [phi, _] phi _
              · exact DerivationTree.weakening [_] [phi, _] _ h_d1 (fun x hx => by
                  simp only [List.mem_singleton] at hx
                  rw [hx]
                  exact List.mem_cons_of_mem _ (List.mem_singleton.mpr rfl))
              · exact DerivationTree.assumption _ _ (.head _)

            -- Step 4: G(neg psi) = neg(F(psi)), so G(neg psi) and F(psi) derive bot
            -- neg(F(psi)) and F(psi) derive bot via neg_elim
            have h_d3 : [Formula.some_future psi, phi, Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))] ⊢
                Formula.bot := by
              -- We have [phi, G(...)] ⊢ neg(F(psi))
              -- We want [F(psi), phi, G(...)] ⊢ bot
              apply DerivationTree.modus_ponens [_, phi, _] (Formula.some_future psi) Formula.bot
              · -- Need: [F(psi), phi, G(...)] ⊢ F(psi) → bot = neg(F(psi))
                -- But neg(F(psi)) = G(neg psi) = (psi.neg.all_future)
                -- Actually, F(psi) = (psi.neg.all_future.neg)
                -- So neg(F(psi)) = psi.neg.all_future
                -- And our h_d2 gives [phi, G(...)] ⊢ psi.neg.all_future
                have h_eq : Formula.neg (Formula.some_future psi) = (Formula.some_future psi).imp Formula.bot := rfl
                rw [h_eq] at h_d2
                exact DerivationTree.weakening [phi, _] [_, phi, _] _ h_d2 (fun x hx =>
                  List.mem_cons_of_mem _ hx)
              · exact DerivationTree.assumption _ _ (.head _)

            -- Now we have a derivation from a subset of f_preserving_seed to bot
            -- This contradicts consistency

            -- The list [F(psi), phi, G(phi → G(neg psi))] is a subset of f_preserving_seed
            have h_list_sub : ∀ x ∈ [Formula.some_future psi, phi,
                Formula.all_future (phi.imp (Formula.neg (Formula.some_future psi)))],
                x ∈ f_preserving_seed M phi := by
              intro x hx
              simp only [List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hx
              rcases hx with rfl | rfl | rfl
              · exact h_Fpsi_in_seed
              · exact h_phi_in_seed
              · exact h_G_imp_in_seed

            -- This is inconsistent!
            -- But wait, we're already in a proof by contradiction assuming
            -- f_preserving_seed is inconsistent. So finding another inconsistency
            -- doesn't help directly.

            -- Actually, wait. We started with L ⊆ f_preserving_seed with L ⊢ bot.
            -- We're trying to derive False (to show consistency).
            -- But we've now constructed a different proof of inconsistency!

            -- The issue is: the h_G_imp was derived using h_G_liftable, which used
            -- h_L_no_phi_standard, which might not hold for arbitrary L.

            -- Let me reconsider. We're in the case:
            -- - h_phi_L_no_F : phi ∈ L_no_F
            -- - h_L_no_phi_standard : L_no_phi ⊆ temporal_box_seed M
            -- - h_neg_G_phi : neg(G(phi)) ∈ M

            -- From h_L_no_phi_standard, we derived h_G_imp : G(phi → G(neg psi)) ∈ M.

            -- Now, G(phi → G(neg psi)) ∈ G_theory M ⊆ f_preserving_seed M phi.
            -- And phi ∈ f_preserving_seed.
            -- And F(psi) ∈ f_preserving_seed.

            -- So [F(psi), phi, G(phi → G(neg psi))] ⊆ f_preserving_seed with derivation to bot.

            -- This IS a witness of inconsistency, independent of our original L!

            -- Hmm, but this doesn't help us prove consistency. We're trying to prove
            -- consistency, not find more witnesses of inconsistency.

            -- Actually, wait. If we can construct an inconsistent subset of f_preserving_seed
            -- from our assumptions (h_Fpsi_M, h_phi_L_no_F, h_L_no_phi_standard, etc.),
            -- then f_preserving_seed IS inconsistent. But we're trying to prove it's consistent!

            -- So we have a problem: under the given hypotheses, f_preserving_seed is inconsistent.

            -- But the theorem claims f_preserving_seed IS consistent!

            -- Let me re-examine. The issue might be with the case structure.

            -- We have:
            -- - F(phi) ∈ M (hypothesis)
            -- - F(psi) ∈ F_unresolved_theory M (from case 2)
            -- - h_L_no_phi_standard : L_no_phi ⊆ temporal_box_seed M

            -- From these, we derived G(phi → G(neg psi)) ∈ M.

            -- Wait, but G(phi → G(neg psi)) was derived by G-lifting L_no_phi ⊢ phi → G(neg psi).
            -- And L_no_phi ⊢ phi → G(neg psi) came from extracting phi from L_no_F ⊢ G(neg psi).
            -- And L_no_F ⊢ G(neg psi) came from extracting F(psi) from L ⊢ bot.

            -- So G(phi → G(neg psi)) ∈ M is a consequence of assuming L ⊢ bot!

            -- And then we showed [F(psi), phi, G(phi → G(neg psi))] ⊢ bot.

            -- So from L ⊢ bot, we derived [F(psi), phi, G(...)] ⊢ bot.

            -- This is consistent! We assumed inconsistency, and derived inconsistency.
            -- It doesn't give us the contradiction we need.

            -- The issue is: we need to show that the ASSUMPTION L ⊢ bot leads to contradiction.
            -- Simply deriving another inconsistent subset doesn't contradict anything.

            -- OK I think I see the issue now. The whole proof by contradiction is:
            -- Assume ∃ L ⊆ f_preserving_seed with L ⊢ bot. Derive False.

            -- We've been trying to derive False by showing G(neg psi) ∈ M contradicts F(psi) ∈ M.
            -- But in this branch (h_neg_G_phi), we can't show G(neg psi) ∈ M.

            -- The other route we tried (constructing [F(psi), phi, G(...)] ⊢ bot) doesn't help
            -- because that's just another way of witnessing inconsistency, not a contradiction.

            -- I think we need a different approach entirely.

            -- Maybe strong induction on the number of elements in L?
            -- Or on the number of non-G-liftable elements?

            -- ARCHIVED: sub-case A unprovable (phi BEFORE psi ordering)
            -- The semantic argument shows this is genuinely unprovable:
            -- "eventually phi AND eventually psi" is consistent when psi holds BEFORE phi.
            -- The deduction approach produces G(phi) -> G(neg psi) in M, but G(phi) not in M
            -- means the implication is vacuously true, yielding no contradiction.
            -- Superseded by bidirectional_temporal_box_seed approach (Phase 1-3 of plan v4).
            sorry

        · -- L_no_phi has elements from F_unresolved_theory M (not all from temporal_box_seed)
          -- ARCHIVED: sub-case B unprovable (requires induction that doesn't close)
          -- Superseded by bidirectional_temporal_box_seed approach which avoids
          -- F_unresolved_theory entirely.
          sorry

      · -- phi ∉ L_no_F: all elements of L_no_F are in M
        -- L_no_F ⊆ M since phi ∉ L_no_F and all other elements are in M
        have h_L_no_F_in_M : ∀ x ∈ L_no_F, x ∈ M := by
          intro x hx
          have hx_ne_phi : x ≠ phi := fun h_eq => by
            rw [h_eq] at hx
            exact h_phi_L_no_F hx
          -- x ∈ L_no_F and x ≠ phi and x ≠ F(psi)
          have hx_seed := h_L_no_F_sub x hx
          simp only [f_preserving_seed, Set.mem_union] at hx_seed
          rcases hx_seed with (h | h) | h
          · simp only [Set.mem_singleton_iff] at h; exact absurd h hx_ne_phi
          · simp only [temporal_box_seed, Set.mem_union] at h
            rcases h with hG | hBox
            · simp only [G_theory, Set.mem_setOf_eq] at hG
              obtain ⟨a, rfl, ha⟩ := hG; exact ha
            · exact box_theory_subset_mcs M h_mcs hBox
          · simp only [F_unresolved_theory, Set.mem_setOf_eq] at h
            obtain ⟨sigma, rfl, h_Fsigma_M, _⟩ := h; exact h_Fsigma_M

        -- L_no_F ⊢ neg(F(psi)) and L_no_F ⊆ M, so neg(F(psi)) ∈ M
        have h_neg_F_psi_M : Formula.neg (Formula.some_future psi) ∈ M :=
          SetMaximalConsistent.closed_under_derivation h_mcs L_no_F h_L_no_F_in_M d_neg_F

        -- neg(F(psi)) ∈ M and F(psi) ∈ M contradicts MCS consistency
        -- F(psi) and neg(F(psi)) form an inconsistent pair
        exact set_consistent_not_both h_mcs.1 (Formula.some_future psi) h_Fpsi_M h_neg_F_psi_M

/--
F-preserving temporal witness theorem:
If F(phi) ∈ M (MCS), there exists MCS W with:
1. phi ∈ W
2. G_theory agreement: G(a) ∈ M → G(a) ∈ W
3. box_class_agree M W
4. **NEW**: F_unresolved preservation: F(psi) ∈ M ∧ psi ∉ M → F(psi) ∈ W

This strengthens temporal_theory_witness_exists by ensuring that unresolved
F-obligations are preserved in the witness.

**DEAD CODE**: This theorem depends on `f_preserving_seed_consistent` which is FALSE.
See Task #69 counterexample. Use the separate-direction construction in SuccChainFMCS.lean.
-/
theorem temporal_theory_witness_F_preserving (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W ∧
      (∀ psi, Formula.some_future psi ∈ M ∧ psi ∉ M → Formula.some_future psi ∈ W) := by
  -- Use f_preserving_seed_consistent to show the seed is consistent
  have h_cons := f_preserving_seed_consistent M h_mcs phi h_F
  -- Apply Lindenbaum to get MCS W extending the seed
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (f_preserving_seed M phi) h_cons
  use W, h_W_mcs
  refine ⟨?_, ?_, ?_, ?_⟩

  · -- phi ∈ W
    exact h_extends (phi_in_f_preserving_seed M phi)

  · -- G_theory agreement: G(a) ∈ M → G(a) ∈ W
    intro a ha
    have h_in_seed : Formula.all_future a ∈ G_theory M := by
      simp only [G_theory, Set.mem_setOf_eq]
      exact ⟨a, rfl, ha⟩
    exact h_extends (G_theory_subset_f_preserving_seed M phi h_in_seed)

  · -- box_class_agree M W
    intro psi
    constructor
    · intro h_box
      have h_in_seed : Formula.box psi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨psi, rfl, h_box⟩
      exact h_extends (box_theory_subset_f_preserving_seed M phi h_in_seed)
    · intro h_box_W
      by_contra h_not_in_M
      have h_neg_in_seed : Formula.neg (Formula.box psi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨psi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box psi) ∈ W :=
        h_extends (box_theory_subset_f_preserving_seed M phi h_neg_in_seed)
      exact set_consistent_not_both h_W_mcs.1 (Formula.box psi) h_box_W h_neg_in_W

  · -- F_unresolved preservation: F(psi) ∈ M ∧ psi ∉ M → F(psi) ∈ W
    intro psi ⟨h_Fpsi, h_psi_not⟩
    have h_in_F_unresolved : Formula.some_future psi ∈ F_unresolved_theory M := by
      simp only [F_unresolved_theory, Set.mem_setOf_eq]
      exact ⟨psi, rfl, h_Fpsi, h_psi_not⟩
    exact h_extends (F_unresolved_subset_f_preserving_seed M phi h_in_F_unresolved)


-- END ARCHIVED CODE
