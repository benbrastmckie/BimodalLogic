# Implementation Plan: Kamp Completeness Final Assembly and Axiom Audit
- **Task**: 375 - kamp_completeness_final_assembly_axiom_audit
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None (tasks 384, 385, 386, 359 already landed; their deltas are folded in below)
- **Research Inputs**: reports/01_rabinovich-fidelity-audit.md (READ THE FINAL "Adversarial Self-Verification (Post-Batch Re-Verification)" SECTION FIRST — it supersedes the report body and pre-dated task-description assumptions)
- **Artifacts**: plans/01_final-assembly-axiom-audit.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; state-management.md; lean4.md; plan-compliance.md; no-task-references-in-deliverables.md
- **Type**: lean4

## Overview

Final assembly for the Kamp expressive-completeness chain: harden the axiom profile of
`completeness_discrete` by swapping `native_decide` for `rfl`/`decide` at the 7 in-cone sites
(with a bounded per-site fallback), run the full verification audit (chain `lean_verify`,
sorry/admit scan, axiom-declaration scan), update the just-refreshed doc surfaces to match the
measured axiom sets, and refresh the `specs/ROADMAP.md` Current-state block. **No new proof
content**: the only `.lean` changes permitted are single-tactic swaps (`native_decide` →
`rfl`/`decide`) in two Syntax-layer files, plus docstring/comment edits on doc surfaces.

**Definition of done**: build green; the four-declaration Kamp chain byte-verifies to
`[propext, Classical.choice, Quot.sound]`; `completeness_discrete`'s axiom set is byte-listed
under exactly one of two explicitly documented branches (Branch A pristine, Branch B expanded
with per-site rationale); Kamp-zone statement-position sorry count is 0; ROADMAP Current-state
block dated 2026-07-24 supersedes the 2026-07-16 block.

**Adjudication DECISION (settled by the orchestrator, binding)**: attempt the swap path to
reach the pristine 3-axiom set for `completeness_discrete`, because `rfl`/`decide` were
verified cheap at both probed sites (report post-batch delta 3). Bounded fallback: if any
specific site's swap is expensive (compile-time blowup, `maxRecDepth`/timeout) or breaks, KEEP
`native_decide` at that site and document the expanded expected axiom set with per-site
rationale in the audit block. Either outcome must be explicit in the docs — never a silent
pass.

### Research Integration

- `reports/01_rabinovich-fidelity-audit.md` — body: ALIGNED verdict, drift register, coverage
  sweep; **post-batch re-verification section (authoritative)**: chain already clean, Kamp-zone
  sorries already 0, native_decide is multi-site (single-site claim REFUTED), 7 enumerated
  post-batch deltas.

### Preserved Assets

The following work is complete and must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Kamp chain sorry-free, axioms `[propext, Classical.choice, Quot.sound]` (all 4 decls) | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (`:350`, `:576`, `:659`), `.../Kamp/PriorExpressiveness.lean:346` | [COMPLETED] | 2026-07-24 (report post-batch `lean_verify`) |
| `completeness_discrete` sorryAx-free | `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` | [COMPLETED] | 2026-07-24 |
| EANegation sorry pair archived to Boneyard (live Kamp-zone sorry count 0) | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/EANegationVBracketBackward.lean` | [COMPLETED] (task 359) | 2026-07-24 |
| Flagship status docs naming the extended axiom set | `Theories/Bimodal/Metalogic/Metalogic.lean`, `BXCanonical/Completeness.lean` | [COMPLETED] (tasks 384/386) — will be RE-EDITED (not regressed) in Phase 2 to track the Phase 1 outcome | 2026-07-24 |
| Orphan triage / aggregator deletion (top-level `Theories/Bimodal/Metalogic.lean` deleted; `Metalogic/Metalogic.lean` is the live surface) | (20 files → Boneyards) | [COMPLETED] (task 385) | 2026-07-24 |
| ζ-wire and all Kamp proof content (`kampArm_zeta`, `translate_uniformFin`, etc.) | `.../Kamp/ZetaUniformExtract.lean` and siblings | [COMPLETED] | 2026-07-24 |

### Source-to-Implementation Mapping (H3)

This is a verification/documentation task (Tier 3, implementation-backed, with the audited
research report as primary source); no new theorem is transcribed from literature, so the
5-column Tier 1 lemma table does not apply. Load-bearing verification targets and their
grounding:

| Verification target | Expected result (byte-exact) | Source |
|---|---|---|
| `Bimodal.Metalogic.BXCanonical.completeness_discrete` | Branch A: `[propext, Classical.choice, Quot.sound]`; Branch B: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` | Report §3.4 + post-batch table rows 1, 6–7 |
| `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`, `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior` | Each exactly `[propext, Classical.choice, Quot.sound]` | Report post-batch table row 2 (CONFIRMED + STRENGTHENED) |
| Statement-position sorry scan, `WeakCanonical/Kamp/` excl. `Boneyard/` | 0 hits | Report post-batch table row 3 / delta 1 |
| `axiom` declaration scan, `WeakCanonical/` excl. Boneyards | 0 hits | Report post-batch table row 4 |
| In-cone `native_decide` sites | `Syntax/Formula.lean:265` (1) + `Syntax/SubformulaClosure/TemporalFormulas.lean:561,:568,:597,:639,:658,:684` (6) = **7 sites** (plan-time fresh grep; the delegation's "8" and the report's "7 in TemporalFormulas" both miscount — the fresh grep at implementation time is authoritative) | Report post-batch delta 3 + plan-time grep 2026-07-24 |
| `SignedFormula.lean` native_decide sites (4) | OUT of `completeness_discrete`'s import cone — out of scope | Report post-batch delta 3 |
| Base `completeness` sorryAx residue | Sole source: deprecated `WeakCanonical.countermodel_discrete` (`Transfer.lean:1277`) — state in ROADMAP, do not fix | Report post-batch delta 5 (task 386 isolation) |

