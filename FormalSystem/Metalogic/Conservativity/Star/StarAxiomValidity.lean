/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.StarLanguage.Axioms
import FormalSystem.StarLanguage.StarValidity
import FormalSystem.Metalogic.Conservativity.Plus.AxiomValidity
import FormalSystem.Metalogic.SoundnessLemmas.GenericSchemata
import FormalSystem.Metalogic.Conservativity.Star.StarPasting

/-!
# Validity and reflection-validity of every TM⋆ axiom schema

The two dispatch lemmas of TM⋆ soundness, one arm per `StarAxiom` constructor and **no wildcard
arm** — so that a constructor added to `StarAxiom` fails the build here until its arm is
supplied:

- `starAxiom_validIn_min` — every schema is valid at its own `minFrameClass`;
- `starAxiom_reflect_time_validIn_min` — every schema's temporal dual is valid at its own
  `minFrameClass`.

The second is what makes the `time_reflection` rule sound **semantically**
(`Conservativity/Star/StarSoundness.lean`, the companion recursion). No proof-theoretic mirror
argument is used, and — as everywhere in this tree — no argument by uniform substitution: TM⁺ is
already not substitution-closed via `PlusAxiom.atom_stab`, and nothing here needs it.

## How the arms close

- **The 53 TM⁺ mirror arms** are named `starValid_*` lemmas, each a **one-line delegation** to
  the correspondingly named `generic_*` lemma of
  `Metalogic/SoundnessLemmas/GenericSchemata.lean`, which states every one of these schemata once
  over the `TruthEnv`/`StabClauses` clause interface. Each name, statement and attribute here is
  unchanged; only the bodies are. The delegation is statement-preserving because
  `StarFormula`'s own derived-operator `def`s coincide definitionally with the clause layer's
  `abbrev`s — the coincidence pinned by the `rfl` bridges in
  `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` — so no `show` is needed at any call site.

  Two arms pass something of their own into the generic statement rather than only arguments:
  `modal_future` and its dual discharge `generic_modal_future`'s explicit homogeneity hypothesis
  from `starTruthAt_timeShift` plus `recallFree_vector_irrelevant`, which is the one piece of L⋆
  semantics the generic layer cannot carry (it is about the environment the clause layer threads
  inert). The `.RTime` arms pass the completeness conjunct their own `sat_intro` produced.

  The order-theoretic content is still never inlined, one level further out:
  `generic_prior_UZ`/`generic_prior_SZ`/`generic_z1` consume
  `SoundnessLemmas/DiscreteOrder.lean` and `generic_sep` consumes
  `SoundnessLemmas/Separability.lean`, each at a `TruthEnv.T` predicate.

  **No L⋆ atomization is used, and none can exist.** The TM⁺ arms of `plusAxiom_validIn_min` go
  through `Conservativity/Plus/Atomization.lean`, which rests on `stab_state_only` — the
  invariant `StarFormula` is built to break, since neither `↓ⁱχ` nor `↑ⁱχ` is state-determined.
  Facing 53 arms this is the shortcut a reader is most likely to reach for; it is unavailable,
  and so is uniform substitution (TM⁺ is not substitution-closed via `atom_stab`). **This is
  exactly why the generic layer exists**: the shared statement had to be made somewhere, and the
  clause interface is where it can be made once for L⁺, L⋆ and L^▷ together instead of
  transcribed three times.

- **The sixteen register arms** are the named `starValid_*` lemmas below, one per constructor,
  proved directly from the two clauses of `def:BLstar-semantics`. Ten of them are definitional
  (`Iff.rfl`, or one `Function.update` identity); the four rigidity arms use forward and backward
  seriality; the two export arms are a six-line `constructor`.

- **Most reflection arms reuse a validity arm; the rest have named duals.** Where a schema's
  temporal dual *is* an instance of a constructor of this inductive — the ten `.iff` register
  schemata are self-dual, the rigidity arms pair G↔H, the export arms pair U↔S, and the mirror block
  supplies fifteen dual pairs — the reflection arm normalises `reflectTime` through the
  `StarFormula.reflect_time_*` family and applies the matching validity lemma at reflected
  arguments. Eleven schemata have **no** dual constructor (`discrete_propagate_fwd`/`_bwd`,
  `discrete_box_necessity`, `dense_indicator`, `density`, `z1`, `sep`, `modal_future`, `paste`,
  `untl_paste`), exactly as at the L level, where `SoundnessLemmas/FrameClassVariants.lean` carries
  a `*_reflect_time_valid` lemma for each; the corresponding `starValid_*_reflect_time` lemmas below
  supply those duals. That is the reflection-closure invariant of `StarLanguage/Axioms.lean`,
  discharged.

## References

* `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` — the TM⁺ dispatch pair being
  transported, and the dispatch shape being mirrored
* `FormalSystem/StarLanguage/Axioms.lean` — `StarAxiom` and its reflection-closure invariant
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
open FormalSystem.Metalogic.SoundnessLemmas

/-! ## Two shape adapters

The `.iff` clause lemma for `StarTruthAt`, and the `StarValid`-at-an-`.iff` introduction rule
every register arm below is stated through. They live here rather than in
`StarLanguage/StarTruth.lean` because every consumer is in this directory. -/

/-- The `.iff` clause lemma, in the shape of the `StarTruth.*_iff` family. -/
theorem starTruth_iff_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (v : ℕ → F.Duration) (φ ψ : StarFormula) :
    StarTruthAt M τ t v (φ.iff ψ) ↔ (StarTruthAt M τ t v φ ↔ StarTruthAt M τ t v ψ) := by
  simp only [StarFormula.iff, StarTruth.and_iff, StarTruth.imp_iff]
  exact ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.1, h.2⟩⟩

/-- Introduce `StarValid (φ.iff ψ)` from a pointwise biconditional. -/
theorem starValid_iff_of_forall {φ ψ : StarFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F)
           (x : F.Duration) (v : ℕ → F.Duration),
             (StarTruthAt M τ x v φ ↔ StarTruthAt M τ x v ψ)) :
    StarValid (φ.iff ψ) :=
  StarValid.of_forall fun F M τ x v =>
    (starTruth_iff_iff M τ x v φ ψ).mpr (h F M τ x v)

/-! ## The sixteen register schemata

Each is valid over **every** task frame, hence stated as `StarValid`. -/

/-- S1: `↑ⁱ↓ⁱφ ↔ ↑ⁱφ` — register `i` of `v⃗[i ↦ x]` is `x`. -/
theorem starValid_store_recall_same (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.timeRecall i φ)).iff (.timeStore i φ)) := by
  refine starValid_iff_of_forall fun F M τ x v => ?_
  rw [StarTruth.timeStore_iff, StarTruth.timeRecall_iff, Function.update_self,
    StarTruth.timeStore_iff]

