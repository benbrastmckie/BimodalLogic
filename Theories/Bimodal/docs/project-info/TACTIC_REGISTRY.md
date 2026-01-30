# Tactic Registry

This document tracks the status of all custom tactics developed for the Logos proof automation system.

## Overview

This registry provides a high-level view of tactic implementation status across all system layers. For detailed guides on developing tactics, see [TACTIC_DEVELOPMENT.md](../user-guide/TACTIC_DEVELOPMENT.md).

## Layer 0 - Core TM (Temporal-Modal Logic)

### Priority Tactics

| Tactic | Purpose | Status | Location |
|--------|---------|--------|----------|
| `modal_k_tactic` | Apply modal K rule (MK) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `temporal_k_tactic` | Apply temporal K rule (TK) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `modal_t` | Apply axiom MT (□φ → φ) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `modal_4_tactic` | Apply axiom M4 (□φ → □□φ) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `modal_b_tactic` | Apply axiom MB (φ → □◇φ) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `temp_4_tactic` | Apply axiom T4 (Fφ → FFφ) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `temp_a_tactic` | Apply axiom TA (φ → F(Pφ)) | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `apply_axiom` | Apply TM axiom by unification | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `assumption_search` | Search context for matching assumption | ✅ Complete | `Logos/Core/Automation/Tactics.lean` |
| `tm_auto` | Comprehensive TM automation (Aesop) | 🚧 Partial (noncomputable errors fixed, proof reconstruction issues remain) | `Logos/Core/Automation/Tactics.lean` |
| `s5_simp` | Simplify S5 modal formulas | 📋 Planned | N/A |
| `temporal_simp` | Simplify temporal formulas | 📋 Planned | N/A |
| `bimodal_simp` | Simplify using MF/TF axioms | 📋 Planned | N/A |
| `perpetuity` | Apply perpetuity principles P1-P6 | 📋 Planned | N/A |

### Advanced Tactics (Task 315)

| Tactic | Purpose | Status | Location |
|--------|---------|--------|----------|
| `modal_search` | Bounded proof search for TM derivability goals | ✅ Complete (Task 315) | `Logos/Core/Automation/Tactics.lean` |
| `temporal_search` | Proof search optimized for temporal formulas | ✅ Complete (Task 315) | `Logos/Core/Automation/Tactics.lean` |
| `propositional_search` | Proof search for purely propositional formulas | ✅ Complete (Task 315) | `Logos/Core/Automation/Tactics.lean` |

**Task 315 Implementation Notes**:
- `modal_search`: General purpose bounded proof search with configurable depth
- `temporal_search`: Uses SearchConfig.temporal (prioritizes temporal K rules)
- `propositional_search`: Uses SearchConfig.propositional (disables modal/temporal K)
- All tactics work at meta-level in TacticM, bypassing Axiom Prop vs Type issue
- Supports named parameters: `(depth := n)`, `(visitLimit := n)`, weight parameters

## Layer 1 - Extended Modalities

### Planned Tactics

| Tactic | Purpose | Target Layer | Status |
|--------|---------|--------------|--------|
| `counterfactual` | Counterfactual reasoning | Layer 1 - Explanatory | 📋 Planned |
| `grounding` | Grounding relation reasoning | Layer 1 - Explanatory | 📋 Planned |

## Aesop Integration

### Rule Sets

| Rule Set | Purpose | Status |
|----------|---------|--------|
| `TMLogic` | TM-specific automation rules | 🚧 Partial (noncomputable errors fixed 2026-01-04, proof reconstruction issues remain) |

### Registered Rules

**Safe Rules** (always apply):
- `modal_t_valid` - Modal T axiom validity
- `modal_4_derivable` - Modal 4 axiom derivability
- `modal_b_derivable` - Modal B axiom derivability
- `perpetuity_1` through `perpetuity_6` - Perpetuity principles (🚧 In Progress)

**Normalization Rules** (preprocessing):
- `box_box_eq_box` - S5 modal idempotence (📋 Planned)
- `diamond_diamond_eq_diamond` - S5 possibility idempotence (📋 Planned)
- `future_future_eq_future` - Temporal future idempotence (📋 Planned)
- `box_future_comm` - Modal-temporal commutativity (📋 Planned)

**Forward Rules** (forward chaining):
- `modal_k_forward` - Modal K forward reasoning (✅ Complete)
- `temporal_k_forward` - Temporal K forward reasoning (✅ Complete)

## Simplification Lemmas

### Modal Simplifications (S5)

