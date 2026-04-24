# Teammate D (Horizons): Strategic Alignment Analysis

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Round**: 7
**Angle**: Horizons - long-term alignment and strategic direction
**Date**: 2026-04-23

---

## Key Findings

### 1. Task 107 vs Task 109: Chronicle Renders Task 109 Obsolete on the Critical Path

The most significant strategic finding is that the chronicle rewiring has already made task 109 obsolete as the critical-path blocker. `Completeness.lean` now calls `dd_countermodel_chronicle` (not `dd_countermodel`), so the 3 sorry sites in `RootScopedChain.lean` are dead code from the standpoint of `bx_completeness`. The 5 critical-path sorries documented in the ROADMAP for task 109 are no longer blocking.

However, task 109 should NOT be abandoned. The 14 "irreflexive-consequence" sorries that task 109 also owned (in Frame.lean, TruthLemma.lean, CanonicalModel.lean, Construction.lean, Realization.lean, SigmaOrdering.lean) are also dead code relative to the chronicle path. But the structural reason those sorries exist is the same architectural shift that motivates the chronicle: the irreflexive semantics on the `irr_until` branch requires redesigning assumptions that were valid under reflexive semantics. Task 109 should be marked `[ABANDONED]` or `[EXPANDED]` with a note that its goal (sorry-free `bx_completeness`) has been subsumed by task 107 via the chronicle approach.

The practical recommendation: re-scope task 109 as cleanup/archival of the dead RootScopedChain and Quasimodel sorry sites now that the chronicle is the authoritative path.

**Confidence**: High. The ROADMAP documents that `Completeness.lean` is sorry-free and delegates to `dd_countermodel`. The implementation summary for task 107 confirms `Completeness.lean` was rewired. The sorry counts verify RootScopedChain is no longer on the critical path.

---

### 2. Sorry Count Trajectory: Progress, Not Regression

The swap of 2 eliminated sorries (ParametricTruthLemma) for 20 new chronicle sorries appears at first to be regression, but it is structural progress for three reasons:

**Reason 1: Tractability.** The 3 RootScopedChain sorries were blocked by the "irreducible Lindenbaum obstruction" — 36 failed dead ends documented in the ROADMAP, with all three attack paths (C, A, B from plan v44) simultaneously blocked. The 20 chronicle sorries correspond to specific lemma obligations in Burgess 1982, a peer-reviewed construction. None of the 20 are in the "mathematically false as stated" category (unlike 4 of the 11 task-109 sorries that the ROADMAP describes as "genuinely unprovable").

**Reason 2: Granularity.** The 20 chronicle sorries break one opaque architectural gap (Lindenbaum opacity at chain level) into 20 discrete mathematical obligations: 1 guard consistency lemma, 4 point insertion cases, 2 Rat helper lemmas, 4 limit construction properties, and 9 FMCS coherence proofs. Each has a clear proof path in the paper.

**Reason 3: Architecture replacement.** The old sorry sites were in RootScopedChain.lean (1,487 lines) which also served as the main chain construction. The chronicle approach adds 2,764 lines of new infrastructure that replaces the chain entirely. The net technical debt is lower: the old approach had 5 critical-path sorries with no viable proof path; the new approach has 20 sorries, each with a corresponding lemma in Burgess.

