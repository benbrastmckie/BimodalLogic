# Implementation Plan: Task #393

- **Task**: 393 - review_archivable_sorries_to_boneyard
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/393_review_archivable_sorries_to_boneyard/reports/01_sorry-archivability-verdicts.md`
- **Artifacts**: plans/01_archive-dead-sorries-boneyard.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Retire 11 of the repository's 12 live `sorry` instances by moving three verified-dead
declaration closures into `Theories/Bimodal/Boneyard/`, following the established Boneyard
conventions (coherent unit move, subdirectory README, root inventory row, no live importer of
any archived path). The twelfth sorry — `WeakCanonical.countermodel_discrete` — is the sole
`sorryAx` source reaching `BXCanonical.completeness` and is explicitly **kept and not touched**;
proving it is recorded as a follow-up recommendation, not attempted here. A final phase corrects
two stale in-repo claims that are wrong today independent of any archival.

No proof work is performed. Every phase is a move-plus-bookkeeping operation validated by
`lake build`.

### Research Integration

The research report supplies machine-verified verdicts that this plan takes as settled and does
not re-derive:

- A whole-environment `Lean.collectAxioms` scan over 19,442 `Bimodal.*` constants found exactly
  47 `sorryAx`-tainted declarations, partitioning into three closed islands (Appendix A of the
  report). The archive units below are islands 1 and 2 verbatim.
- Island 3 (`countermodel_discrete`, `completeness`, `completeness'`) is the live obligation and
  is out of scope.
- Category (c) "keep as explicit axiom" is rejected for all three `..._axiom` declarations: they
  have zero live consumers, and their proof route reduces to the T-axiom for `G`/`H`, already
  recorded as unsound in `Boneyard/TAxiomDependentCode/`.
- Reverse-dependency graphs built from `ConstantInfo.value?` are unreliable in this repo under
  Lean 4.33's module system (imported theorem bodies do not cross module boundaries). Use
  `collectAxioms` plus word-boundary grep. Do not reintroduce a `value?` traversal.

Grounding verified against the tree while planning (line numbers are current-tree, and the
implementer must re-confirm them before cutting, since each excision shifts later ones):

| Fact | Evidence |
|------|----------|
| `SuccExistence.lean` has exactly one live importer | `Core/RestrictedMCS/Basic.lean:13`; the other five importers are all under `Boneyard/` (never built) |
| The 7 `SuccRelation.lean` names have zero code consumers | Only comment hits, in `TemporalCoherence.lean:471` and `UntilSinceCoherence.lean:42` |
| The chronicle chain is 8 declarations across two files | 7 in `Chronicle/ChronicleToCountermodel.lean`, plus `countermodel_discrete_reynolds` at `WeakCanonical/Transfer.lean:1222` |
| `countermodel_discrete_reynolds` calls `_tc`/`_buc`/`_fuc` | `Transfer.lean:1265,1269,1271` — so the Transfer-side head must move in the *same* phase as the Chronicle-side declarations |
| `cantor_bfmcs_discrete_restricted_buc` is sorry-free and survives | Its only two consumers (`dd_countermodel_chronicle_discrete:1878`, `Transfer.lean:1269`) both leave; it becomes a sorry-free orphan |
| Module names are `Bimodal.*` | `lakefile.lean` sets `srcDir := "Theories"`, `roots := #[\`Bimodal]` |

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this task (no `roadmap_path` in the delegation context).

## Goals & Non-Goals

**Goals**:
- Reduce live `sorry` count from 12 to 1 by archiving three verified-dead units.
- Leave `WeakCanonical.countermodel_discrete` (Transfer.lean:1283) live and unmodified.
- Satisfy the Boneyard Maintenance Standard for every unit: coherent move, subdirectory README,
  root `Boneyard/README.md` Directory Inventory row, zero live importers of archived paths.
- Correct the two stale in-repo claims identified by research.
- Record the `countermodel_discrete` proof obligation as an explicit follow-up recommendation.

