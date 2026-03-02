# Implementation Plan: Task #951 (Revision 5)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [NOT STARTED]
- **Effort**: 35-50 hours
- **Version**: 5 (supersedes implementation-001.md through -004.md)
- **Dependencies**: BidirectionalReachable.lean (sorry-free fragment infrastructure), CanonicalCompleteness.lean (fragmentFMCS sorry-free)
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-021.md (synthesis)
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-021-teammate-d-findings.md (verification)
  - specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/phase1-blocker-analysis-20260301.md (v3/v4 blockers)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

| Version | Date | Key Changes | Outcome |
|---------|------|-------------|---------|
| 001 | 2026-02-27 | Z-indexed dovetailing chain | Blocked: F-persistence through GContent impossible |
| 002 | 2026-02-27 | Bidirectional Reachable Fragment | Phases A-D completed; LinearOrder proven |
| 003 | 2026-03-01 | OrderIso via SuccOrder/PredOrder | **PERMANENTLY BLOCKED**: coverness fails |
| 004 | 2026-03-01 | Grothendieck construction | **PERMANENTLY BLOCKED**: quotientSucc_pred_inverse requires G(phi)->H(phi), semantically invalid |
| 005 | 2026-03-02 | **Fragment-level completeness + Int embedding** | New approach based on research-021 synthesis |

## Why Revision is Needed

**Plans v3 and v4 are PERMANENTLY BLOCKED** (not merely blocked):
- **Plan v3**: SuccOrder coverness fails because Lindenbaum creates intermediate elements
- **Plan v4**: Grothendieck `quotientSucc_pred_inverse` requires `G(phi)->H(phi)`, which is semantically invalid (countermodel: 3-point linear order)

Both blockers trace to the same mathematical impossibility: Lindenbaum extension is non-constructive and prevents algebraic regularity on the quotient.

**Research-021 resolution**: The root cause is the 2 sorries in DovetailingChain.lean (forward_F at line 1869, backward_P at line 1881). These exist because F-formulas are existential and not in GContent (universal seeds). However, the FRAGMENT-LEVEL analogs (`fragmentFMCS_forward_F`, `fragmentFMCS_backward_P`) are SORRY-FREE because they work with a different semantic: "exists s in the BidirectionalFragment" rather than "exists n in Int."

**Key insight from teammate D**: The transfer theorem (`canonical_truth_lemma_all`) is ALREADY PROVEN and sorry-free. The ShiftClosed problem is ALREADY RESOLVED. The only remaining work is constructing a BFMCS Int that satisfies temporal coherence AND modal saturation simultaneously.

## Overview

This plan pursues the **Fragment-Based Completeness + Int Embedding** approach recommended by research-021:

1. **Intermediate completeness at the fragment level**: Prove completeness using `BFMCS (BidirectionalFragment M0 h_mcs0)` where ALL infrastructure is sorry-free
2. **Non-constant witness families**: For modal saturation, construct witness families as separate DovetailingChains rooted at witness MCSes (not constant families)
3. **Fragment enumeration into Int**: Embed the fragment into Int via order-preserving injection
4. **Transfer completeness to Int**: Pull back the fragment model to `BFMCS Int`

This factorization isolates the hard work (temporal coherence + modal saturation) at the fragment level where everything is sorry-free, making the Int embedding a modular step.

### Research Integration

Key findings from 20+ research reports integrated:
- **research-021 Part 4**: DovetailingChain forward_F/backward_P are root cause of all sorries
- **research-021 Part 5**: fragmentFMCS, fragmentFMCS_forward_F, fragmentFMCS_backward_P are sorry-free
- **teammate D verification**: canonical_truth_lemma_all is proven; ShiftClosed is resolved; fragment is discrete
- **research-018 Section 8**: Chain-based task_rel avoids SuccOrder blockers

## Goals & Non-Goals

**Goals**:
- Prove intermediate completeness at the BidirectionalFragment level (sorry-free infrastructure)
- Construct non-constant witness families for modal saturation (each witness is a DovetailingChain)
- Define order-preserving enumeration of fragment into Int
- Prove truth transfer through the embedding
- Eliminate all 3 remaining sorries in the completeness chain
- Achieve `standard_weak_completeness` and `standard_strong_completeness` sorry-free

