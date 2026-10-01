import FormalSystem

/-!
Probe (research round 6, dispatch 50): the backward tail-stability conjunct.

Part A settles the **soft link** dispatch 49 left stated-but-unproved: that `e S g` with atomic
guard and event is a genuine ℤ-time non-validity, and that the closure type of every world of the
all-false countermodel is empty — i.e. that `snceProbeFamily`'s labelling is the labelling a
countermodel of that target actually produces.

Part B settles whether the undischargeable `snce` positions are FORCED or AVOIDABLE, at the
smallest possible target: `⊥ S ⊥`. Its closure is `{⊥ S ⊥, ⊥}`, which contains **no state shape**
at all, so `AgreesOnState` is vacuous and `posAt` is the *same two-label set for every family*.
The dead position is therefore not a property of the family's labels and cannot be excluded by any
strengthening of the compression theorem's output.

Part C is the exact mirror at `⊥ U ⊥`, which refutes the RAW forward conjunct for every family —
showing the existing forward liveness filter is not removable either.
-/

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.WitnessFamily

namespace Probe703D50

/-! ## Part A: the soft link -/

noncomputable instance : SuccOrder (intOrder : TemporalOrder).carrier := inferInstanceAs (SuccOrder ℤ)
instance : NoMaxOrder (intOrder : TemporalOrder).carrier := inferInstanceAs (NoMaxOrder ℤ)

/-- The all-false assignment on ℤ. -/
def allFalse : (intOrder : TemporalOrder).carrier → Bool := fun _ => false

noncomputable abbrev PFrame : FrameOver intOrder :=
  permissiveFrame intOrder inferInstance inferInstance

noncomputable abbrev PModel : TaskModel PFrame.toTaskFrame :=
  permissiveModel intOrder inferInstance inferInstance

noncomputable abbrev PHist : WorldHistory PFrame.toTaskFrame :=
  permissiveHist intOrder inferInstance inferInstance allFalse

def gAtom : Atom := Atom.mkBase "g"
def eAtom : Atom := Atom.mkBase "e"

/-- The dispatch-49 probe target, `e S g` with atomic guard and event. -/
def snceTarget : Formula := Formula.snce (Formula.atom gAtom) (Formula.atom eAtom)

/-- Every atom is false at every time along the all-false permissive history. -/
theorem atom_false (p : Atom) (t : (intOrder : TemporalOrder).carrier) :
    ¬ TruthAt PModel PHist t (Formula.atom p) := by
  intro h
  have := (permissive_realizes intOrder inferInstance inferInstance allFalse p t).mp h
  simp [allFalse] at this

/-- **The target is false at every time** along that history: the event never holds. -/
theorem snceTarget_false (t : (intOrder : TemporalOrder).carrier) :
    ¬ TruthAt PModel PHist t snceTarget := by
  intro h
  rw [snceTarget, Truth.snce_iff] at h
  obtain ⟨s, _, he, _⟩ := h
  exact atom_false eAtom s he

/-- **(a), first half: the target is a genuine ℤ-time non-validity.** -/
theorem not_validZTime_snceTarget : ¬ ValidZTime snceTarget := by
  intro h
  exact snceTarget_false 0
    (h PFrame.toTaskFrame ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩ PModel PHist 0)

/-- **(a), second half: the closure type of every world of that countermodel is empty.** -/
theorem typeAtM_empty (u : ℤ) :
    typeAtM PModel ([] : Context) [snceTarget] PHist u = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro ψ hψ
  obtain ⟨hmem, htrue⟩ := mem_typeAtM.mp hψ
  have hcases : ψ = snceTarget ∨ ψ = Formula.atom gAtom ∨ ψ = Formula.atom eAtom := by
    revert hmem
    simp [closureOf, snceTarget, Syntax.subformulaClosure, Syntax.Formula.subformulas]
    tauto
  rcases hcases with rfl | rfl | rfl
  · exact snceTarget_false u htrue
  · exact atom_false gAtom u htrue
  · exact atom_false eAtom u htrue

end Probe703D50

namespace Probe703D50

/-! ## Part B: the obstruction at the smallest `snce` target, `⊥ S ⊥`

Closure: `{⊥ S ⊥, ⊥}`. No implication, so `LabCoherent X ↔ ⊥ ∉ X`. No state shape, so
`AgreesOnState` is vacuous. Hence `posAt t` is `Fin n × {∅, {⊥ S ⊥}}` for **every** certificate
over this target, at every time — a set the family's labels cannot influence.
-/

