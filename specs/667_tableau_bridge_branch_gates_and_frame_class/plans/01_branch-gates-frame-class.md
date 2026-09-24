# Implementation Plan: Tableau bridge branch gates and frame class

- **Task**: 667 - Tableau bridge branch gates and frame class
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: `specs/667_tableau_bridge_branch_gates_and_frame_class/reports/01_branch-gates-frame-class.md`
- **Artifacts**: plans/01_branch-gates-frame-class.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The tableau bridge returns `{"status": "invalid", ...}` from an open saturated branch without
ever evaluating the gates that make that verdict citable via `not_valid_of_hasOpen_int` /
`not_validZTime_of_hasOpen_int`, and silently coerces any unrecognized `frame_class` string to
`.Base`. This plan adds an additive `"gates"` object to the invalid arm of both `tableau_decide`
and `countermodel`, makes `parseFrameClass` fallible (accepting `Base`, `Dense`, `ZTime`,
`Discrete`, `RTime` and rejecting everything else through the existing error path), and documents
both changes. Definition of done: `lake build BimodalTools`, `lake build BimodalToolsTest` and
`lake exe tableau_bridge` all green, new `Tests/BimodalToolsTest/TableauBridgeTest.lean` rows
covering a gated invalid verdict, an ungated one and a `frame_class` rejection, and
`scripts/check-module-invariants.sh` clean.

### Research Integration

Five findings from `reports/01_branch-gates-frame-class.md` shape the phase structure directly:

1. **The theorem takes eight hypotheses, not four.** `IntTruth.lean:1045,1073` require
   `branchOrderValid`, `findUnexpanded … = none` (at the default `fc := .Base`), `findClosure b fc
   = none` and root-denial in addition to the four named gates. `branchOrderValid` is strictly
   stronger than `timeOrderTotal` — `BridgeProbes.lean:62-72` pins a branch where `timeOrderTotal
   = true` and `branchOrderValid = false` on a 3-cycle. The `.decisions.json` answer relayed in
   this round's dispatch settles the reading: report all eight booleans, each of the four named
   gates under its own key, and define `"gated"` as the eight-way conjunction.
2. **The branch is not recoverable from `DecisionResult`.** `decide`
   (`DecisionProcedure.lean:211-213`) discards the branch and the `TimeOrdering`. The gates are
   computed by re-running `buildTableau φ (soundFuel φ) fc` — the exact call `decideAuto` makes —
   which is pure and total and reproduces the same `(branch, ord)`. `extractCountermodelData` is
   the existing precedent for this re-run.
3. **A module split is forced by the acceptance criterion.** `TableauBridgeMain.lean` declares a
   root-namespace `main`; `Tests/BimodalToolsTest.lean` already carries one via
   `C5SmokeTest → DatasetValidatorMain`. A test importing the bridge will not compile until the
   bridge is split library/`Main`, as `ContrastiveGenerator`/`ContrastiveGeneratorMain` already
   are. Phase 1 exists solely because of this.
4. **`RTime` is genuinely supported**, so deliverable 2's conditional resolves to *accept*:
   `FrameClass.RTime` exists (`Axioms.lean:544`), `allRulesForFC` has a live `rTimeRules` arm
   (`Tableau.lean:1657-1670`), and `p → q` at `.RTime` produced an open branch with all gates
   true. No "engine does not support it" rejection message is needed.
5. **Measured: at `.ZTime` the gates never pass today.** On five open ZTime branches
   `regionLabelCheck` and `temporalWitnessCheck` were false on every one. This is a true fact
   about the engine, not a defect this task repairs — making it visible is the deliverable's
   purpose. It also supplies the ungated test row for free.