**Non-Goals**:
- Proving SuccOrder coverness (mathematically blocked)
- Using quotientSucc/quotientPred inverse (mathematically blocked)
- Changing the `valid` definition (breaks MF/TF soundness)
- Requiring D = Q density (fragment is discrete)

## Preserved Infrastructure

| Module | Status | Key Deliverables |
|--------|--------|------------------|
| BidirectionalReachable.lean | Sorry-free (~830 lines) | BidirectionalFragment, totality, F/P closure, LinearOrder on quotient |
| CanonicalCompleteness.lean | Sorry-free (~660 lines) | fragmentFMCS, quotientSucc, quotientPred, enriched seeds |
| CanonicalFrame.lean | Sorry-free (~400 lines) | CanonicalR, forward_F/backward_P at frame level |
| TruthLemma.lean | Sorry-free (~350 lines) | bmcs_truth_lemma (all 6 cases) |
| ModalSaturation.lean | Sorry-free (~200 lines) | saturated_modal_backward |
| Representation.lean | Sorry-free (~600 lines) | canonical_truth_lemma_all, shifted_truth_lemma, shiftClosedCanonicalOmega |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fragment enumeration requires surjectivity proof | High | Medium | Use well-ordering on countable set; explicit enumeration construction |
| Witness families from different roots may be incompatible | Medium | Low | Each witness family is independent; combine via product BFMCS construction |
| Truth transfer through embedding is subtle | High | Medium | Fragment truth uses Preorder; Int truth uses AddCommGroup; bridge via monotonicity |
| Modal saturation with non-constant witnesses is complex | High | Medium | Follow existing ModalSaturation.lean pattern; each witness is a separate chain |
| Fragment may have fixed points under quotientSucc | Medium | Low | If fixed point exists, fragment is finite; handle as special case |

## Sorry Characterization

### Pre-existing Sorries

Exactly **3 sorries** remain in the active codebase:

| File | Line | Statement | Root Cause |
|------|------|-----------|------------|
| DovetailingChain.lean | 1869 | `buildDovetailingChainFamily_forward_F` | F-formulas don't persist through GContent seeds |
| DovetailingChain.lean | 1881 | `buildDovetailingChainFamily_backward_P` | P-formulas don't persist through HContent seeds |
| TemporalCoherentConstruction.lean | 600 | `fully_saturated_bfmcs_exists_int` | Combines temporal coherence + modal saturation |

### Expected Resolution

- **Phase 2** proves fragment-level temporal coherence using sorry-free fragmentFMCS
- **Phase 3** constructs non-constant witness families for modal saturation
- **Phase 4** proves fragment-level completeness combining phases 2-3
- **Phase 5** embeds fragment into Int and proves `fully_saturated_bfmcs_exists_int`
- DovetailingChain.lean sorries become obsolete (bypassed, not directly resolved)

### New Sorries

- **None.** NEVER introduce new sorries.
- If proof cannot be completed: mark phase [BLOCKED] with `requires_user_review: true`
- User decides: revise plan, split task, or change approach
- DO NOT use sorry and mark task complete

### Remaining Debt

After implementation:
- 0 sorries in completeness chain
- `standard_weak_completeness` and `standard_strong_completeness` become sorry-free
- DovetailingChain.lean can be archived (deprecated)
- Downstream theorems no longer inherit sorry status

## Implementation Phases

### Phase 1: Fragment Infrastructure Verification [NOT STARTED]

- **Dependencies:** None
- **Goal:** Verify all required fragment-level infrastructure is sorry-free and correctly typed