## Postmortem Constraints

Binding rules for all implementation dispatches. These rules are derived from prior attempts,
the fidelity audit, and the post-batch re-verification.

**Do NOT**:
- Do NOT assume a single `native_decide` site suffices — the report's §3.4 single-site claim was
  REFUTED by the post-batch pass. Re-run `lean_verify` on `completeness_discrete` after the
  swaps; do not infer the axiom set from the site list.
- Do NOT modify any proof under `WeakCanonical/Kamp/` or `WeakCanonical/` generally. The only
  permitted `.lean` edits are: (a) the 7 single-tactic swaps in the two Syntax files, (b)
  docstring/comment edits on the named doc surfaces. Anything else is out of charter.
- Do NOT touch the 4 `native_decide` sites in `Metalogic/Decidability/SignedFormula.lean` —
  they are outside `completeness_discrete`'s import cone (optional hygiene explicitly NOT in
  this task).
- Do NOT re-open the EANegation bracket backward direction (standing prohibition; pair archived
  to Boneyard by task 359), the attained-vs-Dedekind carrier (owned by task 378), the k≥2
  arity-4 architecture (three prior abandonments), or the `F` stage-index cleanup (descoped by
  task 359).
- Do NOT silently pass the native_decide adjudication: whichever branch lands, the doc surfaces
  must state the measured axiom set and (Branch B) the per-site retention rationale.
- Do NOT cite task numbers in any `Theories/**/*.lean` file (rule:
  no-task-references-in-deliverables.md). `specs/ROADMAP.md` and specs artifacts are exempt.
- Do NOT burn more than one `rfl` attempt + one `decide` attempt per site; on failure or
  compile-time blowup (site build noticeably degraded, e.g. >~60s attributable to the swapped
  tactic, or `maxRecDepth`/timeout errors), revert THAT site to `native_decide` and move on.
  This is the bounded-fallback contract — no open-ended tactic search.
- Do NOT un-archive or edit anything under any `Boneyard/` directory.

**MUST preserve**:
- Everything in the Preserved Assets table above; in particular the four chain declarations'
  clean axiom profile and the sorryAx-free status of `completeness_discrete` and
  `completeness_dense`.
