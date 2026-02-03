# Research Report: Task #840

**Task**: Refactor TruthLemma Forward/Backward for Publication
**Date**: 2026-02-03
**Focus**: Path to completely sorry-free metalogic with ACTUAL archival to Boneyard

## Executive Summary

This research investigates achieving a **completely sorry-free metalogic** for journal publication, where sorries are ACTUALLY ARCHIVED to `Theories/Bimodal/Boneyard/` (not just unused), and the main metalogic has NO imports from Boneyard.

**Key Finding**: The current architecture has two critical blockers to full sorry-free publication:

1. **TruthLemma temporal backward sorries** (lines 383, 395): Omega-rule limitation - mathematically impossible to resolve with finitary proof systems
2. **Boneyard imports**: Two active Metalogic files import from Boneyard, violating publication isolation

**Recommended Path**: Restructure to forward-direction-only truth lemma AND eliminate Boneyard imports.

## Inventory of Relevant Archived Tasks (800+)

### Tasks Related to Temporal Backward Sorries

| Task | Name | Key Finding |
|------|------|-------------|
| **809** | Audit TruthLemma sorries | 4 sorries in TruthLemma; completeness only uses forward direction (.mp) |
| **816** | BMCS temporal modal coherence | Best practice: forward-direction-only; "Option B recommended" |
| **828** | FMP approach TruthLemma backward | FMP does NOT solve backward direction; omega-rule is fundamental |
| **839** | Contrapositive TruthLemma | Contrapositive doesn't help; witness extraction problem persists |

### Tasks Related to Boneyard Archival

| Task | Name | Key Finding |
|------|------|-------------|
| **806** | Archive deprecated representations | Cannot archive full files due to active dependencies; partial cleanup reduces 6 sorries |
| **818** | Refactor Bimodal Metalogic modules | Archived DeductionTheorem.lean; documented 4 remaining sorries |

### Why All Backward Direction Attempts Failed

All archived attempts share the same fundamental obstacle:

1. **Omega-rule limitation**: Finitary proof systems cannot derive universal statements from infinitely many instances
2. **Direction mismatch**: Backward direction requires: semantic truth at times -> syntactic MCS membership. But MCS is built via Lindenbaum extension, blind to which times will matter.
3. **Witness extraction**: Even with contrapositive (`G phi not-in MCS -> exists s, phi false at s`), we cannot extract the witness time from syntactic MCS membership

**Task 828 conclusion**: "The fundamental issue is not about infinity but about directionality"

## Current Boneyard Structure

### Boneyard Directory Contents

```
Theories/Bimodal/Boneyard/
├── Compat/           # Backward-compat modules
├── Completeness/     # Old completeness attempts
├── FDSM/             # Finite Duration Semantic Model attempts
├── FDSM_SingleHistory/
├── Legacy/           # Recently archived (task 818)
├── Metalogic/        # Version 1 (original)
├── Metalogic_v2/     # Version 2 (improved)
├── Metalogic_v3/     # Version 3 (BMCS precursor)
├── Metalogic_v4/     # Version 4 (FMP experiments)
├── Metalogic_v5/     # Version 5 (abandoned approaches)
├── DeprecatedCompleteness.lean
├── DurationConstruction.lean
├── README.md         # Comprehensive archival documentation
├── SyntacticApproach.lean
└── TrivialFMP.lean
```

### CRITICAL: Boneyard Imports in Active Metalogic

**Two files in active Metalogic import from Boneyard**:

1. **`Metalogic/Core/MaximalConsistent.lean`**:
   ```lean
   import Bimodal.Boneyard.Metalogic_v2.Core.MaximalConsistent
   ```
   Re-exports SetConsistent, SetMaximalConsistent, set_lindenbaum, etc.

2. **`Metalogic/FMP/Closure.lean`**:
   ```lean
   import Bimodal.Boneyard.Metalogic_v2.Representation.CanonicalModel
   ```
   Uses canonical model definitions for closure operations.

**Impact**: These imports make the published metalogic transitively dependent on Boneyard code, violating journal publication requirements.

### Existing Boneyard TruthLemma Versions

| File | Version | Status |
|------|---------|--------|
| `Boneyard/Metalogic/Representation/TruthLemma.lean` | v1 | Deprecated - same-MCS approach |
| `Boneyard/Metalogic_v2/Representation/TruthLemma.lean` | v2 | Deprecated - coherence issues |
| `Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` | v3 | Documentation of impossibility |
| `Boneyard/Metalogic_v4/Representation/TruthLemmaBackward.lean` | v4 | FMP attempt, failed |
| `Boneyard/Metalogic_v5/Representation/TruthLemma.lean` | v5 | Universal canonical, abandoned |

