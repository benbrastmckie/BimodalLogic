# Research Report: Task #739

**Task**: 739 - E2 depth two stratification shared stratum falsifier
**Started**: 2026-10-08T20:07:30Z
**Completed**: 2026-10-08T20:52:00Z
**Effort**: ~45 minutes research; implementation estimate 1-2 dispatches (one probe file, ~450-600 lines)
**Dependencies**: None (the landed `stab-depth-two-probe.lean` is read, never edited; no substrate module is touched)
**Sources/Inputs**:
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` (the landed E2 probe, baseline compiled green this session through the build guard, 9/9 axiom lines at `[propext, Classical.choice, Quot.sound]`)
- `specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean` (Probe 718: `stratum M χ w`, `plusTruthAt_iff_stratum_atomize`)
- `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` (Probe 719: backward-step technique)
- `FormalSystem/PlusLanguage/PlusTruth.lean` (`PlusTruthAt`, `PlusTruth.stab_iff`, `stab_state_only`)
- `FormalSystem/Semantics/SlicedFrame.lean` (`FrameOver.ofSlicedStep`, `ofSlicedStep_step`, `ofSlicedStep_isRegular`)
- `FormalSystem/Semantics/IntNormalForm.lean` (`FrameOver.worldHistoryOfStepPath`)
- `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` (`Encoding`, `atomize`, `TaskModel.atomModel`, `plusTruthAt_iff_atomize`)
- `specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md` (the ranking's falsifier sentence, R1 probe 1)
- `specs/711_universal_summary_substrate_stab_fibre/plans/02_buechi-chain-ktype-substrate.md` (E2's definition, Decision D-13)
- `scripts/check-evidence-probes.sh` (the `WIRED` array and probe table)
- lean-lsp `lean_run_code` (two iterations of a standalone fixture skeleton; final run `success: true`)
- A 40-line CTL-style least-fixpoint script (scratchpad) confirming every value table below
- No literature source is cited by the task; the Literature Extraction Protocol does not apply
**Artifacts**: - `specs/739_e2_depth_two_stratification_shared_stratum_falsifier/reports/01_shared-stratum-falsifier.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The falsifier exists, and it is cheap.** Read literally — as the landed probe's
  `value_is_function_of_stratum` reads it, with hypothesis "equal `⊡Fp` value" — the claim
  "a depth-2 `⊡`-value is a function of the depth-1 stratum" is **refuted** on every fixture with
  three or more states that was examined. A single four-state fixture (`a`, `b`, `c`, `d`; edges
  `a→a, a→b, b→b, b→d, d→b, c→c`; `p` at `b` only) refutes it on the landed forward shape
  `⊡(Fp → ⊡Fp)` (pair `a`,`c`, both `⊡Fp` False), on the mixed shape `⊡(Fp → ⊡Pp)` (pairs
  `a`,`c` and `b`,`d`), and on the past-mirror shape `⊡P(⊡Fp)` (pair `b`,`d`, both `⊡Fp` True).
- **Two shapes survive, non-vacuously.** `⊡F(⊡Fp)` is a function of `⊡Fp` on both shared classes,
  and `⊡(Pp → ⊡Fp)` is True everywhere. The landed shape `⊡(Fp → ⊡Fp)` survives on the shared-True
  class `{b, d}` and fails only on the shared-False class `{a, c}`. These are the genuine
  (non-vacuous) upgrades of E2 the task asked for, and they stand alongside the refutations.
