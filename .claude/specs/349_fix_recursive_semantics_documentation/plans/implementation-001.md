# Implementation Plan: Task #349

**Task**: Address all [FIX] tags in RECURSIVE_SEMANTICS.md documentation
**Version**: 001
**Created**: 2026-01-09
**Language**: markdown

## Overview

Systematically address all 25 [FIX] tags in RECURSIVE_SEMANTICS.md through five phases: (1) Constitutive Layer notation fixes, (2) Constitutive Layer semantic clauses, (3) Causal Layer frame and constraints, (4) Causal Layer truth conditions, (5) GLOSSARY.md updates and final cleanup. Each phase groups related fixes to minimize context-switching and ensure consistency.

## Phases

### Phase 1: Constitutive Layer Notation Standardization

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Standardize interpretation function notation (I → | |)
2. Update predicate notation (v_F/f_F → |F|⁺/|F|⁻)
3. Standardize variable assignment notation (σ → a̅)
4. Remove [FIX] tags for turnstile symbols (keep current notation per research)

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Lines 47, 54, 56-59, 63-69, 73

**Steps**:

1. **Fix line 47**: Replace `⟨S, ⊑, I⟩` with `⟨S, ⊑, | |⟩` and update description
   - Remove [FIX] tag at end of line

2. **Fix lines 52-59**: Update interpretation function description
   ```markdown
   | **Interpretation** | | | assigns meanings to non-logical vocabulary |

   The interpretation function | | assigns:
   - **n-place function symbols** f → |f| : Sⁿ → S (0-place = individual constants mapping to states)
   - **n-place predicates** F → ordered pairs ⟨|F|⁺, |F|⁻⟩ where:
     - |F|⁺ : set of functions Sⁿ → S (verifier functions)
     - |F|⁻ : set of functions Sⁿ → S (falsifier functions)
   ```

3. **Fix line 63**: Replace section intro for variable assignments
   - Update to use a̅ notation
   - Add note about reserving Greek letters for world-histories

4. **Fix line 69**: Update function application clause
   - Change `I(f)` to `|f|`

5. **Fix line 73**: Remove [FIX] tag - keep ⊩⁺/⊩⁻ notation (fallback allowed per research)

**Verification**:
- All [FIX] tags in lines 47-73 removed
- Notation consistent: | | for interpretation, a̅ for assignments
- Markdown renders correctly

---

### Phase 2: Constitutive Layer Semantic Clauses

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Add model M and variable assignment to all verification/falsification clauses
2. Add lambda abstraction semantic clause
3. Specify syntactic primitives and update [FIX] tag at line 26

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Lines 26, 75-126

**Steps**:

1. **Fix line 26**: Add syntactic primitives section
   ```markdown
   ### Syntactic Primitives

   The Constitutive Layer interprets the following syntactic primitives:
   - **Variables**: x, y, z, ... (ranging over states)
   - **Individual constants**: a, b, c, ... (0-place function symbols)
   - **n-place function symbols**: f, g, h, ...
   - **n-place predicates**: F, G, H, ...
   - **Sentence letters**: p, q, r, ... (0-place predicates)
   - **Lambda abstraction**: λx.A (binding variable x in formula A)
   - **Logical connectives**: ¬, ∧, ∨, ⊤, ⊥, ≡
   ```

2. **Fix lines 79-87**: Update atomic formulas section with full contextual parameters
   ```markdown
   | | Condition |
   |---|-----------|
   | M, a̅, s ⊩⁺ F(t₁,...,tₙ) | iff there is some f ∈ |F|⁺ where s = f(⟦t₁⟧^a̅_M, ..., ⟦tₙ⟧^a̅_M) |
   | M, a̅, s ⊩⁻ F(t₁,...,tₙ) | iff there is some f ∈ |F|⁻ where s = f(⟦t₁⟧^a̅_M, ..., ⟦tₙ⟧^a̅_M) |
   ```

