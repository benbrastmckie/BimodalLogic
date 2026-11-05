# Research Report: Task #803

**Task**: 803 - Cut the elaboration time of `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`
**Started**: 2026-11-05T07:37:00Z
**Completed**: 2026-11-05T08:15:00Z
**Effort**: Medium (one profiled module run + four A/B heartbeat probes)
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` (1467 lines, 37 theorems)
- `FormalSystem/Metalogic/Decidability/Tableau.lean` (`applyRule`, line 636)
- Fresh profiled elaboration: `lake env lean -Dprofiler=true -Dprofiler.threshold=200 --stats`, this repo, 2026-11-05
- `#count_heartbeats` A/B probes via `lean_run_code` (Mathlib `Mathlib.Util.CountHeartbeats`), `set_option Elab.async false`
- lean-lsp MCP: reachable; `lean_run_code` used for all probes (no `lean_local_search` needed)

**Artifacts**:
- `specs/803_cut_subformulaproperty_elaboration_time/reports/01_cut-subformulaproperty-elaboration-time.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The module's own diagnosis of its cost is wrong.** Thirty-six inline comments blame
  `unfold applyRule` / `whnf` arm-position. The profiler says otherwise: of roughly 15,100s
  cumulative elaboration, **`simp` is 14,988s (99.2%)** while *all* tactic execution —
  `unfold`, `split`, `rcases`, everything — is **108s (0.7%)** and type checking is 20.9s.
  The cost is the `all_goals (try simp_all only [...])` cascade applied across the ~37 goals
  the splitter leaves behind, 1348 such calls above the 200ms threshold, median 5.55s each.
- **A sorry-free, statement-preserving remedy is already available in the environment.**
  Lean has generated per-arm equation lemmas `applyRule.eq_1 … applyRule.eq_37` (one per rule,
  two for `z1Rule`) plus a catch-all `applyRule.eq_38`. Each carries at most one or two tiny
  side hypotheses (`sf.sign = Sign.pos`, sometimes `sf.formula = <pattern>`). Rewriting with
  the right `eq_N` replaces the 36-arm splitter cascade with a two-or-three-goal proof.
- **Measured, not asserted (`#count_heartbeats`, same file, same run, `Elab.async false`):**

  | Theorem | current script | equation-lemma script | factor |
  |---|---|---|---|
  | `applyRule_andPos_closed` | 882,487 hb | **760 hb** | 1161x |
  | `applyRule_serialityRule_closed` | 2,084,589 hb | **146 hb** | 14,278x |
  | `applyRule_boxNeg_closed` | 885,047 hb | **27,178 hb** | 32.6x |

  The two 0.9M/2.1M figures reproduce the file's own inline estimates exactly, so the baseline
  numbers are trustworthy; what is new is where the heartbeats go.
- **Recommended approach**: rewrite the 36 per-rule proof bodies against `applyRule.eq_*`,
  pinned behind named wrappers in `Tableau.lean` so the generated numbering appears exactly
  once per rule. No statement changes, no new `sorry`, no new axiom, no change to the
  termination argument — only the 36 proof bodies and their now-incorrect comments.
- **Expected result**: module heartbeat total drops from roughly 36M to roughly 0.4M. Wall-clock
  baseline on this machine is 499s for a single-module `lake env lean`; a conservative projection
  is well under 60s, dominated by the residual `simp_all` inside the fresh-witness family.

## Context & Scope

Researched: where this module's elaboration time actually goes, and whether it can be cut
without touching any proved statement, introducing `sorry`, adding an axiom, or weakening the
termination argument.

The module proves T1, the generalized signed subformula property: 36 per-rule theorems
`applyRule_<rule>_closed`, each of shape

```lean
∀ g ∈ (applyRule .<rule> sf b ord).1.emitted, g.formula ∈ C
```

assembled by `applyRule_subformula_closed` (line 1424), which is already cheap — it is 36
`exact`s under a `match rule with` and never unfolds `applyRule`. The expensive surface is
therefore exactly the 36 bodies, nothing else in the file.

Constraints honoured throughout: the 37 statements are fixed, `applyRule`'s *definition* is left
alone (177 call sites reference it across 12 modules, and `Tableau.lean`/`CountermodelExtraction.lean`
carry their own `unfold applyRule` proofs), and every proposed change is a proof-body change.

