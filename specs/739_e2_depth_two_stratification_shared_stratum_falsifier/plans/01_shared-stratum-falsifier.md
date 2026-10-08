# Implementation Plan: Task #739

- **Task**: 739 - Run E2's real test: the depth-2 stratification falsifier on a fixture with two states sharing a depth-1 stratum
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/739_e2_depth_two_stratification_shared_stratum_falsifier/reports/01_shared-stratum-falsifier.md
- **Artifacts**: plans/01_shared-stratum-falsifier.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

One new evidence probe, `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean`
(namespace `Probe739SharedStratum`), on the research report's four-state Fixture D — carrier
`a | b | c | d`, time-independent edges `a→a, a→b, b→b, b→d, d→b, c→c`, `p` at `b` only — on which
two distinct states share the depth-1 stratum `⊡Fp` in BOTH directions: `{a, c}` share False,
`{b, d}` share True. Five depth-2 shapes are computed directly and through the strata, exactly as
the landed `stab-depth-two-probe.lean` does, and the falsifier's question is asked
non-vacuously on each shared class. The expected outcome, re-derived at plan time by an
independent fixpoint script and matching the report's table row for row, is MIXED: the literal
one-bit reading of "function of the stratum" is REFUTED for the landed forward shape
`⊡(Fp → ⊡Fp)` (on `{a, c}`), the mixed shape `⊡(Fp → ⊡Pp)` (on both classes) and the past
mirror `⊡P(⊡Fp)` (on `{b, d}`), while `⊡F(⊡Fp)` and `⊡(Pp → ⊡Fp)` survive non-vacuously. The
refutation is the headline deliverable, not a defect to tune away; the surviving shapes are the
non-vacuous upgrade of E2 the task asked for; the landed probe's positive on its own fixture
stands untouched. The probe is wired append-only into `scripts/check-evidence-probes.sh`.

### Research Integration

- Fixture D (report "The fixture and its value table") adopted as recommended: it is the only
  candidate carrying both a shared-False and a shared-True class, hence both the landed-shape
  refutation and a non-degenerate past factor (report Decision D-2).
- The value table was re-derived at plan time with a fresh 30-line least-fixpoint script
  (`⊡Fχ = AX AF χ`, `⊡Pχ = AY AP χ`, `⊡(Fp → X) = X ∨ ¬EX EF p`, `⊡(Pp → X) = X ∨ ¬EY EP p`)
  and agrees with the report on every row; the table in Phase 2 is therefore a re-derived figure,
  not a carried one.
- The report's compiled skeleton (Appendix A: carrier, hand-built `Fintype`, bi-serial relation,
  `ofSlicedStep` frame with `IsRegular`, `viaD`/`fromA` histories, `⊡Fp` at `b`, `⊡Pp` at `d`,
  the `⊡(Fp → ⊡Pp)` refutation at `b` vs `d`) is lifted into Phase 1 — CARRIED from the report's
  `lean_run_code` run (`success: true`, all axioms at `[propext, Classical.choice, Quot.sound]`);
  the implementer's first compile re-confirms it.
- The report's "divergence question" finding is adopted: `plusTruthAt_iff_atomize` (outer `⊡`)
  and the `via_strata` theorems (inner `⊡`) are both biconditionals against the same direct
  value, and the landed `via_strata` proofs are fixture-independent, so no divergence phase is
  planned (Decision D-3); the `via_strata` and `strata_is_atomize` theorems are restated for all
  five shapes instead.
- The report's toolchain table (hand-built `Fintype S`, `Int.leInduction` — re-verified at plan
  time: `Mathlib/Data/Int/Init.lean:141`, with `Int.le_induction` deprecated since 2026-03-25 and
  `Int.leInductionDown` at `:162` available for the backward direction — `decide`d neighbour
  tables, no `by omega` inside anonymous constructors, `viaDState`/`split_ifs` for constructed
  paths, `change` not `show`) is carried into Phase 1's tasks.
- Cited library names re-verified at plan time from source: `FrameOver.ofSlicedStep`
  (`SlicedFrame.lean:283`), `FrameOver.worldHistoryOfStepPath` (`IntNormalForm.lean:323`),
  `stab_state_only` (`PlusTruth.lean:332`), `plusTruthAt_iff_atomize` (`Atomization.lean:160`).
