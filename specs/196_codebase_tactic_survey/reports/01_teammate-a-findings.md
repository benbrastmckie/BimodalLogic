# Teammate A: Primary Pattern Discovery

## Scanning Scope

190 Lean files, 92,261 lines (non-Boneyard), plus 26,452 Boneyard lines = ~118,713 total.
Primary active source: `Theories/Bimodal/` minus `Boneyard/` — 92K lines across 149 files.

All occurrence counts are exact grep counts on non-Boneyard files unless noted.

---

## Key Findings

### Pattern Group 1: MCS Axiom Application (mcs_apply)

**Description**: The three-step pattern of (a) constructing a theorem via `DerivationTree.axiom [] _ (Axiom.X ...)`, (b) lifting it into a MCS via `theorem_in_mcs h_mcs h_ax`, and (c) applying it via `SetMaximalConsistent.implication_property h_mcs ... h_formula`. This is the dominant proof pattern in all BXCanonical and Bundle files.

The full pattern occupies 3–4 lines:
```lean
have h_ax := DerivationTree.axiom [] _ (Axiom.until_F φ ψ)
exact SetMaximalConsistent.implication_property w.is_mcs
  (theorem_in_mcs w.is_mcs h_ax) h_until
```
or with an inline `have`:
```lean
exact SetMaximalConsistent.implication_property h_mcs
  (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.absorb_until φ ψ))) h_formula
```

**Occurrences**: 313 `theorem_in_mcs` calls; 336 `DerivationTree.axiom [] _ (Axiom.*)` constructions; 301 `implication_property` calls. Conservative estimate ~200+ distinct MCS-axiom-application proof steps.

**Lines per occurrence**: 3–4 lines