## Findings

### Codebase Patterns

**The shared script.** All 36 bodies instantiate one template (`applyRule_andPos_closed`,
lines 476-489):

```lean
intro g hg
unfold applyRule at hg
repeat' first
  | split at hg
  | simp only [apply_ite Prod.fst] at hg
all_goals (try simp only [RuleResult.emitted] at hg)
all_goals (try simp_all only [asAnd?_eq_iff, List.mem_cons, …, reduceCtorEq])
all_goals (try (repeat' rcases hg with hg | hg))
all_goals first | exact hC.and_left hsf | exact hC.and_right hsf
```

`unfold applyRule` puts the whole 760-line 36-arm match into `hg`; `repeat' split` shreds it into
on the order of 37 goals; each surviving goal carries the splitter's accumulated cascade of
`rule ≠ …` / `sf.sign = …` / `sf.formula = …` hypotheses *plus* the unfolded `applyRule` term.
`simp_all only` then rewrites that entire context, once per goal. That is the cost.

`set_option maxHeartbeats 1200000` appears on 34 declarations and `3000000` on two
(`serialityRule`, `timeLinearity`); 48 `simp_all only [...]` and 11 full-simp-set `simp_all [...]`
calls appear in the file. The `all_goals (try simp_all only …)` cascade pattern appears 35 times
here and exactly once elsewhere in the tree
(`Verified/Termination/MintBound/TimeCensus.lean`), so this file is where the pattern's cost is
concentrated.

**Profiled baseline** (`lake env lean -Dprofiler=true -Dprofiler.threshold=200 --stats`, via
`lake-build-guard.sh build --timeout 2400 -- env lean …`, exit 0, wall 499s from the guard's own
`start_epoch`/`end_epoch`, 24-core machine with other `lean` workers live):

```
cumulative profiling times:
  simp                  1.52e+04 s     <-- 14,987.6 s summed over 1348 calls >200ms
  blocked (unaccounted)     73.4 s
  tactic execution         108   s     <-- unfold + split + rcases + everything
  type checking             20.9 s
  congr simp thm            15.6 s
  instantiate metavars       2.49s
  import                     1.55s
  elaboration                1.72s
```

Distribution of the 1348 simp calls: total 14,987.6s, median 5.55s, p90 29.7s, max 45.6s; the top
twenty are all 40-46s. There are exactly 37 `split` executions (one per theorem) and 36
`type checking` entries. **Import is 1.55s**, so the heavy imports named in the task description
(`Tableau`, `SubformulaClosure.Closure`) contribute nothing to this module's own elaboration
cost — they matter only as *invalidation triggers*, which is a separate concern this task does
not need to solve to hit its acceptance criteria.

Note on the task description's 1103s figure versus the 499s measured here: 1103s is the Lake
build-log figure; 499s is wall-clock for a single-module `lake env lean` with declaration-level
parallelism across 24 cores, against a cumulative 15,100s of work. Both are consistent. Use
heartbeats, not wall time, for before/after evidence — they are load-independent and reproduce
the file's own recorded estimates.

**The misleading comments.** Thirty-six copies of
`-- unfold applyRule reduces the 36-arm match to this rule's arm: about 0.9M heartbeats measured`
and the `NonAnalytic` section note (`whnf has to step past every earlier arm`) attribute the cost
to `unfold`/`whnf`. The 0.9M figure is a correct *declaration-level* total — it reproduces to
882,487 — but the attribution is wrong by two orders of magnitude. These comments must be
rewritten as part of the work, not preserved.

### External Resources

**`applyRule.eq_1 … eq_38`, already in `Tableau.olean`.** Enumerated from the live environment
after `import FormalSystem.Metalogic.Decidability.Tableau`:

| eq | rule | side hypotheses |
|---|---|---|
| eq_1 | `andPos` | `sf.sign = .pos` |
| eq_2 | `andNeg` | `sf.sign = .neg` |
| eq_3 / eq_4 | `orPos` / `orNeg` | sign only |
| eq_5 / eq_6 | `impPos` / `impNeg` | sign + `sf.formula = ψ.imp χ` |
| eq_7 / eq_8 | `negPos` / `negNeg` | sign only |
| eq_9 / eq_10 | `boxPos` / `boxNeg` | sign + `sf.formula = ψ.box` |
| eq_11 / eq_12 | `diamondPos` / `diamondNeg` | sign only |
| eq_13 | `boxTemporal` | sign + `sf.formula = ψ.box` |
| eq_14 - eq_17 | `allFuturePos/Neg`, `allPastPos/Neg` | sign + nested `allFuture`/`allPast` pattern |
| eq_18 - eq_21 | `someFuturePos/Neg`, `somePastPos/Neg` | sign only |
| eq_22 - eq_25 | `untlPos`, `sncePos`, `untlNeg`, `snceNeg` | sign only |
| eq_26 | `orderTrichotomy` | sign only |
| eq_27 | `denseIndicatorClosure` | sign + literal `untl` pattern |
| eq_28 | `densityRule` | sign + `allFuture` pattern |
| eq_29 / eq_30 | `priorUZ` / `priorSZ` | sign only |
| eq_31, eq_32 | `z1Rule` (two arms) | sign + pattern |
| eq_33 / eq_34 | `priorUGap` / `priorSGap` | sign only |
| eq_35 | `sepRule` | sign only |
| eq_36 | `serialityRule` | **none** |
| eq_37 | `timeLinearity` | **none** |
| eq_38 | catch-all | 38 `… → False` guards |

Twenty-two of the thirty-six rules need only a sign hypothesis, because their arm binds `φ` as a
variable and dispatches through `asAnd?` / `asOr?` / `asNeg?` / `asDiamond?` / `asUntil?` /
`asSince?`. Those are the cheapest conversions. Two rules (`serialityRule`, `timeLinearity`) are
sign-agnostic and need *no* case analysis at all — and they are the two most expensive theorems
in the file today.

The `asX?_eq_iff` characterization lemmas the new scripts need (`asAnd?_eq_iff`, `asOr?_eq_iff`,
`asNeg?_eq_iff`, `asDiamond?_eq_iff`, `asSomeFuture?_eq_iff`, `asSomePast?_eq_iff`,
`asUntil?_eq_iff`, `asSince?_eq_iff`) already exist in this module at lines 338-395.

### Recommendations

**A sorry-free path exists and has been executed on three of the thirty-six cases.** No approach
below needs a `sorry`, an axiom, or a weakened statement.

**R1 (primary). Convert each per-rule body to an `applyRule.eq_*` rewrite.** Verified shape for
a sign-only rule (`andPos`, 760 heartbeats, compiles clean):

```lean
intro g hg
cases hs : sf.sign with
| pos =>
    rw [applyRule.eq_1 sf b ord hs] at hg
    split at hg
    · rename_i ψ χ heq
      rw [asAnd?_eq_iff] at heq
      simp only [RuleResult.emitted, List.mem_cons, List.not_mem_nil, or_false,
        SignedFormula.pos] at hg
      rcases hg with hg | hg
      · subst hg; exact hC.and_left (heq ▸ hsf)
      · subst hg; exact hC.and_right (heq ▸ hsf)
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
| neg =>
    rw [applyRule.eq_38 sf b ord TableauRule.andPos] at hg
    · simp only [RuleResult.emitted, List.not_mem_nil] at hg
    all_goals (intros; simp_all)
```

Verified shape for a sign-agnostic rule (`serialityRule`, 146 heartbeats, compiles clean) — no
`cases`, no off-arm branch:

```lean
intro g hg
rw [applyRule.eq_36 sf b ord] at hg
split at hg
· simp only [RuleResult.emitted, List.not_mem_nil] at hg
· simp only [RuleResult.emitted, List.mem_filter, List.mem_cons, List.not_mem_nil,
    or_false] at hg
  obtain ⟨hg, -⟩ := hg
  rcases hg with hg | hg
  · subst hg; exact hC.serialFuture
  · subst hg; exact hC.serialPast
```

