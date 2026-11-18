# Research Report: Task #937

**Task**: 937 - Fix red CI workflows on main
**Started**: 2026-11-18T15:26:59-08:00
**Completed**: PENDING
**Effort**: Medium
**Dependencies**: None (sibling tasks 829 and 938 are adjacent in `.github/workflows/` territory, not dependencies)
**Sources/Inputs**:
- Codebase: `Tests/BimodalToolsTest/CertificateImportTest.lean`, `BimodalTools/CertificateImport.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Enumerate.lean`, `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean`, `.github/workflows/ci.yml`, `.github/workflows/docs.yml`, `lakefile.toml`, `docs/development/LEAN_STYLE_GUIDE.md`
- Live CI: `gh run view` per-step outcomes for runs 44420618072, 44411191783, 43387984646, 38855797691, 37218607420, 37102252439
- lean-lsp MCP: `lean_run_code` (5 compiled probes)
- Local compiled gates: `lake-build-guard.sh`, `lake env lean`, `lake exe lint-style`, `lake exe mk_all --check`, `scripts/check-evidence-probes.sh`
- Git history: `git log -L`, `git log -S` on the three colliding declarations
**Artifacts**:
- `specs/937_fix_red_ci_workflows_on_main/reports/01_fix-red-ci-workflows.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Finding 1 reproduced and root-caused.** `closureList` is declared in two namespaces the test
  opens; the error is pure name resolution, not semantics. Commit `22e2afa46` (2026-11-12, "task
  830 phase 1: generalize the enumeration in Enumerate.lean") **introduced**
  `FormalSystem.Metalogic.Decidability.closureList` as a new declaration, colliding with
  `BimodalTools.CertificateImport.closureList` which has existed since 2026-09-24. The test has
  used the unqualified name since it was written, resolving unambiguously until that commit.
- **The `#guard` verdict is insensitive to which declaration resolves.** Measured: both lists have
  the same `toFinset` on both test inputs, and both `#guard` rows pass under either declaration.
  So there is no hidden semantic question about "which one the test should be reaching" — the
  intended one is established by provenance (the test was written against the `BimodalTools` one),
  and the two agree on the property being tested.
- **A SECOND, MASKED FAILURE blocks `CI / Build and Test`.** `lake exe lint-style` exits 1 with
  4 "space before a semicolon" findings in
  `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean:383,390,413,420` (introduced
  2026-11-06, commit `7e00fe171`). That CI step is currently **skipped** behind the
  `Compile BimodalToolsTest` hard stop, so **fixing the ambiguity alone leaves the job red** via
  the aggregating `Report results` gate. This is not in the task record.
- **Recommended Finding-1 fix is the rename, not the qualification.** Renaming the `BimodalTools`
  variant closes the *entire* collision class between the two namespaces — measured as exactly two
  colliding names, `closureList` and `mem_closureList` (the second currently latent but armed) —
  and removes a duplicated definition and duplicated proof. The minimal qualification fix is also
  measured green and is recorded as the de-risked fallback.
- **Gate collision found.** `docs/development/LEAN_STYLE_GUIDE.md` §5 mandates a deprecated alias
  retaining the old name on any rename. Measured: a `@[deprecated] abbrev` keeping the old name
  still produces `Ambiguous term`, so §5 applied literally would leave CI red. The rename must
  waive the alias explicitly.
- **Finding 2**: PENDING

## Context & Scope

