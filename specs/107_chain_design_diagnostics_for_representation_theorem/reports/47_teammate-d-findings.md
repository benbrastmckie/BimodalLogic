# Research Report: Task #107 — Teammate D (Horizons) Strategic Analysis

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Role**: Teammate D — Horizons (long-term alignment and strategic direction)
**Date**: 2026-04-29
**Artifact**: 47_teammate-d-findings.md
**Sources**: Handoffs 05/06/07, ROADMAP.md (2026-04-29), plans/46_implementation-plan.md (v32)

---

## Executive Summary

- The chronicle path remains the correct primary strategy; there is no viable alternative.
- The 4 remaining sorries are approachable, but Phase 9's approach is structurally broken and needs a plan revision before implementation resumes.
- The 0-sorry target is the right goal; a partial result (e.g., 7/10 closed) would have no publication value for the representation theorem.
- EliminationResult carrying c2' at finite stages is a real architectural misalignment with Burgess's design; removing it is the recommended fix and is lower-effort than adding g_ordered.
- Task 107 should not be split; the remaining work is tightly coupled. However, a focused plan revision (v33) for Phases 8-11 is essential before the next implementation session.

---

## Key Findings

### 1. Is the chronicle path still the best path to completeness?

**Yes, unambiguously.** The ROADMAP documents 36 dead ends across three BXCanonical paths (C, A, B), all blocked by Lindenbaum opacity. The chronicle escapes this fundamental obstruction via controlled PointInsertion. Task 109 (BXCanonical) is explicitly secondary; its 5 critical-path sorries in RootScopedChain.lean become dead code once task 107 succeeds.

The comparison with task 109 is:

