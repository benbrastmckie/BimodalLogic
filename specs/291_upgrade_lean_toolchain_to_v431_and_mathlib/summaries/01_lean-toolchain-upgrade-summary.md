# Implementation Summary: Lean Toolchain Upgrade to v4.33.0-rc1

- **Task**: 291 — upgrade_lean_toolchain_to_v431_and_mathlib
- **Status**: COMPLETE — all 10 phases closed. `lake build` green, `lake test` green,
  zero net-new `sorry`/axioms, executable outputs verified against baseline.
- **Plan**: `plans/01_lean-toolchain-upgrade.md`
- **Green build landed at**: `89fe8d0d4`

## Headline

| Gate | Result |
|---|---|
| `lake build` | **exit 0** — 1877 jobs, zero errors |
| `lake test` | **exit 0** — outcomes byte-identical to baseline (18 ✗ / 83 ✓, same set) |
| `(deterministic) timeout` | **0** on the final build and all twelve intermediate ones |
| Net new `sorry` | **0** (12 = baseline exactly, same four files) |
| New axioms | **0** |
| `set_option backward.*` | **0** |
| `set_option maxHeartbeats` sites | **88**, unchanged |
| Tier-1 executable outputs | **7 / 7 exact match** |
| Data products | **7 / 10 byte-identical by SHA256** |

## The pin that landed

| Component | Value |
|---|---|
| `lean-toolchain` | `leanprover/lean4:v4.33.0-rc1` |
| mathlib | rev `79d0395a1825`, `inputRev` `v4.33.0-rc1` |
| plausible | `b1c4a69a7e24`, **inherited** (no `require` in `lakefile.lean`) |
| batteries / aesop / Qq / proofwidgets / importGraph / LeanSearchClient / Cli | all inherited |

The task name says "v4.31" and the pin says `v4.33.0-rc1`. That is not drift — the target was
always "whatever cslib HEAD pins", and this matches cslib byte-for-byte. No `import Batteries`
anywhere in the tree.

## Repair volume — the honest answer to the plan's "~50-200 lines" question

The plan's research phase estimated 50-200 lines. The actual figure, measured as `git diff`
against the Phase 2 pin commit `29b9cea6f` restricted to `Theories/`, is **~775 insertions /
~393 deletions across 42 files** at the point Phase 5 closed, plus the later waves.

The estimate was low by roughly an order of magnitude, and the reason is structural rather than a
mis-count: the breakage concentrated in one subtree (`Metalogic/WeakCanonical/Kamp/`) whose proofs
lean heavily on `Fin.cons`/`ZoneSpec` definitional equality, and every such site broke the same
way at once.

| Category | Taxonomy rows | Share |
|---|---|---|
| Definitional equality / transparency (`Fin.cons`, `ZoneSpec`, projections, `dite` motives) | N4, N5, N7, N8, N14, N16 | dominant |
| Mathlib renames and deletions | N1, N3, N13, N17, N20 | second |
| `simp` no longer closing goals it used to | N10, N19 | small |
| `Decidable` instance synthesis | N15 | small |
| Heartbeat / elaboration budget | — | **zero** |

## The most valuable finding: `deriving Inhabited` now respects field defaults

**This is the finding that justifies Phase 8 existing**, and it is not the one the plan predicted.

```lean
structure Cfg where
  a : Nat := 5
  b : Nat := 2
  c : String := "hello"
  deriving Repr, Inhabited

#eval (default : Cfg)
-- v4.27: { a := 0, b := 0, c := "" }
-- v4.33: { a := 5, b := 2, c := "hello" }
```

Verified directly under the new toolchain with a `#guard_msgs` snippet, not inferred from release
notes.

`Automation/FormulaMutator.lean:1058` seeds CLI parsing with `go args default`. Under v4.27 every
field except the explicitly-passed `--max-complexity` was zero — and `maxFormulas = 0` made the
contrastive generator **enumerate nothing**. Under v4.33 the same invocation yields
`maxModalDepth=2, maxTemporalDepth=2, maxFormulas=1000` and 689 formulas.

The upgrade **fixed a latent bug**, silently, with a green build throughout — exactly the failure
mode Phase 8 was built to catch, arriving through a different mechanism than the one predicted.
`baseline/exe/contrastive.jsonl` records the *broken* behaviour and must not be treated as the
desired output.

