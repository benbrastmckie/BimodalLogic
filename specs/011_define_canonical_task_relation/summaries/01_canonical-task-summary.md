# Implementation Summary: CanonicalTask Relation Definition

**Task**: 11 - define_canonical_task_relation
**Status**: COMPLETED
**Date**: 2026-03-21

## Overview

Successfully implemented the CanonicalTask relation for discrete temporal frames, defining an integer-indexed relation built inductively from the Succ relation (Task 10). All three TaskFrame axioms and the bounded witness corollary are proven.

## Deliverables

### Main File
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (~540 lines)

### Key Definitions

| Definition | Type | Description |
|------------|------|-------------|
| `iter_F` | `Nat -> Formula -> Formula` | n-fold F operator application |
| `CanonicalTask_forward` | Inductive | Nat-indexed forward Succ chain |
| `CanonicalTask_backward` | Inductive | Nat-indexed backward Succ chain |
| `CanonicalTask` | Definition | Int-indexed combined relation |
| `CanonicalTask_forward_MCS` | Inductive | Forward chain with MCS witnesses |

### Key Theorems

| Theorem | Statement | TaskFrame Axiom |
|---------|-----------|-----------------|
| `CanonicalTask_nullity_identity` | `CanonicalTask u 0 v <-> u = v` | Nullity Identity |
| `CanonicalTask_forward_comp` | Chain concatenation (Nat) | Forward Compositionality |
| `CanonicalTask_forward_comp_int` | Chain concatenation (Int, non-negative) | Forward Compositionality |
| `CanonicalTask_converse` | `CanonicalTask u n v <-> CanonicalTask v (-n) u` | Converse |
| `bounded_witness` | F^n(phi) in u, F^(n+1)(phi) not in u -> phi in v | Bounded Witness Corollary |

### Supporting Theorems

| Theorem | Description |
|---------|-------------|
| `CanonicalTask_forward_to_backward` | Forward chain -> backward chain |
| `CanonicalTask_backward_to_forward` | Backward chain -> forward chain |
| `CanonicalTask_forward_backward_flip` | Forward/backward duality (iff) |
| `CanonicalTask_backward_comp` | Backward chain concatenation |
| `succ_propagates_F_not` | F-propagation helper for bounded witness |

## Design Decisions

### Split Approach
Following the research recommendation, we defined `CanonicalTask_forward` and `CanonicalTask_backward` separately (Nat-indexed), then combined them into `CanonicalTask` (Int-indexed). This made individual direction proofs cleaner.

### MCS Chain for Bounded Witness
The bounded witness corollary required MCS assumptions for intermediate worlds. We introduced `CanonicalTask_forward_MCS` which carries MCS proofs at each step. In the canonical model, all worlds are MCS by construction, so this requirement is always satisfied in practice.

### Integer Indexing
The combined `CanonicalTask` uses Lean's Int representation:
- `Int.ofNat k` (k >= 0) maps to `CanonicalTask_forward` with k steps
- `Int.negSucc k` (represents -(k+1)) maps to `CanonicalTask_backward` with k+1 steps

## Verification

- `lake build` passes with no errors
- No sorries in the new file
- No new axioms introduced
- All TaskFrame axioms proven
- Bounded witness corollary proven

## Future Work

This module provides infrastructure for:
- Task 12+: Additional TaskFrame properties
- Task 13+: Integration with completeness proof
- Canonical model construction leveraging CanonicalTask

## Phase Completion

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | File Setup and Helper Definitions | COMPLETED |
| 2 | Forward and Backward Chain Definitions | COMPLETED |
| 3 | Combined CanonicalTask Definition | COMPLETED |
| 4 | Nullity Identity Axiom | COMPLETED |
| 5 | Forward Compositionality | COMPLETED |
| 6 | Converse Theorem | COMPLETED |
| 7 | Bounded Witness Corollary | COMPLETED |
| 8 | Final Verification and Documentation | COMPLETED |
