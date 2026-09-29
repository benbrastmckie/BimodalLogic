# Research Report: Task #700

**Task**: 700 - lplus_completeness_programme_survey
**Started**: 2026-09-28T21:32:00Z
**Completed**: 2026-09-28T22:25:00Z
**Effort**: ~1 hour survey. Programme estimate below: 2 landed-task cycles already in flight, 1 large new task (research-first), 1 small new gate task.
**Dependencies**: None. This task is blocked on nothing and blocks task 696 (`696.dependencies = [700]`).
**Sources/Inputs**: - Live tree (`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Incompleteness,Predicates,README}.lean`, `WitnessFamily/Compression/{Family,Assembly,README}.lean`, `WitnessFamily/Sharing/{README,Basic}.lean`, `PlusLanguage/PlusTruth.lean`, `Semantics/{TaskModel,IntTransfer}.lean`, `FormalSystem.lean`, `scripts/check-module-invariants.sh` C2 block, `docs/theorem-index.md`), task 696's two landed reports, `specs/state.json` here and in the paired repository, `specs/literature-index.json`, one WebSearch on Ockhamist decidability
**Artifacts**: - `specs/700_lplus_completeness_programme_survey/reports/01_lplus-completeness-programme-survey.md` (this report)
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal:logic

## Executive Summary

- **Soundness is not in question anywhere in this programme.** `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies` are landed, sorry-free, axiom-pinned in the C2 baseline, and nothing proposed here touches their statements. Every gap named below is a completeness-side gap: the certificate class is *empty* on a fragment, never *unsound* on it. A reader who takes any finding here as evidence of unsoundness has misread it.

- **The carrier normalization must go FIRST, and this is now settled by the code rather than by argument.** `WitnessFamily/Compression/Family.lean:165` opens the proof of `exists_witnessFamily_of_not_validZTime` with `rw [validZTime_iff_validInt]` — Step 0 of the compression theorem itself, not merely of the decision-procedure entry point. The L⁺ twin therefore cannot be *stated and proved* at all without task 695's `plusValidZTime_iff_plusValidInt`. 695 is a hard prerequisite of the target theorem, not an independently useful convenience.

- **No L⁺ compression subtree should be built before the condition set is corrected, and there is no such task today.** `...not_plusCertifies_stabSnce` makes the L⁺ twin **false** against the landed six conditions, and task 696's report F7 records that `snce_share_congr`, `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise` must be *deleted or negated* by the repair. A compression subtree written now would be built on lemmas scheduled for deletion. `PlusWitnessFamily/` has no `Compression/` subdirectory and no `decidablePlusValidZTime`; the entire compression half of the L⁺ route is unowned. **This is the single largest gap in the programme and it is the one new task this survey proposes.**

