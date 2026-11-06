/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TruthClauses

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

variable {L : Type} [TruthEnv L] [ImpClause L] {F : TaskFrame}

/-! `[BotClause L]` is deliberately **not** a module-level section variable: a lemma whose
statement mentions `neg`, `top`, `and`, `or`, `diamond` or `dstab` takes it as its own binder,
and one that does not is stated without it. That is the grain invariant
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
      (ImpClause.imp (ImpClause.imp φ (ImpClause.imp ψ χ))
        (ImpClause.imp (ImpClause.imp φ ψ) (ImpClause.imp φ χ))) := by
  simp only [ImpClause.imp_clause]
  exact fun h1 h2 h3 => h1 h3 (h2 h3)

/-- Propositional S (weakening), stated once. -/
theorem generic_prop_s (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (ImpClause.imp φ (ImpClause.imp ψ φ)) := by
  simp only [ImpClause.imp_clause]
  exact fun h _ => h

/-- Ex falso quodlibet, from the `bot` clause alone. -/
theorem generic_ex_falso [BotClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (BotClause.bot : L) φ) := by
  rw [ImpClause.imp_clause]
  exact fun h => absurd h (BotClause.bot_clause M τ t e)

/-- Peirce's law, by classical case analysis on `φ`. -/
theorem generic_peirce (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (ImpClause.imp (ImpClause.imp φ ψ) φ) φ) := by
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
variable [BoxClause L]

/-- Modal T: the evaluation history is itself a world history, so `□` reflects. -/
theorem generic_modal_t (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (BoxClause.box φ) φ) := by
  rw [ImpClause.imp_clause, BoxClause.box_clause]
  exact fun h => h τ

/-- Modal 4: the `box` clause quantifies over every world history, so it is idempotent. -/
theorem generic_modal_4 (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (BoxClause.box φ) (BoxClause.box (BoxClause.box φ))) := by
  simp only [ImpClause.imp_clause, BoxClause.box_clause]
  exact fun h _ => h

/-- Modal B, through `diamond_iff` at the witness `τ`. -/
theorem generic_modal_b [BotClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp φ (BoxClause.box (diamond φ))) := by
  rw [ImpClause.imp_clause, BoxClause.box_clause]
  intro h σ
  rw [diamond_iff]
  exact ⟨τ, h⟩

/-- Modal 5 collapse: `◇□φ → □φ`. -/
theorem generic_modal_5_collapse [BotClause L] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (diamond (BoxClause.box φ)) (BoxClause.box φ)) := by
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
      (ImpClause.imp (BoxClause.box (ImpClause.imp φ ψ))
        (ImpClause.imp (BoxClause.box φ) (BoxClause.box ψ))) := by
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
variable [StabClause L]

/-- SK: K for `⊡`, from the universal-quantifier shape of the `stab` clause. -/
theorem generic_stab_k (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (StabClause.stab (ImpClause.imp φ ψ))
        (ImpClause.imp (StabClause.stab φ) (StabClause.stab ψ))) := by
  simp only [ImpClause.imp_clause, StabClause.stab_clause]
  exact fun h1 h2 σ hs => h1 σ hs (h2 σ hs)

/-- ST: state equality is reflexive. -/
theorem generic_stab_t (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (StabClause.stab φ) φ) := by
  rw [ImpClause.imp_clause, StabClause.stab_clause]
  exact fun h => h τ rfl

/-- S4 for `⊡`: state equality at a fixed time is transitive. -/
theorem generic_stab_4 (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (StabClause.stab φ) (StabClause.stab (StabClause.stab φ))) := by
  simp only [ImpClause.imp_clause, StabClause.stab_clause]
  intro h σ hσ ρ hρ
  exact h ρ (hσ.trans hρ)

