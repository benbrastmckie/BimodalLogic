# Research Report: Task #83 — Sorry Blocker Resolution & Publication Readiness

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Mode**: Team Research (4 teammates)
**Session**: sess_1775246158_e62aab

## Summary

Four-agent deep investigation of the remaining sorry sites, dead code, roadmap status, and plan gaps for task 83. The strict semantics refactor (reflexive -> strict, T-axiom removed) was architecturally correct but expanded the sorry count from 2 to ~85. The build passes (940 jobs, 0 errors) but `completeness_over_Int` depends on `sorryAx`. FMP completeness is already sorry-free. Three critical blockers remain: (1) X-content propagation through the Succ chain, (2) TemporalDerived.lean has 4 foundational sorries, (3) backward Until truth lemma unsolved after 4 plan versions. An alternative approach (DRM bounded_witness on the original reflexive system) was identified but never tried.

## Key Findings

### 1. Sorry Census (from Teammates A + C)

| Category | Count | Blocking? | Confidence |
|----------|-------|-----------|------------|
| Soundness frame-class (intentional) | 19 | NO | HIGH |
| Completeness critical path | ~26 | YES | HIGH |
| Algebraic path (non-critical) | ~13 | NO | HIGH |
| FMP TruthPreservation (task 82) | 2 | NO | HIGH |
| Temporal derived theorems | 4 | YES (foundation) | HIGH |
| Examples/pedagogical | ~14 | NO | HIGH |
| Misc chain/dead code | ~7 | Mixed | MEDIUM |
| **Total** | **~85** | | |

### 2. Critical Path Dependency Graph (from Teammate A)

```
Tier 5: X_bot_absurd, Y_bot_absurd (TemporalDerived.lean)
  |
  v
Tier 5: until_implies_some_future, since_implies_some_past
  |
  +--------+--------+
  |                  |
  v                  v
Tier 8: WitnessSeed    Tier 3: Until/Since
consistency (2)         Truth Lemma (8)
  |                       |
  v                       v
Tier 4: X-content       Tier 4: Until persistence
propagation (12)        through Succ (SuccRelation)
  |                       |
  v                       v
Tier 7: Restricted      Tier 1+2: Seed redesign
forward_F/backward_P    for strict semantics (14)
  |
  v
COMPLETENESS THEOREM

Independent: Tier 9: Soundness (19 sites, routine, HIGH confidence)
```

### 3. Root Cause Analysis (from Teammate A)

The **single deepest root cause** is removal of the T-axiom (`G(phi) -> phi`) during the strict semantics transition. Under reflexive semantics, `g_content(u) subset u` held trivially; under strict semantics it is **FALSE**. This cascades into ~25 sorry sites directly and enables further gaps.

**Two theorems are provably FALSE** and should be deleted: SuccChainFMCS.lean lines 2160, 2182 (documented counterexamples).

### 4. Three Critical Blockers (from Teammates A + D)

**Blocker 1: X-Content Propagation** (CRITICAL, not in current plan)
- `X(alpha) = bot U alpha` is neither in g_content nor f_content
- The Succ relation only propagates g_content and f_content
- `X(alpha) in mcs(t)` should give `alpha in mcs(t+1)` but no infrastructure exists
- **Fix options**: (a) Extend Succ with x_step, (b) Derive `F(alpha)` from `X(alpha)` and use F-propagation

**Blocker 2: TemporalDerived.lean Sorries** (HIGH, foundation incomplete)
- 4 sorries in the foundational derived theorems: `X_bot_absurd`, `Y_bot_absurd`, `until_implies_some_future`, `since_implies_some_past`
- All downstream phases depend on these
- The derivation sketches exist (report 12) but Lean implementation is incomplete

**Blocker 3: Backward Until Truth Lemma** (CRITICAL, unsolved in 4 versions)
- Getting `phi U psi in mcs(t)` from semantic witnesses requires extending `phi U psi` past the witness point `s`
- 4 plan versions attempted this; all failed
- **Most promising untried approach**: Contrapositive — forward truth lemma gives `phi U psi in mcs(t) => truth(phi U psi, t)`; by MCS maximality, `truth(phi U psi, t) => neg(phi U psi) not in mcs(t) => phi U psi in mcs(t)`. Requires induction on Until-complexity, not formula structure.

### 5. Dead Code & Cleanup (from Teammate B)

| Category | Lines | Action |
|----------|-------|--------|
| T-axiom dependent sorry sites (8 functions across 4 files) | ~200 | Archive to Boneyard/ |
| Stale comments referencing reflexive semantics | ~180 | Update |
| Deprecated aliases (>10 days old) | ~15 | Remove |
| Ghost directories (Canonical/, Soundness/) | 2 dirs | Delete |
| typst/06-notes.typ labels reflexive as "Current" | ~236 | Rewrite |

**Proposed Boneyard structure**: `Theories/Bimodal/Boneyard/TAxiomDependentCode/` for TargetedChain, SuccChainFMCS, CanonicalConstruction, and FMP reflexive sorry sites.

