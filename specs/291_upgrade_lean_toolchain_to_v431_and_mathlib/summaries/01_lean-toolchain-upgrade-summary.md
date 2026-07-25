# Implementation Summary: Lean Toolchain Upgrade to v4.33.0-rc1

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Status**: PARTIAL — phases 1-4 of 10 complete, phase 5 partial (5 errors in 1 file),
  phase 6 measured clean, build not yet green
- **Plan**: `plans/01_lean-toolchain-upgrade.md`
- **Session**: `sess_1784959849_77d9d9`

## What landed

The repo is pinned to `leanprover/lean4:v4.33.0-rc1` + Mathlib `v4.33.0-rc1`, matching cslib
HEAD byte-for-byte. Pre-upgrade baselines are captured, the breakage is measured and categorized,
and the repair work is nearly finished. After three implementation dispatches **373 of the 430
`Theories/` modules elaborate**, with 60+ source files repaired and **no `sorry`, axiom or
`backward.*` option added at any point**. **5 errors remain, all in one file**, with 57 modules
blocked behind it.

The error count is not the progress signal in this task and should not be read as one. `lake
build` aborts a failing module's dependents, so every cleared blocker exposes modules that were
previously invisible; the count went 12 -> 3 -> 54 -> 26 -> 39 -> 59 -> 15 -> 4 -> 13 -> 48 ->
46 -> 7 -> 5 while the count of elaborating modules rose monotonically. Only the second series
measures progress. In the third dispatch the two finally agree: errors fell 39 -> 5 *while*
elaborating modules rose 326 -> 373.

**Metric correction.** The first two dispatches reported progress as "modules elaborated
N / 1877". That was wrong: 1877 is lake's *job* counter over the whole build graph, and the
`[N/1877]` marker records where the scheduler stopped, not how much elaborated — it read
`1837/1877` both at 46 errors and at 5. `Theories/` holds 430 modules; the defensible measure is
`430 - (failing + transitive dependents)`, computed from the import graph. The script is in
`handoffs/phase-5-handoff-1785045000.md`.

| Phase | Status | Outcome |
|---|---|---|
| 1 Baselines | COMPLETED | Build/sorry/axiom/test/executable baselines at HEAD `e0158da5e` |
| 2 Pin flip | COMPLETED | Toolchain + Mathlib pinned; `cache get` gate passed |
| 3 Inventory | COMPLETED | 12 errors, fully categorized, 0 unattributable |
| 4 Mechanical repairs | COMPLETED | 12 -> 3 errors, no `sorry` added |
| 5 Defeq/transparency | PARTIAL | 326 -> 373 of 430 modules elaborating; 41 more files repaired |
| 6 Heartbeat budgets | MEASURED CLEAN | **0** timeouts corpus-wide; 0 budget changes |
| 7-10 | NOT STARTED | See "Where to resume" |

Commits: `0a2afee82` (P1), `29b9cea6f` (P2), `7c8db8b12` (P3), `f091cc5f1` (P4), and the
Phase 5 sub-steps `9aa3e37ad` … `ac3aaab72` (19 incremental green commits).

## Actual repair volume, by category

The task description guessed "~50-200 lines of fixes". Research argued that guess was wrong *in
kind* — that breakage would be semantic (defeq transparency, heartbeats, `simp` instances) rather
than rename-driven, because it had verified that all 59 imported Mathlib **modules** still exist.

**The measurement contradicts both.** It is rename-driven after all, and far smaller than 50 lines
so far:

| Category | Errors | Lines changed | In research §5? |
|---|---|---|---|
| `mathlib-lemma-renames` | 10 | 10 (one-token substitutions) | **No — new row** |
| `subtype-proof-irrelevance` | 3 | 4 | **No — new row** |
| `defeq-transparency` | 3 (open) | — | Yes (predicted HIGH) |
| `heartbeat-timeout` | 0 so far | 0 | Yes (predicted HIGH) |
| `do-elaborator` | 0 | 0 | Yes (predicted MED-HIGH) |
| `simp-instances`, `native-decide-axioms`, `subgoal-tags`, `noncomputable`, `meta-api-renames`, `range-syntax`, `dsimp-no-progress` | 0 each | 0 | Yes |

Research §3 was right that no import path broke. What it missed is that Mathlib renamed individual
**lemmas inside** those still-existing modules:

