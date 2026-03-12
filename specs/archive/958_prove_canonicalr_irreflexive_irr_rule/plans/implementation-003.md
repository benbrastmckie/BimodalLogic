# Implementation Plan: Task #958 - Substitution-Based Conservative Extension

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Dependencies**: None (builds on existing Phases 1-2 infrastructure)
- **Research Inputs**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-006.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove that CanonicalR is irreflexive using the substitution-based conservative extension approach from research-006.md. The key insight is the substitution lemma `sigma[q -> bot]`: F+ derivations of q-free conclusions can be projected back to F derivations. This enables working in F+ where the naming set covers ALL of `embed '' M` (due to q-freshness), then transferring results back to F.

### Research Integration

Key findings from research-006.md (Approach 1 - Substitution-Based Conservative Extension):

1. **Phases 1-2 are COMPLETE**: `ExtFormula.lean` (~300 lines) and `ExtDerivation.lean` (~182 lines) are sorry-free
2. **The substitution lemma is the missing piece**: `sigma[q -> bot]` maps F+ derivations to F derivations
3. **IRR case handling**: When `p = q`, the antecedent `(q AND H(neg q))` maps to `(bot AND H(neg bot))` which is contradictory, so the implication is derivable by ex falso
4. **The naming set argument works in F+**: `atomFreeSubset_Ext(embed '' M, q) = embed '' M` because all embedded formulas are q-free

## Goals & Non-Goals

**Goals**:
- Create `Substitution.lean` with `substFormula : ExtFormula -> ExtFormula` (sigma[q -> bot])
- Prove `substFormula_preserves_qfree`: q-free formulas unchanged under substitution
- Prove axiom schemas closed under substitution
- Create `Lifting.lean` with the lifting theorem for q-free derivations
- Complete `Irreflexivity.lean` removing 2 sorries from `CanonicalIrreflexivity.lean`
- Zero sorries in final implementation

