# Dead Ends Section Audit - Teammate B Findings

**Task**: 934 - audit_roadmap_strategies_dead_ends_accuracy
**Date**: 2026-02-26
**Role**: Teammate B - Dead Ends Section Audit
**Session**: sess_1772128991_e7a991

## Summary

The Dead Ends section of `specs/ROAD_MAP.md` contains 8 entries. All 8 describe genuine dead ends with accurate rationales and lessons. However, 4 of the 8 entries have broken or incorrect evidence paths, and 1 entry contains a minor terminological inaccuracy. Tasks 928-933 archival actions are documented, but the Cross-Origin Coherence entry contains stale references (the active code path it cites was moved to Boneyard by task 928). Several undocumented Boneyard items exist in `Boneyard/Bundle/` that are not Dead Ends entries but represent discrete failed approaches.

---

## Existing Dead Ends Analysis

### Dead End: Boneyard Decidability Infrastructure

**Accurate?**: Mostly Yes
**Issues**: Broken evidence path. The link `Theories/Boneyard/Metalogic_v2/Decidability/` is incorrect. The directory `Theories/Boneyard/` does not exist.
**Evidence**:
- Actual path: `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/` (verified present, contains 9 files: Tableau.lean, Saturation.lean, DecisionProcedure.lean, etc.)
- Path in ROAD_MAP.md: `Theories/Boneyard/Metalogic_v2/Decidability/` (missing `Bimodal/` prefix)
- The rationale and lesson are accurate: decidability infrastructure was superseded by the parametric FMP approach

**Required Fix**: Change `Theories/Boneyard/Metalogic_v2/Decidability/` to `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/`

---

### Dead End: Single-History FDSM Construction

**Accurate?**: Mostly Yes
**Issues**: Broken evidence path. The archive slug does not match.
**Evidence**:
- Path cited: `specs/archive/825_fdsm_construction/reports/research-002.md`
- Actual path: `specs/archive/825_fdsm_multi_history_modal_saturation/reports/research-001.md` (verified)
- The slug `825_fdsm_construction` does not exist. The actual task 825 slug is `825_fdsm_multi_history_modal_saturation`.
- The rationale (single-history trivializes Box semantics, requires multi-history) is accurate.
- The FDSM_SingleHistory directory exists in Boneyard: `Theories/Bimodal/Boneyard/FDSM_SingleHistory/Core.lean`

**Required Fix**: Update archive path to `specs/archive/825_fdsm_multi_history_modal_saturation/reports/research-001.md`

---

### Dead End: Cross-Origin Coherence Proofs

**Accurate?**: Partially - stale paths from post-task-928 archival
**Issues**: Two broken paths and a stale active-file reference:

1. **Stale active file reference**: The evidence cites `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` as the location of "documented sorries for Cases 2,3". However, task 928 moved `CoherentConstruction.lean` to `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean`. The file no longer exists in the active `Metalogic/Representation/` directory (which now only contains `README.md`).

2. **Wrong task slug for task 814 reference**: The entry cites `specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/reports/` but task 814's actual slug is `814_classical_propositional_completeness_infrastructure`. That task was about classical propositional sorries in BMCS, not CoherentConstruction Cases 2 & 3. The correct research task for the cross-origin analysis is task 808 (`808_audit_coherentconstruction_taskrelation_sorries`), which found that cross-origin cases are non-blocking.

3. **Related Tasks field**: Lists `Task 814`. Should likely be `Task 808` based on task content.

**Evidence**:
- `CoherentConstruction.lean` confirmed at: `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean` and `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/CoherentConstruction.lean`
- Task 814 archive confirmed at: `specs/archive/814_classical_propositional_completeness_infrastructure/` (topic: classical propositional sorries, not cross-origin coherence)
- Task 808 archive confirmed at: `specs/archive/808_audit_coherentconstruction_taskrelation_sorries/` (topic: audit of CoherentConstruction sorries, determined 15 sorries including cross-origin cases are non-blocking)

**Required Fixes**:
- Update `CoherentConstruction.lean` reference to Boneyard path
- Correct task reference from `Task 814` / `814_sorry_reduction_coherentconstruction_cases_2_3` to `Task 808` / `808_audit_coherentconstruction_taskrelation_sorries`

---

### Dead End: Original IndexedMCSFamily.construct_indexed_family

**Accurate?**: Yes
**Issues**: None found. Minor note: the evidence path `specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/reports/` appears here as well (same broken slug as Cross-Origin entry), but the task 753 path is correct.
**Evidence**:
- Task 753 archive verified: `specs/archive/753_prove_sorries_in_coherentconstruction/` (confirmed present)
- The rationale (two-chain design makes coherence definitional) is accurate
- The Superseded By reference to CoherentConstruction is accurate (replaced by the two-chain design)
- Secondary reference to `814_sorry_reduction_coherentconstruction_cases_2_3` is the same broken slug as in Cross-Origin entry

