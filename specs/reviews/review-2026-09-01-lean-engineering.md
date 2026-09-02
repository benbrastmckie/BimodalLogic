# Code Review Report

**Date**: 2026-09-01
**Scope**: Lean engineering of the metalogic after the `FrameClass` refactor — soundness, completeness,
compactness, frame validity, correspondence, canonical-model infrastructure, tactics/automation,
documentation, and alignment with Mathlib / CSLib / Formalized Formal Logic conventions
**Reviewed by**: Claude (seven parallel territory reviews, synthesized; every finding below was
re-verified at `file:line` by the territory reviewer, and the Critical findings were independently
re-verified by the orchestrator)

## Summary

- Total files reviewed: 434 live `.lean` files surveyed; **~115 read in full** across seven territories
  (Soundness 14 files / 7.4K lines; Completeness 14 / 5.6K; Frames & Correspondence 28 / 9.5K;
  Canonical infrastructure 22 / 9.8K; Automation 6 / 3.9K; Documentation 68 module docstrings +
  14 READMEs + `docs/` + `typst/`; Ecosystem survey of local Mathlib, CSLib, FFL/ModalLogic, LeanLTL)
- Critical issues: **6**
- High priority issues: **31**
- Medium priority issues: **62**
- Low priority issues: **23**
- Territory reports (full detail, 155 findings): `specs/reviews/2026-09-01-lean-engineering/`
  (`A-soundness.md`, `B-completeness.md`, `C-frames.md`, `D-tactics.md`, `E-docs.md`,
  `F-canonical.md`, `G-ecosystem.md`). Finding IDs below (`A-03`, `B-04`, …) refer to those files.

**Headline.** The previous review (`review-2026-08-31-metalogic-systematicity.md`) diagnosed one root
cause — the semantic side was not indexed by `FrameClass` — and its four tasks (507–510) fixed it. All
seven reviewers independently confirm that the fix is architecturally right and **complete at the
definition layer**: `FrameClass.Sat` states each class's binder set exactly once
(`Semantics/FrameClassValidity.lean:112`), `ValidIn`/`SemanticConsequenceIn`/`SetSemanticConsequenceOn`
are the single sources of truth, `soundness_in` writes the seven-constructor induction once
(`Metalogic/Soundness.lean:1438`), and every per-class name is a genuine one-line instance. No
correctness defect and no structural `sorry` was found anywhere in scope.

The residual problem is uniform across territories and is the subject of this review:

> **The refactor stopped at the definition layer and was never followed by a cleanup pass.**
> Definitions are generic; most *theorems* are still four hand copies. Superseded machinery was
> left compiling beside its replacement. The truth layer never received the `@[simp]` API its
> base-language mirror already has. And the documentation surfaces that restate status by hand have
> drifted into three outright contradictions.

Measured, in the reviewed scope: **~2,300 lines of transitively unreachable code** (615 in
`SoundnessLemmas/DenseValidity.lean` alone; 611 in three dead `Bundle/` modules; 146 orphan
declarations in the core scope); **~1,900 lines of verbatim or mirror duplication** (two 45-arm swap
dispatchers sharing 321 identical lines; ~30 future/past mirror pairs in `Bundle/`; five copies of
`and_of_not_imp_not`; four copies of `truth_and_iff`; five independent `induction φ` truth-transport
proofs; seven copies of the deterministic-frame *Spherical* argument); and **~230 lines of per-class
theorem instantiations** that are provable once generically in ≤ 6 lines each. The estimated net
reduction from the utilities proposed in §"Core utilities" is **4,500–6,000 lines (≈ 15–18 % of the
36K-line core scope) with zero loss of theorem content**, plus a truth-layer simp set that shortens
roughly 300 proofs.

Two things are worse than debt and are Critical: a **library-wide `simp` loop** shipped through
`import FormalSystem` (ten mutually-inverse `rfl` pairs in the global simp set,
`Automation/Normalization.lean:69–161` vs `:800–834`, validated to hit `maximum recursion depth`), and
**four core modules — including the machine-checked CEF countermodel — that `lake build` never
compiles** because nothing imports them and they are absent from the C6 manifest.

---

## Critical Issues

### C1. Plain `simp` loops in 43 modules and for every consumer of `import FormalSystem`
**File**: `FormalSystem/Automation/Normalization.lean:69–161` (21 `@[simp]` unfold lemmas) vs `:800–834`
(10 `@[simp]` fold lemmas); reached via `FormalSystem/FormalSystem.lean:14 → Automation.lean:20`
**Finding**: D-01
**Description**: `neg_unfold : φ.neg = φ.imp bot` and `neg_fold : φ.imp bot = neg φ` (and nine more
pairs: `top`, `next`, `prev`, `and`, `diamond`, `some_future`, `some_past`, `all_future`, `all_past`)
are all `rfl`, all in the **global default** simp set, no `scoped`, no priorities. Validated by
`lean_multi_attempt` at `Metalogic/Decidability/DecisionProcedure.lean:309`: `simp` on
`∀ a : Formula, a.neg = a.neg` fails with *"maximum recursion depth has been reached"*.
`Metalogic/Decidability/Correctness.lean:139`'s docstring blames `maxRecDepth` on decision-procedure
evaluation; the fold/unfold loop is at least a co-cause.
**Impact**: `simp` errors (not merely slows) in 25 `FormalSystem` + 18 `Tests` modules and for any
external user of the library. A reviewer's first `import FormalSystem; example … := by simp` fails.
No `#lint`/`simpNF` runs anywhere (CI has `lint: false`), which is how this survived.
**Recommended fix**: `register_simp_attr formula_unfold` / `formula_fold`; retag both families;
`macro "modalNorm" => simp only [formula_unfold]` etc. (which also removes four hand-maintained
21-name lists at `:178–226`, `:843`). Add a regression `example (a : Formula) : a.neg = a.neg := by simp`.
Effort S. **Do this before adding any `@[simp]` lemma to `Truth.lean` (C4 below), or the new set
interacts with the loop.**

### C2. Four core modules are outside the build graph and absent from the C6 manifest
**File**: `Metalogic/SpWitness.lean`, `Metalogic/TMCompletenessReduction.lean`,
`Metalogic/Z1Countermodel.lean`, `Semantics/LexCarrier.lean`; `scripts/module-invariants-manifest.txt`
**Finding**: B-08 (also C-19); independently confirmed — `check-module-invariants.sh --no-build` **FAILS
C6** today with exactly these four, and their `.olean`s are timestamped 10:37–12:31 while the rest of
`Metalogic/` is 17:54.
**Description**: `SpWitness` and `Z1Countermodel` have zero importers anywhere in `FormalSystem/` or
`Tests/`; `Metalogic.lean` does not import them; `Semantics.lean` does not aggregate `LexCarrier` or
`BLSchemaValidity`. `Z1Countermodel.tmCompleteDiscrete_refuted` is the machine-checked half of the CEF
row that `Conservativity.lean:159–166` and `:78–79` advertise as "closing CEF with both halves
machine-checked".
**Impact**: A headline refutation rests on an `.olean` from an ad-hoc invocation, guarded by nothing;
any upstream breaking change silently invalidates it. The repo's own invariant script is red.
**Recommended fix**: Import `Z1Countermodel` and `SpWitness` from `Metalogic.lean` (or from a new
`Metalogic/Conservativity/` aggregator per B-19); add `LexCarrier` and `BLSchemaValidity` to
`Semantics.lean`; re-run C6. Effort S.

### C3. `README.md` denies a theorem the tree proves (Dedekind strong completeness)
**File**: `README.md:167`, `:240–241` vs `Metalogic/SetConsequence.lean:601,609`,
`Metalogic/DedekindNonCompactness.lean:431,459`, `Metalogic.lean:116–120`
**Finding**: E-01 (verified by orchestrator)
**Description**: The front page says Dedekind strong completeness is "**not stated** … this tree
contains no `CompactDedekind` definition and no refuting theorem". Both are defined and both are
refuted (`dedekind_consequence_not_compact`, `strongCompletenessDedekind_refuted`), and the status
ledger in `Metalogic.lean` says so. The refutation landed 3 hours after the README's last edit.
**Impact**: The repository contradicts itself about a headline metalogical fact on its front page.
**Recommended fix**: Rewrite `README.md:163–168` to match `Metalogic.lean:116–120`; then stop restating
it (see §Documentation architecture). Effort S.

