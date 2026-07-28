/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Saturation
import FormalSystem.Metalogic.Decidability.Tableau

/-!
# Tableau Conformance Corpus

An executable regression corpus for the tableau calculus in
`FormalSystem/Metalogic/Decidability/`. Every row records the verdict the engine
*currently* produces alongside the verdict semantics *requires*; rows where the two
disagree are marked `[DEFECT]` and are the corpus's record of the outstanding
calculus defects.

## Why a corpus and not a `lake build` check

A sorry-free green build is not adequacy evidence for a tableau calculus: a calculus can
be perfectly well-typed, terminate, and still answer OPEN on a valid formula. The only
evidence that the *rules* are adequate is executable: run the engine on formulas whose
semantic status is settled and compare.

## Which validity notion each class targets

The engine is parameterised by `FrameClass`. Each class's corpus is scored against a
different semantic target (`FormalSystem/Semantics/Validity.lean`):

| `FrameClass` | Semantic target | Carrier the bridge will use |
|---|---|---|
| `.Base` | `⊨ φ` (`valid`, all linear TM frames) | ℚ |
| `.Dense` | `ValidDense φ` | ℚ |
| `.Discrete` | `ValidDiscrete φ` | ℤ |
| `.Dedekind` | `ValidDedekindDense φ` (dense *and* conditionally complete) | ℝ |

Consequently the same formula can legitimately carry different targets in different
tables: `F p → F F p` is invalid over an arbitrary linear order and over ℤ, but valid
over any dense order, so it targets OPEN at `.Base`/`.Discrete` and CLOSED at
`.Dense`/`.Dedekind`.

## Verdict vocabulary

`verdict` reduces `buildTableau` to a `String`, deliberately:

- `CLOSED` — `buildTableau` returned `.allClosed`; the engine claims validity.
- `OPEN` — `buildTableau` returned `.hasOpen`; the engine claims a countermodel.
- `STALLED` — `buildTableau` returned `none`: fuel exhausted, or the post-blocking pass
  left the branch unsaturated. At the `DecisionResult` level this is `.fuelExhausted`,
  which R7 split off from `.extractionFailed` (a closed tableau whose proof term could not
  be reconstructed); the tableau-level adapter never sees the latter, since it reads
  `buildTableau` before extraction is attempted.

The adapter returns a `String` rather than using `decide`/`native_decide`/`rfl` because
the tableau is fuel-driven: a kernel-level decision procedure over it either stalls on
the fuel loop or forces whnf of an enormous term. `#guard_msgs in #eval` compares the
*printed* verdict table instead, which costs one interpreter run per class.

## How to use this file

Every table is pinned with `#guard_msgs`. Any change to the calculus that moves a verdict
breaks this file's build. That is the point: the expected block must then be updated in
the same commit as the calculus change, with the flip justified. Rows currently marked
`[DEFECT]` are *expected-current-failure* rows scheduled to flip; a row losing its
`[DEFECT]` marker is progress, a row gaining one is a regression.
-/

namespace BimodalTest.TableauConformance

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.Metalogic.Decidability

/-! ## Formula vocabulary -/

private def p : Formula := .atom (Atom.mkBase "p")
private def q : Formula := .atom (Atom.mkBase "q")
private def tp : Formula := Formula.top
private def F (φ : Formula) : Formula := Formula.someFuture φ
private def G (φ : Formula) : Formula := Formula.allFuture φ
private def P (φ : Formula) : Formula := Formula.somePast φ
private def H (φ : Formula) : Formula := Formula.allPast φ
private def nt (φ : Formula) : Formula := Formula.neg φ
private def im (φ ψ : Formula) : Formula := Formula.imp φ ψ
private def an (φ ψ : Formula) : Formula := Formula.and φ ψ
private def orr (φ ψ : Formula) : Formula := Formula.or φ ψ
private def U (e g : Formula) : Formula := Formula.untl e g
private def S (e g : Formula) : Formula := Formula.snce e g

/-- `F^n φ`. Used by the `F q → F^k ⊤` seriality-iteration family. -/
private def iterF : Nat → Formula → Formula
  | 0, φ => φ
  | n + 1, φ => F (iterF n φ)

/-! ## Corpus row type and verdict adapter -/

/--
Fuel used by the whole corpus.

