# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [PLANNED]
- **Effort**: 24-48 hours
- **Dependencies**: None
- **Research Inputs**: research-001 through research-016 (16 reports)
- **Artifacts**: plans/implementation-012.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 012 (revised from 011 - omega-squared immediate processing approach)

## Overview

This plan implements **omega-squared with immediate processing** to close the forward_F and backward_P sorries in DovetailingChain.lean. This is the ONLY viable path identified across 16 research reports and 11 prior plan versions.

### Why Previous Approaches Failed

Per research-015 and research-016 (team consensus):

| Approach | Fatal Blocker | Source |
|----------|---------------|--------|
| Enriched chain (v011) | F-formulas don't persist through GContent seeds | Phase 5B analysis |
| Witness-graph-guided | DAG has local GContent propagation, not universal | research-016 |
| Constant family oracle | F(psi) in M doesn't imply psi in M | Phase 6 analysis |
| Two-timeline embedding | Nodes reachable by both directions conflict | research-016 Teammate A |
| Tree unraveling | Destroys inverse relation for past operators | research-016 Teammate B |
| Mosaic method | 80-120h, no existing infrastructure | research-016 Teammate C |

### Why Omega-Squared with Immediate Processing Works

The key insight is that **F-formulas must be processed IMMEDIATELY when they appear**, not via enumeration-based scheduling:

1. **Process immediately**: When F(psi) first appears at step n, process it as the VERY FIRST operation BEFORE any Lindenbaum extension can introduce G(neg(psi))
2. **Proven consistent seed**: `{psi} union GContent(M)` is consistent when F(psi) in M (by `witnessSeed_consistent`)
3. **One obligation at a time**: FPreservingSeed counterexample used infinitely many formulas; single-formula seed is proven consistent
4. **GContent monotonicity**: G(phi) -> G(G(phi)) (4-axiom) ensures GContent propagates
5. **Produces BFMCS directly**: Outputs Int -> Set Formula without embedding step

### Current State (from v011 completion)

| Component | Status |
|-----------|--------|
| WitnessGraph.lean | 0 errors, 0 sorries |
| DovetailingChain forward_F/backward_P | 2 sorries (mathematically unprovable for linear chain) |
| `witnessSeed_consistent` | Proven (WitnessGraph.lean:544) |
| `forward_temporal_witness_seed_consistent` | Proven (DovetailingChain.lean) |
| `GContent_subset_implies_HContent_reverse` | Proven (DovetailingChain.lean) |

### Architecture

**Omega-Squared Construction Pattern:**

```
Outer chain: M_0, M_1, M_2, ...
For each outer step n:
  Inner chain: M_{n,0}, M_{n,1}, M_{n,2}, ...
  For each F(psi_k) appearing in M_{n,0}:
    M_{n,k+1} = Lindenbaum({psi_k} union GContent(M_{n,k}))
    (Process F(psi_k) IMMEDIATELY as next inner step)
```

The final BFMCS maps Int to the diagonal: `mcs(i) = M_{i,omega}` (limit of inner chain at outer step i).

## Implementation Phases

### Phase 1: Documentation Cleanup [NOT STARTED]

- **Dependencies**: None
- **Goal**: Fix misleading comments that confuse future agents
- **Estimated effort**: 2-4 hours

**Why First**: Research-015 Teammate B identified that agents keep retrying linear chain approaches because the code tells a "compelling but incomplete story." Fix the documentation first to prevent confusion.

**Tasks:**

1. **Update DovetailingChain.lean module docstring** (lines 38-46)
   - Remove claim that "F-witness formulas via dovetailing enumeration" is the mechanism
   - Add clear statement that forward_F requires non-linear construction (omega-squared)

2. **Update GContent definition** (if no existing warning)
   - Add note that GContent strips F-formulas
   - Reference the F-persistence impossibility

3. **Add "DO NOT TRY" list at BFMCS definition**
   - List the blocked approaches with 1-line explanations
   - Reference research-015/016 for details

