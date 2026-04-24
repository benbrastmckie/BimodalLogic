# Research Report: Task #107

**Task**: Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-23
**Mode**: Team Research (4 teammates)
**Focus**: Post-implementation review — determine remaining work, improvements, and difficulties for a mathematically correct long-term solution

## Summary

The 5-phase Burgess chronicle implementation produced 2,764 lines of new Lean code, eliminated 2 ParametricTruthLemma sorry sites, and successfully rewired `bx_completeness` to bypass the 3 blocked RootScopedChain sorry sites. However, the critical analysis reveals **three fundamental architectural gaps** that make several of the 20 new sorry sites unprovable as currently designed. These gaps must be addressed before any sorry-closing campaign can succeed.

## Critical Findings (Blocking)

### 1. Missing Burgess C4 Condition (HIGH)

The implementation defines chronicle conditions C0, C1, C2, C2', C3, C5, C5' but **omits C4 and C4'** — the backward r-relation from interval DCS to the next point. Burgess's C4 captures: if `U(γ,δ)` persists through interval `(x,y)` (via `g(x,y)`), then at endpoint `f(y)` either `δ` holds or `γ` and `U(γ,δ)` still persist. Without C4, the chronicle cannot establish that Until obligations are correctly "handed off" from intervals to points.

**Consequence**: `limit_satisfies_c5_weak` cannot be proved, and the Lemma 2.7 D2 cases require C4 to work. C4 is load-bearing for the entire construction.

**Fix**: Add `c4 : ∀ x y, Adjacent dom x y → rRelation (χ.g x y) (χ.f y)` and `c4'` (Since dual) to `ValidChronicle`.

### 2. Non-Domain Extension Violates forward_G (HIGH)

`ChronicleToCountermodel.lean` assigns the root MCS `A` to all non-domain rationals via `extended_limit_f`. This is **provably invalid**: if `G(φ) ∈ A` and `t' > t` where `t' ∉ limit_dom`, then `forward_G` requires `φ ∈ extended_limit_f(t') = A`, i.e., `G(φ) → φ` in `A`. But the T-axiom for G (`G(φ) → φ`) is NOT valid under strict semantics. The sorry at `chronicle_fmcs.forward_G` (line 192) is genuinely **unprovable**, not a proof gap.

**Fix options** (from Teammates B and C):
- (A) Use a `Set Rat`-indexed model (subtype of dom) — eliminates forward_G obligation entirely but requires showing the subtype has required ordered group instances
- (B) For non-domain `r`, define `extended_limit_f(r)` via Lindenbaum extension of `g_content` from the nearest domain point below `r` — mathematically correct but complex
- (C) Redesign the integration to avoid extending to non-domain rationals altogether, using the chronicle directly as a model over its countable dense domain

### 3. Vacuous C5 Satisfaction via Endpoint Insertion (MEDIUM-HIGH)

`eliminate_C5_counterexample` inserts the η-witness **beyond all existing domain points** (using `exists_rat_gt_finset`). This makes the guard condition `∀ z ∈ dom, x < z → z < y → ξ ∈ f(z)` vacuously true (no intermediate domain points exist between x and the new y). The inductively constructed chronicle satisfies C5 only vacuously — any formula could be "guard-preserved" trivially.

The transition from discrete domain-based C5 to continuous semantics is where this gap matters. The fix requires either:
- Inserting witnesses between existing domain points (requiring Lemma 2.7 + C4)
- Proving that the interval DCS structure bridges the gap between domain points

## Important Findings (Non-Blocking)

### 4. `until_guard_consistent` Is Likely FALSE (HIGH)

Teammate C produced a concrete counterexample: for `γ = ⊥`, `{⊥}` is trivially inconsistent (`[⊥] ⊢ ⊥`), but `⊥ U δ` can be in an MCS (since `⊥ U δ → ⊥` is NOT a BX theorem). The sorry'd statement is not just unprovable — it's **false** for `γ = ⊥`. However, it is currently not called anywhere downstream, so it is non-blocking. It should be withdrawn or reformulated.

### 5. `claim_2_11` Is Trivially Tautological (LOW)

The `claim_2_11` theorem is `φ ∈ limit_f(x) ↔ φ ∈ limit_f(x)` (trivially `Iff.rfl`). This is NOT Burgess's Claim 2.11, which states membership equals semantic truth. The real content is spread across `ChronicleToCountermodel.lean`'s BFMCS construction.

