# Implementation Plan: Dense Completeness via Density Argument (v11)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [PLANNED]
- **Effort**: 8 hours (4 phases remaining)
- **Dependencies**: None
- **Research Inputs**:
  - reports/17_blocker-resolution.md (density argument analysis)
  - reports/16_dovetailing-analysis.md (dovetailing deep-dive)
- **Artifacts**: plans/11_density-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v011 (2026-03-17)**: **DENSITY ARGUMENT RESOLUTION**

Phase 4 was blocked by coverage gap: when point p enters at step s with `pair(p.point_index, k) < s`, the obligation was processed before p existed.

**Resolution**: Use density argument with F^i(neg bot) formulas. Encodings grow unboundedly, so for large enough i, `pair(p.point_index, k_i) > s`, ensuring p exists when processed.

From reports/17_blocker-resolution.md: mathematically sound, requires 4 lemmas.

**Changes from v10**:
- Phases 1-3: [COMPLETED] (no changes)
- Phase 4: Restructured with density argument approach
- Phase 5-6: Adjusted to build on new Phase 4 foundation

## Current Progress

| Phase | Status | Description |
|-------|--------|-------------|
| 1: Dovetailing Infrastructure | [COMPLETED] | Dovetailing.lean - Cantor pairing, ProcessObligation |
| 2: Dovetailed Staged Build | [COMPLETED] | DovetailedBuild.lean - DovetailedPoint, monotonicity |
| 3: Timeline Properties | [COMPLETED] | Countability, linearity, point index invariants |
| 4: Coverage via Density | [NOT STARTED] | NEW: density argument approach |
| 5: Main Theorems | [NOT STARTED] | has_future, has_past completion |
| 6: Dense Completeness | [NOT STARTED] | Final theorem assembly |

## Implementation Phases

### Phase 4: Coverage via Density Argument [NOT STARTED]

**Goal**: Prove the 4 key lemmas for density-based coverage

**Insight**: While `pair(L, k)` may be < s for a specific encoding k, we can use a semantically equivalent F-formula with larger encoding via density iteration.

#### Task 4.1: Pair Lower Bound

```lean
/-- Nat.pair is at least the sum of its arguments -/
theorem pair_ge_add (a b : Nat) : a + b ≤ Nat.pair a b
```

**Approach**: This may already exist in Mathlib as `Nat.add_le_pair`. If not, prove from triangular definition.

**Effort**: 15 minutes

#### Task 4.2: Encoding Growth

```lean
/-- For any bound N, there exists a formula with encoding > N that is F(...) -/
theorem encoding_growth_exists (N : Nat) :
    ∃ phi k, decodeFormulaStaged k = some phi ∧
             k > N ∧
             ∃ psi, phi = Formula.some_future psi
```

**Approach**:
- Use `iterate Formula.some_future i (Formula.neg Formula.bot)` for large i
- Encodings grow because formulas are structurally distinct
- May need helper lemma about encodeFormulaStaged monotonicity

**Effort**: 1 hour

#### Task 4.3: Density Iteration

```lean
/-- F(phi) in M implies F^n(phi) in M for all n -/
theorem density_iterate_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) (n : Nat) :
    iterate Formula.some_future n (Formula.some_future phi) ∈ M
```

**Approach**: Induction on n using `SetMaximalConsistent.density_F_to_FF`.

**Effort**: 30 minutes

#### Task 4.4: Large-Step Coverage

```lean
/-- When encoding is large enough, witness is added after point enters -/
theorem witness_at_large_step
    (p : DovetailedPoint) (n : Nat) (hp : p ∈ dovetailedBuild root_mcs root_mcs_proof n)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    ∃ w ∈ dovetailedBuild root_mcs root_mcs_proof (Nat.pair p.point_index k),
      CanonicalR p.mcs w.mcs ∧ phi ∈ w.mcs
```

**Approach**:
1. At step `pair(p.point_index, k)`, p is in build (monotonicity)
2. By point index invariant, lookup returns p
3. processForwardObligationDovetailed adds witness

**Effort**: 2 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverage.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverage` passes
- All 4 lemmas proven without sorry

**Total Phase 4 Effort**: 4 hours

---

### Phase 5: Main Theorems (has_future, has_past) [NOT STARTED]

**Goal**: Complete the sorry theorems using Phase 4 lemmas

#### Task 5.1: dovetailedTimeline_has_future

```lean
theorem dovetailedTimeline_has_future
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : DovetailedPoint, q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR p.mcs q.mcs
```

**Proof Structure**:
1. p is in build at some step n (from hp)
2. F(neg bot) in p.mcs (forward seriality)
3. By encoding_growth_exists, find k with k > n - p.point_index
4. Let phi be F^{k-1}(neg bot), so F(phi) = F^k(neg bot) is in p.mcs
5. By density_iterate_in_mcs, F(phi) is in p.mcs
6. pair(p.point_index, encoding(phi)) >= p.point_index + encoding(phi) > n
7. Apply witness_at_large_step
8. Witness is in timeline union

**Effort**: 1.5 hours

#### Task 5.2: dovetailedTimeline_has_past

Symmetric to has_future using P and backward seriality.

**Effort**: 1 hour

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` - MODIFY (complete sorries)

**Verification**:
- grep for `sorry` in DovetailedBuild.lean returns empty

**Total Phase 5 Effort**: 2.5 hours

---

### Phase 6: Dense Completeness Theorem [NOT STARTED]

**Goal**: Wire everything together for the final theorem

**Tasks**:
- [ ] Define DovetailedTimelineQuot (quotient by MCS equality)
- [ ] Prove DovetailedTimelineQuot is DenselyOrdered, LinearOrder, AddCommGroup
- [ ] Build dovetailedTimelineQuotFMCS with forward_F and backward_P
- [ ] Build singleton BFMCS with temporal coherence
- [ ] Apply ParametricTruthLemma
- [ ] Prove dense_completeness_theorem

**Effort**: 1.5 hours (much infrastructure already exists from v10 partial work)

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCompleteness.lean` - CREATE or MODIFY

**Verification**:
- `lake build` full project passes
- No new sorries or axioms

---

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Encoding growth proof complex | Medium | Low | Use structural recursion on formula depth |
| Point index invariant gap | Low | Low | Already proven in Phase 3 (getPointAt_eq_some_of_index) |
| AddCommGroup on TimelineQuot | Medium | Low | Already exists in existing infrastructure |

## Success Criteria

- [ ] All 4 Phase 4 lemmas proven without sorry
- [ ] dovetailedTimeline_has_future and has_past proven without sorry
- [ ] DovetailedTimelineQuot forms valid BFMCS
- [ ] dense_completeness_theorem proven without sorry
- [ ] `grep -rn "\bsorry\b" Dovetailed*.lean` returns empty
- [ ] `grep -n "^axiom " Dovetailed*.lean` shows no new axioms
- [ ] `lake build` passes

## Rollback/Contingency

If encoding growth lemma is problematic:
- Alternative: prove pair(L, k) > L for k > 0, then show there's always an F-formula with large encoding by Encodable properties
- Fallback: modify construction to re-process obligations (more complex)

## Mathematical Correctness Checklist

- [x] Density argument is axiomatically sound (uses density axiom F(phi) -> F(F(phi)))
- [x] Iteration property follows by induction
- [x] Cantor pairing properties from Mathlib
- [x] CanonicalR preserved through executeForwardStep (existing infrastructure)
- [ ] Encoding growth follows from formula structure (to verify)
