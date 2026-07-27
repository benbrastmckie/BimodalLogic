# Implementation Plan: Retire the unwired arity-4 characteristic-formula stack

- **Task**: 407 - retire the unwired arity-4 characteristic-formula stack
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/407_retire_unwired_arity4_char_stack/reports/01_arity4-char-stack-reachability-audit.md`
- **Artifacts**: plans/01_boneyard-arity4-char-stack.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Retire a closed 30-declaration reference island — the losing arity-4 characteristic-formula
branch — by **archiving it to `Kamp/Boneyard/`, not raw-deleting it**, then excising its four
contiguous source blocks (1,736 lines) from the live tree. This is dead-code removal, not
mathematics: the routing question was settled when the zeta wire landed, and the Phase 9
adjudication of the transcription task directed that this stack "be excised or Boneyarded, not
consumed". The definition of done is that the four blocks are gone, the archive file exists, two
prose records that document LIVE code survive as condensed live-adjacent notes, and every
verification baseline measured in Phase 1 is unchanged in Phase 5.

### Research Integration

The audit is the operative specification and **overrides the task description in three places**.
The plan is built around those corrections:

1. **`igOffFiber` is LIVE, not dead.** The task description files it under the dead family. It sits
   at `InteriorGateGeneralK.lean:329`, well above the island, and has three arity-1 consumers
   (`bracketEndChar_kv_succ_eq:372`, `bracketEndChar_kv_succ_holds_iff:439`,
   `bracketEndChar_kv_step_gate:555`). Deleting it breaks the build. It lies outside all four
   deletion ranges, so **block-wise deletion is safe where a name sweep is not**. This is the
   single load-bearing reason the plan forbids any `*Fib` grep-and-delete.
2. **`igAllSubs` IS dead** (`InteriorGateGeneralK.lean:1439`) and belongs in the excision set even
   though the task description omits it (it carries no `Fib` suffix). It falls inside the
   `InteriorGateGeneralK` block range, so block deletion already catches it.
3. **Two comment records are relocation obligations, not deletions.** The task description says of
   the circularity record "leave or update the comment", which presumes it is outside the block.
   It is not — it is inside. Both records are handled by Phase 4.

Also carried forward: the excision set (30 declarations), the four verified line ranges, the
Boneyard-over-raw-excise recommendation, and the measured verification baselines.

### Plan-time re-verification of the audit (done at planning time, on disk)

Every boundary below was re-confirmed against the working tree before this plan was written. All
four ranges are still valid and unshifted:

| File | Lines now | Audited range | Line 1 of range confirmed as |
|---|---|---|---|
| `KampPrior.lean` | 1985 | 1082-1232 | `set_option maxHeartbeats 1600000 in` |
| `NfMultiAnchorBridge/ExteriorGateAssembleK.lean` | 791 | 447-790 | `/-! ## De-folded exterior gate (additive siblings)` |
| `NfMultiAnchorBridge/InteriorGateGeneralK.lean` | 2553 | 1424-2550 | `/-! ## M2 (Option B) — DE-FOLDED public replicas (sibling of `igBody`)` |
| `NfMultiAnchorBridge/CarrierKv.lean` | 617 | 503-616 | `/-! ## M2 (Option B) — the DE-FOLDED sibling carrier` |

Two amendments to the audit, both discovered at plan time:

- **The audit undercounts `set_option` lines.** It refers to "the two `set_option maxHeartbeats
  1600000 in` lines". There are in fact **eight** inside the deletion ranges: `InteriorGateGeneralK`
  at 1671, 1733, 1809, 1893, 2281, 2466; `ExteriorGateAssembleK` at 568; `KampPrior` at 1082. All
  eight must be carried into the archive verbatim with their following declaration.
- **In-file line citations in this tree are stale and MUST NOT be trusted as anchors.**
  `InteriorGateGeneralK.lean`'s own prose cites `bracketEndCharKv` at `CarrierKv.lean:238` and
  `igFoldBit_realize_iff` at `:563`; the actual declarations are at `CarrierKv.lean:248` and
  `InteriorGateGeneralK.lean:611`. This is direct evidence for the plan-wide rule: **locate every
  anchor by content, never by a line number quoted in prose.**

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Archive the 30-declaration island to
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean`, preserving
  docstrings, `set_option` prefixes, and provenance.
