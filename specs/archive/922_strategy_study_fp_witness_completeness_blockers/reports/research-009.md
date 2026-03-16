# Research Report: Task #922 (research-009)

**Task**: Strategy study: forward_F/backward_P completeness blockers
**Date**: 2026-02-26
**Focus**: Post-FMP-completeness reassessment -- is this task still relevant?
**Session**: sess_1772170595_cd6964

## Summary

This report assesses whether task 922 remains relevant given the substantial changes since the last research (research-008, 2026-02-24). The project has achieved sorry-free FMP completeness and cleaned up multiple dead ends. Three sorries remain in the active Metalogic, all in the Int-indexed BFMCS construction, none on any critical path.

## Findings

### 1. What Changed Since research-008

Since the 2026-02-24 timeframe, the following major changes occurred:

| Change | Task | Impact |
|--------|------|--------|
| BFMCS Completeness uses `[Preorder D]` (not `[LinearOrder D]`) | 922/925 | Domain type constraint relaxed; CanonicalMCS viable |
| `canonicalMCSBFMCS` (all-MCS FMCS) sorry-free | 922 | forward_F and backward_P are trivially proven for CanonicalMCS domain |
| `temporal_coherent_family_exists_CanonicalMCS` sorry-free | 922 | Single FMCS over CanonicalMCS with all temporal coherence properties |
| ChainBundleBFMCS archived to Boneyard | 932 | MCS-membership semantics approach discarded as non-standard |
| CanonicalReachable/CanonicalQuotient archived to Boneyard | 933 | backward_P impossibility for future-reachable subset documented |
| Constant Witness Family archived to Boneyard | 932 | Cannot satisfy F/P obligations |
| FMP completeness verified sorry-free and axiom-free | 925 (FMP) | `fmp_weak_completeness` depends only on propext, Classical.choice, Quot.sound |

### 2. Current Sorry Inventory (Verified via `#print axioms`)

| Theorem | Depends on `sorryAx`? | Notes |
|---------|----------------------|-------|
| `fmp_weak_completeness` | **NO** | Publication-ready, sorry-free, axiom-free |
| `bmcs_weak_completeness` | YES | Via `fully_saturated_bfmcs_exists_int` |
| `bmcs_strong_completeness` | YES | Via `fully_saturated_bfmcs_exists_int` |
| `standard_weak_completeness` | YES | Via `construct_saturated_bfmcs_int` |
| `standard_strong_completeness` | YES | Via `construct_saturated_bfmcs_int` |
| `canonicalMCS_forward_F` | **NO** | Sorry-free over CanonicalMCS domain |
| `canonicalMCS_backward_P` | **NO** | Sorry-free over CanonicalMCS domain |
| `temporal_coherent_family_exists_CanonicalMCS` | **NO** | Sorry-free single FMCS |

The 3 active sorries:
1. `DovetailingChain.lean:1869` -- `buildDovetailingChainFamily_forward_F` (Int-chain F witness)
2. `DovetailingChain.lean:1881` -- `buildDovetailingChainFamily_backward_P` (Int-chain P witness)
3. `TemporalCoherentConstruction.lean:600` -- `fully_saturated_bfmcs_exists_int` (combines temporal + modal saturation for Int)

### 3. The Architectural Gap: What Remains

The CanonicalMCS approach has solved the temporal coherence problem (forward_F, backward_P). What it has NOT solved is the modal saturation problem.

**What exists**:
- A single sorry-free FMCS over `CanonicalMCS` (`canonicalMCSBFMCS`) with forward_F and backward_P
- The truth lemma (`bmcs_truth_lemma`) requires a BFMCS (bundle of families), not a single FMCS
- The truth lemma specifically needs `B.temporally_coherent` for ALL families in the bundle

**What is missing**:
- A full BFMCS over `CanonicalMCS` domain that includes:
  - Multiple FMCS families (for modal saturation / `modal_backward`)
  - Each family being temporally coherent (forward_F + backward_P for each)
  - Modal forward/backward conditions across all families

The crux: `canonicalMCSBFMCS` is a single family mapping each CanonicalMCS element to its own world. For modal saturation, we need MULTIPLE families -- one for each Diamond-formula witness. These witness families must ALSO be temporally coherent (satisfy forward_F and backward_P). The question is whether we can construct witness families over `CanonicalMCS` that satisfy temporal coherence.

