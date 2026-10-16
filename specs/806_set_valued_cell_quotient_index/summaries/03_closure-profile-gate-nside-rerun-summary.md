# Implementation Summary: Task #806

- **Task**: 806 - Set-valued cell over a quotient index: promote the closure-indexed periodicity prototype to a wired probe, and re-run the gate table against the countdown profile on the coprime-cycle fixture
- **Status**: [COMPLETED]
- **Started**: 2026-10-16
- **Completed**: 2026-10-16
- **Effort**: ~5 hours (plan estimate 12)
- **Dependencies**: 761 (parent, untouched and still `[BLOCKED]`); 805 (predecessor, refuted; its fixture and index body are ported, not imported)
- **Artifacts**: plans/03_closure-profile-gate-nside-rerun.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)

## Overview

Three wired evidence probes landed under `specs/evidence/seam-gluing-ray-product/`, bringing the
collection's `WIRED` array from 33 entries to 36. The closure-indexed eventual-periodicity
prototype was promoted out of the task directory into the tracked collection; the countdown
profile — the candidate set-valued per-state datum over the object-closure quotient — was defined
on the coprime-cycle fixture and run against the rebuilt nine-row gate table; and a ninth gate was
raised, on compiled ground and as a hypothesis test, against the refuted tuple's n-side
coordinates. All thirteen `## Lean Challenge Statements` Goals are discharged sorry-free with
their recorded signatures unchanged.

The verdict is that the countdown profile **survives this round's gates** on this one fixture, and
that three of the nine gates it does not address at all. Nothing here is a sufficiency claim, a
factorization lemma, a cell index, or any part of one; adequacy — the expensive half of the first
standing obligation — is open, and obligations (b), (c) and (d) are not started.

## What Changed

