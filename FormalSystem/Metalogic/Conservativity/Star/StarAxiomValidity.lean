/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.StarLanguage.Axioms
import FormalSystem.Semantics.StarLanguage.StarValidity
import FormalSystem.Metalogic.Conservativity.Plus.AxiomValidity
import FormalSystem.Metalogic.Conservativity.Star.StarPasting

/-!
# Validity and swap-validity of every TM⋆ axiom schema

The two dispatch lemmas of TM⋆ soundness, one arm per `StarAxiom` constructor and **no wildcard
arm** — so that a constructor added to `StarAxiom` fails the build here until its arm is
supplied:

- `starAxiom_validIn_min` — every schema is valid at its own `minFrameClass`;
- `starAxiom_swap_validIn_min` — every schema's temporal dual is valid at its own
  `minFrameClass`.

The second is what makes the `temporal_duality` rule sound **semantically**
(`Conservativity/Star/StarSoundness.lean`, the companion recursion). No proof-theoretic mirror
argument is used, and — as everywhere in this tree — no argument by uniform substitution: TM⁺ is
already not substitution-closed via `PlusAxiom.atom_stab`, and nothing here needs it.

## How the arms close

- **The 53 TM⁺ mirror arms** are named `starValid_*` lemmas, proved **directly against
  `StarTruthAt` at arbitrary `StarFormula` metavariables**. The five closed uniformity schemata
  and the two seriality schemata are parameterless formulas, hence literally `ofPlus` images, and
  transport along `starValidOnFrames_ofPlus` (`Semantics/StarLanguage/StarValidity.lean`); everything else is
  a fresh proof. The order-theoretic content is never inlined: `prior_UZ`/`prior_SZ`/`z1` consume
  `SoundnessLemmas/DiscreteOrder.lean` and `sep` consumes `SoundnessLemmas/Separability.lean`,
  each at a `StarTruthAt` predicate.

  **No L⋆ atomization is used, and none can exist.** The TM⁺ arms of `plusAxiom_validIn_min` go
  through `Conservativity/Plus/Atomization.lean`, which rests on `stab_state_only` — the
  invariant `StarFormula` is built to break, since neither `↓ⁱχ` nor `↑ⁱχ` is state-determined.
  Facing 53 arms this is the shortcut a reader is most likely to reach for; it is unavailable,
  and so is uniform substitution (TM⁺ is not substitution-closed via `atom_stab`).

- **The sixteen register arms** are the named `starValid_*` lemmas below, one per constructor,
  proved directly from the two clauses of `def:BLstar-semantics`. Ten of them are definitional
  (`Iff.rfl`, or one `Function.update` identity); the four rigidity arms use forward and backward
  seriality; the two export arms are a six-line `constructor`.

- **Most swap arms reuse a validity arm; the rest have named duals.** Where a schema's temporal
  dual *is* an instance of a constructor of this inductive — the ten `.iff` register schemata are
  self-dual, the rigidity arms pair G↔H, the export arms pair U↔S, and the mirror block supplies
  fifteen dual pairs — the swap arm normalises `swapTemporal` through the
  `StarFormula.swap_temporal_*` family and applies the matching validity lemma at swapped
  arguments. Eleven schemata have **no** dual constructor (`discrete_propagate_fwd`/`_bwd`,
  `discrete_box_necessity`, `dense_indicator`, `density`, `z1`, `sep`, `modal_future`, `paste`,
  `untl_paste`), exactly as at the L level, where `SoundnessLemmas/FrameClassVariants.lean`
  carries a `*_swap_valid` lemma for each; the corresponding `starValid_*_swap` lemmas below
  supply those duals. That is the swap-closure invariant of `StarLanguage/Axioms.lean`,
  discharged.

## References

* `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` — the TM⁺ dispatch pair being
  transported, and the dispatch shape being mirrored
* `FormalSystem/StarLanguage/Axioms.lean` — `StarAxiom` and its swap-closure invariant
* JPL paper `possible_worlds.tex` — `def:BLstar-semantics`

## Tags

soundness · star-language · axiom-validity · store-recall
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## Two shape adapters

The `.iff` clause lemma for `StarTruthAt`, and the `StarValid`-at-an-`.iff` introduction rule
every register arm below is stated through. They live here rather than in
`Semantics/StarLanguage/StarTruth.lean` because every consumer is in this directory. -/

/-- The `.iff` clause lemma, in the shape of the `StarTruth.*_iff` family. -/
theorem starTruth_iff_iff {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F)
    (t : F.Duration) (v : ℕ → F.Duration) (φ ψ : StarFormula) :
    StarTruthAt M τ t v (φ.iff ψ) ↔ (StarTruthAt M τ t v φ ↔ StarTruthAt M τ t v ψ) := by
  simp only [StarFormula.iff, StarTruth.and_iff, StarTruth.imp_iff]
  exact ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.1, h.2⟩⟩

/-- Introduce `StarValid (φ.iff ψ)` from a pointwise biconditional. -/
theorem starValid_iff_of_forall {φ ψ : StarFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : PartialHistory F), τ.IsTotal →
           ∀ (x : F.Duration) (v : ℕ → F.Duration),
             (StarTruthAt M τ x v φ ↔ StarTruthAt M τ x v ψ)) :
    StarValid (φ.iff ψ) :=
  StarValid.of_forall_total fun F M τ hτ x v =>
    (starTruth_iff_iff M τ x v φ ψ).mpr (h F M τ hτ x v)

/-! ## The sixteen register schemata

Each is valid over **every** task frame, hence stated as `StarValid`. -/

/-- S1: `↑ⁱ↓ⁱφ ↔ ↑ⁱφ` — register `i` of `v⃗[i ↦ x]` is `x`. -/
theorem starValid_store_recall_same (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.timeRecall i φ)).iff (.timeStore i φ)) := by
  refine starValid_iff_of_forall fun F M τ _ x v => ?_
  rw [StarTruth.timeStore_iff, StarTruth.timeRecall_iff, Function.update_self,
    StarTruth.timeStore_iff]

/-- S2: `↓ⁱ↑ⁱφ ↔ ↓ⁱφ` — writing `v⃗ᵢ` into register `i` writes back what was there. -/
theorem starValid_recall_store_same (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (.timeStore i φ)).iff (.timeRecall i φ)) := by
  refine starValid_iff_of_forall fun F M τ _ x v => ?_
  rw [StarTruth.timeRecall_iff, StarTruth.timeStore_iff, Function.update_eq_self,
    StarTruth.timeRecall_iff]

/-- S3: `↓ⁱ↓ʲφ ↔ ↓ʲφ` — the inner recall overrides the outer one. -/
theorem starValid_recall_recall (i j : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (.timeRecall j φ)).iff (.timeRecall j φ)) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S4: `↑ⁱ↑ʲφ ↔ ↑ʲ↑ⁱφ` — both stores write the same time, so the updates commute. -/
theorem starValid_store_store_comm (i j : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.timeStore j φ)).iff
      (StarFormula.timeStore j (.timeStore i φ))) := by
  refine starValid_iff_of_forall fun F M τ _ x v => ?_
  simp only [StarTruth.timeStore_iff]
  by_cases hij : i = j
  · subst hij; rfl
  · rw [Function.update_comm hij x x v]