3. **Fix line 88**: Add lambda abstraction clause after atomic formulas
   ```markdown
   #### Lambda Abstraction (λ)

   | | Condition |
   |---|-----------|
   | M, a̅, s ⊩⁺ (λx.A)(t) | iff M, a̅[⟦t⟧^a̅_M/x], s ⊩⁺ A |
   | M, a̅, s ⊩⁻ (λx.A)(t) | iff M, a̅[⟦t⟧^a̅_M/x], s ⊩⁻ A |

   Where a̅[v/x] is the assignment that maps x to v and agrees with a̅ on all other variables.
   ```

4. **Fix line 92**: Add M, a̅ to all subsequent connective clauses
   - Update Negation table: `M, a̅, s ⊩⁺ ¬A` etc.
   - Update Conjunction table
   - Update Disjunction table
   - Update Top/Bottom table
   - Update Propositional Identity table

**Verification**:
- All verification/falsification clauses include M, a̅, s
- Lambda abstraction clause present
- Syntactic primitives section added
- [FIX] tags at lines 26, 79-81, 88, 92 removed

---

### Phase 3: Causal Layer Frame and Constraints

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Clarify intensional/hyperintensional relationship
2. Restructure task relation constraints (remove Nullity, add Containment, Maximality)
3. Update state modality definitions (define possible states via s ⇒_0 s)
4. Update causal model notation (I → | |)

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Lines 157-215

**Steps**:

1. **Fix lines 157-160**: Rewrite section intro
   ```markdown
   ## Causal Layer: Intensional Semantics

   The Causal Layer extends the Constitutive Layer with temporal structure and a task relation, enabling evaluation of truth relative to world-histories and times. While the hyperintensional foundation remains (distinguishing propositions by their exact verifiers and falsifiers), this layer adds intensional evaluation relative to contextual parameters (world-history, time, variable assignment) to determine truth-values for all Causal Layer sentences.
   ```

2. **Fix lines 174-183**: Restructure task relation constraints
   ```markdown
   The task relation s ⇒_d t (read: "there is a task from s to t of duration d") satisfies:

   | Constraint | Formulation |
   |------------|-------------|
   | **Compositionality** | If s ⇒_x t and t ⇒_y u, then s ⇒_{x+y} u |
   | **Parthood (Left)** | If d ⊑ s and s ⇒_x t, then d ⇒_x r for some r ⊑ t |
   | **Parthood (Right)** | If r ⊑ t and s ⇒_x t, then d ⇒_x r for some d ⊑ s |
   | **Containment (L)** | If s ∈ P, d ⊑ s, and d ⇒_x r, then s ⇒_x t.r for some t ∈ S |
   | **Containment (R)** | If t ∈ P, r ⊑ t, and d ⇒_x r, then s.d ⇒_x t for some s ∈ S |
   | **Maximality** | If s ∈ S and t ∈ P, there is a maximal t-compatible part r ∈ s_t |

   **Note**: The Containment constraints ensure that tasks between parts of possible states can be extended to tasks between the states themselves. The Maximality constraint ensures that for any state and possible state, there exists a maximal part compatible with that possible state.
   ```

3. **Fix lines 187-197**: Update state modality definitions
   ```markdown
   ### State Modality Definitions

   | Term | Definition |
   |------|------------|
   | **Possible state** | s ∈ P iff s ⇒_0 s (state has a trivial task to itself) |
   | **Impossible state** | s ∉ P iff ¬(s ⇒_0 s) |
   | **Connected** | s ~ t iff s ⇒_d t or t ⇒_d s for some d |
   | **Compatible states** | s ∘ t iff s.t ∈ P |
   | **Maximal state** | s is maximal iff t ⊑ s for every compatible state t ∘ s |
   | **World-state** | w ∈ W iff w is a maximal possible state |
   | **Necessary state** | s ∈ N iff s ~ t implies s = t |
   ```

