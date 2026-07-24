import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition

/-!
# ARCHIVED (Boneyard) — never compiled.

Dead tail of `Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`: 24
declarations carrying the file's 3 statement-position sorries, with zero
external call sites (every consumer of each declaration below is itself a
member of this closure). The chain top `stavi_expressive_completeness`
(GHR93 Theorem 9.3.1) had zero code consumers: `PriorExpressiveness.lean`
bypasses the sorry-tainted chain entirely via
`kamp_prior_expressive_completeness` (Kamp/Rabinovich 2014), and the sole
former consumer of `stavi_expressive_completeness` was removed there.

The closure is the audited 16-declaration tail (two pre-tail orphan-guards
`nf_base_sf_correct` and `nf_exist_sf_forward` included) enlarged to its
consumer fixpoint with 8 exclusively-consumed helpers
(`sf_disj_iff`, `sf_top_iff`, `sf_atom_literal_iff`, `sf_disjList_iff`,
`sf_conjList_iff`, `atomKind_to_sf_literal_correct`, `nf_base_sf`,
`zone_match_witness`) whose only consumers are members of this closure.

Archived declarations (original file order):
- `sf_disj_iff`, `sf_disjList_iff` (disjunction combinator lemmas)
- `sf_top_iff`, `sf_conjList_iff` (conjunction combinator lemmas)
- `sf_atom_literal_iff`, `atomKind_to_sf_literal_correct`
- `nf_base_sf`, `nf_base_sf_correct` (base-case NF characterization)
- `nf_exist_sf_forward` (forward direction of the existence formula)
- `nf_fraisse_compression`, `zone_match_witness`, `atom_agree_from_pointwise`
- `nf_2var_existential_transfer` (2 sorries), `nf_2var_from_interval_data`,
  `nf_2var_transfer` (GHR93 bridge chain)
- `interval_guard_sf`, `interval_guard_sf_true`, `nf_exist_sf_guarded`,
  `nf_exist_sf_guarded_forward`, `nf_exist_sf_guarded_backward` (1 sorry;
  mathematically FALSE as stated per independent verification)
- `nf_2var_exist_sf_classical`, `nf_2var_existence_characterizable`
- `nf_characterizable_by_stavi`, `stavi_expressive_completeness`

The live keep-set (standard translation `stavi_table_mu`, combinator defs
`sf_disj`/`sf_disjList`/`sf_top`/`sf_conjList`/`sf_atom_literal`/
`atomKind_to_sf_literal`, existence-formula defs `nf_exist_sf`/`nf_succ_sf`,
and the interval-data lemmas `interval_nf_types` through
`below_min_depth_decrease`) remains in the live file.

Do not import from live code.
-/

#exit

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean
   Original context: `namespace Bimodal.Metalogic.WeakCanonical`,
   `open Bimodal.Syntax`.
   ====================================================================== -/

/- ---------------------------------------------------------------------
   Original file-level narrative for the archived main theorem
   --------------------------------------------------------------------- -/

/-! ## Stavi Expressive Completeness

The main theorem: {U, S, U', S'} is expressively complete for ALL linear
temporal structures.

For any monadic FO sentence phi of quantifier depth ≤ k, there exists a
StaviFormula A such that for all ordered monadic structures M and points t:

  stavi_temporal_truth M atomMap t A ↔ eval M (fun _ => t) phi

### Proof Strategy (GHR93)

The proof uses the custom EF games to show that if two pointed structures
(M, t) and (N, s) agree on all StaviFormulas of a certain depth, then
Duplicator wins the corresponding EF game, hence they satisfy the same
FO sentences up to that depth. The four cases of the main induction
correspond to different structural configurations:

- Case I: The structures can be distinguished by atoms/order at the
  selected points → use base temporal formulas.
- Case II: There is a standard Until witness → use U.
- Case III: There is a standard Since witness → use S.
- Case IV: The structure has a gap → use U' or S'.

The full proof is ~1000-1500 lines and requires the game infrastructure
defined above. It is the single largest formalization effort in the
Reynolds pipeline.
-/

/- ---------------------------------------------------------------------
   From section: StaviFormula Disjunction Combinator
   --------------------------------------------------------------------- -/

private theorem sf_disj_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (A B : StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_disj A B) ↔
    (stavi_temporal_truth M atomMap t A ∨ stavi_temporal_truth M atomMap t B) := by
  simp only [sf_disj, stavi_temporal_truth]; tauto

theorem sf_disjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (l : List StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_disjList l) ↔
    (∃ A ∈ l, stavi_temporal_truth M atomMap t A) := by
  induction l with
  | nil =>
    simp only [sf_disjList, stavi_temporal_truth, temporal_truth]
    constructor
    · exact False.elim
    · rintro ⟨A, ⟨⟩, _⟩
  | cons a as ih =>
    cases as with
    | nil =>
      simp only [sf_disjList, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h => ⟨a, rfl, h⟩, fun ⟨_, rfl, h⟩ => h⟩
    | cons b bs =>
      simp only [sf_disjList]
      rw [sf_disj_iff]
      constructor
      · rintro (ha | hrest)
        · exact ⟨a, List.Mem.head _, ha⟩
        · obtain ⟨A, hA, h⟩ := ih.mp hrest
          exact ⟨A, List.Mem.tail a hA, h⟩
      · rintro ⟨A, hA, h⟩
        cases hA with
        | head => exact Or.inl h
        | tail _ hA => exact Or.inr (ih.mpr ⟨A, hA, h⟩)

/- ---------------------------------------------------------------------
   From section: StaviFormula Conjunction Combinator
   --------------------------------------------------------------------- -/

private theorem sf_top_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier) :
    stavi_temporal_truth M atomMap t sf_top ↔ True := by
  simp only [sf_top, stavi_temporal_truth, temporal_truth, Formula.top]; tauto

theorem sf_conjList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (l : List StaviFormula) :
    stavi_temporal_truth M atomMap t (sf_conjList l) ↔
    (∀ A ∈ l, stavi_temporal_truth M atomMap t A) := by
  induction l with
  | nil =>
    simp only [sf_conjList]
    rw [sf_top_iff]
    constructor
    · intro _ A hA; simp at hA
    · intro _; trivial
  | cons a as ih =>
    cases as with
    | nil =>
      simp only [sf_conjList, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h A hA => hA ▸ h, fun h => h a rfl⟩
    | cons b bs =>
      simp only [sf_conjList, stavi_temporal_truth]
      constructor
      · rintro ⟨ha, hrest⟩ A hA
        cases hA with
        | head => exact ha
        | tail _ hA => exact (ih.mp hrest) A hA
      · intro h
        exact ⟨h a (List.Mem.head _), ih.mpr (fun A hA => h A (List.Mem.tail a hA))⟩

/- ---------------------------------------------------------------------
   From section: Atom Literal StaviFormula
   --------------------------------------------------------------------- -/

private theorem sf_atom_literal_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (a : Atom) (val : Bool) :
    stavi_temporal_truth M atomMap t (sf_atom_literal a val) ↔
    (M.interp (atomMap (.atom a)) t ↔ val = true) := by
  cases val <;> simp [sf_atom_literal, stavi_temporal_truth, temporal_truth]

/- ---------------------------------------------------------------------
   From section: Base-case NF characterization helpers
   --------------------------------------------------------------------- -/

/-- Correctness of atomKind_to_sf_literal. -/
theorem atomKind_to_sf_literal_correct
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (ak : AtomKind sig 1) (val : Bool) :
    stavi_temporal_truth M atomMap t (atomKind_to_sf_literal atomMap h_surj ak val) ↔
    (atom_eval M (fun _ => t) ak ↔ val = true) := by
  match ak with
  | .pred p i =>
    simp only [atomKind_to_sf_literal]
    have h_spec := Classical.choose_spec (h_surj p)
    -- h_spec : atomMap (Formula.atom (Classical.choose (h_surj p))) = p
    rw [sf_atom_literal_iff]
    -- Goal: (M.interp (atomMap (.atom (Classical.choose ...))) t ↔ val = true) ↔
    --       (atom_eval M (fun _ => t) (.pred p i) ↔ val = true)
    show (M.interp (atomMap (.atom (Classical.choose (h_surj p)))) t ↔ val = true) ↔
         (M.interp p ((fun _ : Fin 1 => t) i) ↔ val = true)
    simp only [h_spec]
  | .order i j h =>
    exact absurd (Fin.ext_iff.mpr (by omega : i.val = j.val)) h

/-- Build a StaviFormula characterizing a depth-0 NormalForm with 1 variable.
    Constructs a conjunction of atom literals over all AtomKind sig 1 elements. -/
noncomputable def nf_base_sf
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1) : StaviFormula :=
  let atoms := (Fintype.elems (α := AtomKind sig 1)).val.toList
  sf_conjList (atoms.map (fun ak => atomKind_to_sf_literal atomMap h_surj ak (nf ak)))

/-- The base StaviFormula correctly characterizes the depth-0 NF. -/
theorem nf_base_sf_correct
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1)
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    stavi_temporal_truth M atomMap t (nf_base_sf atomMap h_surj nf) ↔
    nf_eval_nf M 0 1 (fun _ => t) nf := by
  simp only [nf_base_sf, nf_eval_nf]
  rw [sf_conjList_iff]
  constructor
  · -- Forward: all literals hold → all atom_eval's match
    intro h_all ak
    have h_in_list : ak ∈ (Fintype.elems (α := AtomKind sig 1)).val.toList :=
      Multiset.mem_toList.mpr (Fintype.complete ak)
    have h_mem : atomKind_to_sf_literal atomMap h_surj ak (nf ak) ∈
        (Fintype.elems (α := AtomKind sig 1)).val.toList.map
          (fun ak' => atomKind_to_sf_literal atomMap h_surj ak' (nf ak')) :=
      List.mem_map.mpr ⟨ak, h_in_list, rfl⟩
    exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf ak)).mp
      (h_all _ h_mem)
  · -- Backward: all atom_eval's match → all literals hold
    intro h_nf A hA
    rw [List.mem_map] at hA
    obtain ⟨ak, _, rfl⟩ := hA
    exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf ak)).mpr
      (h_nf ak)

/- ---------------------------------------------------------------------
   Forward Direction section (removed whole)
   --------------------------------------------------------------------- -/

/-! ## Forward Direction: NF Existence → Temporal Formula Truth

Given a witness x such that the 2-variable depth-k NF of (x, t) equals sub_nf,
show that the existence formula nf_exist_sf holds at t. -/

/-- Forward direction of nf_exist_sf: if ∃x with the right 2-var NF, the temporal
    formula holds. This is the EASIER direction — the backward direction requires
    the full game-theoretic argument. -/
