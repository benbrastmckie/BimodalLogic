# Teammate C Findings: Dependencies and Roadmap

**Task**: 974 (context) — Strategic analysis for tasks 973, 974, 977, 978
**Date**: 2026-03-16
**Role**: Teammate C — Dependency analysis and strategic recommendations
**Sources**: state.json, task artifacts (973/974/977/978), ROAD_MAP.md, ConstructiveFragment.lean, DiscreteTimeline.lean

---

## Dependency Analysis

### Critical Path Diagram

```
973 (NoMaxOrder/NoMinOrder)
  |
  | [ALREADY IMPLEMENTED — no code-level sorries]
  |
  v
973 [EFFECTIVELY COMPLETE — pending build verification]
  |
  | (soft dependency: 977 mentions 973 as blocking)
  v
977 Phases 1-3 (docs, soundness, FrameClass) — NO dependency on 973 or 974
  |
977 Phase 4 (dense completeness wiring) — DEPENDS ON 973
  |
977 Phase 5 (base completeness) — DEPENDS ON Phase 4
  |
977 Phase 6 (discrete completeness skeleton) — DEPENDS ON 974 for full proof
  |
977 Phase 7 (summary + verification) — DEPENDS ON Phases 5-6
  |
  v
978 (typeclass architecture refactor) — DEPENDS ON 977 COMPLETE

974 (SuccOrder/PredOrder/IsSuccArchimedean) — INDEPENDENT of 973, 977
  |
  | [BLOCKED: Phase 4 — staged construction architecture issue]
  |
  v
974 [3 sorries remain, architectural blocker]
```

### Hard vs Soft Dependencies

| Dependency | Type | Assessment |
|------------|------|------------|
| 973 -> 977 Phase 4 | Soft | 973 is effectively done; not a real blocker |
| 974 -> 977 Phase 6 (full proof) | Hard | Phase 6 skeleton can proceed with explicit sorry-placeholders |
| 974 -> 977 Phase 6 (statement) | Soft | Statement + skeleton can be written now |
| 977 -> 978 | Hard | 978 was explicitly designed to follow 977 completion |

---

## Task 973 Assessment

### Actual Status: Effectively Complete

**Critical finding**: The ConstructiveFragment.lean file contains NO code-level sorries. The two instances (NoMaxOrder and NoMinOrder) are fully implemented at lines 585-649.

Evidence:
- `grep -n "^\s*sorry" ConstructiveFragment.lean` returns empty
- The implementation at lines 585-649 contains complete proofs using `canonicalR_strict'`, `executeForwardStep_canonicalR`, and `Antisymmetrization.ind`
- The comment at lines 572-573 ("proofs are marked sorry") is a stale documentation artifact

**State inconsistency**: state.json lists task 973 as "implementing" but the implementation appears complete. The proofs should be verified with `lake build` and the task marked complete.

### Priority of 973

Low-priority clarification task. The code appears done; what remains is:
1. Build verification (`lake build Bimodal.Metalogic.Canonical.ConstructiveFragment`)
2. Status update (implementing -> completed)
3. No new proof work required

**Relation to 974 blocker**: None. The two tasks are independent. Task 973 uses seriality witnesses in ConstructiveFragment while task 974's blocker is about the staged construction architecture in a completely separate module.

---

## Task 977 Partial Execution

### Which Phases Can Proceed Right Now (Without 974)

| Phase | Title | Dependency on 974 | Can Start Now? |
|-------|-------|-------------------|----------------|
| Phase 1 | Documentation Audit | None | YES |
| Phase 2 | Derivation Soundness Verification | None | YES |
| Phase 3 | FrameClass Enumeration | Phase 1 only | YES |
| Phase 4 | Dense Completeness Wiring | Task 973 (done) | YES |
| Phase 5 | Base Completeness Statement | Phase 4 | YES (after Phase 4) |
| Phase 6 | Discrete Completeness Framework | Task 974 (blocked) | PARTIAL — statement only |
| Phase 7 | Logic Variants Summary | Phase 6 | PARTIAL — can document 2/3 variants |

**Key insight**: 5 of 7 phases are fully executable without resolving task 974. Phase 6 can be partially executed (writing the `theorem completeness_discrete` statement with explicit sorry-markers documenting the dependency on 974).

### Value of Starting 977 Now

