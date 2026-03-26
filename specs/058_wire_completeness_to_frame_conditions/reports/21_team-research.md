# Team Research Report: Task #58 - CanonicalTask 3-Place Approach

**Task**: Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Mode**: Team Research (4 teammates)
**Session**: sess_1774543335_29cb9f
**Focus**: CanonicalTask as primary 3-place relation, avoiding FMP dependency

## Summary

**The user's insight is mathematically correct and names a real, already-implemented structure.** The 3-place `CanonicalTask(u, x, v)` relation in `CanonicalTaskRelation.lean` is sorry-free and provides a cleaner algebraic framework for understanding coherence. However, the fundamental mathematical obstruction remains: for arbitrary MCS, F-nesting can be unbounded, preventing x-value computation.

**Key breakthrough from Teammate D**: The "sub-case (b)" obstruction as previously stated (`F(phi) ∈ u` and `G(neg phi) ∈ u`) is **impossible in any consistent set** — these are derivably contradictory. The real obstruction is that F-nesting sequences may never terminate, not a logical inconsistency.

## Key Findings

### From Teammate A (CanonicalTask 3-Place Approach)
- CanonicalTask is **fully proven, sorry-free** with all three TaskFrame axioms
- The 3-place structure makes "same family" explicit: `CanonicalTask(u, x, v)` means v is reachable from u in exactly x Succ steps
- **The `bounded_witness` theorem is the key**: if `F^n(phi) ∈ u` and `F^{n+1}(phi) ∉ u`, then `phi ∈ v` where `CanonicalTask(u, n, v)`
- For deferral-restricted MCS, x-values are computable (bounded by `closure_F_bound`)
- **Confidence: HIGH (85%)**

### From Teammate B (Task Relation Constraints)
- The natural constraint for coherence is **Unique Successor Constraint** (functional Task)
- `temp_linearity` axiom forces trichotomy of F-witnesses (comparable distances)
- The `bounded_witness` theorem + bounded F-nesting = family-level coherence
- **The constraint-based view**: `ClosureBoundedTask(u, x, v)` makes coherence definitional
- **Confidence: HIGH**

### From Teammate C (Dovetailed Algebraic - No FMP)
- The existing `BFMCS_Bundle` construction is **fully sorry-free** at bundle level
- Bundle-level F/P witnesses exist without any FMP machinery
- The gap is NOT family-level coherence itself, but connecting `BFMCS_Bundle` to the truth lemma
- A **bundle truth lemma** would complete the sorry-free path
- Sub-case (b) cannot be overcome for arbitrary MCS by the CanonicalTask relation alone
- **Confidence: LOW (20%)** for pure algebraic arbitrary-MCS completeness

### From Teammate D (Partial Order via Task) - **CRITICAL CORRECTION**
- **Sub-case (b) as stated is VACUOUSLY HARMLESS**: `F(phi)` and `G(neg phi)` CANNOT coexist in any consistent set (they are derivably contradictory: `G(neg phi) -> neg F(phi)`)
- The REAL obstruction is **unbounded F-nesting**: for arbitrary MCS, `F^n(phi) ∈ u` for ALL n is possible
- The user's x-value computation `x = max n such that F^n(phi) ∈ u` works when the max exists (bounded nesting)
- For deferral-restricted MCS, the max always exists (`f_nesting_is_bounded_restricted`)
- **Compactness observation**: The global obligation system view suggests a potential ultrafilter-based path for arbitrary MCS
- **Confidence: HIGH (85%)** for restricted case, **MEDIUM (50%)** for compactness path

## Synthesis

### Conflicts Resolved

**Conflict 1**: Is sub-case (b) a genuine mathematical obstruction?
- *Resolution*: **NO** — sub-case (b) as stated (`F(phi)` and `G(neg phi)` in same MCS) is inconsistent and thus vacuous
- *Corrected obstruction*: Unbounded F-nesting (the sequence `F^n(phi) ∈ u` never terminates)

**Conflict 2**: Does the 3-place CanonicalTask provide new proof content?
- *Resolution*: **Conceptually yes, mathematically equivalent** — it makes the structure explicit but converges to the same construction as the existing SuccChainFMCS

**Conflict 3**: Can we avoid FMP dependency entirely?
- *Resolution*: **Yes for bundle-level, No for family-level with arbitrary MCS**
  - Bundle-level: `BFMCS_Bundle` construction is sorry-free without FMP
  - Family-level arbitrary: requires bounded F-nesting, which IS the FMP property
  - Family-level restricted: uses `f_nesting_is_bounded_restricted` (sorry-free)

