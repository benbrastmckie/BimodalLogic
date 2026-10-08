# Implementation Summary: Task #742

- **Task**: 742 - Compute Hit: the per-model realizability device (B1-B3) between the seam bridge and the decidable stab check
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T09:10:01Z
- **Completed**: 2026-10-08T10:50:00Z
- **Effort**: ~150 minutes across six dispatches (Phases 1-6 of 10; per-phase dispatch, `--hard`)
- **Dependencies**: 737 (complete), 711 (complete)
- **Artifacts**: plans/01_compute-hit-realizability-device.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Six single-phase dispatches so far. Dispatch 3 implemented Phase 1 (B3a): the compiled research
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
defined, by design (research Finding 4): composition is a congruence on representatives.
Dispatch 7 implemented Phase 5 (B2a (ii), the uniqueness half of HWZ 2000 Thm 14 ⇒): `Trace.lean`
now proves that a colouring over the closure alphabet satisfying the run conditions and the
anchors for `σ` IS the closure trace (`eq_clTrace_of_localRun_anchored`, Challenge signature
verbatim), through the inductive core `letter_iff_of_localRun_anchored` (every closure letter of
an anchored local run reads `PlusTruthAt` along `σ`, by structural induction on the closure
formula with the membership proof generalised) and packaged as the `∃!` statement
`clTrace_unique`. With Phases 3 and 5 together, B2a is complete: the trace map is a bijection
between the seam's histories and the anchored local runs over `clSig φ`. Dispatch 8
implemented Phase 6 (B3b (ii), the closure half of effective composition), in the new module
`RaySummary/Present.lean` (split out of `Compose.lean` per the plan's own ~900-line rule): a
finite labelled presentation is unbundled (`Q` with `[Fintype Q] [DecidableEq Q]`, `lab`,
`step`, `now`), its runs (`IsRun`) and their decidable traces (`runTrace`) are defined, its
finite paths are the inductive `StepPath` with the list reading `stepPath_iff`, and the
representative-carrying closure `pathClosure` computes — by `kTypeOfFin` on one stored label
list per key, justified by `kTypeOf_listSeg_append_congr` — the finite sets `pathTypes` (the
`k`-types of the `now`-free paths between two states) and `pathTypesNow` (paths reading `now`
once), with the membership characterizations `mem_pathTypes_iff` / `mem_pathTypesNow_iff`
proved sound (induction on the iterate) and complete (induction on `StepPath`, stationarity
within `closureBound` rounds by the generic `iterate_stabilizes`). Liveness is decided as the
greatest fixpoint of a pruning step (`live`, `live_iff`), instantiated to `fwdLive`/`bwdLive`
with `fwdLive_iff`/`bwdLive_iff` in the plan's statement. Everything evaluates: a two-state
presentation at depth 1 runs in seconds. Still nothing about `Hit` is computed and no model is
constructed from a colouring: `hitOf` and `mem_hitOf_iff` (Phase 7), the B2b verdict probe
(Phase 8), the per-model bridge (Phase 9) and the documentation pass (Phase 10) remain
`[NOT STARTED]`.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/Present.lean` — new (684 lines, Phase 6):
  `iterate_stabilizes`; `IsRun`, `runTrace`, `runTraceDecidablePred`, `pathLabels`,
  `pathLabels_singleton`, `pathLabels_append`, `StepPath`, `stepPath_iff`; `PathEntry`,
  `PathEntry.key`, `PathEntry.key_inj`, `PathEntry.instDecidableEq`, `Realizes`, `extendEntry`,
  `canExtend`, `Extendable` (with its `DecidablePred` instance), `closureStep`, `singleEntry`,
  `closureInit`, `closureIter`, `closureBound`, `closureBound_eq`, `pathClosure`, `pathTypes`,
  `pathTypesNow`, `subset_closureStep`, `iterate_closureStep_subset`, `closureIter_eq_iterate`,
  `closureStep_pathClosure`, `iterate_subset_pathClosure`, `realizes_singleEntry`,
  `realizes_extendEntry`, `realizes_of_mem_iterate`, `exists_key_mem_closureStep`,
  `exists_mem_iterate_of_stepPath`, `mem_pathTypes_iff_stepPath`,
  `mem_pathTypesNow_iff_stepPath`, `mem_pathTypes_iff`, `mem_pathTypesNow_iff`; `pruneStep`,
  `liveSet`, `live`, `HasChain`, `pruneStep_subset`, `pruneStep_liveSet`,
  `hasChain_mem_iterate`, `hasChain_of_mem_fixed`, `live_iff`, `fwdLive`, `bwdLive`,
  `fwdLive_iff`, `bwdLive_iff`. Header: what a presentation is and the two things deliberately
  not imposed on it (the run conditions, which traces of histories satisfy as a consequence —
  the recorded decision dropping the research's `dischargeSet` key — and B2b's product/liveness
  structure); how the closure keeps one representative per key; liveness as a greatest fixpoint;
  computability; no complexity bound.
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` — one-line pointer to
  `Present.lean` (Phase 6); otherwise unchanged.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — imports `Compose` and `Present`
  (Phase 6) and now lists all six modules (`Closure` and `Trace` were imported but unlisted).
- `FormalSystem.lean` — library-root imports for `Compose` (omitted by Phase 4 despite its
  summary line below) and `Present` (Phase 6).
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` — new (297 lines, Phase 4):
  `listSeg`, `listSeg_interp`, `listSegFintype`, `listSegDecidableEq`, `listSegDecidableLT`,
  `listSegDecidablePred`, `kTypeOfFin_listSeg`, `labels`, `labels_length`, `labels_getElem`,
  `segZToListSeg`, `segZToListSeg_strictMono`, `segZToListSeg_surjective`,
  `kTypeOf_segZ_eq_listSeg`, `appendSummand`, `appendPt`, `appendPt_strictMono`,
  `appendPt_surjective`, `listSeg_append_kEquiv`, `kTypeOf_listSeg_append_congr`. Header: what
  "effective composition" means here and why there is no `compose` on bare `k`-types; no
  complexity claim; the module is deliberately not yet imported by `RaySummary.lean` (Phase 6).
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` — extended (165 → 249 lines,
  Phase 5): new section `Uniqueness` with `letter_iff_of_localRun_anchored`,
  `eq_clTrace_of_localRun_anchored`, `clTrace_unique`; header retitled to cover both halves of
  Thm 14 ⇒ (soundness and uniqueness), the "next module" pointer for uniqueness replaced by the
  in-module account; the B2b-absent paragraph unchanged.
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

- (Phase 6) One closure serves both read-outs: `PathEntry` carries `hasNow : Bool` as the `now`
  budget (`canExtend` refuses a second `now`), and `pathTypes`/`pathTypesNow` filter the same
  `pathClosure` on the flag.
- (Phase 6) The computable iterate `closureIter` stops at the first stationary round and is
  proved equal to the `Nat.iterate` (`closureIter_eq_iterate`), and `closureBound` is computed
  arithmetically (`closureBound_eq`): `Fintype.card (KType sig k)` would enumerate `2^256`
  functions at depth 1, and without the early stop the iterate would run that many rounds —
  with both, the two-state witness runs in seconds.
- (Phase 6) Stationarity is one generic lemma, `iterate_stabilizes` (a measure bounded by `B`
  that strictly grows on every non-stationary step forces `f^[B]` to be a fixpoint), used twice:
  with the key-image cardinality for the closure and with `card Q - S.card` for the pruning step.
- (Phase 6) Liveness is the greatest fixpoint of `pruneStep` rather than the plan's
  reachability-plus-cycle criterion: the fixpoint is closed under successors, so a chain is built
  by `choose` and `Nat.rec` (`hasChain_of_mem_fixed`), and a chain survives every pruning round
  (`hasChain_mem_iterate`); no pigeonhole and no cycle unrolling. `fwdLive_iff`/`bwdLive_iff`
  are the plan's statements verbatim.
- (Phase 6) Instance resolution cannot synthesize `DecidablePred (fun x => b = true ∧ x ∉ S)`
  although `fun _ => instDecidableAnd` typechecks; the closure's filter predicate is named
  (`Extendable`) with its own instance so `Finset.mem_filter` resolves.
- (Phase 6) `List.Chain'` is deprecated at this pin; the list-shaped membership theorems use
  `List.IsChain` (`List.isChain_append`, `List.isChain_singleton`).
- (Phase 5) The uniqueness induction is factored into a named core,
  `letter_iff_of_localRun_anchored : ∀ ψ hψ z, c (clLetter φ hψ) z ↔ PlusTruthAt M σ z ψ`, with
  the closure-membership proof generalised so each induction hypothesis applies at whatever
  membership witness the run clause supplies (`plusClosure_imp_left/right`,
  `plusClosure_untl_left/right`, `plusClosure_snce_left/right`); `eq_clTrace_of_localRun_anchored`
  is then `funext p z; propext` with the marker case from `Anchored.now` and the letter case from
  the core.
- (Phase 5) The `imp`/`untl`/`snce` cases are `rw [hr.<clause> ψ χ hψ z]`, then `rw`/`simp only`
  by the two IHs, then `Iff.rfl` against the `PlusTruthAt` clause — no well-founded argument on
  time, exactly as the plan's Risks row 1 predicted; `box`/`stab` discard their IHs and read the
  anchor directly (`box`'s anchor is independent of `σ`, a per-time datum, and never passes
  through a run condition — the subtlety the plan asked to record in the docstring, and it is).
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

- **Task 6.1** altered: the presentation section landed in a new module `Present.lean`
  (imports `Compose`), per the phase's own Scope Hypothesis rule (merged module measured 932
  lines, past the ~900 trigger); `Present.lean` added to the plan's Files to modify. Finite
  paths are the inductive `StepPath` with `stepPath_iff` for the list reading.
