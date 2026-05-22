# Teammate A Findings: Primary Naming Convention and Abbreviation Audit

**Task**: #175 — Naming convention and bridge/wrapper cleanup
**Role**: Primary Angle — Systematic naming audit
**Date**: 2026-05-22

## Key Findings

1. **bx_completeness alias does NOT exist in Lean code** — it appears only in spec documents (TODO.md, task 155 reports). The actual theorem is `completeness_discrete` in `BXCanonical/Completeness.lean`. No rename needed in source; only documentation references need updating.

2. **Bridge.lean (993 lines) is NOT a pure forwarding wrapper** — it contains 25 original definitions including substantive proofs (monotonicity lemmas, duality lemmas, always decomposition, P6 proof). Only `dne` is a trivial wrapper around `Propositional.double_negation`. The `lce_imp`/`rce_imp` are duplicates of identical definitions in Propositional.lean but have 0 qualified callers (all callers use unqualified names resolved via import).

3. **temp_ prefix is deeply embedded** — 16 definitions + 2 axiom constructors (`temp_linearity`, `temp_linearity_past`) use the `temp_` prefix. Renaming the axiom constructors is the highest-impact change since they propagate through Soundness, SoundnessLemmas, Substitution, ConservativeExtension, and FrameConditions.

4. **Several task-description abbreviations are Boneyard-only** — `drm`, `tc_`, `fuc_`, `buc_`, `cud`, `sdc` do not appear as code identifiers in active files. They exist only in Boneyard code or as comment mentions. No active code changes needed for these.

5. **Logic abbreviations have low usage outside definitions** — `ni` (0 callers), `ne` (0 callers), `de` (0 callers) are dead code. `ecq` (7 refs), `raa` (11 refs), `efq` (6 refs) have moderate usage.

## Complete Naming Inventory

### Category 1: Logic Rule Abbreviations (Propositional.lean / Combinators.lean)

| Current Name | File | Proposed Name | Refs (active, non-Boneyard) | Confidence |
|---|---|---|---|---|
| `ecq` | Propositional.lean:225 | `bot_of_and_neg` | 7 | high |
| `raa` | Propositional.lean:285 | `imp_neg_imp` or `neg_imp_of_imp` | 11 | high |
| `efq` | Propositional.lean:378 | `neg_imp` (alias of `efq_neg`) | 6 | high |
| `efq_neg` | Propositional.lean:359 | `imp_of_neg` | 4 | medium |
| `lce` | Propositional.lean:579 | `and_left` | 35 | high |
| `rce` | Propositional.lean:658 | `and_right` | 40 | high |
| `ldi` | Propositional.lean:390 | `or_inl` | 6 | high |
| `rdi` | Propositional.lean:453 | `or_inr` | 8 | high |
| `rcp` | Propositional.lean:489 | `imp_of_neg_imp_neg` | 3 | high |
| `lem` | Propositional.lean:70 | `em` (Mathlib standard) | 2 | high |
| `dni` | Combinators.lean:601 | `not_not_intro` | 49 | high |
| `ni` | Propositional.lean:1507 | `neg_intro` (or delete — 0 callers) | 0 | high |
| `ne` | Propositional.lean:1531 | `neg_elim` (or delete — 0 callers) | 0 | high |
| `de` | Propositional.lean:1614 | `or_elim` (or delete — 0 callers) | 0 | high |
| `bi_imp` | Propositional.lean:1562 | `iff_imp` (or delete — 0 callers) | 0 | medium |

### Category 2: temp_ Prefix → temporal_ (Axioms + Derived Theorems)

