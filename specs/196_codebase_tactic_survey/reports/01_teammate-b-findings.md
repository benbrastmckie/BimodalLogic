# Teammate B: Alternative Approaches

## Key Findings

### Alternative 1: Named Simp Sets for Truth Evaluation

- **Description**: The combination `[truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` appears as identical `simp only` calls 43 times across the codebase. All four iff lemmas are already tagged `@[simp]`, but `truth_at` is a plain `def`, not reducible or simp-tagged, so every call must name it explicitly.
- **Type**: simp set / `@[simp]` attribute change
- **Evidence**:
  - 43 exact occurrences of the full 5-lemma list (grep: `simp only \[truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff\]`)
  - 51 occurrences of `simp only [truth_at]` alone
  - Concentrated in `Metalogic/Soundness.lean` (43 uses in a single file), but also in `Metalogic/SoundnessLemmas.lean` and `Semantics/Validity.lean`
  - Sub-patterns also frequent: `[truth_at, Truth.future_iff]` (17x), `[truth_at, Truth.past_iff]` (15x), `[truth_at, Truth.some_future_iff]` (10x), `[truth_at, Truth.some_past_iff]` (10x)
- **Estimated impact**: Replacing 43 identical 5-lemma `simp only` calls with a macro tactic `simp_truth` would save approximately 85 lines of noise. If `truth_at` were tagged `@[simp]`, the full 5-lemma set could reduce to just `simp`.
- **Comparison to tactic approach**: This is a simp set opportunity, not a tactic. A macro `macro "simp_truth" : tactic => \`(tactic| simp only [truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff])` would be simpler than a custom tactic. Alternatively, adding `@[simp]` to `truth_at` (carefully: check for simp loop risk) would make bare `simp` or `simp only [Truth.future_iff, ...]` sufficient.
- **Risk**: Marking `truth_at` as `@[simp]` may slow compilation via unwanted unfolding; a named simp set macro is safer.

### Alternative 2: `intros_validity` Macro for Soundness Proof Introductions

- **Description**: The boilerplate `intro F M Omega _h_sc τ _h_mem t` appears 132 times in `SoundnessLemmas.lean` alone, plus 39 times in `Soundness.lean` with a frame parameter prefix (`intro T _ _ _ _ F M Omega _h_sc τ _h_mem t`). This pattern unfolds the `is_valid D φ` definition to extract frame/model/history/time variables.
- **Type**: macro
- **Evidence**:
  - `intro F M Omega _h_sc τ _h_mem t` — 132 occurrences, exclusively in `SoundnessLemmas.lean`
  - `intro T _ _ _ _ F M Omega _h_sc τ _h_mem t` — 39 occurrences in `Soundness.lean`
  - Variants in `Validity.lean` and `FrameConditions/Validity.lean` (another 53 combined)
  - Total: 224+ occurrences across 4 files
- **Estimated impact**: A pair of macros would replace 224+ lines with single-word calls:
  ```lean
  macro "intros_validity" : tactic =>
    `(tactic| intro F M Omega _h_sc τ _h_mem t)
  macro "intros_validity_framed" : tactic =>
    `(tactic| intro _ _ _ _ _ F M Omega _h_sc τ _h_mem t)
  ```
- **Comparison to tactic approach**: A macro is preferable here over a full tactic because the pattern is purely syntactic (no proof search needed). A tactic would add elaboration overhead. This is the single highest-frequency verbatim repeat in the entire codebase.

### Alternative 3: Simp Set for Subformulas List Membership

- **Description**: The triple `[subformulas, List.mem_cons, List.mem_append]` appears 26 times as an identical `simp only` call in `Syntax/Subformulas.lean` and `Metalogic/Decidability/SignedFormula.lean`. Variants `[subformulas, List.mem_cons]` (5x) and `[subformulas, List.mem_singleton]` (4x) also appear.
- **Type**: simp set macro
- **Evidence**:
  ```
  grep: "simp only \[subformulas, List.mem_cons, List.mem_append\]" -- 26 matches
  grep: "simp only \[subformulas, List.mem_cons\]" -- 5 matches
  ```
