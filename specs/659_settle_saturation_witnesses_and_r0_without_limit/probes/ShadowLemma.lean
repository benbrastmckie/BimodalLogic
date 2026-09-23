import Mathlib.Topology.Order.Compact
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: the extractable general lemma behind the shadow argument

The *only* part of the *Saturation* proofs for the two-origin half-line and the hedgehog that is
frame-independent: a `⊇`-directed family of nonempty sets whose images under a map into a
topological space are compact and closed has a **common image point**. Lifting that point back to
a common *element* is the part that does not generalize — it uses the frame's own fibre structure
over the accumulation point, and the two witnesses need genuinely different arguments there (the
two-origin frame needs directedness to pick one of the two origins at `r = 0`; the hedgehog needs
directedness to pick one ray at `r > 0`, and `r = 0` is free because the centre is the unique
preimage). So this is the honest generality.
-/

open Set

namespace FormalSystem.Semantics.TaskFrame

/-- **The shadow lemma.** A `⊇`-directed family of nonempty sets whose images under `φ` are
compact and closed has a point of `X` lying in every member's image. -/
theorem exists_mem_image_of_directedFamily {W : Type} {X : Type} [TopologicalSpace X]
    (φ : W → X) {S : Set (Set W)} (hdir : DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty)
    (hc : ∀ s ∈ S, IsCompact (φ '' s)) (hcl : ∀ s ∈ S, IsClosed (φ '' s)) :
    ∃ r : X, ∀ s ∈ S, r ∈ φ '' s := by
  obtain ⟨hSne, hdirS⟩ := hdir
  haveI : Nonempty ↥S := hSne.to_subtype
  have hdirec : Directed (· ⊇ ·) (fun i : ↥S => φ '' (i : Set W)) := by
    rintro ⟨s₁, h₁⟩ ⟨s₂, h₂⟩
    obtain ⟨s', hs', hsub⟩ := hdirS s₁ h₁ s₂ h₂
    exact ⟨⟨s', hs'⟩, Set.image_mono (hsub.trans Set.inter_subset_left),
      Set.image_mono (hsub.trans Set.inter_subset_right)⟩
  obtain ⟨r, hr⟩ := IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed _
    hdirec (fun i => (hne i.1 i.2).image _) (fun i => hc i.1 i.2) (fun i => hcl i.1 i.2)
  rw [Set.mem_iInter] at hr
  exact ⟨r, fun s hs => hr ⟨s, hs⟩⟩

/-- The `Icc`-shaped specialisation both witnesses actually use: over a `CompactIccSpace`, a
member whose shadow is a closed interval needs no separate compactness or closedness argument. -/
theorem exists_mem_image_of_directedFamily_Icc {W : Type} {X : Type} [TopologicalSpace X]
    [LinearOrder X] [OrderClosedTopology X] [CompactIccSpace X]
    (φ : W → X) {S : Set (Set W)} (hdir : DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty) (hIcc : ∀ s ∈ S, ∃ a b : X, φ '' s = Icc a b) :
    ∃ r : X, ∀ s ∈ S, r ∈ φ '' s :=
  exists_mem_image_of_directedFamily φ hdir hne
    (fun s hs => by obtain ⟨a, b, h⟩ := hIcc s hs; rw [h]; exact isCompact_Icc)
    (fun s hs => by obtain ⟨a, b, h⟩ := hIcc s hs; rw [h]; exact isClosed_Icc)

end FormalSystem.Semantics.TaskFrame
