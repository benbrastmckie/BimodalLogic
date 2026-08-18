/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel

/-!
# Region-gate probes: measuring the region labelling before it is stated

Phase 7's gap obligation has been restated three times and machine-refuted three times
(`GapDemands` vacuous, the two endpoint-copy policies, then `GapAdequate` itself — see
`Verified/Bridge/Valuation.lean`). The surviving route assigns each **region** of the carrier
the atom content of a **chosen known branch label**, certified by a decidable branch-level
gate in the family `timeOrderTotal` and `boxAnchoredCheck` already belong to.

This file measures that gate on branches the engine actually builds, *before* any of it is
stated in `Verified/`. It is the answer to the process lesson three dispatches paid for: an
interface reasoned about in prose, and proved about only afterwards, has been wrong every
time so far.

## What a region is, and what it is owed

Write `t₀ < t₁ < … < t_{n-1}` for the branch's own times in the branch's own order (the order
`timeOrderTotal` certifies is linear). The carrier places exactly those `n` points, so its
non-placed points fall into `n + 1` **regions**: the lower ray below `t₀`, the interior gaps
between consecutive placed times, and the upper ray above `t_{n-1}`. Region `j` sits strictly
above every branch time of rank `< j` and strictly below every branch time of rank `≥ j`.

Region `j` of world `w` is owed, at every one of its points:

| Source | Side | Demand |
|---|---|---|
| `T(□χ)` anywhere on the branch | positive | `χ` |
| `F(◇χ)` anywhere on the branch (i.e. `□¬χ`) | negative | `χ` |
| `T(U(φ,ψ))` at a label of `w` of rank `< j` | positive | `ψ` |
| `T(S(φ,ψ))` at a label of `w` of rank `≥ j` | positive | `ψ` |
| `F(U(φ,ψ))` at a label of `w` of rank `< j` | negative | `φ` |
| `F(S(φ,ψ))` at a label of `w` of rank `≥ j` | negative | `φ` |

The last two are the additions this probe makes over the two in report 07, and they subsume
report 07's `G`/`H` demands rather than sitting beside them: `G χ` is `(U(¬χ, ⊤)) → ⊥`, so on
a saturated branch `T(Gχ)` at a label appears as `F(U(¬χ, ⊤))` at that label, and the row
above with `ψ = ⊤`, `φ = ¬χ` is exactly "`χ` is demanded above". The `T(U(·,·))`/`T(S(·,·))`
rows are the `untl`/`snce` **straddling guard** conditions, the other addition: an until
asserted below the region whose witness lies above it needs its guard `ψ` throughout, and the
region is part of "throughout".

## Two deliberate over-approximations

Both make the gate **harder** to pass than the induction will need, so passing it is
informative and failing it would not by itself refute anything:

1. The `T(U(φ,ψ))` row ignores where the witness actually is. An until whose witness lies
   *below* the region imposes nothing on the region, but this probe demands `ψ` anyway.
2. The `F(U(φ,ψ))` row ignores the screening disjunct. `F(U(φ,ψ))` below the region says every
   later point either fails `φ` **or** is screened by an earlier `¬ψ`; this probe demands
   `¬φ` outright.

## The measured verdict

The nine rows split cleanly by world count. **Every two-world row (A, B, C, H) reports
`gate=false`**, with world 1's candidate vector all-zero — A and B at `|T|=4`, C and H at `|T|=6`,
the latter two generating byte-identical strings. **Every single-world row (D, E, F, G, I) reports
`gate=true`.** That split is the finding: the gate turns on whether a freshly minted world receives
a temporal universal, and since the unsound cross-world temporal copies were removed, no minted
world does. See the Re-baseline record below for why row C joining the `gate=false` group is
expected rather than a defect.

On the single-world rows the gate is not vacuously true: `regionGate_refutable` exhibits a
two-label branch on which it is `false`, and even on the passing rows most labels are excluded.
Row E (`Gp → p`) is the shape that discriminated report 07's stationarity probe and it
discriminates here too — its interior regions admit two labels, not three.

## Cost

Each engine row runs `buildTableau` at fuel `200`, on the order of tens of seconds, which is
why this lives in the test library rather than beside the definitions it measures.
-/

