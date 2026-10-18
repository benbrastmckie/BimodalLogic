# Implementation Plan: Task #819

- **Task**: 819 - Research-first: choose the presentation of a ladder cell that supports a positive factorization lemma, or settle the direction negatively
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: None in state (`dependencies: []`). Context: 761 (parent; stays `[BLOCKED]`; this task edits its record and its dependency edges, never its plan), 806/809/815 (the set-valued rounds; untouched), 763 (the lift; untouched)
- **Research Inputs**: specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md
- **Artifacts**: plans/01_ladder-cell-presentation-decision.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round made the decision this task exists for, on the merits and against all four
obligations: presentation (a), the set-valued per-state datum, in the sharpened form "the MAXIMUM
`certAdm`-certified subset `D` of the finite carrier `Q × ClType φ × K`", with the realization
theorem the fibre equation `cellAt … (q, c, n) = {T | (q, T, κ(c, n)) ∈ D}` and the factorization
lemma a corollary of it, never its hypothesis. Presentation (b), a parameter-coupled tuple stated
alone, is dominated on every row, incomplete as a presentation (a tuple class carries no types),
and barred by the dispatch's hard constraint; it is reported, not proposed. The round also found
two things the record did not have: the certified chains of record (`coh`/`cohBi` demand `pend`
at both endpoints) are region-interior and never the object projection of an `Rlad` history —
compiled this round as a 69-line prototype (`exists_idle_of_rlad_ray`,
`no_rlad_ray_of_pending_forever`, 0 sorry, axioms at most `[propext, Quot.sound]`) — and the
counter quotient `K` any computable datum needs is forced in SHAPE to the refuted six-coordinate
body, but as a CARRIER COORDINATE whose parameters are OUTPUTS of a pumping lemma, not an index.
The real open problem is named: the COUNTER-LIFT LEMMA (obligations (2) and (3) jointly), with two
hazards that are the first gates a successor must run. A negative outcome was not reached and the
branch is stated: if the lemma fails, no computable per-ladder-state datum exists in either
presentation and the ladder route closes on evidence.

This plan does no proof work on the open problem. It lands the decision where the next dispatch
reads it: (1) the compiled finding is promoted from the task directory to a wired evidence probe
so the region-interior fact is gated and cannot rot; (2) the counter-lift lemma is filed as its
own research-first task, with the dependency edge declared on the realization record (761) so the
block is visible rather than implicit, and 761's record is amended to inherit the decision;
(3) `specs/ROADMAP.md`, the RaySummary README's "(W): what landed and what did not", and the
source-store guidance note `ladder-counter-observables.md` each carry the decision in their own
register (batch ordering; the authority's narrative; the gate-and-rule note); (4) the complete gate
set runs and the summary closes the task. Definition of done: the guard reports one more wired
probe compiling; the successor task exists with 761 depending on it; every one of the three
records says the presentation is chosen, says what the open problem is, and states no tuple index
as a candidate; nothing under `FormalSystem/*.lean` or `Tests/` is touched.

**What this plan does NOT do.** It does not attempt, state, or sketch in Lean the counter-lift
lemma, `LadderCons`, `ladderRealized`, the class relation `R_K`, the idle-extended `cohBi`, or the
maximum-certified construction — every one of those is the successor's, gated first. It does not
compile the derived arithmetic of the report's section 2 (the forward window `|L - n| ≤ c + j`,
the backward constraint `n ≥ c - 1`, the region-doubling inequality): those are the successor's
first gates and are recorded in the guidance note as DERIVED, paper-level, with no theorem
claimed. It does not re-run or touch the three earlier negatives or any gate verdict (gate 8
stays SIDESTEPPED, gates 1, 2 NOT ADDRESSED, 3 CARRIED, 9 OPEN). It does not re-cost or re-plan
761 and does not edit 761's plan file. It does not redeploy `.claude/`.

### Research Integration

- **Recommendation 1 (adopt (a) in the maximum-certified form; record it so 761 inherits it)**:
  Phases 2 (761's record and the edge), 3 (ROADMAP), 4 (README), 5 (guidance note) each carry the
  decision in the register of the record they edit; the Lean-facing statement sketch (report
  section 8) is quoted as a SKETCH, never pinned, in every one of them.
- **Recommendation 2 (file the counter-lift lemma as its own research-first record, gated
  before any sufficiency attempt)**: Phase 2 files it through the sanctioned writer, with the
  gate table the report names (gates 1, 2, 9 both halves, the gap-shift gate, the short-idle
  gate, on a fixture with a product period of at least four) written into the description, and
  adds the `761 -> new` edge.
- **Recommendation 3 (rebuild the relation and certificate for the ladder before the semantic
  step)** is the successor's work and is named in its description as its positive half; nothing
  of it is built here.
- **Recommendation 4 (amend the plan-of-record wording for 761)**: the wording "over `cohBi`,
  realizability label-level" lives in `specs/ROADMAP.md` (the Run-these-next line, the Stage 1
  line, the 761 bullet); Phase 3 rewrites it to "over the idle-extended `cohBi` on the carrier
  `Q × ClType φ × K`; the label-level results are region-interior and compose only through the
  counter-lift lemma", and the Adequacy bullet's "the semantic step (d) is what remains" to
  "(2), (3) jointly — the counter-lift lemma — then (d)".
- **Recommendation 5 (never state a tuple index; record the factorization lemma for `K` as a
  corollary with parameters as outputs; update the guidance note)**: Phase 5 adds the "carrier
  coordinate versus index" distinction beside the parameter-origin rule and the sentence that the
  rule is satisfied by construction when the parameters are the pumping lemma's own; Phase 6 greps
  every artifact of this task for a stated tuple index.
- **Recommendation 6 (keep the negative branch live)**: the successor's description admits the
  negative outcome as complete and forbids a weakened same-named substitute; the ROADMAP and
  README paragraphs say the same.
- **Finding 1 (region-interior; compiled)**: Phase 1 promotes the prototype so the finding is
  wired; Phases 3-5 state it in prose with the probe named by path.
- **Finding 2 (`K` forced in shape; carrier coordinate, not index)** and **Finding 3 (exactness by
  the maximum certified set; Route A unnecessary)**: recorded in Phases 3-5; the README paragraph
  says in one sentence why Route A is not entered (the decision record the roadmap asked for is
  the research report, and its verdict is that `Real` is itself certified and maximal).
- **Context Extension Recommendations (three)**: all three land in Phase 5, at the source-store
  path, additive to the file's current working-tree state.
- **Tactic survey**: the three prototype theorems are already closed; Phase 1 changes no proof
  and adds only the `#print axioms` lines the collection keeps.

### Prior Plan Reference

No prior plan for this task. Calibration: the 806 round's Phase 1 ("Promote the Periodicity
Prototype to the Seventeenth Wired Probe", one hour: `git mv`, header rewrite, decision row, one
`WIRED` entry) is the exact shape of this plan's Phase 1 and ran to plan; the 815 round's Phase 3
(a scoped `specs/ROADMAP.md` rewrite with enumerated regions and a diff read-through) is the shape
of Phase 3 and ran to plan with one recorded deviation this plan pre-empts (a ninth grep hit in a
region not on the list — reviewed, not silently rewritten); the 757 round's Phase 4 (filing
successor records through `state-write.sh` then `manage-topics.sh set`, re-reading
`next_project_number` immediately before each write) is the shape of Phase 2's filing step. The
815 plan also recorded that `lean-challenge-snapshot.sh --check` exits 71 without a manifest and
that the sanctioned substitute is a declaration-by-declaration diff against the Challenge block;
Phase 6 reuses that.

### Roadmap Alignment

