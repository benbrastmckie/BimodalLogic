# Naming Convention Analysis: World States vs Time Indices

**Date**: 2026-03-21
**Task**: 22 (direct_multi_family_bundle)
**Source**: Reports 17-20 from task 006
**Focus**: Distinguish MCS (world states) from D (time/duration indices)

---

## 1. Key Conceptual Distinction

Reports 17-20 establish a fundamental semantic distinction that the codebase should reflect:

| Concept | Semantic Role | Current Name | Type |
|---------|--------------|--------------|------|
| **World State** | Instantaneous semantic content (WHAT is true) | `CanonicalMCS`, `MCS` | `Set Formula` |
| **Time/Duration Index** | Temporal coordinate (WHEN) | `D`, `Int`, `Rat`, `TimelineQuot` | Ordered group |
| **World History** | Trajectory through state space (function from times to states) | `FMCS`, `WorldHistory` | `D -> MCS` |
| **History Bundle** | Set of histories with modal coherence | `BFMCS` | `Set FMCS` |

### Critical Warning from FMCSDef.lean (lines 33-37)

The codebase already documents the core anti-pattern:

> **WARNING: W=D Conflation Error** (Task 15): Some deprecated constructions
> set `WorldState := D`, conflating world states (MCS) with time indices. This
> is architecturally incorrect: world states describe WHAT is true; time indices
> describe WHEN.

---

## 2. Findings from Reports 17-20

### 2.1 Report 17: Three-Place Canonical Task Relation

**Key terminology insight** (Section 2):

The report introduces `Succ(u, v)` for the immediate successor relation on MCS pairs. This naming is clear - "successor" applies to world states traversing a timeline, not to time indices themselves.

**Naming confusion identified**: The report uses `W` inconsistently:
- Line 233: `W and D must be DISTINCT types: W = MCSs (semantic content)`
- Yet in examples, `w` often appears as a variable for both worlds and intermediate witnesses

**Proposed terms from report**:
- `g_content(u)` = universal future commitments (already exists)
- `h_content(u)` = universal past commitments (already exists)
- `f_content(u)` = existential future obligations (NEW)
- `p_content(u)` = existential past obligations (NEW)

### 2.2 Report 18: Dense Three-Place Task Relation

**Critical conceptual clarification** (Section 2.3):

> `DenseTask(u, q, v)` where u, v are MCSs and q is a rational duration

This clearly separates:
- `u, v : MCS` (world states)
- `q : Rat` (duration/time index)

**Naming pattern**: The `DenseTask` name encodes the frame condition (dense) rather than the domain type. This is good - it describes the logic, not the implementation.

### 2.3 Report 19: Role in Representation Theorems

**Strongest terminological recommendation** (Section 2.2-2.3):

The report explicitly labels approaches as:
- **Duration-coarse**: Current `parametric_canonical_task_rel` (all positive d map to same CanonicalR)
- **Duration-precise**: Proposed `CanonicalTask` and `DenseTask` relations

This suggests naming convention:
- Keep `-coarse` suffix for approximate relations
- Use `-precise` or no suffix for exact duration tracking

### 2.4 Report 20: Succ-Based Bypass

**Implementation-ready naming** (Section 2):

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v                              -- (1) G-persistence
  ∧ f_content u ⊆ v ∪ f_content v              -- (2) F-step
```

The `Succ` relation is named for its semantic role (immediate succession in world state space), not for its type structure.

---

## 3. Current Naming Anti-Patterns

### 3.1 Variable Name Overloading

| Variable | Common Uses | Clarity Issue |
|----------|-------------|---------------|
| `W` | WorldState type, also witness MCS in proofs | Ambiguous between type and value |
| `M`, `M'` | MCS sets in proofs, also model in semantics | MCS vs TaskModel confusion |
| `t` | Time index, also sometimes MCS in FMCS | Time vs state confusion |
| `D` | Duration type, also domain in math contexts | Usually clear, but see TemporalDomain |

### 3.2 Type Name Ambiguity

| Current Name | Issue | Suggested Clarification |
|--------------|-------|------------------------|
| `CanonicalMCS` | Good - clearly an MCS | Keep |
| `TimelineQuot` | Good - clearly a timeline | Keep |
| `discreteClosedMCS` | Good - closed subset of MCS | Keep |
| `TemporalDomain` (Boneyard) | W=D conflation | Deprecated |
| `ChainFMCSDomain` | Somewhat unclear if this is times or states | Rename to `ChainTimeIndex`? |

### 3.3 FMCS Indexing Type Confusion

The core issue is that `FMCS D` uses `D` as the indexing type, but `D` is also the conventional name for duration. When we write `FMCS CanonicalMCS`, we're using MCS as indices (a proof-theoretic trick), which creates conceptual confusion.

**Recommendation**: Add documentation clarifying that `FMCS T` means "family indexed by T", where T can be:
- `Int` or `Rat` (semantic: times)
- `CanonicalMCS` (proof-theoretic: world states as indices)
- `TimelineQuot` (semantic: constructed timeline)

