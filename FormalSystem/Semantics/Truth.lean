/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.WorldHistory
import FormalSystem.Syntax.Formula

/-!
# Truth - Truth Evaluation in Task Semantics

This module defines truth evaluation for TM formulas in task models.

**Irreflexive Temporal Semantics (A2 Guard Convention)**: Temporal operators G (allFuture)
and H (allPast) use STRICT semantics (< instead of ≤), meaning "all strictly
future/past times" (excluding the present). Under irreflexive semantics, the
T-axioms (Gφ → φ, Hφ → φ) are NOT valid. Until uses strict witness (s > t) with
open guard (t, s). Since uses strict witness (s < t) with open guard (s, t).

This is the open guard convention: strict witness, open guard. The seriality
axioms (⊤ → F(⊤), ⊤ → P(⊤)) replace the T-axioms (BX1/BX1').

## Paper Specification Reference

**Bimodal Logic Semantics (app:TaskSemantics, def:BL-semantics, lines 1857-1872)**:
The JPL paper defines truth evaluation for TM formulas. Our implementation uses
strict temporal quantification (a refinement of the paper's reflexive convention):
- `M,τ,x ⊨ p` iff `x ∈ dom(τ)` AND `τ(x) ∈ V(p)` (atom satisfaction, line 892)
- `M,τ,x ⊨ ⊥` is false (bottom)
- `M,τ,x ⊨ φ → ψ` iff `M,τ,x ⊨ φ` implies `M,τ,x ⊨ ψ` (implication)
- `M,τ,x ⊨ □φ` iff `M,σ,x ⊨ φ` for all σ ∈ H_F, the total histories (box: necessity)
- `M,τ,x ⊨ Past φ` iff `M,τ,y ⊨ φ` for all y ∈ D where y ≤ x (past, reflexive)
- `M,τ,x ⊨ Future φ` iff `M,τ,y ⊨ φ` for all y ∈ D where x ≤ y (future, reflexive)

**Critical Semantic Design (lines 899-919)**:
The paper explicitly quantifies temporal operators over ALL times `y ∈ D` (the entire
temporal order), NOT just times in `dom(τ)`. This is a deliberate design choice:
- Atoms at times outside domain are FALSE (not undefined)
- Temporal operators see "beyond" the history's domain
- This matters for finite histories (e.g., chess game ending at move 31)

**ProofChecker Implementation Alignment**:
✓ Atom: `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`
  matches paper's domain check at line 892 (atoms false outside domain)
✓ Bot: `False` matches paper's definition
✓ Imp: Standard material conditional matches paper
✓ Box: `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ`
  matches paper's quantification over σ ∈ H_F (the frame's total histories)
✓ Past (H): via `@[simp] past_iff`: `∀ s, s < t → TruthAt M τ s φ`
  uses strict ordering (all past times, excluding now); derived via def + Until/Since
✓ Future (G): via `@[simp] future_iff`: `∀ s, t < s → TruthAt M τ s φ`
  uses strict ordering (all future times, excluding now); derived via def + Until/Since

## Main Definitions

- `TruthAt`: Truth of a formula at a model-history-time triple
- No notation defined (parsing conflicts with validity notation)

## Main Results

- Basic truth lemmas (e.g., `bot` is always false)
- Truth evaluation examples
- Time-shift preservation theorems for temporal operators

## Note on Bridge Theorems

Bridge theorems connecting the proof system to semantics (temporal duality infrastructure)
have been moved to `Metalogic/SoundnessLemmas.lean` to resolve circular dependencies.
See SoundnessLemmas.lean for details on the module hierarchy restructuring.

## Implementation Notes

- Truth is defined recursively on 6 formula constructors (atom, bot, imp, box, untl, snce)
- Modal box quantifies over all world histories at current time
- Until/Since use strict witness (s > t / s < t) with open guards (t,s) / (s,t)
- G/H/F/P are `def` abbreviations with `@[simp]` characterization theorems
- Atoms are false at times outside the history's domain

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Truth evaluation
  specification
* [Formula.lean](../Syntax/Formula.lean) - Formula syntax
* [TaskModel.lean](TaskModel.lean) - Task model structure
* JPL Paper app:TaskSemantics (def:BL-semantics, lines 1857-1872) - Formal truth definition
* JPL Paper lines 892-919 - Semantic design rationale
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] {F : TaskFrame D}

