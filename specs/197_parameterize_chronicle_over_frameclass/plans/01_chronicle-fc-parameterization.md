# Implementation Plan: Parameterize Chronicle Construction over FrameClass

- **Task**: 197 - Parameterize chronicle construction over FrameClass
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: 168 (DerivationTree parameterization -- completed)
- **Research Inputs**: specs/197_parameterize_chronicle_over_frameclass/reports/01_chronicle-fc-parameterization.md
- **Artifacts**: plans/01_chronicle-fc-parameterization.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Thread an `fc : FrameClass` parameter through the Chronicle construction pipeline (6 files in BXCanonical/Chronicle/, 4 files in WeakCanonical/) to replace the hardcoded `FrameClass.Base` that makes it impossible to use discrete axioms (z1, prior_UZ, prior_SZ with minFrameClass = .Discrete) in the chronicle construction. The change is approximately 95% mechanical (replacing `FrameClass.Base` with `fc` across ~700 references in ~14 files) and 5% structural (adding `variable (fc : FrameClass)` declarations, updating type signatures, and replacing 6 `sorry` terms with `h_fc` proofs). The existing `trivial` proofs for base axiom gates remain valid for any `fc` since `Base <= fc` is always `True`. Definition of done: all 6 sorry entries replaced with proper `h_fc` proofs, `lake build` passes, no new sorries introduced.

### Research Integration

The research report (01_chronicle-fc-parameterization.md) provides:
- Complete inventory of all 6 sorry locations with exact proof obligations (all are `Discrete <= Base = False`)
- FrameClass partial order analysis showing `Base <= fc` is `True` for all `fc`
- Per-file reference counts: ChronicleTypes (16), RRelation (103), PointInsertion (344), CounterexampleElimination (39), ChronicleConstruction (71), ChronicleToCountermodel (124), ReflexiveCanonical (24), TruthLemma (29), ChronicleExtraction (6)
- Full dependency chain from ChronicleTypes through to Completeness.lean
- Critical insight: almost all derivation trees in the chronicle use only base axioms, so `trivial` proofs survive parameterization unchanged
- Key design decision: do NOT carry `h_base_le : FrameClass.Base <= fc` as an explicit hypothesis (it is always `True`); only carry `h_fc : .Discrete <= fc` at the 6 sorry locations

### Prior Plan Reference

No prior plan. Task 168's implementation pattern (bottom-up parameterization through the dependency chain) serves as a proven reference approach.

### Roadmap Alignment

This task directly unblocks the 6 sorry workarounds introduced by task 168 and noted in its completion summary. It advances the completeness pipeline toward sorry-free `bx_completeness` (the Phase 1a objective in TODO.md).

## Goals & Non-Goals

**Goals**:
- Replace all 6 fc-mismatch sorries with proper `h_fc` proofs
- Parameterize the entire Chronicle pipeline over `fc : FrameClass`
- Parameterize the WeakCanonical layer (ReflexiveCanonical, TruthLemma, FrameProperties, ChronicleExtraction) over `fc`
- Preserve existing behavior: dense pipeline instantiates at `.Base`, discrete pipeline at `.Discrete`
- `lake build` passes with zero new sorries

**Non-Goals**:
- Fixing the `succ_cofinal` sorry (a separate genuine mathematical gap, task 129/155)
- Parameterizing files outside the Chronicle and WeakCanonical pipelines
- Changing the `Chronicle` data structure itself (it is pure data, no fc dependency)
- Adding new frame class variants or axioms
- Optimizing build times

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Typeclass resolution breaks with parameterized ReflCanDomain | H | M | Test CoeSort instance early in Phase 6; the instance is simple (`fun x => x.val`) and should not depend on fc |
| succ_cofinal sorry accidentally disturbed | H | L | Explicit exclusion from scope; verify `sorry` count at ChronicleToCountermodel.lean:1508,1285,1441,1889 unchanged after Phase 5 |
| PointInsertion.lean (344 refs, 3527 lines) causes cascading type errors | M | M | Work bottom-up so upstream files compile first; use `lake build` per-phase verification |
| ChronicleAsPriorModel API change breaks IntegerModel/NEquivalence | M | M | Phase 7 explicitly handles downstream consumers; API change is mechanical (add `fc` param) |
| Implicit fc in namespace-level variables causes elaboration issues | M | L | Follow task 168 pattern: use explicit parameters, not namespace-level `variable` declarations |
| Build time per phase is long due to 14K-line directory | L | H | Accept long rebuilds; work bottom-up to minimize recompilation cascades |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 5, 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. This is a fully sequential plan due to the strict bottom-up dependency chain in the Chronicle pipeline.

