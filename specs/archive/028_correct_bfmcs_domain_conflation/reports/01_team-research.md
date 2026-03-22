# Research Report: Task #28

**Task**: Correct W=D conflation in BFMCS domain architecture
**Date**: 2026-03-21
**Mode**: Team Research (2 teammates)
**Session**: sess_1774124591_5f0ef6

## Summary

The W=D conflation in BFMCS domain architecture is confirmed across 4 sites in the codebase. The mathematical root cause is clear: `CanonicalMCS` (the world state type W) has neither `DenselyOrdered` nor `SuccOrder` instances, making it unsuitable as the duration type D for either dense or discrete completeness. The `DenselyOrdered`/`SuccOrder` incompatibility (proven via Mathlib's `denselyOrdered_iff_forall_not_covBy` vs `Order.covBy_succ`) means the two completeness variants require fundamentally different D types: `TimelineQuot ≃o ℚ` for dense, `ℤ` for discrete. Reports 17-20 in specs/006 prescribe the architecturally correct fix. Task 22 report 03's "use CanonicalMCS domain" is correct for the BFMCS modal domain (W) but wrong if interpreted as setting D = CanonicalMCS in the completion theorem.

## Key Findings

### Primary Approach: Code Audit (from Teammate A)

**4 conflation sites identified**:

| File | Type | Domain Used | Correct Domain | Status |
|------|------|-------------|----------------|--------|
| `Bundle/DirectMultiFamilyBFMCS.lean` | Discrete BFMCS | `BFMCS Int` (correct D) but modal coverage at `CanonicalMCS` level | `BFMCS Int` with Succ-chain families | 4 sorries (t≠0 modal coherence) |
| `Algebraic/MultiFamilyBFMCS.lean` | Dead-end | `BFMCS CanonicalMCS` (W=D conflation) | N/A (dead end) | 2 sorries (modal_backward impossible) |
| `StagedConstruction/TimelineQuotBFMCS.lean` | Dense proto | `BFMCS CanonicalMCS` for modal + `TimelineQuot` separately | `BFMCS TimelineQuot` (unified) | Incomplete wiring |
| `Algebraic/CanonicalEmbedding.lean` | Dense attempt | `BFMCS Rat` (correct D) | Same | 2 sorries (F/P witnesses under Cantor transfer) |

**Root cause of sorries**: `DirectMultiFamilyBFMCS` uses `intFMCS_basic` which builds arbitrary Lindenbaum chains indexed by Int. At t≠0, different chains rooted at different CanonicalMCS members produce unrelated MCS values — no structural reason for cross-family modal coherence. The fix is Succ-chains where F-step condition forces obligations to propagate deterministically.

**`MultiFamilyBFMCS.lean` dead end**: `BFMCS CanonicalMCS` means `fam.mcs t = t.world`, so `modal_backward` requires `φ ∈ t.world → Box φ ∈ t.world`, which is false in Kripke semantics (counterexample: `{Diamond(p), ¬p}` is consistent).

### Mathematical Foundations (from Teammate B)

**The W/D distinction**:
- **W** (WorldState = CanonicalMCS) carries *what is true* — syntactic MCS objects, no temporal structure
- **D** (duration type) carries *when it is true* — ordered abelian group element determining temporal density/discreteness

**DenselyOrdered requirement for dense completeness**:
- Mathlib's `exists_between` establishes `DenselyOrdered` as exactly the frame condition for DN axiom
- `CanonicalMCS` has no `DenselyOrdered` instance — density lives on `TimelineQuot` (the quotient type), established via density frame condition
- Cantor's theorem (`Order.iso_of_countable_dense`) establishes `TimelineQuot ≃o ℚ` as canonical dense D

**SuccOrder requirement for discrete completeness**:
- Mathlib's `Order.covBy_succ` gives `a ⋖ succ a` for SuccOrder
- `denselyOrdered_iff_forall_not_covBy` says DenselyOrdered means no coverings exist
- These are **mutually exclusive** — no type can have both
- `Int.instSuccOrder` makes `ℤ` the canonical discrete D

**Cross-family modal coherence when D ≠ CanonicalMCS**:
- When `D = CanonicalMCS`, all families map `t` to `t.world` — modal coherence via T-axiom is trivial
- When `D = Int`, families map to `intChainMCS` which differ between families — cross-MCS transfer of `Box φ` is provably impossible for arbitrary unrelated MCSes
- **Correct separation**: BFMCS families indexed by `CanonicalMCS` (modal domain W), final TaskFrame instantiated with correct temporal D

### Prescribed Architecture (from specs/006 reports 17-20)

| Completeness | D Type | Construction | Key Mechanism |
|-------------|--------|-------------|---------------|
| Base | Any (e.g., `ℤ`) | Duration-coarse `parametric_canonical_task_rel` | Sign-only semantics |
| Dense | `TimelineQuot` (≃o `ℚ`) | `DenseTask(u, q, v) := e(tᵥ) - e(tᵤ) = q` | Cantor isomorphism pipeline |
| Discrete | `ℤ` | `CanonicalTask(u, n, v)` via Succ-chain induction | Bypasses covering lemma entirely |

**Discrete pipeline** (reports 17, 20):
```
MCSes → f_content/p_content → Succ relation → CanonicalTask (inductive on ℤ)
      → TaskFrame ℤ → BFMCS construction → Truth lemma → Discrete completeness
```

**Dense pipeline** (reports 18-19):
```
MCSes → TimelineQuot (from DensityFrameCondition) → ≃o ℚ (Cantor)
      → DenseTask → TaskFrame ℚ → BFMCS construction → Truth lemma → Dense completeness
```

## Synthesis

### Conflicts Resolved

**No major conflicts** between teammates. One nuanced agreement reached:

1. **Task 22 report 03 interpretation**: Both teammates agree the recommendation is "partially correct" — using CanonicalMCS as the BFMCS family index (modal domain W) is sound and makes modal coherence trivial via T-axiom. The error is interpreting this as "set D = CanonicalMCS in the completion theorem." The correct reading: BFMCS families indexed by CanonicalMCS (W), final TaskFrame instantiated with D = ℤ (discrete) or D = TimelineQuot (dense).

### Gaps Identified

1. **Implementation complexity for dense case**: The `forward_F`/`backward_P` witnesses for `FMCS TimelineQuot` via Cantor transfer (in `CanonicalEmbedding.lean`) have unresolved sorries. Teammate A rates confidence "low" on implementation difficulty. The specific Lean proof steps for temporal coherence transfer through order isomorphisms are unclear.

2. **New files needed for discrete case**: `SuccRelation.lean` and `CanonicalTask.lean` do not yet exist. The Succ-based bypass is well-specified (report 20) but has no implementation started.

3. **Task 22 report update**: The task description includes "(5) update task 22 report with corrected analysis" — neither teammate addressed how to revise task 22's report to clarify the W vs D distinction.

### Recommendations

1. **For dense completeness**: Two viable paths:
   - **Path A**: Unify `TimelineQuotBFMCS` to use `D = TimelineQuot` throughout (currently uses dual-domain separation)
   - **Path B**: Complete `CanonicalEmbedding.lean` F/P witness proofs for `D = Rat`
   - Path A is architecturally cleaner; Path B is closer to completion but has harder sorries

2. **For discrete completeness**: Implement Succ-based bypass (reports 17/20):
   - Define `f_content`, `p_content` in `TemporalContent.lean`
   - Define `Succ(u,v)` relation (G-persistence + F-step) in new `SuccRelation.lean`
   - Define `CanonicalTask(u,n,v)` inductively from Succ in new `CanonicalTask.lean`
   - Build FMCS Int families using Succ-chains (not arbitrary Lindenbaum chains)
   - This bypasses `discrete_Icc_finite_axiom` entirely

3. **For task 22 correction**: Add clarifying note to task 22 report 03 distinguishing "use CanonicalMCS as BFMCS modal domain W" (correct) from "use CanonicalMCS as temporal D" (incorrect for non-base logics).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (lean-research) | Code audit, implementation approaches | completed | High (diagnosis), Medium (fix complexity) |
| B (math-research) | Mathematical foundations, alternative patterns | completed | High (all findings) |

## References

### Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` — 4 sorries from W=D conflation
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` — Dead-end W=D construction
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` — Correct dual-domain proto
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` — D=Rat approach with F/P sorries
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` — Documents domain mismatch blocker
- `Theories/Bimodal/Metalogic/FMCSDef.lean` — Documents CanonicalMCS limitations
- `Theories/Bimodal/Semantics/TaskFrame.lean` — TaskFrame(D) structure definition

### Prior Research
- `specs/006_canonical_taskframe_completeness/reports/17_three-place-canonical-task-relation.md`
- `specs/006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md`
- `specs/006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md`
- `specs/006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md`

### Mathlib Theorems
- `DenselyOrdered.dense` / `exists_between` — density interpolation
- `denselyOrdered_iff_forall_not_covBy` — DenselyOrdered ↔ no coverings
- `Order.covBy_succ` — SuccOrder provides coverings (incompatible with DenselyOrdered)
- `Order.iso_of_countable_dense` — Cantor's theorem for countable dense linear orders
- `orderIsoIntOfLinearSuccPredArch` — canonical isomorphism to ℤ for SuccOrder types
- `Int.instSuccOrder` — ℤ has SuccOrder
