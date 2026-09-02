# Territory D: Tactics, Automation & Cross-Cutting Engineering — Findings

Scope actually read/measured:
- **Automation layer** (read in full): `FormalSystem/Automation/Tactics/{Commands,Deduction,Helpers,PropDecide}.lean` (2,260 lines), `FormalSystem/Automation/AesopRules.lean` (285), `FormalSystem/Automation/Normalization.lean` (1,336, structure + all simp/macro sites), `FormalSystem/Theorems/Combinators.lean`, `FormalSystem/Automation/README.md`, `FormalSystem/Automation/Tactics/README.md`, `.claude/rules/lean4.md`.
- **"Core consumer scope"** used for every per-file census below = the 11 named `Metalogic/*.lean` files + `Metalogic/{SoundnessLemmas,Core,Bundle,Algebraic,Independence}/**` + `Semantics/**` = **80 files / 33,336 lines**.
- **"Whole live scope"** = `FormalSystem/{Metalogic,Semantics}/**` excluding `Boneyard/` = **357 files / 242,036 lines**.
- Validation: 4 `lean_multi_attempt` runs at 3 representative sites (results inline, marked **VALIDATED**). No `lake build`, no files edited.

---

## 1. Assessment

This project has *two* automation layers that do not meet. The first is a large, carefully documented, **almost entirely unused** bespoke tactic suite (`modal_search`, `tm_auto`, `apply_axiom`, `propDecide`, `deduction`, `modalNorm`, …, 2,260 lines in `Tactics/` plus 1,336 in `Normalization.lean`). Outside `Examples/` and `Tests/` the entire suite is invoked **at most 4 times** in the whole library. The second is what the metalogic actually runs on: 464 hand-written `simp only [...]` lists in the core scope, 231 hand-written validity intro-chains, and long `have`-chains. The two layers were built independently and neither knows about the other.

The most urgent problem is not an absence of automation but a *live defect* in the automation that exists. `Automation/Normalization.lean` registers **ten mutually inverse `@[simp]` `rfl` pairs** (`neg_unfold : φ.neg = φ.imp bot` at line 69 against `neg_fold : φ.imp bot = neg φ` at line 800, and nine more) into the **global default** simp set. I confirmed by `lean_multi_attempt` in `Metalogic/Decidability/DecisionProcedure.lean` that plain `simp` on the trivial goal `a.neg = a.neg` dies with *"maximum recursion depth has been reached"*. `FormalSystem.lean` → `FormalSystem/FormalSystem.lean` → `FormalSystem/Automation.lean` → `Normalization`, so **every downstream consumer of `import FormalSystem` inherits a looping simp set** (D-01). A `#lint`/`simpNF` run would have caught this on day one; there is no linter anywhere in the repo and CI runs with `lint: false` **and** `test: false` (D-15).

The second theme is duplication in the soundness layer. `SoundnessLemmas/DenseValidity.lean:297 axiom_swap_valid` (420 lines) and `SoundnessLemmas/FrameClassVariants.lean:46 axiom_swap_valid_general` (354 lines) differ, after comment/whitespace normalization, by only **83 of ~340 lines** — three-quarters of the second is a verbatim copy of the first. Worse, a *third* copy of the same case analysis, `axiom_locally_valid` (298 lines), together with twelve helper lemmas it exclusively consumed, is **completely unreferenced**: 526 of the 1,247 declaration lines in `DenseValidity.lean` (42%, rising to ~53% with transitively-dead helpers) are unreachable from anywhere in the library or test suite. The same 3-line classical helper `and_of_not_imp_not` is independently redefined **five times** across four files (D-05).

The third theme is a missing simp-normal form for truth. `Semantics/BLTruth.lean` shows the maintainer already knows the right pattern — a complete `@[simp]` characterization API (`neg_iff`, `and_iff`, `or_iff`, `diamond_iff`, `always_iff`, …) for the base language. `Semantics/Truth.lean` does not have it: `imp_iff`, `box_iff`, `bot_false` exist but are *not* `@[simp]`, and there is no `and_iff`/`or_iff`/`neg_iff`/`always_iff` at all. The consequence is 279 `simp only [...]` lists mentioning `TruthAt` across the live scope, `Formula.neg` appearing in 144 simp lists and `Formula.and` in 51, and a hand-rolled classical de-conjunction idiom repeated ~60 times. `truth_and_iff` — the exact lemma needed — does exist, but it lives in `Semantics/Correspondence/DurationFrames.lean:298`, is not `@[simp]`, and its own docstring documents the gap.

The good news: the refactoring already landed the hardest piece. `Semantics/Validity.lean`'s binder-shape adapters (`valid.of_forall_total`, `valid.apply`, `ValidIn.of_forall_total`, `SemanticConsequence.of_forall`) are well-designed and well-documented, docstring coverage in the core scope is **91.8%**, there are zero `sorry`s and zero `native_decide` uses, and the `check-module-invariants.sh` harness (15 checks including `#print axioms` baselines) is genuinely excellent — better than most Mathlib-adjacent projects. The automation gap is an *unfinished* layer, not a broken design.

---

## 2. Automation inventory + usage counts (Q1)

"Library" = `FormalSystem/**` excluding `Boneyard/`, `Automation/`, `Examples/`, and doc-comments. "Tests" = `Tests/**`.

| Tactic / macro | Defined at | Purpose (1 line) | Library uses | Tests | Verdict |
|---|---|---|---|---|---|
| `modal_search [n]` / `(depth := n)` | `Tactics/Commands.lean:115,118` | bounded backward proof search on `DerivationTree` | **4** (`FormalSystem/FormalSystem.lean:64`, `Examples/BimodalProofs.lean:219,223,231`) | 120 | near-dead |
| `temporal_search` | `Commands.lean:191` | same, temporal-weighted config | **0** | 32 | dead |
| `propositional_search` | `Commands.lean:250` | same, propositional-weighted | **0** | 32 | dead |
| `tm_auto [n]` | `Commands.lean:305` | alias → `modal_search` (Aesop path abandoned) | **0** | 104 | dead |
| `apply_axiom` | `Helpers.lean:109` | apply a TM axiom matching the goal | **0** | 37 | dead |
| `modal_t` | `Helpers.lean:126` | apply Modal T | **0** | (in 37) | dead |
| `assumption_search` | `Helpers.lean:165` | find matching formula in context | **0** | 29 | dead |
| `modal_k_tactic` / `temporal_k_tactic` | `Helpers.lean:370,390` | apply generalized K rule | **0** | 1 / 1 | dead |
| `modal_4_tactic` / `modal_b_tactic` | `Helpers.lean:412,464` | apply M4 / MB axiom | **0** | 0 | dead |
| `deduction [n]` | `Tactics/Deduction.lean:106` | `Γ ⊢ A→B` ⟹ `A::Γ ⊢ B` | **0** (4 in-file smoke tests only) | 34 | dead in library |
| `undischarge h` | `Deduction.lean:130` | converse of `deduction` | **0** | 7 | dead in library |
| `propDecide` | `Tactics/PropDecide.lean:123` | reflective propositional-tautology closer | **0** | 13 | **dead but high-value** (D-08) |
| `modalNorm` | `Normalization.lean:178` | unfold all 15 derived operators | **0** | 0 | dead |
| `propNorm` / `modalOpNorm` / `temporalNorm` | `Normalization.lean:189,193,198` | selective unfold variants | **0** | 0 | dead |
| `modalNormAt h` / `modalNormAll` | `Normalization.lean:207,220` | hypothesis-targeting unfold | **0** | 0 | dead |
| `modalFold` | `Normalization.lean:843` | refold primitives → derived operators | **0** | 0 | dead |
| `simp_game_tuple` | `Metalogic/WeakCanonical/EFGameTactics.lean:44` | unfold EF-game tuple projections | **44** | 0 | **live** |
| `orderRefl` | `EFGameTactics.lean:119` | discharge reflexive order-type goals | **8** | 0 | live |
| `sameOrderTypeGrid` / `…Uh` | `EFGameTactics.lean:297,315` | grid of order-type obligations | **5 / 3** | 0 | live |
| `game_tuple_unfold` | `EFGameTactics.lean:59` | variant of `simp_game_tuple` | **4** | 0 | live |
| `extract_order h i j` | `EFGameTactics.lean:328` | pull an order fact out of a hypothesis | **3** | 0 | live |
| `orderRev` | `EFGameTactics.lean:223` | reversed order-type goals | **1** | 0 | live |

**Simp / aesop rule sets:**

| Rule set | Where | Members | Uses |
|---|---|---|---|
| *(none — no `register_simp_attr` anywhere in the repo)* | — | — | — |
| Aesop **default** set (no `declare_aesop_rule_sets`) | `AesopRules.lean:78–283` | 8 `safe apply`, 6 `safe forward`, 4 `norm unfold` | `aesop` is called **0** times in the core scope, **20** times in the whole live scope — all 20 in `WeakCanonical/Kamp/NfMultiAnchorBridge/*`, none of which is in `AesopRules.lean`'s import closure, so **no call site ever sees these rules** |
| `@[simp]` unfold set | `Normalization.lean:69–161` (21 lemmas) | derived-operator unfold, all `rfl` | causes D-01 |
| `@[simp]` fold set | `Normalization.lean:800–834` (10 lemmas) | exact inverses of the above | causes D-01 |

