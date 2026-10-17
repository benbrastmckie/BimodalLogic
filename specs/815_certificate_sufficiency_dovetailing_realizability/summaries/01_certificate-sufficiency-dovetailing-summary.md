# Implementation Summary: Task #815

- **Task**: 815 - Certificate sufficiency: dovetailing, realizability (the SUFFICIENCY half of realizable-type adequacy)
- **Status**: [COMPLETED]
- **Started**: 2026-10-17T15:53:04Z
- **Completed**: 2026-10-17T16:11:22Z
- **Effort**: ~1 hour (plan estimate 5.5 hours)
- **Dependencies**: 809 (predecessor; certificate restated, not imported), 806 (untouched), 761 (parent; untouched in state, now costable per the roadmap)
- **Artifacts**: plans/01_certificate-sufficiency-dovetailing.md, reports/01_certificate-sufficiency-dovetailing.md, specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean, scripts/check-evidence-probes.sh, specs/ROADMAP.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)

## Overview

The research round had already compiled the verdict in the twenty-third wired probe
(`Probe815`, thirteen theorems); this task closed the one gap it left -- the two-sided theorem
`realizes_of_certAdm_cohBi` had no non-vacuous compiled instance -- and did the follow-through.
The verdict, in three parts: the dovetailing argument IS a theorem (`exists_dovetail_chain`), with
forward-only sufficiency for the compiled relation (`forward_chain_of_certAdm`, labelled); the
two-sided claim for `coh` is REFUTED (`sufficiency_refuted`, backward arm only, on `R3` over
`(⊤ S a1) ∧ (⊤ S a2)`); the repair is the strict-since link `cohBi`, under which the certificate
IS sufficient at the LABEL level (`realizes_of_certAdm_cohBi`), at no cost on a `snce`-free
closure (`cohBi_eq_coh_of_snce_free`), and -- new here -- non-vacuously in BOTH arms.
Condition (3)'s `|R|` bound is derived (`eu_mem_lfp_path_le_card`), consumed by nothing.

## What Changed

- `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` -- new section
  "Non-vacuity of the two-sided theorem: a fixture carrying BOTH arms": `phi4 = (⊤ U b) ∧ (⊤ S a1)`
  over the object `2 → 0 → 1` with self-loops at `2` and `1`, candidate set `R4 = {y0, y1, y2}`,
  every member carrying both obligations. Four new Goals, all `[propext, Classical.choice,
  Quot.sound]`: `phi4_closure_both_arms`, `y0_carries_both`, `cert_accepts_R4`
  (`certAdm lab4 cohBi4 R4 = true`, six conditions by hand through `mem_R4`), and
  `realizes_y0_R4`, which is the corollary
  `realizes_of_certAdm_cohBi step4 pend3 lab4 R4 cert_accepts_R4 y0 y0_mem_R4` -- not a hand-built
  chain, not a `decide`. The file now prints seventeen theorems: the research round's thirteen
  (`eu_mem_lfp_path_le_card`, `exists_round`, `exists_dovetail_chain`,
  `forward_chain_of_certFwd_rel`, `forward_chain_of_certAdm`, `link_snce`,
  `cohBi_eq_coh_of_snce_free`, `backward_chain_of_certBwd`, `cert_accepts_R3`,
  `no_bwdFulfilling_through_x0`, `sufficiency_refuted`, `cohBi_rejects_x1_x0`,
  `realizes_of_certAdm_cohBi`) plus this task's four. Header: verdict sentence, figures
  paragraph, and a "What this does NOT say" bullet for the two-arm instance.
- `scripts/check-evidence-probes.sh` -- the probe's decision-row comment block carries the
  non-vacuity rows (`cert_accepts_R4`, `realizes_y0_R4`) and "seventeen printed theorems"; no
  `WIRED` entry added (40 before and after; the guard prints 41 with `WIRED_REPO`).
- `specs/ROADMAP.md` -- the four regions that gated `761` on sufficiency rewritten to the verdict:
  `761` is the critical path and costable; the two rulings it inherits are that Route B's relation
  is `cohBi` and that realizability is label-level with the semantic step (obligation (d)) open.

## Decisions

- Route B's relation is `cohBi` (= `coh` plus `linkPredB`), by name. No backward propagation
  theorem is claimed for `coh`; the predecessor report's section-7 sentence that the mirror holds
  through `snce_propagates_to_start` is false for `coh` (the mirror holds for `cohBi` through
  `link_snce`), and no artifact of this task cites `snce_propagates_to_start` as a product-layer
  fact. The predecessor report itself was not edited (issue log, minor, plan-time entry).
