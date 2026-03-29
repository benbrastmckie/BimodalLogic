# Teammate B Findings: Task Relation Approach Analysis

## Summary

The task relation does not provide a direct shortcut to the sorry. The sorry stems from a gap between **bundle-level** and **family-level** temporal coherence in the canonical model construction, not from any missing connection to the task relation. The task relation approach re-describes the same mathematical requirement (that F/P witnesses lie within the same world history/family) without providing a new proof strategy, though it does clarify the *semantic* reason the gap exists.

## Key Findings

### 1. Task Relation Definition

The task relation `task_rel w d u` in `TaskFrame.lean` encodes reachability: world state `u` is reachable from `w` by a task of duration `d` (Lines 93-122). The axioms are:
- **nullity_identity**: zero-duration task is the identity (`task_rel w 0 u ↔ w = u`)
- **forward_comp**: sequential tasks compose for non-negative durations
- **converse**: temporal symmetry (`task_rel w d u ↔ task_rel u (-d) w`)

A **world history** (`WorldHistory.lean:69`) is a function `τ: X → W` from a *convex* time domain to world states, where adjacent world states are connected by the task relation (`respects_task`). The convexity requirement ensures histories have no temporal gaps.

**Critical semantic point**: World histories encode valid execution sequences where EACH TIME STEP must be connected via the task relation. This means a world history is precisely a coherent temporal chain — an FMCS where adjacent MCSes satisfy Succ (which encodes the task relation at the canonical level).

The BFMCS structure quantifies Box over ALL world histories (families) at each time point, while F/G quantify over times within the SAME world history. This is the semantic foundation for why family-level temporal coherence is required.

### 2. BFMCS Bundle Structure

The `BFMCS` structure (`BFMCS.lean:84`) contains:
- `families`: a set of FMCS (indexed MCS families), each representing one possible world history
- `modal_forward`/`modal_backward`: Box quantifies over ALL families in the bundle
- `eval_family`: the distinguished evaluation family containing the seed MCS

The `BFMCS_Bundle` structure (`UltrafilterChain.lean:2758`) extends this with:
- `bundle_forward_F`: F(phi) in fam.mcs(t) implies phi exists in SOME fam' at some s > t
- `bundle_backward_P`: P(phi) in fam.mcs(t) implies phi exists in SOME fam' at some s < t

**Bundle construction is sorry-free** (`construct_bfmcs_bundle`, Line 2853). The `boxClassFamilies` contains all shifted SuccChainFMCS from MCSes in the same box-class as M0. For each F(phi) in any family at time t, the `temporal_theory_witness_exists` lemma guarantees a witness MCS W with phi in it, and we can build a shifted SuccChainFMCS from W at offset t+1 — placing phi at time t+1 in a family of the bundle. This is proven at lines 2643-2681 without sorry.

**Coherence the bundle lacks**: The `BFMCS.temporally_coherent` predicate (`TemporalCoherence.lean:216`) requires that for each family, F-witnesses lie in the *same* family (not just any family in the bundle). This is family-level coherence, which is what the `shifted_truth_lemma` requires.

### 3. The Inclusion Gap

**The user's proposed argument**: Show CS ⊆ some MCS ∈ some FMCS ∈ BFMCS.

This is already achieved: `construct_bfmcs_bundle` gives a BFMCS_Bundle where the seed MCS M contains neg(phi), and `eval_family.mcs 0 = M` (Line 2870). So CS = {neg(phi)} ⊆ M = eval_family.mcs(0) in a specific FMCS in the bundle.

**The actual gap preventing completeness**: The truth lemma (`ParametricTruthLemma.lean`) must be bidirectional. The backward direction for G formulas requires:

```
G(phi) ∈ fam.mcs(t) ← phi ∈ fam.mcs(s) for all s > t
```

which requires F-witnesses in the **same** family (family-level `forward_F`). The comment at UltrafilterChain.lean:2882-2905 explicitly states:

> "The forward direction of the `imp` case invokes the backward induction hypothesis for the antecedent subformula [...] This means even a 'forward-only' truth lemma for `neg(phi) = phi.imp bot` requires the backward direction for `phi`."

