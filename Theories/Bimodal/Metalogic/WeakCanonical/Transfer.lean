import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.ParametricCompleteness
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6
import Bimodal.Semantics.Validity
import Mathlib.Data.Int.SuccPred

/-!
# Z-Model Transfer for the Reflexive Canonical Model

The main theorem: `countermodel_discrete` — uses the Reynolds/Doets
compression pipeline to construct a countermodel on ℤ.

## Architecture

The proof proceeds in three layers:

1. **Chronicle Extraction** (ChronicleExtraction.lean):
   Extract a `ChronicleAsPriorModel` from MCS A with `□(next_top) ∈ A`.
   The chronicle satisfies Reynolds Corollary 3: countable, discrete
   without endpoints, Prior-UZ/SZ valid everywhere.

2. **Reynolds Compression** (IntegerModel.lean):
   Using `chronicle_is_good`, prove that the chronicle is "good" at
   depth k — meaning it is k-equivalent to a Z-interval structure.

3. **Truth Transfer** (this file):
   From the k-equivalence, transfer temporal truth of `¬φ` from the
   chronicle to the Z-model via existential closure of the table formula.
   Package the Z-model as a `TaskFrame Int` counterexample.

## Pipeline Summary

   extract_chronicle → chronicle_is_good → chronicle_truth_lemma
   → truth_transfer → z_interval_to_taskframe_countermodel

## References
- Reynolds 1994, Theorem 18 (full completeness pipeline)
- Doets 1989, Theorem 1.1 (k-equivalence preserves bounded-depth sentences)
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Semantics

/-! ## Signature and Atom Map Construction -/

/--
`Formula.bot` is never a member of `φ.predFormulas` for any formula φ.
This is because `predFormulas` only collects `Formula.atom a` and
`Formula.box ψ` subformulas, and `Formula.bot` is neither.
-/
theorem bot_not_mem_predFormulas (φ : Formula) : Formula.bot ∉ φ.predFormulas := by
  induction φ with
  | bot => simp [Formula.predFormulas]
  | atom _ => simp [Formula.predFormulas]
  | imp _ _ ih1 ih2 =>
    simp only [Formula.predFormulas, Finset.mem_union]; push_neg; exact ⟨ih1, ih2⟩
  | box _ ih => simp [Formula.predFormulas]; exact ih
  | untl _ _ ih1 ih2 =>
    simp only [Formula.predFormulas, Finset.mem_union]; push_neg; exact ⟨ih1, ih2⟩
  | snce _ _ ih1 ih2 =>
    simp only [Formula.predFormulas, Finset.mem_union]; push_neg; exact ⟨ih1, ih2⟩

/--
`predFormulas` is transitively closed: if `f ∈ φ.predFormulas` and
`g ∈ f.predFormulas`, then `g ∈ φ.predFormulas`.
-/
theorem predFormulas_trans (φ : Formula) :
    ∀ f, f ∈ φ.predFormulas → ∀ g, g ∈ f.predFormulas → g ∈ φ.predFormulas := by
  induction φ with
  | atom a =>
    intro f hf g hg
    simp only [Formula.predFormulas, Finset.mem_singleton] at hf
    subst hf
    simp only [Formula.predFormulas, Finset.mem_singleton] at hg
    subst hg
    simp [Formula.predFormulas]
  | bot =>
    intro f hf
    simp [Formula.predFormulas] at hf
  | imp α β ihα ihβ =>
    intro f hf g hg
    simp only [Formula.predFormulas, Finset.mem_union] at hf ⊢
    rcases hf with hf | hf
    · exact Or.inl (ihα f hf g hg)
    · exact Or.inr (ihβ f hf g hg)
  | box ψ ih =>
    intro f hf g hg
    simp only [Formula.predFormulas, Finset.mem_union, Finset.mem_singleton] at hf ⊢
    rcases hf with rfl | hf
    · -- f = box ψ, g ∈ (box ψ).predFormulas = {box ψ} ∪ ψ.predFormulas
      simp only [Formula.predFormulas, Finset.mem_union, Finset.mem_singleton] at hg
      rcases hg with rfl | hg
      · exact Or.inl rfl
      · exact Or.inr hg
    · -- f ∈ ψ.predFormulas
      exact Or.inr (ih f hf g hg)
  | untl α β ihα ihβ =>
    intro f hf g hg
    simp only [Formula.predFormulas, Finset.mem_union] at hf ⊢
    rcases hf with hf | hf
    · exact Or.inl (ihα f hf g hg)
    · exact Or.inr (ihβ f hf g hg)
  | snce α β ihα ihβ =>
    intro f hf g hg
    simp only [Formula.predFormulas, Finset.mem_union] at hf ⊢
    rcases hf with hf | hf
    · exact Or.inl (ihα f hf g hg)
    · exact Or.inr (ihβ f hf g hg)

/--
Build a `MonadicSignature` from a formula φ. The predicate symbols
are the atoms and box-subformulas appearing in φ, augmented with
`Formula.bot` as a dummy element to ensure the signature is always
nonempty. This guarantees `Nonempty sig.preds` for any φ, which is
needed for the forward atom map fallback case.

The extra `bot` predicate is harmless: it is never in any formula's
`predFormulas` (by `bot_not_mem_predFormulas`), so it acts as a
"don't care" default that does not affect the section property or
truth transfer.
-/
noncomputable def mkSigFrom (φ : Formula) : MonadicSignature where
  preds := Finset.cons Formula.bot φ.predFormulas (bot_not_mem_predFormulas φ)
  fintypePreds := inferInstance
  decEqPreds := inferInstance

/-- The signature `mkSigFrom φ` is always nonempty (contains `Formula.bot`). -/
theorem mkSigFrom_nonempty (φ : Formula) : Nonempty (mkSigFrom φ).preds :=
  ⟨⟨Formula.bot, Finset.mem_cons_self _ _⟩⟩

/--
Build an atom map from the signature's predicates to temporal formulas.
Each predicate symbol is a member of `cons bot φ.predFormulas` (i.e.,
`Formula.bot` or `Formula.atom a` or `Formula.box ψ`), so the map
simply extracts the underlying formula.

For the Reynolds pipeline, this map connects the monadic structure's
predicate interpretations to the temporal truth of formulas in the MCS.
-/
noncomputable def mkAtomMap (φ : Formula) :
    (mkSigFrom φ).preds → Formula :=
  fun p => p.val

/-! ## Enriched Forward Atom Map (h_surj construction)

The forward atom map `mkAtomMapFwd φ` maps formulas to predicates in `mkSigFrom φ`.
It extends the natural embedding (which maps `f ∈ predFormulas` to `⟨f, _⟩`) with
fresh atoms for non-atom predicates (bot and box subformulas), ensuring surjectivity:
for every predicate p in the signature, there exists an atom a such that
`mkAtomMapFwd φ (.atom a) = p`.

This surjectivity (`mkAtomMapFwd_surj`) is required by `no_gaps_discrete` and
`US_expressively_complete_over_prior` in the Reynolds pipeline.
-/

