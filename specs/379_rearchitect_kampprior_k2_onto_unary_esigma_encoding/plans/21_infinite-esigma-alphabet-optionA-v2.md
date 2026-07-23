# Implementation Plan: Option A — Infinite-Alphabet E[Σ] Re-Encoding (Rabinovich Def 4.1)

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
  - Started: 2026-07-19T11:58:03-07:00
- **Effort**: ~60-100 hours across 5 phases (Phase 1 de-risking gate — DONE/GO; Phase 2 `Fintype preds` removal; Phase 3 `sigE` infinite re-index; Phase 4 enumeration-surface re-encode, split 4a/4b/4c; Phase 5 ζ re-wire + residual retirement), ~1,500-3,000+ new/rewritten Lean lines, ~60-100+ declarations touched. **Blast radius is CONTAINED to `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` + the two foundational files `MonadicFO.lean`/`NormalForm.lean`; Decidability/FMP: 0 files (grep-verified spine-safety).** Phase 1 was the go/no-go GATE and is GREEN (GO); Phases 2-5 are authorized.
- **Dependencies**: None to start (all inputs — the base β/γ/δ shape, the landed reconciliations, the machine-checked A-vs-B spike — are landed/committed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 5; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here). No task-dependency changes are made by this revision.
- **Research Inputs**: reports/20_plan19-format-faithfulness-remaining-work.md (AUTHORITATIVE for THIS revision — the plan-format audit surfacing defects D1-D7, the PDF-grounded faithfulness PASS re-confirming every construction against Rabinovich pages 4-6 by direct read, the machine-checked current-state inventory of exactly three permitted sorries, and the ordered format-compliance + state-refresh checklist that this revision executes); reports/19_architecture-spike-A-vs-B.md (the decisive A-vs-B architecture spike: machine-checked B-refutation `capFn_forces_local`, the A blast-radius map, the grep-verified spine-safety of `sigE`, and the 5-phase Option-A scope with a Phase-1 de-risking gate); reports/18_readback-closed-finite-fl-rescope.md (the NO-GO verdict on the finite-`F` readback closure that superseded the earlier restructure plan and forced the A-vs-B decision); the committed machine-checked refutation `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean` (`not_readbackClosed` — no finite `F` satisfies `ReadbackClosed`); the committed B-locality refutation `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean` (`capFn_forces_local` — temporal-reach readbacks uncapturable by any `IntervalType`); reports/17_b5-capture-bound-audit.md, reports/16_zeta-wire-blocker-probe.lean, reports/15_exall-gap-monotone-pinning-verdict.md, reports/14_exall-reordering-closure-resolution.md, reports/13_c1-c2-negation-object-blueprint.md, reports/11_esigma-capture-hypothesis-audit.md, reports/07_faithful-esigma-negation-path.md, reports/09_conjinterleave-interval-type-audit.md, reports/05_conjunction-closure-load-bearing-verdict.md, reports/06_phase4-unblock-construction.md (all carried forward)
- **Artifacts**: plans/21_infinite-esigma-alphabet-optionA-v2.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 20_plan19-format-faithfulness-remaining-work.md, 19_architecture-spike-A-vs-B.md, 18_readback-closed-finite-fl-rescope.md, 17_b5-capture-bound-audit.md, 16_zeta-wire-blocker-probe.lean, 15_exall-gap-monotone-pinning-verdict.md, 14_exall-reordering-closure-resolution.md, 13_c1-c2-negation-object-blueprint.md, 11_esigma-capture-hypothesis-audit.md, 07_faithful-esigma-negation-path.md, 09_conjinterleave-interval-type-audit.md, 05_conjunction-closure-load-bearing-verdict.md, 06_phase4-unblock-construction.md
- **plan_metadata**:
  ```json
  {
    "phases": 5,
    "total_effort_hours": 80,
    "complexity": "complex",
    "research_integrated": true,
    "plan_version": 21,
    "dependency_waves": [["1"], ["2"], ["3"], ["4a"], ["4b", "4c"], ["5"]],
    "reports_integrated": [
      {"path": "reports/20_plan19-format-faithfulness-remaining-work.md", "integrated_in_plan_version": 21, "integrated_date": "2026-07-23"},
      {"path": "reports/19_architecture-spike-A-vs-B.md", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"},
      {"path": "reports/18_readback-closed-finite-fl-rescope.md", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"}
    ]
  }
  ```
  (`plan_version: 21` matches this artifact FILE number and the `revise plan (v21)` commit convention — reconciling the predecessor's stale `plan_version: 14`. The `dependency_waves` now MATCH the authoritative 6-wave human-readable table below — a fully sequential critical path gated on Phase 1, with Phase 4 expanded into `4a → {4b, 4c}`.)

### Revision Changelog (plan v19 → this plan)

This is a **format-compliance + state-refresh revision, NOT a re-architecture** (report 20 §4).
The mathematical architecture is UNCHANGED: Option A is adjudicated (report 19), Option B is
machine-refuted (`capFn_forces_local`), finite-`F` is machine-refuted (`not_readbackClosed`), and
the Phase-1 GATE returned a machine-checked GO. Report 20's PDF-grounded faithfulness audit (pages
4-6 read directly) returned PASS with no prohibition violations. The changes applied here:

- **D1** — Plan-level `Status:` corrected from `[NOT STARTED]` (which contradicted Phase 1 being
  `[COMPLETED]`) to `[IMPLEMENTING]`, with a `Started:` line.
- **D2** — The H1 title (a ~90-word run-on embedding the rotted line anchor `KampPrior.lean:562`)
  is rewritten concise; the k≥2 residual is anchored by DECLARATION NAME (`nf_nvar_exist_all_depths`,
  the `| _k + 2` arm) throughout, never by line.
- **D3** — Phase 1 gains a `Completed:` ISO8601 timestamp (commit `fbe26f61c`,
  2026-07-19T11:58:03-07:00).
- **D4** — `plan_metadata` reconciled: `plan_version` bumped to 21 (was 14, stale); `dependency_waves`
  rewritten to match the authoritative 6-wave table (Phase 4 split `4a → {4b, 4c}`); report 20
  prepended to `reports_integrated`.
- **D5** — Phase 5 `Depends on` corrected to `4b, 4c` only (the phantom phase numbers 13a/13b/13c
  are landed FILES, not phases of this plan; the dependency on those landed reconciliations is
  carried in prose and in the phase task bullets).
- **D6/D7** — Sub-phase headings `4a/4b/4c` annotated as `####` sub-phases of Phase 4 (see note under
  Phase 4); the non-standard extra `State` column dropped from the wave table (now Wave/Phases/Blocked-by).
- **Carry-forward 1 (new substance)** — A post-GATE risk note added to Phase 4b: the GATE GO probe
  exercised only the point-type clause of a trivial `n = 0` input (empty interval clauses), NOT the
  `LiftPair` tuple skeleton disjunction; Phase 4b retains residual representation risk and its
  fwd/bwd split contingency is promoted to a first-class fallback.
- **Carry-forward 2 (new substance)** — A Phase-5 task added to correct the doubly-stale in-file
  audit block in `BXCanonical/Completeness.lean` (rotted `:212/:361/:364` line refs; describes an
  already-discharged n=1 arm as still-sorry) — by declaration name, no task-number pointers.

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) still carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of the declaration `nf_nvar_exist_all_depths` in `KampPrior.lean`
(anchor by DECLARATION NAME — the historical line pointer has drifted repeatedly and must never be
trusted). An earlier plan attempted to retire it by constructing a finite readback-closed `F`; that
path is **machine-refuted** (`not_readbackClosed`, `ZetaReadbackClosure.lean`, committed): no finite
`F` can be closed under the ∃∀-readback because the readback image contains formulas of unbounded
`untl`-count. Report 18 surfaced the two remaining faithful architectures A/B; report 19 decided
between them with machine-checked evidence.

**This plan commits to Option A: the infinite-alphabet E[Σ] of Rabinovich Def 4.1 (PDF p.5).**
Option A is the only faithful path — Option B is a machine-checked NO-GO (`capFn_forces_local`,
`OptionBLocalityProbe.lean`: any `IntervalType` capture forces 1-type-locality, so genuine
temporal-reach readbacks are uncapturable without novel machinery, forbidden by the no-novel-math
binding). Option A is literally Def 4.1 (E[Σ] = Σ ∪ {all TL(U,S)-formulas over Σ}, **infinite**),
requires no invented mathematics, and is **SPINE-SAFE**: `sigE` is grep-confirmed confined to
`WeakCanonical/Kamp/`, absent from `BXCanonical/` (incl. `Completeness.lean`/`completeness_discrete`)
and absent from `Decidability/` (incl. all of `Decidability/FMP/*`), so the completeness /
`completeness_discrete` / decidability / FMP spine is not at risk.

