# Report 05 — The `(G p) → □(G p)` non-termination is a seriality-witness defect, not a blocking defect

- **Task**: 414 — refactor_semantics_to_total_history_validity (phase 22 terminus, follow-up to report 04)
- **Status**: [FINDINGS] — written 2026-08-11
- **Context**: `git log` HEAD is `03c67767f task 414 phase 22.2: retire the Omega architecture from
  the semantics prose`. Input: `reports/04_boxneg-reachability-pathology.md` §4, which named four
  containment directions as *directions, not conclusions*. This report turns them into a verdict.
- **Lean Intent**: false (this report changes no Lean files)
- **Reference grounding tier**: code + definitions-of-record. Every behavioural claim cites a
  `file:line` under `FormalSystem/` or `Tests/BimodalTest/`; every semantic claim cites a
  `\label{...}` anchor in `specs/paper-definitions-of-record.md`.
- **Definitions-of-record gate**: `bash scripts/check-paper-definitions.sh` → **pass** (notice
  only: `possible_worlds.tex` changed, all 26 recorded definitions unchanged).

---

## 1. Executive answer

Report 04's four directions resolve as follows. Three of the four are **rejected**, one on a
measurement that refutes it directly.

| # | Direction (report 04 §4) | Verdict | Fixes the class? |
|---|---|---|---|
| 1 | Witness-first ordering for `boxNeg` + future-eventuality | **Rejected — solves a non-problem.** The countermodel witness is already minted at expansion step 1 and fully decomposed by step 5. Discovery was never the bottleneck. | No |
| 2 | Structural recognition of the `φ → □φ` shape | **Rejected as primary — unsound as stated**, and it fixes one shape rather than the class. | No |
| 3 | Termination / blocking strengthening | **Right diagnosis, wrong lever.** A strengthened *blocking* predicate does not help (measured: a label-aware predicate blocks nothing new and blocks strictly less in one case). The fix belongs one level upstream, at the rule that *generates* the unbounded time family. | Yes, once relocated |
| 4 | Fuel-insensitive a-priori rejection / early exit | **Rejected — unsound.** Both open-verdict constructors carry proof-carrying saturation fields; there is no constructor a heuristic can build. The honest bounded alternative already exists in-tree and is not a heuristic. | No |

**The root cause.** `serialityRule` (`Tableau.lean:1490-1494`) emits `T(F ⊤)` and `T(P ⊤)` at
*every* label. `someFuturePos` / `somePastPos` discharge those by **minting a fresh time**, whose
witness guard `witnessPresent` (`Tableau.lean:1861-1872`) demands the literal formula `T(⊤)` at an
already-ordered time. The times minted by this chain carry `T(⊤)`; the times that existed *before*
seriality ran never receive it. So no pre-seriality time's type can ever contain a
seriality-minted time's type, `isSubsetBlocked` (`SignedFormula.lean:649-652`) fails permanently
for those times, and each escaped time is a fresh unblocked label at which seriality fires again,
minting two more. The time family grows without bound; the world family does not (measured:
constant at 2 for the whole run).

**The recommended fix.** `⊤` is true at every label of every model, so an *already-ordered* future
(resp. past) time is a witness for `F ⊤` (resp. `P ⊤`) whether or not the branch literally carries
`T(⊤)` there. Suppressing the mint in that case is satisfiability-preserving in both directions —
the same argument `Tableau.lean:1786-1787` already gives for the existing witness guard.

**Measured effect of that fix** (simulated at the expansion-step level, §5): the branch reaches
blocking-aware saturation at **step 31** and stays saturated, with `findClosure = none` (a genuine
open branch, i.e. the correct `.invalid` verdict), 8 times instead of an unbounded family, and
— critically — after the `saturateBlocked` pass the *literal* saturation test that
`ExpandedTableau.hasOpen` demands is also satisfiable. That is exactly the `(2, _)` end state
`BoxNegReachabilityProbe.lean:216-217` names as owed.

---

## 2. Reference grounding

### 2.1 Semantics (definitions of record)

| Anchor | Verbatim text (excerpt) | Live Lean mirror | Status |
|---|---|---|---|
| `def:BL-semantics` (`paper-definitions-of-record.md:392`) | `\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.` | `box_iff`, `FormalSystem/Semantics/Truth.lean:223-230`: `TruthAt M τ t φ.box ↔ ∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ` | VERIFIED — quantifier range is `H_F`, no carrier |
| `def:BL-semantics` (`:394`) | `\item[($\Future$)] $\M,\tau,x \vDash \Future \varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $x < y$.` | `future_iff`, `Truth.lean:272-285`: `TruthAt M τ t φ.allFuture ↔ ∀ (s : D), t < s → TruthAt M τ s φ` | VERIFIED — evaluated along `τ` alone |
| `def:world-history` (`:258, :260`) | `A world history is \textit{total}--- equivalently, a \textit{possible world}--- just in case $X = D$.` … `The set of all total world histories over $\F$ is denoted $H_{\F}$.` | `WorldHistory.IsTotal` | VERIFIED |
| `def:frame-validity` (`:487`) | `$\vDash_{\F} \varphi$ if and only if $\M,\tau,x \vDash \varphi$ for every model $\M$ …, possible world $\tau \in H_{\F}$, and time $x \in D$.` | — | VERIFIED |

The invalidity of `(G p) → □(G p)` follows from the *juxtaposition* of the `□` and `Future`
clauses above: the antecedent's quantifier is bound to `τ`, the consequent's ranges over all of
`H_F`, and nothing in `def:BL-semantics` links them. Report 04 §2's two-world countermodel is
correct and is **re-confirmed here**, independently, by the engine itself: the open branch the
engine builds carries `T p` at world 0's future times and `F p, T(¬p)` at `(world 1, time 1)`
(§4.3) — literally the countermodel, present on the branch by step 5.

