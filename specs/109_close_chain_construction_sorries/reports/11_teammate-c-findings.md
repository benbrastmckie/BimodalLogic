# Teammate C: Branch Diff Comparison -- `until` vs `irr_until`

## 1. Overall Diff Statistics

| Metric | Value |
|--------|-------|
| Files changed | 36 |
| Lines added (until -> irr_until) | 2,956 |
| Lines removed (until -> irr_until) | 2,899 |
| Net change | +57 lines |
| Files identical between branches | ~130 (vast majority) |

### Largest Diffs (by file)

| File | Change |
|------|--------|
| `BXCanonical/RootScopedChain.lean` | 1,734 lines changed (1681 -> 229) |
| `Metalogic/SoundnessLemmas.lean` | 862 lines changed (refactoring) |
| `Boneyard/DefectDirectedChain/RootScopedChain.lean` | +1,556 lines (archived copy) |
| `Metalogic/Soundness.lean` | 388 lines changed |
| `BXCanonical/CanonicalModel.lean` | 298 lines changed (498 -> 376) |
| `Semantics/Truth.lean` | 136 lines changed |

## 2. Semantic Definitions Comparison (Truth.lean)

The core semantic change is a systematic replacement of reflexive with irreflexive operators:

| Operator | `until` branch | `irr_until` branch |
|----------|---------------|-------------------|
| `all_past` (H) | `s <= t` (reflexive) | `s < t` (strict) |
| `all_future` (G) | `t <= s` (reflexive) | `t < s` (strict) |
| `untl` witness | `t <= s` | `t < s` |
| `untl` guard | `t <= r` and `r < s` i.e. [t,s) | `t <= r` and `r < s` i.e. [t,s) |
| `snce` witness | `s <= t` | `s < t` |
| `snce` guard | `s < r` and `r <= t` i.e. (s,t] | `s < r` and `r <= t` i.e. (s,t] |

Key observation: The Until/Since **guards** are identical ([t,s) and (s,t]). Only the **witness constraint** changed from reflexive to strict. This is the "A2 guard convention."

## 3. Axiom System Comparison (Axioms.lean)

| Aspect | `until` (37 constructors) | `irr_until` (35 constructors) |
|--------|--------------------------|-------------------------------|
| BX1/BX1' | `temp_t_future/past` (G(phi)->phi) | `serial_future/past` (T->F(T), T->P(T)) |
| BX2/BX2' | `G(phi->chi) -> ...` | `(phi->chi) /\ G(phi->chi) -> ...` (strengthened for half-open guard) |
| BX8/BX8' | `refl_intro_until/since` (psi -> phi U psi) | **REMOVED** (not sound under strict witness) |
| All others | Identical formulas | Identical formulas |