- Delete the four verified line blocks from the four live files (1,736 lines).
- Preserve the two prose records that document LIVE code as condensed notes attached to the live
  declarations they describe.
- Leave `lake build`, `lake build BimodalTest`, and both flagship axiom sets exactly as measured in
  Phase 1.

**Non-Goals** (each repeats an abandoned effort; do not revisit):

- Do NOT wire, repair, complete, or find a consumer for the arity-4 stack.
- Do NOT build an arity-4 realization engine.
- Do NOT reach for Feferman-Vaught.
- Do NOT touch `FormalSystem/Metalogic/Soundness.lean` — two concurrent tasks own it. It is
  read-only baseline material for the sorry census and nothing else.
- Do NOT prove anything. This task closes no goals and adds no lemma.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A name-driven `*Fib` sweep deletes `igOffFiber` or a `kvEFiber*`/`kvE_deepOnFiber_*` member, breaking the build | H | M — the task description itself mis-files `igOffFiber` | Delete by verified line block only. Phase 3 forbids grep-driven deletion and requires a post-deletion existence assertion on `igOffFiber` and `igFoldBit` |
| Line numbers drift because Phase 2/4 edits land before Phase 3's deletion | H | M | Phase ordering is chosen so the four ranges stay unshifted through Phase 3 (see "Why the audit's phase order is reordered"). Phase 3 additionally re-confirms every boundary by content string before cutting |
| A prose record documenting live code is silently lost | M | H if the block is deleted naively — both records sit inside deletion ranges | Phase 2 lands the archive (which carries both records verbatim) before Phase 3 deletes, so neither record is ever absent from the tree; Phase 4 restores condensed versions beside the live code |
| Red C3 after the change is misread as a regression caused by this task | M | M | C3 is **already red** (expects 1 structural sorry, finds 3) from concurrent `Soundness.lean` work. Phase 1 records the pre-state to a file so Phase 5 compares rather than judges |
| Deleting the trailing `end` in `InteriorGateGeneralK.lean` breaks section pairing | H | L | The range stops at 2550; the `end` at 2551 closes the `noncomputable section` opened at :197 and is explicitly retained. Phase 3 verifies the file still ends with `end` + `end FormalSystem.Metalogic.WeakCanonical.Kamp` |
| Removing an `open private` line still needed by surviving arity-1 proofs | H | L | `InteriorGateGeneralK.lean:679` and `:1100` and `ExteriorGateAssembleK.lean:51` are all outside the deletion ranges and must remain. Phase 3 asserts they are still present |
| Archived code silently rots | L | Certain, and accepted | The Boneyard README states this explicitly; the stack is adjudicated dead, so rot is the intended outcome |

### Why the audit's phase order is reordered

The audit recommends relocating the two prose records *before* deleting the blocks, reasoning that
the records should never be absent from the tree in any intermediate commit. This plan instead
sequences **archive → delete → relocate**, for a concrete reason: relocation inserts lines *above*
both deletion ranges (near `InteriorGateGeneralK.lean:611` and `CarrierKv.lean:248`), which shifts
the two largest ranges downward and forces a recomputation immediately before the riskiest edit.

The audit's invariant is still satisfied. The archive file created in Phase 2 carries **both prose
records verbatim** (each sits inside a block copied wholesale), so from the end of Phase 2 onward
the records are continuously present in the tree. Phase 4 then adds condensed live-adjacent copies.
At no commit boundary is either record missing.

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

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
mutates or measures state the next phase depends on, and a half-applied deletion is the primary
hazard, so no parallelism is offered.

---

### Phase 1: Capture pre-state baseline [COMPLETED]

**Goal**: Record every verification signal *before* any edit, so Phase 5 compares against measured
fact rather than assumption. This phase is read-only and MUST complete before any file is modified.

**Tasks**:

- [x] Create `specs/407_retire_unwired_arity4_char_stack/baseline-prestate.txt` to hold all output
      below (this is a task-scoped scratch record, not a deliverable artifact). *(completed)*
- [x] Confirm the working tree is clean or that all dirty paths are outside this task's file scope;
      record `git rev-parse HEAD`. *(completed — HEAD 4545b0916; all dirty paths are `specs/`
      task-management artifacts from concurrent tasks, zero dirty `.lean` files)*