- **Estimated impact**: A `simp_subformulas` macro would reduce 35 near-identical calls:
  ```lean
  macro "simp_subformulas" : tactic =>
    `(tactic| simp only [subformulas, List.mem_cons, List.mem_append, List.mem_singleton])
  ```
- **Comparison to tactic approach**: Pure simp set; no logic needed. Complementary to any tactic work.

### Alternative 4: `push_neg` as Replacement for `simp only [not_and, Classical.not_not]`

- **Description**: The simp call `simp only [not_and, Classical.not_not]` appears 20 times in `EFGames.lean` in an identical context (transforming a hypothesis of the form `¬(P ∧ Q)` and `¬¬R`). Lean 4's `push_neg` tactic handles both rewrites in a single call.
- **Type**: Mathlib integration (tactic replacement)
- **Evidence**:
  - All 20 occurrences are in `Metalogic/WeakCanonical/EFGames.lean`
  - Each is followed by `exact (liftN_iff s u).mp (this ⟨...⟩)` suggesting the simp simplifies a negated conjunction to expose an implication
  - Context: `have := hB u; simp only [not_and, Classical.not_not] at this`
  - `push_neg at this` would achieve the same transformation more idiomatically
- **Estimated impact**: 20 two-word replacements (`push_neg at this` replaces `simp only [not_and, Classical.not_not] at this`). Minor gain, but more idiomatic Lean 4.
- **Comparison to tactic approach**: No custom tactic needed; this is a direct Mathlib tactic substitution.

### Alternative 5: Simp Set for Formula Temporal Unfolding

- **Description**: The combination `[Formula.swap_temporal, truth_at]` appears 25 times in `SoundnessLemmas.lean`. The extended form `[Formula.swap_temporal, Formula.and, Formula.neg, truth_at]` appears 12 times. These appear systematically in "swap" soundness lemmas that prove validity of temporally-swapped formulas.
- **Type**: simp set macro
- **Evidence**:
  ```
  [Formula.swap_temporal, truth_at] -- 25 occurrences (SoundnessLemmas.lean)
  [Formula.swap_temporal, Formula.and, Formula.neg, truth_at] -- 12 occurrences
  [Formula.swap_temporal_all_future, Formula.swap_temporal] -- 10 occurrences
  [Formula.swap_temporal_all_past, Formula.swap_temporal] -- 6 occurrences
  ```
- **Estimated impact**: A `simp_swap_temporal` macro covering the most common variant would replace 25-37 calls in `SoundnessLemmas.lean`.
- **Comparison to tactic approach**: Pure simp set; no tactic logic needed.

### Alternative 6: MCS Membership Helper Pattern

- **Description**: The pattern of proving MCS membership via explicit subset witnesses (`have h_sub : ∀ χ ∈ [φ₁, φ₂, ...], χ ∈ S := by simp [...]`) appears 31 times across `Metalogic/Core/` and `Metalogic/Completeness.lean`. This is paired with `closed_under_derivation` calls (69 total).
- **Type**: helper lemma / macro
- **Evidence**:
  - `have.*h_sub.*: ∀.*∈ \[` -- 31 matches across MCS-related files
  - `closed_under_derivation` -- 69 uses
  - `derives_bot_from_phi_neg_phi` -- 34 uses across 6 files
  - Pattern: build singleton/short list context, prove derivation, provide subset witness, apply `closed_under_derivation`
- **Estimated impact**: A lemma `mcs_mem_of_derivation` could bundle the three-step pattern (weaken theorem, apply modus_ponens to assumption, closed_under_derivation) into a single call. This appears in every file touching MCS properties.
- **Comparison to tactic approach**: Unlike a pure tactic, this could also be expressed as a helper lemma taking the derivation as an argument, avoiding the overhead of TacticM elaboration. A Lean 4 `macro` wrapping the common `have ... simp` + `exact ... closed_under_derivation` chain would also work.

### Alternative 7: `simp only [Formula.and, Formula.neg, truth_at]` Named Simp Set

- **Description**: The combination `[Formula.and, Formula.neg, truth_at]` appears 18 times in `SoundnessLemmas.lean`, and `[Formula.and, Formula.or, Formula.neg, truth_at]` appears 6 times. These unfold derived formula operators alongside truth evaluation.
- **Type**: simp set macro
- **Evidence**:
  ```
  [Formula.and, Formula.neg, truth_at] -- 18 occurrences
  [Formula.and, Formula.or, Formula.neg, truth_at] -- 6+4 occurrences
  ```
- **Estimated impact**: A `simp_formula_truth` macro bundling these would cover ~28 calls.

## Simp Set Analysis

### Most Frequently Co-Occurring Simp Lemmas

| Rank | Lemma | Count | Context |
|------|-------|-------|---------|
| 1 | `truth_at` | 246 | Universal — truth evaluation in all semantic proofs |
| 2 | `Formula.neg` | 156 | Formula unfolding in semantics and soundness |
| 3 | `a'_resp` | 91 | EFGame construction in ExpressivenessGeneral.lean |
| 4 | `ite_true` / `ite_false` | 97 | Chronicle construction in BXCanonical |
| 5 | `Finset.mem_insert` | 85 | Finset membership proofs across Decidability |
| 6 | `Formula.swap_temporal` | 76 | Temporal duality in SoundnessLemmas |
| 7 | `Truth.future_iff` | 71 | Temporal truth unfolding |
| 8 | `List.mem_cons` | 71 | List membership in Subformulas/Decidability |
| 9 | `Truth.past_iff` | 69 | Temporal truth unfolding |
| 10 | `is_U_free` | 51 | U-free formula checking in Separation/Hierarchy |

### Proposed Simp Set Bundles

**Bundle 1: `simp_truth`** (highest priority — 43+ identical calls)
```lean
macro "simp_truth" : tactic =>
  `(tactic| simp only [truth_at, Truth.future_iff, Truth.past_iff,
      Truth.some_future_iff, Truth.some_past_iff])
```

**Bundle 2: `simp_truth_with_formula`** (18 calls in SoundnessLemmas)
```lean
macro "simp_truth_formula" : tactic =>
  `(tactic| simp only [truth_at, Formula.and, Formula.neg,
      Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff])
```

**Bundle 3: `simp_subformulas`** (26 identical calls)
```lean
macro "simp_subformulas" : tactic =>
  `(tactic| simp only [subformulas, List.mem_cons, List.mem_append, List.mem_singleton])
```

**Bundle 4: `simp_swap_temporal`** (25 calls in SoundnessLemmas)
```lean
macro "simp_swap_temporal" : tactic =>
  `(tactic| simp only [Formula.swap_temporal, truth_at])
```

**Bundle 5: `simp_finset_mem`** (targeted to Decidability files)
```lean
macro "simp_finset_mem" : tactic =>
  `(tactic| simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_image,
      Finset.mem_filter, Finset.mem_singleton])
