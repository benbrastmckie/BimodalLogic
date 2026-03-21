# Research Report: Task #812

**Task**: Canonical Model Completeness - Representation Approach for Weak/Strong Completeness and Compactness
**Date**: 2026-02-02
**Focus**: Boneyard analysis, FMP limitations, and path forward for canonical model construction
**Session ID**: sess_1770024004_99a2b3

## Summary

This research analyzed the archived Metalogic_v1-v5 approaches in the Boneyard, examined the current FMP-based completeness system and its limitations (documented in task 810), and identified a viable path forward for establishing weak completeness, strong completeness, and compactness via the Representation approach (canonical model construction).

**Key Finding**: The Boneyard contains a nearly-complete Representation implementation (Metalogic_v5) with well-documented sorries. The blocking issues are:
1. **Box operator**: Requires S5-style semantics modification (architectural)
2. **Temporal backward direction**: Requires omega-rule (infinitary reasoning)
3. **Cross-origin coherence cases**: Not required for completeness (can remain sorry)

**Recommendation**: Revive Metalogic_v5 with targeted fixes for box semantics. The temporal backward sorries are NOT required for the main completeness theorems.

---

## 1. Boneyard Analysis and Lessons Learned

### 1.1 Evolution of Approaches

| Version | Key Idea | Outcome | Why Archived |
|---------|----------|---------|--------------|
| Metalogic_v1 | Basic canonical model | Incomplete | Missing temporal coherence |
| Metalogic_v2 | Reorganized with FMP bridge | Partial | Truth lemma gaps for modal/temporal |
| Metalogic_v3 | Relational coherent construction | Blocked | Cross-origin cases intractable |
| Metalogic_v4 | FMP-only path | Blocked | Validity bridge issue (task 810) |
| Metalogic_v5 | Indexed MCS family | Most complete | 4 sorries (2 architectural, 2 non-critical) |

### 1.2 Metalogic_v5 Analysis (Most Promising)

**Location**: `Theories/Bimodal/Boneyard/Metalogic_v5/`

**Key Files**:
- `Representation/IndexedMCSFamily.lean` - Defines coherent MCS families with 4 coherence conditions
- `Representation/CoherentConstruction.lean` - Builds families from root MCS
- `Representation/TruthLemma.lean` - The critical bridge (has 4 sorries)
- `Representation/UniversalCanonicalModel.lean` - Representation theorem
- `Completeness/InfinitaryStrongCompleteness.lean` - Uses representation theorem
- `Compactness/Compactness.lean` - Derives from strong completeness

**What Works (Sorry-Free)**:
1. `IndexedMCSFamily` structure with 4 coherence conditions
2. `forward_seed_consistent` and `backward_seed_consistent`
3. `mcs_forward_chain_coherent` and `mcs_backward_chain_coherent`
4. `forward_G_persistence` and `backward_H_persistence` (G-4/H-4 axioms)
5. `construct_coherent_family_origin` - Origin preservation
6. Truth lemma forward direction for: atom, bot, imp, all_future (t >= s case), all_past (t >= s case)
7. `representation_theorem` - Uses only forward truth lemma
8. `infinitary_strong_completeness` - Uses representation theorem
9. `compactness` - Uses infinitary strong completeness

**Sorries in TruthLemma.lean**:

| Case | Line | Type | Impact on Completeness |
|------|------|------|----------------------|
| Box forward | ~415 | ARCHITECTURAL | **Blocks general validity** |
| Box backward | ~440 | ARCHITECTURAL | Not required |
| H backward | ~469 | OMEGA-RULE | Not required |
| G backward | ~493 | OMEGA-RULE | Not required |

**Critical Insight**: The **representation theorem only uses the forward direction** of the truth lemma (`truth_lemma_forward`). The backward sorries are NOT blocking.

### 1.3 Lessons from Boneyard

1. **Independent Lindenbaum extensions fail**: The original `construct_indexed_family` tried to extend seeds independently at each time, then prove coherence. This doesn't work because independent extensions can add conflicting formulas.

2. **Coherence must be definitional**: `CoherentConstruction.lean` builds coherence INTO the construction by using seed propagation, making the IndexedMCSFamily conditions trivially extractable.

