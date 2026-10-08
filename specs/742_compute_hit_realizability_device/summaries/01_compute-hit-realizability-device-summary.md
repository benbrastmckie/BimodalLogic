# Implementation Summary: Task #742

- **Task**: 742 - Compute Hit: the per-model realizability device (B1-B3) between the seam bridge and the decidable stab check
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T09:10:01Z
- **Completed**: 2026-10-08T10:13:29Z
- **Effort**: ~110 minutes across four dispatches (Phases 1-4 of 10; per-phase dispatch, `--hard`)
- **Dependencies**: 737 (complete), 711 (complete)
- **Artifacts**: plans/01_compute-hit-realizability-device.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Four single-phase dispatches so far. Dispatch 3 implemented Phase 1 (B3a): the compiled research
probe was transcribed into `KTypeSummary/KTypeFin.lean` — a computable `kTypeOfFin` equal to the
classical `kTypeOf`, a decidable Tarski `eval`, and explicit computable `segZ` instances.
Dispatch 4 implemented Phase 2 (B1): `RaySummary/Closure.lean` widens the two-letter trace
alphabet to the subformula closure of `φ` plus a `now` marker (`clSig`), states HWZ 2000 Def 11's
local run conditions on colourings over it (`LocalRun`) and the anchors that fix what a run
condition cannot (`Anchored`: `now` at `t`, atoms at states, `box` per time, `stab` per state),
defines the full closure trace of a history (`clTrace`, whose two-letter projection is
`seamTrace` by `rfl`), and restates the hypothesis-free `⊡` bridge over an arbitrary finite
signature with distinguished `now`/`phi` letters (`plusStab_iff_forall_hitSig`), of which the
landed `plusStab_iff_forall_hit` is the two-letter instance (`hitSig_twoLetter` by `rfl`, and the
two-letter theorem re-derived as `plusStab_iff_forall_hit'`). Dispatch 5 implemented Phase 3
(B2a (i), the soundness half of HWZ 2000 Thm 14): `RaySummary/Trace.lean` proves that the
closure trace of any history satisfies every run condition (`clTrace_localRun`) and every anchor
(`clTrace_anchored`) — each field is the matching `PlusTruthAt` clause, closed by `Iff.rfl` —
defines the realized set over the closure alphabet (`HitCl`, finite), instantiates the generic
`⊡` bridge there with the anchors discharged by `clTrace_anchored` (`plusStab_iff_forall_hitCl`),
and records reading (R1) as a theorem that is explicitly not a computation (`hitCl_eq_iUnion`:
the union over the seam's ray pairs of the family triples of their traces; `SeqPair` is not
finite). Dispatch 6 implemented Phase 4 (B3b (i), the composition half of effective composition):
`RaySummary/Compose.lean` lands the finite segment of a list of letters (`listSeg`, carrier
`Fin l.length`, computable instances, computable `k`-type `kTypeOfFin_listSeg`), the letters of a
decidable colouring on `[a, b)` (`labels`) with the order isomorphism showing a time-axis segment
has the `k`-type of its label list (`kTypeOf_segZ_eq_listSeg`), the identification of a
concatenation with the two-point ordered sum of its parts (`listSeg_append_kEquiv`), and the
composition congruence `kTypeOf_listSeg_append_congr` — the `k`-type of `l₁ ++ l₂` depends only
on the `k`-types of `l₁` and `l₂`, the `I = J = Bool` instance of the mixing lemma
`kEquiv_orderedSum_of_kEquiv_colour`. No `compose : KType → KType → KType` on bare values is
defined, by design (research Finding 4): composition is a congruence on representatives. Nothing
about `Hit` is computed yet and no model is constructed from a colouring: the uniqueness half of
B2a (Phase 5), the presentation half of B3b (Phases 6, 7), the B2b verdict probe (Phase 8), the
per-model bridge (Phase 9) and the documentation pass (Phase 10) remain `[NOT STARTED]`.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` — new (297 lines, Phase 4):
  `listSeg`, `listSeg_interp`, `listSegFintype`, `listSegDecidableEq`, `listSegDecidableLT`,
  `listSegDecidablePred`, `kTypeOfFin_listSeg`, `labels`, `labels_length`, `labels_getElem`,
  `segZToListSeg`, `segZToListSeg_strictMono`, `segZToListSeg_surjective`,
  `kTypeOf_segZ_eq_listSeg`, `appendSummand`, `appendPt`, `appendPt_strictMono`,
  `appendPt_surjective`, `listSeg_append_kEquiv`, `kTypeOf_listSeg_append_congr`. Header: what
  "effective composition" means here and why there is no `compose` on bare `k`-types; no
  complexity claim; the module is deliberately not yet imported by `RaySummary.lean` (Phase 6).
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — new (165 lines, Phase 3):
  `clTrace_localRun`, `clTrace_anchored`, `clTrace_clPhi`, `familyTriples`, `mem_familyTriples`,
  `hitSig_eq_iUnion`, `HitCl`, `hitCl_finite`, `plusStab_iff_forall_hitCl`, `hitCl_eq_iUnion`.
  Header: Thm 14 ⇒ here, uniqueness in Phase 5, Thm 14 ⇐ is B2b and absent, with research
  Finding 3 (a)-(b) (the fibre is a product; the repair is a product alphabet) folded in.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — imports `Trace` (Phase 3).
- `FormalSystem/Metalogic/Decidability/RaySummary/Closure.lean` — new (310 lines, Phase 2):
  `clSig` with `Fintype`/`DecidableEq` instances, `clNow`, `clLetter`, `clPhi`, `clPhi_eq`,
  `clNow_ne_clLetter`, `clLetter_inj`, `LocalRun`, `Anchored`, `clTrace`, `clTrace_now`,
  `clTrace_letter`, `clTrace_proj`, `nowPhiSig`, `nowPhiSig_depth`, `stabTargetSig`,
  `stabTargetSig_determined`, `stabTargetSig_of_trace`, `nowPhiSig_twoLetter`,
  `stabTargetSig_twoLetter`, `HitSig`, `hitSig_twoLetter`, `hitSig_finite`,
  `plusStab_iff_forall_hitSig`, `plusStab_iff_forall_hit'`.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — imports `Closure` (Phase 2).
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/KTypeFin.lean` — new (193 lines, Phase 1):
  `decAtomEval`, `decNfEvalNf`, `kTypeOfFin`, `kTypeOfFin_eq`, `decEval`, `segZFintype`,
  `segZDecidableEq`, `segZDecidableLT`, `segZDecidablePred`, `kTypeOfFin_segZ`.
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary.lean` — imports `KTypeFin` (Phase 1).
- `FormalSystem.lean` — library-root imports for all three new modules (pre-commit typst-sync gate).
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix` (counts only).

## Decisions

- (Phase 4) Both order isomorphisms are `StrictMono.orderIsoOfSurjective` of an explicit map
  (`segZToListSeg t := ⟨(t - a).toNat, _⟩`; `appendPt ⟨false, i⟩ := i`, `appendPt ⟨true, j⟩ :=
  j + l₁.length`), the idiom of `kEquiv_zFiber_segSum`, fed to `k_equiv_of_iso` exactly as the
  plan routes; the right summand's index is `j + l₁.length` so the letter check is one
  `rw [← List.getElem_append_right']`.
- (Phase 4) `labels` types its lambda binder `(i : ℕ)` explicitly: left to inference, `a + i`
  makes `i : ℤ` and Lean coerces the list `List ℕ → List ℤ` through a monadic lift, defeating
  every `getElem_map` rewrite; `labels_getElem` restates the bound against the unfolded list
  before `simp` for the same reason.
- (Phase 4) `kTypeOf_segZ_eq_listSeg` and `listSeg_append_kEquiv` take `[Finite sig.preds]`,
  what `k_equiv_of_iso` needs; the Challenge-pinned `kTypeOf_listSeg_append_congr` keeps its
  recorded `[Fintype sig.preds] [DecidableEq sig.preds]` binders verbatim under a
  declaration-scoped `unusedFintypeInType`/`unusedDecidableInType` opt-out, the precedent of
  `exists_matching_factorization` in `KTypeSummary/Family.lean`.
- (Phase 4) The mixing lemma's colouring hypothesis is discharged by proving the two
  `kTypeColouring`s equal (`congr 1; funext b; cases b` then `h₁`/`h₂`) and rewriting — the
  "rfl-level equality after rewriting" the plan predicted.
- (Phase 3) The plan's `hitCl_eq_image` item is landed as `hitCl_eq_iUnion` in the
  `⋃ bf, familyTriples …` form the item itself parenthesises, because the literal
  `(fun bf => …) '' Set.univ` is a set of sets and cannot typecheck against `Set (triple)`; a
  generic `hitSig_eq_iUnion` is proved first and the closure instance is its specialisation.
  `HitCl` itself is the Challenge-pinned body verbatim.
- (Phase 3) `plusStab_iff_forall_hitCl` discharges the `now` anchor through
  `clTrace_anchored`'s `.now` field, as the plan asks, and the `phi` anchor through the named
  `clTrace_clPhi` (via `clTrace_letter` at `self_mem_plusSubformulaClosure`) rather than a bare
  `Iff.rfl`, so the dependency is visible.
- (Phase 2) `LocalRun` and `Anchored` are Prop-valued `structure`s with one named field per
  clause (`bot`/`imp`/`untl`/`snce`; `now`/`atom`/`box`/`stab`) rather than nested conjunctions,
  so Phases 3 and 5 project by name. The content is exactly the plan's: the `untl`/`snce` fields
  are `PlusTruthAt`'s clauses verbatim (strict, guard on the open interval), and `atom`/`box`/
  `stab` impose no run condition.
- (Phase 2) `clLetter φ h` takes the subformula implicitly from its `plusSubformulaClosure φ`
  membership proof; since `plusSubformulaClosure φ` unfolds to `(subformulas φ).toFinset`, the
  pinned `clSig` subtype accepts the `plusClosure_*` projections with no conversion.
- (Phase 2) The generic bridge is the SeamMulti proof transcribed verbatim with
  `stabTarget_seamTrace` replaced by `stabTargetSig_of_trace` (stated for an arbitrary `P : ℤ →
  Prop` under the two anchor hypotheses); it compiled on the first build, confirming the plan's
  "restatement with the same proof" expectation (bridge proof length: 14 lines vs 12).
- (Phase 2) `HitSig` keeps the Challenge-pinned `M` binder although its body does not consume it
  (the bridge's anchor hypotheses tie `tr` to `M`); the unused-variable linter is silenced on that
  one `def`, with `set_option … in` placed before the docstring.
- (Phase 1) Instance binders are explicit on every declaration rather than section `variable`s;
  `@decidable_of_iff` takes the target proposition first; `decAtomEval`/`decEval` use the named
  binders directly, never the generic `LinearOrder` decidability (the `ℤ`-instance hazard).

## Plan Deviations

- **Task 4.5** altered: the two order isomorphisms are built by `StrictMono.orderIsoOfSurjective`
  rather than `Equiv.toOrderIso` on a hand-built `Fin (n₁ + n₂) ≃ Σ-lex` (same statements, same
  `k_equiv_of_iso` route); the two non-pinned isomorphism theorems carry `[Finite sig.preds]`
  instead of the section's `[Fintype] [DecidableEq]` (strictly more general; the linters reject
  the unused binders). Annotated inline on the plan checklist.
- **Task 3.5** altered: `hitCl_eq_image` landed under the name `hitCl_eq_iUnion` in the `⋃`
  form (see Decisions); not a Challenge-pinned name. Annotated inline on the plan checklist.
- Otherwise none (implementation followed plan). Additions outside the phases' listed files, all phases:
  `FormalSystem.lean` and `typst/generated/status.typ`, required by the repository's pre-commit
  gate for any new `.lean` file. Phase 2 also adds `plusStab_iff_forall_hit'`, `clTrace_now`,
  `clTrace_letter`, `clPhi_eq`, `clNow_ne_clLetter`, `clLetter_inj`, `nowPhiSig_twoLetter` and
  `stabTargetSig_twoLetter` beyond the plan's list — consistency checks and projections, no new
  claims. Phase 3 adds `clTrace_clPhi`, `familyTriples`, `mem_familyTriples` and
  `hitSig_eq_iUnion` — the named `phi` anchor and the generic form of the (R1) reading.

## Verification

- Build: Success — Phase 4: scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary.Compose` (guard exit 0, `Build completed
  successfully (1924 jobs)`, 0 errors, 0 warnings; `probes/compose-build-2.log`; the first
  attempt `probes/compose-build-1.log` had three errors the LSP sweep had not reported, fixed and
  rebuilt). `lean-sorry-census.sh --cross-check` over the source roots ran its own `lake build`:
  stripper 0, compiler 0, MATCH (`probes/compose-sorry-census.log`). Phase 3: scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary.Trace` (guard exit 0, 1926 jobs, 0 errors; one
  long-line style warning fixed and rebuilt) and of `RaySummary` + library root `FormalSystem`
  (guard exit 0, `Build completed successfully (2832 jobs)`, 0 errors, 0 warnings); `.olean` newer
  than source for `Trace`, `RaySummary`, `FormalSystem`. Logs: `probes/trace-build-1.log`,
  `probes/trace-build-2-library.log`. Phase 2: scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary` (guard exit 0, `Build completed successfully
  (1926 jobs)`, 0 errors, 0 warnings) and of the library root `FormalSystem` (guard exit 0,
  2831 jobs, 0 errors); `.olean` newer than source for `Closure`, `RaySummary` and
  `FormalSystem`. Logs: `probes/closure-build-3.log`, `probes/closure-build-4-library.log`.
- Sorry count: 0 (Phase 4: `--cross-check` stripper 0, compiler 0, MATCH; Phase 3: `lean-sorry-census.sh` on `RaySummary/` = 0, compiler reported no
  sorry; Phase 2: `--cross-check` stripper 0, compiler 0, MATCH, `probes/sorry-census-phase2.log`).
- Sorry inventory: None
- Vacuous count: 0 introduced (the one repository-wide match,
  `Examples/TemporalStructures.lean:495`, predates this task and was not touched).
- Axiom count: 14 over the resolved source roots (baseline 14; no `axiom` added). Phase 4
  `#print axioms` (`probes/compose-axioms.log`):
  `kTypeOf_listSeg_append_congr`, `kTypeOf_segZ_eq_listSeg`, `listSeg_append_kEquiv`,
  `kTypeOfFin_listSeg` all exactly `[propext, Classical.choice, Quot.sound]`; `#eval` witnesses
  at depth 1 on two letters: `[f,g,f]` vs `[f,g,f,g,f]` → `true`, `[f,g,f]` vs `[f]` → `false`,
  `labels … (-1) 2` has length `3`. Phase 3 `#print axioms`
  (`probes/trace-axioms.log`): `clTrace_localRun`, `clTrace_anchored`, `clTrace_clPhi`,
  `hitSig_eq_iUnion`, `hitCl_finite`, `plusStab_iff_forall_hitCl`, `hitCl_eq_iUnion` all exactly
  `[propext, Classical.choice, Quot.sound]`. Phase 2 (`probes/closure-axioms.log`):
  `plusStab_iff_forall_hitSig`, `plusStab_iff_forall_hit'`, `hitSig_twoLetter`, `hitSig_finite`,
  `stabTargetSig_determined`, `clTrace_proj`, `clLetter_inj`, `clNow_ne_clLetter` all exactly
  `[propext, Classical.choice, Quot.sound]`; `stabTargetSig_of_trace` `[propext, Quot.sound]`.
- Plan verification items: `Fintype.card (clSig (p U q)).preds` evaluates to `4`
  (`probes/closure-axioms.log`); `hitSig_twoLetter` and `clTrace_proj` are `rfl`.
- Phase 1 witnesses (dispatch 3): `#eval`s on the two-letter alphabet at depth 1 ran as the
  research probe predicted; the permanent witness module is Phase 9's.

## Impacts

- `Closure.lean` is the alphabet and run-condition vocabulary Phase 3 proved the trace against
  and Phase 5 proves uniqueness against; `HitCl` and `plusStab_iff_forall_hitCl` (Phase 3) are
  now the exact left-hand side and bridge that Phase 9's `hit_eq_hitOf_of_presented` and
  `plusStab_iff_forall_hitOf_of_presented` rewrite.
- `kTypeOfFin_eq` and `decEval` (Phase 1) are the computability substrate for Phases 4, 6, 7, 9.
- `listSeg`, `kTypeOf_segZ_eq_listSeg` and `kTypeOf_listSeg_append_congr` (Phase 4) are what
  Phases 6-7 close a finite set of representative-carrying triples under; `Compose.lean` becomes
  visible to the library when Phase 6 adds it to `RaySummary.lean`.

## Follow-ups

- Phase 5 (B2a (ii), `eq_clTrace_of_localRun_anchored` in `Trace.lean`) is next; Phase 6
  (B3b (ii), `Compose.lean` + `RaySummary.lean`) is now unblocked and admissible in the same
  wave; Phase 8 (verdict probe) remains admissible.
- Phase 10 owns the README, theorem-index rows, axiom pins and ROADMAP updates for both modules.

## References

- specs/742_compute_hit_realizability_device/plans/01_compute-hit-realizability-device.md
- specs/742_compute_hit_realizability_device/reports/01_compute-hit-realizability-device.md
- specs/742_compute_hit_realizability_device/probes/closure-axioms.lean
- specs/742_compute_hit_realizability_device/probes/trace-axioms.lean
- specs/742_compute_hit_realizability_device/probes/compose-axioms.lean
- specs/742_compute_hit_realizability_device/handoffs/phase-1-handoff-20261008T093113Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-2-handoff-20261008T094458Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-3-handoff-20261008T095427Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-4-handoff-20261008T101155Z.md