Fixed rather than `soundFuel`, for two reasons. First, `soundFuel` caps at 100000, and a
per-row interpreter run at that bound would make this file the slowest in the test suite
for no gain — the rows that stall here stall for structural reasons (a missing rule, so
the branch can never saturate), which more fuel does not fix; the audit confirmed this by
re-running counterexample A at fuel 100000 and getting the same `none`. Second, a fixed
bound keeps the table's `STALLED` entries comparable across commits, which a
formula-dependent bound would not.

**Per-row override.** `Row.fuel` defaults to this bound; a row that genuinely needs more
states its own. `expandBranchWithFuel` splits its fuel proportionally across the branches
of a split, so `orderTrichotomy`'s three-way split divides the budget available to
everything below it, and counterexample B needs roughly 10000 to close (measured: `STALLED`
at 200, 500, 2000, 3000, 4000 and 6000; `CLOSED` at 10000). Raising the *corpus-wide*
bound to 10000 instead was tried and rejected: several rows that answer `OPEN` today
explore for minutes at that bound, which would make this file the slowest in the suite for
no gain on any row but the one.
-/
def conformanceFuel : Nat := 200

/-- One conformance row: a formula, the verdict semantics requires, and a note. -/
structure Row where
  /-- Short stable identifier, used as the row label in the printed table. -/
  id : String
  /-- The formula handed to `buildTableau`. -/
  formula : Formula
  /-- The verdict required by the semantic target of the class this row is listed under. -/
  target : String
  /-- Human-readable justification of `target`, or the defect the row witnesses. -/
  note : String
  /-- Fuel for this row. Defaults to `conformanceFuel`; see its docstring for when and why
  a row overrides it. -/
  fuel : Nat := conformanceFuel



/--
Reduce `buildTableau` to a printable verdict. See the module docstring.

**Relation to the `DecisionResult` vocabulary (R7).** The adapter reads `buildTableau`
directly rather than `decide`, so it sees the tableau outcome before proof-term extraction is
attempted. The three verdicts therefore line up with the post-R7 constructors as follows:
`CLOSED` is the tableau-level witness of validity — `decide` turns it into either `.valid`
(term reconstructed) or `.extractionFailed` (term not reconstructed), and the corpus
deliberately does not distinguish those, because a row's semantic target is about the
calculus, not about the proof-extraction pipeline. `OPEN` corresponds to `.invalid`.
`STALLED` corresponds to `.fuelExhausted` and is the *only* verdict here that means the
engine decided nothing — which is exactly the honesty property R7 makes statable at the
`DecisionResult` level.
-/
def verdict (φ : Formula) (fc : FrameClass) (fuel : Nat := conformanceFuel) : String :=
  match buildTableau φ fuel fc with
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen _ _ _ _) => "OPEN"
  | none => "STALLED"

/-- Right-pad to `n` characters so the printed table's columns line up. -/
private def pad (s : String) (n : Nat) : String :=
  s ++ String.ofList (List.replicate (n - s.length) ' ')

/-- Run one row and render it, appending a `[DEFECT]` marker when the engine disagrees
with the semantic target. -/
def runRow (fc : FrameClass) (r : Row) : String :=
  let v := verdict r.formula fc r.fuel
  let marker := if v == r.target then "        " else s!"[DEFECT] "
  s!"{pad r.id 18} {pad v 8} target={pad r.target 7} {marker}{r.note}"

/-- Render the whole corpus for one frame class. -/
def report (fc : FrameClass) (rows : List Row) : String :=
  rows.foldl (fun acc r => acc ++ runRow fc r ++ "\n") ""

/-! ## Shared rows

Rows whose semantic target is the same for every frame class. Class-specific targets
(currently only `F p → F F p`) and class-specific formulas live in the per-class sections
below.
-/

/-- Report 02 §2.1 controls: formulas whose engine verdict was independently confirmed
correct during the adversarial probe. They exist to catch a repair that "fixes" a defect
row by breaking something that already worked. -/
def controlRows : List Row :=
  [ { id := "C1 p->p",       formula := im p p,     target := "CLOSED"
    , note := "propositional tautology" }
  , { id := "C2 p",          formula := p,          target := "OPEN"
    , note := "atom is satisfiable and not valid" }
  , { id := "C3 Gp->p",      formula := im (G p) p, target := "OPEN"
    , note := "G is strict: t is not in its own future" }
  , { id := "C5 K_G",        formula := im (G (im p q)) (im (G p) (G q))
    , target := "CLOSED", note := "K axiom for G" }
  ]