---

### Phase 1: ChronicleTypes.lean Foundation [COMPLETED]

**Goal**: Parameterize the foundational types and conditions in ChronicleTypes.lean over `fc : FrameClass`, establishing the base that all downstream files build upon.

**Tasks**:
- [ ] Add `variable (fc : FrameClass)` or explicit `(fc : FrameClass)` parameter to `ClosedUnderDerivation` (line ~69-71), changing `DerivationTree FrameClass.Base L phi` to `DerivationTree fc L phi`
- [ ] Parameterize `SetDeductivelyClosed` (line ~82-83), changing `SetConsistent (fc := .Base) S` to `SetConsistent (fc := fc) S`
- [ ] Update `mcs_is_dcs` (line ~86) to use parameterized types
- [ ] Parameterize `Chronicle.c0` condition (line ~385-386), changing `SetMaximalConsistent (fc := .Base) (chi.f x)` to `SetMaximalConsistent (fc := fc) (chi.f x)`
- [ ] Update all consistency lemmas (lines ~642-685) from `SetConsistent (fc := .Base)` to `SetConsistent (fc := fc)`
- [ ] Leave the `Chronicle` data structure itself unchanged (pure data, no fc dependency)
- [ ] Verify all ~16 `FrameClass.Base` references updated
- [ ] Run `lake build` and verify ChronicleTypes.lean compiles (downstream files may have errors -- that is expected)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` - Replace ~16 `FrameClass.Base` refs with `fc` parameter

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleTypes` compiles
- `grep -c "FrameClass.Base" ChronicleTypes.lean` returns 0 (or only in comments)

---

### Phase 2: RRelation.lean [COMPLETED]

**Goal**: Thread `fc` through the r-relation, deductive closure, and related lemmas in RRelation.lean.

**Tasks**:
- [ ] Parameterize all function signatures that take `h_mcs : SetMaximalConsistent (fc := .Base)` to use `(fc := fc)`
- [ ] Update all `DerivationTree FrameClass.Base` references to `DerivationTree fc`
- [ ] Update all `ClosedUnderDerivation` and `SetDeductivelyClosed` references to use `fc`
- [ ] Verify that existing `trivial` proofs for base axiom gates still close (they should since `Base <= fc` is `True` for all `fc`)
- [ ] Update all ~103 `FrameClass.Base` references
- [ ] Run `lake build` and verify RRelation.lean compiles

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` - Replace ~103 `FrameClass.Base` refs with `fc`

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.RRelation` compiles
- No new `sorry` introduced (grep check)

---

### Phase 3: PointInsertion.lean [COMPLETED]

**Goal**: Thread `fc` through all point insertion functions and lemmas. This is the largest single file by reference count (344 refs).

