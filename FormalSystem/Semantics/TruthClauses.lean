/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Syntax.Connectives

/-!
# The derived-operator clause layer, written once over abstract truth clauses

`Semantics/ValidityLayer.lean` abstracts the validity layer over the truth relation at a point.
This module does the same one level down, for the *clause* layer: the characterization lemmas
`neg_iff`, `and_iff`, `diamond_iff`, `someFuture_iff`, … that every object language proves for
its own derived operators, from its own primitive clauses, by exactly the same argument.

The structure is one `Prop`-valued class per **primitive operator**, holding that operator's truth
clause alone, over a base `TruthEnv` carrying the pointed truth relation. The operator itself
comes from the connective signature of `FormalSystem/Syntax/Connectives.lean`: `BotClause L`
takes `[HasBot L]` as an instance binder and states its clause about `HasBot.bot`, and likewise
for the others. The derived operators are the `Sig` operators of that module, so they are
defined once for syntax and semantics alike. A language instantiates the clause classes for the
primitives it has; the characterization lemmas of the derived operators then come for free,
tiered by which primitives are present. Nothing here imports anything language-specific,
and nothing here recurses on a formula.

**The environment parameter.** `TruthEnv.T` carries one extra argument beyond `(M, τ, t)`: an
`Env F`, threaded **inert** through every clause below. It is `PUnit` for a language whose truth
recursion evaluates at `(M, τ, t)`, and the extra parameter itself for one that does not — L⋆'s
stored-time vector is `Env F := ℕ → F.Duration`. Inertness is the whole content of the
abstraction: every clause here passes `e` through unchanged, which is precisely why the shared
operators behave identically in both point shapes.

## Main Definitions

- `TruthEnv` — the pointed truth relation with an inert environment
- `AtomClause`, `BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`,
  `StabClause`, `AllFutureClause`, `AllPastClause` — one class per primitive operator, each
  carrying its truth clause; all but `AtomClause` are `Prop`-valued mixins over the signature
  class of the same operator
- `BoolClauses`, `UntlClauses`, `TenseClauses`, `StabClauses` — the bundles, for the instance side

The derived operators the lemmas are about — `Sig.neg`, `.top`, `.and`, `.or`, `.diamond`,
`.someFuture`, `.somePast`, `.allFuture`, `.allPast`, `.always`, `.dstab`, `.kPlus`, `.kMinus`,
`.after`, and the tense-primitive alternatives `.someFuture'`, `.somePast'`, `.always'` — are
defined in `FormalSystem/Syntax/Connectives.lean`, not here.

## Main Results

- `TruthClauses.neg_iff`, `.top_true`, `.and_iff`, `.or_iff`, `.diamond_iff` — the Boolean tier
- `TruthClauses.someFuture_iff`, `.somePast_iff`, `.allFuture_iff`, `.allPast_iff`,
  `.always_iff_tri` — the `untl`/`snce` tier
- `TruthClauses.kPlus_iff`, `.kMinus_iff` — Reynolds' two gap operators, unfolded once
- `TruthClauses.dstab_iff` — the stability tier
- `TruthClauses.someFuture_iff_of_allFuture`, `.somePast_iff_of_allPast`, `.always_iff_of_tense`
  — the tense-primitive tier

## Design Invariants — the extension contract

**Written from the four instantiations actually performed** (`Semantics/Truth.lean`,
`MinusTruth.lean`, `PlusTruth.lean`, `StarTruth.lean`), not aspirationally. See
`Semantics/ValidityLayer.lean` for the validity layer's half of the contract.

### What a fifth language must supply

One signature instance per primitive operator, beside the formula type; a `TruthEnv` instance;
then one bundle instance covering the clauses of the primitive operators it has. The whole of L's
obligation at the semantics layer, verbatim:

```
instance : TruthEnv Formula where
  Env _ := PUnit
  T M τ t _ φ := TruthAt M τ t φ

instance : UntlClauses Formula where
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl
```

Every clause field is `Iff.rfl` or `fun h => h` in **all four** landed instances. That is the real
requirement, and it is the compiler that checks it: a field that needs a genuine proof means the
language's recursion does not have the shared clause shape, and the corresponding tier does not
apply to it.