- The `## Lean Challenge Statements` block below was type-checked standalone against the tree at
  plan time through `lake-build-guard.sh` (exit 0, 29 `declaration uses 'sorry'` warnings, no
  errors).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` in the dispatch context; ROADMAP.md not consulted.

## Goals & Non-Goals

**Goals**:
- Bi-seriality of the four-state relation established, not assumed: `Rg_fwd`, `Rg_bwd`.
- Depth-1 strata on Fixture D, showing the two genuinely shared classes: `stab_will_iff`
  (True exactly at b and d), `stab_past_iff` (True exactly at d).
- The five depth-2 shapes computed DIRECTLY against the value table: `depth2_S1_iff`,
  `depth2_S2_iff`, `depth2_M1_iff`, `depth2_M2_true`, `depth2_S1past_iff`.
- The fresh-atom valuations ARE the depth-1 strata: `stab_fp_iff_fresh`, `stab_pp_iff_fresh`.
- The five shapes computed THROUGH THE STRATA (inner box-dot read through its depth-1 stratum
  over the atomized model): `depth2_via_strata_S1`, `depth2_via_strata_S2`,
  `depth2_via_strata_M1`, `depth2_via_strata_M2`, `depth2_via_strata_S1past`; and the landed
  transfer lemma (outer box-dot atomized) cited at each: `strata_is_atomize_S1`,
  `strata_is_atomize_S2`, `strata_is_atomize_M1`, `strata_is_atomize_M2`,
  `strata_is_atomize_S1past`.
- Non-vacuity certificates — two distinct seam states with equal depth-1 strata, one per class:
  `shared_false_stratum` (a vs c), `shared_true_stratum` (b vs d).
- The falsifier's question answered in the affirmative, NON-VACUOUSLY, where it holds:
  `value_is_function_of_stratum_S1`, `value_is_function_of_stratum_M2`,
  `value_is_function_of_stratum_S2_on_true_class`.
- The falsifier's question REFUTED, machine-checked, where it fails: `not_function_of_stratum_S2`
  (a vs c), `not_function_of_stratum_M1` (b vs d), `not_function_of_stratum_S1past` (b vs d).
- A header in the landed probes' style (fixture; what is established; what is NOT established,
  including the honest consequence for the finite per-time alphabet; axiom record; compile
  line), an axiom foot, and the append-only wiring into the collection gate, green.

**Non-Goals**:
- No decidability result, no complexity bound, nothing about devices — the landed probe's three
  exclusions transfer unchanged.
- No claim about width, period, or per-time summaries over MANY states: the fixture is
  time-independent, so every time slice is the same four states.
- No claim that depth-2 values are a function of the FULL closure labelling (`stratum M χ w`
  per box-dot subformula, Probe 718): only the five named shapes on this one fixture are
  computed. The refutation is relative to the one-bit reading (the `⊡Fp` value at the state),
  which is the reading the landed `value_is_function_of_stratum` hypothesis encodes.
- No edit to `stab-depth-two-probe.lean` beyond an optional single pointer line; no edit to the
  KTypeSummary cluster or the seam interface; no new substrate lemma.
- No investigation of a "divergence" between the outer-atomized and inner-stratum readings
  (shown impossible by the report; see Research Integration).
- The two optional past shapes (`⊡(Pp → ⊡Pp)`, `⊡P(⊡Pp)`) are NOT planned; they may be added
  only if Phase 2 finishes under budget, and are then additions to the header, not to the
  pinned statements.
- No import of any other probe: transcribe, never import (`check-evidence-probes.sh` header).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer treats the S2/M1/S1' refutations as a defect and "tunes" the fixture or the statements until a positive check passes | H | M | The expected value table and the refutation theorems are named deliverables with pinned statements (Lean Challenge Statements); the header records them as findings; Phase 2's verification compares each proved `_iff` against the table. |
| Overclaiming in the header ("stratification fails", "finite alphabet dead") | H | M | Phase 4 transcribes the report's interpretation paragraph: only the one-bit reading dies; `stab_state_only` and the closure-indexed alphabet of Probe 718 are untouched; the landed probe remains correct on its own fixture. |
| Sink-closure inductions written three times with three induction names, one of them deprecated | M | M | One generic `stays_fwd`/`stays_bwd` pair over `Int.leInduction`/`Int.leInductionDown` (both verified present), the "only self-neighbour" hypothesis discharged by `decide` per state. |
| `deriving Fintype` on the enum, `Int.le_induction`, `by omega` inside anonymous constructors, or `show` cost a dispatch | M | M | Phase 1 carries the report's fixes verbatim (hand-built `Fintype`, `Int.leInduction`, `lt_add_one`/`sub_one_lt`, named `have`s, `change`). |
| `lake-build-guard.sh` REPLAYS a cached verdict for the same file path when re-run within its replay window (observed at plan time: a log opening `lake-build-guard: REPLAY: sharing result from holder pid ..., age 82s, recorded exit status 1` after the file had been edited) | M | M | Before trusting a guard verdict, read the first line of its output; if it says REPLAY, wait out the window or rerun; never conclude a fix failed from a replayed log. |
| Sibling task 740 (same cycle, declared scope on `RaySummary/Compose.lean` and the KTypeSummary cluster) touches `scripts/check-evidence-probes.sh` or the shared tree | M | L | Re-read the gate script immediately before the Phase 4 append; stage only the probe file and the script by explicit path; never `git add` a directory; never run `git-snapshot.sh` in its reverting default mode; if a foreign uncommitted change or running build appears, stop and report after checking `git log`. |
| Task-reference hook rejects the gate-script table row | L | M | The script is outside `specs/**`; cite the probe by filename and the "E2 (probe iii)" label as the existing rows do; do not write "task 739" there (the probe file itself is under `specs/**` and exempt). |
| The pinned `(τ.state t).2 = S.x` shapes do not match what the implementer naturally writes (`.b` dotted) | L | L | Either form elaborates; the drift check compares signature text, so copy the pinned statements verbatim into the probe. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every phase
extends the one probe file.

### Phase 1: Fixture, constructed histories, closure lemmas, depth-1 strata [COMPLETED]

**Goal**: The four-state fixture compiles as a regular `ofSlicedStep` frame with bi-seriality
PROVED, every constructed history the later phases need exists, and the two depth-1 strata are
characterized per state — exhibiting the two shared classes `{a, c}` (`⊡Fp` False) and
`{b, d}` (`⊡Fp` True).

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` with a
      provisional header (title line, fixture paragraph, "header completed in Phase 4" note),
      `import FormalSystem`, the three `open` lines of the landed probe plus
      `open FormalSystem.Metalogic.Conservativity`, and `namespace Probe739SharedStratum`.
- [x] Carrier and instances, lifted from the report's skeleton: `inductive S | a | b | c | d
      deriving DecidableEq`; `instance : Fintype S := ⟨{.a, .b, .c, .d}, fun x => by cases x <;>
      simp⟩`; `instance : Finite S := Finite.of_fintype S`; `instance : Nonempty S := ⟨.a⟩`.
      Do NOT use `deriving Fintype` (fails on this toolchain per the report).
- [x] `def edge : S → S → Bool` with exactly the six true cases `a→a, a→b, b→b, b→d, d→b, c→c`;
      `def Rg : ℤ → S → S → Prop := fun _ u v => edge u v = true`.
- [x] Bi-seriality as named theorems, by `cases w` with explicit witnesses (`Rg_fwd`: a→a, b→b,
      c→c, d→b; `Rg_bwd`: a←a, b←a, c←c, d←b); `def Fg : FrameOver intOrder :=
      FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd`; `instance : Fg.IsRegular :=
      FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd`.
- [x] `def pa : Atom := ⟨"p", none⟩`; `def Mg : TaskModel Fg.toTaskFrame where valuation q _ :=
      q.2 = .b`; `abbrev Fp := someFuture (.atom pa)`; `abbrev Pp := somePast (.atom pa)`.
- [x] `step_succ` (transcribed from the landed probe) and the neighbour tables by `decide`:
      `succ_of_a` (a or b), `succ_of_b` (b or d), `succ_of_c` (c), `succ_of_d` (b), `pred_of_a`
      (a), `pred_of_c` (c), `pred_of_d` (b); the `next_of_x` / `prev_of_x` lemmas on histories
      (`prev_of_x` via `σ.isStepPath (t - 1)` then `rw [show t - 1 + 1 = t by ring]`, the Probe
      719 idiom).
- [x] Generic closure lemmas: `stays_fwd (w) (hw : ∀ v, edge w v = true → v = w)
      (σ) (t) (h : (σ.state t).2 = w) : ∀ s, t ≤ s → (σ.state s).2 = w` by `Int.leInduction`,
      and `stays_bwd` (hypothesis on predecessors) by `Int.leInductionDown` (or a ℕ-step
      recursion if preferred); instantiate at `c` (both directions) and `a` (backward), the
      hypotheses by `decide`.
- [x] Constructed histories via `FrameOver.worldHistoryOfStepPath`, each with a `_state` (`rfl`)
      and `_state_t` lemma, the state function factored into a `def` whose step obligation is
      closed by `unfold; split_ifs <;> first | rfl | omega`:
      `stay (w) (hw : edge w w = true) (c t)` (constant at `w`; use for `stayA`, `stayC`),
      `jumpB c t` (`a` through `t`, `b` from `t + 1`), `fromA c t` (`a` before `t`, `b` from
      `t`), `viaD c t` (`a` before `t - 1`, `b` at `t - 1`, `d` at `t`, `b` after). Use
      `lt_add_one`/`sub_one_lt` and named `have`s for the integer side goals, never `by omega`
      inside an anonymous constructor.
- [x] Depth-1: `stab_will_iff` (`⊡Fp ↔ state = b ∨ state = d`: `stayA`/`stayC` refute at `a`/`c`;
      at `b` the successor is `b` or `d` and `d`'s successor is `b`; at `d` the successor is
      `b`) and `stab_past_iff` (`⊡Pp ↔ state = d`: `stayA`, `stayC`, `fromA` refute at `a`, `c`,
      `b`; at `d` the predecessor is `b`). Add the per-state corollaries the later phases
      cite (`stab_will_at_b`, `stab_will_at_d`, `not_stab_will_at_a`, `not_stab_will_at_c`,
      `stab_past_at_d`, `not_stab_past_at_b`, ...).
- [x] Compile through the guard: `bash .claude/scripts/lake-build-guard.sh build --timeout 900
      -- env lean specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean`;
      check the log head for a `REPLAY` line before trusting the verdict.
- [x] Commit (probe file only, by explicit path, via `git-commit-scoped.sh`).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Roughly 180-220 lines (the report's ~150-line estimate plus the generic
closure pair and the extra `stay`/`jumpB` histories); confirmed at implementation time by
`wc -l` after the phase compiles. The report's skeleton compiled under `lean_run_code` at research
time (CARRIED); its lift is confirmed by this phase's first guard compile.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` - new probe file: fixture, histories, closure lemmas, depth-1 strata

**Verification**:
- The guard compile exits 0 with no `error` and no `sorry` in the file.
- `#print axioms Probe739SharedStratum.stab_will_iff` and `...stab_past_iff` report exactly
  `[propext, Classical.choice, Quot.sound]` (temporary `#print axioms` lines are fine here; the
  permanent foot is written in Phase 4).
- The statements of `Rg_fwd`, `Rg_bwd`, `stab_will_iff`, `stab_past_iff` match the Lean
  Challenge Statements verbatim.

---

### Phase 2: The five depth-2 shapes, computed directly [COMPLETED]

**Goal**: Each of the five depth-2 shapes has a per-state characterization that reproduces the
value table below exactly — including the three rows that refute the one-bit reading.

| Formula | a | b | c | d |
|---------|---|---|---|---|
| `⊡Fp` (depth-1 stratum, Phase 1) | F | T | F | T |
| `⊡Pp` (Phase 1) | F | F | F | T |
| S1 `⊡F(⊡Fp)` | F | T | F | T |
| S2 `⊡(Fp → ⊡Fp)` (the landed shape) | F | T | T | T |
| M1 `⊡(Fp → ⊡Pp)` (mixed) | F | F | T | T |
| M2 `⊡(Pp → ⊡Fp)` (mixed) | T | T | T | T |
| S1' `⊡P(⊡Fp)` (past mirror of S1) | F | F | F | T |

**Tasks**:
- [x] `depth2_S1_iff` (`↔ state = b ∨ state = d`): False at `a` along `stayA` and at `c` along
      `stayC` (every future state has `⊡Fp` False); True at `b` (next state `b` or `d`, both
      `⊡Fp` True) and at `d` (next state `b`).
- [x] `depth2_S2_iff` (`↔ state ≠ a`): False at `a` along `jumpB` (`Fp` True via `b` at
      `t + 1`, `⊡Fp` at `a` False); True at `b`, `d` outright (`⊡Fp` holds) and at `c`
      vacuously (`stays_fwd` at `c`: no history through `c` ever sees `p`).
- [x] `depth2_M1_iff` (`↔ state = c ∨ state = d`): False at `a` along `jumpB` (`Fp` True,
      `⊡Pp` at `a` False) and at `b` by instantiating the outer `∀ σ` at `τ` itself (`Fp` by
      `stab_will_at_b`, `⊡Pp` at `b` False — the report's compiled `mixed_at_b`); True at `c`
      vacuously (`stays_fwd`) and at `d` (`⊡Pp` True at `d`).
- [x] `depth2_M2_true` (True at every state): at `b`, `d` because `⊡Fp` holds; at `a`, `c`
      vacuously because `stays_bwd` shows no history through `a` or `c` has `p` in its past.
- [x] `depth2_S1past_iff` (`↔ state = d`): False at `a` along `stayA`, at `c` along `stayC`, and
      at `b` along `fromA` (every past state is `a`, where `⊡Fp` is False); True at `d` with
      witness `s = t - 1` (`prev_of_d`, `⊡Fp` True at `b`).
- [x] If and only if the phase is under budget: the optional `⊡(Pp → ⊡Pp)` (`↔ state ≠ b`) and
      `⊡P(⊡Pp)` (False everywhere; `viaD` refutes at `d`) rows — as extra theorems, not pinned.
- [x] Guard compile (watch for `REPLAY`), commit the probe file by explicit path.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Roughly 200 lines, five theorems of 15-40 lines each; confirmed by `wc -l`
and by the five names appearing in the file after the phase compiles.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` - the five direct depth-2 characterizations

**Verification**:
- Guard compile exits 0, no `sorry`.
- The five statements match the Lean Challenge Statements verbatim, and each right-hand side
  reproduces the table row for that shape (read off: S1 b∨d; S2 ≠a; M1 c∨d; M2 all; S1' d).
- `#print axioms` for the five: exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 3: Strata readings, non-vacuity certificates, positive and refutation theorems [COMPLETED]

**Goal**: Each depth-2 value is shown to be readable through the strata (inner box-dot via its
depth-1 stratum over the atomized model, and the landed outer-atomizing transfer lemma cited at
each shape); two distinct seams with equal depth-1 strata are exhibited per class; the
falsifier's question is answered non-vacuously where it holds and refuted, machine-checked,
where it fails.

**Tasks**:
- [x] `abbrev qAtom (e : Encoding) := e.ι (.inr Fp)`, `abbrev rAtom (e) := e.ι (.inr Pp)`,
      `abbrev pAtom (e) := e.ι (.inl pa)`.
- [x] `stab_fp_iff_fresh` and `atom_iff_fresh` transcribed from the landed probe (proofs are
      fixture-independent: `stab_state_only`, the `atomModel` `inl`/`inr` clauses,
      `Sum.inl_ne_inr`); `stab_pp_iff_fresh` as the twin with `Pp`/`rAtom`.
- [x] `depth2_via_strata_S1`, `_S2` transcribed from the landed `_1`, `_2`; `_M1` (`Fp → ⊡Pp`
      becomes `F p' → r`), `_M2` (`Pp → ⊡Fp` becomes `P p' → q`), `_S1past` (`P(⊡Fp)` becomes
      `P q`) by the same clause-level pattern, the `snce`/`untl` side condition discharged by
      `PlusTruth.top_true`.
- [x] `strata_is_atomize_S1`, `_S2`, `_M1`, `_M2`, `_S1past`: each is
      `plusTruthAt_iff_atomize Mg e _ τ t`.
- [x] `shared_false_stratum`: witnesses `(stayA c t, t)` and `(stayC c t, t)` for any `c t`
      (e.g. `0 0`); both `⊡Fp` False by `stab_will_iff`. `shared_true_stratum`: witnesses
      `(fromA c t, t)` (state `b`) and `(viaD c t, t)` (state `d`); both `⊡Fp` True.
- [x] `value_is_function_of_stratum_S1`: rewrite both sides with `depth2_S1_iff` and the
      hypothesis with `stab_will_iff`; the right-hand sides coincide. `_M2`: both sides True by
      `depth2_M2_true`. `_S2_on_true_class`: from `hτ`, `hτ'` get `b ∨ d` on each side, then
      `depth2_S2_iff` gives True on both.
- [x] `not_function_of_stratum_S2`: the `shared_false_stratum` witnesses; S2 False at `a`, True
      at `c` by `depth2_S2_iff`. `not_function_of_stratum_M1`: the `shared_true_stratum`
      witnesses; M1 False at `b`, True at `d` by `depth2_M1_iff`. `not_function_of_stratum_S1past`:
      same witnesses; S1' False at `b`, True at `d` by `depth2_S1past_iff`.
- [x] Guard compile (watch for `REPLAY`), commit the probe file by explicit path.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Roughly 150 lines: three fresh-atom lemmas (~15 lines each), five
`via_strata` (~12 each), five one-line citations, two certificates and six check theorems
(~5-10 each); confirmed by `wc -l` and by all 19 Phase-3 pinned names appearing in the file.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` - strata readings, certificates, positive and refutation theorems

**Verification**:
- Guard compile exits 0, no `sorry`.
- Every Phase-3 statement matches the Lean Challenge Statements verbatim (in particular the
  refutation theorems are EXISTENTIAL — a concrete pair of seams — and the positive theorems
  keep the landed hypothesis shape `⊡Fp ↔ ⊡Fp`).
- `#print axioms` on the three `not_function_of_stratum_*` and the three
  `value_is_function_of_stratum_*`: exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 4: Header, axiom foot, append-only wiring, collection gate [COMPLETED]

**Goal**: The probe carries a header in the landed probes' style that states the mixed result
honestly, its axiom profile is pinned by a `#print axioms` foot, it is wired append-only into
`scripts/check-evidence-probes.sh`, and the collection gate is green.

**Tasks**:
- [x] Replace the provisional header with the final one, same section order as
      `stab-depth-two-probe.lean`: title ("Probe 739 (E2, probe iii): the shared-stratum
      falsifier"); the falsifier sentence quoted; the fixture (carrier, edges, bi-seriality by
      `Rg_fwd`/`Rg_bwd`, `p` at `b`); **What is established (machine-checked)**, numbered: (1)
      the two depth-1 strata and the two shared classes `{a, c}`/`{b, d}` with the certificate
      names; (2) the five depth-2 values, direct, with the value table; (3) the strata readings
      and the `plusTruthAt_iff_atomize` citations, noting as the landed header does that the
      transfer lemma atomizes the OUTER box-dot while `via_strata` reads the INNER one, and
      that the two readings agree here as there (both are biconditionals against the same direct
      value); (4) the POSITIVE non-vacuous checks (S1 on both classes, S2 on the shared-True
      class, M2 everywhere); (5) the REFUTATIONS as the headline: S2 on `{a, c}`, M1 on both
      classes (exhibited on `{b, d}`), S1' on `{b, d}` — the literal falsifier check of the
      landed probe is refuted on every fixture with a genuinely shared `⊡Fp` class.
- [x] **What is NOT established**, transcribed from the report's interpretation paragraph: the
      refutation kills only the reading on which a depth-2 box-dot value is determined by the
      ONE BIT `⊡Fp` at the state; it does not touch `stab_state_only` (the value is a function
      of the state) nor the closure-indexed alphabet Probe 718 licenses (one label per box-dot
      subformula, `stratum M χ w`) — on this fixture `⊡Fp`, `⊡Pp`, `⊡¬Fp` are pairwise
      independent and all three are needed to read the five shapes, including backward labels
      for a forward target (M1). Nothing about width, period, per-time summaries over many
      states (the fixture is time-independent), decidability, complexity, or devices; "function
      of the full closure labelling" is not proved either. The landed probe remains correct
      about its own two-state fixture; both results stand together.
- [x] **Axiom record** and **Compile line** paragraphs; then the `#print axioms` foot after
      `end Probe739SharedStratum` for every pinned theorem (29 lines), and remove any temporary
      `#print axioms` from earlier phases.
- [x] Re-read `scripts/check-evidence-probes.sh` immediately before editing. Append
      `"seam-gluing-ray-product/stab-depth-two-shared-stratum"` as the LAST entry of the `WIRED`
      array, and add a table row immediately after the `stab-depth-two-probe` row in the
      `# --- WIRED ---` table in the same two-column comment style: label it `E2 (probe iii)`,
      state in one or two lines the shared classes, the refuted shapes and the surviving ones,
      and what it holds in place (no one-bit-per-depth summary may be assumed by the time-axis
      route; the closure-indexed alphabet is what must be carried). No existing line is modified
      or removed. Do not write "task 739" in this file (it is outside `specs/**`); cite the
      probe by filename and label, as the neighbouring rows do.
- [x] Optional, at most one line: after "is a follow-up" in the landed probe's header, add
      "(the follow-up is `stab-depth-two-shared-stratum.lean`)". Nothing else in that file
      changes.
- [x] Run `bash scripts/check-evidence-probes.sh`; require exit 0 and the final line
      `PASS  all 20 wired probe(s) compile`.
- [x] Commit the probe file, the gate script, and (if edited) the landed probe by explicit
      paths; then `git diff --numstat HEAD~1 -- scripts/check-evidence-probes.sh` must show 0
      deletions.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: One header (~60 lines), one 29-line axiom foot, one `WIRED` entry plus one
table row (~20 comment lines), at most one pointer line in the landed probe; the gate's wired
count goes from 19 to 20 (re-derived at plan time: 19 entries in `WIRED`, 3 in `WIRED_REPO`,
gate reports the two summed — confirm from the gate's own `PASS all N wired probe(s)` line).

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` - final header, axiom foot
- `scripts/check-evidence-probes.sh` - append-only: one `WIRED` entry, one table row
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` - optional single pointer line in the header only

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 (check the exit status, not only the text);
  the new probe's line reads `PASS`; the total reads 20 (the changed script plus its enumerated
  dependents — every wired probe — is exactly what the gate run exercises, which is this
  phase's `interface` tier).
- `grep -c '^#print axioms Probe739SharedStratum\.' <probe>` is 29 and the compile output shows
  `[propext, Classical.choice, Quot.sound]` on every line, no `sorryAx`.
- `git diff --numstat` for the gate script shows additions only; the landed probe's diff is
  empty or a single added line.
- The header's "What is NOT established" contains the three exclusions (no decidability, no
  complexity bound, nothing about devices) and the one-bit-vs-closure-labelling distinction.

## Testing & Validation

- [x] `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean
      specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` exits 0 with no
      `error` and no `sorry`.
- [x] Every `#print axioms` line of the foot reports exactly `[propext, Classical.choice,
      Quot.sound]`.
- [x] `bash scripts/check-evidence-probes.sh` exits 0 and reports all 20 wired probes PASS
      (the landed `stab-depth-two-probe` row still PASS: its result is untouched).
- [x] The pinned statements drift-check clean: `bash .claude/scripts/lean-challenge-snapshot.sh
      --check 739 /home/benjamin/Projects/BimodalLogic` (advisory; exit 0 expected once the
      snapshot has been taken, or run `--dry-run` to confirm the identifier sets agree).
- [x] `lake build` is not affected (probes live outside the build graph); no file under
      `FormalSystem/` is modified (`git status --short FormalSystem/` empty).
- [x] The value table in Phase 2 is reproduced by the proved characterizations (manual read-off
      of each `_iff` right-hand side against the table).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/stab-depth-two-shared-stratum.lean` — the probe
  (header, fixture, five shapes direct and through the strata, certificates, positive and
  refutation theorems, axiom foot).
- `scripts/check-evidence-probes.sh` — one appended `WIRED` entry and one appended table row.
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` — optionally one pointer
  line.
- `specs/739_e2_depth_two_stratification_shared_stratum_falsifier/summaries/01_shared-stratum-falsifier-summary.md`
  — the implementation summary.

## Rollback/Contingency

- The change is additive: to revert, delete the new probe file and remove the two appended
  regions (the `WIRED` entry and the table row) from `scripts/check-evidence-probes.sh`, and
  drop the optional pointer line; nothing under `FormalSystem/` is touched, so `lake build` is
  never at risk.
- If a direct depth-2 value cannot be closed in Phase 2, do NOT weaken the statement to match
  what can be proved: record the shape as a `[COMPLETED WITH EXCLUSIONS]` reasoned exclusion
  naming the blocking subgoal, keep the other shapes, and keep the certificates (Phase 3) — the
  refutation on M1 at `b` vs `d` already compiled at research time and is the minimum
  deliverable.
- If the proved value table disagrees with the plan's table at some cell, that is a finding:
  record it in the header and the summary (with the fixpoint derivation of both readings), do
  not adjust the fixture to restore agreement.
- Use `bash .claude/scripts/git-snapshot.sh 739 --no-revert` for a defensive checkpoint before
  the Phase 4 script edit; never the reverting default (sibling task 740 shares the tree).

## Lean Challenge Statements

The 29 declarations this plan commits to, bodies `sorry` by this section's rule. The block
type-checked standalone against the tree at plan time (29 `declaration uses 'sorry'` warnings,
exit 0). Everything the statements need — the carrier and its instances, the graph, the
relation, the frame, its `IsRegular` instance and the model — sits in the preamble as `abbrev`s
or anonymous instances BEFORE the first pinned declaration, because the snapshot tool forces the
body of every `theorem`/`def`/named-`instance` to `sorry` and drops the text up to the next such
declaration; a `sorry`-bodied frame leaves the state carrier stuck (verified: `(τ.state t).2`
then fails with "Invalid projection"). The probe itself uses `def` for `edge`, `Rg`, `Fg`, `Mg`
(the landed probe's shapes); only the pinned theorem signatures must match verbatim, and the
bi-seriality proofs are the named theorems `Rg_fwd`/`Rg_bwd` passed to `ofSlicedStep` rather
than the inline discharges used here.

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.Conservativity

namespace Probe739SharedStratum

/-- The four-state carrier. -/
inductive S where
  | a | b | c | d
  deriving DecidableEq

instance : Fintype S := ⟨{.a, .b, .c, .d}, fun x => by cases x <;> simp⟩
instance : Finite S := Finite.of_fintype S
instance : Nonempty S := ⟨.a⟩

/-- The distinguished atom: `p` holds exactly at `b`. -/
abbrev pa : Atom := ⟨"p", none⟩

/-- `Fp`, the forward depth-0 core. -/
abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- `Pp`, the backward depth-0 core. -/
abbrev Pp : PlusFormula := somePast (.atom pa)

/-- The fresh atom naming `⊡Fp`. -/
abbrev qAtom (e : Encoding) : Atom := e.ι (.inr Fp)

/-- The fresh atom naming `⊡Pp`. -/
abbrev rAtom (e : Encoding) : Atom := e.ι (.inr Pp)

/-- The encoded copy of `p`. -/
abbrev pAtom (e : Encoding) : Atom := e.ι (.inl pa)

/-- The one-step graph: `a→a, a→b, b→b, b→d, d→b, c→c`. -/
abbrev edge : S → S → Bool
  | .a, .a => true | .a, .b => true
  | .b, .b => true | .b, .d => true
  | .d, .b => true
  | .c, .c => true
  | _, _ => false

/-- The time-independent one-step relation. -/
abbrev Rg : ℤ → S → S → Prop := fun _ u v => edge u v = true

/-- The fixture frame, regular by construction (bi-seriality discharged inline here; the probe
proves it as the named theorems `Rg_fwd`/`Rg_bwd` below and passes those instead). -/
abbrev Fg : FrameOver intOrder :=
  FrameOver.ofSlicedStep Rg
    (fun _ w => by cases w <;> first | exact ⟨.a, rfl⟩ | exact ⟨.b, rfl⟩ | exact ⟨.c, rfl⟩)
    (fun _ w => by cases w <;> first | exact ⟨.a, rfl⟩ | exact ⟨.b, rfl⟩ | exact ⟨.c, rfl⟩)

instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg _ _

/-- The fixture model: `p` holds exactly at `b`. -/
abbrev Mg : TaskModel Fg.toTaskFrame := { valuation := fun q _ => q.2 = S.b }

theorem Rg_fwd : ∀ (t : ℤ) (w : S), ∃ u, Rg t w u := sorry

theorem Rg_bwd : ∀ (t : ℤ) (w : S), ∃ v, Rg (t - 1) v w := sorry

theorem stab_will_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab Fp) ↔ ((τ.state t).2 = S.b ∨ (τ.state t).2 = S.d) := sorry

theorem stab_past_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab Pp) ↔ (τ.state t).2 = S.d := sorry

theorem depth2_S1_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      ((τ.state t).2 = S.b ∨ (τ.state t).2 = S.d) := sorry

theorem depth2_S2_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔ (τ.state t).2 ≠ S.a := sorry

theorem depth2_M1_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ↔
      ((τ.state t).2 = S.c ∨ (τ.state t).2 = S.d) := sorry

theorem depth2_M2_true (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) := sorry

theorem depth2_S1past_iff (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ↔ (τ.state t).2 = S.d := sorry

theorem stab_fp_iff_fresh (e : Encoding) (σ : WorldHistory Fg.toTaskFrame) (s : ℤ) :
    PlusTruthAt Mg σ s (.stab Fp) ↔ PlusTruthAt (Mg.atomModel e) σ s (.atom (qAtom e)) := sorry

theorem stab_pp_iff_fresh (e : Encoding) (σ : WorldHistory Fg.toTaskFrame) (s : ℤ) :
    PlusTruthAt Mg σ s (.stab Pp) ↔ PlusTruthAt (Mg.atomModel e) σ s (.atom (rAtom e)) := sorry

theorem depth2_via_strata_S1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t (.stab (someFuture (.atom (qAtom e)))) := sorry

theorem depth2_via_strata_S2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t
        (.stab (.imp (someFuture (.atom (pAtom e))) (.atom (qAtom e)))) := sorry

theorem depth2_via_strata_M1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t
        (.stab (.imp (someFuture (.atom (pAtom e))) (.atom (rAtom e)))) := sorry

theorem depth2_via_strata_M2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t
        (.stab (.imp (somePast (.atom (pAtom e))) (.atom (qAtom e)))) := sorry

theorem depth2_via_strata_S1past (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ↔
      PlusTruthAt (Mg.atomModel e) τ t (.stab (somePast (.atom (qAtom e)))) := sorry

theorem strata_is_atomize_S1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (someFuture (.stab Fp)))) := sorry

theorem strata_is_atomize_S2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Fp (.stab Fp)))) := sorry

theorem strata_is_atomize_M1 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Fp (.stab Pp)))) := sorry

theorem strata_is_atomize_M2 (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (.imp Pp (.stab Fp)))) := sorry

theorem strata_is_atomize_S1past (e : Encoding) (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) :
    PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ↔
      TruthAt (Mg.atomModel e) τ t (atomize e (.stab (somePast (.stab Fp)))) := sorry

theorem shared_false_stratum :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (τ.state t : ℤ × S).2 = S.a ∧ (τ'.state t' : ℤ × S).2 = S.c ∧
        (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) := sorry

theorem shared_true_stratum :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (τ.state t : ℤ × S).2 = S.b ∧ (τ'.state t' : ℤ × S).2 = S.d ∧
        (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) := sorry

theorem value_is_function_of_stratum_S1 (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ)
    (h : PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :
    PlusTruthAt Mg τ t (.stab (someFuture (.stab Fp))) ↔
      PlusTruthAt Mg τ' t' (.stab (someFuture (.stab Fp))) := sorry

theorem value_is_function_of_stratum_M2 (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ)
    (h : PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) :
    PlusTruthAt Mg τ t (.stab (.imp Pp (.stab Fp))) ↔
      PlusTruthAt Mg τ' t' (.stab (.imp Pp (.stab Fp))) := sorry

theorem value_is_function_of_stratum_S2_on_true_class (τ τ' : WorldHistory Fg.toTaskFrame)
    (t t' : ℤ) (hτ : PlusTruthAt Mg τ t (.stab Fp)) (hτ' : PlusTruthAt Mg τ' t' (.stab Fp)) :
    PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ↔
      PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Fp))) := sorry

theorem not_function_of_stratum_S2 :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) ∧
        ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Fp))) ∧
          PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Fp))) := sorry

theorem not_function_of_stratum_M1 :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) ∧
        ¬ PlusTruthAt Mg τ t (.stab (.imp Fp (.stab Pp))) ∧
          PlusTruthAt Mg τ' t' (.stab (.imp Fp (.stab Pp))) := sorry

theorem not_function_of_stratum_S1past :
    ∃ (τ τ' : WorldHistory Fg.toTaskFrame) (t t' : ℤ),
      (PlusTruthAt Mg τ t (.stab Fp) ↔ PlusTruthAt Mg τ' t' (.stab Fp)) ∧
        ¬ PlusTruthAt Mg τ t (.stab (somePast (.stab Fp))) ∧
          PlusTruthAt Mg τ' t' (.stab (somePast (.stab Fp))) := sorry

end Probe739SharedStratum
```