**Top files by frequency**:
- `BXCanonical/Chronicle/PointInsertion.lean`: 63 `theorem_in_mcs` calls
- `BXCanonical/Chronicle/RRelation.lean`: 45
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean`: 34
- `WeakCanonical/ReflexiveCanonical.lean`: 31
- `BXCanonical/Chronicle/CounterexampleElimination.lean`: 21
- `BXCanonical/Frame.lean`: 17
- `BXCanonical/Chronicle/ChronicleConstruction.lean`: 15

**Estimated tactic complexity**: medium (elab that inspects goal formula and applies Axiom constructor by name, then chains theorem_in_mcs + implication_property automatically)

**Estimated line savings**: 3 lines × 200 call sites = ~600 lines

**Proposed tactic**: `mcs_apply h_mcs (Axiom.until_F φ ψ) h_formula` or `mcs_axiom_apply (Axiom.X)` that auto-discovers h_mcs and h_formula from local context.

**Dependencies**: Needs existing `theorem_in_mcs` and `implication_property` — no new theorems required.

---

### Pattern Group 2: Validity Intro Boilerplate (validity_intro)

**Description**: Every validity lemma in `Soundness.lean` and `SoundnessLemmas.lean` opens with the same 2-line boilerplate:
```lean
intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
simp only [truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]
```
(or variations with `h_sc` instead of `_h_sc`, or fewer/different Truth lemmas). The second `simp only [truth_at]` expands the `truth_at` abbreviation into its constituent connective clauses so that the proof can proceed by pure propositional/first-order reasoning.

**Occurrences**: 224 `intro.*F M Omega` patterns; 168 `simp only [truth_at` invocations. Of those, 51 are exactly `simp only [truth_at]`, 38 are `simp only [truth_at, Truth.future_iff, Truth.past_iff, ...]`, and 25 are `simp only [Formula.swap_temporal, truth_at]`.

**Top files**:
- `SoundnessLemmas.lean`: 79 `truth_at` simps, 59+ combined patterns
- `Soundness.lean`: 53 combined patterns
- `Semantics/Truth.lean`: 13
- `Algebraic/ParametricTruthLemma.lean`: 9

**Lines per occurrence**: 2 lines

**Estimated tactic complexity**: low (simple macro: `intro_validity` or `unfold_validity` that expands to the standard pair)

**Estimated line savings**: 224 × 1 saved line each = ~220 lines; could also expand the simp set automatically for larger savings.

**Proposed tactic**:
```lean
macro "intro_validity" : tactic =>
  `(tactic| (intro T _ _ _ _ F M Omega _h_sc τ _h_mem t;
             simp only [truth_at, Truth.future_iff, Truth.past_iff,
                        Truth.some_future_iff, Truth.some_past_iff]))
```

**Dependencies**: None (pure syntactic macro).

---

### Pattern Group 3: Formula Structural Induction (formula_simp_induction)

**Description**: In `Separation/Hierarchy.lean` (3845 lines), `TemporalClosure.lean`, `Duality.lean`, and across SubformulaClosure, there are 167 formula inductions (143 more broadly). Each has the same stereotyped per-case proof:
- `atom _`: `simp [pred, definition]`
- `bot`: `simp [pred, definition]`
- `imp c d ih1 ih2`: `simp [pred] at h; simp [definition, ih1 h.1, ih2 h.2]`
- `box c ih`: `simp [pred] at h; simp [definition, ih h]`
- `untl c d ih1 ih2`: (slightly more complex, often needs `split`)
- `snce c d ih1 ih2`: similar to imp

For predicates like `is_S_free`, `is_U_free`, `junction_depth`, `count_U_subformulas`, almost every case resolves by the same `simp [defn] at h; simp [defn, ih h.1, ih h.2]` pattern. 85 formula inductions occur in the Separation directory alone.

**Occurrences**: 167 formula inductions (143 found by direct grep); 714 formula induction case lines; 1063 `is_U_free` / `is_S_free` / related predicate appearances.

**Top files**:
- `Separation/Hierarchy.lean`: 38 inductions
- `Separation/TemporalClosure.lean`: 22
- `Separation/Duality.lean`: 9
- `Syntax/SubformulaClosure.lean`: ~20+ (110 inductions in total per its structure)

**Lines per occurrence**: 3–8 lines per case × ~8 cases = ~25–50 lines per induction

**Estimated tactic complexity**: medium-high (a `formula_induct_simp` tactic that auto-dispatches non-branching cases via `simp; try omega` and flags the cases needing manual proof)

**Estimated line savings**: If 50% of cases can be auto-handled via `all_goals (try simp [*])`, then ~167 inductions × 4 auto-closable cases × 3 lines = ~2000 lines. Even partial savings are large.

**Proposed approach**: A `simp_formula_induction` tactic that:
1. Dispatches atom/bot/box/imp/snce cases with `simp [*]`
2. Leaves only non-trivial `untl` and special cases for manual proof
3. Works as `first | simp [*] | omega | trivial` applied to each branch

**Dependencies**: Requires well-tagged `@[simp]` lemmas for formula predicates. Existing `is_U_free`, `is_S_free` definitions are already `simp`-tagged in some places.

---

### Pattern Group 4: DerivationTree.modus_ponens Assembly (mp_assemble)

**Description**: In `Theorems/Propositional.lean` (1712 lines), `RestrictedParametricTruthLemma.lean`, `MCSProperties.lean`, and completeness files, proofs manually assemble `DerivationTree.modus_ponens` trees:
```lean
DerivationTree.modus_ponens [φ, φ.imp ψ] φ ψ
  (DerivationTree.assumption _ _ (by simp))
  (DerivationTree.assumption _ _ (by simp))
```
or nested:
```lean
exact DerivationTree.modus_ponens _ _ _ h_neg h_phi
```
This is essentially `modal_search` territory, but many proofs still do it by hand.

**Occurrences**: 451 `DerivationTree.modus_ponens` calls; 450 `DerivationTree.weakening`/`assumption` calls; 130 `.assumption.*by simp` patterns.

**Top files**:
- `BXCanonical/Chronicle/PointInsertion.lean`: 91 weakening/assumption
- `Theorems/Propositional.lean`: 59
- `Metalogic/Algebraic/UltrafilterMCS.lean`: 34
- `Metalogic/Completeness.lean`: 33
- `Core/RestrictedMCS.lean`: 26

**Lines per occurrence**: 2–5 lines (nested calls can span 5+ lines)

**Estimated tactic complexity**: low (existing `modal_search` and `propositional_search` should already close most of these; the question is adoption/refactoring)

**Estimated line savings**: If 40% of 451 modus_ponens calls (≈180 call sites) can be replaced by 1-line `modal_search`, savings ≈ 180 × 3 lines = ~540 lines. Task 193 (codebase refactoring) addresses this directly.

**Dependencies**: Depends on task 185 (extend axiom coverage in `modal_search`).

---

### Pattern Group 5: imp_trans Chains (imp_chain_tactic)

**Description**: In `Theorems/Combinators.lean`, `ModalS5.lean`, `ModalS4.lean`, `TemporalDerived.lean`, many theorems are proved by chaining `imp_trans` applications:
```lean
exact imp_trans step1 step2
-- or
imp_trans
-- or
exact imp_trans (imp_trans a b) c
```
These are propositional entailment chaining proofs. They often appear in 5–20 step sequences.

**Occurrences**: 180 `imp_trans` calls outside definition sites.

**Top files**:
- `Theorems/ModalS5.lean`: ~15 uses
- `Theorems/ModalS4.lean`: ~10 uses
- `Theorems/Propositional.lean`: ~80 uses (lines 35, various)
- `Theorems/TemporalDerived.lean`: ~5 direct uses

**Lines per occurrence**: 1–3 lines

**Estimated tactic complexity**: low (a `chain_implication` tactic or extending `modal_search` to handle multi-step entailment chains automatically)

**Estimated line savings**: ~50–100 lines if chained applications collapse to single `modal_search` calls.

**Dependencies**: Depends on tasks 185, 187 (backward chaining database).

---

### Pattern Group 6: deduction_theorem Boilerplate (deduction_wrap)

**Description**: `deduction_theorem` is used in 143 places to convert between `[φ] ⊢ ψ` and `⊢ φ → ψ`. A very common pattern is:
```lean
have d_neg : Γ ⊢ φ.imp Formula.bot :=
  deduction_theorem Γ φ Formula.bot d_bot
```
or inline in longer proofs. In completeness proofs, it appears multiple times per theorem.

**Occurrences**: 143 non-definition `deduction_theorem` calls.

**Top files**:
- `BXCanonical/Chronicle/RRelation.lean`: ~15
- `Core/MaximalConsistent.lean`: ~5
- `Core/MCSProperties.lean`: ~5
- `Metalogic/Completeness.lean`: ~7

**Lines per occurrence**: 2–3 lines

**Estimated tactic complexity**: low (macro: `intro_deduct` or extending `modal_search` to use deduction theorem internally; task 189 addresses this)

**Estimated line savings**: ~150–200 lines.

**Dependencies**: Task 189 (deduction theorem tactic).

---

### Pattern Group 7: game_tuple Simplification (game_tuple_normalize)

**Description**: In `ExpressivenessGeneral.lean` (4503 lines), there are 134 raw `simp only [game_tuple, ...]` patterns that could use `simp_game_tuple`. The tactic already exists in `EFGameTactics.lean` but is not yet applied back to the existing 134 call sites in the file.

The `EFGames.lean` file (9087 lines) has 22 raw `simp only [game_tuple]` patterns. `ExpressivenessGeneral.lean` has adopted `simp_game_tuple` at 14 call sites but 134 remain raw.

**Occurrences**: 134 raw `simp only [game_tuple,...]` in `ExpressivenessGeneral.lean`; 22 in `EFGames.lean` = ~156 total raw uses that could use existing tactic.

**Lines per occurrence**: 1–3 lines (some inline in simp calls)

**Estimated tactic complexity**: trivial (tactic already exists — this is pure adoption/refactoring)

**Estimated line savings**: ~156 call sites, many already single-line; minor savings ~50 lines but improves readability.

**Dependencies**: EFGameTactics already done (task 195 Component B).

---

### Pattern Group 8: same_order_type Grid Proofs (order_type_grid_dispatch)

**Description**: In `EFGames.lean` (9087 lines) and `ExpressivenessGeneral.lean`, same_order_type goals require introducing indices `i j`, unfolding `game_tuple`, and case-splitting on 4 index categories (x=0, b=n+1, y=n+2, sel). The `same_order_type_grid` macro (task 195 Component A) handles the setup but the 16 resulting subgoals still need manual dispatch.

For ordering subgoals, most are handled by `pivot_chain_order'`, `pivot_chain_order_rev'` (from task 195 Component C), or `order_refl`. The pattern appears 49 times in WeakCanonical.

A **pivot_order elab tactic** (deferred from task 195 Phase 3) was proposed that would auto-discover all arguments from local context via `getLCtx/isDefEq`, eliminating 65 explicit `exact pivot_chain_order' ... ... ... ...` calls in `ExpressivenessGeneral.lean`.

**Occurrences**: 63 `pivot_chain_order` calls in `ExpressivenessGeneral.lean`; 49 `same_order_type` occurrences in WeakCanonical.

**Lines per occurrence**: 1–3 lines (with argument lists)

**Estimated tactic complexity**: high (full elab tactic: getLCtx, iterate over hypotheses, isDefEq matching for bounds and witnesses; ~100 lines of metaprogramming)

**Estimated line savings**: ~65 explicit `pivot_chain_order'` calls × 2–3 lines = ~130–195 lines. Moderate absolute savings but high quality-of-life improvement for EF game proofs.

**Dependencies**: Task 195 Components A/B/C already done. This is Component A improvement and the `pivot_order` elab.

---

### Pattern Group 9: stavi_temporal_truth_mu + depth Induction (stavi_induction)

**Description**: In `EFGames.lean` and `ExpressivenessGeneral.lean`, many proofs proceed by induction on `stavi_depth A` with goals of the form:
```lean
∀ A : StaviFormula, stavi_depth A ≤ r →
  (stavi_temporal_truth_mu M atomMap r x A ↔
   stavi_temporal_truth_mu N atomMap r x' A)
```
These are `formula_agreement`-style goals. The proof structure per StaviFormula case is stereotyped: unfold `stavi_temporal_truth_mu`, apply IH, combine.

**Occurrences**: 379 `stavi_temporal_truth_mu` / `stavi_depth` occurrences; 560 total `stavi_temporal_truth` occurrences; 46 `∀ A, stavi_depth A ≤ r` quantifications.

**Lines per occurrence**: 5–15 lines per StaviFormula case

**Estimated tactic complexity**: high (requires understanding StaviFormula induction; could use `simp [stavi_temporal_truth_mu]` + `omega` for many cases)

**Estimated line savings**: ~300–500 lines if 20% of stavi induction cases can be auto-dispatched.

**Dependencies**: Requires survey of StaviFormula constructors and existing simp lemmas.

---

### Pattern Group 10: Truth Evaluation Unfolding (simp_truth / truth_simp_set)

**Description**: The combination `simp only [truth_at]` (51 occurrences) and `simp only [truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` (38 occurrences) forms a well-defined simp set. A named simp set `truth_simp` would capture these 89+ invocations.

Also: `simp only [Formula.swap_temporal, truth_at]` (25 occurrences), `simp only [Formula.and, Formula.neg, truth_at]` (18 occurrences), `simp only [Separation.int_truth]` (12 occurrences), `simp only [int_truth]` (101 total).

**Occurrences**: 168 `simp only [truth_at...]` invocations; 101 `int_truth` simp invocations.

**Estimated tactic complexity**: trivial (declare `@[simp_set]` attribute groups or macro aliases)

**Estimated line savings**: ~0 lines saved (already single-line), but readability improvement and prevents inconsistent simp sets.

**Dependencies**: None.

---

### Pattern Group 11: int_truth Simp (Separation) (simp_int_truth)

**Description**: The `int_truth` definition (used in `Separation/` files) is unfolded via `simp only [int_truth]` or `simp [int_truth]` in 101 places across 11 files. A `simp_int_truth` macro would standardize this.

**Occurrences**: 101 across `ExpressiveCompleteness.lean` (33), `Separation/Hierarchy.lean` (21), `Separation/TemporalClosure.lean` (8), etc.

**Estimated tactic complexity**: trivial (macro)

**Estimated line savings**: Minor readability gain.

---

## Ranked Inventory

| # | Pattern Group | Occurrences | Est. Lines Saved | Complexity | Priority Score |
|---|---------------|-------------|-----------------|------------|----------------|
| 1 | MCS axiom application (mcs_apply) | 313+ | ~600 | medium | 9.5 |
| 2 | Formula structural induction (formula_simp_induction) | 167 inductions, ~714 case lines | ~1500–2000 | medium-high | 9.0 |
| 3 | DerivationTree.modus_ponens assembly (mp_assemble/modal_search) | 451 | ~540 | low | 8.5 |
| 4 | Validity intro boilerplate (validity_intro) | 224 | ~220 | low | 8.0 |
| 5 | imp_trans chains (imp_chain) | 180 | ~100 | low | 7.5 |
| 6 | deduction_theorem boilerplate (deduction_wrap) | 143 | ~150 | low | 7.5 |
| 7 | stavi induction + depth reasoning | ~65+ occurrences of depth goals | ~300–500 | high | 7.0 |
| 8 | game_tuple normalization (existing tactic adoption) | 156 raw uses | ~50 | trivial | 6.5 |
| 9 | same_order_type + pivot_order elab | 63 pivot calls | ~130–195 | high | 6.0 |
| 10 | Truth simp set naming (simp_truth) | 168 | 0 (readability) | trivial | 5.0 |
| 11 | int_truth simp naming | 101 | 0 (readability) | trivial | 4.5 |

---

## Recommendations

### Existing Tasks to Keep (185–195)

- **185** (extend axiom/derived match): Keep. The MCS axiom application pattern (Pattern 1) depends on `modal_search` having full axiom coverage to subsume the manual `DerivationTree.axiom []` constructions.
- **186** (unify search systems): Keep. Needed for consistency between `modal_search` (TacticM) and `ProofSearch.lean` (computable) once pattern 3 (mp_assemble) is being tackled at scale.
- **187** (lemma database / backward chaining): Keep. Directly enables Pattern 5 (imp_trans chains).
- **188** (weakening-aware search): Keep. Supports Pattern 3 cleanup.
- **189** (deduction theorem tactic): Keep. Directly addresses Pattern 6.
- **190** (modal_norm normalization): Keep. Needed for Pattern 5 (imp_trans) and formula normalization.
- **191** (propositional decision procedure): Keep. Subsumes many Pattern 3 call sites.
- **192** (master tactic dispatch / tm_prove): Keep. Is the integration target for all lower-level tactics.
- **193** (codebase-wide refactoring): Keep. This is the mass-adoption phase for Pattern 3, 4, 6.
- **195** (EF game tactics): Keep. Components B/C/D done. Component A (same_order_type_grid) done. `pivot_order` elab still pending.

### New Tasks Warranted by Survey

**New Task A: MCS Axiom Application Tactic (`mcs_apply`)**
- Addresses Pattern Group 1 (313+ call sites)
- Proposed: `mcs_apply h_mcs (Axiom.X args) h_formula` tactic that wraps `theorem_in_mcs` + `implication_property`
- Priority: HIGH (highest absolute line savings, moderate complexity)
- Should be a separate task before task 193

**New Task B: Formula Structural Induction Simp (`formula_induct_simp` / simp set)**
- Addresses Pattern Group 3 (167 inductions, ~2000 lines of boilerplate)
- Proposed: Tactic that applies `simp [*]` to all non-branching cases in formula inductions
- Priority: HIGH (largest potential savings in Separation/ files)
- Prerequisite: Survey which predicates have complete `@[simp]` coverage

**New Task C: `pivot_order` Elab Tactic (deferred from task 195)**
- Addresses Pattern Group 8 (63 call sites)
- Already specified in task 195 Phase 3 research
- Priority: MEDIUM (localized impact in WeakCanonical/)
- Can be added as subtask to 195 or standalone

**New Task D: Validity Intro Macro (`validity_intro`)**
- Addresses Pattern Group 2 (224 call sites)
- Pure macro, 1 hour of work
- Priority: HIGH (easy win, improves readability of all validity proofs)

**New Task E: Truth Simp Set Declaration**
- Addresses Pattern Groups 10 + 11
- Declare `@[simp]` set aliases or macros for standard truth unfolding
- Priority: LOW (no line savings, readability only)

### Task Dependencies Update

The survey reveals that Pattern Groups 1, 2, and 3 are independent of each other and of tasks 185–195. They can be implemented in parallel:

```
New Task A (mcs_apply): independent → feeds 193
New Task B (formula_induct_simp): independent → feeds 193
New Task D (validity_intro): independent → feeds 193
New Task C (pivot_order): depends on 195 → feeds 193

193 (codebase refactoring): depends on 185, 189, 192, A, B, D, C
```

### Priority Ordering for Implementation

1. New Task D (validity_intro macro) — trivial, high coverage
2. New Task A (mcs_apply) — medium complexity, 600+ lines
3. Task 189 (deduction theorem tactic) — feeds 193
4. Task 185 (extend axiom coverage) — prerequisite for 193
5. New Task B (formula_induct_simp) — high savings in Separation/
6. Task 190 (modal_norm) — complement to 185
7. New Task C (pivot_order elab) — completes 195
8. Tasks 186, 187, 188 (search unification, lemma DB, weakening) — engineering
9. Task 191, 192 (decision procedure, master dispatch) — research-level
10. Task 193 (codebase refactoring) — mass adoption

---

## Evaluation of `pivot_order` Elab Tactic (Deferred from Task 195)

**Assessment**: Worth implementing as a standalone subtask.

- 63 `pivot_chain_order` / `pivot_chain_order'` / `pivot_chain_order_rev'` call sites exist, all in `ExpressivenessGeneral.lean`
- Each call has 4–8 explicit arguments (bound hypotheses) that could be auto-discovered from local context
- The existing `pivot_chain_order'` wrapper (task 195 Component C) reduced from 8 to 6 arguments; the elab tactic would reduce to 0 explicit arguments
- Implementation complexity: ~100 lines of `MetaM` code using `getLCtx`, `isDefEq` matching
- Estimated savings: ~65 call sites × 2 lines = ~130 lines in one file
- **Verdict**: Implement as subtask to task 195 (Component A completion) rather than a new task. The pair-based wrappers already work; the elab tactic is a further convenience. Recommend implementing **after** other higher-priority patterns since this only affects one file.

---

## Confidence Level

**High** for pattern occurrence counts (all from exact grep counts on live codebase).

**Medium** for line savings estimates (based on representative sampling of 20–30 occurrences per pattern; actual savings could be 20–30% lower if some call sites are non-trivial).

**Medium** for complexity estimates (based on existing analogous tactics; `formula_induct_simp` is the highest uncertainty since it depends on which predicates have complete `@[simp]` coverage).

---

## Appendix: File Size Reference

| File | Lines | Primary Patterns |
|------|-------|-----------------|
| `WeakCanonical/EFGames.lean` | 9,087 | game_tuple, stavi_depth, same_order_type |
| `WeakCanonical/ExpressivenessGeneral.lean` | 4,503 | pivot_chain_order, game_tuple, stavi_truth |
| `WeakCanonical/Separation/Hierarchy.lean` | 3,845 | formula_induction (38×), int_truth (21×) |
| `BXCanonical/Chronicle/PointInsertion.lean` | 3,527 | theorem_in_mcs (63×), weakening/assumption (91×) |
| `BXCanonical/Chronicle/CounterexampleElimination.lean` | 3,487 | theorem_in_mcs (21×), by_cases (152×) |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 3,374 | theorem_in_mcs (34×) |
| `SoundnessLemmas.lean` | 2,389 | truth_at simp (79×), validity intro (59×) |
| `WeakCanonical/Separation/DedekindZ.lean` | 2,236 | formula_induction (5×), simp+omega |
| `WeakCanonical/ExpressiveCompleteness.lean` | 2,129 | int_truth simp (33×) |
| `Syntax/SubformulaClosure.lean` | 1,889 | formula_induction (~20+) |
| `Theorems/Propositional.lean` | 1,712 | modus_ponens (59×), weakening (59×) |