**High value**. Completing Phases 1-5 of 977:
- Delivers concrete research output (FrameClass enumeration, documentation, soundness verification)
- Does NOT require 974 to be resolved
- Creates the template that makes 974-dependent work in Phase 6 more tractable
- The 977 plan explicitly states: "Plan phases to be executable in parallel where possible"

### Would 977 Progress Help Resolve 974?

Indirectly, yes. Task 977 Phase 3 will define explicit FrameClass enumeration. This clarification of the discrete/dense boundary might reveal whether there is a cleaner architectural solution for the staged construction problem in 974. However, this is speculative and not a strong reason to block 977 on 974.

---

## Refactor Timing Analysis

### What Task 978 Actually Provides

Task 978 delivers:
1. **Frame condition typeclasses** (`DenseFrame`, `DiscreteFrame`, `SerialFrame`)
2. **Parameterized axiom availability** (extension axioms gated by typeclasses)
3. **Type-level proof system separation** (separate derivation types per logic variant)
4. **Generic soundness/completeness** (theorems parameterized over frame typeclasses)
5. **Directory reorganization**

### How 978 Relates to 974's Blocker

The 974 blocker is: the staged construction (`buildStagedTimeline`) adds density intermediates via `processDensity` at all odd stages, regardless of whether DN is in the axiom set. There is no separate discrete staged construction.

Task 978 would provide `DiscreteFrame` typeclass and `DerivationTree_Discrete` type. However, the 974 blocker is not about the type system — it is about the staged construction logic. A refactor at the typeclass level does NOT fix the staged construction problem. The construction code itself would need a separate discrete path regardless of whether it is gated by a typeclass or by an if-branch.

**Verdict**: Task 978 does NOT unblock 974. The two problems are at different levels of abstraction:
- 974: Computational/algorithmic (staged construction adds wrong witnesses)
- 978: Type-theoretic (typeclasses for axiom availability)

### If We Refactored Now (978 Before 977)

**What would be lost/wasted**:
- 977 specifically establishes the completeness landscape (which gaps exist, what infrastructure is needed) that 978 will refactor
- Doing 978 before 977 means refactoring a system where completeness gaps are not yet filled — the typeclass architecture would be beautiful but incomplete
- The 977 plan explicitly states: "This refactor should only proceed AFTER all gaps identified in research-001.md are filled"

**What would be preserved**: Soundness results (already solid), basic axiom classification

**Risk**: Refactoring before completing 977 means reorganizing toward a target structure that may need further revision once the completeness gaps reveal unexpected infrastructure requirements.

### Minimal Refactor Analysis

Is there a "minimal refactor" that unblocks 974 without full 978 scope?

The 974 blocker has three resolution paths identified in the plan:
- **Option A**: Quotient collapse proof (show the density witnesses collapse in the discrete quotient)
- **Option B**: Separate discrete staged construction (add `buildDiscreteTimeline` that skips `processDensity`)
- **Option C**: Alternative proof not using staged construction at all

None of these require typeclass-level changes. Option B is essentially a targeted refactor of the staged construction — adding a discrete execution path. This is a smaller scope than 978 and can be done independently.

**Recommendation**: Pursue Option B as a targeted intervention. Add `buildDiscreteTimeline` (or `buildStagedTimeline_discrete`) that excludes `processDensity`. This is a surgical fix to the staged construction layer, not a full typeclass refactor.

---

## Strategic Recommendations

### Recommended Approach: Sequential with Parallel Tracks

The strongest strategy is sequential completion with careful parallel tracking:

**Track A (near-term)**: Close out 973, start 977 Phases 1-3 immediately
**Track B (unblocked research)**: Pursue 974 via Option B (targeted discrete construction fix)
**Track C (deferred)**: Hold 977 Phases 4-6 until Tracks A and B converge

This avoids the refactor-first trap while making maximum progress on what is currently unblocked.

### Execution Order

```
Step 1 (immediate, ~0.5h): Verify task 973 builds, mark complete
  -> lake build Bimodal.Metalogic.Canonical.ConstructiveFragment
  -> Update state.json: 973 -> completed

Step 2 (parallel, 2-3h each):
  Track A: Begin 977 Phases 1-3
    - Phase 1: Documentation audit (1-2h)
    - Phase 2: Derivation soundness verification (1-2h)
    - Phase 3: FrameClass enumeration (1.5-2h)
  Track B: 974 Option B — add discrete staged construction
    - Write buildDiscreteTimeline (sans processDensity)
    - Prove finite intervals in discrete construction
    - Resolve 3 remaining sorries in DiscreteTimeline.lean

Step 3 (after Track B completes, 3-4h):
  977 Phase 4: Dense completeness wiring

Step 4 (after Phase 4, 2-3h):
  977 Phase 5: Base completeness statement

Step 5 (after 974 and Phase 5, 2-3h):
  977 Phase 6: Discrete completeness framework (now unblocked)

Step 6 (after Phase 6, 1.5-2h):
  977 Phase 7: Logic variants summary + final verification

Step 7 (after 977 complete, deferred):
  978: Typeclass architecture refactor
```

