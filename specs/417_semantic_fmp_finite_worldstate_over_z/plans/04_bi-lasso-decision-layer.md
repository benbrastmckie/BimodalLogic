# Implementation Plan: Task #417 — the bi-lasso decision layer (handoff Task A)

- **Task**: 417 - Semantic FMP, finite WorldState over ℤ
- **Status**: [IMPLEMENTING]
- **Effort**: 16.5 hours
- **Dependencies**: Task 414, Task 420, Task 438, Task 439 (semantics/frame prerequisites, all landed upstream of the phases below); Task 450 is a dependency of the DEFERRED half only (see Non-Goals) and does **not** gate any phase in this plan
- **Research Inputs**:
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/04_filteredstep-fwd-gating-spike.md` (primary)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/02_semantic-fmp-rescoped-z-time.md`
  - `specs/417_semantic_fmp_finite_worldstate_over_z/handoffs/01_phase-7-12-revision-handoff.md` (architecture of record, §4.2/§4.3/§5/§7)
- **Artifacts**: plans/04_bi-lasso-decision-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Handoff `01_phase-7-12-revision-handoff.md` §5 splits this task into three: **A** the bi-lasso
decision layer, **B** the filtered step relation, **C** the semantic FMP that consumes both. The
gating spike (report 04) then established, machine-checked, that **B has acquired a hard
precondition** — the restricted-MCS layer is pinned to `FrameClass.Base`, `filteredStep_fwd` is
*false* there, and re-parameterising that layer is now task 450, which is `[NOT STARTED]`.
Task A is the one half that is unblocked and independently shippable, and the handoff's
recommended order (A → B → C) is unchanged by the spike.

**This plan therefore implements Task A only**, plus one repair the spike's own evidence file now
needs. The deliverable is a decision procedure for presented ℤ-frames: a finitely-presented
bi-infinite ultimately-periodic path (`BiLasso`), an evaluator over it that recurses on the
formula with the path held fixed, its correctness bridge to `TruthAt`, a modal-depth-stratified
box oracle, a small-model theorem extracting a bounded bi-lasso from any satisfying history, and
`check` with a `Decidable` instance. Definition of done: all of the above sorry-free, `lake build`
green, live-sorry count unchanged at exactly 1.

### Research Integration

Four findings from report 04 and the handoff drive the phase structure:

1. **`check` must not recurse on the formula at a *state*.** `evidence/phase12-check-not-compositional.lean`
   refutes that signature outright. `eval` recurses on the formula with `(L, t)` **fixed**, and the
   `∃` over paths sits outside the recursion (handoff §4.2). This is the whole reason Task A is
   shaped the way it is.
2. **The lasso must be bi-infinite.** `mem_HF_iff_adjacent` (`Semantics/IntNormalForm.lean:306`)
   makes `H_F` over ℤ exactly the set of bi-infinite step-paths, and `snce` quantifies leftward.
   A right-only (prefix + loop) lasso makes the `snce` case non-terminating and the small-model
   theorem false as stated (handoff §3.2).
3. **Pigeonhole must range over `(state, type, pending)`.** Pigeonholing on state, or even on
   `state × type`, lets the extracted loop drop an eventuality obligation the original path
   discharged outside the loop. This is the standard Büchi degeneralisation step and the handoff
   (§4.2) names it as the single most likely place for this layer to go wrong.
4. **Phase 8 and Phase 11 of `plans/03` are landed and are consumed here, not rebuilt.**
   `FMP/Periodicity.lean` supplies `exists_bounded_iter`, `exists_lt_iter_of_card_le`,
   `exists_repeat_of_isStepPath`, `exists_path_of_iter`, `iter_of_path`;
   `Decidability/IntPresentation.lean` supplies `IntPresentation`, `toTaskFrame`, `toFiniteFrame`,
   `toModel`, `step_iff`, `isStepPath_iff`, `card_pos`.