### 2.2 Code anchors

| Declaration | Location | Role in this report |
|---|---|---|
| `serialityRule` arm of `applyRule` | `Tableau.lean:1490-1494` | Emits `T(F ⊤)`, `T(P ⊤)` at every label; `.persistent`, self-guarded by `branch.contains` |
| `witnessPresent` | `Tableau.lean:1842-1891` | Fresh-label suppression guard; `.someFuturePos` arm at `:1861-1866`, `.somePastPos` at `:1867-1872`, `.untlPos` at `:1873-1881`, `.sncePos` at `:1882-1890` |
| `findApplicableRule` | `Tableau.lean:1903-1947` | Consults `witnessPresent` behind `ruleMintsFreshLabel` at `:1912-1914` (`.linear`) and `:1935-1936` (`.branching`) |
| `ruleMintsFreshLabel` | `Tableau.lean:1805-1808` | The eight fresh-label rules, incl. `.someFuturePos`, `.somePastPos`, `.untlPos`, `.sncePos` |
| `allFuturePos` arm | `Tableau.lean:753-759` | `.persistent`; propagates `T ψ` to `timeOrd.futureOf l.time` — **including blocked times** |
| `boxNeg` arm | `Tableau.lean:681-704` | Mints one fresh world; `:700-703` records that the six group-3 `tempGProps` blocks are gone |
| `expandOnceUnblocked` | `Tableau.lean:2214-2243` | Three-stage pick; `:2210-2212` documents that formulas *are* emitted into blocked times |
| `findUnexpandedUnblockedWith` | `Tableau.lean:2119-2121` | The engine's real saturation test |
| `blockedTimes` / `isTemporallyBlockedSaturated` | `Tableau.lean:2108-2110` / `:2047-2053` | Blocking, with `timeSaturated` ancestor side condition |
| `blockCandidates` | `Tableau.lean:2036-2037` | `pastOf t ++ (futureOf t).filter (· < t)` |
| `Branch.timeType` / `isSubsetBlocked` | `SignedFormula.lean:639-640` / `:649-652` | The subset test; `timeType` is **world-blind** (merges all worlds at a time) |
| `expandBranchWithFuel` | `Saturation.lean:816-923` | Fuel loop; `none` on exhaustion (`:827-828`) and on budget (`:825`) |
| `buildTableau` | `Saturation.lean:1159-1182` | Demands the **literal** `findUnexpanded = none` at `:1171` and again at `:1179`; otherwise `none` |
| `saturateBlocked` | `Saturation.lean:431-499` | Post-blocking pass; refuses any step that lengthens the ordering |
| `BudgetedTableau` / `buildTableauAt` | `Saturation.lean:2091-2099` / `:2196-2215` | Already-built blocking-aware certificate and entry point |
| `decide` | `DecisionProcedure.lean:170-209` | Calls `buildTableau` at `:193`; `.hasOpen → .invalid` at `:208-209` |
| Probe rows 9-12 | `BoxNegReachabilityProbe.lean:219-260` | The pinned `(0,0)` / `fuelExhausted` / no-countermodel values |

Derived-operator facts used throughout (`FormalSystem/Syntax/Formula.lean`): `top := bot.imp bot`
(`:118`), `someFuture φ := untl φ top` (`:131`), `allFuture φ := (someFuture φ.neg).neg`
(`:151`). This is why `BoxNegReachabilityProbe.lean:99-103` row 1 is right that `negPos`
decomposes `T(G p)`: `G p` really is a negation.

---

## 3. Method — and what was deliberately not run

**Not run, by dispatch constraint**: `lake build BimodalTest`, and any `#eval` of
`BoxNegReachabilityProbe.lean` or `CrossWorldPropagationProbe.lean`. No probe expectation was
edited. No Lean source file under `FormalSystem/` or `Tests/` was edited.

**Run**: five standalone diagnostic files under the session scratchpad, compiled with
`lake env lean` against the already-cached `FormalSystem` oleans (the default `lake build` target
is green at 2331 jobs per `summaries/04_phase22-omega-terminus-summary.md`). Each drives
`expandOnceUnblocked` from the probe's own initial branch

```lean
b0 : Branch := [ SignedFormula.pos gp {world := 0, time := 0}
               , SignedFormula.neg (Formula.box gp) {world := 0, time := 0} ]
```

(identical to `BoxNegReachabilityProbe.lean:85-87`) at `.Base`, for a **bounded** number of
expansion rounds, and reports state. Round counts used: 4 through 44.

**Measurement attempted and NOT obtained**: snapshots at rounds 44 / 52 / 60 on the *unfixed*
engine. A single `lake env lean` invocation computing those three snapshots was killed at 560 s
(`EXIT=124`). This is itself a datum — see §4.4 — but the numbers do not exist and are not
reported.

**Measurement not attempted**: end-to-end `buildTableau`/`decide` timings under the recommended
fix. That requires editing `Tableau.lean`, which is out of scope for a research dispatch. Every
claim about what `buildTableau` would return under the fix is derived from the step-level
simulation in §5 plus the control flow at `Saturation.lean:1171-1181`, and is marked as such.

---

## 4. What actually happens (measured)

### 4.1 The blow-up is purely temporal; the modal side terminates

Baseline, unfixed engine, head branch after `n` rounds of `expandOnceUnblocked`:

| n | branch len | #times | #worlds | #blocked | #unblocked times | ord constraints |
|---|---|---|---|---|---|---|
| 4 | 8 | 2 | 2 | 0 | — | — |
| 8 | 15 | 2 | 2 | 0 | — | — |
| 12 | 22 | 4 | 2 | 1 | — | — |
| 16 | 27 | 6 | 2 | 3 | 3 | — |
| 20 | 32 | 7 | 2 | 4 | 3 | 6 |
| 24 | 37 | 8 | 2 | 4 | 4 | 7 |
| 28 | 41 | 9 | 2 | 5 | 4 | 8 |
| 32 | 46 | 10 | 2 | 6 | 4 | 9 |
| 40 | 57 | 12 | 2 | 7 | 5 | 11 |

**`#worlds` is constant at 2 for the entire run.** The `boxNeg` witness guard
(`Tableau.lean:1846-1848`, `branch.knownWorlds.any …`) does its job: `boxNeg` fires once, mints
world 1, and is suppressed thereafter. Report 04 §3's framing — "the root temporal universal
`G p` generates a fresh time obligation on `w₀` for every future time considered" — is directionally
right about *where* the growth is (times, not worlds) but wrong about the *generator*: see §4.2.

`#times` and `#unblocked times` both grow monotonically with no plateau. This is the
non-termination, and report 04 §3's characterisation of it as "a termination/bound question rather
than a budget one" is confirmed.

### 4.2 The generator is seriality, not `T(G p)`

Rule fired at each expansion round (`ORD` = stage 1, `SER` = seriality stage):

```
 0 negPos@(0,0)        7 SER@(1,0)          14 negPos@(0,4)
 1 boxNeg@(0,0)        8 someFuturePos@(1,0) 15 somePastPos@(0,2)
 2 negNeg@(1,0)        9 negPos@(1,2)        16 someFutureNeg@(0,0)
 3 someFuturePos@(1,0) 10 impNeg@(0,2)       17 allFuturePos@(0,0)
 4 negPos@(1,1)        11 somePastPos@(1,0)  18 SER@(1,2)
 5 impNeg@(0,1)        12 SER@(0,2)          19 someFuturePos@(1,2)
 6 impNeg@(1,0)        13 someFuturePos@(0,2) 20 someFutureNeg@(0,0)
```

The repeating motif is `SER@(w,t)` → `someFuturePos@(w,t)` / `somePastPos@(w,t)` → fresh time.
`allFuturePos@(0,0)` — the root universal report 04 blamed — fires **once** in the first 21
rounds. `someFutureNeg@(0,0)` fires twice. Both are `.persistent` rules that re-arm once per new
time; they are *consumers* of the time family, contributing one step each per minted time, not
its producer.

### 4.3 The countermodel is on the branch by step 5 and never leaves

Full label contents of the head branch at round 24 (decoded from the raw `Formula` reprs;
`imp bot bot` = `⊤`, `untl ⊤ ⊤` = `F ⊤`, `snce ⊤ ⊤` = `P ⊤`, `imp (atom p) bot` = `¬p`,
`untl (¬p) ⊤` = `F ¬p`, `imp (untl (¬p) ⊤) bot` = `G p`):

| Label | Contents |
|---|---|
| `(0,0)` | `F(F ¬p)`, `T(G p)`, `F(□(G p))` |
| `(0,1)` | `T(F ⊤)`, `T(P ⊤)`, `T p`, `F ⊥`, `F(¬p)` |
| `(0,2)` | `T(F ⊤)`, `T(P ⊤)`, `T p`, `F ⊥`, `F(¬p)` |
| `(0,4)` | `T p`, `F(¬p)`, `F ⊥`, `T ⊤` |
| `(0,5)`, `(0,7)`, `(1,3)`, `(1,6)` | `T ⊤` — **and nothing else** |
| `(1,0)` | `T(F ⊤)`, `T(P ⊤)`, `T(F ¬p)`, `F ⊥`, `F(G p)` |
| `(1,1)` | `F p`, `T(¬p)` |
| `(1,2)` | `T(F ⊤)`, `T(P ⊤)`, `F ⊥`, `T ⊤` |

Ordering: `[(1,7),(2,6),(5,2),(2,4),(3,0),(0,2),(0,1)]`.

`(1,1)` carrying `F p, T(¬p)` beside `(0,1)`/`(0,2)` carrying `T p` **is** report 04 §2's
countermodel: world 0 has `p` throughout its future, world 1 does not, and the branch has both.
The engine finds it in five steps and then spends the remaining budget failing to certify that it
is finished. This is the single most important operational fact in this report, and it is what
kills direction 1.

Note also the four labels carrying `T ⊤` **and nothing else**: `(0,5)`, `(0,7)`, `(1,3)`, `(1,6)`.
These are the seriality-witness times. They are pure overhead — they carry no information about the
countermodel — and each one is a fresh label at which seriality will fire again.

### 4.4 Why blocking cannot keep up

Per-time state at round 32 (`#cands` = `blockCandidates`; `#sub` = candidates passing
`isSubsetBlocked`; `#sub∧sat` = those also passing the `timeSaturated` ancestor side condition;
`|type|` = `timeType` size):

| t | \|fmls@t\| | \|type\| | saturated | blocked | #cands | #sub | #sub∧sat |
|---|---|---|---|---|---|---|---|
| 0 | 9 | 8 | yes | **no** | 1 | 0 | 0 |
| 1 | 8 | 7 | yes | **no** | 3 | 0 | 0 |
| 2 | 10 | 6 | yes | **no** | 3 | 0 | 0 |
| 3 | 1 | 1 | no | yes | 3 | 1 | 1 |
| 4 | 4 | 4 | yes | yes | 4 | 1 | 1 |
| 5 | 1 | 1 | no | yes | 2 | 2 | 2 |
| 6 | 3 | 3 | no | yes | 4 | 1 | 1 |
| 7 | 6 | 6 | yes | **no** | 4 | 0 | 0 |
| 8 | 1 | 1 | no | yes | 2 | 1 | 1 |
| 9 | 3 | 3 | no | yes | 5 | 1 | 1 |

