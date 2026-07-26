# Automation and Tactic Opportunity Survey

**Task**: 196 — Codebase-wide tactic opportunity survey and survivor re-scoping
**Survey date**: 2026-07-26 (measurements taken 22:13 UTC)
**Tree measured**: `git rev-parse --short HEAD` = `e70535a2a`, working tree with three
concurrent agent sessions active (see "Measurement Volatility" below)
**Type**: survey — no `.lean` file was modified at any point during this work

> **`reports/01_team-research.md` and the four `01_teammate-*-findings.md` files are HISTORICAL.**
> They were written 2026-05-22 against a tree of 149 files / 92K lines. That tree no longer
> exists. Every factual claim in those reports has been treated here as a *hypothesis to
> re-test*, not as a fact. Where a re-measurement contradicts them, the number in this report
> wins. Section 3 lists the conclusions that re-measurement invalidates.

---

## 1. Measured Baseline

All commands were run from the repository root. `Boneyard/` is excluded everywhere; it is dead
code (154 `.lean` files) that is not on any critical path.

### 1.1 Tree size

| Metric | Value | Command |
|--------|-------|---------|
| Live `.lean` files (excl. `Boneyard/`) | **278** | `find Theories -name '*.lean' -not -path '*/Boneyard/*' \| wc -l` |
| Live total lines | **185,531** | `find Theories -name '*.lean' -not -path '*/Boneyard/*' -print0 \| xargs -0 cat \| wc -l` |
| Boneyard `.lean` files | 154 | `find Theories -name '*.lean' -path '*/Boneyard/*' \| wc -l` |

The May 2026 report surveyed 149 files / 92K lines. The live tree is now **1.87x the file count
and 2.02x the line count** of what that report saw.

### 1.2 Per-directory breakdown

Command (run once per directory):

```bash
for d in Theories/Bimodal/*/; do
  n=$(find "$d" -name '*.lean' -not -path '*/Boneyard/*' | wc -l)
  l=$(find "$d" -name '*.lean' -not -path '*/Boneyard/*' -print0 | xargs -0 cat | wc -l)
  echo -e "$d\t$n files\t$l lines"
done
```

| Directory | Files | Lines | Share of tree |
|-----------|-------|-------|---------------|
| `Theories/Bimodal/Metalogic/` | 198 | 148,522 | 80.1% |
| `Theories/Bimodal/Automation/` | 35 | 21,576 | 11.6% |
| `Theories/Bimodal/Theorems/` | 13 | 7,017 | 3.8% |
| `Theories/Bimodal/Syntax/` | 8 | 3,404 | 1.8% |
| `Theories/Bimodal/Semantics/` | 5 | 1,856 | 1.0% |
| `Theories/Bimodal/ProofSystem/` | 4 | 1,142 | 0.6% |
| `Theories/Bimodal/FrameConditions/` | 4 | 816 | 0.4% |
| `Theories/Bimodal/Examples/` | 2 | 533 | 0.3% |
| `Theories/Bimodal/Boneyard/` | 0 | 0 | — |

`Metalogic/` is now four-fifths of the codebase. `Theorems/` — the layer tasks 186/192/193 were
scoped against — is 3.8%.

### 1.3 `Automation/` internal breakdown

```bash
find Theories/Bimodal/Automation/Tactics -name '*.lean' -print0 | xargs -0 cat | wc -l   # 2178
find Theories/Bimodal/Automation/ProofSearch -name '*.lean' -print0 | xargs -0 cat | wc -l # 1639
wc -l Theories/Bimodal/Automation/{EFGameTactics,Normalization,LemmaDB,AesopRules}.lean
find Theories/Bimodal/Automation -name '*.lean' \
  \( -name '*Dataset*' -o -name '*Export*' -o -name '*Benchmark*' -o -name '*Exporter*' \
     -o -name '*Trace*' -o -name '*Enum*' -o -name '*Mutator*' -o -name '*Metrics*' \
     -o -name '*Generator*' -o -name '*Validator*' -o -name '*Oracle*' -o -name '*Anchors*' \) \
  -print0 | xargs -0 cat | wc -l   # 13093
```

| Component | Lines | Purpose |
|-----------|-------|---------|
| Dataset / export / benchmark machinery | 13,093 | ML dataset generation, trace export, benchmarking — **not proof automation** |
| `Tactics/` (4 files) | 2,178 | `modal_search`, `temporal_search`, `propositional_search`, `tm_auto`, `deduction`, `prop_decide` |
| `ProofSearch/` (2 files) | 1,639 | search core + strategies |
| `Normalization.lean` | 1,335 | `modal_norm` family |
| `EFGameTactics.lean` | 331 | `simp_game_tuple`, `order_refl`, `same_order_type_grid`, … |
| `AesopRules.lean` | 284 | aesop rule set |
| `LemmaDB.lean` | 47 | lemma database |

**61% of `Automation/` is not proof automation at all** — it is dataset/export/benchmark
tooling. The actual proof-automation surface is ~5,800 lines (`Tactics/` + `ProofSearch/` +
`Normalization` + `EFGameTactics` + `AesopRules` + `LemmaDB`), not the 21,576 the directory
total suggests. This distinction did not exist in May and materially changes how "3,500 lines of
unused automation" should be read.

### 1.4 Measurement volatility

Three agent sessions were writing to this repository during the survey. One is actively
rewriting `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(**13,405 lines** as of 2026-07-26 22:13 UTC — a moving target). No recommendation in this
report depends on that file's line count. Pattern counts below may drift by a few units against
a later measurement; the *ratios* and *rankings* are robust, and no conclusion here turns on a
difference of fewer than ~20 occurrences.

---

## 2. Stale-Reference Audit

Every `.lean` path named in `reports/01_team-research.md` or the four teammate reports was
resolved against the live tree. Method: `test -f "Theories/Bimodal/$p"`; on failure, test for a
directory of the same stem; on failure, `find Theories -name "$(basename $p)"` including
`Boneyard/`.

### 2.1 Split into directories (6 of the report's named monoliths)

| Cited path | Current location | Now |
|------------|------------------|-----|
| `Metalogic/SoundnessLemmas.lean` | `Theories/Bimodal/Metalogic/SoundnessLemmas/` | 3 files, 2,461 lines |
| `Metalogic/WeakCanonical/EFGames.lean` | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` | 8 files, 11,872 lines |
| `Automation/Tactics.lean` | `Theories/Bimodal/Automation/Tactics/` | 4 files, 2,178 lines |
| `Automation/ProofSearch.lean` | `Theories/Bimodal/Automation/ProofSearch/` | 2 files, 1,639 lines |
| `Syntax/SubformulaClosure.lean` | `Theories/Bimodal/Syntax/SubformulaClosure/` | 3 files, 1,934 lines |
| `Theorems/Propositional.lean` | `Theories/Bimodal/Theorems/Propositional/` | 3 files, 1,622 lines |

