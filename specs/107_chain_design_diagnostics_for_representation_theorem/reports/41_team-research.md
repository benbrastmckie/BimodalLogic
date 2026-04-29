# Research Report: Task #107 — Phase 4 Blocker Analysis

**Task**: 107 - Burgess Chronicle Construction (Phase 4+ Blockers)
**Date**: 2026-04-28
**Mode**: Team Research (4 teammates)
**Session**: sess_1777425473_482124

## Summary

Team research with 4 teammates analyzed the 11 remaining sorry sites (9 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean) and the Xu 3.2.1 archival decision. The key breakthrough is that the C4 nested case — previously thought to require `untl_absorb_nested` (invalid under open guard) or a complete rewrite of the elimination strategy — can be resolved using BX6 (`absorb_until`) directly within the existing rightmost-point framework. No new axioms, no restructuring needed for this blocker.

## Key Findings

### 1. BREAKTHROUGH: C4 Nested Case Resolved via BX6 (Teammate B, confirmed by analysis)

The C4 nested case sorry sites (lines 425, 543) arise when `untl(γ, δ) ∈ f(w_next)` but `δ ∉ f(w_next)` directly. The previous analysis claimed this required `untl_absorb_nested` (invalid under open guard).

**The fix**: A direct contradiction argument using BX6 (`absorb_until`):

1. Assume γ ∈ g(w, w_next) for contradiction
2. γ ∈ f(w_next) — from the no_witness condition (all domain points between x and y have γ, since no z has neg(γ))
3. untl(γ, δ) ∈ f(w_next) — the nested hypothesis
4. γ AND untl(γ, δ) ∈ f(w_next) — conjunction in MCS
5. By burgessRSet(f(w), g(w,w_next), f(w_next)) with β = γ ∈ g and event = γ AND untl(γ, δ) ∈ f(w_next): **untl(γ, γ AND untl(γ, δ)) ∈ f(w)**
6. By BX6 (absorb_until): `untl(φ, φ ∧ untl(φ, ψ)) → untl(φ, ψ)` with φ=γ, ψ=δ: **untl(γ, δ) ∈ f(w)**
7. Contradiction with neg(untl(γ, δ)) ∈ f(w)

This proof uses only:
- `burgessRSet` from BurgessR3Maximal (sorry-free)
- BX6 `absorb_until` (valid axiom, sound under open guard)
- MCS consistency (standard)

It does NOT need `untl_absorb_nested`, BX9, or any restructuring of the elimination strategy.