- **Task 6.2** altered: one `PathEntry`-closure with a `hasNow` flag serves `pathTypes` and
  `pathTypesNow`; `closureIter` stops early (proved equal to the iterate) and `closureBound` is
  arithmetic (see Decisions).
- **Task 6.3** altered: completeness by induction on `StepPath` rather than on path length;
  stationarity via the generic `iterate_stabilizes`; both membership theorems stated in the
  planned list shape through `stepPath_iff`, with `_stepPath` inductive forms beside them.
- **Task 6.4** altered: `fwdLive`/`bwdLive` decided as a greatest fixpoint (`live`, `live_iff`)
  rather than reachability-plus-cycle; the characterizations `fwdLive_iff`/`bwdLive_iff` are the
  plan's statements verbatim.
- **Task 6.5** altered: both `Compose` and `Present` imported by the aggregator (and by
  `FormalSystem.lean`, where Phase 4's `Compose` import was found missing).
- **Task 5.1** altered: the structural induction is a separate named theorem
  (`letter_iff_of_localRun_anchored`) rather than inlined under `funext` in
  `eq_clTrace_of_localRun_anchored`; the pinned statement, the case analysis and the
  `clTrace_unique` packaging are as specified. Annotated inline on the plan checklist. Scope:
  84 lines added against a 150-250 hypothesis (the temporal cases are two-line rewrites).
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

- Build: Success — Phase 6: scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary` (guard exit 0, `Build completed successfully
  (1929 jobs)`, 0 errors; `probes/present-build-p6-1.log` had 4 style warnings, fixed;
  `probes/present-build-p6-3.log` 0 errors, 0 warnings); `.olean` newer than source for
  `Compose`, `Present`, `RaySummary`. `lean-sorry-census.sh --cross-check` over the resolved
  source roots: `probes/sorry-census-p6.log`. Phase 5: scoped guarded build of
  `FormalSystem.Metalogic.Decidability.RaySummary.Trace` (guard exit 0, `Build completed
  successfully (1926 jobs)`, 0 errors, 0 warnings, first attempt; `probes/trace-build-p5-1.log`);
  `.olean` newer than source for `Trace`. `lean-sorry-census.sh --cross-check` over the resolved
  source roots: see `probes/sorry-census-p5.log` (result recorded below). Phase 4: scoped guarded build of
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
- Sorry count: 0 (Phase 6: `--cross-check` stripper 0, compiler 0, MATCH, `probes/sorry-census-p6.log`; Phase 5: `--cross-check` stripper 0, compiler 0, MATCH, `probes/sorry-census-p5.log`; Phase 4: `--cross-check` stripper 0, compiler 0, MATCH; Phase 3: `lean-sorry-census.sh` on `RaySummary/` = 0, compiler reported no
  sorry; Phase 2: `--cross-check` stripper 0, compiler 0, MATCH, `probes/sorry-census-phase2.log`).
- Sorry inventory: None
- Vacuous count: 0 introduced (the one repository-wide match,
  `Examples/TemporalStructures.lean:495`, predates this task and was not touched).
- Axiom count: 14 over the resolved source roots (baseline 14; no `axiom` added). Phase 6
  `#print axioms` (`probes/present-axioms-p6.log`): `mem_pathTypes_iff`, `mem_pathTypesNow_iff`,
  `mem_pathTypes_iff_stepPath`, `mem_pathTypesNow_iff_stepPath`, `exists_mem_iterate_of_stepPath`,
  `realizes_of_mem_iterate`, `closureStep_pathClosure`, `closureIter_eq_iterate`,
  `iterate_stabilizes`, `stepPath_iff`, `live_iff`, `fwdLive_iff`, `bwdLive_iff` all exactly
  `[propext, Classical.choice, Quot.sound]`; `#eval` witnesses (two-state presentation over
  `twoLetter`, `now := true`, depth 1, whole file ~7 s): `pathClosure` card `5`,
  `pathTypes false false` card `1`, `pathTypesNow false false` card `1`, `pathTypes false true`
  card `0`, `pathTypesNow false true` card `1`, `fwdLive`/`bwdLive` of `false` at the type of
  `[labW false]` → `true`/`true`, `fwdLive` of `true` there → `false`, `fwdLive` of `false` at
  the type of `[labW true]` → `false`. `pathTypes`, `pathTypesNow`, `fwdLive`, `bwdLive` are
  `def`s, not `noncomputable`. Phase 5
  `#print axioms` (`probes/trace-axioms-p5.log`): `letter_iff_of_localRun_anchored`,
  `eq_clTrace_of_localRun_anchored`, `clTrace_unique` all exactly
  `[propext, Classical.choice, Quot.sound]`. Phase 4
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

- `Closure.lean` is the alphabet and run-condition vocabulary Phases 3 and 5 proved the trace
  sound and unique against: `clTrace_unique` (Phase 5) is what lets Phase 9's `Presented`
  hypothesis be stated as an equality of run sets rather than of histories; `HitCl` and `plusStab_iff_forall_hitCl` (Phase 3) are
  now the exact left-hand side and bridge that Phase 9's `hit_eq_hitOf_of_presented` and
  `plusStab_iff_forall_hitOf_of_presented` rewrite.
- `kTypeOfFin_eq` and `decEval` (Phase 1) are the computability substrate for Phases 4, 6, 7, 9.
- `listSeg`, `kTypeOf_segZ_eq_listSeg` and `kTypeOf_listSeg_append_congr` (Phase 4) are what
  Phase 6's closure composes representatives under; `Compose.lean` and `Present.lean` are
  visible to the library through `RaySummary.lean` and `FormalSystem.lean` as of Phase 6.
- `pathTypesNow`, `fwdLive`, `bwdLive` and their characterizations (Phase 6) are exactly the
  three conjuncts of Phase 7's `hitOf`; `IsRun`/`runTrace` are the run-side vocabulary of
  `mem_hitOf_iff` and of Phase 9's `Presented`.

## Follow-ups

- Phase 7 (B3b (iii), `Present.lean`: `hitOf` and `mem_hitOf_iff`) is next; Phase 8 (verdict
  probe) remains admissible in any wave; Phase 9 is unblocked on its Phase 5 side and waits on
  Phase 7. Note for Phase 7: the plan's Files to modify names `Compose.lean`; the definitions it
  builds on now live in `Present.lean`.
- Phase 10 owns the README, theorem-index rows, axiom pins and ROADMAP updates for both modules.

## References

- specs/742_compute_hit_realizability_device/plans/01_compute-hit-realizability-device.md
- specs/742_compute_hit_realizability_device/reports/01_compute-hit-realizability-device.md
- specs/742_compute_hit_realizability_device/probes/closure-axioms.lean
- specs/742_compute_hit_realizability_device/probes/trace-axioms.lean
- specs/742_compute_hit_realizability_device/probes/compose-axioms.lean
- specs/742_compute_hit_realizability_device/probes/trace-axioms-p5.lean
- specs/742_compute_hit_realizability_device/handoffs/phase-1-handoff-20261008T093113Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-2-handoff-20261008T094458Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-3-handoff-20261008T095427Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-4-handoff-20261008T101155Z.md
- specs/742_compute_hit_realizability_device/handoffs/phase-5-handoff-20261008T102022Z.md
- specs/742_compute_hit_realizability_device/probes/present-axioms-p6.lean
- specs/742_compute_hit_realizability_device/handoffs/phase-6-handoff-20261008T104811Z.md
