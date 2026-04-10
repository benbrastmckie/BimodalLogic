# Teammate D Findings (Round 4): Strategic Horizons

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Teammate D (Strategic Horizons)
**Focus**: Post-implementation strategic assessment — what changed after 3 rounds, what the optimal next step is, and whether task 88 scope is correct

---

## Key Findings

### 1. What Changed After 3 Implementation Rounds

Three rounds of research + 1 implementation attempt have clarified the picture significantly.

**Progress made (task 88 so far)**:
- Phase 1 (plan v1): Restored BX11/BX12 axioms (temp_linearity, F_until_equiv) — independently valuable; closed downstream ConservativeExtension sorries
- Phases 1-6 (plan v1 remainder): axiom restoration cascade complete
- Plan v2: Proposed interval linearity from BX7+BX12 — demolished by Round 3 Critic
- Plan v3 Phase 1: Closed 2 SuccChainFMCS sorries (F_top_theorem, P_top_theorem)
- Plan v3 Phase 2 (architecture spike): NO-GO. Until-witness chain bx_le redefinition still faces the same guard propagation problem with two independent chains not being comparable.

**The current sorry count**: 6 (unchanged from task start — Frame:653, 675, 690, 704; CanonicalEmbedding:418; Completeness:160)

**What we now know with HIGH confidence**:
1. The X-vs-G mismatch is fundamental and **architectural**, not proof-engineering
2. Any global ordering definition (whether g_content or Until-witness chains) faces the same guard problem
3. CanonicalEmbedding:418 (`usf_completeness`) is INDEPENDENT of the Frame.lean sorries — different module, different theorem, different technique needed
4. CanonicalEmbedding:418 is NOT on the critical path for `bx_completeness` (Completeness.lean does not import CanonicalEmbedding)
5. The FMP bridge requires the same temporal truth lemma that BXCanonical needs — not a bypass

### 2. Strategic Assessment: Is BXCanonical the Right Continued Investment?

**Investment so far**: 5 rounds of research (tasks 83-88), 3 implementation rounds, 40+ analysis sessions. Cost: high. Progress on Frame.lean: zero closed sorries.

**The case FOR continued BXCanonical investment**:
- `bx_completeness` is the single most publication-valuable theorem possible from this project
- There are no sorry-free completeness results in Lean 4 for bimodal/temporal logics — a first
- Round 3 identified three architecture alternatives (quasimodel, two-indexed, formula-specific ordering) that have NOT been tried
- The infrastructure is rich: g_content, BX axioms, MCS properties are all proven
- Frame.lean:653/690 (forward eventuality) are the actual bottleneck; backward and downstream follow

**The case AGAINST continued BXCanonical investment**:
- 5 rounds of research without ANY sorry closure in Frame.lean (unlike WitnessSeed, SuccChainFMCS)
- Each round produces a new "viable" approach that fails implementation
- The mathematical obstacle is confirmed fundamental: guard quantification over ALL intermediate points requires either linearity (unavailable) or per-point construction (requires a different canonical model architecture)
- Alternative completeness results are available and less blocked

**Assessment**: The problem is genuinely hard but NOT provably impossible. The NO-GO decisions have all been for specific approaches (global linearity, interval linearity, chain redefinition), not for the Frame.lean goal itself. Three unexplored approaches remain. **Continued investment is warranted but with a time-boxed scope and clear criteria for pivoting.**

### 3. The Correct Strategic Priority Ordering

Given what was learned in rounds 1-3, here is the current best strategic ordering:

**Track A: CanonicalEmbedding:418 (independent, 12-18 hours, HIGH value)**

`usf_completeness` (Until/Since-free fragment = S5 + G + H) has ONE remaining sorry. The approach is established: use `RestrictedTemporallyCoherentFamily` from `SuccChainFMCS.lean` to build a DRM chain for Case B (antecedent-not-valid). The summary from plan v3 documents the concrete approach with 12-18 hour estimate.

Why this is Track A:
- INDEPENDENT of Frame.lean sorries
- Gives a publishable first result: sorry-free completeness for S5 + G/H (Priorean tense logic with S5 modalities)
- The infrastructure exists in `SuccChainFMCS.lean` — this is proof engineering, not research
- Clear success criterion: `grep -n "sorry" CanonicalEmbedding.lean` returns zero

**Track B: Frame.lean quasimodel approach (research spike, 4-8 hours research, 30-40 hours implementation if viable)**

The quasimodel/filtration approach (GHR 1994) has NOT been tried in this codebase despite being mentioned 5+ times in research. It works differently: instead of a global canonical frame, it builds a satisfaction-compatible structure where each formula's truth is assigned directly without requiring propagation through the ordering.