**Is `Helpers.lean` (1,210 lines) at the right level of abstraction?** Partly. It contains three distinct concerns that should be three files: (a) *user-facing tactics* — `apply_axiom`, `modal_t`, `assumption_search`, `modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic` (lines 109–515); (b) *reusable `MetaM` plumbing* — `extractDerivationGoal`, `isNilContext`, `formulaHead`, `lemmaConclusionHead`, `buildContextExpr` (516–1000), which is the only part `PropDecide.lean` and `Deduction.lean` actually reuse (`extractDerivationGoal`, `isNilContext`); (c) *the search engine* — `tryAxiomMatch`, `tryLemmaMatch`, `tryModusPonens`, `tryModalK`, `tryTemporalK`, `searchProof` (545–1210), which is really `ProofSearch/`'s business. It is a grab-bag, but a *coherently ordered* one with a genuine factory abstraction (`mkOperatorKTactic`, line 323, correctly parameterising the two K tactics). The split is worth doing only if the suite is kept at all (see D-02).

---

## 3. Simp / proof-shape / hot-spot census (Q2–Q5)

### 3.1 Simp discipline (Q2)

| Metric | Core scope (33,336 lines) | Whole live scope (242,036 lines) |
|---|---:|---:|
| bare `simp` (no `only`, no `[…]`, no `at`) | 173 | — |
| `simp only [...]` | 464 | — |
| `simp [...]` | 78 | — |
| `simp … at …` (any form) | 84 | — |
| `simp_all` | 2 | — |
| `simp at *` | 1 | — |
| `@[simp]` attributes | 60 | 191 |
| `theorem`/`lemma` declarations | 976 | 5,298 |
| **`@[simp]` per theorem** | 6.1% | **3.7%** |
| `simp only` lists mentioning `TruthAt` | 229 | 279 |
| `simp only` lists mentioning `Formula.neg` | — | 144 |
| `simp only` lists mentioning `Formula.and` | — | 51 |
| `simp only` lists >160 chars | 0 | 0 |

Three files in the core scope have **zero** `@[simp]` lemmas while writing large numbers of ad-hoc lists:

| File | `simp only [` | `@[simp]` |
|---|---:|---:|
| `Metalogic/SoundnessLemmas/DenseValidity.lean` | 115 | 0 |
| `Metalogic/Soundness.lean` | 75 | 0 |
| `Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 50 | 0 |

Most-repeated `simp only` lists across the whole live scope (the named-simp-set candidates):

| Count | List |
|---:|---|
| 108 | `[AtomEval]` |
| 74 | `[TruthAt]` |
| 67 | `[List.mem_cons, List.not_mem_nil, or_false]` |
| 64 | `[AtomEval, Fin.cons]` |
| 43 | `[StaviTemporalTruthMu]` |
| 32 | `[TemporalTruth]` |
| 27 | `[Formula.swapTemporal, TruthAt]` |
| 26 | `[List.mem_cons]` |
| 21 | `[TruthAt, Truth.future_iff]` |
| 14 | `[TruthAt, Truth.past_iff]` |
| 12 | `[Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]` |
| 12 | `[Formula.and, Formula.neg, TruthAt]` |
| 11 | `[TruthAt, Truth.some_past_iff]` |
| 11 | `[TruthAt, Truth.some_future_iff]` |

Simp-normal status of the truth clauses (`Semantics/Truth.lean`), with usage counts across the live scope:

| Lemma | Line | `@[simp]`? | Uses |
|---|---:|---|---:|
| `Truth.bot_false` | 182 | **no** | 7 |
| `Truth.imp_iff` | 192 | **no** | 3 |
| `Truth.atom_iff_of_domain` | 204 | **no** | **0** |
| `Truth.atom_false_of_not_domain` | 221 | **no** | **0** |
| `Truth.box_iff` | 237 | **no** | 1 |
| `Truth.some_future_iff` | 249 | yes | 43 |
| `Truth.some_past_iff` | 266 | yes | 26 |
| `Truth.future_iff` | 283 | yes | 77 |
| `Truth.past_iff` | 301 | yes | 54 |
| `Truth.strong_release_iff` | 320 | yes | **0** |
| `Truth.strong_trigger_iff` | 334 | yes | **0** |
| *(missing)* `and_iff` / `or_iff` / `neg_iff` / `top_true` / `diamond_iff` / `always_iff` | — | — | — |

Compare `Semantics/BLTruth.lean:137–195`, which has all of `neg_iff`, `top_true`, `and_iff`, `or_iff`, `diamond_iff`, `somePast_iff`, `someFuture_iff`, `always_iff` as `@[simp]`.

### 3.2 Proof shapes (Q3)

Validity intro-chains across the whole live scope (231 `intro F …` sites total):

| Count | Chain |
|---:|---|
| 119 | `intro F M τ _hτ t` |
| 40 | `intro F M τ _h_mem t` |
| 13 | `intro F M τ h_mem t` |
| 9 | `intro F M τ hτ t` |
| 6 | `intro F hF M tau h_mem t` |
| 4 | `intro F hF M τ hτ t h_ctx` |
| 4 | `intro F _ h_lub M τ h_mem t h_ant` |
| 3 | `intro F _ _ _ _ M τ hτ t` |
| 3 | `intro F _h_succ _h_pred _h_succ_arch _h_pred_arch M τ _h_mem t` |
| ~30 | other one-off variants |

In `Soundness.lean` + `SoundnessLemmas/**` alone: `intro F M τ _hτ t` ×117, `intro F M τ _h_mem t` ×40, `intro F M τ h_mem t` ×12.

MCS-membership idioms across the whole live scope:

| Lemma | Uses |
|---|---:|
| `theorem_in_mcs` (`Core/MaximalConsistent.lean:491`) | 340 |
| `SetMaximalConsistent.implication_property` (`Core/MCSProperties.lean:157`) | 315 |
| `SetMaximalConsistent.negation_complete` (`MCSProperties.lean:182`) | 139 |
| `set_lindenbaum` | 77 |
| `SetMaximalConsistent.closed_under_derivation` | 38 |
| `SetMaximalConsistent.neg_excludes` (`MCSProperties.lean:371`) | 37 |

Classical-reasoning idioms in the core scope: `by_contra` ×146, `push Not`/`push_neg` ×49, `exfalso` ×58, `exact h_conj (fun …)` (the hand-rolled de-conjunction) ×60.

Derivation combinators (`Theorems/Combinators.lean`) — 22 exported; `necG` is the only one with zero uses outside its own file; `impTrans` (117), `identity` (194), `pairing` (39), `notNotIntro` (20), `bCombinator` (13), `combineImpConj` (13) are live. This layer is healthy.

### 3.3 Hot spots — 20 longest proofs in the core scope (Q4)

| Lines | Site | Declaration | Dominant tactic mix |
|---:|---|---|---|
| 420 | `SoundnessLemmas/DenseValidity.lean:297` | `axiom_swap_valid` | `intro`×98, `exact`×88, `simp only`×48, `have`×22, `by_contra`×17 |
| 354 | `SoundnessLemmas/FrameClassVariants.lean:46` | `axiom_swap_valid_general` | `exact`×79, `intro`×78, `simp only`×42, `have`×19 |
| 298 | `SoundnessLemmas/DenseValidity.lean:970` | `axiom_locally_valid` **(dead)** | `exact`×77, `intro`×68, `simp only`×25 |
| 239 | `Semantics/Truth.lean:450` | `time_shift_preserves_truth` | `have`×64, `exact`×33, `intro`×14 |
| 230 | `Semantics/TaskFrame.lean:493` | `interpolates_of_comp` | nested `have`/`constructor` |
| 215 | `Metalogic/Conservativity.lean:42` | `forward` | single giant `cases` |
| 165 | `Semantics/TaskFrame.lean:1758` | `backward_comp` | `have`×6, `constructor`×2 |
| 149 | `Metalogic/Bundle/SuccRelation.lean:406` | `single_step_forcing_past` | `have`×13, `use`×5 |
| 139 | `Semantics/Extension/PeriodicExtension.lean:156` | `extend_periodic` | **`omega`×39**, `rw`×17, `have`×16 |
| 137 | `Metalogic/Core/RestrictedMCS/Basic.lean:137` | `restricted_mcs_negation_complete` | `have`×24 |
| 128 | `Metalogic/Algebraic/UltrafilterMCS.lean:782` | `ultrafilter_correspondence` | `have`×16 |
| 125 | `Metalogic/Algebraic/FlowFrame.lean:678` | `bundleFlow_truth_lemma` | `have`×19, `intro`×17 |
| 122 | `Metalogic/Core/DeductionTheorem.lean:325` | `deductionTheorem` | `exact`×13, `have`×13 |
| 119 | `Metalogic/Algebraic/BooleanStructure.lean:242` | `le_sup_inf_quot` | **`have`×31**, `induction`×3 |
| 116 | `Metalogic/Algebraic/UltrafilterMCS.lean:360` | `mcsToSet_compl_or` | `have`×26 |
| 110 | `Metalogic/Algebraic/UltrafilterMCS.lean:149` | `mcsToSet_mem_of_le` | `have`×23 |
| 108 | `Metalogic/Algebraic/UltrafilterMCS.lean:674` | `ultrafilterToSet_mcs` | `have`×18, `apply`×8 |
| 105 | `Semantics/Extension/Constraint.lean:288` | `exists_mem_subset_inter` | `rcases`×13, `refine`×13 |
| 104 | `Metalogic/Core/DeductionTheorem.lean:221` | `deduction_with_mem` | `exact`×13, `have`×10 |
| 103 | `Metalogic/Algebraic/UltrafilterMCS.lean:565` | `fold_le_of_derives` | `have`×12 |

`UltrafilterMCS.lean` occupies 5 of the top 20 and `BooleanStructure.lean` 1 — together the `Algebraic/` layer is the biggest `have`-chain hot spot in the project.

### 3.4 Performance signals (Q5)

| Signal | Count | Location |
|---|---:|---|
| `set_option maxHeartbeats` | 51 | 16 files; **24 in `Decidability/Verified/Termination/MintBound.lean`** alone |
| `maxHeartbeats 4000000` (the ceiling used) | 18 | 15× `MintBound.lean`, 3× `SubformulaProperty.lean` |
| `set_option synthInstance.maxHeartbeats 2000` | 2 | `Semantics/TemporalOrder.lean:178,181` — note this *lowers* the budget (fail-fast for a diverging instance search), i.e. it is a *symptom marker*, not a bump |
| `set_option maxRecDepth` | 0 | (one prose mention at `Decidability/Correctness.lean:139`) |
| `set_option linter.* false` | 7 | `unusedSectionVars` ×3 (`Semantics/Ultraproduct/*`), `unusedVariables` ×2 (`Verified/Bridge/RegionFrame.lean`), `unusedTactic` ×2 (`MintBound.lean`) |
| `omega` | 191 (core) | concentrated in `Extension/PeriodicExtension.lean` (39 in one proof) |
| `linarith` | 55 (core) | |
| `decide` | 24 (core) / 1,350 (whole, mostly `decide_eq_true_eq` in simp lists) | |
| `native_decide` | **0** | (5 prose mentions documenting its removal — good) |
| `sorry` | **0** structural | |

The one concrete instance-search pain signal is `TemporalOrder.lean:178,181`. There is no evidence of deep typeclass-hypothesis stacks elsewhere; the `Sat fc F`/`of_forall` adapter design in `Validity.lean:377–530` explicitly exists to keep frame conditions *out* of instance search, and its docstrings say so.

---

## 4. Findings

### D-01. `Normalization.lean` registers ten mutually inverse `@[simp]` pairs — plain `simp` loops library-wide

- **Severity**: Critical
- **Category**: performance
- **Anchors**: `FormalSystem/Automation/Normalization.lean:69` (`neg_unfold`) vs `:800` (`neg_fold`); `:72`/`:803` (`top`); `:75`/`:822` (`next`); `:78`/`:826` (`prev`); `:83`/`:806` (`and`); `:91`/`:810` (`diamond`); `:95`/`:814` (`some_future`); `:99`/`:818` (`some_past`); `:105`/`:830` (`all_future`); `:109`/`:834` (`all_past`). Import path: `FormalSystem.lean` → `FormalSystem/FormalSystem.lean:7` → `FormalSystem/Automation.lean:20`.
- **Description**: `Normalization.lean` declares 21 `@[simp]` *unfold* lemmas (lines 69–161) and 10 `@[simp]` *fold* lemmas (lines 800–834) that are exact inverses, all `rfl`, all in the **global default** simp set — no `scoped`, no `attribute [-simp]`, no priority annotation anywhere in the file. Ten unfold/fold pairs therefore rewrite in both directions.
  **VALIDATED** by `lean_multi_attempt` at `Metalogic/Decidability/DecisionProcedure.lean:309` (a file in `Normalization`'s import closure): the goals `∀ a : Formula, a.neg = a.neg` and `∀ a b : Formula, a.and b = a.and b`, closed by `simp`, both produce
  > `Tactic 'simp' failed with a nested error: maximum recursion depth has been reached`.
  Blast radius: **25 `FormalSystem` modules + 18 `Tests` modules** transitively import `Normalization`, and because `FormalSystem/Automation.lean:20` is in `FormalSystem/FormalSystem.lean`'s import list, **`import FormalSystem` alone is enough** — any external consumer of the library gets the looping default simp set.
  Corroborating evidence that this is already biting: `Metalogic/Decidability/Correctness.lean:139` carries a docstring explaining that "an unrestricted `simp at h` exceeds `maxRecDepth`", blaming decision-procedure evaluation — but that file *is* in `Normalization`'s closure and the goal there is about `φ.neg`, so the fold/unfold loop is at least a co-cause and the recorded diagnosis is probably wrong.
- **Impact**: `simp` is unusable (not merely slow — it errors) in 43 modules and for every downstream user. It also silently changes the meaning of `simp` for anyone who adds a new module under `Automation/` or `Decidability/`. This is the single highest-risk item for publication: a reviewer's first `import FormalSystem; example : … := by simp` fails.
- **Recommendation**: Take *both* families out of the default set and expose them as named sets. Minimal, mechanical fix:
  ```lean
  register_simp_attr formula_unfold   -- derived operators → primitives
  register_simp_attr formula_fold     -- primitives → derived operators (inverse; never combine)

  -- lines 69–161: @[simp] ⟶ @[formula_unfold]
  @[formula_unfold] theorem neg_unfold (φ : Formula) : φ.neg = φ.imp bot := rfl
  -- lines 800–834: @[simp] ⟶ @[formula_fold]
  @[formula_fold]   theorem neg_fold  (φ : Formula) : φ.imp bot = neg φ := rfl

  macro "modalNorm" : tactic => `(tactic| simp only [formula_unfold])
  macro "modalFold" : tactic => `(tactic| simp only [formula_fold])
  ```
  This also *shrinks* the file: `modalNorm`/`modalNormAt`/`modalNormAll`/`modalFold` (lines 178–226, 843–…) each currently re-list all 21 lemma names by hand, four times over. Add a regression example in `Tests/BimodalTest/Automation/NormalizationTest.lean` (`example (a : Formula) : a.neg = a.neg := by simp`) so the loop cannot come back.
- **Effort**: S (attribute rename + 4 macro bodies + 1 test)
- **Depends on**: —

### D-02. The bespoke tactic suite (≈3,600 lines) is used at most 4 times by the library it was written for

- **Severity**: High
- **Category**: organization
- **Anchors**: `Automation/Tactics/{Commands,Helpers,Deduction,PropDecide}.lean` (742+1210+150+158 = 2,260 lines); `Automation/Normalization.lean` (1,336); `Automation/AesopRules.lean` (285). Only live call sites: `FormalSystem/FormalSystem.lean:64`, `FormalSystem/Examples/BimodalProofs.lean:219,223,231` (all `modal_search`).
- **Description**: See the Q1 table in §2. Of 20 declared tactics/macros, **14 have zero library uses and zero test uses combined outside their own defining file**; 4 more are test-only (104 `tm_auto`, 37 `apply_axiom`, 34 `deduction`, 13 `propDecide` uses live entirely in `Tests/`). The only custom tactics with real production usage are the six in `Metalogic/WeakCanonical/EFGameTactics.lean` (68 sites) — which are *not* part of the `Automation/Tactics/` suite and were written by the EF-game development for itself.
- **Impact**: ~3,600 lines of maintained-but-unexercised metaprogramming. It has to keep compiling on every Lean/Mathlib bump, it is documented as the project's automation story in three READMEs, and it is the first thing a reviewer will open. Meanwhile the actual proofs run on hand-written `simp only` lists.
- **Recommendation**: Split the suite by evidence, do not delete wholesale. (a) **Promote** `propDecide` — it has real targets (D-08). (b) **Promote** `deduction`/`undischarge` — the Prop-level `Derivable.deduction` is used 6 times and `Core/DeductionTheorem.lean` is a top-20 hot spot; the tactic form has never been tried in the metalogic. (c) **Retire to `Boneyard/`** `temporal_search`, `propositional_search`, `tm_auto`, `modal_4_tactic`, `modal_b_tactic`, `modalNormAt`, `modalNormAll`, `modalFold`, and the `SearchConfig` weight machinery (`Commands.lean:25–60`) unless a benchmark justifies them. (d) Keep `modal_search` as the pedagogical entry point it actually is, and say so in the README rather than presenting it as library infrastructure.
- **Effort**: M
- **Depends on**: D-08, D-14

### D-03. `axiom_swap_valid` and `axiom_swap_valid_general` are 76% verbatim duplicates (763 lines total)

- **Severity**: Critical
- **Category**: duplication
- **Anchors**: `Metalogic/SoundnessLemmas/DenseValidity.lean:297–716` (`axiom_swap_valid`, 420 lines); `Metalogic/SoundnessLemmas/FrameClassVariants.lean:46–399` (`axiom_swap_valid_general`, 354 lines). Consumers: `Metalogic/Soundness.lean:1333` (general), `:1337,1341` (dense).
- **Description**: Both prove `IsValid D φ.swapTemporal` by `cases h with` over the same ~35 `Axiom` constructors. After stripping comments and normalising indentation, `diff` reports only **83 changed lines out of ~340**, and several of those are pure reorderings of a `simp only` list (e.g. `[Formula.swap_temporal_all_future, Formula.swap_temporal_some_past, …]` vs the same two names swapped, `DenseValidity.lean:390` vs `FrameClassVariants.lean:98`). The genuine differences are: two extra dense-only cases (`density`, `dense_indicator`) in the first; and four cases where the *general* version already delegates to a named lemma (`axiom_temp_linearity_past_valid`, `axiom_temp_linearity_valid`, `axiom_P_since_equiv_valid`, `axiom_F_until_equiv_valid`) while the dense version inlines 22–24 lines each.
  The asymmetry is telling: `Soundness.lean:1330–1343` calls `axiom_swap_valid_general` for the whole `Base` branch and calls the 420-line `axiom_swap_valid` for exactly **two** cases (`Axiom.density`, `Axiom.dense_indicator`). ~380 of its 420 lines exist only to be unreachable in practice.
- **Impact**: Every future axiom added to `Axiom` must be proved swap-valid twice, in two files, in two idioms. Any divergence between the copies is invisible (both still compile). This is the largest single duplication in the reviewed scope.
- **Recommendation**: Finish the extraction the file already started. `DenseValidity.lean` **already contains** per-axiom named lemmas for 9 base cases (`axiom_prop_k_valid` … `axiom_modal_k_dist_valid`, lines 717–801) and 3 swap cases (`swap_axiom_mt_valid`/`m4`/`mb`, lines 50–97). Extend that to every case, then both master theorems become a dispatch table:
  ```lean
  theorem axiom_swap_valid_general (φ : Formula) (h : Axiom φ)
      (h_fc : h.minFrameClass ≤ FrameClass.Base) : IsValid D φ.swapTemporal := by
    cases h with
    | prop_k ψ χ ρ => exact swap_axiom_prop_k_valid ψ χ ρ
    | prop_s ψ χ   => exact swap_axiom_prop_s_valid ψ χ
    …
    | density _ | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

  theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) [DenselyOrdered ↑D]
      (h_fc : h.minFrameClass ≤ FrameClass.Dense) : IsValid D φ.swapTemporal := by
    cases h with
    | density a  => exact swap_axiom_density_valid a
    | dense_indicator => exact swap_axiom_dense_indicator_valid
    | _ => exact axiom_swap_valid_general φ ‹Axiom φ› (by …)   -- base branch delegates
  ```
  Estimated result: 763 lines → ~120 lines of dispatch + ~250 lines of per-case lemmas, single-sourced. Current inline/delegated ratio in `axiom_swap_valid` is **33 inline vs 12 delegated**.
- **Effort**: L
- **Depends on**: D-04 (do the deletion first — it removes the third copy)

### D-04. 526 of 1,247 declaration lines in `DenseValidity.lean` are unreachable dead code

- **Severity**: High
- **Category**: organization
- **Anchors**: `Metalogic/SoundnessLemmas/DenseValidity.lean` — `axiom_locally_valid:970` (298 lines, `private`, **0 references anywhere**), `swap_axiom_t4_valid:98`, `swap_axiom_ta_valid:115`, `swap_axiom_tl_valid:143`, `mp_preserves_swap_valid:228`, `modal_k_preserves_swap_valid:244`, `temporal_k_preserves_swap_valid:260`, `weakening_preserves_swap_valid:275`, `and_extract:280`, `axiom_temp_k_dist_valid:802`, `axiom_temp_4_valid:810`, `axiom_temp_a_valid:818`, `axiom_temp_l_valid:831`, `axiom_density_valid:960`, `mp_preserves_valid:1268`, `necessitation_preserves_local_valid:1277`, `temporal_necessitation_preserves_local_valid:1287`.
- **Description**: Per-declaration reachability scan over the whole live tree plus `Tests/`: 17 declarations totalling **526 lines** occur exactly once in the entire repository — their own declaration. A further 9 (`axiom_prop_k_valid:717` … `axiom_modal_future_valid:855`, ~134 lines) are referenced *only* from inside `axiom_locally_valid`, so they are transitively dead too: **~660 of 1,247 declaration lines (53%)**. `axiom_locally_valid` is `private`, so nothing outside the file could ever have used it. `Soundness.lean:1280–1325` reimplements the same per-axiom dispatch (`modal_future_valid`, `density_valid`, `dense_indicator_valid`, `prior_UZ_valid`, …) independently — this is the *fourth* copy of the case analysis.
  Repository-wide: **146 declarations in the 80-file core scope** are declared and never referenced anywhere in `FormalSystem/`, `Tests/`, or any `.md`/`.typ`/`.tex` document. Top files: `DenseValidity.lean` (17), `SetConsequence.lean` (11), `Semantics/Validity.lean` (11), `Bundle/CanonicalTaskRelation.lean` (10), `Semantics/TaskFrame.lean` (10), `Semantics/WorldHistory.lean` (10), `Bundle/TemporalCoherence.lean` (9), `Soundness.lean` (8).
- **Impact**: A 1,297-line file of which half is unreachable is the worst kind of maintenance burden: it compiles, it looks authoritative, and it silently diverges from the live path. It also inflates the apparent size of the soundness development by ~2×.
- **Recommendation**: Delete `axiom_locally_valid` and its 12 exclusive helpers plus the 6 orphaned `*_preserves_*` lemmas (a `git rm`-scale change, ~660 lines), or move them to `Boneyard/` if the maintainer wants the record. Then run the same scan over the remaining 129 core-scope orphans and triage into (a) genuinely dead → delete, (b) intended public API → add a `Tests/` witness or a README mention so the scan stops flagging them. Note that many of the `Semantics/Validity.lean` and `Semantics/TaskFrame.lean` entries are plausibly deliberate API surface (`validDense_iff_validIn_dense:815`, `trivialFrame_serial:1333`), which is exactly why a witness is worth adding.
- **Effort**: M
- **Depends on**: —

### D-05. `and_of_not_imp_not` is independently redefined five times

- **Severity**: High
- **Category**: duplication
- **Anchors**: `Metalogic/Soundness.lean:153`; `Metalogic/SoundnessLemmas/DenseValidity.lean:826`; `Metalogic/SoundnessLemmas/DenseValidity.lean:280` (as `and_extract`, dead); `Metalogic/SoundnessLemmas/CoValidity.lean:61`; `Metalogic/Decidability/Verified/Decidable.lean:2563` (as `and_of_not_imp_not'`).
- **Description**: Five byte-identical `private theorem {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q` declarations, in four files, under three different names. Call sites: `Soundness.lean` ×6, `CoValidity.lean` ×2, `Decidable.lean` ×3, `DenseValidity.lean` ×0 (both of its copies are dead). This is the classical de-conjunction step forced by `Formula.and` being `¬(φ → ¬ψ)`.
- **Impact**: The duplication is a *symptom*: the reason five files needed it is that there is no `Truth.and_iff` (D-06/D-07). Fixing the root cause removes most of the call sites too.
- **Recommendation**: Promote one copy to `Metalogic/SoundnessLemmas/Core.lean` (107 lines, already the shared-helpers module for this layer) as a public `theorem and_of_not_imp_not`, delete the other four. Better: land D-07 first, after which most of the 11 call sites become `(truth_and_iff …).mp h`.
- **Effort**: S
- **Depends on**: D-07

### D-06. `Truth.lean` has no simp-normal form; `BLTruth.lean` shows the pattern the project already knows

- **Severity**: High
- **Category**: abstraction
- **Anchors**: `Semantics/Truth.lean:182` (`bot_false`), `:192` (`imp_iff`), `:237` (`box_iff`) — none `@[simp]`; `:249,266,283,301,320,334` — `@[simp]`. Contrast `Semantics/BLTruth.lean:137–195` (`neg_iff`, `top_true`, `and_iff`, `or_iff`, `diamond_iff`, `somePast_iff`, `someFuture_iff`, `always_iff`, all `@[simp]`).
- **Description**: The primitive-constructor truth clauses are stated as lemmas but not registered, and the derived Boolean/modal connectives have no truth lemma at all in the main language. Consequently proofs reach for `simp only [TruthAt]` — unfolding the *equation compiler definition* rather than rewriting with characterisation lemmas — at **279 sites** across the live scope, and hand-unfold `Formula.neg` (144 simp lists) and `Formula.and` (51 simp lists).
  **VALIDATED** at `DenseValidity.lean:302` via `lean_multi_attempt`: `simp only [Formula.swapTemporal, Truth.imp_iff]` produces exactly the same goal as the file's `simp only [Formula.swapTemporal, TruthAt]` — the lemma is a drop-in replacement, it is simply not in the simp set.
  Also note `Truth.strong_release_iff` and `Truth.strong_trigger_iff` are `@[simp]` with **0** uses, while `Truth.atom_iff_of_domain` and `atom_false_of_not_domain` are *not* `@[simp]` and also have 0 uses — the attribute assignment appears unconsidered rather than designed.
- **Impact**: Every truth-level proof re-derives the connective semantics inline. It is the direct cause of D-05, of the 60 hand-rolled `exact h_conj (fun …)` de-conjunctions, and of most of the length of the top-3 hot spots.
- **Recommendation**: Mirror `BLTruth.lean` exactly, in `Truth.lean`, under the existing `namespace Truth`:
  ```lean
  @[simp] theorem imp_iff  … (already exists at :192 — just add the attribute)
  @[simp] theorem box_iff  … (already exists at :237 — just add the attribute)
  @[simp] theorem bot_false … (already exists at :182 — just add the attribute)
  @[simp] theorem neg_iff (φ : Formula) : TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ := Iff.rfl
  @[simp] theorem top_true : TruthAt M τ t Formula.top := id
  @[simp] theorem and_iff (φ ψ : Formula) :
      TruthAt M τ t (φ.and ψ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ) := by
    simp only [Formula.and, Formula.neg, TruthAt]; tauto
  @[simp] theorem or_iff (φ ψ : Formula) :
      TruthAt M τ t (φ.or ψ) ↔ (TruthAt M τ t φ ∨ TruthAt M τ t ψ) := by
    simp only [Formula.or, Formula.neg, TruthAt]; tauto
  @[simp] theorem diamond_iff (φ : Formula) :
      TruthAt M τ t φ.diamond ↔ ∃ σ : WorldHistory F, σ.IsTotal ∧ TruthAt M σ t φ := by …
  @[simp] theorem always_iff (φ : Formula) :
      TruthAt M τ t φ.always ↔
        (∀ s, s < t → TruthAt M τ s φ) ∧ TruthAt M τ t φ ∧ (∀ s, t < s → TruthAt M τ s φ) := by
    simp only [Formula.always, and_iff, past_iff, future_iff]
  ```
  Every proof body above is already written verbatim in `BLTruth.lean:137–195` for the base language. Then decide `strong_release_iff`/`strong_trigger_iff` deliberately (keep and use, or drop the attribute).
  **Sequencing caution**: adding `@[simp]` lemmas to `Truth.lean` must be done *after* D-01, otherwise the new set interacts with the looping `formula_fold`/`formula_unfold` rules in any module that sees both.
- **Effort**: M
- **Depends on**: D-01

### D-07. `truth_and_iff` — the lemma the soundness layer needs — is in the wrong module and not `@[simp]`

- **Severity**: High
- **Category**: api-ergonomics
- **Anchors**: `Semantics/Correspondence/DurationFrames.lean:293–306` (`truth_and_iff`), `:308` (`truth_always_of_forall`), `:317` (`truth_of_always`). Its own docstring at `:294`: *"`Truth.lean` supplies unfolding lemmas for the four tense operators but none for `Formula.and` or `Formula.always`."*
- **Description**: The gap in D-06 is already documented, and the fix is already written — but it landed in a leaf correspondence module (`Correspondence/DurationFrames.lean`), which the soundness layer does not import, and it is not `@[simp]`. Its 6 uses are all inside that one file (`:312,314,321,323,432,454`). Meanwhile the 12 sites of `simp only [Formula.and, Formula.neg, TruthAt]` and the 60 `exact h_conj (fun …)` idioms sit in `DenseValidity.lean` / `Soundness.lean` re-deriving it by hand.
- **Impact**: The correct abstraction exists and is unreachable from where it is needed — the most frustrating shape of technical debt, because the author already did the thinking.
- **Recommendation**: Move `truth_and_iff` (and `truth_always_of_forall`, `truth_of_always`) into `Semantics/Truth.lean`'s `Truth` namespace as `Truth.and_iff` / `Truth.always_of_forall` / `Truth.of_always`, mark `and_iff` `@[simp]`, and leave a one-line re-export or update the 6 call sites in `DurationFrames.lean`. Fold this into D-06 as one change.
- **Effort**: S
- **Depends on**: D-06

### D-08. `propDecide` exists, works, and is not used where it would delete hundreds of lines

- **Severity**: High
- **Category**: tactic-automation
- **Anchors**: `Automation/Tactics/PropDecide.lean:123` (the tactic); targets at `Metalogic/Algebraic/BooleanStructure.lean:56,63,72,108,119,130,146,160,176,218,227,242,361,392,409` (15 `*_quot` lemmas, ~430 lines, all zero external references but all consumed by the `BooleanAlgebra` instance).
- **Description**: `BooleanStructure.lean:242 le_sup_inf_quot` is 119 lines with **31 `have`s** that hand-build an object-language derivation of classical distributivity `((φ∨ψ)∧(φ∨χ)) → (φ∨(ψ∧χ))` out of `deductionTheorem`, `orInl`, `orInr`, `lceImp`, `rceImp`, `impTrans` — a proof whose 45 lines of explanatory comments concede it is doing case analysis by hand. `propDecide` was written for exactly this.
  **VALIDATED** by `lean_multi_attempt` in `Tests/BimodalTest/Metalogic/PropDecideTest.lean` (line 66):
  - `have h2 : |-! (((A.or B).and (A.or B)).imp (A.or (B.and B))) := by propDecide` — **closes**, no error (a distributivity instance in exactly the `le_sup_inf_quot` shape).
  - `have h : |-! ((A.and B).neg.imp (A.neg.or B.neg)) := by propDecide` — **closes** (De Morgan).
  - `have h3 : |-! (A.and B) := by propDecide` — **correctly rejected** ("`decide` proved … `isTaut = true` is false"), so the tactic is sound, not vacuous.
  The De Morgan result also **contradicts the file's own docstring** at `PropDecideTest.lean:44–46`, which claims `and`/`or` goals are "out of scope for the pure imp/bot reflection skeleton". They are not: `PropDecide.reify` (`PropDecide.lean:64`) calls `whnf` before matching, which unfolds `Formula.and`/`or`/`neg` down to `imp`/`bot`. The tactic is more capable than it is advertised to be.
  Import feasibility checked: `Decidability/Propositional/Kalmar.lean` imports only `PropForm`, `Derivable`, `Core.DeductionTheorem`, `Theorems.Propositional.Reasoning`, `Theorems.Combinators`; `BooleanStructure.lean` imports `Algebraic.LindenbaumQuotient` + Mathlib order files. **No cycle.**
- **Impact**: The single largest concrete line-count win available: ~430 lines of `Algebraic/BooleanStructure.lean` plus comparable material in `Algebraic/LindenbaumQuotient.lean` (`provEquiv_*` congruence lemmas) reduce to `Quotient.ind` + `change Derives …` + `propDecide`.
- **Recommendation**: Add `import FormalSystem.Automation.Tactics.PropDecide` to `BooleanStructure.lean` and rewrite the `*_quot` bodies as
  ```lean
  theorem le_sup_inf_quot (a b c : LindenbaumAlg) :
      andQuot (orQuot a b) (orQuot a c) ≤ orQuot a (andQuot b c) := by
    induction a using Quotient.ind; induction b using Quotient.ind; induction c using Quotient.ind
    rename_i φ ψ χ
    change Derives ((φ.or ψ).and (φ.or χ)) (φ.or (ψ.and χ))
    unfold Derives
    propDecide
  ```
  Do one lemma first to confirm the `Derives`/`⊢`-shape reaches `extractDerivationGoal` (`Helpers.lean:524`), then apply mechanically. Separately, fix the stale "out of scope" docstring at `PropDecideTest.lean:44` and add the De Morgan / distributivity cases as regression tests.
- **Effort**: M
- **Depends on**: —

### D-09. Many `simp only [Formula.swapTemporal, TruthAt]` calls are no-ops before `intro`

- **Severity**: Medium
- **Category**: proof-elegance
- **Anchors**: `DenseValidity.lean:302` (prop_k), `:307` (prop_s), `:325` (ex_falso), `:342` (modal_k_dist); mirrored at `FrameClassVariants.lean:51,56,71,90`.
- **Description**: `TruthAt … (φ.imp ψ)` is *definitionally* an arrow (`Truth.imp_iff` is proved by `rfl`, `Truth.lean:192`), so `intro`/`exact` see through it without any normalisation.
  **VALIDATED** at `DenseValidity.lean:302`: replacing the whole `simp only [Formula.swapTemporal, TruthAt]` line with `exact fun h_abc h_ab h_a => h_abc h_a (h_ab h_a)` leaves the following line reporting *"No goals to be solved"* — i.e. the four-line case
  ```lean
  | prop_k ψ χ ρ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  ```
  collapses to two lines (`intro F M τ _hτ t` + the `exact`), in each of the two copies.
- **Impact**: Small per site, but it is the dominant idiom in the three largest proofs in the project (48 + 42 + 25 `simp only` calls in the top three), and each unnecessary `simp only` is a simp-set invocation at elaboration time.
- **Recommendation**: When doing D-03, drop the `simp only` from every purely-propositional case. Keep it where the case genuinely needs `Truth.future_iff`/`past_iff` to expose a quantifier.
- **Effort**: S
- **Depends on**: D-03

### D-10. No named simp set anywhere in the repository

- **Severity**: Medium
- **Category**: tactic-automation
- **Anchors**: `register_simp_attr` occurs **0** times in the repo; 229 `simp only` lists in the core scope mention `TruthAt`, 279 across the live scope; top repeated lists tabulated in §3.1.
- **Description**: Every truth-unfolding site re-types its own lemma list. The four most common are `[TruthAt]` (74), `[Formula.swapTemporal, TruthAt]` (27), `[TruthAt, Truth.future_iff]` (21), `[TruthAt, Truth.past_iff]` (14). Beyond truth, `[AtomEval]` (108) and `[AtomEval, Fin.cons]` (64) in the Kamp/countermodel layer, and `[List.mem_cons, List.not_mem_nil, or_false]` (67) in the context layer, are the same phenomenon.
- **Impact**: Adding a truth clause (a new `Formula` constructor, or a new derived operator) requires editing hundreds of lists rather than one attribute. The lists also drift: `[Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]` and `[Formula.and, Formula.neg, TruthAt]` are the same intent at 12 sites each.
- **Recommendation**: After D-06 makes the clauses simp-normal, introduce two named sets and a tactic alias:
  ```lean
  -- Semantics/Truth.lean
  register_simp_attr truth_norm
  attribute [truth_norm] TruthAt Truth.bot_false Truth.imp_iff Truth.box_iff
    Truth.and_iff Truth.or_iff Truth.neg_iff Truth.top_true Truth.diamond_iff
    Truth.future_iff Truth.past_iff Truth.some_future_iff Truth.some_past_iff
    Truth.always_iff

  macro "truth_simp" loc:(Lean.Parser.Tactic.location)? : tactic =>
    `(tactic| simp only [truth_norm] $(loc)?)
  ```
  and a `swap_norm` set for the 9 `Formula.swap_temporal_*` lemmas (`[Formula.swap_temporal_all_future, Formula.swapTemporal]` ×9, `[…all_past, …]` ×6, `[…some_past, …]` ×4). Sites covered: ≥229 in the core scope, ≥279 live.
- **Effort**: M
- **Depends on**: D-01, D-06

### D-11. The master `cases` theorems mix delegation and inlining in the same block

- **Severity**: Medium
- **Category**: abstraction
- **Anchors**: `DenseValidity.lean:297` (`axiom_swap_valid`: 12 one-line `=> exact …` cases vs **33** multi-line inline cases); `DenseValidity.lean:970` (`axiom_locally_valid`: 9 delegated, 20+ inline); `Soundness.lean:1280–1325` (`axiom_validIn_min`: fully delegated — the good example).
- **Description**: `Soundness.lean:1280–1325` shows the intended shape: every case is `| ctor a => exact ctor_valid a`, 45 lines for the whole axiom set, trivially auditable against the paper. The two `SoundnessLemmas` masters do this for a minority of cases and inline 5–25 lines for the rest. There is no principle distinguishing the two groups — `swap_axiom_mt_valid`/`m4`/`mb` are extracted but `swap_axiom_prop_k`/`prop_s`/`peirce` are not, even though the latter are shorter.
- **Impact**: Reviewability. A soundness proof is the one thing a referee will read line by line against the axiom list, and a 420-line `cases` block with heterogeneous case styles is the hardest possible presentation of it.
- **Recommendation**: Make the rule explicit and uniform: *every* `Axiom` constructor gets a named `axiom_<ctor>_valid` / `swap_axiom_<ctor>_valid` lemma stated directly above the dispatch, and *every* case in the master is one line. This is the same change as D-03 and should be done in one pass.
- **Effort**: L
- **Depends on**: D-03, D-04

### D-12. No Aesop rule set for MCS reasoning, where the repetition is heaviest

- **Severity**: Medium
- **Category**: tactic-automation
- **Anchors**: `Core/MaximalConsistent.lean:491` (`theorem_in_mcs`, 340 uses), `Core/MCSProperties.lean:157` (`implication_property`, 315), `:182` (`negation_complete`, 139), `:371` (`neg_excludes`, 37), `MaximalConsistent.lean` (`closed_under_derivation`, 38). Hot spots that would benefit: `Core/RestrictedMCS/Basic.lean:137` (137 lines, 24 `have`s), `Algebraic/UltrafilterMCS.lean:149,360,674,782` (110/116/108/128 lines, 23/26/18/16 `have`s).
- **Description**: The MCS layer has a clean, small, forward-chaining API — exactly the shape Aesop is built for — and 869 combined call sites, but zero `aesop` invocations. Five of the top-20 hot spots are `UltrafilterMCS.lean` proofs whose `have` chains are almost entirely membership bookkeeping: get `φ ∈ S`, apply `implication_property`, split with `negation_complete`, discharge with `neg_excludes`.
- **Impact**: The largest remaining hand-written repetition after the soundness layer is fixed.
- **Recommendation**: Declare a real, *named* rule set (so it never pollutes the default set the way `AesopRules.lean` does) in a new `Metalogic/Core/MCSAesop.lean`:
  ```lean
  declare_aesop_rule_sets [MCS]

  attribute [aesop safe forward (rule_sets := [MCS])]
    SetMaximalConsistent.implication_property   -- (φ→ψ)∈S → φ∈S → ψ∈S
    SetMaximalConsistent.closed_under_derivation
    SetMaximalConsistent.neg_excludes           -- ¬φ∈S → φ∉S
    theorem_in_mcs                              -- ⊢φ → φ∈S

  attribute [aesop unsafe 50% (rule_sets := [MCS])]
    SetMaximalConsistent.negation_complete      -- branching: φ∈S ∨ ¬φ∈S

  attribute [aesop norm simp (rule_sets := [MCS])]
    Set.mem_insert_iff Set.mem_singleton_iff List.mem_cons

  macro "mcs_auto" : tactic => `(tactic| aesop (rule_sets := [MCS]))
  ```
  `negation_complete` must be `unsafe` (it is the only branching rule); the other four are confluent forward rules. Validate on `RestrictedMCS/Basic.lean:137` and one `UltrafilterMCS` lemma before rolling out. **Not validated here** — needs a real experiment.
- **Effort**: M
- **Depends on**: —

### D-13. `AesopRules.lean` is deprecated but its 18 attributes still sit in Aesop's *default* rule set

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `Automation/AesopRules.lean:17–23` (deprecation notice), `:50–53` (the file's own admission: *"the rules below are registered in Aesop's DEFAULT rule set … there is no separate `TMLogic` rule set declared"*), attributes at `:78,84,90,96,102,108,115,132,144,156,168,181,192,204,222,232,242,258,266,274,282`. Reached from `Tactics/Helpers.lean:8` → `Tactics/Commands.lean` → `Automation.lean:6` → `FormalSystem/FormalSystem.lean:7`.
- **Description**: The module is documented as dead ("As of 2026-01-17, `tm_auto` no longer uses Aesop"), but its 8 `safe apply` + 6 `safe forward` + 4 `norm unfold` rules are unconditionally registered globally. Any `aesop` call in a module that transitively imports `FormalSystem.Automation` will try to build `DerivationTree` terms — the very behaviour the deprecation notice says was abandoned because of "proof reconstruction issues". The 20 real `aesop` calls in the live tree happen not to be in that closure (I checked `Kamp/NfMultiAnchorBridge/Base.lean`), so this is latent rather than active — but `AesopRules.lean` is reachable from `import FormalSystem`.
- **Impact**: Same class of hazard as D-01, one step less severe (degraded search rather than a loop). Also 285 lines documented as "preserved for reference".
- **Recommendation**: Either (a) wrap every attribute in `declare_aesop_rule_sets [TMLogic]` + `(rule_sets := [TMLogic])` so the default set is untouched, or (b) move the file to `Boneyard/` and drop it from `Automation.lean:6`. Option (a) is 20 mechanical edits and preserves the reference value the docstring asks for. Note `AesopRules.lean:37–40`'s "Excluded Axioms … pending soundness proofs" comment is also stale — `temp_l` and `modal_future` both have soundness proofs now (`DenseValidity.lean:831`, `:855`; `Soundness.lean:1310`).
- **Effort**: S
- **Depends on**: —

### D-14. `Automation/README.md` and `Tactics/README.md` are systematically wrong

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `FormalSystem/Automation/README.md`, `FormalSystem/Automation/Tactics/README.md`.
- **Description**: Three independent failures.
  1. **Every line count in the module tables is wrong**, several by 2–5×: `DatasetGenerator` 471→**2,294**; `FormulaEnumerator` 1,091→**2,368**; `ProofStepExport` 332→**1,685**; `DatasetExport` 578→**1,353**; `FormulaMutator` 785→**1,191**; `BenchmarkAnchors` 496→**593**; `AesopRules` 276→**285**; plus 8 more. `Tactics/README.md`: `Commands.lean` 431→**742**, `Helpers.lean` 921→**1,210**.
  2. **13 of 27 `Automation/*.lean` modules are absent from the table entirely**, including the 1,336-line `Normalization.lean` (the D-01 culprit), `TableauProofStepPipeline.lean` (696), `TableauBridge.lean` (647), `InterestingnessMetrics.lean` (584), `MachineAppendixExport.lean` (498), `ForwardProofGenerator.lean` (400). `Tactics/README.md` omits both `Deduction.lean` and `PropDecide.lean`.
  3. **Stale namespace**: `Tactics/README.md` says *"Imports from: `Bimodal.ProofSystem`, `Bimodal.Automation.AesopRules`"* and *"Used by: `Bimodal.Automation`"*. The `Bimodal.*` namespace no longer exists in any `.lean` file (0 occurrences), but survives in **26 places across 14 README files** (`Metalogic/README.md`, `Theorems/Propositional/README.md`, `Syntax/SubformulaClosure/README.md`, `Automation/ProofSearch/README.md`, and 10 more).
  Both files claim *"Last verified: 2026-05-29"*.
- **Impact**: The READMEs are the first-contact documentation for the automation story and they misdescribe it in every dimension — size, membership, and namespace. The "Last verified" stamp makes the drift worse than no stamp.
- **Recommendation**: (a) Replace the hand-maintained line-count columns with generated ones — `scripts/readme-inventory.sh` already exists; extend `scripts/readme-lint.sh` to assert module-table completeness and line-count accuracy and wire it into `check-module-invariants.sh` as a new check. (b) Add a `C10`-style check for `Bimodal.` occurrences under `FormalSystem/**/*.md` (the existing C10 already does this shape for stale `docs/latex/typst` paths). (c) Drop or automate the "Last verified" stamps.
- **Effort**: S
- **Depends on**: —

### D-15. CI runs neither the test suite nor any linter; no `#lint` anywhere in the repo