## Current TruthLemma Sorry Locations

### File: `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`

| Line | Case | Direction | Category | Remediation |
|------|------|-----------|----------|-------------|
| 383 | `all_future` (G) | Backward | Omega-rule limitation | Remove backward direction |
| 395 | `all_past` (H) | Backward | Omega-rule limitation | Remove backward direction |

### Why These Are NOT Archival Candidates

These sorries are in the **backward direction only**. The theorem structure is:

```lean
theorem bmcs_truth_lemma : phi in MCS t <-> bmcs_truth_at B fam t phi
```

**Forward direction** (fully proven, sorry-free):
- Atom, Bot, Imp, Box, G, H - ALL PROVEN

**Backward direction** (contains 2 sorries):
- Atom, Bot, Imp, Box - PROVEN
- G, H - SORRY (omega-rule)

The completeness theorems only use `.mp` (forward direction), so they are **transitively sorry-free**.

## Concrete Path to Archiving Temporal Backward Sorries

### Step 1: Restructure TruthLemma to Forward-Only

**Before** (current):
```lean
theorem bmcs_truth_lemma ... : phi in MCS t <-> bmcs_truth_at B fam t phi
```

**After** (publication-ready):
```lean
/-- The forward direction of the truth lemma: MCS membership implies truth.
    This direction suffices for completeness. -/
theorem bmcs_truth_lemma_forward ... : phi in MCS t -> bmcs_truth_at B fam t phi

/-- Corollary used by completeness theorems. -/
theorem bmcs_eval_truth ... : phi in eval_family.mcs 0 -> bmcs_truth_at B eval_family 0 phi
```

**Archive** (to Boneyard):
```lean
-- Boneyard/Metalogic_v6/TruthLemma/BackwardDirection.lean
/-!
# Backward Direction (Requires Omega-Saturation)

The backward direction of the truth lemma:
  bmcs_truth_at B fam t phi -> phi in fam.mcs t

This would require omega-saturation of the MCS construction, which is a fundamental
limitation of finitary proof systems. The forward direction suffices for completeness.

See: task 828, task 839 research for detailed analysis.
-/

theorem bmcs_truth_lemma_backward_conjecture [OmegaSaturated fam] :
    bmcs_truth_at B fam t phi -> phi in fam.mcs t := sorry
```

### Step 2: Eliminate Boneyard Imports

**Goal**: Zero imports from `Bimodal.Boneyard.*` in active `Metalogic/`

**File 1**: `Metalogic/Core/MaximalConsistent.lean`
- Current: imports from `Boneyard.Metalogic_v2.Core.MaximalConsistent`
- Solution: Promote the Boneyard definitions to `Core/MaximalConsistent.lean` directly
- Estimated effort: 2-3 hours (move ~200 lines of definitions and lemmas)

**File 2**: `Metalogic/FMP/Closure.lean`
- Current: imports from `Boneyard.Metalogic_v2.Representation.CanonicalModel`
- Solution: Either:
  - (A) Copy required definitions locally, OR
  - (B) Refactor FMP to not depend on old canonical model
- Estimated effort: 3-4 hours

### Step 3: Create Boneyard/Metalogic_v6 for Archival

```
Theories/Bimodal/Boneyard/Metalogic_v6/
├── README.md           # Task 840 documentation
├── TruthLemma/
│   ├── BackwardDirection.lean  # Archived backward conjecture
│   └── OmegaSaturation.lean    # Documentation of the limitation
└── PromotedToActive/
    └── README.md       # Notes on what was moved to active Metalogic
```

### Step 4: Verify Publication Readiness

After restructuring:
```bash
# 1. Verify no Boneyard imports
grep -r "import.*Boneyard" Theories/Bimodal/Metalogic/ | grep -v "^#"
# Should return empty

# 2. Verify sorry count
grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | wc -l
# Target: 0 (or at most non-critical helper sorries)

# 3. Verify build
lake build
# Should pass

# 4. Verify main theorems are transitively sorry-free
#print axioms Bimodal.Metalogic.Bundle.bmcs_weak_completeness
# Should not show "sorry"
```

## Alternative Paths Considered and Rejected

### Path A: Prove Backward Direction via Omega-Saturation

**Status**: Mathematically impossible without axioms

Would require adding axioms like:
```lean
axiom omega_saturation : forall fam t phi,
    (forall s >= t, phi in fam.mcs s) -> G phi in fam.mcs t
```