- `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` — the **seventeenth
  wired probe** (254 lines). Moved by `git mv` out of
  `specs/806_set_valued_cell_quotient_index/prototype/`, which no longer exists; the header was
  rewritten from "PROTOTYPE TEST (not a wired probe)" to the collection's convention, and the
  `Compile:` line re-pointed. No declaration, proof or `#print axioms` line changed: the seven
  theorems (`iterate_eventually_periodic`, `prodReachN_eventually_periodic`,
  `prodPreN_eventually_periodic`, `prodReach_fst_subset`, `strict_object_period_one`,
  `strict_product_period_three`, `strict_product_not_period_one`) are byte-for-byte as they were.
  The probe was sitting in exactly the position from which four earlier probes were lost to
  `.gitignore` on archival.
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` — the **eighteenth
  wired probe** (799 lines, namespace `Probe806`), new. Eleven theorems proved:
  - `chi_closure_untl_only` — `plusSubformulaClosure chi` has no `box`, `snce` or `stab` member.
  - `coh6_liesOver` — the LOCAL coherence relation lies over the object's step relation.
  - `coh6_cycle_witness` — the non-vacuity exhibit: an explicit `coh6`-coherent 3-cycle of closure
    types carrying `chi`, landed before every negative lemma.
  - `coh6_chi_propagates`, `coh6_no_a_d_a`, `coh6_chain_a_to_a_mod3` — the `chi`-consistent product
    never passes through `d`, and its `a`-to-`a` chains have length divisible by three.
  - `prof6_fibre_a_of_mem`, `prof6_fibre_a_witness`, `prof6_separates_gate6_pair`,
    `prof6_period_not_one`, `reach5_eventually_constant` — the countdown profile's `a`-fibre is
    nonempty at exactly the multiples of three, so it separates gate 6's own pair for every
    modulus coprime to three, and its period is not the object's exhibited period of one.
  Supporting, not Goals: the ported object layer (atoms, `step5`, the `cyc` family, `pred_of_d`,
  `succ_of_d`, `lab6`, `reachStep`), the restated carrier (`ClType`, `ProdState`, `prodPreStep`),
  the relation (`noModalArm`, `locPred`, `linkPred`, `locCoh`, `untlLink`, `coh`, `coh6`), the
  unfolding lemma `coh_iff`, five single-closure-member bridge lemmas (`loc_bot`, `loc_atom`,
  `loc_imp`, `loc_neg`, `link_untl`), `chi_mem_iff`, `pa_mem_of_a`, `chain_cyc`, and the profile
  helpers (`Ea`, `Prof6`, `prof6_succ`, `mem_prof6_succ`, `consChain`, `prof6_chain`).
- `specs/evidence/seam-gluing-ray-product/nside-modulus-gate.lean` — the **nineteenth wired
  probe** (218 lines with its header, ~144 lines of body, namespace `Probe806N`), new. Two Goals,
  `nside_pair_ne` (non-vacuity: the collided pair is a pair of DISTINCT states) and
  `nside_collides` (gate 9's collision half), plus the n-side port carried over from the sixteenth
  probe with statements and hypotheses unchanged (`ladderIndexJnt`, `Qp`, `pendP`, `stepP`, `st`,
  `idl`, `consec_mod_ne`, `gate1_gap_separates`, `gate2_residue_separates`).
- `scripts/check-evidence-probes.sh` — three new boxed decision-row comment blocks and three new
  `WIRED` entries, in probe order (33 → 36).
- `specs/806_set_valued_cell_quotient_index/handoffs/` — two phase-end handoffs (phases 1 and 4).

Nothing under `FormalSystem/`, `Tests/`, `docs/` or `specs/ROADMAP.md` changed, and the parent
task 761 was not touched.

## The gates 1-9 verdict table

Copied from the two probes' headers. Column "Where": which record exhibits it, or that nothing
does.

| Gate | Mechanism | Verdict | Where |
|---|---|---|---|
| 1 | gap pair `(B, B+1)` vs `(B, B+2)` — equal countdown, differing next deadline | **NOT ADDRESSED** | No theorem of the eighteenth probe. The datum reads the countdown only; the next-deadline-side datum is obligation (c). Qualified (not changed) by the nineteenth probe — see below. |
| 2 | residue pair `(2B, 4B+2)` vs `(2B+1, 4B+2)` | **NOT ADDRESSED** | Nothing. The research round's expectation ("below the product's threshold the profile is countdown-exact") is a statement about which types are REALIZABLE, so it reduces to adequacy; recorded as an expectation, not probed. |
| 3 | second region, past direction | **CARRIED** | The sixteenth probe's `second_region_sets_agree`, `third_region_any_length`, `region_start_beyond_depth`. Re-run by nothing here. Its verdict never reads the index's parameters, and this datum has none. |
| 4 | object-exhibited threshold, via the depth-`(T+1)` next-chain | Disarmed by construction, by no theorem here | An argument, recorded as a claim about the datum's shape: there is no threshold parameter to attack, and the depth-`(T+1)` witness enlarges the closure (hence the product, hence the profile) rather than escaping a bound. |
| 5 | full-graph reach-set period | Disarmed **and exhibited** | `reach5_eventually_constant` (the object's own period one from threshold four) against `prof6_period_not_one` (the profile's is not one). |
| 6 | pattern-definable sub-object | **INTERNALISED** | `coh6_liesOver`, `coh6_chi_propagates`, `coh6_no_a_d_a`, `coh6_chain_a_to_a_mod3`, `prof6_fibre_a_of_mem`, `prof6_fibre_a_witness`, `prof6_separates_gate6_pair`. The pattern is a subformula, hence a closure member, hence tracked. |
| 7 | non-circularity / non-vacuity | **PASSED** in its definability form, witnessed non-vacuous | `coh6_cycle_witness`, plus the mechanical grep for `WorldHistory`/`tpOf`/`cellAt`/`PlusTruthAt`/`IsSlicedStepPath` returning no non-comment hit. |
| 8 | `stab` self-reference | **SIDESTEPPED**, not passed | `chi_closure_untl_only`: the fixture's closure is `box`/`snce`/`stab`-free, so the unconstrained arms of `locPred`/`linkPred` are never exercised. A `stab`-free fixture cannot pass a `stab` gate, only avoid it. |
| 9 | n-side modulus | **OPEN** — neither passed nor refuted | The nineteenth probe: `nside_pair_ne` and `nside_collides` compile its collision half; its refuting half (a formula giving the collided pair different cells) is NOT ATTEMPTED. |

## Phase 4.1's decision gate: Branch N-VERIFIED

Phase 4.1 was the plan's one named decision gate, and it landed **Branch N-VERIFIED**: all three
of its conditions held — both ported gate theorems compiled at their original hypotheses with
nothing added, dropped or specialised (signature-level diff against
`ladder-joint-index-refutation.lean` is clean); `nside_pair_ne` closed; and `nside_collides` closed
exactly as the Challenge block states it, with no extra hypothesis.

What that licensed Phase 5 to write on gate 1's row is a **compiled qualification only, never a
verdict change**. Gate 1's row still reads `NOT ADDRESSED`, with the addition that a candidate
datum of the refuted tuple's n-side shape does separate gate 1's pair (ported
`gate1_gap_separates`, `2 ≤ B`) but is itself blind to the n-side modulus shift at every parameter
triple (`nside_collides`) — so the qualification narrows what remains to be found and passes
nothing. That paragraph is written verbatim into both the nineteenth probe's header and the
eighteenth probe's gate-1 section, so the two records cannot drift.

The audit's BELIEVED-tier claim that the refuted tuple's n-side coordinates are therefore the
natural shape of obligation (c)'s datum is thereby **tested and not sustained as stated**: those
coordinates pass gates 1 and 2 and are still blind to the shift the datum has to see.

## Decisions

- The three negative/structural lemmas of Phase 3 are routed through five generic
  single-closure-member bridge lemmas (`loc_bot`, `loc_atom`, `loc_imp`, `loc_neg`, `link_untl`)
  rather than through inline `simp only [locPred, ...]` on each instantiated hypothesis. This is
  the plan's stated strategy — instantiate the universally quantified local/link condition at one
  concrete closure formula, membership by `decide`, then propositional reasoning — factored once
  so that every `have` in the hand proofs carries an explicit type ascription in terms of the
  named formula `def`s. The factoring is what keeps the hypotheses syntactically uniform enough
  for `tauto` to close the propositional steps; the chain of closure members the plan specifies is
  unchanged and is restated in `chi_mem_iff`'s docstring.
- `decide` is used only on concrete closure-membership facts, concrete types (`Ta`/`Tb`/`Tc`) and
  the eight-state object graph. No `decide` call is applied to a goal quantifying over
  `ClType chi`, and the three types are built with `mkT` (a `filter` plus
  `Finset.mem_powerset.mpr (Finset.filter_subset _ _)`), never by `decide` on `Finset.powerset` —
  which the plan recorded as hitting `maxRecDepth`.
- `native_decide` appears nowhere, in any of the three probes.
- The nineteenth probe's two Goals were committed as two separate green sub-steps in the order the
  plan requires — `nside_pair_ne` first, then `nside_collides` — so the non-vacuity obligation is
  discharged before the negative result in git log order as well as in file order.

## Plan Deviations

- **Phase 1 verification bullet** (`check-evidence-probes.sh` "reports 34 wired probes") altered:
  the `WIRED` array does hold 34 entries after Phase 1 and 36 after Phase 5, exactly as the plan's
  Scope Hypotheses predict, but the script's printed total also counts its one `WIRED_REPO` entry,
  so the observed lines are `PASS  all 35 wired probe(s) compile` and
  `PASS  all 37 wired probe(s) compile`. Substance matches; the predicted string does not.
  (Also annotated on Phase 5's and Phase 6's corresponding bullets.)
- **Phase 4.2 verification bullet** ("every Goal is named exactly once") altered: `nside_pair_ne`
  is named once in the nineteenth probe's header, but `nside_collides` is named twice — once in
  the Goal inventory under `## What is settled`, and once inside the verbatim gate-1 row block the
  header hands to Phase 5. Keeping that block byte-identical between the two records was judged to
  matter more than the single-mention count, since the plan's own reason for putting it in the
  header is that "the two records cannot drift".
