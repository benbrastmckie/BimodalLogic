# Implementation Plan: Task #958 - Conservative Extension Approach

- **Task**: 958 - prove_canonicalr_irreflexive_irr_rule
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (builds on existing MCS and IRR infrastructure)
- **Research Inputs**: specs/958_prove_canonicalr_irreflexive_irr_rule/reports/research-005.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove that CanonicalR is irreflexive using the Conservative Extension approach. The previous plan (implementation-001.md) using direct substitution is [BLOCKED] because global freshness is impossible with String atoms (every MCS M contains either `atom s` or `neg(atom s)` for every string `s`, so `atoms(M) = String`). The conservative extension approach introduces `ExtAtom := String + Unit` where `Sum.inr ()` serves as a globally fresh atom for ALL embedded F-formulas.

### Research Integration

Key findings from research-005.md:

1. **Root cause of blocker**: Global freshness is impossible with String atoms because `atoms(M) = String` for every MCS M
2. **Solution**: Extended language with atoms `String + Unit` where `q := Sum.inr ()` does not appear in ANY embedded F-formula
3. **Key insight**: `atomFreeSubset(embed '' M, q) = embed '' M` because all embedded formulas are q-free
4. **Lifting theorem**: q-free F+ derivations project to F derivations via uniform substitution
5. **File organization**: New `ConservativeExtension/` subdirectory under `Theories/Bimodal/Metalogic/`

## Goals & Non-Goals

**Goals**:
- Create `ExtFormula` type with `ExtAtom := String + Unit`
- Create extended proof system `ExtDerivationTree` with IRR taking `ExtAtom`
- Prove `fresh_not_in_embedFormula_atoms : Sum.inr () not in (embedFormula phi).atoms`
- Prove lifting theorem for q-free derivations
- Prove `canonicalR_irreflexive : forall M, SetMaximalConsistent M -> NOT CanonicalR M M`
- Zero sorries in final implementation

**Non-Goals**:
- Do not modify existing Formula, Axiom, or DerivationTree types
- Do not add new axioms to the base proof system
- Do not pursue direct substitution approach (research shows it fails)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ExtFormula boilerplate complexity | MEDIUM | HIGH | Use automation (derive, simp) aggressively; mirror existing Formula structure |
| Lifting theorem complexity (IRR case) | HIGH | MEDIUM | Handle sigma[q -> bot] case carefully where antecedent becomes contradictory |
| MCS properties duplication | MEDIUM | HIGH | Factor shared proofs via sections; minimize duplication |
| embedDerivation induction cases | MEDIUM | MEDIUM | Use structural recursion mirroring DerivationTree |
| Build time increase from new files | LOW | MEDIUM | Keep new files in separate ConservativeExtension/ directory |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalIrreflexivity.lean` at lines 1245 and 1328 (from previous direct approach attempts)
- These sorries stem from global freshness impossibility

### Expected Resolution
- Phase 5 provides new proof that bypasses the global freshness issue
- The two existing sorries become obsolete once `canonicalR_irreflexive` is proved via conservative extension
- Existing CanonicalIrreflexivity.lean can be updated to import and use the new theorem

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in new `ConservativeExtension/` files
- Existing `CanonicalIrreflexivity.lean` can be refactored to remove its sorries
- Downstream theorems (Task 956 Phase 6) will be unblocked

## Implementation Phases

### Phase 1: ExtFormula Infrastructure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Define extended formula type with `ExtAtom := String + Unit` and embedding functions

**Tasks:**
- [ ] Create directory `Theories/Bimodal/Metalogic/ConservativeExtension/`
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean`
- [ ] Define `ExtAtom := String + Unit` as abbrev for transparency
- [ ] Define `ExtFormula` inductive mirroring Formula structure:
  ```lean
  inductive ExtFormula : Type where
    | atom : ExtAtom -> ExtFormula
    | bot : ExtFormula
    | imp : ExtFormula -> ExtFormula -> ExtFormula
    | box : ExtFormula -> ExtFormula
    | all_past : ExtFormula -> ExtFormula
    | all_future : ExtFormula -> ExtFormula
    deriving Repr, DecidableEq, BEq, Hashable, Countable
  ```
- [ ] Define derived operators: `neg`, `and`, `or`, `diamond`, `always`, `sometimes`, `some_past`, `some_future`, `swap_temporal`
- [ ] Define `ExtFormula.atoms : ExtFormula -> Finset ExtAtom`
- [ ] Define `embedAtom : String -> ExtAtom := Sum.inl`
- [ ] Define `embedFormula : Formula -> ExtFormula` (recursive structural map)
- [ ] Prove `embedFormula_injective : Function.Injective embedFormula`
- [ ] Prove `fresh_not_in_embedFormula_atoms : Sum.inr () not in (embedFormula phi).atoms`
- [ ] Prove structural preservation lemmas: `embedFormula_neg`, `embedFormula_and`, `embedFormula_imp`, `embedFormula_box`, `embedFormula_all_past`, `embedFormula_all_future`, `embedFormula_swap_temporal`

