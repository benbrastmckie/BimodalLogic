# Research Report: Check Certificate Executable

- **Task**: 666 - Check certificate executable
- **Started**: 2026-09-24T23:51:08Z
- **Completed**: 2026-09-25T00:05:00Z
- **Effort**: 4-8 hours (task estimate); research ~30 min
- **Dependencies**: Task 665 (witness-family certificate soundness, COMPLETED), Task 667 (tableau bridge branch gates, COMPLETED)
- **Sources/Inputs**:
  - Certificate layer: `FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Closure,Decide,Examples}.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily.lean`
  - JSON interfaces: `BimodalTools/TableauBridge.lean`, `BimodalTools/TableauBridgeMain.lean`, `BimodalTools/DataExport.lean`, `BimodalTools/BenchmarkOracleMain.lean`
  - Build/gate surface: `lakefile.toml`, `BimodalTools.lean`, `BimodalTools/README.md`, `Tests/BimodalToolsTest.lean`, `.github/workflows/ci.yml`, `scripts/check-module-invariants.sh`, `scripts/check-copyright-headers.sh`, `scripts/warning-budget.txt`
  - Live Lean spikes via `lean_run_code` against the built `FormalSystem` oleans (four snippets; see Appendix)
- **Artifacts**:
  - `specs/666_check_certificate_executable/reports/01_check-certificate-executable.md`
- **Standards**: report-format.md, subagent-return.md, status-markers.md, artifact-management.md

## Project Context

- **Upstream Dependencies**: `FormalSystem.Metalogic.Decidability.WitnessFamily` (structures + four `Decidable` instances), `BimodalTools.DataExport` (`Formula.toJson`, `escapeJsonString`), the `pFormula` tag-format parser currently living inside `BimodalTools/TableauBridge.lean`
- **Downstream Dependents**: the external ModelChecker half of the dual-verification architecture (the certificate producer); `Tests/BimodalToolsTest/`
- **Alternative Paths**: none for the checking logic — the four `Decidable` instances are the only sanctioned decision procedure for the four conditions
- **Potential Extensions**: a `--verbose` mode emitting every failing (lasso, position, clause) rather than the first; a batch/JSONL mode mirroring `tableau_bridge`'s REPL

## Executive Summary

