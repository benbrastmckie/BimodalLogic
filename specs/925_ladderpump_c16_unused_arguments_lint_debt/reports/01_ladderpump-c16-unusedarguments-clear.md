# Research Report: Task #925

**Task**: 925 - Clear the C16 env_linter unusedArguments lint debt in RaySummary/LadderPump.lean
**Started**: 2026-11-11T00:00:00Z
**Completed**: 2026-11-11T00:00:00Z
**Effort**: 0.6 hours
**Dependencies**: None live on `LadderPump.lean`; see Territory below for two soft overlaps
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` (the two reported declarations)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` (the only consumer)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (in-module exemption template)
- `.lake/packages/batteries/scripts/runLinter.lean`, `Batteries/Tactic/Lint/{Frontend,Basic}.lean`
- `scripts/check-module-invariants.sh` (C16, C26), `scripts/nolint-attribute-allowlist.txt`, `scripts/nolints.json`
- `specs/archive/889_ladderchain_c16_unusedarguments_clear/` (cited precedent), `specs/911_idle_cycle_sharpening_idle_gap_lengthening/plans/01_idle-cycle-sharpening.md` (the Challenge pin)
- Live gate runs: `lake exe runLinter FormalSystem`, `check-module-invariants.sh --no-build`, `typst-sync-check.sh`
**Artifacts**: - `specs/925_ladderpump_c16_unused_arguments_lint_debt/reports/01_ladderpump-c16-unusedarguments-clear.md`
**Standards**: report-format.md, subagent-return.md, anti-analysis.md, reference-grounding.md, adversarial-verification.md

## Executive Summary

- **The starting position is confirmed exactly, by a live run, not by inheritance.**
  `lake exe runLinter FormalSystem` exits 1 with `-- Found 2 errors in 18885 declarations`:
  `exists_idleSpliced_ladderPath` (args 2 and 3, `[Fintype Q]` and `[Nonempty Q]`) at
  `LadderPump.lean:1825`, and `exists_idleTypeBlock_of_budget_le_run` (arg 12,
  `hg : IsLadderPath step pend g`) at `:1868`. Three dead binders across two declarations.
  Every other gate surface is green: `check-module-invariants.sh --no-build` exits 0
  (`ALL CHECKS PASSED`), `typst-sync-check.sh` passes all four checks, and `LadderPump.lean` is
  1,931 lines, matching its README inventory row exactly. There is no pre-existing drift to
  disentangle from this task's own edits.

- **The mechanism the dispatch cites as precedent has been superseded, and the newer one is
  in-module.** The archived `ladderchain_c16_unusedarguments_clear` record appended a
  `scripts/nolints.json` row on 2026-11-06 and recorded a reason for rejecting the in-source
  attribute ("splits one linter's exemption inventory across two mechanisms"). Three days later,
  commit `a0e46af49` added a note to C16's own failure output: *"prefer the non-destructive fix
  instead: an in-source `@[nolint unusedArguments]` (or the relevant linter name) attribute plus
  a matching entry in `scripts/nolint-attribute-allowlist.txt`"*. On 2026-11-10 three separate
  records paired attribute-plus-allowlist exemptions — one of them
  `unusedArguments:insRegionStart_trichotomy` in `RaySummary/LadderAgree.lean`, the same module
  as this task's target, with a verified working comment/`set_option`/attribute template at
  `LadderAgree.lean:2014-2047`. **Recommendation: use the attribute + allowlist route, not a
  `nolints.json` row.**

- **The two declarations need DIFFERENT dispositions, and only one of them is honestly an
  exemption.** `exists_idleTypeBlock_of_budget_le_run`'s `hg` cannot be removed: removal
  relocates the finding instead of clearing it. `exists_idleSpliced_ladderPath`'s two instance
  binders can be removed outright, and the allowlist's own ADMISSION BAR argues they should be.