### 2.2 Moved to `Boneyard/` — dead code (the report's Tier 2/3 targets)

| Cited path | Current location |
|------------|------------------|
| `Separation/Hierarchy.lean` | `Metalogic/WeakCanonical/Kamp/Boneyard/Separation/Hierarchy/` |
| `Separation/DedekindZ.lean` | `Metalogic/WeakCanonical/Kamp/Boneyard/Separation/DedekindZ/` |
| `Separation/Duality.lean` | `Metalogic/WeakCanonical/Kamp/Boneyard/Separation/Duality.lean` |
| `Separation/TemporalClosure.lean` | `Metalogic/WeakCanonical/Kamp/Boneyard/Separation/TemporalClosure.lean` |
| `WeakCanonical/ExpressiveCompleteness.lean` | `Metalogic/WeakCanonical/Kamp/Boneyard/ExpressiveCompleteness/` |

### 2.3 Removed entirely

| Cited path | Status |
|------------|--------|
| `WeakCanonical/ExpressivenessGeneral.lean` | **Does not exist anywhere**, including `Boneyard/`. Verified: `find Theories -name 'ExpressivenessGeneral.lean'` returns nothing. |

### 2.4 Survive at a corrected path (report used a truncated prefix)

All of the following exist and were verified with `test -f`; the reports simply cited them
relative to `Metalogic/` rather than `Theories/Bimodal/`.

