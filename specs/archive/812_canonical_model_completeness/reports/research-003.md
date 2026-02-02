# Research Report: Task #812

**Task**: FMP-Internal vs General Validity - Semantic Comparison
**Date**: 2026-02-02
**Focus**: Understanding the two validity notions and why the bridge is blocked
**Session ID**: sess_1770026118_5745a7

## Summary

This report analyzes the distinction between FMP-internal validity (`SemanticWorldState`) and general validity (`TaskModel`), explains why the validity bridge is architecturally blocked, and evaluates whether Phase 1's `FMPSemanticConsequence` approach in implementation-002.md is correctly designed.

**Key Finding**: The plan's FMPSemanticConsequence approach is correctly designed. The two validity notions differ fundamentally in their quantification domains, and the bridge between them is blocked specifically for modal operators due to the S5-style universal history quantification. Phase 1 correctly sidesteps this by defining a separate semantic notion over FMP-internal structures.

---

## 1. The Two Validity Notions

### 1.1 General Validity (TaskModel)

**Definition** (Validity.lean:61-64):
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

**Semantic Structure**:
- **Temporal Type**: Quantifies over ALL types D with ordered group structure (Int, Rat, Real, etc.)
- **Task Frame**: Arbitrary frame with WorldState type, WorldHistory, time-shift
- **Task Model**: Frame + arbitrary valuation function (WorldState -> String -> Prop)
- **World History**: Arbitrary function from time domain to world states
- **Time**: Any element of the temporal type D

**Key Characteristics**:
- Universal quantification over unconstrained structures
- No relation to proof system or consistency
- Models can be pathological (all atoms false, infinite states, etc.)

### 1.2 FMP-Internal Validity (SemanticWorldState)

**Definition** (SemanticCanonicalModel.lean:356-357):
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w ...) -> |- phi
```

**Semantic Structure**:
- **Temporal Type**: Fixed to `BoundedTime (temporalBound phi)` = `Fin (2*k+1)` where k = temporal depth
- **World States**: `FiniteWorldState phi` = locally consistent truth assignments on closure
- **Histories**: `FiniteHistory phi` = functions from bounded time to FiniteWorldState
- **SemanticWorldState**: Quotient of (FiniteHistory, BoundedTime) pairs by state equality

**Key Characteristics**:
- Bounded, finite structures
- World states are MCS-derived (satisfy modal T-axiom locally)
- Histories are explicitly constructed from MCS families
- Cardinality bounded by 2^closureSize

### 1.3 Comparison Table

| Aspect | General Validity | FMP-Internal Validity |
|--------|------------------|----------------------|
| Temporal type | Any D | Fin (2k+1) |
| World states | Arbitrary | MCS-derived |
| Cardinality | Unbounded | <= 2^closureSize |
| Histories | All WorldHistory F | FiniteHistory phi |
| Completeness | Blocked for box | Sorry-free |

---

## 2. Why the Validity Bridge is Architecturally Blocked

### 2.1 The Bridge Statement

The validity bridge attempts to prove:
```
General validity -> FMP-internal validity
i.e., (forall TaskModel M, truth_at M ... phi) -> (forall SemanticWorldState w, semantic_truth_at w ... phi)
```

### 2.2 The Problem: Box Semantics

**Box semantics** (Truth.lean:112):
```lean
truth_at M tau t (box phi) = forall (sigma : WorldHistory F), truth_at M sigma t phi
```

This is **S5-style necessity** - box means "true in ALL world histories at time t".

**The issue**: When we try to bridge from FMP-internal to general validity, we need to show:
- If `semantic_truth_at_v2 phi w t (box psi)` holds for all SemanticWorldStates w
- Then `truth_at M tau t (box psi)` holds for any TaskModel M

But `truth_at M tau t (box psi)` requires `psi` true at ALL histories sigma in M, including:
- Histories not derivable from any MCS
- Histories over infinite time domains
- Histories with pathological valuations

### 2.3 Specific Blocking Point

Looking at FiniteStrongCompleteness.lean:123-130:
```lean
have h_fmp_validity : forall (w : SemanticWorldState phi),
    semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi := by
  intro w
  -- Bridge from general validity to FMP-internal validity
  -- This direction should hold but requires proving that the FMP model
  -- instantiates as a valid TaskModel for modal/temporal operators
  -- Currently blocked - see research-005 for analysis
  sorry
