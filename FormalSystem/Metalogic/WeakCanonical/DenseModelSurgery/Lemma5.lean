/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Lemma34
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Dual

/-!
# Reynolds §6 Lemma 5: formula and elementary transfer across classes

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*, printed **p.179**.

This module continues `Lemma34.lean` (Lemmas 3 and 4) with Lemma 5, both of its statements.

## The source, verbatim

Printed p.179, **Lemma 5**:

> **LEMMA 5** *If a temporal formula holds somewhere in one `∼`-class in a maximal interval of
> `R`, then it holds somewhere in each `∼`-class in the interval.*
>
> *Furthermore, each pair of the `∼`-classes in a maximal interval of `R` are elementarily
> equivalent (taken as substructures of `M`).*
>
> **PROOF.** For a contradiction to the first statement, suppose that `A` holds in one class but
> not anywhere in some other class in the same maximal interval of `R`.
>
> Using expressive completeness and `ε`, find `B` which is true at points only if `A` occurs
> somewhere in their `∼`-class. By using `¬B` instead if necessary we may suppose that we have `B`
> holding throughout one `∼`-class in our maximal interval of `R` and false throughout a later
> class. Choose a point `t` in this former class in which `B` holds. `B` holds in the whole of a
> class if it is true anywhere at all in the class so it continues for a while after `t`. By
> Prior-U there is either a last point where `B` holds after `t` (not possible as `B` must continue
> for a while) or a first point `s > t` where `¬B ∧ K⁻(B)` holds.
>
> So `s` must be the left hand end point of its `∼`-class. Look at the gap at right hand end of
> this class. We can not have `B` arbitrarily soon after the gap because of Prior-U. Thus for a
> while after this class `B` stays false.
>
> Let `C` be the temporal formula saying that we are now in a class whose left hand end point is
> also in the class and at that point `K⁻(B)` holds. Now `C` is true in `s`'s class but false
> afterwards contradicting Prior-U.
>
> Now consider the second statement in the lemma. Given a monadic sentence `φ`, we relativise it by
> restricting quantifiers to where `ε(x, −)` holds. We get a formula `φ(x)` of one free variable.
> By expressive completeness this is equivalent to a temporal formula. This is true exactly
> throughout `∼`-classes which model `φ`. Then, by the first part of the lemma, it can't be true
> somewhere and false elsewhere in the interval. ∎

The block above was read off the page image
(`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`, PDF page index 15 = printed p.179)
and not off the pre-segmented corpus chunk. See the corpus notes below.

## Corpus and plan notes

**Page reference.** Plan v8's Phase 19 says *"printed p.178"*. Lemma 5's statement **and** its
whole proof are on printed p.179; p.180 opens with Lemma 6. This continues the page-reference
drift recorded under Phase 18 (Lemmas 3-4 at pp.178-179, not p.177), and the docstrings below use
the pages the lemma is actually printed on.

