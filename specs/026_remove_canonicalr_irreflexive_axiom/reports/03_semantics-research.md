# Research Report: Temporal Semantics and canonicalR_irreflexive_axiom Viability

**Task**: 26 - remove_canonicalr_irreflexive_axiom
**Date**: 2026-03-21
**Session**: sess_1774122144_418c32
**Focus**: Determine temporal semantics (strict vs reflexive), assess axiom removal viability

---

## Executive Summary

The codebase uses **strict temporal semantics** (G/H quantify over s > t / s < t). The T-axioms (`H(phi) -> phi`, `G(phi) -> phi`) are **NOT** in the current proof system - they were intentionally removed during Task 991. Path A (re-enabling the existing proof) is **NOT viable** without reverting to reflexive semantics. Path C (documentation fixes) is recommended.

---

## Research Questions Answered

### 1. Temporal T-Axiom Availability

**Finding**: The temporal T-axioms do NOT exist in the current proof system.

**Evidence** from `Theories/Bimodal/ProofSystem/Axioms.lean`:
- Lines 43-52: Explicit documentation that T-axioms are NOT included:
  ```
  **Note**: Under strict semantics (Task 991), the T-axioms (G(phi) -> phi, H(phi) -> phi) are
  NOT valid and are NOT included. Strict semantics quantifies over s > t, so the
  present is excluded from temporal quantification.
  ```
- Lines 85-87: Repeated in Axiom docstring
- The `Axiom` inductive (lines 94-425) contains NO constructors for `temp_t_future` or `temp_t_past`

**Verification**: Searched for `temp_t` patterns - found only references in documentation explaining why they were removed, and in `LinearityDerivedFacts.lean` line 16 which lists them as part of a historical axiom set discussion.

### 2. modal_t Scope

**Finding**: The `modal_t` axiom applies ONLY to the metaphysical necessity operator (box), NOT to temporal operators.

**Evidence** from `Theories/Bimodal/ProofSystem/Axioms.lean`:
- Lines 115-120:
  ```lean
  /-- Modal T axiom: `box(phi) -> phi` (reflexivity).
      What is necessarily true is actually true. -/
  | modal_t (phi : Formula) : Axiom (Formula.box phi |>.imp phi)
  ```
- Lines 37-41 (S5 Modal Axioms section): Modal axioms govern the `box` operator representing metaphysical necessity
- Lines 43-48 (Temporal Axioms section): Temporal operators G/H are handled separately with NO T-axiom

**Operator Distinction**:
| Operator | Meaning | T-axiom Status |
|----------|---------|----------------|
| `box` (metaphysical) | necessity across all possible worlds | modal_t: `box(phi) -> phi` EXISTS |
| `all_future` (G) | at all strictly future times | temp_t_future: DOES NOT EXIST |
| `all_past` (H) | at all strictly past times | temp_t_past: DOES NOT EXIST |

### 3. CanonicalIrreflexivity.lean Proof Infrastructure

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
**Length**: 1255 lines

**Key Structures** (lines 68-171):
1. `atomFreeSubset`: Extracts p-free formulas from M
2. `namingSet`: Constructs `atomFreeSubset M p union {atom p, H(neg(atom p))}`
3. `exists_fresh_for_finite_list`: Ensures fresh atom existence
4. `iterated_deduction`: Deduction theorem iteration

**Naming Set Consistency Proof** (lines 236-1173):
- The proof uses IRR (Gabbay Irreflexivity Rule) contrapositively
- Core argument: If naming set is inconsistent, derive a p-free formula via IRR, show it contradicts M's consistency

**Where the Proof Breaks** (lines 1232-1248):
```lean
/-- Legacy Proof (Preserved for Reference)
    ...
    5. By T-axiom: H(neg(p)) -> neg(p), so neg(p) in M'.
    6. Contradiction: both p and neg(p) in M'.

    This proof is now superseded by the axiom-based approach above. -/
```

**Root Cause**: Step 5 requires `H(phi) -> phi` which is invalid under strict semantics. The proof machinery is complete BUT relies on a non-existent axiom.

### 4. Task 967 vs Task 991 History

**Task 967** (circa 2026-03-14):
- Adopted reflexive temporal semantics (G = forall s >= t)
- Added T-axioms: `temp_t_future : Axiom ((Formula.all_future phi).imp phi)`
- Proved `canonicalR_irreflexive` as theorem using Gabbay IRR + T-axiom
- Evidence: `specs/vault/01-vault/archive/967_change_atom_type_for_freshness/reports/research-002.md`

