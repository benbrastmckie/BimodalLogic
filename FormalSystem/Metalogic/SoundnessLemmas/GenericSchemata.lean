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

end FormalSystem.Metalogic.SoundnessLemmas
