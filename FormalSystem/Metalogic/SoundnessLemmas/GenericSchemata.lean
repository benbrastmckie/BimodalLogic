/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TruthClauses
import FormalSystem.Metalogic.SoundnessLemmas.DiscreteOrder
import FormalSystem.Metalogic.SoundnessLemmas.Separability

/-!
# The TM⁺ mirror schemata, stated once over the clause interface

`Semantics/ValidityLayer.lean` abstracts the validity layer over the truth relation at a point;
`Semantics/TruthClauses.lean` does the same for the *clause* layer. This module is the third
application of that pattern, one level up again: the **schemata** themselves — `prop_k`,
`modal_t`, `stab_4`, `linear_until`, `prior_UZ`, `sep`, … — stated once over
`[TruthEnv L]` plus whichever operator classes each one's proof actually consumes.

The motivation is measured, not speculative. `Metalogic/Conservativity/Star/StarAxiomValidity.lean`
proved the 53 TM⁺ mirror schemata directly against `StarTruthAt`, and
`Metalogic/Conservativity/Open/OpenAxiomValidity.lean` proved them a second time against
`OpenTruthAt`. Neither could reuse the L⁺ route: that one goes through
`Conservativity/Plus/Atomization.lean`, which rests on `stab_state_only`, and neither a stored-time
register nor an open-modal prefix is state-determined. Uniform substitution is unavailable too —
TM⁺ is not substitution-closed, via `PlusAxiom.atom_stab`. So the shared statement had to be made
somewhere, and the clause interface is where it can be made exactly once.

**The statements here are pointwise**, at `TruthEnv.T M τ t e …`, not validity-level. That is a
deliberate choice: the per-language validity wrappers already have a `Valid.of_forall`-shaped
introduction rule, so a wrapper is one line

```
StarValid.of_forall fun F M τ x v => generic_prop_k M τ x v φ ψ χ
```

for a language whose points carry an environment, and

```
Valid.of_forall fun F M τ x => generic_prop_k M τ x PUnit.unit φ ψ χ
```

for one whose points do not. Stating the schemata at validity level instead would have required a
bridge class relating `PointTruth` to `TruthEnv`, which nothing else in the tree needs.

## Main Results

- `generic_prop_k`, `generic_prop_s`, `generic_ex_falso`, `generic_peirce` — the propositional tier
- `generic_modal_t`, `generic_modal_4`, `generic_modal_b`, `generic_modal_5_collapse`,
  `generic_modal_k_dist` — the S5 `□` tier
- `generic_stab_k`, `generic_stab_t`, `generic_stab_4`, `generic_stab_5`, `generic_box_stab`,
  `generic_atom_stab` — the `⊡` tier, including AS over the atom clause

## Design Invariants — the extension contract

### Grain

Every lemma names exactly the operator classes its proof consumes, never a bundle — the same
invariant `TruthClauses.lean`'s own contract asserts, for the same reason: a language that lacks
`snce` should still be able to use the `untl` schemata.

### Attributes

The generic lemmas carry **no** attributes, and must not acquire any. Each per-language wrapper
keeps exactly the attributes it has today.

### What is NOT generic

The boundary is inherited from the two layers below, and is not a gap to be closed later:

* **The pasting schemata** (`paste`, `untl_paste` and their duals). They consume per-language
  purity predicates (`StarIsPureFuture`/`StarIsPurePast`, `IsPureFutureOpen`/`IsPurePastOpen`) and
  the per-language pasting congruences, every one of which is proved by `induction φ` — the exact
  boundary `ValidityLayer.lean`'s contract declares uninheritable. Their current bodies are already
  one line each, so nothing would be recovered.
* **Time shift.** `plusTruthAt_timeShift`, `starTruthAt_timeShift` and `openTruthAt_timeShift` are
  genuinely different statements: L⋆'s drags the stored-time vector along with the history, and
  L^▷'s needed a bespoke `openTruthAt_congr_ext`. `generic_modal_future` below therefore takes
  the homogeneity fact as an **explicit hypothesis** rather than a class field.
* **The register, restricted-modal and rigidity blocks.** `↓ⁱ`/`↑ⁱ` (L⋆) and `▷`/`◁` (L^▷) are
  not TM⁺ mirror schemata and have no shared clause class; L⋆'s two register operators are
  deliberately absent from `TruthClauses.lean` because they do *not* thread the environment inert.
* **L's collected `always_iff`.** Collapsing the three temporal cases needs the frame's
  trichotomy, which no generic lemma has.

## References

* `FormalSystem/Semantics/TruthClauses.lean` — the clause layer these schemata are stated over
* `FormalSystem/Semantics/ValidityLayer.lean` — the validity layer, and the original statement of
  the extension contract this module follows
* `FormalSystem/Metalogic/Conservativity/Star/StarAxiomValidity.lean` — the L⋆ transcriptions
  these statements were read off, and the first consumer

## Tags

soundness · axiom-schemata · abstraction · typeclass · extension-contract
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Semantics.TruthClauses
open FormalSystem.Syntax.Sig

variable {L : Type} [TruthEnv L] [HasImp L] [ImpClause L] {F : TaskFrame}

/-! `[HasBot L] [BotClause L]` is deliberately **not** a module-level section variable: a lemma
whose statement mentions `neg`, `top`, `and`, `or`, `diamond` or `dstab` takes it as its own
binder, and one that does not is stated without it. That is the grain invariant
`Semantics/TruthClauses.lean`'s contract asks for, checked here by the compiler's
`unusedSectionVars` linter rather than by inspection. -/

/-!
## The propositional tier

Transcriptions of `StarAxiomValidity.lean`'s `starValid_prop_k`–`starValid_peirce` under the
substitution `StarTruthAt M τ t v ↦ TruthEnv.T M τ t e`.
-/

section Propositional

/-- Propositional K, stated once. -/
theorem generic_prop_k (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasImp.imp φ (HasImp.imp ψ χ))
        (HasImp.imp (HasImp.imp φ ψ) (HasImp.imp φ χ))) := by
  simp only [ImpClause.imp_clause]
  exact fun h1 h2 h3 => h1 h3 (h2 h3)

/-- Propositional S (weakening), stated once. -/
theorem generic_prop_s (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (HasImp.imp φ (HasImp.imp ψ φ)) := by
  simp only [ImpClause.imp_clause]
  exact fun h _ => h

/-- Ex falso quodlibet, from the `bot` clause alone. -/
theorem generic_ex_falso [HasBot L] [BotClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasBot.bot : L) φ) := by
  rw [ImpClause.imp_clause]
  exact fun h => absurd h (BotClause.bot_clause M τ t e)

/-- Peirce's law, by classical case analysis on `φ`. -/
theorem generic_peirce (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasImp.imp (HasImp.imp φ ψ) φ) φ) := by
  simp only [ImpClause.imp_clause]
  intro h
  by_cases hφ : TruthEnv.T M τ t e φ
  · exact hφ
  · exact h fun hp => absurd hp hφ

end Propositional

/-!
## The S5 `□` tier

`□` quantifies over *all* world histories at the current time, with no accessibility relation, so
T, 4, B and the 5-collapse are each one step off the clause.
-/

section Modal
variable [HasBox L] [BoxClause L]

/-- Modal T: the evaluation history is itself a world history, so `□` reflects. -/
theorem generic_modal_t (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasBox.box φ) φ) := by
  rw [ImpClause.imp_clause, BoxClause.box_clause]
  exact fun h => h τ

/-- Modal 4: the `box` clause quantifies over every world history, so it is idempotent. -/
theorem generic_modal_4 (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasBox.box φ) (HasBox.box (HasBox.box φ))) := by
  simp only [ImpClause.imp_clause, BoxClause.box_clause]
  exact fun h _ => h