private theorem nf_exist_sf_forward
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_ex : ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    stavi_temporal_truth M atomMap t
      (nf_exist_sf atomMap h_surj k char_k parent_atoms sub_nf) := by
  obtain ⟨x, h_x⟩ := h_ex
  -- Step 1: Extract atom information from h_x
  -- The atoms of the 2-variable NF tell us:
  -- - predicates at x (variable 0)
  -- - predicates at t (variable 1)
  -- - order between x and t
  have h_x_atoms : ∀ (a : AtomKind sig (1 + 1)),
      atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.atom_assgn a = true := by
    cases k with
    | zero => exact h_x
    | succ k' => exact h_x.1
  -- Step 2: t-consistency holds
  have h_t_cons : nf_t_consistent parent_atoms sub_nf = true := by
    simp only [nf_t_consistent]
    rw [List.all_eq_true]
    intro p _
    -- sub_nf's pred at variable 1 should match parent_atoms' pred at variable 0
    simp only [beq_iff_eq]
    -- The atom at (.pred p 1) in sub_nf matches the atom evaluation at t
    have h_sub_t := h_x_atoms (.pred p ⟨1, by omega⟩)
    have h_par := h_atoms (.pred p ⟨0, by omega⟩)
    -- atom_eval M (Fin.cons x (fun _ => t)) (.pred p 1) = M.interp p ((Fin.cons x (fun _ => t)) 1)
    -- and (Fin.cons x (fun _ => t)) 1 = t, so both reduce to M.interp p t
    -- Use the fact that atom_eval (.pred p i) = M.interp p (env i)
    simp only [atom_eval] at h_sub_t h_par
    -- h_sub_t : M.interp p ((Fin.cons x fun _ => t) 1) ↔ sub_nf.atom_assgn (.pred p 1) = true
    -- h_par : M.interp p t ↔ parent_atoms (.pred p 0) = true
    -- (Fin.cons x (fun _ => t)) ⟨1, ...⟩ = (fun _ => t) ⟨0, ...⟩ = t
    have h_env_1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [h_env_1] at h_sub_t
    -- Now both are about M.interp p t
    cases h1 : sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) <;>
    cases h2 : parent_atoms (.pred p ⟨0, by omega⟩) <;>
    simp_all
  -- Step 3: Unfold nf_exist_sf with the consistency check passing
  simp only [nf_exist_sf, h_t_cons, not_true, ↓reduceIte, ite_not]
  -- Step 4: Order consistency (not both x < t and t < x)
  have h_x_lt_t := h_x_atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  have h_t_lt_x := h_x_atoms (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  simp only [atom_eval, Fin.cons] at h_x_lt_t h_t_lt_x
  -- Order atoms correctly reflect the actual order between x and t
  have h_order_compat : ¬ (sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
      sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true := by
    intro h_both
    rw [Bool.and_eq_true] at h_both
    have hxt : x < t := h_x_lt_t.mpr h_both.1
    have htx : t < x := h_t_lt_x.mpr h_both.2
    exact absurd (lt_trans hxt htx) (lt_irrefl _)
  simp only [h_order_compat, ite_false]
  -- The 1-variable depth-k NF of x
  set nf_x := nf_characteristic M k 1 (fun _ => x) with nf_x_def
  have h_nf_x : nf_eval_nf M k 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M k 1 (fun _ => x)
  -- The IH formula for nf_x holds at x
  have h_char_at_x : stavi_temporal_truth M atomMap x (char_k nf_x) :=
    (char_k_correct nf_x M x).mpr h_nf_x
  -- Key lemma: Fin.cons evaluations
  -- Fin.cons x f reduces via Fin.cases; we need explicit eval lemmas
  have h_fc0 : Fin.cases x (fun _ : Fin 1 => t) (⟨0, by omega⟩ : Fin 2) = x := by
    simp [Fin.cases]
  have h_fc1 : Fin.cases x (fun _ : Fin 1 => t) (⟨1, by omega⟩ : Fin 2) = t := by
    simp [Fin.cases]; rfl
  -- Simplify the order hypotheses to use x and t directly
  rw [h_fc0, h_fc1] at h_x_lt_t
  rw [h_fc1, h_fc0] at h_t_lt_x
  -- h_x_lt_t : x < t ↔ sub_nf.atom_assgn (.order 0 1 ...) = true
  -- h_t_lt_x : t < x ↔ sub_nf.atom_assgn (.order 1 0 ...) = true
  -- nf_x is atom-compatible with sub_nf at variable 0
  have h_compat : ∀ p : sig.preds,
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) =
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩) := by
    intro p
    -- nf_x.atom_assgn (.pred p 0) = decide (M.interp p x)  (by nf_characteristic def)
    -- sub_nf.atom_assgn (.pred p 0) = decide (M.interp p x) (via h_x_atoms and Fin.cons 0 = x)
    -- nf_x has 1 variable, so AtomKind sig 1 uses Fin 1
    -- sub_nf has 2 variables, so AtomKind sig 2 uses Fin 2
    -- Both .pred p 0 refer to variable 0 in their respective Fin types
    have h_nf_x_p : atom_eval M (fun _ => x) (.pred p (0 : Fin 1)) ↔
        (nf_x.atom_assgn (.pred p (0 : Fin 1)) = true) := by
      cases k with
      | zero => exact h_nf_x (.pred p 0)
      | succ k' => exact h_nf_x.1 (.pred p 0)
    have h_sub_p := h_x_atoms (.pred p (0 : Fin 2))
    simp only [atom_eval] at h_nf_x_p h_sub_p
    -- Fin.cons x (fun _ => t) at Fin 2 index 0 = x
    have h_fc0' : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) (0 : Fin 2) = x := by
      simp [Fin.cons]
    rw [h_fc0'] at h_sub_p
    -- Now both are about M.interp p x
    cases h1 : nf_x.atom_assgn (.pred p (0 : Fin 1)) <;>
    cases h2 : sub_nf.atom_assgn (.pred p (0 : Fin 2)) <;>
    simp_all
  -- Prove the compat_formulas filter condition
  have h_compat_filter : (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) = true := by
    rw [List.all_eq_true]
    intro p _
    simp only [beq_iff_eq]
    exact h_compat p
  -- char_k nf_x is in the filterMap list
  have h_in_list : char_k nf_x ∈ (Fintype.elems (α := NormalForm sig k 1)).val.toList.filterMap
      (fun nf_x' => if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
        nf_x'.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) = true
      then some (char_k nf_x') else none) := by
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x),
      by rw [if_pos h_compat_filter]⟩
  -- The proof needs to:
  -- 1. Case-split on nf_order_0_1 sub_nf (Until/Since/equality direction)
  -- 2. Use x as the temporal witness (x > t for Until, x < t for Since, x = t for equality)
  -- 3. Show sf_disjList holds at x via h_in_list and h_char_at_x
  -- 4. The sf_top guard is trivially satisfied
  --
  -- The core difficulty is matching Lean's internal representation of the
  -- nf_exist_sf definition (which unfolds nf_order_0_1 into a nested match)
  -- with the structural proof. The proof requires careful definitional
  -- unfolding and Fin subtype matching.
  norm_num
  have h_in_list' : char_k nf_x ∈ List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) = sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList := by
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x), by
      rw [if_pos]; intro p hp; exact h_compat p⟩
  have h_disj_at_x : stavi_temporal_truth M atomMap x (sf_disjList (List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) = sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList)) := by
    rw [sf_disjList_iff]
    exact ⟨char_k nf_x, h_in_list', h_char_at_x⟩
  match h_b1 : sub_nf.atom_assgn (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_b2 : sub_nf.atom_assgn (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, false =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_t_lt_x.mpr h_b1, h_disj_at_x, fun u _ _ => (sf_top_iff M atomMap u).mpr trivial⟩
  | false, true =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_x_lt_t.mpr h_b2, h_disj_at_x, fun u _ _ => (sf_top_iff M atomMap u).mpr trivial⟩
  | false, false =>
    simp only [nf_order_0_1, h_b1, h_b2, and_self, ↓reduceIte]
    have h_eq : x = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h | h
      · exact absurd (h_x_lt_t.mp h) (by simp_all)
      · exact absurd (h_t_lt_x.mp h) (by simp_all)
    rw [← h_eq]; exact h_disj_at_x
  | true, true =>
    exfalso
    exact h_order_compat (by rw [Bool.and_eq_true]; exact ⟨h_b2, h_b1⟩)

/- ---------------------------------------------------------------------
   GHR93 bridge tail through the main theorem (removed whole)
   --------------------------------------------------------------------- -/

/-- **Fraïssé compression lemma**: If two n-variable environments agree on atoms
    AND the existential transfer holds at each depth j < k (i.e., for each
    depth-j (n+1)-var NF, realizability by an extension is the same in both
    models), then the depth-k n-var NFs are equal.

    This is the key compression principle: k rounds of successful quantifier
    matching (at depths 0, ..., k-1) compress into depth-k NF agreement.
    It is a direct consequence of the structure of nf_characteristic. -/
theorem nf_fraisse_compression {sig : MonadicSignature}
    (k n : Nat)
    (M : OrderedMonadicStructure sig) (env_M : Fin n → M.carrier)
    (M' : OrderedMonadicStructure sig) (env_M' : Fin n → M'.carrier)
    (h_atoms : ∀ a : AtomKind sig n, atom_eval M env_M a ↔ atom_eval M' env_M' a)
    (h_transfer : ∀ j, j < k →
      ∀ chi : NormalForm sig j (n + 1),
        (∃ u, nf_eval_nf M j (n + 1) (Fin.cons u env_M) chi) ↔
        (∃ u', nf_eval_nf M' j (n + 1) (Fin.cons u' env_M') chi)) :
    nf_characteristic M k n env_M = nf_characteristic M' k n env_M' := by
  apply nf_eval_unique M' k n env_M'
  · -- M' satisfies M's characteristic NF
    induction k with
    | zero =>
      -- Depth-0: atom agreement
      have hM := nf_characteristic_satisfies M 0 n env_M
      intro a; constructor
      · intro ha'; exact (hM a).mp ((h_atoms a).mpr ha')
      · intro ha; exact (h_atoms a).mp ((hM a).mpr ha)
    | succ k ih =>
      -- Depth-(k+1): atoms + quantifier
      have hM := nf_characteristic_satisfies M (k + 1) n env_M
      obtain ⟨hM_atoms, hM_quant⟩ := hM
      constructor
      · -- Atoms
        intro a; constructor
        · intro ha'; exact (hM_atoms a).mp ((h_atoms a).mpr ha')
        · intro ha; exact (h_atoms a).mp ((hM_atoms a).mpr ha)
      · -- Quantifier: use h_transfer at depth k
        intro sub_nf
        rw [← hM_quant sub_nf]
        exact (h_transfer k (Nat.lt_succ_iff.mpr (Nat.le_refl k)) sub_nf).symm
  · exact nf_characteristic_satisfies M' k n env_M'

/-- Zone matching: given u in M, find u' in M' with the same depth-k 1-var NF
    and the same orderings relative to x' and t'. The five zones are:
    (1) u < min(x,t), (2) u = x, (3) between x and t, (4) u = t, (5) u > max(x,t).
    Each zone's matching uses the corresponding hypothesis. -/
theorem zone_match_witness {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M M' : OrderedMonadicStructure sig}
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier) (u : M.carrier)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
    (h_interval_above : t < x →
      interval_nf_types M k t x = interval_nf_types M' k t' x')
    (h_interval_below : x < t →
      interval_nf_types M k x t = interval_nf_types M' k x' t')
    (h_above_max : (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u))
    (h_below_min : (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u)) :
    ∃ u' : M'.carrier,
      nf_characteristic M k 1 (fun _ => u) =
        nf_characteristic M' k 1 (fun _ => u') ∧
      (u < x ↔ u' < x') ∧ (x < u ↔ x' < u') ∧
      (u < t ↔ u' < t') ∧ (t < u ↔ t' < u') := by
  -- Determine u's zone relative to (x, t)
  set tau := nf_characteristic M k 1 (fun _ => u) with tau_def
  have h_tau_sat := nf_characteristic_satisfies M k 1 (fun _ => u)
  -- Case 1: u = x
  by_cases hux : u = x
  · subst hux
    exact ⟨x', h_nf_x,
      iff_of_false (lt_irrefl _) (lt_irrefl _),
      iff_of_false (lt_irrefl _) (lt_irrefl _),
      h_order_xt.1, h_order_xt.2⟩
  -- Case 2: u = t
  by_cases hut : u = t
  · subst hut
    exact ⟨t', h_nf_t,
      h_order_xt.2, h_order_xt.1,
      iff_of_false (lt_irrefl _) (lt_irrefl _),
      iff_of_false (lt_irrefl _) (lt_irrefl _)⟩
  -- u ≠ x and u ≠ t. By linear order trichotomy, u < x or x < u.
  -- Also u < t or t < u.
  have hux_lt_or_gt : u < x ∨ x < u := by
    rcases lt_trichotomy u x with h | h | h
    · exact Or.inl h
    · exact absurd h hux
    · exact Or.inr h
  have hut_lt_or_gt : u < t ∨ t < u := by
    rcases lt_trichotomy u t with h | h | h
    · exact Or.inl h
    · exact absurd h hut
    · exact Or.inr h
  -- Case 3: u < min(x,t) (below both)
  by_cases h_below : u < min x t
  · have h_tau_below : ∃ v, v < min x t ∧ nf_eval_nf M k 1 (fun _ => v) tau :=
      ⟨u, h_below, h_tau_sat⟩
    have h_transfer : (∃ v, v < min x t ∧ nf_eval_nf M k 1 (fun _ => v) tau) ↔
        (∃ v', v' < min x' t' ∧ nf_eval_nf M' k 1 (fun _ => v') tau) :=
      Iff.of_eq (congr_fun h_below_min tau)
    obtain ⟨u', hu'_min, hu'_tau⟩ := h_transfer.mp h_tau_below
    have hu'_lt_x' : u' < x' := lt_of_lt_of_le hu'_min (min_le_left x' t')
    have hu'_lt_t' : u' < t' := lt_of_lt_of_le hu'_min (min_le_right x' t')
    have hu_lt_x : u < x := lt_of_lt_of_le h_below (min_le_left x t)
    have hu_lt_t : u < t := lt_of_lt_of_le h_below (min_le_right x t)
    refine ⟨u', ?_, ?_, ?_, ?_, ?_⟩
    · exact nf_eval_unique M' k 1 (fun _ => u')
        tau (nf_characteristic M' k 1 (fun _ => u')) hu'_tau
        (nf_characteristic_satisfies M' k 1 (fun _ => u'))
    · exact ⟨fun _ => hu'_lt_x', fun _ => hu_lt_x⟩
    · exact ⟨fun h => absurd h (not_lt.mpr (le_of_lt hu_lt_x)),
             fun h => absurd h (not_lt.mpr (le_of_lt hu'_lt_x'))⟩
    · exact ⟨fun _ => hu'_lt_t', fun _ => hu_lt_t⟩
    · exact ⟨fun h => absurd h (not_lt.mpr (le_of_lt hu_lt_t)),
             fun h => absurd h (not_lt.mpr (le_of_lt hu'_lt_t'))⟩
  -- Case 4: u > max(x,t) (above both)
  by_cases h_above : max x t < u
  · have h_tau_above : ∃ v, max x t < v ∧ nf_eval_nf M k 1 (fun _ => v) tau :=
      ⟨u, h_above, h_tau_sat⟩
    have h_transfer : (∃ v, max x t < v ∧ nf_eval_nf M k 1 (fun _ => v) tau) ↔
        (∃ v', max x' t' < v' ∧ nf_eval_nf M' k 1 (fun _ => v') tau) :=
      Iff.of_eq (congr_fun h_above_max tau)
    obtain ⟨u', hu'_max, hu'_tau⟩ := h_transfer.mp h_tau_above
    have hu'_gt_x' : x' < u' := lt_of_le_of_lt (le_max_left x' t') hu'_max
    have hu'_gt_t' : t' < u' := lt_of_le_of_lt (le_max_right x' t') hu'_max
    have hu_gt_x : x < u := lt_of_le_of_lt (le_max_left x t) h_above
    have hu_gt_t : t < u := lt_of_le_of_lt (le_max_right x t) h_above
    refine ⟨u', ?_, ?_, ?_, ?_, ?_⟩
    · exact nf_eval_unique M' k 1 (fun _ => u')
        tau (nf_characteristic M' k 1 (fun _ => u')) hu'_tau
        (nf_characteristic_satisfies M' k 1 (fun _ => u'))
    · exact ⟨fun h => absurd h (not_lt.mpr (le_of_lt hu_gt_x)),
             fun h => absurd h (not_lt.mpr (le_of_lt hu'_gt_x'))⟩
    · exact ⟨fun _ => hu'_gt_x', fun _ => hu_gt_x⟩
    · exact ⟨fun h => absurd h (not_lt.mpr (le_of_lt hu_gt_t)),
             fun h => absurd h (not_lt.mpr (le_of_lt hu'_gt_t'))⟩
    · exact ⟨fun _ => hu'_gt_t', fun _ => hu_gt_t⟩
  -- Case 5: u is in the interval between x and t (not below min, not above max,
  -- not equal to either). By case analysis on x < t vs t < x.
  push_neg at h_below h_above
  -- Since u is not below min and not above max, u is between x and t.
  -- We need to know which way the interval goes.
  rcases hux_lt_or_gt with hux_lt | hux_gt
  · -- u < x, but not below min. Since min ≤ u, and u < x, we have t ≤ u < x.
    -- So t ≤ u and u < x. Since u ≠ t, we have t < u.
    rcases hut_lt_or_gt with hut_lt | hut_gt
    · -- u < t and u < x: u < min(x,t), contradicts h_below
      exact absurd (lt_min hux_lt hut_lt) (not_lt.mpr h_below)
    · -- t < u < x: u is in the interval (t, x)
      have h_tau_interval : tau ∈ interval_nf_types M k t x := by
        simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and]
        exact ⟨u, hut_gt, hux_lt, h_tau_sat⟩
      rw [h_interval_above (lt_trans hut_gt hux_lt)] at h_tau_interval
      simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and] at h_tau_interval
      obtain ⟨u', ht'u', hu'x', hu'_tau⟩ := h_tau_interval
      refine ⟨u', ?_, ?_, ?_, ?_, ?_⟩
      · exact nf_eval_unique M' k 1 (fun _ => u')
          tau (nf_characteristic M' k 1 (fun _ => u')) hu'_tau
          (nf_characteristic_satisfies M' k 1 (fun _ => u'))
      · exact ⟨fun _ => hu'x', fun _ => hux_lt⟩
      · exact ⟨fun h => absurd hux_lt (not_lt.mpr (le_of_lt h)),
               fun h => absurd hu'x' (not_lt.mpr (le_of_lt h))⟩
      · exact ⟨fun h => absurd hut_gt (not_lt.mpr (le_of_lt h)),
               fun h => absurd ht'u' (not_lt.mpr (le_of_lt h))⟩
      · exact ⟨fun _ => ht'u', fun _ => hut_gt⟩
  · -- x < u, but not above max. Since u ≤ max, and x < u, we have x < u ≤ max(x,t).
    rcases hut_lt_or_gt with hut_lt | hut_gt
    · -- x < u < t: u is in the interval (x, t)
      have h_tau_interval : tau ∈ interval_nf_types M k x t := by
        simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and]
        exact ⟨u, hux_gt, hut_lt, h_tau_sat⟩
      rw [h_interval_below (lt_trans hux_gt hut_lt)] at h_tau_interval
      simp only [interval_nf_types, Finset.mem_filter, Finset.mem_univ, true_and] at h_tau_interval
      obtain ⟨u', hx'u', hu't', hu'_tau⟩ := h_tau_interval
      refine ⟨u', ?_, ?_, ?_, ?_, ?_⟩
      · exact nf_eval_unique M' k 1 (fun _ => u')
          tau (nf_characteristic M' k 1 (fun _ => u')) hu'_tau
          (nf_characteristic_satisfies M' k 1 (fun _ => u'))
      · exact ⟨fun h => absurd hux_gt (not_lt.mpr (le_of_lt h)),
               fun h => absurd hx'u' (not_lt.mpr (le_of_lt h))⟩
      · exact ⟨fun _ => hx'u', fun _ => hux_gt⟩
      · exact ⟨fun _ => hu't', fun _ => hut_lt⟩
      · exact ⟨fun h => absurd hut_lt (not_lt.mpr (le_of_lt h)),
               fun h => absurd hu't' (not_lt.mpr (le_of_lt h))⟩
    · -- x < u and t < u: u > max(x,t), contradicts h_above
      exact absurd (max_lt hux_gt hut_gt) (not_lt.mpr h_above)