### 6. PointInsertion Sorries Not on Current Critical Path (MEDIUM)

Teammates A and C agree: the 4 PointInsertion sorries (Lemma 2.7 D2 cases, 2.8 eta-in-C, 2.6_strong) are not currently called from `CounterexampleElimination.lean` or `ChronicleConstruction.lean`. Phase 4 uses only `lemma_2_4` (sorry-free). However, once C4 is added and the vacuous C5 issue is fixed, these lemmas will become necessary for proper guard propagation.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A says PointInsertion sorries are deferrable; C says they're needed for C4 | **C is correct for the long-term architecture**: once C4 is added and C5 fixed, these become essential. They ARE deferrable for the current (vacuous) construction but will be needed. |
| D says all 20 sorries are tractable; C identifies several as unprovable | **C is more precise**: at least 2 sorries (`forward_G`, `until_guard_consistent`) are genuinely unprovable/false as stated. The construction needs architectural fixes before those sorries become closeable. |
| B suggests Set Rat-indexed model; C identifies the same problem independently | **Complementary**: B's alternative is one fix for C's finding. Both agree the current `extended_limit_f` approach is broken. |

### Gaps Identified

1. **The C4 gap is the root cause** of multiple downstream sorry sites (limit C5, Lemma 2.7 D2, and indirectly the FMCS coherence sorries). Adding C4 to ValidChronicle is the single most important fix.
2. **The non-domain extension strategy must be redesigned** before any of the 9 ChronicleToCountermodel sorries can be closed. The current approach is provably invalid.
3. **The counterexample elimination strategy needs rethinking** to avoid vacuous C5 satisfaction. The Burgess paper inserts witnesses between existing points (not beyond all of them), using the full Lemma 2.7 machinery.

### Recommendations

**Phase 1: Architectural Fixes (10-15 hours)**
1. Add C4/C4' conditions to `ValidChronicle` in `ChronicleTypes.lean`
2. Redesign `extended_limit_f` (or switch to Set Rat-indexed model)
3. Fix `eliminate_C5_counterexample` to insert witnesses between existing domain points (requires Lemma 2.7)
4. Remove or reformulate `until_guard_consistent` (it's false as stated)

**Phase 2: Close Foundational Sorries (10-15 hours)**
5. Close `exists_rat_gt/lt_finset` (trivial Mathlib: `Finset.max'` + `lt_add_one`)
6. Close `counterexample_enum` surjectivity (use `Rat.instDenumerable`)
7. Close `lemma_2_6_strong` (seed consistency via deduction theorem)
8. Close Lemma 2.7 D2 cases (now possible with C4)

**Phase 3: Close Limit and Integration Sorries (15-25 hours)**
9. Close `limit_satisfies_c5_weak/c5'_weak` (now possible with C4 + proper insertion)
10. Close all 9 ChronicleToCountermodel sorries (now possible with redesigned extension)

**Total estimate**: 35-55 hours across 3 phases, with Phase 1 (architectural fixes) being the critical prerequisite.

## Strategic Alignment (from Teammate D)

- **Task 109 should be re-scoped**: its critical-path goal (sorry-free `bx_completeness`) has been subsumed by task 107's chronicle approach. Re-scope to cleanup/archival of dead RootScopedChain infrastructure.
- **irr_until should become main** once `bx_completeness` is sorry-free — do not merge early.
- **Do NOT take the Box+G+H shortcut**: the full Until/Since chronicle result is the stated goal.
- **Task 68 synergy**: the Q-indexed chronicle could serve as the dense canonical model (explore after chronicle is sorry-free).
- **20 sorries represent progress**: they replace 3 sorries that had 36 documented failed approaches. Each new sorry has a corresponding lemma in a peer-reviewed paper.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary progress review | completed | high |
| B | Alternative approaches | completed | medium-high |
| C | Critic (correctness gaps) | completed | high |
| D | Strategic horizons | completed | high |

## References

- Burgess, J.P. (1982). "Axioms for tense logic II: Time periods." Notre Dame Journal of Formal Logic, 23(4), 375-383.
- Phase results: `specs/107_*/phases/06_phase-{1-5}-results.md`
- Implementation summary: `specs/107_*/summaries/06_implementation-summary.md`
