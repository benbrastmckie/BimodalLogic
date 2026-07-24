# Implementation Plan: Re-point General Completeness (Base) — Isolate Base-MCS Discrete Debt

- **Task**: 386 - repoint_general_completeness_isolate_base_mcs_debt
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None (concurrent task 385 archives files OUTSIDE the live import closure; it does not touch `BXCanonical/Completeness.lean` or `WeakCanonical/Transfer.lean`)
- **Research Inputs**: specs/386_repoint_general_completeness_isolate_base_mcs_debt/reports/01_repoint-completeness-branches.md
- **Artifacts**: plans/01_repoint-completeness-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; state-management.md; lean4.md; plan-compliance.md; no-task-references-in-deliverables.md
- **Type**: lean4

## Overview

Re-wire the two clean branches of the general `completeness` theorem
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) so that all remaining sorry debt is
structurally isolated in the Base-MCS discrete branch: mixed branch →
`Chronicle.mcs_mixed_case_absurd FrameClass.Base` (exact mirror of `completeness_discrete`'s
usage); dense branch → `countermodel_dense_enriched` applied with `h_valid Rat`. The
compile-critical enabler is MOVING the currently-`private` `countermodel_dense_enriched` above
its new first use site (declaration order), plus de-privatizing it. Then fix the docstring/code
mismatch and document the Base-MCS discrete branch as the sole residue. **Definition of done**:
scoped `lake build` green, zero new sorries, and `#print axioms` profiles for `completeness`,
`completeness_dense`, and `completeness_discrete` all EXACTLY match the pre-change baseline
(the axiom profile is expected UNCHANGED — `sorryAx` remains via the discrete branch; this task
is dependency-graph hygiene and archival unlocking, not axiom-profile improvement).

All changes are confined to `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`.

### Research Integration

- `reports/01_repoint-completeness-branches.md` (integrated in plan v1, 2026-07-24): delivers
  the executable re-point spec (Changes 1-5), the machine-verified axiom baseline (F1), the
  declaration-order finding (F4), and the verification protocol. The spec is SETTLED — the
  implementer executes it, not re-derives it.

### Source-to-Implementation Mapping (H3, Tier 3 — implementation-backed)

All load-bearing decisions are grounded in machine-verified observations from the research
report (all re-verified with `lean_verify`/reads in the research session, same date as this plan):

| Plan Decision | Report Anchor | Grounding |
|---|---|---|
| Mixed branch → `Chronicle.mcs_mixed_case_absurd FrameClass.Base ...` | Report "Change 3"; mapping table row 1 | Lemma verified clean, fc-generic; hypothesis types match branch-site hypotheses exactly; identical call shape compiles at `completeness_discrete` (currently line ~338, `fc := Discrete`) |
| Dense branch → `countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense` + `h_valid Rat F TM Omega h_sc τ h_mem t` | Report "Change 2", F3; mapping table row 2 | `valid` quantifies over all `D` with the four instances; `Rat` has all four; identical call shape compiles at `completeness_dense` (currently lines ~243-245) |
| MOVE lemma above the `/-! ## BX Completeness Theorem -/` header, not just de-privatize | Report F4 | `private` never blocks same-file use; forward reference does. `completeness` precedes the lemma in the file, so declaration order is the compile-critical fix |
| Move is safe (no forward deps in lemma body) | Report F4 | Proof body references only imported symbols; nothing declared later in the file |
| Discrete branch KEPT as-is (sole residue) | Report "Change 4", F2 | `countermodel_discrete_reynolds_v2` requires a Discrete-MCS; a Base-MCS is not automatically Discrete-consistent — not re-pointable, genuinely open |
| Expected axiom profile UNCHANGED | Report F1, "Expected axiom profile after re-point" | Replacement lemmas carry the same clean axiom set as the deps they replace; the `sorryAx` edge (discrete) is untouched |

### Preserved Assets

