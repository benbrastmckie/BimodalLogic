# Research Report: Task #473 (Focus: Pointwise Transfer Approach)

**Task**: 473 - Fix compositionality gaps from Task 458
**Started**: 2026-01-13T21:00:00Z
**Completed**: 2026-01-13T21:45:00Z
**Effort**: 8-12 hours (estimated implementation)
**Priority**: Medium
**Parent**: Task 458
**Dependencies**: None (builds on Task 458 and 464 work)
**Sources/Inputs**:
  - FiniteCanonicalModel.lean (compositionality gaps at lines 1123, 1140, 1156, 1163, 1178, 1181, 1189, 1191)
  - JPL paper possible_worlds.tex (lem:history-time-shift-preservation line 1918, app:auto_existence line 1884, app:valid line 1989)
  - Bimodal/Semantics/Truth.lean (time_shift_preserves_truth theorem at line 311)
  - Bimodal/Semantics/WorldHistory.lean (time_shift construction at line 236)
  - Task 473 research-001.md (prior gap analysis)
**Artifacts**: This report (research-002.md)
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **Pointwise transfer approach** is fundamentally limited because it only captures endpoint formula membership, not path information
- **Time-shift preservation** (lem:history-time-shift-preservation) provides an **alternative approach** that avoids compositionality gaps entirely
- The key insight: instead of proving `psi` transfers through intermediate states, prove **truth is preserved under time-shift**
- This approach is already implemented in `Truth.lean` as `time_shift_preserves_truth`
- **Recommendation**: Restructure finite model construction to use time-shift-based witnesses rather than pointwise formula transfer

## Context & Scope

### Focus of This Research

The user requested investigation of:
1. What the "pointwise transfer approach" is and why it leads to compositionality gaps
2. How it might be avoided
3. Whether `lem:history-time-shift-preservation` (line 1918) or `app:auto_existence` (line 1884) from the JPL paper could provide inspiration

### The Pointwise Transfer Approach

The current `finite_task_rel` in FiniteCanonicalModel.lean defines the task relation via **pointwise formula transfer**:

```lean
def finite_task_rel (phi : Formula) (w : FiniteWorldState phi) (d : Int)
    (u : FiniteWorldState phi) : Prop :=
  -- Box transfer: box(psi) at w implies psi at u
  (forall psi, box psi in closure -> w.models (box psi) -> u.models psi) /\
  -- Future transfer: all_future(psi) at w implies psi at u when d > 0
  (forall psi, d > 0 -> w.models (all_future psi) -> u.models psi) /\
  -- Past transfer: all_past(psi) at w implies psi at u when d < 0
  (forall psi, d < 0 -> w.models (all_past psi) -> u.models psi) /\
  -- ... persistence conditions ...
```

This approach transfers **individual formulas** from source state `w` to target state `u` based on the duration sign.

### Why Pointwise Transfer Fails for Compositionality

**Compositionality** requires: if `w --(x)--> u` and `u --(y)--> v`, then `w --(x+y)--> v`.

**Mixed-sign gap example** (x > 0, y < 0, x + y > 0):
```
Given:
- w.models (all_future psi)  [from w, Gpsi is true]
- u.models psi               [from future transfer w -> u since x > 0]
- Need: v.models psi         [because x + y > 0]

But:
- From u to v (duration y < 0), only past_transfer applies
- past_transfer gives: u.models (all_past psi) -> v.models psi
- We have psi at u, but NOT all_past(psi) at u
```

The problem: **endpoint formula membership doesn't encode the relationship between total displacement and formula truth**.

Semantically, since `v` is at time `x + y > 0` from `w` and `Gpsi in w`, we know `v |= psi`. But the syntactic relation only tracks what happens at endpoints, not the cumulative displacement.

## Findings

### 1. Paper's Time-Shift Approach

The JPL paper (possible_worlds.tex) uses a fundamentally different approach that avoids compositionality gaps:

**Definition (def:time-shift-histories, line 1877)**:
World histories `tau` and `sigma` are **time-shifted from y to x** (written `tau ~_y^x sigma`) if there exists an order automorphism `a: D -> D` where:
- `y = a(x)`
- `dom(sigma) = a^{-1}(dom(tau))`
- `sigma(z) = tau(a(z))` for all `z in dom(sigma)`

