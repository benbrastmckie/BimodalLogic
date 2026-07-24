# Implementation Plan: Fix Flagship Status Docs for completeness_discrete
- **Task**: 384 - fix_flagship_status_docs_completeness_discrete
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None (coordinate-only boundaries with tasks 385/386, see Postmortem Constraints)
- **Research Inputs**: reports/01_flagship-status-docs-audit.md (integrated, plan v1)
- **Artifacts**: plans/01_flagship-status-docs-fix.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; no-task-references-in-deliverables.md
- **Type**: lean4 (comment/docstring-only — no proof changes)

## Overview

`completeness_discrete` and `completeness_dense` are machine-verified sorryAx-free (via
`lean_verify`, recorded in the research report's Axiom Baseline table), but 9 primary + 2
secondary documentation sites still describe them as sorry-carrying, cite rotted `:361`/`:364`
line anchors, or misname proof branches. This plan applies the research report's site-by-site
corrected wording to 3 `.lean` files + 1 README (comment/docstring edits only, ~60-90 changed
lines total), then verifies with grep checks and a targeted `lake build`. Definition of done:
all 11 sites corrected per the report spec, zero residual stale patterns, touched modules build
green.

### Research Integration

- `reports/01_flagship-status-docs-audit.md` — the COMPLETE fix specification. Every site
  below carries a report section ID (A1..D1); the report section is the authoritative corrected
  wording. The implementer needs no re-research and no `lean_verify` re-runs.

### Source-to-Implementation Mapping (Tier 3, implementation-backed)

Ground truth is the research report's "Machine-Verified Axiom Baseline" table (this session's
`lean_verify` output), corroborated by `specs/reviews/review-2026-07-24-metalogic-cleanup.md`
Dimension 3. Every corrected wording below maps to a report section:

| Site | File | Anchor (declaration/heading — NEVER line number) | Report section (spec) |
|------|------|------------------------------------------------|----------------------|
| A1 | `Theories/Bimodal/Metalogic/Metalogic.lean` | `## Publication-Ready Results` table (3 rows: `completeness`, `completeness_dense`, `completeness_discrete`) | File A, A1 |
| A2 | `Theories/Bimodal/Metalogic/Metalogic.lean` | `## Axiom Dependencies` section | File A, A2 |
| A3 | `Theories/Bimodal/Metalogic/Metalogic.lean` | "(task 93)" in Irreflexive Temporal Semantics paragraph; "(task 142)" in Completeness Architecture item 3 — delete parentheticals | File A, A3 |
| B1 | `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` | Module docstring `## Status` section | File B, B1 |
| B3 | same | `**Sorry Status**` paragraph in docstring above `theorem completeness_dense` (+ scrub "(task 198)") | File B, B3 |
| B4 | same | Docstring above `theorem completeness_discrete`: 3 defects (branch names `_v2` and `mcs_mixed_case_absurd`; Sorry Status rewrite; scrub "(task 198)") | File B, B4 |
| C1 | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | `kampPrior_site_rungK_gate_match` docstring, "Obligation discipline" paragraph | File C, C1 |
| C2 | same | Phase-16 shim module comment above `kampPrior_existProviders_of_ih` ("Axiom cleanliness" + "Line-citation stability" items → historical rationale) | File C, C2 |
| C3 | same | Phase-15 VERDICT RECORD comment; HOIST NOTE above `kampPrior_site_perQnf_seam`; mirrored hoist-note near EOF — replace `:361`/`:364` anchors only, do not rewrite narrative | File C, C3 |
| C4 | same | File header `## Status` section, k>=2 bullet | File C, C4 |
| D1 | `Theories/Bimodal/Metalogic/README.md` | `## Sorry Status` / "Key Point" | File D, D1 |

Line numbers quoted in the report ("currently lines N-M") are advisory locators only — anchor
every edit by the declaration name or section heading above.

### Preserved Assets