/--
Truth of a formula at a model-history-time triple.

Given:
- `M`: A task model (frame + valuation)
- `τ`: A world history (function from times to states)
- `t`: A time point
- `φ`: A formula

Returns whether `φ` is true at this semantic configuration.

The evaluation is defined recursively on formula structure (6 constructors):
- Atoms: true iff there exists a proof that t is in the history's domain
  AND valuation says so at current state (atoms are false at times outside domain)
- Bot (⊥): always false
- Implication: standard material conditional
- Box (□): true iff φ true at all **total** world histories at time t
- Until `φ U ψ`: ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r) (guard φ first, event ψ second)
- Since `φ S ψ`: ∃ s < t, ψ(s) ∧ ∀ r ∈ (s,t), φ(r) (guard φ first, event ψ second)

G (allFuture), H (allPast), F (someFuture), P (somePast) are `def` abbreviations
with `@[simp]` characterization theorems (see `future_iff`, `past_iff`, etc.).

**Paper Reference**: `def:BL-semantics`'s box clause, verbatim: "M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ
for all σ ∈ H_F". The quantifier ranges over `H_F` — the TOTAL histories — with no `Ω` and no
shift-closure side condition. `WorldHistory.IsTotal` is the predicate form of `H_F` membership
(Decision A of `specs/decisions/total-history-validity-decisions.md`); it is deliberately **not**
Mathlib's `IsMax` or any order-theoretic maximality predicate.

**There is no admissible-history parameter.** `TruthAt` takes the model, the history, the time
and the formula, and nothing else. The designated-carrier argument that earlier revisions
threaded through every clause has been deleted outright: the box clause reads its quantifier
range off `WorldHistory.IsTotal`, so no set-valued parameter can narrow, widen, or otherwise
influence the meaning of any connective.

**Atom clause** (Decision A, accepted gap): the `∃ (ht : τ.domain t)` conjunct is retained even
though `def:BL-semantics`'s atom clause has no domain conjunct. Under totality the conjunct is
vacuously satisfiable at every `t`, so the two readings agree on `H_F`; the conjunct is what keeps
`TruthAt` meaningful at the partial histories that the extension machinery still traffics in.

**Until / Since argument order**: `untl`/`snce` are **guard-first / event-second** — `untl φ ψ`
reads "φ is the guard, ψ is the event". The two clauses below transcribe
`def:BLplus-semantics`'s clause bodies directly:

- (since) "M,τ,x ⊨ φ since ψ *iff* M,τ,z ⊨ ψ for some time z < x where M,τ,y ⊨ φ for all y ∈ D
  with z < y < x."
- (until) "M,τ,x ⊨ φ until ψ *iff* M,τ,z ⊨ ψ for some time z > x where M,τ,y ⊨ φ for all y ∈ D
  with x < y < z."

In both, the existential witness is the **second** argument and the universally quantified
open-interval condition is the **first**. `def:BLplus-defined` corroborates independently:
`past φ := ⊤ since φ`, `future φ := ⊤ until φ`, `Next φ := ⊥ until φ`, `Previous φ := ⊥ since φ`
— in each the operand is the event and sits second. `Formula.someFuture φ = untl ⊤ φ` and
`Formula.next φ = untl ⊥ φ` match character for character.

Earlier revisions of this docstring quoted an argument-order **footnote** of
`def:BLplus-semantics` and asserted that the Lean tree was deliberately event-first. Both are
retired: the tracked anchor (sha256 `edde7517…`) carries no footnote, and the tree was aligned
to the paper by a uniform argument swap of the definition and every call site. See
`specs/decisions/untl-snce-argument-order.md`. These clauses are τ-local and are untouched by the
box retarget.
-/
def TruthAt (M : TaskModel F)
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ
  | Formula.untl ψ φ => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce ψ φ => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M τ r ψ

-- Note: We avoid defining a notation for TruthAt as it causes parsing conflicts
-- with the validity notation in Validity.lean. Use TruthAt directly.

namespace Truth

/--
Bot (⊥) is false everywhere.
-/
theorem bot_false
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} :
    ¬(TruthAt M τ t Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
theorem imp_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ ψ : Formula) :
    (TruthAt M τ t (φ.imp ψ)) ↔
      ((TruthAt M τ t φ) → (TruthAt M τ t ψ)) := by
  rfl