---

## 4. Proposed Naming Convention Changes

### 4.1 New Definitions (from Reports 17, 20)

```lean
-- Content extractors (add to TemporalContent.lean)
def f_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_future phi ∈ M}

def p_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_past phi ∈ M}

-- Successor relation (new file: SuccRelation.lean)
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

### 4.2 Variable Naming Guidelines

| Semantic Role | Recommended Variable | Avoid |
|--------------|---------------------|-------|
| World state (MCS) | `w`, `u`, `v`, `m`, `n` | `W` (reserve for type), `t` (reserve for time) |
| Time index | `t`, `s`, `r` | `w` (conflicts with world), `n` (conflicts with integer world) |
| Duration | `d`, `delta`, `q` (rationals) | `t` (conflicts with time point) |
| History/FMCS | `tau`, `sigma`, `fam` | `h` (conflicts with h_content) |
| Bundle/BFMCS | `B`, `bundle` | - |

### 4.3 Type Naming Guidelines

| Category | Pattern | Examples |
|----------|---------|----------|
| World states | `*MCS`, `*WorldState` | `CanonicalMCS`, `ParametricCanonicalWorldState` |
| Time indices | `*Timeline*`, `*TimeIndex` | `TimelineQuot`, `DiscreteTimelineQuot` |
| Relations | `*Task`, `*Rel`, `*R` | `CanonicalTask`, `DenseTask`, `CanonicalR` |
| Families | `*FMCS`, `*Family` | `SuccChainFMCS`, `ChainFMCS` |
| Bundles | `*BFMCS`, `*Bundle` | `ModallyCoherentBFMCS` |

### 4.4 Docstring Template

Every definition involving both world states and time indices should include:

```lean
/--
[Description]

**Semantic types**:
- World states: [type] (instances of: MCS, world contents)
- Time indices: [type] (instances of: duration, temporal position)
- History: [type] (function from times to states)

**Not to be confused with**: [common conflation warnings]
-/
```

---

## 5. Files Requiring Updates

### 5.1 High Priority (Direct Multi-Family Implementation)

| File | Current Issue | Recommended Change |
|------|---------------|-------------------|
| `Bundle/ClosedFlagIntBFMCS.lean` | Uses `discreteClosedMCS` as both state and index | Clarify docstrings |
| `Bundle/FMCSDef.lean` | Good documentation (lines 33-37) | Add variable naming guide |
| `Bundle/ModallyCoherentBFMCS.lean` | BFMCS structure | Verify W/D separation |

### 5.2 Medium Priority (New Definitions)

| File | Action |
|------|--------|
| `Core/TemporalContent.lean` | Add `f_content`, `p_content` |
| `Bundle/SuccRelation.lean` (NEW) | Define `Succ` relation |
| `Bundle/CanonicalTask.lean` (NEW) | Define three-place task relation |

### 5.3 Low Priority (Consistency Sweep)

| File | Issue |
|------|-------|
| `Domain/DurationTransfer.lean` | Good deprecation warnings, keep |
| `StagedConstruction/*.lean` | Verify consistent use of timeline vs state variables |
| `Algebraic/*.lean` | Check for W=D patterns |

---

## 6. Immediate Recommendations for Task 22

For the direct multi-family bundle implementation:

1. **Use `discreteClosedMCS` only for world states**, never as time indices
2. **Index FMCS families by `Int`** (semantic time), not by MCS
3. **Variable naming**: Use `w, u, v` for MCS members, `t, s` for time indices
4. **Document the mapping**: Each family maps `t : Int -> mcs : Set Formula`

### Concrete Code Pattern

```lean
-- Good: Clear separation
structure DirectFamilyBundle where
  -- World states: the closed MCS members that form our families
  closed_states : Set (Set Formula)
  h_closed : ∀ m ∈ closed_states, SetMaximalConsistent m ∧ discrete_closed m

  -- Time-indexed families: each closed state anchors a family over Int
  family_at : (m : Set Formula) -> m ∈ closed_states -> FMCS Int

  -- The family at m has m at time 0
  anchor : ∀ m hm, (family_at m hm).mcs 0 = m

-- Bad: Conflated indices
structure ConfusedBundle where
  families : Set (FMCS (Set Formula))  -- Using MCS as time index!
```

---

## 7. Summary

The reports 17-20 consistently emphasize:

1. **MCS = world states** (semantic content, WHAT is true)
2. **D = time indices** (temporal position, WHEN)
3. **FMCS = world history** (trajectory: function from time to state)
4. **BFMCS = history bundle** (set of histories with modal coherence)

The naming convention changes focus on making this distinction explicit in:
- Variable names (w/u/v for states, t/s for times)
- Type names (*MCS for states, *Timeline* for times)
- Docstrings (explicit "Semantic types" section)

For task 22's direct multi-family bundle, the key is to index families by `Int` (time) and populate them with `discreteClosedMCS` members (states), maintaining the clean separation that avoids the documented W=D conflation error.
