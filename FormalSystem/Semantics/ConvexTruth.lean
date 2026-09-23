/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.FrameClassValidity
import FormalSystem.Semantics.Extension.Extension

/-!
# ConvexTruth - The Convex-Index Consequence Relations C3 and C4

The library's consequence relation — `def:logical-consequence`, rendered by
`SemanticConsequence` — evaluates a sentence at a *possible world* (a total history) and at
every time of the temporal order. This module defines the alternative the paper itself names in
a footnote, and its restriction to interval indices, as relations this library *has* rather than
ones it mentions. Both are written **beside** the library's `TruthAt`, never as a modification
of it: `TruthAtConvex` is a separate recursion, and nothing in `Truth.lean` or `Validity.lean`
depends on this file.

## The four relations

- **C1** — the relation of record. Index a total history, `□` over the world histories `H_F`,
  tenses over all of `D`, evaluation time over all of `D`. This is `TruthAt` with
  `TaskFrame.ValidOn` / `ConsequenceOnFrames`, and it is read here, never written.
- **C2** — C1's clauses at an arbitrary convex index: drop totality of the index and change
  nothing else. It was a diagnostic only, strictly worse than both C1 and C3 (it invalidates
  `□φ → φ`), and it is **retired by the index type**: `TruthAt` is indexed by
  `WorldHistory F`, the subtype of total histories, so C2 is no longer statable with the
  library's truth definition. It is recorded here and deliberately not defined.
- **C3** — `TruthAtConvex` with `ValidC3`. Index any convex history `τ` with a time
  `x ∈ dom τ`; `□` quantifies over the convex histories `σ` with `x ∈ dom σ`; the tense
  clauses and the evaluation time are restricted to `dom τ`.
- **C4** — `ValidC4`: C3 with the index restricted to closed bounded interval domains
  (`IsInterval`), the domain shape of the sections of the paper's behaviour presheaf up to
  translation.

## Paper Alignment

C3 is the alternative described in the footnote the paper attaches to its discussion of
evaluating a tensed modal claim beyond the end of a finished game, just before it states
logical consequence. The footnote, verbatim:

> Alternatively, one might evaluate sentences at any convex history tau together with a time
> x in dom(tau), taking Box to quantify over all convex histories sigma where x in dom(sigma),
> restricting Past and Future to the times in dom(tau), and adapting logical consequence to
> replace D with dom(tau). Since evaluating sentences only at possible worlds excludes no course
> of events by thm:extension, the present account retains the stronger tense logic.

`TruthAtConvex` is that footnote clause for clause, and `ValidC3` is its adapted consequence
relation at the empty premise set: `def:logical-consequence` with "possible worlds tau in H_F,
and times x in D" replaced by "convex histories tau, and times x in dom(tau)".

## What C3 is

C3 is TM's S5 modal layer over a bounded-interval tense logic. Every axiom of TM that fails
under C3 is an **existence assertion about the temporal order** — that a later time exists, that
an earlier time exists, that a gap propagates to a point which would need a successor — and
boundedness of the index's domain is exactly what makes existence assertions fail. The S5 core
survives untouched, because C3 changes the *range* of `□` (from `H_F` to the convex histories
through the evaluation time) and not its character: `truthC3_box_indep`. The modal/temporal
interaction axiom `□φ → □Gφ` survives too, because C3 is time-uniform: `truthC3_timeShift` is
the C3 analogue of `app:auto_existence`. The row-by-row verdicts are theorems of the
`Metalogic/ConvexConsequence/` cluster. No identification of the C3 logic with a known
axiomatic system is asserted anywhere in this development; that is a completeness question.

## The box range: a working default

The footnote's own reading is kept as the **primary** C3: `□` ranges over *all* convex
histories through the evaluation time, one-point histories (germs) included. The germs are
what make every boxed `U`/`S`-formula unsatisfiable (`c3_box_untl_unsat`,
`c3_box_snce_unsat`), and the rationale for keeping them is that the footnote is the
definition of record and the germ result is more interesting stated than avoided. The cut-back
variant — `□` over the convex histories whose domain contains the index's domain — is the
**named alternative** `TruthAtConvexCut` in `Semantics/ConvexTruthCut.lean`. This is a working
default, revisable by the author; overriding it changes what a completeness theorem for C3
would be about.

