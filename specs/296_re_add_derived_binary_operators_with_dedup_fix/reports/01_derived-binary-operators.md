# Research Report: Re-Adding the 6 Derived Binary Temporal Operators (Task 296)

**Task**: 296 - Re-add derived binary temporal operators with dedup fix
**Date**: 2026-07-14
**Session**: sess_1784042369_262c14_296
**Type**: lean4
**Primary grounding**: Task 295 artifacts (`specs/archive/295_dataset_pipeline_diagnostic_audit/`), task 297 verification (`specs/archive/297_verify_operator_removal_and_regenerate_datasets/`), removal commit `8943e3356`

---

## 1. Executive Summary

**The central premise of the removal is empirically false.** Task 295 concluded the 6 binary
derived operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger)
"contributed zero unique formulas to pipeline output" because "their canonical representations
collapsed with primitives". Direct measurement (this report, Section 5) shows the opposite:

- At c4, the 6 operators contribute **690 new canonical equivalence classes** on top of the
  2,076 base classes (+33%), with only 48-8 collisions per operator out of ~400 raw formulas.
- At c5, they contribute **7,722 new canonical classes** on top of 12,754 base classes
  (**+60.5%**), with only 546 collisions out of 26,440 raw formulas.
- `release(p,q)` is *not* in the base canonical set at c4 — it does not collapse with anything.

**The "zero pipeline presence" finding was a measurement artifact.** Task 295 measured operator
presence by analyzing `formula_folded_sexpr` tags in the JSONL output. But the fold layer
(`Normalization.lean`) can **never emit tags for any of the 6 operators**:

- `EnrichedFormula` has **no constructors** for `release`, `weak_until`, `trigger`,
  `weak_since` (Normalization.lean:294-341 — only `strong_release`/`strong_trigger` exist).
- `foldFormula`/`recognizeComposites` have **no recognition patterns** for any of the 6
  (verified empirically: `release(p,q)` folds to `(neg (untl (neg p) (neg q)))`,
  `strong_release(p,q)` folds to `(untl (and q p) q)` despite its constructor existing).
- No `release_unfold`/`weak_until_unfold`/`trigger_unfold`/`weak_since_unfold` simp lemmas
  exist either — the 17 unfold lemmas in Normalization.lean cover 15 operators, skipping
  exactly these 4.

So a folded-tag census returns zero for these operators *regardless of dataset content*.
Task 297's "zero occurrences of removed operators in any dataset" post-removal check has the
same blind spot.

**Recommendation** (Section 7): re-add the enumerator branches unchanged (the dedup machinery
does *not* need adjustment — approach "none of the above"), and fix the *representation layer*
(4 new `EnrichedFormula` constructors + fold recognition for all 6 operators) so that presence
is real, measurable, and exported. Verify presence by value-level pattern counting, not fold
tags alone.

**Open discrepancy flagged for planning** (Section 6): a from-scratch replica of the pipeline's
deterministic stages yields ~2.6x more c4 canonical classes (2,076) than the June 8 dataset has
records (806). A fresh ground-truth run of `lake exe dataset_generator` was launched during this
research to resolve the gap; results in Section 6. This must be reconciled during Phase 1 of
implementation because it determines the surviving-formula counts (and labeling cost) after
re-adding the operators.

---

## 2. Where Everything Lives (Files, Functions, Signatures)

### 2.1 Operator definitions — `Theories/Bimodal/Syntax/Formula.lean`

All 6 operators are **`def` abbreviations over the 6 primitive constructors**
(`atom/bot/imp/box/untl/snce`), NOT constructors:

| Operator | Line | Definition |
|----------|------|------------|
| `release φ ψ` | Formula.lean:448 | `(Formula.untl φ.neg ψ.neg).neg` |
| `weak_until φ ψ` | Formula.lean:457 | `(Formula.untl φ ψ).or ψ.all_future` |
| `trigger φ ψ` | Formula.lean:465 | `(Formula.snce φ.neg ψ.neg).neg` |
| `weak_since φ ψ` | Formula.lean:474 | `(Formula.snce φ ψ).or ψ.all_past` |
| `strong_release φ ψ` | Formula.lean:477 | `Formula.untl (Formula.and ψ φ) ψ` |
| `strong_trigger φ ψ` | Formula.lean:480 | `Formula.snce (Formula.and ψ φ) ψ` |

