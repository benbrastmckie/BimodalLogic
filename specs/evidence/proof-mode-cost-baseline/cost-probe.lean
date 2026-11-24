/-
Cost-baseline probe for the derivation proof mode: every acceptance fixture, the two nesting
ladders, the simplifier rows and the views rows, each measured by `#reprove_record`.

This file is an evidence probe, not part of the library. It is deliberately NOT wired into
`scripts/check-evidence-probes.sh`: a wall-clock elaboration-time measurement is not a
compile-check invariant, and wiring it would oblige that gate to keep compiling 52 mirrored
acceptance scripts forever. What exercises it is `scripts/proof-mode-cost-baseline.sh`, which is
the one command the baseline document names as its reproduction route.

`maxHeartbeats 0` is correct HERE and nowhere in the library: this file measures how expensive
each script is, so a heartbeat cap would convert a slow script into a failure and destroy the
very measurement. `#reprove_record` deliberately does not set the cap itself, so that the
measurement's conditions are stated in the probe a reader is looking at rather than hidden in an
elaborator.

`profiler true` is what makes per-declaration sites separable inside one file: Lean reports
`tactic execution of ... took` and `type checking took` per declaration, in source order. The
`elab_ms` field of each emitted record is the same quantity measured by the emitter itself, and
the profiler output is the cross-check on it.

## The mirrors are a deliberate second copy

`Tests/BimodalTest/Automation/ProofModeAxioms.lean` already holds named mirrors of a
representative script per tactic family. The mirrors below are a second copy of the same idea,
and the duplication is forced by the instrument rather than an oversight: a heartbeat count can
only be taken of an elaboration the counter performs itself, so this probe cannot read
already-elaborated declarations out of an import. It must re-elaborate.

Each mirror is mechanically derived from its acceptance fixture: the `example` keyword is replaced
by `def m<NN>` and nothing else in the script body is touched, so the figure measured is the
acceptance example's own cost. The fixtures are not edited. The per-module counts are re-derived
by `grep -c '^example' Tests/BimodalTest/Automation/ProofMode*Test.lean`, which gives
31 + 6 + 4 + 5 + 6 = 52 at the measurement commit.

**That 52 is not the number of acceptance scripts, and the difference was measured rather than
assumed.** Four of those 52 are `#guard_msgs`-guarded NEGATIVE fixtures in
`ProofModeBooleanTest.lean`, whose `example` also begins at column 0 and is therefore counted by
that grep. The per-module breakdown is 31/0, 2/4, 4/0, 5/0, 6/0 (positive/guarded), so there are
**48 positive acceptance scripts** and 4 guarded negatives. The 48 are mirrored here; the 4 are
not, because a script that is asserted to fail has no cost worth recording and mirroring one would
put a deliberately-failing declaration into a probe that is supposed to elaborate clean. The
guarded negatives keep their own home in the test library, where their messages are the assertion.

Each mirror carries a comment naming its source module and its position in it.

## What the outcome and escape fields mean here

A mirror whose body uses only the mode's own `l*` tactics (plus the structural bullet, the
`guard_target`/`guard_hyp` assertions and `fail_if_success`, none of which close a goal) is
recorded `closed_by_rules` with a null failure class. Three mirrors in the whole corpus close a
goal with a bare `exact`, which is a term-mode escape: those are recorded
`closed_with_term_escape` with failure class `missing_tactic` -- the rule is definitional equality,
which exists, and no tactic of the mode reaches it -- and their `escape_size` is the escape term's
own node count, 1 for a single local hypothesis and 3 for an application of one to a constant.
`constructor` is counted as harness rather than as an escape: in these fixtures it splits a
Lean-level product of two judgments, which is the fixture's own shape and not a derivation step.
-/

import FormalSystem.Automation.ProofMode
import FormalSystem.Theorems.LinearityDerived
import BimodalLib.Diagnostics.Emit

set_option maxHeartbeats 0
set_option profiler true
set_option linter.style.longLine false
set_option linter.unusedVariables false

namespace ProofModeCostBaseline


/-! ### Mirrors of `Tests/BimodalTest/Automation/ProofModeTest.lean` (31 positive acceptance scripts) -/

namespace ProofModeTest

open FormalSystem.Syntax FormalSystem.ProofSystem

variable (A B C : Formula)

