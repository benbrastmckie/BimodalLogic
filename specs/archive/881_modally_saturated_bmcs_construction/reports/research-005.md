# Research Report: Task #881 - Int Specialization Safety Analysis

**Task**: Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-13
**Focus**: Validating whether Int specialization for time type D is sound
**Session**: sess_1771023420_608051

## Summary

The recommendation in research-004.md to specialize the time type from polymorphic `D` to `Int` is **SAFE AND CORRECT** for this codebase. The ProofChecker logic does NOT assume any frame properties beyond those validated by its axiom system, and the completeness theorem being proven is with respect to a fixed class of frames that Int satisfies. Discreteness does not introduce soundness issues because the existential temporal operators (F, P) do not have density axioms in the proof system.

## Key Findings

### Finding 1: The Logic Uses Reflexive, Not Strict, Temporal Operators

The temporal operators `G` (all_future) and `H` (all_past) use **reflexive** semantics (lines 113-114 of `Truth.lean`):

```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ
```

The operators use `≤` rather than `<`, meaning "now and all future/past times". This is explicitly noted in the docstring (line 12-13):

> **Reflexive Temporal Semantics**: As of Task #658, temporal operators G (all_future)
> and H (all_past) use REFLEXIVE semantics (≤ instead of <)

### Finding 2: Existential Operators (F, P) Are Derived, Not Primitive

The "eventually" (F) and "previously" (P) operators are **derived** operators, not primitives (lines 361-373 of `Formula.lean`):

```lean
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg   -- P = ¬H¬
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg  -- F = ¬G¬
```

This means:
- `F(φ)` = "it is not the case that always in the future not-φ" = "sometimes in the future φ"
- `P(φ)` = "it is not the case that always in the past not-φ" = "sometimes in the past φ"

### Finding 3: No Density Axioms in the Proof System

The axiom file (`ProofSystem/Axioms.lean`) defines 16 axiom schemata. **None** of them are density axioms. The temporal axioms are:

| Axiom | Formula | Effect |
|-------|---------|--------|
| TK (Temporal K Distribution) | `G(φ → ψ) → (Gφ → Gψ)` | Distribution |
| T4 (Temporal 4) | `Gφ → GGφ` | Transitivity |
| TA (Temporal A) | `φ → G(Pφ)` | Connectedness (present was in future's past) |
| TL (Temporal L) | `△φ → G(Hφ)` | Perpetuity introspection |
| TT-G (Temporal T Future) | `Gφ → φ` | Reflexivity (now is included in future) |
| TT-H (Temporal T Past) | `Hφ → φ` | Reflexivity (now is included in past) |

**Critically missing density/continuity axioms** that would invalidate discreteness:
- No `Gφ → FGφ` (would require density: between t and any t' > t, there exists t'')
- No `Fφ → φ ∨ FFφ` (discrete induction principle)
- No `Gφ ↔ φ ∧ ○Gφ` (next-state characterization)

### Finding 4: Soundness is Over ALL Task Frames, Including Discrete

The soundness theorem (`Soundness.lean` line 625) proves:

```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ)
```

where `⊨` means validity over **ALL** task frames (polymorphic over the time type D). Critically, each axiom's soundness proof (lines 86-609) uses the generic type class constraints `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

Since Int satisfies these constraints, any formula derivable in the proof system is valid over Int-indexed frames. The logic is **sound over discrete time** because it doesn't contain axioms that would fail on discrete frames.

### Finding 5: Completeness is Being Proven for a Fixed Frame Class

The completeness theorem uses the `fully_saturated_bmcs_exists` axiom (line 773 of `TemporalCoherentConstruction.lean`):

```lean
axiom fully_saturated_bmcs_exists (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS D), ...
```

The axiom is polymorphic in D, but the **actual usage** only instantiates with Int. The completeness proof constructs a SPECIFIC canonical model over Int-indexed times. This is standard practice:

**Strong Completeness over Int**: If φ is not provable, there exists an **Int-indexed** model where φ fails.

This implies:
- If φ is derivable, it's valid over ALL frames (by soundness)
- If φ is NOT derivable, it fails in SOME Int-frame (by completeness)
- Therefore: derivability ↔ validity over Int-frames

### Finding 6: Why Polymorphic D is Unnecessary

The polymorphic D parameter in the axiom serves no mathematical purpose because:

1. **Downstream usage is Int-only**: The completeness chain (`bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`) only needs Int.

2. **No frame-specific axioms**: The logic doesn't have axioms like density that would behave differently on different frame classes.

3. **Unnecessary generality adds proof burden**: Proving existence for ALL ordered groups is strictly harder than proving for Int, with no benefit.

## Theoretical Analysis: Discreteness and Temporal Logic

### What Would Make Int Unsafe?

Using Int (discrete time) would be **unsound** if the proof system contained:

1. **Density axioms**: `∀t,t'. t < t' → ∃t''. t < t'' < t'`
2. **Continuous F characterization**: `Fφ → φ ∨ (∃δ>0. ∀ε<δ. Fε(Fφ))` (informal)
3. **Anti-discreteness axioms**: `¬∃t. t is immediate successor of 0`

The ProofChecker system has **none** of these.

### What Int Does Satisfy

Int satisfies all the frame properties required by the axiom system:

| Property | Required By | Int Satisfies? |
|----------|-------------|----------------|
| Reflexive temporal | TT-G, TT-H | YES (via ≤) |
| Transitive temporal | T4 | YES |
| Linear order | All temporal | YES |
| Abelian group | Task composition | YES |
| Unbounded (no maximal time) | Implicit | YES |

### What About Dense Time Models?

If someone wanted to prove completeness over dense time (Rat or Real), they would need:
1. Different frame axioms (density axiom in the logic)
2. Different construction (transfinite instead of omega-step)
3. No discrete "next time" concept

But that's a **different logic** with **different axioms**. The ProofChecker's TM logic as axiomatized is **agnostic** to density - it works on both discrete and dense frames, proving only what's valid on both.

## Recommendations

### Confirmed Safe: Specialize Axiom to Int

The research-004.md recommendation is **validated**:

```lean
-- BEFORE (unnecessarily general)
axiom fully_saturated_bmcs_exists (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] ...

-- AFTER (appropriately specific)
axiom fully_saturated_bmcs_exists_int (Gamma : List Formula)
    (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS Int), ...
```

### Benefits of Int Specialization

1. **Immediate technical simplification**: Int has decidable equality, well-founded recursion via `Nat.lt_wfRel` on `|n|`, and concrete arithmetic.

2. **Enables omega-step construction**: Can enumerate `0, 1, -1, 2, -2, ...` covering all integers.

3. **Matches downstream usage**: All completeness theorems only need Int.

4. **No loss of generality**: Soundness already covers all frames; completeness only needs one countermodel.

### What Int Specialization Does NOT Do

- Does NOT make the logic "discrete temporal logic" (axioms are unchanged)
- Does NOT validate new theorems (soundness is unchanged)
- Does NOT restrict what models the logic is sound over (all frames still valid)
- Only affects the CONSTRUCTION of canonical countermodels

## References

### Files Analyzed

| File | Lines | Key Content |
|------|-------|-------------|
| `Semantics/Truth.lean` | 1-485 | Reflexive temporal semantics |
| `ProofSystem/Axioms.lean` | 1-293 | 16 axiom schemata (no density) |
| `Metalogic/Soundness.lean` | 1-710 | Soundness over all frames |
| `Metalogic/Bundle/TemporalCoherentConstruction.lean` | 760-808 | The polymorphic axiom |
| `Syntax/Formula.lean` | 1-483 | Derived F/P operators |
| `Semantics/TaskFrame.lean` | 1-193 | Frame definition |

### Prior Research

- research-004.md: Team research recommending Int specialization
- Task 882 summary: TemporalLindenbaum dead end analysis

## Conclusion

Using Int for the time type is **safe** because:

1. The logic's axiom system does not assume density
2. Soundness is proven for all frames (including discrete)
3. Completeness only needs one countermodel frame class
4. Int satisfies all required frame properties
5. All downstream usage is already Int-specific

The user's concern about discrete time validating additional theorems is unfounded - the **axiom system** determines what's provable, not the canonical model construction. Since there are no density axioms, nothing new becomes provable by using Int.
