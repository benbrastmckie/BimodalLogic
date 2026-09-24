# Research Report: Task #667

**Task**: 667 - Tableau bridge branch gates and frame class
**Started**: 2026-09-24T22:56:00Z
**Completed**: 2026-09-24T23:40:00Z
**Effort**: 2-4 hours
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `BimodalTools/TableauBridgeMain.lean`, `FormalSystem/Metalogic/Decidability/{DecisionProcedure,Saturation,Tableau,Closure}.lean`, `FormalSystem/Metalogic/Decidability/Verified/Bridge/{IntTruth,BranchOrder,BoxSaturation,RegionLabel,TemporalGate}.lean`
- Existing probes: `Tests/BimodalTest/Metalogic/Decidability/{BoxSpreadProbe,RegionGateProbe,RayRegionProbe,TemporalWitnessProbe}.lean`, `.../Verified/BridgeProbes.lean`
- Live measurement: 13 `#eval` rows run under `lake env lean` against the built `.olean` tree (this session)
- Consumer contract: `~/Projects/ModelChecker/specs/184_refactor_bimodal_theory_tests_green_and_paper_lean_aligned/reports/01_finite-certificate-redesign.md`, section 5
**Artifacts**:
- `specs/667_tableau_bridge_branch_gates_and_frame_class/reports/01_branch-gates-frame-class.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The four named gates are not the full hypothesis set.** `not_valid_of_hasOpen_int` /
  `not_validZTime_of_hasOpen_int` (`IntTruth.lean:1045,1073`) take **eight** hypotheses, not four:
  `hV : branchOrderValid b ord`, `hSat : findUnexpanded b (timeOrd := ord) = none`,
  `hOpen : findClosure b fc = none`, plus `hTot`/`hBA`/`hCheck`/`hTW`, plus
  `hw₀ : l₀.world ∈ b.knownWorlds` and `hroot : ⟨.neg, χ, l₀⟩ ∈ b`. `branchOrderValid` is
  *strictly stronger* than `timeOrderTotal` (it adds `orderIrrefl` and `orderTransOn`), and
  `BridgeProbes.lean:66-72` already pins a branch where `timeOrderTotal = true` while
  `branchOrderValid = false` (a 3-cycle). A `"gated": true` computed from the four named gates
  alone would therefore be a **false theorem-backing claim** — exactly the claim ModelChecker
  intends to rely on.
- **Measured: at `.ZTime` the gates never pass today.** On five open ZTime branches
  (`p → q`, `¬p`, `p ∧ q → r`, `□p → q`, `◇p → p`), `regionLabelCheck` and `temporalWitnessCheck`
  are **`false` on every one**, while the same formulas at `.Base`/`.Dense`/`.RTime` pass all
  gates. Cause identified: `zTimeRules`' `priorUZ`/`priorSZ` (`Tableau.lean:1398-1416`) rewrite
  `T(F ψ)` to `T(U(¬ψ, ψ))`; with the seriality-minted `T(F ⊤)` this puts `T(U(¬⊤, ⊤))` on the
  branch, and the region gate's candidate grid collapses to all-zero. So the honest answer to the
  consumer's question is: **as the engine stands, no `.ZTime` invalid verdict is theorem-backed.**
  The deliverable is still exactly right — it is what makes this visible instead of assumed.
- **`decideAuto` discards the branch**, so the gates cannot be read off `DecisionResult`. The open
  arm of `decide` (`DecisionProcedure.lean:211-213`) keeps only a `SimpleCountermodel`. Recovery is
  a pure, deterministic re-run of `buildTableau φ (soundFuel φ) fc` — the same call `decide` makes —
  which reproduces the identical `(branch, ord)`. Precedent: `extractCountermodelData` already does
  this on the `countermodel` path.
- **`.RTime` is fully supported by the engine**: `FrameClass.RTime` exists (`Axioms.lean:544`),
  `allRulesForFC` has a live `rTimeRules` arm (`Tableau.lean:1657-1670`), and `p → q` at `.RTime`
  produces an open branch with all gates `true`. So deliverable 2's conditional ("if the engine
  supports it") resolves to **accept and map `"RTime" → .RTime`**; no rejection message is needed.
- **A module split is forced by the acceptance criterion.** `TableauBridgeMain.lean` declares a
  root-namespace `main`, and `Tests/BimodalToolsTest` already carries one from
  `C5SmokeTest → DatasetValidatorMain`. Two cannot share one environment
  (`Tests/BimodalToolsTest.lean:11-21`). The bridge must be split into
  `BimodalTools/TableauBridge.lean` (library) + a thin `TableauBridgeMain.lean` (`main` only),
  mirroring `ContrastiveGenerator`/`ContrastiveGeneratorMain`.

## Context & Scope

Researched: what the bridge must compute to make an `invalid` verdict citable via the Lean
theorem; where the open branch and its `TimeOrdering` can be obtained from inside the bridge;
what `frame_class` values the engine genuinely supports; and how to make the result testable
under `lake build BimodalToolsTest`.

Out of scope, and left alone: the tableau engine itself, the region/temporal gate definitions in
`Verified/Bridge/`, and the `"status"` vocabulary of the protocol (the new field is additive per
deliverable 1).

Constraint honoured throughout: no `sorry`, no new axiom, no deferral. Everything below is
decidable `Bool` computation on the finished branch plus JSON emission; no new proof obligation
is created.

## Findings

### Codebase Patterns

**1. The theorem's real hypothesis list.** `IntTruth.lean:1045-1058` and `:1073-1086`:

| Hypothesis | Decidable expression on the bridge's side |
|---|---|
| `hV : branchOrderValid b ord = true` | `branchOrderValid b ord` (`BranchOrder.lean:149`) |
| `hSat : findUnexpanded b (timeOrd := ord) = none` | `(findUnexpanded b (timeOrd := ord)).isNone` — note the `fc` argument **defaults to `.Base`** here |
| `hOpen : findClosure b fc = none` | `(findClosure b fc).isNone` (`Closure.lean:135`) |
| `hTot : timeOrderTotal b ord = true` | `timeOrderTotal b ord` (`Saturation.lean:234`) |
| `hBA : boxAnchoredCheck b = true` | `boxAnchoredCheck b` (`BoxSaturation.lean:506`) |
| `hCheck : regionLabelCheck b ord = true` | `regionLabelCheck b ord` (`RegionLabel.lean:254`) |
| `hTW : temporalWitnessCheck b ord = true` | `temporalWitnessCheck b ord` (`TemporalGate.lean:364`) |
| `hw₀ : l₀.world ∈ b.knownWorlds` | `Label.initial.world ∈ b.knownWorlds` |
| `hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b` | `b.contains (SignedFormula.neg φ Label.initial)` |

The section variables are `{b : Branch} {ord : TimeOrdering}` only (`IntTruth.lean:928-930`) — no
typeclass hypotheses to discharge. `branchOrderValid = timeOrderTotal && orderIrrefl &&
orderTransOn` (`BranchOrder.lean:149`); the unpacking lemmas at `:156-175` show `hTot` is
*implied* by `hV`, so the theorem's `hTot` is redundant — but the converse is not, which is the
point.

The last two rows are cheap and non-vacuous: the root `F(φ) @ (world 0, time 0)` was observed
present on every open branch dumped this session (expansion is non-destructive — see the caveat
paragraph at `Saturation.lean:220-226`).

**2. Where the branch lives.** `decide` (`DecisionProcedure.lean:176-213`) reaches
`buildTableau φ_n tableauFuel fc`, matches `.hasOpen openBranch _ord _fc hSat`, and **discards
`_ord` and the branch**, returning `.invalid (extractCountermodelSimple φ_n openBranch hSat)`.
`decideAuto φ fc` (`:365`) is `decide φ (5 + φ.complexity / 2) (soundFuel φ) fc`.

`buildTableau` is pure and total, so re-running `buildTableau φ (soundFuel φ) fc` from the bridge
reproduces the same `(branch, ord)` bit for bit. `normalizeFormula` is definitionally the identity
(`DecisionProcedure.lean:181-183`), so passing the un-normalized `φ` is equivalent.

Existing precedent for exactly this re-run: `extractCountermodelData`
(`DatasetGenerator.lean:406-415`), already called on the bridge's `countermodel` path
(`TableauBridgeMain.lean:521`).

**3. A pre-existing defect on the `countermodel` path, found in passing.**
`extractCountermodelData φ fuel` calls `buildTableau φ fuel` with **no `fc` argument**, so it
defaults to `.Base` (`DatasetGenerator.lean:408`). A `countermodel` request at
`frame_class: "ZTime"` therefore returns an enriched/semantic countermodel extracted from a
`.Base` tableau. These are genuinely different objects: measured, `p → q` gives a 13-formula
branch at `.Base` and a 17-formula branch at `.ZTime`. Fixing this is a one-argument change
(`buildTableau φ fuel fc`) and is in the spirit of deliverable 1, which names the countermodel
command explicitly.

**4. Frame classes the engine actually has.** `FrameClass := Base | Dense | ZTime | RTime`
(`Axioms.lean:540-545`). `allRulesForFC` (`Tableau.lean:1657-1670`) has four live arms:
`rTimeRules ++ allRules ++ denseRules ++ zTimeRules`, gated by `Dense ≤ fc`, `ZTime ≤ fc`,
`RTime ≤ fc` respectively. The order is a partial order in which `ZTime` and `RTime` are
incomparable (`Axioms.lean:547-555`), which is why an `.RTime` run gets the Dedekind rules but
**not** the discrete ones. `frameClassToString` (`ProofStepExtractor.lean:201-205`, already
`open`ed by the bridge) round-trips all four names.

**5. Executable-root collision.** `Tests/BimodalToolsTest.lean:11-21` records the rule in the
codebase's own words: an executable root declares a root-namespace `main`, two cannot share an
environment, and the sanctioned fix is a library/`Main` split
(`ContrastiveGenerator`/`ContrastiveGeneratorMain`, `ProofFirstGenerator`/`ProofFirstGeneratorMain`).
`C5SmokeTest` imports `BimodalTools.DatasetValidatorMain`, so `BimodalToolsTest` already holds a
`main`. A test importing `BimodalTools.TableauBridgeMain` will not compile.

**6. README inventory is machine-owned.** `BimodalTools/README.md:33` opens a
`<!-- BEGIN GENERATED: inventory dir=BimodalTools -->` block. Adding a module or changing a line
count without re-emitting fails the `INV` check in `scripts/check-module-invariants.sh`. The
regeneration command is `bash scripts/check-module-invariants.sh --emit-inventory`
(`scripts/readme-inventory.sh` is a deprecated shim that only prints this).

**7. Response construction is string concatenation, not a JSON library**
(`TableauBridgeMain.lean:440-462`), with `escapeJsonString` / `listToJsonArray` from
`BimodalTools/DataExport.lean`. The new `"gates"` object follows the same idiom.

### External Resources

No Mathlib search was required: every gate, the decision entry, and the theorem are all
first-party declarations in this repository. The Lean MCP search tools (leansearch / loogle /
leanfinder) were not called — the relevant names were already known from the task description
and were resolved by `grep` + direct file reads, which is cheaper and exact. No MCP failure or
rate limit was encountered.

### Recommendations

**R1 — Split the module first.** Create `BimodalTools/TableauBridge.lean` holding everything
currently in `namespace BimodalTools.TableauBridgeMain` (parser, `BridgeCommand`, `BridgeRequest`,
handlers, `replLoop`), and reduce `BimodalTools/TableauBridgeMain.lean` to the header comment plus
`def main (_args : List String) : IO Unit := BimodalTools.TableauBridge.replLoop`. Rename the
namespace to `BimodalTools.TableauBridge` to match the file. Add
`import BimodalTools.TableauBridge` to `BimodalTools.lean` (alphabetically, after
`ProofStepExtractor`). No `lakefile.toml` change: the `tableau_bridge` exe root stays
`BimodalTools.TableauBridgeMain`.

**R2 — One gate-evaluation helper, used by both commands.** In `TableauBridge.lean`:

```lean
structure BranchGates where
  timeOrderTotal    : Bool   -- the four the task names
  boxAnchored       : Bool
  regionLabel       : Bool
  temporalWitness   : Bool
  branchOrderValid  : Bool   -- the further theorem hypotheses
  saturated         : Bool   -- findUnexpanded b ord = none, at .Base as the theorem states it
  noClosure         : Bool   -- findClosure b fc = none
  rootDenied        : Bool   -- F(φ) @ Label.initial still on the branch
