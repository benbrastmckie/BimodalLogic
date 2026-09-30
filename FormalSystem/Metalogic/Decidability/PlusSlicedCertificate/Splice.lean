/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Closure

/-!
# The Q5 Factorization: a Bi-Infinite Realization Is Two Halves

The three named pieces the sliced certificate's liveness computation rests on, and the
factorization they assemble. **This is the justification for `live = fwdLive ∩ bwdLive`**: without
it, combining two independently computed fixpoints would be an unargued guess.

## The three pieces, in the order the factorization takes them

1. `histories_through_paste` — **S4.** Two histories agreeing on the state at `t` paste into a
   history following the first before `t` and the second from `t` on. This is
   `FormalSystem.PlusLanguage.paste` with its `paste_agreeUpTo` / `paste_agreeFrom` lemmas, cited
   rather than re-proved.
2. `truth_of_agree_of_type_eq` and its `paste` instance `label_splices_of_type_eq` — **S5.** A
   Hintikka labelling of a bi-infinite path with a fixed origin type is a backward half and a
   forward half agreeing at the origin: a history agreeing with `ρ` up to `t` and with `σ` from `t`
   on, where `ρ` and `σ` share both the state and the `C`-type at `t`, carries `ρ`'s `C`-type row at
   every time `≤ t` and `σ`'s at every time `≥ t`.
3. `forall_forall_or_iff` — the elementary equivalence
   `(∀ ρ, ∀ σ, P ρ ∨ Q σ) ↔ ((∀ ρ, P ρ) ∨ (∀ σ, Q σ))`, which splits a universal condition over
   pairs of halves into a disjunction of universal conditions over single halves.

## The factorization

`stab_factors`: for a `C`-type `X` at a carrier element `v` and a time `t`, a bi-infinite history
through `v` realizing `X` and satisfying **both** a past-determined property `Bwd` and a
future-determined property `Fwd` exists exactly when each half exists separately.

`not_stab_factors` is its `⊡`-shaped reading: "**no** realization" is "no backward half **or** no
forward half". That disjunction is what `live = fwdLive ∩ bwdLive` computes, and `⊡χ`'s clause is
read through it.

## Locality is a hypothesis, not an assumption about shape

`Bwd` and `Fwd` are arbitrary predicates on histories, constrained only by the two locality
hypotheses `hBwd` and `hFwd`: each is invariant under a change of history that preserves the
`C`-truth rows on its own half-line. That is exactly what `label_splices_of_type_eq` delivers, so
the factorization applies to *any* backward/forward condition expressible in the `C`-labels —
`snce`-fulfilment in the past and `untl`-fulfilment in the future being the two the liveness
fixpoints use.

## Provenance

`truth_of_agree_of_type_eq` is stated and proved here, in library style, with **no hypothesis**
beyond those listed on the declaration itself.

## Tags

plus-language · pasting · splicing · liveness · factorization
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## Piece 3: the elementary split -/

/--
**The elementary split.** A universal condition over *pairs* is a disjunction of universal
conditions over *singles*.

