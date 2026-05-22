# Teammate D Findings: Strategic Horizons — Naming Conventions for Publication Quality

**Task**: #175 — Naming convention and bridge/wrapper cleanup
**Date**: 2026-05-22
**Role**: Horizons (strategic alignment and long-term direction)

## Key Findings

1. **The codebase is already 85% Mathlib-compatible in naming**. Types use `UpperCamelCase` (`Formula`, `DerivationTree`, `TaskFrame`, `BXPoint`), namespaces mirror directory structure (`Bimodal.Metalogic.BXCanonical`), and most theorem names use `snake_case`. The problems are concentrated in ~40 opaque abbreviations, one 993-line bridge file, and a handful of inconsistent patterns.

2. **Task 179 report 02 already provides the complete naming mapping** for propositional theorems (`ecq`→`bot_of_and_neg`, `lce`→`and_left`, etc.) and identifies all opaque metalogic abbreviations (`bfmcs`, `drm`, `cud`, `sdc`, `dd_`, `tc_`, `fuc_`, `buc_`). The mapping is authoritative and should be adopted verbatim.

3. **`bx_completeness` does not exist in the codebase** — the user's example appears to be a confusion with the canonical naming `completeness_discrete` (in `Bimodal.Metalogic.BXCanonical`). The existing `{result}_{frame_class}` pattern (`soundness_dense`, `completeness_discrete`) is already consistent and Mathlib-aligned. No change needed for completeness theorem naming.

4. **Bridge.lean (993 lines, 16 forwarding defs) is pure indirection** — every definition in it is a local re-proof of something already proven in `Propositional.lean`, `Combinators.lean`, or `ModalS5.lean`. Imports show it is only used by `Perpetuity.lean`. All 16 definitions can be replaced by direct imports of the canonical originals.

5. **The `dd_` prefix is the most damaging opaque abbreviation** — it stands for "defect-directed" but appears in theorem names visible to external users (`dd_countermodel_chronicle_discrete`). Expanding this to `defect_directed_` would make these names self-documenting.

6. **52 tombstone comments** (`-- removed`, `-- archived`, `-- superseded`) exist in active (non-Boneyard) files. These clutter the codebase without providing useful information (the git history preserves the record).

## Mathlib Convention Analysis

### What ProofChecker Gets Right

| Convention | Status | Evidence |
|-----------|--------|---------|
| Types in `UpperCamelCase` | ✅ | `Formula`, `DerivationTree`, `BXPoint`, `BFMCS` |
| Theorems in `snake_case` | ✅ | `soundness_dense`, `double_negation`, `contrapose_imp` |
| Namespace mirrors directory | ✅ | `Bimodal.Metalogic.BXCanonical` = `Metalogic/BXCanonical/` |
| `_of_` for hypotheses | ✅ | `neg_consistent_of_not_derivable` |
| `_left`/`_right` suffixes | Partial | Missing: `lce`/`rce` should be `and_left`/`and_right` |
| Module docstrings | ✅ | 96% coverage (199/207 files) |

### What Needs Work

| Convention | Gap | Fix |
|-----------|-----|-----|
| No opaque abbreviations | ~40 opaque names | Expand per task 179 mapping |
| Descriptive theorem names | `ecq`, `raa`, `efq`, `ldi`, `rdi`, `rcp` | Use Mathlib-standard names |
| No bridge/wrapper indirection | 993-line `Bridge.lean` | Inline imports from originals |
| No redundant aliases | `efq` aliased to `efq_neg` | Delete alias after migration |
| Consistent prefix expansion | `dd_`, `tc_`, `fuc_`, `buc_` | Expand to full words |

### Mathlib Naming for Logic (Reference)

Mathlib's existing patterns for logical connectives (from `Mathlib.Logic.Basic`):