## Main Definitions

- `TruthAtConvex`: the C3 truth recursion at a partial-history index
- `ValidC3`, `ValidC4`: frame-level validity under C3 and C4; `IsInterval`
- `ValidC3In`, `ValidC4In`: class-level validity, mirroring `ValidIn`
- `ConsequenceC3`, `ConsequenceC4`: finite-context consequence, mirroring
  `ConsequenceOnFrames`

## Main Results

- `TruthAtConvex.and_iff`, `someFuture_iff`, `allFuture_iff`, `somePast_iff`, `allPast_iff`,
  `kPlus_iff`, `kMinus_iff`: the clause lemmas. The abstract clause layer
  (`Semantics/TruthClauses.lean`) fixes a total-history index and cannot be instantiated at a
  partial one, so C3 carries its own.
- `IsInterval.isConvex`, `PartialHistory.point_isConvex`
- `validC3_imp_validC4`: every C3-validity is a C4-validity
- `truthC3_box_indep`: C3's `□` does not depend on the index
- `germ_untl_false`, `germ_snce_false`, `c3_box_untl_unsat`, `c3_box_snce_unsat`: the germ
  theorems
- `c3_nec`, `c3_valid_imp_germ_valid`: semantic necessitation, and germ-validity
- `truthC3_timeShift`, `c3_box_time_uniform`: shift invariance and the time-uniform box

## References

* `FormalSystem/Semantics/Truth.lean` — the library's truth definition (C1)
* `FormalSystem/Semantics/Validity.lean` — `def:logical-consequence`
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `IsConvex`, `timeShift`
* `FormalSystem/Semantics/Extension/Extension.lean` — `PartialHistory.point`

## Tags

convex-history · consequence-relation · germ · shift-invariance · def:logical-consequence
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {F : TaskFrame}

/-! ## The C3 truth recursion -/

/--
**C3 truth**: the paper's alternative-semantics footnote, clause for clause.

* `atom` — true when the evaluation time is in the index's domain and the valuation holds at the
  state there. The clause is `TruthAt`'s own, which is already domain-relative.
* `box` — quantifies over the **convex** partial histories `σ` whose domain contains the
  evaluation time, in place of `def:BL-semantics`'s quantification over `H_F`. Convexity is a
  hypothesis on the quantified history because `PartialHistory.IsConvex` is a predicate, not a
  structure field.
* `untl` / `snce` — the witness `s` and the guard times `r` are both restricted to `dom τ`, in
  place of the library's unrestricted quantification over `D`.

Argument order follows `Formula.untl ψ φ`: `ψ` is the guard and `φ` the event.

The index is an arbitrary partial history. Neither convexity of the index nor the side condition
`x ∈ dom τ` is imposed by this recursion; both are imposed by the validity and consequence
definitions below, exactly as totality of the index is imposed by the *type* of `TruthAt`'s
index rather than by its clauses.
-/
def TruthAtConvex (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) : Formula → Prop
  | .atom p => ∃ ht : τ.domain t, M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => TruthAtConvex M τ t φ → TruthAtConvex M τ t ψ
  | .box φ => ∀ σ : PartialHistory F, σ.IsConvex → σ.domain t → TruthAtConvex M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, τ.domain s ∧ t < s ∧ TruthAtConvex M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → t < r → r < s → TruthAtConvex M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, τ.domain s ∧ s < t ∧ TruthAtConvex M τ s φ ∧
      ∀ r : F.Duration, τ.domain r → s < r → r < t → TruthAtConvex M τ r ψ

/-! ## Validity and consequence under C3 and C4 -/

/-- **C3 validity on a frame**: true at every model, every convex index, and every time in that
index's own domain. The footnote's "replace `D` with `dom τ`" is the final binder. -/
def ValidC3 (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : PartialHistory F), τ.IsConvex →
    ∀ x : F.Duration, τ.domain x → TruthAtConvex M τ x φ