/-- Modal B, through `diamond_iff` at the witness `τ`. -/
theorem generic_modal_b [HasBot L] [BotClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp φ (HasBox.box (diamond φ))) := by
  rw [ImpClause.imp_clause, BoxClause.box_clause]
  intro h σ
  rw [diamond_iff]
  exact ⟨τ, h⟩

/-- Modal 5 collapse: `◇□φ → □φ`. -/
theorem generic_modal_5_collapse [HasBot L] [BotClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (diamond (HasBox.box φ)) (HasBox.box φ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [diamond_iff] at h
  obtain ⟨_, hb⟩ := h
  rw [BoxClause.box_clause] at hb ⊢
  exact hb

/-- Modal K distribution. -/
theorem generic_modal_k_dist (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasBox.box (HasImp.imp φ ψ))
        (HasImp.imp (HasBox.box φ) (HasBox.box ψ))) := by
  simp only [ImpClause.imp_clause, BoxClause.box_clause]
  exact fun h1 h2 σ => h1 σ (h2 σ)

end Modal

/-!
## The `⊡` tier

The stability modal quantifies over the world histories agreeing with the present one *in state at
the present time*, so its S5 package is the reflexivity, transitivity and symmetry of the plain
state equation `τ.state t = σ.state t`.
-/

section Stab
variable [HasStab L] [StabClause L]

/-- SK: K for `⊡`, from the universal-quantifier shape of the `stab` clause. -/
theorem generic_stab_k (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasStab.stab (HasImp.imp φ ψ))
        (HasImp.imp (HasStab.stab φ) (HasStab.stab ψ))) := by
  simp only [ImpClause.imp_clause, StabClause.stab_clause]
  exact fun h1 h2 σ hs => h1 σ hs (h2 σ hs)

/-- ST: state equality is reflexive. -/
theorem generic_stab_t (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasStab.stab φ) φ) := by
  rw [ImpClause.imp_clause, StabClause.stab_clause]
  exact fun h => h τ rfl

/-- S4 for `⊡`: state equality at a fixed time is transitive. -/
theorem generic_stab_4 (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasStab.stab φ) (HasStab.stab (HasStab.stab φ))) := by
  simp only [ImpClause.imp_clause, StabClause.stab_clause]
  intro h σ hσ ρ hρ
  exact h ρ (hσ.trans hρ)

/-- S5 for `⊡`: state equality at a fixed time is symmetric. -/
theorem generic_stab_5 [HasBot L] [BotClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (dstab φ) (HasStab.stab (dstab φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [StabClause.stab_clause]
  intro σ hσ
  rw [dstab_iff] at h ⊢
  obtain ⟨ρ, hρ, hφ⟩ := h
  exact ⟨ρ, hσ.symm.trans hρ, hφ⟩

end Stab

section BoxStab
variable [HasBox L] [BoxClause L] [HasStab L] [StabClause L]

/-- MS: the same-state histories are a subfamily of all of them, so `□` is stronger than `⊡`. -/
theorem generic_box_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasBox.box φ) (HasStab.stab φ)) := by
  rw [ImpClause.imp_clause, BoxClause.box_clause, StabClause.stab_clause]
  exact fun h σ _ => h σ

end BoxStab

section AtomStab
variable [AtomClause L] [HasStab L] [StabClause L]

/-- AS, stated once: the atom clause reads the world state alone, which the `stab` clause fixes.

This is the schema that makes TM⁺ non-substitution-closed, and the reason the L⁺ atomization
route cannot be reused by L⋆ or L^▷. Over the clause interface it is three lines, because
`AtomClause.atom_clause` is exactly the statement that an atom is state-local. -/
theorem generic_atom_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (p : Atom) :
    TruthEnv.T M τ t e
      (HasImp.imp (AtomClause.atom p) (HasStab.stab (AtomClause.atom p))) := by
  rw [ImpClause.imp_clause, StabClause.stab_clause]
  intro h σ hs
  rw [AtomClause.atom_clause] at h ⊢
  rw [← hs]
  exact h

end AtomStab

/-!
## Seriality

The temporal order is nontrivial in both directions — `exists_gt`/`exists_lt` on
`F.Duration` — and that, not any frame constraint, is the whole content of the two seriality
schemata. **Measured correction to the plan's hypothesis**: `[F.IsRegular]` is *not* consumed
here. The L-level `serial_future_axiom_valid` (`Metalogic/Soundness.lean`) is likewise introduced
by `Valid.of_forall`, with no regularity, and closes on `exists_gt t`; the per-language `⊤`-guarded
forms use `of_forall_regular` only as a binder shape. The four lemmas below are therefore stated
without a regularity binder, which is strictly stronger and still serves every wrapper that has
one.
-/

section Seriality
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L]

omit [BotClause L] in
/-- TS, bare: `F⊤`. The order has no maximum. -/
theorem generic_serial_future (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (someFuture (top : L)) := by
  rw [someFuture_iff]
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, top_true M τ s e⟩

omit [BotClause L] in
/-- `⊤ → F⊤`: `generic_serial_future` under a trivially true antecedent. -/
theorem generic_serial_future_imp (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (HasImp.imp (top : L) (someFuture (top : L))) := by
  rw [ImpClause.imp_clause]
  exact fun _ => generic_serial_future M τ t e

end Seriality

section SerialityPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L]

omit [BotClause L] in
/-- `⊤ → P⊤`. The order has no minimum. -/
theorem generic_serial_past (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (HasImp.imp (top : L) (somePast (top : L))) := by
  rw [ImpClause.imp_clause, somePast_iff]
  intro _
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, top_true M τ s e⟩

omit [BotClause L] in
/-- `P⊤`, bare: `generic_serial_past` at the true antecedent. -/
theorem generic_serial_past_bare (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (somePast (top : L)) :=
  ((ImpClause.imp_clause M τ t e _ _).mp (generic_serial_past M τ t e)) (top_true M τ t e)

end SerialityPast

/-!
## Monotonicity of `U` and `S`, and the two connection schemata

Transcriptions of `StarAxiomValidity.lean`'s `starValid_left_mono_until_G`–
`starValid_connect_past`. Each is the clause family followed by one `rintro`; no frame constraint
and no order fact beyond transitivity enters.
-/

section MonoFuture
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L]

/-- BX2G: the guard of an `until` may be weakened under `G`. -/
theorem generic_left_mono_until_G (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ χ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (allFuture (HasImp.imp φ χ))
        (HasImp.imp (HasUntl.untl φ ψ) (HasUntl.untl χ ψ))) := by
  rw [ImpClause.imp_clause]
  intro h_G
  rw [allFuture_iff] at h_G
  rw [ImpClause.imp_clause]
  simp only [UntlClause.untl_clause]
  rintro ⟨s, hts, h_event, h_guard⟩
  refine ⟨s, hts, h_event, fun r htr hrs => ?_⟩
  exact ((ImpClause.imp_clause M τ r e φ χ).mp (h_G r htr)) (h_guard r htr hrs)

/-- BX3: the event of an `until` may be weakened under `G`. -/
theorem generic_right_mono_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (allFuture (HasImp.imp φ ψ))
        (HasImp.imp (HasUntl.untl χ φ) (HasUntl.untl χ ψ))) := by
  rw [ImpClause.imp_clause]
  intro h_G
  rw [allFuture_iff] at h_G
  rw [ImpClause.imp_clause]
  simp only [UntlClause.untl_clause]
  rintro ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, ((ImpClause.imp_clause M τ s e φ ψ).mp (h_G s hts)) h_event, h_guard⟩

end MonoFuture

section MonoPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L]