**The cost is large but structural, not mathematical.** Option A is a foundational re-encoding of the
Kamp type-representation: (1) `MonadicSignature` structurally requires `Fintype preds`/`DecidableEq
preds` as instance fields (`MonadicFO.lean`), so an infinite-alphabet signature is not even
constructible until that requirement is removed; (2) the whole `UnaryType`/`IntervalType`
model-enumeration layer is built on `Finset.univ` over a finite alphabet and must be re-encoded onto
**per-formula finite atom sets** (each Rabinovich formula mentions finitely many atoms; Rabinovich
never enumerates the whole alphabet). Because this is a ~1,500-3,000-line rewrite of landed,
axiom-clean machinery, the plan was structured so its **single hardest obligation was a go/no-go GATE
in Phase 1** — a bounded, off-path prototype of the per-formula-finite-atom representation on ONE
readback, sorry-free-or-escalate. **Phase 1 is GREEN (GATE GO, machine-checked).** There is no third
faithful option (finite-`F` is refuted), so had the Phase-1 gate failed the only defined fallback
would have been escalation.

**Definition of Done (UNCHANGED): `#print axioms completeness_discrete` no longer lists `sorryAx`**,
with the full `lake build` at EXIT 0 and no new axiom or non-permitted sorry anywhere on the proof
term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
Quot.sound]` — with `sorryAx` REMOVED (Phase 5 deletes the sole on-path `nf_nvar_exist_all_depths |
_k+2` residual, LAST, once the new path is proven green end-to-end).

### Research Integration

- **Report 20 (`reports/20_plan19-format-faithfulness-remaining-work.md`, AUTHORITATIVE for this
  revision, newly integrated)**: the plan-format audit + PDF-grounded faithfulness re-check
  (lean-research-agent). Its contributions consumed here:
  - **Format audit → defects D1-D7.** Section 1 keyed each defect to a plan-format rule; the
    load-bearing ones are D1 (stale plan-level status) and D2 (rotted line anchor in the title).
    This revision applies all of them (see the Revision Changelog above).
  - **Faithfulness audit → PASS (independent PDF read, pages 4-6).** Section 2 verified every
    plan-19 construction against Rabinovich by PDF page: the infinite `sigE` re-index is Def 4.1
    (p.5); the per-formula-finite representation is Prop 3.5 (p.5) + Def 3.1 (p.4); the direct
    capture discharge is the p.6 collapse note + Thm 4.4 (p.6); the β/γ/δ negation shape is Prop
    4.2/4.3 (p.6). No Feferman-Vaught, no `chain_split`, no `EANegation` edits, no arity-4 object.
    This corroborates reports 18/19 and mandates NO re-architecture.
  - **Current-state inventory (machine-checked).** Section 3: exactly three permitted sorries on the
    completeness track (`nf_nvar_exist_all_depths | _k+2` = DoD target, `EANegation.lean:1090`,
    `EANegation.lean:1249`); only Phase 1 is landed; Phases 2/3/4a-c/5 are verified NOT STARTED
    (`fintypePreds` still on `MonadicSignature`; `sigE` fresh summand still `{A // A ∈ F}`; closure
    probes not yet deleted).
  - **Two new substance findings** carried into this revision: the post-GATE Phase-4b risk
    refinement (Section 3.3 — the GATE exercised only the point-type clause of a trivial `n = 0`
    input, so the `LiftPair` tuple skeleton disjunction is where residual representation risk now
    lives), and the Phase-5 audit-block correction task (Section 3.1 — `BXCanonical/Completeness.lean`
    still cites `:212/:361/:364` and an already-discharged n=1 arm).
- **Report 19 (`reports/19_architecture-spike-A-vs-B.md`)**: the decisive comparative architecture
  spike (H2+H3+H4). Its contributions consumed here:
  - **Option B ruled out (machine-checked NO-GO).** `capFn_forces_local` (in the committed
    `OptionBLocalityProbe.lean`) proves any `IntervalType`-level capture forces the captured formula's
    truth to be 1-type-local; temporal-reach readback `Until`/`Since` chains are provably non-local, so
    they are capturable by NO `IntervalType sig F`, for ANY `F`. Making B work requires an order-aware
    `IntervalType` with no Def 3.1 counterpart — novel machinery, binding-forbidden.
  - **Option A recommended and de-risked as SPINE-SAFE.** The A blast radius is grep-verified contained
    to `WeakCanonical/Kamp/` (25 live `sigE` consumers + the two foundational files); `sigE` never
    reaches `BXCanonical/`/`Decidability/`; the spine interface is `nf_nvar_exist_all_depths` over the
    BASE signature, which never saw `sigE`.
  - **The 5-phase Option-A scope with a Phase-1 gate** (report 19 §"/revise Scope"): the
    per-formula-finite-atom prototype gate, the `Fintype preds` removal, the `sigE` infinite re-index
    (which makes the readback-closure probes vacuous), the enumeration-surface re-encode (hardest site
    `LiftPair.lean`), and the terminal ζ re-wire. This plan adopts that structure verbatim, expanding
    the consumer-surface phase into bounded per-file sub-phases (H8).
  - **The H3 5-column PDF-page mapping table** (report 19): Def 4.1 p.5 (E[Σ] infinite), the p.6
    collapse note, Def 3.1 p.4 (unary αⱼ/βⱼ), Prop 3.5 p.5, Prop 4.2/4.3 + Thm 4.4 p.6. These are the
    faithfulness anchors for Phases 3-5 and are cited by PDF page throughout.
- **Report 18 (`reports/18_readback-closed-finite-fl-rescope.md`)**: the NO-GO on the finite-`F`
  readback closure. It (with `not_readbackClosed`) is the reason a fresh architecture (A) was
  required. The two faithful options it surfaced (A/B) were adjudicated by report 19.
- **Committed refutations preserved as landed assets** (NOT rebuilt): `not_readbackClosed`
  (`ZetaReadbackClosure.lean`) — the finite-`F` refutation; `capFn_forces_local`
  (`OptionBLocalityProbe.lean`) — the Option-B locality refutation. See "Preserved / Superseded
  Assets" below for their disposition under the A refactor.
- **Reports 17/16/15/14/13/11/09/07/05/06 (carried forward)**: the B1-B4 blocker probe, the B5
  capture-bound audit, the monotone-pinning verdict, the path-(c) eval-side closure, the arity-0/1
  negation blueprint, the `hCapture`-at-`IntervalType` pin, the ConjInterleave audit, the faithful
  α-ζ phase structure, the conjunction-closure verdict, the Phase-4 unblock construction. Under Option
  A the β/γ/δ negation SHAPE and the `translateProp35` structure these grounded SURVIVE (report 19
  comparison table); the `Finset.univ` enumeration and the `IntervalType`-level capture they also
  grounded are REWRITTEN (see the asset table).

### Prior Plan Reference

**`plans/19_infinite-esigma-alphabet-optionA.md` is the immediate predecessor of this plan; this
plan (v21) is its format-compliance + state-refresh revision** (report 20 §4 — NOT a re-architecture).
The architecture and phase decomposition are carried forward verbatim; only the format/freshness
defects D1-D7 and the two new substance findings from report 20 are applied. Plan 19 is left in place
as history; this plan supersedes it as the working plan.

The still-earlier finite-`F` restructure plan is SUPERSEDED and its Option-(a) finite readback-closed
`F` is [BLOCKED]/machine-refuted (`not_readbackClosed`, `ZetaReadbackClosure.lean`, committed). **Do
NOT re-attempt the finite-`F` construction — it is machine-refuted.** The earlier
`13e-1 → 13e-2 → 13e-3` sequence is replaced by the Option-A sequence `1 → 2 → 3 → 4 → 5`.

### Open Scope Question — RESOLVED to (b)

The task charter's OPEN SCOPE QUESTION (a: re-architect the arms while keeping `nf_eval_nf` in the
chain statements, vs b: a statement/alphabet-level migration) is **RESOLVED to (b)**. Option A is
precisely a statement/alphabet-level migration: it migrates the `sigE` E[Σ] alphabet from the finite
`{A // A ∈ F}` index onto the infinite `Formula` alphabet of Def 4.1, and re-encodes every statement
that quantified over the finite `Finset.univ` model-enumeration. This resolution is recorded HERE, in
the plan; per the reviser Plan-Revision workflow this plan does NOT edit the state.json task
description or task dependencies.

### Preserved / Superseded Assets (do NOT rebuild the preserved ones; do NOT re-execute the superseded ones)

Report 19's "Reuse of landed assets" verdict for Option A is **Low**: the committed
`UnaryType`/`IntervalType`/`LiftPair`/capture proofs are rewritten under the new per-formula
representation; the `canonExpand` semantic core and the `translateProp35`/negation SHAPE survive.

