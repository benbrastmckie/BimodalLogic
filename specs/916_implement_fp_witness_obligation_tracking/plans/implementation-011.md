# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [PLANNED]
- **Effort**: 55-75 hours
- **Dependencies**: None
- **Research Inputs**: research-001 through research-014 (14 reports)
- **Artifacts**: plans/implementation-011.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean
- **Lean Intent**: true
- **Version**: 011 (revised from 010 - full commitment to WitnessGraph approach)

## Overview

This plan commits fully to the **WitnessGraph (Deferred Concretization) approach** for closing the forward_F and backward_P sorries in DovetailingChain.lean. This is the ONLY viable path identified across 14 research reports and 10 prior implementation plans.

### Why WitnessGraph Is the Only Path

Per research-003 (team consensus), research-010 (deferred concretization), and research-014 (synthesis):

**Approaches definitively blocked:**
| Approach | Fatal Blocker | Source |
|----------|---------------|--------|
| Constructive Lindenbaum | TCS/MCS incompatibility (Boneyard: 4+ sorries) | research-003 |
| Canonical Model + Unraveling | 20-30h rewrite that faces same challenge | research-003 |
| Dependent Choice + Priority Queue | F-formula death at witness steps unsolvable | research-003 |
| F-Preserving Seed | Counterexample refutes the conjecture | v005 failure |
| Derivation Surgery | Gap at step 12 unfillable | research-007 |
| Linear Chain (flat) | Lindenbaum opacity + past-encoding gap | research-004, 008 |

**Why WitnessGraph works:**
1. Each F/P obligation gets its own **fresh Lindenbaum extension** (no persistence problem)
2. Witnesses are placed **on-demand** (no past-encoding problem)
3. Uses only the PROVEN `forward_temporal_witness_seed_consistent` lemma
4. Matches standard textbook technique (Goldblatt 1992, Blackburn et al. 2001, Reynolds 2003)

### Current State

WitnessGraph.lean exists with:
- ~3100 lines of implementation
- 5 build errors (unknown identifiers)
- 4 sorries (forward_F, backward_P, forward_G, backward_H)
- Phases 1-2 complete (structure + construction)
- Phase 4 complete (Int embedding infrastructure)
- Phase 5 blocked (same omega² obstruction)

### Architecture (from research-010)

**Phase 1 (Witness Graph Construction)**: Build a countable directed graph where:
- Nodes are MCSs (created via Lindenbaum)
- Edges encode temporal ordering constraints (GContent propagation)
- Each F-obligation at a node has a dedicated witness node
- Each P-obligation at a node has a dedicated past-witness node

**Phase 2 (Int Embedding)**: Embed the witness graph into Int:
- Show the graph is a countable partial order with no cycles
- Embed into Int using order-embedding
- Prove embedding preserves GContent/HContent propagation

## Implementation Phases

### Phase 3B: Fix Remaining Build Errors [NOT STARTED]

- **Dependencies**: None
- **Goal**: Make WitnessGraph.lean build with 0 errors
- **Estimated effort**: 2-4 hours

**Current Build Errors** (5 total):

| Line | Error | Missing Identifier |
|------|-------|-------------------|
| 2956 | Unknown identifier | `set_mcs_neg_or` |
| 2985 | Unknown identifier | `set_mcs_neg_or` |
| 3073 | Unknown identifier | `GContent_subset_implies_HContent_reverse` |
| 3086 | Unknown identifier | `GContent_subset_implies_HContent_reverse` |

**Fix Strategy:**

**Fix 1: `set_mcs_neg_or` (lines 2956, 2985)**

This lemma should already exist or be easy to prove:
```lean
lemma set_mcs_neg_or (M : Set Formula) (hM : SetMaximalConsistent M) (phi psi : Formula) :
    ¬phi ∈ M → ((.or phi psi) ∈ M ↔ psi ∈ M) := by
  intro hnphi
  constructor
  · intro hor
    have : phi ∈ M ∨ psi ∈ M := mcs_or_iff.mp hor
    rcases this with h | h
    · exact absurd h hnphi
    · exact h
  · intro hpsi
    exact mcs_or_iff.mpr (Or.inr hpsi)
```

Either:
1. Search codebase for existing lemma with `lean_local_search`
2. Add to WitnessGraph.lean if not found

**Fix 2: `GContent_subset_implies_HContent_reverse` (lines 3073, 3086)**