```

with `BranchGates.gated` the conjunction of **all eight**, `BranchGates.toJson`, and

```lean
def evalBranchGates (φ : Formula) (fc : FrameClass) : Option BranchGates :=
  match buildTableau φ (soundFuel φ) fc with
  | some (.hasOpen b ord _ _) => some { … }
  | _ => none
```

Emit `"gates": null` (and no `"gated"`, or `"gated": false`) in the `none` case, which is
unreachable in practice but must not be guessed at. Required imports: the three
`Verified/Bridge/{BoxSaturation,RegionLabel,TemporalGate}.lean` modules plus `BranchOrder.lean`
— all already on `FormalSystem`'s default build path, so no new build cost beyond the bridge's
own compile.

**R3 — `gated` must mean what ModelChecker will read it to mean.** Report the four named gates
under their own keys exactly as deliverable 1 asks, report the four further hypotheses alongside
them, and define `"gated"` as the conjunction of all eight. Anything less makes `"gated": true`
assertable on a branch whose time order contains a cycle. See "Decisions" below.

**R4 — Make `parseFrameClass` fallible, and thread it through the existing error path.**

```lean
def parseFrameClass (s : String) : Except String FrameClass :=
  match s with
  | "Base" => .ok .Base
  | "Dense" => .ok .Dense
  | "ZTime" | "Discrete" => .ok .ZTime
  | "RTime" => .ok .RTime
  | _ => .error s!"unknown frame_class: '{s}' (expected one of: Base, Dense, ZTime, Discrete, RTime)"