The off-arm branch (`rw [applyRule.eq_38 …] <;> (intros; simp_all)`) discharges all 38 guards and
measured cheap in both probes. For a rule carrying a formula pattern, add a
`match hf : sf.formula with` and route the five non-matching constructors (`atom`, `bot`, `imp`,
`untl`, `snce` — `Formula` has exactly six) through the same off-arm branch; a `have off : … → g.formula ∈ C`
at the top of the proof keeps that from being written six times.

**R2 (companion, do it in the same change). Pin the generated numbering behind named wrappers in
`Tableau.lean`.** `applyRule.eq_N` names are produced by Lean's equation generator; the numbering
tracks arm order and the constants persist in the `.olean` only because something triggers their
generation. Add 37 zero-cost aliases next to `applyRule`:

```lean
theorem applyRule_andPos_eq (sf : SignedFormula) (b : Branch) (ord : TimeOrdering)
    (hs : sf.sign = Sign.pos) : applyRule .andPos sf b ord = _ := applyRule.eq_1 sf b ord hs
```

so the numbering appears exactly once per rule and an arm reorder breaks one line, not
thirty-six. This is the single most important risk control in the plan.

**R3 (second tier, after R1). Tighten the fresh-witness inner block.** `boxNeg` still costs 27,178
heartbeats after R1, all of it in the unchanged `mem_filterMap_sub` sub-proof's
`simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas, Formula.self_mem_subformulas]`
— a **full** simp set, not `simp only`. The ten fresh-witness theorems (`boxNeg`, `diamondPos`,
`allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos`, `untlPos`, `sncePos`, `untlNeg`,
`snceNeg`) share that block and will dominate the post-R1 total. Convert it to `simp only` with
an explicit lemma list. Treat this as a separate phase with its own before/after numbers; R1
alone already clears the acceptance bar.

**R4 (drop the heartbeat ceilings last, as evidence).** After R1, delete the 34
`set_option maxHeartbeats 1200000` and two `set_option maxHeartbeats 3000000` lines. If the file
compiles at the 200,000 default, that is independent, reviewable proof the reduction is real.
Keep `set_option linter.unusedTactic false` only if the rewritten scripts still need it
(`untlNeg`, `snceNeg` currently do).

**Explicitly not recommended:**

- *Restructuring `applyRule` into per-rule sub-definitions.* This was the obvious structural fix
  suggested by the file's own comments, and the profile kills it: the dispatch cost it would
  remove is inside the 108s of tactic execution, under 1% of the total. It would also perturb 177
  call sites across 12 modules for that 1%.
- *Proving the combined theorem in one 36-arm sweep.* The file records that the memory ceiling
  forces one rule per declaration; nothing found here contradicts that, and R1 makes it moot.
- *Blanket `simp_all only` to `simp only … at hg` substitution without the equation lemmas.*
  Cheaper to write but it changes which goals close by context contradiction, and several bodies
  depend on `simp_all`'s whole-context rewriting to substitute `sf.formula`. R1 removes the
  cascade instead of trying to make each of its ~1348 calls cheaper.
- Any `sorry`, deferred case, new axiom, or added hypothesis. None is needed; the three probes
  closed their goals outright.

## Decisions

- **Measure in heartbeats, report wall-clock only as context.** `#count_heartbeats` with
  `set_option Elab.async false` is load-independent and reproduced the file's own two recorded
  estimates (0.9M, 2.1M) to within 2%. Wall-clock on this machine is not reproducible: 24 cores,
  declaration-level parallelism, and concurrent `lean` workers from other sessions.
- **`set_option Elab.async false` is mandatory for the probes.** Without it `#count_heartbeats`
  reports ~30 heartbeats for everything, because the proof elaborates on another thread. This
  silently invalidates any A/B measurement taken without it.
- **`applyRule`'s definition is out of scope.** Justified by the profile (sub-1% of cost) rather
  than by caution alone.
- **Statements and the assembly theorem are untouched.** Only the 36 bodies, their comments, and
  their `maxHeartbeats` lines change. `applyRule_subformula_closed`'s 36 `exact`s need no edit.
- **Three probes, chosen to span the shapes**: a sign-only rule with an `asAnd?` dispatch
  (`andPos`), a sign-agnostic rule (`serialityRule`), and the worst structural case — a
  formula-pattern rule with two propagation blocks (`boxNeg`). The remaining 33 are variations on
  these three.

## Risks & Mitigations