- **Recommended disposition (two edits in `LadderPump.lean`, one in `scripts/`)**:
  1. `exists_idleSpliced_ladderPath` — **remove** `[Fintype Q]` and `[Nonempty Q]`, and drop the
     now-pointless `set_option linter.unusedFintypeInType false in`. Verified: the declaration has
     **zero term-level consumers** (only docstring mentions), and its entire body —
     `exists_ladderPath_of_walk_of_pins` plus five `section Inputs` helpers — lives under
     `variable {Q : Type} {step} {pend}` blocks with **no finiteness or nonemptiness instance at
     all** (`LadderAgree.lean` `section Path`, `LadderPump.lean` `section Inputs`). Dropping two
     instance-implicit binders is a *generalization*, so no call site could break even if one
     existed. Re-pin the generalized signature in this task's own `## Lean Challenge Statements`.
  2. `exists_idleTypeBlock_of_budget_le_run` — **exempt** via `@[nolint unusedArguments]` plus
     `unusedArguments:exists_idleTypeBlock_of_budget_le_run` in
     `scripts/nolint-attribute-allowlist.txt`, keeping the existing
     `set_option linter.unusedVariables false in` as the paired source-level suppression.
  3. **Target a net line delta of ZERO on `LadderPump.lean`** (it stays at 1,931 lines), by
     sizing the two reason comments to absorb the `-1` from the dropped `set_option` and the
     `+1` from the added attribute. This is not cosmetic — see Territory.

- **Territory is the binding constraint on how, not whether.** Any *net* line-count change to
  `LadderPump.lean` fans out to `typst/generated/status.typ` and to three README inventory
  blocks, and **all of those plus the root `README.md` are in concurrent task 918's declared
  `file_scope` for this same cycle**. A net-zero delta avoids every one of them. `scripts/` is
  not line-counted by `status.typ` (only `FormalSystem/`, `Tests/`, `BimodalTools/` are), so the
  long-form reason belongs in the allowlist entry, where length is free.

## Context & Scope

The question researched: how to make C16's `env_linter` group reach exit 0 with no
`unusedArguments` finding in `LadderPump.lean`, without editing any file a concurrent sibling
owns and without weakening a statement.

What was deliberately NOT researched: the one genuine `:= trivial` in
`FormalSystem/Examples/TemporalStructures.lean:495`, excluded by the dispatch. Worth recording
that it is excluded on correct grounds twice over — it is a *vacuous-pattern census* item, and
C16 never sees it at all, so it could not affect this gate's exit code regardless.

Evidence tier: lean-lsp was registered and reachable per the dispatch probe, but every load-bearing
claim below rests on **compiled evidence or source text**, not on an LSP index lookup — the
linter's own output, the Batteries linter driver source, `variable`-block text, and `grep` sweeps
over the whole `FormalSystem/` and `Tests/` trees. No claim rests on an empty `lean_local_search`
result, so the index-state interpretation rule does not bite.

## Findings

### The live finding, verbatim

```
-- Found 2 errors in 18885 declarations (plus 28791 automatically generated ones) in FormalSystem with 14 linters

/- The `unusedArguments` linter reports:
UNUSED ARGUMENTS.
This linter can be disabled with `@[nolint unusedArguments]`. -/
-- FormalSystem.Metalogic.Decidability.RaySummary.LadderPump
.../LadderPump.lean:1825:1: error: @FormalSystem...exists_idleSpliced_ladderPath 2 unused arguments:
  argument 2: [Fintype Q]
  argument 3: [Nonempty Q]
.../LadderPump.lean:1868:1: error: @FormalSystem...exists_idleTypeBlock_of_budget_le_run 1 unused argument:
  argument 12: (hg : FormalSystem...IsLadderPath step pend g)
```

### Why the already-present `set_option` lines do not help

Both declarations *already* carry a scoped suppression with a stated reason —
`set_option linter.unusedFintypeInType false in` at `LadderPump.lean:1823` and
`set_option linter.unusedVariables false in` at `:1867`. Neither can reach this finding, and the
reason is structural, not a misconfiguration: `unusedArguments` is a Batteries
`@[env_linter]`, which runs post-hoc over an **imported environment**, never during elaboration.
`scripts/runLinter.lean` imports the module (`importModules #[module, lintModule]`) and then runs
`lintCore`; no `set_option linter.*` in the source is in scope at that point. Only two things
reach it: the `nolint` attribute (via `shouldBeLinted`, `Frontend.lean:135`:
`decls.filterM (shouldBeLinted linter.name)`) and `scripts/nolints.json` (via
`runLinter.lean:169-170`: `nolints.foldl ... decls.erase decl'`).

This is precisely the gap the archived precedent record identified — its own comment named only
the frontend linter, "which is precisely the gap that let the environment-linter finding reach
the gate."

### The ledger filter is per-declaration, not per-argument

