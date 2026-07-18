# Implementation Plan: Adjudicate Rabinovich Faithfulness of the Phase-7 Negation-Case Unblock

- **Task**: 382 - Adjudicate rabinovich faithfulness of the phase 7 negationcase unblock
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None (parent task 379; produces the verdict that gates the dependent construction task 383)
- **Research Inputs**: specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/02_spawn-analysis.md (blocker analysis); specs/379_.../reports/06_phase4-unblock-construction.md (construction under adjudication)
- **Artifacts**: plans/01_adjudicate-rabinovich-faithfulness.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: false (read-and-adjudicate probe; no `Theories/` edits, no live-spine proof obligations; deliverable is a verdict report, plus at most one scratch `.lean` under `specs/` that is never imported)

## Overview

This is a read-and-adjudicate probe, not a construction task. Its single deliverable is a
GO / RECONCILE verdict report determining whether the ~870-1230-line negation-unblock stack
proposed in task 379's `reports/06_phase4-unblock-construction.md` is genuine, faithfully-transcribed
Rabinovich mathematics (GO) or an avoidable obligation manufactured by the repo's own
`EndpointPinnedCapTrivial`/`VecEA2`-translation choice (RECONCILE). Definition of done: a verdict
report under this task's `reports/` directory that (a) records Rabinovich's actual proof methods for
Lemma 3.2(1) (PDF p.4), the Lemma 3.4 conjunction-closure step (PDF p.5), and Prop 4.2's general
negation proof (Section 5, PDF pp.7-11), each cited by PDF page only; (b) answers the three named
cross-check questions; and (c) emits, for the dependent construction task 383, concrete Lean
signatures with line estimates for whichever route the verdict authorizes. Hard constraints: do not
edit `Theories/`; `lake build` must remain unaffected (any scratch `.lean` lives under `specs/` and
is never imported); cite Rabinovich by PDF page only (the companion `.md` transcription is corrupt).

### Research Integration