No non-emptiness hypothesis is needed in either direction, and none is taken: when an index type is
empty the corresponding universal is vacuously true on both sides. (The plan anticipated needing
inhabited index types; it does not — see this phase's recorded deviations.) Classical reasoning is
used, in the `by_cases` on the left universal.
-/
theorem forall_forall_or_iff {α β : Sort*} (P : α → Prop) (Q : β → Prop) :
    (∀ (a : α) (b : β), P a ∨ Q b) ↔ ((∀ a, P a) ∨ (∀ b, Q b)) := by
  classical
  constructor
  · intro h
    by_cases hP : ∀ a, P a
    · exact Or.inl hP
    · obtain ⟨a₀, ha₀⟩ := not_forall.mp hP
      exact Or.inr fun b => (h a₀ b).resolve_left ha₀
  · rintro (hP | hQ)
    · exact fun a _ => Or.inl (hP a)
    · exact fun _ b => Or.inr (hQ b)

/-! ## Piece 1: pasting two histories through a shared state -/

/--
**Two histories through a shared state paste.** The pasted history keeps the state at `t` and
agrees with the first everywhere at or before `t` and with the second everywhere at or after `t`.

This is `FormalSystem.PlusLanguage.paste` together with `paste_agreeUpTo` and `paste_agreeFrom`,
cited rather than re-proved; it is stated here so that the factorization below names one lemma
instead of three.
-/
theorem histories_through_paste [F.IsRegular] (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) :
    ∃ π : WorldHistory F, π.state t = ρ.state t ∧ AgreeUpTo π ρ t ∧ AgreeFrom π σ t :=
  ⟨paste ρ σ t hsame, paste_agreeUpTo ρ σ t hsame t le_rfl,
    paste_agreeUpTo ρ σ t hsame, paste_agreeFrom ρ σ t hsame⟩

/-! ## Piece 2: the type row splices

Transcribed from `Probe703Paste.truth_of_agree_of_type_eq` with no added hypothesis.
-/

/--
**A `C`-type row splices at a shared type.** If `π` agrees with `ρ` up to `t` and with `σ` from `t`
on, and `ρ` and `σ` have the same `C`-type at `t`, then `π` carries `ρ`'s `C`-truth row at every
time `≤ t` and `σ`'s at every time `≥ t`.

No frame-class assumption, no discreteness, no bound. `C` is asked only to be closed under the
subformulas the temporal and propositional clauses look at — which the target closure
`plusClosureOf` satisfies, by `plusClosureOf_imp_left` and its siblings.
-/
theorem truth_of_agree_of_type_eq (M : TaskModel F) (π ρ σ : WorldHistory F) (t : F.Duration)
    (hup : AgreeUpTo π ρ t) (hfrom : AgreeFrom π σ t)
    (C : Set PlusFormula)
    (himp : ∀ a b, PlusFormula.imp a b ∈ C → a ∈ C ∧ b ∈ C)
    (huntl : ∀ g e, PlusFormula.untl g e ∈ C → g ∈ C ∧ e ∈ C)
    (hsnce : ∀ g e, PlusFormula.snce g e ∈ C → g ∈ C ∧ e ∈ C)
    (htype : ∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ PlusTruthAt M σ t ψ)) :
    ∀ ψ ∈ C, (∀ s, s ≤ t → (PlusTruthAt M π s ψ ↔ PlusTruthAt M ρ s ψ)) ∧
      (∀ s, t ≤ s → (PlusTruthAt M π s ψ ↔ PlusTruthAt M σ s ψ)) := by
  intro ψ
  induction ψ with
  | atom p =>
    intro _
    refine ⟨fun s hs => ?_, fun s hs => ?_⟩
    · change M.valuation _ p ↔ M.valuation _ p
      rw [hup s hs]
    · change M.valuation _ p ↔ M.valuation _ p
      rw [hfrom s hs]
  | bot => intro _; exact ⟨fun _ _ => Iff.rfl, fun _ _ => Iff.rfl⟩
  | imp a b iha ihb =>
    intro h
    obtain ⟨ha, hb⟩ := himp a b h
    exact ⟨fun s hs => Iff.imp ((iha ha).1 s hs) ((ihb hb).1 s hs),
      fun s hs => Iff.imp ((iha ha).2 s hs) ((ihb hb).2 s hs)⟩
  | box a _ => intro _; exact ⟨fun _ _ => Iff.rfl, fun _ _ => Iff.rfl⟩
  | stab a _ =>
    intro _
    exact ⟨fun s hs => stab_congr_state M π ρ s (hup s hs) a,
      fun s hs => stab_congr_state M π σ s (hfrom s hs) a⟩
  | untl g e ihg ihe =>
    intro h
    obtain ⟨hg, he⟩ := huntl g e h
    have Eg := ihg hg
    have Ee := ihe he
    refine ⟨fun s hs => ?_, fun s hs => ?_⟩
    · constructor
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : s' ≤ t
        · exact ⟨s', h1, (Ee.1 s' hs').mp hev, fun r hr1 hr2 =>
            (Eg.1 r (le_trans hr2.le hs')).mp (hgd r hr1 hr2)⟩
        · have hts' : t < s' := not_le.mp hs'
          have hσ : PlusTruthAt M σ t (.untl g e) :=
            ⟨s', hts', (Ee.2 s' hts'.le).mp hev, fun r hr1 hr2 =>
              (Eg.2 r hr1.le).mp (hgd r (lt_of_le_of_lt hs hr1) hr2)⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mpr hσ
          refine ⟨s'', lt_of_le_of_lt hs h1'', hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : r ≤ t
          · exact (Eg.1 r hr).mp (hgd r hr1 (lt_of_le_of_lt hr hts'))
          · exact hgd'' r (not_le.mp hr) hr2
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : s' ≤ t
        · exact ⟨s', h1, (Ee.1 s' hs').mpr hev, fun r hr1 hr2 =>
            (Eg.1 r (le_trans hr2.le hs')).mpr (hgd r hr1 hr2)⟩
        · have hts' : t < s' := not_le.mp hs'
          have hρ : PlusTruthAt M ρ t (.untl g e) :=
            ⟨s', hts', hev, fun r hr1 hr2 => hgd r (lt_of_le_of_lt hs hr1) hr2⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mp hρ
          refine ⟨s'', lt_of_le_of_lt hs h1'', (Ee.2 s'' h1''.le).mpr hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : r ≤ t
          · exact (Eg.1 r hr).mpr (hgd r hr1 (lt_of_le_of_lt hr hts'))
          · exact (Eg.2 r (not_le.mp hr).le).mpr (hgd'' r (not_le.mp hr) hr2)
    · exact exists_congr fun s' => and_congr_right fun h1 =>
        and_congr (Ee.2 s' (le_trans hs h1.le))
          (forall_congr' fun r => imp_congr_right fun hr1 => imp_congr_right fun _ =>
            Eg.2 r (le_trans hs hr1.le))
  | snce g e ihg ihe =>
    intro h
    obtain ⟨hg, he⟩ := hsnce g e h
    have Eg := ihg hg
    have Ee := ihe he
    refine ⟨fun s hs => ?_, fun s hs => ?_⟩
    · exact exists_congr fun s' => and_congr_right fun h1 =>
        and_congr (Ee.1 s' (le_trans h1.le hs))
          (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hr2 =>
            Eg.1 r (le_trans hr2.le hs))
    · constructor
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : t ≤ s'
        · exact ⟨s', h1, (Ee.2 s' hs').mp hev, fun r hr1 hr2 =>
            (Eg.2 r (le_trans hs' hr1.le)).mp (hgd r hr1 hr2)⟩
        · have hts' : s' < t := not_le.mp hs'
          have hρ : PlusTruthAt M ρ t (.snce g e) :=
            ⟨s', hts', (Ee.1 s' hts'.le).mp hev, fun r hr1 hr2 =>
              (Eg.1 r hr2.le).mp (hgd r hr1 (lt_of_lt_of_le hr2 hs))⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mp hρ
          refine ⟨s'', lt_of_lt_of_le h1'' hs, hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : t ≤ r
          · exact (Eg.2 r hr).mp (hgd r (lt_of_lt_of_le hts' hr) hr2)
          · exact hgd'' r hr1 (not_le.mp hr)
      · rintro ⟨s', h1, hev, hgd⟩
        by_cases hs' : t ≤ s'
        · exact ⟨s', h1, (Ee.2 s' hs').mpr hev, fun r hr1 hr2 =>
            (Eg.2 r (le_trans hs' hr1.le)).mpr (hgd r hr1 hr2)⟩
        · have hts' : s' < t := not_le.mp hs'
          have hσ : PlusTruthAt M σ t (.snce g e) :=
            ⟨s', hts', hev, fun r hr1 hr2 => hgd r hr1 (lt_of_lt_of_le hr2 hs)⟩
          obtain ⟨s'', h1'', hev'', hgd''⟩ := (htype _ h).mpr hσ
          refine ⟨s'', lt_of_lt_of_le h1'' hs, (Ee.1 s'' h1''.le).mpr hev'', fun r hr1 hr2 => ?_⟩
          by_cases hr : t ≤ r
          · exact (Eg.2 r hr).mpr (hgd r (lt_of_lt_of_le hts' hr) hr2)
          · exact (Eg.1 r (not_le.mp hr).le).mpr (hgd'' r hr1 (not_le.mp hr))

/--
**The same fact at the landed `paste`.** On a regular frame, histories sharing a state and a
`C`-type at `t` paste to a history carrying both type rows.
-/
theorem label_splices_of_type_eq [F.IsRegular] (M : TaskModel F) (ρ σ : WorldHistory F)
    (t : F.Duration) (hsame : ρ.state t = σ.state t) (C : Set PlusFormula)
    (himp : ∀ a b, PlusFormula.imp a b ∈ C → a ∈ C ∧ b ∈ C)
    (huntl : ∀ g e, PlusFormula.untl g e ∈ C → g ∈ C ∧ e ∈ C)
    (hsnce : ∀ g e, PlusFormula.snce g e ∈ C → g ∈ C ∧ e ∈ C)
    (htype : ∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ PlusTruthAt M σ t ψ)) :
    ∀ ψ ∈ C, (∀ s, s ≤ t →
        (PlusTruthAt M (paste ρ σ t hsame) s ψ ↔ PlusTruthAt M ρ s ψ)) ∧
      (∀ s, t ≤ s → (PlusTruthAt M (paste ρ σ t hsame) s ψ ↔ PlusTruthAt M σ s ψ)) :=
  truth_of_agree_of_type_eq M _ ρ σ t (paste_agreeUpTo ρ σ t hsame) (paste_agreeFrom ρ σ t hsame)
    C himp huntl hsnce htype

/-! ## The closure is a legitimate `C`

Instantiating the three subformula hypotheses at the target closure, so that no consumer has to.
-/

/-- The target closure is closed under the implication's two components. -/
theorem plusClosure_himp (S : PlusContext) :
    ∀ a b, PlusFormula.imp a b ∈ (↑(plusClosureOf S) : Set PlusFormula) →
      a ∈ (↑(plusClosureOf S) : Set PlusFormula) ∧ b ∈ (↑(plusClosureOf S) : Set PlusFormula) :=
  fun _ _ h => ⟨plusClosureOf_imp_left h, plusClosureOf_imp_right h⟩

/-- The target closure is closed under an `untl`'s guard and event. -/
theorem plusClosure_huntl (S : PlusContext) :
    ∀ g e, PlusFormula.untl g e ∈ (↑(plusClosureOf S) : Set PlusFormula) →
      g ∈ (↑(plusClosureOf S) : Set PlusFormula) ∧ e ∈ (↑(plusClosureOf S) : Set PlusFormula) :=
  fun _ _ h => ⟨plusClosureOf_untl_right h, plusClosureOf_untl_left h⟩

/-- The target closure is closed under a `snce`'s guard and event. -/
theorem plusClosure_hsnce (S : PlusContext) :
    ∀ g e, PlusFormula.snce g e ∈ (↑(plusClosureOf S) : Set PlusFormula) →
      g ∈ (↑(plusClosureOf S) : Set PlusFormula) ∧ e ∈ (↑(plusClosureOf S) : Set PlusFormula) :=
  fun _ _ h => ⟨plusClosureOf_snce_right h, plusClosureOf_snce_left h⟩

/-! ## The factorization -/

/--
**The Q5 factorization.**

For a `C`-type `X` at a carrier element `v` and a time `t`: a bi-infinite history through `v`
realizing `X` at `t` and satisfying **both** a past-determined property `Bwd` and a
future-determined property `Fwd` exists exactly when each half exists on its own.

`→` is trivial (one history serves as both halves). `←` is `paste` plus
`label_splices_of_type_eq`: the pasted history keeps the state and the `C`-type at `t`, carries
`ρ`'s `C`-truth rows at every time `≤ t`, so `hBwd` transfers `Bwd`, and `σ`'s at every time
`≥ t`, so `hFwd` transfers `Fwd`.

**This lemma is the justification for `live = fwdLive ∩ bwdLive`.** The two fixpoints are combined
rather than solved jointly precisely because a realization factors this way, and nothing weaker
than this would license the intersection.
-/
theorem stab_factors [F.IsRegular] (M : TaskModel F) (C : Set PlusFormula)
    (himp : ∀ a b, PlusFormula.imp a b ∈ C → a ∈ C ∧ b ∈ C)
    (huntl : ∀ g e, PlusFormula.untl g e ∈ C → g ∈ C ∧ e ∈ C)
    (hsnce : ∀ g e, PlusFormula.snce g e ∈ C → g ∈ C ∧ e ∈ C)
    (t : F.Duration) (v : F.WorldState) (X : Set PlusFormula)
    (Bwd Fwd : WorldHistory F → Prop)
    (hBwd : ∀ π ρ : WorldHistory F,
      (∀ ψ ∈ C, ∀ s, s ≤ t → (PlusTruthAt M π s ψ ↔ PlusTruthAt M ρ s ψ)) → Bwd ρ → Bwd π)
    (hFwd : ∀ π σ : WorldHistory F,
      (∀ ψ ∈ C, ∀ s, t ≤ s → (PlusTruthAt M π s ψ ↔ PlusTruthAt M σ s ψ)) → Fwd σ → Fwd π) :
    (∃ π : WorldHistory F,
        π.state t = v ∧ (∀ ψ ∈ C, (PlusTruthAt M π t ψ ↔ ψ ∈ X)) ∧ Bwd π ∧ Fwd π)
      ↔ (∃ ρ : WorldHistory F,
            ρ.state t = v ∧ (∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ ψ ∈ X)) ∧ Bwd ρ)
        ∧ (∃ σ : WorldHistory F,
            σ.state t = v ∧ (∀ ψ ∈ C, (PlusTruthAt M σ t ψ ↔ ψ ∈ X)) ∧ Fwd σ) := by
  constructor
  · rintro ⟨π, hv, hX, hb, hf⟩
    exact ⟨⟨π, hv, hX, hb⟩, ⟨π, hv, hX, hf⟩⟩
  · rintro ⟨⟨ρ, hρv, hρX, hρb⟩, ⟨σ, hσv, hσX, hσf⟩⟩
    have hsame : ρ.state t = σ.state t := hρv.trans hσv.symm
    have htype : ∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ PlusTruthAt M σ t ψ) :=
      fun ψ hψ => (hρX ψ hψ).trans (hσX ψ hψ).symm
    have hsplice := label_splices_of_type_eq M ρ σ t hsame C himp huntl hsnce htype
    refine ⟨paste ρ σ t hsame, ?_, ?_, ?_, ?_⟩
    · exact (paste_agreeUpTo ρ σ t hsame t le_rfl).trans hρv
    · exact fun ψ hψ => ((hsplice ψ hψ).1 t le_rfl).trans (hρX ψ hψ)
    · exact hBwd _ ρ (fun ψ hψ => (hsplice ψ hψ).1) hρb
    · exact hFwd _ σ (fun ψ hψ => (hsplice ψ hψ).2) hσf

/--
**The `⊡`-shaped reading of the factorization.** "**No** bi-infinite realization of `X` at `v`" is
"no backward half **or** no forward half".

This is the form a `⊡χ`-clause is read through, and the shape `live = fwdLive ∩ bwdLive` computes:
a position is dropped from `live` exactly when one of the two halves is missing.
-/
theorem not_stab_factors [F.IsRegular] (M : TaskModel F) (C : Set PlusFormula)
    (himp : ∀ a b, PlusFormula.imp a b ∈ C → a ∈ C ∧ b ∈ C)
    (huntl : ∀ g e, PlusFormula.untl g e ∈ C → g ∈ C ∧ e ∈ C)
    (hsnce : ∀ g e, PlusFormula.snce g e ∈ C → g ∈ C ∧ e ∈ C)
    (t : F.Duration) (v : F.WorldState) (X : Set PlusFormula)
    (Bwd Fwd : WorldHistory F → Prop)
    (hBwd : ∀ π ρ : WorldHistory F,
      (∀ ψ ∈ C, ∀ s, s ≤ t → (PlusTruthAt M π s ψ ↔ PlusTruthAt M ρ s ψ)) → Bwd ρ → Bwd π)
    (hFwd : ∀ π σ : WorldHistory F,
      (∀ ψ ∈ C, ∀ s, t ≤ s → (PlusTruthAt M π s ψ ↔ PlusTruthAt M σ s ψ)) → Fwd σ → Fwd π) :
    (¬ ∃ π : WorldHistory F,
        π.state t = v ∧ (∀ ψ ∈ C, (PlusTruthAt M π t ψ ↔ ψ ∈ X)) ∧ Bwd π ∧ Fwd π)
      ↔ ((¬ ∃ ρ : WorldHistory F,
            ρ.state t = v ∧ (∀ ψ ∈ C, (PlusTruthAt M ρ t ψ ↔ ψ ∈ X)) ∧ Bwd ρ)
        ∨ (¬ ∃ σ : WorldHistory F,
            σ.state t = v ∧ (∀ ψ ∈ C, (PlusTruthAt M σ t ψ ↔ ψ ∈ X)) ∧ Fwd σ)) := by
  rw [stab_factors M C himp huntl hsnce t v X Bwd Fwd hBwd hFwd, not_and_or]

end FormalSystem.Metalogic.Decidability
