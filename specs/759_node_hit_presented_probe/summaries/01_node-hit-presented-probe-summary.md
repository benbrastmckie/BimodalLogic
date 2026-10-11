# Implementation Summary: Task #759

- **Task**: 759 - Node fixture probe: HitPresented for a ⊡-bearing formula at an infinite-width seam (hitPresented_node or its negation)
- **Status**: [COMPLETED]
- **Started**: 2026-10-11T01:45:28Z
- **Completed**: 2026-10-11T02:28:54Z
- **Effort**: ~50 minutes wall-clock, one dispatch, nine phases
- **Dependencies**: 758 (serialization edge on the shared gate script and RaySummary README; discharged, 758 is [COMPLETED])
- **Artifacts**: plans/01_node-hit-presented-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The POSITIVE headline is landed and wired: `Probe759.hitPresented_node` proves `HitPresented M τ t Φ (labN (windowN m k)) (stepN (windowN m k)) k` on the library fixture `NoFiniteWidth.M` for every `τ` with `τ.state t = .pre m` and every depth `1 ≤ k`, with the presentation size `windowN m k + 5`, `windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1)`, exhibited in the statement (no `∃ L`) and bounded uniformly over every seam by `card_QN_le`. The dispatch's single-index shape is `hitPresented_node_canon`; the by-product `presented_node` records why the negative headline is false on `Node` (finite seam fibre), so no Stage 0 ruling arises. The route is the model-A truncation argument transplanted to `Node`: seam classification in place of rigidity, four relative-position letter classes over the 28-member closure, containment as a fixture fact, the library's periodicity and `familyTriples_subset_deleteRun`, and a one-gadget presentation whose anchored runs are exactly the window.

## What Changed

- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` — new wired probe (1434 lines, `namespace Probe759`): header (formula order `Φ`, `D`, `⊡Xp`; which headline; fixture; argument; bound verdict; what `Node` does and does NOT test; guardrails (a)–(e); OBSERVED axiom record; compile line); `through_pre`/`canon_through`/`hitCl_eq_through`/`hitCl_pre` (seam classification, general `τ`); transcribed `truth_A'/C'/D`, `truth_stab*`; lists `T₂ T₁ T₀ Tₙ` (17/17/15/16 members) and vectors `ℓ₂ ℓ₁ ℓ₀ ℓₙ`, `letterAt`; class lemmas `truth_class₂/₁/₀/ₙ` (one `simp +decide only` each) and the bridge `clTrace_canon_apply`/`clTrace_canon_eq`/`clTrace_canon_thread_free`; `cN`, `hitCl_pre'`, positional read-outs; `W0_le_seam`, `run_lt_W1` (two-hop cover), `run_subset_middle`, `deleteRun_cN`, `familyTriples_cN_shrink`; `windowN`, `QN`, `card_QN`, `card_QN_le`, `hitCl_eq_truncated_node`; `stepN`/`isNowN`/`vecN`/`labN` (all `def`) with bridge and step read-outs; `run_bwd_A`, `run_after_N₀`, `run_after_Npos`, `runTrace_eq_cN`, `runTrace_mem_of_isRun`, `runZero`/`runPos`, `exists_isRun_runTrace`; `hitPresented_node`, `hitPresented_node_canon`, `presented_node`; "does NOT say" section; 15-line `#print axioms` foot.
- `scripts/check-evidence-probes.sh` — one WIRED table row after `node-cell-stabilization` and one `WIRED=(` entry (27 → 28; gate PASS line now 29).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — one Evidence paragraph (the eleventh wired probe); the (C) row now reads "two fixtures (model A and `Node` …)"; obligation (ii) item 2 now names both Hit-level positives and why no Hit-level negative can exist on `Node`; `Last verified` date.

## Decisions