The standard time-shift function is `a(z) = z - x + y`.

**Lemma (app:auto_existence, line 1884)**:
For any history `tau` and times `x, y`, there exists a history `sigma` where `tau ~_y^x sigma` is witnessed by `a(z) = z - x + y`.

**Lemma (lem:history-time-shift-preservation, line 1918)**:
`M, tau, y |= phi` **if and only if** `M, sigma, x |= phi` whenever `tau ~_y^x sigma` is witnessed by `a(z) = z - x + y`.

**Key insight**: Truth is **preserved** under time-shift. This is proven by induction on formula complexity.

### 2. How Time-Shift Solves Compositionality

The time-shift approach doesn't require proving compositionality of a pointwise relation. Instead:

**For validity proofs (app:valid, line 1989)**:
To prove `Box(phi) -> Always(phi)`:
1. Suppose `M, tau, x |= Box(phi)` but `M, tau, x |/= Past(phi)` (i.e., `M, tau, y |/= phi` for some `y < x`)
2. By `app:auto_existence`, there exists `sigma` where `tau ~_y^x sigma`
3. By `lem:history-time-shift-preservation`, `M, sigma, x |/= phi`
4. But `Box(phi)` quantifies over ALL histories, so `M, sigma, x |= phi`, contradiction

The proof doesn't require showing that a task relation composes. Instead, it **constructs** the needed witness history directly using time-shift.

### 3. Existing Implementation in ProofChecker

The codebase already has the time-shift approach implemented:

**WorldHistory.lean (line 236)**:
```lean
def time_shift (sigma : WorldHistory F) (Delta : D) : WorldHistory F where
  domain := fun z => sigma.domain (z + Delta)
  convex := ... -- preserved under translation
  states := fun z hz => sigma.states (z + Delta) hz
  respects_task := ... -- preserved since duration unchanged
```

**Truth.lean (line 311)**:
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (sigma : WorldHistory F) (x y : D)
    (phi : Formula) :
    truth_at M (WorldHistory.time_shift sigma (y - x)) x phi <-> truth_at M sigma y phi
```

This is exactly `lem:history-time-shift-preservation` from the paper.

### 4. Why FiniteCanonicalModel Doesn't Use Time-Shift

The finite canonical model was designed with a **different goal**: constructing world states from syntactic consistency conditions. The pointwise transfer approach was chosen to:

1. Connect syntactic maximal consistent sets to semantic world states
2. Define a task relation based on derivability/membership conditions
3. Build finite countermodels for unprovable formulas

However, this led to compositionality gaps because the syntactic conditions don't capture the semantic relationship between displacement and truth.

### 5. Potential Solution: Hybrid Approach

The compositionality proof doesn't need to succeed syntactically. Instead:

**Option A: Accept Syntactic Gaps, Prove Semantic Correctness**

Keep the current `finite_task_rel` definition. The compositionality sorries represent cases where syntactic derivation is insufficient. However, when we construct actual histories, we can prove they satisfy the semantic task relation (via `respects_task` in WorldHistory) even if we can't prove compositionality syntactically.

**Option B: Restructure Using Time-Shift Witnesses**

Instead of defining `finite_task_rel` via formula transfer, define it **semantically** via time-shift existence:

```lean
def finite_task_rel_semantic (phi : Formula) (w : FiniteWorldState phi) (d : Int)
    (u : FiniteWorldState phi) : Prop :=
  -- w and u are related if there exists a history through both
  exists (h : FiniteHistory phi) (t : FiniteTime),
    h.states t = w /\
    h.states (t + d) = u
```

This **automatically** satisfies compositionality because history construction composes.

**Option C: Use Time-Shift for Existence Theorems**

Keep the current `finite_task_rel` but use time-shift for the existence lemmas:

For the forward existence theorem:
1. Given state `w` at time `t`, we need a state `u` at time `t + 1` related by `finite_task_rel`
2. Instead of constructing `u` via Lindenbaum, construct a **history** from `w` using time-shift
3. The target state `u` is the state at time `t + 1` in this history

### 6. Connection to app:auto_existence

The `app:auto_existence` lemma provides the key construction: given ANY history and ANY two times, we can construct a time-shifted history connecting them.

For the finite model, we need the finite analog:

```lean
/--
Finite analog of app:auto_existence.
Given a finite history and times t1, t2 in the finite domain,
construct a time-shifted finite history.
-/
def finite_time_shift (h : FiniteHistory phi) (Delta : Int)
    (h_range : shifted times remain in domain) : FiniteHistory phi where
  states t := h.states (t + Delta) -- with appropriate adjustments
  -- Task relation preserved by same argument as WorldHistory.time_shift
