# Research Report: Task #807

- **Task**: 807 - Backward-determinism forcing check: can a closed L⁺ formula force backward closure on a regular ℤ-frame?
- **Started**: 2026-10-17T14:09:31Z
- **Completed**: 2026-10-17T14:26:18Z
- **Effort**: ~20 minutes wall clock (three compile rounds of a 1268-line scratch file, each under 3 minutes)
- **Dependencies**: None (the two fixtures it instantiates, `Probe719Backward` and `Probe733Mirror`, are already wired and tracked)
- **Sources/Inputs**:
  - Codebase: `FormalSystem/PlusLanguage/PlusTruth.lean` (the `stab` clause, line 93), `PlusLanguage/PlusValidity.lean` (`TaskFrame.PlusValidOn`), `PlusLanguage/PlusNonValidities.lean` (`refute_somePast_stab`), `Semantics/IntNormalForm.lean` (`FrameOver.step`, `WorldHistory.isStepPath`, `mem_HF_iff_adjacent`), `Semantics/Nomic/Recovery.lean` (`PartialHistory.exists_worldHistory_two_point`), `Semantics/DeterministicBridge.lean` (`SingletonClasses`), `StarLanguage/StarDeterminism.lean` (`deterministic_starDefinable`), `Metalogic/Independence.lean` (result 5, `deterministic_not_plusDefinable`), `Metalogic/Independence/ForwardDeterministicFrame.lean` (`F^N`)
  - Evidence probes: `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` (`Probe719Backward`), `backward-dual-mirror-fixture.lean` (`Probe733Mirror`); registry `scripts/check-evidence-probes.sh`
  - Literature (`--lit`, verified_conversion chunks): Thomason 1984 §4 "The technical side of historical necessity", Definitions 6-8 (`/home/benjamin/Projects/Literature/sources/thomason_1984/sec05_4-the-technical-side-of-historical-neces.md`); Caleiro-Viganò-Volpe 2013 §2, Definition 2.5 (`/home/benjamin/Projects/Literature/sources/caleiro_2013/sec02_2-combinations-of-tense-and-modalities.md`); Halpern-van der Meyden-Vardi 2004 (`halpern_vandermeyden_vardi_2004_axiomatizations_knowledge_and_time`, chunks 0001, 0002, 0014, 0018, 0019 — UNVERIFIED summary tier; Table 1 is an omitted figure in the conversion)
  - Programme documents: `specs/ROADMAP.md` Stage 1 "Two risks not covered" table (line 263) and Stage 0 section; `specs/literature/README.md` "The L⁺ position in the corpus"
  - Compiled scratch check (this session): `specs/807_backward_determinism_forcing_check/research-scratch/807-forcing-check-draft.lean` and its log `807-forcing-check-draft.log`
- **Artifacts**:
  - `specs/807_backward_determinism_forcing_check/reports/01_backward-determinism-forcing-check.md` (this report)
  - `specs/807_backward_determinism_forcing_check/research-scratch/807-forcing-check-draft.lean` — compiled, sorry-free draft of the verdict theorems plus both fixture instantiations (a DRAFT for promotion to `specs/evidence/`, not a wired probe; see Recommendations)
- **Standards**: report-format.md, subagent-return.md, status-markers.md, artifact-management.md

## Executive Summary