- **The refutation core already compiles.** A standalone `lean_run_code` skeleton (Appendix A)
  builds the carrier, the bi-serial relation, the `ofSlicedStep` frame with its `IsRegular`
  instance, three constructed histories, and proves `⊡Fp` True at `b` and `d`, `⊡Pp` True at `d`
  and False at `b`, and `⊡(Fp → ⊡Pp)` **False at `b`, True at `d`** — the refutation on a shared
  stratum — every theorem at exactly `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- **What it means for the finite per-time alphabet, stated honestly.** The refutation kills the
  reading on which a depth-2 `⊡`-value is determined by the *one bit* `⊡Fp` at the state. It does
  not touch the reading Probe 718 actually licenses: the value is a function of the **state**
  (`stab_state_only`, unchanged) and the alphabet is indexed per `⊡`-subformula `χ`
  (`stratum M χ w`), one label per `⊡`-subformula of the target's closure. On the recommended
  fixture the labels `⊡Fp`, `⊡Pp`, `⊡¬Fp` (= "no path hits `p`") are mutually independent and all
  three are needed to read off the five depth-2 shapes. Nothing here bounds width, period, or
  anything per time: the fixture is time-independent, so every time slice is the same four
  states, and the probe says nothing about per-time summaries of *many* states.
- **The "divergence" the task flags cannot happen.** `plusTruthAt_iff_atomize` (outer `⊡`
  atomized) and the `via_strata` theorems (inner `⊡` read through the depth-1 stratum) are both
  biconditionals with the *same* direct value, and the `via_strata` proofs are fixture-independent
  (they use only `stab_fp_iff_fresh`, the `atomModel` `inr` clause and the clause lemmas). The plan
  should not reserve a phase for a divergence investigation; it should instead restate the
  `via_strata` theorems verbatim for the two new inner formulas (`⊡Pp` needs a twin
  `stab_pp_iff_fresh`, same proof).
- **Recommended outcome**: one new probe file `stab-depth-two-shared-stratum.lean` on the
  four-state fixture, five depth-2 shapes computed directly and through the strata, a
  `value_is_function_of_stratum` theorem for the two surviving shapes and explicit
  `not_function_of_stratum_*` refutation theorems for the three failing ones, wired append-only
  into `scripts/check-evidence-probes.sh`. A refutation is the headline; the surviving shapes are
  the non-vacuous positive.

## Context & Scope

**The question.** The ranking's falsifier for the stratification route (R1 probe 1,
`02_ranked-route-analysis.md`) reads: "a depth-2 formula whose `⊡`-value at a class is not a
function of the class's automaton state". E2 (Decision D-13 of the 711 plan v2) operationalized
"summary state" as the depth-1 stratum bit `⊡Fp` at the state, and its check theorem
`value_is_function_of_stratum` takes as hypothesis `PlusTruthAt Mg τ t (.stab Fp) ↔
PlusTruthAt Mg τ' t' (.stab Fp)`. On the landed two-state fixture that hypothesis forces
`τ.state t` and `τ'.state t'` to have the same `Bool` component, so the check is vacuous. The task
asks for a fixture with two distinct states sharing the `⊡Fp` value, the two landed shapes plus
the mixed shapes `⊡(Fp → ⊡Pp)`-like, each computed directly and through the strata.

**Semantics that decide everything** (`PlusTruth.lean:84-92`): `⊡φ` at `(τ, t)` is `∀ σ,
τ.state t = σ.state t → φ at (σ, t)`; `Fp = untl top p` is `∃ s > t, p at s`; `Pp = snce top p`
is `∃ s < t, p at s`. On an `ofSlicedStep` frame the state is a pair `(time, w)` and histories are
exactly the bi-infinite step paths with the time coordinate advancing by one
(`mem_HF_iff_adjacent`). With a time-independent relation, the histories through `(c, w)` at `t`
are the pairs (backward infinite `R`-path into `w`) × (forward infinite `R`-path out of `w`), so
every `⊡`-value here is a CTL-style universal path property on the finite step graph. That is
what the fixpoint script computes and what the Lean proofs mirror.

**Constraints carried unchanged**: bi-seriality (for `ofSlicedStep` and `IsRegular`), the axiom
profile `[propext, Classical.choice, Quot.sound]` with no `sorryAx`, everything under
`[F.IsRegular]`, no decidability / complexity / device claims, the landed probe untouched except
for an optional pointer line, append-only wiring, probes import only `FormalSystem` (transcribe,
never import another probe — `check-evidence-probes.sh` header).

## Findings

### Codebase Patterns

All names below were read from source this session (the lean-lsp symbol index reported
`index: unavailable`, so verification is by `Read`/grep and by the two compiled skeleton runs,
not by `lean_local_search`).

| Name | Where | Role in the new probe |
|------|-------|-----------------------|
| `FrameOver.ofSlicedStep R fwd bwd` | `SlicedFrame.lean:283` | Frame over `ℤ × W`, needs `[Finite W] [Nonempty W]`, `fwd : ∀ t w, ∃ u, R t w u`, `bwd : ∀ t w, ∃ v, R (t-1) v w` |
| `FrameOver.ofSlicedStep_isRegular` | `SlicedFrame.lean:297` | The `IsRegular` instance |
| `FrameOver.ofSlicedStep_step` | `SlicedFrame.lean:305` | `step p q ↔ q.1 = p.1 + 1 ∧ R p.1 p.2 q.2`; both directions used (reading a history's step, discharging a constructed path's step) |
| `FrameOver.worldHistoryOfStepPath F f h` | `IntNormalForm.lean:323` | Constructed histories; `.path = f` by `rfl`; introduces `Classical.choice` |
| `WorldHistory.isStepPath` | `IntNormalForm.lean:334` | `σ.isStepPath t` gives the step from `σ.path t` to `σ.path (t+1)` |
| `PlusTruth.stab_iff`, `PlusTruth.top_true` | `PlusTruth.lean:145,149` | Clause lemma; `top_true` discharges the `untl`/`snce` side condition |
| `stab_state_only` | `PlusTruth.lean:332` | `⊡φ` depends on the state alone; used by `stab_fp_iff_fresh` |
| `Encoding`, `atomize`, `TaskModel.atomModel`, `plusTruthAt_iff_atomize` | `Atomization.lean:66,92,135,160` | The strata reading; `atomize_someFuture`/`atomize_somePast` are `rfl` |
| `Probe711DepthTwo.stab_fp_iff_fresh`, `atom_iff_fresh`, `depth2_via_strata_1/_2`, `strata_is_atomize_1/_2` | landed probe | Transcribe (never import); the proofs are fixture-independent and go through verbatim |
| `Probe719Backward` (`backward-dual-asymmetric-fixture.lean:335`) | mirror probe | The backward-step idiom: `σ.isStepPath (t-1)` then `rw [show t - 1 + 1 = t by ring]` |

**Proof template the landed probe establishes** (and which the skeleton reproduces): for each
formula, a theorem `_iff : PlusTruthAt Mg τ t φ ↔ (τ.state t).2 = …` or per-state
`_at_x` lemmas; False values via a constructed history (`stayA`, `jumpB`) through
`(τ.state t).1` at time `t`, matched with `Prod.ext rfl h`; True values via the successor table
(`next_true`) applied to an arbitrary `σ` through the seam.

### The fixture and its value table

**Fixture D** (recommended). Carrier `S := a | b | c | d`; `edge : S → S → Bool` with
`a→a, a→b, b→b, b→d, d→b, c→c`; `Rg _ u v := edge u v = true`; `p` at `b` only.
Bi-serial: successors `a:{a,b}`, `b:{b,d}`, `c:{c}`, `d:{b}`; predecessors `a:{a}`, `b:{a,b,d}`,
`c:{c}`, `d:{b}`. `Rg_fwd`/`Rg_bwd` are four-case `cases w; exact ⟨_, rfl⟩`. The sub-fixture
`{a, b}` is literally the landed fixture; `c` is an isolated sink; `d` is a post-`b` state whose
only predecessor is the `p` state.

Values (`T`/`F` per state), computed by hand and confirmed by the fixpoint script; `q := ⊡Fp`,
`r := ⊡Pp`:

| Formula | a | b | c | d | Function of `q`? |
|---------|---|---|---|---|------------------|
| `p` | F | T | F | F | — |
| `q = ⊡Fp` (depth-1 stratum) | F | T | F | T | shared classes `{a,c}` (F), `{b,d}` (T) |
| `r = ⊡Pp` | F | F | F | T | — |
| S1 `⊡F(⊡Fp)` | F | T | F | T | **yes**, both classes, non-vacuously |
| S2 `⊡(Fp → ⊡Fp)` (landed) | F | T | T | T | **no**: `a` F vs `c` T |
| M1 `⊡(Fp → ⊡Pp)` (mixed) | F | F | T | T | **no**: `a`/`c` and `b`/`d` |
| M2 `⊡(Pp → ⊡Fp)` (mixed) | T | T | T | T | **yes** (constant) |
| S1' `⊡P(⊡Fp)` (past mirror of S1) | F | F | F | T | **no**: `b` F vs `d` T |
| `⊡(Pp → ⊡Pp)` (optional) | T | F | T | T | no: `b`/`d` |
| `⊡P(⊡Pp)` (optional) | F | F | F | F | yes (constant) |

Why each refutation holds, in one line each:
- **S2 at `a` vs `c`**: `⊡(Fp → q)(w) = q(w) ∨ ¬(some path from w hits p)`. At `a` the history
  `jumpB` hits `p` and `q(a)` is False; at `c` no history hits `p` (forward closure of `c`), so
  the implication is vacuously True.
- **M1 at `b` vs `d`**: `⊡(Fp → r)(w) = r(w) ∨ ¬(some path hits p)`. At `b` every history hits
  `p` (`q(b)`) and `r(b)` is False (history `a…a b b…`, no `p` before `t`); at `d`, `r(d)` is
  True (the only predecessor of `d` is `b`).
- **S1' at `b` vs `d`**: `⊡Pq(w)` = every backward path hits a `q`-state. At `b` the history
  `a…a b b…` has only `a` (`q` False) before `t`; at `d` the predecessor is `b`, `q(b)` True.

**Fixture B** (`{a, b, d}`, drop `c`) is the induction-free minimum: it carries the M1 and S1'
refutations on the shared-True class and the non-vacuous positives for S1, S2, M2 there, but loses
the S2 refutation (which needs the shared-False class, hence `c` and one forward-closure
induction). **Fixture C** (`{a, b, c}`) carries only the S2/M1 refutation on `{a, c}` and has
`⊡Pp` identically False, so its mixed shapes collapse to forward ones — it does not meet the
task's "mixed shapes" requirement on its own. Fixture D subsumes both for the cost of one
generic closure lemma.

### What is refuted and what survives

1. **Refuted**: the literal statement of `Probe711DepthTwo.value_is_function_of_stratum`
   transplanted to any fixture with a genuinely shared `⊡Fp` class — for S2 on the shared-False
   class, and for M1 and S1' on the shared-True class. A depth-2 `⊡`-value is **not** a function of
   the depth-1 `⊡Fp` bit.
2. **Survives, non-vacuously**: S1 `⊡F(⊡Fp)` on both classes; S2 on the shared-True class; M2
   everywhere. For these the plan should state `value_is_function_of_stratum_S1` etc. with the
   same hypothesis shape as the landed theorem, now with real content (two distinct states per
   class).
3. **Unchanged**: everything the landed probe proves about its own fixture, and
   `stab_state_only` / Probe 718's stratification. Nothing here contradicts them.

### Interpretation for the finite per-time alphabet

The ranking's sentence says "function of the class's **automaton** state". The refutation shows
what the automaton state at a seam must at least carry: on Fixture D the labels `⊡Fp`, `⊡Pp` and
`⊡¬Fp` are pairwise independent (`a`: F,F,F; `b`: T,F,F; `c`: F,F,T; `d`: T,T,F), and each depth-2
shape is a Boolean function of the state's *tuple* of depth-1 labels for the `⊡`-subformulas that
actually occur after atomization — S2 is `q ∨ ⊡¬Fp`, M1 is `r ∨ ⊡¬Fp`, S1' is `⊡P q` which needs
the depth-1 label of a *new* formula (`⊡Pq` over the atomized model). So:

- The alphabet that Probe 718 licenses — one label per `⊡`-subformula `χ` of the closure,
  `stratum M χ w` — is **not** threatened: the depth-2 value of `⊡ψ` is the depth-1 value of
  `⊡(atomize ψ)` over the atomized model, which is a function of the state. This is the content
  of `plusTruthAt_iff_atomize` and it holds on Fixture D exactly as on the landed one.
- What **is** dead is any summary that keeps one bit per depth, or the depth-1 label of the
  *target's* inner `⊡`-subformula alone, and expects to read depth 2 off it. The automaton's
  per-state label must include the depth-1 labels of every `⊡`-subformula the atomized depth-2
  formula introduces — including backward ones (`⊡Pp`, `⊡Pq`) even for a forward-looking target,
  since M1 mixes them.
- Honest limits, to go into the probe header verbatim: nothing about width, period, decidability,
  complexity or devices; the fixture is time-independent, so it says nothing about per-time
  summaries over many states; and "function of the full closure labelling" is not proved here
  either — only the specific five shapes on this one fixture are computed.

### The divergence question

The task notes that `plusTruthAt_iff_atomize` atomizes the outer `⊡` while the `via_strata`
theorems read the inner `⊡`, and asks that any divergence on a three-state fixture be recorded.
Both are equivalences whose left-hand side is the same direct `PlusTruthAt Mg τ t (.stab …)`, so
their right-hand sides are provably equivalent to each other on every fixture; and the
`via_strata` proofs in the landed probe never use a fixture fact (they use `stab_fp_iff_fresh`,
`atom_iff_fresh`, `PlusTruth.stab_iff` and `top_true` only). The same proofs will compile
unchanged on Fixture D. The plan should (i) transcribe `stab_fp_iff_fresh`, add
`stab_pp_iff_fresh` (identical proof with `Pp`), and (ii) state `via_strata` for S1, S2, M1, M2,
S1' and `strata_is_atomize` for each as one-line citations of `plusTruthAt_iff_atomize`. No
divergence phase.

### Toolchain facts for the implementer (each hit and fixed this session)

| Fact | Fix used in the compiled skeleton |
|------|-----------------------------------|
| `deriving Fintype` on the 4-constructor enum fails (`Finset.val`/`enumList` coercion mismatch) | `instance : Fintype S := ⟨{.a, .b, .c, .d}, fun x => by cases x <;> simp⟩`; `instance : Finite S := Finite.of_fintype S` |
| `Int.le_induction` is deprecated | `Int.leInduction` (same `base`/`succ` cases) |
| `generalize (σ.path (t+1)).2 = v` misses goals stated in `σ.state` terms | State successor/predecessor tables over `S` once and close them by `decide`: `theorem succ_of_b : ∀ v : S, edge .b v = true → v = .b ∨ v = .d := by decide`; then `exact succ_of_b _ h1` |
| `by omega` inside an anonymous-constructor tuple elaborates before its goal is known | `lt_add_one t`, `sub_one_lt t`, `lt_trans (lt_add_one t) (lt_add_one _)`; or a named `have` |
| `rw [if_neg (by omega)]` — same failure mode | `have h1 : ¬ t < t - 1 := by omega` then `simp only [viaDState, h1, h2, if_false, if_true]` |
| Constructed-history step obligation | Factor the state function into a `def` (`viaDState t z`), prove `edge (f z) (f (z+1)) = true` by `unfold; split_ifs <;> first \| rfl \| omega`, then pass it to `worldHistoryOfStepPath` |
| `show` linter | Use `change` for goal rewrites in new code |
| Backward closure of a sink (`a` for its past, `c` for both directions) | Recommend one generic lemma per direction over `n : ℕ` steps, `stays_fwd (hw : ∀ v, edge w v = true → v = w)` / `stays_bwd (hw : ∀ u, edge u w = true → u = w)`, the hypothesis discharged by `decide` per state; avoids depending on the downward Int induction name |

### Recommendations

1. **Fixture**: D (`{a, b, c, d}`) as above; namespace `Probe739SharedStratum`; file
   `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean`.
2. **Shapes**: S1, S2, M1, M2, S1' (five). The two optional past shapes may be added if cheap
   (`⊡P(⊡Pp)` needs the `viaD` history for its False value at `d`; `⊡(Pp → ⊡Pp)` needs nothing
   new).
3. **Theorems** (sketch; the plan's `## Lean Challenge Statements` section should pin these):
   - Depth 1: `stab_will_iff : ⊡Fp ↔ (state = b ∨ state = d)`, `stab_past_iff : ⊡Pp ↔ state = d`
     (or per-state `_at_x` lemmas, as the skeleton does).
   - Depth 2 direct: one `_iff` per shape against an explicit `S → Bool` table, mirroring the
     value table.
   - Depth 2 through strata: `via_strata_S1 … S1'` and `strata_is_atomize_*`.
   - Shared-stratum witnesses: `shared_false : a ≠ c ∧ (⊡Fp at a ↔ ⊡Fp at c)`,
     `shared_true : b ≠ d ∧ (⊡Fp at b ↔ ⊡Fp at d)` — the non-vacuity certificates.
   - Positive: `value_is_function_of_stratum_S1`, `_M2`, and `_S2_on_true_class`.
   - Refutation: `not_function_of_stratum_S2`, `_M1`, `_S1'`: existence of `τ, τ', t, t'` with
     equal `⊡Fp` values and differing depth-2 values — exhibited with the concrete seams
     `(stayA c t, t)`, `(stayC c t, t)`, `(fromA c t, t)`, `(viaD c t, t)` or any history through
     the state.