The dispatch carries no `roadmap_path` and no `roadmap_flag`, so the mandated snapshot/update wrap
phases are not generated. `specs/ROADMAP.md` was read in full at plan time because it names this
task in five places as the one open edge gating 761 and describes 761 as "THE critical path, once
819 lands"; leaving those paragraphs standing would dispatch 761 straight into the unproved
counter-lift lemma. Phase 3 rewrites exactly those regions. This is a content decision recorded
here, with the 815 precedent (the roadmap's own stated purpose is "batch ordering and the rulings
that gate it", and the decision changes both); it is not a `user_decision`. Items advanced: the
Stage 1 critical path (presentation chosen; the gate on 761 relocated to the counter-lift lemma);
the ruling against any tuple index; the Route A decision record. Items NOT advanced and said so:
gate 8, gates 1, 2, 3, 9, obligations (2), (3), (d).

## Goals & Non-Goals

**Goals** (the identifier set equals the three `theorem` declarations in `## Lean Challenge
Statements`; all live in the promoted probe
`specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`, namespace `Probe819`, and
are PINNED — already compiled by the research round, re-verified byte-unchanged modulo whitespace
at the end of this task; no new theorem is proved by this plan):
- `count_pending_step`
- `exists_idle_of_rlad_ray`
- `no_rlad_ray_of_pending_forever`

Non-Lean goals:
- The probe is wired (guard entry, decision row, header in the collection's convention, three
  `#print axioms` lines) and the guard reports every wired probe compiling.
- A research-first successor task for the counter-lift lemma exists in `specs/state.json` with
  the gate table and the negative-outcome clause in its description; 761 depends on it; 761's
  description and `records/761-amendment.txt` carry a dated amendment naming the decision.
- `specs/ROADMAP.md`, the RaySummary README and the source-store `ladder-counter-observables.md`
  each record: (a) chosen in the maximum-certified form; (b) dominated/incomplete/barred and not
  proposed; `K` a carrier coordinate, never an index; the counter-lift lemma the open problem on
  which (a)'s viability rests; the negative branch and what it would take; Route A not entered.

**Non-Goals**:
- Any Lean statement of `LadderCons`, `ladderRealized`, `ladderCons_localRun`, a class relation
  on `K`, an idle-extended `cohBi`, a maximum-certified construction, or any same-named weaker
  substitute; hence no `LadderCons` without the `box`/`stab` clause.
- Any tuple index stated as a candidate, at any parameters; any seventh coordinate; any gate run
  on `K` as an index.
- Compiling the derived arithmetic of report section 2, or either hazard gate; both are the
  successor's.
- Any complexity claim or upper bound (every figure in every artifact is a count); any added
  finiteness (`anchorCells_finite`, `anchorCells_ncard_le` untouched); any Buchi/MSO lemma cited
  in place of a proof; Route A.
- Any edit under `FormalSystem/**/*.lean`, `Tests/`, `docs/`, or the deployed `.claude/` mirror;
  any edit to 761's plan, to the 806/809/815 artifacts, or to the archived 757 spec.
- Redeploying `.claude/` (`deploy-headless.sh`): the deployed copy of the guidance note falls one
  edit behind the source store until the operator's next deploy; that is the rule's intended
  state, not a defect to hand-patch.
- Committing in the source-store repository (`~/.config/nvim`): outside this task's commit scope;
  the edit is left in that repository's working tree, as the previous round's edit to the same
  file already is, and the summary says so.
- Dispatching, re-costing or re-planning 761 or 763.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Finding 2 is read as tuple-widening and a reader files `K` as an index candidate | H | M | Every record edit (Phases 3-5) states the distinction in the same words: the index is `D`, `D` has no parameter, `K` is a coordinate of the carrier `D` is computed over, its parameters are outputs of the counter-lift lemma; the successor's description forbids stating a tuple index; Phase 6 greps every artifact for `ladderIndex`-style declarations. |
| The promoted probe is read as a factorization lemma, a cell index, or progress on obligation (d) | H | M | The header's "What this does NOT say" section says it mentions no `cellAt`, `HitPresented`, `PlusValidZTime`, `LadderCons` or `ladderRealized`; Phase 1's verification greps for exactly those names outside header prose. |
| The ROADMAP edit overreaches — reorders Stage 2-4, removes still-true gate sentences | M | M | Phase 3 enumerates the regions it may touch and the sentences it must keep verbatim (gate 8, 3, 1-2, 9; `anchorCells_ncard_le`; R2; "one coordinate"); its verification is a diff read-through against that list with before/after `grep -c` counts. |
| The README paragraph collides with the generated inventory block or with the (W) narrative's probe ordinals | M | L | The paragraph is inserted after the fifteenth-probe paragraph and before "The permanent computability witnesses", names the probe by PATH and never by ordinal (the collection's later probes are recorded in the roadmap, not the README, so no ordinal is safe), and Phase 4's verification confirms no hunk lies inside `<!-- BEGIN GENERATED` .. `<!-- END GENERATED -->` and that `check-module-invariants.sh`'s C9 still passes. |
| The source-store file has an UNCOMMITTED modification in its own repository (confirmed at plan time: `git -C ~/.config/nvim status --short` shows ` M` on it, last commit `d68e7f771`) and an edit from HEAD would revert the previous round's mechanism-(6) text | H | M | Phase 5 reads the WORKING-TREE file, edits additively, and verifies before/after that mechanism (6), the sixth gate row and the strengthened modulus clause are still present; it never checks the file out from HEAD. |
| `next_project_number` shifts before Phase 2 files (other live sessions file tasks) | M | M | Phase 2 re-reads `.next_project_number` immediately before the `state-write.sh` call and never hardcodes a number (820 at plan time is a hypothesis); the received number is read back from the write and used for the edge, the amendment, and Phase 3's roadmap lines. |
| `update-task-status.sh --depends-on-add` refused: the operation:target pair does not resolve to 761's current status (`blocked`), or the write-time cycle check fails | M | L | Run with `--dry-run` first; the pair MUST replay 761's own current status (STATUS-NO-OP RESTRICTION in the script header); a cycle refusal is a real finding — report it, do not route around it with a hand `jq` write. |
| `state-write.sh` mutex (`specs/.scope-lock`) held by a concurrent writer; it fails CLOSED | M | M | Retry with bounded backoff (3 attempts, 30 s apart); on persistent refusal mark Phase 2 `[PARTIAL]` with the exact filter recorded for resume. |
| The final `full` gate surfaces pre-existing deploy staleness (dispatch records `core`, `memory` stale) or concurrent-sibling inventory drift (`INV`) | M | H | Record as pre-existing, out-of-scope in the phase's verification notes and on the issue log as a gate collision; the remedy is `deploy-headless.sh`, never a hand patch under `.claude/**`; this task adds no module, so an `INV` failure cannot be its own. |
| A reader takes the maximum-certified enumeration figure as a bound | M | M | Wherever `2^(|Q| · 2^|cl φ| · |K|)` or any figure appears in a record edit it is called a count of candidates; Phase 6 greps the edited records for "bound"/"complexity" in the new hunks. |
| The guard's printed total is misread (`42` when `WIRED` has 41) | L | M | `WIRED` holds 40 entries and `WIRED_REPO` 1 at plan time; Phase 1 adds one `WIRED` entry, so the guard prints `all 42 wired probe(s) compile`; both counts re-measured before editing. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4, 5 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 6 | 3, 4, 5 |

