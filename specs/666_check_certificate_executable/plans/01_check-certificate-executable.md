# Implementation Plan: Check Certificate Executable

- **Task**: 666 - Check certificate executable
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours
- **Dependencies**: Task 665 (witness-family certificate soundness, COMPLETED); Task 667 (tableau bridge branch gates, COMPLETED)
- **Research Inputs**: specs/666_check_certificate_executable/reports/01_check-certificate-executable.md
- **Artifacts**: plans/01_check-certificate-executable.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/rules/artifact-formats.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Build `lake exe check_certificate`: a one-sided re-verification binary that reads a JSON
witness-family certificate on stdin, rebuilds the dependently-typed `WitnessFamily` at runtime,
runs the four `Decidable` instances delivered by the witness-family soundness task, and prints a
single JSON line that is either `{"status":"countermodel"}` or
`{"status":"rejected","failed":[...]}` naming the failed condition, lasso index and position. The
decision logic is entirely existing, proven machinery — the new work is JSON decoding into a
dependent structure (`dite` on each proof field), a diagnostic scan for failure localization, and
the build/test/doc surface a new `lean_exe` target plus two library modules must satisfy. Done
means: the round-trip test accepts the non-vacuity family, rejects a family with one broken
fulfilment obligation naming that obligation, and `lake build BimodalTools --wfail` plus
`lake build BimodalToolsTest --wfail` are green at zero warnings.

### Research Integration

The research report (`reports/01_check-certificate-executable.md`) is the primary input and
resolved every open design question with live spikes rather than inference. Load-bearing findings
carried into this plan:

- **Runtime construction works**: all four `LabelledLasso`/`WitnessFamily` proof fields are
  decidable over computable data and are discharged by `dite`; the built family computes with no
  `noncomputable` marker (Spike A/B).
- **Performance clears the bar by an order of magnitude**: ~68 ms interpreted at total segment
  length 101 (Spike E); the shipped binary is compiled.
- **`Finset.toList` is noncomputable** — a hard blocker for the diagnostic scan. Two verified
  helpers (`closureList` + `mem_closureList`, `intRange`) are carried into Phase 2 verbatim from
  Spike D.
- **Failure localization needs no new mathematics**: `Decide.lean` already exports `CoherentAt`,
  `labClauseAt`, `eventClauseAt`/`FulfilAt`, `boxClause` and the window bounds
  `labCohWindowLo/Hi`, `labFulWindowLo/Hi`. Spike D produced exactly the acceptance tuple
  `some (0, -2, p U q)` on `sepFamily`.
- **The parser must be extracted, not copied**: `pFormula` lives inside
  `BimodalTools/TableauBridge.lean` (whose closure is the whole tableau engine) and verbatim again
  in `BenchmarkOracleMain.lean`. A repo-wide grep found zero references to the parser symbols
  outside those two declaring files, so extraction into `BimodalTools/JsonParse.lean` is
  mechanical and removes a duplicate instead of adding a third.
- **The enumerated INPUT schema omits the target time**; the report's decision is an optional
  `"time"` integer defaulting to `0`, which is backward compatible and matches
  `posFamily.Target 0`.
- **Six prose sites hardcode "12 executable roots" and two hardcode "15 non-`Main` modules"**;
  CI itself enumerates targets programmatically and needs no edit.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no ROADMAP.md consultation was performed.

## Goals & Non-Goals

**Goals**:
- A `lake exe check_certificate` target whose root is `BimodalTools/CheckCertificateMain.lean`,
  with all parsing, decoding, checking and result serialization in
  `BimodalTools/CertificateImport.lean` so it is testable from `Tests/BimodalToolsTest/`.
- The tag-format JSON parser extracted once into `BimodalTools/JsonParse.lean`, with
  `BimodalTools/TableauBridge.lean` re-pointed at it and its own copy deleted.