- Both arms stay EXISTENTIAL: nothing added mentions `ULive`, `SLive`, `Disch` or `DischBwd`
  (grep: header prose only). `au_lfp_ne_eu_lfp_on_exit_graph` stands.
- **Realizability here is LABEL-LEVEL**: a bi-infinite `cohR`-chain fulfilling every `untl`/`snce`
  obligation. No declaration mentions `PlusTruthAt`, `tpOf`, `cellAt`, `anchorCells` or a
  `WorldHistory` (grep: header and section prose only). The semantic step from a fulfilling label
  chain to membership of a type in a cell -- obligation (d) -- is the remaining adequacy obligation.
- Gate 8 stays SIDESTEPPED: `phi4`'s closure has no `box` or `stab` member, so `certStab`/`certBox`
  are exercised by nothing here; the `stab` fixture is a separate deliverable. Gates 1 and 2 stay
  NOT ADDRESSED (n-side qualification carried), gate 3 CARRIED, gate 9 OPEN. Obligations (b), (c),
  (d) untouched. No gate verdict changed.
- The six per-type lemmas (`u0_untl_only` ... `u2_snce_only`) and six fixpoint-membership lemmas
  (`y1_fwd_untB` ... `y1_bwd_sig1`) were added as supporting declarations in the `R3` shape; the
  two-step discharge paths (`y2` through `y0`, `y1` through `y0`) are the point of the fixture.
- Scoped tier under the batch deferral directive: the one non-`specs/` file touched,
  `scripts/check-evidence-probes.sh`, is unmappable to any agent-system suite
  (`suite_selection_select` returns `__FULL_SWEEP__`), so no narrowing `run-all.sh --only` or
  `verify-deploy.sh --only-gate` invocation covers it; its covering checks are `bash -n`,
  `scripts/check-evidence-probes.sh` and `scripts/check-module-invariants.sh`, all run here. The
  complete `run-all.sh`/`verify-deploy.sh` set was DEFERRED to the batch stage, not run by this
  dispatch.

## Plan Deviations

- None (implementation followed plan). Two Phase 1 mechanical verification criteria were read
  substantively rather than literally and recorded on the issue log (minor): `grep -c
  native_decide`/`maxRecDepth` = 0 is unsatisfiable against the research round's own header
  sentence saying neither occurs (one hit each, no code use), and `grep -c 'decide$'` = 0 over the
  six condition lemmas conflicts with the mandated `R3` shape, in which `certLoc_R3` closes its
  three per-member concrete `locCoh` goals by `decide`; no `decide` is applied to a goal over `R4`
  or `ClType phi4`.

## Verification

- Build: Success -- full `lake build` through the guard, detached: `Build completed successfully
  (2875 jobs)`, guard exit 0, `error:` count 0 over the captured log (Tiers 1 and 2); Tier 3's
  per-module `.olean` check has no module to check, since no library `.lean` file was touched and
  the probe is a standalone `lake env lean` file, not a lake module.
- Probe compile: `lake-build-guard.sh build --timeout 600 -- env lean <probe>` exit 0, zero errors,
  zero warnings; seventeen `#print axioms` lines each `[propext, Classical.choice, Quot.sound]`;
  the one `#eval` prints `9` (and the pre-existing one prints `9` for `phi3`).
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots and over the probe)
- Vacuous count: 0 for this task's modified files. The roots grep returns one PRE-EXISTING hit,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal ... := trivial`),
  present at `HEAD~3` before this task and outside its edit set (issue log, minor).
- Axiom count: 14 over the source roots before and after (`HEAD~3` vs `HEAD`), 0 in the probe --
  not increased.
- `scripts/check-evidence-probes.sh`: exit 0, `PASS  all 41 wired probe(s) compile`, this probe's own line `PASS` (40 `WIRED` + 1 `WIRED_REPO`, re-counted; detached, bounded).
- `scripts/check-module-invariants.sh`: exit 1, on `INV` only -- three generated module-inventory blocks (`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`) are stale. NOT caused by this task: it added no `FormalSystem/` module and touched none of the three files (`git diff HEAD~3` on them is empty); the drift is concurrent sibling work and was not regenerated here (README/docs edits are plan Non-Goals). `C9` -- the invariant the plan names for the decision-row edit -- PASSES, as do `C8`, `C11`, `C9D` and every other group (detached, bounded). Recorded on the issue log as a gate collision (minor).
- `bash -n scripts/check-evidence-probes.sh` exit 0; `git diff` on it changes comment lines only;
  `WIRED` 40 entries before and after.
