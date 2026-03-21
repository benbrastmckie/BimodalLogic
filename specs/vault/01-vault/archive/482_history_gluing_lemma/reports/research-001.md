# Research Report: Task #482

**Task**: 482 - Implement history gluing lemma
**Started**: 2026-01-13T21:10:00Z
**Completed**: 2026-01-13T21:25:00Z
**Effort**: 4-5 hours (implementation estimate)
**Priority**: Medium
**Parent**: Task 473
**Dependencies**: None
**Focus**: History gluing lemma to compose histories sharing common world state for SemanticTaskRelV2.compositionality
**Sources/Inputs**:
  - `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
  - Task 473 implementation summary
  - Mathlib search results for gluing patterns
**Artifacts**: This report (research-001.md)
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- The history gluing lemma is needed to eliminate 2 sorries in `SemanticTaskRelV2.compositionality`
- The core challenge: given two histories `h1` and `h2` that share a common state at `h1.states t1' = h2.states t2`, construct a single history witnessing the composed relation
- Three proof strategies identified: (A) Direct gluing via piecewise construction, (B) Using the same-history structure in completeness proofs, (C) Shift-and-align approach
- Recommended approach: Strategy (A) with careful bounds handling
- Key Mathlib pattern: `if t <= junction then h1.states (adjust t) else h2.states (adjust t)`

## Context & Scope

### Problem Statement

The `SemanticTaskRelV2.compositionality` theorem has two sorries at lines 2211 and 2214 in FiniteCanonicalModel.lean:

**Goal (case pos)**: Given:
- `h1 : FiniteHistory phi` witnessing `w -[x]-> u`
- `h2 : FiniteHistory phi` witnessing `u -[y]-> v`
- `h_states_eq : h1.states t1' = h2.states t2` (histories agree at junction)
- `t_final` satisfying time bounds

Need: `semantic_task_rel_v2 phi w (x + y) v`

**Goal (case neg)**: Same hypotheses but `t_final` does not exist within bounds.

### Why This Matters

This completes the semantic approach to compositionality (Path A from Task 473). The semantic approach makes compositionality trivial by construction IF we can show histories can be glued. Without this, the completeness proof cannot proceed.

## Findings

### 1. Key Data Structures

#### FiniteHistory Structure (lines 1677-1689)
```lean
structure FiniteHistory (phi : Formula) where
  states : FiniteTime (temporalBound phi) → FiniteWorldState phi
  forward_rel : ∀ t t', succ? k t = some t' → finite_task_rel phi (states t) 1 (states t')
  backward_rel : ∀ t t', pred? k t = some t' → finite_task_rel phi (states t) (-1) (states t')
```

Key insight: History validity is defined by unit-step relations between consecutive times.

#### FiniteTime Structure (lines 65-74)
```lean
def FiniteTime (k : Nat) := Fin (2 * k + 1)
def toInt (k : Nat) (t : FiniteTime k) : Int := (t : Int) - k
```

Time range: `[-k, k]` where `k = temporalBound phi`.

### 2. Gluing Requirements

For a glued history `h_glued` to be valid:
1. Must be defined on entire domain `FiniteTime (temporalBound phi)`
2. Must satisfy `forward_rel` at all consecutive pairs
3. Must satisfy `backward_rel` at all consecutive pairs
4. Must have `h_glued.states t_start = w` (start condition)
5. Must have `h_glued.states t_end = v` (end condition)

### 3. Proof Strategies

#### Strategy A: Piecewise Construction

Define `h_glued.states t` by cases:
```lean
h_glued.states t :=
  if toInt t <= toInt junction then
    h1.states (t - offset1)  -- Align t with h1's time frame
  else
    h2.states (t - offset2)  -- Align t with h2's time frame
```

**Pros**: Direct and explicit
**Cons**: Requires careful offset calculation and bounds proofs
**Complexity**: Medium-high

#### Strategy B: Same-History Observation

In the completeness proof context, both `h_wu` and `h_uv` typically arise from the SAME canonical history construction. If we can show `h1 = h2`, the proof is trivial.

**Pros**: Simple when applicable
**Cons**: Not always true in general

#### Strategy C: Shift-and-Extend

1. Time-shift `h1` so its endpoint aligns with origin
2. Time-shift `h2` so its startpoint aligns with origin
3. Extend by appending shifted sequences

**Pros**: Modular
**Cons**: Requires proving time-shift preserves consistency

### 4. Critical Lemmas Needed

#### Lemma 1: `finite_task_rel_preserves_consistency`
If `finite_task_rel phi w d u` and `w` is part of a consistent sequence, then the step to `u` maintains consistency.

**Status**: Implicitly proven by `forward_consistent_implies_task_rel` and `backward_consistent_implies_task_rel`.

#### Lemma 2: `consistent_at_junction`
If `h1.states t1' = h2.states t2`, then the unit-step relations at the junction can be composed.

**Status**: Needs explicit proof. The key insight is that consistency is determined by the underlying `FiniteWorldState`, not the history identity.

#### Lemma 3: `piecewise_consistent`
A piecewise-defined function satisfying consistency on each piece and at the junction is globally consistent.

**Status**: Standard mathematical fact, needs Lean implementation.

### 5. Bounds Analysis

#### Case: Bounds Satisfied (`case pos`)
When `t_final` exists satisfying `toInt t_final = toInt t1 + (x + y)`:
- Both `h1` and `h2` contribute parts of the glued history
- Junction at `h1.states t1' = h2.states t2`
- Need to verify offsets stay within `[-k, k]`