- Full `lake build` green at every commit point.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Swap-with-bounded-fallback is the adjudicated native_decide policy (orchestrator decision,
  this plan's Overview). Branch B is a legitimate, documented outcome — not a failure.
- The Prior-structure carrier relativization (`HasAttainedINF/SUP`) is a documented motivated
  deviation; faithful Dedekind carrier is task 378's charter, not this task's.
- Hintikka `NormalForm` in intermediate spine statements is settled (plan-24 resolution,
  report Drift Register #6).

## Goals & Non-Goals

- **Goals**:
  - Attempt the pristine `[propext, Classical.choice, Quot.sound]` axiom set for
    `completeness_discrete` via 7 bounded tactic swaps; land Branch A or a documented Branch B.
  - Re-confirm (cheap regression gates, pre-discharged by the report): chain `lean_verify`
    clean; 0 Kamp-zone statement sorries; 0 `axiom` declarations in `WeakCanonical/`.
  - Make all doc surfaces (`Metalogic/Metalogic.lean`, `BXCanonical/Completeness.lean` audit
    block) byte-consistent with the measured axiom sets.
  - Refresh `specs/ROADMAP.md` Current-state (new block dated 2026-07-24 folding in tasks
    384/385/386/359 and this audit).
- **Non-Goals**:
  - No new proof content; no Kamp-zone proof edits; no SignedFormula.lean hygiene; no
    Dedekind-carrier work (378); no `F` stage-index removal; no consolidation of k=0/k=1 legacy
    arms; no fix for the deprecated `countermodel_discrete` sorry (`Transfer.lean:1277`).

## Risks & Mitigations

- **Risk**: A `decide` swap type-checks but blows up compile time, degrading the build for
  everyone. **Mitigation**: per-site fallback contract (Postmortem Constraints); time the
  rebuild of the touched file; revert any site that degrades it materially.
- **Risk**: After all 7 in-cone swaps, `completeness_discrete` STILL carries
  `Lean.ofReduceBool` (an untraced in-cone site exists — the report explicitly warns
  decl-level tracing was not done). **Mitigation**: one bounded discovery pass — repo-wide
  `grep -rn native_decide Theories/` plus an import-cone membership check for any new hit; if
  a new in-cone site is found, apply the same per-site swap rule once; if the axiom persists
  after that single pass, take Branch B and document ("residual native_decide dependency at
  <site(s)>"). No open-ended cone spelunking.
- **Risk**: Doc surfaces drift from measured reality (the exact failure this task exists to
  prevent). **Mitigation**: Phase 2 edits are written FROM the Phase 1 `lean_verify` transcript
  (byte-listed axiom sets), never from expectation; Phase 3 re-verifies once more after all
  edits.
- **Risk**: Task-number citations leak into `.lean` doc edits. **Mitigation**: explicit MUST
  NOT rule; use durable anchors ("see the Axiom Classification block in
  `BXCanonical/Completeness.lean`") instead.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Fully sequential: Phase 2's doc edits depend on Phase 1's measured branch; Phase 3's ROADMAP
text depends on Phase 2's final audit results.

### Phase 1: native_decide → rfl/decide swaps (7 in-cone sites) with per-site fallback, rebuild, axiom re-verify [COMPLETED]

- **Goal:** Determine and land the `completeness_discrete` axiom branch: Branch A
  (`[propext, Classical.choice, Quot.sound]`) or Branch B (expanded set with a per-site
  fallback ledger).
- **Tasks:**
  - [x] Fresh authoritative grep: `grep -rn native_decide Theories/Bimodal/Syntax/` — expect
    exactly the 7 sites listed in the H3 mapping table; reconcile any drift before editing.
    *(Confirmed: exactly the 7 H3-table sites, no drift.)*
  - [x] Site 1 — `Syntax/Formula.lean:265` (`| bot => native_decide`, goal
    `(bot == bot) = true`): swap to `rfl` (verified cheap by report probe; `rfl` preferred over
    `decide`). *(Landed: `rfl`, first attempt.)*
  - [x] Sites 2–5 — `TemporalFormulas.lean:561,:568,:639,:658`
    (`exact le_max_of_le_right (by native_decide)`): swap each `by native_decide` → `by decide`
    (`decide` verified at `:561`; same concrete-formula shape at the others).
    *(Landed: `decide` at all four, first attempt.)*
  - [x] Sites 6–7 — `TemporalFormulas.lean:597,:684` (calc steps
    `calc 1 = f_nesting_depth F_top := by native_decide` and the `p_nesting_depth P_top`
    mirror): try `rfl` first, then `decide`; these are the two unprobed shapes.
    *(Landed: `rfl` at both, first attempt — `decide` fallback never needed.)*
  - [x] Per-site fallback: on failure or compile blowup (Postmortem Constraints bound), revert
    that site to `native_decide` and append a row to the fallback ledger (site, tactic tried,
    failure mode). *(Fallback ledger: EMPTY — all 7 swaps landed on first attempt. Scoped
    rebuild of both touched modules: 13s total; `TemporalFormulas` itself 1.2s, `Formula`
    unremarkable — no compile-time blowup at any site.)*
  - [x] Rebuild: `lake build` (full) — must be green; note wall time of the two touched files
    if any site was slow. *(Green, 1789 jobs, 3m30s wall (full downstream rebuild); no slow
    site.)*
  - [x] `lean_verify` (byte-list every result in the phase output). *(MCP `lean_verify` on
    `completeness_discrete` initially reported
    `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` from a
    STALE LSP environment predating the rebuild; the discovery pass confirmed no in-cone
    native_decide remains, and the authoritative kernel-level check `lake env lean` with
    `#print axioms` against the fresh oleans byte-lists:*
    - *`Bimodal.Metalogic.BXCanonical.completeness_discrete` → `[propext, Classical.choice, Quot.sound]`*
    - *`Bimodal.Metalogic.BXCanonical.completeness_dense` → `[propext, Classical.choice, Quot.sound]`*
    - *`Bimodal.Syntax.Formula.beq_refl` → `[propext, Classical.choice, Quot.sound]`*
    - *`Bimodal.Syntax.max_F_depth_deferralClosure_eq` → `[propext, Classical.choice, Quot.sound]`*
    - *`Bimodal.Syntax.max_P_depth_deferralClosure_eq` → `[propext, Classical.choice, Quot.sound]`)*
  - [x] Branch decision: **BRANCH A**. All 7 sites swapped, fallback ledger empty,
    `completeness_discrete` = `[propext, Classical.choice, Quot.sound]`. The bounded discovery
    pass (run because of the stale-LSP false positive) found the only remaining tactic-position
    `native_decide` sites are the 4 known out-of-cone `Decidability/SignedFormula.lean` sites
    (`:126,:132,:133,:138`; the `Syntax/Subformulas.lean` grep hit is a comment, not an
    import — SignedFormula confirmed OUT of the cone); all other hits are doc-surface prose
    scheduled for Phase 2 reconciliation.
  - [x] Commit (green): `task 375 phase 1: native_decide swap + axiom re-verify` (stage only
    the two Syntax files).
- **Timing:** ~1.5 hours. Estimated output: ~20–40 changed lines (7 single-tactic diffs) +
  verification transcript.
- **Depends on:** none
- **Done when:** `lake build` green AND all five `lean_verify` axiom sets byte-listed in the
  phase output AND the branch decision (A or B, with ledger if B) is recorded.

### Phase 2: Full audit sweep and doc-surface reconciliation [NOT STARTED]

- **Goal:** Machine-verify every charter audit item and make the in-tree doc surfaces
  byte-consistent with the Phase 1 measured axiom sets.
- **Tasks:**
  - [ ] `lean_verify` the four-declaration chain (regression gate, expected pre-discharged):
    `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`,
    `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior` — each must
    report exactly `[propext, Classical.choice, Quot.sound]`; byte-list all four.
  - [ ] Fresh sorry/admit scan: statement-position patterns (`^\s*sorry$`, `:= sorry`,
    `by sorry`, and `admit`) over `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` excluding
    `Boneyard/` — expected **0** hits (post-359 regression gate).
  - [ ] `axiom` declaration scan (`^\s*axiom `) over
    `Theories/Bimodal/Metalogic/WeakCanonical/` excluding Boneyards — expected **0**.
  - [ ] Update doc surfaces to the measured branch (all edits from the Phase 1 transcript;
    NO task numbers in `.lean` files):
    - `Theories/Bimodal/Metalogic/Metalogic.lean:31,:32,:56` — Branch A: drop the
      `Lean.ofReduceBool`/`Lean.trustCompiler` caveat, state the pristine set for both
      `completeness_dense` and `completeness_discrete`; Branch B: keep the caveat, tighten it
      to name the retained site(s) and the retention reason.
    - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:36,:242,:283` (docstrings) and
      the "Axiom Classification" audit block (near `:381–384`) — same branch treatment; the
      audit block is where the full adjudication (decision, per-site outcome, rationale) is
      recorded so the pass is never silent.
    - Confirm `Metalogic/README.md` has no axiom-set prose to update (plan-time grep found no
      `native_decide`/`ofReduceBool` mention; re-grep to confirm, include `Lean.ofReduceBool`
      and `trustCompiler` in the pattern).
  - [ ] `lake build` green after doc edits (docstring edits can still break compilation).
  - [ ] Commit (green): `task 375 phase 2: axiom audit sweep + doc reconciliation`.
- **Timing:** ~1 hour. Estimated output: ~30–60 changed doc lines + audit transcript.
- **Depends on:** 1
- **Done when:** all four chain axiom sets byte-listed and clean AND both scans report 0 AND
  every named doc surface states the measured (not assumed) axiom set AND build green.

### Phase 3: ROADMAP Current-state refresh and final verification gates [NOT STARTED]

- **Goal:** Fold five tasks' worth of deltas into a new `specs/ROADMAP.md` Current-state block
  and close the task with a final regression pass.
- **Tasks:**
  - [ ] Write a new **Current state (2026-07-24)** block at the top of the Kamp/discrete
    section of `specs/ROADMAP.md`, superseding the 2026-07-16 block (retain the old block as
    history, marked superseded, matching the file's existing convention). Content (task
    numbers ARE permitted in specs/):
    - Kamp chain COMPLETE and sorry-free; all four declarations verify to
      `[propext, Classical.choice, Quot.sound]` (supersedes the "ONE live proof-term sorry"
      claim of the 2026-07-16 block — the k≥2 residual was retired by the ζ-wire).
    - `completeness_discrete` axiom set per the landed branch (byte-exact list; Branch B: note
      retained sites), `completeness_dense` likewise; both sorryAx-free.
    - Live Kamp-zone statement-position sorry count: 0 (EANegation pair archived to
      `Kamp/Boneyard/EANegationVBracketBackward.lean`, task 359).
    - Base `completeness` sorryAx residue isolated to deprecated
      `WeakCanonical.countermodel_discrete` (`Transfer.lean:1277`), outside the Kamp scope
      (task 386 finding) — stated precisely, not re-derived.
    - Batch deltas folded in: 384 (flagship docs), 385 (orphan triage, aggregator deletion),
      386 (completeness re-point), 359 (Boneyard hygiene), 375 fidelity audit verdict
      (ALIGNED, no unmotivated drift) + this task's adjudication outcome.
    - Open remainders with owners: Dedekind carrier (378), `F` stage-index cleanup (future),
      optional SignedFormula.lean native_decide hygiene (unowned).
  - [ ] Final gates: `lake build` green; re-run `lean_verify` on `completeness_discrete` once
    more (post-doc-edit regression) and byte-list the result; `git status` shows only intended
    files.
  - [ ] Commit (green): `task 375 phase 3: ROADMAP current-state refresh` (stage
    `specs/ROADMAP.md`).
- **Timing:** ~0.5 hour. Estimated output: ~40–70 lines of ROADMAP text.
- **Depends on:** 2
- **Done when:** the new ROADMAP block is in place with the old block marked superseded AND
  all final gates are green with the last `lean_verify` byte-listed.

## Testing & Validation

- [ ] `lake build` green at the end of every phase (gate for every commit).
- [ ] `lean_verify` byte-listed results for: `completeness_discrete`, `completeness_dense`,
  `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`,
  `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior`, plus the three
  Syntax-layer host declarations after the swaps.
- [ ] Sorry/admit scan (Kamp zone, Boneyard excluded) = 0; `axiom` scan (WeakCanonical) = 0.
- [ ] Grep check: no `task [0-9]` citation patterns introduced in `Theories/**/*.lean` diffs.
- [ ] Doc-vs-measurement consistency: every axiom set named in a doc surface appears verbatim
  in a Phase 1/2 `lean_verify` transcript line.

## Artifacts & Outputs

- plans/01_final-assembly-axiom-audit.md (this file)
- summaries/01_final-assembly-axiom-audit-summary.md (implementation summary; must include the
  branch decision, the fallback ledger if Branch B, and all byte-listed axiom sets)
- Modified: `Theories/Bimodal/Syntax/Formula.lean`,
  `Theories/Bimodal/Syntax/SubformulaClosure/TemporalFormulas.lean` (tactic swaps only),
  `Theories/Bimodal/Metalogic/Metalogic.lean`,
  `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (doc surfaces only),
  `specs/ROADMAP.md`

## Rollback/Contingency

- Each swap site is independently revertible to `native_decide` (the fallback IS the rollback;
  Branch B with all 7 sites reverted degenerates to the pre-task state plus documentation —
  still a valid, explicit outcome).
- Per-phase green commits mean any failure rolls back to the last green commit; use
  `bash .claude/scripts/git-snapshot.sh` before any intentional discard of uncommitted work.
- If the full build breaks in a way not attributable to a swap site (pre-existing breakage),
  stop, record in errors.json, and mark the phase [PARTIAL] rather than widening scope.
