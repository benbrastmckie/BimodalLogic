# Settling the anchor row: budget or non-termination for `(G p) → □(G p)`

**Verdict: hypothesis (a), and it is already realised in the working tree.** The branch
saturates. The fuel ceiling is **25**. `decide` returns `.invalid` and
`getCountermodel?.isSome = true`. The task's premise — `.fuelExhausted`, no countermodel, `none`
at fuel 30/60/400/1000 — describes a state the repository left behind at commit `a6a72d014`
(`task 414 phase 29.2.1`), which re-baselined the anchor rows and attributed the move to
`Tableau.lean`'s `trivialEventWitnessed` guard.

Every number below was measured directly in this session with `lake env lean` on scratch files
against the current working tree (clean under `FormalSystem/` and `Tests/`), not read off the
existing docstrings.

## 1. The primary deliverable — (a) vs (b), settled

### 1.1 Measured verdict on the anchor formula

`φ = (G p) → □(G p)`, `.Base`:

| Probe | Measured |
|---|---|
| `decide φ` | `.invalid` — `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided) = (false, true, false, false, false)` |
| `(decide φ).getCountermodel?.isSome` | `true` |
| `buildTableau φ 1000 .Base` | `.hasOpen` with an open branch of **40** signed formulas |
| `decideAuto φ` (fuel `soundFuel φ = 2048`) | `.invalid`, countermodel `some` |

`ExpandedTableau.hasOpen` is proof-carrying: its fourth field is
`findUnexpanded openBranch (timeOrd := …) (fc := …) = none` (`Saturation.lean:75`). The branch is
therefore genuinely downward-saturated in the ordinary-rule sense, subject only to the
`serialityRule` gap that constructor's own docstring already states. This is a positive
refutation, not a give-up.

### 1.2 The fuel ceiling, bracketed from both sides

`buildTableau φ n .Base` was evaluated at every `n ∈ [0, 40]` and at `45, 50, 60, 80, 100, 200,
400, 1000`:

* `n ≤ 24` → `none`
* `n ≥ 25` → `.hasOpen` with open-branch length **40**, at every value tested, with no further
  movement out to 1000.

**The ceiling is 25, and it is a true fuel ceiling.** Instrumenting the two stages separately:

| fuel | `expandBranchWithFuel` | `findUnexpanded` on its output |
|---|---|---|
| 1, 5, 10, 15, 20, 22, 23, 24 | `none` | — |
| 25, 26, 30 | open, `\|b\| = 37` | `some _` (not yet saturated) |

So at fuel 25 the inner loop first completes, hands back a 37-formula open branch that is blocked
but not saturated, and `buildTableau`'s `saturateBlocked` post-pass carries it the rest of the way
to the certified 40-formula branch. The `none` below 25 is genuine fuel exhaustion inside
`expandBranchWithFuel`; it is not the "still not saturated" arm.

### 1.3 Headroom against the proved bounds

`|subformulaClosure φ| = 8`, so:

| Figure | Value for this φ | Ratio to the measured 25 |
|---|---|---|
| measured ceiling | 25 | 1× |
| `soundFuel φ` (`Saturation.lean:1210`, capped runtime default) | 2 048 | ~82× |
| `soundFuel' φ` (`Fuel.lean:155`, uncapped single-world figure) | 1 048 576 | ~4×10⁴ |
| `worldFuel' φ 1` (`Fuel.lean:2616`, general figure) | ≈ 1.1×10¹² | ~4×10¹⁰ |

Nothing in `Fuel.lean` is falsified or even stressed by this formula. There is no bound to
repair, no non-termination to prove, and no figure to raise. The honest Fuel-side deliverable is
to **record the measured ceiling and its headroom**, not to change a bound.

## 2. The secondary deliverable — the countermodel, and one real caveat

The certified open branch has 2 worlds `{0, 1}` and 6 times `{0 … 5}`, and its atom rows are:

```
T p @ (0,1)    T p @ (0,4)    T p @ (0,5)    F p @ (1,1)
```

together with `T((G p) → ⊥ → …)`-shaped rows pinning `T(G p) @ (0,0)` and
`F(□(G p)) @ (0,0)`. That is exactly the intended semantic refutation: world 0's history carries
`p` throughout its future so `G p` holds at `(0,0)`, while world 1 — a different total history at
the same time — fails `p` at time 1 and so falsifies `G p`, refuting `□(G p)` at `(0,0)`.