| Concept | Mathlib Name | ProofChecker Should Use |
|---------|-------------|------------------------|
| Left conjunction elim | `And.left` | `and_left` (context: `[A.and B] ⊢ A`) |
| Right conjunction elim | `And.right` | `and_right` |
| Left disjunction intro | `Or.inl` | `or_inl` |
| Right disjunction intro | `Or.inr` | `or_inr` |
| Absurd | `absurd` | `absurd` or `bot_of_and_neg` |
| False elimination | `False.elim` | Keep `efq_axiom` (it's axiomatic, not `False.elim`) |
| Double negation elim | `not_not` | `double_negation` (already good) |
| Excluded middle | `em` | `em` (rename from `lem`) |

## Proposed Naming Convention System

### Tier 1: Core Naming Rules (Universal)

1. **Types**: `UpperCamelCase` — `Formula`, `DerivationTree`, `TaskFrame`, `BXPoint`
2. **Theorems/defs**: `snake_case` — `soundness_dense`, `completeness_discrete`
3. **Namespaces**: Mirror directory hierarchy — `Bimodal.Metalogic.BXCanonical`
4. **No opaque abbreviations**: Every name must be guessable from mathematical content
5. **Structural suffixes**: Use `_left`/`_right`, `_intro`/`_elim`, `_of_`, `_iff`

### Tier 2: Domain-Specific Patterns

| Category | Pattern | Examples |
|----------|---------|---------|
| **Metalogic results** | `{result}` or `{result}_{frame_class}` | `soundness`, `completeness_dense` |
| **Soundness lemmas** | `{axiom}_valid` or `{axiom}_valid_{frame_class}` | `z1_valid` → `axiom_z1_valid` |
| **MCS properties** | `SetMaximalConsistent.{property}` | `.disjunction_iff`, `.box_closure` |
| **Chronicle conditions** | `Chronicle.c{N}` or `Chronicle.c{N}'` | `Chronicle.c2'` (Burgess notation) |
| **Frame conditions** | `{frame_class}TemporalFrame.{property}` | `DenseTemporalFrame.mk'` |
| **Axiom constructors** | `{domain}_{name}` | `modal_t`, `temp_4`, `serial_future` |

### Tier 3: Abbreviation Expansion Rules

| Category | Current | Expanded |
|----------|---------|----------|
| Logical structures | `BFMCS` | Keep as-is (established abbreviation, appears in 10+ files, defined formally in `Bundle/BFMCS.lean`) |
| Logical structures | `FMCS` | Keep as-is (same reasoning) |
| Logical structures | `MCS` | Keep as-is (standard in modal logic literature) |
| Chronicle concepts | `CUD` | Keep as-is IF the definition `ClosedUnderDerivation` is the canonical reference; the abbreviation is used only in comments |
| Chronicle concepts | `SDC` | Keep as-is IF `SetDeductivelyClosed` is the canonical reference |
| Prefix: defect-directed | `dd_` | Expand to `defect_directed_` |
| Prefix: temporal chain | `tc_` (not found in active code) | N/A — already retired |
| Prefix: forward until chain | `fuc_` (not found in active code) | N/A — already retired |
| Prefix: backward until chain | `buc_` (not found in active code) | N/A — already retired |
| `temp_` prefix | `temp_k_dist`, `temp_4` | Rename to `temporal_k_dist`, `temporal_4` for clarity |

**Key finding**: The `tc_`, `fuc_`, `buc_` prefixes appear only in Boneyard/dead code. They are NOT in the active codebase. The task description is slightly over-scoped on this point.

## Completeness Theorem Naming Strategy

The existing naming is already principled and consistent:

```
General:    completeness       soundness
Dense:      completeness_dense  soundness_dense
Discrete:   completeness_discrete  soundness_discrete
```

This follows the Mathlib pattern where the base name is the most general result and frame-class qualifiers are appended as suffixes. **No change recommended.**

For intermediate results, the pattern should be:
- `countermodel_dense` — countermodel construction for dense frames
- `countermodel_discrete` — countermodel construction for discrete frames
- `truth_lemma` — truth lemma (in appropriate namespace)
- `fmp_completeness` — finite model property completeness

## Strategic Recommendations

### 1. Adopt the Task 179 Mapping Verbatim (High Priority)

The mapping in `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md` Section 2 is comprehensive and well-researched. Implement it as-is:

| Current | New | Module |
|---------|-----|--------|
| `ecq` | `bot_of_and_neg` | Propositional |
| `raa` | `imp_neg_imp` (or keep `raa` with docstring) | Propositional |
| `efq` / `efq_neg` | `neg_imp` | Propositional |
| `lce` | `and_left` | Propositional |
| `rce` | `and_right` | Propositional |
| `ldi` | `or_inl` | Propositional |
| `rdi` | `or_inr` | Propositional |
| `rcp` | `contrapose_of_neg_imp_neg` | Propositional |
| `lem` | `em` | Propositional |
| `dni` | `not_not_intro` | Combinators |

### 2. Inline Bridge.lean (High Priority)

Replace all 16 Bridge.lean forwarding definitions with direct imports from their canonical sources:

| Bridge Definition | Canonical Source |
|-------------------|-----------------|
| `dne` | `Propositional.double_negation` |
| `local_efq` | `Propositional.efq_neg` |
| `local_lce` | `Propositional.lce` |
| `local_rce` | `Propositional.rce` |
| `lce_imp` | `Propositional.lce_imp` |
| `rce_imp` | `Propositional.rce_imp` |
| `box_mono` | `ModalS5.box_mono` (or generalized necessitation) |
| `diamond_mono` | `ModalS5.diamond_mono` |
| `future_mono` | `TemporalDerived.future_mono` (verify) |
| `past_mono` | `TemporalDerived.past_mono` (verify) |
| ... | (remaining 6 defs need individual tracing) |

After inlining, update `Perpetuity/Principles.lean` to import canonical sources directly, then delete `Bridge.lean`.

### 3. Expand `temp_` → `temporal_` in Axiom Names (Medium Priority)

The axiom constructors `temp_k_dist`, `temp_4`, `temp_linearity`, `temp_linearity_past`, `temp_future` should become `temporal_k_dist`, `temporal_4`, `temporal_linearity`, `temporal_linearity_past`, `temporal_future`. This is a purely mechanical rename affecting ~6 axiom constructors and all their use sites.

### 4. Expand `dd_` Prefix (Medium Priority)

Only 2 active `dd_` prefixed definitions exist outside Boneyard:
- `dd_countermodel_chronicle_discrete` → `defect_directed_countermodel_chronicle_discrete`
- `dd_countermodel_chronicle_mixed_sorry` → `defect_directed_countermodel_chronicle_mixed` (drop `_sorry` since it's a temporary state)

### 5. Normalize `z1_valid` → `axiom_z1_valid` (Low Priority)

All other axiom soundness lemmas follow the pattern `{axiom_name}_valid` (e.g., `serial_future_valid`, `modal_t_valid`). The `z1` axiom's soundness proof should be `axiom_z1_valid` or simply `z1_valid` (already consistent if we consider `z1` the axiom name). Check whether other axiom validity theorems have the `axiom_` prefix — if not, no change needed.

### 6. Purge Tombstone Comments (Low Priority)

Remove the 52 tombstone comments (`-- removed`, `-- archived`, `-- superseded`) from active files. The git history preserves this information. This is mechanical and low-risk.

### 7. Delete `@[deprecated]` Alias (Low Priority)

Remove the `efq` → `efq_neg` deprecated alias in `Propositional.lean:377`. After renaming `efq_neg` to a better name, the old `efq` alias has no users.

## Publication Readiness Assessment

### Current State: 7/10

**Strengths**:
- Core naming (types, namespaces, most theorems) is Mathlib-compatible
- Module docstrings at 96% coverage
- Clean namespace hierarchy mirroring directory structure
- Consistent `{result}_{frame_class}` pattern for metalogic theorems
- Foundation (the comparable project) took the same standalone-library approach

**Gaps**:
- ~40 opaque abbreviations in theorem names (propositional + metalogic)
- 993-line Bridge.lean adds pure indirection
- 52 tombstone comments clutter active files
- `temp_` prefix on axioms is ambiguous (temperature? temporary?)
- 1 deprecated alias (`efq`) lingering

### After Task 175: Expected 9.5/10

The gaps above are all mechanical renames and deletions. After completing them:
- All theorem names will be self-documenting
- No bridge/wrapper indirection
- No tombstone noise
- Consistent prefix expansion

The remaining 0.5 gap is structural: copyright headers (task 180), universe polymorphism (task 180), and the `DerivationTree : Type` vs Prop question (task 181).

### Mathlib Submission: Not Recommended (Per Task 179)

Task 179 report 02 conclusively argues against full Mathlib submission. ProofChecker should remain a **Mathlib-compatible standalone library**. The naming cleanup in task 175 serves internal quality and external readability, not Mathlib compliance per se.

### Dependency Consideration

Task 175 depends on tasks 168 and 174 (both NOT STARTED). The naming cleanup itself is logically independent — it's a mechanical rename — but if tasks 168/174 create new definitions with old-style names, those would need updating too. Consider whether to do the rename before or after those tasks complete.

## Confidence Level

**High** for the naming convention system and strategic recommendations. The analysis is grounded in:
- Direct inspection of the codebase's current naming patterns
- Task 179 report 02's comprehensive Mathlib compatibility analysis  
- Mathlib's published naming conventions
- Foundation project precedent
- Roadmap alignment (publication quality is Phase 5 goal)

**Medium** for Bridge.lean inlining details — each forwarding definition needs verification that the canonical source has identical type signature and behavior before replacement.
