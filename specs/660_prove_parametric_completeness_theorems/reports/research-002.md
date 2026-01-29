# Research Report: Task #660 (v2)

**Task**: Prove parametric completeness theorems
**Started**: 2026-01-29T06:37:57Z
**Completed**: 2026-01-29T07:15:00Z
**Effort**: Medium (10-15 hours estimated for implementation)
**Priority**: Medium
**Dependencies**: Tasks 656, 657, 658
**Sources/Inputs**:
- Mathlib `FirstOrder.Language.Theory.isSatisfiable_iff_isFinitelySatisfiable`
- [IEP: Compactness](https://iep.utm.edu/compactness/)
- [Wikipedia: Finite Model Property](https://en.wikipedia.org/wiki/Finite_model_property)
- Existing codebase: `Theories/Bimodal/Metalogic/` and `Theories/Bimodal/Boneyard/Metalogic_v2/`
**Artifacts**: This report (supersedes research-001.md)
**Standards**: report-format.md

---

## Executive Summary

**Key Correction**: The previous report conflated "strong completeness" with true infinitary strong completeness. Our current system has only **finite-premise strong completeness**, which does NOT automatically entail compactness.

**Corrected Theorem Hierarchy**:

```
                     REPRESENTATION THEOREM
                     (Consistent φ → Satisfiable φ)
                              |
              +---------------+---------------+
              |                               |
              v                               v
    WEAK COMPLETENESS                FINITE MODEL PROPERTY
    (⊨ φ → ⊢ φ)                      (Satisfiable → Finite Model)
              |                               |
              v                               |
    FINITE-PREMISE STRONG                     |
    COMPLETENESS                              |
    (Γ_finite ⊨ φ → Γ ⊢ φ)                    |
              |                               |
              +---------------+---------------+
                              |
                              v
                        DECIDABILITY
                        (via FMP + finite search)
                              |
                              v
                        COMPACTNESS
                        (requires infinite Γ)
```

**Critical Insight**: Compactness requires reasoning about **infinite** premise sets. Our `Context = List Formula` gives only finite premises. True compactness requires:
1. Either: Set-based semantic consequence + proof that derivations use finite premises
2. Or: Direct semantic proof via ultraproducts (Mathlib approach)

---

## Context & Scope

### Research Focus
The user clarified: "Currently, what strong completeness seems to mean here only permits a finite number of premises, which does not obviously entail compactness."

This is **correct**. Let me clarify the precise distinctions.

---

## Findings

### 1. Three Distinct Notions of "Strong Completeness"

| Term | Definition | Requires |
|------|------------|----------|
| **Weak Completeness** | `⊨ φ → ⊢ φ` | Empty premise set |
| **Finite-Premise Strong** | `Γ_finite ⊨ φ → Γ ⊢ φ` | Finite list of premises |
| **True (Infinitary) Strong** | `Γ_set ⊨ φ → ∃Δ⊆Γ finite, Δ ⊢ φ` | Arbitrary (possibly infinite) set |

**Current Implementation** (`Boneyard/Metalogic_v2/Completeness/StrongCompleteness.lean`):
```lean
theorem strong_completeness (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → ContextDerivable Γ φ
```

Where `Context = List Formula` (inherently finite). This is **finite-premise strong completeness**.

### 2. Why Finite-Premise Strong Completeness Does NOT Entail Compactness

**Compactness** says: If every finite subset of Γ is satisfiable, then Γ is satisfiable.

The standard proof requires:
1. Assume Γ is unsatisfiable (no model)
2. Then Γ ⊨ ⊥
3. **By infinitary strong completeness**: ∃Δ ⊆ Γ finite with Δ ⊢ ⊥
4. By soundness, Δ is unsatisfiable
5. Contradiction: finite subset is unsatisfiable

**The gap**: Step 3 requires reasoning about **infinite** Γ in the premise of "Γ ⊨ ⊥". With `Context = List Formula`, we can only state this for finite Γ, making compactness trivial (Γ = Γ).

### 3. The Finite Model Property (FMP)

**Definition** ([Wikipedia](https://en.wikipedia.org/wiki/Finite_model_property)): A logic has FMP if every satisfiable formula is satisfiable in a **finite** model.

**Location**: `Boneyard/Metalogic_v2/Representation/FiniteModelProperty.lean`

```lean
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ →
    ∃ (D : Type) ... (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
      truth_at M τ t φ
```

**FMP's Role**: FMP is **independent** of completeness in the dependency graph. It provides:
- Decidability (enumerate finite models up to size bound)
- Size bounds (2^|subformulas(φ)|)

**FMP does NOT directly provide compactness**. Both require additional infrastructure.

### 4. Correct Dependency Structure

```
LAYER 0: Proof System + Semantics
          |
          v
LAYER 1: REPRESENTATION THEOREM
         "Consistent {φ} implies φ satisfiable in canonical model"
         (Task 654 - COMPLETED)
          |
    +-----+-----+
    |           |
    v           v
LAYER 2a:    LAYER 2b:
WEAK         FMP
COMPLETE-    "Satisfiable φ has
NESS         finite model"
    |           |
    v           v
LAYER 3:     DECIDABILITY
FINITE-      (via FMP bound)
PREMISE
STRONG
    |
    v
LAYER 4: TRUE COMPACTNESS (requires additional work)
         Option A: Extend to Set-based semantic consequence
         Option B: Direct ultraproduct proof
```

### 5. How To Get True Compactness

**Option A: Proof-Theoretic (Extend Strong Completeness)**

Requires:
1. Define `SetSemanticConsequence (Γ : Set Formula) (φ : Formula)`
2. Prove: `SetSemanticConsequence Γ φ → ∃ Δ : Finset Formula, Δ ⊆ Γ ∧ ContextDerivable Δ.toList φ`

Key insight: Derivations are **syntactically** finite (induction on derivation tree). Even if Γ is infinite, any derivation only uses finitely many premises.

```lean
/-- True infinitary strong completeness -/
theorem infinitary_strong_completeness (Γ : Set Formula) (φ : Formula) :
    set_semantic_consequence Γ φ → ∃ Δ : Finset Formula, ↑Δ ⊆ Γ ∧ ContextDerivable Δ.toList φ := by
  intro h_entails
  -- Contrapositive: if no finite Δ ⊆ Γ derives φ, then Γ ⊭ φ
  -- For this, construct a model where all of Γ is true but φ is false
  -- This uses: if {¬φ} ∪ Γ is consistent, then it has a model (representation theorem)
  sorry
```

**Option B: Purely Semantic (Ultraproducts)**

Mathlib's approach in `ModelTheory.Satisfiability`:
```lean
theorem isSatisfiable_iff_isFinitelySatisfiable {T : L.Theory} :
    T.IsSatisfiable ↔ T.IsFinitelySatisfiable
```

This doesn't require completeness at all. Uses:
1. For each finite T₀ ⊆ T, get model M_{T₀}
2. Form ultraproduct over directed system of finite subsets
3. Ultraproduct satisfies all of T

**Trade-off**:
- Option A: Conceptually cleaner, ties to proof system
- Option B: More general, works even without completeness

### 6. Corrected Architecture for Bimodal/Metalogic

```
Bimodal/Metalogic/
├── Core/                        # MCS, deduction infrastructure
├── Representation/              # Canonical model construction
│   ├── UniversalCanonicalModel.lean  # representation_theorem (DONE)
│   ├── TruthLemma.lean              # (DONE)
│   └── ...
├── Completeness/                # NEW DIRECTORY
│   ├── Completeness.lean            # Module root
│   ├── WeakCompleteness.lean        # ⊨ φ → ⊢ φ
│   ├── FiniteStrongCompleteness.lean # Γ_list ⊨ φ → Γ ⊢ φ
│   └── InfinitaryStrongCompleteness.lean # Γ_set ⊨ φ → ∃Δ finite ⊢ φ (optional)
├── FiniteModel/                 # FMP and decidability
│   ├── FiniteModelProperty.lean
│   └── Decidability.lean
└── Compactness/                 # REQUIRES InfinitaryStrong OR Ultraproducts
    └── Compactness.lean
```

### 7. What The Boneyard's "Compactness" Actually Proves

The comment in `Boneyard/Metalogic_v2/Applications/Compactness.lean` is revealing:

> "These theorems are trivially true for our list-based `Context` type."
> Since `Context = List Formula`, every context is already finite, so the
> "finite subset" is simply the context itself.

This is **not true compactness**. True compactness is about infinite sets of premises.

---

## Decisions

### D1: Distinguish Three Levels of "Completeness"

1. **Weak Completeness**: `⊨ φ → ⊢ φ` - Standard, derive from representation theorem
2. **Finite-Premise Strong**: `Γ_list ⊨ φ → Γ ⊢ φ` - What we currently have
3. **Infinitary Strong**: `Γ_set ⊨ φ → ∃Δ finite ⊢ φ` - Required for true compactness

### D2: FMP is Orthogonal to Completeness

FMP provides decidability, not compactness. Keep them in separate modules.

### D3: True Compactness is Optional for Task 660

Given the complexity, suggest:
- **Must have**: Weak completeness, finite-premise strong completeness, FMP
- **Nice to have**: Infinitary strong completeness, true compactness

---

## Recommendations

### 1. Implementation Plan for Task 660

**Phase 1**: Weak Completeness (~2 hours)
- Port from Boneyard, adapt to parametric D
- Uses representation theorem directly

**Phase 2**: Finite-Premise Strong Completeness (~3 hours)
- Implement impChain helper
- Reduce to weak completeness via deduction theorem
- Keep `Context = List Formula`

**Phase 3**: FMP Port (~3 hours)
- Port FiniteModelProperty.lean to parametric architecture
- Connect to decidability

**Phase 4 (Optional)**: Infinitary Strong Completeness (~4 hours)
- Define `SetSemanticConsequence`
- Prove derivations extract finite premise sets
- Use representation theorem for contrapositive

**Phase 5 (Optional)**: True Compactness (~2 hours if Phase 4 done)
- Derive from infinitary strong completeness
- Or: standalone ultraproduct proof

### 2. Naming Conventions

| Concept | Current Name | Recommended Name |
|---------|--------------|------------------|
| `Context = List Formula` | Keep | Keep |
| Finite strong | `strong_completeness` | `finite_strong_completeness` |
| Infinitary strong | N/A | `infinitary_strong_completeness` |
| Set-based consequence | N/A | `set_semantic_consequence` |

### 3. Key Theorems to Prove

```lean
-- Layer 2a: Weak completeness
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ

-- Layer 3: Finite-premise strong completeness
theorem finite_strong_completeness (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → ContextDerivable Γ φ

-- Layer 2b: FMP
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ → ∃ ... (finite model)

-- Layer 4 (optional): Infinitary strong completeness
theorem infinitary_strong_completeness (Γ : Set Formula) (φ : Formula) :
    set_semantic_consequence Γ φ → ∃ Δ : Finset Formula, ↑Δ ⊆ Γ ∧ ContextDerivable Δ.toList φ

-- Layer 5 (optional): Compactness
theorem compactness (Γ : Set Formula) :
    (∀ Δ : Finset Formula, ↑Δ ⊆ Γ → set_satisfiable ↑Δ) → set_satisfiable Γ
```

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Infinitary strong requires complex derivation analysis | High | Make it optional; finite-strong is useful without it |
| Set-based semantic consequence complicates types | Medium | Keep parallel List and Set versions |
| Ultraproduct approach requires new infrastructure | High | Avoid unless proof-theoretic approach fails |
| Confusion between trivial and true compactness | Medium | Clear naming and documentation |

---

## Appendix

### Theorem Hierarchy Summary

```
                    ┌─────────────────────────────────────┐
                    │      REPRESENTATION THEOREM         │
                    │   (Consistent → Satisfiable)        │
                    │   [Task 654 - COMPLETED]            │
                    └─────────────────┬───────────────────┘
                                      │
           ┌──────────────────────────┼──────────────────────────┐
           │                          │                          │
           v                          v                          v
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│  WEAK COMPLETENESS  │   │         FMP         │   │     SOUNDNESS       │
│    (⊨ φ → ⊢ φ)      │   │ (Sat → Finite Model)│   │    (⊢ φ → ⊨ φ)      │
│   [Task 660 P1]     │   │   [Task 660 P3]     │   │    [Existing]       │
└──────────┬──────────┘   └──────────┬──────────┘   └─────────────────────┘
           │                         │
           v                         v
┌─────────────────────┐   ┌─────────────────────┐
│ FINITE-PREMISE      │   │    DECIDABILITY     │
│ STRONG COMPLETENESS │   │  (Enumerate finite  │
│ (Γ_list ⊨ φ → ⊢ φ)  │   │      models)        │
│   [Task 660 P2]     │   │   [Task 660 P3]     │
└──────────┬──────────┘   └─────────────────────┘
           │
           v
┌─────────────────────┐
│ INFINITARY STRONG   │  ← OPTIONAL
│   COMPLETENESS      │
│ (Γ_set ⊨ φ → ∃Δ⊢φ) │
│   [Task 660 P4]     │
└──────────┬──────────┘
           │
           v
┌─────────────────────┐
│  TRUE COMPACTNESS   │  ← OPTIONAL
│ (Fin-Sat → Sat)     │
│   [Task 660 P5]     │
└─────────────────────┘
```

### References

- **[IEP: Compactness](https://iep.utm.edu/compactness/)**: "If a logic has a sound and complete proof procedure, it is compact."
- **[Wikipedia: Finite Model Property](https://en.wikipedia.org/wiki/Finite_model_property)**: "A logic has FMP if any non-theorem is falsified by some finite model."
- **Mathlib `ModelTheory.Satisfiability`**: Ultraproduct proof of compactness
- **Boneyard `Metalogic_v2/`**: Existing templates (with caveats about Context being finite)

---

## Next Steps

1. Create implementation plan with clear phase boundaries
2. Implement Phases 1-3 (weak, finite-strong, FMP) as core deliverables
3. Assess whether Phases 4-5 (infinitary, compactness) are needed for roadmap goals
4. If compactness is critical, choose between proof-theoretic and ultraproduct approaches
