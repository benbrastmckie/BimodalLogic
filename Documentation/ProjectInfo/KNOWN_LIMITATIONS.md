# Known Limitations - Logos MVP

**Last Updated**: 2025-12-03
**Project Version**: 0.1.0-mvp

## Overview

This document documents actual implementation gaps in Logos MVP that users should be aware of.

**Related Documentation**:
- [TODO.md](../../TODO.md) - Active tasks addressing these limitations
- [SORRY_REGISTRY.md](SORRY_REGISTRY.md) - Technical debt details (sorry placeholders)
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Module completion status
- [MAINTENANCE.md](MAINTENANCE.md) - Documentation update workflow

**Quick Navigation**:
1. [Completeness Status](#1-completeness-status)
2. [Automation Limitations](#2-automation-limitations)
3. [Missing Features](#3-missing-features)

---

## 1. Completeness Status

**Status**: Infrastructure only (type signatures, no proofs)

The `Completeness.lean` module contains `axiom` declarations for:
- Lindenbaum lemma
- Canonical model construction
- Truth lemma
- Weak and strong completeness

**All proofs are missing.** The `axiom` keyword declares unproven assumptions.

**Estimated Effort**: 70-90 hours for complete proofs

**Workaround**: Use soundness only. Most applications only need:
- "If we can prove it, it's true" (soundness - proven)
- Not: "If it's true, we can prove it" (completeness - not proven)

**What you CANNOT do without completeness**:
- Prove a formula is NOT derivable
- Use "it's valid, so it's derivable" reasoning

---

## 2. Automation Limitations

**Status**: 4/12 tactics implemented

### 2.1 Implemented (Working)

- `apply_axiom` - Generic axiom application
- `modal_t` - Modal T axiom convenience wrapper
- `tm_auto` - Native TM automation (single-step search)
- `assumption_search` - Context-based assumption finding

### 2.2 Not Implemented

8 planned tactics are not yet implemented:
- `modal_k_tactic`, `temporal_k_tactic`
- `modal_4_tactic`, `modal_b_tactic`
- `temp_4_tactic`, `temp_a_tactic`
- `modal_search`, `temporal_search`

### 2.3 Aesop Integration Blocked

**Issue**: Adding Aesop/Batteries breaks `Logos.Semantics.Truth` due to integer simplification behavior changes.

**Workaround**: Native `tm_auto` using `first` combinator works for MVP.

**Workaround for Missing Tactics**: Manual proof construction:
```lean
-- Instead of: by modal_t
-- Use:
example : ⊢ φ.box.imp φ := Derivable.axiom [] _ (Axiom.modal_t φ)
```

---

## 3. Missing Features

### 3.1 Counterexamples Module

Not implemented. Manually construct TaskModels to demonstrate invalidity.

### 3.2 Decidability Module

Not started. No tableau method or decision procedures.

### 3.3 Layer 1/2/3 Extensions

Not started:
- Counterfactual operators (Layer 1)
- Epistemic operators (Layer 2)
- Normative operators (Layer 3)

---

## What Works Well

- Complete syntax and proof system
- Complete semantics (zero sorry in all semantics files)
- Full soundness (8/8 axioms, 7/7 inference rules proven)
- All 6 perpetuity principles (P1-P6) available
- 4 working tactics with 50 comprehensive tests

---

## References

- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Detailed module status
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - TM logic specification

**Note**: Last reviewed: 2025-12-03.