| Current Name | File | Proposed Name | Refs | Confidence |
|---|---|---|---|---|
| `Axiom.temp_linearity` | Axioms.lean:260 | `Axiom.temporal_linearity` | ~26 | high |
| `Axiom.temp_linearity_past` | Axioms.lean:269 | `Axiom.temporal_linearity_past` | ~19 | high |
| `temp_k_dist_valid` | Soundness.lean:182 | `temporal_k_dist_valid` | 1 | high |
| `temp_4_valid` | Soundness.lean:191 | `temporal_4_valid` | 1 | high |
| `temp_a_valid` | Soundness.lean:219 | `temporal_a_valid` | 1 | high |
| `temp_l_valid` | Soundness.lean:229 | `temporal_l_valid` | 1 | high |
| `temp_a_dual_valid` | Soundness.lean:261 | `temporal_a_dual_valid` | 1 | high |
| `temp_linearity_valid` | Soundness.lean:273 | `temporal_linearity_valid` | 2 | high |
| `temp_linearity_past_valid` | Soundness.lean:311 | `temporal_linearity_past_valid` | 2 | high |
| `temp_k_dist_derived` | TemporalDerived.lean:152 | `temporal_k_dist_derived` | 1 | high |
| `temp_4_derived` | TemporalDerived.lean:207 | `temporal_4_derived` | 1 | high |
| `temp_future_derived` | Combinators.lean:660 | `temporal_future_derived` | 2 | high |
| `temp_4_forward` | AesopRules.lean:160 | `temporal_4_forward` | 2 | high |
| `temp_a_forward` | AesopRules.lean:173 | `temporal_a_forward` | 2 | high |
| `temp_linearity_derivation` | LinearityDerivedFacts.lean:73 | `temporal_linearity_derivation` | 1 | high |
| `temp_linearity_mcs` | OrderedSeedConsistency.lean:125 | `temporal_linearity_mcs` | 1 | high |
| `temp_4_past` | MCSProperties.lean:268 | `temporal_4_past` | 1 | high |
| `axiom_temp_k_dist_valid` (private) | SoundnessLemmas.lean:888 | `axiom_temporal_k_dist_valid` | 1 | high |
| `axiom_temp_4_valid` (private) | SoundnessLemmas.lean:896 | `axiom_temporal_4_valid` | 1 | high |
| `axiom_temp_a_valid` (private) | SoundnessLemmas.lean:904 | `axiom_temporal_a_valid` | 1 | high |
| `axiom_temp_l_valid` (private) | SoundnessLemmas.lean:917 | `axiom_temporal_l_valid` | 1 | high |
| `axiom_temp_linearity_valid` (private) | SoundnessLemmas.lean:959 | `axiom_temporal_linearity_valid` | 3 | high |
| `axiom_temp_linearity_past_valid` (private) | SoundnessLemmas.lean:991 | `axiom_temporal_linearity_past_valid` | 3 | high |

### Category 3: Axiom Naming Consistency (z1 → axiom_z1)

| Current Name | File | Proposed Name | Refs | Confidence |
|---|---|---|---|---|
| `Axiom.z1` | Axioms.lean:370 | `Axiom.discrete_z1` or keep `z1` | ~20 | medium |
| `z1_valid` | Soundness.lean:810 | `axiom_z1_valid` | 2 | high |
| `z1_is_valid` | SoundnessLemmas.lean:2196 | `axiom_z1_is_valid` | 2 | high |

**Note**: Other axiom validators already follow `{name}_valid` pattern consistently (e.g., `prop_k_valid`, `modal_t_valid`). The `z1` prefix is an abbreviation for the discrete axiom schema. Consider `discrete_z1_valid` instead for clarity.

### Category 4: Bridge.lean Assessment

**Not a pure forwarding file.** Bridge.lean contains 25 definitions:

| Definition | Type | Can Inline? | External Refs |
|---|---|---|---|
| `dne` | Trivial wrapper of `Propositional.double_negation` | **YES** | 7 |
| `modal_duality_neg` | Original proof | No | 0 |
| `modal_duality_neg_rev` | Original proof | No | 0 |
| `box_mono` | Original proof | No | 29 |
| `diamond_mono` | Original proof | No | 12 |
| `future_mono` | Original proof | No | 0 |
| `past_mono` | Original proof | No | 5 |
| `local_efq` | Duplicate of Propositional pattern | Maybe | 0 |
| `local_lce` | Duplicate of Propositional.lce | Maybe | 0 |
| `local_rce` | Duplicate of Propositional.rce | Maybe | 0 |
| `lce_imp` | Duplicate of Propositional.lce_imp | **YES** | 0 (qualified) |
| `rce_imp` | Duplicate of Propositional.rce_imp | **YES** | 0 (qualified) |
| `always_to_past` | Original proof | No | 0 |
| `always_to_present` | Original proof | No | 0 |
| `always_to_future` | Original proof | No | 0 |
| `past_present_future_to_always` | Original proof | No | 0 |
| `always_dni` | Original proof | No | 0 |
| `temporal_duality_neg` | Original proof | No | 0 |
| `always_dne` | Original proof | No | 0 |
| `temporal_duality_neg_rev` | Original proof | No | 0 |
| `always_mono` | Original proof | No | 0 |
| `double_contrapose` | Original proof | No | 2 |
| `bridge1` | Original proof (used in P6) | No | 1 |
| `bridge2` | Original proof (used in P6) | No | 1 |
| `perpetuity_6` | Original proof | No | 6 |

**Recommendation**: Bridge.lean should NOT be deleted wholesale. Instead:
- Inline the 3 trivial wrappers (`dne`, `lce_imp`, `rce_imp`)
- Delete `local_efq`, `local_lce`, `local_rce` if callers can be redirected to Propositional versions
- **Rename** Bridge.lean to something more descriptive (e.g., `DualityMono.lean` or `ModalTemporalBridge.lean`) since it actually contains substantive duality/monotonicity proofs for P6

### Category 5: dd_ Prefix (Opaque Abbreviation)

| Current Name | File | Proposed Name | Refs | Confidence |
|---|---|---|---|---|
| `dd_countermodel_chronicle_discrete` | ChronicleToCountermodel.lean:3285 | `countermodel_chronicle_discrete` | 2 | high |
| `dd_countermodel_chronicle_mixed_sorry` | ChronicleToCountermodel.lean:3363 | `countermodel_chronicle_mixed` | 1 | high |

The `dd_` prefix appears to have originally stood for "defect-directed" but the current implementations don't use the defect-directed chain approach (that's in Boneyard). Dropping the prefix improves clarity.

### Category 6: bx_ Prefix (BXCanonical Module)

The `bx_` prefix (~25 definitions, ~134 total references) is used throughout `Metalogic/BXCanonical/` to namespace definitions. Since they're already in the `BXCanonical` namespace, the prefix is redundant.

| Pattern | Count | Proposed Change |
|---|---|---|
| `bx_le`, `bx_lt` | 2 defs, ~30 refs | `canonical_le`, `canonical_lt` or drop prefix |
| `bx_modal_equiv` | 1 def, ~20 refs | `modal_equiv` (namespace handles scoping) |
| `bx_fmcs` | 1 def, 3 refs | `canonical_fmcs` |
| `bx_forward_witness` etc. | ~8 defs | Drop `bx_` prefix |
| `bx_until_eventuality_resolution` | 2 defs | `until_eventuality_resolution` |

**Confidence**: medium — this is a systematic namespace cleanup but touches 134+ references across 11 files.

### Category 7: Primed Variants

| Current Name | File | Assessment |
|---|---|---|
| `bx_until_eventuality_resolution'` | LocusControl.lean:33 | Variant of `bx_until_eventuality_resolution` — check if both needed |
| `bx_since_eventuality_resolution'` | LocusControl.lean:42 | Same — check if both needed |
| `limitDomSubtype_denselyOrdered_from_F'T` | ChronicleToCountermodel.lean:208 | Rename to descriptive name |
| `shifted_cantor_fmcs_dense'` | ChronicleToCountermodel.lean:456 | Rename to descriptive name |

**Confidence**: high — all 4 should get descriptive names or be merged with unprimed versions.

### Category 8: Tombstone Comments

**96 tombstone comments in 39 active files** containing "removed", "archived", or "superseded".

