# Research Report: Task #761

**Task**: 761 - Ladder realization theorem: LadderCons and ladderRealized per ladder cell for all φ including box/stab letters
**Started**: 2026-10-12T00:48:11Z
**Completed**: 2026-10-12T01:40:00Z
**Effort**: ~1 hour (research only; no library code written)
**Dependencies**: 760 (logical: `ladderModel`, `Adm`, `LadderState`, `ladderFrameAdm` are this theorem's inputs; no finite cell index provided)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/RaySummary/{LadderModel,AnchorLayer,RunLayer,Realize,Trace,Closure,HitOf,Present,Compose,Transport,StabCheck}.lean`, `RaySummary/README.md`, `FormalSystem/PlusLanguage/PlusTruth.lean`, `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`
- Wired probes: `specs/evidence/seam-gluing-ray-product/{ladder-cell-refutation,w-soundness-shape-refuted,hit-presented-model-a,hit-presented-node,node-cell-stabilization}.lean`
- Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C, D, H4; `specs/765_.../plans/01_ladder-carrier-repair-index-deletion.md`; `specs/760_.../reports/01_ladder-cell-stabilization-refuted.md`
- lean-lsp MCP: `lean_local_search` (index `warming` on every call — grep-backed evidence tier, see Appendix), `lean_run_code` (one compiled probe, below)
- Literature: HWZ 2000 corpus chunks 0021-0023 (Definitions 10-12, Remark 13, Theorem 14 and its proof) — UNVERIFIED-summary provenance, orientation only
**Artifacts**: - `specs/761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **`ladderRealized` cannot be stated as filed.** `hitOf` requires `[Fintype Q]` on the presentation; the ladder carrier `LadderState Q pend` is infinite; the only finite presentation the statement names, `truncate B …`, is defined nowhere in the tree, and its only possible reading — the counter-clipping quotient `Q × Fin (B+1) × Fin (B+1)` — is exactly the index the amended description deletes. The amended description is internally inconsistent: its statement line retains `hitOf (truncate B …)` while its deletion clause removes that device's only meaning.
- **The open index sub-problem is a prerequisite of ANY per-cell soundness statement for the ladder, not merely of the `truncate` phrasing.** Three independent, library-grounded reasons (Findings F2): (a) `cell_ne` makes every `Q`-indexed cell assignment unsaturated; (b) the `Q`-projection of a seam's fibre is a proper subset of the `Q`-runs through the seam state (the counters constrain pend-patterns), so even for `box`/`stab`-free `φ` a `Q`-presentation's `hitOf` over-approximates; (c) COLLAPSE generalizes beyond `Presented`+`nowUnique`: any truth lemma that reads closure letters off the world state forces `ψ ↔ ⊡ψ` at every state, so an object must carry a SET of types per ladder state (HWZ's state candidate), which a finite object can do only through a finite index.
- **The acceptance clause (`box`/`stab` pinned per cell) is itself index-dependent**, so `LadderCons` as specified cannot be formulated either; a `Cons`-like bundle without the pinning would be a strictly weaker statement under the task's name (Statement Fidelity).
- **One design question is settled, machine-checked:** the ladder's structural liveness is FORWARD-ONLY. On the Bool fixture, `z ↦ (true, (-z).toNat, B)` for `z ≤ 0` then idle is an `IsSlicedStepPath` of `RladAdm` (`gPast_isPath`, compiled via `lean_run_code`, axioms `[propext, Classical.choice, Quot.sound]`, no sorry): a history pending at every past time. So `Cons.slive` cannot be replaced by `Count`; only `ulive` can.
- **Recommended outcome: `[BLOCKED]`** on the open index sub-problem, with the obstruction landed as a wired probe and recorded in the README/design of record (R1). The index-free, `box`/`stab`-free run-layer half (R2) is landable but is not this task's deliverable and should not be agent-chosen; it is surfaced as a non-blocking `user_decision`.

## Context & Scope

The dispatch asks for the run layer's soundness half on the admissible-carrier ladder frame: a structure `LadderCons`, a run-conditions theorem `ladderCons_localRun`, and a Hit-level per-cell realization `ladderRealized : HitCl (ladderModel …) τ t φ k = ↑(hitOf (truncate B …) … (clNow φ) k)` for ALL `φ`, `box`/`stab` letters included, with the deleted index recorded as an open sub-problem. Constraints: never sorry/axiom/vacuous definition/trace-level hypothesis/finite-fibre or finite-width assumption; guardrails (a)-(e); file scope `LadderRealize.lean` plus the shared pin/index/README set.

This report evaluates whether the three statements can be formulated and closed on the tree as it stands, what transfers from `Realize.lean`, what the two Hit-level positives in the evidence collection do and do not offer, and what the honest outcome is.

## Findings

### Codebase Patterns

**F1 — `truncate` does not exist, and the amended description contradicts itself.**
`grep -rn truncate FormalSystem/ specs/evidence/ docs/theorem-index.md` returns no definition; the only hits are unrelated prose (`negChainOn` truncation in `Expressiveness/Kamp/*`, `MintBound` fuel) and the two fixture theorems `hitCl_eq_truncated` (model A) / `hitCl_eq_truncated_node` (Node), which truncate a SEAM INDEX WINDOW, not a ladder. The 765 amendment deleted "over the finite cell index T3 provides" and `Q × Fin (B+1) × Fin (B+1)` from the description but left `hitOf (truncate B …)` in the statement line, which is that index under another name. Section H4's own text carries the same residue.

**F2 — No finite presentation derived from a `Q`-indexed object can satisfy `HitCl = hitOf` on the ladder; the index is the prerequisite.** Three independent reasons, each grounded in a landed declaration:

(a) *Cells are counter-dependent.* `Probe760.cell_ne B : cellAt M phi (w1 B) 0 ≠ cellAt M phi (w2 B) 0` for every `B`, with `w1 B = (0, (true, B, B+1))`, `w2 B = (0, (true, B, B+2))`. A presentation whose states carry cells indexed by `q ∈ Q` assigns one type set to both; it either contains the `phi`-bearing type (unrealized at `w2 B`) or omits it (realized at `w1 B`). The quasimodel SATURATION condition — "for every `w` and every `t ∈ T_w` there is a run with `r(w) = t`" (HWZ Def. 12, chunk 0022) — therefore fails on every `Q`-indexed candidate.

(b) *The frame itself is counter-constrained, independently of cells.* `Rlad`'s `Count` clause makes a pending state `(q, c, n)` idle at exactly `z + c + 1` (`Count true true` forces `c' + 1 = c`; `Count true false` forces `c = 0`; `Probe760.pending_run`/`idle_at` on the fixture, the same two clauses over any `Q`). A `step`-chain through `q₀` whose pend-pattern does not end its region in exactly `c₀` steps lifts to NO `RladAdm` path through `(q₀, c₀, n₀)`. So the `Q`-projection of the seam fibre at `(t, (q₀, c₀, n₀))` is a proper subset of `{ρ | IsRun lab step (clNow φ) t ρ}`, and `hitOf lab step (clNow φ) k` over `Q` over-approximates `HitCl` even for `box`/`stab`-free `φ`. The truncated carrier was needed for the FRAME structure, not only for the cells.

(c) *COLLAPSE generalizes to every per-state labelling.* `PlusTruthAt M τ t (.stab ψ) ↔ ∀ σ, τ.state t = σ.state t → PlusTruthAt M σ t ψ` (`PlusTruth.lean:93`). If a truth lemma reads `ψ`'s truth at `(σ, z)` off `σ.state z` alone (as `lab (g z).1.1 (clLetter ψ)` on the ladder would), then `ψ → ⊡ψ` at every point, for every closure `ψ` — `Probe747.stab_iff_of_presented_nowUnique`'s conclusion with its two hypotheses dropped. Such a lemma is false for any object with a non-deterministic `step` and an `untl`-letter (two histories through one state with different futures). Hence a per-cell object must carry a SET of types per ladder state and its runs are `(state, type)`-paths (HWZ runs). A FINITE object can describe type sets for the infinitely many ladder states only through a finite index of those states — the open sub-problem. By (a), `Q` alone is not such an index.

Consequence: every shape of the soundness half that the lift (H6, (←) direction) could consume — `HitCl = hitOf`, `HitPresented`, or a truth lemma on `(state, type)`-runs — is stated over a finite presentation of ladder states and is therefore blocked on the same sub-problem. "Which cell a ladder state has" is not a side question of the realization theorem; it is its hypothesis.

**F3 — The acceptance clause is index-dependent too.** "The stab letter at `(q, c, n)` is that cell's bit" presupposes a presentation state per cell at which the bit is stored; `stab_mem_tpOf_iff` is the equation `⊡ψ ∈ T ↔ ∀ T' ∈ cell, ψ ∈ T'`, stated per cell. With no index, a `LadderCons` field can only pin `lab q (⊡ψ)` per `q`, which by F2(a) is the wrong granularity. So the `box`/`stab` half of `LadderCons` — the task's named acceptance criterion and the place where obligation (3)'s first half lands — cannot be formulated. A `LadderCons` lacking it would be a same-named, strictly weaker restatement, which `plan-compliance.md`'s Statement Fidelity section forbids.

**F4 — Structural liveness is forward-only (machine-checked).** Compiled via `lean_run_code` against `RaySummary.LadderModel` this session (no sorry; `#print axioms` reports `[propext, Classical.choice, Quot.sound]` for both):

- `gPast (B) (z) := if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)`, admissible at every `z` (`gPast_adm`);
- `gPast_isPath (B) : IsSlicedStepPath (RladAdm stepB pendB) 0 (gPastA B)` — proof: `rcases lt_trichotomy z 0`, then `simp [h1, h2, Drift, Count]` and `omega` per branch;
- `gPast_pending_past (B) (z) (hz : z ≤ 0) : (gPastA B z).1.1 = true`.

So an `RladAdm` history can be pending at every past time (backward, `Count true true` INCREASES `c`), and a `snce`-letter claimed along it is never structurally discharged. The design of record's "the liveness fields `ulive`/`slive` replaced by the ladder's structural liveness" is half right: `ulive` can be replaced (forward, by the field `∀ q, lab q u = true → lab q e = false → pend q = true` plus the idle-at-`z + c + 1` lemma and `persist`), `slive` must stay as the `SLive` deferral-graph condition of `Realize.lean` over `Q`'s `step` (sound on ladder paths because `Rlad`'s first conjunct makes the `Q`-projection a `step`-chain). This matches guardrail (e): the landed liveness would be forward-only, and the record must say so.

**F5 — What transfers from `Realize.lean` (1004 lines, measured).** Reusable verbatim on the `Q`-projection of an `RladAdm` path: `UCoh`, `deferGraph`, `Disch`, `persist`, `u_of_disch`, `SCoh`, `bwdDeferGraph`, `SLive`, `DischBwd`, `persistBwd`, `u_of_dischBwd`, `snce_iff_of_SCoh_SLive`, and `cons_localRun`'s `bot`/`imp` cases (all generic over `sig`, `Q`; none mentions a model). New content needed for the forward half only: `idle_after_pending` (over any `Q`: pending at `(q, c, n)` at `z` ⇒ idle at `z + c + 1`) and `untl_iff_of_UCoh_ladderLive` (replacing `ULive` by the pend-field, ~100-150 lines). NOT transferable: `frameOf`/`modelOf` (WIDTH), `presented_modelOf` (trace level), `anchored_runTrace_of_boxStabFree` (vacuous on `box`/`stab`), `run_seam_state`/`isRun_of_chain_seam` (per-`Q` `now` bookkeeping that F2(b) makes insufficient on the ladder).

**F6 — The two Hit-level positives are fixture arguments and offer no general route.** `Probe745.hitCl_eq_truncated` and `Probe759.hitCl_eq_truncated_node` both rest on (i) a seam classification (model A: `path_classify` off `v = u ∨ v = b`; Node: `through_pre`, exactly `m + 1` histories), (ii) a constant-block run (`ℓ₀`/`ℓ₂`) whose `k`-type is eventually periodic (`kTypeOf_listSeg_replicate_eventually_periodic_bounded`), and (iii) the fixture fact `run_subset_middle`. The model-A header states "This does NOT generalize … the `⊆` direction of that route is open"; Node's seam fibres are finite. On the ladder the seam fibre at a fixed `(q₀, c₀, n₀)` is infinite for any object with a pending cycle (backward, `Drift` offers up to three predecessors per step), and no constant-block structure is available. Nothing in the tree supplies a truncation lemma for a general object, and the general-model version is H5/task 762's open row.

**F7 — Related landed facts the plan must cite rather than re-prove.** `anchorCells_finite`, `anchorCells_ncard_le` (the SET of cells is finite and bounded — untouched); `anchorCons_anchorCells` (the completeness side of the pinning equations, for every model); `no_fwd`/`no_bwd_of_idle` (why the carrier is restricted); `ladderFrameAdm_isRegular`, `ladderModel`; `Rlad_slice_infinite` (width); `Probe747.modelOf_incomplete` (WIDTH), `Probe747.stab_iff_of_presented_nowUnique` (COLLAPSE).

### External Resources

- **Mathlib**: nothing new is required by any option below; the one compiled probe used only `omega`, `simp`, `split_ifs`, `lt_trichotomy`. No rate-limited search (`leansearch`/`loogle`/`leanfinder`/`state_search`/`hammer_premise`) was needed.
- **lean-lsp**: `lean_local_search` reported `index: warming` on every call (for `HitPresented` it still returned the four `Trace.lean` hits); per the readiness rule no empty result was treated as absence — every declaration named in this report was located by `grep` in its source file and is compile-verified by the existing `.olean`s (the library builds; `LadderModel`'s `.olean` is current per 765's Phase 1).
- **Literature**: HWZ 2000 chunks 0021-0023 (see "Literature Proof Structure"); `literature-search.sh` returned `degraded: true` with no results, so the chunks were located by `grep` in the source directory (issue recorded).

### Recommendations

**R1 (recommended) — `[BLOCKED]`, with the obstruction landed and the records corrected.** The dispatch's own contingency, triggered one level earlier than it anticipated: the theorem does not merely fail to close, it cannot be stated without the open index. Plan shape:

1. *Wired probe* (new, e.g. `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`, per the 758/759/760 header conventions): `gPast_adm`, `gPast_isPath`, `gPast_pending_past` as compiled above (verdict: structural liveness is forward-only; `slive` is not replaceable), citing `RaySummary/LadderModel.lean` and re-proving nothing; `#print axioms` foot; one `WIRED` entry and table row in `scripts/check-evidence-probes.sh`. Optional second theorem, if the planner budgets it (~150-250 lines, risk-bearing): `hitCl_ne (B) (k) (hk : 1 ≤ k) : HitCl M τ₁ 0 phi k ≠ HitCl M τ₂ 0 phi k` for histories through `w1 B`/`w2 B` — the Hit-level twin of `cell_ne`, via a depth-1 sentence `∃x (now x ∧ phi x)` on the middle segment (`eval_iff_of_kTypeOf_eq`, and the argument of `live_of_run`'s `hmid` that `now` lies in the middle segment). It would show directly that no single `truncate B` presentation serves two cells; `cell_ne` already carries the record's weight, so this is strengthening, not load-bearing.
2. *Records*: README "(W): what landed and what did not", item 1 — the soundness half is `[BLOCKED]` because any per-cell object must index ladder states (F2) and the acceptance clause presupposes that index (F3); structural liveness is forward-only (F4). `docs/theorem-index.md` rows already read "phase 2, open" and need no change beyond, at most, the forward-only remark. Design of record: `followup-scope-spec.md` Sections A, C, D, H4 — delete `hitOf (truncate B …)` as a residue of the deleted index; replace "`ulive`/`slive` replaced" by "`ulive` replaced, `slive` retained"; H6/763's (←) clause depends on this record and inherits the block. Task 761's own description via `state-write.sh`. Durable anchors only outside `specs/**`.
3. *No `LadderRealize.lean`*: with the acceptance clause unstatable there is no declaration to put in it; creating a module to hold the run-layer half alone is R2 and a user's call.

**R2 (user-selectable, not agent-chosen) — land the index-free, `box`/`stab`-free run-layer half under an honest name.** `LadderRunCons φ lab step pend` with fields `botFalse`, `impEq`, `ucoh`, `scoh`, `ulivePend : ∀ ψ χ h q, lab q u = true → lab q e = false → pend q = true`, `slive` (as in `Cons`); `idle_after_pending`; `untl_iff_of_UCoh_ladderLive`; `ladderRunCons_localRun (hC) (g : ℤ → LadderState Q pend) (hg : IsSlicedStepPath (RladAdm step pend) k g) : LocalRun φ (runTrace lab (fun z => (g z).1.1))`. Estimated 250-350 lines plus pins (`KTypeSummaryAxiomTest.lean`, both C14 heredocs), two theorem-index rows, aggregator imports. Honest docstring: forward-only structural liveness, no `box`/`stab` clause, no realization, no consumer in the tree. Why not agent-chosen: it is (S)'s corner transposed to the ladder, lands none of the acceptance criterion, and 760's precedent (its R2) was that landing sound-but-consumerless parts is a user ruling.

**R3 (recorded, not recommended) — a realization theorem parametric in an abstract index.** Take `idx : LadderState Q pend → I` with `[Fintype I]`, cells `C : I → Finset (Finset PlusFormula)`, and a saturation hypothesis, and prove the truth lemma conditionally. This is not a re-statement over a concrete substitute, but it is the unsatisfiable-hypothesis form the tree already flags on `ladderFrame` unless some `idx` is exhibited for a `⊡`-bearing `φ` — which is the open sub-problem again. Research-level; costable only after that sub-problem moves.

**Forbidden under every option** (dispatch; `lean4.md`; `plan-compliance.md`): sorry, axiom, `def := True`, a trace-level hypothesis, a finite-fibre or finite-width assumption, a capped ladder, stating `LadderCons` without its `box`/`stab` clause UNDER THAT NAME, re-stating the index over the clipped-gap candidate, citing a Büchi/MSO theorem in place of a proof.

## Decisions

- **D1**: The realization theorem is reported as unstatable (F1-F3), not merely unclosed; the recommended outcome is `[BLOCKED]` per the dispatch's CONTINGENCY. Grounds: the three library-anchored obstructions in F2 and the acceptance clause's dependence on the index in F3.
- **D2**: The forward-only liveness fact was machine-checked in this research phase (one `lean_run_code` compile) rather than left as prose, so the plan can transcribe it into a wired probe without a feasibility risk.
- **D3**: `slive` is retained, `ulive` is replaced — a correction to the design of record's "`ulive`/`slive` replaced", grounded in F4.
- **D4**: R2 is surfaced as a non-blocking `user_decision` (recommended: R1), mirroring the 760 precedent that landing sound-but-consumerless library parts is the user's ruling. The loop proceeds on R1.
- **D5**: No tactic survey beyond the compiled probe was run: no open goal of the dispatched theorem exists to survey, because the theorem has no statement.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| The planner reads `[BLOCKED]` as licence to land `LadderCons` without the `box`/`stab` clause under the task's name | H | F3 and Statement Fidelity: any landed bundle must carry a different name and a docstring saying the acceptance clause is absent (R2), or nothing lands (R1) |
| The optional `hitCl_ne` probe theorem does not close in budget | M | It is strengthening only; `cell_ne` carries the record. Plan it as its own phase with an honest-outcome clause, or omit it |
| Record edits re-introduce the deleted index or a cost figure | M | Guardrail (c); grep the touched records for `truncate`, `Fin (B+1)`, `min c B`, `clip (n`; every quantity named is a count |
| Concurrent writers on `state.json`/`ROADMAP.md` (several orchestrations live) | M | `state-write.sh` only, bounded retry on the mutex; re-read `ROADMAP.md` before touching the 761 authored bullet |
| Record-versioning or task-number phrasing leaks into README/probe-gate comments | M | Durable anchors only; `check-task-references.sh` on each non-`specs/**` file touched |
| A future index result (the open sub-problem) makes this block obsolete | L | The README entry names the index as the prerequisite, so a successor record for the sub-problem unblocks this one by dependency, not by rewrite |

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `(gPast B z).2.1 ∈ Adm pendB (gPast B z).1` | `change …; unfold gPast; split_ifs <;> simp` | success | none |
| `Rlad stepB pendB (z+0) (gPast B z) (gPast B (z+1))`, branch `z < 0` | `simp [h1, h2, Drift, Count]; omega` | success | `h1 : z ≤ 0`, `h2 : z + 1 ≤ 0` |
| same, branch `z = 0` | `subst heq; simp [Drift, Count]` | success | none |
| same, branch `z > 0` | `simp [h1, h2, Drift, Count]` | success | `h1 : ¬ z ≤ 0`, `h2 : ¬ z + 1 ≤ 0` |
| same, branch `z < 0`, first attempt | `simp only [h1, h2, if_true]; refine ⟨rfl, …⟩` | fail | `simp` had already reduced `stepB _ _ = true` to `True`, so `rfl` mismatched; use the full `simp` form above |
| `(gPastA B z).1.1 = true` under `z ≤ 0` | `simp [gPastA, gPast, hz]` | success | none |
| `ladderRealized` (any direction) | — | not applicable | no statement exists to survey (F1-F3) |

## Literature Proof Structure

**Source**: Hodkinson–Wolter–Zakharyaschev 2000, *Decidable fragments of first-order temporal logics*, Definitions 10-12, Remark 13, Theorem 14 (corpus chunks 0021-0023; provenance UNVERIFIED-summary — orientation only, sources no claim).
**Strategy**: construction (⇐ direction): build a model whose domain is the set of runs, realize each quasistate by a first-order structure, prove a truth lemma by induction on subformulas.

### Step Map
1. A *state candidate* is a pair `⟨T_w, T_w^con⟩` of a set of types and constant-tagged types; a *state function* `f` assigns a realizable state candidate to each time `w` — [HWZ] Def. 10 (chunk 0021).
2. A *run* in `f` is `r : W → ⋃ T_w` with `r(w) ∈ T_w` and the `U`/`S` clauses unfolded pointwise (`ψ₁Uψ₂ ∈ r(w)` iff `∃ v > w, ψ₂ ∈ r(v) ∧ ∀ u ∈ (w, v), ψ₁ ∈ r(u)`; mirror for `S`) — Def. 11 (chunks 0021-0022). This is `LocalRun.untl`/`.snce` verbatim.
3. A *quasimodel* `⟨f, R⟩` requires (i) each constant's type sequence is a run in `R`, (ii) **saturation**: every `t ∈ T_w` lies on some run `r ∈ R` with `r(w) = t` — Def. 12 (chunk 0022).
4. Remark 13: run sets are upward closed, so `⟨f, Ω_f⟩` with ALL runs may be taken — the run set is chosen freely.
5. Theorem 14 (⇒): read types off a model, `t_a = {ψ ∈ sub_x φ : (M, w) ⊨_a ψ}`, each domain element `a` gives a run `w ↦ t_{I(w)}(a)` — the anchor layer's `tpOf`/`anchorCons_anchorCells` direction.
6. Theorem 14 (⇐): take `D = Ω_f × κ` (domain = runs, padded by a cardinal), realize each `f(w)` by a structure `I(w)` with `r(w) = {ψ : I(w) ⊨ ψ[⟨r, ξ⟩]}` (Lemma 9), and prove `I(w) ⊨_a ψ̄ ↔ (M, w) ⊨_a ψ` by induction on `ψ`; the `U` case is Step 2's clause read through the induction hypothesis — chunk 0023.

### Dependencies
- Step 6 depends on Steps 2 (run clauses), 3(ii) (saturation, used by Lemma 9 to realize each state candidate), and 4 (all runs available).
- Step 5 is independent of 3-4 and is already landed at cell level (`anchorCons_anchorCells`).

### Potential Formalization Challenges
- **Step 6, the domain**: HWZ's worlds ARE runs, so the truth lemma is per run. In this semantics histories are the path set of a frame (`ofSlicedStepFinBranch_mem_HF_iff`), closed under splicing and limits, and `⊡`/`□` quantify over histories through a state; a run cannot be chosen, padded, or made a world — the README's "The obstruction has a literature description" paragraph, confirmed here.
- **Step 3(ii), saturation**: the condition a per-cell ladder object must satisfy, and the one `cell_ne` shows no `Q`-indexed candidate meets (F2(a)). Expressing it at all requires a finite index of ladder states — the open sub-problem.
- **Step 4**: free choice of `R` is what makes HWZ's liveness trivial; on the ladder, liveness is structural and forward-only (F4), so a backward condition (`slive`) must be carried by the object.
- No step of HWZ's proof mentions a deadline counter; the ladder exists because of the frame-path semantics, so no HWZ step maps onto `Count`/`Drift`.

## Context Extension Recommendations

- **Topic**: The per-state-labelling collapse as a general principle.
- **Gap**: `Probe747.stab_iff_of_presented_nowUnique` is recorded as a fact about `Presented`+`nowUnique`; F2(c) shows the mechanism is the `stab` clause itself, biting any construction that reads closure truth off the world state. Only the README's prose carries this.
- **Recommendation**: Add a short paragraph to `context/project/lean4/` (or the RaySummary README's "(W)" section, which the plan already edits) stating the principle and its consequence — per-cell objects carry SETS of types — so successor designs do not re-derive it.

## Appendix

- **Searches**: `grep -rn truncate FormalSystem/ specs/evidence/ specs/757_*/ docs/theorem-index.md` (no definition; 2 fixture theorems named `hitCl_eq_truncated*`); `grep -n "^theorem\|^def\|^structure" RaySummary/{Realize,HitOf,Present,Trace,Closure}.lean`; `grep -n "Theorem 14\|Definition 12\|Remark 13"` over the HWZ chunk directory (hits in chunks 0022-0026, 0033, 0037); `lean_local_search "HitPresented"` (index `warming`; 4 `Trace.lean` hits returned).
- **Compiled probe** (this session, `lean_run_code`, imports `FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`): `PastProbe.gPast`, `gPast_adm`, `gPastA`, `gPast_isPath`, `gPast_pending_past`; `#print axioms` → `[propext, Classical.choice, Quot.sound]` for both theorems; no sorry. Source text is in Finding F4 and the Tactic Survey; the plan should transcribe it into the wired probe with the collection's header conventions.
- **Line counts measured this session**: `Realize.lean` 1004, `LadderModel.lean` 195, `AnchorLayer.lean` 418, `RunLayer.lean` 373, `HitOf.lean` 810, `Trace.lean` 418; `hit-presented-node.lean`'s `#print axioms` foot sits at line 1426.
- **References**: `RaySummary/README.md` "(W): what landed and what did not" and "The obstruction has a literature description"; `followup-scope-spec.md` Sections A (amendment paragraph), C, D (amendment paragraph), H4; `specs/760_.../reports/01_ladder-cell-stabilization-refuted.md` "Why this breaks the filed successor chain"; `context/standards/user-decision-contract.md`; `.claude/rules/plan-compliance.md` (Statement Fidelity).
- **Issue log** (`specs/761_ladder_realization_theorem/issues.jsonl`): one `issue` (literature-search degraded; grep fallback), one `win` (forward-only liveness machine-checked before planning).