/-- The five seriality/dual probes carried over from the cslib tableau survey (03 §6).
All five are valid here: `serial_future`/`serial_past` (`Axioms.lean:113,117`) are
axioms of the system, so `F⊤` and `P⊤` are theorems and the rest follow.

The engine answers OPEN on all five. This is the same failure mode the cslib survey
recorded as its headline anti-lesson: a sorry-free, build-green tableau that answers OPEN
on `F⊤`. The calculus has no rule that manufactures a successor time from nothing, so a
branch containing only `F(F⊤)` saturates with no successor ever created. -/
def serialityRows : List Row :=
  [ { id := "S1 F-top",      formula := F tp,       target := "CLOSED"
    , note := "serial_future; no rule creates the required successor" }
  , { id := "S2 not-G-bot",  formula := nt (G Formula.bot), target := "CLOSED"
    , note := "dual of S1" }
  , { id := "S3 Gp->Fp",     formula := im (G p) (F p), target := "CLOSED"
    , note := "seriality turns the universal into an existential" }
  , { id := "S4 Hp->Pp",     formula := im (H p) (P p), target := "CLOSED"
    , note := "past dual of S3" }
  , { id := "S5 P-top",      formula := P tp,       target := "CLOSED"
    , note := "serial_past" }
  ]

/-- The `F q → F^k ⊤` family, `k = 0..6`. Every member is valid (`F^k ⊤` is a theorem by
iterating `serial_future`). The family is a graded probe: it isolates *how far* the engine
can chain future steps before the missing transitive/seriality machinery bites. `k = 0, 1`
close; `k ≥ 2` do not. -/
def seriesRows : List Row :=
  (List.range 7).map fun k =>
    { id := s!"K{k} Fq->F^{k}-top"
    , formula := im (F q) (iterF k tp)
    , target := "CLOSED"
    , note := s!"F^{k}(top) is a theorem by iterated seriality" }

/-- The two machine-produced counterexample branches from the adversarial probe. Both
formulas are valid over any linear order, both produced an open branch satisfied by no
linear model, and each is the direct regression target of one calculus repair.

Row A now closes: transitive `futureOf` gives `G p @ t0` its reach to `t2`, and genuine
blocking lets the branch reach a verdict at all instead of being handed back as
"blocked open". Row B now closes too: `orderTrichotomy` splits on the relative order of the
two incomparable fresh times, syntactically as the `temp_linearity` disjuncts, and the three
resulting branches close — two against a negated disjunct directly, the third through the
ordinary `someFutureNeg`/conjunction machinery, which is why a single orientation of the
pair suffices even though row B's disjuncts are a permutation drawn from both orientations.
Row B carries a raised `fuel`; see `conformanceFuel`. -/
def counterexampleRows : List Row :=
  [ { id := "A Gp->GGp",     formula := im (G p) (G (G p)), target := "CLOSED"
    , note := "was D1; closes now that futureOf is a transitive closure" }
  , { id := "B lin-perm"
    , formula := im (an (F p) (F q))
        (orr (F (an p (F q))) (orr (F (an p q)) (F (an q (F p)))))
    , target := "CLOSED"
    , note := "was D2; closes now that orderTrichotomy splits on the witness order"
    , fuel := 10000 }
  ]

/-- Until/Since linearity rows plus the exact axiom instances the permuted counterexample
B is a rearrangement of. These close today. Their role is to pin the syntax-sensitivity
finding: the *exact* disjunct order of `temp_linearity` closes while the logically
equivalent permutation (row B) does not, which is evidence that closure here comes from
matching rather than from a real linearity argument. A repair that makes B close must
leave these CLOSED. -/
def untilSinceRows : List Row :=
  [ { id := "BX11 lin-fut"
    , formula := im (an (F p) (F q))
        (orr (F (an p q)) (orr (F (an p (F q))) (F (an (F p) q))))
    , target := "CLOSED", note := "temp_linearity, exact axiom disjunct order" }
  , { id := "BX11' lin-past"
    , formula := im (an (P p) (P q))
        (orr (P (an p q)) (orr (P (an p (P q))) (P (an (P p) q))))
    , target := "CLOSED", note := "temp_linearity_past, exact axiom disjunct order" }
  , { id := "BX10 U->F",     formula := im (U p q) (F p), target := "CLOSED"
    , note := "until_F" }
  , { id := "BX10' S->P",    formula := im (S p q) (P p), target := "CLOSED"
    , note := "since_P" }
  , { id := "BX7 lin-until"
    , formula := im (an (U p tp) (U q tp))
        (orr (orr (U (an p q) (an tp tp)) (U (an p tp) (an tp tp))) (U (an tp q) (an tp tp)))
    , target := "CLOSED", note := "linear_until instance" }
  , { id := "BX7' lin-since"
    , formula := im (an (S p tp) (S q tp))
        (orr (orr (S (an p q) (an tp tp)) (S (an p tp) (an tp tp))) (S (an tp q) (an tp tp)))
    , target := "CLOSED", note := "linear_since instance" }
  ]

