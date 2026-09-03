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

**Bimodal Logic Semantics (`app:TaskSemantics`, `def:BL-semantics`)**:
The JPL paper defines truth evaluation for TM formulas, and this module transcribes it. The
temporal clauses are **strict** on both sides: the pinned anchor `def:BL-semantics` quantifies H
over `y < x` and G over `x < y` on the nose, so this tree matches the paper exactly rather than
refining it. (Earlier revisions of this docstring described the paper's convention as reflexive
and this tree's reading as a refinement of it; both descriptions were stale and have been
corrected against the anchor of record.)
- `M,τ,x ⊨ p` iff `τ(x) ∈ |p|` (atom satisfaction — at a possible world `τ ∈ H_F`, which is the
  only place the paper evaluates truth; there is no domain conjunct in the paper's clause)
- `M,τ,x ⊨ ⊥` is false (bottom)
- `M,τ,x ⊨ φ → ψ` iff `M,τ,x ⊨ φ` implies `M,τ,x ⊨ ψ` (implication)
- `M,τ,x ⊨ □φ` iff `M,σ,x ⊨ φ` for all σ ∈ H_F, the total histories (box: necessity)
- `M,τ,x ⊨ Past φ` iff `M,τ,y ⊨ φ` for all y ∈ D where y < x (past, strict)
- `M,τ,x ⊨ Future φ` iff `M,τ,y ⊨ φ` for all y ∈ D where x < y (future, strict)

**Critical Semantic Design (this tree's encoding; Decision A of
`specs/decisions/total-history-validity-decisions.md`)**:
`def:BL-semantics` defines truth only at possible worlds `τ ∈ H_F`, whose domain is all of `D`,
and quantifies the temporal clauses over all `y ∈ D`. This tree evaluates `TruthAt` on
**arbitrary** `WorldHistory`s and reads the paper's clauses unchanged on them; the one place that
forces a choice is the atom clause, and the choice is:
- Atoms at times outside the domain are FALSE (not undefined). The domain conjunct is this
  tree's generalisation, not a paper clause; at a possible world it is trivially satisfied.
- Temporal operators still quantify over all of `D`, "beyond" the history's domain
- Validity (`Validity.lean`) quantifies only over total histories, so the paper's statements are
  unaffected; the generalisation matters only for finite histories used as intermediate objects
  (e.g., a chess game ending at move 31)

**ProofChecker Implementation Alignment**:
✓ Atom: `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`
  is the paper's `τ(x) ∈ |p|` plus the domain conjunct described above (atoms false outside
  the domain; trivially satisfied at a possible world)
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
* JPL Paper `app:TaskSemantics`, `def:BL-semantics` — formal truth definition, cited by
  `\label` (pinned verbatim in `specs/paper-definitions-of-record.md`)
* `specs/decisions/total-history-validity-decisions.md` — Decision A, the arbitrary-history
  encoding of the atom clause
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

/-! ## Truth correspondences — the generic relational transport

`TruthCorr` is the data of a truth-preserving correspondence between two task models, and
`Truth.truthAt_of_truthCorr` is the one `induction φ` that discharges it. This is the paper's own
proof shape. `lem:history-time-shift-preservation` — its `□` case in particular — never uses a
bijection between histories: it uses a *relation* between them (`def:time-shift-histories`),
atomic agreement on related pairs, and the existence of a related possible world in each
direction (`app:auto_existence`). `TruthCorr` asks for exactly those three things and nothing
more.

### Why a relation and not an `Equiv`

