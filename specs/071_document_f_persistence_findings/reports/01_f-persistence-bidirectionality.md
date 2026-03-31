# Research Report: Task #71

**Task**: 71 - document_f_persistence_findings
**Started**: 2026-03-31T00:00:00Z
**Completed**: 2026-03-31T00:30:00Z
**Effort**: 2-3 hours (documentation)
**Dependencies**: None
**Sources/Inputs**:
- Codebase exploration (SuccChainTruth.lean, ParametricTruthLemma.lean, SuccChainFMCS.lean)
- Task 69 reports (18_spawn-analysis.md, 17_team-research.md)
- Task 70 artifacts (plans/05_separate-direction-witnesses.md, summaries/07_separate-direction-summary.md)
- ROADMAP.md
**Artifacts**: specs/071_document_f_persistence_findings/reports/01_f-persistence-bidirectionality.md
**Standards**: report-format.md

## Executive Summary

This research confirms all three documentation items:

1. **F-persistence counterexample**: `f_preserving_seed_consistent` is FALSE with a concrete counterexample (task 69 research). Chain-level F-preservation is mathematically impossible. Bundle-level coherence is the proven alternative.

2. **Truth lemma bidirectionality constraint**: The truth lemma is INHERENTLY BIDIRECTIONAL. The forward Imp case at line 200 of SuccChainTruth.lean uses `(ih_psi t).mpr` - the BACKWARD induction hypothesis. This propagates to require `forward_F`/`backward_P` for G/H backward cases. A "forward-only" truth lemma is impossible for the biconditional form.

3. **Separate-direction witness status**: Task 70 proved `forward_G`/`backward_H` sorry-free (SuccChainFMCS.lean lines 449, 513), but `forward_F`/`backward_P` have sorries due to unbounded F/P nesting. The F/P gap is the remaining blocker for sorry-free completeness.

## Context & Scope

This task consolidates discoveries from tasks 67, 69, and 70 into ROADMAP.md and source code comments. The research findings require documentation in three areas.

---

## Finding 1: F-Persistence Counterexample

### Evidence Location

**Source**: `specs/069_close_z_chain_forward_f/reports/17_team-research.md` lines 19-74

### The Counterexample

**Setup**: Let M be an MCS where:
- `F(p) in M` (p eventually)
- `F(q) in M` (q eventually)
- `p not in M`, `q not in M` (both false now)
- `G(p -> G(neg q)) in M` (always: if p then always neg q)

**The seed** `f_preserving_seed M p = {p} union temporal_box_seed M union F_unresolved_theory M` contains:
1. `p` (witness formula)
2. `G(p -> G(neg q))` (from G_theory M)
3. `F(q)` (from F_unresolved_theory M)

**Derivation of contradiction**:
1. From `G(p -> G(neg q))`, T-axiom: `p -> G(neg q)`
2. From `p` and `p -> G(neg q)`, modus ponens: `G(neg q)`
3. `G(neg q) = neg(F(q))`
4. We have both `F(q)` and `neg(F(q))` in the seed: **contradiction**

The seed is **inconsistent**. The theorem `f_preserving_seed_consistent` is **FALSE**.

### Code Location

**File**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
**Line**: 2668

```lean
theorem f_preserving_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi in M) :
    SetConsistent (f_preserving_seed M phi) := by
```

### Why Chain-Level F-Preservation Cannot Work

The F-preserving seed tries to force ALL unresolved F-formulas into the successor world simultaneously. But some F-formulas may require resolution BEFORE phi, not after. In the counterexample:
- q must hold before p (since after p, G(neg q) makes q impossible)
- At a world where p holds, F(q) cannot be satisfied
- Therefore `{p, F(q)}` is inconsistent when `G(p -> G(neg q))` is in the temporal box seed

### Dead Code to Mark

| Theorem | Line | Status | Reason |
|---------|------|--------|--------|
| `f_preserving_seed_consistent` | 2668 | FALSE | Counterexample proves inconsistency |
| `temporal_theory_witness_F_preserving` | 2114+ | Depends on false theorem | |
| `omega_step_forward_F_preserving` | 4751+ | Depends on false theorem | |
| `Z_chain_forward_F` | 3400-3422 | sorry | Built on false foundation |

### Proven Bundle Components