**Key insight**: For `CanonicalMCS` domain, a "constant family" (where `fam.mcs w = W` for all `w : CanonicalMCS`) would trivially satisfy forward_F and backward_P IF the MCS `W` is temporally saturated (i.e., `F(psi) in W => psi in W`). But temporal saturation of a single MCS is impossible for sets like `{F(psi), neg(psi)}` (which is consistent). This is exactly the Dead End documented for the Constant Witness Family approach.

However, for the CanonicalMCS domain, we do NOT need constant families. Each witness family can be another copy of `canonicalMCSBFMCS` (the all-MCS identity mapping), just with a DIFFERENT root/eval point. Since `canonicalMCSBFMCS` is always temporally coherent (it maps each element to itself, and forward_F/backward_P are proven via canonical frame properties), every witness family is automatically temporally coherent. The modal saturation construction would:
1. Start with the eval family (canonicalMCSBFMCS rooted at some M0)
2. For each Diamond-formula Diamond(psi) in some family's MCS at time t: add a witness family (another copy of canonicalMCSBFMCS) rooted at the witness MCS W containing psi
3. All such witness families are automatically temporally coherent

This approach makes the `fully_saturated_bfmcs_exists` theorem provable over `CanonicalMCS` without sorry. The Int-indexed version would remain sorry-backed, but would become redundant.

### 4. Completeness Results: What Is and Isn't Sorry-Free

**Currently sorry-free completeness**:
- `fmp_weak_completeness` -- FMP weak completeness (standard semantics via finite models)
- The BFMCS completeness chain machinery (truth lemma, representation logic) is sorry-free GIVEN a sorry-free fully-saturated BFMCS

**Currently sorry-backed completeness**:
- `bmcs_weak_completeness` and `bmcs_strong_completeness` (BFMCS validity)
- `standard_weak_completeness` and `standard_strong_completeness` (standard validity)
- All blocked by `fully_saturated_bfmcs_exists_int`

**Achievable sorry-free completeness** (via CanonicalMCS domain):
- `bmcs_weak_completeness` and `bmcs_strong_completeness` for `D = CanonicalMCS`
- `standard_weak_completeness` for CanonicalMCS-based models
- This requires building a BFMCS over CanonicalMCS with modal saturation

**Not achievable without new mathematical insight**:
- `fully_saturated_bfmcs_exists_int` -- F/P witnesses in Int-indexed linear chains remain fundamentally blocked by Lindenbaum opacity
- Standard strong completeness with `D = Int`

### 5. Relevance Assessment

**Question**: Is task 922 still relevant given FMP completeness is sorry-free?

**Analysis of what FMP completeness provides**:
- Weak completeness: `valid phi => derivable phi` (sorry-free)
- Finite model property: satisfiable formulas have models with `<= 2^closureSize` states
- NO strong completeness (semantic consequence => derivability)
- NO compactness (finite subsets suffice for entailment)

**What BFMCS completeness over CanonicalMCS would additionally provide**:
- Strong completeness: `semantic_consequence Gamma phi => Gamma |- phi` (sorry-free)
- Standard semantics bridge: BFMCS satisfiability implies standard semantics satisfiability
- Architectural completeness: the ENTIRE metalogic chain from MCS through representation would be sorry-free

**What remains impossible (and does not need to be solved)**:
- Int-indexed sorry-free construction -- documented as dead end
- The 3 existing sorries in DovetailingChain/TemporalCoherentConstruction are for the Int path only

### 6. The Remaining Path: What Would Task 924 Need?

If the goal is sorry-free BFMCS strong completeness over CanonicalMCS, the work would be:

**Phase 1**: Construct `fully_saturated_bfmcs_exists_CanonicalMCS`
- Build a BFMCS over CanonicalMCS with modal saturation
- Key: each witness family = another copy of `canonicalMCSBFMCS` (identity mapping on all MCSes)
- Each witness family is automatically temporally coherent (forward_F and backward_P are already proven)
- Modal forward: if Box(phi) is in a family's MCS at point w, then phi is in ALL families' MCSes at w (since all families map w to w.world, and Box(phi) => phi by T-axiom)
- Modal backward: if phi is in ALL families' MCSes at w, then Box(phi) is in each family's MCS at w (by the standard modal saturation argument via Diamond contraposition)

**Phase 2**: Wire into Completeness.lean
- Replace `construct_saturated_bfmcs_int` with `construct_saturated_bfmcs_CanonicalMCS`
- The existing Completeness.lean already uses `[Preorder D]`, so CanonicalMCS fits directly