- Formula `Φ' := Φ` (first in the dispatch's order); fallbacks not needed. Headline positive; the negative is provably false on `Node` and the header says so without any Stage 0 ruling.
- Primary binder is a general `τ` with `hτ : τ.state t = .pre m` (`HitCl` depends on the seam only through its state); seam index `m` and depth `k` kept independent, identified only in the corollary.
- The four class lemmas close by the plan's primary route (one `simp +decide only` over the enumerated closure with `decide` on list membership); the fallback evaluator was not needed.
- One shared pointwise bridge `runTrace_eq_cN` serves the `⊆` direction and both witness runs, so the seven-case positional comparison is written once.
- `windowN`, `card_QN`, `card_QN_le` are counts; no minimality claimed; `k` free; `labN`/`stepN` are `def` and compute (`#guard`s at `L = 2`).

## Plan Deviations

- **Phase 2** altered: `T₋`/`ℓ₋` are `Tₙ`/`ℓₙ` — the subscript minus (U+208B) is not a Lean identifier character. No statement changed.
- **Phase 3** altered: the negative class lemma is `truth_classₙ`; `truth_class₀` substitutes `s = t'` instead of feeding it to `simp` (which made every other hypothesis unmatched); a `letter_cases` exhaustion helper and the `letterAt_of_*` selectors were added because raw `rcases ℓ` unfolds `(clSig Φ).preds` and leaves a goal that is not type-correct at reducible transparency.
- **Phase 6** altered: `vecN_N₊`/`stepN_N₊` are `vecN_Npos`/`stepN_Npos` (subscript plus U+208A, same constraint; the state keeps the name `N₊` in prose); `vecN_*` proved by explicit `if_neg`/`if_pos` rewrites; `stepN_iff` added for the witness runs.
- **Phase 7** altered: `run_after_N₊` is `run_after_Npos`; one shared bridge `runTrace_eq_cN` (the plan's per-run trace equalities are its instances); `runPos_val` needs only `i ≤ L`; the witness runs' `now` clause is proved per `split_ifs` branch with `iff_of_true`/`iff_of_false`.
- **Phase 8** altered: the axiom record's "no sorryAx" phrase is written "no placeholder axiom" so the plan's literal grep prints nothing; the observed foot has `stepN` axiom-free and `labN` at the three standard axioms (as model A's `labOf`), which the record states together with where `Classical.choice` enters.
- **Phase 9** skipped item: the advisory `lean-challenge-snapshot.sh --check 759 .` found no Challenge manifest (none was snapshotted at plan time), so it exited 71 and was treated as skipped; the nine Goals identifiers were spot-checked by grep instead (all present with the planned signatures).

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build` (detached): guard exit 0, `Build completed successfully (2840 jobs)`, 0 `error:` lines in the captured log (Tiers 1–2); Tier 3 (`.olean` newer than source) is vacuous here — this task touched no module in the build graph (the probe is outside it; the README is markdown).
- Probe: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` exit 0, 0 errors, 0 warnings (re-run after the last edit); `#guard (plusSubformulaClosure Φ).card = 28` and `#guard Fintype.card (QN 2) = 7` pass; all fifteen `#print axioms` lines read `[propext, Classical.choice, Quot.sound]` except `stepN` ("does not depend on any axioms"); no `sorryAx`.
- Evidence gate: `bash scripts/check-evidence-probes.sh` exit 0, `PASS  all 29 wired probe(s) compile`, `seam-gluing-ray-product/hit-presented-node  PASS`; `bash -n` exit 0; `WIRED` 27 → 28, `WIRED_REPO` 1.
- `scripts/check-module-invariants.sh` exit 0 (ALL CHECKS PASSED; C9 and C9D PASS).
- `scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exit 0 (RESULT: PASS).
- `.claude/scripts/verify-deploy.sh` exit 0 (14 checks).
- `.claude/scripts/check-task-references.sh --quiet`: the two deliverables edited here carry 0 occurrences; the repo-wide run exits 1 with 198 pre-existing occurrences in files this task did not touch — recorded in the issue log as baseline, not a regression (the preceding probe task's summary reports the same figure).
- Sorry count: 0 (census over the resolved source roots and over the probe)
- Vacuous count: 0 in files touched by this task (the repo-wide single-line regex reports 1 pre-existing hit, `FormalSystem/Examples/TemporalStructures.lean:495`, identical at baseline `d3c5762e8`; recorded in the issue log)
- Axiom count: 14 over the resolved source roots, equal to the baseline 14 at `d3c5762e8`; the probe declares no axiom
- Tests: N/A (no test module touched; the full `lake build` covers `Tests/`)
- Files verified: Yes
- Plan compliance: all nine Goals identifiers present with the Challenge-block signatures (`windowN`, `QN`, `card_QN`, `card_QN_le`, `labN`, `stepN`, `hitPresented_node`, `hitPresented_node_canon`, `presented_node`); `--check` advisory skipped for want of a manifest.

## Impacts

- Requirement (C)'s Hit-level hypothesis now has a second positive fixture, the first on a ⊡-bearing alphabet and an infinite-width model; the README's (C) row and obligation (ii) item 2 reflect it, and route R1 is not blocked by this probe.
- The probe tests satisfiability and the uniform count, not the truncation argument's necessity: `Node`'s seam fibres are finite, so a future Hit-level falsifier for (C) needs a seam with infinitely many histories through it.
- No library file under `FormalSystem/` changed; nothing imports the probe; the gate keeps it compiled.

## Follow-ups

- The general-row (H5) and lift successors remain the user's to schedule; nothing here abandons or re-scopes them.
- The two repo-wide baselines (198 task-reference occurrences outside the touched files; one `:= trivial` in `Examples/TemporalStructures.lean`) predate this task and are recorded, not fixed, here.
- Snapshotting a Challenge manifest at plan time would let the advisory `--check` run on future probes of this shape.

## References

- specs/759_node_hit_presented_probe/plans/01_node-hit-presented-probe.md
- specs/759_node_hit_presented_probe/reports/01_node-hit-presented-probe.md
- specs/759_node_hit_presented_probe/prototype/node-hit-presented-proto.lean
- specs/759_node_hit_presented_probe/handoffs/ (phase-1 … phase-9 handoffs)
- specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean (template)
- specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean (transcription source)
- specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md (design of record, Section B and H2)
