# Implementation Summary: Task #762

- **Task**: 762 - (C)'s general row: exists_hitPresented with sizeBound φ k a count, for every regular ℤ-model (run-layer phase 3)
- **Status**: [COMPLETED]
- **Started**: 2026-10-13T01:43:42Z
- **Completed**: 2026-10-13T03:38:35Z
- **Effort**: one implementation dispatch (fourteen phases, fourteen phase commits)
- **Dependencies**: 759 (logical edge, discharged at research time: `Probe759.hitPresented_node` is a Hit-level positive, so the Stage 0 "statement is false" branch never fired)
- **Artifacts**: plans/01_hit-presented-general-row.md, reports/01_hit-presented-general-row.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Requirement (C)'s general row is a theorem. `exists_hitPresented` (`FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean`) states, verbatim as filed, that for every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k` there is a finite labelled presentation with `Fintype.card Q ≤ sizeBound φ k` satisfying `HitPresented M τ t φ lab step k`, with `sizeBound φ k := Nat.card (KType (clSig φ) k) ^ 3 * (4 * Nat.card (Profile (clSig φ) k) ^ 2 + 1)` exhibited in the statement as a count of depth-`k` types and of their profiles. The route is the research report's Ramsey-over-profile argument across three new sibling modules (`Profile.lean`, `Periodic.lean`, `HitComplete.lean`), proved sorry-free at `[propext, Classical.choice, Quot.sound]`, pinned at the two C14 sites and in `docs/theorem-index.md`, with the RaySummary README's (C) row, (W) row, obligation (ii) item 2, bound section and Evidence prose amended.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Profile.lean` — new module (578 lines): star languages `StarZero`/`StarPlus`/`PrefixStar`; the σ-star profile `starProfile`, the finite type `Profile sig k` (stepwise `Fintype`/`DecidableEq` instances; `card_profile`), `profile`, `cutProfile`; `typeNil` and `kTypeOf_listSeg_eq_typeNil_iff`; the read-outs `starPlus_iff_profile`/`prefixStar_iff_profile`; the composition law `starProfile_append` (explicit four-case law via `starZero_split` and the representative product `TypeMul`) and `profile_append_congr`, `profile_flatten_congr`; bounded representatives `cutProfile_delete`, `exists_eq_cutPair_of_length_ge`, `exists_rep_of_length_lt`(`_ne_nil`).
- `FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean` — new module (≈1630 lines, `longFile` baseline 1700): `periodicLetter`/`periodicColouring` (computable `DecidablePred`), `fwdPeriodic`, `bwdPeriodic`, the label read-outs; `FwdTypes`/`BwdTypes` with `fwdTypes_congr`/`bwdTypes_congr`, `kTypeOf_segZ_congr`, `exists_seg_of_strictMono`/`_strictAnti`; `exists_blocks_fwd` (Ramsey); the piece refinement (`pieceOff`, `refineIdx`, `refineCut`, `mem_fwdTypes_of_pieces`, `mem_fwdTypes_of_stretches`); the cut transport `fwdTypes_fwdPeriodic_subset` and `exists_periodic_fwd`; the reversal section (`kEquiv_dual`, `listSeg_reverse_kEquiv_dual`, `kTypeOf_listSeg_reverse_congr`, `revType`, `reflectColouring`, `kTypeOf_segZ_reflect`, `revType_segZ`, `mem_bwdTypes_iff_reflect`, `reflectColouring_bwdPeriodic`) and `exists_periodic_bwd`; the seam (`letterAt`, `labels_single`, `not_now_of_eq_segments`, `now_mem_middle`, `segmentFactorization_lt`, `mem_familyTriples_iff_tails`); the assembly (`fwd_now_free_transfer`, `bwd_now_free_transfer`, `periodicLetter_glue_lt`/`_gt`/`_t`, `exists_periodic_subfamily`).
- `FormalSystem/Metalogic/Decidability/RaySummary/HitComplete.lean` — new module (≈670 lines): `GadgetState`, `gadgetLab`, `gadgetStep` (with a `#guard` step table on a two-letter toy), `gadgetRun`, `gadgetLab_gadgetRun`, `runTrace_gadgetRun`, `mid_of_now_unique`, `isRun_gadgetRun`, `eq_gadgetRun_of_lab_now`, `gadgetStep_inr_unique`, `gadgetStep_pred_unique`, `isRun_gadget_iff`, `hitOf_gadget_eq`; `sigmaLab`, `sigmaStep`, `isRun_sigma_iff`, `hitOf_sigma_eq`, `card_sigma_le`; `sizeBound`, `exists_hitPresented`.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` — the three imports and three aggregator docstring bullets naming (C)'s settlement.
- `scripts/check-module-invariants.sh` — three C14 baseline/`#print axioms` pairs (`exists_hitPresented`, `exists_periodic_subfamily`, `profile_append_congr`) and one block-comment paragraph; `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — three "What is pinned" rows, one prose paragraph, three `#guard_msgs` pin pairs; `docs/theorem-index.md` — three rows after `hitCl_modelOf_eq_hitOf`.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — "What it holds" rows for the three modules, the (C) row rewritten as SETTLED in general, the (W) row's obligation (ii) clause, obligation (ii) item 2 marked landed, the Successor paragraph, a "The bound in general" paragraph, the Evidence sentence on falsifiers, `Last verified`; `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks (INV check); `typst/generated/status.typ` — regenerated.