### 6. Publication Readiness (from Teammate C)

| Dimension | Score |
|-----------|-------|
| Core Formalization | 8/10 |
| Completeness | 5/10 |
| Custom Axioms | 8/10 |
| Module Organization | 9/10 |
| Docstring Coverage | 8/10 |
| Build Health | 10/10 |
| **Overall** | **7.3/10** |

**Key verified results**: `soundness_dense` sorry-free. `fmp_completeness` sorry-free. `completeness_over_Int` has sorryAx.

### 7. Plan Evolution & Failure Patterns (from Teammate D)

**5 recurring failure patterns** across 12 plan versions:
1. **Seed Consistency Trap** (v1-v4): Enriched seeds fail G-liftability (proved impossible with counterexample)
2. **Perpetual Deferral** (v1-v4): F-only axiom system has no forcing mechanism
3. **Backward Until Wall** (v6-v8): Cannot extend `phi U psi` past witness point
4. **T-Axiom Dependency Web** (v11-v12): Removing T-axiom cascades into ~67 sites
5. **Scope Creep** (v6+): Task transformed from "close 2 sorries" to "redesign temporal logic"

**Sorry count trajectory**: 2 -> 76+ (increased, not decreased)

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate D | Resolution |
|----------|-----------|-----------|------------|
| Sorry count | 64 on completeness path | 76 total (15 critical) | Different scoping — A counts completeness path specifically, D includes all. Using C's census: ~85 total, ~26 critical path. |
| Achievability | HIGH confidence on seed + derived theorems | UNCERTAIN for current approach | Both agree blockers 1-3 are real. D's skepticism is warranted by 12 plan versions. The contrapositive approach for blocker 3 has NOT been tried. |
| Alternative D (revert to reflexive) | Not considered | Recommended as fallback | Not recommending revert — strict semantics is the mathematically correct foundation. But Alternative D merits investigation as an escape hatch. |

### Gaps Not Covered by Any Teammate

1. **Soundness audit for current semantics**: Teammate D flagged that some of the 19 "intentional" soundness sorries may indicate genuine unsoundness under strict semantics (not just missing proofs for frame-class axioms). An audit is needed.
2. **SuccChainFMCS file splitting**: At 6345 lines, this file is a maintenance hazard. No teammate proposed a concrete splitting plan.

### ROADMAP Updates Needed

From Teammate C's assessment, the TODO.md metrics are stale:
- `sorry_count: 20` should be `85`
- `publication_path_sorries: 4` should be `26`
- Critical path: `83 (phases 6-9) -> 58 -> 60`, with 82 in parallel

## Recommendations

### Priority 1: Close TemporalDerived.lean Sorries (4 sites)
- Implement the derivation trees from research report 12 sketch
- This unblocks ALL downstream phases
- Estimated: 2-3 hours, MEDIUM confidence

### Priority 2: X-Content Propagation Infrastructure
- Either extend Succ relation with x_step/y_step, OR
- Derive `X(a) -> F(a)` and use existing F-propagation
- This is the CRITICAL gap not in the current plan
- Estimated: 3-4 hours, MEDIUM confidence

### Priority 3: Seed Redesign for Strict Semantics (14 closures)
- Replace `g_content(u)` with `{F(chi) | G(chi) in u}` in seed
- Consistency follows from seriality: `G(chi) -> F(chi)`
- HIGH confidence, well-understood

### Priority 4: Backward Until Truth Lemma (Contrapositive)
- Implement the contrapositive approach (never tried)
- Induct on Until-complexity, not formula structure
- Forward direction first, then backward via MCS maximality
- MEDIUM confidence, highest mathematical risk

### Priority 5: Dead Code Cleanup & Boneyard
- Archive 8 T-axiom sorry functions to Boneyard/
- Delete 2 FALSE theorems (SuccChainFMCS 2160, 2182)
- Update stale documentation (typst, READMEs, comments)
- Delete ghost directories (Canonical/, Soundness/)

### Priority 6: Soundness Frame-Class Proofs (19 sites, parallel track)
- Routine semantic validity proofs
- Independent of completeness
- HIGH confidence, good for parallel work

## Teammate Contributions

| Teammate | Angle | Status | Tool Uses | Confidence |
|----------|-------|--------|-----------|------------|
| A | Sorry blocker & infrastructure | Completed | 72 | HIGH |
| B | Dead code & Boneyard cleanup | Completed | 40 | HIGH |
| C | ROADMAP & progress assessment | Completed | 75 | HIGH |
| D | Plan critic & gap analysis | Completed | 39 | MEDIUM-HIGH |

## References

- Burgess (1982): Axiomatization of linear temporal logic with Until
- Xu (1988): Completeness of Until-enriched tense logic
- Reynolds (2003): Axiomatization and completeness results for Until logic
- Gabbay-Hodkinson-Reynolds (1994): Temporal Logic — strict semantics standard formulation
- Research reports 01-12 in specs/083_close_restricted_coherence_sorries/reports/
