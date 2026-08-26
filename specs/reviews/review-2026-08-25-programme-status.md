# Programme Status Review: Completeness, Soundness, FMP, Tableau

**Date**: 2026-08-25
**Scope**: The four fronts named in the review request — completeness results; the
Base-then-extensions soundness architecture; decidability via the finite model property; and the
tableau system's soundness and completeness
**Reviewed by**: Claude
**Verification commit**: `a1710f1d2`

## Verification Basis

Every status claim below is grounded in the Lean source, not in documentation. A fresh
`scripts/check-module-invariants.sh` run at `a1710f1d2` reports **ALL CHECKS PASSED** (18 checks):

| Check | Result |
|-------|--------|
| C1 `lake build` (library + BimodalTest) | exits 0 |
| C2 four flagship axiom sets | all `[propext, Classical.choice, Quot.sound]` — no `sorryAx` |
| C3 structural `sorry` inventory | **ZERO** across `FormalSystem/` (Boneyard excluded) |
| C4/C5/C6/C8/C11/C12/C13 | all imports, module paths, aggregators, links resolve |
| C14 | no stale axiom/sorry counts in `docs/`, `README.md`, `FormalSystem/*.lean` |
| C15 | all 46 paper-anchor citations resolve against the pinned record |

Independently reproduced: structural `sorry` count **0**, real `axiom` declarations **0**
(the 5 `grep` hits are prose word-wrap, the ~110 `sorry` string hits are all docstring narrative
such as "sorry-free"). `Boneyard/` carries 108 structural sorries and is excluded by design.

Scale: 413 live `.lean` files, 272,847 lines (569 files / 361,122 lines including Boneyard).
`Metalogic/` is 227,089 lines of that.

---

## Front 1 — Completeness: **finished at the weak and consequence levels; open only at the infinitary level**

### Done

| Class | Weak completeness | Consequence (finite `Γ : Context`) | Soundness counterpart |
|-------|-------------------|------------------------------------|----------------------|
| **Base** | PROVEN — `BXCanonical/Completeness.lean:196` | PROVEN — `StrongCompleteness.lean:535` | `soundness` (`Soundness.lean:1086`) |
| **Dense** | PROVEN — `BXCanonical/Completeness.lean:255` | PROVEN — `StrongCompleteness.lean:639` | `soundness_dense` (`:1260`) |
| **Discrete** | PROVEN — `BXCanonical/Completeness.lean:296` | PROVEN — `StrongCompleteness.lean:746` | `soundness_discrete` (`:1406`) |
| **Dedekind** | PROVEN — `StrongCompleteness.lean:469` | PROVEN — `StrongCompleteness.lean:450` | `soundness_dedekind` (`:1933`) |

All eight are sorry-free and axiom-clean. The last live sorry in the tree —
`WeakCanonical.countermodel_discrete`, the Base class's discrete branch — was closed by tasks
477→478→479 via a k-equivalence / groupable-companion construction at the non-Archimedean carrier
`ℚ ×ₗ ℤ`, landing in `WeakCanonical/GroupModel/CountermodelBase.lean:142`.

Task 362 (the consequence-completeness capstone) has since **completed**: fourteen new
declarations in `StrongCompleteness.lean` gave finite-context consequence completeness
unconditionally for all four classes, with a nine-entry `#print axioms` audit block. Task 424
(the shift-set representation theorem, the feasibility gate authorizing the ultraproduct route)
also completed.

### Open

**Genuine strong completeness (arbitrary `Γ : Set Formula`) is proven for zero classes**, and the
three statuses must not be collapsed:

- **Discrete — REFUTED.** `strongCompletenessDiscrete_refuted` and
  `discrete_consequence_not_compact` (`Metalogic/DiscreteNonCompactness.lean:280`) settle it
  negatively under `IsSuccArchimedean`.
- **Base and Dense — OPEN.** Gated entirely on compactness. `CompactBase` / `StrongCompletenessBase`
  and `CompactDense` / `StrongCompletenessDense` (`Metalogic/SetConsequence.lean`) name the
  obligations; `strongCompletenessBase_of_compact` keeps its `engine` hypothesis live deliberately
  so `CompactBase` is isolated as the whole remaining obligation. The ultraproduct route is
  authorized (task 424 passed) but **not yet scoped as tasks**.
- **Dedekind — NOT STATED AT ALL.** Reynolds 1992 Theorem 7 is weak-only by the paper's own
  restriction, so this is a deliberate absence, not an oversight — but it is also not recorded as
  a named obligation the way Base/Dense are.

Also open: `latex/subfiles/04-Metalogic.tex`'s "Strong Completeness and Compactness" section still
needs restating for the `Set Formula` statement only.