- No other deviation. No Goal was weakened, specialised, renamed or dropped; all thirteen
  signatures match the plan's `## Lean Challenge Statements` block.

## Verification

- Build: Success. Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached: exit 0 (a no-op success, as expected — no library `.lean` file changed).
- Sorry count: 0 (`bash .claude/scripts/lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 1 pre-existing, 0 introduced. The single grep hit is
  `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial` — a genuine proof
  of a genuine statement (`intTimeHistory`'s domain is total), untouched by this task. No
  declaration in any of the three probes has a `True`/`Unit`/`trivial` body.
- Axiom count: 14 pre-existing `^axiom ` declarations under the source roots, unchanged — this
  task modified no file under those roots (`git diff --stat` against the pre-task commit over
  `FormalSystem/ Tests/ docs/ specs/ROADMAP.md` is empty). Zero `^axiom ` lines in all three
  probes.
- `#print axioms`: 22 lines across the three probes (7 + 11 + 4), every one within
  `[propext, Classical.choice, Quot.sound]`; three of the nineteenth probe's four are the tighter
  `[propext, Quot.sound]`.
- Guarded `lake env lean` on each probe: exit 0, zero errors, zero warnings.
- `bash scripts/check-evidence-probes.sh`: exit 0, every probe PASS.
- `bash scripts/check-module-invariants.sh`: **exit 1 — one PRE-EXISTING check group fails, inherited and not caused here.** `FAIL  C16  env_linter batch reports new finding(s) beyond scripts/nolints.json's grandfathered baseline`, on
  `FormalSystem/Semantics/ShiftFiniteType.lean:149`: `FrameOver.mem_HF_iff_no_forbidden` has one
  unused argument, `[Finite F.WorldState]`. That file was last modified on 2026-10-15 by a
  different task's phase 10 commit (`250a74ae0`) and is **not in this task's diff at all**
  (`git diff --name-only` against the pre-task commit does not list it; the whole
  `FormalSystem/ Tests/ docs/ specs/ROADMAP.md` diff is empty). Every other group passes,
  including `C1  lake build exits 0`, `C1  lake build BimodalTest exits 0`, `C9`, `C15`, and
  `C20` tiers 1 and 2. **This dispatch did not and could not repair it**: the repair is an edit
  under `FormalSystem/`, which this plan forbids by an explicit Non-Goal. See Follow-ups.
- `bash .claude/scripts/check-task-references.sh --quiet`: exit 0 (0 unexempted occurrences). The
  three new decision rows cite probe filenames and theorem names, never a task number.
- `bash .claude/scripts/verify-deploy.sh`: exit 0.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 806 .`: exit 71, `no manifest found at
  specs/806_set_valued_cell_quotient_index/challenge/manifest.json` — the snapshot was never taken
  for this task, so there is nothing pinned to compare against. The tool's own header states its
  verdict is ADVISORY ONLY and MUST NOT set `verification_passed` false or block completion, and
  a missing manifest is weaker still than a drift finding. Statement fidelity was therefore
  established directly instead: every one of the thirteen `theorem` signatures in the two probes
  was diffed against the plan's `## Lean Challenge Statements` block, and all thirteen match
  character-for-character.
- Gate-7 mechanical check: no non-comment hit for
  `WorldHistory|tpOf|cellAt|PlusTruthAt|IsSlicedStepPath` in either new probe.
- `ladderRealized`/`LadderCons`: matched only in header text under "what this does NOT say".
- Tests: N/A (no test file changed; the probes lie outside the Lake build graph by construction).
- Files verified: Yes.

## Impacts

- The evidence collection's rot guard now covers three more records, so the strengthened modulus
  condition, the countdown profile's gate-table verdict, and gate 9's collision half cannot
  silently stop meaning what they say. The periodicity record in particular is no longer sitting
  in a task directory, which is where four earlier probes were lost to `.gitignore` on archival.
- The parent task 761 (ladder realization theorem) stays `[BLOCKED]`, and the corrected record it
  is blocked on now has a named successor candidate with a compiled gate table rather than a fifth
  refuted tuple.
- The tuple-widening line stays closed: no seventh coordinate is proposed, and the profile's
  threshold and period are not re-presented as index coordinates.

## Follow-ups

- **Adequacy** — the expensive half of the first standing obligation, and the gate on everything
  after it. `coh6` is LOCAL coherence: it has no fulfilment condition on `untl`/`snce`
  eventualities, so it over-approximates realizability. Eventual periodicity survives the
  fulfilment-flag repair (the flags live on the same finite carrier), but surviving that repair is
  not adequacy. Successor record.
- **Obligations (b), (c), (d)**, not started and named here so they are not rediscovered: (b) a
  region-length pumping lemma for `untl`/`snce`-depth-bounded formulas; (c) the next deadline's
  coupling through `Drift`; (d) the `box`/`stab` letters through `box_mem_tpOf_iff` and
  `stab_mem_tpOf_iff`. No `LadderCons` is to be stated without the `box`/`stab` clause.
- **Gate 9's refuting half** — a formula on the coprime-cycle object giving the collided n-side
  pair different cells. It needs the sixteenth probe's whole model layer (`F5`, `M6`,
  `hist_path5`, `cellAt`), which a probe may not import and which the nineteenth probe does not
  restate. Gate 9 stays OPEN until that half is landed or refuted.
