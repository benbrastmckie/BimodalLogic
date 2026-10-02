# Research Report: Task #705

**Task**: 705 - trans_reflexivity_residual_collapse
**Started**: 2026-10-02T13:47:33Z
**Completed**: 2026-10-02T14:20:00Z
**Effort**: research-first audit, completed; implementation of the record is small (one Lean file, four one-line theorems, three doc surfaces)
**Dependencies**: 696 (completed), 703 (completed)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/{WitnessFamily/Sharing,PlusWitnessFamily,PlusSlicedCertificate}/`), task 696 report 01 / plan 02 / summary 02, task 703 plan 06 / summary 07, archived task 699 probe `01_clause_shape_collapse_probe.lean`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh` (read-only), `lean_local_search` (index unavailable; grep authoritative). No web search: the dispatch records that no published source bears on this internal audit, and none was sought.
**Artifacts**: - specs/705_trans_reflexivity_residual_collapse/reports/01_trans-reflexivity-residual-audit.md
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal:logic

## Executive Summary

- **Verdict: RETAIN `trans_refl`.** Scope item (1)'s expected answer — "every site consumes only the existential" — is **false**. Four categories of landed consumers need the self-step specifically, not merely some thread through a position: (a) the (C1')→(C1) and (C2')→(C2) deterministic reductions, consumed by `Specialize.lean`'s two biconditionals; (b) the finite-walk-to-thread extensions `FwdWalk.toThread` / `BwdWalk.toThread` (both `Fulfil.lean` and `Window.lean`), which hold the index constant off the walk; (c) the decidable (C2') checker's no-dead-ends lemmas `succF_nonempty` / `predF_nonempty` and the default escape edge inside `window_of_threadFulfilling` (both language sides); (d) the landed incompleteness theorems `Limits/NoCertificate.lean` and `Limits/HopFree.lean`, which read the `untl` clause reflexively.
- **The residual does not exist on the landed `PlusSlicedCertificate`.** That class carries no `trans` field by explicit design (`PlusSlicedCertificate/Basic.lean` header, "no `trans`"), its `edge` relation is bi-serial but not reflexive, and `untl`/`snce` are read on **run** labellings (`LabRun.lab : ℤ → Finset`, coherent via the one-position `PlusLocalCoherentSeqLab`), while slice labels carry only state formulas (atoms, `⊡`, `□`). There is no cross-successor `untl` clause on a position row for `clause_shape_collapse` to apply to. The hopping generality design T existed to admit is now delivered by the sliced class's bi-serial edges, which is the programme's completeness route.
- **The residual is bounded and already dominated.** On the retained sharing class the reflexivity-induced congruence is exactly `clause_shape_collapse` at `R := S.trans t` and nothing stronger; and the class is proven incomplete at `pumpTarget` **under no hypothesis on `trans` at all** (`not_exists_plusCertifies_pumpTarget`). Dropping `trans_refl` would enlarge a class that stays incomplete at the same target, for a cost of roughly 87 term-level sites across 18 Lean files plus three doc surfaces — not the "one substitution lemma" the task anticipated.
- **Scope item (3) is partially done, under a name collision.** `untl_succ_congr` / `snce_pred_congr` landed in `Sharing/Agreement.lean` (Formula side only), but they are the *common-source unfolding* congruences — all successors of one position agree on the unfolding. The label-level statements this task names — `tUntl_trans_congr` (via reflexivity) and `tUntl_common_succ_congr` (reflexivity-free) from the 699 probe — are recorded **nowhere** in the tree, on either side; no `*_trans_congr` declaration exists. The recommended implementation lands those four one-line theorems in `PlusWitnessFamily/Incompleteness.lean` (this task's declared `file_scope`) with the explanatory docstring, plus index rows.
- **Scope item (4) is not triggered.** Reflexivity is required by *consumers* (checker, walk extension, reductions), not because some target forces it; and a trans-congruence-specific incompleteness theorem would be strictly weaker than the landed class-level one. No countermodel construction is recommended.

## Context & Scope

The task was filed as a pre-emption; both status notes supersede it. `trans_refl` is a landed field at three declaration sites (`SharingSkeleton`, `SharingWitnessFamily`, `PlusSharingWitnessFamily`, the latter two delegating through `.skeleton`), with `trans_refl'` (`@[refl]`) and `transRaw_refl` derived. Task 703 completed and landed `PlusSlicedCertificate` with soundness (`Sound.lean`), a decidable checker (`Check.lean`), and completeness relative to tail-stable sliced models (`Complete.lean`); the sharing class is retained with its limits recorded (`Limits/`). The dispatch directs that relevance be decided against the landed sliced class, not the withdrawn lasso/finite-graph classes.

The audit covered every term-level use of `trans_refl`, `trans_refl'`, `transRaw_refl`, `Thread.const`, and `instNonemptyThread` in `FormalSystem/`, plus the sliced tree's structural dependence on the sharing substrate.

## Findings

### Codebase Patterns

**F1. The residual's two shapes, and what is recorded.** On a `PlusSharingWitnessFamily` with `h : S.PlusLocalCoherentShare`, the following are one-liners (exactly the 699 probe's theorems, instantiated at the landed `S.trans` instead of an external parameter):

| Shape | Statement | Needs `trans_refl'`? | In tree? |
|---|---|---|---|
| trans-congruence (`tUntl_trans_congr`) | `S.trans t i j → (untl g e ∈ L i t ↔ untl g e ∈ L j t)` | yes (`(h j t)` read at `j` with itself) | **no** |
| trans-congruence, `snce` | `S.trans (t-1) k i → (snce g e ∈ L i t ↔ snce g e ∈ L k t)` | yes | **no** |
| common-successor label congruence (`tUntl_common_succ_congr`) | `S.trans t i j → S.trans t i' j → (untl g e ∈ L i t ↔ untl g e ∈ L i' t)` | no | **no** |
| common-predecessor label congruence | `S.trans (t-1) k i → S.trans (t-1) k i' → (snce ∈ L i t ↔ snce ∈ L i' t)` | no | **no** |
| common-source unfolding congruence (landed `untl_succ_congr`) | `S.trans t i j → S.trans t i j' → (unfold at (j,t+1) ↔ unfold at (j',t+1))` | no | Formula side only, `Sharing/Agreement.lean` |
| common-target unfolding congruence (landed `snce_pred_congr`) | `S.trans (t-1) k i → S.trans (t-1) k' i → (unfold at (k,t-1) ↔ unfold at (k',t-1))` | no | Formula side only |

The task description's "(the common-successor / common-predecessor congruences ... already machine-checked as `tUntl_common_succ_congr`)" and the landed names refer to **different statements**. `scripts/check-module-invariants.sh` line ~1022 and `Incompleteness.lean`'s header both cite the landed pair as "how much agreement the clauses still force", which is accurate for the unfolding level but silent about the label level — the level at which reflexivity bites. The Plus side records no residual agreement at all.

**F2. Consumers that need the self-step (not merely a thread through the position).**

1. *Deterministic reductions* — `localCoherentLab_of_share`, `untl_self_of_share`, `snce_self_of_share` (`Sharing/Predicates.lean`) and `plusLocalCoherentLab_of_share`, `plusUntl_self_of_share`, `plusSnce_self_of_share` (`PlusWitnessFamily/Predicates.lean`) instantiate the (C1') quantifiers at `S.trans_refl' t i`; `fulfillingLab_of_thread` / `plusFulfillingLab_of_thread` instantiate (C2') at `Thread.const S i` and need the conclusion on the **same** index `i` (a non-constant thread yields `e ∈ L (θ.idx s) s`, a different index). Consumers: `Specialize.lean:157` and `:201`, the biconditionals `localCoherentShare_toSharing` and `threadFulfilling_toSharing` that exhibit the deterministic device as the diagonal instance. `TransId.lean` cites both as the converses of its `hid`-conditional theorems. The four `*_self_of_share` lemmas have no consumers beyond their docstrings.
2. *Walk-to-thread extension* — `FwdWalk.walkIdx` / `BwdWalk.walkIdx` are explicit functions, constant off the walk, and `walkIdx_step` discharges the off-walk step by `rw`'s closing `rfl` against the `@[refl]` `trans_refl'` (`Sharing/Fulfil.lean` 844, 935; `Sharing/Window.lean` 615, 705). Bi-infinite threads built from finite window walks are what connect the fixpoint computation to (C2').
3. *Decidable checker* — `succF_nonempty` / `predF_nonempty` (`Window.lean` 340-353) and the default escape edge `(z.1, nextTime z.2) ∈ succF z` inside `window_of_threadFulfilling` (`Sharing/Fulfil.lean` 490, 498, 1439, 1539; `PlusWitnessFamily/Fulfil.lean` 802, 902) all go through `transRaw_refl` + `share_refl`. The position graph has a self-loop at every vertex by construction.
4. *Landed incompleteness theorems* — `Limits/NoCertificate.lean` 190, 209 and `Limits/HopFree.lean` 141, 194 read `huntl j u j (S.trans_refl' u j)` to turn `Xp ∈ L j u` into `p ∈ L j (u+1)`. (Under a bi-serial replacement this step would instead pick a successor `j'` and transport `p` back to `j` across `share (u+1) j j'` by (C0) — expected to work, not verified.)
5. *Nonemptiness* — `instNonemptyThread` at three sites, via `Thread.const K ⟨0, K.n_pos⟩`.

**F3. Consumers that would accept the existential.** `truth_iff_mem`'s `box` case and `plusTruth_iff_mem`'s `box`/`stab` cases (`Agreement.lean` both sides), `stabQuant_iff_share_class` (`Stability.lean`), `truth_main_iff_mem` / `not_consequence_ztime` / `joint_countermodel` (both sides) use `Thread.const S j` only to obtain a thread with `idx u = j` at a chosen offset; any thread through `(j, u)` would do, though `truth_main_iff_mem`'s statement names the constant thread and would have to be restated existentially.

**F4. Producers.** Every landed producer supplies `trans_refl` from one of two reflexive bundles: `transFullOf_refl` (`Specialize.lean`, `Sharing/Fulfil.lean`, `PlusWitnessFamily/Fulfil.lean`, `Decide.lean`, `Examples.lean` `stabFamily`) or `transIdOf_refl` (`Examples.lean` `famA`, `famB`). No landed family has a non-diagonal, non-full succession matrix, so **no landed family exhibits the residual non-vacuously** — which is consistent with task 696's gate observation and is itself a non-vacuity gap sibling task 704 may wish to note.

**F5. The sliced class is structurally free of the residual.** `PlusSlicedCertificate` fields: `n, n_pos, back, mid, fwd, back_ne, fwd_ne, bx, target, targetTime`; `PlusSlice` fields: `edge : Fin n → Fin n → Bool`, `lab`, `lab_sub`. `BiSerialAt` demands an out-edge and an in-edge per state; no reflexivity is demanded or derived anywhere in the subtree (the only `*_refl` lemmas there are `foldF_refl` / `foldB_refl` on time folding). `LabRun` carries `steps : G.edge s (st s) (st (s+1)) = true` and `coherent : PlusLocalCoherentSeqLab Γ Del G.bx lab`, so the `untl` clause relates `lab t` to `lab (t+1)` along one run. `Canon.lean` makes a fulfilling run's labelling a function of its state path. The sliced files reference the sharing substrate only in docstrings (transcription provenance of `verts`/`succF`/`predF`) and through the shared export `PlusWitnessFamily.PlusRefutes`, which is defined outside the sharing modules.

**F6. The sharing substrate is not on the main decidability path.** `DecisionProcedure.lean`, `Correctness.lean`, `CountermodelExtraction.lean`, `TraceCertificate.lean`, `Verified/` do not reference `Sharing*`; only the `WitnessFamily.lean` umbrella and the `PlusWitnessFamily` modules import it. (Task 703 plan 06's remark that `SharingSkeleton` is a module "on which the whole L-side decision procedure rests" overstates this; it is a second `Refutes` producer.) No test file references it.

**F7. Semantic status of the residual within the class.** `Thread.const K j` is a thread, so `K.hist (Thread.const K j) s` is a world history of the presented frame. Hence `untl g e ∈ L j t` is the truth of `A[g U e]` along the constant history through `(j, t)`, and `untl g e ∈ L i t` with `trans t i j` is its truth along a history that reaches `(j, t+1)`; both equal the unfolding at `(j, t+1)`. Within the class's own frames the trans-congruence is therefore a truth-level fact, not an unsound constraint. Its cost is expressivity: countermodels in which lane `j` does **not** self-continue at `t` are outside the class. That exclusion is already the content of `not_exists_hopFree_plusCertifies_hopTarget` / `not_exists_plusCertifies_pumpTarget`, which is why removing reflexivity cannot repair completeness of this class.

### Mathlib Theorems

Not applicable: the audit concerns this repository's own substrate. `lean_local_search "trans_refl"` returned `index: unavailable` (no language server running) and only Mathlib `Equiv.trans_refl`-style name collisions; it neither confirms nor denies project declarations, so the grep sweep in the Appendix is the evidence of record. No `lean_leansearch` / `lean_loogle` query was run, by design.

### Context File Review

- `context/project/logic/README.md` (index) — loaded. The domain files on Kripke semantics and proof strategies were not needed: the question is certificate-class design, not a modal proof.
- `context/formats/return-metadata-file.md` — loaded for the metadata contract.
- `context/contracts/territory.md` (Cross-Task Territory) — loaded. Sibling 704 declares `scripts/check-module-invariants.sh`; this task must not edit that file this cycle (see Risks).

### External Resources

None, per the dispatch's LITERATURE note. The `<literature-briefing>` entries (Burgess 1982, Gabbay–Hodkinson–Reynolds 1993, etc.) are context for the since/until clauses, not evidence on whether a Lean field should be removed.

### Recommendations

**R1 — Retain `trans_refl`.** Record the retention as a decision with the rationale in F2/F5/F7: the field is consumed structurally by the checker and the walk extension, the residual it induces is bounded (`clause_shape_collapse` and nothing more) and dominated by the landed class-level incompleteness, and the class whose completeness the programme pursues has no such field.

**R2 — Land the label-level record in `PlusWitnessFamily/Incompleteness.lean`** (this task's `file_scope`), in a new section "The residual the succession substrate still carries":

- `untl_trans_congr` : `S.PlusLocalCoherentShare → S.trans t i j → (untl g e ∈ S.L i t ↔ untl g e ∈ S.L j t)` — proof `((h i t).2.2.2.1 j hij g e hc).trans ((h j t).2.2.2.1 j (S.trans_refl' t j) g e hc).symm`.
- `snce_trans_congr` : `S.trans (t-1) k i → (snce g e ∈ S.L i t ↔ snce g e ∈ S.L k t)` — mirror with `(S.trans_refl' (t-1) k)`.
- `untl_common_succ_congr` : `S.trans t i j → S.trans t i' j → (untl g e ∈ S.L i t ↔ untl g e ∈ S.L i' t)` — reflexivity-free; `((h i t).2.2.2.1 j hij g e hc).trans ((h i' t).2.2.2.1 j hi'j g e hc).symm`.
- `snce_common_pred_congr` : `S.trans (t-1) k i → S.trans (t-1) k i' → (snce g e ∈ S.L i t ↔ snce g e ∈ S.L i' t)`.

The docstring should state: (i) the first two are `clause_shape_collapse` at `R := S.trans t` and are forced by `trans_refl` alone; (ii) the last two are what survives without reflexivity, and are the exact residual (699 probe, `tUntl_common_succ_congr`); (iii) both are vacuous on every landed producer (`transFullOf`, `transIdOf`), F4; (iv) within the class's own frames they are truth-level facts, F7; (v) the sliced class carries no analogue because it carries no `trans`, F5; (vi) they are strictly weaker than the landed `not_exists_plusCertifies_pumpTarget` and are recorded so the relocation from `share`-classes to `trans`-classes is seen to be deliberate and bounded. Names deliberately avoid the landed `untl_succ_congr` / `snce_pred_congr`, which state the unfolding-level agreement; the docstring should cross-reference them and the shape difference in F1.

**R3 — Doc surfaces.** Add four rows to `docs/theorem-index.md` next to rows 160/163 (the two refuted-congruence rows); add one paragraph to `Sharing/README.md` after "A position is a history type..." (around line 252) and one to `PlusWitnessFamily/README.md` after "Five declarations recorded that..." naming the four new declarations and the name-collision caveat. Optionally mirror the four theorems on the Formula side in `Sharing/Agreement.lean` beside the landed pair; this is cheap and keeps the two sides symmetric but is not required.

**R4 — Baseline rows.** The theorem-index `Axioms` column is generated from `scripts/check-module-invariants.sh` C2 baselines, so the four rows need C2 entries. That script is sibling task 704's declared territory this cycle; the plan should sequence the C2 rows after 704 lands (or hand the four names to 704), and must not edit the script concurrently.

**R5 — Do not file a removal task.** If a future producer ever needs non-self-continuing lanes on the sharing class, the Appendix's migration sketch is the starting point; the recommendation is that such a producer target `PlusSlicedCertificate` instead.

**Proposed `file_scope` for the implement phase**: `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`, `docs/theorem-index.md`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`, `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`; optionally `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean`; `scripts/check-module-invariants.sh` only after 704 completes.

## Decisions

- **D1**: The audit's unit of analysis is "does the site need `trans u i i` / a constant thread, or only some thread through the position?" — not the raw count of `Thread.const` occurrences. Categories F2.1-F2.5 need the former.
- **D2**: Relevance is judged against the landed `PlusSlicedCertificate`, per the dispatch, and against the landed `Limits/` theorems rather than against a hypothetical hopping producer.
- **D3**: Scope item (4) is declined on the merits (strictly weaker than a landed theorem), not deferred.
- **D4**: No web or literature search was performed, per the dispatch's explicit instruction.
- **D5**: `user_decision` is not set: the retain-and-record recommendation is inferable from the artifacts and carries no external cost.

## Risks & Mitigations

- **R-a. Name collision.** The task text and the landed tree use `untl_succ_congr` / `snce_pred_congr` for different statements. Mitigation: R2's names (`*_trans_congr`, `*_common_succ_congr` / `*_common_pred_congr`) and an explicit cross-reference in the docstring.
- **R-b. Territory.** `scripts/check-module-invariants.sh` belongs to sibling 704 this cycle. Mitigation: R4 sequencing; the implement phase re-reads the file immediately before any edit.
- **R-c. `#print axioms` pin.** New theorems in `Incompleteness.lean` are expected to be `pcq`; C2 will assert whatever the baseline records, so the baseline must be read off the build, not typed.
- **R-d. The incompleteness proofs' reflexive reads.** Not a risk under R1; recorded only so a future removal attempt knows F2.4 needs the (C0) transport.
- **R-e. Lookup-tool limitation.** The local declaration index was unavailable during this research; the grep sweep below is the evidence, and the implement phase should confirm the absence of `*_trans_congr` with a fresh `lean_local_search` once a server is up.

## Appendix

### Search queries used

- `grep -rn "trans_refl" --include=*.lean` (49 hits incl. 703 probes), `grep -rn "Thread\.const"`, `grep -rn "transRaw_refl\|succF_nonempty\|predF_nonempty"`, `grep -rn "instNonemptyThread\|Classical"` under the two sharing trees, `grep -rn "SharingSkeleton\|trans_refl\|\.trans " PlusSlicedCertificate/`, `grep -rln "Sharing" DecisionProcedure.lean Correctness.lean ...`, `grep -rn "trans_congr\|untl_trans_\|snce_trans_"` (no hits), `grep -n "refl"` across `PlusSlicedCertificate/*.lean`.
- `lean_local_search "trans_refl"` — `index: unavailable`.

### Term-level site tally (comment lines excluded, approximate)

| File | Sites |
|---|---|
| PlusWitnessFamily/Agreement.lean | 10 |
| WitnessFamily/Sharing/Skeleton.lean | 9 |
| PlusWitnessFamily/Basic.lean | 9 |
| WitnessFamily/Sharing/Agreement.lean | 8 |
| WitnessFamily/Sharing/Fulfil.lean | 7 |
| WitnessFamily/Sharing/Basic.lean | 6 |
| PlusWitnessFamily/Predicates.lean | 6 |
| WitnessFamily/Sharing/Stability.lean | 5 |
| WitnessFamily/Sharing/Predicates.lean | 5 |
| WitnessFamily/Sharing/Window.lean | 4 |
| WitnessFamily/Sharing/Thread.lean | 4 |
| PlusWitnessFamily/Fulfil.lean | 3 |
| PlusWitnessFamily/Examples.lean | 3 |
| PlusWitnessFamily/TransId.lean | 2 |
| PlusWitnessFamily/Limits/NoCertificate.lean | 2 |
| PlusWitnessFamily/Limits/HopFree.lean | 2 |
| WitnessFamily/Sharing/Specialize.lean | 1 |
| PlusWitnessFamily/Decide.lean | 1 |
| **Total** | **~87 across 18 files**, plus 3 uncompiled probes under `specs/703_*/probes/` |

### Migration sketch, recorded only (not recommended)

Replacement field: bi-seriality of arrival-pruned succession, stated raw over all six lists in the `LiftableRaw` style (`∀ u i, ∃ j, transRaw u i j = true ∧ share (u+1) i j` and its predecessor mirror), with a window-decided twin modelled on the sliced class's `biSerial_iff_window`. Substitution lemma: `exists_thread_through : ∀ i u, ∃ θ : K.Thread, θ.idx u = i`, by dependent choice in both directions (noncomputable). Then: F3 sites rewrite mechanically; F2.1 reductions become `hid`-conditional (as `TransId.lean` already does) or are proved directly at `toSharing` from `transFullOf`; F2.2 walk extensions splice with chosen threads (and `toThread` becomes noncomputable; `walkIdx_le` / `walkIdx_ge` consumers must be re-checked); F2.3 nonemptiness from the window-level bi-seriality; F2.4 via (C0) transport; F2.5 from `n_pos` plus the new lemma; six producers add a bi-seriality proof; `docs/theorem-index.md`, two READMEs and the C2 baseline follow. Estimate 3-5 implementation dispatches with no completeness gain.

### References

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — `SharingSkeleton`, `trans`, `trans_refl'`, `Thread.const`, `hist`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/{Predicates,Agreement,Fulfil,Window,Specialize,Stability}.lean`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Basic,Predicates,Agreement,Fulfil,TransId,Incompleteness}.lean`, `Limits/{NoCertificate,HopFree}.lean`
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/{Basic,Live,Check,Complete}.lean`
- `specs/archive/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean`
- `specs/696_stability_modal_substrate_design/reports/01_stability-modal-substrate-design.md` (Q3 record request), `summaries/02_trans-arrival-substrate-refactor-summary.md`
- `specs/703_lplus_compression_and_completeness/plans/06_lplus-sliced-certificate-and-completeness.md` (the `trans_refl` follow-on paragraphs)
- `docs/theorem-index.md` rows 160-167; `scripts/check-module-invariants.sh` C2 comment block (~line 1015)
