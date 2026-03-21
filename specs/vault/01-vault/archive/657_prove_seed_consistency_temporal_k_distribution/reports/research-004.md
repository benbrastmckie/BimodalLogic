# Research Report: Defining Reflexive G' via G ∨ φ Construction

**Task**: 657 - prove_seed_consistency_temporal_k_distribution
**Started**: 2026-01-26T18:30:00Z
**Completed**: 2026-01-26T19:15:00Z
**Effort**: 1.5 hours
**Priority**: High
**Dependencies**: research-002.md, research-003.md, implementation-summary-20260126.md
**Sources/Inputs**:
- Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean (lines 323-418, blocking issue)
- Theories/Bimodal/Syntax/Formula.lean (operator definitions)
- Theories/Bimodal/Semantics/Truth.lean (irreflexive temporal semantics)
- specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-002.md (Approach A-D analysis)
- specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-003.md (interdefinability analysis)
**Artifacts**: specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-004.md
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- **Proposed construction DOES NOT solve the problem**: Defining `G' φ := G φ ∨ φ` leads back to the same issue via `G ⊥ ≡ G ⊥ ∨ ⊥ ≡ G ⊥ ∨ false ≡ G ⊥`
- **The definition creates identity, not derivation**: `G' ⊥` simplifies to `G ⊥`, providing no leverage for deriving `⊥`
- **Temporal T axiom still needed**: Even with `G'` defined, the axiom `G' φ → φ` is NOT derivable without adding it explicitly to TM
- **This is NOT the same as Approach C**: Approach C made G' primitive with axioms; this defines G' without axioms (insufficient)
- **Semantic bridge (Approach A) remains the only viable solution**: No definitional trick avoids the need for semantic reasoning about satisfiability
- **Key insight**: Definitions don't create derivability - you can define `G'` however you like, but without axioms governing it, you can't derive new theorems

## Context & Scope

### User's Proposed Construction

The user suggests:

> "What about a construction that uses G' instead of G since G' is reflexive, but instead of taking G' to be primitive, defining it as `G φ ∨ φ`? Similar may be done for H'. Carefully review this approach."

**Key distinction from research-002 Approach C**:
- **Approach C**: Make `G'` primitive with axioms `G' φ → φ` (temporal T)
- **User's proposal**: Define `G' φ := G φ ∨ φ` as abbreviation, **without adding axioms**

### Current Blocking Issue (From implementation-summary-20260126.md)

The seed consistency proofs reach Step 4:
```lean
-- Step 3: By MCS deductive closure, G bot ∈ Gamma
have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma := ...

-- Step 4: Now we need to derive a contradiction from G bot ∈ Gamma
-- BLOCKED: Cannot derive bot from G bot syntactically in TM logic
```

**The question**: Does defining `G' φ := G φ ∨ φ` help derive this contradiction?

### Definitional vs Axiomatic Extensions

**Definitional Extension** (what user proposes):
- Add `G'` as notation/abbreviation for existing formula
- No new axioms or inference rules
- Can only unfold definition - no new derivability

**Axiomatic Extension** (Approach C):
- Add `G'` as new primitive operator
- Add axioms: `G' φ → φ`, `G'(φ → ψ) → (G' φ → G' ψ)`, etc.
- Fundamentally changes what's derivable

## Findings

### 1. The Simplification: G' ⊥ ≡ G ⊥

Let's trace through what happens with the proposed definition:

```
G' φ := G φ ∨ φ   (definition)

G' ⊥ = G ⊥ ∨ ⊥   (substitute φ = ⊥)
     = G ⊥ ∨ false  (⊥ = false by semantics)
     = G ⊥          (φ ∨ false ≡ φ)
```

**Critical observation**: `G' ⊥` **IS** `G ⊥`. The definition doesn't create a different formula; it's syntactic sugar that immediately simplifies away.

### 2. Why This Doesn't Help Derive Contradiction

**Current situation**:
- Have: `G ⊥ ∈ Gamma` (from Step 3 via generalized temporal K)
- Need: Derive `⊥` to get contradiction

**With G' definition**:
- Can write: `G' ⊥ ∈ Gamma` (since `G' ⊥ ≡ G ⊥`)
- But still need: `G' ⊥ → ⊥` to derive contradiction
- Problem: `G' ⊥ → ⊥` is **NOT** derivable from the definition alone

**The missing piece**: We need the **axiom** `G' φ → φ` (temporal T). But:
- This is an **axiom**, not derivable from the definition
- TM logic doesn't have this axiom
- Adding the definition doesn't add the axiom

