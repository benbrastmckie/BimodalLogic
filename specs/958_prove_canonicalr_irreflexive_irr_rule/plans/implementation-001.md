# Implementation Plan: Task #958

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (builds on existing MCS and IRR infrastructure)
- **Research Inputs**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove that CanonicalR is irreflexive: for any MCS M, `NOT CanonicalR(M, M)`. This is a critical prerequisite for the Cantor isomorphism application in Task 956 Phase 6. The research establishes that direct axiom approaches FAIL and the IRR rule is ESSENTIAL. The recommended approach is the substitution-based proof from Goldblatt/Blackburn-de Rijke-Venema, which uses IRR contrapositively to establish consistency of a "naming set" that then leads to contradiction.

### Research Integration

Key findings from research-002.md (team research with 2 teammates):

1. **Direct axiom approach fails**: CanonicalR(M, M) is syntactically consistent with all non-IRR axioms
2. **H-closure derivation**: If GContent(M) subset M, then HContent(M) subset M (via temp_a)
3. **Substitution approach recommended**: Standard technique using fresh atom p as "time marker"
4. **Proof sketch**: Assume CanonicalR(M,M), show Gamma_p cup {p, H(neg p)} is consistent using IRR contrapositively, extend to MCS M', derive contradiction via H-closure at M'

## Goals & Non-Goals

**Goals**:
- Prove `canonicalR_irreflexive : forall M, SetMaximalConsistent M -> NOT CanonicalR M M`
- Implement H-closure lemma as reusable intermediate result
- Use the IRR rule in a syntactically correct way (via contrapositive consistency argument)
- Zero sorries in final implementation

**Non-Goals**:
- Do not modify existing MCS or CanonicalR definitions
- Do not add new axioms (use existing IRR rule)
- Do not pursue direct axiom approach (research shows it fails)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Substitution proof blocked by syntactic issues (neg is derived, double negation complications) | HIGH | MEDIUM | Fall back to semantic soundness meta-argument; use existing DNE lemmas in MCSProperties |
| Lindenbaum extension requirements not met | HIGH | LOW | Verify existing Lindenbaum construction handles extended sets |
| Atom freshness formalization complex | MEDIUM | MEDIUM | Use formula.atoms and set membership; leverage existing atom infrastructure |
| Proof exceeds time estimate | MEDIUM | MEDIUM | Phase 5 includes [BLOCKED] escape valve for user review |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in scope (new theorem, not resolving existing sorries)

### Expected Resolution
- N/A (no pre-existing sorries)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in new file(s)
- Downstream theorems (Task 956 Phase 6) will be unblocked

## Implementation Phases

### Phase 1: H-Closure Lemma [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove that GContent(M) subset M implies HContent(M) subset M

**Tasks:**
- [ ] Create new file `Theories/TemporalLogic/CanonicalIrreflexivity.lean` with imports
- [ ] Prove double negation lemmas for temporal contexts if not already present
- [ ] Prove `H_closure_from_G_closure : GContent M subset M -> HContent M subset M`
  - Use temp_a: `phi -> G(P(phi))`
  - Chain: `phi in M -> G(P(phi)) in M -> P(phi) in M` (by G-closure)
  - P(phi) = neg(H(neg phi)), so H(neg phi) not in M
  - Contrapositive + double negation: H(psi) in M -> psi in M

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/TemporalLogic/CanonicalIrreflexivity.lean` (new file)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty
- Lemma signature matches `H_closure_from_G_closure`

---

### Phase 2: Atom-Free Subset Definition [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Define atomFreeSubset and prove basic properties

**Tasks:**
- [ ] Define `atomFreeSubset (M : Set Formula) (p : String) : Set Formula := { psi in M | p not in psi.atoms }`
- [ ] Prove `atomFreeSubset_subset : atomFreeSubset M p subset M`
- [ ] Prove `GContent_atomFree_of_fresh : p fresh for M -> GContent M subset atomFreeSubset M p`
  - Key insight: if p not in any formula of M, then G(phi) in M means phi.atoms does not contain p
- [ ] Define "freshness" predicate: `atom_fresh_for (p : String) (M : Set Formula) : Prop`

**Timing**: 45 min - 1 hour

**Files to modify**:
- `Theories/TemporalLogic/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty

---

### Phase 3: Naming Set Consistency (IRR Contrapositive) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove that Gamma_p cup {p, H(neg p)} is consistent using IRR contrapositively

**Tasks:**
- [ ] Define naming set: `namingSet (M : Set Formula) (p : String) := atomFreeSubset M p cup {atom p, H(neg(atom p))}`
- [ ] Prove consistency lemma:
  ```lean
  lemma naming_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (h_R : CanonicalR M M) (p : String) (h_fresh : atom_fresh_for p M) :
      SetConsistent (namingSet M p)
  ```