Two items the research surfaced that this plan folds in: `extractCountermodelData φ fuel` drops
the frame class (defaults to `.Base`), so a `countermodel` request at `"ZTime"` today extracts
from a `.Base` tableau (Phase 3 fixes it, a one-argument change, inside deliverable 1's "and the
countermodel command" clause); and `BimodalTools/README.md`'s Contents table is a generated
inventory block that must be re-emitted after any line-count change (Phase 6).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch; no ROADMAP.md consultation was performed.

## Goals & Non-Goals

**Goals**:
- Split `BimodalTools/TableauBridgeMain.lean` into `BimodalTools/TableauBridge.lean` (library) plus
  a thin executable root, so the bridge is importable by `BimodalToolsTest`.
- Add a `BranchGates` record with eight booleans plus `gated`, computed from a deterministic
  `buildTableau` re-run, and emit it as an additive `"gates"` object on the `.invalid` arm of both
  `tableau_decide` and `countermodel`, leaving `"status": "invalid"` unchanged.
- Make `parseFrameClass` fallible: accept `Base`, `Dense`, `ZTime`, `Discrete` (alias for `ZTime`)
  and `RTime`; reject anything else with `{"status": "error", "message": ...}` via the existing
  `parseRequest`/`replLoop` error path.
- Pass the request's frame class to `extractCountermodelData` so the enriched countermodel is
  extracted from the same tableau the verdict came from.
- Document the `"gates"` field, the frame-class vocabulary, and what `"gated": true` licenses, in
  the module docstring's protocol section and in `BimodalTools/README.md`.
- Cover a gated invalid verdict, an ungated invalid verdict and a `frame_class` rejection in
  `Tests/BimodalToolsTest/`.

**Non-Goals**:
- Repairing the `.ZTime` region/temporal gates (a change inside `Verified/Bridge/` or to
  `priorUZ`/`priorSZ`; separate and much larger).
- Changing `DecisionResult` or any `FormalSystem` module to carry the branch.
- Changing the `"status"` vocabulary of the protocol, or any existing response field.
- Adding a wall-clock timeout or abort ref to the bridge.
- Writing `.claude/context/project/lean4/tools/tableau-bridge-protocol.md` (the research's context
  extension recommendation — a follow-up, not part of this task's deliverables).

## Lean Challenge Statements

This section is intentionally empty. The task creates **no proof obligations**: every addition is
`Bool` computation on a finished branch plus JSON string emission, and no `theorem`, `lemma` or
`sorry` is introduced. The `- **Goals**:` bullets above accordingly name no theorem identifiers,
so the identifier-set equality this section requires holds vacuously (empty set on both sides).
Recorded explicitly so the absence reads as a decision rather than an omission.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `"gated"` read by ModelChecker as "the Lean theorem applies" while a weaker four-gate reading lets a cyclic time order through | H | M | Eight-way conjunction (Phase 2), with the four named gates keeping their own keys; the docstring (Phase 6) names both theorems so the claim is auditable |
| The module split changes an executable root; a stale `.olean` or a missed `BimodalTools.lean` import surfaces only at `lake build BimodalToolsTest` | H | M | Phase 1 builds `BimodalTools` and `lake exe tableau_bridge` before anything else lands; Phase 7 re-runs the full ladder in order |
| `hSat` is `findUnexpanded b (timeOrd := ord) = none` at the theorem's **default** `fc := .Base`, while `ExpandedTableau.hasOpen`'s own certificate is at the request's `fc` — computing the wrong one makes `gated` a false claim at `.Dense`/`.ZTime`/`.RTime` | H | M | Phase 2 computes the `saturated` field at the default `.Base` exactly as the theorem states it, with an in-source comment recording why it is not the request's `fc`; Phase 5 pins a `.ZTime` row |
| Double tableau build doubles worst-case latency on the invalid path | L | H | `handleCountermodel` drives a single re-run feeding both the gates and the enriched countermodel (Phase 3); `handleDecide` accepts one extra build, which it does not otherwise perform |
| A test row picks a formula that STALLs (measured: `p → □p`, `□p → □q`, `S(q,p) → p` at `.ZTime`) and hangs the test build | M | M | Phase 5 uses only formulas with measured outcomes from the research's survey table: `p → q` at `Base` and at `ZTime` |
| Sibling task 665 is dispatched against this same working tree this cycle with no declared `file_scope` | M | M | Re-read every file immediately before editing; stage only this task's own files by explicit path (never a directory or glob pathspec); treat an unexpected failure outside `BimodalTools/` and `Tests/BimodalToolsTest/` as possibly foreign and report rather than "fix" it |
| README inventory block goes stale when line counts change, turning `INV` red | L | H | Phase 6 re-emits with `bash scripts/check-module-invariants.sh --emit-inventory` after all source edits are final |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |

Phases within the same wave can execute in parallel.

Phases 2, 3 and 4 all edit `BimodalTools/TableauBridge.lean` and are therefore chained rather
than waved, even though their edit regions are disjoint: two agents writing one file in one wave
is a conflict, not a parallelism opportunity.

---

### Phase 1: Split the bridge into library plus executable root [COMPLETED]

**Goal**: `BimodalTools.TableauBridge` is importable by a test module; `lake exe tableau_bridge`
still runs.

**Tasks**:
- [ ] Create `BimodalTools/TableauBridge.lean` with the standard copyright header, the module
      docstring currently at `TableauBridgeMain.lean:11-60`, the four `import` lines, and the
      whole body of `namespace BimodalTools.TableauBridgeMain` (lines 64-624: the `open`s, parser
      state, `BridgeCommand`, `BridgeRequest`, `parseFrameClass`, `parseCommand`, `pNat`,
      `parseRequest`, the response builders, the three handlers, `dispatch`, `replLoop`).
- [ ] Rename the namespace to `BimodalTools.TableauBridge` at both the opening and the `end` line.
- [ ] Reduce `BimodalTools/TableauBridgeMain.lean` to: copyright header, a short module docstring
      pointing at `BimodalTools.TableauBridge` for the protocol, `import BimodalTools.TableauBridge`,
      and `def main (_args : List String) : IO Unit := BimodalTools.TableauBridge.replLoop`. Mirror
      `BimodalTools/ProofFirstGeneratorMain.lean` (21 lines) for shape and length.
- [ ] Add `import BimodalTools.TableauBridge` to `BimodalTools.lean`, alphabetically (after
      `ProofStepExtractor`, before `TraceExport`).
- [ ] Leave `lakefile.toml` untouched: the `tableau_bridge` exe root stays
      `BimodalTools.TableauBridgeMain`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the move is asserted to be the contiguous block `TableauBridgeMain.lean:64-624`
into a new file, with `BimodalTools.lean` and `TableauBridgeMain.lean` as the only other files
touched and no `lakefile.toml` change. Confirm at implementation time by re-reading the file
immediately before editing (line numbers may have drifted), by `grep -n "^namespace\|^end "` on
the new file returning exactly one pair, and by `lake exe tableau_bridge` starting and answering a
`{"command": "ping"}` line after the split.

**Files to modify**:
- `BimodalTools/TableauBridge.lean` - new; receives the whole library body
- `BimodalTools/TableauBridgeMain.lean` - reduced to header, docstring pointer, import, `main`
- `BimodalTools.lean` - one new import line

**Verification**:
- `lake build BimodalTools` green
- `lake exe tableau_bridge` starts, prints `{"status": "ready"}`, answers `{"command": "ping"}`
  with `{"status": "pong"}`, and exits on `{"command": "shutdown"}`
- Response bytes for one `tableau_decide` request are unchanged from before the split (capture the
  before-output first, while the pre-split binary is still built)

---

### Phase 2: BranchGates record and evaluator [COMPLETED]

**Goal**: `evalBranchGates φ fc` returns the eight theorem hypotheses as booleans plus their
conjunction, with a JSON serializer.

**Tasks**:
- [ ] Add imports for the four gate modules to `BimodalTools/TableauBridge.lean`:
      `FormalSystem.Metalogic.Decidability.Verified.Bridge.BranchOrder`,
      `.BoxSaturation`, `.RegionLabel`, `.TemporalGate`.
- [ ] Define `structure BranchGates` with the four named gates (`timeOrderTotal`, `boxAnchored`,
      `regionLabel`, `temporalWitness`) and the four further theorem hypotheses
      (`branchOrderValid`, `saturated`, `noClosure`, `rootDenied`).
- [ ] Define `BranchGates.gated : BranchGates → Bool` as the conjunction of all eight fields.
- [ ] Define `BranchGates.toJson : BranchGates → String` emitting one key per field plus
      `"gated"`, using the `escapeJsonString`-free plain-boolean idiom already used for
      `"consistent"` in `handleCountermodel`.
- [ ] Define `evalBranchGates (φ : Formula) (fc : FrameClass) : Option BranchGates`, matching
      `buildTableau φ (soundFuel φ) fc` against `some (.hasOpen b ord _ _)` and computing each
      field: `timeOrderTotal b ord`, `boxAnchoredCheck b`, `regionLabelCheck b ord`,
      `temporalWitnessCheck b ord`, `branchOrderValid b ord`,
      `(findUnexpanded b (timeOrd := ord)).isNone`, `(findClosure b fc).isNone`, and
      `b.contains (SignedFormula.neg φ Label.initial)` (adapt to whatever `Branch = List
      SignedFormula` membership decides; `List.contains` with the derived `BEq`/`DecidableEq`).
      Every other match arm returns `none`.
- [ ] Record in an in-source comment on the `saturated` field that `findUnexpanded` is called at
      its **default** `fc := .Base`, because that is what `not_valid_of_hasOpen_int`'s `hSat`
      states — deliberately not the request's frame class, which is what
      `ExpandedTableau.hasOpen`'s own certificate field carries.
- [ ] Record in the `BranchGates` docstring that `gated` is the eight-way conjunction and cite
      `not_valid_of_hasOpen_int` / `not_validZTime_of_hasOpen_int`
      (`FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`) as the consumers.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `BimodalTools/TableauBridge.lean` - new imports, `BranchGates`, `gated`, `toJson`,
  `evalBranchGates`

**Verification**:
- `lake build BimodalTools` green
- A scratch `#eval evalBranchGates (p → q) .Base` reproduces the research's measured row (all
  eight `true`) and `#eval evalBranchGates (p → q) .ZTime` reproduces its row (`regionLabel` and
  `temporalWitness` `false`, `gated` `false`). Run these under `lake env lean` on a throwaway
  file; they become permanent rows in Phase 5, not here.

---

### Phase 3: Wire the gates into both invalid arms [COMPLETED]

**Goal**: `tableau_decide` and `countermodel` each carry `"gates"` on their `.invalid` arm, and
the countermodel re-run uses the request's frame class.

**Tasks**:
- [ ] Extract the pure response body of `handleDecide` into
      `def decideResponseBody (φ : Formula) (fc : FrameClass) : String` — everything except
      `time_ms` — and reduce `handleDecide` to timing plus splicing `time_ms` into the body. This
      is what makes Phase 5's rows `#guard`-able rather than `IO` harnesses.
- [ ] On the `.invalid` arm of `decideResponseBody`, call `evalBranchGates φ fc` and append
      `, "gates": <BranchGates.toJson>` after the existing `"countermodel"` field. Keep
      `"status": "invalid"` and every existing field byte-identical.
- [ ] On the `none` result of `evalBranchGates`, emit `"gates": null` and no `"gated"` key.
      Document in a comment that this arm is unreachable whenever `decideAuto` returned
      `.invalid` (both run `buildTableau φ (soundFuel φ) fc`), and is present so the case is not
      guessed at.
- [ ] In `handleCountermodel`, bind the tableau re-run **once** and feed both the gates and the
      enriched countermodel from it, so the invalid path performs one extra build rather than two.
- [x] Pass the request's frame class to `extractCountermodelData` (currently
      `extractCountermodelData φ fuel`, which defaults the tableau to `.Base`). If the function's
      signature has no `fc` parameter, add one defaulting to `.Base` in
      `BimodalTools/DatasetGenerator.lean` and pass it through to its `buildTableau` call — check
      the signature first and prefer the no-signature-change route if one exists.
      *(deviation: altered — `extractCountermodelData` has no `fc` parameter (checked:
      `BimodalTools/DatasetGenerator.lean:406`, `buildTableau φ fuel` at the `.Base` default), so
      the no-signature-change route the task explicitly prefers was taken: `handleCountermodel`
      now inlines the one `buildTableau φ fuel fc` re-run and derives the enriched/semantic
      countermodels and the gates from it, instead of calling `extractCountermodelData`. This
      also satisfies the "bind the tableau re-run once" bullet above. `DatasetGenerator.lean` is
      therefore untouched and its other call site — line 1320 — is unaffected.)*