### CORRECTION OF RECORD: the argument order in the inputs is retired

**Every `untl` / `snce` argument order stated in handoff 01 and report 04 is the retired
event-first order.** Task 448's guard-first migration landed *after* both were written — the spike
was committed at `36bc734aa` (2026-08-17 11:07), the migration ran `20c1d34de`…`65029d89d`
(12:43–15:51 the same day). The live constructors are now **guard first, event second**
(`Syntax/Formula.lean:85,97`; `specs/decisions/untl-snce-argument-order.md`, DECIDED 2026-08-17):

```lean
Formula.untl g e   -- guard g holds throughout the open interval; event e is witnessed at s > t
Formula.snce g e   -- guard g holds throughout the open interval; event e is witnessed at s < t
```

Three renderings legitimately coexist and each must be named where used: the **constructor** is
guard-first; `Formula.prettyPrint`'s prefix `U(e, g)` is **event-first**; the paper's infix
`φ U ψ` is guard-first. Report 04's prose uses prefix `U(e,g)` and is therefore still correct as
written; only its Lean terms are stale.

Consequence, machine-verified during planning: `lake env lean` on
`evidence/spike-untl-unfolding-and-fwd-obstruction.lean` now **fails**, with application type
mismatches at `:126`, `:135`, `:157`, `:159`, `:178` and beyond — e.g.
`Axiom.left_mono_until_G g g' e : Axiom ((g.imp g').allFuture.imp ((g.untl e).imp (g'.untl e)))`
against the file's expected `((e.untl g).imp (e.untl g'))`. Phase 1 repairs this. Getting the
order backwards is silent and expensive; every phase below states the order it uses.

Restated in the live order, handoff §4.4's table row and §4.1's unfolding read:

```
untl g e at t   ↔   e at t+1   ∨   ( g at t+1  ∧  untl g e at t+1 )
snce g e at t   ↔   e at t−1   ∨   ( g at t−1  ∧  snce g e at t−1 )
```

### Prior Plan Reference

`plans/03_semantic-fmp-z-time.md` closed 8 of 13 phases and was superseded in its phases 7, 9, 10,
12, 13 by handoff 01. Lessons carried forward rather than phases:

- **Effort calibration**: that dispatch landed 8 substantial Lean phases in one run, so the
  ~1.5–2h per-phase sizing below is calibrated, not aspirational.
- **The two blockers were both "state instead of path" errors.** This plan's entire architecture is
  the correction, so no phase here restates either refuted shape.
- **A blocked phase stopped the dispatch and produced usable evidence.** That discipline is
  retained verbatim in the verification contract below.
- No phase text is copied from `plans/03`; its Phase 8 and Phase 11 outputs are *consumed* as
  landed library content.

### Roadmap Alignment

No `specs/ROADMAP.md` exists in this repository; `roadmap_flag` was not set for this dispatch. No
roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- Repair `evidence/spike-untl-unfolding-and-fwd-obstruction.lean` to the live guard-first order so
  the spike's schema is re-verifiable and task 450 can cite a green artifact.
- Define `BiLasso`, `unroll`, and prove `unroll_isStepPath` — a finitely-presented, bi-infinite,
  ultimately-periodic step path over an `IntPresentation`.
- Prove the periodicity lemmas that bound the `untl` / `snce` scans, so `eval` terminates without
  well-founded recursion on ℤ.
- Define `eval` (recursing on the formula with the path and time fixed) and `BoxOracleSound`, and
  prove `eval_correct` against `TruthAt`.
- Enumerate bounded bi-lassos as a `Finset`/`List` with decidable membership.
- Prove the small-model theorem `exists_biLasso_of_truth` by `(state, type, pending)` pigeonhole.
- Construct a concrete box oracle by induction on `modalDepth` and prove it sound.
- Deliver `check`, `check_correct`, and a `Decidable` instance; wire the three evidence probes into
  the regression surface.

**Non-Goals**:

- **Task B is out of scope and is blocked.** No `filteredStep`, `filteredStep_fwd`,
  `filteredStep_bwd`, or `FilteredStepFrame` in the built library. Report 04 Finding 4 refutes
  `fwd` against the `Base`-fixed `ClosureMCS`; task 450 (deliverables (a) and (c)) is the
  precondition and is `[NOT STARTED]`.
- **Task C is out of scope.** No `Fulfilling`, no `truth_along_fulfilling`, no assembly of the
  semantic FMP. It depends on both A and B.
- **No frame-class re-parameterisation of the restricted-MCS layer.** That is task 450's charter
  and duplicating it here would collide with it.
- **No promotion of the spike schema into the library.** Report 04 recommendation 2 assigns that to
  task 450 deliverable (d). Phase 1 repairs the evidence file in place; it does not move
  declarations into `FormalSystem/Theorems/`.
- No edits under `/home/benjamin/Philosophy/Papers/` — read-only ground truth.
- No claim, in any docstring, that this decides the logic. `cor:tm-decidability` states decidability
  is **open**, and this layer decides only *presented* ℤ-frames.
- No `sorry`, in any form, including "removed next phase" scaffold.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 441 ("Effective periodic extension over finite frames", `[NOT STARTED]`) independently specifies a prefix-plus-cycle presentation in both directions — the same datatype as `BiLasso` | M | M | Verified at planning time: no `Lasso`/`extend_periodic`/periodic-presentation structure exists anywhere in the live tree, so there is nothing to collide with today. Phase 2 MUST re-run that check first; if 441 has landed a datatype by then, reuse it and record the decision instead of defining a second one. 441's `extend_periodic` is an *extension theorem*; `BiLasso` is a *presentation for evaluation* — related, not identical. |
| The `(state, type, pending)` pigeonhole (Phase 7) is the layer's crux and is rated "not verified against this tree" by handoff §8 | H | M | Phase 7 is sized as one phase and is a declared stop-and-escalate point. If the degeneralisation resists, mark `[BLOCKED]`, write the precise resisting goal state to `evidence/`, and stop — do not weaken the statement to something provable, and do not proceed to Phases 8–9, which consume it. |
| The box oracle (Phase 8) is circular with `eval` if built naively | M | M | Handoff §4.3: stratify by `modalDepth` (`Syntax/Formula.lean:397`), computing the oracle at depth `k` from an `eval` that only consults it at depth `< k`. `BoxOracleSound` is defined in Phase 4 as the invariant carried through that induction, so Phase 5 can prove `eval_correct` relative to it before any concrete oracle exists. |
| `TruthAt`'s `box` clause quantifies over **all** total world histories of the frame (`Semantics/Truth.lean:164`), not over the bi-lassos enumerated | H | M | This is exactly what makes the oracle depend on the small-model theorem, hence the ordering 7 → 8. Phase 8 must not assume "no enumerated bi-lasso refutes χ" implies "no history refutes χ" without citing Phase 7. |
| Argument-order transposition applied backwards somewhere | H | M | Every phase states the order it uses; Phase 1 is a dedicated transposition phase with a compile gate; the guard-first roles are quoted from `Syntax/Formula.lean:85,97` rather than from the handoff. |
| Repository-wide pre-existing red is mistaken for damage caused here | M | H | Known and inherited: `check-module-invariants.sh` C6 (`SoundnessLemmas/CoValidity.lean:104`), C9 (`WeakCanonical/PriorExpressivenessDense.lean:185`), `check-paper-definitions.sh` case (c), and `lake build BimodalTest` `#guard_msgs` drift in `BoxSpreadProbe`/`RegionGateProbe`/`TableauConformance`. Capture the baseline in Phase 1 and compare, never blame. |
| Scope creep from Task A into B or C once the layer works | M | M | Non-Goals above are enforced at every phase close; B's precondition is another task's deliverable and starting it here would produce work that cannot land. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 6 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 7 | 3, 5, 6 |
| 6 | 8 | 5, 7 |
| 7 | 9 | 5, 6, 7, 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Repair the spike evidence file to guard-first order [COMPLETED]