/-- BX2H, the past mirror of `generic_left_mono_until_G`. -/
theorem generic_left_mono_since_H (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ χ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (allPast (HasImp.imp φ χ))
        (HasImp.imp (HasSnce.snce φ ψ) (HasSnce.snce χ ψ))) := by
  rw [ImpClause.imp_clause]
  intro h_H
  rw [allPast_iff] at h_H
  rw [ImpClause.imp_clause]
  simp only [SnceClause.snce_clause]
  rintro ⟨s, hst, h_event, h_guard⟩
  refine ⟨s, hst, h_event, fun r hsr hrt => ?_⟩
  exact ((ImpClause.imp_clause M τ r e φ χ).mp (h_H r hrt)) (h_guard r hsr hrt)

/-- BX3', the past mirror of `generic_right_mono_until`. -/
theorem generic_right_mono_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (allPast (HasImp.imp φ ψ))
        (HasImp.imp (HasSnce.snce χ φ) (HasSnce.snce χ ψ))) := by
  rw [ImpClause.imp_clause]
  intro h_H
  rw [allPast_iff] at h_H
  rw [ImpClause.imp_clause]
  simp only [SnceClause.snce_clause]
  rintro ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, ((ImpClause.imp_clause M τ s e φ ψ).mp (h_H s hst)) h_event, h_guard⟩

end MonoPast

section Connection
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L] [HasSnce L] [SnceClause L]

/-- BX4: what is true now is always going to have been true. -/
theorem generic_connect_future (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp φ (allFuture (somePast φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allFuture_iff]
  intro s hts
  rw [somePast_iff]
  exact ⟨t, hts, h⟩

/-- BX4', the past mirror of `generic_connect_future`. -/
theorem generic_connect_past (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp φ (allPast (someFuture φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allPast_iff]
  intro s hst
  rw [someFuture_iff]
  exact ⟨t, hst, h⟩

end Connection

/-!
## Enrichment, self-accumulation, absorption, and `U`/`S` linearity

The heaviest of the BX groups. Each proof is the clause family followed by `rintro` and, where two
witnesses must be compared, `rcases lt_trichotomy`.

**On the shape of the tactic blocks.** `and`, `or`, `top` and `neg` are `abbrev`s here, hence
*reducible*, so `ImpClause.imp_clause` matches straight through them and will consume an `and` or
`or` term before `and_iff`/`or_iff` can fire. (`StarTruth`'s counterparts do not have this problem:
`StarFormula.and` is a plain `def`.) Every block below therefore peels the outermost implication
with a single `rw [ImpClause.imp_clause]` and hands the rest to a `simp only` that does **not**
mention `imp_clause`.

**All four linearity variants exist on purpose.** `OpenAxiom.linear_until` takes the paper's
right-associated nesting `or A (or B C)` while `OpenAxiom.linear_since` takes the left-associated
`or (or A B) C`; `StarAxiom` carries both. The four lemmas below supply both nestings on both
sides, so that **no language's statement is re-associated by this layer**. The distinction here is
genuine *nesting*; the temporal-linearity pair in the next section differs in disjunct *order*
instead, and the two axes should not be conflated.
-/

section Enrichment
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L] [HasSnce L] [SnceClause L]

/-- BX13: an `until` may be enriched with a `since` back to the present. -/
theorem generic_enrichment_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ p : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and p (HasUntl.untl φ ψ))
        (HasUntl.untl φ (and ψ (HasSnce.snce φ p)))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause, SnceClause.snce_clause]
  rintro ⟨h_pt, s, hts, h_ψs, h_guard⟩
  exact ⟨s, hts, ⟨h_ψs, t, hts, h_pt, h_guard⟩, h_guard⟩

/-- BX13', the past mirror of `generic_enrichment_until`. -/
theorem generic_enrichment_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ p : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and p (HasSnce.snce φ ψ))
        (HasSnce.snce φ (and ψ (HasUntl.untl φ p)))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause, SnceClause.snce_clause]
  rintro ⟨h_pt, s, hst, h_ψs, h_guard⟩
  exact ⟨s, hst, ⟨h_ψs, t, hst, h_pt, h_guard⟩, h_guard⟩

end Enrichment

section AccumFuture
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L]

/-- BX5: the guard of an `until` may absorb the `until` itself. -/
theorem generic_self_accum_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasUntl.untl φ ψ)
        (HasUntl.untl (and φ (HasUntl.untl φ ψ)) ψ)) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause]
  rintro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs => ⟨h_guard r htr hrs, ?_⟩⟩
  exact ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX6, the converse direction: the absorbed `until` may be discharged again. -/
theorem generic_absorb_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasUntl.untl φ (and φ (HasUntl.untl φ ψ)))
        (HasUntl.untl φ ψ)) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause]
  rintro ⟨s₁, hts₁, ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₁ q htq h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q h_gt hqs₂

/-- BX7: linearity of `until`, **left-associated** (`StarAxiom.linear_until`'s own nesting as
`starValid_linear_until` states it), by trichotomy on the two witnesses. -/
theorem generic_linear_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ θ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (HasUntl.untl φ ψ) (HasUntl.untl χ θ))
        (or (or (HasUntl.untl (and φ χ) (and ψ θ))
              (HasUntl.untl (and φ χ) (and ψ χ)))
          (HasUntl.untl (and φ χ) (and φ θ)))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, UntlClause.untl_clause]
  rintro ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · exact .inl (.inr ⟨s₁, hts₁, ⟨h_ψs₁, h_guard₂ s₁ hts₁ h_lt⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (lt_trans hrs h_lt)⟩⟩)
  · exact .inl (.inl ⟨s₁, hts₁, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (h_eq ▸ hrs)⟩⟩)
  · exact .inr ⟨s₂, hts₂, ⟨h_guard₁ s₂ hts₂ h_gt, h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr (lt_trans hrs h_gt), h_guard₂ r htr hrs⟩⟩

/-- The paper's CN, **right-associated** (`OpenAxiom.linear_until`'s nesting). -/
theorem generic_linear_until_paper (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ θ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (HasUntl.untl φ ψ) (HasUntl.untl χ θ))
        (or (HasUntl.untl (and φ χ) (and ψ θ))
          (or (HasUntl.untl (and φ χ) (and ψ χ))
            (HasUntl.untl (and φ χ) (and φ θ))))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, UntlClause.untl_clause]
  rintro ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · exact .inr (.inl ⟨s₁, hts₁, ⟨h_ψs₁, h_guard₂ s₁ hts₁ h_lt⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (lt_trans hrs h_lt)⟩⟩)
  · exact .inl ⟨s₁, hts₁, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr hrs, h_guard₂ r htr (h_eq ▸ hrs)⟩⟩
  · exact .inr (.inr ⟨s₂, hts₂, ⟨h_guard₁ s₂ hts₂ h_gt, h_θs₂⟩,
      fun r htr hrs => ⟨h_guard₁ r htr (lt_trans hrs h_gt), h_guard₂ r htr hrs⟩⟩)

end AccumFuture

section AccumPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L]

/-- BX5', the past mirror of `generic_self_accum_until`. -/
theorem generic_self_accum_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasSnce.snce φ ψ)
        (HasSnce.snce (and φ (HasSnce.snce φ ψ)) ψ)) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, SnceClause.snce_clause]
  rintro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt => ⟨h_guard r hsr hrt, ?_⟩⟩
  exact ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

/-- BX6', the past mirror of `generic_absorb_until`. -/
theorem generic_absorb_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasSnce.snce φ (and φ (HasSnce.snce φ ψ)))
        (HasSnce.snce φ ψ)) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, SnceClause.snce_clause]
  rintro ⟨s₁, hs₁t, ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩, h_guard₁⟩
  refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
  rcases lt_trichotomy s₁ q with h_lt | h_eq | h_gt
  · exact h_guard₁ q h_lt hqt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q hs₂q h_gt

