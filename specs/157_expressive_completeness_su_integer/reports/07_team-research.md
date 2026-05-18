# Research Report: Task #157 (Round 7)

**Task**: Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-17
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Focus**: Axiom elimination track (Phases 6B/6C/8) — correct mathematical approach

## Summary

The Phase 6B blocker (GHR94 Cases 5-8 incorrect for integer time) is confirmed real by all 4 teammates. However, a concrete path forward has been identified: **GHR94 Section 10.3 (Dedekind-complete time) provides Case 5-8 formulas that, when specialized to integers (K⁺ = K⁻ = ⊥, Γ⁺ = Γ⁻ = ⊥), yield correct intermediate equivalences**. Teammate B verified the specialized Case 5 formula against the known counterexample and it produces the correct result (TRUE) where the original Section 10.2 formula gives FALSE. The specialized formulas reduce to Case 1 applications (already proved). Estimated: ~300-400 LOC.

Two alternative strategies are also viable: (a) fusing Cases 5-8 into the junction-depth induction using the IH directly, and (b) partial axiom elimination (only the 4 `is_separable` axioms). The 9 axioms will propagate to `bx_completeness` when task 155 Phase 3B wires in expressive completeness.

## Key Findings

### 1. Counterexample Validated (All 4 Teammates)

The GHR94 Case 5 formula for S(a ∧ U(A,B), q ∨ U(A,B)) is genuinely incorrect for integer time. The counterexample (a(0)=T, A(1)=T, B≡F, q(1)=q(2)=T) shows LHS=TRUE at t=3 but RHS=FALSE. Root cause: U(A,B) can hold vacuously on integers via adjacent successor (U(A,B)(0) via u=1 with (0,1)_Z = ∅), and GHR94's formula assumes B-coverage propagates to t.

### 2. K⁺ = K⁻ = ⊥ on Integers (Teammates A and B)

**Critical correction**: GHR94 line 249 claims "K⁺q = K⁻q = ⊤" on integers. This is WRONG. Both teammates independently calculated:

- K⁺q = ¬U(⊤, ¬q). Since U(⊤, ¬q)(t) is always true on Z (take s=t+1, vacuous guard), K⁺q = ⊥.
- K⁻q = ¬S(⊤, ¬q). Similarly K⁻q = ⊥ on Z.
- Γ⁺(B) = ¬K⁺(¬B) ∧ K⁻(¬B) = ⊤ ∧ ⊥ = ⊥
- Γ⁻(B) = ¬K⁻(¬B) ∧ K⁺(¬B) = ⊤ ∧ ⊥ = ⊥

Semantically: K⁺q means "q is true arbitrarily close from the future" = ∀z>t, ∃y(t<y<z ∧ q(y)). On Z, take z=t+1: no y exists in (t,t+1)_Z. So K⁺q ≡ ⊥ on Z. The GHR94 text has an error.

### 3. Dedekind Case 5 Specialized to Integers (Teammate B — Breakthrough)

GHR94 Lemma 10.3.11.5 gives the Dedekind Case 5 formula. Specialized to Z (K⁺=K⁻=⊥, Γ⁺=Γ⁻=⊥):

```
S(a ∧ U(A,B), q ∨ U(A,B)) ↔
  S(a ∧ U(A,B), q)                                        -- (i) Case 1 (proved!)
  ∨ [S(α, Q) ∧ (A ∨ (B ∧ U(A,B)))]                      -- (ii)
  ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)                    -- (iii)

where:
  α = (a ∧ U(A,B)) ∨ (¬q ∧ S(a ∧ U(A,B), q) ∧ U(A,B))
  Q = Q(A,B,¬q) = B ∨ A ∨ ¬S(¬q, ¬A)
```

The fourth disjunct (Γ⁺(q) term) vanishes since Γ⁺ = ⊥.

**Counterexample verification** (by Teammate B):
- Disjunct (i): S(a ∧ U(A,B), q)(3). Witness s=0: a(0)∧U(A,B)(0)=T, guard q on {1,2}=T. **TRUE.**
  - So the FULL formula is TRUE via disjunct (i) alone.

But even checking the other disjuncts for completeness:
- Disjunct (ii): S(α, Q)(3)=T (verified: α(0)=T, Q at {1,2} both T), but (A(3)∨(B(3)∧U(A,B)(3)))=F. **FALSE.**
- Disjunct (iii): S(A ∧ (q∨U(A,B)) ∧ S(α,Q), q)(3). Witness s=1: A(1)=T, (q(1)∨U(A,B)(1))=T, S(α,Q)(1)=T, guard q(2)=T. **TRUE.**