**Goal**: `evidence/spike-untl-unfolding-and-fwd-obstruction.lean` compiles clean again against the
migrated tree, with its nine `#print axioms` audits still reporting no `sorryAx`, and its header
docstring recording the transposition.

**Tasks**:
- [x] Capture the repository baseline first: `bash scripts/check-module-invariants.sh` and
      `lake build` output, recorded so later phases can distinguish inherited red from new red.
- [x] Re-run `lake env lean specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`
      and capture the **complete** error list (planning captured only the first 40 lines).
- [x] Transpose every `Formula.untl` / `Formula.snce` application to guard-first. Confirmed anchors
      from the live tree: `Axiom.left_mono_until_G g g' e` varies the **guard** (first argument);
      `Axiom.right_mono_until e e' g` varies the **event** (second argument);
      `Axiom.prior_UZ φ : φ.someFuture.imp (φ.neg.untl φ)`, i.e. guard `¬φ`, event `φ`.
- [x] Fix `nxt` (`:48`): it must become `Formula.untl Formula.bot ψ` — guard `⊥` (empty open
      interval), event `ψ`. The file currently has the arguments the other way round.
- [x] Replace the file's own convention paragraph (`:45`) with the live guard-first statement and a
      dated note that the event-first text it replaces is retired.
- [x] Re-run the `#print axioms` block and confirm all nine declarations still report
      `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the hypothesis is that **every** error in this file is an argument-order
transposition and nothing else drifted (no axiom was renamed, restated, or removed by the
migration). Confirm by reading the full error list before editing, and by checking each cited
`Axiom.*` signature with `lean_hover_info` rather than assuming. If any error is not a
transposition, record it and re-scope this phase rather than absorbing it silently.

**Files to modify**:
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean` — guard-first transposition and header correction

