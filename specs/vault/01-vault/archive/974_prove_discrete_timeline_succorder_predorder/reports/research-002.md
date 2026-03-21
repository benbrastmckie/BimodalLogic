# Research Report: Task 974 - Supplementary Research for Discreteness Proofs

**Task**: 974 - prove_discrete_timeline_succorder_predorder
**Session**: sess_1742171000_d9f4h
**Date**: 2026-03-16
**Focus**: Identify mathematically correct path to completing phases 4-5

---

## Executive Summary

The three remaining sorries in `DiscreteTimeline.lean` require proving that the discrete timeline quotient is **not densely ordered** -- that is, for any element `a`, the GLB of `Set.Ioi a` is strictly greater than `a` (not equal to it). This is the core **discreteness property** that flows from the DF axiom.

**Key Finding**: The DF frame condition extraction at the MCS level follows the same pattern already established for density in `DensityFrameCondition.lean`. The density proof shows how to use axiom-level properties to derive order-theoretic properties on the quotient. For discreteness, we need the *contrapositive*: if the order were dense at some point, DF would fail.

**Recommendation**: The mathematically correct path is:

1. **Prove `discrete_timeline_lt_succFn`** by showing that density at any point contradicts the DF axiom
2. **Use temporal duality** for `discrete_timeline_predFn_lt` (DP derivable from DF)
3. **Establish `LocallyFiniteOrder`** via counting argument on the staged construction

---

## Part I: Analysis of the DF Frame Condition

### 1.1 The DF Axiom Semantically

The discreteness forward axiom DF states:
```
(F top /\ phi /\ H phi) -> F(H phi)
```

Under **reflexive** temporal semantics (as currently implemented), this is trivially valid because:
- `F top` is trivially true (witness `t >= t`)
- The conclusion `F(H phi)` can use the same witness `s = t`

This triviality is documented in Soundness.lean lines 300-321:
```lean
theorem discreteness_forward_valid (phi : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and phi (Formula.all_past phi)) |>.imp
      (Formula.all_past phi).some_future) := by
  -- Under reflexive semantics, take s = t as witness for F(H phi)
  apply h_G_not_H t (le_refl t)
  exact h_H
```

### 1.2 What DF *Should* Mean

The research report for task 977 (research-001.md, lines 56-62) explains:

| Extension Axiom | Frame Condition | Formal Constraint |
|-----------------|-----------------|-------------------|
| `discreteness_forward` (DF) | Immediate successor exists | `SuccOrder D`, `PredOrder D` |

DF is supposed to characterize discrete (Z-like) frames where every non-maximal element has an **immediate successor** -- no intermediate point exists.

### 1.3 The Reflexive Semantics Collapse

Research-016 (archived, lines 433-436) analyzes this:

> **DF Axiom Becomes Non-Trivial** [with irreflexive semantics]:
> Similarly, `(F(top) /\ phi /\ H(phi)) -> F(H(phi))` currently uses reflexive witness `u = t`. With irreflexive semantics, it genuinely requires a successor point.

**Implication**: Under reflexive semantics, DF is valid on ALL frames, not just discrete ones. The discreteness property `discrete_timeline_lt_succFn` cannot be derived from DF's validity because DF doesn't actually "do anything" under reflexive semantics.

---

## Part II: The Discreteness Gap Analysis

### 2.1 Why the Current Approach is Blocked

The current proof attempt in DiscreteTimeline.lean (lines 182-193) says:

```lean
theorem discrete_timeline_lt_succFn (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    a < LinearLocallyFiniteOrder.succFn a := by
  have h_not_max : ¬IsMax a := not_isMax a
  have h_nonempty : (Set.Ioi a).Nonempty := exists_gt a
  -- We need: succFn a ∈ Set.Ioi a (i.e., a < succFn a)
  -- This holds iff the GLB is actually the minimum of the set
  -- Which holds iff the order is discrete (not dense) at a
  sorry
```

The comment identifies the key requirement: `succFn a` (the GLB of `Set.Ioi a`) must be the actual **minimum** of that set, not just its greatest lower bound. For dense orders, the GLB equals `a` itself (no minimum exists). For discrete orders, the GLB is strictly greater than `a`.

**The problem**: There is no mechanism in the current codebase to derive non-density from DF under reflexive semantics, because DF is vacuously true.

