# Proof Strategies Research Report

## Executive Summary

This report analyzes proof strategies for deriving P5 (`◇▽φ → △◇φ`) and P6 (`▽□φ → □△φ`) perpetuity theorems, plus the pairing combinator from K and S axioms. P5 is blocked by a missing S5 axiom (`◇φ → □◇φ`), which can be resolved by adding the axiom. P6 requires either P5 as a theorem or direct derivation from TF axiom. The pairing combinator is derivable but tedious, justifying axiomatization.

---

## Findings

### 1. P5 Derivation Strategy: Unblocking via S5 Axiom Addition

**Current Status**: P5 is axiomatized at Perpetuity.lean:859 due to blocked persistence lemma

**Blocking Issue** (Perpetuity.lean:764-828):
The persistence lemma `◇φ → △◇φ` is blocked at step "Need `◇φ → □◇φ` to connect the pieces" (line 821). This axiom is **NOT derivable** from current TM axioms.

**Analysis of Current Approach**:

The commented proof strategy in `persistence` lemma (Perpetuity.lean:799) shows:
```
1. MB axiom: φ → □◇φ (truths are necessarily possible)
2. TF axiom: □◇φ → F□◇φ (necessity persists to future)
3. TD (temporal duality): □◇φ → H□◇φ (necessity extends to past)
4. Identity: □◇φ → □◇φ
```

**The Gap**: We have `φ → □◇φ` but need to start from `◇φ`. The step `◇φ → □◇φ` is the **S5 Axiom 5** (possibility is necessarily possible).