| Theorem | Location | Status |
|---------|----------|--------|
| `boxClassFamilies_bundle_forward_F` | UltrafilterChain.lean:3588 | Sorry-free |
| `boxClassFamilies_bundle_backward_P` | UltrafilterChain.lean:3633 | Sorry-free |
| `boxClassFamilies_bundle_temporally_coherent` | UltrafilterChain.lean:3675 | Sorry-free |
| `construct_bfmcs_bundle` | UltrafilterChain.lean:3799 | Sorry-free |

The bundle approach sidesteps F-persistence by using **different families** for temporal witnesses.

---

## Finding 2: Truth Lemma Bidirectionality Constraint

### The Critical Evidence

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean`
**Lines**: 197-205

```lean
| imp psi chi ih_psi ih_chi =>
    -- Imp: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := succ_chain_fam_mcs M0 t
    constructor
    . -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      -- By IH backward: psi in MCS
      have h_psi_mcs : psi in succ_chain_fam M0 t := (ih_psi t).mpr h_psi_true  -- <-- BACKWARD IH
      -- By MCS modus ponens: chi in MCS
      have h_chi_mcs : chi in succ_chain_fam M0 t :=
        SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi t).mp h_chi_mcs
```

**The critical line** is `(ih_psi t).mpr h_psi_true` at line 200. The forward direction of the Imp case uses `.mpr` - the BACKWARD induction hypothesis for psi.

### Same Pattern in ParametricTruthLemma.lean

**File**: `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
**Lines**: 243-254

```lean
    . -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      -- NOTE: This is why the truth lemma is inherently bidirectional.
      -- The forward direction uses the BACKWARD IH for psi (.mpr).
      -- This means proving "MCS membership -> truth" for any imp formula
      -- requires "truth -> MCS membership" for its antecedent subformula.
      -- When that subformula contains G/H, the backward IH needs h_tc.
      intro h_imp h_psi_true
      -- By IH backward (the critical cross-direction dependency):
      have h_psi_mcs : psi in fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
```

The comment explicitly documents this structural requirement.

### Why Forward-Only is Impossible

The proof structure for the forward Imp case is:

```
Forward imp: (psi -> chi) in MCS, truth(psi) |- truth(chi)
  Step 1: truth(psi) -> psi in MCS        [BACKWARD IH for psi]
  Step 2: (psi -> chi) in MCS, psi in MCS -> chi in MCS  [MCS modus ponens]
  Step 3: chi in MCS -> truth(chi)          [FORWARD IH for chi]
```

Step 1 requires the backward direction. This propagates: since `neg(phi) = phi.imp bot`, proving the forward direction for `neg(phi)` requires the backward direction for `phi`. If `phi` contains G or H subformulas, the backward direction for those cases requires `forward_F`/`backward_P` (temporal coherence).

### Misleading Comment to Correct

**File**: `ROADMAP.md`
**Line**: 195

**Current (INCORRECT)**:
```
- For completeness, only FORWARD truth lemma direction is needed
```

**This is misleading** because:
1. The forward Imp case structurally uses the backward IH
2. The backward G/H cases require `forward_F`/`backward_P`
3. A "forward-only" truth lemma cannot exist for the biconditional form

The comment should be corrected or removed.

---

## Finding 3: Separate-Direction Witness Status

### Task 70 Results

Task 70 (plan v5) proved that the separate-direction witness approach works:

**Sorry-Free Theorems**:

| Theorem | File | Line | Status |
|---------|------|------|--------|
| `succ_chain_forward_G` | SuccChainFMCS.lean | 449 | Sorry-free |
| `succ_chain_forward_G_le` | SuccChainFMCS.lean | 972 | Sorry-free |
| `succ_chain_backward_H` | SuccChainFMCS.lean | 513 | Sorry-free |
| `succ_chain_backward_H_le` | SuccChainFMCS.lean | 988 | Sorry-free |
| `SuccChainFMCS.forward_G` | SuccChainFMCS.lean | 1004 | Sorry-free |
| `SuccChainFMCS.backward_H` | SuccChainFMCS.lean | 1005 | Sorry-free |

**Source**: `specs/070_explore_ultrafilter_construction/summaries/07_separate-direction-summary.md`

### F/P Gaps Remain Open

From SuccChainFMCS.lean lines 1022-1027:

