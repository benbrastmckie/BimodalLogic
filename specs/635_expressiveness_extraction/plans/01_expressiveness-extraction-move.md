# Implementation Plan: Extract the Expressiveness Development out of `WeakCanonical/`

- **Task**: 635 - Extract the 141-file Expressiveness set into `Metalogic/Expressiveness/`
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: task 634 (landed at `d3f912858`)
- **Research Inputs**: `specs/635_expressiveness_extraction/reports/01_expressiveness-extraction-move.md`
- **Artifacts**: plans/01_expressiveness-extraction-move.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Relocate the 141-module / 104,087-line expressiveness development out of
`FormalSystem/Metalogic/WeakCanonical/` into `FormalSystem/Metalogic/Expressiveness/`, renaming
`WeakCanonical.X -> Expressiveness.X` throughout and `WeakCanonical/Expressiveness/` ->
`Expressiveness/GameTransfer/`, so that the two headline results ADR-011 exists to fix
(`Kamp.kampPriorExpressiveCompleteness`, `uSExpressivelyCompleteOverPrior`) stop carrying
`WeakCanonical` in their fully-qualified names. The move lands as one scripted commit that also
re-wires the aggregators, rewrites the two READMEs, restores the two historical statements the
rewrite tool would falsify, re-points the standing pre-move gate, and regenerates
`typst/generated`; a second commit renames the paper-numbered files to content names and deletes
the genuine declaration-free stubs. Done means: the build-inclusive
`check-module-invariants.sh` is green after each commit, `check-metalogic-cycles.sh` reports
exactly 1, and every acceptance assertion in Phase 5 / Phase 7 passes non-degenerately.

### Research Integration

The report is the primary input and four of its findings drive the phase structure directly:

1. **The bare prefix `FormalSystem.Metalogic.WeakCanonical` is declared by 29 moved and 28
   residual files and therefore cannot be a `--namespace-map` row** (a map row is a repo-wide
   prefix rewrite with no file scoping; the moved `uSExpressivelyCompleteOverPrior` and the
   residual `countermodel_discrete` C14 baselines sit two lines apart in
   `scripts/check-module-invariants.sh` and are indistinguishable to a prefix rule). The map
   carries two rows only (`.Kamp`, `.Separation`); the bare-prefix remainder is a separate,
   path-scoped, file-granular step that runs **after** the `git mv`, when the 29 files already
   sit under `Metalogic/Expressiveness/` (Phase 3.2). `--namespace-map` is still passed, because
   `rewrite_text`'s `baseline_re` (class 5, the axiom-baseline sites) is gated on its presence.
2. **`scripts/typst-status-counts.sh` resolves the archived Kamp path relative to
   `FormalSystem/`**, a path that died when the archive moved to the repository root, so
   regenerating `typst/generated` today rewrites a *true* `sorry-total = 4` to `0`. The one-line
   anchoring fix lands in Phase 1, before any regeneration.
3. **Both `measure-refactor-partitions.py --check` and the "residual at 38 files" acceptance
   criterion pass degenerately after the move** (`g.under(WEAK)` finds only the residual, so the
   expressiveness set is empty and the check prints `PASS ... (0 files)` forever). Phase 4 re-points
   the script and adds an explicit empty-set failure branch; Phase 5 asserts *counts*, never exit
   codes alone.
4. **"39 paper-numbered files" is not mechanically reproducible.** A strict re-derivation gives
   14 genuinely paper-numbered names; the plan enumerates them explicitly (Phase 6) and corrects
   the inventory row rather than chasing the 39.

**One research figure is corrected by this plan.** The report concludes "delete 3 stubs, not 4",
excluding only `Kamp/NfMultiAnchorBridge.lean`. Direct inspection shows
`Kamp/EANegationFix.lean` is **also a live sibling re-export aggregator** — 7 imports, a
documented split record, and two importers (`Kamp/NfMultiAnchorBridge.lean:221` and
`Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean:8`). Deleting it would break C8 and both
importers. The genuine deletable stubs are **2**, not 3 or 4, and both need import rewiring
(Phase 6.2).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and `specs/ROADMAP.md` was not consulted. The
task's own programme anchor is Phase 6 of `docs/development/PUBLICATION_REFACTOR.md`, which is
handled in Phase 7.

## Goals & Non-Goals

**Goals**:

- Relocate all 141 expressiveness modules to `FormalSystem/Metalogic/Expressiveness/`, with
  `WeakCanonical/Expressiveness/` becoming `Expressiveness/GameTransfer/`.
- Complete the fully-qualified rename for **every** declaration in the moved set (ADR-011
  Decision §1), including the 29 bare-namespace files.
- Keep `check-metalogic-cycles.sh` at exactly 1 cycle and the build-inclusive
  `check-module-invariants.sh` green after each of the two commits.
- Leave the pre-move gate (`measure-refactor-partitions.py --check`) meaningful rather than
  vacuous, and leave `typst/generated` publishing true figures.
- Accept ADR-011 and record the supersession pointer in ADR-006.
- Rename the paper-numbered modules to content names and delete the genuine declaration-free
  stubs.

**Non-Goals**:

- Fixing the pre-existing red baselines that this task does not touch:
  `readme-lint.sh`'s 21 broken refs and `typst-sync-check.sh` Check 1's 9 `docs/training/PIPELINE.md`
  violations. Both are confirmed pre-existing and unchanged by this work; only Check 2 is fixed here.
- Reopening ADR-006's declined `Completeness/` regroup, or touching the residual
  `BXCanonical <-> WeakCanonical` cycle.
- Splitting, merging or proof-editing any moved module. This is a structural relocation with no
  proof obligations; no `sorry` is introduced or discharged.
- Renaming the 12 "history-suffixed" modules (`AggregateOffDiagK1`, `SubBracket2`, `BoundedFix`,
  …) — see Phase 6's Reasoned Exclusions.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| A prefix `--namespace-map` row corrupts residual declarations | H | M | Never write bare `FormalSystem.Metalogic.WeakCanonical` as a map key. Post-run assert `grep -c 'FormalSystem\.Metalogic\.WeakCanonical\.countermodel_discrete' scripts/check-module-invariants.sh` still reads 1 (Phase 5). |