4. **Update misleading comments in WitnessGraph.lean**
   - Line 2534-2538: "enabling Phase 5 to prove forward_F" -> clarify this refers to omega-squared, not enriched chain

5. **Update TemporalCoherentConstruction.lean**
   - Lines 559-564: clarify that forward_F is NOT yet proven for the current construction

**Verification:**
- Documentation reviewed for misleading claims
- `lake build` still succeeds

**Exit Criteria:**
- [ ] DovetailingChain.lean docstring updated
- [ ] GContent warning added
- [ ] BFMCS "DO NOT TRY" list added
- [ ] WitnessGraph.lean misleading comments fixed
- [ ] TemporalCoherentConstruction.lean updated

---

### Phase 2: GContent Infrastructure [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Prove GContent monotonicity and path propagation lemmas
- **Estimated effort**: 4-8 hours

**Key Lemmas to Prove:**

```lean
-- GContent monotonicity: if GContent(M) subset M', then GContent(M) subset GContent(M')
-- Follows from 4-axiom: G(phi) -> G(G(phi))
lemma GContent_mono (M M' : Set Formula) (hM : SetMaximalConsistent M) (hM' : SetMaximalConsistent M')
    (h : GContent M ⊆ M') : GContent M ⊆ GContent M' := by
  intro phi hphi
  -- phi in GContent M means G(phi) in M
  -- By h, phi in M'
  -- Need: G(phi) in M'
  -- Since M is MCS with G(phi), we have G(G(phi)) in M (4-axiom)
  -- By GContent definition, G(phi) in GContent M
  -- By h, G(phi) in M'
  sorry

-- GContent path propagation: along a chain with GContent seeds, GContent propagates
lemma GContent_path_propagates (chain : Nat -> Set Formula)
    (h_mcs : forall n, SetMaximalConsistent (chain n))
    (h_seed : forall n, GContent (chain n) ⊆ chain (n+1)) :
    forall m n, m < n -> GContent (chain m) ⊆ chain n := by
  intro m n hmn
  induction' hmn with k _ ih
  · exact h_seed m
  · exact subset_trans ih (h_seed k)
```

**Implementation Steps:**

1. Add `GContent_mono` to DovetailingChain.lean (or WitnessGraph.lean if more appropriate)
2. Add `GContent_path_propagates`
3. Add `HContent_mono` and `HContent_path_propagates` (symmetric for P obligations)

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.DovetailingChain` succeeds
- No new sorries in GContent lemmas

**Exit Criteria:**
- [ ] `GContent_mono` proven (0 sorries)
- [ ] `GContent_path_propagates` proven (0 sorries)
- [ ] `HContent_mono` proven (0 sorries)
- [ ] `HContent_path_propagates` proven (0 sorries)
- [ ] `lake build` succeeds

---

### Phase 3: Omega-Squared Construction [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Define and prove the omega-squared BFMCS construction
- **Estimated effort**: 12-20 hours

**Mathematical Design:**

The omega-squared construction builds a BFMCS where each F-obligation is processed immediately:

```lean
/-- Inner chain for processing F-obligations at a fixed outer step.
    At each inner step k, process F(decode(k)) if present and not yet witnessed. -/
def innerChainMCS (outerMCS : Set Formula) (h_mcs : SetMaximalConsistent outerMCS)
    (k : Nat) : Set Formula :=
  match k with
  | 0 => outerMCS
  | k+1 =>
    let prev := innerChainMCS outerMCS h_mcs k
    let formula := decodeFormula k
    if h : .future formula ∈ prev then
      -- Process this F-obligation immediately
      Lindenbaum ({formula} ∪ GContent prev) (witnessSeed_consistent _ _ _)
    else
      -- No F-obligation to process, just extend with GContent seed
      Lindenbaum (GContent prev) (GContent_consistent _ _)

/-- Limit of inner chain (direct limit of omega sequence) -/
def innerChainLimit (outerMCS : Set Formula) (h_mcs : SetMaximalConsistent outerMCS) : Set Formula :=
  ⋃ k, innerChainMCS outerMCS h_mcs k

