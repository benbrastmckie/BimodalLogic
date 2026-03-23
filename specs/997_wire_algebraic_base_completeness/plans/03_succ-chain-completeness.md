# Implementation Plan: Task #997 - Succ-Chain Base Completeness (v3)

- **Task**: 997 - Wire algebraic base completeness via Succ-chain bypass
- **Version**: 3 (replaces v2 BFMCS approach)
- **Status**: [COMPLETED]
- **Effort**: 8 hours
- **Dependencies**: Task 34 (SuccExistence seed consistency - in progress, non-blocking)
- **Research Inputs**:
  - specs/997_wire_algebraic_base_completeness/reports/05_team-research.md (Option B consensus)
  - specs/997_wire_algebraic_base_completeness/reports/04_mid-implementation-review.md
  - specs/997_wire_algebraic_base_completeness/reports/05_teammate-a-findings.md
  - specs/997_wire_algebraic_base_completeness/reports/05_teammate-b-findings.md
- **Artifacts**: plans/03_succ-chain-completeness.md (this file)
- **Type**: lean4

## Pivot Rationale

**Previous approach (v2)**: Bridge FlagBFMCS `satisfies_at` to canonical `valid` via Int-embedding.
**Problem identified**: BFMCS inherits 5 architecturally unprovable sorries:
- Cross-family modal coherence (`modal_forward`, `modal_backward`) requires S5 transfer that TM lacks
- W=D conflation makes these sorries fundamentally unprovable, not just unproven

**New approach (v3)**: Bypass BFMCS entirely using Succ-chain infrastructure:
- `CanonicalTaskTaskFrame` (sorry-free) provides TaskFrame Int directly
- `succ_chain_history` (sorry-free) provides WorldHistory
- Focus on CanonicalTask (three-place task relation), not CanonicalR (existential shadow)

## Overview

The Succ-chain approach constructs completeness via:
1. Given consistent `{¬φ}`, extend to MCS `M₀`
2. Build bi-infinite Succ-chain from `M₀` using deferral seeds
3. The chain directly instantiates TaskFrame Int via CanonicalTask
4. WorldHistory is automatic from chain structure
5. Truth Lemma: `ψ ∈ chain(t) ↔ truth_at model Ω history t ψ`
6. Since `¬φ ∈ M₀`, we have `truth_at ... 0 (¬φ)`, so `φ` is not valid
7. Contrapositive: valid `φ` → provable `φ`

## Goals & Non-Goals

**Goals**:
- Prove base completeness using Succ-chain infrastructure
- Leverage sorry-free `CanonicalTaskTaskFrame` and `succ_chain_history`
- Create `SuccChainCompleteness.lean` with clean proof structure
- Establish completeness for reflexive temporal semantics (Task 29)

**Non-Goals**:
- Modifying existing BFMCS files (deprecated but preserved)
- Eliminating all Succ-existence axioms (Task 34 handles this)
- Proving P-direction theorems (not on critical path for forward completeness)
- Dense/discrete completeness variations (separate tasks)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth Lemma needs P-direction | M | M | Forward direction sufficient for completeness; P only for full bidirectionality |
| SuccExistence axioms unprovable | M | L | Semantically justified; Task 34 making progress |
| Nesting boundary axioms complex | L | M | Well-founded induction on formula depth; structure is clear |
| Integration with existing code | L | L | New file, minimal coupling to existing completeness |

## Implementation Phases

### Phase 1: Verify Succ-Chain Infrastructure [COMPLETED]

**Goal**: Confirm all required infrastructure compiles and understand the API

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Bundle.SuccChainTaskFrame` — verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.Bundle.SuccChainWorldHistory` — verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` — note axiom status
- [ ] Document exact sorry/axiom inventory for completeness path
- [ ] Read `CanonicalTaskTaskFrame` API: nullity, forward_comp, converse
- [ ] Read `succ_chain_history` API: domain, states, respects_task

**Timing**: 2 hours

**Files to read**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- All imports resolve
- Sorry-free status confirmed for TaskFrame + WorldHistory
- API understood for next phase

---

### Phase 2: Create Succ-Chain Truth Lemma [COMPLETED]

**Goal**: Prove the truth lemma connecting chain membership to semantic truth

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean`
- [ ] Define `succ_chain_model : TaskModel CanonicalTaskTaskFrame` using succ_chain_fam
- [ ] Define `succ_chain_omega : Set (WorldHistory CanonicalTaskTaskFrame)` — the set containing our history
- [ ] Prove `succ_chain_truth_forward`:
  ```lean
  theorem succ_chain_truth_forward (M0 : SerialMCS) (phi : Formula) (t : Int) :
      phi ∈ succ_chain_fam M0 t →
      truth_at succ_chain_model succ_chain_omega (succ_chain_history M0) t phi
  ```
  - Atom case: By valuation definition
  - Bot case: Vacuous (⊥ never in MCS)
  - Imp case: By MCS negation completeness + IH
  - Box case: By `succ_chain_omega` containing only our history
  - G case: By G-persistence across Succ + IH
  - F case: By `bounded_witness` theorem — F^n(ψ) in chain(t) means ψ in chain(t+k) for some k ≤ n
