/-
Spike evidence for the `filteredStep_fwd` go/no-go question.

Three result clusters, all machine-checked and free of `sorry`:

1. THE Z-EXACT ONE-STEP UNFOLDING OF `untl` IS A DERIVABLE THEOREM SCHEMA AT
   `FrameClass.Discrete` -- in both the `X (g /\ U(e,g))` shape (`unfoldForward` /
   `unfoldBackward`) and the shape used by the handoff's `filteredStep` table,
   `X g /\ X U(e,g)` (`unfoldTableForward` / `unfoldTableBackward`).  No new axiom is
   required: `succIndicator` derives the discreteness indicator `U(top, bot)` from
   `Axiom.serial_future` + `Axiom.prior_UZ` + guard monotonicity.

2. `filteredStep_fwd` IS REFUTED for the repository's *existing* `ClosureMCS` layer, which
   hard-wires `fc := FrameClass.Base` (`RestrictedMCS/Basic.lean:72,80`).  The obstruction is
   exactly the frame-class mismatch: `U(top, bot)` is a theorem at `Discrete` but not at
   `Base` -- `Axiom.dense_indicator` is its negation, so a base derivation would collapse the
   dense system.  See `filteredStep_fwd_fails`.

3. The relation defined here is NOT the universal relation (`filteredStep_not_universal`),
   i.e. the Phase 7 defect recorded in `phase7-filtered-frame-is-universal.lean` is not
   repeated, and `noBlockingTriple` shows the schema does real work at `Discrete`.

Argument order is event-first / guard-second throughout, per
`specs/decisions/untl-snce-argument-order.md`.

Compile with: `lake env lean <this file>`.
-/
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Decidability.FMP.Filtration

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Propositional
open FormalSystem.Metalogic.Decidability.FMP
open FormalSystem.Semantics

namespace Spike417

noncomputable section

/-- `X ψ`, the next-operator, in the primitive vocabulary: `U(ψ, ⊥)`.
Event-first / guard-second (`specs/decisions/untl-snce-argument-order.md`): the event `ψ`
is witnessed at the first strictly-future point, and the guard `⊥` forces the open interval
strictly between to be empty, i.e. the witness is the immediate successor. -/
def nxt (ψ : Formula) : Formula := Formula.untl ψ Formula.bot

/-! ## Frame-class-polymorphic Hilbert plumbing -/

/-- Temporal necessitation, usable under a context. -/
def necG {fc : FrameClass} (Γ : Context) (A : Formula) (h : ⊢[fc] A) :
    Γ ⊢[fc] A.allFuture :=
  DerivationTree.weakening [] Γ _ (DerivationTree.temporal_necessitation A h) (by simp)

/-- Weaken a theorem into any context. -/
def wk {fc : FrameClass} (Γ : Context) (A : Formula) (h : ⊢[fc] A) : Γ ⊢[fc] A :=
  DerivationTree.weakening [] Γ A h (by simp)

/-- `⊤` is a theorem. -/
def topThm {fc : FrameClass} : ⊢[fc] Formula.top := efqAxiom Formula.bot

/-- Conjunction introduction. -/
def andIntro {fc : FrameClass} (Γ : Context) (A B : Formula)
    (hA : Γ ⊢[fc] A) (hB : Γ ⊢[fc] B) : Γ ⊢[fc] A.and B := by
  have step : ((A.imp B.neg) :: Γ) ⊢[fc] Formula.bot := by
    have h1 : ((A.imp B.neg) :: Γ) ⊢[fc] A.imp B.neg :=
      DerivationTree.assumption _ _ (by simp)
    have h2 : ((A.imp B.neg) :: Γ) ⊢[fc] A :=
      DerivationTree.weakening Γ _ A hA (by intro x hx; simp [hx])
    have h3 : ((A.imp B.neg) :: Γ) ⊢[fc] B :=
      DerivationTree.weakening Γ _ B hB (by intro x hx; simp [hx])
    exact DerivationTree.modus_ponens _ B Formula.bot
      (DerivationTree.modus_ponens _ A B.neg h1 h2) h3
  exact deductionTheorem Γ (A.imp B.neg) Formula.bot step

/-- Disjunction introduction (left). -/
def orIntroL {fc : FrameClass} (Γ : Context) (A B : Formula) (hA : Γ ⊢[fc] A) :
    Γ ⊢[fc] A.or B := by
  have step : (A.neg :: Γ) ⊢[fc] B := by
    have h1 : (A.neg :: Γ) ⊢[fc] A.neg := DerivationTree.assumption _ _ (by simp)
    have h2 : (A.neg :: Γ) ⊢[fc] A :=
      DerivationTree.weakening Γ _ A hA (by intro x hx; simp [hx])
    exact DerivationTree.modus_ponens _ Formula.bot B (wk _ _ (efqAxiom B))
      (DerivationTree.modus_ponens _ A Formula.bot h1 h2)
  exact deductionTheorem Γ A.neg B step