**Phase 3**: Wire into Representation.lean
- Adapt the standard representation bridge from `BFMCS Int` to `BFMCS CanonicalMCS`
- This requires constructing a `TaskFrame CanonicalMCS` (not `TaskFrame Int`)
- The trivial task relation approach still works for CanonicalMCS

**Estimated effort**: 4-8 hours (Phase 1 is the main work; Phases 2-3 are largely mechanical)

**Probability of success**: HIGH (85-90%). The mathematical content is already proven. The construction is a matter of packaging existing sorry-free components (canonicalMCSBFMCS + modal saturation) into a BFMCS. The only risk is unexpected Lean type-level obstacles in the packaging.

### 7. Why Modal Saturation Over CanonicalMCS Is Straightforward

The key mathematical insight that makes this work:

In the CanonicalMCS approach, EVERY FMCS in the bundle maps each point to ITSELF. So for ALL families in the bundle:
- `fam.mcs w = w.world` (the underlying MCS of w)

This means:
- **Modal forward**: If Box(phi) is in w.world, then by the T-axiom (Box phi => phi), phi is in w.world. Since every family maps w to w.world, phi is in every family's MCS at w.
- **Modal backward**: If phi is in every family's MCS at w, then phi is in w.world (since at least the eval family maps w to w.world). Now suppose Box(phi) is NOT in w.world. Then Diamond(neg(phi)) is in w.world (MCS negation completeness). By canonical_forward_F (or more precisely, by the MCS existence lemma for Diamond), there exists an MCS W where neg(phi) is in W. But W.world is also mapped to W.world by every family, so neg(phi) is in every family's MCS at the point corresponding to W. But we assumed phi is in every family's MCS at every point -- in particular at W. This gives phi AND neg(phi) in W.world, contradicting consistency.

Wait -- the modal_backward argument is more subtle. Modal backward requires: "if phi is in ALL families' MCSes at time t, then Box(phi) is in fam.mcs t". The quantification is over ALL families AT THE SAME TIME POINT t. In the CanonicalMCS approach:
- All families map t to t.world
- So "phi in ALL families' MCSes at t" means phi in t.world (which is the same for all families)
- We need: phi in t.world implies Box(phi) in t.world
- This is the converse of the T-axiom: phi => Box(phi)
- TM logic does NOT have this axiom

This means a single-family-per-point bundle does NOT satisfy modal_backward. We need DISTINCT families that can have DIFFERENT MCSes at the same time point, so that Diamond witnesses are nontrivial.

This is exactly the Dead End documented for "Single-Family BFMCS modal_backward" in the ROAD_MAP!

**Revised analysis**: The modal saturation over CanonicalMCS is NOT as straightforward as initially suggested. The identity-mapping families all agree at every point, so there is no nontrivial modal structure. To get modal_backward, we need families that DIFFER at some points.

For CanonicalMCS domain, witness families must have `fam.mcs w` potentially differ from `w.world`. This means the family is no longer the identity mapping. We would need families like:
- `witness_family(W).mcs(w) = W.world` for all w (a constant family)
- But constant families over CanonicalMCS have the temporal coherence problem documented in the Dead End

Alternatively:
- For each Diamond(psi) obligation, create a family that maps the evaluation point to the witness MCS W (containing psi), and maps other points via some coherent extension
- This is essentially the same problem as the Int case but over a Preorder domain

### 8. Corrected Assessment: Modal Saturation Remains the Blocker

After careful analysis, the situation is:

**Solved** (sorry-free):
- Temporal coherence (forward_F, backward_P) for the EVAL family over CanonicalMCS
- FMP weak completeness (no BFMCS needed, uses finite models directly)

**Still blocked**:
- Modal saturation for a BFMCS over ANY domain (Int or CanonicalMCS)
- The fundamental problem is that witness families must be temporally coherent, but:
  - Identity families all agree at every point (no modal diversity)
  - Constant families fail temporal coherence
  - Non-trivial families require solving the same F/P witness placement that failed for Int

**The remaining sorry** (`fully_saturated_bfmcs_exists_int`) captures exactly this gap: combining temporal coherence (all families satisfy forward_F/backward_P) with modal saturation (enough families to witness all Diamond formulas). Changing the domain from Int to CanonicalMCS does NOT help with this particular sorry, because the problem is not the domain -- it is the WITNESS FAMILIES.

