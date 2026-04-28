# Teammate D (Horizons): Strategic Analysis of the R-Relation Redesign

**Task**: 113 - Literature review: completeness techniques
**Date**: 2026-04-27
**Role**: Strategic implications, roadmap alignment, ideal end state
**Session**: sess_1777316607_f01b30

---

## Key Findings

### 1. Open Guard Is Unambiguously the Correct Semantics

The case is settled. Every published source on Since/Until tense logic -- Kamp 1968, Burgess 1982, Xu 1988, Reynolds 1992, Venema 1993 -- uses the open guard convention `(t, s)`. The paper (`possible_worlds.tex` lines 1242-1248) explicitly defines Until/Since with the open guard: "for all intermediate times y in D where x < y < z." The paper further defines Next as X(phi) := bot U phi (line 1249), which is coherent only under open guard (where the vacuously empty interval (t, t+1) on discrete orders makes bot hold trivially). Under the former half-closed guard `[t, s)`, this definition is always false -- semantically broken.

The half-closed guard in the codebase was an implementation artifact that contradicted both the paper and the entire temporal logic literature. The ROADMAP itself (lines 186-189) described the open guard while the code implemented half-closed. The switch to open guard is a correctness fix, not a design choice.

### 2. The Open Guard Change Has Already Begun and Is Well-Scoped