The current sorries:
- `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:222) — needs family-level forward_F/backward_P
- `Z_chain_forward_F` and `Z_chain_backward_P` (UltrafilterChain.lean:2424, 2490) — the OmegaFMCS chain approach
- `Z_chain_forward_G` crossing case (Line 2347) — G-theory doesn't propagate from backward chain to forward chain

The crossing-chain sorry is particularly revealing: the backward omega chain (built with P-witnesses) only preserves H-theory, not G-theory. When a formula G(phi) is in the backward chain at time t < 0, we cannot transfer it to the forward chain at time t' >= 0 because the two chains were built for different purposes.

### 4. Comparison with Plan 07 (Restricted Chain)

Plan 07 uses a restricted chain approach within `deferralClosure(phi)` for a *specific* formula phi. The sorry is in `restricted_bounded_witness_fueled` at the fuel=0 branch (SuccChainFMCS.lean:~2797+).

**Task relation approach re-description**: The user's suggestion is: the task relation constrains which FMCS families are valid world histories, and we just need to show our seed MCS is contained in some MCS of some valid world history in the BFMCS.

**Why this doesn't resolve the sorry**:

1. The sorry is NOT about showing CS ⊆ MCS ∈ FMCS ∈ BFMCS. This is already done by `construct_bfmcs_bundle` (sorry-free).

2. The sorry is about *connecting the truth lemma* to the canonical model. The truth lemma proves `phi ∈ fam.mcs(t) ↔ truth_at(fam, t, phi)`. Its backward direction for G requires same-family F-witnesses — a property that individual SuccChainFMCS families do NOT currently guarantee (the fuel exhaustion sorry), and that the OmegaFMCS also does not guarantee (the crossing-chain sorry).

3. The restricted chain approach targets the SuccChainFMCS (one concrete family). The task relation approach doesn't provide a different construction — it's the same bundle where each FMCS represents a world history. Getting family-level coherence still requires showing that within a single chain, every F-obligation is eventually resolved.

**Plan 07 approach** (fixing the fuel exhaustion sorry) and **task relation approach** are describing the same requirement from different angles. Plan 07's approach is more concrete: it works within the finite deferralClosure to prove a bounded termination argument.

**The dovetailing alternative**: The OmegaFMCS construction attempts to build a family-level temporally coherent chain through dovetailing. However, the current implementation only resolves F_top at each step (not arbitrary F-obligations), and the crossing-chain sorry shows G-theory doesn't propagate across the forward/backward chain boundary. A proper dovetailing implementation that explicitly enumerates and resolves ALL F-obligations round-robin would yield a family-level coherent chain without the fuel exhaustion problem.

## Recommended Approach

The task relation framing **clarifies what needs to be proven** but does not provide a new proof path. The two viable approaches are:

**Option 1: Fix fuel exhaustion (Plan 07 continuation)** — Prove that with fuel = B*B+1, the fuel=0 branch in `restricted_bounded_witness_fueled` is never reached. This requires a well-founded measure argument. This is mathematically correct but the termination proof is syntactically complex (Lean's termination checker requires local evidence).

**Option 2: Dovetailed OmegaFMCS** — Replace `omega_chain_forward` with a construction that explicitly resolves ALL F-obligations from M0 (not just F_top) using a pairing function enumeration. This gives a family-level coherent chain by construction. For this, each step n would:
1. Decode step as (direction, formula_index) via Nat.unpair
2. Resolve the corresponding F or P obligation from M0
3. Track which obligations have been resolved

This approach directly provides `forward_F` and `backward_P` for the OmegaFMCS at the family level, and the crossing-chain problem is avoided because the forward/backward chains are explicitly symmetric.

**Option 2 is more mathematically principled** because it achieves temporal coherence by construction rather than through a fuel-bound argument. The task relation perspective supports this: valid world histories are exactly those chains where every F/P-obligation is eventually resolved by the task relation, which is precisely what dovetailing guarantees.

## Confidence Level

**High**. The code analysis is definitive:
- Bundle-level sorry-free construction exists and is complete (`construct_bfmcs_bundle`, Lines 2853-2870)
- The gap is family-level temporal coherence for the truth lemma (documented at Lines 2882-2905)
- The task relation adds semantic clarity but not a new proof approach
- Both Option 1 (fuel exhaustion) and Option 2 (dovetailing) target the same mathematical gap

## References

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| TaskFrame definition | Semantics/TaskFrame.lean | 93-122 | Background context |
| WorldHistory definition | Semantics/WorldHistory.lean | 69-80 | World history = coherent FMCS chain |
| BFMCS structure | Metalogic/Bundle/BFMCS.lean | 84-116 | Bundle structure (sorry-free) |
| FMCS structure | Metalogic/Bundle/FMCSDef.lean | 99-119 | Family structure |
| TemporalCoherentFamily | Metalogic/Bundle/TemporalCoherence.lean | 146-153 | Family-level F/P coherence definition |
| BFMCS.temporally_coherent | Metalogic/Bundle/TemporalCoherence.lean | 216-219 | Target predicate |
| boxClassFamilies_bundle_forward_F | Metalogic/Algebraic/UltrafilterChain.lean | 2643-2681 | Sorry-free bundle coherence |
| Z_chain_forward_F sorry | Metalogic/Algebraic/UltrafilterChain.lean | 2424-2485 | OmegaFMCS sorry |
| Z_chain_forward_G crossing sorry | Metalogic/Algebraic/UltrafilterChain.lean | 2347 | G-theory crossing gap |
| construct_bfmcs_bundle | Metalogic/Algebraic/UltrafilterChain.lean | 2853-2870 | Sorry-free construction |
| bfmcs_from_mcs_temporally_coherent | FrameConditions/Completeness.lean | 220-226 | Primary sorry target |
| bundle_validity_implies_provability | FrameConditions/Completeness.lean | 250-284 | End goal |
| Completeness comment on gap | Metalogic/Algebraic/UltrafilterChain.lean | 2882-2905 | Explicit documentation of gap |
