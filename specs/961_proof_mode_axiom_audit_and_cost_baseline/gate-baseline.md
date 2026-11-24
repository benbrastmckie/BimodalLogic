# Captured Gate Baseline (Phase 1)

Every figure below is the named command's real output at the base commit, captured before any
file of this task existed. Later phases state their verification criteria as a delta against
this file rather than as an absolute zero that a pre-existing finding would make unmeetable.

- **Base commit**: `889bf7c0ce7662208cf7fabc2fb6feb387c3fef4`
- **Captured**: 2026-11-23
- **Toolchain**: `lean-toolchain` pin, Mathlib tag `v4.33.0-rc1` (resolved `79d0395a`)

## 1. `bash scripts/check-module-invariants.sh --no-build`

**Exit status: 1 — `2 CHECK GROUP(S) FAILED`.** Both failures are pre-existing and name no file
this task touches.

```
FAIL  C12  2 unresolved slash-shaped source path(s) in docs/ + README.md
            docs/development/stability-operator-family.md:369: FormalSystem/Theorems/ProofMode/Stability.lean
            docs/development/stability-operator-family.md:369: FormalSystem/Automation/ProofMode/Stability.lean
```

```
FAIL  C20  residual ceiling: 9 (path, category) pair(s) exceed their pinned ceiling in scripts/c20-residual-baseline.txt
            FormalSystem/Metalogic/Expressiveness/Kamp/KMinusFaithfulRendering.lean  unverifiable-file: live 2 > baseline 0
            FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean  unverifiable-file: live 2 > baseline 0
            FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge.lean  unverifiable-file: live 1 > baseline 0
            FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean  unverifiable-file: live 5 > baseline 0
            FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/Base.lean  unverifiable-file: live 17 > baseline 4
            FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/OuterGate.lean  unverifiable-file: live 2 > baseline 1
            FormalSystem/Metalogic/Expressiveness/PriorDefsDense.lean  unverifiable-file: live 1 > baseline 0
            FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean  unverifiable-file: live 2 > baseline 0
            FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean  unverifiable-file: live 1 > baseline 0
```

Relevant passes recorded so a later regression is visible: `PASS C9D zero task-number citations
under docs/`, `PASS C13 all relative markdown links in 71 markdown files resolve`, `PASS C33
FormalSystem.lean is byte-for-byte the generated root`.

**Delta criterion for Phases 2–8**: C12 stays at exactly 2 findings, both naming
`docs/development/stability-operator-family.md:369`; C20 stays at exactly 9 over-ceiling pairs,
all under `FormalSystem/Metalogic/`. A new finding naming any file this task creates is a
failure; an unchanged count on these two is a recorded PASS.

## 2. `ENFORCE_README_DATES=1 bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib`

**Exit status: 1 — `RESULT: FAIL (4 new stale dates, 0 new missing dates)`.**

```
Missing READMEs:          0
Total READMEs found:      98
Markdown files in scope:  98
Broken file references:   0
Files not listed (info):  76
Stale dates (info):       66
Missing dates (info):     4
Stale dates (new):        4
Missing dates (new):      0
```

The four stale-date findings absent from `scripts/readme-date-baseline.txt` — i.e. the four that
make the exit status non-zero — are all pre-existing and all under `FormalSystem/`, which this
task does not touch at all:

```
FormalSystem/Automation/ProofMode/README.md        (stamped 2026-11-19, directory last changed 2026-11-22)
FormalSystem/Metalogic/Conservativity/Star/README.md
FormalSystem/Tactic/README.md                      (stamped 2026-09-21, directory last changed 2026-11-22)
FormalSystem/Theorems/ProofMode/README.md          (stamped 2026-11-19, directory last changed 2026-11-22)
```

**Delta criterion for Phases 2–8**: `Missing READMEs` stays 0 (Phase 3 creates
`BimodalLib/Diagnostics/README.md` in the same phase as the first `.lean` file under it, which is
what keeps Check 1 at zero); `Broken file references` stays 0; and the `Stale dates (new)` set
stays exactly the four rows above. `BimodalLib/README.md` will be refreshed in Phase 3, because
adding `BimodalLib/Diagnostics/` moves `git log -1 -- BimodalLib` and would otherwise add a
fifth new-stale row.

## 3. `bash scripts/typst-sync-check.sh --counts-only`

**Exit status: 0 — no pre-existing drift.**

```
== Check 2 (--counts-only): generated/status.typ vs live regeneration ==
MISMATCH_COUNT=0
All fields in generated/status.typ match a live regeneration.
```

`typst/generated/status.typ` is current at the base commit, so no drift is inherited. Every phase
that stages a `.lean` path under `Tests/` must therefore regenerate it in that same phase
(`lake build && bash scripts/typst-sync-check.sh --fix && git add typst/generated/status.typ`),
since `.githooks/pre-commit` refuses a commit staging a `.lean` path while `status.typ` is
stale and this file records that the blocking condition is this task's own to create.

## 4. Acceptance-example count, re-derived

`grep -c '^example' Tests/BimodalTest/Automation/ProofMode*Test.lean` at the base commit:

```
ProofModeBooleanTest.lean:6
ProofModeModalTemporalBooleanTest.lean:6
ProofModeTest.lean:31
ProofModeTemporalBooleanTest.lean:5
ProofModeModalBooleanTest.lean:4
```

Total **52**, matching the plan's re-derived figure. No PR merged between plan authoring and
implementation moved it.
