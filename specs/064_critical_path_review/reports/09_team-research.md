# Research Report: Task #64 — BFMCS Saturation and Modal Structure Requirements

**Task**: Critical path review: algebraic analysis of completeness obstacles
**Date**: 2026-03-25
**Mode**: Team Research (3 teammates, wave 2)
**Session**: sess_1774461365_0e8fc2
**Prior Report**: `05_team-research.md` (root cause analysis — corrected by this report)

## Summary

This report corrects two errors in the prior team research (report 05):

1. **`restricted_forward_chain_forward_F` has sorryAx** — confirmed via `#print axioms`. The entire restricted chain infrastructure is sorry-infected. Path A from report 05 is dead.
2. **Singleton BFMCS is wrong** — it collapses modal structure, making Box phi iff phi and Diamond phi iff phi. Multiple families are essential for S5 modal semantics.

The team converges on a new architecture: **omega-enumeration BFMCS** — build temporally coherent chains via iterated noncomputable choice using sorry-free witness theorems, then bundle them via the existing sorry-free `boxClassFamilies` modal infrastructure.

**Critical prerequisite**: Verify `box_class_agree` transitivity (should be trivial for S5).

## Key Findings

### 1. Why Singleton BFMCS Trivializes Modal Structure (Teammate A)

With `B.families = {fam₀}`:
- **modal_backward** reduces to `phi in fam₀.mcs t → Box phi in fam₀.mcs t` — this forces `phi → Box phi` as a theorem, which is NOT valid in S5 for contingent formulas
- **Diamond witness** reduces to `Diamond(psi) → psi` — no separate witnessing world
- **Box case in truth lemma** quantifies over all families; with one family there is no modal variety
- Result: Box phi iff phi iff Diamond phi — S5 collapses to trivial logic

### 2. Modal Saturation and Temporal Coherence Are Independent (Teammate B)

| Condition | Axis | Quantification | Mechanism |
|-----------|------|----------------|-----------|
| Modal saturation | Horizontal (cross-family) | Fixed time t, across families | `box_theory_witness_exists` |
| Temporal coherence | Vertical (within-family) | Fixed family, across times | `temporal_theory_witness_exists` |

- **No circular dependency**: both use `box_theory` but neither requires the other
- `boxClassFamilies` achieves saturation via `box_theory_witness_exists` (sorry-free)
- Temporal coherence is blocked by `SuccChainTemporalCoherent` depending on false `f_nesting_is_bounded`
- The two concerns must be solved independently and composed

### 3. Verified Sorry Status (Teammate C)

| Theorem | sorryAx? | Status |
|---------|----------|--------|
| `restricted_forward_chain_forward_F` | **YES** | Dead path |
| `temporal_theory_witness_exists` | No | Sorry-free |
| `past_theory_witness_exists` | No | Sorry-free |
| `box_theory_witness_exists` | No | Sorry-free |
| `boxClassFamilies_modal_forward` | No | Sorry-free |
| `boxClassFamilies_modal_backward` | No | Sorry-free |

### 4. The Central Technical Challenge (All Teammates)

`F(phi)` and `F(neg phi)` can coexist in an MCS. Therefore a single successor cannot satisfy ALL F-obligations simultaneously. Temporal coherence requires **eventual** resolution (some future time), not **immediate** resolution (next step).

**Solution**: Omega-enumeration with dovetailing — resolve one F-obligation per step, cycling through all obligations. Every obligation is reached in finite steps.

### 5. Proposed Architecture: Omega-Enumeration BFMCS (Teammate C)