Three things follow, and only the third was anticipated by report 04.

**(a) The `timeSaturated` ancestor side condition is not the bottleneck.** For every unblocked
time, `#sub = 0` — the subset test itself fails against *every* candidate, so the side condition
is never even reached (`Tableau.lean:2050-2053`'s `&&` chain short-circuits). Report 04 §3's
"temporal blocking … cannot fire because no time type on `w₀` ever saturates" is **incorrect**:
times 0, 1, 2 and 7 are all `timeSaturated = true` at round 32.

**(b) The subset test fails for a specific, nameable reason: `T ⊤`.** Times 3, 5, 8 (type size 1)
are exactly the `{T ⊤}` seriality witnesses, and they *are* blocked. What is not blocked is a
seriality-minted time that has since *accumulated* propagation. Time 7's `timeType` grew from 1 at
round 24 (§4.3: `(0,7) = {T ⊤}`) to 6 at round 32. Its candidate ancestors are times 1, 0, 3.
Times 0, 1 and 2 predate seriality and therefore never received `T ⊤`; time 7 has it. One pair
outside the ancestor's type is enough, and `isSubsetBlocked` (`SignedFormula.lean:649-652`) fails
permanently.

**(c) Blocking is non-monotone, by design.** `Tableau.lean:2210-2212` states explicitly that a
formula produced *at* a blocked time is added to the branch and only then skipped as a source. So
a blocked time keeps growing, and can grow out of its own block. Time 7's trajectory (type 1 →
type 6, unblocked at 32) is the measured instance. *(That time 7 was blocked at round 24 is
[INFERRED], not directly measured: what is measured is that its type was 1 at round 24, that every
type-1 time at round 32 is blocked, and that time 7 is unblocked at round 32.)*

**(d) Per-step cost also grows.** `blockedTimes` runs `timeSaturated` per candidate ancestor pair,
and `timeSaturated` runs `isExpanded` — i.e. a full `allRulesForFC` scan against the whole branch —
per formula at that time. With branch length and time count both growing, per-step cost grows at
least quadratically. This is why rounds 44/52/60 could not be obtained inside 560 s (§3) and why
`BoxNegReachabilityProbe.lean`'s `#eval` at fuel 1000 burned >45 min per report 04 §5. Fuel 1000
is therefore *doubly* out of reach: the step count never suffices, and the steps are not cheap.

### 4.5 Adversarial test: is world-blind `timeType` the defect? — **No**

`Branch.timeType` (`SignedFormula.lean:639-640`) merges every world at a time. The obvious
hypothesis is that blocking fails because it compares merged types. **Tested and refuted.** A
label-indexed blocking predicate (per-`(world,time)` type, per-`(world,time)` saturation, same
`blockCandidates`) evaluated on the round-32 branch:

| `(w,t)` | \|labelType\| | time-blocked (live) | label-blocked (hypothetical) |
|---|---|---|---|
| `(0,0)` | 3 | no | no |
| `(0,1)` | 5 | no | no |
| `(0,2)` | 5 | no | no |
| `(0,4)` | 4 | **yes** | **no** |
| `(0,5)` | 1 | yes | yes |
| `(0,6)` | 2 | yes | yes |
| `(0,7)` | 6 | no | no |
| `(0,8)` | 1 | yes | yes |
| `(0,9)` | 3 | yes | yes |
| `(1,0)` | 5 | no | no |
| `(1,1)` | 2 | no | no |
| `(1,2)` | 4 | no | no |
| `(1,3)` | 1 | yes | yes |
| `(1,6)` | 1 | yes | yes |

Label-aware blocking blocks **nothing** the live predicate does not, and **loses** `(0,4)`. This
is a genuine negative result and it is why direction 3 is reported as "right diagnosis, wrong
lever" rather than "strengthen blocking".

---

## 5. The recommended fix, and its measured effect

### 5.1 The change

`⊤` is `bot.imp bot` (`Formula.lean:118`) and is true at every label of every model. `F ⊤` is
`untl ⊤ ⊤` (`Formula.lean:131`). Therefore:

> If `t'` is any time already ordered strictly after `t`, then `T(F ⊤) @ (w,t)` is satisfied by
> `t'` in every model, whether or not the branch literally carries `T(⊤) @ (w,t')`.