**Top offenders**:
| File | Count |
|---|---|
| SoundnessLemmas.lean | 14 |
| Bundle/Construction.lean | 9 |
| ProofSystem/Axioms.lean | 8 |
| Bundle/SuccRelation.lean | 7 |
| Algebraic/Algebraic.lean | 7 |
| Bundle/SuccExistence.lean | 5 |
| Automation/ProofSearch.lean | 5 |

**Recommendation**: Purge all 96 tombstone comments. Historical information belongs in git history, not in source code.

### Category 9: Abbreviations in Comments Only (No Code Changes Needed)

These abbreviations from the task description exist ONLY in Boneyard files or as comment text, not as active code identifiers:

| Abbreviation | Meaning | Active Code? | Action |
|---|---|---|---|
| `drm` | Defect-Reducing Maximal | Boneyard only | None (Boneyard) |
| `tc_` | Temporal Chain | Boneyard only | None (Boneyard) |
| `fuc_` | Forward Until Chain | 0 occurrences | None |
| `buc_` | Backward Until Chain | 0 occurrences | None |
| `cud` | Closed Under Derivation | Comments only | Expand in comments |
| `sdc` | (Set) Deductively Closed + consistent | Comments only | Expand in comments |
| `DCS` | Deductively Closed Set | Comments only | Already uses `SetDeductivelyClosed` in code |

### Category 10: Well-Established Abbreviations (Keep As-Is)

| Name | Meaning | Occurrences | Recommendation |
|---|---|---|---|
| `BFMCS` | Bundle of FMCS | 145 | **Keep** — well-documented type name |
| `FMCS` | Family of MCS | 115 | **Keep** — well-documented type name |
| `MCS` | Maximal Consistent Set | 500+ | **Keep** — standard mathematical abbreviation |
| `SetMaximalConsistent` | Full type name | 600+ | Already descriptive |
| `imp_trans` | Implication transitivity | 90+ | **Keep** — standard |
| `b_combinator` | B combinator | 90+ | **Keep** — standard combinator name |
| `mp` | Modus Ponens | 7 (qualified) | **Keep** — universally understood |

## Reference Counts per File (Top Impact Files)

Files that will require the most changes during rename:

| File | Estimated Changes | Key Patterns |
|---|---|---|
| Theorems/Propositional.lean | ~30 | lce, rce, ecq, raa, efq, ldi, rdi definitions + internal refs |
| Theorems/ModalS5.lean | ~25 | lce, rce, dni, raa, ecq refs |
| Metalogic/SoundnessLemmas.lean | ~20 | temp_ → temporal_, tombstones |
| Metalogic/Soundness.lean | ~15 | temp_ → temporal_, z1_valid |
| Theorems/Perpetuity/Bridge.lean | ~10 | local_efq/lce/rce, dni refs |
| Metalogic/BXCanonical/Frame.lean | ~25 | bx_ prefix removal |
| Metalogic/BXCanonical/TruthLemma.lean | ~15 | bx_ prefix removal |
| Metalogic/Algebraic/BooleanStructure.lean | ~10 | lce, rce, ldi, rdi, raa refs |
| Theorems/Combinators.lean | ~5 | dni, temp_future_derived |
| Metalogic/WeakCanonical/ReflexiveCanonical.lean | ~10 | lce, rce, dni refs |

## Confidence Levels

| Category | Confidence | Rationale |
|---|---|---|
| Logic abbreviations (ecq, lce, etc.) | **High** | Clear Mathlib equivalents exist |
| temp_ → temporal_ | **High** | Mechanical rename, no ambiguity |
| Bridge.lean assessment | **High** | Thorough analysis of each definition |
| Tombstone purge | **High** | Pure comment removal |
| dd_ prefix removal | **High** | Prefix is vestigial from abandoned approach |
| bx_ prefix removal | **Medium** | Large scope, need to verify no name collisions |
| z1 → axiom_z1 / discrete_z1 | **Medium** | Naming choice less clear-cut |
| Primed variants | **High** | Small scope, clear improvement |
| Dead code (ni, ne, de, bi_imp) | **High** | Zero callers verified |