- [x] Run `lake build` and `lake build BimodalTest`; record both exit codes. *(completed — both 0)*
- [x] Write a probe file (outside the repo source tree, e.g. under the scratchpad) containing:
      `import FormalSystem`, `#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete`,
      `#print axioms FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness`,
      and a deliberately bogus identifier as a control. Run it with `lake env lean` — **not**
      `lean_run_code`, which has reported success for bogus identifiers in this repository.
      Record both axiom lines and confirm the control errors with `unknownIdentifier`.
      *(completed — both report `[propext, Classical.choice, Quot.sound]`; control errors with
      `unknownIdentifier`, so the probe is validated as trustworthy)*
- [x] Record the live sorry census (non-Boneyard, comment-stripped). Expected: 5 —
      `Soundness.lean:1461,1472,1486,1509` and `Transfer.lean:1242`.
      *(deviation: altered — the plan's expected value was stale. MEASURED pre-state is **3**, at
      `Soundness.lean:1553`, `Soundness.lean:1576`, `Transfer.lean:1242`. Concurrent `Soundness.lean`
      work by other tasks both moved and reduced them. The measured 3 is the baseline of record;
      Phase 5 compares against 3, not the plan's 5.)*
- [x] Run `bash scripts/check-module-invariants.sh` and record the **full pass/fail line for every
      check C1-C10**, not just the summary. **C3 is expected to be RED** (asserts exactly one
      structural sorry, will report 3) because of concurrent `Soundness.lean` work by other tasks.
      Write this expectation into the baseline file in words, so a still-red C3 in Phase 5 cannot be
      misread as a regression introduced here.
      *(completed — C3 red exactly as predicted. **deviation: altered — a SECOND pre-existing red
      was found that the plan does not mention: C9** (4 task-number citations, all four inside
      `Soundness.lean`, which is read-only here). Both C3 and C9 are recorded as pre-existing red in
      the baseline file; Phase 5's criterion covers both.)*
- [x] Record the C7 informational live-file and live-line counts (Phase 5 expects live lines to drop
      by ~1,736). *(completed — 340 live .lean files (297 FormalSystem / 42 Tests); four-file line
      total 5946, expected post-deletion 4210)*
- [x] Re-confirm the four deletion ranges by content: for each file, assert that the first line of
      the range and the first retained line after the range match the strings in the plan-time
      verification table above. *(completed — all four ranges valid and unshifted; boundaries
      transcribed into baseline section 8)*
- [x] *(added)* Record the `scripts/readme-lint.sh` baseline exit code, needed by Phase 6's
      "exits as it did in the Phase 1 baseline" criterion. *(exit 1: 1 missing README,
      5 broken references — already red)*

**Timing**: 30-40 minutes

**Depends on**: none

**Files to modify**:

- `specs/407_retire_unwired_arity4_char_stack/baseline-prestate.txt` - new; captured baseline

**Verification**:

- The baseline file exists and contains: HEAD sha, two build exit codes, two axiom lines, the bogus
  control's error, the sorry census, every C1-C10 result line with C3's pre-red status stated
  explicitly, and the four confirmed range boundaries.
- No `.lean` file has been modified (`git status --short` shows only the baseline file).

---

### Phase 2: Land the Boneyard archive file [COMPLETED]

**Goal**: Create a single archive file holding all 30 declarations verbatim, so nothing is lost when
Phase 3 cuts. Boneyard code is never compiled (it is outside the Lake import closure), so this file
does not need to build — but it should be faithful.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean`.
      *(completed — 1,862 lines)*
- [x] Write the header block following the convention already used by
      `Boneyard/InteriorHrealSupplyK.lean`: an `ARCHIVED — off-faithful-path (Kamp Boneyard).
      MOVE-not-delete; do NOT delete or empty.` banner, the reason for retirement ("landed, unwired,
      circular, fiber-refuted" per the Phase 9 adjudication), the fact that the competing zeta route
      won and keeps `charF` arity-1 end-to-end, a `Key declarations:` line, and — required for
      traceability — a **provenance table** giving, for each of the four source blocks, the origin
      file and the exact line range it came from. *(completed — banner, four-line retirement
      adjudication, zeta-won/`charF`-arity-1 statement, `Key declarations:` line, and a 4-row
      provenance table with origin file + line range + line count + contents. Also added an
      explicit "What is NOT here" section naming `igOffFiber`/`kvEFiber*`/`kvE_deepOnFiber_*` as
      LIVE non-members, so a future reader cannot mistake the shared `Fib` suffix for membership.)*
- [x] Add imports. `import FormalSystem.Metalogic.WeakCanonical.Kamp.KampPrior` is the primary edge
      (this is what `InteriorHrealSupplyK.lean` uses); add the three
      `NfMultiAnchorBridge.{CarrierKv,InteriorGateGeneralK,ExteriorGateAssembleK}` imports if they
      are not already transitively reached. Best-effort: the file is never compiled.
      *(completed — all four imports written explicitly. A `#exit` guard was also added after the
      module docstring, matching `InteriorHrealSupplyK.lean`'s convention, so the file cannot
      compile even if something ever imports it.)*
- [x] Reproduce the `open private` lines the moved proofs consume — the `k1v_*` privates opened at
      `InteriorGateGeneralK.lean:679` and `:1100`, and at `ExteriorGateAssembleK.lean:51`. **Copy
      these; do not move them** — the originals stay in the live files (Phase 3 asserts this).
      *(completed — copied, each marked in-file as COPIED-not-moved; originals untouched)*
- [x] Copy the four blocks in dependency order, each under a sub-heading naming its origin:
      `CarrierKv.lean:503-616` (`kvFib_body`, `bracketEndCharKvFib`) →
      `InteriorGateGeneralK.lean:1424-2550` (`igAllSubs`, the `ig*Fib` defs, the
      `bracketEndChar_kvFib_*` theorems) → `ExteriorGateAssembleK.lean:447-790` (the `*ExtFib`
      block) → `KampPrior.lean:1082-1232` (`kampPrior_site_rungKFib_gate_match`).
      *(completed — copied by exact line range via `sed`, in the stated dependency order, each
      under a "Block N of 4 — origin ..." sub-heading)*
- [x] Carry all **eight** `set_option maxHeartbeats 1600000 in` lines verbatim, each still directly
      prefixing its declaration (`InteriorGateGeneralK` 1671/1733/1809/1893/2281/2466,
      `ExteriorGateAssembleK` 568, `KampPrior` 1082). Do not collapse them into a file-level option.
      *(completed — count independently re-derived per range before copying: 6 + 1 + 1 + 0 = 8,
      confirming the plan's amendment over the audit's undercount of two. Archive greps 8.)*
- [x] Carry all docstrings and section-header comments verbatim, **including** the two prose records
      at `InteriorGateGeneralK.lean:1646-1670` and `CarrierKv.lean:503-516` — they arrive
      automatically as part of their enclosing blocks, and their presence here is what makes Phase 3
      safe to run before Phase 4. *(completed — both records verified present in the archive by
      distinctive-phrase grep. The module docstring additionally indexes both records by name and
      origin so a reader can find them in a 1,862-line file.)*
- [x] Wrap the body in the `namespace FormalSystem.Metalogic.WeakCanonical.Kamp` / `end` pairing used
      by the source files. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean` - new; ~1,750+ lines
  (1,736 copied plus header)

**Verification**:

- The archive contains all 30 declaration names from the audit's excision set. Grep each of the 30
  names and confirm exactly one defining occurrence in the new file.
- The archive contains **zero** occurrences of `igOffFiber`, `kvEFiber`, or `kvE_deepOnFiber` as
  *definitions* (incidental references inside copied proof bodies are expected and fine).
- Eight `set_option maxHeartbeats 1600000 in` lines are present.
- Both prose records are present verbatim (grep for a distinctive phrase from each).
- The four live source files are **byte-identical to their Phase 1 state** — `git diff --stat` shows
  only the new untracked file.

---

### Phase 3: Delete the four blocks [COMPLETED]

**Goal**: Excise the island from the live tree by exact line range, one file per edit. This is the
highest-risk phase; it is deliberately mechanical.

**Absolute prohibition**: do not delete by name, by `grep`, by `*Fib` pattern, or by any
search-driven sweep. `igOffFiber` and the `kvEFiber*` / `kvE_deepOnFiber_*` families share the
suffix and are LIVE. Delete by verified line block only.

**Tasks**:

- [x] For each file, immediately before cutting, re-confirm the range's first line and the first
      retained line after the range by **content string match**, using the plan-time verification
      table. If either does not match, stop and report drift rather than guessing.
      *(completed — all four re-confirmed by an assert-or-abort script that additionally checked
      each file's pre-cut line count. Zero drift; no line number was trusted without a content
      match.)*
- [x] Delete `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierKv.lean`
      lines 503-616 (114 lines). Retained after: `end FormalSystem.Metalogic.WeakCanonical.Kamp`.
      File goes 617 → 503 lines. *(completed — 503 lines)*
- [x] Delete
      `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`
      lines 1424-2550 (1,127 lines). This is the file's entire tail below the arity-1 consumability
      `example` at :1417-1422. **Retain the `end` at old-2551** — it closes the `noncomputable
      section` opened at :197 — and the trailing namespace `end`. File goes 2553 → 1426 lines.
      *(completed — 1426 lines; tail verified as `end` followed by
      `end FormalSystem.Metalogic.WeakCanonical.Kamp`)*
- [x] Delete
      `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean`
      lines 447-790 (344 lines). Retained after: `end FormalSystem.Metalogic.WeakCanonical.Kamp`.
      File goes 791 → 447 lines. *(completed — 447 lines)*
- [x] Delete `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean` lines 1082-1232 (151 lines).
      Range begins at a `set_option maxHeartbeats 1600000 in`; retained after is the
      `/-- **F-i positive exhibit...` docstring. File goes 1985 → 1834 lines.
      *(completed — 1834 lines)*
- [x] Run `lake build` and fix nothing but genuine fallout of the cut (a stray unused `import` or
      `open`). If the build reports a missing identifier that is NOT an island member, stop — that
      means a live declaration was caught. *(completed — `lake build` and `lake build BimodalTest`
      both exit 0 on the first attempt. **Zero fixes were required**: no stray import, no stray
      open, no missing identifier. The island was genuinely closed, confirming the audit.)*

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:

- `.../NfMultiAnchorBridge/CarrierKv.lean` - delete 503-616
- `.../NfMultiAnchorBridge/InteriorGateGeneralK.lean` - delete 1424-2550
- `.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` - delete 447-790
- `.../Kamp/KampPrior.lean` - delete 1082-1232

**Verification**:

- Post-deletion line counts are exactly 503 / 1426 / 447 / 1834. Total removed: 1,736.
- `lake build` and `lake build BimodalTest` both exit 0.
- **Live-survivor assertions** — each of these must still be present and defined in the live tree:
  `igOffFiber`, `igFoldBit`, `igFoldBit_realize_iff`, `kvEFiber`, `kvEDeepOnFiber`,
  `bracketEndCharKv`, `bracketEndCharKvExt`, `bracketEndChar_kv_correct_prior`,
  `kampPrior_site_rungK_gate_match`, `InteriorGateAllK`.
- **`open private` survivor assertions**: `InteriorGateGeneralK.lean` still contains both `open
  private k1v_*` lines and `ExteriorGateAssembleK.lean` still contains its `open private
  k1v_reconstruct_nf3` line.
- `InteriorGateGeneralK.lean` still ends with the `end` closing the `noncomputable section` followed
  by `end FormalSystem.Metalogic.WeakCanonical.Kamp`.
- Grepping the four files for any of the 30 excised declaration names returns zero defining
  occurrences.

---

### Phase 4: Relocate the two prose records [COMPLETED]

**Goal**: Restore, beside the LIVE code each one documents, a condensed version of the two records
that were carried away with the deleted blocks. These are records about live declarations; losing
them would erase machine-confirmed findings.

**Anchor rule**: locate both anchors **by declaration content**, not by any line number — including
the line numbers in this plan. In-file prose in this tree already cites `bracketEndCharKv` at `:238`
and `igFoldBit_realize_iff` at `:563` when they actually live at `:248` and `:611`. Phase 3 has also
shifted nothing above these anchors, but confirm by content regardless.

**Tasks**:

- [x] **Record A — circularity.** Attach a condensed 3-5 line note to `igFoldBit_realize_iff` in
      `InteriorGateGeneralK.lean` (live, currently `:611`). Content: this bridge requires the deep
      render `NfEvalNf M (k+1) 3 [w,x,t] qnf` as an *explicit hypothesis*, which makes the firing
      route for the already-retired `kampPrior_hreal_supply` machine-confirmed **circular**.
      Cross-reference `Boneyard/InteriorHrealSupplyK.lean` (where that lemma now lives) and
      `Boneyard/Arity4CharStackK.lean` (where the full original record now lives). Do not restate
      the deleted derivation; point at it.
      *(completed — 7-line `/-! ## Circularity record for the bridge below -/` block inserted
      directly above the `igFoldBit_realize_iff` docstring. Anchor located by content match on the
      docstring text, not by line number; the declaration was confirmed at `:611`, NOT the `:563`
      that the tree's own prose cites — the plan's stale-citation warning was accurate.)*