### The tiers, and which language takes which

* `BoolClauses` — Primitives: `bot`, `imp`, `box`; Lemmas inherited: `neg_iff`, `top_true`,
  `and_iff`, `or_iff`, `diamond_iff`; Instantiated by: (via the three below)
* `UntlClauses` — Primitives: + `untl`, `snce`; Lemmas inherited: + `someFuture_iff`,
  `somePast_iff`, `allFuture_iff`, `allPast_iff`, `always_iff_tri`, and the `After` tier
  (`after_top_iff`, `after_iff_of_isNextTime`, `after_negation`, over `IsNextTime` and
  `isNextTime_unique`); Instantiated by: L
* `StabClauses` — Primitives: + `stab`; Lemmas inherited: + `dstab_iff`; Instantiated by: L⁺, L⋆
* `AtomClause` — Primitive: `atom`; Lemmas inherited: no clause lemma of its own (the clause
  field *is* the characterization), but it is what
  `Metalogic/SoundnessLemmas/GenericSchemata.lean`'s `generic_atom_stab` consumes;
  Instantiated by: L, L⁻, L⁺, L⋆, L^▷, the hybrid state language,
  and the propositional-quantifier language — all seven, since every one of them reads an atom as
  `M.valuation (τ.state t) p`. It stands alone rather than joining a bundle: it is purely
  additive, with no `extends` into `BoolClauses`, so adding it perturbs no existing instance.
* `TenseClauses` — Primitives: `allFuture`, `allPast` **primitive** instead of `untl`/`snce`; Lemmas
  inherited: the five Boolean ones, plus `someFuture_iff_of_allFuture`, `somePast_iff_of_allPast`,
  `always_iff_of_tense`; Instantiated by: L⁻

L⁻ is the case that justifies the tense tier's existence: it has the universal tenses as
constructors, so its existential tenses are derived in the *opposite* duality direction
(`Fφ := ¬G¬φ` rather than `Fφ := ⊤ U φ`), and both presentations had to be supported without
merging the two formula types.

Measured payoff across the four landed instantiations: **39 per-language theorem bodies** became
one-line delegations (10 for L, 8 for L⁻, 10 for L⁺, 11 for L⋆) against 14 generic lemmas written
once.

### The environment parameter

`Env` is `fun _ => PUnit` for L, L⁻ and L⁺, and `fun F => ℕ → F.Duration` for L⋆. Wrappers in the
first three pass `PUnit.unit` for `e` **inside the proof body**, so `PUnit` never appears in a
preserved statement; L⋆'s wrappers pass the file's own `v`.

**The obligation this carries** is the clause-layer form of `ValidityLayer.lean`'s O2: the extra
parameter must be threaded *unchanged* through every operator instantiated here. L⋆'s
`timeStore`/`timeRecall` do not — they update and read the vector — so they are deliberately
absent from every class above, and every lemma about them stays in `StarTruth.lean`. A fifth
language may have as many parameter-manipulating operators as it likes, provided none of them is
offered to a shared clause class.

### The `rfl` bridges

A language's own derived-operator `def`s coincide with the `Sig` operators the lemmas here are
stated about, either because their bodies are generated from `Sig` or because they are the same
Łukasiewicz/`untl` encodings **character for character** — `neg φ := imp φ bot`,
`and φ ψ := neg (imp φ (neg ψ))`, `someFuture φ := untl top φ`, and so on. That coincidence is
what lets a wrapper delegate without a `show`. All four languages satisfy it today, for every
operator; it is pinned by the `example … := rfl` lines in
`Tests/BimodalTest/Semantics/ValidityLayerTest.lean` rather than assumed. The two gap operators
`kPlus`/`kMinus` and the `atom` constructor are pinned the same way, in each language that has
them — `kPlus`/`kMinus` for L, L⁺, L⋆ and L^▷, `atom` for all seven. A fifth language that
encodes a derived operator differently keeps its own proof for that one lemma and inherits the
rest.