**Tasks**:
- [ ] Parameterize all function signatures over `fc`
- [ ] Replace all `SetMaximalConsistent (fc := .Base)` with `SetMaximalConsistent (fc := fc)`
- [ ] Replace all `DerivationTree FrameClass.Base` with `DerivationTree fc`
- [ ] Replace all `SetConsistent (fc := .Base)` with `SetConsistent (fc := fc)`
- [ ] Verify all `trivial` proofs for base axiom gates still work
- [ ] Update all ~344 `FrameClass.Base` references
- [ ] Run `lake build` and verify PointInsertion.lean compiles

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Replace ~344 `FrameClass.Base` refs with `fc`

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion` compiles
- No new `sorry` introduced

---

### Phase 4: CounterexampleElimination.lean and ChronicleConstruction.lean [COMPLETED]

**Goal**: Thread `fc` through counterexample elimination and the chronicle construction (omega-chain, limit chronicle, limit lemmas). These are combined in one phase because CounterexampleElimination feeds directly into ChronicleConstruction and both are on the same dependency tier.

**Tasks**:
- [ ] **CounterexampleElimination.lean**: Replace all ~39 `FrameClass.Base` references with `fc`
- [ ] Parameterize all elimination function signatures over `fc`
- [ ] Verify `trivial` proofs for base axiom gates still work
- [ ] Run `lake build` for CounterexampleElimination.lean
- [ ] **ChronicleConstruction.lean**: Replace all ~71 `FrameClass.Base` references with `fc`
- [ ] Parameterize `singleton_c0`, `singleton_invariant`, `omega_chain_val`, `limit_dom`, `limit_f`, `limit_c0`, `limit_f_zero`, `limit_satisfies_c5_strong` over `fc`
- [ ] Verify all `trivial` proofs for base axiom gates still work
- [ ] Run `lake build` for ChronicleConstruction.lean

**Timing**: 2.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` - Replace ~39 refs
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` - Replace ~71 refs

**Verification**:
- Both files compile via `lake build`
- No new `sorry` introduced in either file

---

### Phase 5: ChronicleToCountermodel.lean (fix sorry #6) [COMPLETED]

**Goal**: Thread `fc` through the largest Chronicle file and fix sorry #6 (z1_derivation). This phase requires special care to NOT disturb the existing `succ_cofinal` sorry and other intentional sorries.

**Tasks**:
- [ ] Record the current sorry count and locations in ChronicleToCountermodel.lean before starting (expected: sorries at lines ~1285, ~1441, ~1508, ~1529, ~1889)
- [ ] Parameterize `LimitDomSubtype` (line ~76) over `fc`
- [ ] Parameterize `limitDomSubtype_succOrder` and related functions over `fc`
- [ ] Parameterize `cantor_bfmcs_discrete`, `rooted_succ_discrete_fmcs` over `fc`
- [ ] Parameterize `dd_countermodel_chronicle_discrete` (line ~3289) over `fc`
- [ ] **Fix sorry #6**: Change `z1_derivation` (line ~1527-1529) from:
  ```lean
  private def z1_derivation (phi : Formula) :
      DerivationTree FrameClass.Base [] (z1_formula phi) :=
    DerivationTree.axiom [] _ (Axiom.z1 phi) sorry
  ```
  to:
  ```lean
  private def z1_derivation (fc : FrameClass) (h_fc : FrameClass.Discrete <= fc) (phi : Formula) :
      DerivationTree fc [] (z1_formula phi) :=
    DerivationTree.axiom [] _ (Axiom.z1 phi) h_fc
  ```
- [ ] Update `z1_in_mcs` (line ~1533) to pass `h_fc` through
- [ ] Replace all remaining ~124 `FrameClass.Base` references with `fc`
- [ ] DO NOT modify the `succ_cofinal` sorry (line ~1508/1889) -- verify it remains unchanged
- [ ] DO NOT modify other intentional sorries (lines ~1285, ~1441) -- verify they remain unchanged
- [ ] Run `lake build` and verify ChronicleToCountermodel.lean compiles
- [ ] Verify sorry count: the z1_derivation sorry at line ~1529 should be gone; all other sorries should remain exactly as before

**Timing**: 3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Replace ~124 refs, fix sorry #6

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` compiles
- Sorry #6 eliminated (z1_derivation uses `h_fc` instead of `sorry`)
- `succ_cofinal` sorry at line ~1508/1889 unchanged
- Other intentional sorries at lines ~1285, ~1441 unchanged

---

### Phase 6: WeakCanonical Layer -- ReflexiveCanonical.lean and TruthLemma.lean [COMPLETED]

**Goal**: Parameterize the reflexive canonical model and truth lemma over `fc`. This enables the downstream sorry fixes in Phase 7.

**Tasks**:
- [ ] **ReflexiveCanonical.lean**: Parameterize `ReflCanDomain` over `fc`:
  ```lean
  def ReflCanDomain (fc : FrameClass) : Type :=
    { S : Set Formula // SetMaximalConsistent (fc := fc) S }
  ```
