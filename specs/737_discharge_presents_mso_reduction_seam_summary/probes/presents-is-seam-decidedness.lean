/-
Research prototype for the `Presents` discharge question (task 737, research phase).

Part 1. The single-family bundle `Presents M τ t φ sig k T S` is inhabited, for ANY `sig`, `k`,
iff `φ` is `⊡`-decided at the seam: `⊡φ ∨ ⊡¬φ` at `(τ, t)`. Forward uses only `colours`,
`determined`, `verdict` and `family_saturation`; backward is the trivial constant-target witness.
Part 2. A concrete regular ℤ-frame seam (the E2 fixture, transcribed) that is NOT decided, so
no `Presents` inhabitant exists there for any parameters.
Part 3. The corrected shape: a two-letter trace encoding, `T` the depth-1 sentence
`∃x (now x ∧ φ x)` (k-type-determined by Doets 1.1), and the hit set of realized family
triples; the `⊡` bridge is then a THEOREM over a finite conjunction, with no hypothesis bundle,
and the entire residue is the hit set.
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe737Presents

/-! ## Part 1: the single-family bundle is seam decidedness -/

section Obstruction

variable {F : FrameOver intOrder} [F.IsRegular]

/-- `φ` is `⊡`-decided at the seam `(τ, t)`: every history through the seam state agrees on it. -/
def SeamDecided (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) : Prop :=
  PlusTruthAt M τ t (.stab φ) ∨ PlusTruthAt M τ t (.stab φ.neg)

/-- **Obstruction.** `colours` + `determined` + `verdict` force every ray pair to agree on `φ`.
`realized` is not used. -/
theorem seamDecided_of_presents {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : ℕ} {T : (sig.preds → ℤ → Prop) → Prop} {S : SeamSummary sig k}
    (h : Presents M τ t φ sig k T S) : SeamDecided M τ t φ := by
  by_cases hS : S.holds = true
  · exact Or.inl ((plusStab_iff_seamSummary h).mpr hS)
  · right
    rw [plusStab_iff_omega]
    intro bf
    rw [PlusTruth.neg_iff]
    intro hφ
    obtain ⟨c, hc, hbf⟩ := h.colours bf
    obtain ⟨c₀, hc₀, hv⟩ := h.verdict
    have hT₀ : ¬ T c₀ := fun hT => hS (hv.mpr hT)
    rcases family_saturation sig k h.determined S.τneg S.τzero S.τpos with hin | hout
    · exact hT₀ (hin c₀ hc₀)
    · exact hout c hc (hbf.mp hφ)

/-- **Trivial witness.** When the seam is decided, the constant target carrying the answer
inhabits `Presents` for every `sig` and `k`. -/
theorem exists_presents_of_seamDecided {M : TaskModel F.toTaskFrame}
    {τ : WorldHistory F.toTaskFrame} {t : ℤ} {φ : PlusFormula} (hdec : SeamDecided M τ t φ)
    (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) :
    ∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S := by
  classical
  obtain ⟨τneg, τzero, τpos, hfam⟩ := family_cover sig k (fun _ _ => True)
  have hval : ∀ bf : SeqPair F (τ.state t),
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔
        PlusTruthAt M τ t (.stab φ)) := by
    intro bf
    rcases hdec with hall | hnone
    · exact ⟨fun _ => hall, fun h => (plusStab_iff_omega M τ t φ).mp h bf⟩
    · have hn := (plusStab_iff_omega M τ t φ.neg).mp hnone bf
      rw [PlusTruth.neg_iff] at hn
      exact ⟨fun h => absurd h hn, fun h => absurd ((plusStab_iff_omega M τ t φ).mp h bf) hn⟩
  refine ⟨fun _ => PlusTruthAt M τ t (.stab φ),
    ⟨τneg, τzero, τpos, decide (PlusTruthAt M τ t (.stab φ))⟩, ?_, ?_, ?_, ?_⟩
  · intro bf
    exact ⟨fun _ _ => True, hfam, hval bf⟩
  · intro c c' _
    exact Iff.rfl
  · intro c _
    exact ⟨seamOmegaEquiv t (τ.state t) ⟨τ, rfl⟩, hval _⟩
  · exact ⟨fun _ _ => True, hfam, decide_eq_true_iff⟩