This lemma exists in DovetailingChain.lean. Either:
1. Import DovetailingChain.lean (may create circular dependency - check)
2. Duplicate the lemma in WitnessGraph.lean
3. Factor into a shared module

Per research-003, this lemma IS proven in DovetailingChain.lean:
> `GContent_subset_implies_HContent_reverse` -- DovetailingChain.lean line 692 (proven, sorry-free)

**Verification:**
```bash
lake build Bimodal.Metalogic.Bundle.WitnessGraph
# Target: 0 errors (sorries acceptable at this stage)
```

**Exit Criteria:**
- [x] All unknown identifier errors resolved
- [x] `lake build` succeeds for WitnessGraph.lean
- [ ] Document which approach used for each fix

---

### Phase 5A: Resolve Cross-Sign Sorries [NOT STARTED]

- **Dependencies**: Phase 3B
- **Goal**: Close forward_G and backward_H sorries
- **Estimated effort**: 8-12 hours

**Mathematical Background:**

The cross-sign sorries (forward_G, backward_H) should be straightforward given the constant family design (all times map to rootMCS). Per Phase 4 design:

> The constant family avoids [the backward edge problem] entirely. The T-axiom (G phi -> phi, H phi -> phi) gives forward_G and backward_H trivially.

**Current Sorries:**
- `enrichedChainBFMCS.forward_G` (line ~3109)
- `enrichedChainBFMCS.backward_H` (line ~3111)

**Approach:**

For the constant family where `mcs(t) = rootMCS.val` for all t:

```lean
-- forward_G: G(phi) ∈ mcs(t) → ∀ s > t, phi ∈ mcs(s)
-- Since mcs(t) = mcs(s) = rootMCS.val, we need: G(phi) ∈ M → phi ∈ M
-- This follows from the T-axiom: ⊢ G(phi) → phi
theorem witnessGraphBFMCS_forward_G : ...forward_G... := by
  intro t phi h_G s h_lt
  simp only [witnessGraphBFMCS_mcs_eq] at h_G ⊢
  exact mcs_G_implies_self _ rootMCS.property phi h_G

-- backward_H: H(phi) ∈ mcs(t) → ∀ s < t, phi ∈ mcs(s)
-- Same argument with T-axiom for H
theorem witnessGraphBFMCS_backward_H : ...backward_H... := by
  intro t phi h_H s h_lt
  simp only [witnessGraphBFMCS_mcs_eq] at h_H ⊢
  exact mcs_H_implies_self _ rootMCS.property phi h_H
```

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.WitnessGraph` succeeds
- forward_G and backward_H sorries eliminated

**Exit Criteria:**
- [ ] `enrichedChainBFMCS.forward_G` proven (0 sorries)
- [ ] `enrichedChainBFMCS.backward_H` proven (0 sorries)
- [ ] 2 sorries remaining (forward_F, backward_P)

---

### Phase 5B: Prove Forward_F via Witness Graph Bridge [NOT STARTED]

- **Dependencies**: Phase 5A
- **Goal**: Close forward_F sorry using witness graph as oracle
- **Estimated effort**: 15-25 hours

**Mathematical Strategy (from research-010, Section 5):**

The key insight is that the witness graph serves as an **oracle** proving that witnesses exist. The bridge argument:

1. Given: `F(psi) ∈ mcs(t)` in the BFMCS
2. Since BFMCS uses constant family: `F(psi) ∈ rootMCS.val`
3. By witness graph construction: there exists a node `q` in the graph where `psi ∈ g.mcsAt q`
4. The node q has a specific index in the graph
5. We need to show there exists `s > t` with `psi ∈ mcs(s)`

**The Gap:** The constant family design means `mcs(s) = rootMCS.val` for all s. So we need `psi ∈ rootMCS.val`. But `F(psi) ∈ rootMCS.val` does NOT imply `psi ∈ rootMCS.val` in general.

**Resolution: Non-Constant Family**

The constant family was a simplification that doesn't work. We need to use the witness graph to build a **non-constant** BFMCS:

```lean
-- Map witness graph nodes to integers
def witnessGraphBFMCS (g : WitnessGraph) : BFMCS Int where
  mcs t :=
    if h : t.toNat < g.nodes.length then
      g.nodes[t.toNat].mcs.val
    else
      rootMCS.val