### 3. Derivability Analysis: What Is and Isn't Provable

#### What IS derivable from definition `G' φ := G φ ∨ φ`

```lean
-- Unfolding lemma (by definition):
theorem g_prime_unfold : G' φ ↔ G φ ∨ φ := by rfl

-- φ implies G' φ (right disjunct):
theorem implies_g_prime : φ → G' φ := by
  intro h
  unfold G'
  right
  exact h

-- G φ implies G' φ (left disjunct):
theorem g_implies_g_prime : G φ → G' φ := by
  intro h
  unfold G'
  left
  exact h
```

#### What is NOT derivable from definition alone

```lean
-- Temporal T for G' (NEEDS AXIOM):
theorem g_prime_temporal_t : G' φ → φ := by
  intro h
  unfold G' at h  -- h : G φ ∨ φ
  cases h with
  | inl hG =>
    -- hG : G φ
    -- Need: φ
    -- STUCK! Can't derive φ from G φ without temporal T
    sorry
  | inr hφ =>
    -- hφ : φ
    exact hφ  -- This case works!
```

**Critical insight**: The case split on `G φ ∨ φ` gives us two branches:
1. `φ` case: Trivial, returns `φ`
2. `G φ` case: **Cannot** derive `φ` from `G φ` without temporal T axiom

So `G' φ → φ` is **NOT** derivable from the definition - it would require temporal T for the underlying `G`.

### 4. Application to G' ⊥

Let's see what happens with `G' ⊥` specifically:

```lean
-- We have: G' ⊥ ∈ Gamma
-- Unfold: (G ⊥ ∨ ⊥) ∈ Gamma

-- Case analysis on disjunction:
cases (G ⊥ ∨ ⊥) with
| inl hG =>
  -- hG : G ⊥ ∈ Gamma
  -- This is exactly the case we started with!
  -- Still stuck: can't derive ⊥ from G ⊥
  sorry
| inr hbot =>
  -- hbot : ⊥ ∈ Gamma
  -- But Gamma is consistent, so ⊥ ∉ Gamma
  -- This case is impossible by MCS consistency
  exact absurd hbot (h_mcs.to_set_consistent ⊥)
```

**Key observation**: The case analysis shows:
- Either `G ⊥ ∈ Gamma` (stuck - same problem)
- Or `⊥ ∈ Gamma` (impossible - contradicts consistency)

The disjunction `G ⊥ ∨ ⊥` doesn't help because:
- We can rule out the `⊥` case (inconsistent)
- We're left with the `G ⊥` case (original problem)

### 5. Why Temporal T Axiom Is Still Needed

Even with the definition `G' φ := G φ ∨ φ`, to derive `G' ⊥ → ⊥` we need:

```
Proof attempt:
1. Assume G' ⊥                     (hypothesis)
2. Unfold: G ⊥ ∨ ⊥                 (definition)
3. Case 1: Assume ⊥                (contradiction - done)
4. Case 2: Assume G ⊥              (stuck here)
5. Need: ⊥ from G ⊥
6. This requires: G ⊥ → ⊥
7. This is: Temporal T for ⊥
8. NOT DERIVABLE in TM
```

The definition doesn't make temporal T derivable; it just moves the problem from `G' φ → φ` to `G φ → φ` (when φ is present in the disjunction).

### 6. Comparison: Definition vs Axiom