Two independently red GitHub Actions workflows on `main`: `CI / Build and Test` and
`API Documentation`. The task record names one cause for each. Scope boundary from the record,
observed here: no `.lake/build` CI cache work (task 829's record), and `.github/workflows/`
touched only as far as the doc-gen4 fix requires.

Research scope extended in one direction beyond the record, deliberately: because the record's
Finding 1 cause is a *hard stop* in CI, every later step in that job is skipped, and the record's
third verification criterion is "both workflows report success on a real run". Establishing
whether the named fix actually reaches green therefore required measuring the skipped steps. That
is what surfaced the masked `lint-style` failure.

### Redness timeline (from `gh run list --workflow=ci.yml --branch main`)

Last fully green `CI` run on `main`: **37102252439, 2026-10-03**. Since then, three successive and
unrelated causes, the first two already repaired in-tree:

| Run | Date | Failing step | Status of that cause today |
|-----|------|--------------|----------------------------|
| 37218607420 | 2026-10-04 | `Report results` (all 15 checks green; report/`expected` count out of sync) | Repaired — current `ci.yml` has 9 report lines and `expected=9`; latest run reports this step `success` |
| 38299844116 / 38674668629 / 38855797691 | 2026-10-12..16 | `Build, test, and lint with Lean` | Repaired — `success` in every run since 2026-11-13 |
| 43387984646 .. 44420618072 | 2026-11-13..18 | `Compile BimodalToolsTest` | **LIVE — this task's Finding 1** |

## Findings

### Codebase Patterns

**The two `closureList` declarations are different functions with the same name.**

| | `BimodalTools.CertificateImport.closureList` | `FormalSystem.Metalogic.Decidability.closureList` |
|---|---|---|
| Site | `BimodalTools/CertificateImport.lean:149` | `.../Compression/Enumerate.lean:137` |
| Body | `(S.flatMap Formula.subformulas).dedup` | `S.flatMap Formula.subformulas` |
| Added | `2b9b7adce`, 2026-09-24 | `22e2afa46`, 2026-11-12 |
| Internal call sites | `CertificateImport.lean:338,348,357` (the localization scans) | `Enumerate.lean:147,159` (`closureSubsetsOfCtx`) |
| `closureList gammaPos` length (measured) | **16** | **33** |
| `closureList gammaSep` length (measured) | 3 | 3 |

Both carry a `mem_closureList` theorem proving `ψ ∈ closureList S ↔ ψ ∈ closureOf S`, so the two
lists have identical *member sets* and differ only in multiplicity. Measured: `.toFinset` equality
holds on both test inputs.

**Why the test errors and `CertificateImport.lean` itself does not.** Lean 4 lets a declaration in
the *current* namespace shadow an `open`ed one, but two `open`ed namespaces offering the same name
are an ambiguity. `BimodalTools/CertificateImport.lean` is inside
`namespace BimodalTools.CertificateImport` and also does `open FormalSystem.Metalogic.Decidability`
— its own declaration wins, and it compiles. `Tests/BimodalToolsTest/CertificateImportTest.lean`
is inside `namespace BimodalToolsTest.CertificateImport` and `open`s **both** (lines 37 and 40), so
neither shadows the other.

**The collision class is exactly two names.** Mechanical intersection of the names declared
directly in `namespace BimodalTools.CertificateImport` (35) against those declared directly in
`namespace FormalSystem.Metalogic.Decidability` (3910, across every file carrying that namespace
header) yields exactly:

- `closureList` — the live CI error
- `mem_closureList` — **latent but armed**; measured to produce the identical `Ambiguous term`
  error the moment anything references it under both opens

Method tier: line-anchored `awk`/`sed` extraction of `def|abbrev|theorem|lemma|structure|inductive|instance`
headers, which can mis-attribute declarations nested in inner namespaces (inflating the 3910) and
can miss a non-line-anchored declaration form. Both collisions it reports were then confirmed by
compiled probe, so the two positives are measured facts; the *absence* of a third is the weaker
claim here.

**The test's `open` of the `Decidability` namespace cannot simply be dropped.** The test uses
`WitnessFamily` (lines 86, 89) and `LabelledLasso` (docstring, line 80) from it, so narrowing to
`open FormalSystem.Metalogic.Decidability hiding closureList mem_closureList` would be the only
open-level variant. Rejected below.

**`BimodalTools` is not a published API surface.** `lakefile.toml` keeps `BimodalTools` out of
`defaultTargets` on purpose ("a plain `lake build` must compile the published library and nothing
else"), and the published library is `FormalSystem`. `BimodalTools.CertificateImport.closureList`
has three internal call sites and two test call sites, all in this repository, and its
`mem_closureList` has zero use sites outside its own docstrings.

**Why task 830 did not catch this.** `defaultTargets = ["FormalSystem"]`, so neither `lake build`
nor `lake test` (driver `BimodalTest`) ever elaborates `Tests/BimodalToolsTest/`. Only the explicit
`lake build BimodalToolsTest` — which exists solely as its own CI step — reaches the file.

**The second, masked failure.** `CI / Build and Test` currently fails at step 6 and skips steps 7,
14 and 15. Measured locally, those three:

| Skipped step | Local result |
|---|---|
| `scripts/check-evidence-probes.sh` | **green — 67 of 67 wired probes elaborate** (see the caveat below) |
| `lake exe mk_all --lib FormalSystem --check` | **exit 0** ("No update necessary") |
| `lake exe lint-style` | **exit 1 — 4 findings** |

**Caveat on the probe sweep, recorded because the raw output is misleading.** A sweep of
`check-evidence-probes.sh` exited 1 reporting `FAIL (untracked: ...)` for 19 consecutive wired
probes. **Those 19 verdicts are spurious.** Every one of the 19 files is tracked —
`git ls-files --error-unmatch` succeeds for all of them, and `git status --untracked-files=all --
specs/evidence/` lists only the two unrelated `history-morphism-saturation-audit` files as
untracked — and an earlier sweep PASSed 12 of the same 19 before being cut off. The
all-pass-then-all-fail-from-one-point signature is a transient in the script's own
`git ls-files` subprocess (line 3304), not a property of the tree.

The green verdict above is therefore assembled from measurements, not from one sweep's exit code:
60 PASS from the first sweep, plus the remaining 7 probes elaborated individually with
`lake env lean` (`pin-cascade-straddle`, `route-space-closure`, `idle-run-one-ceiling`,
`consumer-shape-witness`, `lcu-lcn-separating-model`, `full-labels-collapse-stab`, and the
`WIRED_REPO` entry `specs/archive/476_.../fmp-hypothesis-is-false.lean`) — all PASS. One entry,
`bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction`, is a declared
`SKIP (deferred: frame-class uniformity work)`, not a failure.

The 4 findings are all `This line contains a space before a semicolon`, in
`FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` at lines 383, 390, 413 and 420
— each an `· intro hC' ; exact ...` / `· intro hF' ; exact ...` focus line, introduced by
`7e00fe171` (2026-11-06, "task 867 phase 20"). No `main` CI run has executed the `lint-style` step
since 2026-10-04, which is why the finding has never been reported.

`lint-style` is `continue-on-error: true`, so it does not hard-stop; the aggregating
`Report results` step counts its outcome and `exit 1`s on any failure. So the job stays red.

**Complete per-step verdict for `CI / Build and Test`.** Every row is either a live-run outcome
or a local measurement, so nothing here is projected from reading the YAML:

| Step | Verdict | Evidence |
|---|---|---|
| 3. `Build, test, and lint with Lean` (`--wfail`, `lake test`, `lake lint`) | green | live run 44420618072 |
| 4. `Compile lean_exe roots` (15 roots) | green | live run |
| 5. `Compile BimodalTools --wfail` | green | live run |
| 6. `Compile BimodalToolsTest --wfail` | **RED** | live run + local reproduce, exit 1 |
| 7. `check-evidence-probes.sh` | green | local, 67/67 (see caveat) |
| 8-13. module invariants, copyright, readme, cycles, typst sync, paper defs | green | live run |
| 14. `mk_all --lib FormalSystem --check` | green | local, exit 0 |
| 15. `lint-style` | **RED** | local, exit 1, 4 findings |
| 16. `Report results` | green once 15 is green | counts 9 outcomes; `expected=9` matches the 9 report lines |

So **R1 (or R3) plus R2 is the complete fix for this workflow** — there is no third cause. Step 6
is the only hard stop and step 15 the only other failing check.

### External Resources

- **Lean 4 name resolution**: a `@[deprecated]` attribute does not remove a name from resolution.
  Measured directly (isolated two-namespace probe): `@[deprecated fooDedup (since := ...)] abbrev
  foo := fooDedup` in one namespace, `def foo` in another, both `open`ed, yields `Ambiguous term`.
- **Mathlib `lint-style`** (`lake exe lint-style`, the linting core of
  `leanprover-community/lint-style-action`): takes module names, not arbitrary file paths, and its
  `--fix` mode repairs the space-before-semicolon class automatically. `scripts/nolints-style.txt`
  exists and is deliberately empty — the enforced set passes at 0 findings without any waiver, so
  waiving these 4 would be a first exception rather than a routine one.
- **`docs/development/LEAN_STYLE_GUIDE.md` §1** — a `def` producing data is lowerCamelCase, so
  `closureListDedup` conforms. **§5 Deprecation Protocol** — "When renaming, create an alias
  pointing to the new name"; see the gate collision under Risks.

### Recommendations

**R1 — Rename `BimodalTools.CertificateImport.closureList` to `closureListDedup`, defined in terms
of the core declaration, with NO deprecated alias.**
[VERIFIED: PASS -- `lean_run_code` elaborated the proposed `def closureListDedup (S : Context) :
List Formula := (FormalSystem.Metalogic.Decidability.closureList S).dedup` together with
`theorem mem_closureListDedup ... := by simp [closureListDedup, List.mem_dedup, mem_closureList]`;
both compiled with zero diagnostics, `#eval closureListDedup gammaPos ==
BimodalTools.CertificateImport.closureList gammaPos` and the `gammaSep` analogue both returned
`true` (element-for-element, order included), and both retargeted `#guard` rows passed]

Edit list (10 sites, all mechanical):

| File | Lines | Change |
|---|---|---|
| `BimodalTools/CertificateImport.lean` | 149 | `def closureList` -> `def closureListDedup`, body -> `(FormalSystem.Metalogic.Decidability.closureList S).dedup` |
| | 152-155 | `mem_closureList` -> `mem_closureListDedup`; `simp [closureListDedup, List.mem_dedup, mem_closureList]` |
| | 338, 348, 357 | call sites |
| | 56, 59, 100, 118 | module-docstring mentions |
| `BimodalTools/README.md` | 384 | inventory row naming `closureList` |
| `Tests/BimodalToolsTest/CertificateImportTest.lean` | 146, 152 | `closureList` -> `closureListDedup` (no qualification then needed) |

Why this over the alternatives:
- It closes **both** collisions, including the latent `mem_closureList` one, rather than the two
  sites that happen to error today.
- It removes a duplicated definition body and a duplicated proof: the renamed declaration is
  defined *through* the core one instead of restating `S.flatMap Formula.subformulas`.
- The name then discloses the difference the measurement found (16 vs 33 elements). Under the
  current naming, a reader who resolves the wrong `closureList` gets a correct but ~2x longer scan
  with nothing in the name to warn them.
- Renaming the *other* declaration is the wrong direction: it sits in the verified core, its name
  is accurate for what it is, and it has more call sites.

**R2 — Delete the four spaces before `;` in
`FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean:383,390,413,420`.**
[VERIFIED: PASS -- applied the four-character edit in the working tree, ran the gate unpiped
(`lake exe lint-style`, exit **0**, no output, down from exit 1 with 4 findings), then restored the
file and confirmed byte-identity with HEAD via `git diff --quiet`. Semantic inertness separately
confirmed by `lean_run_code`: `intro h ; exact h` and `intro h; exact h` both elaborate]

`lake exe lint-style --fix` performs exactly this repair; applying it by hand to those four lines
is equivalent and keeps the diff auditable. Do **not** waive these via `scripts/nolints-style.txt`
— that file is deliberately empty and the enforced set otherwise passes at 0.

**R3 — Fallback for R1 if the plan prefers minimality: qualify the two test call sites.**
[VERIFIED: PASS -- `lake env lean` on a scratchpad copy of the test with lines 146/152 rewritten to
`BimodalTools.CertificateImport.closureList gammaPos` / `... gammaSep`, under the exact
`BimodalToolsTest` Lean options from `lakefile.toml` (`-D pp.unicode.fun=true -D
autoImplicit=false -D weak.linter.hashCommand=false -D weak.linter.mathlibStandardSet=true -D
weak.linter.style.longFile=1500 -D weak.linter.unicodeLinter=false`): exit 0 with **zero errors
and zero warnings**, so it is `--wfail`-clean and within the 100-column limit. The tracked file was
not modified]

This is a strict subset of R1's benefit: it fixes the hard stop and leaves `mem_closureList` armed.
Recorded because it is independently measured green, so the plan can fall back to it without
re-verification.

**R4 — Reject `open FormalSystem.Metalogic.Decidability hiding closureList mem_closureList`.**
[No compiled gate applicable -- this is a readability judgment, not an acceptance question]

It would work, but it moves the disambiguation away from the call site: a reader at line 146 could
no longer see which `closureList` is meant, and the `hiding` list would silently need extending on
every future collision. The same objection applies to relying on `open` order, which in any case
does not affect Lean's ambiguity behavior.

**R5 — Do not "reconcile" the two declarations into one.**
[VERIFIED: PASS -- measured `closureList gammaPos` at 16 elements under the `BimodalTools`
declaration and 33 under the core one via `#eval` in `lean_run_code`, with `.toFinset` equal]

They are not the same function. Deleting the deduped variant would roughly double the list the
three `find?`/`findSome?` localization scans in `CertificateImport.lean` walk, on measured data, for
no CI benefit. Deleting the core one is impossible — `closureSubsetsOfCtx` maps `.sublists` over
it, where dedup would change the enumerated subset multiset.

**R6 — Finding 2 (`API Documentation` / doc-gen4 `srcUri.github`)**: PENDING

## Decisions

1. **The test is meant to reach `BimodalTools.CertificateImport.closureList`** — settled by
   provenance, not by `open` order. The test file was created 2026-09-24 (`926464427`) with the
   unqualified name, when only the `BimodalTools` declaration existed; the retarget to the verified
   codec (`12be620c2`, 2026-09-27) changed the round-trip body and left the `closureList` head
   untouched. The task record's concern that "which of the two the test should be reaching may not
   be what the current `open` order happens to pick" resolves two ways: `open` order is irrelevant
   (Lean errors rather than picking), and the two declarations agree on the tested property anyway.
2. **The ambiguity is the sole hard stop in `CI / Build and Test`, but not the sole failure.**
   Per-step evidence from the live run (not inferred from YAML): steps 3-5 — including the
   `--wfail` `lean-action` build, `lake test`, `lake lint`, the 15 `lean_exe` roots, and
   `lake build BimodalTools --wfail` — all `success`. So no other `--wfail` work is red, and the
   record's second verification criterion is already met everywhere except the one test module.
3. **Rename over qualification** (R1 over R3), on the collision-class measurement.
4. **No deprecated alias on the rename**, waiving style guide §5 — see Risks.
5. **R2 is in scope for this task.** It is a second cause of the same workflow's redness, the
   record's acceptance criterion is a green run, and it is a four-character edit. Filing it
   separately would leave this task unable to meet its own criterion.

## Risks & Mitigations

- **Style guide §5 would reinstate the bug.** §5 says "When renaming, create an alias pointing to
  the new name". Measured: a `@[deprecated] abbrev` retaining the old name still produces
  `Ambiguous term` under two opens. **Mitigation**: waive the alias, and record why in the commit
  — `BimodalTools` is outside `defaultTargets` and is not a published surface, the old name has
  five in-repo use sites and zero external consumers, and an alias would defeat the fix's purpose.
  Consider a one-line scope note in §5 ("the alias step applies to the published `FormalSystem`
  surface") so the next rename does not re-collide.
- **R2 touches a `FormalSystem` file under concurrency.** Sibling tasks 829 and 938 were dispatched
  this same cycle with no declared `file_scope`. **Mitigation**: re-read
  `NormalForm.lean:380-425` immediately before editing, stage only those four lines explicitly
  (`git add -- <path>`, never a directory or glob), and confirm the file was clean beforehand.
- **R1's blast radius is 10 sites across 3 files.** **Mitigation**: `grep -rn 'closureList'
  --include=*.lean --include=*.md . | grep -v '^./.lake\|^./specs/'` is the complete site list and
  was used to build the table above; re-run it after the edit to confirm zero stragglers in
  `BimodalTools`. `readme-lint.sh` is a CI check, so the `BimodalTools/README.md:384` row is not
  optional.
- **Verification criterion 3 cannot be met by this task.** Both workflows reporting success
  requires a push, which `.claude/rules/pr-prohibition.md` bars agents from performing. The task
  ends at a local commit plus the local gate evidence; the push and any re-run are the user's step.
- **A sibling's untracked work is present in the tree.** `specs/evidence/history-morphism-saturation-audit/`
  holds two untracked `.lean` probe files, present at session start and not touched here. They are
  not in `check-evidence-probes.sh`'s `WIRED` list, so they neither affect that gate nor reach CI.
  Reported, not acted on.

## Tactic Survey Results

Not applicable (no proof goals were under investigation; no tactic survey performed). The compiled
probes run here were elaboration and name-resolution checks, not proof search.

## Context Extension Recommendations

- **Topic**: Lean 4 `open`-level name ambiguity as a CI failure class.
  **Gap**: `.claude/context/project/lean4/` has no note on the asymmetry that makes this bug
  survive local development — a declaration in the current namespace shadows an `open`ed one
  (so the *defining* module compiles), while two `open`ed namespaces do not shadow each other
  (so only a *consumer* module errors). Combined with a `defaultTargets` split that keeps the
  consumer out of `lake build`, a new declaration can break a module its author never compiles.
  **Recommendation**: add `context/project/lean4/patterns/open-ambiguity-collision.md`, with the
  namespace-intersection sweep used here as the mechanical detection recipe and the
  `@[deprecated]`-alias-does-not-help measurement as a recorded trap.
- **Topic**: hard-stop steps masking later `continue-on-error` checks in `ci.yml`.
  **Gap**: `docs/development/CI_CD_PROCESS.md` documents the aggregating-gate design, which exists
  precisely so no check masks another — but the gate only protects the `continue-on-error` steps
  from *each other*. The three plain `run` steps ahead of them (steps 4-6) still mask everything
  below. This task found a 12-day-old finding hidden that way.
  **Recommendation**: record, in `CI_CD_PROCESS.md`, that any repair of a hard-stop step must also
  run the skipped steps locally before claiming the job green — and consider `if: !cancelled()` on
  steps 7, 14 and 15 so a hard stop stops masking them.

## Appendix

### Compiled probes run (all via `lean_run_code` unless noted)

1. **Reproduce**: `lake-build-guard.sh build --timeout 1500 -- build
   BimodalToolsTest.CertificateImportTest` -> exit 1, `Ambiguous term closureList` at 146:8 and
   152:8, naming both interpretations. Matches the record's four lines exactly.
2. **R3 candidate + measurement**: qualified rows pass; `#eval` lengths 16 / 33 (`gammaPos`), 3 / 3
   (`gammaSep`); `.toFinset` equal on both; the row also passes under the core declaration, so the
   `#guard` verdict is resolution-insensitive.
3. **R1 candidate**: `closureListDedup` + `mem_closureListDedup` compile clean; extensional
   equality with the current declaration returns `true` on both inputs.
4. **§5 alias trap**: isolated `NsA.foo` / `NsB.@[deprecated] abbrev foo` probe -> `Ambiguous term`.
5. **Latent collision**: `#check @mem_closureList` under both opens -> `Ambiguous term`, printing
   both signatures.
6. **R2 inertness**: `intro h ; exact h` and `intro h; exact h` both elaborate.
7. **R3 under real Lake options** (`lake env lean` on a scratchpad copy): exit 0, no output.
8. **R2 gate** (`lake exe lint-style`, tree edit applied then restored): exit 1 with 4 findings ->
   exit 0 with none.
9. **`mk_all --check`** (`lake-build-guard.sh ... -- exe mk_all --lib FormalSystem --check`):
   exit 0.
10. **Evidence probes**: first sweep 60 PASS / 0 FAIL (cut off by my own wall, not by the script);
    second sweep 48 PASS then 19 spurious `untracked` FAILs; all 19 re-tested TRACKED; the 7
    probes neither sweep reached elaborated individually, all PASS. Net 67/67.

### Search queries and commands of record

- `grep -rn 'closureList' --include=*.lean .` (excluding `.lake`, `specs`) — the complete site list
- `git log -L 140,155:Tests/BimodalToolsTest/CertificateImportTest.lean` — the test's provenance
- `git log -S'def closureList' -- BimodalTools/CertificateImport.lean` — `2b9b7adce`, 2026-09-24
- `git show 22e2afa46 -- .../Enumerate.lean` — confirms the core declaration was *added*, not moved
- `gh run view <id> --json jobs` — per-step outcomes for six runs
- Namespace-intersection sweep (`awk`/`sed`/`comm`) over `BimodalTools.CertificateImport` vs
  `FormalSystem.Metalogic.Decidability`

### Not used

`lean_local_search`, `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_hammer_premise` —
no Mathlib lemma discovery was needed; every declaration at issue is local and was located by
`grep` plus compiled probes. No rate limit was approached and no MCP tool failed. `lean-lsp`
reachability was `registered` / `reachable` per the dispatch, and `lean_run_code` responded
normally throughout, so findings here are at the compiled-evidence tier rather than the degraded
grep-only tier.

### Blocked tools

`lean_diagnostic_messages` and `lean_file_outline` were not called.
