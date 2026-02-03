# Research Report: Task #816

**Task**: BMCS Temporal Modal Coherence Strengthening - Can FMP Establish Completeness for Validity.lean?
**Date**: 2026-02-03
**Focus**: Analyzing whether finite models constructed by FMP qualify as TaskModels for completeness
**Session ID**: sess_1770078322_59c165

## Executive Summary

**The user's question**: Can the FMP establish completeness for Validity.lean by constructing a finite model that satisfies a consistent sentence, even though not every model defined in the semantics is finite?

**Short answer**: YES, but only with a specific construction that differs from the current FMP implementation.

**Key insight**: The classical completeness argument (consistent implies satisfiable) CAN work, but requires:
1. Embedding `SemanticWorldState` into a TaskModel (not just `FiniteWorldState`)
2. Constructing a TaskFrame with a SINGLE history (trivializing Box quantification)
3. Carefully handling temporal operators via constant history

**Critical finding**: The current FMP construction in `ConsistentSatisfiable.lean` fails NOT because finite models aren't TaskModels, but because the `fmpTaskFrame` construction is too permissive - it exposes ALL `FiniteWorldState`s to Box quantification, not just MCS-derived ones.

---

## 1. Analysis of the User's Question

### 1.1 The Classical Completeness Strategy

The user correctly identifies the standard completeness approach:

```
Completeness = (valid => provable)
             = contrapositive of (not provable => not valid)
             = contrapositive of (consistent => satisfiable)
```

If we can show: **every consistent formula has a model** (even a finite one), then by contrapositive, every valid formula is provable.

### 1.2 The Key Question

> "If the FMP constructs a finite model (SemanticWorldState) that satisfies a consistent formula, and finite models are a SUBSET of all models (TaskModels), can we use this to establish completeness for Validity.lean?"

This is asking: Is there an embedding from FMP finite models into the general semantic framework?

---

## 2. The Validity Definition Revisited

From `Validity.lean:61-64`:
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

And the corresponding satisfiability:
```lean
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) ...
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

**The connection to completeness**:
- If `phi` is consistent, show `formula_satisfiable phi`
- This means: NOT `formula_satisfiable phi.neg`
- Therefore: NOT `valid phi.neg`
- By soundness + contrapositive: `provable phi` (weak completeness)

---

## 3. Why the Current FMP Bridge Fails

### 3.1 The Current fmpTaskFrame Construction

From `ConsistentSatisfiable.lean:153-158`:
```lean
noncomputable def fmpTaskFrame (phi : Formula) ... : TaskFrame D where
  WorldState := FiniteWorldState phi
  task_rel := fun _ _ _ => True  -- PROBLEM: Too permissive!
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

**The problem**: Box in `truth_at` quantifies over ALL `WorldHistory F`:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
```

Since `task_rel` is permissive (`True`), there exist world histories that pass through NON-MCS-derived `FiniteWorldState`s. These arbitrary states don't respect modal axioms, so Box fails.

### 3.2 The Actual Blockage

The blockage is NOT that finite models aren't TaskModels. It's that:

1. `fmpTaskFrame.WorldState = FiniteWorldState phi` (all of them!)
2. `WorldHistory F` can contain ANY `FiniteWorldState`
3. `truth_at ... box psi` requires `psi` true at ALL such histories
4. Non-MCS `FiniteWorldState`s don't satisfy `psi`

---

## 4. The Solution: Single-History TaskFrame Construction

### 4.1 Key Insight

The user asks: "Could we construct a degenerate TaskModel where there's only ONE history, making universal quantification trivial?"

**YES!** This is exactly the right approach.

### 4.2 Proposed Construction: SingleHistoryFrame

```lean
-- Construct a TaskFrame where there is essentially only one history
def singleHistoryFrame (phi : Formula) (w : FiniteWorldState phi) : TaskFrame Int where
  WorldState := Unit  -- Only one world state!
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

def singleHistoryModel (phi : Formula) (w : FiniteWorldState phi) :
    TaskModel (singleHistoryFrame phi w) where
  valuation := fun () p =>
    if h : Formula.atom p ∈ closure phi then
      w.models (Formula.atom p) h
    else False

def singleHistory (phi : Formula) (w : FiniteWorldState phi) :
    WorldHistory (singleHistoryFrame phi w) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => ()
  respects_task := fun _ _ _ _ _ => trivial