**Non-Goals**:
- Do not modify existing Formula, Axiom, or DerivationTree types
- Do not add new axioms to the base proof system
- Do not duplicate full MCS machinery in F+ (use substitution lifting instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Substitution lemma complexity for axioms | MEDIUM | MEDIUM | Handle each axiom case systematically; schemas are closed under substitution |
| IRR case ex falso derivation | MEDIUM | LOW | `(bot AND H(neg bot)) -> phi` is derivable; construct explicit derivation |
| Lifting theorem induction complexity | MEDIUM | MEDIUM | Follow derivation tree structure; each rule case maps cleanly |
| Final contradiction step | HIGH | MEDIUM | Use substitution lifting to transfer F+ inconsistency back to F; if stuck, mark [BLOCKED] |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalIrreflexivity.lean` at lines 1245 and 1328
- These sorries stem from global freshness impossibility in base language

### Expected Resolution
- Phase 4 proves the irreflexivity theorem via conservative extension
- The two existing sorries become obsolete once `canonicalR_irreflexive` is proved
- `CanonicalIrreflexivity.lean` updated to use new theorem

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in new `ConservativeExtension/` files
- Existing `CanonicalIrreflexivity.lean` sorries removed
- Downstream theorems (Task 956 Phase 6) unblocked

## Implementation Phases

### Phase 1: Substitution Infrastructure [COMPLETED]

- **Dependencies:** None (uses existing ExtFormula.lean, ExtDerivation.lean)
- **Goal:** Define substitution `sigma[q -> bot]` and prove preservation properties

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean`
- [ ] Define `substFormula : ExtFormula -> ExtFormula` (replaces `atom (Sum.inr ())` with `bot`)
- [ ] Prove `substFormula_bot : substFormula ExtFormula.bot = ExtFormula.bot`
- [ ] Prove `substFormula_imp : substFormula (phi.imp psi) = (substFormula phi).imp (substFormula psi)`
- [ ] Prove `substFormula_box : substFormula (phi.box) = (substFormula phi).box`
- [ ] Prove `substFormula_all_past : substFormula (phi.all_past) = (substFormula phi).all_past`
- [ ] Prove `substFormula_all_future : substFormula (phi.all_future) = (substFormula phi).all_future`
- [ ] Prove `substFormula_preserves_qfree : freshAtom not_in phi.atoms -> substFormula phi = phi`
  - This is the key lemma: q-free formulas are fixed points of substitution
- [ ] Prove `substFormula_of_embedded : substFormula (embedFormula phi) = embedFormula phi`
  - Follows from `fresh_not_in_embedFormula_atoms` + `substFormula_preserves_qfree`

**Timing:** 1 hour

**Files to create:**
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` (~80 lines)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` returns empty
- `substFormula_preserves_qfree` theorem compiles without sorry

---

### Phase 2: Axiom Substitution Closure [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Prove all axiom schemas closed under substitution

**Tasks:**
- [ ] In `Substitution.lean`, add section for axiom closure
- [ ] Define derived operator preservation:
  - `substFormula_neg : substFormula phi.neg = (substFormula phi).neg`
  - `substFormula_and : substFormula (phi.and psi) = (substFormula phi).and (substFormula psi)`
  - `substFormula_or`, `substFormula_diamond`, `substFormula_some_past`, `substFormula_some_future`, `substFormula_always`
- [ ] Prove `substAxiom : ExtAxiom phi -> ExtAxiom (substFormula phi)` (20 cases, one per axiom schema)
  - Each axiom schema `A(phi_1, ..., phi_n)` maps to `A(substFormula phi_1, ..., substFormula phi_n)`
  - All schemas are closed under uniform substitution by construction
- [ ] Prove `substFormula_idempotent : substFormula (substFormula phi) = substFormula phi`
  - After substitution, no `Sum.inr ()` remains, so second application is identity

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` (+70 lines)

**Verification:**
- `lake build` passes
- `substAxiom` theorem compiles without sorry

---

### Phase 3: Lifting Theorem [COMPLETED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove q-free F+ derivations project to F derivations via substitution

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean`
- [ ] Prove helper: `bot_and_Hnegbot_implies_anything : ExtDerivationTree [] ((bot.and (all_past (neg bot))).imp phi)`
  - The antecedent `(bot AND H(neg bot))` is contradictory
  - Derivable for any phi via ex falso
- [ ] Prove `substDerivation : ExtDerivationTree Gamma phi -> ExtDerivationTree (Gamma.map substFormula) (substFormula phi)` by induction:
  - `axiom`: use `substAxiom`
  - `assumption`: membership preserved under map
  - `modus_ponens`: apply substitution to both premises
  - `necessitation`, `temporal_necessitation`: substitute under box/all_future
  - `temporal_duality`: substitute under swap_temporal (need helper lemma)
  - `irr (p) (phi)`:
    - If `p = freshAtom`: antecedent becomes `(bot AND H(neg bot)) -> substFormula phi`, use `bot_and_Hnegbot_implies_anything`
    - If `p != freshAtom`: `p` is `Sum.inl s`, fresh in `substFormula phi`, apply IRR directly
  - `weakening`: map substitution over context subset
- [ ] Prove main lifting theorem:
  ```lean
  theorem lift_derivation_qfree (L : List Formula) (phi : Formula)
      (d : ExtDerivationTree (L.map embedFormula) (embedFormula phi)) :
      Nonempty (DerivationTree L phi)
  ```
  - Apply `substDerivation` to get `ExtDerivationTree (L.map embedFormula) (embedFormula phi)` (since embedded formulas are q-free fixed points)
  - The substituted derivation uses only embedded axioms (Sum.inl atoms)
  - Extract F derivation by inverting the embedding (structural correspondence)

**Timing:** 1.5 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` (~100 lines)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` returns empty
- `lift_derivation_qfree` theorem compiles without sorry

**Escape Valve:** If IRR case proof becomes intractable after 1 hour of effort, mark [BLOCKED] with details on what approach was tried.

---

### Phase 4: Irreflexivity Proof [BLOCKED]

- **Dependencies:** Phase 3
- **Goal:** Prove canonicalR_irreflexive using the lifting theorem

**Tasks:**
- [ ] Create or extend `Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean`
- [ ] Prove naming set consistency in F+:
  ```lean
  theorem embed_naming_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      SetConsistent_Ext (embedFormula '' M ∪ {atom freshAtom, all_past (neg (atom freshAtom))})
  ```
  - Use IRR-contrapositive argument
  - Key: `atomFreeSubset_Ext(embed '' M, freshAtom) = embed '' M` by freshness
  - If naming set inconsistent, IRR gives F+-derivation of q-free formula
  - By lifting theorem: F-derivation from M of that formula
  - Contradiction with M's consistency
- [ ] Prove main irreflexivity theorem:
  ```lean
  theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      ¬CanonicalR M M
  ```
  Proof outline:
  1. Assume `CanonicalR M M`, i.e., `GContent M ⊆ M`
  2. Consider naming set in F+: `N = embed '' M ∪ {atom q, H(neg q)}`
  3. N is F+-consistent (by IRR-contrapositive + lifting)
  4. Extend N to F+-MCS M'_ext via Lindenbaum
  5. Key observation: the standard naming argument shows if `CanonicalR M M` then M is F-inconsistent
  6. The lifting theorem transfers the F+ inconsistency proof back to F
  7. Contradiction with M being an MCS

**Timing:** 1.5 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean` (~150 lines)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean` returns empty
- `canonicalR_irreflexive` theorem compiles without sorry

**Escape Valve:** If proof remains stuck after 1.5 hours of effort, mark [BLOCKED] with:
- What approaches were tried
- Where the proof is stuck (which step of the outline)
- What mathematical insight might be needed
- Set `requires_user_review: true`

---

### Phase 5: Integration and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Update existing files, verify full build, documentation

**Tasks:**
- [ ] Create or update `Theories/Bimodal/Metalogic/ConservativeExtension.lean` as module root with exports:
  ```lean
  import Bimodal.Metalogic.ConservativeExtension.ExtFormula
  import Bimodal.Metalogic.ConservativeExtension.ExtDerivation
  import Bimodal.Metalogic.ConservativeExtension.Substitution
  import Bimodal.Metalogic.ConservativeExtension.Lifting
  import Bimodal.Metalogic.ConservativeExtension.Irreflexivity
  ```
- [ ] Update `CanonicalIrreflexivity.lean`:
  - Add import for `ConservativeExtension.Irreflexivity`
  - Replace sorries at lines 1245 and 1328 with reference to `canonicalR_irreflexive`
  - May require restructuring the proof to use the new theorem
- [ ] Run `lake build` on full project
- [ ] Verify `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/` returns empty
- [ ] Verify zero sorries in `CanonicalIrreflexivity.lean` (except documented pre-existing ones in other theorems if any)
- [ ] Add documentation comments explaining the conservative extension strategy
- [ ] Create implementation summary

**Timing:** 30-45 minutes

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/ConservativeExtension.lean` (new, ~15 lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (update imports, remove sorries)

**Verification:**
- `lake build` passes with no errors
- Zero sorries in ConservativeExtension directory
- Sorries at lines 1245 and 1328 in CanonicalIrreflexivity.lean removed
- No new axioms introduced

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/ConservativeExtension/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Theorem Verification
- [ ] `substFormula_preserves_qfree` has correct signature
- [ ] `substAxiom` has correct signature
- [ ] `lift_derivation_qfree` has correct signature
- [ ] `canonicalR_irreflexive` has correct signature

### Integration Verification
- [ ] `CanonicalIrreflexivity.lean` compiles with no sorries related to irreflexivity
- [ ] Task 956 Phase 6 can proceed (dependency unblocked)

## Artifacts & Outputs

New files:
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` (~150 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` (~100 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean` (~150 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension.lean` (~15 lines, module root)

Modified files:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (remove 2 sorries)

Plan artifacts:
- `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-003.md` (this file)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-YYYYMMDD.md`

Total: ~415 lines of new Lean code

## Rollback/Contingency

If implementation fails:
1. All new files are in separate `ConservativeExtension/` directory - can be deleted without affecting existing code
2. Existing `CanonicalIrreflexivity.lean` remains unchanged until Phase 5 (integration phase)
3. No existing theorems depend on the new theorems yet (Task 956 Phase 6 is blocked waiting for this)
4. If Phase 3 (lifting) proves intractable: consider simplified approach using only the IRR-contrapositive argument without full lifting
5. If Phase 4 (irreflexivity) proves intractable: research-006 mentions product frame bypass as alternative (restructures completeness proof architecture)
