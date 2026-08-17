# Implementation Plan: Task #417 — the annotated bi-lasso decision layer (handoff Task A)

- **Task**: 417 - Semantic FMP, finite WorldState over ℤ
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours total; 3.5 landed (Phases 1–2), 16.5 remaining (Phases 4–12)
- **Dependencies**: Task 414, Task 420, Task 438, Task 439 (semantics/frame prerequisites, all landed upstream); Task 450 gates the DEFERRED half only (see Non-Goals) and does **not** gate any phase here; Task 441 is a *coordination* dependency only (see Risks) and gates nothing
- **Research Inputs**:
  - `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean` (**primary** — the machine-checked refutation that forced this revision)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/.orchestrator-handoff.json` (dispatch 3 blocker record)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/04_filteredstep-fwd-gating-spike.md`
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/02_semantic-fmp-rescoped-z-time.md`
  - `specs/417_semantic_fmp_finite_worldstate_over_z/handoffs/01_phase-7-12-revision-handoff.md` (architecture of record, §4.1/§4.2/§4.3/§4.5/§5/§7)
- **Artifacts**: plans/05_annotated-bi-lasso-decision-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan supersedes `plans/04_bi-lasso-decision-layer.md`. Its scope boundary is unchanged: it
implements handoff §5's **Task A** (the bi-lasso decision layer) only. Tasks B and C remain
deferred, B blocked on task 450.

What changed is the *architecture of the evaluation layer*, and only because a deliverable was
proved false. Plan 04's Phase 3 asked for a scan bound computed from the lasso's segment lengths:
"any property of `L.unroll` that holds at some `s > t` holds at some `s` with
`t < s ≤ t + |mid| + |fwd|`". Read in the form Phases 4–5 consume it — as a bound on the
*semantic* witness that `eval`'s `untl` case must find — this is **false**, and the implementation
dispatch refuted it rather than merely doubting it
(`evidence/phase3-scan-bound-is-false.lean`, sorry-free, `lake env lean` exits 0):

- `plan_scan_bound_fails` — the literal bound fails already at the atomic formula.
- `no_formula_independent_scan_bound` — for **every** integer `N` there is a formula witnessed
  strictly after `t = -1` but at no time in `(-1, N]`, on one **fixed** bi-lasso
  (`|back| = 1`, `|mid| = 0`, `|fwd| = 1`). The witness family is `prevⁿ p`, whose truth set along
  that path is exactly `[n, ∞)`. Since `N` ranges over every quantity computable from the segment
  lengths and `t`, no scan bound that is a function of the lasso alone can be correct.

The root cause is precise and worth stating once, because the whole revision follows from it:
`L.unroll (t + |fwd|) = L.unroll t` for `t ≥ |mid|` is true and is landed, but the *shifted path*
`λ u. L.unroll (u + |fwd|)` is not `L.unroll` — the leftward tail moves. So the **state sequence**
is periodic while **formula truth along it is not**. Formula truth at `t` is not a function of the
state at `t`.

### The routes, evaluated

The dispatch documented two routes and recommended route 2. Both were evaluated here against the
evidence and against the live tree; the recommendation is **accepted**, but on stronger and partly
different grounds than the dispatch gave, and with two corrections to its framing.

| | **Route 1** — formula-dependent threshold | **Route 2** — annotated bi-lassos |
|---|---|---|
| Statement needed | Truth along a bi-lasso is eventually periodic beyond a `ψ`-dependent threshold | Truth along a *fulfilling, locally coherent, type-annotated* bi-lasso equals label membership |
| Is it true? | **Yes** — verified by derivation during this revision (sketch below). The refutation does not touch it: `prevⁿ p`'s truth set `[n, ∞)` *is* right-periodic beyond threshold `n`. | **Yes** — it is handoff §4.5's `truth_along_fulfilling`, restricted to a lasso |
| Where the difficulty sits | One monolithic simultaneous induction: right-threshold and left-threshold defined by mutual recursion (`snce` grows the right threshold by `|fwd|`, `untl` grows the left by `|back|`), four witness-shifting cases, and a stabilisation case split on whether the guard survives a full period | Two crux theorems (truth lemma, small-model pigeonhole), each independently sized and independently escalatable |
| Does the refuted lemma survive? | No — replaced by a formula-indexed bound | **Yes, in corrected form** — see below |
| Reuse downstream | None. Task C consumes nothing from it | The truth lemma *is* the lasso instance of §4.5, which Task C needs; §4.6 says the extraction argument must not be written twice |
| Executable artifact | A genuinely runnable `eval : ℤ → Formula → Bool` | `check` is a search over annotations: correct and decidable, but combinatorially far worse |
| Verdict | Viable, and this is not a "route 1 is wrong" judgment | **Chosen** |

**Two corrections to the dispatch's framing of route 2**, both material to planning:

1. **Route 2 does not discard Phase 3's scan bound — it relocates it to where it is true.** The
   refutation's force is exactly "formula truth is not a function of the state at a time". Label
   *membership* **is** a function of the annotation at a position, and the annotation is presented
   as three lists, so it is periodic **by construction** — the same way the state sequence is.
   Phase 3's original sentence is therefore recovered verbatim with "property of `L.unroll`"
   replaced by "property of the annotation at a position", and it is needed, in Phase 8, to make
   `Fulfilling` decidable. Phase 3 was half right; the revision keeps the right half rather than
   throwing the phase away.

2. **The refutation, read through route 2, promotes handoff §4.2's pigeonhole advice from a
   recommendation to a necessity, and supplies the missing reason.** Handoff §8 rates
   "pigeonhole must range over `(state, type, pending)`" as *medium-high, not verified against this
   tree*. It can now be verified against the tree, from the refutation's own witness: on the lasso
   `|back| = 1, |mid| = 0, |fwd| = 1`, any annotation is forced to give `prev⁵ p` the same
   membership at every `t ≥ 0`, while the semantics gives it truth set `[5, ∞)`. So **that lasso
   admits no consistent annotation for that closure at all**. Nothing is contradicted — annotated
   lassos are simply required to be long enough for the formula, and pigeonholing on the triple
   cannot close a loop until the *types* repeat, which is exactly what makes the extracted lasso
   long enough. Pigeonholing on `state` alone would produce the refutation's own lasso and fail.

**For the record, route 1's mathematics** (recorded so a future revision does not have to
re-derive it, and so the choice stays revisitable): the right threshold satisfies
`thr⁺(untl g e) = max(thr⁺ g, thr⁺ e)` — `untl` looks only forward, into the already-periodic tail —
while `thr⁺(snce g e) = max(thr⁺ g, thr⁺ e) + |fwd|`, because for `t` beyond one full period past
`N` the "witness left of `N`" disjunct has stabilised: either `g` survives a whole period at
`[N, N+|fwd|)`, in which case it survives forever by periodicity and the disjunct is constant, or
`g` fails somewhere in that period, in which case the disjunct is dead for all larger `t`. The
left thresholds mirror, with `untl` growing them by `|back|`. Bounded scans follow by pulling a
witness back one period at a time, which is safe because shrinking the interval only weakens the
guard obligation.

### Research Integration

Newly integrated into this revision, beyond plan 04's inputs:

1. **`evidence/phase3-scan-bound-is-false.lean`** (new since plan 04) — drives the entire
   architecture change, as set out above.
2. **`.orchestrator-handoff.json` dispatch 3** — records that Phases 1–2 landed sorry-free, that
   Phase 6 of plan 04 was *not* started only because of the stop-on-blocked rule, and that
   inherited red is unchanged against baseline.
3. **`box_const` is stronger than plan 04 assumed** — verified this revision at
   `FormalSystem/Semantics/Truth.lean:740`: it gives independence of **both** the history **and**
   the time (`TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box`), with `box_time_const` at `:754` as the
   same-history specialisation. Consequence: an annotation's box entries are a single global
   `Formula → Bool`, not a per-position field. This is a genuine simplification of the annotation
   datatype and is used in Phase 6.
4. **Existing Hintikka machinery exists in the tree and is `[NOT REUSED]` — deliberately, with a
   recorded reason.** `FormalSystem/Metalogic/BXCanonical/Quasimodel/` supplies
   `HintikkaPoint`, `HintikkaStep`, `UntilDefect`, `SinceDefect`, `QuasimodelChain`. It is *not*
   the object needed here: `HintikkaPoint` carries only `subset_sigma`, `locally_consistent` and
   `bot_free` — no atom clause, no `imp` clause, no box clause, and its step relation is stated
   with `allFuture`/`allPast` propagation for the Burgess–Xu completeness proof, not with the exact
   ℤ one-step unfolding. It also sits on the MCS/proof-theoretic side (`BXPoint`,
   `noncomputable sigmaSignatureFormulas`), and importing it into `Decidability/` would point the
   dependency the wrong way for a computable `check`. Phase 6 must re-read those files before
   defining anything and record the comparison in a docstring. **Additionally**: the argument roles
   in `UntilDefect` / `SinceDefect` / `HintikkaStep` read as possibly stale against the guard-first
   migration — do **not** silently "fix" them; they are outside this plan's scope. If the roles are
   genuinely transposed there, report it for a separate task.
5. **The exact ℤ one-step unfolding of `TruthAt` is an unmet prerequisite, not an assumption.**
   Handoff §4.1 asserts it; the tree contains only the `⊥`-guarded special case, proved inside the
   refutation file as `truth_prev`. Phase 4 makes the general form a first-class deliverable,
   because Phases 7 and 10 both consume it and Task C will too.

### CORRECTION OF RECORD: the argument order (carried forward from plan 04, re-verified)

The live constructors are **guard first, event second**. Re-verified against
`FormalSystem/Semantics/Truth.lean:165-168` during this revision:

```lean
| Formula.untl ψ φ => ∃ s : D, t < s ∧ TruthAt M τ s φ ∧ ∀ r : D, t < r → r < s → TruthAt M τ r ψ
| Formula.snce ψ φ => ∃ s : D, s < t ∧ TruthAt M τ s φ ∧ ∀ r : D, s < r → r < t → TruthAt M τ r ψ
```

The **first** constructor argument is the guard (holds strictly between), the **second** is the
event (holds at the witness). Written with role names:

```lean
Formula.untl g e   -- guard g throughout the open interval; event e witnessed at s > t
Formula.snce g e   -- guard g throughout the open interval; event e witnessed at s < t
```

Restated in the live order, the exact ℤ unfolding (Phase 4's deliverable) reads:

```
untl g e at t   ↔   e at t+1   ∨   ( g at t+1  ∧  untl g e at t+1 )
snce g e at t   ↔   e at t−1   ∨   ( g at t−1  ∧  snce g e at t−1 )
```

Every `untl`/`snce` term in handoff 01 and report 04 is the **retired event-first order**; their
prose is fine, their Lean terms are stale. Every phase below states the order it uses. Getting it
backwards is silent and expensive.

### Mapping from plan 04

Nothing from plan 04 is silently dropped. Every phase is accounted for:

| plan 04 | status | disposition in this plan |
|---|---|---|
| 1 — spike repair | [COMPLETED] | **preserved verbatim**, Phase 1 |
| 2 — `BiLasso`, `unroll`, `unroll_isStepPath`, `toHF` | [COMPLETED] | **preserved verbatim**, Phase 2 |
| 3 — periodicity + scan bounds | [BLOCKED] | Phase 3, closed as `[COMPLETED WITH EXCLUSIONS]`: the two periodicity lemmas landed in `Basic.lean`; the scan-bound half is excluded as refuted, and is **recovered in corrected form** in Phase 8 |
| 4 — `eval`, `BoxOracleSound` | [NOT STARTED] | `eval` **retired** (its `untl` case is what the refutation kills). `BoxOracleSound` survives, in Phase 6 |
| 5 — `eval_correct` | [NOT STARTED] | **replaced** by Phase 7's `truth_along_annot` (label read-off instead of evaluation) |
| 6 — `boundedBiLassos` | [NOT STARTED] | **survives**, extended to annotated lassos, as Phase 9 |
| 7 — small-model theorem | [NOT STARTED] | **survives**, restated over annotated lassos, as Phase 10 |
| 8 — box oracle | [NOT STARTED] | **survives essentially unchanged**, as Phase 11 |
| 9 — `check`, wiring | [NOT STARTED] | **survives**, redefined over annotations, as Phase 12 |

### Roadmap Alignment

No `specs/ROADMAP.md` exists in this repository; `roadmap_flag` was not set for this dispatch. No
roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- Preserve Phases 1–2 exactly as landed. They are sorry-free and committed; they are consumed, not
  rebuilt.
- Close Phase 3 honestly: keep the two landed periodicity lemmas, record the refuted half as a
  reasoned exclusion with its machine-checked evidence.
- Prove the exact ℤ one-step unfolding of `TruthAt` for `untl` and `snce`, in the live guard-first
  order — the prerequisite handoff §4.1 asserts but the tree does not contain.
- Define an **annotated bi-lasso**: a landed `BiLasso P` plus a per-position type label, presented
  as three lists of `Finset Formula` matching the three segment lengths, decoded by the same
  periodic scheme.
- Define `LocalCoherent` (the semantic Hintikka conditions, including the one-step unfolding
  clauses), `Fulfilling` (the global eventuality-discharge condition), and `BoxOracleSound`.
- Prove `truth_along_annot`: along a locally coherent, fulfilling annotated bi-lasso, and relative
  to a sound box oracle, `TruthAt` at a position equals membership in that position's label, for
  every formula in the closure.
- Recover Phase 3's scan bound in corrected form over label membership, and use it to make
  `LocalCoherent` and `Fulfilling` decidable.
- Enumerate bounded annotated bi-lassos as a `List` with decidable membership.
- Prove the small-model theorem by `(state, type, pending)` pigeonhole.
- Construct a box oracle by `modalDepth` stratification and prove it sound.
- Deliver `check`, `check_correct`, and a `Decidable` instance; wire the evidence probes into the
  regression surface.

**Non-Goals**:

- **`eval` is retired and must not be reintroduced.** No `def eval … : ℤ → Formula → Bool` with a
  lasso-computed scan range. `evidence/phase3-scan-bound-is-false.lean` is the standing refutation
  and is a permanent regression guard against it, alongside
  `evidence/phase12-check-not-compositional.lean`.
- **No route-1 machinery.** No eventual-periodicity-of-`TruthAt` theorem, no formula-indexed
  threshold function. Route 1 is viable but is not the chosen route; building both is waste. If
  route 2's Phase 7 or Phase 10 blocks, route 1 is the documented fallback (see
  Rollback/Contingency), not something to hedge with now.
- **No modification of `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`.** It is landed,
  green, and task 441 is expected to consume it. Additive new files only. In particular, do **not**
  refactor `Basic.lean`'s `cyc`/`unrollOf` onto the generic version Phase 5 introduces — that is a
  441-coordination decision, not this plan's.
- **No `ClosureMCS`, no `BXPoint`, no derivability, no `BXCanonical` import.** The annotation's
  conditions are stated semantically. This layer needs no proof theory at all, and pulling the MCS
  layer in would drag `noncomputable` into a computable `check`.
- **Task B is out of scope and is blocked.** No `filteredStep`, `filteredStep_fwd`,
  `filteredStep_bwd`, or `FilteredStepFrame`. Report 04 Finding 4 refutes `fwd` against the
  `Base`-fixed `ClosureMCS`; task 450 deliverables (a) and (c) are the precondition and 450 is
  `[NOT STARTED]`.
- **Task C is out of scope.** No `Fulfilling` over `FilteredWorld φ`, no `truth_along_fulfilling`
  in its §4.5 generality, no assembly of the semantic FMP. Phase 7 proves the *lasso instance* over
  an `IntPresentation`; generalising it is Task C's job.
- **No frame-class re-parameterisation of the restricted-MCS layer** — task 450's charter.
- **No promotion of the spike schema into the library** — task 450 deliverable (d).
- **No efficiency claim.** Enumerating annotations costs `(P.card · 2^k)` per position with
  `k = subformulaClosureCard φ`. That is fine for decidability and hopeless for computation; say so
  in the docstring and keep `#eval` smoke tests to closures of two or three formulas.