**Verification**:
- `lake env lean` on the file exits 0 with no errors and no `sorry`.
- Nine `#print axioms` lines, none containing `sorryAx`.
- The file remains outside `lake build` (report 04 Decisions: wiring it in would make the library
  depend on a spike). Phase 9 revisits the regression-guard wiring question.

---

### Phase 2: `BiLasso` datatype, `unroll`, and `unroll_isStepPath` [NOT STARTED]

**Goal**: a finitely-presented bi-infinite step path over an `IntPresentation`, with its decoding
proved to land in the frame's step paths.

**Tasks**:
- [ ] Re-run the duplication check before writing anything:
      `grep -rn "structure .*Lasso\|extend_periodic" FormalSystem/ --include=*.lean | grep -v Boneyard`.
      Empty at planning time. If non-empty, reuse and record; do not define a second datatype.
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` and
      `FormalSystem/Metalogic/Decidability/BiLasso/README.md`.
- [ ] Define `structure BiLasso (P : IntPresentation)` with `back`, `mid`, `fwd : List (Fin P.card)`,
      `back_ne`, `fwd_ne`, and a `coherent` field covering adjacency within each segment, the three
      seams, and the two wrap-arounds. Prefer plain `List` and `Int` over dependent packaging so the
      object stays serializable.
- [ ] Define `BiLasso.unroll (L) : ℤ → Fin P.card` — `mid` on its finite window, `fwd` repeated
      rightward, `back` repeated leftward.
- [ ] Prove `BiLasso.unroll_isStepPath : IsStepPath P.toTaskFrame L.unroll`, via `P.step_iff` and
      `P.isStepPath_iff`.
- [ ] Provide `BiLasso.toHF := HFofStepPath _ _ L.unroll_isStepPath` so the path is usable as an
      element of `H_F` (`IntNormalForm.lean:281`).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` — new
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Basic` exits 0.
- No `sorry`; no vacuous definition (`coherent` must have a non-trivial instance exhibited in a
  docstring example or test, so it cannot be silently `True`).

---

### Phase 3: Periodicity of `unroll` and the bounded-scan lemmas [NOT STARTED]

**Goal**: the lemmas that make the `untl` / `snce` cases of `eval` finite scans rather than
searches over ℤ.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Unroll.lean`.
- [ ] Prove rightward periodicity: `∃ n₁, ∀ t ≥ n₁, L.unroll (t + L.fwd.length) = L.unroll t`.
- [ ] Prove leftward periodicity: `∃ n₀, ∀ t ≤ n₀, L.unroll (t - L.back.length) = L.unroll t`.
- [ ] Derive the scan bounds: any property of `L.unroll` that holds at some `s > t` holds at some
      `s` with `t < s ≤ t + |mid| + |fwd|` (and the leftward mirror). State these as the two lemmas
      `eval`'s temporal cases consume, in exactly the form they will be consumed.
