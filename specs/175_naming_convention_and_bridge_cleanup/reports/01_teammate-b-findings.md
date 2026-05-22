# Teammate B Findings: Bridge/Wrapper/Alias Analysis

**Task**: 175 — Naming convention and bridge/wrapper cleanup
**Date**: 2026-05-22
**Role**: Alternative approaches — deep analysis of Bridge.lean wrappers, alias patterns, removable indirection

## Key Findings

1. **Bridge.lean is NOT a forwarding wrapper** — it's a 993-line file containing 34 substantive definitions (proofs of P6 and supporting lemmas). The "16 forwarding definitions" claim in the task description is inaccurate. Bridge.lean contains real, non-trivial proofs that happen to be named "bridge lemmas" in the mathematical sense.

2. **Only 2 true aliases/abbrevs are candidates for removal** — `canonicalR_transitive` (alias for `existsTask_transitive`) and `minimalFrameClass` (alias for `frameClass`). The rest of the `abbrev` declarations are legitimate type abbreviations.

3. **The `completeness'` primed variant is trivial and removable** — it's a one-liner that wraps `completeness`. Similarly `algebraic_completeness_theorem'` is trivially equal to its base.

4. **The legacy abbreviations (ecq, lce, rce, ldi, rdi, raa, efq, dni) are deeply embedded** — 257+ usages across the codebase. Renaming requires a massive but mechanical find-and-replace.

5. **The `temp_` prefix pattern is widespread** — 30+ definitions use `temp_` where `temporal_` would be clearer, spanning Soundness, SoundnessLemmas, AesopRules, TemporalDerived, Combinators, and other files.

6. **Tombstone comments are minimal** — only 4 found (not 81 as suggested in the task description).

7. **Two inconsistent `Formula.top` definitions exist** — one as `¬⊥` (TemporalDerived.lean) and one as `⊥ → ⊥` (TemporalClosure.lean). These are logically equivalent but should be unified.

8. **FMCS.lean is a pure re-export file** (17 lines) that only re-exports from FMCSDef.lean. Candidate for elimination.

## Bridge.lean Complete Analysis

Bridge.lean (`Theorems/Perpetuity/Bridge.lean`) contains 34 definitions. Despite its name, it is NOT a forwarding wrapper — it contains substantive proofs.

### Definitions in Bridge.lean

| Definition | Type | Is Wrapper? | Notes |
|-----------|------|-------------|-------|
| `dne` | def | **YES** — wraps `Propositional.double_negation` | Remove, use `Propositional.double_negation` |
| `modal_duality_neg` | def | No | Original proof (~20 lines) |
| `modal_duality_neg_rev` | def | No | Original proof (~20 lines) |
| `box_mono` | def | No | Original proof (4 lines) |
| `diamond_mono` | def | No | Original proof (3 lines) |
| `future_mono` | def | No | Original proof (4 lines) |
| `past_mono` | def | No | Original proof (~15 lines) |
| `local_efq` | def | **DUPLICATE** — reimplements `Propositional.efq` for local scope | Local copy to avoid circular import |
| `local_lce` | def | **DUPLICATE** — reimplements `Propositional.lce` for local scope | Local copy to avoid circular import |
| `local_rce` | def | **DUPLICATE** — reimplements `Propositional.rce` for local scope | Local copy to avoid circular import |
| `lce_imp` | def | No | Implication form of lce (uses `local_lce` + deduction theorem) |
| `rce_imp` | def | No | Implication form of rce (uses `local_rce` + deduction theorem) |
| `always_to_past` | def | No | Decomposition lemma |
| `always_to_present` | def | No | Decomposition lemma |
| `always_to_future` | def | No | Decomposition lemma |
| `past_present_future_to_always` | def | No | Composition lemma |
| `always_dni` | def | No | Original proof (~30 lines) |
| `temporal_duality_neg` | def | No | Original proof (3 lines) |
| `always_dne` | def | No | Original proof (~30 lines) |
| `temporal_duality_neg_rev` | def | No | Original proof (3 lines) |
| `always_mono` | def | No | Original proof (~20 lines) |
| `double_contrapose` | def | No | Original proof (5 lines) |
| `bridge1` | def | No | Original proof (5 lines) |
| `bridge2` | def | No | Original proof (4 lines) |
| `perpetuity_6` | def | No | Main theorem — uses bridge1, bridge2, P5 |

**Verdict**: Bridge.lean should NOT be removed wholesale. It contains substantive proofs. The 3 duplicate local_* definitions exist to avoid circular imports (Propositional imports Perpetuity, so Bridge can't import Propositional). The `dne` wrapper is the only truly trivial forwarding definition.

### External Dependents of Bridge.lean Definitions

| Definition | Used Outside Bridge.lean? | Where? |
|-----------|--------------------------|--------|
| `past_mono` | Yes | Algebraic/InteriorOperators.lean, Algebraic/LindenbaumQuotient.lean |
| `perpetuity_6` | Likely via Perpetuity.lean re-export | All files importing Perpetuity |
| Others | Via namespace re-export in Perpetuity.lean | Transitive through `import Bimodal.Theorems.Perpetuity` |

### Blast Radius for Bridge.lean Restructuring

- **Low risk**: Moving definitions to more natural locations (e.g., `box_mono`, `diamond_mono`, `future_mono`, `past_mono` → `Combinators.lean` or a new `Monotonicity.lean`)
- **Medium risk**: The circular import between Propositional and Perpetuity prevents simple consolidation of `local_efq`/`local_lce`/`local_rce`
- **High risk**: Removing Bridge.lean entirely — would break Perpetuity.lean import chain

## Alias and Abbreviation Catalog

### True Aliases (removable by inlining)

| Alias | Target | File | Usage Count | Can Remove? |
|-------|--------|------|-------------|-------------|
| `canonicalR_transitive` | `existsTask_transitive` | Bundle/CanonicalFrame.lean:268 | 3 | **Yes** — used in 2 files |
| `minimalFrameClass` | `@Axiom.frameClass` | ProofSystem/Axioms.lean:412 | 0 (unused) | **Yes** — zero external usage |
| `completeness'` | `completeness` | BXCanonical/Completeness.lean:176 | 0 (unused) | **Yes** — trivial wrapper |
| `algebraic_completeness_theorem'` | `algebraic_completeness_theorem` | Algebraic/AlgebraicCompleteness.lean:187 | 0 (unused) | **Yes** — trivial wrapper |
| `ClosureMCS` | `RestrictedMCS` | Decidability/FMP/ClosureMCS.lean:63 | ~20 (within FMP module) | **Caution** — widely used within FMP, intentional domain alias |