So the fresh-label suppression for `someFuturePos` / `untlPos` on the specific trigger
`T(U(⊤,⊤))` — and the past mirrors `somePastPos` / `sncePos` on `T(S(⊤,⊤))` — may be strengthened
from *"a future time literally carries the witness"* to *"a future time exists"*. This is the
same satisfiability-preserving argument `Tableau.lean:1786-1787` already gives for the existing
witness guard ("the standard 'do not duplicate an existing witness' restriction … satisfiability-
preserving in both directions"), specialised to an event formula that needs no witness at all.

The condition must be keyed on the **syntactic** event formula `⊤`, never generalised: for a
non-valid event `ψ`, "a future time exists" is emphatically not a witness for `F ψ`.

### 5.2 Measured effect

Simulated at the expansion-step level by suppressing `T(F ⊤)` / `T(P ⊤)` as expansion sources when
`timeOrd.futureOf` / `pastOf` of their time is non-empty, with the rest of `expandOnceUnblocked`'s
three-stage pick replicated verbatim:

| n | branch len | #times | #worlds | #blocked | `.saturated`? |
|---|---|---|---|---|---|
| 12 | 20 | 4 | 2 | 0 | no |
| 20 | 31 | 6 | 2 | 2 | no |
| 30 | 45 | 8 | 2 | 3 | no |
| 40 | **47** | **8** | 2 | 3 | **yes** |

- Saturation is first reached at **step 31** and holds at every step from 31 through 44 (measured
  as a contiguous run, so it is a fixpoint, not a transient).
- `findClosure = none` on the saturated branch: it is a genuine **open** branch. The verdict is
  `.invalid`, which is the semantically correct one per §2.1.
- Time count settles at 8 and stops. Compare the unfixed engine, still at 12 times and growing at
  round 40.

### 5.3 Does it reach `buildTableau`'s *literal* certificate?

This matters because `buildTableau` (`Saturation.lean:1171, 1179`) refuses `.hasOpen` unless the
literal `findUnexpanded … = none` holds — the blocking-aware test is not enough for the
`ExpandedTableau` constructor. Measured, by running `saturateBlocked b 1000 o .Base` on the
step-31 branch exactly as `Saturation.lean:1176` does:

```
open  len=50  times=8  literalNone=false  suppressedNone=true
```

`suppressedNone = true` says: with the suppression applied, **no formula anywhere on the branch —
blocked times included — has an applicable rule.** `literalNone = false` is an artifact of the
simulation only: the suppression was applied at the *finder* rather than inside the guard, so the
suppressed `T(F ⊤)` / `T(P ⊤)` formulas still register as unexpanded to the unmodified
`findUnexpanded`. Implemented at the guard (so that `findApplicableRule` genuinely returns `none`
on them), `isExpanded` returns `true` for exactly those formulas and the literal test reads
`none`.

**Therefore** — and this is a derived claim, not a measured one, flagged as such — the
**unmodified** `buildTableau` reaches `some (.hasOpen satBr satOrd fc h2)` at
`Saturation.lean:1180`, and `decide` (`DecisionProcedure.lean:208-209`) returns
`.invalid (extractCountermodelSimple …)`. That is the `(2, _)` / `.invalid` end state
`BoxNegReachabilityProbe.lean:216-217` and `:65-70` name as owed.

### 5.4 Two placements, one safer

| Variant | Change | Measured? | Risk |
|---|---|---|---|
| **A — suppress the mint** | Guard returns "witnessed" on the mere existence of an ordered future/past time | **Yes** (§5.2-5.3) | The branch never carries `T(⊤)` at the witnessing time. Countermodel extraction (`CountermodelExtraction.lean`) may read witnesses off the branch. |
| **B — redirect the witness** | Instead of minting, emit `T(⊤)` at an *existing* ordered future/past time | **No** | Preserves the "witness is literally on the branch" discipline the extraction lemmas rely on. Costs one formula per label instead of one time. |

**B is the safer default**; A is the smaller diff and is the one with measurements behind it. B
should reproduce A's time-count behaviour exactly (it mints no time either) while keeping the
literal witness. A phase that implements B must re-run §5.2's measurement to confirm.

### 5.5 Why not touch `witnessPresent` directly

`witnessPresent` has a large verified consumer surface: `MintBound.lean` (111 occurrences),
`CountermodelExtraction.lean` (11), `TemporalSaturation.lean` (10), `Fuel.lean` (6),
`BoxSaturation.lean` (1), `PropSaturation.lean` (1). Editing its `.someFuturePos` /
`.somePastPos` / `.untlPos` / `.sncePos` arms in place would perturb all of it at once.

The **additive** placement is a new predicate consulted *beside* `witnessPresent` in
`findApplicableRule`'s two fresh-label guards (`Tableau.lean:1912-1914` and `:1935-1936`), leaving
`witnessPresent` itself byte-identical. The genuine proof cost then lands in exactly one place: the
saturation-extraction lemmas that currently read "`findApplicableRule = none` ⟹
`witnessPresent = true`" (`TemporalSaturation.lean`, 188 lines; `PropSaturation.lean`, 108 lines;
`BoxSaturation.lean`, 642 lines) must be widened to a disjunction. Those lemmas are discharged by
the same triviality that motivates the change — the event is `⊤` — so the new case is provable, not
merely plausible.

---

## 6. The three rejected directions, in full

### 6.1 Direction 1 — witness-first ordering: rejected

The `boxNeg` witness `F(G p) @ (1,0)` is minted at expansion step 1 and decomposed to
`T(F ¬p) @ (1,0)` at step 2; its own witness `F p, T(¬p) @ (1,1)` lands at steps 3-4 (§4.2 trace).
The countermodel is complete at step 5 out of a 1000-step budget. **Reordering cannot improve on
"already first".** Report 04 §4.1's premise — that the search "interleav[es] the root universal's
infinite time generation" ahead of the witness — is refuted by the trace: `allFuturePos@(0,0)`
does not fire until step 17.

A reordering would also be *sound but pointless*: `findUnexpandedUnblockedWith`
(`Tableau.lean:2119-2121`) selects which formula to expand, not which verdict to return, and every
verdict constructor carries its own saturation proof field, so no reordering can change a verdict.
That soundness argument is worth keeping on file — it is what would license the reordering if a
future measurement ever motivated one.

### 6.2 Direction 2 — structural `φ → □φ` recognition: rejected as primary

To return `.invalid` for `φ → □φ` in constant time, the rule would have to be sound, i.e. never
fire on a **valid** instance. But `φ → □φ` *is* valid for a large syntactic class: any `φ` whose
truth is history-independent. `□p → □□p` is valid (S5 transitivity, and the tree's `boxTemporal`
/ S5 rules give it); so is `⊤ → □⊤`; so is any `φ → □φ` where `φ` is `□`-prefixed. A rule keyed on
the *shape* `φ → □φ` alone would report those invalid, which is a soundness hole of exactly the
kind `BoxNegReachabilityProbe.lean:56-62` exists to prevent (it records the previous
`extractionFailed` value as "an assertion that this invalid formula is valid" — the same error in
the other direction).