/-- BX7', **left-associated** (`OpenAxiom.linear_since`'s nesting). -/
theorem generic_linear_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ θ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (HasSnce.snce φ ψ) (HasSnce.snce χ θ))
        (or (or (HasSnce.snce (and φ χ) (and ψ θ))
              (HasSnce.snce (and φ χ) (and ψ χ)))
          (HasSnce.snce (and φ χ) (and φ θ)))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, SnceClause.snce_clause]
  rintro ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₂ s₁ with h_lt | h_eq | h_gt
  · exact .inl (.inr ⟨s₁, hs₁t, ⟨h_ψs₁, h_guard₂ s₁ h_lt hs₁t⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (lt_trans h_lt hs₁r) hrt⟩⟩)
  · exact .inl (.inl ⟨s₁, hs₁t, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (h_eq ▸ hs₁r) hrt⟩⟩)
  · exact .inr ⟨s₂, hs₂t, ⟨h_guard₁ s₂ h_gt hs₂t, h_θs₂⟩,
      fun r hs₂r hrt => ⟨h_guard₁ r (lt_trans h_gt hs₂r) hrt, h_guard₂ r hs₂r hrt⟩⟩

/-- The time reflection of the paper's CN: Since linearity, **right-associated**. -/
theorem generic_linear_since_paper (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ θ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (HasSnce.snce φ ψ) (HasSnce.snce χ θ))
        (or (HasSnce.snce (and φ χ) (and ψ θ))
          (or (HasSnce.snce (and φ χ) (and ψ χ))
            (HasSnce.snce (and φ χ) (and φ θ))))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, SnceClause.snce_clause]
  rintro ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩
  rcases lt_trichotomy s₂ s₁ with h_lt | h_eq | h_gt
  · exact .inr (.inl ⟨s₁, hs₁t, ⟨h_ψs₁, h_guard₂ s₁ h_lt hs₁t⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (lt_trans h_lt hs₁r) hrt⟩⟩)
  · exact .inl ⟨s₁, hs₁t, ⟨h_ψs₁, h_eq ▸ h_θs₂⟩,
      fun r hs₁r hrt => ⟨h_guard₁ r hs₁r hrt, h_guard₂ r (h_eq ▸ hs₁r) hrt⟩⟩
  · exact .inr (.inr ⟨s₂, hs₂t, ⟨h_guard₁ s₂ h_gt hs₂t, h_θs₂⟩,
      fun r hs₂r hrt => ⟨h_guard₁ r (lt_trans h_gt hs₂r) hrt, h_guard₂ r hs₂r hrt⟩⟩)

end AccumPast

/-!
## `until_F`/`since_P`, temporal linearity, and the two `F`/`P` equivalences

**The two TL variants differ in disjunct *order*, not nesting.** Both
`generic_temp_linearity` and `generic_temp_linearity_paper` are right-associated,
`or A (or B C)`; what differs is which of the three disjuncts is `A`. That is a different axis
from the CN/BX7 pair of the previous section, which differs in genuine association. Conflating the
two is the slip this note exists to prevent, and both axes are supplied on both sides so that no
language's statement is restated by this layer.

A second ordering trap, internal to the tactic blocks: `someFuture φ` is `untl top φ`, so
`UntlClause.untl_clause` matches a `someFuture` term too. Where a statement carries both operators
the `someFuture_iff`/`somePast_iff` rewrite is therefore applied first, by hand, and never handed
to the same `simp only` as the primitive clause.
-/

section LinearityFuture
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L]

omit [BotClause L] in
/-- BX10: an `until` witness is a future witness. -/
theorem generic_until_F (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasUntl.untl φ ψ) (someFuture ψ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [someFuture_iff]
  rw [UntlClause.untl_clause] at h
  obtain ⟨s, hts, h_ψs, -⟩ := h
  exact ⟨s, hts, h_ψs⟩

omit [BotClause L] in
/-- BX12: `F` is `U` at the trivial guard. -/
theorem generic_F_until_equiv (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (someFuture φ) (HasUntl.untl (top : L) φ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [someFuture_iff] at h
  rw [UntlClause.untl_clause]
  obtain ⟨s, hts, h_φs⟩ := h
  exact ⟨s, hts, h_φs, fun r _ _ => top_true M τ r e⟩

/-- BX11: two future witnesses are ordered, by trichotomy. -/
theorem generic_temp_linearity (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (someFuture φ) (someFuture ψ))
        (or (someFuture (and φ ψ))
          (or (someFuture (and φ (someFuture ψ)))
            (someFuture (and (someFuture φ) ψ))))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, someFuture_iff]
  rintro ⟨⟨s₁, hts₁, hφ⟩, s₂, hts₂, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inl ⟨s₁, hts₁, hφ, s₂, h, hψ⟩)
  · exact .inl ⟨s₁, hts₁, hφ, h ▸ hψ⟩
  · exact .inr (.inr ⟨s₂, hts₂, ⟨s₁, h, hφ⟩, hψ⟩)

/-- The paper's TL, in the disjunct order `OpenAxiom.temp_linearity` declares. -/
theorem generic_temp_linearity_paper (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (someFuture φ) (someFuture ψ))
        (or (someFuture (and (someFuture φ) ψ))
          (or (someFuture (and φ ψ))
            (someFuture (and φ (someFuture ψ)))))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, someFuture_iff]
  rintro ⟨⟨s₁, hts₁, hφ⟩, s₂, hts₂, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inr ⟨s₁, hts₁, hφ, s₂, h, hψ⟩)
  · exact .inr (.inl ⟨s₁, hts₁, hφ, h ▸ hψ⟩)
  · exact .inl ⟨s₂, hts₂, ⟨s₁, h, hφ⟩, hψ⟩

end LinearityFuture

section LinearityPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L]