### Attributes

The generic lemmas carry **no** attributes, and must not acquire any. The same holds of the
schema layer written over this one in `Metalogic/SoundnessLemmas/GenericSchemata.lean`. Each
language's wrapper keeps exactly the attributes it has today — `@[simp, truth_norm]` on L's ten,
`@[simp]` on L⁻'s eight, none on L⁺'s and L⋆'s. Tagging a generic lemma `@[simp]` would change
every downstream simp set at once, and L's two `always` forms are a live example of why that
matters: only the collected `always_iff` may carry the attribute, and it is L-only precisely
because collapsing the three cases needs the frame's trichotomy, which no generic lemma has.

### Classical discipline

`neg_iff` and `top_true` are proved by `rw` plus explicit terms, never by `by_contra`/`push Not`.
This is not style: both are `[propext]` in all four languages, and a classical route here would
drift every wrapper's axiom set at once. Measured outcome of the refactor: **no name gained an
axiom**, and four (`PlusTruth`/`StarTruth`'s `someFuture_iff`/`somePast_iff`) lost `Quot.sound`,
because the generic proofs discharge the `⊤` guard through `top_true` where the originals reached
for `simp`.

### No recursor

These classes abstract the truth *relation* and the operator *constructors*, not the inductive
type. Nothing provable only by `induction φ` belongs here; that boundary is enumerated in
`ValidityLayer.lean`'s contract and is the same boundary for both layers.

### A note on grain

The operator classes are fine-grained — one per operator — and every generic lemma names exactly
the classes its proof consumes, rather than a bundle. The bundles exist for the *instance* side
only, so a language declares one instance instead of six. Stating the lemmas against the bundles
would force a fifth language to supply operators it may not have in order to use a lemma that does
not need them.

## References

* `FormalSystem/Semantics/Truth.lean` — the L clause shapes copied below, and the L instantiation
* `FormalSystem/Semantics/ValidityLayer.lean` — the validity layer over the same idea

## Tags

truth-clauses · abstraction · typeclass · derived-operators · extension-contract
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/-!
## The base: a pointed truth relation with an inert environment
-/

/--
A truth relation at a point `(M, τ, t)` of a task frame, carrying one extra **inert** argument
`e : Env F`.

`Env` is `fun _ => PUnit` for a language whose truth recursion evaluates at `(M, τ, t)` alone,
and the extra parameter's type for one that carries more (L⋆'s stored-time vector is
`Env F := ℕ → F.Duration`). Every clause below threads `e` through unchanged.

This is deliberately distinct from `PointTruth` of `Semantics/ValidityLayer.lean`: that class is
the `∀`-closed relation the validity layer quantifies, this one keeps the extra parameter
exposed, because a clause lemma has to state it.
-/
class TruthEnv (L : Type) where
  /-- The type of the inert extra parameter at each frame; `fun _ => PUnit` when there is none. -/
  Env : TaskFrame → Type
  /-- `T M τ t e φ` — the formula `φ` is true at `(M, τ, t)` under the environment `e`. -/
  T : ∀ {F : TaskFrame}, TaskModel F → WorldHistory F → F.Duration → Env F → L → Prop

/-!
## One class per primitive operator

Each holds the truth clause of the operator its signature class supplies (`AtomClause` alone
carries its constructor, there being no signature class for atoms). The clause statements are
copied from `Semantics/Truth.lean`'s `TruthAt`, with `e` threaded inert.
-/

/--
An atomic proposition, read off the valuation at the history's current **state**.

This is the one clause whose right-hand side is not built from the truth relation itself, and the
only one mentioning `TaskModel.valuation`. It is state-local by construction — `τ.state t` is all
of `(M, τ, t, e)` that it reads — which is exactly what makes AS (`p → ⊡p`) generic.
-/
class AtomClause (L : Type) [TruthEnv L] where
  /-- The atom constructor. -/
  atom : Syntax.Atom → L
  /-- An atom holds iff the valuation holds of the current state. -/
  atom_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (p : Syntax.Atom),
    TruthEnv.T M τ t e (atom p) ↔ M.valuation (τ.state t) p