/-- The smallest target whose closure carries a `snce` obligation and nothing else. -/
def botSnce : Formula := Formula.snce Formula.bot Formula.bot

/-- `⊥ S ⊥` is false at every time in every model: `⊥` is never true. -/
theorem botSnce_false {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    ¬ TruthAt M τ t botSnce := by
  intro h
  rw [botSnce, Truth.snce_iff] at h
  obtain ⟨s, _, he, _⟩ := h
  exact Truth.bot_false he

/-- **`⊥ S ⊥` is a genuine ℤ-time non-validity**, so the compression theorem applies to it. -/
theorem not_validZTime_botSnce : ¬ ValidZTime botSnce := fun h =>
  botSnce_false PModel PHist 0
    (h PFrame.toTaskFrame ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩ PModel PHist 0)

/-- The one-slot empty lasso over `⊥ S ⊥`. -/
def botLasso : LabelledLasso (closureOf (([] : Context) ++ [botSnce])) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact List.mem_singleton.mp h
        · simp at h
      · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

/-- A longer empty lasso: `perB = 2`, `perM = 3`, `perF = 2`. -/
def botLassoLong : LabelledLasso (closureOf (([] : Context) ++ [botSnce])) where
  back := [∅, ∅]
  mid := [∅, ∅, ∅]
  fwd := [∅, ∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · rcases List.mem_cons.mp h with rfl | h
          · rfl
          · exact List.mem_singleton.mp h
        · rcases List.mem_cons.mp h with rfl | h
          · rfl
          · rcases List.mem_cons.mp h with rfl | h
            · rfl
            · exact List.mem_singleton.mp h
      · rcases List.mem_cons.mp h with rfl | h
        · rfl
        · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

def botFamily : WitnessFamily ([] : Context) [botSnce] where
  bx := fun _ => false
  lassos := [botLasso]
  lassos_ne := by simp

def botFamilyLong : WitnessFamily ([] : Context) [botSnce] where
  bx := fun _ => false
  lassos := [botLassoLong]
  lassos_ne := by simp

/-- Two lassos, so the slice width is `2` rather than `1`. -/
def botFamilyWide : WitnessFamily ([] : Context) [botSnce] where
  bx := fun _ => false
  lassos := [botLasso, botLassoLong]
  lassos_ne := by simp

theorem botFamily_certifies : botFamily.Certifies 0 := by decide
theorem botFamilyLong_certifies : botFamilyLong.Certifies 0 := by decide
theorem botFamilyWide_certifies : botFamilyWide.Certifies 0 := by decide

set_option maxRecDepth 40000

/-- **THE REFUTATION, at the smallest possible target.** -/
theorem botFamily_not_tailStableBack :
    ¬ (botFamily.sliced 0).TailStableBack := by decide

theorem botFamilyLong_not_tailStableBack :
    ¬ (botFamilyLong.sliced 0).TailStableBack := by decide

theorem botFamilyWide_not_tailStableBack :
    ¬ (botFamilyWide.sliced 0).TailStableBack := by decide

/-- The forward conjunct holds at all three: the failure is one-sided. -/
theorem botFamily_tailStableFwd : (botFamily.sliced 0).TailStableFwd := by decide
theorem botFamilyLong_tailStableFwd : (botFamilyLong.sliced 0).TailStableFwd := by decide
theorem botFamilyWide_tailStableFwd : (botFamilyWide.sliced 0).TailStableFwd := by decide

/-- **The mirror filter repairs it** at all three. -/
theorem botFamily_tailStableMirror : (botFamily.sliced 0).TailStableMirror := by decide
theorem botFamilyLong_tailStableMirror : (botFamilyLong.sliced 0).TailStableMirror := by decide
theorem botFamilyWide_tailStableMirror : (botFamilyWide.sliced 0).TailStableMirror := by decide

end Probe703D50

namespace Probe703D50

/-! ## Part C: the exact mirror at `⊥ U ⊥` — the forward filter is NOT removable

If the undischargeable positions came from the compression construction, then the forward filter
would be removable once that construction were strengthened. The target `⊥ U ⊥` settles that: its
closure is `{⊥ U ⊥, ⊥}`, again with no state shape and no implication, so `posAt` is again the same
two-label set for every family — and the RAW forward demand `Φ_fwd R₀ = R₀` fails at it while the
FILTERED one holds.
-/

/-- The smallest target whose closure carries an `untl` obligation and nothing else. -/
def botUntl : Formula := Formula.untl Formula.bot Formula.bot

theorem botUntl_false {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    ¬ TruthAt M τ t botUntl := by
  intro h
  rw [botUntl, Truth.untl_iff] at h
  obtain ⟨s, _, he, _⟩ := h
  exact Truth.bot_false he

theorem not_validZTime_botUntl : ¬ ValidZTime botUntl := fun h =>
  botUntl_false PModel PHist 0
    (h PFrame.toTaskFrame ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩ PModel PHist 0)

def botULasso : LabelledLasso (closureOf (([] : Context) ++ [botUntl])) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact List.mem_singleton.mp h
        · simp at h
      · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

def botUFamily : WitnessFamily ([] : Context) [botUntl] where
  bx := fun _ => false
  lassos := [botULasso]
  lassos_ne := by simp

theorem botUFamily_certifies : botUFamily.Certifies 0 := by decide

/-- **The RAW forward demand fails** at the `untl` mirror target. -/
theorem botUFamily_not_tailStableRaw : ¬ (botUFamily.sliced 0).TailStableRaw := by decide

/-- …and it fails in its **forward** conjunct specifically, at `r = 0`: the `r = 0` instance of the
raw forward conjunct is `Φ_fwd R₀ = R₀`, and it is false here. -/
theorem botUFamily_Φ_fwd_R₀_ne :
    (botUFamily.sliced 0).Φ_fwd (botUFamily.sliced 0).R₀ ≠ (botUFamily.sliced 0).R₀ := by decide

/-- **The landed filtered forward conjunct holds** at the same certificate: the filter is exactly
what repairs this, and removing it would reintroduce the failure. -/
theorem botUFamily_tailStableFwd : (botUFamily.sliced 0).TailStableFwd := by decide

/-- **The backward conjunct holds** at the `untl` mirror: the asymmetry is in the target's
obligation direction, not in the certificate. -/
theorem botUFamily_tailStableBack : (botUFamily.sliced 0).TailStableBack := by decide

/-! ## Part D: why no strengthening of the family can move these verdicts

The two witnesses above are not "some families among many". For each of these two targets the
closure is `{χ, ⊥}` with `χ` the single temporal obligation, and:

* `LabCoherent X ↔ ⊥ ∉ X`, since the closure holds no implication — family-independent;
* `AgreesOnState` is vacuous, since the closure holds no atom, no `□` and no `⊡` — so the slice
  labelling, which is the ONLY channel by which a family reaches `posAt`, constrains nothing;
* hence `posAt t = Fin n ×ˢ {∅, {χ}}` at every `t`, for every certificate over the target.

The lemmas below prove the two family-independent halves of that, for an arbitrary certificate over
an arbitrary target, so that the claim does not rest on the three evaluated families.
-/

open FormalSystem.PlusLanguage in
/-- **The junk label is coherent at every slice of every certificate whose closure has no state
shape.** `LabCoherent` is a condition on the label alone and `AgreesOnState` is vacuous, so the
family's labels cannot exclude it. -/
theorem mem_posAt_of_no_state_shape {Γ' Del' : PlusContext}
    (G : PlusSlicedCertificate Γ' Del') (t : ℤ) (i : Fin G.n) (X : PlusSlicedCertificate.Lab Γ' Del')
    (hbot : PlusFormula.bot ∉ X.1)
    (himp : ∀ ψ ∈ plusClosureOf (Γ' ++ Del'), PlusSlicedCertificate.impClauseAt X.1 ψ = true)
    (hst : ∀ ψ ∈ plusClosureOf (Γ' ++ Del'),
      PlusSlicedCertificate.IsStateShape ψ = false) :
    (i, X) ∈ G.posAt t := by
  rw [G.mem_posAt]
  refine ⟨⟨hbot, himp⟩, ?_⟩
  intro ψ hψ hshape
  rw [hst ψ hψ] at hshape
  exact absurd hshape (by simp)

open FormalSystem.PlusLanguage in
/-- **A label carrying an unguardable `snce` obligation has NO predecessor at any slice of any
certificate.** The `snce` clause demands the obligation be discharged by the predecessor's own
label, and with guard and event both `⊥` no coherent label can do it. Nothing about the family,
the slice labelling, or the edge relation enters the proof. -/
theorem predP_eq_empty_of_bot_snce {Γ' Del' : PlusContext}
    (G : PlusSlicedCertificate Γ' Del') (t : ℤ) (q : G.Pos)
    (hmem : PlusFormula.snce PlusFormula.bot PlusFormula.bot ∈ plusClosureOf (Γ' ++ Del'))
    (hq : PlusFormula.snce PlusFormula.bot PlusFormula.bot ∈ q.2.1) :
    G.predP t q = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro p hp
  rw [G.mem_predP] at hp
  obtain ⟨hppos, -, -, hsnce⟩ := hp
  have hclause := hsnce _ hmem
  have hbot : PlusFormula.bot ∉ p.2.1 := ((G.mem_posAt (t - 1) p).mp hppos).1.1
  simp only [PlusSlicedCertificate.snceClauseAt, decide_eq_true_eq] at hclause
  rcases hclause.mp hq with h | ⟨h, -⟩ <;> exact hbot h

end Probe703D50

namespace Probe703D50

/-! ## Part E: at `⊥ S ⊥` EVERY certifying family is the all-empty family

This is what upgrades Part B from "three families" to "every family". A label is a closure subset;
the closure is `{⊥ S ⊥, ⊥}`; `LocalCoherentLab` forbids `⊥`, and its `snce` clause forbids
`⊥ S ⊥` because the clause's right-hand side demands `⊥` of the previous label. So the family's
labels are determined — all empty — and a family over this target is free only in its lasso count
and its three segment lengths, which is exactly what the three evaluated instances vary.
-/

/-- Every member of `closureOf ([] ++ [⊥ S ⊥])` is `⊥ S ⊥` or `⊥`. -/
theorem botSnce_closure_cases {ψ : Formula}
    (h : ψ ∈ closureOf (([] : Context) ++ [botSnce])) :
    ψ = botSnce ∨ ψ = Formula.bot := by
  revert h
  simp [closureOf, botSnce, Syntax.subformulaClosure, Syntax.Formula.subformulas]

/-- `⊥ S ⊥` is in the closure of its own singleton context. -/
theorem botSnce_mem_closure : botSnce ∈ closureOf (([] : Context) ++ [botSnce]) :=
  self_mem_closureOf (by simp)

/--
**Every locally coherent family over `⊥ S ⊥` has every label empty.**

No hypothesis on the family beyond `LocalCoherentLab`, which `Certifies` supplies. So the
obstruction Part B evaluates is not a property of a chosen family: it is a property of the target.
-/
theorem all_labels_empty (W : WitnessFamily ([] : Context) [botSnce])
    (hlc : W.LocalCoherentLab) (i : Fin W.lassos.length) (t : ℤ) : W.L i t = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro ψ hψ
  have hsub := W.subset_closureOf i t hψ
  rcases botSnce_closure_cases hsub with rfl | rfl
  · -- the `snce` clause's right-hand side demands `⊥` of the previous label
    have hclause := (hlc i t).2.2.2.2 Formula.bot Formula.bot botSnce_mem_closure
    rcases hclause.mp hψ with h | ⟨h, -⟩ <;> exact (hlc i (t - 1)).1 h
  · exact (hlc i t).1 hψ

/-- The same for the `untl` mirror target. -/
theorem botUntl_closure_cases {ψ : Formula}
    (h : ψ ∈ closureOf (([] : Context) ++ [botUntl])) :
    ψ = botUntl ∨ ψ = Formula.bot := by
  revert h
  simp [closureOf, botUntl, Syntax.subformulaClosure, Syntax.Formula.subformulas]

theorem botUntl_mem_closure : botUntl ∈ closureOf (([] : Context) ++ [botUntl]) :=
  self_mem_closureOf (by simp)

theorem all_labels_empty_untl (W : WitnessFamily ([] : Context) [botUntl])
    (hlc : W.LocalCoherentLab) (i : Fin W.lassos.length) (t : ℤ) : W.L i t = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro ψ hψ
  have hsub := W.subset_closureOf i t hψ
  rcases botUntl_closure_cases hsub with rfl | rfl
  · have hclause := (hlc i t).2.2.2.1 Formula.bot Formula.bot botUntl_mem_closure
    rcases hclause.mp hψ with h | ⟨h, -⟩ <;> exact (hlc i (t + 1)).1 h
  · exact (hlc i t).1 hψ

end Probe703D50