### Type Abbreviations (keep — they serve documentation purposes)

| Abbrev | Expanded | File | Verdict |
|--------|----------|------|---------|
| `Context` | `List Formula` | Syntax/Context.lean:54 | Keep — fundamental type |
| `ExtAtom` | `Atom ⊕ Unit` | ConservativeExtension/ExtFormula.lean:34 | Keep — meaningful |
| `ExtContext` | `List ExtFormula` | ConservativeExtension/ExtDerivation.lean:30 | Keep — meaningful |
| `AlgWorld` | `Ultrafilter LindenbaumAlg` | Algebraic/AlgebraicCompleteness.lean:43 | Keep — meaningful |
| `Branch` | `List SignedFormula` | Decidability/SignedFormula.lean:176 | Keep — meaningful |
| `Clause` | `List Literal` | Separation/FormulaOps.lean:91 | Keep — meaningful |
| `KType` | (complex type) | NEquivalence.lean:53 | Keep — complex type |
| `SearchResult`, `SearchResultWithProof`, `CacheKey`, `ProofCache`, `Visited`, `PriorityQueue` | (various) | Automation/ProofSearch.lean | Keep — internal automation types |
| `F_top`, `P_top`, `neg_neg_bot`, etc. | (formula constructions) | Syntax/SubformulaClosure.lean | Keep — convenience for closure construction |
| `valid_over_Int` | `valid_over Int` | FrameConditions/Validity.lean:194 | Keep — convenience |
| `FiniteTaskModel` | (complex type) | Semantics/TaskModel.lean:90 | Keep — meaningful |
| `MonadicSentence` | `MonadicFormula sig 0` | WeakCanonical/MonadicFO.lean:73 | Keep — meaningful |
| `NormalFormIdx` | (complex type) | WeakCanonical/MonadicFO.lean:403 | Keep — meaningful |
| `RDefinableGap` | (complex type) | WeakCanonical/EFGames.lean:342 | Keep — meaningful |