**Verdict: the completeness *theorems* are done and clean; the completeness *programme* has one
genuine remaining item (compactness for Base and Dense) and one bookkeeping item (a named
Dedekind obligation).**

---

## Front 2 — Soundness refactoring: **the architecture you describe already exists for TM⁺; it does not exist for TM**

### Done — `Metalogic/Soundness.lean` (2,028 lines) is exactly Base-first-then-extensions

The refactoring is not pending; it is the shipped structure. Five layers:

- **Layer A — per-axiom validity lemmas** (`:121–860`, plus the Reynolds block `:1476–1744`).
  ~50 lemmas, each proving one axiom valid at the weakest class that supports it.
- **Layer B — per-frame-class axiom dispatchers**, one `cases h` over all 45 constructors each:
  `axiom_valid` (`:861`, Base), `axiom_dense_valid` (`:915`), `axiom_discrete_valid` (`:976`),
  `axiom_dedekind_valid` (`:1745`), `axiom_dedekind_swap_valid` (`:1814`).
- **Layer C — rule-preservation helpers**: `necessitation_preserves_valid` (`:1048`),
  `temporal_necessitation_preserves_valid` (`:1059`).
- **Layer D — the four soundness theorems**, each a 7-case induction over `DerivationTree`.
- **Layer E — consistency corollaries**: `not_derivable_nil_bot` (`:1993`),
  `not_derivable_nil_bot_discrete` (`:2020`).

The mechanism that makes it modular is a single gating hypothesis, `h_fc : h.minFrameClass ≤ fc`
in `DerivationTree.axiom` (`ProofSystem/Derivation.lean:98`). Off-class constructors are
eliminated *structurally* by `absurd h_fc (by simp [Axiom.minFrameClass, LE.le])` — there are no
ad-hoc `isBase` / `isDenseCompatible` predicates left anywhere. `FrameClass`
(`ProofSystem/Axioms.lean:531`) is a **partial** order: `Base ≤ everything`, `Dense ≤ Dedekind`,
`Discrete` incomparable with both. The 45 axioms partition 37 Base / 2 Dense / 3 Discrete /
3 Dedekind.

One deliberate asymmetry is worth knowing about, documented at `Soundness.lean:1438–1454`:
`soundness_dedekind` targets **`ValidDedekindDense`, not `ValidDedekind`**, because
`Dense ≤ Dedekind` makes `density`/`dense_indicator` admissible in a Dedekind derivation and both
are false on ℤ, which is Dedekind-complete. A `ValidDedekind`-targeted version would be refutable.

Supporting: `SoundnessLemmas/` (5 files, 3,016 lines) and a typeclass-parameterized restatement
layer at `FrameConditions/Soundness.lean` (206 lines, no Dedekind entry).

### Open — the paper's **TM** (BaseLanguage) has no soundness theorem at all

`FormalSystem/BaseLanguage/` is a complete second proof system: `BLFormula` with `allPast`/
`allFuture` **primitive** (`Formula.lean:72`), a 16-constructor `Axiom` inductive
(`Axioms.lean:73`) reusing the same `FrameClass`, a constructor-for-constructor mirror
`DerivationTree` (`Derivation.lean:68`), a translation `tr : BLFormula → Formula`
(`Translation.lean:69`), and per-axiom discharge derivations (`AxiomDischarge.lean`).

It has **no semantics and no soundness theorem**. That is a stated module invariant — *"Nothing
under `FormalSystem/BaseLanguage/` imports anything from `FormalSystem/Semantics/`"* — and
`grep -rn "soundness" FormalSystem/BaseLanguage/*.lean` returns nothing.

Consequence, identified by task 488's paper-alignment research and written up as memo item **D5**:
the JPL paper asserts at four sites (`possible_worlds.tex:1661`, `:4311`, `:4484`, `:4494`) that
`thm:TM-soundness` is formalized in Lean. The **TM⁺** half of every one of those sentences is
fully supported by the four theorems above. The **TM** half is not. The result would follow by
composing `Metalogic.Conservativity.translate` with `Metalogic.soundness`, but that composition
is stated nowhere.

Related: `Metalogic/Conservativity.lean` proves only the **backward** direction
(`derivable_translate:194`, `TM ⊢ φ ⟹ TM⁺ ⊢ tr φ`). The forward direction is deliberately
unproved and explicitly must not be `sorry`-ed; its CEF witness would need soundness over
`ℤ ×lex ℤ` — "an argument this repository cannot yet make" (`:269`).

