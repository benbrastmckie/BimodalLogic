/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.WorldHistory
import FormalSystem.Syntax.Formula
import FormalSystem.Automation.TruthNormAttr

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
The JPL paper defines truth evaluation for TM formulas, and this module transcribes it. The
temporal clauses are **strict** on both sides: the pinned anchor `def:BL-semantics` quantifies H
over `y < x` and G over `x < y` on the nose, so this tree matches the paper exactly rather than
refining it. (Earlier revisions of this docstring described the paper's convention as reflexive
and this tree's reading as a refinement of it; both descriptions were stale and have been
corrected against the anchor of record.)
- `M,τ,x ⊨ p` iff `x ∈ dom(τ)` AND `τ(x) ∈ V(p)` (atom satisfaction, line 892)
- `M,τ,x ⊨ ⊥` is false (bottom)
- `M,τ,x ⊨ φ → ψ` iff `M,τ,x ⊨ φ` implies `M,τ,x ⊨ ψ` (implication)
- `M,τ,x ⊨ □φ` iff `M,σ,x ⊨ φ` for all σ ∈ H_F, the total histories (box: necessity)
- `M,τ,x ⊨ Past φ` iff `M,τ,y ⊨ φ` for all y ∈ D where y < x (past, strict)
- `M,τ,x ⊨ Future φ` iff `M,τ,y ⊨ φ` for all y ∈ D where x < y (future, strict)

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

## Simp-normal form

The `Truth.*` characterization lemmas below are the truth layer's **simp normal form**: each
rewrites a `TruthAt`-headed goal about a compound formula into the corresponding meta-level
connective, so a proof never has to unfold the `Formula.and` / `Formula.or` / `Formula.neg`
definition chain by hand. The family is confluent and terminating; twelve alternative spellings
of the same formula were each checked to converge on the normal form under bare `simp`.

| Formula | Lemma | Normal form (RHS) |
|---|---|---|
| `¬φ` | `neg_iff` | `¬ TruthAt M τ t φ` |
| `⊤` | `top_true` | `True` (the lemma is the proof, not an `Iff`) |
| `⊥` | `bot_false` | `False` |
| `φ → ψ` | `imp_iff` | `TruthAt … φ → TruthAt … ψ` |
| `φ ∧ ψ` | `and_iff` | `TruthAt … φ ∧ TruthAt … ψ` |
| `φ ∨ ψ` | `or_iff` | `TruthAt … φ ∨ TruthAt … ψ` |
| `□φ` | `box_iff` | `∀ σ, σ.IsTotal → TruthAt M σ t φ` |
| `◇φ` | `diamond_iff` | `∃ σ, σ.IsTotal ∧ TruthAt M σ t φ` |
| `ψ U φ` | `untl_iff` | the `untl` clause |
| `ψ S φ` | `snce_iff` | the `snce` clause |
| `Fφ` | `some_future_iff` | `∃ s, t < s ∧ TruthAt M τ s φ` |
| `Pφ` | `some_past_iff` | `∃ s, s < t ∧ TruthAt M τ s φ` |
| `Gφ` | `future_iff` | `∀ s, t < s → TruthAt M τ s φ` |
| `Hφ` | `past_iff` | `∀ s, s < t → TruthAt M τ s φ` |
| `△φ` | `always_iff` | `∀ s, TruthAt M τ s φ` |
| `K⁺φ` | `kPlus_iff` | `∀ s, t < s → ∃ r, t < r ∧ r < s ∧ TruthAt M τ r φ` |
| `K⁻φ` | `kMinus_iff` | `∀ s, s < t → ∃ r, s < r ∧ r < t ∧ TruthAt M τ r φ` |
| `M(φ,ψ)` | `strong_release_iff` | the `untl` clause with a nested `and` |
| `ST(φ,ψ)` | `strong_trigger_iff` | the `snce` clause with a nested `and` |

All of the above are tagged into the `truth_norm` simp set declared in
`FormalSystem/Automation/TruthNormAttr.lean`, alongside `TruthAt`'s own defining equations, so
`simp only [truth_norm]` — or equivalently the `truth_simp` macro — opens the whole family at
once.

