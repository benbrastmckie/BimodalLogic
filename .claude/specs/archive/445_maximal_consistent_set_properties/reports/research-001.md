# Research Report: Task #445

**Task**: Maximal Consistent Set Properties
**Date**: 2026-01-12
**Focus**: Phase 2 of completeness proofs - MCS properties for canonical model construction

## Summary

Task 445 requires proving key properties of maximal consistent sets (MCS) that are essential for the truth lemma and canonical model construction. The two core axioms to prove are `maximal_consistent_closed` and `maximal_negation_complete`, plus additional saturation lemmas for modal and temporal operators. All proofs depend on the deduction theorem (already complete) and build on the set-based infrastructure from Task 444.

## Findings

### Current State of Completeness.lean

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`

After Task 444's changes:
- `CanonicalWorldState` is now `{S : Set Formula // SetMaximalConsistent S}` (set-based)
- `SetConsistent S` and `SetMaximalConsistent S` are defined for sets
- `set_lindenbaum` is fully proven using Zorn's lemma
- `Countable Formula` instance is available for enumeration

**Axiom Stubs to Prove**:

| Axiom | Type Signature | Location |
|-------|---------------|----------|
| `maximal_consistent_closed` | `MaximalConsistent G -> DerivationTree G phi -> phi in G` | Line 423 |
| `maximal_negation_complete` | `MaximalConsistent G -> phi notin G -> neg phi in G` | Line 437 |

**Additional Properties Needed** (not currently defined):
- Implication property
- Conjunction/disjunction properties
- Modal saturation (box/diamond)
- Temporal saturation (F/P/G/H)

### Definition Review

**Set-Based Consistency** (Line 120-128):
```lean
def SetConsistent (S : Set Formula) : Prop :=
  forall L : List Formula, (forall phi in L, phi in S) -> Consistent L

def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S and forall phi : Formula, phi notin S -> not SetConsistent (insert phi S)
```

**List-Based Definitions** (Line 90-104):
```lean
def Consistent (G : Context) : Prop := not Nonempty (DerivationTree G Formula.bot)

def MaximalConsistent (G : Context) : Prop :=
  Consistent G and forall phi : Formula, phi notin G -> not Consistent (phi :: G)
```

**Key Observation**: The axiom stubs use the list-based `MaximalConsistent`, but the canonical model uses set-based `SetMaximalConsistent`. This needs reconciliation - either:
1. Prove lemmas for set-based MCS and update axiom stubs
2. Bridge between list-based and set-based definitions

### Proof Strategies

#### 1. maximal_consistent_closed

**Statement**: `MaximalConsistent G -> DerivationTree G phi -> phi in G`

**Strategy** (contrapositive):
1. Assume `MaximalConsistent G` and `phi notin G`
2. By maximality definition: `not Consistent (phi :: G)`
3. So there exists derivation `(phi :: G) |- bot`
4. By deduction theorem: `G |- phi -> bot` (i.e., `G |- neg phi`)
5. Now assume we also have `G |- phi`
6. By modus ponens with EFQ: `G |- phi` and `G |- neg phi` gives `G |- bot`
7. This contradicts `Consistent G`

**Key Dependencies**:
- `deduction_theorem : (A :: G) |- B -> G |- A.imp B` (proven in DeductionTheorem.lean)
- Modus ponens and EFQ axiom derivations
- The fact that `neg phi = phi.imp bot` in our syntax

**Estimated Effort**: 3-4 hours

#### 2. maximal_negation_complete

**Statement**: `MaximalConsistent G -> phi notin G -> Formula.neg phi in G`

**Strategy**:
1. Assume `MaximalConsistent G` and `phi notin G`
2. By maximality: `(phi :: G)` is inconsistent, so `(phi :: G) |- bot`
3. By deduction theorem: `G |- phi -> bot`, i.e., `G |- neg phi`
4. By `maximal_consistent_closed`: `neg phi in G`

**Dependencies**:
- `maximal_consistent_closed` (prove this first)
- Deduction theorem
- Understanding that `neg phi` in syntax is `phi.imp bot`

**Estimated Effort**: 1-2 hours (builds on maximal_consistent_closed)

#### 3. Implication Property

**Statement**: `SetMaximalConsistent S -> (phi.imp psi) in S -> phi in S -> psi in S`

**Strategy**:
1. Assume `(phi -> psi) in S` and `phi in S`
2. Take any finite subset L of S containing both formulas
3. By modus ponens: `L |- psi`
4. By closure property: `psi in S`

**Estimated Effort**: 2 hours

#### 4. Conjunction Properties

For sets, conjunction distributes:
- `(phi.and psi) in S <-> phi in S and psi in S`

**Strategy**: Use definition `phi.and psi = neg (phi.imp (neg psi))` and apply closure/negation completeness.

**Estimated Effort**: 2-3 hours

#### 5. Disjunction Properties

- `(phi.or psi) in S <-> phi in S or psi in S`

**Strategy**: Use definition `phi.or psi = (neg phi).imp psi` and contrapositive.

**Estimated Effort**: 2-3 hours

#### 6. Modal Saturation (Box)

**Statement**: `SetMaximalConsistent S -> (box phi in S <-> forall Delta accessible, phi in Delta)`

This is central to the truth lemma for the box case.

**Forward Direction** (box phi in S -> phi at accessible states):
- By Modal T axiom: `box phi -> phi`
- By closure: if `box phi in S` then `phi in S`
- For accessible Delta via task relation: modal transfer gives `phi in Delta`

**Backward Direction** (contrapositive):
- If `box phi notin S`, then `neg (box phi) in S` (by negation completeness)
- By Modal duality: `diamond (neg phi) in S`
- Need to show there exists accessible Delta with `neg phi in Delta`
- Use Lindenbaum to extend `{neg phi}` to maximal consistent set

**Dependencies**:
- Modal T axiom: `box phi -> phi`
- Modal duality: `neg (box phi) <-> diamond (neg phi)`
- Lindenbaum lemma
- Task relation definition (from Phase 4)

**Estimated Effort**: 4-5 hours

#### 7. Temporal Saturation (Future - G operator)

**Statement**: For all_future (G): `G phi in S <-> forall t > 0 in domain, phi at time t`

**Forward Direction**:
- By Temp 4 axiom: `G phi -> G G phi`
- Shows G-formulas persist in the future

**Backward Direction** (contrapositive):
- If `G phi notin S`, then `F (neg phi) in S` (by duality)
- Need to construct witness time where `neg phi` holds
- Requires canonical_history construction (Phase 5)

**Dependencies**:
- Temporal axioms (TK, T4, TA, TL)
- Canonical history construction

**Estimated Effort**: 4-5 hours (but depends on Phase 5)

#### 8. Temporal Saturation (Past - H operator)

Symmetric to future saturation using all_past (H) and some_past (P).

**Estimated Effort**: 3-4 hours (parallel to future case)

### Mathlib Patterns

**Relevant Mathlib Definitions** (from search):

1. `FirstOrder.Language.Theory.IsMaximal` - Maximal consistent theory in first-order logic
   ```lean
   T.IsMaximal -> forall phi, phi in T or not phi in T
   ```

2. `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` - Negation completeness
   ```lean
   T.IsMaximal -> forall phi, phi in T or (Formula.not phi) in T
   ```

3. `FirstOrder.Language.Theory.IsMaximal.mem_of_models` - Deductive closure
   ```lean
   T.IsMaximal -> T.ModelsBoundedFormula phi -> phi in T
   ```

These patterns confirm our approach is standard.

### Set vs List Reconciliation

**Issue**: Axiom stubs use `Context = List Formula`, but set-based MCS is needed for true maximality.

**Options**:

1. **Bridge Lemma Approach** (Recommended):
   ```lean
   lemma set_maximal_list_consistent (S : Set Formula) :
     SetMaximalConsistent S ->
     forall L : List Formula, (forall phi in L, phi in S) -> Consistent L
   ```
   Then work with set-based definitions throughout.

2. **Axiom Stub Update**:
   Change axiom stubs to use `SetMaximalConsistent` directly:
   ```lean
   axiom maximal_consistent_closed_set (S : Set Formula) (phi : Formula) :
     SetMaximalConsistent S ->
     (exists L : List Formula, (forall psi in L, psi in S) and DerivationTree L phi) ->
     phi in S
   ```

3. **Countable Enumeration**:
   Use `Countable Formula` to enumerate set elements when needed for finite derivations.

**Recommendation**: Option 1 (Bridge Lemma) - keeps existing signatures, adds bridging infrastructure.

### Proof Order Dependencies

```
Tier 1 (No dependencies):
  maximal_consistent_closed

Tier 2 (Depends on Tier 1):
  maximal_negation_complete
  implication_property

Tier 3 (Depends on Tier 2):
  conjunction_properties
  disjunction_properties
  modal_box_closure (basic)

Tier 4 (Depends on canonical frame - Phase 4):
  modal_saturation_full

Tier 5 (Depends on canonical history - Phase 5):
  temporal_saturation_future
  temporal_saturation_past
```

### Key Axioms Used

| Property | Axioms Required |
|----------|-----------------|
| maximal_consistent_closed | Deduction theorem, EFQ |
| maximal_negation_complete | Deduction theorem |
| implication_property | Modus ponens |
| box_closure | Modal T (box phi -> phi) |
| modal_saturation | Modal T, Modal 4, Modal B, Modal K |
| temporal_saturation | Temp K, Temp 4, Temp A, Temp L |

### Implementation Checklist

**Phase 2a - Core Properties** (6-8 hours):
- [ ] Prove `maximal_consistent_closed`
- [ ] Prove `maximal_negation_complete`
- [ ] Define and prove `mcs_implication_property`
- [ ] Convert axiom stubs to theorems

**Phase 2b - Boolean Properties** (4-6 hours):
- [ ] Prove conjunction membership equivalence
- [ ] Prove disjunction membership equivalence
- [ ] Add helper lemmas for derived connectives

**Phase 2c - Modal Closure** (3-4 hours):
- [ ] Prove basic box closure (using Modal T)
- [ ] Prove diamond/box duality preservation

**Phase 2d - Saturation Lemmas** (6-8 hours, partial - depends on later phases):
- [ ] State modal saturation lemma (full proof needs Phase 4)
- [ ] State temporal saturation lemmas (full proof needs Phase 5)
- [ ] Prove forward directions where possible

**Total Estimated Effort**: 10-12 hours (as specified in implementation plan)

## Recommendations

### Implementation Order

1. **Start with `maximal_consistent_closed`** - This is the foundation for all other properties. Use the deduction theorem and contrapositive argument.

2. **Prove `maximal_negation_complete`** - Quick follow-up using maximal_consistent_closed.

3. **Add implication/conjunction/disjunction properties** - Standard MCS properties that the truth lemma will need.

4. **Basic modal closure** - Prove `box phi in G -> phi in G` using Modal T axiom.

5. **State (but don't fully prove) saturation lemmas** - These depend on canonical frame construction. State them as lemmas with appropriate sorry placeholders for Phase 4/5 dependencies.

### Key Technical Decisions

1. **Use set-based definitions for saturation lemmas** - Match the set-based `CanonicalWorldState` type.

2. **Bridge between list and set** - Create explicit conversion lemmas using SetConsistent definition.

3. **Factor out reusable patterns** - Create helper lemmas for common patterns (weaken derivation to context, apply axiom and closure, etc.).

### Verification Steps

After implementing each property:
```bash
lake build Bimodal.Metalogic.Completeness
```

Check axiom count:
```bash
grep -c "^axiom" Theories/Bimodal/Metalogic/Completeness.lean
```

After Phase 2, axiom count should decrease by 2 (maximal_consistent_closed and maximal_negation_complete become theorems).

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Deduction theorem integration complex | Medium | Helper lemmas for common patterns |
| Set/list conversion subtle | Medium | Explicit bridge lemmas with clear invariants |
| Modal saturation depends on later phases | Low | State lemma, use sorry for dependent part |
| Proof scripts become long | Low | Factor into small well-named lemmas |

## Appendix: Relevant Code Locations

### Deduction Theorem
- `Theories/Bimodal/Metalogic/DeductionTheorem.lean:332` - Main theorem
- Helper: `deduction_mp` (line 183) - Modus ponens under implication
- Helper: `deduction_axiom` (line 148) - Axiom weakening

### Axiom Schema
- `Theories/Bimodal/ProofSystem/Axioms.lean` - All 14 axiom schemas
- Key for MCS: `modal_t`, `modal_4`, `modal_b`, `modal_k`
- Key for temporal: `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`

### Formula Structure
- `Theories/Bimodal/Syntax/Formula.lean:85-98` - Formula inductive type
- `Formula.neg phi = phi.imp bot` - Negation is derived
- `Formula.box` - Modal necessity primitive

### Derivation System
- `Theories/Bimodal/ProofSystem/Derivation.lean:69-149` - DerivationTree type
- 7 inference rules: axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening

## References

- Previous research: `.claude/specs/257_completeness_proofs/reports/research-001.md` through `research-004.md`
- Task 444 summary: `.claude/specs/444_formula_countability_set_list_bridge/summaries/implementation-summary-20260112.md`
- Implementation plan: `.claude/specs/257_completeness_proofs/plans/implementation-002.md`
- Mathlib `FirstOrder.Language.Theory.IsMaximal` - Pattern for maximal theories
- Modal Logic (Blackburn et al.), Chapter 4 - Canonical model construction