### 9. What This Task Originally Asked

The task description asks for a meta-analysis of failed approaches with the constraint "sorry debt is NEVER acceptable." The creative reframing questions are:

> "What if the problem is not 'prove forward_F for a chain' but 'find a structure that makes forward_F trivially true'?"

This WAS answered by the CanonicalMCS approach -- forward_F is trivially true for the eval family. But the remaining problem is modal saturation, not temporal coherence.

> "What if we abandon BFMCS Int entirely and prove completeness through a different semantic structure?"

This WAS answered by FMP completeness -- it uses finite models, not BFMCS, and is fully sorry-free. But FMP only gives weak completeness, not strong.

> "Can we work backward from the goal state?"

Working backward: we need a BFMCS where ALL families satisfy forward_F/backward_P AND the bundle has enough families for modal_backward. The backward constraint is: Diamond(psi) in fam.mcs(t) implies there exists fam' in the bundle with psi in fam'.mcs(t). This fam' must ALSO satisfy forward_F and backward_P. Over CanonicalMCS domain, forward_F and backward_P for fam' require: F(phi) in fam'.mcs(w) implies exists s >= w with phi in fam'.mcs(s). If fam' is constant at W, this means F(phi) in W implies phi in W, which fails.

The only remaining paths are:
1. Non-constant witness families that are temporally coherent (hard: same problem as Int case)
2. A fundamentally different completeness proof structure that avoids the BFMCS construction entirely

### 10. Path 2: Strong Completeness Without BFMCS

Strong completeness says: if Gamma semantically entails phi, then Gamma derives phi. By contrapositive: if Gamma does not derive phi, then Gamma does not semantically entail phi (i.e., there exists a countermodel).

The FMP approach constructs FINITE countermodels for single formulas. Can it be extended to contexts?

**Key question**: Does TM logic have the Finite Model Property for CONTEXTS (not just single formulas)?

If yes: `fmp_strong_completeness` would give sorry-free strong completeness without any BFMCS.

If no: some form of infinitary construction (like BFMCS) is needed for strong completeness.

For TM logic (bimodal G/H with T and 4 axioms):
- The FMP is typically proven for SINGLE formulas (the closure is finite)
- For finite contexts Gamma, we can take the conjunction: `bigAnd(Gamma)`. If Gamma is consistent, then bigAnd(Gamma) is consistent, and FMP gives a finite model satisfying bigAnd(Gamma), hence satisfying all of Gamma.
- For INFINITE contexts... the current setup uses `List Formula` (finite lists), so this is a non-issue.

Since `ContextConsistent` and `ContextDerivable` use `List Formula` (finite), strong completeness for finite contexts should follow from weak completeness applied to `bigAnd(Gamma) -> phi`:
- If Gamma entails phi semantically, then `bigAnd(Gamma) -> phi` is valid
- By weak completeness, `bigAnd(Gamma) -> phi` is derivable
- Combined with `Gamma derives bigAnd(Gamma)`, we get `Gamma derives phi`

This is a standard trick. The FMP weak completeness should suffice for strong completeness over finite contexts.

## Recommendations

### Primary Recommendation: CONTINUE with revised scope

Task 922 should CONTINUE, but with a revised scope that shifts from "finding a path for BFMCS F/P witness completeness" to two actionable objectives:

**Objective A (HIGH VALUE, MEDIUM EFFORT)**: Prove `fmp_strong_completeness` sorry-free
- Extend the sorry-free FMP approach from weak to strong completeness
- Uses the finite context trick: `semantic_consequence Gamma phi` implies `valid (bigAnd(Gamma) -> phi)` implies `derives (bigAnd(Gamma) -> phi)` implies `Gamma derives phi`
- Requires: conjunction introduction/elimination lemmas and deduction theorem (both likely already proven)
- This would make ALL completeness results sorry-free without touching the BFMCS chain
- Estimated effort: 2-4 hours
- Success probability: 90%+

**Objective B (MEDIUM VALUE, LOW EFFORT)**: Mark BFMCS Int-indexed sorries as intentional gaps
- The 3 remaining sorries in DovetailingChain/TemporalCoherentConstruction are in the Int-indexed construction
- If FMP strong completeness is achieved sorry-free, these become purely vestigial
- Document them as "alternative approach with known mathematical gap" rather than "technical debt"
- Consider archiving DovetailingChain and TemporalCoherentConstruction to Boneyard