Fifteen structures combine field defaults with `deriving Inhabited`. Only consumption through a
bare `default` changes behaviour (`{}` and `{ x with … }` always used the declared defaults):

| Site | Structure | Effect |
|---|---|---|
| `FormulaMutator.lean:1058` | `ContrastiveConfig` | **confirmed** (0 → 689 formulas) |
| `DatasetExport.lean:197-198` | `PatternKey`, `DifficultyMetrics` | `difficultyTier` `""` → `"unknown"` in timeout records |
| `DatasetGenerator.lean:231` | `DifficultyMetrics` | same |
| `Tests/…/ProofFirstTests.lean:186,190` | `DifficultyMetrics`, `PatternKey` | same, in fixtures |

## Phase 8: nested-`return` exposure is nil — the plan's risk assessment was inverted

The plan flagged Lean 4.32 (#13912) — `return e` inside `(← do …)` / `(← try … catch …)` now
early-returns from the *enclosing* `do` — and sized the exposure from raw counts: 12 IO-heavy exe
targets, 241 `let mut`, 15 `catch`, 10 `try`.

**Those counts are not the exposure.** `return` appears 338 times under `Automation/` alone, but
every one is inside a plain `do` block or a plain `try`/`catch` **statement**, where old and new
semantics agree. Only the nested-arrow position changed, and the repo uses it **twice** —
`DatasetGenerator.lean:1729` and `Deduction.lean:64` — neither containing a `return` in either
branch. Finding the second needs a two-line scan; a single-line `grep '← try'` misses it, because
the arrow ends one line and `try` opens the next.

`do match` has zero occurrences. The one `let pat := … | otherwise` site
(`Tactics/Helpers.lean:815`) throws in the `otherwise` branch, so the re-scoping change is
invisible there.

## Phase 6 closed as a *verified* no-op

The plan rated heartbeat breakage its second-highest cost risk, reasoning that a 20-50%
elaboration-cost increase landing on a corpus already at up to 64x the default budget would tip
many proofs over.

It did not happen. `grep -c '(deterministic) timeout'` returns **0** on the final green build
**and on every one of the twelve intermediate full builds** — a stable reading, not one lucky
run. No `maxHeartbeats` value was changed; the site count is still 88.
`inventory/heartbeat-changes.md` is empty by construction. All four files the plan named as
heaviest elaborated without incident, including `SharedWitness.lean` at 12,800 lines.

## Three metric corrections that outlive this task

**1. The module denominator is 262, not 430.** Earlier handoffs reported "N / 430". 430 counts
every `.lean` file under `Theories/`. Only **262** are in the default `lake build` target's import
closure; the other 168 — 89 under `Boneyard/`, plus the `Automation/` exe roots and their private
imports — are unreachable from the default target and never elaborated by `lake build`. Every
"N/430" figure in the phase-4 and phase-5 handoffs was against an inflated denominator. **Do not
re-derive progress from that base.**

**2. Neither the error count nor lake's `[N/1877]` marker measures progress.** 1877 is lake's job
counter for the whole graph, and the marker records where the scheduler stopped — it read
`1837/1877` both at 46 errors and at 5. The error count is worse than useless: `lake build`
aborts a failing module's dependents, so clearing a blocker *exposes* previously invisible modules
and the count goes **up**. It ran
12 → 3 → 54 → 26 → 39 → 59 → 15 → 4 → 13 → 48 → 46 → 7 → 5 → 20 → 10 → 6 → 14 → 6 → 6 → 8 → 5 →
14 → 4 → 6 → 4 → 0.

The usable proxy, discovered late and worth reaching for first next time, is the **job count of a
scoped `lake build <failing-module>`**. It rose monotonically 1055 → 1803 of ~1877 across the
final twelve waves and never once misled.

**3. `baseline/test-summary.txt` undercounts its own log.** It lists 14 failing test markers; the
baseline `test.log.gz` it was derived from contains 18. Compare against the log, not the summary.

## The shape of the tail: a deep import chain, not a wide frontier

The last twelve full builds each surfaced **one or two files**, every one of which had never been
elaborated under the new toolchain because it sat behind the previous wave:

| Wave | Errors / files | Files |
|---|---|---|
| 1 | 20 / 2 | `Kamp/ExteriorNegationPast`, `Expressiveness/SplitPoint` |
| 2 | 10 / 1 | `NfMultiAnchorBridge/ExteriorBracket` |
| 3 | 6 / 1 | `NfMultiAnchorBridge/ExteriorBracketK` |
| 4 | 14 / 3 | `ExteriorNegationK`, `ExteriorNegationPastK`, `InteriorGateGeneralK` |
| 5 | 6 / 1 | `NfMultiAnchorBridge/ExteriorGateAssembleK` |
| 6 | 6 / 1 | `NfMultiAnchorBridge/AggregateHookDischarge` |
| 7 | 8 / 1 | `ExteriorFiberKitK1` (+ `ExteriorNavFutK1`, same idiom, fixed pre-emptively) |
| 8 | 5 / 1 | `Kamp/KampPrior` |
| 9 | 14 / 1 | `IntegerModel/GoodStructuresModelSurgery` |
| 10 | 4 / 1 | `IntegerModel/ShiftAndGlue` |
| 11 | 6 / 1 | `WeakCanonical/Transfer` |
| 12 | 4 / 1 | `IntegerModel/ReynoldsBridge` |

Waves 2-8 needed **no new taxonomy row at all** — every repair reused N7/N10/N14/N16. New rows
only reappeared at wave 9, when the chain left the `Kamp/` subtree for `IntegerModel/`, which
draws on a different part of Mathlib's order API. That pattern is the most reliable
"are we converging?" signal available: **new rows mean new territory, not regression.**

Two exhaustion checks proved worth running before assuming another wave was coming:

1. **Grep for the failing idiom.** `simpa only [… Fin.cons]` — unfolding the `Fin.cons`
   *definition* rather than the `Fin.cons_zero`/`Fin.cons_succ` lemmas — had 9 hits in 2 files at
   wave 7 and **zero** after. That sub-family was genuinely finished, not deferred.
2. **Watch for new taxonomy rows.** Six consecutive waves without one meant the remaining work
   was mechanical.

## Rejected approaches, recorded so they are not retried

**`zoneCons` (specified by a prior dispatch, not landed).** The prescription was a `Fin.cons` at
the declared `ZoneSpec` type in `Kamp/NfEFold.lean` plus an `@[simp] zoneCons_eq` bridge. It does
not work: the bridge is needed because the goal side produces bare `Fin.cons` via
`Fin.cons_self_tail`, but as a `simp` lemma it rewrites the list literal straight back into the
untraversable form — `simp` stalls one step later instead of zero steps later. Stating it in
reverse does not help either; the LHS pattern is then exactly the term that fails to match at
reducible transparency. It also invalidates every module importing `NfEFold.lean`.

Replaced by local term-level membership certificates: `List.Mem` constructors for introduction,
`List.mem_cons.mp` chained as terms for elimination. `exact`/`apply` check at `default`
transparency, where `ZoneSpec` unfolds and the literal is well-typed, so no goal-side
normalisation is needed at all. Five lemmas per side, zero downstream blast radius. Full write-up
in inventory row **N16**.

**`@[reducible]` on `orderedSum`** — still rejected: fixes elaboration but silently changes which
order instance typeclass search selects (Mathlib's `Sigma.preorder` outranks `carrier_order`).

**`@[reducible]` on `NormalForm`** — flagged as the untried lever by an earlier handoff; proved
unnecessary. Every `NormalForm` failure yielded to `show … from` ascriptions and term-level lemma
application at far lower blast radius.

**`@[reducible]` on `extendedStructure` / `extendedStructureWithMu`** — accepted and landed;
cleared 48 errors in `StaviCompleteness.lean` in one change. The rule distinguishing it from the
`orderedSum` case is in inventory row N12 and in docstrings on the definitions.

## Compatibility-option debt: none

`inventory/backward-options.md` is empty because no such option was ever needed, not because the
sweep was skipped. Phase 10's "remove each option and rebuild" step is therefore vacuous.

The `sorry` count is **12, exactly the baseline**, in the same four files (`SuccRelation` 7,
`SuccExistence` 3, `ChronicleToCountermodel` 1, `Transfer` 1). The only difference against
`baseline/sorry-baseline.txt` is a 14-line offset on the `Transfer.lean` site, caused by comments
this task added above it.

Two greps need care, recorded so the next reader does not mis-count:

- `grep -rn '^axiom ' Theories/` returns 2 hits — both prose inside docstrings
  (`SuccChainFMCS.lean:1233`, `Discreteness.lean:40`), not declarations.
- The vacuous-definition grep returns `Examples/TemporalStructures.lean:269`
  (`int_domain_universal … := trivial`), pre-existing and untouched (last modified `21adc2281`).

## Phase 9: tests and axiom audit

`lake test` exits 0 after two test-file repairs, both in already-catalogued families:

- `DerivationTest.lean:226,239` — `simp at d_gen` now reports "made no progress" where it used to
  reduce `List.map` over a singleton. The forms remain definitionally equal, so `exact` closes it
  (N14).
- `ProofSearchTest.lean:113` — a `for` pattern over a list of tuples with unannotated numeric
  components now fails with *"the type of pattern variable 'depth' contains metavariables"*.
  Annotating the literals as `Nat` fixes it.

**Test outcomes are identical to baseline**: 18 failing and 83 passing markers, the same set line
for line. The 18 pre-existing failures (`temp_l`, `temp_k`, `temp_future`, `temp_4`, and the four
`G`-iteration cases) all predate this upgrade.

All four `#print axioms` outputs are **byte-identical to `baseline/axioms.txt`**:

```
completeness_dense      [propext, Classical.choice, Quot.sound]
completeness_discrete   [propext, Classical.choice, Quot.sound]
completeness            [propext, sorryAx, Classical.choice, Quot.sound]
countermodel_dense      [propext, Classical.choice, Quot.sound]
```

Prose verified rather than assumed:

- `Metalogic/Metalogic.lean:57` — **accurate**; no `ofReduceBool`/`trustCompiler` anywhere in the
  build output.
- `BXCanonical/Completeness.lean:386,390` — **accurate**; `SignedFormula.lean` has exactly 4
  `native_decide` sites (`:126,132,133,138`), outside the completeness cone.
- `Automation/Tactics/PropDecide.lean:21,80` "never emits `native_decide`" — **checked, not
  trusted**: `PropDecide.mkIsTautProof` elaborates `by decide` against `PropForm.isTaut f = true`,
  kernel-only.

**New finding, no assertion affected.** Lean 4.29 changed `native_decide` to emit one axiom per
computation instead of the shared `Lean.trustCompiler`. `Sign.eq_of_beq` now reports
`…_native.native_decide.ax_1_1` / `ax_1_2` where it previously reported `Lean.ofReduceBool`.
Nothing breaks — those sites are outside the completeness cone and no assertion covers them — but
the *shape* of the axiom footprint changed.

## Follow-up recommendations (not created as tasks here)

1. **Replace the 4 `native_decide` sites in `Decidability/SignedFormula.lean` with `decide`.**
   `Sign` has two constructors; kernel `decide` handles it. Removes two generated axioms from the
   decidability path.
2. **Audit the remaining `default`-seeded config sites.** The `deriving Inhabited` change fixed
   `contrastive_generator` by accident; the `difficultyTier` `""` → `"unknown"` flip in emitted
   JSONL is a real data-format change downstream consumers should know about.
3. **Fix the two Phase 8 harness defects** (see `inventory/exe-diff.md`): `run-exes.sh` needs the
   exe roots' olean closures built first — a green `lake build` does **not** imply they are
   runnable — and `normalize.sh` only masks output paths under directories literally named
   `exe`/`exe-run2`/`exe-post`.
4. **Correct `baseline/test-summary.txt`**, which undercounts its own log (14 vs 18).
5. **Re-enable the ~18 quarantined Plausible property tests** under the inherited pin (plan D2).
6. **Recurring cslib pin-sync check** — cslib bumps roughly monthly and this pin will drift.
7. **Meta task for the `skill-lean-version` backup/documentation defect** (plan D3).
8. **Consider migrating the ~30 deprecated `push_neg` call sites to `push Not`.** Warnings only.

## The one verification item left open

`lake clean && lake exe cache get && lake build` from scratch was **not** executed. A clean
rebuild of this corpus is a multi-hour job, and the incremental full build that gates every other
claim here was run to convergence twelve times and is green.

**Residual risk**: a stale-artifact dependency — a green build resting on an `.olean` whose source
no longer produces it — would not be detected. The risk is low, because the final green build
followed source edits to eighteen files and lake rebuilt their entire dependent closure each time,
but it is non-zero and is recorded rather than papered over.