| `move-modules.py` collapses "from X to Y" prose into "from Y to Y" | H | **H (observed 4x this run)** | Two named sites: `ADR-011:104` (*Today* column) and `ADR-006:40-43` (historical cycle enumeration). Capture both from `HEAD` **before** the tool runs; restore/hand-edit after (Phase 4.3). **Hand-review every non-`.lean` diff hunk** in Phase 5.1 — no exceptions, no sampling. |
| `lake build` green while an exe root is broken | H | M | Exe roots sit outside every build closure. `lake build` alone is **not** an acceptance gate; only the **build-inclusive** `check-module-invariants.sh` (C25) catches a broken root. Run it after each commit (Phases 5.3, 7.3). |
| Regenerated `status.typ` publishes a false `sorry-total = 0` | H | **H if unfixed** | Phase 1 fixes `typst-status-counts.sh` and proves regeneration is a no-op *before* the move exists. Never regenerate before that fix lands. |
| `--check` and "residual at 38" pass degenerately post-move | M | **H if unhandled** | Phase 4.4 re-points `WEAK`/`EXPRESSIVENESS_SET` and adds an empty-set failure branch; Phase 5.2 asserts the printed **counts** (141 / 38) and the `find | wc -l` file counts, never exit 0 alone. |
| Residual `WeakCanonical/README.md` left with ~19 dangling bare-form citations | M | H | `move-modules.py` deliberately never rewrites bare-form citations (its `232 before, 232 after` audit line asserts this). Rewrite that README by hand and author `Expressiveness/README.md` inside commit 1 (Phase 4.2); C5/C12/C13 catch a miss. |
| Added `open` lines shift C20 `file.lean:NNN` citations | M | M | Only 1 such citation points into the moved tree. Insert every added `open` **below** any cited line, and re-run C20 in Phase 5.3. |
| Sibling aggregator deleted as a "stub", breaking C8 | H | M | `Kamp/NfMultiAnchorBridge.lean` **and** `Kamp/EANegationFix.lean` are aggregators, not stubs. Delete exactly 2 files, each with its importers rewired (Phase 6.2), and record the 2 exclusions with evidence. |
| Long cold rebuild stalls the implementing agent | M | **H** | This is a 141-file / ~104,000-line move; a cold rebuild is long. **Run every long command as a foreground blocking Bash call with `timeout: 600000`, re-invoked until it completes.** Do NOT background it, and do NOT wait on it with a monitor or a polling loop — agents that did so in this run were repeatedly never woken and stalled 15-30 minutes. The guarded build resumes from the lake cache, so re-invocation is cheap. |
| Phases 3-5 accumulate a large uncommitted working tree | M | M | Take a durable, non-reverting checkpoint with `bash .claude/scripts/git-snapshot.sh 635 --no-revert` at the start of Phase 3. Declared `Commit Mode: atomic-batch` across Phases 3-5; the single commit is taken at the end of Phase 5. |
| Proposed content names collide with existing siblings | M | M | `Kamp/KPlusFaithful.lean` already exists, so `Lemma53Faithful` must NOT become `KPlusFaithful`. Phase 6.1 requires a collision check against the post-move tree before any rename is executed. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every phase
mutates the same tree that the next one measures.

---

### Phase 1: Pre-move gate and the typst generator anchoring fix [COMPLETED]

**Goal**: Establish and record the green/red baseline, and fix the mis-rooted archive path in
`scripts/typst-status-counts.sh` so that regenerating `typst/generated` later in this task cannot
publish a false zero.

**Tasks**:

- [ ] Run `python3 scripts/measure-refactor-partitions.py --check`. It MUST exit 0 **and** print
      `Expressiveness set (141 files) ... residual WeakCanonical set (38 files)`. Record the exact
      line. If the counts differ from 141/38, STOP and report — the partition has drifted since
      research.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and record that all 36 checks are
      green. This is the fast inner-loop gate for the rest of the task.
- [ ] Record the three pre-existing red baselines verbatim so a later run can be compared against
      them rather than re-litigated: `bash scripts/readme-lint.sh` (expect FAIL, 21 broken refs);
      `bash scripts/typst-sync-check.sh` (expect Check 1 FAIL with 9 `docs/training/PIPELINE.md`
      violations, Check 2 FAIL with `MISMATCH_COUNT=2`).
- [ ] Edit `scripts/typst-status-counts.sh`: the `SORRY_KAMP_BONEYARD` assignment resolves
      `Boneyard/Kamp/KampWeakCanonical` relative to the `cd`-ed `${BIMODAL_DIR}` (`FormalSystem/`),
      where it has not existed since the archive moved to the repository root. Anchor it at
      `${REPO_ROOT}` instead:
      `SORRY_KAMP_BONEYARD=$(strip_and_count_sorries "${REPO_ROOT}/Boneyard/Kamp/KampWeakCanonical")`.
- [x] Re-run `bash scripts/typst-status-counts.sh` and assert
      `git diff --stat -- typst/generated/status.typ` is **empty** — regeneration must now be a
      no-op. In particular `sorry-total` must still read `4` and
      `("WeakCanonical/ (archived, Boneyard/Kamp/)", 4)` must be unchanged.
      *(deviation: altered — the diff is not literally empty: the generator unconditionally
      restamps `stamp-commit`/`stamp-date` (817c10abc/2026-09-20 -> 0c4b2891b/2026-09-21), which
      it does on every run at a new HEAD regardless of content. Every count line is
      byte-identical: `sorry-total = 4` and the archived row `4` both unchanged. The substantive
      no-op assertion holds; the literal-empty form of it was unachievable by construction.)*
- [ ] Re-run `bash scripts/typst-sync-check.sh` and assert Check 2 now reports `MISMATCH_COUNT=0`.
      Check 1's 9 violations are expected to remain (out of scope).
- [ ] Commit this fix on its own: `task 635: anchor archived-sorry path in typst status generator`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the four pre-move figures 141 / 38 / 21 broken refs /
`MISMATCH_COUNT=2`, and that the generator fix is a one-line change producing a no-op
regeneration. Confirm each by running the command named in its bullet and comparing the printed
value; a mismatch is a stop-and-report condition, not something to code around.

**Files to modify**:

- `scripts/typst-status-counts.sh` - anchor the `SORRY_KAMP_BONEYARD` path at `${REPO_ROOT}`.

**Verification**:

- `--check` exits 0 printing 141 and 38.
- `check-module-invariants.sh --no-build` green, 36 checks.
- `git diff --stat -- typst/generated/status.typ` empty after regeneration.
- `typst-sync-check.sh` Check 2 reads `MISMATCH_COUNT=0`.

**Note on the two-commit mandate**: this preparatory commit does not violate it. The mandate is
that *the move* is one scripted commit and *the renames* a second; this fix is an independent
defect with its own verification (`MISMATCH_COUNT` 2 -> 0) that would be unverifiable inside a
141-file diff, and it must land before any regeneration.