### C4. `typst/FormalFoundations.typ` reports `sorryAx` on an axiom-clean theorem
**File**: `typst/FormalFoundations.typ:697`, `:701`, `:993`, `:999–1004`, `:1543`
**Finding**: E-02 (verified by orchestrator)
**Description**: The compiled publication artifact records `completeness` as "same, plus `sorryAx`",
and states "the development contains exactly one structural `sorry` … `countermodel_discrete` in
`WeakCanonical/Transfer.lean`". C2's baseline pins `completeness` at exactly
`[propext, Classical.choice, Quot.sound]`; C3 asserts zero structural sorries;
`countermodel_discrete` is proved at `WeakCanonical/GroupModel/CountermodelBase.lean:143`.
**Impact**: The paper understates its own main result, in five places.
**Recommended fix**: Correct all five; then generate the axiom table from
`scripts/typst-status-counts.sh` (which already emits `typst/generated/status.typ`). Effort S/M.

### C5. Two READMEs describe a `Formula` type with the wrong constructors
**File**: `FormalSystem/README.md:51–58, :68–69`; `FormalSystem/Syntax/README.md:19` vs
`Syntax/Formula.lean:78–106`
**Finding**: E-03 (verified by orchestrator)
**Description**: Both list `all_past`/`all_future` as primitive constructors and omit `untl`/`snce`.
The six constructors are `atom, bot, imp, box, untl, snce`; `allPast`/`allFuture` are derived `def`s;
the snake_case names exist nowhere. Top-level `README.md:33–51` is correct, so two READMEs one
directory apart state incompatible object languages.
**Recommended fix**: Replace both tables with links to `README.md`'s version. Effort S.

### C6. Two 45-arm swap-validity dispatchers, 321 identical lines, one reached for two arms
**File**: `SoundnessLemmas/DenseValidity.lean:297` (`axiom_swap_valid`, 416 lines) vs
`SoundnessLemmas/FrameClassVariants.lean:46` (`axiom_swap_valid_general`, 348 lines); call sites
`Metalogic/Soundness.lean:1333,1337,1341`
**Finding**: A-02 ≡ D-03 (two reviewers independently measured 321 / "83 of ~340 differing" lines)
**Description**: `axiom_swap_validIn_min` (`Soundness.lean:1326`) already does the
`minFrameClass ≤ Base` split and reaches into the 416-line Dense dispatcher for exactly two
constructors (`density`, `dense_indicator`); the other 43 arms are unreachable through any live path.
**Impact**: Every new axiom constructor must be added to both; divergence is invisible (both compile).
Largest single duplication in scope; the soundness proof a referee reads line-by-line is presented in
its hardest possible form.
**Recommended fix**: Delete `axiom_swap_valid`; replace its two live arms with `density_swap_valid` and
`dense_indicator_swap_valid` beside `sep_swap_valid` (`Soundness.lean:1217`); make every arm of the
surviving dispatcher a one-line `exact <ctor>_swap_valid` (the shape `axiom_validIn_min`
`Soundness.lean:1277` already has). Net −416 lines. Effort S after the dead-code deletion (H1).

---

## High Priority Issues

The 31 High findings cluster into nine themes. Each theme names the finding IDs, the anchors, and the
single fix that discharges the cluster.