- No edits under `/home/benjamin/Philosophy/Papers/` — read-only ground truth.
- No claim, in any docstring, that this decides the logic. `cor:tm-decidability` states decidability
  is **open**; this layer decides only *presented* ℤ-frames.
- No `sorry`, in any form, including "removed next phase" scaffold. No vacuous definitions.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **The truth lemma (Phase 7) is the same theorem the Boneyard failed at** | H | M | It is not, and the difference is the whole point of handoff §4.5: the Boneyard attempts tried to *establish* fulfilment inside the truth-lemma induction, where it cannot be established because it is not local. Here `Fulfilling` is a **hypothesis carried by the structure**, and the induction only consumes it. The `untl` `→` direction is an inner induction on the witness distance `(s - t).toNat`; the `←` direction is `Fulfilling` applied directly. Phase 7 is a declared stop-and-escalate point. |
| **Task 441 ("Effective periodic extension over finite frames", `[RESEARCHING]` concurrently) specifies a prefix-plus-cycle-in-both-directions presentation — the same shape as `BiLasso`** | M | H (it is being researched right now) | Three-part mitigation. (a) `Basic.lean` is **frozen** by this plan — 441 can consume it unchanged. (b) The generic periodic-decoding helper Phase 5 needs goes in a **new** file, not into `Basic.lean`, so 441 refactoring `Basic.lean` cannot conflict. (c) Phase 5 MUST re-run `grep -rn "structure .*Lasso\|extend_periodic\|periodicExtension" FormalSystem/ --include=*.lean \| grep -v Boneyard` first; if 441 has landed a generic periodic-sequence type, **use it and record the decision** rather than defining a second one. The annotation layer itself is not in 441's scope — 441 extends *histories*, this annotates *types over a lasso* — so there is no overlap there. |
| **The `(state, type, pending)` pigeonhole (Phase 10) is the layer's second crux** | H | M | Now better grounded than at plan 04: the refutation supplies a concrete reason the triple is *necessary* (Overview, correction 2). Phase 10 is a declared stop-and-escalate point: if the degeneralisation resists, mark `[BLOCKED]`, write the resisting goal state to `evidence/`, and stop — do not weaken the statement, and do not start Phases 11–12, which consume it. |
| The box oracle (Phase 11) is circular with the truth lemma if built naively | M | M | Stratify by `modalDepth` (`Syntax/Formula.lean:397`), computing the oracle at depth `k` from annotations whose box entries are only consulted at depth `< k`. `BoxOracleSound` is defined in Phase 6 as the invariant carried through that induction, so Phase 7 proves the truth lemma *relative to* it before any concrete oracle exists. |
| `TruthAt`'s `box` clause quantifies over **all** total world histories, not over the lassos enumerated | H | M | Exactly what makes the oracle depend on the small-model theorem, hence ordering 10 → 11. Phase 11 must not assume "no enumerated annotated bi-lasso refutes χ" implies "no total history refutes χ" without citing Phase 10. `box_const` (`Truth.lean:740`) supplies both history- and time-independence, so only one Bool per box-subformula is at stake. |
| `Fulfilling` looks decidable but the far-left / far-right positions are an infinite family | M | M | Phase 8 is sized for exactly this. The label sequence is genuinely periodic, so the family collapses: beyond one full period past the window, discharge is determined by whether the guard survives a full period. This is the corrected scan bound and it is the recovered half of Phase 3. If it resists, that is a real blocker, not a detail — escalate rather than adding a `Decidable` instance by `Classical.dec`. |
| An annotation is silently vacuous (`LocalCoherent` provable of anything, `Fulfilling` never asked) | H | M | Phase 6 must exhibit a **concrete non-trivial witness** — a small presentation, a two- or three-formula closure, a hand-built annotated lasso where `LocalCoherent` and `Fulfilling` are shown by `decide` — and a **negative** witness where `Fulfilling` fails. Both are verification criteria, not optional extras. `.claude/rules/lean4.md` prohibits vacuous definitions; this is the concrete form that prohibition takes here. |
| Argument-order transposition applied backwards somewhere | H | M | Every phase states the order it uses; the roles are quoted from `Semantics/Truth.lean:165-168` (the clause itself), not from any handoff. The pre-existing `BXCanonical/Quasimodel/` code is *not* to be trusted as a model for the order — see Research Integration finding 4. |
| Repository-wide pre-existing red is mistaken for damage caused here | M | H | Known and inherited, confirmed identical to HEAD by dispatch 3: `check-module-invariants.sh` C6 (`SoundnessLemmas/CoValidity.lean:104`), C9 (`WeakCanonical/PriorExpressivenessDense.lean:185`), `check-paper-definitions.sh` case (c), and `lake build BimodalTest` `#guard_msgs` mismatches in `BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`. **Do not plan to re-baseline the three test modules** — they fail identically against HEAD and are not this task's. Capture the baseline in Phase 4 and compare, never blame. |
| Scope creep from Task A into B or C once the layer works | M | M | Non-Goals are enforced at every phase close. B's precondition is another task's deliverable; starting it here produces work that cannot land. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- (both landed) |
| 2 | 3 | 2 (closed with exclusions) |
| 3 | 4, 5 | 2 |
| 4 | 6 | 4, 5 |
| 5 | 7, 8 | 6 |
| 6 | 9 | 6, 8 |
| 7 | 10 | 7, 9 |
| 8 | 11 | 7, 10 |
| 9 | 12 | 7, 9, 10, 11 |