No prior implementation phases exist. The following in-repo content is verified-current and
must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| `/-! ## Axiom Audit ... -/` block (end of file) | `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` | current, matches `lean_verify` exactly — DO NOT EDIT | 2026-07-24 (research session) |
| Rabinovich citations (Def 4.1 / Prop 4.3 / Thm 4.4, PDF pp.5-6) | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | preserve verbatim inside edited regions | 2026-07-24 |
| Unchanged table rows (`soundness`/`soundness_dense`/`soundness_discrete`/`decide`) | `Theories/Bimodal/Metalogic/Metalogic.lean` | leave as-is | 2026-07-24 (soundness spot-verified) |

## Postmortem Constraints

Binding rules for all implementation dispatches. No prior attempts exist; rules derive from
research-report risk factors, scope boundaries, and repo rules.

**Do NOT**:
- Edit any proof code, statements, imports, or the `/-! ## Axiom Audit ... -/` block at the end
  of `BXCanonical/Completeness.lean` — this task is comment/docstring-only, and the Axiom Audit
  block is verified-current.
- Touch the orphan aggregator `Theories/Bimodal/Metalogic.lean` (repo-root-relative; the
  duplicate of the live `Metalogic/Metalogic.lean`) — task 385 DELETEs it; editing it is wasted
  churn.
- Fix the Base-`completeness` docstring `**Status**` paragraph / mixed-branch mismatch (report
  site B2, the ":129 vs :169" issue) — task 386's territory; it will rewrite that very branch.
- Restructure the `## Module Structure` tree in `Metalogic/Metalogic.lean`
  (`DenseSoundness.lean`/`DiscreteSoundness.lean` rows) — task 385's triage owns those files.
- Perform mass `.lean:NNN` → decl-name anchor conversion beyond the specific rotted anchors in
  edited regions (~568 remaining anchors ride with the task-380 sweep).
- Introduce ANY new line-number anchors (`:NNN`) or task-number references (`(task N)`,
  `task-N`) in `Theories/**` or `README.md` — and scrub the existing ones inside edited regions
  (rule `no-task-references-in-deliverables.md`).
- Infer sorry status from declaration names (e.g. `dd_countermodel_chronicle_mixed_sorry` is
  sorryAx-FREE despite its name) or re-run `lean_verify` to second-guess the report — the
  baseline table is this session's machine output.

**MUST preserve**:
- The Preserved Assets table above (Axiom Audit block untouched; Rabinovich citations verbatim;
  unchanged status-table rows).
- All proof code byte-identical: `git diff` must show changes only inside comments/docstrings
  and README prose.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Corrected wording comes from the report's per-site suggested text (light prose smoothing
  allowed; factual content — axiom lists, branch names, "sole sorryAx source =
  `WeakCanonical.countermodel_discrete`" — is fixed).
- B2 stays deferred to the re-point task; at most apply the report's documented
  defensive-minimal last-two-sentence replacement, never the mixed-case sentence.
- Anchoring convention: declaration name / section heading, never line number.

## Goals & Non-Goals

- **Goals**: Correct all 11 in-scope stale documentation sites (A1-A3, B1, B3, B4, C1-C4, D1)
  so the library front door matches the machine-verified axiom baseline; scrub task-number
  references and rotted `:361`/`:364` anchors inside edited regions; keep touched modules
  building green.
- **Non-Goals**: Any proof change; B2 (task 386); orphan `Theories/Bimodal/Metalogic.lean`
  (task 385); Module Structure tree restructuring (task 385); mass line-anchor conversion
  (task 380); renaming `dd_countermodel_chronicle_mixed_sorry` (later sweep).

## Risks & Mitigations

- Risk: A malformed `/-! ... -/` or `/-- ... -/` edit breaks docstring syntax and fails the
  build. Mitigation: Phase 2 targeted `lake build` of the three touched modules; comment-only
  edits make any failure trivially local.
