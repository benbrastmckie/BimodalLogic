# Research Report: Task #981 - W=D Error Analysis and Representation Theorem Redesign

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-17
**Session**: sess_1773762158_31046
**Mode**: Team Research (2 teammates, logic domain override)
**Domain**: Logic/Mathematical — architectural analysis of task semantics

---

## Executive Summary

**CRITICAL FINDING**: The `canonicalTaskFrame` in `DurationTransfer.lean` (line 189) is a **fundamental architectural error**, not a simplification. It sets `WorldState := T` (W = D), violating the paper's specification that W and D are distinct types. Research-009's claim that this is "a simplification, not a requirement" is **demonstrably wrong** — the W=D identification:

1. Makes `task_rel` trivially deterministic (group translation), losing all semantic expressiveness
2. Destroys world history structure (histories collapse to affine translations)
3. Causes the completeness wiring gap directly (BFMCS uses W = MCSs; TaskFrame uses W = D — irreconcilable type mismatch)

**CRITICAL DISCOVERY**: The **correct architecture is already implemented**:
- **W** = `ParametricCanonicalWorldState` (ALL MCSs) — in `Algebraic/ParametricCanonical.lean`
- **D** = `TimelineQuot` (via Cantor isomorphism) — in `Domain/DFromCantor.lean`
- **task_rel** = `parametric_canonical_task_rel` (using `CanonicalR`) — sorry-free

**The remaining work** is NOT architectural redesign. It is connecting the existing FMCS truth lemma (over `Int`/`CanonicalMCS`) to the separated TaskFrame (over `TimelineQuot FMCS`).

---

## Part 1: W=D is a Fundamental Error

### 1.1 Primary Error Location

**File**: `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean:189-217`

```lean
noncomputable def canonicalTaskFrame
    (T : Type) [acg : AddCommGroup T] [lo : LinearOrder T] [oam : IsOrderedAddMonoid T] :
    TaskFrame T where
  WorldState := T                    -- CRITICAL ERROR: W := D
  task_rel := canonicalTaskRel       -- task_rel w d w' = (w + d = w')
```

### 1.2 Downstream Propagation

| File | Construct | Impact |
|------|-----------|--------|
| `Domain/CanonicalDomain.lean:221-231` | `denseCanonicalTaskFrame` | Inherits W=D via `canonicalTaskFrame` |
| `Domain/DiscreteTimeline.lean:611-616` | `discreteCanonicalTaskFrame` | Inherits W=D via `discreteTaskFrame` |
| `StagedConstruction/Completeness.lean` | Wiring gap documentation | Gap is CAUSED by W=D mismatch |

### 1.3 Why W=D is NOT a Simplification

Research-009 (report-009.md) stated:
> "W = D in canonical construction is a simplification, not a requirement"

This is **incorrect**. A simplification preserves semantic content; the W=D identification destroys it:

1. **Violates paper specification**: JPL paper "The Perpetuity Calculus of Agency" defines task frames as `F = (W, D, task_rel)` with W and D as **distinct** components. The paper's task_rel is a **relation** W × D × W → Prop — not a function.

2. **Trivializes task_rel**: `canonicalTaskRel w d w' := w + d = w'` is deterministic — given w and d, exactly ONE w' satisfies it. This eliminates all non-determinism from task semantics, losing the expressiveness intended by the paper.

3. **Destroys world history structure**: When W = D, histories become `states : D → D`, reducing to affine translations `h(t) = h(0) + t`. This makes the Box operator trivial (quantifying over "all histories" ≡ quantifying over starting points) and eliminates modal/temporal interaction.

4. **Causes the wiring gap directly**: The dense completeness gap documented in ROAD_MAP.md is:
   - BFMCS uses W = MCSs (correct: W = semantic content)
   - canonicalTaskFrame uses W = TimelineQuot (incorrect: W = D)
   - These cannot be connected because they define *different things* as world states

### 1.4 ROAD_MAP.md Dead End Entry

The following should be added to `specs/ROAD_MAP.md` under "Dead Ends":