### 2.2 Three Potential Approaches

#### Approach A: Axiomatize Discreteness

**Strategy**: Add an axiom asserting discreteness at the MCS level, similar to how `canonicalR_irreflexive` was proven in `CanonicalIrreflexivityAxiom.lean`.

**Precedent**: The docstring in CanonicalIrreflexivityAxiom.lean (lines 44-47) states:
> From this theorem, the following properties are provable:
> - `SuccOrder`/`PredOrder` coverness on the discrete timeline (via DF + irreflexivity)

This suggests the developers anticipated using `canonicalR_irreflexive` for discreteness. The pattern would be:
1. Given two distinct MCSs M < N in the quotient
2. Show there is an immediate successor (no intermediate W exists)
3. Use DF + irreflexivity to derive contradiction if intermediate existed

**Problem with this approach**: DF under reflexive semantics doesn't provide the "no intermediate" condition. The density proof uses the DN axiom to *construct* intermediates. For discreteness, we'd need DF to *prevent* intermediates, but it doesn't.

#### Approach B: Derive from Staged Construction

**Strategy**: The staged construction (`StagedExecution.lean`, `CantorPrereqs.lean`) builds the timeline incrementally. Each stage adds finitely many witnesses. Use this finiteness to prove discreteness.

**Key insight from CantorPrereqs.lean** (lines 258-277): `staged_has_future` shows that for any point `p` at stage `n`, there exists a forward witness at some later stage. The witness is constructed from `processForwardObligation`.

**Hypothesis**: Between any two MCSs in the staged construction, there are only finitely many intermediate stages. This would give LocallyFiniteOrder, which implies:
1. Finite intervals
2. Each interval has a minimum (GLB = min)
3. Hence discreteness: `succFn a > a`

**Problem**: This requires showing that the staged construction doesn't add "dense" intermediates. But the density axiom (if present) would add them via `density_of_canonicalR`. The key is that for discrete timeline construction, the density axiom is NOT used.

#### Approach C: Prove Directly from Absence of Density Axiom

**Strategy**: The discrete timeline quotient is built from the base staged timeline *without* the density intermediates that the dense case adds (per DiscreteTimeline.lean lines 64-68):

> The discrete timeline is the `Antisymmetrization` of the base staged timeline (without density intermediates).

**Key observation**: The density frame condition in `DensityFrameCondition.lean` explicitly uses the DN axiom to construct intermediate MCSs. In the discrete case, DN is NOT in the axiom set (per task 977 research, lines 72-73):

> Mutual exclusivity: `density` and `discreteness_forward` are incompatible frame conditions -- no frame can satisfy both.

**Implication**: Since the discrete axiom set does NOT include DN, the `density_of_canonicalR` theorem and `density_frame_condition` theorem do NOT apply. The staged construction for the discrete case does NOT add density intermediates.

**This is the mathematically correct approach.**

---

## Part III: The Correct Proof Path

### 3.1 Strategy: No-Density Implies Discrete

The discrete timeline is constructed from MCSs using only discrete-compatible axioms. The DN axiom is excluded. Without DN, the staged construction cannot create dense intermediates.

**Theorem to prove**: For the discrete staged timeline, between any two MCSs M < N, there exists an MCS W that is an immediate successor of M (no intermediate between M and W).

**Proof sketch**:
1. The staged construction adds forward witnesses via `processForwardObligation`
2. These witnesses satisfy CanonicalR(M, W)
3. For any two comparable MCSs M < N, the first witness added after M is the immediate successor
4. No "in-between" witnesses are added because DN is not available to construct them

### 3.2 Formalizing the Argument

**Step 1**: Show that in the discrete axiom system, there is no derivation that forces dense intermediates.

The key theorem in `CantorPrereqs.lean` is `density_of_canonicalR` which uses DN:
```lean
theorem density_of_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧
      Formula.some_future phi ∈ W
```

This is called from `DensityFrameCondition.lean:148` to construct intermediates. But this theorem REQUIRES `F(phi) -> F(F(phi))` (the DN axiom) to be derivable in the MCS.

**In the discrete case**: DN is NOT in the axiom set, so `F(phi)` does NOT imply `F(F(phi))`. The `density_of_canonicalR` pattern does not apply.