| Landed asset | File | Disposition under Option A |
|---|---|---|
| `not_readbackClosed` (finite-`F` refutation) | `ZetaReadbackClosure.lean` | **PRESERVED as documentation of the finite-`F` NO-GO**, then **VACUOUS + slated for DELETION in Phase 3** (once `sigE` is infinite, readbacks are automatically atoms; the closure question dissolves). |
| `ReadbackClosed` / `*_of_closed` conditionals + circularity findings | `ZetaEngineClosure.lean` | **VACUOUS under infinite E[Σ] + slated for DELETION in Phase 3** (report 19 Phase-3 note: the conditional closure lemmas have no content when every readback is already an atom). |
| `capFn_forces_local` / `intervalHolds_local` (Option-B refutation) | `OptionBLocalityProbe.lean` | **PRESERVED VERBATIM** — the machine-checked record that B is a NO-GO; do NOT delete (it is the justification for choosing A over B). Off-path; unaffected. |
| `canonExpand` semantic core + `temporal_truth_canonExpand` conservativity | `ESigmaExpansion.lean`, `ESigmaCapture.lean` | **Semantic SHAPE SURVIVES** (canonical expansion interp of a fresh atom = `sat A`; old-pred conservativity via `oldPred`). The `esigmaPred A hA` proof-carrying `hA : A ∈ F` membership is **REWRITTEN** in Phase 3 (fresh atoms indexed by the full `Formula`, no `hA`). |
| `esigmaCapture_canonExpand` + `intervalCapture_of_atomNamed` (𝔈-bounded capture) | `ESigmaCapture.lean` | **SUPERSEDED**: the `S := univ.filter (τ names A)` capture is `Finset.univ`-based and rebuilt in Phase 4/5; under infinite E[Σ] the capture obligation is discharged DIRECTLY (readback IS an atom), so the `hCapture`/`capFn` machinery is REMOVED at Phase 5, not re-derived. The conservativity lemma survives. |
| `ZetaAtomMapReconcile` (`Sum.inl`/`Sum.inr` collapse-unwinding) | `ZetaAtomMapReconcile.lean` | **SHAPE SURVIVES** — `sigE` keeps its `sig.preds ⊕ (fresh)` sum structure (only the fresh summand changes from `{A // A ∈ F}` to `Formula`); the collapse-unwinding is re-stated over the new fresh summand in Phase 5. |
| `ZetaPriorTransfer` (prior-axiom / `HasAttainedINF/SUP` transport) | `ZetaPriorTransfer.lean` | **SURVIVES** (carrier/order transport along `temporal_truth_canonExpand`; independent of the alphabet's finiteness); re-checked at Phase 5. |
| `MonadicFormulaMap` (`mapPreds` eval-naturality) | `MonadicFormulaMap.lean` | **SURVIVES** (structural relabelling + `oldPred` conservativity; independent of finiteness); re-checked at Phase 5. |
| `ZetaUniformExtract` (M-uniform extraction + capture threading) | `ZetaUniformExtract.lean` | **PARTIALLY REWRITTEN**: the `S = univ.filter (τ a₀)` model-independent witness is `Finset.univ`-based (Phase 4 re-encode); the N-independence structure survives, but the `capFn`/`hCapture` threading is REMOVED at Phase 5. |
| β/γ/δ negation stack (`efSat_negation_general`, `veeSat_negation`, `translate_correct`) SHAPE | `EFSatNegationGeneral.lean`, `VeeSatNegation.lean`, `Prop43Translate.lean` | **SHAPE SURVIVES** (De Morgan trichotomy, Prop 4.3 structural induction); the `Finset.univ` "type = disjunction over ALL 1-types" enumeration inside them is **REWRITTEN** in Phase 4 onto per-formula finite atom sets. |
| `translateProp35` / `charType` / `skelDisjunct` structure | `Prop35Assembly.lean`, `LiftPair.lean` | **STRUCTURE SURVIVES**, but the `Finset.univ`-enumeration bodies are **REWRITTEN** (Phase 4; `LiftPair.lean` is the hardest single site). |
| `Section5Correspondence` (`prop42_contentful_of_attained`) + `VecEANegFix` (`negFix_iff`) | `Section5Correspondence.lean`, `VecEANegFix.lean` | **SURVIVE** — they live in the `VVecEA2`/bracket world and are structural De Morgan / attained-carrier facts, not `Finset.univ`-enumeration and not `IntervalType` captures (report 19 B2). Re-checked, not rebuilt. |
| `Fintype (UnaryType)` `Finset.univ` model-enumeration (in `IntervalType.lean`, `LiftPair.lean`, `Prop43Translate.lean`, `ConjInterleave.lean`) | multiple | **REWRITTEN** — the core of the Phase-4 re-encode; `Finset.univ` over the (now infinite) alphabet does not exist, replaced by per-formula finite atom sets. |

## Goals & Non-Goals

**Goals**:
- **[DONE] Prove the Phase-1 de-risking GATE**: a per-formula-finite-atom `UnaryType` prototype
  (`UnaryTypeFin`) carrying only the finite `Finset (AtomKind …)` a formula mentions, plus its
  `intervalHolds`-analog, and the Prop-3.5 "type = finite disjunction of atoms" equivalence for ONE
  `translateProp35 ξ` **without any `Finset.univ` over the whole alphabet** — sorry-free and
  axiom-clean, off the live path, touching NO committed file. This was the honest go/no-go on Option
  A's true difficulty; **it returned GO (machine-checked)**.
- **Remove the finiteness type-class requirement** (`Fintype preds`/`DecidableEq preds`) from
  `MonadicSignature` (`MonadicFO.lean`), and re-derive the `AtomKind`/`NormalForm` instances
  (`NormalForm.lean`) under an explicit per-formula finiteness discipline, so an infinite-alphabet
  signature is constructible.
- **Re-index `sigE` onto the infinite `Formula` alphabet** (Def 4.1 p.5): change the fresh summand
  from `{A // A ∈ F}` to the full `Formula` type; update `esigmaPred`/`canonExpand`/`ESigmaCapture`
  so a fresh atom needs no `hA : A ∈ F`; retire the now-vacuous `ZetaReadbackClosure`/`ZetaEngineClosure`
  probes.
- **Re-encode the `Finset.univ` enumeration surface** onto the Phase-1 per-formula representation
  (`LiftPair.lean` hardest, plus `Prop43Translate.lean`, `IntervalType.lean`, `ConjInterleave.lean`),
  proving "type = finite disjunction of the atoms the formula mentions" with no total `Finset.univ`.
- **Re-wire the ζ consumers and perform the terminal spine wire** (`ZetaUniformExtract`,
  `EFSatNegationGeneral`): discharge the capture obligation DIRECTLY (the readback is an atom of the
  infinite expansion), removing the `hCapture`/`capFn` parameters; construct the ζ `canonExpand` from
  the surviving reconciliations; re-point `kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery`; verify green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT, then **delete it LAST**; confirm
  `#print axioms completeness_discrete` no longer lists `sorryAx`.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor
  headers only; Rabinovich cited by PDF page, never line number).

**Non-Goals**:
- Introducing any novel mathematics or Feferman-Vaught composition. Option A is literally Rabinovich
  Def 4.1's infinite E[Σ]; no invented content.
- Re-attempting the finite-`F` readback closure (machine-refuted, `not_readbackClosed`) or Option B's
  semantic capture (machine-refuted, `capFn_forces_local`).
- Any arity-4 realization engine, joint-type-over-a-tuple, or `chain_split` (NON-APPLICABLE).
- Touching `EANegation.lean:1090` / `:1249` (three-strikes UNFIXABLE, zero external consumers) or
  rebuilding `Kamp/NfEFold.lean`; no `nf_eval_efold` / `nf_eval_nfk_iff_efold`.
- Any change to `BXCanonical/` or `Decidability/` beyond the single spine re-point + the in-file
  audit-block correction in Phase 5 (`sigE` never reaches them; the spine interface is
  `nf_nvar_exist_all_depths` over the base signature).
- Any `sorry` outside the amended sorry gate below, any `def X := True`, or vacuous placeholder.

## Binding Constraints (carry into EVERY phase)

- **FAITHFULNESS TO RABINOVICH IS ESSENTIAL. NO NOVEL MATHEMATICS, NO FEFERMAN-VAUGHT.** Every
  construction traces to Rabinovich Def 4.1 (infinite E[Σ]) / Prop 3.5 / Prop 4.2-4.3 / Thm 4.4, a
  report-19 finding, or a report-19/20 H3 table row. The infinite alphabet is Rabinovich's own E[Σ],
  not invented. (Report 20 re-verified this against the PDF pages 4-6 by direct read: PASS.)
