# Review: Pre-Refactor Milestone Path

**Date**: 2026-07-29
**Scope**: Open-task portfolio — sequencing work ahead of the Paper Refactor tasks (414, 415, 417, 419, 420, 427)
**Reviewed by**: Claude

## Summary

The paper-refactor cluster will rewrite the semantics core: 414 makes maximal-history validity
THE validity of the repo, deleting the `Omega`/`ShiftClosed` parameters everywhere, propagating
through Soundness; 415 internalizes completeness under the new semantics; 420 aligns `TaskFrame`
with the positive-cone `def:frame`. Anything stated against `Omega`-parameterized validity or
documenting the current definitions will be revised. The pre-refactor milestone should therefore
consist of work that is **proof-theoretic, order-theoretic, or actively reduces refactor churn**
— plus the one semantics-coupled exception (165 Phase 7) whose value justifies a known rebase
cost.

## Key Findings

### 1. Task 165 is stale-BLOCKED (High)

165's only dependency, 418 (unsound group-3 block removal), is **completed**. The plan shows
Phases 1-6 [COMPLETED], Phase 7 (truth lemma + Track A decidability — the MILESTONE phase)
[BLOCKED] on exactly the 418 fix that has now landed, Phase 8 (hygiene) [IN PROGRESS]. The task
is resumable today; only its status marker is out of date.

**Caveat**: Phase 7 constructs genuine `WorldHistory`s and a shift-closed `Omega` — the one
semantics-coupled piece in the batch. It WILL need rebasing under 415's Omega-free semantics.
Recommendation is to accept that cost: rebasing an existing machine-checked bridge is far
cheaper than inventing it, 415's charter already includes downstream metalogic rebasing, and
Phase 7 is what converts Phases 1-6 (~sunk 50h) into the decidability headline.

### 2. Task 193 is unblocked AND is refactor-synergistic (High)

193's dependency (402, the Mathlib naming upgrade) is completed. Its content — collapsing ~146
`intro F M Omega _h_sc τ _h_mem t` sites and ~131 `simp only [TruthAt …]` bundles across
SoundnessLemmas/DenseValidity.lean, SoundnessLemmas/FrameClassVariants.lean, and Soundness.lean
into 4 syntactic macros — is precisely the churn-reducer for 414: after 193, the Omega-removal
edits **four macro definitions** instead of ~277 proof sites. Sequencing 193 BEFORE the paper
refactor is not merely safe, it makes the refactor cheaper. This confirms the user's instinct.

### 3. Tasks 177/178 should come AFTER the refactor, not before (High)

Both are chartered as final passes: 177 "final documentation pass after all structural
refactoring is complete"; 178 publication-quality examples exercising the full pipeline. Run
before 414/415/420 they would document and demonstrate definitions about to change (`TruthAt`,
`valid`, `TaskFrame`, `Omega`) and be redone wholesale. Their only live dependency is 193 (131
and 402 are completed), so they stay ready — but they belong in the post-refactor close-out
wave, alongside 427 (typst book sync).

### 4. Task 179 is terminally researched (Medium)

179 (research_lean4_tactics_infrastructure) produced its team-research reports in 2026-05; its
actionable content was carried into the (now archived) tactic survey 196 and from there into
193's re-scope. Teammate C's finding stands: existing search-family tactics have near-zero
adoption, and 193 explicitly rules elaborated tactics out of scope. Nothing remains to plan or
implement under 179. Recommend closing it as research-complete rather than sequencing it.

### 5. Task 408 tail is largely refactor-immune (Medium)