/-- `F p → F F p`, the one shared formula whose target genuinely varies by class: invalid
over an arbitrary linear order and over ℤ, valid over any dense order. -/
def densityProbe (target : String) (note : String) : Row :=
  { id := "C4 Fp->FFp", formula := im (F p) (F (F p)), target := target, note := note }

/-! ## Per-class corpora -/

/-- `.Base`, scored against `⊨ φ` (all linear TM frames). -/
def baseRows : List Row :=
  controlRows ++ [densityProbe "OPEN" "no density over an arbitrary linear order"]
    ++ serialityRows ++ seriesRows ++ counterexampleRows ++ untilSinceRows

/-- `.Dense`, scored against `ValidDense φ`. -/
def denseRows : List Row :=
  controlRows ++ [densityProbe "CLOSED" "density: a time strictly between t and the witness"]
    ++ serialityRows ++ seriesRows ++ counterexampleRows ++ untilSinceRows

/-- The Discrete-class successor probe. `prior_UZ` (`F φ → U(φ, ¬φ)`, the integer
well-ordering Prior axiom) is valid at `.Discrete`: on ℤ a nonempty future φ-region has a
least element, and everything strictly between now and it satisfies `¬φ`. -/
def discreteExtraRows : List Row :=
  [ { id := "Z1 priorUZ",    formula := im (F p) (U p (nt p)), target := "CLOSED"
    , note := "prior_UZ: least future witness exists on the integers" }
  , { id := "Z2 priorSZ",    formula := im (P p) (S p (nt p)), target := "CLOSED"
    , note := "prior_SZ: greatest past witness exists on the integers" }
  ]

/-- `.Discrete`, scored against `ValidDiscrete φ`. -/
def discreteRows : List Row :=
  controlRows ++ [densityProbe "OPEN" "ZZ is not dense: no time strictly between t and t+1"]
    ++ serialityRows ++ seriesRows ++ counterexampleRows ++ untilSinceRows
    ++ discreteExtraRows

/-- The three Dedekind axiom instances. `allRulesForFC` now has a `dedekindRules` arm
(`priorUGap`, `priorSGap`, `sepRule`), and all three close. `kPlus`/`kMinus` are Reynolds'
`K⁺`/`K⁻` (`Formula.lean:180,193`), which those three rules are the only consumers of.

Each rule triggers on its axiom's antecedent *conjunction* and adds the consequent
persistently, so a row closes by contradiction between the added consequent and the negated
consequent the row's implication puts on the branch. That is a faithful transcription of the
axiom, not a proof of it: the admissibility burden — that the rule is derivable in the
Hilbert system — is Track B's, deliberately deferred. -/
def dedekindExtraRows : List Row :=
  [ { id := "R1 prior-U-gap"
    , formula := im (an (U tp p) (F (nt p))) (U (orr (nt p) (Formula.kPlus (nt p))) p)
    , target := "CLOSED", note := "prior_U_gap; discharged by the priorUGap rule" }
  , { id := "R2 prior-S-gap"
    , formula := im (an (S tp p) (P (nt p))) (S (orr (nt p) (Formula.kMinus (nt p))) p)
    , target := "CLOSED", note := "prior_S_gap; discharged by the priorSGap rule" }
  , { id := "R3 sep"
    , formula := im (an (Formula.kPlus p) (nt (Formula.kPlus (an p (U p (nt p))))))
        (Formula.kPlus (an (Formula.kPlus p) (Formula.kMinus p)))
    , target := "CLOSED", note := "sep; discharged by the sepRule rule" }
  ]

