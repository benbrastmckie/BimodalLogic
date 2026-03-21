# Team Research Synthesis: Irreflexivity Under Strict Semantics

**Task**: 991 - Temporal Algebraic Representation
**Date**: 2026-03-18
**Mode**: Team Research (2 teammates)
**Focus**: Appropriate semantics for TM temporal logic supporting base, dense, and discrete representation theorems

---

## Summary

Both research teammates agree on the core finding: **strict semantics is the correct standard
approach** for temporal logic, and the refactoring direction in Task 991 is mathematically sound.
However, the naming set proof for irreflexivity fails under strict semantics, and a different proof
strategy is needed. The two most viable paths are:

1. **Alternative proof via temp_a + linearity** (no axiom changes needed, medium difficulty)
2. **Add seriality to base axioms** (changes logic slightly, cleaner proof, aligns with standard Kt)

---

## Key Findings

### 1. Strict Semantics Is the Standard (CONFIRMED, High Confidence)

The temporal logic literature (Prior, Burgess, Goldblatt, Gabbay-Hodkinson-Reynolds) predominantly
uses **strict semantics** as the mathematical standard:

- `Gφ` = "φ at all s > t" (strict future)
- `Hφ` = "φ at all s < t" (strict past)

The reflexive variant (`≥`/`≤`) is an LTL-style computer science convention. For mathematical
logic and representation theorems, strict semantics is correct.

**Consequence**: The refactoring direction in Task 991 is confirmed correct. Continuing.

### 2. Density and Seriality Become Non-Trivial (CONFIRMED, High Confidence)

Under strict semantics:
- **Density** `GGφ → Gφ` genuinely characterizes dense orders (non-trivial, not trivially valid)
- **Seriality** `Gφ → Fφ` genuinely characterizes no-maximum-element frames
- **Discreteness** requires Next/Prev operators (correctly identified in research-002)

Under reflexive semantics these were trivially valid or collapsed. Strict semantics enables genuine
frame class separation — the core motivation for the refactoring.

### 3. The Naming Set Proof Fails (CONFIRMED, High Confidence)

The current `CanonicalIrreflexivity.lean` naming set proof requires T-axiom `H(φ) → φ`, which
is invalid under strict semantics. The set `{p, H(¬p)}` is semantically consistent because
"p now and ¬p at all strict past times" is satisfiable (think: p becoming true for the first time).

This is a genuine mathematical blocker, not an implementation issue.

### 4. Alternative Proof Via temp_a + Linearity (NEW, Medium Confidence)

Teammate B identified a proof strategy that does NOT require T-axiom:

**Proof sketch** (assuming `CanonicalR M M`, i.e., `g_content M ⊆ M`):
1. Take any `φ ∈ M`. By temp_a axiom: `G(P(φ)) ∈ M`
2. Since `G(P(φ)) ∈ M`, we have `P(φ) ∈ g_content(M)`
3. By assumption `CanonicalR M M`: `P(φ) ∈ M`
4. `P(φ) = ¬H(¬φ)`, so `H(¬φ) ∉ M`
5. By linearity axiom, M must be linearly ordered with other worlds
6. Combined with `G(P(φ)) ∈ M` (every future time has a past time with φ), this creates
   an infinite regress that violates MCS consistency

**Assessment**: This proof requires careful formalization. Steps 5-6 need rigorous development
using the linearity axioms (temp_l/temp_lin). This is doable but non-trivial (~50-100 lines
vs ~1200 in the Gabbay proof).

### 5. Seriality in Base Axioms Is Cleaner (Teammate A, Medium-High Confidence)

The simplest path: add `G(φ) → F(φ)` and `H(φ) → P(φ)` (seriality) to the **base** axiom set.

**With seriality in base**:
- The canonical model is over unbounded linear time (standard Kt.Li)
- Irreflexivity proof becomes: assume `g_content M ⊆ M`, apply seriality to get explicit
  successor/predecessor witnesses, derive contradiction
- Aligns with standard tense logic over unbounded linear time (Burgess, Goldblatt)

**Trade-off**: The base logic now requires unbounded frames. Currently seriality is in the
Discrete extension. Moving it to base means all frame classes (base, dense, discrete) require
no-max/no-min elements — which is mathematically appropriate for the intended semantics anyway.

---

## Conflict Analysis

| Finding | Teammate A | Teammate B | Resolution |
|---------|-----------|-----------|------------|
| Strict semantics correct | ✓ Yes | ✓ Yes | Unanimous |
| Naming set proof fails | ✓ Yes | ✓ Yes | Unanimous |
| Alternative proof exists | Option A (seriality in base) | Approach A (temp_a + linearity) | Both viable; see recommendation |
| Irreflexivity is "definitional" | Partially (needs extra axiom) | Yes (via temp_a proof) | Complementary — temp_a proof avoids axiom addition |

No fundamental conflicts. The teammates identified complementary paths.

---

## Recommendations

### Primary Recommendation: temp_a + Linearity Proof (No Axiom Changes)

**Rationale**: Preserves the current axiom architecture (seriality stays in Discrete extension)
and implements irreflexivity via a compact proof using existing base axioms.

**Implementation path for Phase 4**:
1. Delete the existing 1283-line `CanonicalIrreflexivity.lean`
2. Write new proof: assume `g_content M ⊆ M`, use temp_a + linearity to derive contradiction
3. Target: ~50-100 lines

**Risk**: Medium — requires careful formalization of the infinite regress argument.

### Fallback: Add Seriality to Base Axioms

If the temp_a + linearity proof proves too difficult to formalize:
1. Move `seriality_future` and `seriality_past` from Discrete to Base axiom set
2. Update soundness proofs (seriality requires NoMaxOrder/NoMinOrder, add as frame condition)
3. Use seriality-based irreflexivity proof (~30 lines)

**Risk**: Low — straightforward but changes the logic.

### Do NOT Use

- ❌ The Gabbay IRR rule (freshness issues with Lean's finite type system)
- ❌ Zanardo's infinite axiom schema (complicates decidability)
- ❌ Bulldozing (adds unnecessary infrastructure complexity)

---

## Implications for Remaining Phases

Phase 4 should now:
1. **Try the temp_a + linearity proof** (clean, no architectural changes)
2. If that fails, **fall back to seriality-in-base**

Phases 5-10 are **unaffected by this choice** — the truth lemma, staged construction, and
algebraic modules don't depend on which irreflexivity proof strategy is used.

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Literature review, semantics trade-offs | ✓ Complete | High | Confirmed seriality-in-base as viable path; irreflexivity non-definability |
| B | Alternative proofs, representation theorems | ✓ Complete | High | Identified temp_a+linearity proof; Stone duality analysis |

---

## References

- Burgess (1982): Axioms for tense logic — standard Kt axiomatization with IRR
- Goldblatt (1992): *Logics of Time and Computation* — canonical models for tense logic
- Gabbay, Hodkinson, Reynolds (1994): *Temporal Logic* — comprehensive treatment
- Blackburn, de Rijke, Venema (2001): *Modal Logic* — Sahlqvist theory
- Stanford Encyclopedia of Philosophy: [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- ProofChecker codebase: research-002.md, research-003-irreflexive-refactoring-plan.md
