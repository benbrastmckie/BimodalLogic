# Research Report: Redefine G, H, F, P via Until and Since

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Started**: 2026-05-11T16:00:00Z
- **Completed**: 2026-05-11T16:30:00Z
- **Effort**: 15-25 hours (estimated implementation)
- **Dependencies**: Task 107 (completed)
- **Sources/Inputs**:
  - Burgess 1982: "Axioms for tense logic I: Since and Until" (literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md)
  - `Theories/Bimodal/Syntax/Formula.lean` (current Formula inductive type)
  - `Theories/Bimodal/ProofSystem/Axioms.lean` (BX axiom system)
  - `Theories/Bimodal/Semantics/Truth.lean` (semantic evaluation)
  - `Theories/Bimodal/Theorems/TemporalDerived.lean` (derived temporal theorems)
  - `Theories/Bimodal/ProofSystem/Derivation.lean` (inference rules)
  - Codebase-wide grep analysis (70 non-Boneyard files, ~1400 references)
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context

- **Upstream Dependencies**: Task 107 (completed; convention migration). Burgess 1982 section 1.1 defines F, P, G, H as abbreviations from U and S.
- **Downstream Dependents**: All metalogic files (soundness, completeness, decidability, FMP), all theorem files, all automation/tactic files, all example files.
- **Alternative Paths**: (A) Keep constructors, prove equivalence theorems only. (B) Full removal as specified by Burgess.
- **Potential Extensions**: Simplification of axiom system (remove temp_k_dist, temp_4 as axiom constructors).

## Executive Summary

- Burgess 1982 section 1.1 defines F(φ) = U(φ,⊤), P(φ) = S(φ,⊤), G(φ) = ¬F(¬φ), H(φ) = ¬P(¬φ) as definitional abbreviations, not primitive connectives.
- The current codebase has 8 Formula constructors (atom, bot, imp, box, all_past, all_future, untl, snce); the task removes 2 constructors (all_past, all_future) and redefines G/H/F/P as `def`/`abbrev` via untl/snce.
- Impact analysis: ~1416 references across 70 non-Boneyard files. Pattern-match sites (122 all_future/all_past arms) are the most critical changes. Constructor applications (~700) require mechanical renaming.
- The semantic equivalence is verified: truth_at(¬U(¬φ,⊤), t) = ∀s > t, φ(s) = truth_at(G(φ), t).
- Two axioms (temp_k_dist, temp_4) become derived theorems, potentially simplifying the axiom system from 45 to 43 constructors.
- Task 107 dependency is satisfied (completed and archived).

## Context & Scope

### Current State

The `Formula` inductive type in `Syntax/Formula.lean` has 8 constructors:

```
atom | bot | imp | box | all_past | all_future | untl | snce
```

Currently `all_future` (G) and `all_past` (H) are **primitive constructors**, while F (some_future) and P (some_past) are **derived definitions**:

- `some_future(φ) = φ.neg.all_future.neg` (i.e., ¬G(¬φ))
- `some_past(φ) = φ.neg.all_past.neg` (i.e., ¬H(¬φ))

### Target State (Burgess 1982 Section 1.1)

After this task, `Formula` would have 6 constructors:

```
atom | bot | imp | box | untl | snce
```

With G, H, F, P as definitional abbreviations:

| Operator | Burgess | Lean Definition |
|----------|---------|----------------|
| F(φ) | U(φ, ⊤) | `def some_future (φ : Formula) := Formula.untl φ top` |
| P(φ) | S(φ, ⊤) | `def some_past (φ : Formula) := Formula.snce φ top` |
| G(φ) | ¬F(¬φ) | `def all_future (φ : Formula) := (Formula.untl φ.neg top).neg` |
| H(φ) | ¬P(¬φ) | `def all_past (φ : Formula) := (Formula.snce φ.neg top).neg` |

Where `top = Formula.bot.imp Formula.bot` (⊤ = ⊥ → ⊥).

### Semantic Equivalence

The semantic equivalence is exact:

- **truth_at(F(φ), t)**: `∃s > t, φ(s) ∧ ∀r ∈ (t,s), ⊤` simplifies to `∃s > t, φ(s)` (guard is vacuous). This matches `¬truth_at(G(¬φ), t) = ¬(∀s > t, ¬φ(s)) = ∃s > t, φ(s)`.
- **truth_at(G(φ), t)**: `¬truth_at(F(¬φ), t) = ¬(∃s > t, ¬φ(s)) = ∀s > t, φ(s)`. Matches the current direct evaluation.

## Findings

### 1. Reference Count Analysis (Non-Boneyard Only)

| Category | Count | Description |
|----------|-------|-------------|
| Pattern match arms | 122 | `\| all_future ψ =>` or `\| all_past ψ =>` in match/induction |
| Constructor applications | ~700 | `φ.all_future`, `Formula.all_future φ` building formulas |
| Simp/rewrite references | ~88 | `simp [all_future]`, `rw [all_future]` in proofs |
| Total (non-Boneyard) | ~1416 | Across 70 files |
| Boneyard references | ~699 | Can be ignored or updated minimally |

### 2. High-Impact Files (Top 10 by Reference Count)

| File | Count | Nature |
|------|-------|--------|
| Syntax/SubformulaClosure.lean | 115 | Subformula closure computation |
| Metalogic/Bundle/WitnessSeed.lean | 88 | MCS witness construction |
| Metalogic/BXCanonical/Chronicle/PointInsertion.lean | 68 | Chronicle point insertion |
| Syntax/Formula.lean | 62 | Core formula type (source of change) |
| Theorems/Perpetuity/Bridge.lean | 57 | Bridge theorems |
| Examples/BimodalProofStrategies.lean | 57 | Example proofs |
| Metalogic/Bundle/TemporalCoherence.lean | 51 | Temporal coherence proofs |
| Metalogic/Bundle/SuccRelation.lean | 49 | Successor relation |
| Theorems/Perpetuity/Principles.lean | 47 | Perpetuity principles |
| Examples/TemporalProofs.lean | 41 | Example proofs |

### 3. Structural Changes Required

#### 3a. Formula Inductive Type

Remove `all_past` and `all_future` constructors. Add definitions:

```lean
def top : Formula := Formula.bot.imp Formula.bot

def some_future (φ : Formula) : Formula := Formula.untl φ top
def some_past (φ : Formula) : Formula := Formula.snce φ top
def all_future (φ : Formula) : Formula := (some_future φ.neg).neg
def all_past (φ : Formula) : Formula := (some_past φ.neg).neg
```

#### 3b. truth_at Evaluation

Currently `truth_at` has 8 cases. After removal it would have 6. The G/H truth conditions are recovered via the untl/snce + imp cases:

- `truth_at(all_future φ, t)` = `truth_at(¬U(¬φ,⊤), t)` = `¬(∃s > t, ¬φ(s) ∧ ∀r, ⊤)` = `∀s > t, φ(s)` ✓

However, this requires proving semantic equivalence lemmas. The truth evaluation will no longer directly unfold to `∀s > t, φ(s)` for `all_future`; instead it unfolds through multiple layers of imp and untl.

#### 3c. Pattern Match Elimination

Every function that pattern-matches on `Formula` will lose the `all_future`/`all_past` arms. These include:

- `complexity`, `modalDepth`, `temporalDepth`, `countImplications` — need recased to handle G/H via simp lemmas
- `swap_temporal` — critical: currently swaps `all_past ↔ all_future` and `untl ↔ snce`. After the change, G/H are defined via U/S, so swap_temporal only needs `untl ↔ snce` cases (G/H swap automatically).
- `atoms` — subformula computation loses G/H arms
- `beq_refl`, `eq_of_beq` — decidable equality proofs lose 2 cases
- `subformulas` — loses 2 cases
- `subformulaClosure` — major rewrite needed (115 references)
- All proof-by-induction on Formula — lose 2 induction hypotheses

#### 3d. Axiom System Changes

Two axiom constructors reference `all_future` directly:
- `temp_k_dist`: G(φ→ψ) → (G(φ) → G(ψ)) — becomes derived theorem
- `temp_4`: G(φ) → G(G(φ)) — becomes derived theorem

14 axiom expressions use `.all_future` or `.all_past` in their formula construction (e.g., `left_mono_until`, `connect_future`, `modal_future`, `temp_future`, `discrete_propagate_fwd/bwd`). These would use the new `def all_future`/`all_past` directly without change — the Axiom constructor just takes a Formula, so the expressions remain the same syntactically.