**`always` has two forms, and only one may carry the attribute.** `always_iff` (the collected
`∀ s` form) is the normal form and is the tagged one. `always_iff_tri` (the three-conjunct
past/present/future form, mirroring `BLTruth.always_iff`) is the **introduction** form and is
deliberately left plain. The two are logically equivalent but syntactically distinct, so tagging
both makes `simp` apply whichever was declared first and silently strand every proof written
against the other; that failure was reproduced rather than merely anticipated. Build an `always`
with `always_iff_tri`, eliminate one with `always_iff`.

**A caveat when rewriting an existing `simp only` list.** Adding these names to a list that still
mentions `Formula.and` / `Formula.or` / `Formula.neg` is a no-op: simp rewrites bottom-up, so the
syntax-unfolding lemmas fire on the argument before the `TruthAt`-headed characterization lemma
can match. The syntax lemmas have to come **out** of the list as the characterization lemmas go
in.

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

variable {F : TaskFrame}

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

**Until / Since argument order**: `untl`/`snce` are **guard-first / event-second** — `untl ψ φ`
reads "ψ is the guard, φ is the event". The two clauses below transcribe
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
    (τ : WorldHistory F) (t : F.Duration) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ
  | Formula.untl ψ φ => ∃ s : F.Duration, t < s ∧ TruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce ψ φ => ∃ s : F.Duration, s < t ∧ TruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ

-- Note: We avoid defining a notation for TruthAt as it causes parsing conflicts
-- with the validity notation in Validity.lean. Use TruthAt directly.

namespace Truth

/--
Bot (⊥) is false everywhere.
-/
@[simp] theorem bot_false
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration} :
    ¬(TruthAt M τ t Formula.bot) := by
  intro h
  exact h

/--
Truth of implication is material conditional.
-/
@[simp] theorem imp_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
    (φ ψ : Formula) :
    (TruthAt M τ t (φ.imp ψ)) ↔
      ((TruthAt M τ t φ) → (TruthAt M τ t ψ)) := by
  rfl

/--
Truth of atom at a time in the domain: true iff valuation says so at current state.
For times outside domain, atoms are always false.
-/
theorem atom_iff_of_domain
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration} (ht : τ.domain t)
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
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration} (ht : ¬τ.domain t)
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
@[simp] theorem box_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
    (φ : Formula) :
    (TruthAt M τ t φ.box) ↔
      ∀ (σ : WorldHistory F), σ.IsTotal → (TruthAt M σ t φ) := by
  rfl

/--
Truth of someFuture: existential future operator.
F(φ) = U(φ, ⊤) is true iff there exists a strictly future time where φ holds.
-/
@[simp] theorem some_future_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
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
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
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
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.allFuture ↔
      ∀ (s : F.Duration), t < s → TruthAt M τ s φ := by
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
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.allPast ↔
      ∀ (s : F.Duration), s < t → TruthAt M τ s φ := by
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
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (Formula.strongRelease φ ψ) ↔
      ∃ s : F.Duration, t < s ∧ TruthAt M τ s (Formula.and ψ φ) ∧
        ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ := by
  simp [Formula.strongRelease, Formula.and, TruthAt]

/--
Truth of strongTrigger: ST(φ, ψ) = ψ S (ψ ∧ φ).
True iff there exists a strictly past time where ψ ∧ φ held,
with ψ holding at all intermediate times.
-/
@[simp] theorem strong_trigger_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (Formula.strongTrigger φ ψ) ↔
      ∃ s : F.Duration, s < t ∧ TruthAt M τ s (Formula.and ψ φ) ∧
        ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ := by
  simp [Formula.strongTrigger, Formula.and, TruthAt]


/-! ### The derived Boolean operators

`Formula.neg`, `top`, `and` and `or` are all `def` abbreviations over `imp`/`bot`, so without
these four the only way to reason about a conjunction is to unfold the definition chain by hand
with `simp only [Formula.and, Formula.neg, TruthAt]` and finish with `tauto`. That idiom is what
this family retires. -/

/-- Truth of `¬φ`. -/
@[simp, truth_norm] theorem neg_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ := Iff.rfl

/-- `⊤` is true everywhere. -/
@[simp, truth_norm] theorem top_true
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration} :
    TruthAt M τ t Formula.top := id

/-- Truth of `φ ∧ ψ`. Classical: `and` is the double-negated implication. -/
@[simp, truth_norm] theorem and_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (φ.and ψ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ) := by
  simp only [Formula.and, Formula.neg, TruthAt]
  tauto