opaque projectionContract : ⊢ (A.and B).imp A := by
  lintro h
  lcases h as hA hB
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 1 of 31
#reprove_record m01 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lapply,lexact" escape 0 in
def m01 : [A.imp B, A] ⊢ B := by
  lstart hAB hA
  lapply hAB
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 2 of 31
#reprove_record m02 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def m02 : ⊢ A.imp A := by
  lintro hA
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 3 of 31
#reprove_record m03 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lsplit,lexact" escape 0 in
def m03 : [A, B] ⊢ A.and B := by
  lstart hA hB
  lsplit
  · lexact hA
  · lexact hB

-- source: ProofModeTest.lean, positive acceptance script 4 of 31
#reprove_record m04 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lcases,lapply,lexact" escape 0 in
def m04 : [A.or B, A.imp C, B.imp C] ⊢ C := by
  lstart hAB hAC hBC
  lcases hAB as hA hB
  · lapply hAC
    lexact hA
  · lapply hBC
    lexact hB

-- source: ProofModeTest.lean, positive acceptance script 5 of 31
#reprove_record m05 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_intro,lapply,lexact" escape 0 in
def m05 : [(A.imp B).box, A.box] ⊢ B.box := by
  lstart hAB hA
  lmodal_intro necessity using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 6 of 31
#reprove_record m06 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ltemporal_intro,lapply,lexact" escape 0 in
def m06 : [(A.imp B).allFuture, A.allFuture] ⊢ B.allFuture := by
  lstart hAB hA
  ltemporal_intro future using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 7 of 31
#reprove_record m07 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ltemporal_intro,lapply,lexact" escape 0 in
def m07 : [(A.imp B).allPast, A.allPast] ⊢ B.allPast := by
  lstart hAB hA
  ltemporal_intro past using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 8 of 31
#reprove_record m08 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ltemporal_cases,lsplit,lexact" escape 0 in
def m08 : [A.allFuture, B.someFuture] ⊢ (A.and B).someFuture := by
  lstart hA hB
  ltemporal_cases hB using [hA] as hB hA
  lsplit
  · lexact hA
  · lexact hB

-- Reuse an opaque contract and a provider with an abstract context through two cuts.
-- source: ProofModeTest.lean, positive acceptance script 9 of 31
#reprove_record m09 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lhave,lapply,lexact" escape 0 in
def m09 (Γ : Context) (provider : Γ ⊢ A.and B) : Γ ⊢ C.imp A := by
  lintro hC
  lhave hPair : A.and B := provider
  lapply (projectionContract A B)
  lexact hPair

-- □ facts travel to an alternative; current facts cannot leak into it.
-- source: ProofModeTest.lean, positive acceptance script 10 of 31
#reprove_record m10 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_cases,lsplit,lexact" escape 0 in
def m10 : [A.box, A.diamond, A] ⊢ (A.and A).diamond := by
  lstart hBox hPossible hCurrent
  lmodal_cases hPossible using [hBox] as hEvent hA
  lsplit
  · fail_if_success lexact hCurrent
    lexact hEvent
  · lexact hA

-- An explicit empty selection must not inherit the matching outer guarantee.
-- source: ProofModeTest.lean, positive acceptance script 11 of 31
#reprove_record m11 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_intro,lexact,lintro" escape 0 in
def m11 : [(A.imp A).box, A.imp A] ⊢ (A.imp A).box := by
  lstart hBox hCurrent
  lmodal_intro necessity using []
  fail_if_success lexact hCurrent
  lintro hA
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 12 of 31
#reprove_record m12 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lprogress" escape 0 in
def m12 : [(A.imp B.someFuture).allFuture, (B.imp C.someFuture).allFuture] ⊢
    (A.imp C.someFuture).allFuture := by
  lstart hAB hBC
  lprogress using [hAB, hBC]

-- source: ProofModeTest.lean, positive acceptance script 13 of 31
#reprove_record m13 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ladvance,lapply,lexact" escape 0 in
def m13 : [A.someFuture, (A.imp B.someFuture).allFuture] ⊢ B.someFuture := by
  lstart hA hMap
  ladvance hA using [hMap] as hA hMap
  lapply hMap
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 14 of 31
#reprove_record m14 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,luntil,lexact" escape 0 in
def m14 : [(A.imp B).allFuture, Formula.untl A C] ⊢ Formula.untl B C := by
  lstart hMap hUntil
  luntil guard using hMap
  lexact hUntil

