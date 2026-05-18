# Teammate A Findings: Primary Approach — Comprehensive File-by-File Impact Analysis

**Task**: 116 — Redefine G, H, F, P via Until/Since (Burgess 1982)
**Teammate**: A — Primary Approach
**Date**: 2026-05-18

## Key Findings

### 1. Corrected Impact Scope

The original research (report 01) undercounted significantly:

| Metric | Original Estimate | Actual Count | Delta |
|--------|------------------|--------------|-------|
| Affected files | ~70 | **83** | +13 |
| Total references | ~1416 | **1891** | +475 |
| Pattern match arms | ~122 | **400** | +278 |
| Constructor applications | ~700 | **1204** | +504 |
| Simp/rw references | ~88 | **32** | -56 (overcounted) |
| Comment references | N/A | **40** | new |

**Key gap**: The original research entirely missed the `WeakCanonical/Separation/` subtree — **15 files** with **260 pattern match arms** and the highest per-file density in the entire codebase.

### 2. Three Change Categories

Every reference falls into one of three categories with different difficulty levels:

**Category A — Pattern Match Arms (400 total, HARD)**: These are the compile-breaking changes. When `all_future`/`all_past` are removed as constructors, every `match`/`induction`/`cases` on `Formula` that has arms for these constructors will fail to compile. These arms must be DELETED (not modified) — after removal, the 6-constructor Formula type no longer needs arms for these two former constructors.

**Category B — Constructor Applications (1204 total, EASY)**: Expressions like `φ.all_future`, `Formula.all_future φ`, `Context.map Formula.all_future L`, and `Formula.all_future φ ∈ S`. These all work transparently when `all_future` becomes a `def` — the syntax is identical. **Most of these files need NO code changes at all.**

**Category C — Constructor-Specific Proof Patterns (small, MEDIUM)**: A few files use constructor-specific proof techniques:
- `congrArg Formula.all_future` (2 files) — fails because `all_future` is no longer injective as a constructor
- `nomatch h` in exhaustive `match` discriminating constructors (Formula.lean only)
- `beq_all_past_eq`/`beq_all_future_eq` helper theorems (Formula.lean only)
- `injection` on constructor equality (none found)

### 3. Impact on Derived Properties

**DecidableEq / BEq / Hashable / Countable**: The `deriving` clause on `Formula` will produce instances for the 6-constructor type. These work correctly. However:
- `beq_refl` has manual induction proof with `all_past`/`all_future` arms — must delete those arms
- `eq_of_beq` has manual `match` with `all_past`/`all_future` branches — must delete them AND remove `all_past`/`all_future` from the `nomatch` lists in other branches
- `beq_all_past_eq`/`beq_all_future_eq` private theorems — must delete entirely

**complexity/modalDepth/temporalDepth/countImplications**: These are `def` functions that pattern-match on Formula. After removing constructors:
- The old arms are deleted
- `all_future φ` now unfolds to `(untl φ.neg top).neg` = `imp (untl (imp φ bot) (imp bot bot)) bot`
- `complexity (all_future φ)` would compute as: `1 + (1 + complexity φ + 1) + 1` = `complexity φ + 4` instead of old `1 + complexity φ`. This is a **semantic change** — complexity of G(p) jumps from 2 to 5.
- `temporalDepth (all_future φ)` would compute as: `max (max temporalDepth(φ.neg) temporalDepth(top)) 0` via the `imp` arm wrapping `untl`. The `untl` contributes `1 +` so we get `1 + ...`. Actually need careful analysis: `(untl (imp φ bot) (imp bot bot)).imp bot` → `imp` arm gives `max (untl_depth) 0` where `untl_depth = 1 + max (temporalDepth (imp φ bot)) (temporalDepth (imp bot bot))` = `1 + temporalDepth φ`. So net temporalDepth = `1 + temporalDepth φ`, same as before. **Correct behavior preserved for temporalDepth.**
- `modalDepth (all_future φ)` computes through `imp → untl → imp` nesting but all return `modalDepth φ` since no `box` involved. **Correct.**
- `countImplications` would count the structural `imp` nodes in the expanded form. `all_future φ` = `imp (untl (imp φ bot) (imp bot bot)) bot` has 3 `imp`s: top-level, φ→⊥, ⊥→⊥. So `countImplications (all_future φ)` goes from 0 to 3. **Semantic change.**

