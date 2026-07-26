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