/--
Truth of atom at a time in the domain: true iff valuation says so at current state.
For times outside domain, atoms are always false.
-/
theorem atom_iff_of_domain
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} (ht : τ.domain t)
    (p : Atom) :
    (TruthAt M τ t (Formula.atom p)) ↔
      M.valuation (τ.states t ht) p := by
  simp only [TruthAt]
  constructor
  · intro ⟨ht', h⟩
    -- By proof irrelevance, τ.states t ht' = τ.states t ht
    exact h
  · intro h
    exact ⟨ht, h⟩

/--
Truth of atom at a time outside the domain is false.
-/
theorem atom_false_of_not_domain
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D} (ht : ¬τ.domain t)
    (p : Atom) :
    ¬(TruthAt M τ t (Formula.atom p)) := by
  simp only [TruthAt]
  intro ⟨ht', _⟩
  exact ht ht'

/--
Truth of box: formula true at every **total** history at the current time.

**Paper Reference**: `def:BL-semantics`'s box clause, "M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ for all
σ ∈ H_F". The quantifier's range is `WorldHistory.IsTotal`, taken directly from the frame; there
is no carrier parameter to supply.
-/
theorem box_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    (TruthAt M τ t φ.box) ↔
      ∀ (σ : WorldHistory F), σ.IsTotal → (TruthAt M σ t φ) := by
  rfl

/--
Truth of someFuture: existential future operator.
F(φ) = U(φ, ⊤) is true iff there exists a strictly future time where φ holds.
-/
@[simp] theorem some_future_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    TruthAt M τ t (Formula.someFuture φ) ↔
      ∃ s, t < s ∧ TruthAt M τ s φ := by
  simp only [Formula.someFuture, Formula.top, TruthAt]
  constructor
  · rintro ⟨s, hlt, hevent, _⟩
    exact ⟨s, hlt, hevent⟩
  · rintro ⟨s, hlt, hs⟩
    exact ⟨s, hlt, hs, fun _ _ _ => id⟩

/--
Truth of somePast: existential past operator.
P(φ) = S(φ, ⊤) is true iff there exists a strictly past time where φ held.
-/
@[simp] theorem some_past_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    TruthAt M τ t (Formula.somePast φ) ↔
      ∃ s, s < t ∧ TruthAt M τ s φ := by
  simp only [Formula.somePast, Formula.top, TruthAt]
  constructor
  · rintro ⟨s, hlt, hevent, _⟩
    exact ⟨s, hlt, hevent⟩
  · rintro ⟨s, hlt, hs⟩
    exact ⟨s, hlt, hs, fun _ _ _ => id⟩

/--
Truth of allFuture: universal future operator.
G(φ) = ¬F(¬φ) is true iff φ holds at all strictly future times.
-/
@[simp] theorem future_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    TruthAt M τ t φ.allFuture ↔
      ∀ (s : D), t < s → TruthAt M τ s φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, TruthAt]
  constructor
  · intro h s hlt
    by_contra hns
    exact h ⟨s, hlt, fun hs => hns hs, fun _ _ _ => id⟩
  · intro h ⟨s, hlt, hevent, _⟩
    exact hevent (h s hlt)

/--
Truth of allPast: universal past operator.
H(φ) = ¬P(¬φ) is true iff φ holds at all strictly past times.
-/
@[simp] theorem past_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ : Formula) :
    TruthAt M τ t φ.allPast ↔
      ∀ (s : D), s < t → TruthAt M τ s φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, TruthAt]
  constructor
  · intro h s hlt
    by_contra hns
    exact h ⟨s, hlt, fun hs => hns hs, fun _ _ _ => id⟩
  · intro h ⟨s, hlt, hevent, _⟩
    exact hevent (h s hlt)

/--
Truth of strongRelease: M(φ, ψ) = ψ U (ψ ∧ φ).
True iff there exists a strictly future time where ψ ∧ φ holds,
with ψ holding at all intermediate times.
-/
@[simp] theorem strong_release_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ ψ : Formula) :
    TruthAt M τ t (Formula.strongRelease φ ψ) ↔
      ∃ s : D, t < s ∧ TruthAt M τ s (Formula.and ψ φ) ∧
        ∀ r : D, t < r → r < s → TruthAt M τ r ψ := by
  simp [Formula.strongRelease, Formula.and, TruthAt]