#### 3e. Inference Rules

The `temporal_necessitation` rule currently produces `⊢ G(φ)` from `⊢ φ`. After the change, `G(φ)` is `¬U(¬φ,⊤)`, so temporal_necessitation needs reformulation or re-derivation.

#### 3f. Decidability/Tableau

The `SignedFormula` module in `Metalogic/Decidability/` explicitly pattern-matches on `all_future`/`all_past` for tableau rules. The FMP truth preservation (21 references) also pattern-matches.

### 4. Axiom System Simplification Opportunity

After making G/H abbreviations, the following become derivable from the BX Until/Since axioms:

| Current Axiom | Derivability |
|---------------|-------------|
| `temp_k_dist` (G-distribution) | From BX2G (left_mono_until_G) + propositional logic |
| `temp_4` (G-transitivity) | From BX5 (self_accum_until) + BX6 (absorb_until) |
| `serial_future` (⊤ → F(⊤)) | From seriality of the temporal order (needs BX12: F(⊤) ↔ U(⊤,⊤)) |
| `serial_past` (⊤ → P(⊤)) | Mirror of serial_future |

Burgess's axiom system J₀ uses ONLY A1a-A7a (and mirrors), plus temporal generalization (TG). The current system has 45 axiom constructors. Removing temp_k_dist/temp_4 would reduce to 43, with G/H properties derived.

### 5. Existing Sorries Relevant to This Task

- `G_implies_topUntil`: `⊢ G(a) → U(a, ⊤)` — currently sorry (requires BX8, which was removed). After the redefinition, G(a) = ¬U(¬a,⊤) and this becomes a different statement.
- `bot_until_bot_absurd`: `⊢ U(⊥,⊥) → ⊥` — sorry (X(⊥) absurdity)
- ~20 sorries in TemporalDerived.lean related to removed axioms (BX8/BX9)

### 6. Key Risk: Subformula Closure Breakage

The `SubformulaClosure.lean` (115 references) is critical for the decidability/FMP pipeline. Currently, the subformula closure explicitly handles G/H as primitive constructors. After removal:

- Subformulas of `G(φ)` = subformulas of `¬U(¬φ,⊤)` = subformulas of `(U(¬φ,⊤)).imp bot`
- This unpacks to: the formula itself, U(¬φ,⊤), ¬φ, φ, ⊤ (= ⊥→⊥), ⊥
- The closure is LARGER than the current G(φ) closure which is just {G(φ), φ}
- This affects decidability and FMP arguments that bound the closure size

## Decisions

- **Approach**: Full constructor removal as specified, matching Burgess 1982 section 1.1.
- **Axiom handling**: temp_k_dist and temp_4 become derived theorems; remove from Axiom inductive.
- **Temporal necessitation**: Reformulate to produce `⊢ G(φ)` using the new definition.
- **Boneyard**: Minimal updates only (add `all_future`/`all_past` abbreviation imports where needed for compilation).

## Recommendations

### Priority 1: Core Syntax Layer (Formula.lean, Subformulas.lean, SubformulaClosure.lean)

1. Remove `all_future`/`all_past` constructors from `Formula`
2. Add `def top`, `def some_future`, `def some_past`, `def all_future`, `def all_past` as abbreviations
3. Add `@[simp]` lemmas for unfolding: `all_future_def`, `all_past_def`, `some_future_def`, `some_past_def`
4. Update all decidable equality, BEq, complexity, modalDepth, temporalDepth, countImplications, atoms, swap_temporal functions
5. Prove key simplification lemmas for the new definitions

### Priority 2: Proof System Layer (Axioms.lean, Derivation.lean, Substitution.lean)

1. Remove `temp_k_dist` and `temp_4` from `Axiom` inductive (derive from BX axioms instead)
2. Reformulate axiom expressions to use new abbreviations
3. Update temporal_necessitation rule derivation
4. Update Substitution.lean pattern matches

### Priority 3: Semantics Layer (Truth.lean, Validity.lean)

1. Remove `all_future`/`all_past` cases from `truth_at`
2. Prove `truth_at_all_future_iff` and `truth_at_all_past_iff` equivalence lemmas
3. These lemmas bridge the old and new definitions for downstream use