- One new theorem identifier, `mem_closureList`, discharging the computable-closure-enumeration
  obligation that `Finset.toList`'s noncomputability creates.
- Verdicts driven by the four top-level Decidable instances (so acceptance means the soundness
  theorem's hypotheses were decided true), with a separate diagnostic scan used only to localize
  a rejection.
- A JSON schema section in `BimodalTools/README.md` beside the tableau bridge protocol, with
  field names mirroring the Lean structure exactly.
- Green `lake build BimodalTools --wfail`, `lake build BimodalToolsTest --wfail`, module
  invariants, copyright headers, and the exe-roots compile step.

**Non-Goals**:
- The ModelChecker-side certificate emitter (external; this task consumes its output only).
- Any change to `FormalSystem/` — the certificate layer is complete and consumed read-only.
- A validity claim of any kind. `rejected` means "this object is not a certificate", never "the
  consequence holds".
- Retiring `BenchmarkOracleMain.lean`'s parser copy (optional follow-on named in the research
  report, deliberately out of scope here).
- A `--verbose` all-failures mode or a JSONL batch/REPL mode (named as future extensions).

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.WitnessFamily

theorem mem_closureList {S : Context} {ψ : Formula} :
    ψ ∈ closureList S ↔ ψ ∈ closureOf S := sorry
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Finset.toList`'s noncomputability is rediscovered mid-implementation and read as a structural obstruction | H | M | Phase 2 carries `closureList`/`mem_closureList`/`intRange` verbatim from the research spike; write them before any scan code |
| Parser extraction breaks `TableauBridge` (silently changed namespace or dropped declaration) | H | M | Phase 1 is a declared `atomic-batch`: move all eleven declarations in one step, keep `BimodalTools.JsonParse` as the namespace, `open` it from `TableauBridge`, and gate on `lake build BimodalTools --wfail` plus the existing `TableauBridgeTest` |
| `--wfail` turns a stray >100-character line or an unused `simp` argument into red CI | M | H | Both classes are `blocking` in `scripts/warning-budget.txt`; build each new module with `--wfail` locally before calling a phase green |
| Diagnostic scan disagrees with the top-level verdict (reports `rejected` with no localized failure, or vice versa) | M | M | Scan over exactly the units the instances decide (`CoherentAt` on `[labCohWindowLo, labCohWindowHi)`, `eventClauseAt` on `[labFulWindowLo, labFulWindowHi)`); Phase 3 emits an explicit `"unlocalized"` entry rather than a silent empty `failed` list if the scan finds nothing |
| Atom identity mismatch: `Formula.toJson` drops `Atom.freshIndex`, so a fresh-indexed atom round-trips to a different `Finset Formula` member | M | L | Phase 2 validates atom shape on import and rejects (or documents) non-base atoms; Phase 6 states the base-only round-trip explicitly in the README |
| Acceptance read as a soundness claim about the binary itself | M | M | Phase 4's module docstring states the trust model plainly: the binary evaluates the same compiled `Decidable` instances `joint_countermodel` consumes; `countermodel` means those returned `true`, not a kernel-checked proof for this certificate |
| Stale hardcoded counts ("12 executable roots", "15 non-`Main` modules") left behind | L | H | Phase 6 re-derives both counts mechanically before editing, then regenerates the README inventory block and runs `--emit-inventory --check` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 4, 5, 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Extract the tag-format JSON parser into BimodalTools/JsonParse.lean [COMPLETED]

**Goal**: One copy of the recursive-descent parser, in a module whose import closure is light
enough for the certificate checker to depend on without pulling in the tableau engine.

**Tasks**:
- [ ] Re-confirm the zero-external-reference finding before moving anything:
      `grep -rn 'PState\|mkPState\|pFormula\|pString\|pSkipValue\|pNat\|pExpect\|pEof\|pPeek\|pAdvance\|pSkipWS' --include='*.lean' .`
      and check every hit is inside `BimodalTools/TableauBridge.lean` or
      `BimodalTools/BenchmarkOracleMain.lean`.
- [ ] Create `BimodalTools/JsonParse.lean` with the standard four-line Apache header, a module
      docstring naming both consumers, and `namespace BimodalTools.JsonParse`; move
      `PState`, `mkPState`, `pEof`, `pPeek`, `pAdvance`, `pSkipWS`, `pExpect`, `pString`,
      `pSkipValue`, `pNat`, `pFormula` verbatim (imports: `FormalSystem.Syntax` only, or whatever
      the moved bodies actually need — confirm by building, not by guessing).
- [ ] Delete the parser region from `BimodalTools/TableauBridge.lean`, add
      `import BimodalTools.JsonParse` and `open BimodalTools.JsonParse`, and keep the surrounding
      section docstring accurate (it currently explains the replication; rewrite it to point at
      the extracted module).
- [ ] Add `import BimodalTools.JsonParse` to `BimodalTools.lean`, in alphabetical position.
- [ ] Build: `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail`
      (the latter exercises `TableauBridgeTest`).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: eleven parser declarations move, and the only files touched are
`BimodalTools/JsonParse.lean` (new), `BimodalTools/TableauBridge.lean` and `BimodalTools.lean`.
Confirm by the grep above before the move and by `lake build BimodalTools --wfail` after it; if
any hit falls outside the two declaring files, stop and widen the phase rather than editing past
the hypothesis.

**Files to modify**:
- `BimodalTools/JsonParse.lean` - new module holding the extracted parser
- `BimodalTools/TableauBridge.lean` - delete the parser copy, import and open the new module
- `BimodalTools.lean` - import the new non-`Main` module

**Verification**:
- `lake build BimodalTools --wfail` green at zero warnings
- `lake build BimodalToolsTest --wfail` green (proves `TableauBridgeTest`'s `#guard` rows still
  pass through the re-pointed parser)