**Caveat, and it is real.** The Layer-0 `SimpleCountermodel` that `getCountermodel?` returns
flattens the `(world, time)` label away — `extractTrueAtoms`/`extractFalseAtoms`
(`CountermodelExtraction.lean:81, :92`) filter on sign alone. The returned value is therefore
`trueAtoms = [p, p, p, p, p, p]`, `falseAtoms = [p]`, and `isConsistent = false`. The refutation
is sound; its Layer-0 *presentation* is not a usable valuation. `BoxNegReachabilityProbe.lean`
row 11 already records this and explicitly disclaims ownership of it. `CountermodelExtraction.lean`
is **outside this task's `file_scope`** — recorded here as a finding, not proposed as work.

## 3. The genuinely non-terminating neighbour — `F(G p)` — and why it is not this formula

`Fuel.lean:2256` names `φ = F(G p)` as the witness on which unconditional `buildTableau_isSome`
died. **That witness is still live**, and measuring it sharpens what `Fuel.lean` says:

| fuel | 10 | 25 | 50 | 100 | 200 | 500 | 1000 | 2048 | 4096 |
|---|---|---|---|---|---|---|---|---|---|
| `buildTableau (F (G p)) n .Base` | none | none | none | none | none | none | none | none | none |

`decide (F (G p))` = `.fuelExhausted`, no countermodel. But splitting the stages shows the `none`
is **not fuel exhaustion at all**:

| fuel | 25 | 100 | 500 | 1000 | 2048 | 4096 |
|---|---|---|---|---|---|---|
| `expandBranchWithFuel` | open, `\|b\|=21` | 21 | 21 | 21 | 21 | 21 |
| `findUnexpanded` | `some _` | `some _` | `some _` | `some _` | `some _` | `some _` |

The inner loop *succeeds* at every fuel from 25 upward and returns the **same 21-formula branch**.
The branch is stationary; raising fuel provably cannot change it. `buildTableau` then falls into
its last arm — "still not saturated after the post-blocking pass" (`Saturation.lean:1182`) — and
returns `none`.

The obstruction, read off directly:

* before the post-blocking pass, `findUnexpanded` points at `F(G p) @ (0,4)`;
* after `saturateBlocked` (branch grown to 25), it points at `T(F ¬p) @ (0,4)` — i.e.
  `T(untl ⊤ (p → ⊥))`.

That is an **unfulfilled eventuality at a blocked time**. Blocking has stopped the engine minting
new times, but `untlPos` remains applicable, so the `findUnexpanded … = none` certificate can
never be produced. `trivialEventWitnessed` does not suppress it, and correctly so: that guard
keys on the syntactic `event == Formula.top`, and this event is `¬p`.

**This is hypothesis (b), realised — but on `F(G p)`, not on the anchor formula.** The
distinction the task asked for is therefore not "which of (a) or (b) is true of the engine" but
"which of them is true of *this* formula", and the answer for `(G p) → □(G p)` is unambiguously
(a).

**Secondary finding, out of `file_scope`.** `DecisionProcedure.lean:194` maps every `buildTableau
= none` to `.fuelExhausted`, conflating three distinct routes: fuel exhaustion inside
`expandBranchWithFuel`, the `maxBranches` budget, and the "still not saturated" arm. On `F(G p)`
the reported constructor is `.fuelExhausted` while no fuel was exhausted. The verdict remains
*honest* — `isUndecided` is the right coarse answer — but the constructor name misattributes the
cause, which is exactly the misreading that cost this formula family a full task cycle already.
Recorded for a follow-up task; not proposed here.

## 4. What the two `file_scope` files actually need

### 4.1 `Tests/BimodalTest/CrossWorldPropagationProbe.lean`

**Row F is already correct and already green.** It pins
`(false, true, false, false, false)`, which reproduces exactly. Its own docstring is current. No
`#guard_msgs` value moves.

**The module docstring contradicts row F**, at lines 51-56:

> **Row F is the discrimination rows A-C cannot make** … It records the post-deletion state
> honestly: on `(G p) → □(G p)` the engine no longer wrongly closes, **but neither does it
> positively refute — it exhausts its fuel. A wrong answer became no answer.** That is a strict
> improvement in soundness and an unfinished job on completeness; see the plan's Phase 6 triage.

Every emphasised clause is false of the current engine, and the file's own row F says so eleven
lines further down. This is the concrete in-scope defect. The replacement should state the
three-step history (wrong answer → no answer → right answer), the ceiling of 25, and drop the
dangling "see the plan's Phase 6 triage" pointer, which names no durable anchor.