`runLinter.lean:169-170` erases the whole declaration from the linter's result set, so **one**
row or **one** attribute clears all of `exists_idleSpliced_ladderPath`'s two unused arguments.
The linter name must be the exact `linter.name`, `unusedArguments`, which is what all 228
existing rows use.

### Source-to-implementation mapping (H3 Tier 3, implementation-backed)

| Source | Location | Lean identifier / artifact | Signature or exact text | Status |
|--------|----------|----------------------------|-------------------------|--------|
| C16 failure note | `scripts/check-module-invariants.sh:3641` | — | "prefer the non-destructive fix instead: an in-source `@[nolint unusedArguments]` ... plus a matching entry in `scripts/nolint-attribute-allowlist.txt`" | VERIFIED (read in source; `git log -S` dates it to `a0e46af49`, 2026-11-09) |
| In-module exemption template | `RaySummary/LadderAgree.lean:2014-2047` | `insRegionStart_trichotomy` | 8-line reason comment → `set_option linter.unusedVariables false in` → docstring → `@[nolint unusedArguments]` → `theorem` | VERIFIED (compiles today; C16 green on it) |
| Allowlist pairing | `scripts/nolint-attribute-allowlist.txt` | `unusedArguments:insRegionStart_trichotomy` | `<linter>:<declaration-as-written>` | VERIFIED (C26 half two keys on `f"{lint}:{nm}"`, bare name as written) |
| Ledger precedent, pending twin | `scripts/nolints.json:900` | `FormalSystem...exists_typeBlock_of_budget_le_cnt` | `["unusedArguments", "<fqn>"]` | VERIFIED (the pending-side mirror of this task's idle lemma is already exempted) |
| Cited task precedent | `specs/archive/889_.../summaries/01_...-summary.md` | `mem_cellAt_of_shift_of_hasForwardSlack` | `scripts/nolints.json` row, 227→228 | VERIFIED but SUPERSEDED as to mechanism (2026-11-06, predates the gate note) |
| Challenge pin | `specs/911_.../plans/01_idle-cycle-sharpening.md:767,780` | both target declarations | both signatures written verbatim incl. `[Fintype Q] [Nonempty Q]` and `hg` | VERIFIED (pin exists; drift check is ADVISORY per `plan-compliance.md`) |
| Linter driver | `.lake/packages/batteries/scripts/runLinter.lean:133-170` | `NoLints := Array (Name × Name)` | `nolints.foldl ... decls.erase decl'` | VERIFIED (read in source) |
| Attribute filter | `Batteries/Tactic/Lint/{Frontend.lean:135,Basic.lean:190}` | `shouldBeLinted` | `decls.filterM (shouldBeLinted linter.name)` | VERIFIED (read in source) |

### Per-declaration analysis

**`exists_idleSpliced_ladderPath` — the binders are removable, and the allowlist's bar says remove them.**

- Consumers: **none at term level.** A `grep` over all of `FormalSystem/` and `Tests/` returns
  only three docstring mentions (`LadderWindow.lean:181,425`, `LadderIdle.lean:19,75`) and the
  declaration itself.
- Body requirements: the proof is one application of `exists_ladderPath_of_walk_of_pins`
  (`LadderAgree.lean:1322`, under `section Path`'s `variable {Q : Type} {step} {pend}` — **no
  finiteness instance**) to five helpers declared in `LadderPump.lean`'s `section Inputs`
  (`variable {Q : Type} {step} {pend} {g}` — again no instance). Nothing in the term can mention
  `Fintype Q` or `Nonempty Q`, which is independently why the linter reports them.
- Direction of change: removing instance-implicit binders **generalizes** the theorem. Even a
  future call site added by a concurrent sibling resolves unaffected, because instance arguments
  are supplied by synthesis, not positionally.
- Against the ADMISSION BAR: the four existing `unusedArguments` allowlist entries are all
  justified by "this is the published signature the interface above resolves against" / "dropping
  the argument would change a contract signature to spare a linter." With zero consumers, that
  justification is **factually unavailable** here. The bar's own instruction for that case is
  explicit: *"If the exemption is temporary, fix the declaration instead."*
- Residual cost of removal, stated plainly: it breaks the "uniform instance shape" the existing
  comment cites, and it is signature drift against the recorded Challenge pin. `exists_iterIdleSpliced_ladderPath`
  (`LadderIdle.lean:108`) keeps `[Fintype Q] [Nonempty Q]` and genuinely consumes them, so the
  layer's shape is not uniform in the first place — the unanchored lift would simply be the more
  general of the two. The drift is a *generalization*, not the weakening `plan-compliance.md`'s
  Statement Fidelity section targets, and re-pinning in this task's own Challenge Statements
  section is the sanctioned way to make the new signature the contract.

**`exists_idleTypeBlock_of_budget_le_run` — removal relocates the finding; exemption is honest.**

- `hg` is consumed exactly once, by the layer directly above:
  `exists_idleBlock_of_hasIdleRunBelow` (`LadderWindow.lean:430`) takes its own
  `hg : IsLadderPath step pend g` and passes it **positionally** at `:443`
  (`exists_idleTypeBlock_of_budget_le_run step pend fwd bwd lab φ σ hg ...`). That pass-through is
  the only reason that declaration's own `hg` is live and unreported.
- Therefore dropping `hg` here makes `exists_idleBlock_of_hasIdleRunBelow`'s `hg` dead and
  creates a **new** `unusedArguments` finding in `LadderWindow.lean` — which is in task 918's
  declared `file_scope` this cycle. The finding would be relocated into a file this record may
  not edit, and the gate would still be red. (`exists_idleBlock_of_hasIdleRunBelow` has no
  consumers of its own yet and no allowlist or ledger entry, so nothing absorbs it.)
- This is the same failure mode the archived precedent recorded for its own declaration: "the
  finding is relocated, not resolved."
- The admissible reason therefore nearly transcribes the `insRegionStart_trichotomy` entry: the
  hypothesis is the one the layer built directly on top of it consumes, the two are stated over a
  shared hypothesis list so neither re-derives it, and the idle mirror hypothesizes the run's
  idleness directly (`hrun`) where the pending form reads it off `cntAt_sub_of_pend` and so needs
  the path condition. The pending twin `exists_typeBlock_of_budget_le_cnt` is already exempted at
  `nolints.json:900`, so exempting the idle mirror keeps the pair symmetric.

### Baseline, measured (so the implementation can attribute its own drift)

| Surface | Measured now | Command |
|---------|--------------|---------|
| `runLinter FormalSystem` | exit 1, 2 findings, both in `LadderPump.lean` | `lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem` |
| `check-module-invariants.sh --no-build` | exit 0, `ALL CHECKS PASSED` | as written |
| `typst-sync-check.sh` | `PASS (all 4 checks green)`, `MISMATCH_COUNT=0` | as written |
| `LadderPump.lean` length | 1,931 lines | `wc -l` |
| README inventory row | `| LadderPump.lean | 1,931 |` (`RaySummary/README.md:44`) | `grep` |
| `formalsystem-line-count` | 403364, live-matching | `status.typ:33` + Check 2 |
| `nolints.json` | 914 lines, 228 `unusedArguments` rows, 10 `RaySummary` rows, **zero** rows for either target | `grep -c` |
| allowlist | 4 `unusedArguments:` entries, none for either target | `cat` |

### Territory

- `LadderPump.lean`: **no live holder but this task.** A `file_scope` sweep of every non-terminal
  record in `state.json` returns only 925 itself.
- `scripts/nolint-attribute-allowlist.txt`: **no live holder.** (Relevant: it is the recommended
  edit target.)
- `scripts/nolints.json`: held by record 761, status `hold`. Not resumable by any ordinary
  command, so not in flight — but a second reason to prefer the allowlist over the ledger.
- **The cascade surfaces are hot.** Task 918 is `implementing` this cycle with
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`,
  `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` and
  `typst/generated/status.typ` all in its declared `file_scope`. Those are exactly the five
  surfaces a net line-count change to `LadderPump.lean` forces (the archived precedent record
  planned two files and closed six for this reason). A net-zero line delta is what keeps this
  task to the two files it should touch.
- Task 924 is `researching` on `LadderChain.lean`/`LadderCell.lean` — no overlap.

### Recommendations

1. Edit `LadderPump.lean` at `1818-1830`: delete the 5-line `linter.unusedFintypeInType` comment
   and the `set_option linter.unusedFintypeInType false in` line; change the signature's first
   line to `theorem exists_idleSpliced_ladderPath {Q : Type}`; write a replacement reason comment
   recording that the two instance binders were dropped because the body consumes no finiteness
   (`exists_ladderPath_of_walk_of_pins` and the `section Inputs` helpers take none) and the
   declaration has no call sites, so the removal generalizes rather than weakens.
2. Edit `LadderPump.lean` at `1862-1873`: keep `set_option linter.unusedVariables false in`,
   extend the reason comment to name the environment linter and its separate remedy, and insert
   `@[nolint unusedArguments]` on its own line immediately before `theorem` (after the docstring),
   exactly as `LadderAgree.lean:2046` does.
3. Append one entry to `scripts/nolint-attribute-allowlist.txt`:
   `unusedArguments:exists_idleTypeBlock_of_budget_le_run`, preceded by a `#` comment block
   carrying the full admission-bar reason (pass-through consumption at `LadderWindow.lean:443`;
   the relocation hazard; the shared hypothesis list; the pinned Challenge statement; and that the
   paired source-level suppression is the scoped `set_option` at the same site). Length is free
   here — `scripts/` is not line-counted.
4. **Size the two comments so the file's total stays 1,931.** The arithmetic: `-5` (deleted
   comment) `-1` (deleted `set_option`) `+1` (added attribute) means the two replacement comments
   must together be 5 lines longer than the single 5-line comment they replace — i.e. the
   `exists_idleSpliced_ladderPath` comment lands at 5 lines and the
   `exists_idleTypeBlock_of_budget_le_run` comment grows 5 → 6. Verify with `wc -l` before
   staging, and re-run `typst-sync-check.sh` to confirm no cascade.