Consequence: `release p q` **is the value** `neg (untl (neg p) (neg q))`. There is no
value-level distinction between "the derived form" and "the primitive form" — they are the
same object. This kills candidate approaches (2) and (4) outright (Section 4).

`Formula.complexity` (Formula.lean:170) is **pattern-aware** (tasks 274/275/285): it matches
the primitive expansions of derived operators and assigns them low cost. Verified by inline
`#eval`s at Formula.lean:484-503: `release/trigger/weak_until/weak_since(atom,atom) = 3`,
`strong_release/strong_trigger(atom,atom) = 4`. Note the genuine ambiguity:
`release(φ, ⊥) = all_future(φ)` **as a value** (the G-pattern case at Formula.lean:198-199
shadows the R-pattern case, correctly).

### 2.2 Enumerator — `Theories/Bimodal/Automation/FormulaEnumerator.lean`

| Item | Location | Signature / role |
|------|----------|------------------|
| `enumExactHelper` | :154 | `(atoms : List Atom) (modalBudget temporalBudget sizeBudget : Nat) (cache : EnumCache) : Array Formula × EnumCache` — exact-complexity memoized enumeration. The 6 op branches were removed from the binary cross-product section (was after `untls ++ snces`, :295). |
| `passesFilter` | :721 | `(φ : Formula) : Bool` — `φ.complexity ≥ 3 && hasModalOrTemporal φ`. **Not a blocker**: min pattern-aware complexity of the 6 ops is 3 (R/T/WU/WS) or 4 (M/ST), and all contain `untl`/`snce`. |
| `sampleOne` | :~400 | Grammar-based deterministic sampler; binary-derived slot removed (commit 8943e3356). |
| `sampleOneRandom` | :~795 | IO random sampler; branch 11 (binary derived) removed. |
| `randomSubFormula` | :~1009 | Mutation-support sampler; branch 9 removed. |
| `hashDedup` | :1585 | Value-level `Std.HashSet Formula` dedup (post task 295 fix). |
| `canonicalDedupArray` | :1710 | Per-level atom-permutation dedup with cross-level seen-set. Only active when `EnumParams.canonicalDedup = true` (**default false**; the CLI does not set it). |
| `enumerateWithProgress` | :1733 | IO exhaustive driver: per level → `enumExactBudget` → `passesFilter` → optional canonical dedup → concat. |
| `generateFormulas` | :1847 | `enumerated ++ validSeeds` → `hashDedup` → cap. |
| `hasDerivedTemporal` | :1911 | Already recognizes R/T/WU/WS primitive patterns (:1924-1934) — no change needed. |
| `partitionCrossProduct` | :1995 | Parallel enumeration path (task 283 Phase 5). Generates only `untls ++ snces` (:2064-2070) — **never had** the binary derived branches (verified against pre-removal commit `8943e3356^`). Pre-existing parity gap; Phase 1 should add the branches here too. |
| `EnumParams` | :683 | Defaults: `maxComplexity 5, maxModalDepth 2, maxTemporalDepth 2, atoms [p,q,r], validSeedCount 500`. |

### 2.3 Canonicalization — `Theories/Bimodal/Automation/AtomCanonicalization.lean`

`canonicalize` (:115) is **pure atom renaming** (first-seen DFS order → p,q,r,...). It does not
rewrite structure and cannot merge a release-value with a non-release-value unless they are
already structurally identical up to atom names. `deduplicateCanonical` (:132) is the pipeline's
dedup entry point (called from DatasetExport main Step 3).

### 2.4 Dataset pipeline — `Theories/Bimodal/Automation/DatasetExport.lean`

`main` (:931) stage order for `--mode exhaustive` (the cN dataset runs, per task 297:
`lake exe dataset_generator -- --max-complexity 4 --output data/bmlogic-c4.jsonl`):

1. `enumerateAndEnrich` (:813) → `generateFormulas` (enum + valid seeds + `hashDedup`);
   `--include-duals` off by default.
2. Checkpoint write (`.checkpoint` next to output).
3. **Step 3**: `AtomCanonicalization.deduplicateCanonical` (:1040) unless `--skip-dedup`.
4. Step 3b: interestingness-stratified sampling only if `--stratified-sample > 0` (off for cN runs).
5. Step 4: streaming label + write — one JSONL record per surviving formula.

The folded representation fields are produced at :301-303 via `Formula.toEnrichedJson/
toEnrichedPretty/toEnrichedSExpr` (= `foldFormulaFull` compositions from Normalization.lean).