/-- The falsum, false at every point. -/
class BotClause (L : Type) [TruthEnv L] [HasBot L] : Prop where
  /-- `⊥` is false at every point. -/
  bot_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F), ¬ TruthEnv.T M τ t e HasBot.bot

/-- Material implication. -/
class ImpClause (L : Type) [TruthEnv L] [HasImp L] : Prop where
  /-- Truth of an implication is the material conditional. -/
  imp_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L),
    TruthEnv.T M τ t e (HasImp.imp φ ψ) ↔ (TruthEnv.T M τ t e φ → TruthEnv.T M τ t e ψ)

/-- The modal box: truth at every world history at the current time. -/
class BoxClause (L : Type) [TruthEnv L] [HasBox L] : Prop where
  /-- `□φ` holds iff `φ` holds at every world history at the current time. -/
  box_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (HasBox.box φ) ↔ ∀ σ : WorldHistory F, TruthEnv.T M σ t e φ

/-- Strict `until`, guard first. -/
class UntlClause (L : Type) [TruthEnv L] [HasUntl L] : Prop where
  /-- `untl ψ φ` holds iff `φ` holds at some strictly future time with `ψ` throughout the open
  interval between. -/
  untl_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (ψ φ : L),
    TruthEnv.T M τ t e (HasUntl.untl ψ φ) ↔ ∃ s : F.Duration, t < s ∧ TruthEnv.T M τ s e φ ∧
      ∀ r : F.Duration, t < r → r < s → TruthEnv.T M τ r e ψ

/-- Strict `since`, guard first. -/
class SnceClause (L : Type) [TruthEnv L] [HasSnce L] : Prop where
  /-- `snce ψ φ` holds iff `φ` held at some strictly past time with `ψ` throughout the open
  interval between. -/
  snce_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (ψ φ : L),
    TruthEnv.T M τ t e (HasSnce.snce ψ φ) ↔ ∃ s : F.Duration, s < t ∧ TruthEnv.T M τ s e φ ∧
      ∀ r : F.Duration, s < r → r < t → TruthEnv.T M τ r e ψ

/--
The stability modal: truth at every world history in the same state as the present one **at the
present time**.

The agreement relation is the plain state equation `τ.state t = σ.state t`: world histories carry
a non-dependent state accessor, so no separate same-state relation is needed.
-/
class StabClause (L : Type) [TruthEnv L] [HasStab L] : Prop where
  /-- `⊡φ` holds iff `φ` holds at every world history in the same state at the current time. -/
  stab_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (HasStab.stab φ) ↔ ∀ σ : WorldHistory F, τ.state t = σ.state t →
      TruthEnv.T M σ t e φ

/-- The **primitive** universal future, for a tense-primitive language. -/
class AllFutureClause (L : Type) [TruthEnv L] [HasAllFuture L] : Prop where
  /-- `Gφ` holds iff `φ` holds at every strictly future time. -/
  allFuture_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (HasAllFuture.allFuture φ) ↔ ∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ

/-- The **primitive** universal past, for a tense-primitive language. -/
class AllPastClause (L : Type) [TruthEnv L] [HasAllPast L] : Prop where
  /-- `Hφ` holds iff `φ` holds at every strictly past time. -/
  allPast_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (HasAllPast.allPast φ) ↔ ∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ

/-!
## Capability bundles

Convenience aggregates for the *instance* side: a language declares one bundle instance rather
than four or six separate ones, and the parent instances the generic lemmas actually ask for are
projected out automatically. The lemmas themselves always name the individual operator classes
their proofs consume, so nothing here widens a lemma's requirements.
-/

/-- The Boolean-plus-modal core: `⊥`, `→`, `□`. -/
class BoolClauses (L : Type) [TruthEnv L] [HasBot L] [HasImp L] [HasBox L] : Prop
  extends BotClause L, ImpClause L, BoxClause L

/-- The Boolean core with the strict temporal primitives `U` and `S`: L, L⁺ and L⋆'s shape. -/
class UntlClauses (L : Type) [TruthEnv L] [HasBot L] [HasImp L] [HasBox L] [HasUntl L]
    [HasSnce L] : Prop
  extends BoolClauses L, UntlClause L, SnceClause L