- The confirming grep shows the parser symbols declared in exactly one place under
  `BimodalTools/` outside `BenchmarkOracleMain.lean`

---

### Phase 2: CertificateImport.lean - computable helpers, raw records, and the runtime family builder [NOT STARTED]

**Goal**: Decode a certificate JSON object into a real `WitnessFamily Γ Del`, or a named
structural rejection, with every computability blocker already closed.

**Tasks**:
- [ ] Create `BimodalTools/CertificateImport.lean` (Apache header, module docstring,
      `namespace BimodalTools.CertificateImport`) importing
      `FormalSystem.Metalogic.Decidability.WitnessFamily`, `BimodalTools.JsonParse` and
      `BimodalTools.DataExport`.
- [ ] Carry the verified computable helpers in verbatim from the research spike:
      `def closureList (S : Context) : List Formula := (S.flatMap Formula.subformulas).dedup`;
      `theorem mem_closureList : ψ ∈ closureList S ↔ ψ ∈ closureOf S := by simp [closureList, mem_closureOf, subformulaClosure]`;
      `def intRange (a b : Int) : List Int := (List.range (b - a).toNat).map (fun k => a + (k : Int))`.
- [ ] Define the raw parsed record types mirroring the JSON: premises, conclusions, `bx` as a
      list of `(Formula × Bool)` pairs, `lassos` each with `back`/`mid`/`fwd` as
      `List (List Formula)`, and an optional `time : Int` defaulting to `0`.
- [ ] Write the envelope parser on top of `JsonParse.pFormula`: object/array/field readers for
      the five top-level fields, tolerating the absent `"time"` field, and a signed-integer
      reader (`pNat` handles unsigned only — positions are `ℤ` and go negative).
- [ ] `def bxOf (pairs : List (Formula × Bool)) : Formula → Bool :=
      fun φ => (pairs.find? (·.1 == φ)).map Prod.snd |>.getD false`.