### Formula.top Inconsistency

| Definition | Value | File |
|-----------|-------|------|
| `private abbrev top` | `Formula.neg Formula.bot` (¬⊥) | Theorems/TemporalDerived.lean:62 |
| `abbrev Formula.top` | `.imp .bot .bot` (⊥ → ⊥) | WeakCanonical/Separation/TemporalClosure.lean:515 |

These are logically equivalent but structurally different. Should be unified to one canonical definition.

## Re-export File Inventory

| File | Lines | Purpose | Can Eliminate? |
|------|-------|---------|----------------|
| `Bundle/FMCS.lean` | 17 | Re-exports FMCS from FMCSDef.lean | **Yes** — merge into FMCSDef.lean or update importers |
| `Perpetuity.lean` | 88 | Imports and re-exports all Perpetuity submodules | Keep — standard Lean module pattern |

### Re-export Patterns in Comments (not code-level)

| File | Description |
|------|-------------|
| `Decidability/FMP/ClosureMCS.lean:21` | "Re-export of RestrictedMCS specialized for FMP usage" |
| `BXCanonical/Quasimodel/Construction.lean:806` | "Thin re-export of hintikka_chain_exists" |
| `WeakCanonical/Separation/Hierarchy.lean:1965` | "Re-export of since_distrib_and_right" |

These are deliberate API-shaping re-exports with additional type constraints, not simple pass-throughs.

## Tombstone Comment Inventory

| File | Line | Comment |
|------|------|---------|
| ProofSystem/Axioms.lean | 178 | `-- REMOVED (Task 115): BX14 (separation_until) and BX14' (separation_since) constructors.` |
| Automation/AesopRules.lean | 40 | `-- DEPRECATED: tm_auto no longer uses Aesop` |
| Automation/ProofSearch.lean | 480 | `-- temp_l: △φ → G(Hφ) -- removed in BX (was derivable from interaction axioms)` |
| Automation/ProofSearch.lean | 485 | `none -- removed in BX, not a base axiom` |

**Note**: The task description mentions 81 tombstone comments. The actual count from searching `-- removed`, `-- archived`, `-- superseded`, `-- deprecated` patterns is **4**. If the 81 count includes other comment patterns (e.g., `-- TODO`, `-- HACK`, `-- NOTE`), those would need separate investigation under a `/fix-it` scan.

## Primed Variants Analysis

### Trivial Primed Variants (removable)

| Definition | Base | File | Relationship |
|-----------|------|------|-------------|
| `completeness'` | `completeness` | BXCanonical/Completeness.lean:176 | Identical — just argument reorder |
| `algebraic_completeness_theorem'` | `algebraic_completeness_theorem` | Algebraic/AlgebraicCompleteness.lean:187 | Identical |

### Non-trivial Primed Variants (keep — different signatures or proofs)