4. **Fix lines 211-215**: Update causal model notation
   ```markdown
   A *causal model* is a structure **M** = ⟨S, ⊑, D, ⇒, | |⟩ where:
   - ⟨S, ⊑, D, ⇒⟩ is a causal frame
   - | | is an interpretation as in the Constitutive Layer
   ```

**Verification**:
- Nullity removed from constraints table
- Containment (L), Containment (R), and Maximality added
- Possible state defined directly via s ⇒_0 s
- Intensional/hyperintensional relationship clarified
- [FIX] tags at lines 157-160, 174, 183, 187, 211 removed

---

### Phase 4: Causal Layer Truth Conditions

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add variable assignment to all truth condition clauses
2. Add time vector v⃗ to contextual parameters
3. Remove time domain restriction
4. Rewrite atomic sentence clauses
5. Add lambda abstraction clause
6. Update Since/Until operator symbols
7. Fix imposition notation

**Files to modify**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Lines 217-354

**Steps**:

1. **Fix lines 219-223**: Update truth conditions intro
   ```markdown
   ### Truth Conditions

   Truth is evaluated relative to a model M, world-history τ, time x ∈ D, variable assignment a̅, and time vector v⃗ = ⟨v₁, v₂, ...⟩:
   ```

2. **Fix lines 227-240**: Rewrite atomic sentences section
   ```markdown
   #### Atomic Sentences

   | | Condition |
   |---|-----------|
   | M, τ, x, a̅, v⃗ ⊨ F(t₁,...,tₙ) | iff there is some f ∈ |F|⁺ where f(⟦t₁⟧^a̅_M, ..., ⟦tₙ⟧^a̅_M) ⊑ τ(x) |
   | M, τ, x, a̅, v⃗ ⊭ F(t₁,...,tₙ) | iff there is some f ∈ |F|⁻ where f(⟦t₁⟧^a̅_M, ..., ⟦tₙ⟧^a̅_M) ⊑ τ(x) |

   **Note**: It is derivable that M, τ, x, a̅, v⃗ ⊨ A iff it is not the case that M, τ, x, a̅, v⃗ ⊭ A. This justifies using ⊨ alone for truth and ⊭ for falsehood.

   #### Lambda Abstraction

   | Operator | Truth Condition |
   |----------|-----------------|
   | **(λx.A)(t)** | M, τ, x, a̅, v⃗ ⊨ (λx.A)(t) iff M, τ, x, a̅[⟦t⟧/x], v⃗ ⊨ A |
   ```

3. **Fix lines 242-257**: Add a̅, v⃗ to extensional connective and modal operator clauses
   - Update all tables to use `M, τ, x, a̅, v⃗ ⊨ ...`

4. **Fix lines 266-277**: Add a̅, v⃗ to tense operator clauses
   - Update H, G, P, F operators

5. **Fix lines 281-289**: Update Since/Until with new symbols
   ```markdown
   #### Extended Tense Operators: Since and Until

   | Operator | Truth Condition |
   |----------|-----------------|
   | **A ◁ B** (Since) | M, τ, x, a̅, v⃗ ⊨ A ◁ B iff there exists z < x where M, τ, z, a̅, v⃗ ⊨ B and M, τ, y, a̅, v⃗ ⊨ A for all y where z < y < x |
   | **A ▷ B** (Until) | M, τ, x, a̅, v⃗ ⊨ A ▷ B iff there exists z > x where M, τ, z, a̅, v⃗ ⊨ B and M, τ, y, a̅, v⃗ ⊨ A for all y where x < y < z |

   **Reading**:
   - "A since B" means B was true at some past time, and A has been true ever since
   - "A until B" means B will be true at some future time, and A is true until then
   ```

6. **Fix line 307**: Update imposition notation
   ```markdown
   **Imposition notation**: We write t ⊳_w w' ("imposing t on w yields w'") iff there exists maximal t-compatible part s ∈ w_t where s.t ⊑ w'.
   ```

