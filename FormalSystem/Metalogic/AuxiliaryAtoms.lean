/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.NamingRules
import FormalSystem.Semantics.ConeUnravelling
import FormalSystem.PlusLanguage.PlusStateLocal
import FormalSystem.PlusLanguage.PlusIntTransfer
import FormalSystem.PlusLanguage.PlusLCSchema

/-!
# The Auxiliary-Atoms rule for L⁺ at `FrameClass.ZTime`

Reynolds' *Auxiliary Atoms* rule licenses inferring `φ` from `A(Q) → φ`, where `Q` is a finite
set of fresh sentence letters and `A(Q)` says that the letters of `Q` label the states of a
run of a finite-state machine: one letter holds initially, at most one holds at any point, and
whenever the letter `q_j` holds and the input condition `aᵢ` holds, the letter `q_{p j i}` holds
at the next instant on every history through the present state. The letters are auxiliary — they
are discharged by the rule and never appear in the conclusion — which is what makes the rule
sound without `A(Q)` being valid.

The device is the one `Metalogic/NamingRules.lean` records for the irreflexivity and clock rules,
run on a different frame construction. There the auxiliary letter is named by the clock of the
translation product; here the auxiliary letters are named by the state of a machine run along the
*recorded path* of the forward-cone unravelling (`Semantics/ConeUnravelling.lean`). Concretely:
given a regular frame over `intOrder` and a model on it, pass to `coneFrame F`, define a
valuation on the cone carrier that reads each `q_j` off the machine state recorded at a node and
every other atom off the base model through the projection `coneF`, check the antecedent there,
instantiate the premise, forget `Q` by the family freshness congruence, and project back along
`TwoWayBounded.plus_invariance_of_isZTime`.

## Why the recorded path is what makes this work

The machine's input at a node must be a function of the *state* alone, because the antecedent's
step clause is read under `⊡` and so quantifies over every history through the present state. A
state-local formula's truth is indeed a function of the world state alone, at possibly different
times — that is `plusTruthAt_stateLocal_state_only` below, which is the composition of
`plusStateLocal_stab_iff` with `stab_state_only` and is the exact statement that
`IsPlusStateLocal` (same-time only) does not give. The machine's *own* state, by contrast, is a
function of the cone node, since the `inr` layer of the cone carrier records the path by which a
state was reached: `aaState` reads the machine run off that record, and `aaState_step` is the
identity saying one cone step advances the run by one machine step.

## Main Definitions

- `aaRun`, `aaState` — the machine run along a recorded path, and the machine state a node of the
  cone carrier records
- `aaModel` — the auxiliary-atom valuation on the cone carrier
- `aaIdx` — the machine's input function, a function of the base world state alone
- `aaStep`, `aaExcl`, `aaAnte` — the rule's antecedent as L⁺ formulas: the machine-step clause,
  the exclusivity clause, and their assembly under `⊡G≤`

## Main Results

- `plusTruthAt_next_iff_succ`, `plusTruthAt_next_iff_add_one` — the missing L⁺ truth clause for
  `X`, over a successor order and at `intOrder` respectively
- `plusTruthAt_stateLocal_state_only` — a state-local formula's truth depends on the world state
  alone, at possibly different times
- `plusTruthAt_congr_of_fresh_family` — the finite-family form of
  `NamingRules.plusTruthAt_congr_of_fresh`
- `coneHist_step`, `coneHist_inr_of_anchor` — consecutive states of a history of the cone frame
  are a one-step `coneR` edge, and a history anchored at an `inr` node with empty record stays in
  the `inr` layer forward with a record of the expected length
- `aaState_step` — the step identity that is the semantic core of the antecedent
- `plusTruthAt_aaAnte` — the auxiliary-atom model satisfies the whole antecedent
- `aa_sound_int` — **the headline**: the Auxiliary-Atoms rule is validity-preserving over every
  regular frame over `intOrder`
- `aa_sound_ztime` — the same rule at `FrameClass.ZTime`, by carrier normalization
- `aa_reflectTime_sound_ztime` — the mirror rule at `FrameClass.ZTime`, by reflection

## Not formalized

No completeness, decidability or axiomatizability claim is made or implied. This is a soundness
fact about one rule; what an axiomatization built on it would prove is not settled here. No
derivability (proof-system) form of the rule is stated, and nothing is added to `ProofSystem/`.
The mirror rule is stated at `((aaAnte …).imp φ).reflectTime` rather than expanded in syntax, for
the reason `PlusLanguage/PlusLCSchema.lean`'s `lcN_reflectTime_plusValidZTime` records for its
own mirror.

## References

* [M. Reynolds, *An Axiomatization of Full Computation Tree Logic*][reynolds2001] — §7, the
  Auxiliary-Atoms rule (Definition 4, Lemma 6) and §4.7 Lemma 3 for the unravelling remark. The
  transposition to `⊡`/`G≤` over L⁺ and the proof carried here are not Reynolds'; the partition
  conditions on the `aᵢ` are taken as semantic validity rather than as substitution instances of
  a classical tautology, which is weaker and so yields a more general rule.
* `FormalSystem/Metalogic/NamingRules.lean` — `Fresh`, `plusTruthAt_congr_of_fresh`, and the
  irreflexivity and clock rules this rule's device extends
* `FormalSystem/Semantics/ConeUnravelling.lean` — `coneFrame`, `coneF`, `coneF_twoWayBounded`,
  `coneF_surjective`, `coneFrame_isRegular`
* `FormalSystem/Semantics/HistoryMorphism.lean` — `TwoWayBounded.plus_invariance_of_isZTime`
* `FormalSystem/PlusLanguage/PlusStateLocal.lean` — `PlusFormula.StateLocal`,
  `plusStateLocal_stab_iff`
* `FormalSystem/PlusLanguage/PlusIntTransfer.lean` — `PlusValidInt`,
  `plusValidZTime_iff_plusValidInt`
* `FormalSystem/PlusLanguage/PlusReversal.lean` — `plusValidIn_reflectTime`,
  `plusValidIn_reflectTime_iff`

## Tags

naming-rules · auxiliary-atoms · reynolds · cone-unravelling · soundness · plus-language · ztime
-/

namespace FormalSystem.Metalogic.AuxiliaryAtoms

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules

/-! ## Infrastructure: the `X` clause at L⁺ -/

/--
**`X φ` collapses to the successor**, over a successor order with no maximum.

`PlusFormula.next` is `⊥ U φ`, so the `untl` clause's gap condition forces the witness to be the
immediate successor.