omit [BotClause L] in
/-- BX10', the past mirror of `generic_until_F`. -/
theorem generic_since_P (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (HasImp.imp (HasSnce.snce φ ψ) (somePast ψ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [somePast_iff]
  rw [SnceClause.snce_clause] at h
  obtain ⟨s, hst, h_ψs, -⟩ := h
  exact ⟨s, hst, h_ψs⟩

omit [BotClause L] in
/-- BX12', the past mirror of `generic_F_until_equiv`. -/
theorem generic_P_since_equiv (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (somePast φ) (HasSnce.snce (top : L) φ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [somePast_iff] at h
  rw [SnceClause.snce_clause]
  obtain ⟨s, hst, h_φs⟩ := h
  exact ⟨s, hst, h_φs, fun r _ _ => top_true M τ r e⟩

/-- BX11', the past mirror of `generic_temp_linearity`. -/
theorem generic_temp_linearity_past (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (somePast φ) (somePast ψ))
        (or (somePast (and φ ψ))
          (or (somePast (and φ (somePast ψ)))
            (somePast (and (somePast φ) ψ))))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, somePast_iff]
  rintro ⟨⟨s₁, hs₁t, hφ⟩, s₂, hs₂t, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inr (.inr ⟨s₂, hs₂t, ⟨s₁, h, hφ⟩, hψ⟩)
  · exact .inl ⟨s₁, hs₁t, hφ, h ▸ hψ⟩
  · exact .inr (.inl ⟨s₁, hs₁t, hφ, s₂, h, hψ⟩)

/-- The time reflection of the paper's TL, in the disjunct order
`OpenAxiom.temp_linearity_past` declares. -/
theorem generic_temp_linearity_past_paper (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (somePast φ) (somePast ψ))
        (or (somePast (and (somePast φ) ψ))
          (or (somePast (and φ ψ))
            (somePast (and φ (somePast ψ)))))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, or_iff, somePast_iff]
  rintro ⟨⟨s₁, hs₁t, hφ⟩, s₂, hs₂t, hψ⟩
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · exact .inl ⟨s₂, hs₂t, ⟨s₁, h, hφ⟩, hψ⟩
  · exact .inr (.inl ⟨s₁, hs₁t, hφ, h ▸ hψ⟩)
  · exact .inr (.inr ⟨s₁, hs₁t, hφ, s₂, h, hψ⟩)

end LinearityPast

/-!
## Discrete uniformity, density, Prior-Z and Z1

**The frame-class side conditions are instance binders on `F.Duration`, not transports.** Both
`StarAxiomValidity.lean` and `OpenAxiomValidity.lean` close the five uniformity arms by
transporting `plusAxiom_validIn_min` along their `ofPlus` embeddings, which is cheap for them but
useless to a language with no such embedding. Stated here, each is what it actually is: a fact
about the duration group's order, with the gap-translation argument written once.

**Measured correction to the plan's hypothesis for this group.** The five uniformity schemata are
valid at `FrameClass.Base` — `Metalogic/Soundness.lean`'s `discrete_symm_fwd_valid` and siblings
are introduced by `Valid.of_forall`, with no frame class and no regularity. The only structure
they consume is that `F.Duration` is a nontrivial linearly ordered abelian group, which every
`TemporalOrder` already is. So there is no frame-constraint binder to add for them; the binders
appear exactly where the frame class is real — `[DenselyOrdered F.Duration]` for density,
`[SuccOrder]`/`[IsSuccArchimedean]` (and their `Pred` mirrors) for Prior-Z and Z1.

The order-theoretic content is **not** inlined: Prior-Z goes through
`SoundnessLemmas.exists_nearest_gt`/`exists_nearest_lt` and Z1 through
`forall_gt_of_succ_step`/`forall_lt_of_pred_step`, each at `P := fun x => TruthEnv.T M τ x e φ`.

**The two consumers' sets of named duals differ, and both are covered.** The group is not closed
under `reflectTime` — the dual of `U(⊤,⊥) → G(U(⊤,⊥))` is `S(⊤,⊥) → H(S(⊤,⊥))`, which is no
member's statement — so `StarAxiomValidity.lean` names three duals explicitly
(`discrete_propagate_fwd_reflect_time`, `discrete_propagate_bwd_reflect_time`,
`discrete_box_necessity_reflect_time`) while `OpenAxiomValidity.lean` instead produces all five
reflections mechanically through `openValid_reflectTime`, giving it two names Star has none for
(`discreteSymmFwd_reflect`, `discreteSymmBwd_reflect`). The sixteen lemmas here are stated per
*distinct statement*, which covers both sets: the two `symm` reflections are the other `symm`
lemma's statement, so they need no separate generic form.
-/

section Gap
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L]

/-- `U(⊥,⊤)` at `t` says there is a point strictly above `t` with nothing strictly between: the
guard `⊥` forbids every intruder and the event `⊤` is free. -/
theorem generic_gap_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (HasUntl.untl (HasBot.bot : L) top) ↔
      ∃ s : F.Duration, t < s ∧ ∀ r : F.Duration, t < r → r < s → False := by
  rw [UntlClause.untl_clause]
  constructor
  · rintro ⟨s, hts, -, hguard⟩
    exact ⟨s, hts, fun r h1 h2 => BotClause.bot_clause M τ r e (hguard r h1 h2)⟩
  · rintro ⟨s, hts, hguard⟩
    exact ⟨s, hts, top_true M τ s e, fun r h1 h2 => (hguard r h1 h2).elim⟩

/-- **Gaps translate.** A gap immediately above `t` is a gap immediately above every point: shift
the witness by `u - t` and shift any intruder back. Translation invariance of `<` on the duration
group is the whole argument, which is why the statement mentions no history and no model, exactly
as `Semantics/Truth.lean`'s `truthAt_gap_shift` does not. -/
theorem generic_gap_shift (M : TaskModel F) (τ : WorldHistory F) (t u : F.Duration)
    (e : TruthEnv.Env L F)
    (h : TruthEnv.T M τ t e (HasUntl.untl (HasBot.bot : L) top)) :
    TruthEnv.T M τ u e (HasUntl.untl (HasBot.bot : L) top) := by
  rw [generic_gap_iff] at h ⊢
  obtain ⟨s, hts, hguard⟩ := h
  refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun c huc hcs => ?_⟩
  have h1 : t < c - (u - t) := by
    conv_lhs => rw [(sub_sub_cancel u t).symm]
    exact sub_lt_sub_right huc _
  have h2 : c - (u - t) < s := by
    conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
    exact sub_lt_sub_right hcs _
  exact hguard (c - (u - t)) h1 h2

/-- `U(⊤,⊥) → G(U(⊤,⊥))`: a gap above `t` is a gap above every later point. -/
theorem generic_discrete_propagate_fwd (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasUntl.untl (HasBot.bot : L) top)
        (allFuture (HasUntl.untl (HasBot.bot : L) top))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allFuture_iff]
  exact fun u _ => generic_gap_shift M τ t u e h

end Gap

section Cogap
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L]

/-- `S(⊥,⊤)` at `t`: the past mirror of `generic_gap_iff`. -/
theorem generic_cogap_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (HasSnce.snce (HasBot.bot : L) top) ↔
      ∃ s : F.Duration, s < t ∧ ∀ r : F.Duration, s < r → r < t → False := by
  rw [SnceClause.snce_clause]
  constructor
  · rintro ⟨s, hst, -, hguard⟩
    exact ⟨s, hst, fun r h1 h2 => BotClause.bot_clause M τ r e (hguard r h1 h2)⟩
  · rintro ⟨s, hst, hguard⟩
    exact ⟨s, hst, top_true M τ s e, fun r h1 h2 => (hguard r h1 h2).elim⟩

/-- Co-gaps translate, the past mirror of `generic_gap_shift`. -/
theorem generic_cogap_shift (M : TaskModel F) (τ : WorldHistory F) (t u : F.Duration)
    (e : TruthEnv.Env L F)
    (h : TruthEnv.T M τ t e (HasSnce.snce (HasBot.bot : L) top)) :
    TruthEnv.T M τ u e (HasSnce.snce (HasBot.bot : L) top) := by
  rw [generic_cogap_iff] at h ⊢
  obtain ⟨s, hst, hguard⟩ := h
  refine ⟨u - (t - s), sub_lt_self u (sub_pos.mpr hst), fun c huc hcu => ?_⟩
  have h1 : s < c + (t - u) := by
    calc s = u - (t - s) + (t - u) := by rw [sub_add_sub_cancel', sub_sub_cancel]
      _ < c + (t - u) := add_lt_add_left huc (t - u)
  have h2 : c + (t - u) < t := by
    calc c + (t - u) < u + (t - u) := add_lt_add_left hcu (t - u)
      _ = t := by rw [add_comm, sub_add_cancel]
  exact hguard (c + (t - u)) h1 h2

/-- The temporal dual of `generic_discrete_propagate_fwd`: `S(⊤,⊥) → H(S(⊤,⊥))`. Not an instance
of any schema, so it is named here, mirroring
`SoundnessLemmas.discrete_propagate_fwd_reflect_time_valid`. -/
theorem generic_discrete_propagate_fwd_reflect_time (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasSnce.snce (HasBot.bot : L) top)
        (allPast (HasSnce.snce (HasBot.bot : L) top))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allPast_iff]
  exact fun u _ => generic_cogap_shift M τ t u e h

end Cogap

section GapMixed
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L] [HasSnce L] [SnceClause L]

