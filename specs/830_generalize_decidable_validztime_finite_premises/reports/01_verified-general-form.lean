/-
Research probe (task 830): the general finite-premise form of the witness-family decision
procedure, compiled sorry-free against the current tree.

This file is NOT part of the build. It is a verified transcription target: every declaration
below elaborates with no diagnostics under
  lake env lean <this file>
Namespaced under `Probe830` so it cannot collide with the live declarations it mirrors.
-/
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly

namespace FormalSystem.Metalogic.Decidability.Probe830

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## Residue item 1: the consequence-form carrier normalization -/

/-- Consequence analogue of `ValidInt`: the carrier quantifier collapsed to `ℤ`. -/
def ConsequenceInt (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/--
Consequence analogue of `validZTime_iff_validInt`.

`truthAt_map` is stated at a fixed aligned triple `(σ, σ', t)` and quantified over the formula,
so a single aligned pair discharges every premise and the conclusion at once; no new transfer
machinery is needed.
-/
theorem consequenceZTime_iff_consequenceInt (Γ : Context) (φ : Formula) :
    SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ φ ↔ ConsequenceInt Γ φ := by
  constructor
  · intro h F _ M τ t hprem
    exact h F.toTaskFrame ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩ M τ t hprem
  · intro h F hF M τ t hprem
    sat_intro hF
    let e : ↑F.Duration ≃+o ↑intOrder := intIso
    have hal := aligned_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e τ
    refine (truthAt_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e M φ τ
      (WorldHistory.map τ e) hal t).mpr ?_
    refine h (FrameOver.map F.toFibre e) (TaskModel.map (F := F.toFibre) M e)
      (WorldHistory.map τ e) (e t) ?_
    intro ψ hψ
    exact (truthAt_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e M ψ τ
      (WorldHistory.map τ e) hal t).mp (hprem ψ hψ)

/-! ## Residue item 3: the enumeration, de-specialized from `φ` to `Γ ++ Del` -/

/--
The computable underlying list of `closureOf S`.

This is what replaces `Formula.subformulas φ` as the enumeration universe. `closureOf` is a
`foldr (· ∪ ·)` over `List.map subformulaClosure`, and `subformulaClosure χ` is
`(Formula.subformulas χ).toFinset`, so the flatMap below has exactly `closureOf S`'s members and
computes — no `Finset.toList` and so no noncomputability.
-/
def closureList (S : Context) : List Formula := S.flatMap Formula.subformulas

theorem mem_closureList {S : Context} {ψ : Formula} :
    ψ ∈ closureList S ↔ ψ ∈ closureOf S := by
  simp [closureList, mem_closureOf, subformulaClosure, List.mem_flatMap]

/-- Every subset of the target closure `closureOf (Γ ++ Del)`, computably. -/
def closureSubsetsOfC (Γ Del : Context) : List (Finset Formula) :=
  ((closureList (Γ ++ Del)).sublists).map List.toFinset

theorem closureSubsetsOfC_sub {Γ Del : Context} {X : Finset Formula}
    (h : X ∈ closureSubsetsOfC Γ Del) : X ⊆ closureOf (Γ ++ Del) := by
  obtain ⟨l, hl, rfl⟩ := List.mem_map.mp h
  intro a ha
  rw [← mem_closureList]
  exact (List.mem_sublists.mp hl).subset (List.mem_toFinset.mp ha)

theorem mem_closureSubsetsOfC {Γ Del : Context} {X : Finset Formula}
    (h : X ⊆ closureOf (Γ ++ Del)) : X ∈ closureSubsetsOfC Γ Del := by
  refine List.mem_map.mpr
    ⟨(closureList (Γ ++ Del)).filter (fun a => decide (a ∈ X)), ?_, ?_⟩
  · exact List.mem_sublists.mpr List.filter_sublist
  · ext a
    simp only [List.mem_toFinset, List.mem_filter, decide_eq_true_eq]
    exact ⟨fun hx => hx.2, fun hx => ⟨mem_closureList.mpr (h hx), hx⟩⟩

/-- A raw candidate lasso: three label lists, before any condition is imposed. -/
abbrev RawLL := List (Finset Formula) × List (Finset Formula) × List (Finset Formula)

def rawLabelledLassosC (Γ Del : Context) (n : ℕ) : List RawLL :=
  (ListEnumC.upTo (closureSubsetsOfC Γ Del) n).flatMap (fun b =>
    (ListEnumC.upTo (closureSubsetsOfC Γ Del) n).flatMap (fun m =>
      (ListEnumC.upTo (closureSubsetsOfC Γ Del) n).map (fun f => (b, m, f))))

theorem mem_rawLabelledLassosC {Γ Del : Context} {n : ℕ} {t : RawLL}
    (hb : t.1.length ≤ n) (hm : t.2.1.length ≤ n) (hf : t.2.2.length ≤ n)
    (hsub : ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ closureOf (Γ ++ Del)) :
    t ∈ rawLabelledLassosC Γ Del n := by
  obtain ⟨b, m, f⟩ := t
  have huniv : ∀ (l : List (Finset Formula)),
      (∀ X ∈ l, X ⊆ closureOf (Γ ++ Del)) → ∀ X ∈ l, X ∈ closureSubsetsOfC Γ Del := by
    intro l hl X hX
    exact mem_closureSubsetsOfC (hl X hX)
  simp only [rawLabelledLassosC, List.mem_flatMap, List.mem_map]
  exact ⟨b, ListEnumC.mem_upTo hb (huniv b (fun X hX => hsub X (by simp [hX]))),
    m, ListEnumC.mem_upTo hm (huniv m (fun X hX => hsub X (by simp [hX]))),
    f, ListEnumC.mem_upTo hf (huniv f (fun X hX => hsub X (by simp [hX]))), rfl⟩

theorem length_of_mem_rawLabelledLassosC {Γ Del : Context} {n : ℕ} {t : RawLL}
    (h : t ∈ rawLabelledLassosC Γ Del n) :
    t.1.length ≤ n ∧ t.2.1.length ≤ n ∧ t.2.2.length ≤ n := by
  obtain ⟨b, m, f⟩ := t
  simp only [rawLabelledLassosC, List.mem_flatMap, List.mem_map] at h
  obtain ⟨b', hb', m', hm', f', hf', heq⟩ := h
  cases heq
  exact ⟨ListEnumC.length_of_mem_upTo hb', ListEnumC.length_of_mem_upTo hm',
    ListEnumC.length_of_mem_upTo hf'⟩

def IsLabelledLassoC (Γ Del : Context) (t : RawLL) : Prop :=
  t.1 ≠ [] ∧ t.2.2 ≠ [] ∧ ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ closureOf (Γ ++ Del)

instance instDecIsLabelledLassoC (Γ Del : Context) :
    DecidablePred (IsLabelledLassoC Γ Del) := by
  intro t
  dsimp only [IsLabelledLassoC]
  infer_instance

/-- **Every labelled lasso with segments bounded by `n`**, at arbitrary `Γ Del`. -/
def boundedLassosC (Γ Del : Context) (n : ℕ) :
    List (LabelledLasso (closureOf (Γ ++ Del))) :=
  (rawLabelledLassosC Γ Del n).filterMap (fun t =>
    if h : IsLabelledLassoC Γ Del t then some ⟨t.1, t.2.1, t.2.2, h.1, h.2.1, h.2.2⟩ else none)

theorem mem_boundedLassosC {Γ Del : Context} {n : ℕ}
    (Λ : LabelledLasso (closureOf (Γ ++ Del)))
    (hb : Λ.back.length ≤ n) (hm : Λ.mid.length ≤ n) (hf : Λ.fwd.length ≤ n) :
    Λ ∈ boundedLassosC Γ Del n := by
  have hraw : (Λ.back, Λ.mid, Λ.fwd) ∈ rawLabelledLassosC Γ Del n :=
    mem_rawLabelledLassosC hb hm hf Λ.label_sub
  have hcond : IsLabelledLassoC Γ Del (Λ.back, Λ.mid, Λ.fwd) :=
    ⟨Λ.back_ne, Λ.fwd_ne, Λ.label_sub⟩
  simp only [boundedLassosC, List.mem_filterMap]
  exact ⟨(Λ.back, Λ.mid, Λ.fwd), hraw, by rw [dif_pos hcond]⟩

theorem boundedLassosC_sound {Γ Del : Context} {n : ℕ}
    {Λ : LabelledLasso (closureOf (Γ ++ Del))} (h : Λ ∈ boundedLassosC Γ Del n) :
    Λ.back.length ≤ n ∧ Λ.mid.length ≤ n ∧ Λ.fwd.length ≤ n := by
  simp only [boundedLassosC, List.mem_filterMap] at h
  obtain ⟨t, ht, heq⟩ := h
  by_cases hc : IsLabelledLassoC Γ Del t
  · rw [dif_pos hc] at heq
    obtain ⟨hb, hm, hf⟩ := length_of_mem_rawLabelledLassosC ht
    cases heq
    exact ⟨hb, hm, hf⟩
  · rw [dif_neg hc] at heq
    exact absurd heq (by simp)

/-- **The computable candidate list**, at arbitrary `Γ Del`. -/
def candsC (Γ Del : Context) : List (WitnessFamily Γ Del) :=
  (closureSubsetsOfC Γ Del).flatMap (fun S =>
    (ListEnumC.upTo (boundedLassosC Γ Del (compressionBound Γ Del))
        ((closureOf (Γ ++ Del)).card + 1)).filterMap (fun L =>
      if h : L ≠ [] then some ⟨fun χ => decide (χ ∈ S), L, h⟩ else none))

theorem mem_candsC_of_bounded (Γ Del : Context) (W : WitnessFamily Γ Del)
    (hlen : ∀ Λ ∈ W.lassos,
      Λ.back.length ≤ compressionBound Γ Del ∧
      Λ.mid.length ≤ compressionBound Γ Del ∧
      Λ.fwd.length ≤ compressionBound Γ Del)
    (hcount : W.lassos.length ≤ (closureOf (Γ ++ Del)).card + 1)
    (hbx : ∃ S : Finset Formula, S ⊆ closureOf (Γ ++ Del) ∧ W.bx = fun χ => decide (χ ∈ S)) :
    W ∈ candsC Γ Del := by
  obtain ⟨S, hSsub, hSeq⟩ := hbx
  obtain ⟨bxW, lasW, hne⟩ := W
  simp only at hlen hcount hSeq
  subst hSeq
  have hmemL : lasW ∈ ListEnumC.upTo (boundedLassosC Γ Del (compressionBound Γ Del))
      ((closureOf (Γ ++ Del)).card + 1) := by
    refine ListEnumC.mem_upTo hcount (fun Λ hΛ => ?_)
    obtain ⟨hb, hm, hf⟩ := hlen Λ hΛ
    exact mem_boundedLassosC Λ hb hm hf
  simp only [candsC, List.mem_flatMap, List.mem_filterMap]
  exact ⟨S, mem_closureSubsetsOfC hSsub, lasW, hmemL, by rw [dif_pos hne]⟩

/-! ## The compression theorem at arbitrary premises (residue item 2 is the `Target` premise
clause, discharged in `htgt` below) -/