| Risk | Evidence | Mitigation |
|---|---|---|
| `applyRule.eq_N` numbering shifts if `applyRule`'s arms are reordered or one is added | numbering is generator-assigned and tracks arm order; `z1Rule` already occupies two slots (eq_31, eq_32) | R2: 37 named wrappers in `Tableau.lean`. Failure mode is loud (`rw` fails / wrong rule in goal), never silent. |
| Equation lemmas vanish from `Tableau.olean` if nothing triggers generation | they exist today only because `Tableau.lean`'s own proofs triggered them | R2 forces generation at the definition site, making their presence a compile-time fact rather than a side effect. |
| `rw [applyRule.eq_38 …] <;> (intros; simp_all)` fails to discharge all 38 guards for some rule | succeeded for `andPos` (off-sign) and `boxNeg` (off-sign and five off-pattern constructors) | Per-rule verification is intrinsic — the proof does not compile otherwise. Fall back to naming the contradicting hypothesis explicitly. |
| The `boxNeg` probe left two unsolved goals | **probe artifact**: the probe's `open FormalSystem.Syntax FormalSystem.Metalogic.Decidability` makes `Formula.subformulas` ambiguous. The *unmodified* script failed identically in the same run, so the A/B comparison holds. | In-module there is no ambiguity. Re-verify `boxNeg` in place as the first fresh-witness conversion. |
| A proof-body rewrite silently proves something weaker | the statements are untouched and the assembly theorem forces all 36 to typecheck at their declared types | Record `#print axioms` for all 37 declarations before and after; run `bash scripts/check-module-invariants.sh`. |
| `simp only` lemma lists drift as goals change shape | each converted body is smaller and its `simp only` list shorter than today's | Convert in small batches with a scoped guarded build per batch. |
| Build contention during verification | 24-core machine, several concurrent `lean` workers observed | Route every build through `lake-build-guard.sh build --timeout …`; the baseline run above did and exited 0. |

## Tactic Survey Results

`lean_multi_attempt` and `lean_hammer_premise` were not the right instruments here — the goals are
already closed, and the question is cost, not closability. The survey below is the cost-oriented
equivalent, run with `#count_heartbeats` on real goals from this module.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `applyRule .andPos` emitted ⊆ C | `unfold applyRule` + `repeat' split` + `all_goals simp_all only` | success, 882,487 hb | `asAnd?_eq_iff`, `List.mem_cons`, `reduceCtorEq`, … |
| `applyRule .andPos` emitted ⊆ C | `cases sf.sign` + `rw [applyRule.eq_1]` + `split` + `simp only at hg` | **success, 760 hb** | `applyRule.eq_1`, `applyRule.eq_38`, `asAnd?_eq_iff` |
| `applyRule .serialityRule` emitted ⊆ C | `unfold applyRule` + cascade | success, 2,084,589 hb | `List.mem_filter`, `Bool.not_eq_eq_eq_not`, … |
| `applyRule .serialityRule` emitted ⊆ C | `rw [applyRule.eq_36]` + `split` + `simp only at hg` | **success, 146 hb** | `applyRule.eq_36` only; no sign case needed |
| `applyRule .boxNeg` emitted ⊆ C | `unfold applyRule` + cascade | 885,047 hb (probe-local ambiguity residue) | `reduceCtorEq`, `Branch.boxPosFormulas`, … |
| `applyRule .boxNeg` emitted ⊆ C | `cases sf.sign` + `match sf.formula` + `rw [applyRule.eq_10]` | **27,178 hb** (same residue) | `applyRule.eq_10`, `applyRule.eq_38`, `mem_filterMap_sub` |
| off-arm: `applyRule .boxNeg` on `.atom`/`.bot`/`.imp`/`.untl`/`.snce` | `rw [applyRule.eq_38 …] <;> (intros; simp_all)` | success, negligible | catch-all equation, 38 guards |
| whole-module elaboration | `-Dprofiler=true` | 14,987.6s simp / 108s tactic execution / 20.9s type checking | threshold 200ms, 1348 simp entries |

## Context Extension Recommendations