- **Cite Rabinovich BY PDF PAGE ONLY**:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`. The
  companion `.md` is CORRUPT and must NOT be used.
- **Anchor code by DECLARATION NAME, never line number. NO TASK-NUMBER POINTERS in `Theories/**/*.lean`**
  (durable anchors only).
- **The k≥2 blocker is anchored by declaration name `nf_nvar_exist_all_depths` (the `| _k + 2` arm),
  NEVER by line.** Every historical line pointer to it has rotted repeatedly; do not trust any
  line-anchored reference.
- **`chain_split` is NON-APPLICABLE.** Do NOT touch `EANegation.lean:1090` / `:1249` (three-strikes
  UNFIXABLE). Do NOT rebuild `Kamp/NfEFold.lean`.
- **AMENDED SORRY GATE.** The only permitted live sorries anywhere in the build are:
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 5), `EANegation.lean:1090`, and
  `EANegation.lean:1249`. No phase may introduce any other sorry or any new axiom. (Report 20
  machine-verified exactly these three are live — no extra sorry has crept in.)
- **DO NOT DELETE `nf_nvar_exist_all_depths | _k+2` until the new path is proven green end-to-end.**
  Its deletion is the LAST action of the terminal phase (Phase 5), performed only after the new path
  builds green with the residual STILL PRESENT (spine carried by fallback).
- **INCREMENTAL-WITH-FALLBACK.** Phases 2-4 land off the live import path and green (full `lake build`
  EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline) BEFORE Phase 5 touches the
  spine. Phase 5 proves the new path green with the old residual still present, then deletes it LAST.
- **PHASE SIZING (H8).** Each phase (and each Phase-4 sub-phase) is bounded to ~one agent run
  (~100-500 lines of net new/rewritten output). Phase 4 is split per file (4a/4b/4c) precisely so the
  `LiftPair.lean` re-encode — the single hardest obligation — is its own bounded run.
- **PHASE-1 IS THE GO/NO-GO GATE — GREEN (GO).** Phases 2-5 are authorized. (Retained here as the
  standing record: had the gate failed — cannot close without a full-alphabet `Finset.univ` — that
  would have been the machine-checked signal to STOP and escalate, since finite-`F` and Option B are
  both refuted.)
- **Point types stay complete under the new representation; interval types remain partial (a finite
  set of the point types the formula mentions).** The per-formula-finite-atom discipline replaces
  `Finset.univ` over the whole alphabet, NOT the point/interval distinction.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Phase 4b `LiftPair.lean` re-encode is only PARTIALLY de-risked by the GATE** (post-GATE refinement, report 20 §3.3): the Phase-1 GO exercised only the point-type clause of a TRIVIAL `ξConcrete` (`n = 0`, interval clauses `= ∅`); it did NOT exercise (i) non-empty interval clauses, (ii) the `Finset.univ : Finset (Fin (K+1) → UnaryType)` TUPLE skeleton disjunction that `charType`/`skelDisjunct` use, or (iii) `liftPair_forward`/`liftPair_backward`. The residual representation risk now lives in 4b, NOT the GATE. | H | M | This is now the plan's top open representation risk. Keep the 4b fwd/bwd split contingency as a FIRST-CLASS fallback (see Phase 4b). If the tuple skeleton disjunction cannot be expressed on per-formula finite atom sets WITHOUT a full-alphabet `Finset.univ`, that is a return-to-gate signal (the GATE only validated the point-type clause) — surface for `/research`, do NOT force with a global `Finset.univ`. |
| **Phase 2**: removing `[fintypePreds]` from `MonadicSignature` breaks the downstream `AtomKind`/`NormalForm` `Fintype`/`DecidableEq` instances and every card lemma (`atomKind_card`/`normalForm_card`) | H | M-H | This is a foundational, expected consequence (report 19 A2). Thread finiteness as an EXPLICIT per-formula hypothesis where it was implicit; re-derive the instances under the new discipline; the two foundational files (`MonadicFO.lean`, `NormalForm.lean`) must build green before any Phase-3+ work. If a card lemma has no per-formula finite witness, that is a Phase-1-class signal — do NOT paper over with a global `Fintype`. |
| **Phase 4 (whole)** — the `Fintype (UnaryType)` `Finset.univ` model-enumeration (`charType`/`skelDisjunct`/`liftPair_forward`/`liftPair_backward`) has no finite syntactic form once the alphabet is infinite | H | M | Report 19 A3 names `LiftPair.lean` the hardest site. The faithful fix (validated by the Phase-1 gate FOR THE POINT-TYPE CLAUSE) is per-formula finite atom sets: each Rabinovich formula mentions finitely many atoms, so "type = finite disjunction of the mentioned atoms" IS expressible without a total `Finset.univ`. `LiftPair.lean` is its OWN bounded sub-phase (4b) after `IntervalType.lean` (4a). |
| **Phase 4/5 re-work of the landed reconciliations + β/γ/δ lemmas** that thread the free `variable {F}` | M | M | The negation SHAPE and the prior/eval transports survive (asset table); only the `Finset.univ` enumeration and the `IntervalType`-level capture are rewritten. The `ZetaAtomMapReconcile` `Sum.inl`/`Sum.inr` collapse survives because `sigE` keeps its sum structure (only the fresh summand's index type changes). Verify each surviving lemma type-checks against the new `sigE` before consuming it. |
| **Phase 5 spine re-point** regresses the spine or fails to remove `sorryAx` | H | M | Incremental-with-fallback (binding constraint): prove the new path green with the residual STILL PRESENT; delete `nf_nvar_exist_all_depths | _k+2` LAST and verify immediately with `#print axioms`. Rollback = revert the Phase-5 spine re-point + arm deletion to last-green (all Phase 1-4 modules present, old residual intact). `sigE` never reaches the spine, so the only spine edit is the single re-point of the three `kamp_prior_*` / `US_expressively_*` / `no_gaps_*` consumers (plus the in-file audit-block correction). |
| **Spine-safety assumption is wrong** (`sigE` secretly reaches `BXCanonical/`/`Decidability/`) | H | L | Report 19 grep-verified `sigE`/`UnaryType`/`IntervalType` absent from both trees. Re-run the grep at Phase-3 start as a cheap re-confirmation before committing to the infinite re-index. |
| **Off-paper mathematics or a task-number/line-number citation slips into a `Theories/` file** | H | L | Per-phase faithfulness anchor to a named report-19/20 finding or a Rabinovich PDF page; durable-anchor headers only; the infinite E[Σ] anchored to Def 4.1 (p.5), the per-formula finite-atom representation to Prop 3.5 (p.5) + the "each formula mentions finitely many atoms" observation. |

## Implementation Phases

**Dependency Analysis** (fully sequential critical path, GATED on Phase 1 — now GREEN; Phase 4
expands into `4a → {4b, 4c}`):

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 (de-risking GATE — DONE/GO) | -- |
| 2 | 2 (`Fintype preds` removal, foundational) | 1 |
| 3 | 3 (`sigE` infinite re-index + retire vacuous probes) | 2 |
| 4 | 4a (`IntervalType` representation re-encode) | 3 |
| 5 | 4b (`LiftPair` re-encode — hardest), 4c (`Prop43Translate` + `ConjInterleave` re-encode) | 4a |
| 6 | 5 (ζ re-wire + terminal spine wire; retire residual LAST) | 4b, 4c |

Phases within the same wave can execute in parallel (4b and 4c are file-disjoint). **The gate (Phase
1) is GREEN, so Phases 2-5 are authorized.** Phase 5 is the ONLY live-path phase; through Phase 4 the
spine and `#print axioms completeness_discrete` are UNCHANGED (the `nf_nvar_exist_all_depths | _k+2`
`sorryAx` remains the sole on-path sorry until Phase 5 deletes it LAST).

> **Sub-phase heading convention (D6):** Phase 4 is a parent phase; its sub-phases 4a/4b/4c use `####`
> (H4) headings to denote that they are bounded sub-runs of Phase 4. All top-level phases use `###`.

---

### Phase 1: De-risking GATE — per-formula-finite-atom `UnaryType` prototype on ONE readback, off-path, sorry-free-or-escalate [COMPLETED]

- Completed: 2026-07-19T11:58:03-07:00