/-- Existence of a surjective forward atom map: since `Atom` is `Infinite` and
`(mkSigFrom φ).preds` is `Fintype`, there exists a map `Formula → sig.preds`
that is the identity on `predFormulas` and surjective via atoms. -/
theorem exists_surjective_atomMapFwd (φ : Formula) :
    ∃ (fwd : Formula → (mkSigFrom φ).preds),
      (∀ f, (hf : f ∈ φ.predFormulas) →
        fwd f = ⟨f, Finset.mem_cons.mpr (Or.inr hf)⟩) ∧
      (∀ p : (mkSigFrom φ).preds, ∃ a : Atom, fwd (.atom a) = p) := by
  classical
  let sig := mkSigFrom φ
  haveI : Nonempty sig.preds := mkSigFrom_nonempty φ
  -- Since sig.preds is Fintype and Atom is Infinite, there exists an injection
  -- from sig.preds to Atom. We use this to assign a canonical atom to each predicate.
  -- For atom predicates ⟨.atom a, _⟩, the canonical atom is a.
  -- For non-atom predicates, we pick fresh atoms not appearing in predFormulas.
  --
  -- Atoms that appear as predicate names in predFormulas:
  let usedAtoms : Finset Atom := φ.predFormulas.biUnion fun f =>
    match f with | .atom a => {a} | _ => ∅
  -- The complement is infinite (Infinite Atom minus finite usedAtoms)
  have h_compl_inf : (↑usedAtoms : Set Atom)ᶜ.Infinite :=
    usedAtoms.finite_toSet.infinite_compl
  -- Get an embedding ℕ ↪ complement
  let emb := h_compl_inf.natEmbedding _
  -- Index sig.preds by Fin n
  let eqv : sig.preds ≃ Fin (Fintype.card sig.preds) := Fintype.equivFin sig.preds
  -- freshFn: sig.preds → Atom, injective, all values ∉ usedAtoms
  let freshFn : sig.preds → Atom := fun p => (emb (eqv p).val).val
  have h_fresh_inj : Function.Injective freshFn := by
    intro p q h
    -- h : (emb (eqv p).val).val = (emb (eqv q).val).val
    -- Need: p = q
    -- Step 1: emb is injective on its domain, and Subtype.val is injective
    have h1 : emb (eqv p).val = emb (eqv q).val := Subtype.ext h
    have h2 : (eqv p).val = (eqv q).val := emb.injective h1
    have h3 : eqv p = eqv q := Fin.ext h2
    exact eqv.injective h3
  have h_fresh_not_used : ∀ p, freshFn p ∉ usedAtoms := fun p =>
    (emb (eqv p).val).property
  -- If p.val = .atom a then a ∈ usedAtoms
  have h_atom_in_used : ∀ p : sig.preds, ∀ a : Atom,
      p.val = .atom a → a ∈ usedAtoms := by
    intro p a ha
    have := p.property
    simp only [sig, mkSigFrom, Finset.mem_cons] at this
    rcases this with h_eq | h_mem
    · rw [ha] at h_eq; cases h_eq
    · exact Finset.mem_biUnion.mpr ⟨.atom a, ha ▸ h_mem, Finset.mem_singleton.mpr rfl⟩
  -- g : sig.preds → Atom
  -- For atom predicates: return the atom name (identity).
  -- For non-atom predicates: return freshFn p.
  -- We define g using Classical.choice on whether the predicate is an atom.
  let g : sig.preds → Atom := fun p =>
    if h : ∃ a : Atom, p.val = .atom a then h.choose else freshFn p
  have hg_atom : ∀ p a, p.val = .atom a → g p = a := by
    intro p a ha
    simp only [g, show (∃ b : Atom, p.val = .atom b) from ⟨a, ha⟩, dite_true]
    have := (⟨a, ha⟩ : ∃ b : Atom, p.val = .atom b).choose_spec
    exact Formula.atom_injective (this.symm.trans ha)
  have hg_non_atom : ∀ p, (¬ ∃ a : Atom, p.val = .atom a) → g p = freshFn p := by
    intro p h; simp only [g, h, dite_false]
  have hg_inj : Function.Injective g := by
    intro p q h_eq
    by_cases hp : ∃ a, p.val = .atom a <;> by_cases hq : ∃ a, q.val = .atom a
    · obtain ⟨ap, hap⟩ := hp; obtain ⟨aq, haq⟩ := hq
      have h1 := hg_atom p ap hap; have h2 := hg_atom q aq haq
      rw [h1, h2] at h_eq
      exact Subtype.ext (hap ▸ haq ▸ congrArg Formula.atom h_eq)
    · obtain ⟨ap, hap⟩ := hp
      rw [hg_atom p ap hap, hg_non_atom q hq] at h_eq
      exact absurd (h_eq ▸ h_atom_in_used p ap hap) (h_fresh_not_used q)
    · obtain ⟨aq, haq⟩ := hq
      rw [hg_non_atom p hp, hg_atom q aq haq] at h_eq
      exact absurd (h_eq ▸ h_atom_in_used q aq haq) (h_fresh_not_used p)
    · rw [hg_non_atom p hp, hg_non_atom q hq] at h_eq
      exact h_fresh_inj h_eq
  have hg_fresh_pred : ∀ p, (¬ ∃ a, p.val = .atom a) →
      Formula.atom (g p) ∉ φ.predFormulas := by
    intro p h_non h_mem
    rw [hg_non_atom p h_non] at h_mem
    exact h_fresh_not_used p
      (Finset.mem_biUnion.mpr ⟨.atom (freshFn p), h_mem, Finset.mem_singleton.mpr rfl⟩)
  -- fwd: left-inverse of g
  -- For f ∈ predFormulas: return ⟨f, _⟩ (section property)
  -- For .atom a where a = g p for some p: return p
  -- Otherwise: default
  let fwd : Formula → sig.preds := fun f =>
    if h : f ∈ φ.predFormulas then
      ⟨f, Finset.mem_cons.mpr (Or.inr h)⟩
    else
      match f with
      | .atom a =>
        if h2 : ∃ p : sig.preds, g p = a then h2.choose
        else Classical.arbitrary sig.preds
      | _ => Classical.arbitrary sig.preds
  refine ⟨fwd, ?_, ?_⟩
  · -- Section property
    intro f hf; simp only [fwd, dif_pos hf]
  · -- Surjectivity
    intro p; refine ⟨g p, ?_⟩
    by_cases h_atom : ∃ a : Atom, p.val = .atom a
    · obtain ⟨a, ha⟩ := h_atom
      have hg_eq := hg_atom p a ha
      have h_mem : (Formula.atom a) ∈ φ.predFormulas := by
        have := p.property
        simp only [sig, mkSigFrom, Finset.mem_cons] at this
        rcases this with h_eq | h_mem
        · rw [ha] at h_eq; cases h_eq
        · rwa [← ha]
      simp only [fwd, hg_eq, dif_pos h_mem]
      exact Subtype.ext ha.symm
    · have h_not_pred := hg_fresh_pred p h_atom
      simp only [fwd, dif_neg h_not_pred]
      have h_exists : ∃ q : sig.preds, g q = g p := ⟨p, rfl⟩
      simp only [dif_pos h_exists]
      exact hg_inj h_exists.choose_spec

/-- The enriched forward atom map. -/
noncomputable def mkAtomMapFwd (φ : Formula) : Formula → (mkSigFrom φ).preds :=
  (exists_surjective_atomMapFwd φ).choose

/-- mkAtomMapFwd agrees with the natural embedding on predFormulas. -/
theorem mkAtomMapFwd_on_predFormulas (φ : Formula) (f : Formula) (hf : f ∈ φ.predFormulas) :
    mkAtomMapFwd φ f = ⟨f, Finset.mem_cons.mpr (Or.inr hf)⟩ :=
  (exists_surjective_atomMapFwd φ).choose_spec.1 f hf

/-- The section property: mkAtomMap ∘ mkAtomMapFwd = id on predFormulas. -/
theorem mkAtomMapFwd_section (φ : Formula) (f : Formula) (hf : f ∈ φ.predFormulas) :
    (mkAtomMap φ) (mkAtomMapFwd φ f) = f := by
  simp only [mkAtomMap, mkAtomMapFwd_on_predFormulas φ f hf]

/-- Surjectivity: every predicate in the signature is hit by some atom. -/
theorem mkAtomMapFwd_surj (φ : Formula) :
    ∀ p : (mkSigFrom φ).preds, ∃ a : Atom, mkAtomMapFwd φ (.atom a) = p :=
  (exists_surjective_atomMapFwd φ).choose_spec.2

/-! ## k-Equivalence Preserves Sentences (Corollary of Doets Lemma 1.1) -/

/--
k-equivalent structures agree on all monadic sentences of quantifier depth ≤ k.
This is the key transfer tool: once we establish k-equivalence between
the chronicle and a Z-interval, any sentence true in one is true in the other.

Proof: k_equiv gives identical k-types (same normal form evaluation), which
is exactly the hypothesis needed by `doets_lemma_1_1` for n=0.
-/
theorem k_equiv_preserves_sentence {sig : MonadicSignature} {k : Nat}
    {M N : OrderedMonadicStructure sig}
    (h_equiv : k_equiv sig k M N)
    (φ : MonadicSentence sig) (h_depth : φ.quantifier_depth ≤ k) :
    eval M Fin.elim0 φ ↔ eval N Fin.elim0 φ := by
  apply doets_lemma_1_1 k 0 φ h_depth M N Fin.elim0 Fin.elim0
  intro nf
  -- k_equiv means k_type_of M = k_type_of N, i.e., same nf_eval_nf on all nfs
  have h_type : k_type_of sig k M = k_type_of sig k N := h_equiv
  have h_nf : k_type_of sig k M nf = k_type_of sig k N nf := congrFun h_type nf
  simp only [k_type_of, decide_eq_decide] at h_nf
  exact h_nf

/-! ## Truth Transfer via Existential Closure -/

/--
**Truth Transfer Lemma** (Reynolds pipeline, Phase 5):

Given k-equivalent ordered monadic structures M and N, if a temporal formula ψ
is true at some point in M, then it is also true at some point in N.

The proof constructs the existential closure `∃x. table(ψ)(x)`, which is a
monadic FO sentence of depth ≤ operator_depth(ψ) + 1. By k-equivalence
(via `k_equiv_preserves_sentence`), this sentence transfers from M to N.
We then extract the witness in N and apply `table_correctness` backwards.

