/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live

/-!
# Every Step Path Carries a Canonical Labelling

A `LabRun` is a state path together with a labelling. `Live.lean` asks for runs and says nothing
about which state paths admit one. This module answers that: **every** `G.edge`-path admits a
labelling making it a locally coherent, fulfilling run, built by recursion on the formula and not by
any choice.

## Why this module exists, and what would be unprovable without it

The presented frame `G.frame h` is `FrameOver.ofSlicedStep`, whose histories are *all* the
`G.edge`-paths (`Frame.lean`'s `mem_HF_iff_slicedPath`). `□` and `⊡` quantify over histories.
So the `box` and `stab` cases of a truth lemma have to say something about an arbitrary history,
while the induction hypothesis is available only at a *run* — and a bare history carries no
labelling at all. The step "a history of `G.frame h` is an offset step path, **hence** a labelled
path of `G`" is therefore not a step: it is exactly the content of this module.

The obvious candidate labelling — the *true* type `plusTypeAtM`, the closure members actually true
along the history — does not work, and the reason is worth recording because it is what forced the
syntactic construction below. `Compression/Types.lean` proves the true type locally coherent and
fulfilling, but its local coherence takes `hbx`, the hypothesis that the box guess is semantically
correct; and `AgreesOnState` for the true type is, at the `□` and `⊡` shapes, that same semantic
correctness. Proving it needs runs at arbitrary histories, which is what we were trying to build.
The circle is not formula-structural and no induction breaks it, because `AgreesOnState` quantifies
over **every** state shape of the closure, including shapes larger than the formula in hand.

`canAt` breaks the circle by never mentioning truth. Its `□` and `⊡` cases read the slice labelling
*by fiat*, so `AgreesOnState` holds by construction (`canLab_agreesOnState`, which needs no
hypothesis at all); its `→` case is the implication clause by fiat; and its `U` and `S` cases are
the *least* solutions of the one-step clauses, so the step clauses hold and fulfilment is free
(`canLab_fulfilling`). The only hypothesis anywhere here is (C3b) `BoxLabelFaithful`, and it is
needed for exactly one of the five local-coherence clauses — the `□` clause, which relates the
label to `G.bx` and not to the slice.

## What a canonical run is *not*

A canonical run is **not** claimed to label its path with the truths of the presented model. That
claim is the truth lemma, it is proved elsewhere, and it is false for an arbitrary certificate —
`G.bx` and `G.slab` are unconstrained data until a checker constrains them. What is claimed here is
purely syntactic: whatever the certificate's guesses are, every step path has a labelling
consistent with them.

## Main definitions

- `PlusSlicedCertificate.canAt` — the canonical membership predicate, by recursion on the formula
- `PlusSlicedCertificate.canLab` — the canonical label, the closure filtered by `canAt`
- `PlusSlicedCertificate.canRun` — the `LabRun` an arbitrary `G.edge`-path presents

## Main results

- `PlusSlicedCertificate.canLab_agreesOnState` — agreement on the state shapes, hypothesis-free
- `PlusSlicedCertificate.canLab_localCoherent` — the five clauses, from (C3b) alone
- `PlusSlicedCertificate.canLab_fulfilling` — fulfilment, hypothesis-free
- `PlusSlicedCertificate.canRun_fulfilling` — the canonical run discharges both halves
- `PlusSlicedCertificate.live_canRun` — every step path occupies a live position at every time

## Tags

plus-language · certificate · time-sliced · labelling · liveness
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The canonical membership predicate -/

/--
**The canonical membership predicate of a state path.**

By recursion on the formula, with the time as a parameter. Each clause is the clause the
certificate's own conditions read, turned into a definition:

* `atom`, `box`, `stab` — the three **state shapes** — read the slice labelling at `(t, g t)`
  directly. This is what makes `AgreesOnState` hold by construction.
* `bot` is absent and `imp` is the implication clause, so `LabCoherent` holds by construction.
* `untl` and `snce` are the *least* solutions of their one-step clauses — the existential form,
  not the recursive one — so both the step clauses and fulfilment hold by construction.

Nothing here mentions `PlusTruthAt`: see the module header for why a truth-based labelling cannot
be used.
-/
def canAt (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) : PlusFormula → ℤ → Prop
  | .atom a, t => PlusFormula.atom a ∈ G.slab t (g t)
  | .bot, _ => False
  | .imp a b, t => canAt G g a t → canAt G g b t
  | .box χ, t => PlusFormula.box χ ∈ G.slab t (g t)
  | .stab χ, t => PlusFormula.stab χ ∈ G.slab t (g t)
  | .untl a b, t => ∃ s : ℤ, t < s ∧ canAt G g b s ∧ ∀ r : ℤ, t < r → r < s → canAt G g a r
  | .snce a b, t => ∃ s : ℤ, s < t ∧ canAt G g b s ∧ ∀ r : ℤ, s < r → r < t → canAt G g a r

/-- The `atom` clause, as a rewrite. -/
@[simp] theorem canAt_atom (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (a : FormalSystem.Syntax.Atom) (t : ℤ) :
    G.canAt g (PlusFormula.atom a) t ↔ PlusFormula.atom a ∈ G.slab t (g t) := Iff.rfl

/-- The `bot` clause: `⊥` is never canonically present. -/
@[simp] theorem canAt_bot (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) (t : ℤ) :
    ¬ G.canAt g PlusFormula.bot t := id

/-- The `imp` clause. -/
@[simp] theorem canAt_imp (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (a b : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.imp a b) t ↔ (G.canAt g a t → G.canAt g b t) := Iff.rfl

/-- The `box` clause: read off the slice labelling. -/
@[simp] theorem canAt_box (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (χ : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.box χ) t ↔ PlusFormula.box χ ∈ G.slab t (g t) := Iff.rfl

/-- The `stab` clause: read off the slice labelling. -/
@[simp] theorem canAt_stab (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (χ : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.stab χ) t ↔ PlusFormula.stab χ ∈ G.slab t (g t) := Iff.rfl

/-- The `untl` clause, in its existential form. -/
@[simp] theorem canAt_untl (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (a b : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.untl a b) t ↔
      ∃ s : ℤ, t < s ∧ G.canAt g b s ∧ ∀ r : ℤ, t < r → r < s → G.canAt g a r := Iff.rfl

/-- The `snce` clause, in its existential form. -/
@[simp] theorem canAt_snce (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (a b : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.snce a b) t ↔
      ∃ s : ℤ, s < t ∧ G.canAt g b s ∧ ∀ r : ℤ, s < r → r < t → G.canAt g a r := Iff.rfl

/-! ### The one-step unfoldings

The two lemmas the step clauses are read off. Both are the `plusTruth_untl_succ` argument with the
truth predicate replaced by `canAt` — stated and proved here rather than transported, because
`canAt` is not a truth predicate and no transport applies.
-/

/-- **The one-step unfolding of the canonical `untl`.** -/
theorem canAt_untl_succ (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (a b : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.untl a b) t ↔
      (G.canAt g b (t + 1) ∨
        (G.canAt g a (t + 1) ∧ G.canAt g (PlusFormula.untl a b) (t + 1))) := by
  constructor
  · rintro ⟨s, hts, hse, hguard⟩
    rcases eq_or_lt_of_le (show t + 1 ≤ s by omega) with heq | hlt
    · exact Or.inl (heq ▸ hse)
    · exact Or.inr ⟨hguard (t + 1) (by omega) hlt, s, hlt, hse,
        fun r hr1 hr2 => hguard r (by omega) hr2⟩
  · rintro (h | ⟨hg, s, hts, hse, hguard⟩)
    · exact ⟨t + 1, by omega, h, fun r hr1 hr2 => absurd (show False by omega) not_false⟩
    · refine ⟨s, by omega, hse, ?_⟩
      intro r hr1 hr2
      rcases eq_or_lt_of_le (show t + 1 ≤ r by omega) with heq | hlt
      · exact heq ▸ hg
      · exact hguard r hlt hr2

/-- **The one-step unfolding of the canonical `snce`**, the leftward mirror. -/
theorem canAt_snce_pred (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n)
    (a b : PlusFormula) (t : ℤ) :
    G.canAt g (PlusFormula.snce a b) t ↔
      (G.canAt g b (t - 1) ∨
        (G.canAt g a (t - 1) ∧ G.canAt g (PlusFormula.snce a b) (t - 1))) := by
  constructor
  · rintro ⟨s, hst, hse, hguard⟩
    rcases eq_or_lt_of_le (show s ≤ t - 1 by omega) with heq | hlt
    · exact Or.inl (heq ▸ hse)
    · exact Or.inr ⟨hguard (t - 1) hlt (by omega), s, hlt, hse,
        fun r hr1 hr2 => hguard r hr1 (by omega)⟩
  · rintro (h | ⟨hg, s, hst, hse, hguard⟩)
    · exact ⟨t - 1, by omega, h, fun r hr1 hr2 => absurd (show False by omega) not_false⟩
    · refine ⟨s, by omega, hse, ?_⟩
      intro r hr1 hr2
      rcases eq_or_lt_of_le (show r ≤ t - 1 by omega) with heq | hlt
      · exact heq ▸ hg
      · exact hguard r hr1 hlt

/-! ## The canonical label -/

/--
**The canonical label of a state path at a time**: the target closure filtered by `canAt`.

`Classical.decPred` is used for the filter, exactly as `plusTypeAtM` does: `canAt` is a `Prop`
with an unbounded existential in its temporal cases and is not decidable. Nothing computational
depends on this definition — a checker reads `G.liveAt`, never a canonical label.
-/
noncomputable def canLab (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) (t : ℤ) :
    Finset PlusFormula :=
  @Finset.filter PlusFormula (fun ψ => G.canAt g ψ t) (Classical.decPred _)
    (plusClosureOf (Γ ++ Del))

theorem mem_canLab (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) {t : ℤ}
    {ψ : PlusFormula} :
    ψ ∈ G.canLab g t ↔ ψ ∈ plusClosureOf (Γ ++ Del) ∧ G.canAt g ψ t := by
  simp only [canLab, Finset.mem_filter]

theorem canLab_subset (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) (t : ℤ) :
    G.canLab g t ⊆ plusClosureOf (Γ ++ Del) :=
  fun _ hψ => (G.mem_canLab g).mp hψ |>.1

/-! ## The three obligations the canonical label discharges -/

/--
**Agreement on the state shapes, with no hypothesis at all.**

The `atom`, `box` and `stab` clauses of `canAt` *are* the slice labelling, and the other four
shapes are not state shapes, so `IsStateShape` rules them out. This is the lemma the true type
cannot supply: see the module header.
-/
theorem canLab_agreesOnState (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) (t : ℤ) :
    G.AgreesOnState t (g t) (G.canLab g t) := by
  intro ψ hψ hst
  rw [G.mem_canLab g]
  cases ψ with
  | atom a => exact ⟨fun h => h.2, fun h => ⟨hψ, h⟩⟩
  | bot => exact absurd hst (by simp [IsStateShape])
  | imp a b => exact absurd hst (by simp [IsStateShape])
  | box χ => exact ⟨fun h => h.2, fun h => ⟨hψ, h⟩⟩
  | untl a b => exact absurd hst (by simp [IsStateShape])
  | snce a b => exact absurd hst (by simp [IsStateShape])
  | stab χ => exact ⟨fun h => h.2, fun h => ⟨hψ, h⟩⟩

/--
**The five local-coherence clauses, from (C3b) alone.**

Four of the five are by construction. The `□` clause is the one that is not: it relates the label
to the box guess `G.bx` rather than to the slice, and `canAt` reads the slice, so the two are
joined by (C3b) `BoxLabelFaithful` and by nothing else.
-/
theorem canLab_localCoherent (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) : PlusLocalCoherentSeqLab Γ Del G.bx (G.canLab g) := by
  intro t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro h
    exact (G.canAt_bot g t) ((G.mem_canLab g).mp h).2
  · intro a b hab
    rw [G.mem_canLab g]
    constructor
    · rintro ⟨-, himp⟩ ha
      exact (G.mem_canLab g).mpr ⟨plusClosureOf_imp_right hab,
        himp ((G.mem_canLab g).mp ha).2⟩
    · intro h
      refine ⟨hab, fun hta => ?_⟩
      exact ((G.mem_canLab g).mp
        (h ((G.mem_canLab g).mpr ⟨plusClosureOf_imp_left hab, hta⟩))).2
  · intro χ hχ
    rw [G.mem_canLab g]
    constructor
    · rintro ⟨-, hb⟩
      exact (hbox χ hχ t (g t)).mp hb
    · intro hb
      exact ⟨hχ, (hbox χ hχ t (g t)).mpr hb⟩
  · intro a b hab
    rw [G.mem_canLab g, G.mem_canLab g, G.mem_canLab g, G.mem_canLab g,
      G.canAt_untl_succ g a b t]
    constructor
    · rintro ⟨-, h | ⟨hg, hu⟩⟩
      · exact Or.inl ⟨plusClosureOf_untl_left hab, h⟩
      · exact Or.inr ⟨⟨plusClosureOf_untl_right hab, hg⟩, ⟨hab, hu⟩⟩
    · rintro (⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hu⟩⟩)
      · exact ⟨hab, Or.inl he⟩
      · exact ⟨hab, Or.inr ⟨hg, hu⟩⟩
  · intro a b hab
    rw [G.mem_canLab g, G.mem_canLab g, G.mem_canLab g, G.mem_canLab g,
      G.canAt_snce_pred g a b t]
    constructor
    · rintro ⟨-, h | ⟨hg, hs⟩⟩
      · exact Or.inl ⟨plusClosureOf_snce_left hab, h⟩
      · exact Or.inr ⟨⟨plusClosureOf_snce_right hab, hg⟩, ⟨hab, hs⟩⟩
    · rintro (⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hs⟩⟩)
      · exact ⟨hab, Or.inl he⟩
      · exact ⟨hab, Or.inr ⟨hg, hs⟩⟩

/--
**Fulfilment, with no hypothesis at all.**

`canAt`'s temporal clauses are the *existential* forms, so the witness fulfilment asks for is
already in the hypothesis; only the closure guards have to be supplied, and both come from the
label's own membership.
-/
theorem canLab_fulfilling (G : PlusSlicedCertificate Γ Del) (g : ℤ → Fin G.n) :
    PlusFulfillingSeqLab (G.canLab g) := by
  constructor
  · intro t a b hmem
    obtain ⟨hcl, s, hts, hse, hguard⟩ := (G.mem_canLab g).mp hmem
    refine ⟨s, hts, (G.mem_canLab g).mpr ⟨plusClosureOf_untl_left hcl, hse⟩, ?_⟩
    intro r hr1 hr2
    exact (G.mem_canLab g).mpr ⟨plusClosureOf_untl_right hcl, hguard r hr1 hr2⟩
  · intro t a b hmem
    obtain ⟨hcl, s, hst, hse, hguard⟩ := (G.mem_canLab g).mp hmem
    refine ⟨s, hst, (G.mem_canLab g).mpr ⟨plusClosureOf_snce_left hcl, hse⟩, ?_⟩
    intro r hr1 hr2
    exact (G.mem_canLab g).mpr ⟨plusClosureOf_snce_right hcl, hguard r hr1 hr2⟩

/-! ## The canonical run -/

/--
**The run an arbitrary `G.edge`-path presents.**

Every field but `steps` is one of the three lemmas above; `steps` is the hypothesis. (C3b) is the
only condition on the certificate anywhere in the construction.
-/
noncomputable def canRun (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) : G.LabRun where
  st := g
  lab := G.canLab g
  lab_sub := G.canLab_subset g
  agrees := G.canLab_agreesOnState g
  steps := hg
  coherent := G.canLab_localCoherent hbox g

@[simp] theorem canRun_st (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    (G.canRun hbox g hg).st t = g t := rfl

@[simp] theorem canRun_lab (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    (G.canRun hbox g hg).lab t = G.canLab g t := rfl

/-- **The canonical run discharges both halves of fulfilment.** -/
theorem canRun_fulfilling (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) :
    PlusFulfillingSeqLab (G.canRun hbox g hg).lab :=
  G.canLab_fulfilling g

/-- **The position a canonical run occupies**, as a pair of the state and the canonical label. -/
theorem canRun_pos (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    ((G.canRun hbox g hg).pos t).1 = g t ∧ ((G.canRun hbox g hg).pos t).2.1 = G.canLab g t :=
  ⟨rfl, rfl⟩

/--
**Every step path occupies a live position at every time.**

The conclusion the `box` and `stab` cases of a truth lemma read: an arbitrary history is not merely
*some* path, it is a path through live positions, so a clause checked against the live positions
says something about it.
-/
theorem live_canRun (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    G.Live t ((G.canRun hbox g hg).pos t) :=
  G.live_of_path (G.canRun hbox g hg) (G.canRun_fulfilling hbox g hg) t

/--
**Liveness of a step path, stated on the pair the position space is.**

The same fact as `live_canRun` with the position's two components spelled out, so that a clause
quantifying over `p.1` and `p.2.1` can be instantiated without unfolding `LabRun.pos`.
-/
theorem live_canRun_pair (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    G.Live t ((g t, ⟨G.canLab g t, Finset.mem_powerset.mpr (G.canLab_subset g t)⟩) : G.Pos) := by
  have h := G.live_canRun hbox g hg t
  have he : (G.canRun hbox g hg).pos t
      = ((g t, ⟨G.canLab g t, Finset.mem_powerset.mpr (G.canLab_subset g t)⟩) : G.Pos) :=
    Prod.ext rfl (Subtype.ext rfl)
  rwa [he] at h

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