/-- S5: `↑ⁱ(φ → ψ) ↔ (↑ⁱφ → ↑ⁱψ)` — `↑ⁱ` is functional. -/
theorem starValid_store_k (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.timeStore i (φ.imp ψ)).iff
      ((StarFormula.timeStore i φ).imp (.timeStore i ψ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S5, recall half: `↓ⁱ(φ → ψ) ↔ (↓ⁱφ → ↓ⁱψ)`. -/
theorem starValid_recall_k (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (φ.imp ψ)).iff
      ((StarFormula.timeRecall i φ).imp (.timeRecall i ψ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S6: `↑ⁱ□φ ↔ □↑ⁱφ` — `□` moves the history, never the time or the vector. -/
theorem starValid_store_box (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.box φ)).iff (StarFormula.box (.timeStore i φ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S6, recall half: `↓ⁱ□φ ↔ □↓ⁱφ`. -/
theorem starValid_recall_box (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (.box φ)).iff (StarFormula.box (.timeRecall i φ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S7: `↑ⁱ⊡φ ↔ ⊡↑ⁱφ` — `⊡`'s same-state condition is taken at the time `↑ⁱ` writes. The recall
analogue `↓ⁱ⊡φ ↔ ⊡↓ⁱφ` is **refuted** and is deliberately not among the schemata. -/
theorem starValid_store_stab (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.stab φ)).iff (StarFormula.stab (.timeStore i φ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S9: `↑ⁱp ↔ p` for atoms — the atom clause does not read the register vector. -/
theorem starValid_store_atom (i : ℕ) (p : Atom) :
    StarValid ((StarFormula.timeStore i (.atom p)).iff (StarFormula.atom p)) :=
  starValid_iff_of_forall fun _ _ _ _ _ _ => Iff.rfl

/-- S8: `↓ⁱφ → G↓ⁱφ` — a recall's truth does not read the time of evaluation. -/
theorem starValid_recall_rigid_future (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i φ).imp
      (StarFormula.allFuture (.timeRecall i φ))) := by
  refine StarValid.of_forall_total fun F M τ _ x v h => ?_
  rw [StarTruth.allFuture_iff]
  intro s _
  exact h

/-- S8, converse: `G↓ⁱφ → ↓ⁱφ`, by forward seriality (`exists_gt`). -/
theorem starValid_future_rigid_recall (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.allFuture (.timeRecall i φ)).imp
      (StarFormula.timeRecall i φ)) := by
  refine StarValid.of_forall_total fun F M τ _ x v h => ?_
  rw [StarTruth.allFuture_iff] at h
  obtain ⟨y, hy⟩ := exists_gt x
  exact h y hy

/-- S8, past half: `↓ⁱφ → H↓ⁱφ`. -/
theorem starValid_recall_rigid_past (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i φ).imp
      (StarFormula.allPast (.timeRecall i φ))) := by
  refine StarValid.of_forall_total fun F M τ _ x v h => ?_
  rw [StarTruth.allPast_iff]
  intro s _
  exact h

/-- S8, past converse: `H↓ⁱφ → ↓ⁱφ`, by backward seriality (`exists_lt`). -/
theorem starValid_past_rigid_recall (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.allPast (.timeRecall i φ)).imp
      (StarFormula.timeRecall i φ)) := by
  refine StarValid.of_forall_total fun F M τ _ x v h => ?_
  rw [StarTruth.allPast_iff] at h
  obtain ⟨y, hy⟩ := exists_lt x
  exact h y hy

/-- S10: `ψ U ↓ⁱφ ↔ (↓ⁱφ ∧ (ψ U ⊤))` — a rigid event contributes nothing to the `until` beyond
the existence of the interval. -/
theorem starValid_recall_export_until (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl ψ (.timeRecall i φ)).iff
      ((StarFormula.timeRecall i φ).and (StarFormula.untl ψ StarFormula.top))) := by
  refine starValid_iff_of_forall fun F M τ _ x v => ?_
  rw [StarTruth.and_iff]
  simp only [StarTruth.untl_iff, StarTruth.timeRecall_iff]
  constructor
  · rintro ⟨s, hs, hev, hg⟩
    exact ⟨hev, s, hs, StarTruth.top_true M τ s v, hg⟩
  · rintro ⟨hrec, s, hs, _, hg⟩
    exact ⟨s, hs, hrec, hg⟩

/-- S10, past mirror: `ψ S ↓ⁱφ ↔ (↓ⁱφ ∧ (ψ S ⊤))`. -/
theorem starValid_recall_export_since (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce ψ (.timeRecall i φ)).iff
      ((StarFormula.timeRecall i φ).and (StarFormula.snce ψ StarFormula.top))) := by
  refine starValid_iff_of_forall fun F M τ _ x v => ?_
  rw [StarTruth.and_iff]
  simp only [StarTruth.snce_iff, StarTruth.timeRecall_iff]
  constructor
  · rintro ⟨s, hs, hev, hg⟩
    exact ⟨hev, s, hs, StarTruth.top_true M τ s v, hg⟩
  · rintro ⟨hrec, s, hs, _, hg⟩
    exact ⟨s, hs, hrec, hg⟩

/-! ## The TM⁺ mirror block — Layer 1 (propositional), Layer 2 (S5 modal), and the `⊡` S5 block

Each of these is the schema of the correspondingly named `StarAxiom` constructor, proved
**directly against `StarTruthAt`** at arbitrary `StarFormula` metavariables — not transported
from `PlusAxiom`, which reaches only `ofPlus` instances.

**No L⋆ atomization, and no uniform substitution.** Both routes are prohibited here and
throughout this file: the first does not exist (`stab_state_only` has no L⋆ analogue, see the
module docstring), and the second is unsound over TM⁺, which `atom_stab` already makes
non-substitution-closed. Every arm below is a fresh direct proof. -/

/-- Propositional K over L⋆. Mirror of `PlusAxiom.prop_k`'s validity. -/
theorem starValid_prop_k (φ ψ χ : StarFormula) :
    StarValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h1 h2 h3 => h1 h3 (h2 h3)

/-- Propositional S (weakening) over L⋆. -/
theorem starValid_prop_s (φ ψ : StarFormula) : StarValid (φ.imp (ψ.imp φ)) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h _ => h

/-- Ex Falso Quodlibet over L⋆. -/
theorem starValid_ex_falso (φ : StarFormula) : StarValid (StarFormula.bot.imp φ) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h => h.elim

/-- Peirce's Law over L⋆, by classical case analysis on `φ`. -/
theorem starValid_peirce (φ ψ : StarFormula) : StarValid (((φ.imp ψ).imp φ).imp φ) := by
  refine StarValid.of_forall_total fun F M τ _ x v h => ?_
  by_cases hφ : StarTruthAt M τ x v φ
  · exact hφ
  · exact h fun hp => absurd hp hφ

/-- Modal T over L⋆: the evaluation history is itself total, so `□` reflects. -/
theorem starValid_modal_t (φ : StarFormula) : StarValid ((StarFormula.box φ).imp φ) :=
  StarValid.of_forall_total fun _ _ τ hτ _ _ h => h τ hτ

/-- Modal 4 over L⋆: the `box` clause quantifies over all total histories, so it is idempotent. -/
theorem starValid_modal_4 (φ : StarFormula) :
    StarValid ((StarFormula.box φ).imp (StarFormula.box (StarFormula.box φ))) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h _ _ => h

/-- Modal B over L⋆. -/
theorem starValid_modal_b (φ : StarFormula) :
    StarValid (φ.imp (StarFormula.box φ.diamond)) := by
  refine StarValid.of_forall_total fun F M τ hτ x v h => ?_
  intro σ _
  rw [StarTruth.diamond_iff]
  exact ⟨τ, hτ, h⟩

/-- Modal 5 Collapse over L⋆. -/
theorem starValid_modal_5_collapse (φ : StarFormula) :
    StarValid (φ.box.diamond.imp φ.box) := by
  refine StarValid.of_forall_total fun F M τ _ x v h => ?_
  rw [StarTruth.diamond_iff] at h
  obtain ⟨σ, hσ, hb⟩ := h
  exact hb

/-- Modal K distribution over L⋆. -/
theorem starValid_modal_k_dist (φ ψ : StarFormula) :
    StarValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h1 h2 σ hσ => h1 σ hσ (h2 σ hσ)

/-- SK over L⋆: K for `⊡`, from the universal-quantifier shape of the `stab` clause. -/
theorem starValid_stab_k (φ ψ : StarFormula) :
    StarValid ((StarFormula.stab (φ.imp ψ)).imp
      ((StarFormula.stab φ).imp (StarFormula.stab ψ))) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h1 h2 σ hσ hs => h1 σ hσ hs (h2 σ hσ hs)

/-- ST over L⋆: `SameStateAt` is reflexive. -/
theorem starValid_stab_t (φ : StarFormula) : StarValid ((StarFormula.stab φ).imp φ) :=
  StarValid.of_forall_total fun _ _ τ hτ _ _ h => h τ hτ (SameStateAt.refl τ _)

/-- S4 for `⊡` over L⋆: `SameStateAt` at a fixed time is transitive. -/
theorem starValid_stab_4 (φ : StarFormula) :
    StarValid ((StarFormula.stab φ).imp (StarFormula.stab (StarFormula.stab φ))) := by
  refine StarValid.of_forall_total fun F M τ hτ x v h => ?_
  intro σ hσ hσsame ρ hρ hρsame
  exact h ρ hρ (fun hτ' hρ' => by rw [hσsame hτ' (hσ x), hρsame (hσ x) hρ'])

/-- S5 for `⊡` over L⋆: `SameStateAt` at a fixed time is symmetric. -/
theorem starValid_stab_5 (φ : StarFormula) :
    StarValid ((StarFormula.dstab φ).imp (StarFormula.stab (StarFormula.dstab φ))) := by
  refine StarValid.of_forall_total fun F M τ hτ x v h => ?_
  intro σ hσ hσsame
  rw [StarTruth.dstab_iff] at h ⊢
  obtain ⟨ρ, hρ, hρsame, hφ⟩ := h
  exact ⟨ρ, hρ, fun hσ' hρ' => by rw [← hσsame (hτ x) hσ', ← hρsame (hτ x) hρ'], hφ⟩

/-- MS over L⋆: `⟨τ⟩_x ⊆ H_F`, so `□` is stronger than `⊡` — **at every `φ : StarFormula`**,
registers included. This is the schematic fact that makes `stabNecessitation`
(`StarLanguage/Derivation.lean`) unrestricted. -/
theorem starValid_box_stab (φ : StarFormula) :
    StarValid ((StarFormula.box φ).imp (StarFormula.stab φ)) :=
  StarValid.of_forall_total fun _ _ _ _ _ _ h σ hσ _ => h σ hσ

/-- AS over L⋆: the atom clause reads the world state alone, which `SameStateAt` fixes. -/
theorem starValid_atom_stab (p : Atom) :
    StarValid ((StarFormula.atom p).imp (StarFormula.stab (StarFormula.atom p))) := by
  refine StarValid.of_forall_total fun F M τ hτ x v h => ?_
  intro σ hσ hsame
  rw [StarTruth.atom_iff] at h ⊢
  obtain ⟨ht, hval⟩ := h
  exact ⟨hσ x, by rw [← hsame ht (hσ x)]; exact hval⟩

/-! ## The TM⁺ mirror block — seriality, monotonicity, connection

Transcriptions of the corresponding L-level proofs (`Metalogic/Soundness.lean`) under the
substitution `TruthAt M τ t ↦ StarTruthAt M τ t v`, `Truth.*_iff ↦ StarTruth.*_iff`. The two
seriality schemata are closed formulas, hence literally `ofPlus` images, and transport. -/

/-- Serial future over L⋆. The formula is closed, so it *is* an `ofPlus` image and the L⁺
validity transports along `starValidOnFrames_ofPlus`. -/
theorem starValid_serial_future :
    StarValid ((StarFormula.bot.imp StarFormula.bot).imp
      (StarFormula.someFuture (StarFormula.bot.imp StarFormula.bot))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.serial_future)

/-- Serial past over L⋆, likewise by transport. -/
theorem starValid_serial_past :
    StarValid ((StarFormula.bot.imp StarFormula.bot).imp
      (StarFormula.somePast (StarFormula.bot.imp StarFormula.bot))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.serial_past)

/-- BX2G over L⋆: the guard of an `until` may be weakened under `G`. -/
theorem starValid_left_mono_until_G (φ χ ψ : StarFormula) :
    StarValid ((φ.imp χ).allFuture.imp
      ((StarFormula.untl φ ψ).imp (StarFormula.untl χ ψ))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allFuture_iff, StarTruth.untl_iff]
  rintro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_event, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩

/-- BX2H over L⋆, the past mirror of `starValid_left_mono_until_G`. -/
theorem starValid_left_mono_since_H (φ χ ψ : StarFormula) :
    StarValid ((φ.imp χ).allPast.imp
      ((StarFormula.snce φ ψ).imp (StarFormula.snce χ ψ))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allPast_iff, StarTruth.snce_iff]
  rintro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_event, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩

/-- BX3 over L⋆: the event of an `until` may be weakened under `G`. -/
theorem starValid_right_mono_until (φ ψ χ : StarFormula) :
    StarValid ((φ.imp ψ).allFuture.imp
      ((StarFormula.untl χ φ).imp (StarFormula.untl χ ψ))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allFuture_iff, StarTruth.untl_iff]
  rintro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_G s hts h_event, h_guard⟩

/-- BX3' over L⋆, the past mirror of `starValid_right_mono_until`. -/
theorem starValid_right_mono_since (φ ψ χ : StarFormula) :
    StarValid ((φ.imp ψ).allPast.imp
      ((StarFormula.snce χ φ).imp (StarFormula.snce χ ψ))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allPast_iff, StarTruth.snce_iff]
  rintro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_H s hst h_event, h_guard⟩

/-- BX4 over L⋆: what is true now is always going to have been true. -/
theorem starValid_connect_future (φ : StarFormula) :
    StarValid (φ.imp (φ.somePast.allFuture)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allFuture_iff, StarTruth.somePast_iff]
  intro h s hts
  exact ⟨t, hts, h⟩

/-- BX4' over L⋆, the past mirror of `starValid_connect_future`. -/
theorem starValid_connect_past (φ : StarFormula) :
    StarValid (φ.imp (φ.someFuture.allPast)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allPast_iff, StarTruth.someFuture_iff]
  intro h s hst
  exact ⟨t, hst, h⟩

/-! ## The TM⁺ mirror block — enrichment, self-accumulation, absorption, linearity

The heaviest of the BX block. Each is `simp only` over the `StarTruth.*_iff` clause family
followed by `rintro` and, where the argument needs to compare two witnesses,
`rcases lt_trichotomy`. There is **no** `star_truth_norm` simp set on the L⋆ side, so the clause
lemmas are spelled out. As throughout: no atomization, no uniform substitution. -/

/-- BX13 over L⋆. -/
theorem starValid_enrichment_until (φ ψ p : StarFormula) :
    StarValid (StarFormula.and p (StarFormula.untl φ ψ) |>.imp
      (StarFormula.untl φ (StarFormula.and ψ (StarFormula.snce φ p)))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.untl_iff, StarTruth.snce_iff]
  rintro ⟨h_pt, s, hts, h_ψs, h_guard⟩
  exact ⟨s, hts, ⟨h_ψs, t, hts, h_pt, h_guard⟩, h_guard⟩

/-- BX13' over L⋆, the past mirror of `starValid_enrichment_until`. -/
theorem starValid_enrichment_since (φ ψ p : StarFormula) :
    StarValid (StarFormula.and p (StarFormula.snce φ ψ) |>.imp
      (StarFormula.snce φ (StarFormula.and ψ (StarFormula.untl φ p)))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.untl_iff, StarTruth.snce_iff]
  rintro ⟨h_pt, s, hst, h_ψs, h_guard⟩
  exact ⟨s, hst, ⟨h_ψs, t, hst, h_pt, h_guard⟩, h_guard⟩

/-- BX5 over L⋆. -/
theorem starValid_self_accum_until (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl φ ψ).imp
      (StarFormula.untl (StarFormula.and φ (StarFormula.untl φ ψ)) ψ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.untl_iff]
  rintro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs => ⟨h_guard r htr hrs, ?_⟩⟩
  exact ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX5' over L⋆, the past mirror of `starValid_self_accum_until`. -/
theorem starValid_self_accum_since (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce φ ψ).imp
      (StarFormula.snce (StarFormula.and φ (StarFormula.snce φ ψ)) ψ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.snce_iff]
  rintro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt => ⟨h_guard r hsr hrt, ?_⟩⟩
  exact ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

/-- BX6 over L⋆. -/
theorem starValid_absorb_until (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl φ (StarFormula.and φ (StarFormula.untl φ ψ))).imp
      (StarFormula.untl φ ψ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.untl_iff]
  rintro ⟨s₁, hts₁, ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₁ q htq h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q h_gt hqs₂

/-- BX6' over L⋆, the past mirror of `starValid_absorb_until`. -/
theorem starValid_absorb_since (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce φ (StarFormula.and φ (StarFormula.snce φ ψ))).imp
      (StarFormula.snce φ ψ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.snce_iff]
  rintro ⟨s₁, hs₁t, ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
  rcases lt_trichotomy s₁ q with h_lt | h_eq | h_gt
  · exact h_guard₁ q h_lt hqt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q hs₂q h_gt

/-- BX7 over L⋆: linearity of `until`, by trichotomy on the two witnesses. -/
theorem starValid_linear_until (φ ψ χ θ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.untl φ ψ) (StarFormula.untl χ θ)
      |>.imp (StarFormula.or
        (StarFormula.or
          (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and ψ θ))
          (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and ψ χ)))
        (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and φ θ)))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.or_iff, StarTruth.untl_iff]
  rintro ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · exact .inl (.inr ⟨s₁, hts₁, ⟨h_ψs₁, h_guard₂ s₁ hts₁ h_lt⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (lt_trans hrs h_lt)⟩⟩)
  · exact .inl (.inl ⟨s₁, hts₁, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (h_eq ▸ hrs)⟩⟩)
  · exact .inr ⟨s₂, hts₂, ⟨h_guard₁ s₂ hts₂ h_gt, h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr (lt_trans hrs h_gt), h_guard₂ r htr hrs⟩⟩