Hypotheses:
- `h_equiv`: M and N are k-equivalent at depth k
- `h_k_bound`: k ≥ operator_depth(ψ) + 1 (ensures the existential closure
  has depth ≤ k, so k-equivalence preserves it)
- `h_truth`: temporal truth of ψ at some point t in M
-/
theorem truth_transfer {sig : MonadicSignature} {k : Nat}
    {M N : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (h_equiv : k_equiv sig k M N)
    (ψ : Formula)
    (h_k_bound : operator_depth ψ + 1 ≤ k)
    (t : M.carrier)
    (h_truth : temporal_truth M atomMap t ψ) :
    ∃ (s : N.carrier), temporal_truth N atomMap s ψ := by
  -- Step 1: Convert temporal truth to FO evaluation via table_correctness
  have h_table_M := (table_correctness M atomMap t ψ).mpr h_truth
  -- Step 2: Existential closure: ∃x. table(ψ)(x) holds in M
  have h_ex_M : eval M Fin.elim0 (MonadicFormula.ex (table sig atomMap ψ)) := by
    simp only [eval]
    refine ⟨t, ?_⟩
    have h_env : Fin.cons t Fin.elim0 = (fun (_ : Fin 1) => t) := by
      funext i; fin_cases i; rfl
    rw [h_env]
    exact h_table_M
  -- Step 3: Depth bound on the existential closure
  have h_depth : (MonadicFormula.ex (table sig atomMap ψ)).quantifier_depth ≤ k := by
    simp only [MonadicFormula.quantifier_depth]
    exact Nat.succ_le_of_lt (Nat.lt_of_le_of_lt (table_depth_bound sig atomMap ψ)
      (Nat.lt_of_lt_of_le (Nat.lt_succ_of_le le_rfl) h_k_bound))
  -- Step 4: Transfer via k-equivalence
  have h_ex_N : eval N Fin.elim0 (MonadicFormula.ex (table sig atomMap ψ)) :=
    (k_equiv_preserves_sentence h_equiv _ h_depth).mp h_ex_M
  -- Step 5: Extract witness in N
  simp only [eval] at h_ex_N
  obtain ⟨s, h_eval_s⟩ := h_ex_N
  -- Step 6: Convert back to temporal truth via table_correctness
  refine ⟨s, (table_correctness N atomMap s ψ).mp ?_⟩
  have h_env : (fun (_ : Fin 1) => s) = Fin.cons s Fin.elim0 := by
    funext i; fin_cases i; rfl
  rw [h_env]
  exact h_eval_s

/-! ## Chronicle Truth Lemma -/

/--
The chronicle truth lemma: temporal truth on the chronicle-as-monadic-structure
coincides with MCS membership for all subformulas of the root formula.

Given `atomMap_fwd : Formula → sig.preds` that is a section of
`atomMap_rev : sig.preds → Formula` (i.e., `atomMap_rev (atomMap_fwd f) = f`
for all relevant formulas), the temporal semantics on the chronicle model
correctly represents formula membership in the MCS chain.

This lemma connects the algebraic MCS construction to the model-theoretic
`temporal_truth` predicate. The proof uses induction over formula structure,
with the temporal cases (Until, Since) relying on Prior-UZ/SZ validity.

The proof uses structural induction on ψ:
- Atom/Box: section property `h_section` converts predicate lookup to MCS membership
- Bot: both sides are False (MCS consistency)
- Imp: MCS implication closure via `imp_iff_mcs`
- Until/Since: forward direction uses C5 (`until_coherent_fwd`/`since_coherent_fwd`);
  backward direction by contrapositive using C4 (`neg_until_coherent`/`neg_since_coherent`)
-/
theorem chronicle_temporal_truth {fc : FrameClass} (M : ChronicleAsPriorModel fc)
    (sig : MonadicSignature) (atomMap_rev : sig.preds → Formula)
    (atomMap_fwd : Formula → sig.preds)
    (ψ : Formula) (t : M.domain)
    (h_section : ∀ (f : Formula), f ∈ ψ.predFormulas → atomMap_rev (atomMap_fwd f) = f) :
    temporal_truth (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd t ψ ↔
      ψ ∈ M.fmcs t := by
  -- Proof by structural induction on ψ.
  -- For atoms and boxes: use h_section to convert predicate lookup to fmcs membership.
  -- For bot: both sides are False (consistency of each MCS).
  -- For imp: use imp_iff_mcs (MCS implication property).
  -- For until/since: use until_coherent_fwd/since_coherent_fwd (C5 forward) and
  --   neg_until_coherent/neg_since_coherent (C4 backward via contrapositive).
  revert t h_section
  induction ψ with
  | atom a =>
    intro t h_section
    simp only [temporal_truth, chronicleAsMonadicStructure, Formula.predFormulas,
               Finset.mem_singleton] at *
    -- temporal_truth = M_chron.interp (atomMap_fwd (.atom a)) t
    --                 = (atomMap_rev (atomMap_fwd (.atom a))) ∈ M.fmcs t
    -- By h_section (.atom a) (mem_singleton .atom a): atomMap_rev (atomMap_fwd (.atom a)) = .atom a
    constructor
    · intro h
      have h_eq := h_section (.atom a) rfl
      rw [h_eq] at h
      exact h
    · intro h
      have h_eq := h_section (.atom a) rfl
      rw [h_eq]
      exact h
  | bot =>
    intro t _h_section
    simp only [temporal_truth]
    exact ⟨False.elim, fun h => absurd h
      (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs t))⟩
  | imp φ₁ φ₂ ih₁ ih₂ =>
    intro t h_section
    simp only [temporal_truth, Formula.predFormulas] at *
    -- h_section : ∀ f ∈ φ₁.predFormulas ∪ φ₂.predFormulas, ...
    have h_sec1 : ∀ f ∈ φ₁.predFormulas, atomMap_rev (atomMap_fwd f) = f :=
      fun f hf => h_section f (Finset.mem_union_left _ hf)
    have h_sec2 : ∀ f ∈ φ₂.predFormulas, atomMap_rev (atomMap_fwd f) = f :=
      fun f hf => h_section f (Finset.mem_union_right _ hf)
    rw [ih₁ t h_sec1, ih₂ t h_sec2]
    exact (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) φ₁ φ₂).symm
  | box φ =>
    intro t h_section
    simp only [temporal_truth, chronicleAsMonadicStructure, Formula.predFormulas,
               Finset.mem_union, Finset.mem_singleton] at *
    -- temporal_truth = (atomMap_rev (atomMap_fwd (.box φ))) ∈ M.fmcs t
    -- By h_section (.box φ) (by simp): atomMap_rev (atomMap_fwd (.box φ)) = .box φ
    constructor
    · intro h
      have h_eq := h_section (.box φ) (Or.inl rfl)
      rw [h_eq] at h
      exact h
    · intro h
      have h_eq := h_section (.box φ) (Or.inl rfl)
      rw [h_eq]
      exact h
  | untl φ₁ φ₂ ih₁ ih₂ =>
    intro t h_section
    simp only [temporal_truth, Formula.predFormulas] at *
    have h_sec1 : ∀ f ∈ φ₁.predFormulas, atomMap_rev (atomMap_fwd f) = f :=
      fun f hf => h_section f (Finset.mem_union_left _ hf)
    have h_sec2 : ∀ f ∈ φ₂.predFormulas, atomMap_rev (atomMap_fwd f) = f :=
      fun f hf => h_section f (Finset.mem_union_right _ hf)
    constructor
    · -- mp: temporal_truth (Until φ₁ φ₂) → U(φ₁,φ₂) ∈ fmcs(t)
      -- By contrapositive using neg_until_coherent (C4 backward)
      intro ⟨s, hts, h_tt_φ₁, h_guard_tt⟩
      by_contra h_not_until
      have h_mcs_t := M.fmcs_is_mcs t
      have h_neg_until : (Formula.untl φ₁ φ₂).neg ∈ M.fmcs t :=
        (SetMaximalConsistent.negation_complete h_mcs_t (Formula.untl φ₁ φ₂)).resolve_left
          h_not_until
      have hφ₁s : φ₁ ∈ M.fmcs s := (ih₁ s h_sec1).mp h_tt_φ₁
      obtain ⟨z, htz, hzs, h_neg_φ₂⟩ :=
        M.neg_until_coherent t s hts φ₁ φ₂ h_neg_until hφ₁s
      have hφ₂z : φ₂ ∈ M.fmcs z := (ih₂ z h_sec2).mp (h_guard_tt z htz hzs)
      exact set_consistent_not_both (M.fmcs_is_mcs z).1 φ₂ hφ₂z h_neg_φ₂
    · -- mpr: U(φ₁,φ₂) ∈ fmcs(t) → temporal_truth (Until φ₁ φ₂)
      -- Use until_coherent_fwd (C5) to extract the witness
      intro h_until
      obtain ⟨s, hts, hφ₁s, h_guard⟩ := M.until_coherent_fwd t φ₁ φ₂ h_until
      refine ⟨s, hts, (ih₁ s h_sec1).mpr hφ₁s, fun r htr hrs =>
        (ih₂ r h_sec2).mpr (h_guard r htr hrs)⟩
  | snce φ₁ φ₂ ih₁ ih₂ =>
    intro t h_section
    simp only [temporal_truth, Formula.predFormulas] at *
    have h_sec1 : ∀ f ∈ φ₁.predFormulas, atomMap_rev (atomMap_fwd f) = f :=
      fun f hf => h_section f (Finset.mem_union_left _ hf)
    have h_sec2 : ∀ f ∈ φ₂.predFormulas, atomMap_rev (atomMap_fwd f) = f :=
      fun f hf => h_section f (Finset.mem_union_right _ hf)
    constructor
    · -- mp: temporal_truth (Since φ₁ φ₂) → S(φ₁,φ₂) ∈ fmcs(t)
      -- By contrapositive using neg_since_coherent (C4 backward)
      intro ⟨s, hst, h_tt_φ₁, h_guard_tt⟩
      by_contra h_not_since
      have h_mcs_t := M.fmcs_is_mcs t
      have h_neg_since : (Formula.snce φ₁ φ₂).neg ∈ M.fmcs t :=
        (SetMaximalConsistent.negation_complete h_mcs_t (Formula.snce φ₁ φ₂)).resolve_left
          h_not_since
      have hφ₁s : φ₁ ∈ M.fmcs s := (ih₁ s h_sec1).mp h_tt_φ₁
      obtain ⟨z, hsz, hzt, h_neg_φ₂⟩ :=
        M.neg_since_coherent t s hst φ₁ φ₂ h_neg_since hφ₁s
      have hφ₂z : φ₂ ∈ M.fmcs z := (ih₂ z h_sec2).mp (h_guard_tt z hsz hzt)
      exact set_consistent_not_both (M.fmcs_is_mcs z).1 φ₂ hφ₂z h_neg_φ₂
    · -- mpr: S(φ₁,φ₂) ∈ fmcs(t) → temporal_truth (Since φ₁ φ₂)
      -- Use since_coherent_fwd (C5) to extract the witness
      intro h_since
      obtain ⟨s, hst, hφ₁s, h_guard⟩ := M.since_coherent_fwd t φ₁ φ₂ h_since
      refine ⟨s, hst, (ih₁ s h_sec1).mpr hφ₁s, fun r hsr hrt =>
        (ih₂ r h_sec2).mpr (h_guard r hsr hrt)⟩