### H1. Superseded soundness machinery left compiling — 615 dead lines in `DenseValidity.lean`
**Findings**: A-01, D-04, A-08, A-09, D-05
**Anchors**: `SoundnessLemmas/DenseValidity.lean:970` (`axiom_locally_valid`, 298 lines, `private`,
zero references), `:98–169`, `:228–279`, `:717–874`, `:1268–1297`; `SoundnessLemmas/Core.lean:42`
(`IsValid`, a second monomorphic validity notion whose docstring's justification has expired), `:56–105`;
`Soundness.lean:1000` vs `Separability.lean:48` (`exists_isGLB_of_lub`, with a docstring apologising for
the copy); `and_of_not_imp_not` ×5 across four files
**Description**: 26 declarations occur exactly once in the tree (their own line). The file's own
docstring at `:215–217` records the supersession by `derivable_valid_and_swap_validIn` without removing
the code. `IsValid D` forces a `.toFibre` + `(D := F.Duration)` shim at every boundary.
**Fix**: Delete the eight dead ranges; move the four live `axiom_*_valid` survivors into
`FrameClassVariants.lean`; delete `DenseValidity.lean` and `Core.lean`; restate the five
`FrameClassVariants` theorems at `ValidDiscrete`. Effort S–M.

### H2. `Truth.lean` has no Boolean/derived-operator `@[simp]` API; `BLTruth.lean` has all of it
**Findings**: A-03 ≡ C-04 ≡ B-13 ≡ D-06 ≡ D-07 (five reviewers, independently)
**Anchors**: present — `Semantics/BLTruth.lean:137–196` (`neg_iff`, `top_true`, `and_iff`, `or_iff`,
`diamond_iff`, `always_iff`, …, all `@[simp]`); absent — `Semantics/Truth.lean` (`imp_iff:192`,
`box_iff:237`, `bot_false:182` exist but are not `@[simp]`; no `and`/`or`/`neg`/`top`/`always`).
Consequences: four private copies of `truth_and_iff` (`Correspondence/DurationFrames.lean:298`,
`DedekindNonCompactness.lean:158` — with a docstring choosing to duplicate rather than widen imports,
`Independence/CoNotPriorU.lean:180`, `Decidability/Verified/Decidable.lean:1408`); 279 `simp only […TruthAt…]`
lists; 144 lists naming `Formula.neg`; 85 `by_contra`; ~60 hand-rolled de-conjunctions; proof comments
like `-- Goal: (((D₁→F)→D₂)→F) → D₃. For D₁: intro h; exfalso; apply h; …` (`Soundness.lean:779`).
**Fix**: Transcribe `BLTruth.lean:137–196` into the `Truth` namespace verbatim; tag `imp_iff`/`box_iff`/
`bot_false`; then `register_simp_attr truth_norm` + `macro "truth_simp"` (D-10). ~200–250 lines saved in
the soundness territory alone, and the linearity/enrichment proofs become readable against Burgess/Xu.
Validated: `Truth.imp_iff` is a drop-in for `simp only [TruthAt]` at `DenseValidity.lean:302`. **After C1.**

### H3. `TaskFrame.IsDense` is a `def`, forcing 47 binder-shape adapter lemmas
**Findings**: A-04 (with C-08/A-16, C-09, C-10)
**Anchors**: `Semantics/FrameProperty.lean:71` (`def IsDense := DenselyOrdered F.Duration`), `:118`
(`IsSuccArchDiscrete`, a bare `∃`); the 47 adapters at `Validity.lean` (21), `BLValidity.lean` (12),
`StrongCompleteness.lean` (6), `SetConsequence.lean` (8); the stated reason at `Validity.lean:536–543`
**Description**: Because `IsDense`'s head symbol hides `DenselyOrdered` from instance search, every
class-restricted predicate carries `.of_forall`/`.apply`/`.of_not` adapters to re-expose it. Note the
frames reviewer's caution (C-frames §2): do **not** make `Sat` a typeclass — `IsSuccArchDiscrete` is an
existential over data-carrying `SuccOrder`, and the `haveI`-breaks-defeq trap at `Validity.lean:612–616`
is real. `abbrev` + a `Prop`-structure with instance-tagged projections is the narrow fix.
**Fix**: `abbrev TaskFrame.IsDense`; `structure TaskFrame.IsSuccArchDiscrete … where [succ : SuccOrder …] …`;
one `sat_intro` macro that destructures `fc.Sat F` into the instance cache; delete 45 adapters. Pair
with the rename `ValidDedekind → ValidComplete`, `ValidDedekindDense → ValidDedekind` (C-08/A-16: nine
prose warnings across six files defend a name that should carry the distinction itself). Effort M.

### H4. The consequence/compactness *theorems* are still four hand copies
**Findings**: B-01 ≡ A-05, B-02, B-04, B-05, B-06, G-02
**Anchors**: `StrongCompleteness.lean:256,632,762,907` (four identical `semantic_deduction_*`);
`:525,675,805,948` (four byte-identical `soundness_*_consequence` bodies); `:504,543,568,587,658,688,787,822,930,966`
(eight instances of two theorems); `Compactness.lean:84` vs `:121` (`modelExistenceBase`/`Dense`, identical
but for a `haveI` whose content is already an instance at `Ultraproduct/Carrier.lean:182`);
`DiscreteNonCompactness.lean:249` vs `:278` and `DedekindNonCompactness.lean:431` vs `:459` (the same
five-step refutation skeleton four times)
**Description**: Three textbook facts are missing as declarations, and their absence forces the copies:
`StrongCompleteness fc → Compact fc`, `Compact fc ↔ ModelExistence fc`, and a name for the
weak-completeness engine shape `∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`.
**Fix** (each ≤ 10 lines): `semantic_deduction_in`, `soundness_consequence`, `WeakCompleteness fc`,
`compact_of_strongCompleteness` + `strongCompleteness_iff_compact`, `setConsequence_of_not_satisfiable` +
`not_compact_of_witness` + `not_strongCompleteness_of_witness`, `modelExistence_of_satPreserved` (whose
docstring becomes the one place explaining *why* compactness holds for Base/Dense and fails for
Discrete/Dedekind: `fc.Sat` is or is not preserved by ultraproducts). "Strong completeness = weak
completeness + compactness" becomes one `iff`. ~230 lines → ~40. Effort M.

### H5. Three dead `Bundle/` modules and an undocumented third directory cycle
**Findings**: F-01, F-03, F-02, F-06, F-07, F-16
**Anchors**: `Bundle/CanonicalFrame.lean` (312), `Bundle/Construction.lean` (253),
`Bundle/UntilSinceCoherence.lean` (46, declares nothing) — zero live consumers, advertised as deliverables
in `Bundle/README.md`; `BXCanonical/Frame.lean:11` imports `CanonicalFrame` and uses nothing from it while
`:223–244` re-proves its headline theorems; `Bundle/LimitMCS.lean:8 → Algebraic.FlowFrame` and
`Algebraic/FlowFrame.lean:9 → Bundle.TemporalCoherence` (verified by orchestrator: a `Bundle ↔ Algebraic`
cycle that `Metalogic/README.md:88` says does not exist, caused by the single orphan
`fc_theorem_true_in_bundle_flow_model`); `Bundle/SuccRelation.lean:432–543` (85 lines of first-person
proof diary — "Hmm, this may need additional infrastructure. Let me check." — around an 8-line proof,
citing `SuccExistence.lean`, which does not exist); `Bundle/ModalSaturation.lean` (nine importers use it
for five S5 derivation helpers; everything named "saturation" is dead)
**Fix**: Boneyard the three dead modules; delete the orphan to break the cycle; move `iterF`/`iterP`/
`closure{F,P}Bound` (pure syntax, 24 declarations) to a new `Syntax/SubformulaClosure/IteratedTemporal.lean`
— this breaks `Core ↔ Bundle` in **3 Lean files with no renames**, not the 9 files the README recorded
for a different plan; move the derivation helpers to `Theorems/ModalDerived.lean`; delete the diary.
Effort M.

### H6. Future/past mirroring is done textually ~30 times in `Bundle/`
**Findings**: F-14, F-08, F-15, A-06, A-12
**Anchors**: the one correct use — `Algebraic/FlowFrame.lean:618` (`past_tf_deriv` via `swapTemporal` +
`temporal_duality`); the mirrors — `WitnessSeed.lean:59/81, :150/271, :181/290, :408/488`;
`TemporalContent.lean:157/212`; `SuccRelation.lean:149/315, :246/406`; `CanonicalTaskRelation.lean:74–194/707–849`;
`TemporalCoherence.lean` (6 pairs); `LimitMCS.lean` (5 pairs); `LimitMCSCoherence.lean` (5 pairs);
`FrameClassVariants.lean:400/440, :479/541` (Prior-UZ/SZ and Z1/Z1-past, hand-dualised though
`Separability.lean:270/324` demonstrates the `Dᵒᵈ` recipe in the same directory); `Truth.lean:450`
(`time_shift_preserves_truth`, 236 lines, four near-identical arithmetic blocks); 14 inline
re-derivations of `fMono`/`pMono` (`Theorems/TemporalDerived.lean:407,418`)
**Description**: Conservatively 1,200–1,400 lines are the second half of a mirror pair. Four ~85-line
witness-seed proofs share one 60-line core; `UntilWitnessSeed` and `ForwardTemporalWitnessSeed` are the
same set under two names.
**Fix**: (a) derive past-side *derivations* via `temporal_duality`; (b) for order-theoretic mirrors,
extract `P : D → Prop`-parameterised cores and instantiate at `Dᵒᵈ` (the `sep_order`/`sep_order_mirror`
pattern); (c) `allFuture_neg_of_gseed_inconsistent` as the shared witness-seed core; (d) `someFuture_mono`.
Effort L, but (c)+(d)+the discrete Prior/Z1 pair alone are M and save ~400 lines.

### H7. Frame-kit gaps: seven copies of *Spherical*, five truth-transport inductions, three permissive frames
**Findings**: C-01, C-02, C-03, C-07, C-12
**Anchors**: deterministic-*Spherical* at `ClockFrame.lean:156`, `DurationFrames.lean:163` (docstring admits
copying the former), `RegionFrame.lean:208,295`, `ReynoldsBridge.lean:464,522,784`, `ShiftSet.lean:186`,
with two competing generic helpers (`TaskFrame.lean:977`, `Algebraic/FlowFrame.lean:116`); `induction φ`
transport at `Truth.lean:450`, `IntTransfer.lean:292`, `FwdRecPeriodicity.lean:356`,
`LoopingDuration.lean:98`, `CoNotPriorU.lean:416` (~370 lines, each documenting the same
"generalize the history for the `box` case" trick); Helper B incomplete (`TaskFrame.lean:1129–1235`) so
`natFrame:1449`, `genericNatFrame` (`Examples/TemporalStructures.lean:382`, verbatim copy), and
`permissiveFrame` (`DurationFrames.lean:210`) inline the same three fields; `FwdRecBridge.lean:61–115`
re-derives `IntNormalForm.lean:177–345`'s ℤ step-path dictionary under new names though `IntNormalForm`
is upstream; six copies of the total-history boilerplate (C-12)
**Fix**: Helper D (`spherical_of_fib_subsingleton`); complete Helper B; `WorldHistory.ofTotal` /
`TaskFrame.HF.ofTotal` with a `@[simp]` states lemma; one `TruthIso`/`truthAt_of_truthIso` transport
lemma; one `import` line in `FwdRecBridge`. Then `Semantics/Frames/Standard.lean` as the indexed home for
the 14 frame constants currently spread over nine files (C-11). ~700–800 lines removed for ~250 added.
**Sequence after task 517** (Spherical → Saturation rename), which touches the same declarations.

### H8. No linter, no tests in CI, no single source of truth for status or counts
**Findings**: D-15, E-14, E-04, E-05, E-08, E-15, G-08, G-14, B-14
**Anchors**: `.github/workflows/ci.yml` (`test: false`, `lint: false`, and CI skipped on push unless the
message contains `[ci]`); `#lint` occurs 0 times; `Metalogic.lean:224–256` (every file count wrong:
Decidability 19 vs 62, WeakCanonical 135 vs 179, "two Boneyards" vs the one B0 asserts);
`Metalogic/README.md` (~20 stale counts, "Ten loose files" above an eleven-row table);
`Metalogic.lean` asserts SORRY-FREE for 37 declarations while C2+C14 pin 8; six mutually-drifting copies
of the four-row status ledger (`Metalogic.lean:45–47` says "the two countermodels remain outstanding",
`Conservativity.lean:159–166` says CEF landed; `:110–113` is a dangling edit fragment);
`docs/README.md:273–279` documents a `lake build :docs` that cannot run (no doc-gen4 in the lakefile);
no `docs/theorem-index.md`, no `CITATION.cff`
**Fix**: (a) `test: true`, `lint: true`, a `runLinter` exe with `simpNF`+`dupNamespace` blocking;
(b) the single-source-of-truth policy in §Documentation architecture; (c) `docgen-action` on GitHub Pages.
Effort M each.

### H9. `propDecide` works and is deployed nowhere; the bespoke tactic suite is 19/26 unused
**Findings**: D-08, D-02, D-13
**Anchors**: `Automation/Tactics/PropDecide.lean:123`; targets `Algebraic/BooleanStructure.lean:56–409`
(15 `*_quot` lemmas, ~430 lines; `le_sup_inf_quot:242` is 119 lines with 31 `have`s); the suite
`Automation/Tactics/**` (2,260 lines) + `Normalization.lean` (1,336) + `AesopRules.lean` (285, deprecated
but its 18 rules still sit in Aesop's *default* set)
**Description**: Validated by `lean_multi_attempt`: `propDecide` closes a distributivity instance in exactly
the `le_sup_inf_quot` shape and De Morgan, and correctly rejects a non-tautology; its own test file's
docstring understates it. No import cycle. Meanwhile 14 of 26 declared tactics have zero library *and*
test uses; the only production custom tactics are the six EF-game ones (68 sites).
**Fix**: Deploy `propDecide` in `BooleanStructure.lean` (and likely `LindenbaumQuotient.lean`'s
`provEquiv_*`); move the 18 Aesop attributes into a named `TMLogic` rule set; retire the dead search
tactics to `Boneyard/`; split `Helpers.lean` into user tactics / `MetaM` plumbing / search engine.
Effort M.

---

## Medium Priority Issues

Grouped; anchors and full recommendations in the territory files.

**Duplication / abstraction (13)**
- B-03, B-09, B-10, B-22 — eight `consequence_completeness_*`/`completeness_*` instances of two theorems;
  `Compact ↔ ModelExistence` half-present; `WeakCompleteness` unnamed; `TMComplete`/`Forward` at two tags.
- B-11 — `restricted_lindenbaum` re-proves `set_lindenbaum`'s Zorn argument (≈ 110 lines → one
  `exists_maximal_of_chainClosed`). B-12/F-22 — `restricted_mcs_{F,P}_bounded` byte-identical modulo
  renaming, 154 lines of hand-rolled well-founded minimum that `Nat.find` gives in ~20.
- A-07 — `BLValidity.lean` is a structural clone of `Validity.lean` despite `truthAt_tr`; one
  `blValidIn_iff_validIn_tr` makes the lemma layer corollaries.
- C-06 ≡ G-06 — `Galois.lean`'s `Th`/`Mod`/`GaloisClosed` and six theorems are `Mathlib.Order.Concept`'s
  `upperPolar`/`lowerPolar`/`Order.IsExtent` verbatim (verified locally at `Mathlib/Order/Concept.lean:48,53,70,137,142,184,188`);
  reusing them frees `IsExtent.iInter`, `GaloisConnection.l_sup`/`l_iSup` (`Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂`)
  for the `Independence/` sandwich work. Reconciled recommendation: instantiate Concept's polar API
  (it is itself a `GaloisConnection`), keep `galoisClosed_of_indicator` (genuinely repo-specific).
- C-15, C-16 — "least positive ⟹ immediate successor" written four times; `LexCarrier.lean` (`ℚ ×ₗ ℤ`)
  and `LexIntWitness.lean` (`ℤ ×ₗ ℤ`) develop the same apparatus twice; generalise to `α ×ₗ ℤ`.
- C-13 — `WorldHistory.lean:382–444` four dead Mathlib duplicates that **shadow** Mathlib's
  `neg_lt_neg_iff`/`neg_le_neg_iff` with the opposite orientation.
- F-09, F-10, F-17, F-11, F-12, F-13 — `bot_not_in_mcs` proved three times, none in `Core/`;
  `CanonicalTask_backward` a redundant inductive; `LimitMCS` proves the finite-intersection argument
  once by thresholds and once via `Filter` (the former is `Filter.eventually_all_finite`); a bespoke
  `Ultrafilter` structure shadowing Mathlib's in a file whose neighbour uses Mathlib's; the MCS↔ultrafilter
  bijection stated as an anonymous `∃` so both round trips are re-proved (state it as an `Equiv` —
  task 125 already asks for this); `List.foldl` meet vs `Multiset.inf`.
- B-07 — ≈ 110 lines of `SetConsequence.lean` with no consumer, two of which are the only reason it
  imports `Core.MaximalConsistent`.

**Tactic-automation / proof-elegance (9)**
- A-13, D-10 — no `truth_simp` set; 464 hand-typed `simp only` lists in the core scope; the four most
  common are `[TruthAt]` ×74, `[Formula.swapTemporal, TruthAt]` ×27, `[TruthAt, Truth.future_iff]` ×21,
  `[TruthAt, Truth.past_iff]` ×14. D-09 — many `simp only [Formula.swapTemporal, TruthAt]` are no-ops
  before `intro` (validated). D-11 — master `cases` blocks mix delegation and 5–25-line inlining with no
  principle; `axiom_validIn_min` (`Soundness.lean:1277`) is the good shape.
- D-12 — MCS reasoning (869 call sites of a five-lemma API, five top-20 hot spots in `UltrafilterMCS.lean`)
  is the right shape for a **named** Aesop rule set (`MCS`: `safe forward` ×4, `unsafe 50%`
  `negation_complete`); not validated — needs an experiment.
- D-20 — 231 validity intro-chains in ~44 spellings, 53 of them naming a `_h_mem` parameter that
  `Validity.lean:352–357` documents as removed. The tactics reviewer recommends **against** a
  `validity_intro` binder macro (macro hygiene makes it worse than `intro`); the soundness reviewer
  recommends one. Reconciled: normalise the spelling; put the effort into `truth_simp` + `sat_intro`.
- A-14 — two induction idioms for one recursion, duplicated `weakening` scaffold in `Soundness.lean:1422`
  and `BaseLanguageSoundness.lean:382`. A-17 — `Truth.box_const` states the insight but the four
  uniformity-axiom proofs re-derive it (`truthAt_atomFree_history_indep`). B-20 — `dedWitness_core`
  51 lines mixing four arguments. C-18 — the three (T1) biconditionals share a witness-frame pattern
  never named (`translation_realizes`). C-05 — frame-constant atom-truth lemmas proved but not `@[simp]`,
  forcing an 8-site `rw [show τ.val = … from rfl, …]` idiom.

**Naming / API (9)**
- A-15 — five conventions for "axiom X is valid" (`X_valid`, `axiom_X_valid`, `X_is_valid`,
  `swap_axiom_X_valid`, `X_swap_valid`); `valid` lowercase beside `ValidIn`/`ValidDense`.
- B-18 — `compactBase` / `discrete_consequence_not_compact` / `strongCompletenessDiscrete_refuted`: three
  schemes for one family. C-23 — `time_shift_*` vs `timeShift_*`. D-17 — 98 non-namespaced
  `Uppercase_x` theorem names (`CanonicalTask_backward_comp` → `CanonicalTask.backward_comp`);
  `theorem`:`lemma` 5,198:100 (G-11: normalise). F-19, F-20 — `iter_F_*` vs `iterF`; `FMCS (fc := …) D`
  at 130 sites because `fc` is declared after `D`. E-20 — five concepts with two or more names
  (Saturation/Spherical is tracked by task 517; `StrongCompleteness.lean` hosts the results the docs
  insist are *not* strong completeness — consider `ConsequenceCompleteness.lean`).
- C-24, C-25 — `galoisClosed_of_indicator` should take the `Iff`; `corrAtom` private in one file,
  inlined in another.

**Organization (7)**
- B-19 — the BL-vs-TM group (five loose files with a documented reading order) has no directory and
  no aggregator, against the sibling-aggregator convention — which is how C2 happened.
- C-11, C-19, C-20, C-21 — frame constants in five homes with no index; `Semantics.lean` does not
  aggregate two modules; `Semantics/README.md` omits `TemporalOrder`, `FrameProperty`,
  `FrameClassValidity` (the three most central files) and cites `truth_at`; `Independence.lean`'s
  docstring says "the one result" above a six-module list, two of which are definability results that
  belong beside `Indicator.lean`.
- D-16 — 146 orphan declarations in the core scope (5–8 %); triage into API-with-witness / delete /
  investigate (`UltrafilterMCS.lean:983,1056` look like headline theorems and are referenced nowhere).
- D-18 — `lakefile.lean` carries nine work-item citations; C9 scans `FormalSystem/` only.

**Documentation (24)**
- B-16, A-18, E-12, F-21 — refactor archaeology in publication-facing prose: 45 "before the collapse"
  lines in two files (`StrongCompleteness.lean` is 69 % prose, `Conservativity.lean` 80 %); "Formerly a
  strategic sorry", "Earlier revisions of this docstring…"; 19 change-log phrasings on live README
  surfaces; docstrings citing an axiom `temp_a` that does not exist; "But wait - we need:" mid-docstring.
- A-10, B-15, B-17, E-11, E-18, D-14 — verifiable prose/code mismatches: two files assert `TruthAt` takes a
  `Set.univ` argument it lacks; 6 of 16 `file.lean:NNN` citations wrong (38 %); `Conservativity.lean:347–357`
  names the wrong carrier and denies its own result ten lines from the correction; `Semantics.lean`'s
  truth-clause table shows a five-argument `TruthAt` with `H`/`G` clauses; `Automation/README.md` line
  counts wrong by 2–5× with 13 of 27 modules missing; 26 stale `Bimodal.*` references in 14 READMEs.
- A-11 — three source files cite an ephemeral `specs/NNN_…` report path, against the repo's own rule.
- E-06, E-07, E-09, E-10, E-13, E-16, E-17, E-19, E-21, E-22 — nine stale "Last verified" stamps;
  contents tables omitting live modules; the C14 tripwire regex lets "21 TM axiom" through; the typst
  sorry table labels an archived subtree as live; four paragraphs duplicated verbatim between `README.md`
  and `Metalogic.lean` (the transmission mechanism for C3); missing `CITATION.cff`/`ARCHITECTURE.md`;
  `cd ProofChecker` after cloning `BimodalLogic`; eight files below 70 % doc-comment coverage; the twelve
  flagship completeness/compactness theorems carry no paper anchor at the declaration site (the
  Semantics/Correspondence layers do this well — the convention stops at the Metalogic terminus).
- B-23 — 45 in-file `#print axioms` (64 tree-wide) duplicating C2's failing check with hand-transcribed
  output blocks.

---

## Low Priority Issues

A-17, A-19, B-22, B-23, C-09, C-14 (negative finding: `Walk`/`MinCyc` is **not** in Mathlib and should
stay — recorded so the question is not reopened; only `per_period` ↔ `Function.Periodic` is worth
hooking up), C-22 (five overlapping regression-`example` sections in `TaskFrame.lean`), C-23, C-24, C-25,
C-26 (`push Not` 544 vs `push_neg` 74), D-19 (heartbeat bumps: 51 total, 24 in the 15,252-line
`MintBound.lean` — a split candidate, not urgent; the two `synthInstance.maxHeartbeats 2000` in
`TemporalOrder.lean:178,181` *lower* the budget as regression guards and deserve a comment), D-21, E-18,
E-19, E-21, F-13, F-18 (`Bundle.lean` imports `FMCSDef` twice), F-19, F-20, G-07 (no `## Tags` sections
repo-wide; four files lack a module docstring), G-11, G-13, G-15 (`assert_not_exists` would make the
documented `Semantics → ProofSystem` seam machine-checked), G-16.

---

## Core utilities at the right level of abstraction

This is the answer to the review's central question. Every utility below is (i) proposed by at least one
territory reviewer with a signature, (ii) discharges at least two findings, and (iii) has a stated home.
Ranked by leverage; dependencies noted. Together they are the "cleanup pass" the refactor did not get.

| # | Utility | Home | Discharges | Lines out / in | Depends on |
|---|---|---|---|---|---|
| U1 | `formula_unfold` / `formula_fold` named simp attrs; `modalNorm`/`modalFold` as `simp only [attr]` | `Automation/Normalization.lean` | C1, D-01 | 4 hand lists → 0 | — |
| U2 | `Truth.{neg_iff,top_true,and_iff,or_iff,diamond_iff,always_iff,kPlus_iff,kMinus_iff}` `@[simp]`; tag `imp_iff`/`box_iff`/`bot_false`; `register_simp_attr truth_norm`; `macro "truth_simp"`; `swap_norm` set | `Semantics/Truth.lean` | H2, A-13, D-10, D-21, C-17, B-13, D-05 | ~250 / 40 | U1 |
| U3 | `abbrev TaskFrame.IsDense`; `structure TaskFrame.IsSuccArchDiscrete` with instance projections; `macro "sat_intro"`; `isSuccArchDiscrete_of_instances` bridge | `Semantics/FrameProperty.lean`, `FrameClassValidity.lean` | H3, A-04, C-10, B-21 | 45 adapters + ~250 docstring lines / 15 | — |
| U4 | `semantic_deduction_in`, `soundness_consequence`, `def WeakCompleteness fc`, `compact_of_strongCompleteness`, `strongCompleteness_iff_compact`, `setConsequence_of_not_satisfiable`, `not_compact_of_witness`, `not_strongCompleteness_of_witness`, `compact_iff_modelExistence`, `modelExistence_of_satPreserved` | `Metalogic/{StrongCompleteness,SetConsequence,Compactness}.lean` | H4, B-01–B-06, B-09, B-10, A-05 | ~230 / 60 | U3 (easier after) |
| U5 | `structure PointedModel fc Γ`; `SatisfiableSet fc Γ := Nonempty (PointedModel fc Γ)`; `FinitelySatisfiableSet`; `SatisfiableSet.mono`; compactness as `SatisfiableSet ↔ FinitelySatisfiableSet` (Mathlib `Theory.ModelType`/`IsSatisfiable` shape, `ModelTheory/Bundled.lean:73`, `Satisfiability.lean:65,100`) | `Metalogic/SetConsequence.lean` | G-01, G-03, B-21; four `*_of_forall` constructors → one `PointedModel.of` | ~60 / 30 | U4 |
| U6 | Helper D `spherical_of_fib_subsingleton` + `fib_subsingleton_of_functional`; Helper B completion (`nullity_identity_of_permissive`, `converse_of_permissive`, `comp_of_permissive`); `WorldHistory.ofTotal` / `TaskFrame.HF.ofTotal` + `@[simp]` states lemma | `Semantics/TaskFrame.lean`, `WorldHistory.lean` | H7, C-01, C-03, C-05, C-12, C-18 | ~200 / 50 | task 517 |
| U7 | `structure TruthIso M M'` (`dur : D ≃o D'`, `hist : HF ≃ HF'`, atom compat) + `truthAt_of_truthIso` and its anti-isomorphism twin concluding `φ.swapTemporal` | `Semantics/Truth.lean` | C-02, A-12 (`time_shift_preserves_truth` 236 → ~90) | ~370 / 90 | U2 |
| U8 | `Th`/`Mod`/`GaloisClosed` as `abbrev`s over `upperPolar`/`lowerPolar`/`Order.IsExtent` of `validOnRel`; `galoisClosed_of_indicator_iff` | `Semantics/Correspondence/Galois.lean` | C-06, G-06, C-24 | ~45 / 10, plus free `IsExtent.iInter`, `l_sup`, `l_iSup`, `u_top` | — |
| U9 | Order-dual cores `exists_nearest_succ`, `forall_gt_of_succ_step` (`P : D → Prop`, successor-Archimedean); `isLeast_succ_of_isLeast_pos`; `LexInt` namespace at `α ×ₗ ℤ` | `SoundnessLemmas/DiscreteOrder.lean` (new), `Semantics/DurationClassification.lean`, `Semantics/LexCarrier.lean` | A-06, C-15, C-16 | ~200 / 60 | — |
| U10 | `blValidIn_iff_validIn_tr (fc)` — the one BL transfer theorem | `Metalogic/BaseLanguageSoundness.lean` | A-07 | ~30 declarations become corollaries | U3 |
| U11 | `exists_maximal_of_chainClosed` (generic Zorn); `restricted_mcs_iter_bounded` via `Nat.find`; `SetMaximalConsistent.bot_not_mem`; `SetMaximalConsistent.ultrafilterEquiv`; `someFuture_mono`/`somePast_mono` | `Metalogic/Core/*`, `Algebraic/UltrafilterMCS.lean`, `Theorems/TemporalDerived.lean` | B-11, B-12, F-22, F-09, F-12, F-15 | ~400 / 120 | F-02 relocation |
| U12 | `structure BFMCS.CanonicalCoherence` bundling the three coherence hypotheses (drops the unused `_h_rtc`); `allFuture_neg_of_gseed_inconsistent` + past mirror; the temporal-duality discipline (`mirror` via `temporal_duality` + `swap_temporal_involution`; `TemporalSide` parameter for `<`/`>` mirrors); `limitSetBelow` as `∀ᶠ` over `Filter.comap Rat.cast (𝓝[<] r)` | `Bundle/TemporalCoherence.lean`, `WitnessSeed.lean`, `LimitMCS.lean` | H6, F-05, F-08, F-14, F-17 | ~800–1,400 / 200 | H5 cleanup |
| U13 | `truthAt_atomFree_history_indep`, `truthAt_gap_shift` | `Semantics/Truth.lean` | A-17 (four uniformity-axiom proofs → two-liners) | ~60 / 15 | U2 |
| U14 | `DerivationTree.ofWeakeningNil` + height lemma (TM and BL twins) | `ProofSystem/Derivation.lean` | A-14 | ~25 / 10 | — |
| U15 | `MCS` named Aesop rule set + `mcs_auto` (experiment first) | `Metalogic/Core/MCSAesop.lean` (new) | D-12 | unknown until validated | U11 |
| U16 | Deploy `propDecide` in `BooleanStructure.lean` / `LindenbaumQuotient.lean` | existing `Automation/Tactics/PropDecide.lean` | D-08 | ~430 / 60 | — |

Explicitly **not** recommended, so the questions are not reopened: a typeclass `FrameClass.Sat` (C-frames
§2 — `IsSuccArchDiscrete` carries data); replacing `Walk`/`MinCyc` with Mathlib (C-14); a `validity_intro`
binder macro (D-20 — hygiene); a `ClosureOperator` step on top of the Galois connection (G-ecosystem §3.3);
physically regrouping the three completeness routes (the README's measured decision stands).

---

## Automation kit

The tactics reviewer's validated ranking (D-tactics §5). Existing infrastructure: 20 tactics in
`Automation/`, of which 19 have zero library uses; the six EF-game tactics (68 sites) are the only
production automation. No `register_simp_attr` anywhere; `@[simp]` density 3.7 % of theorems.

1. **U1** — named `formula_unfold`/`formula_fold` sets. **Validated** (loop reproduced).
2. **U2** — `Truth` simp-normal form. **Validated in part** (`Truth.imp_iff` drop-in at `DenseValidity.lean:302`;
   the `and_iff`/`or_iff` proofs already compile in `BLTruth.lean`).
3. **U16** — deploy `propDecide`. **Validated** (closes distributivity and De Morgan; rejects a non-tautology).
4. `truth_norm` set + `truth_simp` tactic (≥ 279 sites). Blocked on 2.
5. `swap_norm` set over the nine `Formula.swap_temporal_*` lemmas (~55 sites).
6. **U15** — `MCS` Aesop set. **Not validated**; run on `RestrictedMCS/Basic.lean:137` and one
   `UltrafilterMCS` lemma before committing.
7. Move `AesopRules.lean`'s 18 default-set attributes into `declare_aesop_rule_sets [TMLogic]`.
8. `lean_exe runLinter` (`import FormalSystem` + `#lint`) with `simpNF` + `dupNamespace` blocking, behind
   an `ENFORCE_C16` flag in `check-module-invariants.sh`. Would have caught C1 on the day it landed.

---

## Ecosystem alignment (Mathlib / CSLib / FFL)

From the ecosystem survey (G-ecosystem), verified against the pinned local Mathlib and fetched sources:

- **Mathlib `ModelTheory`** is the template for the consequence layer: one `Theory.IsSatisfiable`
  (`Satisfiability.lean:65`), never per-theory copies; `IsSatisfiable := Nonempty (ModelType T)`
  (`Bundled.lean:73`); compactness as `isSatisfiable_iff_isFinitelySatisfiable` (`:100`);
  `models_iff_not_satisfiable` (`:296`) as the consequence/satisfiability bridge. The *machinery* does not
  transfer (TM is not a single-sorted first-order theory; `Filter.Product` needs a `Prestructure`); the
  **API shape** does — U4/U5 above. The repo's `Ultraproduct/` layer independently rebuilt Mathlib's three
  moving parts (`Idx`/`tailFilter` ≈ `Filter.atTop` on `Finset T`) correctly.
- **Galois connections**: `Th`/`Mod` is exactly Mathlib's antitone theory/model pair — the shape of
  `PrimeSpectrum.gc` (`RingTheory/Spectrum/Prime/Basic.lean:185`) and the Nullstellensatz connection
  (`Nullstellensatz.lean:87`), and *even more exactly* `Order/Concept.lean`'s polars (U8). Zero
  `GaloisConnection` occurrences in the repo today.
- **Formalized Formal Logic / ModalLogic** (`ModalLogicArchive/Modal/Kripke/Logic/S5.lean`): the whole
  metatheory of S5 relative to its frame class is four `instance` lines — `Sound`, `Consistent`,
  `Canonical`, `Complete := inferInstance`. The pattern to borrow is a `Sound`/`Canonical`/`Complete`
  typeclass triple indexed by `fc` with completeness *derived* from canonicity (G-04); its truth lemma is
  proved once generically over an abstract entailment (P4), which is what U12's `CanonicalCoherence`
  moves toward. FFL has no temporal logic; TM's `Until`/`Since` layer has no precedent there. The
  inductive `FrameClass` should stay (`DerivationTree` needs `DecidableEq`); the *semantic* side can
  carry inclusion by instances (`instance [F.IsDedekind] : F.IsDense`) rather than a 64-case `le_trans`
  (G-05) — compatible with U3.
- **CSLib** (`leanprover/cslib`): `ORGANISATION.md` lists `Cslib.Logic.LinearTemporalLogic` as a **planned,
  currently empty** directory — an open slot TM's temporal fragment could contribute to. Furniture worth
  adopting regardless: a `FormalSystem/Init.lean` linter root (à la `Cslib/Init.lean` + `checkInitImports`),
  `references.bib`, `ORGANISATION.md`, `NOTATION.md`, per-logic judgement notation tags
  (`TM[...]`) since the repo carries four `⊨`-shaped relations, `theorem` everywhere, proof systems in
  `Type` (which `DerivationTree` already is — record it as a deliberate alignment).
- **LeanLTL** (UCSC, ITP 2025): one semantic core with object logics as thin embeddings; a dedicated
  `Util/SimpAttrs.lean`; examples as a *separate* library rather than inside the default target.
- **Mathlib style compliance** is already strong where it counts: 433/434 copyright headers, 430/434 module
  docstrings, 90 % doc-comment coverage in the core scope, `autoImplicit := false`, and a `#print axioms`
  discipline (`DiscreteNonCompactness.lean:292–312`) better than most research repos. Gaps: no `## Tags`,
  no `library_note`, no `assert_not_exists`, no `#lint`, CI gated on `[ci]`.
- **Publication packaging recipe** (G §8, ~3 days): `Init.lean` + linter; CI on every push with
  `lint: true`; `references.bib`; `leanprover-community/docgen-action` → GitHub Pages; a
  `FormalSystem/MainResults.lean` restating every headline theorem with `#print axioms` (generalising
  the pattern the two non-compactness files already use); `CITATION.cff`. Blueprint only if
  `typst/`/`latex/` become the paper.

---

## Documentation architecture

Single-source-of-truth policy (E-docs §5.1), adopted here as the review's recommendation:

| Fact class | Owner | Every other surface |
|---|---|---|
| Axiom sets / sorry-freeness | `check-module-invariants.sh` C2 + C14, extended from 8 to the full flagship set | a pointer to the check |
| File / line / directory counts | `check-module-invariants.sh --emit-inventory` → `<!-- BEGIN GENERATED -->` blocks | nothing hand-typed |
| Per-theorem human-readable status | **one** ledger: `docs/theorem-index.md` (schema: paper label · statement · Lean name · file · class · axioms-generated); 16 rows already drafted in E-docs §5.2 | `README.md` keeps a ≤ 5-row highlights table + link |
| Mathematical narrative | the declaration's `/--` doc comment, present tense, with a paper anchor | READMEs summarise in ≤ 2 sentences |
| Design decisions and history | `docs/decisions/*.md` (ADRs — the mechanism already exists) | current-state prose only; no "used to be" |
| Object-language definition | top-level `README.md` §Operators (the only correct copy) | links |

Two new gates make it self-enforcing: **C16** (fail if a ≥ 25-word paragraph appears in two of the four
status surfaces — would have caught C3 when introduced) and **C17** (resolve every backticked declaration
name in `FormalSystem/**/*.md` and `docs/**`, reusing `typst-sync-check.sh`'s resolver — would have caught
C5 and E-18). Plus: widen C14's regex (E-09), have `readme-lint.sh` compare "Last verified" against
`git log -1 -- <dir>` (E-06), and scan `lakefile.lean`/`README.md` in C9 (D-18).

Docstring register, applied once across the core scope (A-18, B-16): **(a)** doc comments state what a
declaration means, its paper anchor, and any caller trap; **(b)** `docs/decisions/` or the module README
carries rejected alternatives and layering rationale; **(c)** commit messages carry "formerly a sorry",
"before this delta". `Metalogic/README.md`'s "Why There Is No Physical Regroup" and the archive
consolidation narrative move to (b). `Semantics/Correspondence/README.md`, `Metalogic/Independence/README.md`
and `Metalogic/SoundnessLemmas/README.md` are fully compliant and accurate — use them as the template.

---

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| `lake build` | exit 0, 2,515 jobs | **Pass** |
| `check-module-invariants.sh --no-build` | **C6 FAIL** (4 unmanifested unreachable modules); 14 other checks pass | **Fail** |
| C3 structural sorry inventory | 0 across `FormalSystem/` (Boneyard excluded) | Pass |
| `native_decide` / `Lean.ofReduceBool` | 0 | Pass |
| Linter warnings in build | 1 (`DatasetGenerator.lean:2269`, unused `q`) | Info |
| TODO / FIXME count | 5 / 0 | OK |
| Live `.lean` files | 434 `FormalSystem` / 54 `Tests`; `Metalogic/` 323 files, 229,930 lines | Info |
| Global-simp-set loop (`Normalization.lean`) | 10 inverse `rfl` pairs; 43 modules affected | **Critical** |
| Unreachable code in reviewed scope | ~2,300 lines (615 `DenseValidity`, 611 `Bundle/`, 146 orphan decls) | **Warning** |
| Verbatim / mirror duplication | ~1,900 lines (321 identical dispatcher lines; ~30 F/P mirror pairs; 5× `and_of_not_imp_not`; 4× `truth_and_iff`; 5× `induction φ` transport; 7× *Spherical*) | **Warning** |
| Per-class theorem instantiations provable once | ~230 lines (4× deduction, 4× soundness guard, 8× completeness corollaries, 2× model existence, 4× refutation skeleton) | Warning |
| `@[simp]` per theorem (live scope) | 3.7 % (191 / 5,298); `Truth` namespace 6/13, `BLTruth` 8/13, disjoint halves | Warning |
| Named simp sets / `#lint` / `assert_not_exists` / `GaloisConnection` | 0 / 0 / 0 / 0 | Warning |
| Custom tactics with zero library uses | 19 of 26 (14 with zero test uses either) | Warning |
| `simp only […TruthAt…]` sites | 229 core / 279 live | Info |
| Validity intro-chains | 231 sites, ~44 spellings, 53 naming a removed parameter | Info |
| Directory-level import cycles | **3** (README claims 2); `Core↔Bundle` breakable in 3 files, `Bundle↔Algebraic` in 2 | Warning |
| Doc-comment coverage (core scope) | 924 / 1,028 = **90 %**; 67/68 module docstrings | **Pass** |
| Status claims in `Metalogic.lean` machine-pinned | 8 of 37 (33 prose-only) | Warning |
| Stale numeric claims across four doc surfaces | ~40 of 68 checked | **Warning** |
| Cross-document contradictions | 3 (Dedekind row, Boneyard count, sorry status) | **Critical** |
| `file.lean:NNN` citations in the five main metalogic files | 6 of 16 wrong (38 %) | Warning |
| CI | build ✓ · **test ✗** · **lint ✗** · skipped on push without `[ci]` | **Warning** |
| `set_option maxHeartbeats` | 51 live (24 in `MintBound.lean`); 0 in the reviewed core | OK |
| `theorem` : `lemma` | 7,031 : 141 | Info |
| Mathlib style compliance | headers 433/434; module docstrings 430/434; `autoImplicit := false`; `#print axioms` discipline | Pass |

---

## Roadmap Progress

### Completed Since Last Review
The four tasks the 2026-08-31 review spawned are complete and archived: 507 (validity indexed by
`FrameClass`), 508 (one soundness theorem + corollaries), 509 (`FrameClass`-indexed compactness family),
510 (`FrameConditions/` resolved). Their effect is confirmed throughout this review. Also since:
494 (Dedekind non-compactness — the refutation `README.md` still denies), 516 (documentation ledger),
513 (Galois closure), 495 (Z1 countermodel — the module C2 shows is unbuilt).

`roadmap-integration.sh`: 22 candidate matches, all `low_confidence`, 0 annotations applied (same as the
last three runs — no archived task populated `completion_data.roadmap_items`).

### Current Focus
| Phase | Priority | Current Goal | Progress |
|-------|----------|--------------|----------|
| Phase 1 | Low (weak DONE; strong DONE for Base/Dense, refuted for Discrete/Dedekind) | consolidation | 5/7 checkboxes; the Phase's mathematics is finished |
| Phase 2 | High | Decidability / tableau engine | largest open front; untouched by this review |
| Phase 5 | Medium | Publication and documentation | **this review's programme lands here** |
| Phase 7 | Low | Repository hygiene | C6 red; linter absent |

### Roadmap Signal
- **Structure**: 7 phases, 39 checkboxes, 60 table rows — parseable: true
- **Warnings**: none
- **Skipped**: 22 items skipped — reasons: `low_confidence`

### Recommended Next Tasks
See §Integration below — a sequenced programme rather than a list.

---

## Integration with the live task portfolio

The active portfolio has 37 tasks: 13 decidability, 7 algebraic-representation, 6 dataset, 2 literature,
2 frame-extensions, 2 formula-refactor, 1 semantics, 1 publication-quality, 1 automation. The
decidability and dataset fronts are orthogonal to this review. The following existing tasks intersect it
and should be adjusted rather than duplicated:

| Task | Status | Intersection | Recommendation |
|---|---|---|---|
| **193** `automation` — "Apply validity-intro and truth-simp macros to the soundness layer" | not_started | Its `simp_truth` half is exactly U2/`truth_norm`; its `intros_validity` half is the binder macro D-20 argues against; its measured targets (`DenseValidity.lean` 92 intros / 54 simps) are files H1 deletes | **Re-scope**: drop the intro macros, retarget the simp half onto U2 + `truth_simp`, sequence *after* H1 (else it rewrites 600 lines that are about to be deleted). Or abandon in favour of the Wave-2 task below, which subsumes it. |
| **517** `semantics` — Spherical → Saturation rename | not_started | Touches `TaskFrame.Spherical`, the `spherical` field, and every `*_spherical` witness — the same declarations U6's Helper D collapses seven copies of | **Do 517 first**, then the frame-kit task; doing them in the other order renames seven copies that are about to become one. |
| **177** `formula-refactor` — final docs polish, gated on the decidability chain (16 deps) | not_started | The E-* documentation findings overlap its charter, but 177 is gated on 426–434, which are months out | Keep 177 as the gated decidability-docs pass. The **un-gated** metalogic-docs work (C3–C5, H8's doc half, the single-source-of-truth policy) is a new task; record it as a dependency of 177 so 177's residual shrinks. |
| **178** `formula-refactor` — publication-quality `Examples/` | not_started | G-10's `FormalSystem/MainResults.lean` (every headline theorem + `#print axioms`) is the artefact 178 should produce first; LeanLTL's separate examples library is the layout precedent | Add `MainResults.lean` to 178's scope; sequence after Wave 3 so the examples cite the final names (`ValidDedekind`, `WeakCompleteness`, `strongCompleteness_iff_compact`). |
| **497 / 499 / 125** `algebraic-representation` — STSA port, `Uf(A)`, Jonsson–Tarski | not_started | F-11 (bespoke `Ultrafilter` shadowing Mathlib's; `Order.PFilter`/`Ideal.IsPrime` reuse), F-12 (`ultrafilterEquiv` — 125's description already asks for it), F-13, D-08 (`propDecide` in `BooleanStructure.lean`) all live in the files 497/499 build on | Insert an **`Algebraic/` modernisation** task (U11's Algebraic half + U16) as a dependency of 497 and 125; otherwise the representation front inherits a shadowed `Ultrafilter` name and 430 lines of hand-built Boolean algebra. |
| **500** `algebraic-representation` — reconcile `ShiftSet.reverse_repr` with STSA | not_started | C-01/C-03's frame kit and `ShiftSet.frame`'s inline *Spherical* (`ShiftSet.lean:186`) are in its scope | No change; note the kit in its research brief. |
| **127 / 128** `frame-extensions` — time addition `+`, interior operator | not_started | Each adds a `Formula` constructor and truth clause — the exact stress test for U1 (fold/unfold sets), U2 (`truth_norm`), U7 (`TruthIso` gets a new case), and the one-line dispatch shape of H1/C6 | Sequence **after** Waves 1–2; the point of those waves is that a new constructor costs one arm per dispatcher and one `@[simp]` lemma, not edits at 300 sites. |

### Proposed programme (14 new tasks, 518–531, in dependency waves)

Sizing follows H8 (each phase one agent run); every task below is scoped so its acceptance criterion
is a measured line delta plus `lake build` + `check-module-invariants.sh` green.

**Wave 0 — hotfix (one task, S, no dependencies).** C1 named simp sets; C2 wire the four modules +
`Semantics.lean` aggregator + C6 green; C3/C4/C5 doc contradictions; F-03 orphan deletion (cycle);
D-13 Aesop default-set attributes into a named set. Everything else in this review should land on a
tree where `simp` works and the invariant script passes.

**Wave 1 — deletion (two tasks, S–M).**
- *SoundnessLemmas consolidation*: H1 + C6 (delete `DenseValidity.lean`, `Core.lean`, `IsValid`; one
  dispatcher with one-line arms; D-09 no-op `simp only`s; A-09; D-05). Acceptance: `SoundnessLemmas/` ≤
  1,400 lines from 2,487; one 45-arm dispatcher.
- *Bundle/ retirement and cycle-breaking*: H5 (three modules to Boneyard; `IteratedTemporal.lean`;
  `Theorems/ModalDerived.lean`; diary deletion; F-18; F-21 docstring corrections; `Bundle/README.md`
  regenerated). Acceptance: directory cycles = 1 (`BXCanonical ↔ WeakCanonical`, the measured one),
  `Metalogic/README.md:88` corrected.

**Wave 2 — semantic core utilities (three tasks, M; depends on Wave 0; the frame kit also on 517).**
- *Truth-layer simp-normal form*: U2, U13, D-10, D-21, C-05, C-17, then apply across `Soundness.lean` /
  `SoundnessLemmas/` / `Correspondence/` (subsumes the surviving half of 193). Acceptance: `simp only
  […TruthAt…]` sites −80 %; zero private copies of `truth_and_iff`/`and_of_not_imp_not`.
- *Frame-property representation and validity names*: U3, U10, C-08/A-16 renames, C-09, C-10, A-15
  naming convention, D-20 spelling normalisation. Acceptance: binder adapters 47 → 2 (+ BL twins);
  `ValidX = ValidIn .X` for every tag; nine "Read this first" warnings → one cross-reference.
- *Frame kit*: U6, U7, U9, C-07, C-11 (`Semantics/Frames/Standard.lean`), C-13, C-16, C-19–C-21 README
  fixes. Acceptance: *Spherical* discharged in one helper; five `induction φ` transports → one lemma +
  five instantiations; `natFrame`/`genericNatFrame` merged.

**Wave 3 — metalogic theorem layer (three tasks, M; depends on Wave 2).**
- *Consequence and compactness generics*: U4, U5, B-03, B-07, B-18 renames, B-19 `Metalogic/Conservativity/`
  directory + aggregator, B-20, B-21, B-22, B-23. Acceptance: `strongCompleteness_iff_compact` and
  `compact_iff_modelExistence` exist; four refutations are two-liners; `#print axioms` moved into C2.
- *Galois over Mathlib and correspondence tidy*: U8, C-14 hookups, C-18, C-21 relocation decision, G-13.
- *Core/ MCS API*: U11 (Core half), U14, U15 experiment, F-09, F-10. Acceptance: one Zorn lemma; `_F_`/`_P_`
  boundedness one lemma; `bot_not_mem` in `Core/`.

**Wave 4 — canonical-model and algebraic infrastructure (two tasks, L / M; depends on Waves 1, 3).**
- *Bundle/ temporal-duality discipline*: U12 (H6). Largest single reduction (800–1,400 lines); land the
  witness-seed core and `CanonicalCoherence` first (M), the mirror sweep second.
- *Algebraic/ modernisation*: U16 (`propDecide`), F-11, F-12 (`ultrafilterEquiv`), F-13. **Dependency of
  497 and 125.**

**Wave 5 — publication infrastructure (three tasks, M; Wave 0 first, otherwise parallel).**
- *CI, linter and invariant gates*: D-15 (`test: true`, `lint: true`, `runLinter`, drop the `[ci]` gate),
  G-08 `Init.lean`, G-15 `assert_not_exists`, D-16 orphan scan as C17, D-18 C9 widening, E-09, E-06,
  C16 duplication gate.
- *Single source of truth for documentation*: E-14 policy, generated inventories (E-04/E-05/D-14),
  `docs/theorem-index.md` (E-15) with paper anchors at the twelve flagship declarations (E-22), ADRs
  (E-12), terminology table (E-20), `CITATION.cff` + `docs/ARCHITECTURE.md` (E-16), all remaining
  E-/A-10/A-11/B-14–B-17 corrections. Dependency of 177.
- *doc-gen4 publication and the automation suite*: E-08/G-14 (`docgen-action`), G-09 furniture,
  D-02 suite triage + `Helpers.lean` split, D-17/G-11 naming normalisation, G-10 `MainResults.lean`
  (hand to 178).

Then 127/128 (frame extensions), 178 (examples), and the algebraic-representation front proceed on a
consolidated base.

**Task Order goal.** The current goal — "Systematize the metalogic: index validity, soundness, and
compactness by FrameClass, then discharge strong completeness for Base and Dense via the ultraproduct
chain" — is achieved. Proposed successor: *"Consolidate the metalogic after the FrameClass refactor:
delete superseded code, land the truth/frame/consequence core utilities, then publish — doc-gen,
theorem index, CI lint."*

---

## Recommendations

1. **Land Wave 0 today.** Six small edits close all six Criticals and turn the invariant script green.
   Nothing else in this review should be started on a tree where `simp` loops and C6 is red.
2. **Delete before you abstract.** Waves 1 and 2 are ordered so that the ~2,300 unreachable lines and the
   second dispatcher are gone before any proof is rewritten; otherwise task 193's targets and the
   frame-kit sites are rewritten twice. Re-scope 193 and sequence 517 first, per the table above.
3. **The truth-layer simp set is the highest-leverage single change** (five reviewers converged on it,
   the proofs already exist in `BLTruth.lean`, ~300 proofs shorten). Do it immediately after Wave 0
   and Wave 1's deletion.
4. **Adopt the Mathlib shapes where they exist** — `ModelType`/`IsSatisfiable`/`iff`-compactness for the
   consequence layer, `Order.Concept` polars for `Th`/`Mod`, `Nat.find`/`Filter.Eventually`/`Multiset.inf`/
   `Order.PFilter` in `Core/` and `Algebraic/` — and record the negative results (`Walk`/`MinCyc`) so
   they are not re-surveyed.
5. **Make status machine-owned.** Extend C2/C14 from 8 to all flagship declarations, generate every
   count, create `docs/theorem-index.md`, add the C16/C17 gates, and turn `#lint`/tests on in CI. The
   three contradictions in this review are the cost of not having done so; the mechanism
   (`typst-status-counts.sh`, C7's inventory) already exists.
6. **Do not start 127/128 or the Jonsson–Tarski construction before Waves 2–4.** Both add constructors
   or build on `UltrafilterMCS.lean`; the whole point of the consolidation is that those additions then
   cost one arm and one lemma each.