/-- `.Dedekind`, scored against `ValidDedekindDense φ` — dense *and* conditionally
complete, which is why the density probe targets CLOSED here as it does at `.Dense`. -/
def dedekindRows : List Row :=
  controlRows ++ [densityProbe "CLOSED" "ValidDedekindDense includes density"]
    ++ serialityRows ++ seriesRows ++ counterexampleRows ++ untilSinceRows
    ++ dedekindExtraRows

/-! ## Pinned verdict tables

Each block below is the engine's current behaviour, pinned. Updating one of these blocks
is only legitimate as part of a commit that changes the calculus and justifies each flip.
-/

/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=OPEN            no density over an arbitrary linear order
S1 F-top           OPEN     target=CLOSED  [DEFECT] serial_future; no rule creates the required successor
S2 not-G-bot       OPEN     target=CLOSED  [DEFECT] dual of S1
S3 Gp->Fp          OPEN     target=CLOSED  [DEFECT] seriality turns the universal into an existential
S4 Hp->Pp          OPEN     target=CLOSED  [DEFECT] past dual of S3
S5 P-top           OPEN     target=CLOSED  [DEFECT] serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     OPEN     target=CLOSED  [DEFECT] F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     OPEN     target=CLOSED  [DEFECT] F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     OPEN     target=CLOSED  [DEFECT] F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     OPEN     target=CLOSED  [DEFECT] F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     OPEN     target=CLOSED  [DEFECT] F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
-/
#guard_msgs in
#eval IO.print (report .Base baseRows)

/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=CLOSED  [DEFECT] density: a time strictly between t and the witness
S1 F-top           OPEN     target=CLOSED  [DEFECT] serial_future; no rule creates the required successor
S2 not-G-bot       OPEN     target=CLOSED  [DEFECT] dual of S1
S3 Gp->Fp          OPEN     target=CLOSED  [DEFECT] seriality turns the universal into an existential
S4 Hp->Pp          OPEN     target=CLOSED  [DEFECT] past dual of S3
S5 P-top           OPEN     target=CLOSED  [DEFECT] serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     OPEN     target=CLOSED  [DEFECT] F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     OPEN     target=CLOSED  [DEFECT] F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     OPEN     target=CLOSED  [DEFECT] F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     OPEN     target=CLOSED  [DEFECT] F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     OPEN     target=CLOSED  [DEFECT] F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
-/
#guard_msgs in
#eval IO.print (report .Dense denseRows)

/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=OPEN            ZZ is not dense: no time strictly between t and t+1
S1 F-top           OPEN     target=CLOSED  [DEFECT] serial_future; no rule creates the required successor
S2 not-G-bot       OPEN     target=CLOSED  [DEFECT] dual of S1
S3 Gp->Fp          OPEN     target=CLOSED  [DEFECT] seriality turns the universal into an existential
S4 Hp->Pp          OPEN     target=CLOSED  [DEFECT] past dual of S3
S5 P-top           OPEN     target=CLOSED  [DEFECT] serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     OPEN     target=CLOSED  [DEFECT] F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     OPEN     target=CLOSED  [DEFECT] F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     OPEN     target=CLOSED  [DEFECT] F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     OPEN     target=CLOSED  [DEFECT] F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     OPEN     target=CLOSED  [DEFECT] F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
Z1 priorUZ         CLOSED   target=CLOSED          prior_UZ: least future witness exists on the integers
Z2 priorSZ         CLOSED   target=CLOSED          prior_SZ: greatest past witness exists on the integers
-/
#guard_msgs in
#eval IO.print (report .Discrete discreteRows)

