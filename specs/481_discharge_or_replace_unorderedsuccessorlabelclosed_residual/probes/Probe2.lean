import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

private def gp : Formula := .atom (Atom.mkBase "p")

def gWitness (l : Label) : SignedFormula := SignedFormula.neg (Formula.box gp) l
def gBranch (l : Label) : Branch := [gWitness l]
def gEmitted (l : Label) : List SignedFormula :=
  [SignedFormula.neg gp ⟨l.world + 1, l.time⟩]

private theorem g_ia_ug (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .priorUGap (gWitness l) fc = false := rfl
private theorem g_ia_sg (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .priorSGap (gWitness l) fc = false := rfl
private theorem g_ia_sep (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .sepRule (gWitness l) fc = false := rfl
private theorem g_ia_np (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .negPos (gWitness l) fc = false := rfl
private theorem g_ia_nn (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .negNeg (gWitness l) fc = false := rfl
private theorem g_ia_in (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .impNeg (gWitness l) fc = false := rfl
private theorem g_ia_ap (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .andPos (gWitness l) fc = false := rfl
private theorem g_ia_on (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .orNeg (gWitness l) fc = false := rfl
private theorem g_ia_bp (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .boxPos (gWitness l) fc = false := rfl
private theorem g_ia_bn (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .boxNeg (gWitness l) fc = true := rfl
private theorem g_ar_bn (l : Label) :
    applyRule .boxNeg (gWitness l) (gBranch l) TimeOrdering.empty
      = (RuleResult.linear (gEmitted l), TimeOrdering.empty) := rfl
private theorem g_rm_bn : ruleMintsFreshLabel .boxNeg = true := rfl
private theorem g_wp_bn (l : Label) :
    witnessPresent .boxNeg (gWitness l) (gBranch l) TimeOrdering.empty = false := rfl
private theorem g_tw_bn (l : Label) :
    trivialEventWitnessed .boxNeg (gWitness l) (gBranch l) TimeOrdering.empty = false := rfl

attribute [local simp] g_ia_ug g_ia_sg g_ia_sep g_ia_np g_ia_nn g_ia_in g_ia_ap g_ia_on
  g_ia_bp g_ia_bn g_ar_bn g_rm_bn g_wp_bn g_tw_bn

theorem findApplicableRule_gWitness (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    findApplicableRule (gWitness l) (gBranch l) TimeOrdering.empty fc
      = some (TableauRule.boxNeg, RuleResult.linear (gEmitted l), TimeOrdering.empty) := by
  simp only [findApplicableRule, allRulesForFC, allRules, dedekindRules]
  by_cases hd : FormalSystem.ProofSystem.FrameClass.Dedekind ≤ fc
  · simp [hd, List.findSome?]
  · simp [hd, List.findSome?]

theorem expandOnceUnblocked_gBranch
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) (l : Label) :
    (expandOnceUnblocked (gBranch l) TimeOrdering.empty fc tr).1
      = ExpansionResult.extended (gEmitted l ++ gBranch l) := by
  have hrule := findApplicableRule_gWitness fc l
  simp only [gBranch] at hrule
  rw [expandOnceUnblocked]
  simp only [blockedTimes_empty, findUnexpandedUnblockedWith, isExpanded, gBranch,
    List.find?_cons, List.contains_nil, Bool.not_false, Bool.and_true, hrule,
    Option.isNone_some]

/-- **The residual is refuted at EVERY nonempty finite `L`, at every frame class.** -/
theorem unorderedSuccessorLabelClosed_nonempty_false
    (fc : FormalSystem.ProofSystem.FrameClass) (L : Finset Label) (hne : L.Nonempty) :
    ¬ UnorderedSuccessorLabelClosed fc L := by
  intro h
  have hine : (L.image (·.world)).Nonempty := hne.image _
  obtain ⟨l₀, hl₀, hl₀w⟩ := Finset.mem_image.mp ((L.image (·.world)).max'_mem hine)
  have hstep := expandOnceUnblocked_gBranch fc EventualityTracker.empty l₀
  have hmem : (gEmitted l₀ ++ gBranch l₀)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked (gBranch l₀) TimeOrdering.empty fc EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbl : ∀ y ∈ gBranch l₀, y.label ∈ L := by
    intro y hy
    simp only [gBranch, List.mem_cons, List.not_mem_nil, or_false] at hy
    subst hy
    simpa [gWitness, SignedFormula.neg] using hl₀
  have hbad := h (gBranch l₀) TimeOrdering.empty EventualityTracker.empty hbl _ hmem
    (SignedFormula.neg gp ⟨l₀.world + 1, l₀.time⟩) (by simp [gEmitted])
  simp only [SignedFormula.neg] at hbad
  have hle : l₀.world + 1 ≤ (L.image (·.world)).max' hine :=
    Finset.le_max' (L.image (·.world)) (l₀.world + 1)
      (Finset.mem_image.mpr ⟨⟨l₀.world + 1, l₀.time⟩, hbad, rfl⟩)
  rw [hl₀w] at hle
  exact absurd hle (Nat.not_succ_le_self _)

/-- **The `Ord` variant, refuted at every nonempty `L`.** Stronger, since `Ord` is the weaker
predicate; the plain form follows. -/
theorem unorderedSuccessorLabelClosedOrd_nonempty_false
    (fc : FormalSystem.ProofSystem.FrameClass) (L : Finset Label) (hne : L.Nonempty) :
    ¬ UnorderedSuccessorLabelClosedOrd fc L := by
  intro h
  have hine : (L.image (·.world)).Nonempty := hne.image _
  obtain ⟨l₀, hl₀, hl₀w⟩ := Finset.mem_image.mp ((L.image (·.world)).max'_mem hine)
  have hstep := expandOnceUnblocked_gBranch fc EventualityTracker.empty l₀
  have hmem : (gEmitted l₀ ++ gBranch l₀)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked (gBranch l₀) TimeOrdering.empty fc EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbl : ∀ y ∈ gBranch l₀, y.label ∈ L := by
    intro y hy
    simp only [gBranch, List.mem_cons, List.not_mem_nil, or_false] at hy
    subst hy
    simpa [gWitness, SignedFormula.neg] using hl₀
  have hbad := h (gBranch l₀) TimeOrdering.empty EventualityTracker.empty
    (ordTimesKnown_empty (gBranch l₀)) hbl _ hmem
    (SignedFormula.neg gp ⟨l₀.world + 1, l₀.time⟩) (by simp [gEmitted])
  simp only [SignedFormula.neg] at hbad
  have hle : l₀.world + 1 ≤ (L.image (·.world)).max' hine :=
    Finset.le_max' (L.image (·.world)) (l₀.world + 1)
      (Finset.mem_image.mpr ⟨⟨l₀.world + 1, l₀.time⟩, hbad, rfl⟩)
  rw [hl₀w] at hle
  exact absurd hle (Nat.not_succ_le_self _)

/-- Plain form, re-derived from the Ord form. -/
theorem unorderedSuccessorLabelClosed_nonempty_false'
    (fc : FormalSystem.ProofSystem.FrameClass) (L : Finset Label) (hne : L.Nonempty) :
    ¬ UnorderedSuccessorLabelClosed fc L :=
  fun h => unorderedSuccessorLabelClosedOrd_nonempty_false fc L hne
    (unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed h)

/-- Satisfiable at the empty label set. -/
theorem unorderedSuccessorLabelClosed_empty
    (fc : FormalSystem.ProofSystem.FrameClass) :
    UnorderedSuccessorLabelClosed fc (∅ : Finset Label) := by
  intro b ord tr hbl nb hnb x hx
  have hb : b = [] := by
    rcases b with _ | ⟨y, ys⟩
    · rfl
    · exact absurd (hbl y (by simp)) (by simp)
  subst hb
  rw [expandOnceUnblocked] at hnb
  simp only [findUnexpandedUnblockedWith, List.find?_nil, Option.isNone_none] at hnb
  simp [unorderedSuccessorBranches] at hnb