/-- Outer chain, where each step's inner chain processes all F-obligations -/
def outerChainMCS (n : Nat) : Set Formula :=
  match n with
  | 0 => rootMCS.val
  | n+1 => innerChainLimit (outerChainMCS n) (outerChainMCS_mcs n)

/-- The omega-squared BFMCS mapping Int to outer chain steps -/
def omegaSquaredBFMCS : BFMCS Int where
  mcs t :=
    if t ≥ 0 then outerChainMCS t.toNat
    else backwardOuterChainMCS (-t).toNat  -- Symmetric for negative times
```

**Key Properties to Prove:**

1. **Inner chain MCS property**: Each `innerChainMCS` step is an MCS
2. **Inner chain GContent propagation**: GContent propagates through inner chain
3. **Inner chain F-coverage**: Every F-obligation in outerMCS gets its witness in innerChainLimit
4. **Inner chain limit is MCS**: The directed limit preserves MCS property
5. **Outer chain MCS property**: Each `outerChainMCS` step is an MCS
6. **Outer chain GContent propagation**: GContent propagates through outer chain
7. **forward_F for omegaSquaredBFMCS**: If F(psi) in mcs(t), exists s > t with psi in mcs(s)
8. **forward_G for omegaSquaredBFMCS**: Universal GContent propagation
9. **Symmetric properties for HContent/backward_P/backward_H**

**Files to Modify:**

- **New file**: `Theories/Bimodal/Metalogic/Bundle/OmegaSquaredChain.lean`
  - Define omega-squared construction
  - Prove inner/outer chain properties
  - Define `omegaSquaredBFMCS`
  - Prove forward_F, backward_P, forward_G, backward_H

**Implementation Steps:**

1. Create OmegaSquaredChain.lean with imports
2. Define `innerChainMCS` and prove MCS property
3. Prove GContent propagation through inner chain
4. Define `innerChainLimit` and prove it's an MCS (directed limit)
5. Prove F-coverage: inner chain limit witnesses all F-obligations from base
6. Define `outerChainMCS` and `backwardOuterChainMCS`
7. Prove GContent/HContent propagation through outer chains
8. Define `omegaSquaredBFMCS`
9. Prove forward_G and backward_H (GContent/HContent universal propagation)
10. Prove forward_F using inner chain F-coverage
11. Prove backward_P (symmetric)

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.OmegaSquaredChain` succeeds
- All 4 BFMCS properties proven (forward_F, backward_P, forward_G, backward_H)
- No sorries in OmegaSquaredChain.lean

**Exit Criteria:**
- [ ] `innerChainMCS` defined with MCS proof
- [ ] `innerChainLimit` defined with MCS proof
- [ ] `outerChainMCS` defined with MCS proof
- [ ] `omegaSquaredBFMCS` defined
- [ ] `omegaSquaredBFMCS.forward_F` proven (0 sorries)
- [ ] `omegaSquaredBFMCS.backward_P` proven (0 sorries)
- [ ] `omegaSquaredBFMCS.forward_G` proven (0 sorries)
- [ ] `omegaSquaredBFMCS.backward_H` proven (0 sorries)
- [ ] 0 sorries in OmegaSquaredChain.lean
- [ ] `lake build` succeeds

---

### Phase 4: Integration into DovetailingChain [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Wire omega-squared construction to close DovetailingChain sorries
- **Estimated effort**: 4-8 hours

**Tasks:**

1. **Import OmegaSquaredChain.lean into DovetailingChain.lean**
   ```lean
   import Bimodal.Metalogic.Bundle.OmegaSquaredChain
   ```
   Check for circular dependency issues.

2. **Replace `buildDovetailingChainFamily` sorries**
   - Line ~1754 (forward_F): Replace sorry with omega-squared proof
   - Line ~1761 (backward_P): Replace sorry with omega-squared proof

   Option A: Redirect to use `omegaSquaredBFMCS` instead of current chain
   Option B: Keep current chain for forward_G/backward_H, delegate forward_F/backward_P to omega-squared