/-! ## Re-baseline record — the `trivialEventWitnessed` guard

The `#guard_msgs` expectations marked `RE-BASELINED (guard)` below were moved from their previous
pinned values. **Owner of every such move**: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
`def trivialEventWitnessed`, consulted as a disjunct beside `witnessPresent` in both fresh-label
guards of `findApplicableRule`. It is **not** owned by `Decidability/Saturation.lean` and **not**
by the semantics refactor. The guard stops the engine minting trivial seriality witnesses, so the
time domain stops growing without bound; the shorter time domains and the renumbered downstream
indices below are the direct consequence.

**Evidence — a three-point differential, not an inference.** Each row's value was measured at
three commits, with `#guard_msgs` output captured and compared row by row:

| Point | Commit | Meaning |
|---|---|---|
| P0 | `edcecd551^` (`d49b977c0`) | guard defined but **not consulted** — pre-guard behaviour |
| P1 | `edcecd551` | guard consulted |
| P2 | current `HEAD` | today |

A row was re-baselined **only** when its pinned value equalled its P0 value — i.e. the row was
correct before the guard, so the guard is the sole cause of its present mismatch. Rows whose
pinned value already disagreed with P0 were **already stale before the guard**; those are the
separately-owned mismatches baselined 2026-07-29 against an engine-behaviour change owned outside
this refactor, and they are left pinned, unedited, and enumerated below. Re-baselining them would
absorb that separately-owned change into this attribution, which is exactly what the plan forbids.

The window `edcecd551^ .. HEAD` contains only the guard consultation plus proof-body-only edits to
three files (`CountermodelExtraction.lean`, `Verified/Bridge/TemporalSaturation.lean`,
`Verified/Termination/MintBound.lean`); those diffs add and remove no `def`, `abbrev`, `instance`,
`structure`, or `inductive` line at all, so no `#eval` here can have moved because of them. This is
corroborated directly in `TableauConformance.lean`, whose P1 and P2 values are identical on every
row.

**Re-baselined in this file** (guard-attributed): rows A and B — each carrying its own
`RE-BASELINED (guard)` note with the old and new value.

**SETTLED — re-recorded from the generated values**: 2 rows, C and H (both `.Dense`).

Rows C and H were members of the ten pre-existing, separately-declined mismatches, identified at
row level for the first time by the P0 measurement above: for each, the pinned value, the pre-guard
(P0) value and the current (P2) value were three *different* values, so the row was already stale
before the guard **and** the guard moved it again. Both were left pinned for as long as
re-recording them would have folded a separately-owned engine change into this refactor's
re-baseline. That is no longer a risk, because the attribution below is stated rather than
absorbed, so both are now re-recorded:

* row C — `probe (.imp (andF (.box p) (dia q)) r) 200 .Dense`
  - pinned, before this settlement: `info: "OPEN |W|=2 |T|=8 total=true gate=true check=true cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3], [1, 1, 1, 1, 1, 1, 1, 1, 1]]"`
  - P0 pre-guard: `info: "OPEN |W|=2 |T|=10 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]"`
  - recorded now: `info: "OPEN |W|=2 |T|=6 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0]]"`
* row H — `probe (.imp (andF (.box p) (dia (.allFuture q))) r) 200 .Dense`
  - pinned, before this settlement: `info: "OPEN |W|=2 |T|=10 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]"`
  - P0 pre-guard: `info: "OPEN |W|=2 |T|=9 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [1, 1, 1, 0, 0, 0, 0, 0, 0, 0]]"`
  - recorded now: `info: "OPEN |W|=2 |T|=6 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0]]"`

Rows C and H now generate the *same* string. That is a measurement, not a copy-paste error: under
`.Dense` the `◇(G q)` shape no longer forces mints that `◇q` does not.

**Attribution.** Both moves belong to the 2026-08-10/11 engine window — the semantics refactor
together with the tableau-engine work that rewrote `Decidability/Tableau.lean` and
`Decidability/Saturation.lean` and added `Verified/Termination/MintBound.lean`. They are **not**
owned by `trivialEventWitnessed`, which is the separately-owned change the original exclusion
existed to protect: the guard's contribution to these rows is the P0 → pinned step, not the
pinned → current one. Re-recording here therefore does not absorb the guard's move into a later
attribution.

