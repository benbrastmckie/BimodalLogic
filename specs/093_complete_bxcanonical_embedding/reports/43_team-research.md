# Research Report: Task #93 - Round 43

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1776616161_3b75e1
**Focus**: Rigorously study the last blocker to identify a mathematically correct long-term solution to overcome the control problem, scanning literature for relevant techniques.

## Summary

All four teammates independently confirm the **control problem is irreducible with the current architecture**. The fundamental tension is: no single Lindenbaum extension can simultaneously (a) guarantee a specific target phi is directly resolved AND (b) preserve F-obligations for all other sigma_list formulas. The enriched resolving seed `{target} ∪ g_content(M) ∪ f_carry(M)` is **definitively inconsistent** in general (concrete counterexample constructed). Standard temporal logic completeness proofs avoid this problem entirely by using finite Hintikka sets or constructive step-by-step methods.

The team identifies **three viable paths forward**, each with different risk/reward profiles. The `self_resolving_fwd_step` infrastructure already in the codebase is the key building block, but cannot be directly substituted into the existing chain without losing F-persistence for non-target formulas.

## Key Findings

### 1. Enriched Resolving Seed: DEFINITIVELY INCONSISTENT (Teammate B, confirmed)

**Question**: Is `{target} ∪ g_content(M) ∪ f_carry(M)` consistent when `F(target) ∈ M`?

**Answer**: **NO**. The G-lift consistency argument requires G(chi) ∈ M for each chi in any inconsistent subset L. For chi ∈ g_content(M), G(chi) ∈ M by definition. For chi = F(alpha) ∈ f_carry(M), we have F(alpha) ∈ M but G(F(alpha)) ∈ M is NOT guaranteed. The G-lift fails at f_carry elements.

**Concrete counterexample**: Let M contain F(p), F(q), and G(p ↔ ¬F(q)). Then g_content ⊇ {p ↔ ¬F(q)}, f_carry ⊇ {F(p), F(q)}, target = p. The seed {p, p ↔ ¬F(q), F(q)} derives: from p and p ↔ ¬F(q), we get ¬F(q). Combined with F(q) ∈ seed, this is ⊥.

**Impact**: This closes the single most-discussed potential solution path. No "enriched resolving seed" approach can work.

### 2. Literature Survey: Standard Proofs Avoid the Control Problem Entirely (Teammates A, D)

Standard temporal logic completeness proofs handle F-obligation resolution through fundamentally different mechanisms:

| Approach | Mechanism | Applicability to BXCanonical |
|----------|-----------|------|
| Tableau pruning (Wolper 1985) | Eliminate non-fulfilling branches | NO (requires finite state) |
| Finite Sigma scheduling (GHR 1994) | Finite Hintikka sets, defect count decreases | PARTIALLY (quasimodel path) |
| Constructive step-by-step (Burgess 1982) | Deterministic seed at each step | PARTIALLY (self_resolving_fwd_step) |
| Until Induction Rule (Lichtenstein-Pnueli 2000) | Changes axiom system | NO (task requires existing BX axioms) |
| Buchi automata | Built-in fairness condition | NO (not MCS-based) |

**Key insight**: None of these prove "F(phi) eventually resolves on an arbitrary MCS chain." They all BUILD chains where resolution is guaranteed by construction. The BXCanonical codebase's attempt to prove resolution as a PROPERTY of a pre-built chain is the non-standard move causing the 42-round difficulty.

### 3. The Control Problem Is Mathematically Irreducible (All teammates agree)