**Tasks:**
- [ ] **Task 1.1:** Verify `fragmentFMCS` exists with correct signature (`FMCS (BidirectionalFragment M0 h_mcs0)`)
- [ ] **Task 1.2:** Verify `fragmentFMCS_forward_F` is sorry-free (F-witnesses in fragment)
- [ ] **Task 1.3:** Verify `fragmentFMCS_backward_P` is sorry-free (P-witnesses in fragment)
- [ ] **Task 1.4:** Verify `fragmentFMCS_temporally_coherent` is sorry-free
- [ ] **Task 1.5:** Verify `enriched_seed_consistent_from_F` and `enriched_seed_consistent_from_P` are sorry-free
- [ ] **Task 1.6:** Verify `diamondWitnessMCS` exists for modal witness construction
- [ ] **Task 1.7:** Document any gaps or missing lemmas for Phase 2

**Timing:** 2-3 hours

**Files to verify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
- `Theories/Bimodal/Metalogic/Canonical/BidirectionalReachable.lean`

**Verification:**
- All listed lemmas exist via `lean_local_search`
- No sorries in their proofs (check with grep)
- Types match expected signatures

---

### Phase 2: Fragment-Level BFMCS with Temporal Coherence [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Construct `BFMCS (BidirectionalFragment M0 h_mcs0)` with temporally coherent eval_family

**Tasks:**
- [ ] **Task 2.1:** Define `fragmentBFMCS_eval_family` wrapping `fragmentFMCS` as the evaluation family
- [ ] **Task 2.2:** Prove `fragmentBFMCS_eval_family_forward_F`: F-witnesses exist in fragment
- [ ] **Task 2.3:** Prove `fragmentBFMCS_eval_family_backward_P`: P-witnesses exist in fragment
- [ ] **Task 2.4:** Prove `fragmentBFMCS_eval_family_temporally_coherent`: combines forward_F and backward_P
- [ ] **Task 2.5:** Define `fragmentBFMCS_single : BFMCS (BidirectionalFragment M0 h_mcs0)` with single eval_family
- [ ] **Task 2.6:** Prove context preservation: `Gamma subseteq (fragmentBFMCS_single.eval_family.mcs origin)`

**Timing:** 4-6 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (new)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- All proofs verified with `lean_goal` showing "no goals"

---

### Phase 3: Non-Constant Witness Families for Modal Saturation [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** For each Diamond(psi) obligation, construct a temporally coherent witness family as a separate fragment-based FMCS

**Tasks:**
- [ ] **Task 3.1:** Define `witnessFragmentRoot (M : Set Formula) (psi : Formula) (h_diamond : Diamond psi in M)` returning the witness MCS for Diamond(psi) at M
- [ ] **Task 3.2:** Prove `witnessFragmentRoot_contains_psi`: the witness MCS contains psi
- [ ] **Task 3.3:** Prove `witnessFragmentRoot_preserves_box`: BoxContent(M) subseteq witness MCS
- [ ] **Task 3.4:** Define `witnessFragment (M : Set Formula) (psi : Formula) (h_diamond)` as `BidirectionalFragment (witnessFragmentRoot ...) h_mcs_witness`
- [ ] **Task 3.5:** Construct `witnessFMCS : FMCS (witnessFragment M psi h_diamond)` using `fragmentFMCS`
- [ ] **Task 3.6:** Prove `witnessFMCS_forward_F` and `witnessFMCS_backward_P` (by `fragmentFMCS` properties)
- [ ] **Task 3.7:** Prove `witnessFMCS_temporally_coherent`
- [ ] **Task 3.8:** Define embedding from `witnessFragment` to `BidirectionalFragment M0 h_mcs0` (if needed for BFMCS combination)

**Timing:** 6-8 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (extend)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- Each witness family is independently temporally coherent

---

### Phase 4: Fragment-Level Completeness Theorem [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Prove completeness at the fragment level: consistent formulas are satisfiable in a fragment model

