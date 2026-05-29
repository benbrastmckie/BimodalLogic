# Research Report: Task #202

**Task**: Reynolds k-equivalence bypass — sorry-free completeness_discrete
**Date**: 2026-05-29
**Mode**: Team Research (4 teammates)
**Session**: sess_1780072909_ba23c7

## Summary

Four research agents independently analyzed the succ_cofinal blocker, task 129, the literature, and the project landscape. All four converge on a key conclusion: **task 129 is not a viable near-term path** (17-18 sorries, same Reynolds Theorem 5 blocker), and all Henkin chain approaches are dead (F-persistence through Lindenbaum is unfixable). Two novel insights emerged: (1) the Critic identified that all 11+ approaches attacked **global** surjectivity when only **local** surjectivity is needed, and (2) the Horizons researcher identified **Option C** (direct completeness on Z) where IsSuccArchimedean is trivially true. These are complementary facets of the same insight — the correct path bypasses succ_cofinal entirely by building on Z where the property holds by definition.

## Key Findings

### Primary Approach (from Teammate A)

- **Sorry chain confirmed**: succ_cofinal → limitDomSubtype_isSuccArchimedean → succ_embed_surjective → restricted_tc/fuc → completeness_discrete. Only restricted_tc and restricted_fuc carry sorries; restricted_buc, cantor_bfmcs_discrete, and the parametric truth lemma are sorry-free.
- **Task 129 has ~18 sorries** across WeakCanonical/ (TruthLemma: 6, StaviCompleteness: 3, CaseAnalysis: 4, GoodStructures: 1, ShiftAndGlue: 2, Transfer: 1, OrderedSum: 1). The central blocker `no_gaps_discrete` requires Reynolds Theorem 5 — the same Cases III/IV blocker from task 155.
- **successor_deferral_seed_consistent** without BX1 was assessed at 60% success probability, but Teammate A's own analysis concludes the deferral disjunction approach still requires F-persistence, circling back to the same problem.
- **Restricted MCS truth lemma** (10-15h, 80% probability) is a viable but high-effort alternative.

### Alternative Approaches (from Teammate B)

- **HenkinDiscreteChain.lean**: Keep — contains 2 sorry-free infrastructure lemmas and institutional documentation of 5 failed approaches. Will move with Chronicle/ under task 176.
- **Non-Chronicle BXCanonical subtree**: ~4,615 lines of dead code (Frame, TruthLemma, CanonicalChain, Filtration/, Quasimodel/). NOT archivable now — OrderedSeedConsistency.lean is imported by both Chronicle/PointInsertion.lean and WeakCanonical/ReflexiveCanonical.lean. Task 176 owns this cleanup.
- **Task 129 is absorbed into active code**: The archived task's code was merged into WeakCanonical/. References to "task 129" should be read as "the WeakCanonical/ Reynolds pipeline." It is not a separate executable approach.
- **Bundle/ has 12 dead-code sorries** (SuccRelation: 7, SuccExistence: 3, UntilSinceCoherence: 2) — none block completeness_discrete. Task 176 scope.
- **`temporal_coherent_family_exists_CanonicalMCS`** in Bundle/Construction.lean was identified as an unchecked unblocking candidate (Approach 3 from report 02).
- **Task 202 does NOT need to depend on 155** — the Henkin/Option C path is architecturally independent.

### Gaps and Shortcomings (from Critic)

- **succ_cofinal is genuinely unprovable as stated** — the constant-MCS gap scenario is consistent with all temporal axioms (Z1, Prior-UZ, c5) under strict irreflexive semantics. This is not a proof engineering failure.
- **CRITICAL INSIGHT — Local vs Global Surjectivity**: All 11+ approaches tried to prove global surjectivity (succ_embed_surjective: every limit domain point reachable from root). But restricted_tc/fuc only need LOCAL surjectivity: map the SPECIFIC witnesses from limit_F_resolution back to integers. C5 witnesses are inserted at finite construction stages and may always land on embedded integer points. This distinction has never been explored.
- **Dense vs discrete asymmetry is structural**: Dense completeness works because the Cantor construction provides a bijection by construction. The discrete architecture is fundamentally misaligned — it cannot be fixed by a missing lemma; it needs a different foundation.
- **Task 129's conservative extension claim is not established** in the literature for TM bimodal logic. Going from reflexive to irreflexive is a weakening, not a conservative extension in the needed direction.
- **Construction-level gap analysis is unexplored**: Different construction stages insert points for different formulas, making constant-MCS gaps potentially impossible. This was labeled "DEAD APPROACH" prematurely.

### Strategic Horizons (from Teammate D)

