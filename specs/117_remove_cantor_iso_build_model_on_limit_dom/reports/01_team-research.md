# Research Report: Task #117

**Task**: Remove Cantor isomorphism and build countermodel on limit domain
**Date**: 2026-05-08
**Mode**: Team Research (4 teammates)

## Summary

The task as described — building the countermodel directly on `LimitDomSubtype` — is **not feasible** because the parametric representation theorem requires `AddCommGroup D`, which `LimitDomSubtype` cannot satisfy (not closed under addition/negation). However, the underlying goal — eliminating the sorry at CE:3570 by removing the Cantor isomorphism — is achievable via a reinterpreted approach: **keep D=Rat but extend `limit_f` directly to all rationals without the Cantor iso**, making the density case in CounterexampleElimination dead code.

The sorry is genuinely **unprovable** in the current architecture: `burgessR3Maximal_extension_exists` uses Zorn over `ClosedUnderDerivation` sets which are not guaranteed consistent. All four teammates independently confirmed this.

## Key Findings

### 1. AddCommGroup Blocker (Unanimous — All Teammates)

The full semantic infrastructure requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`:
- `TaskFrame D` (Semantics/TaskFrame.lean:93)
- `WorldHistory` (Semantics/WorldHistory.lean:69) — uses `z + Δ`, `add_sub_add_right_eq_sub`
- `truth_at` (Semantics/Truth.lean:119)
- `valid` (Semantics/Validity.lean:73)
- `ParametricCanonicalTaskFrame` (Algebraic/ParametricCanonical.lean:198)
- `ParametricRepresentation` (line 96)
- `RestrictedParametricTruthLemma` (line 37)
- `time_shift` (WorldHistory.lean:238) — uses `t - s` arithmetic
- `parametric_to_history` (ParametricHistory.lean:61)

`FMCS D` and `BFMCS D` only need `[Preorder D]` (FMCSDef.lean:77, BFMCS.lean:53), but the downstream truth lemma imposes the heavier constraints.

`LimitDomSubtype = {q : Rat // q ∈ limit_dom A h_mcs}` has `LinearOrder`, `Countable`, `NoMinOrder`, `NoMaxOrder`, `Nonempty` — all sorry-free. But it is NOT closed under addition or negation, so `AddCommGroup` is impossible.

### 2. The Sorry is Unprovable (Teammate B — High Confidence)

The sorry at CE:3570 asks for `SetConsistent (χ.g pc.x pc.y)`. The g-values are constructed via `burgessR3Maximal_extension_exists` (RRelation.lean:760-789) which uses Zorn's lemma over `ClosedUnderDerivation` sets — NOT `SetConsistent` sets. The codebase explicitly acknowledges this at ChronicleTypes.lean:356: "The resulting B may or may not be consistent; at finite stages g-values can be Set.univ (inconsistent)."

No alternative proof path exists. Threading `SetConsistent` through the Zorn construction would require a fundamentally different approach with unclear downstream effects.

### 3. The Dependency Chain: Sorry → Density → Cantor Iso (Teammates A, B)

The complete chain:
1. `cantor_iso` (ChronicleToCountermodel.lean:189-192) uses `Order.iso_of_countable_dense`, requiring `DenselyOrdered LimitDomSubtype`
2. `limitDomSubtype_denselyOrdered` (line 98-106) uses `limit_dom_dense`
3. `limit_dom_dense` (ChronicleConstruction.lean:746-778) is sorry-free itself
4. BUT the density case in `eliminate_potential_counterexample` (CE:3535-3570) inserts midpoints between adjacent pairs using `lemma_2_6_splitting`
5. The splitting needs `∃ β, β ∉ g`, obtained via `BurgessR3Maximal_bot_not_mem`
6. `BurgessR3Maximal_bot_not_mem` needs `SetConsistent (χ.g pc.x pc.y)` — the sorry

**Removing `cantor_iso` breaks this chain**: no iso → no `DenselyOrdered` needed → density case in CE becomes dead code → sorry is unreachable.

### 4. Recommended Approach: Keep D=Rat, Remove Cantor Iso (All Teammates Converge)

All teammates independently converge on the same approach:

1. **Keep `D = Rat`** — satisfies AddCommGroup requirement
2. **Remove `cantor_iso`** — no longer embed LimitDomSubtype into Rat via order isomorphism
3. **Extend `limit_f` directly to all rationals** — for q ∉ limit_dom, assign an MCS via Lindenbaum extension of g_content from enclosing domain interval
4. **Prove forward_G/backward_H for the extension** — the key implementation challenge
5. **Remove density case from CounterexampleElimination** — modify `PotentialCounterexampleKind` enum (CE:570-576) and `EliminationResult` (CE:638-640), delete density branch
6. **Remove `DenselyOrdered` instance and `cantor_iso`** from ChronicleToCountermodel.lean

### 5. Guard Condition Insight (Teammate A)

The guard condition in `restricted_forward_until_since_coherent` (TemporalCoherence.lean:535-544):
```
∀ r : D, t < r → r < s → ψ ∈ fam.mcs r
```

When `D = Rat` with direct extension: quantifies over ALL rationals between t and s. For domain points, this follows from `limit_g`. For non-domain points, the extension must be chosen so that the guard holds — specifically, for non-domain r between domain points x < y, we need `limit_g(x,y) ⊆ f(r)`.

This is naturally satisfied if the extension uses g_content: `f(r)` extends `limit_g(x,y)` via Lindenbaum, so `limit_g(x,y) ⊆ f(r)`.

### 6. Burgess 1982 Alignment (Teammate D, Confirmed by Paper)

Burgess's completeness proof (Section 2, Claim 2.11) works directly on X = ⋃ dom f_n — a countable subset of Q. He:
- Does NOT use a Cantor isomorphism
- Does NOT require density of X
- Quantifies the truth lemma over X, not over all of Q
- Handles C4a/C5a counterexamples by point insertion in X

The current formalization adds step "3.5: embed X into all of Q via Cantor" which is not in Burgess. Removing it aligns the formalization with the paper.

However, the Lean infrastructure differs from Burgess: Burgess evaluates truth directly on X, while the formalization uses a parametric representation that requires AddCommGroup D. This forces D=Rat rather than D=X, requiring the extension of limit_f to all rationals.

## Synthesis

### Conflicts Resolved

**No major conflicts** between teammates. All four independently identified the same core blocker (AddCommGroup) and converged on the same approach (keep D=Rat, remove Cantor iso). Minor differences in extension strategy (Teammate A: "nearest domain point", Teammate B: "Lindenbaum extension", Teammate D: "root MCS or any default") are implementation details to resolve during planning.

### Gaps Identified

1. **Extension coherence**: How exactly to define f(q) for q ∉ limit_dom and prove forward_G/backward_H. Lindenbaum extension of g_content from the enclosing interval is the leading candidate, but the formal proof needs to be worked out.

2. **CE refactoring scope**: The density case is interleaved with the `PotentialCounterexampleKind` enum, `EliminationResult`, `counterexample_enum`, and the main elimination loop in CounterexampleElimination.lean (3783 lines). The refactoring scope needs careful assessment.

3. **c2'/BurgessR3Maximal for adjacent pairs**: When limit_dom is not dense, adjacent pairs persist with `limit_g = Set.univ`. `BurgessR3Maximal` requires its second argument to be CUD; `Set.univ` is CUD. But if any code path requires `SetConsistent (limit_g x y)` for adjacent pairs, that would reintroduce the sorry. Need to verify no such path exists outside the density case.

4. **Shifted/rooted FMCS without Cantor iso**: The current `shifted_cantor_fmcs` uses `t - s` where s involves `cantor_zero`. Without the iso, the shifting still works (D=Rat has subtraction) but the offset calculation changes — instead of `s - cantor_zero`, we'd use `s - 0` (since `0 ∈ limit_dom` directly).

### Recommendations

1. **Reinterpret the task description**: "Build model on LimitDomSubtype" should become "Remove Cantor iso, extend limit_f to all of Rat directly, eliminate density case from CE."

2. **Prioritize task 117 before task 116**: Task 117 touches fewer files and eliminates the last critical-path sorry. Task 116 (redefine G/H/F/P) would affect ~3200 references including ChronicleToCountermodel.lean.

3. **Implementation order**:
   - Phase 1: Remove density case from CE (PotentialCounterexampleKind, EliminationResult, elimination loop)
   - Phase 2: Define direct extension of limit_f to all rationals (with coherence proofs)
   - Phase 3: Build FMCS/BFMCS directly without Cantor iso
   - Phase 4: Remove DenselyOrdered instance, cantor_iso, cantor_f, cantor_fmcs, etc.
   - Phase 5: Update dd_countermodel_chronicle and verify bx_completeness

4. **Risk mitigation**: Before starting, verify that `SetConsistent (limit_g x y)` is NOT required by any code path other than the density case.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach — type constraints, architecture | completed | high |
| B | Alternatives — sorry provability, alternative approaches | completed | high |
| C | Critic — gaps, risks, algebraic mismatch | completed | high |
| D | Horizons — Burgess alignment, publication readiness | completed | high |

## References

- Burgess 1982, "Axioms for Tense Logic I: Since and Until" — Section 2, Claim 2.11
- ChronicleToCountermodel.lean:189-192 — cantor_iso definition
- CounterexampleElimination.lean:3570 — the sorry
- ParametricCanonical.lean:198 — AddCommGroup D requirement
- RestrictedParametricTruthLemma.lean:37 — AddCommGroup D requirement
- ChronicleConstruction.lean:884-887 — limit_g definition
- RRelation.lean:760-789 — Zorn construction (ClosedUnderDerivation, not SetConsistent)
- ChronicleTypes.lean:356 — "g-values can be Set.univ (inconsistent)"
- FMCSDef.lean:77 — FMCS only needs Preorder D
- BFMCS.lean:53 — BFMCS only needs Preorder D
