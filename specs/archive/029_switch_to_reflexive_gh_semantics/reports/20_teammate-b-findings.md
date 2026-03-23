# Teammate B: Codebase Archaeology — All Irreflexive Artifacts

## Key Findings

1. **The IRR rule is deeply embedded**: The `DerivationTree.irr` constructor appears in the core proof system (`Derivation.lean:149`) and propagates to ~15 files that pattern-match on derivation trees.

2. **The `canonicalR_irreflexive_axiom` is already deprecated**: In `CanonicalIrreflexivity.lean:1492`, the axiom is marked as DEPRECATED with a note that it introduces an INCONSISTENCY (asserting both `CanonicalR M M` and `¬CanonicalR M M`). There are ~54 downstream call sites.

3. **The `canonicalR_reflexive` theorem already exists**: `CanonicalIrreflexivity.lean:1500` shows `canonicalR_reflexive` is proven. The file contains both the new reflexive proof and the deprecated irreflexive axiom.

4. **Three categories of IRR-related artifacts**:
   - **Core proof system** (must remove IRR constructor): 1 file
   - **Pattern-matching on IRR** (must update match arms): ~10 files
   - **Using `canonicalR_irreflexive`** (must switch to antisymmetry): ~10 files
   - **Boneyard** (already archived, no action): ~5 files

5. **IRRSoundness.lean already has a sorry** at line 322 noting the IRR rule is unsound under reflexive semantics.

## Complete Reference Inventory

### Core Proof System (Category a: Proof System Rule)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `ProofSystem/Derivation.lean` | 140-154 | `irr` constructor in `DerivationTree` | **REMOVE** constructor |
| `ProofSystem/Derivation.lean` | 200 | `.irr` in `height` | **REMOVE** match arm |
| `ProofSystem/Derivation.lean` | 291 | `.irr` in `isDenseCompatible` | **REMOVE** match arm |
| `ProofSystem/Derivation.lean` | 308 | `.irr` in `isDiscreteCompatible` | **REMOVE** match arm |

### Substitution (Category a: Proof infrastructure)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `ProofSystem/Substitution.lean` | 366-386 | `DerivationTree.irr` case in `derivation_subst` | **REMOVE** (has sorry) |

### Soundness & Sound Lemmas (Category d: Soundness proof)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Metalogic/Soundness.lean` | 4 | `import IRRSoundness` | **REMOVE** import |
| `Metalogic/Soundness.lean` | 604-606 | `.irr` case in `soundness_at` (sorry) | **REMOVE** match arm |
| `Metalogic/Soundness.lean` | 671-680 | `.irr` case in `soundness_dense_valid` | **REMOVE** match arm |
| `Metalogic/Soundness.lean` | 796-800 | `.irr` case in another soundness theorem | **REMOVE** match arm |
| `Metalogic/SoundnessLemmas.lean` | 961-963 | `.irr` case (sorry) | **REMOVE** match arm |
| `Metalogic/IRRSoundness.lean` | 1-324 (entire) | IRR soundness proof (has sorry) | **DELETE** entire file |

### Canonical Irreflexivity (Category c: Canonical model)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Metalogic/Bundle/CanonicalIrreflexivity.lean` | 1-1505 (entire) | Irreflexivity proofs + deprecated axiom | **MAJOR MODIFY** (keep reflexive proof, naming set infra, remove axiom + irr proofs) |
| `Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` | 1-101 (entire) | Re-export of `canonicalR_irreflexive` | **DELETE** or **RENAME** to CanonicalAntisymmetry |

### Deduction Theorem (Category e: Pattern matching)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Metalogic/Core/DeductionTheorem.lean` | 259-262 | `.irr` case | **REMOVE** match arm |

### MCS Properties (Category e: Pattern matching)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Metalogic/Core/MaximalConsistent.lean` | 150 | `.irr` in `usedFormulas` | **REMOVE** match arm |
| `Metalogic/Core/MaximalConsistent.lean` | 186-190 | `.irr` in `usedFormulas_subset` | **REMOVE** match arm |