- **Severity**: High
- **Category**: organization
- **Anchors**: `.github/workflows/ci.yml:30–35` (`build: true`, **`test: false`**, **`lint: false`**); `lakefile.lean:5` declares `testDriver := "BimodalTest"`; `#lint` / `runLinter` occur **0** times in the repo (the only matches are prose in `scripts/check-copyright-headers.sh`).
- **Description**: The project has a 700+-case test suite (`Tests/BimodalTest/**`, the *only* consumer of most of the tactic layer — 120 `modal_search`, 104 `tm_auto`, 37 `apply_axiom` uses) and it is disabled in CI. Mathlib's environment linters (`simpNF`, `unusedArguments`, `docBlame`, `dupNamespace`, `simpVarHead`) are never run. `simpNF` alone would have flagged D-01 the day it landed. CI is additionally skipped on push unless the commit message contains `[ci]`.
- **Impact**: The two most valuable automated signals available to a Lean project are both off. Given that `check-module-invariants.sh` is otherwise an unusually thorough harness (15 checks including `#print axioms` baselines against a pinned record), this is a conspicuous hole.
- **Recommendation**: (a) Flip `test: true` in `ci.yml`. (b) Add a `runLinter` executable to `lakefile.lean` and a `C16` check to `check-module-invariants.sh`:
  ```lean
  lean_exe runLinter where
    root := `FormalSystem.RunLinter
    supportInterpreter := true
  ```
  with `FormalSystem/RunLinter.lean` containing `import FormalSystem` + `#lint`. Start with `simpNF` + `dupNamespace` as blocking and the rest as reporting-only, matching the file's existing `ENFORCE_C*` flag pattern (`check-module-invariants.sh:64–78`). (c) Add a docstring-coverage check — the core scope is already at 91.8%, so a 90% floor is free to enforce and cheap to hold. (d) The build log's unused-variable warnings should become a counted, non-decreasing-forbidden metric in the same style as C14's axiom/sorry counts.