```

## Mathlib Opportunities

### 1. `push_neg` for Negation Normal Form

The project uses `simp only [not_and, Classical.not_not]` in 20 identical spots in `EFGames.lean`. Lean 4's `push_neg` tactic from Mathlib handles this idiomatically and handles a broader class of negation rewrites. Direct drop-in replacement.

### 2. `omega` Already Well-Used

`omega` appears 1,230 times, which is appropriate given the integer arithmetic in temporal reasoning. No underuse detected. The pattern `simp [...]; omega` (using simp to normalize then omega for arithmetic) is the correct Lean 4 idiom and is already in use.

### 3. `ring` Well-Integrated

`ring` is used 355 times in the project. Appropriate for the algebraic structure of temporal orderings.

### 4. `linarith` Used but Limited

66 uses of `linarith` compared to 1,230 `omega` uses. In a project with integer temporal ordering (`ℤ`), `omega` is generally stronger than `linarith` for linear arithmetic over integers. The current balance looks correct.

### 5. Untapped: `tauto` for Propositional Goals

The project uses 545 `by_contra` and 454 `by_cases` invocations. Many of these may involve propositional goals that Lean 4's `tauto` could close directly. No uses of `tauto` were found in the codebase. Audit opportunity: scan for `by_contra h; push_neg at h` + short proof patterns where `tauto` would close the goal.

### 6. Untapped: `positivity` for Positivity Goals

3 uses of `positivity` found. Given the integer linear order structure, `positivity` may have limited additional applicability, but any goals of the form `0 < n` or `0 ≤ n` that currently require manual proof via `omega` could be checked.

### 7. `fin_cases` Already Used

7 uses of `fin_cases` in the codebase — appropriate use in decidability and finite case analyses.

## Cross-Cutting Patterns

### Pattern: The "Validity Proof Boilerplate" (224+ occurrences, 4 files)

Every validity/soundness proof in `Soundness.lean`, `SoundnessLemmas.lean`, `Semantics/Validity.lean`, and `FrameConditions/Validity.lean` begins with a nearly identical intro pattern that unfolds the `is_valid` type:

```
-- Most common (132x in SoundnessLemmas.lean):
intro F M Omega _h_sc τ _h_mem t