Phases within the same wave can execute in parallel. The first executable phases are **4 and 5**.

---

### Phase 1: Repair the spike evidence file to guard-first order [COMPLETED]

**Goal**: `evidence/spike-untl-unfolding-and-fwd-obstruction.lean` compiles clean against the
migrated tree, with its nine `#print axioms` audits reporting no `sorryAx`, and its header
docstring recording the transposition.

**Landed.** Do not rebuild. Committed and sorry-free.

**Tasks**:
- [x] Capture the repository baseline: `bash scripts/check-module-invariants.sh` and `lake build`,
      recorded so later phases can distinguish inherited red from new red.
- [x] Re-run `lake env lean` on the spike file and capture the complete error list.
- [x] Transpose every `Formula.untl` / `Formula.snce` application to guard-first. Confirmed
      anchors: `Axiom.left_mono_until_G g g' e` varies the **guard**;
      `Axiom.right_mono_until e e' g` varies the **event**;
      `Axiom.prior_UZ φ : φ.someFuture.imp (φ.neg.untl φ)`, i.e. guard `¬φ`, event `φ`.
- [x] Fix `nxt` (`:48`) to `Formula.untl Formula.bot ψ` — guard `⊥`, event `ψ`.
- [x] Replace the file's convention paragraph with the live guard-first statement plus a dated note
      that the event-first text it replaces is retired.
- [x] Re-run the `#print axioms` block; all nine report `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1.5 hours (spent)

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`

**Verification**:
- `lake env lean` on the file exits 0, no errors, no `sorry`. **Met.**
- Nine `#print axioms` lines, none containing `sorryAx`. **Met.**
- The file remains outside `lake build`; Phase 12 revisits the regression-guard wiring question.

---

### Phase 2: `BiLasso` datatype, `unroll`, and `unroll_isStepPath` [COMPLETED]

**Goal**: a finitely-presented bi-infinite step path over an `IntPresentation`, with its decoding
proved to land in the frame's step paths.

**Landed.** `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`, sorry-free, `coherent`
decidable and non-vacuous. **This file is frozen by this plan** — see Non-Goals and the task 441
risk row.