/-- S2: `↓ⁱ↑ⁱφ ↔ ↓ⁱφ` — writing `v⃗ᵢ` into register `i` writes back what was there. -/
theorem starValid_recall_store_same (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (.timeStore i φ)).iff (.timeRecall i φ)) := by
  refine starValid_iff_of_forall fun F M τ x v => ?_
  rw [StarTruth.timeRecall_iff, StarTruth.timeStore_iff, Function.update_eq_self,
    StarTruth.timeRecall_iff]

/-- S3: `↓ⁱ↓ʲφ ↔ ↓ʲφ` — the inner recall overrides the outer one. -/
theorem starValid_recall_recall (i j : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (.timeRecall j φ)).iff (.timeRecall j φ)) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S4: `↑ⁱ↑ʲφ ↔ ↑ʲ↑ⁱφ` — both stores write the same time, so the updates commute. -/
theorem starValid_store_store_comm (i j : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.timeStore j φ)).iff
      (StarFormula.timeStore j (.timeStore i φ))) := by
  refine starValid_iff_of_forall fun F M τ x v => ?_
  simp only [StarTruth.timeStore_iff]
  by_cases hij : i = j
  · subst hij; rfl
  · rw [Function.update_comm hij x x v]

/-- S5: `↑ⁱ(φ → ψ) ↔ (↑ⁱφ → ↑ⁱψ)` — `↑ⁱ` is functional. -/
theorem starValid_store_k (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.timeStore i (φ.imp ψ)).iff
      ((StarFormula.timeStore i φ).imp (.timeStore i ψ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S5, recall half: `↓ⁱ(φ → ψ) ↔ (↓ⁱφ → ↓ⁱψ)`. -/
theorem starValid_recall_k (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (φ.imp ψ)).iff
      ((StarFormula.timeRecall i φ).imp (.timeRecall i ψ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S6: `↑ⁱ□φ ↔ □↑ⁱφ` — `□` moves the history, never the time or the vector. -/
theorem starValid_store_box (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.box φ)).iff (StarFormula.box (.timeStore i φ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S6, recall half: `↓ⁱ□φ ↔ □↓ⁱφ`. -/
theorem starValid_recall_box (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i (.box φ)).iff (StarFormula.box (.timeRecall i φ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S7: `↑ⁱ⊡φ ↔ ⊡↑ⁱφ` — `⊡`'s same-state condition is taken at the time `↑ⁱ` writes. The recall
analogue `↓ⁱ⊡φ ↔ ⊡↓ⁱφ` is **refuted** and is deliberately not among the schemata. -/
theorem starValid_store_stab (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeStore i (.stab φ)).iff (StarFormula.stab (.timeStore i φ))) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S9: `↑ⁱp ↔ p` for atoms — the atom clause does not read the register vector. -/
theorem starValid_store_atom (i : ℕ) (p : Atom) :
    StarValid ((StarFormula.timeStore i (.atom p)).iff (StarFormula.atom p)) :=
  starValid_iff_of_forall fun _ _ _ _ _ => Iff.rfl

/-- S8: `↓ⁱφ → G↓ⁱφ` — a recall's truth does not read the time of evaluation. -/
theorem starValid_recall_rigid_future (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i φ).imp
      (StarFormula.allFuture (.timeRecall i φ))) := by
  refine StarValid.of_forall fun F M τ x v h => ?_
  rw [StarTruth.allFuture_iff]
  intro s _
  exact h

/-- S8, converse: `G↓ⁱφ → ↓ⁱφ`, by forward seriality (`exists_gt`). -/
theorem starValid_future_rigid_recall (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.allFuture (.timeRecall i φ)).imp
      (StarFormula.timeRecall i φ)) := by
  refine StarValid.of_forall fun F M τ x v h => ?_
  rw [StarTruth.allFuture_iff] at h
  obtain ⟨y, hy⟩ := exists_gt x
  exact h y hy

/-- S8, past half: `↓ⁱφ → H↓ⁱφ`. -/
theorem starValid_recall_rigid_past (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i φ).imp
      (StarFormula.allPast (.timeRecall i φ))) := by
  refine StarValid.of_forall fun F M τ x v h => ?_
  rw [StarTruth.allPast_iff]
  intro s _
  exact h

/-- S8, past converse: `H↓ⁱφ → ↓ⁱφ`, by backward seriality (`exists_lt`). -/
theorem starValid_past_rigid_recall (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.allPast (.timeRecall i φ)).imp
      (StarFormula.timeRecall i φ)) := by
  refine StarValid.of_forall fun F M τ x v h => ?_
  rw [StarTruth.allPast_iff] at h
  obtain ⟨y, hy⟩ := exists_lt x
  exact h y hy

/-- S10: `ψ U ↓ⁱφ ↔ (↓ⁱφ ∧ (ψ U ⊤))` — a rigid event contributes nothing to the `until` beyond
the existence of the interval. -/
theorem starValid_recall_export_until (i : ℕ) (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl ψ (.timeRecall i φ)).iff
      ((StarFormula.timeRecall i φ).and (StarFormula.untl ψ StarFormula.top))) := by
  refine starValid_iff_of_forall fun F M τ x v => ?_
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
  refine starValid_iff_of_forall fun F M τ x v => ?_
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
non-substitution-closed. Every arm below delegates to `GenericSchemata.lean`, where the schema
is stated once pointwise over the clause interface; none is re-proved here. -/

/-- Propositional K over L⋆. Mirror of `PlusAxiom.prop_k`'s validity. -/
theorem starValid_prop_k (φ ψ χ : StarFormula) :
    StarValid ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_prop_k (L := StarFormula) M τ x v φ ψ χ

/-- Propositional S (weakening) over L⋆. -/
theorem starValid_prop_s (φ ψ : StarFormula) : StarValid (φ.imp (ψ.imp φ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_prop_s (L := StarFormula) M τ x v φ ψ

/-- Ex Falso Quodlibet over L⋆. -/
theorem starValid_ex_falso (φ : StarFormula) : StarValid (StarFormula.bot.imp φ) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_ex_falso (L := StarFormula) M τ x v φ

/-- Peirce's Law over L⋆, by classical case analysis on `φ`. -/
theorem starValid_peirce (φ ψ : StarFormula) : StarValid (((φ.imp ψ).imp φ).imp φ) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_peirce (L := StarFormula) M τ x v φ ψ

/-- Modal T over L⋆: the evaluation history is itself a world history, so `□` reflects. -/
theorem starValid_modal_t (φ : StarFormula) : StarValid ((StarFormula.box φ).imp φ) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_t (L := StarFormula) M τ x v φ

/-- Modal 4 over L⋆: the `box` clause quantifies over all world histories, so it is idempotent. -/
theorem starValid_modal_4 (φ : StarFormula) :
    StarValid ((StarFormula.box φ).imp (StarFormula.box (StarFormula.box φ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_4 (L := StarFormula) M τ x v φ

/-- Modal B over L⋆. -/
theorem starValid_modal_b (φ : StarFormula) :
    StarValid (φ.imp (StarFormula.box φ.diamond)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_b (L := StarFormula) M τ x v φ

/-- Modal 5 Collapse over L⋆. -/
theorem starValid_modal_5_collapse (φ : StarFormula) :
    StarValid (φ.box.diamond.imp φ.box) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_5_collapse (L := StarFormula) M τ x v φ

/-- Modal K distribution over L⋆. -/
theorem starValid_modal_k_dist (φ ψ : StarFormula) :
    StarValid ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_k_dist (L := StarFormula) M τ x v φ ψ

/-- SK over L⋆: K for `⊡`, from the universal-quantifier shape of the `stab` clause. -/
theorem starValid_stab_k (φ ψ : StarFormula) :
    StarValid ((StarFormula.stab (φ.imp ψ)).imp
      ((StarFormula.stab φ).imp (StarFormula.stab ψ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_stab_k (L := StarFormula) M τ x v φ ψ

/-- ST over L⋆: state equality is reflexive. -/
theorem starValid_stab_t (φ : StarFormula) : StarValid ((StarFormula.stab φ).imp φ) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_stab_t (L := StarFormula) M τ x v φ

/-- S4 for `⊡` over L⋆: state equality at a fixed time is transitive. -/
theorem starValid_stab_4 (φ : StarFormula) :
    StarValid ((StarFormula.stab φ).imp (StarFormula.stab (StarFormula.stab φ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_stab_4 (L := StarFormula) M τ x v φ

/-- S5 for `⊡` over L⋆: state equality at a fixed time is symmetric. -/
theorem starValid_stab_5 (φ : StarFormula) :
    StarValid ((StarFormula.dstab φ).imp (StarFormula.stab (StarFormula.dstab φ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_stab_5 (L := StarFormula) M τ x v φ

/-- MS over L⋆: `⟨τ⟩_x ⊆ H_F`, so `□` is stronger than `⊡` — **at every `φ : StarFormula`**,
registers included. This is the schematic fact that makes `stabNecessitation`
(`StarLanguage/Derivation.lean`) unrestricted. -/
theorem starValid_box_stab (φ : StarFormula) :
    StarValid ((StarFormula.box φ).imp (StarFormula.stab φ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_box_stab (L := StarFormula) M τ x v φ

/-- AS over L⋆: the atom clause reads the world state alone, which the `stab` clause fixes. -/
theorem starValid_atom_stab (p : Atom) :
    StarValid ((StarFormula.atom p).imp (StarFormula.stab (StarFormula.atom p))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_atom_stab (L := StarFormula) M τ x v p

/-! ## The TM⁺ mirror block — seriality, monotonicity, connection

Delegations to the generic layer. The two seriality schemata used to transport along
`starValidOnFrames_ofPlus` because their formulas are closed; `generic_serial_future` and its
siblings remove the detour, since the content is seriality of the *temporal order*
(`exists_gt`/`exists_lt` on `F.Duration`) and needs no `ofPlus` embedding at all. -/

/-- Serial future over L⋆: `F⊤`. -/
theorem starValid_serial_future :
    StarValid (StarFormula.someFuture (StarFormula.bot.imp StarFormula.bot)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_serial_future (L := StarFormula) M τ x v

/-- `⊤ → F(⊤)` over L⋆: `starValid_serial_future` under a trivially true antecedent. The
time reflection of `serial_past`. -/
theorem starValid_serial_future_imp :
    StarValid ((StarFormula.bot.imp StarFormula.bot).imp
      (StarFormula.someFuture (StarFormula.bot.imp StarFormula.bot))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_serial_future_imp (L := StarFormula) M τ x v

/-- Serial past over L⋆: `⊤ → P⊤`. -/
theorem starValid_serial_past :
    StarValid ((StarFormula.bot.imp StarFormula.bot).imp
      (StarFormula.somePast (StarFormula.bot.imp StarFormula.bot))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_serial_past (L := StarFormula) M τ x v

/-- `P(⊤)` over L⋆: `starValid_serial_past` at the true antecedent `⊤`. The time reflection of
the paper's TS. -/
theorem starValid_serial_past_bare :
    StarValid (StarFormula.somePast (StarFormula.bot.imp StarFormula.bot)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_serial_past_bare (L := StarFormula) M τ x v

/-- BX2G over L⋆: the guard of an `until` may be weakened under `G`. -/
theorem starValid_left_mono_until_G (φ χ ψ : StarFormula) :
    StarValid ((φ.imp χ).allFuture.imp
      ((StarFormula.untl φ ψ).imp (StarFormula.untl χ ψ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_left_mono_until_G (L := StarFormula) M τ x v φ χ ψ

/-- BX2H over L⋆, the past mirror of `starValid_left_mono_until_G`. -/
theorem starValid_left_mono_since_H (φ χ ψ : StarFormula) :
    StarValid ((φ.imp χ).allPast.imp
      ((StarFormula.snce φ ψ).imp (StarFormula.snce χ ψ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_left_mono_since_H (L := StarFormula) M τ x v φ χ ψ

/-- BX3 over L⋆: the event of an `until` may be weakened under `G`. -/
theorem starValid_right_mono_until (φ ψ χ : StarFormula) :
    StarValid ((φ.imp ψ).allFuture.imp
      ((StarFormula.untl χ φ).imp (StarFormula.untl χ ψ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_right_mono_until (L := StarFormula) M τ x v φ ψ χ

/-- BX3' over L⋆, the past mirror of `starValid_right_mono_until`. -/
theorem starValid_right_mono_since (φ ψ χ : StarFormula) :
    StarValid ((φ.imp ψ).allPast.imp
      ((StarFormula.snce χ φ).imp (StarFormula.snce χ ψ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_right_mono_since (L := StarFormula) M τ x v φ ψ χ

/-- BX4 over L⋆: what is true now is always going to have been true. -/
theorem starValid_connect_future (φ : StarFormula) :
    StarValid (φ.imp (φ.somePast.allFuture)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_connect_future (L := StarFormula) M τ x v φ

/-- BX4' over L⋆, the past mirror of `starValid_connect_future`. -/
theorem starValid_connect_past (φ : StarFormula) :
    StarValid (φ.imp (φ.someFuture.allPast)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_connect_past (L := StarFormula) M τ x v φ

/-! ## The TM⁺ mirror block — enrichment, self-accumulation, absorption, linearity

The heaviest of the BX block. The trichotomy-on-two-witnesses argument each of these needs now
lives once in `GenericSchemata.lean`; the arms here are delegations. Both nestings of CN/BX7 are
supplied generically, so **no language's statement is re-associated** by the refactor. As
throughout: no atomization, no uniform substitution. -/

/-- BX13 over L⋆. -/
theorem starValid_enrichment_until (φ ψ p : StarFormula) :
    StarValid (StarFormula.and p (StarFormula.untl φ ψ) |>.imp
      (StarFormula.untl φ (StarFormula.and ψ (StarFormula.snce φ p)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_enrichment_until (L := StarFormula) M τ x v φ ψ p

/-- BX13' over L⋆, the past mirror of `starValid_enrichment_until`. -/
theorem starValid_enrichment_since (φ ψ p : StarFormula) :
    StarValid (StarFormula.and p (StarFormula.snce φ ψ) |>.imp
      (StarFormula.snce φ (StarFormula.and ψ (StarFormula.untl φ p)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_enrichment_since (L := StarFormula) M τ x v φ ψ p

/-- BX5 over L⋆. -/
theorem starValid_self_accum_until (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl φ ψ).imp
      (StarFormula.untl (StarFormula.and φ (StarFormula.untl φ ψ)) ψ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_self_accum_until (L := StarFormula) M τ x v φ ψ

/-- BX5' over L⋆, the past mirror of `starValid_self_accum_until`. -/
theorem starValid_self_accum_since (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce φ ψ).imp
      (StarFormula.snce (StarFormula.and φ (StarFormula.snce φ ψ)) ψ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_self_accum_since (L := StarFormula) M τ x v φ ψ

/-- BX6 over L⋆. -/
theorem starValid_absorb_until (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl φ (StarFormula.and φ (StarFormula.untl φ ψ))).imp
      (StarFormula.untl φ ψ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_absorb_until (L := StarFormula) M τ x v φ ψ

/-- BX6' over L⋆, the past mirror of `starValid_absorb_until`. -/
theorem starValid_absorb_since (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce φ (StarFormula.and φ (StarFormula.snce φ ψ))).imp
      (StarFormula.snce φ ψ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_absorb_since (L := StarFormula) M τ x v φ ψ

/-- BX7 over L⋆: linearity of `until`, by trichotomy on the two witnesses. -/
theorem starValid_linear_until (φ ψ χ θ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.untl φ ψ) (StarFormula.untl χ θ)
      |>.imp (StarFormula.or
        (StarFormula.or
          (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and ψ θ))
          (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and ψ χ)))
        (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and φ θ)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_linear_until (L := StarFormula) M τ x v φ ψ χ θ

/-- The paper's CN over L⋆ (`StarAxiom.linear_until`, right-associated). -/
theorem starValid_linear_until_paper (φ ψ χ θ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.untl φ ψ) (StarFormula.untl χ θ)
      |>.imp (StarFormula.or
        (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and ψ θ))
        (StarFormula.or
          (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and ψ χ))
          (StarFormula.untl (StarFormula.and φ χ) (StarFormula.and φ θ))))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_linear_until_paper (L := StarFormula) M τ x v φ ψ χ θ

/-- The time reflection of the paper's CN over L⋆: Since linearity, right-associated. -/
theorem starValid_linear_since_paper (φ ψ χ θ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.snce φ ψ) (StarFormula.snce χ θ)
      |>.imp (StarFormula.or
        (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and ψ θ))
        (StarFormula.or
          (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and ψ χ))
          (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and φ θ))))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_linear_since_paper (L := StarFormula) M τ x v φ ψ χ θ

/-- BX7' over L⋆, the past mirror of `starValid_linear_until`. -/
theorem starValid_linear_since (φ ψ χ θ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.snce φ ψ) (StarFormula.snce χ θ)
      |>.imp (StarFormula.or
        (StarFormula.or
          (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and ψ θ))
          (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and ψ χ)))
        (StarFormula.snce (StarFormula.and φ χ) (StarFormula.and φ θ)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_linear_since (L := StarFormula) M τ x v φ ψ χ θ

/-! ## The TM⁺ mirror block — `until_F`/`since_P`, temporal linearity, the two equivalences -/

/-- BX10 over L⋆: an `until` witness is a future witness. -/
theorem starValid_until_F (φ ψ : StarFormula) :
    StarValid ((StarFormula.untl φ ψ).imp (StarFormula.someFuture ψ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_until_F (L := StarFormula) M τ x v φ ψ

/-- BX10' over L⋆, the past mirror of `starValid_until_F`. -/
theorem starValid_since_P (φ ψ : StarFormula) :
    StarValid ((StarFormula.snce φ ψ).imp (StarFormula.somePast ψ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_since_P (L := StarFormula) M τ x v φ ψ

/-- BX11 over L⋆: two future witnesses are ordered, by trichotomy. -/
theorem starValid_temp_linearity (φ ψ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.someFuture φ) (StarFormula.someFuture ψ) |>.imp
      (StarFormula.or (StarFormula.someFuture (StarFormula.and φ ψ))
        (StarFormula.or (StarFormula.someFuture (StarFormula.and φ (StarFormula.someFuture ψ)))
          (StarFormula.someFuture (StarFormula.and (StarFormula.someFuture φ) ψ))))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_temp_linearity (L := StarFormula) M τ x v φ ψ

/-- The paper's TL over L⋆ (`StarAxiom.temp_linearity`). -/
theorem starValid_temp_linearity_paper (φ ψ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.someFuture φ) (StarFormula.someFuture ψ) |>.imp
      (StarFormula.or (StarFormula.someFuture (StarFormula.and (StarFormula.someFuture φ) ψ))
        (StarFormula.or (StarFormula.someFuture (StarFormula.and φ ψ))
          (StarFormula.someFuture (StarFormula.and φ (StarFormula.someFuture ψ)))))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_temp_linearity_paper (L := StarFormula) M τ x v φ ψ

/-- The time reflection of the paper's TL over L⋆. -/
theorem starValid_temp_linearity_past_paper (φ ψ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.somePast φ) (StarFormula.somePast ψ) |>.imp
      (StarFormula.or (StarFormula.somePast (StarFormula.and (StarFormula.somePast φ) ψ))
        (StarFormula.or (StarFormula.somePast (StarFormula.and φ ψ))
          (StarFormula.somePast (StarFormula.and φ (StarFormula.somePast ψ)))))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_temp_linearity_past_paper (L := StarFormula) M τ x v φ ψ

/-- BX11' over L⋆, the past mirror of `starValid_temp_linearity`. -/
theorem starValid_temp_linearity_past (φ ψ : StarFormula) :
    StarValid (StarFormula.and (StarFormula.somePast φ) (StarFormula.somePast ψ) |>.imp
      (StarFormula.or (StarFormula.somePast (StarFormula.and φ ψ))
        (StarFormula.or (StarFormula.somePast (StarFormula.and φ (StarFormula.somePast ψ)))
          (StarFormula.somePast (StarFormula.and (StarFormula.somePast φ) ψ))))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_temp_linearity_past (L := StarFormula) M τ x v φ ψ

/-- BX12 over L⋆: `F` is `U` at the trivial guard. -/
theorem starValid_F_until_equiv (φ : StarFormula) :
    StarValid ((StarFormula.someFuture φ).imp
      (StarFormula.untl (StarFormula.bot.imp StarFormula.bot) φ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_F_until_equiv (L := StarFormula) M τ x v φ

/-- BX12' over L⋆, the past mirror of `starValid_F_until_equiv`. -/
theorem starValid_P_since_equiv (φ : StarFormula) :
    StarValid ((StarFormula.somePast φ).imp
      (StarFormula.snce (StarFormula.bot.imp StarFormula.bot) φ)) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_P_since_equiv (L := StarFormula) M τ x v φ

/-! ## The TM⁺ mirror block — discrete uniformity, density, Prior, Z1

Every arm here delegates. The five uniformity schemata used to transport along
`starValidOnFrames_ofPlus` from `plusAxiom_validIn_min`; the generic forms prove them outright
from the duration group's order, with the gap-translation argument written once in
`GenericSchemata.lean`'s `generic_gap_shift` / `generic_cogap_shift` / `generic_gap_iff_cogap`.

The order-theoretic content is **not** inlined, one level further out: `generic_prior_UZ` and
`generic_prior_SZ` consume `SoundnessLemmas.DiscreteOrder`'s
`exists_nearest_gt`/`exists_nearest_lt` and `generic_z1` its
`forall_gt_of_succ_step`/`forall_lt_of_pred_step`, each at `P := fun x => TruthEnv.T M τ x v φ`.
The frame-class side conditions arrive as instance binders that each arm's own `sat_intro`
discharges.

**Measured correction to this group's reflection-closure.** Three of the five uniformity schemata
are *not* closed under `reflectTime` within the group — `reflectTime` exchanges `untl` and `snce`,
so the dual of `U(⊤,⊥) → G(U(⊤,⊥))` is `S(⊤,⊥) → H(S(⊤,⊥))`, which is no member's statement — and
neither `density`, `dense_indicator` nor `z1` has a past twin among the schemata. This mirrors the L
level exactly, where `SoundnessLemmas.FrameClassVariants` carries a dedicated `*_reflect_time_valid`
lemma for each. The named `*_reflect_time` lemmas below are those duals, and the generic layer
supplies a distinct statement for each of them. -/

/-- `discrete_symm_fwd` over L⋆. -/
theorem starValid_discrete_symm_fwd :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_symm_fwd (L := StarFormula) M τ x v

/-- `discrete_symm_bwd` over L⋆. -/
theorem starValid_discrete_symm_bwd :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_symm_bwd (L := StarFormula) M τ x v

/-- `discrete_propagate_fwd` over L⋆. -/
theorem starValid_discrete_propagate_fwd :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.allFuture
        (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_propagate_fwd (L := StarFormula) M τ x v

/-- The temporal dual of `discrete_propagate_fwd`: `S(⊤,⊥) → H(S(⊤,⊥))`. Not an instance of any
schema, so it is named here, mirroring
`SoundnessLemmas.discrete_propagate_fwd_reflect_time_valid`. -/
theorem starValid_discrete_propagate_fwd_reflect_time :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.allPast
        (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_propagate_fwd_reflect_time (L := StarFormula) M τ x v

/-- `discrete_propagate_bwd` over L⋆. -/
theorem starValid_discrete_propagate_bwd :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.allPast
        (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_propagate_bwd (L := StarFormula) M τ x v

/-- The temporal dual of `discrete_propagate_bwd`: `S(⊤,⊥) → G(S(⊤,⊥))`. -/
theorem starValid_discrete_propagate_bwd_reflect_time :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.allFuture
        (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_propagate_bwd_reflect_time (L := StarFormula) M τ x v

/-- `discrete_box_necessity` over L⋆. -/
theorem starValid_discrete_box_necessity :
    StarValid ((StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.box
        (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_box_necessity (L := StarFormula) M τ x v

/-- The temporal dual of `discrete_box_necessity`: `S(⊤,⊥) → □(S(⊤,⊥))`. -/
theorem starValid_discrete_box_necessity_reflect_time :
    StarValid ((StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).imp
        (StarFormula.box
        (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_discrete_box_necessity_reflect_time (L := StarFormula) M τ x v

/-- Density over L⋆ at `.Dense`: `GGφ → Gφ`. -/
theorem starValid_density (φ : StarFormula) :
    StarValidIn FrameClass.Dense ((φ.allFuture.allFuture).imp φ.allFuture) := by
  refine fun F h_dense M τ t v => ?_
  sat_intro h_dense
  exact generic_density (L := StarFormula) M τ t v φ

/-- The temporal dual of `starValid_density`: `HHφ → Hφ`, again at `.Dense`. There is no
`density_past` schema, so this dual is named here rather than dispatched to a sibling
constructor — mirroring `Metalogic/Soundness.lean`'s `density_reflect_time_valid`. -/
theorem starValid_density_reflect_time (φ : StarFormula) :
    StarValidIn FrameClass.Dense ((φ.allPast.allPast).imp φ.allPast) := by
  refine fun F h_dense M τ t v => ?_
  sat_intro h_dense
  exact generic_density_reflect_time (L := StarFormula) M τ t v φ

/-- The dense indicator over L⋆ at `.Dense`. -/
theorem starValid_dense_indicator :
    StarValidIn FrameClass.Dense
        (StarFormula.untl StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).neg := by
  refine fun F h_dense M τ t v => ?_
  sat_intro h_dense
  exact generic_dense_indicator (L := StarFormula) M τ t v

/-- The temporal dual of the dense indicator: `¬S(⊤,⊥)`. -/
theorem starValid_dense_indicator_reflect_time :
    StarValidIn FrameClass.Dense
        (StarFormula.snce StarFormula.bot (StarFormula.bot.imp StarFormula.bot)).neg := by
  refine fun F h_dense M τ t v => ?_
  sat_intro h_dense
  exact generic_dense_indicator_reflect_time (L := StarFormula) M τ t v

/-- Prior-UZ over L⋆ at `.ZTime`: the nearest `φ`-point above `t` witnesses `U(φ, ¬φ)`. -/
theorem starValid_prior_UZ (φ : StarFormula) :
    StarValidIn FrameClass.ZTime (φ.someFuture.imp (StarFormula.untl φ.neg φ)) := by
  refine fun F hF M τ t v => ?_
  sat_intro hF
  exact generic_prior_UZ (L := StarFormula) M τ t v φ

/-- Prior-SZ over L⋆ at `.ZTime`, the past dual — through `exists_nearest_lt`, which is itself
`exists_nearest_gt` at `Dᵒᵈ`. The dualisation is of the *carrier*, never of the formula. -/
theorem starValid_prior_SZ (φ : StarFormula) :
    StarValidIn FrameClass.ZTime (φ.somePast.imp (StarFormula.snce φ.neg φ)) := by
  refine fun F hF M τ t v => ?_
  sat_intro hF
  exact generic_prior_SZ (L := StarFormula) M τ t v φ

/-- Z1 over L⋆ at `.ZTime`, through `forall_gt_of_succ_step`. -/
theorem starValid_z1 (φ : StarFormula) :
    StarValidIn FrameClass.ZTime ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  refine fun F hF M τ t v => ?_
  sat_intro hF
  exact generic_z1 (L := StarFormula) M τ t v φ

/-- The temporal dual of `starValid_z1`, through `forall_lt_of_pred_step`. Z1 has no past twin
among the schemata, so this dual is named here — mirroring
`SoundnessLemmas.z1_past_valid`. -/
theorem starValid_z1_reflect_time (φ : StarFormula) :
    StarValidIn FrameClass.ZTime ((φ.allPast.imp φ).allPast.imp
      (φ.allPast.somePast.imp φ.allPast)) := by
  refine fun F hF M τ t v => ?_
  sat_intro hF
  exact generic_z1_reflect_time (L := StarFormula) M τ t v φ

/-! ## The register-inertness of the `↓ⁱ`-free fragment

`recallFree_vector_irrelevant` is the semantic content of `RecallFree`
(`StarLanguage/Formula.lean`) and the load-bearing input to the `modal_future` arm. It is
genuinely new rather than a transcription: no L⁺ statement mentions a register vector, and it is
the one piece of this file's own semantics that the generic layer cannot carry, because it is
about the environment the clause layer threads inert.

The two `K±` clause lemmas that used to sit here are gone: `TruthClauses.kPlus_iff` and
`TruthClauses.kMinus_iff` (`Semantics/TruthClauses.lean`) now state them once over the clause
interface, and the Dedekind arms reach them through the generic schemata below. Nothing outside
this file ever consumed the L⋆-specific pair. -/

/-- **The stored-time vector is inert on `↓ⁱ`-free formulas.** The `timeStore` case recurses at
`Function.update v i t` on both sides, which is why the vector pair is quantified inside the
motive; `timeRecall` — the one case that would read the vector — is absent from `RecallFree` by
construction.

This is what makes `StarAxiom.modal_future` sound at every `RecallFree φ`: the L⋆ time-shift
lemma moves the vector along with the history, and on this fragment that movement is invisible. -/
theorem recallFree_vector_irrelevant {F : TaskFrame} (M : TaskModel F) {φ : StarFormula}
    (hφ : RecallFree φ) :
    ∀ (τ : WorldHistory F) (t : F.Duration) (v w : ℕ → F.Duration),
      StarTruthAt M τ t v φ ↔ StarTruthAt M τ t w φ := by
  induction hφ with
  | atom p => intros; exact Iff.rfl
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ => intro τ t v w; exact Iff.imp (ihφ τ t v w) (ihψ τ t v w)
  | box _ ih => intro τ t v w; exact forall_congr' fun ρ => ih ρ t v w
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
    exact forall_congr' fun ρ => imp_congr_right fun _ => ih ρ t v w
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
  refine fun F h_lub M τ t v => ?_
  sat_intro h_lub
  exact generic_prior_U_gap (L := StarFormula) M τ t v φ h_lub

/-- Prior-S (gap form) over L⋆ at `.RTime`, the past dual — through
`SoundnessLemmas.exists_isGLB_of_lub`, so the least-upper-bound hypothesis is used once and the
greatest lower bound is derived rather than assumed. -/
theorem starValid_prior_S_gap (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      ((StarFormula.and (StarFormula.snce φ StarFormula.top) φ.neg.somePast).imp
        (StarFormula.snce φ (StarFormula.or φ.neg (StarFormula.kMinus φ.neg)))) := by
  refine fun F h_lub M τ t v => ?_
  sat_intro h_lub
  exact generic_prior_S_gap (L := StarFormula) M τ t v φ h_lub

/-- **Sep over L⋆ at `.RTime`.** The order-theoretic core is
`SoundnessLemmas.sep_order`, consumed unchanged at `P := {u | StarTruthAt M τ u v φ}`; nothing
about `StarFormula` enters it. -/
theorem starValid_sep (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      ((StarFormula.and (StarFormula.kPlus φ)
        (StarFormula.kPlus (StarFormula.and φ (StarFormula.untl φ.neg φ))).neg).imp
        (StarFormula.kPlus (StarFormula.and (StarFormula.kPlus φ) (StarFormula.kMinus φ)))) := by
  refine fun F h_lub M τ t v => ?_
  sat_intro h_lub
  exact generic_sep (L := StarFormula) M τ t v φ h_lub

/-- **The temporal dual of Sep**, at `.RTime`. Sep has no past twin among the schemata, so the
dual is named here; the order-theoretic core is `SoundnessLemmas.sep_order_mirror`, which is
`sep_order` instantiated at `Dᵒᵈ`, so the nested-interval argument is written once. Mirrors
`Metalogic/Soundness.lean`'s `sep_reflect_time_valid`. -/
theorem starValid_sep_reflect_time (φ : StarFormula) :
    StarValidIn FrameClass.RTime
      (((StarFormula.and (StarFormula.kPlus φ)
        (StarFormula.kPlus (StarFormula.and φ (StarFormula.untl φ.neg φ))).neg).imp
        (StarFormula.kPlus
          (StarFormula.and (StarFormula.kPlus φ) (StarFormula.kMinus φ)))).reflectTime) := by
  refine fun F h_lub M τ t v => ?_
  sat_intro h_lub
  exact generic_sep_reflect_time (L := StarFormula) M τ t v φ.reflectTime h_lub

/-- **MF at every `↓ⁱ`-free `StarFormula`** — strictly wider than the register-free (`ofPlus`)
instances. The argument is the L-level one, `starTruthAt_timeShift` supplying homogeneity, with
`recallFree_vector_irrelevant` absorbing the vector the L⋆ shift drags along. -/
theorem starValid_modal_future {φ : StarFormula} (hφ : RecallFree φ) :
    StarValid ((StarFormula.box φ).imp (StarFormula.box (StarFormula.allFuture φ))) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_future (L := StarFormula) M τ x v φ fun σ s hxs h => by
      have h1 := h (σ.timeShift (s - x))
      have h2 := (starTruthAt_timeShift M φ σ x (s - x) v).mp h1
      rw [add_sub_cancel] at h2
      exact (recallFree_vector_irrelevant M hφ σ s _ v).mp h2

/-- MF's temporal dual, at every `↓ⁱ`-free `StarFormula`: `□φ → □(Hφ)`. No `modal_past` schema
exists, so this dual is named here. `RecallFree.reflectTime` carries the side condition across.
-/
theorem starValid_modal_future_reflect_time {φ : StarFormula} (hφ : RecallFree φ) :
    StarValid (((StarFormula.box φ).imp
      (StarFormula.box (StarFormula.allFuture φ))).reflectTime) :=
  StarValid.of_forall fun _ M τ x v =>
    generic_modal_future_reflect_time (L := StarFormula) M τ x v φ.reflectTime
      fun σ s hsx h => by
        have h1 := h (σ.timeShift (s - x))
        have h2 := (starTruthAt_timeShift M φ.reflectTime σ x (s - x) v).mp h1
        rw [add_sub_cancel] at h2
        exact (recallFree_vector_irrelevant M hφ.reflectTime σ s _ v).mp h2

/-! ## The TM⁺ mirror block — the two pasting schemata

The semantic content is `Conservativity/Star/StarPasting.lean`'s: the two purity congruences and
the four pasting validities, over the L⋆ purity predicates. Nothing is re-proved here; these four
lemmas are the `StarValid` packagings the dispatch consumes.

**Measured correction to this group's reflection-closure.** PS and US are not each other's duals.
`reflectTime` fixes `⟐` and exchanges `untl`/`snce`, so the dual of PS is PS with the conjuncts
exchanged (PS'), and the dual of US is SS — exactly as at the L⁺ level, where
`PlusLanguage/PlusPasting.lean` carries `paste_valid'` and `snce_dstab_valid` for
precisely this reason. The two `*_reflect_time` lemmas below are those duals. -/

/-- PS as a `StarValid`. -/
theorem starValid_paste
    {φ ψ : StarFormula} (hφ : StarIsPureFuture φ) (hψ : StarIsPurePast ψ) :
    StarValid ((StarFormula.dstab φ).imp
      ((StarFormula.dstab ψ).imp (StarFormula.dstab (φ.and ψ)))) :=
  StarValid.of_forall_regular fun _ _ M τ t v => star_paste_valid M τ t v hφ hψ

/-- The temporal dual of PS: the same schema with the conjuncts exchanged, `⟐ψ⁻ → (⟐φ⁺ →
⟐(ψ⁻ ∧ φ⁺))`. Mirrors `Semantics.paste_valid'`. -/
theorem starValid_paste_reflect_time {ψ φ : StarFormula} (hψ : StarIsPurePast ψ)
    (hφ : StarIsPureFuture φ) :
    StarValid ((StarFormula.dstab ψ).imp
      ((StarFormula.dstab φ).imp (StarFormula.dstab (ψ.and φ)))) :=
  StarValid.of_forall_regular fun _ _ M τ t v => star_paste_valid' M τ t v hψ hφ

/-- US as a `StarValid`. -/
theorem starValid_untl_paste {α φ : StarFormula} (hα : StarIsPurePast α)
    (hφ : StarIsPureFuture φ) :
    StarValid ((StarFormula.untl α (StarFormula.dstab φ)).imp
      (StarFormula.dstab (StarFormula.untl α φ))) :=
  StarValid.of_forall_regular fun _ _ M τ t v => star_untl_paste_valid M τ t v hα hφ

/-- The temporal dual of US, namely SS: `(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)`. Mirrors
`Semantics.snce_dstab_valid`. -/
theorem starValid_untl_paste_reflect_time
    {α φ : StarFormula} (hα : StarIsPureFuture α)
    (hφ : StarIsPurePast φ) :
    StarValid ((StarFormula.snce α (StarFormula.dstab φ)).imp
      (StarFormula.dstab (StarFormula.snce α φ))) :=
  StarValid.of_forall_regular fun _ _ M τ t v => star_snce_paste_valid M τ t v hα hφ

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
  | linear_until φ ψ χ θ => exact starValid_linear_until_paper φ ψ χ θ
  | linear_since φ ψ χ θ => exact starValid_linear_since φ ψ χ θ
  | until_F φ ψ => exact starValid_until_F φ ψ
  | since_P φ ψ => exact starValid_since_P φ ψ
  | temp_linearity φ ψ => exact starValid_temp_linearity_paper φ ψ
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

/-! ## Reflection-validity -/

/-- **Every TM⋆ schema's temporal dual is valid at its own minimum frame class.** One arm per
constructor; the semantic input to the `time_reflection` case of soundness. Each register arm
normalises `reflectTime` and lands on the matching validity lemma — the reflection-closure invariant
of `StarLanguage/Axioms.lean`, discharged constructor by constructor. -/
theorem starAxiom_reflect_time_validIn_min {φ : StarFormula} (ax : StarAxiom φ) :
    StarValidIn ax.minFrameClass φ.reflectTime := by
  cases ax with
  | prop_k φ ψ χ =>
    simp only [StarFormula.reflectTime]
    exact starValid_prop_k φ.reflectTime ψ.reflectTime χ.reflectTime
  | prop_s φ ψ =>
    simp only [StarFormula.reflectTime]
    exact starValid_prop_s φ.reflectTime ψ.reflectTime
  | ex_falso φ =>
    simp only [StarFormula.reflectTime]
    exact starValid_ex_falso φ.reflectTime
  | peirce φ ψ =>
    simp only [StarFormula.reflectTime]
    exact starValid_peirce φ.reflectTime ψ.reflectTime
  | modal_t φ =>
    simp only [StarFormula.reflectTime]
    exact starValid_modal_t φ.reflectTime
  | modal_4 φ =>
    simp only [StarFormula.reflectTime]
    exact starValid_modal_4 φ.reflectTime
  | modal_b φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_diamond]
    exact starValid_modal_b φ.reflectTime
  | modal_5_collapse φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_diamond]
    exact starValid_modal_5_collapse φ.reflectTime
  | modal_k_dist φ ψ =>
    simp only [StarFormula.reflectTime]
    exact starValid_modal_k_dist φ.reflectTime ψ.reflectTime
  | stab_k φ ψ =>
    simp only [StarFormula.reflectTime]
    exact starValid_stab_k φ.reflectTime ψ.reflectTime
  | stab_t φ =>
    simp only [StarFormula.reflectTime]
    exact starValid_stab_t φ.reflectTime
  | stab_4 φ =>
    simp only [StarFormula.reflectTime]
    exact starValid_stab_4 φ.reflectTime
  | stab_5 φ =>
    simp only [StarFormula.reflect_time_dstab, StarFormula.reflectTime]
    exact starValid_stab_5 φ.reflectTime
  | box_stab φ =>
    simp only [StarFormula.reflectTime]
    exact starValid_box_stab φ.reflectTime
  | atom_stab p =>
    simp only [StarFormula.reflectTime]
    exact starValid_atom_stab p
  | serial_future =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_some_future]
    exact starValid_serial_past_bare
  | serial_past =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_some_past]
    exact starValid_serial_future_imp
  | left_mono_until_G φ χ ψ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future]
    exact starValid_left_mono_since_H φ.reflectTime χ.reflectTime ψ.reflectTime
  | left_mono_since_H φ χ ψ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_past]
    exact starValid_left_mono_until_G φ.reflectTime χ.reflectTime ψ.reflectTime
  | right_mono_until φ ψ χ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future]
    exact starValid_right_mono_since φ.reflectTime ψ.reflectTime χ.reflectTime
  | right_mono_since φ ψ χ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_past]
    exact starValid_right_mono_until φ.reflectTime ψ.reflectTime χ.reflectTime
  | connect_future φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future,
      StarFormula.reflect_time_some_past]
    exact starValid_connect_past φ.reflectTime
  | connect_past φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_past,
      StarFormula.reflect_time_some_future]
    exact starValid_connect_future φ.reflectTime
  | enrichment_until φ ψ p =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflectTime]
    exact starValid_enrichment_since φ.reflectTime ψ.reflectTime p.reflectTime
  | enrichment_since φ ψ p =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflectTime]
    exact starValid_enrichment_until φ.reflectTime ψ.reflectTime p.reflectTime
  | self_accum_until φ ψ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflectTime]
    exact starValid_self_accum_since φ.reflectTime ψ.reflectTime
  | self_accum_since φ ψ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflectTime]
    exact starValid_self_accum_until φ.reflectTime ψ.reflectTime
  | absorb_until φ ψ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflectTime]
    exact starValid_absorb_since φ.reflectTime ψ.reflectTime
  | absorb_since φ ψ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflectTime]
    exact starValid_absorb_until φ.reflectTime ψ.reflectTime
  | linear_until φ ψ χ θ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflect_time_or,
      StarFormula.reflectTime]
    exact starValid_linear_since_paper φ.reflectTime ψ.reflectTime χ.reflectTime θ.reflectTime
  | linear_since φ ψ χ θ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflect_time_or,
      StarFormula.reflectTime]
    exact starValid_linear_until φ.reflectTime ψ.reflectTime χ.reflectTime θ.reflectTime
  | until_F φ ψ =>
    simp only [StarFormula.reflect_time_some_future, StarFormula.reflectTime]
    exact starValid_since_P φ.reflectTime ψ.reflectTime
  | since_P φ ψ =>
    simp only [StarFormula.reflect_time_some_past, StarFormula.reflectTime]
    exact starValid_until_F φ.reflectTime ψ.reflectTime
  | temp_linearity φ ψ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflect_time_or,
      StarFormula.reflect_time_some_future, StarFormula.reflectTime]
    exact starValid_temp_linearity_past_paper φ.reflectTime ψ.reflectTime
  | temp_linearity_past φ ψ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflect_time_or,
      StarFormula.reflect_time_some_past, StarFormula.reflectTime]
    exact starValid_temp_linearity φ.reflectTime ψ.reflectTime
  | F_until_equiv φ =>
    simp only [StarFormula.reflect_time_some_future, StarFormula.reflectTime]
    exact starValid_P_since_equiv φ.reflectTime
  | P_since_equiv φ =>
    simp only [StarFormula.reflect_time_some_past, StarFormula.reflectTime]
    exact starValid_F_until_equiv φ.reflectTime
  | discrete_symm_fwd =>
    simp only [StarFormula.reflectTime]
    exact starValid_discrete_symm_bwd
  | discrete_symm_bwd =>
    simp only [StarFormula.reflectTime]
    exact starValid_discrete_symm_fwd
  | discrete_propagate_fwd =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future]
    exact starValid_discrete_propagate_fwd_reflect_time
  | discrete_propagate_bwd =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_past]
    exact starValid_discrete_propagate_bwd_reflect_time
  | discrete_box_necessity =>
    simp only [StarFormula.reflectTime]
    exact starValid_discrete_box_necessity_reflect_time
  | density φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future]
    exact starValid_density_reflect_time φ.reflectTime
  | dense_indicator =>
    simp only [StarFormula.reflect_time_neg, StarFormula.reflectTime]
    exact starValid_dense_indicator_reflect_time
  | prior_UZ φ =>
    simp only [StarFormula.reflect_time_neg, StarFormula.reflect_time_some_future,
      StarFormula.reflectTime]
    exact starValid_prior_SZ φ.reflectTime
  | prior_SZ φ =>
    simp only [StarFormula.reflect_time_neg, StarFormula.reflect_time_some_past,
      StarFormula.reflectTime]
    exact starValid_prior_UZ φ.reflectTime
  | z1 φ =>
    simp only [StarFormula.reflect_time_all_future, StarFormula.reflect_time_some_future,
      StarFormula.reflectTime]
    exact starValid_z1_reflect_time φ.reflectTime
  | prior_U_gap φ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflect_time_or,
      StarFormula.reflect_time_neg, StarFormula.reflect_time_some_future,
      StarFormula.reflect_time_kPlus, StarFormula.reflect_time_top, StarFormula.reflectTime]
    exact starValid_prior_S_gap φ.reflectTime
  | prior_S_gap φ =>
    simp only [StarFormula.reflect_time_and, StarFormula.reflect_time_or,
      StarFormula.reflect_time_neg, StarFormula.reflect_time_some_past,
      StarFormula.reflect_time_kMinus, StarFormula.reflect_time_top, StarFormula.reflectTime]
    exact starValid_prior_U_gap φ.reflectTime
  | sep φ => exact starValid_sep_reflect_time φ
  | modal_future φ hφ => exact starValid_modal_future_reflect_time hφ
  | paste φ ψ hφ hψ =>
    simp only [StarFormula.reflect_time_dstab, StarFormula.reflect_time_and,
      StarFormula.reflectTime]
    exact starValid_paste_reflect_time hφ.reflectTime hψ.reflectTime
  | untl_paste α φ hα hφ =>
    simp only [StarFormula.reflect_time_dstab, StarFormula.reflectTime]
    exact starValid_untl_paste_reflect_time hα.reflectTime hφ.reflectTime
  | store_recall_same i φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_store_recall_same i φ.reflectTime
  | recall_store_same i φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_recall_store_same i φ.reflectTime
  | recall_recall i j φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_recall_recall i j φ.reflectTime
  | store_store_comm i j φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_store_store_comm i j φ.reflectTime
  | store_k i φ ψ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_store_k i φ.reflectTime ψ.reflectTime
  | recall_k i φ ψ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_recall_k i φ.reflectTime ψ.reflectTime
  | store_box i φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_store_box i φ.reflectTime
  | recall_box i φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_recall_box i φ.reflectTime
  | store_stab i φ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_store_stab i φ.reflectTime
  | store_atom i p =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflectTime]
    exact starValid_store_atom i p
  | recall_rigid_future i φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future]
    exact starValid_recall_rigid_past i φ.reflectTime
  | future_rigid_recall i φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_future]
    exact starValid_past_rigid_recall i φ.reflectTime
  | recall_rigid_past i φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_past]
    exact starValid_recall_rigid_future i φ.reflectTime
  | past_rigid_recall i φ =>
    simp only [StarFormula.reflectTime, StarFormula.reflect_time_all_past]
    exact starValid_future_rigid_recall i φ.reflectTime
  | recall_export_until i φ ψ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflect_time_and,
      StarFormula.reflect_time_top, StarFormula.reflectTime]
    exact starValid_recall_export_since i φ.reflectTime ψ.reflectTime
  | recall_export_since i φ ψ =>
    simp only [StarFormula.reflect_time_iff, StarFormula.reflect_time_and,
      StarFormula.reflect_time_top, StarFormula.reflectTime]
    exact starValid_recall_export_until i φ.reflectTime ψ.reflectTime

/-- Reflection-validity of a TM⋆ schema at any class admitting it. -/
theorem starAxiom_reflect_time_validIn {φ : StarFormula} {fc : FrameClass} (ax : StarAxiom φ)
    (h : ax.minFrameClass ≤ fc) : StarValidIn fc φ.reflectTime :=
  StarValidIn.mono h (starAxiom_reflect_time_validIn_min ax)

end FormalSystem.Metalogic.Conservativity
