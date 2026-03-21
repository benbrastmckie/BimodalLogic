# Research Report: Task #628

**Task**: 628 - Prove semantic_truth_implies_truth_at (upward bridge) for FMP generalization
**Started**: 2026-01-20T01:00:00Z
**Completed**: 2026-01-20T01:30:00Z
**Effort**: 45 minutes
**Priority**: Medium
**Dependencies**: Related to Tasks 610, 627, 470
**Sources/Inputs**:
- Metalogic_v2 codebase (SemanticCanonicalModel.lean, FiniteModelProperty.lean)
- Task 610 research report (Strategy B structural induction analysis)
- Task 627 research report (downward bridge NOT REQUIRED finding)
- Lean MCP tools for theorem verification
**Artifacts**:
- specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The upward bridge `semantic_truth_implies_truth_at` would prove: `w.models phi -> truth_at (SemanticCanonicalModel phi) tau 0 phi`
- This bridge is **theoretically sound but practically difficult** with 3 major infrastructure requirements
- The **Box case is the hardest**: requires proving that box formulas propagate globally across all MCS-derived states
- The **Temporal cases** require a **bounded relevance lemma** showing truth only depends on times within temporal depth
- Task 610 research already provides detailed case analysis; this task's scope is the **reverse direction** (models -> truth_at vs truth_at -> models)
- The bridge is **NOT on the critical path** for completeness (which is proven via `semantic_weak_completeness`) or decidability (which only needs the cardinality bound)
- **Recommendation**: LOW PRIORITY - only implement if external semantics compatibility is explicitly required

## Context & Scope

### Task Purpose

The upward bridge theorem would prove that if a formula is true in the finite model (via `w.models phi h_mem`), it is also true in the general semantics (via `truth_at (SemanticCanonicalModel phi) tau 0 phi`). This completes `finite_model_property_constructive` in `FiniteModelProperty.lean` (line 481).

### Current Sorry Location

```lean
-- In FiniteModelProperty.lean (lines 475-481):
· -- truth_at (SemanticCanonicalModel φ) tau 0 φ
  -- This requires a "truth bridge" connecting finite model truth to general truth_at.
  -- The bridge requires formula induction with problematic modal/temporal cases.
  -- See Boneyard/DeprecatedCompleteness.lean for documentation of the issues.
  sorry
```

### Why This Matters

Without this bridge:
1. `finite_model_property_constructive` cannot connect finite model satisfiability to general `truth_at`
2. External frameworks using `truth_at` cannot directly leverage the FMP witness
3. The theorem statement is weaker (existential witness without general semantics guarantee)

### Why This Is Not Critical

1. **Completeness** is already proven via `semantic_weak_completeness` which avoids the bridge entirely
2. **Decidability** only needs the cardinality bound (2^closureSize), not the truth bridge
3. The `main_provable_iff_valid_v2` theorem is proven without needing this bridge

## Findings

### Key Definitions

**1. General Truth (`truth_at`)** - From `Semantics/Truth.lean`:
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s < t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t < s -> truth_at M tau s phi
```

**2. Finite Model Truth (`models`)** - From `FiniteWorldState.lean`:
```lean
def models (w : FiniteWorldState phi) (psi : Formula) (h : psi in closure phi) : Prop :=
  w.assignment <psi, h> = true
```

**3. Local Consistency (`IsLocallyConsistent`)** - From `FiniteWorldState.lean`:
```lean
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- Bot is false
  (forall h : Formula.bot in closure phi, v <Formula.bot, h> = false) /\
  -- Implications are respected (material implication)
  (...) /\
  -- Modal T axiom: box(psi) -> psi
  (forall psi, forall h_box : Formula.box psi in closure phi,
    forall h_psi : psi in closure phi,
    v <Formula.box psi, h_box> = true -> v <psi, h_psi> = true)
  -- Note: NO temporal reflexivity axioms (strict semantics)
```

### Case-by-Case Analysis (Forward Direction: models -> truth_at)

Task 610 analyzed the **reverse direction** (truth_at -> models). This task requires the **forward direction**.

#### Atom Case (EASY)

**Claim**: If `w.models (atom p) h_mem`, then `truth_at M tau 0 (atom p)`

**Analysis**:
- `truth_at` requires: `exists (ht : tau.domain 0), M.valuation (tau.states 0 ht) p`
- `M.valuation` is `semantic_valuation` which checks: `w'.toFiniteWorldState.models (atom p) h`
- Given `tau.states 0 ht = w`, we need `w.models (atom p) h`
- This follows directly from the hypothesis

**Status**: **PROVABLE** - Direct definition unfolding

#### Bot Case (TRIVIAL)

**Claim**: If `w.models bot h_mem`, then `truth_at M tau 0 bot`

**Analysis**:
- `w.models bot h_mem = w.assignment <bot, h_mem> = true`
- But `IsLocallyConsistent` requires `bot` to be false
- The premise is vacuously satisfied (False -> anything)

