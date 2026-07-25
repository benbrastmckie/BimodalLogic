# Implementation Summary: Lean Toolchain Upgrade to v4.33.0-rc1

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Status**: PARTIAL — phases 1-4 of 10 complete, build not yet green
- **Plan**: `plans/01_lean-toolchain-upgrade.md`
- **Session**: `sess_1784959849_77d9d9`

## What landed

The repo is pinned to `leanprover/lean4:v4.33.0-rc1` + Mathlib `v4.33.0-rc1`, matching cslib
HEAD byte-for-byte. Pre-upgrade baselines are captured, the breakage is measured and categorized,
and the mechanical repair wave is done. **3 errors remain in 2 files**, down from 12.

| Phase | Status | Outcome |
|---|---|---|
| 1 Baselines | COMPLETED | Build/sorry/axiom/test/executable baselines at HEAD `e0158da5e` |
| 2 Pin flip | COMPLETED | Toolchain + Mathlib pinned; `cache get` gate passed |
| 3 Inventory | COMPLETED | 12 errors, fully categorized, 0 unattributable |
| 4 Mechanical repairs | COMPLETED | 12 -> 3 errors, no `sorry` added |
| 5-10 | NOT STARTED | See "Where to resume" |

Commits: `0a2afee82` (P1), `29b9cea6f` (P2), `7c8db8b12` (P3), `f091cc5f1` (P4).

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

**Mathlib itself now ships `set_option backward.isDefEq.respectTransparency false`** in
`Order/SuccPred/Basic.lean`, corroborating research §5.1's transparency prediction upstream even
though it produced few errors here.

## Verification status

| Gate | State |
|---|---|
| `lake build` green | **No** — 3 errors, 2 files |
| Zero net new `sorry` | **Yes** — 12 at baseline, 0 added (`git diff` of `Theories/` has no `sorry` additions) |
| No new axioms | Yes — no `axiom` declarations added |
| `lake test` | Not re-run (blocked on green build) |
| Executable output diff | Not run (Phase 8) |
| `backward.*` options added | **None** — `inventory/backward-options.md` would be empty |

## Where to resume

Remaining errors, all in Phase 5's category:

1. `Metalogic/WeakCanonical/NormalForm.lean:605` and `:608` — `rw [Fintype.card_fun]` fails to
   match `Fintype.card (AtomKind sig n → Bool)`. Lean's own note says the target "is not
   type-correct under the `implicit` transparency level", i.e. the `Fintype` instance left behind
   by `simp only [NormalForm, nfCount]` is not the canonical function-type instance `card_fun`
   expects. Substituting `simp` for `rw` makes it worse (`simp made no progress`) and was reverted;
   this needs the instance handled explicitly rather than a tactic swap.
2. `Metalogic/WeakCanonical/Kamp/VecEAClosure.lean:374` — "Application type mismatch", newly
   revealed once `VecEAFormula` was fixed. Not yet diagnosed.

Note that ~100 modules downstream of these two have still never been elaborated, including the
heartbeat-sensitive giants (`SharedWitness.lean` at 12,800 lines, `SuccChainFMCS.lean`,
`GapDetection.lean`, `SplitPoint.lean`). **The `heartbeat-timeout` row reading zero means
"unmeasured", not "clean"**, and remains the main cost risk in the plan.

Re-run harness: `bash baseline/run-exes.sh <dir>` then
`bash baseline/compare-exes.sh baseline/exe <dir>` (validated: reports 0/12 differences between two
independent pre-upgrade captures).

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
- **Phases 5-10** — not started; dispatch budget exhausted at a phase boundary with all completed
  work committed.

## Follow-up recommendations (not created here)

1. Re-enable the ~18 quarantined Plausible property tests under the inherited pin (plan D2).
2. Recurring cslib pin-sync check — cslib bumps roughly monthly and this pin will drift.
3. Meta task for the `skill-lean-version` backup/documentation defect (plan D3).
4. **New**: seed `IO.rand` from a CLI flag in the dataset/benchmark executables. Five of twelve
   produce irreproducible output, which permanently weakens any behavioral regression gate over
   them — this upgrade merely exposed a pre-existing testability gap.