5. `lake exe runLinter --update` **must not be run**, for the reason the gate itself records: it
   rewrites `nolints.json` wholesale from current findings for the named roots only, observed to
   drop 914 lines to 237, grandfathering any genuine regression along the way.
6. Verify with a guarded `lake exe runLinter FormalSystem` (expect
   `-- Linting passed for FormalSystem.`; note that `Found 0 errors` can never appear, since that
   line is printed only on a failing run) and then a full `check-module-invariants.sh` for
   `PASS C16` and exit 0. A scoped `lake build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`
   must come first, since recommendation 1 changes a signature.

**A sorry-free, axiom-neutral path exists.** No proof term changes under recommendation 2, and
recommendation 1 changes only a binder list, so no axiom profile can move. No `sorry`, no new
axiom, no vacuous placeholder is involved anywhere in this task.

## Decisions

- **Attribute + allowlist, not a `nolints.json` row.** Decided on the dated evidence above, not on
  preference: the ledger route's rationale predates the gate note and the three 2026-11-10
  pairings, one of which is in this very module. Recorded as a correction to the dispatch's
  framing of the archived record — it remains precedent for the *analysis* (routes enumerated, the
  relocation test, the generated-surface cascade) but not for the *mechanism*.
- **Asymmetric disposition, on the merits of each declaration.** Removing both dead binder sets
  would be the strongest outcome if it worked; it does not, because one removal relocates the
  finding into a sibling-owned file. Exempting both would be the safest; it is not honest, because
  the allowlist's admission bar is not met for a declaration with zero consumers and a body that
  needs no instance. The split follows the evidence rather than a uniform policy.
