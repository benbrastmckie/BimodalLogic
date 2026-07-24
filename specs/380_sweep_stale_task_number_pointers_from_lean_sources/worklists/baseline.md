# Gate Baselines (Phase 1, recorded 2026-07-24)

Recorded on the clean working tree at HEAD `2b315b64a` (Theories/ content unchanged since
research baseline `c12eab1d6`; `git status --porcelain Theories` empty). All later phase
gates reconcile against the numbers below.

## Build

- `lake build` → **EXIT 0**, `Build completed successfully (1789 jobs).`

### CORRECTED in Phase 8 — the original "exactly ONE pre-existing warning" figure was wrong

This section originally read: "Exactly ONE pre-existing warning (must remain byte-identical
through the sweep): `Theories/Bimodal/Automation/DatasetGenerator.lean:2174:6: unused variable
'q'`". **That figure is an artifact of measurement, not a property of the tree, and no phase
gate should be reconciled against it.** It was recorded from a *cached* `lake build` in which
only `DatasetGenerator` had been invalidated, so only that module's log was emitted. A build
that replays every module's cached log emits **1,024 warning lines tree-wide — 1,012 non-sorry
(`unused variable`, `This simp argument is unused`, `Try this: intro …`) across 81 files, plus 12
`declaration uses 'sorry'`**. Every one is pre-existing and unrelated to this sweep. Measured in
Phase 8 on the final tree: `lake build` EXIT 0, 1789 jobs, 0 errors, 1,024 warning lines.

**Use this invariant instead** — it is what Phases 2-8 actually verified, and it is strictly
stronger than any warning-count comparison:

> Every diff hunk in `Theories/**/*.lean` is provably confined to a comment span
> (`rewrite_task_refs.py --check-diff`), and independently, the comment-stripped,
> whitespace-normalized code of all 430 `.lean` files is byte-identical to `c12eab1d6` except
> for the 6 explicitly user-authorized string-literal payloads (`Saturation.lean` ×4,
> `EnumBenchmark.lean` ×2). Warnings are emitted by elaborating declarations; if no declaration,
> proof, tactic, or term changed, **no warning can have been introduced, removed, or altered** —
> regardless of how many warnings the tree emits in total.

Corollary on line numbers: warning *line numbers* legitimately shift where a comment line was
deleted, and such a shift is not a regression. The `DatasetGenerator` `unused variable q` warning
moved `:2174` → `:2173` (message and column `:6:` byte-identical) because one pure-pointer
References bullet was deleted at `:80`. Verified on the final tree:
`Theories/Bimodal/Automation/DatasetGenerator.lean:2173:6: unused variable 'q'`, still the only
warning in that file.

## Sorry census (invariant at every gate)

```bash
grep -rn '\bsorry\b' Theories --include='*.lean' | wc -l                                  # 906
grep -rn '\bsorry\b' Theories --include='*.lean' | grep -vE '^\S+:[0-9]+:\s*--' | wc -l   # 820
grep -rn 'sorryAx' Theories --include='*.lean' | wc -l                                    # 26
```

Reproduced this session: **906 / 820 / 26** — identical to the research report §5.

## Sweep-pattern baseline

```bash
grep -rE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' Theories --include='*.lean' | wc -l   # 1549
grep -rlE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' Theories --include='*.lean' | wc -l  # 192
```

Reproduced this session via `rewrite_task_refs.py --count Theories`: **1,549 lines / 192
files** — identical to the research inventory (report §1). Also cross-checked per-file:
SharedWitness.lean scoped `--count` = 261 (matches report histogram top row).

## Declaration-count baseline (for Phase 8 reconciliation)

```bash
grep -rEc '^\s*(theorem|lemma|def|noncomputable def|instance|structure|inductive)\b' \
  Theories --include='*.lean' -h | awk '{s+=$1} END {print s}'
```

(Phase 8 may alternatively rely on `--check-diff --base c12eab1d6`, which proves
comment-only hunks directly; recorded command kept for the spot-check option.)

**Measured in Phase 8** — both sides of the sweep, computed at `c12eab1d6` via
`git grep -hEc … c12eab1d6` and on the final tree:

| Metric | `c12eab1d6` (pre-sweep) | Final tree | Status |
|---|---|---|---|
| Declaration lines | **7,316** | **7,316** | identical |
| `.lean` files under `Theories/` | 430 | 430 | identical (0 added, 0 deleted) |
| Vacuous-definition count | 1 | 1 | identical (pre-existing `Examples/TemporalStructures.lean:269`) |

## check-diff gate

`rewrite_task_refs.py --check-diff --base HEAD Theories` on the clean tree:
`0 changed .lean file(s), 0 failure(s)`, EXIT 0.

**Final-tree expectation (Phase 8)**: `--check-diff --base c12eab1d6 Theories` reports
`196 changed .lean file(s), 2 failure(s)`, and the two failures are exactly the files carrying
user-authorized non-comment string-literal edits (`Metalogic/Decidability/Saturation.lean`,
`Automation/EnumBenchmark.lean`). This is the correct output. The checker asserts comment-span-only
hunks; those payloads are string literals, so they must fail it. **The checker was never weakened
or edited to make the count look clean.**

## Build-graph coverage of the `lake build` gate (discovered in Phase 8)

`lake build` builds only `@[default_target] lean_lib Bimodal`, whose transitive import closure
from `Theories/Bimodal.lean` is **262 modules of the 430** `.lean` files in the tree. Of the 196
files this sweep changed, the gate therefore elaborates **124**; **12** are reachable only from
`lean_exe` roots (`Automation/{AxiomNames, BenchmarkAnchors, BenchmarkOracle, DatasetExport,
DatasetValidator, EnumBenchmark, FormulaMutator, ProofStepExport, TableauBridge,
TableauProofStepPipeline, TraceExporter}`, `Metalogic/Decidability/TraceExport`) and **60** are
Boneyard modules in no lake target at all. A `lake build` EXIT 0 was therefore never, in any
phase, evidence about those 72 files.

Phase 8 closed the gap two ways rather than leaving the claim overstated:
1. **The 12 live exe-only modules were elaborated directly** with
   `lake env lean <file>` (elaboration only, no native codegen — `lake build enum_benchmark`
   native-compiles the whole import closure and is not a usable gate).
2. **The 60 uncompiled Boneyard modules rest on the code-identity proof**, which is
   lake-independent: their comment-stripped normalized code is byte-identical to `c12eab1d6`.
   This also detects delimiter damage — deleting a `-/` would extend a comment span over real
   code and drop those lines from the normalized form; deleting a `/-` would add prose lines to
   it. Neither occurred anywhere in the tree.