-- source: ProofModeTest.lean, positive acceptance script 15 of 31
#reprove_record m15 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lstep,lapply,lexact" escape 0 in
def m15 : [(A.imp B).next, A.next] ⊢[FrameClass.ZTime] B.next := by
  lstart hMap hA
  lstep future using [hMap, hA] as hMap hA
  lapply hMap
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 16 of 31
#reprove_record m16 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,linvariant,lexact" escape 0 in
def m16 : [A, A.imp A.next, (A.imp A.next).allFuture] ⊢[FrameClass.ZTime] A.allFuture := by
  lstart hInit hNow hFuture
  linvariant future
  · lexact hInit
  · lexact hNow
  · lexact hFuture

-- An abstract frame retains the certificate as a real proof obligation.
-- source: ProofModeTest.lean, positive acceptance script 17 of 31
#reprove_record m17 stage "reprove" outcome "closed_with_term_escape"
  failure "missing_tactic" tactics "lstep,lintro,lexact,exact" escape 1 in
def m17 (fc : FrameClass) (hFrame : FrameClass.ZTime ≤ fc) : ⊢[fc] (A.imp A).next := by
  lstep future using []
  · exact hFrame
  · lintro hA
    lexact hA

-- Native TM⁺ arguments may contain stability; no restriction to embedded TM formulas.
-- source: ProofModeTest.lean, positive acceptance script 18 of 31
#reprove_record m18 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ltemporal_use,lexact" escape 0 in
def m18 (p q : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base
      [(p.stab.imp q).allPast, p.stab.allPast] q.allPast := by
  lstart hMap hP
  ltemporal_use hMap
  lexact hP

-- source: ProofModeTest.lean, positive acceptance script 19 of 31
#reprove_record m19 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_cases,lsplit,lexact" escape 0 in
def m19 (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base
      [p.stab.stab, p.stab.dstab] (p.stab.and p.stab).dstab := by
  lstart hSettled hPossible
  lmodal_cases hPossible using [hSettled] as hEvent hScoped
  lsplit
  · lexact hEvent
  · lexact hScoped

-- Exercise dynamically selected rules and past/dual variants at their tactic entry points.
-- source: ProofModeTest.lean, positive acceptance script 20 of 31
#reprove_record m20 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_use,lsplit,lexact" escape 0 in
def m20 : [A.box] ⊢ A.and A := by
  lstart hBox
  lmodal_use hBox as hA
  lsplit
  · lexact hA
  · lmodal_use hBox

-- source: ProofModeTest.lean, positive acceptance script 21 of 31
#reprove_record m21 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lcases,lright,lexact,lleft" escape 0 in
def m21 : [A.or B] ⊢ B.or A := by
  lstart hEither
  lcases hEither as hA hB
  · lright
    lexact hA
  · lleft
    lexact hB

-- source: ProofModeTest.lean, positive acceptance script 22 of 31
#reprove_record m22 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,luntil,lexact" escape 0 in
def m22 : [(A.imp B).allFuture, Formula.untl C A] ⊢ Formula.untl C B := by
  lstart hMap hUntil
  luntil event using hMap
  lexact hUntil

-- source: ProofModeTest.lean, positive acceptance script 23 of 31
#reprove_record m23 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lsince,lexact" escape 0 in
def m23 : [(A.imp B).allPast, (B.imp C).allPast, Formula.snce A B] ⊢ Formula.snce B C := by
  lstart hGuard hEvent hSince
  lsince guard using hGuard
  lsince event using hEvent
  lexact hSince

-- source: ProofModeTest.lean, positive acceptance script 24 of 31
#reprove_record m24 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lstep,lapply,lexact" escape 0 in
def m24 : [(A.imp B).prev, A.prev] ⊢[FrameClass.ZTime] B.prev := by
  lstart hMap hA
  lstep past using [hMap, hA] as hMap hA
  lapply hMap
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 25 of 31
#reprove_record m25 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,linvariant,lexact" escape 0 in
def m25 : [A, A.imp A.prev, (A.imp A.prev).allPast] ⊢[FrameClass.ZTime] A.allPast := by
  lstart hInit hNow hPast
  linvariant past
  · lexact hInit
  · lexact hNow
  · lexact hPast

-- source: ProofModeTest.lean, positive acceptance script 26 of 31
#reprove_record m26 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ltemporal_cases,lsplit,lexact" escape 0 in
def m26 : [A.allPast, B.somePast] ⊢ (A.and B).somePast := by
  lstart hA hB
  ltemporal_cases hB using [hA] as hB hA
  lsplit
  · lexact hA
  · lexact hB

-- source: ProofModeTest.lean, positive acceptance script 27 of 31
#reprove_record m27 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_intro,lexact" escape 0 in
def m27 : [A] ⊢ A.diamond := by
  lstart hA
  lmodal_intro possibility
  lexact hA

-- source: ProofModeTest.lean, positive acceptance script 28 of 31
#reprove_record m28 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_intro,lleft,lexact" escape 0 in
def m28 (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base [p.stab] (p.or p).stab := by
  lstart hP
  lmodal_intro settled using [hP] as hP
  lleft
  lexact hP

-- source: ProofModeTest.lean, positive acceptance script 29 of 31
#reprove_record m29 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lmodal_intro,lmodal_use" escape 0 in
def m29 (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base [p.stab] p.dstab := by
  lstart hP
  lmodal_intro settled_possibility
  lmodal_use hP

-- A G-scoped implication applied in TM, leaving its G premise.
-- source: ProofModeTest.lean, positive acceptance script 30 of 31
#reprove_record m30 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,ltemporal_use,lexact" escape 0 in
def m30 : [(A.imp B).allFuture, A.allFuture] ⊢ B.allFuture := by
  lstart hMap hA
  ltemporal_use hMap
  lexact hA

-- `lhave` without `:=` leaves the intermediate assertion as its own obligation.
-- source: ProofModeTest.lean, positive acceptance script 31 of 31
#reprove_record m31 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lhave,lapply,lexact,lsplit" escape 0 in
def m31 : [A, A.imp B] ⊢ B.and A := by
  lstart hA hAB
  lhave hB : B
  · lapply hAB
    lexact hA
  · lsplit
    · lexact hB
    · lexact hA

end ProofModeTest

/-! ### Mirrors of `Tests/BimodalTest/Automation/ProofModeBooleanTest.lean` (2 positive acceptance scripts) -/

namespace ProofModeBooleanTest

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

private def weakeningSchema (X Y : Formula) : ⊢[fc] X.imp (Y.imp X) :=
  .axiom [] _ (.prop_s X Y) (FrameClass.base_le fc)

-- Negative positions reverse implication direction. Explicit paths disambiguate repeated leaves.
-- source: ProofModeBooleanTest.lean, positive acceptance script 1 of 2
#reprove_record m01 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m01 (mapping : Γ ⊢[fc] B.imp A) (provider : Γ ⊢[fc] A.imp C) : Γ ⊢[fc] B.imp C := by
  lrewrite ← mapping (path := [impLeft]) at provider as mapped
  lexact mapped

-- An unmatched data parameter is never guessed from the first Formula local in scope.
-- source: ProofModeBooleanTest.lean, positive acceptance script 2 of 2
#reprove_record m02 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m02 (provider : Γ ⊢[fc] A) : Γ ⊢[fc] A := by
  fail_if_success lrewrite weakeningSchema at provider as guessed
  fail_if_success lrewrite weakeningSchema at provider as guessed (obligations := expose)
  lexact provider

end ProofModeBooleanTest

/-! ### Mirrors of `Tests/BimodalTest/Automation/ProofModeModalBooleanTest.lean` (4 positive acceptance scripts) -/

namespace ProofModeModalBooleanTest

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- Scope replacement needs a real native proof and drops unused implicit premises of the old map.
-- source: ProofModeModalBooleanTest.lean, positive acceptance script 1 of 4
#reprove_record m01 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m01 (_localMap : ∀ {_unavailable : False}, Γ ⊢[fc] A.imp B)
    (hScoped : Γ ⊢[fc] (A.imp B).box)
    (provider : Γ ⊢[fc] A.box) : Γ ⊢[fc] B.box := by
  lrewrite _localMap at provider as mapped (obligations := expose)
  · guard_target =ₛ Γ ⊢[fc] (A.imp B).box
    lexact hScoped
  · guard_hyp mapped :ₛ Γ ⊢[fc] B.box
    lexact mapped

-- Named views change formula data at a goal or local hypothesis.
-- source: ProofModeModalBooleanTest.lean, positive acceptance script 2 of 4
#reprove_record m02 stage "reprove" outcome "closed_with_term_escape"
  failure "missing_tactic" tactics "lfold,lunfold,exact" escape 1 in
def m02 (provider : Γ ⊢[fc] A.neg.box.neg) : Γ ⊢[fc] A.diamond := by
  lfold diamond at provider
  guard_hyp provider :ₛ Γ ⊢[fc] A.diamond
  lunfold diamond
  guard_target =ₛ Γ ⊢[fc] A.neg.box.neg
  exact provider

-- Backward goal rewriting exactly replays the closed boxDne derivation.
-- source: ProofModeModalBooleanTest.lean, positive acceptance script 3 of 4
#reprove_record m03 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m03 (h : ⊢[fc] A.neg.neg.box) : ⊢[fc] A.box := by
  lrewrite ← (FormalSystem.Theorems.Propositional.doubleNegation (fc := fc) A)
    (path := [boxBody])
  lexact h

-- source: ProofModeModalBooleanTest.lean, positive acceptance script 4 of 4
#reprove_record m04 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lsimp,lexact" escape 0 in
def m04 (Δ : FormalSystem.PlusLanguage.PlusContext) (P : FormalSystem.PlusLanguage.PlusFormula)
    (provider : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ P.neg.neg.stab) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc Δ P.stab := by
  lsimp only [FormalSystem.PlusLanguage.ProofMode.doubleNegationIff] at provider as reduced
  lexact reduced

end ProofModeModalBooleanTest

/-! ### Mirrors of `Tests/BimodalTest/Automation/ProofModeTemporalBooleanTest.lean` (5 positive acceptance scripts) -/

namespace ProofModeTemporalBooleanTest

open FormalSystem.Syntax FormalSystem.ProofSystem

open FormalSystem.Theorems.LinearityDerived

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

private def implicitDensityRule {gate : FrameClass.Dense ≤ fc} (P : Formula) :
    ⊢[fc] P.allFuture.allFuture.imp P.allFuture :=
  density gate P

-- Concrete frame gates are checked, not exposed as impossible obligations or silently assumed.
-- source: ProofModeTemporalBooleanTest.lean, positive acceptance script 1 of 5
#reprove_record m01 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m01 (base : Γ ⊢ A.allFuture.allFuture)
    (dense : Γ ⊢[FrameClass.Dense] A.allFuture.allFuture) :
    (Γ ⊢ A.allFuture.allFuture) × (Γ ⊢[FrameClass.Dense] A.allFuture) := by
  constructor
  · fail_if_success lrewrite density at base as collapsed (obligations := expose)
    lexact base
  · lrewrite density at dense as collapsed
    lexact collapsed

-- Leading implicit premises inserted by term elaboration are genuine, atomic obligations.
-- source: ProofModeTemporalBooleanTest.lean, positive acceptance script 2 of 5
#reprove_record m02 stage "reprove" outcome "closed_with_term_escape"
  failure "missing_tactic" tactics "lrewrite,lsimp,lexact,exact" escape 3 in
def m02 (frameProvider : True → FrameClass.Dense ≤ fc)
    (provider : Γ ⊢[fc] A.allFuture.allFuture) : Γ ⊢[fc] A.allFuture := by
  fail_if_success lrewrite implicitDensityRule at provider as untracked
  fail_if_success lsimp only [implicitDensityRule] at provider as untracked
  lrewrite implicitDensityRule at provider as mapped (obligations := expose)
  · exact frameProvider True.intro
  · lexact mapped

-- Boolean reduction and strict FFA→FA are independent, genuinely one-way proof steps.
-- source: ProofModeTemporalBooleanTest.lean, positive acceptance script 3 of 5
#reprove_record m03 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lsimp,lexact" escape 0 in
def m03 (provider : Γ ⊢ A.neg.neg.someFuture.someFuture) : Γ ⊢ A.someFuture := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff,
    FormalSystem.Theorems.ProofMode.futureCollapse] at provider as reduced
  lexact reduced

-- Occurrence selection precedes scope discharge: an inaccessible match is still ambiguous.
-- source: ProofModeTemporalBooleanTest.lean, positive acceptance script 4 of 5
#reprove_record m04 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m04 (mapping : Γ ⊢ (A.imp B).allFuture) (provider : Γ ⊢ A.and A.allFuture) :
    Γ ⊢ A.and B.allFuture := by
  fail_if_success lrewrite mapping at provider as implicitChoice
  lrewrite mapping (path := [andRight, futureBody]) at provider as mapped
  lexact mapped

-- Past scope transport works through Previous and through the guard of Since.
-- source: ProofModeTemporalBooleanTest.lean, positive acceptance script 5 of 5
#reprove_record m05 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m05 (mapping : Γ ⊢ (A.imp B).allPast) (previous : Γ ⊢ A.prev)
    (since : Γ ⊢ Formula.snce A C) : (Γ ⊢ B.prev) × (Γ ⊢ Formula.snce B C) := by
  constructor
  · lrewrite mapping (path := [prevBody]) at previous as mapped
    lexact mapped
  · lrewrite mapping (path := [sinceGuard]) at since as mapped
    lexact mapped

end ProofModeTemporalBooleanTest

/-! ### Mirrors of `Tests/BimodalTest/Automation/ProofModeModalTemporalBooleanTest.lean` (6 positive acceptance scripts) -/

namespace ProofModeModalTemporalBooleanTest

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- The same opaque scoped statement supports fact rewriting and backward goal reconstruction.
-- source: ProofModeModalTemporalBooleanTest.lean, positive acceptance script 1 of 6
#reprove_record m01 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lsplit,lrewrite,lexact" escape 0 in
def m01 (mapping : Γ ⊢[fc] (A.imp B).allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).allFuture.box) :
    Γ ⊢[fc] ((B.or C).allFuture.box).and ((B.or C).allFuture.box) := by
  lsplit
  · lrewrite mapping at provider as mapped
    lexact mapped
  · fail_if_success lrewrite mapping
    lrewrite ← mapping
    lexact provider

-- Current-point equivalence cannot enter a fresh world/time scope.
-- source: ProofModeModalTemporalBooleanTest.lean, positive acceptance script 2 of 6
#reprove_record m02 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m02 (_localEq : Γ ⊢[fc] (A.imp B).and (B.imp A))
    (provider : Γ ⊢[fc] A.allFuture.box) : Γ ⊢[fc] A.allFuture.box := by
  fail_if_success lrewrite _localEq at provider as leaked
  lexact provider

-- Closed logical equivalences rewrite through conditional Next at Base without an existence gate.
-- source: ProofModeModalTemporalBooleanTest.lean, positive acceptance script 3 of 6
#reprove_record m03 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m03 (provider : Γ ⊢ A.box.next.allFuture) : Γ ⊢ A.box.diamond.next.allFuture := by
  lrewrite (FormalSystem.Theorems.ModalS5.s5DiamondBox A)
  lexact provider

-- The exact same planner composes TM transfers and native stability at arbitrary Plus arguments.
-- source: ProofModeModalTemporalBooleanTest.lean, positive acceptance script 4 of 6
#reprove_record m04 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m04 (Δ : FormalSystem.PlusLanguage.PlusContext)
    (P Q R : FormalSystem.PlusLanguage.PlusFormula)
    (mapping : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ
      ((P.imp Q).allFuture.stab.box))
    (provider : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ
      ((P.or R).allFuture.stab.box)) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc Δ ((Q.or R).allFuture.stab.box) := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- Simp reduces closed modal equivalences, skips growing orientations, and restores on exhaustion.
-- source: ProofModeModalTemporalBooleanTest.lean, positive acceptance script 5 of 6
#reprove_record m05 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lsplit,lsimp,lexact" escape 0 in
def m05 (provider : Γ ⊢ A.box.next.allFuture) (boxes : Γ ⊢ (A.and B).box) :
    Γ ⊢ (A.box.and B.box).and A.box.diamond.next.allFuture := by
  lsplit
  · fail_if_success lsimp only [← FormalSystem.Theorems.ModalS5.boxConjIff]
    lsimp only [FormalSystem.Theorems.ModalS5.boxConjIff]
    lexact boxes
  · fail_if_success lsimp only [FormalSystem.Theorems.ModalS5.s5DiamondBox] (maxSteps := 0)
    lsimp only [FormalSystem.Theorems.ModalS5.s5DiamondBox]
    fail_if_success lsimp only [← FormalSystem.Theorems.ModalS5.s5DiamondBox]
    lexact provider

-- Run the fragile scope adapters and exact conditional Next in one compact product fixture.
-- source: ProofModeModalTemporalBooleanTest.lean, positive acceptance script 6 of 6
#reprove_record m06 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def m06 (boxMap : Γ ⊢ (A.imp B).box) (futureMap : Γ ⊢ (A.imp B).allFuture)
    (nextMap : Γ ⊢ (A.imp B).next) (future : Γ ⊢ A.allFuture)
    (futureFuture : Γ ⊢ A.allFuture.allFuture) (adjacent : Γ ⊢ A.next) :
    (Γ ⊢ B.allFuture) × (Γ ⊢ B.allFuture.allFuture) × (Γ ⊢ B.next) := by
  constructor
  · lrewrite boxMap at future as mapped
    lexact mapped
  constructor
  · lrewrite futureMap at futureFuture as mapped
    lexact mapped
  · lrewrite nextMap at adjacent as mapped
    lexact mapped

end ProofModeModalTemporalBooleanTest

/-! ### The `lintro` ladder, depth 1 to 16

`lintro` discharges through the deduction theorem, which transforms a whole derivation, so each
step re-walks what the previous ones built. Whether that makes a long script expensive to
elaborate, expensive to check, or both, is the open question these rows answer. The task's stated
threshold of five nested steps is a member of the range rather than the whole of it, because a
single point cannot distinguish a linear cost from a quadratic one.
-/

namespace IntroLadder

-- `lintro` nested 1 deep, closing on the first introduced hypothesis.
#reprove_record i01 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i01 (A1 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A1)) := by
  lintro h1
  lexact h1

-- `lintro` nested 2 deep, closing on the first introduced hypothesis.
#reprove_record i02 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i02 (A1 A2 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A1))) := by
  lintro h1
  lintro h2
  lexact h1

-- `lintro` nested 3 deep, closing on the first introduced hypothesis.
#reprove_record i03 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i03 (A1 A2 A3 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A1)))) := by
  lintro h1
  lintro h2
  lintro h3
  lexact h1

-- `lintro` nested 4 deep, closing on the first introduced hypothesis.
#reprove_record i04 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i04 (A1 A2 A3 A4 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A1))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lexact h1

-- `lintro` nested 5 deep, closing on the first introduced hypothesis.
#reprove_record i05 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i05 (A1 A2 A3 A4 A5 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A1)))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lexact h1

-- `lintro` nested 6 deep, closing on the first introduced hypothesis.
#reprove_record i06 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i06 (A1 A2 A3 A4 A5 A6 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A1))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lexact h1

-- `lintro` nested 7 deep, closing on the first introduced hypothesis.
#reprove_record i07 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i07 (A1 A2 A3 A4 A5 A6 A7 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A1)))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lexact h1

-- `lintro` nested 8 deep, closing on the first introduced hypothesis.
#reprove_record i08 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i08 (A1 A2 A3 A4 A5 A6 A7 A8 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A1))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lexact h1

-- `lintro` nested 9 deep, closing on the first introduced hypothesis.
#reprove_record i09 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i09 (A1 A2 A3 A4 A5 A6 A7 A8 A9 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A1)))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lexact h1

-- `lintro` nested 10 deep, closing on the first introduced hypothesis.
#reprove_record i10 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i10 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A1))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lexact h1

-- `lintro` nested 11 deep, closing on the first introduced hypothesis.
#reprove_record i11 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i11 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A11.imp (A1)))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lintro h11
  lexact h1

-- `lintro` nested 12 deep, closing on the first introduced hypothesis.
#reprove_record i12 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i12 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A11.imp (A12.imp (A1))))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lintro h11
  lintro h12
  lexact h1

-- `lintro` nested 13 deep, closing on the first introduced hypothesis.
#reprove_record i13 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i13 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A11.imp (A12.imp (A13.imp (A1)))))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lintro h11
  lintro h12
  lintro h13
  lexact h1

-- `lintro` nested 14 deep, closing on the first introduced hypothesis.
#reprove_record i14 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i14 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A11.imp (A12.imp (A13.imp (A14.imp (A1))))))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lintro h11
  lintro h12
  lintro h13
  lintro h14
  lexact h1

-- `lintro` nested 15 deep, closing on the first introduced hypothesis.
#reprove_record i15 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i15 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A11.imp (A12.imp (A13.imp (A14.imp (A15.imp (A1)))))))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lintro h11
  lintro h12
  lintro h13
  lintro h14
  lintro h15
  lexact h1

-- `lintro` nested 16 deep, closing on the first introduced hypothesis.
#reprove_record i16 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lintro,lexact" escape 0 in
def i16 (A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 A16 : FormalSystem.Syntax.Formula) :
    FormalSystem.ProofSystem.DerivationTree FormalSystem.ProofSystem.FrameClass.Base [] (A1.imp (A2.imp (A3.imp (A4.imp (A5.imp (A6.imp (A7.imp (A8.imp (A9.imp (A10.imp (A11.imp (A12.imp (A13.imp (A14.imp (A15.imp (A16.imp (A1))))))))))))))))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lintro h6
  lintro h7
  lintro h8
  lintro h9
  lintro h10
  lintro h11
  lintro h12
  lintro h13
  lintro h14
  lintro h15
  lintro h16
  lexact h1

end IntroLadder

/-! ### The nested logical rewrite, 0 to 4 nested scopes

The merged congruence kit (`lrewrite`/`lsimp`) promised a cost baseline and recorded none. These
rows are it. Each transports an implication through the scope stack named in its docstring, which
is read outside-in: `□ G H` is `□ G H (A → B)`.
-/

namespace RewriteLadder

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- `lrewrite` through 0 nested scope(s): (current point).
#reprove_record rw0 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def rw0 (mapping : Γ ⊢[fc] (A.imp B))
    (provider : Γ ⊢[fc] (A.or C)) : Γ ⊢[fc] (B.or C) := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- `lrewrite` through 1 nested scope(s): □.
#reprove_record rw1 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def rw1 (mapping : Γ ⊢[fc] (A.imp B).box)
    (provider : Γ ⊢[fc] (A.or C).box) : Γ ⊢[fc] (B.or C).box := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- `lrewrite` through 2 nested scope(s): □ G.
#reprove_record rw2 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def rw2 (mapping : Γ ⊢[fc] (A.imp B).allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).allFuture.box) : Γ ⊢[fc] (B.or C).allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- `lrewrite` through 3 nested scope(s): □ G H.
#reprove_record rw3 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def rw3 (mapping : Γ ⊢[fc] (A.imp B).allPast.allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).allPast.allFuture.box) : Γ ⊢[fc] (B.or C).allPast.allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- `lrewrite` through 4 nested scope(s): □ G H □.
#reprove_record rw4 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lrewrite,lexact" escape 0 in
def rw4 (mapping : Γ ⊢[fc] (A.imp B).box.allPast.allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).box.allPast.allFuture.box) : Γ ⊢[fc] (B.or C).box.allPast.allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped

end RewriteLadder

/-! ### The simplifier, at one rule and at two

`lsimp` is the most expensive single step the baseline measures, which matches its bounded-search
design. Both rows are recorded so that the simplifier's cost is separable from the plain
congruence transport above it.
-/

namespace Simplifier

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass} (Γ : Context) (A : Formula)

-- `lsimp only` with one rule and one reduction.
#reprove_record simp1 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lsimp,lexact" escape 0 in
def simp1 (provider : Γ ⊢[fc] A.neg.neg) : Γ ⊢[fc] A := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff] at provider as reduced
  lexact reduced