Phases within the same wave can execute in parallel. Phases 2, 4 and 5 touch disjoint files
(`specs/state.json`/761's record; the RaySummary README; the source-store note) and each describes
what Phase 1 landed; Phase 3 needs the successor's task number from Phase 2 for the roadmap lines;
Phase 6 observes all of them.

### Phase 1: Promote the No-Pending-Forever Prototype to a Wired Evidence Probe [COMPLETED]

**Goal**: Move `prototype/no-pending-forever-ray.lean` into the evidence collection, rewrite its
header to the collection's probe convention, add the three `#print axioms` lines the collection
keeps, register it in `scripts/check-evidence-probes.sh`, and confirm the guard compiles it from
its new, tracked path — so the region-interior finding is held in place by the rot guard.

**Tasks**:
- [x] `git mv specs/819_ladder_cell_presentation_design_decision/prototype/no-pending-forever-ray.lean specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` (the `prototype/` directory becomes empty and disappears; do not recreate it).
- [x] Rewrite the header block only (nothing at or below `import`): a one-paragraph capitalised verdict line (NO FORWARD `Rlad` RAY IS PENDING FOREVER; hence every `Realizes`-chain of the certificate rounds is region-interior and is the object projection of no `Rlad` history), then `## What was asked` (the presentation decision's need to know whether the certified realizability of record is ladder realizability), `## What is settled` (the three theorems, each named with its statement in one line and its axiom profile: `count_pending_step` `[propext]`; the other two `[propext, Quot.sound]`), `## What this does NOT say` (not a factorization lemma, a cell index, a `LadderCons`, a `ladderRealized`, or any part of one; no declaration mentions `cellAt`, `HitPresented`, `PlusValidZTime`; nothing about the backward direction — `gPast_isPath` stands; `c₀ + 1` is a count of steps and nothing else; the composition of regions across idle runs under `Count`/`Drift` is the successor's obligation, not discharged here), and the `Compile:` line updated to the new path. Keep the existing docstrings on the three theorems.
- [x] Append, after `end Probe819`, three lines: `#print axioms Probe819.count_pending_step`, `#print axioms Probe819.exists_idle_of_rlad_ray`, `#print axioms Probe819.no_rlad_ray_of_pending_forever`.
- [x] In `scripts/check-evidence-probes.sh`, add a boxed decision-row comment block directly below the `certificate-sufficiency-dovetailing` block (same `# <path> | <decision>` column layout, wrapped at the same width), naming the three theorems; the decision it holds in place — the certified chains of record are REGION-INTERIOR (both `coh` endpoints pending), so label-level sufficiency transfers to a region segment and never to a ladder history, and the ladder datum must compose regions through idle runs under `Count`/`Drift` (the counter-lift lemma, named as the open problem); the presentation decision it accompanies (set-valued datum over `Q × ClType φ × K`; no tuple index); what it withholds (no `cellAt`, no `LadderCons`/`ladderRealized`, no bound, every quantity a count, no finiteness added, no gate verdict changed); the axiom profile.
- [x] Add `"seam-gluing-ray-product/no-pending-forever-ray"` as the last entry of the `WIRED` array (after `certificate-sufficiency-dovetailing`).
- [x] `bash -n scripts/check-evidence-probes.sh`; compile the moved file through the guard.
- [x] Record on the issue log anything that arose, or attest in the phase notes that nothing did.
- [x] Commit the move, the header, the axiom lines and the registration as one green sub-step via `bash .claude/scripts/git-commit-scoped.sh` (explicit file list: the moved file, the removed prototype path, `scripts/check-evidence-probes.sh`).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the prototype has 69 lines, three `theorem` declarations and zero `#print axioms` lines; `WIRED` has 40 entries and `WIRED_REPO` 1 before this phase, so the guard prints `all 42 wired probe(s) compile` after it (all measured at plan time with `wc -l`, `grep -c '^theorem'`, `grep -c '^#print axioms'`, and `sed -n '/^WIRED=(/,/^)/p' scripts/check-evidence-probes.sh | grep -c '^  "'`). The axiom profile `[propext]` / `[propext, Quot.sound]` / `[propext, Quot.sound]` is CARRIED from the research report (confirmed there on a scratch copy, not in the committed file); the three appended `#print axioms` lines are what confirm it in-file. Re-measure every figure before editing.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` exiting 0 with zero errors and zero warnings, together with `bash -n scripts/check-evidence-probes.sh` exiting 0 and `bash scripts/check-evidence-probes.sh` exiting 0 reporting 42, is the complete covering check — the phase moves one standalone probe that no library module imports and adds one array entry to the guard that reads it, so it has no blast radius beyond those two files.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` - new path (via `git mv`); header rewritten to the probe convention; three `#print axioms` lines appended
- `specs/819_ladder_cell_presentation_design_decision/prototype/no-pending-forever-ray.lean` - removed by the move
- `scripts/check-evidence-probes.sh` - one decision-row comment block, one `WIRED` entry

**Verification**:
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` exits 0 after the commit (the guard's TRACKED test); the old prototype path is absent from `git ls-files`.
- The guarded single-file compile exits 0: three `#print axioms` lines, `count_pending_step` at `[propext]`, the other two at `[propext, Quot.sound]`; zero `sorry` (`bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file); `grep -c native_decide` 0; `grep -c "^axiom "` 0.
- The three theorem statements match `## Lean Challenge Statements` byte for byte modulo whitespace (no statement or proof is edited by this phase; `git diff -M --stat` on the rename shows changes confined to the header and the appended lines).
- `bash scripts/check-evidence-probes.sh` exits 0 and reports `all 42 wired probe(s) compile`, this probe `PASS`; run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`.
- `grep -n "cellAt\|HitPresented\|PlusValidZTime\|LadderCons\|ladderRealized\|ladderIndex" specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` matches only header prose under `## What this does NOT say`, never a declaration.
- `git diff -- scripts/check-evidence-probes.sh` adds only `#` comment lines inside the new block plus exactly one `WIRED` line; the decision row cites theorem names and the probe filename, never a task number (C9).

---

### Phase 2: File the Counter-Lift Lemma Record and Declare the Edge on the Realization Record [COMPLETED]

**Goal**: Create the research-first successor task for the counter-lift lemma through the
sanctioned writer, make 761 depend on it so the block is visible rather than implicit, and amend
761's own record so it inherits the decision — nothing else in `specs/state.json` moves.

**Tasks**:
- [x] `source .claude/scripts/lib/common.sh`; use this dispatch's `session_id` for every write.
- [x] Immediately before the write, `next=$(jq '.next_project_number' specs/state.json)`; never hardcode the number. Create the task via `bash .claude/scripts/state-write.sh '<creation filter>' --session-id "$session_id" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg desc "$desc" --argjson fs '<file_scope array>' --regen-todo`, where the filter is `commands/task.md` Step 6's Create Task Mode object extended with `"dependencies": []`, `"file_scope": $fs`, `"topic": "decidability"`, `"task_type": "lean4"`, `"status": "not_started"`, `"project_name": "ladder_counter_lift_lemma_gated"`, and `.next_project_number = <next+1>`. `file_scope` (files only, never a directory root): `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` (new), `scripts/check-evidence-probes.sh`, `specs/ROADMAP.md`, `FormalSystem/Metalogic/Decidability/RaySummary/README.md`. Then `bash .claude/scripts/manage-topics.sh set <number> decidability` (hard error on failure; print the remediation line).
- [x] The description `$desc` is written in full, in the register of the 757 records (statement shape, not prose goal), and carries, in this order: RESEARCH-FIRST, GATED: no sufficiency attempt before the gate table below is compiled. WHY: presentation (a) is chosen (the maximum `certAdm`-certified subset `D` of `Q × ClType φ × K`; realization = the fibre equation; factorization a corollary) and its viability rests on this lemma, which is unproved; see the decision report at `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md` sections 2, 6, 7 and the wired probe `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` (the certified chains of record are region-interior). STATEMENT SHAPE (not pinned): soundness — every `RladAdm` history projects to a bi-infinite chain over `Q × ClType φ × K` whose consecutive counter classes satisfy a decidable `R_K` and whose consecutive types satisfy the idle-extended `cohBi` link (the two `pend` conjuncts of `coh` replaced by the `Count`/`Drift` class clauses); completeness (the lift) — every such chain through `(q, κ(c, n))` lifts to an `RladAdm` history through `(q, c, n)` with the same type sequence; consequence, by induction on `stab`-nesting depth — `cellAt` is constant on `K`-classes, the factorization lemma for `K` recorded as a COROLLARY with `K`'s parameters `(T, P, B)` as OUTPUTS of the first repeat of the realizable-type iteration on the object-closure product, never exhibited from the object or the letters. GATE TABLE, compiled BEFORE any sufficiency attempt, on a fixture with a product period of at least four: gates 1, 2 and 9 (n-side, both halves: separation when `2(c + j) + 1 <` the product period and `m` is not a multiple of it; collision when `m` is a multiple), the gap-shift gate (lengthening the current region by `P` lowers the gap at every earlier position by `P` unless `n` is pumped in step, which the previous idle run must absorb), and the short-idle gate (`L_{k+1} ≤ 2 L_k + j_k + 1`; a class-level chain must carry enough of `(L_k, j_k)` exactly, which may force `T` above the formula-derived depth and must be computed, not guessed). FIRST COMPILE TARGETS, each currently DERIVED and no theorem: the forward window `|L - n| ≤ c + j` for the next region's length, the backward constraint `n ∈ [c - 1, c + 2s + 1]` when the region started `s` steps ago, the region-doubling inequality. WHAT TRANSFERS and is not re-proved: `prodPreN_eventually_periodic`, `profR_period_three`, `exists_dovetail_chain`, `realizes_of_certAdm_cohBi` (region segments), `gap_le_region_age`, `region_start_beyond_depth`, `second_region_any_length`, `exists_idle_of_rlad_ray`. OBLIGATION (4): `certStab` must be rebuilt per `(q, κ)` (`stab_mem_tpOf_iff` is per cell); gate 8 stays SIDESTEPPED until a `stab`-bearing fixture is run. HARD CONSTRAINTS: no tuple index stated as a candidate at any parameters — `K` is a carrier coordinate; no seventh coordinate; no complexity claim or upper bound, every quantity a count (the candidate enumeration over `Finset (Q × ClType φ × K)` is a count of candidates); no finiteness added (`anchorCells_finite`, `anchorCells_ncard_le` untouched); the `box`/`stab` acceptance clause never dropped; zero debt (no Buchi/MSO lemma cited in place of a proof); Route A not entered (the decision record is the report above). A NEGATIVE OUTCOME IS A COMPLETE RESULT: if either hazard is a genuine seventh mechanism resistant to every `K` of the forced shape, no computable per-ladder-state datum exists in either presentation; report `[BLOCKED]`-to-closed for the ladder route with the obstruction compiled, never a weakened same-named substitute. WHAT THIS UNBLOCKS: `ladderRealized`/`LadderCons` (the realization record), then the lift `not_plusValidZTime_iff_ladderRefutes` and `Decidable (PlusValidZTime φ)`. NOT COSTABLE: sized by an open problem; no figure is invented.
- [x] Add the edge, direction rule observed (761 GAINS the dependency): `bash .claude/scripts/update-task-status.sh <op> 761 <target> "$session_id" --depends-on-add="[<number>]" --dry-run` with an operation:target pair that resolves to 761's CURRENT status `blocked` (the script's STATUS-NO-OP RESTRICTION; a pair that would transition 761 is refused — read the script header's `map_status()` note to pick the replay pair), then the same call without `--dry-run`. The script runs `validate-state.sh --deep`'s cycle check itself; a refusal is reported, never routed around. Then, if `.claude/scripts/orchestrate-cycle-plan.sh` is present, confirm drain: `bash .claude/scripts/orchestrate-cycle-plan.sh --dry-run --state-file specs/state.json <number> 761 763`.
- [x] Amend 761's record: prepend to its `description` (via `state-write.sh`, filter `(.active_projects[] | select(.project_number == 761)).description |= ($amend + "\n\n" + .)`) the paragraph `AMENDED 2026-10-18 (presentation chosen): the cell presentation is (a), the set-valued per-state datum — the maximum certAdm-certified subset D of Q × ClType φ × K, with ladderRealized the fibre equation and the factorization lemma for K its corollary; no tuple index is to be stated at any parameters (K is a carrier coordinate whose parameters are outputs of the counter-lift lemma). The realization theorem now waits on the counter-lift lemma (obligations (2) and (3) jointly), filed as task <number>, gated before any sufficiency attempt; the label-level results of the certificate rounds are region-interior (wired probe specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean) and compose only through that lemma. Route A is not entered. See specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md.` — and prepend the same paragraph (newest first, matching the description's order) to `specs/761_ladder_realization_theorem/records/761-amendment.txt`.
- [x] `bash .claude/scripts/generate-todo.sh`; `bash .claude/scripts/validate-state.sh specs/state.json --deep` exits 0. *(deviation: altered — `validate-state.sh --deep` exits 1 before AND after this phase on the pre-existing Check 12 counter failure (`next_project_number` below the archive's stray max 1054; no archived row carries 820); its D3 cycle check PASSES after the edge add. Recorded on the issue log; not repaired here.)*
- [x] Record on the issue log anything that arose (a mutex retry, a refused pair, a shifted number), or attest that nothing did.
- [x] Commit (explicit file list: `specs/state.json`, `specs/TODO.md`, `specs/761_ladder_realization_theorem/records/761-amendment.txt`).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: `next_project_number` is 820 at plan time and the new task receives it — a hypothesis, since other live sessions file tasks; confirm by re-reading immediately before the write and by reading the number back from the written row (`jq '.active_projects[] | select(.project_name == "ladder_counter_lift_lemma_gated") | .project_number'`). 761's `dependencies` is `[760, 775, 805, 806, 819]` at plan time; after this phase it is that list plus the new number, nothing removed.

**Tier Justification**: every touched path lies under `specs/**`, so the honest covering check is `bash .claude/scripts/validate-state.sh specs/state.json --deep` exiting 0 plus `jq empty specs/state.json` and a diff read-through of `git diff -- specs/TODO.md specs/761_ladder_realization_theorem/records/761-amendment.txt` (plan-format.md's `__FULL_SWEEP__` sub-case (a)); the edge add additionally carries the script's own write-time cycle refusal.

**Files to modify**:
- `specs/state.json` - one new `active_projects` row; `next_project_number` advanced by one; 761's `dependencies` gains one number; 761's `description` gains the dated amendment paragraph; nothing else
- `specs/TODO.md` - regenerated by `generate-todo.sh`, never hand-edited
- `specs/761_ladder_realization_theorem/records/761-amendment.txt` - the dated amendment paragraph prepended

**Verification**:
- `jq '.active_projects[] | select(.project_name == "ladder_counter_lift_lemma_gated") | {project_number, status, task_type, topic, dependencies, file_scope}' specs/state.json` shows `not_started`, `lean4`, `decidability`, `[]`, the four-path `file_scope`; `bash .claude/scripts/manage-topics.sh list` includes `decidability` for the number.
- `jq '.active_projects[] | select(.project_number == 761) | .dependencies' specs/state.json` is the plan-time list plus the new number; `.status` is still `blocked`; `.description` begins `AMENDED 2026-10-18 (presentation chosen)`.
- `bash .claude/scripts/validate-state.sh specs/state.json --deep` exits 0 (no cycle, no malformed row).
- `grep -c "AMENDED 2026-10-18" specs/761_ladder_realization_theorem/records/761-amendment.txt` is 1 and the 2026-10-12 entry is still present.
- `git diff -- specs/TODO.md` shows the new task row and 761's amended line and dependency list, and no other task's line changed (a concurrent writer's change is noted, not reverted).
- `grep -n "ladderIndex\|index candidate" ` over the new description matches only sentences forbidding a tuple index.

---

### Phase 3: The Roadmap Verdict: Presentation Chosen, Gate Relocated to the Counter-Lift Lemma [COMPLETED]

**Goal**: Rewrite the regions of `specs/ROADMAP.md` that name this task as the open gate on 761 and
describe 761 as dispatchable once 819 lands, so the next `/orchestrate` run reads the decision and
the new gate — and nothing else in that file.

**Tasks**:
- [x] Read `specs/ROADMAP.md` in full first; `grep -n "819" specs/ROADMAP.md` and compare the hit list against the five regions below — a hit outside them is reviewed, not silently rewritten. The regions, by their current opening text: (A) the `## Run these next` code block's two lines `/orchestrate 819` and `/orchestrate 761 --hard --lit`; (B) the paragraph beginning `` `761` declares five edges ``; (C) in `## Next batches`, the Stage 1 lines for `819` and `761`; (D) in the Stage 1 narrative, the Adequacy bullet's heading sentence `**Adequacy — SUFFICIENCY RETURNED (\`815\`); the semantic step, obligation (d), is what remains.**` and, in the same bullet, the sentence `what remains of adequacy is the semantic step (obligation (d))` together with the sentence that follows it on Route B/Route A; (E) the `761` bullet beginning `- **761 — the ladder realization theorem**`.
- [x] (A): replace the two lines with `/orchestrate <number>` (comment: the counter-lift lemma, research-first, gated — the gate on 761; a refutation there closes the ladder route) and `/orchestrate 761 --hard --lit` (comment: the ladder realization theorem over the idle-extended `cohBi` on the carrier `Q × ClType φ × K`, once the counter-lift lemma lands).
- [x] (B): rewrite to: 761 declares six edges (`760`, `775`, `805`, `806`, `819`, `<number>`); five are discharged or about to be (819 lands the presentation decision); the one still open is `<number>`, the counter-lift lemma, which gates the dispatch. Then the decision in two sentences: presentation (a) chosen in the maximum-certified form; (b) dominated, incomplete as a presentation (a tuple class carries no types) and barred — reported, not proposed; and the ruling: no tuple index is to be stated at any parameters, `K` is a carrier coordinate whose parameters are outputs of the lemma. Keep the infrastructure-repairs sentence (`810`, `813`/`814`) verbatim.
- [x] (C): replace the `819` line with the `<number>` line (comment as in (A)); change 761's comment to "over the idle-extended `cohBi` on `Q × ClType φ × K`; waits on `<number>`"; leave the 763 line and everything after it untouched.
- [x] (D): change the heading sentence to `**Adequacy — SUFFICIENCY RETURNED (\`815\`); PRESENTATION CHOSEN (\`819\`); what remains is (2), (3) jointly — the counter-lift lemma — then the semantic step (d).**`; after the `anchorCells_ncard_le` sentence of that bullet (kept verbatim) add one paragraph: the presentation decision (index = `D`, the maximum `certAdm`-certified subset of `Q × ClType φ × K`; `ladderRealized` = the fibre equation; the factorization lemma for `K` a corollary with parameters as outputs), Finding 1 (the certified chains of record are region-interior — `coh`/`cohBi` require `pend` at both endpoints and no forward `Rlad` ray is pending forever, wired probe `no-pending-forever-ray.lean` — so the label-level results compose only through the counter-lift lemma), Finding 3 in one sentence (`Real` is itself certified given constancy of `cellAt` on `K`-classes and every certified set lies inside it, so the maximum certified set is `Real` and is computable by enumeration — a count of candidates; this is the decision record the Route A sentence asked for, and its verdict is that Route A is not entered), the two hazards named as the successor's first gates, and the negative branch (a seventh mechanism closes the ladder route on evidence). Change `what remains of adequacy is the semantic step (obligation (d))` to `what remains of adequacy is the counter-lift lemma — obligations (2) and (3) jointly — and then the semantic step (obligation (d))`.
- [x] (E): rewrite the 761 bullet: still `[BLOCKED]`; five of six edges discharged once 819 completes; it now waits on `<number>` alone; it inherits presentation (a), the idle-extended `cohBi` on the carrier `Q × ClType φ × K`, the `certStab`-per-`(q, κ)` rebuild, and the label-level qualification with its region-interior reading. Keep the 763 bullet verbatim.
- [x] Keep verbatim, and count before and after: the gate-8 SIDESTEPPED sentence, the gate-3 CARRIED and gates-1/2 NOT ADDRESSED sentences, the gate-9 OPEN sentence, "A gate probing one coordinate certifies one coordinate only", the `anchorCells_ncard_le` sentence, the declined R2 sentence, "The tuple-widening line is spent; no seventh coordinate is to be proposed", and the closing guardrails paragraph. Do not touch Stages 2-4, the coverage appendix, the "Not on the critical path" paragraph, or the two-risks table. The `last edited` date already reads 2026-10-18.
- [x] Record on the issue log anything that arose, or attest that nothing did.
- [x] Commit (explicit file list: `specs/ROADMAP.md`).

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: `grep -n "819" specs/ROADMAP.md` returns 7 hits at plan time (lines 16, 17, 29, 30, 49, 50, 200-201), all inside regions (A), (B), (C) and (E); region (D) contains no `819` hit and is located by its quoted opening text. Re-run the grep before editing; a hit outside the five regions is reviewed, not rewritten.

**Tier Justification**: every touched path lies under `specs/**`, so the honest covering check is the `prose` row's diff read-through of `git diff -- specs/ROADMAP.md` against the five enumerated regions with the before/after `grep -c` counts of the kept sentences (plan-format.md's `__FULL_SWEEP__` sub-case (a): `specs/**` is the task-reference lint's own exempt tree).

**Files to modify**:
- `specs/ROADMAP.md` - the five regions enumerated above, nothing else

**Verification**:
- `git diff -- specs/ROADMAP.md` read through hunk by hunk: every hunk lies inside one of the five regions.
- Before/after `grep -c` agree for: `SIDESTEPPED`, `CARRIED`, `NOT ADDRESSED`, `gate 9`, `one coordinate`, `anchorCells_ncard_le`, `R2`, `tuple-widening line is spent`.
- `grep -n "819" specs/ROADMAP.md` after the edit matches only sentences saying the decision landed (never "the one edge still open" or "once 819 lands").
- `grep -n "<number>" specs/ROADMAP.md` matches the Run-these-next line, the Next-batches line, region (B) and region (E).
- `grep -n "carrier coordinate\|no tuple index" specs/ROADMAP.md` matches the new text; `grep -n "bound" ` over the new hunks matches nothing that is not "no bound"/"a count".
- `grep -n "idle-extended" specs/ROADMAP.md` matches the 761 lines and bullet.

---

### Phase 4: The README Paragraph: the Successor Design Is Chosen [COMPLETED]

**Goal**: Add to the RaySummary README's "(W): what landed and what did not" one paragraph that
says the successor design the three earlier probe paragraphs leave "not chosen here" is now
chosen, names the new wired probe by path and what it settles, and records what is withheld —
without touching the generated inventory block, the verdict table, or any earlier paragraph.

**Tasks**:
- [x] Read the section `### (W): what landed and what did not` in full. *(deviation: altered — the quoted fifteenth-probe paragraph lies under `## Evidence`, not `### (W)`; the insertion point was located by the quoted text as the plan directs, so the paragraph sits where the plan intends.)* Locate the fifteenth-probe paragraph (begins `A fifteenth wired probe, \`specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean\``, ends `citing \`LadderModel.lean\` and re-proving nothing.`) and the paragraph that follows it (begins `The permanent computability witnesses are`). Insert the new paragraph between them.
- [x] The paragraph, in the section's register and WITHOUT a probe ordinal (the collection's later probes are recorded in the roadmap and this narrative's ordinals do not extend to them): **The successor design is chosen.** The presentation of a ladder cell is a set-valued per-state datum over a quotient, in the sharpened form: `D`, the MAXIMUM `certAdm`-certified subset of the finite carrier `Q × ClType φ × K`, where `K` is a quotient of the two ladder counters; the realization theorem is the fibre equation (`cellAt` at `(q, c, n)` equals the fibre of `D` at `(q, κ(c, n))`), and the factorization lemma for `K` is its corollary, never its hypothesis. A parameter-coupled tuple index stated alone is dominated, incomplete as a presentation (a tuple class carries no types) and barred by the refutation record; no tuple index is stated at any parameters. `K`'s SHAPE — threshold, residue and clipped gap on each counter — is forced by the compiled mechanisms, but `K` is a coordinate of the carrier `D` is computed over, not an index: its parameters are outputs of the first repeat of the realizable-type iteration on the object-closure product, which is the candidate the sixteenth probe's header reserved. Then the wired probe `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` and what it settles: `Count true true` forces `c' + 1 = c`, so a forward `Rlad` ray reaches an idle state within `c₀ + 1` steps (`exists_idle_of_rlad_ray`; `count_pending_step`; the contrapositive `no_rlad_ray_of_pending_forever`); since the certificate rounds' `coh`/`cohBi` require `pend` at both endpoints, every certified `Realizes`-chain is region-interior and is the object projection of no `Rlad` history — label-level sufficiency transfers to a region segment and the ladder datum still owes the composition of regions through idle runs under `Count`/`Drift`. Exactness: `Real` is itself certified given constancy of `cellAt` on `K`-classes and every certified set lies inside it, so the maximum certified set is `Real`, computable by enumeration (a count of candidates), and Route A is not entered. The open problem on which the choice rests, stated by name: the COUNTER-LIFT LEMMA — soundness (every `RladAdm` history projects to a class-level chain) and completeness (every class-level chain lifts), obligations (2) and (3) jointly, with two hazards (gap shift under pumping; short idle runs cannot absorb a deadline shift) as its first gates; its failure would close the ladder route on evidence, because both presentations need it. Withheld: no `LadderCons`, `ladderRealized` or factorization lemma stated; no bound of any kind, every quantity a count; no finiteness added, `anchorCells_finite` and `anchorCells_ncard_le` untouched; the acceptance clause never dropped; `certStab` per `(q, κ)` is a rebuild the successor owes; gate 8 still SIDESTEPPED. Axioms `[propext]` on `count_pending_step`, `[propext, Quot.sound]` on the other two, citing `RunLayer.lean` and re-proving nothing.
- [x] Do not edit the three earlier "the successor design not chosen here" sentences (true of those probes), the verdict table, `## What it holds`, or anything inside `<!-- BEGIN GENERATED: inventory ... -->` .. `<!-- END GENERATED -->`.
- [x] Record on the issue log anything that arose, or attest that nothing did.
- [x] Commit (explicit file list: `FormalSystem/Metalogic/Decidability/RaySummary/README.md`).

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the README's generated inventory block spans lines 28-47 at plan time and the fifteenth-probe paragraph ends immediately before `The permanent computability witnesses` (located by text at plan time); confirm both by `grep -n` before editing — the insertion point is found by the quoted text, never by line number.

**Tier Justification**: the touched file is a deploy-consumer-tree markdown outside `specs/**` (plan-format.md's `__FULL_SWEEP__` sub-case (c)), so the covering check is `bash .claude/scripts/verify-deploy.sh --only-gate 4` exiting 0 together with `bash .claude/scripts/check-task-references.sh --quiet` exiting 0 and a diff read-through confirming the single hunk lies between the two quoted paragraphs and outside the generated block; `check-module-invariants.sh`'s C9 and INV are observed in Phase 6.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one paragraph inserted in `### (W): what landed and what did not`, nothing else

**Verification**:
- `git diff -- FormalSystem/Metalogic/Decidability/RaySummary/README.md` is one added hunk; its first line follows `citing \`LadderModel.lean\` and re-proving nothing.` and its last line precedes `The permanent computability witnesses are`; no hunk touches lines between `<!-- BEGIN GENERATED` and `<!-- END GENERATED -->`.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0; `bash .claude/scripts/verify-deploy.sh --only-gate 4` exits 0 (the paragraph cites filenames and theorem names, never a task number).
- `grep -c "successor design not chosen here\|successor design is not chosen here\|successor design not chosen" FormalSystem/Metalogic/Decidability/RaySummary/README.md` is unchanged before and after; `grep -c "The successor design is chosen" ` is 1.
- `grep -n "no-pending-forever-ray" FormalSystem/Metalogic/Decidability/RaySummary/README.md` matches the new paragraph; `grep -n "bound\|complexity" ` over the new hunk matches only "no bound of any kind".
- `git diff --stat -- FormalSystem/` names `README.md` only — no `.lean` file.

---

### Phase 5: The Guidance Note at the Source Store: Counters, Region-Interior Scope, Carrier Coordinate [COMPLETED]

**Goal**: Land the research round's three Context Extension Recommendations in
`ladder-counter-observables.md` at its SOURCE-STORE path, additively to the file's current
working-tree state, and rewrite its closing "direction on record" paragraph to the decision — so
the next index-shaped proposal is checked against the decision as well as the six mechanisms.

**Tasks**:
- [x] Resolve the target: `source_dir` for the `lean` extension in `/home/benjamin/Projects/BimodalLogic/.claude-extensions.json` is `/home/benjamin/.config/nvim/agent-system/extensions/lean`; the file is `<source_dir>/context/project/lean4/domain/ladder-counter-observables.md`. Confirm `git -C /home/benjamin/.config/nvim status --short -- agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` shows ` M` (the previous round's mechanism-(6) edit is uncommitted there) and `grep -c "(6)" ` on the WORKING-TREE file is non-zero before editing. Never check the file out from HEAD; never edit the deployed mirror `.claude/context/project/lean4/domain/ladder-counter-observables.md`.
- [x] Add a section `## What the counters constrain` after `## The structural fact that makes every "clip the counters" proposal fail`: one COMPILED item — no forward `Rlad` ray is pending forever; an idle state is reached within `c₀ + 1` steps (`exists_idle_of_rlad_ray`, `no_rlad_ray_of_pending_forever`, wired probe `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean`) — and three items marked DERIVED (read off `Count`/`Drift`; paper-level; no theorem; the counter-lift record's first compile targets): the forward window — from pending `(q, c, n)` the next region starts after an idle run of `j ≥ 1` states with length `L` where `|L - n| ≤ c + j`, so `n` enters the cell only through these windows; the backward constraint — if the current region started `s` steps ago then `n ∈ [c - 1, c + 2s + 1]`, so `n < c - 1` has only pending-forever pasts (`gPast_isPath`) and a large gap forces a far region start; the region-doubling inequality `L_{k+1} ≤ 2 L_k + j_k + 1` (and its backward reading), exhibited by no probe and the first candidate for a seventh mechanism. Close the section by naming the two hazards (gap shift under pumping; short idle runs cannot absorb) as the gates to run before any sufficiency attempt.
- [x] Add one paragraph, placed after mechanism (6)'s closing paragraph and before `## The six-part falsification gate`, headed in bold **The region-interior scope of the certificate rounds' relations**: `coh` and `cohBi` of the countdown-profile and certificate probes require `pend` at BOTH endpoints (`step ∧ pend x ∧ pend y ∧ …`), so `certBiInf` and `Realizes` quantify over all-pending bi-infinite object walks; by the compiled item above no such walk is the object projection of any `Rlad` history; hence `realizes_of_certAdm_cohBi` is sufficiency for the interior of one region and transfers to the region segments of a ladder history, and the composition of regions through idle runs — the two `pend` conjuncts dropped in favour of `Count`/`Drift` clauses on the counter classes — is what the ladder datum still owes.
- [x] In `## The parameter-origin rule`, add a final bullet **Carrier coordinate versus index**: a tuple of this shape is a coordinate `K` of the carrier `Q × ClType φ × K` over which a set-valued datum `D` is computed, and `D` — not `K` — is what factors `cellAt`; `K`'s parameters are outputs of the counter-lift lemma (the first repeat of the realizable-type iteration on the object-closure product), and when they are, the three clauses above are satisfied by construction rather than exhibited; stating `K` as an index of cells at any parameters is the refuted claim and is not to be filed.
- [x] In `## What is still open`, replace the closing paragraph (`The direction on record for a successor is a different presentation of a cell …`) with: the direction is CHOSEN — presentation (a), `D` the maximum `certAdm`-certified subset of `Q × ClType φ × K`, realization the fibre equation, factorization a corollary; the open problem on which it rests is the counter-lift lemma (soundness and completeness of the class-level `Count`/`Drift` relation over the carrier), gated by gates 1, 2, 9 and the two hazards before any sufficiency attempt; `certStab` must be rebuilt per `(q, κ)`; a seventh mechanism resistant to every `K` of the forced shape would close the ladder route for both presentations; no tuple index is to be stated. Keep the paragraph's "no weakened same-named substitute" sentence.
- [x] Verify the file still carries mechanism (6), the sixth gate-table row and the strengthened modulus clause (`grep -c` before and after agree). *(deviation: altered — the source-store gate's TARGET is the nvim repository root `/home/benjamin/.config/nvim`, not `.../agent-system` (no deploy tree there, exit 2); with the right target gate 3 reported the one stale `line_count` (233 -> 287) this phase's additions caused, so `generate-context-line-counts.sh --write` was run as the lint's named remedy — one field in `agent-system/extensions/lean/index-entries.json`, source-store working tree, uncommitted there like the note; gates 3,4 then PASS.)*
- [x] Do NOT commit in `/home/benjamin/.config/nvim` (outside this task's commit scope; the operator's repository); record on the issue log that the edit lives in that working tree beside the previous round's, and attest anything else that arose.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the working-tree file at the source store is 19036 bytes at plan time, byte-identical to the deployed mirror, and modified relative to its own repository's HEAD (`d68e7f771`); after this phase it is longer, still carries every mechanism-(6) sentence, and the deployed mirror is unchanged (confirm with `diff -q`, which now reports a difference — the expected post-edit state until the next deploy).

**Tier Justification**: the touched file is a source-store markdown outside `specs/**` (plan-format.md's `__FULL_SWEEP__` sub-case (b)), so the covering check is `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system` (explicit TARGET; the bare form would run both gates' SKIP branch in this consumer repo) exiting 0, plus a diff read-through (`git -C /home/benjamin/.config/nvim diff -- agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`) confirming every hunk is additive prose or the one replaced closing paragraph.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` - the `## What the counters constrain` section, the region-interior paragraph, the carrier-coordinate bullet, the rewritten closing paragraph (source store, per source-store-deploy-boundary.md; never the deployed `.claude/` mirror)

**Verification**:
- The source-store gate subset above exits 0.
- `grep -c "(6)" `, `grep -c "letter-FREE pattern" `, `grep -c "CLOSURE carves out" ` agree before and after on the working-tree file.
- `grep -n "What the counters constrain\|Carrier coordinate versus index\|region-interior\|counter-lift" ` on the file matches the four additions; `grep -n "DERIVED" ` marks each of the three derived items; `grep -n "no-pending-forever-ray" ` matches the compiled item.
- `grep -n "The direction on record for a successor is a different presentation" ` matches nothing; `grep -c "weakened same-named\|same-named weaker" ` is at least 1.
- `diff -q .claude/context/project/lean4/domain/ladder-counter-observables.md <source file>` reports a difference (deployed mirror untouched, source store ahead); `git status --short` in THIS repository shows no change under `.claude/`.

---

### Phase 6: The Complete Gate Set, Summary, Return [COMPLETED]

**Goal**: Discharge the complete gate set on the task's whole edit set, write the summary with the
decision, the open problem, the successor's number, the carried-figure notes and the issue-log
attestation, and return `implemented` with 761 still `[BLOCKED]` in state and depending on the
successor.

**Tasks**:
- [x] Run every command under **Verification** below, checking each exit status, never only its output; detached long runs use a bounded waiter per `context/patterns/bounded-build-waiter.md`.
- [x] Diff the three Goal declarations' statements in the promoted probe against `## Lean Challenge Statements` declaration by declaration; attempt `bash .claude/scripts/lean-challenge-snapshot.sh --check 819 .` first and record its exit (71 without a manifest is expected; the declaration diff is the recorded substitute).
- [x] Sweep every artifact this task wrote (the probe header, the guard decision row, the roadmap hunks, the README paragraph, the guidance note hunks, the successor description, 761's amendment) for a stated tuple index, a bound or complexity claim, a dropped acceptance clause, a Buchi/MSO citation in place of a proof, or any `LadderCons`/`ladderRealized` declaration; report the grep results. *(deviation: altered — the `^def ladderIndex` sweep matches five PRE-EXISTING pinned definitional bodies of the refuted candidates inside the four refutation probes, untouched by this task and kept on purpose; reported, not acted on. `lean-challenge-snapshot.sh --check` exit 71 (no manifest); the declaration diff agrees modulo whitespace.)*
- [x] Write `specs/819_ladder_cell_presentation_design_decision/summaries/01_ladder-cell-presentation-decision-summary.md` per summary-format.md: the decision in the three-part form (presentation (a) in the maximum-certified form, (b) dominated/incomplete/barred and reported not proposed, `K` a carrier coordinate with parameters as outputs); Finding 1 with the probe path and its three theorems and axiom profile; Finding 3 and why Route A is not entered; the counter-lift lemma named as the open problem with its two hazards and the gate table, and the successor's task number; the negative branch and what it would take; the edge declared on 761 and 761's amendment; the three record edits; the carried-figure note (every verdict read from an earlier probe's header rather than re-run is named as such); the check actually run in place of the challenge snapshot; gate 8 SIDESTEPPED, gates 1, 2, 3, 9 as carried; the guidance-note edit's location in the source-store working tree, uncommitted there by design; and an explicit attestation of the issue-log entries made in every phase.
- [x] Commit the summary; return.

**Timing**: 1.5 hours

**Depends on**: 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the guard prints `all 42 wired probe(s) compile` (41 `WIRED` + 1 `WIRED_REPO` after Phase 1); the probe has three `#print axioms` lines; `N` in the `git diff --stat HEAD~N` check below is this task's own commit count at run time, counted then, not predicted here.

**Files to modify**:
- `specs/819_ladder_cell_presentation_design_decision/summaries/01_ladder-cell-presentation-decision-summary.md` - the implementation summary (new)
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set — every command's exit status is checked, never only its output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` exits 0: three `#print axioms` lines (`[propext]`; `[propext, Quot.sound]`; `[propext, Quot.sound]`), zero errors, zero warnings.
- `bash -n scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-evidence-probes.sh` exits 0 reporting `all 42 wired probe(s) compile`, this probe `PASS`; detached, bounded waiter.
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` exits 0; `git ls-files specs/819_ladder_cell_presentation_design_decision/prototype/` is empty.
- `bash scripts/check-module-invariants.sh` exits 0, detached with a bounded waiter — C9 in particular (the README paragraph and the guard's decision row cite filenames and theorem names, never a task number); an `INV` failure on a generated block this task did not touch is recorded as pre-existing sibling drift, not repaired here.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached per `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op success, since no library `.lean` file changes, but mandatory before the return.
- Lean Final Verification Stage over the probe: `bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file; the vacuous-definition grep (`def .* := True`, `:= trivial`, `:= Unit`) matches nothing; `grep -c "^axiom "` 0; `grep -c native_decide` 0; `grep -c maxRecDepth` 0.
- `git diff --stat HEAD~N -- FormalSystem/ Tests/ docs/` (N = this task's commit count) names only `FormalSystem/Metalogic/Decidability/RaySummary/README.md`; no `.lean` file under `FormalSystem/`, nothing under `Tests/` or `docs/`.
- `grep -rn "^theorem ladderRealized\|^structure LadderCons\|^theorem ladderCons_localRun\|^def ladderIndex" FormalSystem/ Tests/ specs/evidence/` matches nothing; `grep -rn "ladderRealized\|LadderCons" specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` matches only header prose.
- `grep -n "PlusTruthAt\|tpOf\|cellAt\|anchorCells\|WorldHistory\|HitPresented\|PlusValidZTime" specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` matches nothing outside header prose.
- `jq '.active_projects[] | select(.project_number == 761) | {status, dependencies}' specs/state.json` shows `blocked` and the successor's number in `dependencies`; `bash .claude/scripts/validate-state.sh specs/state.json --deep` exits 0.
- The three Goal statements, extracted from the probe, agree with their Challenge-block statements modulo whitespace; `bash .claude/scripts/lean-challenge-snapshot.sh --check 819 .` attempted first and its exit recorded (ADVISORY: a drift finding is investigated; a genuinely wrong recorded statement blocks the phase and is raised, never silenced by editing this plan's block).
- `bash .claude/scripts/verify-deploy.sh` exits 0 (pre-existing deploy staleness of `core`/`memory`, if reported, is recorded as out-of-scope with the `deploy-headless.sh` remedy named, never hand-patched).
- `bash .claude/scripts/validate-artifact.sh specs/819_ladder_cell_presentation_design_decision/summaries/01_ladder-cell-presentation-decision-summary.md summary` exits 0; `bash .claude/scripts/validate-artifact.sh specs/819_ladder_cell_presentation_design_decision/plans/01_ladder-cell-presentation-decision.md plan` exits 0.
- `git status --short` shows no modified file outside the union of this plan's `Files to modify` sets plus the task directory's own `.return-meta.json`/`issues.jsonl`/`handoffs/` and the orchestrator-owned `specs/TODO.md`/`state.json`/`events.jsonl`; nothing under `.claude/` is modified.

## Lean Challenge Statements

The three `theorem` declarations are the Goals and carry `sorry` bodies. All three are PINNED: their
signatures are copied verbatim from the compiled prototype at plan time (69 lines, 0 sorry,
compiled clean by `lake env lean` in the research round, axioms `[propext]` on the first and
`[propext, Quot.sound]` on the other two — CARRIED from the report's `#print axioms` on a scratch
copy; Phase 1's appended `#print axioms` lines confirm them in-file). No new theorem is proved by
this plan; the block exists so a later drift of a pinned statement is a diff against it. The block
type-checks standalone against `RaySummary/RunLayer.lean` (`Rlad`, `Count`, `Drift`); `Rlad step
pend t x y` unfolds to `step ∧ (idle source → c = 0) ∧ Drift ∧ Count`, and `h.2.2.2` is its `Count`
component, which is what `count_pending_step` reads. **This block was compiled through `lake env
lean` at plan time: exit 0, three `declaration uses 'sorry'` warnings and no other diagnostic.**

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer

open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe819

theorem count_pending_step {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (t : ℤ)
    (x y : Q × ℕ × ℕ) (h : Rlad step pend t x y) (hx : pend x.1 = true) (hy : pend y.1 = true) :
    y.2.1 + 1 = x.2.1 := sorry

theorem exists_idle_of_rlad_ray {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (t : ℤ)
    (f : ℕ → Q × ℕ × ℕ) (hf : ∀ i, Rlad step pend t (f i) (f (i + 1))) :
    ∃ i, i ≤ (f 0).2.1 + 1 ∧ pend (f i).1 = false := sorry

theorem no_rlad_ray_of_pending_forever {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (t : ℤ) (f : ℕ → Q × ℕ × ℕ) (hp : ∀ i, pend (f i).1 = true) :
    ¬ ∀ i, Rlad step pend t (f i) (f (i + 1)) := sorry

end Probe819
```

## Testing & Validation

- [x] The promoted probe compiles through `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` with exit 0, zero errors, zero warnings, three `#print axioms` lines at most `[propext, Quot.sound]`.
- [x] Zero `sorry` in the probe (`lean-sorry-census.sh` 0); no `axiom`, `native_decide`, `maxRecDepth`, vacuous definition.
- [x] The three pinned Goal signatures are byte-unchanged modulo whitespace from the Challenge block.
- [x] `bash scripts/check-evidence-probes.sh` exits 0 reporting `all 42 wired probe(s) compile`; `WIRED` has 41 entries.
- [x] The successor task exists (`not_started`, `lean4`, `decidability`, four-path `file_scope`); 761 depends on it and is still `blocked`; `validate-state.sh --deep` exits 0; 761's description and `records/761-amendment.txt` carry the 2026-10-18 amendment.
- [x] `specs/ROADMAP.md`'s diff lies entirely inside the five enumerated regions and keeps every listed sentence verbatim; the successor's number appears in Run-these-next, Next-batches, region (B) and region (E).
- [x] The README diff is one hunk between the two quoted paragraphs, outside the generated block; C9 and `check-task-references.sh --quiet` pass.
- [x] The source-store guidance note carries the four additions, still carries mechanism (6), and passes `verify-deploy.sh --skip-slow --only-gate 3,4 <agent-system root>`; the deployed mirror and `.claude/**` in this repository are untouched.
- [x] No artifact of this task states a tuple index, a bound or complexity claim, a `LadderCons`/`ladderRealized` declaration, or a Buchi/MSO citation in place of a proof (grep sweep reported).
- [x] `bash scripts/check-module-invariants.sh`, `bash .claude/scripts/check-task-references.sh --quiet` and `bash .claude/scripts/verify-deploy.sh` each exit 0 (pre-existing staleness/drift recorded, not repaired).
- [x] Full `lake build` exits 0 (expected no-op: no library `.lean` file changes).
- [x] `git diff --stat` over `FormalSystem/`, `Tests/`, `docs/` across this task's commits names only the RaySummary README.
- [x] `lean-challenge-snapshot.sh --check 819 .` attempted and its outcome recorded; on exit 71 the declaration-by-declaration diff is the recorded substitute (advisory).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` — the promoted wired evidence probe (namespace `Probe819`, three theorems, header in the collection's convention, three `#print axioms` lines), moved from the task directory's `prototype/`.
- `scripts/check-evidence-probes.sh` — one decision-row comment block and one `WIRED` entry (41 entries; the guard prints 42).
- `specs/state.json` — the counter-lift lemma successor task (`ladder_counter_lift_lemma_gated`, research-first, gated, `lean4`, `decidability`); 761's `dependencies` extended by its number; 761's `description` amended; `next_project_number` advanced by one.
- `specs/TODO.md` — regenerated.
- `specs/761_ladder_realization_theorem/records/761-amendment.txt` — the 2026-10-18 amendment prepended.
- `specs/ROADMAP.md` — the five regions rewritten to the decision and the relocated gate.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — one paragraph in `### (W): what landed and what did not`.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` — the counters section, the region-interior paragraph, the carrier-coordinate bullet, the rewritten closing paragraph (source store; left in that repository's working tree).
- `specs/819_ladder_cell_presentation_design_decision/plans/01_ladder-cell-presentation-decision.md` — this plan.
- `specs/819_ladder_cell_presentation_design_decision/summaries/01_ladder-cell-presentation-decision-summary.md` — the implementation summary.

## Rollback/Contingency

- **Per phase**: each phase edits one to three files and commits on its own green sub-steps through `.claude/scripts/git-commit-scoped.sh`, so a failed phase is reverted by `git revert` of its own commits; no rollback of the working tree is required and none is to be taken as a routine precaution.
- **If a pinned Goal statement differs from the Challenge block**: the probe is the compiled record and the block was copied from it at plan time, so a difference means a copy error in THIS plan or a drift in the file; find which before anything else, mark Phase 1 `[BLOCKED]` if the file's statement is genuinely weaker than the research round's, and raise it. Never edit a statement or a proof to make the two agree.
- **If the guard's TRACKED test fails after the move**: the `git mv` was not committed; commit it (the file never leaves version control); never force-track the old path.
- **If Phase 2's writer is refused** (mutex, cycle check, STATUS-NO-OP pair): retry with bounded backoff for the mutex; for a cycle or a pair refusal report the exact message and mark the phase `[PARTIAL]` with the filter and the intended pair recorded for resume — never a hand `jq` write to `state.json` to route around the sanctioned writer's refusal. If the successor was created but the edge was not, Phase 3's roadmap text still names the successor and says the edge is pending.
- **If a Scope Hypothesis is falsified** (the `WIRED` count, the line count, a roadmap region that turns out not to exist, the generated block's position): the figure is re-derived and the phase proceeds on the re-derived figure; a genuine overcount (a region with no hit) is closed with `[COMPLETED WITH EXCLUSIONS]` and a `#### Reasoned Exclusions` record whose Evidence column cites the grep that falsified it.
- **If the source-store file at `~/.config/nvim` has changed under the previous round's uncommitted state** (a concurrent edit or a deploy that reset it): re-read the working tree, re-apply the four additions additively, and record the event on the issue log; never resolve by checking the file out from HEAD.
- **If a genuine rollback of uncommitted work becomes necessary**: take the snapshot first per `context/contracts/recovery.md`'s rollback rung, then run the destructive command; a bare `git-snapshot.sh 819` is not a start-of-phase precaution, and an ordinary defensive checkpoint uses `--no-revert`.
- **Whole-task contingency**: the decision and its compiled finding stand regardless of this task's outcome — the report is committed and the prototype is tracked at its current path. If the probe cannot be promoted (an environment failure in the guard), the task returns `partial` with the records (Phases 2-5) landed and the probe path in the roadmap and README named as "tracked under the task directory, promotion pending" rather than as wired; no record states anything the file does not prove.