**Tasks**:
- [x] Duplication check re-run before writing; empty at the time.
- [x] Create `BiLasso/Basic.lean` and `BiLasso/README.md`.
- [x] Define `structure BiLasso (P : IntPresentation)` with `back`, `mid`, `fwd : List (Fin P.card)`,
      `back_ne`, `fwd_ne`, `coherent`. *(deviation: altered — segments are indexed left-to-right in
      time via an `Int.emod`-based `cyc`, making the segment chains, seams and wrap-arounds one
      contiguous window `[-|back|-1, |mid|+|fwd|)` quantified as `∀ i : Fin (|back|+1+|mid|+|fwd|)`
      rather than a `Finset.Ico` over ℤ. Same content, fewer clauses, same decidability.)*
- [x] Define `BiLasso.unroll (L) : ℤ → Fin P.card` via `unrollOf`.
- [x] Prove `BiLasso.unroll_isStepPath : IsStepPath P.toTaskFrame L.unroll`.
- [x] Provide `BiLasso.toHF`.

**Timing**: 2 hours (spent)

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` — landed
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — landed

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Basic` exits 0. **Met.**
- No `sorry`; `coherent` non-vacuous via the exhibited `flipBiLasso`. **Met.**

---

### Phase 3: Periodicity of `unroll`; scan bounds refuted [COMPLETED WITH EXCLUSIONS]

**Goal (as achieved)**: the two periodicity lemmas for `unroll`, plus a machine-checked
determination of what the scan-bound half of this phase can and cannot deliver.

The periodicity half **landed**, in `Basic.lean` rather than a separate `Unroll.lean`, because
`unroll_isStepPath` in Phase 2 already needed it:

- `BiLasso.unroll_sub_back_length` — `t < 0 → L.unroll (t - |back|) = L.unroll t`
- `BiLasso.unroll_add_fwd_length` — `|mid| ≤ t → L.unroll (t + |fwd|) = L.unroll t`

Both are in the stronger explicit-threshold form rather than the existential form this phase asked
for, and both are consumed downstream.

The scan-bound half is **excluded as refuted**, with evidence. See the Overview for the full
statement of what was refuted and why, and Phase 8 for where the correct half of it is recovered.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| "Any property of `L.unroll` that holds at some `s > t` holds at some `s` with `t < s ≤ t + \|mid\| + \|fwd\|`", in the reading Phases 4–5 of plan 04 consume (a bound on the *semantic* witness) | **False.** Formula truth along a bi-lasso is not a function of the state at that time, and is not periodic in `t`: `unroll (t+\|fwd\|) = unroll t` holds for `t ≥ \|mid\|`, but the shifted path is not the path because the leftward tail moves. The failure appears already at temporal-nesting depth 1. | `evidence/phase3-scan-bound-is-false.lean`, sorry-free, `lake env lean` exits 0: `plan_scan_bound_fails` (literal bound fails at the atomic formula) and `no_formula_independent_scan_bound` (for every `N`, a formula witnessed after `t = -1` but at no time in `(-1, N]`, on one fixed bi-lasso) |
| The leftward mirror of the same bound | Same refutation, by the `untl`-mirror of the `prevⁿ` family | Same file; the mirror is immediate from `no_formula_independent_scan_bound` by time reversal and was not separately mechanised, since one refutation suffices to kill the design |
| `FormalSystem/Metalogic/Decidability/BiLasso/Unroll.lean` | Not created. Its only intended contents were the two landed lemmas (which went to `Basic.lean`) and the two refuted ones | `Basic.lean:185,194`; the file does not exist |

**Recovered, not abandoned**: the same sentence with "property of `L.unroll`" replaced by
"property of the annotation at a position" is **true**, because the annotation is periodic by
construction. Phase 8 states and proves it and uses it for `Fulfilling`'s decidability.

**Tasks**:
- [x] Prove rightward periodicity. *(deviation: altered — landed in `Basic.lean` as
      `unroll_add_fwd_length`, explicit threshold `|mid| ≤ t`.)*
- [x] Prove leftward periodicity. *(deviation: altered — landed in `Basic.lean` as
      `unroll_sub_back_length`, explicit threshold `t < 0`.)*
- [x] Determine the scan bounds — **refuted**; see Reasoned Exclusions.
- [x] Do not attempt well-founded recursion on ℤ. *(Honoured; and route 2 makes the question moot,
      since nothing recurses on time any more.)*

**Timing**: 2 hours (spent)

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` — the two periodicity lemmas (landed)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean` — the
  refutation (landed)

**Verification**:
- The two periodicity lemmas are sorry-free and consumed by `unroll_isStepPath`. **Met.**
- `lake env lean` on the refutation file exits 0; `#print axioms` on both refutation theorems shows
  no `sorryAx`. **Met.**

---

### Phase 4: The exact ℤ one-step unfolding of `TruthAt` [COMPLETED]

**Goal**: the semantic unfolding equations handoff §4.1 asserts, proved, in the live guard-first
order — the prerequisite Phases 7 and 10 both consume.

**Argument order used in this phase**: guard first. `Formula.untl g e` has guard `g`, event `e`.

**Tasks**:
- [x] Re-capture the repository baseline before touching anything: `bash scripts/check-module-invariants.sh`
      and `lake build`, plus `lake build BimodalTest`. Record the three known-red test modules
      (`BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`) so their failure is never
      attributed to this work and is never "fixed" here. *(Baseline captured: `lake build` exits 0;
      invariants FAIL at C6 (7 unreachable live modules) and C9 (1 task-number citation at
      `WeakCanonical/PriorExpressivenessDense.lean:185`); `lake build BimodalTest` red at exactly
      `BoxSpreadProbe:165`, `RegionGateProbe:299,330`, `TableauConformance:873,885,910,916`, all
      `#guard_msgs` mismatches. All inherited, none repaired here.)*
- [x] Check first whether the general unfolding already exists:
      `grep -rn "untl_unfold\|snce_unfold\|untl_succ\|unfold_untl" FormalSystem/ --include=*.lean | grep -v Boneyard`.
      The tree is expected to contain only the `⊥`-guarded case, and that only inside the evidence
      file (`truth_prev`, `phase3-scan-bound-is-false.lean:110`). If a general form exists, consume
      it and reduce this phase to the missing half. *(Grep returned empty — scope hypothesis
      confirmed, no general form exists; the phase was written in full.)*
- [x] Create `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean`.
- [x] Prove, for any `TaskModel` over `ℤ`, any history and any `t`:
      `TruthAt M τ t (Formula.untl g e) ↔ TruthAt M τ (t+1) e ∨ (TruthAt M τ (t+1) g ∧ TruthAt M τ (t+1) (Formula.untl g e))`.
      Forward: take the witness `s > t`; if `s = t+1` the left disjunct holds, otherwise `s > t+1`,
      the guard gives `g` at `t+1`, and the same `s` witnesses `untl g e` at `t+1`. Backward: the
      left disjunct gives witness `t+1` with a vacuous guard obligation; the right gives a witness
      `s > t+1` whose guard interval `(t, s)` is `{t+1} ∪ (t+1, s)`.
- [x] Prove the `snce` mirror. Derive it from `temporal_duality` if that is available and applies;
      otherwise prove it directly — do not leave it as "by symmetry" prose. *(Proved directly as
      `truth_snce_pred`; `temporal_duality` is a derivability statement, not a `TruthAt` one, so it
      does not apply. Recorded in the lemma docstring.)*