**Stability.** The two `P2 current` values measured on 2026-08-11 and recorded above are
byte-identical to what Lean generates today. Zero drift across that window, so this settles
recorded debt against a stable measurement rather than baselining against a moving one.

**Row C's gate loss is expected behaviour, not a defect.** Four things establish that, and none of
them is new:

1. The gate is a *declared* over-approximation. "Two deliberate over-approximations" above states
   it is made **harder** to pass than the induction will need, "so passing it is informative and
   failing it would not by itself refute anything". Row C failing sits inside the module's own
   declared tolerance.
2. The cause is already documented and already pinned by three sibling rows. The unsound
   cross-world temporal copies were the only route by which a `T(Gφ)`/`T(Hφ)` reached a freshly
   minted world; with them gone a minted world receives none. Rows A, B and H — every other
   two-world row here — already pinned `gate=false` with world 1 all-zero for exactly that reason.
   Row C was the last two-world holdout and has simply joined the group its siblings occupy.
3. The resulting rule is uniform and checkable: every two-world row (A, B, C, H) now reports
   `gate=false` with world 1 all-zero, and every single-world row (D, E, F, G, I) reports
   `gate=true`. That uniformity is a better statement of the finding than "one row keeps its gate"
   ever was.
4. The probe's designed cross-check still holds. `gate` is probe-computed and `check` is
   library-computed; agreement between them is the invariant, and the shared value is only the
   measurement. On row C both moved to `false` together, so the self-consistency this module exists
   to measure is unbroken.
-/

namespace BimodalTest.RegionGateProbe

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge

private def p : Formula := .atom (Atom.mkBase "p")
private def q : Formula := .atom (Atom.mkBase "q")
private def r : Formula := .atom (Atom.mkBase "r")

/-- `◇A`, in the engine's encoding. -/
private def dia (A : Formula) : Formula := .imp (.box (.imp A .bot)) .bot

/-- `A ∧ B`, in the engine's encoding. -/
private def andF (A B : Formula) : Formula := .imp (.imp A (.imp B .bot)) .bot

/-! ## The branch's linear order on its own times -/