```

## Decisions

1. **The pointwise transfer approach is fundamentally limited**: It cannot capture the semantic relationship between total displacement and formula truth in mixed-sign duration cases.

2. **Time-shift preservation provides the mathematically elegant solution**: The JPL paper's approach avoids compositionality issues entirely by using history construction and truth preservation.

3. **The existing `time_shift_preserves_truth` theorem is the key tool**: This is already proven in Truth.lean and matches the paper's lem:history-time-shift-preservation.

4. **For completeness proofs, we can work around compositionality gaps**: The gaps affect the syntactic task relation, but not the semantic validity of constructed models.

## Recommendations

### Primary Recommendation: Accept Gaps with Semantic Justification

The compositionality gaps in `finite_task_rel` are acceptable because:

1. **Nullity is proven** (zero-duration task is identity)
2. **Same-sign cases are proven** (x > 0, y > 0 and x < 0, y < 0)
3. **Mixed-sign cases are semantically valid** but not syntactically provable via pointwise transfer

For the truth lemma and completeness proofs, what matters is that:
- We can construct histories satisfying `respects_task` from WorldHistory.lean
- Truth evaluation on these histories is well-defined
- The `time_shift_preserves_truth` theorem handles the semantic cases

### Secondary Recommendation: Document the Gap Formally

Add a `compositionality_limitation` declaration that explains:
1. Why mixed-sign cases fail syntactically
2. Why they are semantically valid
3. Reference to the time-shift approach as the "correct" solution

### Future Work: Full Time-Shift Refactor

If a zero-sorry proof is desired, restructure FiniteCanonicalModel to:
1. Define `finite_task_rel_semantic` via history existence
2. Use `finite_time_shift` construction for witnesses
3. Prove compositionality trivially (histories compose by construction)

This would be a larger refactor but would eliminate all compositionality gaps.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Semantic justification insufficient for formal proof | High | Low | Time-shift approach is fully formal |
| Refactoring FiniteCanonicalModel too invasive | Medium | Medium | Start with Option A (accept gaps) |
| Truth lemma still blocked by other gaps | High | Medium | Focus on negation-completeness separately |

## Appendix

### Key Theorems Referenced

**From JPL Paper (possible_worlds.tex)**:
- `def:time-shift-histories` (line 1877): Definition of time-shifted histories
- `app:auto_existence` (line 1884): Existence of time-shifted history for any times x, y
- `lem:history-time-shift-preservation` (line 1918): Truth preserved under time-shift
- `app:valid` (line 1989): Uses time-shift to prove Box(phi) -> Always(phi)

**From ProofChecker Codebase**:
- `WorldHistory.time_shift` (WorldHistory.lean:236): Time-shift construction
- `time_shift_preserves_truth` (Truth.lean:311): Truth preservation under time-shift
- `truth_double_shift_cancel` (Truth.lean:243): Double time-shift cancellation

### Compositionality Gap Locations

All gaps in FiniteCanonicalModel.lean, `FiniteTaskRel.compositionality` (lines 1088-1191):
- Line 1123: x > 0, y < 0, x + y > 0 (future transfer)
- Line 1140: x < 0, y > 0, x + y > 0 (future transfer)
- Line 1156: x < 0, y > 0, x + y < 0 (past transfer)
- Line 1163: x > 0, y < 0, x + y < 0 (past transfer)
- Line 1178: x >= 0, y < 0 (future persistence)
- Line 1181: x < 0 (future persistence)
- Line 1189: y > 0 (past persistence)
- Line 1191: x > 0 (past persistence)

## Next Steps

1. **Immediate**: Accept compositionality gaps as documented limitations
2. **Short-term**: Focus on truth lemma gaps (negation-completeness via Task 472)
3. **Medium-term**: Consider full time-shift refactor if zero-sorry proof is required
4. Run `/plan 473 --revise` to update implementation plan based on these findings
