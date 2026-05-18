# Implementation Plan: Rename Metalogical Theorems to Standard Names

- **Task**: 166 - Rename major metalogical theorems to standard uniform names and create new completeness_dense/completeness_discrete theorems
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/166_rename_metalogical_theorems_standard_names/reports/01_metalogical-naming-hygiene.md
- **Artifacts**: plans/01_metalogical-naming-hygiene.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task normalizes the naming of major metalogical theorems in the ProofChecker codebase to follow a consistent `{concept}_{frame_class}` convention. The primary renames are: `bx_completeness` to `completeness`, `dd_countermodel_chronicle_dense` to `countermodel_dense`, `doets_countermodel_discrete` to `countermodel_discrete`, and axiom validity name normalization (`axiom_base_valid` to `axiom_valid`, `axiom_valid_dense` to `axiom_dense_valid`, `axiom_valid_discrete` to `axiom_discrete_valid`). Two new standalone completeness theorems (`completeness_dense`, `completeness_discrete`) will be created, each duplicating the shared MCS preamble from `bx_completeness` and calling the appropriate countermodel builder directly. The `soundness` name is kept as-is.

### Research Integration

The research report (01_metalogical-naming-hygiene.md) provided:
- Complete inventory of all 8 soundness theorems and 7 completeness theorems with file locations and line numbers
- Cross-reference map of all call sites (50+ test sites for `soundness`, 3-4 sites for `bx_completeness`, etc.)
- Frame constraint hierarchy analysis (Linear -> Serial -> Dense/Discrete)
- Identification that `DenseSoundness.lean` already contains `axiom_dense_valid` as a re-export (aligning with the target name)
- Architectural analysis of the `bx_completeness` proof showing the 3-way case split structure and MCS preamble that must be factored into the new completeness theorems

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- This task aligns with ROADMAP Phase 2 ("Frame hierarchy + axiom cleanup") which calls for standardizing the four-tier hierarchy naming
- Advances the naming hygiene prerequisite for publication quality (ROADMAP Phase 5)

## Goals & Non-Goals

**Goals**:
- Rename `bx_completeness` to `completeness` and `bx_completeness'` to `completeness'`
- Rename `dd_countermodel_chronicle_dense` to `countermodel_dense`
- Rename `doets_countermodel_discrete` to `countermodel_discrete`
- Rename `axiom_base_valid` to `axiom_valid`
- Rename `axiom_valid_dense` to `axiom_dense_valid`
- Rename `axiom_valid_discrete` to `axiom_discrete_valid`
- Create new `completeness_dense` theorem: `valid_dense phi -> Nonempty (DerivationTree [] phi)`
- Create new `completeness_discrete` theorem: `valid_discrete phi -> Nonempty (DerivationTree [] phi)`
- Update all call sites, docstrings, `#print axioms` references, and README tables
- Keep `soundness` name unchanged

**Non-Goals**:
- Renaming `soundness` (explicitly kept as-is per user decision)
- Renaming internal helper theorems or lemmas not in the public API
- Removing sorry obligations from completeness theorems
- Reorganizing module structure or moving files
- Creating `soundness_serial_valid` (the serial analogue of `soundness_dense_valid`)
- Renaming FrameConditions wrapper names beyond what is needed for consistency

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `completeness_dense` proof requires non-trivial MCS preamble duplication | M | M | Follow the exact structure of `bx_completeness` lines 131-168; the MCS steps are straightforward |
| Dense case may need `h_box_dense` premise that is not obviously derivable from `valid_dense` | H | M | Research shows `bx_completeness` derives it from `negation_complete` on the MCS; `completeness_dense` will need to derive it differently or the dense case may be direct since all models are dense |
| Namespace collisions after rename (e.g., `FrameConditions.soundness_dense` vs `Metalogic.soundness_dense`) | L | L | The rename targets are in different namespaces; verify with `lake build` |
| `axiom_valid` name may collide with existing definitions | M | L | Search confirmed no existing `axiom_valid` definition; the closest is `axiom_base_valid_linear` in FrameConditions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Rename Completeness Theorems and Countermodels [COMPLETED]

**Goal**: Rename the completeness theorem and countermodel existence theorems to their standard names, updating all call sites.

**Tasks**:
- [x] Rename `bx_completeness` to `completeness` in `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (line 131)
- [x] Rename `bx_completeness'` to `completeness'` in the same file (line 173)
- [x] Update `bx_completeness` references in:
  - [x] Completeness.lean docstrings and comments (lines 15, 30, 124, 131, 175, 184, 225, 236)
  - [x] `#print axioms` statement (line 236): update fully-qualified name
  - [x] WeakCanonical/TruthLemma.lean comment references (lines 36, 399, 430, 440, 457, 484, 492, 555, 571)
  - [x] ChronicleToCountermodel.lean comment reference (line 824)
  - [x] WeakCanonical/WeakCanonical.lean docstrings (lines 29, 33)
  - [x] README.md table (line 146): `bx_completeness` to `completeness`
  - [x] Theories/Bimodal/README.md references *(deviation: skipped -- no references found)*
  - [x] Metalogic/Metalogic.lean docstring *(deviation: skipped -- no references found)*