/-- BX7' over L⋆, the past mirror of `starValid_linear_until`. -/
theorem starValid_linear_since (φ ψ χ θ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.snce φ ψ) (StarFormula.snce χ θ)
      |>.imp (StarFormula.or
        (StarFormula.or
          (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and ψ θ))
          (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and ψ χ)))
        (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and φ θ)))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.or_iff, StarTruth.snce_iff]
  rintro ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₂ s₁ with h_lt | h_eq | h_gt
  · exact .inl (.inr ⟨s₁, hs₁t, ⟨h_ψs₁, h_guard₂ s₁ h_lt hs₁t⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (lt_trans h_lt hs₁r) hrt⟩⟩)
  · exact .inl (.inl ⟨s₁, hs₁t, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (h_eq ▸ hs₁r) hrt⟩⟩)
  · exact .inr ⟨s₂, hs₂t, ⟨h_guard₁ s₂ h_gt hs₂t, h_θs₂⟩,
      fun r hs₂r hrt => ⟨h_guard₁ r (lt_trans h_gt hs₂r) hrt, h_guard₂ r hs₂r hrt⟩⟩

/-! ## The TM⁺ mirror block — `until_F`/`since_P`, temporal linearity, the two equivalences -/

/-- BX10 over L⋆: an `until` witness is a future witness. -/
theorem starValid_until_F (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl φ ψ).imp (StarFormula.someFuture ψ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.untl_iff, StarTruth.someFuture_iff]
  rintro ⟨s, hts, h_ψs, _⟩
  exact ⟨s, hts, h_ψs⟩

/-- BX10' over L⋆, the past mirror of `starValid_until_F`. -/
theorem starValid_since_P (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce φ ψ).imp (StarFormula.somePast ψ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.snce_iff, StarTruth.somePast_iff]
  rintro ⟨s, hst, h_ψs, _⟩
  exact ⟨s, hst, h_ψs⟩

/-- BX11 over L⋆: two future witnesses are ordered, by trichotomy. -/
theorem starValid_temp_linearity (φ ψ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.someFuture φ) (StarFormula.someFuture ψ) |>.imp
      (StarFormula.or (StarFormula.someFuture (StarFormula.and φ ψ))
        (StarFormula.or (StarFormula.someFuture (StarFormula.and φ (StarFormula.someFuture ψ)))
          (StarFormula.someFuture (StarFormula.and (StarFormula.someFuture φ) ψ))))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.or_iff, StarTruth.someFuture_iff]
  rintro ⟨⟨s₁, hs₁t, hφ⟩, s₂, hs₂t, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inl ⟨s₁, hs₁t, hφ, s₂, h, hψ⟩)
  · exact .inl ⟨s₁, hs₁t, hφ, h ▸ hψ⟩
  · exact .inr (.inr ⟨s₂, hs₂t, ⟨s₁, h, hφ⟩, hψ⟩)