**Why Current Axioms Don't Suffice**:
- `◇φ → φ` is FALSE (possibility doesn't imply truth)
- Cannot use MB axiom `φ → □◇φ` without first proving φ from ◇φ
- No axiom for `◇◇φ → □◇φ` pattern
- Modal necessitation only applies to theorems (⊢ φ), not to arbitrary ◇φ

**Proposed Solution**: Add S5 Axiom 5

**Axiom Addition** (to Axioms.lean):
```lean
| modal_5 (φ : Formula) :
    Axiom (Formula.diamond φ |>.imp (Formula.box (Formula.diamond φ)))
```

Semantic justification: Valid in task semantics due to S5 modal structure (Theorem 2.9, Corollary 2.11).

**Completed Persistence Proof Strategy** (after axiom addition):

1. **Start**: `◇φ` (assumption)
2. **Modal 5**: `◇φ → □◇φ` (new axiom)
3. **Apply**: Get `□◇φ`
4. **TF axiom**: `□◇φ → F□◇φ` (box_diamond_to_future_box_diamond)
5. **TD axiom**: `□◇φ → H□◇φ` (box_diamond_to_past_box_diamond)
6. **Identity**: `□◇φ → □◇φ`
7. **Combine**: `□◇φ → H□◇φ ∧ □◇φ ∧ F□◇φ` (combine_imp_conj_3)
8. **MT axiom**: `□◇φ → ◇φ` (applied three times to unbox each component)
9. **Compose**: `◇φ → H◇φ ∧ ◇φ ∧ G◇φ = △◇φ`

**Result**: `persistence` lemma proven, removing the sorry at line 827.

**P5 Derivation** (trivial once persistence is proven):
```lean
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  exact imp_trans (perpetuity_4 φ) (persistence φ)
```

**Effort Estimate**:
- Add axiom: 1 hour
- Prove soundness of modal_5: 2-4 hours (semantic argument)
- Complete persistence proof: 3-5 hours (follow outlined strategy)
- Derive P5: 1 hour (trivial composition)
- **Total: 7-11 hours**

### 2. P6 Derivation Strategy: Two Approaches

**Current Status**: P6 is axiomatized at Perpetuity.lean:926 due to P5 dependency

**Blocking Issues** (Perpetuity.lean:869-926):
1. P5 is axiomatized (blocked by persistence lemma)
2. Operator duality theorems are not definitionally equal

**Approach A: Derive P6 from P5 via Duality (Preferred)**

**Prerequisites**:
1. P5 must be a **proven theorem** (requires S5 axiom, see Finding 1)
2. Prove modal duality lemma: `◇(¬φ) ↔ ¬□φ`
3. Prove temporal duality lemma: `▽(¬φ) ↔ ¬△φ`

**Modal Duality Lemma Strategy**:

Goal: `◇(¬φ) ↔ ¬□φ`

Expanded: `(¬φ).neg.box.neg ↔ φ.box.neg`

**Forward direction** (`◇(¬φ) → ¬□φ`):
- Assume `◇(¬φ)` = `¬□¬(¬φ)` = `¬□φ` (by DNE inside box)
- Use `box_dne` lemma (Perpetuity.lean:630): From `□¬¬φ` derive `□φ`
- Contrapose: From `¬□φ` derive `¬□¬¬φ` = `◇(¬φ)`
- This direction is **definitional** after DNE simplification

**Backward direction** (`¬□φ → ◇(¬φ)`):
- Assume `¬□φ` (not necessary φ)
- Need to show `¬□¬(¬φ)` (not necessary that ¬φ)
- By DNI inside box: `□φ → □¬¬φ` (from dni axiom)
- Contrapose: `¬□¬¬φ → ¬□φ`
- This gives `◇(¬φ) → ¬□φ` (swap direction via contraposition)

**Implementation**:
```lean
theorem modal_duality_neg (φ : Formula) :
  ⊢ φ.neg.diamond.imp φ.box.neg := by
  -- Forward: ◇(¬φ) → ¬□φ
  sorry  -- 15-20 lines using DNE + contraposition

theorem modal_duality_neg_rev (φ : Formula) :
  ⊢ φ.box.neg.imp φ.neg.diamond := by
  -- Backward: ¬□φ → ◇(¬φ)
  sorry  -- 15-20 lines using DNI + contraposition
```

**Effort Estimate**: 4-6 hours per direction, **8-12 hours total** for modal duality

**Temporal Duality Lemma Strategy**:

Goal: `▽(¬φ) ↔ ¬△φ`

Expanded: `(¬φ).neg.always.neg ↔ φ.always.neg`

**Approach**: Similar to modal duality, using temporal K distribution instead of modal K

**Key Insight**: The formula definitions are:
- `always φ` = `φ.all_past.and (φ.and φ.all_future)`
- `sometimes φ` = `φ.neg.always.neg`

So `▽(¬φ)` = `¬△(¬φ)` = `¬(H(¬φ) ∧ (¬φ) ∧ G(¬φ))`

And `¬△φ` = `¬(Hφ ∧ φ ∧ Gφ)`

**Challenge**: These are **NOT** definitionally equal due to nested structure. Need to prove equivalence using:
- De Morgan's laws (distributed negation over conjunction)
- Temporal K distribution
- DNE/DNI on temporal operators

**Effort Estimate**: 4-6 hours per direction, **8-12 hours total** for temporal duality

**P6 Derivation from P5** (once dualities are proven):

```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- Apply P5 to ¬φ: ◇▽(¬φ) → △◇(¬φ)
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always :=
    perpetuity_5 φ.neg

  -- Apply modal duality: ◇(¬φ) ↔ ¬□φ
  have mod_dual : ⊢ φ.neg.diamond ↔ φ.box.neg := modal_duality_neg φ

  -- Apply temporal duality: ▽(¬φ) ↔ ¬△φ
  have temp_dual : ⊢ φ.neg.sometimes ↔ φ.always.neg := temporal_duality_neg φ

  -- Substitute dualities into P5(¬φ):
  -- ◇▽(¬φ) → △◇(¬φ)  becomes  ◇(¬△φ) → △(¬□φ)
  -- By modal duality: ¬□△φ → △(¬□φ)
  -- By temporal duality: ¬□△φ → ¬▽□φ (on right side)
  -- Contrapose: ▽□φ → □△φ

  sorry  -- 30-40 lines to thread through substitutions + contraposition
```

**Effort Estimate**: 6-8 hours (complex substitution and contraposition reasoning)

**Total Effort (Approach A)**:
- Modal duality: 8-12 hours
- Temporal duality: 8-12 hours
- P6 derivation: 6-8 hours
- **Total: 22-32 hours**

**Approach B: Direct Derivation from TF Axiom (Alternative)**

**Strategy**: Use TF axiom (`□φ → F□φ`) to show necessity persists

**Conceptual Proof**:
1. Assume `▽□φ` (necessity occurs at some time)
2. This means `∃t. □φ at t` (there exists a time where φ is necessary)
3. From TF: `□φ → F□φ` (necessity persists to future from that time)
4. Need temporal necessitation: "From □φ at t, derive G□φ globally"
5. This requires inference rules not in current TM system

**Blocking Issue**: No temporal necessitation rule. Current rules:
- Modal K: `Γ ⊢ φ` implies `□Γ ⊢ □φ`
- Temporal K: `Γ ⊢ φ` implies `FΓ ⊢ Fφ`
- Necessitation: `⊢ φ` implies `⊢ □φ` (empty context only)

**Missing Rule**: `⊢ φ → Fφ` implies `⊢ ◇φ → F◇φ` (lift temporal persistence to modal context)

**Assessment**: This approach is **more complex** than the P5-based approach and requires extending the proof system with new inference rules.

**Recommendation**: Use Approach A (P5 via duality) instead of Approach B (direct TF).

### 3. Pairing Combinator Derivation Strategy

**Current Status**: Axiomatized at Perpetuity.lean:174 with semantic justification

**Derivation Goal**: Prove `⊢ A → B → A ∧ B` from K and S axioms

**Combinator Construction**:

The pairing combinator is: `λa.λb.λf. f a b`

In combinator calculus: `S (S (K S) (S (K K) I)) (K I)` where `I = S K K`

**Expansion Strategy**:

```
I = S K K  (identity combinator)

Pairing a b f = f a b

Step 1: Build application combinator (applies function to two arguments)
  S (K S) (S (K K) I) a b f = K S a (S (K K) I a) b f
                             = S (S (K K) I a) b f
                             = S (K K) I a b (b f)
                             = K K a b (I b) f
                             = K b (I b) f
                             = b f

Step 2: Wrap with K I to fix second argument
  S (S (K S) (S (K K) I)) (K I) a b f
    = S (K S) (S (K K) I) a (K I a) b f
    = ... (complex reduction)
    = f a b  (after ~20-30 reduction steps)
```

**Implementation Challenges**:

1. **Length**: ~40-50 lines of combinator manipulation
2. **Readability**: Each step is a mechanical application of S/K definitions
3. **Verification**: Easy to make errors in deeply nested applications
4. **Insight**: Zero mathematical content beyond "this is how combinators work"

**Alternative: Semantic Justification** (current approach):

The pairing axiom is **semantically valid** in task semantics:
- If A holds at (M,τ,t) and B holds at (M,τ,t)
- Then A ∧ B = ¬(A → ¬B) holds
- Because assuming (A → ¬B) with A gives ¬B, contradicting B

**Recommendation**: Keep axiomatized. The derivation is:
- **Syntactically possible** but tedious
- **Semantically obvious** (conjunction introduction is a propositional tautology)
- **Low priority** for completing Layer 0 MVP

**Effort Estimate** (if derivation pursued): 8-12 hours (per TODO.md Task 21)

### 4. Alternative Approaches to Avoid S5 Axiom

**Analysis**: Can we derive P5 without adding the S5 axiom?

**Attempted Approach 1: Use MB and Modal Necessitation**

Goal: From MB (`φ → □◇φ`), derive `◇φ → □◇φ`

**Problem**: MB starts from φ (truth), not ◇φ (possibility)
- Cannot prove `◇φ → φ` (this is FALSE)
- Cannot apply necessitation to ◇φ (it's not a theorem)

**Verdict**: IMPOSSIBLE without additional axioms

**Attempted Approach 2: Use Temporal K with Modal Distribution**

Goal: Lift `◇φ` to `□◇φ` using temporal machinery

**Strategy**:
1. From ◇φ at time t
2. Use Temporal K: If `Γ ⊢ ◇φ`, then `FΓ ⊢ F◇φ`
3. Try to combine with modal axioms to get □◇φ

**Problem**: Temporal K requires `◇φ` to be **derivable** from context Γ, not just true at a time. The rule transforms the context (`Γ → FΓ`), not a formula truth value.

**Verdict**: IMPOSSIBLE - category error between semantic truth and syntactic derivability

**Attempted Approach 3: Strengthen MB Axiom**

Current MB: `φ → □◇φ` (truths are necessarily possible)

Hypothetical: `◇φ → □◇φ` (possibilities are necessarily possible)

**Analysis**: This IS the S5 Axiom 5. We've come full circle.

**Verdict**: This is equivalent to adding the S5 axiom, not avoiding it.

**Conclusion**: There is **no alternative** to adding the S5 axiom. The paper assumes S5 modal logic, and P5 requires S5-specific reasoning.

### 5. Proof Organization and Testing Strategy

**Recommended Proof Order**:

1. **Add S5 Axiom 5** (Axioms.lean)
   - Add constructor: `modal_5 (φ : Formula)`
   - Update axiom count in documentation
   - Effort: 1 hour

2. **Prove Soundness of Modal 5** (Soundness.lean)
   - Add validity lemma: `modal_5_valid`
   - Update soundness theorem to include modal_5 case
   - Effort: 2-4 hours

3. **Complete Persistence Lemma** (Perpetuity.lean:799)
   - Remove sorry at line 827
   - Implement strategy from Finding 1
   - Effort: 3-5 hours

4. **Derive P5** (Perpetuity.lean:859)
   - Replace axiom with theorem: `imp_trans (perpetuity_4 φ) (persistence φ)`
   - Effort: 1 hour

5. **Prove Modal Duality Lemma** (Perpetuity.lean, new)
   - Forward direction: `◇(¬φ) → ¬□φ`
   - Backward direction: `¬□φ → ◇(¬φ)`
   - Effort: 8-12 hours

6. **Prove Temporal Duality Lemma** (Perpetuity.lean, new)
   - Forward direction: `▽(¬φ) → ¬△φ`
   - Backward direction: `¬△φ → ▽(¬φ)`
   - Effort: 8-12 hours

7. **Derive P6** (Perpetuity.lean:926)
   - Replace axiom with theorem using P5 + duality lemmas
   - Effort: 6-8 hours

**Total Effort**: 29-43 hours (conservative estimate)

**Testing Strategy**:

1. **Unit Tests** (LogosTest/Core/Theorems/PerpetuityTest.lean):
   - Test modal_5 axiom instantiation
   - Test persistence lemma with concrete formulas
   - Test P5 with various φ (atoms, compound formulas, modal/temporal combinations)
   - Test modal/temporal duality lemmas both directions
   - Test P6 with concrete formulas

2. **Integration Tests** (LogosTest/Integration/):
   - Test perpetuity proof chains: P1 → P2, P3 → P4, P4 → P5, P5 → P6
   - Test interaction with modal axioms (T, 4, B, 5)
   - Test interaction with temporal axioms (4, A, L, MF, TF)

3. **Soundness Tests** (LogosTest/Core/Metalogic/SoundnessTest.lean):
   - Test validity of modal_5 in concrete task models
   - Test validity of P5 and P6 in concrete task models

**Test Coverage Target**: ≥90% (per Metalogic quality metrics in CLAUDE.md Section 8)

---

## Recommendations

### Recommendation 1: Adopt Phased Implementation Strategy

**Phase 1: S5 Axiom Addition and P5 Derivation** (8-12 hours)
- Add modal_5 axiom to Axioms.lean
- Prove soundness of modal_5 in Soundness.lean
- Complete persistence lemma in Perpetuity.lean
- Derive P5 from P4 + persistence
- Write unit tests for modal_5, persistence, P5

**Phase 2: Duality Lemmas** (16-24 hours)
- Prove modal duality lemma: `◇(¬φ) ↔ ¬□φ`
- Prove temporal duality lemma: `▽(¬φ) ↔ ¬△φ`
- Write unit tests for both directions

**Phase 3: P6 Derivation** (6-8 hours)
- Derive P6 from P5 using duality lemmas
- Write unit tests for P6
- Write integration tests for perpetuity proof chains

**Rationale**: Phasing allows intermediate milestones (P5 completion) before tackling complex duality proofs.

### Recommendation 2: Accept Pairing Axiom as Axiomatized

**Action**: Keep `pairing` axiom at Perpetuity.lean:174 with semantic justification

**Rationale**:
- Derivation is syntactically tedious (~40-50 lines)
- Semantic justification is clear (propositional tautology)
- Zero mathematical insight gained from derivation
- TODO.md marks as "SKIPPED - optional, low priority"
- Effort (8-12 hours) better spent on P5/P6 derivations

**Alternative**: If zero-axiom footprint required for publication, implement in Phase 4 (post-P6).

### Recommendation 3: Document S5 Modal Logic Assumption

**Action**: Update ARCHITECTURE.md and CLAUDE.md to explicitly state S5 assumption

**Content**:
- TM logic uses **S5 modal logic** for metaphysical necessity (□) and possibility (◇)
- S5 characteristics: reflexive, symmetric, transitive accessibility relation
- S5 axioms: T (□φ → φ), 4 (□φ → □□φ), B (φ → □◇φ), 5 (◇φ → □◇φ)
- Semantic justification: Task semantics has S5 modal structure (Theorem 2.9, Corollary 2.11)

**Rationale**: Clarifies design decisions and grounds axiom additions in paper's foundations.

### Recommendation 4: Consider Deferring P6 Duality Proof

**Action**: Evaluate effort/benefit of full P6 derivation vs. axiomatization

**Analysis**:
- P5 derivation: **High value** (removes blocking sorry, unifies perpetuity proofs)
- P6 derivation: **Lower priority** (requires complex duality proofs, P5 + axiom sufficient for MVP)

**Options**:
1. **Complete P6 derivation**: Full syntactic proof (29-43 hours total)
2. **Defer P6 derivation**: Accept P6 as axiom, document as future work (saves 16-24 hours)

**Recommendation**: Complete Phase 1 (P5 derivation), then reassess effort for Phases 2-3 based on:
- Remaining MVP priorities
- Publication requirements
- Formal certification needs

### Recommendation 5: Leverage Existing Propositional Machinery

**Action**: Reuse proven helper lemmas from Perpetuity.lean

**Available Helpers**:
- `imp_trans`: Transitivity of implication (line 85)
- `identity`: Identity combinator (line 109)
- `b_combinator`: Function composition (line 128)
- `contraposition`: Proven via B combinator (line 341)
- `combine_imp_conj`: Conjunction introduction (line 216)
- `box_conj_intro`: Boxed conjunction introduction (line 512)
- `box_dne`: DNE inside modal box (line 630)

**Benefit**: These lemmas form the **propositional foundation** for duality proofs. Extensive reuse reduces implementation time.

**Example**: Modal duality proof will use:
- `contraposition` for `¬□φ → ¬□¬¬φ`
- `box_dne` for `□¬¬φ → □φ`
- `imp_trans` for composing intermediate steps

---

## Summary

**P5 Derivation**: Straightforward once S5 axiom added (8-12 hours total)
- **Blocker**: Missing `◇φ → □◇φ` axiom
- **Solution**: Add modal_5 axiom to Axioms.lean
- **Effort**: Manageable with clear path forward

**P6 Derivation**: Complex due to duality requirements (22-32 hours after P5)
- **Approach A** (preferred): Derive from P5 via modal/temporal duality lemmas
- **Approach B** (alternative): Direct from TF axiom (blocked by missing inference rules)
- **Deferral Option**: Accept as axiom for MVP, document as future work

**Pairing Combinator**: Keep axiomatized
- **Derivation**: Syntactically possible but tedious (8-12 hours)
- **Justification**: Semantically valid, low priority for MVP

**Recommended Path**:
1. Phase 1: Complete P5 derivation (8-12 hours) ← **HIGH PRIORITY**
2. Phase 2-3: Attempt P6 derivation (22-32 hours) ← **MEDIUM PRIORITY**
3. Pairing derivation: Defer unless required ← **LOW PRIORITY**

**Total Effort Range**: 8-12 hours (P5 only) to 52-56 hours (P5 + P6 + pairing)