- [ ] Do **not** attempt well-founded recursion on ℤ; the handoff (§4.2) is explicit that
      periodicity is the intended route.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Unroll.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Unroll` exits 0, sorry-free.
- The two scan-bound lemmas are stated with explicit bounds, not existentially with an unbounded
  witness — an unbounded statement would not discharge `eval`'s termination.

---

### Phase 4: `eval` and `BoxOracleSound` [NOT STARTED]

**Goal**: an evaluator that recurses on the formula with `(L, t)` **fixed**, parameterised by an
abstract box oracle, plus the soundness invariant that oracle must satisfy.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Eval.lean`.
- [ ] Define `eval (P) (bx : Formula → Bool) (L : BiLasso P) : ℤ → Formula → Bool` by recursion on
      the formula: `atom` via `P.val`, `bot`, `imp`, `box` via `bx`, and `untl g e` / `snce g e`
      via the Phase 3 bounded scans. **Guard-first**: in `untl g e`, `e` is the event sought at
      `s > t` and `g` the guard required on the open interval.
- [ ] Discharge termination from the bounded scans (the recursion is structural on the formula; the
      scans are finite `List.any`/`List.all` over an explicit range).
- [ ] Define `BoxOracleSound P bx : Prop` — `∀ χ, bx χ = true ↔ ∀ σ : WorldHistory P.toTaskFrame,
      σ.IsTotal → TruthAt P.toModel σ t χ` — in the shape Phase 5 consumes and Phase 8 establishes.
      Use `box_const` (`Semantics/Truth.lean:740`) to justify that the statement need not be
      time-indexed.
- [ ] Add a docstring paragraph naming the refuted alternative (`check P w φ` recursing on `φ` at a
      *state*) and pointing at `evidence/phase12-check-not-compositional.lean`, so the design is not
      re-litigated.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Eval.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Eval` exits 0, sorry-free.
- `eval` elaborates without `partial` and without `decreasing_by sorry`.
- `#eval` smoke test on a two-state presentation returns the expected `Bool` for a
  hand-checked `untl` and a hand-checked `snce`.

---

### Phase 5: `eval_correct` [NOT STARTED]

**Goal**: `eval` agrees with `TruthAt` along `L.unroll`, given a sound oracle.

**Tasks**:
- [ ] Prove `eval_correct (hbx : BoxOracleSound P bx) (L) (t) (φ) :
      eval P bx L t φ = true ↔ TruthAt P.toModel L.toHF.val t φ`, by induction on `φ`.
- [ ] `atom` / `bot` / `imp`: direct from `P.toModel_valuation` and `Truth.lean`'s `imp_iff`.
- [ ] `box`: immediate from `hbx` — this is the entire reason the oracle is a hypothesis here rather
      than a construction.
- [ ] `untl g e`: `→` from the scan witness; `←` from the Phase 3 scan bound applied to the
      semantic witness. Mirror for `snce g e`. Re-read the live clause
      (`Semantics/Truth.lean:165-168`) at the start of this phase rather than trusting any quoted
      form — the clause binds the **first** constructor argument as the guard.