/-! ### GHR93 Proposition 7: Multi-arity NF Transfer

The transfer argument requires proving existential transfer at ALL arities
simultaneously, because the quantifier component at arity n requires transfer
at arity n+1 and one lower depth. The recursion terminates because depth
strictly decreases and reaches 0, where only atoms matter.

**GHR93 Proposition 7 / GHR94 Proposition 12.8.18**: Given matched m-tuples
with interval game strategies, Duplicator wins the n-round EF game. In NF
terms: given atom agreement and existential transfer at all depths < j, the
depth-j NF agrees. The transfer at depth j requires zone matching + IH at
depth j-1 for the extended configuration.

The proof proceeds by strong induction on j (game depth), universally
quantified over n (arity). At depth 0, atoms at any arity suffice. At
depth j+1, zone matching produces a matched point, and the IH at depth j
for the extended (n+1)-point configuration gives the quant agreement.

**Key structural insight**: The zone matching of each new point uses
depth-k 1-var NF data (from the hypothesis), and the matched point has
the same depth-k 1-var NF. Atom agreement at any arity follows from
pairwise 1-var NF agreement + ordering agreement. So the matching data
does NOT need to be passed through the induction — only the existence of
the zone-matched point matters. -/

/-- Helper: atom agreement at arity n follows from pairwise 1-var NF agreement
    and ordering agreement. The 1-var NF encodes predicates, and ordering agreement
    encodes the order atoms. -/
theorem atom_agree_from_pointwise {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {n : Nat} (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf : ∀ i : Fin n, ∀ k : Nat,
        ∀ nf : NormalForm sig k 1,
          nf_eval_nf M k 1 (fun _ => env_M i) nf ↔
          nf_eval_nf M' k 1 (fun _ => env_M' i) nf)
    (h_order : ∀ i j : Fin n, env_M i < env_M j ↔ env_M' i < env_M' j) :
    ∀ a : AtomKind sig n, atom_eval M env_M a ↔ atom_eval M' env_M' a := by
  intro a
  cases a with
  | pred p i =>
    simp only [atom_eval]
    -- From NF agreement at depth 1 for point i, extract predicate agreement
    have h := h_nf i 1
    have hM := nf_characteristic_satisfies M 1 1 (fun _ => env_M i)
    have hM' := nf_characteristic_satisfies M' 1 1 (fun _ => env_M' i)
    exact atom_agreement_from_nf M (fun _ => env_M i) M' (fun _ => env_M' i)
      (nf_agreement_from_shared_nf M (fun _ => env_M i) M' (fun _ => env_M' i)
        (nf_characteristic M 1 1 (fun _ => env_M i)) hM ((h _).mp hM)) (.pred p 0)
  | order i j _ =>
    simp only [atom_eval]
    exact h_order i j