/-- **The characterization.** The parameters are inert: for every `sig`, `k`, the bundle is
inhabited iff the seam is decided. -/
theorem exists_presents_iff {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) :
    (∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S) ↔ SeamDecided M τ t φ :=
  ⟨fun ⟨_, _, h⟩ => seamDecided_of_presents h, fun h => exists_presents_of_seamDecided h sig k⟩

end Obstruction

/-! ## Part 2: a concrete undecided seam (the E2 fixture, transcribed) -/

section Fixture

/-- `a := false` steps to `a` and to `b`; `b := true` steps to `b` only. -/
def Rg : ℤ → Bool → Bool → Prop := fun _ u v => u = false ∨ v = true

theorem Rg_fwd : ∀ (t : ℤ) (w : Bool), ∃ u, Rg t w u := fun _ _ => ⟨true, Or.inr rfl⟩
theorem Rg_bwd : ∀ (t : ℤ) (w : Bool), ∃ v, Rg (t - 1) v w := fun _ _ => ⟨false, Or.inl rfl⟩

def Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd

instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd

def pa : Atom := ⟨"p", none⟩

def Mg : TaskModel Fg.toTaskFrame where
  valuation q _ := q.2 = true

abbrev Fp : PlusFormula := someFuture (.atom pa)

noncomputable def stayA (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), false)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, Or.inl rfl⟩
    show z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem stayA_state (c t z : ℤ) : (stayA c t).state z = (z + (c - t), false) := rfl

theorem stayA_state_t (c t : ℤ) : (stayA c t).state t = (c, false) := by
  rw [stayA_state]
  congr 1
  ring

noncomputable def jumpB (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), decide (t < z))) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, ?_⟩
    · show z + 1 + (c - t) = z + (c - t) + 1
      ring
    · show decide (t < z) = false ∨ decide (t < z + 1) = true
      by_cases h : t < z
      · right
        rw [decide_eq_true_eq]
        omega
      · left
        rw [decide_eq_false_iff_not]
        exact h)

theorem jumpB_state (c t z : ℤ) : (jumpB c t).state z = (z + (c - t), decide (t < z)) := rfl

theorem jumpB_state_t (c t : ℤ) : (jumpB c t).state t = (c, false) := by
  rw [jumpB_state, decide_eq_false (lt_irrefl t)]
  congr 1
  ring

theorem jumpB_state_succ (c t : ℤ) : ((jumpB c t).state (t + 1)).2 = true := by
  rw [jumpB_state]
  exact decide_eq_true (lt_add_one t)

theorem not_Fp_stayA (c t : ℤ) : ¬ PlusTruthAt Mg (stayA c t) t Fp := by
  rw [PlusTruth.someFuture_iff]
  rintro ⟨s, -, hs⟩
  have hs' : ((stayA c t).state s).2 = true := hs
  rw [stayA_state] at hs'
  exact Bool.noConfusion hs'

theorem Fp_jumpB (c t : ℤ) : PlusTruthAt Mg (jumpB c t) t Fp := by
  rw [PlusTruth.someFuture_iff]
  exact ⟨t + 1, lt_add_one t, jumpB_state_succ c t⟩

/-- The seam `(stayA c t, t)` is not decided on `Fp`: `stayA` refutes it, `jumpB` satisfies it,
and both pass through `(c, a)` at `t`. -/
theorem seam_undecided (c t : ℤ) : ¬ SeamDecided Mg (stayA c t) t Fp := by
  rintro (hall | hnone)
  · exact not_Fp_stayA c t ((PlusTruth.stab_iff Mg (stayA c t) t Fp).mp hall (stayA c t) rfl)
  · have h := (PlusTruth.stab_iff Mg (stayA c t) t Fp.neg).mp hnone (jumpB c t)
      (by rw [stayA_state_t, jumpB_state_t])
    exact (PlusTruth.neg_iff Mg (jumpB c t) t Fp).mp h (Fp_jumpB c t)