---

### Phase 2: Author the move inputs, capture the ADR originals, and dry-run [COMPLETED]

**Goal**: Produce the exact `--module-map` and `--namespace-map` files, preserve the two
historical statements the rewrite will falsify, and confirm via `--dry-run` that the tool's
behaviour at HEAD matches what research measured.

**Tasks**:

- [ ] Write `specs/635_expressiveness_extraction/module-map.txt` with exactly these 13 rows
      (`old -> new`, one per line). `Expressiveness -> Expressiveness.GameTransfer` is the
      directory rename the task description requires:

      ```
      FormalSystem.Metalogic.WeakCanonical.Expressiveness -> FormalSystem.Metalogic.Expressiveness.GameTransfer
      FormalSystem.Metalogic.WeakCanonical.Kamp -> FormalSystem.Metalogic.Expressiveness.Kamp
      FormalSystem.Metalogic.WeakCanonical.EFGames -> FormalSystem.Metalogic.Expressiveness.EFGames
      FormalSystem.Metalogic.WeakCanonical.Separation -> FormalSystem.Metalogic.Expressiveness.Separation
      FormalSystem.Metalogic.WeakCanonical.NormalForm -> FormalSystem.Metalogic.Expressiveness.NormalForm
      FormalSystem.Metalogic.WeakCanonical.MonadicFO -> FormalSystem.Metalogic.Expressiveness.MonadicFO
      FormalSystem.Metalogic.WeakCanonical.StaviConnectives -> FormalSystem.Metalogic.Expressiveness.StaviConnectives
      FormalSystem.Metalogic.WeakCanonical.PriorDefs -> FormalSystem.Metalogic.Expressiveness.PriorDefs
      FormalSystem.Metalogic.WeakCanonical.PriorDefsDense -> FormalSystem.Metalogic.Expressiveness.PriorDefsDense
      FormalSystem.Metalogic.WeakCanonical.PriorExpressiveness -> FormalSystem.Metalogic.Expressiveness.PriorExpressiveness
      FormalSystem.Metalogic.WeakCanonical.PriorExpressivenessDense -> FormalSystem.Metalogic.Expressiveness.PriorExpressivenessDense
      FormalSystem.Metalogic.WeakCanonical.Table -> FormalSystem.Metalogic.Expressiveness.Table
      FormalSystem.Metalogic.WeakCanonical.EFGameTactics -> FormalSystem.Metalogic.Expressiveness.EFGameTactics
      ```

- [ ] Write `specs/635_expressiveness_extraction/namespace-map.txt` with exactly **two** rows:

      ```
      FormalSystem.Metalogic.WeakCanonical.Kamp -> FormalSystem.Metalogic.Expressiveness.Kamp
      FormalSystem.Metalogic.WeakCanonical.Separation -> FormalSystem.Metalogic.Expressiveness.Separation
      ```

      **MUST NOT** add a bare `FormalSystem.Metalogic.WeakCanonical` row. It is declared by 28
      residual files and a prefix rewrite would silently corrupt them.
- [ ] Capture the two prose sites the rewrite will falsify, into the session scratchpad:
      `git show HEAD:docs/architecture/ADR-011-Extract-Expressiveness.md` and
      `git show HEAD:docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`. Note the exact
      current text of ADR-011's *Today* column row and ADR-006's `BXCanonical → WeakCanonical
      (9 import lines)` block.
- [ ] Run `python3 scripts/move-modules.py --module-map specs/635_expressiveness_extraction/module-map.txt --namespace-map specs/635_expressiveness_extraction/namespace-map.txt --dry-run`
      and record all seven class lines plus the audit line. Research measured: class 1 = 369 in
      149 files, class 2 = 638 in 215 files, class 3 = 149 in 27 files, class 4 = 0, class 5 = 2
      in 2 files, class 6 = 13 paths, class 7 = 6 re-based, audit `232 before, 232 after`,
      282 files changed. Small drift is acceptable; a change in **class 6 (13 paths)** or a
      non-zero class-4 count is not — investigate before proceeding.
- [ ] Confirm class 5 reads **2**, not 3. The third WeakCanonical axiom baseline
      (`uSExpressivelyCompleteOverPrior`) is the bare-namespace gap and is handled by hand in
      Phase 3.3.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the module map is asserted to be exactly 13 rows and the namespace map
exactly 2. Confirm by `wc -l` on each file and by matching the dry run's `class 6 tree moves`
line, which must read `13 path(s)`.

**Files to modify**:

- `specs/635_expressiveness_extraction/module-map.txt` - new, 13 rows.
- `specs/635_expressiveness_extraction/namespace-map.txt` - new, 2 rows.

**Verification**:

- Both map files exist with the stated row counts; neither contains a bare
  `FormalSystem.Metalogic.WeakCanonical` key.
- `--dry-run` completes, writes nothing (`git status --porcelain` unchanged), and its class 6
  line reads `13 path(s)`.

---

### Phase 3: Execute the scripted move and complete the bare-namespace rename [COMPLETED]

**Goal**: Run the move, then finish the fully-qualified rename for the 29 moved files that declare
the bare `FormalSystem.Metalogic.WeakCanonical` namespace — the part no map row can do safely.

**Tasks**:

- [ ] Take a durable, non-reverting checkpoint: `bash .claude/scripts/git-snapshot.sh 635 --no-revert`.
      This is a defensive checkpoint before a large batch, **not** a rollback; do not use the
      default reverting form here.
- [ ] **3.1 Run the move.**
      `python3 scripts/move-modules.py --module-map specs/635_expressiveness_extraction/module-map.txt --namespace-map specs/635_expressiveness_extraction/namespace-map.txt --no-verify`.
      Pass `--no-verify`: the closing harness run is deliberately taken later, in Phase 5.3, once
      the aggregators and READMEs are wired — running it here would fail for reasons this phase is
      not yet responsible for. Run it as a foreground blocking call (`timeout: 600000`).
