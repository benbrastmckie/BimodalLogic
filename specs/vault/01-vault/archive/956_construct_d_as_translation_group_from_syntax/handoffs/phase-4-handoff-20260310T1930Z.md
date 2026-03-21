# Handoff: Task 956 Phase 4 Continuation - Staged Execution Iteration Functions

## Immediate Next Action

Continue Phase 4: implement the full even/odd stage iteration functions and the recursive `staged_timeline` construction in `StagedExecution.lean`. The linearity infrastructure is complete; what remains is the construction logic itself.

## Current State

- **Plan**: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-014.md`
- **Phases 0-3**: All COMPLETED, zero sorries, zero axioms
- **Phase 4**: PARTIAL - linearity infrastructure complete, iteration functions pending
- **Build**: `lake build` passes (758 jobs)
- **Branch**: `claude/modal-logic-group-structure-5aQsV`

### File Created This Session

| File | Purpose |
|------|---------|
| `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` | Linearity infrastructure and stage building blocks |

### Key Lemmas Available

**Linearity (NEW - proven this session)**:
- `mcs_F_linearity` / `mcs_P_linearity` - F/P linearity from temp_linearity axiom
- `canonical_F_of_mem_successor` / `canonical_P_of_mem_predecessor` - F/P introduction
- `canonical_forward_reachable_linear` - two forward-reachable MCSs are comparable
- `canonical_backward_reachable_linear` - two backward-reachable MCSs are comparable
- `comparability_step_forward` / `comparability_step_backward` - inductive steps
- `stagedPoint_le_of_mcs_comparable` - MCS-to-StagedPoint ordering bridge

**Construction building blocks (NEW)**:
- `rootPoint` / `stage0` - initial stage
- `processForwardObligation` / `processBackwardObligation` - single obligation processing
- `forwardWitness_comparable_with` / `backwardWitness_comparable_with` - witness comparability
- `forward_witness_comparable_with_root` / `backward_witness_comparable_with_root` - root propagation
- `density_intermediate_exists` - density axiom wrapper

**From prior phases**:
- `executeForwardStep` / `executeBackwardStep` - MCS witness creation
- `density_intermediate` - density axiom gives intermediate with F-obligation preserved
- `mcs_has_strict_future` / `mcs_has_strict_past` - seriality witnesses

### What Remains in Phase 4

1. **Even stage function**: For each point p in the current Finset and each formula phi (from enumeration), if F(phi) in p.mcs, add a forward witness; if P(phi), add backward witness. The comparability lemmas prove each new witness is comparable with all existing points.

2. **Odd stage function**: For each successive pair of points in the current Finset, insert a density intermediate using `density_intermediate_exists`.

3. **Recursive construction**: `stagedBuild : Nat -> Finset StagedPoint` defined by recursion, alternating even/odd stages.

4. **Monotonicity**: Each stage's Finset is a superset of the previous (new witnesses are added, never removed).

5. **Wrap as StagedTimeline**: Construct a `StagedTimeline` from `stagedBuild` by providing root, monotonicity, and linearity proofs.

### Design Challenge

The main remaining challenge is Finset iteration. Processing obligations requires iterating over all (point, formula) pairs in the current Finset. Lean's `Finset.fold` or explicit recursion over `Finset.toList` would work. The linearity invariant must be maintained across all additions.

**Suggested approach**: Define `processAllObligations` that takes a `Finset StagedPoint` and a formula phi, and returns a new `Finset StagedPoint` with all F/P witnesses for phi added. Prove linearity is preserved by showing each new witness is comparable with all existing points (using `forwardWitness_comparable_with`).

## Key Decisions Made

1. **Replicated linearity proofs**: Instead of importing `BidirectionalReachable.lean` from Boneyard (which pulls in `Completeness.lean`), we replicated the key linearity proofs. This avoids circular dependencies and keeps the module self-contained.

2. **Gamma enrichment trick**: The forward/backward linearity proofs use an enriched compound formula with gamma/neg-gamma to make Case 1 of the linearity trichotomy self-contradictory. This is essential for irreflexive semantics where G(alpha) and neg-alpha can coexist.

3. **Import Completeness.lean**: We import it for `set_mcs_conjunction_intro`, `set_mcs_conjunction_elim`, `set_mcs_disjunction_elim`. These MCS closure properties are fundamental.

## What NOT to Try

- Do NOT import DovetailingChain.lean (has pre-existing build errors from `temp_t_future`/`temp_t_past`)
- Do NOT try to prove individual step strictness (same blocker as ConstructiveQuotient)
- Do NOT fall back to Path D
- Do NOT import BidirectionalReachable.lean from Boneyard (heavy dependency chain)

## Critical Context

1. `formulaEncodableStaged : Encodable Formula` is defined locally (same as DovetailingChain's but avoids import)
2. The linearity proofs are the most complex part and ARE complete
3. The remaining iteration functions are mostly definitional (less proof burden)
4. Countability of the staged timeline will follow from omega-indexed stages with finite additions per stage (Phase 5)
5. All new points are comparable with the root (proven via `forward_witness_comparable_with_root` / `backward_witness_comparable_with_root`)

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-014.md` (Phase 4 section)
- Summary: `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-20260310d.md`
- StagedExecution.lean: `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