- **Effort**: M
- **Depends on**: D-01 (fix the loop before turning `simpNF` on, or it fails immediately)

### D-16. Repository-wide dead-declaration census: 146 unreferenced declarations in the core scope

- **Severity**: Medium
- **Category**: organization
- **Anchors**: full list produced by name-occurrence scan over `FormalSystem/**` (ex-`Boneyard`) + `Tests/**` + all `.md`/`.typ`/`.tex`. Concentrations: `SoundnessLemmas/DenseValidity.lean` (17), `SetConsequence.lean` (11: `setDerivable_mono:338`, `setSemanticConsequenceOn_mono_fc:354`, `setSemanticConsequence{Base,Dense,Discrete,DedekindDense}_mono:360–376`, `setDerivable_of_derivable:390`, `derivable_of_setDerivable_contextToSet:400`, `setDerivable_of_mem:408`), `Semantics/Validity.lean` (11), `Bundle/CanonicalTaskRelation.lean` (10), `Semantics/TaskFrame.lean` (10), `Semantics/WorldHistory.lean` (10), `Bundle/TemporalCoherence.lean` (9), `Soundness.lean` (8).
- **Description**: 691 of 1,334 core-scope declarations (52%) have zero references outside their defining file — mostly legitimate file-internal helpers. The sharper number is **146 declarations that occur exactly once in the entire repository** (their own declaration), with no test use and no mention in any document. Method: tokenised occurrence counting of the base identifier across all `.lean` and all prose files; conservative (a name used only via `open`-shortened form or dot-notation still counts).
- **Impact**: Roughly 5–8% of the core scope is unreachable. For a publication artifact this inflates the apparent formalisation size and gives reviewers unproved-looking surface area.
- **Recommendation**: Triage into three buckets. (a) *Symmetric-completion API* (`setSemanticConsequence{Dense,Discrete,DedekindDense}_mono`, `trivialFrame_{serial,interpolates,limit,spherical}`, `natFrame_*`) — keep, but add a `Tests/` witness so they are exercised. (b) *Orphaned proof scaffolding* (the `DenseValidity.lean` 17, `Bundle/ModalSaturation.lean` 6, `Bundle/Construction.lean` 4) — delete, per D-04. (c) *Genuinely-forgotten results* (`Algebraic/UltrafilterMCS.lean:983 ultrafilter_mcs_round_trip`, `:1056 mcs_ultrafilter_round_trip` — these look like the headline theorems of that module and are referenced nowhere) — investigate before touching. Add the scan itself as a reporting-only `C17` in `check-module-invariants.sh`, following the `ENFORCE_C9_DOCS=0` precedent.
- **Effort**: M
- **Depends on**: D-04

