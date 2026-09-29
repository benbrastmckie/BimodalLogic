# Research Report: Task #696

**Task**: 696 - stability_modal_substrate_design
**Started**: 2026-09-28T23:20:24Z
**Completed**: 2026-09-29T00:05:00Z
**Effort**: ~4 hours research; implementation estimate 3-5 orchestrator cycles (see Recommendations)
**Dependencies**: None (task 694 is to be re-scoped from this report; task 695 is independent)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/*.lean`, `PlusWitnessFamily/*.lean`, `PlusLanguage/PlusTruth.lean`, `Semantics/TaskFrame.lean`, `scripts/check-module-invariants.sh`, `docs/theorem-index.md`), lean-lsp MCP (`lean_local_search`), two scratch probes elaborated with `lake env lean` against the built library (archived under this task's `probes/`), Mathlib (compactness and pigeonhole lemmas located by name)
**Artifacts**: - `specs/696_stability_modal_substrate_design/reports/01_stability-modal-substrate-design.md` (this report)
- `specs/696_stability_modal_substrate_design/probes/01_untl_shift_congr_probe.lean` (elaborates clean: `untl_shift_share_congr`, `not_plusCertifies_stabUntl`)
- `specs/696_stability_modal_substrate_design/probes/02_untl_target_nonvalid_probe.lean` (elaborates clean: `not_plusValidZTime_stabUntl`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **New machine-checked finding that changes the problem statement.** The landed (C1') is defective on the `untl` side too, not only the `snce` side. Reading the `untl` clause at `(i, t-1)` against two class-mates at `t` forces the one-step-shifted unfolding `e ∨ (g ∧ g U e)` to be constant across every `share`-class at every time (`untl_shift_share_congr`). Consequence, also machine-checked: no six-condition L⁺ family certifies `Fp → (p ∨ ⊡Fp)` (i.e. `(¬p ∧ Fp) → ⊡Fp`) at any time or size (`not_plusCertifies_stabUntl`), while that schema is a genuine ℤ-time non-validity (`not_plusValidZTime_stabUntl`). The task description's premise "the `untl` clause escapes the defect" and the two READMEs' "the `untl` half is a genuine repair" are false; the collapse is merely one step delayed. Both probes are archived under `probes/` and elaborate against the current oleans with exit 0.
- **Root cause, restated exactly.** Any (C1') clause quantifies over the set of positions a thread can reach in one step from the labelled position. In the current substrate that set is a whole `share`-class (arrival class at `t+1` for `untl`; own class at `t` for `snce`), so the clause's right-hand side is forced constant on the class. The defect is therefore not about *which time* the clause quantifies at, but about *succession being a class*. Any design in which one-step succession is definable from `share` alone collapses at some bounded depth (shown below for the two-time thread step, which collapses at depth 2).
- **Adequacy criteria (Q1)** are stated before scoring: the stability modal needs exactly a per-time equivalence on indices (`share`); `untl`/`snce` need a per-time succession relation whose predecessor and successor sets are *free data* per position; `□`/`⊡` soundness needs every frame history to be a thread (`total_eq_thread`), and every position to lie on a thread. The weakest datum meeting all of these is a fourth periodic relation `trans u : Fin n → Fin n → Bool`, **pruned by arrival renaming** (`trans u i j → share (u+1) i j`) so that the frame's task relation and the whole quotient-frame section of `Skeleton.lean` stay byte-identical.
- **Scored candidates (Q2).** Re-timing `snce` to `t-1` while keeping the substrate is unsound as a clause change (the thread's actual predecessor is not in that class) and, when accompanied by the matching two-time thread step, collapses at depth 2 and still needs a closure condition. Indexing `share` by formula class is a special case of `trans` (symmetric, arrival-renaming-shaped succession) with the same costs and no proof saving. A hop-free "splice-closed lassos" design is the cheapest of all and non-collapsing, but presents only models with finitely many histories, which loses currently certifiable recombination models; it survives as the cheap *sufficient* closure lemma inside the recommended design. Pair-indexed labels break the export contract. **Recommended: `trans` pruned by arrival renaming, with thread-lifting as a label-free skeleton field discharged by decidable sufficient conditions.**
- **The one genuinely new obligation is closure.** With free succession, "every frame history is a thread" is no longer automatic (a two-lasso counterexample is given). The correct condition is exactly "every state path of the frame lifts to a thread" (`Liftable`). Every pointwise local surrogate I tried (index-level splice conditions, rectangularity, one-sided lifting) is either a collapse or rejects the natural two-lasso certificates; the report records why. `Liftable` is made a **field of `SharingSkeleton`** (label-free well-formedness, like `rep_idem`), which keeps `total_eq_thread`, `plusTruth_iff_mem` and `plusRefutes_of_certifies` statements literally unchanged, as the hard constraint requires. Producers discharge it via three sufficient lemmas: full `trans` (port of today's proof), splice-closed lassos (finite pigeonhole, `Finite.exists_infinite_fiber`), and, as a later phase, the exact window form by subset construction plus compactness (`IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed` on `ℤ → Fin n`).
- **Non-vacuity by construction (Q3).** Two concrete two-lasso families are given with full label tables and a hand check of all conditions: one certifies `Pp → ⊡Pp` at time 0 (flipping `not_plusCertifies_stabSnce` for `g := ⊤, e := p`), the other certifies `Fp → (p ∨ ⊡Fp)` at time 0 (flipping the new `not_plusCertifies_stabUntl`). Each family is itself the refutation of the corresponding congruence against the redesigned (C1'), which is the second check the task demands. Both use `trans = eq` and are splice-closed, so the cheap closure lemma suffices for the gate.
- **(C2') limitation (Q4)**: re-examined, not inherited blindly. The (C1')-relative far-left argument uses only "consecutive thread indices are one-step related" and the (C1') clause at exactly that relation; under `trans` it transfers verbatim (and `thread_share_pred` simplifies). The redesign neither removes nor worsens it; the left-wrap-edge refinement stays a separate, optional follow-up.

## Context & Scope

Ground truth read in full: `WitnessFamily/Sharing/Skeleton.lean` (substrate, `Thread.step`, quotient frame, `total_eq_thread`), `Sharing/Window.lean` (combined window, position graph, walks), `Sharing/Predicates.lean` and `PlusWitnessFamily/Predicates.lean` ((C0), (C1'), (C2'), (C5)), `Sharing/Fulfil.lean` and `PlusWitnessFamily/Fulfil.lean` (fixpoint, propagation, window reduction), `Sharing/Agreement.lean` and `PlusWitnessFamily/Agreement.lean` (truth lemma, `Certifies`), `Sharing/Specialize.lean`, `Sharing/Stability.lean`, `PlusWitnessFamily/Examples.lean`, `PlusWitnessFamily/Incompleteness.lean`, both READMEs, `PlusLanguage/PlusTruth.lean` (the `stab` clause), the C2 axiom baseline block of `scripts/check-module-invariants.sh` (lines 994-1067), and the four pinned rows of `docs/theorem-index.md` (lines 156-159).

Constraints honoured: soundness untouched (`plusTruth_iff_mem`, `plusRefutes_of_certifies` keep their statements); zero sorries, no new axioms; the C2 rows for `Incompleteness.lean` flip deliberately; each implementation phase ends green; task 695 out of scope. The research answers Q1-Q4 in order.

## Findings

### Codebase Patterns

**F1. Truth clauses and what they quantify over** (`PlusLanguage/PlusTruth.lean` lines 84-93, `Semantics/Truth.lean` lines 233-241):

- `stab φ` at `(τ, t)`: `∀ σ, τ.state t = σ.state t → φ at (σ, t)` — all histories through the *state* at `t`.
- `untl g e` / `snce g e` at `(τ, t)`: existential over `τ`'s own later / earlier times, guard on the open interval — the history's own future / past.
- `box φ`: all histories.
- `WorldHistory F` is *every* total function respecting `TaskRel` (`Semantics/TaskFrame.lean`); nothing bundles or restricts it. So in any presented model the histories through a state at `t` are the full product of that state's pasts and futures.

**F2. What the substrate makes of a position.** `Thread.step u : share (u+1) (idx u) (idx (u+1))` (`Skeleton.lean`). Hence for position `(i, t)`:
- successors reachable by a thread = `class(i, t+1)`, the arrival class of `i`'s own lasso;
- predecessors = `{k : share t k i}` = `class(i, t)`, the whole class at the label's own time.

Two class-mates therefore have *identical* predecessor sets (past collapse, `snce_share_congr`), and every index in an arrival class at `t+1` is a successor of the *same* position `(i, t)` (shifted-future collapse, F3).

**F3. New machine-checked result: the `untl` side collapses too.** Probe `probes/01_untl_shift_congr_probe.lean` elaborates (exit 0) against the current build:

- `untl_shift_share_congr (hloc : S.PlusLocalCoherentShare) (hij : S.share t i j) : (e ∈ L i t ∨ (g ∈ L i t ∧ untl g e ∈ L i t)) ↔ (e ∈ L j t ∨ (g ∈ L j t ∧ untl g e ∈ L j t))` — proof: read `(hloc i (t-1)).2.2.2.1` at `j := i` and at `j := j`, both legitimate since `share ((t-1)+1) i _` holds; six lines.
- `stabUntlTarget p := Fp → (¬p → ⊡Fp)` and `not_plusCertifies_stabUntl (S : PlusSharingWitnessFamily [] [stabUntlTarget p]) (t) : ¬ S.PlusCertifies t` — uses (C0), (C1')'s `bot`/`imp`/`untl` clauses, (C4), (C5); no bound.
- Probe `probes/02_untl_target_nonvalid_probe.lean`: `not_plusValidZTime_stabUntl p` on `PlusNonValidities.NF` with histories `s ↦ if s ≤ 0 then 1 else 0` and `s ↦ 1` (state 0 is the `p`-state of `natModel`).

Consistency check: `Examples.lean`'s `stabFamily` labels `Fp` on lasso 0 at `t = -1` and nothing on lasso 1 at `t = 0`, while the two share at `0`; by F3 it violates (C1') — which is exactly why `stabFamily_separates` checks (C5) in isolation and no branching `Certifies` exists except the diagonal.

**F4. Why a general succession relation needs a closure condition, and which condition.** With `Thread.step := trans u (idx u) (idx (u+1))` and `trans` free, take two lassos sharing only at `u = 0` with `trans = eq`: the frame's task relation still has the step `[0]_{-1} → [shared]_0 → [1]_1`, so the state path "lasso 0 before 0, lasso 1 after 0" is a frame history but no thread traces it; `total_eq_thread` is false and the `box`/`stab` cases of the truth lemma cannot be proved. The current proof survives only because gluing two `Step` witnesses uses transitivity of `share` *at one time*; a two-time succession relation has nothing to glue with.

Surrogates examined and rejected (each with a two-lasso witness worked in the analysis):
- index-level splice `∀ i ~_u j, ∀ h ∈ preds i, h' ∈ succs j, ∃ k ~_u i, trans (u-1) h k ∧ trans u k h'` is *unsatisfiable* by any sound presentation of the `Fp → (p ∨ ⊡Fp)` countermodel (it demands a position that is `h1`-typed at `u-1` and `h2`-typed at `u+1`);
- pred/succ-set equality or inclusion variants over-demand a full product of history types and reject the natural two-lasso certificates;
- rectangularity of `trans` between consecutive states identifies the successor sets of class-mates, a future collapse;
- one-sided lifting from any index (forward or backward) is, respectively, "successor states are class-invariant" or "predecessor states are class-invariant", i.e. a collapse.

The exact condition is `Liftable`: every `Step`-path of the frame is the trace of a thread. It is equivalent, by compactness, to "every finite segment lifts", and that is decidable over the folded position graph by a subset construction (never reaching the empty index set from a full class). Two cheap sufficient conditions cover the immediate needs: (a) `trans = full` (today's substrate; today's `total_eq_thread` proof), (b) splice-closed lassos, `∀ u i j, share u i j → ∃ k, (∀ v < u, share v k i) ∧ (∀ v ≥ u, share v k j)`, from which every state path is a *lasso* trace by iterated splicing over `[-n, n]` and `Finite.exists_infinite_fiber` over the finitely many lassos (no compactness needed).

**F5. Arrival pruning keeps the frame section verbatim.** Defining `trans u i j := transRaw u i j = true ∧ share (u+1) i j` gives `thread_is_history` in one line (`trans → share (u+1) → Step`) and leaves `Step`, `ReachN`, `Conn`, `RelZ`, all four `def:frame` constraints, `instIsRegular`, `frame_isZTime` untouched. It is also WLOG: a history type whose continuations land in two different states can be split by next state, so nothing presentable is lost. Every current certificate is recovered by `transRaw := fun _ _ => true`.

**F6. Where the code reads `share` as succession** (the exact re-proof sites): `Skeleton.lean` `Thread.step`, `Thread.const`, `thread_is_history`, `total_eq_thread`; `Window.lean` `succF`/`predF` (lines 277-282), `FwdWalk.share_succ`/`BwdWalk.share_succ`, `walkIdx_step` (both), `succF_nonempty`/`predF_nonempty` (via `share_refl`); `Predicates.lean` (both sides) the `untl`/`snce` quantifiers of (C1'); `Decide.lean` (both sides) `shareClauseAt`'s `rp i = rp j` / `rt i = rt k` tests and the `data_congr` lemmas; `Fulfil.lean` (both sides) `thread_share_pred`, `untl_thread_step`, `snce_thread_step`, and the default escape edge `S.share_refl (z.2 + 1) z.1` in `window_of_threadFulfilling`; `Agreement.lean` (both sides) the along-thread lemmas' use of `θ.step` against the (C1') clause; `Specialize.lean` `toSharing` and `thread_toSharing_eq_zero`.

**F7. Baseline and index plumbing.** The C2 block pins fourteen `#print axioms` lines (`check-module-invariants.sh` lines 1012-1027) including `total_eq_thread`, `plusTruth_iff_mem`, `plusRefutes_of_certifies`, and the four `Incompleteness.lean` declarations; `docs/theorem-index.md` rows 156-159 mirror the latter with `pcq pinned:C2`. `FormalSystem.lean` line 153 imports `Incompleteness`. A successful repair makes `snce_share_congr`, `not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise` unprovable (they must be *deleted or negated*, not kept), so C2 fails until the baseline is rewritten; that failure is the intended signal.

**F8. Combined window.** `perBack = |repBack| * ∏|back_i|` (`Sharing/Decide.lean` line 151); `SharingWindow` carries `nbr_dvd_NB`, `nfr_dvd_NF`, `nmr_le_NM`. If the `trans` segments are constrained to the *same lengths* as the `rep` segments, every window and fold lemma extends to `trans` by the same proof (`trans_congr_back/fwd/NB/NF` twins of `rep_congr_*`) with no change to the window arithmetic.

### External Resources

- Mathlib `IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed` (`Mathlib/Topology/Compactness/Compact.lean`) — the compactness step for the exact closure lemma, on `ℤ → Fin n` with `Pi.compactSpace`; the constraint sets are finite intersections of preimages under `continuous_apply`, hence closed.
- Mathlib `Finite.exists_infinite_fiber` (`Mathlib/Data/Fintype/Pigeonhole.lean`) — the pigeonhole step for the splice-closed sufficient condition.
- Both names verified present via `lean_local_search`.
- Literature (briefing): the closure phenomenon is the "limits of splices in both directions" of `specs` task 559's P2 and the fusion/suffix/limit closure of Emerson–Halpern 1986; Reynolds 2001/2002 handle it with an automaton run over the *future* only (rooted), which is why a two-sided compactness argument, not a rooted recursion, is the right Lean shape here. No literature source prescribes a certificate format; this is formalization-native.

### Recommendations

**Q1 — adequacy criteria (fixed before scoring).**

| # | Criterion | Why |
|---|-----------|-----|
| A1 | A per-time equivalence on indices (`share`) | the `stab` clause quantifies over histories through the *state*; the quotient carrier, (C0) and (C5) read it |
| A2 | Predecessor sets of positions are free data (two class-mates may differ) | otherwise `snce` labels are class-constant (`snce_share_congr`); must hold at *every* depth, not a bounded window |
| A3 | Successor sets of positions are free data | otherwise the shifted `untl` unfolding is class-constant (`untl_shift_share_congr`) |
| A4 | Every frame history is a thread (`total_eq_thread`) | `box` and `stab` cases of the truth lemma evaluate arbitrary histories through threads |
| A5 | Every position lies on a thread (`Thread.const`) | the forward direction of the `stab` case and `succF_nonempty` |
| A6 | Every condition window-reducible; datum periodic with the existing decoding | decidability of `Certifies` |
| A7 | `plusTruth_iff_mem`, `plusRefutes_of_certifies`, `total_eq_thread` statements unchanged | hard constraint |
| A8 | No regression: every family certifiable today remains certifiable | the current class must embed |
| A9 | Export contract additive | model checker not re-opened |
| A10 | Re-proof surface | cost |

**Q2 — candidates and scores.**

| Candidate | A1 | A2 | A3 | A4 | A5 | A6 | A7 | A8 | A9 | A10 |
|-----------|----|----|----|----|----|----|----|----|----|-----|
| Current (arrival renaming) | yes | **no** (`snce_share_congr`) | **no** (`untl_shift_share_congr`, F3) | free | yes | yes | — | — | — | 0 |
| B. Re-time `snce` to `t-1`, substrate unchanged | yes | n/a | n/a | — | — | — | — | — | — | small | **unsound**: a thread through `(i,t)` came from `class(i,t)`, not `class(i,t-1)`; the along-thread `snce` induction no longer has a clause to apply |
| B'. Two-time thread step `share u ∧ share (u+1)` | yes | **no** at depth 2 (`share (t-1) i j ∧ share t i j → snce congruence`, same double reading) | **no** at depth 2 | needs closure (F4) | yes | yes | yes | no (fewer threads) | yes (no new data) | medium |
| C. `share` indexed by formula class (finer arrival equivalences) | yes | yes (congruence relocates to equal-pred-set positions, which is semantically forced) | yes | needs closure (F4) | yes | yes | yes | yes | additive, 3 lists | same as T; succession forced *symmetric* (`i` may precede `j` iff `j` may precede `i`), strictly less general than T with no proof saving |
| D. No hopping; lassos splice-closed | yes | yes | yes | **yes, cheap** (pigeonhole) | yes | yes | yes | **no**: only finite-history models (loses e.g. the one-step-lookahead branching models the current design presents) | yes (a proof field only) | smallest (the fixpoint layer becomes unnecessary) |
| T-free. `trans` arbitrary, `Step` redefined | yes | yes | yes | needs closure | yes (with `trans_refl`) | yes | yes | yes | additive, 3 lists | large: whole frame section re-proved |
| **T-arrival. `trans` pruned by `share (u+1)`** | yes | yes | yes | needs closure; `Liftable` as skeleton field, three sufficient lemmas | yes | yes | **yes, literally** | **yes** (`transRaw := full`) | additive, 3 lists, same lengths as `rep` | medium; frame section verbatim |
| Pair-indexed labels (product substrate) | yes | yes | yes | automatic | yes | yes | yes | yes | **breaking** (quadratic label rows) | very large |

**Recommendation: T-arrival**, with D absorbed as the cheap sufficient closure lemma and the current design absorbed as the `full`-trans lemma. Concretely:

1. `SharingSkeleton` gains `transBack transMid transFwd : List (Fin n → Fin n → Bool)`, `transBack_len : transBack.length = repBack.length` (and Mid/Fwd), `trans_refl : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i, r i i = true`, decoded by `Periodic.unrollOf` at the `Inhabited` default `fun i j => decide (i = j)` (mirror of `repIdInhabited`), and `lift : LiftableRaw n repBack … transFwd` (a `Prop` stated through a pre-structure raw predicate on the decoded functions, so it can be a field). `trans u i j := transRaw u i j = true ∧ share (u+1) i j`.
2. `Thread.step u : trans u (idx u) (idx (u+1))`; `Thread.const` by `trans_refl`; `Step`, `ReachN`, frame untouched; `total_eq_thread` proved from `lift` (the first half of today's proof — extracting the index path and its `Step`s — is reused verbatim).
3. Sufficient lemmas for `lift`: `liftable_of_full` (today's gluing proof), `liftable_of_spliceClosed` (pigeonhole; decidable premise by window reduction), and, as a separate later task, `liftable_of_liftWindow` (subset construction on the skeleton's own window `[-2·nbr, nmr + 2·nfr)` plus compactness). Producers pick one; the diagonal (`Specialize.lean`) is `liftable_of_spliceClosed` trivially.
4. (C1') quantifies `∀ j, trans t i j → …` and `∀ k, trans (t-1) k i → …`; `shareClauseAt` takes `trans t` and `trans (t-1)` as data; the `data_congr` lemmas gain `trans` components (same periods, same proofs). (C2'), (C0), (C3), (C4), (C5) statements unchanged.
5. `succF v := verts.filter (w.2 = nextTime v.2 ∧ trans v.2 v.1 w.1)`, `predF v := verts.filter (w.2 = prevTime v.2 ∧ trans (prevTime v.2) v.1 w.1)`; walks carry `trans_succ`; the propagation lemmas read `θ.step` directly.
6. Export: three new list fields, each a list of `n × n` Boolean matrices whose lengths equal the corresponding `rep` list; absent fields default to the full relation (exactly today's semantics). Additive. Arrival pruning means an exporter need not make its relations arrival-consistent.

**Q3 — non-vacuity by construction, and the congruence checks.**

Family A (`snceFamily`), certifies `stabSnceTarget ⊤ p` (`Pp → ⊡Pp`) at `t = 0`, `Γ = []`, `Del = [imp Pp ⊡Pp]`, closure `{imp Pp ⊡Pp, Pp, ⊡Pp, ⊤, ⊥, p}`. Semantics: lasso 0 = state 0 always (`p`); lasso 1 = state 1 for `t < 0`, state 0 for `t ≥ 0`.

| index | `t < 0` (`back`) | `t = 0` (`mid`) | `t ≥ 1` (`fwd`) |
|-------|------------------|-----------------|-----------------|
| 0 (main) | `{p, Pp, ⊡Pp, ⊤, T}` | `{p, Pp, ⊤}` | `{p, Pp, ⊡Pp, ⊤, T}` |
| 1 | `{⊤, T}` | `{p, ⊤, T}` | `{p, Pp, ⊡Pp, ⊤, T}` |

`T := imp Pp ⊡Pp`; `repBack = [id]`, `repMid = [const 0]`, `repFwd = [const 0]`; all `trans` segments `[eq]`; `bx := fun _ => false`. Checks: (C0) atoms agree wherever shared (`t ≥ 0`: `p` in both). (C1') `bot` absent; `⊤` present everywhere; `imp` clauses by inspection (`T ∉ L 0 0` since `Pp ∈, ⊡Pp ∉`; `T ∈ L 1 0` since `Pp ∉`); `snce` clause per constant thread: `Pp ∈ L 0 u` iff `p ∈ L 0 (u-1)` — always; `Pp ∈ L 1 u` iff `p ∈ L 1 (u-1)` iff `u ≥ 1`. (C2') `Pp` discharged one step back on its own lasso. (C3) vacuous (no `box`). (C4) `T ∉ L 0 0`. (C5) at `u = 0`: `⊡Pp ∈ L i 0` iff `Pp ∈ L 0 0 ∧ Pp ∈ L 1 0` = false, both absent; `u ≥ 1` both present; `u < 0` singleton classes, `⊡Pp ↔ Pp` on each lasso. `lift`: state paths are exactly the two lasso traces; splice-closed (the splice of either lasso's past with the other's future is one of the two). **Congruence check**: `share 0 0 1`, `Pp ∈ L 0 0`, `Pp ∉ L 1 0` with the redesigned (C1') satisfied — so `snce_share_congr`'s statement is refuted at this family (`not_snce_share_congr`).

Family B (`untlFamily`), certifies `stabUntlTarget p` (`Fp → (¬p → ⊡Fp)`) at `t = 0`, closure `{U, R, ¬p, ⊡Fp, Fp, ⊤, ⊥, p}` with `Fp := untl ⊤ p`, `R := imp ¬p ⊡Fp`, `U := imp Fp R`. Semantics: lasso 0 = state 1 (`¬p`) for `t ≤ 0`, state 0 (`p`) for `t ≥ 1`; lasso 1 = state 1 always.

| index | `t ≤ 0` (`back`, `mid = [same]`) | `t ≥ 1` (`fwd`) |
|-------|----------------------------------|-----------------|
| 0 (main) | `{Fp, ¬p, ⊤}` | `{p, Fp, ⊡Fp, R, U, ⊤}` |
| 1 | `{¬p, U, ⊤}` | `{¬p, U, ⊤}` |

`repBack = [const 0]`, `repMid = [const 0]`, `repFwd = [id]`; `trans` all `[eq]`. Checks: (C0) `p` absent in both at `t ≤ 0`. (C1') `untl` per constant thread: `Fp ∈ L 0 u` iff `p ∨ Fp` at `L 0 (u+1)` — true at every `u`; lasso 1 never. `imp` clauses by inspection (`U ∉ L 0 0` since `Fp ∈`, `R ∉`; `R ∉ L 0 0` since `¬p ∈`, `⊡Fp ∉`). (C2') `Fp` on lasso 0 discharged at `max(u,0)+1` with guard `⊤`. (C4) `U ∉ L 0 0`. (C5) at `u ≤ 0`: `⊡Fp ∈ L i u` iff `Fp ∈ L 0 u ∧ Fp ∈ L 1 u` = false, both absent; `u ≥ 1` singletons. `lift`: two state paths, both lasso traces; splice-closed. **Congruence check**: `share 0 0 1` with `p ∨ (⊤ ∧ Fp)` true at `L 0 0` and false at `L 1 0` — refutes `untl_shift_share_congr`'s statement against the redesigned (C1').

Both families have `trans = eq`, i.e. the minimal repair for the two known targets is hop-free; hopping (design T's generality) is for targets whose countermodels have infinitely many histories, where the exact closure lemma is needed.

What *remains* provable, and is harmless because semantically forced: two positions with the same predecessor set agree on `snce` labels; two positions with the same successor set agree on shifted `untl` unfoldings. Record these as `snce_pred_congr` / `untl_succ_congr` so the next reader knows the relocation is intended.

**Q4 — (C2')'s (C1')-relative limitation.** `threadFulfilling_of_window`'s far-left case uses `untl_propagate_le`, which uses `untl_thread_step`, which uses only `θ.step t` fed to the (C1') `untl` clause at exactly the relation `θ.step` provides. Under T-arrival both change in lockstep (`trans t (θ.idx t) (θ.idx (t+1))` on both sides), so the argument transfers verbatim; `thread_share_pred` becomes a direct instance of `θ.step (t-1)` and loses its rewrite. The limitation is independent of the substrate datum; it is about the position graph's backward region being a path. Verdict: inherit, documented as re-examined; the left-wrap-edge refinement (cycle edge from the last backward vertex alongside `-1 → 0`, fixpoint lemmas over the larger walk set) remains a separate optional task. `succF_nonempty`/`predF_nonempty` still hold via `trans_refl`.

**Phasing (each phase ends green).**

0. Land the `untl`-side incompleteness (`untl_shift_share_congr`, `stabUntlTarget`, `not_plusCertifies_stabUntl`, `not_plusValidZTime_stabUntl`) in `Incompleteness.lean` from the archived probes; add three C2 rows and three `theorem-index.md` rows; correct the two READMEs' "`untl` half is a genuine repair" / "defect-free by inspection" claims. Small, and it fixes the record before the redesign.
1. Additive data layer: `trans` lists, decoding, periodicity twins, `trans_refl`, arrival-pruned `trans`, `LiftableRaw`/`lift` field, `liftable_of_full`, `liftable_of_spliceClosed`; `Basic.lean` (both sides) fields and re-exports; `Specialize.lean` and `Examples.lean` producers supply the new fields (`transRaw := full`, `lift := liftable_of_full`). `Thread.step` unchanged. Green, no statement changes.
2. Substrate switch: `Thread.step := trans`, `Thread.const`, `thread_is_history`, `total_eq_thread` from `lift`; `Window.lean` edges/walks; `Fulfil.lean` (both) and `Agreement.lean` (both) proofs patched via `thread_share_succ : share (u+1) (idx u) (idx (u+1))` (derived from arrival pruning) wherever the *old* (C1') clause is applied to a thread step. Statements unchanged; green. C2 still passes.
3. Formula side (C1') re-quantified over `trans`: `Predicates.lean`, `Decide.lean` (`shareClauseAt` data, `data_congr`), `Fulfil.lean` propagation, `Agreement.lean` along-thread lemmas, `Specialize.lean` reductions. Green.
4. Plus side, same. Green; the three old `Incompleteness` proofs now fail to elaborate — replace with `not_snce_share_congr`, `not_untl_shift_share_congr`, `plusCertifies_stabSnce_example`, `plusCertifies_stabUntl_example` (Families A and B, in `Examples.lean`, `lift` via `liftable_of_spliceClosed`, conditions by `decide` at a concrete atom or by the `stabFamily_L`-style decoding lemmas), keep both `not_plusValidZTime_*`. Rewrite the C2 baseline and the index rows *visibly*; update both READMEs and the module docstring. Green.
5. (Separate follow-up task, not the gate.) Exact closure: `LiftWindow` by subset construction over the skeleton's own window, `liftable_of_liftWindow` by compactness, `Decidable LiftWindow`.

Task 694 should be folded into this task (its `trans` proposal is the recommended design's core; it lacks arrival pruning, the closure field, the `untl`-side finding, and the concrete families).

## Decisions

- The `trans` datum is adopted, **pruned by arrival renaming**, so the frame section of `Skeleton.lean` is not re-proved (F5).
- Thread-lifting is a **skeleton field**, not a `Certifies` conjunct, to keep the pinned theorem statements literally unchanged (A7) and because it is label-free well-formedness of the same kind as `rep_idem`.
- `trans` segments have the same lengths as `rep` segments, so the window machinery extends without new arithmetic (F8).
- The `untl`-side incompleteness is landed **first** (Phase 0) because it corrects the task's own premise and gives a second, independent flip signal.
- The exact closure decision procedure is deferred to a follow-up; the gate families need only the splice-closed lemma.
- Candidates B, B', C, D, T-free and pair-indexed labels are rejected for the reasons in the Q2 table; D and the current design survive as sufficient lemmas.

## Risks & Mitigations

- **Risk**: `decide` on `PlusCertifies 0` for the example families may be slow or fail to reduce (Finset fixpoints, closure computation). **Mitigation**: state each condition with the `stabFamily_L`-style decoding lemmas as `Examples.lean` already does; use `decide` only per condition; `native_decide` is not used in this tree (Axiom Audit in `BXCanonical/Completeness.lean`).
- **Risk**: making `lift` a structure field means every producer must discharge it; a malformed export fails at structure construction rather than at `Certifies`. **Mitigation**: this is the same posture as `rep_idem`; document in the hand-off section of the Sharing README, and provide `liftable_of_full` so today's exports need no new proof.
- **Risk**: the exact closure (Phase 5) is a substantial new layer; without it, hopping families beyond arrival renaming and beyond splice-closure cannot be certified. **Mitigation**: it is not needed for the gate; scope it as its own task with the compactness lemma named here.
- **Risk**: C2 fails between Phases 4 and the baseline rewrite. **Mitigation**: rewrite the baseline in the same phase, and cite the failure in the summary as the intended transition.
- **Risk**: hidden `share`-as-succession uses beyond F6. **Mitigation**: after Phase 2, `grep -n "share (.*+ 1)\|share_refl (.*+ 1)"` across both `Fulfil.lean`, `Window.lean`, `Agreement.lean` is the checklist.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The research phase used whole-file elaboration of two probes with `lake env lean` rather than per-goal tactic trials; both probes closed with elementary term-mode proofs (`Iff.trans`, `rw [sub_add_cancel]`, `by_contra`, `rcases`).

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `untl_shift_share_congr` | term proof via two clause readings + `rwa [sub_add_cancel]` | success | (C1') only |
| `not_plusCertifies_stabUntl` | `rintro` + closure projections + `rcases` | success | (C0), (C1'), (C4), (C5) |
| `not_plusValidZTime_stabUntl` | `someFuture_iff`, `simp`, `one_ne_zero` | success | `PlusNonValidities.NF`, `natModel` |

## Context Extension Recommendations

- **Topic**: Substrate rule of thumb for branching certificates. **Gap**: both READMEs state the rule as "a condition quantifying over the class at the label's *own* time collapses"; F3 shows the correct rule is "a condition quantifying over the one-step reach of a position collapses whenever that reach is a whole class, at either time". **Recommendation**: replace the rule-of-thumb paragraphs in `WitnessFamily/Sharing/README.md` and `PlusWitnessFamily/README.md` in Phase 0.
- **Topic**: Closure conditions for finite presentations of all-histories frames. **Gap**: no context file records why index-level splice conditions fail and why compactness is the right shape. **Recommendation**: a short note in `.claude/context/project/lean4/` (or the Sharing README) summarising F4 for future planners.

## Appendix

- Probe elaboration: `cd /home/benjamin/Projects/BimodalLogic && lake env lean specs/696_stability_modal_substrate_design/probes/01_untl_shift_congr_probe.lean` (exit 0, no output); same for `02_untl_target_nonvalid_probe.lean`.
- `lean_local_search` queries: `nonempty_iInter_of_sequence_nonempty_isCompact_isClosed` (hit: `IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed`), `exists_infinite_fiber` (hit: `Finite.exists_infinite_fiber`).
- Sibling tasks: 694 (`sharing_substrate_trans_redesign`, `not_started`, depends on 685) — fold in; 695 (`plus_carrier_normalization_int_transfer`) — independent, untouched.
- Line counts at time of research: `Sharing/Skeleton.lean` 946, `Window.lean` 639, `Decide.lean` 567, `Fulfil.lean` 1673, `Agreement.lean` 411, `Specialize.lean` 455; `PlusWitnessFamily/Fulfil.lean` 1093, `Decide.lean` 969, `Agreement.lean` 423, `Examples.lean` 413, `Incompleteness.lean` 250.