/-- Truth of `φ ∨ ψ`. Classical: `or` is `¬φ → ψ`. -/
@[simp, truth_norm] theorem or_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ ψ : Formula) :
    TruthAt M τ t (φ.or ψ) ↔ (TruthAt M τ t φ ∨ TruthAt M τ t ψ) := by
  simp only [Formula.or, Formula.neg, TruthAt]
  tauto

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* total history at the current time. The classical
`¬∀¬ ↔ ∃` step over `box_iff`. -/
@[simp, truth_norm] theorem diamond_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.diamond ↔ ∃ σ : WorldHistory F, σ.IsTotal ∧ TruthAt M σ t φ := by
  simp only [Formula.diamond, Formula.neg, TruthAt]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun σ hσ hφ => hc σ hσ hφ)
  · rintro ⟨σ, hσ, hφ⟩ h; exact h σ hσ hφ

/-! ### The primitive temporal clauses

`untl_iff` and `snce_iff` restate `TruthAt`'s own `untl`/`snce` equations as biconditionals. They
look redundant next to `simp only [TruthAt]`, and they are not: once the characterization family
is the normal form, a proof no longer opens `TruthAt` at all, so a raw `untl`/`snce` head would
have nothing to reduce it. These two are what keep the family complete on the primitives. Both
are guard-first / event-second, matching `TruthAt`. -/

/-- Truth of `ψ U φ` (guard `ψ`, event `φ`): the `untl` clause of `TruthAt`, as a biconditional. -/
@[simp, truth_norm] theorem untl_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (ψ φ : Formula) :
    TruthAt M τ t (Formula.untl ψ φ) ↔
      ∃ s : F.Duration, t < s ∧ TruthAt M τ s φ ∧
        ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ := Iff.rfl

/-- Truth of `ψ S φ` (guard `ψ`, event `φ`): the `snce` clause of `TruthAt`, as a biconditional. -/
@[simp, truth_norm] theorem snce_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (ψ φ : Formula) :
    TruthAt M τ t (Formula.snce ψ φ) ↔
      ∃ s : F.Duration, s < t ∧ TruthAt M τ s φ ∧
        ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ := Iff.rfl

/-! ### Temporal `always`

**Only one of the two `always` characterizations may ever carry `@[simp]`.** They are logically
equivalent but syntactically distinct normal forms, so tagging both makes `simp` apply whichever
was declared first and silently strand every proof written against the other — a failure that was
reproduced, not hypothesised. The **collected `∀ s` form, `always_iff`, is the normal form** and
is the one that carries the attribute. `always_iff_tri` is the three-conjunct introduction form
that mirrors `BLTruth.always_iff` and is the proof route to the collected form; it is deliberately
plain, and must stay untagged by both `@[simp]` and `@[truth_norm]`. -/

/-- Truth of `△φ` (`Hφ ∧ (φ ∧ Gφ)`) in three-conjunct form: past, present, future.

The **introduction** form — this is the shape you build an `always` from, and the association
mirrors `Formula.always` and `BLTruth.always_iff`. It is **not** the simp normal form and must
never be tagged; see the section note above. Use `always_iff` for elimination. -/
theorem always_iff_tri
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.always ↔
      (∀ s : F.Duration, s < t → TruthAt M τ s φ) ∧ TruthAt M τ t φ ∧
        (∀ s : F.Duration, t < s → TruthAt M τ s φ) := by
  simp only [Formula.always, and_iff, past_iff, future_iff]

/-- Truth of `△φ`, collected: `φ` holds at **every** time. The simp normal form for `always`.

Collapsing the three strict cases into one unrestricted `∀ s` is what removes the hand-rolled
`lt_trichotomy` case split that every `always` elimination otherwise has to perform. -/
@[simp, truth_norm] theorem always_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.always ↔ ∀ s : F.Duration, TruthAt M τ s φ := by
  rw [always_iff_tri]
  constructor
  · rintro ⟨hp, hn, hf⟩ s
    rcases lt_trichotomy s t with h | h | h
    · exact hp s h
    · exact h ▸ hn
    · exact hf s h
  · intro h
    exact ⟨fun s _ => h s, h t, fun s _ => h s⟩

/-! ### The density operators -/