**needsPositiveHypotheses**: Uses wildcard `| _ => true` for all non-`imp` cases. After change, `all_future φ` is an `imp` at the top level, so `needsPositiveHypotheses (all_future φ)` changes from `true` to `false`. **Behavioral change** — but may be harmless since G(φ) = ¬F(¬φ) really is an implication.

**swap_temporal**: Currently pattern-matches with arms `all_past φ => all_future φ.swap_temporal` and `all_future φ => all_past φ.swap_temporal`. After removal, these arms vanish. The function would process `all_future φ` through the `imp` and `untl` arms: `swap_temporal (imp (untl (imp φ bot) (imp bot bot)) bot)` = `imp (snce (imp (swap_temporal φ) bot) (imp bot bot)) bot` = `all_past (swap_temporal φ)`. **Correct! The swap happens automatically via the untl↔snce swap.**

**atoms**: Currently `all_future φ => φ.atoms`. After change, processes through `imp (untl (imp φ bot) (imp bot bot)) bot`. The `bot` arms contribute `∅`, `imp` arms compute `∪`, `untl` arms compute `∪`. Net result: `φ.atoms ∪ ∅ ∪ (∅ ∪ ∅) ∪ ∅` = `φ.atoms`. **Correct.**

### 4. ExtFormula — The Parallel Type Problem

`Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` defines **ExtFormula**, a SEPARATE inductive type mirroring `Formula` but with `ExtAtom` atoms. It also has `all_past`/`all_future` constructors. This must undergo the SAME transformation:
- Remove `all_past`/`all_future` constructors from `ExtFormula`
- Add `def` abbreviations
- Update `embedFormula` (which maps `Formula → ExtFormula`)
- Update all pattern matches in ExtFormula.lean (30 arms), ExtDerivation.lean, Lifting.lean, Substitution.lean

The `ExtAxiom` inductive also has `temp_k_dist`/`temp_4` constructors that must be removed.

### 5. Critical Decision: temp_k_dist / temp_4 Removal Cascade

Removing `temp_k_dist` and `temp_4` from `Axiom` affects **36 files with 118 references**. The most impactful:
- `Soundness.lean` (13 refs): Remove `temp_k_dist_valid` and `temp_4_valid` soundness proofs, remove match arms in 4 theorem proofs
- `SoundnessLemmas.lean` (11 refs)
- `MCSProperties.lean` (15 refs): Uses `Axiom.temp_4 φ` to derive G(G(φ)) from G(φ) — must prove this via BX axioms instead
- `Tactics.lean` (12 refs): Proof automation references
- `ReflexiveCanonical.lean` (12 refs)
- `UltrafilterFrame.lean` (10 refs)

### 6. The WeakCanonical Separation Gap (NEW — NOT IN ORIGINAL RESEARCH)

15 files in `WeakCanonical/` with **435 total references** were missed entirely. Key files:

| File | Refs | Pattern Arms | Nature |
|------|------|-------------|--------|
| Separation/Hierarchy.lean | 115 | 82 | Structural induction on Formula for separability lemmas |
| Separation/TemporalClosure.lean | 111 | 58 | Temporal closure proofs; **already has `expand_temporal`** |
| ReflexiveCanonical.lean | 84 | 0 | Constructor applications only |
| Separation/Defs.lean | 45 | 36 | `int_truth`, `formula_atoms`, `is_U_free`, etc. — 9 functions with full pattern matches |
| Separation/SeparationThm.lean | 24 | 4 | Separation theorem |
| Separation/Duality.lean | 24 | 20 | Duality lemmas |
| Separation/DedekindZ.lean | 24 | 20 | Dedekind cuts on Z |
| ExpressiveCompleteness.lean | 25 | 20 | Expressive completeness |
| Table.lean | 12 | 10 | Table construction |
| TruthLemma.lean | 10 | 2 | Truth lemma |
| Separation/Eliminations.lean | 8 | 2 | Elimination lemmas |
| Separation/FormulaOps.lean | 4 | 4 | `subst_formula` pattern matches |
| Separation/NormalForm.lean | 2 | 2 | Normal form |
| Separation/NegationEquiv.lean | 2 | 0 | Constructor applications |
| FrameProperties.lean | 2 | 0 | Constructor applications |