- [ ] `mkLasso`: `dite` on `back = []`, `fwd = []`, and
      `∀ X ∈ back ++ mid ++ fwd, X ⊆ C`, returning a named structural rejection on each failure
      (`back_empty`, `fwd_empty`, `label_outside_closure`) rather than a parse error.
- [ ] `mkFamily`: build `closureOf (Γ ++ Del)`, map `mkLasso` over the lassos, `dite` on
      `lassos = []` (`lassos_empty`), assemble the `WitnessFamily`.
- [ ] Validate atom shape on import: flag (or reject) atoms carrying a `freshIndex`, since
      `Formula.toJson` drops it and `Finset Formula` membership is by `DecidableEq`.
- [ ] Add `import BimodalTools.CertificateImport` to `BimodalTools.lean`.
- [ ] Build: `lake build BimodalTools --wfail`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - new module (helpers, records, envelope parser, builders)
- `BimodalTools.lean` - import the new non-`Main` module

**Verification**:
- `lake build BimodalTools --wfail` green at zero warnings, with **no `noncomputable` marker** on
  any new definition (a `noncomputable` here means a `Finset.toList` leaked back in)
- A temporary `#guard` (or `#eval`) confirming `(closureList gammaPos).length = 16`, matching
  `(closureOf gammaPos).card` — the spike's own check
- `mem_closureList` closes with the single `simp` call and no `sorry`

---

### Phase 3: Verdict, failure localization, and result serialization [NOT STARTED]

**Goal**: Turn a built family into the output contract — `countermodel`, or `rejected` with the
condition, lasso index and position named.

**Tasks**:
- [ ] Define the result type: a `CheckResult` carrying `countermodel` (optionally with the
      falsifying position) or `rejected` with a list of failure records
      `(condition, lasso index, position, formula)`.
- [ ] `checkCertificate`: run the four top-level instances in order —
      `decide W.LocalCoherentLab`, `decide W.FulfillingLab`, `decide W.BoxFaithful`,
      `decide (W.Target t)` — and short-circuit to the localization scan on the first `false`.
      The verdict comes from these instances only; the scan never overrides them.
- [ ] Localization scans, each over exactly the units its instance decides:
      - coherence: `List.finRange W.lassos.length` x `intRange (labCohWindowLo Λ) (labCohWindowHi Λ)`,
        testing `CoherentAt W.bx Λ t`, then `labClauseAt` per `closureList` member for the formula;
      - fulfilment: same index/window product, testing `eventClauseAt Λ t ψ` per `closureList`
        member (this is the scan that returned `(0, -2, p U q)` on `sepFamily`);
      - box faithfulness: `closureList` members, positions `intRange (-Λ.nb) (Λ.nm + Λ.nf)`, via
        `boxClause`;
      - target: membership of each `γ ∈ Γ` and `σ ∈ Del` in `W.main t` at the single position `t`.
- [ ] Emit an explicit `"unlocalized"` failure record if an instance says `false` but the
      corresponding scan finds nothing, rather than an empty `failed` list.
- [ ] Result serializer: one JSON line, `{"status":"countermodel"}` or
      `{"status":"rejected","failed":[...]}`, reusing `escapeJsonString` and `Formula.toJson`
      from `BimodalTools.DataExport`. Malformed input maps to
      `{"status":"error","message":...}`, mirroring `TableauBridge`. **Never emit a validity
      claim.**
- [ ] Certificate *serializer* (the inverse direction), so the round-trip test is a `#guard` and
      the schema is pinned executably rather than only in prose.
- [ ] Build: `lake build BimodalTools --wfail`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - result type, `checkCertificate`, scans, both serializers

**Verification**:
- `lake build BimodalTools --wfail` green at zero warnings, still with no `noncomputable` marker
- A temporary `#eval` reproducing the spike results: `posFamily` -> all four conditions true;
  `sepFamily` -> fulfilment false, localized at lasso 0, position -2, formula `p U q`