- [ ] Add the argument-order regression note to the docstring: the guard is argument 1.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Eval.lean` — `eval_correct` and its supporting lemmas

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Eval` exits 0, sorry-free.
- `#print axioms` on `eval_correct` reports no `sorryAx`.
- The statement quantifies over all `φ` — no closure restriction, no frame-class side condition.

---

### Phase 6: Bounded enumeration of bi-lassos [NOT STARTED]

**Goal**: `boundedBiLassos P n : List (BiLasso P)` (or `Finset`), containing every bi-lasso whose
three segments are bounded by `n`, with decidable membership.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean`.
- [ ] Define `boundedBiLassos P n` by enumerating segment lists over `Fin P.card` up to length `n`
      and filtering on the decidable `coherent` predicate.
- [ ] Prove completeness: every `L : BiLasso P` with all three segments of length `≤ n` appears.
- [ ] Prove soundness: every element is a genuine `BiLasso P` (immediate if the filter is on the
      structure's own field).
- [ ] Supply the `DecidablePred` instances the filter needs, mirroring `IntPresentation`'s existing
      `DecidablePred` on `stepRel` (`IntPresentation.lean:96`).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Enumerate` exits 0, sorry-free.
- `#eval (boundedBiLassos P 2).length` terminates on a two-state presentation and the count is
  hand-checkable.

---

### Phase 7: The small-model theorem [NOT STARTED]

**Goal**: `exists_biLasso_of_truth` — if a formula is true at `(τ, t)` for some total history of
the presentation, a bounded bi-lasso witnessing it exists.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean`.
- [ ] Define the pigeonhole datum as the **triple** `(state, type, pending)`: the state
      `τ.path t`, the *type* `{χ ∈ subformulaClosure φ | TruthAt … t χ}`, and *pending*, the set of
      as-yet-undischarged eventuality obligations. Pigeonholing on `state`, or on `state × type`,
      is the known failure mode (handoff §4.2) — an extracted loop may drop an obligation the
      original path discharged outside it.
- [ ] Prove the triple space finite: `Fin P.card × Finset (subformulaClosure φ) × Finset (…)`.
- [ ] Extract the forward loop with `exists_bounded_iter` (`FMP/Periodicity.lean:183`) and splice
      with `exists_lt_iter_of_card_le` (`:140`); mirror leftward for the backward loop, using
      `exists_repeat_of_isStepPath` (`:122`) on the presentation's converse.
- [ ] Assemble the extracted segments into a `BiLasso P`, discharging `coherent` from the source
      path's adjacency.
- [ ] State the bound explicitly in terms of `P.card` and `subformulaClosureCard φ`
      (`Syntax/SubformulaClosure/Closure.lean:56`).
- [ ] Prove `exists_biLasso_of_truth`, concluding via `eval_correct`.

**Timing**: 2 hours

**Depends on**: 3, 5, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the asserted bound is `|triple space| = P.card · 2^k · 2^k` with
`k = subformulaClosureCard φ`, and the hypothesis is that this bound is both *achievable* by the
extraction above and *sufficient* for the enumeration in Phase 9. Confirm at implementation time by
deriving the bound from the finiteness proof rather than asserting it, and by checking that the
`bound` function Phase 9 passes to `boundedBiLassos` is exactly this quantity. If the derived bound
differs, update Phase 9's `bound` and say so — do not leave the two out of step.

**This phase is a declared stop-and-escalate point.** If the degeneralisation resists, mark the
phase `[BLOCKED]`, write the precise resisting goal state to `evidence/`, and stop. Do not weaken
the statement to a provable but useless form, and do not start Phases 8 or 9, both of which consume
this result.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.SmallModel` exits 0, sorry-free.
- `#print axioms exists_biLasso_of_truth` reports no `sorryAx`.
- The docstring states the bound and names the degeneralisation step explicitly.