27/31 phases complete. The remainder — `doets_lemma_1_5` (coloured-index mixing lemma
generalizing NEquivalence.lean's sum induction), its `hcol` back-and-forth hypothesis, Phase 28
(`orderIsoRealOfDedekindDenseSeparable`), Phase 29 (Doets' Theorem), Phase 30 (Reynolds §9
engine + terminus) — is monadic-FO/order theory over ℚ/ℝ, untouched by the Omega refactor. Only
Phase 30's final wiring into `completeness_dedekind_of_engine` (StrongCompleteness.lean:308)
touches current semantics, a small surface 415 will rebase anyway. Finishing 408 before the
refactor is right; abandoning a 90%-complete Reynolds formalization across a semantics rewrite
would be far worse.

### 6. Track B (410-412) is refactor-proof but under-sequenced (Medium)

410/411/412 are Hilbert-system admissibility lemmas and the refutation core — pure proof
theory, immune to the semantics refactor (412's completeness corollaries and the
`countermodel_discrete` discharge have a small semantic surface). But state.json gates all
three only on 165, while the true order is **410 → 411 → 412**: 411's `z1Rule` lemma "relies on
same-label internalization from the predecessor task" (410), and 412's single induction
consumes every admissibility lemma from both. Dependencies should be added before any batch
dispatch, or the orchestrator will co-dispatch them in one wave and 411/412 will stall or race.

### 7. Redundant Dedekind engines — 408 vs 412 (Medium)

Both 408 (Reynolds transfer route) and 412 (tableau route) are chartered to supply "the
Dedekind engine consumed by `completeness_dedekind_of_engine`". Not a conflict — 408 lands
first in any schedule and 412's Dedekind corollary becomes confirmatory — but the 412 dispatch
should be told the engine may already exist, so it doesn't re-derive or clobber it.

### 8. Task 426 shares 165's territory (Low)

426 (settle whether the engine can positively refute `(G p) → □(G p)`) probes exactly the
formula and engine 418 fixed and 165 Phase 7/8 operate on. Sequence it after 165, never
concurrent with it.

### 9. Close-out candidates (Low)

- 170: "SUBSTANTIVELY CLOSED. NO IMPLEMENTATION AGENT SHOULD BE DISPATCHED" — mark completed.
- 390: "RESOLVED (research complete). VERDICT: GO…" — mark completed.
- 179: per Finding 4.

### 10. Defer to post-refactor (classification)

| Task(s) | Reason |
|---------|--------|
| 169, 362, 421, 422, 423, 424, 425 | Strong-completeness architecture: 415 internalizes completeness under the new semantics; building more of this layer against Omega-validity now is rework. (423's `SetDerivable` half is proof-theoretic, but its `SetSemanticConsequence` half parallels the exact binder lists 414 rewrites.) |
| 413 | Formalizes a paper theorem (`thm:ConservativeExtension`) from the paper being refactored. |
| 419, 427 | Paper-refactor wave proper (419 feeds 427). |
| 177, 178 | Finding 3. |
| 95 | Optional exception: as milestone capstone (verify + record axiom/sorry status of headline results) it is best run at the END of the pre-refactor batch — include as final wave, or run standalone once the batch lands. |

Orthogonal axes not on this milestone (unaffected either way, user's discretion): 219, 231,
257, 282, 296, 298 (dataset-enhancement), 321 (Kamp), 125 (algebraic), 127/128
(frame-extensions).

## Recommended Path

One multi-task orchestration (fits MAX_TASKS=8), after adding the sequencing dependencies
below:

```
/orchestrate 408, 165, 193, 410-412, 426, 95 --hard --lit
```

Dependency edits first (state.json): 411 += [410]; 412 += [410, 411]; 426 += [165];
95 += [408, 165, 412]. Resulting waves:

| Wave | Tasks | Notes |
|------|-------|-------|
| 1 | 408, 165, 193 | Disjoint territories: WeakCanonical/RealModel + NEquivalence / Decidability/ / SoundnessLemmas + Soundness.lean |
| 2 | 410, 426 | 410 opens Verified/Internalize + routine Rules/; 426 probes the now-repaired engine |
| 3 | 411 | Hard admissibility block (untlNeg budgeted its own dispatch) |
| 4 | 412 | Refutation core, Decidable(Derivable), countermodel_discrete discharge |
| 5 | 95 | Milestone capstone: verify + record axiom/sorry status |

**Build-contention caution**: Wave 1 co-dispatches three Lean tasks in one clone. The 418
postmortem records concurrent sessions destroying `.olean` files mid-build. The orchestrator's
wave-split check covers file overlap but not `lake build` contention; if that risk is
unacceptable, run Wave 1 as {408, 165} and let 193 join Wave 2 (it is one mechanical dispatch).

**Milestone definition**: batch lands → zero sorries repo-wide outside Boneyard (Transfer.lean:1242
discharged by 412; ShuffleReal.lean:201 by 408), decidability + completeness headlines for all
four frame classes, soundness layer macro-compressed, 95's verification record committed → tag
→ begin paper-refactor wave (420 → 414 → 415/417 → 419 → 427, with 177/178 as post-refactor
close-out after 193's macros absorb the new binder shape).

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Live sorries (outside Boneyard) | 2 (Transfer.lean:1242; ShuffleReal.lean:201 strategic) | Tracked, both discharged by this batch |
| 408 phases | 27/31 complete | On track |
| 165 phases | 6/8 complete, Phase 7 unblocked | Stale BLOCKED marker |
| Stale statuses | 165 (blocked→resumable), 170/390 (closable) | Cleanup |