| Dimension | Chronicle (107) | BXCanonical (109) |
|-----------|----------------|-------------------|
| Sorry count | 4 | 23 (5 critical + 18 irreflexive artifacts) |
| Mathematical blocker? | No (all gaps are engineering) | Yes (Lindenbaum opacity, dead ends #34-#36) |
| Clear next step? | Yes (Phase 8/9 fix identified) | No (blocked by opacity) |
| Becomes dead code when 107 succeeds? | No (this IS the proof) | Yes (5 critical path sorries) |

Task 109 is worth pursuing only for the 18 irreflexive-consequence cleanup sorries, which are independent of the completeness proof. The chronicle path should remain the undivided focus.

### 2. What is the minimum viable result?

There is no meaningful partial completeness result to ship for this project. The representation theorem goal is:

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

A Box+G+H-only completeness result (without Until/Since) would be a different theorem about a different logic. The core scientific contribution of task 107 is the Burgess construction for Until/Since. The Chronicle module exists entirely to handle Until/Since; the simpler operators are already handled by the BXCanonical Truth Lemma.

Partial results that are genuine milestones:
- **PointInsertion.lean sorry-free** (DONE as of Phase 5b) — This is already a significant result; Lemma 2.4 and 2.6 are the hardest parts of the Burgess construction.
- **RRelation.lean sorry-free** — 1 sorry remaining (Zorn inconsistent case). This is independently publishable as a formalization of Burgess's Lemma 2.1-2.3.
- **Full chronicle sorry-free** — The target. This gives `dd_countermodel_chronicle` and closes the completeness loop.

Shipping a "7 of 10 closed" result would communicate "work in progress," not "theorem proved." The 0-sorry target is correct.

### 3. Sorry budget: Is 0 sorries realistic?

**Yes, but not on the current plan.** The current plan (v32) has a structural mismatch in Phase 9 that must be resolved before implementation can succeed.

Current sorry inventory (4 sites):

| # | File | Line | Nature | Difficulty |
|---|------|------|--------|------------|
| 1 | RRelation.lean | 772 | Zorn inconsistent case: `¬burgessR3(A, Set.univ, C)` | Medium — needs density or direct argument |
| 2 | CounterexampleElimination.lean | 1130 | Density self-pair: requires `g_content A ⊆ C` from split | Medium — fixed by extending lemma_2_6_splitting return type (Phase 8 plan) |
| 3 | ChronicleToCountermodel.lean | 615 | FUC coherence | Medium |
| 4 | ChronicleToCountermodel.lean | 619 | FSC coherence | Medium |

Additionally, handoff 07 reveals that Phase 9 (C4/g_prop/h_prop sorry sites) has 4 additional sorry sites at CounterexampleElimination.lean:908, 946, 982, 1014 that are NOT in the ROADMAP's count of 4. These appear to be sorry sites the ROADMAP does not yet track (the build still passes, suggesting they are inside `eliminate_C4_counterexample` and related functions which may compile with sorry). This discrepancy needs clarification.

If the Phase 9 approach is fixed (Option B: remove c2' from EliminationResult), the 4 sorry sites at lines 908, 946, 982, 1014 become vacuously closed. This makes the total path to 0-sorries concrete.

### 4. Architectural debt: Is EliminationResult carrying c2' a sign of deeper misalignment?

**Yes.** This is the clearest architectural signal in all three handoffs. Handoff 07 identifies the root cause precisely:

Burgess's design builds the omega-chain to achieve density: when the limit is taken over the dense subdomain of Q, there are NO adjacent pairs in the limit chronicle. Therefore c2' (BurgessR3Maximal for all adjacent pairs) is vacuously true at the limit. Burgess never needs c2' at finite stages — he only needs c0 (MCS values), the specific counterexample witness, and domain monotonicity.

The codebase's `EliminationResult` carries `c2' : val.c2'`, which requires proving `BurgessR3Maximal` for ALL adjacent pairs at EACH finite stage. This is structurally harder than what Burgess requires and creates exactly the blockers observed in Phase 9.

**Recommended fix**: Option B from handoff 07 — remove c2' from EliminationResult. The specific changes:

1. Remove `c2' : val.c2'` field from `EliminationResult`
2. The 4 sorry sites (lines 908, 946, 982, 1014) become unprovable goals that disappear (the structure no longer requires them)
3. Restructure `omega_chain` to not carry c2' through iterations
4. Prove c2' ONLY at the limit (vacuously true for the dense construction)

This is aligned with how Burgess actually designed the construction, and handoff 07 estimates "medium" effort for this change versus "substantial refactoring" for the g_ordered invariant alternative (Option A).

The fact that this architectural mismatch took 47 artifacts to surface is itself informative: the construction was proceeding "against the grain" of the original design. Fixing this now saves effort on all downstream phases (10, 11).

### 5. Does the task need to be split?

**No, but a plan revision is essential.** The remaining work in task 107 is tightly coupled:

- Phase 8 (density sorry) and Phase 9 (c2' sorry sites) share the same root: the EliminationResult architecture.
- Phase 10 (C5 case) depends on Phase 9's c2' architecture decision.
- Phase 11 (FUC/FSC coherence) is more independent but benefits from clean phases 8-10.

Splitting into sub-tasks would create coordination overhead without benefit. The right response is a plan revision (v33) that:

1. Consolidates Phases 8-9 into a single "EliminationResult architecture fix" phase using Option B (remove c2')
2. Updates Phase 10 (C5 case) to use the new simplified EliminationResult
3. Keeps Phase 11 (FUC/FSC) unchanged
4. Adds the Phase 6 (Lemma 2.7) work as the immediate next step

What the 47-artifact history DOES suggest is the value of cleaner phase boundaries. Future plan revisions should scope each phase to a single proof obligation and a target sorry count, rather than spanning multiple structural changes.

---

## Recommended Approach

### Immediate action (before next implementation session)

Run `/revise 107` to create plan v33. The revision should:

1. **Acknowledge Phase 9's structural blocker**: The plan's Phase 9 approach (apply lemma_2_6 to c2' sorry sites) does not work because the counterexample conditions directly contradict the required hypothesis. Handoff 07 documents this definitively.

2. **Choose Option B (remove c2' from EliminationResult)**: This is Burgess's design intent. The EliminationResult structure becomes:
   - `val : Chronicle`
   - `dom_sub : χ.dom ⊆ val.dom`
   - `c0 : val.c0`
   - `f_agrees : ∀ x ∈ χ.dom, val.f x = χ.f x`
   - `g_agrees : ...`
   - `witness : ...` (the specific counterexample resolution)
   - *(no c2' field)*

3. **Keep Phase 8 fix as designed**: Extend `lemma_2_6_splitting` return type to include `g_content A ⊆ D ∧ g_content D ⊆ C` (handoff 05 already did Task A for this: the extension is sorry-free). This unblocks the density sorry at line 1130.

4. **Add h_gc_adj to omega_chain invariant**: As described in handoff 06, carry `∀ x y, Adjacent χ.dom x y → g_content (χ.f x) ⊆ χ.f y` as an omega_chain invariant (not through EliminationResult). The density case proves this for the new adjacent pairs using the extended lemma_2_6_splitting output; old adjacent pairs are covered by the inductive hypothesis.

5. **Lemma 2.7 (Phase 6) is the next executable phase**: PointInsertion.lean is sorry-free. Phase 6 (Lemma 2.7) is unblocked and should proceed while the EliminationResult architectural decision is being made.

### Phase priority order for v33

| Priority | Phase | Dependency | Effort |
|----------|-------|------------|--------|
| 1 | Phase 6: Lemma 2.7 (D1/D3 case) | none | 3-4 hours |
| 2 | Phase 6: Lemma 2.7 (Case 2) | Phase 6 D1/D3 | 2-3 hours |
| 3 | Phase 8-arch: Remove c2' from EliminationResult | none | 2-3 hours |
| 4 | Phase 8-density: Close density sorry via extended splitting | Phase 8-arch | 1-2 hours |
| 5 | Phase 9: C4/g_prop/h_prop (now vacuous under no-c2') | Phase 8-arch | 1 hour |
| 6 | Phase 10: C5 full case analysis | Phase 9 | 3-4 hours |
| 7 | Phase 11: FUC/FSC coherence | Phase 10 | 2-3 hours |

Total estimated remaining: 14-20 hours (vs. 22 in current plan).

### On the Zorn sorry (RRelation.lean:772)

This sorry (`¬burgessR3(A, Set.univ, C)`) needs a separate argument. The handoffs do not address it directly. Two approaches:

1. **Direct argument**: `BurgessR3(A, Set.univ, C)` requires `SetConsistent Set.univ`, but `Set.univ` contains `⊥`, making it inconsistent. Show `BurgessR3` requires the middle argument to be consistent (checking the definition). If so, this sorry is straightforward.
2. **Density argument**: Use the density structure to show `Set.univ` cannot arise as a R-relation target in the Zorn construction. This is harder.

The plan v33 should assign this sorry a dedicated phase or note it as a sub-task of the architecture phase.

---

## Evidence/Examples

### Evidence that c2' removal is aligned with Burgess design

Handoff 07, lines 104-128, makes this explicit:

> "Since `c2'` is vacuously true at the limit (dense domain, no adjacent pairs), Burgess's approach is to prove c2' ONLY at the limit. At finite stages, we just need c0, f-agreement, and the specific counterexample witness."

The ROADMAP itself notes (lines 283-286):

> "Binary g(x,y) rebuilt, `ClosedUnderDerivation` aligned with Burgess/Xu, `splitting_seed_consistent` sorry-free, `g_content(A) ⊆ B` proved via maximality + left_mono_until_G. PointInsertion.lean is sorry-free."

Each architectural alignment step has reduced sorry count substantially (13 → 4 after Phase 5b). The c2' removal is the next alignment step of the same character.

### Evidence that the chronicle path is viable

Report 16 (cited in ROADMAP dead end #37) established: "all chronicle gaps are engineering problems, not mathematical impossibilities." The subsequent progress confirms this: 9 sorries closed since 2026-04-25, all via engineering fixes (C4 argument swap correction, left_mono_until_G axiom, ClosedUnderDerivation definition alignment).

### Evidence on BXCanonical non-viability

ROADMAP dead ends #34-#36 document three independent attempts to close the 5 critical-path sorries in RootScopedChain.lean, all blocked by the same root cause: "The irreducible obstruction is the gap between SEMANTIC temporal reasoning (which can freely reference future/past states) and SYNTACTIC MCS membership (which is local to one MCS). Lindenbaum extensions are non-constructive (axiom of choice) and provide no inter-step structural guarantees."

---

## Confidence Level

| Question | Confidence | Reasoning |
|----------|------------|-----------|
| Chronicle is the right path | Very high (95%) | Three independent BXCanonical paths documented-dead; chronicle has clear engineering path |
| 0 sorries is the right target | High (90%) | No partial result serves the representation theorem goal |
| Remove c2' from EliminationResult is right | High (85%) | Aligns with Burgess design; handoff 07 analysis is thorough; similar alignment steps have always unblocked progress |
| No task split needed | High (85%) | Phases are coupled through shared EliminationResult architecture |
| Plan v33 revision is needed before next implementation | Very high (95%) | Current plan v32 Phase 9 approach is documented-broken; continuing without revision risks wasted sessions |
| 14-20 hour remaining effort estimate | Medium (65%) | Lemma 2.7 Case 2 and FUC/FSC coherence have unclear path; other phases are well-scoped |
