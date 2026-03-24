# Research Report: Task #48 — Root Cause and Solution Analysis

**Task**: 48 — prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Session**: sess_1774312603_c9d90e

## Summary

After 10 plan versions and 18 prior research artifacts, the team identified the **root cause** of why we keep going in circles and evaluated all prior approaches. The theorem IS true but requires a fundamentally different proof strategy than incremental patches.

## Root Cause (Both Teammates Agree)

**The fundamental blocker is a structural asymmetry between unrestricted MCS and DeferralRestrictedMCS.**

In unrestricted MCS, `succ_propagates_F_not` works via:
```
FF(psi) ∉ u → neg(FF(psi)) ∈ u → GG(neg(psi)) ∈ u → G(neg(psi)) ∈ v → F(psi) ∉ v
```

In DeferralRestrictedMCS, this chain breaks at step 1 when `FF(psi) ∉ deferralClosure` — local negation completeness cannot apply.

**All 5 remaining sorries (lines 3201, 3360, 4108, 4336, 4348) reduce to the same gap**: we cannot force the Lindenbaum MCS extension to prefer `G(psi.neg)` over `F(psi)` at the FF-boundary, because:
1. The Succ relation only imposes INCLUSION constraints, not EXCLUSION
2. `Classical.choose` in Lindenbaum's lemma is non-deterministic
3. MCS maximality can freely choose `F(psi)` when it's consistent with the seed

## Why Prior Approaches Failed

| Plan | Approach | Failure Root Cause |
|------|----------|-------------------|
| v1-v4 | Direct translation | Assumed local negation completeness suffices |
| v5 | Fuel recursion | Fuel invariant breaks through persistence steps |
| v6 | Bounded witness | Correct structure but sorries at FF-boundary |
| v7-v8 | Strengthen hypotheses | Succ has NO exclusion constraints — can't block F(psi) |
| v9 | boundary_resolution_set | augmented_seed_consistent blocked by derivability |
| v10 | chi-in-u restriction | augmented_seed_consistent done, but doesn't help restricted_single_step_forcing |

**Critical discovery (Teammate B)**: The **g_content propagation path** is the key unaddressed blocker. When `GF(psi) ∈ chain(k)`, `F(psi)` enters `chain(k+1)` via g_persistence — INDEPENDENT of f_content. All plans assume F(psi) only enters via f_step, which is FALSE.

## The Theorem IS True

Both teammates agree the theorem statement is correct. The semantic argument:
1. The restricted chain lives in deferralClosure, which has finite F-depth bound
2. F(psi) in chain(k) represents an F-obligation that MUST be witnessed
3. Deferral disjunctions (chi ∨ F(chi)) ensure progress toward resolution
4. Finiteness of deferralClosure bounds the number of steps

The truth is **semantic** (model-theoretic), but the proof attempts have been **syntactic** (tracking derivations).

## Recommended Solutions (Ranked)

### 1. Lindenbaum Extension (PRIMARY — Teammate B)

**Strategy**: Extend each restricted chain element to full MCS and use the existing (working) `bounded_witness`.

**Infrastructure already exists**:
- `DeferralRestrictedSerialMCS.extendToMCS` (SuccChainFMCS.lean:4613)
- `extendToMCS_is_mcs` (line 4621)
- `extendToMCS_extends` (line 4630)

**Proof outline**:
1. `chain(k) ⊆ extendToMCS(chain(k))` — already proven
2. `extendToMCS(chain(k))` is full MCS with global negation completeness
3. Show `Succ(extendToMCS(chain(k)), extendToMCS(chain(k+1)))` — need to prove
4. Apply original `bounded_witness` to get `psi ∈ extendToMCS(chain(k+d))`
5. Transfer back: `psi ∈ deferralClosure ∧ psi ∈ extendToMCS(chain(k+d)) → psi ∈ chain(k+d)`

**Gap**: Step 5 — the extension might include psi without chain(k+d) including it. Step 3 — need to show Succ lifts to extensions.