**GATE VERDICT: GO** (machine-checked, commit `fbe26f61c`). Prototype `Kamp/InfAlphabetProbe.lean`
proves the Prop-3.5 "type = finite disjunction of atoms" equivalence (`typeEqFiniteDisjunction`) and
its concrete instantiation on a genuine `translateProp35` input (`gate_translateProp35`, over
`ξConcrete`), sorry-free, with the enumeration ranging ONLY over completions of the mentioned atoms
(`Finset.univ : Finset (UnaryTypeFin sig F M)` where `UnaryTypeFin sig F M = {a // a ∈ M} → Bool`)
— NO full-alphabet `Finset.univ : Finset (UnaryType)`. `#print axioms gate_translateProp35` =
`[propext, Classical.choice, Quot.sound]` (subset of permitted). Off-path (no importers); full
`lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline
(`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`, k+2
residual untouched). Phases 2-5 are authorized.

**Post-GATE scope caveat (report 20 §3.3):** the probe exercised the representation only on the
**point-type clause** of a **trivial** `ξConcrete` (`n = 0`, interval clauses `= ∅`). It did NOT
exercise non-empty interval clauses, the tuple skeleton disjunction, or the `liftPair_*` equivalence.
Phase 4b is therefore the site where residual representation risk now lives (see Phase 4b).

- **Goal:** Decide go/no-go on Option A before committing to the ~1,500-3,000-line refactor. Prototype,
  in a NEW off-path module touching no committed file, a candidate `UnaryTypeFin` that carries only the
  **finite `Finset (AtomKind …)`** a formula mentions (a partial assignment), plus its
  `intervalHolds`-analog, and prove the Prop-3.5 "type = finite disjunction of atoms" equivalence for a
  SINGLE `translateProp35 ξ` **without any `Finset.univ` over the whole alphabet**.
- **Faithfulness anchor:** Rabinovich Prop 3.5 (PDF p.5) + Def 3.1 (p.4, unary αⱼ/βⱼ) + the report-19/20
  observation that "each Rabinovich formula mentions finitely many atoms; Rabinovich never enumerates
  the whole alphabet".
- **Tasks:**
  - [x] New module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/InfAlphabetProbe.lean` defining
        `UnaryTypeFin` as a partial assignment over a finite `Finset (AtomKind …)` the formula mentions.
        *(landed: `UnaryTypeFin sig F M = {a // a ∈ M} → Bool`)*
  - [x] Define the `intervalHolds`-analog for `UnaryTypeFin` (a finite disjunction over the mentioned
        atoms). *(landed: `partialIntervalHolds`, over `Finset (UnaryTypeFin sig F M)`)*
  - [x] Prove the Prop-3.5 equivalence for ONE concrete `translateProp35 ξ`, sorry-free, WITHOUT
        `Finset.univ` over the alphabet. *(landed: `typeEqFiniteDisjunction` + `gate_translateProp35`)*
  - [x] Record an explicit GO / NO-GO verdict. *(GO; `#print axioms gate_translateProp35` =
        `[propext, Classical.choice, Quot.sound]`)*
- **Definition of Done (BINARY GATE):** the equivalence builds sorry-free and axiom-clean, off the live
  import path, full `lake build` EXIT 0, `#print axioms completeness_discrete` byte-identical to
  baseline. **GO** iff it closes WITHOUT re-introducing a full-alphabet `Finset.univ`. **Achieved: GO.**
- **Timing:** 4-8 hours (~150-350 lines). ~1 agent run. **GATES Phases 2-5 (now GREEN).**
- **Depends on:** none.
- **Files modified:** new probe only (`Kamp/InfAlphabetProbe.lean`).

---

### Phase 2: Foundational type-class change — remove `[fintypePreds]`/`[decEqPreds]` from `MonadicSignature`; re-derive `AtomKind`/`NormalForm` instances [COMPLETED]

- Started: 2026-07-23T18:08:00Z
- Partial: 2026-07-23 (foundational core GREEN + preserved as patch; downstream instance-threading
  cascade in progress — see PARTIAL note below)
- Completed: 2026-07-23T22:30:00Z (full `lake build` EXIT 0; cascade fully ground out)

> **COMPLETED (Phase 2) — full green reached.** The continuation run reapplied the preserved
> foundational patch and ground the instance-threading cascade to completion across ~45 files and
> ~30 build waves. `[Fintype sig.preds] [DecidableEq sig.preds]` was threaded after each failing
> abstract-`sig` decl binder (via an idempotent guard-scripted pass per file); three genuine
> non-binder repairs were needed: (1) explicit bridge instances `muSig_fintypePreds`/
> `muSig_decEqPreds` (`EFGames/TypeFormulas.lean`) because instance search does not unfold the
> semireducible `muSig`; (2) explicit `Fintype`/`DecidableEq` instances for the concrete counterexample
> signature `sigCex` (`NfMultiAnchorBridge/Base.lean`) for the same reason; (3) removal of the two
> `fintypePreds := inferInstance` / `decEqPreds := inferInstance` field assignments in `mkSigFrom`
> (`Transfer.lean`) plus explicit bridge instances for `(mkSigFrom φ).preds`. The `IntervalType.lean:~109`
> "unsolved goals" flagged in the handoff was NOT a genuine proof break — it resolved mechanically once
> `DecidableEq (UnaryType)` came into scope. **Verification:** full `lake build` EXIT 0; git diff added/
> removed ZERO `sorry` lines (no new sorries); `#print axioms completeness_discrete` byte-identical to
> baseline `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`;
> and an infinite-alphabet signature (`preds := Formula`, with `Infinite` instance) is now constructible.