/-- **A gap above is a gap below.** Reflect the witness through `t`. Its two directions are what
make the two `discrete_symm_*` schemata one term each. -/
theorem generic_gap_iff_cogap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (HasUntl.untl (HasBot.bot : L) top) ↔
      TruthEnv.T M τ t e (HasSnce.snce (HasBot.bot : L) top) := by
  rw [generic_gap_iff, generic_cogap_iff]
  constructor
  · rintro ⟨s, hts, hguard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact hguard (c + (s - t)) h1 h2
  · rintro ⟨r, hrt, hguard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact hguard (c - (t - r)) h1 h2

/-- `U(⊤,⊥) → S(⊤,⊥)`. -/
theorem generic_discrete_symm_fwd (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasUntl.untl (HasBot.bot : L) top)
        (HasSnce.snce (HasBot.bot : L) top)) := by
  rw [ImpClause.imp_clause]
  exact fun h => (generic_gap_iff_cogap M τ t e).mp h

/-- `S(⊤,⊥) → U(⊤,⊥)`. -/
theorem generic_discrete_symm_bwd (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasSnce.snce (HasBot.bot : L) top)
        (HasUntl.untl (HasBot.bot : L) top)) := by
  rw [ImpClause.imp_clause]
  exact fun h => (generic_gap_iff_cogap M τ t e).mpr h

/-- `U(⊤,⊥) → H(U(⊤,⊥))`. -/
theorem generic_discrete_propagate_bwd (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasUntl.untl (HasBot.bot : L) top)
        (allPast (HasUntl.untl (HasBot.bot : L) top))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allPast_iff]
  exact fun u _ => generic_gap_shift M τ t u e h

/-- The temporal dual of `generic_discrete_propagate_bwd`: `S(⊤,⊥) → G(S(⊤,⊥))`. -/
theorem generic_discrete_propagate_bwd_reflect_time (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasSnce.snce (HasBot.bot : L) top)
        (allFuture (HasSnce.snce (HasBot.bot : L) top))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allFuture_iff]
  exact fun u _ => generic_cogap_shift M τ t u e h

end GapMixed

section GapBox
variable [HasBot L] [BotClause L] [HasBox L] [BoxClause L] [HasUntl L] [UntlClause L]

/-- `U(⊤,⊥) → □(U(⊤,⊥))`: the gap is a fact about the duration order, so it holds at every world
history. `generic_gap_iff`'s right-hand side mentions no history, which is the whole proof. -/
theorem generic_discrete_box_necessity (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasUntl.untl (HasBot.bot : L) top)
        (HasBox.box (HasUntl.untl (HasBot.bot : L) top))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [BoxClause.box_clause]
  rw [generic_gap_iff] at h
  exact fun σ => (generic_gap_iff M σ t e).mpr h

end GapBox

section CogapBox
variable [HasBot L] [BotClause L] [HasBox L] [BoxClause L] [HasSnce L] [SnceClause L]

/-- The temporal dual of `generic_discrete_box_necessity`: `S(⊤,⊥) → □(S(⊤,⊥))`. -/
theorem generic_discrete_box_necessity_reflect_time (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasSnce.snce (HasBot.bot : L) top)
        (HasBox.box (HasSnce.snce (HasBot.bot : L) top))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [BoxClause.box_clause]
  rw [generic_cogap_iff] at h
  exact fun σ => (generic_cogap_iff M σ t e).mpr h

end CogapBox

section DensityFuture
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L] [DenselyOrdered F.Duration]

/-- DN: `GGφ → Gφ` on a dense order. -/
theorem generic_density (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (allFuture (allFuture φ)) (allFuture φ)) := by
  rw [ImpClause.imp_clause]
  intro h_GG
  rw [allFuture_iff] at h_GG
  rw [allFuture_iff]
  intro s hts
  obtain ⟨r, htr, hrs⟩ := exists_between hts
  exact (allFuture_iff M τ r e φ).mp (h_GG r htr) s hrs

/-- The dense indicator: `¬U(⊤,⊥)`. A dense order has no gap. -/
theorem generic_dense_indicator (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (neg (HasUntl.untl (HasBot.bot : L) top)) := by
  rw [neg_iff, generic_gap_iff]
  rintro ⟨s, hts, hguard⟩
  obtain ⟨r, htr, hrs⟩ := exists_between hts
  exact hguard r htr hrs

end DensityFuture

section DensityPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L] [DenselyOrdered F.Duration]

/-- The temporal dual of `generic_density`: `HHφ → Hφ`. There is no `density_past` schema, so this
dual is named here, mirroring `Metalogic/Soundness.lean`'s `density_reflect_time_valid`. -/
theorem generic_density_reflect_time (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (HasImp.imp (allPast (allPast φ)) (allPast φ)) := by
  rw [ImpClause.imp_clause]
  intro h_HH
  rw [allPast_iff] at h_HH
  rw [allPast_iff]
  intro s hst
  obtain ⟨r, hsr, hrt⟩ := exists_between hst
  exact (allPast_iff M τ r e φ).mp (h_HH r hrt) s hsr

/-- The temporal dual of the dense indicator: `¬S(⊤,⊥)`. -/
theorem generic_dense_indicator_reflect_time (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (neg (HasSnce.snce (HasBot.bot : L) top)) := by
  rw [neg_iff, generic_cogap_iff]
  rintro ⟨s, hst, hguard⟩
  obtain ⟨r, hsr, hrt⟩ := exists_between hst
  exact hguard r hsr hrt

end DensityPast

section PriorZFuture
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L] [SuccOrder F.Duration]
  [IsSuccArchimedean F.Duration]

/-- Prior-UZ: the nearest `φ`-point above `t` witnesses `U(¬φ, φ)`. -/
theorem generic_prior_UZ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (someFuture φ) (HasUntl.untl (neg φ) φ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [someFuture_iff] at h
  rw [UntlClause.untl_clause]
  obtain ⟨s, hts, hs⟩ := h
  obtain ⟨u, htu, hu, hmin⟩ :=
    exists_nearest_gt (P := fun x => TruthEnv.T M τ x e φ) hts hs
  exact ⟨u, htu, hu, fun r h1 h2 => (neg_iff M τ r e φ).mpr (hmin r h1 h2)⟩

/-- Z1, through `forall_gt_of_succ_step`. -/
theorem generic_z1 (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (allFuture (HasImp.imp (allFuture φ) φ))
        (HasImp.imp (someFuture (allFuture φ)) (allFuture φ))) := by
  rw [ImpClause.imp_clause]
  intro h_GGpIp
  rw [ImpClause.imp_clause]
  intro h_ex
  rw [allFuture_iff] at h_GGpIp
  rw [someFuture_iff] at h_ex
  rw [allFuture_iff]
  obtain ⟨s₀, hts₀, hs₀⟩ := h_ex
  refine forall_gt_of_succ_step (P := fun x => TruthEnv.T M τ x e φ) ?_ hts₀ ?_
  · intro u htu hu
    exact ((ImpClause.imp_clause M τ u e (allFuture φ) φ).mp (h_GGpIp u htu))
      ((allFuture_iff M τ u e φ).mpr hu)
  · exact (allFuture_iff M τ s₀ e φ).mp hs₀

end PriorZFuture

section PriorZPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L] [PredOrder F.Duration]
  [IsPredArchimedean F.Duration]

/-- Prior-SZ, the past dual — through `exists_nearest_lt`, which is itself `exists_nearest_gt`
at `Dᵒᵈ`. The dualisation is of the *carrier*, never of the formula. -/
theorem generic_prior_SZ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (somePast φ) (HasSnce.snce (neg φ) φ)) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [somePast_iff] at h
  rw [SnceClause.snce_clause]
  obtain ⟨s, hst, hs⟩ := h
  obtain ⟨u, hut, hu, hmin⟩ :=
    exists_nearest_lt (P := fun x => TruthEnv.T M τ x e φ) hst hs
  exact ⟨u, hut, hu, fun r h1 h2 => (neg_iff M τ r e φ).mpr (hmin r h1 h2)⟩