/-- The Boolean core with the **primitive** universal tenses `G` and `H`: L⁻'s shape. -/
class TenseClauses (L : Type) [TruthEnv L] [HasBot L] [HasImp L] [HasBox L] [HasAllFuture L]
    [HasAllPast L] : Prop
  extends BoolClauses L, AllFutureClause L, AllPastClause L

/-- `UntlClauses` with the stability modal `⊡`: L⁺ and L⋆'s shape. -/
class StabClauses (L : Type) [TruthEnv L] [HasBot L] [HasImp L] [HasBox L] [HasUntl L]
    [HasSnce L] [HasStab L] : Prop
  extends UntlClauses L, StabClause L

namespace TruthClauses

open FormalSystem.Syntax.Sig

/-!
## The Boolean tier: `bot`, `imp`, `box`
-/

section Boolean
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] {F : TaskFrame}


/-- Truth of `¬φ`.

Proved by `rw` and explicit terms rather than a classical tactic: this lemma is `[propext]` in
every language today, and every wrapper's axiom set is inherited from here. -/
theorem neg_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (neg φ) ↔ ¬ TruthEnv.T M τ t e φ := by
  rw [neg, ImpClause.imp_clause]
  exact ⟨fun h hφ => BotClause.bot_clause M τ t e (h hφ), fun h hφ => absurd hφ h⟩

omit [BotClause L] in
/-- `⊤` is true everywhere. -/
theorem top_true (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) : TruthEnv.T M τ t e (top : L) := by
  rw [top, ImpClause.imp_clause]
  exact id

/-- Truth of `φ ∧ ψ`. Classical: `and` is the double-negated implication. -/
theorem and_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (and φ ψ) ↔ (TruthEnv.T M τ t e φ ∧ TruthEnv.T M τ t e ψ) := by
  rw [Sig.and, neg_iff, ImpClause.imp_clause, neg_iff]
  constructor
  · intro h
    exact ⟨by_contra fun hφ => h (fun hh => absurd hh hφ), by_contra fun hψ => h (fun _ => hψ)⟩
  · rintro ⟨hφ, hψ⟩ h
    exact (h hφ) hψ

/-- Truth of `φ ∨ ψ`. Classical: `or` is `¬φ → ψ`. -/
theorem or_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (or φ ψ) ↔ (TruthEnv.T M τ t e φ ∨ TruthEnv.T M τ t e ψ) := by
  rw [Sig.or, ImpClause.imp_clause, neg_iff]
  exact ⟨fun h => by_cases (fun hφ => Or.inl hφ) (fun hφ => Or.inr (h hφ)),
    fun h hn => h.elim (fun hφ => absurd hφ hn) id⟩

end Boolean

/-!
## The modal tier: `box`
-/

section Modal
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasBox L]
  [BoxClause L] {F : TaskFrame}

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* world history at the current time. The classical
`¬∀¬ ↔ ∃` step over the box clause. -/
theorem diamond_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (diamond φ) ↔
      ∃ σ : WorldHistory F, TruthEnv.T M σ t e φ := by
  rw [diamond, neg_iff, BoxClause.box_clause]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun σ => (neg_iff M σ t e φ).mpr (hc σ))
  · rintro ⟨σ, hφ⟩ h
    exact ((neg_iff M σ t e φ).mp (h σ)) hφ

end Modal

/-!
## The `untl`/`snce` tier

The existential tenses are primitive-derived (`Fφ := ⊤ U φ`), and the universal ones are their
duals. This is L, L⁺ and L⋆'s shape; the tense-primitive alternative is the last section.
-/

section Future
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasUntl L]
  [UntlClause L] {F : TaskFrame}