- **Task 699 Part B should NOT gate task 696's implementation.** 696 round 2 already machine-checked, by construction, two six-condition certificates (`famA_tCertifies`, `famB_tCertifies`) on exactly the two target classes the landed conditions left empty, plus `total_eq_tthread_of_liftable` and `stabFamily_not_liftable`. A literature expressiveness bound cannot invalidate a construction that already elaborates. What such a bound *could* constrain is the compression/completeness theorem, so the gating edge is 699-Part-B → the new compression task, advisory. 699 **Part A** is a different matter: it sweeps `PlusBoxFaithful`'s globality and the Formula-side mirrors, which 696's redesign does not touch, so 696 should read Part A's audit table before its (C1')-rewrite phase. Both tasks are in research this same cycle, so honoring that is nearly free.

- **The general-consequence obligation is parallel to the critical path, not on it.** The target named in this task's own description is the L⁺ twin of `exists_witnessFamily_of_not_validZTime`, which is itself the `Γ = []`, single-conclusion instance. Premise generality is an orthogonal axis. Propose nothing; add one extension-point sentence to 695's plan (below) so the consequence-form analogue costs less later.

- **Reachable, with three unowned formal obligations and one open literature question.** Nothing in the tree or the corpus predicts unreachability, and the repository sits in the literature's *decidable* case (state-indexed valuation ⇒ instant-based atoms). But three of the target theorem's proof obligations (O1 `Liftable` decidability, O2 liftable-`trans` construction from an arbitrary countermodel, O3 (C5)'s time-indexed witness demand) have no owner today, and O3 in particular may move the lasso-count bound. Details in **Reachability**.

- **Task 696's declared file_scope understates its real footprint by nine files.** Its own round-2 report F6 names edits in `Sharing/{Thread,Frame,Histories,Basic,Window}.lean`, `PlusWitnessFamily/{Basic,Examples,Incompleteness}.lean` and `FormalSystem.lean`, none of which appears in its 14 declared paths. Concurrency planning that trusts the declared scope will collide.

## Context & Scope

This task is a survey and a sequence, not work. It reads each programme item's status from the live tree, places it in a dependency graph, recommends an order, identifies file-territory collisions in advance, judges reachability, and names the cross-repository hand-off by fully-qualified declaration name. It writes no Lean, touches no other task's territory, and proposes the minimum number of new task entries its own conclusions justify — two.

**A concurrency caveat on two of the six survey items.** Tasks 695 and 699 are dispatched for research in this same `/orchestrate` cycle and their `reports/` directories are empty as of this writing. Their status below is read from the live tree plus their `specs/state.json` descriptions, never from reports that do not yet exist. When those two reports land, edges E2, E5 and E8 below should be re-checked against them; nothing else in this graph depends on their content.

Not restated here, by constraint: task 696's two reports, and `PlusWitnessFamily/Incompleteness.lean`. Both are cited by declaration name only.

## Findings

### Codebase Patterns

**F1. The obstruction, cited not restated.** Four landed declarations, all in `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`, all axiom-pinned in `scripts/check-module-invariants.sh`'s C2 `AXIOM_BASELINE` (lines 1022-1025) and rowed in `docs/theorem-index.md`:

- `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.snce_share_congr`
- `...not_plusCertifies_stabSnce`
- `...not_plusCertifies_stabSnce_premise`
- `...not_plusValidZTime_stabSnce`

Soundness counterparts, also C2-pinned and untouched by anything proposed here: `...plusTruth_iff_mem`, `...plusRefutes_of_certifies`, `FormalSystem.Metalogic.Decidability.SharingSkeleton.total_eq_thread`, `...stabFaithful_share_congr`, `...stabFamily_separates`, `...stabFaithful_diagonal`.

**F2. The carrier normalization is inside the compression theorem.** `WitnessFamily/Compression/Family.lean:139` ("`validZTime_iff_validInt` normalises the countermodel's carrier to ℤ. This is compression …") and `:165` (`rw [validZTime_iff_validInt] at h`). The only other consumer is `Compression/Assembly.lean:66` (the entry point). `FormalSystem.Semantics.plusValidZTime_iff_plusValidInt` does not exist; `grep` finds the name only in task 695's description. `FormalSystem.PlusLanguage.PlusValidZTime` is defined at `PlusLanguage/PlusValidity.lean:111`; there is no `PlusValidInt`. **Consequence: the L⁺ twin of `exists_witnessFamily_of_not_validZTime` has no provable Step 0 until 695 lands.**

**F3. The L⁺ compression half does not exist.** `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` contains `Basic`, `Predicates`, `Decide`, `Fulfil`, `Agreement`, `Examples`, `Closure`, `Incompleteness`, `README` — and no `Compression/`. `grep` for `decidablePlusValidZTime`, `PlusCompression`, `plusValidZTime_iff` over the library returns nothing. The Formula side's counterpart is five modules (`Compression/{Types,Extract,Cycle,Fulfil,Enumerate,Family,Assembly}.lean`, 7 files). So the missing work is not a lemma; it is a subtree comparable in size to `Compression/`.

**F4. (C5) is the completeness-critical condition nobody has costed.** `PlusWitnessFamily/Predicates.lean:277-280`:

```
StabFaithful S : ∀ i u φ, stab φ ∈ plusClosureOf (Γ ++ Del) →
  (stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
```

The `←` direction is what soundness consumes and it is cheap. The `→` direction is what *completeness* must supply, and it is strictly stronger than (C3)'s box clause. `PlusBoxFaithful` (`:196-198`) is global — `bx χ = true ↔ ∀ i t, χ ∈ W.L i t` — so a `□χ` witness lasso may carry its failing position at *any* time, which is why `Compression/Family.lean` bounds the lasso count by `(closureOf ([] ++ [φ])).card + 1` (one witness lasso per failing boxed member). (C5) instead demands, for each `u` and each `⊡φ ∉ S.L i u`, a class-mate index **at that same time `u`** missing `φ`. Semantically the witness exists: `PlusTruth.lean`'s `stab` clause (`| .stab φ => ∀ σ, τ.state t = σ.state t → PlusTruthAt M σ t φ`) gives a history `σ` agreeing with `τ` at `t`. But compression must place that witness into a *finite periodic* family at the right time, and the natural bound is no longer `|closure| + 1` — it is plausibly `|closure| ×` (window size), or else a per-time witness scheme with a sharper argument. **No landed report, README or task description records this obligation.** It is obligation O3 below.

**F5. `Liftable` is a Π-statement over all `Step`-paths.** Task 696's recommended design makes `Liftable` a skeleton field, in the shape its round-2 probe verified:

```
∀ σ : ℤ → Fin n, (∀ u, Step u (σ u) (σ (u+1))) → ∃ θ : TThread trans, ∀ u, share u (σ u) (θ.idx u)
```

`total_eq_tthread_of_liftable` shows this suffices for the histories characterization, and `stabFamily_not_liftable` shows it is not free. Two things follow that 696's reports do not claim and do not need to: nothing establishes that `Liftable` is **decidable**, and the decision procedure (the Assembly analogue) must decide it for every enumerated candidate. Because `trans` and `share` are periodic on a finite index set, a finite-graph simulation argument is the obvious route, but it is unscoped. Obligation O1 below. Note this is a *decision-procedure* obligation, not a soundness one — a family carrying a `lift` proof is sound whether or not `Liftable` is decidable.

**F6. 696's two lifts are the easy case.** Round 2's `famA_liftable` and `famB_liftable` both go through a constant thread, explicitly with no pigeonhole. Compression from an *arbitrary* ℤ-time countermodel must construct a `trans` that is simultaneously arrival-pruned, liftable, and bounded — and the liftability of a compressed `trans` is exactly the general case the two gate families sidestep. Obligation O2 below.

**F7. Task 696's declared territory is nine files short.** Declared (14): `PlusWitnessFamily/{Agreement,Decide,Fulfil,Predicates,README}`, `Sharing/{Agreement,Decide,Fulfil,Predicates,README,Skeleton,Specialize}`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`. Named as requiring edits by 696's own round-2 F6 but **not** declared:

| File | Why it must change |
|------|--------------------|
| `WitnessFamily/Sharing/Thread.lean` | `Thread.step` (94-95), `step_of_share_succ`, `step_congr_right` restated at `trans` |
| `WitnessFamily/Sharing/Frame.lean` | delegation restatement |
| `WitnessFamily/Sharing/Histories.lean` | delegation restatement |
| `WitnessFamily/Sharing/Basic.lean` | `skeleton` projection (~101) must populate the three new `trans` lists and `lift` |
| `WitnessFamily/Sharing/Window.lean` | `succF`/`predF` (277-282), both `share_succ`, both `walkIdx_step`, the two `_nonempty` lemmas |
| `PlusWitnessFamily/Basic.lean` | `Thread.step`, `Thread.const`, `skeleton` projection (~248) |
| `PlusWitnessFamily/Examples.lean` | `stabFamily` gains the new fields; `famA`/`famB` land here |
| `PlusWitnessFamily/Incompleteness.lean` | its three certificate-side declarations become unprovable and must be deleted or negated |
| `FormalSystem.lean` | line 153 imports `...PlusWitnessFamily.Incompleteness`; changes with that module's fate |

This is a finding for concurrency planning, not a criticism of 696's design: the design is sound and the reports are explicit about the surface. It is the *declaration* that is stale.

**F8. The paired repository, read from its own `specs/state.json`.** Four items named in this task's scope, plus one more that matters:

| # | project_name | status | What it actually waits on |
|---|--------------|--------|---------------------------|
| 200 | `extend_bimodal_to_stability_modal` | blocked | Its own description names four needs: "a state-sharing witness structure, its histories characterization, its redesigned box condition, and a compression bound". The first three are task 696. **The fourth is the new compression task.** So 200 stays blocked past 696. |
| 216 | `apply_upstream_adequacy_chain_rows` | not_started | Nothing further from here. Consumes only landed declarations. |
| 217 | `rescope_blocked_adequacy_consumers` | not_started | Nothing further from here. Its own description already carries the corrected shape-form mechanism. |
| 219 | `bimodal_theory_limits_example_group` | not_started | Nothing further from here. Consumes the four `Incompleteness.lean` declarations, which are landed. |
| 198 | `a3_compute_bounds_from_closure` | blocked | Its `back`/`fwd` clause needs a *minimal-period* result, which the landed theorem does not give (it bounds segment lengths). Not an L⁺ question at all; orthogonal to this programme. |

**216, 217 and 219 are therefore unblocked now** — their blockers are documentation accuracy, not dependency. That is worth saying plainly in the hand-off note, because a reader sequencing "wait for upstream" on all five would idle three of them.

### Mathlib and Tool Lookups

No Mathlib lookup was needed for this survey: it is a sequencing question over landed declarations, not a search for a lemma. Task 696's round-1 report already located the two Mathlib candidates its design might have needed (`IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed`, `Finite.exists_infinite_fiber`) and round 2 records that neither gate family requires them. The new compression task's research round will need Mathlib lookups for the O2 pigeonhole; they are not pre-empted here.

### Context File Review

- `.claude/context/project/logic/README.md` — loaded first per this agent's contract. Terminology: "sentence letter", observed below.
- `.claude/context/project/logic/domain/metalogic-concepts.md`, `.../kripke-semantics-overview.md` — the soundness/completeness asymmetry this report turns on is the standard one; no repository-specific convention needed restating.

### External Resources

- **WebSearch, Ockhamist decidability.** The decisive point: *Ockhamist validity is decidable under the assumption of instant-based atomic propositions; the decidability of Ockhamist validity with history-dependent atomic propositions is not known.* `FormalSystem/Semantics/TaskModel.lean:60` gives `valuation : F.WorldState → Atom → Prop` — **state-indexed, hence instant-based**. The repository sits in the decidable case, not the open one. ([Goranko & Zanardo, *An Extended Branching-Time Ockhamist Temporal Logic*](https://www2.philosophy.su.se/goranko/papers/JoLLI-An%20Extended%20Branching-Time%20Ockhamist%20Temporal%20Logic.pdf); [SEP, *Temporal Logic*](https://plato.stanford.edu/entries/logic-temporal/))
- **The repository's object semantics is already Ockhamist; only the certificate was not.** `PlusTruth.lean:84-93` evaluates at `(τ, t)` — a history-time pair. The defect was that the certificate evaluated tense at a `share`-class (a moment) rather than at a position (a moment-history *type*). 696 round 2's F5 states the positive side of this independently ("a position's label is the truth set of every history through it, so a position is a history type"). This is corroboration for task 699 Part B's hypothesis, recorded as such; **Part B owns the verdict and this survey does not pre-empt it.**
- **In-corpus sources 699 Part B should reach for, already indexed** (`specs/literature-index.json`): `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics` (products/fusions, negative results for an S5 factor with a linear factor — the reference point for O4); Thomason, *Indeterminist Time and Truth-Value Gaps* (1970) and *Combinations of Tense and Modality*; Reynolds 2001 (CTL\*), 2002 (*Axioms for Branching Time*: bundled vs full validity, limit closure, open problems), 2003 (Prior's Ockhamist logic); Emerson & Halpern 1986 (R-generable path sets, bundled vs limit-closed); Burgess 1982 I & II; `rumberg-zanardo-2019-transition-structures`. None of these needs to be located from scratch.

### Recommendations

#### The dependency graph

```
                 A = 695  plus_carrier_normalization_int_transfer   [researching, unblocked]
                 B = 699  invariance_clause_audit (Part A)          [researching, unblocked]
                 B'= 699  Ockhamist grounding (Part B)              [researching, unblocked]
                 C = 696  stability_modal_substrate_design          [researched, deps=[700]]
                 D = NEW  lplus_compression_and_completeness        [proposed]
                 F = NEW  certificate_non_vacuity_and_shape_gates   [proposed]
                 G = 701  port_substrate_lessons_to_model_checker   [not_started, deps=[696]]
                 E = general finite-premise consequence             [unowned, PARALLEL — propose nothing]

   A ─────────────────────── E1 (HARD) ──────────────────────────► D
   B ──── E2 (SOFT gate) ──► C ───── E3 (HARD) ──────────────────► D
   B' ─── E8 (ADVISORY) ───────────────────────────────────────► D
   C ──── E4 ─────────────► G ──── E6 ──► [paired repo #200]
   D ──── E5 (HARD) ────────────────────► [paired repo #200]
   C ──── E7 ─────────────► F
   D ──── E7' ────────────► F
```

Every edge, justified:

| Edge | From → To | Strength | Justification |
|------|-----------|----------|---------------|
| E1 | A → D | **HARD** | `Compression/Family.lean:165` is `rw [validZTime_iff_validInt]`, Step 0 of the Formula-side theorem. D's statement has no provable Step 0 without `plusValidZTime_iff_plusValidInt`. Not an argument from analogy — the line is in the tree. |
| E2 | B → C | **SOFT gate** | 699 Part A sweeps `PlusBoxFaithful`'s globality (`Predicates.lean:196-198`) and the Formula-side mirrors, neither of which C's redesign touches. If Part A finds a collapse C does not repair, C's (C1')-rewrite phase is the cheapest place to absorb it. C should read Part A's table before that phase; it need not wait to *start*. |
| E3 | C → D | **HARD** | `...not_plusCertifies_stabSnce` makes D's conclusion **false** against the landed conditions. D written now would prove nothing, and would rest on three lemmas C schedules for deletion (696 F7). |
| E4 | C → G | existing | Already recorded as `701.dependencies = [696]`. Unchanged. |
| E5 | D → paired #200 | **HARD** | #200's own description requires "a compression bound" as the fourth of four needs. C supplies three; only D supplies the fourth. |
| E6 | G → paired #200 | advisory | G is the hand-off note; #200's blocker restatement wants it, but #200 is gated by E5 regardless. |
| E7 / E7' | C → F, D → F | **HARD** | F's non-vacuity obligation must be stated against the *final* condition set, and F's clause-shape check must not fire on clauses C is about to delete. A gate landed earlier goes red on the very refactor it exists to protect. |
| E8 | B' → D | **ADVISORY, not gating** | A literature expressiveness bound cannot invalidate `famA_tCertifies`/`famB_tCertifies`, which already elaborate — so B' cannot gate C. It *can* bound what a finite periodic certificate over moment-history pairs decides, which is a D question. D's research round should read B''s verdict; D's start need not wait. |

**No edge B' → C.** This survey was asked to assess whether Part B should gate the substrate implementation and concludes it should not, for the reason in E8: the construction is already machine-checked and a bound on the *decision* problem is not a bound on the *certificate*.

**E is deliberately not in the graph as a node with edges.** The general finite-premise consequence form is parallel. Rationale: the target theorem named in this task's description is the L⁺ twin of `exists_witnessFamily_of_not_validZTime`, itself the `Γ = []`, single-conclusion instance, so D is complete without E. `Compression/README.md:114-129` and `Assembly.lean:55-73` already enumerate the three `Γ = []`-specific residue items and state that the general form "is not known to compile" — a present, accurate scope fact, recorded and owned. The paired repository's #216 and #217 already carry it as an open upstream obligation in their own scope. Adding a task for it now would put a second axis (premise generality) on the critical path of the first (language), and the Formula side is the cheaper place to open it. **Propose nothing.** One cheap coordination action instead, below.

#### Recommended execution order

| Wave | Items | Concurrency | Serialization constraint |
|------|-------|-------------|--------------------------|
| **0** (in flight now) | A research (695), B/B' research (699) | **concurrent, safe** | 695 touches `Semantics/*` + the two shared gates; 699 writes only its own `specs/` dir and `probes/`. No overlap. |
| **1** | A plan + implement (695) | **serial vs C** | Both A and C write `docs/theorem-index.md` and `scripts/check-module-invariants.sh`. A is much smaller; land it first and C rebases. |
| **1** | B/B' plan + implement (699) | **concurrent with A** | 699's deliverable is a report plus probes under its own dir; it writes no Lean and no shared gate. |
| **2** | C plan + implement (696), phases 0-5 per its own reports | **alone** | C's real footprint is 23 files (14 declared + F7's 9), including the substrate core. Nothing else should touch `WitnessFamily/` or `PlusWitnessFamily/` while C runs. Read B's Part A table before C's (C1')-rewrite phase. |
| **3** | **D (new)** — research round first, then plan, then phased implement | **alone** | D creates `PlusWitnessFamily/Compression/` and edits `PlusWitnessFamily.lean`, `FormalSystem.lean`, plus both shared gates. |
| **4** | **F (new)** — the two structural preventions, one task | **concurrent with G** | F touches `scripts/check-module-invariants.sh` only (plus its own docs). G touches nothing in this repository's Lean. |
| **4** | G (701) | **concurrent with F** | G is a hand-off note to the paired repository. |

**Serialization is driven by two files, and this is the concrete concurrency hazard.** `scripts/check-module-invariants.sh` is written by A, C, F. `docs/theorem-index.md` is written by A, C, D. Both are single-file, whole-file-rewrite-prone artifacts (the C2 `AXIOM_BASELINE` heredoc at lines 1012-1027 is edited as a block). Two tasks editing the C2 baseline concurrently will produce a gate that is red for both and diagnosable for neither. **Recommendation: never dispatch two of {A, C, D, F} implementing in the same cycle.** Tasks 697 and 698 are safe alongside any of them (697: `scripts/typst-*` + `typst/generated/`; 698: `specs/state.json`).

A second, softer hazard: 696's round-2 F6 counts the `share`-as-succession idiom at 36 lines across 9 files, and its 23-file real footprint spans both the `Formula` and `PlusFormula` sides of the substrate. Splitting C across parallel dispatches with territory contracts is not advisable — the two sides share `Sharing/Skeleton.lean` and the edit is one coherent refactor.

#### Reachability: is the completeness theorem reachable against the recommended design?

**Verdict: yes, reachable; not provably blocked; and the honest estimate is that D is the largest single piece of work in the programme, larger than C.** Stated plainly rather than optimistically, with the evidence on both sides.

Positive evidence, all machine-checked (696 round 2, probe `03_trans_redesign_gate_probe.lean`, exit 0, no `sorryAx`):

1. `famA_tCertifies` and `famB_tCertifies` — full six-condition certificates under the redesigned conditions, on exactly the two target classes the landed conditions left empty (`Pp → ⊡Pp`; `Fp → (¬p → ⊡Fp)`). The certificate class is non-empty precisely where it was empty.
2. `famA_refutes_snce_share_congr` / `famB_refutes_untl_shift_congr` — the redesigned (C1') does *not* re-derive the collapse. This is the check without which a redesign reproduces the defect and still type-checks.
3. `total_eq_tthread_of_liftable` — `Liftable` alone restores the histories characterization, so the `box`/`stab` cases of the truth lemma survive.
4. `TThread.toThread` under `ArrivalPruned` — every trans-thread is a share-thread, so `hist` and the whole frame section are byte-unchanged.
5. The repository's valuation is state-indexed (`TaskModel.lean:60`), placing it in the literature's *decidable* case for Ockhamist validity, not the case recorded as open.

Open obligations, none of which has an owner today, and all of which belong to D's research round:

- **O1 — is `Liftable` decidable?** F5. The Assembly analogue must decide it per candidate. Likely yes by finite-graph simulation on the periodic index set, but unscoped. Risk: medium. If it is *not* decidable, the compression theorem still holds and the *decision procedure* degrades to a semi-decision procedure again — the same failure mode this programme exists to remove, relocated. **D's research round must answer O1 before D's plan is written.**
- **O2 — constructing a liftable `trans` from an arbitrary countermodel.** F6. The two landed lifts use constant threads and no pigeonhole; the general case needs a periodicity argument at the combined window. Risk: medium-high. This is the analogue of the hardest half of today's `total_eq_thread`.
- **O3 — (C5)'s time-indexed witness demand, and the lasso-count bound.** F4. `⊡φ` witnesses must share the state at a *specific* time, unlike `□χ` witnesses. The Formula side's `|closure| + 1` lasso bound may not survive; the L⁺ bound may be `|closure| ×` window, which propagates into the enumeration cost and into the paired repository's search bounds. Risk: high, and the one most likely to force a design revisit. **Not recorded anywhere before this report.**
- **O4 — a literature question, for 699 Part B.** GKWZ's negative results cover products with an S5 factor and a linear factor. Here `box` is S5 over all histories and `⊡` is S5 over state-agreeing histories, so there are two S5-like modalities over a linear-time factor. `⊡` *refines* `box` and the valuation is state-based, so the standard product-undecidability encodings do not obviously apply — but that is an absence of an argument, not an argument. **699 Part B should be asked for this explicitly**, since it already owns the literature grounding and GKWZ is already in the corpus. If GKWZ or Reynolds 2002's open-problem list turns out to bound this combination, O4 changes D's target, and that is exactly the "obstruction predictable from the audit and the literature" this survey was told to look for. As read today, no such bound is in hand.

**What each intermediate step buys toward the target theorem:**

| Item | What it buys |
|------|--------------|
| A (695) | Step 0 of D's proof. Without it D is unstateable. Also useful standalone: it is the L⁺ twin of a landed result and pins a new C2 row regardless of how C turns out. |
| B Part A (699) | Assurance that the *other* conditions do not carry the same latent collapse, so C's repair is not one of several needed. Its highest-value output is a collapse C does not repair — which would change C's design before it is built. |
| B' Part B (699) | The verdict on O4, and a name for what `Liftable` is doing (history-closure / bundled-branch condition) so the design is recognizable to a reader outside this repository. |
| C (696) | Makes D's conclusion *possible*: turns `...not_plusCertifies_stabSnce` from a theorem into a non-theorem. Supplies three of the paired repository #200's four needs. |
| D (new) | **The target itself**, plus #200's fourth need. |
| F (new) | Prevents recurrence. Buys nothing toward the theorem; buys the theorem's durability. |
| G (701) | Hand-off; buys the paired repository's ability to restate its blockers correctly. |

#### Cross-repository coordination point

Expressed by fully-qualified declaration name, so it survives task renumbering on either side. **The paired repository is not edited by this task or by any task proposed here.**

Must land in `BimodalLogic` before `ModelChecker`'s `extend_bimodal_to_stability_modal` can move:

1. `FormalSystem.Semantics.plusValidZTime_iff_plusValidInt` — task 695. (Name as its description gives it; confirm on landing.)
2. `FormalSystem.Metalogic.Decidability.SharingSkeleton.total_eq_thread` — **landed**, and must be re-proved in its `trans`-relative form by task 696. This is #200's "histories characterization".
3. The redesigned `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.PlusLocalCoherentShare` and `...StabFaithful` — task 696. These are #200's "state-sharing witness structure" and "redesigned box condition".
4. `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies` — **landed**, and must survive task 696 with their statements unchanged. This is #200's soundness argument, and its absence was the reason #200 was blocked in the first place.
5. The L⁺ compression theorem and its bound — **task D, proposed here**. This is #200's "compression bound", the fourth of its four needs and the last to arrive.

Already satisfied, so these three paired-repository tasks need nothing further from here and should not wait: `apply_upstream_adequacy_chain_rows` (#216), `rescope_blocked_adequacy_consumers` (#217), `bimodal_theory_limits_example_group` (#219) — all three consume only `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime` and the four `Incompleteness.lean` declarations, every one of them landed and C2-pinned.

Orthogonal, and not part of this programme: `a3_compute_bounds_from_closure` (#198) needs a *minimal-period* result on the Formula side, which the landed theorem does not supply (it bounds segment lengths). That is a Formula-side question with no L⁺ content.

#### Task entries this survey proposes — exactly two

Both are proposals for the implementation phase of this task to create; this research round creates no task entries.

**PROPOSAL 1 — `lplus_compression_and_completeness`** (`task_type: lean4`, `dependencies: [695, 696]`)

The L⁺ twin of `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`: every ℤ-time non-validity of a `PlusFormula` admits a bounded, canonically guessed `PlusSharingWitnessFamily` certifying the refutation, against task 696's redesigned condition set, with `...plusTruth_iff_mem` and `...plusRefutes_of_certifies` untouched, zero sorries, no new axioms, a `docs/theorem-index.md` row and a C2 axiom pin. **Research-first**: its research round must answer O1 (is `Liftable` decidable, and by what argument), O2 (constructing a liftable arrival-pruned `trans` from an arbitrary countermodel — the general case, not the constant-thread case), and O3 ((C5)'s time-indexed witness demand and the resulting lasso-count bound, which may not be `|closure| + 1`), and must read task 699 Part B's verdict on O4 before its plan is written. Anticipated `file_scope`: `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/` (new subtree), `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`, `FormalSystem.lean`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`.

*Justification*: this is the target theorem. It has no owner, it is the largest single gap in the programme, it is the fourth of the paired repository #200's four stated needs, and nothing else on either side supplies it. Its research round is where O1-O3 — three obligations this survey found unrecorded — acquire an owner.

**PROPOSAL 2 — `certificate_non_vacuity_and_shape_gates`** (`task_type: general`, `dependencies: [696]`; prefer scheduling after Proposal 1 as well)

Both structural preventions as one task, because both are assertions in `scripts/check-module-invariants.sh` and splitting them would put two tasks on the same single file. (a) A standing obligation that every certificate-shaped condition set carry an exhibited **non-trivial** inhabitant as a checked artifact — the defect survived because no such witness had ever been exhibited and a vacuously-satisfiable condition set type-checks indefinitely. Task 696's `famA_tCertifies`/`famB_tCertifies` are the first instances; the gate makes the obligation standing rather than incidental. (b) A mechanical check against the collapsing clause shape — a definition that universally quantifies a biconditional over a reflexive relation — so the error class cannot be reintroduced silently. Task 699 Part A's audit table is the specification for (b): it enumerates the shape's occurrences and classifies each as intended-invariance or latent-collapse, which is exactly the allowlist a shape check needs.

*Justification*: separable from the completeness programme in the sense that neither buys anything toward the theorem — but not separable in scheduling, because a gate landed before task 696 goes red on task 696's own refactor, and a shape check written against the pre-repair clauses encodes the defect as the baseline. Sequencing it last is the whole point. Existing invariants run C1-C35, so these are C36/C37 and there is room. No existing task covers either.

#### Areas where existing tasks suffice — proposing nothing, and why

| Survey item | Verdict | Reason |
|-------------|---------|--------|
| (1) Substrate design | **Covered by 696.** Propose nothing. | Design authority, `researched`, two landed reports, a recommended design verified by construction, and the abandoned redesign task already folded in with its paths transferred. The one action needed is not a new task: 696's `file_scope` should be widened by F7's nine files. Task 698 (`file_scope_declaration_hygiene`, scope `specs/state.json`) is the right owner and is in research this same cycle. |
| (2) Carrier normalization | **Covered by 695.** Propose nothing; **sequence it FIRST.** | Unblocked, in research now. F2 settles the sequencing question from the code. One coordination action: 695's plan should state the consequence-form (`Γ ≠ []`) analogue as a named extension point, since `Compression/Assembly.lean:66` identifies it as one of exactly three `Γ = []`-specific residue items. That is a sentence in a plan, not a task. |
| (3) Invariance audit / Ockhamist grounding | **Covered by 699.** Propose nothing. | Unblocked, in research now. Part A soft-gates 696's (C1')-rewrite phase (E2); Part B does **not** gate 696 (E8) and should be asked for O4. 699's own description already commits to proposing a follow-on task for any latent collapse Part A finds that 696 does not repair — so that contingency has an owner too. |
| (4) General-consequence obligation | **Parallel, not critical path.** Propose nothing. | Recorded accurately in `Compression/README.md:114-129` and `Assembly.lean:55-73`, and carried as an open upstream obligation by paired #216/#217. D's target is the `Γ = []` instance, so D is complete without it. Opening it now would cross two axes; the Formula side is cheaper. |
| (5) L⁺ compression subtree / paired-repo waits | **Do NOT build before the condition set is corrected** — see E3. **This is Proposal 1**, gated on 696. | The paired repository's four named items: #200 blocked past D (E5); #216, #217, #219 unblocked now and need nothing further. |
| (6) Structural preventions | **Separable in value, not in scheduling. This is Proposal 2**, gated on 696. | See E7/E7'. |

## Decisions

1. **695 goes first.** Decided from `Compression/Family.lean:165`, not from the argument in 695's own description. The carrier normalization is inside the compression theorem, so the target theorem is unstateable without it.
2. **No L⁺ compression work before 696 lands.** `...not_plusCertifies_stabSnce` makes the target false against the landed conditions, and three of the lemmas a premature subtree would rest on are scheduled for deletion.
3. **699 Part B does not gate 696; it advises the new compression task.** A literature bound cannot invalidate an elaborated construction. 699 Part A does soft-gate 696's (C1')-rewrite phase.
4. **The general-consequence obligation is parallel.** No task; one extension-point sentence in 695's plan.
5. **Two new tasks, not more.** `lplus_compression_and_completeness` (the target) and `certificate_non_vacuity_and_shape_gates` (both preventions, one task, last). Everything else in the survey scope is already owned.
6. **The completeness theorem is judged reachable**, with O1/O2/O3 assigned to the new compression task's research round and O4 assigned to 699 Part B. No obstruction now in hand predicts unreachability; the repository's state-indexed valuation puts it in the literature's decidable case.
7. **Never dispatch two of {695, 696, D, F} implementing in the same cycle.** `scripts/check-module-invariants.sh` and `docs/theorem-index.md` are the two shared, block-rewritten artifacts.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| O3 ((C5)'s time-indexed witnesses) forces a larger lasso-count bound, propagating into the paired repository's search bounds | High | Assigned to the new compression task's research round as a named question. Flag it to the paired repository in the same hand-off note as the rest, so #200's bound expectations are not set from the Formula side's `|closure| + 1`. |
| O1 (`Liftable` undecidable) would relocate the semi-decision-procedure failure rather than remove it | Medium | Answer O1 in D's *research* round, before D's plan. If undecidable, D still delivers the compression theorem and the honest scope statement is "compression proved, procedure still semi-decision" — which is a real result, not a failure, and must be recorded as such rather than concealed. |
| 696's undeclared nine files cause a mid-refactor collision | Medium | F7's table. Widen 696's `file_scope` via task 698 before 696 implements; meanwhile run 696 alone. |
| Two tasks edit the C2 `AXIOM_BASELINE` heredoc concurrently, producing a gate red for both and diagnosable for neither | Medium | Decision 7. The wave table serializes A, C, D, F. |
| A reader mistakes a completeness gap for unsoundness | Medium | Stated in this report's first bullet, in `PlusWitnessFamily/README.md`'s "Soundness versus completeness, explicitly", and in `Incompleteness.lean`'s "What this does NOT show". Any new artifact in this programme should carry the same sentence. |
| 695's and 699's reports land after this survey and contradict an edge | Low | The Context & Scope caveat names E2, E5, E8 as the edges to re-check. No conclusion here depends on the *content* of a report that does not yet exist. |
| The programme lands the repair without the theorem it was for — the risk this task exists to remove | Low, now | E3 and E5 make the ordering explicit, and Proposal 1 gives the theorem an owner. Before this survey, the repair (696) had an owner and the theorem did not. |

## Appendix

**Searches and probes used.** `grep` over the live tree for `exists_witnessFamily_of_not_validZTime`, `plusRefutes_of_certifies`, `plusTruth_iff_mem`, `plusValidZTime`/`plusValidInt`, `validZTime_iff_validInt`, `decidablePlusValidZTime`/`PlusCompression`; `find` over `FormalSystem/Metalogic/Decidability/`; `jq` over `specs/state.json` here and in `/home/benjamin/Projects/ModelChecker`; `grep` over `specs/literature-index.json`; one WebSearch (Ockhamist decidability). No Lean was elaborated and no Mathlib lookup was needed — see *Mathlib and Tool Lookups*.

**Constraints honored.** No Lean source, no other task's declared territory, and no file in `/home/benjamin/Projects/ModelChecker` was modified; that repository was read only. Task 696's reports and `Incompleteness.lean` are cited by fully-qualified declaration name and not restated. This report creates no task entries; Proposals 1 and 2 are for this task's implementation phase.

**Declaration names cited, all confirmed present in the live tree** unless marked: `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`; `...validZTime_iff_noCertifiedCandidate`; `...Compression.decidableValidZTime`; `...decidableSemanticConsequenceNil`; `...SharingSkeleton.total_eq_thread`; `...PlusSharingWitnessFamily.{plusTruth_iff_mem, plusRefutes_of_certifies, stabFaithful_share_congr, stabFamily_separates, stabFaithful_diagonal, snce_share_congr, not_plusCertifies_stabSnce, not_plusCertifies_stabSnce_premise, not_plusValidZTime_stabSnce, StabFaithful, PlusBoxFaithful, PlusLocalCoherentShare, PlusTarget, plusLocalCoherentLab_of_share, plusFulfillingLab_of_thread}`; `FormalSystem.Semantics.validZTime_iff_validInt`; `FormalSystem.PlusLanguage.PlusValidZTime`; `FormalSystem.Semantics.TaskModel.valuation`. **Not present** (proposed or in-flight): `FormalSystem.Semantics.plusValidZTime_iff_plusValidInt` (task 695); any `PlusWitnessFamily.Compression.*` (Proposal 1). Names from task 696's round-2 probe (`famA_tCertifies`, `famB_tCertifies`, `total_eq_tthread_of_liftable`, `stabFamily_not_liftable`, `TThread.toThread`, `famA_liftable`, `famB_liftable`, `famA_refutes_snce_share_congr`, `famB_refutes_untl_shift_congr`) live in that task's archived probe, not in the library, and are cited as probe results.

**Sources.**
- [Goranko & Zanardo, *An Extended Branching-Time Ockhamist Temporal Logic*](https://www2.philosophy.su.se/goranko/papers/JoLLI-An%20Extended%20Branching-Time%20Ockhamist%20Temporal%20Logic.pdf)
- [*Temporal Logic*, Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
