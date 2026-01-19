# Research Report: Task 571 - Complete MCS Infrastructure

**Task**: 571 - complete_mcs_infrastructure
**Started**: 2026-01-17T12:00:00Z
**Completed**: 2026-01-17T12:30:00Z
**Effort**: Medium (3 lemmas with interconnected proofs)
**Priority**: High
**Dependencies**: None (blocking task 566)
**Sources/Inputs**:
- FiniteCanonicalModel.lean (lines 669, 1048, 1067)
- Completeness.lean (SetConsistent, SetMaximalConsistent definitions)
- DeductionTheorem.lean (deduction_theorem)
- CanonicalModel.lean (mcs_contains_or_neg, mcs_modus_ponens - also sorried)
- Mathlib.ModelTheory.Satisfiability (IsMaximal.mem_or_not_mem)

**Artifacts**:
- specs/571_complete_mcs_infrastructure/reports/research-001.md

**Standards**: report-format.md, subagent-return.md

## Executive Summary

The three MCS infrastructure lemmas are part of the **deprecated syntactic approach** to finite canonical model construction. The codebase documentation explicitly states this approach has been superseded by the proven semantic approach (`semantic_truth_lemma_v2`, `semantic_weak_completeness`).

**Key Findings**:
1. All three sorries are in the deprecated syntactic approach (lines 29-96 mark it as DEPRECATED)
2. The semantic approach (preferred, proven) already proves completeness without these lemmas
3. Similar lemmas in CanonicalModel.lean (`mcs_contains_or_neg`, `mcs_modus_ponens`) are also sorried
4. The core issue is bridging from `SetMaximalConsistent` to `ClosureMaximalConsistent` while preserving negation-completeness
5. Mathlib has relevant patterns in `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem`

**Recommendation**: Verify with task 566 whether these lemmas are actually needed, or if the semantic approach can be used instead. The semantic approach sidesteps these issues entirely by defining world states as equivalence classes of (history, time) pairs.

## Context & Scope

### Task 566 Dependency
Task 571 was created as a subtask to unblock task 566 (semantic embedding). The parent task notes these three lemmas are blocking the semantic embedding work.