/-- A partial history is an **interval history** when its domain is a closed bounded interval
`[a, b]` — the domain shape of the sections of the paper's behaviour presheaf, up to
translation. The one-point domain `[x, x]` is included. -/
def IsInterval (τ : PartialHistory F) : Prop :=
  ∃ a b : F.Duration, ∀ t : F.Duration, τ.domain t ↔ (a ≤ t ∧ t ≤ b)

/-- **C4 validity on a frame**: C3 with the index restricted to interval histories. The box
still ranges over every convex history through the evaluation time; only the *index* is
restricted. -/
def ValidC4 (F : TaskFrame) (φ : Formula) : Prop :=
  ∀ (M : TaskModel F) (τ : PartialHistory F), IsInterval τ →
    ∀ x : F.Duration, τ.domain x → TruthAtConvex M τ x φ

/-- C3 validity on every frame of the class the tag `fc` denotes: the C3 mirror of `ValidIn`. -/
def ValidC3In (fc : ProofSystem.FrameClass) (φ : Formula) : Prop :=
  ∀ F : TaskFrame, fc.Sat F → ValidC3 F φ

/-- C4 validity on every frame of the class the tag `fc` denotes: the C4 mirror of `ValidIn`. -/
def ValidC4In (fc : ProofSystem.FrameClass) (φ : Formula) : Prop :=
  ∀ F : TaskFrame, fc.Sat F → ValidC4 F φ

/-- **C3 consequence** from a finite context, over every frame satisfying `P`: the C3 mirror of
`ConsequenceOnFrames`, with "possible world `τ` and time `x ∈ D`" replaced by "convex history
`τ` and time `x ∈ dom τ`". -/
def ConsequenceC3 (P : TaskFrame → Prop) (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : PartialHistory F), τ.IsConvex →
    ∀ x : F.Duration, τ.domain x →
      (∀ ψ ∈ Γ, TruthAtConvex M τ x ψ) → TruthAtConvex M τ x φ

/-- **C4 consequence** from a finite context, over every frame satisfying `P`: `ConsequenceC3`
with the index restricted to interval histories. -/
def ConsequenceC4 (P : TaskFrame → Prop) (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : PartialHistory F), IsInterval τ →
    ∀ x : F.Duration, τ.domain x →
      (∀ ψ ∈ Γ, TruthAtConvex M τ x ψ) → TruthAtConvex M τ x φ

/-! ## Clause lemmas

The derived connectives unfold through `imp` and `bot`, and the derived tense operators through
`untl` and `snce` with a `⊤` guard. These lemmas state each clause once, so that the survival
proofs never unfold `Formula.and` or `Formula.allFuture` by hand. -/

namespace TruthAtConvex

/-- Truth of `φ ∧ ψ` under C3. Classical: `and` is the double-negated implication. -/
theorem and_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) (φ ψ : Formula) :
    TruthAtConvex M τ t (φ.and ψ) ↔ TruthAtConvex M τ t φ ∧ TruthAtConvex M τ t ψ := by
  change ((_ → (_ → False)) → False) ↔ _
  tauto

/-- Truth of `Fφ` under C3: a later time **in the index's domain** where `φ` holds. -/
theorem someFuture_iff (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration) (φ : Formula) :
    TruthAtConvex M τ x (Formula.someFuture φ) ↔
      ∃ s, τ.domain s ∧ x < s ∧ TruthAtConvex M τ s φ :=
  ⟨fun ⟨s, hs, hxs, hφ, _⟩ => ⟨s, hs, hxs, hφ⟩,
   fun ⟨s, hs, hxs, hφ⟩ => ⟨s, hs, hxs, hφ, fun _ _ _ _ h => h⟩⟩

/-- Truth of `Pφ` under C3: an earlier time **in the index's domain** where `φ` holds. -/
theorem somePast_iff (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration) (φ : Formula) :
    TruthAtConvex M τ x (Formula.somePast φ) ↔
      ∃ s, τ.domain s ∧ s < x ∧ TruthAtConvex M τ s φ :=
  ⟨fun ⟨s, hs, hsx, hφ, _⟩ => ⟨s, hs, hsx, hφ⟩,
   fun ⟨s, hs, hsx, hφ⟩ => ⟨s, hs, hsx, hφ, fun _ _ _ _ h => h⟩⟩