**Non-Goals**:
- Proving `countermodel_discrete`, or scoping either candidate route (Base→Discrete MCS
  transfer, or a Henkin discrete canonical model). That is a task in its own right.
- Converting any `..._axiom` declaration into a declared Lean `axiom` (rejected by research).
- Cascade-removing sorry-free declarations that become orphaned by these moves
  (`cantor_bfmcs_discrete_restricted_buc` and anything below it). Orphan cleanup is a separate,
  optional concern; expanding the diff to chase it increases risk without retiring a sorry.
- Repairing stale `import` lines inside Boneyard files. Boneyard imports are historical text,
  not build edges (root `Boneyard/README.md`, "Build Policy: Never Compiled").
- Adding a row to the root README's Task Cross-References table, or putting a task number in the
  Directory Inventory `Task` column. Use `--`, matching the most recent entries
  (`DeadChronicleGapElimination`, `RestrictedMCSDeferral`, `SorriedDeclExcisions`) and
  `.claude/rules/no-task-references-in-deliverables.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Chronicle closure grows during excision (the `StaviDiscretePath` precedent grew 16→24 decls) | H | M | Phase 3 removes the *head* first and rebuilds; every `unknown identifier` from that build names a survivor that must join the closure. Iterate to a fixpoint before declaring the phase done. |
| Excising `_tc`/`_fuc` from Chronicle without removing `countermodel_discrete_reynolds` breaks `lake build` | H | M | They are in the same phase, with a mandated sub-step order (heads before tails). Never commit a red tree. |
| Cutting by stale line numbers after an earlier cut shifts the file | M | H | Locate every region by declaration name and section header, never by the line numbers quoted in this plan. Re-`grep -n` before each cut. |
| Accidentally archiving `countermodel_discrete` (adjacent to `countermodel_discrete_reynolds` in Transfer.lean) | H | L | Phase 3 verification asserts `countermodel_discrete` still elaborates and `completeness` still builds. Name-check, not position-check. |
| `lake build` cache masks a sorry-count change | M | M | Measure sorries textually (command in Phase 0 of Phase 1) rather than by counting build warnings; corroborate with `#print axioms` at Phase 5. |
| Sorry-free orphans left behind trigger reviewer confusion | L | H | Each subdirectory README explicitly names the orphans it created and states they were deliberately left live. |
| Boneyard/README.md edit conflicts between phases | M | M | Phases are strictly sequential; each phase updates the root README as its own last bookkeeping step. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is a deliberate linear chain,
not a wide DAG: Phases 1 and 2 are independent at the Lean level (the seven `SuccRelation`
names have only comment references, including from `SuccExistence.lean`), but all four archival
phases write `Theories/Bimodal/Boneyard/README.md`, and Phases 3 and 4 both write
`WeakCanonical/Transfer.lean`. Serializing removes every write conflict at negligible cost.
Failure isolation is preserved by ordering lowest-risk first: a failure in Phase 3 leaves the 10
sorries retired by Phases 1-2 committed and green.

---

### Phase 1: Archive `Bundle/SuccExistence.lean` (whole file, 3 sorries) [COMPLETED]

**Goal**: Move the entire dead successor/predecessor-seed construction to the Boneyard, remove
its one stale live import, and establish the sorry-count baseline for the whole task.

**Tasks**:
- [x] Record the baseline. Run `lake build` and confirm it is green. Then count live sorries:
      `grep -rnE '(^|[^A-Za-z0-9_.])sorry([^A-Za-z0-9_]|$)' Theories/ --include=*.lean | grep -v '/Boneyard/'`
      Confirm the count is **12**. If it is not, stop and reconcile against the research report's
      per-sorry table before touching anything.
