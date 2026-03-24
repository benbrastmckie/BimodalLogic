# Blocker Analysis: Task #36

**Parent Task**: #36 - Prove f_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
**Generated**: 2026-03-23
**Blocker**: Two sorry-containing helper lemmas (`f_nesting_is_bounded` and `p_nesting_is_bounded`) require proving that F/P-iteration sequences in an arbitrary MCS are bounded.

## Root Cause

The implementation successfully converted the axioms to theorems, but the core soundness relies on proving that for any MCS M and formula phi with F(phi) in M, there exists n >= 2 such that iter_F n phi is NOT in M.

The research report identified a fundamental limitation: **Pure MCS reasoning is insufficient**. An MCS over a dense or continuous frame COULD contain all F-iterations of phi without inconsistency. The bound comes from model-theoretic properties, not syntactic MCS structure.

The specific sorries are:
1. `f_nesting_is_bounded` (SuccChainFMCS.lean:678-722)
2. `p_nesting_is_bounded` (SuccChainFMCS.lean:899-907)

Both attempt to prove: if all iter_F/iter_P iterations were in M, derive a contradiction. But the proof sketch acknowledges this requires connecting to model-theoretic reasoning (FMP, frame properties, or canonical model construction).

## Alternative Approaches Analyzed

### Approach 1: Closure-Based Bounded MCS (Recommended First)

**Key Insight**: The formulas iter_F n phi eventually leave the subformula closure of any fixed formula. RestrictedMCS (MCS restricted to closureWithNeg) cannot contain formulas outside their closure.

**Proof Strategy**:
- For any phi, define closure_depth(phi) = max depth of F-nesting in closureWithNeg(phi)
- Show that iter_F (closure_depth(phi) + 1) phi is NOT in closureWithNeg(phi)
- For RestrictedMCS over phi, this formula must be outside the MCS

**Infrastructure Available**:
- `closureWithNeg : Formula -> Finset Formula` (finite!)
- `RestrictedMCS : Formula -> Set Formula -> Prop`
- `restricted_lindenbaum` theorem for constructing RestrictedMCS

**Limitation**: The current proof applies to ARBITRARY MCS, not RestrictedMCS. Would need to:
1. Either prove that succ_chain_fam MCS are effectively bounded (see Approach 2)
2. Or add a hypothesis that the MCS is closure-restricted

**Effort**: 3-4 hours

### Approach 2: succ_chain_fam Bounded F-Depth (Recommended Second)

**Key Insight**: The succ_chain_fam construction builds MCS at specific integer indices. The forward_chain/backward_chain construction uses `successor_exists` which places F-witnesses at the NEXT index, not deeper.

**Proof Strategy**:
- Analyze how successor_exists places the witness for F(phi)
- Show that if F(phi) in M_n, then phi is witnessed at M_{n+1}
- The F-depth in any single MCS is bounded by the "distance" in the chain

**Infrastructure Available**:
- `forward_chain`, `backward_chain` definitions
- `successor_exists` places F-witnesses at immediate successor
- `bounded_witness` already uses iter_F boundary for chain traversal

**Key Challenge**: Need to formalize that the succ_chain_fam construction specifically bounds F-depth, not just that witnesses exist at bounded distance.

**Effort**: 4-6 hours

### Approach 3: Pigeonhole on Complexity Classes (Lightweight)

**Key Insight**: iter_F produces formulas of strictly increasing complexity. In any finite set, there are finitely many complexity classes.

**Proof Strategy**:
- Show iter_F_complexity: complexity(iter_F n phi) = 5n + complexity(phi)
- All iter_F iterations are distinct (iter_F_injective exists)
- If M were a finite set (or had finite intersection with some complexity band), pigeonhole applies

**Limitation**: MCS M is infinite. Need additional constraint to make this work.

**Variation**: If M is the projection of a RestrictedMCS to a closure, the intersection is finite.

**Effort**: 2-3 hours (but may not be sufficient alone)

### Approach 4: FMP Connection (Fallback)

**Key Insight**: The Finite Model Property (FMP) ensures that if phi is satisfiable, it's satisfiable in a finite model. Finite models have bounded F-depth.

**Proof Strategy**:
- Connect succ_chain_fam to the FMP filtration construction
- Show that the canonical model restricted to closure has bounded F-depth
- Lift the bound to the full canonical model

**Infrastructure Available**:
- `Theories/Bimodal/Metalogic/Decidability/FMP/` module
- `ClosureMCS`, `FiniteModel` types
- `TruthPreservation` theorems

**Challenge**: Significant integration effort. The FMP module was built for decidability, not for the canonical model completeness proof.

**Effort**: 8-12 hours

## Proposed New Tasks

### New Task 1: Prove iter_F leaves closure for large n

- **Effort**: 2-3 hours
- **Language**: lean4
- **Rationale**: This is the simplest approach. If we can show that iter_F (depth + 1) phi is not in closureWithNeg phi for some computable depth, we immediately get boundedness for RestrictedMCS. This doesn't directly solve the arbitrary MCS case but provides a foundation.
- **Depends on**: None

### New Task 2: Prove succ_chain_fam has bounded F-depth

- **Effort**: 4-6 hours
- **Language**: lean4
- **Rationale**: The succ_chain_fam construction is the SPECIFIC context where f_nesting_boundary is used. Rather than proving boundedness for arbitrary MCS, we can prove it for this specific construction. This is more targeted and likely achievable.
- **Depends on**: New Task 1, because the closure depth bound from Task 1 can inform what "bounded" means for succ_chain_fam MCS. Specifically, if we know iter_F leaves closures at a predictable depth, we can use that to characterize the bound in the canonical model.

### New Task 3: FMP-based boundedness proof (Fallback)

- **Effort**: 6-8 hours
- **Language**: lean4
- **Rationale**: If Tasks 1 and 2 are insufficient, connect the succ_chain_fam construction to the FMP infrastructure. This provides the full model-theoretic justification but requires more integration work.
- **Depends on**: New Task 2, because we should only pursue this heavyweight approach if the targeted succ_chain_fam proof (Task 2) encounters fundamental obstacles. Task 2's partial results will inform how to structure the FMP connection.

## Dependency Reasoning

- **Task 2 depends on Task 1**: The closure depth lemma from Task 1 provides the "what is bounded" characterization needed for Task 2. Without knowing that iter_F eventually leaves any fixed closure, we cannot state what bound to prove for succ_chain_fam.

- **Task 3 depends on Task 2**: Task 3 is the fallback if Task 2's targeted approach fails. The partial results and obstacles discovered in Task 2 will inform how to structure the FMP integration. We should not pursue the heavyweight FMP approach until simpler approaches are ruled out.

- **Task 1 and Task 3 are not directly independent**: Task 3 could theoretically be done without Task 1, but Task 2 serves as a filter. If Task 2 succeeds, Task 3 is unnecessary. If Task 2 fails, Task 3 becomes necessary, and Task 1's results provide useful infrastructure.

## After Completion

Once all spawned tasks are complete, resume the parent task #36 with `/implement 36`.

The blocker will be resolved because:
1. Task 1 establishes the closure-depth foundation
2. Task 2 (or Task 3 as fallback) provides the proof that iter_F iterations must eventually leave the specific MCS used in succ_chain_fam
3. The two sorry lemmas (`f_nesting_is_bounded` and `p_nesting_is_bounded`) can then be replaced with proper proofs using this infrastructure