This is the L⁺ twin of `SourceLanguage/SentenceTruth.lean`'s and
`NomicLanguage/NomicTruth.lean`'s `next_iff_succ`. `PlusLanguage/PlusTruth.lean` carries no such
clause, which is why it is proved here, at the one module that needs it. **Promotion candidate**:
`PlusLanguage/PlusTruth.lean` is its eventual home, beside the other clause lemmas; promoting it
is deliberately not done here, because that module is widely imported and no current client
outside this one consumes the statement. A later reader should promote it and re-point this
module's use sites rather than duplicate it, exactly as
`Semantics.base_taskRel_eq_ofStepRel`'s own placement note asks.

Paper: — (formalization-native; the manuscript states no `X` clause for L⁺)
-/
theorem plusTruthAt_next_iff_succ {F : TaskFrame} [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (Order.succ t) φ := by
  rw [PlusFormula.next, PlusTruth.untl_iff]
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    rcases lt_or_eq_of_le (Order.succ_le_of_lt hts) with h | h
    · exact absurd (hgap (Order.succ t) (Order.lt_succ t) h) (PlusTruth.bot_false M τ _)
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, Order.lt_succ t, h,
      fun r hr hrs => absurd (Order.succ_le_of_lt hr) (not_le_of_gt hrs)⟩

/-- **`X φ` collapses to `t + 1`** at `intOrder`, the form every use site in this module wants.
One rewrite through `Order.succ_eq_add_one`, which synthesizes over `↑intOrder`.

Paper: — (formalization-native; the manuscript states no `X` clause for L⁺)
-/
theorem plusTruthAt_next_iff_add_one {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ↑intOrder) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (t + 1) φ := by
  rw [plusTruthAt_next_iff_succ M τ t φ, Order.succ_eq_add_one]

/-! ## Infrastructure: state-local truth at different times -/

/--
**A state-local formula's truth depends on the world state alone**, at possibly *different* times:
if `τ(t) = σ(s)` then `φ` has the same truth value at `(τ, t)` and `(σ, s)`.

This is the composition of `plusStateLocal_stab_iff` (a state-local `φ` is already `⊡`-stable)
with `stab_state_only` (`⊡ψ` depends on the world state alone, across times).

**It is not a restatement of `IsPlusStateLocal`, and the distinction is the point.**
`IsPlusStateLocal` fixes the time on both sides, and `PlusLanguage/PlusStateLocal.lean`'s module
docstring records that the different-times shape "does **not** generalize to this fragment" —
true of `box φ`, whose truth is a per-model datum constant along a history but *not* determined
by the state. For a `StateLocal φ` the composition above does give the different-times statement,
and that is exactly what makes the Auxiliary-Atoms machine's input function `aaIdx : WorldState →
ℕ` well defined: the antecedent's step clause is read under `⊡`, at times other than the one at
which the input was read.

**Promotion candidate**: `PlusLanguage/PlusStateLocal.lean`, beside `plusStateLocal_stab_iff`
itself. Not promoted here for the same reason as `plusTruthAt_next_iff_succ` above.

Paper: — (formalization-native; the manuscript classifies no L⁺ constructor for state-locality)
-/
theorem plusTruthAt_stateLocal_state_only {F : TaskFrame} {φ : PlusFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) (τ σ : WorldHistory F) (t s : F.Duration) (h : τ.state t = σ.state s) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M σ s φ :=
  (plusStateLocal_stab_iff hφ M τ t).trans
    ((stab_state_only M τ σ t s h φ).trans (plusStateLocal_stab_iff hφ M σ s).symm)

/-! ## Infrastructure: forgetting a finite family of auxiliary atoms -/

/--
**L⁺ truth is unchanged by a valuation change confined to a finite family of fresh atoms.**

The finite-family form of `NamingRules.plusTruthAt_congr_of_fresh`, which forgets one atom. The
Auxiliary-Atoms rule discharges a whole finite set `Q = {qa 0, …, qa (m-1)}` of auxiliary
letters, so the single-atom form cannot be iterated usefully: the intermediate models would each
have to be exhibited. The side condition on the valuations is read as "`r` is none of the first
`m` members of the family", and `NamingRules.Fresh` itself is reused rather than re-defined, so
the tree keeps one notion of freshness.

By induction on `φ`, arm for arm as the single-atom form, with each inductive hypothesis fed the
componentwise freshness it needs.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem plusTruthAt_congr_of_fresh_family {F : TaskFrame} (M M' : TaskModel F) (qa : ℕ → Atom)
    (m : ℕ)
    (hV : ∀ (w : F.WorldState) (r : Atom), (∀ j, j < m → r ≠ qa j) →
      (M.valuation w r ↔ M'.valuation w r)) :
    ∀ φ : PlusFormula, (∀ j, j < m → Fresh (qa j) φ) →
      ∀ (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M' τ t φ := by
  intro φ
  induction φ with
  | atom p => intro hq τ t; exact hV _ _ fun j hj => hq j hj
  | bot => intro _ _ _; exact Iff.rfl
  | imp a b ih1 ih2 =>
    intro hq τ t
    exact imp_congr (ih1 (fun j hj => (hq j hj).1) τ t) (ih2 (fun j hj => (hq j hj).2) τ t)
  | box a ih => intro hq τ t; exact forall_congr' fun σ => ih hq σ t
  | untl a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 (fun j hj => (hq j hj).2) τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 (fun j hj => (hq j hj).1) τ r)
  | snce a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 (fun j hj => (hq j hj).2) τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 (fun j hj => (hq j hj).1) τ r)
  | stab a ih =>
    intro hq τ t
    exact forall_congr' fun σ => imp_congr_right fun _ => ih hq σ t

/-! ## Histories of the cone frame -/

/--
**Consecutive states of a history of the cone frame are a one-step `coneR` edge.**

`WorldHistory.respects_task` gives the task relation at the duration `s + 1 - s`, which `abel`
normalizes to `1`; `coneFrame_taskRel` then reads that as `ofStepRel (coneR F.step)`, whose
nonnegative conjunct at duration `1` is a single `coneR` step.

**The intermediate `have` is at `FrameOver.TaskRel`, deliberately.** `coneFrame_taskRel` is an
equality of `FrameOver.TaskRel`s and does *not* rewrite a goal phrased with
`(coneFrame F).toTaskFrame.TaskRel`, which is the shape `WorldHistory.respects_task` hands over;
`toTaskFrame` is `@[reducible]`, so stating the `have` at the `FrameOver` projection typechecks
against the history's own field and leaves a goal the rewrite applies to.

`abel`, not `omega`, discharges `s + 1 - s = 1`: `omega` reports "no usable constraints" on
`↑intOrder`.

Paper: — (formalization-native; the paper defines no unravelling of a task frame)
-/
theorem coneHist_step (F : FrameOver intOrder) [F.IsRegular]
    (τ' : WorldHistory (coneFrame F).toTaskFrame) (s : ↑intOrder) :
    coneR F.step (τ'.state s) (τ'.state (s + 1)) := by
  have h0 : (coneFrame F).TaskRel (τ'.state s) 1 (τ'.state (s + 1)) := by
    have := τ'.respects_task s (s + 1)
    rwa [show s + 1 - s = (1 : ↑intOrder) by abel] at this
  rw [coneFrame_taskRel] at h0
  have h1 := h0.1 (by norm_num)
  simp only [show (1 : ℤ).natAbs = 1 from rfl] at h1
  obtain ⟨v, hv, hstep⟩ := h1
  exact (iter_zero _ _ _ |>.mp hv) ▸ hstep

/--
**A history anchored at an `inr` node with empty record stays in the `inr` layer forward**, with
a record of exactly the elapsed length.

Induction on `n` off `coneHist_step`: forward from an `inr` node every `coneR` edge is a `coneRin`
edge, which prepends one state to the record, so the length tracks the elapsed time. The length
conjunct is what makes the induction go through — it is not consumed downstream, but without it
the inductive hypothesis says nothing about the record and the step case cannot be closed.

`push_cast` + `abel` moves `t + ((n + 1 : ℕ) : ℤ)` to `t + (n : ℤ) + 1`; again not `omega`.

Paper: — (formalization-native; the paper defines no unravelling of a task frame)
-/
theorem coneHist_inr_of_anchor (F : FrameOver intOrder) [F.IsRegular]
    (τ' : WorldHistory (coneFrame F).toTaskFrame) (t : ↑intOrder) (w : F.WorldState)
    (ha : τ'.state t = .inr (w, [])) :
    ∀ n : ℕ, ∃ x : F.WorldState × List F.WorldState,
      τ'.state (t + (n : ℤ)) = .inr x ∧ x.2.length = n := by
  intro n
  induction n with
  | zero => exact ⟨(w, []), by simpa using ha, rfl⟩
  | succ n ih =>
    obtain ⟨x, hx, hlen⟩ := ih
    have hstep := coneHist_step F τ' (t + (n : ℤ))
    rw [hx] at hstep
    rw [show t + ((n + 1 : ℕ) : ℤ) = t + (n : ℤ) + 1 by push_cast; abel]
    rcases hv : τ'.state (t + (n : ℤ) + 1) with v | y
    · rw [hv] at hstep; exact hstep.elim
    · rw [hv] at hstep
      exact ⟨y, rfl, by rw [hstep.2]; simp [hlen]⟩

/-! ## The machine run along a recorded path -/

/--
**The machine run along a recorded path.**

`aaRun p b₀ idx l` is the state the machine `p` reaches from the initial state `b₀` after reading
the inputs `idx` of the states in `l`, *last first*: the recorded list of a cone node is
**most-recent-first**, which is the orientation `coneRin` produces (it prepends the state just
left), so the recursion consumes the head last.

Paper: — (formalization-native; the paper's machine runs along a path of the model, not along a
recorded list)
-/
def aaRun {W : Type} (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (idx : W → ℕ) : List W → ℕ
  | [] => b₀
  | u :: h => p (aaRun p b₀ idx h) (idx u)

/--
**Which machine state a node of the cone carrier records.** An `inl` node carries no record and
reads the initial state; an `inr` node reads the run along its record.

Paper: — (formalization-native; the paper's machine runs along a path of the model, not along a
recorded list)
-/
def aaState {W : Type} (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (idx : W → ℕ) : W ⊕ (W × List W) → ℕ
  | .inl _ => b₀
  | .inr x => aaRun p b₀ idx x.2

/--
**The semantic core of the Auxiliary-Atoms antecedent**: one cone step advances the machine run by
one machine step.

Precisely: on a history `ρ'` of the cone frame anchored at an `inr` node with empty record at `t`,
at every time `s ≥ t`, and for *every* history `η'` agreeing with `ρ'` at `s`, the machine state
recorded at `η'(s + 1)` is `p` applied to the machine state at `ρ'(s)` and the input read off the
projection of that state. The quantifier over `η'` is what the antecedent's `⊡` needs: the step
clause is read on every history through the present state.

The anchor hypothesis is load-bearing through `coneHist_inr_of_anchor`: without it `ρ'(s)` could
be an `inl` node, whose successor's record is a singleton rather than an extension, and the
identity fails.

The offset extraction is `⟨(s - t).toNat, …⟩` discharged by `Int.toNat_of_nonneg` + `sub_nonneg`
+ `abel`. The archived probe's `by omega` does not transfer: `omega` reports "no usable
constraints" on `↑intOrder`. The final restatement uses `change`, not `show`, because
`linter.style.show` rejects a goal-changing `show`.

This is the archived probe's `aa_expand` restated over `WorldHistory (coneFrame F)`; the
Mathlib-only ancestor is `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` Part J.

Paper: — (formalization-native; the paper's Lemma 6 argues on a tree model, not on a recorded
cone)
-/
theorem aaState_step (F : FrameOver intOrder) [F.IsRegular]
    (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (idx : F.WorldState → ℕ)
    (t : ↑intOrder) (w : F.WorldState)
    (ρ' : WorldHistory (coneFrame F).toTaskFrame) (ha : ρ'.state t = .inr (w, []))
    (s : ↑intOrder) (hs : t ≤ s)
    (η' : WorldHistory (coneFrame F).toTaskFrame) (he : η'.state s = ρ'.state s) :
    aaState p b₀ idx (η'.state (s + 1))
      = p (aaState p b₀ idx (ρ'.state s)) (idx (coneF (ρ'.state s))) := by
  obtain ⟨n, rfl⟩ : ∃ n : ℕ, s = t + (n : ℤ) :=
    ⟨(s - t).toNat, by
      have h : ((s - t).toNat : ℤ) = s - t := Int.toNat_of_nonneg (by simpa using sub_nonneg.mpr hs)
      rw [show ((((s - t).toNat : ℕ) : ℤ) : ↑intOrder) = ((s - t : ↑intOrder)) from h]
      abel⟩
  obtain ⟨x, hx, _⟩ := coneHist_inr_of_anchor F ρ' t w ha n
  have hstep := coneHist_step F η' (t + (n : ℤ))
  rw [he, hx] at hstep
  rcases hv : η'.state (t + (n : ℤ) + 1) with v | y
  · rw [hv] at hstep; exact hstep.elim
  · rw [hv] at hstep
    rw [hx]
    change aaRun p b₀ idx y.2 = p (aaRun p b₀ idx x.2) (idx x.1)
    rw [hstep.2]; rfl

/-! ## The antecedent as L⁺ syntax -/

/--
**The machine-step clause** `⋀_{j<m} ⋀_{i<k} ((q_j ∧ aᵢ) → ⊡X q_{p j i})`.

Reynolds' Definition 4 clause for clause, with `⊡X` where the source has its own next-step
operator: the consequent must hold on *every* history through the state reached, not only along
the history at hand, which is what makes the machine's labelling a function of the state.

`bigAnd` is single-level and `ℕ`-indexed, so the double family is a nested `bigAnd`.

Paper: — (formalization-native; the transposition to `⊡`/`G≤` over L⁺ is not Reynolds')
-/
def aaStep (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) : PlusFormula :=
  bigAnd m fun j => bigAnd k fun i =>
    ((PlusFormula.atom (qa j)).and (a i)).imp
      (PlusFormula.stab (PlusFormula.atom (qa (p j i))).next)

/--
**The exclusivity clause** `⋀_{j<m} ⋀_{j'<m, j'≠j} ¬(q_j ∧ q_{j'})`: no two auxiliary atoms hold
together.

**The diagonal carries `top`, by convention stated here.** `bigAnd` ranges over the full `m × m`
square, and the diagonal entry `¬(q_j ∧ q_j)` is unsatisfiable, so the pair `(j, j)` is guarded
by `if j = j' then PlusFormula.top`. `bigAnd_iff` then yields a clean
`∀ j < m, ∀ j' < m, …` that a `rcases eq_or_ne j j'` splits, with the diagonal branch discharged
by `PlusTruth.top_true`. Decidable equality on `ℕ` means no classical choice enters here.

Paper: — (formalization-native; the transposition to `⊡`/`G≤` over L⁺ is not Reynolds')
-/
def aaExcl (qa : ℕ → Atom) (m : ℕ) : PlusFormula :=
  bigAnd m fun j => bigAnd m fun j' =>
    if j = j' then PlusFormula.top
    else ((PlusFormula.atom (qa j)).and (PlusFormula.atom (qa j'))).neg

/--
**The Auxiliary-Atoms antecedent**, the L⁺ transposition of Reynolds §7's `θ`: three conjuncts —

* `q_{b₀}` — the machine starts in state `b₀` here;
* `⊡G≤ (aaStep …)` — the machine-step clause, on every history through the present state and at
  every time from now on;
* `⊡G≤ (aaExcl …)` — the exclusivity clause, under the same two closures.

Both closed conjuncts sit under `⊡G≤` rather than `□△`: the rule is run on the cone unravelling
anchored at the present point, so only the forward cone of the present stability cluster is
constrained, which is exactly what the construction can supply.

Paper: — (formalization-native; the transposition to `⊡`/`G≤` over L⁺ is not Reynolds')
-/
def aaAnte (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) :
    PlusFormula :=
  ((PlusFormula.atom (qa b₀)).and (PlusFormula.stab (aaStep qa m k a p).gle)).and
    (PlusFormula.stab (aaExcl qa m).gle)

/-! ### Reading the antecedent's three conjuncts back out -/

/-- **The antecedent's initial conjunct**: the atom `q_{b₀}` holds at the evaluation point. One
`PlusTruth.and_iff` unpacking.

Paper: — (formalization-native; the transposition to `⊡`/`G≤` over L⁺ is not Reynolds')
-/
theorem plusTruthAt_aaAnte_initial {F : TaskFrame} (M : TaskModel F) (qa : ℕ → Atom) (m k : ℕ)
    (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (τ : WorldHistory F) (x : F.Duration)
    (h : PlusTruthAt M τ x (aaAnte qa m k a p b₀)) :
    M.valuation (τ.state x) (qa b₀) :=
  ((PlusTruth.and_iff M τ x _ _).mp ((PlusTruth.and_iff M τ x _ _).mp h).1).1

/--
**The antecedent's step conjunct**, read out at an arbitrary point of the forward cone of the
present stability cluster: on every history `σ` through `τ(x)` at `x`, at every `s ≥ x`, if `q_j`
and `aᵢ` both hold at `(σ, s)` then `q_{p j i}` holds at `(σ', s + 1)` for *every* history `σ'`
agreeing with `σ` at `s`.

The ladder is `PlusTruth.and_iff` → `PlusTruth.stab_iff` → `gle_iff` → `bigAnd_iff` twice →
`PlusTruth.imp_iff`/`and_iff` → `PlusTruth.stab_iff` → `plusTruthAt_next_iff_add_one`. The last
step is why this lemma is stated at `FrameOver intOrder` rather than at an arbitrary
`TaskFrame`.

Paper: — (formalization-native; the transposition to `⊡`/`G≤` over L⁺ is not Reynolds')
-/
theorem plusTruthAt_aaAnte_step {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ)
    (τ : WorldHistory F.toTaskFrame) (x : ↑intOrder)
    (h : PlusTruthAt M τ x (aaAnte qa m k a p b₀))
    (σ : WorldHistory F.toTaskFrame) (hσ : τ.state x = σ.state x)
    (s : ↑intOrder) (hs : x ≤ s) (j : ℕ) (hj : j < m) (i : ℕ) (hi : i < k)
    (hq : M.valuation (σ.state s) (qa j)) (hai : PlusTruthAt M σ s (a i))
    (σ' : WorldHistory F.toTaskFrame) (hσ' : σ.state s = σ'.state s) :
    M.valuation (σ'.state (s + 1)) (qa (p j i)) := by
  have h1 := ((PlusTruth.and_iff M τ x _ _).mp ((PlusTruth.and_iff M τ x _ _).mp h).1).2
  have h2 := (PlusTruth.stab_iff M τ x _).mp h1 σ hσ
  have h3 := (gle_iff M σ x _).mp h2 s hs
  have h4 := (bigAnd_iff M σ s _ m).mp h3 j hj
  have h5 := (bigAnd_iff M σ s _ k).mp h4 i hi
  have h6 := (PlusTruth.imp_iff M σ s _ _).mp h5 ((PlusTruth.and_iff M σ s _ _).mpr ⟨hq, hai⟩)
  have h7 := (PlusTruth.stab_iff M σ s _).mp h6 σ' hσ'
  exact (plusTruthAt_next_iff_add_one M σ' s _).mp h7

/--
**The antecedent's exclusivity conjunct**, read out over the same forward cone: on every history
`σ` through `τ(x)` at `x`, at every `s ≥ x`, no two distinct auxiliary atoms below `m` hold
together at `(σ, s)`.

The same ladder as the step conjunct down to the two `bigAnd_iff`s, then `if_neg` on the
`j ≠ j'` guard discharges the `top` diagonal.

Paper: — (formalization-native; the transposition to `⊡`/`G≤` over L⁺ is not Reynolds')
-/
theorem plusTruthAt_aaAnte_excl {F : TaskFrame} (M : TaskModel F) (qa : ℕ → Atom) (m k : ℕ)
    (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (τ : WorldHistory F) (x : F.Duration)
    (h : PlusTruthAt M τ x (aaAnte qa m k a p b₀))
    (σ : WorldHistory F) (hσ : τ.state x = σ.state x)
    (s : F.Duration) (hs : x ≤ s) (j : ℕ) (hj : j < m) (j' : ℕ) (hj' : j' < m) (hne : j ≠ j') :
    ¬ (M.valuation (σ.state s) (qa j) ∧ M.valuation (σ.state s) (qa j')) := by
  have h1 := (PlusTruth.and_iff M τ x _ _).mp h |>.2
  have h2 := (PlusTruth.stab_iff M τ x _).mp h1 σ hσ
  have h3 := (gle_iff M σ x _).mp h2 s hs
  have h4 := (bigAnd_iff M σ s _ m).mp h3 j hj
  have h5 := (bigAnd_iff M σ s _ m).mp h4 j' hj'
  rw [if_neg hne] at h5
  intro hc
  exact (PlusTruth.neg_iff M σ s _).mp h5 ((PlusTruth.and_iff M σ s _ _).mpr hc)

/-! ## The auxiliary-atom model on the cone carrier -/

/--
**The auxiliary-atom model**: on the cone carrier, each `q_j` with `j < m` reads the machine
state `st` recorded at the node, and every other atom reads the base model through the projection
`coneF`.

The two disjuncts are mutually exclusive by their own side conditions, which is what makes the
two reading lemmas below biconditionals rather than one-way implications.

Paper: — (formalization-native; the paper labels a tree model, not a recorded cone)
-/
def aaModel (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m : ℕ) (st : (coneFrame F).WorldState → ℕ) :
    TaskModel (coneFrame F).toTaskFrame :=
  ⟨fun z r => (∃ j, j < m ∧ r = qa j ∧ st z = j) ∨
    ((∀ j, j < m → r ≠ qa j) ∧ M.valuation (coneF z) r)⟩

/--
**Reading an auxiliary atom**: `q_j` holds at a node exactly when the machine state recorded
there is `j`.

**The injectivity-below-`m` hypothesis is load-bearing**, not decoration: without it two indices
`j ≠ j'` could name the same atom, and `q_j` would hold at a node recording `j'` through the
first disjunct, so the biconditional would fail left to right.

Paper: — (formalization-native; the paper labels a tree model, not a recorded cone)
-/
theorem aaModel_atom_q (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m : ℕ) (st : (coneFrame F).WorldState → ℕ)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (z : (coneFrame F).WorldState) (j : ℕ) (hj : j < m) :
    (aaModel F M qa m st).valuation z (qa j) ↔ st z = j := by
  constructor
  · rintro (⟨j', hj', he, hst⟩ | ⟨hne, _⟩)
    · exact hst.trans (hinj j' hj' j hj he.symm)
    · exact absurd rfl (hne j hj)
  · intro h; exact Or.inl ⟨j, hj, rfl, h⟩

/-- **Reading any other atom**: an atom outside the auxiliary family is read off the base model
through the projection. This is what `plusTruthAt_congr_of_fresh_family` consumes to forget `Q`.

Paper: — (formalization-native; the paper labels a tree model, not a recorded cone)
-/
theorem aaModel_valuation_off (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m : ℕ) (st : (coneFrame F).WorldState → ℕ)
    (z : (coneFrame F).WorldState) (r : Atom) (hr : ∀ j, j < m → r ≠ qa j) :
    (aaModel F M qa m st).valuation z r ↔ M.valuation (coneF z) r := by
  constructor
  · rintro (⟨j, hj, he, _⟩ | ⟨_, h⟩)
    · exact absurd he (hr j hj)
    · exact h
  · intro h; exact Or.inr ⟨hr, h⟩

/-! ## The machine's input function -/

/--
**The machine's input function**: the index of an `aᵢ` true at the base world state `w`, or `0`
when none is.

The input must be a function of the **state** alone — the antecedent's step clause is read under
`⊡`, so the input read at one history must be the input read at every history through that state,
at every time. `plusTruthAt_stateLocal_state_only` is what makes that well defined for a
`StateLocal` family, and `aaIdx_spec` below is where it is consumed.

**`Classical.choice` enters here and nowhere else in this module**, through `h.choose` on the
`dite`'s real branch. The `0` fallback is never consulted at a state that actually occurs on a
history: `aaIdx_of_occurring` shows the real branch is always taken there, under exhaustiveness.
The fallback exists only so that the function is total, which the machine-labelling definitions
`aaRun`/`aaState` require.

**No `[F.IsRegular]` binder.** The definition reads only the frame's world states and histories,
so regularity is not needed here; it is needed at `aaIdx_of_occurring` and `aaIdx_spec`, where
`PlusValidInt`'s own `[F.IsRegular]` binder has to be discharged to instantiate the partition
hypotheses. Carrying an unread instance binder here would be a `unusedArguments` finding with no
contract to justify it, unlike `aa_sound_int`'s `hexh`.

Paper: — (formalization-native; the paper's machine reads a propositional labelling directly)
-/
noncomputable def aaIdx (F : FrameOver intOrder) (M : TaskModel F.toTaskFrame)
    (a : ℕ → PlusFormula) (k : ℕ) : F.WorldState → ℕ := fun w =>
  haveI : Decidable (∃ i, i < k ∧ ∃ (τ : WorldHistory F.toTaskFrame) (t : ℤ),
      τ.state t = w ∧ PlusTruthAt M τ t (a i)) := Classical.dec _
  if h : ∃ i, i < k ∧ ∃ (τ : WorldHistory F.toTaskFrame) (t : ℤ),
      τ.state t = w ∧ PlusTruthAt M τ t (a i)
    then h.choose else 0

/-- **The input is in range** whenever the `dite` takes its real branch — which, by
`aaIdx_of_occurring`, is at every state that occurs on a history.

Paper: — (formalization-native; the paper's machine reads a propositional labelling directly)
-/
theorem aaIdx_lt (F : FrameOver intOrder) (M : TaskModel F.toTaskFrame)
    (a : ℕ → PlusFormula) (k : ℕ) (w : F.WorldState)
    (h : ∃ i, i < k ∧ ∃ (τ : WorldHistory F.toTaskFrame) (t : ℤ),
      τ.state t = w ∧ PlusTruthAt M τ t (a i)) :
    aaIdx F M a k w < k := by
  simp only [aaIdx, dif_pos h]
  exact h.choose_spec.1

/--
**At a state that occurs on a history, the `dite` takes its real branch.**

This is where **exhaustiveness** is consumed: `hexh` says no point makes every `aᵢ` false, so at
`(τ, t)` some `aᵢ` with `i < k` holds, and that is the witness the `dite`'s condition asks for.

**No "history through a state" existence lemma is used, and none exists in this tree.** The
witness history is the one the caller already has, which is why this lemma is stated at a state
*presented* as `τ.state t` rather than at an arbitrary state of the carrier.

Paper: — (formalization-native; the paper's machine reads a propositional labelling directly)
-/
theorem aaIdx_of_occurring (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (a : ℕ → PlusFormula) (k : ℕ)
    (hexh : PlusValidInt (bigAnd k fun i => (a i).neg).neg)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ∃ i, i < k ∧ ∃ (σ : WorldHistory F.toTaskFrame) (s : ℤ),
      σ.state s = τ.state t ∧ PlusTruthAt M σ s (a i) := by
  have h := (PlusTruth.neg_iff M τ t _).mp (hexh F M τ t)
  by_contra hc
  refine h ((bigAnd_iff M τ t _ k).mpr fun i hi => ?_)
  refine (PlusTruth.neg_iff M τ t _).mpr fun hai => ?_
  exact hc ⟨i, hi, τ, t, rfl, hai⟩

/--
**The input function is exactly the index**: if some `aᵢ` with `i < k` holds at a point whose
state is `w`, then `aaIdx … w = i`.

This is the lemma with real content in the input layer, and it is where **pairwise
inconsistency** is consumed. The `dite`'s real branch is reached by the hypothesis itself, so the
chosen index `i'` satisfies `aᵢ'` at *some* point whose state is also `w`;
`plusTruthAt_stateLocal_state_only` transports that truth from the chosen witness point to the
given one — this is the step that needs state-locality at *different times*, which
`IsPlusStateLocal` does not give — and `hdisj` then forces `i' = i`.

Paper: — (formalization-native; the paper's machine reads a propositional labelling directly)
-/
theorem aaIdx_spec (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (a : ℕ → PlusFormula) (k : ℕ)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidInt (((a i).and (a i')).neg))
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (i : ℕ) (hi : i < k)
    (hai : PlusTruthAt M τ t (a i)) :
    aaIdx F M a k (τ.state t) = i := by
  have hex : ∃ i, i < k ∧ ∃ (σ : WorldHistory F.toTaskFrame) (s : ℤ),
      σ.state s = τ.state t ∧ PlusTruthAt M σ s (a i) := ⟨i, hi, τ, t, rfl, hai⟩
  simp only [aaIdx, dif_pos hex]
  obtain ⟨hlt, σ, s, hst, hspec⟩ := hex.choose_spec
  by_contra hne
  have htr : PlusTruthAt M τ t (a hex.choose) :=
    (plusTruthAt_stateLocal_state_only (ha _ hlt) M σ τ s t hst).mp hspec
  exact (PlusTruth.neg_iff M τ t _).mp (hdisj _ hlt i hi hne F M τ t)
    ((PlusTruth.and_iff M τ t _ _).mpr ⟨htr, hai⟩)

/-! ## The antecedent holds at the constructed model -/

/--
**The auxiliary-atom model satisfies the whole Auxiliary-Atoms antecedent**, on every history of
the cone frame anchored at an `inr` node with empty record.

The three conjuncts:

* **initial** — `aaState` at an `inr` node with empty record is `aaRun … [] = b₀` by `rfl`, and
  `aaModel_atom_q` reads that back as `q_{b₀}`;
* **exclusivity** — `aaModel_atom_q` at two indices says the node's machine state is both `j` and
  `j'`, and `aaState` is a function, so `j = j'`; the diagonal is `top`;
* **step** — the only branch with work in it. At a cone node `ρ'(s)` where `q_j` and `aᵢ` both
  hold, `aᵢ`'s truth is transferred to the base model in two moves: `aaModel_valuation_off`
  together with `plusTruthAt_congr_of_fresh_family` (reading `hfreshA`) replaces the
  auxiliary-atom valuation by the pulled-back one, and the morphism's own truth equivalence
  carries it to `M` along `g.mapH ρ'`. `aaIdx_spec` then forces `aaIdx … (coneF (ρ'(s))) = i`,
  which is the input `aaState` actually stepped on, so `aaState_step` computes the machine state
  at `η'(s + 1)` as `p j i` for *every* history `η'` agreeing with `ρ'` at `s` — which is what
  the `⊡` in the step clause's consequent quantifies over — and `plusTruthAt_next_iff_add_one`
  turns the `X` into `s + 1`.

**Exhaustiveness is not consumed here.** The step clause's antecedent is an implication, so a
node at which no `aᵢ` holds places no demand on the machine and the `aaIdx` fallback is never
read. Exhaustiveness is what makes the rule *useful* — it is what pins the machine's run down to
one run — not what makes it sound. See `aa_sound_int` for the same observation at the headline.

Paper: — (formalization-native; the paper's Lemma 6 argues on a tree model, not on a recorded
cone)
-/
theorem plusTruthAt_aaAnte (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidInt (((a i).and (a i')).neg))
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (τ' : WorldHistory (coneFrame F).toTaskFrame) (x : ↑intOrder) (ω : F.WorldState)
    (hax : τ'.state x = .inr (ω, [])) :
    PlusTruthAt (aaModel F M qa m (aaState p b₀ (aaIdx F M a k))) τ' x
      (aaAnte qa m k a p b₀) := by
  obtain ⟨g, hgf, hinv⟩ :=
    @TwoWayBounded.plus_invariance_of_isZTime intOrder (coneFrame F) F
      (coneFrame_isRegular F) ‹F.IsRegular›
      (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (IsSuccArchimedean ℤ))
      coneF (coneF_twoWayBounded F) (coneF_surjective (E := F.step)) M
  have hpull : ∀ (z : (coneFrame F).WorldState) (r : Atom),
      (g.pullM M).valuation z r ↔ M.valuation (coneF z) r := by
    intro z r
    change M.valuation (g.toFun z) r ↔ M.valuation (coneF z) r
    rw [hgf]
  have hV : ∀ (z : (coneFrame F).WorldState) (r : Atom), (∀ j, j < m → r ≠ qa j) →
      ((aaModel F M qa m (aaState p b₀ (aaIdx F M a k))).valuation z r ↔
        (g.pullM M).valuation z r) :=
    fun z r hr =>
      (aaModel_valuation_off F M qa m _ z r hr).trans (hpull z r).symm
  have hcongr := plusTruthAt_congr_of_fresh_family
    (aaModel F M qa m (aaState p b₀ (aaIdx F M a k))) (g.pullM M) qa m hV
  refine (PlusTruth.and_iff _ τ' x _ _).mpr
    ⟨(PlusTruth.and_iff _ τ' x _ _).mpr ⟨?_, ?_⟩, ?_⟩
  · -- the initial conjunct
    have h0 : aaState p b₀ (aaIdx F M a k) (τ'.state x) = b₀ := by rw [hax]; rfl
    exact (aaModel_atom_q F M qa m _ hinj _ b₀ hb₀).mpr h0
  · -- the step conjunct
    refine (PlusTruth.stab_iff _ τ' x _).mpr fun ρ' hρ => (gle_iff _ ρ' x _).mpr fun s hs => ?_
    refine (bigAnd_iff _ ρ' s _ m).mpr fun j hj => (bigAnd_iff _ ρ' s _ k).mpr fun i hi => ?_
    refine (PlusTruth.imp_iff _ ρ' s _ _).mpr fun hand => ?_
    obtain ⟨hqj, hai⟩ := (PlusTruth.and_iff _ ρ' s _ _).mp hand
    refine (PlusTruth.stab_iff _ ρ' s _).mpr fun η' he => ?_
    refine (plusTruthAt_next_iff_add_one _ η' s _).mpr ?_
    refine (aaModel_atom_q F M qa m _ hinj _ (p j i) (hp j hj i hi)).mpr ?_
    have hanchor : ρ'.state x = .inr (ω, []) := hρ.symm.trans hax
    have hstep := aaState_step F p b₀ (aaIdx F M a k) x ω ρ' hanchor s hs η' he.symm
    have hjeq : aaState p b₀ (aaIdx F M a k) (ρ'.state s) = j :=
      (aaModel_atom_q F M qa m _ hinj _ j hj).mp hqj
    have hbase : PlusTruthAt M (g.mapH ρ') s (a i) :=
      (hinv (a i) ρ' s).mp ((hcongr (a i) (fun jj hjj => hfreshA jj hjj i hi) ρ' s).mp hai)
    have hidx : aaIdx F M a k (coneF (ρ'.state s)) = i := by
      have h0 := aaIdx_spec F M a k ha hdisj (g.mapH ρ') s i hi hbase
      rwa [HistMap.mapH_state, hgf] at h0
    rw [hstep, hjeq, hidx]
  · -- the exclusivity conjunct
    refine (PlusTruth.stab_iff _ τ' x _).mpr fun ρ' _ => (gle_iff _ ρ' x _).mpr fun s _ => ?_
    refine (bigAnd_iff _ ρ' s _ m).mpr fun j hj => (bigAnd_iff _ ρ' s _ m).mpr fun j' hj' => ?_
    rcases eq_or_ne j j' with rfl | hne
    · rw [if_pos rfl]
      exact PlusTruth.top_true _ ρ' s
    · rw [if_neg hne]
      refine (PlusTruth.neg_iff _ ρ' s _).mpr fun hc => ?_
      obtain ⟨h1, h2⟩ := (PlusTruth.and_iff _ ρ' s _ _).mp hc
      exact hne (((aaModel_atom_q F M qa m _ hinj _ j hj).mp h1).symm.trans
        ((aaModel_atom_q F M qa m _ hinj _ j' hj').mp h2))

/-! ## The headline: the Auxiliary-Atoms rule is validity-preserving -/

-- `linter.unusedVariables`, scoped to this declaration: the `hexh` binder is genuinely unread,
-- and a deletion trial confirms it — dropping the hypothesis raises no error inside this proof,
-- the only breakage being the positional application at `aa_sound_ztime`'s call site below
-- (measured with `lean_minimal_hypotheses`). The reason is that the antecedent's step clause is
-- an implication, so a point at which no `aᵢ` holds places no demand on the machine. The binder
-- is retained because it is the published signature this theorem's recorded statement fixes, and
-- because dropping it would silently change the rule's shape relative to Reynolds' §7; see the
-- doc comment below and `scripts/nolint-attribute-allowlist.txt`.
set_option linter.unusedVariables false in
/--
**Soundness of the Auxiliary-Atoms rule over every regular frame over `intOrder`.**

If `(aaAnte …) → φ` is `ℤ`-valid, the auxiliary atoms `q_0, …, q_{m-1}` are distinct and occur
neither in `φ` nor in any `aᵢ`, the `aᵢ` are state-local and pairwise inconsistent, the machine
`p` stays below `m`, and the initial state `b₀` is below `m`, then `φ` is `ℤ`-valid.

The eight steps, at an arbitrary regular `F`, model `M`, history `τ` and time `x`:

1. `TwoWayBounded.plus_invariance_of_isZTime` at `coneF_twoWayBounded F` and
   `coneF_surjective` supplies the morphism `g : HistMorphism (coneFrame F) F` with
   `g.toFun = coneF` and the truth biconditional along it;
2. `aaIdx F M a k` is the machine's input function and `aaState p b₀ (aaIdx F M a k)` the machine
   labelling of the cone carrier, so `aaModel` is the auxiliary-atom model;
3. `g.lift τ (.inr (τ.state x, [])) x` anchors a cone history at the `inr` node with empty record
   above `τ(x)` — the side condition is `coneF (.inr (τ.state x, [])) = τ.state x`, which is
   `rfl` after `g.toFun = coneF`. **No history construction and no onto-histories argument is
   needed**: `lift` is already a field of `HistMap`;
4. `plusTruthAt_aaAnte` says the antecedent holds there;
5. `hprem` instantiates at `coneFrame F` — its `[(coneFrame F).IsRegular]` binder is discharged by
   `coneFrame_isRegular`'s instance status — and the implication gives `φ` at the cone model;
6. `plusTruthAt_congr_of_fresh_family`, fed `aaModel_valuation_off`, forgets the auxiliary atoms
   and lands at the pulled-back model `g.pullM M`;
7. the morphism's truth biconditional carries `φ` to `M` along `g.mapH τ'`;
8. `WorldHistory.ext_state` on `lift`'s projection equation turns `g.mapH τ'` into `τ`.

**The statement is at `PlusValidInt`, not at a class-generic `PlusValidIn fc`, and that
narrowing is forced**, not sloppiness: `coneFrame F` exists only over `intOrder`, so there is no
cone to run the premise on at another carrier. `clock_irr_sound`'s class-generic signature
(`Metalogic/NamingRules.lean`) is possible there because the translation product is built at an
arbitrary frame class. `aa_sound_ztime` below recovers the `FrameClass.ZTime` form by carrier
normalization, which is the only class this construction reaches.

**Exhaustiveness (`hexh`) is retained in the signature and is not consumed by the proof.** The
step clause of the antecedent is an implication, so a point at which no `aᵢ` holds places no
demand on the machine and `aaIdx`'s `0` fallback is never read; `aaIdx_of_occurring` is the
declaration that consumes exhaustiveness, and it is a recorded fact about the input function
rather than a step of this proof. Exhaustiveness is what makes the rule *useful* — it is what
pins the machine's run down to a single run, which is how Reynolds uses it — not what makes it
sound, so the rule proved here is in that one respect stronger than the rule stated. The binder
is kept because it is the **published signature** this theorem's recorded statement fixes, and
because dropping it would silently change the rule's shape relative to its source; paired entry:
`scripts/nolint-attribute-allowlist.txt`.

**The partition conditions enter as semantic validity hypotheses**, which is a deliberate
deviation from Reynolds' §7, where they are substitution instances of a classical tautology.
Semantic validity is weaker, so the rule obtained is more general.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
@[nolint unusedArguments]
theorem aa_sound_int (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ)
    (φ : PlusFormula) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hexh : PlusValidInt (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidInt (((a i).and (a i')).neg))
    (hfresh : ∀ j, j < m → Fresh (qa j) φ)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hprem : PlusValidInt ((aaAnte qa m k a p b₀).imp φ)) :
    PlusValidInt φ := by
  intro F _ M τ x
  obtain ⟨g, hgf, hinv⟩ :=
    @TwoWayBounded.plus_invariance_of_isZTime intOrder (coneFrame F) F
      (coneFrame_isRegular F) ‹F.IsRegular›
      (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (IsSuccArchimedean ℤ))
      coneF (coneF_twoWayBounded F) (coneF_surjective (E := F.step)) M
  obtain ⟨τ', hτ'x, hτ'⟩ := g.lift τ (.inr (τ.state x, [])) x (by rw [hgf]; rfl)
  have hante := plusTruthAt_aaAnte F M qa m k a p b₀ hb₀ hinj hp ha hdisj hfreshA τ' x
    (τ.state x) hτ'x
  have hφ' : PlusTruthAt (aaModel F M qa m (aaState p b₀ (aaIdx F M a k))) τ' x φ :=
    (PlusTruth.imp_iff _ τ' x _ _).mp
      (hprem (coneFrame F) (aaModel F M qa m (aaState p b₀ (aaIdx F M a k))) τ' x) hante
  have hpull : ∀ (z : (coneFrame F).WorldState) (r : Atom),
      (g.pullM M).valuation z r ↔ M.valuation (coneF z) r := by
    intro z r
    change M.valuation (g.toFun z) r ↔ M.valuation (coneF z) r
    rw [hgf]
  have hV : ∀ (z : (coneFrame F).WorldState) (r : Atom), (∀ j, j < m → r ≠ qa j) →
      ((aaModel F M qa m (aaState p b₀ (aaIdx F M a k))).valuation z r ↔
        (g.pullM M).valuation z r) :=
    fun z r hr => (aaModel_valuation_off F M qa m _ z r hr).trans (hpull z r).symm
  have h2 : PlusTruthAt (g.pullM M) τ' x φ :=
    (plusTruthAt_congr_of_fresh_family (aaModel F M qa m (aaState p b₀ (aaIdx F M a k)))
      (g.pullM M) qa m hV φ hfresh τ' x).mp hφ'
  have h3 := (hinv φ τ' x).mp h2
  have hm : g.mapH τ' = τ := WorldHistory.ext_state hτ'
  rwa [hm] at h3

/--
**The Auxiliary-Atoms rule at the `FrameClass.ZTime` frame class**, by carrier normalization from
`aa_sound_int`.

Each side condition is converted by `plusValidZTime_iff_plusValidInt`; the conclusion is
converted back by the same biconditional. The partition hypotheses are stated at
`PlusValidZTime` here and at `PlusValidInt` in `aa_sound_int` rather than mixed within one
signature, which would read worse than two `.mp` applications.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem aa_sound_ztime (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ) (b₀ : ℕ)
    (φ : PlusFormula) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hexh : PlusValidZTime (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidZTime (((a i).and (a i')).neg))
    (hfresh : ∀ j, j < m → Fresh (qa j) φ)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hprem : PlusValidZTime ((aaAnte qa m k a p b₀).imp φ)) :
    PlusValidZTime φ :=
  (plusValidZTime_iff_plusValidInt φ).mpr
    (aa_sound_int qa m k a p b₀ φ hb₀ hinj hp ha
      ((plusValidZTime_iff_plusValidInt _).mp hexh)
      (fun i hi i' hi' hne => (plusValidZTime_iff_plusValidInt _).mp (hdisj i hi i' hi' hne))
      hfresh hfreshA ((plusValidZTime_iff_plusValidInt _).mp hprem))

/--
**The mirror Auxiliary-Atoms rule at `FrameClass.ZTime`**: the rule read backwards in time is
validity-preserving there too.

`plusValidIn_reflectTime_iff` unreflects the premise — `reflectTime` commutes with `imp`
componentwise by `rfl`, so the unreflected premise is literally `(aaAnte …) → φ` — `aa_sound_ztime`
gives `PlusValidZTime φ`, and `plusValidIn_reflectTime` reflects the conclusion. `FrameClass.ZTime`
is closed under `rev`, which is what `plusValidIn_reflectTime` consumes.

**The side conditions are stated on the unreflected data**, so no `Fresh`-vs-`reflectTime`
commutation lemma is needed.

**The mirror form is deliberately not expanded in syntax**, following
`PlusLanguage/PlusLCSchema.lean`'s `lcN_reflectTime_plusValidZTime`, whose docstring names the
three declarations an expanded mirror would need and declines all three: an `H≤` definition
(neither `Formula` nor `PlusFormula` carries a reflexive *past* closure), a `reflect_time_gle`
push-through lemma, and a `reflect_time_bigAnd` lemma for the `ℕ`-indexed conjunction. The
one-liner below already proves what all three would be built to state. A mirrored cone
construction is likewise not built: reflection of the validity statement is enough.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem aa_reflectTime_sound_ztime (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
    (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (φ : PlusFormula) (hb₀ : b₀ < m)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
    (ha : ∀ i, i < k → (a i).StateLocal)
    (hexh : PlusValidZTime (bigAnd k fun i => (a i).neg).neg)
    (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' → PlusValidZTime (((a i).and (a i')).neg))
    (hfresh : ∀ j, j < m → Fresh (qa j) φ)
    (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
    (hprem : PlusValidZTime (((aaAnte qa m k a p b₀).imp φ).reflectTime)) :
    PlusValidZTime φ.reflectTime :=
  plusValidIn_reflectTime
    (aa_sound_ztime qa m k a p b₀ φ hb₀ hinj hp ha hexh hdisj hfresh hfreshA
      (plusValidIn_reflectTime_iff.mp hprem))

end FormalSystem.Metalogic.AuxiliaryAtoms
