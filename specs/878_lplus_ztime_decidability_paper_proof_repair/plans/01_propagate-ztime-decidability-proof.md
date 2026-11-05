# Implementation Plan: Task #878

- **Task**: 878 - Make the paper proof of L-plus ZTime decidability rigorous
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None (the theorem it propagates is conditional on task 870's lemma, but no
  phase below is gated on 870 landing)
- **Research Inputs**: `specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
- **Artifacts**: plans/01_propagate-ztime-decidability-proof.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

The task's own deliverable — a report carrying the repaired argument, each step proved or cited to
a held source — is already written and linked in `state.json`. All five dispatch items are
discharged in it: G1 repaired, G2 repaired with an explicit new-root coding, every recalled
citation replaced by a held one, the theorem stated with its hypotheses and its negative results,
and the Craig/existence question answered. What remains is **propagation, not discovery**: three
live records currently state, in their own text, claims this task's report refutes or answers, and
each has to reach the record where a future reader will look.

Every phase below edits `specs/**` markdown only. No Lean file, no `FormalSystem/` or `Tests/`
path, and no `.typ` chapter is touched — the dispatch's "report only" constraint is honoured
literally, and the standing refusal of a Lean formalization of the MSO route is restated rather
than revisited.

The single most important discipline across all four phases: **the theorem is conditional on
(H5)**, the oriented-forest Saturation and universal-cover lemma that task 870 owns and that is
`not_started`. No sentence added anywhere may read as if L⁺ ZTime decidability is established
unconditionally, machine-checked, or constructive.

### Research Integration

Six findings drive the phases below.

- **Finding 2 (paper, with a compiled core)**: G1 is repaired, and by re-justification rather than
  reconstruction. Report 03 §1.3 step 1's "state-local truth is shift-invariant, so one witness per
  state suffices" is a non-sequitur, but the conclusion holds for a different reason — the compiled
  `PlusTruth.stab_state_only` (`⊡φ` is one bit per world state) and `PlusTruth.box_global` (`□φ` is
  one bit per model). The witness closure is indexed by *states*, which is exactly the carrier
  being cut down, so each stage is countable-to-countable. This answers the standing 2026-11-05
  amendment's statement that "step 1 currently has no stated justification that survives".
- **Finding 1 (derived)**: the argument's step order must change — cover first, countable model
  second — because `FrameOver.IsRegular` bundles `saturation` as a fourth field, so the compiled
  `plus_invariance_of_isZTime` demands Saturation of the *base* frame, which in report 03's order
  is the very sub-digraph whose Saturation is unestablished. Report 03 §1.3's steps 1 and 2 are
  therefore in the wrong order as written.
- **Finding 4 (derived)**: G2 is repaired by an explicit new-root coding, and step 4's encoding
  survives it with exactly one load-bearing guard — directed reachability `⊑` must carry the
  conjunct `¬Rt(meet(y, x))`, or it returns spurious cross-component reachability once the
  rooted-tree meet of two nodes in different components becomes the new super-root.
- **Finding 6 (held)**: Rabin's theorem is Thomas 1997 Theorem 6.20 (`S2S` is decidable), with
  6.19 for the effective MSO-to-automaton direction and 6.18 for emptiness and a regular witness.
  `S2S` alone suffices: `SωS`, Gurevich-Shelah and the Muchnik/Walukiewicz transfer are **not
  needed**. Report 03 §1.3 step 5's parenthetical ("recalled; the held Reynolds 2002 §6 … via
  Gurevich-Shelah") is superseded.
- **Finding 9 (derived, on a held citation)**: the existence question is closed affirmatively and
  **did not need Craig** — decidability makes the validity set recursive, hence literally its own
  recursive axiom set. Craig's theorem (held: Chagrov & Zakharyaschev 1997 Thm 16.10) is the
  instrument for the weaker r.e.-only hypothesis, which is the Base/Dense/RTime situation. What
  stays open is a *finitely schematic* system, which is a different question.
- **Finding 8 and Decision 7 (derived)**: no finite model property, but a *regular*-model property
  does follow from Thm 6.18; and task 870's stated hypothesis (directed-path uniqueness) is
  strictly weaker than what report 03 §1.2's own step 4 consumes (an underlying undirected forest),
  so 870 as currently described may not discharge (H5).

Finding 10's open-modal verdict is **negative** and is a correction to report 866's finding 5,
which proposed a (walk, time, subformula)-indexed closure and thereby walked into the gap its own
finding 6 names. That correction is Phase 2.

### Prior Plan Reference

No prior plan for this task. Task 866's plan
(`specs/866_mso_route_open_modals_ztime_decidability/plans/01_record-verdict-and-file-r1.md`) was
read as a **precedent for shape only** — it is the closest prior propagation plan against the same
report 03 target, and its path-resolution, re-read-before-edit, and coverage-appendix-marker
disciplines are reused below. Its phase content is not copied, and one of its claims is corrected:
it asserted in two Tier Justification lines that `specs/ROADMAP.md` resolves to `__FULL_SWEEP__`
under `suite_selection_select`. Measured this dispatch, that path resolves to two real suites
(`test-engine-written-state-paths-lib.sh`, `test-roadmap-generation.sh`); only the report 03 path
returns the sentinel. Phase 3's tier justification names the suites rather than repeating the
sentinel claim.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch, so `specs/ROADMAP.md` was not consulted as
delegation context and `roadmap_flag` is unset — this plan therefore adds **no** roadmap-review or
roadmap-update wrapper phases. `specs/ROADMAP.md` is nonetheless a deliberate **file target** of
Phase 3, because four of its own sentences name this task as the pending measurement that answers
them:

- the "MSO/Rabin route reaches ZTime only" ruling, whose closing sentence reads "**Making the paper
  argument a proof is 878**: the countable-model step (gap G1) and the forest-versus-single-tree
  gap, with held citations";
- the "MSO decidability formalization is refused outright" entry, which states "Before any attempt
  at that reading, gap G1 in report 03 §1.3 needs a paper repair, which 878 owns";
- the two run-order annotations on `870` ("870 feeds 878's cover step"), which is where the (H5)
  hypothesis-strength flag has to land to reach 870's owner;
- the "Decidability before completeness" ruling's stated mechanism ("Deciding validity makes the
  valid set r.e., and Craig then gives a recursive axiomatization"), which finding 9 sharpens.

Phase 3 re-reads the roadmap immediately before editing rather than relying on any line number or
quotation stated here.

## Goals & Non-Goals

**Goals**:

- Land the G1 and G2 repairs, the step reorder, and the held Rabin citation into report 03 §1.3, so
  that the next reader of the only existing argument finds it repaired rather than gapped, and does
  not re-derive what is now settled.
- Reinstate report 03 §1.3's withdrawn consequence sentence in a sharper and honestly conditional
  form: at ZTime the validities are decidable and hence recursively axiomatizable *on hypothesis
  (H5)*, with the open question being a finitely schematic system rather than existence.
- Flag, in report 03 §1.2 itself, that the oriented-forest hypothesis its step 4 consumes is
  stronger than directed-path uniqueness, so that task 870's Lean lemma is stated at the strength
  (H5) actually needs.
- Correct report 866's finding 5 where it stands, so the (walk, time, subformula)-indexed closure
  is not relied on again for the open modals.
- Answer, in `specs/ROADMAP.md`, the four sentences that name this task as their pending
  measurement, and record the paper theorem as the citable result the task exists to produce.
- Leave every touched record consistent on the six guardrails of Phase 4's audit — above all that
  the result is conditional on (H5), is not machine-checked, is not constructive, and carries no
  finite model property.

**Non-Goals**:

- **Any Lean work whatsoever.** No `FormalSystem/` or `Tests/` path is touched (dispatch
  constraint), and no formalization of the MSO route is proposed — that is refused by standing
  ruling (Mathlib has no MSO syntax, no ω-automata, no Rabin tree theorem), and Phase 3 restates
  the refusal rather than softening it on the strength of the G1 repair.
- **Discharging (H5).** Task 870 owns the oriented-forest Saturation lemma and the universal-cover
  construction; the dispatch directs that they be cited and not reproved. No phase proves, re-proves
  or weakens them.
- **Editing task 870's own record.** The hypothesis-strength correction reaches 870's owner through
  report 03 §1.2 (which 870's description points at by name) and the roadmap annotation, not by
  mutating another task's `state.json` description. Filing a revision of 870 is a `/revise`
  operation for the conclusion stage or the user, not for this task.
- **Writing the theorem into the Typst reference manual or `docs/theorem-index.md`.** The dispatch
  says "report only"; `docs/theorem-index.md` indexes Lean declarations and this theorem is not
  one, and a `typst/chapters/p3-decidability-frontier.typ` write-up is a separate deliverable with
  its own chapter-quality gate. Phase 4 records it as a follow-up proposal instead.
- **Repairing the open-modal gap.** Finding 10's verdict is negative with the obstruction named
  (a backward ray is not a countable index), and the dispatch directs that it stop there. A repair
  would need an elementary-submodel or mosaic argument and is a research project.
- **Touching Base, Dense or RTime.** Report 03 §1.4 locates those obstructions and stays untouched.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The amendment is read as establishing L⁺ ZTime decidability unconditionally, or as machine-checked | H | M | Every added block opens by naming (H5) as undischarged and task 870 as its owner, and labels the result *paper, conditional on (H5)*. Phase 4 greps all touched records for an unconditional reading |
| (H5) never lands, or task 870 lands at its weaker stated hypothesis and does not discharge it | H | M | The conditionality is stated in every record rather than assumed away, so a failure of (H5) invalidates no record's text — it only leaves the antecedent open. The hypothesis-strength flag is propagated to both channels 870's owner reads (Phase 1 for §1.2, Phase 3 for the annotation) |
| Report 03's directory is archived mid-flight (`559` is completed and pending archival; the roadmap's own `/todo` line says 19 completed tasks are ready to archive) | M | M | Phase 1 resolves the path at execution time: the live `specs/559_.../reports/03_axiomatizability-rules-engine.md` first, then the same basename under `specs/archive/**`. Edit whichever exists; if both, the live tree wins and the discrepancy is recorded as an issue |
| A sibling task edits `specs/ROADMAP.md` concurrently (it is the single most contended file in this tree, and the roadmap's own run-order lists several in-flight tasks) | M | M | Phase 3 re-reads the file immediately before editing, makes only additive, section-local edits, and stages `specs/ROADMAP.md` by explicit file list. On a foreign commit or foreign uncommitted modification, STOP and report rather than proceeding; do not run `git-snapshot.sh` in its reverting default form under concurrency |
| `roadmap-integration.sh --regenerate` discards authored content after the `**Coverage appendix (uncovered tasks)**:` marker inside the run-order section | H | L | Phase 3 edits only above that marker, verifies by `grep` that the marker and everything below it in that section are byte-identical pre- and post-edit, and adds, removes or renames no `## ` heading |
| Phase 3 is read as licence to rewrite a **ruling**, which the roadmap states "an agent may not override" | H | M | The "Decidability before completeness" ruling's text and direction are not altered. The r.e.-versus-recursive sharpening is added as an additive clause that leaves the ruling's substance and its "Craig buys *an* axiomatization, not a natural one" caveat standing — both of which finding 9 confirms rather than contradicts |
| The G1 repair is read as reopening the refused MSO formalization | H | M | Phase 3 states explicitly that the refusal rests on Mathlib's inventory (no MSO, no ω-automata, no Rabin), which the G1 repair does not change; only the "G1 needs a paper repair first" precondition is discharged |
| The regular-model by-product is read as a finite model property | M | M | Every record that mentions it says *finitely presented, not finite*, and names the reason the fold is unsound (the fold map satisfies *forth* and fails *back*, while `plus_invariance_of_isZTime` demands `TwoWayBounded`) |
| Phase 4's gate run reports failures caused by the pre-existing `literature` extension staleness this dispatch was warned about | M | M | Attribute every failure by path. This plan touches `specs/**` only; a pre-existing failure is recorded as pre-existing, not repaired here, and not reported as this task's regression |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Phases 1, 2 and 3 touch three disjoint files
(report 03, report 866's report, `specs/ROADMAP.md`) and share no content dependency — each derives
independently from this task's own report.

### Phase 1: Amend report 03 with the G1/G2 repairs, the step reorder, the held Rabin citation, and the §1.2 hypothesis-strength flag [NOT STARTED]

**Goal**: Report 03 carries, in its own text, that G1 and G2 are repaired and how; that its §1.3
step order must be reversed and why; that Rabin's theorem is now held at `S2S` and which exact form
is used; that the withdrawn consequence sentence is reinstated conditionally on (H5); and — in §1.2
— that the hypothesis its step 4 consumes is the oriented-forest one, not directed-path uniqueness.

**Tasks**:

- [ ] Resolve the target path: `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`, falling back to the same basename under `specs/archive/**` if the directory has been archived. Record which path was used
- [ ] Read §1.2 in full, §1.3 in full including both existing amendment blocks, and §1.4's first paragraph, so the new amendment is written against the current text rather than against this plan's description of it
- [ ] Append a clearly-delimited, dated amendment block at the end of §1.3, after the existing 2026-11-05 amendment and before the `#### 1.4` heading. Open it with one sentence stating that §1.3 remains an unverified paper argument, that the repairs below are *paper* results, and that the whole chain is conditional on hypothesis (H5), owned by task 870 and not yet landed
- [ ] In that block, record the **G1 repair** as a re-justification, not a reconstruction: the construction stands, its stated justification ("state-local truth is shift-invariant") is a non-sequitur and is replaced by the compiled `PlusTruth.stab_state_only` (`PlusTruth.lean:332`) and `PlusTruth.box_global` (`:372`); the closure is indexed by *states*, which is the carrier being cut down, so each stage is countable-to-countable; the induction is quantified over **every** walk of the sub-digraph, which is the scope G1 named. Label *paper, with a compiled core*, and state that this answers the 2026-11-05 amendment's "step 1 currently has no stated justification that survives"
- [ ] In that block, record the **step reorder**: steps 1 and 2 must swap, because `FrameOver.IsRegular` (`TaskFrame.lean:1185`) bundles `saturation`, so `plus_invariance_of_isZTime` (`HistoryMorphism.lean:589`) demands Saturation of the base frame, which in the written order is the sub-digraph whose Saturation is unestablished. Record why the reorder is free: an induced sub-digraph of an oriented forest is an oriented forest, so the cited lemma applies a second time and no second cover or second invariance appeal is needed. Label *derived*
- [ ] In that block, record the **G2 repair**: the explicit new-root coding (adjoin `r`, tree edges to each component root, `Rt`/`Up`/`A_p` unary predicates, `E` recovered first-order with the two `¬Rt` conjuncts), that `Walk` needs no separate `r`-exclusion because `E` has no edge at `r`, and the one load-bearing guard — `⊑` must carry `¬Rt(meet(y, x))` or it returns spurious cross-component reachability. State that the multigraph convention is load-bearing for `Walk` (it makes the cover a *simple* tree, hence no directed 2-cycles). Label *derived*
- [ ] In that block, replace step 5's recalled citation: Rabin's theorem is **held** as Thomas 1997 Theorem 6.20 (`S2S` is decidable, attributed to Rabin 1969), with 6.19 (MSO to Muller tree automaton, effectively) and 6.18 (Rabin Basis Theorem: emptiness decidable, regular witness). State the exact form used — MSO over the full binary tree `⟨{0,1}*, S₀, S₁⟩`, decidable and effective in the sentence — and that `SωS`, Gurevich-Shelah and the Muchnik/Walukiewicz transfer are **not needed**, countable branching entering only through §6.3's explicit `1^{i₁}0⋯1^{i_l}0` embedding whose range is quantified as `P₀`
- [ ] In that block, reinstate the withdrawn consequence sentence in its sharper, conditional form: on (H5) the validity set is decidable, hence **recursive**, hence literally its own recursive axiom set — so the *existence* question is closed affirmatively and did not need Craig. State that Craig's theorem (held: Chagrov & Zakharyaschev 1997 Thm 16.10) is the instrument for the weaker r.e.-only hypothesis, which is the Base/Dense/RTime situation, and that what stays open at ZTime is a *finitely schematic* system — the `LC_n` question of §2, untouched
- [ ] In that block, sharpen the finite-model sentence: no finite model property, and the reason is that the fold by subtree type satisfies *forth* and fails *back* while `plus_invariance_of_isZTime` demands `TwoWayBounded`; but Thm 6.18 does give a **regular**-model property — every ZTime-refutable L⁺ formula is refuted on a finitely presented (automaton-generated) doubly serial oriented forest. State *finitely presented, not finite*
- [ ] Add a pointer to this task's report (`specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`) findings 1-9 for the derivations, and state that the route still reaches **ZTime only**, leaving §1.4's Base/Dense/RTime obstruction untouched
- [ ] Append a short, separately-delimited note at the end of **§1.2** recording the hypothesis-strength discrepancy: §1.2's claim glosses "oriented forest" as "directed paths between two nodes are unique", but its own step 4 uses the *undirected* tree path between `a_m` and `a'` and its unique sink, which needs the underlying undirected graph to be a forest — strictly more than directed-path uniqueness. State that a Lean lemma stated at the weaker hypothesis will not discharge what §1.3 consumes, and name task 870 as the owner. Label *derived*
- [ ] Re-read both amended regions and confirm no sentence claims §1.3 is verified or machine-checked, claims the finite model property, asserts decidability unconditionally on (H5), proposes a Lean formalization of the MSO route, or conflates the route with the landed base-language `decidableValidZTime` / `decidableDerivableZTime` (at base `Formula`, no `stab`)
- [ ] Commit, staging only the one resolved report path by explicit file list

**Timing**: 50 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path (measured this dispatch), so no suite covers it and none may be claimed; the honest covering check is `bash .claude/scripts/validate-artifact.sh <resolved-path> report` together with the `prose` row's diff read-through confirming every changed hunk is additive prose inside §1.2's and §1.3's own bounds.

**Files to modify**:

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` - append a dated amendment block at the end of §1.3 (after the existing 2026-11-05 block, before the `#### 1.4` heading) and a hypothesis-strength note at the end of §1.2; path resolved at execution time, may be under `specs/archive/**` instead

**Verification**:

- `bash .claude/scripts/validate-artifact.sh <resolved-path> report` exits 0
- Diff read-through: every changed hunk is additive prose, located either at the end of §1.2 before the `#### 1.3` heading or at the end of §1.3 before the `#### 1.4` heading; no existing sentence of §1.2, §1.3, §1.4 or either prior amendment is deleted or reworded
- The new §1.3 block's first sentence names (H5) and task 870 as the undischarged antecedent
- Each of the six recorded items (G1, reorder, G2, Rabin, Craig/existence, finite-versus-regular model) carries an evidence tier and points at this task's report
- `grep -n "Rabin" <resolved-path>` shows the new block naming Thomas 1997 Thm 6.20, and no added sentence presents Rabin's theorem as recalled
- The §1.2 note names task 870 and states the oriented-forest hypothesis explicitly

---

### Phase 2: Correct report 866's finding 5 with the negative open-modal verdict [NOT STARTED]

**Goal**: Report 866's finding 5 carries, in its own text, that its proposed (walk, time,
subformula)-indexed witness closure does not give a countable-model step, and that the obstruction
is the one its own finding 6 names.

**Tasks**:

- [ ] Read `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md` findings 5 and 6 in full, so the correction is written against the current text
- [ ] Append a clearly-delimited, dated amendment note to finding 5 (or at the end of the findings section if finding 5's bounds are not cleanly delimited) recording the correction: indexing witnesses by (walk already in the set, time, diamond subformula) does **not** yield a countable closure for `▷`/`◁`, because the induction must hold at **every** walk of the sub-digraph and the sub-digraph has uncountably many walks — which is exactly the gap finding 6 names. Label *derived*
- [ ] In that note, state the mechanism of the contrast rather than only the verdict: the L⁺ repair works because `⊡`'s quantifier class is determined by a *world state* (compiled `stab_state_only`) and `□`'s by *nothing* (compiled `box_global`), and the state carrier is what is being made countable; for `▷` the determining object is an entire backward ray (`AgreeUpTo τ σ t` is agreement at every time `≤ t`), and the backward rays of a countable oriented forest are in general of size continuum
- [ ] In that note, preserve what does survive: `▷`/`◁` still ride step 4's encoding (finding 3's `⊑` clauses, confirmed by this task's finding 4, now with the `¬Rt(meet(y, x))` guard) and still ride the cover step (finding 4). What they have **no** analogue of is the countable-model step, so L^▷ decidability at ZTime is *not* obtained
- [ ] In that note, state that a repair would need a countable-model argument of a different kind — an elementary-submodel or Hintikka-type/mosaic argument replacing the ray by a finite type — and that this is a research project, not an amendment. Add the pointer to this task's report finding 10
- [ ] Re-read the amended region and confirm nothing added asserts L^▷ ZTime decidability, and that the correction is stated as a correction rather than as a softer qualification
- [ ] Commit, staging only `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md` by explicit file list

**Timing**: 25 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this `specs/**` report path, so the honest covering check is `bash .claude/scripts/validate-artifact.sh specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md report` plus the `prose` row's diff read-through confirming the change is an additive note inside the findings section.

**Files to modify**:

- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md` - append a dated correction note to finding 5

**Verification**:

- `bash .claude/scripts/validate-artifact.sh specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md report` exits 0
- Diff read-through: the change is one additive, delimited note; no existing sentence of finding 5 or finding 6 is deleted or reworded
- The note states the verdict (no countable-model step for `▷`/`◁`), the mechanism (ray versus state as the index), and what survives (step 4's encoding and the cover step)
- No added sentence asserts L^▷ ZTime decidability or presents the verdict as a qualification rather than a correction

---

### Phase 3: Answer the four roadmap sentences that name this task as their pending measurement [NOT STARTED]

**Goal**: `specs/ROADMAP.md` states this task's verdict where the batch order is read: the MSO/Rabin
route's gaps are repaired and its citations held, the result is a paper theorem conditional on
(H5), the formalization refusal still stands on its own grounds, 870's hypothesis must be stated at
oriented-forest strength, and the "decidability before completeness" ruling's mechanism is sharpened
without its substance being altered.

**Tasks**:

- [ ] Re-read `specs/ROADMAP.md` immediately before editing: the "MSO/Rabin route reaches ZTime only" ruling, the two `## Run these next` / `## Next batches` annotations on `870` and on `878`, the "MSO decidability formalization is refused outright" entry, and the "Decidability before completeness" ruling
- [ ] Confirm, by locating the `**Coverage appendix (uncovered tasks)**:` marker, that no planned edit falls at or after it inside the run-order section. Record the marker's line number pre-edit
- [ ] Update the "MSO/Rabin route reaches ZTime only" ruling: its closing sentence currently frames this task as the pending measurement ("Making the paper argument a proof is 878: the countable-model step (gap G1) and the forest-versus-single-tree gap, with held citations"). Replace the pending framing with the verdict — both gaps repaired, Rabin held at `S2S` via Thomas 1997 Thm 6.20 (so `SωS`/Gurevich-Shelah are not needed), the theorem stated with its hypotheses — and state in the same breath that it is a **paper** theorem **conditional on (H5)**, task 870's lemma, and that it still does **not** close `Decidable (PlusValidZTime φ)` constructively, which remains Stage 1's own aim
- [ ] Update the "MSO decidability formalization is refused outright, not deferred" entry: its stated precondition ("Before any attempt at that reading, gap G1 in report 03 §1.3 needs a paper repair, which 878 owns") is now discharged. State that the refusal is **unchanged and does not rest on G1** — it rests on Mathlib's inventory (no MSO syntax, no ω-automata, no determinization of ω-automata, no Rabin tree theorem) — so the G1 repair removes a precondition without weakening the refusal
- [ ] Annotate `870` where it appears in the run-order blocks (currently "870 feeds 878's cover step"): add that 870 must state the **oriented-forest** hypothesis — the underlying undirected graph is a forest — and not merely directed-path uniqueness, because report 03 §1.2's own step 4 uses the undirected tree path and its unique sink; a lemma at the weaker hypothesis will not discharge (H5). Keep the annotation short and point at report 03 §1.2's new note and this task's report decision 7
- [ ] Add the r.e.-versus-recursive sharpening to the "Decidability before completeness" ruling as an **additive clause only**: deciding validity makes the valid set *recursive*, which is directly its own recursive axiom set, so Craig is not needed where decidability is in hand; Craig is the instrument for the r.e.-only case, which is Base/Dense/RTime. Do **not** alter the ruling's text, its direction, or its existing "Craig buys *an* axiomatization, not a natural one" caveat — finding 9 confirms that caveat rather than contradicting it, and the ruling is one an agent may not override
- [ ] Record, where the roadmap's L⁺ stage is framed, that the citable paper theorem the task exists to produce is now in hand and where it lives (this task's report, finding 7's statement and hypothesis list), together with its four negative results: no constructive procedure, no Lean `Decidable`, no elementary complexity bound, no finite model property — a *regular*-model property instead, finitely presented and not finite
- [ ] Verify no added claim is one that no check can reproduce: each cites either this task's report by path and finding, a held source by author/year/theorem, or a compiled declaration by name
- [ ] Re-run the marker check: `grep -n "Coverage appendix (uncovered tasks)" specs/ROADMAP.md` still matches and the content from that marker to the end of the run-order section is byte-identical to its pre-edit state; no `## ` heading was added, removed or renamed
- [ ] Commit, staging `specs/ROADMAP.md` by explicit file list only

**Timing**: 40 minutes

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select specs/ROADMAP.md` resolves (measured this dispatch) to two real suites, so the covering check is `bash .claude/scripts/tests/run-all.sh --only test-roadmap-generation.sh,test-engine-written-state-paths-lib.sh` plus the diff read-through and the coverage-appendix-marker grep — the precedent plan's `__FULL_SWEEP__` claim for this path is measurably wrong and is not reused.

**Files to modify**:

- `specs/ROADMAP.md` - answer the MSO/Rabin ruling's pending sentence; discharge the formalization-refusal entry's G1 precondition without weakening the refusal; annotate `870` with the oriented-forest hypothesis requirement; add the r.e.-versus-recursive clause to the "Decidability before completeness" ruling; record the paper theorem and its negative results

**Verification**:

- `bash .claude/scripts/tests/run-all.sh --only test-roadmap-generation.sh,test-engine-written-state-paths-lib.sh` exits 0 (checked by exit status, not by diffing captured stdout)
- `grep -n "Coverage appendix (uncovered tasks)" specs/ROADMAP.md` still matches, and the content from that marker to the end of the run-order section is unchanged from pre-edit
- Diff read-through: every changed hunk is additive, or replaces a now-answered pending-measurement sentence; no `## ` section heading is added, removed or renamed; the "Decidability before completeness" ruling's own text and caveat are intact with only an additive clause alongside
- The MSO/Rabin entry states the theorem is paper, conditional on (H5)/870, and does not close `Decidable (PlusValidZTime φ)` constructively
- The formalization-refusal entry states the refusal is unchanged and rests on Mathlib's inventory, not on G1
- The `870` annotation names the oriented-forest hypothesis and why directed-path uniqueness is insufficient

---

### Phase 4: Close-out verification and guardrail audit [NOT STARTED]

**Goal**: All three edited records and this task's own report are mutually consistent, every
dispatch guardrail holds across all four, and the full gate set has been run with every failure
attributed by path to something this task did not touch.

**Tasks**:

- [ ] Re-read the four records as a set: this task's report, the amended report 03 (§1.2 and §1.3), the amended report 866, and the changed regions of `specs/ROADMAP.md`. Confirm they agree on the verdict's scope (G1 and G2 repaired, order reversed, Rabin held at `S2S`, ZTime only, conditional on (H5)) and on the open-modal verdict being negative
- [ ] Audit the six guardrails across all four records: (1) nothing claims the theorem is machine-checked, Lean-verified, or constructive; (2) nothing states it unconditionally on (H5); (3) nothing claims the finite model property, and every mention of the regular-model by-product says *finitely presented, not finite*; (4) nothing proposes or reopens a Lean formalization of the MSO route; (5) nothing presents the landed `decidableValidZTime` / `decidableDerivableZTime` (at base `Formula`, no `stab`) as covering `⊡`; (6) Base, Dense and RTime are stated open with the obstruction located at report 03 §1.4
- [ ] Confirm every claim added in Phases 1-3 carries an evidence tier (compiled / held / cited / derived / paper) and that no added claim is labelled *recalled* — dispatch item (3) was to eliminate recalled citations, so a newly-introduced one would be a regression
- [ ] Run `bash .claude/scripts/validate-artifact.sh` on this task's report, on the amended report 03 (resolved path), and on the amended report 866 — all three with type `report`
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. For every failure, attribute it by path and confirm none is attributable to a file this plan touched (all under `specs/**`, where the doc-lint gate has no bearing and the task-reference lint is exempt by design). Record any pre-existing failure — including anything arising from the `literature` extension staleness this dispatch was warned about — as pre-existing, and do not repair it here
- [ ] Record the two follow-up proposals in the handoff and `.return-meta.json` `next_steps`, filed by neither this phase nor this task: (a) a `/revise` of task 870 restating its hypothesis at oriented-forest strength, since this task propagates the flag but does not mutate 870's record; (b) a separate task to write the theorem into `typst/chapters/p3-decidability-frontier.typ` as the citable chapter-level result, with its own chapter-quality gate, if the user wants it beyond the report
- [ ] Record the phase's issue-log entries via `issue-record.sh`, non-fatally, including a `kind: win` entry if the propagation ran clean and an entry for any record that needed more than an additive edit

**Timing**: 35 minutes

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Files to modify**:

- none - verification only; no file is edited in this phase

**Verification**:

- The complete gate set has been run in this dispatch and observed: `bash .claude/scripts/verify-deploy.sh`, with its result recorded and every failure attributed by path to a file outside this plan's touched set
- `bash .claude/scripts/validate-artifact.sh` exits 0 on all three reports
- All six guardrails confirmed, record by record, in the phase's own notes
- No claim added by Phases 1-3 is labelled *recalled*
- Both follow-up proposals appear in `.return-meta.json`'s `next_steps` and in the handoff `summary`

## Testing & Validation

- [ ] `validate-artifact.sh` exits 0 on this task's report, the amended report 03, and the amended report 866
- [ ] `bash .claude/scripts/tests/run-all.sh --only test-roadmap-generation.sh,test-engine-written-state-paths-lib.sh` exits 0 after the roadmap edit
- [ ] `specs/ROADMAP.md`'s coverage-appendix marker and everything below it in the run-order section are unchanged
- [ ] Every claim added to any record carries an evidence tier, and none is labelled *recalled*
- [ ] No record asserts the theorem is machine-checked, constructive, unconditional on (H5), or accompanied by a finite model property
- [ ] No record proposes a Lean formalization of the MSO route, and the standing refusal reads as resting on Mathlib's inventory rather than on G1
- [ ] Base, Dense and RTime are stated open with the obstruction at report 03 §1.4
- [ ] The full gate set has been run, with failures attributed by path and pre-existing ones recorded as such

## Artifacts & Outputs

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` — a dated §1.3 amendment (G1 repair, step reorder, G2 repair with the `⊑` guard, Rabin held at `S2S`, the conditional reinstatement of the consequence sentence, the finite-versus-regular-model sharpening) and a §1.2 hypothesis-strength note; path may resolve under `specs/archive/**`
- `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md` — a dated correction note to finding 5
- `specs/ROADMAP.md` — the MSO/Rabin ruling answered, the formalization-refusal precondition discharged without weakening the refusal, `870` annotated with the oriented-forest hypothesis requirement, the r.e.-versus-recursive clause added to the "Decidability before completeness" ruling, and the paper theorem recorded with its negative results
- A completion summary under `specs/878_lplus_ztime_decidability_paper_proof_repair/summaries/`
- No Lean file, no `FormalSystem/` or `Tests/` path, and no `.typ` file is created or modified

## Rollback/Contingency

Every change is additive markdown in three independent files, each committed in its own phase, so
rollback is per-phase and loses nothing else. This task's actual deliverable — the report — is
already landed and linked in `state.json` regardless of any phase's outcome.

- **Any single phase fails or must be undone**: revert that phase's one commit. The other two
  wave-1 phases are unaffected (disjoint files, no content dependency).
- **Report 03's directory has been archived and the path cannot be resolved**: mark Phase 1
  `[BLOCKED]` with the searched paths recorded, and complete Phases 2 and 3, whose value does not
  depend on it. The amendment can then be filed against the archived copy later.
- **A sibling task's foreign edit is observed in `specs/ROADMAP.md` or either report**: STOP,
  confirm via `git log` that the work is not this task's own, and report rather than proceeding. Do
  not run `git-snapshot.sh` in its reverting default form under concurrency; use `--no-revert` for
  a defensive checkpoint.
- **Phase 3's roadmap edit would require altering a ruling's substance rather than adding to it**:
  do not make the edit. Record the discrepancy as an issue and surface it as a `user_decision`
  candidate instead — a ruling is the user's to change.
- **Phase 4's gate run fails on something pre-existing**: record it and complete the phase on the
  attribution argument; do not repair out-of-scope failures, and do not discard uncommitted work to
  reach a green gate.