**Total estimated time**: 14-20 hours active work

### Decision Points

1. **After Step 1** (973 build verification): If 973 does NOT build, re-examine the implementation gap before proceeding to 977 Phase 4.

2. **After Track B Phase 4 attempt** (discrete staged construction): If Option B proves harder than expected (> 3h), pivot to Option A (quotient collapse proof) or consider temporarily axiomatizing `staged_build_discrete_finite` and revisiting as a separate proof task.

3. **After 977 Phase 4** (dense completeness wiring): If the domain mismatch between Int-indexed BFMCS and TimelineQuot proves intractable, mark Phase 4 BLOCKED and deliver Phases 1-3 + 5-7 as partial completion of 977. Dense completeness may require a separate targeted task.

4. **Before starting 978**: Confirm 977 is fully complete (not partial). Starting 978 before 977 is done creates architectural confusion.

---

## Quality Impact Assessment

### Path A: Sequential (Recommended)
`973 -> 977 (Phases 1-5) -> 974 Option B -> 977 Phase 6-7 -> 978`

**Quality**: Highest. Each task builds on complete foundations. 978 refactors a system with all completeness gaps filled. Final architecture is fully modular with proven results at every layer.

**Risk**: Moderate. 974 Option B may take longer than estimated. Dense completeness wiring (977 Phase 4) carries medium risk.

### Path B: Refactor First
`978 -> 974 -> 977`

**Quality**: Medium. Typeclass architecture is beautiful but would be built over an incomplete metalogic (missing discrete completeness). The 978 typeclass separation doesn't actually help 974's staged construction problem.

**Risk**: High. Risk of refactoring toward a target that changes when completeness gaps are filled. High risk of wasted effort.

**Verdict**: Path B is a false shortcut. Task 978 cannot unblock 974, so refactoring first gains nothing and creates rework risk.

### Path C: Abandon 974, Complete 977 with Sorry
`977 (Phases 1-5, mark Phase 6 permanently deferred) -> 978`

**Quality**: Lower. Discrete completeness remains unproven. The repository would have explicit sorry-markers in the completeness hierarchy.

**Risk**: Low. Delivers significant value (FrameClass enumeration, base + dense completeness) without resolving the hardest open problem.

**Viability**: This is a legitimate fallback if Track B (974 Option B) proves intractable. The sorry-markers would be honest documentation of the open problem.

---

## Confidence Level

**High** on dependency analysis — the artifact trail is detailed and consistent across multiple research reports, plans, and the ROAD_MAP.md.

**Medium** on 974 resolution path — the Option B (discrete staged construction) approach is mathematically sound but the implementation effort estimate (2-3h) assumes the staged construction is modular enough to fork. If the density processing is deeply entangled with the construction state, the effort could be higher.

**High** on the refactor timing recommendation — the evidence is clear that 978 does not unblock 974, and that 977 completion is the prerequisite for 978 to be maximally useful.

**High** on task 973 status — the code inspection shows no code-level sorries. The task is effectively complete pending build verification.

---

## Appendix: Evidence Trail

| Finding | Source |
|---------|--------|
| 973 has no code-level sorries | `grep -n "^\s*sorry" ConstructiveFragment.lean` -> empty |
| 974 Phase 4 blocked on `processDensity` | implementation-002.md, Session 2026-03-16 progress |
| 977 Phases 1-3 independent of 974 | implementation-001.md Phase dependencies table |
| 977 Phase 6 requires 974 for full proof | implementation-001.md Phase 6 dependencies |
| 978 depends on 977 completion | TODO.md task 978 description, state.json depends_on |
| 978 does not help 974's blocker | research-002.md Part II analysis (staged construction issue vs type system) |
| Option B viable for 974 | research-002.md Section 5.1, plan implementation-002.md Phase 4 comment |
| Dense/discrete are incompatible frame conditions | research-002.md Section 2.2 Approach C |