4. **Header**: same style as the landed probe — fixture, what is established (numbered), what is
   NOT established (including the honest-limits paragraph above and the explicit statement that
   the landed probe remains correct about its own fixture), axiom record, compile line.
5. **Wiring**: append `"seam-gluing-ray-product/stab-depth-two-shared-stratum"` as the last entry
   of the `WIRED` array (`check-evidence-probes.sh:392-401`) and a table row after the
   `stab-depth-two-probe` row (`:258`), both append-only. Optionally one pointer line in the
   landed probe's header after "is a follow-up".
6. **Gate**: `bash scripts/check-evidence-probes.sh` green (currently 19 wired; becomes 20).
   Compile the single file through the guard during development:
   `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean <file>`.
7. **Phase sizing** (for the planner): Phase 1 fixture + depth-1 values + histories (the skeleton,
   ~150 lines, compiled); Phase 2 the five direct depth-2 tables (~200 lines); Phase 3 strata
   readings + shared-stratum certificates + positive/refutation theorems + header + wiring
   (~150 lines). One generic closure lemma pair in Phase 1 serves `a` and `c`.

## Decisions

- **D1**: Take "stratum" to mean the `⊡Fp` bit, as the task text and the landed theorem both do.
  The refutation is relative to that reading and the header must say so; the richer reading
  (function of the state / of the full closure labelling) is recorded as unchanged, not as
  refuted.