/-- Disjunction introduction (right). -/
def orIntroR {fc : FrameClass} (Γ : Context) (A B : Formula) (hB : Γ ⊢[fc] B) :
    Γ ⊢[fc] A.or B :=
  deductionTheorem Γ A.neg B (DerivationTree.weakening Γ _ B hB (by intro x hx; simp [hx]))

/-- Classical disjunction elimination, via Peirce. -/
def orElim {fc : FrameClass} (Γ : Context) (A B C : Formula)
    (hor : Γ ⊢[fc] A.or B) (hA : Γ ⊢[fc] A.imp C) (hB : Γ ⊢[fc] B.imp C) :
    Γ ⊢[fc] C := by
  have step : (C.neg :: Γ) ⊢[fc] C := by
    have hnc : (C.neg :: Γ) ⊢[fc] C.neg := DerivationTree.assumption _ _ (by simp)
    have hA' : (C.neg :: Γ) ⊢[fc] A.imp C :=
      DerivationTree.weakening Γ _ _ hA (by intro x hx; simp [hx])
    have hB' : (C.neg :: Γ) ⊢[fc] B.imp C :=
      DerivationTree.weakening Γ _ _ hB (by intro x hx; simp [hx])
    have hor' : (C.neg :: Γ) ⊢[fc] A.neg.imp B :=
      DerivationTree.weakening Γ _ _ hor (by intro x hx; simp [hx])
    -- `A.neg` : from `A` we would get `C`, contradicting `C.neg`
    have hna : (C.neg :: Γ) ⊢[fc] A.neg := by
      refine deductionTheorem _ A Formula.bot ?_
      have hnc2 : (A :: C.neg :: Γ) ⊢[fc] C.neg :=
        DerivationTree.assumption _ _ (by simp)
      have ha2 : (A :: C.neg :: Γ) ⊢[fc] A := DerivationTree.assumption _ _ (by simp)
      have hA2 : (A :: C.neg :: Γ) ⊢[fc] A.imp C :=
        DerivationTree.weakening _ _ _ hA' (by intro x hx; simp [hx])
      exact DerivationTree.modus_ponens _ C Formula.bot hnc2
        (DerivationTree.modus_ponens _ A C hA2 ha2)
    exact DerivationTree.modus_ponens _ B C hB'
      (DerivationTree.modus_ponens _ A.neg B hor' hna)
  exact DerivationTree.modus_ponens Γ (C.neg.imp C) C
    (wk Γ _ (peirceAxiom C Formula.bot)) (deductionTheorem Γ C.neg C step)

/-- Guard monotonicity (BX2G, `Axiom.left_mono_until_G`) in usable form. -/
def guardMono {fc : FrameClass} (Γ : Context) (e g g' : Formula)
    (hg : ⊢[fc] g.imp g') (h : Γ ⊢[fc] Formula.untl e g) : Γ ⊢[fc] Formula.untl e g' :=
  DerivationTree.modus_ponens Γ (Formula.untl e g) (Formula.untl e g')
    (DerivationTree.modus_ponens Γ (g.imp g').allFuture _
      (DerivationTree.axiom Γ _ (Axiom.left_mono_until_G g g' e) (FrameClass.base_le fc))
      (necG Γ _ hg))
    h

/-- Event monotonicity (BX3, `Axiom.right_mono_until`) in usable form. -/
def eventMono {fc : FrameClass} (Γ : Context) (e e' g : Formula)
    (he : ⊢[fc] e.imp e') (h : Γ ⊢[fc] Formula.untl e g) : Γ ⊢[fc] Formula.untl e' g :=
  DerivationTree.modus_ponens Γ (Formula.untl e g) (Formula.untl e' g)
    (DerivationTree.modus_ponens Γ (e.imp e').allFuture _
      (DerivationTree.axiom Γ _ (Axiom.right_mono_until e e' g) (FrameClass.base_le fc))
      (necG Γ _ he))
    h

/-! ## Two small theorems of the base system -/

/-- `¬⊤ → ⊥`. -/
def topNegImpBot {fc : FrameClass} : ⊢[fc] Formula.top.neg.imp Formula.bot := by
  refine deductionTheorem [] Formula.top.neg Formula.bot ?_
  exact DerivationTree.modus_ponens _ Formula.top Formula.bot
    (DerivationTree.assumption _ _ (by simp [Formula.neg])) (wk _ _ topThm)

/-- `¬U(⊥, X)`: an `untl` with a refutable event is refutable.
Route: `Axiom.until_F` to `F ⊥`, event monotonicity to `F ¬¬⊥`, and temporal
necessitation of `¬⊥`, whose `allFuture` unfolds to exactly `¬F ¬¬⊥`. -/
def untlBotFalse {fc : FrameClass} (X : Formula) :
    ⊢[fc] (Formula.untl Formula.bot X).imp Formula.bot := by
  refine deductionTheorem [] (Formula.untl Formula.bot X) Formula.bot ?_
  have h1 : [Formula.untl Formula.bot X] ⊢[fc] Formula.untl Formula.bot X :=
    DerivationTree.assumption _ _ (by simp)
  have h2 : [Formula.untl Formula.bot X] ⊢[fc] Formula.someFuture Formula.bot :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.until_F X Formula.bot) (FrameClass.base_le fc)) h1
  have h3 : [Formula.untl Formula.bot X] ⊢[fc] Formula.someFuture Formula.bot.neg.neg :=
    eventMono _ Formula.bot Formula.bot.neg.neg Formula.top (efqAxiom _) h2
  have h4 : [Formula.untl Formula.bot X] ⊢[fc] Formula.allFuture Formula.bot.neg :=
    wk _ _ (DerivationTree.temporal_necessitation _ (efqAxiom Formula.bot))
  exact DerivationTree.modus_ponens _ _ _ h4 h3

/-! ## Result 1: the discreteness indicator is a theorem at `FrameClass.Discrete`

`U(⊤,⊥)` says "the current point has an immediate successor".  It is asserted by no axiom
of this tree (its *negation* is `Axiom.dense_indicator`, at `FrameClass.Dense`).  It is
nonetheless *derivable* at `FrameClass.Discrete`, from `Axiom.serial_future`,
`Axiom.prior_UZ` at `⊤`, and guard monotonicity. -/

/-- **`⊢[Discrete] U(⊤, ⊥)`.** -/
def succIndicator : ⊢[FrameClass.Discrete] nxt Formula.top := by
  have h1 : ⊢[FrameClass.Discrete] Formula.someFuture Formula.top :=
    DerivationTree.modus_ponens _ Formula.top _
      (DerivationTree.axiom _ _ Axiom.serial_future (by decide)) topThm
  have h2 : ⊢[FrameClass.Discrete] Formula.untl Formula.top Formula.top.neg :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.prior_UZ Formula.top) (by decide)) h1
  exact guardMono [] Formula.top Formula.top.neg Formula.bot topNegImpBot h2

/-! ## Result 2: the Z-exact one-step unfolding schema

```
U(e, g)   <->   X e  \/  X (g /\ U(e, g))
```

with `X ψ := U(ψ, ⊥)`.  Forward at `Discrete` (it needs `succIndicator`); backward already
at `Base`. -/

/-- Forward half of the unfolding.  Engine: `Axiom.self_accum_until` enriches the guard with
the eventuality itself, then `Axiom.linear_until` compares that `untl` against `U(⊤,⊥)`,
and the middle disjunct is killed by `untlBotFalse`. -/
def unfoldForward (e g : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.untl e g).imp ((nxt e).or (nxt (Formula.and g (Formula.untl e g)))) := by
  set G' := Formula.and g (Formula.untl e g) with hG'
  set C := (nxt e).or (nxt G') with hC
  set Γ : Context := [Formula.untl e g] with hΓ
  refine deductionTheorem [] (Formula.untl e g) C ?_
  have h1 : Γ ⊢[FrameClass.Discrete] Formula.untl e g :=
    DerivationTree.assumption _ _ (by simp [hΓ])
  have h2 : Γ ⊢[FrameClass.Discrete] Formula.untl e G' :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.self_accum_until g e) (FrameClass.base_le _)) h1
  have h3 : Γ ⊢[FrameClass.Discrete] Formula.untl Formula.top Formula.bot :=
    wk _ _ succIndicator
  have h4 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl e G').and (Formula.untl Formula.top Formula.bot) := andIntro _ _ _ h2 h3
  have h5 : Γ ⊢[FrameClass.Discrete]
      ((Formula.untl (Formula.and e Formula.top) (Formula.and G' Formula.bot)).or
        (Formula.untl (Formula.and e Formula.bot) (Formula.and G' Formula.bot))).or
        (Formula.untl (Formula.and G' Formula.top) (Formula.and G' Formula.bot)) :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.linear_until G' e Formula.bot Formula.top) (FrameClass.base_le _)) h4
  -- Disjunct 1: `U(e ∧ ⊤, G' ∧ ⊥)` collapses to `X e`.
  have d1 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl (Formula.and e Formula.top) (Formula.and G' Formula.bot)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and e Formula.top) (Formula.and G' Formula.bot)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete)
      (Formula.untl (Formula.and e Formula.top) (Formula.and G' Formula.bot) :: Γ)
      (Formula.untl (Formula.and e Formula.top) (Formula.and G' Formula.bot)) (by simp)
    have a2 := guardMono _ (Formula.and e Formula.top) (Formula.and G' Formula.bot)
      Formula.bot (rceImp G' Formula.bot) a1
    have a3 := eventMono _ (Formula.and e Formula.top) e Formula.bot
      (lceImp e Formula.top) a2
    exact orIntroL _ _ _ a3
  -- Disjunct 2: `U(e ∧ ⊥, _)` has a refutable event.
  have d2 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl (Formula.and e Formula.bot) (Formula.and G' Formula.bot)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and e Formula.bot) (Formula.and G' Formula.bot)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete)
      (Formula.untl (Formula.and e Formula.bot) (Formula.and G' Formula.bot) :: Γ)
      (Formula.untl (Formula.and e Formula.bot) (Formula.and G' Formula.bot)) (by simp)
    have a2 := eventMono _ (Formula.and e Formula.bot) Formula.bot
      (Formula.and G' Formula.bot) (rceImp e Formula.bot) a1
    have a3 : _ ⊢[FrameClass.Discrete] Formula.bot :=
      DerivationTree.modus_ponens _ _ _ (wk _ _ (untlBotFalse _)) a2
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (efqAxiom C)) a3
  -- Disjunct 3: `U(G' ∧ ⊤, G' ∧ ⊥)` collapses to `X G'`.
  have d3 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl (Formula.and G' Formula.top) (Formula.and G' Formula.bot)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.top) (Formula.and G' Formula.bot)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete)
      (Formula.untl (Formula.and G' Formula.top) (Formula.and G' Formula.bot) :: Γ)
      (Formula.untl (Formula.and G' Formula.top) (Formula.and G' Formula.bot)) (by simp)
    have a2 := guardMono _ (Formula.and G' Formula.top) (Formula.and G' Formula.bot)
      Formula.bot (rceImp G' Formula.bot) a1
    have a3 := eventMono _ (Formula.and G' Formula.top) G' Formula.bot
      (lceImp G' Formula.top) a2
    exact orIntroR _ _ _ a3
  refine orElim Γ _ _ C h5 ?_ d3
  exact deductionTheorem _ _ _ (orElim _ _ _ C (DerivationTree.assumption _ _ (by simp))
    (DerivationTree.weakening _ _ _ d1 (by intro x hx; simp [hx]))
    (DerivationTree.weakening _ _ _ d2 (by intro x hx; simp [hx])))

/-- Backward half of the unfolding — already derivable at `FrameClass.Base`.
Engine: guard weakening `⊥ → g`, then `Axiom.absorb_until`. -/
def unfoldBackward (e g : Formula) :
    ⊢[FrameClass.Base]
      ((nxt e).or (nxt (Formula.and g (Formula.untl e g)))).imp (Formula.untl e g) := by
  set G' := Formula.and g (Formula.untl e g) with hG'
  set A := (nxt e).or (nxt G') with hA
  set Δ : Context := [A] with hΔ
  refine deductionTheorem [] A (Formula.untl e g) ?_
  refine orElim Δ (nxt e) (nxt G') (Formula.untl e g)
    (DerivationTree.assumption Δ A (by simp [hΔ])) ?_ ?_
  · refine deductionTheorem Δ (nxt e) (Formula.untl e g) ?_
    exact guardMono (nxt e :: Δ) e Formula.bot g (efqAxiom g)
      (DerivationTree.assumption (nxt e :: Δ) (nxt e) (by simp))
  · refine deductionTheorem Δ (nxt G') (Formula.untl e g) ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Base) (nxt G' :: Δ) (nxt G') (by simp)
    have a2 := guardMono (nxt G' :: Δ) G' Formula.bot g (efqAxiom g) a1
    exact DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.absorb_until g e) (FrameClass.base_le _)) a2

/-! ### `X` distributes over conjunction (Base)

Needed to move between the schema's `X (g ∧ U(e,g))` and handoff §4.4's table shape
`g ∈ u ∧ U(e,g) ∈ u`.  The `←` direction is event monotonicity; the `→` direction below is
the functionality of the successor, and it is derivable at `Base` from `Axiom.linear_until`. -/
def nextConj {fc : FrameClass} (A B : Formula) :
    ⊢[fc] ((nxt A).and (nxt B)).imp (nxt (Formula.and A B)) := by
  set T := nxt (Formula.and A B) with hT
  set D := (nxt A).and (nxt B) with hD
  set Γ : Context := [D] with hΓ
  set W := Formula.and Formula.bot Formula.bot with hW
  set E1 := Formula.untl (Formula.and A B) W with hE1
  set E2 := Formula.untl (Formula.and A Formula.bot) W with hE2
  set E3 := Formula.untl (Formula.and Formula.bot B) W with hE3
  refine deductionTheorem [] D T ?_
  have h4 : Γ ⊢[fc] D := DerivationTree.assumption Γ D (by simp [hΓ])
  have h5 : Γ ⊢[fc] (E1.or E2).or E3 :=
    DerivationTree.modus_ponens Γ _ _
      (DerivationTree.axiom Γ _ (Axiom.linear_until Formula.bot A Formula.bot B)
        (FrameClass.base_le _)) h4
  have kill : ∀ (Δ : Context) (E : Formula), (⊢[fc] E.imp Formula.bot) →
      (Δ ⊢[fc] (Formula.untl E W).imp T) := by
    intro Δ E hE
    refine deductionTheorem Δ (Formula.untl E W) T ?_
    have a1 := DerivationTree.assumption (fc := fc) (Formula.untl E W :: Δ)
      (Formula.untl E W) (by simp)
    have a2 := eventMono (Formula.untl E W :: Δ) E Formula.bot W hE a1
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (efqAxiom T))
      (DerivationTree.modus_ponens _ _ _ (wk _ _ (untlBotFalse _)) a2)
  have keep : ∀ Δ : Context, Δ ⊢[fc] E1.imp T := by
    intro Δ
    refine deductionTheorem Δ E1 T ?_
    exact guardMono (E1 :: Δ) (Formula.and A B) W Formula.bot
      (rceImp Formula.bot Formula.bot)
      (DerivationTree.assumption (E1 :: Δ) E1 (by simp))
  refine orElim Γ (E1.or E2) E3 T h5 ?_ (kill Γ _ (lceImp Formula.bot B))
  refine deductionTheorem Γ (E1.or E2) T ?_
  exact orElim (E1.or E2 :: Γ) E1 E2 T
    (DerivationTree.assumption (E1.or E2 :: Γ) (E1.or E2) (by simp))
    (keep _) (kill _ _ (rceImp A Formula.bot))

/-! ### The unfolding in handoff §4.4's table shape

```
U(e, g)   <->   X e  \/  ( X g  /\  X U(e, g) )
```
-/

/-- Table shape, forward. -/
def unfoldTableForward (e g : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.untl e g).imp ((nxt e).or ((nxt g).and (nxt (Formula.untl e g)))) := by
  set G' := Formula.and g (Formula.untl e g) with hG'
  set C := (nxt e).or ((nxt g).and (nxt (Formula.untl e g))) with hC
  set Γ : Context := [Formula.untl e g] with hΓ
  refine deductionTheorem [] (Formula.untl e g) C ?_
  have h1 : Γ ⊢[FrameClass.Discrete] (nxt e).or (nxt G') :=
    DerivationTree.modus_ponens Γ _ _ (wk Γ _ (unfoldForward e g))
      (DerivationTree.assumption Γ (Formula.untl e g) (by simp [hΓ]))
  refine orElim Γ (nxt e) (nxt G') C h1 ?_ ?_
  · refine deductionTheorem Γ (nxt e) C ?_
    exact orIntroL _ _ _ (DerivationTree.assumption _ _ (by simp))
  · refine deductionTheorem Γ (nxt G') C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete) (nxt G' :: Γ) (nxt G')
      (by simp)
    have a2 := eventMono (nxt G' :: Γ) G' g Formula.bot (lceImp g (Formula.untl e g)) a1
    have a3 := eventMono (nxt G' :: Γ) G' (Formula.untl e g) Formula.bot
      (rceImp g (Formula.untl e g)) a1
    exact orIntroR _ _ _ (andIntro _ _ _ a2 a3)

/-- Table shape, backward (still `Base`). -/
def unfoldTableBackward (e g : Formula) :
    ⊢[FrameClass.Base]
      ((nxt e).or ((nxt g).and (nxt (Formula.untl e g)))).imp (Formula.untl e g) := by
  set G' := Formula.and g (Formula.untl e g) with hG'
  set A := (nxt e).or ((nxt g).and (nxt (Formula.untl e g))) with hA
  set Δ : Context := [A] with hΔ
  refine deductionTheorem [] A (Formula.untl e g) ?_
  refine orElim Δ (nxt e) ((nxt g).and (nxt (Formula.untl e g))) (Formula.untl e g)
    (DerivationTree.assumption Δ A (by simp [hΔ])) ?_ ?_
  · refine deductionTheorem Δ (nxt e) (Formula.untl e g) ?_
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (unfoldBackward e g))
      (orIntroL _ _ _ (DerivationTree.assumption _ _ (by simp)))
  · refine deductionTheorem Δ ((nxt g).and (nxt (Formula.untl e g))) (Formula.untl e g) ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Base)
      ((nxt g).and (nxt (Formula.untl e g)) :: Δ)
      ((nxt g).and (nxt (Formula.untl e g))) (by simp)
    have a2 := DerivationTree.modus_ponens _ _ _
      (wk _ _ (nextConj g (Formula.untl e g))) a1
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (unfoldBackward e g))
      (orIntroR _ _ _ a2)

/-! ### The schema does real work: no over-determined successor at `Discrete`

The pattern that would block a Lindenbaum-style construction of `filteredStep_fwd` is a world
`w` holding `U(p,q)` while omitting both `U(p,r)` and `U(q,s)`: the first demands that the
successor carry `p` or carry `q` together with `U(p,q)`, and the other two forbid exactly those.
At `FrameClass.Discrete` that pattern is *derivably* inconsistent, so no such `w` exists.  At
`FrameClass.Base` — where the closure MCS layer actually lives — this derivation is unavailable,
because `unfoldForward` is. -/
def noBlockingTriple (p q r s : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.untl p q).imp ((Formula.untl p r).or (Formula.untl q s)) := by
  set C := (Formula.untl p r).or (Formula.untl q s) with hC
  set Γ : Context := [Formula.untl p q] with hΓ
  set G' := Formula.and q (Formula.untl p q) with hG'
  refine deductionTheorem [] (Formula.untl p q) C ?_
  have h1 : Γ ⊢[FrameClass.Discrete] (nxt p).or (nxt G') :=
    DerivationTree.modus_ponens Γ _ _ (wk Γ _ (unfoldForward p q))
      (DerivationTree.assumption Γ (Formula.untl p q) (by simp [hΓ]))
  refine orElim Γ (nxt p) (nxt G') C h1 ?_ ?_
  · refine deductionTheorem Γ (nxt p) C ?_
    exact orIntroL _ _ _
      (guardMono (nxt p :: Γ) p Formula.bot r (efqAxiom r)
        (DerivationTree.assumption (nxt p :: Γ) (nxt p) (by simp)))
  · refine deductionTheorem Γ (nxt G') C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete) (nxt G' :: Γ) (nxt G')
      (by simp)
    have a2 := eventMono (nxt G' :: Γ) G' q Formula.bot (lceImp q (Formula.untl p q)) a1
    exact orIntroR _ _ _ (guardMono (nxt G' :: Γ) q Formula.bot s (efqAxiom s) a2)

/-! ## Result 3: `filteredStep` and the refutation of `filteredStep_fwd`

The relation below is handoff §4.4's table, verbatim, on closure-MCS bundles, then lifted
through `Quotient.lift₂` to `FilteredWorld`. -/

/-- The one-step relation on closure-MCS bundles.  Event-first / guard-second throughout. -/
def StepBundle (φ : Formula) (w u : ClosureMCSBundle φ) : Prop :=
  (∀ χ ψ, Formula.untl χ ψ ∈ subformulaClosure φ →
      (Formula.untl χ ψ ∈ w.carrier ↔
        (χ ∈ u.carrier ∨ (ψ ∈ u.carrier ∧ Formula.untl χ ψ ∈ u.carrier)))) ∧
  (∀ χ ψ, Formula.snce χ ψ ∈ subformulaClosure φ →
      (Formula.snce χ ψ ∈ u.carrier ↔
        (χ ∈ w.carrier ∨ (ψ ∈ w.carrier ∧ Formula.snce χ ψ ∈ w.carrier)))) ∧
  (∀ χ, Formula.box χ ∈ subformulaClosure φ →
      (Formula.box χ ∈ w.carrier ↔ Formula.box χ ∈ u.carrier))

/-- `StepBundle` mentions only membership of closure formulas, so it respects
`ClosureMCSEquiv` in each argument (`formula_mem_respects_equiv`). -/
theorem stepBundle_respects (φ : Formula) {w₁ w₂ u₁ u₂ : ClosureMCSBundle φ}
    (hw : ClosureMCSEquiv φ w₁ w₂) (hu : ClosureMCSEquiv φ u₁ u₂) :
    StepBundle φ w₁ u₁ ↔ StepBundle φ w₂ u₂ := by
  have key : ∀ (a₁ a₂ b₁ b₂ : ClosureMCSBundle φ), ClosureMCSEquiv φ a₁ a₂ →
      ClosureMCSEquiv φ b₁ b₂ → StepBundle φ a₁ b₁ → StepBundle φ a₂ b₂ := by
    rintro a₁ a₂ b₁ b₂ ha hb ⟨hU, hS, hB⟩
    refine ⟨?_, ?_, ?_⟩
    · intro χ ψ hmem
      have hχ := closure_untl_left φ χ ψ hmem
      have hψ := closure_untl_right φ χ ψ hmem
      rw [← ha _ hmem, ← hb _ hχ, ← hb _ hψ, ← hb _ hmem]
      exact hU χ ψ hmem
    · intro χ ψ hmem
      have hχ := closure_snce_left φ χ ψ hmem
      have hψ := closure_snce_right φ χ ψ hmem
      rw [← hb _ hmem, ← ha _ hχ, ← ha _ hψ, ← ha _ hmem]
      exact hS χ ψ hmem
    · intro χ hmem
      rw [← ha _ hmem, ← hb _ hmem]
      exact hB χ hmem
  exact ⟨key w₁ w₂ u₁ u₂ hw hu,
    key w₂ w₁ u₂ u₁ (closure_mcs_equiv_equivalence φ |>.symm hw)
      (closure_mcs_equiv_equivalence φ |>.symm hu)⟩

/-- The filtered one-step relation on `FilteredWorld φ`. -/
def filteredStep (φ : Formula) : FilteredWorld φ → FilteredWorld φ → Prop :=
  Quotient.lift₂ (StepBundle φ)
    (fun _ _ _ _ hw hu => propext (stepBundle_respects φ hw hu))

theorem filteredStep_mk (φ : Formula) (w u : ClosureMCSBundle φ) :
    filteredStep φ (toFilteredWorld φ w) (toFilteredWorld φ u) ↔ StepBundle φ w u := Iff.rfl

/-! ### The obstruction

Take `Φ := U(⊤, ⊥)`, the discreteness indicator, as the target formula.  Its closure is
`{U(⊤,⊥), ⊤, ⊥}`.  The `untl` clause of the table at `χ := ⊤`, `ψ := ⊥` reads

```
U(⊤,⊥) ∈ w  ↔  ⊤ ∈ u  ∨  (⊥ ∈ u ∧ U(⊤,⊥) ∈ u)
```

and `⊤ ∈ u` holds in *every* closure MCS by deductive closure.  So the right-hand side is
unconditionally true, and any `w` omitting `U(⊤,⊥)` has no `filteredStep`-successor at all. -/

/-- The discreteness indicator, used as the target formula of the filtration. -/
def Phi : Formula := nxt Formula.top

theorem top_mem_closure : Formula.top ∈ subformulaClosure Phi :=
  closure_untl_left Phi Formula.top Formula.bot (self_mem_subformulaClosure Phi)

/-- `⊤` belongs to every closure MCS whose closure contains it. -/
theorem top_mem (φ : Formula) (w : ClosureMCSBundle φ)
    (h : Formula.top ∈ subformulaClosure φ) : Formula.top ∈ w.carrier :=
  closure_mcs_deductively_closed w.is_mcs (Γ := []) (by simp) topThm
    (subformulaClosure_subset_closureWithNeg φ h)

/-- **Any `StepBundle`-successor forces `U(⊤,⊥)` into the source world.** -/
theorem stepBundle_forces_phi (w u : ClosureMCSBundle Phi) (h : StepBundle Phi w u) :
    Phi ∈ w.carrier := by
  have hmem : Formula.untl Formula.top Formula.bot ∈ subformulaClosure Phi :=
    self_mem_subformulaClosure Phi
  exact (h.1 Formula.top Formula.bot hmem).mpr (Or.inl (top_mem Phi u top_mem_closure))

/-- **No successor for any world omitting the indicator.** -/
theorem no_successor (w : ClosureMCSBundle Phi) (h : Phi ∉ w.carrier) :
    ¬ ∃ u, StepBundle Phi w u := by
  rintro ⟨u, hu⟩
  exact h (stepBundle_forces_phi w u hu)

/-! ### Such a world exists unless the base system already proves discreteness -/

/-- If `U(⊤,⊥)` is not a base theorem, `{¬U(⊤,⊥)}` is base-consistent. -/
theorem setConsistent_negPhi (h : ¬ Derivable FrameClass.Base [] Phi) :
    SetConsistent (fc := FrameClass.Base) ({Phi.neg} : Set Formula) := by
  intro L hL hbot
  obtain ⟨d⟩ := hbot
  have hsub : L ⊆ [Phi.neg] := by
    intro x hx
    have := hL x hx
    simp only [Set.mem_singleton_iff] at this
    simp [this]
  have d' : [Phi.neg] ⊢ Formula.bot :=
    DerivationTree.weakening L [Phi.neg] Formula.bot d hsub
  have d'' : ⊢ Phi.neg.neg := deductionTheorem [] Phi.neg Formula.bot d'
  exact h ⟨DerivationTree.modus_ponens [] Phi.neg.neg Phi (doubleNegation Phi) d''⟩

/-- A closure MCS omitting the indicator, again under the same hypothesis. -/
theorem exists_bad_world (h : ¬ Derivable FrameClass.Base [] Phi) :
    ∃ w : ClosureMCSBundle Phi, Phi ∉ w.carrier := by
  obtain ⟨S, hmem, hmcs⟩ :=
    closure_mcs_exists_containing Phi Phi.neg
      (neg_mem_closureWithNeg Phi Phi (self_mem_subformulaClosure Phi))
      (setConsistent_negPhi h)
  refine ⟨⟨S, hmcs⟩, ?_⟩
  intro hin
  exact set_consistent_not_both (closure_mcs_consistent hmcs) Phi hin hmem

/-! ### And the base system does not prove discreteness

`Axiom.dense_indicator` *is* `¬U(⊤,⊥)` at `FrameClass.Dense`, and `Base ≤ Dense`. -/

/-- A base derivation of the indicator collapses the dense system. -/
def denseCollapse (d : ⊢[FrameClass.Base] Phi) : ⊢[FrameClass.Dense] Formula.bot :=
  DerivationTree.modus_ponens [] Phi Formula.bot
    (DerivationTree.axiom [] Phi.neg Axiom.dense_indicator (by decide))
    (d.lift (by decide))

/-- The dense system is consistent: soundness over `ℚ` at the trivial frame. -/
theorem dense_consistent : ¬ Derivable FrameClass.Dense [] Formula.bot := by
  rintro ⟨d⟩
  obtain ⟨τ⟩ :=
    TaskFrame.hF_nonempty_of_frameAxioms (D := ℚ) TaskFrame.trivialFrame
  exact Truth.bot_false
    (FormalSystem.Metalogic.soundness_dense_valid d ℚ TaskFrame.trivialFrame
      TaskModel.allFalse τ.val τ.property 0)

/-- `U(⊤,⊥)` is **not** a theorem of the base system. -/
theorem phi_not_base_derivable : ¬ Derivable FrameClass.Base [] Phi := by
  rintro ⟨d⟩
  exact dense_consistent ⟨denseCollapse d⟩

/-! ### Verdict for the *existing* (Base-consistent) filtration layer -/

/-- **`filteredStep_fwd` is false as stated for the repository's `FilteredWorld`.**
There is a filtered world with no `filteredStep`-successor whatsoever. -/
theorem filteredStep_fwd_fails :
    ¬ (∀ w : FilteredWorld Phi, ∃ u, filteredStep Phi w u) := by
  intro hfwd
  obtain ⟨w, hw⟩ := exists_bad_world phi_not_base_derivable
  obtain ⟨u, hu⟩ := hfwd (toFilteredWorld Phi w)
  refine no_successor w hw ⟨Quotient.out u, ?_⟩
  have : filteredStep Phi (toFilteredWorld Phi w)
      (toFilteredWorld Phi (Quotient.out u)) := by
    have hq : toFilteredWorld Phi (Quotient.out u) = u := Quotient.out_eq u
    rw [hq]; exact hu
  exact (filteredStep_mk Phi w (Quotient.out u)).mp this

/-! ### And the relation is *not* the universal one

At `Φ = U(⊤,⊥)` the table pins `filteredStep` exactly to membership of the indicator in the
source world, so it is universal only if every closure MCS contains the indicator — which
`filteredStep_fwd_fails` has just refuted.  This is the Phase 7 defect
(`evidence/phase7-filtered-frame-is-universal.lean`) not being repeated. -/
theorem filteredStep_not_universal :
    ¬ (∀ w u : FilteredWorld Phi, filteredStep Phi w u) := by
  intro huniv
  obtain ⟨w, hw⟩ := exists_bad_world phi_not_base_derivable
  exact hw (stepBundle_forces_phi w w
    ((filteredStep_mk Phi w w).mp (huniv _ _)))

end

/-! ## Axiom audit -/

#print axioms Spike417.succIndicator
#print axioms Spike417.unfoldForward
#print axioms Spike417.unfoldBackward
#print axioms Spike417.noBlockingTriple
#print axioms Spike417.nextConj
#print axioms Spike417.unfoldTableForward
#print axioms Spike417.unfoldTableBackward
#print axioms Spike417.filteredStep_fwd_fails
#print axioms Spike417.filteredStep_not_universal

end Spike417