-- `lsimp only` with two rules and two reductions.
#reprove_record simp2 stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lsimp,lexact" escape 0 in
def simp2 (provider : Γ ⊢ A.neg.neg.someFuture.someFuture) : Γ ⊢ A.someFuture := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff,
    FormalSystem.Theorems.ProofMode.futureCollapse] at provider as reduced
  lexact reduced

end Simplifier

/-! ### The views tier

A views-tier step produces the same judgment up to definitional equality or a cast. These two rows
are what the per-tier table's views column is measured from, and the contrast with the derivation
rows above is the tier separation the architecture record asserts.

Both rows close with a bare `exact`, because `lexact` matches a judgment rather than a
definitional equality; they are recorded as term-mode escapes for that reason, with the escape
being the single local hypothesis.
-/

namespace Views

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass} (Γ : Context) (A : Formula)

-- `lfold` at a hypothesis.
#reprove_record viewFold stage "reprove" outcome "closed_with_term_escape"
  failure "missing_tactic" tactics "lfold,exact" escape 1 in
def viewFold (provider : Γ ⊢[fc] A.neg.box.neg) : Γ ⊢[fc] A.diamond := by
  lfold diamond at provider
  exact provider

-- `lfold` at a hypothesis, then `lunfold` at the goal.
#reprove_record viewFoldUnfold stage "reprove" outcome "closed_with_term_escape"
  failure "missing_tactic" tactics "lfold,lunfold,exact" escape 1 in
def viewFoldUnfold (provider : Γ ⊢[fc] A.neg.box.neg) : Γ ⊢[fc] A.diamond := by
  lfold diamond at provider
  lunfold diamond
  exact provider

end Views

end ProofModeCostBaseline
