# Implementation Plan: DConsistencyTransport "not a sorry" Docstring Fix
- **Task**: 388 - dconsistencytransport_not_a_sorry_docfix
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_docfix-wording-research.md
- **Artifacts**: plans/01_docfix-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/lean4.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4

## Overview

The docstrings of `d_consistency_left` (declaration at
`Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean:56`,
offending sentence at lines 53-55) and `d_consistency_right` (declaration at :150, offending
sentence at :149) falsely claim the interior case is "sorry'd". Both proof bodies are
sorry-free: the interior cases are discharged via `exact h_interior_d ...` (lines 142 and 234),
where `h_interior_d` is an explicit hypothesis parameter (lines 80 and 173) supplied by the
caller in `SplitPoint.lean:900-907`. This plan rewords both docstrings per the research
report's recommended wording (Finding 5). Comment-only change; zero proof-term edits.
Definition of done: both docstrings reworded, targeted build green, no remaining false-sorry
claims, no task-number references in the .lean file.

**Source-to-implementation mapping** (H3, Tier 3 — implementation-backed):

| Plan decision | Source |
|---------------|--------|
| Replacement wording (both docstrings) | Research report Finding 5 (recommended wording) |
| Mandatory tokens: "hypothesis-gated", backticked `h_interior_d`, "NOT a sorry" | Research report Finding 5 constraint + task directive |
| Fact: bodies are sorry-free, all 3 `sorry` tokens are in docstrings | Research report Finding 2 (exhaustive grep, verified against file lines 54, 55, 149) |
| Docstring convention (name hypothesis param + supplier) | Research report Finding 4 (`Kamp/NfMultiAnchorBridge/Base.lean:178-180, 217-220`) |
| Targeted build module path | Research report Finding 7 (`lakefile.lean`: `lean_lib Bimodal`, `srcDir := "Theories"`) |

## Postmortem Constraints

Binding rules for the implementation dispatch. No prior failed attempts exist; rules derive
from the research report and task constraints.

**Do NOT**:
- Edit anything other than the two docstring comment blocks — no proof terms, no signatures,
  no hypothesis parameters, no inline `--` comments inside the proofs (the inline comments at
  lines 76-79 and 170-172 are already correct and must be left untouched).
- Add task-number references (e.g. "task 388") to the .lean file — forbidden by
  `no-task-references-in-deliverables.md`.
- Drop any of the three mandatory tokens from the new wording: "hypothesis-gated", backticked
  `h_interior_d`, "NOT a sorry".
- Skip the targeted build on the grounds that the change is comment-only — a malformed
  docstring delimiter (`-/`) breaks compilation; the build gate is load-bearing.

**MUST preserve**:
- Both theorem statements, hypothesis lists, and proof bodies byte-for-byte.
- The correct portions of both docstrings (everything before the offending sentences).

**Design decisions are SETTLED** (do not re-open):
- Wording follows research report Finding 5. The phrase "hypothesis-gated" is deliberately new
  to the repo (zero prior hits — Finding 4/Contradiction Log); the sibling Kamp files establish
  the structural convention (name the hypothesis, its role, and its supplier), not the literal
  phrase. Do not search for or substitute an "established phrase" instead.

## Goals & Non-Goals

- **Goals**: Remove both false "sorry'd" claims; state accurately that the interior case is
  hypothesis-gated via `h_interior_d` and that both proofs contain no `sorry`.
- **Non-Goals**: Any proof change; rewording other docstrings or the inline comments; touching
  `SplitPoint.lean` or any other file.

## Risks & Mitigations

- Risk: Breaking the `/-- ... -/` docstring delimiter while editing. Mitigation: exact
  old/new text specified below; targeted build gate catches any syntax breakage.
- Risk: New wording itself contains the substring `sorry` (intentionally, in "NOT a sorry" /
  "no `sorry`"), so a naive `grep sorry` still hits. Mitigation: verification grep targets the
  false-claim patterns (`sorry'd`, `sorry-free for boundary`) specifically, not the bare word.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Single-phase plan; no parallelism.

### Phase 1: Reword both false-sorry docstrings in DConsistencyTransport.lean [COMPLETED]

- **Goal:** Both docstrings accurately describe the hypothesis-gated interior case; targeted
  build green. Estimated output: ~12 changed lines (one file). Done when: all three
  verification gates below pass.
- **Tasks:**
  - [x] Edit 1 — `d_consistency_left` docstring
    (`Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`,
    lines 53-55). Replace OLD:

    ```
        same_order_type. Boundary cases (x'=d, d=y') are fully proved.
        Interior case uses the forward strategy's response directly (sorry-free
        for boundary cases; interior case sorry'd pending Claim 1). -/
    ```

    with NEW:

    ```
        same_order_type. Boundary cases (x'=d, d=y') are fully proved. The
        interior case is hypothesis-gated (discharged via the `h_interior_d`
        parameter, supplied at the call site via rank_down(h_fwd_r1) + K⁻(¬D)),
        NOT a sorry — this proof contains no `sorry`. -/
    ```

  - [x] Edit 2 — `d_consistency_right` docstring (same file, line 149). Replace OLD:

    ```
        Boundary cases proved; interior case sorry'd (same blocker as left). -/
    ```

    with NEW:

    ```
        Boundary cases proved; the interior case is hypothesis-gated
        (`h_interior_d` parameter, same call-site construction as left),
        NOT a sorry — this proof contains no `sorry`. -/
    ```

  - [x] Verification gate (all three must pass):
    1. False-claim grep is empty:
       `grep -n "sorry'd\|sorry-free for boundary" Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`
       returns zero hits (remaining `sorry` mentions are only the new accurate wording).
    2. No task-number references:
       `grep -Ein "task [0-9]" Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`
       returns zero hits.
    3. Targeted build green:
       `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.DConsistencyTransport`
- **Timing:** ~15 minutes including build.
- **Depends on:** none

## Testing & Validation

- [x] Gate 1: false-claim grep empty (see Phase 1).
- [x] Gate 2: task-number-reference grep empty (see Phase 1).
- [x] Gate 3: `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.DConsistencyTransport`
      exits 0. Full `lake build` is NOT required — comment-only change in one module.
- [x] Diff sanity: `git diff` for the file shows changes confined to the two docstring blocks.

## Artifacts & Outputs

- plans/01_docfix-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`
  (two docstrings only)
- summaries/01_docfix-summary.md (written by implementer)

## Rollback/Contingency

- Single-file revert: run `bash .claude/scripts/git-snapshot.sh`, then
  `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`
  (snapshot first per the destructive-git guard hook). No other files are touched, so no wider
  rollback is ever needed.