### 2.5 Fold layer — `Theories/Bimodal/Automation/Normalization.lean`

| Item | Location | Gap |
|------|----------|-----|
| `EnrichedFormula` | :294 | 23 constructors; **missing** `release`, `weak_until`, `trigger`, `weak_since`. Has `strong_release`, `strong_trigger` (:338, :340). |
| `foldFormula` | :~405 | `untl`/`snce` nodes only match `top`/`bot` guards (→ F/P/next/prev); `foldImp` handles diamond/G/H/weak_future/weak_past/and_/neg. **No patterns for any of the 6 binary ops** — including M/ST whose constructors exist but are never produced. |
| `recognizeComposites` | :~478 | Post-pass for `always`/`sometimes`/`or_`. No binary-derived patterns. |
| Unfold lemmas | :64-138 | 17 `@[simp]` `rfl` lemmas; **missing** `release_unfold`, `weak_until_unfold`, `trigger_unfold`, `weak_since_unfold`. `modal_norm` macro lists (:157-162, :192, :202) would need the 4 additions. |
| `toJson`/`prettyPrint`/`toSExpr` | :~900-1000 | Exhaustive matches on `EnrichedFormula` — need 4 new cases each. |

`EnrichedFormula` consumers are confined to Normalization.lean (verified by grep — DatasetExport
only uses the `toEnriched*` wrappers). `FormulaMutator.lean:320` already contains value-level
primitive-pattern matchers for trigger/strong_trigger — a precedent for value-level operator
recognition.

Empirical fold behavior (verified via `lean_run_code` against HEAD):

```
release(p,q)        folds to (neg (untl (neg p) (neg q)))       -- no tag
weak_until(p,q)     folds to (or (untl p q) (all_future q))     -- no tag
trigger(p,q)        folds to (neg (snce (neg p) (neg q)))       -- no tag
weak_since(p,q)     folds to (or (snce p q) (all_past q))       -- no tag
strong_release(p,q) folds to (untl (and q p) q)                 -- no tag (constructor exists!)
strong_trigger(p,q) folds to (snce (and q p) q)                 -- no tag (constructor exists!)
release(p,bot)      folds to (all_future p)                     -- genuine value identity with G
```

---

## 3. Root-Cause Analysis: Why "Zero Presence" Was Reported

Three independent effects were conflated in task 295's diagnosis:

1. **Measurement artifact (dominant)**: presence was counted from `formula_folded_sexpr` tags.
   The fold layer cannot emit `release`/`weak_until`/`trigger`/`weak_since` (no constructors)
   nor `strong_release`/`strong_trigger` (no fold patterns). The census was structurally
   guaranteed to return zero for all 6 operators, whatever the dataset contained.

2. **Genuine but partial value collisions (minor)**: `release(φ,⊥) = all_future(φ)` and
   `trigger(φ,⊥) = all_past(φ)` as values; `strong_release`/`strong_trigger` collide when the
   `and`-guard degenerates. Measured at c4: 48/400 release, 48/400 trigger, 8/400 M, 8/400 ST,
   0/400 WU, 0/400 WS raw formulas collide with the base enumeration's canonical classes.
   These collisions are *correct* dedup behavior (same value ⇒ same formula) and affect only a
   small minority.

3. **Task 297's count comparison is confounded**: c4 806→806, c5 6,029→6,028, c6
   39,787→39,790 pre/post removal appear to show "no output change", but the ±1/±3 variation
   already reveals a non-deterministic component (`generateValidBatch` random seeds), and the
   identical c4 count is inconsistent with the measured 690 new canonical classes the operators
   contribute at c4. See the Section 6 discrepancy — the June runs' surviving-count mechanics
   do not match a first-principles replica of the current pipeline, so those counts should not
   be treated as evidence of collapse.

---

## 4. Evaluation of the 4 Candidate Approaches