The `irr_until` branch (commit `6bfb80e7`) has completed Phase 1 of the open guard refactoring plan (task 113, plan v03):
- Truth.lean now uses strict `<` for both Until and Since guards
- 4 unsound axioms removed from Axioms.lean (`until_guard`, `since_guard`, `until_elim`/BX9, `since_elim`/BX9')
- Dead code archived to `Boneyard/ClosedGuardLegacy/` (4 files)
- Soundness.lean is actively being rebuilt (Soundness.lean shows diff with sorry stubs replaced by proofs for BX2/BX2', BX5/BX5', BX6/BX6')
- RRelation.lean has ~6 sorry stubs from the removal of `until_guard_in_mcs` and `since_guard_in_mcs`

The blast radius is well-characterized: ~116 references across 12 files, with 5 phases of work. Phases 1-2 (foundation + soundness) are at or near completion. Phases 3-5 (chronicle infrastructure, quasimodel/frame, cleanup) remain.

### 3. Impact on Task 107 Is Contained and Favorable

Task 107's implementation plan v21 (artifact 34) has 5 phases for closing 9 chronicle sorry sites. The interaction with the open guard refactoring is precisely scoped:

**Guard-independent phases** (no rework needed):
- Phase 1 (Lemma 2.6 for BurgessR3Maximal): Uses BX5, BX6, BX7, BX4 -- all sound under open guard.
- Phase 2 (7 c2' sorry sites): Constructs g-values via BurgessR3Maximal. DCS construction uses r-relation structure, not guard extraction.
- Phase 3 (g-immutability): Pure structural properties about g-values across omega-chain stages.
- Phase 5 (cleanup): No axiom dependency.

**One interaction point (Phase 4.1)**: The guard-at-intermediate-points lemma contains the step "from U(xi, eta) in f(t), by BX9 (until_elim), xi or eta in f(t)." BX9 is removed under open guard. The plan already documents the replacement: use the r-relation to propagate guard information through the BurgessR3Maximal construction rather than extracting it at the current point. This is a single derivation step in an otherwise guard-independent phase.

**The recommended sequencing is correct**: Complete task 107 Phase 1, then finish the open guard refactoring (task 113 Phases 3-5), then resume task 107 Phases 2-5 under the correct semantics. This writes all remaining chronicle code under open guard from the start, avoiding the need to patch Phase 4.1 later.

### 4. The Chronicle Construction Does NOT Fundamentally Depend on BX9

This is the critical strategic finding. The Burgess 1982 chronicle construction was designed for the standard open guard semantics. BX9 does not appear in Burgess's or Xu's axiom system Sigma4. The chronicle's reliance on guard extraction at the current point (`until_guard_in_mcs`) was an artifact of the codebase's non-standard half-closed guard, not a mathematical necessity.

Under open guard, the r-relation itself encodes all guard information. Xu Lemma 2.3(i) gives: for R(A, B, C), every alpha in A has S(alpha, top) in B. The guard enters g(t,s) through the BurgessR3Maximal construction from the Until seed, then lifts to limit_g via the intersection-based limit. This is the mechanism Burgess and Xu intended -- the codebase was taking a shortcut via BX9 that happened to work under half-closed guard but was never the canonical approach.

The transition from BX9-based to r-relation-based reasoning is thus a return to the mathematically intended construction, not a workaround.

### 5. The Boneyard Approach Is Correct

The plan archives dead code (4 axiom constructors, their soundness proofs, and dependent MCS lemmas) to `Boneyard/ClosedGuardLegacy/`. This is the right approach for several reasons:

1. **The archived code is mathematically wrong under the correct semantics.** `until_guard_in_mcs` derives gamma from gamma U delta at an MCS A, using the axiom (phi U psi) -> phi. Under open guard, this axiom is unsound -- the guard phi holds on the open interval (t, s), not at t itself. The lemma cannot be "redesigned in place" because its statement is false.

2. **Replacement infrastructure is structurally different.** The replacements use the r-relation structure (Xu Lemma 2.3(i)) rather than pointwise guard extraction. These are fundamentally different proof strategies, not variations on the same lemma.

3. **Boneyard preserves history.** The archived code documents the half-closed guard approach for future reference, which is useful for understanding the project's evolution.

4. **The code genuinely has no valid future use.** Unlike previous Boneyard items (e.g., oracle coherence) that represented viable-but-superseded approaches, the closed guard lemmas are provably unsound under the now-permanent open guard semantics.

### 6. The Axiom System After Refactoring

After the open guard refactoring completes, the BX axiom system should contain exactly **31 axioms** (down from 35):

| Layer | Axioms | Count |
|-------|--------|-------|
| Propositional | prop_k, prop_s, ex_falso, peirce | 4 |
| S5 Modal | modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist | 5 |
| BX Temporal | temp_k_dist, temp_4, serial_future, serial_past, left_mono_until/since, right_mono_until/since, connect_future/past, self_accum_until/since, absorb_until/since, linear_until/since, until_F/since_P, temp_linearity/past, F_until_equiv/P_since_equiv | 20 |
| Modal-Temporal | modal_future, temp_future | 2 |

**Removed**: BX8/BX8' (already removed -- not sound under irreflexive semantics), BX9/BX9' (not sound under open guard), until_guard/since_guard (not sound under open guard).

This 31-axiom system matches Xu 1988's Sigma4 (adapted for S5 modality and irreflexive strict ordering with seriality). It is the minimal sound and complete axiomatization for the bimodal TM logic over all strict linear orders.

### 7. The Ideal End State

After task 107 and task 113 are both complete, the formalized system should satisfy:

**Axiom system**: 31 axioms, all provably sound under open guard irreflexive semantics. Soundness theorems sorry-free (already achieved for all but the match-arm cleanup in progress).

**Completeness proof**: `dd_countermodel_chronicle` sorry-free, using the Burgess 1982 chronicle construction with:
- Open guard Until/Since semantics matching the paper and literature
- Controlled PointInsertion escaping Lindenbaum opacity
- Binary g(x,y) interval function (not the former unary g)
- BurgessR3Maximal providing DCS structure for the r-relation
- Limit construction via intersection-based limit_g

**Representation theorem**: "TM is complete with respect to TaskFrames over totally ordered abelian groups." This is the paper's primary formalization goal. The chronicle construction achieves this as Path B (D=Rat completeness, task 107).

**Paper alignment**: The formalized semantics exactly matches the paper's definitions at lines 1242-1248 (open guard Until/Since), line 1249 (Next/Previous definability), and the axiom system presented in Section 3.4. The paper currently states soundness (proved) and conjectures completeness (line 1485: "Completeness of TM with respect to the class of task frames is conjectured but unproved"). The formalization will upgrade this from conjecture to theorem.

**BXCanonical path**: The 19 sorry sites in BXCanonical become secondary -- task 109 can be deprioritized once the chronicle path succeeds. The 5 critical-path sorries in RootScopedChain.lean become dead code (completeness is established through the chronicle, not through BXCanonical). The 14 irreflexive-consequence sorries remain independently valuable for cleanup but are not on the critical path.

---

## Strategic Recommendations

### Recommendation 1: Maintain the Current Sequencing Strategy

The current plan -- task 107 Phase 1 (Lemma 2.6), then task 113 Phases 3-5 (open guard infrastructure), then task 107 Phases 2-5 (chronicle completion) -- is the optimal sequencing. It minimizes wasted work, ensures all remaining chronicle code is written under the correct semantics, and isolates the two cross-cutting changes (Lemma 2.6 and open guard) into separate phases.

### Recommendation 2: Deprioritize BXCanonical (Task 109) Permanently

After the chronicle path succeeds, the BXCanonical path should be treated as cleanup, not completeness infrastructure. The 5 critical-path sorries in RootScopedChain.lean are blocked by Lindenbaum opacity (dead ends 34-36) and have no known solution. The chronicle construction escapes this fundamental obstruction. Once `dd_countermodel_chronicle` is sorry-free, the BXCanonical sorries should be either (a) documented as "alternative path, not needed for completeness" or (b) deleted if they serve no pedagogical purpose.

### Recommendation 3: Update the Paper's Completeness Status After Task 107

The paper currently says "Completeness of TM with respect to the class of task frames is conjectured but unproved" (line 1485). Once task 107 produces a sorry-free `dd_countermodel_chronicle`, the paper can be updated to claim completeness as a formalized theorem, which is a significant scholarly contribution. The paper should also be updated to include the Since/Until axioms (line 1260 currently says "Extending TM to include S and U is outside the scope of the present paper") or at minimum reference the formalization as establishing completeness for the extended system.

### Recommendation 4: Do Not Add Replacement Axioms for BX9

Report 02 considered Option C (adding replacement axioms to recover BX9's proof-theoretic power). This is unnecessary. Xu's completeness proof works without BX9 entirely. The 31-axiom system after removal is already complete. Adding non-standard axioms would diverge from the literature and create maintenance burden for no mathematical gain.

### Recommendation 5: Treat the Open Guard Refactoring as a Prerequisite for Publication

The paper's semantics uses open guard. The formalization must match. Any claim in the paper that references the Lean formalization (currently: soundness at line 2594) requires the formalization to implement the paper's semantics. The open guard refactoring is therefore a publication prerequisite, not merely a code quality improvement.

---

## Roadmap Alignment

The open guard refactoring (task 113) and chronicle completion (task 107) together constitute the critical path to the project's central goal: the representation theorem. Here is how they align with the ROADMAP priorities:

| ROADMAP Priority | Status | How This Refactor Fits |
|------------------|--------|----------------------|
| Chronicle construction (task 107) | IN PROGRESS, Phase 1 | Refactor aligns code with the mathematics Burgess/Xu assumed |
| Representation theorem (D=Rat) | BLOCKED on task 107 | Unblocked once chronicle sorry-free under correct semantics |
| General completeness (all strict linear orders) | Stretch goal | Same chronicle, different frame class |
| BXCanonical sorry closure (task 109) | LOW PRIORITY | Becomes dead code for completeness once chronicle succeeds |
| Literature alignment (task 112) | RESEARCHED | Open guard aligns formalization with all cited sources |
| Paper publication | DEPENDENT | Open guard is publication prerequisite |

The refactoring does not conflict with any ROADMAP item. It advances the primary completeness path by aligning the formalization with the mathematical literature that the chronicle construction follows.

---

## Confidence Level

**High (9/10)** for all findings.

The open guard semantics question is definitively settled by the literature. The impact analysis on task 107 is precise because the plan explicitly documents axiom dependencies at each phase. The Boneyard strategy is straightforward because the archived code is provably unsound. The ideal end state is well-defined by the paper's stated goals and the ROADMAP's representation theorem target.

The one area of moderate uncertainty (hence 9/10 rather than 10/10) is the Xu Lemma 2.3(i) infrastructure replacement for `until_guard_in_mcs` in RRelation.lean. While the mathematical approach is clear and documented, the Lean implementation involves reconstructing ~6 proofs that currently use guard extraction with r-relation-based reasoning. The total effort for this replacement (estimated at 6 hours in the plan) could exceed the estimate if unexpected dependencies surface in the quasimodel/filtration infrastructure. However, the fallback -- using sorry stubs temporarily and continuing with the chronicle -- is always available.