**Task 991** (circa 2026-03-18):
- Reverted to strict temporal semantics (G = forall s > t)
- Removed T-axioms (invalid under strict semantics)
- T-axiom proof broke; `canonicalR_irreflexive` became `axiom`
- Evidence: `specs/vault/01-vault/archive/991_temporal_algebraic_representation/reports/research-003-irreflexive-refactoring-plan.md`

**Documentation Inconsistency**:
- `CanonicalIrreflexivityAxiom.lean` lines 14-18 still claim "proven theorem (Task 967)"
- Actual status: axiom invocation at line 1212

### 5. Viability Assessment

**Path A: Re-enable Existing Proof**
| Aspect | Assessment |
|--------|------------|
| Proof infrastructure | EXISTS (1170+ lines complete) |
| Required axiom | T-axiom (`H(phi) -> phi`) |
| T-axiom in system | NO - intentionally removed |
| Would re-adding work? | YES - but breaks semantics design |
| Semantic impact | Reflexive semantics conflates base/dense/discrete frame classes |

**Verdict**: NOT viable without reverting to reflexive semantics, which was explicitly rejected in Task 991 because it trivializes the frame class distinctions (density `F(phi) -> FF(phi)` becomes tautological when s=t witnesses the intermediate).

**Path C: Documentation Fixes**

**Required Changes**:

1. **`CanonicalIrreflexivityAxiom.lean`** (lines 14-18):
   - CURRENT: "This is now a **proven theorem** (Task 967)"
   - CORRECT: "This is an **axiom** justified by modal non-definability of irreflexivity under strict temporal semantics (Task 991)"

2. **`CanonicalIrreflexivityAxiom.lean`** (lines 73-75):
   - CURRENT: "**Resolved (Task 967)**: This was previously an axiom... Now proven via T-axiom approach"
   - CORRECT: "**Status (Task 991)**: Axiom-based. T-axiom proof (Task 967) was reverted when strict semantics was adopted."

---

## Recommendation

**Implement Path C**: Accept the axiom with proper documentation.

**Rationale**:
1. The axiom is **mathematically sound** - irreflexivity is a semantic truth under strict temporal ordering
2. Irreflexivity is **NOT modally definable** (van Benthem 1983, BdRV 2001 Ch. 3.3) - no pure Hilbert-style derivation can establish it
3. Re-enabling the proof would require **reverting to reflexive semantics** which was explicitly rejected to preserve frame class distinctions
4. The current architecture is **deliberately designed** - strict semantics enables parametric representation theorems for distinct frame classes

**Exact Documentation Changes**:

**File**: `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

Lines 14-18 (docstring, Mathematical Status section):
```markdown
## Mathematical Status

This is an **axiom** justified by modal non-definability. Under strict temporal
semantics (Task 991), the T-axiom (H(phi) -> phi) is not valid, so the Gabbay IRR
proof approach is unavailable. Irreflexivity is semantically guaranteed (t > t is
impossible) but not syntactically derivable.
```

Lines 73-75 (theorem docstring, Resolved note):
```markdown
**Status (Task 991)**: Axiom-based. The T-axiom proof approach (Task 967) was
reverted when strict temporal semantics was adopted. Irreflexivity is modal
non-definable, so the axiom is the correct formalization.
```

---

## Code References

| File | Lines | Content |
|------|-------|---------|
| `Theories/Bimodal/ProofSystem/Axioms.lean` | 43-52, 85-87 | T-axiom exclusion documentation |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | 115-120 | modal_t definition (box only) |
| `Theories/Bimodal/Semantics/Truth.lean` | 10-15, 121-122 | Strict semantics (s < t / t < s) |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` | 1212 | axiom declaration |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` | 1232-1248 | Legacy proof documentation |
| `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` | 14-18, 73-75 | Stale documentation |

---

## Appendix: Why Reflexive Semantics Was Rejected

From `research-003-irreflexive-refactoring-plan.md`:

Under reflexive semantics (`G(phi)` = forall s >= t, phi(s)):
1. Density `F(phi) -> FF(phi)` is trivially valid on ALL frames (witness s = t)
2. Seriality `F(top)` is trivially valid on ALL frames (witness s = t)
3. Discreteness axiom collapses to tautology
4. All three frame classes (base, dense, discrete) are **semantically indistinguishable**

This makes parametric representation theorems for distinct frame classes **logically impossible** within a single fixed semantics.