**Optional strengthening, cheap and well-founded.** Rows A and C — `(¬F p) → □(¬F p)` and
`(¬P p) → □(¬P p)` — were measured this session and *both* now decide `.invalid` with
`getCountermodel?.isSome = true`. They are currently `isValid`-only rows, so they read `false`
under `.invalid`, `.fuelExhausted` and `.extractionFailed` alike — the exact blindness that
motivated row F for row B. Adding constructor-pinning siblings for A and C closes that gap for
the whole A-C family at the cost of two `#eval` rows. This is an addition, not a re-baseline;
it changes no existing pinned value.

### 4.2 `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`

**No theorem, definition, or bound needs to change.** Zero `sorry`s; nothing measured here
contradicts anything proved there. Two documentation deliverables, both empirical:

1. **Record the anchor-row ceiling.** `soundFuel'`'s docstring (`:135-153`) states the figure
   without any measured anchor. Adding "measured: `(G p) → □(G p)` saturates at fuel 25, against
   `soundFuel' = 1 048 576` and `worldFuel' … 1 ≈ 1.1×10¹²`" converts an abstract bound into a
   bound with a witness, and settles this task's (a)-branch obligation ("find and record the
   ceiling") in the file the task scoped it to.

2. **Sharpen the `F(G p)` witness note at `:2256`.** It currently says the refuted unconditional
   `buildTableau_isSome` "died on (`φ = F(G p)`)" and that `resolveOpenArm = none` is "a live
   outcome, not a dead one". Both still hold. What is new and worth stating is *why* it is live
   and why no fuel figure can rescue it: the inner loop reaches a stationary 21-formula branch at
   every fuel ≥ 25 and the residue is an unfulfilled `T(F ¬p)` eventuality at a blocked time. That
   turns a named counterexample into a diagnosed one, and it forecloses the next reader's
   temptation to try raising the figure.

### 4.3 Explicitly out of scope, and why it matters that it is

`Tests/BimodalTest/BoxNegReachabilityProbe.lean` is **not** in `file_scope`, and its rows 9-12 are
already re-baselined and green — but its module docstring (`:64-70`) and row 12's docstring
(`:290-294`) still carry the superseded narrative:

> **But the positive refutation is not here.** … At fuel 1000 it returns neither … rows 11-12
> still pin no countermodel.

and

> this `false` is row 10's constructor — `extractionFailed` then, `fuelExhausted` now — and a
> countermodel neither time.

Both contradict rows 10 and 11 of the same file. This is the identical defect class as §4.1 on the
identical formula. It needs either an explicit `file_scope` extension approved by the user, or a
follow-up task; it should not be fixed silently.

The decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
`regionLabelCheck`, `rayUpOk`/`rayDnOk`) computing `false` on multi-world branches is, per the
task description, a separate concern and was not investigated.

## 5. Prohibition compliance

No change is proposed to `boxNeg` or `diamondPos`, and none is needed: the branch closes nothing
and does not need to. The engine reaches `.invalid` by *saturating an open branch*, which is the
opposite of the deleted temporal-copy behaviour. Reinstating any group-3 block would re-close the
branch and restore the false claim of validity. The finding here strictly confirms the deletion
was correct.

## 6. Zero-debt note

Nothing proposed above requires a `sorry`, an axiom, or a deferral. The scoped work is docstring
realignment plus two optional `#eval` rows, all of which either build green or fail loudly on a
`#guard_msgs` mismatch.

## 7. Reproduction

Each measurement is a scratch `lake env lean` file (~3-5 s each, no `lake build` required — the
`.olean` tree is current at 452 modules). The shape:

```lean
import FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax FormalSystem.Metalogic.Decidability
def p : Formula := .atom (Atom.mkBase "p")
def gp : Formula := Formula.allFuture p
#eval match buildTableau (gp.imp gp.box) 25 .Base with
      | none => "none" | some (.allClosed bs) => s!"closed {bs.length}"
      | some (.hasOpen ob _ _ _) => s!"hasOpen {ob.length}"
```

The two-stage diagnostic that separates fuel exhaustion from the unsaturated arm calls
`expandBranchWithFuel ib fuel TimeOrdering.empty .Base` directly and then `findUnexpanded` on its
`.inr` payload; that is the probe that produced §1.2 and §3 and is the one worth preserving if any
of this is turned into a committed row.