```markdown
### Dead End: W = D Canonical Construction

**Status**: ABANDONED
**Tried**: 2025-12-01 to 2026-03-17
**Related Tasks**: Task 956, Task 981, Task 982

**What We Tried**:
`canonicalTaskFrame` in `DurationTransfer.lean` identifies world states with the duration
domain (WorldState := T). Creates a "translation frame" where task_rel(w, d, w') ≡ w + d = w'.

**Why It Failed**:
1. Violates paper spec: W and D are DISTINCT types in F = (W, D, task_rel)
2. task_rel becomes degenerate deterministic translation, not a genuine relation
3. World histories collapse to affine translations, eliminating modal semantics
4. Causes irreconcilable type mismatch with BFMCS (BFMCS: W = MCSs; canonicalTaskFrame: W = D)
5. This is NOT a simplification — it destroys essential semantic structure

**Lesson**: Never conflate W and D even if it seems to simplify construction.
W must encode semantic content (MCSs); D must encode temporal duration (timeline).

**Superseded By**: `ParametricCanonicalTaskFrame` in `Algebraic/SeparatedTaskFrame.lean`
```

---

## Part 2: The Correct Architecture (Already Implemented)

### 2.1 What EXISTS in the Codebase

The W/D-separated architecture is **already implemented** and sorry-free:

| Component | File | Status |
|-----------|------|--------|
| W = `ParametricCanonicalWorldState` | `Algebraic/ParametricCanonical.lean:63-64` | ✅ DONE |
| D = `TimelineQuot` (via Cantor) | `Domain/DFromCantor.lean` | ✅ DONE |
| `task_rel` = `parametric_canonical_task_rel` | `Algebraic/ParametricCanonical.lean:85-89` | ✅ DONE |
| TaskFrame axioms (all 3) | `Algebraic/ParametricCanonical.lean:100-183` | ✅ DONE (sorry-free) |
| WorldHistory (`separatedHistory`) | `Algebraic/SeparatedHistory.lean` | ✅ DONE |
| Shift-closed Omega | `Algebraic/SeparatedTaskFrame.lean` | ✅ DONE |

### 2.2 W: ParametricCanonicalWorldState

```lean
-- Algebraic/ParametricCanonical.lean:63-64
def ParametricCanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }
```

This is the set of ALL maximal consistent sets — correct because:
- Independent of D (no duration type needed)
- Contains ALL witnesses for F(φ)/P(φ) satisfiability
- Each MCS determines truth of all formulas (canonical model property)

### 2.3 D: TimelineQuot via Cantor

```
TimelineQuot ≃o ℚ  (cantor_iso, proven sorry-free)
```

The temporal domain D emerges from syntax:
1. Canonical timeline properties: countable, dense, no endpoints (from axioms)
2. Cantor isomorphism discovers D as isomorphic to ℚ (not imported)
3. `(ℚ, +, ≤)` structure inherited via the isomorphism

**This satisfies the D-from-syntax constraint** (no Int/Rat import).

### 2.4 task_rel: parametric_canonical_task_rel

```lean
-- Algebraic/ParametricCanonical.lean:85-89
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0
```

Where `CanonicalR M N := g_content M ⊆ N` (the G-operator accessibility relation).

This is a **genuine** (non-degenerate) relation W × D × W → Prop:
- **Non-deterministic**: Multiple N can be related to M at the same d (CanonicalR is not a function)
- **Semantically meaningful**: CanonicalR encodes the G-modality accessibility
- **All 3 TaskFrame axioms proven sorry-free**

---

## Part 3: The Actual Remaining Gap

### 3.1 What the Gap Is

The remaining completeness gap (per ROAD_MAP.md Phase 8 Wiring) is **not** about W/D separation — it is about connecting:

- **Piece 1**: Existing `canonical_truth_lemma` (FMCS over `Int` or `CanonicalMCS`)
- **Piece 2**: Separated TaskFrame (uses `D = TimelineQuot`)

The truth lemma needs to be proven for FMCS over `TimelineQuot` (not `Int`/`CanonicalMCS`).

### 3.2 Why This Gap Exists

The FMCS construction was originally built with `D = Int` (or `D = CanonicalMCS`). The Cantor-based D-from-syntax construction produces `D = TimelineQuot`. These have the same order type (both ≃o ℚ) but are different types.

The `timelineQuotFMCS` already exists in `TimelineQuotCanonical.lean` — the gap is proving the truth lemma for it.

### 3.3 Resolution Path

**Option A (Direct, Preferred)**:
Build the truth lemma directly for FMCS TimelineQuot:
- `timelineQuotFMCS` already exists
- Adapt `canonical_truth_lemma` proof from `CanonicalConstruction.lean`
- Should transfer with minimal changes (same logical structure)