**Critical observation**: `TemporalClosure.lean` (line 588-629) already defines `Formula.top`, `expand_temporal`, and proves `all_past_equiv_neg_snce` and `all_future_equiv_neg_untl` — the EXACT semantic equivalences this refactoring relies on. This is a valuable proof asset.

However, `Defs.lean` defines 9 recursive functions (`int_truth`, `formula_atoms`, `is_U_free`, `is_S_free`, `is_syntactically_separated`, `is_future_only`, `is_past_only`, `is_properly_separated`, `junction_depth` mutual group, `U_depth_under_S`, `count_U_subformulas`) plus more — all with full 8-constructor pattern matches. These ALL lose 2 arms each.

Some of these functions are semantically significant after removal:
- `is_future_only`: Currently `| .all_past _ => false`, `| .all_future φ => is_future_only φ`. After removal, `all_past`/`all_future` are no longer constructors. `is_future_only (all_future φ)` would unfold through `imp`/`untl` arms and return `is_future_only (untl ...) = is_future_only ... && is_future_only ...`. Since `all_future φ = (untl φ.neg top).neg = imp (untl ...) bot`, and `imp` recurses, this correctly identifies it as future-only (no `snce`). But `is_future_only (all_past φ)` = `is_future_only (imp (snce ...) bot)` which recurses into `snce` and returns `false`. **Correct!**
- `is_syntactically_separated`: `| .all_past φ => is_U_free φ`, `| .all_future φ => is_S_free φ`. After removal, `is_syntactically_separated (all_future φ)` processes through `imp (untl ...) bot`. The `imp` arm recurses. `is_syntactically_separated (untl ...)` = `is_S_free ... && is_S_free ...`. `is_syntactically_separated bot` = `true`. So net: `is_S_free (φ.neg) && is_S_free top && true` which is different from `is_S_free φ` — introduces extra checks on `φ.neg` and `top`. **Potentially changed semantics** — but `is_S_free (φ.neg) = is_S_free (imp φ bot) = is_S_free φ && is_S_free bot = is_S_free φ && true = is_S_free φ` and `is_S_free top = is_S_free (imp bot bot) = true && true = true`. So net result: `is_S_free φ`. **Correct!**

### 7. Complete File-by-File Difficulty Assessment

#### Tier 1: HARD (pattern matches + structural changes, 2+ hours each)
| File | Refs | Pat Arms | Difficulty | Notes |
|------|------|----------|------------|-------|
| Syntax/Formula.lean | 64 | 34 | HARD | Core type change + beq/complexity/atoms/swap |
| WeakCanonical/Separation/Hierarchy.lean | 115 | 82 | HARD | Massive structural induction proofs |
| WeakCanonical/Separation/TemporalClosure.lean | 111 | 58 | HARD | But has `expand_temporal` asset |
| WeakCanonical/Separation/Defs.lean | 45 | 36 | HARD | 9+ recursive functions lose arms |
| ConservativeExtension/ExtFormula.lean | 39 | 30 | HARD | Parallel type must match |