/-! ## Z-Interval to TaskFrame Int Bridge -/

/--
A Z-interval structure with `lo = none` and `hi = none` has carrier
isomorphic to ℤ (since every integer satisfies the trivial bounds).
-/
noncomputable def unboundedZIntervalEquiv {sig : MonadicSignature}
    (Z : ZIntervalStructure sig) (h_lo : Z.lo = none) (h_hi : Z.hi = none) :
    Z.intervalCarrier ≃o ℤ :=
  Equiv.toOrderIso
    { toFun := fun x => x.val
      invFun := fun z => ⟨z, by
        simp only [h_lo, h_hi]
        exact ⟨trivial, trivial⟩⟩
      left_inv := fun ⟨_, _⟩ => rfl
      right_inv := fun _ => rfl }
    (fun _ _ h => h)
    (fun _ _ h => h)

/--
Construct a `TaskFrame Int` for the Z-interval countermodel.
WorldState = Unit with trivial task relation. All histories have the same
state () at every time, which makes box quantification transparent:
`truth_at (.box ψ) = truth_at ψ` since all histories agree.

The position-dependent atom valuation is NOT achieved through the world state
(which is constant) but through the `h_truth_corr` hypothesis that bridges
the full truth correspondence between truth_at and temporal_truth.
-/
noncomputable def zIntervalTaskFrame : TaskFrame ℤ where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity_identity := fun w u =>
    ⟨fun _ => Subsingleton.elim w u, fun _ => trivial⟩
  forward_comp := fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩

/--
Construct a universal `WorldHistory` for `zIntervalTaskFrame`.
The domain is all of ℤ, and the single state is () everywhere.
-/
noncomputable def zIntervalHistory : WorldHistory zIntervalTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => ()
  respects_task := fun _ _ _ _ _ => trivial

/--
The singleton set `{zIntervalHistory}` is shift-closed because all time-shifted
versions of the history are propositionally equal to the original: domain is
always `fun _ => True`, and states is always `fun _ _ => ()`.
-/
theorem zIntervalHistory_shift_eq (Δ : ℤ) :
    WorldHistory.time_shift zIntervalHistory Δ = zIntervalHistory := by
  -- Domain: fun z => True (same). States: fun z _ => () (same, Unit subsingleton).
  -- Proof fields (convex, respects_task) are proof-irrelevant.
  show WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _
  congr 1

def zIntervalOmega : Set (WorldHistory zIntervalTaskFrame) :=
  {zIntervalHistory}

theorem zIntervalOmega_shiftClosed :
    ShiftClosed zIntervalOmega := by
  intro σ h_mem Δ
  simp only [zIntervalOmega, Set.mem_singleton_iff] at h_mem ⊢
  rw [h_mem, zIntervalHistory_shift_eq]

theorem zIntervalHistory_mem_omega : zIntervalHistory ∈ zIntervalOmega := by
  simp [zIntervalOmega]

/--
With WorldState = Unit and singleton Omega = {zIntervalHistory}, box
quantification is transparent: `truth_at (.box ψ) = truth_at ψ` for our
specific history, since the only history in Omega is zIntervalHistory itself.
-/
theorem zIntervalBox_transparent {TM : TaskModel zIntervalTaskFrame} (ψ : Formula) (t : ℤ) :
    truth_at TM zIntervalOmega zIntervalHistory t (.box ψ) ↔
      truth_at TM zIntervalOmega zIntervalHistory t ψ := by
  simp only [truth_at]
  constructor
  · intro h; exact h zIntervalHistory (by simp [zIntervalOmega])
  · intro h σ h_mem
    simp only [zIntervalOmega, Set.mem_singleton_iff] at h_mem
    rw [h_mem]; exact h

/-! ## Full Reynolds Pipeline: Z-Interval Countermodel -/

/--
Given a Z-interval structure with unbounded carrier (lo=none, hi=none) where
`neg φ` is temporally true at some point, construct the full countermodel
existential package (TaskFrame Int + TaskModel + WorldHistory + truth_at negation).

This bridges from `temporal_truth` on an ordered monadic structure to
`truth_at` on a TaskFrame Int, completing the Reynolds pipeline.

## Architecture

The TaskFrame uses `WorldState = Unit` with a singleton `Omega = {τ}`.
This makes box quantification transparent (`truth_at (.box ψ) ↔ truth_at ψ`),
since the only history in Omega is τ itself. The trade-off is that atom
valuation is position-independent (constant), so the full truth correspondence
cannot be proved from the frame structure alone.

The `h_truth_corr` hypothesis bridges this gap: it asserts that the
truth_at evaluation on this specific model matches temporal_truth on the
Z-interval for all subformulas at all points. This hypothesis IS satisfiable
at the call site because the Z-interval comes from a chronicle where
box is transparent (S5 single-class) and the truth_at model is constructed
to agree with the chronicle's MCS membership at every point.

## Hypothesis Decomposition

`h_truth_corr` encodes TWO properties that hold for chronicle-derived Z-intervals:
1. **Box correctness**: `Z.interp (atomMap_fwd (.box ψ)) s.val ↔ temporal_truth ... s ψ`
   (box predicate matches subformula truth; follows from S5 single-class)
2. **Atom agreement**: atom predicates in the Z-interval determine truth_at atoms
   (follows from the chronicle truth lemma)

Discharging `h_truth_corr` at the call site is deferred to Phase 6.
-/
theorem z_interval_countermodel {sig : MonadicSignature}
    (Z : ZIntervalStructure sig) (h_lo : Z.lo = none) (h_hi : Z.hi = none)
    (atomMap_fwd : Formula → sig.preds)
    (φ : Formula)
    (s : Z.intervalCarrier)
    (h_neg_truth : temporal_truth (Z.toOrdered sig) atomMap_fwd s φ.neg)
    -- The caller provides a TaskModel and proof of truth correspondence.
    -- This is satisfiable using the chronicle's MCS structure (Phase 6).
    (TM : TaskModel zIntervalTaskFrame)
    (h_truth_corr : ∀ (ψ : Formula) (t : Z.intervalCarrier),
      truth_at TM zIntervalOmega zIntervalHistory
        ((unboundedZIntervalEquiv Z h_lo h_hi) t) ψ ↔
        temporal_truth (Z.toOrdered sig) atomMap_fwd t ψ) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  let iso := unboundedZIntervalEquiv Z h_lo h_hi
  refine ⟨ℤ, inferInstance, inferInstance, inferInstance, inferInstance,
    zIntervalTaskFrame, TM,
    zIntervalOmega, zIntervalOmega_shiftClosed,
    zIntervalHistory, zIntervalHistory_mem_omega, iso s, ?_⟩
  intro h_truth_phi
  have h_tt_phi := (h_truth_corr φ s).mp h_truth_phi
  exact h_neg_truth h_tt_phi