- [x] **Record B — M1/F1 fold-information loss.** Attach a condensed note near `bracketEndCharKv` in
      `CarrierKv.lean` (live, currently `:248`). Content: the frozen `bracketEndCharKv` folds each
      marked arity-4 fiber down to `(nf0ZoneSpec (atomAssgn sub), nfkProjFresh sub)` — the F1
      information loss constituting the M1 refutation record. Cross-reference
      `Boneyard/Arity4CharStackK.lean`. **Drop** the sentence "the M2 fix is the sibling carrier
      below" — that clause is about the archived sibling and belongs only with the archive.
      *(completed — 7-line `/-! ## M1 refutation record — the F1 fold-information loss -/` block
      inserted directly above the `open Classical in` / docstring pair heading `bracketEndCharKv`.
      Anchor located by content; declaration confirmed at `:248`, NOT the `:238` the tree's prose
      cites. The "M2 fix is the sibling carrier below" clause was DROPPED as directed — the note
      says only that the de-folded sibling is retired and unwired in the archive.)*
- [x] Do not cite task numbers in either note (per `.claude/rules/no-task-references-in-deliverables.md`);
      cite the declaration names and Boneyard filenames, which are durable anchors.
      *(completed — grep for `task [0-9]+` over the added lines returns 0. Both notes cite only
      declaration names and Boneyard filenames.)*