This defeats the purpose of formal verification.

### Path B: Bounded Time Semantics

**Status**: Changes the logic, not the same theorem

Previous attempts in Boneyard (SemanticCanonicalModel, FiniteCanonicalModel) show compositionality fails for unbounded durations.

### Path C: Keep Biconditional with Documented Sorries

**Status**: Unacceptable for publication

Per sorry-debt-policy.md: "Publication requires resolving all sorries or documenting as explicit axioms"

Keeping undocumented sorries in a biconditional claimed as "proven" is dishonest.

## Implementation Phases

### Phase 1: Restructure TruthLemma (2 hours)
1. Split `bmcs_truth_lemma` into `bmcs_truth_lemma_forward` (proven) and archive backward
2. Update all callers (only use `.mp` currently)
3. Create Boneyard/Metalogic_v6/TruthLemma/BackwardDirection.lean

### Phase 2: Promote Boneyard Dependencies (4 hours)
1. Move `Boneyard.Metalogic_v2.Core.MaximalConsistent` definitions to `Core/MaximalConsistent.lean`
2. Move required `CanonicalModel` definitions to `FMP/Closure.lean` or new `FMP/CanonicalModel.lean`
3. Remove Boneyard imports
4. Add documentation notes about promotion

### Phase 3: Verification (1 hour)
1. Verify zero Boneyard imports
2. Verify zero sorries in main theorems (transitively)
3. Verify build passes
4. Update Metalogic/Metalogic.lean entry point documentation

### Phase 4: Documentation (1 hour)
1. Update Boneyard/README.md with v6 section
2. Update sorry-debt-policy cross-references
3. Create publication checklist

## Success Criteria

1. **Zero sorries** in `Theories/Bimodal/Metalogic/` (excluding examples)
2. **Zero Boneyard imports** in `Theories/Bimodal/Metalogic/`
3. **Main theorems transitively sorry-free**: soundness, bmcs_weak_completeness, bmcs_strong_completeness, fmp_weak_completeness, decidability
4. **Backward direction documented** as requiring omega-saturation (in Boneyard)
5. **Build passes** with `lake build`

## Recommendations

### Primary Recommendation

**Execute the 4-phase implementation plan above.**

This achieves:
- Publication-ready metalogic (zero sorries, zero Boneyard imports)
- Honest documentation of the omega-rule limitation
- Preserved learning in Boneyard for future reference

### Effort Estimate

| Phase | Effort |
|-------|--------|
| Phase 1: Restructure TruthLemma | 2 hours |
| Phase 2: Promote Boneyard dependencies | 4 hours |
| Phase 3: Verification | 1 hour |
| Phase 4: Documentation | 1 hour |
| **Total** | **8 hours** |

### Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking changes to callers | Current callers only use `.mp`; minimal impact |
| Promoting Boneyard code introduces issues | Boneyard code is already proven; just moving it |
| New sorries discovered in promoted code | Audit promoted code before merge |

## References

### Archived Task Reports
- `specs/archive/809_audit_truthlemma_sorries/reports/research-001.md`
- `specs/archive/816_bmcs_temporal_modal_coherence_strengthening/reports/research-005.md`
- `specs/archive/828_fmp_approach_truthlemma_backward/reports/research-001.md`
- `specs/archive/839_contrapositive_truthlemma/reports/research-001.md`
- `specs/archive/806_archive_deprecated_representation_constructions/reports/research-001.md`
- `specs/archive/818_refactor_bimodal_metalogic_modules/summaries/implementation-summary-20260203.md`

### Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Current sorries at 383, 395
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Uses only forward direction
- `Theories/Bimodal/Boneyard/README.md` - Boneyard documentation
- `.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry management policy

### Academic References
- Sundholm: "A survey of the omega-rule" (omega-rule limitation)
- Hilbert's Program and The Omega-Rule (CMU) - infinitary inference
- Mathlib contribution guidelines - no-sorry policy
- Archive of Formal Proofs - submission requirements

## Conclusion

The path to a completely sorry-free, publication-ready metalogic requires:

1. **Accepting the omega-rule limitation** as fundamental (not fixable)
2. **Restructuring TruthLemma** to forward-direction-only
3. **Eliminating Boneyard imports** by promoting required definitions
4. **Archiving backward direction** to Boneyard with documentation

This approach is mathematically honest, technically achievable, and follows established publication best practices from Mathlib and the Archive of Formal Proofs.

The estimated 8-hour implementation can be broken into 2-3 tasks for incremental progress.