**Tasks:**
- [ ] **Task 4.1:** Define `fragmentBFMCS_saturate : BFMCS (BidirectionalFragment M0 h_mcs0) -> BFMCS (BidirectionalFragment M0 h_mcs0)` adding witness families for modal saturation
- [ ] **Task 4.2:** Prove `fragmentBFMCS_saturate_temporally_coherent`: all families remain temporally coherent
- [ ] **Task 4.3:** Prove `fragmentBFMCS_saturate_modally_saturated`: Diamond obligations are satisfied
- [ ] **Task 4.4:** Apply Zorn's lemma (following ModalSaturation.lean pattern) to get fully saturated BFMCS
- [ ] **Task 4.5:** Prove `fragment_completeness_theorem`:
  ```lean
  theorem fragment_completeness (phi : Formula) (h_cons : ContextConsistent [phi]) :
      exists (B : BFMCS (BidirectionalFragment M0 h_mcs0)),
        B.temporally_coherent /\
        is_modally_saturated B /\
        phi in B.eval_family.mcs origin
  ```
- [ ] **Task 4.6:** Verify truth lemma applies at fragment level (bmcs_truth_lemma requires Preorder + Zero, which fragment has)

**Timing:** 8-12 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (extend)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- `fragment_completeness_theorem` type-checks and is sorry-free

---

### Phase 5: Fragment Enumeration into Int [NOT STARTED]

- **Dependencies:** Phase 1 (fragment properties)
- **Goal:** Define order-preserving injection from BidirectionalFragment into Int

**Tasks:**
- [ ] **Task 5.1:** Prove `bidirectionalFragment_countable`: the fragment is countable (built from countable seeds)
- [ ] **Task 5.2:** Prove `bidirectionalFragment_nonempty`: the fragment contains at least the root M0
- [ ] **Task 5.3:** Define `fragmentEnumeration : BidirectionalFragment M0 h_mcs0 -> Int` via well-ordering enumeration
- [ ] **Task 5.4:** Prove `fragmentEnumeration_injective`: distinct fragment elements map to distinct integers
- [ ] **Task 5.5:** Prove `fragmentEnumeration_monotone`: w1 <= w2 implies fragmentEnumeration w1 <= fragmentEnumeration w2
- [ ] **Task 5.6:** Prove `fragmentEnumeration_origin_zero`: fragmentEnumeration origin = 0 (or appropriate normalization)

**Timing:** 5-7 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentEnumeration.lean` (new)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentEnumeration.lean` returns empty
- Enumeration is order-preserving

**Note:** If fragment is finite, enumeration is trivial. The infinite case uses well-ordering of countable linear orders.

---

### Phase 6: FMCS Pullback via Enumeration [NOT STARTED]

- **Dependencies:** Phase 4, Phase 5
- **Goal:** Transfer fragment FMCS to FMCS Int using the enumeration

**Tasks:**
- [ ] **Task 6.1:** Define `pullbackFMCS : FMCS (BidirectionalFragment M0 h_mcs0) -> FMCS Int` using fragmentEnumeration
- [ ] **Task 6.2:** Prove `pullbackFMCS_preserves_mcs`: `(pullbackFMCS fam).mcs n = fam.mcs (fragmentEnumeration.symm n)` (or via partial inverse)
- [ ] **Task 6.3:** Prove `pullbackFMCS_forward_F`: F-witnesses transfer through monotone enumeration
- [ ] **Task 6.4:** Prove `pullbackFMCS_backward_P`: P-witnesses transfer through monotone enumeration
- [ ] **Task 6.5:** Prove `pullbackFMCS_temporally_coherent`: temporal coherence preserved
- [ ] **Task 6.6:** Handle out-of-range integers (those not in fragment image): extend by constant MCS or use fragment-bounded construction

**Timing:** 6-8 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentToInt.lean` (new)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentToInt.lean` returns empty
- Pullback preserves temporal coherence

---

### Phase 7: BFMCS Int Construction and Final Theorem [NOT STARTED]

- **Dependencies:** Phase 4, Phase 6
- **Goal:** Prove `fully_saturated_bfmcs_exists_int` without sorry