**Realistic timeline**: The sorry distribution suggests 3-4 independent proof campaigns:
- Campaign 1: `until_guard_consistent` in RRelation.lean (1 sorry, Lemma 2.2 — guard consistency under strict Until, medium difficulty)
- Campaign 2: PointInsertion lemmas (4 sorries, Lemmas 2.6-2.8 — BX7/BX5/BX6 algebra, high difficulty, requires careful axiom tracking)
- Campaign 3: CounterexampleElimination + ChronicleConstruction (6 sorries, Lemmas 2.9-2.10 + limit construction — moderate difficulty, some Rat ordering helpers)
- Campaign 4: ChronicleToCountermodel (9 sorries, FMCS G/H coherence + restricted conditions — high difficulty, requires full C5/C5' satisfaction)

Estimated total: 30-60 hours across 4 campaigns, with Campaign 4 being the hardest (it requires that Campaigns 1-3 are done first because it depends on the full chronicle satisfying C5).

---

### 3. irr_until Branch Strategy

The `irr_until` branch has now diverged significantly from `main` in its approach to completeness:

| | main branch | irr_until branch |
|---|---|---|
| Completeness path | `dd_countermodel` (5 sorries, blocked) | `dd_countermodel_chronicle` (20 sorries, tractable) |
| Semantic model | Reflexive G/H/U/S | Strict (irreflexive) G/H/U/S |
| Key infrastructure | RootScopedChain.lean (1,487 lines) | Chronicle/ (2,764 lines) |
| Axiom set | BX 35 axioms (includes BX1, BX8, BX9) | BX 35 axioms (BX1=seriality, no BX8, BX9=strict guard) |

The merge question hinges on what the project's canonical semantics should be. From the ROADMAP, the irreflexive semantics on `irr_until` represents a completed semantic rewrite (task 93). The `main` branch has reflexive semantics with the same irreducible Lindenbaum obstruction that task 93 was designed to resolve.

**When to merge**: The `irr_until` branch should become `main` once `bx_completeness` is sorry-free — not before. The current 20 sorry sites mean `irr_until` is ahead architecturally but not yet at publication readiness. Merging early would put 20 sorries into main, which is worse than the 5 sorries currently on main's critical path.

**Chronicle and reflexive semantics**: The Burgess chronicle construction was designed for strict semantics (Burgess 1982 uses strict Until). It is NOT directly applicable to reflexive semantics without the A3a/A4a gate (which the round-6 research found is definitively closed by counterexample under reflexive semantics). This means the chronicle approach is specific to `irr_until` — it cannot backport to `main`.

**Unification strategy**: There are two options:
1. Complete the chronicle on `irr_until` first, then make `irr_until` the new `main`.
2. Abandon `main`'s reflexive semantics and cherry-pick the chronicle infrastructure.

Option 1 is the lower-risk path. The irreflexive semantics on `irr_until` is the mathematically preferred form (user's stated preference, more expressive, avoids the Lindenbaum obstruction). Once sorry-free, `irr_until` should be the canonical branch.

**Confidence**: Medium-high. The branch strategy depends on whether the project commits to irreflexive semantics permanently (which appears to be the intent, given that the irr_until branch was created for exactly this purpose).

---

### 4. Publication Readiness

**Minimum viable sorry-free theorem**: The current architecture gives a clear ladder:
1. `bx_completeness` sorry-free (requires closing all 20 chronicle sorries)
2. Axiom audit via `#print axioms bx_completeness` confirming only `{propext, Classical.choice, Quot.sound}` plus Lean.ofReduceBool/trustCompiler from native_decide
3. Completeness.lean already documents the target state

The completeness theorem as currently structured (contrapositive via chronicle BFMCS over Rat) is mathematically sound as a publication-quality result. The key components that constitute the contribution are:
- The BX axiom system (35 axioms for bimodal S5 + irreflexive linear temporal)
- The chronicle construction over Q (Rat in Lean)
- The truth lemma and parametric representation theorem

**Box+G+H-only path**: The round-6 synthesis documents a faster path — a Box+G+H-only representation theorem could be done in 8-15 hours (zero sorry sites arise from Box/G/H alone under strict semantics). This would be a publishable result for the S5 + strict temporal fragment, but it does NOT establish the Until/Since completeness that is the stated goal of the project.

The recommendation is to NOT take the Box+G+H shortcut for publication unless the timeline requires an interim publication. The chronicle-based full completeness theorem is the stronger result and the infrastructure is now largely in place (2,764 lines built, 20 specific sorries to close).

**Publication-quality criteria**: A paper-worthy formalization needs:
- Zero sorries in the completeness proof and its dependencies
- No custom axioms (currently satisfied: zero custom axioms per state.json)
- Soundness and completeness both sorry-free (Soundness.lean is already entirely sorry-free)
- Clean axiom audit

The current state: soundness is done, completeness has 20 tractable sorries. The gap is one concentrated campaign on the chronicle construction.

**Confidence**: High for the goal assessment; medium for timeline (30-60 hours estimate has uncertainty in Campaign 4).

---

### 5. Adjacent Opportunities

**Task 68 (dense completeness via Rat canonical model)**: This task shares infrastructure with the chronicle approach. The chronicle constructs a model over Rat (Q) — exactly what task 68 needs for the dense canonical model. The `ValidChronicle` structure over Q could be the foundation for both the discrete-order completeness (task 107's goal) and the dense completeness (task 68's goal). If the chronicle infrastructure is generalized to handle both seriality (discrete) and density as instances, task 68 could be resolved as a corollary of the chronicle construction. This synergy should be explored once the chronicle sorry sites are closed.

**Task 95 (verification audit)**: This task depends on sorry-free `bx_completeness`. Once all 20 chronicle sorries are closed, task 95 is a straight `#print axioms` run — about 2-4 hours of work. The ROADMAP already documents the expected output. Task 95 unblocks immediately upon task 107 completion.

**Task 992 (STSA representation theorem)**: The chronicle infrastructure is compatible with the STSA algebraic framing. The Lindenbaum quotient algebra (TenseS5Algebra instance, already sorry-free per task 64) and the chronicle construction are independent proofs of the same completeness result — one algebraic, one model-theoretic. Task 992 could reference the chronicle as the canonical-model instance while the STSA provides the algebraic abstraction. This is future work after task 107 completes.

**Task 109 (close chain construction sorries)**: As argued in Finding 1, task 109 should be re-scoped. The constructive action: update task 109's description to "archive dead RootScopedChain and Quasimodel sorry infrastructure" and link it as cleanup following task 107's completion. This prevents confusion about two parallel efforts targeting the same goal.

---

## Recommended Approach

### Priority and Sequencing

**Immediate (task 107, current)**: Close the 20 chronicle sorries in 4 campaigns, in dependency order:
1. RRelation: `until_guard_consistent` (Campaign 1, unblocks PointInsertion Campaign 2)
2. PointInsertion: Lemmas 2.6_strong, 2.7 D2, 2.8 eta-in-C (Campaign 2, unblocks ChronicleConstruction)
3. CounterexampleElimination + ChronicleConstruction: Rat helpers, limit C5/C5', enumeration (Campaign 3)
4. ChronicleToCountermodel: FMCS G/H coherence, box stability, restricted conditions (Campaign 4, last because depends on full C5 from Campaign 3)

**Upon task 107 completion**: Run task 95 immediately (axiom audit, 2-4 hours).

**Re-scope task 109**: Change status to reflect its goals have been subsumed. New scope: archive/cleanup of dead-code sorry infrastructure in RootScopedChain.lean, Quasimodel/, and Filtration/ that is no longer on the critical path.

**Merge strategy**: Merge `irr_until` to `main` after `bx_completeness` is sorry-free on `irr_until`. This makes the irreflexive semantics the canonical project semantics.

**Explore task 68 synergy**: After chronicle is sorry-free, check whether the Q-indexed chronicle can serve as the dense canonical model for task 68 dense completeness.

### What NOT to do

- Do NOT take the Box+G+H shortcut for the publication version (unless an interim publication is specifically desired)
- Do NOT merge `irr_until` to `main` before the 20 chronicle sorries are closed
- Do NOT invest more effort in the main branch's RootScopedChain sorries — they are now architecturally superseded

---

## Evidence and Examples

**ROADMAP confirmation of critical path change**: The ROADMAP documents `dd_countermodel` (in RootScopedChain.lean) as the critical-path blocker. `Completeness.lean` (now sorry-free) has been rewired to call `dd_countermodel_chronicle`. This is confirmed by the Completeness.lean header comment: "The completeness proof is wired through `dd_countermodel_chronicle` from Chronicle/ChronicleToCountermodel.lean."

**Sorry count verification** (from current codebase):
- Chronicle/ (new): 20 sorries (4 + 9 + 0 + 2 + 4 + 1)
- RootScopedChain.lean (now dead code): 3 sorries still present but off critical path
- TruthLemma.lean: 2 sorries (irreflexive-consequence, also off critical path)
- Frame.lean: 1 sorry (bx_le_refl, intentionally invalid)
- Quasimodel/: 6 sorries (dead code for the chronicle path)
- Filtration/: 3 sorries (dead code for the chronicle path)

**State.json status**: task 107 is "researching", task 109 is "planned". Given that Phases 1-5 of task 107's implementation plan are all marked [PARTIAL] or [COMPLETED] with 2,764 lines of chronicle code already written and completeness rewired, the status should be "implementing" or "partial" — it has progressed far beyond research.

**Branch divergence**: The `irr_until` branch has 20 tractable sorries. The `main` branch has 5 critical-path sorries that all major attack paths have failed to close (36 dead ends in ROADMAP). The asymmetry strongly favors completing the chronicle on `irr_until` and making it canonical.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Task 109 is superseded on the critical path | High — Completeness.lean rewiring is confirmed in code |
| 20 chronicle sorries are more tractable than the 3 they replaced | High — each has a corresponding Burgess lemma; none are "mathematically false as stated" |
| irr_until should become main after sorry-free completion | High — stated user preference for strict semantics, architecture evidence |
| Box+G+H shortcut is premature for the full publication goal | High — all research rounds confirm full Until/Since is the stated goal |
| Task 68 synergy via Q-indexed chronicle | Medium — depends on generalization of ValidChronicle structure not yet explored |
| 30-60 hour total estimate to close 20 sorries | Medium — Campaign 4 (ChronicleToCountermodel) has the highest uncertainty |