| Definition | File | Reason to Keep |
|-----------|------|----------------|
| `c2'_preserved_on_old_adjacent` | Chronicle/CounterexampleElimination.lean | Different from c2 — refers to chronicle condition C2' |
| `eliminate_C5'_counterexample` | Chronicle/CounterexampleElimination.lean | Refers to condition C5' |
| `singleton_c2'`, `omega_chain_c2'` | Chronicle/ChronicleConstruction.lean | C2' is a distinct chronicle condition |
| `omega_chain_c5'_witness`, `omega_chain_c4'_witness` | ChronicleConstruction.lean | C4', C5' are distinct conditions |
| `limit_satisfies_c5'_weak`, `limit_satisfies_c5'_strong` | ChronicleConstruction.lean | Different strength levels |
| `limit_satisfies_c4'` | ChronicleConstruction.lean | C4' condition |
| `bx_until_eventuality_resolution'` | Quasimodel/LocusControl.lean | Different interface from non-primed |
| `bx_since_eventuality_resolution'` | Quasimodel/LocusControl.lean | Different interface from non-primed |
| `shifted_cantor_fmcs_dense'` | ChronicleToCountermodel.lean | Variant construction |
| `extendPoint_lt_iff'` | EFGames.lean | Different lemma |
| `ultrafilter_neg_iff'` | Algebraic/UltrafilterMCS.lean | Different formulation |
| `rRelation_guard_continues'` | Chronicle/RRelation.lean | Different statement |
| `c4'_hard_case_H_neg_delta` | Chronicle/RRelation.lean | C4' condition |
| `h_content_sub_imp_g_content_sub'` | PointInsertion.lean | Variant direction |
| `g_content_sub_imp_h_content_sub'` | PointInsertion.lean | Variant direction |
| `limitDomSubtype_denselyOrdered_from_F'T` | ChronicleToCountermodel.lean | F'T is a formula name |
| `limit_dom_dense_from_F'T` | ChronicleToCountermodel.lean | F'T is a formula name |

**Verdict**: Most primed variants in this codebase are NOT trivial — they refer to primed conditions from the mathematical theory (C2', C4', C5' are specific chronicle conditions in the Burgess/Doets completeness proof). Only `completeness'` and `algebraic_completeness_theorem'` are trivially removable.

## Recommended Removal Order

### Phase 1: Zero-risk removals (no dependency changes)
1. Remove `minimalFrameClass` abbrev (unused)
2. Remove `completeness'` primed variant (unused externally)
3. Remove `algebraic_completeness_theorem'` primed variant (unused externally)
4. Remove 4 tombstone comments
5. Remove `FMCS.lean` re-export file (update 1 importer)

### Phase 2: Low-risk alias inlining
1. Inline `canonicalR_transitive` → `existsTask_transitive` (3 call sites)
2. Inline `dne` in Bridge.lean → `Propositional.double_negation` (used only in Bridge.lean internally)
3. Unify `Formula.top` definitions (choose one canonical form)

### Phase 3: Medium-risk naming cleanup (mechanical but high blast radius)
1. Rename `temp_` prefix → `temporal_` across ~30 definitions and all call sites
2. Rename `ecq` → `bot_of_and_neg` (or Mathlib equivalent) — ~5 call sites
3. Rename `lce` → `and_left` — ~15 call sites
4. Rename `rce` → `and_right` — ~10 call sites
5. Rename `ldi` → `or_inl` — ~5 call sites
6. Rename `rdi` → `or_inr` — ~5 call sites
7. Rename `raa` → `absurd` — ~5 call sites
8. Rename `efq` → `False.elim` — ~5 call sites (note: efq_neg variant exists)
9. Rename `z1` axiom constructor → `discrete_induction` or `succArchim` — ~10 sites

### Phase 4: Structural refactoring (higher risk)
1. Move `box_mono`, `diamond_mono`, `future_mono`, `past_mono` from Bridge.lean to a shared location
2. Resolve circular import between Propositional and Perpetuity (allows removing `local_efq`, `local_lce`, `local_rce`)
3. Consider whether `ClosureMCS` alias adds value or should be inlined to `RestrictedMCS`

### Phase 5: Prefix expansion (lower priority, high blast radius)
1. Expand `bfmcs` in identifiers → `bundledFamilyMCS` (154 references — very high blast radius, debatable value)
2. Expand `dd_` prefix → `doets_discrete_` or similar (2 definitions)
3. Expand `fuc`/`buc`/`tc` suffixes in identifiers → `forward_until_coherent` etc.

## Confidence Level

**High** for:
- Bridge.lean analysis (read the entire file)
- Alias/abbrev catalog (systematic grep)
- Primed variant classification (checked each one)
- Tombstone comment count (systematic search)

**Medium** for:
- Blast radius estimates (based on grep counts, not full dependency graph)
- Phase 3 rename call site counts (approximate from grep, some false positives)
- Whether `ClosureMCS` is best kept or inlined

**Low** for:
- Whether circular import can be resolved without significant restructuring
- Whether `bfmcs` expansion is worth the churn (154 references is massive)
- Impact on build times of moving definitions between files
