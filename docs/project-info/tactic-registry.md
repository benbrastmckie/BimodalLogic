# Tactic Registry

This document tracks the status of all custom tactics developed for the Logos proof automation system.

## Overview

This registry provides a high-level view of tactic implementation status across all system layers. For detailed guides on developing tactics, see [tactic-development.md](../user-guide/tactic-development.md).

## Layer 0 - Core TM (Temporal-Modal Logic)

### Priority Tactics

| Tactic | Purpose | Status | Location |
|--------|---------|--------|----------|
| `apply_axiom` | Apply TM axiom by unification | ✅ Complete | `FormalSystem/Automation/Tactics/UserTactics.lean` |
| `modal_t` | Apply axiom MT (□φ → φ) | ✅ Complete | `FormalSystem/Automation/Tactics/UserTactics.lean` |
| `assumption_search` | Search context for matching assumption | ✅ Complete | `FormalSystem/Automation/Tactics/UserTactics.lean` |
| `propDecide` | Reflective propositional tautology decision | ✅ Complete | `FormalSystem/Automation/Tactics/PropDecide.lean` |
| `deduction` | Apply the deduction theorem `n` times | ✅ Complete | `FormalSystem/Automation/Tactics/Deduction.lean` |
| `undischarge` | Reverse-direction deduction theorem application | ✅ Complete | `FormalSystem/Automation/Tactics/Deduction.lean` |
| `s5_simp` | Simplify S5 modal formulas | 📋 Planned | N/A |
| `temporal_simp` | Simplify temporal formulas | 📋 Planned | N/A |
| `bimodal_simp` | Simplify using MF/TF axioms | 📋 Planned | N/A |
| `perpetuity` | Apply perpetuity principles P1-P6 | 📋 Planned | N/A |

**Retired**: `modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic`,
`temp_4_tactic`, and `temp_a_tactic` were never implemented as separate operator-specific
tactics; `modal_search` (below) subsumes this role.

### Advanced Tactics

| Tactic | Purpose | Status | Location |
|--------|---------|--------|----------|
| `modal_search` | Bounded best-first proof search for TM derivability goals | ✅ Complete | `FormalSystem/Automation/Tactics/Commands.lean` |

**Advanced-tactic implementation notes**:
- `modal_search`: the single proof-search entry point. It replaced `temporal_search`,
  `propositional_search`, and `tm_auto`, which differed from it only in `SearchConfig` weight
  fields that `searchProof` never read, and which have been removed.
- Works at meta-level in `TacticM`, bypassing the Axiom Prop vs Type issue
- Supports both a bare depth (`modal_search 5`) and named parameters
  (`modal_search (depth := 5) (visitLimit := 200)`)

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
| `TMLogic` | TM-specific automation rules | **Retired.** The rule set and its rules were archived to `FormalSystem/Boneyard/RetiredTactics/` on measurement: rules in a dedicated set are reachable only through an explicit `aesop (rule_sets := [TMLogic])`, and no such call site existed in the library or the tests. Aesop's proof reconstruction does not work over `Type`-valued `DerivationTree` goals. |

### Registered Rules

**Safe Rules** (always apply):
- `modal_t_valid` - Modal T axiom validity
- `modal_4_derivable` - Modal 4 axiom derivability
- `modal_b_derivable` - Modal B axiom derivability
- `perpetuity1` through `perpetuity6` - Perpetuity principles: theorems fully proven
  (sorry-free), not yet registered as Aesop safe rules (📋 Planned integration)

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

- **Total Tactics Implemented**: 7 (`apply_axiom`, `modal_t`, `assumption_search`, `propDecide`,
  `deduction`, `undischarge`, `modal_search`), across the six files under
  `FormalSystem/Automation/Tactics/`
- **Completed**: 7 (100% of implemented tactics)
- **Planned**: 4 - `s5_simp`, `temporal_simp`, `bimodal_simp`, `perpetuity`

### By Category
- **Layer 0 Core**: 6/6 implemented tactics complete (`s5_simp`, `temporal_simp`, `bimodal_simp`,
  `perpetuity` remain planned)
- **Layer 0 Advanced**: 1/1 complete (`modal_search`)
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
- Build errors identified: 2 noncomputable errors in the Aesop rule module affecting Aesop integration
- Documentation coverage: All implemented tactics have comprehensive docstrings and examples
- Undocumented tactics: 0 (all implemented tactics fully documented)

### 2025-12-22
- Standards updated: `/task`, `/add`, `/review`, and `/todo` must update tactic-registry.md alongside implementation-status.md when tactic or task status changes occur; dry-run/test modes must avoid registry writes and must not create project directories for doc-only updates. Sorry status is not documented by hand -- check C3 of `scripts/check-module-invariants.sh` asserts it.

### 2025-12-16
- Split tactic-development.md into tactic-registry.md (this file) and UserGuide/tactic-development.md
- Established registry as single source of truth for tactic implementation status

## See Also

- [tactic-development.md](../user-guide/tactic-development.md) - Guide for developing custom tactics
- [implementation-status.md](implementation-status.md) - Overall project implementation status
- [Automation Documentation](../../FormalSystem/Automation/Tactics/) - Source code for tactics
