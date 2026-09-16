/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.PartialHistory

/-!
# The derived-operator clause layer, written once over abstract truth clauses

`Semantics/ValidityLayer.lean` abstracts the validity layer over the truth relation at a point.
This module does the same one level down, for the *clause* layer: the characterization lemmas
`neg_iff`, `and_iff`, `diamond_iff`, `someFuture_iff`, … that every object language proves for
its own derived operators, from its own primitive clauses, by exactly the same argument.

The structure is one class per **primitive operator**, each bundling the operator with its truth
clause, over a base `TruthEnv` carrying the pointed truth relation. A language instantiates the
operator classes it has; the derived operators and their characterization lemmas then come for
free, tiered by which primitives are present. Nothing here imports anything language-specific,
and nothing here recurses on a formula.

**The environment parameter.** `TruthEnv.T` carries one extra argument beyond `(M, τ, t)`: an
`Env F`, threaded **inert** through every clause below. It is `PUnit` for a language whose truth
recursion evaluates at `(M, τ, t)`, and the extra parameter itself for one that does not — L⋆'s
stored-time vector is `Env F := ℕ → F.Duration`. Inertness is the whole content of the
abstraction: every clause here passes `e` through unchanged, which is precisely why the shared
operators behave identically in both point shapes.

## Main Definitions

- `TruthEnv` — the pointed truth relation with an inert environment
- `BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause`,
  `AllFutureClause`, `AllPastClause` — one class per primitive operator, each carrying the
  operator and its truth clause
- `TruthClauses.neg`, `.top`, `.and`, `.or`, `.diamond`, `.someFuture`, `.somePast`,
  `.allFuture`, `.allPast`, `.always`, `.dstab` — the derived operators, and the
  tense-primitive alternatives `.someFuture'`, `.somePast'`, `.always'`

## Main Results

- `TruthClauses.neg_iff`, `.top_true`, `.and_iff`, `.or_iff`, `.diamond_iff` — the Boolean tier
- `TruthClauses.someFuture_iff`, `.somePast_iff`, `.allFuture_iff`, `.allPast_iff`,
  `.always_iff_tri` — the `untl`/`snce` tier
- `TruthClauses.dstab_iff` — the stability tier
- `TruthClauses.someFuture_iff_of_allFuture`, `.somePast_iff_of_allPast`, `.always_iff_of_tense`
  — the tense-primitive tier

## Design Invariants — the extension contract

**Written from the four instantiations actually performed** (`Semantics/Truth.lean`,
`MinusTruth.lean`, `PlusTruth.lean`, `StarTruth.lean`), not aspirationally. See
`Semantics/ValidityLayer.lean` for the validity layer's half of the contract.

### What a fifth language must supply

A `TruthEnv` instance, then one bundle instance covering the primitive operators it has. The
whole of L's obligation, verbatim:

```
instance : TruthEnv Formula where
  Env _ := PUnit
  T M τ t _ φ := TruthAt M τ t φ

instance : UntlClauses Formula where
  bot := Formula.bot;  imp := Formula.imp;  box := Formula.box
  untl := Formula.untl;  snce := Formula.snce
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

| Bundle | Primitives | Lemmas inherited | Instantiated by |
|--------|-----------|------------------|-----------------|
| `BoolClauses` | `bot`, `imp`, `box` | `neg_iff`, `top_true`, `and_iff`, `or_iff`, `diamond_iff` | (via the three below) |
| `UntlClauses` | + `untl`, `snce` | + `someFuture_iff`, `somePast_iff`, `allFuture_iff`, `allPast_iff`, `always_iff_tri` | L |
| `StabClauses` | + `stab` | + `dstab_iff` | L⁺, L⋆ |
| `TenseClauses` | `allFuture`, `allPast` **primitive** instead of `untl`/`snce` | the five Boolean ones, plus `someFuture_iff_of_allFuture`, `somePast_iff_of_allPast`, `always_iff_of_tense` | L⁻ |

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

A language's own derived-operator `def`s coincide with the `abbrev`s here only because they are
the same Łukasiewicz/`untl` encodings **character for character** — `neg φ := imp φ bot`,
`and φ ψ := neg (imp φ (neg ψ))`, `someFuture φ := untl top φ`, and so on. That coincidence is
what lets a wrapper delegate without a `show`. All four languages satisfy it today, for every
operator; it is pinned by ~40 `example … := rfl` lines in
`Tests/BimodalTest/Semantics/ValidityLayerTest.lean` rather than assumed. A fifth language that
encodes a derived operator differently keeps its own proof for that one lemma and inherits the
rest.

### Attributes

The generic lemmas carry **no** attributes, and must not acquire any. Each language's wrapper
keeps exactly the attributes it has today — `@[simp, truth_norm]` on L's ten, `@[simp]` on L⁻'s
eight, none on L⁺'s and L⋆'s. Tagging a generic lemma `@[simp]` would change every downstream simp
set at once, and L's two `always` forms are a live example of why that matters: only the collected
`always_iff` may carry the attribute, and it is L-only precisely because collapsing the three
cases needs the frame's trichotomy, which no generic lemma has.

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

* `FormalSystem/Semantics/Truth.lean` — the L clause shapes copied below, and the L
  instantiation
* `FormalSystem/Semantics/ValidityLayer.lean` — the validity layer over the same idea

## Tags

truth-clauses · abstraction · typeclass · derived-operators · extension-contract
-/

namespace FormalSystem.Semantics

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
  T : ∀ {F : TaskFrame}, TaskModel F → PartialHistory F → F.Duration → Env F → L → Prop

/-!
## One class per primitive operator

Each carries the operator and its truth clause. The clause statements are copied from
`Semantics/Truth.lean`'s `TruthAt`, with `e` threaded inert.
-/

/-- The falsum, false at every point. -/
class BotClause (L : Type) [TruthEnv L] where
  /-- The falsum constructor. -/
  bot : L
  /-- `⊥` is false at every point. -/
  bot_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F), ¬ TruthEnv.T M τ t e bot

/-- Material implication. -/
class ImpClause (L : Type) [TruthEnv L] where
  /-- The implication constructor. -/
  imp : L → L → L
  /-- Truth of an implication is the material conditional. -/
  imp_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L),
    TruthEnv.T M τ t e (imp φ ψ) ↔ (TruthEnv.T M τ t e φ → TruthEnv.T M τ t e ψ)

/-- The modal box: truth at every total history at the current time. -/
class BoxClause (L : Type) [TruthEnv L] where
  /-- The box constructor. -/
  box : L → L
  /-- `□φ` holds iff `φ` holds at every **total** history at the current time. -/
  box_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (box φ) ↔ ∀ σ : PartialHistory F, σ.IsTotal → TruthEnv.T M σ t e φ

/-- Strict `until`, guard first. -/
class UntlClause (L : Type) [TruthEnv L] where
  /-- The `until` constructor, guard first. -/
  untl : L → L → L
  /-- `untl ψ φ` holds iff `φ` holds at some strictly future time with `ψ` throughout the open
  interval between. -/
  untl_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (ψ φ : L),
    TruthEnv.T M τ t e (untl ψ φ) ↔ ∃ s : F.Duration, t < s ∧ TruthEnv.T M τ s e φ ∧
      ∀ r : F.Duration, t < r → r < s → TruthEnv.T M τ r e ψ

/-- Strict `since`, guard first. -/
class SnceClause (L : Type) [TruthEnv L] where
  /-- The `since` constructor, guard first. -/
  snce : L → L → L
  /-- `snce ψ φ` holds iff `φ` held at some strictly past time with `ψ` throughout the open
  interval between. -/
  snce_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (ψ φ : L),
    TruthEnv.T M τ t e (snce ψ φ) ↔ ∃ s : F.Duration, s < t ∧ TruthEnv.T M τ s e φ ∧
      ∀ r : F.Duration, s < r → r < t → TruthEnv.T M τ r e ψ

/--
The stability modal: truth at every total history agreeing with the present one **at the present
time**.

The agreement relation is carried as the field `sameState` rather than named directly. The tree's
`SameStateAt` lives in `Semantics/PlusLanguage/PlusTruth.lean`, which sits above this module in the import
order; taking it as a field keeps this module a leaf while letting each instance supply the real
relation, so no consumer's statement changes.
-/
class StabClause (L : Type) [TruthEnv L] where
  /-- The stability constructor. -/
  stab : L → L
  /-- The same-state-at-a-time relation the stability clause quantifies over. -/
  sameState : ∀ {F : TaskFrame}, PartialHistory F → PartialHistory F → F.Duration → Prop
  /-- `⊡φ` holds iff `φ` holds at every total history in the same state at the current time. -/
  stab_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (stab φ) ↔ ∀ σ : PartialHistory F, σ.IsTotal →
      sameState τ σ t → TruthEnv.T M σ t e φ

/-- The **primitive** universal future, for a tense-primitive language. -/
class AllFutureClause (L : Type) [TruthEnv L] where
  /-- The universal-future constructor. -/
  allFuture : L → L
  /-- `Gφ` holds iff `φ` holds at every strictly future time. -/
  allFuture_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (allFuture φ) ↔ ∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ

/-- The **primitive** universal past, for a tense-primitive language. -/
class AllPastClause (L : Type) [TruthEnv L] where
  /-- The universal-past constructor. -/
  allPast : L → L
  /-- `Hφ` holds iff `φ` holds at every strictly past time. -/
  allPast_clause : ∀ {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F)
    (t : F.Duration) (e : TruthEnv.Env L F) (φ : L),
    TruthEnv.T M τ t e (allPast φ) ↔ ∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ

/-!
## Capability bundles

Convenience aggregates for the *instance* side: a language declares one bundle instance rather
than four or six separate ones, and the parent instances the generic lemmas actually ask for are
projected out automatically. The lemmas themselves always name the individual operator classes
their proofs consume, so nothing here widens a lemma's requirements.
-/

/-- The Boolean-plus-modal core: `⊥`, `→`, `□`. -/
class BoolClauses (L : Type) [TruthEnv L] extends BotClause L, ImpClause L, BoxClause L

/-- The Boolean core with the strict temporal primitives `U` and `S`: L, L⁺ and L⋆'s shape. -/
class UntlClauses (L : Type) [TruthEnv L] extends BoolClauses L, UntlClause L, SnceClause L

/-- The Boolean core with the **primitive** universal tenses `G` and `H`: L⁻'s shape. -/
class TenseClauses (L : Type) [TruthEnv L] extends BoolClauses L, AllFutureClause L, AllPastClause L

/-- `UntlClauses` with the stability modal `⊡`: L⁺ and L⋆'s shape. -/
class StabClauses (L : Type) [TruthEnv L] extends UntlClauses L, StabClause L

namespace TruthClauses

/-!
## The Boolean tier: `bot`, `imp`, `box`
-/

section Boolean
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] {F : TaskFrame}

/-- Negation (`¬φ`): `φ → ⊥`. -/
abbrev neg (φ : L) : L := ImpClause.imp φ BotClause.bot

/-- Verum (`⊤`): `⊥ → ⊥`. -/
abbrev top : L := ImpClause.imp (BotClause.bot : L) BotClause.bot

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. -/
abbrev and (φ ψ : L) : L := neg (ImpClause.imp φ (neg ψ))

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. -/
abbrev or (φ ψ : L) : L := ImpClause.imp (neg φ) ψ


/-- Truth of `¬φ`.

Proved by `rw` and explicit terms rather than a classical tactic: this lemma is `[propext]` in
every language today, and every wrapper's axiom set is inherited from here. -/
theorem neg_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (neg φ) ↔ ¬ TruthEnv.T M τ t e φ := by
  rw [neg, ImpClause.imp_clause]
  exact ⟨fun h hφ => BotClause.bot_clause M τ t e (h hφ), fun h hφ => absurd hφ h⟩

/-- `⊤` is true everywhere. -/
theorem top_true (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) : TruthEnv.T M τ t e (top : L) := by
  rw [top, ImpClause.imp_clause]
  exact id

/-- Truth of `φ ∧ ψ`. Classical: `and` is the double-negated implication. -/
theorem and_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (and φ ψ) ↔ (TruthEnv.T M τ t e φ ∧ TruthEnv.T M τ t e ψ) := by
  rw [and, neg_iff, ImpClause.imp_clause, neg_iff]
  constructor
  · intro h
    exact ⟨by_contra fun hφ => h (fun hh => absurd hh hφ), by_contra fun hψ => h (fun _ => hψ)⟩
  · rintro ⟨hφ, hψ⟩ h
    exact (h hφ) hψ

/-- Truth of `φ ∨ ψ`. Classical: `or` is `¬φ → ψ`. -/
theorem or_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e (or φ ψ) ↔ (TruthEnv.T M τ t e φ ∨ TruthEnv.T M τ t e ψ) := by
  rw [or, ImpClause.imp_clause, neg_iff]
  exact ⟨fun h => by_cases (fun hφ => Or.inl hφ) (fun hφ => Or.inr (h hφ)),
    fun h hn => h.elim (fun hφ => absurd hφ hn) id⟩

end Boolean

/-!
## The modal tier: `box`
-/

section Modal
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [BoxClause L] {F : TaskFrame}

/-- Possibility (`◇φ`): `¬□¬φ`. -/
abbrev diamond (φ : L) : L := neg (BoxClause.box (neg φ))

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* total history at the current time. The classical
`¬∀¬ ↔ ∃` step over the box clause. -/
theorem diamond_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (diamond φ) ↔
      ∃ σ : PartialHistory F, σ.IsTotal ∧ TruthEnv.T M σ t e φ := by
  rw [diamond, neg_iff, BoxClause.box_clause]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun σ hσ => (neg_iff M σ t e φ).mpr (hc σ hσ))
  · rintro ⟨σ, hσ, hφ⟩ h
    exact ((neg_iff M σ t e φ).mp (h σ hσ)) hφ

end Modal

/-!
## The `untl`/`snce` tier

The existential tenses are primitive-derived (`Fφ := ⊤ U φ`), and the universal ones are their
duals. This is L, L⁺ and L⋆'s shape; the tense-primitive alternative is the last section.
-/

section Future
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L] {F : TaskFrame}

/-- Existential future (`Fφ`): `⊤ U φ`. -/
abbrev someFuture (φ : L) : L := UntlClause.untl top φ

/-- Universal future (`Gφ`): `¬F¬φ`. -/
abbrev allFuture (φ : L) : L := neg (someFuture (neg φ))

/-- Truth of `Fφ`: `φ` holds at some strictly future time. The `⊤` guard is discharged by
`top_true`. -/
theorem someFuture_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (someFuture φ) ↔ ∃ s : F.Duration, t < s ∧ TruthEnv.T M τ s e φ := by
  rw [someFuture, UntlClause.untl_clause]
  exact ⟨fun ⟨s, hs, hφ, _⟩ => ⟨s, hs, hφ⟩,
    fun ⟨s, hs, hφ⟩ => ⟨s, hs, hφ, fun r _ _ => top_true M τ r e⟩⟩

/-- Truth of `Gφ`: `φ` holds at every strictly future time. The classical `¬∃¬ ↔ ∀` step. -/
theorem allFuture_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (allFuture φ) ↔ ∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ := by
  rw [allFuture, neg_iff, someFuture_iff]
  constructor
  · intro h s hs
    by_contra hc
    exact h ⟨s, hs, (neg_iff M τ s e φ).mpr hc⟩
  · rintro h ⟨s, hs, hn⟩
    exact ((neg_iff M τ s e φ).mp hn) (h s hs)

end Future

/-!
## The `snce` tier: the past mirror of the `untl` tier
-/

section Past
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [SnceClause L] {F : TaskFrame}

/-- Existential past (`Pφ`): `⊤ S φ`. -/
abbrev somePast (φ : L) : L := SnceClause.snce top φ

/-- Universal past (`Hφ`): `¬P¬φ`. -/
abbrev allPast (φ : L) : L := neg (somePast (neg φ))

/-- Truth of `Pφ`: `φ` held at some strictly past time. -/
theorem somePast_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (somePast φ) ↔ ∃ s : F.Duration, s < t ∧ TruthEnv.T M τ s e φ := by
  rw [somePast, SnceClause.snce_clause]
  exact ⟨fun ⟨s, hs, hφ, _⟩ => ⟨s, hs, hφ⟩,
    fun ⟨s, hs, hφ⟩ => ⟨s, hs, hφ, fun r _ _ => top_true M τ r e⟩⟩

/-- Truth of `Hφ`: `φ` holds at every strictly past time. -/
theorem allPast_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (allPast φ) ↔ ∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ := by
  rw [allPast, neg_iff, somePast_iff]
  constructor
  · intro h s hs
    by_contra hc
    exact h ⟨s, hs, (neg_iff M τ s e φ).mpr hc⟩
  · rintro h ⟨s, hs, hn⟩
    exact ((neg_iff M τ s e φ).mp hn) (h s hs)

end Past

/-!
## Temporal `always`, over the `untl`/`snce` tenses
-/

section Always
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L] [SnceClause L]
  {F : TaskFrame}

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. -/
abbrev always (φ : L) : L := and (allPast φ) (and φ (allFuture φ))

/-- Truth of `△φ` in three-conjunct form: past, present, future. The **introduction** shape,
mirroring the association of `always` itself. Collapsing the three cases into one unrestricted
`∀ s` needs the frame's trichotomy and stays per-language. -/
theorem always_iff_tri (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
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
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [StabClause L] {F : TaskFrame}

/-- The dual stability modal (`⟐φ`): `¬⊡¬φ`. -/
abbrev dstab (φ : L) : L := neg (StabClause.stab (neg φ))

/-- Truth of `⟐φ`: some total history in the same state at the current time satisfies `φ`. The
classical `¬∀¬ ↔ ∃` step over the stability clause. -/
theorem dstab_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (dstab φ) ↔
      ∃ σ : PartialHistory F, σ.IsTotal ∧ StabClause.sameState (L := L) τ σ t ∧
        TruthEnv.T M σ t e φ := by
  rw [dstab, neg_iff, StabClause.stab_clause]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun σ hσ hs => (neg_iff M σ t e φ).mpr (hc σ hσ hs))
  · rintro ⟨σ, hσ, hs, hφ⟩ h
    exact ((neg_iff M σ t e φ).mp (h σ hσ hs)) hφ

end Stab

/-!
## The tense-primitive tier

A language with `allFuture`/`allPast` **primitive** rather than `untl`/`snce` derives the
existential tenses in the opposite duality direction. The operators are primed to distinguish
them from the `untl`-derived ones above; they are the same operators in a different presentation,
and no language has both.
-/

section TenseFuture
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [AllFutureClause L]
  {F : TaskFrame}

/-- Existential future from the primitive universal one (`Fφ`): `¬G¬φ`. -/
abbrev someFuture' (φ : L) : L := neg (AllFutureClause.allFuture (neg φ))

/-- Truth of `Fφ` when the universal future is primitive. The classical `¬∀¬ ↔ ∃` step. -/
theorem someFuture_iff_of_allFuture (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
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
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [AllPastClause L] {F : TaskFrame}

/-- Existential past from the primitive universal one (`Pφ`): `¬H¬φ`. -/
abbrev somePast' (φ : L) : L := neg (AllPastClause.allPast (neg φ))

/-- Truth of `Pφ` when the universal past is primitive. -/
theorem somePast_iff_of_allPast (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
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
variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [AllFutureClause L]
  [AllPastClause L] {F : TaskFrame}

/-- Temporal `always` over the primitive tenses (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. -/
abbrev always' (φ : L) : L :=
  and (AllPastClause.allPast φ) (and φ (AllFutureClause.allFuture φ))

/-- Truth of `△φ` in three-conjunct form, over the primitive tenses. -/
theorem always_iff_of_tense (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (always' φ) ↔
      (∀ s : F.Duration, s < t → TruthEnv.T M τ s e φ) ∧ TruthEnv.T M τ t e φ ∧
        (∀ s : F.Duration, t < s → TruthEnv.T M τ s e φ) := by
  rw [always', and_iff, and_iff, AllPastClause.allPast_clause,
    AllFutureClause.allFuture_clause]

end TenseAlways

end TruthClauses

end FormalSystem.Semantics