Sound versions require a side condition — "`φ` has an occurrence of an atom or a temporal operator
not under any `□`" — which is decidable and cheap. But even the sound version fixes a *shape*, not
the class: `CrossWorldPropagationProbe.lean:70-76` row A (`(¬F p) → □(¬F p)`) and row C exhibit
the identical seriality-driven non-termination, and so would any refutation requiring a seriality
chain regardless of whether a `□` appears at top level. The class is "refutations that need the
engine to stop minting seriality witnesses", and §5's fix addresses it directly.

`CrossWorldPropagationProbe.lean` completing at 2418 s (report 04 §5) is not evidence that this
class is tractable: its rows A-E call `isValid`, which reads `false` under `.invalid`,
`.fuelExhausted` and `.extractionFailed` alike (`CrossWorldPropagationProbe.lean:31-33`). Those
rows are satisfied by fuel exhaustion. Only row F pins a constructor.

### 6.3 Direction 4 — fuel-insensitive early exit: rejected as unsound

Both open-verdict constructors are proof-carrying:

- `ExpandedTableau.hasOpen` (`Saturation.lean:75`) carries `findUnexpanded openBranch … = none`.
- `BudgetedTableau.hasOpen` (`Saturation.lean:2096-2099`) carries
  `findUnexpandedUnblockedWith … (blockedTimes … tracker) = none`.

A heuristic detector cannot construct either field. Emitting `.invalid` on an a-priori pattern
match would require a **new constructor without a saturation proof**, which is a soundness hole in
the decision procedure — precisely the defect class `BoxNegReachabilityProbe.lean` was written to
catch. Report 04 §4.3's defence ("it returns the *same* verdict the fuel sweep converges to") does
not survive contact with the type: the fuel sweep converges to `fuelExhausted`, an
*undetermined* verdict, whereas the proposed early exit would emit `hasOpen`, a *determined* one.
They are not the same verdict.

**The honest bounded alternative already exists and is not a heuristic.** `BudgetedTableau` /
`buildTableauAt` (`Saturation.lean:2091-2215`) are exactly a principled certificate weakening —
blocking-aware saturation instead of literal saturation — with `upgrade` and
`upgrade_hasOpen_isSome_iff` (`:2124-2155`) proving no free path from the weak certificate to the
strong one. `decide` does not currently route through it (`DecisionProcedure.lean:193` calls
`buildTableau`). Routing it there is a legitimate, sound, in-tree improvement — but note it does
**not** rescue this formula on its own: measured in §4.1, the unfixed engine never reaches
blocking-aware saturation either, so `expandBranchWithFuel` returns `none` and `buildTableauAt`
returns `none` too. It is a complement to §5's fix, not a substitute.

---

## 7. Probe-expectation impact — declared, not silent

Per the dispatch's hard constraint and the plan's carried caveat
(`plans/03_omega-free-totality-refactor.md:83-89`), no probe expectation was edited here. The
recommended change **will** legitimately move probe rows, and this section is that declaration.

**Rows that will move, with high confidence:**

| Row | File:line | Current | Expected after fix |
|---|---|---|---|
| Row 9 | `BoxNegReachabilityProbe.lean:219-224` | `(0, 0)` | `(2, N)` for some branch length `N` (≈50 at `.Base`; the exact `N` must be measured, not predicted) |
| Row 10 | `BoxNegReachabilityProbe.lean:240-243` | `(false, false, true, false, true)` | `(false, true, false, false, false)` — `.invalid` |
| Row 11 | `BoxNegReachabilityProbe.lean:249-251` | `false` | `true`, **conditional on `extractCountermodelSimple` succeeding** — unverified |
| Row F | `CrossWorldPropagationProbe.lean` (the `decide`-constructor row) | `fuelExhausted` tuple | `.invalid` tuple |

**Rows that may move and must be measured:** `BoxNegReachabilityProbe` rows 4-8 all read
`reached := run 12` (`:138`), and the fixed engine's round-12 branch differs from the unfixed one
(20 formulas vs 22, §5.2 vs §4.1). Rows 7 (`(1, 1)`) and 8 (`none`) are the exposed ones. Row 12
(`isValid = false`) is stable under both `.fuelExhausted` and `.invalid`.

**Rows outside these two files that may move:** any row in `TableauConformance.lean`,
`RegionGateProbe.lean`, `BoxSpreadProbe.lean`, `TemporalWitnessProbe.lean`, `RayRegionProbe.lean`
or `UntlSnceCopyProbe.lean` whose formula's refutation involves a seriality chain. **This was not
measured** — measuring it requires `lake build BimodalTest`, which the dispatch forbids and which
is currently unusable for the reason this report exists. It is the first thing that becomes
possible *after* the fix lands, and Phase D below is that measurement.

**Where the re-baseline must be recorded.** The behavioural change is owned by
`FormalSystem/Metalogic/Decidability/Tableau.lean` (the guard in `findApplicableRule` /
`witnessPresent`), **not** by `Saturation.lean` and **not** by this refactor's semantics work. The
plan's caveat names `Saturation.lean` because that is where the *previous* engine-behaviour change
lived; this one is a `Tableau.lean` change and must be attributed there. The ten pre-existing
`#guard_msgs` mismatches (`TableauConformance` 7, `RegionGateProbe` 2, `BoxSpreadProbe` 1) remain
a separate, still-declined item and must not be folded into this re-baseline.

**No scope reduction is proposed.** No probe is deleted or weakened, no fuel figure is lowered, no
test is marked `sorry`, no file is excluded from the build, and phases 22/23 of the plan of record
are untouched. The one bounded caveat is stated in §5.4 (variant A's interaction with countermodel
extraction) with variant B named as its resolution and Phase D as its measurement.