/-- The temporal dual of `generic_z1`, through `forall_lt_of_pred_step`. Z1 has no past twin among
the schemata, so this dual is named here — mirroring `SoundnessLemmas.z1_past_valid`. -/
theorem generic_z1_reflect_time (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e
      (HasImp.imp (allPast (HasImp.imp (allPast φ) φ))
        (HasImp.imp (somePast (allPast φ)) (allPast φ))) := by
  rw [ImpClause.imp_clause]
  intro h_HHpIp
  rw [ImpClause.imp_clause]
  intro h_ex
  rw [allPast_iff] at h_HHpIp
  rw [somePast_iff] at h_ex
  rw [allPast_iff]
  obtain ⟨s₀, hs₀t, hs₀⟩ := h_ex
  refine forall_lt_of_pred_step (P := fun x => TruthEnv.T M τ x e φ) ?_ hs₀t ?_
  · intro u hut hu
    exact ((ImpClause.imp_clause M τ u e (allPast φ) φ).mp (h_HHpIp u hut))
      ((allPast_iff M τ u e φ).mpr hu)
  · exact (allPast_iff M τ s₀ e φ).mp hs₀

end PriorZPast

/-!
## The Reynolds Dedekind tier

The four order-dependent schemata of `.RTime`. The least-upper-bound property is taken as an
**explicit hypothesis** `h_lub` rather than a class: `FrameClass.RTime`'s `Sat` is the conjunction
`IsRegular ∧ IsRTime`, and `IsRTime`'s completeness clause is itself a `Prop`-valued statement
(`Semantics/FrameProperty.lean` records why it is not a `ConditionallyCompleteLinearOrder`
instance), so each wrapper passes what its own `sat_intro` already produced.

The order-theoretic content is **not** inlined: `generic_prior_S_gap` derives its greatest lower
bound through `SoundnessLemmas.exists_isGLB_of_lub`, so the lub hypothesis is used once rather than
assumed twice, and the two `sep` lemmas consume the whole of `SoundnessLemmas.sep_order` /
`sep_order_mirror` at `P := {u | TruthEnv.T M τ u e φ}`.

A third ordering trap, after Phase 3's and Phase 5's: `kPlus ψ` is `neg (untl (neg ψ) top)`, so
`neg_iff` matches a `kPlus` term. `kPlus_iff`/`kMinus_iff` are therefore always applied *before*
`neg_iff`, never in the same `simp only`.
-/

section DedekindFuture
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L]