- [ ] Update `CoeSort ReflCanDomain` instance to work with parameterized type
- [ ] Update `ReflCanDomain.mcs` to return `SetMaximalConsistent (fc := fc)`
- [ ] Update `ReflCanDomain.ext` for parameterized type
- [ ] Parameterize `g_content`, `g_w_content`, `h_content` and all other functions taking `ReflCanDomain` over `fc`
- [ ] Parameterize `reflCanR`, `tempR_fwd`, and all canonical relations over `fc`
- [ ] Update all ~24 `FrameClass.Base` references
- [ ] Run `lake build` for ReflexiveCanonical.lean
- [ ] **TruthLemma.lean**: Add `fc` parameter throughout
- [ ] Update all derivation tree constructions from `DerivationTree FrameClass.Base` to `DerivationTree fc`
- [ ] Verify all `trivial` proofs for base axiom gates still close (all use only base axioms)
- [ ] Update all ~29 `FrameClass.Base` references
- [ ] Run `lake build` for TruthLemma.lean

**Timing**: 2.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Parameterize ReflCanDomain and all functions (~24 refs)
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Thread `fc` through truth lemma (~29 refs)

**Verification**:
- Both files compile via `lake build`
- No new `sorry` introduced
- `ReflCanDomain fc` correctly parameterized with working CoeSort instance

---

### Phase 7: Fix Remaining 5 Sorries -- FrameProperties.lean and ChronicleExtraction.lean [IN PROGRESS]

**Goal**: Fix sorries #1-5 by leveraging the parameterized infrastructure from Phases 1-6. Update downstream consumers (IntegerModel, NEquivalence, WeakCanonical).

**Tasks**:
- [ ] **FrameProperties.lean -- Fix sorries #1-3**: Update theorems to take `(fc : FrameClass)` and `(h_fc : FrameClass.Discrete <= fc)`:
  - [ ] `z1_in_frame`: Change `sorry` to `h_fc` in `DerivationTree.axiom [] _ (Axiom.z1 psi) h_fc`
  - [ ] `prior_UZ_in_frame`: Change `sorry` to `h_fc` in `DerivationTree.axiom [] _ (Axiom.prior_UZ psi) h_fc`
  - [ ] `prior_SZ_in_frame`: Change `sorry` to `h_fc` in `DerivationTree.axiom [] _ (Axiom.prior_SZ psi) h_fc`
- [ ] Run `lake build` for FrameProperties.lean and verify all 3 sorries eliminated
- [ ] **ChronicleExtraction.lean -- Fix sorries #4-5**: Update functions to take `(fc : FrameClass)` and `(h_fc : FrameClass.Discrete <= fc)`:
  - [ ] `prior_UZ_in_limit_domain`: Change `sorry` to `h_fc`
  - [ ] `prior_SZ_in_limit_domain`: Change `sorry` to `h_fc`
- [ ] Parameterize `DiscreteHypothesis`, `ChronicleAsPriorModel.root_mcs`, `ChronicleAsPriorModel.fmcs_is_mcs`, `extract_chronicle_as_prior` over `fc`
- [ ] Update remaining ~6 `FrameClass.Base` references in ChronicleExtraction.lean
- [ ] Run `lake build` for ChronicleExtraction.lean and verify both sorries eliminated
- [ ] **Downstream consumers**: Update signatures in files that import the changed modules:
  - [ ] `IntegerModel.lean` - Update `ChronicleAsPriorModel` usage to pass `fc`
  - [ ] `NEquivalence.lean` - Update `ChronicleAsPriorModel` usage to pass `fc`
  - [ ] `WeakCanonical.lean` (if it imports FrameProperties) - Update calls
- [ ] Run `lake build` for all downstream consumer files

