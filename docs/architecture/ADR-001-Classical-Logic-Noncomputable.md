# ADR-001: Use Classical Logic for Metalogic (Accepting Noncomputable Definitions)

**Status**: Accepted  
**Date**: 2025-12-28  
**Deciders**: ProofChecker Development Team  
**Related**: [Task 192](../../.opencode/specs/192_fix_generalized_necessitation_termination/), [NONCOMPUTABLE_GUIDE.md](../development/NONCOMPUTABLE_GUIDE.md)

---

## Context

ProofChecker implements a Hilbert-style proof system for bimodal temporal logic (TM logic). The deduction theorem and other metalogic theorems are fundamental to the system, enabling context manipulation and proof simplification.

### Problem

Lean 4 requires definitions to be **computable** (executable) by default. However, metalogic theorems like the deduction theorem perform operations that are inherently **undecidable**:

1. **Formula Equality**: Deciding if two arbitrary formulas are equal (`φ = A`)
2. **Context Membership**: Deciding if a formula is in a context (`A ∈ Γ`)
3. **Context Equality**: Deciding if two contexts are equal (`Γ' = A :: Γ`)

These operations require **classical axioms** (like `Classical.propDecidable`) to perform case analysis, making the definitions **noncomputable** (cannot be executed or compiled to runnable code).

### Question

**Should we accept noncomputable definitions in ProofChecker's metalogic, or should we attempt to make everything computable?**

---

## Decision

**We accept noncomputable definitions for metalogic theorems.**

Specifically:
1. Use `Classical.propDecidable` for decidable instances in metalogic
2. Mark affected definitions with `noncomputable` keyword
3. Document why each definition is noncomputable
4. Follow standard practice from mathlib4 and published Lean 4 research

---

## Rationale

### Why Classical Logic is Appropriate

1. **Standard Practice in Lean Community**
   - **mathlib4**: Uses classical logic extensively for metalogic and proof theory
   - **Published Research**: Lean 4 papers on formal verification use classical reasoning for metatheory
   - **Community Consensus**: Classical logic is idiomatic for proof systems that aren't intended to be executed

2. **Architectural Fit**
   - **Hilbert-Style System**: Designed for mathematical elegance, not computational execution
   - **Proof Objects**: Derivations are mathematical objects representing proofs, not algorithms
   - **Metalogic vs. Object Logic**: Metalogic reasons *about* the proof system; it doesn't need to be constructive

3. **Practical Benefits**
   - **Simpler Proofs**: Classical case analysis (`by_cases h : A ∈ Γ`) is more direct than constructive alternatives
   - **Reduced Complexity**: Avoids requiring `DecidableEq Formula` instances
   - **Maintainability**: Aligns with Lean 4 ecosystem conventions

### Why Constructive Alternative is Impractical

To make `deduction_theorem` computable, we would need:

1. **`DecidableEq Formula`**: Decide if two formulas are syntactically equal
   - **Problem**: Formulas are recursive structures; decidability is complex to implement
   - **Problem**: Adds boilerplate to every formula constructor

2. **`DecidablePred (· ∈ Γ)`**: Decide if a formula is in a context
   - **Problem**: Requires `DecidableEq Formula` (see above)
   - **Problem**: Context membership is structurally recursive; complex implementation

3. **Constructive Proof System**: Rewrite all proofs to avoid classical axioms
   - **Problem**: Massive rewrite of entire codebase
   - **Problem**: Loss of simplicity and elegance in proofs
   - **Problem**: Deviates from standard practice in formal logic