- Risk: Line-number loci in the report drift from the working tree. Mitigation: every edit
  anchors by declaration name / heading (grep for the anchor first); line numbers are advisory.
- Risk: Accidental edit bleed into task 385/386 territory. Mitigation: Postmortem Constraints
  "Do NOT" list + Phase 2 `git diff --stat` check that exactly 4 files changed.
- Risk: Over-scrubbing task references outside edited regions (scope creep). Mitigation: scrub
  only the 5 specific occurrences the report names (task 93, 142, 198 x2, 357/task-309 in C1).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Fully sequential; no parallel opportunity (single-territory, 4-file edit set).

### Phase 1: Apply all 11 site corrections (Files A, B, C, D) [COMPLETED]
- **Goal:** Every in-scope stale site rewritten to the report's corrected wording; task-number
  references and rotted `:361`/`:364` anchors scrubbed inside edited regions.
- **Tasks:**
  - [x] Read the four target files' relevant regions (locate each anchor by declaration
    name/heading via grep, not by line number).
  - [x] File A `Theories/Bimodal/Metalogic/Metalogic.lean`: apply A1 (3 table rows), A2 (Axiom
    Dependencies rewrite), A3 (delete "(task 93)" and "(task 142)" parentheticals). Leave the
    Module Structure tree and all other table rows untouched.
  - [x] File B `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`: apply B1 (module
    `## Status` rewrite), B3 (`completeness_dense` Sorry Status rewrite + "(task 198)" scrub),
    B4 (`completeness_discrete` docstring: `countermodel_discrete_reynolds` →
    `countermodel_discrete_reynolds_v2`; mixed-case credit → `mcs_mixed_case_absurd`; Sorry
    Status rewrite; "(task 198)" scrub). Do NOT touch B2's `**Status**` paragraph or the Axiom
    Audit block. *(deviation: altered — two additional bare task-number parentheticals in the
    base-`completeness` docstring/proof comment ("discrete_box_necessity" line and the
    mixed-case branch comment) were scrubbed token-only, without touching B2's `**Status**`
    narrative or the mixed-branch mismatch, because the Phase 1 self-check grep requires 0
    matches across the whole file)*
  - [x] File C `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`: apply C1
    (Obligation discipline rewrite, scrubs its two task references), C2 (Phase-16 shim items →
    historical-rationale form), C3 (replace `:361`/`:364` anchors in VERDICT RECORD + both
    hoist notes with "the `nf_nvar_exist_all_depths` recursion arms (since retired — see
    `kampArm_zeta`)"; narrative untouched), C4 (header k>=2 bullet → sorry-free headline).
    Preserve Rabinovich citations verbatim. *(deviation: altered — the self-check grep pattern
    also matched two occurrences outside the report's 5 named scrubs: the supply-site
    certificate docstring's opening parenthetical (same docstring as C1) and the hoisted
    arm-closure chain section comment's "task-309"/"task-358" section labels; both scrubbed
    token-only to meet the 0-matches done-criterion, narratives unchanged)*
  - [x] File D `Theories/Bimodal/Metalogic/README.md`: apply D1 (qualified Key Point wording).
  - [x] Self-check greps (all must return 0 matches):
    `grep -n ':361\|:364' Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`;
    `grep -n 'task 93\|task 142\|task 198\|task 357\|task-309' <the 4 edited files>`;
    `grep -n 'SORRY (chronicle\|SORRY (nf_nvar' Theories/Bimodal/Metalogic/Metalogic.lean`;
    `grep -n 'Inherits sorries' Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`;
    `grep -n 'un-landed realization\|inherits .sorryAx. from the open' Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`.
- **Timing:** ~1 hour. Estimated output: ~60-90 changed lines across 4 files (bounded unit:
  fixed, finite 11-site checklist with per-site done-criteria — no open-ended surface).
- **Depends on:** none
- **Done when:** all 11 checklist sites applied and every self-check grep returns 0 matches.