**This is tracked as task 489** (`prove_baselanguage_soundness_base_and_extensions`, `not_started`,
created 2026-08-26 out of task 488's D5 split). It is the smallest well-scoped open item on any of
the four fronts, and closing it retires a live over-claim in a paper heading to publication.

---

## Front 3 — Decidability via FMP: **the existing `FMP/` directory is not a decidability route**

### What is proven

`Decidability/FMP/` — 6 files, 2,000 lines, entirely sorry-free:

- `mcs_finite_model_property` (`FMP.lean:263`): `¬Derivable FrameClass.Base [] φ → ∃ S : ClosureMCSBundle φ, φ ∉ S.carrier ∧ Finite (FilteredWorld φ)`
- `fmp_contrapositive` (`:280`), `fmp_size_bound` (`:310`) adding
  `Nat.card (FilteredWorld φ) ≤ 2 ^ (subformulaClosure φ).card`
- `filteredCharacteristicSet_injective` (`FiniteModel.lean:109`), `filtered_world_bound` (`:212`)

### Why it does not give decidability

This is documented in the directory's own README under the heading *"These theorems are about MCS
membership, not about truth"*, and the audit confirms it mechanically:

- The directory contains **zero occurrences of `TruthAt`**. Every conclusion is a *membership*
  claim (`φ ∉ S.carrier`), never a semantic falsification in a `TaskModel`.
- `refinedFilteredTaskRel` (`Filtration.lean:276`) is `fun w d u => if d = 0 then w = u else True`
  — the **permissive** complete-graph relation. The four `def:frame` axioms discharge precisely
  *because* the relation is universal.
- Consequently a truth lemma `TruthAt M τ t ψ ↔ ψ ∈ (τ.states t _).carrier` is **provably false**
  on this frame (`someFuture χ` separates the sides).

Its README's own budgeting note: *"A semantic finite model property … needs a world space derived
from a given model, a non-permissive relation, and a truth lemma. This directory has none of the
three … Anyone budgeting that work should budget a construction with a different subject, not a
modification of these files."* The transferable content is the **cardinality bound only**.

The three "FMP completeness" theorems in `Correctness.lean:300/316/325` are one-line re-exports
and carry no semantic-validity content.

This qualifies the original proof-state audit's finding F6 ("FMP is syntactic, not semantic"):
F6 was right about `FMP/` but was reached without accounting for BiLasso.

### The live route: BiLasso

`Decidability/BiLasso/` — 19 modules, 6,673 lines, landed sorry-free and wired into the build
graph. It decides truth of a formula at a state of a **given** `IntPresentation` by bounded
enumeration of annotated bi-lassos: `check_correct` (`BiLasso/Check.lean:195`) and a computing
`Decidable` instance (`:217`).

Honest scope: it does not decide the logic — nothing in the layer quantifies over frames — and it
performs no part of the finite-model step (`exists_annot_of_truth` takes a `WorldHistory` as
*input*). Its axioms are `[propext, Classical.choice, Quot.sound]`; that is computability, not
choice-freedom, and `wlem_of_spherical` rules out any choice-free finite-carrier route.

`BiLasso/Assembly.lean` closes to decidability of `ValidDiscrete` **under one hypothesis**:

```
validDiscrete_iff_check (canon)
  (fmp : ∀ ψ, ¬ValidDiscrete ψ → ∃ w, SatAtState (canon ψ) w ψ.neg) …
```

Given `fmp`, the assembly (`validDiscrete_iff_checkFamily:88`, `decidableValidDiscreteFamily:105`)
is already live and machine-checked. The soundness direction
(`not_validDiscrete_of_satAtState:60`) is proven hypothesis-free.

**`fmp` is the single open theorem between this layer and decidability of `ValidDiscrete`.** Its
crux is box-faithfulness — `box` truth is a global constant of its own model, so a source model's
and a target presentation's box facts need not agree. The existing `FMP/` subtree cannot supply it:
wrong shape (MCS membership vs. `SatAtState` on an `IntPresentation`).

**Tracked as task 476** (`box_faithful_small_model_theorem`, `not_started`, deps `[475]` =
completed, so it is unblocked). Classified in its own description as OPEN MATHEMATICS, MULTI-MONTH,
with an explicit literature gate (Gabbay–Kurucz–Wolter–Zakharyaschev) and a
must-not-merge-into-engineering clause.

---

## Front 4 — Tableau system: **soundness proven, completeness open, and most of the investment is in termination**

`Decidability/` is 62 files and **52,134 lines** — 23% of `Metalogic/`. But **61% of it (32,015
lines) is `Verified/`**, and **46% of the whole subtree (24,140 lines) is three
`Verified/Termination/` files** (`MintBound.lean` alone is 14,770). The bulk of the investment is
fuel and termination bookkeeping, not the open correctness biconditional.

### Soundness — PROVEN

- `sound_of_isValid` (`Correctness.lean:100`) and `isValid_sound` (`:111`):
  `isValid φ fc = true → ⊨ φ`, sorry-free, with `isTautology` / `isContradiction` /
  `isSatisfiable` siblings (`:124`, `:131`, `:142`) and frame-class-relativized forms
  (`:150/157/164`). Landed by task 480.
- Important caveat: this direction rides **entirely** on the `⊢ φ` derivation carried in
  `DecisionResult.valid` (`decide_sound'`, `:71`) and uses **nothing from the tableau side**. The
  tableau contributes the derivation; the proof system contributes the soundness.
- The tableau-side half that does exist: `ruleSound_of_mem_allRulesForFC`
  (`Verified/Decidable.lean:3155`), assembled from 34 `ruleSound_*` theorems, all sorry-free —
  every rule `allRulesForFC` can schedule at a frame class preserves satisfiability under that
  class's carrier property.
- Task 418 removed the one known unsoundness (a cross-world temporal-copy in
  `boxNeg`/`diamondPos`).

### Completeness — OPEN, and stated as such in-source

`Correctness.lean:185–233` carries a section *"`validity_decidable` /
`validity_has_decision_procedure` — Retired as vacuous"*: two theorems were **deleted** because
their proofs were `Classical.em` wrappers whose names claimed a decidability result the proofs did
not deliver. What is owed:

> `⊨ φ → isValid φ fc = true` — and hence the biconditional `isValid φ fc = true ↔ ⊨ φ` and the
> `Decidable (⊨ φ)` instances for the four frame classes — requires `valid_iff_allClosed`, which
> needs the fuel/termination side and the truth-lemma gate on top of the rule half, and it must
> also account for the two rules scheduled outside `allRulesForFC` (`serialityRule` and
> `timeLinearity`, stages 2 and 3 of `expandOnce`).

**There is no theorem named `valid_iff_allClosed` anywhere in the tree** — it exists only as a
named obligation in prose. This is the correct discipline (no `isValid`-shaped `iff` is written
before it can be proved), but it means the headline decidability result does not exist.

### Structural blockers on this front

Four of these are settled negative results, not unproven conjectures, and must not be re-attempted:

1. **Unconditional `buildTableau_isSome` is FALSE by construction.** `buildTableau` returns `none`
   whenever a formula explores more than `maxBranches := 50000` branches, *at any fuel*. This is a
   property of the engine signature. Task 428 targets a budget-parameterised replacement via the
   amortized mint-bound route, with an explicit ASSESS/C9-register escape clause for the split-arm
   fuel scaling problem (`allocateFuelProportionally`, whose depth is not bounded by anything
   proved).
2. **The decidable-branch-gate family is REFUTED** — `boxAnchoredCheck`, `boxGridCheck`,
   `regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk` all collapse to `false` on any branch that
   mints a world, because task 418's *sound* fix removed the only route by which `T(Gφ)`/`T(Hφ)`
   reach a freshly minted world. **Task 429 is a redesign, not a repair.** Repair option (c)
   (weaken only the anchor) is closed as formulated. Recommended route: propagate `T(□φ)` itself to
   the fresh world (S5 axiom-4/5 pattern), which carries its own `RuleSound` obligation and named
   fuel/termination consequences.
3. **Five termination residuals, not four.** `UniverseClosed` (task 432 ✓), `DifficultyBounded`/
   `StepLengthBounded`, `MintPaysForTime` (task 434 ✓, engine-level assembly task 462 ✓),
   `PostBlockingSettles` (task 433, partial), and **`UnorderedSuccessorLabelClosed`** — the fifth,
   carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` and
   **refuted in-tree** at `MintBound.lean:6238`. The four-residual framing used elsewhere in the
   programme is wrong. Task 481 is repair-or-replace, not routine discharge; a C9 register entry is
   a complete, valid outcome.
4. **`Verified/Refutation/` does not exist, `ProofExtraction.lean` has zero theorems, and
   `verifyProof` (`:345`) is the constant stub `fun _ _ => true`** — a total, sorry-free function
   that certifies every input. Eliminating `.extractionFailed` as a live outcome on a genuinely
   closed tableau is open mathematics, multi-month (task 482). `Verified/README.md` lists five
   designed-but-unbuilt paths: `Internalize.lean`, `Refutation/Core.lean`, `Refutation/Rules/*`,
   `Bridge/Omega.lean`, `Provable.lean`.

### Critical path

Re-derived by longest-path over the live dependency graph. Task 462 has **completed** since the
roadmap was written, so the spine has advanced one wave:

```
462 ✓ -> 463 (ROUTINE, unblocked today)
          -> 464 (HARD -- gapPotential, the one genuinely open question on this spine)
            -> 465 (ROUTINE -- mechanical restatement)
              -> 428 (HARD -- split-arm fuel scaling, ASSESS/C9 escape clause)
                -> 429 (HARD -- box-anchor redesign, genuine open mathematics)
                  -> 410 -> 411 -> 430 (HARD -- the semantic lift)
                    -> 412 -> 482 (HARD -- proof-extraction completeness)
                            -> 177 (documentation polish)

483 (researched, startable) -> 481 (HARD -- repair-or-replace) -- parallel entry
476 (HARD -- open mathematics, unblocked) -- parallel, does not feed this spine
```

Roughly **10 waves from 463 to 482**, four of them classified HARD / open mathematics.

---

## What Is Startable Today

| Task | Status | Classification | Note |
|------|--------|----------------|------|
| **489** | not_started | small, well-scoped | BaseLanguage soundness; retires a live paper over-claim |
| **463** | not_started | ROUTINE | unblocked by 462's completion; head of the decidability spine |
| **483** | researched | ROUTINE | Route 1 for the OrdTimesKnown/UniverseClosedAt mismatch; unblocks 481 |
| **476** | not_started | OPEN MATHEMATICS | unblocked (475 ✓); the genuine semantic FMP |
| **433** | partial | in flight | `PostBlockingSettles` narrowing |

Blocked: 428 (on 432/433/434/465), 481 (on 434/483), 461 (literature acquisition), 257 (human
action — HuggingFace token).

## Findings

### Documentation

Task 488's alignment sweep (13 phases, completed 2026-08-26) corrected the defects the
2026-08-25 review found. `README.md` now states the four-class weak/consequence completeness
result correctly, distinguishes strong completeness with its three-way status split, and records
the decidability sound/open/partial split accurately. Two write-time guards were added (C14
widened to Lean docstrings, C15 for paper anchors), and both pass.

**Remaining documentation gap (new finding, low severity):** `README.md` contains **zero**
mentions of FMP, finite model property, or BiLasso. The BiLasso layer is 19 sorry-free modules
and 6,673 lines wired into the build graph, and the FMP/semantic-FMP distinction is one of the
most load-bearing scope facts in the repository. A reader of the front page cannot learn either
exists. This is an under-claim, the opposite of the tree's historical failure mode, but it is
still a mismatch between the front page and the tree.

### Automation coverage (already recorded as open by task 488)

`Automation/Tactics/Helpers.lean`'s `axiomCtors` and `Automation/ProofSearch/Core.lean`'s
`matchAxiom` each cover exactly 42 of the tree's 45 axiom constructors, omitting the three Layer-9
Reynolds Dedekind constructors `prior_U_gap`, `prior_S_gap`, `sep`;
`Decidability/ProofExtraction.lean` inherits the gap by delegation. Task 488 corrected the
docstrings to state coverage honestly rather than replacing a stale number with a false one.
Closing the gap is a code change and remains open: a Dedekind-class goal needing one of those
three axioms will not be closed by `tryAxiomMatch`.

### Correction to a prior framing

An earlier draft of this review's soundness audit reported sorries in `BXCanonical/`,
`WeakCanonical/`, `StrongCompleteness.lean` and `Decidability.lean`. That was a `grep` artifact
matching the string "sorry-free" inside docstrings. Independently verified: **zero** structural
sorries outside `Boneyard/`, consistent with C3.

## Recommendations

1. **Take task 489 first.** It is the only item on any front that is both small and closes a
   published-claim gap. The composition `Conservativity.translate ∘ soundness` is the stated route.
2. **Scope the compactness work.** `CompactBase` / `CompactDense` are the entire remaining
   completeness obligation, the ultraproduct route is authorized (task 424 ✓), and no tasks exist
   for it. This is the largest untracked item in the programme.
3. **Record the Dedekind strong-completeness obligation by name**, the way Base and Dense are, so
   its absence reads as deliberate rather than overlooked.
4. **Do not let 476 be merged into engineering.** Its own description anticipates exactly that
   failure. The two-day literature check it names (Gabbay–Kurucz–Wolter–Zakharyaschev) should
   happen before any implementation budget is committed.
5. **Add FMP/BiLasso to `README.md`**, with the semantic-vs-syntactic FMP distinction stated
   plainly. The accurate prose already exists in-tree at `Decidability.lean:118-160` and
   `FMP/README.md`.
