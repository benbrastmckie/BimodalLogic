# Research Report: Task #48 — Blocker Analysis and Solution Viability

**Task**: 48 — prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Session**: sess_1774308893_ccb0e7

## Summary

The blocker is **real and deeper than previously understood**. The fundamental issue is not just about blocking specific propagation paths (f_content, g_content) — it's that the Succ relation only imposes *inclusion* constraints (g_content ⊆ v, f_content ⊆ v ∪ f_content(v)), not *exclusion* constraints. A Lindenbaum-extended MCS within deferralClosure can freely contain F(psi) even when no propagation path forces it. **No amount of hypothesis strengthening on the helper theorems can fix this** — the theorems are asking "F(psi) ∉ chain(k+1) for ALL successor MCS", but there exist valid successor MCS containing F(psi).

The only viable fix is **Option C: modify the chain construction** to explicitly resolve F-obligations at the boundary by adding a `boundary_resolution_set` to the seed.

## Key Findings

### 1. Blocker is Real (Both teammates agree)

The scenario where F(psi) ∈ chain(k+1) despite h_FF_not and h_GF_not is fully verified:
- When GF(psi) ∈ dc but ∉ chain(k), negation completeness gives FG(psi.neg) ∈ chain(k)
- f_step distributes G(psi.neg) into chain(k+1) ∪ f_content(chain(k+1))
- If G(psi.neg) is deferred (lands in f_content), MCS maximality can place F(psi) in chain(k+1)

### 2. The Deeper Problem: MCS Maximality (Teammate B's critical insight)

Even when ALL propagation paths are blocked (f_content, g_content, negation completeness), F(psi) can still enter chain(k+1) via **MCS maximality alone**. The Lindenbaum extension within deferralClosure chooses between F(psi) and G(psi.neg) freely — the seed does not force either choice. This makes ALL "blocking hypothesis" approaches non-viable.

### 3. Modal Duality is Semantically Correct (Teammate A)

neg(GF(psi)) and FG(psi.neg) are NOT syntactically equal (different double-negation wrapping), but ARE co-membered in any MCS via derivation closure. The existing code correctly handles this via explicit derivation, not syntactic equality.

### 4. Why Unrestricted Case Works (Teammate A)

The unrestricted `single_step_forcing` avoids ALL these problems because full negation completeness gives neg(FF(psi)) ∈ u → GG(neg(psi)) ∈ u → G(neg(psi)) ∈ g_content(u) ⊆ v, which forces G(neg(psi)) ∈ v, which blocks F(psi) ∈ v by consistency. The restricted case loses this chain when FF(psi) ∉ dc.

## Solution Analysis

### Option A: Strengthen to GF ∉ dc — NOT VIABLE

| Aspect | Assessment |
|--------|-----------|
| Blocks g_content path? | Yes |
| Blocks negation completeness path? | Yes |
| Blocks MCS maximality? | **No** |
| Handles phi = G(F(p))? | No |
| Verdict | Cannot prove the ultimate goal |

**Conflict resolved**: Teammate A rated this HIGH confidence; Teammate B rated NOT VIABLE. Teammate B's analysis is correct — even with GF(psi) ∉ dc, the Lindenbaum extension can still freely place F(psi) in chain(k+1). The Succ relation only requires g_content(u) ⊆ v and f_content(u) ⊆ v ∪ f_content(v); it does NOT require F(psi) ∉ v.

### Option B: Lexicographic bounded_witness — PARTIALLY VIABLE

| Aspect | Assessment |
|--------|-----------|
| Termination measure sound? | Yes (subformulaClosure finite) |
| Base case provable? | **No** (same MCS maximality gap) |
| Infrastructure needed | High (g_nesting_depth, Nat.lex WF) |
| Verdict | Sound termination but can't close base case without Option C |

The lexicographic measure (f_depth, g_depth) is mathematically well-founded. But at the base case (when all G-chains leave dc), we still need to show the Lindenbaum construction picks psi over F(psi) — which is exactly Option C.