/-- BX11' over L⋆, the past mirror of `starValid_temp_linearity`. -/
theorem starValid_temp_linearity_past (φ ψ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.somePast φ) (StarFormula.somePast ψ) |>.imp
      (StarFormula.or (StarFormula.somePast (StarFormula.and φ ψ))
        (StarFormula.or (StarFormula.somePast (StarFormula.and φ (StarFormula.somePast ψ)))
          (StarFormula.somePast (StarFormula.and (StarFormula.somePast φ) ψ))))) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.and_iff, StarTruth.or_iff, StarTruth.somePast_iff]
  rintro ⟨⟨s₁, hs₁t, hφ⟩, s₂, hs₂t, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inr ⟨s₂, hs₂t, ⟨s₁, h, hφ⟩, hψ⟩)
  · exact .inl ⟨s₁, hs₁t, hφ, h ▸ hψ⟩
  · exact .inr (.inl ⟨s₁, hs₁t, hφ, s₂, h, hψ⟩)

/-- BX12 over L⋆: `F` is `U` at the trivial guard. -/
theorem starValid_F_until_equiv (φ : StarFormula) :
    StarValid ((StarFormula.someFuture φ).imp
      (StarFormula.untl (StarFormula.bot.imp StarFormula.bot) φ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.someFuture_iff, StarTruth.untl_iff]
  rintro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ => id⟩

/-- BX12' over L⋆, the past mirror of `starValid_F_until_equiv`. -/
theorem starValid_P_since_equiv (φ : StarFormula) :
    StarValid ((StarFormula.somePast φ).imp
      (StarFormula.snce (StarFormula.bot.imp StarFormula.bot) φ)) := by
  refine StarValid.of_forall_total fun F M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.somePast_iff, StarTruth.snce_iff]
  rintro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ => id⟩

/-! ## The TM⁺ mirror block — discrete uniformity, density, Prior, Z1

The five uniformity schemata are **closed** formulas, hence literally `ofPlus` images: their
validity and their swap-validity both transport along `starValidOnFrames_ofPlus` from
`plusAxiom_validIn_min` / `plusAxiom_swap_validIn_min`, with no L⋆ argument at all.

`density`, `z1`, `prior_UZ` and `prior_SZ` carry a metavariable and are proved directly. The
order-theoretic content is **not** inlined: `prior_UZ`/`prior_SZ` consume
`SoundnessLemmas.DiscreteOrder`'s `exists_nearest_gt`/`exists_nearest_lt` and `z1` its
`forall_gt_of_succ_step`/`forall_lt_of_pred_step`, each at
`P := fun x => StarTruthAt M τ x v φ`.

**Measured correction to this group's swap-closure.** Three of the five uniformity schemata are
*not* closed under `swapTemporal` within the group — `swapTemporal` exchanges `untl` and `snce`,
so the dual of `U(⊤,⊥) → G(U(⊤,⊥))` is `S(⊤,⊥) → H(S(⊤,⊥))`, which is no member's statement —
and neither `density`, `dense_indicator` nor `z1` has a past twin among the schemata. This
mirrors the L level exactly, where `SoundnessLemmas.FrameClassVariants` carries a dedicated
`*_swap_valid` lemma for each. The named `*_swap` lemmas below are those duals; the closed ones
transport, `density` and `z1` are direct. -/

/-- `discrete_symm_fwd` over L⋆, by transport: the formula is closed. -/
theorem starValid_discrete_symm_fwd :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.discrete_symm_fwd)

/-- `discrete_symm_bwd` over L⋆, by transport. -/
theorem starValid_discrete_symm_bwd :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.discrete_symm_bwd)

/-- `discrete_propagate_fwd` over L⋆, by transport. -/
theorem starValid_discrete_propagate_fwd :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.allFuture (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.discrete_propagate_fwd)