| Path (verified to exist) | Lines |
|--------------------------|-------|
| `Theories/Bimodal/Metalogic/Soundness.lean` | 1,394 |
| `Theories/Bimodal/Metalogic/Completeness.lean` | 534 |
| `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` | — |
| `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` | — |
| `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` | — |
| `Theories/Bimodal/Metalogic/Core/RestrictedMCS/` (dir) | — |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` | — |
| `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` | 1,071 |
| `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` | 553 |
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | 943 |
| `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` | — |
| `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` | — |
| `Theories/Bimodal/Metalogic/BXCanonical/{Completeness,Frame}.lean` | — |
| `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/{ChronicleConstruction,ChronicleToCountermodel,CounterexampleElimination,PointInsertion,RRelation}.lean` | — |
| `Theories/Bimodal/Semantics/{Truth,Validity}.lean` | 695 / 324 |
| `Theories/Bimodal/FrameConditions/Validity.lean` | 210 |
| `Theories/Bimodal/Syntax/Subformulas.lean` | 235 |
| `Theories/Bimodal/Theorems/{Combinators,ModalS4,ModalS5,TemporalDerived}.lean` | 669 / 420 / 777 / 800 |
| `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` | 936 |
| `Theories/Bimodal/Automation/EFGameTactics.lean` | 331 |

**Audit total**: of the 42 distinct `.lean` paths cited across the five research artifacts, 6
have been split into directories, 5 have been moved to `Boneyard/`, 1 has been deleted outright,
and 30 survive (23 of those only under a corrected path prefix).

---

## 3. Superseded Conclusions

Headline greps were re-run against the live tree. Method (`Boneyard/` excluded throughout):

```bash
grep -rn --include='*.lean' -e '<PATTERN>' Theories | grep -v '/Boneyard/' | wc -l
```

| Pattern | May 2026 | 2026-07-26 | Delta |
|---------|----------|------------|-------|
| `theorem_in_mcs` | 313 | **321** | +8 |
| `intro F M Omega` | 224 | **153** | −71 |
| `simp only [truth_at` | 168 | **173** | +5 |
| `DerivationTree.modus_ponens` | 451 | **444** | −7 |
| `imp_trans` | 180 | **209** | +29 |
| `deduction_theorem` | 143 | **153** | +10 |
| `modal_search` | 3 | **125** | +122 |
| `tauto` (word) | 0 | **15** (14 as a leading tactic) | +15 |
| `by_contra` | 545 | **686** | +141 |
| `by_cases` | 454 | **713** | +259 |
| executable `sorry` (`^\s*sorry\s*$`) | ~41 | **1** | −40 |

The single remaining executable sorry:

```
Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1242:  sorry
```

### 3.1 Conclusions the measurements invalidate

**S1. "Sorry triage: of ~41 executable sorries…" and "the critical path runs through completing
task 155's Phase 1, then Phases 3-6" — INVALIDATED.**
Invalidating number: **executable sorries = 1**. The entire sorry-reduction framing that drove
the report's Tier 3 ("EF Game Automation — critical path, sorry-reducing") priority is gone. Any
ranking formula that weights by `frequency × sorry_impact` now degenerates: sorry_impact is zero
for every pattern group except whatever touches `Transfer.lean:1242`.

**S2. "Complete task 195 Component A — the single highest-ROI action" — INVALIDATED.**
Invalidating fact: its stated targets, "the 2 BLOCKED sorries in ExpressivenessGeneral.lean at
lines ~3199/3404", cannot exist — `ExpressivenessGeneral.lean` has been deleted from the tree
(section 2.3), and there is exactly one executable sorry left in the codebase, in a different
file. This recommendation is unexecutable as written.

**S3. "modal_search has 3 uses, all in Examples/" — SUPERSEDED BUT NOT REVERSED.**
Invalidating number: 125 occurrences. But see section 5.1: **116 of the 125 are inside
`Automation/` itself**, 6 are in `Examples/`, 2 are re-exports in `Bimodal.lean`, and the single
occurrence in `Theorems/Combinators.lean:92` is a *comment explaining that `modal_search` cannot
prove the goal*. Genuine proof-site adoption outside `Examples/` is **zero**. The non-adoption
finding is not merely intact — it is stronger, because the automation subtree grew 6x while
proof-site adoption stayed at zero.

**S4. "Separation Simp Sets (Task B)" and "Formula Induction Automation (Task C), apply to
Hierarchy.lean (38 inductions), TemporalClosure.lean (22)" — INVALIDATED.**
Invalidating fact: `Hierarchy.lean`, `TemporalClosure.lean`, `Duality.lean`, `DedekindZ.lean`
and `ExpressiveCompleteness.lean` are all in `Boneyard/` (section 2.2). The report's estimated
"~1,500-2,000 lines saved" for formula-induction automation was concentrated in files that are
now dead code. Both proposals target the boneyard.

**S5. "`intros_validity` — the single highest-frequency verbatim repetition, 224+ occurrences
across 4 files (SoundnessLemmas.lean: 132, Soundness.lean: 39, Validity.lean: 53)" —
PARTIALLY SUPERSEDED.**
Invalidating number: 153, not 224+. The distribution also changed completely: it is now
`SoundnessLemmas/DenseValidity.lean` (92) and `SoundnessLemmas/FrameClassVariants.lean` (56),
with only 5 occurrences outside `SoundnessLemmas/`. `Soundness.lean` and `Semantics/Validity.lean`
have **zero**. The opportunity is real but is now a two-file opportunity, not a four-file one.

**S6. "Tasks 185-192 target `Theorems/` (6,450 lines, 8% of codebase)" — SUPERSEDED.**
Invalidating number: `Theorems/` is 7,017 lines and **3.8%** of the tree, not 8%. The
"wrong layer" argument is therefore *stronger* than the report stated: the targeted layer has
halved in relative size while `Metalogic/` grew to 80.1%.

**S7. "The 3,500 lines of `Automation/Tactics.lean` + `ProofSearch.lean`" — SUPERSEDED.**
Invalidating numbers: `Tactics/` = 2,178 and `ProofSearch/` = 1,639 (3,817 combined), but the
`Automation/` directory as a whole is 21,576 lines of which 13,093 is dataset/export/benchmark
tooling unrelated to proof automation (section 1.3). Any statement of the form "we have 21K
lines of unused tactics" is wrong; the correct figure for proof-automation surface is ~5,800.

**S8. "545 `by_contra` + 454 `by_cases` with zero `tauto` uses" — SUPERSEDED.**
Invalidating numbers: 686 `by_contra`, 713 `by_cases`, and `tauto` is now used 14 times as a
leading tactic. The audit opportunity still exists and has grown, but the "zero `tauto`" framing
is no longer true.

**S9. "Task 195 is marked [COMPLETED] but Component A was deferred" / "Dependency chain errors
in tasks 185-193" / the "Existing Tasks: Keep/Modify/Defer" table — SUPERSEDED WHOLESALE.**
Tasks 185, 187, 189, 190, 191, 194 and 195 have all completed and been archived. Only 186, 192,
193 remain open from that chain, plus 199 in `[partial]`. The table reasons about seven tasks
that no longer exist as open work.

### 3.2 Conclusions that survive re-measurement

- **The non-adoption problem is real and has worsened** (S3, section 5).
- **The wrong layer is being targeted** (S6) — and by a wider margin than stated.
- **`theorem_in_mcs` / MCS axiom application is a genuine, high-frequency, still-live pattern**
  (321 occurrences, concentrated in `BXCanonical/Chronicle/`).
- **`simp only [truth_at` bundling is real and live** (173 occurrences).
- **`imp_trans` chains grew** (180 → 209) and are still concentrated in `Theorems/` plus
  `BXCanonical/Chronicle/PointInsertion.lean`.

### 3.3 Staleness horizon of *this* report

This report will go stale along two axes.

- **Names**: every declaration name cited here (`theorem_in_mcs`, `imp_trans`,
  `deduction_theorem`, `modal_search`, …) is reported as it exists on 2026-07-26. The systematic
  Mathlib naming upgrade will rename many of them. **Occurrence counts survive a rename; the
  literal grep strings do not.** Anything in this report expressed as a grep string must be
  re-derived after that upgrade lands.
- **Paths**: the tree is being actively split into directories (six of the May report's named
  files were split in ~two months). Path-level claims in sections 1.2, 2 and 4 have a
  half-life measured in weeks. Ratio-level and ranking-level claims are durable.

*Sections 1-3 written in Phase 1.*

---

## 4. Ranked Automation Inventory

### 4.1 Ranking formula (stated before it is applied)

```
Score = (R × D) × C × A / X
```

| Term | Meaning | Values |
|------|---------|--------|
| **R** | Measured occurrence count, live tree, `Boneyard/` excluded | integer from grep |
| **D** | Estimated lines removed *per occurrence* | 0.05 – 2 |
| **C** | Concentration | 1.0 if ≥80% of occurrences sit in ≤3 files; 0.7 if in ≤10 files; 0.4 otherwise |
| **A** | Adoption factor | 1.0 = mechanical rewrite of existing proof text that lands once and stays landed; **0.3** = savings require proof authors to change habits going forward |
| **X** | Complexity divisor | 1 = syntactic macro; 2 = simp set or shallow elab; 4 = nontrivial metaprogramming (goal inspection, backtracking search) |

**Sorry-impact is deliberately absent from this formula.** The May report weighted opportunities
by `frequency × sorry_impact`. With **exactly one executable sorry left in the tree**
(`Metalogic/WeakCanonical/Transfer.lean:1242`, section 3), that multiplier is zero for every
group and would collapse the entire ranking to zero. Sorry reduction is no longer a reason to
build a tactic in this codebase. Anyone re-deriving this ranking after new sorries appear should
reinstate the term; today it carries no signal.

**The `A` term is the correction the May report lacked.** It is forced in by the measured
evidence in section 5: the DerivationTree search family is fully built, is covered by tests, and
is invoked at exactly **three** real proof sites after eight months of availability. Any group
whose savings depend on future authors choosing to invoke a tactic is discounted to `A = 0.3`;
any group realizable by a one-time mechanical pass over existing text keeps `A = 1.0`.

### 4.2 Ranked table (top 10, hard cap)

| # | Group | R | D | C | A | X | Score | Concentration | Naming-upgrade |
|---|-------|---|---|---|---|---|-------|---------------|----------------|
| 1 | **MCS axiom application** — `mcs_mp` elab wrapping `DerivationTree.axiom` → `theorem_in_mcs` → `implication_property` | 321 | 2 | 0.7 | 1.0 | 2 | **225** | `BXCanonical/` 240/321; `Chronicle/PointInsertion.lean` 63, `Chronicle/RRelation.lean` 45, `WeakCanonical/ReflexiveCanonical.lean` 31 | **SENSITIVE** |
| 2 | **Validity intro macro** — `intros_validity` for `intro F M Omega _h_sc τ _h_mem t` | 153 | 1 | 1.0 | 1.0 | 1 | **153** | `SoundnessLemmas/DenseValidity.lean` 92, `SoundnessLemmas/FrameClassVariants.lean` 56 (148/153 in 2 files) | **SENSITIVE** |
| 3 | **Truth simp bundle** — `simp_truth` family for `simp only [truth_at, …]` | 173 | 0.6 | 0.7 | 1.0 | 1 | **72.7** | `SoundnessLemmas/DenseValidity.lean` 54, `Metalogic/Soundness.lean` 47, `SoundnessLemmas/FrameClassVariants.lean` 30 | **SENSITIVE** |
| 4 | **EF-game tactic application pass** — apply the *already-working* `simp_game_tuple` / `order_refl` family to the five `game_tuple` files that do not yet use it | 322 | 0.5 | 0.7 | 1.0 | 2 | **56.4** | `EFGames/CustomGame.lean` 100, `EFGames/Composition.lean` 87, `Expressiveness/SplitPoint.lean` 61, `Expressiveness/DConsistencyTransport.lean` 47, `EFGames/Decomposition.lean` 15, `Expressiveness/Claim1.lean` 12 | **SENSITIVE** |
| 5 | **`tauto` / `by_contra` audit** — replace hand-rolled classical reasoning where `tauto` closes the goal | 1,399 | 0.05 | 0.4 | 1.0 | 1 | **28.0** | 686 `by_contra` + 713 `by_cases`, diffuse across the whole tree | **SENSITIVE** |
| 6 | **Subformulas simp set** — `simp_subformulas` for `simp only [subformulas, List.mem_cons, …]` | 41 | 0.5 | 1.0 | 1.0 | 1 | **20.5** | 2 files | **SENSITIVE** |
| 7 | **`modus_ponens` assembly via search** — replace manual `DerivationTree.modus_ponens` chains with a working search tactic | 444 | 1.5 | 0.4 | **0.3** | 4 | **20.0** | `Chronicle/PointInsertion.lean` 64, then ~28 each across `Theorems/Propositional/{Core,Connectives}.lean`, `Theorems/Combinators.lean` — diffuse | **SENSITIVE** |
| 8 | **`deduction_theorem` boilerplate** — the `deduction` tactic already exists in `Automation/Tactics/Deduction.lean` | 153 | 1 | 0.4 | **0.3** | 2 | **9.2** | `Chronicle/PointInsertion.lean` 20, `Theorems/Propositional/Reasoning.lean` 16, then a long tail | **SENSITIVE** |
| 9 | **`imp_trans` chains** — backward-chaining closure of combinator chains | 209 | 1 | 0.4 | **0.3** | 4 | **6.3** | split almost exactly in half: `Theorems/` 102, `Metalogic/` 103; `Chronicle/PointInsertion.lean` 67 alone | **SENSITIVE** |
| 10 | **`push_neg` migration** — replace `simp only [not_and, Classical.not_not]` | 20 | 0.2 | 1.0 | 1.0 | 1 | **4.0** | 1 file cluster | **SENSITIVE** |

### 4.3 Naming-upgrade sensitivity: all ten groups are sensitive

Every ranked group is marked SENSITIVE, and that uniformity is itself a finding rather than an
oversight. Realizing *any* of these groups means a mass edit of proof text across dozens to
hundreds of sites. A mass proof rewrite must not race a mass rename: if the systematic Mathlib
naming upgrade lands mid-pass, half the rewritten sites reference old names and half reference
new ones, and the resulting merge is worse than either change alone.

**Every task spawned from this inventory that rewrites proof bodies must declare a dependency on
task 402 (systematic Mathlib naming upgrade).** The reason is recorded inline in each charter in
section 7 so it survives copy-paste.

The only naming-upgrade-*independent* work available here is **defining a tactic without
applying it** — which is precisely the activity that produced the current zero-adoption state
(section 5). Defining more tactics ahead of 402 is available, cheap, and worthless.

### 4.4 Inter-group dependency relationships

| Constraint | Reason |
|------------|--------|
| **1 before 7** | 305 `implication_property` and a large share of the 498 `DerivationTree.axiom` sites lie *inside* the MCS triple that group 1 collapses. Running group 7 first would rewrite the same lines twice, and the second pass would be rewriting text the first pass invented. |
| **3 before/with 2** | Groups 2 and 3 land on the same two files (`SoundnessLemmas/DenseValidity.lean`, `SoundnessLemmas/FrameClassVariants.lean`). Doing them as separate passes edits those files twice and forfeits the combined `unfold_validity` collapse. Land them as one pass. |
| **4 depends on nothing** | Group 4 requires **no new tactic**. `simp_game_tuple` and `order_refl` already exist, already work, and already have 38 live invocations. It is a pure application pass. |
| **7, 8, 9 are gated on an adoption fix, not on engine work** | All three depend on the DerivationTree search engine being ergonomic enough that authors reach for it. Section 5 shows it is not, and that ~5,800 lines of engine already exist. More engine work does not unblock them. |
| **5 last** | The `tauto` audit is a diffuse sweep; running it before the concentrated groups means re-touching sites that groups 1-4 are about to rewrite anyway. |

### 4.5 Considered and not ranked

- **Formula structural induction (`formula_induct_simp`)** — the May report's largest single
  estimate (~1,500-2,000 lines). Its named targets `Hierarchy.lean` (38 inductions) and
  `TemporalClosure.lean` (22) are both in `Boneyard/` (section 2.2). The opportunity targets
  dead code.
- **Separation simp sets (`@[separation_norm]`)** — same reason: `Hierarchy.lean`,
  `TemporalClosure.lean`, `Duality.lean`, `DedekindZ.lean` and `ExpressiveCompleteness.lean` are
  all in `Boneyard/`.
- **`same_order_type_grid` validation** — the May report's "single highest-ROI action". Its
  target file `ExpressivenessGeneral.lean` has been deleted from the tree entirely (section 2.3),
  and the tactic has **zero** invocations anywhere in `Theories/`. Unexecutable as specified.
- **`pivot_order` context-search elab tactic** — 63 cited call sites were all in
  `ExpressivenessGeneral.lean`, which no longer exists.
- **Stavi formula induction** — carried forward from teammate A as unassessed in May; still
  unassessed, and no other measurement surfaced it as high-frequency in the live tree.
- **Culling `Automation/`'s 13,093 lines of dataset/export/benchmark tooling** — considered and
  **rejected on evidence**. It looked like dead weight, but it is live: it is imported by
  `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` and exercised by six test files
  under `Tests/BimodalTest/Automation/`. It is not proof automation, but it is not dead. Do not
  propose culling it.
- **`Automation/Normalization.lean` (1,335 lines, `modal_norm` family)** — zero invocations
  anywhere in `Theories/` *and* zero in `Tests/`. This is genuinely unexercised, but it is a
  cleanup question, not a tactic opportunity; it is handled in section 6 as part of the survivor
  decisions rather than ranked here.

*Section 4 written in Phase 2.*

---

## 5. Adoption Evidence and Bespoke-Tactic Cost

### 5.1 What the `modal_search` 3 → 125 growth actually is

The May report's most-quoted number was "`modal_search` has 3 uses". It is now 125. That growth
is **entirely growth of the automation subtree itself**, not adoption.

Breakdown by location (`grep -rn 'modal_search' Theories | grep -v '/Boneyard/'`, then bucketed by
file):

| Location | Count | What it is |
|----------|-------|------------|
| `Automation/Tactics/Commands.lean` | 96 | the tactic's own implementation |
| `Automation.lean` | 8 | aggregator module docstring + code-block examples |
| `Automation/Tactics/Helpers.lean` | 6 | internal helpers |
| `Examples/BimodalProofs.lean` | 6 | 3 real invocations + 3 prose mentions |
| `Automation/AesopRules.lean` | 3 | aesop rule set |
| `Bimodal.lean` | 2 | top-level aggregator docstring |
| `Automation/LemmaDB.lean` | 2 | internal |
| `Theorems/Combinators.lean` | **1** | **a comment saying `modal_search` *cannot* prove the goal** |
| `Automation/Tactics/PropDecide.lean` | 1 | internal |

The `Theorems/Combinators.lean:92` occurrence reads, verbatim:

```
-- does not determine. The greedy, backtrack-free `modal_search` cannot pick
```

**This is the codebase's only mention of `modal_search` in a real proof file, and it is an
explanation of why the tactic was not used.**

Isolating genuine tactic invocations — lines whose leading token (after whitespace, `·`, or
`<;>`) is the tactic name — outside `Automation/` and `Boneyard/`:

```bash
grep -rn --include='*.lean' -E "^[[:space:]]*(·[[:space:]]*|<;>[[:space:]]*)?(modal_search|temporal_search|propositional_search)([[:space:]]|$)" \
  Theories --exclude-dir=Boneyard --exclude-dir=Automation
```

returns 9 lines, of which 6 are inside docstring code blocks in `Automation.lean` and
`Bimodal.lean` (aggregator module documentation, not proofs). **Real proof-site invocations: 3,
all in `Theories/Bimodal/Examples/BimodalProofs.lean` (lines 219, 223, 231).**

Answer to the plan's question: **the growth represents growth of the automation subtree itself.
Genuine proof-site adoption is unchanged at 3, and all 3 are still in `Examples/`.**

### 5.2 Per-tactic adoption census

Every tactic declared via `syntax`/`macro`/`elab` under `Automation/`, counted as a *leading
tactic token* in each layer. "Real proof sites" = `Metalogic/` + `Theorems/` + `Semantics/` +
`ProofSystem/` + `Syntax/` + `FrameConditions/`, i.e. excluding `Automation/`, `Examples/`,
`Tests/` and `Boneyard/`.

| Tactic | Defined in | Real proof sites | `Examples/` | `Tests/` |
|--------|-----------|------------------|-------------|----------|
| `modal_search` | `Tactics/Commands.lean` | **0** | 3 | 22 |
| `temporal_search` | `Tactics/Commands.lean` | **0** | 0 | 9 |
| `propositional_search` | `Tactics/Commands.lean` | **0** | 0 | 10 |
| `tm_auto` | `Tactics/Commands.lean` | **0** | 0 | 22 |
| `prop_decide` | `Tactics/PropDecide.lean` | **0** | 0 | 2 |
| `deduction` / `undischarge` | `Tactics/Deduction.lean` | **0** | 0 | 9 |
| `modal_norm`, `prop_norm`, `modal_op_norm`, `temporal_norm`, `modal_norm_at`, `modal_norm_all`, `modal_fold` | `Normalization.lean` (1,335 lines) | **0** | 0 | **0** |
| `apply_axiom`, `modal_t`, `assumption_search`, `modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic` | `Tactics/Helpers.lean` | **0** | 0 | 0 |
| `same_order_type_grid`, `same_order_type_grid_uh` | `EFGameTactics.lean` | **0** | 0 | 0 |
| `game_tuple_unfold`, `order_rev`, `extract_order` | `EFGameTactics.lean` | **0** | 0 | 0 |
| **`simp_game_tuple`** | `EFGameTactics.lean` | **35** | 0 | 0 |
| **`order_refl`** | `EFGameTactics.lean` | **3** | 0 | 0 |

Total real proof-site invocations of the entire ~5,800-line proof-automation surface: **38**.
All 38 are in a single file, `Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`, and all
38 come from the EF-game family.

Note on prose false positives: naive greps for `deduction` and `modal_t` return 74 and 29 hits in
`Metalogic/`, but every one is prose in a comment ("By deduction theorem on φ…") or an axiom name
in a docstring. Restricting to leading-tactic position yields **zero**. This distinction matters:
the May-era claim that `deduction_theorem` boilerplate is "addressed by task 189" is true only in
the sense that the tactic exists.

### 5.3 The `Automation/` subtree is *tested*, and still unused

`Tests/BimodalTest/Automation/` contains 13 test files exercising `modal_search` (22 invocations),
`tm_auto` (22), `propositional_search` (10), `assumption_search` (10), `temporal_search` (9),
`deduction` (9), `prop_decide` (2). The May report's gap #4 — "the existing Tactics.lean and
ProofSearch.lean have no test files… building more automation on untested infrastructure carries
risk" — **has been closed.** The tactics are tested. They are still not used.

This removes "it isn't trustworthy" from the list of candidate explanations for non-adoption.

`Automation/Normalization.lean` (1,335 lines, 7 tactics) is the one component with **zero
invocations in `Theories/` and zero in `Tests/`**. It is entirely unexercised.

### 5.4 Diagnosing non-adoption: four candidate causes, tested

The May report asked why the automation is unused and offered four hypotheses. Each can now be
tested against measurement.

| Hypothesis | Verdict |
|------------|---------|
| (a) proofs predate the tactics (ordering) | **Refuted as a sufficient explanation.** `Metalogic/` grew from ~92K to 148K lines *after* the tactics existed. 56K lines of new proof were written with zero search-family invocations. |
| (b) tactics aren't ergonomic enough | **Supported.** The single explicit statement in the codebase about why the tactic wasn't used (`Theorems/Combinators.lean:92`) cites a capability limit: "the greedy, backtrack-free `modal_search` cannot pick…". |
| (c) no documentation | **Refuted.** `Automation.lean` and `Bimodal.lean` carry worked docstring examples; `Examples/BimodalProofs.lean` exists specifically to demonstrate the tactics. |
| (d) tactics don't match proof shapes in `Metalogic/` | **Strongly supported.** `Metalogic/` is 80.1% of the tree. The one tactic family with any adoption (`simp_game_tuple`) was written *against a specific `Metalogic/` file* and is used there 35 times. Every tactic written speculatively against a general notion of "modal proof" has zero uptake. |

The two supported causes point the same direction: **tactics written against measured, specific
proof text get adopted; tactics written against an idea of what proofs look like do not.**

### 5.5 Coverage extension did not produce adoption

Task 185 (`complete_axiom_derived_coverage`) completed with the summary "Extended `tryAxiomMatch`
from 12 to 42 axiom constructors, added `tryDerivedMatch` with 26 derived theorems, 69 new test
examples, full lake build passes." That is a 3.5x increase in the search engine's axiom coverage
— exactly the remedy tasks 186 and 192 were sequenced behind.

Adoption after that increase: **still 3, still all in `Examples/`.** The hypothesis that
`modal_search` was unused because it knew too few axioms has been tested by a completed task and
is refuted.

### 5.6 The architectural blocker persists

Task 179's research found the Aesop integration was deprecated because `DerivationTree` is
`Type`, not `Prop` — proof reconstruction fails. Task 168 has since completed and *did*
re-parameterize the type (`DerivationTree (fc : FrameClass) : Context → Formula → Type`,
`ProofSystem/Derivation.lean:91`, 1,452 `FrameClass` references across the tree) — but it is
**still `Type`**. The Aesop blocker is unchanged.

This matters for sequencing: the May recommendation to defer tactic work until after 168 has been
satisfied — 168 is complete and archived. There is no longer a sequencing excuse for the
non-adoption. The tactics have had a stable post-168 `DerivationTree` to work against.

### 5.7 The unanimous "zero-risk" recommendation produced almost nothing

Task 179's research reported that **all four teammates independently converged** on `@[simp]`
lemma sets and `registerSimpAttr` domain-specific simp sets as "the highest-leverage immediate
improvement", "zero-risk", and safe to do before task 168. It measured 147 `@[simp]` tags.

Two months later:

```bash
grep -rn --include='*.lean' '@\[simp\]' Theories | grep -v '/Boneyard/' | wc -l   # 151
grep -rn --include='*.lean' 'registerSimpAttr' Theories | grep -v Boneyard
#   Automation/Normalization.lean:169:Plain macro approach (no `registerSimpAttr` infrastructure needed).
```

**+4 tags. Zero simp sets.** The only occurrence of `registerSimpAttr` anywhere in the tree is a
comment declining to use it. The single cheapest, least risky, most unanimously recommended piece
of automation work in this codebase's research history was not done.

This is the strongest available evidence that the constraint is not capability, effort, or risk.
A recommendation that is not carried by a task with a mandatory application pass does not happen
here, no matter how cheap it is.

### 5.8 What a bespoke tactic actually cost: task 199

Task 199 (`grid_order_tactic`) is the codebase's one live experiment in bespoke tactic
development, and it is `[partial]` with 1 of 4 phases done.

Sources: `specs/199_grid_order_tactic/reports/02_blocker-analysis.md`,
`specs/199_grid_order_tactic/summaries/01_grid-order-tactic-summary.md`,
`specs/199_grid_order_tactic/handoffs/phase-3-handoff-20260526.md`.

**What it cost and where it stalled — specifically:**

The plan's Phase 1 was to prove a `fan_order` theorem, on which the Phase 2 `grid_order_tac`
macro depended. Phase 1 did not fail because it was hard. **The theorem is false**, and task 199
disproved it with an explicit counterexample:

> Counterexample: `p=0, a=1, b=2, q=0, a'=2, b'=1`. All hypotheses (`p≤a`, `p≤b`, `q≤a'`,
> `q≤b'`, ordering iffs) satisfied, but `a<b` while `a'>b'`, so the conclusion fails.

The root cause, in the blocker analysis's own terms: `pivot_chain_order'` requires a *linear
chain* `a ≤ p ≤ b`. Case A supplies one (`b_resp ≤ d ≤ p_n`). Case B supplies a **fan** — `d ≤
b_resp` **and** `d ≤ p_n`, with nothing ordering `b_resp` against `p_n`. And no hypothesis
connects them, because `b_resp` comes from the tau game and `p_n` from the big game, and
*neither game contains both points*. The ordering the tactic needed is not derivable by abstract
order theory from what the proof context provides; it requires restructuring the construction
(an additional big-game challenge, or restructured padding) to introduce the missing relation.

**Outcome ledger for task 199:**

| Planned | Delivered |
|---------|-----------|
| Phase 1: `fan_order` theorem | **BLOCKED** — theorem disproved, skipped entirely |
| Phase 2: `grid_order_tac` macro | **BLOCKED** — depended on Phase 1 |
| Phase 3: apply to Case B | **PARTIAL** — 3 of 6 goals closed **by hand-written direct proofs**, not by a macro |
| Phase 4: verification | **NOT STARTED** |

**The task produced zero tactic.** Its only durable output is three hand-written
impossible-direction proofs in `CaseAnalysis.lean`. Note where those landed: `CaseAnalysis.lean`
is the *one file in the codebase where EF-game tactics are actually adopted*. Even in the single
location where bespoke tactics have demonstrated uptake, the attempt to go one level deeper hit a
mathematical wall that no amount of metaprogramming skill would have cleared.

**The generalizable lesson**: the binding cost of a bespoke tactic here is not implementation
difficulty. It is that a tactic encodes a *claimed* uniformity across proof sites, and whether
that uniformity actually holds is a mathematical question that is typically unanswered at
planning time. Task 199 was planned, scheduled, and one phase into execution before anyone
discovered its central lemma was false.

### 5.9 Verdict on further bespoke-tactic investment

**More bespoke tactic development is not warranted in this codebase on the current evidence, and
no task should be chartered to build a tactic as its deliverable.**

The measured record is unambiguous. Roughly 5,800 lines of proof automation exist, are tested,
survive the post-168 architecture, and are invoked at 38 real proof sites — all 38 from the one
tactic family that was written against a specific measured file, and 0 from every family written
against a general notion of what modal proofs look like. Increasing the search engine's axiom
coverage 3.5x (task 185) moved adoption by zero. The cheapest and most unanimously endorsed
improvement in the project's research history (`@[simp]` sets) moved by four tags in two months.
The one live bespoke-tactic experiment (task 199) produced no tactic at all because its
foundational lemma turned out to be false. And the sorry-reduction argument that once justified
tactic investment has evaporated: one executable sorry remains in 185,531 lines.

Tactic work should be permitted only under **all four** of the following preconditions:

1. **Application, not construction, is the deliverable.** The task's completion criterion must be
   a measured reduction in existing proof text at named files — never "tactic X exists and its
   tests pass". A task that ends with a working, tested, unused tactic has failed, and this
   codebase now contains ~5,800 lines of that failure mode.
2. **The uniformity is verified before the task is chartered**, not assumed. Task 199's lemma was
   false. Any charter must name the specific call sites and show that the pattern genuinely holds
   at each — a grep count is a hypothesis, not a proof of uniformity.
3. **The target is a specific measured file or small file set, not a layer.** The only family
   with adoption (`simp_game_tuple`) was built for `CaseAnalysis.lean`. Every family built for
   "modal reasoning" or "propositional goals" has zero uptake.
4. **The work is sequenced behind task 402.** Every ranked group rewrites proof bodies
   (section 4.3); a mass proof rewrite must not race a mass rename.

Sub-verdict on the ranked inventory: groups 1-4 and 6 satisfy preconditions 1 and 3 as scoped in
section 4 and are viable as *application* tasks. Groups 7, 8 and 9 — the `modus_ponens`,
`deduction_theorem` and `imp_trans` groups that tasks 186/192/193 were built around — depend on
authors adopting a search tactic, carry `A = 0.3` for exactly that reason, and are refuted by
sections 5.2 and 5.5. They should not be chartered.

*Section 5 written in Phase 3.*

---

## 6. Survivor Re-Scoping: Tasks 186, 192, 193

### 6.0 Dependency audit against live state

Read from `specs/state.json` and `specs/archive/state.json` on 2026-07-26.

| Task | Declared `dependencies` | Live status of each |
|------|------------------------|---------------------|
| **186** `unify_search_systems` | `[185, 199]` | **185** completed, archived at `specs/archive/185_complete_axiom_derived_coverage`. **199** `[partial]` — 1 of 4 phases, produced no tactic (section 5.8). |
| **192** `master_tactic_dispatch` | `[185, 187, 190, 191, 194]` | **All five completed and archived** (`specs/archive/{185,187,190,191,194}_*`). 192 has been fully unblocked for some time. |
| **193** `codebase_tactic_refactor` | `[189, 192, 196, 402]` | **189** completed, archived. **192** open (this section abandons it). **196** this survey. **402** `not_started`, deps `[341, 131, 394]`. |

All three have `"description": ""` — measured by `jq '.active_projects[] | select(...) | (.description // "") | length'`, which returns `0` for each. That is why none of them can be orchestrated, and it is the concrete defect this section repairs.

Two further live-state facts bear on the decisions:

- **Task 168 completed and is archived.** `DerivationTree` is now `(fc : FrameClass) : Context → Formula → Type` (`ProofSystem/Derivation.lean:91`). The "wait for 168" sequencing argument that shielded 186/192/193 in May no longer applies — and adoption did not move after it landed.
- **`FormalSystem/` in 193's `file_scope` is not a stale path.** It is the *post-402* location: task 402 Part A moves `Theories/Bimodal/` to `FormalSystem/`. The directory correctly does not exist yet.

---

### 6.1 Task 186 — `unify_search_systems`: **ABANDON**

**Decision**: abandon.

**The measured number that drove it**: **0**. Real proof-site invocations of `modal_search`,
`temporal_search`, `propositional_search` and `tm_auto` across `Metalogic/`, `Theorems/`,
`Semantics/`, `ProofSystem/`, `Syntax/` and `FrameConditions/` — the entire 178K-line proof
surface — total zero (section 5.2).

**Rationale**. Task 186's deliverable is a *better* search engine: merge the TacticM search
(`Tactics/Commands.lean`, 722 lines) with the computable search (`ProofSearch/Core.lean`, 1,254
lines) so each gains the other's strengths — IDDFS, caching, heuristics, complete proof
construction. The seed estimates 15 hours.

Every hour of it improves a tactic that no proof in this codebase calls. The proposition that
capability is the binding constraint has already been tested and refuted by a completed task:
185 raised `tryAxiomMatch` from 12 to 42 axiom constructors and added 26 derived theorems, and
adoption stayed at exactly 3 invocations, all in `Examples/` (section 5.5). Unification is a
larger, more expensive version of the same bet.

Its dependency on 199 also cannot be satisfied as intended: 199 is `[partial]`, its central
lemma was disproved, and it produced no tactic (section 5.8).

**What is lost, and where it is preserved**. One genuine engineering finding:
`bounded_search_with_proof` is incomplete. `Theories/Bimodal/Automation/ProofSearch/Core.lean:1193-1196`
still reads:

```
-- Modal/temporal rules would go here
-- Note: Full implementation of modal K and temporal K rules requires
-- helper lemmas from the deduction theorem. For now, we skip these.
```

That is a real defect, and it is a defect in code with zero call sites. It is recorded here so
the observation survives the abandonment. Note also that the duplicate-search-engine situation
raises a legitimate *consolidation-by-deletion* question — but section 5.3 shows `ProofSearch/`
is exercised by `Tests/BimodalTest/Automation/`, so it is not obviously deletable, and this
survey does not charter a deletion on that evidence.

**Downstream impact**: none. Only task 192 declared a dependency on 186's outcome, and 192 is
abandoned below. No other task in `state.json` lists 186.

---

### 6.2 Task 192 — `master_tactic_dispatch` (`tm_prove`): **ABANDON**

**Decision**: abandon.

**The measured number that drove it**: **0** again, plus **129**. Zero is the combined real
proof-site invocation count of every sub-tactic `tm_prove` would dispatch to — `modal_search`,
`temporal_search`, `propositional_search`, `prop_decide`, `deduction`, and the whole
`Normalization.lean` family (section 5.2). 129 is the number of `Derivable` references already in
the tree, which is where the task's one durable idea has already landed without it.

**Rationale**. `tm_prove` is a dispatcher: classify the goal, then route to the best sub-tactic.
The seed estimates 25 hours. A dispatcher's value is bounded by the value of what it dispatches
to; here that is a set of tactics with a combined zero real proof sites. Building a single
front door onto six unused rooms does not make the rooms used.

The revealed-preference evidence is unusually clean. All five of 192's dependencies — 185, 187,
190, 191, 194 — completed and were archived. 192 has therefore been fully unblocked, with every
prerequisite in hand, and in that time nobody wrote even a description for it. That is not a
scheduling accident; it is a judgment already made and never recorded.

**What is lost, and where it is preserved**. The transfer principle between `Derivable : Prop`
and `DerivationTree : Type` was 192's genuine architectural contribution. It is **not lost** —
it landed independently via task 181 and is live today: `ProofSystem/Derivable.lean:69` defines
`Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop`, with `Derivable.ofTree` at
line 99 and `Derivable.lift` at line 110, and there are 129 `Derivable` references across the
tree. The valuable half of 192 already shipped without the dispatcher.

The Aesop half did not ship and cannot: `DerivationTree` is still `Type`, not `Prop`
(`Derivation.lean:91`), which is the exact architectural cause task 179's research recorded for
the Aesop rule set being deprecated. Task 168 re-parameterized the type and left the sort
unchanged. Reviving Aesop-over-`DerivationTree` requires a sort change, which is far outside
192's charter.

**Downstream impact**: task 193 declares a dependency on 192. That edge is removed as part of
193's re-scope in 6.3 — the re-scoped 193 requires no dispatcher.

---

### 6.3 Task 193 — `codebase_tactic_refactor`: **RE-SCOPE**

**Decision**: re-scope.

**The measured numbers that drove it**: **153** and **173**. 153 occurrences of the validity
intro boilerplate `intro F M Omega _h_sc τ _h_mem t`, of which **148 sit in just two files**;
173 occurrences of `simp only [truth_at, …]`, of which **131 sit in three files, two of them the
same two**. Combined ranking score 225.7 (groups 2 and 3, section 4.2) — the highest of any
group realizable with `X = 1` complexity and `A = 1.0` adoption, i.e. with no new metaprogramming
and no dependence on anyone changing their habits.

**Why re-scope rather than abandon.** 193 is the only one of the three survivors whose deliverable
is *application* rather than *construction*, which is precondition 1 of the section 5.9 verdict.
Its identity — a pass that reduces existing proof text — is exactly the shape of work the
evidence supports. What is wrong with it is its target and its means, not its kind.

As chartered it targeted `Theorems/` (7,017 lines, **3.8%** of the tree — half the relative share
the May report assumed) using `tm_prove` as its instrument. `Theorems/` is sorry-free and stable,
`tm_prove` is abandoned, and the search-tactic instruments it would fall back to have zero
adoption. The re-scope keeps the task and replaces both.

#### Paste-ready charter for task 193

> **Title**: Apply validity-intro and truth-simp macros to the soundness layer
>
> **Slug**: `codebase_tactic_refactor` (unchanged — the directory
> `specs/193_codebase_tactic_refactor/` and its seed report are retained)
>
> **`task_type`**: `lean4`
>
> **Description**:
>
> Define a small family of syntactic macros and apply them mechanically to the three files that
> concentrate the codebase's two highest-frequency verbatim proof repetitions. This is an
> application task: the deliverable is measured reduction in existing proof text at named files,
> not the existence of a macro.
>
> Macros to define (single-line `macro … : tactic` declarations, no elaboration, no goal
> inspection):
> - `intros_validity` for `intro F M Omega _h_sc τ _h_mem t`
> - `intros_validity_framed` for the frame-condition-prefixed variant
> - `simp_truth` for the recurring `simp only [truth_at, Truth.future_iff, Truth.past_iff,
>   Truth.some_future_iff, Truth.some_past_iff]` bundle
> - `unfold_validity` composing `intros_validity` with `simp_truth`, for the sites where the two
>   appear consecutively
>
> Measured target sites (2026-07-26, `Boneyard/` excluded):
> - `Metalogic/SoundnessLemmas/DenseValidity.lean` — 92 `intro F M Omega`, 54 `simp only [truth_at`
> - `Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 56 `intro F M Omega`, 30 `simp only [truth_at`
> - `Metalogic/Soundness.lean` — 47 `simp only [truth_at`
>
> Completion criterion: `intro F M Omega` occurrences in the two `SoundnessLemmas/` files reach
> zero, `simp only [truth_at` occurrences across the three files fall by at least 80%, `lake build`
> is green, and the executable `sorry` count is unchanged at 1 (located by content in
> `Metalogic/WeakCanonical/Transfer.lean`, never by line number). A task that ends with working
> macros and unchanged proof text has failed.
>
> Do groups 2 and 3 as ONE pass over the same files, not two. Splitting them edits the same two
> files twice and forfeits the `unfold_validity` collapse.
>
> Explicitly out of scope: `Theorems/` refactoring, `tm_prove`, `modal_search` and every other
> search-family tactic, and any new elaborated tactic. See
> `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` section 5 for why.
>
> **`file_scope`**:
> ```json
> ["Theories/Bimodal/Automation/Tactics/",
>  "Theories/Bimodal/Metalogic/SoundnessLemmas/",
>  "Theories/Bimodal/Metalogic/Soundness.lean"]
> ```
> (Post-402 these paths live under `FormalSystem/`; 402 performs that move.)
>
> **`dependencies`**: `[402]`
>
> **Why the 402 dependency** — keep this sentence in the charter, it must survive copy-paste:
> this task rewrites proof bodies at ~330 sites, and task 402 rewrites the same reference graph
> at 24,364 sites while moving every file from `Theories/Bimodal/` to `FormalSystem/`. A mass
> proof rewrite must not race a mass rename; run this after 402 lands, never concurrently.
>
> **Effort**: 8 hours.
>
> **Inventory groups drawn on**: section 4.2 groups 2 (`intros_validity`, score 153) and 3
> (`simp_truth`, score 72.7).

**Dependency changes**: `[189, 192, 196, 402]` → `[402]`. 189 is completed and archived; 192 is
abandoned in 6.2; 196 is this survey, completing now; 402 is retained and is the whole reason
this task is not near-term.

#### Downstream impact on tasks 177 and 178 — resolved

Tasks 177 (`update_readme_and_module_docstrings`) and 178 (`publication_examples_and_demo`) both
declare `dependencies: [131, 193, 402]`.

**Both edges on 193 are retained, unchanged.** Because 193 is re-scoped rather than abandoned or
merged, no dependency surgery is required on either task, and neither needs to be touched in
`state.json`. This is a deliberate argument in favour of re-scoping over abandoning: abandoning
193 would have orphaned two edges and forced edits to two further tasks during a window when
`state.json` has no locking and three agents are writing to it.

The edges also remain *semantically* defensible under the new scope. 177 is "the final
documentation pass after all structural refactoring is complete" and 178 rewrites the
`Examples/` files; both should follow the last task that changes proof text, and re-scoped 193
still is such a task. The edge is weaker than it was under the "capstone of the tactics
initiative" framing — 193 no longer produces a user-facing tactic product for the docs to
describe — but it orders the work correctly and breaks nothing. Retaining it is the conservative
choice; a future `/todo` pass may drop it as noise without consequence.

Note that both 177 and 178 already depend on 402 directly, so the re-scoped 193's 402 dependency
introduces no new ordering constraint on either.

### 6.4 Summary of the three decisions

| Task | Decision | Driving measured number | Downstream edits required |
|------|----------|------------------------|---------------------------|
| **186** `unify_search_systems` | **ABANDON** | 0 real proof-site invocations of the search-tactic family across 178K lines; adoption unchanged at 3 after task 185's 3.5x axiom-coverage increase | none — no task depends on 186 except 192, also abandoned |
| **192** `master_tactic_dispatch` | **ABANDON** | 0 combined real proof sites across every sub-tactic it would dispatch to; 129 live `Derivable` references show its one durable idea already shipped via task 181 | 193's dependency on 192 removed (done as part of 6.3) |
| **193** `codebase_tactic_refactor` | **RE-SCOPE** | 153 `intro F M Omega` (148 in 2 files) + 173 `simp only [truth_at` (131 in 3 files) | **none** — 177 and 178 keep their edges unchanged |

*Section 6 written in Phase 4.*