/-- **GHR93 Existential Transfer**: The bridge lemma hypotheses (1-var NF agreement,
    ordering, interval/above/below type agreement at depth k) imply existential
    transfer at every depth j < k for 3-variable extensions.

    Mathematically, this is the content of Duplicator's winning strategy in the
    k-round EF game on colored linear orders (GHR93 Proposition 7): at each round
    j, Duplicator matches the new challenge point in the correct zone (using
    interval/above/below data) to maintain the game invariant. After k rounds, the
    invariant at depth 0 (atom agreement) is trivially satisfied, and the Fraïssé
    compression lemma lifts this to depth-k NF agreement.

    The proof requires a back-and-forth game argument because:
    1. Zone matching finds u' with the same 1-var NF and correct orderings relative
       to x' and t', but the depth-j 3-var NF agreement at (u,x,t)/(u',x',t')
       requires sub-interval type data for ALL pairs in the 3-point configuration.
    2. The sub-interval types of (x,u)/(x',u') at depth j are NOT determined by the
       interval types of (x,t)/(x',t') at depth k alone — they depend on the
       specific arrangement of types within the interval.
    3. The game argument resolves this by having Duplicator choose u' to SPLIT the
       interval types consistently: the types in (x',u') match those in (x,u) and
       the types in (u',t') match those in (u,t). This "interval-splitting" choice
       maintains the game invariant at the cost of decreasing the depth by 1.

    Formalizing the game strategy requires ~300-500 lines of infrastructure:
    defining game positions, proving strategy existence from the hypotheses,
    and proving that the strategy maintains the invariant at each round. -/
theorem nf_2var_existential_transfer {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M M' : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig) (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
    (h_interval_above : t < x →
      interval_nf_types M k t x = interval_nf_types M' k t' x')
    (h_interval_below : x < t →
      interval_nf_types M k x t = interval_nf_types M' k x' t')
    (h_above_max : (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u))
    (h_below_min : (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u)) :
    ∀ j, j < k →
      ∀ chi : NormalForm sig j (2 + 1),
        (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
        (∃ u', nf_eval_nf M' j (2 + 1) (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi) := by
  intro j hj chi
  -- Forward direction: M → M'
  constructor
  · rintro ⟨u, hu⟩
    -- Zone-match u to u' in M'
    obtain ⟨u', h_nf_u, h_ux, h_xu, h_ut, h_tu⟩ :=
      zone_match_witness k x t x' t' u h_nf_x h_nf_t h_order_xt
        h_interval_above h_interval_below h_above_max h_below_min
    -- u and u' have matching depth-k 1-var NFs, hence matching depth-j NFs
    -- (by nf_agreement_monotone). Together with ordering agreement, this gives
    -- depth-j 3-var NF agreement at (u,x,t)/(u',x',t'), which includes chi.
    --
    -- The depth-j 3-var NF agreement requires the Fraïssé game argument for j ≥ 1:
    -- atoms agree (from 1-var NFs + orderings), but the quantifier transfer at depth
    -- j-1 for 4-var extensions requires sub-interval matching for the 3-point
    -- configuration (u,x,t). This is the same sub-interval problem as the outer
    -- bridge lemma, but at one fewer variable and one lower depth.
    --
    -- For j = 0: the depth-0 3-var NF is just atoms (predicates + orderings).
    -- Zone matching gives correct orderings, and 1-var NF agreement gives predicates.
    -- For j ≥ 1: requires the Fraïssé game argument (sub-interval matching).
    -- We use u' from zone matching as the witness.
    refine ⟨u', ?_⟩
    -- Show atom agreement at 3 vars between (u,x,t) and (u',x',t')
    -- Atom agreement at 3 vars: each point shares depth-k NF => atom agreement
    have h_agree_u := nf_agreement_from_shared_nf M (fun _ => u) M' (fun _ => u')
      (nf_characteristic M k 1 (fun _ => u))
      (nf_characteristic_satisfies M k 1 (fun _ => u))
      (h_nf_u ▸ nf_characteristic_satisfies M' k 1 (fun _ => u'))
    have h_agree_x := nf_agreement_from_shared_nf M (fun _ => x) M' (fun _ => x')
      (nf_characteristic M k 1 (fun _ => x))
      (nf_characteristic_satisfies M k 1 (fun _ => x))
      (h_nf_x ▸ nf_characteristic_satisfies M' k 1 (fun _ => x'))
    have h_agree_t := nf_agreement_from_shared_nf M (fun _ => t) M' (fun _ => t')
      (nf_characteristic M k 1 (fun _ => t))
      (nf_characteristic_satisfies M k 1 (fun _ => t))
      (h_nf_t ▸ nf_characteristic_satisfies M' k 1 (fun _ => t'))
    have h_pred_u : ∀ p : sig.preds, M.interp p u ↔ M'.interp p u' :=
      fun p => atom_agreement_from_nf M (fun _ => u) M' (fun _ => u') h_agree_u (.pred p 0)
    have h_pred_x : ∀ p : sig.preds, M.interp p x ↔ M'.interp p x' :=
      fun p => atom_agreement_from_nf M (fun _ => x) M' (fun _ => x') h_agree_x (.pred p 0)
    have h_pred_t : ∀ p : sig.preds, M.interp p t ↔ M'.interp p t' :=
      fun p => atom_agreement_from_nf M (fun _ => t) M' (fun _ => t') h_agree_t (.pred p 0)
    have h_3var_atoms : ∀ (a : AtomKind sig 3),
        atom_eval M (Fin.cons u (Fin.cons x fun _ => t)) a ↔
        atom_eval M' (Fin.cons u' (Fin.cons x' fun _ => t')) a := by
      intro a; cases a with
      | pred p i =>
        simp only [atom_eval]
        refine Fin.cases ?_ (fun i' => ?_) i
        · -- i = 0: pred at u
          simp only [Fin.cons_zero]; exact h_pred_u p
        · refine Fin.cases ?_ (fun i'' => ?_) i'
          · -- i = 1: pred at x
            simp only [Fin.cons_succ, Fin.cons_zero]; exact h_pred_x p
          · -- i = 2: pred at t
            simp only [Fin.cons_succ]; exact h_pred_t p
      | order i j hij =>
        simp only [atom_eval]
        refine Fin.cases ?_ (fun i' => ?_) i <;> refine Fin.cases ?_ (fun j' => ?_) j
        -- (0, 0): u < u ↔ u' < u'
        · exact iff_of_false (lt_irrefl _) (lt_irrefl _)
        -- (0, succ j'): u < ...
        · refine Fin.cases ?_ (fun j'' => ?_) j'
          · -- (0, 1): u < x ↔ u' < x'
            simp only [Fin.cons_zero, Fin.cons_succ]; exact h_ux
          · -- (0, 2): u < t ↔ u' < t'
            simp only [Fin.cons_zero, Fin.cons_succ]; exact h_ut
        -- (succ i', 0): ... < u ↔ ... < u'
        · refine Fin.cases ?_ (fun i'' => ?_) i'
          · -- (1, 0): x < u ↔ x' < u'
            simp only [Fin.cons_zero, Fin.cons_succ]; exact h_xu
          · -- (2, 0): t < u ↔ t' < u'
            simp only [Fin.cons_zero, Fin.cons_succ]; exact h_tu
        -- (succ i', succ j'):
        · refine Fin.cases ?_ (fun i'' => ?_) i' <;> refine Fin.cases ?_ (fun j'' => ?_) j'
          · -- (1, 1): x < x ↔ x' < x'
            exact iff_of_false (lt_irrefl _) (lt_irrefl _)
          · -- (1, 2): x < t ↔ x' < t'
            simp only [Fin.cons_succ]; exact h_order_xt.1
          · -- (2, 1): t < x ↔ t' < x'
            simp only [Fin.cons_succ]; exact h_order_xt.2
          · -- (2, 2): t < t ↔ t' < t'
            simp only [Fin.cons_succ]; exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    -- Now use atom agreement to prove the goal.
    -- For j = 0: nf_eval_nf at depth 0 = atom agreement. Direct transfer.
    -- For j ≥ 1: need atoms + quantifier transfer. Atoms proved; quantifier requires
    -- sub-interval matching (the Fraïssé game argument).
    match j with
    | 0 =>
      -- Depth 0: just atoms. Transfer via h_3var_atoms and hu.
      intro a; constructor
      · intro ha'; exact (hu a).mp ((h_3var_atoms a).mpr ha')
      · intro ha; exact (h_3var_atoms a).mp ((hu a).mpr ha)
    | j' + 1 =>
      -- Depth j'+1: atoms + quantifier transfer for 4-var extensions.
      -- The atom part transfers via h_3var_atoms.
      -- The quantifier part requires sub-interval matching at the 3-point
      -- configuration (u,x,t)/(u',x',t'), which is the Fraïssé game argument.
      obtain ⟨hu_atoms, hu_quant⟩ := hu
      refine ⟨?_, ?_⟩
      · -- Atoms: transfer via h_3var_atoms
        intro a; constructor
        · intro ha'; exact (hu_atoms a).mp ((h_3var_atoms a).mpr ha')
        · intro ha; exact (h_3var_atoms a).mp ((hu_atoms a).mpr ha)
      · -- Quantifier: need 4-var transfer at depth j'
        intro sub_nf
        rw [← hu_quant sub_nf]
        -- Now need: (∃ w, nf_eval M j' 4 (w::u::x::t) sub_nf) ↔
        --           (∃ w', nf_eval M' j' 4 (w'::u'::x'::t') sub_nf)
        -- This is 4-var existential transfer at depth j' for the 3-point
        -- configuration (u,x,t)/(u',x',t'). Use zone_match on (x,t) bridge
        -- plus the outer theorem's transfer conclusion at depth j'.
        sorry
  · rintro ⟨u', hu'⟩
    -- Backward direction: M' → M (symmetric, using reversed hypotheses)
    have h_nf_x' := h_nf_x.symm
    have h_nf_t' := h_nf_t.symm
    have h_order_xt' : (x' < t' ↔ x < t) ∧ (t' < x' ↔ t < x) :=
      ⟨h_order_xt.1.symm, h_order_xt.2.symm⟩
    have h_interval_above' : t' < x' → interval_nf_types M' k t' x' = interval_nf_types M k t x :=
      fun h => (h_interval_above (h_order_xt.2.mpr h)).symm
    have h_interval_below' : x' < t' → interval_nf_types M' k x' t' = interval_nf_types M k x t :=
      fun h => (h_interval_below (h_order_xt.1.mpr h)).symm
    have h_above_max' : (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u) =
        (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) :=
      h_above_max.symm
    have h_below_min' : (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u) =
        (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) :=
      h_below_min.symm
    obtain ⟨u, h_nf_u, h_u'x', h_x'u', h_u't', h_t'u'⟩ :=
      zone_match_witness k x' t' x t u' h_nf_x' h_nf_t' h_order_xt'
        h_interval_above' h_interval_below' h_above_max' h_below_min'
    refine ⟨u, ?_⟩
    -- Same structure as forward: atom agreement at 3 vars, then split on j.
    have h_agree_u := nf_agreement_from_shared_nf M' (fun _ => u') M (fun _ => u)
      (nf_characteristic M' k 1 (fun _ => u'))
      (nf_characteristic_satisfies M' k 1 (fun _ => u'))
      (h_nf_u ▸ nf_characteristic_satisfies M k 1 (fun _ => u))
    have h_agree_x := nf_agreement_from_shared_nf M' (fun _ => x') M (fun _ => x)
      (nf_characteristic M' k 1 (fun _ => x'))
      (nf_characteristic_satisfies M' k 1 (fun _ => x'))
      (h_nf_x' ▸ nf_characteristic_satisfies M k 1 (fun _ => x))
    have h_agree_t := nf_agreement_from_shared_nf M' (fun _ => t') M (fun _ => t)
      (nf_characteristic M' k 1 (fun _ => t'))
      (nf_characteristic_satisfies M' k 1 (fun _ => t'))
      (h_nf_t' ▸ nf_characteristic_satisfies M k 1 (fun _ => t))
    have h_pred_u : ∀ p : sig.preds, M'.interp p u' ↔ M.interp p u :=
      fun p => atom_agreement_from_nf M' (fun _ => u') M (fun _ => u) h_agree_u (.pred p 0)
    have h_pred_x : ∀ p : sig.preds, M'.interp p x' ↔ M.interp p x :=
      fun p => atom_agreement_from_nf M' (fun _ => x') M (fun _ => x) h_agree_x (.pred p 0)
    have h_pred_t : ∀ p : sig.preds, M'.interp p t' ↔ M.interp p t :=
      fun p => atom_agreement_from_nf M' (fun _ => t') M (fun _ => t) h_agree_t (.pred p 0)
    have h_3var_atoms : ∀ (a : AtomKind sig 3),
        atom_eval M' (Fin.cons u' (Fin.cons x' fun _ => t')) a ↔
        atom_eval M (Fin.cons u (Fin.cons x fun _ => t)) a := by
      intro a; cases a with
      | pred p i =>
        simp only [atom_eval]
        refine Fin.cases ?_ (fun i' => ?_) i
        · simp only [Fin.cons_zero]; exact h_pred_u p
        · refine Fin.cases ?_ (fun i'' => ?_) i'
          · simp only [Fin.cons_succ, Fin.cons_zero]; exact h_pred_x p
          · simp only [Fin.cons_succ]; exact h_pred_t p
      | order i j hij =>
        simp only [atom_eval]
        refine Fin.cases ?_ (fun i' => ?_) i <;> refine Fin.cases ?_ (fun j' => ?_) j
        · exact iff_of_false (lt_irrefl _) (lt_irrefl _)
        · refine Fin.cases ?_ (fun j'' => ?_) j'
          · simp only [Fin.cons_zero, Fin.cons_succ]; exact h_u'x'
          · simp only [Fin.cons_zero, Fin.cons_succ]; exact h_u't'
        · refine Fin.cases ?_ (fun i'' => ?_) i'
          · simp only [Fin.cons_zero, Fin.cons_succ]; exact h_x'u'
          · simp only [Fin.cons_zero, Fin.cons_succ]; exact h_t'u'
        · refine Fin.cases ?_ (fun i'' => ?_) i' <;> refine Fin.cases ?_ (fun j'' => ?_) j'
          · exact iff_of_false (lt_irrefl _) (lt_irrefl _)
          · simp only [Fin.cons_succ]; exact h_order_xt'.1
          · simp only [Fin.cons_succ]; exact h_order_xt'.2
          · simp only [Fin.cons_succ]; exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    match j with
    | 0 =>
      intro a; constructor
      · intro ha'; exact (hu' a).mp ((h_3var_atoms a).mpr ha')
      · intro ha; exact (h_3var_atoms a).mp ((hu' a).mpr ha)
    | j' + 1 =>
      obtain ⟨hu'_atoms, hu'_quant⟩ := hu'
      refine ⟨?_, ?_⟩
      · -- Atoms: transfer via h_3var_atoms
        intro a; constructor
        · intro ha'; exact (hu'_atoms a).mp ((h_3var_atoms a).mpr ha')
        · intro ha; exact (h_3var_atoms a).mp ((hu'_atoms a).mpr ha)
      · -- Quantifier: need 4-var transfer at depth j'
        intro sub_nf
        rw [← hu'_quant sub_nf]
        -- 4-var existential transfer at depth j' for (u',x',t')/(u,x,t)
        sorry

/-- **GHR93 Bridge Lemma**: The 2-var depth-k NF of (x,t) is determined by the
    depth-k 1-var NFs of x and t, their ordering, and the set of depth-k 1-var
    NFs realized in the interval between them.

    Concretely: if two 2-variable environments (x,t) in M and (x',t') in M'
    have the same 1-var depth-k NFs, same ordering, and same interval type sets,
    then their 2-var depth-k NFs are equal.

    This is the content of GHR93's game-theoretic composition argument
    (Proposition 7 + Lemma 11): agreement on 1-var types at all positions +
    interval type sets → Duplicator wins the EF game → same NF. -/
theorem nf_2var_from_interval_data {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M M' : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig) (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
    -- Interval type agreement (each direction, for the interval between x and t)
    (h_interval_above : t < x →
      interval_nf_types M k t x = interval_nf_types M' k t' x')
    (h_interval_below : x < t →
      interval_nf_types M k x t = interval_nf_types M' k x' t')
    -- Outside interval: types realized above max and below min also agree
    (h_above_max : (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u))
    (h_below_min : (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u)) :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic M' k 2 (Fin.cons x' (fun _ => t')) := by
  -- Extract atom agreement: atom_eval M (x,t) a ↔ atom_eval M' (x',t') a.
  -- Predicates agree from the depth-k 1-var NF equality; orderings from h_order_xt.
  have h_atom_agree : ∀ (a : AtomKind sig 2),
      atom_eval M (Fin.cons x fun _ => t) a ↔
      atom_eval M' (Fin.cons x' fun _ => t') a := by
    intro a; cases a with
    | pred p i =>
      simp only [atom_eval]
      -- Extract predicate agreement from 1-var NF agreement using shared NF
      refine Fin.cases ?_ (fun j => ?_) i
      · -- i = 0: pred at x ↔ pred at x'
        simp only [Fin.cons_zero]
        have hM := nf_characteristic_satisfies M k 1 (fun _ => x)
        have hM' := nf_characteristic_satisfies M' k 1 (fun _ => x')
        -- M',x' satisfies M's characteristic NF (from h_nf_x)
        have hM'_sat_M_nf : nf_eval_nf M' k 1 (fun _ => x')
            (nf_characteristic M k 1 (fun _ => x)) := by
          rw [h_nf_x]; exact hM'
        exact atom_agreement_from_nf M (fun _ => x) M' (fun _ => x')
          (nf_agreement_from_shared_nf M (fun _ => x) M' (fun _ => x')
            (nf_characteristic M k 1 (fun _ => x)) hM hM'_sat_M_nf)
          (.pred p 0)
      · -- i = succ j: pred at t ↔ pred at t'
        simp only [Fin.cons_succ]
        have hM := nf_characteristic_satisfies M k 1 (fun _ => t)
        have hM' := nf_characteristic_satisfies M' k 1 (fun _ => t')
        have hM'_sat_M_nf : nf_eval_nf M' k 1 (fun _ => t')
            (nf_characteristic M k 1 (fun _ => t)) := by
          rw [h_nf_t]; exact hM'
        exact atom_agreement_from_nf M (fun _ => t) M' (fun _ => t')
          (nf_agreement_from_shared_nf M (fun _ => t) M' (fun _ => t')
            (nf_characteristic M k 1 (fun _ => t)) hM hM'_sat_M_nf)
          (.pred p 0)
    | order i j hij =>
      simp only [atom_eval]
      refine Fin.cases ?_ (fun i' => ?_) i <;> refine Fin.cases ?_ (fun j' => ?_) j
      · -- i=0, j=0: x < x ↔ x' < x' (both false)
        exact iff_of_false (lt_irrefl _) (lt_irrefl _)
      · simp only [Fin.cons_zero, Fin.cons_succ]; exact h_order_xt.1
      · simp only [Fin.cons_zero, Fin.cons_succ]; exact h_order_xt.2
      · -- i=succ, j=succ: t < t ↔ t' < t' (both false)
        simp only [Fin.cons_succ]; exact iff_of_false (lt_irrefl _) (lt_irrefl _)
  -- Use the Fraïssé compression lemma: atoms + existential transfer at each
  -- depth j < k implies depth-k NF equality.
  exact nf_fraisse_compression k 2 M (Fin.cons x fun _ => t) M' (Fin.cons x' fun _ => t')
    h_atom_agree (nf_2var_existential_transfer atomMap k x t x' t' char_k char_k_correct
      h_nf_x h_nf_t h_order_xt h_interval_above h_interval_below h_above_max h_below_min)

/-- Corollary: if nf_eval_nf holds for one pair with the interval data,
    it holds for any pair with the same data. -/
theorem nf_2var_transfer {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M M' : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig) (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    (sub_nf : NormalForm sig k 2)
    (h_eval : nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
    (h_interval_above : t < x →
      interval_nf_types M k t x = interval_nf_types M' k t' x')
    (h_interval_below : x < t →
      interval_nf_types M k x t = interval_nf_types M' k x' t')
    (h_above_max : (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u))
    (h_below_min : (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u)) :
    nf_eval_nf M' k 2 (Fin.cons x' (fun _ => t')) sub_nf := by
  -- Follows from nf_2var_from_interval_data: the bridge lemma gives
  -- nf_characteristic M k 2 (x,t) = nf_characteristic M' k 2 (x',t').
  -- Combined with h_eval and nf_eval_unique, this yields the result.
  have h_eq := nf_2var_from_interval_data atomMap k x t x' t' char_k char_k_correct
    h_nf_x h_nf_t h_order_xt h_interval_above h_interval_below h_above_max h_below_min
  -- sub_nf = nf_characteristic M k 2 (x,t) by uniqueness
  have h_sub_eq : sub_nf = nf_characteristic M k 2 (Fin.cons x (fun _ => t)) :=
    nf_eval_unique M k 2 (Fin.cons x (fun _ => t)) sub_nf _ h_eval
      (nf_characteristic_satisfies M k 2 (Fin.cons x (fun _ => t)))
  rw [h_sub_eq, h_eq]
  exact nf_characteristic_satisfies M' k 2 (Fin.cons x' (fun _ => t'))

/-! ## Classical Existence of 2-Var Characterizing Formula

For the k≥1 case, we construct the existence formula classically.
The key idea: for a fixed parent_atoms and sub_nf, enumerate over all
possible "configurations" (nf_x, ordering, interval_type_set) that produce
sub_nf as the 2-var NF. For each such configuration, build a temporal
formula detecting it. The disjunction over all valid configurations
characterizes ∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf.

The backward direction uses the bridge lemma: given a model M where the
formula holds, extract the configuration data, find a "reference model"
where sub_nf is the actual 2-var NF, and transfer via nf_2var_transfer.
-/

/-- The interval guard formula: disjunction of char_k nf_u for ALL depth-k
    1-var NFs. This is always satisfiable (every point has some NF type)
    but provides the structural hook for extracting types in the backward
    direction. -/
noncomputable def interval_guard_sf
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (char_k : NormalForm sig k 1 → StaviFormula) : StaviFormula :=
  sf_disjList ((Fintype.elems (α := NormalForm sig k 1)).val.toList.map char_k)

/-- The interval guard is always true: every point satisfies some char_k nf_u. -/
theorem interval_guard_sf_true
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds) (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (M : OrderedMonadicStructure sig) (u : M.carrier) :
    stavi_temporal_truth M atomMap u (interval_guard_sf char_k) := by
  simp only [interval_guard_sf]
  rw [sf_disjList_iff]
  set nf_u := nf_characteristic M k 1 (fun _ => u)
  refine ⟨char_k nf_u, ?_, ?_⟩
  · simp only [List.mem_map]
    exact ⟨nf_u, Multiset.mem_toList.mpr (Fintype.complete nf_u), rfl⟩
  · exact (char_k_correct nf_u M u).mpr (nf_characteristic_satisfies M k 1 (fun _ => u))

/-- Build the existence formula for the k≥1 case using interval guard instead of sf_top.
    Same structure as nf_exist_sf but with interval_guard_sf as the guard. -/
noncomputable def nf_exist_sf_guarded
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) : StaviFormula :=
  -- Step 1: t-consistency check
  if ¬ nf_t_consistent parent_atoms sub_nf = true then
    .base .bot
  -- Step 2: order consistency check
  else if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
          sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) then
    .base .bot
  else
    -- Step 3: Determine order direction and build formula
    let all_nfs_k1 := (Fintype.elems (α := NormalForm sig k 1)).val.toList
    let atom_compat (nf_x : NormalForm sig k 1) : Bool :=
      (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
        nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)
    let compat_formulas := all_nfs_k1.filterMap fun nf_x =>
      if atom_compat nf_x then some (char_k nf_x) else none
    let witness_type := sf_disjList compat_formulas
    let guard := interval_guard_sf char_k
    match nf_order_0_1 sub_nf with
    | some true =>  -- t < x: use Until
      .std_untl witness_type guard
    | some false =>  -- x < t: use Since
      .std_snce witness_type guard
    | none =>
      -- x = t case
      if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) == false &&
         sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) == false then
        witness_type
      else
        .base .bot

/-- Forward direction for the guarded formula: nf_eval → formula truth. -/
theorem nf_exist_sf_guarded_forward
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_ex : ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    stavi_temporal_truth M atomMap t
      (nf_exist_sf_guarded atomMap h_surj k char_k parent_atoms sub_nf) := by
  -- The proof follows the same structure as nf_exist_sf_forward, but uses
  -- interval_guard_sf_true for the guard obligation instead of sf_top_iff.
  obtain ⟨x, h_x⟩ := h_ex
  -- Extract atom information from h_x
  have h_x_atoms : ∀ (a : AtomKind sig (1 + 1)),
      atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.atom_assgn a = true := by
    cases k with
    | zero => exact h_x
    | succ k' => exact h_x.1
  -- t-consistency holds
  have h_t_cons : nf_t_consistent parent_atoms sub_nf = true := by
    simp only [nf_t_consistent]
    rw [List.all_eq_true]
    intro p _
    simp only [beq_iff_eq]
    have h_sub_t := h_x_atoms (.pred p ⟨1, by omega⟩)
    have h_par := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h_sub_t h_par
    have h_env_1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [h_env_1] at h_sub_t
    cases h1 : sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) <;>
    cases h2 : parent_atoms (.pred p ⟨0, by omega⟩) <;>
    simp_all
  -- Unfold guarded formula with consistency check passing
  simp only [nf_exist_sf_guarded, h_t_cons, not_true, ↓reduceIte, ite_not]
  -- Order consistency
  have h_x_lt_t := h_x_atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  have h_t_lt_x := h_x_atoms (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  simp only [atom_eval, Fin.cons] at h_x_lt_t h_t_lt_x
  have h_order_compat : ¬ (sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
      sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true := by
    intro h_both
    rw [Bool.and_eq_true] at h_both
    have hxt : x < t := h_x_lt_t.mpr h_both.1
    have htx : t < x := h_t_lt_x.mpr h_both.2
    exact absurd (lt_trans hxt htx) (lt_irrefl _)
  simp only [h_order_compat, ite_false]
  -- The 1-variable depth-k NF of x
  set nf_x := nf_characteristic M k 1 (fun _ => x) with nf_x_def
  have h_nf_x : nf_eval_nf M k 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M k 1 (fun _ => x)
  -- The IH formula for nf_x holds at x
  have h_char_at_x : stavi_temporal_truth M atomMap x (char_k nf_x) :=
    (char_k_correct nf_x M x).mpr h_nf_x
  -- Key lemma: Fin.cons evaluations
  have h_fc0 : Fin.cases x (fun _ : Fin 1 => t) (⟨0, by omega⟩ : Fin 2) = x := by
    simp [Fin.cases]
  have h_fc1 : Fin.cases x (fun _ : Fin 1 => t) (⟨1, by omega⟩ : Fin 2) = t := by
    simp [Fin.cases]; rfl
  rw [h_fc0, h_fc1] at h_x_lt_t
  rw [h_fc1, h_fc0] at h_t_lt_x
  -- nf_x is atom-compatible with sub_nf at variable 0
  have h_compat : ∀ p : sig.preds,
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) =
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩) := by
    intro p
    have h_nf_x_p : atom_eval M (fun _ => x) (.pred p (0 : Fin 1)) ↔
        (nf_x.atom_assgn (.pred p (0 : Fin 1)) = true) := by
      cases k with
      | zero => exact h_nf_x (.pred p 0)
      | succ k' => exact h_nf_x.1 (.pred p 0)
    have h_sub_p := h_x_atoms (.pred p (0 : Fin 2))
    simp only [atom_eval] at h_nf_x_p h_sub_p
    have h_fc0' : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) (0 : Fin 2) = x := by
      simp [Fin.cons]
    rw [h_fc0'] at h_sub_p
    cases h1 : nf_x.atom_assgn (.pred p (0 : Fin 1)) <;>
    cases h2 : sub_nf.atom_assgn (.pred p (0 : Fin 2)) <;>
    simp_all
  -- Prove the compat_formulas filter condition
  norm_num
  have h_in_list' : char_k nf_x ∈ List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) = sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList := by
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x), by
      rw [if_pos]; intro p hp; exact h_compat p⟩
  have h_disj_at_x : stavi_temporal_truth M atomMap x (sf_disjList (List.filterMap
      (fun nf_x' => if (∀ x ∈ Fintype.elems, nf_x'.atom_assgn (AtomKind.pred x 0) = sub_nf.atom_assgn (AtomKind.pred x 0)) then some (char_k nf_x') else none)
      Fintype.elems.val.toList)) := by
    rw [sf_disjList_iff]
    exact ⟨char_k nf_x, h_in_list', h_char_at_x⟩
  -- Case-split on order direction
  match h_b1 : sub_nf.atom_assgn (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_b2 : sub_nf.atom_assgn (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, false =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_t_lt_x.mpr h_b1, h_disj_at_x,
      fun u _ _ => interval_guard_sf_true atomMap k char_k char_k_correct M u⟩
  | false, true =>
    simp only [nf_order_0_1, h_b1, h_b2, stavi_temporal_truth]
    exact ⟨x, h_x_lt_t.mpr h_b2, h_disj_at_x,
      fun u _ _ => interval_guard_sf_true atomMap k char_k char_k_correct M u⟩
  | false, false =>
    simp only [nf_order_0_1, h_b1, h_b2, and_self, ↓reduceIte]
    have h_eq : x = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h | h
      · exact absurd (h_x_lt_t.mp h) (by simp_all)
      · exact absurd (h_t_lt_x.mp h) (by simp_all)
    rw [← h_eq]; exact h_disj_at_x
  | true, true =>
    exfalso
    exact h_order_compat (by rw [Bool.and_eq_true]; exact ⟨h_b2, h_b1⟩)

/-- Backward direction for the guarded formula: formula truth → nf_eval.
    This is the hard direction requiring the bridge lemma.

    The proof extracts the witness x from the temporal formula, determines its
    1-var depth-k NF type, and uses the bridge lemma to show that the 2-var NF
    of (x,t) must equal sub_nf.

    Key steps:
    1. From the formula, extract witness x with atom-compatible type + interval guard
    2. The 2-var characteristic NF of (x,t) agrees with sub_nf on atoms (provable)
    3. The 2-var characteristic NF of (x,t) agrees with sub_nf on quant part (bridge)
    4. By nf_eval_unique, nf_eval_nf holds for sub_nf -/
theorem nf_exist_sf_guarded_backward
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_sf : stavi_temporal_truth M atomMap t
      (nf_exist_sf_guarded atomMap h_surj k char_k parent_atoms sub_nf)) :
    ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  -- The backward direction requires the GHR93 bridge lemma:
  -- The 2-var NF of (x,t) is determined by the 1-var NFs + ordering + interval types.
  -- The proof structure:
  -- 1. Extract witness x from the temporal formula (Until/Since/equality)
  -- 2. From char_k_correct, determine x's 1-var depth-k NF
  -- 3. From the interval guard, extract types of intermediate points
  -- 4. Apply bridge lemma (nf_2var_from_interval_data) to conclude 2-var NF = sub_nf
  --
  -- The bridge lemma is sorry'd (nf_2var_from_interval_data), so this proof
  -- is sorry'd as well. When the bridge is proved, this proof completes.
  sorry

/-- Classical existence of a StaviFormula characterizing 2-var NF existence at
    arbitrary depth k. Uses the guarded formula (interval_guard_sf instead of sf_top)
    for both forward and backward directions. -/
theorem nf_2var_exist_sf_classical
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (sf : StaviFormula),
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
          parent_atoms a = true) →
        (stavi_temporal_truth M atomMap t sf ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
  ⟨nf_exist_sf_guarded atomMap h_surj k char_k parent_atoms sub_nf,
   fun M t h_atoms => ⟨
     nf_exist_sf_guarded_backward atomMap h_surj k char_k char_k_correct
       parent_atoms sub_nf h_atoms,
     nf_exist_sf_guarded_forward atomMap h_surj k char_k char_k_correct
       parent_atoms sub_nf h_atoms⟩⟩

/-! ## NF Existence Characterization by StaviFormulas

GHR93 key lemma: for each 2-variable depth-k NF sub_nf and parent atom
assignment, there exists a StaviFormula that correctly characterizes
"∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" at t.

The construction uses a guarded formula (interval_guard_sf) instead of sf_top,
following GHR93's approach of constraining intermediate point types.

The k=0 case is fully proved using the original nf_exist_sf (atoms + order
suffice at depth 0). The k≥1 case uses nf_2var_exist_sf_classical, which
builds a guarded formula and appeals to the bridge lemma for the backward
direction. -/
theorem nf_2var_existence_characterizable
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (sf : StaviFormula),
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
          parent_atoms a = true) →
        (stavi_temporal_truth M atomMap t sf ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Strategy: use nf_exist_sf as the witness formula for all k.
  -- Forward direction: nf_exist_sf_forward (already proved).
  -- Backward direction: case-split on k.
  --   k=0: depth-0 2-var NFs are purely atomic; atoms+order from the formula
  --         fully determine the NF.
  --   k+1: the formula with sf_top guard is too weak for backward at k≥1.
  --         Instead, we refine the witness x using nf_characteristic to get
  --         the actual 2-var NF, then appeal to the game-theoretic composition.
  cases k with
  | zero =>
    -- k=0: nf_exist_sf works in both directions
    refine ⟨nf_exist_sf atomMap h_surj 0 char_k parent_atoms sub_nf,
      fun M t h_atoms => ⟨?_, nf_exist_sf_forward atomMap h_surj 0 char_k
        char_k_correct parent_atoms sub_nf h_atoms⟩⟩
    -- Backward direction: formula truth → ∃ x, nf_eval_nf M 0 2 (Fin.cons x ...) sub_nf
    intro h_sf
    -- Case-split on t-consistency BEFORE unfolding
    by_cases h_t_cons : nf_t_consistent parent_atoms sub_nf = true
    · -- t-consistency passes: unfold and continue
      simp only [nf_exist_sf] at h_sf
      simp only [h_t_cons, not_true, ↓reduceIte, ite_false] at h_sf
      -- Unfold .atom_assgn at depth 0 (identity)
      simp only [NormalForm.atom_assgn] at h_sf
      -- Order consistency check: abbreviate the order booleans
      set b_x_lt_t := sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with b_x_lt_t_def
      set b_t_lt_x := sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) with b_t_lt_x_def
      -- The if-condition in h_sf now uses sub_nf (.order ...) directly
      change stavi_temporal_truth M atomMap t
        (if (b_x_lt_t && b_t_lt_x) = true then StaviFormula.base Formula.bot
         else _) at h_sf
      by_cases h_order_both : (b_x_lt_t && b_t_lt_x) = true
      · -- Both order atoms true → formula is bot
        simp only [h_order_both, ↓reduceIte, stavi_temporal_truth, temporal_truth] at h_sf
      · -- Order consistency passes
        simp only [h_order_both, ↓reduceIte, ite_false] at h_sf
        -- Unfold nf_order_0_1 to a match on the actual booleans
        simp only [nf_order_0_1, NormalForm.atom_assgn] at h_sf
        -- Now h_sf has a match on b_t_lt_x, b_x_lt_t
        -- Helper: extract witness info from sf_disjList of compat_formulas
        -- At k=0, .atom_assgn = id, so nf_x and sub_nf are just (AtomKind → Bool)
        have extract_witness : ∀ (x : M.carrier),
            stavi_temporal_truth M atomMap x (sf_disjList
              (List.filterMap
                (fun nf_x => if (Fintype.elems (α := sig.preds)).val.toList.all
                  (fun p => nf_x (.pred p ⟨0, by omega⟩) ==
                    sub_nf (.pred p ⟨0, by omega⟩)) = true
                  then some (char_k nf_x) else none)
                (Fintype.elems (α := NormalForm sig 0 1)).val.toList)) →
            ∃ nf_x : NormalForm sig 0 1,
              (∀ p : sig.preds, nf_x (.pred p ⟨0, by omega⟩) =
                sub_nf (.pred p ⟨0, by omega⟩)) ∧
              nf_eval_nf M 0 1 (fun _ => x) nf_x := by
          intro x h_disj
          rw [sf_disjList_iff] at h_disj
          obtain ⟨A, h_mem, h_A⟩ := h_disj
          rw [List.mem_filterMap] at h_mem
          obtain ⟨nf_x, _, h_if⟩ := h_mem
          split_ifs at h_if with h_compat
          · cases h_if with | refl =>
            refine ⟨nf_x, ?_, (char_k_correct nf_x M x).mp h_A⟩
            intro p
            have := (List.all_eq_true.mp h_compat) p
              (Multiset.mem_toList.mpr (Fintype.complete p))
            simp only [beq_iff_eq] at this
            exact this
        -- Helper: t-consistency gives predicates at t matching sub_nf
        have h_pred_t : ∀ p : sig.preds,
            M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true := by
          intro p
          have h_par := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h_par
          have h_cons : sub_nf (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) := by
            have := (List.all_eq_true.mp (by rw [nf_t_consistent] at h_t_cons; exact h_t_cons))
              p (Multiset.mem_toList.mpr (Fintype.complete p))
            simp only [beq_iff_eq] at this
            exact this
          rw [h_cons]; exact h_par
        -- Helper: build nf_eval_nf M 0 2 from component data
        have build_nf_eval : ∀ (x : M.carrier)
            (h_px : ∀ p : sig.preds, M.interp p x ↔ sub_nf (.pred p ⟨0, by omega⟩) = true)
            (h_pt : ∀ p : sig.preds, M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true)
            (h_o01 : (x < t) ↔ b_x_lt_t = true)
            (h_o10 : (t < x) ↔ b_t_lt_x = true),
            nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
          intro x h_px h_pt h_o01 h_o10
          -- At depth 0: ∀ a, atom_eval M env a ↔ sub_nf a = true
          simp only [nf_eval_nf]
          -- Env lemmas
          have henv0 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨0, by omega⟩ = x := by
            simp [Fin.cons]
          have henv1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
            simp [Fin.cons]; rfl
          intro a
          match a with
          | .pred p ⟨0, _⟩ =>
            simp only [atom_eval, henv0]
            exact h_px p
          | .pred p ⟨1, _⟩ =>
            simp only [atom_eval, henv1]
            exact h_pt p
          | .pred _ ⟨n + 2, h⟩ => exact absurd h (by omega)
          | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
          | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
            simp only [atom_eval, henv0, henv1]
            rw [b_x_lt_t_def] at h_o01; exact h_o01
          | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
            simp only [atom_eval, henv1, henv0]
            rw [b_t_lt_x_def] at h_o10; exact h_o10
          | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
          | .order ⟨n + 2, hi⟩ _ _ => exact absurd hi (by omega)
          | .order _ ⟨n + 2, hj⟩ _ => exact absurd hj (by omega)
        -- Now case-split on the order booleans
        -- The inner match uses sub_nf (AtomKind.order ...) which at k=0 equals
        -- b_t_lt_x and b_x_lt_t up to proof-irrelevant equalities
        -- Strategy: substitute b_t_lt_x/b_x_lt_t into h_sf via rewriting
        -- Rewrite the match discriminants in h_sf to use b_t_lt_x, b_x_lt_t
        -- The proof-irrelevant proof terms (nf_order_0_1._proof_*) match definitionally
        have h_btx_rw : sub_nf (.order ⟨1, nf_order_0_1._proof_2⟩ ⟨0, nf_order_0_1._proof_1⟩
          nf_order_0_1._proof_6) = b_t_lt_x := b_t_lt_x_def.symm
        have h_bxt_rw : sub_nf (.order ⟨0, nf_order_0_1._proof_1⟩ ⟨1, nf_order_0_1._proof_2⟩
          nf_order_0_1._proof_5) = b_x_lt_t := b_x_lt_t_def.symm
        rw [h_btx_rw, h_bxt_rw] at h_sf
        -- Helper to extract witness and build nf_eval from disjList truth
        have use_witness : ∀ (x : M.carrier)
            (h_disj : stavi_temporal_truth M atomMap x (sf_disjList
              (List.filterMap
                (fun nf_x => if (Fintype.elems (α := sig.preds)).val.toList.all
                  (fun p => nf_x (.pred p ⟨0, by omega⟩) ==
                    sub_nf (.pred p ⟨0, by omega⟩)) = true
                  then some (char_k nf_x) else none)
                (Fintype.elems (α := NormalForm sig 0 1)).val.toList)))
            (h_o01 : (x < t) ↔ b_x_lt_t = true)
            (h_o10 : (t < x) ↔ b_t_lt_x = true),
            nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
          intro x h_disj h_o01 h_o10
          obtain ⟨nf_x, h_x_compat, h_nf_x⟩ := extract_witness x h_disj
          exact build_nf_eval x
            (fun p => by
              have h_nf_x_p := h_nf_x (.pred p ⟨0, by omega⟩)
              simp only [atom_eval] at h_nf_x_p
              rw [h_x_compat p] at h_nf_x_p; exact h_nf_x_p)
            h_pred_t h_o01 h_o10
        -- Case-split on b_t_lt_x, b_x_lt_t
        rcases h_btx : b_t_lt_x with _ | _ <;> rcases h_bxt : b_x_lt_t with _ | _
        · -- false, false: x = t equality case
          simp only [h_btx, h_bxt, ↓reduceIte, beq_self_eq_true, Bool.true_and, Bool.false_and,
            Bool.false_eq_true, not_false_eq_true, stavi_temporal_truth, temporal_truth] at h_sf
          exact ⟨t, use_witness t h_sf
            (Iff.intro (fun h => absurd h (lt_irrefl _)) (by simp [h_bxt]))
            (Iff.intro (fun h => absurd h (lt_irrefl _)) (by simp [h_btx]))⟩
        · -- false, true: x < t, Since case
          simp only [h_btx, h_bxt, ↓reduceIte, stavi_temporal_truth] at h_sf
          obtain ⟨s, h_s_lt_t, h_disj_s, _⟩ := h_sf
          exact ⟨s, use_witness s h_disj_s
            (Iff.intro (fun _ => h_bxt) (fun _ => h_s_lt_t))
            (Iff.intro (fun h => absurd (lt_trans h_s_lt_t h) (lt_irrefl _)) (by simp [h_btx]))⟩
        · -- true, false: t < x, Until case
          simp only [h_btx, h_bxt, ↓reduceIte, stavi_temporal_truth] at h_sf
          obtain ⟨s, h_t_lt_s, h_disj_s, _⟩ := h_sf
          exact ⟨s, use_witness s h_disj_s
            (Iff.intro (fun h => absurd (lt_trans h h_t_lt_s) (lt_irrefl _)) (by simp [h_bxt]))
            (Iff.intro (fun _ => h_btx) (fun _ => h_t_lt_s))⟩
        · -- true, true: impossible (eliminated by h_order_both)
          exact absurd (by simp [h_btx, h_bxt] : (b_x_lt_t && b_t_lt_x) = true) h_order_both
    · -- t-consistency fails: formula is bot → contradiction from h_sf
      exfalso
      -- h_sf still has nf_exist_sf (not yet unfolded)
      have h_is_bot : nf_exist_sf atomMap h_surj 0 char_k parent_atoms sub_nf =
          StaviFormula.base Formula.bot := by
        unfold nf_exist_sf
        rw [if_pos h_t_cons]
      rw [h_is_bot] at h_sf
      simp [stavi_temporal_truth, temporal_truth] at h_sf
  | succ k' =>
    -- k+1: The nf_exist_sf formula (with sf_top guard) is correct in the forward
    -- direction but too weak for the backward direction. Instead, we build a
    -- DIFFERENT formula that encodes the FULL 2-variable NF, not just the atom part.
    --
    -- The key insight (GHR93 Proposition 12.8.18): the 2-var depth-(k'+1) NF of (x,t)
    -- is determined by the depth-(k'+1) 1-var NFs of x and t, their ordering, and
    -- the SET of depth-(k'+1) 1-var NFs realized in the interval between them.
    --
    -- Strategy: Use Classical.choice on a constructive formula built by enumerating
    -- over ALL possible depth-(k'+1) 1-var NFs for the witness x, using the
    -- nf_exist_sf formula for the guard. A bridge lemma (sorry'd below) connects
    -- the interval guard + endpoint types to the full 2-var NF.
    --
    -- For the formula witness, we use nf_exist_sf (forward direction works).
    -- For the backward direction, we appeal to the bridge lemma.
    --
    -- Alternative approach: define the existence formula using Classical.choice
    -- from nf_2var_exist_sf_classical, which constructs the correct formula by
    -- enumerating over depth-(k'+1) NF types and checking compatibility.
    exact nf_2var_exist_sf_classical atomMap h_surj (k' + 1) char_k char_k_correct
      parent_atoms sub_nf

/-! ## NF Characterization by StaviFormulas -/

/-- Core game-theoretic lemma: each NF is characterizable by a StaviFormula.

The proof proceeds by induction on k. The base case (k=0) constructs a conjunction
of atom literals. The inductive step (k+1) uses:
- Atom part: conjunction of atom literals for predicate agreement at t
- Quantifier part: for each sub_nf : NormalForm sig k 2, a classically chosen
  existence formula from nf_2var_existence_characterizable. This formula correctly
  characterizes the 2-variable NF realizability, avoiding the collision bug in the
  naive nf_exist_sf construction (which used sf_top as guard and could not
  distinguish 2-variable NFs sharing the same atom assignment).

The formula is assembled as: conjunction of atom literals AND for each sub_nf,
the existence formula (if quant=true) or its negation (if quant=false).

Both directions of the biconditional follow directly from the properties of the
classically chosen existence formulas and the atom literal correctness. -/
theorem nf_characterizable_by_stavi
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    ∃ A : StaviFormula, ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t A ↔
      nf_eval_nf M k 1 (fun _ => t) nf := by
  induction k with
  | zero =>
    exact ⟨nf_base_sf atomMap h_surj nf, fun M t => nf_base_sf_correct atomMap h_surj nf M t⟩
  | succ k ih =>
    -- Use the IH to build characteristic formulas for all depth-k 1-variable NFs
    let char_k : NormalForm sig k 1 → StaviFormula :=
      fun nf_k => Classical.choose (ih nf_k)
    have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k :=
      fun nf_k => Classical.choose_spec (ih nf_k)
    -- For each 2-variable sub_nf, classically choose a correct existence formula
    -- via nf_2var_existence_characterizable. This avoids the collision bug in
    -- nf_exist_sf (which maps different sub_nfs with same atoms to the same formula).
    let exist_sf : NormalForm sig k 2 → StaviFormula :=
      fun sub_nf => Classical.choose
        (nf_2var_existence_characterizable atomMap h_surj k char_k char_k_correct
          nf.1 sub_nf)
    have exist_sf_correct : ∀ (sub_nf : NormalForm sig k 2)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true) →
        (stavi_temporal_truth M atomMap t (exist_sf sub_nf) ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
      fun sub_nf => Classical.choose_spec
        (nf_2var_existence_characterizable atomMap h_surj k char_k char_k_correct
          nf.1 sub_nf)
    -- Build the formula: atom literals AND quantifier existence formulas
    let atom_lits := (Fintype.elems (α := AtomKind sig 1)).val.toList.map fun ak =>
      atomKind_to_sf_literal atomMap h_surj ak (nf.1 ak)
    let quant_formulas := (Fintype.elems (α := NormalForm sig k 2)).val.toList.map fun sub_nf =>
      if nf.2 sub_nf then exist_sf sub_nf else .neg (exist_sf sub_nf)
    let full_formula := StaviFormula.conj (sf_conjList atom_lits) (sf_conjList quant_formulas)
    refine ⟨full_formula, fun M t => ?_⟩
    constructor
    · -- Forward: formula truth → nf_eval_nf
      intro h_formula
      simp only [full_formula, stavi_temporal_truth] at h_formula
      obtain ⟨h_f_atoms, h_f_quant⟩ := h_formula
      have h_atom_list := (sf_conjList_iff M atomMap t _).mp h_f_atoms
      have h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true := by
        intro a
        have h_mem : atomKind_to_sf_literal atomMap h_surj a (nf.1 a) ∈ atom_lits := by
          simp only [atom_lits, List.mem_map]
          exact ⟨a, Multiset.mem_toList.mpr (Fintype.complete a), rfl⟩
        exact (atomKind_to_sf_literal_correct atomMap h_surj M t a (nf.1 a)).mp
          (h_atom_list _ h_mem)
      have h_quant_list := (sf_conjList_iff M atomMap t _).mp h_f_quant
      show nf_eval_nf M (k + 1) 1 (fun _ => t) nf
      obtain ⟨atom_part, quant_part⟩ := nf
      refine ⟨h_atoms, fun sub_nf => ?_⟩
      -- Extract the formula truth for this specific sub_nf
      have h_sub_in : (if quant_part sub_nf then exist_sf sub_nf
          else (exist_sf sub_nf).neg) ∈ quant_formulas := by
        simp only [quant_formulas, List.mem_map]
        exact ⟨sub_nf, Multiset.mem_toList.mpr (Fintype.complete sub_nf), rfl⟩
      have h_sub_truth := h_quant_list _ h_sub_in
      -- Use exist_sf_correct to bridge between formula truth and NF existence
      have h_iff := exist_sf_correct sub_nf M t h_atoms
      cases h_q_val : quant_part sub_nf
      · -- quant_part sub_nf = false: the negation formula holds
        simp only [h_q_val, Bool.false_eq_true, ↓reduceIte, stavi_temporal_truth] at h_sub_truth
        constructor
        · intro h_ex; exact absurd (h_iff.mpr h_ex) h_sub_truth
        · intro h_abs; simp at h_abs
      · -- quant_part sub_nf = true: the existence formula holds
        simp only [h_q_val, ↓reduceIte] at h_sub_truth
        constructor
        · intro _; rfl
        · intro _; exact h_iff.mp h_sub_truth
    · -- Backward: nf_eval_nf → formula truth
      intro h_nf
      simp only [nf_eval_nf] at h_nf
      obtain ⟨h_atoms, h_quant⟩ := h_nf
      simp only [full_formula, stavi_temporal_truth]
      constructor
      · -- Atom part
        rw [sf_conjList_iff]
        intro A hA
        simp only [atom_lits, List.mem_map] at hA
        obtain ⟨ak, _, rfl⟩ := hA
        exact (atomKind_to_sf_literal_correct atomMap h_surj M t ak (nf.1 ak)).mpr
          (h_atoms ak)
      · -- Quantifier part
        rw [sf_conjList_iff]
        intro A hA
        simp only [quant_formulas, List.mem_map] at hA
        obtain ⟨sub_nf, _, rfl⟩ := hA
        have h_iff := exist_sf_correct sub_nf M t h_atoms
        by_cases h_q : nf.2 sub_nf = true
        · -- quant = true: show the existence formula holds
          simp only [h_q, ite_true]
          exact h_iff.mpr ((h_quant sub_nf).mpr h_q)
        · -- quant = false: show the negation holds
          have h_q_false : nf.2 sub_nf = false := by
            cases h_val : nf.2 sub_nf <;> simp_all
          rw [show (nf.2 sub_nf) = false from h_q_false]
          simp only [Bool.false_eq_true, ↓reduceIte, stavi_temporal_truth]
          have h_no_ex : ¬ ∃ x, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
            rw [h_quant sub_nf, h_q_false]; simp
          exact fun h => h_no_ex (h_iff.mp h)

/-- **GHR93 Theorem 9.3.1**: {U, S, U', S'} is expressively complete. -/
noncomputable def stavi_expressive_completeness
    (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t A ↔
        eval M (fun _ => t) psi } := by
  set k := psi.quantifier_depth with hk_def
  -- Choose characteristic StaviFormulas for each NF
  have nf_char := fun nf => nf_characterizable_by_stavi atomMap h_surj k nf
  let char_sf : NormalForm sig k 1 → StaviFormula :=
    fun nf => Classical.choose (nf_char nf)
  have char_correct : ∀ (nf : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t (char_sf nf) ↔
      nf_eval_nf M k 1 (fun _ => t) nf :=
    fun nf => Classical.choose_spec (nf_char nf)
  -- "good" predicate as Prop
  let good_prop : NormalForm sig k 1 → Prop :=
    fun nf => ∃ (M : OrderedMonadicStructure sig) (t : M.carrier),
      nf_eval_nf M k 1 (fun _ => t) nf ∧ eval M (fun _ => t) psi
  -- Build the disjunction via Classical.dec as a Bool filter
  let all_nfs := (Fintype.elems (α := NormalForm sig k 1)).val.toList
  let good_formulas := all_nfs.filterMap (fun nf =>
    if @decide (good_prop nf) (Classical.dec _) then some (char_sf nf) else none)
  -- Helper: good_formulas membership characterization
  have mem_good_iff : ∀ (sf : StaviFormula), sf ∈ good_formulas ↔
      ∃ nf ∈ all_nfs, good_prop nf ∧ sf = char_sf nf := by
    intro sf
    simp only [good_formulas, List.mem_filterMap]
    constructor
    · rintro ⟨nf, hnf_mem, h_ite⟩
      by_cases hg : good_prop nf
      · rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)] at h_ite
        exact ⟨nf, hnf_mem, hg, (Option.some.inj h_ite).symm⟩
      · rw [if_neg (mt (@decide_eq_true_eq _ (Classical.dec _)).mp hg)] at h_ite
        exact absurd h_ite (by simp)
    · rintro ⟨nf, hnf_mem, hg, rfl⟩
      exact ⟨nf, hnf_mem, by rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)]⟩
  -- NF determines psi (from doets_lemma_1_1 + nf_exists_unique)
  have nf_determines_psi : ∀ (nf : NormalForm sig k 1)
      (M₁ M₂ : OrderedMonadicStructure sig) (t₁ : M₁.carrier) (t₂ : M₂.carrier),
      nf_eval_nf M₁ k 1 (fun _ => t₁) nf →
      nf_eval_nf M₂ k 1 (fun _ => t₂) nf →
      (eval M₁ (fun _ => t₁) psi ↔ eval M₂ (fun _ => t₂) psi) := by
    intro nf M₁ M₂ t₁ t₂ h₁ h₂
    apply doets_lemma_1_1 k 1 psi (hk_def ▸ le_refl _) M₁ M₂ (fun _ => t₁) (fun _ => t₂)
    intro nf'
    obtain ⟨c₁, hc₁, hu₁⟩ := nf_exists_unique M₁ k 1 (fun _ => t₁)
    obtain ⟨c₂, hc₂, hu₂⟩ := nf_exists_unique M₂ k 1 (fun _ => t₂)
    simp only at hu₁ hu₂
    have h_eq₁ : c₁ = nf := (hu₁ nf h₁).symm
    have h_eq₂ : c₂ = nf := (hu₂ nf h₂).symm
    subst h_eq₁; subst h_eq₂
    constructor
    · intro h'; have := hu₁ nf' h'; subst this; exact hc₂
    · intro h'; have := hu₂ nf' h'; subst this; exact hc₁
  -- Construct the result
  refine ⟨sf_disjList good_formulas, fun M t => ?_⟩
  rw [sf_disjList_iff]
  constructor
  · -- Forward: some good NF's characteristic formula holds → psi holds
    rintro ⟨A, hA_mem, hA_eval⟩
    rw [mem_good_iff] at hA_mem
    obtain ⟨nf, _, h_good, rfl⟩ := hA_mem
    have h_nf_eval := (char_correct nf M t).mp hA_eval
    obtain ⟨M', t', hM'_nf, hM'_psi⟩ := h_good
    exact (nf_determines_psi nf M' M t' t hM'_nf h_nf_eval).mp hM'_psi
  · -- Backward: psi holds → some good NF's characteristic formula holds
    intro h_psi
    set nf_M := nf_characteristic M k 1 (fun _ => t)
    have h_nf_M := nf_characteristic_satisfies M k 1 (fun _ => t)
    have h_char_eval := (char_correct nf_M M t).mpr h_nf_M
    have h_good : good_prop nf_M := ⟨M, t, h_nf_M, h_psi⟩
    have h_in : char_sf nf_M ∈ good_formulas := by
      rw [mem_good_iff]
      exact ⟨nf_M, Multiset.mem_toList.mpr (Fintype.complete nf_M), h_good, rfl⟩
    exact ⟨char_sf nf_M, h_in, h_char_eval⟩

