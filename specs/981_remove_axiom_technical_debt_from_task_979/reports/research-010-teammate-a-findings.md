# Teammate A Findings: W=D Error Analysis

## Executive Summary

The `canonicalTaskFrame` construction in `DurationTransfer.lean` sets `WorldState := T` (where T is the duration type), creating a **degenerate** TaskFrame where W = D. This is NOT a "simplification" as research-009 suggests - it is a **fundamental architectural error** that violates the paper's specification of task semantics. The error has propagated throughout the completeness pipeline and is the root cause of the "domain connection" blockers documented in multiple tasks.

## Code Affected by W=D Assumption

### Primary Error Location

**File**: `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`
**Lines**: 189-217

```lean
noncomputable def canonicalTaskFrame
    (T : Type) [acg : AddCommGroup T] [lo : LinearOrder T] [oam : IsOrderedAddMonoid T] :
    TaskFrame T where
  WorldState := T                    -- <-- CRITICAL ERROR: W := D
  task_rel := canonicalTaskRel       -- task_rel w d w' = (w + d = w')
  ...
```

### Downstream Dependencies

| File | Line | Impact |
|------|------|--------|
| `Domain/CanonicalDomain.lean` | 221-232 | `denseCanonicalTaskFrame` inherits W=D error |
| `Domain/DiscreteTimeline.lean` | 611-616 | `discreteCanonicalTaskFrame` inherits W=D error |
| `StagedConstruction/Completeness.lean` | 21-22 | Documents blocker caused by W=D mismatch |
| `Bundle/CanonicalConstruction.lean` | 71-74 | Comments acknowledge W=D but don't fix it |

### Code That Uses W=D Implicitly

1. **`discreteTaskFrame`** (DurationTransfer.lean:231-235):
   - Uses `canonicalTaskFrame` which sets W = D

2. **`denseTaskFrame`** (DurationTransfer.lean:244-248):
   - Uses `canonicalTaskFrame` which sets W = D

3. **`denseCanonicalTaskFrame`** (CanonicalDomain.lean:221-231):
   - Uses `canonicalTaskFrame`, resulting in WorldState = TimelineQuot

4. **`discreteCanonicalTaskFrame`** (DiscreteTimeline.lean:611-616):
   - Uses `discreteTaskFrame`, resulting in WorldState = DiscreteTimelineQuot

## Why W=D is a Fundamental Error (Not Just Simplification)

### 1. Violates Paper Specification

The JPL paper "The Perpetuity Calculus of Agency" defines task frames as `F = (W, D, task_rel)` where:
- **W** = set of world states (INDEPENDENT of D)
- **D** = totally ordered abelian group of durations
- **task_rel : W x D x W -> Prop** = relation connecting world states via durations

These are THREE DISTINCT components. The canonical construction CONFLATES two of them.

### 2. Makes task_rel Trivial and Deterministic

When W = D, `canonicalTaskRel` becomes:
```lean
def canonicalTaskRel (w : T) (d : T) (w' : T) : Prop := w + d = w'
```

This is:
- **Deterministic**: Given w and d, there is exactly ONE w' satisfying task_rel
- **Trivial**: It's just group translation, not a genuine task relation
- **Degenerate**: Loses all expressiveness of task semantics

The paper's task_rel is intended to be a RELATION (potentially non-deterministic), not a function.

### 3. Destroys World History Structure

When W = D, world histories become:
```lean
states : D -> D  -- (not D -> W as intended)
```

This makes histories into "affine translations" where `h(t) = h(0) + t`. This collapses the semantic structure:
- There's effectively ONE history per starting point
- The Box operator becomes trivial (quantifying over "all histories" becomes quantifying over starting points)
- The modal/temporal interaction disappears

### 4. Causes the Completeness Wiring Gap

The `dense_completeness_components_proven` theorem in `StagedConstruction/Completeness.lean` documents:

> The gap is connecting the CanonicalMCS-based BFMCS (which has the proven truth lemma) to the TimelineQuot-based TaskFrame (which has the right temporal structure).

This gap exists PRECISELY because:
1. The BFMCS uses MCSs as world states (correct: W = MCS space)
2. The canonicalTaskFrame uses TimelineQuot as world states (incorrect: W = D)
3. These two cannot be connected because W and D are DIFFERENT concepts

### 5. The "Simplification" Argument is False

Research-009 claims: "W = D in canonical construction is a simplification, not a requirement"

This is WRONG because:
1. A **simplification** preserves semantic content - this destroys it
2. A **simplification** can be refined later - this creates fundamental type mismatches
3. The dense completeness blocker is CAUSED by this "simplification"

## Impact on Proof Structure

### What Breaks When We Separate W and D

1. **`canonicalTaskFrame` cannot be used directly** - It hardcodes W = D
2. **All `*TaskFrame` constructions downstream** - They inherit the error
3. **Truth lemma connection** - BFMCS (W = MCS) vs TaskFrame (W = D) mismatch