- [ ] Append the same `"gates"` field to `handleCountermodel`'s `.invalid` response, after
      `"semantic_countermodel"`.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts that `BimodalTools/TableauBridge.lean` is the only file
edited — i.e. that `extractCountermodelData` already accepts a `FrameClass`. Confirm at
implementation time with `grep -n "def extractCountermodelData" -A 4
BimodalTools/DatasetGenerator.lean`; if it does not, `DatasetGenerator.lean` joins the file list
and this phase's tier rises to `interface` (the function has other call sites — enumerate them
with `grep -rn extractCountermodelData` before editing).

**Files to modify**:
- `BimodalTools/TableauBridge.lean` - `decideResponseBody`, `handleDecide`, `handleCountermodel`
- `BimodalTools/DatasetGenerator.lean` - conditional; only if `extractCountermodelData` needs an
  `fc` parameter (see Scope Hypothesis)

**Verification**:
- `lake build BimodalTools` green
- `lake exe tableau_bridge` answers a `tableau_decide` request for `p → q` at `"Base"` with a
  response carrying `"status": "invalid"`, every pre-existing field unchanged, and a `"gates"`
  object whose `"gated"` is `true`
- The same request at `"ZTime"` returns `"gated": false`
- A `valid` request's response bytes are unchanged (no `"gates"` key on the valid arm)