omit [BotClause L] in
/-- Truth of `Fφ`: `φ` holds at some strictly future time. The `⊤` guard is discharged by
`top_true`. -/
theorem someFuture_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (someFuture φ) ↔ ∃ s : F.Duration, t < s ∧ TruthEnv.T M τ s e φ := by
  rw [someFuture, UntlClause.untl_clause]
  exact ⟨fun ⟨s, hs, hφ, _⟩ => ⟨s, hs, hφ⟩,
    fun ⟨s, hs, hφ⟩ => ⟨s, hs, hφ, fun r _ _ => top_true M τ r e⟩⟩

/-- Truth of `Gφ`: `φ` holds at every strictly future time. The classical `¬∃¬ ↔ ∀` step. -/
theorem allFuture_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (allFuture φ) ↔ ∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ := by
  rw [allFuture, neg_iff, someFuture_iff]
  constructor
  · intro h s hs
    by_contra hc
    exact h ⟨s, hs, (neg_iff M τ s e φ).mpr hc⟩
  · rintro h ⟨s, hs, hn⟩
    exact ((neg_iff M τ s e φ).mp hn) (h s hs)

/-- `K⁺φ` at `t`: every point above `t` has a `φ`-point strictly between. -/
theorem kPlus_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (kPlus φ) ↔
      ∀ s : F.Duration, t < s → ∃ r : F.Duration, t < r ∧ r < s ∧ TruthEnv.T M τ r e φ := by
  rw [kPlus, neg_iff, UntlClause.untl_clause]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, top_true M τ s e,
      fun r h1 h2 => (neg_iff M τ r e φ).mpr (hc r h1 h2)⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact (neg_iff M τ r e φ).mp (hall r h1 h2) hr

end Future

/-!
## The `After` tier and next-time uniqueness

`def:event-operators`' `After` operator, and the next-time machinery `lem:after-negation` runs
on. The mathematics lives here **once**, over any `L` carrying the Boolean and `untl` clauses;
the L statement (`Metalogic/SoundnessLemmas/EventOperators.lean`) and the two L⁺ statements
(`PlusLanguage/PlusValidity.lean`) are instantiations of `after_negation` below, not second
proofs of it.
-/

section After
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasUntl L]
  [UntlClause L] {F : TaskFrame}

/--
`z` is the **next `φ`-time** after `t` along `τ`: strictly future, with `φ` true there and false
everywhere strictly between. This is exactly `untl`'s witness together with its open-interval
guard, named because `isNextTime_unique` and `after_iff_of_isNextTime` both quantify over it.
-/
def IsNextTime (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F)
    (φ : L) (z : F.Duration) : Prop :=
  t < z ∧ TruthEnv.T M τ z e φ ∧ ∀ r : F.Duration, t < r → r < z → ¬ TruthEnv.T M τ r e φ