/-- `t` is strictly before `t'` in the branch's abstract time order. -/
private def ltT (ord : TimeOrdering) (t t' : TimeIndex) : Bool :=
  (ord.futureOf t).contains t'

/-- Rank of `t`: how many branch times lie strictly below it. On a branch where
`timeOrderTotal` holds this is a bijection onto `0, …, n-1`, and it is what indexes regions. -/
private def rankOf (b : Branch) (ord : TimeOrdering) (t : TimeIndex) : Nat :=
  (b.knownTimes.filter fun s => ltT ord s t).length

/-! ## Per-region demands -/

/-- `T(χ)` demanded at every point of every region: the box content. -/
private def boxPosDemands (b : Branch) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .pos, .box c => some c
    | _, _ => none

/-- `F(χ)` demanded at every point of every region: `F(◇χ)` is `□¬χ`. -/
private def boxNegDemands (b : Branch) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .neg, .imp (.box (.imp c .bot)) .bot => some c
    | _, _ => none

/-- Positive demands at region `j` of world `w`: the box content, plus the `untl`/`snce`
straddling guards. See the module docstring's table and over-approximation 1. -/
private def posDemands (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) :
    List Formula :=
  boxPosDemands b ++ b.filterMap fun sf =>
    if sf.sign == .pos && sf.label.world == w then
      let rk := rankOf b ord sf.label.time
      match sf.formula with
      | .untl ψ _ => if rk < j then some ψ else none
      | .snce ψ _ => if j ≤ rk then some ψ else none
      | _ => none
    else none

/-- Negative demands at region `j` of world `w`. Subsumes report 07's `G`/`H` demands: `T(Gχ)`
is `F(U(¬χ, ⊤))` on a saturated branch. See the docstring's table and over-approximation 2. -/
private def negDemands (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) :
    List Formula :=
  boxNegDemands b ++ b.filterMap fun sf =>
    if sf.sign == .neg && sf.label.world == w then
      let rk := rankOf b ord sf.label.time
      match sf.formula with
      | .untl _ φ => if rk < j then some φ else none
      | .snce _ φ => if j ≤ rk then some φ else none
      | _ => none
    else none

/-- Does `l` state every demand of the region, on the correct side and without stating its
complement? The two-sided form is what makes the check discriminating. -/
private def meets (b : Branch) (l : Label) (pos neg : List Formula) : Bool :=
  pos.all (fun c => b.hasPosAt c l && !(b.hasNegAt c l)) &&
  neg.all (fun c => b.hasNegAt c l && !(b.hasPosAt c l))

/-- The labels of world `w` eligible to be region `j`'s state. -/
private def candidates (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) :
    List Label :=
  let pos := posDemands b ord w j
  let neg := negDemands b ord w j
  (b.knownTimes.map fun t => (⟨w, t⟩ : Label)).filter fun l => meets b l pos neg

/-- Candidate counts, world-major: one inner list per known world, one entry per region, in
region order (lower ray first, upper ray last). -/
private def candidateGrid (b : Branch) (ord : TimeOrdering) : List (List Nat) :=
  let n := b.knownTimes.length
  b.knownWorlds.map fun w =>
    (List.range (n + 1)).map fun j => (candidates b ord w j).length

/-- **The gate.** Every region of every known world has at least one eligible label. -/
private def regionGate (b : Branch) (ord : TimeOrdering) : Bool :=
  (candidateGrid b ord).all fun row => row.all fun c => c > 0

/-- Run the engine and report the gate on the resulting open branch.

`gate` is this file's own copy, written before `Bridge/RegionLabel.lean` existed; `check` is the
library's `regionLabelCheck`. Reporting both on every row makes the two an independent
cross-check of each other, so a later edit to either that changes what is being measured shows
up as a disagreement rather than silently. -/
def probe (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob ord _ _) =>
      s!"OPEN |W|={ob.knownWorlds.length} |T|={ob.knownTimes.length} " ++
      s!"total={timeOrderTotal ob ord} gate={regionGate ob ord} " ++
      s!"check={regionLabelCheck ob ord} cands={candidateGrid ob ord}"

/-! ## Non-vacuity: a branch the gate rejects

Before reading any `gate=true` below, note that the gate *can* be `false`. The branch here
carries `T(G q)` in its saturated form `F(U(¬q, ⊤))` at the earlier of two times, and no
label states `F(¬q)`. Every region above rank 0 therefore has no eligible label. The branch
is otherwise consistent — it is not closed, and `q` is simply never mentioned positively —
which is the point: the gate is a condition on the branch, and this branch fails it. -/

private def refuteTimes : TimeOrdering := { constraints := [(0, 1)] }

/-- `T(G q)` at `(0,0)` in the form a saturated branch carries it, with `T(p)` at both times
and nothing about `q` anywhere else. -/
private def refuteBranch : Branch :=
  [ SignedFormula.neg (.untl .top (.imp q .bot)) ⟨0, 0⟩
  , SignedFormula.pos p ⟨0, 0⟩
  , SignedFormula.pos p ⟨0, 1⟩ ]

/-- info: "total=true gate=false check=false cands=[[2, 0, 0]]" -/
#guard_msgs in
#eval s!"total={timeOrderTotal refuteBranch refuteTimes} " ++
  s!"gate={regionGate refuteBranch refuteTimes} " ++
  s!"check={regionLabelCheck refuteBranch refuteTimes} " ++
  s!"cands={candidateGrid refuteBranch refuteTimes}"

/-! ## The rows

Six shapes at `.Base` matching report 07's stationarity and region-fill probes row for row,
then three at `.Dense`. Read each as: the branch's time order is total, and the per-region
counts show which labels the demands exclude.

**The two-world rows (A, B, C, H) moved** when the unsound cross-world temporal copies were
deleted from `.boxNeg`/`.diamondPos`. The minted world's regions lose their eligible labels
because it no longer receives any `T(G·)`/`T(H·)`, so `gate` and `check` go false and its
candidate vector collapses to zeros. `total` is unmoved throughout — the deletion did not
disturb the time order, only the minted world's formula content. The single-world rows (D, E, F,
G, I) are entirely unmoved. See `BoxNegPreservationProbe.lean` row 3 for the soundness
measurement and `Verified/Bridge/BoxSaturation.lean`'s `BoxAnchored` rationale for the
consequence. -/