> **PARTIAL (Phase 2) — foundational core landed green, cascade larger than the rollback note assumed.**
> - **What landed (GREEN, scoped-verified, preserved):** the `[fintypePreds]`/`[decEqPreds]` fields
>   are removed from `MonadicSignature`; `MonadicFormula`'s `deriving DecidableEq` is replaced by an
>   explicit **conditional** `instDecidableEqMonadicFormula [DecidableEq sig.preds]`; `AtomKind`/
>   `NormalForm` `Fintype`/`DecidableEq` instances, the card lemmas, `nf_to_formula`/`nf_to_sentence`,
>   and the wave-1 downstream (`ESigmaExpansion`, `KampTranslation`, `EFGames/Defs`, `NEquivalence`)
>   are re-threaded with explicit `[Fintype sig.preds] [DecidableEq sig.preds]` hypotheses. All six
>   files build green individually (`lake build <module>` EXIT 0 for `MonadicFO`, `NormalForm`,
>   `Kamp.ESigmaExpansion`, `Separation.KampTranslation`, `EFGames.Defs`, `NEquivalence`).
> - **Key design finding (carries into Phase 3+):** decidability is PRESERVED along the infinite E[Σ]
>   path (Def 4.1's fresh summand `Formula` has `DecidableEq`); only `Fintype`-finiteness is truly
>   lost. So `[DecidableEq sig.preds]` threading survives; `[Fintype sig.preds]` vanishes at Phase 3.
> - **Why PARTIAL, not COMPLETED:** the DoD requires full `lake build` EXIT 0. Removing the fields is
>   a transitive instance-threading cascade over the whole abstract-`sig` `NormalForm`-`Fintype`
>   surface — measured ~30-40 files across ≥3 build-waves (wave 2 = `EFGames/StaviCompleteness` [41
>   errors, 60 decls], `Kamp/IntervalType` [incl. a genuine "unsolved goals" proof-repair at ~line
>   109, NOT pure binder-threading], `Kamp/NfToVecEA`, `OrderedSum`; wave 3+ = the ~18-file
>   IntervalType/UnaryType Kamp tree + `PriorExpressiveness`/`CharacteristicFormula`/`WeakCanonical`/
>   `Claim1`). This exceeds one agent run and cannot be committed green until the WHOLE build passes.
> - **The plan's Rollback §Phase-2 note ("scoped to two files; revert to last-green") UNDER-estimated
>   the blast radius** (the Risk table's "foundational, expected consequence" was right; the rollback
>   estimate was not). Working tree was reverted to green HEAD per that sanctioned rollback; the
>   complete correct work is preserved as `handoffs/phase2-foundational-fintype-removal.patch` (+ git
>   `stash@{0}`) with a wave-by-wave continuation recipe in `handoffs/phase-2-handoff-20260723.md`.
> - **Resume:** `git apply` the patch, then grind the cascade wave-by-wave (add `[Fintype sig.preds]
>   [DecidableEq sig.preds]` after each failing decl's `sig` binder; concrete-sig call sites need
>   nothing), repairing the handful of genuine proof breaks, until full green + `#print axioms`
>   byte-identical to baseline.

- **Goal:** Make an infinite-alphabet signature constructible. Remove the `[fintypePreds : Fintype
  preds]` and `[decEqPreds : DecidableEq preds]` instance fields from `MonadicSignature`
  (`MonadicFO.lean`); thread finiteness/decidability as an EXPLICIT per-formula hypothesis where they
  were implicit. Re-derive the `AtomKind`/`NormalForm` `Fintype`/`DecidableEq` instances and the card
  lemmas (`atomKind_card`/`normalForm_card`) under the new discipline (`NormalForm.lean`).
- **Faithfulness anchor:** report 19 A2 (`MonadicSignature` structurally REQUIRES `Fintype preds` as a
  field, so infinite E[Σ] is not constructible until it is removed) + Def 4.1 (p.5, E[Σ] is infinite).
  Report 20 §2.2 verdict: FAITHFUL (structural necessity, not mathematics).
- **Tasks:**
  - [x] Remove `[fintypePreds]`/`[decEqPreds]` from the `MonadicSignature` structure (`MonadicFO.lean`). *(completed)*
  - [x] Re-derive `AtomKind sig n` `Fintype`/`DecidableEq` (`NormalForm.lean`) taking the needed
        finiteness/decidability as explicit hypotheses rather than field-projections. *(completed)*
  - [x] Re-derive `NormalForm sig k n := AtomKind sig n → Bool`'s `Fintype × DecidableEq` and the card
        lemmas (`atomKind_card`/`normalForm_card`) under the explicit-hypothesis discipline. *(completed)*
  - [x] Fix breakage local to the two foundational files; confirm the wider tree still builds (finite
        signatures still supply the hypotheses; only the infinite-alphabet path needs the new form).
        *(completed — deviation: altered — the cascade spanned ~45 files, not just the two foundational
        files; the plan's Rollback note under-estimated the blast radius. Threaded mechanically; three
        genuine non-binder repairs (muSig/sigCex bridge instances, mkSigFrom field removal) documented
        in the COMPLETED note above.)*
- **Definition of Done:** `MonadicFO.lean` and `NormalForm.lean` build green, sorry-free, axiom-clean;
  full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline. An
  infinite-alphabet signature is now constructible (verified by a throwaway `#check` on a
  `Formula`-indexed fresh summand).
- **Timing:** 8-14 hours (~200-450 lines; foundational). ~1-2 agent runs.
- **Depends on:** 1 (gate GREEN).
- **Files to modify:** `Theories/Bimodal/Metalogic/FirstOrder/MonadicFO.lean` (or wherever
  `MonadicSignature` lives), `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NormalForm.lean`.
- **Prohibited:** no `sorry`; do NOT re-introduce a global `Fintype preds` field; no spine edit.

---

### Phase 3: Re-index `sigE` onto the infinite `Formula` alphabet (Def 4.1) + retire the now-vacuous readback-closure probes [IN PROGRESS]

- **Goal:** Change `sigE`'s fresh summand from `{A // A ∈ F}` (finite) to the full `Formula` type
  (infinite E[Σ], Def 4.1 p.5). Update `esigmaPred`/`canonExpand`/`ESigmaCapture` so `esigmaPred A`
  needs no `hA : A ∈ F`. This is where `not_readbackClosed`/`ReadbackClosed` become VACUOUS (readbacks
  are automatically atoms) — delete the `ZetaReadbackClosure`/`ZetaEngineClosure` probes.
- **Faithfulness anchor:** Rabinovich Def 4.1 (PDF p.5, E[Σ] = Σ ∪ {A | A a TL(U,S)-formula over Σ},
  infinite) + the p.6 collapse note. Report 20 §2.2 verdict: FAITHFUL (literally Def 4.1).

> **SEQUENCING DECISION (Phase 3↔4, recorded per orchestrator delegation — this is sequencing, NOT a
> plan-content change): land the `sigE` summand flip LAST, re-encode the enumeration surface FIRST.**
> The `sigE_fintypePreds`/`UnaryType` inspection resolves the entanglement decisively:
> `UnaryType sig F := NormalForm (sigE sig F) 0 1`, whose `Fintype`/`DecidableEq` (load-bearing for
> `IntervalType := Finset (UnaryType)` and every `Finset.univ : Finset (UnaryType)` enumeration)
> derive ENTIRELY from `Fintype (sigE sig F).preds` — i.e. from the finite alphabet. Flipping the
> fresh summand `{A // A ∈ F}` → `Formula` deletes that `Fintype` and breaks the ENTIRE
> `UnaryType`/`IntervalType` surface AT ONCE — not just 4a, but the whole ~18-file Phase-4 tree +
> the ζ consumers. So the summand flip and the Phase-4 per-formula re-encode are INSEPARABLE:
> neither "Phase 3 alone green" nor "3+4a together green" is reachable (4b/4c break from the same lost
> `Fintype`). The ONLY green intermediate between the current HEAD (finite alphabet, total `UnaryType`)
> and the end-state (infinite alphabet, per-formula `UnaryType`) is **finite alphabet + per-formula
> `UnaryType`**: do the Phase-4 re-encode first WITH `sigE` STILL FINITE — the per-formula rep's
> `Fintype` comes from `M : Finset (AtomKind …)` (each formula mentions finitely many atoms), NOT from
> the alphabet, so it builds green against the finite alphabet and full `lake build` stays EXIT 0 at
> each commit — THEN perform the summand flip (delete `sigE_fintypePreds`, drop `hA` from `esigmaPred`,
> re-point the fresh atom) as the small terminal green step of Phase 3. This is the handoff's sanctioned
> "summand change staged behind a `DecidableEq`-only path" (decidability survives the flip:
> `Formula` has `DecidableEq`; only `Fintype`-finiteness is lost). Faithfulness is unchanged — the
> end-state is exactly Def 4.1 infinite E[Σ] + per-formula rep; only the LANDING ORDER differs.
> **Guardrail (must carry into Phase 4):** because the re-encode is done while the alphabet is still
> finite, `Finset.univ : Finset (UnaryType …)` still COMPILES; the re-encode must nonetheless route ALL
> point/interval finiteness through per-formula `M`, NEVER a total `Finset.univ` over `UnaryType` — any
> residual alphabet-wide `Finset.univ` will surface as RED at the final flip (the compiler check the
> plan's "no full-alphabet `Finset.univ`" invariant is deferred to). Grep-guard for
> `Finset.univ` typed at `UnaryType`/`AtomKind (sigE …)` before the flip.
>
> **Rationale for this ordering over flip-first:** flip-first (Option A) has the compiler enforce the
> invariant but keeps the tree RED through the ENTIRE re-base with no green commit — under the
> crash/budget-exhaustion discipline (revert-to-green-HEAD on interrupt) that means every interrupted
> run banks ZERO forward progress across a 60-100h task. Re-encode-first (this decision) banks green
> commits along the way and is crash-safe.

- **Tasks:**
  - [x] Re-confirm spine-safety: re-run `grep -rln 'sigE\|UnaryType\|IntervalType'` over `BXCanonical/`
        and `Decidability/` (expect empty, per report 19) before committing the re-index. *(completed —
        grep returned EMPTY over both trees; spine-safety re-confirmed.)*
  - [ ] Change `sigE sig F`'s fresh summand from `{A // A ∈ F}` to `Formula`; construct the
        `MonadicSignature` using the Phase-2 explicit-finiteness form. *(deviation: deferred — per the
        SEQUENCING DECISION above, this summand flip lands LAST, after the Phase-4 per-formula re-encode;
        it is a small terminal step, not the leading edge of Phase 3.)*
  - [ ] Update `esigmaPred`/`oldPred`/`canonExpand` (`ESigmaExpansion.lean`) so `esigmaPred A` takes no
        `hA` proof; the fresh atom's interp remains `sat A` (semantic core preserved). *(deviation:
        deferred — bundled with the summand flip, lands LAST per the SEQUENCING DECISION.)*
  - [ ] Update `ESigmaCapture` so the atom-naming (`canonExpand_atom_named`) no longer requires `A ∈ F`.
        *(deviation: deferred — bundled with the summand flip, lands LAST per the SEQUENCING DECISION.)*
  - [x] Delete `ZetaReadbackClosure.lean` (`not_readbackClosed`) and `ZetaEngineClosure.lean`
        (`ReadbackClosed`/`*_of_closed`) — now vacuous; record in the deletion commit message that they
        are superseded by the infinite E[Σ]. PRESERVE `OptionBLocalityProbe.lean` (the B-refutation stays).
        *(completed — both were a leaf cluster imported by NOBODY (only `ZetaReadbackClosure` imported
        `ZetaEngineClosure`; `OptionBLocalityProbe` references them only in doc-comments, not imports),
        so `git rm` of both is provably non-breaking. Deviation: altered — deleted BEFORE the summand
        flip rather than after; justification recorded as "superseded by the adjudicated Option A
        architecture decision (vacuous once the alphabet is infinite)".)*
- **Definition of Done:** the re-indexed `sigE` + `esigmaPred`/`canonExpand`/`ESigmaCapture` build
  green, sorry-free, axiom-clean; the two closure probes are deleted; full `lake build` EXIT 0;
  `#print axioms completeness_discrete` byte-identical to baseline. Off the live import path.
- **Timing:** 6-12 hours (~200-400 lines net, incl. deletions). ~1-2 agent runs.
- **Depends on:** 2.
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaExpansion.lean`,
  `ESigmaCapture.lean`; DELETE `ZetaReadbackClosure.lean`, `ZetaEngineClosure.lean`.
- **Prohibited:** no `sorry`; do NOT delete `OptionBLocalityProbe.lean`; no spine edit.

---

### Phase 4: Re-encode the `Finset.univ` enumeration surface onto per-formula finite atom sets (split 4a → {4b, 4c}) [IN PROGRESS]

**Framing:** This is the largest phase and the core of Option A's cost — rewriting "type = finite
disjunction over ALL 1-types (`Finset.univ`)" onto the Phase-1 per-formula-finite-atom representation.
`Finset.univ` over the now-infinite alphabet does not exist; each site is re-encoded to disjoin only
over the finitely many atoms the formula mentions. Split per file (H8) so each sub-phase is ~one agent
run, with the `IntervalType.lean` representation landing first (4a) and the two heaviest consumers
(4b `LiftPair.lean`, 4c `Prop43Translate.lean` + `ConjInterleave.lean`) following in parallel.

**Faithfulness anchor (whole phase):** Rabinovich Prop 3.5 (PDF p.5, ∨∃∀ ≡ TL) + Def 3.1 (p.4, unary
αⱼ/βⱼ) + the report-19 A3 / report-20 §2.2 finding that the `Finset.univ` finiteness is STRONGER than
Rabinovich needs (each formula mentions finitely many atoms). Validated by the Phase-1 gate FOR THE
POINT-TYPE CLAUSE only (see the Phase 4b risk note).

#### Phase 4a: `IntervalType.lean` — re-encode the interval-type representation onto per-formula finite atom sets [NOT STARTED]

- **Goal:** Promote the Phase-1 `UnaryTypeFin` representation into the production `UnaryType`/
  `IntervalType` in `IntervalType.lean` (and `ExistsForallFormula.lean` where
  `UnaryType`/`IntervalType`/`intervalHolds` live). Replace the `(Finset.univ : Finset (UnaryType sig
  F))` model-enumeration and the `intervalHolds` definition so they range over per-formula finite atom
  sets, not the whole alphabet. Re-prove the basic algebra (`intervalHolds_mono`/`_inter_iff`/`_bot`/
  `ofComplete` compat).
- **Tasks:**
  - [ ] Re-define `UnaryType`/`IntervalType` on the per-formula-finite-atom representation (Phase-1 shape).
  - [ ] Re-define `intervalHolds` without `Finset.univ`; re-prove `ofComplete`/`intervalConj`/
        `intervalBot` and the algebra lemmas.
  - [ ] Re-establish the `efSat` interval-clause bridge lemmas (`efSat_interval_iff`, `intervalSet_*_iff`).
- **Definition of Done:** `IntervalType.lean` (+ the `ExistsForallFormula.lean` core) build green,
  sorry-free, axiom-clean; off-path; `lake build` EXIT 0; axioms unchanged.
- **Timing:** 6-10 hours (~200-400 lines). ~1 agent run.
- **Depends on:** 3.
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/IntervalType.lean`,
  `ExistsForallFormula.lean`.

#### Phase 4b: `LiftPair.lean` — re-encode the `charType`/`skelDisjunct`/`liftPair_forward/backward` enumeration (HARDEST SITE) [NOT STARTED]

> **POST-GATE RISK — this is where the residual representation risk now lives (report 20 §3.3).** The
> Phase-1 GATE GO validated the per-formula-finite representation ONLY on the point-type clause of a
> trivial `ξConcrete` (`n = 0`, empty interval clauses). It did NOT exercise the `Finset.univ : Finset
> (Fin (K+1) → UnaryType)` TUPLE skeleton disjunction that `charType`/`skelDisjunct` use, non-empty
> interval clauses, or the `liftPair_forward`/`liftPair_backward` equivalence. So 4b — NOT the GATE —
> carries the open representation risk. **If the tuple skeleton disjunction cannot be re-encoded onto
> per-formula finite atom sets WITHOUT a full-alphabet `Finset.univ`, that is a return-to-gate signal:
> STOP and surface for `/research`; do NOT force with a global `Finset.univ` or weaken a correctness
> statement.** The fwd/bwd split contingency below is a FIRST-CLASS fallback, not an afterthought.

- **Goal:** The single hardest obligation (report 19 A3). Rewrite the `(Finset.univ : Finset (Fin (K+1)
  → UnaryType sig F))` skeleton disjunction (`charType`, `skelDisjunct`, `skelR_sat`,
  `liftPair_forward`/`liftPair_backward`) onto per-formula finite atom sets. Prove "type = finite
  disjunction of the atoms the formula mentions" and the forward/backward equivalence WITHOUT a total
  `Finset.univ`.
- **Tasks:**
  - [ ] Re-encode `charType`/`unaryHolds_charType`/`exists_unaryHolds` onto per-formula finite atoms.
  - [ ] Re-encode `skelDisjunct`/`skelR`/`skelR_sat` (the tuple skeleton disjunction) without
        `Finset.univ`.
  - [ ] Re-prove `liftPair_forward` and `liftPair_backward` (+ `liftPairV`/`liftSentence` wrappers and
        their `_iff` lemmas) on the new representation.
- **Split contingency (H8, FIRST-CLASS fallback):** if this overflows one run — likely, given the
  post-GATE risk — split by direction (4b-fwd `liftPair_forward` / 4b-bwd `liftPair_backward`); each
  lands green off-path.
- **Definition of Done:** `LiftPair.lean` builds green, sorry-free, axiom-clean; off-path; `lake build`
  EXIT 0; axioms unchanged.
- **Timing:** 12-24 hours (~400-800 lines; the heaviest re-encode). ~1-2 agent runs.
- **Depends on:** 4a.
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean`.

#### Phase 4c: `Prop43Translate.lean` + `ConjInterleave.lean` — re-encode the remaining enumeration sites [NOT STARTED]

- **Goal:** Rewrite the `(Finset.univ : Finset (Fin (m+1) → UnaryType sig F)).filter …`
  (`Prop43Translate.lean`) and the `Fintype`-enumeration + `Finset.card_image_le`
  (`ConjInterleave.lean`) onto per-formula finite atom sets, preserving the δ `translate_correct`
  structural induction and the α `conjInterleave_iff` merge.
- **Tasks:**
  - [ ] Re-encode `Prop43Translate.lean`'s `Finset.univ` filter onto per-formula finite atoms; re-establish
        `translate`/`translate_correct` (all six connective cases) on the new representation, preserving
        the report-15 `StrictMono ψ.pin` conclusion-strengthening.
  - [ ] Re-encode `ConjInterleave.lean`'s `Fintype`-enumeration / `card_image_le`; re-establish
        `conjInterleave_iff` + `veeConj_iff` on the new representation.
- **Definition of Done:** both files build green, sorry-free, axiom-clean; off-path; `lake build` EXIT
  0; axioms unchanged.
- **Timing:** 10-18 hours (~350-650 lines; may split per file). ~1-2 agent runs.
- **Depends on:** 4a. Runs parallel with 4b (file-disjoint).
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean`,
  `ConjInterleave.lean`.
- **Prohibited (whole Phase 4):** no `sorry`; no full-alphabet `Finset.univ`; do NOT weaken any
  correctness statement or drop a conjunct to force a fit; no spine edit.

---

### Phase 5: ζ re-wire — discharge capture DIRECTLY (readback IS an atom), construct the ζ `canonExpand`, spine re-point, retire `nf_nvar_exist_all_depths | _k+2` LAST (terminal, live-path) [NOT STARTED]

> **Optional split (report 20 §4.2):** if the single run overflows, split into 5a (capture removal + ζ
> `canonExpand` construction, off-path-verifiable) / 5b (spine re-point + audit-block correction +
> residual deletion + `#print axioms` check). The residual deletion and the `#print axioms` check MUST
> be the terminal actions of 5b.

- **Goal:** With the infinite E[Σ] (Phase 3) and the re-encoded enumeration surface (Phase 4) landed
  off-path, re-wire the ζ consumers (`ZetaUniformExtract`, `EFSatNegationGeneral`): the capture
  obligation is discharged DIRECTLY because every readback is an atom of the infinite expansion —
  REMOVE the `hCapture`/`capFn` parameters entirely. Construct the ζ `canonExpand` from the surviving
  landed reconciliations (`atomMap = oldPred ∘ g` from `ZetaAtomMapReconcile.lean`, `HasAttainedINF/SUP`
  from `ZetaPriorTransfer.lean`, lifted `psi` from `MonadicFormulaMap.lean`, carrier witness giving
  `hne : Nonempty N.carrier` per report 13). Re-point `kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery`; verify green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT; then **delete it LAST**; confirm
  `#print axioms completeness_discrete` no longer lists `sorryAx`. This is the ONLY live-path phase.
- **Landed-asset dependency (prose, per D5):** this phase consumes the landed reconciliations
  `ZetaAtomMapReconcile.lean` (`Sum.inl`/`Sum.inr` collapse), `ZetaPriorTransfer.lean`
  (`HasAttainedINF/SUP`), and `MonadicFormulaMap.lean` (`mapPreds`). These are committed FILES, not
  phases of this plan — they are dependencies-in-fact carried in the task bullets below, not in the
  `Depends on` field (which lists only this plan's phase numbers).
- **Faithfulness anchor:** Rabinovich Thm 4.4 (PDF p.6, φ ≡ ⋁ᵢ φᵢ, each →Prop 3.5→ TL — the readback
  is automatically an atom of the infinite expansion, needs no `∈ F`) + Def 4.1 collapse note (p.6) +
  report 13 (`hne` mandatory) + report 19 / report 20 §2.2 (Phase-5: capture discharged directly,
  `hCapture`/`capFn` removed — FAITHFUL).
- **Tasks:**
  - [ ] Re-wire `ZetaUniformExtract` / `EFSatNegationGeneral` to discharge capture DIRECTLY (readback is
        an atom); remove the `hCapture`/`capFn` parameters from the uniform + non-uniform negation stack.
  - [ ] Verify the surviving landed `ZetaAtomMapReconcile` (`Sum.inl`/`Sum.inr` collapse),
        `ZetaPriorTransfer` (`HasAttainedINF/SUP`), and `MonadicFormulaMap` (`mapPreds`) type-check
        against the re-indexed `sigE` and re-state where the fresh summand's index type changed.
  - [ ] Construct the ζ `canonExpand` on the infinite E[Σ] with `atomMap = oldPred ∘ g` and the carrier
        witness giving `hne`.
  - [ ] Collapse the (now capture-free) β / γ / δ results — as re-encoded in Phase 4 — to UNCONDITIONAL;
        apply the (re-encoded) uniform extraction to obtain the single `M`-uniform formula; wire the
        semantic `MonadicFormula → characteristic NormalForm` bridge into the live spine.
  - [ ] Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery`.
  - [ ] **Correct the STALE in-file audit block in `BXCanonical/Completeness.lean`** (carry-forward,
        report 20 §3.1): the axiom-audit block still cites rotted line refs (`:212/:361/:364`) and
        describes an already-discharged n=1 arm (`kampPrior_case1_arm_k1`) as still-sorry. Rewrite it to
        name `nf_nvar_exist_all_depths` (the `| _k+2` arm) by DECLARATION NAME as the sole residual —
        no line numbers, no task-number pointers (durable anchors only).
  - [ ] **Verify the new path is green with the `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT**
        (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths | _k+2` arm (the residual + its rationale
        block); update the in-file audit block (above) to reflect its removal and any stale doc-comment refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Definition of Done:** `#print axioms completeness_discrete` no longer lists `sorryAx` (retains
  `propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`); full `lake
  build` EXIT 0; no new axiom/sorry anywhere on the proof term. The in-file audit block in
  `Completeness.lean` names `nf_nvar_exist_all_depths` by declaration name (no rotted line refs). Hand
  off to task 375 for the terminal audit.
- **Timing:** 12-20 hours (~400-700 lines), plus the `canonExpand` construction + direct capture
  discharge. ~1-2 agent runs (or split 5a/5b).
- **Depends on:** 4b, 4c.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean`
    (capture removal + ζ wire),
  - `KampPrior.lean` (delete the `nf_nvar_exist_all_depths | _k+2` arm — LAST),
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-point + audit-block correction),
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files.
- **Prohibited:** no `sorry`/`def := True`/vacuous placeholder on the spine; no reset/checkout; do NOT
  delete the `nf_nvar_exist_all_depths | _k+2` arm until the new path is proven green end-to-end.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at the current job floor.
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phases 1-4
      the axiom set is byte-identical to baseline (the pre-existing `nf_nvar_exist_all_depths | _k+2`
      `sorryAx` remains, carrying the spine). Target end-state after Phase 5: `[propext,
      Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no `sorryAx`.
- [ ] The amended sorry gate holds: the only live sorries anywhere are `nf_nvar_exist_all_depths | _k+2`
      (until Phase 5), `EANegation.lean:1090`, and `EANegation.lean:1249`. No phase introduces any other
      sorry. (Report 20 machine-verified exactly these three are currently live.)
- [ ] Incremental-with-fallback: Phases 2-4 land off the live import path and green BEFORE Phase 5
      touches the spine; Phase 5 proves the new path green with the residual still present, then deletes
      the arm LAST. Verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, or full-alphabet `Finset.univ` re-introduced. A failed
      foundational instance in Phase 2 is a return-to-gate, not a global `Fintype` papered on; a Phase-4b
      tuple-skeleton failure that needs the full alphabet is a return-to-gate, not a hole.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number or
      a Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page). The k≥2
      blocker is referenced by declaration name `nf_nvar_exist_all_depths`, never by line.
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks:
- [x] **Phase 1 (GATE)**: the per-formula-finite-atom Prop-3.5 equivalence for one readback compiles
      sorry-free, axiom-clean, off-path, WITHOUT a full-alphabet `Finset.univ`. **GO** (machine-checked).
- [ ] **Phase 2**: `MonadicFO.lean` + `NormalForm.lean` build green with `[fintypePreds]`/`[decEqPreds]`
      removed and finiteness threaded explicitly; an infinite-alphabet signature is constructible.
- [ ] **Phase 3**: `sigE` re-indexed onto `Formula`; `esigmaPred A` needs no `hA`; `ZetaReadbackClosure`/
      `ZetaEngineClosure` deleted (vacuous); `OptionBLocalityProbe` preserved; spine-safety grep re-confirmed.
- [ ] **Phase 4 (4a/4b/4c)**: `IntervalType`/`LiftPair`/`Prop43Translate`/`ConjInterleave` re-encoded onto
      per-formula finite atom sets, sorry-free, axiom-clean, off-path; no `Finset.univ` over the alphabet;
      `liftPair_iff`/`conjInterleave_iff`/`translate_correct` re-established. (4b tuple skeleton disjunction
      is the post-GATE risk site.)
- [ ] **Phase 5 (ζ)**: capture discharged DIRECTLY (readback IS an atom), `hCapture`/`capFn` removed; the ζ
      `canonExpand` constructed; conditional β/γ/δ collapse to unconditional; the `Completeness.lean`
      in-file audit block corrected to name `nf_nvar_exist_all_depths` by declaration; the `_k+2` arm is
      DELETED LAST; `sorryAx` confirmed absent from `completeness_discrete`.

## Artifacts & Outputs

- plans/21_infinite-esigma-alphabet-optionA-v2.md (this file)
- PRESERVED landed assets (do NOT rebuild): `OptionBLocalityProbe.lean` (`capFn_forces_local`, the
  Option-B NO-GO record); the surviving-shape reconciliations `ZetaAtomMapReconcile.lean`,
  `ZetaPriorTransfer.lean`, `MonadicFormulaMap.lean`; `Section5Correspondence.lean`, `VecEANegFix.lean`;
  the `canonExpand` semantic core + `temporal_truth_canonExpand` conservativity in
  `ESigmaExpansion.lean`/`ESigmaCapture.lean`; `InfAlphabetProbe.lean` (Phase-1 GATE, off-path).
- SLATED FOR DELETION in Phase 3 (vacuous under infinite E[Σ]): `ZetaReadbackClosure.lean`
  (`not_readbackClosed`), `ZetaEngineClosure.lean` (`ReadbackClosed`/`*_of_closed`).
- New / rewritten `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules:
  - Phase 1: `InfAlphabetProbe.lean` (landed; off-path gate).
  - Phase 2: edits to `MonadicFO.lean`, `NormalForm.lean`.
  - Phase 3: edits to `ESigmaExpansion.lean`, `ESigmaCapture.lean`; deletions.
  - Phase 4: rewrites to `IntervalType.lean`, `ExistsForallFormula.lean` (4a), `LiftPair.lean` (4b),
    `Prop43Translate.lean`, `ConjInterleave.lean` (4c).
  - Phase 5: edits to `ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean`, `KampPrior.lean` (arm
    deletion), `BXCanonical/Completeness.lean` (spine re-point + audit-block correction), the
    `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain.
- summaries/21_infinite-esigma-alphabet-optionA-v2-summary.md (on completion)

## Rollback/Contingency

- **Phase 1 (GATE):** DONE/GO — additive/off-path. No rollback needed; the probe stays as landed
  documentation of the GO verdict.
- **Phase 2 foundational failure:** if a re-derived `AtomKind`/`NormalForm` instance or card lemma has
  no per-formula finite witness, that is a Phase-1-class signal — return to the gate; do NOT re-introduce
  a global `Fintype preds` field. The change is scoped to two files; revert to last-green and resume.
- **Phase 3 re-index failure:** additive-then-deletion; if the infinite re-index breaks a surviving
  reconciliation, revert the re-index (restore the finite `sigE`) to last-green; the deletions of the
  closure probes are done only after the re-indexed `sigE` builds green.
- **Phase 4 re-encode failure:** each sub-phase (4a/4b/4c) is additive/off-path and file-disjoint; a
  failed attempt leaves last-green intact and resumable. `LiftPair.lean` (4b) may split by direction if
  it overflows one run (first-class fallback). Do NOT weaken a correctness statement to force a fit — if
  the 4b tuple skeleton disjunction genuinely needs the full alphabet, that is the post-GATE risk
  materializing and is a return-to-gate / `/research` escalation, NOT a hole.
- **Phase 5 regression:** incremental-with-fallback. The new path is proven green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT; the arm deletion is done LAST and verified
  immediately with `#print axioms`. If the spine re-point regresses the build or the axiom set, revert
  the Phase-5 edits (spine re-point + audit-block correction + arm deletion) to restore the last-green
  state where all Phase 1-4 modules exist but the old residual still carries the spine. `sigE` never
  reaches the spine, so the blast radius of a Phase-5 revert is the three
  `kamp_prior_*`/`US_expressively_*`/`no_gaps_*` consumers + the `Completeness.lean` audit block only.
