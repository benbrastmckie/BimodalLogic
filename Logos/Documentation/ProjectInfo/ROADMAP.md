# Logos Development Roadmap

Development roadmap for Logos second-order hyperintensional logic.

## Vision

Logos aims to be a comprehensive second-order hyperintensional logic supporting:
- Modal and temporal reasoning (via Bimodal foundation)
- Epistemic operators (knowledge, belief)
- Normative operators (obligation, permission)
- Explanatory operators (grounding, explanation)
- State-based semantics for hyperintensional contexts

## Development Phases

### Phase 1: Bimodal Foundation ✅ COMPLETE

**Status**: Complete (current state)

**Deliverables**:
- [x] Core TM logic via Bimodal re-export
- [x] Namespace structure for extensions
- [x] Stub modules documenting planned architecture
- [x] Theory-specific documentation

**What's Available**:
- Complete propositional intensional logic
- Modal operators □, ◇
- Temporal operators △, ▽
- Soundness theorem
- Task frame semantics

### Phase 2: First-Order Extension

**Status**: Not Started

**Estimated Effort**: 40-60 hours

**Deliverables**:
- [ ] Individual variables and terms
- [ ] First-order quantifiers (∀, ∃)
- [ ] Predicate symbols
- [ ] First-order Kripke semantics
- [ ] Extended proof system

**Dependencies**:
- None (can proceed independently)

### Phase 3: Second-Order Extension

**Status**: Not Started

**Estimated Effort**: 60-80 hours

**Deliverables**:
- [ ] Predicate variables
- [ ] Second-order quantifiers
- [ ] Higher-order model theory
- [ ] Comprehension axioms

**Dependencies**:
- Phase 2 (First-Order Extension)

### Phase 4: Epistemic Extension

**Status**: Not Started (stub exists)

**Estimated Effort**: 30-40 hours

**Deliverables**:
- [ ] Knowledge operator K with S5 axioms
- [ ] Belief operator B with KD45 axioms
- [ ] Multi-agent extensions
- [ ] Common and distributed knowledge

**Dependencies**:
- Phase 2 (for quantified epistemic logic)
- Can begin basic propositional epistemic logic independently

### Phase 5: Normative Extension

**Status**: Not Started (stub exists)

**Estimated Effort**: 30-40 hours

**Deliverables**:
- [ ] Obligation operator O
- [ ] Permission operator P
- [ ] Standard deontic logic (SDL)
- [ ] Dyadic deontic logic

**Dependencies**:
- Phase 2 (for quantified deontic logic)
- Can begin basic propositional deontic logic independently

### Phase 6: Explanatory Extension

**Status**: Not Started (stub exists)

**Estimated Effort**: 50-70 hours

**Deliverables**:
- [ ] Grounding relation <
- [ ] State-based hyperintensional semantics
- [ ] Explanation operator
- [ ] Fine-grained content individuation

**Dependencies**:
- Phase 3 (for second-order grounding)
- State-based semantics requires significant new infrastructure

### Phase 7: Integration

**Status**: Not Started

**Estimated Effort**: 40-60 hours

**Deliverables**:
- [ ] Cross-extension interactions
- [ ] Unified semantics
- [ ] Combined proof system
- [ ] Comprehensive test suite

**Dependencies**:
- All previous phases

## Priority Order

Based on research value and implementation complexity:

1. **High Priority**: Phase 4 (Epistemic) - Most common use case
2. **Medium Priority**: Phase 5 (Normative) - Standard deontic logic
3. **Medium Priority**: Phase 2-3 (First/Second-Order) - Foundation for quantified extensions
4. **Lower Priority**: Phase 6 (Explanatory) - Requires most new infrastructure

## Milestones

| Milestone | Description | Target |
|-----------|-------------|--------|
| M1 | Basic epistemic logic (propositional) | TBD |
| M2 | First-order quantification | TBD |
| M3 | Full epistemic logic | TBD |
| M4 | Basic deontic logic | TBD |
| M5 | Second-order quantification | TBD |
| M6 | Grounding logic | TBD |
| M7 | Full integration | TBD |

## Current Focus

The project is currently focused on:
1. Bimodal completeness proofs (on hold, Task 360)
2. Bimodal polish and documentation (Task 360, 372)
3. Bimodal automation improvements

Logos extension work will begin after Bimodal is polished.

## Contributing

To contribute to Logos development:
1. Review [Extension Stubs](../Reference/EXTENSION_STUBS.md) for planned architecture
2. See [Theory Comparison](../../../Documentation/Research/THEORY_COMPARISON.md) for theory details
3. Follow [Contributing Guidelines](../../../Documentation/Development/CONTRIBUTING.md)

## See Also

- [Implementation Status](IMPLEMENTATION_STATUS.md) - Current status
- [Extension Stubs](../Reference/EXTENSION_STUBS.md) - Planned modules
- [Theory Comparison](../../../Documentation/Research/THEORY_COMPARISON.md)