**Required Fix**: Correct the `814_sorry_reduction_coherentconstruction_cases_2_3` slug to `808_audit_coherentconstruction_taskrelation_sorries` (same fix as Cross-Origin entry)

---

### Dead End: CanonicalReachable/CanonicalQuotient Stack

**Accurate?**: Yes
**Issues**: None. All evidence paths verified.
**Evidence**:
- `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/` exists with: `CanonicalEmbedding.lean`, `CanonicalQuotient.lean`, `CanonicalReachable.lean`, `LegacyCanonicalFMCS.lean`
- `specs/933_research_alternative_canonical_construction/reports/research-001.md` exists (verified)
- Tasks 922, 923, 933 all verified as present in `specs/`
- The rationale (backward_P witnesses not necessarily future-reachable from origin) matches the task 933 research findings
- Superseded By (`canonicalMCSBFMCS` all-MCS approach) is accurate

---

### Dead End: MCS-Membership Semantics for Box

**Accurate?**: Yes
**Issues**: None. All evidence paths verified.
**Evidence**:
- `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean` confirmed present
- `specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/summaries/implementation-summary-20260225.md` confirmed present
- Tasks 925 and 931 referenced correctly
- The rationale (non-standard semantics creates soundness/completeness gap) is accurate

---

### Dead End: Constant Witness Family Approach

**Accurate?**: Yes
**Issues**: None. All evidence paths verified.
**Evidence**:
- `Theories/Bimodal/Boneyard/Metalogic_v7/Bundle/ConstantWitnessFamily_ModalSaturation.lean` confirmed present
- `specs/932_remove_constant_witness_family_metalogic/summaries/implementation-summary-20260225.md` confirmed present
- The rationale (constant families cannot satisfy forward_F/backward_P) matches the Boneyard file header
- Task 932 referenced correctly

---

### Dead End: Single-Family BFMCS modal_backward

**Accurate?**: Mostly Yes - minor terminological inaccuracy
**Issues**: The entry claims "This is equivalent to the T-axiom `phi → Box(phi)`". This is incorrect terminology. The T-axiom (defined in the codebase as `Axiom.modal_t`) is `Box(phi) → phi`, not `phi → Box(phi)`. The direction `phi → Box(phi)` (what this dead end is about) is a different, unnamed formula that is indeed not provable in TM logic.

The underlying claim - that single-family modal_backward is unprovable in TM logic - is correct. Only the label "T-axiom" is wrong.