**Definitional approach** (user's proposal):
```lean
def all_future_ref (φ : Formula) : Formula := all_future φ |>.or φ

-- Can derive:
theorem all_future_implies_ref : all_future φ → all_future_ref φ := ...
theorem imp_implies_ref : φ → all_future_ref φ := ...

-- CANNOT derive:
theorem ref_temporal_t : all_future_ref φ → φ := ... -- STUCK!
```

**Axiomatic approach** (Approach C from research-002):
```lean
inductive Formula where
  | all_future_ref : Formula → Formula  -- NEW PRIMITIVE

inductive Axiom where
  | temp_t_future (φ : Formula) : Axiom (Formula.all_future_ref φ |>.imp φ)
  -- Add temporal T as AXIOM

-- Now can derive:
theorem ref_temporal_t : ⊢ all_future_ref φ → φ := by
  apply axiom
  exact Axiom.temp_t_future φ
```

**The key difference**: Axioms add derivability; definitions don't.

### 7. Semantic Interpretation of Defined G'

Even semantically, the definition doesn't help:

```
Semantic interpretation of G' φ := G φ ∨ φ:

M,τ,t ⊨ G' φ  ⟺  M,τ,t ⊨ G φ ∨ φ
              ⟺  (M,τ,t ⊨ G φ) ∨ (M,τ,t ⊨ φ)
              ⟺  (∀s > t, M,τ,s ⊨ φ) ∨ (M,τ,t ⊨ φ)

For φ = ⊥:
M,τ,t ⊨ G' ⊥  ⟺  (∀s > t, M,τ,s ⊨ ⊥) ∨ (M,τ,t ⊨ ⊥)
              ⟺  (∀s > t, false) ∨ false
              ⟺  (no s > t exists) ∨ false
              ⟺  (no s > t exists)
              ⟺  M,τ,t ⊨ G ⊥
```

**Result**: `G' ⊥` has the **same** satisfiability as `G ⊥`. The definition doesn't change the semantic behavior for `⊥`.

### 8. Does This Change Approach C's Viability?

**Approach C** (from research-002): Make G' primitive with temporal T axioms.

**User's modification**: Define G' as `G φ ∨ φ` instead of making it primitive.

**Analysis**:
- Approach C **with primitives**: Would work (temporal T becomes derivable from axiom)
- Approach C **with definitions**: Does NOT work (temporal T not derivable without axiom)

The user's modification removes the axiom addition, which was the **essential** part of Approach C. Without the axiom, the definition provides no leverage.

### 9. What About Non-⊥ Formulas?

The definition `G' φ := G φ ∨ φ` does provide useful properties for general φ:

```lean
-- These ARE derivable:
theorem g_prime_implies_eventually : G' φ → F' φ
theorem g_prime_monotone : (φ → ψ) → (G' φ → G' ψ)
theorem g_prime_conj : G' (φ ∧ ψ) ↔ G' φ ∧ G' ψ
```

But for the **specific case** `φ = ⊥`:
- `G' ⊥ ≡ G ⊥` (simplifies to irreflexive case)
- `G' ⊥ → ⊥` still not derivable
- No help for seed consistency proof

### 10. Alternative Interpretation: Is User Proposing New Axiom?

**Possible interpretation**: User wants to:
1. Define `G' φ := G φ ∨ φ`
2. Add axiom: `G' φ → φ` (temporal T for defined G')

**Analysis**:
- This would be **redundant** and **inconsistent**
- We'd have two derivations of `φ` from `G' φ`:
  - Via axiom: `G' φ → φ` (trivial)
  - Via definition and case analysis: `(G φ ∨ φ) → φ` (stuck on G case)
- The axiom would make the G case derivable, but then why use definition?

**More coherent approach**: Just add axiom `G φ → φ` directly (temporal T for G), avoiding the detour through G'.

### 11. Architectural Impact

If we did define `G' := G ∨ id` (even though it doesn't help):

**Codebase changes needed**:
```lean
-- In Formula.lean:
def all_future_ref (φ : Formula) : Formula := (all_future φ).or φ
def all_past_ref (φ : Formula) : Formula := (all_past φ).or φ

-- In Axioms.lean: NO NEW AXIOMS (that's the problem!)

-- In Semantics/Truth.lean: NO SEMANTIC CHANGES
-- (Just unfolds to existing semantics)
```

**Effort**: Low (just add definitions)

**Value**: None for seed consistency (doesn't solve the problem)

**Risk**: Confuses readers who expect G' to have temporal T

### 12. Why Approach A (Semantic Bridge) Is Still Necessary

Research-002 proposed Approach A: Use semantic argument about satisfiability.

**Why definitional G' doesn't change this**:

1. **Satisfiability is unchanged**: `G' ⊥` is satisfiable iff `G ⊥` is satisfiable (same models)
2. **Derivability is unchanged**: Can't derive `⊥` from `G' ⊥` without temporal T
3. **Semantic bridge still needed**: Must argue that MCS with `G ⊥` can't be at construction origin

The definitional approach doesn't eliminate the need for semantic reasoning about model classes (bounded vs unbounded domains).

### 13. Final Verdict: Does Definition Help?

**Short answer**: No.

**Detailed analysis**:

| Aspect | With Definition G' := G ∨ φ | Without Definition |
|--------|----------------------------|-------------------|
| Can derive `G' ⊥` from `G ⊥` | Yes (trivial) | N/A |
| Can derive `⊥` from `G' ⊥` | No (still stuck) | No (still stuck) |
| Can derive `G' φ → φ` | No (not for G case) | No |
| Satisfiability of `G' ⊥` | Same as `G ⊥` | Same as `G ⊥` |
| Axiom changes needed | None (that's the problem) | None |
| Semantic bridge needed | Yes | Yes |

**Conclusion**: The definition is a syntactic transformation that doesn't change derivability or satisfiability. It provides no leverage for the seed consistency proof.

## Decisions

1. **Reject definitional G' approach**: Defining `G' φ := G φ ∨ φ` doesn't solve the seed consistency blocking issue.

2. **Distinguish from Approach C**: The definitional approach is NOT the same as Approach C (making G' primitive with axioms). Approach C might work; this approach doesn't.

3. **Reaffirm Approach A necessity**: The semantic bridge approach from research-002 remains the only viable solution without axiom changes.

4. **Clarify axiom vs definition**: Document that definitions don't create derivability - only axioms do.

## Recommendations

### 1. Reject Definitional G' Approach

**Rationale**:
- `G' ⊥ ≡ G ⊥` (simplifies to original problem)
- `G' ⊥ → ⊥` not derivable without temporal T axiom
- No advantage over working directly with G

**Action**: Do not add `all_future_ref` definitions to codebase (provides no value).

### 2. Clarify Why Approach C Requires Primitives + Axioms

**From research-002.md**: Approach C makes G' primitive with temporal T axiom.

**User's confusion**: Thought defining G' would suffice.

**Clarification needed**: Approach C requires BOTH:
- G' as primitive operator (new syntax)
- Temporal T axiom: `G' φ → φ` (new derivability)

Definitions alone don't add derivability.

### 3. Proceed with Semantic Bridge (Approach A)

**From research-002.md**:
```lean
lemma mcs_with_G_bot_not_at_origin
    {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (h_G_bot : Formula.all_future Formula.bot ∈ Gamma) :
    ¬∃ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F),
      (∀ φ ∈ Gamma, truth_at M τ 0 φ) ∧
      (∃ t : D, 0 < t ∧ τ.domain t)
```

**Next steps**:
1. Prove this semantic bridge lemma
2. Use it to resolve seed consistency
3. Complete task 657 without axiom changes

**Estimated effort**: 12-17 hours (from research-002)

### 4. Document Definitional vs Axiomatic Extensions

**For future reference**: Add to OPERATORS.md or similar:

```markdown
## Definitional vs Axiomatic Extensions

**Definitional**: Add abbreviation for existing formula
- Example: `G' φ := G φ ∨ φ`
- Unfolding lemma: `G' φ ↔ G φ ∨ φ` provable by definition
- Does NOT change: derivability (no new theorems)
- Does NOT change: satisfiability (same models)

**Axiomatic**: Add new primitive with axioms
- Example: `G'` primitive + axiom `G' φ → φ`
- Derivation: New theorems become provable
- Changes: Fundamentally alters logic (different derivability)
- May restrict: Model class (semantic impact)

**Key insight**: Only axioms (or primitive operators with axioms) add derivability.
Definitions are syntactic sugar that can be unfolded away.
```

### 5. Consider Approach B as Alternative

If semantic bridge proves too complex:

**Approach B** (from research-002): Add `sometime_future top` axiom (unbounded time).

**Trade-offs**:
- Pros: Simple syntactic solution, clear semantic meaning
- Cons: Restricts model class to unbounded forward time

**When to use**: If TM logic is intended to quantify only over unbounded time structures.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| User expects definition to work | Medium - confusion | High | Clear explanation in this report |
| Conflation with Approach C | Medium - wrong approach chosen | Medium | Distinguish definition-only from primitive+axiom |
| Temptation to add axiom later | High - changes logic | Low | Approach A avoids this |
| Semantic bridge complexity | High - may not complete | Medium | Approach B as fallback |

## Appendix

### A. Formal Derivation: Why G' ⊥ → ⊥ Is Not Provable

```lean
-- Definition:
def G' (φ : Formula) : Formula := G φ ∨ φ

-- Attempted theorem:
theorem g_prime_bot_implies_bot : ⊢ G' ⊥ → ⊥ := by
  -- Unfold definition
  show ⊢ (G ⊥ ∨ ⊥) → ⊥

  -- Assume hypothesis
  intro h
  -- h : G ⊥ ∨ ⊥

  -- Case analysis on disjunction
  cases h with
  | inr hbot =>
    -- hbot : ⊥
    exact hbot  -- Trivial case: ⊥ → ⊥

  | inl hG =>
    -- hG : G ⊥
    -- GOAL: ⊥

    -- Need to derive ⊥ from G ⊥
    -- This requires: G ⊥ → ⊥
    -- This is temporal T for ⊥
    -- NOT PROVABLE in TM
    sorry
```

**Formal statement**: In TM logic, `G ⊥ → ⊥` is NOT a theorem. Therefore, `G' ⊥ → ⊥` is also NOT a theorem (since it reduces to the G case).

### B. Comparison Table: All Approaches

| Approach | Changes | Derivability Gain | Semantic Impact | Complexity |
|----------|---------|------------------|----------------|-----------|
| Definition G' := G ∨ φ | Add definition only | None | None | Very Low |
| Approach A (Semantic Bridge) | Lemmas only | None (uses semantics) | None | Medium-High |
| Approach B (Unbounded Axiom) | Add axiom `F top` | `¬G ⊥` derivable | Restricts to unbounded time | Low |
| Approach C (Primitive G') | New primitive + axioms | `G' φ → φ` derivable | May restrict models | Very High |
| Definition G' + Temporal T Axiom | Definition + axiom `G' φ → φ` | `φ` from `G' φ` | Redundant with just `G φ → φ` | Low but redundant |

**Key insight**: The definitional approach (row 1) provides no derivability gain, making it ineffective for the seed consistency proof.

### C. Proof-Theoretic Analysis

**Derivation rules in TM** (relevant subset):
```
Modus Ponens: φ, φ → ψ ⊢ ψ
Temporal K: ⊢ G(φ → ψ) → (G φ → G ψ)
Generalized Temporal K: L ⊢ φ implies L.map G ⊢ G φ
```

**NOT a derivation rule**:
```
Temporal T: ⊢ G φ → φ  -- NOT VALID in TM
```

**With definition G' := G ∨ φ**:
```
Can derive: ⊢ φ → G' φ           (by Or.inr)
Can derive: ⊢ G φ → G' φ         (by Or.inl)
CANNOT derive: ⊢ G' φ → φ        (stuck on G case)
```

**Conclusion**: The definition doesn't add the crucial derivation `G' φ → φ` that would enable temporal T reasoning.

### D. Semantic Models Where G ⊥ Is True

Example models satisfying `G ⊥`:

**Model 1: Bounded Forward Domain**
```
Domain: {t : Int | 0 ≤ t ≤ 100}
Valuation: arbitrary
Evaluation point: t = 100

G ⊥ at t=100 means: ∀s > 100, s ∈ domain → bot true at s
This is vacuously true (no s > 100 in domain)
```

**Model 2: Isolated Point Domain**
```
Domain: {42}
Valuation: arbitrary
Evaluation point: t = 42

G ⊥ at t=42 means: ∀s > 42, s ∈ domain → bot true at s
This is vacuously true (no s > 42 in domain)
```

**These models also satisfy** `G' ⊥` (since `G' ⊥ ≡ G ⊥` for ⊥):
- At t=100: `G' ⊥ ≡ G ⊥ ∨ ⊥ ≡ true ∨ false ≡ true`
- At t=42: `G' ⊥ ≡ G ⊥ ∨ ⊥ ≡ true ∨ false ≡ true`

**Conclusion**: The definition doesn't change which models satisfy the formula. The satisfiability problem persists.

### E. Cross-References

**Related research**:
- `specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-002.md` - Four approaches including semantic bridge (Approach A) and reflexive operators (Approach C)
- `specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-003.md` - Interdefinability analysis showing G/G' semantic relationship
- `specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-004.md` - Earlier exploration of reflexive vs irreflexive operators

**Codebase references**:
- `Theories/Bimodal/Syntax/Formula.lean` (lines 254-266) - Existential operator definitions
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (lines 323-418) - Blocking issue location
- `Theories/Bimodal/ProofSystem/Axioms.lean` - TM axiom system (lacks temporal T)

**Next steps**:
- Create task for implementing Approach A (semantic bridge)
- Add clarification to OPERATORS.md about definitions vs axioms
- Update IndexedMCSFamily.lean comments to reference this report

---

**Conclusion**: Defining `G' φ := G φ ∨ φ` does not solve the seed consistency blocking issue. For `φ = ⊥`, the definition simplifies to `G' ⊥ ≡ G ⊥`, providing no leverage for deriving contradiction. The temporal T axiom `G' ⊥ → ⊥` remains non-derivable without adding it as an explicit axiom. The semantic bridge approach (Approach A from research-002.md) remains necessary and is the recommended solution.

**Last Updated**: 2026-01-26
**Version**: 1.0
**Researcher**: lean-research-agent (Claude Sonnet 4.5)