```

### 4.3 Why This Works

With `WorldState = Unit`:
- There is only ONE possible `WorldHistory`: the constant history mapping every time to `()`
- `truth_at M tau t (box psi)` requires `forall sigma, truth_at M sigma t psi`
- Since ALL histories are equivalent to the constant one, this reduces to checking `psi` at the SINGLE world state
- The valuation on Unit delegates to `w.models`, which is MCS-derived

### 4.4 Truth Correspondence Theorem (Sketch)

```lean
theorem single_history_truth_correspondence (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_mem : psi ∈ closure phi) :
    let w := worldStateFromClosureMCS phi S h_mcs
    let M := singleHistoryModel phi w
    let tau := singleHistory phi w
    psi ∈ S ↔ truth_at M tau 0 psi
```

**Proof sketch by induction on formula structure**:

1. **Atom p**: By definition of `singleHistoryModel.valuation`
2. **Bot**: Both sides false
3. **Imp psi chi**: Standard MCS properties + IH
4. **Box psi**:
   - Forward: `box psi ∈ S` implies `psi ∈ S` (by T axiom in MCS), then IH
   - Backward: All histories have the same truth, so `psi` true everywhere means `psi ∈ S` (by IH), then `box psi ∈ S` (by MCS properties)
5. **All_future/All_past**:
   - The constant history trivializes this: same state at all times
   - Need to show `all_future psi ∈ S` iff `psi` true at all future times
   - Since state is constant, this reduces to `psi` true at current state
   - MCS temporal properties: `all_future psi ∈ S` iff `psi ∈ S` (from reflexivity axioms G psi -> psi)

---

## 5. The Temporal Operator Issue

### 5.1 Potential Problem

The temporal operators in `Truth.lean:113-114` are:
```lean
| Formula.all_past phi => forall (s : D), s ≤ t -> truth_at M tau s phi
| Formula.all_future phi => forall (s : D), t ≤ s -> truth_at M tau s phi
```

With a constant history (same state at all times), this reduces to:
- `all_future psi` true iff `psi` true (for all times >= t, which is all times by totality)
- `all_past psi` true iff `psi` true (for all times <= t)

### 5.2 MCS Requirement

For the bridge to work, we need the MCS to satisfy:
- `all_future psi ∈ S` iff `psi ∈ S`
- `all_past psi ∈ S` iff `psi ∈ S`

This requires the T-axioms for temporal operators to be derivable:
- `G psi -> psi` (future implies now)
- `H psi -> psi` (past implies now)

**Check**: From `FiniteWorldState.lean:86-87`, the comment says:
> "NOTE: Temporal reflexivity (H phi -> phi, G phi -> phi) is intentionally NOT included"

This is problematic! The current semantics in `Truth.lean` uses REFLEXIVE operators (≤, not <):
```lean
| Formula.all_past phi => forall (s : D), s ≤ t -> ...  -- includes s = t!
| Formula.all_future phi => forall (s : D), t ≤ s -> ... -- includes s = t!
```

So the T-axioms ARE semantically valid, but `IsLocallyConsistent` doesn't enforce them.

### 5.3 Resolution

**Option A**: Verify that MCS projection automatically includes temporal T-axioms

The MCS is a projection from a maximal consistent set that contains all derivable theorems. Since `G psi -> psi` is derivable (sound for reflexive semantics), it will be in any MCS.

**Option B**: Add temporal T-axioms to `IsLocallyConsistent`

Modify `FiniteWorldState.lean` to add:
```lean
-- Temporal T axiom: all_future psi -> psi
(forall psi : Formula,
  forall h_future : Formula.all_future psi ∈ closure phi,
  forall h_psi : psi ∈ closure phi,
  v ⟨Formula.all_future psi, h_future⟩ = true ->
  v ⟨psi, h_psi⟩ = true)
```

---

## 6. Proof Roadmap

### 6.1 What Needs to Be Proven

To establish completeness for `Validity.lean` via FMP:

1. **`singleHistoryFrame_is_TaskFrame`**: The construction is a valid TaskFrame
2. **`singleHistory_is_WorldHistory`**: The constant history respects all constraints
3. **`single_history_truth_lemma`**: Truth in single-history model equals MCS membership
4. **`consistent_implies_satisfiable_general`**: If `phi` is consistent, then `formula_satisfiable phi`
5. **`completeness_via_satisfiability`**: `valid phi -> provable phi`

### 6.2 Critical Lemma

The key new theorem would be:

```lean
theorem consistent_implies_formula_satisfiable (phi : Formula)
    (h_cons : ¬Nonempty (⊢ phi.neg)) : formula_satisfiable phi := by
  -- 1. Build MCS containing phi
  have h_set_cons : SetConsistent {phi} := ...
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum {phi} h_set_cons

  -- 2. phi ∈ M
  have h_phi_in : phi ∈ M := h_sub (Set.mem_singleton phi)

  -- 3. Project to closure MCS
  let S := M ∩ (closureWithNeg phi)
  have h_S_mcs : ClosureMaximalConsistent phi S := ...

  -- 4. Build FiniteWorldState
  let w := worldStateFromClosureMCS phi S h_S_mcs

  -- 5. Build single-history TaskModel
  use Int, inferInstance, inferInstance, inferInstance
  use singleHistoryFrame phi w
  use singleHistoryModel phi w
  use singleHistory phi w
  use 0

  -- 6. Apply truth lemma
  exact (single_history_truth_lemma phi S h_S_mcs phi (phi_mem_closure phi)).mp ...