### Option C: Modify Chain Construction — VIABLE (Recommended)

| Aspect | Assessment |
|--------|-----------|
| Eliminates the sorry? | Yes, directly |
| Mathematical soundness? | Yes (boundary resolution is the only coherent choice) |
| Implementation effort | Medium (3-4 hours) |
| Risk of breaking existing proofs | Medium (all seed-dependent proofs need reverification) |

**The approach**:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}

-- Add to seed:
constrained_successor_seed_restricted_v2 =
  g_content u ∪ deferralDisjunctions phi u ∪ p_step_blocking ∪ boundary_resolution_set phi u
```

**Why it works**: At the boundary (FF(chi) ∉ dc, GF(chi) ∉ u), there is no valid mechanism to further defer F(chi). Adding chi directly to the seed forces the only coherent resolution.

**Consistency proof strategy** (Teammate B):
- `old_seed ⊆ u`, so old_seed is consistent
- `old_seed` does NOT contain `neg(chi)` (none of g_content, deferralDisjunctions, p_step_blocking contain neg(chi))
- Therefore `old_seed ∪ {chi}` is consistent (adding chi cannot create inconsistency if neg(chi) is not derivable from old_seed)
- Key verification needed: confirm neg(chi) is not derivable from g_content(u) via modal axioms

**What changes downstream**:
- `restricted_single_step_forcing` becomes trivial: chi ∈ seed ⊆ chain(k+1)
- `restricted_succ_propagates_F_not` may become unnecessary
- `bounded_witness` simplifies: each boundary step directly resolves via seed
- Succ properties preserved: g_persistence unchanged, f_step still holds

## Synthesis: Conflicts and Resolution

### Conflict 1: Option A Viability

**Teammate A**: HIGH confidence, recommended as primary approach
**Teammate B**: NOT VIABLE due to MCS maximality gap

**Resolution**: Teammate B is correct. The Succ relation is a one-way constraint — it guarantees g_content(u) ⊆ v and f_content(u) ⊆ v ∪ f_content(v), but places NO exclusion on what else v can contain. Blocking all "propagation paths" does not prevent F(psi) from appearing in v via Lindenbaum maximality. This is the fundamental insight that invalidates all "strengthen hypothesis" approaches.

### No Other Conflicts

Both teammates agree:
- The blocker is real
- Modal duality is semantically valid
- The unrestricted case works via full negation completeness
- Option C is the most promising path

## Gaps Identified

1. **Consistency proof for boundary_resolution_set**: The argument that neg(chi) ∉ old_seed needs formal verification. Teammate B's analysis is plausible but not airtight — modal axioms applied to g_content(u) formulas could theoretically derive neg(chi).

2. **Impact on existing proofs**: The chain construction is used in multiple downstream theorems. All seed-dependent lemmas need reverification.

3. **GF(chi) ∈ u case not covered by boundary_resolution_set**: The set only adds chi when GF(chi) ∉ u. When GF(chi) ∈ u, F(chi) enters chain(k+1) via g_persistence legitimately. This case still needs handling in bounded_witness (but is already handled by the existing non-boundary proof).

## Recommendations

1. **Pursue Option C** (modify chain construction with boundary_resolution_set)
2. **First step**: Prove consistency of the augmented seed — this is the gating question
3. **Estimate**: 3-4 hours implementation, can be tested incrementally
4. **Fallback**: If consistency proof fails, investigate whether the consistency argument can be rescued by restricting boundary_resolution_set further

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical blocker analysis | completed | high (blocker), medium (recommendation) |
| B | Solution viability | completed | medium |

## References

- Report 10: G-content path analysis (original discovery)
- Plan v8: g-content-fix (blocked approach)
- Summary 08: Implementation attempt findings
- SuccRelation.lean: Succ definition and unrestricted proofs
- SuccChainFMCS.lean: Restricted chain construction and current sorries