/--
info: C1 p->p            CLOSED   target=CLOSED          propositional tautology
C2 p               OPEN     target=OPEN            atom is satisfiable and not valid
C3 Gp->p           OPEN     target=OPEN            G is strict: t is not in its own future
C5 K_G             CLOSED   target=CLOSED          K axiom for G
C4 Fp->FFp         OPEN     target=CLOSED  [DEFECT] ValidDedekindDense includes density
S1 F-top           OPEN     target=CLOSED  [DEFECT] serial_future; no rule creates the required successor
S2 not-G-bot       OPEN     target=CLOSED  [DEFECT] dual of S1
S3 Gp->Fp          OPEN     target=CLOSED  [DEFECT] seriality turns the universal into an existential
S4 Hp->Pp          OPEN     target=CLOSED  [DEFECT] past dual of S3
S5 P-top           OPEN     target=CLOSED  [DEFECT] serial_past
K0 Fq->F^0-top     CLOSED   target=CLOSED          F^0(top) is a theorem by iterated seriality
K1 Fq->F^1-top     CLOSED   target=CLOSED          F^1(top) is a theorem by iterated seriality
K2 Fq->F^2-top     OPEN     target=CLOSED  [DEFECT] F^2(top) is a theorem by iterated seriality
K3 Fq->F^3-top     OPEN     target=CLOSED  [DEFECT] F^3(top) is a theorem by iterated seriality
K4 Fq->F^4-top     OPEN     target=CLOSED  [DEFECT] F^4(top) is a theorem by iterated seriality
K5 Fq->F^5-top     OPEN     target=CLOSED  [DEFECT] F^5(top) is a theorem by iterated seriality
K6 Fq->F^6-top     OPEN     target=CLOSED  [DEFECT] F^6(top) is a theorem by iterated seriality
A Gp->GGp          CLOSED   target=CLOSED          was D1; closes now that futureOf is a transitive closure
B lin-perm         CLOSED   target=CLOSED          was D2; closes now that orderTrichotomy splits on the witness order
BX11 lin-fut       CLOSED   target=CLOSED          temp_linearity, exact axiom disjunct order
BX11' lin-past     CLOSED   target=CLOSED          temp_linearity_past, exact axiom disjunct order
BX10 U->F          CLOSED   target=CLOSED          until_F
BX10' S->P         CLOSED   target=CLOSED          since_P
BX7 lin-until      CLOSED   target=CLOSED          linear_until instance
BX7' lin-since     CLOSED   target=CLOSED          linear_since instance
R1 prior-U-gap     CLOSED   target=CLOSED          prior_U_gap; discharged by the priorUGap rule
R2 prior-S-gap     CLOSED   target=CLOSED          prior_S_gap; discharged by the priorSGap rule
R3 sep             CLOSED   target=CLOSED          sep; discharged by the sepRule rule
-/
#guard_msgs in
#eval IO.print (report .Dedekind dedekindRows)

/-! ## Defect-level regression probes

The tables above exercise the whole pipeline, which means a table row can stay red for a
reason unrelated to the repair that was supposed to fix it. The probes below pin the
individual defective components directly, at exactly the inputs the adversarial audit used
to isolate them. Each probe is the acceptance evidence for one repair.
-/

section TransitivityProbe

/-- The time ordering of the machine-produced open branch for `G p → G G p`:
`t0 < t1 < t2`, recorded as two separate `addFuture` calls, hence two direct edges and no
edge from `t0` to `t2`. -/
def ordA : TimeOrdering := { constraints := [(1, 2), (0, 1)] }

-- `futureOf` must reach `t2` from `t0`. Before the transitive-closure repair this was
-- `[1]`, and `someFutureNeg` consequently propagated `F(¬p)` only as far as `t1`, leaving
-- `p` unconstrained at `t2` — the open branch that no linear model satisfies.
/-- info: [1, 2] -/
#guard_msgs in
#eval ordA.futureOf 0

-- From `t1` the closure reaches only `t2`; nothing is invented.
/-- info: [2] -/
#guard_msgs in
#eval ordA.futureOf 1

-- The past direction must be transitive too, symmetrically: `t2` sees both `t1` and `t0`.
-- `allPastPos`/`somePastNeg` consume this.
/-- info: [1, 0] -/
#guard_msgs in
#eval ordA.pastOf 2

-- A time with no incident forward edge has an empty future, and no time is its own
-- ancestor. Guards against a closure that accidentally includes its own argument.
/-- info: true -/
#guard_msgs in
#eval ordA.futureOf 2 == ([] : List TimeIndex) && ordA.pastOf 0 == ([] : List TimeIndex)

-- A cyclic constraint list must terminate rather than run the fuel down: the visited set
-- stops the walk after one lap.
/-- info: true -/
#guard_msgs in
#eval (({ constraints := [(0, 1), (1, 0)] } : TimeOrdering).futureOf 0).length == 2