```

---

## 7. Comparison to Current Approaches

| Approach | Box Handling | Temporal Handling | Completeness Target |
|----------|-------------|-------------------|---------------------|
| Current FMP (`semantic_weak_completeness`) | MCS membership | BoundedTime | FMP-internal validity |
| Current Bridge (`ConsistentSatisfiable`) | Sorried | Constant history (blocked) | `valid` (blocked) |
| BMCS | Bundle quantification | Omega-rule limited | BMCS-internal validity |
| **Proposed Single-History** | Trivial (one history) | Constant history (works!) | `valid` (achievable) |

### 7.1 Key Difference from Current Bridge

The current `fmpTaskFrame` uses:
```lean
WorldState := FiniteWorldState phi  -- ALL of them
```

The proposed single-history approach uses:
```lean
WorldState := Unit  -- Just one
```

This eliminates the Box quantification problem entirely.

---

## 8. Recommendations

### 8.1 Immediate Path (Low Effort)

Create `SingleHistoryCompleteness.lean` with:
1. Single-history TaskFrame/TaskModel construction
2. Truth lemma for single-history model
3. Bridge theorem: `consistent phi -> formula_satisfiable phi`
4. Completeness theorem: `valid phi -> provable phi`

**Estimated effort**: 2-4 hours

### 8.2 Required Verification

Before implementation, verify:
1. Temporal T-axioms (`G psi -> psi`, `H psi -> psi`) are derivable in the proof system
2. MCS contains all theorems (including temporal T-axioms)
3. The reflexive semantics (≤ not <) is intentional and correct

### 8.3 Alternative Approaches

If the single-history approach has issues, consider:

**Alternative A**: Identity frame approach
```lean
WorldState := Unit
task_rel := fun () d () => d = 0  -- Identity only
```
This restricts histories to single-time-point domains, potentially simplifying temporal reasoning.

**Alternative B**: Singleton domain approach
Create a TaskFrame where the domain is a single point {0}, eliminating temporal quantification.

---

## 9. Answers to Specific Questions

### Q1: Can the FMP model qualify as a TaskModel?

**YES**, via the single-history construction. The key is to construct a TaskFrame where the set of possible world histories is trivial (effectively one history).

### Q2: What barriers exist to the embedding?

The barrier in the CURRENT code (`ConsistentSatisfiable.lean`) is the permissive `fmpTaskFrame` that exposes all `FiniteWorldState`s. The proposed single-history construction eliminates this barrier.

### Q3: Can "consistent implies satisfiable" work?

**YES**. The classical argument is sound. The issue is constructing the right TaskModel.

### Q4: What Lean types need to be proven equal?

The key theorem is:
```lean
psi ∈ S ↔ truth_at (singleHistoryModel phi w) (singleHistory phi w) 0 psi
```
where `S` is the closure-MCS and `w` is the derived world state.

---

## 10. Conclusion

The user's insight is correct: the FMP CAN establish completeness for the general validity definition in Validity.lean. The solution is to construct a "degenerate" TaskModel with:
- A single abstract world state (Unit)
- Valuation that delegates to the MCS-derived FiniteWorldState
- A constant history trivializing Box quantification

This approach bypasses the architectural limitations of the current `ConsistentSatisfiable.lean` bridge by ensuring that Box never quantifies over non-MCS states.

**The sorry-free completeness proof for `valid` in Validity.lean is achievable** with the single-history construction outlined in this report.

---

## References

### Codebase Files Analyzed
- `Theories/Bimodal/Semantics/Validity.lean` - Target validity definition
- `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation (Box and temporal semantics)
- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame structure
- `Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory structure
- `Theories/Bimodal/Semantics/TaskModel.lean` - TaskModel structure
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Current FMP completeness
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` - Blocked bridge attempt
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - FiniteWorldState construction

### Historical Research
- `specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-011.md` - Previous analysis