- [ ] **3.2 Bare-namespace rename inside the moved tree (path-scoped).** Every edit below is
      restricted to `FormalSystem/Metalogic/Expressiveness/`, which after 3.1 contains only moved
      files, so the residual set is unreachable by construction:
      - 29 `namespace FormalSystem.Metalogic.WeakCanonical` lines -> `...Expressiveness`.
      - 29 matching `end FormalSystem.Metalogic.WeakCanonical` lines -> `...Expressiveness`
        (29/29 paired, verified; a residual mismatch after the edit is a defect).
      - 104 `open FormalSystem.Metalogic.WeakCanonical` lines in 104 files -> `...Expressiveness`.
        Safe because `--check` guarantees no moved file imports a residual module, so a bare
        in-tree `open` can only ever resolve to declarations that moved together.
      - The 4 `_root_.FormalSystem.Metalogic.WeakCanonical.<Decl>` declaration headers inside the
        moved tree (e.g. `MonadicFormula.rename`, `.size`, `.subst0` in `Kamp/Prop43Translate.lean`)
        -> `_root_.FormalSystem.Metalogic.Expressiveness.<Decl>`.
      - Enumerate the remaining in-tree dotted mentions with
        `grep -rn 'FormalSystem\.Metalogic\.WeakCanonical\b' FormalSystem/Metalogic/Expressiveness/ | grep -vE ':[0-9]+:(import|open|namespace|end) '`
        (8 total at HEAD, the 4 `_root_` headers among them) and hand-review each one. A mention
        that legitimately names the *residual* development is kept; a self-reference is rewritten.
- [ ] **3.3 Bare-namespace fixups outside the moved tree.** These files import from **both** sides,
      so their existing bare `open` MUST be kept and a new one **added** alongside:
      - 5 `open FormalSystem.Metalogic.WeakCanonical` lines in 5 residual `WeakCanonical/` files:
        add `open FormalSystem.Metalogic.Expressiveness` beside each.
      - 5 lines in 2 files outside both trees (`BXCanonical/CompletenessDedekind.lean` x4,
        `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` x1): same treatment.
        *(deviation: altered — the real site count is **18 open lines across 15 files**, not 10
        across 7. The plan's anchored grep `^open FormalSystem.Metalogic.WeakCanonical$` missed
        two further syntactic forms: the multi-namespace form `open FormalSystem.Syntax
        FormalSystem.Metalogic.WeakCanonical` (8 lines in 8 residual
        `WeakCanonical/DenseModelSurgery/` files) and, in CompletenessDedekind, the `open ... in`
        form. A transitive-import closure confirms all 15 files reach the moved tree, so
        `open FormalSystem.Metalogic.Expressiveness` resolves in each.)*
      - **Insert every added `open` BELOW any line that a C20 `file.lean:NNN` citation points at**,
        so no citation shifts. Phase 5.3 re-runs C20 to confirm.
        *(deviation: altered — no `open` line was inserted at all. Each existing `open` line was
        **extended in place** with the extra namespace (`open A.WeakCanonical A.Expressiveness`,
        and `open A.WeakCanonical A.Expressiveness in` for the `in` form), asserted to change no
        file's line count. This shifts zero lines and so removes the citation-shift hazard
        entirely rather than merely routing around it.)*
      - The 8 fully-qualified citations of moved bare-namespace declarations:
        6x `FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior` in
        `FormalSystem/MainResults.lean`, `docs/architecture/ADR-011-Extract-Expressiveness.md`,
        `docs/theorem-index.md`, `scripts/check-module-invariants.sh` (this is the third C14
        baseline that class 5 does not reach), plus the primed `uSExpressivelyCompleteOverPrior'`
        site; and 2x `FormalSystem.Metalogic.WeakCanonical.MonadicSignature` in
        `Boneyard/DeadChronicleGapElimination/{ChronicleGapChainExcision,GapElimination}.lean`.
        Rewrite all of them to `...Expressiveness....`.
      - **Exception**: the ADR-011 occurrence inside the *Today* column of "The two names that
        change" is a historical statement and is handled in Phase 4.3, not here.
- [x] Assert the residual set is untouched:
      `grep -c 'FormalSystem\.Metalogic\.WeakCanonical\.countermodel_discrete' scripts/check-module-invariants.sh`
      still reads `1`. *(deviation: altered — the asserted value `1` is wrong at HEAD, where the
      count is already **2**: the C14 baseline text at line 1740 and the `#print axioms` probe at
      line 1860, exactly mirroring the `uSExpressivelyCompleteOverPrior` pair at 1782/1902. The
      invariant the assertion exists to guard — residual baselines uncorrupted by a prefix
      rewrite — holds: both occurrences are byte-identical to HEAD. Asserted as **unchanged at
      2**.)*
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` as a fast inner-loop probe. It is
      **expected to fail** here on the aggregator/README checks (C5/C6/C8/C12/C13), which Phase 4
      fixes. Record which checks fail so Phase 4 can confirm it closed exactly those.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch — Phases 3, 4 and 5 form one pre-declared atomic batch. The tree is
expected red for the whole of Phases 3 and 4; the single move commit is taken at the end of
Phase 5. Do not commit an intermediate state.

**Scope Hypothesis**: this phase asserts 29 `namespace` + 29 `end` + 104 in-tree `open` + 4
`_root_` headers + 8 residual in-tree dotted mentions + 8 external FQN citations + 10 external
`open` additions across 7 files. Confirm each count with the grep that produced it, **before**
editing and again after (the post-edit count for each rewritten class must be 0 inside
`FormalSystem/Metalogic/Expressiveness/`). A count that does not match is a signal the tree
drifted, not a reason to widen the edit.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/**` (141 files, post-move) - namespace/end/open/`_root_`
  rewrites in the subset that carries them.