**Timing**: 3 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/FrameProperties.lean` - Fix sorries #1-3 (3 sorry -> h_fc)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` - Fix sorries #4-5 (2 sorry -> h_fc), parameterize ~6 refs
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Update ChronicleAsPriorModel calls
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Update ChronicleAsPriorModel calls
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` - Update imports/calls (if needed)

**Verification**:
- All 5 sorries (#1-5) eliminated from FrameProperties.lean and ChronicleExtraction.lean
- All downstream consumers compile
- No new `sorry` introduced

---

### Phase 8: Integration, Instantiation Sites, and Final Verification [NOT STARTED]

**Goal**: Update the top-level instantiation sites (Transfer.lean, Completeness.lean), verify the full build, and confirm all 6 sorries are eliminated with no new sorries introduced.

**Tasks**:
- [ ] **Transfer.lean**: Update `countermodel_discrete` and any other functions that call into the parameterized Chronicle pipeline to pass `fc := .Discrete` (and `h_fc := le_refl .Discrete` or `trivial`)
- [ ] Update `FrameClass.Base` references in Transfer.lean (currently ~1 ref)
- [ ] **Completeness.lean**: Update `dd_countermodel_chronicle_discrete` call to pass `fc := .Discrete`; update any `FrameClass.Base` references (~30 refs)
- [ ] Verify that dense pipeline calls still pass `.Base` (or `.Dense`) and work unchanged
- [ ] Verify that the mixed case (`dd_countermodel_chronicle_mixed_sorry`) still works at `.Base` via `False.elim`
- [ ] Run full `lake build` -- entire project must compile
- [ ] Verify sorry elimination:
  - [ ] `grep -rn "sorry" FrameProperties.lean` returns 0 results
  - [ ] `grep -rn "sorry" ChronicleExtraction.lean` returns 0 results (for the fc-mismatch sorries)
  - [ ] `grep -rn "sorry" ChronicleToCountermodel.lean` -- z1_derivation sorry gone; succ_cofinal and other intentional sorries remain
- [ ] Verify no new sorries: `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/*.lean Theories/Bimodal/Metalogic/WeakCanonical/*.lean` and compare against pre-task baseline
- [ ] Verify `succ_cofinal` sorry at ChronicleToCountermodel.lean is undisturbed

**Timing**: 2 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Update instantiation calls (~1 ref)
- `Theories/Bimodal/Metalogic/Completeness.lean` - Update discrete countermodel calls (~30 refs)

**Verification**:
- Full `lake build` passes
- All 6 fc-mismatch sorries eliminated:
  1. FrameProperties.lean:25 (z1) -- GONE
  2. FrameProperties.lean:34 (prior_UZ) -- GONE
  3. FrameProperties.lean:41 (prior_SZ) -- GONE
  4. ChronicleExtraction.lean:62 (prior_UZ) -- GONE
  5. ChronicleExtraction.lean:73 (prior_SZ) -- GONE
  6. ChronicleToCountermodel.lean:1529 (z1) -- GONE
- No new sorries introduced in any file
- `succ_cofinal` sorry preserved (intentional, separate mathematical gap)
- Dense pipeline still works at `.Base`
- Mixed pipeline still works via `False.elim`

## Testing & Validation

- [ ] Full `lake build` passes with zero errors
- [ ] All 6 fc-mismatch sorries replaced with `h_fc` proofs
- [ ] No new `sorry` introduced (diff-based grep comparison against pre-task state)
- [ ] `succ_cofinal` sorry and other intentional sorries preserved unchanged
- [ ] Dense countermodel (`dd_countermodel_chronicle_dense`) still works at `fc = .Base`
- [ ] Discrete countermodel (`dd_countermodel_chronicle_discrete`) works at `fc = .Discrete`
- [ ] Mixed countermodel (`dd_countermodel_chronicle_mixed_sorry`) still works via `False.elim` at `fc = .Base`
- [ ] ReflCanDomain parameterized type with working CoeSort instance
- [ ] `#check @dd_countermodel_chronicle_discrete` shows `fc` parameter in signature

## Artifacts & Outputs

- `specs/197_parameterize_chronicle_over_frameclass/plans/01_chronicle-fc-parameterization.md` (this plan)
- `specs/197_parameterize_chronicle_over_frameclass/summaries/01_chronicle-fc-parameterization-summary.md` (post-implementation)
- Modified files (12-14 total):
  - 6 files in `Metalogic/BXCanonical/Chronicle/`
  - 4 files in `Metalogic/WeakCanonical/`
  - 1-2 files in `Metalogic/` (Completeness.lean)
  - 1 file in `Metalogic/WeakCanonical/` (Transfer.lean)

## Rollback/Contingency

If implementation fails mid-phase:
- Each phase is independently compilable (bottom-up order ensures this)
- `git stash` or `git checkout` to revert to last known-good state
- Partial progress can be committed at phase boundaries
- If the parameterization approach causes unforeseen typeclass issues with `ReflCanDomain`, fallback strategy: keep `ReflCanDomain` at `.Base` and create separate `ReflCanDomainDiscrete` type alias at `.Discrete` for the 6 sorry-containing theorems only (less elegant but avoids cascading ReflexiveCanonical changes)