No prior implementation phases exist for this task. The following pre-existing verified results
must not regress (regression checked in every phase's verification step):

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| `completeness_dense` (clean: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`) | Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean | [VERIFIED CLEAN] | 2026-07-24 (research session, `lean_verify`) |
| `completeness_discrete` (clean, same axiom set) | Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean | [VERIFIED CLEAN] | 2026-07-24 (research session, `lean_verify`) |
| `completeness` baseline profile (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`) | Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean | [BASELINE — must be identical after change] | 2026-07-24 (research session, `lean_verify`) |
| `Chronicle.mcs_mixed_case_absurd` (clean) | Theories/Bimodal/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean | [VERIFIED CLEAN — read-only dependency] | 2026-07-24 (research session, `lean_verify`) |

## Postmortem Constraints

Binding rules for all implementation dispatches. No prior implementation attempts exist; rules
derive from the research report's verified findings and known risk factors.

**Do NOT**:
- De-privatize WITHOUT moving the lemma. Dropping `private` on `countermodel_dense_enriched`
  while leaving it below `completeness` will NOT compile — Lean forbids same-file forward
  references. The move above the `/-! ## BX Completeness Theorem -/` section header is the
  compile-critical change (report F4).
- Touch the discrete branch's code. It stays pointed at the deprecated
  `WeakCanonical.countermodel_discrete` — re-pointing it at the Reynolds pipeline fails on an
  fc-mismatch (Base-MCS vs required Discrete-MCS) and is explicitly OUT of scope.
- Expect or claim an axiom-profile improvement. The `sorryAx` in `completeness` is expected to
  REMAIN (sole source: discrete branch). A post-change profile differing in ANY way from the F1
  baseline (including a vanished `sorryAx`, which would indicate a mis-wired case split) is a
  defect — stop and diagnose, do not rationalize.
- Archive or delete `Chronicle.countermodel_dense` or
  `Chronicle.dd_countermodel_chronicle_mixed_sorry`, or edit their defining files. Archival is
  explicitly follow-up scope; this task only removes their last live consumers in
  `Completeness.lean`.
- Trust cached line numbers. A concurrent task is archiving files elsewhere in the repo; all
  line anchors in this plan are "as of planning" — the implementer MUST re-locate every edit
  site by pattern (grep/read) at implement time. Anchor patterns are given per edit below.
- Trust `_sorry`-suffixed names or review-document prose for axiom status. Only `lean_verify` /
  `#print axioms` output counts (the review doc's §3.5 was proven stale on two counts).
- Add any task-number references ("task 386", etc.) to `.lean` file content — forbidden by
  no-task-references-in-deliverables.md. Docstrings cite lemma names and file paths only.
- Introduce any new `sorry` (the task adds zero proof obligations; both replacement terms are
  existing verified lemmas used verbatim at analogous, already-compiling call sites).

**MUST preserve**:
- The axiom profiles of `completeness`, `completeness_dense`, `completeness_discrete` exactly
  as in the F1 baseline (see Preserved Assets).
- The `#print axioms` audit lines for `completeness_dense`, `completeness_discrete`, and
  `completeness` near the end of the file.
- The discrete branch call `WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in
  h_box_discrete` byte-for-byte.

**Design decisions are SETTLED** (do not re-open without a concrete compile error as counterexample):
- Mixed branch target is `Chronicle.mcs_mixed_case_absurd FrameClass.Base` via `False.elim` —
  mirror of the existing `completeness_discrete` usage. Rejected alternative: keeping the
  vacuous `dd_countermodel_chronicle_mixed_sorry` wrapper (misleading name fossil, blocks archival).
- Dense branch target is `countermodel_dense_enriched` with `h_valid Rat ...` — mirror of the
  existing `completeness_dense` usage. Rejected alternative: keeping
  `Chronicle.countermodel_dense` (duplicate top-level wrapper, blocks archival).
- Visibility fix is move-above-first-use PLUS de-privatization (the lemma becomes a load-bearing
  dependency of two flagship theorems and must be `lean_verify`-able by FQN; private names are
  mangled). Rejected alternative: de-privatize in place (does not compile — forward reference).
- Discrete branch is kept and documented as the sole residue. Rejected alternative: attempting a
  Base-to-Discrete MCS transfer (a genuine open construction, its own future task).

## Goals & Non-Goals

- **Goals**:
  - Dense branch of `completeness` calls `countermodel_dense_enriched` (moved, de-privatized).
  - Mixed branch of `completeness` calls `Chronicle.mcs_mixed_case_absurd FrameClass.Base`.
  - `Completeness.lean` no longer references `Chronicle.countermodel_dense` or
    `Chronicle.dd_countermodel_chronicle_mixed_sorry` anywhere outside historical-note prose
    (unlocking their archival as follow-up work).
  - Docstring/code mismatch fixed; file-header Status block and `completeness` docstring
    accurately describe the new wiring and name the Base-MCS discrete branch as the sole
    `sorryAx` source, using the residue wording from the research report.
  - Axiom profiles verified byte-identical to baseline; zero new sorries.
- **Non-Goals**:
  - Re-pointing or discharging the discrete branch (open construction; future task).
  - Archiving `countermodel_dense` / `dd_countermodel_chronicle_mixed_sorry` (follow-up scope).
  - Any edit outside `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`.
  - Any axiom-profile change.

## Risks & Mitigations

- **Risk**: Line anchors drift (file edited between plan and implement time; concurrent archival
  task active elsewhere). **Mitigation**: every edit below carries a unique grep pattern; the
  implementer locates by pattern, never by cached line number, and re-reads the touched region
  before editing.
- **Risk**: Moved lemma block accidentally loses or duplicates lines (largest single edit).
  **Mitigation**: cut/paste the contiguous docstring+theorem block exactly once; scoped build
  immediately after Phase 1; `grep -c "countermodel_dense_enriched"` to confirm expected
  occurrence count (1 declaration + call sites + docstring mentions).
- **Risk**: Unification surprise at the dense re-point (fc implicit). **Mitigation**: `fc`
  unifies to `FrameClass.Base` from `hM_mcs`, and the identical call shape already compiles in
  `completeness_dense`; if it fails, pass `(fc := FrameClass.Base)` explicitly — do not redesign.
- **Risk**: Silent axiom-profile drift (e.g., a branch now vacuously closed). **Mitigation**:
  mandatory before/after `#print axioms` comparison for all three theorems is a phase
  done-criterion, with "any difference = defect, stop" per Postmortem Constraints.
- **Risk**: Docstring edits accidentally introduce task-number references into `.lean` content.
  **Mitigation**: Phase 2 verification includes `grep -in "task [0-9]" ` on the file.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Fully sequential (both phases edit the same file; Phase 2's prose must describe Phase 1's final
wiring). No parallel opportunities — single-file surgery.

### Phase 1: Re-point dense and mixed branches; relocate and de-privatize countermodel_dense_enriched [COMPLETED]

- **Goal:** `completeness` compiles with its dense branch on `countermodel_dense_enriched` and
  its mixed branch on `Chronicle.mcs_mixed_case_absurd`, with the lemma moved above its first
  use; axiom profiles byte-identical to baseline.
- **Estimated output:** ~50 changed lines (one ~31-line block moved + two branch-call
  replacements). One bounded, verifiable unit: a single theorem's branch re-wiring, all
  replacement terms pre-verified — fixed attempt surface, no open-ended proof work.
- **Tasks:**
  - [x] **Record the "before" baseline**: run scoped build if needed, then capture current
    `#print axioms` output for `Bimodal.Metalogic.BXCanonical.completeness`,
    `...completeness_dense`, `...completeness_discrete` (the file's existing audit `#print
    axioms` commands near EOF, or `lean_verify` on each FQN). Expected baseline (report F1):
    - `completeness`: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
    - `completeness_dense` / `completeness_discrete`: same set WITHOUT `sorryAx`.
  - [x] **Change 1 — Move + de-privatize** (report Change 1): locate the block starting at the
    docstring above `private theorem countermodel_dense_enriched` (anchor pattern:
    `private theorem countermodel_dense_enriched`) through the end of that theorem's proof
    (~31 lines, ends just before the `-- countermodel_discrete_enriched archived to` comment,
    which stays where it is). Cut the entire docstring+theorem block and paste it immediately
    BEFORE the section header `/-! ## BX Completeness Theorem -/` (anchor pattern:
    `## BX Completeness Theorem`). Change `private theorem countermodel_dense_enriched` →
    `theorem countermodel_dense_enriched`. Optionally update its docstring to note it is now
    the single canonical dense countermodel used by both `completeness` and `completeness_dense`.
  - [x] **Change 2 — Dense branch re-point** (report Change 2): in `completeness`, locate the
    dense case (anchor pattern: `Chronicle.countermodel_dense FrameClass.Base`). Replace:
    ```lean
      · -- Dense case: □(F'T) ∈ M — all box-equivalent MCS's are dense
        obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
          Chronicle.countermodel_dense FrameClass.Base M hM_mcs φ h_neg_in h_box_dense
        exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
    ```
    with:
    ```lean
      · -- Dense case: □(F'T) ∈ M — countermodel on Rat (countermodel_dense_enriched)
        obtain ⟨F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
          countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
        exact h_not_true (h_valid Rat F TM Omega h_sc τ h_mem t)
    ```
  - [x] **Change 3 — Mixed branch re-point** (report Change 3): locate the mixed case (anchor
    pattern: `dd_countermodel_chronicle_mixed_sorry FrameClass.Base`). Replace:
    ```lean
        · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — some worlds dense, others discrete
          obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
            Chronicle.dd_countermodel_chronicle_mixed_sorry FrameClass.Base M hM_mcs φ h_neg_in
              h_not_box_dense h_not_box_discrete
          exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
    ```
    with:
    ```lean
        · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
          exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Base M hM_mcs
            h_not_box_dense h_not_box_discrete)
    ```
  - [x] **Change 4 — Discrete branch: NO code change** (report Change 4): confirm the call
    `WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete` is untouched.
- **Verification (done when ALL pass):**
  - [x] `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds (scoped; fall back to
    full `lake build` only if the scoped target is rejected).
  - [x] `lean_verify` (or the in-file `#print axioms` output) for `completeness`,
    `completeness_dense`, `completeness_discrete` EXACTLY matches the recorded baseline —
    `sorryAx` still present in `completeness` (sole source: discrete branch), absent in the
    other two. Any difference is a defect: stop and diagnose.
  - [x] `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` shows no new
    `sorry` tokens (only pre-existing prose/name mentions).
  - [x] `grep -n "Chronicle.countermodel_dense \|dd_countermodel_chronicle_mixed_sorry" ` on the
    file shows no remaining CALL sites in `completeness` (the EOF `#print axioms
    ...Chronicle.countermodel_dense` audit line may still exist; it is Phase 2's concern).
- **Timing:** ~45 minutes.
- **Depends on:** none

### Phase 2: Docstring/header alignment and sole-residue documentation [NOT STARTED]

- **Goal:** All prose in `Completeness.lean` accurately describes the post-re-point wiring:
  docstring/code mismatch fixed, file-header Status block updated, EOF audit print annotated,
  Base-MCS discrete residue documented with the report's wording. Build stays green, profiles
  unchanged.
- **Estimated output:** ~40 changed lines (docstring + header + comments). One bounded,
  verifiable unit: prose alignment in one file against a fixed spec (report Change 5) — no
  proof work.
- **Tasks:**
  - [ ] **`completeness` docstring rewrite** (report Change 5.1): locate the docstring above
    `theorem completeness` (anchor pattern: `The mixed case (¬□(F'T)` or the `**Proof
    Strategy**` block). Replace the Proof Strategy / Status portion with the report's
    replacement text: three-way case split naming `countermodel_dense_enriched` (dense, on ℚ),
    deprecated `WeakCanonical.countermodel_discrete` as SOLE remaining `sorryAx` source
    (discrete), and `mcs_mixed_case_absurd` via `discrete_box_necessity` (mixed); plus the
    **Sorry Status** paragraph stating exactly one `sorryAx` source and why the Reynolds
    pipeline cannot be reused (Base-MCS not automatically Discrete-consistent). This also
    removes the stale `Chronicle/ChronicleToCountermodel.lean` location anchor (report
    Change 5.4). Incorporate the report's "Base-MCS Discrete Branch Documentation Wording"
    (sole-residue paragraph) here — lemma names and file paths only, no task numbers.
  - [ ] **File-header Status block update** (report Change 5.2): locate the header Status block
    (anchor pattern: `WeakCanonical.countermodel_discrete` within the first ~45 lines). Update
    branch-dependency names: dense → `countermodel_dense_enriched`, mixed →
    `mcs_mixed_case_absurd`; drop mentions of `Chronicle.countermodel_dense` and
    `dd_countermodel_chronicle_mixed_sorry` as live dependencies.
  - [ ] **EOF audit print** (report Change 5.3): locate `#print axioms
    Bimodal.Metalogic.BXCanonical.Chronicle.countermodel_dense` near EOF. Keep the audit but
    add a one-line comment that the lemma is no longer consumed by `completeness` and is
    retained pending archival (or delete the line — keeping with annotation preferred).
  - [ ] Sweep any other in-file comments still describing the old wiring (e.g., the case-split
    roadmap comment `-- 3. Mixed case ... vacuously true` if it misstates the mechanism).
- **Verification (done when ALL pass):**
  - [ ] `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds.
  - [ ] Axiom profiles for all three theorems still EXACTLY match baseline (docstring edits
    cannot change them; this is the regression tripwire).
  - [ ] `grep -in "task [0-9]" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` → no
    matches (no task-number references in deliverable).
  - [ ] `grep -n "dd_countermodel_chronicle_mixed_sorry" ` on the file → no matches at all
    (prose included), and `Chronicle.countermodel_dense` appears only in the annotated EOF
    audit/historical note.
  - [ ] No new sorries (same grep as Phase 1).
- **Timing:** ~30 minutes.
- **Depends on:** 1

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.BXCanonical.Completeness`.
- [ ] Before/after `#print axioms` comparison per the report's verification protocol:
  `completeness` profile unchanged INCLUDING `sorryAx`; `completeness_dense` and
  `completeness_discrete` unchanged clean. Any delta = defect.
- [ ] No new `sorry` tokens in the touched file; no edits to any other file.
- [ ] No task-number references in `.lean` content.
- [ ] Final full `lake build` (cheap safety net; only `Completeness.lean` is in the change set
  and it sits near the leaf of the import DAG).

## Artifacts & Outputs

- plans/01_repoint-completeness-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (only file)
- summaries/01_repoint-completeness-summary.md (written by the implementer)
- Implementation summary should note the two archival unlocks for follow-up task creation:
  `Chronicle.dd_countermodel_chronicle_mixed_sorry` (MCSMixedCase.lean) and
  `Chronicle.countermodel_dense` (ChronicleToCountermodelBasic.lean) lose their last live
  consumers.

## Rollback/Contingency

- Single-file change committed per green phase (commit-per-green-substep mandate). To roll back,
  `git revert` the phase commit(s); no state outside the one file is affected.
- If Phase 1's build fails on the dense re-point after the explicit `(fc := FrameClass.Base)`
  fallback, restore the original branch code (the old lemmas remain compiled and importable —
  nothing is archived in this task), report the exact error, and mark the phase [BLOCKED]
  rather than improvising a new proof.
- If the axiom-profile comparison shows ANY drift, treat as defect: do not commit; diagnose the
  mis-wired branch (most likely a wrong hypothesis passed to `mcs_mixed_case_absurd` or a
  dropped case) before proceeding.