- `FormalSystem/Metalogic/WeakCanonical/**` (5 residual files) - add the new `open`.
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`,
  `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` - add the new `open`.
- `FormalSystem/MainResults.lean`, `docs/theorem-index.md`,
  `scripts/check-module-invariants.sh`, `Boneyard/DeadChronicleGapElimination/*.lean` - FQN
  citations.

**Verification**:

- `grep -rc 'FormalSystem\.Metalogic\.WeakCanonical' FormalSystem/Metalogic/Expressiveness/` totals
  0 across all classes, or every surviving occurrence is a hand-reviewed, deliberate reference to
  the residual development.
- 29/29 `namespace`/`end` pairing holds under the new name.
- The residual C14 baseline `countermodel_discrete` count is still 1.

---

### Phase 4: Aggregator wiring, READMEs, ADR restoration and acceptance, gate re-point [COMPLETED]

**Goal**: Do the work the move tool deliberately does not: create the new aggregator, rewrite the
two READMEs, restore the two falsified historical statements, accept ADR-011, and make the
standing pre-move gate meaningful again.

**Tasks**:

- [ ] **4.1 Aggregators.** `FormalSystem/Metalogic/WeakCanonical.lean` holds exactly 14 imports
      into the moved set (lines 11, 13-17, 19-23, 27-29 of 40 at HEAD; the tool rewrote them in
      place, leaving a sibling aggregator importing a sibling directory's contents).
      - **Move** those 14 imports out into a new `FormalSystem/Metalogic/Expressiveness.lean`,
        with the standard copyright header and a module docstring naming the development.
      - Leave the remaining imports in `WeakCanonical.lean`.
      - Add `import FormalSystem.Metalogic.Expressiveness` to `FormalSystem/Metalogic.lean`
        (13 imports at HEAD, one of them `...WeakCanonical`).
      - C8 requires the new aggregator to exist; C6 requires any module left unreachable to be
        manifested — check both.
- [ ] **4.2 READMEs.** `FormalSystem/Metalogic/WeakCanonical/README.md` carries ~19 bare-form
      citations of the moved names (`Kamp/` x2, `EFGames/` x3, `Separation/` x3,
      `Expressiveness/` x2, and one each for the nine single modules). `move-modules.py` never
      rewrites bare-form citations — that is exactly what its `232 before, 232 after` audit line
      asserts — so every one of these is dangling now.
      - Rewrite `WeakCanonical/README.md` by hand to describe the residual 38-module development
        only.
      - Author `FormalSystem/Metalogic/Expressiveness/README.md` covering the moved set, following
        the conventions `scripts/readme-inventory.sh` / `readme-lint.sh` expect.
- [ ] **4.3 Restore the two falsified historical statements.**
      - `docs/architecture/ADR-011-Extract-Expressiveness.md`, "The two names that change": restore
        the *Today* column **verbatim from the Phase 2 capture**. If the tool collapsed the table to
        `After | After`, the row is wrong and must be put back.
      - `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`, the
        `BXCanonical → WeakCanonical (9 import lines)` block: **remove** the four
        `ChronicleMonadicBridge.lean` lines that now point at `Expressiveness`
        (`Kamp.KPlusFaithful`, `PriorDefsDense`, `PriorExpressivenessDense`, `Table`) and change
        the header from `(9 import lines)` to `(5 import lines)`. Do **not** rewrite them in place —
        that produces a block headed "9 import lines" listing `Expressiveness` targets, which is
        internally contradictory. ADR-011's own Consequences section prescribes this treatment and
        the research simulation independently confirms the post-move count is 5.
- [ ] **4.4 Accept ADR-011 and point ADR-006 at it.**
      - ADR-011 `## Status`: `**Proposed** - 2026-09-19` -> `**Accepted** - {implementation date}`,
        and reword the trailing sentence that currently reads "ADR-006 remains **Accepted** until
        this record is" to state that it now is.
      - ADR-006 `## Status`: update the supersession note from "(Proposed); this record remains in
        force until that ADR is accepted" to a pointer stating that ADR-011 is **Accepted** and
        supersedes the no-physical-relocation clause for the expressiveness subset only; ADR-006's
        declined `Completeness/` regroup and its accepted single cycle both stand.
      - Refresh the stale residual line count in ADR-011's measurement table: `28,472` -> `28,498`
        (measured at HEAD; the script's header states its output wins over a document).
- [ ] **4.5 Re-point the standing gate.** In `scripts/measure-refactor-partitions.py`, `--check`
      becomes vacuous after the move: `g.under(WEAK)` finds only the residual 38, `expr` is empty,
      and the check prints `PASS ... (0 files)` and exits 0 forever.
      - Re-point the expressiveness root at `FormalSystem.Metalogic.Expressiveness` (with
        `GameTransfer` in place of the old `Expressiveness` member) and keep
        `FormalSystem.Metalogic.WeakCanonical` as the residual root.
      - Add an explicit **empty-set failure branch**: if the expressiveness set is empty, the check
        FAILS loudly rather than passing. ADR-011's Consequences promises this is "a standing
        pre-move gate"; without the branch it silently degenerates.
      - Refresh the `28,472` in the module docstring to `28,498`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: atomic-batch — continues the Phase 3 batch; no commit here.

**Scope Hypothesis**: this phase asserts 14 imports to relocate out of `WeakCanonical.lean`, ~19
bare-form README citations, and 4 lines to remove from the ADR-006 block. Confirm the 14 by
`grep -c` on the post-move `WeakCanonical.lean` before editing; confirm the README citations by
enumerating them rather than trusting the ~19; confirm the ADR-006 removal by checking that the
surviving block lists exactly 5 import lines.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness.lean` - new aggregator, 14 imports.
- `FormalSystem/Metalogic/WeakCanonical.lean` - drop the 14 moved imports.
- `FormalSystem/Metalogic.lean` - add the new aggregator import.
- `FormalSystem/Metalogic/Expressiveness/README.md` - new.
- `FormalSystem/Metalogic/WeakCanonical/README.md` - rewrite for the residual set.
- `docs/architecture/ADR-011-Extract-Expressiveness.md` - Status, *Today* column, 28,498.
- `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md` - Status pointer, cycle block 9->5.
- `scripts/measure-refactor-partitions.py` - re-point roots, empty-set failure branch, 28,498.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` green again (C5/C6/C8/C12/C13 closed).
- ADR-011's *Today* column differs from its *After* column.
- ADR-006's cycle block header reads `(5 import lines)` and lists 5.
- `measure-refactor-partitions.py --check` prints a non-zero expressiveness count.

---

### Phase 5: Regenerate derived artifacts, verify, and take commit 1 [COMPLETED]

**Goal**: Regenerate `typst/generated`, reconcile `docs/theorem-index.md` and the C2/C14
baselines, hand-review every non-`.lean` hunk, prove the acceptance criteria non-degenerately,
and land the move as one commit.

**Tasks**:

- [ ] **5.1 Hand-review every non-`.lean` diff hunk.** `git diff --stat` then
      `git diff -- '*.md' '*.typ' 'scripts/*'` and read **every** hunk. `move-modules.py` collapsed
      "from X to Y" into "from Y to Y" in every move of this run; ADR-011 and ADR-006 are the two
      *known* sites, not necessarily the only ones. Any hunk that turns a historical statement into
      a present-tense one is a defect to fix here.
- [ ] **5.2 Non-degenerate acceptance assertions.** Every one of these must be run and its
      **value** recorded — exit 0 alone proves nothing after this move:
      - `find FormalSystem/Metalogic/Expressiveness -name '*.lean' | wc -l` == `141`
      - `find FormalSystem/Metalogic/WeakCanonical -name '*.lean' | wc -l` == `38`
      - `python3 scripts/measure-refactor-partitions.py --check` exits 0 **and** prints a
        `141`-file expressiveness set against a `38`-file residual set.
      - `grep -rn 'FormalSystem\.Metalogic\.WeakCanonical' FormalSystem/Metalogic/Expressiveness/`
        returns only hand-reviewed deliberate references to the residual development (0 otherwise).
      - `grep -c 'FormalSystem\.Metalogic\.WeakCanonical\.countermodel_discrete' scripts/check-module-invariants.sh`
        == `1`.
      - `grep -rc 'FormalSystem\.Metalogic\.WeakCanonical\.uSExpressivelyCompleteOverPrior' .`
        == `0`. *(deviation: altered — 0 across all tracked files, which is the assertion's
        intent; a bare `grep -r .` also reads 9 hits inside the gitignored `.lake/` build cache
        and build-guard logs left by the pre-move build, which are not source.)*
      - `bash scripts/check-metalogic-cycles.sh` reports **exactly 1** cycle, still
        `BXCanonical <-> WeakCanonical`. If it reads 0 or 2, the discrepancy is in the aggregator
        wiring (Phase 4.1), not in the module partition.
- [ ] **5.3 Full build-inclusive harness.** Run `bash scripts/check-module-invariants.sh`
      **without** `--no-build`. `lake build` green is **not** sufficient: exe roots sit outside
      every build closure and only C25 catches a broken one; C2/C14 axiom pinning is likewise
      build-gated. Run it as a **foreground blocking Bash call with `timeout: 600000`**, re-invoked
      until it completes — a cold rebuild of a 104,000-line move is long, and the guarded build
      resumes from the lake cache, so re-invocation is cheap. Do NOT background it or wait on it
      with a monitor.
      - Fix any C14/C2 axiom-baseline entry the move did not reach (research measured class 5
        rewriting 2 of the 3 WeakCanonical baselines; the third was handled in Phase 3.3 — confirm).
      - Re-run C20 specifically: added `open` lines can shift `file.lean:NNN` citations. Only 1
        such citation points into the moved tree, but confirm rather than assume.
      - C15 verifies `docs/theorem-index.md` rows are anchored at their declarations; the index is
        hand-maintained (no generator), so fix the affected rows directly (research found 1 dotted
        + 2 slash citations at rows 218-219).
- [ ] **5.4 Regenerate `typst/generated`.** With the Phase 1 fix in place, run
      `bash scripts/typst-status-counts.sh` and `bash scripts/typst-module-map.sh`. Review the diff:
      `sorry-total` must still read `4`. The moved set carries 0 live sorries, so the
      `WeakCanonical/ (live)` row stays `0` and the moved files fall into the `Metalogic/ (other)`
      remainder at `0` — a figure change here needs an explanation before it is committed.
      Re-run `bash scripts/typst-sync-check.sh`: Check 2 `MISMATCH_COUNT=0`; Check 1's 9
      pre-existing violations remain.
- [x] **5.5** Re-run `bash scripts/readme-lint.sh` and confirm the broken-ref count is still `21`,
      not higher. *(deviation: altered — it first read 22. The extra one was a relative link
      `../Separation/README.md` in the residual `IntegerModel/README.md`, which the tool's class-7
      re-basing did not reach; re-pointed to `../../Expressiveness/Separation/README.md` and the
      count returned to 21, exactly as the plan predicted a rise would mean.)* Every move preserved directory depth, so the 9 refs living in moved READMEs
      resolve identically; a rise means Phase 4.2's README work is incomplete.
- [ ] **5.6 Record the task-412 reconciliation fact** in the new
      `FormalSystem/Metalogic/Expressiveness/README.md` or the residual
      `WeakCanonical/README.md`: `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` stays
      in the residual 38-file set and its path is unchanged by this extraction, so citations of it
      do not drift. State it as a durable fact about the path, **without** citing a task number —
      `.claude/rules/no-task-references-in-deliverables.md` forbids task-number references outside
      `specs/**`.
- [ ] **5.7 Commit 1** with targeted staging (never `git add -A`, never a directory pathspec):
      `task 635: extract Expressiveness out of WeakCanonical`.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch — closes the Phase 3-5 batch with the single move commit.

**Scope Hypothesis**: this phase asserts post-move counts of 141 / 38 / exactly 1 cycle / 21
broken refs / `MISMATCH_COUNT=0` / `sorry-total = 4`. Every one is confirmed by running the named
command and comparing the printed value; none may be inferred from an exit code.

**Files to modify**:

- `typst/generated/*` - regenerated.
- `docs/theorem-index.md` - affected rows.
- `scripts/check-module-invariants.sh` - any baseline the move did not reach.
- READMEs - the reconciliation note.

**Verification**:

- Build-inclusive `check-module-invariants.sh` green, all checks.
- `check-metalogic-cycles.sh` reports exactly 1.
- Every assertion in 5.2 passes with the stated value.
- One commit containing the whole move.

---

### Phase 6: Rename the paper-numbered modules and delete the genuine stubs [COMPLETED WITH EXCLUSIONS]

**Goal**: Replace paper-artifact filenames with content names, and remove the two genuinely
declaration-free stub modules, rewiring their importers.

**Tasks**:

- [ ] **6.1 Confirm and finalise the rename list.** The task description's "39 paper-numbered
      files" is not mechanically reproducible — it comes from a hand-written inventory row
      (`docs/development/PUBLICATION_REFACTOR.md:63`) and no script produces it. The strict
      re-derivation gives **14** paper-numbered names, of which 2 are deleted in 6.2, leaving
      **12 renames**. *(deviation: altered — the strict re-derivation over the post-move tree
      gives **15**, not 14: the plan missed `Kamp/Section5Correspondence.lean`. It is excluded
      with evidence in the Reasoned Exclusions table below, so the rename count stands at 12.)* Proposed targets (each is a *proposal* — confirm against the file's headline
      declarations and check for a sibling collision **before** executing):

      | Current module (post-move) | Proposed content name | Headline content |
      |---|---|---|
      | `Expressiveness.GameTransfer.Claim1` | `...GameTransfer.ContinuationSets` | `ContHolds`, `ContHoldsCross`, `ContinuationSetCross`, base-case M/N equality |
      | `Expressiveness.Kamp.Lemma53` | `...Kamp.KPlusBracketRendering` | `allTopBracket`, `kplus_formula_correct` |
      | `Expressiveness.Kamp.Lemma53Faithful` | `...Kamp.KPlusFaithfulRendering` | `kplusPred`, `kplusOpenPred`, `VVecEA2.prependAllVec` — **collision check: `Kamp/KPlusFaithful.lean` already exists** |
      | `Expressiveness.Kamp.Lemma53FaithfulPast` | `...Kamp.KMinusFaithfulRendering` | `kminusFormula`, `kminusPred`, `kminusOpenPred` |
      | `Expressiveness.Kamp.Prop35Assembly` | `...Kamp.ExistsForallTranslation` | `translateProp35Fin`, `efPointTPFin`, `efIntervalSetTPFin` |
      | `Expressiveness.Kamp.Prop35Chain` | `...Kamp.UntilSinceChainSpec` | `buildRight_spec_iff_chain`, `buildLeft_spec_iff_chain` |
      | `Expressiveness.Kamp.Prop42Contentful` | `...Kamp.ContentfulWitness` | `Prop42Contentful`, `topBlock`, `topVVec` |
      | `Expressiveness.Kamp.Prop42ExistsForall` | `...Kamp.VeeExistsForallTranslation` | `translateProp42Fin`, `translateVeeProp42Fin` |
      | `Expressiveness.Kamp.Prop42Faithful` | `...Kamp.ContentfulFaithfulBridge` | `prop42_contentful_of_faithful`, `prop42_contentful_of_dedekind` |
      | `Expressiveness.Kamp.Prop42NegationGeneral` | `...Kamp.BracketNegationClauses` | `negLeftClauseFin`, `negRightClauseFin`, `belowFormulaFin` |
      | `Expressiveness.Kamp.Prop42Vacuity` | `...Kamp.VacuousConclusionGuard` | `prop42_conclusion_is_vacuous` |
      | `Expressiveness.Kamp.Prop43Translate` | `...Kamp.MonadicFormulaSubstitution` | `MonadicFormula.rename/size/subst0`, `eval_rename` |

      Keep every paper reference (Rabinovich Lemma 5.3, Prop 3.5, Prop 4.2/4.3, GHR93 Claim 1, …)
      **in the module docstrings**, which is where a paper citation belongs; only the filenames
      change.
- [ ] **6.2 Delete the 2 genuine declaration-free stubs, rewiring importers.**
      - `Expressiveness/GameTransfer/Theorem6.lean` (25 lines, declaration-free, imports
        `...GameTransfer.CaseAnalysis`). Four importers:
        `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean:20`,
        `Boneyard/StaviDiscretePath/DiscreteGameTransfer.lean:7`,
        `FormalSystem/Metalogic/Expressiveness.lean` (the new aggregator),
        `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:11`. Replace each `import ...Theorem6`
        with `import ...GameTransfer.CaseAnalysis` where the importer actually needs that content,
        and drop it outright where it does not. Verify each by building.
      - `Expressiveness/Kamp/Prop35ExistsForall.lean` (45 lines, declaration-free, re-exports
        `Kamp.ExistsForallFormula` + `Separation.KampTranslation`). One importer:
        `Expressiveness/Kamp/Prop35Chain.lean:8` — replace that single import with the two it
        re-exports.
      - Preserve the substantive archival explanations both docstrings carry (where the GHR93
        Theorem 6 chain was archived; where the Prop 3.5 rendering now lives) by folding them into
        the surviving module's docstring or the directory README. Do not simply lose them.
- [ ] **6.3 Execute the renames with `move-modules.py`**, not by hand, so imports, dotted citations,
      slash-path citations and relative links are all rewritten together. Write a second module map
      at `specs/635_expressiveness_extraction/rename-map.txt` with the 12 confirmed rows and run
      with `--dry-run` first, then for real with `--no-verify`.
- [ ] Re-run `bash scripts/check-module-invariants.sh --no-build` as the inner-loop probe.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `Kamp/NfMultiAnchorBridge.lean` (413 ln, declaration-free) | Sibling re-export aggregator for `Kamp/NfMultiAnchorBridge/`; C8 requires it and `Kamp/KampPrior.lean:10` imports it. Not a stub. | `grep -rn 'import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge$'` -> 1 importer; file body is an import block plus a documented split record. |
| `Kamp/EANegationFix.lean` (35 ln, declaration-free) | Sibling re-export shim for `Kamp/EANegationFix/`, with 7 imports and a documented Phase-R1 split order. Two importers. **The research report's "delete 3, not 4" wrongly classes this as a true stub.** | `grep -rn 'import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix$'` -> `Kamp/NfMultiAnchorBridge.lean:221`, `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean:8`; file body is 7 `import` lines plus the split docstring. |
| `Kamp/Section5Correspondence.lean` | A 15th strictly paper-numbered name the plan's derivation of 14 missed. It is NOT renamed: it is a navigational guard module whose entire documented purpose is to be found by a reader searching for "Section 5". Its docstring states it exists "so that the next reader finds the correspondence instead of re-deriving it" after the material was re-planned from scratch by successive agents despite being present and sorry-free for thirteen months. Renaming it away from `Section5` would defeat the function it was written to serve. | File header: "**Read this before planning any Section 5 work.** Rabinovich's Section 5 ... is **already transcribed in this tree** ... It was discoverable by `grep` for thirteen months and was nonetheless re-planned from scratch"; the file is a correspondence table, CI-protected by reachability from `FormalSystem.lean`. |
| The 12 "history-suffixed" modules (`EFSatNegationGeneral`, `NfDepth0Generalized`, `EANegationFix/{BoundedFix,NegFix,VecEANegFix}`, `NfMultiAnchorBridge/{AggregateOffDiagK1,AggregatePointMergeK1,ExteriorFiberKitK1,ExteriorNavFutK1,ExteriorNavPastK1,SubBracket2}`) | Not paper-numbered. Their names already describe content (`K1` is the arity k=1, `SubBracket2` the anchor-at-`x` sub-bracket, `BoundedFix` the Until/Since fold). The task's scope is paper-artifact names -> content names; these are already content names. | Docstring headings read e.g. "Off-diagonal k=1 aggregate: zone classifier + per-qnf dispatcher", "Since-navigated w-package `navPackLeft`" — content descriptions, not paper artifact numbers. |

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: atomic-batch — Phases 6 and 7 form the second pre-declared batch; the single
rename commit is taken at the end of Phase 7.

**Scope Hypothesis**: this phase asserts 14 paper-numbered names, 12 renames, and exactly 2
deletable stubs (against the research report's 3). Confirm the 14 by re-deriving the strict
pattern over the post-move leaf names; confirm the 2 by checking that each candidate's body is
genuinely declaration-free **and** carries no `import` lines that make it a sibling aggregator,
and by enumerating its importers with `grep -rn 'import <module>$'`.

**Files to modify**:

- `specs/635_expressiveness_extraction/rename-map.txt` - new, 12 rows.
- 12 module files renamed, plus every importer and citation `move-modules.py` rewrites.
- 2 stub files deleted, plus 5 importer files rewired.

**Verification**:

- No file under `FormalSystem/Metalogic/Expressiveness/` has a paper-artifact filename
  (`Claim`/`Theorem`/`Lemma`/`Prop` + digits).
- `check-module-invariants.sh --no-build` green.
- Each deleted stub has zero remaining importers.

---

### Phase 7: Reconcile the programme docs, full verification, and take commit 2 [COMPLETED]

**Goal**: Correct the unreproducible inventory figure, run the full build-inclusive harness, and
land the renames as the second commit.

**Tasks**:

- [ ] Correct `docs/development/PUBLICATION_REFACTOR.md`'s Phase 6 inventory row: replace the
      unreproducible `39` with the actual count this task renamed (12) plus the 2 deleted stubs,
      and state how the figure is derived so a future reader can re-check it. Mark Phase 6 of the
      programme as complete.
- [ ] Update any ADR-011 or README text that still describes the paper-numbered filenames.
- [ ] **Hand-review every non-`.lean` diff hunk** of commit 2, same rule as Phase 5.1 — the rename
      run is the same tool with the same "from X to Y" collapse behaviour.
- [ ] **Full build-inclusive** `bash scripts/check-module-invariants.sh` (no `--no-build`), run as
      a **foreground blocking Bash call with `timeout: 600000`**, re-invoked until it completes.
      All checks green, including C25's exe roots and C2/C14 axiom pinning.
- [ ] `bash scripts/check-metalogic-cycles.sh` still reports exactly 1.
- [ ] `python3 scripts/measure-refactor-partitions.py --check` still exits 0 with a non-zero
      expressiveness count.
- [ ] `bash scripts/typst-sync-check.sh` Check 2 `MISMATCH_COUNT=0`; Check 1's 9 violations remain;
      `bash scripts/readme-lint.sh` still 21.
- [ ] **Commit 2** with targeted staging:
      `task 635: rename paper-numbered Expressiveness modules to content names`.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: atomic-batch — closes the Phase 6-7 batch with the single rename commit.

**Scope Hypothesis**: this phase asserts the corrected inventory figure and the unchanged
pre-existing baselines (21 broken refs, Check 1's 9). Confirm by re-running `readme-lint.sh` and
`typst-sync-check.sh` and comparing against the Phase 1 recorded values.

**Files to modify**:

- `docs/development/PUBLICATION_REFACTOR.md` - inventory row and Phase 6 status.
- `docs/architecture/ADR-011-Extract-Expressiveness.md` - any stale filename references.

**Verification**:

- Build-inclusive `check-module-invariants.sh` green.
- `check-metalogic-cycles.sh` == 1.
- Pre-existing red baselines unchanged at 21 and 9.
- Two commits total for the move and the renames.

---

## Testing & Validation

- [ ] `python3 scripts/measure-refactor-partitions.py --check` exits 0 **and** prints a
      141-file expressiveness set / 38-file residual set — before the move (Phase 1) and, against
      the re-pointed roots, after it (Phases 5, 7).
- [ ] `bash scripts/check-metalogic-cycles.sh` reports exactly 1 cycle after each commit.
- [ ] `bash scripts/check-module-invariants.sh` (build-inclusive, no `--no-build`) green after each
      of the two commits — this, not `lake build`, is the acceptance gate.
- [x] `find FormalSystem/Metalogic/Expressiveness -name '*.lean' | wc -l` == 141 and
      `find FormalSystem/Metalogic/WeakCanonical -name '*.lean' | wc -l` == 38.
      *(deviation: altered — 141/38 after commit 1, then **139**/38 after commit 2, which deletes
      the 2 declaration-free stubs. Both are the intended values at their respective commits.)*