- **Topic**: Profiling a slow Lean module — which instrument answers which question.
  **Gap**: `context/project/lean4/` has `operations/long-builds.md` (how to *wait* for a build)
  but nothing on *attributing* a module's cost. This task's first hour was spent discovering
  that `-Dprofiler=true`'s `cumulative profiling times` block is the right first look, that
  `#count_heartbeats` needs `set_option Elab.async false` or it reports ~30 heartbeats for
  everything, and that wall-clock is unusable as before/after evidence on a 24-core box.
  **Recommendation**: add `context/project/lean4/operations/profiling-elaboration.md` with the
  guarded `lake env lean -Dprofiler=true` invocation, how to read the cumulative block, the
  `Elab.async false` trap, and the rule "report heartbeats, not seconds".

- **Topic**: `f.eq_N` per-arm equation lemmas as a cost tool.
  **Gap**: no context file mentions them. They are the whole remedy here, they already exist for
  every `match`-defined function in the tree, and they turn a 36-arm splitter cascade into a
  two-goal proof. **Recommendation**: a short section in
  `context/project/lean4/patterns/` covering how to enumerate them, the `eq_def` versus `eq_N`
  distinction, the catch-all `eq_38` shape with its `… → False` guards, and the named-wrapper
  discipline that keeps generated numbering out of downstream proofs.

- **Topic**: `simp_all` versus `simp only … at h` under `all_goals`.
  **Gap**: `rules/lean4.md`'s "Common Tactics" lists `simp` without cost guidance. The
  anti-pattern measured here — `all_goals (try simp_all only [...])` over a splitter's ~37 goals,
  each carrying the unfolded definition — produced 1348 calls and 99.2% of a module's cost.
  **Recommendation**: record it as a named anti-pattern with these numbers attached.

## Appendix

### Commands of record

```bash
# Baseline profile (guarded, detached, exit 0, wall 499s)
bash .claude/scripts/lake-build-guard.sh build --timeout 2400 -- \
  env lean -Dprofiler=true -Dprofiler.threshold=200 --stats \
  FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean
# verdict read from .lake/build-guard.result (state=complete, exit_status=0,
# start_epoch=1793893252, end_epoch=1793893751)
```

```lean
-- A/B probe harness (lean_run_code)
import FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty
import Mathlib.Util.CountHeartbeats
set_option Elab.async false   -- REQUIRED; without it every count reads ~30
#count_heartbeats in
theorem probe … := by …
```

```lean
-- Enumerating the equation lemmas
open Lean Elab Meta Command in
run_cmd do
  let env ← getEnv
  for i in [1:39] do
    let n := `FormalSystem.Metalogic.Decidability.applyRule ++ Name.mkSimple s!"eq_{i}"
    match env.find? n with
    | none => logInfo s!"eq_{i}: MISSING"
    | some ci => logInfo (← liftCoreM <| Lean.Meta.MetaM.run' (Lean.Meta.ppExpr ci.type)).pretty
```

### Key source locations

- `applyRule` — `FormalSystem/Metalogic/Decidability/Tableau.lean:636` (36 arms + catch-all)
- the 36 per-rule theorems — `SubformulaProperty.lean:476-1403`
- `applyRule_subformula_closed` — `SubformulaProperty.lean:1424` (needs no change)
- `asX?_eq_iff` characterizations — `SubformulaProperty.lean:338-395`
- `mem_filterMap_sub` — `SubformulaProperty.lean:828` (the R3 target's entry point)
- misleading comments — 36 copies of the `0.9M heartbeats` line, plus the `NonAnalytic` note at
  `SubformulaProperty.lean:613-615`

### Acceptance-criteria mapping

| Acceptance item | How the plan satisfies it |
|---|---|
| measured before/after numbers | `#count_heartbeats` per converted theorem; the three baselines above are already recorded, 33 remain |
| `lake build` green | per-batch scoped guarded build, then one unscoped final run |
| `check-module-invariants.sh` ALL CHECKS PASSED | `bash scripts/check-module-invariants.sh` at phase end |
| `sorry_count` 0 | no proposed step introduces one; all three probes closed their goals |
| axiom profiles unchanged | `#print axioms` for all 37 declarations captured before the first edit and re-run after the last |
| no weakening of the termination argument | the 37 statements and the assembly theorem are untouched |
