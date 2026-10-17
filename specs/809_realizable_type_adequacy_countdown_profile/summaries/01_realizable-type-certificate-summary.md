# Implementation Summary: Task #809

- **Task**: 809 - Realizable-type adequacy of the countdown profile: the certificate presentation, its existential fulfilment condition, and the compiled separation from local coherence
- **Status**: [COMPLETED]
- **Started**: 2026-10-17T00:00:00Z
- **Completed**: 2026-10-17T00:00:00Z
- **Effort**: ~4 hours
- **Dependencies**: 761 (parent, untouched and still `[BLOCKED]`); 806 (predecessor, fixture and local relation ported not imported); 805 (refuted predecessor, its coprime-cycle object reaches here through 806)
- **Artifacts**: plans/01_realizable-type-certificate.md, reports/01_realizable-type-adequacy.md, specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)

## Overview

The round landed one new wired evidence probe,
`specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`, carrying all eighteen
Goal theorems of the plan sorry-free and with no new axiom. It builds the EXISTENTIAL
until-fixpoint as the dual of the tree's landed universal `AUFix`, reads it as a guarded-path
statement, compiles the universal-versus-existential separation on a cycle with an exit, defines
the certificate presentation as a candidate realizable set with the research report's six
conditions as seven decidable fields -- `certLoc`, `certBiInf`, `certFwd`, `certBwd`,
`stabOk`/`certStab`, `certBox`, conjoined by `certAdm` -- INCLUDING the `box` and `stab` clauses, and exhibits the separation that makes the exercise non-vacuous: a set
of product states that local coherence accepts and the certificate rejects, on the same fixture
the predecessor round's gate table was run on.

**Adequacy is NOT discharged.** That the certificate's six conditions are SUFFICIENT for
realizability is an argument in the research round's report, marked uncompiled there, and is
stated as a theorem nowhere. The sufficiency half, and standing obligations (b) region-length
pumping, (c) the `Drift` coupling of the next deadline, and (d) the `box`/`stab` letters through
`box_mem_tpOf_iff`/`stab_mem_tpOf_iff`, are NOT STARTED and belong to a successor record.

## What Changed

- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` — new, the
  twenty-first wired probe (namespace `Probe809C`). Eighteen Goal theorems:
  - the existential fixpoint API — `eu_step_mono`, `eu_lfp_fixed`, `eu_mem_lfp_iff`,
    `eu_lfp_least`, ported one quantifier at a time from `AUFix` and mentioning no formula, label
    or object;
  - its meaning — `eu_mem_lfp_iff_exists_path` (`0 < n` and the event at `f n`, so strict until
    and not weak until), and the one negative lemma the rejection consumes,
    `eu_lfp_eq_empty_of_no_event`;
  - the strength choice, compiled — `au_lfp_ne_eu_lfp_on_exit_graph` on the four-state graph
    `0 → 1 → 2 → 0` with the exit `0 → 3`;
  - the composition theorem the restriction could have broken —
    `untl_propagates_along_coh`, stated generically over the object, the labelling and the
    formula, with `cohR_le_coh` reading the restriction as a restriction;
  - the certificate — `chi_closure_box_snce_stab_free`, `cert_fwd_iff_eu_lfp`, and the
    non-vacuity witness `cert_accepts_Rchi`, landed before every negative statement about the
    certificate;
  - the separation — `coh_accepts_Rev`, `rev_eu_lfp_empty`, `cert_rejects_Rev`;
  - the restricted countdown profile — `profR_period_three`, `profR_fibre_a_witness`,
    `profR_separates_gate6_pair`.
- `scripts/check-evidence-probes.sh` — one boxed decision-row comment block and one `WIRED`
  entry (37 entries before, 38 after).

### Per-gate verdict, copied from the probe header

| Gate | Verdict in this round |
|------|------------------------|
| 1 (first region separation, next-deadline side) | NOT ADDRESSED; this datum reads the countdown only. Compiled n-side qualification CARRIED from `nside-modulus-gate.lean` (Branch N-VERIFIED). |
| 2 (second region separation) | NOT ADDRESSED; reduces to adequacy, whose sufficiency half is not discharged. Same carried qualification. |
| 3 (two-sided region refutation) | CARRIED from the sixteenth probe's `second_region_sets_agree` and `region_start_beyond_depth`; re-run by nothing here. |
| 4 (threshold coordinate) | DISARMED BY CONSTRUCTION, carried from the eighteenth probe; neither the profile nor `ProfR` carries a threshold. |
| 5 (modulus coordinate) | DISARMED AND EXHIBITED, carried from the eighteenth probe's `reach5_eventually_constant`. |
| 6 (pattern-definability) | The eighteenth probe's separation SURVIVES the refinement to the candidate set (`profR_separates_gate6_pair`). NOT a new gate-6 verdict. |
| 7 (non-circularity / non-vacuity) | PASSED in its definability form, and witnessed non-vacuous by `cert_accepts_Rchi`. |
| 8 (`stab` self-reference) | SIDESTEPPED on a `stab`-free fixture, NOT passed (`chi_closure_box_snce_stab_free`); the clauses are PRESENT as `certStab`/`certBox` conjuncts of `certAdm` and are unexercised. |
| 9 (n-side modulus) | OPEN; neither attempted nor closed here. |

## Decisions

- **Route B over Route A, as the plan fixed it.** Route A's missing piece is generalized-Büchi
  nonemptiness per state — a nested fixpoint nothing in this tree decides — and entering it
  without a decision record is how the tuple-widening loop was entered. Route B's conditions are
  bounded and decidable field by field, and the shape is the one three separate subtrees already
  use. The existential fixpoint built here is NOT Route A's algorithm: no theorem in the file
  quantifies over the SET of eventualities a state carries.
- **The fulfilment condition is EXISTENTIAL, and `ULive` is never transplanted.**
  `au_lfp_ne_eu_lfp_on_exit_graph` is the compiled reason: the universal operator returns `{3}`
  where the existential one returns `Finset.univ`.
- **`certFwd`/`certBwd` run INSIDE `R`** (`V := R`, `succ := succR R`/`preR R`), and
  `cert_fwd_iff_eu_lfp` puts that quantifier structure into a signature so the weaker reading
  ("a path somewhere in the carrier") cannot be substituted silently.
- **No backward propagation theorem is stated.** `linkPred` constrains no backward arm, so one is
  not available from this relation, and claiming it would be a strictly weaker statement wearing a
  stronger name.
- **The `AUFix` port lives in the probe, not in `FormalSystem/`**, because this task's scope
  forbids library edits — recorded as a deliberate consequence, not an oversight.

## Plan Deviations

- None in statement: all eighteen pinned signatures were landed exactly as the plan's
  `## Lean Challenge Statements` block fixes them, verified by a mechanical declaration-by-
  declaration diff against that block.
- One PROOF-ROUTE change, pre-authorised by the plan's own Risks table rather than a deviation
  from it: `cert_accepts_Rchi`'s six components could not be closed by `decide` (all six overran
  `maxRecDepth`, and a 20000 budget did not help). The cause is kernel-reducing the three-element
  `Rchi` LITERAL — deciding equality of closure types — not the carrier; `decide` over the
  18-member closure succeeds at the default depth. Each condition is therefore discharged by hand
  through `mem_Rchi` and per-state facts, which is exactly the mitigation that Risks row names
  ("Every Goal quantifying over `ClType chi` is proved by hand through the one-step unfoldings").
  No `set_option maxRecDepth` survives in the file.
- One CONFIRMATION-METHOD change of the same kind, in Phase 5: the Scope Hypothesis asked for
  `#eval` on `ProfR Rchi k` directly, which would enumerate the `2 ^ 18 × 8` carrier — the
  whole-carrier computation the same Risks table forbids. The three values were instead confirmed
  by `#eval` through the compiled identity `profR_step_eq`, which proves the iterated operator
  equal to a three-element `Rchi.filter`, and the object coordinate of each value is printed. The
  figures confirmed are the plan's own.