**Timing**: 45 minutes

**Depends on**: 3

**Files to modify**:

- `.../NfMultiAnchorBridge/InteriorGateGeneralK.lean` - add condensed circularity note at
  `igFoldBit_realize_iff`
- `.../NfMultiAnchorBridge/CarrierKv.lean` - add condensed fold-loss note at `bracketEndCharKv`

**Verification**:

- Both notes exist, each adjacent to the declaration it documents, each naming the archive file.
- Each note is 3-8 lines — condensed, not a re-paste of the original 25-line / 14-line records.
- Neither note contains a task number.
- `lake build` still exits 0 (comment-only edits, but confirm no docstring/comment delimiter was
  mismatched).

---

### Phase 5: Verify against the Phase 1 baseline [NOT STARTED]

**Goal**: Prove the change is inert with respect to every measured signal. Comparison is against
`baseline-prestate.txt`, never against a remembered expectation.

**Tasks**:

- [ ] `lake build` exits 0. `lake build BimodalTest` exits 0.
- [ ] Re-run the Phase 1 `lake env lean` probe, **keeping the bogus-identifier control**. Confirm:
      `completeness_discrete` reports `[propext, Classical.choice, Quot.sound]`;
      `kampPriorExpressiveCompleteness` reports `[propext, Classical.choice, Quot.sound]`; neither
      shows `sorryAx`; the control still errors with `unknownIdentifier`.