```

`parseRequest` is already `Except String BridgeRequest` and `replLoop` already maps `.error msg`
to `mkErrorResponse msg` (`TableauBridgeMain.lean:608-611`), so the deliverable's
`{"status": "error", "message": ...}` shape falls out with no new plumbing. `"RTime"` is
**accepted**, not rejected — finding 4 above settles the deliverable's conditional.

**R5 — Factor the response body pure so it can be `#guard`-tested.** The handlers are `IO String`
only for `IO.monoMsNow`. Extract `def decideResponseBody (φ : Formula) (fc : FrameClass) : String`
(everything but `time_ms`) and let `handleDecide` wrap it with the timing. This is what makes the
acceptance tests `#guard` rows rather than `IO` harnesses.

**R6 — Test rows, chosen from measured behaviour** (table in "Tactic Survey Results"):
- *gated invalid*: `p → q` at `"Base"` — all eight true.
- *ungated invalid*: `p → q` at `"ZTime"` — `regionLabel` and `temporalWitness` false. (A
  `.Base`-only alternative if a same-class pair is wanted: `◇p → p` at `"Base"`, also
  `regionLabel`/`temporalWitness` false.)
- *frame_class rejection*: `parseFrameClass "RTime"` = `.ok .RTime` and `parseFrameClass "Bogus"`
  is `.error`, plus a `parseRequest` row on a full line with `"frame_class": "Bogus"`.