/-- S5 for `⊡`: state equality at a fixed time is symmetric. -/
theorem generic_stab_5 [BotClause L] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (dstab φ) (StabClause.stab (dstab φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [StabClause.stab_clause]
  intro σ hσ
  rw [dstab_iff] at h ⊢
  obtain ⟨ρ, hρ, hφ⟩ := h
  exact ⟨ρ, hσ.symm.trans hρ, hφ⟩

end Stab

section BoxStab
variable [BoxClause L] [StabClause L]

/-- MS: the same-state histories are a subfamily of all of them, so `□` is stronger than `⊡`. -/
theorem generic_box_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp (BoxClause.box φ) (StabClause.stab φ)) := by
  rw [ImpClause.imp_clause, BoxClause.box_clause, StabClause.stab_clause]
  exact fun h σ _ => h σ

end BoxStab

section AtomStab
variable [AtomClause L] [StabClause L]

/-- AS, stated once: the atom clause reads the world state alone, which the `stab` clause fixes.

This is the schema that makes TM⁺ non-substitution-closed, and the reason the L⁺ atomization
route cannot be reused by L⋆ or L^▷. Over the clause interface it is three lines, because
`AtomClause.atom_clause` is exactly the statement that an atom is state-local. -/
theorem generic_atom_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (p : Atom) :
    TruthEnv.T M τ t e
      (ImpClause.imp (AtomClause.atom p) (StabClause.stab (AtomClause.atom p))) := by
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
variable [BotClause L] [UntlClause L]

/-- TS, bare: `F⊤`. The order has no maximum. -/
theorem generic_serial_future (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (someFuture (top : L)) := by
  rw [someFuture_iff]
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, top_true M τ s e⟩

/-- `⊤ → F⊤`: `generic_serial_future` under a trivially true antecedent. -/
theorem generic_serial_future_imp (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (ImpClause.imp (top : L) (someFuture (top : L))) := by
  rw [ImpClause.imp_clause]
  exact fun _ => generic_serial_future M τ t e

end Seriality

section SerialityPast
variable [BotClause L] [SnceClause L]

/-- `⊤ → P⊤`. The order has no minimum. -/
theorem generic_serial_past (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) :
    TruthEnv.T M τ t e (ImpClause.imp (top : L) (somePast (top : L))) := by
  rw [ImpClause.imp_clause, somePast_iff]
  intro _
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, top_true M τ s e⟩

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
variable [BotClause L] [UntlClause L]

/-- BX2G: the guard of an `until` may be weakened under `G`. -/
theorem generic_left_mono_until_G (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ χ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (allFuture (ImpClause.imp φ χ))
        (ImpClause.imp (UntlClause.untl φ ψ) (UntlClause.untl χ ψ))) := by
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
      (ImpClause.imp (allFuture (ImpClause.imp φ ψ))
        (ImpClause.imp (UntlClause.untl χ φ) (UntlClause.untl χ ψ))) := by
  rw [ImpClause.imp_clause]
  intro h_G
  rw [allFuture_iff] at h_G
  rw [ImpClause.imp_clause]
  simp only [UntlClause.untl_clause]
  rintro ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, ((ImpClause.imp_clause M τ s e φ ψ).mp (h_G s hts)) h_event, h_guard⟩

end MonoFuture

section MonoPast
variable [BotClause L] [SnceClause L]

/-- BX2H, the past mirror of `generic_left_mono_until_G`. -/
theorem generic_left_mono_since_H (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ χ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (allPast (ImpClause.imp φ χ))
        (ImpClause.imp (SnceClause.snce φ ψ) (SnceClause.snce χ ψ))) := by
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
      (ImpClause.imp (allPast (ImpClause.imp φ ψ))
        (ImpClause.imp (SnceClause.snce χ φ) (SnceClause.snce χ ψ))) := by
  rw [ImpClause.imp_clause]
  intro h_H
  rw [allPast_iff] at h_H
  rw [ImpClause.imp_clause]
  simp only [SnceClause.snce_clause]
  rintro ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, ((ImpClause.imp_clause M τ s e φ ψ).mp (h_H s hst)) h_event, h_guard⟩

end MonoPast

section Connection
variable [BotClause L] [UntlClause L] [SnceClause L]

/-- BX4: what is true now is always going to have been true. -/
theorem generic_connect_future (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp φ (allFuture (somePast φ))) := by
  rw [ImpClause.imp_clause]
  intro h
  rw [allFuture_iff]
  intro s hts
  rw [somePast_iff]
  exact ⟨t, hts, h⟩

/-- BX4', the past mirror of `generic_connect_future`. -/
theorem generic_connect_past (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (ImpClause.imp φ (allPast (someFuture φ))) := by
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
variable [BotClause L] [UntlClause L] [SnceClause L]

/-- BX13: an `until` may be enriched with a `since` back to the present. -/
theorem generic_enrichment_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ p : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (and p (UntlClause.untl φ ψ))
        (UntlClause.untl φ (and ψ (SnceClause.snce φ p)))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause, SnceClause.snce_clause]
  rintro ⟨h_pt, s, hts, h_ψs, h_guard⟩
  exact ⟨s, hts, ⟨h_ψs, t, hts, h_pt, h_guard⟩, h_guard⟩

/-- BX13', the past mirror of `generic_enrichment_until`. -/
theorem generic_enrichment_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ p : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (and p (SnceClause.snce φ ψ))
        (SnceClause.snce φ (and ψ (UntlClause.untl φ p)))) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause, SnceClause.snce_clause]
  rintro ⟨h_pt, s, hst, h_ψs, h_guard⟩
  exact ⟨s, hst, ⟨h_ψs, t, hst, h_pt, h_guard⟩, h_guard⟩

end Enrichment

section AccumFuture
variable [BotClause L] [UntlClause L]

/-- BX5: the guard of an `until` may absorb the `until` itself. -/
theorem generic_self_accum_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (UntlClause.untl φ ψ)
        (UntlClause.untl (and φ (UntlClause.untl φ ψ)) ψ)) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, UntlClause.untl_clause]
  rintro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs => ⟨h_guard r htr hrs, ?_⟩⟩
  exact ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX6, the converse direction: the absorbed `until` may be discharged again. -/