- **D2**: Recommend the four-state Fixture D over the three-state B or C, because only D carries
  both a shared-False and a shared-True class and therefore both the landed-shape refutation and
  the non-degenerate past factor. Cost: one generic closure lemma pair.
- **D3**: Do not plan a divergence investigation (see "The divergence question").
- **D4**: Do not touch `stab-depth-two-probe.lean` beyond an optional pointer line; do not touch
  the KTypeSummary cluster or the seam interface. Research found no need to.
- **D5**: Record the refutation as the headline and the surviving shapes as the non-vacuous
  positive; both stand together with the landed probe's result, per the task's instruction.

## Risks & Mitigations

- **Risk**: the implementer treats the S2/M1/S1' refutations as a defect and "tunes" the fixture
  until the check passes. *Mitigation*: the plan states the expected value table and names the
  refutations as deliverables; the header records them as findings.
- **Risk**: overclaiming in the header ("stratification fails", "finite alphabet dead").
  *Mitigation*: use the interpretation paragraph above verbatim; the finite closure-indexed
  alphabet is untouched, only the one-bit reading dies.
- **Risk**: the sink-closure inductions (`a` backward, `c` both ways) get written three times with
  three different induction names. *Mitigation*: one generic `stays_fwd`/`stays_bwd` over `n : ℕ`
  with a `decide`-discharged "only self-neighbour" hypothesis.