Why this might work where others failed:
- Avoids bx_le entirely — no ordering to propagate through
- Standard technique in temporal logic completeness (Gabbay-Hodkinson-Reynolds 1994, Wolter-Zakharyaschev)
- The X-vs-G mismatch does not apply because there is no g_content propagation requirement
- Completeness for bimodal logics via quasimodel is established in the literature

Risk: the quasimodel approach is a major rewrite (~1500-2000 LOC in a new module), and the linearization issues noted in task 83 report 24 may be fundamental. This needs an explicit research spike to assess viability before committing.

**Track C: Narrow task 88 scope and create Frame.lean Track as task 89**

The CanonicalEmbedding:418 sorry is worth pursuing now (Track A). The Frame.lean sorries need a fresh approach (Track B) but are uncertain. These are better managed as separate tasks with:
- Task 88: narrowed to close CanonicalEmbedding:418 only (12-18h, high confidence)
- Task 89: close Frame.lean sorries via quasimodel/alternative architecture (research-heavy, 40-80h estimate, medium confidence)

### 4. Marginal Value Assessment: BXCanonical vs. Alternatives

| Result | What It Gives | Effort Remaining | Confidence | Publication Value |
|--------|--------------|------------------|------------|------------------|
| `usf_completeness` (CanonicalEmbedding:418) | S5+G/H completeness | 12-18h | MEDIUM-HIGH | HIGH — first S5+G/H in Lean 4 |
| `bx_completeness` (all 6 sorries) | Full TM completeness | 40-80h | MEDIUM (unknown approach) | VERY HIGH — first TM bimodal in Lean 4 |
| `fmp_completeness` (already done) | FMP | 0h | DONE | MEDIUM — good, but standard result |
| Task 82: FMP TruthPreservation (2 sorries) | Weak completeness via FMP | 1-2h | HIGH | MEDIUM — closes FMP chain |
| Task 68: Dense completeness via Rat | Dense fragment | 20-40h | MEDIUM | MEDIUM |

**Immediate highest-ROI action**: Close the 2 FMP TruthPreservation sorries (task 82, 1-2 hours, HIGH confidence). This closes the FMP chain and is independent of everything else. Then pursue CanonicalEmbedding:418.

### 5. Should Task 88 Be Split?

**Current scope**: 6 sorries (Frame:4 + CanonicalEmbedding:1 + Completeness:1)

**Problem with current scope**: The 4 Frame.lean sorries and the 1 CanonicalEmbedding sorry are fundamentally different technical problems requiring different techniques:
- Frame.lean requires architectural rethinking of the canonical model (50-100h, uncertain)
- CanonicalEmbedding requires extending the WorldHistory infrastructure (12-18h, established)

**Recommendation**: Split task 88 now.

**Task 88 (revised scope)**: Close CanonicalEmbedding:418 only for sorry-free `usf_completeness`
- 12-18h, proof engineering, established approach
- Definition of done: `usf_completeness` is sorry-free and `lake build` passes

**New task 89**: Close Frame.lean sorries (4 of 6 BXCanonical) via quasimodel or alternative architecture
- Research-heavy, 40-80h, medium confidence
- Prerequisite: quasimodel viability research spike
- Dependency: task 88 (CanonicalEmbedding independence confirmed, but separate)
- Definition of done: all 4 Frame.lean eventuality sorries closed

**New task 90**: Wire `bx_completeness` via TruthLemma once Frame.lean is resolved
- Short (1-2h), downstream of 89

This split clarifies the roadmap and prevents a blocked Frame.lean track from delaying the achievable CanonicalEmbedding result.

### 6. Is There a Minimal Publishable Result Already?

**Yes, TODAY (without closing any more sorries)**:

The project already has:
- `soundness` (sorry-free, axiom-free)
- `validity_decidable` + `fmp_completeness` (sorry-free, axiom-free)
- `fragment_completeness` for `{atom, bot, imp, box}` (sorry-free)
- Algebraic representation theorem `parametric_algebraic_representation_relative` (sorry-free, conditional)
- FMP: any unprovable formula has a finite countermodel bounded by `2^|closure(φ)|`

This is publishable as a "first formalization of bimodal TM logic soundness, decidability, and FMP in Lean 4."

**After closing CanonicalEmbedding:418**:

Sorry-free `usf_completeness` = completeness for S5 + G/H. This is the first formalization of Priorean tense logic completeness in Lean 4 (the S5+G/H fragment is the bimodal logic studied by Prior 1957, Goldblatt 1992). This is a SIGNIFICANT milestone.

**After closing all 6 sorries** (task 88 new scope + task 89 + 90):

First formalization of TM bimodal logic completeness with Until/Since in Lean 4. This is the strongest academic claim and the only result that fully completes the soundness/completeness circle.

### 7. The Axiom Question — Is BX1-BX12 the Right System?