- Reading the code confirms the verdict is taken from the four instances and the scan is
  diagnostics only

---

### Phase 4: CheckCertificateMain.lean and the lake exe target [NOT STARTED]

**Goal**: `lake exe check_certificate` runs end to end from stdin.

**Tasks**:
- [ ] Create `BimodalTools/CheckCertificateMain.lean` in the shape of the 23-line
      `TableauBridgeMain.lean`: Apache header, module docstring, `main` and nothing else — read
      stdin to a string, call `CertificateImport`, print one JSON line.
- [ ] State the trust model in the module docstring: the binary evaluates the same compiled
      `Decidable` instances `WitnessFamily.joint_countermodel` consumes, so `countermodel` means
      those instances returned `true` — it is not a kernel-checked proof for this certificate, and
      `rejected` is never a validity claim.
- [ ] Add the `[[lean_exe]]` block to `lakefile.toml` matching its siblings:
      `name = "check_certificate"`, `root = "BimodalTools.CheckCertificateMain"`,
      `supportInterpreter = true`.
- [ ] Confirm the C25N root-naming invariant: `check_certificate` -> `CheckCertificateMain`.
- [ ] Do **not** add the `*Main` module to `BimodalTools.lean` (root-namespace `main` collision).
- [ ] Smoke-run: `echo '<a certificate>' | lake exe check_certificate` on the serialized
      non-vacuity family, and on a deliberately broken one.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Files to modify**:
- `BimodalTools/CheckCertificateMain.lean` - new executable root (`main` only)
- `lakefile.toml` - new `[[lean_exe]]` block

**Verification**:
- `lake exe check_certificate` builds and runs
- Smoke run prints exactly one JSON line, `{"status":"countermodel"}` on the good family and a
  `rejected` line naming the condition on the broken one
- `bash scripts/check-module-invariants.sh` passes C25N (root naming)
- `python3 scripts/lake_targets.py exe-roots` lists the new root (this is what CI enumerates, so
  no CI edit is needed)

---

### Phase 5: Tests/BimodalToolsTest/CertificateImportTest.lean [NOT STARTED]

**Goal**: The acceptance criteria are executable `#guard` rows against the library module, not a
manual smoke run.

**Tasks**:
- [ ] Create `Tests/BimodalToolsTest/CertificateImportTest.lean` (Apache header, module
      docstring), importing `BimodalTools.CertificateImport` and the witness-family examples —
      **never** the `*Main` root.
- [ ] Row (a): `posFamily`'s data serialized to JSON and re-imported is accepted, all four
      conditions true.
- [ ] Row (b): `sepFamily`'s data is rejected with `failed` naming fulfilment at lasso 0,
      position -2, formula `p U q`.
- [ ] Row (c): a structural rejection — a label outside `closureOf (Γ ++ Del)` — reported as
      `rejected` under the named structural condition, not as a parse error.
- [ ] Row (d): `pFormula ∘ Formula.toJson = id` on the closure members (base atoms only; note
      the `freshIndex` caveat in the module docstring).
- [ ] Add `import BimodalToolsTest.CertificateImportTest` to `Tests/BimodalToolsTest.lean`.
- [ ] Build: `lake build BimodalToolsTest --wfail`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Files to modify**:
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - new test module
- `Tests/BimodalToolsTest.lean` - import the new test module

**Verification**:
- `lake build BimodalToolsTest --wfail` green at zero warnings, with every `#guard` row passing
- Row (b)'s expected tuple matches the research spike's `some (0, -2, p U q)` exactly
- The test imports no `*Main` module (grep the import block)

---

### Phase 6: Schema documentation, inventory regeneration, and stale counts [NOT STARTED]

**Goal**: The two JSON interfaces sit together in `BimodalTools/README.md`, and no prose count
goes stale from this task.