### Conservative Extension (Category e: Pattern matching + IRR constructor)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | 100-105 | `ExtDerivationTree.irr` constructor | **REMOVE** constructor |
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | 175-176 | IRR embedding | **REMOVE** |
| `Metalogic/ConservativeExtension/ExtFormula.lean` | 306 | IRR embedding lemma | **REMOVE** |
| `Metalogic/ConservativeExtension/Lifting.lean` | 20-21, 118-147, 341-382, 397, 506, 563-582 | Multiple IRR-related lemmas and cases | **MODIFY** (remove all IRR cases) |

### Downstream `canonicalR_irreflexive` Call Sites (Category e: Completeness)

| File | Call Count | Action |
|------|------------|--------|
| `Metalogic/Bundle/FMCSTransfer.lean` | 2 calls (lines 234, 239) | **MODIFY** — switch to antisymmetry |
| `Metalogic/Canonical/CanonicalSerialFrameInstance.lean` | 2 calls (lines 77, 123) | **MODIFY** — switch to antisymmetry |
| `Metalogic/Algebraic/SaturatedChain.lean` | 8 calls (lines 370, 373, 401, 404, 446, 449, 459, 462) | **MODIFY** — switch to antisymmetry |
| `Metalogic/Domain/CanonicalDomain.lean` | refs in comments only | **MODIFY** — update comments |
| `Metalogic/Domain/DiscreteTimeline.lean` | import + comments | **MODIFY** — update import + comments |
| `Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` | 12 calls | **MODIFY** — switch to antisymmetry |
| `Metalogic/StagedConstruction/TimelineQuotCanonical.lean` | 1 call (line 96) | **MODIFY** — switch to antisymmetry |
| `Metalogic/StagedConstruction/ClosureSaturation.lean` | 2 calls (lines 391, 395) | **MODIFY** — switch to antisymmetry |
| `Metalogic/StagedConstruction/IncrementalTimeline.lean` | 1 call (line 156) | **MODIFY** — switch to antisymmetry |
| `Metalogic/StagedConstruction/CantorApplication.lean` | multiple calls + comments | **MODIFY** — switch to antisymmetry |
| `Metalogic/Algebraic/CanonicalQuot.lean` | 1 comment (line 68) | **MODIFY** — update comment |

### Syntax Layer (Category f/g: Infrastructure)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Syntax/Atom.lean` | 33-34, 192, 202-206 | `fresh_for`, IRR references in docs | **MODIFY** — update docs (Atom infrastructure still useful) |
| `Syntax/Formula.lean` | 487, 309, 318 | IRR references in comments | **MODIFY** — update comments |

### Documentation/Typst (Category f: Documentation)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `typst/chapters/06-notes.typ` | 142, 187, 218, 225, 241, 243, 254, 304, 330 | Discussion of IRR, irreflexivity | **MODIFY** — update to reflect reflexive semantics |
| `latex/subfiles/04-Metalogic.tex` | 149 | Footnote about G/H being irreflexive | **MODIFY** — update |

### Boneyard (Category g: Archived — NO ACTION)

| File | Pattern | Action |
|------|---------|--------|
| `Boneyard/Task956_StrictDensity/*.lean` | `irreflexive_mcs_has_strict_future` | **KEEP** (archived) |
| `Boneyard/Task971/*.lean` | irreflexive semantics references | **KEEP** (archived) |
| `Boneyard/Task970/*.lean` | irreflexive semantics references | **KEEP** (archived) |
| `Boneyard/Task994_DovetailedQuot/*.lean` | `canonicalR_irreflexive` calls | **KEEP** (archived) |
| `Boneyard/Task956_IntRat/*.lean` | irreflexive references | **KEEP** (archived) |
| `Boneyard/IntRepresentation/*.lean` | irreflexive references | **KEEP** (archived) |

### Other Module References (Category f: Comments/docs)