omit [BotClause L] [ImpClause L] [UntlClause L] [HasBot L] [HasImp L] [HasUntl L] in
/--
**Next-`φ`-time uniqueness.** Any two next `φ`-times after `t` coincide: were they distinct, the
earlier would lie strictly between `t` and the later, where the later's own open-interval clause
forbids `φ` — contradicting that `φ` holds at the earlier. Linearity of `F.Duration` is the only
order-theoretic input; the proof appeals to nothing about the frame.
-/
theorem isNextTime_unique (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) {z z' : F.Duration}
    (hz : IsNextTime M τ t e φ z) (hz' : IsNextTime M τ t e φ z') : z = z' := by
  rcases lt_trichotomy z z' with h | h | h
  · exact absurd hz.2.1 (hz'.2.2 z hz.1 h)
  · exact h
  · exact absurd hz'.2.1 (hz.2.2 z' hz'.1 h)

/-- Truth of the `lem:after-negation` guard: `After(φ,⊤)` holds at `(τ,t)` exactly when some `z`
is a next `φ`-time, which is the paper's reading of `After(φ,⊤) = ¬φ U φ` as "there is a next
`φ`-time". The `⊤` conjunct is discharged by `top_true`. -/
theorem after_top_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (after φ top) ↔ ∃ z : F.Duration, IsNextTime M τ t e φ z := by
  rw [after, UntlClause.untl_clause]
  constructor
  · rintro ⟨z, hz, hzand, hint⟩
    exact ⟨z, hz, ((and_iff M τ z e φ top).mp hzand).1,
      fun r hr hrz => (neg_iff M τ r e φ).mp (hint r hr hrz)⟩
  · rintro ⟨z, hz, hφ, hint⟩
    exact ⟨z, hz, (and_iff M τ z e φ top).mpr ⟨hφ, top_true M τ z e⟩,
      fun r hr hrz => (neg_iff M τ r e φ).mpr (hint r hr hrz)⟩

/-- Given a next `φ`-time `z`, `After(φ,χ)` reads `χ` **at `z`**: any `untl` witness is itself a
next `φ`-time, so `isNextTime_unique` identifies it with `z`. -/
theorem after_iff_of_isNextTime (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ χ : L) {z : F.Duration} (hz : IsNextTime M τ t e φ z) :
    TruthEnv.T M τ t e (after φ χ) ↔ TruthEnv.T M τ z e χ := by
  rw [after, UntlClause.untl_clause]
  constructor
  · rintro ⟨s, hs, hsand, hint⟩
    obtain ⟨hφ, hχ⟩ := (and_iff M τ s e φ χ).mp hsand
    have hsz : IsNextTime M τ t e φ s :=
      ⟨hs, hφ, fun r hr hrs => (neg_iff M τ r e φ).mp (hint r hr hrs)⟩
    exact (isNextTime_unique M τ t e φ hsz hz) ▸ hχ
  · intro hχ
    exact ⟨z, hz.1, (and_iff M τ z e φ χ).mpr ⟨hz.2.1, hχ⟩,
      fun r hr hrz => (neg_iff M τ r e φ).mpr (hz.2.2 r hr hrz)⟩

/--
**`lem:after-negation`, pointwise and language-generic.** Under the guard `After(φ,⊤)`, failing
`After(φ,ψ)` is the same as satisfying `After(φ,¬ψ)`: both read the single next `φ`-time, so the
equivalence is `¬ T ψ ↔ T (¬ψ)` transported along `after_iff_of_isNextTime`.

The guard is what makes this hold. Without it `After(φ,ψ)` and `After(φ,¬ψ)` can both fail, for
want of any next `φ`-time at all.
-/
theorem after_negation (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) (hg : TruthEnv.T M τ t e (after φ top)) :
    (¬ TruthEnv.T M τ t e (after φ ψ)) ↔ TruthEnv.T M τ t e (after φ (neg ψ)) := by
  obtain ⟨z, hz⟩ := (after_top_iff M τ t e φ).mp hg
  rw [after_iff_of_isNextTime M τ t e φ ψ hz, after_iff_of_isNextTime M τ t e φ (neg ψ) hz,
    neg_iff]

end After

/-!
## The `snce` tier: the past mirror of the `untl` tier
-/

section Past
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasSnce L]
  [SnceClause L] {F : TaskFrame}

omit [BotClause L] in
/-- Truth of `Pφ`: `φ` held at some strictly past time. -/
theorem somePast_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (somePast φ) ↔ ∃ s : F.Duration, s < t ∧ TruthEnv.T M τ s e φ := by
  rw [somePast, SnceClause.snce_clause]
  exact ⟨fun ⟨s, hs, hφ, _⟩ => ⟨s, hs, hφ⟩,
    fun ⟨s, hs, hφ⟩ => ⟨s, hs, hφ, fun r _ _ => top_true M τ r e⟩⟩

/-- Truth of `Hφ`: `φ` holds at every strictly past time. -/
theorem allPast_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (allPast φ) ↔ ∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ := by
  rw [allPast, neg_iff, somePast_iff]
  constructor
  · intro h s hs
    by_contra hc
    exact h ⟨s, hs, (neg_iff M τ s e φ).mpr hc⟩
  · rintro h ⟨s, hs, hn⟩
    exact ((neg_iff M τ s e φ).mp hn) (h s hs)

/-- `K⁻φ` at `t`: the past mirror of `kPlus_iff`. -/
theorem kMinus_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (kMinus φ) ↔
      ∀ s : F.Duration, s < t → ∃ r : F.Duration, s < r ∧ r < t ∧ TruthEnv.T M τ r e φ := by
  rw [kMinus, neg_iff, SnceClause.snce_clause]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, top_true M τ s e,
      fun r h1 h2 => (neg_iff M τ r e φ).mpr (hc r h1 h2)⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact (neg_iff M τ r e φ).mp (hall r h1 h2) hr

end Past

/-!
## Temporal `always`, over the `untl`/`snce` tenses
-/

section Always
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasUntl L]
  [UntlClause L] [HasSnce L] [SnceClause L]
  {F : TaskFrame}