theorem generic_absorb_until (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (UntlClause.untl φ (and φ (UntlClause.untl φ ψ)))
        (UntlClause.untl φ ψ)) := by
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
      (ImpClause.imp (and (UntlClause.untl φ ψ) (UntlClause.untl χ θ))
        (or (or (UntlClause.untl (and φ χ) (and ψ θ))
              (UntlClause.untl (and φ χ) (and ψ χ)))
          (UntlClause.untl (and φ χ) (and φ θ)))) := by
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
      (ImpClause.imp (and (UntlClause.untl φ ψ) (UntlClause.untl χ θ))
        (or (UntlClause.untl (and φ χ) (and ψ θ))
          (or (UntlClause.untl (and φ χ) (and ψ χ))
            (UntlClause.untl (and φ χ) (and φ θ))))) := by
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
variable [BotClause L] [SnceClause L]

/-- BX5', the past mirror of `generic_self_accum_until`. -/
theorem generic_self_accum_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (SnceClause.snce φ ψ)
        (SnceClause.snce (and φ (SnceClause.snce φ ψ)) ψ)) := by
  rw [ImpClause.imp_clause]
  simp only [and_iff, SnceClause.snce_clause]
  rintro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt => ⟨h_guard r hsr hrt, ?_⟩⟩
  exact ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

/-- BX6', the past mirror of `generic_absorb_until`. -/
theorem generic_absorb_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (SnceClause.snce φ (and φ (SnceClause.snce φ ψ)))
        (SnceClause.snce φ ψ)) := by
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
      (ImpClause.imp (and (SnceClause.snce φ ψ) (SnceClause.snce χ θ))
        (or (or (SnceClause.snce (and φ χ) (and ψ θ))
              (SnceClause.snce (and φ χ) (and ψ χ)))
          (SnceClause.snce (and φ χ) (and φ θ)))) := by
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
      (ImpClause.imp (and (SnceClause.snce φ ψ) (SnceClause.snce χ θ))
        (or (SnceClause.snce (and φ χ) (and ψ θ))
          (or (SnceClause.snce (and φ χ) (and ψ χ))
            (SnceClause.snce (and φ χ) (and φ θ))))) := by
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

end FormalSystem.Metalogic.SoundnessLemmas