---

## 8. Adversarial Self-Verification

| # | Claim | Source / counterexample | Outcome |
|---|---|---|---|
| 1 | `(G p) → □(G p)` is invalid under the post-refactor semantics | `def:BL-semantics` box clause (`paper-definitions-of-record.md:392`) + Future clause (`:394`); mirrored by `box_iff` (`Truth.lean:223-230`) and `future_iff` (`Truth.lean:272-285`). Independently corroborated by the engine's own open branch (§4.3): `T p` at `(0,1)/(0,2)`, `F p, T(¬p)` at `(1,1)`, `findClosure = none` | **CONFIRMED** (High) |
| 2 | The countermodel is discovered within 5 expansion steps | Measured rule trace, §4.2 rounds 0-4; label dump §4.3 shows `(1,1) = {F p, T(¬p)}` | **CONFIRMED** (High) — kills direction 1 |
| 3 | Report 04 §3's stated cause ("no time type on `w₀` ever saturates") is wrong | Round-32 per-time table §4.4: times 0, 1, 2, 7 all have `saturated = yes` and are nonetheless unblocked, with `#sub = 0` — the subset test fails before the saturation condition is consulted | **REFUTES REPORT 04 §3** (High). The *conclusion* (termination problem, not budget problem) survives; the mechanism does not |
| 4 | Report 04 §3's blaming of the root universal `T(G p)` is wrong | Rule trace §4.2: `allFuturePos@(0,0)` fires once in rounds 0-20; the repeating motif is `SER → someFuturePos/somePastPos → fresh time` | **REFUTES REPORT 04 §3** (High) |
| 5 | The blow-up is temporal only; the modal side terminates | `#worlds = 2` at every measured round 4→40 (§4.1); `boxNeg` witness guard at `Tableau.lean:1846-1848` | **CONFIRMED** (High) |
| 6 | World-blind `timeType` is the defect | **Counterexample found by direct test**: label-aware blocking at round 32 blocks nothing new and loses `(0,4)` (§4.5) | **REFUTED — hypothesis abandoned** (High). Recorded because it is the most natural wrong answer |
| 7 | Blocking is non-monotone (a blocked time can unblock) | `Tableau.lean:2210-2212` documents propagation into blocked times as intended; time 7's `timeType` measured at 1 (round 24, §4.3) and 6 (round 32, §4.4), unblocked at 32 | **CONFIRMED for the type growth; the blocked→unblocked transition at those exact rounds is [INFERRED]** (Medium) |
| 8 | The seriality witness chain is what escapes blocking, because ancestors lack `T ⊤` | §4.3 shows `(0,5),(0,7),(1,3),(1,6)` carry `T ⊤` alone while `(0,0),(0,1),(0,2),(1,0)` carry no `T ⊤`; `isSubsetBlocked` (`SignedFormula.lean:649-652`) needs *every* pair present | **CONFIRMED** (High) |
| 9 | Suppressing the `⊤`-event mint terminates the search | Simulated and measured §5.2: saturation at step 31, stable through 44, 8 times, `findClosure = none` | **CONFIRMED for the simulation** (High) |
| 10 | The fix makes the **unmodified** `buildTableau` return `.hasOpen` | `saturateBlocked` tail measured (§5.3): `suppressedNone = true` after the pass, i.e. no formula anywhere has an applicable rule modulo the suppression. Combined with `Saturation.lean:1176-1180` control flow | **DERIVED, not measured** (Medium). The residual `literalNone = false` is a stated simulation artifact; the claim depends on the fix being implemented at the guard, not the finder |
| 11 | Probe row 11 (countermodel present) will flip to `true` | Requires `extractCountermodelSimple` (`DecisionProcedure.lean:209`) to return `some` on this branch | **[UNVERIFIED]** — extraction not exercised. Stated conditionally in §7 |
| 12 | A structural `φ → □φ` rule would be unsound | `□p → □□p`, `⊤ → □⊤` are valid instances of the shape | **CONFIRMED by counterexample** (High) |
| 13 | Direction 4's early exit is unsound | `ExpandedTableau.hasOpen` (`Saturation.lean:75`) and `BudgetedTableau.hasOpen` (`:2096-2099`) both carry saturation proof fields; no heuristic can inhabit them | **CONFIRMED** (High) |
| 14 | `buildTableauAt`/`BudgetedTableau` alone would rescue this formula | **Counterexample**: §4.1 shows the unfixed engine never reaches blocking-aware saturation either, so `expandBranchWithFuel` returns `none` (`Saturation.lean:827-828`) and `buildTableauAt:2201` returns `none` | **REFUTED — demoted to a complement** (High) |
| 15 | Per-step cost grows, so fuel 1000 is doubly out of reach | Rounds 44/52/60 not obtained in 560 s (§3); `blockedTimes → timeSaturated → isExpanded` nesting (`Tableau.lean:2108-2110`, `:2011-2014`, `:1953-1956`) | **CONFIRMED for the timeout; the complexity bound is an [ANALYTIC] reading of the call structure, not a profile** (Medium) |
| 16 | Rows in other probe files may move | Not measured — requires `lake build BimodalTest`, forbidden by dispatch and currently unusable | **[UNVERIFIED, reason stated]** — Phase D exists for this |

**Contradiction log.** One contradiction was found and resolved: report 04 §3 attributes the
non-termination to the root universal `T(G p)` and to ancestor non-saturation; claims 3 and 4
above refute both on direct measurement of the live engine. Resolution by precedence: *measured
behaviour of the live tree outranks a prior report's structural reading*. Report 04's higher-level
conclusion — "a termination/bound question rather than a budget one" — is **upheld**, and its
directive not to re-baseline probes without attributing the change is **upheld and executed** in
§7. No unresolved contradictions remain.