### D-17. Naming hygiene: 98 non-namespaced Uppercase-initial theorem names; `theorem`/`lemma` split is 98:2

- **Severity**: Medium
- **Category**: naming
- **Anchors**: `Bundle/CanonicalTaskRelation.lean` — `CanonicalTask_backward_comp:402`, `CanonicalTask_forward_comp_int:429`, `CanonicalTask_neg_succ_nat:301`, `CanonicalTask_of_nat`, `CanonicalTask_converse`, `CanonicalTask_nullity_identity`, `CanonicalTask_negSucc`, `CanonicalTask_forward_zero`, `CanonicalTask_backward_zero`, `CanonicalTask_forward_to_backward`, `CanonicalTask_backward_to_forward`, `CanonicalTask_forward_backward_flip` (12); `Algebraic/FlowFrame.lean` — `Fib_eq_singleton`, `Fib_permissive_ne`, `Fib_permissive_zero`; `Bundle/SuccRelation.lean` — `Succ_implies_CanonicalR`, `Succ_implies_h_content_reverse`, `Succ.f_step`; plus `G_neg_implies_not_F`, `H_neg_implies_not_P`, `H_monotone`, `F_until_equiv_valid`, `P_since_equiv_valid`, `HFofStepPath_path`.
- **Description**: Counts across the live scope: `theorem` 5,198 / `lemma` 100 (98:2 — effectively uniform, and matching Mathlib's `theorem` preference; the 100 stragglers are worth normalising but are not a real problem). Namespace roots are clean (`FormalSystem.*` throughout; 0 stale `Bimodal.*` in `.lean`). The real issue is **98 theorem names beginning with an uppercase letter and not dot-qualified** (24 in the core scope): Mathlib's convention is that `Foo_bar` is a *namespaced* declaration written `Foo.bar`, so `CanonicalTask_backward_comp` should be `CanonicalTask.backward_comp`. Suffix conventions are otherwise consistent and good: `_valid` ×111, `_iff` ×45, `_forall` ×21, `_total` ×18, `_quot` ×15, `_eq` ×15, `_consistent` ×15, `_mcs` ×13.
  `open` discipline is disciplined: 257 `open FormalSystem.Syntax`, 90 `open FormalSystem.ProofSystem`, 45 `open Classical in` (correctly scoped with `in`), and 24 uses of the selective form `open FormalSystem.Syntax (Formula Atom)`.
- **Impact**: Low functional risk, real reviewer-perception cost for a Mathlib-adjacent artifact. Also blocks `#lint dupNamespace` from being useful.
- **Recommendation**: Mechanical rename of the 98 to dot-namespaced form (`CanonicalTask_x` → `CanonicalTask.x` inside `namespace CanonicalTask`, etc.), and normalise the 100 `lemma`s to `theorem`. Do it in one commit after D-04/D-16 so the dead ones are gone first. Guard with a new `check-module-invariants.sh` check.
- **Effort**: M
- **Depends on**: D-04, D-16

### D-18. `lakefile.lean` carries nine work-item citations, violating the repo's own deliverable rule

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `lakefile.lean` — the docstrings for `enum_benchmark`, `benchmark_anchors`, `benchmark_oracle`, `contrastive_generator`, `tableau_bridge`, `tableau_proof_steps`, `trace_exporter`, `proof_first_generator`, and `machine_appendix` each end with a parenthesised work-item number. Rule: `.claude/rules/no-task-references-in-deliverables.md`. Gate: `scripts/check-module-invariants.sh:17,530–543` — its C9 check scans **`FormalSystem/` only**.
- **Description**: The project's own rule forbids ephemeral work-item citations outside `specs/**`, commit messages, and PR metadata, and enforces it with a blocking check — but the check's traversal root excludes the repository root, so `lakefile.lean` (a deliverable, and the first file any consumer reads) slips through with nine violations. `ENFORCE_C9_DOCS=0` already acknowledges a second uncovered region (`docs/`).
- **Impact**: Minor in isolation; notable because it is a gap in an otherwise well-engineered gate, and `lakefile.lean` is high-visibility.
- **Recommendation**: Rewrite the nine docstrings to cite what the executable does rather than which work item produced it, and widen C9's traversal to `lakefile.lean`, `README.md`, and `scripts/` (keeping `specs/**` excluded). One-line change to the `find` in `check-module-invariants.sh:530`.
- **Effort**: S
- **Depends on**: —

### D-19. Heartbeat budgets are concentrated in one file and are a load-bearing workaround

- **Severity**: Low
- **Category**: performance
- **Anchors**: `Decidability/Verified/Termination/MintBound.lean` — 24 `set_option maxHeartbeats`, 15 of them at the 4,000,000 ceiling, in a **15,252-line** file (the largest in the project); `Verified/Termination/SubformulaProperty.lean` (5, three at 4M); `Verified/Bridge/BoxSaturation.lean` (4); `Decidability/CountermodelExtraction.lean` (5); `WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (5); `WeakCanonical/Expressiveness/CaseAnalysis.lean` (4). Linter suppressions: `MintBound.lean:845,12918` (`linter.unusedTactic false`), `Verified/Bridge/RegionFrame.lean:150,318` (`linter.unusedVariables false`), `Semantics/Ultraproduct/{Carrier,ShiftSetProduct,Los}.lean` (`linter.unusedSectionVars false`).
- **Description**: 51 heartbeat bumps across the live scope, but 47% of them in one file. `MintBound.lean` at 15,252 lines with 24 budget bumps is a single-file build bottleneck. The two `synthInstance.maxHeartbeats 2000` at `Semantics/TemporalOrder.lean:178,181` *lower* the budget — a deliberate fail-fast against a diverging instance search, and the only instance-search pain signal I found in the whole scope.
- **Impact**: Build time and fragility on toolchain bumps; not correctness.
- **Recommendation**: Not urgent, but before publication: (a) split `MintBound.lean` along its section boundaries so heartbeat bumps are scoped to the handful of proofs that need them; (b) profile the three worst offenders with `lean_profile_proof` and record the numbers in the file docstring, so a future bump has a baseline; (c) document *why* `TemporalOrder.lean:178,181` lower the instance budget — that is a subtle, easily-reverted decision with no comment.
- **Effort**: L (the split), S (the documentation)
- **Depends on**: —

### D-20. Validity intro-chains: 231 hand-written binder lists in 40+ shapes

- **Severity**: Medium
- **Category**: proof-elegance
- **Anchors**: `intro F M τ _hτ t` ×119 (117 of them in `Soundness.lean` + `SoundnessLemmas/**`), `intro F M τ _h_mem t` ×40, `intro F M τ h_mem t` ×13, `intro F M τ hτ t` ×9, plus ~40 one-off variants. Adapters already provided: `Semantics/Validity.lean:377` (`valid.of_forall_total`), `:387` (`valid.apply`), `:497` (`ValidIn.of_forall_total`), `:514` (`ValidIn.of_not`), `:396` (`SemanticConsequence.of_forall`).
- **Description**: The binder-shape adapter layer in `Validity.lean` is genuinely well-designed and its docstrings (`:370–376`, `:476`, `:700`) explain exactly why it exists — the frame condition must land in the local context in a form instance search can see. But the *inner* `IsValid D φ` shape is still introduced by hand at 231 sites, in four near-identical spellings that differ only in whether the totality hypothesis is named `hτ`, `_hτ`, `h_mem`, or `_h_mem`.
- **Impact**: Mostly cosmetic — a macro `valid_intro` would expand to `intro …` and buy little beyond consistency, so I do **not** recommend a binder macro. The real cost is the *naming* inconsistency: `_h_mem` (40 sites) is a leftover from an older admissible-history formulation that `Validity.lean:352–357` explicitly documents as removed ("There is no admissible-history parameter"), so the hypothesis name now lies about what it is.
- **Recommendation**: (a) Normalise all 231 sites to one spelling (`intro F M τ hτ t`, with `_hτ` where genuinely unused) — a mechanical `sed`-scale change, and rename the 53 `_h_mem`/`h_mem` occurrences to `hτ`/`_hτ` to stop advertising a parameter that no longer exists. (b) Skip the macro; put the effort into D-10's `truth_simp` instead, which is where the leverage is. (c) The one place a macro *would* pay is the combined open: `macro "valid_intro" : tactic => \`(tactic| intro F M τ hτ t <;> truth_simp)` — but macro hygiene means `F`/`M`/`τ`/`t` would not be accessible by those names at the call site, so it needs the `binderIdent*` form and then it is just `intro` again. Recommend against.
- **Effort**: S
- **Depends on**: D-10

### D-21. `Truth.lean`'s `@[simp]` assignment looks unconsidered

- **Severity**: Low
- **Category**: abstraction
- **Anchors**: `Semantics/Truth.lean:320` (`strong_release_iff`, `@[simp]`, **0 uses**), `:334` (`strong_trigger_iff`, `@[simp]`, **0 uses**), `:204` (`atom_iff_of_domain`, not `@[simp]`, **0 uses**), `:221` (`atom_false_of_not_domain`, not `@[simp]`, **0 uses**), `:689` (`exists_shifted_history`, **0 uses**).
- **Description**: Two never-used lemmas are in the simp set while two never-used lemmas of the same kind are not, and the three heavily-used clauses (`imp_iff`, `box_iff`, `bot_false`) are not. There is no visible principle. Every `@[simp]` lemma is a permanent cost on every `simp` call in the import closure.
- **Impact**: Small, but it is the kind of detail a Mathlib reviewer checks first, and `#lint simpNF` will comment on it.
- **Recommendation**: Decide the simp-normal form once (D-06) and state it in the `Truth.lean` module docstring — which already has a "✓ Past (H): via `@[simp] past_iff`" table at `:53–57` that would be the natural place. Drop `@[simp]` from the two unused strong-operator lemmas until they have a consumer, or delete them per D-16.
- **Effort**: S
- **Depends on**: D-06, D-16

---

## 5. Proposed automation kit (ranked)

Ranked by (sites covered) × (confidence), highest first.

| # | Name | Home module | Definition sketch | Sites covered | Validation |
|---|---|---|---|---|---|
| 1 | `formula_unfold` / `formula_fold` (two named simp attrs, replacing the global `@[simp]`) | `Automation/Normalization.lean` | `register_simp_attr formula_unfold` / `formula_fold`; retag lines 69–161 and 800–834; `macro "modalNorm" => simp only [formula_unfold]`, `macro "modalFold" => simp only [formula_fold]` | fixes `simp` in **43 modules** + all downstream consumers of `import FormalSystem` | **VALIDATED** — loop reproduced at `DecisionProcedure.lean:309` (`maximum recursion depth`) |
| 2 | `Truth.and_iff` / `or_iff` / `neg_iff` / `top_true` / `diamond_iff` / `always_iff` + `@[simp]` on `imp_iff` / `box_iff` / `bot_false` | `Semantics/Truth.lean` (namespace `Truth`) | verbatim copies of `BLTruth.lean:137–195`; `truth_and_iff` moved from `Correspondence/DurationFrames.lean:298` | 279 `simp only […TruthAt…]` sites; 51 `Formula.and` lists; 144 `Formula.neg` lists; 60 hand-rolled de-conjunctions; removes 5 copies of `and_of_not_imp_not` | **VALIDATED** in part — `Truth.imp_iff` shown at `DenseValidity.lean:302` to produce exactly the goal `simp only [TruthAt]` produces; the `and_iff`/`or_iff` proofs already compile in `BLTruth.lean` |
| 3 | `propDecide` (existing tactic — *deploy*, don't build) | `Automation/Tactics/PropDecide.lean:123` | add `import FormalSystem.Automation.Tactics.PropDecide` to `Algebraic/BooleanStructure.lean`; replace `have`-chains with `change Derives … ; unfold Derives ; propDecide` | ~430 lines in `BooleanStructure.lean` (15 `*_quot` lemmas incl. the 119-line, 31-`have` `le_sup_inf_quot:242`); plausibly the `provEquiv_*` congruences in `LindenbaumQuotient.lean` | **VALIDATED** — closes a distributivity instance and De Morgan; correctly rejects a non-tautology; no import cycle |
| 4 | `truth_norm` simp set + `truth_simp` tactic | `Semantics/Truth.lean` | `register_simp_attr truth_norm`; `attribute [truth_norm] TruthAt Truth.{bot_false,imp_iff,box_iff,and_iff,or_iff,neg_iff,top_true,diamond_iff,future_iff,past_iff,some_future_iff,some_past_iff,always_iff}`; `macro "truth_simp" loc? => simp only [truth_norm] loc?` | ≥229 core / ≥279 live `simp only` lists | not validated (blocked on #2) |
| 5 | `swap_norm` simp set | `Syntax/Formula.lean` or `SoundnessLemmas/Core.lean` | `register_simp_attr swap_norm` over the 9 `Formula.swap_temporal_*` rewrite lemmas + `Formula.swapTemporal` | 27 + 9 + 6 + 4 + … ≈ 55 lists in `DenseValidity.lean` / `FrameClassVariants.lean` | not validated |
| 6 | `MCS` Aesop rule set + `mcs_auto` | new `Metalogic/Core/MCSAesop.lean` | `declare_aesop_rule_sets [MCS]`; `safe forward`: `implication_property`, `closed_under_derivation`, `neg_excludes`, `theorem_in_mcs`; `unsafe 50%`: `negation_complete`; `norm simp`: `Set.mem_insert_iff`, `Set.mem_singleton_iff`, `List.mem_cons` | 869 combined API call sites; directly targets 5 of the top-20 hot spots (`UltrafilterMCS.lean:149,360,674,782`, `RestrictedMCS/Basic.lean:137`) | **not validated** — needs an experiment before committing |
| 7 | Retire `AesopRules.lean`'s default-set attributes | `Automation/AesopRules.lean` | wrap all 18 in `declare_aesop_rule_sets [TMLogic]` + `(rule_sets := [TMLogic])`, or move the file to `Boneyard/` | removes a latent hazard from every module importing `FormalSystem` | file's own docstring (`:50–53`) confirms the diagnosis |
| 8 | `runLinter` exe + `C16` invariant check | `lakefile.lean` + `scripts/check-module-invariants.sh` | `lean_exe runLinter` over `import FormalSystem; #lint`; `simpNF` + `dupNamespace` blocking, rest reporting-only via an `ENFORCE_C16` flag | would have caught #1 and D-21 automatically; ongoing guard | — |

Explicitly **not** recommended: a `validity_intro` / `valid_intro` binder macro (D-20) — macro hygiene makes it strictly worse than `intro`, and the 231 sites need name normalisation, not a tactic.

---

## 6. Metrics

| Metric | Value |
|---|---|
| Automation layer read in full | 3,881 lines (`Tactics/` 2,260 + `AesopRules` 285 + `Normalization` 1,336) |
| Core consumer scope | 80 files / 33,336 lines |
| Whole live scope (`Metalogic` + `Semantics`, ex-`Boneyard`) | 357 files / 242,036 lines |
| Custom tactics/macros declared | 20 (`Automation/`) + 6 (`EFGameTactics.lean`) |
| …with **zero** library uses | 19 of 26 |
| …with **zero** library *and* test uses | 14 of 26 |
| Live custom-tactic call sites in the library | **72** (68 EF-game, 4 `modal_search`) |
| `aesop` calls in the core scope / live scope | 0 / 20 (none in `AesopRules`' import closure) |
| Named simp sets (`register_simp_attr`) | **0** |
| `@[simp]` per theorem, live scope | 191 / 5,298 = **3.7%** |
| `simp only [...]` in core scope | 464 (vs 173 bare `simp`, 78 `simp [...]`) |
| `simp only` lists mentioning `TruthAt` | 229 core / 279 live |
| Modules where plain `simp` loops (D-01) | 25 `FormalSystem` + 18 `Tests` = **43**, plus every `import FormalSystem` consumer |
| Validity intro-chain sites | 231, in ~44 distinct spellings |
| Longest proof | 420 lines (`DenseValidity.lean:297 axiom_swap_valid`) |
| Duplicate-pair overlap (`axiom_swap_valid` vs `_general`) | 83 differing lines of ~340 normalised = **76% identical** |
| Fully dead declaration lines in `DenseValidity.lean` | 526 / 1,247 = **42%** (≈53% with transitive) |
| Core-scope declarations never referenced anywhere | **146** of 1,334 |
| Copies of `and_of_not_imp_not` | **5** (4 files, 3 names) |
| `set_option maxHeartbeats` (live scope) | 51 (24 in `MintBound.lean`; 18 at the 4M ceiling) |
| `set_option linter.* false` | 7 |
| `native_decide` / structural `sorry` | **0** / **0** |
| Docstring coverage, core scope | **91.8%** (1,221 / 1,330) |
| `theorem` : `lemma` | 5,198 : 100 |
| Non-namespaced Uppercase theorem names | 98 live (24 core) |
| Stale `Bimodal.*` references | 0 in `.lean`; **26** in 14 `README.md` files |
| `#lint` / `runLinter` occurrences | **0** |
| CI: build / test / lint | true / **false** / **false** |
| `lakefile.lean` work-item citations | **9** (rule-violating, outside C9's traversal root) |
| Findings | 21 (2 Critical, 6 High, 11 Medium, 2 Low) |
| `lean_multi_attempt` validations performed | 4 runs, 3 sites, 3 findings validated (D-01, D-08, D-09), 1 partially (D-06) |