Summary: `irr_until` removed 2 axioms (BX8/BX8'), replaced 2 axioms (BX1/BX1' reflexivity -> seriality), and strengthened 2 axioms (BX2/BX2' left monotonicity now requires conjunction).

## 4. RootScopedChain.lean Comparison

| Aspect | `until` | `irr_until` |
|--------|---------|-------------|
| Lines | 1,681 | 229 |
| Sorries | 7 | 3 (+ 1 in comment) |
| Architecture | Defect-directed chain with `f_carry`/`p_carry`, BX11 fold, `FF_imp_F` derivation | Schedule-based wrapper over `bx_bfmcs` from CanonicalModel.lean |
| Key content | Full defect-discharge construction with round-robin scheduling | Thin wrapper delegating to `shifted_bx_fmcs` |

**What happened**: The 1,452-line defect-directed chain from `until` was archived to `Boneyard/DefectDirectedChain/RootScopedChain.lean` on `irr_until` (1,556 lines in the Boneyard copy). It was replaced with a minimal schedule-based approach.

**Critical finding**: The defect-discharge approach was declared "provably unfixable due to Classical.choice opacity in the BX11 fold." However, this diagnosis was made under irreflexive semantics. Under reflexive semantics (where BX1: G(phi)->phi is available), the `enriched_seed_consistent` proof in CanonicalModel.lean works because `g_content M <= M` follows from `temp_t_future`. This is exactly what's present on the `until` branch.

### Sorry locations on `until` RootScopedChain:
1. Line 1111: `fwd_chain_forward_F` -- F-resolution in forward chain
2. Line 1138: `dd_bfmcs_restricted_tc` backward chain cross-region case
3. Line 1145: `dd_bfmcs_restricted_tc` P-resolution direction
4. Line 1153: `dd_bfmcs_restricted_buc` -- backward Until/Since coherence
5. Line 1160: `dd_bfmcs_restricted_fuc` -- forward Until/Since coherence

### Sorry locations on `irr_until` RootScopedChain:
1. Line 186: `bx_bfmcs_restricted_tc` -- temporal coherence
2. Line 193: `bx_bfmcs_restricted_buc` -- backward Until/Since coherence
3. Line 198: `bx_bfmcs_restricted_fuc` -- forward Until/Since coherence

Both branches have the **same fundamental blockers**: restricted temporal coherence (F/P-resolution) and restricted Until/Since coherence.

## 5. Shared Sorry-Free Infrastructure

These files are **identical** between branches and carry forward without modification:

### Core Infrastructure (all sorry-free, identical)
- All of `Syntax/` (Formula, Atom, Context, SubformulaClosure, etc.)
- `Semantics/TaskFrame.lean`, `Semantics/TaskModel.lean`, `Semantics/WorldHistory.lean`
- All of `Theorems/` (Combinators, Perpetuity, Propositional, ModalS4, ModalS5, etc.)
- `ProofSystem/Derivation.lean`, `ProofSystem/Substitution.lean`, `ProofSystem/LinearityDerivedFacts.lean`
- All of `Automation/`
- `Metalogic/Core/` (MCSProperties, MaximalConsistent, DeductionTheorem, RestrictedMCS)
- `Metalogic/Algebraic/` (most files: BooleanStructure, InteriorOperators, LindenbaumQuotient, ParametricCanonical, ParametricRepresentation, TenseS5Algebra, UltrafilterMCS, AlgebraicRepresentation)
- `Metalogic/Bundle/` (BFMCS, FMCS, WitnessSeed, UntilSinceCoherence, TemporalContent, CanonicalTaskRelation, CanonicalFrame, ModalSaturation)
- `BXCanonical/OrderedSeedConsistency.lean` (255 lines, sorry-free, IDENTICAL)
- `BXCanonical/Filtration/DefectChain.lean`
- `BXCanonical/Quasimodel/` (EnrichedClosure, HintikkaPoint, LocusControl, SubformulaClosure)
- All of `Metalogic/Decidability/` (FMP, Tableau, etc.)
- All of `Metalogic/ConservativeExtension/`

**Total identical files**: ~130 out of ~166 Lean source files.

## 6. Files on `until` but NOT on `irr_until`

| File | Description |
|------|-------------|
| `BXCanonical/Boneyard/OracleCoherence.lean` | Moved to `Boneyard/QuasimodelOracle/` |
| `BXCanonical/Boneyard/RoundRobinChain.lean` | Moved to `Boneyard/QuasimodelOracle/` |
| `BXCanonical/Quasimodel/OracleStep.lean` | Moved to `Boneyard/QuasimodelOracle/` |

These were organizational moves, not deletions. All three files exist on `irr_until` under `Boneyard/QuasimodelOracle/`.

## 7. Files on `irr_until` but NOT on `until`

| File | Description |
|------|-------------|
| `Boneyard/DeadCanonicalModel/EnrichedSeedLegacy.lean` | Archived dead code from CanonicalModel refactor |
| `Boneyard/DefectDirectedChain/RootScopedChain.lean` | Archived defect-directed chain (1,556 lines) |
| `Boneyard/QuasimodelOracle/OracleCoherence.lean` | Moved from BXCanonical/Boneyard |
| `Boneyard/QuasimodelOracle/OracleStep.lean` | Moved from BXCanonical/Quasimodel |
| `Boneyard/QuasimodelOracle/README.md` | New README |
| `Boneyard/QuasimodelOracle/RoundRobinChain.lean` | Moved from BXCanonical/Boneyard |

**Assessment**: The only substantive new file is `EnrichedSeedLegacy.lean` (90 lines of dead code). The defect-directed chain Boneyard copy is the `until` branch's `RootScopedChain.lean`. Nothing here is needed for the reflexive approach.

## 8. Soundness Comparison

| Aspect | `until` | `irr_until` |
|--------|---------|-------------|
| `Soundness.lean` sorries | 0 (4 mentions in comments only) | 0 (4 mentions in comments only) |
| `SoundnessLemmas.lean` sorries | 0 | 0 |
| Both sorry-free | YES | YES |

### Nature of changes:
- **Soundness.lean**: Systematic `<= -> <` replacements, `le_refl`/`le_trans` -> `lt_trans`/`exists_gt`. Replaced `temp_t_future_valid`/`temp_t_past_valid` with `serial_future_axiom_valid`/`serial_past_axiom_valid`. Added `Nontrivial D` type constraint. Removed BX8/BX8' soundness cases. Modified BX2/BX2' for conjunction-strengthened axiom.
- **SoundnessLemmas.lean**: Replaced ~63 lines with `<=` by ~45 lines with `<`. Replaced `temp_t` references with `serial` references. Rewrote `swap_axiom_tl_valid` proof (shorter, cleaner under strict semantics). All changes are semantic (reflexive -> irreflexive).

**Portability assessment**: The `irr_until` soundness is a clean, complete rewrite for irreflexive semantics. It CANNOT be ported back to `until` directly -- the proofs depend on strict inequalities. However, the structural improvements (cleaner proof of `swap_axiom_tl_valid`, dead code removal) could inspire improvements to the `until` version.

## 9. The Boneyard

| Boneyard content | `until` | `irr_until` |
|-----------------|---------|-------------|
| BundleTemporalCoherence/ | Identical | Identical |
| ChainCompleteness/ | Identical | Identical |
| DiscreteXY/ | Identical | Identical |
| RoundRobinChain/ | Identical | Identical |
| StrictSemanticsLegacy/ | Identical | Identical |
| TAxiomDependentCode/ | Identical | Identical |
| UltrafilterDeadCode/ | Identical | Identical |
| BXCanonical/Boneyard/ | 2 files (OracleCoherence, RoundRobinChain) | Empty (moved) |
| QuasimodelOracle/ | N/A | 4 files (moved from BXCanonical) |
| DeadCanonicalModel/ | N/A | 1 file (EnrichedSeedLegacy) |
| DefectDirectedChain/ | N/A | 1 file (archived RootScopedChain) |

## 10. Sorry Inventory Comparison

### Non-Boneyard Metalogic/ sorries

| File | `until` | `irr_until` | Delta |
|------|---------|-------------|-------|
| `Algebraic/InteriorOperators.lean` | 1 | 1 | 0 |
| `Algebraic/LindenbaumQuotient.lean` | 2 | 2 | 0 |
| `Algebraic/ParametricTruthLemma.lean` | 0 | 4 | **+4** |
| `Algebraic/TenseS5Algebra.lean` | 3 | 3 | 0 |
| `BXCanonical/BXCanonical.lean` | 2 | 0 | -2 (comments) |
| `BXCanonical/CanonicalChain.lean` | 1 | 1 | 0 |
| `BXCanonical/CanonicalModel.lean` | 2 | 0 | **-2** |
| `BXCanonical/Completeness.lean` | 1 | 2 | +1 (mostly comments) |
| `BXCanonical/Filtration/SigmaOrdering.lean` | 1 | 4 | **+3** |
| `BXCanonical/Frame.lean` | 1 | 2 | **+1** |
| `BXCanonical/Quasimodel/Construction.lean` | 1 | 3 | **+2** |
| `BXCanonical/Quasimodel/OracleStep.lean` | 23 | N/A | -23 (moved to Boneyard) |
| `BXCanonical/Quasimodel/Realization.lean` | 1 | 5 | **+4** |
| `BXCanonical/RootScopedChain.lean` | 7 | 4 | -3 |
| `BXCanonical/TruthLemma.lean` | 1 | 4 | **+3** |
| `Bundle/CanonicalFrame.lean` | 1 | 1 | 0 |
| `Bundle/Construction.lean` | 3 | 3 | 0 |
| `Bundle/ModalSaturation.lean` | 1 | 1 | 0 |
| `Bundle/SuccExistence.lean` | 1 | 4 | **+3** |
| `Bundle/SuccRelation.lean` | 1 | 3 | **+2** |
| `Bundle/TemporalCoherence.lean` | 2 | 2 | 0 |
| `ConservativeExtension/ExtDerivation.lean` | 9 | 9 | 0 |
| `ConservativeExtension/Lifting.lean` | 12 | 12 | 0 |
| **TOTAL (actual sorry calls)** | **~53** | **~58** | **+5** |

**Key observation**: Excluding the OracleStep.lean move (23 sorries -> Boneyard) and comments, `until` has FEWER active sorries in the completeness pipeline. The `irr_until` branch introduced new sorries in ParametricTruthLemma (+4), SigmaOrdering (+3), Frame (+1), TruthLemma (+3), Realization (+4), Construction (+2), SuccExistence (+3), SuccRelation (+2) -- all consequences of the irreflexive semantics switch breaking proofs.

## 11. Merge Strategy Recommendation

### Option Analysis

| Strategy | Effort | Risk | Result |
|----------|--------|------|--------|
| **A. Switch to `until` branch, continue** | Low | Low | Best starting point for reflexive completeness |
| B. Cherry-pick irr_until improvements to `until` | Medium | Medium | Gets soundness cleanup but most changes are semantic |
| C. New branch from `until` + selective irr_until | Medium | Low | Cleaner but same as A with extra steps |
| D. Merge irr_until back into until | High | High | Semantic conflicts everywhere |

### Recommendation: **Option A -- Switch to `until` and continue**

**Rationale**:

1. **The soundness improvements from `irr_until` are NOT portable** -- they are fundamentally tied to irreflexive semantics (`<` vs `<=`). The `until` branch already has sorry-free soundness.

2. **The irr_until branch ADDED sorries** compared to `until` in: ParametricTruthLemma, SigmaOrdering, Frame, TruthLemma, Realization, Construction, SuccExistence, SuccRelation. These were all working on `until` and broke during the irreflexive switch.

3. **The key infrastructure is already on `until`**: OrderedSeedConsistency (sorry-free), the defect-directed chain (1,681 lines with 7 sorries), and the `enriched_seed_consistent` proof using BX1 (G(phi)->phi).

4. **The Boneyard material from `irr_until`** (DefectDirectedChain, EnrichedSeedLegacy) would be irrelevant on `until` -- it IS the `until` branch's live code.

5. **130 out of ~166 files are IDENTICAL** between branches. The divergence is entirely in semantic definitions (Truth, Axioms), soundness proofs, and the chain construction pipeline.

6. **When it's time to build irreflexive completeness**, the `irr_until` branch can serve as a reference for: the axiom changes, the semantic definitions, the seriality approach, and the SoundnessLemmas restructuring. But this is a future step.

### Concrete Action Items

1. `git checkout until` -- switch to reflexive branch
2. Continue from the 7 sorries in RootScopedChain.lean (defect-discharge chain)
3. The critical path is: `fwd_chain_forward_F` (F-resolution) -> `restricted_tc` -> `restricted_buc/fuc`
4. Later: create `irr_until_v2` branch from completed reflexive completeness

## Confidence Level

**HIGH (9/10)**. The data is unambiguous:
- The branches diverge cleanly at the semantic level
- The `until` branch has fewer sorries in the completeness pipeline
- The `irr_until` branch's contributions (soundness cleanup, dead code archival) are either not portable or not needed for reflexive work
- Switching to `until` is safe and reversible