- [ ] (Optional) Prove backward direction if needed

**Key insight**: The F case uses `bounded_witness`:
```lean
theorem bounded_witness (u v : Set Formula) (phi : Formula) (n : Nat)
    (h_Fn : iter_F n phi ∈ u) (h_Fn1_not : iter_F (n + 1) phi ∉ u)
    (h_task : CanonicalTask_forward_MCS u n v) : phi ∈ v
```

**Timing**: 4 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` (new file)

**Verification**:
- `succ_chain_truth_forward` compiles with no new sorries
- Sorries only in called infrastructure (SuccExistence axioms)

---

### Phase 3: Wire Completeness Theorem [COMPLETED]

**Goal**: Prove `valid phi → Nonempty (DerivationTree [] phi)` via contrapositive

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`
- [ ] Import SuccChainTruth, Derivation, Lindenbaum
- [ ] Prove `succ_chain_completeness`:
  ```lean
  theorem succ_chain_completeness (phi : Formula) :
      valid phi → Nonempty (DerivationTree [] phi) := by
    -- Contrapositive: ¬provable phi → ¬valid phi
    -- 1. Assume phi not provable, then {¬phi} consistent
    -- 2. Extend {¬phi} to MCS M0 via Lindenbaum
    -- 3. M0 is serial (reflexive semantics makes seriality trivial)
    -- 4. Build succ_chain_fam from M0
    -- 5. By truth lemma: ¬phi true at M0 in canonical model
    -- 6. Therefore phi is false at some point, so not valid
    -- 7. Contrapositive gives result
  ```
- [ ] Add docstring explaining relationship to BFMCS approach (deprecated)

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` (new file)

**Verification**:
- `succ_chain_completeness` compiles
- Only inherits sorries from SuccExistence axioms (semantically justified)

---

### Phase 4: Documentation and Cleanup [COMPLETED]

**Goal**: Document the approach, deprecate BFMCS path, update completeness module

**Tasks**:
- [ ] Add deprecation comments to `DirectMultiFamilyBFMCS.lean`
- [ ] Add deprecation comments to `IntFMCSTransfer.lean`
- [ ] Document sorry status in SuccChainCompleteness.lean header
- [ ] Run `lake build` to verify full project compiles
- [ ] Create summary artifact

**Timing**: 1 hour (stretched for review)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` (deprecation comment)
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean` (deprecation comment)
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` (documentation)

**Verification**:
- `lake build` succeeds
- Sorry inventory documented

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccChainTruth` compiles
- [ ] `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness` compiles
- [ ] `lake build` full project succeeds
- [ ] `succ_chain_completeness` theorem present and typechecks
- [ ] Only SuccExistence axioms in transitive sorry closure

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` (new file)
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` (new file)
- `specs/997_wire_algebraic_base_completeness/summaries/03_succ-chain-summary.md` (on completion)

## Relationship to Other Tasks

| Task | Relationship |
|------|-------------|
| Task 34 | Proves SuccExistence seed consistency axioms — reduces our axiom count |
| Task 29 | Established reflexive semantics — our completeness builds on this |
| Task 995 | FMCS domain transfer — NOT needed for Succ-chain approach |
| Task 1004 | IntBFMCS dovetailing — NOT needed for Succ-chain approach |

## Rollback/Contingency

If the Succ-chain approach encounters unexpected blockers:

1. **Fallback A**: Accept remaining axioms as semantically justified
   - Document that completeness holds modulo 3-6 axioms
   - All axioms have clear semantic justifications

2. **Fallback B**: Partial completeness
   - Prove F-forward completeness only (no P-backward)
   - Sufficient for most use cases

3. **Preserve progress**: Git commit at end of each phase

## Technical Notes

### Why CanonicalTask, Not CanonicalR

CanonicalR (`g_content M ⊆ N`) is the existential shadow — it says "N accessible from M" but loses duration information. CanonicalTask is three-place (`task_rel w d u`), counting Succ steps, which:
- Directly instantiates TaskFrame Int
- Provides `bounded_witness` for F-witness semantics
- Aligns with Task Semantics (not just Kripke semantics)

### Reflexive Semantics Benefits

Task 29 established `G phi` and `H phi` use `≤` (reflexive):
- T-axioms are semantically valid
- Seriality is trivial (every world sees itself)
- No irreflexivity complications

### Axiom Inventory (Final State)

After Phase 3, completeness depends on:
1. `successor_deferral_seed_consistent_axiom` — Task 34 targeting
2. `predecessor_deferral_seed_consistent_axiom` — Task 34 targeting
3. `predecessor_f_step_axiom` — Task 34 targeting
4. `succ_chain_fam_p_step` — provable via induction
5. `f_nesting_boundary` — provable via formula structure
6. `p_nesting_boundary` — provable via formula structure

All are semantically justified by frame conditions (NoMaxOrder, NoMinOrder, reflexive G/H).