- Keep fuel small: `soundFuel (p → q)` is well under the 100000 cap and these rows elaborate in
  seconds, but avoid adding modal/temporal rows that `STALL` (measured: `p → □p` at `.ZTime`,
  `S(q,p) → p` at `.ZTime`).

**R7 — Documentation.** Module docstring "## Protocol" section (`TableauBridgeMain.lean:30-42`,
moving to `TableauBridge.lean`): add the `frame_class` value list with the rejection behaviour,
and an `invalid` response example carrying `"gates"`/`"gated"`, with one sentence naming
`not_valid_of_hasOpen_int` / `not_validZTime_of_hasOpen_int` as what `"gated": true` licenses.
`BimodalTools/README.md`: the file has **no** prose section on the bridge at all today (only the
generated inventory row), so add a short "Tableau bridge protocol" section above "## Contents",
then re-emit the inventory.

**R8 — Fix `extractCountermodelData`'s dropped `fc`** (finding 3) as part of deliverable 1's
"and the countermodel command" clause, or, if that is judged out of scope, record it explicitly
rather than leaving it silent.

## Decisions

- **`gated` is the conjunction of all eight hypotheses, not the four named ones.** Recorded here
  as a decision rather than deferred, on the evidence of `BridgeProbes.lean:66-72`
  (`timeOrderTotal = true`, `branchOrderValid = false` on a 3-cycle). The four named booleans
  still appear under their own keys, so deliverable 1 is met literally; the additional keys are
  additive in the same sense the deliverable already sanctions. Surfaced as a non-blocking
  `user_decision` because it reinterprets the deliverable's `"gated"` clause.
- **`"RTime"` is accepted and mapped to `.RTime`.** The deliverable's conditional is resolved by
  measurement, not by assumption: `allRulesForFC` has a live Dedekind arm and an `.RTime` run
  produces a gated-true open branch.