- **Project is 99%+ complete** toward Phase 1: sorry_count=1, axiom_count=0, build_errors=0, repository_health=95. Every result except completeness_discrete is sorry-free.
- **Task 202 is strategically essential** — discrete completeness is mathematically indispensable for the paper targeting Z-models. Publishing with a known sorry significantly weakens the claim.
- **Option C (direct completeness on Z)**: On Z itself, IsSuccArchimedean is trivially true by definition. Build restricted_tc/fuc in a BFMCS constructed directly on Z rather than the chronicle domain. Estimated 6-10 hours.
- **Task 129 does not exist in TODO.md** — it's an archived task whose code is now in WeakCanonical/.
- **Dependency on 155 is outdated**: The EF-game infrastructure (ghr93_forward_to_backward_discrete) is already sorry-free. Option C needs nothing from tasks 155, 174, or 199.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate C | Teammate D | Resolution |
|----------|-----------|-----------|-----------|------------|
| Best path forward | successor_deferral_seed (60%) | Local surjectivity audit | Option C on Z (85%) | **Option C + local surjectivity** — complementary facets of the same insight |
| Task 129 viability | Not near-term (~18 sorries) | Not viable (circular defs, unestablished claim) | Not in TODO.md | **Consensus: task 129 is not a path** — it's absorbed into WeakCanonical/ |
| Task 202 dependency on 155 | Not discussed | Not discussed | Outdated | **Remove dependency** — EF infrastructure already sorry-free |
| F-persistence solvable? | Maybe via augmented seed | No — counterexample demolishes | N/A (bypassed by Option C) | **Not solvable** — all Henkin chain approaches are dead |

### Gaps Identified

1. **Option C has not been implemented or tested** — the mathematical case is clear but Lean 4 type-theoretic issues may arise
2. **Local surjectivity of C5 witnesses has not been formally verified** — needs audit of limit_satisfies_c5_weak
3. **`temporal_coherent_family_exists_CanonicalMCS` unchecked** — may provide existing sorry-free infrastructure for Option C
4. **Construction-level gap analysis unexplored** — could prove succ_cofinal directly but is technically complex

### Recommendations

**Priority 1 — Option C (Direct Completeness on Z)** [6-10h, 85% confidence]
Build restricted_tc/fuc directly on Z where IsSuccArchimedean holds by definition. This bypasses succ_cofinal entirely without needing the Reynolds pipeline, Henkin chains, or conservative extensions.

**Priority 2 — Local Surjectivity Audit** [2-4h, medium confidence]  
Audit limit_satisfies_c5_weak to determine whether C5 witnesses always land on embedded integer points. If yes, the EXISTING code can be fixed with a local surjectivity lemma replacing global succ_embed_surjective. This could be even cheaper than Option C.

**Priority 3 — Construction-Level Gap Analysis** [8-12h, medium confidence]
Prove that the dovetailed construction cannot produce constant-MCS regions. Different stages insert points for different formulas, potentially ruling out the gap scenario. Most direct proof of succ_cofinal but high technical complexity.

### Task Ordering Update

Current TODO.md has: 199 → 174 → 155 → 202. Recommended changes:

1. **Remove 155 dependency from task 202** — Option C is architecturally independent
2. **Task 202 can proceed immediately** — needs nothing from 155, 174, or 199
3. **Task 176 handles all code archival** — no Boneyard work needed in task 202
4. **Task 129 should NOT be recreated** — its code is already in WeakCanonical/

Proposed ordering:
- **Independent**: Task 202 (Option C path, 6-10h)
- **Parallel track**: Tasks 199 → 155 (Reynolds pipeline, continues independently)
- **After both**: Task 176 (code archival), then Phase 2+ tasks

### Code Archival Summary

| Item | Action | Owner |
|------|--------|-------|
| HenkinDiscreteChain.lean | KEEP — sorry-free lemmas + documentation | Moves with Chronicle/ in task 176 |
| Non-Chronicle BXCanonical (~4,615 lines) | Archive to Boneyard/ | Task 176 |
| Bundle/SuccRelation + SuccExistence (10 sorries) | Archive to Boneyard/ | Task 176 |
| Nothing | Archive now in task 202 | — |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary path | completed | medium | Sorry chain audit, task 129 sorry count, deferral seed analysis |
| B | Code organization | completed | high | Archival scope, task 129 absorbed, dependency analysis, unblocking candidate |
| C | Critic | completed | high | **Local vs global surjectivity insight**, construction-level analysis, task 129 not viable |
| D | Strategic horizons | completed | high | **Option C (direct on Z)**, dependency outdated, project 99%+ complete |

## References

- ChronicleToCountermodel.lean:1804-1882 — constant-MCS gap analysis
- WitnessSeed.lean:175 — forward_temporal_witness_seed_consistent (sorry-free)
- Bundle/Construction.lean — temporal_coherent_family_exists_CanonicalMCS (unchecked candidate)
- specs/202_reynolds_k_equivalence_bypass/reports/04_teammate-{a,b,c,d}-findings.md — individual findings
- specs/202_reynolds_k_equivalence_bypass/plans/03_henkin-chain-plan.md — blocked plan v3
- ROADMAP.md — Phase 1 critical path, dead ends #34-36
