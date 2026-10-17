# Research Report: Task #811

**Task**: 811 - Re-cut the dependency edges on the ladder/periodicity line
**Started**: 2026-10-17T05:50:00Z
**Completed**: 2026-10-17T06:14:43Z
**Effort**: ~25 minutes; no Lean probe written, no build run (the dispatch asked for neither)
**Dependencies**: None
**Sources/Inputs**:

State and task records
- `specs/state.json` — `dependencies`, `status`, `file_scope`, `parent_task` for 734, 805, 806, 807, 809, 811
- `specs/TODO.md` lines 178-186 (task 809 block), 228-232 (task 807 block)
- `specs/literature-index.json`, entry `doc_id: hodkinson_2006` (`hazard` field)
- `.claude/scripts/update-task-status.sh` (flag surface), `.claude/scripts/generate-todo.sh:415`

Landed Lean artifacts
- `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` (header, `import` line 89)
- `specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean` (`import` line 42)
- `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`,
  `closure-profile-gate-rerun.lean`, `nside-modulus-gate.lean`,
  `ladder-joint-index-refutation.lean` (`import` lines; `coh6` at `closure-profile-gate-rerun.lean:405`)
- `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean:81`,
  `backward-dual-mirror-fixture.lean:117` (namespaces `Probe719Backward`, `Probe733Mirror`)
- `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean:186,208`
  (`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`)
- `scripts/check-evidence-probes.sh:191,603,1258` (mosaic-stab-saturated wiring)

Reports
- `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/reports/01_e4-stabsaturated-mixed-germ-probe.md`
- `specs/806_set_valued_cell_quotient_index/reports/01_closure-indexed-periodicity-gate.md`

**Artifacts**:
- `specs/811_ladder_periodicity_dependency_edge_recut/reports/01_dependency-edge-recut-verdict.md` (this report)

**Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: none for this task (`dependencies: []`). The task audits other
  tasks' edges; it does not consume their output.
- **Downstream Dependents**: none declared. Tasks 809 and 807 are the subjects of the audit, not
  dependents of it.
- **Alternative Paths**: the edge set could have been left in place and task 734's hold lifted
  instead. That path is explicitly out of scope (the dispatch forbids lifting the hold) and is
  also the wrong instrument: 734's block is an external paywall, not a schedulable unit of work.

## Executive Summary

- **VERDICT, edge `809 -> 734`: NOT A REAL DEPENDENCY. DROP IT.** Task 809's adequacy scope
  consumes nothing from 734's technical contribution and nothing from the Handbook sections 734
  cannot obtain. The two lines are disjoint at every mechanically checkable level: no
  cross-reference, disjoint imports, different fixtures, different routes (R1 ladder/seam vs. R2
  mosaic), and 734's own landed finding is that its predicate is identically true, so there is no
  content to consume even in principle.
- **VERDICT, edge `807 -> 809`: NOT A SEMANTIC DEPENDENCY, BUT KEEP THE EDGE** as the declared
  serialization device. 807's test bed is `Probe719Backward`/`Probe733Mirror` and its question is
  frame-level backward closure; it reads none of 809's adequacy relation. But 807 and 809 declare
  an identical, unordered `file_scope` overlap (`scripts/check-evidence-probes.sh` plus
  `specs/evidence/seam-gluing-ray-product/`), and an unordered overlap takes an edge, not a bare
  exclusion. The edge survives with its rationale re-labelled from semantic to serialization.
- **VERDICT, edge `809 -> 805`: REAL AND ALREADY SATISFIED.** 805 is `[COMPLETED]`; its
  `ladder-joint-index-refutation.lean` is the sixth refuted index shape that 809's "the
  tuple-widening line is spent" premise rests on. No change.
- **Net effect of the recut**: 809's dependency set becomes `[805]`, which is satisfied, so 809
  becomes dispatchable with no change to 734's hold; 807 stays gated behind 809 and so stays out
  of 809's wave. The serialization the dispatch asked to preserve is preserved by exactly the
  edge that already expressed it.
- **The hold on 734 is untouched and remains correct.** Its reactivation condition is external
  (institutional access or an open release of Handbook ch. 11); nothing in this audit weakens,
  restates, or re-reads its landed probe, and nothing here is a claim that 734's remaining half
  is unnecessary — only that it is not upstream of 809.