### Status Recommendation

**Do NOT mark task 922 as [COMPLETED] yet.** The original task goal (find a path to sorry-free completeness) is achievable via the FMP strong completeness route, which is a concrete, bounded task.

**Do NOT mark task 922 as [ABANDONED].** The goal of zero-sorry completeness is achievable -- just via a different route than originally envisioned.

**Recommended status**: [RESEARCHED] with the finding that the FMP route is the path to sorry-free strong completeness.

### Task 924 Status

Task 924 (prove `fully_saturated_bmcs_exists`) should be reconsidered:
- If FMP strong completeness succeeds, task 924 becomes moot (BFMCS is vestigial)
- If FMP strong completeness cannot be achieved, task 924 remains blocked on the same fundamental modal saturation + temporal coherence combination problem
- Recommend: PAUSE task 924 pending outcome of FMP strong completeness attempt

### Clean-Up Recommendations

If FMP strong completeness succeeds:
1. Archive DovetailingChain.lean to Boneyard (2 sorries eliminated from active code)
2. Archive TemporalCoherentConstruction.lean to Boneyard (1 sorry eliminated)
3. Update Completeness.lean to not import TemporalCoherentConstruction
4. The entire Bundle/ directory would be sorry-free (or unnecessary for the main results)
5. Update ROAD_MAP.md "Proof Economy" ambition to show all criteria complete

## Architecture Summary

```
CURRENTLY SORRY-FREE                    CURRENTLY SORRY-BACKED
================================        ================================
FMP/SemanticCanonicalModel.lean         Bundle/Completeness.lean
  fmp_weak_completeness                   bmcs_weak_completeness (via sorry)
  (no strong completeness yet)            bmcs_strong_completeness (via sorry)

                                        Representation.lean
                                          standard_weak_completeness (via sorry)
                                          standard_strong_completeness (via sorry)

ACHIEVABLE (proposed path)              BLOCKED (Int-indexed, dead end)
================================        ================================
FMP strong completeness                 DovetailingChain forward_F/backward_P
  via bigAnd(Gamma) trick               TemporalCoherentConstruction
  ~2-4 hours, 90%+ success              fully_saturated_bfmcs_exists_int

                                        ALSO BLOCKED (CanonicalMCS BFMCS)
                                        ================================
                                        Modal saturation + temporal coherence
                                        combination for witness families
```

## Answers to Research Questions

### 1. What remains?

Given FMP completeness is sorry-free, the remaining value is **strong completeness**: proving `semantic_consequence Gamma phi => Gamma |- phi` sorry-free. FMP currently only provides weak completeness. The BFMCS chain has strong completeness but with a sorry dependency.

### 2. What is the best path?

The best path is to prove `fmp_strong_completeness` by extending the FMP approach using the finite context / big conjunction trick. This avoids the BFMCS modal saturation blocker entirely. Estimated 2-4 hours, 90%+ success rate.

### 3. Prospects of success

**HIGH** for FMP strong completeness. The mathematical argument is standard, the infrastructure (deduction theorem, conjunction lemmas) likely already exists, and the FMP approach is proven to work.

**LOW** for BFMCS sorry-free completion over any domain. The modal saturation + temporal coherence combination remains a genuine mathematical obstacle, independent of the choice of domain (Int or CanonicalMCS).

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Sorry-free FMP weak completeness
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - BFMCS completeness (sorry-dependent)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Sorry-free temporal coherence for CanonicalMCS FMCS
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Modal saturation infrastructure
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - 2 sorries (Int-indexed F/P witnesses)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - 1 sorry (combining temporal + modal)
- `Theories/Bimodal/Metalogic/Representation.lean` - Standard semantics bridge (sorry-dependent)
- `specs/ROAD_MAP.md` - Current state, dead ends, ambitions
- `specs/reviews/review-20260226.md` - Post-cleanup review
- `specs/reviews/review-20260226-full.md` - Full codebase review

## Next Steps

1. **Verify FMP strong completeness feasibility**: Check if `bigAnd` / conjunction introduction exists, check if the deduction theorem bridges contexts to single formulas
2. **Create implementation plan**: If feasible, plan the FMP strong completeness proof
3. **Update task 924 status**: Depending on FMP outcome, either abandon or continue task 924
4. **Update ROAD_MAP.md**: Reflect the revised strategy (FMP route to full completeness)