/-- Truth of `K⁺φ` (`¬(¬φ U ⊤)`): between the present and every strictly future time there is an
intermediate time at which `φ` holds. -/
@[simp, truth_norm] theorem kPlus_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.kPlus ↔
      ∀ s : F.Duration, t < s → ∃ r : F.Duration, t < r ∧ r < s ∧ TruthAt M τ r φ := by
  simp only [Formula.kPlus, Formula.neg, Formula.top, TruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-- Truth of `K⁻φ` (`¬(¬φ S ⊤)`): the past dual of `kPlus_iff`. -/
@[simp, truth_norm] theorem kMinus_iff
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.kMinus ↔
      ∀ s : F.Duration, s < t → ∃ r : F.Duration, s < r ∧ r < t ∧ TruthAt M τ r φ := by
  simp only [Formula.kMinus, Formula.neg, Formula.top, TruthAt]
  constructor
  · intro h s hs
    by_contra hc
    push Not at hc
    exact h ⟨s, hs, id, fun r h1 h2 hr => hc r h1 h2 hr⟩
  · rintro h ⟨s, hs, -, hall⟩
    obtain ⟨r, h1, h2, hr⟩ := h s hs
    exact hall r h1 h2 hr

/-! ### `truth_norm` membership for the pre-existing lemmas

`TruthAt`'s own defining equations together with the characterization lemmas declared above this
block. `always_iff_tri` is deliberately absent — see the `always` section note. -/

attribute [truth_norm] TruthAt bot_false imp_iff box_iff some_future_iff some_past_iff
  future_iff past_iff strong_release_iff strong_trigger_iff


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
    (τ₁ τ₂ : WorldHistory F) (t : F.Duration)
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
    (σ : WorldHistory F) (Δ : F.Duration) (t : F.Duration)
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
    (σ : WorldHistory F) (x y : F.Duration)
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
    -- Until (guard-first): untl(guard=ψ, event=φ)
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
    -- Since (guard-first): snce(guard=ψ, event=φ)
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
    (σ : WorldHistory F) (x y : F.Duration)
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
    (t s : F.Duration) (φ : Formula) :
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
theorem box_time_const (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : F.Duration)
    (φ : Formula) : TruthAt M τ t φ.box ↔ TruthAt M τ s φ.box :=
  box_const M τ τ hτ hτ t s φ

/-! ## A-17: history-independence and the gap formula

The four uniformity axioms and the discrete box-necessity axiom all say the same thing twice
over: the formula they quantify is *atom-free*, so its truth cannot depend on the history at all,
and the particular atom-free formula they use — `⊥ U (⊥ → ⊥)` — says only that the temporal order
has a gap immediately above the point, which is a statement about `F.Duration` and nothing else.
Both facts are proved once here, so the soundness proofs that consume them collapse to one term
each instead of re-deriving the translation argument five times over. -/

/-- **Truth of an atom-free formula does not depend on the history.**

The `box` case is where this is not merely an induction bookkeeping step: `def:BL-semantics`'s box
clause quantifies over *all* total histories and does not mention `τ`, so the two sides are
definitionally equal there and the induction hypothesis is not needed. Every other case is
congruence. The atom case is vacuous — `(Formula.atom p).atoms = {p} ≠ ∅`. -/
theorem truthAt_atomFree_history_indep (M : TaskModel F) :
    ∀ (φ : Formula), φ.atoms = ∅ →
      ∀ (τ σ : WorldHistory F) (t : F.Duration), TruthAt M τ t φ ↔ TruthAt M σ t φ := by
  intro φ
  induction φ with
  | atom p => intro h; simp only [Formula.atoms, Finset.singleton_ne_empty] at h
  | bot => intro _ _ _ _; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
      intro h τ σ t
      simp only [Formula.atoms, Finset.union_eq_empty] at h
      exact imp_congr (ihφ h.1 τ σ t) (ihψ h.2 τ σ t)
  | box φ _ => intro _ _ _ _; exact Iff.rfl
  | untl ψ φ ihψ ihφ =>
      intro h τ σ t
      simp only [Formula.atoms, Finset.union_eq_empty] at h
      exact exists_congr fun s => and_congr_right fun _ =>
        and_congr (ihφ h.1 τ σ s)
          (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ h.2 τ σ r)
  | snce ψ φ ihψ ihφ =>
      intro h τ σ t
      simp only [Formula.atoms, Finset.union_eq_empty] at h
      exact exists_congr fun s => and_congr_right fun _ =>
        and_congr (ihφ h.1 τ σ s)
          (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ h.2 τ σ r)

/-- The **gap formula** `⊥ U (⊥ → ⊥)`, characterized: there is a point strictly above `t` with
nothing strictly between. The right-hand side mentions neither `M` nor `τ` — that is the entire
content of the uniformity block, isolated. -/
theorem truthAt_gap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) ↔
      ∃ s : F.Duration, t < s ∧ ∀ r : F.Duration, t < r → r < s → False := by
  simp only [TruthAt]
  constructor
  · rintro ⟨s, hts, -, hguard⟩; exact ⟨s, hts, hguard⟩
  · rintro ⟨s, hts, hguard⟩; exact ⟨s, hts, id, hguard⟩