**Evidence**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` line 94: `modal_t` is `Formula.box φ |>.imp φ` (i.e., Box(phi) → phi)
- `Theories/Bimodal/Boneyard/Metalogic_v7/Bundle/SingleFamilyBFMCS.lean` header confirms: "phi in MCS → Box phi in MCS ... equivalent to phi -> Box phi, which is FALSE"
- The Boneyard file itself uses `Axiom.modal_t` in the `modal_forward` proof (line 37) - correctly using Box(phi) → phi for the OTHER direction
- `specs/archive/905_cleanup_metalogic_for_task_903/` confirmed present in archive
- `Theories/Bimodal/Boneyard/Metalogic_v7/Bundle/SingleFamilyBFMCS.lean` confirmed present

**Required Fix**: Change "T-axiom `phi → Box(phi)`" to "`phi → Box(phi)` (converse of T-axiom, unprovable in TM)" or simply "the principle `phi → Box(phi)` which TM does not include".

---

## Missing Dead Ends

Several Boneyard items are not documented as Dead Ends. These are primarily in `Theories/Bimodal/Boneyard/Bundle/`:

### Undocumented but potentially dead-end-worthy

| Boneyard File | Approach | Status |
|---------------|----------|--------|
| `Boneyard/Bundle/ZornFamily.lean` | Zorn's lemma for globally coherent FMCS (alternative to DovetailingChain) | Unclear if abandoned or still potential |
| `Boneyard/Bundle/SeedBFMCS.lean` | Seed-based BFMCS avoiding cross-sign propagation | Has self-description suggesting it resolved DovetailingChain blockers |
| `Boneyard/Bundle/FinalConstruction.lean` | Combining modal saturation + temporal coherence | Could be abandoned approach |
| `Boneyard/Bundle/SaturatedConstruction.lean` | Alternative saturation | Unclear |
| `Boneyard/Bundle/UnifiedChain.lean` | Unified chain (both GContent and HContent seeds) | Alternative to DovetailingChain |
| `Boneyard/Bundle/RecursiveSeed/` | Recursive seed construction (archived from Metalogic/Bundle) | Archived, superseded by TemporalCoherentConstruction |
| `Boneyard/Bundle/PreCoherentBundle.lean` | Pre-Coherent Bundle (marked MATHEMATICALLY BLOCKED in header) | Dead end candidate |
| `Boneyard/Bundle/WeakCoherentBundle.lean` | WeakBMCS to eliminate saturated_extension_exists axiom | Alternative approach |
| `Boneyard/Bundle/TemporalChain.lean`, `TemporalLindenbaum.lean`, `SeedCompletion.lean` | Various temporal construction attempts | No Dead End entry |

### Already covered by existing Dead End entries

| Boneyard File | Covered By |
|---------------|-----------|
| `Boneyard/Bundle/MCSMembershipCompleteness.lean` | Dead End: MCS-Membership Semantics for Box |
| `Boneyard/Bundle/CanonicalQuotientApproach/` | Dead End: CanonicalReachable/CanonicalQuotient Stack |
| `Boneyard/Bundle/CoherentConstruction.lean` | Dead End: Cross-Origin Coherence Proofs (after fix) |
| `Boneyard/Metalogic_v7/Bundle/SingleFamilyBFMCS.lean` | Dead End: Single-Family BFMCS modal_backward |
| `Boneyard/Metalogic_v7/Bundle/ConstantWitnessFamily_ModalSaturation.lean` | Dead End: Constant Witness Family Approach |
| `Boneyard/Metalogic_v2/Decidability/` | Dead End: Boneyard Decidability Infrastructure |
| `Boneyard/FDSM_SingleHistory/` | Dead End: Single-History FDSM Construction |

### Older Boneyard approaches (pre-existing, lower priority)

The `SyntacticApproach.lean`, `DurationConstruction.lean`, and `DeprecatedCompleteness.lean` at the top level of the Boneyard are documented in `Boneyard/README.md` but have no Dead End entries. These are older (pre-task 800) approaches that may deserve entries for completeness.

---

## Completeness for Tasks 928-933

| Task | Claim | Verified? | Notes |
|------|-------|-----------|-------|
| Task 928 | Moved CoherentConstruction to Boneyard | Yes | CoherentConstruction.lean now at `Boneyard/Bundle/` and `Boneyard/Metalogic_v5/Representation/`. However, the Cross-Origin Dead End still cites the old active path. |
| Task 931 | Moved MCS-membership semantics to Boneyard | Yes | `Boneyard/Bundle/MCSMembershipCompleteness.lean` verified. Dead End entry is accurate. |
| Task 932 | Moved constant witness family approach to Boneyard | Yes | `Boneyard/Metalogic_v7/Bundle/ConstantWitnessFamily_ModalSaturation.lean` verified. Dead End entry is accurate. |
| Task 933 | Moved CanonicalReachable/CanonicalQuotient to Boneyard | Yes | `Boneyard/Bundle/CanonicalQuotientApproach/` verified with 4 files. Dead End entry is accurate. |

The Dead Ends section was updated to include all four task 928-933 archival actions. The entries for tasks 931, 932, and 933 are accurate and complete. The entry for task 928 (Cross-Origin Coherence) is outdated in that it still references the pre-928 active file path.

---

## Recommended Additions/Corrections

### Priority 1 - Fix Broken Paths (High Impact)

1. **Boneyard Decidability Infrastructure**: Fix path prefix
   - Change: `Theories/Boneyard/Metalogic_v2/Decidability/`
   - To: `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/`

2. **Single-History FDSM Construction**: Fix archive slug
   - Change: `specs/archive/825_fdsm_construction/reports/research-002.md`
   - To: `specs/archive/825_fdsm_multi_history_modal_saturation/reports/research-001.md`

3. **Cross-Origin Coherence Proofs**: Fix stale file path and task reference
   - Change evidence path from `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
   - To: `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean`
   - Change `Related Tasks: Task 814` to `Related Tasks: Task 808`
   - Change evidence reference from `specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/`
   - To: `specs/archive/808_audit_coherentconstruction_taskrelation_sorries/`

4. **Original IndexedMCSFamily.construct_indexed_family**: Fix same task 814 reference
   - Change `specs/archive/814_sorry_reduction_coherentconstruction_cases_2_3/`
   - To: `specs/archive/808_audit_coherentconstruction_taskrelation_sorries/`

### Priority 2 - Fix Terminological Inaccuracy (Medium Impact)

5. **Single-Family BFMCS modal_backward**: Fix T-axiom mislabeling
   - Change: "This is equivalent to the T-axiom `phi → Box(phi)`"
   - To: "This requires `phi → Box(phi)` (the converse of the T-axiom), which TM logic does not have."

### Priority 3 - Add Missing Dead Ends (Lower Priority)

6. Consider adding Dead End entry for `RecursiveSeed` approach (archived, superseded by TemporalCoherentConstruction)
7. Consider adding Dead End entry for `PreCoherentBundle` (self-described as MATHEMATICALLY BLOCKED)
8. Consider adding Dead End entries for `SyntacticApproach`, `DurationConstruction` from top-level Boneyard (documented in Boneyard/README.md but not in ROAD_MAP.md Dead Ends)

---

## Confidence Level

**high** - All evidence paths verified against actual filesystem. Task summaries and Boneyard file headers cross-referenced. The 4 broken paths are confirmed broken. The terminological issue with T-axiom is confirmed via `ProofSystem/Axioms.lean`. The task 928-933 archival completeness is verified by checking both the Boneyard directories and the Dead End entries.