The `preserving_fwd_step` uses `defect_step_choice_early` which wraps `resolving_enriched_fwd_exists`. At each step:
- SOME defect w from active_defects is resolved (w ∈ M')
- ALL F-obligations preserved (F(chi) ∈ M' for all chi in active_defects)
- g_content(M) ⊆ M'

The resolved w is determined by Classical.choice on the BX11 fold existential. This choice is:
- Deterministic (fixed by the proof term)
- Uncontrollable (could always pick the same w ≠ phi)
- Not subject to well-founded induction (defect count never decreases)

**Why defect count never decreases**: w ∈ M' implies F(w) ∈ M' (by `phi_in_mcs_imp_F_phi`). So resolved defect w immediately re-enters active_defects. The set of active defects is monotonically non-decreasing.

### 4. Strict Defect Counting: Novel but Incomplete (Teammate C)

A "strict defect" is F(chi) ∈ M AND chi ∉ M (the formula itself is absent). When defect_step_choice_early resolves w (w ∈ M'), w is no longer a strict defect in M' (since w ∈ M'). So strict defect count decreases by at least 1.

**Problem**: New strict defects can appear. A formula chi ∈ M \ g_content(M) with F(chi) ∈ M could have chi dropped by Lindenbaum extension (chi ∉ M'), creating a new strict defect. The net change in strict defect count is not provably negative.

**Status**: Promising direction requiring further investigation. The key question is whether Lindenbaum dropoff can be bounded.

### 5. self_resolving_fwd_step: Right Tool, Wrong Slot (Teammates A, D)

`self_resolving_fwd_step` (RootScopedChain.lean:1594-1629, sorry-free) gives: given F(psi) ∈ M, constructs M' with psi ∈ M' AND F(psi) ∈ M' AND g_content(M) ⊆ M'.

Teammate A proposed using this as the chain step function. The proof sketch:
1. F-persistence carries F(phi) to step k where schedule(k) = phi
2. self_resolving_fwd_step resolves phi at step k
3. schedule_surjective_above guarantees phi is scheduled

**Critical flaw**: self_resolving_fwd_step uses seed {psi, F(psi)} ∪ g_content(M), which does NOT include f_carry(M). Other F-obligations F(chi) for chi ≠ psi are NOT preserved. So `fwd_chain_F_persistent` fails for the resolve_chain, breaking the proof at step 1.

**The fundamental tension** (confirmed by all teammates): No single Lindenbaum extension simultaneously achieves target control AND F-preservation. This is the mathematical crux.

### 6. Backward Case (t-s < 0) Is Structurally Different (Teammate C)

For F(phi) in the backward chain: g_content propagation goes forward in index but BACKWARD in time (g_content(bwd_chain(k)) ⊆ bwd_chain(k-1)). F-obligations do NOT propagate from bwd_chain(k) to M_0 = bwd_chain(0). The backward case requires a separate argument and cannot be reduced to the forward case.

### 7. The restricted_tc Witness Must Be In The Actual Chain (Teammate D)

`restricted_temporally_coherent` requires phi ∈ fam.mcs(u) where fam = shifted_dd_fmcs N h_N sigma_list s, so fam.mcs(u) = dd_chain N h_N sigma_list (u-s). The witness MUST be in the actual dd_chain, not an externally constructed MCS. This rules out "per-formula witness chain" approaches.

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate A claims self_resolving_fwd_step solves forward_F. Teammates B, D show it loses F-obligations for non-targets.

**Resolution**: Teammate A's proof sketch has a gap at the F-persistence step. The resolve_chain using self_resolving_fwd_step does NOT satisfy fwd_chain_F_persistent because the step function doesn't preserve f_carry. The approach requires the enriched seed (which is inconsistent) to fix this. **Teammate B and D are correct**: self_resolving_fwd_step alone is insufficient.

**Conflict 2**: Teammate C proposes strict defect counting as a solution. Others focus on the uncontrollable Classical.choice.

**Resolution**: Both perspectives are correct about different aspects. The strict defect counting is a genuinely new idea (not explored in 42 prior rounds) but has the Lindenbaum dropoff problem. It deserves further investigation but is not yet a complete solution. The Classical.choice obstruction is the deeper issue.

**Conflict 3**: Teammate D suggests quasimodel replication as fallback. Others focus on fixing the current chain.

**Resolution**: Both paths should be pursued. The current chain approach (preserving_fwd_step) is architecturally correct but needs a breakthrough on the termination argument. The quasimodel approach avoids the problem entirely but requires significant new wiring.

### Gaps Identified

1. **Strict defect counting**: Can Lindenbaum dropoff be bounded? Is there a well-founded measure combining strict defect count with sigma_list position?

2. **deferralClosure properties**: Does deferralClosure have special closure properties that prevent F-self-generation? If F(phi) ∉ deferralClosure for phi ∈ deferralClosure, the strict defect analysis simplifies.

3. **Quasimodel-to-Int bridge**: The quasimodel chain infrastructure exists (sorry-free) but the embedding into Int-indexed BFMCS is the known gap (Dead End #25 in ROAD_MAP.md). What specific technical obstacles remain?

4. **BX unfolding axiom**: Does BX include a full Until-unfolding axiom (phi U psi ↔ psi ∨ (phi ∧ F(phi U psi)))? If so, this might provide the backward step transfer for restricted_buc.

### Recommendations

**Path 1: Strict Defect Counting with Controlled Lindenbaum (NEW)**
- Confidence: 45%
- LOC: ~100-150
- Risk: Lindenbaum dropoff may be uncontrollable
- Key question: Can we modify the Lindenbaum extension to preserve formulas in sigma_list? If so, strict defects strictly decrease (no new strict defects from dropoff)
- Investigation needed: Read `set_lindenbaum` definition and check if it can be parameterized to keep sigma_list formulas

**Path 2: Quasimodel Bridge (literature-aligned)**
- Confidence: 55%
- LOC: ~400-600
- Risk: Known gap at BXPoint-to-Int bridge
- Key question: Can QuasimodelChain's periodic structure be embedded into Int-indexed BFMCS?
- This is the approach the literature actually uses (finite Hintikka sets)

**Path 3: Modified Chain with Two-Step Architecture (NEW)**
- Confidence: 35%
- LOC: ~200-300
- Idea: At each chain step, first use preserving_fwd_step (preserves all F), then check if the CURRENT step's scheduled target was resolved; if not, REPLACE with self_resolving_fwd_step for that target
- Problem: The replacement step loses other F-obligations
- Potential fix: Prove that over |sigma_list| steps, each target is resolved at least once by the preserving step ANYWAY (this reduces to the original problem)

## Dead Ends Confirmed (Cumulative)

- All 21+ approaches from Report 17: CONFIRMED DEAD
- Enriched resolving seed {target} ∪ g_content ∪ f_carry: **DEFINITIVELY DEAD** (concrete counterexample, not just G-lift failure)
- Backward step transfer phi ∧ F(phi U psi) → phi U psi: SEMANTICALLY INVALID
- Defect-count induction on F-defects: IMPOSSIBLE (count never decreases)
- Per-formula witness chain: BLOCKED (restricted_tc witness must be in actual dd_chain)
- self_resolving_fwd_step as drop-in replacement: BLOCKED (loses F-persistence for non-targets)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Discovery |
|----------|-------|--------|------------|---------------|
| A | Primary / Literature | completed | high (85%) | self_resolving_fwd_step identified but has F-persistence gap |
| B | Alternatives | completed | high (90%) | Enriched seed definitively inconsistent; FMP bypass explored |
| C | Critic | completed | medium-high (80%) | Strict defect counting novel but has dropoff issue; backward case structurally different |
| D | Horizons | completed | high (85%) | Literature avoids problem entirely; quasimodel bridge recommended |

## References

- Teammate A: `specs/093_complete_bxcanonical_embedding/reports/43_teammate-a-findings.md`
- Teammate B: `specs/093_complete_bxcanonical_embedding/reports/43_teammate-b-findings.md`
- Teammate C: `specs/093_complete_bxcanonical_embedding/reports/43_teammate-c-findings.md`
- Teammate D: `specs/093_complete_bxcanonical_embedding/reports/43_teammate-d-findings.md`
- Wolper, P. (1985). The Tableau Method for Temporal Logic.
- Burgess, J.P. (1982). Axioms for Tense Logic.
- Gabbay, Hodkinson, Reynolds (1994). Temporal Logic: Mathematical Foundations.
- Lichtenstein, O. and Pnueli, A. (2000). Propositional Temporal Logics.
- Goldblatt, R. (1992). Logics of Time and Computation.
