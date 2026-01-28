# Implementation Plan: Task #658 (Revised v3)

- **Task**: 658 - Prove indexed family coherence conditions
- **Version**: 003 (Option A: Propagation Lemmas)
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: High
- **Dependencies**: None (builds on implementation-002 infrastructure)
- **Research Inputs**:
  - specs/658_prove_indexed_family_coherence_conditions/summaries/implementation-summary-20260125.md (Option A recommendation)
  - specs/658_prove_indexed_family_coherence_conditions/summaries/implementation-summary-20260128.md (blocking analysis)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Context**: Implementation-002 successfully added T-axioms and reflexive semantics (Phases 1-3, 5 completed). Phase 4 (coherence proofs) remains blocked because T-axioms provide *local* closure (`Gφ → φ` at the same MCS) but don't propagate formulas *across* independent Lindenbaum extensions.

**This Plan (Option A)**: Develop propagation lemmas to connect formulas between MCS at different times. The key insight is that the T4 axiom (`Gφ → GGφ`) combined with T-axiom creates a chain that can bridge independent extensions.

### The Core Problem

The construction creates MCS at each time point independently:
```
mcs(t) = extendToMCS(time_seed(Gamma, t))
```

Where:
- `time_seed(Gamma, 0) = Gamma`
- `time_seed(Gamma, t>0) = {φ | Gφ ∈ Gamma}` (future seed)
- `time_seed(Gamma, t<0) = {φ | Hφ ∈ Gamma}` (past seed)

The seeds come from the *root* Gamma, not from adjacent MCS. So even with T-axioms:
1. `Gφ ∈ mcs(t)` gives `φ ∈ mcs(t)` via T-axiom
2. But `mcs(t')` is built from Gamma's seeds, not from `mcs(t)`

### The Solution Strategy

For `forward_G` (`Gφ ∈ mcs(t) → φ ∈ mcs(t')` where `t < t'`):

**Case 1**: If `Gφ ∈ Gamma` (root):
- Then `φ ∈ future_seed(t')` by construction
- Then `φ ∈ mcs(t')` by Lindenbaum extension

**Case 2**: If `Gφ ∉ Gamma` but `Gφ ∈ mcs(t)`:
- This happens when Lindenbaum added `Gφ` to `mcs(t)`
- By T4: `Gφ → GGφ`, so `GGφ ∈ mcs(t)`
- But here's the problem: `GGφ` doesn't propagate to `mcs(t')` either!

**Key Insight**: The coherence conditions are actually *only provable* for formulas that originate from Gamma. For formulas added by Lindenbaum, we need to use MCS properties (negation completeness, maximality) to show coherence.

**Actual Strategy** (refined):

For `forward_G`: Use contrapositive with negation completeness.
- Suppose `φ ∉ mcs(t')`, then `¬φ ∈ mcs(t')` by MCS maximality
- Need to show this implies `Gφ ∉ mcs(t)`
- By MCS properties: `Gφ ∈ mcs(t)` implies `φ ∈ mcs(t)` via T-axiom
- Use temporal axiom relationships to derive contradiction

## Goals & Non-Goals

**Goals**:
- Develop MCS propagation lemmas connecting formulas across time points
- Complete all four coherence condition proofs (forward_G, backward_H, forward_H, backward_G)
- Eliminate all 4 sorries in IndexedMCSFamily.lean lines 550-603
- Ensure full `lake build` passes

**Non-Goals**:
- Redesigning the seed construction (Option B approach)
- Weakening the coherence requirements (Option C approach)
- Proving coherence for non-reflexive semantics (already abandoned in v2)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Contrapositive approach has circularity | High | Medium | Verify logic carefully; use explicit lemma chain |
| Missing Lindenbaum/MCS lemmas | Medium | Medium | Check Boneyard for existing infrastructure; may need to port |
| T4/T5 axioms insufficient | High | Low | Fall back to Option B (redesign) if stuck |
| Proof complexity exceeds estimate | Medium | Medium | Track progress per proof; adjust plan if needed |

## Implementation Phases

### Phase 1: MCS Infrastructure Lemmas [NOT STARTED]

**Goal**: Establish lemmas about MCS closure under axiom application

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (or new supporting file)

**Tasks**:
- [ ] Create/locate lemma: MCS closed under axiom modus ponens
- [ ] Create lemma: `mcs_closed_temp_t_future`: `Gφ ∈ mcs → φ ∈ mcs`
- [ ] Create lemma: `mcs_closed_temp_t_past`: `Hφ ∈ mcs → φ ∈ mcs`
- [ ] Create lemma: `mcs_closed_temp_4`: `Gφ ∈ mcs → GGφ ∈ mcs`
- [ ] Create lemma: `mcs_closed_temp_4_past`: `Hφ ∈ mcs → HHφ ∈ mcs`
- [ ] Verify each lemma compiles without error