- **Risk**: `deriving Fintype` or `Int.le_induction` cost a dispatch. *Mitigation*: the fixes are
  in the toolchain table and the compiled skeleton.
- **Risk**: sibling task 740 (undeclared scope) edits `check-evidence-probes.sh` in the same
  cycle. *Mitigation*: re-read the script immediately before the append; stage only the probe
  file and the script by explicit path.
- **Risk**: the fixpoint script's semantics differ from Lean's (strict future/past, bi-infinite
  histories). *Mitigation*: the five values that matter most (`q`, `r` at `b`, `d`; M1 at `b`, `d`)
  are already proved in Lean in the skeleton and agree with the script.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| successor/predecessor tables over `S` (`∀ v, edge .b v = true → v = .b ∨ v = .d`) | decide | success | hand-built `Fintype S`, `DecidableEq S` |
| `Rg_fwd`, `Rg_bwd` (bi-seriality) | cases + exact ⟨_, rfl⟩ | success | none |
| constructed-path step `edge (f z) (f (z+1)) = true` with `if`-defined `f` | unfold; split_ifs <;> first \| rfl \| omega | success | none |
| time-offset side goal `z + 1 + (c - t) = z + (c - t) + 1` | ring | success | after `change` |
| `t - 1 < t`, `t < t + 1` inside anonymous constructors | omega | fail (goal unknown at elaboration) | use `sub_one_lt`, `lt_add_one` |
| forward closure of `c` (`∀ s ≥ t, state = c`) | Int.leInduction | success | `next_of_c` |
| `viaD_state_t` (`if`-reduction at `z = t`) | simp only [viaDState, h1, h2, if_false, if_true]; congr 1; ring | success | `h1 : ¬ t < t - 1`, `h2 : ¬ t = t - 1` by omega as named `have`s |
| `⊡Pp` at `d` (True) | rw [PlusTruth.stab_iff]; intro; exact ⟨t-1, sub_one_lt t, prev_of_d …, top_true⟩ | success | `prev_of_d` from `isStepPath (t-1)` |
| `⊡(Fp → ⊡Pp)` at `b` (False) | instantiate the outer `∀σ` at `τ` itself; `stab_will_at_b` gives `Fp`, `not_stab_past_at_b` closes | success | no new history needed |