theorem exists_witnessFamily_of_not_consequence (Γ : Context) (σ : Formula)
    (h : ¬ SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) :
    ∃ (W : WitnessFamily Γ [σ]) (t : ℤ),
      (∀ Λ ∈ W.lassos,
        Λ.back.length ≤ compressionBound Γ [σ] ∧
        Λ.mid.length ≤ compressionBound Γ [σ] ∧
        Λ.fwd.length ≤ compressionBound Γ [σ]) ∧
      W.lassos.length ≤ (closureOf (Γ ++ [σ])).card + 1 ∧
      (∃ S : Finset Formula, S ⊆ closureOf (Γ ++ [σ]) ∧ W.bx = fun χ => decide (χ ∈ S)) ∧
      0 ≤ t ∧ t ≤ (compressionBound Γ [σ] : ℤ) ∧
      W.Certifies t := by
  classical
  -- ### Step 0: normalise the carrier to ℤ (residue item 1)
  rw [consequenceZTime_iff_consequenceInt] at h
  simp only [ConsequenceInt, not_forall] at h
  obtain ⟨F, hreg, M, τ, t₀, hprem, hfail⟩ := h
  set C : Finset Formula := closureOf (Γ ++ [σ]) with hC
  set B : ℕ := compressionBound Γ [σ] with hB
  -- ### The two box guesses
  set bxTrue : Formula → Bool := fun χ =>
    @decide (∀ (s : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M s v χ) (Classical.dec _)
    with hbxTrueDef
  have hbxTrue : ∀ χ : Formula, bxTrue χ = true ↔
      ∀ (s : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M s v χ := by
    intro χ
    rw [hbxTrueDef]
    exact decide_eq_true_iff
  set S : Finset Formula :=
    @Finset.filter Formula (fun χ => ∀ (s : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M s v χ)
      (Classical.decPred _) (boxedPart C) with hSdef
  have hmemS : ∀ χ : Formula, χ ∈ S ↔
      (χ ∈ boxedPart C ∧ ∀ (s : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M s v χ) := by
    intro χ
    rw [hSdef]
    simp only [Finset.mem_filter]
  set bxC : Formula → Bool := fun χ => decide (χ ∈ S) with hbxCdef
  have hagree : ∀ χ : Formula, Formula.box χ ∈ C → bxTrue χ = bxC χ := by
    intro χ hχ
    rw [Bool.eq_iff_iff, hbxTrue χ]
    rw [hbxCdef]
    simp only [decide_eq_true_iff, hmemS χ]
    constructor
    · intro hg; exact ⟨mem_boxedPart.mpr hχ, hg⟩
    · intro hg; exact hg.2
  -- ### One lasso per formula: the main one, or a witness where the guess is false
  obtain ⟨Λ₀, i₀, hb₀, hm₀, hf₀, hi₀a, hi₀b, hlab₀, hloc₀, hful₀, hreal₀⟩ :=
    exists_labelledLasso_of_history_realized M Γ [σ] bxTrue hbxTrue τ t₀
  have hchoice : ∀ χ : Formula, ∃ Λ : LabelledLasso C,
      Λ.back.length ≤ B ∧ Λ.mid.length ≤ B ∧ Λ.fwd.length ≤ B ∧
      LocalCoherentSeqLab Γ [σ] bxTrue Λ.lab ∧ FulfillingSeqLab Λ.lab ∧
      (∀ j : ℤ, ∃ (s : WorldHistory F.toTaskFrame) (u : ℤ),
        Λ.lab j = typeAtM M Γ [σ] s u) ∧
      ((¬ ∀ (s : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M s v χ) →
        ∃ j : ℤ, χ ∉ Λ.lab j) := by
    intro χ
    by_cases hg : ∀ (s : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M s v χ
    · exact ⟨Λ₀, hb₀, hm₀, hf₀, hloc₀, hful₀,
        fun j => by obtain ⟨u, hu⟩ := hreal₀ j; exact ⟨τ, u, hu⟩,
        fun hcon => absurd hg hcon⟩
    · simp only [not_forall] at hg
      obtain ⟨σ₀, v₀, hv₀⟩ := hg
      obtain ⟨Λ, i, hb, hm, hf, -, -, hlab, hloc, hful, hreal⟩ :=
        exists_labelledLasso_of_history_realized M Γ [σ] bxTrue hbxTrue σ₀ v₀
      refine ⟨Λ, hb, hm, hf, hloc, hful,
        fun j => by obtain ⟨u, hu⟩ := hreal j; exact ⟨σ₀, u, hu⟩, fun _ => ⟨i, ?_⟩⟩
      rw [hlab]
      intro hmem
      exact hv₀ (mem_typeAtM.mp hmem).2
  choose wit hwitb hwitm hwitf hwitloc hwitful hwitreal hwitfail using hchoice
  -- ### The family
  obtain ⟨R, hR⟩ : ∃ R : Finset Formula, R = boxedPart C \ S := ⟨_, rfl⟩
  obtain ⟨L, hL⟩ : ∃ L : List (LabelledLasso C), L = Λ₀ :: R.toList.map wit := ⟨_, rfl⟩
  have hLne : L ≠ [] := by rw [hL]; simp
  have hLmem : ∀ Λ ∈ L, (Λ = Λ₀) ∨ ∃ χ ∈ R, Λ = wit χ := by
    intro Λ hΛ
    rw [hL] at hΛ
    rcases List.mem_cons.mp hΛ with rfl | hΛ'
    · exact Or.inl rfl
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hΛ'
      exact Or.inr ⟨χ, Finset.mem_toList.mp hχ, rfl⟩
  have hLbound : ∀ Λ ∈ L,
      Λ.back.length ≤ B ∧ Λ.mid.length ≤ B ∧ Λ.fwd.length ≤ B := by
    intro Λ hΛ
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact ⟨hb₀, hm₀, hf₀⟩
    · exact ⟨hwitb χ, hwitm χ, hwitf χ⟩
  have hLloc : ∀ Λ ∈ L, LocalCoherentSeqLab Γ [σ] bxC Λ.lab := by
    intro Λ hΛ
    refine localCoherentSeqLab_congr_bx (fun χ hχ => hagree χ hχ) ?_
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact hloc₀
    · exact hwitloc χ
  have hLful : ∀ Λ ∈ L, FulfillingSeqLab Λ.lab := by
    intro Λ hΛ
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact hful₀
    · exact hwitful χ
  have hLreal : ∀ Λ ∈ L, ∀ j : ℤ, ∃ (s : WorldHistory F.toTaskFrame) (u : ℤ),
      Λ.lab j = typeAtM M Γ [σ] s u := by
    intro Λ hΛ
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact fun j => by obtain ⟨u, hu⟩ := hreal₀ j; exact ⟨τ, u, hu⟩
    · exact hwitreal χ
  obtain ⟨W, hW⟩ : ∃ W : WitnessFamily Γ [σ],
      W = { bx := bxC, lassos := Λ₀ :: R.toList.map wit, lassos_ne := by simp } := ⟨_, rfl⟩
  have hWbx : W.bx = bxC := by rw [hW]
  have hWlas : W.lassos = L := by rw [hW, hL]
  have hWL : ∀ i : Fin W.lassos.length, W.L i = (W.lassos.get i).lab := fun _ => rfl
  have hWmemL : ∀ i : Fin W.lassos.length, W.lassos.get i ∈ L := by
    intro i
    rw [← hWlas]
    exact List.get_mem _ _
  -- ### The four certificate conditions
  have hcoh : W.LocalCoherentLab := by
    intro i t
    have h := hLloc _ (hWmemL i) t
    rw [hWbx]
    exact h
  have hfulW : W.FulfillingLab := by
    constructor
    · intro i t g e hmem
      exact (hLful _ (hWmemL i)).1 t g e hmem
    · intro i t g e hmem
      exact (hLful _ (hWmemL i)).2 t g e hmem
  have hboxW : W.BoxFaithful := by
    intro χ hχ
    rw [hWbx, hbxCdef]
    simp only [decide_eq_true_iff, hmemS χ]
    constructor
    · rintro ⟨-, hglob⟩ i t
      obtain ⟨s, u, hu⟩ := hLreal _ (hWmemL i) t
      rw [hWL i, hu]
      exact mem_typeAtM.mpr ⟨closureOf_box hχ, hglob s u⟩
    · intro hall
      refine ⟨mem_boxedPart.mpr hχ, ?_⟩
      by_contra hglob
      obtain ⟨j, hj⟩ := hwitfail χ hglob
      have hmemR : χ ∈ R := by
        rw [hR, Finset.mem_sdiff]
        exact ⟨mem_boxedPart.mpr hχ, fun hS => hj (by
          obtain ⟨-, hg⟩ := (hmemS χ).mp hS
          exact absurd hg hglob)⟩
      have hmemL : wit χ ∈ L := by
        rw [hL]
        exact List.mem_cons_of_mem _ (List.mem_map.mpr ⟨χ, Finset.mem_toList.mpr hmemR, rfl⟩)
      obtain ⟨k, hk⟩ : ∃ k : Fin W.lassos.length, W.lassos.get k = wit χ := by
        rw [hWlas]
        obtain ⟨k, hk⟩ := List.mem_iff_get.mp hmemL
        exact ⟨k, hk⟩
      exact hj (by rw [← hk, ← hWL k]; exact hall k j)
  have hmain : W.main = Λ₀.lab := by
    rw [hW]
    rfl
  -- residue item 2: the premise clause is the mirror of the conclusion clause beside it
  have htgt : W.Target i₀ := by
    refine ⟨fun γ hγ => ?_, fun ψ hψ hmem => ?_⟩
    · rw [hmain, hlab₀]
      exact mem_typeAtM.mpr ⟨WitnessFamily.premise_mem_closure hγ, hprem γ hγ⟩
    · rcases List.mem_singleton.mp hψ with rfl
      rw [hmain, hlab₀] at hmem
      exact hfail (mem_typeAtM.mp hmem).2
  -- ### Assemble
  refine ⟨W, i₀, ?_, ?_, ⟨S, ?_, ?_⟩, hi₀a, ?_, hcoh, hfulW, hboxW, htgt⟩
  · intro Λ hΛ
    rw [hWlas] at hΛ
    exact hLbound Λ hΛ
  · rw [hWlas, hL]
    have hcard : R.card ≤ (closureOf (Γ ++ [σ])).card := by
      rw [hR, hC]
      exact le_trans (Finset.card_le_card Finset.sdiff_subset)
        (Finset.card_le_card (boxedPart_subset_closureOf _))
    simp only [List.length_cons, List.length_map, Finset.length_toList]
    omega
  · rw [hSdef]
    exact le_trans (Finset.filter_subset _ _) (boxedPart_subset_closureOf _)
  · rw [hWbx, hbxCdef]
  · have hnm : Λ₀.nm = (Λ₀.mid.length : ℤ) := rfl
    have : (Λ₀.mid.length : ℤ) ≤ (B : ℤ) := by exact_mod_cast hm₀
    omega

/-! ## The general assembly -/

/-- **The decision criterion** at arbitrary finite premises. -/
theorem consequence_iff_noCertifiedCandidate (Γ : Context) (σ : Formula) :
    SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ ↔
      ∀ W ∈ candsC Γ [σ], ∀ t ∈ Finset.Icc (0 : ℤ) (compressionBound Γ [σ] : ℤ),
        ¬ W.Certifies t := by
  constructor
  · intro hv W _ t _ hcert
    obtain ⟨F, hF, M, τ, u, hprem, hno⟩ := WitnessFamily.refutes_of_certifies W hcert
    exact hno σ (by simp) (hv F hF M τ u hprem)
  · intro hall
    by_contra hnv
    obtain ⟨W, t, hlen, hcount, hbx, ht0, ht1, hcert⟩ :=
      exists_witnessFamily_of_not_consequence Γ σ hnv
    exact hall W (mem_candsC_of_bounded Γ [σ] W hlen hcount hbx) t
      (Finset.mem_Icc.mpr ⟨ht0, ht1⟩) hcert

/-- **The decision procedure** for `Γ ⊨_ZTime σ` at arbitrary finite `Γ`. -/
def decidableSemanticConsequenceZTime (Γ : Context) (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) :=
  decidable_of_iff _ (consequence_iff_noCertifiedCandidate Γ σ).symm

#print axioms consequenceZTime_iff_consequenceInt
#print axioms exists_witnessFamily_of_not_consequence
#print axioms consequence_iff_noCertifiedCandidate
#print axioms decidableSemanticConsequenceZTime

end FormalSystem.Metalogic.Decidability.Probe830