**Confidence**: MEDIUM-HIGH. Most principled approach, uses existing proven infrastructure.

### 2. Lexicographic Bounded Witness (BACKUP — Teammate B)

**Key insight**: Lexicographic termination was DISCUSSED but NEVER IMPLEMENTED.

Report 08 concluded "use single-component induction on d" — which misses the g_content path entirely.

**Correct measure**: `(g_depth, f_depth)` where:
- `g_depth` = max n such that `G^n(F(psi)) ∈ deferralClosure`
- `f_depth` = current F-iteration depth d

**Why this works**: When f_depth doesn't decrease (persistence via g_content), g_depth MUST decrease because `G^(n+1)(F(psi))` eventually exits deferralClosure. At `g_depth = 0`, `GF(psi) ∉ dc`, blocking the g_content path.

```lean
theorem restricted_bounded_witness_lex
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (k : Nat) (psi : Formula) (g_depth f_depth : Nat)
    (h_Fd : iter_F f_depth psi ∈ chain(k))
    (h_Fd1_not : iter_F (f_depth + 1) psi ∉ chain(k))
    (h_g_bound : ∀ n, n > g_depth → iter_G n (F psi) ∉ dc) :
    psi ∈ chain(k + f_depth)
```

**Confidence**: MEDIUM. Sound mathematically but requires significant restructuring.

### 3. Modified Chain Construction (ALREADY PARTIALLY DONE)

Continue the boundary_resolution_set approach from v10, but also handle the `chi.neg ∈ u` case explicitly by:
- Adding chi directly to seed when chi ∈ u (already done)
- For chi.neg ∈ u: modify successor construction to use priority resolution

**Confidence**: LOW-MEDIUM. Addresses one blocker but may uncover more.

## Conflicts Resolved

### Conflict: Best Path Forward

**Teammate A**: Recommends Option C (modify chain construction) — same as v9/v10 direction
**Teammate B**: Recommends Lindenbaum extension — fundamentally different approach

**Resolution**: Teammate B's analysis is stronger. Plans v9-v10 already explored the chain modification path and hit diminishing returns. The Lindenbaum extension approach is fundamentally different — it sidesteps the restricted negation completeness problem entirely by lifting to full MCS. However, the gap in step 5 (transfer back) needs careful analysis.

**Synthesis**: Try Lindenbaum extension FIRST. If the transfer-back property is hard, fall back to lexicographic bounded witness.

## Gaps Identified

1. **Lindenbaum Succ lifting**: Does `Succ(chain(k), chain(k+1))` imply `Succ(ext(chain(k)), ext(chain(k+1)))`? Needs verification — the extension adds formulas outside dc which might break Succ properties.

2. **Transfer-back property**: Does `psi ∈ dc ∧ psi ∈ ext(chain(k)) → psi ∈ chain(k)`? This is the DeferralRestrictedMCS property — formulas in dc are decided the same way.

3. **Lexicographic g_depth calculation**: What exactly is `iter_G n (F psi)` and how to compute the bound? Need to formalize the G-nesting depth within deferralClosure.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Root cause analysis | completed | HIGH (root cause), MEDIUM (solution) |
| B | Solution evaluation | completed | HIGH |

## Key Takeaway

**We've been trying to prove `F(psi) ∉ chain(k+1)` — but this is FALSE in general for restricted MCS.** The Succ relation allows MCS maximality to include F(psi) freely. The solution is either:
- **Lift to full MCS** where the property IS provable (Lindenbaum extension)
- **Track a richer termination measure** that accounts for g_content propagation (lexicographic)

Stop patching the restricted `succ_propagates_F_not` — it cannot be proven as stated.

## References

- Reports: 08 (lexicographic-wf), 10 (g-content-path), 15 (team-research), 16 (derivability-blocker)
- Plans: 01-10 in specs/048_prove_succ_chain_fam_bounded_f_depth/plans/
- Code: CanonicalTaskRelation.lean (working bounded_witness), SuccChainFMCS.lean (sorries)