- **Net-zero line delta is a hard constraint of the recommendation, not a nicety.** It is the one
  thing that keeps this task from editing five files a concurrently-implementing sibling owns.
- **The 911 Challenge pin is re-pinned, not ignored.** The generalized
  `exists_idleSpliced_ladderPath` signature should appear in this task's own
  `## Lean Challenge Statements` section, which is how a new signature becomes the contract. A
  `lean-challenge-snapshot.sh --check` drift finding against the older pin is advisory by rule
  and is the expected, correct output of a deliberate generalization.

## Adversarial Self-Verification

Every load-bearing claim was re-tested against a documented reason it might fail. Three claims
changed as a result (noted below the table).

| Claim | Source / counterexample tested | Verification method | Confidence |
|-------|-------------------------------|---------------------|------------|
| C16 fails on exactly 2 findings, 3 binders, both in `LadderPump.lean` | Could the dispatch's inherited claim be stale? | Live guarded `lake exe runLinter FormalSystem`; exit 1; output quoted verbatim above | High |
| The existing `set_option` lines cannot suppress this finding | Could the gate be misconfigured rather than the mechanism structural? | Read `runLinter.lean:133-170` and `Frontend.lean:135` — the linter runs over an imported environment, after elaboration | High |
| One attribute/row clears both of `exists_idleSpliced_ladderPath`'s unused args | Could the filter be per-argument? | `runLinter.lean:169-170` `decls.erase decl'`; `Frontend.lean:135` `filterM (shouldBeLinted linter.name)` — both per-declaration | High |
| `exists_idleSpliced_ladderPath` has no term-level consumers | A positional call could exist in `Tests/` or a tools root | `grep -rn` over `FormalSystem/` and `Tests/`: three docstring mentions, zero applications | High |
| Its body needs no `Fintype`/`Nonempty` | The instance could be consumed via a `Finite Q` derivation, which would make the binder live | `exists_ladderPath_of_walk_of_pins` sits under `section Path`'s `variable {Q : Type} {step} {pend}` (no instance); `section Inputs` likewise. Corroborated by the linter's own verdict | High — but the plan must still compile-check it; a signature change is the only edit here that can fail to elaborate |
| Removing `hg` relocates the finding into `LadderWindow.lean` | `exists_idleBlock_of_hasIdleRunBelow` might read `hg` for something else, or be exempted already | Read `LadderWindow.lean:430-450`: `hg` appears exactly once, as the 8th positional argument to the pigeonhole at `:443`; `grep` confirms no allowlist or `nolints.json` entry for it, and no consumers of its own | High |
| The attribute + allowlist route is the current repo practice | The archived precedent explicitly rejected the attribute — is the newer evidence real or a misread? | `git log -S` on three strings: `a0e46af49` (2026-11-09) added the gate note; `7ee06354b`/`059e1fdfa`/`54715cb01` (2026-11-10) added attribute pairings; the ledger row is `116c6c2af` (2026-11-06) | High |
| The gate note *ranks* the attribute above a hand-appended ledger row | Read in sequence, the note's "instead" may contrast only with `--update` | Re-read `check-module-invariants.sh:3638-3643` in order | **Medium — claim weakened.** The note's direct contrast is with `--update`. The ranking rests on the three 2026-11-10 pairings and the C26 allowlist's existence, not on the note's wording alone |
| `LadderPump.lean` has no live territory holder | A `file_scope` entry could be a directory or glob covering it | `jq` sweep of every non-terminal record; only 925 matches; 918's entries are file-granular and name `LadderWindow`/`LadderModel`, not `LadderPump` | High |
| A net line change cascades to five sibling-owned files | The README might count something other than total lines | `RaySummary/README.md:44` reads `1,931`; `wc -l` reads 1931; `status.typ:33` live-matches under Check 2 | High |
| `scripts/` edits are not line-counted | The allowlist might feed an inventory | `typst-sync-check.sh:193-214` counts only `formalsystem`/`tests`/`tools`; `--no-build` INV pass is green with the allowlist already present | High |
| No pre-existing drift to disentangle | A sibling may have already moved a generated surface | `check-module-invariants.sh --no-build` exit 0 and `typst-sync-check.sh` all-green, both run this phase | High — but build-gated groups (C1/C2/C6/C24/C25/C36b) were NOT run, so "only C16 fails" is asserted for the `--no-build` set plus C16, not for the full gate |

**Recommendations modified after verification:**

1. The disposition for `exists_idleSpliced_ladderPath` **changed from exemption to removal.** The
   first pass carried the archived precedent's reasoning forward and recommended a ledger row for
   both declarations. Re-reading the allowlist's ADMISSION BAR against the measured facts — zero
   consumers, no instance required anywhere in the body — showed the bar is not met, and the bar's
   own instruction for that case is to fix the declaration. H2's forbidden conclusion "a different
   approach is needed" would have been reached here without the consumer sweep and the
   `variable`-block check; both were run.
2. The claim that the gate note ranks attribute above ledger was **weakened from High to Medium**
   and its support moved to the dated pairings. The note's "instead" contrasts with `--update`.
3. The scope of "only C16 fails" was **bounded** to the `--no-build` check set plus C16, since the
   build-gated groups were not run in this phase.

**Contradiction Log.** One contradiction was found and resolved.

- **A** (archived `ladderchain_c16_unusedarguments_clear` summary, 2026-11-06): an in-source
  `@[nolint unusedArguments]` "splits one linter's exemption inventory across two mechanisms, so
  the 228-row ledger stays the single place to look."
- **B** (`scripts/nolint-attribute-allowlist.txt`, `scripts/check-module-invariants.sh:3641`, and
  three records dated 2026-11-10): the in-source attribute paired with an allowlist entry is the
  reviewed, C26-asserted mechanism, and the gate's own output names it.
- **Resolution, by precedence ranking: B wins on recency and on mechanical authority.** A's
  premise was already false when written — the repo carried seven `@[nolint]` attributes across
  six files, and C26 half two has asserted them against the allowlist since 2026-09-08
  (`d8b1f8b88`). A also understates a real hazard B avoids: a `nolints.json` row is destroyed by
  any `--update` run, which the gate documents as rewriting 914 lines to 237, whereas an
  attribute is immune. A's "single place to look" goal is met in the current design by the
  allowlist, which exists precisely to turn an in-source suppression back into a reviewable line.
  No unresolved contradiction remains.

## Tactic Survey Results

No tactic survey was conducted, and none is applicable: this task changes no proof term. The
recommended edits are a binder-list removal, an attribute, two comments, and one allowlist line.
The single elaboration risk — whether `exists_idleSpliced_ladderPath` still compiles without
`[Fintype Q]`/`[Nonempty Q]` — is a scoped-build question, not a tactic question, and is assigned
to the plan as a compile check rather than guessed at here.

## Context Extension Recommendations

- **Topic**: Choosing between the three `unusedArguments` suppression mechanisms in this repo.
- **Gap**: The decision procedure is currently reconstructible only by git-dating
  `scripts/nolint-attribute-allowlist.txt` against an archived task summary. A reader starting
  from the archived precedent — which is what the matcher surfaces — gets the superseded answer,
  and the cost is a landed exemption in the wrong mechanism.
- **Recommendation**: add `context/project/lean4/patterns/nolint-mechanism-selection.md` recording
  the three mechanisms (frontend `set_option`, Batteries env-linter attribute + C26 allowlist,
  `nolints.json` ledger), which linter each can and cannot reach and why, the ADMISSION BAR's
  "fix the declaration instead" branch, the relocation test to run before removing a binder, and
  the `--update` prohibition. Cross-reference it from the C16 block's header.
- **Topic**: The generated-surface cascade of any net `.lean` line-count change.
- **Gap**: The archived precedent recorded this as a follow-up ("a net line-count change to any
  `.lean` file is never a one-file commit in this repository") and the follow-up was never
  promoted into context, so this task had to rediscover it — and it is load-bearing here, because
  the cascade targets are a concurrent sibling's territory.
- **Recommendation**: record the five surfaces, their generators
  (`typst-sync-check.sh --fix`, `check-module-invariants.sh --emit-inventory`), and the net-zero
  avoidance technique in the Lean operations context.

## Appendix

### Commands run

```
lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem   # exit 1, 2 findings
bash scripts/check-module-invariants.sh --no-build                      # exit 0, ALL CHECKS PASSED
bash scripts/typst-sync-check.sh                                        # exit 0, all 4 checks green
wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean    # 1931
grep -rn exists_idleSpliced_ladderPath --include=*.lean FormalSystem/ Tests/
grep -rn exists_idleBlock_of_hasIdleRunBelow --include=*.lean FormalSystem/ Tests/
grep -rn '@\[nolint' --include=*.lean FormalSystem/ Tests/ BimodalTools/   # 7 hits, 6 files
git log -S'prefer the non-destructive fix instead' -- scripts/check-module-invariants.sh
git log --date=short -- scripts/nolint-attribute-allowlist.txt
jq over specs/state.json for file_scope overlap on LadderPump.lean / nolints.json / allowlist
```

### References

- `scripts/check-module-invariants.sh` — C16 (lines 3536-3646) and C26 half two (lines 5151-5230)
- `scripts/nolint-attribute-allowlist.txt` — the ADMISSION BAR and four `unusedArguments` precedents
- `.lake/packages/batteries/scripts/runLinter.lean:133-180`;
  `Batteries/Tactic/Lint/Frontend.lean:135`; `Batteries/Tactic/Lint/Basic.lean:168-191`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean:2014-2047` — the working template
- `specs/archive/889_ladderchain_c16_unusedarguments_clear/` — precedent for the analysis
- `specs/911_idle_cycle_sharpening_idle_gap_lengthening/plans/01_idle-cycle-sharpening.md:708-800`
  — the `## Lean Challenge Statements` pin
- `docs/development/NAMING_CONVENTION_DEVIATION.md` — why `unusedArguments` is the one
  permanently-grandfathered category (cited by the allowlist header)