**Option B (Transfer)**:
Prove a domain-isomorphism transfer theorem:
> If truth lemma holds for FMCS with D ≃o D', then it holds for FMCS with D'

More elegant but adds complexity.

---

## Part 4: Conflicts and Resolutions

### 4.1 Research-009 Conflict

| Claim (research-009) | Verdict | Resolution |
|---------------------|---------|------------|
| "W=D is a simplification, not a requirement" | **FALSE** | W=D destroys essential semantic structure; it is a fundamental error |
| "Covering lemma difficulty is orthogonal to W vs D" | **FALSE** | The wiring gap is caused by W=D; proper architecture avoids the discrete covering entirely |
| "No code refactoring needed" | **FALSE** | The W=D code in DurationTransfer.lean must be deprecated/removed |
| "No changes needed to task-semantics.md" | **TRUE** | Documentation is correct; code must change |

### 4.2 Prior Research Conflict Summary

Research-009 failed to recognize that `SeparatedTaskFrame.lean` and `ParametricCanonical.lean` already implement the correct architecture. It focused on defending the W=D simplification rather than identifying that the fix already existed.

---

## Part 5: Synthesis and Recommendations

### 5.1 Immediate Actions

1. **Add ROAD_MAP.md Dead End entry** for W=D canonical construction (see Section 1.4)
2. **Deprecate `canonicalTaskFrame`** in `DurationTransfer.lean` with a comment pointing to `ParametricCanonicalTaskFrame`
3. **Update task 981 scope**: The task is NOT about the discrete covering lemma — it is about completing the truth lemma for FMCS TimelineQuot to wire the separated TaskFrame to completeness

### 5.2 Scope for Task 981

The task's real scope (removing `discrete_Icc_finite_axiom`) can be approached by:
- **Avoiding the discrete case entirely**: Use the dense timeline (TimelineQuot ≃o ℚ) which needs no discreteness axiom
- **Completing FMCS TimelineQuot truth lemma**: This is the remaining gap; the discrete covering was a red herring caused by the W=D approach

### 5.3 Files That Need Change

| File | Change Required |
|------|----------------|
| `Domain/DurationTransfer.lean` | Deprecate `canonicalTaskFrame` (mark as DEPRECATED, add warning comment) |
| `specs/ROAD_MAP.md` | Add Dead End entry for W=D approach |
| `Domain/CanonicalDomain.lean` | Deprecate `denseCanonicalTaskFrame` |
| `Domain/DiscreteTimeline.lean` | Deprecate `discreteCanonicalTaskFrame` |

### 5.4 Files That Are CORRECT (No Change Needed)

| File | Status |
|------|--------|
| `Algebraic/ParametricCanonical.lean` | Correct W/D separation, sorry-free |
| `Algebraic/SeparatedTaskFrame.lean` | Correct architecture |
| `Algebraic/SeparatedHistory.lean` | Correct WorldHistory |
| `Domain/DFromCantor.lean` | Correct D-from-syntax |
| `Semantics/TaskFrame.lean` | Correct definition |

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | W=D error identification, affected code, ROAD_MAP entry | completed | HIGH |
| B | Proper representation design, current implementation status, gap analysis | completed | HIGH |

---

## Decisions

1. **W=D is a fundamental architectural error, not a simplification** — research-009 was wrong
2. **The correct architecture (W ≠ D) already exists** in `Algebraic/` module, sorry-free
3. **`canonicalTaskFrame` must be deprecated**, not just documented
4. **The discrete covering lemma was a false lead** — caused by incorrectly pursuing W=D + discrete timeline
5. **Task 981's path forward**: complete FMCS TimelineQuot truth lemma (Option A)
6. **ROAD_MAP.md needs a Dead End entry** explicitly marking W=D as abandoned

---

## References

- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` — W=D error location
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` — Correct architecture
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean` — W/D separation
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean` — WorldHistory
- `Theories/Bimodal/Semantics/TaskFrame.lean` — TaskFrame definition
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` — inherits W=D error
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` — inherits W=D error
- `specs/ROAD_MAP.md` — Strategic context
- `specs/981_.../reports/research-010-teammate-a-findings.md` — W=D error analysis
- `specs/981_.../reports/research-010-teammate-b-findings.md` — Representation design
- `specs/981_.../reports/research-009.md` — Prior analysis (conflicting claims resolved here)