3. **Update downstream theorems**
   - Verify `fully_saturated_bmcs_exists_int` still compiles
   - Verify `buildBimorphismIntSet` still works

4. **Clean up**
   - Remove any residual sorry'd theorems that omega-squared replaces
   - Update docstrings to reflect new construction

**Verification:**
```bash
lake build Bimodal.Metalogic.Bundle.DovetailingChain
# Must succeed with 0 new sorries (may still have unrelated sorries)
```

**Exit Criteria:**
- [ ] OmegaSquaredChain imported without circular dependency
- [ ] forward_F sorry at line ~1754 replaced
- [ ] backward_P sorry at line ~1761 replaced
- [ ] Downstream theorems compile
- [ ] `lake build` succeeds with no new sorries

---

### Phase 5: Documentation and Summary [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Create implementation summary and verify no axioms
- **Estimated effort**: 1-2 hours

**Tasks:**

1. **Create implementation summary** documenting:
   - Total lines added/modified
   - Key lemmas proven
   - Architecture decisions
   - Build verification results

2. **Verify no axioms via `lean_verify`**:
   ```bash
   # Verify key theorems
   mcp__lean-lsp__lean_verify OmegaSquaredChain forward_F
   mcp__lean-lsp__lean_verify DovetailingChain forward_F
   ```

3. **Update state.json with completion_summary**

4. **Create BLOCKED_APPROACHES.md** (optional)
   - Consolidate the analysis of blocked approaches
   - Reference for future development

**Exit Criteria:**
- [ ] Implementation summary written
- [ ] No new axioms verified
- [ ] Task marked complete

---

## Summary

| Phase | Description | Effort | Depends On |
|-------|-------------|--------|------------|
| 1 | Documentation cleanup | 2-4h | None |
| 2 | GContent infrastructure | 4-8h | 1 |
| 3 | Omega-squared construction | 12-20h | 2 |
| 4 | Integration with DovetailingChain | 4-8h | 3 |
| 5 | Documentation | 1-2h | 4 |

**Total Estimated Effort:** 24-48 hours (vs 55-75h for v011)

---

## Key Technical Insights (from 16 Research Reports)

### From research-015 (Team Research)
- F-formulas must be processed IMMEDIATELY when they appear
- Code tells "compelling but incomplete story" that misleads agents
- Documentation cleanup is critical

### From research-016 (Team Research)
- Witness-graph-guided is definitively blocked (universal vs local GContent)
- Omega-squared immediate processing is the ONLY viable path
- 65-75% success probability at 24-48h effort
- Risk-adjusted expected value favors omega-squared over all alternatives

### Mathematical Foundation
- `witnessSeed_consistent` (WitnessGraph.lean:544): Single-formula seed is consistent
- FPreservingSeed counterexample uses infinitely many formulas; doesn't apply here
- 4-axiom (G(phi) -> G(G(phi))) ensures GContent monotonicity

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Inner chain limit MCS proof complexity | MEDIUM | HIGH | Follow existing directed limit patterns |
| GContent monotonicity trickier than expected | LOW | MEDIUM | 4-axiom already proven |
| Phase 3 takes longer than 20h | MEDIUM | MEDIUM | Time-box; partial progress acceptable |
| Integration causes circular imports | LOW | MEDIUM | Factor shared lemmas to common module |

---

## Literature References

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Blackburn, de Rijke, Venema (2001). *Modal Logic*. Cambridge University Press.
- Reynolds, M. (2003). "Completeness by construction for tense logics of linear time."

---

## Success Criteria

- [ ] DovetailingChain.lean: forward_F and backward_P closed (0 sorries from current 2)
- [ ] OmegaSquaredChain.lean: 0 sorries, 0 errors
- [ ] `lake build` succeeds
- [ ] No new axioms introduced
- [ ] Implementation summary created