| File | Line(s) | Pattern | Action |
|------|---------|---------|--------|
| `Metalogic/Representation.lean` | 26, 33 | refs to CanonicalRIrreflexive | **MODIFY** — update |
| `Metalogic/Metalogic.lean` | 69 | Task 967 ref | **MODIFY** — update |
| `Metalogic/DenseSoundness.lean` | 18, 26 | irreflexive semantics refs | **MODIFY** — update |
| `Metalogic/DiscreteSoundness.lean` | 18, 25 | irreflexive semantics refs | **MODIFY** — update |
| `Metalogic/DenseCompleteness.lean` | 82 | Task 967 ref | **MODIFY** — update |
| `Metalogic/Canonical/ConstructiveFragment.lean` | 567 | import ref | **MODIFY** — update |
| `Metalogic/Canonical/README.md` | 10, 22 | irreflexivity mention | **MODIFY** — update |
| `Metalogic/Bundle/README.md` | 40 | CanonicalIrreflexivity ref | **MODIFY** — update |
| `Metalogic/Bundle/WitnessSeed.lean` | 31, 65, 307 | irreflexive semantics comments | **MODIFY** — update |
| `Metalogic/Bundle/Construction.lean` | 73, 78 | irreflexive semantics comments | **MODIFY** — update |
| `Metalogic/Bundle/TemporalCoherence.lean` | 145 | irreflexive semantics comment | **MODIFY** — update |
| `Metalogic/StagedConstruction/DFromCantor.lean` | 98, 106, 120 | `task_rel` irreflexive (math property of `<`) | **KEEP** (this is about `<` on D, not semantics) |
| `Metalogic/StagedConstruction/WitnessSeedWrapper.lean` | 28 | irreflexive comment | **MODIFY** — update |
| `Metalogic/StagedConstruction/StagedTimeline.lean` | 137 | irreflexive comment | **MODIFY** — update |
| `Metalogic/StagedConstruction/CanonicalRecovery.lean` | 57, 168, 193 | irreflexive comments | **MODIFY** — update |
| `Metalogic/StagedConstruction/DensityFrameCondition.lean` | 242, 256 | `irreflexive_SetMaximalConsistent.has_strict_future` | **MODIFY** — update or remove |
| `Metalogic/StagedConstruction/Completeness.lean` | 47, 70-72 | irreflexivity refs | **MODIFY** — update |
| `Metalogic/StagedConstruction/DiscreteSuccSeed.lean` | 281, 410 | `canonicalR_irreflexive_axiom` refs | **MODIFY** — update |
| `Metalogic/Decidability/Correctness.lean` | 17 | irreflexive semantics ref | **MODIFY** — update |
| `ProofSystem/Axioms.lean` | 53, 88, 374, 423, 450 | irreflexive semantics refs | **MODIFY** — update comments |
| `Semantics/Truth.lean` | 13, 17 | irreflexivity refs | **MODIFY** — update |

## File-Level Actions

| File | Action | Reason |
|------|--------|--------|
| `Metalogic/IRRSoundness.lean` | **DELETE** | Entirely IRR-specific, has sorry, unsound under reflexive semantics |
| `Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` | **DELETE** or **RENAME** | Re-exports deprecated `canonicalR_irreflexive`; if antisymmetry is kept, rename to `CanonicalAntisymmetry.lean` |
| `Metalogic/Bundle/DirectIrreflexivity.lean` | **DELETE** | Entirely about proving irreflexivity directly; exploratory/dead code |
| `Metalogic/Bundle/CanonicalIrreflexivity.lean` | **HEAVY MODIFY** | Contains reflexive proof (KEEP), naming set infrastructure (KEEP), deprecated axiom (REMOVE), IRR proof attempts (REMOVE) |
| `ProofSystem/Derivation.lean` | **MODIFY** | Remove `irr` constructor from `DerivationTree` |
| `ProofSystem/Substitution.lean` | **SIMPLIFY** | Remove IRR case (the rest is independently useful) |
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | **MODIFY** | Remove `irr` constructor from `ExtDerivationTree` |
| `Metalogic/ConservativeExtension/Lifting.lean` | **HEAVY MODIFY** | Remove all IRR-specific cases (~12 locations) |
| `Metalogic/ConservativeExtension/ExtFormula.lean` | **MODIFY** | Remove IRR embedding lemma |
| `Metalogic/Soundness.lean` | **MODIFY** | Remove IRR import and all IRR match arms |
| `Metalogic/SoundnessLemmas.lean` | **MODIFY** | Remove IRR match arm |
| `Metalogic/Core/DeductionTheorem.lean` | **MODIFY** | Remove IRR match arm |
| `Metalogic/Core/MaximalConsistent.lean` | **MODIFY** | Remove IRR match arms |
| All `canonicalR_irreflexive` call sites (~28 calls) | **MODIFY** | Replace with antisymmetry-based arguments |
| All comment-only references (~20 files) | **MODIFY** | Update documentation |
| All Boneyard files | **KEEP** | Already archived |