- [x] Create `Theories/Bimodal/Boneyard/BundleSuccessorSeed/`.
- [x] `git mv Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean Theories/Bimodal/Boneyard/BundleSuccessorSeed/SuccExistence.lean`
      (use `git mv` so `git log --follow` keeps working, per the root README's Git Retrieval section).
- [x] In the moved file, insert an `ARCHIVED (Boneyard) — never compiled.` docstring after the
      import block (imports must precede all commands in Lean 4). It must name the file's origin,
      state that all 72 declarations have zero live consumers, identify the three sorries
      (`constrained_successor_seed_consistent`, `successor_deferral_seed_consistent_axiom`,
      `predecessor_deferral_seed_consistent_axiom`), state that all three reduce to
      `g_content u ⊆ u` / `h_content u ⊆ u` (the T-axiom for `G`/`H`, unsound under the current
      irreflexive open-guard semantics), and end with `Do not import from live code.`
      Leave the file's import lines verbatim — do not repair them.
- [x] Add `#exit` immediately after that docstring. The file is unreachable from any lakefile
      root and would not be built regardless; `#exit` makes the never-built intent explicit and
      matches the `SorriedDeclExcisions` convention.
- [x] Delete the now-dead import line `import Bimodal.Metalogic.Bundle.SuccExistence` from
      `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean` (currently line 13). This is the
      only live importer; nothing in that file uses a declaration from `SuccExistence`.
- [x] Write `Theories/Bimodal/Boneyard/BundleSuccessorSeed/README.md`: purpose, file inventory
      (1 file, ~1,178 lines, 72 decls, 3 sorries), why dead (zero live consumers anywhere; the
      shared root cause with the `SuccRelation` Until/Since block archived in Phase 2), the
      explicit rejection of axiomatizing the two `..._axiom` declarations and why, and a pointer
      to the sibling `../RestrictedMCSDeferral/`, which archives the deferral-restricted variant
      of this same construction.
- [x] Add a `BundleSuccessorSeed` row to the Directory Inventory table in
      `Theories/Bimodal/Boneyard/README.md`, matching the existing column format
      (Directory / Files / Lines / Archived From / Why Archived / Task). Use `--` in the Task
      column. Update the `**Total**` row's file and line counts.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — moved out (deleted from live tree)
- `Theories/Bimodal/Boneyard/BundleSuccessorSeed/SuccExistence.lean` — new (moved), archive header + `#exit`
- `Theories/Bimodal/Boneyard/BundleSuccessorSeed/README.md` — new
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean` — remove one import line
- `Theories/Bimodal/Boneyard/README.md` — new inventory row, updated totals

**Verification**:
- `lake build` is green with no new errors.
- The live sorry count (command above) is **9**, down from 12.
- `grep -rn "Bundle.SuccExistence" Theories/ Tests/ --include=*.lean | grep -v '/Boneyard/'`
  returns nothing.
- `git status` shows the move as a rename, not add+delete.

---

### Phase 2: Excise the Until/Since step block from `Bundle/SuccRelation.lean` (7 sorries) [COMPLETED]

**Goal**: Remove the seven dead Until/Since-step theorems from `SuccRelation.lean` as a
`SorriedDeclExcisions`-style declaration excision, leaving the rest of the file live.

**Tasks**:
- [x] Locate the block by name, not by line number. It runs from the
      `/-! ## Until/Since Step Properties ... -/` section header through the end of
      `h_content_subset_mcs`, immediately before `end Bimodal.Metalogic.Bundle`. The seven
      declarations, in order: `until_unfold_in_mcs`, `since_unfold_in_mcs`,
      `until_persists_through_succ`, `or_until_in_mcs`, `or_since_in_mcs`,
      `g_content_subset_mcs`, `h_content_subset_mcs`.
- [x] Re-verify zero code consumers before cutting: for each of the seven names run
      `grep -rnw "<name>" Theories/ Tests/ --include=*.lean | grep -v '/Boneyard/'` and confirm
      every hit outside `SuccRelation.lean` is inside a docstring or `--` comment. (Expected:
      `TemporalCoherence.lean:471` and `UntilSinceCoherence.lean:42`, both prose.)
- [x] Create `Theories/Bimodal/Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` following
      that directory's README structure **in this exact order**: (1) imports verbatim — copy
      `SuccRelation.lean`'s four `import` lines as-is; (2) an
      `ARCHIVED (Boneyard) — never compiled.` docstring naming all seven declarations, the source
      file, and the reason (proved under BX1/BX8/BX9, all removed as unsound under the current
      open-guard `(t,s)` irreflexive semantics; `g_content_subset_mcs` and `h_content_subset_mcs`
      are not merely unproven but *false* under irreflexive semantics — they are the T-axiom for
      `G`/`H` recorded as unsound in `../TAxiomDependentCode/`; the original proofs live in
      `../OpenGuardInvalid/`), ending with `Do not import from live code.`; (3) `#exit`;
      (4) the seven declarations copied verbatim, including the section header comment.
- [x] Delete the block from `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`, preserving the
      trailing `end Bimodal.Metalogic.Bundle`.
- [x] Update the stale prose references that now name archived declarations:
      `Bundle/TemporalCoherence.lean:471` and `Bundle/UntilSinceCoherence.lean:42` should point at
      `Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` rather than at `SuccRelation.lean`.
- [x] Add a row to the File Inventory table in
      `Theories/Bimodal/Boneyard/SorriedDeclExcisions/README.md`
      (`BundleUntilSinceStep.lean` | 7 | 7 | `Bundle/SuccRelation.lean`). Also update that
      README's "Relationship to Active Code" section, which currently asserts that the
      `chronicle_gap_contradiction`/`succ_cofinal`/`limitDomSubtype_isSuccArchimedean` trio must
      not be moved — add a forward note that Phase 3 supersedes that entry.
- [x] Update the `SorriedDeclExcisions` row in the root `Boneyard/README.md` Directory Inventory
      (files 5 → 6, line count) and the `**Total**` row.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — delete the Until/Since step block
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` — new
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/README.md` — inventory row, superseded note
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — one prose reference
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — one prose reference
- `Theories/Bimodal/Boneyard/README.md` — updated inventory row and totals

**Verification**:
- `lake build` is green with no new errors.
- Live sorry count is **2**, down from 9.
- Each of the seven names appears in `Theories/` outside `Boneyard/` only inside comments (if at
  all): `for n in <names>; do grep -rnw "$n" Theories/ Tests/ --include=*.lean | grep -v '/Boneyard/'; done`
- `SuccRelation.lean` still ends with `end Bimodal.Metalogic.Bundle` and its live consumers
  (`UntilSinceCoherence.lean`, `CanonicalTaskRelation.lean`) still build.

---

### Phase 3: Excise the `chronicle_gap_contradiction` chain as one unit (1 sorry) [COMPLETED]

**Goal**: Move the entire 8-declaration `sorryAx` island — 7 declarations in
`Chronicle/ChronicleToCountermodel.lean` plus `countermodel_discrete_reynolds` in
`WeakCanonical/Transfer.lean` — into the existing
`Boneyard/DeadChronicleGapElimination/`, retiring the last archivable sorry.

This is the highest-risk phase. The whole closure must move together: piecemeal excision breaks
`lake build`, exactly as the in-file warning at `ChronicleToCountermodel.lean:62-71` says. That
warning's *conclusion* ("keep them") is wrong only because its stated reason — a consumer named
`countermodel_discrete_enriched` — no longer exists.

**The closure** (Appendix A island 2, each edge re-verified while planning):

```
chronicle_gap_contradiction  (private, ChronicleToCountermodel.lean; sole `sorry` token)
  → succ_cofinal                        (private; call site inside succ_cofinal's proof)
  → limitDomSubtype_isSuccArchimedean   (call site inside its proof)
  → succ_embed_surjective               (letI binding inside its proof)
  → cantor_bfmcs_discrete_restricted_tc  and  cantor_bfmcs_discrete_restricted_fuc
  → dd_countermodel_chronicle_discrete   (0 consumers)
  → countermodel_discrete_reynolds       (Transfer.lean; 0 consumers)
```

Two adjacent private helpers, `limit_f_some_future_of_lt` and `limit_f_not_G_neg_of_mem`, are
sorry-free and sit inside the same contiguous section; they have no call sites outside that
section and should move with it.

**Tasks**:
- [x] **Sub-step 3.1 — remove the heads.** Delete `countermodel_discrete_reynolds` from
      `Transfer.lean` (the theorem plus its two preceding `/-! ... -/` doc blocks, the second of
      which is the stale "is now sorry-free" claim) and `dd_countermodel_chronicle_discrete`
      plus its `/-! ## Discrete Countermodel -/` header from the end of
      `ChronicleToCountermodel.lean`. Preserve the trailing `end` lines of both files and the
      trailing `-- mcs_mixed_case_absurd ... moved to MCSMixedCase.lean` comment. **Do not touch
      `countermodel_discrete`, which immediately follows `countermodel_discrete_reynolds` in
      Transfer.lean and must stay.** Run `lake build`; it must be green. Sorry count is unchanged
      at 2 — that is expected, the sorry token is still upstream. Commit this green sub-step.
- [x] **Sub-step 3.2 — remove the tails.** Delete `cantor_bfmcs_discrete_restricted_tc` and
      `cantor_bfmcs_discrete_restricted_fuc` (contiguous, with their doc headers, ending just
      before the `/-! ## Discrete Countermodel` region removed in 3.1), then
      `succ_embed_surjective`, then the contiguous
      `/-! ## Chronicle Gap Elimination via Model Surgery` section through the end of
      `limitDomSubtype_isSuccArchimedean` (containing `limit_f_some_future_of_lt`,
      `limit_f_not_G_neg_of_mem`, `chronicle_gap_contradiction`, `succ_cofinal`,
      `limitDomSubtype_isSuccArchimedean`), stopping immediately before the
      `/-! ## Collapse-Based Discrete Pipeline` header. Re-`grep -n` for each declaration name
      before cutting — earlier cuts shift every later line number.
- [x] **Sub-step 3.3 — close the fixpoint.** Run `lake build`. Every `unknown identifier` or
      `unknown constant` error names a *survivor* that referenced something now archived; add it
      to the closure and repeat until green. Expect growth (the `StaviDiscretePath` precedent in
      the root README grew from 16 to 24 declarations this way). Record the final closure size. *(no growth: `lake build` was green on the first attempt after the tails came out; final closure = 10 declarations, the 8 audited plus the two adjacent sorry-free private helpers)*
- [x] **Sub-step 3.4 — deliberate non-goal check.** `cantor_bfmcs_discrete_restricted_buc` is
      sorry-free and both its consumers left; it is now an orphan. **Leave it live.** Same for
      anything below it (`cantor_bfmcs_discrete`, `rooted_succ_discrete_fmcs`,
      `succ_embed_squeeze`, `succ_embed_squeeze_strict`, …). Removing sorry-free orphans widens
      the diff without retiring a sorry. Record the orphan list for the README.
- [x] Create the archive file, e.g.
      `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`,
      following the `SorriedDeclExcisions` structure: imports verbatim (union of the two source
      files' import blocks), `ARCHIVED (Boneyard) — never compiled.` docstring, `#exit`, then the
      code verbatim with a per-declaration source-file comment banner separating the
      `ChronicleToCountermodel.lean` declarations from the `Transfer.lean` one.
- [x] Rewrite the `/-! ## Gap Elimination and IsSuccArchimedean — status -/` block that remains
      near the top of `ChronicleToCountermodel.lean` into a tombstone comment: the chain has been
      archived; its former retention rationale cited `countermodel_discrete_enriched`, which was
      itself archived to `Boneyard/DeadChronicleGapElimination/TransferDead.lean`; the live
      discrete path goes through `countermodel_discrete_reynolds_v2`
      (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`), which bypasses `succ_embed_surjective`
      and the `IsSuccArchimedean` requirement entirely.
- [x] Update `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/README.md`. Its current text
      already *lists* `chronicle_gap_contradiction` and `succ_cofinal` as archived — an earlier
      pass copied them without excising them from live code. State that plainly, list the new
      file and its declarations, name the orphans this excision created and that they were
      deliberately left live, and correct the "Sorry Chain" section, which claims
      `succ_embed_surjective` "still in live code, now uses axiom instead" (it now moves too, and
      it never used an axiom).
- [x] Update the `DeadChronicleGapElimination` row in the root `Boneyard/README.md` Directory
      Inventory (files 2 → 3, line count, Archived From now spanning both
      `BXCanonical/Chronicle/` and `WeakCanonical/`) and the `**Total**` row.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — excise 7 declarations; rewrite the status block
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — excise `countermodel_discrete_reynolds` and its two doc blocks
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean` — new
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/README.md` — corrected and extended
- `Theories/Bimodal/Boneyard/README.md` — updated inventory row and totals
- (possibly) additional survivors surfaced by sub-step 3.3

**Verification**:
- `lake build` is green with no new errors. Sub-steps 3.1 and 3.2/3.3 each end green; 3.1 leaves
  the sorry count unchanged at 2 (expected), and the phase as a whole reduces it to **1**.
- The only remaining live `sorry` is `WeakCanonical.countermodel_discrete` in `Transfer.lean`.
- `countermodel_discrete` still elaborates and `BXCanonical.completeness` still builds — check by
  name, never by position.
- Each of the 8 closure names has zero code references outside `Boneyard/`:
  `for n in chronicle_gap_contradiction succ_cofinal limitDomSubtype_isSuccArchimedean succ_embed_surjective cantor_bfmcs_discrete_restricted_tc cantor_bfmcs_discrete_restricted_fuc dd_countermodel_chronicle_discrete countermodel_discrete_reynolds; do grep -rnw "$n" Theories/ Tests/ --include=*.lean | grep -v '/Boneyard/'; done`
  Remaining hits must all be prose (and are addressed in Phase 4).
- `completeness_dense` and `completeness_discrete` are unchanged and still `sorryAx`-free.

---

### Phase 4: Correct the stale in-repo claims [COMPLETED]

**Goal**: Fix documentation that is factually wrong today, and re-point prose that now names
archived declarations. No Lean declarations change.

The load-bearing correction is the `countermodel_discrete_reynolds` / `..._reynolds_v2`
conflation: the sorry-free discrete theorem is **`countermodel_discrete_reynolds_v2`**
(`WeakCanonical/IntegerModel/ReynoldsBridge.lean`). `countermodel_discrete_reynolds` was
`sorryAx`-tainted and is archived by Phase 3.

**Tasks**:
- [x] `WeakCanonical/Transfer.lean` — the module docstring near the top calls
      `countermodel_discrete_reynolds` "(active path)". Correct it to name
      `countermodel_discrete_reynolds_v2` as the live discrete path and note that
      `countermodel_discrete_reynolds` is archived. Also fix the
      `/-! ## countermodel_discrete — DEPRECATED (sorry) -/` block, which says the discrete
      completeness theorem "uses `countermodel_discrete_reynolds`" — it uses `..._v2`. Keep the
      block's accurate content: `countermodel_discrete`'s BX-pipeline route is provably
      unavailable (`succ_cofinal` refuted by the ℤ+ℤ counterexample), so the sorry must be closed
      by a different construction, not by repairing that route.
- [x] `BXCanonical/Completeness.lean` — the `### completeness_discrete` section correctly names
      `countermodel_discrete_reynolds_v2` and correctly states that `completeness_discrete` is
      `sorryAx`-free; verify this against the current text and change it only if it is actually
      wrong. What *does* need updating in that file is the nearby paragraph asserting that "the
      `chronicle_gap_contradiction` sorry (ChronicleToCountermodel.lean) is dead code" — the
      declaration no longer lives there; re-point it to the Boneyard path. Add an explicit
      `..._reynolds` vs `..._reynolds_v2` disambiguation only if the surrounding prose is
      genuinely ambiguous about which theorem is clean.
- [x] `WeakCanonical/IntegerModel/ReynoldsBridge.lean` — the module docstring narrates the
      `chronicle_gap_contradiction → succ_cofinal → limitDomSubtype_isSuccArchimedean →
      succ_embed_surjective → ..._tc/fuc` chain as the thing it bypasses. That is still true and
      worth keeping; annotate it as `(archived — see Boneyard/DeadChronicleGapElimination/)`.
- [x] `BXCanonical/Chronicle/MCSMixedCase.lean` and `WeakCanonical/WeakCanonical.lean` and
      `WeakCanonical/ReflexiveCanonical.lean` — each mentions the chain in prose. Verify each
      reads correctly post-archival; annotate with the Boneyard location where it does not.
- [x] Sweep for any remaining prose reference to an archived name that implies the declaration is
      live, using the Phase 3 verification grep, and fix each.

**Timing**: 45 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — module docstring, deprecation block
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — chronicle dead-code paragraph
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — bypass narration
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean` — prose reference
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` — prose reference
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` — prose reference

**Verification**:
- `lake build` is green with no new errors; live sorry count is still **1** (unchanged — this is
  a documentation-only phase, and the reduction achieved in Phases 1-3 must be preserved).
- No live file asserts that `countermodel_discrete_reynolds` is sorry-free or on the active path.
- No live file names an archived declaration without indicating it is archived.

---

### Phase 5: Final verification and follow-up recommendation [COMPLETED]

**Goal**: Prove the end state machine-verifiably, close the Boneyard bookkeeping, and record the
`countermodel_discrete` obligation as a recommendation for a separate task.

**Tasks**:
- [x] Full clean-ish rebuild: `lake build`, green, no errors.
- [x] Confirm the final live sorry count is **1**, and that the single remaining sorry is
      `WeakCanonical.countermodel_discrete` in `Transfer.lean`.
- [x] Re-run the report's Appendix B axiom check over the headline theorems and confirm the
      expected end state: `completeness` and `completeness'` still carry `sorryAx` (from
      `countermodel_discrete`); `completeness_dense` and `completeness_discrete` are still clean.
      Archiving must not have changed any of these four.
- [x] Re-run the whole-environment `collectAxioms` taint scan from Appendix B. The tainted set
      must shrink from 47 declarations to exactly 3: `countermodel_discrete`, `completeness`,
      `completeness'`. Use `collectAxioms`, not a `ConstantInfo.value?` traversal — the latter
      silently under-reports in this repo.
- [x] Confirm no live module imports any Boneyard path:
      `grep -rn "import Bimodal.Boneyard" Theories/ Tests/ --include=*.lean | grep -v '/Boneyard/'`
      returns nothing. Also confirm no live module imports `Bimodal.Metalogic.Bundle.SuccExistence`.
- [x] Audit the root `Boneyard/README.md`: three rows touched or added
      (`BundleSuccessorSeed` new, `SorriedDeclExcisions` updated, `DeadChronicleGapElimination`
      updated), `**Total**` row consistent with `find Theories/Bimodal/Boneyard -name '*.lean' | wc -l`
      and the corresponding `wc -l` sum, Task column `--` throughout the new/updated rows.
- [x] Record the follow-up recommendation in the task summary (not as a code change): prove
      `WeakCanonical.countermodel_discrete`, the sole `sorryAx` source reaching
      `BXCanonical.completeness`. Scope route (i) — a Base-MCS → Discrete-MCS transfer lemma that
      lets `countermodel_discrete_reynolds_v2` apply — before route (ii), a Henkin-style discrete
      canonical model built directly from a Base-MCS. Note that the old BX-pipeline route is
      provably unavailable (`succ_cofinal`, refuted by the ℤ+ℤ counterexample documented in
      `Boneyard/BXPipelineGapAnalysis/`), and that the effort is comparable to the original
      Reynolds pipeline landing — a task in its own right, not a follow-on to this one.

**Timing**: 45 minutes

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Boneyard/README.md` — final consistency pass on inventory and totals
- (verification only otherwise; no Lean source changes)

**Verification**:
- `lake build` green, 1 live sorry, tainted set of exactly 3 declarations.
- `completeness_dense` / `completeness_discrete` axiom sets unchanged and `sorryAx`-free.
- Zero live imports of any `Bimodal.Boneyard.*` module.

## Testing & Validation

- [x] `lake build` green at the end of every phase, with no new errors or warnings beyond the
      expected reduction in sorry warnings.
- [x] Live sorry count trajectory: 12 → 9 (P1) → 2 (P2) → 1 (P3) → 1 (P4) → 1 (P5).
- [x] `WeakCanonical.countermodel_discrete` is present, unmodified, and still the sole live sorry.
- [x] `#print axioms` on `completeness`, `completeness'`, `completeness_dense`,
      `completeness_discrete` matches the research report's baseline exactly.
- [x] The `collectAxioms` taint scan reports exactly 3 tainted declarations (down from 47).
- [x] No live module imports any archived path (`Bimodal.Boneyard.*`, or
      `Bimodal.Metalogic.Bundle.SuccExistence`).
- [x] Every archive destination has a subdirectory `README.md`, and the root
      `Boneyard/README.md` Directory Inventory has a matching row with consistent totals.
- [x] `Tests/BimodalTest/` still builds — the excised declarations had no test references, and
      that must remain true.

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/BundleSuccessorSeed/SuccExistence.lean` (moved) and its `README.md`
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` and an updated
  `SorriedDeclExcisions/README.md`
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean` and a
  corrected `DeadChronicleGapElimination/README.md`
- Updated `Theories/Bimodal/Boneyard/README.md` (three inventory rows plus totals)
- Trimmed live sources: `Bundle/SuccRelation.lean`, `Chronicle/ChronicleToCountermodel.lean`,
  `WeakCanonical/Transfer.lean`, `Core/RestrictedMCS/Basic.lean`
- Corrected documentation in `Completeness.lean`, `Transfer.lean`, `ReynoldsBridge.lean`,
  `MCSMixedCase.lean`, `WeakCanonical.lean`, `ReflexiveCanonical.lean`
- An implementation summary recording the final sorry inventory and the `countermodel_discrete`
  follow-up recommendation

## Rollback/Contingency

Each phase is a self-contained, independently green commit, so rollback is per-phase:
`git revert` the phase commit and rebuild. Because the phases are ordered lowest-risk first, a
failure in Phase 3 leaves the 10 sorries retired by Phases 1-2 committed and green — the units
do not strand each other.

Within Phase 3, sub-step 3.1 (heads) is committed green before sub-step 3.2 (tails) begins, so a
failure while closing the closure fixpoint reverts only 3.2/3.3. If the fixpoint grows past a
manageable size — say beyond ~15 declarations, or if it starts pulling in declarations reachable
from `completeness_discrete` — stop, revert Phase 3 to the 3.1 commit, and record the enlarged
closure in the task summary as a scoping finding rather than forcing the excision. Retiring 10 of
11 archivable sorries is a good outcome; a red tree is not.

Never commit a red tree, and never use `git add -A` (see `.claude/rules/git-workflow.md`) — stage
the task directory, the plan file, and the specific files each phase reports as modified.
