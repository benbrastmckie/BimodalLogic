# Implementation Plan: Audit and Close SoundnessLemmas.lean Sorries

- **Task**: 108 - Audit 28 sorry occurrences in SoundnessLemmas.lean
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None (self-contained file with known call sites)
- **Research Inputs**: specs/108_audit_soundness_lemmas_sorries/reports/01_soundness-sorry-audit.md
- **Artifacts**: plans/01_soundness-sorry-closure.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

SoundnessLemmas.lean contains 24 sorry occurrences (8 active, 16 block-commented). All 8 active sorries are closeable under irreflexive semantics: 4 standalone lemma sorries with verified proof sketches, and 4 master dispatch theorem sorries fixable by uncommenting block-commented proof bodies with targeted edits. The general-version master theorems require adding `[Nontrivial D]` to their signatures, which cascades cleanly to call sites in Soundness.lean that already have the constraint available.

### Research Integration

The research report (01_soundness-sorry-audit.md) provided verified proof sketches for `swap_axiom_tl_valid` and `axiom_temp_l_valid`, identified the `le_trans` to `lt_trans` mechanical fix in `temp_4` cases, confirmed that `until_step`/`since_step` cases are dead code (BX8/BX8' removed), and determined that serial axiom cases need `exists_gt`/`exists_lt` from `Nontrivial + AddCommGroup`. All findings are integrated into the phase structure below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

The ROADMAP notes Soundness.lean/DenseSoundness.lean/DiscreteSoundness.lean are "entirely sorry-free" (line 1008-1012). Closing SoundnessLemmas.lean sorries strengthens the soundness infrastructure and removes sorry sites from the active source tree. This task is parallelizable with the critical completeness path (task 93).

## Goals & Non-Goals

**Goals**:
- Close all 8 active sorries in SoundnessLemmas.lean
- Uncomment and fix the 4 master dispatch theorem proof bodies
- Add `[Nontrivial D]` to general-version signatures and update call sites
- Remove dead `until_step`/`since_step` cases from uncommented code
- Achieve clean `lake build` with zero sorries in SoundnessLemmas.lean (active code)

**Non-Goals**:
- Removing block-commented code entirely (block comments serve as documentation)
- Modifying the axiom system or frame conditions
- Addressing sorries in other files beyond cascading signature changes

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Serial axiom proof harder than expected under `Nontrivial + AddCommGroup` | M | L | Proof approach well-understood; `exists_gt`/`exists_lt` are standard Mathlib lemmas |
| Signature change cascades beyond Soundness.lean | M | L | Research confirmed only Soundness.lean uses the general versions; all call sites already have `Nontrivial D` |
| Block-commented code has hidden issues beyond identified fixes | M | M | Build after each master theorem uncommenting; the proofs are mostly complete per research |
| Linearity axiom encoding requires complex classical logic manipulation | M | M | Follow the verified pattern from block-commented swap linearity proofs (lines 743-786) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Close Standalone Lemma Sorries [COMPLETED]

**Goal**: Close the 4 standalone lemma sorries (#1-4) using verified proof sketches from research.

**Tasks**:
- [ ] Close `swap_axiom_tl_valid` (line 316) using the verified proof from the research report: `simp only` on `Formula.always` encoding, extract future/present/past via `Classical.byContradiction`, then `lt_trichotomy` dispatch
- [ ] Close `axiom_temp_l_valid` (line 918) using the same pattern adapted for the non-swap case
- [ ] Close `axiom_temp_linearity_valid` (line 951) using existential extraction from `some_future` encoding and `lt_trichotomy` on witnesses s1, s2 (following the pattern from block-commented swap linearity proofs at lines 743-786)
- [ ] Close `axiom_temp_linearity_past_valid` (line 961) as mirror of the above for past direction
- [ ] Run `lake build` to verify all 4 standalone lemma proofs compile cleanly

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Replace 4 sorry sites with proofs

**Verification**:
- `lake build` succeeds
- `grep -n "sorry" SoundnessLemmas.lean` shows 4 fewer active sorries (from 8 to 4)

---

### Phase 2: Uncomment and Fix Dense Master Dispatch Theorems [IN PROGRESS]

**Goal**: Restore the proof bodies for `axiom_swap_valid` and `axiom_locally_valid` (dense versions with `[DenselyOrdered D] [Nontrivial D]`), applying the identified fixes.

**Tasks**:
- [ ] Uncomment the block-commented proof body for `axiom_swap_valid` (line 467)
- [ ] Delete `until_step`/`since_step` dead cases (lines ~705, 710 in the commented block)
- [ ] Fix `le_trans` to `lt_trans` in the `temp_4` case (line ~528 in the commented block)
- [ ] Close `serial_future`/`serial_past` cases using `exists_between` or `NoMaxOrder`/`NoMinOrder` derived from `DenselyOrdered D` + `Nontrivial D`
- [ ] Remove the top-level `sorry` and verify the theorem compiles
- [ ] Repeat for `axiom_locally_valid` (line 1008): uncomment, delete dead cases, fix mechanical issues, close serial cases
- [ ] Run `lake build` to verify both dense master theorems compile

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Uncomment and fix 2 master theorems

**Verification**:
- `lake build` succeeds
- `axiom_swap_valid` and `axiom_locally_valid` are sorry-free
- Active sorry count reduced from 4 to 2

---

### Phase 3: Uncomment and Fix General Master Dispatch Theorems [NOT STARTED]

**Goal**: Restore the proof bodies for `axiom_swap_valid_general` and `axiom_locally_valid_general`, adding `[Nontrivial D]` to signatures and updating downstream theorems.

**Tasks**:
- [ ] Add `[Nontrivial D]` to the signature of `axiom_swap_valid_general` (line 1365)
- [ ] Uncomment the block-commented proof body
- [ ] Delete `until_step`/`since_step` dead cases
- [ ] Fix `le_trans` to `lt_trans` in `temp_4` case
- [ ] Close `serial_future`/`serial_past` cases using `exists_gt`/`exists_lt` from `Nontrivial + AddCommGroup + LinearOrder + IsOrderedAddMonoid`
- [ ] Remove the top-level `sorry` and verify compilation
- [ ] Repeat for `axiom_locally_valid_general` (line 1641)
- [ ] Add `[Nontrivial D]` to downstream signatures: `derivable_valid_and_swap_valid_general` (line 1865) and `derivable_implies_swap_valid_general` (line 1903)
- [ ] Run `lake build` to catch any further cascading signature changes

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Uncomment and fix 2 general master theorems, update 2 downstream signatures

**Verification**:
- `lake build` succeeds
- All 4 master dispatch theorems are sorry-free
- Active sorry count in SoundnessLemmas.lean is 0

---

### Phase 4: Update Call Sites and Final Verification [NOT STARTED]

**Goal**: Update call sites in Soundness.lean for the `[Nontrivial D]` signature change and verify clean compilation of the full project.

**Tasks**:
- [ ] Check Soundness.lean call sites (lines ~1047, 1267, 1323) for compatibility with `[Nontrivial D]` addition (research indicates they already have it in scope)
- [ ] Fix any call sites that need explicit `[Nontrivial D]` annotation
- [ ] Run full `lake build` to verify entire project compiles cleanly
- [ ] Run `grep -c sorry SoundnessLemmas.lean` and verify the count is reduced to only block-commented occurrences (16 expected)
- [ ] Verify no regressions in Soundness.lean, DenseSoundness.lean, or DiscreteSoundness.lean

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Update call sites if needed
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Any final adjustments

**Verification**:
- Full `lake build` succeeds with zero errors
- `grep sorry SoundnessLemmas.lean` shows only block-commented occurrences
- `grep sorry Soundness.lean` shows zero occurrences
- No regressions in other Metalogic files

## Testing & Validation

- [ ] `lake build` succeeds with no errors after each phase
- [ ] Zero active sorries remain in SoundnessLemmas.lean
- [ ] All 4 master dispatch theorems (`axiom_swap_valid`, `axiom_locally_valid`, `axiom_swap_valid_general`, `axiom_locally_valid_general`) compile without sorry
- [ ] Downstream theorems (`derivable_valid_and_swap_valid_general`, `derivable_implies_swap_valid_general`) compile with updated signatures
- [ ] No regressions in Soundness.lean, DenseSoundness.lean, DiscreteSoundness.lean

## Artifacts & Outputs

- `specs/108_audit_soundness_lemmas_sorries/plans/01_soundness-sorry-closure.md` (this plan)
- Modified: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (all 8 active sorries closed)
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (call site updates if needed)

## Rollback/Contingency

All changes are confined to SoundnessLemmas.lean and potentially Soundness.lean. If any phase introduces regressions, `git checkout` of those two files restores the previous state. Each phase builds on the previous, so partial progress is preserved: completed phases remain valid even if a later phase is blocked.