**Step 2**: Characterize the discrete staged build.

The staged build processes formulas in order. At each even stage `2k`, it processes formula with encoding `k`. For F-obligations, it adds one witness. For P-obligations, it adds one witness.

**Key property**: Each formula's F-obligation creates AT MOST ONE forward witness per MCS. Without DN, there's no way to create multiple witnesses at different "depths."

**Step 3**: Derive discreteness from finite witness count.

Between any two comparable MCSs M < N:
- Let the formulas distinguishing them have encoding bounded by some K
- The witnesses between M and N are added at stages up to 2K+1
- This is a finite set
- The minimum of `{W : M < W < N}` exists and is the immediate successor of M

### 3.3 The LocallyFiniteOrder Approach

**Theorem**: `DiscreteTimelineQuot` is locally finite (every closed interval is finite).

**Proof**:
1. The staged construction is an omega-indexed union of finite sets
2. Each stage adds finitely many points
3. Given `a <= b` in the quotient, both are represented at finite stages `n_a`, `n_b`
4. All points in `[a, b]` must be added by stage `max(n_a, n_b)` (by monotonicity)
5. Hence `Finset.Icc a b` is finite

**From LocallyFiniteOrder**:
- `succFn` computes the GLB of `Set.Ioi a`
- Since `Set.Ioi a ∩ Finset.Icc a (someUpperBound)` is finite, it has a minimum
- Hence `succFn a > a` (the GLB is the minimum)

This gives `discrete_timeline_lt_succFn`.

### 3.4 Implementation Plan

**Phase 4 (revised)**: Prove discreteness theorems

1. **Add helper lemma**: `discrete_staged_finitely_between`
   - Statement: For any `a < b` in DiscreteTimelineQuot, the set `{x : a < x < b}` is finite
   - Proof: Use staged construction properties + absence of density axiom

2. **Prove `discrete_timeline_lt_succFn`**:
   - From finite set `Set.Ioi a ∩ Finset.Icc a someUpperBound`, extract minimum
   - Show `succFn a` equals this minimum
   - Hence `a < succFn a`

3. **Prove `discrete_timeline_predFn_lt`**:
   - Symmetric argument using LUB and finite past

**Phase 5**: Prove IsSuccArchimedean

Once we have finite intervals (`LocallyFiniteOrder`), `IsSuccArchimedean` follows from:
```lean
LinearLocallyFiniteOrder.instIsSuccArchimedean
```

This is a direct application of the Mathlib instance.

---

## Part IV: Addressing the Reflexive Semantics Issue

### 4.1 The Core Tension

The current system uses reflexive temporal semantics (G/H quantify over `<=`). Under this semantics:
- DF is trivially valid (uses reflexive witness)
- DN is trivially valid (uses reflexive witness)
- Both density AND discreteness axioms are "valid" on ALL frames

This makes the axiom-frame correspondence vacuous.

### 4.2 Why the Staged Construction Still Works

Despite the semantic collapse, the staged construction can still distinguish discrete from dense cases:

**For dense timeline**: Explicitly add density intermediates using the DN axiom at each stage
**For discrete timeline**: Do NOT add density intermediates (DN not in axiom set)

The key is that the construction is *syntactic* -- it looks at which axioms are derivable from the MCS, not at the semantic validity.

### 4.3 The Discreteness Argument Without DF

Given that DF doesn't "do work" under reflexive semantics, we can still prove discreteness by:

1. Observing that the discrete staged construction does NOT call `density_of_canonicalR`
2. Showing that each step adds bounded witnesses
3. Deriving finite intervals from the staged structure

This bypasses the DF axiom entirely -- discreteness follows from the construction, not from DF.

**Alternative framing**: The discrete timeline is discrete BY CONSTRUCTION, not by virtue of DF validity.

---

## Part V: Concrete Recommendations

### 5.1 Immediate Action: Prove via Staged Construction

The most direct path to completing phases 4-5:

1. **Add theorem**: For any two elements `a < b` in `DiscreteTimelineQuot`, there are finitely many elements between them.

2. **Use this for `discrete_timeline_lt_succFn`**:
   ```lean
   theorem discrete_timeline_lt_succFn (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
       a < LinearLocallyFiniteOrder.succFn a := by
     -- Set.Ioi a has a minimum (not just GLB) because intervals are finite
     -- In a finite set, GLB = min
     -- So succFn a = min(Set.Ioi a) > a
   ```