- **VERDICT: POSITIVE — a forcing formula exists.** The closed L⁺ formula `(q S ⊥) → ⊡(q S ⊥)` ("what held yesterday is settled") is valid on a regular ℤ-frame **if and only if** the frame is backward deterministic (every world state has exactly one step-predecessor). Both directions are machine-checked and sorry-free in the draft; the history-level characterization is choice-free at `[propext, Quot.sound]`.
- **Fixture evidence as the task specified**: on `Probe733Mirror` (backward branching factor 2 at every `aft (k+1)`) the formula is **refuted** (`Probe733Mirror.bdForce_not_valid`), with the two histories through `aft 1` at time 0 that diverge at time −1 (`x 1` vs `aft 0`) as the witness; on `Probe719Backward` (unique predecessors) it is **valid** (`Probe719Backward.bdForce_valid`) while that fixture is forward-branching (`forward_branching`, axiom-free) — so the formula forces backward and **not** forward determinism, which is exactly the Wdc-style condition the historical-necessity tradition needs.
- **The mechanism is one line**: on ℤ-time `φ S ⊥` is "φ at t−1" (`yest_iff`); the forcing direction runs the singleton valuation `|q| = {τ(t−1)}`, the same device `deterministic_of_detPM` already uses in L⋆.
- **No contradiction with the tree's non-definability result**: `deterministic_not_plusDefinable` (Independence result 5) is about *full* determinism over **ℝ-time**, where `q S ⊥` is unsatisfiable (no immediate predecessor), so `(q S ⊥) → ⊡(q S ⊥)` is vacuously valid on every dense frame and forces nothing there. The forcing is ℤ-specific, and that is the whole point.
- **Per task item (4): STOP and escalate.** The ROADMAP risk row's conditional ("if forcing is possible, the know-time-do-not-forget family becomes a reduction target") is now realized. This report does **not** attempt the reduction; it records the exact mapping (⊡ on backward-closed frames = single-agent synchronous perfect-recall knowledge with the state as observation; □ = the same-time universal modality) and what the corpus does and does not say about that case, for a Stage 0 ruling. A `user_decision` is set on `.return-meta.json` (non-blocking, recommended option: land the positive-verdict probe, add the Stage 0 ruling item, scope the transfer question as its own task).

## Context & Scope

- **What was asked**: (1) state the backward-closure condition precisely as a frame property on regular ℤ-frames, grounded in Thomason 1984 §4 Def. 6(2) and Caleiro-Viganò-Volpe Def. 2.5 `Wdc`; (2) construct or refute a closed L⁺ formula whose ℤ-validity forces it, using `Probe733Mirror` as the branching test bed and `Probe719Backward` as the positive control; (3) report the verdict as a wired probe; (4) if found, stop and escalate.
- **Scope of this phase**: items (1) and (2) are settled here with compiled evidence; item (3) is specified for the plan (the draft is complete and compiles, but a wired probe must be a transcription under `specs/evidence/` registered in `scripts/check-evidence-probes.sh`, which is implementation work); item (4) is executed by the `user_decision` field and the Recommendations below.
- **Guardrails honoured**: no `sorry`, no new axiom, no `native_decide`, no vacuous definition anywhere in the draft (`grep -c sorry` on the draft returns 0; the `#print axioms` lines are quoted verbatim in Findings). The `stab` clause is used as is and never restated or weakened; the check is frame-level forcing, as required.
- **Constraint**: the probe collection's standing rule — a probe imports only `FormalSystem`, never another probe — is why the draft transcribes both fixtures verbatim rather than importing them.

## Findings

### Literature Proof Structure

**Source**: Thomason 1984, "Combinations of Tense and Modality", §4 Definitions 6-8 (T×W frames); Caleiro-Viganò-Volpe 2013, "On the Mosaic Method for Many-Dimensional Modal Logics", §2 Definition 2.5 (`Wdc`), Definition 2.7 (satisfaction), Lemma 2.8.
**Strategy**: definition extraction only (no proof is being transcribed); the two definitions are rendered on L⁺'s `⟨τ⟩_t` and shown equivalent to a one-step frame property on ℤ.