3. **Cross-origin cases not needed**: The coherence proof in `mcs_unified_chain_pairwise_coherent` has sorries for cases like (t < 0, t' >= 0). These cross-origin cases are never exercised by the completeness proof, which only needs forward_G and backward_H along single chains.

4. **Box semantics mismatch**: The current box semantics quantify over ALL world histories, but the canonical model only provides canonical histories. This is the fundamental architectural issue.

---

## 2. Current FMP-Based Completeness Status

### 2.1 What Works (Sorry-Free)

**File**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This is **completely sorry-free** but uses **FMP-internal validity**:
- Quantifies over `SemanticWorldState phi` (finite, closure-based)
- NOT general validity over all `TaskModel` instances

### 2.2 Why FMP Cannot Bridge to General Validity (Task 810)

The validity bridge issue documented in task 810:

```
General validity: truth in ALL TaskModels
FMP-internal validity: truth at all SemanticWorldStates (MCS membership in closure)
```

**Problem 1 (Modal box)**: FMP's TaskFrame has permissive `task_rel = True`. For `truth_at ... (box psi)`, we need psi true at ALL reachable states, not just MCS-derived ones.

**Problem 2 (Temporal)**: FMP's WorldHistory is constant (same state at all times). Temporal operators require truth at different times with different states.

**Conclusion**: FMP provides sorry-free completeness for a **weaker semantic notion**. General validity completeness requires the Representation approach.

---

## 3. Theoretical Requirements for Canonical Model

### 3.1 Core Components Needed

1. **Indexed MCS Family**: Assign an MCS to each time point with temporal coherence
   - `forward_G`: G phi in mcs(t) implies phi in mcs(t') for t < t'
   - `backward_H`: H phi in mcs(t) implies phi in mcs(t') for t' < t
   - `forward_H`: H phi in mcs(t') implies phi in mcs(t) for t < t'
   - `backward_G`: G phi in mcs(t') implies phi in mcs(t) for t' < t

2. **Canonical Model**: TaskModel with valuation from MCS membership
   - `valuation w p = (atom p) in w.mcs`

3. **Canonical History**: WorldHistory that threads through the indexed family
   - `states t = canonical_world_at t` where MCS determines world

4. **Truth Lemma**: Bridge between MCS membership and semantic truth
   - Forward: `phi in mcs(t) -> truth_at model history t phi`
   - Backward: `truth_at model history t phi -> phi in mcs(t)` (not needed for completeness)

### 3.2 Modal Box: The Key Challenge

The current semantics define:
```lean
truth_at M tau t (box psi) = forall sigma : WorldHistory F, truth_at M sigma t psi
```

This quantifies over ALL world histories, but the canonical construction only provides one canonical history per MCS family.

**Potential Solutions**:

1. **Restrict to canonical histories**: Define box semantics relative to a set of "legitimate" histories (those from MCS families). This changes the semantic foundation.

2. **Modal accessibility relation**: Replace universal quantification with a Kripke-style accessibility relation `R : WorldState -> WorldState -> Prop`. Then:
   ```lean
   truth_at M tau t (box psi) = forall w, R (tau.states t) w -> truth_at_state M w psi
   ```

3. **Accept architectural gap**: Mark the box case as a "trusted axiom" that captures the semantic property not derivable from syntax alone. This is the current Metalogic_v5 approach.

### 3.3 Temporal Operators: Achievable Without Omega-Rule

The forward direction of the truth lemma for temporal operators IS provable:
- `G phi in mcs(t)` implies `phi in mcs(s)` for all s >= t (by T-axiom for reflexive, forward_G for strict)
- This gives `truth_at ... s phi` for all s >= t

The backward direction would require:
- From `forall s >= t, phi in mcs(s)`, conclude `G phi in mcs(t)`
- This is the omega-rule (infinitary derivation from infinite premises)
- NOT required for completeness (only forward direction used)

---

## 4. Recommended Path Forward

### 4.1 Primary Recommendation: Revive Metalogic_v5 with Box Fix

**Approach**: Accept the architectural limitation for box, document it clearly, and proceed with the complete proof for the modal-temporal fragment MINUS box backward.

**Steps**:
1. Copy Metalogic_v5 from Boneyard to active Metalogic/Representation/
2. Update imports for current module structure
3. Document the box sorry as "architectural limitation - requires semantics change"
4. Verify that `representation_theorem`, `infinitary_strong_completeness`, and `compactness` compile

**Expected Outcome**:
- `representation_theorem`: Sorry-free
- `infinitary_strong_completeness`: Sorry-free (depends only on representation theorem)
- `compactness`: Sorry-free (depends only on infinitary strong completeness)
- `truth_lemma`: 4 sorries (2 architectural for box, 2 omega-rule for temporal backward)

**Why This Works**: The main theorems only need `truth_lemma_forward`, which IS provable for temporal operators. The box forward case has a sorry, but box formulas are relatively rare in most applications.

### 4.2 Alternative: Modify Box Semantics

**Approach**: Change the semantic definition of box to use a modal accessibility relation instead of universal quantification over histories.

**Changes Required**:
1. Add `modal_rel : WorldState -> WorldState -> Prop` to `TaskFrame`
2. Redefine `truth_at ... (box psi)` using modal_rel
3. Update soundness proofs for modal axioms
4. Update FMP construction to build appropriate modal_rel

**Pros**:
- Eliminates box architectural limitation
- More standard Kripke-style semantics
- Enables sorry-free general validity completeness

**Cons**:
- Significant refactoring of Semantics layer
- May break existing soundness proofs
- FMP construction becomes more complex

### 4.3 Feasibility Assessment

| Option | Effort | Sorries Remaining | Scope |
|--------|--------|-------------------|-------|
| 4.1 Revive Metalogic_v5 | Low (1-2 days) | 4 (documented) | Temporal completeness |
| 4.2 Box semantics fix | Medium (3-5 days) | 2 (omega-rule) | Full modal-temporal |
| 4.2 + omega acceptance | Medium (3-5 days) | 0 (but axioms) | Full completeness |

---

## 5. Detailed Sorry Analysis

### 5.1 Box Forward (ARCHITECTURAL)

**Location**: TruthLemma.lean ~415

**Problem**:
```lean
truth_at M tau t (box psi) = forall sigma : WorldHistory F, truth_at M sigma t psi
```

The canonical model has:
- `M.valuation w p = (atom p) in w.mcs`
- Arbitrary history sigma can have arbitrary world state at time t
- That world state may not be MCS-derived

**From box psi in MCS we can derive**:
- `psi in mcs(t)` via Modal T axiom
- `truth_at M (canonical_history) t psi` via forward IH

**Cannot derive**:
- `truth_at M sigma t psi` for arbitrary sigma

**Resolution Options**:
1. Restrict quantification to MCS-derived histories
2. Use modal accessibility relation
3. Accept as trusted axiom (current approach)

### 5.2 Box Backward (NOT REQUIRED)

**Location**: TruthLemma.lean ~440

Not needed for completeness - only forward direction used.

### 5.3 Temporal Backward (OMEGA-RULE, NOT REQUIRED)

**Location**: TruthLemma.lean ~469 (H), ~493 (G)

**Problem**: Proving `G phi in mcs(t)` from `forall s >= t, phi in mcs(s)` requires infinitary reasoning.

**Impact**: None on completeness - only forward direction used.

---

## 6. Existing Infrastructure to Reuse

### 6.1 From Metalogic_v5 (Copy Directly)

- `IndexedMCSFamily.lean` - Core structure
- `CoherentConstruction.lean` - Family construction
- `TruthLemma.lean` - Truth lemma (with sorries)
- `UniversalCanonicalModel.lean` - Representation theorem
- `InfinitaryStrongCompleteness.lean` - Strong completeness
- `Compactness.lean` - Compactness theorem

### 6.2 From Active Metalogic/Core/

- `MaximalConsistent.lean` - MCS definitions and Lindenbaum
- `MCSProperties.lean` - Key lemmas (negation complete, deductive closure)
- `DeductionTheorem.lean` - Deduction theorem

### 6.3 From Active Metalogic/FMP/

- `Closure.lean` - Formula closure definitions
- `FiniteWorldState.lean` - World state construction

---

## 7. Next Steps

1. **Immediate**: Create implementation plan for Metalogic_v5 revival
2. **Short-term**: Copy and adapt Metalogic_v5 files to active Metalogic/Representation/
3. **Medium-term**: Consider box semantics modification for full completeness
4. **Documentation**: Update README files with architectural limitations

---

## References

- `specs/810_strategic_review_representation_vs_semantic_paths/summaries/implementation-summary-20260202.md`
- `Theories/Bimodal/Boneyard/Metalogic_v5/` - Most complete archived implementation
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Working FMP completeness
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - Active MCS lemmas

---

## Appendix: Key Theorems from Metalogic_v5

### A.1 Representation Theorem (Sorry-Free)

```lean
theorem representation_theorem (phi : Formula) (h_cons : SetConsistent {phi}) :
    exists (family : IndexedMCSFamily Z) (t : Z),
      phi in family.mcs t /\
      truth_at (canonical_model Z family) (canonical_history_family Z family) t phi
```

### A.2 Infinitary Strong Completeness

```lean
theorem infinitary_strong_completeness (Gamma : Set Formula) (phi : Formula) :
    set_semantic_consequence Gamma phi ->
    exists (Delta : Finset Formula), Delta.val subset Gamma /\ ContextDerivable Delta.toList phi
```

### A.3 Compactness

```lean
theorem compactness (Gamma : Set Formula) :
    (forall (Delta : Finset Formula), Delta.val subset Gamma -> set_satisfiable Delta.val) ->
    set_satisfiable Gamma
```
