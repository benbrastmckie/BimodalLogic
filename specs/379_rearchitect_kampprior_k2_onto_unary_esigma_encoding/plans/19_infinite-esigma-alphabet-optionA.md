# Implementation Plan: Option A — Infinite-Alphabet E[Σ] Re-Encoding (Rabinovich Def 4.1) — Removing `Fintype preds`, Re-Indexing `sigE` onto the Full `Formula` Alphabet, Re-Encoding the `Finset.univ` Enumeration Surface, and Retiring `nf_nvar_exist_all_depths | _k+2` (`KampPrior.lean:562`) LAST

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [NOT STARTED]
- **Effort**: ~60-100 hours across 5 not-started phases (Phase 1 de-risking gate; Phase 2 `Fintype preds` removal; Phase 3 `sigE` infinite re-index; Phase 4 enumeration-surface re-encode, split 4a/4b/4c; Phase 5 ζ re-wire + `:562` retirement), ~1,500-3,000+ new/rewritten Lean lines, ~60-100+ declarations touched. **Blast radius is CONTAINED to `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` + the two foundational files `MonadicFO.lean`/`NormalForm.lean`; Decidability/FMP: 0 files (grep-verified spine-safety).** Phase 1 is the go/no-go GATE and must be green before any of Phases 2-5 are authorized.
- **Dependencies**: None to start (all inputs — the base β/γ/δ shape, the 13a-13d reconciliations, the machine-checked A-vs-B spike — are landed/committed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 5; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here). No task-dependency changes are made by this revision.
- **Research Inputs**: reports/19_architecture-spike-A-vs-B.md (AUTHORITATIVE for this revision — the decisive A-vs-B architecture spike: machine-checked B-refutation `capFn_forces_local`, the A blast-radius map, the grep-verified spine-safety of `sigE`, and the recommended 5-phase Option-A scope with a Phase-1 de-risking gate); reports/18_readback-closed-finite-fl-rescope.md (the NO-GO verdict on the finite-`F` readback closure that superseded plan v18's Phase 13e-1 and forced the A-vs-B decision); the committed machine-checked refutation `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean` (`not_readbackClosed` — no finite `F` satisfies `ReadbackClosed`); the committed B-locality refutation `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean` (`capFn_forces_local` — temporal-reach readbacks uncapturable by any `IntervalType`); reports/17_b5-capture-bound-audit.md, reports/16_zeta-wire-blocker-probe.lean, reports/15_exall-gap-monotone-pinning-verdict.md, reports/14_exall-reordering-closure-resolution.md, reports/13_c1-c2-negation-object-blueprint.md, reports/11_esigma-capture-hypothesis-audit.md, reports/07_faithful-esigma-negation-path.md, reports/09_conjinterleave-interval-type-audit.md, reports/05_conjunction-closure-load-bearing-verdict.md, reports/06_phase4-unblock-construction.md (all carried forward from plan v18)
- **Artifacts**: plans/19_infinite-esigma-alphabet-optionA.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 19_architecture-spike-A-vs-B.md, 18_readback-closed-finite-fl-rescope.md, 17_b5-capture-bound-audit.md, 16_zeta-wire-blocker-probe.lean, 15_exall-gap-monotone-pinning-verdict.md, 14_exall-reordering-closure-resolution.md, 13_c1-c2-negation-object-blueprint.md, 11_esigma-capture-hypothesis-audit.md, 07_faithful-esigma-negation-path.md, 09_conjinterleave-interval-type-audit.md, 05_conjunction-closure-load-bearing-verdict.md, 06_phase4-unblock-construction.md
- **plan_metadata**:
  ```json
  {
    "phases": 5,
    "total_effort_hours": 80,
    "complexity": "complex",
    "research_integrated": true,
    "plan_version": 14,
    "dependency_waves": [[1], [2], [3], [4], [5]],
    "reports_integrated": [
      {"path": "reports/19_architecture-spike-A-vs-B.md", "integrated_in_plan_version": 14, "integrated_date": "2026-07-19"},
      {"path": "reports/18_readback-closed-finite-fl-rescope.md", "integrated_in_plan_version": 14, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean", "integrated_in_plan_version": 14, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean", "integrated_in_plan_version": 14, "integrated_date": "2026-07-19"}
    ]
  }
  ```
  (`plan_version: 14` = predecessor plan v18's internal `plan_version: 13` + 1; the artifact FILE number is `19` per the target path. The `dependency_waves` are `[[1],[2],[3],[4],[5]]` — a fully sequential critical path gated on Phase 1; the human-readable wave table under `## Implementation Phases` is authoritative and expands Phase 4 into the parallel sub-phases 4a → {4b, 4c}.)

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) still carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of the declaration `nf_nvar_exist_all_depths`
(historically line-anchored `:562`, but the line has drifted repeatedly — anchor by DECLARATION NAME,
never by line). Plan v18 attempted to retire it by constructing a finite readback-closed `F`; that path
is now **machine-refuted** (`not_readbackClosed`, `ZetaReadbackClosure.lean`, committed): no finite `F`
can be closed under the ∃∀-readback because the readback image contains formulas of unbounded `untl`-count.
Report 18 surfaced the two remaining faithful architectures A/B; report 19 then decided between them with
machine-checked evidence.

**This revision (plan v19) supersedes plan v18 and commits to Option A: the infinite-alphabet E[Σ] of
Rabinovich Def 4.1 (PDF p.5).** Option A is the only faithful path — Option B is a machine-checked NO-GO
(`capFn_forces_local`, `OptionBLocalityProbe.lean`: any `IntervalType` capture forces 1-type-locality, so
genuine temporal-reach readbacks are uncapturable without novel machinery, forbidden by the no-novel-math
binding). Option A is literally Def 4.1 (E[Σ] = Σ ∪ {all TL(U,S)-formulas over Σ}, **infinite**), requires
no invented mathematics, and is **SPINE-SAFE**: `sigE` is grep-confirmed confined to
`WeakCanonical/Kamp/`, absent from `BXCanonical/` (incl. `Completeness.lean`/`completeness_discrete`) and
absent from `Decidability/` (incl. all of `Decidability/FMP/*`), so the completeness / `completeness_discrete`
/ decidability / FMP spine is not at risk.

**The cost is large but structural, not mathematical.** Option A is a foundational re-encoding of the Kamp
type-representation: (1) `MonadicSignature` structurally requires `Fintype preds`/`DecidableEq preds` as
instance fields (`MonadicFO.lean:41-44`), so an infinite-alphabet signature is not even constructible until
that requirement is removed; (2) the whole `UnaryType`/`IntervalType` model-enumeration layer is built on
`Finset.univ` over a finite alphabet and must be re-encoded onto **per-formula finite atom sets** (each
Rabinovich formula mentions finitely many atoms; Rabinovich never enumerates the whole alphabet). Because
this is a ~1,500-3,000-line rewrite of landed, axiom-clean machinery, the plan is structured so its
**single hardest obligation is a go/no-go GATE in Phase 1** — a bounded, off-path prototype of the
per-formula-finite-atom representation on ONE readback, sorry-free-or-escalate — before any of the
foundational or consumer-surface phases are authorized. There is no third faithful option (finite-`F` is
refuted), so if the Phase-1 gate fails the only defined fallback is escalation.

**Definition of Done (UNCHANGED from v18): `#print axioms completeness_discrete` no longer lists
`sorryAx`**, with the full `lake build` at EXIT 0 and no new axiom or non-permitted sorry anywhere on the
proof term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool,
Lean.trustCompiler, Quot.sound]` — with `sorryAx` REMOVED (Phase 5 deletes the sole on-path
`nf_nvar_exist_all_depths | _k+2` residual, LAST, once the new path is proven green end-to-end).

### Research Integration

- **Report 19 (`reports/19_architecture-spike-A-vs-B.md`, AUTHORITATIVE, newly integrated)**: the decisive
  comparative architecture spike (lean-research-hard-agent, H2+H3+H4). Its contributions consumed here:
  - **Option B ruled out (machine-checked NO-GO).** `capFn_forces_local` (in the committed
    `OptionBLocalityProbe.lean`) proves any `IntervalType`-level capture forces the captured formula's
    truth to be 1-type-local; temporal-reach readback `Until`/`Since` chains are provably non-local, so
    they are capturable by NO `IntervalType sig F`, for ANY `F`. Making B work requires an order-aware
    `IntervalType` with no Def 3.1 counterpart — novel machinery, binding-forbidden.
  - **Option A recommended and de-risked as SPINE-SAFE.** The A blast radius is grep-verified contained to
    `WeakCanonical/Kamp/` (25 live `sigE` consumers + the two foundational files); `sigE` never reaches
    `BXCanonical/`/`Decidability/`; the spine interface is `nf_nvar_exist_all_depths` over the BASE
    signature, which never saw `sigE`.
  - **The 5-phase Option-A scope with a Phase-1 gate** (report 19 §"/revise Scope for plan v19"): the
    per-formula-finite-atom prototype gate, the `Fintype preds` removal, the `sigE` infinite re-index (which
    makes the readback-closure probes vacuous), the enumeration-surface re-encode (hardest site
    `LiftPair.lean`), and the terminal ζ re-wire. This plan adopts that structure verbatim, expanding the
    consumer-surface phase into bounded per-file sub-phases (H8).
  - **The H3 5-column PDF-page mapping table** (report 19): Def 4.1 p.5 (E[Σ] infinite), the p.6 collapse
    note, Def 3.1 p.4 (unary αⱼ/βⱼ), Prop 3.5 p.5, Prop 4.2/4.3 + Thm 4.4 p.6. These are the faithfulness
    anchors for Phases 3-5 and are cited by PDF page throughout.
- **Report 18 (`reports/18_readback-closed-finite-fl-rescope.md`, newly integrated as the superseding
  rationale)**: the NO-GO on the finite-`F` readback closure. It (with `not_readbackClosed`) is the reason
  plan v18's Phase 13e-1 is [BLOCKED] and the reason a fresh architecture (A) was required. Its content is
  the direct provenance of this plan; the two faithful options it surfaced (A/B) were adjudicated by report 19.
- **Committed refutations preserved as landed assets** (NOT rebuilt): `not_readbackClosed`
  (`ZetaReadbackClosure.lean`) — the finite-`F` refutation; `capFn_forces_local`
  (`OptionBLocalityProbe.lean`) — the Option-B locality refutation. See "Preserved / Superseded Assets"
  below for their disposition under the A refactor.
- **Reports 17/16/15/14/13/11/09/07/05/06 (carried forward from plan v18)**: the B1-B4 blocker probe, the
  B5 capture-bound audit, the monotone-pinning verdict, the path-(c) eval-side closure, the arity-0/1
  negation blueprint, the `hCapture`-at-`IntervalType` pin, the ConjInterleave audit, the faithful α-ζ
  phase structure, the conjunction-closure verdict, the Phase-4 unblock construction. Under Option A the
  β/γ/δ negation SHAPE and the `translateProp35` structure these grounded SURVIVE (report 19 comparison
  table); the `Finset.univ` enumeration and the `IntervalType`-level capture they also grounded are
  REWRITTEN (see the asset table).

### Prior Plan Reference — plan v18 SUPERSEDED

**`plans/18_zeta-readback-closed-f-restructure.md` is SUPERSEDED by this plan.** v18 pursued Option (a) of
the earlier decision tree — a finite readback-closed `F` — whose decisive Phase 13e-1 is [BLOCKED]:
`not_readbackClosed` (`ZetaReadbackClosure.lean`, committed) proves NO finite `F` satisfies the committed
`ReadbackClosed` predicate (the readback image has unbounded `untl`-count). Report 18 recorded the NO-GO and
surfaced faithful architectures A/B; report 19 machine-refuted B (`capFn_forces_local`) and recommended A.
This plan replaces v18's blocked `13e-1 → 13e-2 → 13e-3` sequence with the Option-A sequence
`1 → 2 → 3 → 4 → 5`. **Do NOT re-attempt v18's finite-`F` construction — it is machine-refuted.** The Phase
0-12 / 10a / 10b / 10P / 11 / 12 / 13a-13d machinery that v18 preserved is NOT re-executed here either; its
disposition under the A re-encoding is enumerated in "Preserved / Superseded Assets" below (some survives as
structure, much is rewritten under the new type representation — report 19's "Reuse of landed assets: Low"
row for Option A).

### Open Scope Question — RESOLVED to (b)

The task charter's OPEN SCOPE QUESTION (a: re-architect the arms while keeping `nf_eval_nf` in the chain
statements, vs b: a statement/alphabet-level migration) is now **RESOLVED to (b)**. Option A is precisely a
statement/alphabet-level migration: it migrates the `sigE` E[Σ] alphabet from the finite `{A // A ∈ F}`
index onto the infinite `Formula` alphabet of Def 4.1, and re-encodes every statement that quantified over
the finite `Finset.univ` model-enumeration. This resolution is recorded HERE, in the plan; per the reviser
Plan-Revision workflow this plan does NOT edit the state.json task description or task dependencies.

### Preserved / Superseded Assets (do NOT rebuild the preserved ones; do NOT re-execute the superseded ones)

Report 19's "Reuse of landed assets" verdict for Option A is **Low**: the committed
`UnaryType`/`IntervalType`/`LiftPair`/capture proofs are rewritten under the new per-formula representation;
the `canonExpand` semantic core and the `translateProp35`/negation SHAPE survive.

| Landed asset | File | Disposition under Option A |
|---|---|---|
| `not_readbackClosed` (finite-`F` refutation) | `ZetaReadbackClosure.lean` | **PRESERVED as documentation of the finite-`F` NO-GO**, then **VACUOUS + slated for DELETION in Phase 3** (once `sigE` is infinite, readbacks are automatically atoms; the closure question dissolves). |
| `ReadbackClosed` / `*_of_closed` conditionals + circularity findings | `ZetaEngineClosure.lean` | **VACUOUS under infinite E[Σ] + slated for DELETION in Phase 3** (report 19 Phase-3 note: the conditional closure lemmas have no content when every readback is already an atom). |
| `capFn_forces_local` / `intervalHolds_local` (Option-B refutation) | `OptionBLocalityProbe.lean` | **PRESERVED VERBATIM** — the machine-checked record that B is a NO-GO; do NOT delete (it is the justification for choosing A over B). Off-path; unaffected. |
| `canonExpand` semantic core + `temporal_truth_canonExpand` conservativity | `ESigmaExpansion.lean`, `ESigmaCapture.lean` | **Semantic SHAPE SURVIVES** (canonical expansion interp of a fresh atom = `sat A`; old-pred conservativity via `oldPred`). The `esigmaPred A hA` proof-carrying `hA : A ∈ F` membership is **REWRITTEN** in Phase 3 (fresh atoms indexed by the full `Formula`, no `hA`). |
| 10P `esigmaCapture_canonExpand` + `intervalCapture_of_atomNamed` (𝔈-bounded capture) | `ESigmaCapture.lean` | **SUPERSEDED**: the `S := univ.filter (τ names A)` capture is `Finset.univ`-based and rebuilt in Phase 4/5; under infinite E[Σ] the capture obligation is discharged DIRECTLY (readback IS an atom), so the `hCapture`/`capFn` machinery is REMOVED at Phase 5, not re-derived. The conservativity lemma survives. |
| 13a `ZetaAtomMapReconcile` (`Sum.inl`/`Sum.inr` collapse-unwinding) | `ZetaAtomMapReconcile.lean` | **SHAPE SURVIVES** — `sigE` keeps its `sig.preds ⊕ (fresh)` sum structure (only the fresh summand changes from `{A // A ∈ F}` to `Formula`); the collapse-unwinding is re-stated over the new fresh summand in Phase 5. |
| 13b `ZetaPriorTransfer` (prior-axiom / `HasAttainedINF/SUP` transport) | `ZetaPriorTransfer.lean` | **SURVIVES** (carrier/order transport along `temporal_truth_canonExpand`; independent of the alphabet's finiteness); re-checked at Phase 5. |
| 13c `MonadicFormulaMap` (`mapPreds` eval-naturality) | `MonadicFormulaMap.lean` | **SURVIVES** (structural relabelling + `oldPred` conservativity; independent of finiteness); re-checked at Phase 5. |
| 13d `ZetaUniformExtract` (M-uniform extraction + capture threading) | `ZetaUniformExtract.lean` | **PARTIALLY REWRITTEN**: the `S = univ.filter (τ a₀)` model-independent witness is `Finset.univ`-based (Phase 4 re-encode); the N-independence structure survives, but the `capFn`/`hCapture` threading is REMOVED at Phase 5. |
| β/γ/δ negation stack (`efSat_negation_general`, `veeSat_negation`, `translate_correct`) SHAPE | `EFSatNegationGeneral.lean`, `VeeSatNegation.lean`, `Prop43Translate.lean` | **SHAPE SURVIVES** (De Morgan trichotomy, Prop 4.3 structural induction); the `Finset.univ` "type = disjunction over ALL 1-types" enumeration inside them is **REWRITTEN** in Phase 4 onto per-formula finite atom sets. |
| `translateProp35` / `charType` / `skelDisjunct` structure | `Prop35Assembly.lean`, `LiftPair.lean` | **STRUCTURE SURVIVES**, but the `Finset.univ`-enumeration bodies are **REWRITTEN** (Phase 4; `LiftPair.lean` is the hardest single site). |
| `Section5Correspondence` (`prop42_contentful_of_attained`) + `VecEANegFix` (`negFix_iff`) | `Section5Correspondence.lean`, `VecEANegFix.lean` | **SURVIVE** — they live in the `VVecEA2`/bracket world and are structural De Morgan / attained-carrier facts, not `Finset.univ`-enumeration and not `IntervalType` captures (report 19 B2). Re-checked, not rebuilt. |
| `Fintype (UnaryType)` `Finset.univ` model-enumeration (`IntervalType.lean:70`, `LiftPair.lean:101/246/596/869`, `Prop43Translate.lean:344`, `ConjInterleave.lean`) | multiple | **REWRITTEN** — the core of the Phase-4 re-encode; `Finset.univ` over the (now infinite) alphabet does not exist, replaced by per-formula finite atom sets. |

## Goals & Non-Goals

**Goals**:
- **Prove the Phase-1 de-risking GATE**: a per-formula-finite-atom `UnaryType` prototype (`UnaryTypeFin`)
  carrying only the finite `Finset (AtomKind …)` a formula mentions, plus its `intervalHolds`-analog, and
  the Prop-3.5 "type = finite disjunction of atoms" equivalence for ONE `translateProp35 ξ` **without any
  `Finset.univ` over the whole alphabet** — sorry-free and axiom-clean, off the live path, touching NO
  committed file. This is the honest go/no-go on Option A's true difficulty; if it cannot close without
  re-introducing a full-alphabet `Finset.univ`, STOP and escalate (no third faithful option remains).
- **Remove the finiteness type-class requirement** (`Fintype preds`/`DecidableEq preds`) from
  `MonadicSignature` (`MonadicFO.lean:41-44`) and re-derive the `AtomKind`/`NormalForm` instances
  (`NormalForm.lean`) under an explicit per-formula finiteness discipline, so an infinite-alphabet signature
  is constructible.
- **Re-index `sigE` onto the infinite `Formula` alphabet** (Def 4.1 p.5): change the fresh summand from
  `{A // A ∈ F}` to the full `Formula` type; update `esigmaPred`/`canonExpand`/`ESigmaCapture` so a fresh
  atom needs no `hA : A ∈ F`; retire the now-vacuous `ZetaReadbackClosure`/`ZetaEngineClosure` probes.
- **Re-encode the `Finset.univ` enumeration surface** onto the Phase-1 per-formula representation
  (`LiftPair.lean` hardest, plus `Prop43Translate.lean`, `IntervalType.lean`, `ConjInterleave.lean`),
  proving "type = finite disjunction of the atoms the formula mentions" with no total `Finset.univ`.
- **Re-wire the ζ consumers and perform the terminal spine wire** (`ZetaUniformExtract`,
  `EFSatNegationGeneral`): discharge the capture obligation DIRECTLY (the readback is an atom of the
  infinite expansion), removing the `hCapture`/`capFn` parameters; construct the ζ `canonExpand` from the
  surviving 13a/13b/13c reconciliations; re-point `kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery`; verify green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT, then **delete it LAST**; confirm
  `#print axioms completeness_discrete` no longer lists `sorryAx`.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor headers
  only; Rabinovich cited by PDF page, never line number).

**Non-Goals**:
- Introducing any novel mathematics or Feferman-Vaught composition. Option A is literally Rabinovich
  Def 4.1's infinite E[Σ]; no invented content.
- Re-attempting the finite-`F` readback closure (machine-refuted, `not_readbackClosed`) or Option B's
  semantic capture (machine-refuted, `capFn_forces_local`).
- Any arity-4 realization engine, joint-type-over-a-tuple, or `chain_split` (NON-APPLICABLE).
- Touching `EANegation.lean:1090` / `:1249` (three-strikes UNFIXABLE, zero external consumers) or rebuilding
  `Kamp/NfEFold.lean`; no `nf_eval_efold` / `nf_eval_nfk_iff_efold`.
- Any change to `BXCanonical/` or `Decidability/` beyond the single spine re-point in Phase 5 (`sigE` never
  reaches them; the spine interface is `nf_nvar_exist_all_depths` over the base signature).
- Any `sorry` outside the amended sorry gate below, any `def X := True`, or vacuous placeholder. If the
  Phase-1 gate proves infeasible, STOP and surface for `/research` — do NOT force with `sorry`.

## Binding Constraints (carry into EVERY phase — inherited from plan v18)

- **FAITHFULNESS TO RABINOVICH IS ESSENTIAL. NO NOVEL MATHEMATICS, NO FEFERMAN-VAUGHT.** Every construction
  traces to Rabinovich Def 4.1 (infinite E[Σ]) / Prop 3.5 / Prop 4.2-4.3 / Thm 4.4, a report-19 finding, or
  a report-19 H3 table row. The infinite alphabet is Rabinovich's own E[Σ], not invented.
- **Cite Rabinovich BY PDF PAGE ONLY**:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`. The companion
  `.md` is CORRUPT and must NOT be used.
- **Anchor code by DECLARATION NAME, never line number. NO TASK-NUMBER POINTERS in `Theories/**/*.lean`**
  (durable anchors only).
- **The k≥2 blocker is anchored by declaration name `nf_nvar_exist_all_depths` (the `| _k + 2` arm), NEVER
  by line.** The historical line pointer (`:562`, previously `:212`/`:351`/`:354`/`:361`/`:364`/`:520`) has
  rotted repeatedly; do not trust any line-anchored reference to it.
- **`chain_split` is NON-APPLICABLE.** Do NOT touch `EANegation.lean:1090` / `:1249` (three-strikes
  UNFIXABLE). Do NOT rebuild `Kamp/NfEFold.lean`.
- **AMENDED SORRY GATE.** The only permitted live sorries anywhere in the build are:
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 5), `EANegation.lean:1090`, and
  `EANegation.lean:1249`. No phase may introduce any other sorry or any new axiom.
- **DO NOT DELETE `nf_nvar_exist_all_depths | _k+2` until the new path is proven green end-to-end.** Its
  deletion is the LAST action of the terminal phase (Phase 5), performed only after the new path builds
  green with the residual STILL PRESENT (spine carried by fallback).
- **INCREMENTAL-WITH-FALLBACK.** Phases 1-4 land off the live import path and green (full `lake build`
  EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline) BEFORE Phase 5 touches the spine.
  Phase 5 proves the new path green with the old residual still present, then deletes it LAST.
- **PHASE SIZING (H8).** Each phase (and each Phase-4 sub-phase) is bounded to ~one agent run
  (~100-500 lines of net new/rewritten output). Phase 4 is split per file (4a/4b/4c) precisely so the
  `LiftPair.lean` re-encode — the single hardest obligation — is its own bounded run.
- **PHASE-1 IS THE GO/NO-GO GATE.** Do NOT authorize Phases 2-5 until Phase 1 is green. A failed Phase-1
  gate (cannot close without a full-alphabet `Finset.univ`) is the machine-checked signal that A's
  re-encoding is intractable and NO faithful path remains — STOP and escalate.
- **Point types stay complete under the new representation; interval types remain partial (a finite set of
  the point types the formula mentions).** The per-formula-finite-atom discipline replaces `Finset.univ`
  over the whole alphabet, NOT the point/interval distinction.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Phase 1 gate fails**: the Prop-3.5 "type = finite disjunction of atoms" equivalence for one readback cannot be proved WITHOUT re-introducing a full-alphabet `Finset.univ` | H | M | THIS is the decisive de-risking gate — its entire purpose is to surface this failure cheaply, off-path, in one bounded run, BEFORE the ~1,500-3,000-line refactor. If it fails, the finiteness that makes a semantic 1-type expressible as a `MonadicFormula` genuinely requires the full alphabet, Option A is intractable, and — since finite-`F` (`not_readbackClosed`) and Option B (`capFn_forces_local`) are already refuted — NO faithful path remains. STOP and escalate for `/research`; do NOT force with `sorry` or a full-alphabet `Finset.univ`. |
| **Phase 2**: removing `[fintypePreds]` from `MonadicSignature` breaks the downstream `AtomKind`/`NormalForm` `Fintype`/`DecidableEq` instances and every card lemma (`atomKind_card`/`normalForm_card`) | H | M-H | This is a foundational, expected consequence (report 19 A2). Thread finiteness as an EXPLICIT per-formula hypothesis where it was implicit; re-derive the instances under the new discipline; the two foundational files (`MonadicFO.lean`, `NormalForm.lean`) must build green before any Phase-3+ work. If a card lemma has no per-formula finite witness, that is a Phase-1-class signal — return to the gate, do NOT paper over with a global `Fintype`. |
| **Phase 4 `LiftPair.lean` re-encode** (the single hardest obligation) — the `Fintype (UnaryType)` `Finset.univ` model-enumeration (`charType`/`skelDisjunct`/`liftPair_forward`/`liftPair_backward`) has no finite syntactic form once the alphabet is infinite | H | M | Report 19 A3 names this the hardest site. The faithful fix (validated by the Phase-1 gate) is per-formula finite atom sets: each Rabinovich formula mentions finitely many atoms, so "type = finite disjunction of the mentioned atoms" IS expressible without a total `Finset.univ`. `LiftPair.lean` is its OWN bounded sub-phase (4b) after the `IntervalType.lean` representation lands (4a). If 4b overflows one run, split by lemma (forward/backward). |
| **Phase 4/5 re-work of the landed 13a-13d + β/γ/δ lemmas** that thread the free `variable {F}` | M | M | The negation SHAPE and the 13b/13c transports survive (asset table); only the `Finset.univ` enumeration and the `IntervalType`-level capture are rewritten. 13a's `Sum.inl`/`Sum.inr` collapse survives because `sigE` keeps its sum structure (only the fresh summand's index type changes). Verify each surviving lemma type-checks against the new `sigE` before consuming it. |
| **Phase 5 spine re-point** regresses the spine or fails to remove `sorryAx` | H | M | Incremental-with-fallback (binding constraint): prove the new path green with the residual STILL PRESENT; delete `nf_nvar_exist_all_depths | _k+2` LAST and verify immediately with `#print axioms`. Rollback = revert the Phase-5 spine re-point + arm deletion to last-green (all Phase 1-4 modules present, old residual intact). `sigE` never reaches the spine, so the only spine edit is the single re-point of the three `kamp_prior_*` / `US_expressively_*` / `no_gaps_*` consumers. |
| **Spine-safety assumption is wrong** (`sigE` secretly reaches `BXCanonical/`/`Decidability/`) | H | L | Report 19 grep-verified `sigE`/`UnaryType`/`IntervalType` absent from both trees (H4 refutation attempt: "tried to inflate A's spine risk — searched both, empty"). Re-run the grep at Phase-3 start as a cheap re-confirmation before committing to the infinite re-index. |
| **Off-paper mathematics or a task-number/line-number citation slips into a `Theories/` file** | H | L | Per-phase faithfulness anchor to a named report-19 finding or a Rabinovich PDF page; durable-anchor headers only; the infinite E[Σ] anchored to Def 4.1 (p.5), the per-formula finite-atom representation to Prop 3.5 (p.5) + the "each formula mentions finitely many atoms" observation. |

## Implementation Phases

**Dependency Analysis** (fully sequential critical path, GATED on Phase 1; Phase 4 expands into 4a → {4b, 4c}):

| Wave | Phases | Blocked by | State |
|------|--------|------------|-------|
| 1 | 1 (de-risking GATE — decisive) | -- | NOT STARTED |
| 2 | 2 (`Fintype preds` removal, foundational) | 1 (gate GREEN) | NOT STARTED |
| 3 | 3 (`sigE` infinite re-index + retire vacuous probes) | 2 | NOT STARTED |
| 4 | 4a (`IntervalType` representation re-encode) | 3, 1 | NOT STARTED |
| 5 | 4b (`LiftPair` re-encode — hardest), 4c (`Prop43Translate` + `ConjInterleave` re-encode) | 4a | NOT STARTED |
| 6 | 5 (ζ re-wire + terminal spine wire; retire residual LAST) | 4b, 4c, 13a, 13b, 13c | NOT STARTED |

Phases within the same wave can execute in parallel (4b and 4c are file-disjoint). **The gate (Phase 1)
must be GREEN before any of Phases 2-5 are authorized.** Phase 5 is the ONLY live-path phase; through
Phase 4 the spine and `#print axioms completeness_discrete` are UNCHANGED (the `nf_nvar_exist_all_depths |
_k+2` `sorryAx` remains the sole on-path sorry until Phase 5 deletes it LAST).

---

### Phase 1: De-risking GATE — per-formula-finite-atom `UnaryType` prototype on ONE readback, off-path, sorry-free-or-escalate [NOT STARTED]

- **Goal:** Decide go/no-go on Option A before committing to the ~1,500-3,000-line refactor. Prototype, in a
  NEW off-path module touching no committed file, a candidate `UnaryTypeFin` that carries only the **finite
  `Finset (AtomKind …)`** a formula mentions (a partial assignment), plus its `intervalHolds`-analog, and
  prove the Prop-3.5 "type = finite disjunction of atoms" equivalence for a SINGLE `translateProp35 ξ`
  **without any `Finset.univ` over the whole alphabet**. This is the honest test of Option A's single
  hardest obligation (report 19 A3).
- **Faithfulness anchor:** Rabinovich Prop 3.5 (PDF p.5) "every ∨∃∀-formula with one free var ≡ a TL(U,S)
  formula" + Def 3.1 (p.4, unary αⱼ/βⱼ) + the report-19 observation that "each Rabinovich formula mentions
  finitely many atoms; Rabinovich never enumerates the whole alphabet" (report 19 H3 row "Prop 3.5, p.5").
- **Tasks:**
  - [ ] New module (e.g. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/InfAlphabetProbe.lean`) defining
        `UnaryTypeFin` as a partial assignment over a finite `Finset (AtomKind …)` the formula mentions
        (NOT a total assignment to the whole alphabet).
  - [ ] Define the `intervalHolds`-analog for `UnaryTypeFin` (a finite disjunction over the mentioned
        atoms, not `∃ τ ∈ Finset.univ`).
  - [ ] Prove the Prop-3.5 "type = finite disjunction of atoms" equivalence for ONE concrete
        `translateProp35 ξ`, sorry-free, **without `Finset.univ` over the alphabet**.
  - [ ] Record an explicit GO / NO-GO verdict (a docstring + `#print axioms` on the prototype equivalence).
- **Definition of Done (BINARY GATE):** the equivalence builds sorry-free and axiom-clean (`[propext,
  Classical.choice, Quot.sound]` or a subset), off the live import path, full `lake build` EXIT 0,
  `#print axioms completeness_discrete` byte-identical to baseline. **GO** iff it closes **without
  re-introducing a full-alphabet `Finset.univ`**. **If it does NOT close without a full-alphabet
  `Finset.univ`, STOP and escalate for `/research`** — that is the machine-checked signal that A's
  re-encoding is intractable and (with finite-`F` and Option B already refuted) no faithful path remains.
  Do NOT force with `sorry` or a full-alphabet `Finset.univ`.
- **Timing:** 4-8 hours (~150-350 lines). ~1 agent run. **GATES Phases 2-5.**
- **Depends on:** none.
- **Files to modify:** new probe only (`Kamp/InfAlphabetProbe.lean`, name provisional). NO edits to
  `MonadicFO.lean`/`NormalForm.lean`/any live `Kamp/*` yet.
- **Prohibited:** no edits to committed files; no `sorry`; no full-alphabet `Finset.univ`.

---

### Phase 2: Foundational type-class change — remove `[fintypePreds]`/`[decEqPreds]` from `MonadicSignature`; re-derive `AtomKind`/`NormalForm` instances [NOT STARTED]

- **Goal:** Make an infinite-alphabet signature constructible. Remove the `[fintypePreds : Fintype preds]`
  and `[decEqPreds : DecidableEq preds]` instance fields from `MonadicSignature` (`MonadicFO.lean:41-44`);
  thread finiteness/decidability as an EXPLICIT per-formula hypothesis where they were implicit. Re-derive
  the `AtomKind`/`NormalForm` `Fintype`/`DecidableEq` instances and the card lemmas
  (`atomKind_card`/`normalForm_card`) under the new discipline (`NormalForm.lean`). Scoped, foundational.
- **Faithfulness anchor:** report 19 A2 (`MonadicSignature` structurally REQUIRES `Fintype preds` as a
  field, so infinite E[Σ] is not constructible until it is removed) + Def 4.1 (p.5, E[Σ] is infinite).
- **Tasks:**
  - [ ] Remove `[fintypePreds]`/`[decEqPreds]` from the `MonadicSignature` structure (`MonadicFO.lean`).
  - [ ] Re-derive `AtomKind sig n` `Fintype`/`DecidableEq` (`NormalForm.lean` ~63/~94) taking the needed
        finiteness/decidability as explicit hypotheses rather than field-projections.
  - [ ] Re-derive `NormalForm sig k n := AtomKind sig n → Bool`'s `Fintype × DecidableEq` and the card
        lemmas (`atomKind_card`/`normalForm_card`) under the explicit-hypothesis discipline.
  - [ ] Fix breakage local to the two foundational files; confirm the wider tree still builds (finite
        signatures still supply the hypotheses; only the infinite-alphabet path needs the new form).
- **Definition of Done:** `MonadicFO.lean` and `NormalForm.lean` build green, sorry-free, axiom-clean; full
  `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline. An infinite-alphabet
  signature is now constructible (verified by a throwaway `#check` on a `Formula`-indexed fresh summand).
- **Timing:** 8-14 hours (~200-450 lines; foundational). ~1-2 agent runs.
- **Depends on:** 1 (gate GREEN).
- **Files to modify:** `Theories/Bimodal/Metalogic/FirstOrder/MonadicFO.lean` (or wherever `MonadicSignature`
  lives), `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NormalForm.lean` (paths per the current tree).
- **Prohibited:** no `sorry`; do NOT re-introduce a global `Fintype preds` field; no spine edit.

---

### Phase 3: Re-index `sigE` onto the infinite `Formula` alphabet (Def 4.1) + retire the now-vacuous readback-closure probes [NOT STARTED]

- **Goal:** Change `sigE`'s fresh summand from `{A // A ∈ F}` (finite) to the full `Formula` type
  (infinite E[Σ], Def 4.1 p.5). Update `esigmaPred`/`canonExpand`/`ESigmaCapture` so `esigmaPred A` needs no
  `hA : A ∈ F` (every TL(U,S)-formula is already an atom of the expansion). This is where
  `not_readbackClosed`/`ReadbackClosed` become VACUOUS (readbacks are automatically atoms) — delete the
  `ZetaReadbackClosure`/`ZetaEngineClosure` probes.
- **Faithfulness anchor:** Rabinovich Def 4.1 (PDF p.5, E[Σ] = Σ ∪ {A | A a TL(U,S)-formula over Σ},
  infinite) + the p.6 collapse note (a TL formula over E[Σ] ≡ an atom of the canonical expansion —
  automatic once the alphabet is infinite) (report 19 H3 rows "Def 4.1 p.5" + "collapse note p.6").
- **Tasks:**
  - [ ] Re-confirm spine-safety: re-run `grep -rln 'sigE\|UnaryType\|IntervalType'` over `BXCanonical/` and
        `Decidability/` (expect empty, per report 19) before committing the re-index.
  - [ ] Change `sigE sig F`'s fresh summand from `{A // A ∈ F}` to `Formula` (drop the `F` parameter's role
        as the fresh index, or keep `F` only where still needed as a finite working set); construct the
        `MonadicSignature` using the Phase-2 explicit-finiteness form.
  - [ ] Update `esigmaPred`/`oldPred`/`canonExpand` (`ESigmaExpansion.lean`) so `esigmaPred A` takes no
        `hA` proof; the fresh atom's interp remains `sat A` (semantic core preserved).
  - [ ] Update `ESigmaCapture` so the atom-naming (`canonExpand_atom_named`) no longer requires `A ∈ F`.
  - [ ] Delete `ZetaReadbackClosure.lean` (`not_readbackClosed`) and `ZetaEngineClosure.lean`
        (`ReadbackClosed`/`*_of_closed`) — now vacuous; record in the deletion commit message that they are
        superseded by the infinite E[Σ] (every readback is automatically an atom). PRESERVE
        `OptionBLocalityProbe.lean` (the B-refutation stays as documentation).
- **Definition of Done:** the re-indexed `sigE` + `esigmaPred`/`canonExpand`/`ESigmaCapture` build green,
  sorry-free, axiom-clean; the two closure probes are deleted; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` byte-identical to baseline. Off the live import path.
- **Timing:** 6-12 hours (~200-400 lines net, incl. deletions). ~1-2 agent runs.
- **Depends on:** 2.
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaExpansion.lean`,
  `ESigmaCapture.lean`; DELETE `ZetaReadbackClosure.lean`, `ZetaEngineClosure.lean`.
- **Prohibited:** no `sorry`; do NOT delete `OptionBLocalityProbe.lean`; no spine edit.

---

### Phase 4: Re-encode the `Finset.univ` enumeration surface onto per-formula finite atom sets (split 4a → {4b, 4c}) [NOT STARTED]

**Framing:** This is the largest phase and the core of Option A's cost — rewriting "type = finite
disjunction over ALL 1-types (`Finset.univ`)" onto the Phase-1 per-formula-finite-atom representation.
`Finset.univ` over the now-infinite alphabet does not exist; each site is re-encoded to disjoin only over
the finitely many atoms the formula mentions. Split per file (H8) so each sub-phase is ~one agent run, with
the `IntervalType.lean` representation landing first (4a) and the two heaviest consumers (4b `LiftPair.lean`,
4c `Prop43Translate.lean` + `ConjInterleave.lean`) following in parallel.

**Faithfulness anchor (whole phase):** Rabinovich Prop 3.5 (PDF p.5, ∨∃∀ ≡ TL) + Def 3.1 (p.4, unary
αⱼ/βⱼ) + the report-19 A3 finding that the `Finset.univ` finiteness is STRONGER than Rabinovich needs (each
formula mentions finitely many atoms). Validated by the Phase-1 gate.

#### Phase 4a: `IntervalType.lean` — re-encode the interval-type representation onto per-formula finite atom sets [NOT STARTED]

- **Goal:** Promote the Phase-1 `UnaryTypeFin` representation into the production `UnaryType`/`IntervalType`
  in `IntervalType.lean` (and `ExistsForallFormula.lean` where `UnaryType`/`IntervalType`/`intervalHolds`
  live). Replace `(Finset.univ : Finset (UnaryType sig F))` (`IntervalType.lean:70`) and the `intervalHolds`
  definition so they range over per-formula finite atom sets, not the whole alphabet. Re-prove the basic
  algebra (`intervalHolds_mono`/`_inter_iff`/`_bot`/`ofComplete` compat).
- **Tasks:**
  - [ ] Re-define `UnaryType`/`IntervalType` on the per-formula-finite-atom representation (Phase-1 shape).
  - [ ] Re-define `intervalHolds` without `Finset.univ`; re-prove `ofComplete`/`intervalConj`/`intervalBot`
        and the algebra lemmas.
  - [ ] Re-establish the `efSat` interval-clause bridge lemmas (`efSat_interval_iff`, `intervalSet_*_iff`).
- **Definition of Done:** `IntervalType.lean` (+ the `ExistsForallFormula.lean` core) build green,
  sorry-free, axiom-clean; off-path; `lake build` EXIT 0; axioms unchanged.
- **Timing:** 6-10 hours (~200-400 lines). ~1 agent run.
- **Depends on:** 3, 1.
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/IntervalType.lean`,
  `ExistsForallFormula.lean`.

#### Phase 4b: `LiftPair.lean` — re-encode the `charType`/`skelDisjunct`/`liftPair_forward/backward` enumeration (HARDEST SITE) [NOT STARTED]

- **Goal:** The single hardest obligation (report 19 A3). Rewrite the `(Finset.univ : Finset (Fin (K+1) →
  UnaryType sig F))` skeleton disjunction (`charType`, `skelDisjunct`, `skelR_sat`,
  `liftPair_forward`/`liftPair_backward`; `LiftPair.lean:101/246/596/869`) onto per-formula finite atom
  sets. Prove "type = finite disjunction of the atoms the formula mentions" and the forward/backward
  equivalence WITHOUT a total `Finset.univ`.
- **Tasks:**
  - [ ] Re-encode `charType`/`unaryHolds_charType`/`exists_unaryHolds` onto per-formula finite atoms.
  - [ ] Re-encode `skelDisjunct`/`skelR`/`skelR_sat` (the skeleton disjunction) without `Finset.univ`.
  - [ ] Re-prove `liftPair_forward` and `liftPair_backward` (+ `liftPairV`/`liftSentence` wrappers and their
        `_iff` lemmas) on the new representation.
- **Split contingency (H8):** if this overflows one run, split by direction (4b-fwd `liftPair_forward` /
  4b-bwd `liftPair_backward`); each lands green off-path.
- **Definition of Done:** `LiftPair.lean` builds green, sorry-free, axiom-clean; off-path; `lake build`
  EXIT 0; axioms unchanged.
- **Timing:** 12-24 hours (~400-800 lines; the heaviest re-encode). ~1-2 agent runs.
- **Depends on:** 4a.
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean`.

#### Phase 4c: `Prop43Translate.lean` + `ConjInterleave.lean` — re-encode the remaining enumeration sites [NOT STARTED]

- **Goal:** Rewrite the `(Finset.univ : Finset (Fin (m+1) → UnaryType sig F)).filter …`
  (`Prop43Translate.lean:344`) and the `Fintype`-enumeration + `Finset.card_image_le`
  (`ConjInterleave.lean:679/682`) onto per-formula finite atom sets, preserving the δ `translate_correct`
  structural induction and the α `conjInterleave_iff` merge.
- **Tasks:**
  - [ ] Re-encode `Prop43Translate.lean`'s `Finset.univ` filter onto per-formula finite atoms; re-establish
        `translate`/`translate_correct` (all six connective cases) on the new representation, preserving the
        report-15 `StrictMono ψ.pin` conclusion-strengthening.
  - [ ] Re-encode `ConjInterleave.lean`'s `Fintype`-enumeration / `card_image_le`; re-establish
        `conjInterleave_iff` + `veeConj_iff` on the new representation.
- **Definition of Done:** both files build green, sorry-free, axiom-clean; off-path; `lake build` EXIT 0;
  axioms unchanged.
- **Timing:** 10-18 hours (~350-650 lines; may split per file). ~1-2 agent runs.
- **Depends on:** 4a. Runs parallel with 4b (file-disjoint).
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean`,
  `ConjInterleave.lean`.
- **Prohibited (whole Phase 4):** no `sorry`; no full-alphabet `Finset.univ`; do NOT weaken any correctness
  statement or drop a conjunct to force a fit; no spine edit.

---

### Phase 5: ζ re-wire — discharge capture DIRECTLY (readback IS an atom), construct the ζ `canonExpand`, spine re-point, retire `nf_nvar_exist_all_depths | _k+2` LAST (terminal, live-path) [NOT STARTED]

- **Goal:** With the infinite E[Σ] (Phase 3) and the re-encoded enumeration surface (Phase 4) landed
  off-path, re-wire the ζ consumers (`ZetaUniformExtract`, `EFSatNegationGeneral`): the capture obligation
  is discharged DIRECTLY because every readback is an atom of the infinite expansion — REMOVE the
  `hCapture`/`capFn` parameters entirely (no `IntervalType`-level capture, no 𝔈-bounded threading).
  Construct the ζ `canonExpand` from the surviving reconciliations (`atomMap = oldPred ∘ g` from 13a
  `ZetaAtomMapReconcile`, `HasAttainedINF/SUP` from 13b `ZetaPriorTransfer`, lifted `psi` from 13c
  `MonadicFormulaMap`, carrier witness giving `hne : Nonempty N.carrier` per report 13). Re-point
  `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery`; verify green with the `nf_nvar_exist_all_depths | _k+2` residual STILL
  PRESENT; then **delete it LAST**; confirm `#print axioms completeness_discrete` no longer lists `sorryAx`.
  This is the ONLY live-path phase.
- **Faithfulness anchor:** Rabinovich Thm 4.4 (PDF p.6, φ ≡ ⋁ᵢ φᵢ, each →Prop 3.5→ TL — the readback is
  automatically an atom of the infinite expansion, needs no `∈ F`) + Def 4.1 collapse note (p.6) +
  report 13 (`hne` mandatory) + report 19 (Phase-5: capture discharged directly, `hCapture`/`capFn`
  removed).
- **Tasks:**
  - [ ] Re-wire `ZetaUniformExtract` / `EFSatNegationGeneral` to discharge capture DIRECTLY (readback is an
        atom); remove the `hCapture`/`capFn` parameters from the uniform + non-uniform negation stack.
  - [ ] Verify the surviving 13a `ZetaAtomMapReconcile` (`Sum.inl`/`Sum.inr` collapse), 13b
        `ZetaPriorTransfer` (`HasAttainedINF/SUP`), and 13c `MonadicFormulaMap` (`mapPreds`) type-check
        against the re-indexed `sigE` and re-state where the fresh summand's index type changed.
  - [ ] Construct the ζ `canonExpand` on the infinite E[Σ] with `atomMap = oldPred ∘ g` and the carrier
        witness giving `hne`.
  - [ ] Collapse the (now capture-free) β (10b) / γ (11) / δ (12) results — as re-encoded in Phase 4 — to
        UNCONDITIONAL; apply the (re-encoded) uniform extraction to obtain the single `M`-uniform formula;
        wire the Phase-0 semantic `MonadicFormula → characteristic NormalForm` bridge into the live spine.
  - [ ] Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery`.
  - [ ] **Verify the new path is green with the `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT**
        (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths | _k+2` arm (the residual + its rationale
        block); update the in-file axiom-audit block and any stale doc-comment refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Definition of Done:** `#print axioms completeness_discrete` no longer lists `sorryAx` (retains
  `propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`); full `lake build`
  EXIT 0; no new axiom/sorry anywhere on the proof term. Hand off to task 375 for the terminal audit.
- **Timing:** 12-20 hours (~400-700 lines), plus the `canonExpand` construction + direct capture discharge.
  ~1-2 agent runs.
- **Depends on:** 4b, 4c, 13a, 13b, 13c (surviving reconciliations), and transitively 3, 2, 1.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean`
    (capture removal + ζ wire),
  - `KampPrior.lean` (delete the `nf_nvar_exist_all_depths | _k+2` arm — LAST),
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-point + audit block),
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files.
- **Prohibited:** no `sorry`/`def := True`/vacuous placeholder on the spine; no reset/checkout; do NOT
  delete the `nf_nvar_exist_all_depths | _k+2` arm until the new path is proven green end-to-end.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at the current job floor.
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phases 1-4 the
      axiom set is byte-identical to baseline (the pre-existing `nf_nvar_exist_all_depths | _k+2` `sorryAx`
      remains, carrying the spine). Target end-state after Phase 5: `[propext, Classical.choice,
      Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no `sorryAx`.
- [ ] The amended sorry gate holds: the only live sorries anywhere are `nf_nvar_exist_all_depths | _k+2`
      (until Phase 5), `EANegation.lean:1090`, and `EANegation.lean:1249`. No phase introduces any other
      sorry. No new sorry reaches the trusted core before ζ.
- [ ] Incremental-with-fallback: Phases 1-4 land off the live import path and green BEFORE Phase 5 touches
      the spine; Phase 5 proves the new path green with the residual still present, then deletes the arm
      LAST. Verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, or full-alphabet `Finset.univ` re-introduced. A failed
      Phase-1 gate is a STOP-and-escalate, not a hole; a failed foundational instance in Phase 2 is a
      return-to-gate, not a global `Fintype` papered on.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number or a
      Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page). The k≥2 blocker is
      referenced by declaration name `nf_nvar_exist_all_depths`, never by line.
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks:
- [ ] **Phase 1 (GATE)**: the per-formula-finite-atom Prop-3.5 equivalence for one readback compiles
      sorry-free, axiom-clean, off-path, WITHOUT a full-alphabet `Finset.univ`. GO iff green under that
      constraint; otherwise STOP and escalate.
- [ ] **Phase 2**: `MonadicFO.lean` + `NormalForm.lean` build green with `[fintypePreds]`/`[decEqPreds]`
      removed and finiteness threaded explicitly; an infinite-alphabet signature is constructible.
- [ ] **Phase 3**: `sigE` re-indexed onto `Formula`; `esigmaPred A` needs no `hA`; `ZetaReadbackClosure`/
      `ZetaEngineClosure` deleted (vacuous); `OptionBLocalityProbe` preserved; spine-safety grep re-confirmed.
- [ ] **Phase 4 (4a/4b/4c)**: `IntervalType`/`LiftPair`/`Prop43Translate`/`ConjInterleave` re-encoded onto
      per-formula finite atom sets, sorry-free, axiom-clean, off-path; no `Finset.univ` over the alphabet;
      `liftPair_iff`/`conjInterleave_iff`/`translate_correct` re-established.
- [ ] **Phase 5 (ζ)**: capture discharged DIRECTLY (readback IS an atom), `hCapture`/`capFn` removed; the ζ
      `canonExpand` constructed; conditional β/γ/δ collapse to unconditional; the `nf_nvar_exist_all_depths |
      _k+2` arm is DELETED LAST; `sorryAx` confirmed absent from `completeness_discrete`.

## Artifacts & Outputs

- plans/19_infinite-esigma-alphabet-optionA.md (this file)
- PRESERVED landed assets (do NOT rebuild): `OptionBLocalityProbe.lean` (`capFn_forces_local`, the Option-B
  NO-GO record); the surviving-shape reconciliations `ZetaAtomMapReconcile.lean` (13a), `ZetaPriorTransfer.lean`
  (13b), `MonadicFormulaMap.lean` (13c); `Section5Correspondence.lean`, `VecEANegFix.lean`; the `canonExpand`
  semantic core + `temporal_truth_canonExpand` conservativity in `ESigmaExpansion.lean`/`ESigmaCapture.lean`.
- SLATED FOR DELETION in Phase 3 (vacuous under infinite E[Σ]): `ZetaReadbackClosure.lean`
  (`not_readbackClosed`), `ZetaEngineClosure.lean` (`ReadbackClosed`/`*_of_closed`).
- New / rewritten `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules:
  - Phase 1: `InfAlphabetProbe.lean` (new, off-path gate).
  - Phase 2: edits to `MonadicFO.lean`, `NormalForm.lean`.
  - Phase 3: edits to `ESigmaExpansion.lean`, `ESigmaCapture.lean`; deletions.
  - Phase 4: rewrites to `IntervalType.lean`, `ExistsForallFormula.lean` (4a), `LiftPair.lean` (4b),
    `Prop43Translate.lean`, `ConjInterleave.lean` (4c).
  - Phase 5: edits to `ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean`, `KampPrior.lean` (arm
    deletion), `BXCanonical/Completeness.lean` (spine re-point), the `US_expressively_complete_over_prior` /
    `no_gaps_discrete_model_surgery` chain.
- summaries/19_infinite-esigma-alphabet-optionA-summary.md (on completion)

## Rollback/Contingency

- **Phase 1 gate failure:** additive/off-path (a new probe module), so a failed attempt leaves last-green
  intact. If the per-formula-finite-atom equivalence cannot close WITHOUT a full-alphabet `Finset.univ`,
  Option A is intractable and — since finite-`F` (`not_readbackClosed`) and Option B (`capFn_forces_local`)
  are already machine-refuted — NO faithful path remains: STOP and surface for `/research`; do NOT force
  with `sorry` or a full-alphabet `Finset.univ`. Because Phase 1 gates Phases 2-5, no downstream work is
  committed against an unproven representation.
- **Phase 2 foundational failure:** if a re-derived `AtomKind`/`NormalForm` instance or card lemma has no
  per-formula finite witness, that is a Phase-1-class signal — return to the gate; do NOT re-introduce a
  global `Fintype preds` field. The change is scoped to two files; revert to last-green and resume.
- **Phase 3 re-index failure:** additive-then-deletion; if the infinite re-index breaks a surviving
  reconciliation, revert the re-index (restore the finite `sigE`) to last-green; the deletions of the
  closure probes are done only after the re-indexed `sigE` builds green.
- **Phase 4 re-encode failure:** each sub-phase (4a/4b/4c) is additive/off-path and file-disjoint; a failed
  attempt leaves last-green intact and resumable. `LiftPair.lean` (4b) may split by direction if it
  overflows one run. Do NOT weaken a correctness statement to force a fit — if a site genuinely needs the
  full alphabet, that contradicts the Phase-1 gate and is a return-to-gate.
- **Phase 5 regression:** incremental-with-fallback. The new path is proven green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT; the arm deletion is done LAST and verified
  immediately with `#print axioms`. If the spine re-point regresses the build or the axiom set, revert the
  Phase-5 edits (spine re-point + arm deletion) to restore the last-green state where all Phase 1-4 modules
  exist but the old residual still carries the spine. `sigE` never reaches the spine, so the blast radius of
  a Phase-5 revert is the three `kamp_prior_*`/`US_expressively_*`/`no_gaps_*` consumers only.