```lean
**Known Gaps (documented in Task #70):**
- The BACKWARD direction of the truth lemma for G/H uses `temporal_backward_G`
  and `temporal_backward_H` from TemporalCoherence.lean, which require
  `forward_F` and `backward_P` properties (existential witnesses)
- `forward_F` and `backward_P` have sorries due to unbounded F/P nesting
- For sorry-free completeness, use `semantic_weak_completeness` (FMP path)
```

### How temporal_backward_G Uses forward_F

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
**Lines**: 165-178

```lean
theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (phi : Formula)
    (h_all : forall s : D, t <= s -> phi in fam.mcs s) :
    Formula.all_future phi in fam.mcs t := by
  by_contra h_not_G
  have h_mcs := fam.is_mcs t
  have h_neg_G : Formula.neg (Formula.all_future phi) in fam.mcs t := by
    -- negation completeness
  -- neg(G(phi)) = F(neg(phi))
  -- By forward_F: exists s >= t with neg(phi) in fam.mcs s  <-- USES forward_F
  -- But h_all says phi in fam.mcs s. Contradiction.
```

The contrapositive proof requires `forward_F` to find a witness where `neg(phi)` holds.

### Why This Blocks Sorry-Free Completeness

Since the truth lemma is inherently bidirectional (Finding 2):
- Forward Imp uses backward IH
- Backward G uses `temporal_backward_G` which requires `forward_F`
- Backward H uses `temporal_backward_H` which requires `backward_P`

Therefore, `forward_F`/`backward_P` are required for a fully sorry-free completeness proof.

---

## Decisions

1. **Document F-persistence counterexample**: Add clear comments to UltrafilterChain.lean marking the F-persistence approach as dead code.

2. **Correct ROADMAP.md line 195**: The statement "For completeness, only FORWARD truth lemma direction is needed" is misleading and should be corrected to explain the bidirectionality constraint.

3. **Document truth lemma bidirectionality**: Add comments to SuccChainTruth.lean and ParametricTruthLemma.lean explicitly explaining why the forward Imp case requires the backward IH.

4. **Document F/P gaps**: The existing documentation in SuccChainFMCS.lean (lines 1007-1040) is accurate and should be preserved.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Misleading existing comments cause confusion | Correct or remove misleading statements |
| Future attempts to revive chain-level F-preservation | Clear documentation of counterexample |
| Misunderstanding of truth lemma structure | Explicit comments at the Imp case |

---

## Documentation Checklist

### ROADMAP.md
- [ ] Correct line 195 statement about forward-only truth lemma
- [ ] Add section on F-persistence counterexample (consolidate from 18_spawn-analysis.md)
- [ ] Document truth lemma bidirectionality constraint
- [ ] Update "Temporal Coherence Resolution" section with task 70 findings

### SuccChainTruth.lean
- [x] Comment at Imp case explaining bidirectionality (lines 37-39 already exist)
- [ ] Reference to task 70 F/P gap documentation

### ParametricTruthLemma.lean
- [x] Comments explain bidirectionality (lines 17-33 already exist)
- [x] Lines 243-247 document the cross-direction dependency

### SuccChainFMCS.lean
- [x] Task 70 Phase 6 documentation exists (lines 1007-1040)
- [ ] Add reference to F-persistence counterexample

### UltrafilterChain.lean
- [ ] Mark `f_preserving_seed_consistent` as FALSE with counterexample reference
- [ ] List dependent dead code
- [ ] Document proven bundle components

---

## Appendix

### Search Queries Used
- `succ_chain_forward_G|succ_chain_backward_H|forward_F|backward_P` in SuccChainFMCS.lean
- `f_preserving_seed_consistent` in Theories/Bimodal
- `For completeness.*only.*FORWARD` in repository
- `temporal_backward_G|temporal_backward_H` in TemporalCoherence.lean

### References to Documentation
- Task 69 report 17: `specs/069_close_z_chain_forward_f/reports/17_team-research.md`
- Task 69 spawn analysis: `specs/069_close_z_chain_forward_f/reports/18_spawn-analysis.md`
- Task 70 plan v5: `specs/070_explore_ultrafilter_construction/plans/05_separate-direction-witnesses.md`
- Task 70 summary: `specs/070_explore_ultrafilter_construction/summaries/07_separate-direction-summary.md`
- Task 70 blocker analysis: `specs/070_explore_ultrafilter_construction/reports/10_blocker-analysis.md`