## Substitution.lean Assessment

**Verdict: SIMPLIFY** (remove IRR case, keep the rest)

- **Lines 1-365**: Formula substitution infrastructure (`Formula.subst`, structural lemmas, `derivation_subst` for non-IRR cases) — all independently useful for any proof system work.
- **Lines 366-386**: The IRR case in `derivation_subst` — has a `sorry` because substitution interaction with IRR freshness is complex. This is the ONLY IRR-specific part.
- **Lines 387-395**: Weakening case — independently useful.

The substitution infrastructure is valuable for future proof theory work. Only the single IRR case (20 lines) should be removed. The file was created for Task 29 but its non-IRR content is general-purpose.

## Axiom Inventory

### Irreflexive-Specific Axioms (REMOVE)

| Axiom | File | Line | Status |
|-------|------|------|--------|
| `canonicalR_irreflexive_axiom` | `Bundle/CanonicalIrreflexivity.lean` | 1492 | **DEPRECATED** — marked as introducing inconsistency |

### Semantics-Independent Axioms (KEEP)

| Axiom | File | Line | Purpose |
|-------|------|------|---------|
| `successor_deferral_seed_consistent_axiom` | `Bundle/SuccExistence.lean` | 266 | Successor seed consistency |
| `predecessor_deferral_seed_consistent_axiom` | `Bundle/SuccExistence.lean` | 311 | Predecessor seed consistency |
| `predecessor_f_step_axiom` | `Bundle/SuccExistence.lean` | 516 | Predecessor construction |
| `succ_chain_fam_p_step` | `Bundle/SuccChainFMCS.lean` | 335 | Succ chain p-step |
| `f_nesting_boundary` | `Bundle/SuccChainFMCS.lean` | 583 | F nesting bound |
| `p_nesting_boundary` | `Bundle/SuccChainFMCS.lean` | 695 | P nesting bound |
| `discrete_Icc_finite_axiom` | `Domain/DiscreteTimeline.lean` | 316 | Discrete Icc finiteness |
| `discrete_Icc_finite_axiom` | `FrameConditions/Completeness.lean` | 210 | Duplicate declaration |
| `discreteImmediateSuccSeed_consistent_axiom` | `StagedConstruction/DiscreteSuccSeed.lean` | 284 | Discrete successor seed |
| `discreteImmediateSucc_covers_axiom` | `StagedConstruction/DiscreteSuccSeed.lean` | 414 | Discrete successor coverage |

**Note**: The semantics-independent axioms use `canonicalR_irreflexive` in their proofs/justifications in some cases (e.g., `DiscreteSuccSeed.lean:281` references `canonicalR_irreflexive_axiom`). These axioms themselves remain valid under reflexive semantics, but their documentation needs updating.

## Confidence Level

**High confidence (95%)** for the inventory completeness. The search covered all patterns (`irreflexive`, `Gabbay`, `.irr`, `IRR`, `canonicalR_irreflexive`, `CanonicalIrreflexivity`, `fresh_atom`, `fresh_for`, `strict_successor`, `strict_predecessor`) across the entire `Theories/` directory.

**Key uncertainty**: Some files referencing "irreflexive" in comments may use the term in a mathematical sense (e.g., `<` is irreflexive on naturals) rather than referring to the IRR proof system feature. The `DFromCantor.lean` references to `task_rel` being irreflexive are about the mathematical property of strict orders, not about the semantics switch — these are correctly marked KEEP.

**Total scope**:
- **3 files to DELETE** (IRRSoundness, CanonicalIrreflexivityAxiom, DirectIrreflexivity)
- **~15 files requiring code changes** (remove IRR match arms, switch to antisymmetry)
- **~20 files requiring comment/doc updates**
- **~6 Boneyard files to leave untouched**
- **1 axiom to remove** (`canonicalR_irreflexive_axiom`)
- **~28 call sites** to `canonicalR_irreflexive` that need replacement