- **The mis-filing is diagnosable, and worth recording.** The plausible origin of the `809 -> 734`
  edge is lexical proximity, not technical consumption: both tasks sit in the same evidence
  collection, both talk about `stab`, and 734's own report names "`stab` witnessing" while 806's
  gate table names "`stab` self-reference". These are different objects (see F5).

## Context & Scope

- **What was asked.** Settle three questions against landed artifacts rather than by
  re-derivation: (a) does 809's adequacy work consume anything from 734's mosaic/`StabSaturated`
  probe; (b) does it consume anything from the Handbook sections 734 cannot obtain; (c) is 807's
  edge onto 809 real. Then drop refuted edges or leave genuine ones in place, preserving the
  `check-evidence-probes.sh` serialization between 809 and 807 as an explicit edge.
- **Measured starting edge set** (`specs/state.json`, this session): `734` status `hold`,
  `dependencies [733, 805]`; `805` status `completed`, `dependencies []`; `806` status
  `completed`; `807` status `not_started`, `dependencies [809]`; `809` status `not_started`,
  `dependencies [734, 805]`, `parent_task 806`. `733` is archived
  (`specs/archive/733_backward_dual_mirror_fixture_branching_probe`). `specs/TODO.md` renders the
  same sets, so the two records agree before any change.
- **Who else depends on these three.** A sweep of every `active_projects[].dependencies` array
  for 734, 809 and 807 returns exactly two edges: `807 -> 809` and `809 -> 734, 805`. No third
  task is affected by this recut.
- **Evidence tier.** Every Lean-side claim below is from reading committed source and from grep
  over the working tree. No `lake build` and no new probe were run, per the dispatch. lean-lsp
  search was not used, so no `index`-state caveat applies; the evidence tier here is committed
  file content, which is the stronger tier for existence-and-reference questions.
- **Out of scope by instruction.** Lifting 734's hold; editing 734's probe or report; writing a
  Lean probe; touching `FormalSystem/` or `Tests/`.

## Findings

### Codebase Patterns

- **F1. No cross-reference exists, in either direction.** `grep -rn -iE
  "Probe734|StabSaturated|StabWitnessedAt|mosaic"` over every `.lean` file in
  `specs/evidence/seam-gluing-ray-product/`, excluding the two `mosaic-*.lean` files themselves,
  returns **zero** lines. The mosaic probes are referenced by nothing in the collection, and they
  reference nothing in it. Probes never import each other by the collection's own header rule, so
  import-level consumption was never possible; this grep closes the weaker textual-reference
  question too.
- **F2. The two lines import disjoint `FormalSystem` subtrees.** Measured `import` lines:
  `mosaic-stab-saturated.lean:89` and `mosaic-germ-amalgamation.lean:42` both take the whole
  `FormalSystem` root; `closure-indexed-periodicity.lean:74`,
  `closure-profile-gate-rerun.lean:188` take
  `FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer`; `nside-modulus-gate.lean:76-77`
  and `ladder-joint-index-refutation.lean:160-161` take that plus
  `...RaySummary.LadderModel`. 809's named inputs are the three `RaySummary`-importing files; the
  mosaic probes contribute no declaration into that subtree (they declare their own
  `Probe718Mosaic`/`Probe734Mosaic` namespaces and are terminal).