---

### Phase 8: The box oracle by modal-depth stratification [NOT STARTED]

**Goal**: a concrete `bx` with `BoxOracleSound P bx` proved, breaking the `eval` ↔ oracle
circularity.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean`.
- [ ] Define `boxOracle P : Formula → Bool` by strong recursion on `modalDepth`
      (`Syntax/Formula.lean:397`): at depth `k`, decide `□χ` as "no bounded bi-lasso refutes `χ`",
      evaluating `χ` with an `eval` that consults the oracle only at depth `< k`.
- [ ] Prove the stratification well-founded — every `□`-subformula consulted has strictly smaller
      modal depth than the formula being decided.
- [ ] Prove `BoxOracleSound P (boxOracle P)`, using Phase 7 to bridge "no *enumerated* bi-lasso
      refutes `χ`" to "no *total history* refutes `χ`". The `box` clause of `TruthAt`
      (`Semantics/Truth.lean:164`) quantifies over all total world histories of the frame, so this
      bridge is load-bearing and must cite Phase 7 rather than assume it.
- [ ] Cite `box_const` (`Semantics/Truth.lean:740`) for history-independence of `□`.

**Timing**: 2 hours

**Depends on**: 5, 7

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.BoxOracle` exits 0, sorry-free.
- `#print axioms boxOracle_sound` reports no `sorryAx`.
- The oracle elaborates without `partial`.

---

### Phase 9: `check`, `check_correct`, `Decidable`, and regression wiring [NOT STARTED]

**Goal**: the shipped decision procedure, plus the module re-export, README updates, and the
evidence probes wired in as permanent regression guards.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean`.
- [ ] Define `check P w φ : Bool` as `decide (∃ L ∈ boundedBiLassos P (bound P φ),
      L.unroll 0 = w ∧ eval P (boxOracle P) L 0 φ)` — the `∃` sits **outside** the recursion on
      `φ`, which is precisely why `no_compositional_imp` does not touch it. Say so in the docstring.
- [ ] Prove `check_correct` from `eval_correct` and `exists_biLasso_of_truth`.
- [ ] Provide the `Decidable` instance for satisfiability-in-a-presentation.
- [ ] Add `FormalSystem/Metalogic/Decidability/BiLasso.lean` as the subdirectory re-export, matching
      the existing `FMP.lean` re-export convention.
- [ ] Update `FormalSystem/Metalogic/Decidability/README.md`'s module table with the new
      subdirectory, and finalise `BiLasso/README.md`.
- [ ] Wire the evidence probes in as regression guards, per handoff §7. Treat
      `phase7-filtered-frame-is-universal.lean` and `phase12-check-not-compositional.lean` as the
      two guards to wire now; `spike-untl-unfolding-and-fwd-obstruction.lean` stays *out* of the
      build until task 450 lands, per report 04 recommendation 5, and the reason is recorded in
      `BiLasso/README.md`.
- [ ] Run `bash scripts/readme-lint.sh` and `bash scripts/check-task-references.sh` — no task-number
      citations may appear in any `.lean` file or `README.md` (`.claude/rules/no-task-references-in-deliverables.md`).

**Timing**: 1.5 hours

**Depends on**: 5, 6, 7, 8

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **three** evidence probes exist, of which **two** are
wired in and one deferred. Confirm by `ls specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`
at implementation time and by checking each probe's compile status individually — a probe that is
already red for an unrelated reason must be reported, not wired in red. The wiring mechanism itself
(a `Tests/` module, a `lake env lean` invocation in `check-module-invariants.sh`, or an entry in
the lakefile) is not fixed here; choose the one consistent with how the repository already runs
non-library checks and record the choice.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` — new
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` — new re-export
- `FormalSystem/Metalogic/Decidability/README.md` — module table row
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — finalise
- the regression-wiring target chosen above (script or test module)

**Verification**:
- Full gate set: `lake build` exits 0; `bash scripts/check-module-invariants.sh` shows no
  regression against the Phase 1 baseline; live-sorry count exactly 1
  (`countermodel_discrete`, `WeakCanonical/Transfer.lean`), via the invariant script, never naive
  grep.
- `#print axioms check_correct` reports no `sorryAx`.
- `bash scripts/check-task-references.sh` passes.
- Both wired probes are green.

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase close.
- [ ] Repository live-sorry count is exactly 1 at every phase close, verified with
      `bash scripts/check-module-invariants.sh` — **never** naive grep.