/-- Truth of `Gφ` under C3: `φ` at every later time of the index's domain. Vacuously true at a
right endpoint. -/
theorem allFuture_iff (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration) (φ : Formula) :
    TruthAtConvex M τ x (Formula.allFuture φ) ↔
      ∀ s, τ.domain s → x < s → TruthAtConvex M τ s φ := by
  constructor
  · intro h s hs hxs
    by_contra hcon
    exact h ((someFuture_iff M τ x φ.neg).mpr ⟨s, hs, hxs, hcon⟩)
  · intro h hcon
    obtain ⟨s, hs, hxs, hneg⟩ := (someFuture_iff M τ x φ.neg).mp hcon
    exact hneg (h s hs hxs)

/-- Truth of `Hφ` under C3: `φ` at every earlier time of the index's domain. Vacuously true at
a left endpoint. -/
theorem allPast_iff (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration) (φ : Formula) :
    TruthAtConvex M τ x (Formula.allPast φ) ↔
      ∀ s, τ.domain s → s < x → TruthAtConvex M τ s φ := by
  constructor
  · intro h s hs hsx
    by_contra hcon
    exact h ((somePast_iff M τ x φ.neg).mpr ⟨s, hs, hsx, hcon⟩)
  · intro h hcon
    obtain ⟨s, hs, hsx, hneg⟩ := (somePast_iff M τ x φ.neg).mp hcon
    exact hneg (h s hs hsx)

/-- Truth of `K⁺φ` under C3: `φ` holds arbitrarily soon after `t`, **within the domain**. At a
right endpoint of the domain there is no later domain time, so `K⁺φ` is vacuously true there. -/
theorem kPlus_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) (φ : Formula) :
    TruthAtConvex M τ t φ.kPlus ↔
      ∀ s, τ.domain s → t < s → ∃ r, τ.domain r ∧ t < r ∧ r < s ∧ TruthAtConvex M τ r φ := by
  change (¬ ∃ s, τ.domain s ∧ t < s ∧ (False → False) ∧
      ∀ r, τ.domain r → t < r → r < s → (TruthAtConvex M τ r φ → False)) ↔ _
  constructor
  · intro h s hs hts
    by_contra hc
    exact h ⟨s, hs, hts, id, fun r hr h1 h2 hφ => hc ⟨r, hr, h1, h2, hφ⟩⟩
  · rintro h ⟨s, hs, hts, -, hno⟩
    obtain ⟨r, hr, h1, h2, hφ⟩ := h s hs hts
    exact hno r hr h1 h2 hφ

/-- Truth of `K⁻φ` under C3: `φ` holds arbitrarily recently before `t`, **within the domain**.
Vacuously true at a left endpoint of the domain. -/
theorem kMinus_iff (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) (φ : Formula) :
    TruthAtConvex M τ t φ.kMinus ↔
      ∀ s, τ.domain s → s < t → ∃ r, τ.domain r ∧ s < r ∧ r < t ∧ TruthAtConvex M τ r φ := by
  change (¬ ∃ s, τ.domain s ∧ s < t ∧ (False → False) ∧
      ∀ r, τ.domain r → s < r → r < t → (TruthAtConvex M τ r φ → False)) ↔ _
  constructor
  · intro h s hs hts
    by_contra hc
    exact h ⟨s, hs, hts, id, fun r hr h1 h2 hφ => hc ⟨r, hr, h1, h2, hφ⟩⟩
  · rintro h ⟨s, hs, hts, -, hno⟩
    obtain ⟨r, hr, h1, h2, hφ⟩ := h s hs hts
    exact hno r hr h1 h2 hφ

end TruthAtConvex

/-! ## Interval and one-point histories are convex -/

/-- An interval history is convex, so every C4 index is a C3 index. -/
theorem IsInterval.isConvex {τ : PartialHistory F} (h : IsInterval τ) : τ.IsConvex := by
  obtain ⟨a, b, hab⟩ := h
  intro x z hx hz y hxy hyz
  exact (hab y).mpr ⟨le_trans ((hab x).mp hx).1 hxy, le_trans hyz ((hab z).mp hz).2⟩