- Three of the plan's VERIFICATION items could not be executed in their literal form and are
  annotated inline on the plan's checklist, each with the substitute actually run:
  - the probe guard prints `all 39 wired probe(s) compile`, not `38` — the `WIRED` array figures
    the plan named are exactly right (37 before, 38 after), but the guard's `wired_total` adds
    the one-entry `WIRED_REPO` array;
  - `cert_accepts_Rchi` precedes every negative statement ABOUT the certificate and the candidate
    sets, but not `au_lfp_ne_eu_lfp_on_exit_graph` or `chi_closure_box_snce_stab_free`, which the
    plan's own pinned Challenge-block ORDER places earlier — resolved in favour of the pinned
    order, since Statement Fidelity governs that block;
  - `lean-challenge-snapshot.sh --check 809 .` has no manifest to check against, so a mechanical
    declaration-by-declaration diff against the plan's Challenge block was run instead
    (91/91 declarations present, 0 signature mismatches).
- Every one of these is recorded in `specs/809_realizable_type_adequacy_countdown_profile/issues.jsonl`
  as it arose, together with one `win` entry recording that every Scope-Hypothesis figure was
  confirmed exactly and that Phases 1-3 compiled with zero errors and zero warnings.

## Verification

- Build: `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` exits 0 with ZERO errors and ZERO warnings; eighteen `#print axioms` lines each report at most `[propext, Classical.choice, Quot.sound]`.
- Full `lake build` through the guard, detached: guard exit 0, `Build completed successfully (2875 jobs)`, and ZERO `error:` occurrences across both captured streams. No library file changed, so this is the expected no-op success; the one module this task touched is the standalone probe, which no library module imports and whose own single-file compile exits 0.
- Sorry count: 0. Vacuous-definition count: 0. `grep -c "^axiom "`: 0. `grep -c native_decide`: 0.
- `bash -n scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-evidence-probes.sh` exits 0, reporting `PASS  all 39 wired probe(s) compile` with the new probe listed PASS, and the probe is git-tracked (`git ls-files --error-unmatch` exits 0). The plan's Scope Hypothesis predicted the printed total would be 38; the `WIRED` array figures it named are exactly right (37 before, 38 after, measured both times) but the guard's `wired_total` adds `WIRED_REPO` (1 entry, the archived FMP probe), so it printed 38 before this round and 39 after. Recorded in this task's issue log rather than silently reported as 38.
- `bash scripts/check-module-invariants.sh` exits 0 (C9 and C9D both PASS: zero task-number citations under `FormalSystem/`, `scripts/`, `README.md` or `docs/`). Its output does carry one FAIL group — `INV  3 file(s) carry a stale generated inventory block` in `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — which this dispatch did not cause: the block is generated from `dir=FormalSystem`, the diff over `FormalSystem/` across this task's commits is empty, and the last `FormalSystem/` commit postdates the last `README.md` commit. Its remedy would edit files this task's Non-Goals forbid, so it is deliberately left alone and logged.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0; `bash .claude/scripts/verify-deploy.sh` exits 0 (`15 check(s), 0 failure(s)`).
- `git diff --stat` over `FormalSystem/`, `Tests/` and `docs/` across this task's six commits is EMPTY.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 809 .` could NOT run: no Challenge manifest exists for this task (exit 71, `no manifest found`), because the plan round pinned its Challenge block in the plan file without taking a snapshot. Substituted a stronger, self-contained check: a mechanical declaration-by-declaration diff of the probe against the plan's own `## Lean Challenge Statements` block, reporting all 91 declarations present and ZERO signature mismatches. The named check is advisory-only, so this does not affect `verification_passed`; it is recorded in this task's issue log.
- Gate-7 mechanical check: no `WorldHistory`, `PlusTruthAt`, `tpOf`, `cellAt` or `anchorCells` anywhere in the file outside the header's own Gate 7 section.
- `grep "ladderRealized\|LadderCons"` matches header prose only; `grep "ULive\|DischBwd\|SLive"` matches header prose only — never a definition or a theorem statement.
- `cert_accepts_Rchi` precedes every negative statement ABOUT the certificate and the candidate sets (`rev_eu_lfp_empty`, `cert_rejects_Rev`, `profR_separates_gate6_pair`) by line number. It does NOT precede `au_lfp_ne_eu_lfp_on_exit_graph` or `chi_closure_box_snce_stab_free`, which the plan's own pinned Challenge-block ORDER places earlier; that internal tension in the plan was resolved in favour of the pinned order and is recorded in this task's issue log.
- Scope Hypotheses, every one CONFIRMED rather than trusted: the exit-graph fixpoints are `{3}` (universal) and `{0, 1, 2, 3}` (existential); `(plusSubformulaClosure chi).card = 18`; the `untl`-member counts of `Ta`/`Tb`/`Tc` are `0`/`1`/`1`; the restricted profile's three values are `{(a5, Ta)}`, `{(c5, Tc)}`, `{(b5, Tb)}`; and the `WIRED` array held 37 entries before this round and 38 after.
- Files verified: yes.