/-- Prior-U, gap form. The least upper bound of the set of times whose whole open past back to
`t` satisfies `φ` is the gap point. -/
theorem generic_prior_U_gap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L)
    (h_lub : ∀ X : Set F.Duration, X.Nonempty → BddAbove X → ∃ x, IsLUB X x) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (HasUntl.untl φ top) (someFuture (neg φ)))
        (HasUntl.untl φ (or (neg φ) (kPlus (neg φ))))) := by
  rw [ImpClause.imp_clause]
  intro h_ant
  rw [and_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  rw [UntlClause.untl_clause] at h1
  rw [someFuture_iff] at h2
  obtain ⟨s0, hts0, -, hp0⟩ := h1
  obtain ⟨w0, htw0, hnw0⟩ := h2
  have hnpw0 : ¬ TruthEnv.T M τ w0 e φ := (neg_iff M τ w0 e φ).mp hnw0
  set A : Set F.Duration :=
    {u : F.Duration | t < u ∧ ∀ r : F.Duration, t < r → r < u → TruthEnv.T M τ r e φ} with hA
  have hs0A : s0 ∈ A := ⟨hts0, hp0⟩
  have hAbdd : BddAbove A := by
    refine ⟨w0, ?_⟩
    intro u hu
    by_contra hvu
    exact hnpw0 (hu.2 w0 htw0 (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨s0, hs0A⟩ hAbdd
  have hts : t < s := lt_of_lt_of_le hts0 (hs.1 hs0A)
  have hguard : ∀ r : F.Duration, t < r → r < s → TruthEnv.T M τ r e φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r htr hru
  rw [UntlClause.untl_clause]
  refine ⟨s, hts, ?_, hguard⟩
  rw [or_iff, kPlus_iff]
  simp only [neg_iff]
  by_cases hps : TruthEnv.T M τ s e φ
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

end DedekindFuture

section DedekindPast
variable [HasBot L] [BotClause L] [HasSnce L] [SnceClause L]

/-- Prior-S, gap form: the past dual, through `SoundnessLemmas.exists_isGLB_of_lub`. -/
theorem generic_prior_S_gap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L)
    (h_lub : ∀ X : Set F.Duration, X.Nonempty → BddAbove X → ∃ x, IsLUB X x) :
    TruthEnv.T M τ t e
      (HasImp.imp (and (HasSnce.snce φ top) (somePast (neg φ)))
        (HasSnce.snce φ (or (neg φ) (kMinus (neg φ))))) := by
  rw [ImpClause.imp_clause]
  intro h_ant
  rw [and_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  rw [SnceClause.snce_clause] at h1
  rw [somePast_iff] at h2
  obtain ⟨s0, hs0t, -, hp0⟩ := h1
  obtain ⟨w0, hw0t, hnw0⟩ := h2
  have hnpw0 : ¬ TruthEnv.T M τ w0 e φ := (neg_iff M τ w0 e φ).mp hnw0
  set B : Set F.Duration :=
    {u : F.Duration | u < t ∧ ∀ r : F.Duration, u < r → r < t → TruthEnv.T M τ r e φ} with hB
  have hs0B : s0 ∈ B := ⟨hs0t, hp0⟩
  have hBbdd : BddBelow B := by
    refine ⟨w0, ?_⟩
    intro u hu
    by_contra huw
    exact hnpw0 (hu.2 w0 (lt_of_not_ge huw) hw0t)
  obtain ⟨s, hs⟩ := exists_isGLB_of_lub h_lub ⟨s0, hs0B⟩ hBbdd
  have hst : s < t := lt_of_le_of_lt (hs.1 hs0B) hs0t
  have hguard : ∀ r : F.Duration, s < r → r < t → TruthEnv.T M τ r e φ := by
    intro r hsr hrt
    obtain ⟨u, huB, -, hur⟩ := hs.exists_between hsr
    exact huB.2 r hur hrt
  rw [SnceClause.snce_clause]
  refine ⟨s, hst, ?_, hguard⟩
  rw [or_iff, kMinus_iff]
  simp only [neg_iff]
  by_cases hps : TruthEnv.T M τ s e φ
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

end DedekindPast

section Sep
variable [HasBot L] [BotClause L] [HasUntl L] [UntlClause L] [HasSnce L] [SnceClause L]
  [DenselyOrdered F.Duration]

/-- **Sep.** The order-theoretic core is `SoundnessLemmas.sep_order`, consumed unchanged at
`P := {u | TruthEnv.T M τ u e φ}`; nothing about any object language enters it.

Stating this over the clause interface is a genuine simplification of the L⋆ and L^▷
transcriptions as well as a unification of them: both of those unfold their whole formula
language to the raw truth recursion (`simp only [StarTruthAt, StarFormula.and, …]`) in order to
reach the shape `sep_order` wants, where `kPlus_iff`/`kMinus_iff` give it directly. -/
theorem generic_sep (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L)
    (h_lub : ∀ X : Set F.Duration, X.Nonempty → BddAbove X → ∃ x, IsLUB X x) :
    TruthEnv.T M τ t e
      (HasImp.imp
        (and (kPlus φ) (neg (kPlus (and φ (HasUntl.untl (neg φ) φ)))))
        (kPlus (and (kPlus φ) (kMinus φ)))) := by
  rw [ImpClause.imp_clause]
  intro h_ant
  rw [and_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  rw [kPlus_iff] at h1
  rw [neg_iff, kPlus_iff] at h2
  push Not at h2
  obtain ⟨s₁, hts₁, hstart⟩ := h2
  rw [kPlus_iff]
  intro s₂ hts₂
  by_contra hno
  push Not at hno
  obtain ⟨Q, hQc, hQd⟩ := exists_countable_order_dense h_lub
  refine (sep_order h_lub Q hQc hQd {u : F.Duration | TruthEnv.T M τ u e φ} t s₁ s₂
    hts₁ hts₂ h1 ?_ ?_).elim
  · rintro u htu hus₁ huP ⟨v, huv, hvP, hfree⟩
    refine hstart u htu hus₁ ?_
    rw [and_iff, UntlClause.untl_clause]
    exact ⟨huP, v, huv, hvP,
      fun r hur hrv => (neg_iff M τ r e φ).mpr (hfree r hur hrv)⟩
  · intro u htu hus₂
    have hAB : ¬ (TruthEnv.T M τ u e (kPlus φ) ∧ TruthEnv.T M τ u e (kMinus φ)) := fun hab =>
      hno u htu hus₂ ((and_iff M τ u e (kPlus φ) (kMinus φ)).mpr hab)
    by_cases hR : ∃ v, u < v ∧ ∀ w, u < w → w < v → w ∉ {x : F.Duration | TruthEnv.T M τ x e φ}
    · exact Or.inl hR
    · refine Or.inr ?_
      have ha : TruthEnv.T M τ u e (kPlus φ) := by
        rw [kPlus_iff]
        intro s hus
        by_contra hc
        push Not at hc
        exact hR ⟨s, hus, fun w huw hws => hc w huw hws⟩
      by_contra hns
      push Not at hns
      exact hAB ⟨ha, (kMinus_iff M τ u e φ).mpr hns⟩

/-- **The temporal dual of Sep.** Sep has no past twin among the schemata, so the dual is stated
here; the order core is `SoundnessLemmas.sep_order_mirror`, itself `sep_order` at `Dᵒᵈ`, so the
nested-interval argument is written once. -/
theorem generic_sep_reflect_time (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L)
    (h_lub : ∀ X : Set F.Duration, X.Nonempty → BddAbove X → ∃ x, IsLUB X x) :
    TruthEnv.T M τ t e
      (HasImp.imp
        (and (kMinus φ) (neg (kMinus (and φ (HasSnce.snce (neg φ) φ)))))
        (kMinus (and (kMinus φ) (kPlus φ)))) := by
  rw [ImpClause.imp_clause]
  intro h_ant
  rw [and_iff] at h_ant
  obtain ⟨h1, h2⟩ := h_ant
  rw [kMinus_iff] at h1
  rw [neg_iff, kMinus_iff] at h2
  push Not at h2
  obtain ⟨s₁, hs₁t, hstart⟩ := h2
  rw [kMinus_iff]
  intro s₂ hs₂t
  by_contra hno
  push Not at hno
  obtain ⟨Q, hQc, hQd⟩ := exists_countable_order_dense h_lub
  refine (sep_order_mirror h_lub Q hQc hQd {u : F.Duration | TruthEnv.T M τ u e φ} t s₁ s₂
    hs₁t hs₂t h1 ?_ ?_).elim
  · rintro u hut hs₁u huP ⟨v, hvu, hvP, hfree⟩
    refine hstart u hs₁u hut ?_
    rw [and_iff, SnceClause.snce_clause]
    exact ⟨huP, v, hvu, hvP,
      fun r hvr hru => (neg_iff M τ r e φ).mpr (hfree r hvr hru)⟩
  · intro u hut hs₂u
    have hAB : ¬ (TruthEnv.T M τ u e (kMinus φ) ∧ TruthEnv.T M τ u e (kPlus φ)) := fun hab =>
      hno u hs₂u hut ((and_iff M τ u e (kMinus φ) (kPlus φ)).mpr hab)
    by_cases hL : ∃ v, v < u ∧ ∀ w, v < w → w < u → w ∉ {x : F.Duration | TruthEnv.T M τ x e φ}
    · exact Or.inl hL
    · refine Or.inr ?_
      have ha : TruthEnv.T M τ u e (kMinus φ) := by
        rw [kMinus_iff]
        intro s hsu
        by_contra hc
        push Not at hc
        exact hL ⟨s, hsu, fun w hsw hwu => hc w hsw hwu⟩
      by_contra hns
      push Not at hns
      exact hAB ⟨ha, (kPlus_iff M τ u e φ).mpr hns⟩

end Sep

/-!
## `modal_future`, with homogeneity as an explicit hypothesis

MF (`□φ → □Gφ`) is the one TM⁺ mirror schema whose semantic content is **time shift**, and time
shift is the boundary both layers below this one declare uninheritable. The reason is not
squeamishness: the three languages' shift lemmas have genuinely different statements.
`PlusTruth.plusTruthAt_timeShift` and `openTruthAt_timeShift` read

```
T M (σ.timeShift Δ) t φ ↔ T M σ (t + Δ) φ
```

while `StarTruth.starTruthAt_timeShift` must drag the stored-time vector along,

```
StarTruthAt M (σ.timeShift Δ) t v φ ↔ StarTruthAt M σ (t + Δ) (fun i => v i + Δ) φ
```

and the L^▷ lemma needed a bespoke `openTruthAt_congr_ext` to land at all. No single clause-class
field covers the three, so making one up would be fiction.

What *is* common is the consequence MF actually uses: a formula true at every world history at `t`
is true at every world history at every later time. That is taken below as the explicit hypothesis
`hhom`, shaped so each language discharges it from its own shift lemma — L⁺ and L^▷ directly, L⋆
with `recallFree_vector_irrelevant` absorbing the vector the shift moves (which is why
`StarAxiom.modal_future` carries a `RecallFree` side condition, and why the generic statement
fixes one `e` rather than quantifying it).
-/

section ModalFuture
variable [HasBot L] [BotClause L] [HasBox L] [BoxClause L] [HasUntl L] [UntlClause L]

/-- MF, generically: `□φ → □Gφ` under homogeneity. `hhom` is the only semantic input, and it is
load-bearing — nothing else in the proof could supply `φ` at a later time. -/
theorem generic_modal_future (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L)
    (hhom : ∀ (σ : WorldHistory F) (s : F.Duration), t < s →
      (∀ ρ : WorldHistory F, TruthEnv.T M ρ t e φ) → TruthEnv.T M σ s e φ) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasBox.box φ) (HasBox.box (allFuture φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [BoxClause.box_clause] at h
  rw [BoxClause.box_clause]
  intro σ
  rw [allFuture_iff]
  intro s hts
  exact hhom σ s hts h

end ModalFuture

section ModalPast
variable [HasBot L] [BotClause L] [HasBox L] [BoxClause L] [HasSnce L] [SnceClause L]

/-- MF's temporal dual, `□φ → □Hφ`, under past homogeneity. No `modal_past` schema exists, so
this dual is named here, exactly as `starValid_modal_future_reflect_time` is. -/
theorem generic_modal_future_reflect_time (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L)
    (hhom : ∀ (σ : WorldHistory F) (s : F.Duration), s < t →
      (∀ ρ : WorldHistory F, TruthEnv.T M ρ t e φ) → TruthEnv.T M σ s e φ) :
    TruthEnv.T M τ t e
      (HasImp.imp (HasBox.box φ) (HasBox.box (allPast φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [BoxClause.box_clause] at h
  rw [BoxClause.box_clause]
  intro σ
  rw [allPast_iff]
  intro s hst
  exact hhom σ s hst h

end ModalPast

end FormalSystem.Metalogic.SoundnessLemmas