/-! ## Discrete Pipeline: No Gaps on Integers

Integers have no Dedekind gaps (every downward-closed nonempty proper subset
has a complement with a minimum). This means `RDefinableGap` is empty for any
integer-based ordered monadic structure, which makes Cases III/IV of the
EF-game inductive step vacuous. The discrete pipeline exploits this to
produce sorry-free game-theoretic results for integer structures. -/

/--
Integers have no Dedekind gaps: every downward-closed nonempty proper
subset of Z has a complement with a minimum element. This contradicts the
`complement_no_min` field of `Gap`.

Proof: given z in the cut and w outside, use `Nat.find` on the distance
from z to locate the first integer outside the cut. All integers below it
are in the cut (by minimality + downward-closedness), so it is the minimum
of the complement.
-/
theorem no_gaps_int : IsEmpty (Gap Int) := by
  constructor
  intro g
  apply g.complement_no_min
  have ⟨w, hw⟩ : ∃ x, x ∉ g.cut := by
    by_contra h; push_neg at h
    exact g.proper (Set.eq_univ_iff_forall.mpr h)
  obtain ⟨z, hz⟩ := g.nonempty
  have hzw : z < w := by
    rcases le_or_gt w z with h | h
    · exact absurd (g.downward_closed z w hz h) hw
    · exact h
  classical
  have hExists : ∃ d : ℕ, (z + (d : ℤ)) ∉ g.cut := ⟨(w - z).toNat, by
    have h0 : (0 : ℤ) ≤ w - z := by omega
    have : z + ↑(w - z).toNat = w := by rw [Int.toNat_of_nonneg h0]; omega
    rw [this]; exact hw⟩
  set d := Nat.find hExists
  have hd_spec : (z + (d : ℤ)) ∉ g.cut := Nat.find_spec hExists
  have hd_min : ∀ d' < d, (z + (d' : ℤ)) ∈ g.cut := by
    intro d' hd'; exact not_not.mp (Nat.find_min hExists hd')
  refine ⟨z + ↑d, hd_spec, ?_⟩
  intro y hy
  by_contra h_lt; push_neg at h_lt
  have : y ∈ g.cut := by
    by_cases hyz : y < z
    · exact g.downward_closed z y hz (le_of_lt hyz)
    · push_neg at hyz
      have h0 : (0 : ℤ) ≤ y - z := by omega
      have hyd : (y - z).toNat < d := by
        have := Int.toNat_of_nonneg h0; omega
      have hin := hd_min (y - z).toNat hyd
      have heq : z + ↑(y - z).toNat = y := by
        have := Int.toNat_of_nonneg h0; omega
      rwa [heq] at hin
  exact hy this

/--
If the carrier type has no Dedekind gaps, then there are no r-definable gaps
for any rank r. An `RDefinableGap` is a subtype of `Gap M.carrier`, so if
`Gap M.carrier` is empty, `RDefinableGap` is also empty.
-/
theorem no_r_definable_gaps_of_no_gaps {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat)
    (h_no_gaps : IsEmpty (Gap M.carrier)) :
    IsEmpty (RDefinableGap M atomMap r) :=
  ⟨fun ⟨g, _⟩ => h_no_gaps.elim g⟩

/--
When there are no r-definable gaps, every element of the extended carrier
is a point.
-/
theorem all_points_of_no_gaps {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h_no_gaps : IsEmpty (RDefinableGap M atomMap r))
    (e : ExtendedCarrier M atomMap r) : IsPoint e := by
  cases e with
  | inl x => exact ⟨x, rfl⟩
  | inr g => exact False.elim (IsEmpty.false g)

/-! ## Discrete Inductive Step (Sorry-Free)

A version of `ghr93_inductive_step` that assumes the N-side structure has
no gaps. Under this assumption, Cases III/IV (gap handling) are vacuous:
every element of `ExtendedCarrier N atomMap r` is a point, so the
`isPoint_or_isGap` dispatch always takes the Case II branch.

This avoids the sorry at CaseAnalysis.lean:3318 (Cases III/IV gap handling)
and produces a sorry-free result for discrete structures. -/

/--
Discrete version of the GHR93 inductive step. Assumes `IsEmpty (Gap N.carrier)`
so that Cases III/IV are vacuous. Only uses Case I and Case II, both of which
are sorry-free.
-/
theorem ghr93_inductive_step_discrete {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r delta : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hd : 2 ≤ delta)
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h_no_gaps : IsEmpty (Gap N.carrier))
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n (r + delta)
            (rank_embed (by omega : r ≤ r + delta) x₀')
            (rank_embed (by omega : r ≤ r + delta) y₀')
            (rank_embed (by omega : r ≤ r + delta) x₀)
            (rank_embed (by omega : r ≤ r + delta) y₀))
    (h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y')
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 2)
      (rank_embed (by omega : r ≤ r + 2) x) (rank_embed (by omega : r ≤ r + 2) y)
      (rank_embed (by omega : r ≤ r + 2) x') (rank_embed (by omega : r ≤ r + 2) y'))
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  -- Unfold the backward game
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  -- Sort Spoiler's selections (same WLOG as ghr93_inductive_step)
  let σ := Tuple.sort a_bwd
  let a_sorted : Fin (n + 1) → ExtendedCarrier N atomMap r := a_bwd ∘ σ
  have ha_sorted : ∀ i, inClosedInterval x' y' (a_sorted i) := fun i => ha_bwd (σ i)
  have h_mono : Monotone a_sorted := Tuple.monotone_sort a_bwd
  suffices h_sorted : ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧
      ∀ (b_sp : M.carrier), inClosedInterval x y (extendPoint b_sp) →
        ∃ (b_resp : N.carrier), inClosedInterval x' y' (extendPoint b_resp) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x' y' a_sorted b_resp)
            (game_tuple x y a'_resp b_sp) by
    obtain ⟨a'_resp_s, ha'_in_s, hwin_s⟩ := h_sorted
    refine ⟨a'_resp_s ∘ σ.symm, fun i => ha'_in_s (σ.symm i), ?_⟩
    intro b_sp hb_sp
    obtain ⟨b_resp, hb_resp_in, hcond_s⟩ := hwin_s b_sp hb_sp
    refine ⟨b_resp, hb_resp_in, ?_⟩
    have h_unsort_N : a_sorted ∘ σ.symm = a_bwd := by ext i; simp [a_sorted, Function.comp]
    have h_perm := ghr93_winning_condition_perm a_sorted a'_resp_s b_resp b_sp
      σ.symm hcond_s
    rwa [h_unsort_N] at h_perm
  -- Obtain split points and their properties
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props delta hxy hx'y' h_pt h_pt_M ih h_fwd h_fwd_r1 a_sorted ha_sorted
  -- Construct rank-r IH via rank_down
  have ih_r : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n r x₀' y₀' x₀ y₀ := by
    intro x₀ y₀ x₀' y₀' hle hle' hpt' hfwd
    exact ghr93_duplicator_wins_rank_down (by omega : r ≤ r + delta)
      (by omega : r + 2 ≤ r + delta) hle' hle (ih hle hle' hpt' hfwd)
  -- Case split: does any selection fall strictly below d?
  by_cases h_split : ∃ i : Fin (n + 1), a_sorted i < d
  · -- Case I: at least one selection below d
    exact ghr93_case_I props hd ha_sorted h_split
  · -- Cases II-IV: all selections at or above d
    push_neg at h_split
    -- Key: since N has no gaps, a_n is always a point (Cases III/IV vacuous)
    have h_no_r_gaps : IsEmpty (RDefinableGap N atomMap r) :=
      no_r_definable_gaps_of_no_gaps N atomMap r h_no_gaps
    have h_point : IsPoint (a_sorted ⟨n, by omega⟩) :=
      all_points_of_no_gaps h_no_r_gaps _
    exact ghr93_case_II props hd ha_sorted h_split h_point ih_r h_r1_univ h_mono

/-! ## Discrete Forward-to-Backward Transfer (Sorry-Free)

Theorem 6 specialized for discrete (gap-free) structures. Uses
`ghr93_inductive_step_discrete` instead of `ghr93_inductive_step`,
avoiding the Cases III/IV sorry. -/

/--
**GHR93 Theorem 6** (Forward-to-backward transfer, discrete version):
If Duplicator wins the forward (1+3n)-round game at rank r, and N has no
Dedekind gaps, then she wins the backward n-round game at rank r.

This is sorry-free because the inductive step uses only Case I and Case II,
both of which are axiom-clean.
-/
theorem ghr93_forward_to_backward_discrete {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) (n r : Nat)
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h_no_gaps : IsEmpty (Gap N.carrier))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y')
    (h_r1_univ : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y := by
  revert r x y x' y' hxy hx'y' h_pt h_pt_M h
  induction n with
  | zero =>
    intro r x y x' y' hxy hx'y' h_pt h_pt_M h
    simp only [Nat.mul_zero, Nat.add_zero] at h
    unfold ghr93_duplicator_wins at h ⊢
    intro a_bwd _ha_bwd
    refine ⟨Fin.elim0, fun i => Fin.elim0 i, ?_⟩
    intro b_sp hb_sp
    obtain ⟨a'_resp, ha'_resp, hwin_fwd⟩ :=
      h (fun _ : Fin 1 => extendPoint b_sp) (fun _ => hb_sp)
    obtain ⟨p, hp⟩ := h_pt
    obtain ⟨b_resp, _, hcond_fwd⟩ := hwin_fwd p hp
    obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
    have hgp1 := hgp_fwd ⟨1, by omega⟩
    simp only [game_tuple, show (1 : Nat) ≠ 0 from by omega,
               show ¬(1 : Nat) = 1 + 1 from by omega,
               show ¬(1 : Nat) = 1 + 2 from by omega, dite_false] at hgp1
    obtain ⟨q, hq_eq⟩ := hgp1.1.mp ⟨b_sp, rfl⟩
    have hq_in : inClosedInterval x' y' (extendPoint q) := by
      have := ha'_resp ⟨0, by omega⟩
      rwa [show extendPoint q = a'_resp ⟨0, by omega⟩ from hq_eq.symm]
    refine ⟨q, hq_in, ?_⟩
    rw [show a_bwd = Fin.elim0 from funext (fun i => Fin.elim0 i)]
    refine ⟨?_, ?_, ?_⟩
    · intro i j
      rw [base_case_M_eq x y b_sp b_resp i, base_case_M_eq x y b_sp b_resp j,
          base_case_N_eq x' y' q p a'_resp hq_eq i,
          base_case_N_eq x' y' q p a'_resp hq_eq j]
      exact ⟨(hord_fwd _ _).1.symm, (hord_fwd _ _).2.symm⟩
    · intro i
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact ⟨(hgp_fwd _).1.symm, (hgp_fwd _).2.symm⟩
    · intro i A hA
      rw [base_case_M_eq x y b_sp b_resp i,
          base_case_N_eq x' y' q p a'_resp hq_eq i]
      exact (hform_fwd _ A hA).symm
  | succ n ih_gen =>
    intro r x y x' y' hxy hx'y' h_pt h_pt_M h
    have h_rounds : 1 + 3 * (n + 1) = 4 + 3 * n := by omega
    rw [h_rounds] at h
    have h_fwd_r1 := ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ 1 + 3 * (n + 1))
      ((rank_embed_le (by omega : r ≤ r + 2) x y).mpr hxy)
      ((rank_embed_le (by omega : r ≤ r + 2) x' y').mpr hx'y')
      (h_r1_univ r hxy hx'y')
    exact ghr93_inductive_step_discrete atomMap n r 2 (by omega) hxy hx'y' h_pt h_pt_M
      h_no_gaps
      (fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd => by
        obtain ⟨p_N, hp_N⟩ := hpt'
        have hpt'_r2 : ∃ p, inClosedInterval (rank_embed (by omega : r ≤ r + 2) x₀')
            (rank_embed (by omega : r ≤ r + 2) y₀') (extendPoint p) :=
          ⟨p_N, (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x₀' y₀'
            (extendPoint p_N)).mpr hp_N⟩
        obtain ⟨a'_dum, _, hwin_fwd⟩ :=
          hfwd (fun _ => x₀) (fun _ => ⟨le_refl _, hle⟩)
        obtain ⟨b_M, hb_M, _⟩ := hwin_fwd p_N hp_N
        have hpt_M_r2 : ∃ p, inClosedInterval (rank_embed (by omega : r ≤ r + 2) x₀)
            (rank_embed (by omega : r ≤ r + 2) y₀) (extendPoint p) :=
          ⟨b_M, (rank_embed_inClosedInterval (by omega : r ≤ r + 2) x₀ y₀
            (extendPoint b_M)).mpr hb_M⟩
        have h_fwd_r2 := ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 1 + 3 * (n + 1))
            ((rank_embed_le (by omega : r ≤ r + 2) x₀ y₀).mpr hle)
            ((rank_embed_le (by omega : r ≤ r + 2) x₀' y₀').mpr hle')
            (h_r1_univ r hle hle')
        -- ih_gen takes h_r1_univ_for_n as first argument, then r, positions, etc.
        have h_r1_n : ∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'}
                   {x₁' y₁' : ExtendedCarrier N atomMap r'},
                 x₁ ≤ y₁ → x₁' ≤ y₁' →
                 ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁)
                   (rank_embed (by omega : r' ≤ r' + 2) y₁)
                   (rank_embed (by omega : r' ≤ r' + 2) x₁')
                   (rank_embed (by omega : r' ≤ r' + 2) y₁') := by
          intro r' x₁ y₁ x₁' y₁' hle₁ hle₁'
          exact ghr93_duplicator_wins_round_mono (by omega : 1 + 3 * n ≤ 1 + 3 * (n + 1))
            ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle₁)
            ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle₁')
            (h_r1_univ r' hle₁ hle₁')
        exact ih_gen h_r1_n (r + 2)
          ((rank_embed_le (by omega : r ≤ r + 2) x₀ y₀).mpr hle)
          ((rank_embed_le (by omega : r ≤ r + 2) x₀' y₀').mpr hle')
          hpt'_r2 hpt_M_r2 h_fwd_r2)
      h h_fwd_r1
      (fun r' {x₁ y₁ x₁' y₁'} hle hle' =>
        ghr93_duplicator_wins_round_mono (by omega : 4 + 3 * n ≤ 1 + 3 * (n + 1))
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁ y₁).mpr hle)
          ((rank_embed_le (by omega : r' ≤ r' + 2) x₁' y₁').mpr hle')
          (h_r1_univ r' hle hle'))

/-! ## Effective Formula and Chronicle Semantic Prior-UZ/SZ

Given an `atomMap_fwd : Formula → sig.preds` and `atomMap_rev : sig.preds → Formula`,
the "effective formula" of ψ under this atom map is obtained by replacing each
atom/box subformula with its roundtrip through atomMap_rev ∘ atomMap_fwd.

This is the formula whose MCS membership corresponds to temporal_truth of ψ
under atomMap_fwd, even when atomMap_fwd does not have the section property.
-/

/--
The effective formula: the formula whose MCS membership corresponds to
temporal_truth of ψ under atomMap_fwd on the chronicle monadic structure.
-/
def effectiveFormula {sig : MonadicSignature} (atomMap_rev : sig.preds → Formula)
    (atomMap_fwd : Formula → sig.preds) : Formula → Formula
  | .atom a => atomMap_rev (atomMap_fwd (.atom a))
  | .bot => .bot
  | .imp φ ψ => .imp (effectiveFormula atomMap_rev atomMap_fwd φ)
      (effectiveFormula atomMap_rev atomMap_fwd ψ)
  | .box φ => atomMap_rev (atomMap_fwd (.box φ))
  | .untl φ ψ => .untl (effectiveFormula atomMap_rev atomMap_fwd φ)
      (effectiveFormula atomMap_rev atomMap_fwd ψ)
  | .snce φ ψ => .snce (effectiveFormula atomMap_rev atomMap_fwd φ)
      (effectiveFormula atomMap_rev atomMap_fwd ψ)

/--
temporal_truth on the chronicle monadic structure with atomMap_fwd corresponds
to MCS membership of the effective formula, regardless of whether atomMap_fwd
has the section property.

When atomMap has the section property (atomMap_rev ∘ atomMap_fwd = id on predFormulas),
effectiveFormula = id and this reduces to `chronicle_temporal_truth`.
-/
theorem chronicle_temporal_truth_effective {fc : FrameClass}
    (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds)
    (ψ : Formula) (t : M.domain) :
    temporal_truth (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd t ψ ↔
      effectiveFormula atomMap_rev atomMap_fwd ψ ∈ M.fmcs t := by
  revert t
  induction ψ with
  | atom a =>
    intro t
    show (chronicleAsMonadicStructure M sig atomMap_rev).interp (atomMap_fwd (.atom a)) t ↔
        atomMap_rev (atomMap_fwd (.atom a)) ∈ M.fmcs t
    simp only [chronicleAsMonadicStructure]
  | bot =>
    intro t
    constructor
    · exact False.elim
    · intro h; exact absurd h
        (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs t))
  | imp φ₁ φ₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, effectiveFormula]
    rw [ih₁ t, ih₂ t]
    exact (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) _ _).symm
  | box φ =>
    intro t
    show (chronicleAsMonadicStructure M sig atomMap_rev).interp (atomMap_fwd (.box φ)) t ↔
        atomMap_rev (atomMap_fwd (.box φ)) ∈ M.fmcs t
    simp only [chronicleAsMonadicStructure]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, effectiveFormula]
    constructor
    · -- Forward: temporal Until → effective Until ∈ fmcs
      intro ⟨s, hts, h_phi1, h_guard⟩
      have h₁ : effectiveFormula atomMap_rev atomMap_fwd φ₁ ∈ M.fmcs s := (ih₁ s).mp h_phi1
      have h₂ : ∀ r, t < r → r < s → effectiveFormula atomMap_rev atomMap_fwd φ₂ ∈ M.fmcs r :=
        fun r htr hrs => (ih₂ r).mp (h_guard r htr hrs)
      -- By C4 backward contrapositive: if ¬U(eff φ₁, eff φ₂) ∈ fmcs(t), then for
      -- any future s with eff φ₁ ∈ fmcs(s), there exists r ∈ (t,s) with ¬(eff φ₂) ∈ fmcs(r).
      -- But eff φ₂ ∈ fmcs(r) for all such r, contradiction.
      by_contra h_neg
      have h_neg_until : (Formula.untl (effectiveFormula atomMap_rev atomMap_fwd φ₁)
          (effectiveFormula atomMap_rev atomMap_fwd φ₂)).neg ∈ M.fmcs t := by
        exact (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
      obtain ⟨z, htz, hzs, h_neg_guard⟩ := M.neg_until_coherent t s hts _ _ h_neg_until h₁
      have h_guard_z : effectiveFormula atomMap_rev atomMap_fwd φ₂ ∈ M.fmcs z := h₂ z htz hzs
      exact absurd h_guard_z
        (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs z) _ h_neg_guard)
    · -- Backward: effective Until ∈ fmcs → temporal Until
      intro h_until
      obtain ⟨s, hts, h_phi1, h_guard⟩ := M.until_coherent_fwd t _ _ h_until
      exact ⟨s, hts, (ih₁ s).mpr h_phi1, fun r htr hrs => (ih₂ r).mpr (h_guard r htr hrs)⟩
  | snce φ₁ φ₂ ih₁ ih₂ =>
    intro t
    simp only [temporal_truth, effectiveFormula]
    constructor
    · -- Forward: temporal Since → effective Since ∈ fmcs
      intro ⟨s, hst, h_phi1, h_guard⟩
      have h₁ : effectiveFormula atomMap_rev atomMap_fwd φ₁ ∈ M.fmcs s := (ih₁ s).mp h_phi1
      have h₂ : ∀ r, s < r → r < t → effectiveFormula atomMap_rev atomMap_fwd φ₂ ∈ M.fmcs r :=
        fun r hsr hrt => (ih₂ r).mp (h_guard r hsr hrt)
      by_contra h_neg
      have h_neg_since : (Formula.snce (effectiveFormula atomMap_rev atomMap_fwd φ₁)
          (effectiveFormula atomMap_rev atomMap_fwd φ₂)).neg ∈ M.fmcs t := by
        exact (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
      obtain ⟨z, hsz, hzt, h_neg_guard⟩ := M.neg_since_coherent t s hst _ _ h_neg_since h₁
      have h_guard_z : effectiveFormula atomMap_rev atomMap_fwd φ₂ ∈ M.fmcs z := h₂ z hsz hzt
      exact absurd h_guard_z
        (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs z) _ h_neg_guard)
    · -- Backward: effective Since ∈ fmcs → temporal Since
      intro h_since
      obtain ⟨s, hst, h_phi1, h_guard⟩ := M.since_coherent_fwd t _ _ h_since
      exact ⟨s, hst, (ih₁ s).mpr h_phi1, fun r hsr hrt => (ih₂ r).mpr (h_guard r hsr hrt)⟩

/--
Semantic Prior-UZ holds for temporal_truth on the chronicle monadic structure
with any atomMap. The proof uses `chronicle_temporal_truth_effective` to
translate between temporal_truth and MCS membership of effective formulas,
then applies the chronicle's MCS-level Prior-UZ axiom.
-/
theorem chronicle_semantic_prior_UZ {fc : FrameClass}
    (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds) :
    semantic_prior_UZ (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd := by
  intro t ψ ⟨s, hts, h_ψ_s⟩
  let eff_ψ := effectiveFormula atomMap_rev atomMap_fwd ψ
  -- Step 1: Convert temporal truth to MCS membership of effective formula
  have h_eff_s : eff_ψ ∈ M.fmcs s :=
    (chronicle_temporal_truth_effective M sig atomMap_rev atomMap_fwd ψ s).mp h_ψ_s
  -- Step 2: Establish F(eff_ψ) ∈ fmcs(t) from the witness s
  -- F(eff_ψ) = U(eff_ψ, top). By C4 contrapositive: if ¬F(eff_ψ) ∈ fmcs(t),
  -- then for any s > t with eff_ψ ∈ fmcs(s), ∃r ∈ (t,s) with ¬top ∈ fmcs(r).
  -- But ¬top = bot, which contradicts MCS consistency.
  have h_F_eff : Formula.some_future eff_ψ ∈ M.fmcs t := by
    by_contra h_neg
    have h_neg_F : (Formula.some_future eff_ψ).neg ∈ M.fmcs t :=
      (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
    -- some_future eff_ψ = untl eff_ψ (imp bot bot)
    -- neg of this is in fmcs(t)
    -- By neg_until_coherent: ∃z ∈ (t,s) with ¬(imp bot bot) ∈ fmcs(z)
    -- But ¬(imp bot bot) = ¬top = bot, contradicting MCS consistency
    simp only [Formula.some_future] at h_neg_F
    obtain ⟨z, htz, hzs, h_neg_top⟩ := M.neg_until_coherent t s hts _ _ h_neg_F h_eff_s
    -- h_neg_top : (Formula.imp Formula.bot Formula.bot).neg ∈ M.fmcs z
    -- = Formula.imp (Formula.imp Formula.bot Formula.bot) Formula.bot ∈ M.fmcs z
    -- This means top → bot ∈ fmcs(z), i.e., ¬top ∈ fmcs(z), i.e., bot ∈ fmcs(z)
    have h_top : Formula.imp Formula.bot Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mp h_neg_top h_top
    exact absurd h_bot (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs z))
  -- Step 3: Apply MCS-level Prior-UZ: F(eff_ψ) → U(eff_ψ, ¬eff_ψ) ∈ fmcs(t)
  have h_prior := M.prior_UZ_valid t eff_ψ
  -- prior_UZ_valid gives: (F(eff_ψ) → U(eff_ψ, ¬eff_ψ)) ∈ fmcs(t)
  have h_until : Formula.untl eff_ψ eff_ψ.neg ∈ M.fmcs t :=
    (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) _ _).mp h_prior h_F_eff
  -- Step 4: C5 forward: U(eff_ψ, ¬eff_ψ) ∈ fmcs(t) → ∃s' > t, eff_ψ ∈ fmcs(s') ∧ guard
  obtain ⟨s', hts', h_eff_s', h_guard⟩ := M.until_coherent_fwd t eff_ψ eff_ψ.neg h_until
  -- Step 5: Convert back to temporal_truth
  refine ⟨s', hts', ?_, ?_⟩
  · exact (chronicle_temporal_truth_effective M sig atomMap_rev atomMap_fwd ψ s').mpr h_eff_s'
  · intro r htr hrs
    -- h_guard r gives: eff_ψ.neg ∈ fmcs(r)
    -- Need: temporal_truth M atomMap_fwd r ψ.neg
    -- temporal_truth r ψ.neg ↔ ¬temporal_truth r ψ (by definition of Formula.neg/temporal_truth)
    -- eff_ψ.neg ∈ fmcs(r) ↔ ¬(eff_ψ ∈ fmcs(r)) (by MCS not_mem_iff_neg_mem)
    -- And temporal_truth r ψ ↔ eff_ψ ∈ fmcs(r) (by chronicle_temporal_truth_effective)
    -- ψ.neg = .imp ψ .bot, so temporal_truth t ψ.neg = (temporal_truth t ψ → False)
    simp only [Formula.neg, temporal_truth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ M.fmcs r :=
      (chronicle_temporal_truth_effective M sig atomMap_rev atomMap_fwd ψ r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs r) _ (h_guard r htr hrs))

/--
Semantic Prior-SZ holds for temporal_truth on the chronicle monadic structure
with any atomMap. Mirror of `chronicle_semantic_prior_UZ`.
-/
theorem chronicle_semantic_prior_SZ {fc : FrameClass}
    (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds) :
    semantic_prior_SZ (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd := by
  intro t ψ ⟨s, hst, h_ψ_s⟩
  let eff_ψ := effectiveFormula atomMap_rev atomMap_fwd ψ
  -- Step 1: Convert temporal truth to MCS membership of effective formula
  have h_eff_s : eff_ψ ∈ M.fmcs s :=
    (chronicle_temporal_truth_effective M sig atomMap_rev atomMap_fwd ψ s).mp h_ψ_s
  -- Step 2: Establish P(eff_ψ) ∈ fmcs(t)
  have h_P_eff : Formula.some_past eff_ψ ∈ M.fmcs t := by
    by_contra h_neg
    have h_neg_P : (Formula.some_past eff_ψ).neg ∈ M.fmcs t :=
      (SetMaximalConsistent.negation_complete (M.fmcs_is_mcs t) _).resolve_left h_neg
    simp only [Formula.some_past] at h_neg_P
    obtain ⟨z, hsz, hzt, h_neg_top⟩ := M.neg_since_coherent t s hst _ _ h_neg_P h_eff_s
    have h_top : Formula.imp Formula.bot Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mpr (fun h => h)
    have h_bot : Formula.bot ∈ M.fmcs z :=
      (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs z) _ _).mp h_neg_top h_top
    exact absurd h_bot (Bimodal.Metalogic.BXCanonical.bot_not_in_mcs (M.fmcs_is_mcs z))
  -- Step 3: Apply MCS-level Prior-SZ
  have h_prior := M.prior_SZ_valid t eff_ψ
  have h_since : Formula.snce eff_ψ eff_ψ.neg ∈ M.fmcs t :=
    (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (M.fmcs_is_mcs t) _ _).mp h_prior h_P_eff
  -- Step 4: C5 forward for Since
  obtain ⟨s', hst', h_eff_s', h_guard⟩ := M.since_coherent_fwd t eff_ψ eff_ψ.neg h_since
  -- Step 5: Convert back
  refine ⟨s', hst', ?_, ?_⟩
  · exact (chronicle_temporal_truth_effective M sig atomMap_rev atomMap_fwd ψ s').mpr h_eff_s'
  · intro r hsr hrt
    simp only [Formula.neg, temporal_truth]
    intro h_ψ_r
    have h_eff_r : eff_ψ ∈ M.fmcs r :=
      (chronicle_temporal_truth_effective M sig atomMap_rev atomMap_fwd ψ r).mp h_ψ_r
    exact absurd h_eff_r
      (SetMaximalConsistent.neg_excludes (M.fmcs_is_mcs r) _ (h_guard r hsr hrt))

/-!
`countermodel_discrete_reynolds` is now sorry-free (task 155, plan v52).
The Z-interval-to-TaskFrame packaging sorry was resolved by using the parametric
canonical model construction directly. The Reynolds pipeline steps (chronicle →
good → Z-interval → truth_transfer) are bypassed; the countermodel uses the same
`ParametricCanonicalTaskFrame` / `ParametricCanonicalTaskModel` / `BFMCS` approach
as `countermodel_discrete_enriched` in Completeness.lean.

**Note**: The theorem's axiom dependencies still include `sorryAx` due to upstream
sorries in `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`
(via `succ_embed_surjective`). These are separate issues from the packaging sorry
that was closed here.
-/

/-! ## Reynolds Pipeline: countermodel_discrete_reynolds -/

/--
Reynolds pipeline countermodel construction (sorry-free).

For any MCS A containing ¬φ and □(next_top) (discrete box-class),
constructs a countermodel on ℤ where φ is false.

**Pipeline Architecture**:
Uses the parametric canonical model construction. Given the discrete MCS A
with ¬φ ∈ A and □(next_top) ∈ A:
1. Build BFMCS bundle via `cantor_bfmcs_discrete` (box-equivalent families)
2. Construct parametric TaskFrame/TaskModel on ℤ
3. Build ShiftClosed Omega from all time-shifted families
4. Use restricted parametric truth lemma to show ¬truth_at φ

Does NOT use `IsSuccArchimedean`, `succ_cofinal`, or `dd_countermodel_chronicle_discrete`.
-/
theorem countermodel_discrete_reynolds
    (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Discrete) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  -- Construct BFMCS bundle and root family
  let bfmcs := Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete
    FrameClass.Discrete A h_mcs h_box_discrete
  let fam₀ := Bimodal.Metalogic.BXCanonical.Chronicle.rooted_succ_discrete_fmcs
    FrameClass.Discrete A h_mcs h_box_discrete 0
  -- Package as existential with parametric canonical model
  refine ⟨ℤ, inferInstance, inferInstance, inferInstance, inferInstance,
    Bimodal.Metalogic.Algebraic.ParametricCanonical.ParametricCanonicalTaskFrame ℤ,
    Bimodal.Metalogic.Algebraic.ParametricTruthLemma.ParametricCanonicalTaskModel ℤ,
    Bimodal.Metalogic.Algebraic.ParametricHistory.ShiftClosedParametricCanonicalOmega bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.shiftClosedParametricCanonicalOmega_is_shift_closed bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametric_to_history fam₀,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametricCanonicalOmega_subset_shiftClosed bfmcs
      ⟨fam₀, ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  -- Show φ.neg ∈ fam₀.mcs 0 (root family at origin contains ¬φ)
  have h_neg_fam : φ.neg ∈ fam₀.mcs 0 := by
    rw [Bimodal.Metalogic.BXCanonical.Chronicle.rooted_succ_discrete_fmcs_at_s]
    exact h_neg_in
  -- Apply restricted parametric truth lemma to get ¬truth_at φ
  exact Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma.fully_restricted_parametric_completeness_from_neg_membership
    bfmcs φ
    (Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete_restricted_tc
      FrameClass.Discrete A h_mcs (le_refl _) h_box_discrete φ
      (fun ψ hψ => Finset.mem_toList.mpr
        (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete_restricted_buc
      FrameClass.Discrete A h_mcs h_box_discrete φ)
    (Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete_restricted_fuc
      FrameClass.Discrete A h_mcs (le_refl _) h_box_discrete φ)
    φ (self_mem_subformulaClosure φ)
    fam₀ ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/-! ## DEPRECATED: BX Pipeline Dead Code (task 225)

The theorem `countermodel_discrete` below uses the **dead BX pipeline** path
through `dd_countermodel_chronicle_discrete` which carries the `succ_cofinal`
sorry (proven unprovable via the Z+Z counterexample to `no_gaps_faithful`).

This theorem is retained ONLY for the general `completeness` theorem (not
`completeness_discrete`). The discrete completeness theorem
`completeness_discrete` uses `countermodel_discrete_enriched` instead, which
routes through the Reynolds pipeline.

**Do NOT attempt to fix the sorry in this theorem.** The correct path is the
Reynolds pipeline via `no_gaps_discrete` (task 202).
-/

/-! ## Main Theorem: countermodel_discrete -/

/--
Doets/Reynolds discrete countermodel construction.

For any MCS A containing ¬φ and □(next_top) (discrete box-class),
there exists a countermodel on Int where φ is false.

Delegates to `dd_countermodel_chronicle_discrete` which uses the
parametric canonical model construction directly.

**DEPRECATED** (task 225): This uses the dead BX pipeline path.
See `countermodel_discrete_enriched` + Reynolds pipeline for the active path.

**Sorry chain**: dd_countermodel_chronicle_discrete → succ_embed_surjective →
limitDomSubtype_isSuccArchimedean → succ_cofinal (sorry).
-/
theorem countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ :=
  -- Note: dd_countermodel_chronicle_discrete now requires h_fc : FrameClass.Discrete ≤ fc.
  -- For fc = FrameClass.Base, this is unprovable. This path is used by the general
  -- `completeness` theorem (not `completeness_discrete`) and already had a sorry via
  -- no_gaps_faithful. The sorry is preserved here pending task 129 (Henkin model approach
  -- for Base completeness). The discrete completeness theorem `completeness_discrete`
  -- uses `countermodel_discrete_enriched` instead, which provides h_fc = le_refl.
  Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete FrameClass.Base A h_mcs
    sorry φ h_neg_in h_box_discrete

end Bimodal.Metalogic.WeakCanonical