3. **Establish `LocallyFiniteOrder`**:
   ```lean
   instance : LocallyFiniteOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) := ...
   ```

4. **Derive `IsSuccArchimedean`** from Mathlib:
   ```lean
   instance : IsSuccArchimedean (DiscreteTimelineQuot root_mcs root_mcs_proof) :=
     LinearLocallyFiniteOrder.instIsSuccArchimedean
   ```

### 5.2 Required Infrastructure

**New lemmas needed**:

1. `staged_build_finitely_between`: Show that between any two comparable MCSs, only finitely many points are added by the staged construction.

2. `discrete_no_density_intermediates`: Show that without DN, `density_of_canonicalR` is not called, so no dense intermediates are added.

3. `discrete_timeline_locally_finite`: Register `LocallyFiniteOrder` instance.

**Location**: These should go in `DiscreteTimeline.lean` or a new helper file `DiscreteTimelineFiniteness.lean`.

### 5.3 Estimated Effort

- **Phase 4 (revised)**: 2-3 hours
  - Proving staged construction gives finite intervals: 1-2 hours
  - Deriving discreteness theorems: 1 hour

- **Phase 5**: 30 minutes
  - LocallyFiniteOrder instance: 20 minutes
  - IsSuccArchimedean from Mathlib: 10 minutes

### 5.4 Risk Assessment

**Low risk**: The staged construction properties are well-documented and the finiteness argument is straightforward.

**Medium risk**: Ensuring the "no density intermediates" condition is formally captured may require careful analysis of which theorems depend on DN.

**Mitigation**: If the full proof is complex, consider adding an axiom like `staged_build_discrete_finite` that asserts finiteness directly. This would be analogous to how `canonicalR_irreflexive` was handled -- first axiomatized, then proven.

---

## Part VI: Relationship to Task 977 Refactoring

### 6.1 Insight from Task 977

Task 977 aims to organize TM base logic with extensions. The research (research-001.md) identifies:
- Base axioms valid on ALL linear ordered additive groups (17 axioms)
- Extension axioms requiring frame conditions (DN, DF, seriality)

The key insight: **DF and DN are extension axioms with incompatible frame conditions.**

### 6.2 How This Informs Task 974

The discrete timeline should:
1. Include DF in the axiom set (marking it as discrete extension)
2. EXCLUDE DN (density is incompatible)
3. The exclusion of DN is what prevents dense intermediates

This is already the case in the current codebase (`isDiscreteCompatible` excludes `density`).

### 6.3 Post-977 Simplification

After task 977 restructures the proof system:
- `DerivationTree_Discrete` would explicitly use only discrete-compatible axioms
- The discreteness property would follow from the type system
- Task 974's sorries would become more straightforward to resolve

**However**: Task 974 can be completed without waiting for task 977. The current predicate-based approach (`isDiscreteCompatible`) is sufficient.

---

## Summary

**Key Findings**:

1. The DF axiom under reflexive semantics is trivially valid and cannot be used to derive discreteness

2. Discreteness follows from the staged construction, specifically from the ABSENCE of DN (which would create dense intermediates)

3. The correct proof path is:
   - Show discrete staged construction has finite intervals
   - Derive `succFn a > a` from finite sets having minima
   - Use Mathlib's `LocallyFiniteOrder` -> `IsSuccArchimedean` chain

4. Estimated effort: 2.5-3 hours for phases 4-5

**Recommendation**: Proceed with the staged construction finiteness approach. This bypasses the DF frame condition extraction (which is vacuous under reflexive semantics) and uses the concrete properties of the construction.

---

## Artifacts

- **This report**: `specs/974_prove_discrete_timeline_succorder_predorder/reports/research-002.md`
- **Key referenced files**:
  - `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - Current state with 3 sorries
  - `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - Staged construction properties
  - `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - Density proof pattern
  - `Theories/Bimodal/Metalogic/Soundness.lean` - DF validity (trivial under reflexive semantics)
  - `specs/977_organize_tm_base_logic_with_extensions/reports/research-001.md` - Axiom classification
  - `specs/archive/956_construct_d_as_translation_group_from_syntax/reports/research-016.md` - Irreflexive semantics analysis
