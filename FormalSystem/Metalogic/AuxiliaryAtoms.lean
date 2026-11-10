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

end FormalSystem.Metalogic.AuxiliaryAtoms