- **Gate 8 on a `stab`-carrying fixture.** This round sidestepped it; a fixture whose closure has a
  `stab` member is what would actually test the fixpoint obligation `stab_mem_tpOf_iff` imposes at
  definition time.
- **Repair the inherited C16 failure** in `FormalSystem/Semantics/ShiftFiniteType.lean:149`
  (`FrameOver.mem_HF_iff_no_forbidden`'s unused `[Finite F.WorldState]` argument). It fails the
  module-invariant gate and therefore CI today. It arrived with a different task's work on
  2026-10-15 and is out of scope here by an explicit Non-Goal, so it needs its own task: either
  drop the instance argument or, if it is intentional, mark it `@[nolint unusedArguments]`. Do
  NOT reach for `lake exe runLinter --update FormalSystem`, which grandfathers everything
  currently reported, a genuine regression included.
- **One fixture is one fixture.** Every separation here is on the coprime-cycle object with gate
  6's labelling and gate 6's formula. A seventh mechanism this fixture does not exercise would not
  be visible.

## Carried figures, and the status of the audit

- The sixteenth probe's gate outcomes (gates 1-6 against the refuted six-coordinate index) were
  read from its header, not re-run here. The one exception is the n-side material: the gate-1 and
  gate-2 standing of those coordinates was **re-established by port** into the nineteenth probe,
  compiled there, rather than inherited by citation.
- Gate 3's verdict is CARRIED from the sixteenth probe and re-run by nothing in this round.
- The graveyard-and-alternatives audit that supplied gate 9 and the n-side hand-off is a
  **session-local read-only analysis held in a scratchpad**, not a repository artifact, and it will
  not survive. Every claim this round used from it is restated with its tier in
  `plans/03_closure-profile-gate-nside-rerun.md`. A reader who wants to check the substance should
  re-run the compiled probes instead: `ladder-joint-index-refutation.lean` (the four refutations
  and the n-side gate theorems) and `mosaic-stab-saturated.lean` (the mosaic route's closure).
- The research report `reports/01_closure-indexed-periodicity-gate.md` cites the periodicity
  prototype at its old path, `specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean`.
  That citation is now historical and was deliberately left alone: the report is a dated record.
  The current path is `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`.

## Issue log

Recorded as they arose, in `specs/806_set_valued_cell_quotient_index/issues.jsonl`: two `issue`
entries (the `WIRED_REPO` off-by-one in the plan's predicted guard output, `minor`; and the
inherited C16 module-invariant failure, `costly`, unrepairable within this plan's scope) and one
`win` (both
Lean-heavy phases compiling green on the first attempt, with every Phase 2 scope-hypothesis figure
confirmed to the number: closure of `chi` has 18 members, `Ta`/`Tb`/`Tc` have 9/9/10). Nothing
else arose that is not already recorded as a Plan Deviation above.

## References

- `specs/806_set_valued_cell_quotient_index/plans/03_closure-profile-gate-nside-rerun.md` — the plan executed, with the thirteen-signature Challenge contract.
- `specs/806_set_valued_cell_quotient_index/reports/01_closure-indexed-periodicity-gate.md` — the research round, including the gate table this round ran.
- `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` — seventeenth probe.
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` — eighteenth probe.
- `specs/evidence/seam-gluing-ray-product/nside-modulus-gate.lean` — nineteenth probe.
- `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean` — sixteenth probe: the source of every port, and the owner of gate 3's carried verdict.
- `scripts/check-evidence-probes.sh` — the rot guard the three probes are registered in.
- `specs/806_set_valued_cell_quotient_index/handoffs/` — phase-end handoffs for phases 1 and 4.