-- The rule that consumes `futureOf`, at the audit's exact input: `F(F ¬p) @ (w0, t0)` on
-- the counterexample-A ordering must now propagate `F(¬p)` to BOTH `t1` and `t2`. The
-- result is `.persistent` (the source formula is universal, so it is kept), and the
-- propagated labels are the payload.
/-- info: "persistent -> times [1, 2]" -/
#guard_msgs in
#eval
  let sf := SignedFormula.neg (F (nt p)) { world := 0, time := 0 }
  match (applyRule .someFutureNeg sf [] ordA).1 with
  | .persistent fs => s!"persistent -> times {fs.map (fun g : SignedFormula => g.label.time)}"
  | .linear fs => s!"linear -> times {fs.map (fun g : SignedFormula => g.label.time)}"
  | .branching _ => "branching"
  | .notApplicable => "notApplicable"

end TransitivityProbe

section BlockingProbe

/-- The audit's blocking branch: `t0` carries `p`, `t1` carries `q`. The time type at `t1`
is therefore *not* a subset of the type at `t0`, so nothing here licenses blocking `t1`. -/
def b0 : Branch :=
  [ SignedFormula.pos p { world := 0, time := 0 }
  , SignedFormula.pos q { world := 0, time := 1 } ]

/-- The same shape but with `t1`'s type genuinely contained in `t0`'s: both carry `p` and
`t0` additionally carries `q`. This is what real subset blocking looks like. -/
def b1 : Branch :=
  [ SignedFormula.pos p { world := 0, time := 0 }
  , SignedFormula.pos q { world := 0, time := 0 }
  , SignedFormula.pos p { world := 0, time := 1 } ]

/-- The single-edge ordering `t0 < t1` from the audit. -/
def ordB : TimeOrdering := { constraints := [(0, 1)] }

-- `t1`'s only ancestor is `t0`. The pre-repair definition returned `[0, 1]`: it followed
-- the successor edge back and reported `t1` as its own ancestor. Since
-- `isSubsetBlocked b t t` holds reflexively, that alone made every time with an incident
-- constraint "blocked".
/-- info: [0] -/
#guard_msgs in
#eval ancestorTimes ordB 1

-- `t0` has no ancestors at all. Pre-repair this was `[1, 0]` — both the successor and,
-- via the round trip, itself.
/-- info: [] -/
#guard_msgs in
#eval ancestorTimes ordB 0

-- The subset test itself was never the problem and must still say no here.
/-- info: false -/
#guard_msgs in
#eval Branch.isSubsetBlocked b0 1 0

-- The audit's headline probe. Pre-repair this was `true` with `isSubsetBlocked = false`
-- sitting right next to it — blocking firing on a branch it had no grounds to block.
/-- info: false -/
#guard_msgs in
#eval isTemporallyBlocked b0 1 ordB EventualityTracker.empty

-- Blocking must still fire when it is genuinely licensed, otherwise the repair has just
-- turned the predicate off. On `b1` the type at `t1` really is contained in the type at
-- its ancestor `t0`, and there are no pending eventualities, so blocking fires.
/-- info: true -/
#guard_msgs in
#eval isTemporallyBlocked b1 1 ordB EventualityTracker.empty

-- Argument-order regression for the eventuality guard. An unfulfilled Until obligation
-- sits at the *blocked* time `t1` and nowhere else, so blocking must be withheld: `t1`
-- still owes a witness that the ancestor is not carrying. Passing `(t_anc, t_new)` in the
-- wrong order made this `true`, because the ancestor `t0` has nothing pending and the
-- `all` then ranged over an empty list.
/-- info: false -/
#guard_msgs in
#eval
  let tr : EventualityTracker :=
    { pending := [{ formula := U p q, label := { world := 0, time := 1 }, isUntil := true }] }
  isTemporallyBlocked b1 1 ordB tr

-- The converse direction, which the swapped call was accidentally testing: an obligation
-- pending only at the *ancestor* says nothing about whether `t1` may be blocked, so
-- blocking still fires.
/-- info: true -/
#guard_msgs in
#eval
  let tr : EventualityTracker :=
    { pending := [{ formula := U p q, label := { world := 0, time := 0 }, isUntil := true }] }
  isTemporallyBlocked b1 1 ordB tr

-- And the obligation being duplicated at the ancestor is exactly the case the guard is
-- meant to permit: the ancestor will discharge it, so blocking fires.
/-- info: true -/
#guard_msgs in
#eval
  let tr : EventualityTracker :=
    { pending :=
        [ { formula := U p q, label := { world := 0, time := 1 }, isUntil := true }
        , { formula := U p q, label := { world := 0, time := 0 }, isUntil := true } ] }
  isTemporallyBlocked b1 1 ordB tr

end BlockingProbe

end BimodalTest.TableauConformance