## Context Extension Recommendations

- **Topic**: constructing bi-infinite histories on `ofSlicedStep` frames with a custom finite
  carrier.
- **Gap**: the four toolchain pitfalls above (hand-built `Fintype`, `Int.leInduction`, `decide`d
  neighbour tables, `omega` inside anonymous constructors) are rediscovered per probe; the lean4
  context has no note on them.
- **Recommendation**: add a short "evidence-probe fixture recipe" to
  `.claude/context/project/lean4/patterns/` (or extend `mcp-fallback-table.md`'s neighbour) with
  the `viaDState`/`split_ifs` idiom and the generic `stays_fwd`/`stays_bwd` lemma shape.

## Appendix

### A. The compiled skeleton (lean-lsp `lean_run_code`, `success: true`, all `#print axioms` at `[propext, Classical.choice, Quot.sound]`)

This is a research artifact, not the probe: it has no header, covers one refutation, and should
be lifted into Phase 1 of the plan rather than committed as-is.

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace Probe739Skeleton

inductive S where
  | a | b | c | d
  deriving DecidableEq

instance : Fintype S := ⟨{.a, .b, .c, .d}, fun x => by cases x <;> simp⟩
instance : Finite S := Finite.of_fintype S
instance : Nonempty S := ⟨.a⟩

def edge : S → S → Bool
  | .a, .a => true | .a, .b => true
  | .b, .b => true | .b, .d => true
  | .d, .b => true
  | .c, .c => true
  | _, _ => false

def Rg : ℤ → S → S → Prop := fun _ u v => edge u v = true

theorem Rg_fwd : ∀ (t : ℤ) (w : S), ∃ u, Rg t w u := by
  intro _ w; cases w
  · exact ⟨.a, rfl⟩
  · exact ⟨.b, rfl⟩
  · exact ⟨.c, rfl⟩
  · exact ⟨.b, rfl⟩

theorem Rg_bwd : ∀ (t : ℤ) (w : S), ∃ v, Rg (t - 1) v w := by
  intro _ w; cases w
  · exact ⟨.a, rfl⟩
  · exact ⟨.a, rfl⟩
  · exact ⟨.c, rfl⟩
  · exact ⟨.b, rfl⟩

def Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd
instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd

def pa : Atom := ⟨"p", none⟩
def Mg : TaskModel Fg.toTaskFrame where
  valuation q _ := q.2 = .b

abbrev Fp : PlusFormula := someFuture (.atom pa)
abbrev Pp : PlusFormula := somePast (.atom pa)

theorem step_succ (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    (σ.path (t + 1)).1 = (σ.path t).1 + 1 ∧ Rg (σ.path t).1 (σ.path t).2 (σ.path (t + 1)).2 :=
  (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mp (σ.isStepPath t)

theorem succ_of_b : ∀ v : S, edge .b v = true → v = .b ∨ v = .d := by decide
theorem succ_of_c : ∀ v : S, edge .c v = true → v = .c := by decide
theorem succ_of_d : ∀ v : S, edge .d v = true → v = .b := by decide
theorem pred_of_d : ∀ u : S, edge u .d = true → u = .b := by decide

theorem next_of_b (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .b) :
    (σ.state (t + 1)).2 = .b ∨ (σ.state (t + 1)).2 = .d := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .b := h
  rw [h'] at h1
  exact succ_of_b _ h1

theorem next_of_d (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .d) :
    (σ.state (t + 1)).2 = .b := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .d := h
  rw [h'] at h1
  exact succ_of_d _ h1

theorem prev_of_d (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .d) :
    (σ.state (t - 1)).2 = .b := by
  have h1 := (step_succ σ (t - 1)).2
  rw [show t - 1 + 1 = t by ring] at h1
  have h' : (σ.path t).2 = .d := h
  rw [h'] at h1
  exact pred_of_d _ h1

theorem next_of_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .c) :
    (σ.state (t + 1)).2 = .c := by
  have h1 := (step_succ σ t).2
  have h' : (σ.path t).2 = .c := h
  rw [h'] at h1
  exact succ_of_c _ h1

theorem stays_c (σ : WorldHistory Fg.toTaskFrame) (t : ℤ) (h : (σ.state t).2 = .c) :
    ∀ s, t ≤ s → (σ.state s).2 = .c := by
  intro s hs
  induction s, hs using Int.leInduction with
  | base => exact h
  | succ n _ ih => exact next_of_c σ n ih

def viaDState (t z : ℤ) : S :=
  if z < t - 1 then .a else if z = t - 1 then .b else if z = t then .d else .b

theorem viaDState_edge (t z : ℤ) : edge (viaDState t z) (viaDState t (z + 1)) = true := by
  unfold viaDState
  split_ifs <;> first | rfl | omega

noncomputable def viaD (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), viaDState t z)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, viaDState_edge t z⟩
    change z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem viaD_state (c t z : ℤ) : (viaD c t).state z = (z + (c - t), viaDState t z) := rfl

theorem viaD_state_t (c t : ℤ) : (viaD c t).state t = (c, .d) := by
  rw [viaD_state]
  have h1 : ¬ t < t - 1 := by omega
  have h2 : ¬ t = t - 1 := by omega
  simp only [viaDState, h1, h2, if_false, if_true]
  congr 1
  ring

theorem stab_past_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab Pp) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .d := by rw [← hagree]; exact hd
  exact ⟨t - 1, sub_one_lt t, prev_of_d σ t h1,
    fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

theorem stab_will_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    PlusTruthAt Mg τ t (.stab Fp) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree
  have h1 : (σ.state t).2 = .b := by rw [← hagree]; exact hb
  rcases next_of_b σ t h1 with h2 | h2
  · exact ⟨t + 1, lt_add_one t, h2, fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩
  · exact ⟨t + 1 + 1, lt_trans (lt_add_one t) (lt_add_one _), next_of_d σ (t + 1) h2,
      fun r _ _ => PlusTruth.top_true (M := Mg) (τ := σ) (t := r)⟩

def fromAState (t z : ℤ) : S := if z < t then .a else .b

theorem fromAState_edge (t z : ℤ) : edge (fromAState t z) (fromAState t (z + 1)) = true := by
  unfold fromAState
  split_ifs <;> first | rfl | omega

noncomputable def fromA (c t : ℤ) : WorldHistory Fg.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath Fg (fun z => (z + (c - t), fromAState t z)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step Rg Rg_fwd Rg_bwd _ _).mpr ⟨?_, fromAState_edge t z⟩
    change z + 1 + (c - t) = z + (c - t) + 1
    ring)

theorem fromA_state (c t z : ℤ) : (fromA c t).state z = (z + (c - t), fromAState t z) := rfl

theorem fromA_state_t (c t : ℤ) : (fromA c t).state t = (c, .b) := by
  rw [fromA_state]
  simp only [fromAState, lt_irrefl, if_false]
  congr 1
  ring

theorem not_stab_past_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    ¬ PlusTruthAt Mg τ t (.stab Pp) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hagree : τ.state t = (fromA (τ.state t).1 t).state t := by
    rw [fromA_state_t]
    exact Prod.ext rfl hb
  obtain ⟨s, hs, hp, -⟩ := h _ hagree
  have hp' : ((fromA (τ.state t).1 t).state s).2 = .b := hp
  rw [fromA_state] at hp'
  simp only [fromAState, hs, if_true] at hp'
  exact S.noConfusion hp'

/-- The mixed-shape refutation on the shared-True stratum `{b, d}`. -/
theorem mixed_at_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = .b) :
    ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro h
  have hFp : PlusTruthAt Mg τ t Fp := (stab_will_at_b τ t hb) τ rfl
  exact not_stab_past_at_b τ t hb (h τ rfl hFp)

theorem mixed_at_d (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hd : (τ.state t).2 = .d) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) := by
  rw [PlusTruth.stab_iff]
  intro σ hagree _
  exact stab_past_at_d σ t (by rw [← hagree]; exact hd)

end Probe739Skeleton
```

Still to add for the full probe (not in the skeleton): `stayA`, `jumpB` (transcribe from the
landed probe with `.a`/`.b` for `false`/`true`), `stayC` (copy of `stayA`), the generic
`stays_fwd`/`stays_bwd`, `stab_will_at_d` (`next_of_d`), the S1/S2/M2/S1' tables, the strata
readings, and the shared-stratum certificates.

### B. The fixpoint check

Universal path-eventualities on a finite serial graph with time-independent `R`:
`⊡Fχ = AX AF χ`, `⊡Pχ = AY AP χ`, `⊡(Fp → X) = X ∨ ¬EX EF p`, `⊡(Pp → X) = X ∨ ¬EY EP p` for a
state-function `X`; `AF`/`EF`/`AP`/`EP` as least fixpoints. Run on the landed fixture (reproduces
its header's values exactly), on Fixtures B, C and D (table above). Script in the session
scratchpad; 40 lines, standard library only.

### C. Search queries used

- grep: `summary state`, `not a function of the class`, `E2` across `specs/` and `docs/`
  (located the ranking sentence and D-13).
- grep: `theorem stab_iff|stab_state_only|plusTruthAt_iff_atomize|def ofSlicedStep|
  worldHistoryOfStepPath|def atomModel|structure Encoding|def PlusTruthAt` across `FormalSystem/`.
- `lean_local_search "Int.le_induction"` — returned `index: unavailable` (no evidence either way);
  settled instead by the compiler's deprecation warning naming `Int.leInduction`.
- Rate-limited search tools (leansearch/loogle/leanfinder) were not needed: every cited name was
  read from source in this repository.