**Timing**: 1.5-2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` (~200 lines)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` returns empty
- `fresh_not_in_embedFormula_atoms` theorem compiles without sorry

---

### Phase 2: Extended Proof System [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Define extended axiom and derivation types with embedding preservation

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean`
- [ ] Define `ExtAxiom : ExtFormula -> Type` mirroring all 20 axiom schemas from Axioms.lean
- [ ] Define `ExtContext := List ExtFormula`
- [ ] Define `ExtDerivationTree : ExtContext -> ExtFormula -> Type` with constructors:
  - `axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`
  - **Critical**: `irr (p : ExtAtom) (phi : ExtFormula) (h_fresh : p not in phi.atoms) (d : ExtDerivationTree [] ((atom p AND H(neg(atom p))).imp phi)) : ExtDerivationTree [] phi`
- [ ] Define `embedAxiom : Axiom phi -> ExtAxiom (embedFormula phi)` (case analysis on axiom constructors)
- [ ] Prove `embedDerivation : DerivationTree Gamma phi -> ExtDerivationTree (Gamma.map embedFormula) (embedFormula phi)` by induction on derivation tree

**Timing**: 1.5-2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` (~150 lines)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` returns empty
- `embedDerivation` theorem compiles without sorry

---

### Phase 3: Extended MCS and Naming Set Consistency [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Define extended MCS, prove naming set with embedded M is consistent

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/ExtMCS.lean`
- [ ] Define `SetConsistent_Ext`, `SetMaximalConsistent_Ext` mirroring Core definitions
- [ ] Prove `set_lindenbaum_ext` (Lindenbaum for F+, may leverage existing proof structure)
- [ ] Define fresh atom: `q := Sum.inr () : ExtAtom`
- [ ] Define `embed_naming_set (M : Set Formula) := embedFormula '' M cup {ExtFormula.atom q, ExtFormula.all_past (ExtFormula.neg (ExtFormula.atom q))}`
- [ ] Prove key insight: `atomFreeSubset_ext_embed : atomFreeSubset_Ext (embedFormula '' M) q = embedFormula '' M`
  - Because ALL embedded formulas are q-free by `fresh_not_in_embedFormula_atoms`
- [ ] Prove `embed_naming_set_consistent : SetMaximalConsistent M -> SetConsistent_Ext (embed_naming_set M)`
  - Use IRR-contrapositive argument
  - Suppose finite L from embed_naming_set derives bot in F+
  - Separate into L_M (embedded F-formulas) and L_q (naming formulas)
  - By deduction theorem and IRR: conclude derives chi where chi is q-free
  - By lifting (Phase 4 preview): if embedded F-formulas derive chi in F+, original derives chi in F
  - Contradiction with M's consistency

**Timing**: 1-1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtMCS.lean` (~100 lines)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/ExtMCS.lean` returns empty
- `embed_naming_set_consistent` theorem compiles without sorry

---

### Phase 4: Lifting Theorem [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove that q-free F+ derivations project to F derivations

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean`
- [ ] Define substitution `sigma_q_bot : ExtFormula -> ExtFormula` that replaces `atom (Sum.inr ())` with `bot`
- [ ] Prove `sigma_preserves_qfree : p not in phi.atoms -> sigma_q_bot phi = phi` (for q-free formulas)
- [ ] Prove substitution lemma for axioms: `sigma_q_bot` maps each ExtAxiom instance to a valid axiom instance (schema substitution)
- [ ] Handle IRR case carefully:
  - If `p = q`: antecedent `(q AND H(neg q))` maps to `(bot AND H(neg bot))` which is contradictory
  - The implication `(bot AND H(neg bot)) -> phi` is derivable for any phi (ex falso)
  - Conclusion phi is q-free, so `sigma(phi) = phi`
  - Therefore the F+-IRR rule application maps to an F-derivation
- [ ] Prove main lifting theorem:
  ```lean
  theorem lift_derivation_qfree (L : List Formula) (phi : Formula)
      (d : ExtDerivationTree (L.map embedFormula) (embedFormula phi)) :
      Nonempty (DerivationTree L phi)
  ```

**Timing**: 1.5-2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` (~80 lines)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` returns empty
- `lift_derivation_qfree` theorem compiles without sorry

---

### Phase 5: Irreflexivity Transfer [NOT STARTED]

- **Dependencies:** Phase 3, Phase 4
- **Goal:** Prove canonicalR_irreflexive using conservative extension framework

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean`
- [ ] Prove GContent transfer: if `GContent M subset M`, then `GContent_Ext(embedFormula '' M) subset embed_naming_set M extended`
  - Key: GContent of embedded F-formulas stays in embedded set because `atomFreeSubset = embedFormula '' M`