#### Tier 2: MEDIUM (pattern matches, 30-60 min each)
| File | Refs | Pat Arms | Difficulty | Notes |
|------|------|----------|------------|-------|
| WeakCanonical/ExpressiveCompleteness.lean | 25 | 20 | MEDIUM | |
| WeakCanonical/Separation/Duality.lean | 24 | 20 | MEDIUM | |
| WeakCanonical/Separation/DedekindZ.lean | 24 | 20 | MEDIUM | |
| ConservativeExtension/Lifting.lean | 29 | 20 | MEDIUM | |
| WeakCanonical/Table.lean | 12 | 10 | MEDIUM | |
| ProofSystem/Substitution.lean | 27 | 8 | MEDIUM | subst function + simp lemmas |
| Automation/ProofSearch.lean | 35 | 7 | MEDIUM | Heuristic scoring |
| ConservativeExtension/Substitution.lean | 12 | 6 | MEDIUM | |
| BXCanonical/Quasimodel/Realization.lean | 16 | 6 | MEDIUM | |
| Decidability/SignedFormula.lean | 6 | 4 | MEDIUM | |
| WeakCanonical/Separation/SeparationThm.lean | 24 | 4 | MEDIUM | |
| WeakCanonical/Separation/FormulaOps.lean | 4 | 4 | MEDIUM | |
| Semantics/Truth.lean | 10 | 4 | MEDIUM | Remove 2 arms from truth_at |
| Algebraic/RestrictedParametricTruthLemma.lean | 8 | 4 | MEDIUM | |
| Algebraic/ParametricTruthLemma.lean | 13 | 4 | MEDIUM | |
| Automation/SuccessPatterns.lean | 6 | 3 | MEDIUM | |
| Syntax/Subformulas.lean | 16 | 2 | MEDIUM | Remove 2 arms + theorem rewrites |
| SubformulaClosure.lean | 115 | 2 | MEDIUM | Only 2 pattern arms but 56 applications |
| SoundnessLemmas.lean | 29 | 2 | MEDIUM | |
| WeakCanonical/TruthLemma.lean | 10 | 2 | MEDIUM | |
| WeakCanonical/Separation/NormalForm.lean | 2 | 2 | MEDIUM | |
| WeakCanonical/Separation/Eliminations.lean | 8 | 2 | MEDIUM | |
| Automation/Tactics.lean | 24 | 2 | MEDIUM | |
| Syntax.lean | 4 | 2 | MEDIUM | |

#### Tier 3: EASY (constructor applications only, <15 min each, most need NO changes)
54 files — these use `all_future`/`all_past` only as method-call function applications (e.g., `φ.all_future`, `Formula.all_future φ`, `Formula.all_future φ ∈ S`). Since `all_future` becomes a `def` with the same signature `Formula → Formula`, these compile unchanged. **Key exception**: files that use `congrArg Formula.all_future` (2 files) need proof updates.