The blocker analysis (`reports/02_spawn-analysis.md`) supplies the framing and the three concrete
grounds for suspecting avoidable scope: (1) `Prop42ExistsForall.lean:23-28` self-describes the
endpoint-pin restriction as a `VecEA2`-translation artifact ("we do not extend `VecEA2` to carry
caps"), not a Rabinovich feature; (2) Lemma 3.2(2)'s <=2-free-var reduction (`augTarget` family) does
not currently guarantee the two target vars land at chain endpoints, and it is unestablished whether
it could be re-targeted to do so; (3) report-06's ~500-650-line order-preserving-interleaving
construction for Lemma 3.2(1) was invented this session without reading Rabinovich's own proof text
in detail. Report-06 is the construction being adjudicated and its §§1-3 signatures/line estimates
are the baseline the verdict confirms (GO) or replaces (RECONCILE).

### Prior Plan Reference

No prior plan for task 382. Report-06 is a construction proposal (reference/subject of
adjudication), not a prior plan; its phase-A/B/C/D dependency chain and line estimates are the
concrete claims this task tests against Rabinovich's own text, not a template to copy.

### Roadmap Alignment

`specs/ROADMAP.md` exists (topic: kamp-completeness) but no `roadmap_flag` was passed to this
dispatch; this plan performs no ROADMAP.md read/write. The task advances the Kamp-completeness
line by de-risking (or re-scoping) the Prop 4.3 negation-case unblock before any heavy construction
is authorized.

## Goals & Non-Goals

**Goals**:
- Re-derive, from the Rabinovich PDF only, the actual proof methods of Lemma 3.2(1) (p.4), the
  Lemma 3.4 conjunction-closure step (p.5), and Prop 4.2's general negation proof (Section 5, pp.7-11).
- Answer cross-check (1): is `EndpointPinnedCapTrivial` a repo-internal `VecEA2`-translation artifact
  or a genuine feature of Rabinovich's Prop 4.2 statement?
- Answer cross-check (2): can `augTarget`'s reduction target be re-stated to always land the two free
  variables at chain endpoints, eliminating the arbitrary-pin negation case, and at what size?
- Answer cross-check (3): does report-06's order-preserving-interleaving construction match
  Rabinovich's actual proof shape, or is it a heavier reinvention?
- Emit an explicit GO or RECONCILE verdict with concrete Lean signatures and line estimates for the
  dependent construction task 383.

**Non-Goals**:
- No `Theories/` edits of any kind; no new proofs on the live spine.
- No construction of `conjInterleave`, `veeConj`, or `prop42_veeSat_negation_general` (that is task
  383's scope, gated on this verdict).
- No re-litigation of already-settled findings: Lemma 3.2(1)/3.4 are load-bearing
  (`reports/05_...verdict.md`) and negation-bridge option (a) canonicalization is unsound
  (`reports/06_...` §3) — these are inputs, not questions to reopen.
- No citation of Rabinovich by anything other than PDF page.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `.md`/`.md.bak` transcription is corrupt and gets cited by accident | H | M | Read ONLY the `.pdf` (`Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`) via the `pages` parameter; cite page numbers only; never open the `.md`/`.md.bak` |
| Rabinovich's pp.7-11 proof is dense and its shape is ambiguous, yielding neither a clean GO nor RECONCILE | H | M | Phase 4 explicitly permits a third outcome: if adjudication is genuinely tied/ambiguous, record the specific unresolved question rather than forcing a verdict (task 383's spawn-analysis already anticipates this escalation branch) |
| Verdict emits Lean signatures that do not typecheck, misleading task 383 | M | M | Optional Phase 3 scratch `.lean` under `specs/` (never imported) to sanity-check any signature whose validity is load-bearing to the verdict; keep it minimal |
| Scratch `.lean` accidentally imported or placed under `Theories/`, perturbing `lake build` | H | L | Scratch file lives only under `specs/382_.../reports/`; verify `lake build` job count/exit unchanged is NOT required because nothing under `specs/` is on the import path — confirm the file has no `import Bimodal...` line that a stray build could pick up |
| Cross-check (2) `augTarget` re-targeting looks feasible on paper but hides a soundness gap | M | M | Treat any re-targeting claim as RECONCILE-only if it can be stated as a concrete Lean signature with a sketched proof obligation; otherwise flag as "candidate, needs construction-time confirmation" |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Extract Rabinovich's actual proof methods from the PDF [COMPLETED]

- **Goal:** Record, from the Rabinovich PDF only, the genuine proof shapes of the three target
  results — with page citations — as the faithfulness ground truth the cross-checks measure against.
- **Tasks:**
  - [ ] Open `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
        via `Read` with the `pages` parameter; do NOT open the corrupt `.md`/`.md.bak`.
  - [ ] Read p.4: Lemma 3.2(1) statement and its proof method (conjunction of ∃∀-formulas ⟺
        disjunction of ∃∀-formulas). Record whether the proof is a combinatorial chain-merge, an
        appeal to a prior normal form, or something else.
  - [ ] Read p.5: Lemma 3.4's conjunction-closure step ("By (1) and (3) of Lemma 3.2") and Prop 4.2's
        statement. Record exactly what (1) and (3) contribute and how ∧-closure is obtained.
  - [ ] Read Section 5, pp.7-11: Prop 4.2's general (non-endpoint-restricted) negation-closure proof.
        Record whether Rabinovich's Prop 4.2 object is stated for arbitrary pins from the start, and
        the actual method used to negate a single ∃∀ object (case analysis over order patterns, or
        otherwise).
  - [ ] Write a scratch notes block (in the eventual report, or a working file under `reports/`)
        capturing page-cited method summaries for each of the three results.
- **Timing:** ~1.25 hours
- **Depends on:** none
- **Verification:** Three page-cited method summaries exist (Lemma 3.2(1) p.4; Lemma 3.4 step p.5;
  Prop 4.2 general pp.7-11), each stating the proof SHAPE (not just the statement), with no citation
  to the `.md` transcription.

### Phase 2: Read the repo anchors and the report-06 construction [COMPLETED]

- **Goal:** Load the exact repo evidence the three cross-checks compare against Rabinovich's methods.
- **Tasks:**
  - [ ] Read `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ExistsForall.lean:1-90` —
        docstring + `EndpointPinnedCapTrivial` (`:75-86`), noting the `:23-28` self-description of the
        no-caps-on-`VecEA2` restriction and the `pinLeft`/`pinRight` fields.
  - [ ] Read `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean` — the Lemma
        3.2(2) <=2-free-var reduction: `augTarget`, `augTarget_iff`, `augTarget_forward`,
        `augTarget_backward`. Record the current reduction target's pin placement (where do the 2
        surviving free variables land relative to the chain?).
  - [ ] Read `reports/06_phase4-unblock-construction.md` §§1-3: the `conjInterleave` /
        `conjInterleave_iff` interleaving construction (§1, ~500-650 lines), `veeConj` (§2, ~120-180),
        and the option-(b) `prop42_veeSat_negation_general` bridge (§3, ~250-400).
  - [ ] Note the existing signatures verbatim (`efSat`, `veeSat`, `ExistsForallFormula` fields,
        `prop42_veeSat_negation` at `Prop42ExistsForall.lean:435`) so the verdict's signatures are
        expressed in the repo's actual types.
- **Timing:** ~0.75 hours
- **Depends on:** none
- **Verification:** Notes capture (a) `EndpointPinnedCapTrivial`'s exact fields and its docstring
  provenance, (b) `augTarget`'s reduction-target pin placement, and (c) report-06's three proposed
  signatures with their claimed line estimates, all in the repo's real type vocabulary.

### Phase 3: Cross-check analysis — the three faithfulness questions [COMPLETED]

- **Goal:** Decide each of the three cross-check questions by comparing Phase-1 Rabinovich methods
  against Phase-2 repo evidence, using an optional scratch `.lean` (under `specs/`, never imported)
  only where a signature's validity is load-bearing to the verdict.
- **Tasks:**
  - [ ] Cross-check (1): Determine whether `EndpointPinnedCapTrivial` is a repo-internal
        `VecEA2`-translation artifact or a genuine feature of Rabinovich's Prop 4.2. Ground the answer
        in Rabinovich's Def 3.1 / Prop 4.2 object arity (arbitrary pins vs. endpoint pins, PDF p.4/p.6)
        against `Prop42ExistsForall.lean:23-28,75-86`.
  - [ ] Cross-check (2): Determine whether `augTarget`'s reduction target can be re-stated to always
        land the two free variables at chain endpoints (which would route Phase 7 through the
        already-proved endpoint-pinned engine with no new interleaving machinery). If feasible, state
        it as a concrete Lean signature and estimate its size; if not, record why.
  - [ ] Cross-check (3): Determine whether report-06's order-preserving-interleaving method matches
        Rabinovich's actual Lemma 3.2(1)/Prop 4.2 proof shape, or is a heavier reinvention (e.g.,
        Rabinovich may prove Prop 4.2's general case directly in Section 5 without a standalone
        combinatorial merge).
  - [ ] (Optional) Write `reports/03_faithfulness-scratch.lean` under this task's directory ONLY if a
        specific signature/claim must be typechecked to settle a cross-check; it must contain no
        `import Bimodal...` and never be added to any lakefile target.
- **Timing:** ~1.25 hours
- **Depends on:** 1, 2
- **Verification:** Each of the three cross-check questions has an explicit answer with PDF-page and
  file:line grounding; any scratch `.lean` (if written) lives under `reports/`, has no live import,
  and leaves `lake build` untouched.

### Phase 4: Produce the GO / RECONCILE verdict report [COMPLETED]

- **Goal:** Write the deliverable verdict report with concrete Lean signatures and line estimates for
  the dependent construction task 383.
- **Tasks:**
  - [ ] Write `reports/01_go-reconcile-verdict.md` (advance the task's artifact sequence) stating the
        verdict explicitly: **GO** or **RECONCILE** (or, if genuinely tied/ambiguous, a recorded
        unresolved question that would escalate task 383 to `[BLOCKED]`).
  - [ ] GO branch: confirm report-06's construction (or a corrected version) as faithful and
        genuinely required at roughly the scoped size; record corrected Lean signatures / line
        estimates where they differ from report-06's §§1-3.
  - [ ] RECONCILE branch: record the concrete smaller construction plan — with its own Lean
        signatures and line estimate — that task 383 should build instead (e.g., re-targeted
        `augTarget` yielding endpoint pins, or a direct transcription of Rabinovich's pp.7-11 Prop 4.2
        general-case proof).
  - [ ] Ensure every Rabinovich reference in the report cites PDF page only; ensure the report names
        the exact repo signatures/types task 383 will consume.
  - [ ] Write `.orchestrator-handoff.json` at the task root (status `planned`→adjudication is a
        research-shaped dispatch; use the run's actual outcome status) summarizing the verdict and the
        next action for task 383.
- **Timing:** ~0.75 hours
- **Depends on:** 3
- **Verification:** `reports/01_go-reconcile-verdict.md` exists with an explicit GO/RECONCILE verdict,
  concrete Lean signatures + line estimates for task 383, and PDF-page-only Rabinovich citations;
  `.orchestrator-handoff.json` written; `Theories/` unmodified; `lake build` unaffected.

## Testing & Validation

- [ ] `git status --short Theories/` shows no modifications (read-only against the live spine).
- [ ] No file under `Theories/` was created or edited; any scratch `.lean` is under
      `specs/382_.../reports/` and contains no `import Bimodal...` line.
- [ ] `lake build` behavior is unaffected (nothing under `specs/` is on the import path).
- [ ] The verdict report contains an explicit GO or RECONCILE (or recorded-ambiguity) verdict.
- [ ] Every Rabinovich citation in the report is by PDF page only; the `.md`/`.md.bak` transcription
      is never cited.
- [ ] The report supplies concrete Lean signatures and line estimates in the repo's real type
      vocabulary for whichever route the verdict authorizes.

## Artifacts & Outputs

- `specs/382_adjudicate_rabinovich_faithfulness_of_the_phase_7_negationcase_unblock/plans/01_adjudicate-rabinovich-faithfulness.md` (this plan)
- `specs/382_.../reports/01_go-reconcile-verdict.md` (the deliverable verdict report)
- `specs/382_.../reports/03_faithfulness-scratch.lean` (optional; only if a claim must be typechecked; never imported)
- `specs/382_.../.orchestrator-handoff.json` (orchestrator handoff, written on completion)

## Rollback/Contingency

This task writes only under `specs/382_.../` and touches no build-relevant files, so there is
nothing to roll back on the live spine. If adjudication stalls (e.g., pp.7-11 proof shape cannot be
resolved from the PDF within budget), mark the current phase `[PARTIAL]`, record the specific
unresolved question in a partial verdict report, and write partial metadata with resume info — the
dependent construction task 383 must not be dispatched until a GO/RECONCILE (or explicit BLOCKED)
verdict exists.