```
Input: M (MCS with phi.neg)

1. omega_chain_forward(M) : N → MCS
   - c(0) = M
   - c(n+1) resolves oldest unresolved F-obligation via temporal_theory_witness_exists
   - Each step preserves G-theory and box_class_agree

2. omega_chain_backward(M) : N → MCS (symmetric via past_theory_witness_exists)

3. Dovetail into Z-chain: c(n) = forward(n) for n≥0, backward(-n) for n<0

4. Wrap as FMCS

5. Build boxClassFamilies using omega chains instead of SuccChainFMCS
   - For each W with box_class_agree(M₀, W): build omega chain from W
   - Bundle all such chains

6. Temporal coherence: BY CONSTRUCTION (dovetailing ensures every F(phi) eventually resolved)

7. Modal coherence: REUSE existing sorry-free boxClassFamilies_modal_forward/backward
   - Only needs box_class_agree, which omega chain preserves at each step

8. Wire to parametric_algebraic_representation_conditional
```

**What this avoids**: `f_nesting_is_bounded` (false), `boundary_resolution_set` (unprovable), `restricted_bounded_witness` termination (sorry), `SuccChainTemporalCoherent` (removed).

**What this uses**: Only the 3 sorry-free witness theorems + existing sorry-free modal infrastructure.

## Synthesis

### Conflicts Resolved

No conflicts between teammates in this wave. All three independently confirmed:
- Singleton BFMCS is wrong
- Multiple families needed for modal saturation
- Sorry-free witness theorems are the only viable building blocks

### Critical Prerequisites

**Before implementing**, verify:

1. **`box_class_agree` transitivity**: If `box_class_agree(M,W)` and `box_class_agree(W,V)` then `box_class_agree(M,V)`. Since `box_class_agree` means `forall phi, Box(phi) in M iff Box(phi) in W`, transitivity follows from iff-transitivity. Should be trivial but must exist or be proven.

2. **G-theory propagation through chain**: `G(a) in c(0) → G(a) in c(n)` for all n. This follows from `temporal_theory_witness_exists` giving G-theory agreement at each step, but needs formal induction.

3. **Dovetailing formalization**: The omega-enumeration needs a clean Lean encoding. One approach: define a priority function `priority : N × Formula → N` that assigns each `(t, phi)` pair (where `F(phi) in c(t)`) a unique priority, then at step n resolve the highest-priority unresolved obligation.

### Effort Estimate

| Component | LOC | Hours |
|-----------|-----|-------|
| `omega_chain_forward` + properties | ~150 | 2-3 |
| `omega_chain_backward` + properties | ~150 | 2-3 |
| Z-chain dovetailing | ~80 | 1 |
| New `boxClassFamilies` with omega chains | ~100 | 1-2 |
| Temporal coherence proof | ~100 | 1-2 |
| Wire to completeness | ~50 | 1 |
| **Total** | **~630** | **8-12** |

### Comparison to Prior Approaches

| Approach | Why It Failed | What This Approach Learns |
|----------|---------------|---------------------------|
| Strategy C (boundary_resolution_set) | Unprovable consistency | Don't build compound seeds — resolve one obligation at a time |
| Strategy A (ultrafilter F-witness) | MCS-level → within-chain gap | Build chain BY CONSTRUCTION so witnesses are in-chain by definition |
| Restricted chain | Termination sorry + seed sorry | Don't use SuccChainFMCS at all — replace with omega chain |
| Singleton BFMCS | Trivializes modal structure | Keep boxClassFamilies for saturation, replace only the chain construction |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Why singleton BFMCS fails | completed | HIGH |
| B | Saturation-coherence independence | completed | HIGH |
| C | Omega-enumeration design | completed | MEDIUM-HIGH |

## References

### Teammate Reports
- `specs/064_critical_path_review/reports/09_teammate-a-findings.md` — Singleton failure analysis
- `specs/064_critical_path_review/reports/09_teammate-b-findings.md` — Saturation investigation
- `specs/064_critical_path_review/reports/09_teammate-c-findings.md` — Omega-enumeration design

### Key Source Files
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — Witness theorems, boxClassFamilies
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` — Saturation definition and proofs
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` — Truth lemma (Box/Diamond cases)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` — Completeness conditional