### The User's Key Insight Validated

The user's framing — "What F(phi) in u should give us is Task(u, x, v) for some positive x with phi ∈ v; the aim is to resolve all x values" — is precisely correct:

1. **The x-value formula**: `x = max n such that F^n(phi) ∈ u` (computed from F-nesting depth)
2. **The `bounded_witness` theorem**: proves `phi ∈ v` at `CanonicalTask(u, x, v)` when this max exists
3. **`temp_linearity`**: ensures x-values for different obligations are pairwise comparable (no conflicts)
4. **The algebraic content**: bounded F-nesting is both necessary and sufficient for x-value computation

### The Two Viable Paths

**Path A: Bundle Truth Lemma (Avoids Family-Level Coherence)**
```
1. phi not provable -> neg(phi) consistent
2. Extend to MCS M0 (Lindenbaum, sorry-free)
3. construct_bfmcs_bundle M0 (sorry-free)
4. Prove BUNDLE truth lemma: phi ∈ fam.mcs t <-> truth_at ... phi
5. Since neg(phi) ∈ M0, phi not valid -> completeness

Missing: Bundle truth lemma for G/H backward cases
Status: Requires new proof infrastructure
```

**Path B: Deferral-Restricted Task Construction (Family-Level Coherence)**
```
1. phi not provable -> neg(phi) consistent
2. Extend to DeferralRestrictedMCS M0 over deferralClosure(phi)
3. Compute x-values via bounded_witness + f_nesting_is_bounded_restricted
4. Build SuccChainFMCS with CanonicalTask-connected worlds
5. restricted_forward_chain_forward_F gives family-level coherence (sorry-free)
6. Apply parametric_shifted_truth_lemma (sorry-free given coherence)
7. Completeness

Missing: deferralClosure_closed_under_box_class
Status: Most infrastructure sorry-free
```

### Why Path B Is Recommended

Path B is the "clean algebraic solution" the user requested:
- Uses CanonicalTask as the primary structure
- Computes x-values algebraically from F-nesting depth
- No arbitrary choices — the x-value is determined by the MCS content
- `temp_linearity` provides the algebraic justification for linearization
- `bounded_witness` is the bridge theorem connecting nesting to Task-distance

The "FMP dependency" criticism is reframed: using `deferralClosure(phi)` is not invoking FMP machinery — it is using the algebraic fact that formulas have finite subformula closures, which bounds F-nesting.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | CanonicalTask 3-place | completed | Made Task structure explicit; identified bounded_witness as key theorem |
| B | Task constraints | completed | Identified Unique Successor Constraint; temp_linearity analysis |
| C | Dovetailed algebraic | completed | Confirmed bundle path is sorry-free; clarified sub-case (b) persists |
| D | Partial order via Task | completed | **Corrected sub-case (b)**: it's vacuous; real obstruction is unbounded nesting |

## Recommended Implementation

### Immediate (Sorry-Free Target)

1. **Prove `deferralClosure_closed_under_box_class`**: If M0 is restricted to `deferralClosure(phi)`, and W has `box_class_agree M0 W`, show W is also restricted to `deferralClosure(phi)`.

2. **Create `construct_task_based_bfmcs`**: Wire the deferral-restricted SuccChainFMCS to BFMCS using CanonicalTask as the explicit relation.

3. **Wire to completeness**: Use `parametric_shifted_truth_lemma` with the restricted family-level coherence.

### Key Theorem Already Proven (Sorry-Free)

```lean
theorem bounded_witness
    (u v : Set Formula) (phi : Formula) (n : Nat)
    (h_Fn : iter_F n phi ∈ u)
    (h_Fn1_not : iter_F (n + 1) phi ∉ u)
    (h_task : CanonicalTask_forward_MCS u n v) :
    phi ∈ v
```

This IS the algebraic x-value resolution the user requested. The remaining work is ensuring `n` exists (via bounded nesting) and wiring to BFMCS.

## Conclusion

The CanonicalTask 3-place approach clarifies the completeness problem but does not provide new proof content beyond the existing infrastructure. The key insight — x-value computation via bounded F-nesting — is already captured by `bounded_witness`. The recommended path uses deferral-restriction to ensure x-values are computable, which is algebraically clean and avoids the (vacuous) sub-case (b) concern entirely.

The "sub-case (b) obstruction" should be retired from future analysis — it describes an inconsistent situation. The real mathematical content is: **F-nesting must be bounded for x-values to be computable**, which is guaranteed by deferral-restriction.
