# Research Report: Task #175

**Task**: Naming convention and bridge/wrapper cleanup
**Date**: 2026-05-22
**Mode**: Team Research (4 teammates)
**Session**: sess_1779462811_376d78

## Summary

Systematic audit of all 152 active Lean source files (91,153 lines) identified ~40 opaque naming issues across 10 categories, resolved critical misconceptions in the task description, and produced a prioritized rename inventory with blast radius estimates. The key finding is that Bridge.lean is NOT a pure forwarding wrapper (it contains substantive proofs), several abbreviations from the task description (`drm`, `tc_`, `fuc_`, `buc_`) exist only in Boneyard and need no active code changes, and `bx_completeness` does not exist in source code (it's a documentation artifact). The real work is concentrated in ~13 propositional abbreviation renames (257+ references), ~22 `temp_` to `temporal_` renames, tombstone comment purging, and a few trivial alias removals.

## Key Findings

### 1. Bridge.lean Is NOT a Pure Forwarding Wrapper (Conflict Resolved)

Teammates A and B independently read the entire file and agree: Bridge.lean contains 25-34 substantive definitions including duality lemmas, monotonicity proofs, and the P6 theorem. Only 3-4 definitions are trivial wrappers or duplicates:
- `dne` wraps `Propositional.double_negation` (7 refs)
- `local_efq`, `local_lce`, `local_rce` are local re-implementations to avoid circular imports
- `lce_imp`/`rce_imp` duplicate Propositional versions

**Resolution**: Bridge.lean should NOT be deleted wholesale. Inline the 3-4 trivial wrappers, but the substantive proofs (`box_mono`, `diamond_mono`, `perpetuity_6`, etc.) must stay or be relocated to natural homes. Consider renaming Bridge.lean to something more descriptive (e.g., `MonotonicityDuality.lean`).

### 2. `bx_completeness` Does Not Exist in Source Code

All teammates confirm: the actual theorem is `completeness_discrete` in `BXCanonical/Completeness.lean`. The name `bx_completeness` appears only in documentation/specs. The existing `{result}_{frame_class}` naming pattern (`soundness_dense`, `completeness_discrete`) is already consistent and Mathlib-aligned. **No source rename needed** -- only documentation references should be updated.

### 3. Several Task-Description Abbreviations Are Boneyard-Only

| Abbreviation | Active Code? | Action |
|---|---|---|
| `drm` | Boneyard only | None |
| `tc_` | Boneyard only | None |
| `fuc_` | 0 occurrences anywhere | None |
| `buc_` | 0 occurrences anywhere | None |
| `cud` | Comments only | Expand in comments if desired |
| `sdc` | Comments only | Expand in comments if desired |

The task description over-scoped these. Only `bfmcs`, `dd_`, and `temp_` need active code changes.

### 4. Tombstone Comment Count (Conflict Resolved)

- Teammate A: 96 comments across 39 files (broadest search)
- Teammate B: 4 comments (narrowest search: exact "REMOVED"/"DEPRECATED" patterns)
- Teammate D: 52 comments

**Resolution**: The count depends on search breadth. A's count of 96 includes comments mentioning "removed" in any context (e.g., "removed in BX", "was removed"). B's count of 4 is only explicit tombstone markers. For cleanup purposes, use A's audit as the starting point but verify each -- some "removed" mentions are legitimate historical documentation for complex mathematical constructions.

### 5. Metaprogramming Backtick Names Are the Highest-Risk Rename (Critic Finding)

`Tactics.lean:540-553` hardcodes axiom constructor names as backtick references:
```lean
let axiomCtors : List Name := [
  ``Axiom.modal_t, ``Axiom.modal_4, ...
]
```
And `Tactics.lean:512` references `` `Bimodal.Theorems.Combinators.temp_future_derived``.

These backtick names **fail silently** if the target is renamed -- the tactic simply won't find matching constructors. Aesop rules (`@[aesop safe apply]` in AesopRules.lean) have the same risk. **Every rename of axiom constructors or theorem names must be coordinated with updates to Tactics.lean, AesopRules.lean, and SuccessPatterns.lean.**

### 6. `and_left`/`and_right` Namespace Collision Risk

Renaming `lce` to `and_left` and `rce` to `and_right` has potential collision with:
- `PointInsertion.lean:1193`: `private noncomputable def and_left_impl`
- `Hierarchy.lean:2463`: `private theorem and_left_congr_hier`
- `DedekindZ.lean:691`: `private theorem and_left_congr`
- Lean 4 core `And.left` / `And.right`

Risk is low since these are `private` and in different namespaces, but should be verified at implementation time.

### 7. Task Dependency Ordering Should Be Reconsidered

The current TODO ordering is 168 -> 174 -> 175, but Teammate C makes a strong case for **175 FIRST**:
- If 174 (file splitting) runs first, renames in 175 must target the NEW split files (unknown filenames)
- If 175 runs first, 174 splits happen on already-clean names -- file splitting is name-independent
- Running 175 first avoids renaming across twice as many files

**Recommendation**: Run 175 before 174. This contradicts the current dependency graph but is practically safer.

## Complete Rename Inventory

### Category 1: Propositional Logic Abbreviations (13 names, ~257+ references)

| Current | Proposed | File | Active Refs | Dead Code? |
|---|---|---|---|---|
| `ecq` | `bot_of_and_neg` | Propositional.lean:225 | 7 | No |
| `raa` | `imp_neg_imp` | Propositional.lean:285 | 11 | No |
| `efq` | `neg_imp` (alias of efq_neg) | Propositional.lean:378 | 6 | No |
| `efq_neg` | `imp_of_neg` | Propositional.lean:359 | 4 | No |
| `lce` | `and_left` | Propositional.lean:579 | 35 | No |
| `rce` | `and_right` | Propositional.lean:658 | 40 | No |
| `ldi` | `or_inl` | Propositional.lean:390 | 6 | No |
| `rdi` | `or_inr` | Propositional.lean:453 | 8 | No |
| `rcp` | `imp_of_neg_imp_neg` | Propositional.lean:489 | 3 | No |
| `lem` | `em` | Propositional.lean:70 | 2 | No |
| `dni` | `not_not_intro` | Combinators.lean:601 | 49 | No |
| `ni` | (delete) | Propositional.lean:1507 | 0 | **Yes** |
| `ne` | (delete) | Propositional.lean:1531 | 0 | **Yes** |
| `de` | (delete) | Propositional.lean:1614 | 0 | **Yes** |
| `bi_imp` | (delete) | Propositional.lean:1562 | 0 | **Yes** |

### Category 2: `temp_` to `temporal_` (22 definitions)

All high confidence. See Teammate A findings for complete table with file locations. Key entries:
- `Axiom.temp_linearity` -> `Axiom.temporal_linearity` (~26 refs)
- `Axiom.temp_linearity_past` -> `Axiom.temporal_linearity_past` (~19 refs)
- 14 soundness/derived theorem names with `temp_` prefix
- 6 private `axiom_temp_*` helpers in SoundnessLemmas.lean

### Category 3: Axiom Naming Consistency

| Current | Proposed | Refs |
|---|---|---|
| `z1_valid` | `axiom_z1_valid` | 2 |
| `z1_is_valid` | `axiom_z1_is_valid` | 2 |

Medium confidence -- verify whether other axiom validators use the `axiom_` prefix first.

### Category 4: Bridge.lean Inlineable Definitions

| Definition | Action | Refs |
|---|---|---|
| `dne` | Inline to `Propositional.double_negation` | 7 |
| `local_efq` | Remove if circular import resolved | 0 external |
| `local_lce` | Remove if circular import resolved | 0 external |
| `local_rce` | Remove if circular import resolved | 0 external |
| `lce_imp` (Bridge version) | Remove duplicate (Propositional has same) | 0 qualified |
| `rce_imp` (Bridge version) | Remove duplicate (Propositional has same) | 0 qualified |

### Category 5: Removable Aliases and Dead Code

| Name | Type | File | Action |
|---|---|---|---|
| `completeness'` | Trivial primed variant | BXCanonical/Completeness.lean:176 | Delete (unused) |
| `algebraic_completeness_theorem'` | Trivial primed variant | Algebraic/AlgebraicCompleteness.lean:187 | Delete (unused) |
| `minimalFrameClass` | Unused alias | ProofSystem/Axioms.lean:412 | Delete |
| `canonicalR_transitive` | Alias for `existsTask_transitive` | Bundle/CanonicalFrame.lean:268 | Inline (3 call sites) |

### Category 6: `dd_` Prefix (2 definitions)

| Current | Proposed | Refs |
|---|---|---|
| `dd_countermodel_chronicle_discrete` | `countermodel_chronicle_discrete` | 2 |
| `dd_countermodel_chronicle_mixed_sorry` | `countermodel_chronicle_mixed` | 1 |

### Category 7: `bx_` Prefix (~25 defs, ~134 refs)

The `bx_` prefix is redundant within the `BXCanonical` namespace but has high blast radius. **Recommend deferring** this to a separate task or treating as low priority within 175.

### Category 8: `Formula.top` Inconsistency

Two different definitions:
- `private abbrev top = Formula.neg Formula.bot` in TemporalDerived.lean:62
- `abbrev Formula.top = .imp .bot .bot` in TemporalClosure.lean:515

Logically equivalent but structurally different. Unify to one canonical form.

### Category 9: Re-export File

`Bundle/FMCS.lean` (17 lines) is a pure re-export of `FMCSDef.lean`. Can be eliminated by updating importers.

### Category 10: Well-Established Abbreviations (KEEP)

| Name | Refs | Decision | Rationale |
|---|---|---|---|
| `BFMCS` | 145 | Keep | Standard type name, formally defined, 10+ files |
| `FMCS` | 115 | Keep | Standard type name |
| `MCS` | 500+ | Keep | Standard mathematical abbreviation |
| `imp_trans` | 189 | Keep | Already descriptive |
| `b_combinator` | 90+ | Keep | Standard combinator name |
| `mp` | 7 | Keep | Universally understood |

## Synthesis

### Conflicts Resolved

| Topic | Teammates | Resolution |
|---|---|---|
| Bridge.lean nature | A+B (substantive proofs) vs D (pure forwarding) | **A+B correct** -- they read the file; D relied on task description claims. Bridge.lean has substantive proofs. |
| Tombstone count | A (96) vs B (4) vs D (52) | Different search breadths. Use A's 96 as upper bound; verify each. |
| BFMCS/FMCS rename | A+D (keep) vs C (asks question) | **Keep** -- standard abbreviations with formal definitions, 260+ combined refs. |
| `bx_` prefix | A (remove, medium) vs C (keep?, high blast) | **Defer** -- high blast radius (134 refs), debatable value since already descriptive. |

### Gaps Identified

1. **Exact blast radius of `lce_imp`/`rce_imp` removal from Bridge**: Teammate C notes 101/92 refs respectively for these names, but it's unclear how many resolve to Bridge vs Propositional versions. Need `lean_hover_info` at specific call sites during implementation.
2. **Circular import between Propositional and Perpetuity**: Neither teammate fully analyzed whether this can be broken. This determines whether `local_efq`/`local_lce`/`local_rce` in Bridge can actually be removed.
3. **Exact search for primed variants**: A found 4, B found 2 trivially removable + many non-trivial (C2', C4', C5' are mathematical conditions). Most primed variants are NOT trivial.
4. **Boneyard breakage**: Will Boneyard code break? It references `lce` (2), `rce` (4), `dni` (4). Decision needed: is breaking Boneyard acceptable?

### Recommendations

**Phase 1 -- Zero Risk (1-2 hours)**:
1. Delete dead code: `ni`, `ne`, `de`, `bi_imp` (0 callers each)
2. Delete unused aliases: `minimalFrameClass`, `completeness'`, `algebraic_completeness_theorem'`
3. Unify `Formula.top` definitions
4. Eliminate `FMCS.lean` re-export file

**Phase 2 -- Low Risk, High Value (2-3 hours)**:
1. Rename `temp_` -> `temporal_` across all 22 definitions + update Tactics.lean backtick refs
2. Inline `canonicalR_transitive` -> `existsTask_transitive` (3 call sites)
3. Inline `dne` -> `Propositional.double_negation` in Bridge.lean

**Phase 3 -- Medium Risk, Core Rename (3-5 hours)**:
1. Rename propositional abbreviations: `ecq`, `raa`, `efq`, `lce`, `rce`, `ldi`, `rdi`, `rcp`, `lem`, `dni`
2. Update ALL automation files: Tactics.lean backtick names, AesopRules.lean, SuccessPatterns.lean string labels
3. Build and verify after EACH rename (not batched)

**Phase 4 -- Structural (1-2 hours)**:
1. Remove `dd_` prefix from 2 active definitions
2. Rename `z1_valid` -> `axiom_z1_valid` (if consistent with other axiom validators)
3. Purge tombstone comments (verify each before deletion)

**Phase 5 -- Optional/Deferred**:
1. `bx_` prefix removal (134 refs, debatable value)
2. Bridge.lean rename to descriptive name
3. Resolve circular import to eliminate local_* duplicates

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|---|---|---|---|---|
| A | Primary naming audit | completed | high | Complete inventory of all 10 rename categories with reference counts |
| B | Bridge/wrapper/alias | completed | high | Corrected Bridge.lean misconception; cataloged all aliases and primed variants |
| C | Critic (risks) | completed | high | Identified silent metaprogramming breakage risk; task ordering recommendation |
| D | Horizons (strategy) | completed | high | Mathlib convention alignment; confirmed codebase is 85% compatible; proposed naming system |

## Task Ordering Recommendation

Based on Critic analysis, the dependency ordering should be reconsidered:

**Current**: 168 -> 174 -> 175
**Recommended**: 175 -> 168 -> 174

Rationale: Renaming first (175) means file splitting (174) operates on clean names. The alternative forces renaming across twice as many files after splitting. Task 168 (FrameClass parameterization) changes type signatures but not names, so it's order-independent relative to 175.

## References

- Task 179 report 02: `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md` (authoritative Mathlib naming mapping)
- Teammate A detailed findings: `specs/175_naming_convention_and_bridge_cleanup/reports/01_teammate-a-findings.md`
- Teammate B Bridge analysis: `specs/175_naming_convention_and_bridge_cleanup/reports/01_teammate-b-findings.md`
- Teammate C risk analysis: `specs/175_naming_convention_and_bridge_cleanup/reports/01_teammate-c-findings.md`
- Teammate D strategic assessment: `specs/175_naming_convention_and_bridge_cleanup/reports/01_teammate-d-findings.md`