**Verdict**: The constructive approach offers:
- ❌ Massive implementation cost
- ❌ Significant complexity increase
- ❌ Deviation from community standards
- ✅ No practical benefit (proofs aren't meant to be executed)

### Impact on ProofChecker

**Current Noncomputable Definitions**: 36 total
- `DeductionTheorem.lean`: 2 definitions
- `Propositional.lean`: 32 definitions (in `noncomputable section`)
- `GeneralizedNecessitation.lean`: 2 definitions (need fixing)

**Dependency Propagation**:
```
Classical.propDecidable
└── deduction_theorem
    ├── generalized_modal_k
    ├── generalized_temporal_k
    └── Propositional theorems (lce_imp, rce_imp, classical_merge, de, etc.)
```

**Build Impact**:
- Noncomputable definitions compile successfully with marker
- No runtime performance impact (proofs are erased at runtime)
- No user-facing impact (proofs are not executed)

---

## Alternatives Considered

### Alternative 1: Constructive Logic with `DecidableEq`

**Description**: Implement `DecidableEq Formula` and `DecidablePred (· ∈ Γ)` to make everything computable.

**Pros**:
- ✅ All definitions would be computable
- ✅ Theoretically "pure" constructive approach

**Cons**:
- ❌ Massive implementation cost (weeks of work)
- ❌ Significant code complexity increase
- ❌ Deviation from mathlib4 and Lean 4 standards
- ❌ No practical benefit (we don't execute proofs)
- ❌ Maintenance burden (every new formula constructor needs decidability instance)

**Decision**: Rejected - cost far outweighs benefit.

---

### Alternative 2: Curry-Howard Encoding

**Description**: Encode proofs as functions, making the proof system inherently computable.

**Pros**:
- ✅ Natural deduction style might be more intuitive for some users
- ✅ Proofs would be computable

**Cons**:
- ❌ Complete rewrite of ProofChecker (months of work)
- ❌ Abandons Hilbert-style system (core design choice)
- ❌ Loss of existing 10,000+ lines of proven theorems
- ❌ Deviation from project goals (bimodal temporal logic in Hilbert style)

**Decision**: Rejected - fundamentally incompatible with project architecture.

---

### Alternative 3: Quotient Types for Formula Equality

**Description**: Use quotient types to make formula equality computable by quotienting over syntactic equivalence.

**Pros**:
- ✅ Could make some operations computable

**Cons**:
- ❌ Adds significant complexity to formula representation
- ❌ Still requires classical logic for other operations (membership, context equality)
- ❌ Doesn't solve the fundamental problem
- ❌ Maintenance burden for little gain

**Decision**: Rejected - doesn't solve core issue, adds complexity.

---

### Alternative 4: Accept Noncomputable (CHOSEN)

**Description**: Use classical logic for metalogic, mark definitions as `noncomputable`.

**Pros**:
- ✅ Aligns with Lean 4 community standards
- ✅ Simple, maintainable implementation
- ✅ Follows published research practices
- ✅ Appropriate for mathematical proof objects
- ✅ No runtime impact (proofs erased)
- ✅ Minimal code changes required

**Cons**:
- ⚠️ Definitions cannot be executed (not a problem for proof systems)
- ⚠️ Must propagate `noncomputable` to dependencies

**Decision**: **ACCEPTED** - best fit for ProofChecker's architecture and goals.

---

## Consequences

### Positive

1. **Simplicity**: Metalogic proofs remain simple and readable
2. **Maintainability**: Aligns with Lean 4 ecosystem conventions
3. **Performance**: No runtime impact (proofs are erased)
4. **Standard Practice**: Follows mathlib4 and published research
5. **Minimal Changes**: Only requires adding `noncomputable` markers

### Negative

1. **Propagation**: Must mark all definitions calling `deduction_theorem` as `noncomputable`
2. **Documentation**: Must document why each definition is noncomputable
3. **Education**: Contributors must understand when to use `noncomputable`

### Neutral

1. **Not Executable**: Proof objects cannot be run (this is expected and appropriate)
2. **Classical Logic**: Deviates from constructive mathematics (acceptable for proof systems)

---

## Implementation Plan

### Phase 1: Fix Current Errors (Task 192)

**Status**: In Progress

1. ✅ Research completed (comprehensive)
2. ✅ Documentation created (this ADR + NONCOMPUTABLE_GUIDE.md)
3. ⏳ Fix `GeneralizedNecessitation.lean`:
   - Add `noncomputable` to `generalized_modal_k` (line 66)
   - Add `noncomputable` to `generalized_temporal_k` (line 101)
4. ⏳ Verify build passes

### Phase 2: Documentation (In Progress)

1. ✅ Create comprehensive catalog ([NONCOMPUTABLE_GUIDE.md](../development/NONCOMPUTABLE_GUIDE.md))
2. ✅ Create architecture decision record (this document)
3. ⏳ Update [LEAN_STYLE_GUIDE.md](../development/LEAN_STYLE_GUIDE.md) with noncomputable patterns
4. ⏳ Update [ARCHITECTURE.md](../user-guide/ARCHITECTURE.md) to mention classical logic choice

### Phase 3: Continuous Maintenance

1. Add docstrings to all noncomputable definitions explaining why
2. Include noncomputable checklist in code review process
3. Update NONCOMPUTABLE_GUIDE.md as new noncomputable definitions are added

---

## Validation

### Success Criteria

- [x] All noncomputable definitions are cataloged
- [x] Root cause analysis completed for each
- [ ] Build passes with no "no executable code" errors (pending Task 192 fix)
- [x] Documentation explains why classical logic is appropriate
- [x] Guidelines provided for future contributors

### Metrics

- **Research Depth**: 2 comprehensive reports (912 + 720 lines)
- **Catalog Completeness**: 36 definitions documented
- **Affected Files**: 2 files with explicit markers, 53 files audited
- **Dependency Chain**: Complete tree from `Classical.propDecidable` to all dependents

### Stakeholder Review

- **Technical**: Aligns with Lean 4 best practices
- **Maintenance**: Clear guidelines for contributors
- **Academic**: Follows published research standards
- **Practical**: No impact on user experience

---

## References

### Internal Documentation

- [NONCOMPUTABLE_GUIDE.md](../development/NONCOMPUTABLE_GUIDE.md) - Complete catalog and guidelines
- [Task 192](../../.opencode/specs/192_fix_generalized_necessitation_termination/) - Fix noncomputable errors
- [Noncomputable Research](../research/noncomputable.md) - Comprehensive explanation
- [Deduction Theorem Necessity](../research/deduction-theorem-necessity.md) - Detailed analysis

### External References

1. **Lean 4 Manual**: [Noncomputable Definitions](https://lean-lang.org/theorem_proving_in_lean4/axioms_and_computation.html#noncomputable-definitions)
2. **mathlib4**: Uses classical logic extensively for metalogic and set theory
3. **Lean 4 Research**: Published papers on formal verification use classical reasoning
4. **Classical vs. Constructive**: [Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-classical/)

### Related Decisions

- **None yet** (this is the first ADR)
- Future ADRs may reference this decision when discussing proof system design

---

## Notes

### Historical Context

- **2025-12-28**: Task 192 identified noncomputable errors in `GeneralizedNecessitation.lean`
- **2025-12-28**: Research completed on noncomputable necessity
- **2025-12-28**: Decision formalized in this ADR
- **2025-12-28**: Comprehensive catalog created ([NONCOMPUTABLE_GUIDE.md](../development/NONCOMPUTABLE_GUIDE.md))

### Key Insights

1. **Proofs are not programs**: Mathematical proof objects don't need to be executable
2. **Classical is standard**: Lean 4 community widely uses classical logic for metalogic
3. **Simplicity wins**: Classical approach is simpler and more maintainable than constructive
4. **No runtime cost**: Lean erases proofs at runtime, so noncomputable has zero performance impact

### Future Considerations

- If ProofChecker ever needs to **execute** proofs (e.g., proof search, automation), we could:
  1. Keep metalogic classical (for simplicity)
  2. Add separate computable proof search algorithms
  3. Use classical metalogic to verify correctness of computable algorithms

This separation is common in proof assistants (e.g., Coq's `Ltac` vs. `gallina`).

---

## Approval

**Decision Date**: 2025-12-28  
**Status**: Accepted  
**Approved By**: ProofChecker Development Team (via documentation and implementation)

**Rationale Summary**:  
Classical logic with noncomputable definitions is the standard, appropriate, and maintainable choice for ProofChecker's Hilbert-style proof system. The alternatives (constructive logic, Curry-Howard, quotient types) offer no practical benefits and impose significant costs.

**Implementation**: Proceeding with Task 192 fix and documentation updates.