```

**Why the sorry cannot be removed**:

1. **Non-MCS histories**: General validity requires truth at histories where `h.states t` might not be a ClosureMCS projection. The FMP model only constructs MCS-derived states.

2. **Universal history quantification**: For `box psi` to be valid in general models, `psi` must hold at EVERY history. But we only know `psi` holds at FiniteHistory structures built from MCS families.

3. **No accessibility relation**: Standard Kripke completeness uses `wRv` defined by MCS containment. This codebase's semantics quantify over ALL histories, not just "accessible" ones.

### 2.4 The Gap is Architectural, Not Technical

This is NOT a matter of missing lemmas. The semantic definition of box fundamentally differs from what canonical model construction can satisfy:

- **Standard Kripke**: `box phi` means "phi at all R-accessible worlds" where R is defined by MCS containment
- **This codebase**: `box phi` means "phi at ALL histories" (S5-style universal)

Closing the gap would require changing the semantics (e.g., adding an accessibility relation).

---

## 3. Evaluation of Phase 1's FMPSemanticConsequence Approach

### 3.1 The Proposed Design

From implementation-002.md:
```lean
/-- FMP-internal validity: truth at all SemanticWorldStates for the formula's closure -/
def FMPValid (phi : Formula) : Prop :=
  forall (w : SemanticWorldState phi),
    semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi

/-- FMP-internal semantic consequence -/
def FMPSemanticConsequence (Gamma : Context) (phi : Formula) : Prop :=
  forall (psi : Formula) (h : psi = impChain Gamma phi), FMPValid psi
```

### 3.2 Assessment: Correctly Designed

**The approach is sound** for the following reasons:

1. **Sidesteps the bridge problem**: By defining a SEPARATE semantic consequence relation that only quantifies over SemanticWorldStates, we never need to relate to general TaskModels.

2. **Matches existing sorry-free theorem**: `semantic_weak_completeness` already proves:
   ```
   FMPValid phi -> |- phi
   ```
   The wrapper `fmp_weak_completeness` just exposes this with cleaner naming.

3. **impChain semantics work**: The impChain construction transforms semantic consequence into validity:
   ```
   FMPSemanticConsequence Gamma phi
   = FMPValid (impChain Gamma phi)
   -> |- (impChain Gamma phi)           [by fmp_weak_completeness]
   -> ContextDerivable Gamma phi         [by imp_chain_to_context]
   ```

4. **No modal/temporal subtlety**: The impChain construction is purely propositional. Building `psi1 -> (psi2 -> ... -> phi)` doesn't involve box or temporal operators in the chain structure itself.

### 3.3 One Subtle Issue

The definition as written:
```lean
def FMPSemanticConsequence (Gamma : Context) (phi : Formula) : Prop :=
  forall (psi : Formula) (h : psi = impChain Gamma phi), FMPValid psi
```

This is overly complex. It could be simplified to:
```lean
def FMPSemanticConsequence (Gamma : Context) (phi : Formula) : Prop :=
  FMPValid (impChain Gamma phi)
```

The `forall psi h` structure adds nothing because `psi` is uniquely determined by `impChain Gamma phi`.

### 3.4 Verification Requirements

For Phase 1 to succeed:

1. **FMPValid definition must use correct closure**: The SemanticWorldState for `impChain Gamma phi` needs closure of that formula, not of phi alone.

2. **semantic_truth_at_v2 must handle arbitrary formulas**: It does - it takes any formula and checks if it's in the closure.

3. **BoundedTime origin must be valid for impChain**: The temporalBound for impChain Gamma phi = max of temporal depths, which is fine.

---

## 4. Why the General Validity Version Has the Sorry

### 4.1 Location of Sorry

FiniteStrongCompleteness.lean:109-131 contains `weak_completeness`:
```lean
theorem weak_completeness (phi : Formula) :
    valid phi -> ContextDerivable [] phi := by
  intro h_valid
  have h_fmp_validity : ... := by
    intro w
    sorry  -- Line 130
  exact ...