- [x] Rename `dd_countermodel_chronicle_dense` to `countermodel_dense` in `ChronicleToCountermodel.lean` (line 793)
- [x] Update `dd_countermodel_chronicle_dense` references in:
  - [x] Completeness.lean line 155 (call site inside `completeness`)
  - [x] Completeness.lean `#print axioms` (line 238)
  - [x] README.md table (line 147)
  - [x] ROADMAP.md reference (line 26)
- [x] Rename `doets_countermodel_discrete` to `countermodel_discrete` in `WeakCanonical/Transfer.lean` (line 312)
- [x] Update `doets_countermodel_discrete` references in:
  - [x] Completeness.lean line 162 (call site inside `completeness`)
  - [x] WeakCanonical/WeakCanonical.lean docstrings (lines 29, 33)
  - [x] Transfer.lean docstring/comments (line 13, line 288)
- [x] Run `lake build` to verify no compilation errors

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - rename `bx_completeness`/`bx_completeness'`, update call sites to renamed countermodels
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - rename `dd_countermodel_chronicle_dense`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - rename `doets_countermodel_discrete`
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - update comment references
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` - update docstrings
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update docstrings
- `README.md` - update Result Details table
- `Theories/Bimodal/README.md` - update completeness references
- `specs/ROADMAP.md` - update theorem name reference

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "bx_completeness\|dd_countermodel_chronicle_dense\|doets_countermodel_discrete" Theories/ README.md` returns zero matches (excluding Boneyard)

---

### Phase 2: Normalize Axiom Validity Naming [NOT STARTED]

**Goal**: Rename the axiom validity theorems to follow consistent `axiom_{frame_class}_valid` word order, and rename `axiom_base_valid` to `axiom_valid`.

**Tasks**:
- [ ] Rename `axiom_base_valid` to `axiom_valid` in `Soundness.lean` (line 893)
- [ ] Update `axiom_base_valid` references in:
  - [ ] Soundness.lean docstrings (lines 34, 44, 61)
  - [ ] FrameConditions/Soundness.lean `axiom_base_valid_linear` body (line 121) -- calls `axiom_base_valid`
  - [ ] Theories/Bimodal/README.md (line 148)
  - [ ] FrameConditions/Compatibility.lean comment references (lines 121-154 use `axiom_base_valid_linear` which calls `axiom_base_valid`)
- [ ] Rename `axiom_valid_dense` to `axiom_dense_valid` in `Soundness.lean` (line 943)
- [ ] Update `axiom_valid_dense` references in:
  - [ ] Soundness.lean internal call (line 1197, inside `soundness_dense_valid`)
  - [ ] DenseSoundness.lean body (line 48) -- calls `axiom_valid_dense`
  - [ ] DenseSoundness.lean docstrings (lines 14, 44)
  - [ ] FrameConditions/Soundness.lean `axiom_valid_dense_fc` body (line 132) -- calls `axiom_valid_dense`
  - [ ] Decidability/Correctness.lean comment (line 21)
  - [ ] Theories/Bimodal/README.md (line 157)
- [ ] Rename `axiom_valid_discrete` to `axiom_discrete_valid` in `Soundness.lean` (line 993)
- [ ] Update `axiom_valid_discrete` references in:
  - [ ] Soundness.lean internal calls (lines 1368, 1432, inside `soundness_discrete_valid` and `soundness_discrete`)
  - [ ] DiscreteSoundness.lean body (line 49) -- calls `axiom_valid_discrete`
  - [ ] DiscreteSoundness.lean docstrings (lines 14, 45)
  - [ ] FrameConditions/Soundness.lean `axiom_valid_discrete_fc` body (line 144) -- calls `axiom_valid_discrete`
  - [ ] Decidability/Correctness.lean comment (line 22)
  - [ ] Theories/Bimodal/README.md (line 166)
  - [ ] Boneyard reference (non-critical, update if convenient)
- [ ] Run `lake build` to verify no compilation errors

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - rename all three axiom validity theorems + update internal references
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` - update call to `axiom_valid_dense` and docstrings
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - update call to `axiom_valid_discrete` and docstrings
- `Theories/Bimodal/FrameConditions/Soundness.lean` - update calls in `axiom_base_valid_linear`, `axiom_valid_dense_fc`, `axiom_valid_discrete_fc`
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - update comments
- `Theories/Bimodal/README.md` - update axiom validity names in Logic Variants section

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "axiom_base_valid\b\|axiom_valid_dense\b\|axiom_valid_discrete\b" Theories/` returns zero matches outside Boneyard (note: `axiom_base_valid_linear` is a different name and stays)

---

### Phase 3: Create completeness_dense and completeness_discrete Theorems [NOT STARTED]