**Corpus fidelity.** Unlike Lemmas 3 and 4, Lemma 5 contains **no displayed formula**, which is
where both previously-found §6 corpus defects sat (`ρ`'s missing middle conjunct, recorded under
Phase 17; Lemma 4's mangled display, recorded under Phase 18). Its inline text in
`~/Projects/Literature/sources/reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md`
checks out against the page image with one cosmetic difference: the corpus renders *"We get a
formula `φ'` of one free variable"* where the page prints *"We get a formula `φ(x)` of one free
variable"*. Plan v8 repeats the corpus' `φ'`. Nothing turns on it — both name the same
one-free-variable relativization — but the quotation above uses the printed form.

## What this module lands, and in what order

Reynolds' proof needs three things this tree did not have.

1. **A monadic image of a temporal formula.** *"Using expressive completeness and `ε`, find `B`
   which is true at points only if `A` occurs somewhere in their `∼`-class"* builds `B` from `A`'s
   **monadic** form. The tree lands the hard direction of §5 Theorem 3
   (`uSExpressivelyCompleteOverDensePrior`, monadic → temporal) but not the easy converse. It is
   landed here as `temporalAt` / `temporalToMonadic`, with the checked soundness theorem
   `eval_temporalAt`. The recursion is available only because `TemporalTruth`
   (`Table.lean:188`) reads `.box φ` off `M.interp (atomMap (.box φ))` — a monadic atom — so every
   clause of `TemporalTruth` is monadically expressible after all.

2. **Two reusable auxiliary-formula families**, in Phase 18's style (named monadic definition,
   named semantic reading, checked `..._eval`): `classBeginsWithFormula` (*"we are now in a class
   whose left hand end point is also in the class and at that point … holds"*) and `kMinusFormula`
   (`K⁻`, *"… accumulates from below"*). Reynolds' `C` is their composite,
   `classLeftEndKMinusTemporal`. `Lemma34.lean`'s `classBeginsAtGapStartFormula` is the same shape
   with `R ∧ K⁻(¬R)` in the payload slot; it is **not** refactored to go through these — nothing is
   removed or renamed — and the relationship is recorded at `classBeginsWithFormula`'s docstring.

3. **A bounded gap-crossing.** Phase 18's `false_of_holds_throughout_class` (`Lemma34.lean:595`)
   asks for the auxiliary formula to fail at **every** point outside the class with `R` throughout
   in between. Lemma 5's `C` does not satisfy that, and cannot: with classes `C₀ ⊨ ¬B`, `C₁ ⊨ B`,
   `C₂ ⊨ ¬B` in a row, `C₂`'s left end point does carry `K⁻(B)`, so `C` is true again at `C₂`.
   Reynolds says only *"false **afterwards**"*, and gets that from the preceding paragraph
   (*"for a while after this class `B` stays false"*). `false_of_holds_throughout_class_bounded`
   below is that reading: failure is required only below an explicit bound `b`. It is a genuine
   strengthening rather than a duplicate — the unbounded form does not imply it — and Phase 18's
   theorem is left in place and unweakened.

## Honest caveat, carried forward

Every §6 lemma below Lemma 2 remains **conditional**: `IsContempEquivDense ε` plus Reynolds'
Prior-U / Prior-S on `M` are hypotheses, and the only `ε` this tree can currently exhibit
satisfying them is the total relation `epsTop` (`Defs.lean:461`), for which `EndsInGapOnRight`
is empty (`not_endsInGapOnRight_epsTop`). So the results below are not discharged at any
non-trivial instance; the first live instance is due at the Lemma 9 / dense-surgery stage.

## References

- Reynolds 1992, §6 Lemma 5, printed p.179
- `Defs.lean` — `ρ`, `λ`, `EndsInGapOnRight`, `gapRightFormula`, Lemma 2
- `Lemma34.lean` — Lemmas 3 and 4, `false_of_holds_throughout_class`, `exists_contemp_gt`
- `SemanticPriorU` (`PriorDefsDense.lean:119`) — Reynolds' Prior-U, printed p.168
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! The structure class §6 is parameterized over, together with its dual-closure hypothesis; see
`IsContempEquivDenseOn` and `IsDualClosed` (`Defs.lean`, `Dual.lean`). `IsDualClosed` is carried at
file scope rather than per-declaration because the mirror halves of Lemmas 5-9 obtain their results
by running the unmirrored half at `dual M`, and every caller of those halves needs it too. At both
instantiations of `C` it is discharged by instance search, so no call site mentions it. -/
variable {C : OrderedMonadicStructure sig → Prop} [IsDualClosed C]

/-! ## A monadic image of a temporal formula

Reynolds uses expressive completeness in both directions in §6 without comment. The tree lands
only the hard direction. This section lands the easy one.

`temporalAt atomMap i A` is the monadic formula, at any arity, saying *"`A` holds at the point
named by De Bruijn index `i`"*. The `U` and `S` clauses are Reynolds' own truth conditions,
transcribed from `TemporalTruth` (`Table.lean:188`) one binder at a time; `.box φ` and `.atom a`
are monadic atoms, because `TemporalTruth` already reads both off `M.interp`. -/

/-- **`A` at De Bruijn index `i`**, as a monadic formula.

Index discipline: under `∃s` the former `i` is `i.succ` and `0` is `s`; under a further `∀r` the
former `i` is `i.succ.succ`, `1` is `s` and `0` is `r`. -/
def temporalAt (atomMap : Formula → sig.preds) :
    {n : Nat} → Fin n → Formula → MonadicFormula sig n
  | _, i, .atom a => .atom (atomMap (.atom a)) i
  | _, i, .bot => .and (.lt i i) (.not (.lt i i))
  | _, i, .imp φ ψ => .imp (temporalAt atomMap i φ) (temporalAt atomMap i ψ)
  | _, i, .box φ => .atom (atomMap (.box φ)) i
  | _, i, .untl ψ φ =>
      .ex (.and (.lt i.succ 0)
        (.and (temporalAt atomMap 0 φ)
          (.all (.imp (.and (.lt i.succ.succ 0) (.lt 0 1)) (temporalAt atomMap 0 ψ)))))
  | _, i, .snce ψ φ =>
      .ex (.and (.lt 0 i.succ)
        (.and (temporalAt atomMap 0 φ)
          (.all (.imp (.and (.lt 1 0) (.lt 0 i.succ.succ)) (temporalAt atomMap 0 ψ)))))

/-- Index `1` under two binders at arbitrary arity: the outer bound variable. `Defs.lean`'s
`cons3_one` is this lookup at the fixed arity its formulas use; `temporalAt` recurses through
every arity, so it needs the general form. -/
private theorem consCons_one {α : Type*} {n : Nat} (a b : α) (env : Fin n → α) :
    (Fin.cons a (Fin.cons b env) : Fin (n + 2) → α) 1 = b := rfl

/-- **The monadic image is correct**: `temporalAt atomMap i A` evaluates, at any environment, to
`A`'s temporal truth at the point the environment assigns to `i`.

Checked rather than asserted, exactly as `rhoFormula_eval` (`Defs.lean:340`) checks `ρ`. -/
@[simp] theorem eval_temporalAt (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) :
    ∀ (A : Formula) {n : Nat} (env : Fin n → M.carrier) (i : Fin n),
      eval M env (temporalAt atomMap i A) ↔ TemporalTruth M atomMap (env i) A := by
  intro A
  induction A with
  | atom a => intro n env i; simp [temporalAt, eval, TemporalTruth]
  | bot => intro n env i; simp [temporalAt, eval, TemporalTruth]
  | imp φ ψ ihφ ihψ =>
      intro n env i; simp only [temporalAt, eval_imp, ihφ, ihψ, TemporalTruth]
  | box φ => intro n env i; simp [temporalAt, eval, TemporalTruth]
  | untl ψ φ ihψ ihφ =>
      intro n env i
      simp only [temporalAt, eval, eval_imp, ihφ, ihψ, Fin.cons_zero, Fin.cons_succ,
        consCons_one, TemporalTruth, and_imp]
  | snce ψ φ ihψ ihφ =>
      intro n env i
      simp only [temporalAt, eval, eval_imp, ihφ, ihψ, Fin.cons_zero, Fin.cons_succ,
        consCons_one, TemporalTruth, and_imp]

/-- **`A` as a monadic formula of one free variable** — the `n = 1` case of `temporalAt`, which is
the shape every auxiliary formula below plugs into. -/
def temporalToMonadic (atomMap : Formula → sig.preds) (A : Formula) : MonadicFormula sig 1 :=
  temporalAt atomMap 0 A

/-- The one-free-variable image is correct. -/
@[simp] theorem eval_temporalToMonadic (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (A : Formula) (t : M.carrier) :
    eval M (fun _ => t) (temporalToMonadic atomMap A) ↔ TemporalTruth M atomMap t A :=
  eval_temporalAt M atomMap A (fun _ => t) 0

/-! ## A one-free-variable formula at an arbitrary variable

`rhoAt` (`Lemma34.lean:352`) is this operation specialized to `ρ`. `atVar` is the same
`MonadicFormula.rename` step for an arbitrary payload, which is what lets the auxiliary formulas
below be parametric in what they assert of the witness point. `rhoAt` is left in place. -/

/-- A one-free-variable monadic formula, with its free variable placed at index `i`. -/
def atVar {n : Nat} (α : MonadicFormula sig 1) (i : Fin n) : MonadicFormula sig n :=
  α.rename ![i]

/-- Evaluating a relocated formula is evaluating it at the relocated point. -/
@[simp] theorem eval_atVar {n : Nat} (M : OrderedMonadicStructure sig)
    (α : MonadicFormula sig 1) (env : Fin n → M.carrier) (i : Fin n) :
    eval M env (atVar α i) ↔ eval M (fun _ => env i) α := by
  unfold atVar
  rw [Kamp.eval_rename]
  have h : env ∘ ![i] = (fun _ : Fin 1 => env i) := by funext k; fin_cases k; rfl
  rw [h]

/-! ## Environment lookups

The auxiliary formulas below sit under up to three nested binders. These are the index lookups
`simp` needs to check each transcription against its intended meaning. -/

section EnvLookup

variable {α : Type*}

private theorem e2_one (x t : α) : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → α) 1 = t := rfl

private theorem e3_one (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) 1 = x := rfl

private theorem e3_two (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) 2 = t := rfl

end EnvLookup

/-! ## `K⁻`, as a formula family

*"at that point `K⁻(B)` holds"* (printed p.179). `K⁻(β)` at `x` is *"`β` accumulates from below at
`x`"*: below every earlier point there is a `β`-point still below `x`. This is the same reading
`Lemma34.lean` gives `K⁻(¬R)` inside `classBeginsAtGapStartFormula`, factored out. -/

/-- **`K⁻(β)`** — *"`β` holds arbitrarily soon before now"*, as a monadic formula.

De Bruijn layout: free variable `0` is `x`; under `∀v` the indices are `0 = v`, `1 = x`; under the
inner `∃r` they are `0 = r`, `1 = v`, `2 = x`. -/
def kMinusFormula (β : MonadicFormula sig 1) : MonadicFormula sig 1 :=
  .all (.imp (.lt 0 1) (.ex (.and (.lt 1 0) (.and (.lt 0 2) (atVar β 0)))))

/-- **What `K⁻` says.** -/
def KMinusAt (M : OrderedMonadicStructure sig) (P : M.carrier → Prop) (x : M.carrier) : Prop :=
  ∀ v : M.carrier, v < x → ∃ r : M.carrier, v < r ∧ r < x ∧ P r

/-- **The `K⁻` transcription is correct** — checked, not asserted. -/
theorem kMinusFormula_eval (M : OrderedMonadicStructure sig) (β : MonadicFormula sig 1)
    (x : M.carrier) :
    eval M (fun _ => x) (kMinusFormula β) ↔
      KMinusAt M (fun r => eval M (fun _ => r) β) x := by
  simp only [kMinusFormula, KMinusAt, eval, eval_imp, eval_atVar, Fin.cons_zero,
    e2_one, e3_one, e3_two]

/-! ## *"a class whose left hand end point is also in the class and at that point … holds"*

Reynolds' `C` (printed p.179) is this family with `K⁻(B)` in the payload slot. `Lemma34.lean`'s
`classBeginsAtGapStartFormula` — Lemma 3's `B` — is the same family with `R ∧ K⁻(¬R)` in the
payload slot; it is deliberately **not** rewritten to go through this definition, so that nothing
Phase 18 landed changes shape. -/

/-- **"We are now in a class whose left hand end point is also in the class, and `γ` holds at
it"**, as a monadic formula (printed p.179).

De Bruijn layout: free variable `0` is `x`; under `∃w` the indices are `0 = w`, `1 = x`; under the
inner `∀v` they are `0 = v`, `1 = w`, `2 = x`. As in `ClassBeginsAtGapStart`, *"is the left hand
end point"* is rendered by the negated `¬ v < w` rather than by `w ≤ v`. -/
def classBeginsWithFormula (ε : MonadicFormula sig 2) (γ : MonadicFormula sig 1) :
    MonadicFormula sig 1 :=
  .ex (.and (epsAt ε 1 0)
    (.and (.all (.imp (epsAt ε 2 0) (.not (.lt 0 1))))
      (atVar γ 0)))

/-- **What it says**: `t`'s class has a least element `w`, and `Q` holds at `w`. -/
def ClassBeginsWith (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier) : Prop :=
  ∃ w : M.carrier, ContempEquivDense M ε t w ∧
    (∀ v : M.carrier, ContempEquivDense M ε t v → ¬ v < w) ∧ Q w

/-- **The transcription is correct** — checked, not asserted. -/
theorem classBeginsWithFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (γ : MonadicFormula sig 1) (t : M.carrier) :
    eval M (fun _ => t) (classBeginsWithFormula ε γ) ↔
      ClassBeginsWith M ε (fun w => eval M (fun _ => w) γ) t := by
  simp only [classBeginsWithFormula, ClassBeginsWith, eval, eval_imp, eval_epsAt, eval_atVar,
    Fin.cons_zero, e2_one, e3_one, e3_two]

/-! ## The temporal formulas `B` and `C`

*"Using expressive completeness and `ε`, find `B` which is true at points only if `A` occurs
somewhere in their `∼`-class"* and *"Let `C` be the temporal formula saying that we are now in a
class whose left hand end point is also in the class and at that point `K⁻(B)` holds"* (printed
p.179). Both are applications of `uSExpressivelyCompleteOverDensePrior`, and both are produced
before any structure is supplied, so one formula serves every Prior structure. -/