### Carried figures and verdicts — read from an earlier record, not re-run here

- Gates 1 and 2's n-side qualification: `nside-modulus-gate.lean`, Branch N-VERIFIED.
- Gate 3: the sixteenth probe's `second_region_sets_agree` and `region_start_beyond_depth`.
- Gates 4 and 5: the eighteenth probe's header and `reach5_eventually_constant`.
- Gate 6's own row: the eighteenth probe's `prof6_separates_gate6_pair`.
- Eventual periodicity of the UNRESTRICTED countdown: the seventeenth probe,
  `closure-indexed-periodicity.lean`.
- The finiteness and bound on the SET of cells: `anchorCells_finite`, `anchorCells_ncard_le`.

## Impacts

- A successor round now has a compiled presentation to attack rather than a definition to read:
  the certificate's six fields are stated, non-vacuous, and strictly stronger than local
  coherence on the fixture, so the next question is sufficiency and not shape.
- The strength question is closed as a matter of compiled fact: a cell-level fulfilment condition
  cannot be the tree's landed universal one, and any future attempt to reuse `ULive`,
  `Disch`, `SLive` or `DischBwd` on the object-closure product has to answer
  `au_lfp_ne_eu_lfp_on_exit_graph`.
- The existential fixpoint and its guarded-path characterization are generic over an arbitrary
  `DecidableEq` carrier, so a later decision to upstream them into `FormalSystem/` is a move, not
  a rewrite.

## Follow-ups

- The SUFFICIENCY half of adequacy — that the six conditions imply realizability — is NOT
  STARTED. The dovetailing argument lives in `reports/01_realizable-type-adequacy.md` §6 and is
  marked uncompiled there.
- Standing obligations (b), (c) and (d) are untouched, as are gates 1, 2, 3 and 9.
- Gate 8 stays SIDESTEPPED: exercising the `stab` and `box` clauses needs a fixture whose closure
  has `stab` members, which this one does not.
- A seventh mechanism may exist that none of this exercises. A gate probing one coordinate
  certifies one coordinate only.

## References

- `specs/809_realizable_type_adequacy_countdown_profile/plans/01_realizable-type-certificate.md`
- `specs/809_realizable_type_adequacy_countdown_profile/reports/01_realizable-type-adequacy.md`
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` (the eighteenth probe)
- `specs/evidence/seam-gluing-ray-product/nside-modulus-gate.lean` (the nineteenth)
- `specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean` (the twentieth)
- `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` (the seventeenth)
- `specs/806_set_valued_cell_quotient_index/reports/01_closure-indexed-periodicity-gate.md`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` (`AUFix`, the substrate)
- `specs/809_realizable_type_adequacy_countdown_profile/issues.jsonl`