- **The branch is recovered by re-running `buildTableau`, not by changing `DecisionResult`.**
  Widening `DecisionResult.invalid` to carry the branch would touch `FormalSystem` and every
  consumer of the decision procedure; the re-run is local to `BimodalTools`, deterministic, and
  already the established idiom on the countermodel path. Cost is one extra tableau build on the
  invalid path only.
- **No Lean MCP search tools were called.** Every name needed is first-party; `grep` plus file
  reads resolved all of them exactly. Recorded so the absence is not read as an omission.

## Risks & Mitigations

- **Risk**: `"gated"` is read by ModelChecker as "the Lean theorem applies", while the four-gate
  reading would let a cyclic time order through. **Mitigation**: R3 (eight-way conjunction), plus
  naming the theorem in the docstring so the claim is auditable.
- **Risk**: the headline measurement — no `.ZTime` invalid verdict is gated today — makes the
  consumer's verdict matrix ("only counts as evidence when the branch gates pass") vacuous at the
  class it cares about. **Mitigation**: this is a true fact about the engine, and reporting it is
  the deliverable's purpose. It should be relayed to the ModelChecker side rather than worked
  around here; a gate repair is a separate, much larger task (it means changing `regionLabelCheck`
  or `priorUZ`/`priorSZ`, both inside `Verified/`).
- **Risk**: the double tableau build doubles worst-case latency on invalid queries.
  **Mitigation**: compute the gates and the enriched countermodel from a *single* re-run inside
  `handleCountermodel` (one `buildTableau`, both consumers), and accept the second build on
  `handleDecide`, which does not otherwise re-run. If latency proves material, a later change can
  have `handleDecide` drive `buildTableau` itself and call the fast paths only when the tableau
  closes.
- **Risk**: the module split changes an executable root, and a stale `.olean` or a missed
  `BimodalTools.lean` import shows up only at `lake build BimodalToolsTest`. **Mitigation**: build
  `BimodalTools`, `BimodalToolsTest`, and `lake exe tableau_bridge` in that order, and run
  `bash scripts/check-module-invariants.sh` (B3 + INV) before committing.
- **Risk**: a sibling task (665) is dispatched against the same working tree this cycle with no
  declared `file_scope`. **Mitigation**: re-read each file immediately before editing, stage only
  this task's own files by explicit path, and treat an unexpected failure outside
  `BimodalTools/`, `Tests/BimodalToolsTest/` as possibly foreign.

## Tactic Survey Results

No proof obligations arise from this task — every addition is `Bool` computation and JSON
emission — so the tactic pipeline (`simp`/`omega`/`aesop`/`decide`) has nothing to close and
`lean_multi_attempt` / `lean_hammer_premise` were not applicable. In its place, the executable
measurement that *did* drive the recommendations, run this session via `lake env lean` against
the built tree:

| Formula | Frame class | Outcome | tot | bov | box | region | tw | gated (8-way) |
|---|---|---|---|---|---|---|---|---|
| `p → q` | Base | open, \|W\|=1 \|T\|=4 | true | true | true | **true** | **true** | **true** |
| `p → q` | Dense | open, \|W\|=1 \|T\|=4 | true | true | true | true | true | true |
| `p → q` | RTime | open, \|W\|=1 \|T\|=4 | true | true | true | true | true | true |
| `p → q` | ZTime | open, \|W\|=1 \|T\|=4 | true | true | true | **false** | **false** | **false** |
| `¬p` | ZTime | open, \|W\|=1 \|T\|=4 | true | true | true | false | false | false |
| `p ∧ q → r` | Base | open, \|W\|=1 \|T\|=4 | true | true | true | true | true | true |
| `p ∧ q → r` | ZTime | open, \|W\|=1 \|T\|=4 | true | true | true | false | false | false |
| `□p → q` | Base | open, \|W\|=1 \|T\|=4 | true | true | true | true | true | true |
| `□p → q` | ZTime | open, \|W\|=1 \|T\|=4 | true | true | true | false | false | false |
| `p → □p` | Base | open, \|W\|=2 \|T\|=4 | true | true | true | false | false | false |
| `◇p → p` | Base | open, \|W\|=2 \|T\|=4 | true | true | true | false | false | false |
| `◇p → p` | ZTime | open, \|W\|=2 \|T\|=7 | true | true | true | false | false | false |
| `U(q,p) → p` | Base | open, \|W\|=1 \|T\|=5 | true | true | true | false | false | false |
| `S(q,p) → p` | Base | open, \|W\|=1 \|T\|=5 | true | true | true | false | false | false |
| `p → U(p,⊤)` | ZTime | open, \|W\|=1 \|T\|=4 | true | true | true | false | false | false |
| `p → □p` | ZTime | STALLED (fuel 24) | — | — | — | — | — | — |
| `□p → □q` | ZTime | STALLED (fuel 160) | — | — | — | — | — | — |
| `S(q,p) → p` | ZTime | STALLED | — | — | — | — | — | — |
| `p → (q → p)` | ZTime | CLOSED (valid) | — | — | — | — | — | — |