Full list of Tier 3 files:
- Bundle/WitnessSeed.lean (88 refs, 0 pattern arms)
- Bundle/TemporalCoherence.lean (51 refs, 0 pattern arms)
- Bundle/SuccRelation.lean (49 refs, 0 pattern arms)
- Theorems/Perpetuity/Bridge.lean (57 refs, 0 pattern arms)
- Theorems/Perpetuity/Principles.lean (47 refs, 0 pattern arms)
- Algebraic/UltrafilterFrame.lean (82 refs, 0 pattern arms)
- WeakCanonical/ReflexiveCanonical.lean (84 refs, 0 pattern arms)
- Algebraic/TenseS5Algebra.lean (38 refs, 0 pattern arms)
- Core/RestrictedMCS.lean (33 refs, 0 pattern arms)
- Theorems/GeneralizedNecessitation.lean (30 refs, 0 pattern arms)
- BXCanonical/Chronicle/ChronicleConstruction.lean (30 refs, 0 pattern arms)
- BXCanonical/Chronicle/ChronicleToCountermodel.lean (28 refs, 0 pattern arms)
- Core/MCSProperties.lean (28 refs, 0 pattern arms)
- BXCanonical/Frame.lean (27 refs, 0 pattern arms)
- BXCanonical/Chronicle/RRelation.lean (24 refs, 0 pattern arms)
- BXCanonical/Chronicle/PointInsertion.lean (74 refs, 0 pattern arms)
- Decidability/FMP/TruthPreservation.lean (19 refs, 0 pattern arms)
- Algebraic/LindenbaumQuotient.lean (19 refs, 0 pattern arms)
- Bundle/SuccExistence.lean (17 refs, 0 pattern arms)
- BXCanonical/TruthLemma.lean (15 refs, 0 pattern arms)
- Theorems/TemporalDerived.lean (15 refs, 0 pattern arms)
- BXCanonical/Chronicle/CounterexampleElimination.lean (15 refs, 0 pattern arms)
- Decidability/Tableau.lean (12 refs, 0 pattern arms)
- ProofSystem/Axioms.lean (12 refs, 0 pattern arms)
- BXCanonical/RootScopedChain.lean (10 refs, 0 pattern arms)
- ConservativeExtension/ExtDerivation.lean (8 refs, 0 pattern arms)
- Bundle/TemporalContent.lean (8 refs, 0 pattern arms)
- Bundle/CanonicalTaskRelation.lean (8 refs, 0 pattern arms)
- BXCanonical/Filtration/SigmaOrdering.lean (8 refs, 0 pattern arms)
- Algebraic/RestrictedParametricTruthLemma.lean (see Tier 2 for 4 pattern arms)
- Theorems/Perpetuity/Helpers.lean (7 refs, 0 pattern arms)
- BXCanonical/CanonicalModel.lean (7 refs, 0 pattern arms)
- Automation/AesopRules.lean (6 refs, 0 pattern arms)
- BXCanonical/OrderedSeedConsistency.lean (6 refs, 0 pattern arms)
- BXCanonical/Quasimodel/SubformulaClosure.lean (5 refs, 0 pattern arms)
- Bundle/CanonicalFrame.lean (5 refs, 0 pattern arms)
- BXCanonical/Quasimodel/EnrichedClosure.lean (4 refs, 0 pattern arms)
- BXCanonical/Quasimodel/Construction.lean (4 refs, 0 pattern arms)
- Algebraic/InteriorOperators.lean (4 refs, 0 pattern arms)
- Syntax/Context.lean (3 refs, 0 pattern arms)
- Completeness.lean (3 refs, 0 pattern arms)
- Soundness.lean (22 refs, 0 formula pattern arms; but temp_k_dist/temp_4 axiom arms)
- Theorems/Combinators.lean (2 refs, 0 pattern arms)
- Semantics/Validity.lean (2 refs, 0 pattern arms)
- WeakCanonical/FrameProperties.lean (2 refs, 0 pattern arms)
- WeakCanonical/Separation/NegationEquiv.lean (2 refs, 0 pattern arms)
- DiscreteSoundness.lean (2 refs, 0 pattern arms)
- Core/DeductionTheorem.lean (2 refs, 0 pattern arms)
- BXCanonical/Filtration/DefectChain.lean (2 refs, 0 pattern arms)
- Bundle/FMCSDef.lean (2 refs, 0 pattern arms)
- Examples/BimodalProofs.lean (2 refs, 0 pattern arms)
- ProofSystem/Derivation.lean (1 ref, 0 pattern arms)
- Bundle/CanonicalIrreflexivity.lean (1 ref, 0 pattern arms)
- Bimodal.lean (1 ref, 0 pattern arms — barrel file comment)
- Automation.lean (1 ref, 0 pattern arms — barrel file)

**However**: Some Tier 3 files reference `Axiom.temp_k_dist` or `Axiom.temp_4` and would break from that removal even though they have no Formula pattern matches. This is a separate axis of impact.

### 8. Required Simp Lemmas (Complete List)

#### Core Definitional Lemmas
```lean
@[simp] theorem top_def : top = Formula.imp Formula.bot Formula.bot := rfl
@[simp] theorem some_future_def : some_future φ = Formula.untl φ top := rfl
@[simp] theorem some_past_def : some_past φ = Formula.snce φ top := rfl
@[simp] theorem all_future_def : all_future φ = (some_future φ.neg).neg := rfl
@[simp] theorem all_past_def : all_past φ = (some_past φ.neg).neg := rfl
-- Expanded forms
@[simp] theorem all_future_expand : all_future φ = (Formula.untl φ.neg top).neg := rfl
@[simp] theorem all_past_expand : all_past φ = (Formula.snce φ.neg top).neg := rfl
```

