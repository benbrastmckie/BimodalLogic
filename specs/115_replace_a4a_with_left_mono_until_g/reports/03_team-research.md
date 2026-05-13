# Research Report: Task 115 — Phase 2 Blocker Resolution

**Task**: 115 - Remove A4a (separation_until/separation_since) for axiom minimality
**Date**: 2026-05-13
**Session**: sess_1778699886_510714
**Mode**: Team Research (4 teammates)
**Type**: lean4

## Summary

The Phase 2 blocker — Xu Lemma 2.4 producing only `r(A, ⊤, D)` instead of the required `r(A, B, D)` — is resolved by using **Xu Lemma 3.2.1 + 3.2.2 for transitive frames** instead of Xu Lemma 2.4 for general frames. All 4 teammates converged unanimously on this solution with high confidence (9/10).

The codebase operates on transitive frames (axioms include BX5 = self_accum_until, temp_4 = FFp→Fp). Xu Section 3 provides strengthened lemmas for transitive frames:

- **Xu 3.2.1**: R(A,B,C) implies U(γ,β) ∈ B for all β ∈ B, γ ∈ C (not just U(γ,⊤) ∈ B as in Xu 2.3)
- **Xu 3.2.2**: Splitting gives `B ⊆ B' ∩ D ∩ B''` — exactly matching `lemma_2_6_splitting`'s output type

No new axioms needed. All required infrastructure (BX5, BurgessR3Maximal_extension_fails, dcs_neg_union_consistent) already exists.

## Key Findings

### 1. Xu 3.2.1 Provides the Missing Guard Strengthening (All Teammates)

Xu Lemma 3.2.1 (transitive frames) states: If R(A, B, C) then:
- (i) U(γ, β) ∈ B for all β ∈ B, γ ∈ C
- (ii) S(α, β) ∈ B for all β ∈ B, α ∈ A

**Proof** (Xu 1988, p.226-227): By contradiction. Suppose U(γ, β) ∉ B. By BurgessR3Maximal_extension_fails (2.0(iii)), ∃ β' ∈ B, γ' ∈ C with ¬U(γ', β' ∧ U(γ, β)) ∈ A. Let γ'' = γ ∧ γ', β'' = β ∧ β'. By BX5 (self_accum_until): U(γ'', β'' ∧ U(γ'', β'')) ∈ A. By BX3/BX2G monotonicity: U(γ'', β'' ∧ U(γ'', β'')) → U(γ', β' ∧ U(γ, β)) is derivable. Contradiction.

This uses only BX5 + BX2/BX3 — no BX14 (separation_until) needed.

### 2. Xu 3.2.2 Gives Exact Output Type (All Teammates)

With 3.2.1 established, the Xu 3.2.2 splitting works:

1. Extend B to B* with R(A, B*, C) (existing `burgessR3Maximal_extension_exists`)
2. β ∉ B* (else U(γ, β) ∈ A, contradicting ¬U(γ, β) ∈ A)
3. B* ∪ {¬β} consistent via `dcs_neg_union_consistent` (line 458) — **TRIVIAL, no BX14**
4. D = MCS extending B* ∪ {¬β}
5. By 3.2.1: S(α, β') ∈ B* for all β' ∈ B*, α ∈ A. Since B* ⊆ D: r(A, B*, D)
6. By 3.2.1: U(γ', β') ∈ B* for all β' ∈ B*, γ' ∈ C. Since B* ⊆ D: r(D, B*, C)
7. Zorn: R(A, B', D) with B* ⊆ B', R(D, B'', C) with B* ⊆ B''
8. Since B ⊆ B* ⊆ B', D, B'': **B ⊆ B' ∩ D ∩ B''**

Output type is **identical** to existing `lemma_2_6_splitting` — zero changes to CounterexampleElimination.lean callers.

### 3. B ⊆ B' IS Necessary (Critic, Teammate C)

The Critic confirmed `B ⊆ B'` is not a convenience but a structural necessity:
- `g_sub_g_new` in CounterexampleElimination.lean (line 599) requires g(pt,x') ⊆ g(pt,z) = B'
- This feeds into `omega_chain_g_sub_g_new` → `adj_g_mem_f_at_stage` → the limit construction
- It encodes Xu's C4'' condition: g(t,t') ⊆ g(t,t'') ∩ f(t'') ∩ g(t'',t')
- Weakening `lemma_2_6_splitting`'s output would break 6+ callers

### 4. All 4 BX14 Usage Sites Become Dead Code (Teammates A, C)

The current `separation_until_mcs` is used at lines 1629, 2280, 2480, 2697 — all within the `burgess_D0_seed_consistent` machinery. With the 3.2.2 approach:
- The rich D0 seed (`B ∪ {¬β} ∪ {U(γ,β') : γ∈C, β'∈B} ∪ {S(α,β') : α∈A, β'∈B}`) is replaced by the simple seed `B* ∪ {¬β}`
- `burgess_zeta_consistent` and the entire BX14-dependent seed consistency chain become dead code
- All 4 usage sites are eliminated simultaneously

### 5. The Handoff's 4 Resolution Paths Were All Suboptimal (Critic)

The handoff missed the correct solution (Xu 3.2.1+3.2.2) entirely:
- Option 1 (enrich seed): Brings back seed consistency problem
- Option 2 (derive r(A,B,D) ad hoc): Correct intuition but wrong mechanism
- Option 3 (weaken output): B ⊆ B' is necessary, can't weaken
- Option 4 (contrapositive): More complex than needed
- **Option 5 (Xu 3.2.1+3.2.2)**: The correct answer, not considered

### 6. All Required Infrastructure Exists (All Teammates)

| Infrastructure | Location | Purpose |
|----------------|----------|---------|
| BX5 `self_accum_until_mcs` | PointInsertion.lean:194 | Key axiom for 3.2.1 proof |
| `BurgessR3Maximal_extension_fails` | PointInsertion.lean:709 | Contradiction via 2.0(iii) |
| `dcs_neg_union_consistent` | PointInsertion.lean:458 | Trivial seed consistency |
| `burgessR3Maximal_extension_exists` | PointInsertion.lean | Get B* with R(A,B*,C) |
| `right_mono_until_mcs` (BX3) | PointInsertion.lean:1150 | Monotonicity in 3.2.1 |
| `untl_left_mono_thm` (BX2) | RRelation.lean:1073 | Monotonicity in 3.2.1 |
| `burgessR_implies_burgessRSince` | PointInsertion.lean | Lemma 2.1 equivalence |

## Synthesis

### Conflicts Resolved

**Zero conflicts.** All 4 teammates independently converged on the same solution: Xu 3.2.1 + 3.2.2 for transitive frames.

### Gaps Identified

1. **`lemma_2_7` and `lemma_2_8` seeds**: The Critic noted these may also use BX14-dependent seed constructions. The 3.2.1 approach should simplify their seeds too, but this needs verification during implementation.

2. **Xu Section 3 also modifies Lemma 2.7**: Xu's transitive frame construction uses extended ordering (b\*, c\*, d\*) when inserting points. The codebase's `lemma_2_7` may need similar updates.

3. **`ClosedUnderDerivation` vs `DCS`**: The codebase uses `ClosedUnderDerivation` rather than Xu's DCS. The existing `xu_lemma_2_3_*` proofs show this works, but it's a minor formalization risk.

### Recommendations

1. **Revise plan v2 Phase 1**: Add Xu 3.2.1 as a strengthening of the existing Xu 2.3 theorems. The proof pattern is identical (contradiction via maximality) but uses BX5 instead of BX4+BX12.

2. **Revise plan v2 Phase 2**: Replace `xu_lemma_2_4_splitting` with `xu_lemma_3_2_2_splitting`. The seed simplifies from the rich D0 to just `B* ∪ {¬β}`. The output type stays identical.

3. **Plan v2 Phases 3-4** (remove constructors, cleanup): Unchanged.

4. **Estimated effort**: ~8-10 hours total. 3.2.1 proof is ~2-3h (similar to existing xu_lemma_2_3). 3.2.2 integration is ~3-4h (rewrite splitting internals). Phases 3-4 unchanged at ~2.5h.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach | completed | high (90%) | Detailed 3.2.1 proof sketch + codebase infrastructure mapping |
| B | Literature survey | completed | high (90%) | Comprehensive survey of 9 sources, confirmed 3.2.2 is the only solution |
| C | Critic | completed | high | Confirmed B⊆B' is necessary, showed all handoff options are suboptimal |
| D | Strategic horizons | completed | high (90%) | Roadmap alignment, confirmed no architectural changes needed |

## References

- Xu, Ming (1988). "On some U,S-tense logics." *Journal of Philosophical Logic* 17: 181-202. **Lemmas 3.2.1 and 3.2.2** (transitive frame specialization).
- Burgess, John P. (1982). "Axioms for Tense Logic I: Since and Until." Lemma 2.6 (seed consistency using A4a).
- Burgess, John P. (1984). "Basic Tense Logic." Handbook chapter (F/P chronicle, not directly relevant).
- Venema, Yde (1993). "Since and Until." Completeness via completeness (different method, not applicable).
- Blackburn, de Rijke, Venema (2002). *Modal Logic*, Section 7.2. Model-theoretic transfer approach.
- Reynolds, Mark (1992). "Axiomatization of U and S over the reals without IRR." Takes Burgess as black box.
- Research report: specs/115_.../reports/01_a4a-vs-left-mono.md
- Handoff: specs/115_.../handoffs/01_phase1-complete-phase2-blocked.md