```

### 4.2 What the Sorry Would Need to Prove

The sorry needs to show:
```
valid phi -> (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w ... phi)
```

Expanding:
- Given: for ALL D, F, M, tau, t, `truth_at M tau t phi`
- Show: for ALL SemanticWorldState w, `semantic_truth_at_v2 phi w ... phi`

### 4.3 The Concrete Obstruction

For propositional atoms and implications, this works because:
- `semantic_truth_at_v2` checks membership in underlying FiniteWorldState
- FiniteWorldState is MCS-derived, which respects propositional logic
- General validity at propositional level transfers to finite models

For `box psi`:
- General validity: `forall sigma : WorldHistory F, truth_at M sigma t psi`
- FMP-internal: `w.toFiniteWorldState.models (box psi) h_mem`

But `w.toFiniteWorldState.models (box psi) h_mem` is:
```
w.assignment ⟨box psi, h_mem⟩ = true
```

This is just reading a boolean from the MCS! It doesn't involve quantifying over histories at all. The MCS contains `box psi` iff the logic's T-axiom and maximal consistency put it there, NOT because we verified psi at all histories.

### 4.4 The Gap Illustrated

Consider a formula `box (atom "p")`:
- **General validity**: "p" true at ALL world histories at time t
- **FMP-internal**: The MCS containing the world state has `box (atom "p")` because of proof-theoretic reasons (derivability), not semantic evaluation over all histories

The two notions coincide when the logic is complete for the semantics. But proving they coincide IS the completeness theorem - it's circular to assume it in the bridge.

---

## 5. Recommendations for Implementation

### 5.1 Phase 1 Adjustments

1. **Simplify FMPSemanticConsequence definition**:
   ```lean
   def FMPSemanticConsequence (Gamma : Context) (phi : Formula) : Prop :=
     FMPValid (impChain Gamma phi)
   ```

2. **Be careful with closure parameters**: When building SemanticWorldState for `impChain Gamma phi`, ensure the closure is for that formula, not for phi alone.

3. **Add docstrings explaining the semantic scope**: Make clear this is completeness for finite models built from MCS, not for arbitrary models.

### 5.2 Documentation Emphasis

The key distinction users need to understand:
- `fmp_weak_completeness` and `fmp_strong_completeness` are sorry-free but only for FMP-internal validity
- `weak_completeness` and `finite_strong_completeness` have a sorry because they claim general validity completeness
- The sorry is architectural (semantic design choice), not an implementation gap

### 5.3 Alternative Future Approaches

If general validity completeness is eventually desired:
1. **Add modal accessibility relation**: `truth_at M tau t (box phi) = forall sigma, accessible tau sigma -> ...`
2. **Define accessibility via MCS containment**: Standard Kripke approach
3. **Proves completeness for Kripke semantics**: Avoid S5-style universal quantification

---

## 6. Conclusion

The implementation plan's Phase 1 approach is correctly designed. By defining `FMPSemanticConsequence` as a SEPARATE semantic notion over SemanticWorldStates (not TaskModels), the plan avoids the architectural blocker entirely. The resulting theorems will be:

1. **fmp_weak_completeness**: `FMPValid phi -> |- phi` (sorry-free wrapper)
2. **fmp_strong_completeness**: `FMPSemanticConsequence Gamma phi -> ContextDerivable Gamma phi` (sorry-free)

These are legitimate completeness theorems for the finite model semantics. They don't replace general validity completeness (which requires semantic changes), but they provide a clean, sorry-free completeness story for the FMP construction.

The validity bridge (general -> FMP-internal) will remain sorried because the S5-style box semantics quantify over structures that FMP cannot represent. This is documented as an architectural limitation, not an implementation gap.

---

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - FMP-internal completeness
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - General validity (with sorry)
- `Theories/Bimodal/Semantics/Truth.lean` - Box semantics definition (line 112)
- `Theories/Bimodal/Semantics/Validity.lean` - General validity definition
- `specs/812_canonical_model_completeness/reports/research-002.md` - Prior research on plan viability
- `specs/812_canonical_model_completeness/plans/implementation-002.md` - Current implementation plan