### Phase 2: Verification sweep and targeted build [COMPLETED]
- **Goal:** Prove the edit set is comment-only, in-scope, and compiles.
- **Tasks:**
  - [x] `git diff --stat` — exactly 4 files changed: `Metalogic/Metalogic.lean`,
    `BXCanonical/Completeness.lean`, `WeakCanonical/Kamp/KampPrior.lean`,
    `Metalogic/README.md`. In particular, orphan `Theories/Bimodal/Metalogic.lean` unchanged.
    *(deviation: altered — Phase 1 was already committed (783393926), so the scope check ran
    against that commit (`git show --stat`) instead of the working tree; 4 deliverable files +
    specs/ task artifacts only, orphan aggregator absent)*
  - [x] `git diff` review — no hunk touches code outside `/-! -/`, `/-- -/`, `--` comments, or
    README prose; Axiom Audit block absent from the diff. *(verified against commit 783393926:
    all 118 changed lines are docstring/comment/README prose; the only "Axiom Audit" diff
    matches are new `+` docstring cross-references, block header at Completeness.lean:343
    untouched)*
  - [x] Re-run the Phase 1 self-check greps (guard against partial application). *(all 5
    negative greps: 0 matches — confirms Phase 1's token-only deviation scrubs satisfy the
    0-matches done-criterion)*
  - [x] Positive greps (each must return >= 1 match): `countermodel_discrete_reynolds_v2` and
    `mcs_mixed_case_absurd` in the `completeness_discrete` docstring region of
    `Completeness.lean`; `kampArm_zeta` in the rewritten KampPrior regions;
    `WeakCanonical.countermodel_discrete` in the corrected A1/A2/B1/D1 wording.
    *(reynolds_v2: 3 hits incl. discrete-case docstring line; mcs_mixed_case_absurd: 6;
    kampArm_zeta: 9; WeakCanonical.countermodel_discrete: 2/3/1 in Metalogic.lean /
    Completeness.lean / README.md)*
  - [x] Targeted build of touched modules:
    `lake build Bimodal.Metalogic.Metalogic Bimodal.Metalogic.BXCanonical.Completeness Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`
    (fall back to `lake build Bimodal.Metalogic`, then plain `lake build`, if the targeted
    module names are not accepted). Expect a fast no-op-semantics rebuild; this guards only
    against docstring/comment syntax errors. *(Build completed successfully, 1758 jobs; only
    pre-existing unusedSimpArgs linter warnings in untouched Quasimodel/Realization.lean)*
- **Timing:** ~20-30 minutes (build-dominated). Estimated output: 0 new file lines
  (verification gate; done-criterion is externally checkable).
- **Depends on:** 1
- **Done when:** diff scope confirmed 4-files/comment-only, all negative greps 0, all positive
  greps >= 1, targeted build green.

## Testing & Validation

- [x] Phase 1 self-check greps (negative patterns, 0 matches) — listed in Phase 1.
- [x] Phase 2 positive greps (corrected wording present) — listed in Phase 2.
- [x] `git diff --stat` scope check (exactly 4 files; orphan aggregator untouched).
- [x] Targeted `lake build` of the three touched `.lean` modules green (fallback chain in
  Phase 2). Full `lake build` NOT required — comments cannot change semantics.

## Artifacts & Outputs

- plans/01_flagship-status-docs-fix.md (this file)
- Edited deliverables: `Theories/Bimodal/Metalogic/Metalogic.lean`,
  `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`,
  `Theories/Bimodal/Metalogic/README.md`
- summaries/01_flagship-status-docs-summary.md (written by implementer)

## Rollback/Contingency

- All edits are comment/docstring-only in 4 files; rollback is
  `bash .claude/scripts/git-snapshot.sh` followed by reverting the 4 files (or dropping the
  uncommitted hunks). No downstream code depends on comment content.
- If the targeted build fails on a docstring syntax error, fix forward in the offending
  comment block (errors will be local to the edited hunk); never revert proof code — none is
  touched.