The paper's proof consumes existence in both directions and never injectivity or round-trip
cancellation, so an equivalence would be strictly more data than the induction spends. More
importantly, an `Equiv` on `WorldHistory` itself is a trap: `states` is indexed by a proof of
`domain`, so round-tripping two history transports forces a dependent structure equality and
degenerates into `HEq` — the failure `IntTransfer.lean`'s "Design decision: `Aligned`, not
`Equiv`" section records. A `Prop`-valued `Rel` on arbitrary histories has no round trip to
cancel. Every instance in the tree (`TruthIso.toCorr`, `TimeShift.shiftCorr`,
`IntTransfer`'s `alignedCorr`) states its relation on arbitrary `WorldHistory`s, which is what
lets `TimeShift.timeShift_preserves_truth` and `IntTransfer.truthAt_map` keep their
arbitrary-history statements while being derived from a single induction.

`TruthIso` (below, after the time-shift section) is the total-only, bijective special case:
`TruthIso.toCorr` reads an equivalence `F.HF ≃ F'.HF` as the relation "`hist` sends the one to
the other", and `truthAt_of_truthIso` is `truthAt_of_truthCorr` at that instance.
-/

/--
**A truth correspondence between two task models.**

Field by field against the paper:
- `dur`: times reindex by an order isomorphism — order preservation is what `untl`/`snce` need.
- `Rel`: the correspondence relation on **arbitrary** histories — the relation of
  `def:time-shift-histories`, read on histories rather than only on possible worlds.
- `atom`: atomic truth agrees at every related pair — the base case of
  `lem:history-time-shift-preservation`. Because `TruthAt`'s atom clause carries the domain
  conjunct, this field absorbs the domain transport as well. It is quantified over every related
  pair, not one distinguished history, because the `□` case applies the induction hypothesis at a
  pair the caller did not choose.
- `total_fwd` / `total_bwd`: every possible world on either side is related to some possible
  world on the other — `app:auto_existence` in the two directions the `□` case of
  `lem:history-time-shift-preservation` uses.
-/
structure TruthCorr {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  /-- Times reindex by an order isomorphism. -/
  dur : F.Duration ≃o F'.Duration
  /-- The correspondence relation, on arbitrary histories. -/
  Rel : WorldHistory F → WorldHistory F' → Prop
  /-- Atomic truth, domain conjunct included, agrees at every related pair. -/
  atom : ∀ σ σ', Rel σ σ' → ∀ (t : F.Duration) (p : Atom),
    TruthAt M σ t (Formula.atom p) ↔ TruthAt M' σ' (dur t) (Formula.atom p)
  /-- Every total history of `F` is related to some total history of `F'`. -/
  total_fwd : ∀ σ : WorldHistory F, σ.IsTotal → ∃ σ', σ'.IsTotal ∧ Rel σ σ'
  /-- Every total history of `F'` is related to some total history of `F`. -/
  total_bwd : ∀ σ' : WorldHistory F', σ'.IsTotal → ∃ σ, σ.IsTotal ∧ Rel σ σ'

namespace Truth

/--
**The generic truth transport, relational form.**

One `induction φ` over `Formula`'s six constructors, discharging every transport a `TruthCorr`
can express. Every order-preserving truth transport in `Semantics/` is an instance of it
(`truthAt_of_truthIso`, `TimeShift.timeShift_preserves_truth`, `IntTransfer.truthAt_map`); the
only other generic induction is the time-reversal twin `truthAt_of_truthAntiIso`.

The body is the former `truthAt_of_truthIso` induction with `I.hist.surjective` in the `□` case
replaced by `I.total_bwd` (forward direction) and `I.total_fwd` (backward direction) — the two
halves of `app:auto_existence`. The `untl` and `snce` cases spend `dur`'s surjectivity on the
guard's bounded quantifier and `OrderIso.lt_iff_lt` in both directions on the bounds. Written
against the `truth_norm` characterisation lemmas (`imp_iff`, `box_iff`, `untl_iff`, `snce_iff`)
rather than `simp only [TruthAt]`, which is what keeps it short.
-/
theorem truthAt_of_truthCorr {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthCorr M M') (φ : Formula) :
    ∀ (σ : WorldHistory F) (σ' : WorldHistory F'), I.Rel σ σ' →
      ∀ t : F.Duration, TruthAt M σ t φ ↔ TruthAt M' σ' (I.dur t) φ := by
  induction φ with
  | atom p => intro σ σ' h t; exact I.atom σ σ' h t p
  | bot => intro σ σ' _ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
      intro σ σ' h t
      simp only [imp_iff]
      rw [ihφ σ σ' h t, ihψ σ σ' h t]
  | box φ ih =>
      intro σ σ' _ t
      simp only [box_iff]
      constructor
      · intro h ρ' hρ'
        obtain ⟨ρ, hρ, hR⟩ := I.total_bwd ρ' hρ'
        exact (ih ρ ρ' hR t).mp (h ρ hρ)
      · intro h ρ hρ
        obtain ⟨ρ', hρ', hR⟩ := I.total_fwd ρ hρ
        exact (ih ρ ρ' hR t).mpr (h ρ' hρ')
  | untl ψ φ ihψ ihφ =>
      intro σ σ' h t
      simp only [untl_iff]
      constructor
      · rintro ⟨s, hts, hs, hmin⟩
        refine ⟨I.dur s, I.dur.lt_iff_lt.mpr hts, (ihφ σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ σ σ' h r).mp (hmin r (I.dur.lt_iff_lt.mp h1) (I.dur.lt_iff_lt.mp h2))
      · rintro ⟨s', hts', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, I.dur.lt_iff_lt.mp hts', (ihφ σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ σ σ' h r).mpr (hmin' (I.dur r) (I.dur.lt_iff_lt.mpr h1) (I.dur.lt_iff_lt.mpr h2))
  | snce ψ φ ihψ ihφ =>
      intro σ σ' h t
      simp only [snce_iff]
      constructor
      · rintro ⟨s, hst, hs, hmin⟩
        refine ⟨I.dur s, I.dur.lt_iff_lt.mpr hst, (ihφ σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ σ σ' h r).mp (hmin r (I.dur.lt_iff_lt.mp h1) (I.dur.lt_iff_lt.mp h2))
      · rintro ⟨s', hst', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, I.dur.lt_iff_lt.mp hst', (ihφ σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ σ σ' h r).mpr (hmin' (I.dur r) (I.dur.lt_iff_lt.mpr h1) (I.dur.lt_iff_lt.mpr h2))

end Truth

/-! ## Time-Shift Preservation

Truth is preserved under time shift: for a formula `φ`,
`TruthAt M σ y φ ↔ TruthAt M (timeShift σ (y - x)) x φ`. This is the semantic engine behind the
MF and TF axioms' validity.

The theorem is `Truth.truthAt_of_truthCorr` at the instance `shiftCorr`: `ShiftRel Δ` is the
relation of `def:time-shift-histories` read on arbitrary histories, and `shiftCorr`'s
`total_fwd`/`total_bwd` are `app:auto_existence` ("total since 𝔇 is a group", i.e.
`WorldHistory.isTotal_timeShift`). No six-case induction lives in this section; the one that
used to is the relational transport's, run once.
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
`ρ` is the `Δ`-shift of `ρ'`, pointwise: domains agree at `z` versus `z + Δ`, and so do the
states. This is the relation of `def:time-shift-histories` (`τ ≈ σ` with `τ(z) = σ(z + Δ)`), read
on **arbitrary** histories rather than only on possible worlds — which is what lets
`timeShift_preserves_truth` keep its arbitrary-`σ` statement.
-/
def ShiftRel (Δ : F.Duration) (ρ ρ' : WorldHistory F) : Prop :=
  (∀ z, ρ.domain z ↔ ρ'.domain (z + Δ)) ∧
  ∀ z (h : ρ.domain z) (h' : ρ'.domain (z + Δ)), ρ.states z h = ρ'.states (z + Δ) h'

/-- `σ.timeShift Δ` is the `Δ`-shift of `σ`, definitionally. -/
theorem shiftRel_timeShift (Δ : F.Duration) (σ : WorldHistory F) :
    ShiftRel Δ (σ.timeShift Δ) σ :=
  ⟨fun _ => Iff.rfl, fun _ _ _ => rfl⟩

/--
`ρ` is the `Δ`-shift of `ρ.timeShift (-Δ)`. Not definitional: the right-hand side sits at
`z + Δ + -Δ`, so the domain half is a rewrite and the state half is the tree's existing
`WorldHistory.states_eq_of_time_eq` — no `HEq`, no structure equality.
-/
theorem shiftRel_timeShift_neg (Δ : F.Duration) (ρ : WorldHistory F) :
    ShiftRel Δ ρ (ρ.timeShift (-Δ)) := by
  refine ⟨fun z => ?_, fun z h h' => ?_⟩
  · show ρ.domain z ↔ ρ.domain (z + Δ + -Δ)
    rw [add_neg_cancel_right]
  · exact WorldHistory.states_eq_of_time_eq ρ z (z + Δ + -Δ) (add_neg_cancel_right z Δ).symm h h'

/--
**Time shift is a truth correspondence** of `M` with itself: times reindex by `· + Δ`, histories
by `ShiftRel Δ`. `total_fwd` and `total_bwd` are `app:auto_existence` — every possible world has
a shifted possible world in each direction, `WorldHistory.isTotal_timeShift` supplying totality
— and `atom` is the pointwise domain/state agreement unfolded at one time.

`dur` must be `OrderIso.addRight Δ` itself. A hand-built `{ toEquiv := Equiv.addRight Δ, … }`
elaborates, but leaves an unreduced `let` in `dur t` that blocks `rw` on `states` at every use
site of the transport.
-/
def shiftCorr (M : TaskModel F) (Δ : F.Duration) : TruthCorr M M where
  dur := OrderIso.addRight Δ
  Rel := ShiftRel Δ
  atom := by
    rintro ρ ρ' ⟨hd, hs⟩ t p
    show (∃ h : ρ.domain t, M.valuation (ρ.states t h) p) ↔
      ∃ h' : ρ'.domain (t + Δ), M.valuation (ρ'.states (t + Δ) h') p
    constructor
    · rintro ⟨h, hv⟩
      exact ⟨(hd t).mp h, by rw [← hs t h ((hd t).mp h)]; exact hv⟩
    · rintro ⟨h', hv⟩
      exact ⟨(hd t).mpr h', by rw [hs t ((hd t).mpr h') h']; exact hv⟩
  total_fwd := fun ρ hρ =>
    ⟨ρ.timeShift (-Δ), WorldHistory.isTotal_timeShift hρ (-Δ), shiftRel_timeShift_neg Δ ρ⟩
  total_bwd := fun ρ' hρ' =>
    ⟨ρ'.timeShift Δ, WorldHistory.isTotal_timeShift hρ' Δ, shiftRel_timeShift Δ ρ'⟩

/--
Time-shift preserves truth of formulas.

If σ is a history and Δ = y - x, then truth at (σ, y) equals truth at (timeShift σ Δ, x).

**Paper Reference**: `lem:history-time-shift-preservation`. The paper states the lemma for
possible worlds `τ, σ ∈ H_F`; this theorem is Lean-stronger, holding for an arbitrary `σ`, and
the extra generality is free because `ShiftRel` is pointwise and never needs totality of the
history being shifted. Every live consumer passes a total history; the `H_F` form is
`timeShift_preserves_truth_total` below.

**Proof**: `Truth.truthAt_of_truthCorr` at `shiftCorr M (y - x)` on the related pair
`(σ.timeShift (y - x), σ)`, then `x + (y - x) = y`. The final step is a `change` followed by
`rw [add_sub_cancel]`: `simpa` does not normalise `(OrderIso.addRight Δ) x` to `x + Δ`.

**Key Insight**: **no shift-closure hypothesis is required.** Under the totality box clause the
shifted history's membership in the quantifier's range is `WorldHistory.isTotal_timeShift`,
definitionally `fun t => hρ (t + Δ)` — there is no closure condition left to assume, so this
statement is strictly stronger than the shift-closure-hypothesised version it replaces.
-/
theorem timeShift_preserves_truth (M : TaskModel F)
    (σ : WorldHistory F) (x y : F.Duration)
    (φ : Formula) :
    TruthAt M (WorldHistory.timeShift σ (y - x)) x φ ↔ TruthAt M σ y φ := by
  have h := Truth.truthAt_of_truthCorr (shiftCorr M (y - x)) φ (σ.timeShift (y - x)) σ
    (shiftRel_timeShift (y - x) σ) x
  change TruthAt M (σ.timeShift (y - x)) x φ ↔ TruthAt M σ (x + (y - x)) φ at h
  rw [add_sub_cancel] at h
  exact h

/--
The paper-faithful form of `timeShift_preserves_truth`: `lem:history-time-shift-preservation`
as stated, for a possible world `τ : F.HF`. Documentation alignment only — it is the general
theorem specialised, and no consumer needs it.
-/
theorem timeShift_preserves_truth_total (M : TaskModel F) (τ : F.HF) (x y : F.Duration)
    (φ : Formula) :
    TruthAt M (WorldHistory.timeShift τ.val (y - x)) x φ ↔ TruthAt M τ.val y φ :=
  timeShift_preserves_truth M τ.val x y φ

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
  exact (timeShift_preserves_truth M σ x y φ).symm

end TimeShift

namespace Truth

/-!
## `□` is a model constant

The box clause quantifies over *all* total histories at a time. Under time-homogeneity of the task
relation that makes its truth value depend on neither the history nor the time — a boxed formula is
a fact about the model alone.

This block is placed after `TimeShift` rather than beside the other `Truth` clause lemmas because
its proof consumes `TimeShift.timeShift_preserves_truth`, which is declared there.
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
  `TimeShift.timeShift_preserves_truth` transports the result back.

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
    exact (TimeShift.timeShift_preserves_truth M ρ t s φ).mp
      (h (WorldHistory.timeShift ρ (s - t)) (WorldHistory.isTotal_timeShift hρ (s - t)))
  · intro h ρ hρ
    exact (TimeShift.timeShift_preserves_truth M ρ s t φ).mp
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

/-! ## Truth isomorphisms — the bijective special case

`TruthIso` is the total-only, bijective special case of `TruthCorr`: times reindex by an order
isomorphism and **total** histories reindex by an equivalence `F.HF ≃ F'.HF`. It is the packaging
`Independence/LoopingDuration.lean`'s duration reindexings naturally come in, and it is kept as a
structure in its own right for them. It is not a second induction: `TruthIso.toCorr` reads
`hist` as the relation "`hist` sends the one to the other", and `truthAt_of_truthIso` is
`truthAt_of_truthCorr` at that instance.

### Why `hist` is an equivalence

The paper needs existence in both directions (`app:auto_existence`): the `□` case of the
transport must produce, for an arbitrary possible world of `F'`, a possible world of `F` to feed
the hypothesis, and conversely. `TruthCorr.total_fwd`/`total_bwd` ask for exactly that, and an
`Equiv` supplies it — the map itself in one direction, `Equiv.surjective` in the other. Nothing
finer than the two existence facts is spent, which is why the relational `TruthCorr` is the
primitive and this structure the special case.

### Why `atom` is quantified over all histories

The `atom` field has to hold at every `τ : F.HF`, not at one distinguished history, because the
`box` case applies the induction hypothesis at a history the caller did not choose. A per-history
atom hypothesis would not survive the box case — which is precisely why
`Correspondence/FwdRecPeriodicity.truthAt_add_hist_period` is **not** an instance of this
structure, nor of `TruthCorr`, and keeps its own induction; see its docstring.
-/

/--
**A truth isomorphism between two task models.**

`dur` reindexes times by an order isomorphism, `hist` reindexes total histories by an
equivalence, and `atom` says the two models agree on atomic truth under that reindexing. The
three together are exactly what `TruthIso.toCorr` needs to build a `TruthCorr`: `dur` is
passed through, `hist` and its surjectivity supply `total_fwd`/`total_bwd`, and `atom` supplies
`atom` (with `atom_iff_of_domain` discharging the domain conjunct on both sides).
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

/--
**A `TruthIso` is a `TruthCorr`.** The relation is "`hist` sends the one total history to the
other": `Rel σ σ'` holds when both are total and `hist ⟨σ, _⟩ = ⟨σ', _⟩`. `total_fwd` is `hist`
itself, `total_bwd` is `hist.surjective`, and `atom` is the structure's `atom` field with the
domain conjunct on each side discharged by `atom_iff_of_domain` from totality.
-/
def TruthIso.toCorr {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthIso M M') : TruthCorr M M' where
  dur := I.dur
  Rel := fun σ σ' => ∃ (hσ : σ.IsTotal) (hσ' : σ'.IsTotal), I.hist ⟨σ, hσ⟩ = ⟨σ', hσ'⟩
  atom := by
    rintro σ σ' ⟨hσ, hσ', heq⟩ t p
    rw [Truth.atom_iff_of_domain (hσ t) p, Truth.atom_iff_of_domain (hσ' (I.dur t)) p]
    have := I.atom ⟨σ, hσ⟩ t p
    rw [heq] at this
    exact this
  total_fwd := fun σ hσ => ⟨(I.hist ⟨σ, hσ⟩).val, (I.hist ⟨σ, hσ⟩).property, hσ, _, rfl⟩
  total_bwd := by
    intro σ' hσ'
    obtain ⟨⟨τ, hτ⟩, h⟩ := I.hist.surjective ⟨σ', hσ'⟩
    exact ⟨τ, hτ, hτ, hσ', h⟩

namespace Truth

/--
**Truth transport along a `TruthIso`.**

`truthAt_of_truthCorr` at the instance `TruthIso.toCorr`: the related pair is
`(τ.val, (I.hist τ).val)`, witnessed by `rfl`. The six-case induction lives in
`truthAt_of_truthCorr`; nothing is re-run here. Statement unchanged from the days it carried its
own induction, so every consumer (`Independence/LoopingDuration.lean`) is untouched.
-/
theorem truthAt_of_truthIso {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthIso M M') (φ : Formula) (τ : F.HF) (t : F.Duration) :
    TruthAt M τ.val t φ ↔ TruthAt M' (I.hist τ).val (I.dur t) φ :=
  truthAt_of_truthCorr (TruthIso.toCorr I) φ τ.val (I.hist τ).val
    ⟨τ.property, (I.hist τ).property, rfl⟩ t

end Truth

/-! ## The anti-isomorphism twin

`TruthIso` transports truth along an *order-preserving* reindexing of time. A time **reversal**
is order-reversing, so it cannot be one — and the formula it transports to is not `φ` but
`φ.swapTemporal`, since reversing time exchanges `untl` with `snce`. `TruthAntiIso` is that
twin, and `truthAt_of_truthAntiIso` its generic lemma.

`Formula.swapTemporal` (`Syntax/Formula.lean`) fixes `atom` and `bot`, distributes through `imp`
and `box`, and exchanges `untl` with `snce` — exactly the six-case shape the twin's induction
needs, one clause per constructor with no residue.
-/

/--
**An anti-isomorphism between two task models**: `TruthIso` with time reversed.

`dur` is a bare `Equiv` plus an explicit reversal condition rather than an
`F.Duration ≃o (F'.Duration)ᵒᵈ`. The two carry the same content, and the `≃o`-into-the-dual
spelling would force every use site to insert `OrderDual.toDual`/`ofDual` round trips into
statements that are otherwise about the carrier itself.

`hist` and `atom` are unchanged from `TruthIso`, and for the same reasons: the `box` clause of
`TruthAt` is time-symmetric, so reversal does not touch it, and it still ranges over all total
histories — which is what forces `hist` to be an equivalence and `atom` to be quantified over
every history.
-/
structure TruthAntiIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  /-- Times reindex by an equivalence... -/
  dur : F.Duration ≃ F'.Duration
  /-- ...which **reverses** the order. This is the whole difference from `TruthIso`. -/
  dur_rev : ∀ s t : F.Duration, dur s < dur t ↔ t < s
  /-- Total histories reindex by an equivalence, exactly as in `TruthIso`. -/
  hist : F.HF ≃ F'.HF
  /-- Atomic truth agrees under the reindexing, at every total history. -/
  atom : ∀ (τ : F.HF) (t : F.Duration) (p : Atom),
    M.valuation (τ.val.states t (τ.property t)) p ↔
      M'.valuation ((hist τ).val.states (dur t) ((hist τ).property (dur t))) p

namespace Truth

/--
**The generic truth transport across an anti-isomorphism.**

The order-reversing twin of `truthAt_of_truthCorr` (at the `TruthIso` instance), concluding at
`φ.swapTemporal`. Its `atom`,
`bot`, `imp` and `box` cases are the same arguments, since `swapTemporal` is the identity on the
first two and structural on the second two; only `untl` and `snce` differ, and they differ by
exchanging places and reading every bound through `dur_rev` instead of `OrderIso.lt_iff_lt`.

Note on `swap_norm`: the plan for this work specified writing the body against that simp set.
`swap_norm` collects the eleven `Formula.swap_temporal_*` lemmas, which push `swapTemporal`
through the **derived** operators (`neg`, `diamond`, `someFuture`, `next`, …). A six-constructor
induction needs the *base* equations of `Formula.swapTemporal` instead, and those are not in the
set — nor should they be, since adding them would make `swap_norm` unfold the definition at every
call site. `simp only [Formula.swapTemporal, …]` is therefore what the base cases use; `swap_norm`
remains the right tool for a caller reasoning about a derived operator.
-/
theorem truthAt_of_truthAntiIso {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthAntiIso M M') (φ : Formula) (τ : F.HF) (t : F.Duration) :
    TruthAt M τ.val t φ ↔ TruthAt M' (I.hist τ).val (I.dur t) φ.swapTemporal := by
  induction φ generalizing τ t with
  | atom p =>
      rw [Formula.swapTemporal, atom_iff_of_domain (τ.property t) p,
        atom_iff_of_domain ((I.hist τ).property (I.dur t)) p]
      exact I.atom τ t p
  | bot => simp [Formula.swapTemporal]
  | imp φ ψ ihφ ihψ =>
      simp only [Formula.swapTemporal, imp_iff]
      rw [ihφ τ t, ihψ τ t]
  | box φ ih =>
      simp only [Formula.swapTemporal, box_iff]
      constructor
      · intro h σ' hσ'
        obtain ⟨τ', hτ'⟩ := I.hist.surjective ⟨σ', hσ'⟩
        have key := (ih τ' t).mp (h _ τ'.property)
        rw [hτ'] at key
        exact key
      · intro h σ hσ
        exact (ih ⟨σ, hσ⟩ t).mpr (h _ (I.hist ⟨σ, hσ⟩).property)
  | untl ψ φ ihψ ihφ =>
      simp only [Formula.swapTemporal, untl_iff, snce_iff]
      constructor
      · rintro ⟨s, hts, hs, hg⟩
        refine ⟨I.dur s, (I.dur_rev s t).mpr hts, (ihφ τ s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ τ r).mp (hg r ((I.dur_rev r t).mp h2) ((I.dur_rev s r).mp h1))
      · rintro ⟨s', hs't, hs', hg'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, (I.dur_rev s t).mp hs't, (ihφ τ s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ τ r).mpr (hg' (I.dur r) ((I.dur_rev s r).mpr h2) ((I.dur_rev r t).mpr h1))
  | snce ψ φ ihψ ihφ =>
      simp only [Formula.swapTemporal, snce_iff, untl_iff]
      constructor
      · rintro ⟨s, hst, hs, hg⟩
        refine ⟨I.dur s, (I.dur_rev t s).mpr hst, (ihφ τ s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ τ r).mp (hg r ((I.dur_rev r s).mp h2) ((I.dur_rev t r).mp h1))
      · rintro ⟨s', hts', hs', hg'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, (I.dur_rev t s).mp hts', (ihφ τ s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ τ r).mpr (hg' (I.dur r) ((I.dur_rev t r).mpr h2) ((I.dur_rev r s).mpr h1))

end Truth

end FormalSystem.Semantics