- [ ] `#print axioms` on `eval_correct`, `exists_biLasso_of_truth`, `boxOracle_sound`, and
      `check_correct`: no `sorryAx` in any.
- [ ] No vacuous definitions. In particular `BiLasso.coherent` and `BoxOracleSound` must each have
      a non-trivial witness exhibited, so neither can silently be `True`.
- [ ] `#eval` smoke tests on a small presentation for `eval` (Phase 4), `boundedBiLassos`
      (Phase 6), and `check` (Phase 9).
- [ ] `bash scripts/readme-lint.sh` and `bash scripts/check-task-references.sh` pass.
- [ ] Inherited red is unchanged, not worsened: `check-module-invariants.sh` C6 and C9,
      `check-paper-definitions.sh` case (c), and `lake build BimodalTest` `#guard_msgs` drift in
      `BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`. Compare against the Phase 1
      baseline before attributing any failure to this work.
- [ ] Argument order: every new `untl` / `snce` occurrence is guard-first, argument 1 the guard.

## Artifacts & Outputs

- `specs/417_semantic_fmp_finite_worldstate_over_z/plans/04_bi-lasso-decision-layer.md` (this file)
- `specs/417_semantic_fmp_finite_worldstate_over_z/summaries/04_bi-lasso-decision-layer-summary.md`
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Unroll.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Eval.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md`
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` (re-export)
- `FormalSystem/Metalogic/Decidability/README.md` (module table row)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean` (repaired)

## Rollback/Contingency

Every phase is additive: new modules under `Decidability/BiLasso/`, nothing live imports them until
Phase 9's re-export. Reverting any phase is `git revert` of that phase's commit; nothing downstream
breaks, because nothing downstream depends on this subtree until Phase 9.

The two exceptions, both in Phase 1 and Phase 9, touch shared surface: Phase 1 edits an evidence
file (already red, so reverting restores a red file — acceptable), and Phase 9 edits
`Decidability/README.md` plus a regression-wiring target. Take
`bash .claude/scripts/git-snapshot.sh 417` before Phase 9 if the wiring choice turns out to touch
`lakefile.lean`.

**Never discard uncommitted changes to reach a passing build.** Fix forward; if a phase cannot be
made green, mark it `[BLOCKED]`, write the resisting goal state to `evidence/`, and stop — the
contingency for Phase 7 in particular is escalation, not a weakened statement.

## Deferred Scope and the Re-Plan Trigger

Tasks B and C of handoff §5 remain open and are **not** planned here:

- **Task B** (`filteredStep`, `filteredStep_fwd` / `_bwd`, `FilteredStepFrame`) is blocked on task
  450 deliverables (a) — parameterise `RestrictedConsistent` / `RestrictedMCS` /
  `closure_mcs_deductively_closed` by `{fc : FrameClass}` — and (c) — the Discrete-system
  consistency lemma. Re-plan B once 450 is `[COMPLETED]`, taking report 04 recommendation 3's
  four-part re-scope as the starting point, with the risk located in the successor construction,
  not in the axiom base.
- **Task C** (`Fulfilling`, `truth_along_fulfilling`, the semantic FMP assembly) depends on both A
  and B and carries the highest risk of the three. It should not be dispatched until both are
  green.

When this plan completes, the correct next action is **not** `/implement 417` again but a re-plan
of B (once 450 lands) and then C.