/-- **"`A` occurs somewhere in my `∼`-class"**, as a monadic formula. -/
def holdsSomewhereInClassFormula (ε : MonadicFormula sig 2) (α : MonadicFormula sig 1) :
    MonadicFormula sig 1 :=
  .ex (.and (epsAt ε 1 0) (atVar α 0))

/-- **What it says.** -/
def HoldsSomewhereInClass (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (P : M.carrier → Prop) (t : M.carrier) : Prop :=
  ∃ w : M.carrier, ContempEquivDense M ε t w ∧ P w

/-- **The transcription is correct** — checked, not asserted. -/
theorem holdsSomewhereInClassFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (α : MonadicFormula sig 1) (t : M.carrier) :
    eval M (fun _ => t) (holdsSomewhereInClassFormula ε α) ↔
      HoldsSomewhereInClass M ε (fun w => eval M (fun _ => w) α) t := by
  simp only [holdsSomewhereInClassFormula, HoldsSomewhereInClass, eval, eval_epsAt, eval_atVar,
    Fin.cons_zero, e2_one]

/-- *"`A` occurs somewhere in their `∼`-class"* is a property of the class, which is the whole
point of building `B` this way. -/
theorem holdsSomewhereInClass_congr {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (P : M.carrier → Prop) {a c : M.carrier}
    (hac : ContempEquivDense M ε a c) :
    HoldsSomewhereInClass M ε P a ↔ HoldsSomewhereInClass M ε P c := by
  constructor
  · rintro ⟨w, haw, hw⟩
    exact ⟨w, (contemp_congr_left hε M hac).mp haw, hw⟩
  · rintro ⟨w, hcw, hw⟩
    exact ⟨w, (contemp_congr_left hε M hac).mpr hcw, hw⟩

section Temporal

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds' `B`** — *"`B` which is true at points only if `A` occurs somewhere in their
`∼`-class"* (printed p.179). -/
noncomputable def holdsSomewhereInClassTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (A : Formula) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (holdsSomewhereInClassFormula ε (temporalToMonadic atomMap A))).val

/-- **`B` holds exactly at points whose class contains an `A`-point**, in every Prior structure. -/
theorem holdsSomewhereInClassTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (A : Formula) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (holdsSomewhereInClassTemporal atomMap h_surj ε A) ↔
      HoldsSomewhereInClass M ε (fun w => TemporalTruth M atomMap w A) t := by
  refine ((uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (holdsSomewhereInClassFormula ε (temporalToMonadic atomMap A))).property
      M h_prior_U h_prior_S t).symm.trans ?_
  rw [holdsSomewhereInClassFormula_eval]
  simp only [eval_temporalToMonadic]

/-- **Reynolds' `C`** — *"the temporal formula saying that we are now in a class whose left hand
end point is also in the class and at that point `K⁻(B)` holds"* (printed p.179). -/
noncomputable def classLeftEndKMinusTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (B : Formula) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (classBeginsWithFormula ε (kMinusFormula (temporalToMonadic atomMap B)))).val