**Tasks:**
- [ ] **Task 7.1:** Define `pullbackBFMCS : BFMCS (BidirectionalFragment M0 h_mcs0) -> BFMCS Int` applying pullbackFMCS to all families
- [ ] **Task 7.2:** Prove `pullbackBFMCS_temporally_coherent`: all families remain temporally coherent in Int version
- [ ] **Task 7.3:** Prove `pullbackBFMCS_modally_saturated`: modal saturation preserved (witnesses map correctly)
- [ ] **Task 7.4:** Prove `pullbackBFMCS_preserves_context`: Gamma in eval_family.mcs 0
- [ ] **Task 7.5:** Replace sorry in `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:600) with:
  ```lean
  -- Given Gamma consistent, apply fragment_completeness, then pullbackBFMCS
  let B_fragment := fragment_completeness_theorem Gamma h_cons
  exact pullbackBFMCS B_fragment
  ```
- [ ] **Task 7.6:** Verify `standard_weak_completeness` is sorry-free (chain: fully_saturated_bfmcs_exists_int -> construct_saturated_bfmcs_int -> standard_weak_completeness)
- [ ] **Task 7.7:** Verify `standard_strong_completeness` is sorry-free

**Timing:** 4-6 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (remove sorry)
- `Theories/Bimodal/Metalogic/Bundle/FragmentToInt.lean` (extend)

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` returns empty (for completeness files)
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/` returns only deprecated DovetailingChain sorries
- `lean_verify` on `standard_weak_completeness` shows no `sorry` axiom dependency

---

### Phase 8: Cleanup and Documentation [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Document the completeness proof, archive deprecated modules, create implementation summary

**Tasks:**
- [ ] **Task 8.1:** Add module docstrings to FragmentCompleteness.lean, FragmentEnumeration.lean, FragmentToInt.lean
- [ ] **Task 8.2:** Mark DovetailingChain.lean as deprecated in module header (sorries bypassed, not resolved)
- [ ] **Task 8.3:** Update TODO.md with completion status
- [ ] **Task 8.4:** Create implementation summary `summaries/implementation-summary-YYYYMMDD.md`
- [ ] **Task 8.5:** Final `lake build` verification
- [ ] **Task 8.6:** Git commit with complete changelog

**Timing:** 2-3 hours

**Files to modify:**
- New module files (docstrings)
- `Theories/Bimodal/Metalogic/Canonical/DovetailingChain.lean` (deprecation notice)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` (new)

**Verification:**
- All new files have module docstrings
- Deprecated modules marked
- Implementation summary created

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors throughout all phases
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean Theories/Bimodal/Metalogic/Bundle/FragmentEnumeration.lean Theories/Bimodal/Metalogic/Bundle/FragmentToInt.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` returns empty (after Phase 7)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"
- [ ] `lean_verify` on `standard_weak_completeness` shows no `sorry` in axiom list

### Regression Tests
- [ ] Soundness theorems still compile (`Theories/Bimodal/Metalogic/Bundle/Soundness.lean`)
- [ ] Decidability infrastructure still compiles
- [ ] No new imports break existing modules

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (new, ~400-600 lines)
- `Theories/Bimodal/Metalogic/Bundle/FragmentEnumeration.lean` (new, ~200-300 lines)
- `Theories/Bimodal/Metalogic/Bundle/FragmentToInt.lean` (new, ~300-400 lines)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (modified, sorry removed)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

**If Phase 4 (fragment-level completeness) fails:**
- Fragment-level infrastructure is isolated in new files
- Existing TemporalCoherentConstruction.lean unchanged
- Roll back by deleting new files; no regression

**If Phase 5 (fragment enumeration) fails:**
- The fragment may not be order-isomorphic to a subset of Int
- Contingency: Use fragment-indexed completeness without Int embedding (weaker theorem but still valuable)
- Alternative: Use `Order.embedding_from_countable_to_dense` into Q if fragment is dense (research suggests it's discrete)

**If Phase 6/7 (pullback to Int) fails:**
- Preserve fragment-level completeness theorem (Phases 2-4)
- Document the embedding gap as a research finding
- Mark task [BLOCKED] with user review for architectural decision

**Hard Blocker Escape:**
If proof stuck at any phase with no path forward:
- Mark phase [BLOCKED] with `requires_user_review: true`
- Document the mathematical obstacle
- User decides: pursue algebraic path (Jonsson-Tarski, 150-300h), pruning path (200-500h), or accept partial result