After 5 rounds, the evidence is clear:

The BX axiom system (BX1-BX12 with restored BX11/BX12) IS sound and IS complete for the intended semantics. The evidence:
- `temp_linearity_valid` is proved sorry-free (BX11 is semantically valid)
- `F_until_equiv_valid` is provable similarly (BX12 is semantically valid)
- `soundness` covers all axioms sorry-free
- The 3-point counterexample in `LinearityDerivedFacts.lean` proved BX11 was NOT derivable from BX1-BX10 (hence needed restoration, not removal)

The issue is NOT "are the axioms right?" but "is the canonical model construction technique appropriate?" The answer is: BXCanonical as currently architectured (global MCS ordering via g_content) is insufficient for Until/Since. The axioms are correct; the model construction needs a different technique.

This distinction is important for planning: future work should focus on **model construction technique**, not axiom modification.

### 8. The Quasimodel Approach — What It Would Require

The GHR (Gabbay-Hodkinson-Reynolds 1994) quasimodel approach for Until/Since logics works as follows:

**Idea**: Instead of building a single global canonical frame from all MCSs, construct a **satisfaction-compatible model** piece by piece:
1. For the root formula φ, take an MCS w₀ with ¬φ ∈ w₀
2. Extend w₀ to a "quasimodel" — a finite structure that satisfies all the local consistency properties
3. The key: eventuality formulas (φ U ψ) are resolved by **construction** of witnesses, not by appeal to an ordering property

**Why it avoids the X-vs-G mismatch**: Quasimodels assign truth at each world explicitly, without requiring propagation through a pre-existing ordering. The guard condition `∀ u ∈ [w,v), φ ∈ u` is satisfied **by construction** because we build v specifically to witness the eventuality.

**Potential blockers**:
- Quasimodels are typically finite; extending to infinite models requires a limit argument
- Modal content must be consistent across the quasimodel (S5 constraint)
- The construction is complex: GHR 1994 is 40+ pages for pure temporal logic; bimodal extension adds the S5 dimension

**Prior task 83 report 24 findings**: "linearization issues — determine if fundamental or surmountable." This needs to be the focus of any task 89 research.

---

## Confidence Level

| Claim | Confidence | Basis |
|-------|-----------|-------|
| CanonicalEmbedding:418 closable in 12-18h | MEDIUM-HIGH (65%) | Plan v3 summary documented concrete approach; SuccChainFMCS infrastructure present |
| Splitting task 88 is correct | HIGH (85%) | Independent problems with different techniques; different time horizons |
| Quasimodel approach viable for Frame.lean | MEDIUM (50%) | Standard literature technique; linearization risk from task 83 not resolved |
| bx_completeness achievable with ~80h additional work | MEDIUM (55%) | Dependent on quasimodel viability; architectural risk |
| Current project is publication-ready as system description | HIGH (90%) | Soundness + decidability + FMP all sorry-free |
| Closing CanonicalEmbedding first is highest ROI | HIGH (80%) | Independent, established technique, publishable milestone |

---

## Recommendations

### Primary: Split Task 88 Now

1. **Revise task 88** to scope = close CanonicalEmbedding:418 only
   - 12-18h estimate
   - Use the `RestrictedTemporallyCoherentFamily` approach documented in plan v3 summary
   - Clear success criterion: sorry-free `usf_completeness`

2. **Create task 89**: Close Frame.lean sorries via quasimodel/alternative architecture
   - Start with a 4-8h research spike into quasimodel viability
   - If viable: 30-40h implementation
   - If not viable: document as open problem requiring novel technique

3. **As immediate quick win**: Complete task 82 (FMP TruthPreservation, 1-2h) to close the FMP chain independently

### Secondary: Assess Quasimodel Viability (Task 89 Prerequisite)

Before committing to task 89, investigate:
- What exactly were the "linearization issues" in task 83 report 24?
- Does the GHR 1994 technique work for reflexive vs. strict temporal semantics?
- Can the bimodal constraint (S5 modality) be embedded naturally in a quasimodel?

This spike (~4h) determines whether task 89 is 30-40h or blocked.

### Strategic Summary

| Milestone | Path | Time | Confidence |
|-----------|------|------|------------|
| Close FMP chain | Task 82 (2 sorries) | 1-2h | HIGH |
| Close USF completeness | Task 88 revised (1 sorry) | 12-18h | MEDIUM-HIGH |
| Close Frame.lean (4 sorries) | Task 89 (quasimodel) | 40-60h | MEDIUM |
| Full `bx_completeness` | Task 90 (wire Completeness) | 2h | HIGH (if 89 done) |

**Net recommendation**: The project is at an inflection point where splitting and narrowing scope will accelerate progress more than continued broad-scope attempts on a fundamental blocker.