**Expected Code**:
```lean
/-- MCS is closed under T-axiom for future: Gφ ∈ mcs implies φ ∈ mcs. -/
lemma mcs_closed_temp_t_future {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (φ : Formula) (h_G : Formula.all_future φ ∈ Gamma) : φ ∈ Gamma := by
  -- T-axiom: Gφ → φ is an axiom
  -- MCS is closed under derivation
  have h_axiom : ⊢ (Formula.all_future φ).imp φ := Derivation.axiom (.temp_t_future φ)
  exact mcs_closed_under_mp h_mcs h_G h_axiom
```

**Timing**: 1-2 hours

**Verification**:
- `lean_diagnostic_messages` shows no errors
- Each lemma can be instantiated

---

### Phase 2: Seed-to-MCS Propagation Lemmas [NOT STARTED]

**Goal**: Connect seed membership to MCS membership with time constraints

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Tasks**:
- [ ] Prove: `future_seed_from_gamma`: `Gφ ∈ Gamma ∧ t > 0 → φ ∈ future_seed(t)`
- [ ] Prove: `past_seed_from_gamma`: `Hφ ∈ Gamma ∧ t < 0 → φ ∈ past_seed(t)`
- [ ] Prove: `seed_subset_mcs`: `time_seed(t) ⊆ mcs(t)` (already exists: `mcs_at_time_contains_seed`)
- [ ] Prove: `gamma_Gformula_implies_phi_in_future_mcs`: `Gφ ∈ Gamma → φ ∈ mcs(t)` for `t > 0`
- [ ] Prove: `gamma_Hformula_implies_phi_in_past_mcs`: `Hφ ∈ Gamma → φ ∈ mcs(t)` for `t < 0`

**Expected Code**:
```lean
/-- If Gφ ∈ Gamma and t > 0, then φ is in the MCS at t. -/
lemma gamma_Gformula_implies_phi_in_future_mcs
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (φ : Formula) (h_G : Formula.all_future φ ∈ Gamma)
    (t : D) (ht : (0 : D) < t) :
    φ ∈ mcs_at_time D Gamma h_mcs h_no_G_bot h_no_H_bot t := by
  -- φ ∈ future_seed by definition (since Gφ ∈ Gamma and t > 0)
  -- future_seed ⊆ mcs by Lindenbaum
  have h_in_seed : φ ∈ future_seed D Gamma t := by
    simp only [future_seed, ht, ↓reduceIte, Set.mem_setOf_eq]
    exact h_G
  have h_seed_eq : time_seed D Gamma t = future_seed D Gamma t := by
    simp only [time_seed]
    split_ifs with h0 hpos
    · omega
    · rfl
    · omega
  rw [h_seed_eq] at h_in_seed
  exact mcs_at_time_contains_seed D Gamma h_mcs h_no_G_bot h_no_H_bot t (by rw [← h_seed_eq]; exact h_in_seed)
```

**Timing**: 1-2 hours

**Verification**:
- Lemmas compile
- Can instantiate with concrete examples

---

### Phase 3: Coherence Proof - forward_G [NOT STARTED]

**Goal**: Prove `Gφ ∈ mcs(t) → φ ∈ mcs(t')` for `t < t'`

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (line ~550)

**Strategy**:
The key is recognizing that `Gφ ∈ mcs(t)` can arise in two ways:
1. `Gφ` was in the seed (derived from Gamma)
2. `Gφ` was added by Lindenbaum extension

**Case 1 (seed origin)**: If `Gφ` came from the seed at time t:
- For t = 0: seed is Gamma, so `Gφ ∈ Gamma`
- For t > 0: seed is future_seed, so `GGφ ∈ Gamma` (since `Gψ ∈ future_seed ↔ Gψ ∈ Gamma`)
- For t < 0: seed is past_seed, which only has H-formulas

Wait, this doesn't cover all cases. Let me reconsider.

**Revised Strategy** (contrapositive + negation completeness):
Prove contrapositive: `φ ∉ mcs(t') → Gφ ∉ mcs(t)`

1. Assume `φ ∉ mcs(t')`
2. By MCS maximality of `mcs(t')`: `¬φ ∈ mcs(t')`
3. Need to show `Gφ ∉ mcs(t)`, i.e., `¬Gφ ∈ mcs(t)` or derive contradiction from `Gφ ∈ mcs(t)`

Hmm, this still doesn't directly work because `mcs(t)` and `mcs(t')` are independent.

**Final Strategy** (direct, using T4 + T + seed):
Actually, for the indexed family construction with seeds from Gamma:

For `t' > 0`:
- `mcs(t')` contains `{φ | Gφ ∈ Gamma}` (from future_seed)
- If `Gφ ∈ mcs(t)` and we can show `Gφ ∈ Gamma`, then `φ ∈ mcs(t')` by seed