- **The whole pipeline is runtime-feasible today, and this was measured, not assumed.** A spike that builds a `WitnessFamily` from ordinary runtime data (`dite` on each structure field's `Decidable` instance) and runs all four `decide`s evaluated correctly: `posFamily` data returned `(true, true, true, true)`; `sepFamily` data returned `(true, false, true, true)`; a deliberately broken positive family returned `(false, true, true, true)`. No `sorry`, no new axiom, no proof debt.
- **Performance clears the acceptance bar by more than an order of magnitude.** On a passing family padded to **total segment length 101**, the four checks took **~68 ms in the Lean interpreter** (coh 23 ms, ful 0 ms, box 0 ms, tgt 45 ms). The shipped executable runs compiled code, so "well under a second under total segment length 100" is met with large margin.
- **Precise failure localization is already available from `Decide.lean`'s exposed intermediate predicates** — `CoherentAt`, `eventClauseAt`/`FulfilAt`, `boxClause`, plus the window bounds `labCohWindowLo/Hi`, `labFulWindowLo/Hi` and `Finset.Ico (-nb) (nm+nf)`. A spike scan over `sepFamily` returned `some (0, -2, p U q)`: lasso 0, position -2, and the exact unfulfilled obligation. That is literally the acceptance criterion "rejected naming that obligation".
- **One blocking implementation gotcha: `Finset.toList` is noncomputable in Mathlib**, so the diagnostic scan cannot iterate a `Finset` directly. Two tiny computable helpers are required: a closure enumeration list (`(S.flatMap Formula.subformulas).dedup`, with a one-line `simp` membership lemma — proved in the spike) and an `Int` range list. Both are cheap and belong in `CertificateImport.lean`.
- **The tag-format parser `pFormula` is currently trapped inside `BimodalTools/TableauBridge.lean`**, whose import closure is the whole tableau engine plus `DatasetGenerator`. Importing it from `CertificateImport.lean` would couple the certificate checker to machinery it does not use; copying it would make a **third** verbatim copy (`BenchmarkOracleMain.lean` already holds the second). Recommendation: extract into a new `BimodalTools/JsonParse.lean`. Verified safe — **nothing outside the two declaring files references the parser**.
- **The enumerated INPUT schema omits the target time.** `Target` is time-indexed; the schema in the task description lists only premises, conclusions, box guess and lassos. Recommended resolution: an **optional** `"time"` integer field defaulting to `0` (backward compatible with the enumerated schema, and `0` is what `posFamily.Target 0` already uses).
- **Six prose sites hardcode "the 12 executable roots" and two hardcode "15 non-`Main` modules"** and go stale the moment this target lands. CI itself is safe (it enumerates targets through `scripts/lake_targets.py exe-roots`), but the counts are checked by human review and appear inside gate scripts.

## Context & Scope

Researched: how to build `lake exe check_certificate` on top of the certificate layer delivered by the witness-family soundness task, covering (a) whether the four `Decidable` instances actually compute on runtime-constructed data, (b) how to construct a dependently-typed `WitnessFamily Γ Del` from parsed JSON, (c) how to report *which* condition failed and *where*, (d) what JSON infrastructure already exists, (e) measured performance against the acceptance bar, and (f) the full repository gate surface a new `lean_exe` target plus two new library modules must satisfy.

Out of scope: the ModelChecker-side emitter, and any change to `FormalSystem/` (the certificate layer is complete and this task consumes it read-only).

## Findings

### Codebase Patterns

**The certificate datatype and its proof obligations** (`FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean`):

- `LabelledLasso (C : Finset Formula)` carries `back mid fwd : List (Finset Formula)` plus three *proof* fields: `back_ne : back ≠ []`, `fwd_ne : fwd ≠ []`, and `label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C`.
- `WitnessFamily (Γ Del : Context)` carries `bx : Formula → Bool`, `lassos : List (LabelledLasso (closureOf (Γ ++ Del)))` and `lassos_ne : lassos ≠ []`.
- The file states explicitly that "**Field names are an export contract**": `back`, `mid`, `fwd`, `bx`, `lassos` are mirrored field-for-field by the model checker's JSON export, and renaming any of them is a breaking change. The task's "field names mirror the Lean structure exactly" is therefore already the module's own stated contract.

**Constructing that structure at runtime is the central design problem, and it is solved by `dite`.** All four proof fields are decidable propositions over computable data, so each is discharged by an `if h : _ then _ else _`. The spike (Appendix, Spike A) type-checked and compiled with no `noncomputable` marker:

```
if hb : back = [] then .error "back empty" else
if hf : fwd  = [] then .error "fwd empty"  else
if hs : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C then
  .ok { back, mid, fwd, back_ne := hb, fwd_ne := hf, label_sub := hs }
else .error "label outside closure"
```

`Γ`, `Del` and therefore `closureOf (Γ ++ Del)` are all runtime values; the dependent type causes no difficulty as long as the family is built and checked inside one scope.

**The four `Decidable` instances are genuinely computable** (`WitnessFamily/Decide.lean`): `decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful`, `decidableTarget`. Each is `decidable_of_iff` over a window collapse, and each window is a `Finset.Ico` at `ℤ` or a `Finset` quantifier over the closure. `Examples.lean` already runs all four through `#guard @Decidable.decide _ ...`; Spike B ran them on runtime-constructed families and got the expected three-way discrimination.

**The box guess arrives as pairs and must become a function.** `bx : Formula → Bool` cannot be parsed directly; the importer builds `fun φ => (pairs.find? (·.1 == φ)).map Prod.snd |>.getD false`. Spike B confirmed this reproduces `posFamily`'s own `fun ψ => (ψ == occurs) || (ψ == once)` exactly (same verdict, all four conditions true), because `occurs` and `once` are the only two formulas `BoxFaithful` reads. `Formula` derives `DecidableEq` and `BEq` (`FormalSystem/Syntax/Formula.lean:108`), so the lookup is well-defined.

**Failure localization uses predicates `Decide.lean` already exports**, so no new mathematics is needed:

| Condition | Per-unit predicate | Scan range |
|---|---|---|
| `LocalCoherentLab` | `LabelledLasso.CoherentAt W.bx Λ t` (and `labClauseAt` per closure member) | `[labCohWindowLo Λ, labCohWindowHi Λ)` = `[-2·nb, nm + 2·nf)` |
| `FulfillingLab` | `LabelledLasso.eventClauseAt Λ t ψ` (`FulfilAt` is its closure conjunction) | `[labFulWindowLo Λ, labFulWindowHi Λ)` = same window |
| `BoxFaithful` | `WitnessFamily.boxClause W ψ`; counter-position via `instDecidableMemAll` | closure members; positions `[-nb, nm + nf)` |
| `Target t` | membership of each `γ ∈ Γ` / `σ ∈ Del` in `W.main t` | the single position `t` |

Because these are exactly the units the top-level instances decide over (via `localCoherentLab_iff_lassos`, `fulfillingLab_iff_lassos`, `boxFaithful_iff_forall` and the window-collapse theorems), a diagnostic scan cannot disagree with the verdict.

**`Finset.toList` is noncomputable** — the one hard blocker found. Spike C failed to compile with `failed to compile definition, consider marking it as 'noncomputable' because it depends on 'Finset.toList'`. Spike D fixed it with two helpers, both verified:

- `def closureList (S : Context) : List Formula := (S.flatMap Formula.subformulas).dedup`, with `theorem mem_closureList : ψ ∈ closureList S ↔ ψ ∈ closureOf S := by simp [closureList, mem_closureOf, subformulaClosure]` — a genuine one-line proof, and `(closureList gammaPos).length = (closureOf gammaPos).card = 16` on the live example.
- `def intRange (a b : Int) : List Int := (List.range (b - a).toNat).map (fun k => a + (k : Int))` for `Finset.Ico` at `ℤ`.
- `List.finRange W.lassos.length` is the computable enumeration of the lasso index and worked unchanged.

**JSON infrastructure already in the tree:**

- `Formula.toJson` exists in `BimodalTools/DataExport.lean` as a `_root_` extension, and its schema (`BimodalTools/DataExport.lean:101-107`) is exactly the tag format `pFormula` parses — `atom`/`bot`/`imp`(left,right)/`box`(child)/`untl`(event,guard)/`snce`(event,guard). It is the serializer the round-trip test needs, already written.
- `DataExport`'s import closure is light (`FormalSystem.Syntax`, `Automation.SuccessPatterns`, `Metalogic.Decidability.CountermodelExtraction`, `ProofSystem.Derivation`).
- `pFormula` and its `PState` machinery exist **twice**, verbatim, in `BimodalTools/TableauBridge.lean:143-315` and `BimodalTools/BenchmarkOracleMain.lean` (the latter's own header calls it a replication made to dodge the root-`main` collision). A repo-wide grep found **zero** references to `PState`, `mkPState`, `pFormula`, `pString`, `pSkipValue`, `pNat`, `pExpect` outside the two declaring files — in particular `Tests/BimodalToolsTest/TableauBridgeTest.lean` touches only `evalBranchGates`, `BranchGates` and `parseFrameClass`.

**One round-trip fidelity caveat:** `Formula.toJson` serializes `atom a` as `{"tag":"atom","name":a.base}`, dropping `Atom.freshIndex`; `pFormula` reads it back as `Formula.atomS name = Atom.mkBase name = ⟨name, none⟩`. Round-trip is exact only for base atoms. `WitnessFamilyExamples` uses `Atom.mkBase` throughout, so the acceptance round-trip is unaffected — but a certificate carrying a fresh-indexed atom would silently change identity, which matters because `Finset Formula` membership is by `DecidableEq`.

**Test-library idiom** (`Tests/BimodalToolsTest/`): `#guard` rows on pure functions, with `weak.linter.hashCommand = false` set for the test library in `lakefile.toml`. `TableauBridgeTest.lean` is the closest model. Tests import library halves, never `*Main` roots (the aggregator's own comment explains why: two root-namespace `main`s cannot share an environment). This is precisely why the task puts parsing in `CertificateImport.lean`.

### External Resources

No Mathlib gap was found and no external search was needed: every predicate, window collapse and `Decidable` instance the executable consumes already exists in-tree, delivered by the soundness task. The only Mathlib facts load-bearing here are `Finset.decidableMem`/subset decidability, `List.decidableBAll`, `Fintype.decidableForallFintype` and the noncomputability of `Finset.toList` — all confirmed by direct elaboration rather than from memory.

### Build, Gate and Documentation Surface

- **lakefile**: add a `[[lean_exe]]` block `name = "check_certificate"`, `root = "BimodalTools.CheckCertificateMain"`, `supportInterpreter = true`, matching the twelve siblings.
- **C25N** (`scripts/check-module-invariants.sh`) requires the root be named `PascalCase(target) ++ "Main"`: `check_certificate` → `CheckCertificateMain`. The task's placement already complies.
- **CI needs no edit**: the "Compile lean_exe roots" step enumerates roots through `python3 scripts/lake_targets.py exe-roots` (`.github/workflows/ci.yml:69-78`), so a new lakefile target is picked up automatically. `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` cover the two new library modules and the test, **at zero compiler warnings** — including the 100-character line limit and `linter.unusedSimpArgs`, both of which the research spikes tripped and which are `blocking` in `scripts/warning-budget.txt`.
- **`BimodalTools.lean`** must import the new non-`Main` modules (`BimodalTools.CertificateImport`, and `BimodalTools.JsonParse` if extracted); `*Main` stays out by construction.
- **`Tests/BimodalToolsTest.lean`** must import the new test module.
- **`BimodalTools/README.md`** carries a machine-owned inventory block (`<!-- BEGIN GENERATED: inventory dir=BimodalTools -->`). Regenerate with `bash scripts/check-module-invariants.sh --emit-inventory`, verify with `--emit-inventory --check`, and update the `*Last verified*` date at the file's end. The schema section goes next to `## Tableau bridge protocol`, per the task.
- **Copyright headers**: `scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` gates the `BimodalTools/*Main.lean` roots. Every new file needs the standard four-line Apache block plus a module docstring as the first command after the imports.
- **Stale hardcoded counts** — "12 executable roots" becomes 13:
  `lakefile.toml:5`, `BimodalTools.lean:23`, `BimodalTools/README.md:10`, `scripts/check-copyright-headers.sh:20`, `scripts/check-module-invariants.sh:5359`, `.github/workflows/ci.yml:83` (and `ci.yml:61`'s "thirteen of them", which counts `checkInitImports` too, becomes fourteen).
  "15 non-`Main` modules" becomes 17: `.github/workflows/ci.yml:83`, `scripts/module-invariants-manifest.txt:28`.
  `docs/development/PUBLICATION_REFACTOR.md` also says "12" in four places but is a historical record of a completed refactor and should be left alone.

## Decisions

- **Verdict comes from the four top-level `Decidable` instances; the granular scan is diagnostics only.** Running `decide W.LocalCoherentLab` (etc.) keeps the accepted path grounded in exactly the instances `WitnessFamily.joint_countermodel` consumes, so acceptance means the soundness theorem applies. The per-position scan runs only to localize a failure. This also preserves short-circuiting on the reject path.
- **Target time is an optional `"time"` field defaulting to `0`.** The enumerated schema omits it; an optional field is backward compatible, and `0` is the origin the certificate layer's own `Target` example uses. Rejected alternative: searching the main lasso's window for some satisfying `t`, because there is no in-tree theorem that a window scan is complete for `Target`, and an incomplete search would produce unexplained rejections.
- **Structural violations are `rejected`, malformed JSON is `error`.** A label outside `closureOf (Γ ++ Del)`, an empty `back`/`fwd`, or an empty `lassos` list is certificate *content* that fails a structural precondition, so it belongs in `{"status":"rejected","failed":[...]}` under a named structural condition. Unparseable input is a protocol failure and gets `{"status":"error","message":...}`, mirroring `TableauBridge`'s existing behaviour.
- **Never emit a validity claim.** `rejected` means "this object is not a certificate", never "the consequence holds" — the checker is one-sided by construction, and the `failed` list is the only thing it asserts.

## Recommendations

Prioritized; owner is the implementing agent unless noted.

1. **Extract the tag-format parser into `BimodalTools/JsonParse.lean`** (`PState`, `mkPState`, `pEof`, `pPeek`, `pAdvance`, `pSkipWS`, `pExpect`, `pString`, `pSkipValue`, `pNat`, `pFormula`) under `namespace BimodalTools.JsonParse`, and re-point `BimodalTools/TableauBridge.lean` at it by deleting its copy and adding `open BimodalTools.JsonParse`. Verified safe: no external references. This makes `CertificateImport` depend on a ~200-line parser module instead of the whole tableau engine, and removes one of the two existing duplicates rather than adding a third. `BimodalTools/BenchmarkOracleMain.lean`'s copy can be retired the same way as optional follow-on; it is an exe root, so nothing imports it.
2. **Write `BimodalTools/CertificateImport.lean`** containing: the raw parsed record types; `closureList` + `mem_closureList` + `intRange`; `bxOf`; the `dite`-based `mkLasso`/`mkFamily` builders; a `CheckResult` type; `checkCertificate` returning the verdict plus the first failing `(condition, lasso, position, formula)`; and `toJson` for the result. Put the certificate **serializer** here too (built on the existing `Formula.toJson`) so the round-trip test is a `#guard` and the schema is pinned executably.
3. **Write `BimodalTools/CheckCertificateMain.lean`** as `main` only — read stdin, call `CertificateImport`, print one JSON line — matching the 23-line `TableauBridgeMain.lean` shape.
4. **Write `Tests/BimodalToolsTest/CertificateImportTest.lean`** with at minimum: (a) `posFamily`'s data serialized and re-imported, accepted with all four conditions true; (b) `sepFamily`'s data rejected with `failed` naming `fulfilling` at lasso 0, position -2, formula `p U q` — the spike already produced exactly this tuple; (c) a structural rejection (label outside the closure); (d) a `pFormula ∘ Formula.toJson = id` round-trip row on the closure members. Import the library module, never the `*Main` root.
5. **Document the schema in `BimodalTools/README.md`** under a new section beside `## Tableau bridge protocol`, naming the fields `premises`, `conclusions`, `bx`, `lassos` (each with `back`/`mid`/`fwd`), and the optional `"time"`. State explicitly that atom names round-trip on `Atom.base` only.
6. **Update the stale counts and regenerate the inventory** (see the six + two sites listed under Findings), then run `bash scripts/check-module-invariants.sh --emit-inventory --check`.
7. **Validate atom shape on import**: reject, or at least document, certificates whose atom names would not round-trip. Cheap insurance against a silent `Finset` membership mismatch.

## Risks & Mitigations

- **Risk**: importing `BimodalTools.TableauBridge` for `pFormula` drags the tableau engine and `DatasetGenerator` into the checker's closure, slowing `lake build` and coupling unrelated code. **Mitigation**: recommendation 1 (extract `JsonParse.lean`).
- **Risk**: a third verbatim copy of the parser if recommendation 1 is skipped. **Mitigation**: the extraction is verified zero-reference and therefore mechanical; if it is deferred, record the third copy explicitly rather than leaving it undocumented.
- **Risk**: `Finset.toList`'s noncomputability is discovered mid-implementation and mistaken for a structural obstruction. **Mitigation**: `closureList`/`intRange` are already written and verified in Spike D; carry them into the plan verbatim.
- **Risk**: `--wfail` turns a stray >100-character line or unused `simp` argument into a red CI. **Mitigation**: both classes are `blocking` in `scripts/warning-budget.txt`; build the two library modules with `--wfail` locally before the phase is called green.
- **Risk**: acceptance is read as a soundness claim about the *checker binary*. **Mitigation**: the module docstring should state the trust model plainly — the binary evaluates the same compiled `Decidable` instances that `joint_countermodel` consumes, so `countermodel` means those instances returned `true`; it is not a kernel-checked proof for that particular certificate. This mirrors the honesty of the `"gates"` field in the tableau bridge protocol and of `context/project/lean4/tools/comparator-guide.md`'s trust model.
- **Risk (low)**: performance on adversarial inputs. The scan is `O(window × |closure| × witness-range)`; at total segment length 101 with a 16-member closure it measured ~68 ms interpreted. A pathological closure (many nested `untl`/`snce`) would grow this, but stays far from the one-second bar at the stated input size.

## Tactic Survey Results

Not applicable in the usual sense — no open proof goal required tactic search. All four conditions are discharged by existing `Decidable` instances at runtime, and the only new proof obligation found (`mem_closureList`) was closed by a single `simp` call, verified live:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `ψ ∈ closureList S ↔ ψ ∈ closureOf S` | `simp` | success | `[closureList, mem_closureOf, subformulaClosure]` |
| `label_sub` for a padded replicated lasso | `intro` + `rcases` + `exact` | success | reuses `posLasso.label_sub` / `sepLasso.label_sub` |
| structure fields at runtime (`back_ne`, `fwd_ne`, `label_sub`, `lassos_ne`) | `dite` on synthesized instance | success | no tactic needed; `infer_instance` resolves all four |

## Context Extension Recommendations

- **Topic**: certificate-checker trust model for this repository.
  **Gap**: `context/project/lean4/tools/comparator-guide.md` documents what a green Comparator result does and does not certify, and `BimodalTools/README.md` documents the `"gates"` honesty contract, but there is no single statement of what a *compiled `Decidable` instance returning `true`* licenses versus a kernel-checked proof. This executable is the third artifact to need it.
  **Recommendation**: a short `context/project/lean4/tools/decidable-instance-trust.md`, or a paragraph appended to `comparator-guide.md`, stating the distinction once so each new checker can point at it.

## Appendix

**Spikes run** (all via `lean_run_code` against the built `FormalSystem` oleans; no repository file was modified):

- **Spike A** — runtime construction. `mkLasso`/`mkFamily`/`check` elaborated and compiled with every structure field discharged by `dite`. `#print axioms` reported `[propext, Classical.choice, Quot.sound]` for all three, which is the ordinary profile of proofs *inside* the instances' correctness arguments and does not block computation — confirmed by Spike B actually running them.
- **Spike B** — verdicts on runtime-built families:
  `posFamily` data → `Except.ok (true, true, true, true)`;
  `sepFamily` data → `Except.ok (true, false, true, true)`;
  `posFamily` with `fP` erased from `labBack` → `Except.ok (false, true, true, true)`.
- **Spike C** — the noncomputability blocker: `Finset.toList` rejected the diagnostic scan at compile time.
- **Spike D** — localization, with the computable helpers: `firstCohFailure posFamily = none`, `firstFulFailure posFamily = none`, `firstCohFailure sepFamily = none`, `firstFulFailure sepFamily = some (0, -2, p U q)`; `(closureList gammaPos).length = 16 = (closureOf gammaPos).card`.
- **Spike E** — timing on `posLasso` with both cycles replicated (the decoded label function is unchanged, so the family still passes; only the scan windows grow):

  | total segment length | verdict | coh | ful | box | tgt |
  |---:|---|---:|---:|---:|---:|
  | 3 | (true,true,true,true) | 2 ms | 0 ms | 0 ms | 0 ms |
  | 11 | (true,true,true,true) | 3 ms | 0 ms | 0 ms | 0 ms |
  | 31 | (true,true,true,true) | 11 ms | 0 ms | 0 ms | 6 ms |
  | 101 | (true,true,true,true) | 23 ms | 0 ms | 0 ms | 45 ms |

  A second timing run on a padded separation family (constant label, closure of size 3) at total segment length 200 completed a full no-early-return scan of both windows in under 1 ms.

**Key file references**: `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` (structures and the export-contract note), `.../Predicates.lean` (the four conditions), `.../Decide.lean` (window collapses, per-unit predicates, the four instances), `.../Examples.lean` (`posFamily`, `sepFamily`, and the `#guard` rows proving the instances compute), `BimodalTools/DataExport.lean:101-120` (`Formula.toJson`), `BimodalTools/TableauBridge.lean:143-315` (the parser to extract), `.github/workflows/ci.yml:55-108` (the three build steps a new target must pass).