- [x] Prove the ℤ-distance induction principle the truth lemma needs: for `P : ℤ → Prop`, if `P t`
      and `∀ u ≥ t, P u → P (u+1)`, then `∀ s ≥ t, P s` (and the leftward mirror). If Mathlib
      supplies this directly for `ℤ` (`Int.le_induction` and its downward counterpart), use it and
      note the name rather than re-proving. *(Mathlib supplies them; the current names are
      `Int.leInduction` / `Int.leInductionDown` — `Int.le_induction` / `Int.le_induction_down` are
      deprecated aliases. Landed as one-line `Prop`-level wrappers `Int.rightInduction` /
      `Int.leftInduction` in the plan's exact shape, with the Mathlib names noted.)*
- [x] Docstring: state that the exactness of this unfolding is what scopes the task to ℤ-time and
      is what fails over a dense duration type, and that `subformulaClosure` is therefore adequate
      with no Fischer–Ladner enlargement.

**Timing**: 1.5 hours

**Depends on**: 2 (only for the module's home directory; mathematically independent)

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the general unfolding does **not** already exist in the
tree and that the `⊥`-guarded case in the evidence file is the only instance. Confirm with the grep
above before writing. If a general form exists elsewhere, consume it and re-scope this phase rather
than landing a duplicate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Unfold` exits 0, sorry-free.
- `#print axioms` on both unfolding lemmas reports no `sorryAx`.
- The statements are biconditionals quantified over all `g`, `e`, `t`, `τ`, `M` — no closure
  restriction, no frame-class side condition, no lasso in sight. (These are facts about ℤ-time
  semantics, reusable by Task C; a lasso-specific statement here would be a scope error.)

---

### Phase 5: Generic periodic decoding and the annotated bi-lasso datatype [NOT STARTED]

**Goal**: `Annot P φ` — a landed `BiLasso P` carrying a per-position type label, presented as three
lists matching the three segment lengths, with the label's periodicity lemmas.

**Tasks**:
- [ ] **Duplication check first**, before writing anything:
      `grep -rn "structure .*Lasso\|extend_periodic\|periodicExtension" FormalSystem/ --include=*.lean | grep -v Boneyard`.
      Task 441 is `[RESEARCHING]` concurrently and specifies a prefix-plus-cycle-in-both-directions
      presentation. If it has landed a generic periodic-sequence type, **use it and record the
      decision in the module docstring**; do not define a second one.
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` with the `cyc`/`unrollOf`
      arithmetic generalised to an arbitrary `[Inhabited α]`, plus the two periodicity lemmas at
      that generality. **Do not modify `Basic.lean`** and do not refactor it onto this file: it is
      frozen for 441. Record the deliberate, small duplication of the `emod` arithmetic and the
      reason in the docstring, together with the trigger that would retire it (441 landing a shared
      periodic presentation).
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean`.
- [ ] Define `structure Annot (P : IntPresentation) (φ : Formula)` with fields: the underlying
      `lasso : BiLasso P`; `backLab`, `midLab`, `fwdLab : List (Finset Formula)`; and three length
      agreements pinning them to `lasso.back.length`, `lasso.mid.length`, `lasso.fwd.length`.
      Keep the label lists as plain `List (Finset Formula)` — serializable, `DecidableEq`, and
      enumerable — rather than dependent packaging.
- [ ] Define `Annot.label : ℤ → Finset Formula` by the generic decoding, so that it uses **exactly**
      the same window/`emod` scheme as `unroll`. State and prove the alignment lemma
      `Annot.label_windowTime`-style, tying label positions to `unroll` positions, so the two are
      never off by one.
- [ ] Prove the two label periodicity lemmas, mirroring `unroll_sub_back_length` /
      `unroll_add_fwd_length` at the label: `t < 0 → label (t - |back|) = label t` and
      `|mid| ≤ t → label (t + |fwd|) = label t`.
- [ ] Prove `Annot.label_subset_closure`-style: every label is a subset of `subformulaClosure φ`
      (either as a structure field or as a derived condition; prefer a field, since the enumeration
      in Phase 9 will filter on it anyway).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts that no generic periodic-sequence datatype exists in the
live tree today and that the small `emod`-arithmetic duplication against `Basic.lean` is the
cheapest collision-safe option while 441 is in flight. Confirm the first by the grep above at
implementation time. If 441 has landed, the correct action is reuse, and this phase shrinks to the
`Annot` datatype alone — record that outcome rather than absorbing it silently.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` — new
- `FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Annotation` exits 0, sorry-free.
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` is **byte-identical** to its committed
  state — `git diff --exit-code FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` exits 0.
- The label alignment lemma is stated and proved, not assumed by `rfl` at a single position.

---

### Phase 6: `LocalCoherent`, `Fulfilling`, `BoxOracleSound`, and the non-vacuity witnesses [NOT STARTED]

**Goal**: the three predicates the truth lemma consumes, each exhibited non-vacuously.

**Argument order used in this phase**: guard first, `Formula.untl g e` / `Formula.snce g e`.

**Tasks**:
- [ ] Read `FormalSystem/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` and
      `Construction.lean` before defining anything, and record in the module docstring why the
      existing `HintikkaPoint` / `HintikkaStep` are not reused: they carry no atom, `imp`, or box
      clause; their step relation is `allFuture`/`allPast` propagation for the Burgess–Xu
      completeness proof rather than the exact ℤ one-step unfolding; and they sit on the
      MCS/`noncomputable` side. Do **not** modify them, and do **not** "fix" their argument roles
      even if they read as stale — report that separately if so.
- [ ] Define `LocalCoherent (P) (φ) (bx : Formula → Bool) (A : Annot P φ) : Prop` as the
      conjunction, over every `ψ ∈ subformulaClosure φ` and every `t : ℤ`, of the clauses:
      - `Formula.atom p ∈ A.label t ↔ P.val p (A.lasso.unroll t) = true`
      - `Formula.bot ∉ A.label t`
      - `Formula.imp a b ∈ A.label t ↔ (a ∈ A.label t → b ∈ A.label t)`
      - `Formula.box χ ∈ A.label t ↔ bx χ = true` — position-independent, justified by
        `box_const` (`Semantics/Truth.lean:740`), which gives independence of **both** the history
        and the time
      - `Formula.untl g e ∈ A.label t ↔ (e ∈ A.label (t+1) ∨ (g ∈ A.label (t+1) ∧ Formula.untl g e ∈ A.label (t+1)))`
      - `Formula.snce g e ∈ A.label t ↔ (e ∈ A.label (t-1) ∨ (g ∈ A.label (t-1) ∧ Formula.snce g e ∈ A.label (t-1)))`
      These are **biconditionals**. They are what make the label negation-complete over the closure
      without any MCS machinery, and the `→` direction of the truth lemma depends on that.
- [ ] Define `Fulfilling (P) (φ) (A : Annot P φ) : Prop` — for every `t` and every
      `Formula.untl g e ∈ A.label t`, there is `s > t` with `e ∈ A.label s` and
      `g ∈ A.label r` for all `t < r < s`; and the `snce` mirror leftward.
- [ ] Define `BoxOracleSound P bx : Prop` — `∀ χ, bx χ = true ↔ ∀ σ : WorldHistory P.toTaskFrame,
      σ.IsTotal → TruthAt P.toModel σ 0 χ`. Fix the time at `0` and cite `box_const` for why no
      time index is needed. State it in exactly the shape Phase 7 consumes and Phase 11
      establishes.
- [ ] **Non-vacuity, positive**: exhibit a concrete `A : Annot P φ` over a small presentation
      (`flipPresentation` or the refutation file's `chainPresentation`) and a two- or
      three-formula closure, with `LocalCoherent` and `Fulfilling` discharged — by `decide` where
      the phase-8 instances allow, otherwise by hand.
- [ ] **Non-vacuity, negative**: exhibit an annotated lasso that is `LocalCoherent` but **not**
      `Fulfilling` — an `untl` postponed forever around the forward loop. This is the greatest-vs-
      least-fixpoint gap of handoff §4.1 made concrete, and it is the proof that `Fulfilling`
      carries real content. Docstring it as such.

**Timing**: 1.5 hours

**Depends on**: 4, 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean` — the three predicates
- `FormalSystem/Metalogic/Decidability/BiLasso/Examples.lean` — new, the two witnesses (keep them
  out of `Annotation.lean` so the definitional module stays small)

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Examples` exits 0, sorry-free.
- Both witnesses exist and are named in the module docstring. Neither `LocalCoherent` nor
  `Fulfilling` nor `BoxOracleSound` may be `True`, `Unit`, or any unconditional predicate — the
  negative witness is what proves `Fulfilling` is not.
- No import of `FormalSystem.Metalogic.BXCanonical.*` anywhere under `BiLasso/`.

---

### Phase 7: `truth_along_annot` — the truth lemma [NOT STARTED]

**Goal**: along a locally coherent, fulfilling annotated bi-lasso, and relative to a sound box
oracle, truth equals label membership.

```lean
theorem truth_along_annot
    (hbx : BoxOracleSound P bx) (A : Annot P φ)
    (hloc : LocalCoherent P φ bx A) (hful : Fulfilling P φ A)
    (t : ℤ) (ψ : Formula) (hψ : ψ ∈ subformulaClosure φ) :
    TruthAt P.toModel A.lasso.toHF.val t ψ ↔ ψ ∈ A.label t
```

**This phase is a declared stop-and-escalate point.** If it resists, mark `[BLOCKED]`, write the
precise resisting goal state to `evidence/`, and stop. Do not weaken the statement to a
temporal-nesting-free fragment, and do not start Phases 10–12, which consume it.

**Argument order used in this phase**: guard first.

**Tasks**:
- [ ] Induct on `ψ`, threading closure membership of subformulas through `closure_imp_left`,
      `closure_imp_right`, `closure_box`, `closure_untl_left`, `closure_untl_right`,
      `closure_snce_left`, `closure_snce_right`
      (`Syntax/SubformulaClosure/Closure.lean:241-331`).
- [ ] `atom`: from `P.toModel_valuation` (`IntPresentation.lean:141`) and `LocalCoherent`'s atom
      clause; note the `τ.domain` obligation is discharged because `toHF` is total.
- [ ] `bot`: from `Truth.bot_false` and the `bot_free` clause.
- [ ] `imp`: from `Truth.imp_iff` and the `imp` clause. This is where the biconditional form of the
      clauses pays: no negation-completeness lemma is needed.
- [ ] `box`: from `hbx` plus `box_const` (`Truth.lean:740`) to move from time `t` to time `0`.
      This is the entire reason the oracle is a hypothesis here rather than a construction.
- [ ] `untl g e`, direction `←`: `Fulfilling` gives `s`, `e ∈ label s`, and the guard on `(t,s)`;
      the induction hypotheses on `e` and `g` convert membership to truth. Immediate.
- [ ] `untl g e`, direction `→`: the substantive case. From a semantic witness `s > t`, show
      `untl g e ∈ label t` by induction on the distance `(s - t).toNat` using Phase 4's ℤ-distance
      principle: at distance 1 the unfolding clause's left disjunct applies; at distance `n+1` the
      guard gives `g` at `t+1` (hence `g ∈ label (t+1)` by IH on `g`), the same `s` witnesses at
      `t+1` at distance `n`, and the unfolding clause's right disjunct applies. **Note the two
      nested inductions** — outer on the formula, inner on the witness distance — and keep them
      textually separate; conflating them is the standard way this proof goes wrong.
- [ ] `snce g e`: the leftward mirror of both directions, using Phase 4's `snce` unfolding and the
      downward ℤ-distance principle.
- [ ] Docstring: state explicitly that this is the **lasso instance** of handoff §4.5's
      `truth_along_fulfilling`, that `Fulfilling` is a hypothesis carried by the structure and is
      never established inside the induction, and that the latter is precisely what the Boneyard
      attempts (`RoundRobinChain`, `OracleStep`, `OracleCoherence`, `ScheduleBasedBFMCS`) tried and
      could not do, because fulfilment is not a local property.

**Timing**: 2.5 hours

**Depends on**: 4, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/TruthLemma.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.TruthLemma` exits 0, sorry-free.
- `#print axioms truth_along_annot` reports no `sorryAx`.
- The statement quantifies over every `ψ ∈ subformulaClosure φ` — no restriction to
  temporal-nesting-free formulas, no modal-depth bound, no frame-class side condition. A statement
  carrying any of those is a weakened statement and must be escalated, not landed.

---

### Phase 8: Decidability of `LocalCoherent` and `Fulfilling` — the corrected scan bound [NOT STARTED]

**Goal**: `DecidablePred` instances for both predicates, via the *corrected* form of the bound
Phase 3 could not deliver.

This is the recovered half of Phase 3. The statement Phase 3 asked for is true once "property of
`L.unroll`" is replaced by "property of the annotation at a position", because the annotation is
periodic **by construction**. Say so in the docstring, and cite
`evidence/phase3-scan-bound-is-false.lean` for what the corrected statement is *not*.

**Tasks**:
- [ ] State and prove the corrected forward scan bound: for a decidable predicate `Q` on
      `Finset Formula`, if `Q (A.label s)` holds for some `s > t`, then it holds for some `s` in an
      explicit finite range determined by `t`, `|back|`, `|mid|`, `|fwd|`. Derive it by pulling a
      witness back one period at a time using Phase 5's label periodicity. State the bound
      **explicitly**, not existentially — an unbounded existential does not discharge decidability.
- [ ] State and prove the leftward mirror.
- [ ] Reduce `LocalCoherent`'s `∀ t : ℤ` to a finite check. The clauses relate `label t` to
      `label (t±1)` and `unroll t`, and both sequences are periodic, so the whole family collapses
      to one window — reuse `BiLasso.step_of_mem_window`'s shape (`Basic.lean:204`) as the model,
      since `coherent` solved the identical problem for adjacency.
- [ ] Reduce `Fulfilling`'s `∀ t : ℤ` to a finite check. This is the harder half and the place to
      slow down. The obligation at a far-left position `t ≪ 0` is not literally the obligation at
      `t + |back|`, because the *distance to the window* differs; what makes it finite is that
      discharge from a far-left position is determined by whether the guard survives one whole
      backward period — if it does, the eventuality is discharged within `|back|`; if it does not,
      no far-left position discharges it at all. Prove that dichotomy, then check a window of
      roughly `2|back| + |mid| + 2|fwd|`. Derive the window size, do not guess it.
- [ ] Supply the `DecidablePred` instances, mirroring `IntPresentation`'s existing `DecidablePred`
      on `stepRel` (`IntPresentation.lean:96`). **No `Classical.dec`, no `open Classical`** — these
      instances must compute, or `check` is not a decision procedure.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the fulfilment window is bounded by a quantity of the
order `2|back| + |mid| + 2|fwd|`. Derive that constant from the dichotomy proof rather than
asserting it, and make Phase 9's enumeration and Phase 12's `bound` consume the derived quantity.
If the derived window is larger, update the consumers and say so — do not leave them out of step.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Decide` exits 0, sorry-free.
- `#print axioms` on the two decidability instances shows no `Classical.choice` beyond what the
  imported semantics already forces, and no `sorryAx`.
- `#eval` on the Phase 6 positive witness returns `true` for both predicates, and on the Phase 6
  negative witness returns `true` for `LocalCoherent` and `false` for `Fulfilling`. This is the
  smoke test that the instances actually compute and actually discriminate.

---

### Phase 9: Bounded enumeration of annotated bi-lassos [NOT STARTED]

**Goal**: `boundedAnnots P φ n : List (Annot P φ)` containing every annotated bi-lasso whose three
segments are bounded by `n`, with completeness and soundness proved.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean`.
- [ ] Define `boundedBiLassos P n : List (BiLasso P)` first — enumerate segment lists over
      `Fin P.card` up to length `n`, filter on the decidable `coherent` field. This is plan 04's
      Phase 6, surviving unchanged, and it is the base of the annotated enumeration.
- [ ] Prove completeness and soundness for `boundedBiLassos`: every `L` with all three segments of
      length `≤ n` appears, and every element is a genuine `BiLasso P` (immediate, since the filter
      is on the structure's own field).
- [ ] Define `boundedAnnots P φ n` by pairing each enumerated lasso with every assignment of
      subsets of `subformulaClosure φ` to its positions, filtered on `LocalCoherent` and
      `Fulfilling` via Phase 8's instances.
- [ ] Prove completeness and soundness for `boundedAnnots`.
- [ ] Docstring the size honestly: `(P.card · 2^k)` per position with
      `k = subformulaClosureCard φ` (`Closure.lean:56`). State that this is a decidability
      construction and not a practical algorithm, and keep every `#eval` smoke test to a closure of
      two or three formulas.

**Timing**: 1.5 hours

**Depends on**: 6, 8

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Enumerate` exits 0, sorry-free.
- `#eval (boundedBiLassos P 2).length` terminates on a two-state presentation and the count is
  hand-checkable.
- `#eval (boundedAnnots P φ 2).length` terminates for a two-formula closure, and the Phase 6
  positive witness is found in the list.

---

### Phase 10: The small-model theorem [NOT STARTED]

**Goal**: `exists_annot_of_truth` — if a formula is true at `(τ, t)` for some total history of the
presentation, a bounded annotated bi-lasso witnessing it exists.

**This phase is a declared stop-and-escalate point.** If the degeneralisation resists, mark
`[BLOCKED]`, write the precise resisting goal state to `evidence/`, and stop. Do not weaken the
statement to a provable but useless form, and do not start Phases 11–12, which consume it.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean`.
- [ ] Define the *type* at a position: `typeAt τ u := (subformulaClosure φ).filter (TruthAt P.toModel τ u ·)`.
      Prove that the type sequence of a genuine history satisfies every `LocalCoherent` clause —
      the atom, `bot` and `imp` clauses from `TruthAt`'s definition, the box clause from `box_const`
      and `BoxOracleSound`, and the two temporal clauses from **Phase 4's unfolding lemmas**. This
      is where Phase 4 is consumed and why it is a separate phase.
- [ ] Prove that the type sequence of a genuine history is `Fulfilling`: immediate, because the
      model's own eventualities are genuinely witnessed. State this as its own lemma — it is
      handoff §4.5's "fulfilment is supplied from outside, and cheaply", and it is the only place
      the least-fixpoint reading enters.
- [ ] Define the pigeonhole datum as the **triple** `(state, type, pending)`: `τ.path u`, the type
      above, and *pending*, the set of eventuality obligations in the type not yet discharged.
      Prove the triple space finite:
      `Fin P.card × Finset (subformulaClosure φ) × Finset (subformulaClosure φ)`.
      **Docstring why the triple is necessary, with the concrete reason now available**: pigeonholing
      on `state` alone can close a loop as short as the refutation file's
      `|back| = 1, |mid| = 0, |fwd| = 1`, which admits no consistent annotation for a closure
      containing `prev⁵ p` at all, because the annotation would be forced to give it the same
      membership at every `t ≥ 0` while its truth set is `[5, ∞)`. Cite
      `evidence/phase3-scan-bound-is-false.lean` for the witness. Requiring the *type* to repeat is
      what forces the extracted lasso to be long enough; requiring *pending* to repeat is the Büchi
      degeneralisation that stops the loop dropping an obligation the original path discharged
      outside it.
- [ ] Extract the forward loop with `exists_bounded_iter` (`FMP/Periodicity.lean:183`) and splice
      with `exists_lt_iter_of_card_le` (`:140`); mirror leftward using
      `exists_repeat_of_isStepPath` (`:122`) on the presentation's converse.
- [ ] Assemble the extracted segments into an `Annot P φ`, discharging the lasso's `coherent` from
      the source path's adjacency and `LocalCoherent` / `Fulfilling` from the two lemmas above,
      transported across the splice.
- [ ] State the bound explicitly in terms of `P.card` and `subformulaClosureCard φ`
      (`Closure.lean:56`).
- [ ] Prove `exists_annot_of_truth`, concluding via `truth_along_annot`.

**Timing**: 2.5 hours

**Depends on**: 7, 9

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the asserted bound is `|triple space| = P.card · 2^k · 2^k` with
`k = subformulaClosureCard φ`, and the hypothesis is that it is both *achievable* by the extraction
and *sufficient* for Phase 12's enumeration. Confirm by deriving the bound from the finiteness
proof rather than asserting it, and by checking that the `bound` function Phase 12 passes to
`boundedAnnots` is exactly this quantity. If the derived bound differs, update Phase 12 and say so.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.SmallModel` exits 0, sorry-free.
- `#print axioms exists_annot_of_truth` reports no `sorryAx`.
- The docstring states the bound and names the degeneralisation step explicitly.

---

### Phase 11: The box oracle by modal-depth stratification [NOT STARTED]

**Goal**: a concrete `bx` with `BoxOracleSound P bx` proved, breaking the annotation ↔ oracle
circularity.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean`.
- [ ] Define `boxOracle P : Formula → Bool` by strong recursion on `modalDepth`
      (`Syntax/Formula.lean:397`): at depth `k`, decide `□χ` as "no bounded annotated bi-lasso
      carries `¬χ`", where the annotations consulted have box entries only at depth `< k`.
- [ ] Prove the stratification well-founded — every `□`-subformula consulted has strictly smaller
      modal depth than the formula being decided.
- [ ] Prove `BoxOracleSound P (boxOracle P)`, using Phase 10 to bridge "no *enumerated* annotated
      bi-lasso refutes `χ`" to "no *total history* refutes `χ`". `TruthAt`'s `box` clause
      (`Truth.lean:164`) quantifies over all total world histories of the frame, so this bridge is
      load-bearing and must **cite** Phase 10 rather than assume it.
- [ ] Cite `box_const` (`Truth.lean:740`) for history- *and* time-independence, so the oracle is a
      single `Formula → Bool` with no time parameter.

**Timing**: 2 hours

**Depends on**: 7, 10

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.BoxOracle` exits 0, sorry-free.
- `#print axioms boxOracle_sound` reports no `sorryAx`.
- The oracle elaborates without `partial` and without `decreasing_by sorry`.

---

### Phase 12: `check`, `check_correct`, `Decidable`, and regression wiring [NOT STARTED]

**Goal**: the shipped decision procedure, plus the module re-export, README updates, and the
evidence probes wired in as permanent regression guards.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean`.
- [ ] Define `check P w φ : Bool` as
      `decide (∃ A ∈ boundedAnnots P φ (bound P φ), A.lasso.unroll 0 = w ∧ φ ∈ A.label 0)`.
      The `∃` sits **outside** any recursion on `φ` — nothing here computes `Sat (φ → ψ)` from
      `Sat φ` and `Sat ψ` — which is precisely why `no_compositional_imp`
      (`evidence/phase12-check-not-compositional.lean`) does not touch it. Say so in the docstring.
- [ ] Prove `check_correct` from `truth_along_annot` and `exists_annot_of_truth`.
- [ ] Provide the `Decidable` instance for satisfiability-in-a-presentation.
- [ ] Add `FormalSystem/Metalogic/Decidability/BiLasso.lean` as the subdirectory re-export, matching
      the existing `FMP.lean` convention.
- [ ] Update `FormalSystem/Metalogic/Decidability/README.md`'s module table, and finalise
      `BiLasso/README.md`. The latter must record: that `eval` was designed, refuted and retired;
      the route-1/route-2 decision and why route 2 was taken; and that `Basic.lean` is held stable
      for task 441's benefit.
- [ ] Wire the evidence probes in as regression guards, per handoff §7. Wire **three** now:
      `phase7-filtered-frame-is-universal.lean`, `phase12-check-not-compositional.lean`, and
      `phase3-scan-bound-is-false.lean` — the last is newly a permanent guard, because it is what
      stops a future dispatch reintroducing `eval` with a lasso-computed scan range.
      `spike-untl-unfolding-and-fwd-obstruction.lean` stays **out** of the build until task 450
      lands, per report 04 recommendation 5; record the reason in `BiLasso/README.md`.
- [ ] Run `bash scripts/readme-lint.sh` and `bash scripts/check-task-references.sh` — no task-number
      citations in any `.lean` file or `README.md`
      (`.claude/rules/no-task-references-in-deliverables.md`). Refer to task 441 and task 450 by
      *what they are* ("the effective-periodic-extension work", "the frame-class uniformity work"),
      never by number, in any file outside `specs/**`.

**Timing**: 1.5 hours

**Depends on**: 7, 9, 10, 11

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **four** evidence probes exist, of which **three** are
wired in and one deferred. Confirm by `ls specs/417_semantic_fmp_finite_worldstate_over_z/evidence/`
at implementation time and by checking each probe's compile status individually — a probe already
red for an unrelated reason must be reported, not wired in red. The wiring mechanism (a `Tests/`
module, a `lake env lean` invocation in `check-module-invariants.sh`, or a lakefile entry) is not
fixed here; choose the one consistent with how the repository already runs non-library checks, and
record the choice.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` — new
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` — new re-export
- `FormalSystem/Metalogic/Decidability/README.md` — module table row
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — finalise
- the regression-wiring target chosen above (script or test module)

**Verification**:
- Full gate set: `lake build` exits 0; `bash scripts/check-module-invariants.sh` shows no regression
  against the Phase 4 baseline; live-sorry count exactly 1 (`countermodel_discrete`,
  `WeakCanonical/Transfer.lean`), via the invariant script, never naive grep.
- `#print axioms check_correct` reports no `sorryAx`.
- `bash scripts/check-task-references.sh` passes.
- All three wired probes are green.
- `lake build BimodalTest` fails at exactly the three known modules and no others.

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase close.
- [ ] Repository live-sorry count is exactly 1 at every phase close, verified with
      `bash scripts/check-module-invariants.sh` — **never** naive grep.
- [ ] `#print axioms` on `truth_along_annot`, `exists_annot_of_truth`, `boxOracle_sound`, and
      `check_correct`: no `sorryAx` in any.
- [ ] **No vacuous definitions.** `LocalCoherent`, `Fulfilling`, and `BoxOracleSound` each need a
      non-trivial witness, and `Fulfilling` additionally needs the Phase 6 *negative* witness
      showing a locally coherent annotation that is not fulfilling. Without that negative witness,
      `Fulfilling` could silently be implied by `LocalCoherent` and the whole least-fixpoint
      distinction would be lost.
- [ ] Decidability instances compute: `#eval` smoke tests on the Phase 6 witnesses for
      `LocalCoherent` and `Fulfilling` (Phase 8), on `boundedBiLassos` and `boundedAnnots`
      (Phase 9), and on `check` (Phase 12). No `open Classical` under `BiLasso/`.
- [ ] `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` is unchanged from its committed
      state at every phase close (`git diff --exit-code` on that path).
- [ ] No `FormalSystem.Metalogic.BXCanonical.*` import anywhere under `BiLasso/`.
- [ ] `bash scripts/readme-lint.sh` and `bash scripts/check-task-references.sh` pass.
- [ ] Inherited red is unchanged, not worsened, and **not repaired here**:
      `check-module-invariants.sh` C6 and C9, `check-paper-definitions.sh` case (c), and
      `lake build BimodalTest` `#guard_msgs` mismatches in `BoxSpreadProbe`, `RegionGateProbe`,
      `TableauConformance`. These fail identically against HEAD. Compare against the Phase 4
      baseline before attributing any failure to this work; do not re-baseline the three test
      modules.
- [ ] Argument order: every new `untl` / `snce` occurrence is guard-first, argument 1 the guard.

## Artifacts & Outputs

- `specs/417_semantic_fmp_finite_worldstate_over_z/plans/05_annotated-bi-lasso-decision-layer.md` (this file)
- `specs/417_semantic_fmp_finite_worldstate_over_z/summaries/05_annotated-bi-lasso-decision-layer-summary.md`
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` (landed, **frozen**)
- `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean` (Phase 4)
- `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` (Phase 5)
- `FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean` (Phases 5, 6)
- `FormalSystem/Metalogic/Decidability/BiLasso/Examples.lean` (Phase 6)
- `FormalSystem/Metalogic/Decidability/BiLasso/TruthLemma.lean` (Phase 7)
- `FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean` (Phase 8)
- `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean` (Phase 9)
- `FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean` (Phase 10)
- `FormalSystem/Metalogic/Decidability/BiLasso/BoxOracle.lean` (Phase 11)
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` (Phase 12)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (finalised Phase 12)
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` (re-export, Phase 12)
- `FormalSystem/Metalogic/Decidability/README.md` (module table row, Phase 12)
- `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean` (landed, promoted to permanent regression guard in Phase 12)

## Rollback/Contingency

Every remaining phase is additive: new modules under `Decidability/BiLasso/`, nothing live imports
them until Phase 12's re-export. Reverting any phase is `git revert` of that phase's commit;
nothing downstream breaks, because nothing downstream depends on this subtree until Phase 12.
`Basic.lean` is not touched at all, so the landed Phase 2 work cannot be damaged by a rollback of
anything later.

The one shared-surface exception is Phase 12, which edits `Decidability/README.md` plus a
regression-wiring target. Take `bash .claude/scripts/git-snapshot.sh 417` before Phase 12 if the
wiring choice turns out to touch `lakefile.lean`.

**Never discard uncommitted changes to reach a passing build.** Fix forward; if a phase cannot be
made green, mark it `[BLOCKED]`, write the resisting goal state to `evidence/`, and stop.

**If route 2 blocks, route 1 is the documented fallback — but it is a re-plan, not an improvisation.**
Should Phase 7 or Phase 10 prove genuinely resistant, the recovery is a new plan round built on
route 1 (formula-dependent eventual periodicity), whose mathematics is recorded in the Overview so
it does not have to be re-derived. Do not attempt to switch routes mid-dispatch: the two share only
`Basic.lean` and `Unfold.lean`, and Phases 5, 6, 8, 9 have no route-1 analogue.

## Deferred Scope and the Re-Plan Trigger

Tasks B and C of handoff §5 remain open and are **not** planned here:

- **Task B** (`filteredStep`, `filteredStep_fwd` / `_bwd`, `FilteredStepFrame`) is blocked on task
  450 deliverables (a) — parameterise `RestrictedConsistent` / `RestrictedMCS` /
  `closure_mcs_deductively_closed` by `{fc : FrameClass}` — and (c) — the Discrete-system
  consistency lemma. Re-plan B once 450 is `[COMPLETED]`, taking report 04 recommendation 3's
  four-part re-scope as the starting point, with the risk located in the successor construction,
  not in the axiom base.
- **Task C** (`Fulfilling` over `FilteredWorld φ`, `truth_along_fulfilling`, the semantic FMP
  assembly) depends on both A and B and carries the highest risk of the three. Phase 7 of this plan
  delivers the *lasso instance* of its truth lemma and Phase 4 delivers the unfolding lemmas it
  needs; both are written to be reusable at Task C's greater generality, per handoff §4.6. C should
  not be dispatched until A and B are both green.

**Coordination note on task 441** ("Effective periodic extension over finite frames", currently
`[RESEARCHING]`): it independently specifies a prefix-plus-cycle-in-both-directions presentation
and is expected to consume `BiLasso/Basic.lean`. This plan freezes that file precisely so 441 can.
If 441 lands a shared periodic-sequence abstraction before Phase 5 runs, Phase 5 reuses it. After
both land, a small follow-up refactor unifying `Basic.lean`'s `cyc` with the generic version is
worth doing — but it belongs to whichever task owns the shared abstraction, and it is explicitly
not in scope here.

When this plan completes, the correct next action is **not** `/implement 417` again but a re-plan
of B (once 450 lands) and then C.