```

This requires proving:
1. **forward_G**: GContent propagation along forward edges in the graph lifts to Int ordering
2. **backward_H**: HContent propagation along backward edges lifts to Int ordering
3. **forward_F**: For `F(psi)` at node index t, there exists node index s > t with psi at s
4. **backward_P**: Symmetric for P

**Key Lemmas Needed:**

```lean
-- Forward edges carry GContent
lemma witnessGraph_forward_edge_GContent (g : WitnessGraph) (e : WitnessEdge)
    (he : e ∈ g.edges) (h_dir : e.direction = .forward) :
    GContent (g.mcsAt e.src).val ⊆ (g.mcsAt e.dst).val

-- Graph node ordering is compatible with Int ordering
lemma witnessGraph_acyclic_implies_int_ordering (g : WitnessGraph) :
    ∀ e ∈ g.edges, e.src < e.dst

-- Forward_F witness exists in graph
lemma witnessGraph_forward_F_witness (g : WitnessGraph) (rootMCS : ...)
    (n : Nat) (hn : n < g.nodes.length) (psi : Formula) :
    F(psi) ∈ (g.mcsAt n).val →
    ∃ m, n < m ∧ m < g.nodes.length ∧ psi ∈ (g.mcsAt m).val
```

**Coverage Argument (from research-003, Section 5):**

The core coverage argument uses enumeration:
- For any `F(psi) ∈ M_n`, let `k = encodeFormulaWG psi`
- At step `(n, k)` in the Nat.unpair enumeration, the graph construction checks if `F(psi) ∈ g.nodes[n].mcs.val`
- If yes, it creates a witness node via `addFutureWitness`
- The witness node contains psi (by `addFutureWitness_contains_formula`)

**Implementation Steps:**

1. Refactor `witnessGraphBFMCS` to use non-constant node indexing
2. Prove `witnessGraph_acyclic_implies_int_ordering`
3. Prove `witnessGraph_forward_edge_GContent`
4. Prove `witnessGraph_forward_F_witness` using coverage argument
5. Assemble into `witnessGraphBFMCS_forward_F`

**Verification:**
- forward_F sorry eliminated
- `lake build` succeeds

**Exit Criteria:**
- [ ] `witnessGraphBFMCS` uses non-constant indexing
- [ ] Coverage argument proven
- [ ] `witnessGraphBFMCS_forward_F` proven (0 sorries)
- [ ] 1 sorry remaining (backward_P)

---

### Phase 5C: Prove Backward_P via Witness Graph Bridge [NOT STARTED]

- **Dependencies**: Phase 5B
- **Goal**: Close backward_P sorry (symmetric to forward_F)
- **Estimated effort**: 10-15 hours

**Strategy:**

Backward_P is symmetric to forward_F:
- Uses `addPastWitness` instead of `addFutureWitness`
- Uses HContent instead of GContent
- Uses backward edges instead of forward edges

**Key Symmetric Lemmas:**

```lean
-- Backward edges carry HContent
lemma witnessGraph_backward_edge_HContent (g : WitnessGraph) (e : WitnessEdge)
    (he : e ∈ g.edges) (h_dir : e.direction = .backward) :
    HContent (g.mcsAt e.src).val ⊆ (g.mcsAt e.dst).val

-- Backward_P witness exists in graph
lemma witnessGraph_backward_P_witness (g : WitnessGraph) (rootMCS : ...)
    (n : Nat) (hn : n < g.nodes.length) (psi : Formula) :
    P(psi) ∈ (g.mcsAt n).val →
    ∃ m, m < n ∧ m < g.nodes.length ∧ psi ∈ (g.mcsAt m).val