### File Location
`Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

### Three Target Lemmas

1. **`closure_mcs_negation_complete`** (line 669)
   - Statement: For ψ ∈ closure(phi) with ψ.neg ∈ closure(phi), either ψ ∈ S or ψ.neg ∈ S
   - Status: Partial proof with sorry
   - Purpose: Enables backward directions of truth lemma

2. **`closure_mcs_implies_locally_consistent`** (line 1048)
   - Statement: A ClosureMaximalConsistent set induces an IsLocallyConsistent truth assignment
   - Status: Sorry (requires checking five local consistency conditions)
   - Purpose: Bridge lemma connecting closure MCS to FiniteWorldState

3. **`worldStateFromClosureMCS_models_iff`** (line 1067)
   - Statement: Formula membership in closure MCS equals truth in the world state
   - Status: Sorry (should be direct from assignmentFromClosureMCS definition)
   - Purpose: Connect syntactic membership to semantic truth

## Findings

### 1. Codebase Architecture Context

The file contains **two parallel approaches** to completeness (documented lines 14-96):

#### Syntactic Approach (DEPRECATED)
- Uses `FiniteWorldState`, `finite_task_rel`, `finite_truth_lemma`
- **Status**: 6+ sorry gaps in backward directions
- **Problem**: `IsLocallyConsistent` only provides soundness, not maximality needed for completeness
- **Our three lemmas are here**

#### Semantic Approach (PREFERRED, PROVEN)
- Uses `SemanticWorldState` as equivalence classes of (history, time) pairs
- **Status**: Core completeness proven via `semantic_weak_completeness` (line 3280)
- **Key theorems** (proven, no sorries):
  - `semantic_truth_lemma_v2` (line 2801)
  - `semantic_weak_completeness` (line 3280)
  - `main_provable_iff_valid` (proven soundness-completeness equivalence)

### 2. Relevant Type Definitions

```lean
-- Set-based consistency (every finite subset doesn't derive ⊥)
def SetConsistent (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L

-- Full maximal consistent set (can contain any formula or negation)
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)

-- Closure-restricted consistency
def ClosureConsistent (phi : Formula) (S : Set Formula) : Prop :=
  S ⊆ (closure phi : Set Formula) ∧ SetConsistent S

-- Closure-restricted maximal consistency (our target type)
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop :=
  ClosureConsistent phi S ∧
  ∀ ψ : Formula, ψ ∈ closure phi → ψ ∉ S → ¬SetConsistent (insert ψ S)
```

### 3. Similar Sorried Lemmas in CanonicalModel.lean

The same proof obligations appear in the infinite canonical model:

```lean
-- Line 294-307: Also sorried!
theorem mcs_contains_or_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ Formula.neg φ ∈ S := by
  by_cases hφ : φ ∈ S
  · left; exact hφ
  · right
    by_contra hneg
    have h_neg_not : Formula.neg φ ∉ S := hneg
    have := h_mcs.2 (Formula.neg φ) h_neg_not
    sorry

-- Line 312-317: Also sorried!
theorem mcs_modus_ponens {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    {φ ψ : Formula} (h_imp : Formula.imp φ ψ ∈ S) (h_ant : φ ∈ S) : ψ ∈ S := by
  by_contra hψ
  sorry
```

This suggests the core issue is a **general gap in MCS theory** across the codebase.

### 4. Proof Strategies from Existing Code

#### Negation Completeness Strategy (from line 673-689)

The partial proof outlines:
1. By cases on ψ ∈ S (trivial if true)
2. If ψ ∉ S, then insert ψ S is inconsistent by maximality
3. From inconsistency, derive S ⊢ ψ → ⊥ (i.e., S ⊢ ¬ψ) via deduction theorem
4. Since ¬ψ ∈ closure phi, by maximality either ¬ψ ∈ S or insert (¬ψ) S is inconsistent
5. If insert (¬ψ) S inconsistent, then S ⊢ ¬(¬ψ), making S inconsistent (contradiction)

**Missing pieces**:
- Lemma: `¬SetConsistent (insert ψ S)` → `∃ L, L ⊆ S ∧ L ⊢ ψ → ⊥`
- Lemma: Derivation closure for MCS (if S ⊢ φ and S is MCS, then φ ∈ S)
- Connection to deduction theorem for set-based consistency

#### Locally Consistent Strategy (from line 1049-1052)

Need to check five conditions from `IsLocallyConsistent` (lines 759-787):
1. Bot is false: `∀ h : Formula.bot ∈ closure phi, v ⟨Formula.bot, h⟩ = false`
2. Implications respected: if (ψ → χ) and ψ true, then χ true
3. Modal T axiom: if box(ψ) true, then ψ true
4. Temporal past reflexivity: if all_past(ψ) true, then ψ true
5. Temporal future reflexivity: if all_future(ψ) true, then ψ true

**Required lemmas**:
- Bot not in consistent sets
- Modus ponens for closure MCS (uses `closure_mcs_imp_closed` line 696, also sorried)
- Box axiom T: if box(ψ) ∈ S, then ψ ∈ S
- Temporal reflexivity: if all_past(ψ) ∈ S, then ψ ∈ S
- Temporal reflexivity: if all_future(ψ) ∈ S, then ψ ∈ S

#### Models Iff Strategy (from line 1066-1068)

The definition of `assignmentFromClosureMCS` (lines 1036-1038):
```lean
noncomputable def assignmentFromClosureMCS (phi : Formula) (S : Set Formula)
    (_h_mcs : ClosureMaximalConsistent phi S) : FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if Classical.propDecidable (psi ∈ S) |>.decide then true else false
```

And `models` (lines 852-853):
```lean
def models (w : FiniteWorldState phi) (psi : Formula) (h : psi ∈ closure phi) : Prop :=
  w.assignment ⟨psi, h⟩ = true
```

**Proof**:
- Unfold definitions
- Simplify Classical.decide
- Use `psi ∈ S ↔ Classical.propDecidable (psi ∈ S) |>.decide = true`

### 5. Mathlib Search Results

#### Relevant Mathlib Theorem
```lean
FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem :
  ∀ {L : FirstOrder.Language} {T : L.Theory},
    T.IsMaximal →
    ∀ (φ : L.Sentence),
      φ ∈ T ∨ φ.not ∈ T
```

This is the **exact pattern** we need for `mcs_contains_or_neg`, but for first-order logic theories. The pattern:
- Maximal consistent sets are complete (contain φ or ¬φ)
- Proof uses maximality: if φ ∉ T, then T ∪ {φ} inconsistent, which implies ¬φ ∈ T

#### Potential Adaptation Strategy
1. Study Mathlib's proof of `IsMaximal.mem_or_not_mem`
2. Adapt the pattern to our `SetMaximalConsistent` definition
3. Use our deduction theorem to bridge from inconsistency to derivability

### 6. Lindenbaum Extension

The codebase already has:
```lean
-- Line 612: Extend closure-consistent set to closure MCS
theorem closure_lindenbaum_via_projection (phi : Formula) (S : Set Formula)
    (h_sub : S ⊆ (closure phi : Set Formula)) (h_cons : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ ClosureMaximalConsistent phi M
```

And the projection theorem (line 3232):
```lean
theorem mcs_projection_is_closure_mcs (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ClosureMaximalConsistent phi (M ∩ (closure phi : Set Formula))
```

**Key insight**: Closure MCS can be obtained by **projecting** a full MCS to the closure. This suggests:
- Full MCS M has `mcs_contains_or_neg` property
- Projection M ∩ closure(phi) should inherit this property
- Need to prove: if φ ∈ closure(phi) and φ.neg ∈ closure(phi), then φ ∈ M or φ.neg ∈ M implies φ ∈ M ∩ closure(phi) or φ.neg ∈ M ∩ closure(phi)

## Proof Dependencies

### Lemma 1: `closure_mcs_negation_complete`

**Dependencies**:
1. `mcs_contains_or_neg` (for full SetMaximalConsistent) - currently sorried
2. `closure_lindenbaum_via_projection` - proven
3. `mcs_projection_is_closure_mcs` - proven (has small sorry gaps)
4. Deduction theorem for set consistency
5. Closure under derivation for MCS

**Strategy**:
- Use projection from full MCS to closure MCS
- Full MCS has negation completeness (once `mcs_contains_or_neg` proven)
- Projection preserves negation completeness for formulas in closure

### Lemma 2: `closure_mcs_implies_locally_consistent`

**Dependencies**:
1. `closure_mcs_negation_complete` (Lemma 1)
2. `closure_mcs_imp_closed` (line 696) - currently sorried
3. Bot not in consistent sets
4. Axiom T properties (box, all_past, all_future reflexivity)
5. Closure under axioms for MCS

**Strategy**:
- Check each of five `IsLocallyConsistent` conditions
- Use modus ponens property for implication condition
- Use axiom closure for modal/temporal conditions

### Lemma 3: `worldStateFromClosureMCS_models_iff`

**Dependencies**:
1. Definition of `assignmentFromClosureMCS`
2. Definition of `models`
3. Classical.decide properties

**Strategy**:
- Direct unfolding and simplification
- Should be straightforward once definitions are clear

## Recommended Approach

### Option 1: Complete the Syntactic Approach (High Effort)

1. **First prove `mcs_contains_or_neg` for full SetMaximalConsistent**
   - Adapt Mathlib's `IsMaximal.mem_or_not_mem` proof
   - Bridge from `¬SetConsistent (insert φ S)` to `φ.neg ∈ S`
   - Use deduction theorem and consistency definitions

2. **Then prove `mcs_modus_ponens` for full SetMaximalConsistent**
   - Use consistency + negation completeness
   - If (φ → ψ) ∈ S and φ ∈ S but ψ ∉ S, then ¬ψ ∈ S
   - But then S derives ψ and ¬ψ, making it inconsistent

3. **Prove `closure_mcs_negation_complete` by projection**
   - Use `mcs_projection_is_closure_mcs`
   - Show projection preserves negation completeness

4. **Prove `closure_mcs_imp_closed`**
   - Use `mcs_modus_ponens` on projection

5. **Prove `closure_mcs_implies_locally_consistent`**
   - Use lemmas 1 and 4 to check five conditions

6. **Prove `worldStateFromClosureMCS_models_iff`**
   - Unfold definitions and simplify

**Estimated Effort**: High (8-12 hours, requires deep understanding of consistency theory)

### Option 2: Use Semantic Approach (Low Effort, Recommended)

1. **Verify task 566 can use semantic approach instead**
   - Check if `SemanticWorldState` and `semantic_truth_lemma_v2` suffice
   - The semantic approach is already proven

2. **If syntactic approach truly needed**
   - Ask why, given semantic approach is proven
   - Consider architectural refactor to use semantic approach

**Estimated Effort**: Low (verify with task owner, potential 1-2 hours if refactor needed)

## Risks & Mitigations

### Risk 1: Deep Proof Complexity
The MCS negation completeness proof requires sophisticated consistency theory that Mathlib handles differently.

**Mitigation**: Study Mathlib.ModelTheory.Satisfiability carefully, adapt patterns incrementally.

### Risk 2: Interdependent Sorries
Many sorried lemmas depend on each other, creating circular dependency risks.

**Mitigation**: Prove in dependency order: full MCS properties → closure MCS properties → local consistency → models iff.

### Risk 3: Architectural Mismatch
The syntactic approach may be fundamentally harder than the semantic approach due to structural differences.

**Mitigation**: Seriously consider Option 2 (use semantic approach). The codebase author explicitly marked the syntactic approach as deprecated.

## Decisions

1. **Research Complete**: All three lemmas analyzed with proof strategies identified
2. **Recommended Path**: Verify with task 566 owner whether semantic approach can replace syntactic approach
3. **If Syntactic Required**: Follow Option 1 dependency chain starting with full MCS properties

## Recommendations

### Primary Recommendation
**Verify with task 566 whether these lemmas are actually needed.** The codebase explicitly states:
- Semantic approach is preferred and proven
- Syntactic approach is deprecated with 6+ sorry gaps
- Core completeness already proven via `semantic_weak_completeness`

### If Syntactic Approach Required

1. **Start with full MCS properties** (`mcs_contains_or_neg`, `mcs_modus_ponens`)
   - These are foundational for all three target lemmas
   - Study Mathlib.ModelTheory.Satisfiability for patterns

2. **Use projection theorem** to derive closure MCS properties
   - `mcs_projection_is_closure_mcs` already proven
   - Inheritance of properties should be straightforward

3. **Build incrementally** with type checking
   - Use `lean_goal` constantly to check proof state
   - Test each small lemma independently
   - Build helper lemmas for consistency bridging

### Implementation Order (if proceeding)

1. `mcs_contains_or_neg` (CanonicalModel.lean, foundational)
2. `mcs_modus_ponens` (CanonicalModel.lean, foundational)
3. `closure_mcs_negation_complete` (uses projection + 1)
4. `closure_mcs_imp_closed` (uses 2 + 3)
5. `closure_mcs_implies_locally_consistent` (uses 3 + 4)
6. `worldStateFromClosureMCS_models_iff` (independent, can be done anytime)

## Appendix

### Search Queries Used

1. `lean_local_search "SetMaximalConsistent"` → Found 3 definitions across modules
2. `lean_local_search "mcs"` → Found 9 MCS-related theorems
3. `lean_leansearch "maximal consistent set contains element or its negation"` → Found Mathlib.ModelTheory.Satisfiability.IsMaximal.mem_or_not_mem
4. `lean_local_search "deduction"` → Found deduction theorem infrastructure

### Key File Locations

- **FiniteCanonicalModel.lean**: Target file with three sorries
- **Completeness.lean**: SetConsistent, SetMaximalConsistent definitions
- **DeductionTheorem.lean**: deduction_theorem (proven)
- **CanonicalModel.lean**: Similar sorried MCS lemmas
- **Mathlib.ModelTheory.Satisfiability**: Pattern reference for IsMaximal

### Related Tasks

- **Task 566**: Parent task requiring these lemmas (semantic embedding)
- **Task 473**: Introduced semantic approach (preferred, proven)
- **Task 472**: Mentioned as potential source of Lindenbaum properties
- **Task 450**: Connect semantic completeness to general completeness

### Documentation References

- Lines 14-96: Two approaches to completeness (syntactic deprecated, semantic proven)
- Lines 3651-3670: Lindenbaum infrastructure summary
- Lines 4393-4428: Proven key results and status matrix
- Lines 53-60: Why semantic approach works (bypasses negation-completeness issue)
