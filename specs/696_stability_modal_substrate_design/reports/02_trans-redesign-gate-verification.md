# Research Report: Task #696

**Task**: 696 - stability_modal_substrate_design
**Started**: 2026-09-29T00:19:55Z
**Completed**: 2026-09-29T00:40:01Z
**Effort**: ~45 minutes research (round 2, verification-focused); implementation estimate unchanged from round 1 (3-5 orchestrator cycles, phased)
**Dependencies**: None (task 694 to be folded in; task 695 independent)
**Sources/Inputs**: - Round-1 report `reports/01_stability-modal-substrate-design.md` (read in full and taken as the design baseline), codebase (`WitnessFamily/Sharing/{Skeleton,Basic,Thread,Frame,Histories,Predicates,Window,Decide,Fulfil,Specialize}.lean`, `PlusWitnessFamily/{Basic,Predicates,Fulfil,Agreement,Examples,Incompleteness}.lean`, both READMEs, `scripts/check-module-invariants.sh` C2 block, `docs/theorem-index.md` pinned rows), one new 892-line probe elaborated with `lake env lean` against the built library (archived under this task's `probes/`), literature briefing (Burgess 1982 `S`/`U` truth clauses, chunk read)
**Artifacts**: - `specs/696_stability_modal_substrate_design/reports/02_trans-redesign-gate-verification.md` (this report)
- `specs/696_stability_modal_substrate_design/probes/03_trans_redesign_gate_probe.lean` (elaborates clean, exit 0, all nine `#print axioms` lines show `[propext, Classical.choice, Quot.sound]`, no `sorryAx`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **This round converts round 1's Q3 from argument to construction.** Round 1 recommended the arrival-pruned `trans` datum plus a `Liftable` skeleton field and gave Families A and B as hand-checked label tables. Those tables are now Lean terms. `famA_tCertifies` and `famB_tCertifies` prove that Family A (`Pp → ⊡Pp`) and Family B (`Fp → (¬p → ⊡Fp)`) satisfy all six *redesigned* conditions at `t = 0` with `trans = eq`, and `famA_refutes_snce_share_congr` / `famB_refutes_untl_shift_congr` prove that the redesigned (C1') is satisfied by a family on which the corresponding congruence *fails*. This is exactly the second check the task demands ("the redesigned (C1') no longer entails an analogue of `snce_share_congr`"), and it is now machine-checked for both temporal sides.
- **The closure obligation is confirmed genuine, by construction.** `stabFamily_not_liftable` shows that the landed (C5) witness `stabFamily` (sharing at `u = 0` only) admits a frame `Step`-path — lasso 0 on the negatives, lasso 1 from the origin — that no hop-free thread traces. So under any free-succession design the histories characterization is not automatic; round 1's F4 was right and is no longer only prose. The complementary positive fact is also machine-checked: `total_eq_tthread_of_liftable` proves that `Liftable` *alone* yields the histories characterization for trans-threads, in six lines, reusing the landed `total_eq_thread` for the `Step`-path extraction; and `TThread.toThread` shows arrival pruning alone makes every trans-thread a `share`-thread (hence a history via the untouched `hist`). These two are the redesign's A4 and A5, and their proofs are the ones Phase 2 should land.
- **The `t-1` re-timing candidate (B) is now refuted at a named lemma, not by narrative.** `plusSnce_thread_step` (`PlusWitnessFamily/Fulfil.lean` 344-350) instantiates (C1')'s `snce` clause at `k := θ.idx (t-1)` using `plusThread_share_pred θ t : S.share t (θ.idx t) (θ.idx (t-1))`, which is `Thread.step (t-1)` read backwards. A `share (t-1)`-quantified clause would need `share (t-1) (θ.idx t) (θ.idx (t-1))`, which no thread step supplies. The current `snce` clause is therefore already the exact mirror of the `untl` clause relative to `Thread.step`; the asymmetry the task description attributes to "own time vs `t+1`" is not the mechanism. Both clauses quantify over the one-step reach of a position, and both collapse because that reach is a `share`-class (round 1's F3, confirmed).
- **Candidate C (share indexed by formula class) is more restrictive than round 1 scored it.** In an all-histories frame a position's label must be the truth set of *every* history through it, so an index at `u` is a history type (past type, future type) restricted to the closure. Successors of `(i, u)` refine the future type; predecessors merge past types. The succession graph between times `u` and `u+1` is therefore a general bipartite relation whose left and right fibres differ in size; a single-time equivalence forces `succ(i, u) = pred(j, u+1)` as index sets, which the product structure does not generally permit. C is not a proof-saving special case of T but a genuinely lossy one.
- **Re-proof surface sharpened.** Round 1's F6 omitted three thin Formula-side modules, `Sharing/Thread.lean` (179 lines), `Frame.lean` (267) and `Histories.lean` (109), which are one-line delegations to the skeleton. They add restatement sites (`Thread.step` at `Thread.lean` 94-95, `step_of_share_succ`, `step_congr_right`) but no proof surface. Total lines across the two directories: 9,839; the `share`-as-succession grep (`share (.* + 1)` / `share_refl (.* + 1)`) hits 36 lines in 9 files, listed in F6 below.
- **Recommendation unchanged: T-arrival with `Liftable` as a skeleton field**, `liftable_of_full` and `liftable_of_spliceClosed` as sufficient lemmas, exact closure deferred. This round adds concrete Lean shapes for the field, the two A4/A5 lemmas, and the two gate families, so the planner can write Phase 1-4 against verified definitions rather than sketches.

## Context & Scope

This is research round 2 (forced re-research). The task description is unchanged from round 1; round 1's report is complete on Q1, Q2 and Q4 and its recommendation stands. The gap this round closes is the task's explicit demand in Q3, "confirm by construction, not by argument": round 1 exhibited the two gate families as tables and checked them by hand, and its closure counterexample (F4) was likewise prose. Everything else in this report is either a verification of a round-1 claim against the code, or a sharpening of a round-1 score.

Read in full this round: round-1 report; `Skeleton.lean` `Thread`/`Step`/`total_eq_thread` (lines 255-372, 855-946); `PlusWitnessFamily/Predicates.lean`, `Basic.lean`, `Examples.lean`, `Incompleteness.lean` (all, in full); `PlusWitnessFamily/Fulfil.lean` 305-350 and 955-1000; `Agreement.lean` `snce` case (243-266) and `PlusCertifies` (325-337); `Sharing/README.md` `### Correction: (C1') is only half a repair`, `### (c) What a follow-up needs`, `## Hand-off to the consuming model checker`; `Window.lean` 270-290; `Decide.lean` (both) `shareClauseAt` / `data_congr_*`; `check-module-invariants.sh` 990-1070; `theorem-index.md` 150-162; declaration outlines of `Sharing/Thread.lean`, `Frame.lean`, `Histories.lean`, `Basic.lean`; the Burgess 1982 `S`/`U` truth clauses.

Constraints honoured: nothing in the tree was modified; the probe is a standalone file elaborated against the existing oleans; zero sorries, no new axioms; soundness statements (`plusTruth_iff_mem`, `plusRefutes_of_certifies`) untouched and their form respected by the redesign as stated here.

## Findings

### Codebase Patterns

**F1. The probe's generic layer is a faithful pre-image of the redesigned conditions.** Stated on top of the landed `PlusSharingWitnessFamily` with `trans : ℤ → Fin n → Fin n → Prop` an external parameter:

- `TLocalCoherent S trans` — (C1') with the `untl` clause over `trans t i j` and the `snce` clause over `trans (t-1) k i`; the three one-position clauses verbatim.
- `TThread S trans` — `idx : ℤ → Fin n`, `step : ∀ u, trans u (idx u) (idx (u+1))`.
- `TThreadFulfilling S trans` — (C2') with `θ : S.TThread trans`.
- `TCertifies S trans t` — `PlusAtomCoherent ∧ (TLocalCoherent ∧ TThreadFulfilling) ∧ PlusBoxFaithful ∧ PlusTarget t ∧ StabFaithful`, the exact conjunct shape of the landed `PlusCertifies` (`Agreement.lean` 325-327).
- `ArrivalPruned S trans` — `∀ u i j, trans u i j → S.share (u+1) i j`.
- `Liftable S trans` — `∀ σ : ℤ → Fin n, (∀ u, S.skeleton.Step u (σ u) (σ (u+1))) → ∃ θ : S.TThread trans, ∀ u, S.share u (σ u) (θ.idx u)`.

(C0), (C3), (C4), (C5), `share`, `Step` and the frame are the landed ones; the redesign leaves all of them byte-identical (arrival pruning keeps `Step := ∃ i', share u i i' ∧ share (u+1) i' j` as the frame relation, `Skeleton.lean` 343-344). So a theorem about `TCertifies` here is a theorem about the redesigned `PlusCertifies` there, modulo renaming `TThread` to `Thread`.

**F2. A4 and A5 under the redesign, machine-checked.**

- `total_eq_tthread_of_liftable (hlift : S.Liftable trans) (σ : WorldHistory S.frame.toTaskFrame) : ∃ θ : S.TThread trans, ∃ s, ∀ t, σ.state t = S.cls (θ.idx (s+t)) (s+t)`. Proof: `S.total_eq_thread σ` gives a `share`-thread `θ₀`; `θ₀.idx` is a `Step`-path by `SharingSkeleton.Thread.step'`; `hlift` lifts it; `cls_eq rfl (hθ (s+t))` finishes. Six lines. Under the redesign the first step becomes the first half of today's `total_eq_thread` proof (extraction of `a` and `hstep`, `Skeleton.lean` 905-930), and today's second half (gluing via `share_trans`) becomes `liftable_of_full`.
- `TThread.toThread (hap : S.ArrivalPruned trans) (θ : S.TThread trans) : S.Thread := ⟨θ.idx, fun u => hap u _ _ (θ.step u)⟩`. One line; `S.hist (θ.toThread hap) s` is then a world history with no change to `hist`.

**F3. Family A, in Lean** (`famA : PlusSharingWitnessFamily [] [TA p]`, `TA p = stabSnceTarget ⊤ p` by `rfl`):

| index | `t < 0` | `t = 0` | `t ≥ 1` |
|-------|---------|---------|---------|
| 0 (main) | `a0b = {p, Pp, ⊡Pp, ⊤, T}` | `a0m = {p, Pp, ⊤}` | `a0b` |
| 1 | `a1b = {⊤, T}` | `a1m = {p, ⊤, T}` | `a0b` |

`repBack = [id]`, `repMid = [const 0]`, `repFwd = [const 0]`; `share u i j ↔ i = j` for `u < 0`, `share u i j` for `u ≥ 0` (`famA_share_neg`, `famA_share_nonneg`); `trans = eq`. Proved: `famA_atomCoherent`, `famA_tLocalCoherent`, `famA_tThreadFulfilling`, `famA_boxFaithful`, `famA_target` (at 0), `famA_stabFaithful`, bundled as `famA_tCertifies : (famA p).TCertifies (transEq p) 0`; `famA_arrivalPruned`; `famA_liftable` (every `Step`-path is constant on `(-∞, -1]`, so the constant thread at `σ (-1)` lifts it); `famA_refutes_snce_share_congr : TLocalCoherent ∧ ¬ (∀ i j, share 0 i j → (Pp ∈ L i 0 ↔ Pp ∈ L j 0))`; and the sanity check `famA_not_plusLocalCoherentShare` (the *landed* (C1') rejects Family A, via `snce_share_congr`), so this certificate is new.

**F4. Family B, in Lean** (`famB : PlusSharingWitnessFamily [] [UB p]`, `UB p := Fp → (¬p → ⊡Fp)`, the `stabUntlTarget` of the round-1 probe):

| index | `t ≤ 0` | `t ≥ 1` |
|-------|---------|---------|
| 0 (main) | `b0n = {Fp, ¬p, ⊤}` | `b0f = {p, Fp, ⊡Fp, R, U, ⊤}` |
| 1 | `b1 = {¬p, U, ⊤}` | `b1` |

`repBack = [const 0]`, `repMid = [const 0]`, `repFwd = [id]`; `share u i j` for `u ≤ 0`, `↔ i = j` for `u > 0`; `trans = eq`. Proved: the six conditions, bundled as `famB_tCertifies : TCertifies (transEqB p) 0`; `famB_liftable`; `famB_refutes_untl_shift_congr : TLocalCoherent ∧ ¬ (∀ i j, share 0 i j → ((p ∈ L i 0 ∨ (⊤ ∈ L i 0 ∧ Fp ∈ L i 0)) ↔ (p ∈ L j 0 ∨ (⊤ ∈ L j 0 ∧ Fp ∈ L j 0))))`, refuting the round-1 probe's `untl_shift_share_congr` against the redesigned (C1').

**F5. `stabFamily` is not liftable at `trans = eq`** (`stabFamily_not_liftable`). `crossPath u := if u < 0 then 0 else 1` is a `Step`-path (`crossPath_step`: reflexive steps except at `u = -1`, where `⟨0, share_refl, stabFamily_share_zero⟩` witnesses the existential). Any lifting trans-thread is constant (`TThread.eq_const`), must equal `0` at `u = -1` and `1` at `u = 1` by `stabFamily_share_ne`, contradiction. So the frame of the landed (C5) witness has a history that hop-free threads miss: with `trans = eq`, `stabFamily`'s own six-condition certificate cannot be sound — the `box`/`stab` cases of the truth lemma would evaluate `crossPath`'s history through no thread. A certifying family for `Fp` vs `⊡Fp` at a single shared instant must either hop (`trans (-1) 0 1`, which then forces `L 1 0` to agree with `L 0 0` on the `snce` unfolding — the semantically forced relocation) or share on a half-line as Families A and B do.

**F6. Re-proof surface, corrected list.** Sites where `share` is read as succession (36 grep hits, 9 files), grouped by what changes:

- *Substrate definition*: `Skeleton.lean` `Thread.step` (305), `Thread.const` (325-327), `thread_is_history`/`hist` (879-891, via `conn_thread` -> `Thread.reachN` -> `step'`), `total_eq_thread` (905-940).
- *Thin delegations, restatement only*: `Sharing/Thread.lean` `Thread.step` (94-95), `step_of_share_succ` (115-116), `step_congr_right` (128-129); `PlusWitnessFamily/Basic.lean` `Thread.step` (restated at `S.share`), `Thread.const`; `Sharing/Basic.lean` none.
- *(C1') statements*: `Sharing/Predicates.lean` 154, 158; `PlusWitnessFamily/Predicates.lean` `untl`/`snce` clauses; `plusUntl_self_of_share`, `plusSnce_self_of_share`, `plusLocalCoherentLab_of_share` (instantiate at `share_refl (t+1)`/`share_refl t`; become `trans_refl`).
- *Window / fixpoint*: `Window.lean` `succF`/`predF` (277-282), `mem_succF`/`mem_predF`, `succF_nonempty`/`predF_nonempty` (300-315, via `share_refl`), `FwdWalk.share_succ` (501), `walkIdx_step` (533, 547), `BwdWalk.share_succ` (574), `walkIdx_step` (606, 621).
- *Decision data*: `Decide.lean` (both) `shareClauseAt`'s `rp i = rp j` (Plus 524) and `rt i = rt k` (Plus 526) tests, `data_congr_back/fwd` (Formula 236/245, Plus 272/281).
- *Propagation*: `Fulfil.lean` (both) `untl_thread_step`/`plusUntl_thread_step` (Plus 328-334), `thread_share_pred`/`plusThread_share_pred` (Plus 337-341), `snce_thread_step`/`plusSnce_thread_step` (Plus 344-350), and the default escape edge `share_refl (z.2 + 1)` in `window_of_threadFulfilling`.
- *Producers needing the new fields*: `Sharing/Specialize.lean` `toSharing` (92-105), `PlusWitnessFamily/Examples.lean` `stabFamily` (238-246), smoke families at `Sharing/Fulfil.lean` 1646, `PlusWitnessFamily/Fulfil.lean` 1062, `PlusWitnessFamily/Decide.lean` 802, plus the two `skeleton` projections (`Sharing/Basic.lean` 101, `PlusWitnessFamily/Basic.lean` 251).

**F7. Export contract, exact text.** `Sharing/README.md` `## Hand-off to the consuming model checker` states the contract as: the five deterministic fields (`back`, `mid`, `fwd`, `bx`, `lassos`) unchanged; a sharing certificate adds `repBack`/`repMid`/`repFwd` (index maps as lists of naturals of length `|lassos|`, idempotent); the accepting branch's codomain is the same `Refutes Γ Del`. The redesign adds `transBack`/`transMid`/`transFwd` as lists of `|lassos| × |lassos|` Boolean matrices with lengths equal to the corresponding `rep` lists, defaulting to the full relation when absent. Additive in exactly the sense the README already uses; the checker's `Refutes` consumer is unchanged. The `lift` field is a proof obligation on the Lean side discharged by `liftable_of_full` for any export without `trans` fields, so existing exports need no new data and no new proof.

**F8. (C2') limitation, exact record.** `PlusWitnessFamily/Fulfil.lean` 316-324 records that the far-left/far-right case of the window reduction needs (C1') propagation along a thread, "which is the reason the window equivalence below is stated relative to `PlusLocalCoherentShare` rather than as a standalone `Decidable (PlusThreadFulfilling S)` instance"; 961-963 restates it; `decidablePlusThreadFulfilling` (972-974) is a `def` taking `hlc`, and `decidablePlusCoherentShareAndFulfilling` (985-995) is the `instance` on the conjunction. The propagation lemmas consume exactly `θ.step` (forward) and `plusThread_share_pred` (backward, `θ.step (t-1)` symmetrised). Under T-arrival both become `trans`-facts and the (C1') clauses quantify over exactly those, so the argument transfers verbatim and `plusThread_share_pred` loses its `share_symm` (the `snce` clause reads `trans (t-1) k i` directly). Round 1's Q4 verdict stands: inherit, documented as re-examined.

### External Resources

- Burgess, *Axioms for Tense Logic I: "Since" and "Until"* (1982), §1: `V(U(α,β)) = {x : ∃y (x < y ∧ y ∈ V(α) ∧ ∀z (x < z < y → z ∈ V(β)))}` and the mirror for `S`. This is the point-based clause; the repo's `PlusTruth.lean` clause is the same shape read along a history. Note Burgess writes `U(event, guard)` while the repo writes `untl guard event` (`Formula.lean` 100-103) — irrelevant to the design but a transcription hazard for anyone comparing. Burgess's completeness construction uses *pairs* `(f, g)` with `g` on pairs of points recording what holds between them; the analogue here is that a position's label records truth for every history through it, which is why (C1') must constrain all `trans`-neighbours of a position to agree on the one-step unfoldings (F5, Recommendations Q1).
- Mathlib names from round 1 (`IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed`, `Finite.exists_infinite_fiber`) are unchanged in relevance; the gate needs neither (both families are lifted by a constant thread, no pigeonhole required).
- Literature briefing entries flagged for this task (Gabbay-Hodkinson-Reynolds 1993 on gaps, Hodkinson-Reynolds 2006, Caleiro-Viganò-Volpe 2013 mosaics) remain orientation only; none prescribes a certificate format for an all-histories branching frame, and the design question is formalization-native.

### Recommendations

**Q1 — adequacy criteria.** Round 1's A1-A10 stand. One sharpening, which this round's constructions make precise: A2/A3 ("predecessor / successor sets are free data") should be read together with the *forced* residue that any position-labelled certificate carries — all `trans`-predecessors of `(i, t)` must agree on the `snce` unfolding `e ∨ (g ∧ g S e)` at `t-1`, and all `trans`-successors of `(i, t)` on the `untl` unfolding at `t+1`. This is not a defect: a position's label is the truth set of every history through it, so a position is a history type, and the neighbours of a history type agree on exactly what the type determines. Record these as `snce_pred_congr` / `untl_succ_congr` (round 1's suggestion) so no future reader mistakes them for a relapse. The defect being repaired is that the *landed* substrate identifies the predecessor set with the whole `share`-class (`Thread.step (t-1) : share t (idx (t-1)) (idx t)`), so the forced agreement spreads to every class-mate.

**Q2 — candidates, rescored where this round changed something.**

| Candidate | Change from round 1 |
|-----------|---------------------|
| B. Re-time `snce` to `t-1`, substrate unchanged | Now refuted at a named lemma: `plusSnce_thread_step` has no hypothesis to feed the re-timed clause (F8; round 1 said this in prose). Unsound as a clause change; not a candidate. |
| B'. Two-time thread step `share u ∧ share (u+1)` | Unchanged (depth-2 collapse, needs closure). |
| C. `share` indexed by formula class | Downgraded: not merely "symmetric succession", but forces `succ(i,u) = pred(j,u+1)` as index sets, incompatible with the product structure of history types (Executive Summary bullet 4). Rejected. |
| D. Hop-free, splice-closed | Unchanged; `famA_liftable`/`famB_liftable` are instances of its closure argument (constant lift, no pigeonhole needed on two lassos). Survives as `liftable_of_spliceClosed`. |
| **T-arrival** | Confirmed by construction on both temporal sides. `Liftable` confirmed necessary (`stabFamily_not_liftable`) and sufficient for A4 (`total_eq_tthread_of_liftable`); `ArrivalPruned` sufficient for A5 (`TThread.toThread`). |
| Pair-indexed labels | Unchanged; breaking on export. |

**Q3 — non-vacuity by construction.** Done, both sides; see F3, F4. The two families are exactly round 1's tables (Family A's lasso-1 origin label is `{p, ⊤, T}` as round 1 stated). Both certificates are refused by the landed (C1') (`famA_not_plusLocalCoherentShare`; the `untl`-side twin is immediate from the round-1 probe's `untl_shift_share_congr`), so the flip of `not_plusCertifies_stabSnce` / `not_plusCertifies_stabUntl` after Phase 4 is guaranteed by these two terms, not expected.

**Q4 — (C2') limitation.** Inherit, documented as re-examined (F8).

**Concrete Lean shapes for the plan** (lifted from the probe; names to taste):

1. `SharingSkeleton` gains `transBack transMid transFwd : List (Fin n → Fin n → Bool)`, three `_len` equalities against the `rep` lists, `trans_refl : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i, r i i = true`, and `lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd`, where `LiftableRaw` is the probe's `Liftable` written against the decoded functions (so it can be a field: `∀ σ : ℤ → Fin n, (∀ u, StepRaw u (σ u) (σ (u+1))) → ∃ θ : ℤ → Fin n, (∀ u, transRaw u (θ u) (θ (u+1)) = true ∧ shareRaw (u+1) (θ u) (θ (u+1))) ∧ ∀ u, shareRaw u (σ u) (θ u)`). `trans u i j := transRaw u i j = true ∧ share (u+1) i j`.
2. `Thread.step : ∀ u, K.trans u (idx u) (idx (u+1))`; `Thread.const` via `trans_refl` and `share_refl`; `thread_share_succ (θ) (u) : share (u+1) (θ.idx u) (θ.idx (u+1)) := (θ.step u).2` — this one lemma is what every current `θ.step` consumer in `Window.lean`/`Fulfil.lean`/`Agreement.lean` rewrites to in Phase 2, before (C1') itself changes in Phase 3.
3. `total_eq_thread` := extraction half of today's proof + `K.lift`; the probe's `total_eq_tthread_of_liftable` is the template. `liftable_of_full` := today's gluing half. `liftable_of_spliceClosed` per round 1.
4. (C1') as the probe's `TLocalCoherent` with `S.trans` for the parameter; (C2') as `TThreadFulfilling` with `S.Thread`. `shareClauseAt` takes `trans t` and `trans (t-1)` rows as data; `data_congr_*` gain `trans` components at the same periods.
5. `Examples.lean` gains `famA`/`famB` (or one, with the other in `Incompleteness.lean`'s successor module) with `lift` by `liftable_of_spliceClosed` or, simpler and already proved, the constant-thread argument of `famA_liftable`. Their per-condition proofs in the probe are each under 40 lines and use only `famA_L`-style decoding lemmas, `split_ifs`, and `simp` with the label `Finset`s — no `decide` over closures, so no evaluation-cost risk.

**Phasing.** Round 1's Phases 0-5 stand. Two adjustments from this round:

- Phase 0 should also land the probe's `TThread.eq_const`-style constant-thread lemma only if `Examples.lean` is to use the constant-lift argument; otherwise skip.
- Phase 2's checklist is F6's grep (36 hits, 9 files), not round 1's narrower list; the three delegation modules `Sharing/Thread.lean`, `Frame.lean`, `Histories.lean` must be touched (restatement) though no proof in them changes.

Task 694: fold in, as round 1 said. Its description prescribes the `trans` datum without arrival pruning, without the closure field, without the `untl`-side result, and without either gate family; everything it asks for is a strict subset of this design.

## Decisions

- Round 1's recommendation (T-arrival, `Liftable` as a skeleton field, exact closure deferred) is **confirmed**, now with machine-checked evidence for the two claims it rested on by argument: the gate families certify under the redesign and refute the congruences (both sides), and the closure field is necessary.
- Candidate B is **closed** (refuted at `plusSnce_thread_step`); candidate C is **closed** (incompatible with history-type product structure); neither is to be re-opened by the planner.
- The probe's definitions are adopted as the reference shapes for Phases 1-4; the planner should copy signatures from `probes/03_trans_redesign_gate_probe.lean` rather than re-derive them.
- The probe stays under `specs/…/probes/`; it is not a tree module. Its contents are to be *re-created* inside the tree in Phase 4 (families) and Phases 1-2 (generic lemmas), because inside the tree the `trans` parameter becomes a structure field and `TThread` becomes `Thread`.

## Risks & Mitigations

- **Risk**: in the tree, the redesigned (C1') is stated at `S.trans` (a field-derived relation) rather than an external parameter, and `simp`/`decide` behaviour on the example families may differ from the probe's. **Mitigation**: the probe's proofs use only decoding lemmas (`famA_L`, `famA_rep`, `famA_share_*`) and `Finset` literal membership, none of which mentions `trans`; the `trans = eq` reduction is one `change k = i at hki; subst`. Expect a near-verbatim port.
- **Risk**: `Liftable` as a structure field makes every producer prove it, including the three smoke families in `Fulfil.lean`/`Decide.lean`. **Mitigation**: all three are diagonal or full-`rep`; `liftable_of_full` discharges them with `transRaw := full`, no new proof per producer.
- **Risk**: the constant-lift argument (`famA_liftable`) does not generalise to families with more than one shared half-line; a third family needing genuine splicing would need `liftable_of_spliceClosed`. **Mitigation**: not on the gate's critical path; round 1's pigeonhole lemma remains the general tool.
- **Risk**: C2 fails between the substrate switch and the baseline rewrite. **Mitigation**: unchanged from round 1 — rewrite the fourteen-row baseline and the four `theorem-index.md` rows in the same phase as the `Incompleteness.lean` replacement, and cite the failure as the intended signal. The new rows should be `famA_certifies`/`famB_certifies` (or their in-tree names), `not_snce_share_congr`, `not_untl_shift_share_congr`, and both `not_plusValidZTime_*`.

## Tactic Survey Results

- Not applicable in the protocol's per-goal sense; this round used whole-file elaboration of one probe rather than `lean_multi_attempt`. The table records what closed the gate goals, for the planner's cost estimate.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `mem_closA` / `mem_closB` (closure enumeration) | `rw [mem_plusClosureOf]; simp only [List.mem_*]; rw [plusSubformulaClosure, List.mem_toFinset]; simp only [PlusFormula.top, PlusFormula.subformulas, List.mem_cons, …]; tauto` | success | plain `simp [subformulas, top]` hit the 200000-heartbeat `whnf` limit; `simp only` with explicit `List.mem_*` lemmas is the working form |
| `famA_L` / `famB_L` (label decoding) | `unrollOf_three` (three-singleton `Periodic.unrollOf` lemma) + `Fin.ext` case split | success | needs `change Periodic.unrollOf [a] [b] [c] u = _` before `rw` when the lists sit behind a structure projection |
| `famA_rep` / `famB_rep` | `@unrollOf_three _ (repIdInhabited _) …` ascribed to `S.rep u = …` | success | mirror of `Examples.lean`'s `stabFamily_rep_*` |
| (C1') clauses on both families | `split_ifs <;> simp [labels, PlusFormula.top]` after `rcases lt_trichotomy t 0` and a `t = 1 ∨ 2 ≤ t` split for `t-1` | success | each clause under 25 lines |
| (C5) on both families | `iff_of_false` / `iff_of_true` after splitting `u` by sign | success | as `stabFamily_stabFaithful` |
| `famA_liftable` / `famB_liftable` | ℕ-induction on distance from the shared half-line, `omega` for the casts | success | no pigeonhole, no compactness |
| `stabFamily_not_liftable` | `TThread.eq_const` + `stabFamily_share_ne` at `u = -1, 1` | success | 8 lines |
| axiom check | `#print axioms` on nine headline theorems | `[propext, Classical.choice, Quot.sound]` each | no `sorryAx` |

## Context Extension Recommendations

- **Topic**: "Position = history type" reading of branching certificates. **Gap**: neither README states that a position's label is the truth set of every history through it, which is what makes the residual neighbour-agreement constraints (F5, Q1) semantically forced rather than a relapse. **Recommendation**: a paragraph in `WitnessFamily/Sharing/README.md` under the (C1') correction, replacing the "own time" rule of thumb round 1 already flagged as wrong.
- **Topic**: `simp` on `plusClosureOf`/`subformulas` enumerations. **Gap**: the heartbeat blow-up of `simp [PlusFormula.subformulas, PlusFormula.top]` on closure membership is not recorded anywhere. **Recommendation**: note the `simp only` + `List.mem_toFinset` form in `.claude/context/project/lean4/` alongside other project-specific tactic idioms.

## Appendix

- Probe elaboration: `cd /home/benjamin/Projects/BimodalLogic && lake env lean specs/696_stability_modal_substrate_design/probes/03_trans_redesign_gate_probe.lean` — exit 0; stdout is the nine `#print axioms` lines, each `[propext, Classical.choice, Quot.sound]`. 892 lines, `grep -c sorry` = 0.
- Headline declarations in the probe (namespace `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily`): `TLocalCoherent`, `TThread`, `TThreadFulfilling`, `TCertifies`, `ArrivalPruned`, `Liftable`, `TThread.toThread`, `total_eq_tthread_of_liftable`, `TThread.eq_const`; `famA`, `famA_L`, `famA_rep`, `famA_share_neg`, `famA_share_nonneg`, `famA_tCertifies`, `famA_arrivalPruned`, `famA_liftable`, `famA_refutes_snce_share_congr`, `famA_not_plusLocalCoherentShare`; `crossPath`, `crossPath_step`, `stabFamily_not_liftable`; `famB`, `famB_L`, `famB_rep`, `famB_share_pos`, `famB_share_nonpos`, `famB_tCertifies`, `famB_liftable`, `famB_refutes_untl_shift_congr`.
- Round-1 probes (`01_untl_shift_congr_probe.lean`, `02_untl_target_nonvalid_probe.lean`) were not re-run this round; the oleans they elaborated against are unchanged (`Incompleteness.olean` dated 2026-09-28 15:01, tree at `e25e0bddb`).
- Line counts this round: `Sharing/` 5,463 lines over 12 files (`Skeleton` 946, `Fulfil` 1673, `Window` 639, `Decide` 567, `Specialize` 455, `Agreement` 411, `Frame` 267, `Predicates` 235, `Basic` 208, `Thread` 179, `Stability` 174, `Histories` 109); `PlusWitnessFamily/` 4,376 lines over 8 files (`Fulfil` 1093, `Decide` 969, `Agreement` 423, `Examples` 413, `Basic` 350, `Predicates` 318, `Incompleteness` 250, `Closure` 160).
- Sibling tasks: 694 `sharing_substrate_trans_redesign` (`not_started`, depends on 685) — fold in; 695 `plus_carrier_normalization_int_transfer` (`not_started`) — independent, untouched.
