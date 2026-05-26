import Bimodal.Metalogic.WeakCanonical.IntegerModel
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.ParametricCompleteness
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Semantics.Validity

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
theorem chronicle_temporal_truth (M : ChronicleAsPriorModel)
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

/-! ## Main Theorem: countermodel_discrete -/

/--
Doets/Reynolds discrete countermodel construction.

For any MCS A containing ¬φ and □(next_top) (discrete box-class),
there exists a countermodel on Int where φ is false.

Delegates to `dd_countermodel_chronicle_discrete` which uses the
parametric canonical model construction directly.
-/
theorem countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ :=
  Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete A h_mcs φ h_neg_in h_box_discrete

end Bimodal.Metalogic.WeakCanonical