#### Step Map
1. **Thomason Def. 6(2)**: a T×W frame carries `≈_t` on W for each t, an equivalence for each t, with the **backward closure** clause (2): for all w₁, w₂ ∈ W and t, t' ∈ T, if `w₁ ≈_t w₂` and `t' < t` then `w₁ ≈_{t'} w₂`. Intention stated in the source: "w and w' are historical alternatives through t, and so differ only in what is future to t." Def. 7 (assignments respect `≈_t` at all `t₁ ≤ t`) is the atomic-harmony twin; Def. 8 gives the clauses, with `□φ` at (t, w) quantifying over `w ≈_t w'`. — [Thomason 1984] §4, Definitions 6-8.
2. **CVV Def. 2.5 `Wdc`** (weak diagram completion) on a basic frame (W, ≺, ≃): for all x, y, y' ∈ W, if `x ≺ y ≃ y'` then there exists x' with `x ≃ x' ≺ y'`. The source glosses it as "a consequence of the linearity of the order relation in a tree"; Ockhamist frames are the ()-(Dsj+Wdc+Mb)-frames, and Lemma 2.8(ii) gives L(C, Dsj+Wdc) = L(C, Wdc+Sdc). — [CVV 2013] §2, Def. 2.5, Lemma 2.8.
3. **Rendering on L⁺** (task item (1)). Points are pairs (τ, t) with τ a possible world of a regular ℤ-frame; `(τ, s) ≺ (τ, t)` iff s < t on the same history; `(τ, t) ≃ (σ, t)` iff `τ.state t = σ.state t` — this is exactly `⟨τ⟩_t` of `def:BLstar-semantics`, which `PlusTruth.lean:93` renders as `∀ σ, τ.state t = σ.state t → …`. `≃` so defined is an equivalence (it is equality of states at a fixed time). Thomason's single global time axis makes his clause (2) **synchronous**; transported it reads: `τ.state t = σ.state t ∧ s < t → τ.state s = σ.state s`. On ℤ this is equivalent to its one-step form:

   `HistBwdDet F := ∀ τ σ t, τ.state t = σ.state t → τ.state (t−1) = σ.state (t−1)`

   (the iterate to every earlier time is `histBwdDet_iterate`, by induction on the gap). CVV's `Wdc` without a global clock is weaker (it asks only for *some* earlier `x'` on `σ`, not one at the same time); its synchronous instance is `HistBwdDet`. Hand check, not compiled: the asynchronous `Wdc` also fails on `Probe733Mirror` — thread-0's history never visits `x 1` at any time — so nothing in this report turns on the distinction.
4. **Frame-level form**. `StepBwdDet F := ∀ u v w, F.step u w → F.step v w → u = v` ("every world state's backward factor is a singleton" in the probes' vocabulary: unique predecessor gives a unique backward root path from every state, and a state with two predecessors gives two backward root paths that differ at index 1, which is `Probe733Mirror.two_bwd_paths`'s shape). `StepBwdDet → HistBwdDet` is one application of `WorldHistory.isStepPath` at `t−1`; `HistBwdDet → StepBwdDet` on a regular frame is `PartialHistory.exists_worldHistory_two_point` applied to each of the two steps (every step lies on a possible world, a ZFC fact through `thm:extension`).

#### Dependencies
- Step 3 depends on Step 1 (the synchronous clause) and Step 2 (the `≃` reading).
- Step 4 depends on Step 3 and on the regular-frame history-existence lemma (choice).

#### Potential Formalization Challenges
- None remained after the session: every rendering above is compiled in the draft (`HistBwdDet`, `StepBwdDet`, `histBwdDet_iterate`, `histBwdDet_of_stepBwdDet`, `stepBwdDet_of_histBwdDet`).

### Codebase Patterns

- **The candidate and the mechanism**. In constructor vocabulary the formula is `PlusFormula.imp (PlusFormula.snce PlusFormula.bot (PlusFormula.atom q)) (PlusFormula.stab (PlusFormula.snce PlusFormula.bot (PlusFormula.atom q)))`. The one lemma that makes it work is `yest_iff`: on a `FrameOver intOrder`, `PlusTruthAt M τ t (φ S ⊥) ↔ PlusTruthAt M τ (t−1) φ`, because the `snce` clause's "no r strictly between s and t" pins `s = t−1` on ℤ. No equivalent "yesterday" lemma exists for `PlusFormula` in the tree (the `snce ⊥`/`snce (⊥→⊥)` occurrences found are in the `Formula`/`StaviFormula` layers: `Soundness.lean:806-814`, `StaviConnectives.lean:317`, `BXCanonical/CanonicalChain.lean:62`).
- **Forcing direction** (`histBwdDet_of_valid`): given histories τ, σ agreeing at t, take the valuation `fun w _ => w = τ.state (t−1)`; then `Yq` holds at (τ, t), validity of the implication gives `⊡Yq` at (τ, t), hence `Yq` at (σ, t), hence `σ.state (t−1) = τ.state (t−1)`. This is the singleton-valuation device of `StarDeterminism.deterministic_of_detPM` and of the PossibleWorlds determinism-axiom-correspondence report §4.1, run one time-step back instead of at a stored time.
- **Soundness direction** (`valid_of_histBwdDet`): immediate from `HistBwdDet` and `yest_iff`.
- **Fixture instantiations** (all compiled; declaration names are those of the draft):
  - `Probe733Mirror.not_histBwdDet`: `histOf 1 (−1)` and `histOf 0 (−2)` both have state `aft 1` at time 0 (`histOf_state` + `canon_of_gt`) and states `x 1` (`canon_self`) versus `aft 0` (`canon_of_gt`) at time −1; `cases` on the equality closes. Hence `Probe733Mirror.bdForce_not_valid (q) : ¬ F.toTaskFrame.PlusValidOn (bdForce q)` and `Probe733Mirror.not_stepBwdDet`.
  - `Probe719Backward.stepBwdDet_node`: case split on the target with `step_inv_pre`, `step_inv_x`, `step_inv_post` (the last needs the `j = 0` versus `j = j'+1` reconciliation by `omega`); `Probe719Backward.bdForce_valid (q)` follows; `Probe719Backward.forward_branching` exhibits `pre 1 → pre 0` and `pre 1 → x 1`.
- **Axiom record of the draft, verbatim from `807-forcing-check-draft.log`** (EXIT=0; the only diagnostics are unused-tactic linter warnings on a `first | rfl | simp | …` combinator whose `rfl` arm fires):
  - `'Scratch807.valid_iff_histBwdDet' depends on axioms: [propext, Quot.sound]`
  - `'Scratch807.valid_iff_stepBwdDet' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe733Mirror.bdForce_not_valid' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe733Mirror.not_stepBwdDet' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe719Backward.bdForce_valid' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe719Backward.forward_branching' does not depend on any axioms`
  The choice in the regular-frame form is upstream and named: `exists_worldHistory_two_point` (through `thm:extension`); in the fixture instantiations it enters through `F_step`/`hist_canon`'s route via `FrameOver.worldHistoryOfStepPath`, exactly as the two fixtures' own headers record for their own theorems. Nothing in the forcing argument itself appeals to choice.
- **How this sits with what the tree already proves**:
  - `PlusNonValidities.refute_somePast_stab` (`P⊡p → ⊡Pp` fails on the permissive frame, "`⟨τ⟩_t` is not closed towards the past") and `ForwardDeterministicFrame.fn_refutes_sentDet_somePast` are the *negative* half of this picture on specific frames; neither states a frame *characterization*. The new content is the exact equivalence, obtained by replacing `P` (which a history can satisfy through an arbitrarily early visit) with `Y` (which it cannot).
  - `Independence.lean` result 5 / `deterministic_not_plusDefinable`: *full* determinism is not L⁺-definable, witnessed over **ℝ**. Consistent: on any dense frame `q S ⊥` is never true, so `bdForce q` is vacuously valid and forces nothing. Result 8 (`sent:det` defines only forward determinism; `F^N`) is the forward analogue of the same asymmetry.
  - **Side remark (not compiled)**: the mirror formula `(q U ⊥) → ⊡(q U ⊥)` forces forward determinism by the same argument, so the conjunction characterizes `TaskFrame.Deterministic` over **regular ℤ-frames** — i.e. `cor:no-characterization` is ℝ-specific and does not extend to ℤ. Worth a one-line note in `Independence.lean`'s docstring once the probe lands; not needed for this task's verdict.
- **The two fixtures are enough, but they are not general**: the characterization theorem is general (any `FrameOver intOrder`, regular for the frame-level form); the fixtures only *instantiate* the two sides, which is what the task asked of them.

### External Resources

- **Thomason 1984 §4**: besides Def. 6(2), the section records that T×W validity is "essentially first-order" and recursively axiomatizable (Burgess, in correspondence) and that Kamp validity is decidable by the method of Burgess [1980] §5 — i.e. the *historical-necessity* side with backward closure is, in the sources the ROADMAP cites, a **positive** (decidable) story, not a negative one. The negatives the ROADMAP row has in mind are the knowledge-and-time family, not Thomason's own.
- **CVV 2013 §2**: Lemma 2.8 and the remark after it fix the hierarchy (), (Wdc), (Wdc+Sdc), (Wdc+Sdc+Mb−); the mosaic decidability results of §4.3 are for these Ockhamist classes. With backward closure now forceable, L⁺ over backward-deterministic regular ℤ-frames is an Ockhamist-style (Wdc-satisfying) class with synchrony and state-local atoms — the comparison with CVV's positive results becomes meaningful, and is for the follow-up, not here.
- **Halpern-van der Meyden-Vardi 2004** (UNVERIFIED summary tier; Table 1 is an omitted figure): the abstract (chunk 0001) says "not all settings of these parameters lead to recursively axiomatizable logics, but sound and complete axiomatizations are presented for all the ones that do"; chunk 0018 states that for m ≥ 2 agents, unique initial state together with no learning gives a class "that do[es] not have a recursive axiomatic characterization, since the validity problem is co-r.e.", and that "if there is only one agent in the picture, things simplify. No learning together with uis implies perfect recall"; chunk 0019 states that with common knowledge and m > 1, complete axiomatizations exist only for C_m, C^sync, C^uis, C^sync,uis, C^nl,sync,uis, C^nl,pr,sync,uis. **What this means for L⁺ on backward-closed frames**: `⊡` is the knowledge of a single agent whose observation is the world state, synchronous (same t) and with perfect recall (`histBwdDet_iterate`); `□` is the same-time universal modality (an "agent" with no information). The corpus prose settles neither (a) the exact single-agent synchronous perfect-recall complexity row nor (b) whether adding the universal modality changes it — both require the PDF's Table 1 and HV89. This is precisely the "reduction target" assessment the task forbids attempting here.

### Recommendations

- See `## Recommendations` below (kept in one place to avoid drift).

## Decisions

- **Formula choice**: `Y := · S ⊥` ("yesterday") rather than `P := ⊤ S ·`; `Pq → ⊡Pq` does not force backward determinism on frames with cycles (σ may visit the predecessor state earlier), while `Yq → ⊡Yq` does, on every ℤ-frame. Decided by the argument, not by taste.
- **History-level predicate as the primary rendering** of Thomason 6(2) (`HistBwdDet`), with the step-level predicate as a corollary on regular frames: the history-level form is literally the source's clause on `⟨τ⟩_t`, needs no regularity, and is choice-free; the step-level form is what "singleton backward factor" means in the probe collection.
- **Verbatim transcription of both fixtures** into the draft, per the collection's import rule, instead of a smaller bespoke fixture: the task named these two fixtures as the test bed and control, and the plan can promote the draft with no re-derivation.
- **Draft kept under the task directory, not under `specs/evidence/`**: writing or registering a probe is implementation; the research-phase deliverable is the verdict and its evidence. The draft is flagged as a draft in its own header comment and in this report so it is not mistaken for a wired probe (`check-evidence-probes.sh`'s header explains why probes must not live in task directories).
- **`user_decision` set non-blocking**: landing the probe (task item (3)) is mandated whatever the verdict and is reversible in-repo; the irreversible-looking question (what Stage 1 does about a realized risk) is a programme ruling the orchestrator must not make, so it is surfaced for the user at cycle end with a recommended option, per `user-decision-contract.md`.

## Recommendations

1. **Plan phase**: one short plan, two phases. Phase 1 promotes the draft to `specs/evidence/seam-gluing-ray-product/backward-determinism-forcing-formula.lean` (namespace `Probe807Forcing` for the general section; keep `Probe733Mirror`/`Probe719Backward` namespaces for the transcribed fixtures or re-namespace them to avoid cross-collection ambiguity — the collection already lives with `decide_will` being ambiguous and qualifies every citation, so either is acceptable), with a header in the existing probes' convention (why this fixture, outcome, honest limit, `reflectTime` note not needed here, citation hygiene, verbatim axiom record, compile-check line), registered in `scripts/check-evidence-probes.sh`'s `WIRED` array and table with a row that says **POSITIVE (forcing formula exists)**. Phase 2 adds a checkbox under `specs/ROADMAP.md` Stage 0 ("Rule on **807**'s positive verdict …") and re-words the Stage 1 risk-row cell from "unrealized" to "**realized** — `(q S ⊥) → ⊡(q S ⊥)` characterizes backward determinism over regular ℤ-frames (probe …); reduction not attempted; Stage 0 ruling pending", and adds one sentence to `specs/literature/README.md`'s "The L⁺ position in the corpus" paragraph. Both edits are factual records of this verdict, not rulings.
2. **Do not** attempt the know-time-do-not-forget reduction in this task (task item (4)). The honest state of that question: forcing is a *frame* property (all valuations), while a reduction of "ψ valid over backward-closed frames" to "something valid over all regular ℤ-frames" can only relativize finitely many instances `Yχ → ⊡Yχ` (χ over the closure of ψ), i.e. a *local* backward closure along ψ's own observations; whether that suffices, and whether the resulting target class is one of the non-r.e. rows of HVV's Table 1 or the single-agent row that "simplifies", is a separate scoped task with the HV89/HVV PDFs in hand.
3. **Stage 0 ruling (the `user_decision`)**: recommended option A — land the probe and the record edits, open the follow-up assessment task, keep Stage 1 moving. Options B (halt Stage 1 until the transfer question is settled) and C (land the probe only, no ROADMAP change, no follow-up) are the alternatives.
4. **Minor, optional**: add a `PlusFormula.yest` / `PlusTruth.yest_iff` pair to `PlusLanguage/` when some consumer in `FormalSystem/` needs "yesterday" — the probe should not be that consumer (probes are transcriptions, not library), and this task's file-scope is `specs/**` only.

## Risks & Mitigations

- **Risk**: the positive verdict is read as "L⁺ is undecidable". **Mitigation**: the report and the probe header say what is and is not shown — a frame-definability theorem, not a reduction; Thomason's own tradition (T×W, Kamp validity) is decidable/axiomatizable per §4; the knowledge-and-time negatives need ≥ 2 informed agents in every corpus statement found, and L⁺ has one.
- **Risk**: `decide`/instance-synthesis fragility in the fixture instantiation (the third compile round was a `Decidable` instance failing to synthesize at type `F.toTaskFrame.WorldState`). **Mitigation**: the draft uses `rfl` for that goal (it fires; the `simp`/`congr` arms of the `first` combinator are dead and should be dropped at promotion to silence the linter).
- **Risk**: the draft's two transcribed fixtures drift from the wired originals. **Mitigation**: promotion must re-copy from the current `backward-dual-*-fixture.lean` files, not from the draft; the appended sections are the only new text.
- **Risk**: the ROADMAP edit is taken as the ruling. **Mitigation**: phrase it as a record with "ruling pending", and put the ruling itself under Stage 0 as a checkbox.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `s < t ∧ (∀ r, s < r → r < t → False) → s = t − 1` (ℤ) | omega | success (after binding `r`/`s` at type `ℤ`, not `Duration`) | `by_contra` + `show (s : ℤ) < t − 1` |
| same goal with `r : F.toTaskFrame.Duration` | omega | fail ("possible counterexample r − t ≥ 0") | N/A — fixed by `fun (r : ℤ) …` |
| `Node.aft (1 + (0 − −1 − 1).toNat) = Node.aft (0 + (0 − −2 − 1).toNat)` at type `F.toTaskFrame.WorldState` | decide | fail (no `Decidable` instance synthesized through `F`) | N/A |
| same | rfl | success | kernel evaluation of the `Int` literals |
| `u = v` from `Step u (post k j)`, `Step v (post k j)` | rcases + omega | success | `step_inv_post` both sides; `omega` on the `j = 0` vs `j = j'+1` clash |
| `rw [F_step] at hu` with `hu : F.step u w`, `u : F.WorldState` | rw | fail (pattern not found at reducible transparency) | N/A — fixed by `(F_step u w).mp hu` term-mode |

## Context Extension Recommendations

- **Topic**: "yesterday"/"tomorrow" on ℤ-time in the L⁺ layer. **Gap**: no context note records that `φ S ⊥` / `φ U ⊥` are the previous/next-instant operators on `FrameOver intOrder` and that this is what makes ℤ-time frame-definability results (this one; the forward twin) differ from the ℝ-time non-definability of `cor:no-characterization`. **Recommendation**: a short paragraph in `.claude/context/project/lean4/` (or the repo's Lean domain notes) under determinism/definability, pointing at `Independence.lean` result 5 and at the promoted probe.
- **Topic**: knowledge-and-time mapping for `⊡`/`□`. **Gap**: `specs/literature/README.md` names the "know-time-do-not-forget family" without the dictionary (⊡ = single-agent synchronous perfect-recall knowledge with the state as observation once backward closure holds; □ = same-time universal modality; atoms state-local = observable local state). **Recommendation**: add the dictionary to the README's corpus-position paragraph alongside the verdict sentence.

## Appendix

- **Search queries used**: `lean_local_search` was not needed — every declaration cited was located by `grep` over `FormalSystem/` and `specs/evidence/` and then read in place; `literature-search.sh "perfect recall"`, `"no learning perfect recall undecidable"` (both returned only SEP chunks at bm25 tier; the HVV statements above were read directly from the document's chunks 0001/0002/0014/0018/0019).
- **Compile command** (from the repository root, under the `.lake/build-guard.lock` flock that `check-evidence-probes.sh` uses): `lake env lean specs/807_backward_determinism_forcing_check/research-scratch/807-forcing-check-draft.lean`; toolchain `leanprover/lean4:v4.33.0-rc1` (from `lean-toolchain`).
- **Declarations in the draft (general section, namespace `Scratch807`)**: `yest`, `bdForce`, `HistBwdDet`, `StepBwdDet`, `yest_iff`, `histBwdDet_of_valid`, `valid_of_histBwdDet`, `valid_iff_histBwdDet`, `histBwdDet_iterate`, `histBwdDet_of_stepBwdDet`, `stepBwdDet_of_histBwdDet`, `valid_iff_stepBwdDet`. Fixture sections: `Probe733Mirror.not_histBwdDet`, `bdForce_not_valid`, `not_stepBwdDet`; `Probe719Backward.stepBwdDet_node`, `stepBwdDet`, `forward_branching`, `bdForce_valid`.
- **References**: Thomason 1984 §4 (Defs 6-8, the Burgess remark on T×W axiomatizability, the Kamp-validity decidability remark); CVV 2013 §2 Def. 2.5, Lemma 2.8; HVV 2004 abstract and §§2-3 prose around Table 1; `specs/ROADMAP.md` line 263; `specs/literature/README.md` "The L⁺ position in the corpus"; PossibleWorlds determinism-axiom-correspondence report §4.1 (as cited by `StarDeterminism.lean`; not read this session).