**Goal**: Create two new standalone completeness theorems that each duplicate the MCS preamble from `completeness` and call the appropriate countermodel builder for their frame class.

**Tasks**:
- [ ] Create `completeness_dense` in `BXCanonical/Completeness.lean`:
  - Signature: `theorem completeness_dense (phi : Formula) : valid_dense phi -> Nonempty (DerivationTree [] phi)`
  - Proof structure: contrapositive approach matching `completeness`:
    1. `by_contra` + `push_neg` to get `h_valid : valid_dense phi` and `h_not_deriv : IsEmpty ...`
    2. `neg_consistent_of_not_derivable` to get `{neg phi}` consistent
    3. `set_lindenbaum` to extend to MCS M with `neg phi in M`
    4. Call `countermodel_dense` (renamed from `dd_countermodel_chronicle_dense`) with M, phi, h_neg_in
    5. The dense case requires `h_box_dense : box (Chronicle.next_top.neg) in M`. Since `valid_dense` restricts to dense models, and the MCS M is over the full axiom system, derive `h_box_dense` from the MCS properties or handle the case where it is not present by showing that `valid_dense` still yields the needed contradiction
  - Will carry same sorry status as `countermodel_dense`
- [ ] Create `completeness_discrete` in `BXCanonical/Completeness.lean`:
  - Signature: `theorem completeness_discrete (phi : Formula) : valid_discrete phi -> Nonempty (DerivationTree [] phi)`
  - Proof structure: same MCS preamble, then call `countermodel_discrete`
  - The discrete case requires `h_box_discrete : box (Chronicle.next_top) in M`. Derive from MCS properties.
  - Will carry same sorry status as `countermodel_discrete`
- [ ] Add docstrings explaining these are frame-class-specific completeness theorems
- [ ] Update `#print axioms` section in Completeness.lean to include the new theorems
- [ ] Run `lake build` to verify compilation

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - add new theorems after `completeness'`

**Verification**:
- `lake build` passes with zero errors
- New theorems have correct type signatures (check with `lean_hover_info` or `#check`)
- The sorry obligations trace to the same leaf sorries as `completeness`

---

### Phase 4: Update Documentation and Final Verification [NOT STARTED]

**Goal**: Ensure all documentation (README tables, docstrings, module docs) accurately reflect the renamed theorems and new theorems.

**Tasks**:
- [ ] Update README.md Result Details table to include `completeness_dense` and `completeness_discrete`
- [ ] Update Theories/Bimodal/README.md:
  - [ ] TM Dense section: add `completeness_dense` reference
  - [ ] TM Discrete section: add `completeness_discrete` reference
  - [ ] Update the Result Details table with all new names
- [ ] Update Metalogic/Metalogic.lean Publication-Ready Results table to include new completeness theorems
- [ ] Update ROADMAP.md if discrete completeness row references have changed
- [ ] Verify that `FrameConditions/Soundness.lean` references are consistent (the wrapper `axiom_base_valid_linear` now calls `axiom_valid` -- ensure the docstring explains this)
- [ ] Run full `lake build` to confirm zero errors
- [ ] Run `grep -rn` for all old names to confirm no stale references remain (excluding Boneyard and dead code comments)

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Files to modify**:
- `README.md` - final table updates for new theorems
- `Theories/Bimodal/README.md` - comprehensive update of all theorem references
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update module docstring
- `specs/ROADMAP.md` - update discrete completeness reference
- `Theories/Bimodal/FrameConditions/Soundness.lean` - update docstrings for clarity

**Verification**:
- `lake build` passes with zero errors
- `grep -rn "bx_completeness\|dd_countermodel_chronicle_dense\|doets_countermodel_discrete\|axiom_base_valid\b\|axiom_valid_dense\b\|axiom_valid_discrete\b" Theories/ README.md` returns zero matches (excluding Boneyard)
- All README tables reflect current theorem names

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] All old theorem names produce zero grep matches in active code (excluding Boneyard)
- [ ] New `completeness_dense` and `completeness_discrete` theorems have correct type signatures
- [ ] `#print axioms completeness` still shows same axiom dependencies as before
- [ ] Test suite (`lake build Tests`) passes without modification (soundness name unchanged, completeness not used in tests)

## Artifacts & Outputs

- `specs/166_rename_metalogical_theorems_standard_names/plans/01_metalogical-naming-hygiene.md` (this plan)
- Modified Lean source files (listed per phase)
- Updated README.md and Theories/Bimodal/README.md

## Rollback/Contingency

All changes are pure renames and additions (no deletions of logic). Rollback via `git checkout` of the affected files. If `completeness_dense`/`completeness_discrete` proofs prove more complex than expected (e.g., deriving the `h_box_dense`/`h_box_discrete` premises), mark Phase 3 as [BLOCKED] and complete Phases 1, 2, 4 independently. The new theorems can use `sorry` for the premise derivation if the MCS argument is non-trivial, matching the existing sorry status of the backing countermodel theorems.