#### Semantic Bridge Lemmas (in Truth.lean)
```lean
theorem truth_at_top : truth_at M Omega τ t top ↔ True
theorem truth_at_all_future_iff :
    truth_at M Omega τ t (all_future φ) ↔ ∀ s, t < s → truth_at M Omega τ s φ
theorem truth_at_all_past_iff :
    truth_at M Omega τ t (all_past φ) ↔ ∀ s, s < t → truth_at M Omega τ s φ
theorem truth_at_some_future_iff :
    truth_at M Omega τ t (some_future φ) ↔ ∃ s, t < s ∧ truth_at M Omega τ s φ
theorem truth_at_some_past_iff :
    truth_at M Omega τ t (some_past φ) ↔ ∃ s, s < t ∧ truth_at M Omega τ s φ
```

#### Swap Temporal Lemmas
```lean
theorem swap_temporal_all_future :
    swap_temporal (all_future φ) = all_past (swap_temporal φ)
theorem swap_temporal_all_past :
    swap_temporal (all_past φ) = all_future (swap_temporal φ)
theorem swap_temporal_some_future :
    swap_temporal (some_future φ) = some_past (swap_temporal φ)
theorem swap_temporal_some_past :
    swap_temporal (some_past φ) = all_future (swap_temporal φ)
```

#### Substitution Lemmas
```lean
@[simp] theorem subst_all_future :
    subst (all_future φ) a ψ = all_future (subst φ a ψ)
@[simp] theorem subst_all_past :
    subst (all_past φ) a ψ = all_past (subst φ a ψ)
@[simp] theorem subst_some_future :
    subst (some_future φ) a ψ = some_future (subst φ a ψ)
@[simp] theorem subst_some_past :
    subst (some_past φ) a ψ = some_past (subst φ a ψ)
```

#### Complexity/Depth Lemmas (if semantic equivalence desired)
```lean
-- These are optional normalization lemmas if callers expect old behavior
theorem complexity_all_future : complexity (all_future φ) = complexity φ + 4
theorem temporalDepth_all_future : temporalDepth (all_future φ) = 1 + temporalDepth φ
theorem modalDepth_all_future : modalDepth (all_future φ) = modalDepth φ
-- And past duals
```

#### Integer Semantics Lemmas (for WeakCanonical/Separation/)
```lean
theorem int_truth_top : int_truth M t top ↔ True
theorem int_truth_all_future_iff :
    int_truth M t (all_future φ) ↔ ∀ s, t < s → int_truth M s φ
theorem int_truth_all_past_iff :
    int_truth M t (all_past φ) ↔ ∀ s, s < t → int_truth M s φ
```

### 9. Existing Proof Asset: expand_temporal

`WeakCanonical/Separation/TemporalClosure.lean` (lines 588-629) already contains:
- `Formula.top` definition (line 588)
- `expand_temporal` function that does exactly this rewriting (lines 592-600)
- `top_true` proof (line 603)
- `all_past_equiv_neg_snce` semantic equivalence proof (lines 608-618)
- `all_future_equiv_neg_untl` semantic equivalence proof (lines 621-629)
- `expand_temporal_equiv` full equivalence proof (line 632)

These proofs validate the semantic correctness of the redefinition for integer time semantics. The `truth_at` equivalence proofs for task frame semantics will follow the same structure.

### 10. Files That Need NO Code Changes

Approximately **40-45 of the 54 Tier 3 files** should compile without any changes when `all_future`/`all_past` become `def` instead of constructors, PROVIDED:
1. They don't use `congrArg Formula.all_future` (only 2 files do)
2. They don't reference `Axiom.temp_k_dist` or `Axiom.temp_4` (separate axis)

Files that use `all_future`/`all_past` purely in expressions like `φ.all_future ∈ S` or `Formula.all_future φ` as term construction are fully transparent to this change.

**However**, this transparency relies on Lean's `def` elaboration. If any proof relies on definitional equality of `all_future` as a constructor (e.g., pattern matching in `match` that happens to work on the head constructor), it will break. This is unlikely for Tier 3 files but possible in edge cases with `simp` lemmas or rewriting.

## Recommended Approach

### Phase Strategy: Bottom-Up with Semantic Bridge

1. **Phase 1**: Formula.lean — Remove constructors, add `def` abbreviations, add ALL simp lemmas, fix beq/complexity/atoms/swap. This is the foundation.