/-- The temporal dual of `discrete_propagate_fwd`: `S(⊤,⊥) → H(S(⊤,⊥))`. Not an instance of any
schema, so it is named here, mirroring `SoundnessLemmas.discrete_propagate_fwd_swap_valid`. -/
theorem starValid_discrete_propagate_fwd_swap :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.allPast (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  (starValidOnFrames_ofPlus _ _).mpr
    (plusAxiom_swap_validIn_min PlusAxiom.discrete_propagate_fwd)

/-- `discrete_propagate_bwd` over L⋆, by transport. -/
theorem starValid_discrete_propagate_bwd :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.allPast (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.discrete_propagate_bwd)

/-- The temporal dual of `discrete_propagate_bwd`: `S(⊤,⊥) → G(S(⊤,⊥))`. -/
theorem starValid_discrete_propagate_bwd_swap :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.allFuture (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  (starValidOnFrames_ofPlus _ _).mpr
    (plusAxiom_swap_validIn_min PlusAxiom.discrete_propagate_bwd)

/-- `discrete_box_necessity` over L⋆, by transport. -/
theorem starValid_discrete_box_necessity :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.box (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.discrete_box_necessity)

/-- The temporal dual of `discrete_box_necessity`: `S(⊤,⊥) → □(S(⊤,⊥))`. -/
theorem starValid_discrete_box_necessity_swap :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp (StarFormula.box (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  (starValidOnFrames_ofPlus _ _).mpr
    (plusAxiom_swap_validIn_min PlusAxiom.discrete_box_necessity)

/-- Density over L⋆ at `.Dense`: `GGφ → Gφ`. -/
theorem starValid_density (φ : StarFormula) :
    StarValidIn FrameClass.Dense ((φ.allFuture.allFuture).imp φ.allFuture) := by
  refine StarValidIn.of_forall_total fun F h_dense M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allFuture_iff]
  intro h_GG s hts
  obtain ⟨r, htr, hrs⟩ := @DenselyOrdered.dense F.Duration _ h_dense t s hts
  exact h_GG r htr s hrs

/-- The temporal dual of `starValid_density`: `HHφ → Hφ`, again at `.Dense`. There is no
`density_past` schema, so this dual is named here rather than dispatched to a sibling
constructor — mirroring `Metalogic/Soundness.lean`'s `density_swap_valid`. -/
theorem starValid_density_swap (φ : StarFormula) :
    StarValidIn FrameClass.Dense ((φ.allPast.allPast).imp φ.allPast) := by
  refine StarValidIn.of_forall_total fun F h_dense M τ _ t v => ?_
  simp only [StarTruth.imp_iff, StarTruth.allPast_iff]
  intro h_HH s hst
  obtain ⟨r, hsr, hrt⟩ := @DenselyOrdered.dense F.Duration _ h_dense s t hst
  exact h_HH r hrt s hsr

/-- The dense indicator over L⋆ at `.Dense`, by transport. -/
theorem starValid_dense_indicator :
    StarValidIn FrameClass.Dense (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).neg :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_validIn_min PlusAxiom.dense_indicator)

/-- The temporal dual of the dense indicator: `¬S(⊤,⊥)`, by transport. -/
theorem starValid_dense_indicator_swap :
    StarValidIn FrameClass.Dense (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).neg :=
  (starValidOnFrames_ofPlus _ _).mpr (plusAxiom_swap_validIn_min PlusAxiom.dense_indicator)

/-- Prior-UZ over L⋆ at `.ZTime`: the nearest `φ`-point above `t` witnesses `U(φ, ¬φ)`. -/
theorem starValid_prior_UZ (φ : StarFormula) :
    StarValidIn FrameClass.ZTime (φ.someFuture.imp (StarFormula.untl φ.neg φ)) := by
  refine StarValidIn.of_forall_total fun F hF M τ _ t v => ?_
  sat_intro hF
  simp only [StarTruth.imp_iff, StarTruth.someFuture_iff, StarTruth.untl_iff, StarTruth.neg_iff]
  rintro ⟨s, hts, hs⟩
  exact Metalogic.SoundnessLemmas.exists_nearest_gt
    (P := fun x => StarTruthAt M τ x v φ) hts hs

/-- Prior-SZ over L⋆ at `.ZTime`, the past dual — through `exists_nearest_lt`, which is itself
`exists_nearest_gt` at `Dᵒᵈ`. The dualisation is of the *carrier*, never of the formula. -/
theorem starValid_prior_SZ (φ : StarFormula) :
    StarValidIn FrameClass.ZTime (φ.somePast.imp (StarFormula.snce φ.neg φ)) := by
  refine StarValidIn.of_forall_total fun F hF M τ _ t v => ?_
  sat_intro hF
  simp only [StarTruth.imp_iff, StarTruth.somePast_iff, StarTruth.snce_iff, StarTruth.neg_iff]
  rintro ⟨s, hst, hs⟩
  exact Metalogic.SoundnessLemmas.exists_nearest_lt
    (P := fun x => StarTruthAt M τ x v φ) hst hs

/-- Z1 over L⋆ at `.ZTime`, through `forall_gt_of_succ_step`. -/
theorem starValid_z1 (φ : StarFormula) :
    StarValidIn FrameClass.ZTime ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  refine StarValidIn.of_forall_total fun F hF M τ _ t v => ?_
  sat_intro hF
  simp only [StarTruth.imp_iff, StarTruth.allFuture_iff, StarTruth.someFuture_iff]
  rintro h_GGpIp ⟨s₀, hts₀, hs₀⟩
  exact Metalogic.SoundnessLemmas.forall_gt_of_succ_step
    (P := fun x => StarTruthAt M τ x v φ) h_GGpIp hts₀ hs₀

/-- The temporal dual of `starValid_z1`, through `forall_lt_of_pred_step`. Z1 has no past twin
among the schemata, so this dual is named here — mirroring
`SoundnessLemmas.z1_past_valid`. -/
theorem starValid_z1_swap (φ : StarFormula) :
    StarValidIn FrameClass.ZTime ((φ.allPast.imp φ).allPast.imp
      (φ.allPast.somePast.imp φ.allPast)) := by
  refine StarValidIn.of_forall_total fun F hF M τ _ t v => ?_
  sat_intro hF
  simp only [StarTruth.imp_iff, StarTruth.allPast_iff, StarTruth.somePast_iff]
  rintro h_HHpIp ⟨s₀, hs₀t, hs₀⟩
  exact Metalogic.SoundnessLemmas.forall_lt_of_pred_step
    (P := fun x => StarTruthAt M τ x v φ) h_HHpIp hs₀t hs₀

/-! ## Two `K±` clause lemmas, and the register-inertness of the `↓ⁱ`-free fragment

`starKPlus_iff` and `starKMinus_iff` unfold the two Reynolds gap operators into the shape the
Dedekind arms consume. They are declared here rather than in `Semantics/StarLanguage/StarTruth.lean` for the
same reason `starTruth_iff_iff` above is: every consumer is in this directory. Relocating the
whole `StarTruth.*_iff` family, together with a `star_truth_norm` simp set, is recorded as
deferred follow-up work, not done here.

`recallFree_vector_irrelevant` is the semantic content of `RecallFree`
(`StarLanguage/Formula.lean`) and the load-bearing input to the `modal_future` arm. It is
genuinely new rather than a transcription: no L⁺ statement mentions a register vector. -/

/-- `K⁺φ` at `t`: every point above `t` has a `φ`-point strictly between. -/
theorem starKPlus_iff {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (v : ℕ → F.Duration) (φ : StarFormula) :
    StarTruthAt M τ t v φ.kPlus ↔
      ∀ s : F.Duration, t < s → ∃ r : F.Duration, t < r ∧ r < s ∧ StarTruthAt M τ r v φ := by
  simp only [StarFormula.kPlus, StarFormula.neg, StarFormula.top, StarTruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-- `K⁻φ` at `t`: the past mirror of `starKPlus_iff`. -/
theorem starKMinus_iff {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (v : ℕ → F.Duration) (φ : StarFormula) :
    StarTruthAt M τ t v φ.kMinus ↔
      ∀ s : F.Duration, s < t → ∃ r : F.Duration, s < r ∧ r < t ∧ StarTruthAt M τ r v φ := by
  simp only [StarFormula.kMinus, StarFormula.neg, StarFormula.top, StarTruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-- **The stored-time vector is inert on `↓ⁱ`-free formulas.** The `timeStore` case recurses at
`Function.update v i t` on both sides, which is why the vector pair is quantified inside the
motive; `timeRecall` — the one case that would read the vector — is absent from `RecallFree` by
construction.

This is what makes `StarAxiom.modal_future` sound at every `RecallFree φ`: the L⋆ time-shift
lemma moves the vector along with the history, and on this fragment that movement is invisible. -/
theorem recallFree_vector_irrelevant {F : TaskFrame} (M : TaskModel F) {φ : StarFormula}
    (hφ : RecallFree φ) :
    ∀ (τ : PartialHistory F) (t : F.Duration) (v w : ℕ → F.Duration),
      StarTruthAt M τ t v φ ↔ StarTruthAt M τ t w φ := by
  induction hφ with
  | atom p => intros; exact Iff.rfl
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ => intro τ t v w; exact Iff.imp (ihφ τ t v w) (ihψ τ t v w)
  | box _ ih => intro τ t v w; exact forall_congr' fun ρ => imp_congr_right fun _ => ih ρ t v w
  | untl _ _ ihψ ihφ =>
    intro τ t v w
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s v w) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ihψ τ r v w)
  | snce _ _ ihψ ihφ =>
    intro τ t v w
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s v w) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ihψ τ r v w)
  | stab _ ih =>
    intro τ t v w
    exact forall_congr' fun ρ => imp_congr_right fun _ => imp_congr_right fun _ => ih ρ t v w
  | timeStore i _ ih =>
    intro τ t v w
    exact ih τ t (Function.update v i t) (Function.update w i t)

/-! ## The TM⁺ mirror block — Reynolds Dedekind, and `modal_future` under `RecallFree` -/

/-- Prior-U (gap form) over L⋆ at `.RTime`. The least upper bound of the set of times whose whole
open past back to `t` satisfies `φ` is the gap point. -/
theorem starValid_prior_U_gap (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      ((StarFormula.and (StarFormula.untl φ StarFormula.top) φ.neg.someFuture).imp
        (StarFormula.untl φ (StarFormula.or φ.neg (StarFormula.kPlus φ.neg)))) := by
  refine StarValidIn.of_forall_total fun F h_lub M τ _hτ t v h_ant => ?_
  sat_intro h_lub
  simp only [StarTruth.and_iff, StarTruth.untl_iff, StarTruth.someFuture_iff,
    StarTruth.neg_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  obtain ⟨s0, hts0, -, hp0⟩ := h1
  obtain ⟨w0, htw0, hnpw0⟩ := h2
  set A : Set F.Duration :=
    {u : F.Duration | t < u ∧ ∀ r : F.Duration, t < r → r < u → StarTruthAt M τ r v φ} with hA
  have hs0A : s0 ∈ A := ⟨hts0, hp0⟩
  have hAbdd : BddAbove A := by
    refine ⟨w0, ?_⟩
    intro u hu
    by_contra hvu
    exact hnpw0 (hu.2 w0 htw0 (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨s0, hs0A⟩ hAbdd
  have hts : t < s := lt_of_lt_of_le hts0 (hs.1 hs0A)
  have hguard : ∀ r : F.Duration, t < r → r < s → StarTruthAt M τ r v φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r htr hru
  simp only [StarTruth.untl_iff, StarTruth.or_iff, StarTruth.neg_iff, starKPlus_iff]
  refine ⟨s, hts, ?_, hguard⟩
  by_cases hps : StarTruthAt M τ s v φ
  · refine .inr fun w hsw => ?_
    by_contra hw
    push Not at hw
    have hwA : w ∈ A := by
      refine ⟨lt_trans hts hsw, ?_⟩
      intro r htr hrw
      rcases lt_trichotomy r s with h | h | h
      · exact hguard r htr h
      · exact h ▸ hps
      · exact hw r h hrw
    exact absurd (hs.1 hwA) (not_le_of_gt hsw)
  · exact .inl hps

/-- Prior-S (gap form) over L⋆ at `.RTime`, the past dual — through
`SoundnessLemmas.exists_isGLB_of_lub`, so the least-upper-bound hypothesis is used once and the
greatest lower bound is derived rather than assumed. -/
theorem starValid_prior_S_gap (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      ((StarFormula.and (StarFormula.snce φ StarFormula.top) φ.neg.somePast).imp
        (StarFormula.snce φ (StarFormula.or φ.neg (StarFormula.kMinus φ.neg)))) := by
  refine StarValidIn.of_forall_total fun F h_lub M τ _hτ t v h_ant => ?_
  sat_intro h_lub
  simp only [StarTruth.and_iff, StarTruth.snce_iff, StarTruth.somePast_iff,
    StarTruth.neg_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  obtain ⟨s0, hs0t, -, hp0⟩ := h1
  obtain ⟨w0, hw0t, hnpw0⟩ := h2
  set B : Set F.Duration :=
    {u : F.Duration | u < t ∧ ∀ r : F.Duration, u < r → r < t → StarTruthAt M τ r v φ} with hB
  have hs0B : s0 ∈ B := ⟨hs0t, hp0⟩
  have hBbdd : BddBelow B := by
    refine ⟨w0, ?_⟩
    intro u hu
    by_contra huw
    exact hnpw0 (hu.2 w0 (lt_of_not_ge huw) hw0t)
  obtain ⟨s, hs⟩ := Metalogic.SoundnessLemmas.exists_isGLB_of_lub h_lub ⟨s0, hs0B⟩ hBbdd
  have hst : s < t := lt_of_le_of_lt (hs.1 hs0B) hs0t
  have hguard : ∀ r : F.Duration, s < r → r < t → StarTruthAt M τ r v φ := by
    intro r hsr hrt
    obtain ⟨u, huB, -, hur⟩ := hs.exists_between hsr
    exact huB.2 r hur hrt
  simp only [StarTruth.snce_iff, StarTruth.or_iff, StarTruth.neg_iff, starKMinus_iff]
  refine ⟨s, hst, ?_, hguard⟩
  by_cases hps : StarTruthAt M τ s v φ
  · refine .inr fun w hws => ?_
    by_contra hw
    push Not at hw
    have hwB : w ∈ B := by
      refine ⟨lt_trans hws hst, ?_⟩
      intro r hwr hrt
      rcases lt_trichotomy r s with h | h | h
      · exact hw r hwr h
      · exact h ▸ hps
      · exact hguard r h hrt
    exact absurd (hs.1 hwB) (not_le_of_gt hws)
  · exact .inl hps

/-- **Sep over L⋆ at `.RTime`.** The order-theoretic core is
`SoundnessLemmas.sep_order`, consumed unchanged at `P := {u | StarTruthAt M τ u v φ}`; nothing
about `StarFormula` enters it. -/
theorem starValid_sep (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      ((StarFormula.and (StarFormula.kPlus φ)
        (StarFormula.kPlus (StarFormula.and φ (StarFormula.untl φ.neg φ))).neg).imp
        (StarFormula.kPlus (StarFormula.and (StarFormula.kPlus φ) (StarFormula.kMinus φ)))) := by
  refine StarValidIn.of_forall_total fun F h_lub M τ _hτ t vec h_ant => ?_
  sat_intro h_lub
  obtain ⟨Q, hQc, hQd⟩ := Metalogic.SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (StarTruth.and_iff _ _ _ _ _ _).mp h_ant
  simp only [StarTruthAt, StarFormula.and, StarFormula.neg, StarFormula.kPlus,
    StarFormula.kMinus, StarFormula.top] at h1 h2 ⊢
  rintro ⟨s₂, hts₂, -, hno⟩
  have hK : ∀ w, t < w → ∃ u, t < u ∧ u < w ∧ StarTruthAt M τ u vec φ := by
    intro w htw
    by_contra hc
    refine h1 ⟨w, htw, fun hb => hb, ?_⟩
    intro r htr hrw hrφ
    exact hc ⟨r, htr, hrw, hrφ⟩
  have h2' : ∃ s₁, t < s₁ ∧ (True) ∧ ∀ u, t < u → u < s₁ →
      (StarTruthAt M τ u vec φ → StarTruthAt M τ u vec (StarFormula.untl φ.neg φ) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hts₁, -, hu⟩ := hbad
      exact ⟨s₁, hts₁, trivial, fun u htu hus => Classical.byContradiction (hu u htu hus)⟩)
  obtain ⟨s₁, hts₁, -, hstart⟩ := h2'
  refine Metalogic.SoundnessLemmas.sep_order h_lub Q hQc hQd
    {u | StarTruthAt M τ u vec φ} t s₁ s₂ hts₁ hts₂ hK ?_ ?_
  · rintro u htu hus₁ huP ⟨w, huw, hwP, hfree⟩
    exact hstart u htu hus₁ huP ⟨w, huw, hwP, fun r hur hrw => hfree r hur hrw⟩
  · intro u htu hus₂
    have hAB : StarTruthAt M τ u vec (StarFormula.kPlus φ) →
        StarTruthAt M τ u vec (StarFormula.kMinus φ) → False := by
      intro ha hb
      exact hno u htu hus₂ (fun k => k ha hb)
    by_cases hR : ∃ w, u < w ∧ ∀ z, u < z → z < w → ¬ StarTruthAt M τ z vec φ
    · exact Or.inl hR
    · refine Or.inr ?_
      have ha : StarTruthAt M τ u vec (StarFormula.kPlus φ) := by
        rw [starKPlus_iff]
        intro s hus
        by_contra hc
        exact hR ⟨s, hus, fun z huz hzs hz => hc ⟨z, huz, hzs, hz⟩⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      rw [starKMinus_iff]
      intro s hsu
      by_contra hc
      exact hns ⟨s, hsu, fun z hsz hzu hz => hc ⟨z, hsz, hzu, hz⟩⟩

/-- **The temporal dual of Sep**, at `.RTime`. Sep has no past twin among the schemata, so the
dual is named here; the order-theoretic core is `SoundnessLemmas.sep_order_mirror`, which is
`sep_order` instantiated at `Dᵒᵈ`, so the nested-interval argument is written once. Mirrors
`Metalogic/Soundness.lean`'s `sep_swap_valid`. -/
theorem starValid_sep_swap (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      (((StarFormula.and (StarFormula.kPlus φ)
        (StarFormula.kPlus (StarFormula.and φ (StarFormula.untl φ.neg φ))).neg).imp
        (StarFormula.kPlus
          (StarFormula.and (StarFormula.kPlus φ) (StarFormula.kMinus φ)))).swapTemporal) := by
  refine StarValidIn.of_forall_total fun F h_lub M τ _hτ t vec h_ant => ?_
  sat_intro h_lub
  obtain ⟨Q, hQc, hQd⟩ := Metalogic.SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (StarTruth.and_iff _ _ _ _ _ _).mp h_ant
  simp only [StarFormula.and, StarFormula.neg, StarFormula.kPlus, StarFormula.kMinus,
    StarFormula.top, StarFormula.swapTemporal, StarTruthAt] at h1 h2 ⊢
  rintro ⟨s₂, hs₂t, -, hno⟩
  have hK : ∀ w, w < t → ∃ u, w < u ∧ u < t ∧ StarTruthAt M τ u vec φ.swapTemporal := by
    intro w hwt
    by_contra hc
    refine h1 ⟨w, hwt, fun hb => hb, ?_⟩
    intro r hwr hrt hrφ
    exact hc ⟨r, hwr, hrt, hrφ⟩
  have h2' : ∃ s₁, s₁ < t ∧ (True) ∧ ∀ u, u < t → s₁ < u →
      (StarTruthAt M τ u vec φ.swapTemporal →
        StarTruthAt M τ u vec (StarFormula.snce φ.swapTemporal.neg φ.swapTemporal) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hs₁t, -, hu⟩ := hbad
      exact ⟨s₁, hs₁t, trivial, fun u hut hs₁u => Classical.byContradiction (hu u hs₁u hut)⟩)
  obtain ⟨s₁, hs₁t, -, hstart⟩ := h2'
  refine Metalogic.SoundnessLemmas.sep_order_mirror h_lub Q hQc hQd
    {u | StarTruthAt M τ u vec φ.swapTemporal} t s₁ s₂ hs₁t hs₂t hK ?_ ?_
  · rintro u hut hs₁u huP ⟨w, hwu, hwP, hfree⟩
    exact hstart u hut hs₁u huP ⟨w, hwu, hwP, fun r hwr hru => hfree r hwr hru⟩
  · intro u hut hs₂u
    have hAB : StarTruthAt M τ u vec (StarFormula.kMinus φ.swapTemporal) →
        StarTruthAt M τ u vec (StarFormula.kPlus φ.swapTemporal) → False := by
      intro ha hb
      exact hno u hs₂u hut (fun k => k ha hb)
    by_cases hL : ∃ w, w < u ∧ ∀ z, w < z → z < u → ¬ StarTruthAt M τ z vec φ.swapTemporal
    · exact Or.inl hL
    · refine Or.inr ?_
      have ha : StarTruthAt M τ u vec (StarFormula.kMinus φ.swapTemporal) := by
        rw [starKMinus_iff]
        intro s hsu
        by_contra hc
        exact hL ⟨s, hsu, fun z hsz hzu hz => hc ⟨z, hsz, hzu, hz⟩⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      rw [starKPlus_iff]
      intro s hus
      by_contra hc
      exact hns ⟨s, hus, fun z huz hzs hz => hc ⟨z, huz, hzs, hz⟩⟩

/-- **MF at every `↓ⁱ`-free `StarFormula`** — strictly wider than the register-free (`ofPlus`)
instances. The argument is the L-level one, `starTruthAt_timeShift` supplying homogeneity, with
`recallFree_vector_irrelevant` absorbing the vector the L⋆ shift drags along. -/
theorem starValid_modal_future {φ : StarFormula} (hφ : RecallFree φ) :
    StarValid ((StarFormula.box φ).imp (StarFormula.box (StarFormula.allFuture φ))) := by
  refine StarValid.of_forall_total fun F M τ _hτ t v h => ?_
  intro σ hσ
  rw [StarTruth.allFuture_iff]
  intro s hts
  have h1 := h (σ.timeShift (s - t)) (timeShift_isTotal' σ hσ (s - t))
  have h2 := (starTruthAt_timeShift M φ σ t (s - t) v).mp h1
  rw [add_sub_cancel] at h2
  exact (recallFree_vector_irrelevant M hφ σ s _ v).mp h2

/-- MF's temporal dual, at every `↓ⁱ`-free `StarFormula`: `□φ → □(Hφ)`. No `modal_past` schema
exists, so this dual is named here. `RecallFree.swapTemporal` carries the side condition across.
-/
theorem starValid_modal_future_swap {φ : StarFormula} (hφ : RecallFree φ) :
    StarValid (((StarFormula.box φ).imp
      (StarFormula.box (StarFormula.allFuture φ))).swapTemporal) := by
  simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
  refine StarValid.of_forall_total fun F M τ _hτ t v h => ?_
  intro σ hσ
  rw [StarTruth.allPast_iff]
  intro s hst
  have h1 := h (σ.timeShift (s - t)) (timeShift_isTotal' σ hσ (s - t))
  have h2 := (starTruthAt_timeShift M φ.swapTemporal σ t (s - t) v).mp h1
  rw [add_sub_cancel] at h2
  exact (recallFree_vector_irrelevant M hφ.swapTemporal σ s _ v).mp h2

/-! ## The TM⁺ mirror block — the two pasting schemata

The semantic content is `Conservativity/Star/StarPasting.lean`'s: the two purity congruences and
the four pasting validities, over the L⋆ purity predicates. Nothing is re-proved here; these four
lemmas are the `StarValid` packagings the dispatch consumes.

**Measured correction to this group's swap-closure.** PS and US are not each other's duals.
`swapTemporal` fixes `⟐` and exchanges `untl`/`snce`, so the dual of PS is PS with the conjuncts
exchanged (PS'), and the dual of US is SS — exactly as at the L⁺ level, where
`Semantics/PlusLanguage/PlusPasting.lean` carries `paste_valid'` and `snce_dstab_valid` for precisely this
reason. The two `*_swap` lemmas below are those duals. -/

/-- PS as a `StarValid`. -/
theorem starValid_paste {φ ψ : StarFormula} (hφ : StarIsPureFuture φ) (hψ : StarIsPurePast ψ) :
    StarValid ((StarFormula.dstab φ).imp
      ((StarFormula.dstab ψ).imp (StarFormula.dstab (φ.and ψ)))) :=
  StarValid.of_forall_total fun _ M τ hτ t v => star_paste_valid M τ hτ t v hφ hψ

/-- The temporal dual of PS: the same schema with the conjuncts exchanged, `⟐ψ⁻ → (⟐φ⁺ →
⟐(ψ⁻ ∧ φ⁺))`. Mirrors `Semantics.paste_valid'`. -/
theorem starValid_paste_swap {ψ φ : StarFormula} (hψ : StarIsPurePast ψ)
    (hφ : StarIsPureFuture φ) :
    StarValid ((StarFormula.dstab ψ).imp
      ((StarFormula.dstab φ).imp (StarFormula.dstab (ψ.and φ)))) :=
  StarValid.of_forall_total fun _ M τ hτ t v => star_paste_valid' M τ hτ t v hψ hφ

/-- US as a `StarValid`. -/
theorem starValid_untl_paste {α φ : StarFormula} (hα : StarIsPurePast α)
    (hφ : StarIsPureFuture φ) :
    StarValid ((StarFormula.untl α (StarFormula.dstab φ)).imp
      (StarFormula.dstab (StarFormula.untl α φ))) :=
  StarValid.of_forall_total fun _ M τ hτ t v => star_untl_paste_valid M τ hτ t v hα hφ

/-- The temporal dual of US, namely SS: `(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)`. Mirrors
`Semantics.snce_dstab_valid`. -/
theorem starValid_untl_paste_swap {α φ : StarFormula} (hα : StarIsPureFuture α)
    (hφ : StarIsPurePast φ) :
    StarValid ((StarFormula.snce α (StarFormula.dstab φ)).imp
      (StarFormula.dstab (StarFormula.snce α φ))) :=
  StarValid.of_forall_total fun _ M τ hτ t v => star_snce_paste_valid M τ hτ t v hα hφ

/-! ## Validity -/

/-- **Every TM⋆ schema is valid at its own minimum frame class.** One arm per constructor, no
wildcard. -/
theorem starAxiom_validIn_min {φ : StarFormula} (ax : StarAxiom φ) :
    StarValidIn ax.minFrameClass φ := by
  cases ax with
  | prop_k φ ψ χ => exact starValid_prop_k φ ψ χ
  | prop_s φ ψ => exact starValid_prop_s φ ψ
  | ex_falso φ => exact starValid_ex_falso φ
  | peirce φ ψ => exact starValid_peirce φ ψ
  | modal_t φ => exact starValid_modal_t φ
  | modal_4 φ => exact starValid_modal_4 φ
  | modal_b φ => exact starValid_modal_b φ
  | modal_5_collapse φ => exact starValid_modal_5_collapse φ
  | modal_k_dist φ ψ => exact starValid_modal_k_dist φ ψ
  | stab_k φ ψ => exact starValid_stab_k φ ψ
  | stab_t φ => exact starValid_stab_t φ
  | stab_4 φ => exact starValid_stab_4 φ
  | stab_5 φ => exact starValid_stab_5 φ
  | box_stab φ => exact starValid_box_stab φ
  | atom_stab p => exact starValid_atom_stab p
  | serial_future => exact starValid_serial_future
  | serial_past => exact starValid_serial_past
  | left_mono_until_G φ χ ψ => exact starValid_left_mono_until_G φ χ ψ
  | left_mono_since_H φ χ ψ => exact starValid_left_mono_since_H φ χ ψ
  | right_mono_until φ ψ χ => exact starValid_right_mono_until φ ψ χ
  | right_mono_since φ ψ χ => exact starValid_right_mono_since φ ψ χ
  | connect_future φ => exact starValid_connect_future φ
  | connect_past φ => exact starValid_connect_past φ
  | enrichment_until φ ψ p => exact starValid_enrichment_until φ ψ p
  | enrichment_since φ ψ p => exact starValid_enrichment_since φ ψ p
  | self_accum_until φ ψ => exact starValid_self_accum_until φ ψ
  | self_accum_since φ ψ => exact starValid_self_accum_since φ ψ
  | absorb_until φ ψ => exact starValid_absorb_until φ ψ
  | absorb_since φ ψ => exact starValid_absorb_since φ ψ
  | linear_until φ ψ χ θ => exact starValid_linear_until φ ψ χ θ
  | linear_since φ ψ χ θ => exact starValid_linear_since φ ψ χ θ
  | until_F φ ψ => exact starValid_until_F φ ψ
  | since_P φ ψ => exact starValid_since_P φ ψ
  | temp_linearity φ ψ => exact starValid_temp_linearity φ ψ
  | temp_linearity_past φ ψ => exact starValid_temp_linearity_past φ ψ
  | F_until_equiv φ => exact starValid_F_until_equiv φ
  | P_since_equiv φ => exact starValid_P_since_equiv φ
  | discrete_symm_fwd => exact starValid_discrete_symm_fwd
  | discrete_symm_bwd => exact starValid_discrete_symm_bwd
  | discrete_propagate_fwd => exact starValid_discrete_propagate_fwd
  | discrete_propagate_bwd => exact starValid_discrete_propagate_bwd
  | discrete_box_necessity => exact starValid_discrete_box_necessity
  | density φ => exact starValid_density φ
  | dense_indicator => exact starValid_dense_indicator
  | prior_UZ φ => exact starValid_prior_UZ φ
  | prior_SZ φ => exact starValid_prior_SZ φ
  | z1 φ => exact starValid_z1 φ
  | prior_U_gap φ => exact starValid_prior_U_gap φ
  | prior_S_gap φ => exact starValid_prior_S_gap φ
  | sep φ => exact starValid_sep φ
  | modal_future φ hφ => exact starValid_modal_future hφ
  | paste φ ψ hφ hψ => exact starValid_paste hφ hψ
  | untl_paste α φ hα hφ => exact starValid_untl_paste hα hφ
  | store_recall_same i φ => exact starValid_store_recall_same i φ
  | recall_store_same i φ => exact starValid_recall_store_same i φ
  | recall_recall i j φ => exact starValid_recall_recall i j φ
  | store_store_comm i j φ => exact starValid_store_store_comm i j φ
  | store_k i φ ψ => exact starValid_store_k i φ ψ
  | recall_k i φ ψ => exact starValid_recall_k i φ ψ
  | store_box i φ => exact starValid_store_box i φ
  | recall_box i φ => exact starValid_recall_box i φ
  | store_stab i φ => exact starValid_store_stab i φ
  | store_atom i p => exact starValid_store_atom i p
  | recall_rigid_future i φ => exact starValid_recall_rigid_future i φ
  | future_rigid_recall i φ => exact starValid_future_rigid_recall i φ
  | recall_rigid_past i φ => exact starValid_recall_rigid_past i φ
  | past_rigid_recall i φ => exact starValid_past_rigid_recall i φ
  | recall_export_until i φ ψ => exact starValid_recall_export_until i φ ψ
  | recall_export_since i φ ψ => exact starValid_recall_export_since i φ ψ

/-- Validity of a TM⋆ schema at any class admitting it. -/
theorem starAxiom_validIn {φ : StarFormula} {fc : FrameClass} (ax : StarAxiom φ)
    (h : ax.minFrameClass ≤ fc) : StarValidIn fc φ :=
  StarValidIn.mono h (starAxiom_validIn_min ax)

/-! ## Swap-validity -/

/-- **Every TM⋆ schema's temporal dual is valid at its own minimum frame class.** One arm per
constructor; the semantic input to the `temporal_duality` case of soundness. Each register arm
normalises `swapTemporal` and lands on the matching validity lemma — the swap-closure invariant
of `StarLanguage/Axioms.lean`, discharged constructor by constructor. -/
theorem starAxiom_swap_validIn_min {φ : StarFormula} (ax : StarAxiom φ) :
    StarValidIn ax.minFrameClass φ.swapTemporal := by
  cases ax with
  | prop_k φ ψ χ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_prop_k φ.swapTemporal ψ.swapTemporal χ.swapTemporal
  | prop_s φ ψ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_prop_s φ.swapTemporal ψ.swapTemporal
  | ex_falso φ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_ex_falso φ.swapTemporal
  | peirce φ ψ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_peirce φ.swapTemporal ψ.swapTemporal
  | modal_t φ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_modal_t φ.swapTemporal
  | modal_4 φ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_modal_4 φ.swapTemporal
  | modal_b φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_diamond]
    exact starValid_modal_b φ.swapTemporal
  | modal_5_collapse φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_diamond]
    exact starValid_modal_5_collapse φ.swapTemporal
  | modal_k_dist φ ψ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_modal_k_dist φ.swapTemporal ψ.swapTemporal
  | stab_k φ ψ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_stab_k φ.swapTemporal ψ.swapTemporal
  | stab_t φ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_stab_t φ.swapTemporal
  | stab_4 φ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_stab_4 φ.swapTemporal
  | stab_5 φ =>
    simp only [StarFormula.swap_temporal_dstab, StarFormula.swapTemporal]
    exact starValid_stab_5 φ.swapTemporal
  | box_stab φ =>
    simp only [StarFormula.swapTemporal]
    exact starValid_box_stab φ.swapTemporal
  | atom_stab p =>
    simp only [StarFormula.swapTemporal]
    exact starValid_atom_stab p
  | serial_future =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_some_future]
    exact starValid_serial_past
  | serial_past =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_some_past]
    exact starValid_serial_future
  | left_mono_until_G φ χ ψ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
    exact starValid_left_mono_since_H φ.swapTemporal χ.swapTemporal ψ.swapTemporal
  | left_mono_since_H φ χ ψ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_past]
    exact starValid_left_mono_until_G φ.swapTemporal χ.swapTemporal ψ.swapTemporal
  | right_mono_until φ ψ χ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
    exact starValid_right_mono_since φ.swapTemporal ψ.swapTemporal χ.swapTemporal
  | right_mono_since φ ψ χ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_past]
    exact starValid_right_mono_until φ.swapTemporal ψ.swapTemporal χ.swapTemporal
  | connect_future φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future,
      StarFormula.swap_temporal_some_past]
    exact starValid_connect_past φ.swapTemporal
  | connect_past φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_past,
      StarFormula.swap_temporal_some_future]
    exact starValid_connect_future φ.swapTemporal
  | enrichment_until φ ψ p =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swapTemporal]
    exact starValid_enrichment_since φ.swapTemporal ψ.swapTemporal p.swapTemporal
  | enrichment_since φ ψ p =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swapTemporal]
    exact starValid_enrichment_until φ.swapTemporal ψ.swapTemporal p.swapTemporal
  | self_accum_until φ ψ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swapTemporal]
    exact starValid_self_accum_since φ.swapTemporal ψ.swapTemporal
  | self_accum_since φ ψ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swapTemporal]
    exact starValid_self_accum_until φ.swapTemporal ψ.swapTemporal
  | absorb_until φ ψ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swapTemporal]
    exact starValid_absorb_since φ.swapTemporal ψ.swapTemporal
  | absorb_since φ ψ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swapTemporal]
    exact starValid_absorb_until φ.swapTemporal ψ.swapTemporal
  | linear_until φ ψ χ θ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swap_temporal_or,
      StarFormula.swapTemporal]
    exact starValid_linear_since φ.swapTemporal ψ.swapTemporal χ.swapTemporal θ.swapTemporal
  | linear_since φ ψ χ θ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swap_temporal_or,
      StarFormula.swapTemporal]
    exact starValid_linear_until φ.swapTemporal ψ.swapTemporal χ.swapTemporal θ.swapTemporal
  | until_F φ ψ =>
    simp only [StarFormula.swap_temporal_some_future, StarFormula.swapTemporal]
    exact starValid_since_P φ.swapTemporal ψ.swapTemporal
  | since_P φ ψ =>
    simp only [StarFormula.swap_temporal_some_past, StarFormula.swapTemporal]
    exact starValid_until_F φ.swapTemporal ψ.swapTemporal
  | temp_linearity φ ψ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swap_temporal_or,
      StarFormula.swap_temporal_some_future, StarFormula.swapTemporal]
    exact starValid_temp_linearity_past φ.swapTemporal ψ.swapTemporal
  | temp_linearity_past φ ψ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swap_temporal_or,
      StarFormula.swap_temporal_some_past, StarFormula.swapTemporal]
    exact starValid_temp_linearity φ.swapTemporal ψ.swapTemporal
  | F_until_equiv φ =>
    simp only [StarFormula.swap_temporal_some_future, StarFormula.swapTemporal]
    exact starValid_P_since_equiv φ.swapTemporal
  | P_since_equiv φ =>
    simp only [StarFormula.swap_temporal_some_past, StarFormula.swapTemporal]
    exact starValid_F_until_equiv φ.swapTemporal
  | discrete_symm_fwd =>
    simp only [StarFormula.swapTemporal]
    exact starValid_discrete_symm_bwd
  | discrete_symm_bwd =>
    simp only [StarFormula.swapTemporal]
    exact starValid_discrete_symm_fwd
  | discrete_propagate_fwd =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
    exact starValid_discrete_propagate_fwd_swap
  | discrete_propagate_bwd =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_past]
    exact starValid_discrete_propagate_bwd_swap
  | discrete_box_necessity =>
    simp only [StarFormula.swapTemporal]
    exact starValid_discrete_box_necessity_swap
  | density φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
    exact starValid_density_swap φ.swapTemporal
  | dense_indicator =>
    simp only [StarFormula.swap_temporal_neg, StarFormula.swapTemporal]
    exact starValid_dense_indicator_swap
  | prior_UZ φ =>
    simp only [StarFormula.swap_temporal_neg, StarFormula.swap_temporal_some_future,
      StarFormula.swapTemporal]
    exact starValid_prior_SZ φ.swapTemporal
  | prior_SZ φ =>
    simp only [StarFormula.swap_temporal_neg, StarFormula.swap_temporal_some_past,
      StarFormula.swapTemporal]
    exact starValid_prior_UZ φ.swapTemporal
  | z1 φ =>
    simp only [StarFormula.swap_temporal_all_future, StarFormula.swap_temporal_some_future,
      StarFormula.swapTemporal]
    exact starValid_z1_swap φ.swapTemporal
  | prior_U_gap φ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swap_temporal_or,
      StarFormula.swap_temporal_neg, StarFormula.swap_temporal_some_future,
      StarFormula.swap_temporal_kPlus, StarFormula.swap_temporal_top, StarFormula.swapTemporal]
    exact starValid_prior_S_gap φ.swapTemporal
  | prior_S_gap φ =>
    simp only [StarFormula.swap_temporal_and, StarFormula.swap_temporal_or,
      StarFormula.swap_temporal_neg, StarFormula.swap_temporal_some_past,
      StarFormula.swap_temporal_kMinus, StarFormula.swap_temporal_top, StarFormula.swapTemporal]
    exact starValid_prior_U_gap φ.swapTemporal
  | sep φ => exact starValid_sep_swap φ
  | modal_future φ hφ => exact starValid_modal_future_swap hφ
  | paste φ ψ hφ hψ =>
    simp only [StarFormula.swap_temporal_dstab, StarFormula.swap_temporal_and,
      StarFormula.swapTemporal]
    exact starValid_paste_swap hφ.swapTemporal hψ.swapTemporal
  | untl_paste α φ hα hφ =>
    simp only [StarFormula.swap_temporal_dstab, StarFormula.swapTemporal]
    exact starValid_untl_paste_swap hα.swapTemporal hφ.swapTemporal
  | store_recall_same i φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_store_recall_same i φ.swapTemporal
  | recall_store_same i φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_recall_store_same i φ.swapTemporal
  | recall_recall i j φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_recall_recall i j φ.swapTemporal
  | store_store_comm i j φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_store_store_comm i j φ.swapTemporal
  | store_k i φ ψ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_store_k i φ.swapTemporal ψ.swapTemporal
  | recall_k i φ ψ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_recall_k i φ.swapTemporal ψ.swapTemporal
  | store_box i φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_store_box i φ.swapTemporal
  | recall_box i φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_recall_box i φ.swapTemporal
  | store_stab i φ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_store_stab i φ.swapTemporal
  | store_atom i p =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swapTemporal]
    exact starValid_store_atom i p
  | recall_rigid_future i φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
    exact starValid_recall_rigid_past i φ.swapTemporal
  | future_rigid_recall i φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_future]
    exact starValid_past_rigid_recall i φ.swapTemporal
  | recall_rigid_past i φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_past]
    exact starValid_recall_rigid_future i φ.swapTemporal
  | past_rigid_recall i φ =>
    simp only [StarFormula.swapTemporal, StarFormula.swap_temporal_all_past]
    exact starValid_future_rigid_recall i φ.swapTemporal
  | recall_export_until i φ ψ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swap_temporal_and,
      StarFormula.swap_temporal_top, StarFormula.swapTemporal]
    exact starValid_recall_export_since i φ.swapTemporal ψ.swapTemporal
  | recall_export_since i φ ψ =>
    simp only [StarFormula.swap_temporal_iff, StarFormula.swap_temporal_and,
      StarFormula.swap_temporal_top, StarFormula.swapTemporal]
    exact starValid_recall_export_until i φ.swapTemporal ψ.swapTemporal

/-- Swap-validity of a TM⋆ schema at any class admitting it. -/
theorem starAxiom_swap_validIn {φ : StarFormula} {fc : FrameClass} (ax : StarAxiom φ)
    (h : ax.minFrameClass ≤ fc) : StarValidIn fc φ.swapTemporal :=
  StarValidIn.mono h (starAxiom_swap_validIn_min ax)

end FormalSystem.Metalogic.Conservativity