| Old | New | Sites |
|---|---|---|
| `Finset.not_mem_empty` | `Finset.notMem_empty` | 5 |
| `le_of_not_lt` | `le_of_not_gt` | 4 |
| `PredOrder.ofLePredIff` | `PredOrder.ofPredLeIff` | 1 |

Every replacement was confirmed in the vendored Mathlib source before use, not guessed.

## Findings worth carrying forward

**The plan's headline Phase 5 defeq sites were a false alarm.** `ChronicleToCountermodelBasic.lean`
`:989`/`:1000` were pre-identified as the highest-risk defeq-transparency sites, and they did report
"Not a definitional equality" and "Type mismatch". Both were **cascades from the renamed
`PredOrder.ofLePredIff` 12 lines above**; the one-token rename cleared all three errors and the
`rfl` proofs still hold. Phase 5's real scope is therefore much smaller than planned.

**The 4.32 `do`-elaborator hazard has no matching site in this repo.** The plan rates this the most
dangerous change because it fails no build. A source audit found **zero** `(← do …)` occurrences in
`Theories/`, and the single `← try … catch` site (`DatasetGenerator.lean:1729`) has no `return` in
its body. The `return` at `:1734` sits in an `IO.asTask do` block, which is not the affected form.
Phase 8's output diff should still run, but the prior probability of a hit is now low.

**Five executables are not reproducible even pre-upgrade.** Running each target twice before
touching anything showed `contrastive_generator`, `dataset_generator`, `enum_benchmark`,
`proof_first_generator` and `tableau_proof_steps` produce different output run-to-run: they call
unseeded `IO.rand` (`FormulaEnumerator.lean:811+`). Two identical `enum_benchmark` runs gave pool
sizes 108 vs 98. `proof_first_generator` is affected despite taking `--seed 1000`, which does not
control `IO.rand`. **A byte-exact Phase 8 diff is impossible for these five regardless of the
upgrade** — they get a structural comparison that masks RNG-derived cardinalities and requires
everything else to match. The other 7 targets are exactly reproducible.

**Three of the plan's suggested executable invocations were wrong.** `trace_exporter` reads
S-expressions, not JSON, so the plan's JSON line would have baselined a parse-error path that
compares equal before and after while exercising nothing. `tableau_bridge` does take JSON but
needed its own envelope. `tableau_proof_steps --max-complexity 3` never finishes.

**`lake clean` destroys the Mathlib cache.** It cleans the whole workspace, dependencies included:
olean count went 8300 -> 0. The plan's Phase 2 task order (`cache get` then `clean`) therefore
loses what it just fetched. Order used instead: `update` -> `cache get` -> `clean` -> `cache get`.

**The `heartbeat-timeout` risk did not materialise, and that is now measured rather than
assumed.** The plan rated it second only to `defeq-transparency`, reasoning that a 20-50%
elaboration-cost increase landing on a corpus already running at up to 64x the default budget
would tip many proofs over. With every one of the four named heavyweight files now elaborated —
`SharedWitness.lean` (12,800 lines), `SuccChainFMCS.lean` (6,147), `GapDetection.lean` (5,056),
`SplitPoint.lean` (4,693) — the corpus-wide count of `(deterministic) timeout` errors is **zero**
and not one `maxHeartbeats` value was raised. The 88 existing sites are unchanged.

**The real category was never `isDefEq` call sites — it was semireducible type synonyms.** Every
one of the ~200 errors across three dispatches traces to the same shape: a term whose *inferred*
type is the unfolded form of a semireducible `def` (`NormalForm`, `ZoneSpec`, `ExtendedCarrier`,
`(orderedSum …).carrier`) placed where the *declared* type is the synonym. Elaboration accepts it
(default transparency); instance synthesis, `rw` motive construction and `simp` congruence do not
(instances/reducible transparency). This single mechanism produced failures that present as at
least seven unrelated-looking symptoms: `failed to synthesize Decidable`, `rw` not finding a
visibly-present pattern, `split_ifs` silently half-applying, `simp` "no progress", `simp` leaving
`X = X`, a stuck `decide`, and `rcases` "not a free variable". Recognising them as one family is
what turned the work mechanical.

**Two repairs, and knowing which to reach for is the whole skill.** `show T from e` re-elaborates
`e` against the expected type and fixes the cases where the *result* type is wrong (a projection,
an `if` scrutinee). A named helper whose *declared* argument and result types are the synonym
(`orderedSumPt`, and the `zoneCons` the last file needs) fixes both result and argument
positions. A parenthesised `(e : T)` ascription is never sufficient. When neither is
proportionate — 24 near-identical sites in one file — `@[reducible]` on the offending definition
is the right tool, subject to the instance-safety test below.