/-- Truth of `△φ` in three-conjunct form: past, present, future. The **introduction** shape,
mirroring the association of `always` itself. Collapsing the three cases into one unrestricted
`∀ s` needs the frame's trichotomy and stays per-language. -/
theorem always_iff_tri (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (always φ) ↔
      (∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ) ∧ TruthEnv.T M τ t e φ ∧
        (∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ) := by
  rw [always, and_iff, and_iff, allPast_iff, allFuture_iff]

end Always

/-!
## The stability tier
-/

section Stab
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasStab L]
  [StabClause L] {F : TaskFrame}

/-- Truth of `⟐φ`: some world history in the same state at the current time satisfies `φ`. The
classical `¬∀¬ ↔ ∃` step over the stability clause. -/
theorem dstab_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (dstab φ) ↔
      ∃ σ : WorldHistory F, τ.state t = σ.state t ∧ TruthEnv.T M σ t e φ := by
  rw [dstab, neg_iff, StabClause.stab_clause]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun σ hs => (neg_iff M σ t e φ).mpr (hc σ hs))
  · rintro ⟨σ, hs, hφ⟩ h
    exact ((neg_iff M σ t e φ).mp (h σ hs)) hφ

end Stab

/-!
## The tense-primitive tier

A language with `allFuture`/`allPast` **primitive** rather than `untl`/`snce` derives the
existential tenses in the opposite duality direction. The operators are primed to distinguish
them from the `untl`-derived ones above; they are the same operators in a different presentation,
and no language has both.
-/

section TenseFuture
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasAllFuture L]
  [AllFutureClause L]
  {F : TaskFrame}

/-- Truth of `Fφ` when the universal future is primitive. The classical `¬∀¬ ↔ ∃` step. -/
theorem someFuture_iff_of_allFuture (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (someFuture' φ) ↔
      ∃ s : F.Duration, t < s ∧ TruthEnv.T M τ s e φ := by
  rw [someFuture', neg_iff, AllFutureClause.allFuture_clause]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun s hs => (neg_iff M τ s e φ).mpr (hc s hs))
  · rintro ⟨s, hs, hφ⟩ h
    exact ((neg_iff M τ s e φ).mp (h s hs)) hφ

end TenseFuture

section TensePast
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasAllPast L]
  [AllPastClause L] {F : TaskFrame}

/-- Truth of `Pφ` when the universal past is primitive. -/
theorem somePast_iff_of_allPast (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (somePast' φ) ↔
      ∃ s : F.Duration, s < t ∧ TruthEnv.T M τ s e φ := by
  rw [somePast', neg_iff, AllPastClause.allPast_clause]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun s hs => (neg_iff M τ s e φ).mpr (hc s hs))
  · rintro ⟨s, hs, hφ⟩ h
    exact ((neg_iff M τ s e φ).mp (h s hs)) hφ

end TensePast

section TenseAlways
variable {L : Type} [TruthEnv L] [HasBot L] [BotClause L] [HasImp L] [ImpClause L] [HasAllFuture L]
  [AllFutureClause L]
  [HasAllPast L] [AllPastClause L] {F : TaskFrame}

/-- Truth of `△φ` in three-conjunct form, over the primitive tenses. -/
theorem always_iff_of_tense (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (always' φ) ↔
      (∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ) ∧ TruthEnv.T M τ t e φ ∧
        (∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ) := by
  rw [always', and_iff, and_iff, AllPastClause.allPast_clause,
    AllFutureClause.allFuture_clause]

end TenseAlways

end TruthClauses

end FormalSystem.Semantics