/--
Truth of strongTrigger: ST(φ, ψ) = ψ S (ψ ∧ φ).
True iff there exists a strictly past time where ψ ∧ φ held,
with ψ holding at all intermediate times.
-/
@[simp] theorem strong_trigger_iff
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F}
    {t : D}
    (φ ψ : Formula) :
    TruthAt M τ t (Formula.strongTrigger φ ψ) ↔
      ∃ s : D, s < t ∧ TruthAt M τ s (Formula.and ψ φ) ∧
        ∀ r : D, s < r → r < t → TruthAt M τ r ψ := by
  simp [Formula.strongTrigger, Formula.and, TruthAt]

end Truth

/-! ## Time-Shift Preservation

These lemmas establish that truth is preserved under time-shift transformations.
This is fundamental to proving the MF and TF axioms valid.

The key insight is that for a formula φ:
  `TruthAt M σ y φ ↔ TruthAt M (timeShift σ (y - x)) x φ`

This relates truth at (σ, y) to truth at (shifted_σ, x).

Note: With the new semantics where temporal operators quantify over ALL times (not just
domain times), these proofs become simpler since we don't need to thread domain proofs.
-/

namespace TimeShift

/--
Truth transport across equal histories.

When two histories are equal, truth is preserved.
-/
theorem truth_history_eq (M : TaskModel F)
    (τ₁ τ₂ : WorldHistory F) (t : D)
    (h_eq : τ₁ = τ₂) (φ : Formula) :
    TruthAt M τ₁ t φ ↔ TruthAt M τ₂ t φ := by
  cases h_eq
  rfl

/--
Truth at double time-shift with opposite amounts equals truth at original history.