**A safety test for `@[reducible]`, derived from one success and one failure.**

> `@[reducible]` on a structure-instance def is safe iff, for every class whose instance the
> structure carries as a field, the unfolded carrier admits no instance other than the one the
> field supplies.

`extendedStructure`/`extendedStructureWithMu` pass (their `.carrier` unfolds only to the
still-semireducible `ExtendedCarrier`, whose only order instance *is* `carrier_order`) and the
attribute cleared 48 errors in `StaviCompleteness.lean` in one change with no regression.
`orderedSum` fails the test (its `.carrier` unfolds to a raw `Sigma`, where Mathlib's
`Sigma.preorder` outranks the local order — a silently *different* order, with no error) and was
rejected. Both rationales are recorded in docstrings on the definitions so the distinction
survives this task. `NormalForm`, flagged in the second dispatch as the remaining untried lever,
turned out not to need it at all.

**A failed instance declaration poisons `decide` far away.** `SharedWitness.lean`'s
`DecidableEq (ZoneSpec n)` bridge failed at line 61; the *reported* errors were `decide` failures
2,000 lines later whose message ends "reduction got stuck at the `Decidable` instance `sorry`".
Fixing the instance cleared them all. Read a stuck `decide` as a cascade until proven otherwise.

**`List.Chain'` is gone and its lemmas have no deprecation aliases.** Batteries replaced
`Chain`/`Chain'` with the inductive `List.IsChain`. The *predicates* carry `@[deprecated]`
aliases so statements still elaborate with a warning; the lemmas were deleted and produce
`Unknown constant`. The mapping has a trap — the primed old name maps to the *unprimed* new one
(`chain'_cons'` -> `isChain_cons`, `chain'_cons` -> `isChain_cons_cons`). Sweep the predicate
too, not just the lemmas: leaving `List.Chain'` in statements forces the new lemmas to see
through a deprecated semireducible `def`, which is the same failure mode all over again.


**Mathlib itself now ships `set_option backward.isDefEq.respectTransparency false`** in
`Order/SuccPred/Basic.lean`, corroborating research §5.1's transparency prediction upstream even
though it produced few errors here.

## Verification status

| Gate | State |
|---|---|
| `lake build` green | **No** — 5 errors, 1 file (`Kamp/ExteriorNegation.lean`) |
| Zero net new `sorry` | **Yes** — `git diff` of `Theories/` against the Phase 2 pin commit adds none |
| No new axioms | Yes — no `axiom` declarations added (count unchanged at 2, both in prose) |
| `(deterministic) timeout` errors | **Zero**, corpus-wide, including all four heaviest files |
| `set_option maxHeartbeats` sites | **88 — unchanged from baseline**; no budget raised |
| `backward.*` options added | **None** — `inventory/backward-options.md` is empty by construction |
| `lake test` | Not re-run (blocked on green build) |
| Executable output diff | Not run (Phase 8) |

## Where to resume

Full detail is in `handoffs/phase-5-handoff-1785045000.md`, which names the exact fix. Summary:

**5 errors in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean`, one root
cause.** The list literal `kvE2_futPossibleZones` is not type-correct at `implicit` transparency:
`Fin.cons`'s implicit motive is solved as `fun _ => Bool × Bool`, so its second argument is
expected at `Fin 3 → Bool × Bool` while `kvE2_sep_zPastX3 : ZoneSpec 3`. Every `simp`/`rcases`
step that traverses the list stalls. The fix is a `zoneCons` helper next to `ZoneSpec` in
`Kamp/NfEFold.lean` — the `orderedSumPt` pattern applied to `Fin.cons` at `ZoneSpec` — plus a
`@[simp] zoneCons_eq … := rfl` bridge for the goal side. The handoff gives the exact code and
lists what was already tried and rejected so it is not re-derived.

After that: Phase 6 closes as a verified no-op (re-run the timeout grep on the final green
build), Phase 7's residue is empty, and Phases 8-10 proceed as planned.

Re-run harness: `bash baseline/run-exes.sh <dir>` then
`bash baseline/compare-exes.sh baseline/exe <dir>` (validated: reports 0/12 differences between
two independent pre-upgrade captures).

## Plan Deviations

- **Phase 1, executable capture method** — altered. Used `lake env lean --run` (interpreter)
  instead of `lake exe`. `lake exe` needs a ~264 MB native link per target, requiring every module
  recompiled as `.c.o.export` at `-O3`; the 29 MB `Syntax/Formula.c` alone consumed 30 minutes of
  CPU and 3.9 GB RSS without finishing, and the set would have to be rebuilt post-flip. The 4.32
  `do` hazard this gate targets is an *elaboration* change, which the interpreter exercises
  identically. Uncovered by the substitution: native codegen and linking, checked separately via
  `lake build` of the exe targets rather than folded into this gate.
- **Phase 1, `SKIPPED.md`** — altered. No target was skipped, so there was nothing to name.
  `baseline/exe/REPRODUCIBILITY.md` gives the strictly stronger disclosure: gate strength per
  target, not just omissions.
- **Phase 1, executable invocations** — altered for `trace_exporter`, `tableau_bridge`,
  `tableau_proof_steps` (see "Findings" above).
- **Phase 2, `lake clean` ordering** — altered; `cache get` re-run after `clean` (see above).
- **Phase 3, taxonomy labels** — altered. All 12 planned labels retained and reported, plus two new
  rows (`mathlib-lemma-renames`, `subtype-proof-irrelevance`) that together account for 100% of
  observed errors. Forcing them into `unattributable` would have misreported attribution as lost
  when it is perfect.
- **Phase 3, D1 fallback trigger** — altered, and **flagged for reviewer attention**. Trigger 2
  (early abort) fires literally: only 123 of ~472 modules built. Proceeded single-jump anyway,
  because D1's stated rationale for staging is attribution (undegraded at 0% unattributable) and
  because staging does not cure an early abort — a 4.29 build stops at the same blocker. Reversal
  stays cheap: the Phase 2 pin commit is isolated.
- **Phase 3, effort re-estimate** — deferred. Wave 1 covered 123 of ~472 modules; writing Phase 4-7
  timings from it would be inventing a number, which is the exact failure the plan's "Effort
  estimate is provisional by design" section exists to prevent.
- **Phase 5** — partial, not complete. The phase's three pre-identified `isDefEq` call sites in
  `Automation/Tactics/Helpers.lean` never errored, and the two pre-identified sites in
  `ChronicleToCountermodelBasic.lean` were already green. The category is real but lands on
  semireducible *type* definitions rather than explicit `isDefEq` calls — recorded as new
  taxonomy rows N3-N6 in the inventory rather than forced into the planned labels.
- **Phase 5, `@[reducible]` escape hatch** — the plan directs "prefer marking it `@[reducible]`
  over applying a `backward.*` option". Applied to `k_equiv`; **deliberately not** applied to
  `orderedSum`, where it silently changes which order instance typeclass search selects. That
  negative result is documented in the plan and the inventory so it is not retried.
- **Phase 5, `@[reducible]` on `extendedStructure`/`extendedStructureWithMu`** — applied
  (third dispatch), after the plan's own guidance ("prefer marking it `@[reducible]` over
  applying a `backward.*` option") and against the instance-safety test above. Cleared 48 errors
  in one change; no previously-green module regressed. `@[reducible]` on `NormalForm`, flagged in
  the second dispatch as the remaining untried lever, was **not** applied — it proved
  unnecessary.
- **Phase 6** — executed out of order and reported as *measured*, not *completed*. The plan
  sequences 6 after 5, but the heavyweight files that dominate this category sat behind Phase 5
  blockers, so the measurement became available the moment they elaborated. It is recorded here
  rather than deferred, because a Phase 6 that finds nothing to do is a result worth stating.
  Formal closure still waits on a green build, per the phase's own verification block.
- **Phases 7-10** — not started; dispatch budget exhausted with all completed work committed and
  the single remaining blocker diagnosed in the handoff.

## Follow-up recommendations (not created here)

1. Re-enable the ~18 quarantined Plausible property tests under the inherited pin (plan D2).
2. Recurring cslib pin-sync check — cslib bumps roughly monthly and this pin will drift.
3. Meta task for the `skill-lean-version` backup/documentation defect (plan D3).
4. **New**: seed `IO.rand` from a CLI flag in the dataset/benchmark executables. Five of twelve
   produce irreproducible output, which permanently weakens any behavioral regression gate over
   them — this upgrade merely exposed a pre-existing testability gap.