/-- The past dual of `truthAt_gap`: `⊥ S (⊥ → ⊥)` says there is a point strictly below `t` with
nothing strictly between. -/
theorem truthAt_cogap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) ↔
      ∃ s : F.Duration, s < t ∧ ∀ r : F.Duration, s < r → r < t → False := by
  simp only [TruthAt]
  constructor
  · rintro ⟨s, hst, -, hguard⟩; exact ⟨s, hst, hguard⟩
  · rintro ⟨s, hst, hguard⟩; exact ⟨s, hst, id, hguard⟩

/-- **Gaps translate.** A gap immediately above `t` is a gap immediately above every point: shift
the witness by `u - t` and shift any intruder back. Translation invariance of `<` on the duration
group is the whole argument, which is why the statement mentions no history and no model. -/
theorem truthAt_gap_shift (M : TaskModel F) (τ : WorldHistory F) (t u : F.Duration)
    (h : TruthAt M τ t (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) :
    TruthAt M τ u (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) := by
  rw [truthAt_gap] at h ⊢
  obtain ⟨s, hts, hguard⟩ := h
  refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun c huc hcs => ?_⟩
  have h1 : t < c - (u - t) := by
    conv_lhs => rw [(sub_sub_cancel u t).symm]
    exact sub_lt_sub_right huc _
  have h2 : c - (u - t) < s := by
    conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
    exact sub_lt_sub_right hcs _
  exact hguard (c - (u - t)) h1 h2

/-- **A gap above is a gap below.** The mirror of `truthAt_gap_shift`: reflect the witness through
`t`. Together with `truthAt_cogap_iff_gap` this is what makes the two `discrete_symm_*` axioms one
term each. -/
theorem truthAt_gap_iff_cogap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) ↔
      TruthAt M τ t (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) := by
  rw [truthAt_gap, truthAt_cogap]
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

end Truth

/-! ## Truth isomorphisms — the generic transport

Five hand-written `induction φ` transport proofs used to sit across `Semantics/` and
`Independence/`, each ~70-230 lines, each re-running the same six-constructor case analysis to
say that some particular reindexing of times and histories preserves truth. `TruthIso` is the
data such a reindexing consists of, and `truthAt_of_truthIso` is the induction, run once.

### Why `hist` is an honest equivalence and not a map