This is the key transport lemma for the box case of time_shift_preserves_truth.
It allows us to transfer truth from (timeShift (timeShift σ Δ) (-Δ)) back to σ.
-/
theorem truth_double_shift_cancel (M : TaskModel F)
    (σ : WorldHistory F) (Δ : D) (t : D)
    (φ : Formula) :
    TruthAt M (WorldHistory.timeShift (WorldHistory.timeShift σ Δ) (-Δ)) t φ ↔
    TruthAt M σ t φ := by
  induction φ generalizing t with
  | atom p =>
    simp only [TruthAt]
    -- Both sides check domain membership and get the same state
    -- Domain equivalence: double-shift domain at t iff σ.domain t
    constructor
    · intro ⟨ht', h⟩
      have ht : σ.domain t := (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ t).mp ht'
      have h_eq := WorldHistory.time_shift_time_shift_neg_states σ Δ t ht ht'
      exact ⟨ht, by rw [← h_eq]; exact h⟩
    · intro ⟨ht, h⟩
      have ht' : (WorldHistory.timeShift (WorldHistory.timeShift σ Δ) (-Δ)).domain t :=
        (WorldHistory.time_shift_time_shift_neg_domain_iff σ Δ t).mpr ht
      have h_eq := WorldHistory.time_shift_time_shift_neg_states σ Δ t ht ht'
      exact ⟨ht', by rw [h_eq]; exact h⟩
  | bot =>
    simp only [TruthAt]
  | imp ψ χ ih_ψ ih_χ =>
    simp only [TruthAt]
    constructor
    · intro h h_ψ
      have h_ψ' := (ih_ψ t).mpr h_ψ
      exact (ih_χ t).mp (h h_ψ')
    · intro h h_ψ'
      have h_ψ := (ih_ψ t).mp h_ψ'
      exact (ih_χ t).mpr (h h_ψ)
  | box ψ ih =>
    simp only [TruthAt]
    -- Box quantifies over the total histories at time t, independent of the current history.
    -- Both sides quantify over the same `IsTotal` predicate, so this is definitionally closed
    -- and leaves no residual goal.
  | untl ψ φ ih_ψ ih_φ =>
    simp only [TruthAt]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mp h_event, fun r hr1 hr2 => (ih_ψ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mpr h_event, fun r hr1 hr2 => (ih_ψ r).mpr (h_guard r hr1 hr2)⟩
  | snce ψ φ ih_ψ ih_φ =>
    simp only [TruthAt]
    constructor
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mp h_event, fun r hr1 hr2 => (ih_ψ r).mp (h_guard r hr1 hr2)⟩
    · intro ⟨s, h_le, h_event, h_guard⟩
      exact ⟨s, h_le, (ih_φ s).mpr h_event, fun r hr1 hr2 => (ih_ψ r).mpr (h_guard r hr1 hr2)⟩

/--
Time-shift preserves truth of formulas.

If σ is a history and Δ = y - x, then truth at (σ, y) equals truth at (timeShift σ Δ, x).

**Paper Reference**: lem:history-time-shift-preservation establishes this property.

The proof proceeds by structural induction on formulas:
- **Atom**: States match because (timeShift σ Δ).states x = σ.states (x + Δ) = σ.states y
- **Bot**: Both sides are False
- **Imp**: By induction hypothesis on subformulas
- **Box**: Both sides quantify over the total histories; `WorldHistory.isTotal_timeShift`
  supplies the shifted history's totality, enabling the bijection argument
- **Past/Future**: Times shift together with the history

**Key Insight**: **no shift-closure hypothesis is required.** Under the totality box clause the
shifted history's membership in the quantifier's range is `WorldHistory.isTotal_timeShift`,
definitionally `fun t => hρ (t + Δ)` — there is no closure condition left to assume, so this
statement is strictly stronger than the shift-closure-hypothesised version it replaces.
-/
theorem time_shift_preserves_truth (M : TaskModel F)
    (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    TruthAt M (WorldHistory.timeShift σ (y - x)) x φ ↔ TruthAt M σ y φ := by
  -- Proof by structural induction on φ
  induction φ generalizing x y σ with
  | atom p =>
    -- For atoms, we need to check domain membership in both cases
    -- (timeShift σ Δ).domain x iff σ.domain (x + Δ) = σ.domain y
    simp only [TruthAt, WorldHistory.timeShift]
    have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
    -- Domain at x in shifted history iff domain at y in original
    constructor
    · intro ⟨hx, h⟩
      have hy : σ.domain y := by rw [← h_eq]; exact hx
      -- States match: use states_eq_of_time_eq
      have h_states := WorldHistory.states_eq_of_time_eq σ (x + (y - x)) y h_eq hx hy
      exact ⟨hy, by rw [← h_states]; exact h⟩
    · intro ⟨hy, h⟩
      have hx : σ.domain (x + (y - x)) := by rw [h_eq]; exact hy
      have h_states := WorldHistory.states_eq_of_time_eq σ (x + (y - x)) y h_eq hx hy
      exact ⟨hx, by rw [h_states]; exact h⟩
  | bot =>
    -- Both sides are False
    simp only [TruthAt]
  | imp ψ χ ih_ψ ih_χ =>
    -- By IH on both subformulas
    simp only [TruthAt]
    constructor
    · intro h h_psi
      have h_psi' := (ih_ψ σ x y).mpr h_psi
      exact (ih_χ σ x y).mp (h h_psi')
    · intro h h_psi'
      have h_psi := (ih_ψ σ x y).mp h_psi'
      exact (ih_χ σ x y).mpr (h h_psi)
  | box ψ ih =>
    -- For box, both sides quantify over the total histories at their respective times.
    -- Totality of the shifted history is `isTotal_timeShift`, definitionally `fun t => hρ (t + Δ)`.
    simp only [TruthAt]
    constructor
    · intro h_box_x ρ h_rho_tot
      -- ρ is total, need to show truth at (ρ, y)
      -- timeShift ρ (y - x) is total by isTotal_timeShift
      have h_shifted_tot : (WorldHistory.timeShift ρ (y - x)).IsTotal :=
        WorldHistory.isTotal_timeShift h_rho_tot (y - x)
      have h1 := h_box_x (WorldHistory.timeShift ρ (y - x)) h_shifted_tot
      -- Apply IH with ρ instead of σ
      exact (ih ρ x y).mp h1
    · intro h_box_y ρ h_rho_tot
      -- ρ is total, need to show truth at (ρ, x)
      -- timeShift ρ (x - y) is total by isTotal_timeShift
      have h_shifted_tot : (WorldHistory.timeShift ρ (x - y)).IsTotal :=
        WorldHistory.isTotal_timeShift h_rho_tot (x - y)
      have h1 := h_box_y (WorldHistory.timeShift ρ (x - y)) h_shifted_tot
      -- Apply IH with timeShift ρ (x - y) instead of σ
      have h2 := (ih (WorldHistory.timeShift ρ (x - y)) x y).mpr h1
      -- h2 : TruthAt M (timeShift (timeShift ρ (x-y)) (y-x)) x ψ
      -- Need: TruthAt M ρ x ψ
      have h_cancel : y - x = -(x - y) := (neg_sub x y).symm
      have h_hist_eq :
        WorldHistory.timeShift (WorldHistory.timeShift ρ (x - y)) (y - x) =
        WorldHistory.timeShift (WorldHistory.timeShift ρ (x - y)) (-(x - y)) := by
        exact WorldHistory.time_shift_congr
          (WorldHistory.timeShift ρ (x - y)) (y - x) (-(x - y)) h_cancel
      have h2' := (truth_history_eq M _ _ x h_hist_eq ψ).mp h2
      exact (truth_double_shift_cancel M ρ (x - y) x ψ).mp h2'
  | untl ψ φ ih_ψ ih_φ =>
    -- Until (Burgess convention): untl(event=φ, guard=ψ)
    -- ∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r)
    -- Direction (→): shifted history at x → original history at y
    --   Witness s in shifted maps to s+(y-x) in original.
    -- Direction (←): original at y → shifted at x
    --   Witness s in original maps to s-(y-x) in shifted.
    simp only [TruthAt]
    constructor
    · -- (→) shifted at x → original at y
      intro ⟨s, h_x_lt_s, h_event_s, h_guard⟩
      -- Witness in original: s + (y - x)
      refine ⟨s + (y - x), ?_, ?_, ?_⟩
      · -- y < s + (y - x)
        have h := add_lt_add_right h_x_lt_s (y - x)
        have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
        calc y = x + (y - x) := h_eq.symm
          _ = (y - x) + x := add_comm x (y - x)
          _ < (y - x) + s := h
          _ = s + (y - x) := add_comm (y - x) s
      · -- φ (event) at (σ, s + (y - x))
        have h_shift_eq2 : (s + (y - x)) - s = y - x :=
          add_sub_cancel_left s (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ ((s + (y - x)) - s) =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((s + (y - x)) - s) (y - x) h_shift_eq2
        have h_conv := (truth_history_eq M _ _ s h_hist_eq.symm φ).mp h_event_s
        exact (ih_φ σ s (s + (y - x))).mp h_conv
      · -- guard: ∀ r, y < r → r < s + (y - x) → ψ(σ, r)
        intro r h_y_lt_r h_r_lt_s'
        have h_x_lt_r' : x < r - (y - x) := by
          have h := sub_lt_sub_right h_y_lt_r (y - x)
          simp only [sub_sub_cancel] at h
          exact h
        have h_r'_lt_s : r - (y - x) < s := by
          have h := sub_lt_sub_right h_r_lt_s' (y - x)
          simp only [add_sub_cancel_right] at h
          exact h
        have h_grd := h_guard (r - (y - x)) h_x_lt_r' h_r'_lt_s
        have h_shift_eq : r - (r - (y - x)) = y - x := sub_sub_cancel r (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ (r - (r - (y - x))) =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (r - (r - (y - x))) (y - x) h_shift_eq
        have h_conv := (truth_history_eq M _ _ (r - (y - x)) h_hist_eq.symm ψ).mp h_grd
        exact (ih_ψ σ (r - (y - x)) r).mp h_conv
    · -- (←) original at y → shifted at x
      intro ⟨s, h_y_lt_s, h_event_s, h_guard⟩
      -- Witness in shifted: s - (y - x)
      refine ⟨s - (y - x), ?_, ?_, ?_⟩
      · -- x < s - (y - x)
        have h := sub_lt_sub_right h_y_lt_s (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      · -- φ (event) at (shifted σ, s - (y - x))
        have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ (s - (s - (y - x))) =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
        have h_conv := (ih_φ σ (s - (y - x)) s).mpr h_event_s
        exact (truth_history_eq M _ _ (s - (y - x)) h_hist_eq φ).mp h_conv
      · -- guard: ∀ r', x < r' → r' < s - (y - x) → ψ(shifted σ, r')
        intro r' h_x_lt_r' h_r'_lt_s'
        have h_y_lt_r : y < r' + (y - x) := by
          have h := add_lt_add_right h_x_lt_r' (y - x)
          have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
          calc y = x + (y - x) := h_eq.symm
            _ = (y - x) + x := add_comm x (y - x)
            _ < (y - x) + r' := h
            _ = r' + (y - x) := add_comm (y - x) r'
        have h_r_lt_s : r' + (y - x) < s := by
          have h_eq : s - (y - x) + (y - x) = s := sub_add_cancel s (y - x)
          calc r' + (y - x) < s - (y - x) + (y - x) :=
                add_lt_add_left h_r'_lt_s' (y - x)
            _ = s := h_eq
        have h_grd := h_guard (r' + (y - x)) h_y_lt_r h_r_lt_s
        have h_shift_eq : (r' + (y - x)) - r' = y - x :=
          add_sub_cancel_left r' (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ ((r' + (y - x)) - r') =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((r' + (y - x)) - r')
            (y - x) h_shift_eq
        have h_conv := (ih_ψ σ r' (r' + (y - x))).mpr h_grd
        exact (truth_history_eq M _ _ r' h_hist_eq ψ).mp h_conv
  | snce ψ φ ih_ψ ih_φ =>
    -- Since (Burgess convention): snce(event=φ, guard=ψ)
    -- ∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r)
    -- Mirror of Until with reversed inequalities.
    simp only [TruthAt]
    constructor
    · -- (→) shifted at x → original at y
      intro ⟨s, h_s_lt_x, h_event_s, h_guard⟩
      -- Witness in original: s + (y - x)
      refine ⟨s + (y - x), ?_, ?_, ?_⟩
      · -- s + (y - x) < y
        have h := add_lt_add_right h_s_lt_x (y - x)
        calc s + (y - x) = (y - x) + s := add_comm s (y - x)
          _ < (y - x) + x := h
          _ = x + (y - x) := add_comm (y - x) x
          _ = y := by rw [add_sub, add_sub_cancel_left]
      · -- φ (event) at (σ, s + (y - x))
        have h_shift_eq : (s + (y - x)) - s = y - x :=
          add_sub_cancel_left s (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ ((s + (y - x)) - s) =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((s + (y - x)) - s)
            (y - x) h_shift_eq
        have h_conv := (truth_history_eq M _ _ s h_hist_eq.symm φ).mp h_event_s
        exact (ih_φ σ s (s + (y - x))).mp h_conv
      · -- guard: ∀ r, s + (y - x) < r → r < y → ψ(σ, r)
        intro r h_s'_lt_r h_r_lt_y
        have h_s_lt_r' : s < r - (y - x) := by
          have h := sub_lt_sub_right h_s'_lt_r (y - x)
          simp only [add_sub_cancel_right] at h
          exact h
        have h_r'_lt_x : r - (y - x) < x := by
          have h := sub_lt_sub_right h_r_lt_y (y - x)
          simp only [sub_sub_cancel] at h
          exact h
        have h_grd := h_guard (r - (y - x)) h_s_lt_r' h_r'_lt_x
        have h_shift_eq : r - (r - (y - x)) = y - x := sub_sub_cancel r (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ (r - (r - (y - x))) =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (r - (r - (y - x))) (y - x) h_shift_eq
        have h_conv := (truth_history_eq M _ _ (r - (y - x)) h_hist_eq.symm ψ).mp h_grd
        exact (ih_ψ σ (r - (y - x)) r).mp h_conv
    · -- (←) original at y → shifted at x
      intro ⟨s, h_s_lt_y, h_event_s, h_guard⟩
      -- Witness in shifted: s - (y - x)
      refine ⟨s - (y - x), ?_, ?_, ?_⟩
      · -- s - (y - x) < x
        have h := sub_lt_sub_right h_s_lt_y (y - x)
        simp only [sub_sub_cancel] at h
        exact h
      · -- φ (event) at (shifted σ, s - (y - x))
        have h_shift_eq : s - (s - (y - x)) = y - x := sub_sub_cancel s (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ (s - (s - (y - x))) =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ (s - (s - (y - x))) (y - x) h_shift_eq
        have h_conv := (ih_φ σ (s - (y - x)) s).mpr h_event_s
        exact (truth_history_eq M _ _ (s - (y - x)) h_hist_eq φ).mp h_conv
      · -- guard: ∀ r', s - (y - x) < r' → r' < x → ψ(shifted σ, r')
        intro r' h_s'_lt_r' h_r'_lt_x
        have h_s_lt_r : s < r' + (y - x) := by
          calc s = s - (y - x) + (y - x) := (sub_add_cancel s (y - x)).symm
            _ < r' + (y - x) := add_lt_add_left h_s'_lt_r' (y - x)
        have h_r_lt_y : r' + (y - x) < y := by
          have h_eq : x + (y - x) = y := by rw [add_sub, add_sub_cancel_left]
          calc r' + (y - x) < x + (y - x) := add_lt_add_left h_r'_lt_x (y - x)
            _ = y := h_eq
        have h_grd := h_guard (r' + (y - x)) h_s_lt_r h_r_lt_y
        have h_shift_eq : (r' + (y - x)) - r' = y - x :=
          add_sub_cancel_left r' (y - x)
        have h_hist_eq :
          WorldHistory.timeShift σ ((r' + (y - x)) - r') =
          WorldHistory.timeShift σ (y - x) := by
          exact WorldHistory.time_shift_congr σ ((r' + (y - x)) - r')
            (y - x) h_shift_eq
        have h_conv := (ih_ψ σ r' (r' + (y - x))).mpr h_grd
        exact (truth_history_eq M _ _ r' h_hist_eq ψ).mp h_conv

/--
Corollary: For any history σ at time y, there exists a history at time x
(namely, timeShift σ (y - x)) where the same formulas are true.

This is the key lemma for proving MF and TF axioms.
-/
theorem exists_shifted_history (M : TaskModel F)
    (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    TruthAt M σ y φ ↔
    TruthAt M (WorldHistory.timeShift σ (y - x)) x φ := by
  exact (time_shift_preserves_truth M σ x y φ).symm

end TimeShift

namespace Truth

/-!
## `□` is a model constant

The box clause quantifies over *all* total histories at a time. Under time-homogeneity of the task
relation that makes its truth value depend on neither the history nor the time — a boxed formula is
a fact about the model alone.

This block is placed after `TimeShift` rather than beside the other `Truth` clause lemmas because
its proof consumes `TimeShift.time_shift_preserves_truth`, which is declared there.
-/

/--
**A boxed formula's truth value is a constant of the model**: it depends on neither the history nor
the time.

Two very different reasons combine, and the docstring separates them deliberately so that neither
is over-engineered in the proof:

- **History-independence is definitional.** `def:BL-semantics`'s box clause is
  `∀ σ, σ.IsTotal → TruthAt M σ t φ` — it simply does not mention `τ`. Nothing has to be proved.
- **Time-independence is the substantive half**, and it is exactly time-homogeneity: given a total
  `ρ` at which `φ` is wanted at `s`, the `(s - t)`-shift of `ρ` is total
  (`WorldHistory.isTotal_timeShift`) and is covered by the hypothesis at `t`, and
  `TimeShift.time_shift_preserves_truth` transports the result back.

The `IsTotal` hypotheses on `τ` and `σ` are stated because that is the setting the result is used
in, but they are **not consumed**: the statement holds for arbitrary histories, precisely because
of the definitional half above.

This is what makes the box case of a finite-model truth lemma routine rather than the hardest
clause: the set of total histories over a finite carrier is still uncountable, but the box
*predicate* is constant on it, so a model has one finite set of box facts, computed once.
-/
theorem box_const (M : TaskModel F) (τ σ : WorldHistory F) (_hτ : τ.IsTotal) (_hσ : σ.IsTotal)
    (t s : D) (φ : Formula) :
    TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box := by
  simp only [TruthAt]
  constructor
  · intro h ρ hρ
    exact (TimeShift.time_shift_preserves_truth M ρ t s φ).mp
      (h (WorldHistory.timeShift ρ (s - t)) (WorldHistory.isTotal_timeShift hρ (s - t)))
  · intro h ρ hρ
    exact (TimeShift.time_shift_preserves_truth M ρ s t φ).mp
      (h (WorldHistory.timeShift ρ (t - s)) (WorldHistory.isTotal_timeShift hρ (t - s)))

/-- The time-only specialization of `box_const`, at a fixed history. -/
theorem box_time_const (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : D)
    (φ : Formula) : TruthAt M τ t φ.box ↔ TruthAt M τ s φ.box :=
  box_const M τ τ hτ hτ t s φ

end Truth

end FormalSystem.Semantics