- [ ] Proof approach (IRR contrapositive):
  - Suppose not consistent: some finite subset derives bot
  - This means `Gamma, p, H(neg p) derives bot` for finite Gamma subset atomFreeSubset M p
  - By deduction theorem: `derives (p AND H(neg p)) -> neg(bigwedge Gamma)`
  - The conclusion `neg(bigwedge Gamma)` is p-free since Gamma is p-free
  - By IRR: `derives neg(bigwedge Gamma)`, so `neg(bigwedge Gamma)` is a theorem
  - By theorem_in_mcs: `neg(bigwedge Gamma) in M`
  - But `bigwedge Gamma subset M` (since Gamma subset M), so M is inconsistent
  - Contradiction with M being MCS

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/TemporalLogic/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty
- Lemma signature matches `naming_set_consistent`

---

### Phase 4: Lindenbaum Extension and CanonicalR Preservation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Extend naming set to MCS M' and show CanonicalR(M, M')

**Tasks:**
- [ ] Apply Lindenbaum lemma to extend namingSet M p to MCS M'
- [ ] Prove `GContent_subset_M'`:
  ```lean
  lemma canonicalR_M_M' (M M' : Set Formula) (h_mcs : SetMaximalConsistent M)
      (h_R : CanonicalR M M) (h_mcs' : SetMaximalConsistent M')
      (h_ext : namingSet M p subset M') (p : String) (h_fresh : atom_fresh_for p M) :
      CanonicalR M M'
  ```
- [ ] Proof approach:
  - GContent(M) is p-free (since p is fresh for M)
  - By Phase 2: GContent M subset atomFreeSubset M p
  - atomFreeSubset M p subset namingSet M p subset M'
  - Therefore CanonicalR M M'

**Timing**: 45 min - 1 hour

**Files to modify**:
- `Theories/TemporalLogic/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty

---

### Phase 5: Main Theorem - CanonicalR Irreflexivity [NOT STARTED]

- **Dependencies:** Phase 1, Phase 3, Phase 4
- **Goal:** Prove the main irreflexivity theorem

**Tasks:**
- [ ] Prove main theorem:
  ```lean
  theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      NOT CanonicalR M M := by
    intro h_R
    -- Choose fresh atom p
    -- By Phase 3: namingSet M p is consistent
    -- By Lindenbaum: extend to MCS M'
    -- By Phase 4: CanonicalR M M'
    -- At M': atom p in M' and H(neg(atom p)) in M'
    -- By CanonicalR M M' and Phase 1 (H-closure applied to M with successor M'):
    --   H(neg(atom p)) in M' implies we need H-closure reasoning
    -- Actually the contradiction: in M', both atom p and H(neg(atom p)) hold
    -- By H-closure at M' (if CanonicalR M' M' held): neg(atom p) in M'
    -- But we have CanonicalR M M', not CanonicalR M' M'
    -- Key insight: use temp_a on atom p at M': G(P(atom p)) in M'
    -- If GContent(M) subset M' (which we have), and GContent(M) subset M (from h_R),
    -- need to derive that p AND H(neg p) at M' contradicts something
    -- The contradiction: CanonicalR(M, M') + temp_a gives P(p) in M' if p in M'
    -- P(p) = neg H(neg p), so H(neg p) not in M'. But H(neg p) in M' by construction!
    sorry -- If stuck here, mark [BLOCKED] for user review
  ```
- [ ] If proof is stuck after reasonable effort, mark [BLOCKED] with review_reason

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/TemporalLogic/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty
- Main theorem signature: `canonicalR_irreflexive : (M : Set Formula) -> SetMaximalConsistent M -> NOT CanonicalR M M`

**Escape Valve**: If proof remains stuck after 1.5 hours of Phase 5 effort, mark [BLOCKED] with `requires_user_review: true` and document:
- What approaches were tried
- Where the proof is stuck
- What insight might be needed

---

### Phase 6: Integration and Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Final verification and documentation

**Tasks:**
- [ ] Run `lake build` on full project
- [ ] Verify `grep -rn "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty
- [ ] Add documentation comments explaining the proof strategy
- [ ] Create implementation summary

**Timing**: 30 min

**Files to modify**:
- `Theories/TemporalLogic/CanonicalIrreflexivity.lean` (documentation)

**Verification**:
- `lake build` passes with no errors
- Zero sorries in new file
- No new axioms introduced

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/TemporalLogic/CanonicalIrreflexivity.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/TemporalLogic/CanonicalIrreflexivity.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Theorem Verification
- [ ] `canonicalR_irreflexive` has correct signature
- [ ] `H_closure_from_G_closure` has correct signature
- [ ] `naming_set_consistent` has correct signature

## Artifacts & Outputs

- `Theories/TemporalLogic/CanonicalIrreflexivity.lean` - New file with irreflexivity proof
- `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-001.md` (this file)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. The new file can be deleted without affecting existing code
2. No existing theorems depend on canonicalR_irreflexive yet (Task 956 Phase 6 is blocked waiting for this)
3. If the substitution approach proves intractable, research suggests a fallback: semantic soundness meta-argument (argue that IF CanonicalR(M,M) then canonical model has reflexive point, contradicting IRR soundness on irreflexive frames)
4. Alternative: Product domain T x Q construction from RestrictedFragment.lean:443 (avoids irreflexivity proof entirely but requires restructuring)