**Tasks**:
- [ ] Add a certificate-schema section to `BimodalTools/README.md` immediately beside
      `## Tableau bridge protocol`, documenting: `premises`, `conclusions`, `bx` (list of
      `[formula, bool]` pairs), `lassos` (each with `back`/`mid`/`fwd` as lists of label sets,
      each label set a list of formula ASTs), and the optional `"time"` integer defaulting to `0`.
      State that field names mirror the Lean structure exactly (`Basic.lean` calls them an export
      contract), that the formula AST is the tag format `Formula.toJson` emits, that atom names
      round-trip on `Atom.base` only, and that the output is one JSON line which never claims
      validity.
- [ ] Re-derive both counts mechanically before touching any prose:
      executable roots via `python3 scripts/lake_targets.py exe-roots | wc -l`, non-`Main`
      modules via the import list in `BimodalTools.lean`.
- [ ] Update the executable-root count at: `lakefile.toml` header comment, `BimodalTools.lean`
      trailing comment, `BimodalTools/README.md`, `scripts/check-copyright-headers.sh` header,
      `scripts/check-module-invariants.sh` header, and `.github/workflows/ci.yml` (both the
      roots count and the "thirteen of them" phrasing that also counts `checkInitImports`).
- [ ] Update the non-`Main` module count at `.github/workflows/ci.yml` and
      `scripts/module-invariants-manifest.txt`.
- [ ] Leave `docs/development/PUBLICATION_REFACTOR.md` alone — it is a historical record of a
      completed refactor.
- [ ] Regenerate the machine-owned README inventory block:
      `bash scripts/check-module-invariants.sh --emit-inventory`, then verify with
      `--emit-inventory --check`; update the `*Last verified*` date at the file's end.

**Timing**: 1 hour

**Depends on**: 4, 5

**Verification Tier**: prose

**Scope Hypothesis**: six prose sites carry the executable-root count (12 -> 13) and two carry the
non-`Main` module count (15 -> 17, as two modules are added). Both numbers and both site lists are
hypotheses from the research report, not facts. Confirm by re-deriving each count with the
commands above and by
`grep -rn '\b12\b.*executable root\|\b15\b.*non-.Main' --include='*.toml' --include='*.lean' --include='*.md' --include='*.sh' --include='*.yml' --include='*.txt' .`
before editing; if the derived count or the site list differs, follow the evidence, not this line.

**Files to modify**:
- `BimodalTools/README.md` - certificate schema section, inventory block, last-verified date
- `lakefile.toml` - header comment count
- `BimodalTools.lean` - trailing comment count
- `scripts/check-copyright-headers.sh` - header comment count
- `scripts/check-module-invariants.sh` - header comment count
- `scripts/module-invariants-manifest.txt` - non-`Main` module count
- `.github/workflows/ci.yml` - both counts (comment/echo text only; no step logic changes)

**Verification**:
- Diff read-through confirming every changed hunk outside `README.md` lies inside a comment or
  prose region. If any hunk crosses into executable shell, YAML step logic, or Lean code,
  escalate this phase to `full` and run the complete gate set before closing it.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` passes
- Every re-derived count matches the number now written in prose

---

### Phase 7: Full gate set and the performance bar [NOT STARTED]

**Goal**: Everything the repository gates on is green, and the acceptance timing claim is
measured rather than asserted.

**Tasks**:
- [ ] `lake build BimodalTools --wfail`
- [ ] `lake build BimodalToolsTest --wfail`
- [ ] `lake build` (the published `FormalSystem` default target — confirm this task changed
      nothing under `FormalSystem/`)
- [ ] `bash scripts/check-module-invariants.sh` (full, including B3 and C25N)
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`
- [ ] Compile every `lean_exe` root the way CI does:
      `python3 scripts/lake_targets.py exe-roots` and build each.
- [ ] Measure the acceptance timing bar: time `lake exe check_certificate` on a family with total
      segment length just under 100 (the padded-`posLasso` construction the research spike used)
      and record the wall-clock number. Compiled code must be well under a second; the interpreter
      measured ~68 ms.