/-- **What `C` holds of**, in every Prior structure. -/
theorem classLeftEndKMinusTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (B : Formula) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (classLeftEndKMinusTemporal atomMap h_surj ε B) ↔
      ClassBeginsWith M ε
        (fun w => KMinusAt M (fun r => TemporalTruth M atomMap r B) w) t := by
  refine ((uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (classBeginsWithFormula ε (kMinusFormula (temporalToMonadic atomMap B)))).property
      M h_prior_U h_prior_S t).symm.trans ?_
  rw [classBeginsWithFormula_eval]
  simp only [kMinusFormula_eval, eval_temporalToMonadic]

end Temporal

/-! ## The bounded gap-crossing

Phase 18's `false_of_holds_throughout_class` (`Lemma34.lean:595`) isolates Reynolds' recurring
*"holds up to a gap and is false arbitrarily soon after the gap, contradicting Prior-U"* step, and
requires the auxiliary formula to fail at **every** point outside the class reachable with `R`
throughout. Reynolds' Lemma 5 supplies less: only *"false afterwards"*, on the stretch on which
the preceding paragraph has already shown `B` to stay false.

This is that weaker hypothesis. The proof is Phase 18's, with the explicit bound `b` doing the
work its `exists_gt_notContemp_holds` call did: `ρ(s)`'s third conjunct — *"there is no first point
after the class"* — already guarantees a point of `(s,b)` outside the class as soon as `b` itself
is outside it, so no appeal to Lemma 3 is needed and Prior-S drops out of the hypotheses. -/

/-- **The gap-crossing contradiction, bounded.**

`P` holds throughout `s`'s class, and fails at every point of `(s,b)` outside that class, where
`b` is itself outside the class. Prior-U forbids this.

This does **not** follow from `false_of_holds_throughout_class`, whose `hout` is strictly
stronger; both are kept. -/
theorem false_of_holds_throughout_class_bounded {atomMap : Formula → sig.preds}
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    {s : M.carrier} (hs : EndsInGapOnRight M ε s) (P : Formula)
    {b : M.carrier} (hsb : s < b) (hnb : ¬ ContempEquivDense M ε s b)
    (hin : ∀ r : M.carrier, ContempEquivDense M ε s r → TemporalTruth M atomMap r P)
    (hout : ∀ u : M.carrier, s < u → u < b → ¬ ContempEquivDense M ε s u →
      ¬ TemporalTruth M atomMap u P) : False := by
  -- *"there is no first point after the class"*: some point of `(s,b)` is already outside it.
  have hu₀ : ∃ u : M.carrier, s < u ∧ u < b ∧ ¬ ContempEquivDense M ε s u := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨b, hsb, hnb, fun y h₁ h₂ => hcon y h₁ h₂⟩
  obtain ⟨u₀, hsu₀, hu₀b, hnu₀⟩ := hu₀
  have hnP₀ : ¬ TemporalTruth M atomMap u₀ P := hout u₀ hsu₀ hu₀b hnu₀
  obtain ⟨y, hsy, hcy⟩ := exists_contemp_gt hε M hs
  have hstretch : ∃ c : M.carrier, s < c ∧ ∀ r : M.carrier, s < r → r < c →
      TemporalTruth M atomMap r P :=
    ⟨y, hsy, fun r h₁ h₂ => hin r (contemp_of_between hε M h₁.le h₂.le hcy)⟩
  obtain ⟨s₁, hss₁, hbelow, hcase⟩ := h_prior_U s P hstretch ⟨u₀, hsu₀, hnP₀⟩
  have hns₁ : ¬ ContempEquivDense M ε s s₁ := by
    intro hc
    rcases hcase with hn | ⟨_hb, hkplus⟩
    · exact hn (hin s₁ hc)
    · obtain ⟨y', hs₁y', hcy'⟩ :=
        exists_contemp_gt hε M ((endsInGapOnRight_congr hε M hc).mp hs)
      obtain ⟨r, hs₁r, hry', hnr⟩ := hkplus y' hs₁y'
      exact hnr (hin r (contemp_trans hε M hc (contemp_of_between hε M hs₁r.le hry'.le hcy')))
  have hex : ∃ r : M.carrier, s < r ∧ r < s₁ ∧ ¬ ContempEquivDense M ε s r := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨s₁, hss₁, hns₁, fun z h₁ h₂ => hcon z h₁ h₂⟩
  obtain ⟨r, hsr, hrs₁, hnr⟩ := hex
  rcases lt_or_ge u₀ s₁ with hlt | hge
  · exact hnP₀ (hbelow u₀ hsu₀ hlt)
  · exact hout r hsr (lt_trans (lt_of_lt_of_le hrs₁ hge) hu₀b) hnr (hbelow r hsr hrs₁)

/-! ## *"for a while after this class `B` stays false"*

*"Look at the gap at right hand end of this class. We can not have `B` arbitrarily soon after the
gap because of Prior-U. Thus for a while after this class `B` stays false."* (printed p.179)

Reynolds' *"we can not have `B` arbitrarily soon after the gap"* is Prior-U applied to `¬B` at
`s`: `¬B` already holds on an initial stretch above `s` (it holds throughout `s`'s class, and the
class has no last point), so the boundary point Prior-U returns must lie at or beyond the gap —
inside the class it would have to be a point where `¬B` fails, or one after which `B` accumulates,
and both are excluded by class-invariance. -/

/-- **`B` stays false for a while after `s`'s class.**