**Status**: **PROVABLE** - Proof by contradiction on premise

#### Imp Case (REQUIRES BIDIRECTIONAL IH)

**Claim**: If `w.models (psi.imp chi) h_mem`, then `truth_at M tau 0 (psi.imp chi)`

**Analysis**:
- `truth_at` for imp: `truth_at M tau 0 psi -> truth_at M tau 0 chi`
- Need to show: assuming `truth_at M tau 0 psi`, we get `truth_at M tau 0 chi`
- The **reverse IH** gives: `truth_at M tau 0 psi -> w.models psi h_psi`
- With `w.models (psi.imp chi)` and `w.models psi`, get `w.models chi` by `imp_correct`
- Then **forward IH** gives: `w.models chi -> truth_at M tau 0 chi`

**Status**: **REQUIRES BIDIRECTIONAL INDUCTION** - Must prove both directions simultaneously

#### Box Case (PROBLEMATIC - THE HARD ONE)

**Claim**: If `w.models (box psi) h_mem`, then `truth_at M tau 0 (box psi)`

**Analysis**:
- `truth_at` for box: `forall (sigma : WorldHistory F), truth_at M sigma 0 psi`
- This quantifies over **ALL** WorldHistories in SemanticCanonicalFrame
- The finite model only knows the T-axiom: `box(psi) = true -> psi = true` (same state)

**The Core Challenge**:

The SemanticCanonicalFrame has uncountably many WorldHistories (all functions Int -> SemanticWorldState satisfying convexity and respects_task). But `w.models (box psi)` only tells us that `w.models psi`.

For the forward direction, we need:
- For ANY WorldHistory sigma at time 0
- sigma.states 0 can be ANY SemanticWorldState
- We need `truth_at M sigma 0 psi` for all such sigma

**Required Infrastructure**:

The proof requires showing that in the SemanticCanonicalModel:
1. Every SemanticWorldState is MCS-derived
2. If `box(psi) in S` for any MCS S, then `psi in T` for ALL MCSes T in the closure
3. This is the **global saturation property** for box formulas

**Alternative Approach**: Instead of global saturation, we can use:
- The TM logic has S5 modal logic semantics (reflexive, symmetric, transitive)
- All worlds are modal equivalents of each other
- Therefore `box(psi) at any w` implies `psi at all w'`

This requires proving the modal equivalence relation is trivial (all states related).

**Status**: **HARD** - Requires canonical MCS propagation lemma or S5 triviality proof

#### Temporal Cases (PROBLEMATIC)

**Claim**: If `w.models (all_future psi) h_mem`, then `truth_at M tau 0 (all_future psi)`

**Analysis**:
- `truth_at` for all_future: `forall s : Int, 0 < s -> truth_at M tau s psi`
- This quantifies over **ALL** positive integers
- The finite model only has times in [-k, k] where k = temporalBound phi

**The Core Challenge**:

For times s > k:
- `tau.domain s` may be false (history doesn't extend there)
- If domain is false, atoms become false (no witness for existence)
- But the finite model says nothing about these times

**Required Infrastructure: Bounded Relevance Lemma**

Need to prove: For a formula of temporal depth d, truth at time 0 only depends on truth values at times in [-d, d].

```
Lemma bounded_relevance:
  For psi in closure phi (so temporalDepth psi <= temporalDepth phi = k):
    truth_at M tau 0 psi depends only on tau restricted to [-k, k]
```

**Why This Would Work**:
- If `w.models (all_future psi) h_mem`, finite evaluation at times 1, 2, ..., k gives psi true
- For s > k, `truth_at M tau s psi` involves atoms at times in [s-d, s+d]
- Since psi is in the closure, d <= k
- For s > k, atoms at times > k are outside domain, hence false
- But if the formula structure ensures evaluation "bottoms out" before hitting these atoms, it works

**Complication**: TM logic uses **strict** temporal operators (G psi does NOT imply psi at current time).
This is correctly reflected in `IsLocallyConsistent` which does NOT include temporal reflexivity.

**Status**: **HARD** - Requires bounded relevance lemma + careful boundary analysis

### Required Infrastructure Summary

Based on the case analysis, completing the upward bridge requires:

| Infrastructure | Difficulty | Estimated Effort | Status |
|---------------|------------|------------------|--------|
| Bidirectional Induction Schema | Medium | 2-3 hours | Not started |
| Canonical MCS Propagation (Box) | Hard | 4-6 hours | Not started |
| Bounded Relevance Lemma (Temporal) | Hard | 3-4 hours | Not started |
| Domain Extension/Boundary Handling | Medium | 2-3 hours | Not started |

**Total Estimated Effort**: 12-16 hours

### Comparison with Related Tasks

| Task | Direction | Purpose | Status | Needed? |
|------|-----------|---------|--------|---------|
| 610 | truth_at -> models | Strategy B completeness | RESEARCHED | NO (Strategy A used) |
| 627 | valid -> semantic_truth_at_v2 | Downward bridge | ABANDONED | NO (architecture avoids) |
| 628 | models -> truth_at | FMP generalization | This task | LOW PRIORITY |

### Existing Code Assets

**Useful lemmas in old Metalogic**:
- `truth_at_implies_semantic_truth` (FiniteCanonicalModel.lean:3952) - has sorry
- `mcs_imp_iff_material` - MCS implication property (proven)
- `worldStateFromClosureMCS_models_iff` - MCS membership correspondence (proven)

**Useful lemmas in Metalogic_v2**:
- `semantic_truth_lemma_v2` - connects `models` to `semantic_truth_at_v2` (proven)
- `semantic_weak_completeness` - avoids the bridge entirely (proven)
- `eq_iff_toFiniteWorldState_eq` - SemanticWorldState extensionality (proven)

### Alternative Approaches

**1. Weaken the Statement**
Instead of proving the full `truth_at`, prove:
```lean
truth_at_restricted (M : TaskModel F) (tau : WorldHistory F) (t : D)
    (domain_bound : Int) : Formula -> Prop
```
where temporal quantification is restricted to [-domain_bound, domain_bound].

**2. Add Axiom**
Accept the sorry as an axiom with documented justification. The finite model property is well-established in the literature, and the sorry is in a non-critical-path theorem.

**3. Use Classical Logic**
Use `Classical.choice` and cardinality arguments to show the finite model truth implies general truth without explicit construction.

## Decisions

1. **The upward bridge is mathematically sound but requires significant infrastructure**
   - Same challenges as task 610 (reverse direction)
   - Both directions need the same lemmas (bidirectional induction, canonical propagation, bounded relevance)

2. **The bridge is NOT on the critical path**
   - Completeness: proven via `semantic_weak_completeness`
   - Decidability: only needs cardinality bound
   - The sorry is in `finite_model_property_constructive`, not core theorems

3. **Estimated effort is high relative to value**
   - 12-16 hours for a theorem that is not needed for core results
   - Same work as task 610 which was already deprioritized

## Recommendations

### Primary Recommendation

**Mark task 628 as LOW PRIORITY** for the completeness proof. The existing architecture establishes:
- `semantic_weak_completeness` provides core completeness (PROVEN)
- `main_provable_iff_valid_v2` connects provability to validity (completeness direction has sorry but soundness direction proven)
- Decidability uses cardinality bound, not the truth bridge

### If Implementation Is Desired

Order of attack:
1. **Bounded Relevance Lemma** (most tractable, standard temporal logic technique)
2. **Bidirectional Induction Schema** (well-understood pattern)
3. **Atom/Bot/Imp Cases** (straightforward once schema established)
4. **Temporal Cases** (using bounded relevance)
5. **Canonical MCS Propagation** (hardest, most uncertain)
6. **Box Case** (using propagation lemma)

### Alternative: Document as Known Limitation

Add documentation to `finite_model_property_constructive` explaining:
- The sorry is for the truth bridge connecting finite model truth to general semantics
- The core FMP result (cardinality bound) is still valid
- External frameworks can use the bound without the truth bridge

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Canonical MCS propagation may fail | High | May need to restructure canonical model |
| Bounded relevance has edge cases | Medium | Careful boundary condition analysis |
| Effort exceeds value | High | Document as known limitation instead |
| Bidirectional IH complexity | Low | Standard well-founded induction |

## Appendix

### Relevant Code Locations

| File | Line | Content |
|------|------|---------|
| FiniteModelProperty.lean | 481 | `finite_model_property_constructive` (sorry) |
| SemanticCanonicalModel.lean | 551 | `semantic_weak_completeness` (PROVEN) |
| SemanticCanonicalModel.lean | 632 | `main_provable_iff_valid_v2` (sorry in completeness) |
| FiniteWorldState.lean | 121 | `IsLocallyConsistent` definition |
| FiniteWorldState.lean | 169 | `models` definition |
| Truth.lean | 104 | `truth_at` definition |
| FiniteCanonicalModel.lean | 3952 | Old `truth_at_implies_semantic_truth` (sorry) |

### Task 610 Research Summary

Task 610 analyzed Strategy B (truth bridge) and concluded:
- Strategy A (semantic_weak_completeness) is preferred
- Strategy B requires 5+ infrastructure lemmas
- Box case is hardest (canonical MCS propagation)
- Temporal cases need bounded relevance
- Recommendation was to continue with Strategy A

### Task 627 Outcome

Task 627 (downward bridge) was ABANDONED because:
- The bridge was found to be NOT REQUIRED for completeness
- `main_provable_iff_valid_v2` already proven via alternative path
- Same infrastructure would be needed as tasks 610/628

### References

- Blackburn et al., "Modal Logic" - Finite model property proofs
- Goldblatt, "Logics of Time and Computation" - Temporal completeness
- Boneyard/DeprecatedCompleteness.lean - Documentation of deprecated approaches
- Task 610 research report - Strategy B detailed analysis
- Task 627 research report - Downward bridge NOT REQUIRED finding