- [ ] Add to the probe `#check` lines asserting the five live survivors still resolve
      (`igOffFiber`, `igFoldBit_realize_iff`, `kvEFiber`, `bracketEndCharKv`,
      `kampPrior_site_rungK_gate_match`) and — as a negative control — that at least two excised
      names (`bracketEndCharKvFib`, `kampPrior_site_rungKFib_gate_match`) now **fail** with
      `unknownIdentifier`.
- [ ] Re-run the sorry census; confirm it is still 5 and in the same locations.
- [ ] Re-run `bash scripts/check-module-invariants.sh`. Compare **check by check** against the
      baseline. The pass criterion is *no check moved from green to red*, not *all checks green*:
      C3 is expected to remain red from concurrent `Soundness.lean` work and its redness here is
      neither caused nor fixable by this task.
- [ ] Confirm C4 (dangling imports), C6 (unreachable-module manifest), and C8 (aggregator
      convention) are unchanged — all three prune `Boneyard`, so the new archive file is invisible
      to them.
- [ ] Confirm C7's informational live line count dropped by ~1,736 and the live file count is
      unchanged (a file was added under `Boneyard/`, which C7 prunes).
- [ ] Record the excision set — the 30 declarations — in the implementation summary, as the task's
      DONE-WHEN requires.

**Timing**: 45 minutes

**Depends on**: 4

**Files to modify**:

- `specs/407_retire_unwired_arity4_char_stack/summaries/01_boneyard-arity4-char-stack-summary.md` -
  new; includes the 30-declaration excision set and the baseline comparison table

**Verification**:

- A written baseline-vs-post comparison table exists in the summary covering: two build exit codes,
  two axiom sets, sorry census, every C1-C10 result, C7 line delta.
- No check moved green → red.
- The summary lists all 30 excised declarations.

---

### Phase 6: Boneyard README housekeeping [NOT STARTED]

**Goal**: Keep the archive's own inventory coherent. This is courtesy, not enforcement —
`scripts/readme-lint.sh` checks 1 and 2 both skip any path containing `Boneyard`, so nothing here
is gated by a lint.

**Tasks**:

- [ ] Update the file/line summary table in
      `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (currently "62 files, 27,394
      lines") to reflect the added `Arity4CharStackK.lean`. Recount rather than arithmetic-guess.
- [ ] Add `Arity4CharStackK.lean` to the retirement narrative alongside the three existing members
      of this same stack — `InteriorHrealSupplyK.lean`, `SeamPairRefutationProbe.lean`, and
      `ZoneSeamCrossContextProbe.lean` — noting that those three already name eight of this island's
      symbols, which is the coherence argument for archiving rather than raw-deleting.
- [ ] Do not cite task numbers in the README.

**Timing**: 20 minutes

**Depends on**: 5

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` - inventory table and retirement
  narrative

**Verification**:

- The README table count matches an actual recount of the directory.
- `bash scripts/readme-lint.sh` exits as it did in the Phase 1 baseline.
- `Arity4CharStackK.lean` appears in the retirement narrative.

---

## Testing & Validation

- [ ] `lake build` exits 0.
- [ ] `lake build BimodalTest` exits 0.
- [ ] `#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete` reports exactly
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] `#print axioms FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness`
      reports exactly `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] The `lake env lean` probe includes a bogus-identifier control that errors with
      `unknownIdentifier` (do not trust `lean_run_code` for existence or axiom claims in this
      repository).
- [ ] Live sorry census unchanged at 5 (4 in `Soundness.lean`, 1 in `Transfer.lean`).
- [ ] All five live-survivor `#check`s resolve; both excised-name `#check`s fail as expected.
- [ ] `scripts/check-module-invariants.sh`: no check moved green → red versus the Phase 1 baseline
      (C3 expected to remain red, pre-existing).
- [ ] Post-deletion line counts: `CarrierKv.lean` 503, `InteriorGateGeneralK.lean` 1426,
      `ExteriorGateAssembleK.lean` 447, `KampPrior.lean` 1834.
- [ ] `FormalSystem/Metalogic/Soundness.lean` is untouched (`git diff` shows no change).

## Artifacts & Outputs

- `specs/407_retire_unwired_arity4_char_stack/plans/01_boneyard-arity4-char-stack.md` (this file)
- `specs/407_retire_unwired_arity4_char_stack/baseline-prestate.txt` (Phase 1 baseline record)
- `specs/407_retire_unwired_arity4_char_stack/summaries/01_boneyard-arity4-char-stack-summary.md`
  (includes the 30-declaration excision set, as DONE-WHEN requires)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean` (new archive)
- Four modified live files under `Kamp/` and `Kamp/NfMultiAnchorBridge/`
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (inventory update)

## Rollback/Contingency

- Commit per phase (`task 407 phase {P}: {name}`) so any phase can be reverted independently. Phase
  2 in particular is a pure addition and is safe to land alone.
- If Phase 3's `lake build` reports a missing identifier that is **not** one of the 30 island
  members, a live declaration was caught. Revert that single file's deletion (`git checkout` the
  file from the phase-2 commit), re-confirm the range boundaries by content, and report the drift —
  do not attempt to patch around the break by re-adding the declaration.
- If the axiom sets change or `sorryAx` appears, revert the whole deletion series to the Phase 2
  commit; the archive can stay. An axiom-set change means a live proof term depended on something
  cut, which contradicts the audit and requires re-auditing before retrying.
- Because Phase 2 lands the archive first, no phase-3-or-later rollback can lose the excised code:
  it exists in `Boneyard/Arity4CharStackK.lean` from the end of Phase 2 onward.
- Snapshot before any destructive git operation on a dirty tree
  (`bash .claude/scripts/git-snapshot.sh`); never `git reset --hard` over uncommitted work.