The bound `b` is beyond the class, and `B` is false throughout `(s,b)`. -/
theorem exists_bound_notHolds {atomMap : Formula → sig.preds}
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap) (B : Formula)
    (hinv : ∀ a c : M.carrier, ContempEquivDense M ε a c →
      (TemporalTruth M atomMap a B ↔ TemporalTruth M atomMap c B))
    {s : M.carrier} (hs : EndsInGapOnRight M ε s)
    (hnB : ¬ TemporalTruth M atomMap s B) :
    ∃ b : M.carrier, s < b ∧ ¬ ContempEquivDense M ε s b ∧
      ∀ q : M.carrier, s < q → q < b → ¬ TemporalTruth M atomMap q B := by
  by_cases hall : ∀ u : M.carrier, s < u → ¬ TemporalTruth M atomMap u B
  · obtain ⟨b, hsb, hnb⟩ := hs.1
    exact ⟨b, hsb, hnb, fun q h₁ _ => hall q h₁⟩
  · push_neg at hall
    obtain ⟨u, hsu, hBu⟩ := hall
    obtain ⟨y, hsy, hcy⟩ := exists_contemp_gt hε M hs
    obtain ⟨s₂, hss₂, hbelow, hcase⟩ := h_prior_U s (Formula.imp B Formula.bot)
      ⟨y, hsy, fun r h₁ h₂ hBr =>
        hnB ((hinv s r (contemp_of_between hε M h₁.le h₂.le hcy)).mpr hBr)⟩
      ⟨u, hsu, fun hn => hn hBu⟩
    have hns₂ : ¬ ContempEquivDense M ε s s₂ := by
      intro hc
      rcases hcase with hn | ⟨_hb, hkplus⟩
      · exact hn (fun hBs₂ => hnB ((hinv s s₂ hc).mpr hBs₂))
      · obtain ⟨y', hs₂y', hcy'⟩ :=
          exists_contemp_gt hε M ((endsInGapOnRight_congr hε M hc).mp hs)
        obtain ⟨r, hs₂r, hry', hnr⟩ := hkplus y' hs₂y'
        exact hnr (fun hBr => hnB ((hinv s r
          (contemp_trans hε M hc (contemp_of_between hε M hs₂r.le hry'.le hcy'))).mpr hBr))
    exact ⟨s₂, hss₂, hns₂, fun q h₁ h₂ => hbelow q h₁ h₂⟩

/-! ## Lemma 5, first statement

The whole of Reynolds' first proof paragraph, run on an arbitrary **class-invariant** temporal
formula. That is exactly what *"by using `¬B` instead if necessary"* needs: `B` and `¬B` are both
class-invariant, and the contradiction is symmetric in them. -/

section First

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 5, printed p.179 — the first proof paragraph.**

> *Choose a point `t` in this former class in which `B` holds. `B` holds in the whole of a class if
> it is true anywhere at all in the class so it continues for a while after `t`. By Prior-U there
> is either a last point where `B` holds after `t` (not possible as `B` must continue for a while)
> or a first point `s > t` where `¬B ∧ K⁻(B)` holds.*
>
> *So `s` must be the left hand end point of its `∼`-class. … Let `C` be the temporal formula
> saying that we are now in a class whose left hand end point is also in the class and at that
> point `K⁻(B)` holds. Now `C` is true in `s`'s class but false afterwards contradicting Prior-U.*

A class-invariant temporal formula cannot be true at one point and false at a later one with `R`
holding throughout in between. *"In the same maximal interval of `R`"* is rendered as `R`
throughout the closed segment `[t,t']`, which is what being in one maximal — hence convex —
`R`-interval amounts to for two of its points.