| # | Approach (from task description) | Verdict | Reason |
|---|----------------------------------|---------|--------|
| 1 | Skip canonicalization for formulas containing derived binary operators | **Reject** | Canonicalization is not what suppresses them (Section 5: 99-125 new classes per op survive it at c4). Skipping would also *increase* atom-permutation duplicates (release(p,q)/release(q,r)/... all kept) without adding representational value, and "contains derived binary op" is only detectable by pattern-matching the expansion anyway. |
| 2 | Canonicalize to the derived form instead of the primitive form | **Reject (incoherent at value level)** | The operators are `def` abbreviations: `release p q` *is* `neg(untl(neg p, neg q))`. There is no distinct derived form to canonicalize to. The derived form exists only in `EnrichedFormula` — which is a representation/export concern, not a dedup concern. |
| 3 | Lower/remove the `passesFilter` complexity gate for these operators | **Reject (no-op)** | The gate is `complexity ≥ 3` with pattern-aware complexity; the 6 ops score 3-4 even on atoms and all contain `untl`/`snce`. They already pass. (The gate *is* the blocker for `always(p)`/`sometimes(p)` at complexity 2 — that is 295's P2 recommendation and is worth bundling if task scope includes all 13 operators; see Section 7 Phase 4.) |
| 4 | Fold-aware dedup treating `release(p,q)` as distinct from `neg(untl(neg p, neg q))` | **Reject (impossible without provenance, and unnecessary)** | They are the same Lean value; `foldFormula` is a function of the value, so both "forms" fold identically. Distinguishing them would require threading enumerator provenance tags through the pipeline and would produce duplicate records with identical labels (same formula, same validity) — semantically wrong for a dataset. Unnecessary because the values are already distinct from everything else in the enumeration (Section 5). |

**Correct approach (5, synthesized)**: the dedup machinery needs **no adjustment**. Re-add the
enumerator branches as-is, and complete the *representation layer* so the operators are
visible: 4 new `EnrichedFormula` constructors, fold/recognizeComposites patterns for all 6
operators, serialization cases, and unfold lemmas. Fix the measurement protocol (value-level
pattern counts, not fold-tag greps).

---

## 5. Empirical Measurements (this research, `lean_run_code` against HEAD)

Method: replicate the deterministic pipeline stages (levels 1..N via `enumExactHelper` with
atoms [p,q,r], modal/temporal depth 2/2 → `passesFilter` → `AtomCanonicalization.canonicalize`
→ class census), then reconstruct the removed binary-derived branch output exactly as commit
8943e3356 had it (cross-product of `tLefts × tRights` at `temporalBudget - 1`) and measure
overlap.

### c4 (maxComplexity 4)

| Source | Raw | Post-filter | Canonical classes |
|--------|-----|-------------|-------------------|
| Base enumeration (current, ops removed) | 5,061 | 4,992 | 2,076 |

| Operator | Raw | Post-filter | Collide w/ base | **New canonical classes** |
|----------|-----|-------------|-----------------|---------------------------|
| release | 400 | 396 | 48 | **99** |
| weak_until | 400 | 400 | 0 | **125** |
| trigger | 400 | 396 | 48 | **99** |
| weak_since | 400 | 400 | 0 | **125** |
| strong_release | 400 | 400 | 8 | **121** |
| strong_trigger | 400 | 400 | 8 | **121** |
| **Total** | 2,400 | 2,392 | 160 | **690 (+33% over base)** |

Spot check: `canonicalize (release p q) ∉` base canonical set; `(release p q).complexity = 3`;
`passesFilter (release p q) = true`.

### c5 (maxComplexity 5)

| Source | Post-filter | Canonical classes |
|--------|-------------|-------------------|
| Base enumeration | 37,403 | 12,754 |
| 6 ops combined | 26,440 | **7,722 new** (546 collide) |

**+60.5% canonical classes at c5.** The claimed "40-60% enumeration-space inflation without
contributing unique formulas" is actually "40-60% inflation contributing ~60% more unique
canonical formulas".

### Cost projection

Labeling is the pipeline bottleneck (295: c5 11s, c6 ~15min, c7 marginal). Re-adding the
operators grows the labeled set by roughly +33% (c4) to +60% (c5, and plausibly similar at c6).
Projected c6 labeling: ~15min → ~22-25min. c7 exhaustive remains marginal and is gated by the
separate c7 labeling bug (task 298 territory), not by this change.

---

## 6. The June 8 Datasets Are Not the Post-Removal Pipeline Output (resolved discrepancy)

A first-principles replica of the deterministic pipeline stages (enumerate levels 1-4 →
`passesFilter` → canonical dedup, CLI-default params) predicts 2,076 c4 canonical classes, yet
`data/bmlogic-c4.jsonl` (written 2026-06-08 21:59, *after* the 19:38 removal commit) has 806
records. Direct set comparison (parsing every record's `formula_sexpr` back into `Formula`,
via `lake env lean` script):

| Comparison | Count |
|-----------|-------|
| Dataset records (all distinct values) | 806 |
| Replica canonical classes (post-removal HEAD code, same params) | 2,076 |
| Dataset ∩ replica | **366** |
| Dataset \ replica | **440** |
| Replica \ dataset | **1,710** |

All 440 dataset-only formulas are canonical (so they passed through `deduplicateCanonical`),
but the post-removal enumerator **cannot generate them**. Smoking gun — record
`bmlogic-00199`:

```
formula_sexpr:        (untl (imp (snce (imp bot bot) (imp (atom "p") bot)) bot) (imp bot bot))
                      = F(trigger(⊥, p))   [pattern-aware complexity 4]
label:                invalid  (decision_method adaptive_500 — NOT a valid seed)
formula_folded_sexpr: (some_future (neg (snce top (neg (atom "p")))))  -- no trigger tag
```

`trigger(⊥,p)` is constructible only by the removed binary-derived branch (as a primitive
composition it needs level ≥ 9). So:

1. **Binary-derived-operator formulas are in the published c4 dataset right now** — invisible
   to the fold-tag census (the folded field shows `neg (snce …)`), which is exactly the
   measurement artifact of Section 3.
2. **Task 297's c4/c5/c6 "regeneration" relabeled a stale (pre-removal) formula list** rather
   than freshly enumerating with the post-removal code. The most plausible mechanism is the
   checkpoint reload path in `DatasetExport.main` Step 1b (`--use-checkpoint`, or
   `--resume-from N` with an existing `.checkpoint` — 297 demonstrably used resume for c7,
   3 stall retries). This also explains 150 complexity-5 records and 3 purely-propositional
   records in a "c4 exhaustive" dataset (older-vintage formula list with different budget
   semantics + seed leakage), and why counts appeared "unchanged" pre/post removal — the same
   frozen formula list was relabeled.
3. Therefore neither 295's presence census nor 297's "removal changed nothing" verification
   constrains what the *current* pipeline produces. The Section 5 replica numbers are the best
   current estimate (the replica and the binary share the same
   `enumExactHelper`/`passesFilter`/`deduplicateCanonical` code paths, so divergence is not
   expected). Empirical validation via a live `lake exe dataset_generator` c4 run (confirming
   the 6 derived operators survive dedup in the compiled pipeline) is **deferred to the
   implementation phase as its acceptance test** — it triggers a long full-C rebuild and
   belongs to implementation/validation, not research.

Planning implications:
- Phase 1 must run generation **fresh** (delete or bypass `.checkpoint` files; add a log
  assertion that Step 1b took the fresh-enumeration path) and record the stage-by-stage
  counts (`[gen]`/`Deduplicated` lines).
- The published c4/c5/c6/c7 datasets are stale relative to HEAD *independently of this task* —
  full regeneration (with checkpoints cleared) should be an explicit deliverable/follow-up.

---

## 7. Recommended Phased Implementation

### Phase 1: Re-add enumerator branches + ground-truth baseline

- Re-apply the `enumExactHelper` hunk of commit 8943e3356 in reverse (6 cross-product
  builders after `snces` at FormulaEnumerator.lean:295, concatenated into
  `temporalBinaries`), and the corresponding branches in `sampleOne`, `sampleOneRandom`,
  `randomSubFormula`.
- Also add the branches to `partitionCrossProduct` (:2064-2070) — the parallel enumeration
  path never had them (pre-existing parity gap vs the sequential path).
- Extend the existing `#eval` membership checks (~:1980-2000: diamond/next/prev presence) with
  `release(p,q)`/`weak_until(p,q)` membership assertions at the appropriate level.
- Run c4 baseline before/after via the real binary with `--valid-seed-count 0`; record the
  `[gen]`/`Deduplicated`/labeled counts. Expected: raw +~2,400, final +~690 at c4.
- Verification: `lake build`; `#eval` count assertions; zero sorries (all changes computational).

### Phase 2: Representation layer completion (Normalization.lean)

- Add 4 `EnrichedFormula` constructors: `release`, `weak_until`, `trigger`, `weak_since`.
- Extend `toPrimitive`, `recognizeComposites` recursion, `toJson`, `prettyPrint`, `toSExpr`
  (4 cases each; compiler enforces exhaustiveness — no missed sites).
- Fold recognition:
  - `foldImp`: `| .untl (.neg φ) (.neg ψ), .bot => .release φ ψ` and snce-dual for `trigger`.
    Safe ordering: ⊥-guards already fold to `top`/`bot` before this point, so the
    `release(φ,⊥)=G(φ)` identity is automatically routed to `all_future` by the earlier
    `.some_future (.neg φ), .bot` case.
  - `foldFormula` untl/snce nodes: `| .and_ a b, g` with `a == g` → `strong_release b g`
    (and snce-dual for `strong_trigger`).
  - `recognizeComposites` or_ node: `.or_ (.untl φ ψ) (.all_future ψ')` with `ψ == ψ'` →
    `weak_until φ ψ` (and snce/all_past-dual for `weak_since`).
- Add 4 `@[simp]` `rfl` unfold lemmas; extend `modal_norm`/`modal_fold` macro lists.
- Round-trip `#eval` tests: `toPrimitive ∘ foldFormulaFull = id` on representative instances
  of all 6 operators (extend the existing 21-formula suite).

### Phase 3: Measurement protocol fix + dataset regeneration

- Add a value-level operator census utility (primitive-pattern matchers, precedent:
  `FormulaMutator.lean:320`) or reuse the now-correct folded tags — but cross-check both.
- Regenerate c4/c5 (fast), verify all 13 derived operators have nonzero presence in
  `formula_folded_sexpr`; c6 regeneration optional in this task (25min run).

### Phase 4 (optional, completes the "all 13" goal): always/sometimes gate

- 295-P2: `always(p)`/`sometimes(p)` have pattern complexity 2 and are excluded by
  `passesFilter`'s `≥ 3` gate. Either lower the gate to 2 for formulas matching
  always/sometimes patterns, or accept representation only at complexity ≥ 3 arguments.
  Re-measure with the fixed census before deciding — the 295 claim that higher-complexity
  `always` formulas "get deduplicated" carries the same measurement-artifact suspicion.

### Zero-debt compliance

All changes are computational definitions, exhaustive-match extensions (compiler-enforced),
`rfl` lemmas, and `#eval` tests. No sorries, no axioms, no proof debt anticipated. The only
proof-adjacent risk is `normalizeFormula_id` — it pattern-matches on 6 primitive constructors
only and is unaffected by `EnrichedFormula` changes.

---

## 8. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Fold pattern mis-ordering shadows existing tags (e.g., G vs release) | Wrong enriched output | The ⊥/⊤ guard folding happens in children first; add regression `#eval`s for `release(p,⊥)→all_future` and the existing 21-formula round-trip suite |
| Labeling cost growth at c6 (+50-60%) | Longer regeneration | c6 stays ~25min; acceptable. c7 blocked by task 298's labeling bug independently |
| Ground-truth run reveals an additional suppression stage (Section 6) | Re-added ops might be suppressed again | Phase 1 explicitly measures stage-by-stage counts before/after; if a suppressor exists it becomes the actual fix target |
| `Formula.complexity` pattern ambiguity (complexity-5 records in c4 dataset) | Dataset complexity metadata slightly off | Pre-existing behavior, orthogonal to this task; document in plan |

## 9. Tactic Survey Results

Not applicable in the usual sense — this task involves no proof goals. The verification surface
is `lake build` + `#eval` assertions + `rfl` simp lemmas. `lean_multi_attempt` was not needed;
`lean_run_code` was used for the five decisive experiments (c4/c5 class censuses, fold-behavior
probes, complexity/filter spot checks).

## 10. Key Findings for the Planner (compressed)

1. Dedup does NOT need fixing — the 6 ops survive canonicalization (690 new classes at c4,
   7,722 at c5). Re-add branches verbatim from commit 8943e3356 (reverse).
2. The real gap is the fold/representation layer: 4 missing `EnrichedFormula` constructors,
   0/6 fold recognition patterns, 4 missing unfold lemmas. All in `Normalization.lean`.
3. All prior "presence" measurements (295 §operator-audit, 297 verification) were fold-tag
   based and structurally blind to these operators; the census method must change.
4. `passesFilter` untouched for the 6 binary ops; only relevant to always/sometimes (Phase 4).
5. `release(φ,⊥) = all_future(φ)` is a genuine value identity — small collision sets are
   correct behavior, not a bug.
6. Resolve the Section 6 pipeline-count discrepancy during Phase 1 with stage-count logging.