---

### Phase 4: Fallible frame-class parsing [COMPLETED]

**Goal**: an unrecognized `frame_class` produces `{"status": "error", "message": ...}`; `"RTime"`
is accepted and mapped to `.RTime`.

*(deviation: altered — Phases 2, 3 and 4 were applied in one edit pass and verified by one
`lake build BimodalTools`, then committed together. The plan chains them only because they share
one file and "two agents writing one file in one wave is a conflict"; a single agent editing three
disjoint regions of that file has no such conflict. Each phase's own verification steps were still
run individually — see the Verification bullets below and in Phases 2 and 3.)*

**Tasks**:
- [ ] Change `parseFrameClass` to `def parseFrameClass (s : String) : Except String FrameClass`
      with arms `"Base" => .ok .Base`, `"Dense" => .ok .Dense`, `"ZTime" | "Discrete" => .ok
      .ZTime`, `"RTime" => .ok .RTime`, and a `_` arm returning
      `.error s!"unknown frame_class: '{s}' (expected one of: Base, Dense, ZTime, Discrete, RTime)"`.
- [ ] Update the docstring: replace "Unrecognized strings default to `.Base`" with the accepted
      vocabulary and the rejection behaviour, and note that `Discrete` is an alias for `ZTime`
      while `RTime` is the Dedekind class (`ZTime` and `RTime` are incomparable in
      `FrameClass`'s partial order, `Axioms.lean:547-555`).
- [ ] In `parseRequest`'s `frame_class` branch, bind `frameClass ← parseFrameClass val`. The
      function is already `Except String BridgeRequest` and `replLoop` already maps `.error msg`
      to `mkErrorResponse msg`, so no new plumbing is needed — confirm both by reading the two
      sites rather than assuming.
- [ ] Check for any other `parseFrameClass` call site with `grep -rn parseFrameClass` across
      `BimodalTools/` and `Tests/` and update each.

**Timing**: 45 minutes

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `BimodalTools/TableauBridge.lean` - `parseFrameClass`, its docstring, `parseRequest`

**Verification**:
- `lake build BimodalTools` green
- `lake exe tableau_bridge` given a line with `"frame_class": "Bogus"` returns
  `{"status": "error", "message": "unknown frame_class: 'Bogus' ...", "time_ms": 0}` and the REPL
  stays alive for the next line
- The same request with `"frame_class": "RTime"` is accepted and decides normally
- A request with no `frame_class` key still defaults to `Base`

---

### Phase 5: Acceptance tests [COMPLETED]

**Goal**: the three acceptance cases are pinned in `Tests/BimodalToolsTest/` and fail the build if
they regress.

**Tasks**:
- [ ] Create `Tests/BimodalToolsTest/TableauBridgeTest.lean`: copyright header, module docstring,
      `import BimodalTools.TableauBridge`, `namespace BimodalToolsTest.TableauBridge`, and the
      `open`s the rows need. Mirror `Tests/BimodalTest/Metalogic/Decidability/Verified/BridgeProbes.lean`
      for the `#guard_msgs in #eval` idiom and `Tests/BimodalToolsTest/ProofFirstTests.lean` for
      the header and namespace conventions.
- [ ] Row A (gated invalid): `evalBranchGates (p → q) .Base` — pin all eight booleans and
      `gated = true`.
- [ ] Row B (ungated invalid): `evalBranchGates (p → q) .ZTime` — pin `regionLabel = false`,
      `temporalWitness = false`, `gated = false`, and the other six `true`. Add a comment
      recording that this is the measured current behaviour of the `.ZTime` rules
      (`priorUZ`/`priorSZ` on the seriality-minted `T(F ⊤)`), not an assertion that it is correct.
- [x] Row C (response shape): `decideResponseBody (p → q) .Base` contains `"status": "invalid"`
      and `"gated": true`; the same at `.ZTime` contains `"gated": false`. Use substring checks
      (`String.isInfixOf` or the codebase's existing equivalent) rather than pinning the whole
      string, so an unrelated additive field does not break the row.
      *(deviation: altered — neither `String.isInfixOf` nor `String.containsSubstr` exists at this
      toolchain, and the codebase had no equivalent, so the test file defines a two-line private
      `hasSub` on `String.splitOn` and self-tests it with a positive and a negative row.)*
- [ ] Row D (frame_class): `parseFrameClass "RTime"` is `.ok .RTime`, `parseFrameClass "Discrete"`
      is `.ok .ZTime`, and `parseFrameClass "Bogus"` is an `.error`.
- [ ] Row E (end-to-end rejection): `parseRequest` on a full line carrying
      `"frame_class": "Bogus"` returns `.error`.
- [ ] Add `import BimodalToolsTest.TableauBridgeTest` to `Tests/BimodalToolsTest.lean`, in the
      existing import block.
- [ ] Use only formulas with measured outcomes from the research survey. Do NOT add
      `p → □p`, `□p → □q` or `S(q,p) → p` at `.ZTime`: all three are measured to STALL.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: five test rows (A-E) in one new file plus one import line are asserted to
cover the acceptance criterion. Confirm at implementation time by re-reading the dispatch's
ACCEPTANCE clause against the finished file: a gated invalid verdict, an ungated one, and the
frame_class rejection must each map to at least one row. If a row cannot be written as a `#guard`
(e.g. `decideResponseBody` turns out to be `IO`), record which one and why, and use an `#eval`
with `#guard_msgs` instead rather than dropping the case.

**Files to modify**:
- `Tests/BimodalToolsTest/TableauBridgeTest.lean` - new
- `Tests/BimodalToolsTest.lean` - one new import line

**Verification**:
- `lake build BimodalToolsTest` green, with no `main` collision error
- Deliberately flipping one expected boolean in a row makes the build red (confirm the rows are
  actually load-bearing, then revert the flip)
- Elaboration of the new file completes in seconds, not minutes

---

### Phase 6: Documentation [IN PROGRESS]

**Goal**: the protocol change and the frame-class vocabulary are documented where a consumer will
look, and the generated inventory is current.

**Tasks**:
- [ ] In `BimodalTools/TableauBridge.lean`'s module docstring `## Protocol` section: add the
      `frame_class` value list (`Base`, `Dense`, `ZTime`, `Discrete` alias, `RTime`) and state
      that any other value returns `{"status": "error", "message": ...}`.
- [ ] Add an `invalid` response example to the same section showing the `"gates"` object with all
      eight keys and `"gated"`, and one sentence naming `not_valid_of_hasOpen_int` /
      `not_validZTime_of_hasOpen_int` as exactly what `"gated": true` licenses — and stating that
      `"gated": false` means the verdict is heuristic, not that the formula is valid.
- [ ] Add a "Tableau bridge protocol" prose section to `BimodalTools/README.md` immediately above
      `## Contents`: the request/response shape, the frame-class vocabulary, and the
      theorem-backed-vs-heuristic distinction. The file has no prose on the bridge today, only the
      generated inventory row.
- [ ] Fill in the `<!-- TODO: add description -->` cell for `TableauBridgeMain.lean` and add one
      for the new `TableauBridge.lean`, following the `ContrastiveGenerator`/`ContrastiveGeneratorMain`
      pair's wording.
- [ ] Re-emit the generated block with
      `bash scripts/check-module-invariants.sh --emit-inventory`, then confirm with
      `bash scripts/check-module-invariants.sh --emit-inventory --check`.
- [ ] Update the `*Last verified:*` date line at the foot of the README.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: two files are asserted to need documentation edits, and the inventory block
is asserted to be the only generated region affected. Confirm at implementation time with
`bash scripts/check-module-invariants.sh --emit-inventory --check` before and after: the before
run should name exactly `BimodalTools/README.md` as stale, and the after run should be clean. If
another README's block also goes stale, that is a signal the split touched more than expected —
stop and report rather than re-emitting blocks this task did not cause to change.

**Files to modify**:
- `BimodalTools/TableauBridge.lean` - module docstring `## Protocol` section
- `BimodalTools/README.md` - new prose section, two inventory descriptions, regenerated block,
  date line

**Verification**:
- `lake build BimodalTools` green (the module docstring is a `/-! -/` block and does elaborate)
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- The documented `invalid` example's key set matches `BranchGates.toJson`'s actual output for a
  real request, compared side by side rather than by eye

---

### Phase 7: Full gate and close-out [NOT STARTED]

**Goal**: every acceptance criterion is demonstrated green in one pass, in dependency order.

**Tasks**:
- [ ] `lake build BimodalTools`
- [ ] `lake build BimodalToolsTest`
- [ ] `lake exe tableau_bridge` end-to-end smoke: feed a here-doc of five JSONL lines — `ping`,
      `tableau_decide` for `p → q` at `"Base"`, the same at `"ZTime"`, one with
      `"frame_class": "Bogus"`, and `shutdown` — and check each response against this plan's
      stated expectations.
- [ ] `bash scripts/check-module-invariants.sh` (whole run: B3 and INV both).
- [ ] Re-read `git status --short`; confirm the modified set is exactly the six files this plan
      names (plus any conditional `DatasetGenerator.lean` from Phase 3) and nothing else. Any
      foreign modification is task 665's, not this task's — report it, do not stage or revert it.
- [ ] Stage by explicit per-file path (never `git add -A`, `git add .`, or a directory/glob
      pathspec) and commit.

**Timing**: 45 minutes

**Depends on**: 5, 6

**Verification Tier**: full

**Files to modify**:
- None (verification and commit only)

**Verification**:
- All four commands above exit 0
- `git diff --staged --stat` lists only this task's files

---

## Testing & Validation

- [ ] `lake build BimodalTools` green
- [ ] `lake build BimodalToolsTest` green (this is the acceptance criterion's named gate)
- [ ] `lake exe tableau_bridge` starts, answers `ping`, decides, rejects an unknown
      `frame_class` without dying, and exits on `shutdown`
- [ ] A `tableau_decide` invalid response at `"Base"` carries `"gated": true`; at `"ZTime"`,
      `"gated": false`
- [ ] Every pre-existing response field is byte-identical to its pre-change value on the valid,
      timeout and `valid_no_proof_term` arms
- [ ] `parseFrameClass` accepts exactly `Base`, `Dense`, `ZTime`, `Discrete`, `RTime`
- [ ] `bash scripts/check-module-invariants.sh` clean (B3 + INV)
- [ ] No `sorry` and no new axiom introduced (`grep -rn "sorry" BimodalTools/TableauBridge.lean`
      returns nothing)

## Artifacts & Outputs

- `BimodalTools/TableauBridge.lean` (new) — the bridge library: protocol, parsers, `BranchGates`,
  handlers, REPL loop
- `BimodalTools/TableauBridgeMain.lean` (reduced) — executable root, `main` only
- `BimodalTools.lean` (modified) — one new import
- `BimodalTools/README.md` (modified) — protocol prose section, regenerated inventory
- `Tests/BimodalToolsTest/TableauBridgeTest.lean` (new) — the five acceptance rows
- `Tests/BimodalToolsTest.lean` (modified) — one new import
- `BimodalTools/DatasetGenerator.lean` (conditional, Phase 3) — `fc` parameter on
  `extractCountermodelData` if it lacks one
- `specs/667_tableau_bridge_branch_gates_and_frame_class/summaries/01_branch-gates-frame-class-summary.md`

## Rollback/Contingency

Each phase is independently committed, so the ordinary contingency is `git revert` of the offending
phase commit — no working-tree rollback is required and none should be attempted while task 665 is
dispatched against the same tree.

Before Phase 1 only (the one phase that moves ~560 lines between files and changes an executable
root), take a **durable, non-reverting** checkpoint:
`bash .claude/scripts/git-snapshot.sh 667 --no-revert`. This records the pre-split state without
touching the working tree. Do not use the default (reverting) invocation as a routine checkpoint.

If a genuine working-tree rollback becomes necessary, follow `context/contracts/recovery.md`'s
rollback rung for the exact invocation shape, including its out-of-scope override flag — and
first confirm, via `git log` and `git status --short`, that every change being discarded is this
task's own and not task 665's.

Phase-specific fallbacks:
- **Phase 1 fails to build**: the split is mechanical; the likely cause is a missed `open` or the
  namespace rename. Revert the phase commit and re-do it as a pure cut-and-paste with no other
  edit, then rename the namespace as a separate second commit.
- **Phase 3's `extractCountermodelData` change ripples** beyond `BimodalTools/`: drop the `fc`
  fix from this task, record it explicitly in the implementation summary as a known defect with
  its own follow-up, and ship the rest — it is an in-passing repair, not a deliverable.
- **Phase 5's `.ZTime` row turns out to STALL** despite the research's measurement: substitute
  `◇p → p` at `"Base"` (measured `regionLabel`/`temporalWitness` false, same ungated shape) and
  record the substitution and its reason in the test file.