#### Case: Bounds Not Satisfied (`case neg`)
When no valid `t_final` exists:
- This happens when `|x + y| > 2k` (exceeds finite domain)
- **Important**: This case should NOT arise in the completeness proof because the formula complexity bounds the required temporal range
- Can use `False.elim` if we prove bounds always satisfied, OR
- Mark as impossible case with appropriate lemma

### 6. Mathlib Patterns Found

#### `Fin.append` (Mathlib.Data.Fin.Tuple.Basic)
```lean
def Fin.append {m n : Nat} (a : Fin m → α) (b : Fin n → α) : Fin (m + n) → α
```
Not directly applicable but shows the pattern for concatenating indexed functions.

#### `Function.extend` (Mathlib.Logic.Function.Basic)
```lean
def Function.extend (f : α → β) (g : α → γ) (j : β → γ) : β → γ
```
Useful for extending partial definitions.

#### `PartialEquiv.disjointUnion` (Mathlib.Logic.Equiv.PartialEquiv)
Shows how to union partial functions on disjoint domains - relevant pattern.

### 7. Goal State Analysis

**Case pos goal**:
```lean
⊢ semantic_task_rel_v2 phi w (x + y) v
```

Unfolding: need to provide `h_glued`, `t_start`, `t_end` such that:
- `toInt t_end = toInt t_start + (x + y)`
- `w = ofHistoryTime h_glued t_start`
- `v = ofHistoryTime h_glued t_end`

**Case neg goal**:
Same, but need to handle the impossibility of bounds or prove it leads to contradiction in context.

## Decisions

1. **Primary Strategy**: Strategy A (piecewise construction) - most general
2. **Junction handling**: Define junction time as `t1'` in `h1`'s frame
3. **Offset calculation**: Compute offsets to align both histories at junction
4. **Bounds case**: Prove using finite domain size constraints
5. **Neg case**: Prove contradiction from completeness proof context or leave as acceptable sorry (not blocking main result)

## Recommendations

### Implementation Plan

1. **Define `glue_histories`**:
```lean
noncomputable def glue_histories {phi : Formula}
    (h1 h2 : FiniteHistory phi)
    (t1' t2 : FiniteTime (temporalBound phi))
    (h_agree : h1.states t1' = h2.states t2)
    (t_new_origin : FiniteTime (temporalBound phi))
    (h_valid : valid_gluing_bounds ...) : FiniteHistory phi
```

2. **Prove junction consistency**:
```lean
theorem junction_forward_consistent {phi : Formula}
    (h1 h2 : FiniteHistory phi)
    (t1' t2 : FiniteTime (temporalBound phi))
    (h_agree : h1.states t1' = h2.states t2) :
    UnitStepForwardConsistent phi (h1.states t1') (h2.states (t2 + 1))
```

3. **Prove glued history valid**:
```lean
theorem glue_histories_valid :
    (glue_histories h1 h2 ...).forward_rel ∧
    (glue_histories h1 h2 ...).backward_rel
```

4. **Connect to compositionality**:
```lean
theorem compositionality_via_gluing (w u v : SemanticWorldState phi) (x y : Int)
    (h_wu : semantic_task_rel_v2 phi w x u)
    (h_uv : semantic_task_rel_v2 phi u y v) :
    semantic_task_rel_v2 phi w (x + y) v
```

### Verification Checklist

- [ ] `glue_histories` type-checks
- [ ] Junction consistency proofs compile
- [ ] Forward/backward relations preserved
- [ ] Compositionality theorem compiles without sorry
- [ ] `lake build` succeeds

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Offset arithmetic errors | High | Medium | Unit tests for specific cases |
| Bounds case impossible | Medium | Low | Prove contradiction from context |
| Performance (noncomputable) | Low | Certain | Accept for correctness proof |
| Missing lemmas for junction | Medium | Medium | Prove as needed during implementation |

## Appendix

### A. Related Sorries Analysis

1. **Line 2211** (`case pos`): Main gluing case - solvable with piecewise construction
2. **Line 2214** (`case neg`): Bounds exceeded - likely impossible in completeness context
3. **Line 1739** (`respects_task`): Uses compositionality - will be resolved by this fix

### B. Key Type Signatures

```lean
SemanticWorldState phi := Quotient (htSetoid phi)

semantic_task_rel_v2 phi w d u :=
  ∃ (h : FiniteHistory phi) (t t' : FiniteTime (temporalBound phi)),
    toInt t' = toInt t + d ∧
    w = ofHistoryTime h t ∧
    u = ofHistoryTime h t'
```

### C. Search Queries Used

1. `lean_local_search "glue"` - Found gluing patterns in Mathlib topology
2. `lean_local_search "FiniteHistory"` - Found project definition
3. `lean_local_search "compositionality"` - Found sorry locations
4. `lean_loogle "Fin.append"` - Found tuple concatenation pattern
5. `lean_loogle "Function.extend"` - Found extension pattern
6. `lean_leanfinder "gluing two paths"` - Found topological path gluing

## Next Steps

1. Run `/plan 482` to create implementation plan from this research
2. Implement `glue_histories` construction
3. Prove junction consistency lemmas
4. Connect to `SemanticTaskRelV2.compositionality`
5. Verify `lake build` succeeds with no new sorries