-- A. The minimal witness: one box, one diamond, an unrelated consequent.
-- Was `gate=true check=true` with world 1's vector `[3, 3, 3, 3, 3, 3, 3, 3]`.
-- RE-BASELINED (guard): was `"OPEN |W|=2 |T|=7 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0]]"`;
-- now `"OPEN |W|=2 |T|=4 total=true gate=false check=false cands=[[3, 3, 3, 3, 3], [0, 0, 0, 0, 0]]"`. Owner: `trivialEventWitnessed` — see the Re-baseline record above.
/-- info: "OPEN |W|=2 |T|=4 total=true gate=false check=false cands=[[3, 3, 3, 3, 3], [0, 0, 0, 0, 0]]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r)

-- B. The witness world carries a temporal universal of its own. Its regions used to fall to a
-- single eligible label from rank 4 up — the `G q` in the minted world biting. That `T(G q)`
-- reached the minted world only via the deleted copy, so the row now collapses to A's: no
-- eligible label anywhere in world 1.
-- Was `gate=true check=true` with world 1's vector `[3, 3, 3, 3, 1, 1, 1, 1]`.
-- RE-BASELINED (guard): was `"OPEN |W|=2 |T|=7 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0]]"`;
-- now `"OPEN |W|=2 |T|=4 total=true gate=false check=false cands=[[3, 3, 3, 3, 3], [0, 0, 0, 0, 0]]"`. Owner: `trivialEventWitnessed` — see the Re-baseline record above.
/-- info: "OPEN |W|=2 |T|=4 total=true gate=false check=false cands=[[3, 3, 3, 3, 3], [0, 0, 0, 0, 0]]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r)

-- C. The same shape under `.Dense`, where the density rules mint further times. `|T|` is now `6`
-- and world 1's per-region count falls all the way to `0`, so the gate goes with it: this row has
-- joined A, B and H, and every two-world row in the file now reports `gate=false`. C and H
-- generate identical strings. Was `|T|=10` with both vectors all-`3`, then `|T|=8` with world 1
-- all-`1` and the gate still passing. See the Re-baseline record above for why this is expected.
/-- info: "OPEN |W|=2 |T|=6 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0]]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r) 200 .Dense

-- D. The shape that refutes `GapAdequate` (`gapAdequate_insufficient`). Every region has
-- three eligible labels, which is the concrete form of report 07's argument that a *label's*
-- content is propositionally closed where a *forced set* is not.
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 3, 3, 3]]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (.box (.imp p q))) r)

-- E. `G p → p`, report 07's discriminating row: the interior regions admit two labels, not
-- three, because a label carrying `T(G p)` without `T(p)` is ineligible above rank 0.
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 2, 2, 2]]" -/
#guard_msgs in
#eval probe (.imp (.allFuture p) p)

-- F. `¬(F p → p)`.
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 2, 2, 2]]" -/
#guard_msgs in
#eval probe (.imp (.imp (Formula.someFuture p) p) .bot)

-- G. Row E under `.Dense`: one more minted time, same discrimination.
/-- info: "OPEN |W|=1 |T|=5 total=true gate=true check=true cands=[[3, 3, 2, 2, 2, 2]]" -/
#guard_msgs in
#eval probe (.imp (.allFuture p) p) 200 .Dense

-- H. Row B under `.Dense`. The single-candidate stretch was the deleted copy's `T(G q)` biting;
-- with the copy gone world 1 has no eligible label at any rank. `|T|` is now `6`, the same as row
-- C, and the two rows generate identical strings — the `◇(G q)` shape no longer forces density
-- mints that `◇q` does not.
-- Was `gate=true check=true` with world 1's vector `[3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1]`.
/-- info: "OPEN |W|=2 |T|=6 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0]]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r) 200 .Dense

-- I. Row F under `.Dense`.
/-- info: "OPEN |W|=1 |T|=4 total=true gate=true check=true cands=[[3, 3, 2, 2, 2]]" -/
#guard_msgs in
#eval probe (.imp (.imp (Formula.someFuture p) p) .bot) 200 .Dense

end BimodalTest.RegionGateProbe