2. **Phase 2**: Subformulas.lean + SubformulaClosure.lean — Remove pattern arms, add subformula lemmas for abbreviation forms.

3. **Phase 3**: Truth.lean — Remove truth_at arms, add `truth_at_all_future_iff` and `truth_at_all_past_iff` bridge lemmas. These are CRITICAL for downstream files.

4. **Phase 4**: Substitution.lean — Remove pattern arms, add substitution lemmas.

5. **Phase 5**: ExtFormula.lean + ConservativeExtension/ — Parallel type transformation.

6. **Phase 6**: ProofSystem/Axioms.lean + Derivation.lean — Remove temp_k_dist/temp_4 from Axiom, update temporal_necessitation. Derive temp_k_dist/temp_4 as theorems.

7. **Phase 7**: Soundness cascade — Remove soundness proof arms for temp_k_dist/temp_4.

8. **Phase 8**: WeakCanonical/Separation/ — 15 files, 260 pattern arms. This is the largest single module and should be done as a unit.

9. **Phase 9**: Metalogic Core + Bundle + BXCanonical — Most files need no changes (Tier 3), but verify compilation.

10. **Phase 10**: Theorems + Automation + Examples — Update derived theorems and heuristics.

11. **Phase 11**: Full build validation + sorry audit.

### Key Insight for Implementation

The most efficient approach recognizes that **~54 files need no code changes** — they compile transparently. Focus implementation effort on:
1. The 5 HARD files (Tier 1) — ~200 pattern arms
2. The ~24 MEDIUM files (Tier 2) — ~200 pattern arms  
3. The temp_k_dist/temp_4 cascade — 36 files, but mostly removing match arms

## Evidence/Examples

### Example: Pattern arm removal in Defs.lean
```lean
-- BEFORE (8 arms):
def is_U_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_U_free φ && is_U_free ψ
  | .box φ => is_U_free φ
  | .all_past φ => is_U_free φ     -- REMOVE
  | .all_future φ => is_U_free φ   -- REMOVE
  | .untl _ _ => false
  | .snce φ ψ => is_U_free φ && is_U_free ψ

-- AFTER (6 arms):
def is_U_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_U_free φ && is_U_free ψ
  | .box φ => is_U_free φ
  | .untl _ _ => false
  | .snce φ ψ => is_U_free φ && is_U_free ψ
```
This is correct because `is_U_free (all_future φ)` unfolds through `imp`/`untl` arms and returns `false` iff `φ.neg` or `top` contain `untl`, which they don't (assuming `φ` is U-free). Wait — `all_future φ = (untl φ.neg top).neg = imp (untl ...) bot`. So `is_U_free (all_future φ) = is_U_free (imp (untl ...) bot) = is_U_free (untl ...) && is_U_free bot = false && true = false`. 

**This is a SEMANTIC CHANGE**: `is_U_free (all_future φ)` was `true` (for U-free φ), now it's `false` because `all_future` expands to contain `untl`.

This means the Separation/Defs.lean predicates have genuinely changed semantics. `is_U_free` previously checked for absence of `untl` constructors. After the change, `all_future φ` CONTAINS `untl` in its expansion. This is mathematically correct (G/H are now defined in terms of U/S), but it changes which formulas pass the predicate.

**Impact on is_syntactically_separated**: `| .all_future φ => is_S_free φ` disappears. The function now processes through `imp (untl ...) bot`, hitting the `untl` arm which checks `is_S_free`. The result is equivalent but the code path is different.

## Confidence Level

**High** for:
- File counts and reference totals (verified by grep)
- Pattern match arm counts (verified by grep)
- Which files need no changes (Tier 3 analysis)
- Simp lemma requirements

**Medium** for:
- Semantic equivalence of all recursive functions after expansion (verified for key functions but not all)
- Proof difficulty estimates (some proofs may have non-obvious dependencies on constructors)
- ExtFormula parallel type effort

**Low** for:
- Whether temp_k_dist/temp_4 can be derived from BX axioms without difficulty
- Whether `needsPositiveHypotheses` behavioral change causes downstream issues
- Whether `complexity` behavioral change causes termination measure issues