| Lemma | Purpose | Status |
|-------|---------|--------|
| `box_box_eq_box` | □□φ = □φ idempotence | 📋 Planned |
| `diamond_diamond_eq_diamond` | ◇◇φ = ◇φ idempotence | 📋 Planned |
| `diamond_def` | ◇φ = ¬□¬φ duality | ✅ Complete |

### Temporal Simplifications

| Lemma | Purpose | Status |
|-------|---------|--------|
| `future_future_eq_future` | GGφ = Gφ idempotence | 📋 Planned |
| `past_past_eq_past` | HHφ = Hφ idempotence | 📋 Planned |

### Bimodal Interaction Simplifications

| Lemma | Purpose | Status |
|-------|---------|--------|
| `box_future_eq_future_box` | □Gφ = G□φ commutativity | 📋 Planned |
| `box_past_eq_past_box` | □Hφ = H□φ commutativity | 📋 Planned |

### Propositional Simplifications

| Lemma | Purpose | Status |
|-------|---------|--------|
| `neg_neg` | Double negation elimination | ✅ Complete |
| `imp_eq_or` | Implication to disjunction | ✅ Complete |
| `and_comm` | Conjunction commutativity | ✅ Complete |

## Syntax Macros

### DSL Syntax

| Macro | Purpose | Status |
|-------|---------|--------|
| `□ term` | Modal necessity syntax | ✅ Complete |
| `◇ term` | Modal possibility syntax | ✅ Complete |
| `term ⊢ term` | Derivability syntax | ✅ Complete |

### Tactic Syntax Macros

| Macro | Purpose | Status |
|-------|---------|--------|
| `apply_axiom` | Shorthand for axiom application | ✅ Complete |
| `modal_reasoning` | Combined modal tactic | 📋 Planned |

## Summary Statistics

- **Total Tactics Implemented**: 19 (identified in Tactics.lean)
- **Completed**: 15 (78.9%)
- **In Progress**: 1 (5.3%) - tm_auto has proof reconstruction issues
- **Planned**: 3 (15.8%) - s5_simp, temporal_simp, bimodal_simp

### By Category
- **Layer 0 Core**: 9/10 complete (90%) - All major tactics implemented
- **Layer 0 Advanced**: 3/3 complete (100%) - Task 315 completed modal_search, temporal_search, propositional_search
- **Layer 1 Extended**: 0/2 complete (0%)
- **Simplification Lemmas**: 3/10 complete (30%)
- **Syntax Macros**: 4/5 complete (80%)

## Recent Changes

*This section is automatically updated by the `/todo` command*

### 2026-01-15
- Codebase review completed (sess_1768528304_4parxt): Verified 19 implemented tactics in Tactics.lean
- Identified 1 tactic with issues: tm_auto has proof reconstruction problems with Aesop
- Build error found: RepresentationTheorems.lean has application type mismatch
- Updated tactic counts: 19 total tactics identified (not 23 previously estimated)

### 2025-12-28
- Codebase review completed (sess_1766969902_lx): Verified 10 complete tactics, 2 in progress (modal_search/temporal_search infrastructure ready)
- Tactic count corrected: 10 complete (not 12) - apply_axiom, modal_t, tm_auto, assumption_search, modal_k_tactic, temporal_k_tactic, modal_4_tactic, modal_b_tactic, temp_4_tactic, temp_a_tactic
- Build errors identified: 2 noncomputable errors in AesopRules.lean affecting Aesop integration
- Documentation coverage: All implemented tactics have comprehensive docstrings and examples
- Undocumented tactics: 0 (all implemented tactics fully documented)

### 2025-12-22
- Standards updated: `/task`, `/add`, `/review`, and `/todo` now must update TACTIC_REGISTRY.md alongside IMPLEMENTATION_STATUS.md and SORRY_REGISTRY.md when sorry/tactic/task status changes occur; dry-run/test modes must avoid registry writes and must not create project directories for doc-only updates.

### 2025-12-16
- Split TACTIC_DEVELOPMENT.md into TACTIC_REGISTRY.md (this file) and UserGuide/TACTIC_DEVELOPMENT.md
- Established registry as single source of truth for tactic implementation status

## See Also

- [TACTIC_DEVELOPMENT.md](../user-guide/TACTIC_DEVELOPMENT.md) - Guide for developing custom tactics
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Overall project implementation status
- [SORRY_REGISTRY.md](SORRY_REGISTRY.md) - Registry of unproven theorems
- [Automation Documentation](../../Logos/Core/Automation/) - Source code for tactics