**Recommendations modified after verification.** Two. (i) The primary recommendation was initially
going to be a strengthened blocking predicate (report 04 direction 3, taken at face value); the
§4.5 label-aware test refuted the natural form of it and moved the recommendation upstream to the
mint guard. (ii) Routing `decide` through `buildTableauAt` was initially going to be recommended
as a standalone fix; claim 14 refuted that and demoted it to a complementary phase.

---

## 9. Recommended Implementation Surface

Ordered. Each phase is sized to roughly one agent run. Phases A-C are the fix; D-E are the
declared measurement and attribution work §7 requires. **Do not reorder A before the definitions
gate, and do not start D before C is green.**

### Phase A — the guard (≈150 lines)

**File**: `FormalSystem/Metalogic/Decidability/Tableau.lean`

1. Add a new definition beside `witnessPresent` (i.e. after `Tableau.lean:1891`), named e.g.
   `trivialEventWitnessed`, with the arms:
   - `.someFuturePos` / `.untlPos` on trigger `⟨.pos, .untl ⊤ ⊤, l⟩` → `!(timeOrd.futureOf l.time).isEmpty`
   - `.somePastPos` / `.sncePos` on trigger `⟨.pos, .snce ⊤ ⊤, l⟩` → `!(timeOrd.pastOf l.time).isEmpty`
   - every other rule/shape → `false`
   Key it on the syntactic event `Formula.top` (`Formula.lean:118`) only. Carry a docstring giving
   the soundness argument (§5.1) and an explicit warning against generalising to a non-valid event.
2. Consult it in `findApplicableRule`'s two fresh-label guards, as a disjunct beside
   `witnessPresent`: `Tableau.lean:1913` (`.linear` arm) and `:1936` (`.branching` arm).
   **Do not edit `witnessPresent` itself** — §5.5.
3. Prefer **variant B** (§5.4): where the guard now suppresses, emit `T(⊤)` at the existing
   ordered witness time instead of nothing, so the literal witness stays on the branch. If B
   proves awkward, land A and record the extraction risk as an explicit caveat with Phase C as its
   check.

**Verification**: `lake build FormalSystem.Metalogic.Decidability.Tableau`.

### Phase B — the saturation-extraction lemmas (≈300 lines)

**Files**: `Verified/Bridge/TemporalSaturation.lean` (188 lines),
`Verified/Bridge/PropSaturation.lean` (108), `Verified/Bridge/BoxSaturation.lean` (642).

Every lemma that reads "`findApplicableRule … = none` ⟹ `witnessPresent … = true`" must be widened
to the disjunction `witnessPresent … = true ∨ trivialEventWitnessed … = true`, and each new
disjunct discharged. The new case is discharged by the validity of `⊤`, so it is provable rather
than merely plausible — but it is real proof work and it is the bulk of this change's cost.

**Verification**: `lake build FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalSaturation`
(and the two siblings). **Zero-debt**: no `sorry`, no new axiom. If a lemma cannot be discharged,
mark the phase `[BLOCKED]` with the goal state — do not weaken the lemma.

### Phase C — countermodel extraction (≈150 lines)

**File**: `FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean` (11 `witnessPresent`
sites, incl. `:517` and the `.someFuturePos` / `.somePastPos` / `.untlPos` / `.sncePos` lemmas).

Confirm that extraction still produces a countermodel from a branch whose `F ⊤` / `P ⊤` witnesses
are *ordered* rather than *literal*. Under variant B this should be a no-op check; under variant A
it is the phase where the §5.4 risk is settled. Also confirm `extractCountermodelSimple`
(`DecisionProcedure.lean:209`) returns `some` on the `(G p) → □(G p)` open branch — this is
claim 11, currently `[UNVERIFIED]`.

**Verification**: `lake build FormalSystem`. Full tree green, sorry count unchanged at 1
(pre-existing `Metalogic/WeakCanonical/Transfer.lean:1084`), axiom count unchanged at 6.

### Phase D — measure `BimodalTest`, then re-baseline (≈250 lines)

**Files**: `Tests/BimodalTest/*.lean` (expectations only).

Now — and only now — run `lake build BimodalTest`. This is the first point at which it is expected
to terminate. Record the **actual** values for `BoxNegReachabilityProbe` rows 4-12,
`CrossWorldPropagationProbe` row F, and every `#guard_msgs` row that moves anywhere in the suite.
Update expectations to the measured values, with each moved row's docstring stating (a) the old
value, (b) the new value, (c) that the change is owned by `Tableau.lean`'s
`trivialEventWitnessed` guard — per §7's attribution requirement.

**Constraints**: do not lower any fuel figure; do not delete or weaken any probe; do not fold in
the ten pre-existing `#guard_msgs` mismatches (`TableauConformance` 7, `RegionGateProbe` 2,
`BoxSpreadProbe` 1), which remain separately owned and separately declined.

### Phase E — route `decide` through the blocking-aware entry (≈120 lines, OPTIONAL)

**Files**: `Saturation.lean:2196-2215` (`buildTableauAt`, exists), `DecisionProcedure.lean:193`.

Add a `decide` path that consumes `BudgetedTableau` so that formulas whose refutation needs
blocking can return `.invalid` on the blocking-aware certificate. This is a **complement**, not a
substitute (claim 14): it does not rescue `(G p) → □(G p)` without Phase A. Independent value, so
it may be deferred without blocking anything above.

**Verification**: `lake build FormalSystem && lake build BimodalTest`; the
`upgrade_hasOpen_isSome_iff` bridge (`Saturation.lean:2138-2155`) must remain the only path from
the weak certificate to the strong one.