### Priority 4: Metalogic Layer (Soundness, Completeness, Decidability)

1. Update SoundnessLemmas.lean (remove temp_k_dist/temp_4 match arms)
2. Update SubformulaClosure.lean and its downstream users
3. Update BXCanonical pipeline (WitnessSeed, TruthLemma, PointInsertion, etc.)
4. Update Decidability/Tableau rules for G/H

### Priority 5: Theorem and Example Files

1. Update TemporalDerived.lean derived theorem proofs
2. Update Perpetuity theorems
3. Update example files

### Priority 6: Boneyard and Tests

1. Minimal updates to Boneyard for compilation
2. Update test suite

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| SubformulaClosure size explosion (G(φ) subformulas grow from 2 to 6+) | High | Add custom closure lemmas that treat G/H as atomic for closure purposes; or define specialized closure functions |
| Proof breakage cascade (1400+ references) | High | Phased implementation with `lake build` validation at each phase; use `@[simp]` lemmas extensively |
| Temporal necessitation reformulation | Medium | Derive `⊢ φ → ⊢ G(φ)` using temporal_necessitation for U/S + propositional steps |
| FMP/Decidability pipeline breakage | Medium | The tableau currently pattern-matches on G/H; needs new rules for the abbrev-expanded form |
| Performance regression (larger terms) | Low | G(φ) expands to `(untl (φ.imp bot) (bot.imp bot)).imp bot` — 5 constructors vs 1. May slow `simp`/`decide` |
| Boneyard compilation failures | Low | Minimal attention; Boneyard is dead code |

### Critical Decision Point: Subformula Closure Strategy

The biggest technical risk is the subformula closure. Two strategies:

**Strategy A: Transparent abbreviations** — Let G(φ) expand to its full form. SubformulaClosure sees `(untl (φ.neg) top).imp bot` and computes subformulas of that. Pro: simple, matches Burgess exactly. Con: closure size increases, may break decidability bounds.

**Strategy B: Smart abbreviations with custom simp lemmas** — Define G/H as `def` (not `abbrev`) and add custom `subformulas` and `SubformulaClosure` handling that recognizes the G/H pattern and treats it as a single operator. Pro: preserves closure size. Con: more complex, partially undoes the point of the change.

**Recommendation**: Start with Strategy A. If SubformulaClosure size becomes a problem for decidability proofs, add dedicated handling.

## Appendix

### References

- Burgess, J.P. (1982). "Axioms for tense logic I: Since and Until." *Notre Dame Journal of Formal Logic* 23(4).
- Kamp, H. (1968). *Tense Logic and the Theory of Linear Order.* UCLA Ph.D. thesis.
- Reynolds, M. (1994). "Axiomatising U and S over integer time."

### Affected File List (Non-Boneyard, Top 20)

1. Syntax/SubformulaClosure.lean (115 refs)
2. Metalogic/Bundle/WitnessSeed.lean (88 refs)
3. Metalogic/BXCanonical/Chronicle/PointInsertion.lean (68 refs)
4. Syntax/Formula.lean (62 refs)
5. Theorems/Perpetuity/Bridge.lean (57 refs)
6. Examples/BimodalProofStrategies.lean (57 refs)
7. Metalogic/Bundle/TemporalCoherence.lean (51 refs)
8. Metalogic/Bundle/SuccRelation.lean (49 refs)
9. Theorems/Perpetuity/Principles.lean (47 refs)
10. Examples/TemporalProofs.lean (41 refs)
11. Metalogic/ConservativeExtension/ExtFormula.lean (39 refs)
12. Metalogic/Algebraic/TenseS5Algebra.lean (38 refs)
13. Automation/ProofSearch.lean (35 refs)
14. Metalogic/Core/RestrictedMCS.lean (33 refs)
15. Theorems/GeneralizedNecessitation.lean (30 refs)
16. Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean (30 refs)
17. Metalogic/ConservativeExtension/Lifting.lean (29 refs)
18. Examples/TemporalProofStrategies.lean (29 refs)
19. Metalogic/Core/MCSProperties.lean (28 refs)
20. Metalogic/BXCanonical/Frame.lean (27 refs)