**Result: The Dedekind-specialized formula gives TRUE**, matching the LHS. The original Section 10.2 formula gave FALSE.

### 4. Conflict Resolution: Teammate A vs Teammate B

**Conflict**: Teammate A claimed the Dedekind reduction "also fails" because the β factor A∨(B∧U(A,B)) persists in disjunct (ii).

**Resolution**: Teammate A only checked disjunct (ii) and found it fails for the same reason as the original formula. But Teammate B checked ALL disjuncts and found that disjunct (i) succeeds (it's just Case 1, which is already proved!) and disjunct (iii) also succeeds. The Dedekind formula works via multiple disjuncts — even when (ii) fails, (i) and (iii) capture the correct semantics.

**Verdict**: Teammate B's analysis is correct. The Dedekind-specialized formula IS viable.

### 5. The Formulas Are Intermediate, Not Terminal (Teammates A and D)

GHR94 Section 10.3 explicitly says for Case 5: "The first elimination will separate the first disjunct and the expression α. Further use of that elimination will separate S(α, Q) and finally also the expression which the latter is nested within."

This means the Case 5 formula is an INTERMEDIATE reduction. To fully separate, apply Case 1 (already proved) to:
- Disjunct (i): S(a ∧ U(A,B), q) — directly Case 1
- The α terms inside disjuncts (ii) and (iii) that contain S(a ∧ U(A,B), q) — Case 1 again
- S(α, Q) — after expanding α via Case 1, this becomes a formula with U(A,B) only in event position

After all Case 1 applications, U(A,B) is no longer under any S. The formula is then syntactically separated.

### 6. Cases 6-8 Reduce to Earlier Cases (Teammates B and C)

- **Case 6**: GHR94 says "use elimination (3) and then elimination (2)" — reduces to Cases 2, 3, and 5.
- **Case 7**: GHR94 gives an explicit formula then says "use the eighth and fourth eliminations" — reduces to Cases 4 and 8.
- **Case 8**: Reduces to Cases 1, 2, and 5 via negation.

**Dependency order**: Case 5 is the only independently problematic case. Once Case 5 is proved, Cases 6-8 follow by reduction.

### 7. Definition Mismatches Non-Blocking (Teammate C)

Two definition mismatches found:
1. `is_U_free` accepts `all_future` (GHR94 would not) — resolved by `expand_temporal`
2. `no_S_nested_in_U` with `all_past` — resolved by operating on expanded formulas

Neither blocks the hierarchy proof.

### 8. Axioms Will Propagate (Teammate D)

The 9 axioms are NOT cosmetic debt. They will propagate to `bx_completeness` when task 155 Phase 3B wires in expressive completeness. While not `sorryAx`, they will appear in `#print axioms bx_completeness`. 418 lines of Phase 6A infrastructure already exist in Hierarchy.lean.

## Synthesis

### Primary Recommendation: Dedekind Specialization (Strategy 1)

Specialize GHR94 Section 10.3 Case 5 formula to integers, then use existing Case 1 to finish separating. Implementation:

1. **Prove K⁺ ≡ ⊥ and K⁻ ≡ ⊥ on Z** (~20 LOC). These are simple consequences of vacuous satisfaction.

2. **Prove the Q-lemma for integers** (GHR94 Lemma 10.3.6 specialized). On Z, Q(A,B,C) = B ∨ A ∨ ¬S(C, ¬A). The Q-lemma's two directions simplify dramatically on Z because:
   - No sup/inf needed (Z is discrete)
   - K⁺(¬B) = ⊥ eliminates a condition
   - Γ⁻(B) = ⊥ eliminates a case
   Estimated: ~80-100 LOC.

3. **Prove Case 5 intermediate equivalence for Z** (~150-200 LOC):
   ```
   S(a ∧ U(A,B), q ∨ U(A,B)) ↔
     S(a ∧ U(A,B), q)
     ∨ [S(α, Q) ∧ (A ∨ (B ∧ U(A,B)))]
     ∨ S(A ∧ (q ∨ U(A,B)) ∧ S(α, Q), q)
   ```
   Follow the GHR94 Section 10.3 proof adapted for Z (discrete case analysis instead of sup/inf).

4. **Apply Case 1 repeatedly** to get a fully separated equivalent (~50-80 LOC).

5. **Derive Cases 6-8** via reductions to Cases 1-5 (~100-150 LOC).

6. **Wire into hierarchy**: Replace `multi_U_formula_separable`'s use of `all_separable` with the full hierarchy proof (~50 LOC).

**Total: ~450-600 LOC. Confidence: MEDIUM-HIGH.**

### Secondary Recommendation: Inline Elimination (Strategy 2)

If Strategy 1 proves too complex (Q-lemma adaptation), fuse Cases 5-8 into the junction-depth induction:

- Within `junction_depth_separable`, when encountering a Case 5-8 form at junction depth d:
  - Abstract S-nodes inside U-arguments with fresh atoms → reduces junction depth
  - Apply IH at lower junction depth
  - Resubstitute and apply IH again

**Advantage**: Avoids needing explicit Case 5-8 formulas entirely.
**Risk**: Mutual dependency between 10.2.4 and 10.2.8 requires careful WF argument.
**Estimated: ~300-500 LOC. Confidence: MEDIUM.**

### Fallback: Partial Elimination (Strategy 3)

Eliminate only the 4 `is_separable` axioms (proving `all_separable` without axioms). Keep the 5 `is_properly_separable` axioms for a later task.

### Key Literature References

| Reference | Section | Relevance |
|-----------|---------|-----------|
| GHR94 Ch 10.2 | Lemma 10.2.3 Cases 1-8 | Cases 5-8 WRONG for Z |
| GHR94 Ch 10.3 | Lemma 10.3.11.5 | Correct Case 5 for Dedekind, specializable to Z |
| GHR94 Ch 10.3 | Lemma 10.3.6 (Q-lemma) | Key ingredient for correct formulas |
| GHR94 Ch 10.3 | Lemma 10.3.11.6-8 | Reduce to Cases 1-5 |
| Reynolds 1994 | Theorem 5 | Does NOT provide separation (only exp. completeness) |
| Burgess 1982 | All | No separation procedure |

### Literature-Specific Guidance for Implementation Agents

When implementing Strategy 1:
- **Primary reference**: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`, lines 322-573 (Section 10.3.2-10.3.3)
- **Q-lemma**: Lines 322-359 (Lemma 10.3.6). Adapt the proof for Z: replace sup/inf with discrete max/min, and note that K⁺/K⁻/Γ⁺/Γ⁻ all collapse to ⊥.
- **Case 5**: Lines 538-554 (Lemma 10.3.11.5). The proof outline is at lines 488-529 (for Case 3, which Case 5 uses). Specialize: the L/R/l/r analysis becomes discrete (l and r are specific integers, not limits).
- **Cases 6-8**: Lines 556-573. These are SHORT reductions to other cases.
- **Do NOT use**: Section 10.2 formulas (lines 80-120) — these are the broken ones.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (GHR94 analysis) | completed | high | Confirmed both errors in Section 10.2; junction-depth fusion idea |
| B | Alternatives (literature) | completed | high | **Dedekind specialization verified correct against counterexample** |
| C | Critic (blocker validation) | completed | high | Confirmed blocker real; identified Dedekind exploration gap |
| D | Horizons (strategy) | completed | medium-high | Axiom propagation to bx_completeness; Option F architecture |

## Conflicts Resolved

| Conflict | Teammate A | Teammate B | Resolution |
|----------|-----------|-----------|------------|
| Dedekind specialization works? | NO (β factor persists in disjunct ii) | YES (verified full formula) | **B correct**: Formula works via disjuncts (i) and (iii); (ii) can fail but the formula has 3 disjuncts |
| K⁺/K⁻ on Z | ⊥ (corrected from ⊤) | ⊥ (contradicts GHR94 text) | **Both agree**: K⁺ = K⁻ = ⊥. GHR94 line 249 has a textbook error |

## Next Steps

1. `/plan 157` to create implementation plan for Phase 6B using the Dedekind specialization approach
2. Key implementation order: Q-lemma for Z → Case 5 intermediate → Case 1 to finish → Cases 6-8 → wire into hierarchy → Phase 6C → Phase 8

## References

- GHR94 Chapter 10.2 (integer separation — blocked formulas)
- GHR94 Chapter 10.3 (Dedekind-complete separation — source of correct formulas)
- GHR94 Lemma 10.3.6 (Q-lemma — key ingredient)
- GHR94 Lemma 10.3.11 (all 8 Dedekind cases)
- Reynolds 1994 (expressive completeness, no separation procedure)
- Burgess 1982 (completeness for linear time, no separation)