-- Frame-parameterized variant (39x in Soundness.lean):
intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
```

This cross-cutting pattern spans 4 files and 224+ proofs. It represents the most significant single verbatim repetition in the codebase. A pair of macros would eliminate this noise entirely.

### Pattern: The Conjunction-Separation in EFGames (20x)

The `simp only [not_and, Classical.not_not] at this` pattern in `EFGames.lean` always appears in a specific semantic context: extracting the consequence of a negated Stavi Until/Since body. All 20 occurrences could be replaced with `push_neg at this`.

### Pattern: MCS Membership Three-Step (31+ times in Core/Completeness)

The idiom for proving MCS membership through derivability:
1. Build `h_sub` witness (`have h_sub : ∀ χ ∈ [...], χ ∈ S := by simp [...]`)
2. Apply derivation tree construction
3. `exact SetMaximalConsistent.closed_under_derivation h_mcs [...] h_sub h_deriv`

This 3-step pattern appears 31+ times. It could be wrapped in a tactic or lemma.

### Pattern: Chronicle Construction dite/ite (89x in BXCanonical)

`CounterexampleElimination.lean` contains 89 `simp only` calls involving `ite_true`, `ite_false`, `dite_true`, `dite_false`, and `↓reduceDIte`. Many appear in pairs within the same proof block:
```lean
simp only [χ', Finset.mem_insert] at ha hb  -- 36 times
simp only [ite_true]                          -- 29 times  
simp only [h_ne, ite_false]                  -- 12 times
```
This suggests a macro `simp_chronicle_mem` or `simp_dite` could bundle the most common combinations.

## Recommendations

### Priority 1 (High Impact, Low Risk): Macro Bundles
1. **`intros_validity`** macro: replaces 224+ identical intro patterns. Pure syntactic macro, zero risk. One line each:
   ```lean
   macro "intros_validity" : tactic := `(tactic| intro F M Omega _h_sc τ _h_mem t)
   ```
2. **`simp_truth`** macro: replaces 43 identical 5-lemma simp calls in Soundness.lean.

### Priority 2 (Medium Impact): Named Simp Set Macros
3. **`simp_subformulas`**: 26+ identical calls in 2 files.
4. **`simp_swap_temporal`**: 25 calls in SoundnessLemmas.lean.
5. **`simp_truth_formula`**: 18-22 calls in SoundnessLemmas.lean.

### Priority 3 (Mathlib Integration)
6. **`push_neg` migration**: Replace 20 `simp only [not_and, Classical.not_not]` calls in EFGames.lean.
7. **`tauto` audit**: Check `by_contra`/`by_cases` proofs for closable propositional goals.

### Architectural Note on `truth_at`
Adding `@[simp]` to `truth_at` itself would eliminate the need to name it explicitly in most simp calls. However, `truth_at` is a recursive definition, and aggressive simp unfolding of recursive definitions risks simp loops. The safer approach is named simp sets (macros). If performance profiling shows `truth_at` unfolding is the bottleneck, `@[reducible]` could be considered, but this should be benchmarked first.

## Confidence Level

**High** for simp set analysis — evidence is direct grep counts of identical strings.

**High** for the `intros_validity` macro — 224 verbatim occurrences across 4 files.

**Medium** for `push_neg` as replacement — the semantic equivalence of `push_neg` with `simp only [not_and, Classical.not_not]` is standard Lean 4 knowledge, but verification that no other rewriting is needed in those 20 specific contexts would require checking each occurrence.

**Medium** for `tauto` opportunities — identifying which `by_contra`/`by_cases` proofs are purely propositional requires per-proof inspection; the 545+454 count suggests substantial opportunity but manual verification needed.

**Low** for MCS membership macro — the three-step pattern has enough variation in the specific formulas/contexts that a single macro may not generalize cleanly without parameters.