```

**Implementation Steps:**

1. Prove `witnessGraph_backward_edge_HContent`
2. Prove `witnessGraph_backward_P_witness` using coverage argument
3. Assemble into `witnessGraphBFMCS_backward_P`

**Verification:**
- backward_P sorry eliminated
- `lake build` succeeds
- WitnessGraph.lean: 0 sorries, 0 errors

**Exit Criteria:**
- [ ] `witnessGraphBFMCS_backward_P` proven (0 sorries)
- [ ] WitnessGraph.lean: 0 sorries
- [ ] 0 errors in WitnessGraph.lean

---

### Phase 6: Integration with DovetailingChain [NOT STARTED]

- **Dependencies**: Phase 5C
- **Goal**: Replace sorries in DovetailingChain.lean
- **Estimated effort**: 5-10 hours

**Tasks:**

1. **Import WitnessGraph:**
   ```lean
   import Bimodal.Metalogic.Bundle.WitnessGraph
   ```
   Check for circular dependency issues.

2. **Define bridge function:**
   ```lean
   def buildDovetailingChainFamily_via_WitnessGraph (Gamma : Set Formula)
       (h_cons : SetConsistent Gamma) : BFMCS Int :=
     witnessGraphBFMCS (buildWitnessGraph (Lindenbaum Gamma h_cons))
   ```

3. **Wire forward_F:**
   Replace sorry at line 1754 with:
   ```lean
   exact witnessGraphBFMCS_forward_F ...
   ```

4. **Wire backward_P:**
   Replace sorry at line 1761 with:
   ```lean
   exact witnessGraphBFMCS_backward_P ...
   ```

5. **Verify integration:**
   - `lake build` succeeds
   - No new sorries in DovetailingChain.lean
   - Downstream theorems still compile

**Verification:**
```bash
lake build
# Full build must succeed with 0 new sorries
```

**Exit Criteria:**
- [ ] WitnessGraph imported into DovetailingChain.lean
- [ ] forward_F sorry replaced (line 1754)
- [ ] backward_P sorry replaced (line 1761)
- [ ] `lake build` succeeds
- [ ] No new axioms introduced

---

### Phase 7: Documentation and Summary [NOT STARTED]

- **Dependencies**: Phase 6
- **Goal**: Create implementation summary
- **Estimated effort**: 1-2 hours

**Tasks:**

1. Create `implementation-summary-{DATE}.md` documenting:
   - Total lines added/modified
   - Key lemmas proven
   - Architecture decisions
   - Build verification results

2. Verify no axioms via `lean_verify`:
   ```bash
   lean_verify Bimodal.Metalogic.Bundle.WitnessGraph
   ```

3. Update state.json with completion_summary

**Exit Criteria:**
- [ ] Implementation summary written
- [ ] No axioms verified
- [ ] Task marked complete

---

## Summary

| Phase | Description | Effort | Depends On |
|-------|-------------|--------|------------|
| 3B | Fix 5 build errors | 2-4h | None |
| 5A | Cross-sign sorries (forward_G, backward_H) | 8-12h | 3B |
| 5B | Forward_F via witness graph bridge | 15-25h | 5A |
| 5C | Backward_P (symmetric) | 10-15h | 5B |
| 6 | Integration with DovetailingChain | 5-10h | 5C |
| 7 | Documentation | 1-2h | 6 |

**Total Estimated Effort:** 41-68 hours

---

## Key Technical Insights (from 14 Research Reports)

### From research-003 (Team Consensus)
- `F(psi) -> G(F(psi))` is NOT derivable in TM logic (F-formulas don't self-persist)
- Approach D with omega² inner construction is the standard textbook technique
- Reuses 600+ lines of proven cross-sign G/H propagation

### From research-004 (Obstruction Analysis)
- Flat chain is mathematically insufficient for forward_F
- Each F-obligation needs its own Lindenbaum extension
- Coverage via enumeration surjectivity + immediate predecessor witnessing

### From research-010 (Deferred Concretization)
- Two-phase construction: Witness Graph -> Int Embedding
- Each witness is a fresh Lindenbaum extension (no persistence problem)
- GContent transitivity via 4-axiom: G(phi) -> G(G(phi))

### From research-014 (Synthesis)
- WitnessGraph is the ONLY viable path
- All chain-based approaches blocked by Lindenbaum opacity
- Mathematical result is standard textbook theorem (99% confidence)

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Coverage argument complexity | HIGH | HIGH | Use Encodable surjectivity + immediate predecessor |
| GContent transitivity through paths | MEDIUM | MEDIUM | 4-axiom already proven |
| Non-constant family introduces complexity | MEDIUM | HIGH | Follow existing DovetailingChain patterns |
| Integration causes circular imports | LOW | MEDIUM | Factor shared lemmas to common module |
| Context exhaustion during implementation | HIGH | MEDIUM | Handoff-based continuation (proven effective) |

---

## Literature References

- Burgess, J.P. (1982). "Axioms for tense logic." *Notre Dame Journal of Formal Logic*
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*
- Reynolds, M. (2003). "Completeness by construction for tense logics of linear time"
- Marx, M., Mikulas, S., Reynolds, M. (2000). "The Mosaic Method for Temporal Logics"

---

## Success Criteria

- [ ] WitnessGraph.lean: 0 sorries, 0 errors
- [ ] DovetailingChain.lean: forward_F and backward_P closed
- [ ] `lake build` succeeds with no new sorries
- [ ] No new axioms introduced
- [ ] Implementation summary created