## Decisions

- **Phase 7 took route (b), the reversal transfer**, not the plan's default duplication: the Ehrenfeucht–Fraïssé game `kEquiv_iff_backForth` is symmetric under reversing the order (the atom `order i j` becomes `order j i`), so `kTypeOf (listSeg l.reverse)` is a function of `kTypeOf (listSeg l)` in about sixty lines, reusing `dualStructure`/`kEquiv_of_dualStructure` from `GroupModel/MonoDiscrete.lean` (whose name a module-scoped build did not reveal as a clash; the full build did). `exists_periodic_bwd` is then `exists_periodic_fwd` on the reflected colouring `reflectColouring c p z := c p (-z)`.
- **The refinement of piece stretches into a factorization is one generic lemma** (`refineIdx`/`refineCut`, `mem_fwdTypes_of_pieces`), used by both the membership and the containment half of the forward transport, instead of two ad hoc re-cuttings.
- **`now`-freeness of the periodic tails is transferred along the shared tail type** (`fwd_now_free_transfer`, type-visibility of `now` at `k ≥ 1`), not letter by letter, so `exists_periodic_fwd`'s pinned signature needed no extra conjunct.
- **The headline's set equality is proved pointwise** (`mem_hitOf_iff` on the union, `isRun_sigma_iff`, `hitOf_gadget_eq`): rewriting with `hitOf_sigma_eq` hit an `isDefEq` heartbeat timeout on the union's `hitOf` instance terms. `hitOf_sigma_eq` itself is landed, pinned, and stated with the Challenge block's raw lambdas.
- Theorems whose statements do not consume the instance are over `[Finite sig.preds]` with `Fintype.ofFinite`/`Classical.decEq` in the proof (the style guide's recipe); the pinned statements that mention `SegmentFactorization`/`familyTriples` carry `[Fintype sig.preds] [DecidableEq sig.preds]` as those do. `gadgetRun` takes `hw : w ≠ []` and `hv : v ≠ []`, needed to form its `Fin` indices.
- `Periodic.lean` crosses the package-wide 1500-line limit and carries the sanctioned `set_option linter.style.longFile 1700` after its docstring; the three-module split is the plan's.

## Plan Deviations

- **Phase 1** altered: the `Fintype`/`DecidableEq` instances on `Profile sig k` need two inner `haveI` helpers (instance search does not reach three nested function levels); `card_profile` landed over `[Finite sig.preds]`.
- **Phase 2** closed as stated — the strengthening fallback was not needed; the product is on representatives (`TypeMul`/`typeMul_iff`).
- **Phase 3** altered: the nonempty corollary is `exists_rep_of_length_lt_ne_nil` (no prime).
- **Phase 4** altered: `labels_append` already exists in `Transport.lean` (imported); the read-outs are `labels_periodicColouring_mid/_slice/_period/_replicate/_bwd`; the profile-of-`n`-periods fact is the label-list equality `labels_periodicColouring_replicate` (profile equality is then `rfl`); no shift lemmas were needed.
- **Phase 5** altered: blocks are returned as a cut sequence `V` (`labels c (V a) (V (a + 1))` is the block), so no `blockStart` helper; `starZero_labels` is the coverage lemma.
- **Phase 6** altered: the re-cutting at piece boundaries is the generic `mem_fwdTypes_of_pieces`/`mem_fwdTypes_of_stretches`.
- **Phase 7** altered: route (b) (above); no `exists_blocks_bwd`.
- **Phase 8** altered: the middle clause is the ∃-form `∃ lβ lα, type lβ = β ∧ type lα = α ∧ x.2.1 = type (lβ ++ letterAt c t :: lα)` (the plan grants this shape freedom); helpers `segmentFactorization_lt`, `not_now_of_eq_segments`.
- **Phase 9** altered: `now_free_of_periodic` is the pair `fwd_now_free_transfer`/`bwd_now_free_transfer` plus the glue agreements `periodicLetter_glue_lt/_gt/_t`.
- **Phase 10** altered: `gadgetRun hw hv b`; determinism as `gadgetStep_inr_unique`/`gadgetStep_pred_unique`; `mid_of_now_unique` derives `b ≤ t < b + |m|` from `hnow` alone.
- **Phase 12** altered: the union bound is `card_sigma_le` via `Fintype.card_sigma`/`Finset.sum_le_sum`/`Finset.sum_const`.
- **Phase 13** altered: the realized-set equality is proved pointwise (above); `#print axioms` lines recorded here rather than in a progress file.
- **Phase 14**: the inventory blocks of `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` (all in `file_scope`) were regenerated because the INV check requires it after new modules land; the `Paper:` lines C15 requires were added to `exists_periodic_subfamily` and `profile_append_congr`; two unused `[Finite sig.preds]` binders flagged by C16's env_linter batch were removed.

## Verification

- Build: Success (full guarded `lake build`, detached; every module `.olean` newer than its source)
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: 0 in every file this task touched (the repo-wide single-line grep reports one pre-existing hit, `int_domain_universal` in `FormalSystem/Examples/TemporalStructures.lean`, where the domain predicate is genuinely constant — predates this task, not a placeholder)
- Axiom count: unchanged from baseline (`grep -rn "^axiom " FormalSystem/`)
- `#print axioms`: `FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented`, `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily`, `FormalSystem.Metalogic.WeakCanonical.profile_append_congr` — each `[propext, Classical.choice, Quot.sound]` (lean_verify and the C14 pins at both sites)
- Tests: Passed (`lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest`, the six new `#guard_msgs` pass, zero warnings)
- Gates: `check-module-invariants.sh` ALL CHECKS PASSED (exit 0, after the INV inventory re-emit, the C15 `Paper:` lines and the C16 binder removals); `readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` PASS; `check-task-references.sh --quiet` PASS on every touched file and repo-wide (0 occurrences); `typst-sync-check.sh --fix` PASS (`status.typ` counts only); `verify-deploy.sh` exit 0
- Plan compliance spot-check: all twenty Goals identifiers are declared in the source roots; no replacement target in the plan
- Files verified: Yes
- Line counts: `Profile.lean` 578 (plan 900-1200 for the whole module — the composition law and pumping were shorter than projected), `Periodic.lean` ≈1630 (plan 1100-1400; the reversal section and the seam are the overrun), `HitComplete.lean` ≈670 (plan 700-1000)

## Impacts

- The run layer's phase 3 is closed: at every seam of every regular `ℤ`-model the realized family triples are those of a finite presentation of exhibited size, so (W)'s obligation (ii) is open on its soundness half only; the README records this on the (C) row, the (W) row and obligation (ii) item 2.
- `Profile.lean`'s composing summary and `Periodic.lean`'s one-sided transports are model-free and reusable for any "ultimately periodic witness" argument over `k`-types; `kTypeOf_listSeg_reverse_congr` (reversal transfer through the order dual) is new infrastructure beside `GroupModel/MonoDiscrete.lean`'s duality.
- The deletion surgery of `Transport.lean` and its transport `↔` are not used by the general row and remain a non-goal; the two fixture probes stay as exhibitions with their own counts.
- Nothing here states `Decidable (PlusValidZTime φ)`, a complexity bound, or anything about `⊡(Pp)`; `Presented` stays refuted as a completeness carrier.

## Follow-ups

- The constant `4 P ^ 2 + 1` per gadget and `N ^ 3` gadgets are loose by design (the plan kept the report's shape); a tighter count is possible but is not a goal.
- `hitOf_sigma_eq` is pinned but not consumed by the headline (the pointwise route avoids an `isDefEq` timeout); a future consumer wanting the equation form should state the union presentation through `sigmaLab`/`sigmaStep` and rewrite before unfolding `hitOf`.
- The plan's Challenge block declares `sig`/`k` explicit on every statement "so the block type-checks standalone"; the landed declarations keep `sig` explicit and the Finite/Fintype binder choices above — an advisory `lean-challenge-snapshot.sh --check` would report those binder-level differences, none a weakening.

## References

- specs/762_hit_presented_general_row/plans/01_hit-presented-general-row.md
- specs/762_hit_presented_general_row/reports/01_hit-presented-general-row.md
- specs/762_hit_presented_general_row/handoffs/ (phase-end handoffs for Phases 1-9)
- specs/762_hit_presented_general_row/issues.jsonl
- FormalSystem/Metalogic/Decidability/RaySummary/README.md ("The verdict", (C) row; "The bound in general")
- docs/theorem-index.md (rows `exists_hitPresented`, `exists_periodic_subfamily`, `profile_append_congr`)