`tot` = `timeOrderTotal`, `bov` = `branchOrderValid`, `box` = `boxAnchoredCheck`,
`region` = `regionLabelCheck`, `tw` = `temporalWitnessCheck`. `saturated` and `noClosure` were
`true` on every open row. Every row used `buildTableau φ (soundFuel φ) fc`, i.e. the exact call
`decideAuto` makes.

Root cause of the ZTime column, established by dumping both branches: the `.ZTime` branch for
`p → q` carries 17 signed formulas against `.Base`'s 13, the four extras being
`T(U(¬⊤, ⊤))` and `T(S(¬⊤, ⊤))` at two labels. These are `priorUZ`/`priorSZ`
(`Tableau.lean:1398-1416`: `T(F ψ) → T(U(ψ.neg, ψ))`) firing on the seriality-minted `T(F ⊤)`.
The region candidate grid for that branch is `[[0,0,0,0,0]]` — every region of the single known
world has zero eligible labels, because the imported demands include a positive `¬⊤`.

## Context Extension Recommendations

- **Topic**: the tableau bridge's JSONL protocol as a versioned external contract.
- **Gap**: the protocol lives only in one Lean module docstring, and an external repository
  (ModelChecker) is now building an oracle against it. There is no place recording which fields
  are stable, which are additive, and what a consumer may infer from each `status`.
- **Recommendation**: after this task lands, add
  `.claude/context/project/lean4/tools/tableau-bridge-protocol.md` capturing the request/response
  schema, the frame-class vocabulary, and — specifically — the difference between a theorem-backed
  and a heuristic `invalid`. The `comparator-guide.md` trust-model file already in that directory
  is the right shape to mirror.

## Appendix

**Searches used**: `grep -rn` over `FormalSystem/`, `BimodalTools/`, `Tests/` for
`def timeOrderTotal|def boxAnchoredCheck|def regionLabelCheck|def temporalWitnessCheck|def branchOrderValid`,
`def decideAuto|inductive DecisionResult|def soundFuel`, `def buildTableau`, `inductive FrameClass`,
`def frameClassToString`, `extractCountermodelData`, `not_valid_of_hasOpen`. No Lean MCP search
tool (leansearch / loogle / leanfinder / state_search / hammer_premise) was invoked; see
"Decisions".

**Measurement method**: four scratch `#eval` files elaborated with
`lake env lean <file>` against the pre-built `.lake/build` tree (no rebuild required). The files
are throwaway; the rows they produced are transcribed in full above.

**Key source locations**:
- `BimodalTools/TableauBridgeMain.lean:297-302` — `parseFrameClass`, the silent `_ => .Base` arm
- `BimodalTools/TableauBridgeMain.lean:379-381` — `frame_class` key in `parseRequest`
- `BimodalTools/TableauBridgeMain.lean:446-451` — `handleDecide`'s `.invalid` arm
- `BimodalTools/TableauBridgeMain.lean:519-535` — `handleCountermodel`'s `.invalid` arm
- `BimodalTools/TableauBridgeMain.lean:608-611` — `replLoop`'s existing `.error → mkErrorResponse`
- `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:211-213` — where the branch is dropped
- `FormalSystem/Metalogic/Decidability/Saturation.lean:1161-1184` — `buildTableau`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean:1045,1073` — the two theorems
- `Tests/BimodalTest/Metalogic/Decidability/Verified/BridgeProbes.lean:62-72` — `timeOrderTotal`
  true / `branchOrderValid` false
- `Tests/BimodalToolsTest.lean:11-21` — the root-`main` collision rule