- [ ] Record the measured number in the implementation summary — a timing claim without a
      measurement is not acceptance.

**Timing**: 1 hour

**Depends on**: 4, 5, 6

**Verification Tier**: full

**Files to modify**:
- None (verification only; any fix this phase surfaces is an edit to the phase that owns the file)

**Verification**:
- Every command above exits 0, with zero compiler warnings under `--wfail`
- The measured wall-clock time at total segment length ~100 is recorded and is well under one
  second

## Testing & Validation

- [ ] `lake build BimodalTools --wfail` green at zero warnings
- [ ] `lake build BimodalToolsTest --wfail` green at zero warnings, all `#guard` rows passing
- [ ] `lake build` (default `FormalSystem` target) unaffected
- [ ] Round-trip acceptance: the non-vacuity family serialized to JSON is accepted
      (`{"status":"countermodel"}`)
- [ ] Rejection acceptance: a family with one broken fulfilment obligation is rejected naming
      that obligation (lasso 0, position -2, `p U q`)
- [ ] Structural rejection: a label outside the closure yields `rejected` under a named structural
      condition, not a parse error
- [ ] Parser round-trip: `pFormula ∘ Formula.toJson = id` on the closure members
- [ ] `bash scripts/check-module-invariants.sh` passes, including C25N root naming
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` passes
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` passes
- [ ] Measured runtime well under one second at total segment length under 100
- [ ] No `noncomputable` marker on any new definition; no `sorry`; no new axiom

## Artifacts & Outputs

- `BimodalTools/JsonParse.lean` - the extracted tag-format JSON parser (new)
- `BimodalTools/CertificateImport.lean` - records, computable helpers, builders, checker,
  serializers (new)
- `BimodalTools/CheckCertificateMain.lean` - executable root, `main` only (new)
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - acceptance tests (new)
- `lakefile.toml` - `check_certificate` `[[lean_exe]]` target
- `BimodalTools.lean`, `Tests/BimodalToolsTest.lean` - aggregator imports
- `BimodalTools/TableauBridge.lean` - parser copy deleted, re-pointed at `JsonParse`
- `BimodalTools/README.md` - certificate JSON schema section, regenerated inventory block
- `scripts/check-copyright-headers.sh`, `scripts/check-module-invariants.sh`,
  `scripts/module-invariants-manifest.txt`, `.github/workflows/ci.yml` - count updates

## Rollback/Contingency

Every phase is committed green per the Commit-Per-Green-Substep Mandate (Phase 1 excepted as a
declared `atomic-batch`), so the ordinary contingency is `git revert` of the offending phase
commit — no working-tree destruction is involved and no snapshot is needed.

Per-phase fallbacks, in order of likelihood:

- **Phase 1 extraction proves non-mechanical** (an external reference the grep missed): abandon
  the extraction and have `CertificateImport.lean` import `BimodalTools.TableauBridge` directly,
  accepting the heavier import closure. The research report explicitly names this fallback and
  requires that a third parser copy, if it happens instead, be recorded rather than left
  undocumented. All later phases are unaffected.
- **Phase 3 localization disagrees with a verdict**: ship the verdict path alone with an
  `"unlocalized"` failure record. The acceptance criterion for row (b) then fails and the task is
  `[PARTIAL]` — do not weaken the criterion to match the behavior.
- **A phase must be discarded mid-work with uncommitted edits present**: this is a genuine
  rollback, so follow `context/contracts/recovery.md`'s rollback rung for the exact
  `git-snapshot.sh` invocation shape (including its out-of-scope override flag for a whole-tree
  case) before running any destructive git command. Never emit a bare default-mode
  `git-snapshot.sh` as a routine start-of-phase checkpoint; a precautionary checkpoint before
  risky work uses `--no-revert`.

Nothing under `FormalSystem/` is touched, so no rollback can affect the published library.