**Conflict resolution**: Teammate A proposed Burgess's induction with formula substitution γ' = δ ∧ U(γ,δ), but noted that deriving neg_untl(γ',δ) ∈ f(x) requires BX2 with γ'→γ tautology, which fails because δ ∧ untl(γ,δ) does NOT imply γ without BX9. Teammate B's argument sidesteps this entirely by working within burgessR3 directly. **B's approach is correct and simpler.**

### 2. Xu 3.2.1 Archival Was Correct (All teammates agree)

All 4 teammates confirmed:
- `burgessR3Maximal_untl_mem_B` and `burgessR3Maximal_snce_mem_B` are not referenced by any downstream sorry site
- The `untl(⊥, δ)` satisfiability claim is verified correct against Truth.lean semantics (Teammate C)
- The archival to `Boneyard/XuLemma321.lean` was appropriate

Teammate C notes that strengthening the BurgessR3Maximal definition (Xu 2.0(iii) witness property) could be a future improvement but is not needed now.

### 3. c2' Sorry Sites Fall Into Two Difficulty Tiers (Teammate C)

The 7 c2' sorry sites are NOT equally hard:

**Tier 1 (easier — C5 forward/backward, lines 792, 830)**: The new point is appended beyond all existing domain. Lemma 2.4 provides seed material (`g_content(f(x_max)) ⊆ C`). Use `burgessR3Maximal_exists_from_seed` with elements from g_content as seeds.

**Tier 2 (harder — C4/C4'/g_prop/h_prop, lines 870, 908, 944, 976)**: New point inserted BETWEEN existing adjacent points. Need fresh seeds derived from existing `g(x,y)` value. The existing `burgessR3Maximal_exists_from_seed` (sorry-free, RRelation.lean:1131) can be used once appropriate seeds are identified.

**Effort estimate**: Tier 1 cases ~10-15h total, Tier 2 cases ~20-30h. The previous 100h estimate was inflated by assuming all cases required equal restructuring.

### 4. Density Self-Pair Fix (Teammate B)

The density sorry site (line 1092) requires `BurgessR3Maximal(f(x), g', f(x))` (same MCS both sides). This is structurally different from all other cases.

**Fix**: Change `eliminate_density_counterexample` to use a proper intermediate MCS D (constructed via `burgessR3Maximal_exists_from_seed` with a seed from the existing g(pc.x, pc.y)) instead of copying f(pc.x) as f(z). This avoids the self-pair requirement entirely.

### 5. Phase 5 (ChronicleToCountermodel) — Independent but Similar Depth

Lines 615, 619 require the limit chronicle's C5 + C3 properties wired through the Cantor isomorphism. These need guard information (phi at intermediate points) from the C3 three-way decomposition. Not studied in depth by any teammate but flagged as requiring the limit g-function's C3 property.

### 6. A3a/A3b Already in the System (Teammate D confirms)

Teammate D analyzed the literature and confirmed A3a (`enrichment_until`, BX13) is sound under strict semantics and IS already in the axiom system (added in Phase 2 of plan v23). Lemma 2.3 is already sorry-free using these axioms.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A: "C4 needs Burgess induction rewrite" vs B: "BX6 gives direct proof" | **B is correct**. BX6 argument works within existing framework, no restructuring needed. A's formula substitution approach fails under open guard (needs BX9). |
| C: "100h estimate" vs D: "30-60h estimate" | **Revised to ~40-50h**. C5 cases (Tier 1) are significantly easier than C4 cases (Tier 2). |

### Gaps Identified

1. **Seed construction for Tier 2 c2' cases**: Need concrete seed-finding lemmas for each elimination type. The mathematical argument exists (seeds come from existing g-values) but the Lean infrastructure doesn't yet connect the dots.
2. **Phase 5 guard propagation**: How C3 three-way decomposition at the limit provides guard information through the Cantor isomorphism needs detailed analysis.
3. **Density case restructuring**: The alternative of using intermediate MCS D instead of f(pc.x) changes the EliminationResult type — ripple effects need assessment.

### Recommendations

1. **Immediate (highest leverage)**: Add new lemma `burgessR3_gamma_not_in_B_nested` in RRelation.lean using B's BX6 argument. Close sorry sites at lines 425 and 543. Estimated: 3-5h.

2. **Next**: Close Tier 1 c2' sorry sites (C5 forward/backward, lines 792, 830) using Lemma 2.4 seed material + `burgessR3Maximal_exists_from_seed`. Estimated: 10-15h.

3. **Then**: Close Tier 2 c2' sorry sites (C4/g_prop/h_prop, lines 870, 908, 944, 976) with seed-finding lemmas from existing g-values. Estimated: 15-20h.

4. **Then**: Fix density case (line 1092) by restructuring to use intermediate MCS D. Estimated: 5-8h.

5. **Finally**: Close Phase 5 (lines 615, 619) with C3 guard propagation through the limit. Estimated: 8-12h.

**Total revised estimate**: 40-55h (down from 100h)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | High | Detailed Burgess 2.9 analysis, confirmed current code structure |
| B | Alternatives | completed | High | **BREAKTHROUGH**: BX6 proof for C4 nested case |
| C | Critic | completed | High | Tier 1/Tier 2 c2' classification, validated archival decision |
| D | Horizons | completed | High | A3a confirmation, strategic assessment, effort calibration |

## References

- Burgess 1982: "Axioms for tense logic I: Since and Until" — Lemma 2.9 (C4 elimination)
- Xu 1988: PhD thesis — Lemma 3.2.1 (B closure)
- Reynolds 1992: Completeness for Until/Since over reals — confirms A3a as primitive axiom
- BX6 (`absorb_until`): `untl(φ, φ ∧ untl(φ, ψ)) → untl(φ, ψ)` — the key axiom for the C4 fix