- [ ] Prove H-content duality in extended setting (may reuse existing WitnessSeed patterns)
- [ ] Prove main theorem:
  ```lean
  theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      NOT CanonicalR M M := by
    intro h_R
    -- 1. Construct embed_naming_set M (q-free part plus naming formulas)
    -- 2. By Phase 3: embed_naming_set is F+-consistent
    -- 3. Extend to F+-MCS M'_ext via Lindenbaum
    -- 4. M'_ext contains embedFormula '' M, atom(q), H(neg(q))
    -- 5. Since embedFormula '' M = atomFreeSubset for q, GContent transfer works
    -- 6. From CanonicalR(M, M): GContent(M) subset M, so embed(GContent(M)) subset M'_ext
    -- 7. The contradiction arises from: atom(q) in M'_ext AND H(neg(q)) in M'_ext
    --    plus the GContent/HContent duality
    -- 8. Final step: neg(atom(q)) ends up required in M'_ext, contradicting atom(q) in M'_ext
    sorry -- If stuck after reasonable effort, mark [BLOCKED]
  ```
- [ ] If proof is stuck after 2 hours of effort, mark [BLOCKED] with `requires_user_review: true`

**Timing**: 1.5-2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean` (~100 lines)

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean` returns empty
- `canonicalR_irreflexive` theorem compiles without sorry

**Escape Valve**: If proof remains stuck after 2 hours of Phase 5 effort, mark [BLOCKED] with:
- What approaches were tried
- Where the proof is stuck
- What insight might be needed

---

### Phase 6: Integration and Cleanup [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Update existing files to use new theorem, verify full build

**Tasks:**
- [ ] Create or update `Theories/Bimodal/Metalogic/ConservativeExtension.lean` as module root with exports
- [ ] Update `CanonicalIrreflexivity.lean` to import and use `canonicalR_irreflexive` from ConservativeExtension
- [ ] Remove sorries from `CanonicalIrreflexivity.lean` (replace with reference to new theorem)
- [ ] Run `lake build` on full project
- [ ] Verify `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/` returns empty
- [ ] Add documentation comments explaining the conservative extension strategy
- [ ] Create implementation summary

**Timing**: 30-45 min

**Files to modify**:
- `Theories/Bimodal/Metalogic/ConservativeExtension.lean` (new, ~20 lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (update imports, remove sorries)

**Verification**:
- `lake build` passes with no errors
- Zero sorries in ConservativeExtension directory
- Zero sorries in CanonicalIrreflexivity.lean
- No new axioms introduced

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ConservativeExtension/` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/ConservativeExtension/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Theorem Verification
- [ ] `fresh_not_in_embedFormula_atoms` has correct signature
- [ ] `embedDerivation` has correct signature
- [ ] `embed_naming_set_consistent` has correct signature
- [ ] `lift_derivation_qfree` has correct signature
- [ ] `canonicalR_irreflexive` has correct signature

## Artifacts & Outputs

New files:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` (~200 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` (~150 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtMCS.lean` (~100 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` (~80 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension/Irreflexivity.lean` (~100 lines)
- `Theories/Bimodal/Metalogic/ConservativeExtension.lean` (~20 lines, module root)

Plan artifacts:
- `specs/958_prove_canonicalr_irreflexive_irr_rule/plans/implementation-002.md` (this file)
- `specs/958_prove_canonicalr_irreflexive_irr_rule/summaries/implementation-summary-YYYYMMDD.md`

Total: ~650 lines of new Lean code

## Rollback/Contingency

If implementation fails:
1. All new files are in a separate `ConservativeExtension/` directory - can be deleted without affecting existing code
2. Existing `CanonicalIrreflexivity.lean` remains unchanged until Phase 6 (integration phase)
3. No existing theorems depend on the new theorems yet (Task 956 Phase 6 is blocked waiting for this)
4. If the conservative extension approach proves intractable, research-005 mentions a fallback: semantic soundness meta-argument (argue that IF CanonicalR(M,M) then canonical model has reflexive point, contradicting IRR soundness on irreflexive frames)
5. Alternative: Product domain T x Q construction from RestrictedFragment.lean:443 (avoids irreflexivity proof entirely but requires restructuring)