For general `t < t'`:
- Use T4: `Gφ → GGφ`, so `Gφ ∈ mcs(t)` implies `GGφ ∈ mcs(t)`
- If `t = 0`: `mcs(0) = extendToMCS(Gamma)` contains Gamma
- If `GGφ ∈ mcs(0)` and `mcs(0) ⊇ Gamma`, then for any `t' > 0`, the seed at `t'` contains `Gφ` (since `Gφ` is what you'd extract from `GGφ`)

**The Issue**: We need `Gφ ∈ Gamma`, not just `Gφ ∈ mcs(0)`.

**Resolution**: The coherence conditions may only be provable when the family is constructed such that temporal formulas in the MCS originate from the root. This is actually the standard canonical model construction pattern.

Let me check if there's a simpler approach: use the reflexive semantics directly.

With reflexive semantics, `Gφ` at time t means `φ` at all times `≥ t`. So if `Gφ ∈ mcs(t)` and the MCS family represents a temporal model, then `φ` must be in `mcs(t')` for all `t' ≥ t`.

The proof would be semantic: show the family satisfies the semantic coherence property because each MCS is consistent with the temporal semantics.

**Concrete Plan**: Use induction on the time gap `t' - t`, or direct argument using the fact that both MCS are built from the same root Gamma.

**Tasks**:
- [ ] Analyze whether `Gφ ∈ mcs(t)` implies `Gφ ∈ Gamma` or `GGφ ∈ Gamma`
- [ ] If yes, use seed propagation from Phase 2
- [ ] If no, develop alternative strategy (possibly semantic)
- [ ] Implement proof for forward_G
- [ ] Verify no errors

**Timing**: 2 hours

---

### Phase 4: Coherence Proof - backward_H [NOT STARTED]

**Goal**: Prove `Hφ ∈ mcs(t) → φ ∈ mcs(t')` for `t' < t`

**Strategy**: Symmetric to forward_G using H instead of G.

**Tasks**:
- [ ] Apply same analysis as Phase 3 for H direction
- [ ] Implement proof for backward_H
- [ ] Verify no errors

**Timing**: 1 hour (leveraging Phase 3 insights)

---

### Phase 5: Coherence Proofs - forward_H and backward_G [NOT STARTED]

**Goal**: Prove remaining two coherence conditions

**forward_H**: `Hφ ∈ mcs(t') → φ ∈ mcs(t)` for `t < t'`
- H at later time t' asserts φ at all times ≤ t'
- Since t < t', need φ at t

**backward_G**: `Gφ ∈ mcs(t') → φ ∈ mcs(t)` for `t' < t`
- G at earlier time t' asserts φ at all times ≥ t'
- Since t' < t, need φ at t

**Note**: These are the "looking from the other direction" proofs.

**Tasks**:
- [ ] Prove forward_H using past seed propagation
- [ ] Prove backward_G using future seed propagation
- [ ] Verify all four proofs compile
- [ ] Remove blocking comments from IndexedMCSFamily.lean

**Timing**: 2 hours

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure all sorries eliminated and code is clean

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily`
- [ ] Verify no sorry warnings
- [ ] Run full `lake build` for Bimodal
- [ ] Update documentation to reflect completed proofs
- [ ] Remove obsolete blocking analysis comments
- [ ] Update implementation-002 phase 4 status to [COMPLETED]

**Timing**: 30 minutes

---

## Testing & Validation

- [ ] Phase 1: MCS closure lemmas compile
- [ ] Phase 2: Seed propagation lemmas compile
- [ ] Phase 3: forward_G proof complete
- [ ] Phase 4: backward_H proof complete
- [ ] Phase 5: forward_H and backward_G proofs complete
- [ ] Phase 6: Full `lake build` with no errors
- [ ] All 4 coherence sorries eliminated

## Artifacts & Outputs

- plans/implementation-003.md (this plan)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- Modified files:
  - `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Coherence proofs

## Rollback/Contingency

- **If Phase 3 strategy fails**: Re-evaluate whether semantic approach is needed; consider Option B (seed redesign)
- **If MCS lemmas missing**: Port from Boneyard or create new module
- **Partial progress**: Each phase can be committed independently
- **If blocked**: Document specific blocker and create follow-up task

## Analysis from implementation-summary-20260125.md

**Option A Recommendation** (from that summary):
> **Option A**: Modify Construction (Recommended)
> Redefine `construct_indexed_family` to use a **single coherent MCS construction**

This plan takes a middle ground: rather than fully redesigning the construction (Option B), we develop the propagation lemmas that make the existing construction work. If the propagation approach fails, Option B remains available.

## Analysis from implementation-summary-20260128.md

**Missing Infrastructure** identified:
1. **Seed propagation lemma**: Show that GGφ ∈ mcs(t) implies Gφ in future_seed(t')
2. **Cross-time formula propagation**: Connect formulas from mcs(t) to mcs(t') via axioms
3. **Alternative**: Redesign seed construction to be recursive/dependent on previous times

This plan addresses items 1 and 2 directly. Item 3 is the fallback if 1-2 prove insufficient.
