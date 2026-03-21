# Research Report: Task #956 - Well-Founded Recursion Termination Measure

**Task**: 956 - construct_d_as_translation_group_from_syntax
**Started**: 2026-03-12T14:00:00Z
**Completed**: 2026-03-12T15:30:00Z
**Effort**: Mathlib search + codebase audit + termination measure synthesis
**Dependencies**: research-043 (mathematical ideal path), research-044 (streamlined approach)
**Sources/Inputs**: DensityFrameCondition.lean, Subformulas.lean, SubformulaClosure.lean, Mathlib (Nat.strongRecOn, Finset.strongInductionOn)
**Artifacts**: This report
**Standards**: report-format.md, proof-debt-policy.md

## Executive Summary

- **13 sorries remain** in strict density cases where M is reflexive and W ~ M (W equivalent to M)
- **Termination measure identified**: `Finset.card` of candidate distinguishing formulas
- **Mathlib tools**: `Nat.strongRecOn` (primary), `Finset.strongInductionOn` (alternative)
- **Key infrastructure exists**: `subformulaClosure`, `subformulaCount` already in codebase
- **Recommended implementation**: Pattern C with Nat fuel + sufficiency proof using subformula card bound

## Context & Scope

### Current Sorry Distribution

From grep analysis of DensityFrameCondition.lean:

| Line | Case | Description |
|------|------|-------------|
| 486, 490, 492 | Case B1 (M' reflexive) | W ~ M' when V sees M |
| 585, 589, 591 | Case B1 (M' reflexive) | W ~ M' when M' sees V |
| 641, 646, 653 | Case B1 (M' reflexive) | V = M' sub-cases |
| 865 | Case A, V ~ M | M reflexive, further iteration needed |
| 923 | Case A, W_1 ~ M | M reflexive, further iteration needed |
| 1668 | non_reflexive_target | M reflexive iteration fallback |
| 1753 | non_reflexive_target | M reflexive iteration fallback |

All sorries share the same root cause: **M is reflexive and the constructed witness W satisfies CanonicalR(W, M)**, meaning W is equivalent to M in the quotient. Iteration is required to "escape" M's equivalence class.

### The Mathematical Problem

Given M < M' strictly (CanonicalR M M' AND NOT CanonicalR M' M), find W strictly between:
- CanonicalR M W (W is forward from M)
- CanonicalR W M' (W sees M')
- NOT CanonicalR W M (W doesn't see back to M) **<-- THE PROBLEM**
- NOT CanonicalR M' W (M' doesn't see W)

When M is reflexive, the density construction produces witnesses W that may also be equivalent to M (W ~ M). We need to iterate until we escape M's equivalence class.

## Findings

### Finding 1: Mathlib Termination Tools

**Primary Tool: `Nat.strongRecOn`**

```lean
-- From Init.WF
Nat.strongRecOn :
  {motive : Nat -> Sort u} ->
  (n : Nat) ->
  (ind : (n : Nat) -> ((m : Nat) -> m < n -> motive m) -> motive n) ->
  motive n
```

This is the cleanest approach: encode iteration depth as a Nat, use strong induction to prove termination.

**Equation lemma (for unfolding)**:
```lean
-- From Batteries.Data.Nat.Lemmas
Nat.strongRecOn_eq :
  Nat.strongRecOn t ind = ind t (fun m _ => Nat.strongRecOn m ind)
```

**Alternative: `Finset.strongInductionOn`**

```lean
-- From Mathlib.Data.Finset.Card
Finset.strongInductionOn :
  {p : Finset alpha -> Sort u} ->
  (s : Finset alpha) ->
  ((s : Finset alpha) -> ((t : Finset alpha) -> t (subset) s -> p t) -> p s) ->
  p s
```

This operates directly on the Finset of candidate formulas. **Issue**: Requires decidable equality and filter operations on Set Formula, which need classical reasoning.

**Measure-based approach**:

```lean
-- From Init.WF
measure : {alpha : Sort u} -> (f : alpha -> Nat) -> WellFoundedRelation alpha
```

This creates a well-founded relation from any function to Nat.

### Finding 2: Existing Infrastructure in Codebase

**From `Theories/Bimodal/Syntax/Subformulas.lean`**:

```lean
-- Already exists!
def subformulaCount (phi : Formula) : Nat := (subformulas phi).eraseDups.length
```

**From `Theories/Bimodal/Syntax/SubformulaClosure.lean`**:

```lean
-- Already exists!
def subformulaClosure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset

def subformulaClosureCard (phi : Formula) : Nat := (subformulaClosure phi).card
```

The termination measure infrastructure is **already present**.

### Finding 3: Decreasing Measure Analysis

The iteration decreases when we find a new distinguishing formula. Key insight:

1. At each iteration, we use a distinguishing formula delta with G(delta) in M' and delta NOT in M
2. If the witness W is equivalent to M (W ~ M), then delta is "absorbed" into the equivalence class
3. The next iteration must use a DIFFERENT distinguishing formula delta'
4. The set of candidate formulas is bounded by the subformula closure of the anchor

**The Measure**:

```lean
def iterationMeasure (M M' : Set Formula) (anchor : Formula) : Nat :=
  (subformulaClosure anchor).card
```

Each iteration either:
1. **Succeeds**: returns strict witness (done)
2. **Fails and progresses**: uses a formula from `candidateDistinguishing M M'` which is bounded by `subformulaClosure anchor`

Since each failure "consumes" a candidate formula, and the set is finite, iteration terminates.

### Finding 4: Implementation Strategy

**Pattern C: Fuel + Sufficiency Proof**

```lean
-- Layer 1: Fuel-based iteration (computational, returns Option)
noncomputable def strictDensityWithFuel (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : NOT CanonicalR M' M)
    (fuel : Nat) : Option (StrictDensityWitness M M') :=
  match fuel with
  | 0 => none
  | n + 1 =>
    let W := (density_frame_condition M M' h_mcs h_mcs' h_R h_not_R').choose
    match checkStrictness M M' W ... with
    | some result => some result
    | none =>
      -- Escape via seriality: get strict future M'' from M
      -- Recursively find strict intermediate between M and M'
      -- via path M < M'' < M' (if M'' < M') or M < W' < M' (from escape)
      strictDensityWithFuel M M' ... n

-- Layer 2: Sufficiency proof (proves fuel always exists)
theorem fuel_suffices (M M' : Set Formula) (anchor : Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : NOT CanonicalR M' M)
    (h_anchor : ... anchor covers all distinguishing formulas ...) :
    exists fuel, (strictDensityWithFuel M M' ... fuel).isSome := by
  -- Use Nat.strongRecOn on (subformulaClosure anchor).card
  apply Nat.strongRecOn (subformulaClosure anchor).card
  intro n ih
  -- Case split:
  -- If checkStrictness succeeds: done with fuel = 1
  -- If fails: recursion with smaller measure (new target has smaller formula set)
  ...

-- Layer 3: Final theorem (combines the above)
theorem density_frame_condition_strict (M M' : Set Formula) ... :
    exists W, SetMaximalConsistent W AND CanonicalR M W AND ... := by
  obtain (fuel, h_some) := fuel_suffices M M' anchor ...
  exact (strictDensityWithFuel M M' ... fuel).get h_some
```

### Finding 5: Key Lemma Requirements

**Lemma 1: Strictness Check is Total**

```lean
-- Either the witness is strict, or we can identify why it fails
theorem strictness_trichotomy (W : Set Formula) (h_W : SetMaximalConsistent W)
    (h_MW : CanonicalR M W) (h_WM' : CanonicalR W M') :
    (NOT CanonicalR W M AND NOT CanonicalR M' W) OR  -- strict
    CanonicalR W M OR                                 -- W ~ M
    CanonicalR M' W                                   -- W ~ M'
```

**Lemma 2: Escape Mechanism Decreases Measure**

```lean
-- When W ~ M, seriality gives M'' with M < M'' strictly
-- The new target (M, M'') has smaller formula set
theorem escape_decreases_measure (M W M' M'' : Set Formula)
    (h_equiv_MW : CanonicalR M W AND CanonicalR W M)  -- W ~ M
    (h_escape : CanonicalR M M'' AND NOT CanonicalR M'' M) :
    (candidateDistinguishing M M'' anchor).card <
    (candidateDistinguishing M M' anchor).card
```

This is where the subformula measure applies: the escape uses a formula that's no longer in the candidate set for the new target.

**Lemma 3: Anchor Formula Contains All Candidates**

```lean
-- The distinguishing formulas between M and M' are subformulas of M'
theorem candidates_in_closure (M M' : Set Formula) (anchor : Formula)
    (h_anchor_covers : forall phi, G(phi) IN M' -> phi IN subformulaClosure anchor) :
    forall phi, phi IN candidateDistinguishing M M' -> phi IN subformulaClosure anchor
```

### Finding 6: The Anchor Formula

The anchor formula should be:
- Any formula phi such that subformulaClosure(phi) contains GContent(M')
- In practice: the conjunction of all G-formulas in M' (conceptually)
- For implementation: use the target formula from the overall completeness proof

Since we're proving density for an arbitrary pair M < M', we need an anchor that covers the distinguishing formulas. The standard choice is the "target formula" from the completeness proof context.

## Recommendations

### Primary Recommendation: Implement Pattern C with Nat.strongRecOn

**Step 1: Define the iteration function** (30 min)

```lean
noncomputable def strictDensityIter (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : NOT CanonicalR M' M)
    (fuel : Nat) : Option (StrictDensityWitness M M') := ...
```

**Step 2: Prove escape mechanism works** (1 hr)

When the density witness W is equivalent to M:
1. Get seriality witness M'' from M (mcs_has_strict_future)
2. Show M'' is strictly above M (use irreflexive_mcs_has_strict_future when M not reflexive)
3. For M reflexive case: use the existing reflexive_seriality_escape_via_seed infrastructure

**Step 3: Prove fuel_suffices** (2 hrs)

```lean
theorem fuel_suffices (M M' : Set Formula) ... :
    exists fuel, (strictDensityIter M M' ... fuel).isSome := by
  apply Nat.strongRecOn (someFiniteBound)
  ...
```

The bound can be:
- `(subformulaClosure delta).card * 2` where delta is any distinguishing formula
- Or simpler: just `n + 1` where n is any upper bound on iterations

**Step 4: Compose final theorem** (30 min)

Replace the sorry-filled `density_frame_condition_strict` with:

```lean
theorem density_frame_condition_strict ... := by
  obtain (fuel, h) := fuel_suffices M M' ...
  exact (strictDensityIter M M' ... fuel).get h
```

**Estimated total effort**: 4-5 hours

### Alternative: Direct Finset Induction

Use `Finset.strongInductionOn` directly on the candidate set:

```lean
theorem density_frame_condition_strict ... := by
  have delta := distinguishing_formula_exists ...
  apply Finset.strongInductionOn (subformulaClosure delta.1)
  intro S ih
  ...
```

**Pros**: More mathematically direct
**Cons**: More complex decidability requirements

### NOT Recommended

1. **Adding more case analysis**: The existing 13 sorries are all fundamentally the same problem (M reflexive, W ~ M). More cases won't help.

2. **Axiom introduction**: Would change the logical system.

3. **Sorry deferral**: Violates zero-debt policy.

## Concrete Code Sketch

```lean
/-- The termination measure: subformula count of the anchor formula. -/
def iterFuel (anchor : Formula) : Nat := (subformulaClosure anchor).card + 1

/-- Main iteration theorem using Nat.strongRecOn. -/
theorem strict_density_via_iteration (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : NOT CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : ... anchor covers distinguishing formulas ...) :
    exists W, SetMaximalConsistent W AND CanonicalR M W AND CanonicalR W M' AND
              NOT CanonicalR W M AND NOT CanonicalR M' W := by
  -- Strong induction on the fuel
  apply Nat.strongRecOn (iterFuel anchor)
  intro n ih
  -- Get non-strict witness from existing density_frame_condition
  obtain (W, h_W_mcs, h_MW, h_WM') := density_frame_condition M M' h_mcs h_mcs' h_R h_not_R'
  -- Case split on strictness
  by_cases h_WM : CanonicalR W M
  case neg =>
    -- W doesn't see M. Check M' side.
    by_cases h_M'W : CanonicalR M' W
    case neg =>
      -- W is strict! We're done.
      exact (W, h_W_mcs, h_MW, h_WM', h_WM, h_M'W)
    case pos =>
      -- W ~ M'. Use seriality escape from M.
      -- Apply ih with smaller fuel (need to show measure decreases)
      ...
  case pos =>
    -- W ~ M. Escape via seriality from M.
    -- The escape gives M'' strictly above M.
    -- Apply ih to (M, M'') or (M'', M') with smaller fuel.
    ...
```

## Decisions

1. **Pattern C (Nat fuel + sufficiency) is the recommended approach** - cleanest separation of concerns
2. **The measure is `subformulaClosure(anchor).card`** - bounds the number of iterations
3. **Existing infrastructure (`subformulaClosure`, `subformulaCount`) can be reused**
4. **`Nat.strongRecOn` is the primary termination tool**
5. **All 13 sorries will be resolved by a single unified iteration theorem**

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Escape mechanism fails | HIGH | LOW | Use existing seriality infrastructure |
| Measure doesn't decrease | HIGH | MEDIUM | Carefully track which formula is consumed |
| Anchor formula unclear | MEDIUM | MEDIUM | Use context from completeness proof |
| Integration with CantorApplication | LOW | LOW | API unchanged (exists W, ...) |

## Appendix

### Mathlib References

1. **Nat.strongRecOn**: `Init.WF` - strong induction on Nat
2. **Nat.strongRecOn_eq**: `Batteries.Data.Nat.Lemmas` - unfolding equation
3. **Finset.strongInductionOn**: `Mathlib.Data.Finset.Card` - strong induction on Finset
4. **Finset.strongDownwardInduction**: `Mathlib.Data.Finset.Card` - downward variant
5. **measure**: `Init.WF` - create well-founded relation from function to Nat
6. **WellFounded.wellFounded_iff_no_descending_seq**: characterization

### Codebase References

- `Subformulas.lean`: `Formula.subformulas`, `Formula.subformulaCount`
- `SubformulaClosure.lean`: `subformulaClosure`, `subformulaClosureCard`
- `DensityFrameCondition.lean`: `density_frame_condition`, `irreflexive_mcs_has_strict_future`
- `SeparationLemma.lean`: `mcs_has_strict_future`, `distinguishing_formula_exists`

### Search Queries Used

1. `lean_loogle`: "Nat.strongRecOn" - found `Init.WF`, `Batteries.Data.Nat.Lemmas`
2. `lean_leansearch`: "well-founded recursion on natural number terminates" - found `IsWellFounded.recOn`, `Nat.leRec`
3. `lean_leanfinder`: "finite iteration terminates when measure decreases" - found `Finite.wellFounded_of_trans_of_irrefl`, key patterns
4. `lean_loogle`: "Finset.strongInductionOn" - found `Mathlib.Data.Finset.Card`
5. `lean_local_search`: "subformula" - found existing infrastructure in Subformulas.lean