### What the Correct Architecture Looks Like

**Already implemented** in `Algebraic/ParametricCanonical.lean` and `Algebraic/SeparatedTaskFrame.lean`:

```lean
-- CORRECT: W != D
noncomputable def SeparatedCanonicalTaskFrame :
    TaskFrame (TimelineQuot root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskFrame (TimelineQuot root_mcs root_mcs_proof)
  -- WorldState = ParametricCanonicalWorldState (ALL MCSs)
  -- D = TimelineQuot (dense time domain)
  -- These are DIFFERENT types!
```

This is documented in `SeparatedTaskFrame.lean` (lines 6-34):

> The dense completeness blocker arose from conflating two architecturally distinct components:
> - **D** (Duration/Time Domain): Needs LinearOrder + DenselyOrdered (TimelineQuot provides this)
> - **W** (World States): Space of all MCSs (ParametricCanonicalWorldState provides this)

### Theorems That Depend on W = D

The following proofs use `canonicalTaskFrame` and thus assume W = D:

1. `canonicalTaskFrame.nullity_identity` - Works but semantically vacuous
2. `canonicalTaskFrame.forward_comp` - Works but proves wrong thing
3. `canonicalTaskFrame.converse` - Works but proves wrong thing
4. `denseCanonicalTaskFrame` - Inherits all above issues
5. `discreteCanonicalTaskFrame` - Inherits all above issues

## ROAD_MAP.md Documentation

### Proposed Dead End Entry

```markdown
### Dead End: W = D Canonical Construction

**Status**: ABANDONED
**Tried**: 2025-12-01 to 2026-03-17
**Related Tasks**: Task 956, Task 981, Task 982

*Rationale*: Attempted to simplify canonical model construction by identifying world states with the duration domain.

**What We Tried**:
`canonicalTaskFrame` in `DurationTransfer.lean` sets `WorldState := T` where T is the duration type. This creates a "translation frame" where task_rel(w, d, w') iff w + d = w'. The construction was adopted to simplify proofs by making world histories into affine translations.

**Why It Failed**:
1. **Violates paper specification**: JPL paper defines task frames as (W, D, task_rel) with W and D as DISTINCT components
2. **Makes task_rel degenerate**: The deterministic translation task_rel(w,d,w') = (w+d=w') loses all expressiveness
3. **Destroys world history structure**: Histories become trivial affine translations, eliminating modal/temporal interaction
4. **Causes completeness wiring gap**: BFMCS uses W = MCSs while TaskFrame uses W = D, creating irreconcilable type mismatch
5. **NOT a simplification**: Does not preserve semantic content; destroys essential structure

**Evidence**:
- [DurationTransfer.lean](Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean) - Error location (line 192)
- [Completeness.lean](Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean) - Documents resulting gap
- [SeparatedTaskFrame.lean](Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean) - Correct W/D separation
- [research-010-teammate-a-findings.md](specs/981_.../reports/research-010-teammate-a-findings.md) - This analysis

**Lesson**:
When the specification defines W and D as distinct types, NEVER conflate them in implementation - even if it seems to "simplify" the construction. Type identification that violates semantic distinctions creates irrecoverable architectural damage.

**Superseded By**: W/D-separated construction via `ParametricCanonicalTaskFrame` and `SeparatedCanonicalTaskFrame`
```

## Confidence Level

**HIGH**

Justification:
1. The JPL paper specification is unambiguous: W and D are distinct types
2. The code explicitly sets `WorldState := T` where T is the duration type
3. The `SeparatedTaskFrame.lean` module was created specifically to fix this error
4. The completeness wiring gap is documented as caused by W/D mismatch
5. Research-009's "simplification" claim is demonstrably false - the error destroys essential semantic structure

## Recommendations

1. **Mark canonicalTaskFrame as DEPRECATED** - It should not be used in new code
2. **Update ROAD_MAP.md** - Add Dead End entry documenting this architectural mistake
3. **Route all completeness work through SeparatedTaskFrame** - This is the correct architecture
4. **Remove research-009's "simplification" claim** - It is misleading and incorrect
5. **Consider deleting canonicalTaskFrame** - Or rename to `_degenerateTranslationFrame` to indicate its limited role

## Files Examined

- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` (error source)
- `Theories/Bimodal/Semantics/TaskFrame.lean` (correct definition)
- `Theories/Bimodal/Semantics/WorldHistory.lean` (shows W != D requirement)
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` (inherits error)
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` (documents blocker)
- `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean` (correct fix)
- `.claude/context/project/logic/domain/task-semantics.md` (paper specification)
- `specs/981_.../reports/research-009.md` (prior analysis claiming "simplification")
- `specs/ROAD_MAP.md` (current strategies documentation)