- **F3. 809's actual consumption list is `AnchorLayer`, and it is landed.** The declarations
  809's scope names — `anchorCells_finite`, `anchorCells_ncard_le` ("not in question, do not
  re-attack"), and the gate-8 mechanism `stab_mem_tpOf_iff` (with its sibling
  `box_mem_tpOf_iff`) — are at
  `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean:186` and `:208`, plus the
  surrounding `tpOf`/`cellAt`/`AnchorCons` layer documented in
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`. None of this is 734's; all of it is
  committed and readable now.
- **F4. 734's technical contribution is, by its own landed statement, empty content.** The probe
  header of `mosaic-stab-saturated.lean` states the outcome as "VACUOUS — decidable because
  identically true": `stabSaturated_univ` proves the landed predicate for every finite mosaic
  set, and the header says in terms that "THIS DECIDES NOTHING ABOUT R2". A predicate that is
  constantly true cannot be a semantic input to anything. The non-trivial half the probe does
  carry — `StabWitnessedAt`, SH1 witnessing on `Smix`/`Sdrop` — is a transcription of
  Caleiro-Viganò-Volpe Def. 3.6 on the **E2 Bool fixture** `Rg`, a two-state `a→a, a→b, b→b`
  graph. 809 works on the **coprime-cycle object** `Q5` with the closure product
  `ProdState Q5 chi`. Different fixture, different carrier, different route.
- **F5. "`stab` witnessing" and "`stab` self-reference" are different objects — this is the
  likely origin of the mis-filed edge.** 734's witness direction asks whether a *set of mosaics*
  contains a same-germ refuter for each of its own `⊡`-refuters; it is a closure property of a
  chosen finite set under a relation the model already decides (the probe header says the set is
  "a CONSUMER of R1's device, not an independent decision procedure"). 809's gate 8 asks whether
  a *set-valued index datum* is well-defined at all when `stab_mem_tpOf_iff` places the cell on
  both sides of its own defining equation — a fixpoint obligation at definition time, per the 806
  gate table. The first is a saturation check on a given set; the second is a definability
  obstruction for a candidate datum. Neither supplies the other.
- **F6. 809's adequacy obligation is self-contained in the 806 line.** The gap is stated inside
  809's own named input: `closure-profile-gate-rerun.lean:46-51` records that `coh6` is "LOCAL
  coherence, not realizability", imposes "NO fulfilment condition", and therefore
  "OVER-APPROXIMATES realizability". 806's report §2 names the standard repair — enlarge the
  product state by a fulfilment-flag component, a Büchi-style acceptance condition, with claim 2
  (periodicity) surviving the enlargement. The whole obligation is stated, and its repair
  sketched, in artifacts already committed and already `[COMPLETED]`.
- **F7. 807 reads none of 809.** `backward-dual-asymmetric-fixture.lean:81` declares
  `Probe719Backward` (with `step_inv_pre`/`step_inv_x`/`step_inv_post` at lines 128/131/134, the
  singleton-backward-factor machinery), and `backward-dual-mirror-fixture.lean:117` declares
  `Probe733Mirror`. Both are landed, both are 807's stated test bed, and neither is 809's. 807's
  question — whether a closed L⁺ formula's Z-validity forces a frame-level backward-closure
  condition — is a `PlusTruth`/frame-property question that does not mention a closure-indexed
  index datum, a countdown profile, or a coherence relation.
- **F8. 734's remaining half does not even touch the serialized file.** 734's probe is wired:
  `scripts/check-evidence-probes.sh` carries the entry at line 1258 of its `WIRED` array, the
  decision row at 603, and the forward pointer at 191; `git log` on the probe path shows
  `task 734 phase 1/2/4` commits (`80dd7b32b`, `fa567569e`, `d8e4317ae`), the last of which is
  the gate wiring. So although 734's `file_scope` declares
  `scripts/check-evidence-probes.sh`, its one outstanding deliverable is the Handbook acquisition
  in `specs/literature-index.json` — no remaining write to the serialized script.

### External Resources

- **E1. The Handbook sections 734 cannot obtain are R2-route sources, and 809 is not on R2.**
  The `hodkinson_2006` `hazard` field in `specs/literature-index.json` names the gap precisely:
  sections 5.10 "Mosaics" and 5.11 "Monodic fragments", with the recorded user decision stating
  "sections 5.10 ... and 5.11 ... are the ones **R2** needs" and naming the in-corpus stand-ins
  (`caleiro_2013` for 5.10, `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl` for
  5.11). 809 is on the ladder/`RaySummary` line (route R1's successor layer); its description
  carries no literature clause and names no source, in contrast to 734's explicit "LITERATURE.
  Part (2) is source acquisition; run with `--lit`". Answer to question (b): **nothing consumed.**
- **E2. Nothing else in the corpus gates 809, and 807's two sources are present.** 807 grounds
  its backward-closure condition in Thomason 1984 §4 Def. 6(2) and Caleiro-Viganò-Volpe Def. 2.5
  (Wdc); both `thomason_1984` and `caleiro_2013` have index entries. 807 therefore has no
  literature blocker of its own that this recut would expose.
- **E3. The acquisition blocker figures are carried, not re-measured.** `CARRIED-UNVERIFIED`
  (source: `specs/literature-index.json` `hodkinson_2006.hazard`, re-measured there 2026-10-09 by
  task 734): publisher preview 3 pages / 51,937 bytes, byte-identical to the corpus PDF; DOI
  `10.1016/S1570-2464(07)80014-0` paywalled. This audit deliberately did not re-run the
  acquisition attempt — the dispatch forbids lifting the hold, and re-measuring a paywall is not
  this task's question.

### Recommendations

Prioritised. Owner of 1-3 is this task's implementation dispatch.

1. **Drop the `809 -> 734` edge.** `update-task-status.sh` has `--depends-on-add` but no
   removal counterpart (`grep -cE "depends-on-(remove|rm|del|drop)"` over the script returns
   `0`), so the sanctioned route is the direct `dependencies[]` edit the task description already
   authorises. Targeted, append-safe form — it rewrites only task 809's `dependencies` array and
   touches no other field:

   ```bash
   jq '(.active_projects[] | select(.project_number==809) | .dependencies) |= map(select((. == 734) | not))' \
     specs/state.json > specs/state.json.811.tmp && mv specs/state.json.811.tmp specs/state.json
   ```

   The `select((. == 734) | not)` form is deliberate: `CLAUDE.md`'s jq-safety section records that
   a bare `!=` is escaped to `\!=` through the harness and fails to parse.
2. **Keep the `807 -> 809` edge, and record why.** It is the only expression of the
   `scripts/check-evidence-probes.sh` + `specs/evidence/seam-gluing-ray-product/` serialization
   between the two, which the dispatch requires to survive as an explicit edge. Its rationale is
   now scheduling, not semantics; that re-labelling belongs in this report, not in a state.json
   field (there is none for edge rationale).
3. **Regenerate `specs/TODO.md`** with `bash .claude/scripts/generate-todo.sh` after the edit.
   `generate-todo.sh:415` renders `dependencies` straight out of `state.json`, so 809's
   TODO block should go from `- **Dependencies**: Task 734, Task 805` to
   `- **Dependencies**: Task 805`, and 807's block should stay `- **Dependencies**: Task 809`.
   Verify both lines after regeneration; that pair of lines is the acceptance check for
   "state.json and TODO.md agreeing".
4. **Do not add any compensating edge for 734** (owner: future scheduler, not this task). 734's
   wiring into the serialized script is already committed (F8), so its outstanding half collides
   with nothing. If its hold is ever lifted and it is re-dispatched for the acquisition half, that
   dispatch writes `specs/literature-index.json` only. The `specs/state.json` collision noted in
   the dispatch's SCHEDULING clause (tasks 751 and 784) is a separate matter and applies to this
   task's own cycle, not to 809's.
5. **For the 809 dispatch itself** (owner: 809): the adequacy relation's inputs are
   `AnchorLayer.lean`'s `tpOf`/`cellAt`/`stab_mem_tpOf_iff`/`box_mem_tpOf_iff` and the three
   `RaySummary`-importing probes. 734's report and probe remain readable regardless of its hold
   and are worth a read for F5's distinction, but reading a committed artifact needs no
   dependency edge — that is the general principle this recut turns on.

## Decisions

- **D1. No `specs/state.json` write in this research dispatch.** The edge mutation is this task's
  deliverable, but it is an implementation action, and `specs/state.json` is live orchestrator
  state with other agents active in this session. Writing it from a research dispatch risks
  clobbering a concurrent orchestrator write. The exact commands are given in Recommendations 1
  and 3 so the implement phase can apply them mechanically.
- **D2. The `807 -> 809` edge is kept even though the semantic question is answered "no".** A
  refuted semantic rationale is not sufficient grounds to drop an edge that is also carrying a
  file-territory serialization. Dropping it would put two tasks that both write
  `scripts/check-evidence-probes.sh` into one wave; `batch-orchestration-guardrails.md` requires
  an edge rather than a bare exclusion for an unordered overlap.
- **D3. Settled against artifacts, not by re-derivation.** The `809 -> 734` verdict rests on four
  independent mechanical observations (F1 no cross-reference, F2 disjoint imports, F4 the
  predicate is identically true by the probe's own header, E1 the missing sections are R2's), not
  on a judgment about whether mosaics "feel" related to ladder adequacy.
- **D4. Nothing in 734's probe or report was weakened, restated, or re-read as weaker than it
  states.** The vacuity of `StabSaturated` is quoted from 734's own landed header, which asserts
  it three times and explicitly forbids reading `stabSaturated_univ` as positive R2 evidence.
  Independence here is a consequence of what 734 already says about itself, not a reinterpretation
  of it.
- **D5. Did not re-measure the paywall.** See E3; marked carried rather than silently presented
  as fresh.

## Risks & Mitigations

- **Risk: dropping `809 -> 734` is read as "734's remaining half is unnecessary".** It is not —
  734's acquisition half still gates R2's promotion on textual grounds, exactly as its hazard
  record says. *Mitigation*: stated in the Executive Summary and D4; the hold is untouched and its
  reactivation condition is unchanged.
- **Risk: a future scheduler puts 734 and 809/807 in one wave once the hold lifts.** *Mitigation*:
  F8 measures that 734's wiring into `scripts/check-evidence-probes.sh` is already committed, so
  its outstanding deliverable writes only `specs/literature-index.json`. If that ever changes, the
  overlap takes a fresh edge at that time — not a pre-emptive edge now, which is what created this
  pathology.
- **Risk: the `jq` edit replaces an array wholesale and drops a field.** *Mitigation*:
  Recommendation 1's form uses `|=` on the single `dependencies` array of the single selected
  project, not `.artifacts = [...]`-style wholesale assignment, which
  `.claude/rules/state-management.md` prohibits. Verify with a diff of 809's and 807's objects
  before and after.
- **Risk: `TODO.md` is hand-edited instead of regenerated.** *Mitigation*: Recommendation 3 names
  `generate-todo.sh`; `state-management.md` forbids editing `TODO.md` directly for status or
  dependency changes.
- **Risk: 809 is dispatched and discovers a dependency this audit missed.** *Mitigation*: the
  audit's negative claims are bounded by what it measured — no textual reference, disjoint
  imports, disjoint fixtures, and the missing sections being R2's. If 809's own research turns up
  a consumption, the edge can be re-added with `--depends-on-add='[734]'`, which is the cheap
  direction of the error; the expensive direction is the one this task is fixing.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This dispatch wrote no Lean and ran no proof
  attempt; the dispatch states that no new Lean probe is required and that reading existing
  probes is the expected method.

## Context Extension Recommendations

- **Topic**: when a task-dependency edge is semantic and when it is a file-territory
  serialization device.
- **Gap**: `context/patterns/batch-orchestration-guardrails.md` establishes that an unordered
  `file_scope` overlap takes an edge rather than a bare exclusion, and
  `context/reference/state-management-schema.md` defines `dependencies` and `file_scope` as
  separate fields — but nothing records that a single `dependencies` entry can be carrying either
  rationale, that `state.json` has no field distinguishing them, or that conflating the two is how
  a serialization edge inherits a semantic edge's block. That conflation is exactly what stranded
  two tasks behind an externally-blocked `[HOLD]` for a whole batch run here.
- **Recommendation**: a short subsection in `batch-orchestration-guardrails.md` stating that an
  edge added for serialization should have its rationale recorded in the dependent task's
  description (the only durable free-text field), and that a task whose block is *external* (a
  paywall, a vendor, a user decision) must not be used as a serialization anchor, because its
  block propagates to every successor regardless of what they consume.

## Appendix

Commands run this session (all read-only; results are in Findings, not duplicated here)
- `jq` over `specs/state.json` for the five task objects, and a sweep of every
  `active_projects[].dependencies` array for 734/809/807
- `jq -r '.entries[] | select(.doc_id=="hodkinson_2006")'` over `specs/literature-index.json`
- `grep -rn -iE "Probe734|StabSaturated|StabWitnessedAt|mosaic"` over
  `specs/evidence/seam-gluing-ray-product/*.lean`, excluding the two `mosaic-*.lean` files
- `grep -n "^import"` over the eight probes named in Sources/Inputs
- `grep -rnE "theorem (stab_mem_tpOf_iff|box_mem_tpOf_iff)|anchorCells_(finite|ncard_le)"` over
  `FormalSystem/`
- `grep -n "mosaic-stab-saturated" scripts/check-evidence-probes.sh`;
  `git log --oneline -3 -- specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`
- `grep -cE "depends-on-(remove|rm|del|drop)" .claude/scripts/update-task-status.sh` -> `0`
- `sed -n` reads of the 806 report (§2, §7 gate table, Decisions/Recommendations), the 734 report,
  the `mosaic-stab-saturated.lean` header, `closure-profile-gate-rerun.lean:36-60`, and
  `specs/TODO.md:176-200`

Issue log
- One `issue` (class `dependency-modeling`, severity `costly`) recording the mis-filed edge and
  its cost: two never-dispatched successors behind an external block for a batch run.
- One `win` (class `evidence-quality`, severity `none`) recording that the audit settled against
  committed artifacts with no probe and no build.
