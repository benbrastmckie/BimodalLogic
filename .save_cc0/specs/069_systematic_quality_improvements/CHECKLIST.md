# Implementation Checklist

Quick reference for tracking progress through all 13 phases.

## Week 1: High ROI Improvements ⏳

### Phase 1: Directory READMEs (4-6 hours)
- [ ] `Logos/Core/README.md`
- [ ] `Logos/Core/Syntax/README.md`
- [ ] `Logos/Core/ProofSystem/README.md`
- [ ] `Logos/Core/Semantics/README.md`
- [ ] `Logos/Core/Metalogic/README.md`
- [ ] `Logos/Core/Theorems/README.md`
- [ ] `Logos/Core/Theorems/Perpetuity/README.md`
- [ ] `Logos/Core/Automation/README.md`

### Phase 2: CI Quality Gates (2-3 hours)
- [ ] Sorry placeholder check
- [ ] Docstring coverage check
- [ ] File size limit check
- [ ] Directory README check
- [ ] `scripts/docstring-coverage.sh` created

### Phase 3: Quality Metrics Dashboard (3-4 hours)
- [ ] `scripts/quality-metrics.sh` created
- [ ] `scripts/quality-trends.sh` created
- [ ] CI integration complete
- [ ] Baseline metrics recorded

### Phase 4: Documentation TODOs (4-6 hours)
- [ ] All 85 TODOs categorized
- [ ] Outdated TODOs removed (30-40)
- [ ] Completed work documented (20-30)
- [ ] Active TODOs moved to TODO.md (10-15)
- [ ] Future TODOs moved to specs (5-10)
- [ ] Final count <20

## Week 2: Foundation Refactoring ⏳

### Phase 5: Axiom Refactoring (8-12 hours)
- [ ] `ex_falso` axiom added
- [ ] `peirce` axiom added
- [ ] `double_negation` axiom removed
- [ ] EFQ soundness proof complete
- [ ] Peirce soundness proof complete
- [ ] DNE derived as theorem
- [ ] All uses of DNE axiom updated
- [ ] Tests updated

### Phase 6: Split Propositional.lean (8-12 hours)
- [ ] `Propositional/Combinators.lean` created
- [ ] `Propositional/DeMorgan.lean` created
- [ ] `Propositional/Biconditional.lean` created
- [ ] `Propositional/Classical.lean` created
- [ ] `Propositional/README.md` created
- [ ] `Propositional.lean` becomes re-export
- [ ] All imports updated
- [ ] Tests pass

### Phase 7: Import Patterns (3-4 hours)
- [ ] `IMPORT_STYLE_GUIDE.md` created
- [ ] `scripts/check-imports.sh` created
- [ ] All files updated to match standard
- [ ] CI check added
- [ ] LEAN_STYLE_GUIDE.md updated

## Week 3: Documentation & Structure ⏳

### Phase 8: Add Docstrings (6-8 hours)
- [ ] Syntax package docstrings (~50)
- [ ] ProofSystem package docstrings (~80)
- [ ] Semantics package docstrings (~100)
- [ ] Theorems package docstrings (~70)
- [ ] Automation package docstrings (~36)
- [ ] Coverage ≥60%
- [ ] Zero `#lint docBlame` warnings

### Phase 9: Split Truth.lean (4-6 hours)
- [ ] `Truth/Evaluation.lean` created
- [ ] `Truth/TimeShift.lean` created
- [ ] `Truth/Validity.lean` created
- [ ] `Truth/README.md` created
- [ ] `Truth.lean` becomes re-export
- [ ] All imports updated
- [ ] Tests pass

### Phase 10: Split Bridge.lean (4-6 hours)
- [ ] `Bridge/Monotonicity.lean` created
- [ ] `Bridge/Duality.lean` created
- [ ] `Bridge/Contraposition.lean` created
- [ ] `Bridge/README.md` created
- [ ] `Bridge.lean` becomes re-export
- [ ] All imports updated
- [ ] Tests pass

### Phase 11: Dependency Graph (2-3 hours)
- [ ] Dependency graph generated (PNG, SVG)
- [ ] `MODULE_DEPENDENCIES.md` created
- [ ] Layered architecture documented
- [ ] Import rules defined
- [ ] No circular dependencies

## Week 4: Testing & Sustainability ⏳

### Phase 12: Add Tests (8-10 hours)
- [ ] Edge case tests (~300 lines)
- [ ] Negative tests (~300 lines)
- [ ] Property-based tests (~400 lines)
- [ ] 1,000+ total lines added
- [ ] Test-to-code ratio ≤3:1
- [ ] All tests pass

### Phase 13: Inference Rule Refactoring (12-16 hours)
- [ ] `necessitation` rule added
- [ ] `modal_k_dist` rule added
- [ ] `temporal_necessitation` rule added
- [ ] `temporal_k_dist` rule added
- [ ] Equivalence theorems proven
- [ ] Soundness proofs complete
- [ ] All uses of old rules updated
- [ ] Tests updated

## Final Validation ✅

- [ ] `lake build` succeeds
- [ ] `lake test` passes
- [ ] No sorry in production code
- [ ] Docstring coverage ≥60%
- [ ] All directories have READMEs
- [ ] No files >800 lines
- [ ] Documentation TODOs <20
- [ ] Test-to-code ratio ≤3:1
- [ ] All CI quality gates pass

## Documentation Updates ✅

- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] MAINTENANCE.md updated
- [ ] CLAUDE.md updated
- [ ] README.md updated
- [ ] Final quality metrics report generated

---

**Progress**: 0/13 phases complete (0%)

**Estimated Time Remaining**: 60-80 hours

**Next Phase**: Phase 1 (Directory READMEs)