7. **Fix lines 311-324**: Update Store/Recall section
   - Already uses v⃗, ensure a̅ is added to all clauses

8. **Fix line 352-354**: Update logical consequence definition
   ```markdown
   > Γ ⊨ A iff for any model M, world-history τ ∈ H_F, time x ∈ D, and assignment a̅: if M, τ, x, a̅, v⃗ ⊨ B for all B ∈ Γ, then M, τ, x, a̅, v⃗ ⊨ A
   ```

**Verification**:
- All truth conditions include M, τ, x, a̅, v⃗
- Lambda abstraction clause added
- Since uses ◁, Until uses ▷
- Imposition uses ⊳ instead of ▷
- Time domain restriction removed (x ∈ D, not x ∈ dom(τ))
- [FIX] tags at lines 219, 221, 227, 234-238, 240, 281, 283, 307, 313, 352 removed

---

### Phase 5: GLOSSARY.md Updates and Final Cleanup

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add lambda abstraction to GLOSSARY.md
2. Update Since/Until operator entries with new symbols
3. Remove all remaining [FIX] tags from RECURSIVE_SEMANTICS.md
4. Verify markdown rendering

**Files to modify**:
- `Documentation/Reference/GLOSSARY.md` - Extended Tense Operators section, new Lambda entry
- `Documentation/Research/RECURSIVE_SEMANTICS.md` - Final cleanup

**Steps**:

1. **Update GLOSSARY.md Extended Tense Operators** (around line 90):
   ```markdown
   ## Extended Tense Operators (Causal Layer)

   | Symbol | Name | Definition | Domain |
   |--------|------|------------|--------|
   | `◁` | Since | "A since B" (A has held since B was true) | Temporal reasoning |
   | `▷` | Until | "A until B" (A holds until B becomes true) | Temporal reasoning |
   ```

2. **Add Lambda Abstraction entry** to Constitutive Layer Concepts (around line 121):
   ```markdown
   | Lambda Abstraction | λx.A binds variable x in formula A; (λx.A)(t) substitutes t for x | Higher-order semantics |
   ```

3. **Add interpretation function entry** if not present:
   ```markdown
   | Interpretation Function | | | assigns meanings to non-logical vocabulary in a model | Semantic structure |
   ```

4. **Scan RECURSIVE_SEMANTICS.md** for any remaining [FIX] tags and remove them

5. **Verify markdown rendering** - ensure all tables and Unicode symbols display correctly

**Verification**:
- GLOSSARY.md updated with new entries
- No [FIX] tags remain in RECURSIVE_SEMANTICS.md
- Document renders correctly in markdown viewers
- Cross-references between documents are consistent

---

## Dependencies

- None external
- Phase 2 depends on Phase 1 (notation must be consistent)
- Phase 4 depends on Phase 3 (frame structure must be defined first)
- Phase 5 depends on all previous phases

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Unicode symbols don't render in some viewers | Low | Low | Use common Unicode, test in multiple viewers |
| Notation inconsistency between sections | Medium | Medium | Careful review after each phase |
| External LaTeX source misinterpreted | Medium | Low | Cross-reference original source during implementation |
| Breaking cross-references to GLOSSARY | Low | Low | Update GLOSSARY simultaneously |

## Success Criteria

- [ ] All 25 [FIX] tags removed from RECURSIVE_SEMANTICS.md
- [ ] Notation standardized: | | for interpretation, a̅ for assignments
- [ ] Lambda abstraction clauses added to both layers
- [ ] Containment and Maximality constraints incorporated
- [ ] Since (◁) and Until (▷) operators updated
- [ ] Time vector v⃗ in all Causal Layer clauses
- [ ] GLOSSARY.md updated with corresponding entries
- [ ] Document renders correctly in markdown

## Rollback Plan

If implementation introduces errors:
1. Revert to git commit before implementation started
2. Apply fixes incrementally with verification between phases
3. Use git diff to identify specific problematic changes