Reynolds' *"`¬B ∧ K⁻(B)`"* is `hnBs` together with `hkm` below; the tree's Prior-U
(`PriorDefsDense.lean:119`) returns the `¬B` half directly and the `K⁻` half is read off the
stretch it also returns, using `ρ` to supply the intermediate points. -/
theorem false_of_classInvariant_changes {atomMap : Formula → sig.preds}
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (B : Formula)
    (hinv : ∀ a c : M.carrier, ContempEquivDense M ε a c →
      (TemporalTruth M atomMap a B ↔ TemporalTruth M atomMap c B))
    {t t' : M.carrier} (htt' : t < t')
    (hIcc : ∀ q : M.carrier, t ≤ q → q ≤ t' → EndsInGapOnRight M ε q)
    (hB : TemporalTruth M atomMap t B) (hnB : ¬ TemporalTruth M atomMap t' B) : False := by
  have hRt : EndsInGapOnRight M ε t := hIcc t le_rfl htt'.le
  obtain ⟨y, hty, hcy⟩ := exists_contemp_gt hε M hRt
  -- *"it continues for a while after `t`"*, then Prior-U.
  obtain ⟨s, hts, hbelow, hcase⟩ := h_prior_U t B
    ⟨y, hty, fun r h₁ h₂ => (hinv t r (contemp_of_between hε M h₁.le h₂.le hcy)).mp hB⟩
    ⟨t', htt', hnB⟩
  have hst' : s ≤ t' := by
    by_contra hcon
    push_neg at hcon
    exact hnB (hbelow t' htt' hcon)
  have hRs : EndsInGapOnRight M ε s := hIcc s hts.le hst'
  -- *"not possible as `B` must continue for a while"*: the last-point case is excluded.
  have hnBs : ¬ TemporalTruth M atomMap s B := by
    rcases hcase with hn | ⟨hbs, hkplus⟩
    · exact hn
    · exfalso
      obtain ⟨y', hsy', hcy'⟩ := exists_contemp_gt hε M hRs
      obtain ⟨r, hsr, hry', hnr⟩ := hkplus y' hsy'
      exact hnr ((hinv s r (contemp_of_between hε M hsr.le hry'.le hcy')).mp hbs)
  -- *"So `s` must be the left hand end point of its `∼`-class."*
  have hmin : ∀ v : M.carrier, ContempEquivDense M ε s v → ¬ v < s := by
    intro v hsv hvs
    rcases le_or_gt v t with hvt | htv
    · have hvs' : ContempEquivDense M ε v s := contemp_symm hε M hsv
      have hvt' : ContempEquivDense M ε v t := contemp_of_between hε M hvt hts.le hvs'
      exact hnBs ((hinv t s (contemp_trans hε M (contemp_symm hε M hvt') hvs')).mp hB)
    · exact hnBs ((hinv v s (contemp_symm hε M hsv)).mp (hbelow v htv hvs))
  -- *"`K⁻(B)` holds"* at `s`: below any earlier point there is a `B`-point still below `s`.
  have hkm : KMinusAt M (fun r => TemporalTruth M atomMap r B) s := by
    intro v hvs
    have hv' : max v t < s := max_lt hvs hts
    have hRv' : EndsInGapOnRight M ε (max v t) :=
      hIcc _ (le_max_right v t) (le_trans hv'.le hst')
    obtain ⟨w, hvw, hcw⟩ := exists_contemp_gt hε M hRv'
    have hws : w < s := by
      by_contra hcon
      push_neg at hcon
      have hc : ContempEquivDense M ε (max v t) s :=
        contemp_of_between hε M hv'.le hcon hcw
      exact hmin (max v t) (contemp_symm hε M hc) hv'
    exact ⟨w, lt_of_le_of_lt (le_max_left v t) hvw, hws,
      hbelow w (lt_of_le_of_lt (le_max_right v t) hvw) hws⟩
  -- *"for a while after this class `B` stays false"*, then `C`.
  obtain ⟨b, hsb, hnb, hnBq⟩ := exists_bound_notHolds hε M h_prior_U B hinv hRs hnBs
  refine false_of_holds_throughout_class_bounded hε M h_prior_U hRs
    (classLeftEndKMinusTemporal atomMap h_surj ε B) hsb hnb ?_ ?_
  · -- *"`C` is true in `s`'s class"*
    intro r hsr
    rw [classLeftEndKMinusTemporal_spec atomMap h_surj ε B M h_prior_U h_prior_S r]
    exact ⟨s, contemp_symm hε M hsr, fun v hv => hmin v (contemp_trans hε M hsr hv), hkm⟩
  · -- *"but false afterwards"*
    intro u hsu hub hnsu hC
    rw [classLeftEndKMinusTemporal_spec atomMap h_surj ε B M h_prior_U h_prior_S u] at hC
    obtain ⟨w, huw, hwmin, hkw⟩ := hC
    have hwu : w ≤ u := not_lt.mp (hwmin u (contemp_refl hε M u))
    have hsw : s < w := by
      by_contra hcon
      push_neg at hcon
      have hwu' : ContempEquivDense M ε w u := contemp_symm hε M huw
      have hws : ContempEquivDense M ε w s := contemp_of_between hε M hcon hsu.le hwu'
      exact hnsu (contemp_trans hε M (contemp_symm hε M hws) hwu')
    obtain ⟨r, hsr, hrw, hBr⟩ := hkw s hsw
    exact hnBq r hsr (lt_of_lt_of_le hrw (le_trans hwu hub.le)) hBr

/-- **Reynolds 1992, §6 Lemma 5, printed p.179 — first statement.**

> *If a temporal formula holds somewhere in one `∼`-class in a maximal interval of `R`, then it
> holds somewhere in each `∼`-class in the interval.*

`B` is `holdsSomewhereInClassTemporal`, Reynolds' *"`B` which is true at points only if `A` occurs
somewhere in their `∼`-class"*; *"by using `¬B` instead if necessary"* is the `t' < t` branch. -/
theorem reynolds_lemma5_first {atomMap : Formula → sig.preds}
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (A : Formula) {t t' : M.carrier}
    (hIcc : ∀ q : M.carrier, min t t' ≤ q → q ≤ max t t' → EndsInGapOnRight M ε q)
    (hA : ∃ w : M.carrier, ContempEquivDense M ε t w ∧ TemporalTruth M atomMap w A) :
    ∃ w : M.carrier, ContempEquivDense M ε t' w ∧ TemporalTruth M atomMap w A := by
  by_contra hcon
  set B := holdsSomewhereInClassTemporal atomMap h_surj ε A with hBdef
  have hspec : ∀ x : M.carrier, TemporalTruth M atomMap x B ↔
      ∃ w : M.carrier, ContempEquivDense M ε x w ∧ TemporalTruth M atomMap w A := fun x =>
    holdsSomewhereInClassTemporal_spec atomMap h_surj ε A M h_prior_U h_prior_S x
  have hinv : ∀ a c : M.carrier, ContempEquivDense M ε a c →
      (TemporalTruth M atomMap a B ↔ TemporalTruth M atomMap c B) := by
    intro a c hac
    rw [hspec a, hspec c]
    exact holdsSomewhereInClass_congr hε M (fun w => TemporalTruth M atomMap w A) hac
  have hBt : TemporalTruth M atomMap t B := (hspec t).mpr hA
  have hnBt' : ¬ TemporalTruth M atomMap t' B := fun h => hcon ((hspec t').mp h)
  rcases lt_trichotomy t t' with h | h | h
  · refine false_of_classInvariant_changes h_surj hε M h_prior_U h_prior_S B hinv h ?_ hBt hnBt'
    intro q h₁ h₂
    exact hIcc q (by rwa [min_eq_left h.le]) (by rwa [max_eq_right h.le])
  · exact hnBt' (h ▸ hBt)
  · -- *"by using `¬B` instead if necessary"*
    have hinv' : ∀ a c : M.carrier, ContempEquivDense M ε a c →
        (TemporalTruth M atomMap a (Formula.imp B Formula.bot) ↔
          TemporalTruth M atomMap c (Formula.imp B Formula.bot)) := by
      intro a c hac
      constructor
      · exact fun hn hBc => hn ((hinv a c hac).mpr hBc)
      · exact fun hn hBa => hn ((hinv a c hac).mp hBa)
    refine false_of_classInvariant_changes h_surj hε M h_prior_U h_prior_S
      (Formula.imp B Formula.bot) hinv' h ?_ hnBt' (fun hn => hn hBt)
    intro q h₁ h₂
    exact hIcc q (by rwa [min_eq_right h.le]) (by rwa [max_eq_left h.le])

end First

/-! ## Lemma 5, second statement: relativization to a `∼`-class

*"Given a monadic sentence `φ`, we relativise it by restricting quantifiers to where `ε(x, −)`
holds. We get a formula `φ(x)` of one free variable. By expressive completeness this is equivalent
to a temporal formula. This is true exactly throughout `∼`-classes which model `φ`. Then, by the
first part of the lemma, it can't be true somewhere and false elsewhere in the interval."*
(printed p.179)

**Rendering of "taken as substructures of `M`".** A `∼`-class is convex but need not be an
interval with end points in `M` — Lemma 3 is precisely the statement that maximal `R`-intervals
have *excluded* end points, and by `ρ` the classes inside them end in gaps. So `M.subinterval`
(`MonadicFO.lean:215`), which needs two carrier points, cannot name a class. The induced
substructure is therefore named the standard equivalent way, by **relativized satisfaction**:
`evalOn M S` is `eval` with every quantifier restricted to `S`, and *"the class of `t` models
`φ`"* is `evalOn` at `S = ContempEquivDense M ε t`. Reynolds' relativization step is then exactly
the syntactic counterpart, `relativizeToClass`, and `eval_relativizeAt` is the theorem that the
two agree. -/

/-- **Satisfaction relativized to a subset `S` of the carrier** — `eval` (`MonadicFO.lean:306`)
with both quantifiers restricted to `S`. This is the induced substructure's satisfaction relation,
named without having to build the substructure. -/
def evalOn (M : OrderedMonadicStructure sig) (S : M.carrier → Prop) :
    {n : Nat} → (Fin n → M.carrier) → MonadicFormula sig n → Prop
  | _, env, .atom p i => M.interp p (env i)
  | _, env, .lt i j => env i < env j
  | _, env, .not α => ¬ evalOn M S env α
  | _, env, .and α β => evalOn M S env α ∧ evalOn M S env β
  | _, env, .all α => ∀ y : M.carrier, S y → evalOn M S (Fin.cons y env) α
  | _, env, .ex α => ∃ y : M.carrier, S y ∧ evalOn M S (Fin.cons y env) α

/-- **Reynolds' relativization** — *"we relativise it by restricting quantifiers to where
`ε(x, −)` holds"* (printed p.179), at arbitrary arity.

One fresh free variable is appended at index `Fin.last n`: that is Reynolds' `x`, the point whose
class the quantifiers are restricted to. Every pre-existing free variable keeps its index, via
`Fin.castSucc`.

Landed at arbitrary arity, not only for sentences, because the induction that verifies it has to
pass through subformulas with free variables — and because Lemma 12 needs the same operator
applied to a two-variable `γ(z,t)`. -/
def relativizeAt (ε : MonadicFormula sig 2) :
    {n : Nat} → MonadicFormula sig n → MonadicFormula sig (n + 1)
  | _, .atom p i => .atom p i.castSucc
  | _, .lt i j => .lt i.castSucc j.castSucc
  | _, .not α => .not (relativizeAt ε α)
  | _, .and α β => .and (relativizeAt ε α) (relativizeAt ε β)
  | n, .all α => .all (.imp (epsAt ε (Fin.last (n + 1)) 0) (relativizeAt ε α))
  | n, .ex α => .ex (.and (epsAt ε (Fin.last (n + 1)) 0) (relativizeAt ε α))

/-- **`φ'`, the one-free-variable relativization of a monadic sentence `φ`** — *"We get a formula
`φ(x)` of one free variable"* (printed p.179). This is the `n = 0` case of `relativizeAt`. -/
def relativizeToClass (ε : MonadicFormula sig 2) (φ : MonadicFormula sig 0) :
    MonadicFormula sig 1 :=
  relativizeAt ε φ

section Relativize

variable {α : Type*}

private theorem consSnoc_last {n : Nat} (y x : α) (env : Fin n → α) :
    (Fin.cons y (Fin.snoc env x) : Fin (n + 2) → α) (Fin.last (n + 1)) = x := by
  rw [← Fin.succ_last, Fin.cons_succ, Fin.snoc_last]

private theorem snoc_elim0 (x : α) : (Fin.snoc (Fin.elim0) x : Fin 1 → α) = fun _ => x := by
  funext k
  rfl

end Relativize

/-- **The relativization is correct**: evaluating `relativizeAt ε φ` with `x` in the fresh slot is
evaluating `φ` in the substructure carried by `x`'s `∼`-class. Checked, not asserted. -/
theorem eval_relativizeAt (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (x : M.carrier) :
    ∀ {n : Nat} (φ : MonadicFormula sig n) (env : Fin n → M.carrier),
      eval M (Fin.snoc env x) (relativizeAt ε φ) ↔
        evalOn M (ContempEquivDense M ε x) env φ := by
  intro n φ
  induction φ with
  | atom p i => intro env; simp [relativizeAt, eval, evalOn, Fin.snoc_castSucc]
  | lt i j => intro env; simp [relativizeAt, eval, evalOn, Fin.snoc_castSucc]
  | not α ih => intro env; simp only [relativizeAt, eval, evalOn, ih]
  | and α β ihα ihβ => intro env; simp only [relativizeAt, eval, evalOn, ihα, ihβ]
  | all α ih =>
      intro env
      simp only [relativizeAt, eval, eval_imp, evalOn, eval_epsAt, consSnoc_last, Fin.cons_zero]
      refine forall_congr' fun y => ?_
      rw [Fin.cons_snoc_eq_snoc_cons, ih (Fin.cons y env)]
  | ex α ih =>
      intro env
      simp only [relativizeAt, eval, evalOn, eval_epsAt, consSnoc_last, Fin.cons_zero]
      refine exists_congr fun y => ?_
      rw [Fin.cons_snoc_eq_snoc_cons, ih (Fin.cons y env)]

/-- **"The `∼`-class of `t` models the monadic sentence `φ`"**, as relativized satisfaction. -/
def ClassModels (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) (φ : MonadicFormula sig 0) : Prop :=
  evalOn M (ContempEquivDense M ε t) Fin.elim0 φ

/-- Modelling `φ` is a property of the class, not of the point — the classes of two class-mates are
the same set, so the relativized satisfaction relations coincide. -/
theorem classModels_congr {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] {a c : M.carrier} (hac : ContempEquivDense M ε a c)
    (φ : MonadicFormula sig 0) : ClassModels M ε a φ ↔ ClassModels M ε c φ := by
  have h : ContempEquivDense M ε a = ContempEquivDense M ε c := by
    funext z
    exact propext (contemp_congr_left hε M hac)
  unfold ClassModels
  rw [h]

/-- **`relativizeToClass` is correct**: `φ'` holds at `t` exactly when `t`'s class models `φ`. -/
theorem eval_relativizeToClass (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (φ : MonadicFormula sig 0) (t : M.carrier) :
    eval M (fun _ => t) (relativizeToClass ε φ) ↔ ClassModels M ε t φ := by
  have h := eval_relativizeAt M ε t φ Fin.elim0
  rwa [snoc_elim0] at h

section Second

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds' `φ'` as a temporal formula** — *"By expressive completeness this is equivalent to a
temporal formula"* (printed p.179). -/
noncomputable def classModelsTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (φ : MonadicFormula sig 0) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (relativizeToClass ε φ)).val

/-- *"This is true exactly throughout `∼`-classes which model `φ`."* (printed p.179) -/
theorem classModelsTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (φ : MonadicFormula sig 0) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (classModelsTemporal atomMap h_surj ε φ) ↔ ClassModels M ε t φ :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (relativizeToClass ε φ)).property M h_prior_U h_prior_S t).symm.trans
      (eval_relativizeToClass M ε φ t)

/-- **Reynolds 1992, §6 Lemma 5, printed p.179 — second statement.**

> *Furthermore, each pair of the `∼`-classes in a maximal interval of `R` are elementarily
> equivalent (taken as substructures of `M`).*

*"Elementarily equivalent taken as substructures of `M`"* is: they satisfy the same monadic
sentences under relativized satisfaction (see the section header for why the substructures are
named this way rather than through `M.subinterval`).

*"Then, by the first part of the lemma, it can't be true somewhere and false elsewhere in the
interval"* is the appeal to `reynolds_lemma5_first` below, applied to the temporal equivalent of
`φ'`; class-invariance of `ClassModels` is what turns *"holds somewhere in the class"* back into
*"holds throughout the class"*. -/
theorem reynolds_lemma5_second {atomMap : Formula → sig.preds}
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (φ : MonadicFormula sig 0) {t t' : M.carrier}
    (hIcc : ∀ q : M.carrier, min t t' ≤ q → q ≤ max t t' → EndsInGapOnRight M ε q) :
    ClassModels M ε t φ ↔ ClassModels M ε t' φ := by
  have key : ∀ a c : M.carrier,
      (∀ q : M.carrier, min a c ≤ q → q ≤ max a c → EndsInGapOnRight M ε q) →
      ClassModels M ε a φ → ClassModels M ε c φ := by
    intro a c hac hφ
    obtain ⟨w, hcw, hw⟩ :=
      reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S
        (classModelsTemporal atomMap h_surj ε φ) hac
        ⟨a, contemp_refl hε M a,
          (classModelsTemporal_spec atomMap h_surj ε φ M h_prior_U h_prior_S a).mpr hφ⟩
    exact (classModels_congr hε M hcw φ).mpr
      ((classModelsTemporal_spec atomMap h_surj ε φ M h_prior_U h_prior_S w).mp hw)
  refine ⟨key t t' hIcc, key t' t ?_⟩
  intro q h₁ h₂
  exact hIcc q (by rwa [min_comm]) (by rwa [max_comm])

/-- **Reynolds 1992, §6 Lemma 5, printed p.179**, both statements. -/
theorem reynolds_lemma5 {atomMap : Formula → sig.preds}
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t t' : M.carrier}
    (hIcc : ∀ q : M.carrier, min t t' ≤ q → q ≤ max t t' → EndsInGapOnRight M ε q) :
    (∀ A : Formula, (∃ w : M.carrier, ContempEquivDense M ε t w ∧
        TemporalTruth M atomMap w A) →
      ∃ w : M.carrier, ContempEquivDense M ε t' w ∧ TemporalTruth M atomMap w A) ∧
    (∀ φ : MonadicFormula sig 0, ClassModels M ε t φ ↔ ClassModels M ε t' φ) :=
  ⟨fun A hA => reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S A hIcc hA,
    fun φ => reynolds_lemma5_second h_surj hε M h_prior_U h_prior_S φ hIcc⟩

end Second

/-! ## Lemma 5 over maximal intervals of `λ`

Reynolds states Lemma 5 over maximal intervals of `R` only, and prints no dual. The `λ`-side
statement below is therefore **unstated by Reynolds**: it is licensed by the duality convention
he sets at printed **p.178** — *"Dually we can define `λ(x)` about left ends."* — and it is
required by the appeal to *"previous results"* in Lemma 6's closing sentence at printed **p.180**
(*"using mirror images of the above and previous results we get our proof"*). It is not
attributed to the source as a printed statement, because it is not one.

It is obtained by **instantiation**, not by a second proof: `reynolds_lemma5_first` at
`(dual M, dualize ε)`, rewritten through `Dual.lean`'s transport lemmas. That is what makes it
a formalization of Reynolds' sentence rather than of a proof he did not write.

The standing §6 caveat applies unchanged: this result, like everything in §6 below Lemma 2, is
**conditional** on `IsContempEquivDense ε` together with Prior-U/Prior-S, and has no live
non-trivial instance yet. -/

section FirstLeft

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 5, printed p.179 — the first statement over maximal intervals of
`λ` rather than of `R`.**

> *If a temporal formula holds somewhere in one `∼`-class in a maximal interval of `R`, then it
> holds somewhere in each `∼`-class in the interval.*

with `R` replaced by `L` throughout. **Reynolds prints no such statement**; see the section
header for what licenses it and for why it is not attributed to him.

Proved by instantiating `reynolds_lemma5_first` at `(dual M, dualize ε)` and at `swapUS A`. -/
theorem reynolds_lemma5_first_left {atomMap : Formula → sig.preds}
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDenseOn ε C)
    (M : OrderedMonadicStructure sig) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (A : Formula) {t t' : M.carrier}
    (hIcc : ∀ q : M.carrier, min t t' ≤ q → q ≤ max t t' → EndsInGapOnLeft M ε q)
    (hA : ∃ w : M.carrier, ContempEquivDense M ε t w ∧ TemporalTruth M atomMap w A) :
    ∃ w : M.carrier, ContempEquivDense M ε t' w ∧ TemporalTruth M atomMap w A := by
  -- The `R`-side statement, at the dual structure and the dualized `ε`.
  have hIcc' : ∀ q : (dual M).carrier,
      min (d t) (d t') ≤ q → q ≤ max (d t) (d t') → EndsInGapOnRight (dual M) (dualize ε) q := by
    intro q h₁ h₂
    exact (endsInGapOnRight_dual (M := M) ε q).mpr (hIcc q h₂ h₁)
  have hA' : ∃ w : (dual M).carrier,
      ContempEquivDense (dual M) (dualize ε) (d t) w ∧
        TemporalTruth (dual M) atomMap w (swapUS A) := by
    obtain ⟨w, hcw, hAw⟩ := hA
    exact ⟨d w, (contempEquivDense_dual (M := M) ε t w).mpr hcw,
      (temporalTruth_dual' (M := M) atomMap w A).mpr hAw⟩
  obtain ⟨w, hcw, hAw⟩ :=
    reynolds_lemma5_first h_surj (isContempEquivDense_dualize hε) (dual M)
      (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U) (swapUS A) hIcc' hA'
  exact ⟨w, (contempEquivDense_dual (M := M) ε t' w).mp hcw, (temporalTruth_dual' (M := M) atomMap w A).mp hAw⟩

end FirstLeft

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