`TruthAt`'s `box` clause quantifies over **all** total histories of the frame. Transporting it
therefore needs both directions: the forward direction of `↔` must produce, for an arbitrary
total history of `F'`, a total history of `F` to feed the hypothesis. A one-way
`F.HF → F'.HF` cannot do that, and the hand-written proofs paid for the gap with bespoke
round-trip cancellation lemmas (`TimeShift.truth_double_shift_cancel` was exactly such a lemma,
existing only to serve `time_shift_preserves_truth`'s box case). With `hist : F.HF ≃ F'.HF` the
round trip is `Equiv.surjective` and the bespoke lemmas become deletable.

### Why `atom` is quantified over all histories

For the same reason: the `atom` field has to hold at every `τ : F.HF`, not at one distinguished
history, because the `box` case applies the induction hypothesis at a history the caller did not
choose. A per-history atom hypothesis would not survive the box case — which is precisely why
`Correspondence/FwdRecPeriodicity.truthAt_add_hist_period` is **not** an instance of this
structure and keeps its own induction; see its docstring.
-/

/--
**A truth isomorphism between two task models.**

`dur` reindexes times by an order isomorphism, `hist` reindexes total histories by an
equivalence, and `atom` says the two models agree on atomic truth under that reindexing. The
three together are exactly what `truthAt_of_truthIso`'s six cases consume: `dur`'s order
preservation for `untl`/`snce`, `hist`'s surjectivity for `box`, and `atom` for `atom`.
-/
structure TruthIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  /-- Times reindex by an order isomorphism — order preservation is what `untl`/`snce` need. -/
  dur : F.Duration ≃o F'.Duration
  /-- Total histories reindex by an **equivalence**; see the section note on why not a map. -/
  hist : F.HF ≃ F'.HF
  /-- Atomic truth agrees under the reindexing, at **every** total history. -/
  atom : ∀ (τ : F.HF) (t : F.Duration) (p : Atom),
    M.valuation (τ.val.states t (τ.property t)) p ↔
      M'.valuation ((hist τ).val.states (dur t) ((hist τ).property (dur t))) p

namespace Truth

/--
**The generic truth transport.**

One `induction φ` over `Formula`'s six constructors, discharging every transport a `TruthIso`
can express. The body is written against the `truth_norm` characterisation lemmas
(`Automation/TruthNormAttr.lean`) — `imp_iff`, `box_iff`, `untl_iff`, `snce_iff` — rather than
`simp only [TruthAt]`, which is what keeps it short.

The `box` case is where `hist` being an equivalence is spent: `I.hist.surjective` produces the
`F`-side history the hypothesis needs from an arbitrary `F'`-side one, with no round-trip
cancellation lemma. The `untl` and `snce` cases spend `dur`'s surjectivity the same way on the
guard's bounded quantifier, and `OrderIso.lt_iff_lt` in both directions on the bounds.
-/
theorem truthAt_of_truthIso {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthIso M M') (φ : Formula) (τ : F.HF) (t : F.Duration) :
    TruthAt M τ.val t φ ↔ TruthAt M' (I.hist τ).val (I.dur t) φ := by
  induction φ generalizing τ t with
  | atom p =>
      rw [atom_iff_of_domain (τ.property t) p,
        atom_iff_of_domain ((I.hist τ).property (I.dur t)) p]
      exact I.atom τ t p
  | bot => simp
  | imp φ ψ ihφ ihψ =>
      simp only [imp_iff]
      rw [ihφ τ t, ihψ τ t]
  | box φ ih =>
      simp only [box_iff]
      constructor
      · intro h σ' hσ'
        obtain ⟨τ', hτ'⟩ := I.hist.surjective ⟨σ', hσ'⟩
        have key := (ih τ' t).mp (h _ τ'.property)
        rw [hτ'] at key
        exact key
      · intro h σ hσ
        exact (ih ⟨σ, hσ⟩ t).mpr (h _ (I.hist ⟨σ, hσ⟩).property)
  | untl ψ φ ihψ ihφ =>
      simp only [untl_iff]
      constructor
      · rintro ⟨s, hts, hs, hmin⟩
        refine ⟨I.dur s, I.dur.lt_iff_lt.mpr hts, (ihφ τ s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ τ r).mp (hmin r (I.dur.lt_iff_lt.mp h1) (I.dur.lt_iff_lt.mp h2))
      · rintro ⟨s', hts', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, I.dur.lt_iff_lt.mp hts', (ihφ τ s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ τ r).mpr (hmin' (I.dur r) (I.dur.lt_iff_lt.mpr h1) (I.dur.lt_iff_lt.mpr h2))
  | snce ψ φ ihψ ihφ =>
      simp only [snce_iff]
      constructor
      · rintro ⟨s, hst, hs, hmin⟩
        refine ⟨I.dur s, I.dur.lt_iff_lt.mpr hst, (ihφ τ s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ τ r).mp (hmin r (I.dur.lt_iff_lt.mp h1) (I.dur.lt_iff_lt.mp h2))
      · rintro ⟨s', hst', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, I.dur.lt_iff_lt.mp hst', (ihφ τ s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ τ r).mpr (hmin' (I.dur r) (I.dur.lt_iff_lt.mpr h1) (I.dur.lt_iff_lt.mpr h2))

end Truth

end FormalSystem.Semantics
