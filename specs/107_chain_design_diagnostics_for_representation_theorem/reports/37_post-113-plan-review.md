# Research Report: Task #107 -- Post-Task-113 Plan Review

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Started**: 2026-04-28T14:00:00Z
**Completed**: 2026-04-28T15:00:00Z
**Task Type**: formal
**Domains**: logic

## Executive Summary

- The v21 plan (artifact 34) was written before task 113's open guard refactoring. Its Phase 1 is **critically impacted**: the entire D0 seed construction and consistency proof (tasks 1.2-1.5) depend on infrastructure that was removed as dead code in task 113 Phase 3.
- The plan's Phase 4 (FUC sorry sites) had a **prescient warning** at task 4.1 NOTE about BX9 dependency, but the note assumed BX9 would still be available at Phase 4 time. That assumption is now false.
- The paper (possible_worlds.tex) states completeness as a **conjecture**, not a theorem. The publication does not depend on completing the formalization -- it only requires soundness (which is done).
- 11 sorry sites remain on the chronicle critical path (7 c2' in CounterexampleElimination + 1 density self-pair + 2 FUC in ChronicleToCountermodel + 2 nested bridging in RRelation that are INVALID). The non-chronicle BXCanonical has 12 additional sorry sites (quasimodel, filtration, truthlemma, frame) which are off the chronicle path.
- The v21 plan needs a **major revision** to Phase 1, since its core building blocks (`BurgessR3Maximal_maximality_combined`, `burgess_D0_consistent`, `B_sub_A_of_burgessR3`, `B_sub_C_of_burgessR3`, `burgess_D0_elem_in_A_or_C`, `lemma_2_6_full`) have all been removed.

## 1. Current Plan Assessment

### Still Valid

| Plan Element | Status | Notes |
|-------------|--------|-------|
| Phase 1 task 1.1 (maximality infrastructure) | VALID | `dc_delta_B_controlled`, `BurgessR3Maximal_extension_fails`, `dc_delta_B_burgessR3` are sorry-free and retained. |
| Phase 2 overall strategy (construct g-values via Lemma 2.6) | VALID | The approach of using Lemma 2.6 splitting to provide g-values is mathematically correct. |
| Phase 2 tasks 2.1-2.2 (C5/C5' g-values) | VALID | These use `burgessR3Maximal_exists_from_seed` which is sorry-free. |
| Phase 3 (g-immutability) | VALID | Pure omega-chain reasoning, no dependency on removed infrastructure. |
| Phase 5 (cleanup) | MOSTLY VALID | `lemma_2_6_full` already removed; task 5.1 is done. |

### Outdated or Broken

| Plan Element | Impact | Details |
|-------------|--------|---------|
| **Phase 1 tasks 1.2-1.5** (D0 consistency + Lemma 2.6 assembly) | CRITICAL | The D0 definition, `burgess_D0`, `burgess_D0_consistent`, `B_sub_A_of_burgessR3`, `B_sub_C_of_burgessR3`, and `burgess_D0_elem_in_A_or_C` are ALL removed. The consistency proof strategy at 1.2 uses BX5+BX7+BX10 which remain valid axioms, but the D0 set definition itself and all supporting lemmas must be rebuilt from scratch. |
| **Phase 1 task 1.2 proof strategy** (steps 3, 6, 7) | PARTIALLY BROKEN | Step 3 uses "From burgessR3: untl(beta, gamma) in A" -- this property (`B_sub_A_of_burgessR3` / the untl membership from r-relation) was marked INVALID and removed. The burgessR3 definition gives untl membership but via a different route; the v21 plan's appeal to a removed helper is misleading. Step 6 uses BX10 (still valid). Step 7 uses BX4 (still valid). |
| **Phase 2 tasks 2.3-2.5** (C4/density using Lemma 2.6) | BLOCKED on Phase 1 | These require `burgess_lemma_2_6_content` which depends on the removed D0 construction. |
| **Phase 4 task 4.1 NOTE** (BX9 dependency) | OUTDATED | The NOTE warned about a "future refactor to open guard" -- that refactor is now DONE. The BX9-based derivation in Phase 4.1 must be replaced with the Xu 2.3(i) approach (already identified as `rRelation_guard_continues'` in the codebase). |
| **Phase 5 task 5.1** (delete `lemma_2_6_full`) | ALREADY DONE | Removed by task 113. |

### New Issues Introduced by Task 113

| Issue | Severity | Details |
|-------|----------|---------|
| `burgessR3_gamma_not_in_B_nested` is INVALID (sorry stub) | HIGH | Called by CounterexampleElimination.lean at lines 422, 537. The C4/C4' elimination branches depend on this for the "nested bridging" pattern. The lemma depended on `untl_absorb_nested` which is genuinely invalid under open guard. |
| `burgessR3_gamma_not_in_B_since_nested` is INVALID (sorry stub) | HIGH | Mirror of above, also called from CounterexampleElimination.lean. |
| `B_sub_A_of_burgessR3` removed | MEDIUM | Used in v21 plan's consistency argument. The property "beta in B implies beta in A" does NOT follow from burgessR3 under open guard without the now-removed `until_guard` axiom. This is not just missing code -- the STATEMENT may be false. |
| Density elimination (line 1086) is the "8th sorry" | MEDIUM | The v21 plan counted 7 c2' sites + 2 FUC sites = 9. But there is also the density `f(z) = f(x)` self-pair sorry at line 1086. The plan's Phase 2.5 addresses this but the count was off. |

## 2. Removed Infrastructure Impact

### What Was Removed (Task 113 Phase 3)

From PointInsertion.lean:
- `burgess_D0` (definition) -- the seed set for Lemma 2.6
- `B_subset_burgess_D0`, `neg_delta_in_burgess_D0`, `untl_in_burgess_D0`, `snce_in_burgess_D0` -- D0 membership lemmas
- `B_sub_A_of_burgessR3` -- INVALID (beta in B implies beta in A; false under open guard)
- `B_sub_C_of_burgessR3` -- INVALID (mirror)
- `burgess_D0_elem_in_A_or_C` -- depended on invalid lemmas
- `F_mono_mcs`, `left_mono_contrapositive_neg_delta` -- dead, used only by removed code
- `BurgessR3Maximal_maximality_combined` -- dead code, partially invalid
- `burgess_D0_consistent` -- dead code, depended on above
- `lemma_2_6_full` -- dead, depended on removed `rRelation_self_mcs`
- `rRelation_self_mcs`, `rRelationSince_self_mcs` -- INVALID under open guard
- `until_elim_mcs` -- INVALID (depended on BX9)
- `lemma_2_7_guard` -- dead

### What Was Retained

From PointInsertion.lean (sorry-free):
- `dc_delta_B_controlled` -- decomposes DC({delta} union B) elements
- `BurgessR3Maximal_extension_fails` -- maximality proof for proper extensions
- `dc_delta_B_burgessR3` -- DC({delta} union B) satisfies burgessR3 when until/since conditions hold
- `mcs_no_proper_dcs_extension` -- MCS cannot have proper DCS extensions
- `burgessR3Maximal_exists_from_seed` -- THE key existence theorem (sorry-free)

From RRelation.lean (sorry stubs, INVALID):
- `burgessR3_gamma_not_in_B_nested` -- retained because CounterexampleElimination calls it
- `burgessR3_gamma_not_in_B_since_nested` -- mirror

### Rebuilding Requirements

The v21 plan's Phase 1 (Lemma 2.6 for BurgessR3Maximal) requires:

1. **Reconstruct D0 seed set** -- the definition can be restored from the Boneyard archive, but the membership lemmas need new proofs that work under open guard.

2. **Reprove or bypass `B_sub_A_of_burgessR3`** -- Under open guard, burgessR3(A, B, C) gives: (1) for beta in B, gamma in C: untl(beta, gamma) in A; (2) for beta in B, alpha in A: snce(beta, alpha) in C. This does NOT directly give "beta in A" because BX9 (untl(beta, gamma) implies beta or gamma) is removed. However, BX10 (untl(beta, gamma) implies F(gamma)) is still valid. An alternative path might use BX5 (self-accumulation) + BX4 (connect_future) to recover membership via a longer derivation chain.

3. **Handle the `BurgessR3Maximal_maximality_combined` gap** -- The key insight from task 113 is that the delta.neg-in-B case is mathematically blocked without the `until_guard` axiom. Under open guard, `bot U gamma` is satisfiable on discrete orders where the guard interval can be empty. This means the FULL maximality combined lemma may be false. The plan must work without it.

4. **Address the nested bridging lemma invalidity** -- `burgessR3_gamma_not_in_B_nested` is called from CounterexampleElimination.lean but is INVALID. This is a new sorry source not accounted for in the v21 plan's Phase 2. The C4 elimination code that calls this lemma needs reworking.

## 3. Sorry State Audit

### Chronicle Critical Path (11 active sorry sites)

| File | Line | Classification | Plan Phase |
|------|------|---------------|------------|
| CounterexampleElimination.lean | 786 | c2' C5 g-construction | Phase 2.1 |
| CounterexampleElimination.lean | 824 | c2' C5' g-construction | Phase 2.2 |
| CounterexampleElimination.lean | 864 | c2' C4 splitting | Phase 2.3 |
| CounterexampleElimination.lean | 902 | c2' C4' splitting (mirror) | Phase 2.4 |
| CounterexampleElimination.lean | 938 | c2' g_prop g-construction | Phase 2.6 |
| CounterexampleElimination.lean | 970 | c2' h_prop g-construction | Phase 2.6 |
| CounterexampleElimination.lean | 1086 | density self-pair `f(z)=f(x)` | Phase 2.5 |
| ChronicleToCountermodel.lean | 615 | FUC Until case | Phase 4.2 |
| ChronicleToCountermodel.lean | 619 | FUC Since case | Phase 4.3 |
| RRelation.lean | 1177 | nested bridging (INVALID) | **NOT IN PLAN** |
| RRelation.lean | 1191 | nested bridging Since (INVALID) | **NOT IN PLAN** |

### Non-Chronicle BXCanonical (12 sorry sites, off critical path)

| File | Count | Notes |
|------|-------|-------|
| Quasimodel/Construction.lean | 2 | quasimodel construction |
| Quasimodel/Realization.lean | 4 | quasimodel realization |
| TruthLemma.lean | 2 | truth lemma |
| Filtration/SigmaOrdering.lean | 3 | sigma ordering |
| Frame.lean | 1 | frame construction |

These are on an alternative completeness path (quasimodel/filtration) which is NOT the chronicle path. They are not addressed by the v21 plan and are not blocking.

### Classification Summary

- **Addressable by v21 plan (revised)**: 9 sorry sites (7 c2' + 1 density + 1 absorbed FUC pair counted as 2)
- **INVALID (need replacement approach)**: 2 sorry sites (nested bridging)
- **Off critical path**: 12 sorry sites (quasimodel/filtration)
- **Total BXCanonical**: 23 active sorry sites (excluding RootScopedChain and Boneyard)

## 4. Paper Requirements

The paper (possible_worlds.tex, line 1483) states:

> "Completeness of **TM** with respect to the class of task frames is conjectured but unproved; the mosaic method for many-dimensional modal logics (Goldblatt 1992) is a natural candidate proof strategy."

### Current Paper State

- **Soundness**: Fully formalized and sorry-free. The paper references the Lean formalization for soundness.
- **Completeness**: Stated as a conjecture. No proof is claimed.
- **The paper does NOT depend on task 107's completion for publication.**

### Minimal Viable Formalization for Publication

The paper can be submitted as-is with the completeness conjecture. However, upgrading from conjecture to theorem would strengthen the paper significantly. For this:

1. The chronicle construction must be sorry-free (`dd_countermodel_chronicle`)
2. This gives: "Every BX-consistent formula is satisfiable in a countermodel over Q (rationals)"
3. The final step to task-frame completeness (from Q-model to task-frame model) may require additional machinery

### What the Paper Needs from the Formalization

- Soundness theorem (DONE, sorry-free)
- Axiom system alignment with Xu's Sigma4 (DONE after task 113: 31 axioms, open guard)
- Optional: completeness theorem (task 107 goal)

## 5. Gaps and Missing Elements

### 5.1 The B_sub_A_of_burgessR3 Gap

The v21 plan's Phase 1.2 consistency proof (step 3) relies on "From burgessR3: untl(beta, gamma) in A", extracted via `B_sub_A_of_burgessR3` (the property that B-membership implies A-membership under burgessR3). This property was marked INVALID and removed.

Under open guard, burgessR3(A, B, C) only gives: for beta in B and gamma in C, untl(beta, gamma) in A. It does NOT give beta in A directly. The v21 plan needs the richer property for the D0 consistency argument.

**Possible fix**: The property "beta in B implies beta in A" may still hold through an alternative derivation. Consider: from burgessR3, untl(beta, gamma) in A for any gamma in C. By BX10 (until_F), F(gamma) in A. By BX4 (connect_future), beta implies G(P(beta)), so if beta in A, then P(beta) in g_content(A). But this is circular (assumes beta in A).

Alternative approach: Use the BurgessR3Maximal definition directly. BurgessR3Maximal(A, B, C) means B is the maximal DCS with burgessR3(A, B, C). The maximality gives structural information about B that might substitute for the membership lemma.

**This is a genuine mathematical gap that the revised plan must address.**

### 5.2 The Nested Bridging Lemma Gap

`burgessR3_gamma_not_in_B_nested` (RRelation.lean:1169) is INVALID under open guard but is called by CounterexampleElimination.lean at lines 422 and 537. The v21 plan does not address this.

The lemma states: if burgessR3(A, B, C) and neg(untl(gamma, delta)) in A and untl(gamma, delta) in C, then gamma not in B. The proof depended on `untl_absorb_nested` which used BX9 (removed).

**This needs either a new proof under open guard or a restructuring of the C4 elimination code.**

### 5.3 Density vs General Linear Orders

The v21 plan assumes completeness over general linear orders (not necessarily dense). However, task 113 revealed that the `BurgessR3Maximal_maximality_combined` delta.neg-in-B case is mathematically blocked without density. The chronicle construction produces a dense limit domain (the omega-chain limit is dense by construction), so density IS available at the limit level. But the Lemma 2.6 splitting is applied at finite stages where the domain is NOT yet dense.

**The plan does not clearly distinguish between:**
- Lemma 2.6 at finite stages (discrete domain)
- Lemma 2.6's consistency argument (which may need density)
- The limit chronicle (dense domain)

### 5.4 Missing Treatment of Task 113 Phase 5 Remnants

Task 113's Phase 5 is NOT yet completed. Several items remain:
- `cantor_bfmcs_restricted_buc` le-to-lt fix (task 113 Phase 5 Step 4)
- TemporalDerived.lean cleanup (Phase 5 Step 2)
- Substitution.lean cleanup (Phase 5 Step 3)
- Documentation updates (Phase 5 Step 5)

These are not blocking for task 107 but should be completed to maintain codebase hygiene. The v21 plan does not account for these as prerequisites.

### 5.5 No Verification Strategy for Axiom Independence

The v21 plan does not verify that the 31-axiom system is exactly Xu's Sigma4. While task 113 established this correspondence conceptually, there is no formal verification step in the plan.

## 6. Recommended Plan Improvements

### 6.1 Phase 1 Must Be Rewritten

The current Phase 1 (tasks 1.2-1.5) is based on infrastructure that no longer exists. A revised Phase 1 should:

1. **Restore the D0 seed definition** from the Boneyard archive, but with fresh membership lemmas that work under open guard.

2. **Find an alternative to B_sub_A_of_burgessR3** for the consistency proof. Options:
   - (a) Prove the property through a longer BX axiom chain (BX2 + BX3 + BX10 + BX4)
   - (b) Restructure the consistency argument to avoid needing "beta in A" directly
   - (c) Use a different seed set D0 that does not require this property
   - (d) Use density at the point of application (but finite stages are discrete)

3. **Address the delta.neg-in-B blocker** explicitly. The plan's contingency (Phase 1 contingency) mentions using the "special case where g(x,y) is NOT an MCS" to avoid needing a delta. This contingency is now the primary path, since the full maximality_combined result is blocked.

4. **Re-estimate effort**: The original 23 hours for Phase 1 assumed existing infrastructure. With the rebuild, add 8-12 hours.

### 6.2 New Phase: Fix Nested Bridging (Between Current Phases 1 and 2)

Add a phase to resolve the `burgessR3_gamma_not_in_B_nested` / `_since_nested` sorry stubs. Options:
- (a) Prove under open guard using a different derivation
- (b) Restructure CounterexampleElimination.lean to avoid calling these lemmas
- (c) Change the C4 elimination approach to not need the "nested" case

Effort: 4-8 hours depending on approach.

### 6.3 Phase 4 Revision: Remove BX9 Dependency

Phase 4.1's proof strategy explicitly uses BX9 (until_elim). Replace with:
- Use `rRelation_guard_continues'` (identified in task 113 research as the Xu 2.3(i) replacement)
- The guard `xi` enters intermediate points through the DCS interval containment (C3) rather than through BX9 extraction at the current point

This is a proof-strategy change, not a structural change. Effort: 2-4 additional hours.

### 6.4 Phase 5 Should Include Task 113 Remnants

Add tasks to complete task 113 Phase 5 if not already done:
- `cantor_bfmcs_restricted_buc` le-to-lt fix
- TemporalDerived.lean dead theorem archival
- Substitution.lean cleanup

### 6.5 Simplifications from Task 113

Some things are now EASIER:
- No need to worry about guard convention switching (open guard is final)
- `lemma_2_6_full` deletion already done (task 5.1 is free)
- The axiom system is now definitively Xu's Sigma4 -- no ambiguity about which axioms are available
- BX10 (until_F), BX5 (self_accum), BX4 (connect_future) remain valid and are the correct tools for all chronicle constructions

## 7. Effort Estimate

| Phase | Original Estimate | Revised Estimate | Notes |
|-------|------------------|-----------------|-------|
| Phase 1 (Lemma 2.6) | 23 hrs | 28-35 hrs | Must rebuild D0 infrastructure under open guard; B_sub_A gap adds uncertainty |
| NEW: Fix nested bridging | -- | 4-8 hrs | Not in original plan |
| Phase 2 (g-values) | 21 hrs | 18-21 hrs | Slightly easier with clearer axiom set |
| Phase 3 (g-immutability) | 6 hrs | 5-6 hrs | Unchanged |
| Phase 4 (FUC) | 11.5 hrs | 10-14 hrs | BX9 replacement adds complexity |
| Phase 5 (cleanup) | 3-5 hrs | 4-6 hrs | Add task 113 remnants |
| **Total** | **64.5-66.5 hrs** | **69-90 hrs** | |

**Realistic calendar estimate**: 3-4 months of focused work sessions (assuming 5-8 hours/week).

## 8. Confidence Level

**Overall plan viability**: MEDIUM (60-70%)

The mathematical approach (Burgess 1982 chronicle construction) is well-established in the literature. The formal infrastructure (`burgessR3Maximal_exists_from_seed`, the omega-chain machinery, the Cantor isomorphism) is sorry-free and solid.

**High confidence** elements:
- Phase 2 (g-value construction): once Lemma 2.6 exists, closing the c2' sorry sites is mechanical
- Phase 3 (g-immutability): follows established patterns
- Phase 5 (cleanup): straightforward

**Medium confidence** elements:
- Phase 4 (FUC): the BX9 replacement via DCS interval containment is conceptually clear but unverified in Lean
- Nested bridging fix: plausible approaches exist but none verified

**Low confidence** elements:
- Phase 1 (D0 consistency under open guard): The `B_sub_A_of_burgessR3` invalidity is a genuine mathematical obstacle. The consistency argument may need a fundamentally different approach than what the v21 plan describes. This is the **critical risk**.

**Recommendation**: Before revising the full plan, conduct a focused mathematical investigation of whether `B_sub_A_of_burgessR3` (or a useful substitute) holds under open guard semantics. This can be done as a targeted research spike (2-4 hours) before committing to the full Phase 1 rebuild.