/-- The one-point partial history `{⟨x, w⟩}` is convex: its domain is a singleton. It is a legal
C3 index at its own point, for every world state `w` — a **germ**. -/
theorem PartialHistory.point_isConvex (F : TaskFrame) [F.IsRegular]
    (w : F.WorldState) (x : F.Duration) :
    (PartialHistory.point F w x).IsConvex := by
  intro a c ha hc y hay hyc
  have ha' : a = x := ha
  have hc' : c = x := hc
  subst ha'
  exact le_antisymm (hc' ▸ hyc) hay

/-! ## Containment, and the index-independence of the box -/

/-- C4 is a restriction of C3: every C3-validity is a C4-validity. The containment is strict —
`validC4_lastPoint` and `refute_C3_lastPoint` in `Metalogic/ConvexConsequence/Separations.lean`
separate the two. -/
theorem validC3_imp_validC4 {φ : Formula} (h : ValidC3 F φ) : ValidC4 F φ :=
  fun M τ hτ x hx => h M τ hτ.isConvex x hx

/--
**C3's `□` does not depend on the index.** Its clause reads its quantifier range off the
evaluation time `x` alone — the convex `σ` with `x ∈ dom σ` — so `□φ` at `(τ, x)` and at
`(τ', x)` are the same proposition.

This is the structural fact that makes the S5 core survive C3: `□` is still a universal modality
over a set determined by `x`, and that set still contains the index itself, because a C3 index
is convex with `x` in its domain. What C3 changes is the *range* of `□`, not its character.
-/
theorem truthC3_box_indep (M : TaskModel F) (τ τ' : PartialHistory F) (x : F.Duration)
    (φ : Formula) :
    TruthAtConvex M τ x (Formula.box φ) ↔ TruthAtConvex M τ' x (Formula.box φ) :=
  Iff.rfl

/-! ## Germ structure: both binary tense operators are false at a germ -/

/-- At a germ, `φ U ψ` is false: its witness would have to lie in a one-point domain and be
strictly later than that point. -/
theorem germ_untl_false [F.IsRegular]
    (M : TaskModel F) (w : F.WorldState) (x : F.Duration) (ψ φ : Formula) :
    ¬ TruthAtConvex M (PartialHistory.point F w x) x (Formula.untl ψ φ) := by
  rintro ⟨s, hs, hxs, -, -⟩
  have hs' : s = x := hs
  exact lt_irrefl x (hs' ▸ hxs)

/-- At a germ, `φ S ψ` is false, symmetrically. -/
theorem germ_snce_false [F.IsRegular]
    (M : TaskModel F) (w : F.WorldState) (x : F.Duration) (ψ φ : Formula) :
    ¬ TruthAtConvex M (PartialHistory.point F w x) x (Formula.snce ψ φ) := by
  rintro ⟨s, hs, hsx, -, -⟩
  have hs' : s = x := hs
  exact lt_irrefl x (hs' ▸ hsx)

/--
**`□(φ U ψ)` is C3-unsatisfiable**, at every model, every index and every time, over an
arbitrary task frame. The germ at `x` is always in C3's box range at `x`, and no binary tense
formula is true at a germ.

This is the most consequential structural fact about the primary box range. TM derives `F⊤` and
is closed under necessitation, so it derives `□F⊤`; under C3 that formula is not merely invalid
but unsatisfiable. The failure falls on every formula whose body under `□` has a binary tense
operator as its principal connective, not on `F⊤` alone.
-/
theorem c3_box_untl_unsat [F.IsRegular] (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration)
    (ψ φ : Formula) : ¬ TruthAtConvex M τ x (Formula.box (Formula.untl ψ φ)) := fun h =>
  germ_untl_false M F.worldNonempty.some x ψ φ
    (h (PartialHistory.point F F.worldNonempty.some x)
      (PartialHistory.point_isConvex F F.worldNonempty.some x) rfl)

/-- The past dual of `c3_box_untl_unsat`: `□(φ S ψ)` is C3-unsatisfiable. -/
theorem c3_box_snce_unsat [F.IsRegular] (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration)
    (ψ φ : Formula) : ¬ TruthAtConvex M τ x (Formula.box (Formula.snce ψ φ)) := fun h =>
  germ_snce_false M F.worldNonempty.some x ψ φ
    (h (PartialHistory.point F F.worldNonempty.some x)
      (PartialHistory.point_isConvex F F.worldNonempty.some x) rfl)

/-- **C3 is closed under necessitation**, semantically: a C3-validity is true at every convex
index through the evaluation time, which is exactly what `□` asks for. -/
theorem c3_nec {φ : Formula} (h : ValidC3 F φ) : ValidC3 F (Formula.box φ) :=
  fun M _τ _hτ x _hx σ hσc hσ => h M σ hσc x hσ

/--
**Every C3-validity is germ-valid**: take the index to be the germ at `x`.

Combined with `c3_nec` and `c3_box_untl_unsat`, this is the governing constraint on the C3
validities: each must survive evaluation at a one-point domain, where every binary tense
operator is false. `F⊤` does not, which is why seriality goes.
-/
theorem c3_valid_imp_germ_valid [F.IsRegular] {φ : Formula} (h : ValidC3 F φ) (M : TaskModel F)
    (w : F.WorldState) (x : F.Duration) :
    TruthAtConvex M (PartialHistory.point F w x) x φ :=
  h M (PartialHistory.point F w x) (PartialHistory.point_isConvex F w x) x rfl

/-! ## Shift invariance, and the time-uniform box -/

/--
**C3 truth is invariant under time translation of the index.**

`TruthAtConvex M (σ.timeShift Δ) z φ ↔ TruthAtConvex M σ (z + Δ) φ`, for every formula, index,
time and offset. The box case is the substantive one: the convex histories through `z` and the
convex histories through `z + Δ` are exchanged by `PartialHistory.timeShift`, with
`PartialHistory.isConvex_timeShift` carrying convexity across in both directions, so C3's box
range translates along with everything else.

This is the C3 analogue of `app:auto_existence` (the possible worlds are closed under
translation). It is what makes C3 a time-uniform semantics even though its indices are bounded,
and it is the lemma that settles `□φ → □Gφ`.
-/
theorem truthC3_timeShift (M : TaskModel F) (φ : Formula) :
    ∀ (σ : PartialHistory F) (z Δ : F.Duration),
      TruthAtConvex M (σ.timeShift Δ) z φ ↔ TruthAtConvex M σ (z + Δ) φ := by
  induction φ with
  | atom p => intro _ _ _; exact Iff.rfl
  | bot => intro _ _ _; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro σ z Δ; exact imp_congr (ihφ σ z Δ) (ihψ σ z Δ)
  | box φ ih =>
      intro σ z Δ
      constructor
      · intro h ρ hρc hρ
        exact (ih ρ z Δ).mp (h (ρ.timeShift Δ) (PartialHistory.isConvex_timeShift hρc Δ) hρ)
      · intro h ρ hρc hρ
        have hdom : (ρ.timeShift (-Δ)).domain (z + Δ) := by
          change ρ.domain (z + Δ + -Δ)
          simpa using hρ
        have hz := (ih ρ (z + Δ) (-Δ)).mp
          (h _ (PartialHistory.isConvex_timeShift hρc (-Δ)) hdom)
        simpa using hz
  | untl ψ φ ihψ ihφ =>
      intro σ z Δ
      constructor
      · rintro ⟨s, hs, hzs, hφ, hψ⟩
        refine ⟨s + Δ, hs, add_lt_add_of_lt_of_le hzs (le_refl Δ), (ihφ σ s Δ).mp hφ, ?_⟩
        intro r hr hzr hrs
        have hback : r - Δ + Δ = r := sub_add_cancel r Δ
        have hdom : (σ.timeShift Δ).domain (r - Δ) := by
          change σ.domain (r - Δ + Δ); rw [hback]; exact hr
        have h1 : z < r - Δ := by
          have := hzr; rw [← hback] at this; exact lt_of_add_lt_add_right this
        have h2 : r - Δ < s := by
          have := hrs; rw [← hback] at this; exact lt_of_add_lt_add_right this
        have := (ihψ σ (r - Δ) Δ).mp (hψ (r - Δ) hdom h1 h2)
        rwa [hback] at this
      · rintro ⟨s, hs, hzs, hφ, hψ⟩
        have hback : s - Δ + Δ = s := sub_add_cancel s Δ
        have hdom : (σ.timeShift Δ).domain (s - Δ) := by
          change σ.domain (s - Δ + Δ); rw [hback]; exact hs
        have h1 : z < s - Δ := by
          have := hzs; rw [← hback] at this; exact lt_of_add_lt_add_right this
        refine ⟨s - Δ, hdom, h1, (ihφ σ (s - Δ) Δ).mpr (by rw [hback]; exact hφ), ?_⟩
        intro r hr hzr hrs
        refine (ihψ σ r Δ).mpr (hψ (r + Δ) hr (add_lt_add_of_lt_of_le hzr (le_refl Δ)) ?_)
        have := add_lt_add_of_lt_of_le hrs (le_refl Δ)
        rwa [hback] at this
  | snce ψ φ ihψ ihφ =>
      intro σ z Δ
      constructor
      · rintro ⟨s, hs, hsz, hφ, hψ⟩
        refine ⟨s + Δ, hs, add_lt_add_of_lt_of_le hsz (le_refl Δ), (ihφ σ s Δ).mp hφ, ?_⟩
        intro r hr hsr hrz
        have hback : r - Δ + Δ = r := sub_add_cancel r Δ
        have hdom : (σ.timeShift Δ).domain (r - Δ) := by
          change σ.domain (r - Δ + Δ); rw [hback]; exact hr
        have h1 : s < r - Δ := by
          have := hsr; rw [← hback] at this; exact lt_of_add_lt_add_right this
        have h2 : r - Δ < z := by
          have := hrz; rw [← hback] at this; exact lt_of_add_lt_add_right this
        have := (ihψ σ (r - Δ) Δ).mp (hψ (r - Δ) hdom h1 h2)
        rwa [hback] at this
      · rintro ⟨s, hs, hsz, hφ, hψ⟩
        have hback : s - Δ + Δ = s := sub_add_cancel s Δ
        have hdom : (σ.timeShift Δ).domain (s - Δ) := by
          change σ.domain (s - Δ + Δ); rw [hback]; exact hs
        have h1 : s - Δ < z := by
          have := hsz; rw [← hback] at this; exact lt_of_add_lt_add_right this
        refine ⟨s - Δ, hdom, h1, (ihφ σ (s - Δ) Δ).mpr (by rw [hback]; exact hφ), ?_⟩
        intro r hr hsr hrz
        refine (ihψ σ r Δ).mpr (hψ (r + Δ) hr ?_ (add_lt_add_of_lt_of_le hrz (le_refl Δ)))
        have := add_lt_add_of_lt_of_le hsr (le_refl Δ)
        rwa [hback] at this

/--
**C3's box is time-uniform.** If `□φ` holds at `x` then it holds at every time `y` and every
index, because the convex histories through `x` and through `y` are exchanged by
`PartialHistory.timeShift` and `truthC3_timeShift` carries truth across.
-/
theorem c3_box_time_uniform (M : TaskModel F) (τ τ' : PartialHistory F) (x y : F.Duration)
    (φ : Formula) (h : TruthAtConvex M τ x (Formula.box φ)) :
    TruthAtConvex M τ' y (Formula.box φ) := by
  intro ρ hρc hρ
  have hxy : x + (y - x) = y := add_sub_cancel x y
  have hdom : (ρ.timeShift (y - x)).domain x := by
    change ρ.domain (x + (y - x))
    rw [hxy]; exact hρ
  have h2 := (truthC3_timeShift M φ ρ x (y - x)).mp
    (h (ρ.timeShift (y - x)) (PartialHistory.isConvex_timeShift hρc (y - x)) hdom)
  rwa [hxy] at h2

end FormalSystem.Semantics