- [ ] No occurrence of `FormalSystem.Metalogic.WeakCanonical` survives inside
      `FormalSystem/Metalogic/Expressiveness/` except as a hand-reviewed reference to the residual
      development.
- [ ] The residual C14 baseline `...WeakCanonical.countermodel_discrete` is intact (count 1) and
      `...WeakCanonical.uSExpressivelyCompleteOverPrior` has zero occurrences repo-wide.
- [ ] `bash scripts/typst-sync-check.sh` Check 2 reads `MISMATCH_COUNT=0`; `typst/generated/status.typ`
      still publishes `sorry-total = 4`.
- [ ] `bash scripts/readme-lint.sh` broken-ref count is still 21 (not higher).
- [ ] ADR-011's *Today* column differs from its *After* column; ADR-006's cycle block reads
      `(5 import lines)` and lists 5.
- [ ] No file under `FormalSystem/Metalogic/Expressiveness/` carries a paper-artifact filename.

## Artifacts & Outputs

- `specs/635_expressiveness_extraction/plans/01_expressiveness-extraction-move.md` (this file)
- `specs/635_expressiveness_extraction/module-map.txt` (13 rows)
- `specs/635_expressiveness_extraction/namespace-map.txt` (2 rows)
- `specs/635_expressiveness_extraction/rename-map.txt` (12 rows)
- `FormalSystem/Metalogic/Expressiveness/` (141 modules, relocated)
- `FormalSystem/Metalogic/Expressiveness.lean` (new aggregator)
- `FormalSystem/Metalogic/Expressiveness/README.md` (new)
- Three commits: the typst generator fix, the move, the renames.
- `specs/635_expressiveness_extraction/summaries/01_expressiveness-extraction-move-summary.md`

## Rollback/Contingency

The Phase 3 checkpoint (`bash .claude/scripts/git-snapshot.sh 635 --no-revert`) is durable and
non-reverting: it preserves the pre-move tree without touching the working copy.

- **Failure inside the Phase 3-5 batch** (before commit 1): nothing is committed, so recovery is a
  working-tree restore. If a genuine whole-tree rollback is needed, follow
  `.claude/context/contracts/recovery.md`'s rollback rung — snapshot first, with
  `--allow-out-of-scope` for the deliberate whole-tree case, then run the destructive command.
  Prefer fixing forward: the recovery ladder's first rung is correcting the source, and this task
  introduces no proof obligations that could require a strategic sorry.
- **Failure inside the Phase 6-7 batch** (after commit 1): commit 1 is independently green and
  self-consistent. Discard only the uncommitted rename work and re-attempt Phase 6 from the
  commit-1 tree; the move does not need redoing.
- **Failure after commit 2**: both commits are independently green; `git revert` the rename commit
  alone leaves the extraction intact.
- The Phase 1 generator fix is committed separately and should be kept in every rollback scenario —
  it is an independent defect fix with no dependency on the move.