/-- **No `Presents` inhabitant exists at that seam, for any parameters.** -/
theorem no_presents_on_fixture (c t : ℤ) (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k) :
    ¬ Presents Mg (stayA c t) t Fp sig k T S :=
  fun h => seam_undecided c t (seamDecided_of_presents h)

end Fixture

/-! ## Part 3: the corrected shape — trace encoding, hit set, hypothesis-free bridge -/

section Trace

/-- A depth-`≤ k` sentence target is `k`-type-determined (Doets 1989, Lemma 1.1). -/
theorem determinedByKType_eval (sig : MonadicSignature) (k : ℕ) (ψ : MonadicFormula sig 0)
    (hψ : ψ.quantifierDepth ≤ k) :
    DeterminedByKType sig k (fun c => eval (zFiber sig c) Fin.elim0 ψ) := by
  intro c c' h
  refine doets_lemma_1_1 k 0 ψ hψ (zFiber sig c) (zFiber sig c') Fin.elim0 Fin.elim0 ?_
  intro nf
  unfold kTypeOf at h
  have h_pt := congr_fun h nf
  simp only [decide_eq_decide] at h_pt
  exact h_pt

/-- Two letters: `true` is the seam marker `now`, `false` is `φ`. -/
abbrev sig2 : MonadicSignature := ⟨Bool⟩

instance : Fintype sig2.preds := inferInstanceAs (Fintype Bool)
instance : DecidableEq sig2.preds := inferInstanceAs (DecidableEq Bool)

variable {F : FrameOver intOrder} [F.IsRegular]

/-- The trace of a history: the marker at `t`, and `φ`'s truth along the history. -/
def trace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : sig2.preds → ℤ → Prop :=
  fun (p : Bool) z => bif p then z = t else PlusTruthAt M σ z φ

/-- `∃x (now x ∧ φ x)`. -/
def nowPhi : MonadicFormula sig2 0 := .ex (.and (.atom true 0) (.atom false 0))

theorem nowPhi_depth : nowPhi.quantifierDepth = 1 := rfl

/-- The target: the block satisfies `nowPhi`. -/
def Tφ : (sig2.preds → ℤ → Prop) → Prop := fun c => eval (zFiber sig2 c) Fin.elim0 nowPhi

/-- Field `determined`, discharged at every depth `k ≥ 1`. -/
theorem Tφ_determined (k : ℕ) (hk : 1 ≤ k) : DeterminedByKType sig2 k Tφ :=
  determinedByKType_eval sig2 k nowPhi (by rw [nowPhi_depth]; exact hk)

omit [F.IsRegular] in
theorem Tφ_trace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : Tφ (trace M φ t σ) ↔ PlusTruthAt M σ t φ := by
  simp only [Tφ, nowPhi, eval, zFiber, trace, Fin.cons_zero, cond_true, cond_false]
  constructor
  · rintro ⟨z, rfl, h⟩
    exact h
  · intro h
    exact ⟨t, rfl, h⟩

/-- The spliced history of a ray pair. -/
abbrev world (τ : WorldHistory F.toTaskFrame) (t : ℤ) (bf : SeqPair F (τ.state t)) :
    WorldHistory F.toTaskFrame :=
  ((seamOmegaEquiv t (τ.state t)).symm bf).1

/-- The family triples realized through the seam. THIS is the residue. -/
def Hit (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) : Set (KType sig2 k × KType sig2 k × KType sig2 k) :=
  {tr | ∃ bf : SeqPair F (τ.state t), InFamily sig2 k tr.1 tr.2.1 tr.2.2 (trace M φ t (world τ t bf))}

theorem hit_finite (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) : (Hit M τ t φ k).Finite := by
  haveI := finite_family_triples sig2 k
  exact Set.toFinite _

/-- **The hypothesis-free bridge.** `⊡φ` is a conjunction over the (finitely many) realized
family triples. -/
theorem plusStab_iff_forall_hit (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ tr ∈ Hit M τ t φ k, ∀ c, InFamily sig2 k tr.1 tr.2.1 tr.2.2 c → Tφ c := by
  rw [plusStab_iff_omega]
  constructor
  · rintro hall ⟨τneg, τzero, τpos⟩ ⟨bf, hbf⟩ c hc
    rcases family_saturation sig2 k (Tφ_determined k hk) τneg τzero τpos with hin | hout
    · exact hin c hc
    · exact absurd ((Tφ_trace M φ t _).mpr (hall bf)) (hout _ hbf)
  · intro hhit bf
    obtain ⟨τneg, τzero, τpos, hfam⟩ := family_cover sig2 k (trace M φ t (world τ t bf))
    exact (Tφ_trace M φ t _).mp (hhit (τneg, τzero, τpos) ⟨bf, hfam⟩ _ hfam)

/-- The multi-family bundle: `Presents` with the summary's one triple replaced by a set of
triples. Same four fields. -/
structure PresentsMulti (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) (T : (sig.preds → ℤ → Prop) → Prop)
    (hit : Set (KType sig k × KType sig k × KType sig k)) (holds : Bool) : Prop where
  colours : ∀ bf : SeqPair F (τ.state t), ∃ c : sig.preds → ℤ → Prop, ∃ tr ∈ hit,
    InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
  determined : DeterminedByKType sig k T
  realized : ∀ tr ∈ hit, ∃ c : sig.preds → ℤ → Prop, InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧
    ∃ bf : SeqPair F (τ.state t),
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
  verdict : holds = true ↔ ∀ tr ∈ hit, ∃ c, InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧ T c

theorem plusStab_iff_presentsMulti {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : ℕ} {T : (sig.preds → ℤ → Prop) → Prop}
    {hit : Set (KType sig k × KType sig k × KType sig k)} {holds : Bool}
    (h : PresentsMulti M τ t φ sig k T hit holds) :
    PlusTruthAt M τ t (.stab φ) ↔ holds = true := by
  rw [plusStab_iff_omega, h.verdict]
  constructor
  · intro hall tr htr
    obtain ⟨c, hc, bf, hbf⟩ := h.realized tr htr
    exact ⟨c, hc, hbf.mp (hall bf)⟩
  · intro hhit bf
    obtain ⟨c, tr, htr, hc, hbf⟩ := h.colours bf
    obtain ⟨c₀, hc₀, hT₀⟩ := hhit tr htr
    rcases family_saturation sig k h.determined tr.1 tr.2.1 tr.2.2 with hin | hout
    · exact hbf.mpr (hin c hc)
    · exact absurd hT₀ (hout c₀ hc₀)

open Classical in
/-- **All four fields discharge definitionally** under the trace encoding, with `hit` the
realized set. The `Bool` is classical: the residue is computing `Hit`. -/
theorem presentsMulti_trace (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PresentsMulti M τ t φ sig2 k Tφ (Hit M τ t φ k)
      (decide (PlusTruthAt M τ t (.stab φ))) where
  colours bf := by
    obtain ⟨τneg, τzero, τpos, hfam⟩ := family_cover sig2 k (trace M φ t (world τ t bf))
    exact ⟨_, (τneg, τzero, τpos), ⟨bf, hfam⟩, hfam, (Tφ_trace M φ t _).symm⟩
  determined := Tφ_determined k hk
  realized tr htr := by
    obtain ⟨bf, hbf⟩ := htr
    exact ⟨_, hbf, bf, (Tφ_trace M φ t _).symm⟩
  verdict := by
    rw [decide_eq_true_iff, plusStab_iff_forall_hit M τ t φ k hk]
    constructor
    · intro hall tr htr
      obtain ⟨bf, hbf⟩ := htr
      exact ⟨_, hbf, hall tr ⟨bf, hbf⟩ _ hbf⟩
    · intro hex tr htr c hc
      obtain ⟨c₀, hc₀, hT₀⟩ := hex tr htr
      rcases family_saturation sig2 k (Tφ_determined k hk) tr.1 tr.2.1 tr.2.2 with hin | hout
      · exact hin c hc
      · exact absurd hT₀ (hout c₀ hc₀)

end Trace

end Probe737Presents

#print axioms Probe737Presents.exists_presents_iff
#print axioms Probe737Presents.no_presents_on_fixture
#print axioms Probe737Presents.plusStab_iff_forall_hit
#print axioms Probe737Presents.presentsMulti_trace