- `.claude/scripts/check-task-references.sh --quiet` exit 0 (0 unexempted occurrences).
- `git ls-files --error-unmatch <probe>` exit 0; `git diff --stat HEAD~3 -- FormalSystem/ Tests/
  docs/` empty (N = 3 phase commits at check time).
- The ten Goal statements (six pinned, four new) each match the plan's `## Lean Challenge
  Statements` block modulo whitespace, declaration by declaration.
  `lean-challenge-snapshot.sh --check 815 .` was attempted first and exited 71 (no manifest), so
  the declaration-by-declaration diff is the check actually run, as the predecessor recorded.
- Label-level mechanical check: `PlusTruthAt|tpOf|cellAt|anchorCells|WorldHistory`,
  `ladderRealized|LadderCons`, `ULive|DischBwd|SLive` match only header/section prose.
- `grep -c native_decide` / `maxRecDepth`: one hit each, the header sentence saying neither
  occurs; `^axiom ` 0.
- Tests: N/A (no `Tests/` change)
- Files verified: Yes
- `validate-artifact.sh` on this summary: exit 0 on the first run (before this line was filled); re-run after filling it, result in the return metadata.
- Carried figures: the gate verdicts for gates 1, 2, 3, 9 and the n-side qualification are READ
  from the headers of `nside-modulus-gate.lean`, `realizable-type-certificate.lean` and
  `closure-indexed-periodicity.lean`, not re-run here; the predecessor's `cert_accepts_Rchi`,
  `coh_accepts_Rev`/`cert_rejects_Rev` and `au_lfp_ne_eu_lfp_on_exit_graph` are cited from
  `realizable-type-certificate.lean`'s header and compiled by the evidence-probe guard run above,
  not re-read. Two fixture figures are measured by development-time `#eval` and re-confirmed by
  no theorem: `U0`/`U1`/`U2` have 4/5/5 members, and `y0 → y0`, `y1 → y0`, `y0 → y2` are not
  `cohBi4`-edges (the header says so).
- Issue log (attestation): four entries this dispatch -- a `win` (Scope Hypothesis confirmed
  in-file before any Goal was proved), a `minor` issue (two over-strict mechanical criteria), a
  `minor` issue (pre-existing vacuous-grep baseline hit); plus the plan-time `minor` entry on the
  predecessor report's section-7 sentence already logged. Nothing else arose.
- Plan revision sentinel: absent throughout; each phase's section was re-read before its first edit.

## Impacts

- `761` is costable: the roadmap now names it the critical path, over `cohBi`, with every
  realizability statement it inherits label-level.
- Route B is vindicated for the strengthened relation and the certificate shape is settled:
  seven decidable fields, both discharge conditions existential inside `R`, the two-arm one-step
  link. Any later cell-level fulfilment condition still has to answer `au_lfp_ne_eu_lfp_on_exit_graph`.
- The generic existential fixpoint and the dovetailing theorem remain probe-local; upstreaming
  them into `FormalSystem/` is a move, not done here.

## Follow-ups

- The `stab` fixture that exercises `certStab`/`certBox` (gate 8) -- a separate deliverable.
- The semantic step, obligation (d): from a fulfilling label chain to membership of a type in a cell.
- Upstreaming `euStep` ... `eu_mem_lfp_path_le_card` and `LinkStep` ... `exists_dovetail_chain` into
  `FormalSystem/` (research Recommendation 6).
- The predecessor report's section-7 mirror sentence stays uncorrected in that report (plan
  Non-Goal; recorded on the issue log).
- The batch-stage full gate set (`run-all.sh`, `verify-deploy.sh`) is owed by the batch stage.

## References

- specs/815_certificate_sufficiency_dovetailing_realizability/plans/01_certificate-sufficiency-dovetailing.md
- specs/815_certificate_sufficiency_dovetailing_realizability/reports/01_certificate-sufficiency-dovetailing.md
- specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean
- specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean (predecessor probe, cited)
- specs/809_realizable_type_adequacy_countdown_profile/reports/01_realizable-type-adequacy.md (section 6, the argument now compiled; section 7, the sentence now false for `coh`)
- specs/ROADMAP.md
- specs/815_certificate_sufficiency_dovetailing_realizability/handoffs/ (phase-1, phase-2, phase-3, phase-4 handoffs)
- specs/815_certificate_sufficiency_dovetailing_realizability/issues.jsonl
