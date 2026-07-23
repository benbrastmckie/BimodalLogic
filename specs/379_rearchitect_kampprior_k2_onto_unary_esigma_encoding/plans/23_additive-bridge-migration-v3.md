# Implementation Plan: Additive-Bridge Migration to Per-Formula E[Sigma] (Rabinovich Def 3.1/4.1)

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
  - Started: 2026-07-19T11:58:03-07:00
- **Effort**: ~60-100 hours across 12 phases (Phases 1-2 COMPLETE; Phase 3 retained scope COMPLETE; Phase 4 re-decomposed into the additive-bridge migration 4a-0 -> 4a-1 -> 4a-2 render micro-gate -> 4a-3 -> 4a-4..N consumer migration -> 4b LiftPair alone -> 4c switchover+deletions -> 4-flip terminal summand flip; Phase 5 unchanged). ~1,500-3,000+ new/rewritten Lean lines, ~60-100+ declarations touched. **Blast radius CONTAINED to `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` + the two foundational files `MonadicFO.lean`/`NormalForm.lean`; Decidability/FMP: 0 files; `Separation/KampTranslation.lean`: 0 edits (grep-verified spine-safety + report-22 renderer-scope verdict).** Phase 1 was the go/no-go GATE and is GREEN (GO); Phases 2-5 authorized.
- **Dependencies**: None to start (all inputs — the base beta/gamma/delta shape, the landed reconciliations, the machine-checked A-vs-B spike, the blocker root-cause report — are landed/committed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 5; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here). No task-dependency changes are made by this revision.
- **Research Inputs**: reports/22_phase4a-staging-blocker-research.md (AUTHORITATIVE for THIS revision — the Phase-4a staging-blocker root-cause analysis: refutes the plan-v21 in-place-swap Phase-4 premise, establishes the paper-faithfulness verdict that per-formula-M IS Rabinovich Def 3.1/Prop 3.5 [the total `UnaryType` was a finite-alphabet encoding artifact], the 17-file Consumer Classification, the ordered green-at-every-commit additive-bridge Migration Order table, and the explicit non-goal that `Separation/KampTranslation.lean` is NOT edited); reports/20_plan19-format-faithfulness-remaining-work.md (the plan-format audit surfacing defects D1-D7, the PDF-grounded faithfulness PASS re-confirming every construction against Rabinovich pages 4-6 by direct read, the machine-checked current-state inventory of exactly three permitted sorries, and the ordered format-compliance + state-refresh checklist); reports/19_architecture-spike-A-vs-B.md (the decisive A-vs-B architecture spike: machine-checked B-refutation `capFn_forces_local`, the A blast-radius map, the grep-verified spine-safety of `sigE`, and the 5-phase Option-A scope with a Phase-1 de-risking gate); reports/18_readback-closed-finite-fl-rescope.md (the NO-GO verdict on the finite-`F` readback closure that forced the A-vs-B decision); the committed machine-checked refutation `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean` (`not_readbackClosed`); the committed B-locality refutation `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean` (`capFn_forces_local`); reports/17_b5-capture-bound-audit.md, reports/16_zeta-wire-blocker-probe.lean, reports/15_exall-gap-monotone-pinning-verdict.md, reports/14_exall-reordering-closure-resolution.md, reports/13_c1-c2-negation-object-blueprint.md, reports/11_esigma-capture-hypothesis-audit.md, reports/07_faithful-esigma-negation-path.md, reports/09_conjinterleave-interval-type-audit.md, reports/05_conjunction-closure-load-bearing-verdict.md, reports/06_phase4-unblock-construction.md (all carried forward)
- **Artifacts**: plans/23_additive-bridge-migration-v3.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 22_phase4a-staging-blocker-research.md, 20_plan19-format-faithfulness-remaining-work.md, 19_architecture-spike-A-vs-B.md, 18_readback-closed-finite-fl-rescope.md, 17_b5-capture-bound-audit.md, 16_zeta-wire-blocker-probe.lean, 15_exall-gap-monotone-pinning-verdict.md, 14_exall-reordering-closure-resolution.md, 13_c1-c2-negation-object-blueprint.md, 11_esigma-capture-hypothesis-audit.md, 07_faithful-esigma-negation-path.md, 09_conjinterleave-interval-type-audit.md, 05_conjunction-closure-load-bearing-verdict.md, 06_phase4-unblock-construction.md
- **plan_metadata**:
  ```json
  {
    "phases": 12,
    "total_effort_hours": 80,
    "complexity": "complex",
    "research_integrated": true,
    "plan_version": 23,
    "dependency_waves": [["1"], ["2"], ["3"], ["4a-0"], ["4a-1"], ["4a-2"], ["4a-3"], ["4a-4"], ["4b"], ["4c"], ["4-flip"], ["5"]],
    "reports_integrated": [
      {"path": "reports/22_phase4a-staging-blocker-research.md", "integrated_in_plan_version": 23, "integrated_date": "2026-07-23"},
      {"path": "reports/20_plan19-format-faithfulness-remaining-work.md", "integrated_in_plan_version": 21, "integrated_date": "2026-07-23"},
      {"path": "reports/19_architecture-spike-A-vs-B.md", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"},
      {"path": "reports/18_readback-closed-finite-fl-rescope.md", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean", "integrated_in_plan_version": 21, "integrated_date": "2026-07-19"}
    ]
  }
  ```
  (`plan_version: 23` matches this artifact FILE number and the `revise plan (v23)` commit convention. The `dependency_waves` MATCH the fully-sequential 12-wave human-readable table below.)

### Revision Changelog (plan v21 -> this plan v23)

This revision is a **Phase-4 re-decomposition driven by the Phase-4a staging blocker** (report 22).
Everything upstream of Phase 4 is UNCHANGED: Option A is adjudicated (report 19), Option B is
machine-refuted (`capFn_forces_local`), finite-`F` is machine-refuted (`not_readbackClosed`), the
Phase-1 GATE returned a machine-checked GO, and Phases 1-2 landed green. The changes applied here:

- **Phase 4 in-place swap REPLACED by additive-bridge migration (report 22 §4).** Plan v21's Phase 4
  (4a `IntervalType.lean` -> {4b `LiftPair.lean`, 4c `Prop43Translate.lean`+`ConjInterleave.lean`})
  staged the per-formula re-encode as an **IN-PLACE swap** of the total `UnaryType`/`IntervalType`
  names and the `ExistsForallFormula` stored field types. Report 22 refutes that premise by static
  evidence: `UnaryType sig F := NormalForm (sigE sig F) 0 1` is a bare, `M`-free type consumed in 17
  Kamp files (25 uses in `LiftPair.lean`) INCLUDING as `ExistsForallFormula` stored field types, so
  any in-place arity/semantics change breaks the whole surface at once — there is NO green-at-every-
  commit order for an in-place swap, and the flip-last device does not rescue it (the break is
  independent of alphabet finiteness). Phase 4 is re-decomposed into the ordered ADDITIVE-BRIDGE
  migration (a parallel per-formula representation + a finite-alphabet `completions` bridge; migrate
  the 17 consumers one file per commit behind the bridge; delete the total types last).
- **`Separation/KampTranslation.lean` declared explicitly OUT OF SCOPE (report 22 §3).** Plan v21's
  Phase-4a blocker flagged `nf_depth0_char_formula` (which folds over `Fintype.elems (sig.preds)`)
  as an unscoped foundational file that would need re-encoding. Report 22's decisive negative finding:
  `nf_depth0_char_formula` has ~40+ consumers OUTSIDE the exists-forall chain (`KampPrior.lean`
  itself, the whole `NfMultiAnchorBridge/` tree, Boneyard archives) at finite/concrete signatures
  where `[Fintype sig.preds]` legitimately holds. It MUST stay exactly as it is. The correct move is
  ADDITIVE: one NEW Kamp-layer per-formula renderer (`unaryToFormulaFin` folding over `M.toList`)
  used by the exists-forall chain at `sigE`; `Separation/KampTranslation.lean` is NEVER edited.
- **Render micro-gate ADDED (4a-2, report 22 §5).** A new explicit GO/NO-GO gate exercises the exact
  render-correctness obligation the Phase-1 gate missed (`translateProp35Fin` end-to-end through
  `unaryToFormulaFin_correct` on a nontrivial `n = 1` input) BEFORE any mass consumer migration. This
  discharges report 20 §3.3's residual 4b representation risk early, honoring this task's three-strikes
  history.
- **Paper-faithfulness verdict RECORDED in-plan (report 22 §2).** Per-formula-M IS the faithful
  transcription of Def 3.1's quantifier-free one-variable `alpha_j`/`beta_j` (Prop 3.5's `A_i`); the
  repo's TOTAL `UnaryType` (a truth assignment to ALL E[Sigma] atoms, rendered by folding over
  `Fintype.elems`) was a repo-local finite-alphabet ENCODING ARTIFACT, never the paper's object. The
  "semantics change" worry (weakening `unaryHolds` to mentioned-`M` agreement) is the paper's own
  satisfaction notion for a quantifier-free formula; during migration the two are connected by the
  finite-alphabet `completions` bridge, so NO correctness statement is weakened — the old total-type
  statements are reproved as consequences of the Fin-variants, then retired.
- **Flip-last decision KEPT (report 22 §4 rec 4).** The recorded flip-last decision (Phase 3
  blockquote below) is PRESERVED — it is what makes the finite-alphabet `completions` bridge available
  during the whole migration. Its premise failed only for the *in-place* 4a, not for the additive
  path. The summand flip `{A // A in F}` -> `Formula` moves to its own named terminal sub-phase
  (Phase 4-flip) AFTER 4c, per the report-22 Migration Order table.
- **Phase 3 retained scope marked COMPLETE; summand flip relocated.** Phase 3's landed items
  (spine-safety grep re-confirmation; deletion of the vacuous `ZetaReadbackClosure`/`ZetaEngineClosure`
  probes) stay as history. Its remaining work — the `sigE` summand flip — is moved out of Phase 3 to
  the new terminal Phase 4-flip (after 4c), per path A.
- **Phase 5 UNCHANGED in content**, renumbered to depend on Phase 4-flip (was `4b, 4c`): capture
  discharged directly, ζ `canonExpand` construction, spine re-point, the `Completeness.lean` audit-block
  correction by declaration name, `nf_nvar_exist_all_depths | _k+2` deleted LAST, final sorry-inventory
  / `#print axioms` verification.

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) still carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of the declaration `nf_nvar_exist_all_depths` in `KampPrior.lean`
(anchor by DECLARATION NAME — the historical line pointer has drifted repeatedly and must never be
trusted). An earlier plan attempted to retire it by constructing a finite readback-closed `F`; that
path is **machine-refuted** (`not_readbackClosed`, committed): no finite `F` can be closed under the
exists-forall-readback because the readback image contains formulas of unbounded `untl`-count. Report
18 surfaced the two remaining faithful architectures A/B; report 19 decided between them with
machine-checked evidence; **this plan commits to Option A: the infinite-alphabet E[Sigma] of Rabinovich
Def 4.1 (PDF p.5).**

Option A is SPINE-SAFE: `sigE`/`UnaryType`/`IntervalType` are grep-confirmed confined to
`WeakCanonical/Kamp/`, absent from `BXCanonical/` (incl. `Completeness.lean`/`completeness_discrete`)
and absent from `Decidability/` (incl. all of `Decidability/FMP/*`). The cost is large but structural,
not mathematical: (1) `MonadicSignature` structurally required `Fintype preds`/`DecidableEq preds` as
instance fields, so an infinite-alphabet signature was not constructible until that requirement was
removed (Phase 2, DONE); (2) the whole `UnaryType`/`IntervalType` model-enumeration layer is built on
`Finset.univ` over a finite alphabet and must be re-encoded onto **per-formula finite atom sets** (each
Rabinovich formula mentions finitely many atoms; Rabinovich never enumerates the whole alphabet).

**This revision fixes HOW Phase 4 performs that re-encode.** Plan v21 assumed an in-place swap; report
22 proved no green-at-every-commit order exists for it (the total `UnaryType` is a bare `M`-free type
that is also an `ExistsForallFormula` stored field type, referenced across 17 files — any in-place
arity/semantics change breaks the whole surface simultaneously). Phase 4 is re-decomposed as an
**additive-bridge migration**: introduce a parallel per-formula representation (`UnaryTypeFin`/
`IntervalTypeFin` bundling the mentioned-atom set `M`) plus a finite-alphabet `completions` bridge,
migrate the 17 consumers one file per commit behind the bridge (each old total-type lemma consumed via
the bridge while the Fin-variant lands), switch the exists-forall chain to the Fin variants, delete the
total types and the bridge, and only THEN perform the small `sigE` summand flip `{A // A in F}` ->
`Formula`. `Separation/KampTranslation.lean` is never edited — the scope addition is one NEW Kamp-layer
per-formula renderer, not a foundational re-encode.

**Definition of Done (UNCHANGED): `#print axioms completeness_discrete` no longer lists `sorryAx`**,
with the full `lake build` at EXIT 0 and no new axiom or non-permitted sorry anywhere on the proof
term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
Quot.sound]` — with `sorryAx` REMOVED (Phase 5 deletes the sole on-path `nf_nvar_exist_all_depths |
_k+2` residual, LAST, once the new path is proven green end-to-end).

### Research Integration

- **Report 22 (`reports/22_phase4a-staging-blocker-research.md`, AUTHORITATIVE for this revision, newly
  integrated)**: the Phase-4a staging-blocker root-cause analysis. Its contributions consumed here:
  - **Root cause (§1).** Plan v21's Phase 4 staged the per-formula re-encode as an IN-PLACE swap; both
    blocker findings are downstream of that single assumption. `UnaryType sig F := NormalForm (sigE sig
    F) 0 1` is a bare `M`-free type consumed in 17 Kamp files (25 uses in `LiftPair.lean`) including as
    `ExistsForallFormula.pointType`/`intervalType` stored field types — any in-place arity/semantics
    change breaks every consumer at once, independent of alphabet finiteness (so the flip-last device
    does not rescue it). The rendering path `unaryToFormula` -> `nf_depth0_char_formula`
    (`Separation/KampTranslation.lean`) folds over `Fintype.elems (sig.preds)`, which cannot exist at
    the post-flip infinite `sigE`.
  - **Paper-faithfulness verdict: FAITHFUL (§2, direct PDF read pp. 4-6).** Def 3.1's `alpha_j`/`beta_j`
    are quantifier-free one-variable formulas over Sigma (finite mentioned atoms); Prop 3.5's `A_i` is
    built per-formula from its own `alpha_i`; Def 4.1's E[Sigma] is infinite, so a TOTAL assignment was
    never the paper's object. The repo's total `UnaryType` is the encoding artifact; per-formula-`M`
    (`UnaryTypeFin sig F M`) IS the faithful transcription. No correctness statement is weakened — the
    two satisfaction notions are connected by the finite-alphabet bridge.
  - **Consumer Classification (§3).** 17 Kamp files at green HEAD, partitioned into class (a)
    type+instances+`unaryHolds`/`intervalHolds` layer, class (b) need-rendering-at-`sigE`, class (c)
    alphabet-dependent enumeration that becomes `M`-relative and SURVIVES the flip. Plus the decisive
    negative finding: `nf_depth0_char_formula` stays as-is (~40+ finite-signature consumers); the
    scope addition is one NEW renderer file, not a `Separation/` edit.
  - **Migration Order table (§4).** The ordered green-at-every-commit additive-bridge staging adopted
    verbatim as the new Phase-4 sub-phase structure below (4a-0 -> 4a-1 -> 4a-2 -> 4a-3 -> 4a-4..N ->
    4b -> 4c -> 4-flip), including the `completions` bridge definition + bridge lemma.
  - **Reviser recommendations (§5).** Choose path (A) additive-bridge; reject (B) in-place (no green
    order) and (C) user-stuck (evidence determines the path); keep the flip-last decision; the 4a-2
    micro-gate is the cheap early GO/NO-GO this task's three-strikes history demands.
- **Report 20 (`reports/20_plan19-format-faithfulness-remaining-work.md`)**: the plan-format audit +
  PDF-grounded faithfulness re-check. Consumed here: the faithfulness PASS (independent PDF read, pages
  4-6) corroborating reports 18/19/22 and mandating NO re-architecture; the machine-checked current-state
  inventory (exactly three permitted sorries); and the post-GATE Phase-4b risk refinement (§3.3 — the
  Phase-1 GATE exercised only the point-type clause of a trivial `n = 0` input; the render obligation
  and the tuple skeleton disjunction were un-de-risked). Report 22's 4a-2 micro-gate directly discharges
  that §3.3 residual risk before mass migration.
- **Report 19 (`reports/19_architecture-spike-A-vs-B.md`)**: the decisive comparative architecture
  spike. Consumed here: Option B ruled out (machine-checked NO-GO `capFn_forces_local`); Option A
  recommended and de-risked as SPINE-SAFE (grep-verified `sigE` containment); the H3 5-column
  PDF-page mapping table (Def 4.1 p.5, Def 3.1 p.4, Prop 3.5 p.5, Prop 4.2/4.3 + Thm 4.4 p.6).
- **Report 18 (`reports/18_readback-closed-finite-fl-rescope.md`)**: the NO-GO on the finite-`F`
  readback closure — the reason a fresh architecture (A) was required.
- **Committed refutations preserved as landed assets** (NOT rebuilt): `not_readbackClosed`
  (`ZetaReadbackClosure.lean`, deleted in Phase 3 as vacuous); `capFn_forces_local`
  (`OptionBLocalityProbe.lean`, preserved verbatim).
- **Reports 17/16/15/14/13/11/09/07/05/06 (carried forward)**: the B1-B4 blocker probe, the B5
  capture-bound audit, the monotone-pinning verdict, the path-(c) eval-side closure, the arity-0/1
  negation blueprint, the `hCapture`-at-`IntervalType` pin, the ConjInterleave audit, the faithful
  alpha-zeta phase structure, the conjunction-closure verdict, the Phase-4 unblock construction. Under
  Option A the beta/gamma/delta negation SHAPE and the `translateProp35` structure SURVIVE; the
  `Finset.univ` enumeration and the `IntervalType`-level capture are REWRITTEN via the additive bridge.

### Prior Plan Reference

**`plans/21_infinite-esigma-alphabet-optionA-v2.md` is the immediate predecessor of this plan; this
plan (v23) re-decomposes its blocked Phase 4** per report 22. The architecture (Option A, infinite
E[Sigma], per-formula representation) is carried forward verbatim; only the Phase-4 STAGING is
replaced (in-place swap -> additive-bridge migration) and the summand flip is relocated after 4c.
Plan 21 is left in place as history; this plan supersedes it as the working plan. Plan 21's Phase 4a
`[BLOCKED]` blockquote is the root-cause record that report 22 resolves.

The still-earlier finite-`F` restructure plan is SUPERSEDED and its Option-(a) finite readback-closed
`F` is machine-refuted (`not_readbackClosed`). **Do NOT re-attempt the finite-`F` construction.**

### Open Scope Question — RESOLVED to (b)

The task charter's OPEN SCOPE QUESTION (a: re-architect the arms while keeping `nf_eval_nf` in the
chain statements, vs b: a statement/alphabet-level migration) is **RESOLVED to (b)**. Option A is
precisely a statement/alphabet-level migration. This resolution is recorded HERE, in the plan; per
the reviser Plan-Revision workflow this plan does NOT edit the state.json task description or task
dependencies.

### Preserved / Superseded Assets (do NOT rebuild the preserved ones; do NOT re-execute the superseded ones)

Report 19's "Reuse of landed assets" verdict for Option A is **Low**: the committed
`UnaryType`/`IntervalType`/`LiftPair`/capture proofs are rewritten under the new per-formula
representation; the `canonExpand` semantic core and the `translateProp35`/negation SHAPE survive.
Report 22 refines HOW the rewrite lands (additive Fin-variants alongside the old total types, via the
`completions` bridge, deleted last).

| Landed asset | File | Disposition under the additive-bridge migration |
|---|---|---|
| `not_readbackClosed` (finite-`F` refutation) | `ZetaReadbackClosure.lean` | **DELETED in Phase 3** (already done — vacuous once `sigE` is infinite). |
| `ReadbackClosed` / `*_of_closed` conditionals | `ZetaEngineClosure.lean` | **DELETED in Phase 3** (already done — vacuous under infinite E[Sigma]). |
| `capFn_forces_local` / `intervalHolds_local` (Option-B refutation) | `OptionBLocalityProbe.lean` | **PRESERVED VERBATIM** — do NOT delete (justification for choosing A over B). Off-path; unaffected. |
| `canonExpand` semantic core + `temporal_truth_canonExpand` conservativity | `ESigmaExpansion.lean`, `ESigmaCapture.lean` | **Semantic SHAPE SURVIVES**. The `esigmaPred A hA` proof-carrying membership is REWRITTEN in Phase 4-flip (fresh atoms indexed by the full `Formula`, no `hA`). |
| `esigmaCapture_canonExpand` + `intervalCapture_of_atomNamed` | `ESigmaCapture.lean` | **SUPERSEDED**: capture sites are Phase-5 deletions (readback IS an atom under infinite E[Sigma]); NOT migrated to Fin-variants (report 22 §3). Conservativity lemma survives. |
| `ZetaAtomMapReconcile` (`Sum.inl`/`Sum.inr` collapse-unwinding) | `ZetaAtomMapReconcile.lean` | **SHAPE SURVIVES** — `sigE` keeps its sum structure (only the fresh summand's index type changes at Phase 4-flip); class (a) migration adds Fin-variants where it names types. |
| `ZetaPriorTransfer` (prior-axiom transport) | `ZetaPriorTransfer.lean` | **SURVIVES**; re-checked at Phase 5. |
| `MonadicFormulaMap` (`mapPreds` eval-naturality) | `MonadicFormulaMap.lean` | **SURVIVES**; re-checked at Phase 5. |
| `ZetaUniformExtract` (M-uniform extraction + capture threading) | `ZetaUniformExtract.lean` | **Phase-5 deletion** of the `capFn`/`hCapture` threading (NOT migrated); the N-independence structure survives. |
| beta/gamma/delta negation stack SHAPE | `EFSatNegationGeneral.lean`, `VeeSatNegation.lean`, `Prop43Translate.lean` | **SHAPE SURVIVES**; the `Finset.univ` enumeration inside is migrated to `M`-relative Fin-variants (class (a)/(c), Phases 4a-4 / 4c). |
| `translateProp35` / `charType` / `skelDisjunct` structure | `Prop35Assembly.lean`, `LiftPair.lean` | **STRUCTURE SURVIVES**; switched to the Fin renderer (`unaryToFormulaFin`) at 4a-4 (`Prop35*`) and 4b (`LiftPair`, hardest single site). |
| `Section5Correspondence` + `VecEANegFix` | `Section5Correspondence.lean`, `VecEANegFix.lean` | **SURVIVE** — structural De Morgan / attained-carrier facts, not `Finset.univ`-enumeration. Re-checked, not rebuilt. |
| `nf_depth0_char_formula` (total renderer, folds over `Fintype.elems`) | `Separation/KampTranslation.lean` | **NOT EDITED** (report 22 §3): ~40+ finite-signature consumers legitimately hold `[Fintype sig.preds]`. The exists-forall chain gets a NEW additive Fin renderer instead. |
| `UnaryTypeFin`/`partialHolds`/`charTypeFin` (Phase-1 gate rep) | `InfAlphabetProbe.lean` | **PROMOTED** to production in 4a-0 (do NOT duplicate). |

## Goals & Non-Goals

**Goals**:
- **[DONE] Phase-1 de-risking GATE**: per-formula-finite-atom `UnaryTypeFin` prototype on ONE readback,
  sorry-free, axiom-clean, off-path, no full-alphabet `Finset.univ`. Returned GO (machine-checked).
- **[DONE] Remove the finiteness type-class requirement** (`Fintype preds`/`DecidableEq preds`) from
  `MonadicSignature`; re-derive the `AtomKind`/`NormalForm` instances under explicit per-formula
  finiteness. An infinite-alphabet signature is now constructible.
- **[DONE, retained scope] Spine-safety re-confirmation + deletion of the vacuous readback-closure
  probes** (`ZetaReadbackClosure`/`ZetaEngineClosure`).
- **Perform the additive-bridge Phase-4 migration** (report 22 §4): promote the per-formula
  representation to production + build the `completions` bridge (4a-0); add the NEW per-formula renderer
  (4a-1); pass the render micro-gate (4a-2); add the per-formula exists-forall object (4a-3); migrate
  the 17 consumers one file per commit behind the bridge (4a-4..N); re-encode `LiftPair.lean` last and
  alone (4b); switch the exists-forall chain to the Fin variants and delete the total types + bridge
  (4c); then perform the small `sigE` summand flip `{A // A in F}` -> `Formula` (4-flip). Prove "type =
  finite disjunction of the atoms the formula mentions" with no total `Finset.univ`.
- **Re-wire the ζ consumers and perform the terminal spine wire** (Phase 5): discharge capture DIRECTLY
  (the readback is an atom of the infinite expansion), removing `hCapture`/`capFn`; construct the ζ
  `canonExpand`; re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery`; verify green with the `nf_nvar_exist_all_depths | _k+2` residual
  STILL PRESENT, then **delete it LAST**; confirm `#print axioms completeness_discrete` no longer lists
  `sorryAx`.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor headers
  only; Rabinovich cited by PDF page, never line number).

**Non-Goals**:
- Introducing any novel mathematics or Feferman-Vaught composition. Per-formula-M IS Rabinovich Def
  3.1/Prop 3.5 (report 22 §2); the total types were the encoding artifact. No invented content.
- **Editing `Separation/KampTranslation.lean` / `nf_depth0_char_formula`** (report 22 §3): it keeps its
  ~40 finite-signature consumers. The exists-forall chain uses a NEW additive Fin renderer.
- Re-attempting the in-place Phase-4 swap (refuted — no green order, report 22 §1), the finite-`F`
  readback closure (machine-refuted `not_readbackClosed`), or Option B's semantic capture (machine-refuted
  `capFn_forces_local`).
- Migrating `ESigmaCapture` capture sites or `ZetaUniformExtract` to Fin-variants — these are Phase-5
  DELETIONS (report 22 §3), not migrations.
- Any arity-4 realization engine, joint-type-over-a-tuple, or `chain_split` (NON-APPLICABLE).
- Touching `EANegation.lean:1090` / `:1249` (three-strikes UNFIXABLE, zero external consumers) or
  rebuilding `Kamp/NfEFold.lean`; no `nf_eval_efold` / `nf_eval_nfk_iff_efold`.
- Any change to `BXCanonical/` or `Decidability/` beyond the single spine re-point + the in-file
  audit-block correction in Phase 5.
- Any `sorry` outside the amended sorry gate below, any `def X := True`, or vacuous placeholder.

## Binding Constraints (carry into EVERY phase)

- **FAITHFULNESS TO RABINOVICH IS ESSENTIAL. NO NOVEL MATHEMATICS, NO FEFERMAN-VAUGHT.** Every
  construction traces to Rabinovich Def 4.1 (infinite E[Sigma]) / Def 3.1 / Prop 3.5 / Prop 4.2-4.3 /
  Thm 4.4, or a report-19/20/22 finding. Per-formula-M is Def 3.1's quantifier-free one-variable
  formula, not invented (report 22 §2, direct PDF read pp. 4-6).
- **Cite Rabinovich BY PDF PAGE ONLY**:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`. The
  companion `.md` is CORRUPT and must NOT be used.
- **Anchor code by DECLARATION NAME, never line number. NO TASK-NUMBER POINTERS in `Theories/**/*.lean`**
  (durable anchors only).
- **The k>=2 blocker is anchored by declaration name `nf_nvar_exist_all_depths` (the `| _k + 2` arm),
  NEVER by line.** Every historical line pointer to it has rotted repeatedly.
- **`Separation/KampTranslation.lean` is OUT OF SCOPE — do NOT edit `nf_depth0_char_formula`** (report
  22 §3). The exists-forall chain's per-formula rendering is a NEW additive file (`unaryToFormulaFin`).
- **`chain_split` is NON-APPLICABLE.** Do NOT touch `EANegation.lean:1090` / `:1249`. Do NOT rebuild
  `Kamp/NfEFold.lean`.
- **AMENDED SORRY GATE.** The only permitted live sorries anywhere in the build are:
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 5), `EANegation.lean:1090`, and
  `EANegation.lean:1249`. No phase may introduce any other sorry or any new axiom. (Report 20
  machine-verified exactly these three are live.)
- **DO NOT DELETE `nf_nvar_exist_all_depths | _k+2` until the new path is proven green end-to-end.**
  Its deletion is the LAST action of Phase 5.
- **ADDITIVE-BRIDGE DISCIPLINE (report 22 §4).** Every Phase-4 sub-phase is purely additive or a bridge
  consumption, EXCEPT 4c (deletions of now-unconsumed decls) and 4-flip (the summand change). The
  finite-alphabet `completions` bridge exists precisely WHILE `sigE` is finite (the flip-last payoff);
  every old total-type lemma is consumed through it while the Fin-variant lands, then the total types
  and the bridge are deleted at 4c, and only THEN does 4-flip make `sigE` infinite.
- **NO FULL-ALPHABET `Finset.univ`.** The Fin-variants route ALL point/interval/tuple finiteness through
  the per-formula mentioned-atom set `M` (`Finset.univ : Finset (UnaryTypeFin ... M)` and `Finset.univ :
  Finset (Fin (m+1) -> UnaryTypeFin ... M)` are finite FROM `M` alone and survive the flip). Because the
  migration lands while the alphabet is still finite, `Finset.univ : Finset (UnaryType ...)` still
  COMPILES; any residual alphabet-wide `Finset.univ` will surface as RED at 4-flip. Grep-guard for
  `Finset.univ` typed at `UnaryType`/`AtomKind (sigE ...)` before 4-flip.
- **INCREMENTAL-WITH-FALLBACK.** Phases 4a-0 through 4-flip land off the live import path and green (full
  `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline) at EVERY commit
  BEFORE Phase 5 touches the spine. Phase 5 proves the new path green with the old residual still present,
  then deletes it LAST.
- **PHASE SIZING (H8).** Each phase/sub-phase is bounded to ~one agent run (~100-500 lines net). The
  4a-4..N consumer migration is one commit PER FILE (the bridge decouples them). `LiftPair.lean` (4b) is
  its own bounded run and may split by direction.
- **MICRO-GATE (4a-2) IS A HARD GO/NO-GO.** If the render step cannot be proven correct on the nontrivial
  `n = 1` input WITHOUT a full-alphabet `Finset.univ` or a weakened correctness statement, STOP and
  surface for `/research`. Do NOT proceed to mass consumer migration on a red render obligation.
- **Point types stay complete; interval types remain partial** (a finite set of the point types the
  formula mentions). The per-formula-finite-atom discipline replaces `Finset.univ` over the whole
  alphabet, NOT the point/interval distinction.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **The render obligation (`unaryToFormulaFin_correct` / `translateProp35Fin` under partial satisfaction) fails on a nontrivial input** — the exact gap the Phase-1 GATE missed (report 20 §3.3), now the top open representation risk | H | M | The 4a-2 micro-gate exercises precisely this on a nontrivial `n = 1` input BEFORE any consumer migration. It is a HARD GO/NO-GO: a red render obligation is a return-to-`/research`, NOT a hole to force. `unaryToFormulaFin` folds over `M.toList` mirroring `nf_depth0_char_formula_correct` bounded to `M` (report 22 §4 row 4a-1). |
| **`LiftPair.lean` tuple skeleton disjunction (`skelR`/`skelDisjunct`) cannot be expressed on per-formula finite atoms without a full-alphabet `Finset.univ`** (report 20 §3.3 residual) | H | M | Report 22 §4 (row 4b): `skelRFin := Finset.univ : Finset (Fin (m+1) -> UnaryTypeFin M)` is finite FROM `M` alone (class (c)), so the skeleton disjunction survives the flip. `LiftPair.lean` is 4b, last and alone, after the render obligation is already GO (4a-2). Fwd/bwd split is a first-class fallback. If it genuinely needs the full alphabet, that is a return-to-gate. |
| **Additive migration doubles surface area** (Fin-variants alongside total types) and the bridge lemmas are load-bearing across every consumer | M | M | The bridge (`completions c := Finset.univ.filter (fun tau => forall a in M, tau a = c a)` with `intervalHolds N (completions c) y <-> partialHolds N c y`) is built and proven ONCE in 4a-0. Each consumer's Fin-variant is proved via the bridge; the old total lemma stays untouched until 4c deletes it. Green at every commit; a failed file leaves last-green intact and resumable. |
| **Consumer migration order wrong → a file's Fin-variant needs a not-yet-migrated dependency** | M | L-M | Migrate strictly in import order (report 22 §4 row 4a-4..N): `IntervalType` algebra -> `ExistsForallLemmas` -> `ConjInterleave` -> `Prop35*` (switch to Fin renderer) -> `Prop42ExistsForall` -> `EFSatNegationGeneral`/`VeeSatNegation`/`VVecEA2Collapse` -> `Prop43Translate`. `LiftPair` (4b) last. The bridge decouples them so there is no cross-file coupling within a wave. |
| **4-flip (summand `{A // A in F}` -> `Formula`) surfaces a residual full-alphabet `Finset.univ` as RED** | M | L | Grep-guard for `Finset.univ` typed at `UnaryType`/`AtomKind (sigE ...)` before 4-flip; by 4c all exists-forall-chain finiteness is `M`-relative, so the flip only deletes `sigE_fintypePreds` and drops `hA` from `esigmaPred`. Decidability survives (`Formula` has `DecidableEq`); only `Fintype`-finiteness is lost. |
| **Phase 5 spine re-point** regresses the spine or fails to remove `sorryAx` | H | M | Incremental-with-fallback: prove the new path green with the residual STILL PRESENT; delete `nf_nvar_exist_all_depths | _k+2` LAST and verify immediately with `#print axioms`. `sigE` never reaches the spine, so the only spine edit is the single re-point of the three consumers + the in-file audit-block correction. |
| **Spine-safety assumption is wrong** (`sigE` secretly reaches `BXCanonical/`/`Decidability/`) | H | L | Report 19/22 grep-verified absent from both trees; Phase 3 re-confirmed EMPTY. Re-run the grep before 4-flip as a cheap re-confirmation. |
| **Off-paper mathematics or a task-number/line-number citation slips into a `Theories/` file** | H | L | Per-phase faithfulness anchor to a named report-19/20/22 finding or a Rabinovich PDF page; durable-anchor headers only. |

## Implementation Phases

**Dependency Analysis** (fully sequential critical path; Phases 1-3 landed; Phase 4 re-decomposed into
the additive-bridge migration; each sub-phase is green-committable):

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 (de-risking GATE — DONE/GO) | -- |
| 2 | 2 (`Fintype preds` removal — DONE) | 1 |
| 3 | 3 (spine-safety re-confirm + retire vacuous probes — DONE; summand flip relocated to 4-flip) | 2 |
| 4 | 4a-0 (promote per-formula rep + `completions` bridge) | 3 |
| 5 | 4a-1 (NEW per-formula renderer `unaryToFormulaFin`) | 4a-0 |
| 6 | 4a-2 (render MICRO-GATE — GO/NO-GO) | 4a-1 |
| 7 | 4a-3 (`ExistsForallFormulaFin` per-formula exists-forall object) | 4a-2 |
| 8 | 4a-4 (consumer migration in import order, one file per commit) | 4a-3 |
| 9 | 4b (`LiftPair.lean` re-encode — hardest, last and alone) | 4a-4 |
| 10 | 4c (switchover: repoint exists-forall chain at Fin variants; delete total types + bridge) | 4b |
| 11 | 4-flip (terminal `sigE` summand flip `{A // A in F}` -> `Formula`) | 4c |
| 12 | 5 (ζ re-wire + terminal spine wire; retire residual LAST) | 4-flip |

Fully sequential. **The gate (Phase 1) is GREEN, Phases 2-3 landed, so Phase 4 (as re-decomposed) and
Phase 5 are authorized.** Phase 5 is the ONLY live-path phase; through 4-flip the spine and `#print
axioms completeness_discrete` are UNCHANGED (the `nf_nvar_exist_all_depths | _k+2` `sorryAx` remains the
sole on-path sorry until Phase 5 deletes it LAST).

> **Sub-phase heading convention:** Phase 4 is a parent phase; its sub-phases 4a-0/4a-1/4a-2/4a-3/4a-4/
> 4b/4c/4-flip use `####` headings to denote bounded sub-runs. Top-level phases use `###`.

---

### Phase 1: De-risking GATE — per-formula-finite-atom `UnaryType` prototype on ONE readback, off-path, sorry-free-or-escalate [COMPLETED]

- Completed: 2026-07-19T11:58:03-07:00

**GATE VERDICT: GO** (machine-checked, commit `fbe26f61c`). Prototype `Kamp/InfAlphabetProbe.lean`
proves the Prop-3.5 "type = finite disjunction of atoms" equivalence (`typeEqFiniteDisjunction`) and
its concrete instantiation on a genuine `translateProp35` input (`gate_translateProp35`, over
`xiConcrete`), sorry-free, with the enumeration ranging ONLY over completions of the mentioned atoms
(`Finset.univ : Finset (UnaryTypeFin sig F M)` where `UnaryTypeFin sig F M = {a // a in M} -> Bool`)
— NO full-alphabet `Finset.univ : Finset (UnaryType)`. `#print axioms gate_translateProp35` =
`[propext, Classical.choice, Quot.sound]` (subset of permitted). Off-path; full `lake build` EXIT 0;
`#print axioms completeness_discrete` byte-identical to baseline. Phases 2-5 authorized.

**Post-GATE scope caveat (report 20 §3.3, resolved by 4a-2):** the probe exercised the representation
only on the **point-type clause** of a **trivial** `xiConcrete` (`n = 0`, interval clauses `= empty`).
It did NOT exercise the render step, non-empty interval clauses, the tuple skeleton disjunction, or the
`liftPair_*` equivalence. Report 22's 4a-2 render micro-gate discharges the render obligation on a
nontrivial `n = 1` input BEFORE mass migration; 4b carries the tuple-skeleton residual.

- **Goal:** Decide go/no-go on Option A before committing to the refactor. (Done.)
- **Faithfulness anchor:** Rabinovich Prop 3.5 (PDF p.5) + Def 3.1 (p.4) + the observation that each
  formula mentions finitely many atoms.
- **Tasks:**
  - [x] New off-path module `InfAlphabetProbe.lean` defining `UnaryTypeFin` as a partial assignment.
  - [x] `intervalHolds`-analog `partialIntervalHolds` over `Finset (UnaryTypeFin sig F M)`.
  - [x] Prop-3.5 equivalence for ONE concrete `translateProp35 xi`, sorry-free, no full-alphabet `Finset.univ`.
  - [x] Record GO / NO-GO verdict. (GO.)
- **Definition of Done (BINARY GATE):** achieved — GO.
- **Timing:** 4-8 hours (~150-350 lines). DONE.
- **Depends on:** none.
- **Files modified:** `Kamp/InfAlphabetProbe.lean` (off-path gate).

---

### Phase 2: Foundational type-class change — remove `[fintypePreds]`/`[decEqPreds]` from `MonadicSignature`; re-derive `AtomKind`/`NormalForm` instances [COMPLETED]

- Started: 2026-07-23T18:08:00Z
- Completed: 2026-07-23T22:30:00Z (full `lake build` EXIT 0; instance-threading cascade fully ground out)

> **COMPLETED (Phase 2) — full green reached.** The `[Fintype sig.preds] [DecidableEq sig.preds]` fields
> were removed from `MonadicSignature`; the cascade was threaded after each failing abstract-`sig` decl
> binder across ~45 files and ~30 build waves. Three genuine non-binder repairs: (1) explicit bridge
> instances `muSig_fintypePreds`/`muSig_decEqPreds` (`EFGames/TypeFormulas.lean`); (2) explicit
> `Fintype`/`DecidableEq` for the concrete `sigCex` (`NfMultiAnchorBridge/Base.lean`); (3) removal of the
> `fintypePreds := inferInstance`/`decEqPreds := inferInstance` field assignments in `mkSigFrom`
> (`Transfer.lean`) plus explicit bridge instances for `(mkSigFrom phi).preds`. **Verification:** full
> `lake build` EXIT 0; git diff added/removed ZERO `sorry` lines; `#print axioms completeness_discrete`
> byte-identical to baseline; an infinite-alphabet signature (`preds := Formula`, with `Infinite`
> instance) is now constructible. **Key design finding (carries forward):** decidability is PRESERVED
> along the infinite E[Sigma] path (`Formula` has `DecidableEq`); only `Fintype`-finiteness is truly
> lost, so `[DecidableEq sig.preds]` threading survives and `[Fintype sig.preds]` vanishes at 4-flip.

- **Goal:** Make an infinite-alphabet signature constructible. (Done.)
- **Faithfulness anchor:** report 19 A2 + Def 4.1 (p.5, E[Sigma] infinite). Report 20 §2.2: FAITHFUL.
- **Tasks:**
  - [x] Remove `[fintypePreds]`/`[decEqPreds]` from `MonadicSignature` (`MonadicFO.lean`).
  - [x] Re-derive `AtomKind sig n` `Fintype`/`DecidableEq` (`NormalForm.lean`) via explicit hypotheses.
  - [x] Re-derive `NormalForm sig k n` `Fintype`/`DecidableEq` + card lemmas under the explicit discipline.
  - [x] Fix breakage (deviation: cascade spanned ~45 files, not two; three genuine non-binder repairs).
- **Definition of Done:** achieved — full `lake build` EXIT 0; `#print axioms` byte-identical; infinite
  signature constructible.
- **Timing:** 8-14 hours. DONE (~1-2 agent runs, multi-wave).
- **Depends on:** 1.
- **Files modified:** `MonadicFO.lean`, `NormalForm.lean`, + ~43 downstream instance-threading files.

---

### Phase 3: Spine-safety re-confirmation + retire the now-vacuous readback-closure probes (summand flip RELOCATED to Phase 4-flip) [COMPLETED]

- Completed: 2026-07-23 (retained scope landed; grep EMPTY, probes deleted)

> **SEQUENCING DECISION (flip-last) — PRESERVED VERBATIM, still load-bearing.** `UnaryType sig F :=
> NormalForm (sigE sig F) 0 1`, whose `Fintype`/`DecidableEq` derive ENTIRELY from `Fintype (sigE sig
> F).preds` (the finite alphabet). Flipping the fresh summand `{A // A in F}` -> `Formula` deletes that
> `Fintype` and breaks the ENTIRE `UnaryType`/`IntervalType` surface AT ONCE. So the summand flip is the
> LAST step: perform the per-formula re-encode FIRST while `sigE` is STILL FINITE — the per-formula
> rep's `Fintype` comes from `M : Finset (AtomKind ...)` (each formula mentions finitely many atoms),
> NOT from the alphabet, so it builds green against the finite alphabet and full `lake build` stays EXIT
> 0 at each commit — THEN flip the summand (delete `sigE_fintypePreds`, drop `hA` from `esigmaPred`) as
> the small terminal green step. Decidability survives the flip (`Formula` has `DecidableEq`); only
> `Fintype`-finiteness is lost. Faithfulness is unchanged — the end-state is exactly Def 4.1 infinite
> E[Sigma] + per-formula rep; only the LANDING ORDER differs.
>
> **Why flip-last still holds under the additive-bridge migration (report 22 §4 rec 4):** the flip-last
> premise failed only for the plan-v21 IN-PLACE 4a (an arity/semantics change to the total `UnaryType`
> breaks all 17 consumers at once, independent of finiteness). It does NOT fail for the ADDITIVE path:
> the finite-alphabet `completions` bridge (`completions c : Finset (UnaryType sig F) :=
> Finset.univ.filter (fun tau => forall a in M, tau a = c a)`) exists precisely WHILE `sigE` is finite,
> and is exactly what lets every old total-type lemma be consumed while the Fin-variants land. Keep the
> flip-last decision — it is what makes the bridge available during the whole migration. The summand
> flip is Phase 4-flip, AFTER 4c deletes the total types and the bridge.
>
> **Guardrail (carry into Phase 4):** because the re-encode is done while the alphabet is still finite,
> `Finset.univ : Finset (UnaryType ...)` still COMPILES; route ALL point/interval/tuple finiteness
> through per-formula `M`, NEVER a total `Finset.univ` over `UnaryType`. Grep-guard for `Finset.univ`
> typed at `UnaryType`/`AtomKind (sigE ...)` before 4-flip.

- **Goal (retained scope):** Re-confirm spine-safety and delete the vacuous readback-closure probes. The
  summand flip that plan v21 placed in Phase 3 is RELOCATED to Phase 4-flip (after 4c), per report 22 §4.
- **Faithfulness anchor:** Rabinovich Def 4.1 (PDF p.5) + the p.6 collapse note. Report 20 §2.2: FAITHFUL.
- **Tasks:**
  - [x] Re-confirm spine-safety: `grep -rln 'sigE\|UnaryType\|IntervalType'` over `BXCanonical/` and
        `Decidability/`. *(completed — returned EMPTY over both trees.)*
  - [x] Delete `ZetaReadbackClosure.lean` (`not_readbackClosed`) and `ZetaEngineClosure.lean`
        (`ReadbackClosed`/`*_of_closed`) — vacuous; PRESERVE `OptionBLocalityProbe.lean`. *(completed —
        both a leaf cluster imported by NOBODY; `git rm` provably non-breaking.)*
  - [RELOCATED] The `sigE` summand flip `{A // A in F}` -> `Formula` and the `esigmaPred`/`canonExpand`/
        `ESigmaCapture` `hA`-removal move to **Phase 4-flip** (after 4c), per report 22 §4. They are NOT
        part of Phase 3's landed scope.
- **Definition of Done:** grep EMPTY (spine-safety re-confirmed); the two closure probes deleted;
  `OptionBLocalityProbe.lean` preserved; full `lake build` EXIT 0; `#print axioms` byte-identical.
  Achieved.
- **Timing:** 2-4 hours (retained scope). DONE.
- **Depends on:** 2.
- **Files modified:** DELETED `ZetaReadbackClosure.lean`, `ZetaEngineClosure.lean`.
- **Prohibited:** do NOT delete `OptionBLocalityProbe.lean`; no spine edit.

---

### Phase 4: Additive-bridge migration of the enumeration + rendering surface onto per-formula finite atom sets (4a-0 -> 4a-1 -> 4a-2 -> 4a-3 -> 4a-4..N -> 4b -> 4c -> 4-flip) [NOT STARTED]

**Framing (report 22 §1, §4):** the core of Option A's cost — re-encoding "type = finite disjunction
over ALL 1-types (`Finset.univ`)" onto the per-formula-finite-atom representation — staged as an
ADDITIVE PARALLEL migration rather than an in-place swap. Introduce the per-formula representation
(`UnaryTypeFin`/`IntervalTypeFin` bundling the mentioned-atom set `M`) plus a finite-alphabet
`completions` bridge; add a NEW per-formula renderer (`Separation/KampTranslation.lean` untouched);
migrate the 17 consumers one file per commit behind the bridge; switch the exists-forall chain to the
Fin variants; delete the total types and the bridge; then flip the `sigE` summand. Green at every commit.

**Faithfulness anchor (whole phase):** Rabinovich Prop 3.5 (PDF p.5) + Def 3.1 (p.4, quantifier-free
one-variable `alpha_j`/`beta_j`) + report 22 §2's verdict that per-formula-`M` IS Def 3.1's object (the
total `UnaryType` was a finite-alphabet encoding artifact). Validated end-to-end by the 4a-2 render
micro-gate before mass migration.

**The bridge (report 22 §4, finite-alphabet only, deleted at 4c):** for `c : UnaryTypeFin sig F M`,
`completions c : Finset (UnaryType sig F) := Finset.univ.filter (fun tau => forall a in M, tau a = c a)`
with lemma `intervalHolds N (completions c) y <-> partialHolds N c y`. It exists precisely while `sigE`
is finite (the flip-last payoff) and is what lets every old total-type lemma be consumed while the
Fin-variants land.

#### Phase 4a-0: Promote the per-formula representation to production + build the `completions` bridge [NOT STARTED]

- **Goal:** Promote `UnaryTypeFin`/`partialHolds`/`charTypeFin` from `InfAlphabetProbe.lean` (the Phase-1
  gate — promote, do NOT duplicate) to a production file. Add `IntervalTypeFin M := Finset (UnaryTypeFin
  M)`, `intervalHoldsFin`, the restriction/weakening maps, and the finite-alphabet `completions` bridge
  + bridge lemma (`intervalHolds N (completions c) y <-> partialHolds N c y`). Purely additive.
- **Faithfulness anchor:** report 22 §4 row 4a-0; Def 3.1 (p.4).
- **Tasks:**
  - [ ] New file `Kamp/PerFormulaType.lean`: promote `UnaryTypeFin`/`partialHolds`/`charTypeFin`.
  - [ ] Define `IntervalTypeFin M := Finset (UnaryTypeFin M)`, `intervalHoldsFin`, restriction/weakening maps.
  - [ ] Define `completions c := Finset.univ.filter (fun tau => forall a in M, tau a = c a)` and prove
        the bridge lemma `intervalHolds N (completions c) y <-> partialHolds N c y`.
- **Definition of Done:** `PerFormulaType.lean` builds green, sorry-free, axiom-clean; off-path; `lake
  build` EXIT 0; axioms unchanged.
- **Timing:** 4-8 hours (~150-350 lines). ~1 agent run.
- **Depends on:** 3.
- **Files to modify:** new `Kamp/PerFormulaType.lean` (imports `InfAlphabetProbe.lean` or absorbs it).
- **Prohibited:** no `sorry`; no full-alphabet `Finset.univ` in the Fin definitions; no spine edit.

#### Phase 4a-1: NEW per-formula renderer `unaryToFormulaFin` (Separation/ untouched) [NOT STARTED]

- **Goal:** Add a per-formula renderer `unaryToFormulaFin (c : UnaryTypeFin M) : Formula` folding over
  `M.toList` (proof mirrors `nf_depth0_char_formula_correct` but bounded to `M`) + `unaryToFormulaFin_correct`
  proving it renders `<-> partialHolds`. Purely additive; `Separation/KampTranslation.lean` is NEVER
  edited (report 22 §3 — `nf_depth0_char_formula` keeps its ~40 finite-signature consumers).
- **Faithfulness anchor:** report 22 §4 row 4a-1; Prop 3.5 (p.5) `A_i` built from `alpha_i`'s finite syntax.
- **Tasks:**
  - [ ] New file `Kamp/PerFormulaRender.lean`: `unaryToFormulaFin` folding over `M.toList`.
  - [ ] `unaryToFormulaFin_correct` (`<-> partialHolds`), mirroring `nf_depth0_char_formula_correct`
        bounded to `M`.
- **Definition of Done:** `PerFormulaRender.lean` builds green, sorry-free, axiom-clean; off-path;
  `Separation/KampTranslation.lean` unchanged (git diff empty); `lake build` EXIT 0; axioms unchanged.
- **Timing:** 4-8 hours (~150-350 lines). ~1 agent run.
- **Depends on:** 4a-0.
- **Files to modify:** new `Kamp/PerFormulaRender.lean`.
- **Prohibited:** no edit to `Separation/KampTranslation.lean`; no `sorry`; no full-alphabet `Finset.univ`.

#### Phase 4a-2: Render MICRO-GATE — `translateProp35Fin` end-to-end on a nontrivial `n = 1` input [NOT STARTED]

> **HARD GO/NO-GO (report 22 §5, discharges report 20 §3.3's residual 4b risk).** This gate exercises the
> exact render-correctness obligation the Phase-1 gate MISSED — the render step and `translateProp35_correct`
> under partial satisfaction — on a NONTRIVIAL input, BEFORE any consumer migration begins. **STOP
> CONDITION:** if `translateProp35Fin` cannot be proven correct end-to-end through
> `unaryToFormulaFin_correct` on the nontrivial `n = 1` input WITHOUT re-introducing a full-alphabet
> `Finset.univ` or weakening a correctness statement, the gate is NO-GO: STOP and surface for `/research`.
> Do NOT proceed to 4a-3 / mass consumer migration on a red render obligation. Do NOT force with a global
> `Finset.univ` or a weakened `translateProp35_correct`.

- **Goal:** Extend the Phase-1 gate to the RENDER step. Define `translateProp35Fin` on a nontrivial `n =
  1` input (non-empty interval clauses) and prove it correct end-to-end through `unaryToFormulaFin_correct`,
  sorry-free, off-path, WITHOUT a full-alphabet `Finset.univ`. Record an explicit GO / NO-GO verdict.
- **Faithfulness anchor:** report 22 §4 row 4a-2 + §5; Prop 3.5 (p.5); Def 3.1 (p.4).
- **Tasks:**
  - [ ] Define `translateProp35Fin` on a nontrivial `n = 1` input (in the gate/probe file).
  - [ ] Prove it correct end-to-end through `unaryToFormulaFin_correct`, sorry-free, no full-alphabet
        `Finset.univ`.
  - [ ] Record explicit GO / NO-GO (with `#print axioms` on the gate lemma, subset of permitted).
- **Definition of Done (BINARY GATE):** the render obligation builds sorry-free and axiom-clean, off-path,
  `lake build` EXIT 0, `#print axioms completeness_discrete` byte-identical to baseline. **GO** iff it
  closes WITHOUT a full-alphabet `Finset.univ` and WITHOUT weakening a correctness statement. **NO-GO**
  = STOP, surface for `/research` (do NOT proceed).
- **Timing:** 4-8 hours (~150-350 lines). ~1 agent run. **GATES 4a-3 through 5.**
- **Depends on:** 4a-1.
- **Files to modify:** the gate/probe file (additive probe; may extend `InfAlphabetProbe.lean` or a new
  `PerFormulaRenderProbe.lean`).
- **Prohibited:** no `sorry`; no full-alphabet `Finset.univ`; no weakened correctness statement; do NOT
  proceed past a NO-GO.

#### Phase 4a-3: Per-formula exists-forall object `ExistsForallFormulaFin` + bridge to `efSat` [NOT STARTED]

- **Goal:** Define the per-formula exists-forall object `ExistsForallFormulaFin` bundling `M` +
  `pointType : Fin (n+1) -> UnaryTypeFin M` + `intervalType : Fin (n+2) -> IntervalTypeFin M`, its
  `efSatFin`, and the bridge to the total `efSat` via `completions`. This IS Def 3.1 (the exists-forall
  formula psi is a finite formula; `M` = its mentioned atoms). Additive + bridge.
- **Faithfulness anchor:** report 22 §4 row 4a-3; Def 3.1 (p.4) verbatim (M-bundled exists-forall object).
- **Tasks:**
  - [ ] Define `ExistsForallFormulaFin` (bundles `M`, `pointType`, `intervalType`).
  - [ ] Define `efSatFin`.
  - [ ] Prove the bridge `efSatFin <-> efSat (via completions)` on the finite alphabet.
- **Definition of Done:** builds green, sorry-free, axiom-clean; off-path; `lake build` EXIT 0; axioms
  unchanged.
- **Timing:** 6-10 hours (~200-400 lines). ~1 agent run.
- **Depends on:** 4a-2 (GO).
- **Files to modify:** `Kamp/PerFormulaType.lean` (or new adjacent file).
- **Prohibited:** no `sorry`; no full-alphabet `Finset.univ`; no spine edit.

#### Phase 4a-4..N: Migrate class (a)/(b) consumers in import order, one file per commit [NOT STARTED]

- **Goal:** Migrate the class (a)/(b) consumers (report 22 §3) to the Fin variants, in strict import
  order, ONE FILE PER COMMIT, each Fin-variant proved via the `completions` bridge with the old total-type
  lemmas left untouched (deleted only at 4c). Order (report 22 §4 row 4a-4..N): `IntervalType` algebra
  (`intervalTopFin` over `M`) -> `ExistsForallLemmas` -> `ConjInterleave` -> `Prop35ExistsForall`/
  `Prop35Assembly`/`Prop35Chain` (switch to the Fin renderer `unaryToFormulaFin`) -> `Prop42ExistsForall`
  -> `EFSatNegationGeneral`/`VeeSatNegation`/`VVecEA2Collapse` -> `Prop43Translate` (`M`-relative filter).
  Each file is its own green commit; the bridge decouples them (no cross-file coupling).
- **Faithfulness anchor:** report 22 §3 (class a/b) + §4 row 4a-4..N; Prop 3.5 (p.5); Prop 4.2/4.3 (p.6).
- **Tasks (one green commit each, in order):**
  - [ ] `IntervalType.lean`: add `intervalTopFin` and the `M`-relative algebra Fin-variants
        (`ofComplete`/`intervalConj`/monotonicity) via the bridge.
  - [ ] `ExistsForallLemmas.lean`: Fin-variants of the `efSat` lemma layer.
  - [ ] `ConjInterleave.lean`: `conjInterleaveFin` / `veeConjFin` via the bridge.
  - [ ] `Prop35ExistsForall.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean`: switch the exists-forall
        chain to the Fin renderer `unaryToFormulaFin`; `translateProp35Fin`/`translateProp35Fin_correct`.
  - [ ] `Prop42ExistsForall.lean`: Fin-variant.
  - [ ] `EFSatNegationGeneral.lean` / `VeeSatNegation.lean` / `VVecEA2Collapse.lean`: Fin-variants of the
        beta/gamma negation stack (SHAPE survives; enumeration becomes `M`-relative).
  - [ ] `Prop43Translate.lean`: `M`-relative delta-translate filter Fin-variant (preserve the report-15
        `StrictMono psi.pin` conclusion-strengthening).
- **Definition of Done:** each file builds green, sorry-free, axiom-clean, off-path, at its own commit;
  old total-type lemmas untouched; `lake build` EXIT 0; axioms unchanged at every commit.
- **Timing:** 20-40 hours across the file series (~one agent run per 1-3 files). This is the bulk of the
  migration.
- **Depends on:** 4a-3.
- **Files to modify:** the class (a)/(b) files listed above (Fin-variants added alongside old lemmas).
- **Prohibited:** no `sorry`; no full-alphabet `Finset.univ`; do NOT delete any total-type lemma yet
  (deletions are 4c); do NOT edit `Separation/KampTranslation.lean`; no spine edit.

#### Phase 4b: `LiftPair.lean` — re-encode `charType`/`skelDisjunct`/`liftPair_forward/backward` (HARDEST SITE, last and alone) [NOT STARTED]

> **POST-GATE RISK (report 20 §3.3, now bounded by the 4a-2 GO).** `LiftPair.lean` (25 uses) carries the
> tuple skeleton disjunction `Finset.univ : Finset (Fin (K+1) -> UnaryType)` that `charType`/`skelDisjunct`
> use, plus `liftPair_forward`/`liftPair_backward`. Report 22 §4 (row 4b): `skelRFin := Finset.univ :
> Finset (Fin (m+1) -> UnaryTypeFin M)` is finite FROM `M` alone (class (c)), so the skeleton disjunction
> survives the flip. Because 4a-2 already proved the render obligation GO, the residual risk here is the
> tuple-skeleton re-encode specifically. **If the tuple skeleton disjunction genuinely needs a
> full-alphabet `Finset.univ`, that is a return-to-gate: STOP and surface for `/research`. Do NOT force
> with a global `Finset.univ` or weaken a correctness statement.** The fwd/bwd split is a FIRST-CLASS
> fallback.

- **Goal:** The single hardest obligation (report 19 A3). Add Fin-variants of `charType`/`skelDisjunct`/
  `skelR`/`skelR_sat`/`liftPair_forward`/`liftPair_backward` on the per-formula representation
  (`skelRFin := Finset.univ : Finset (Fin (m+1) -> UnaryTypeFin M)`), proved via the bridge, WITHOUT a
  total `Finset.univ`. Last and alone (after all 4a-4 consumers).
- **Faithfulness anchor:** report 22 §4 row 4b; report 19 A3; Prop 3.5 (p.5).
- **Tasks:**
  - [ ] Fin-variants of `charType`/`unaryHolds_charType`/`exists_unaryHolds` on per-formula atoms.
  - [ ] `skelRFin`/`skelDisjunctFin`/`skelR_satFin` (tuple skeleton disjunction) via the bridge, no total
        `Finset.univ`.
  - [ ] Fin-variants of `liftPair_forward` and `liftPair_backward` (+ `liftPairV`/`liftSentence` wrappers
        and their `_iff` lemmas).
- **Split contingency (H8, FIRST-CLASS fallback):** if this overflows one run, split by direction
  (4b-fwd `liftPair_forward` / 4b-bwd `liftPair_backward`); each lands green off-path.
- **Definition of Done:** `LiftPair.lean` builds green (Fin-variants alongside old), sorry-free,
  axiom-clean; off-path; `lake build` EXIT 0; axioms unchanged.
- **Timing:** 12-24 hours (~400-800 lines; heaviest re-encode). ~1-2 agent runs.
- **Depends on:** 4a-4.
- **Files to modify:** `Kamp/LiftPair.lean`.
- **Prohibited:** no `sorry`; no full-alphabet `Finset.univ`; do NOT weaken a correctness statement; do
  NOT delete total-type lemmas yet; no spine edit.

#### Phase 4c: Switchover — repoint the exists-forall chain at the Fin variants; delete the total-type lemmas + the bridge [NOT STARTED]

- **Goal:** Repoint the `KampPrior` consumer chain (`nf_characterizable_temporal_prior` ->
  `nf_nvar_exist_all_depths` k+2 arm) at the Fin variants; then delete the now-unconsumed total-type
  lemmas at `sigE` AND the `completions` bridge (both are dead once the chain uses the Fin variants). This
  is the deletion step of the additive migration.
- **Faithfulness anchor:** report 22 §4 row 4c.
- **Tasks:**
  - [ ] Repoint the `KampPrior` exists-forall consumer chain at the Fin variants (`ExistsForallFormulaFin`/
        `efSatFin`/`translateProp35Fin`/`liftPair*Fin`).
  - [ ] Verify the total-type lemmas at `sigE` are now unconsumed (grep/import audit).
  - [ ] Delete the unconsumed total-type lemmas and the `completions` bridge.
- **Definition of Done:** the exists-forall chain builds green on the Fin variants; the total-type lemmas
  and the bridge are deleted; off-path; `lake build` EXIT 0; `#print axioms completeness_discrete`
  byte-identical to baseline (the `_k+2` residual still carries the spine).
- **Timing:** 8-14 hours (~200-450 lines net, incl. deletions). ~1-2 agent runs.
- **Depends on:** 4b.
- **Files to modify:** the `KampPrior` exists-forall chain files; the class (a)/(b)/(c) files (delete the
  total-type decls); `Kamp/PerFormulaType.lean` (delete the bridge).
- **Prohibited:** no `sorry`; do NOT delete the `nf_nvar_exist_all_depths | _k+2` arm (that is Phase 5,
  LAST); no spine edit beyond the exists-forall chain repoint (which is above `sigE`, not on the
  `completeness_discrete` spine).

#### Phase 4-flip: Terminal `sigE` summand flip `{A // A in F}` -> `Formula` (per the flip-last decision) [NOT STARTED]

- **Goal:** With all exists-forall-chain finiteness now `M`-relative (nothing left at `sigE` needs
  `Fintype`), perform the small summand flip: change `sigE sig F`'s fresh summand from `{A // A in F}`
  (finite) to the full `Formula` type (infinite E[Sigma], Def 4.1 p.5); update `esigmaPred`/`oldPred`/
  `canonExpand` (`ESigmaExpansion.lean`) so `esigmaPred A` takes no `hA` proof (interp remains `sat A`);
  update `ESigmaCapture` atom-naming to need no `A in F`; drop the `DecidableEq`-only threading residue.
  Decidability survives (`Formula` has `DecidableEq`); only `Fintype`-finiteness is lost.
- **Faithfulness anchor:** report 22 §4 row 3-terminal; Rabinovich Def 4.1 (PDF p.5) + p.6 collapse note.
- **Tasks:**
  - [ ] Re-run the spine-safety grep (`sigE`/`UnaryType`/`IntervalType` over `BXCanonical/`+`Decidability/`
        — expect EMPTY) as a cheap re-confirmation before the flip.
  - [ ] Grep-guard: confirm NO residual `Finset.univ` typed at `UnaryType`/`AtomKind (sigE ...)` remains.
  - [ ] Change `sigE sig F`'s fresh summand `{A // A in F}` -> `Formula`; construct the `MonadicSignature`
        via the Phase-2 explicit-finiteness form (delete `sigE_fintypePreds`).
  - [ ] Update `esigmaPred`/`oldPred`/`canonExpand` (`ESigmaExpansion.lean`) so `esigmaPred A` takes no
        `hA`; interp remains `sat A`.
  - [ ] Update `ESigmaCapture` atom-naming (`canonExpand_atom_named`) to need no `A in F`.
- **Definition of Done:** the re-indexed infinite `sigE` + `esigmaPred`/`canonExpand`/`ESigmaCapture`
  build green, sorry-free, axiom-clean; off-path; `lake build` EXIT 0; `#print axioms completeness_discrete`
  byte-identical to baseline (the `_k+2` residual still carries the spine). The end-state is exactly Def
  4.1 infinite E[Sigma] + per-formula rep.
- **Timing:** 4-8 hours (~150-300 lines). ~1 agent run.
- **Depends on:** 4c.
- **Files to modify:** `Kamp/ESigmaExpansion.lean`, `ESigmaCapture.lean` (+ any `DecidableEq` threading
  touched by the summand change).
- **Prohibited:** no `sorry`; no full-alphabet `Finset.univ`; do NOT delete `OptionBLocalityProbe.lean`;
  no spine edit.

---

### Phase 5: ζ re-wire — discharge capture DIRECTLY (readback IS an atom), construct the ζ `canonExpand`, spine re-point, retire `nf_nvar_exist_all_depths | _k+2` LAST (terminal, live-path) [NOT STARTED]

> **Optional split (report 20 §4.2):** if the single run overflows, split into 5a (capture removal + ζ
> `canonExpand` construction, off-path-verifiable) / 5b (spine re-point + audit-block correction +
> residual deletion + `#print axioms` check). The residual deletion and the `#print axioms` check MUST
> be the terminal actions of 5b.

- **Goal:** With the infinite E[Sigma] (Phase 4-flip) and the re-encoded enumeration surface (Phase 4)
  landed off-path, re-wire the ζ consumers (`ZetaUniformExtract`, `EFSatNegationGeneral`): the capture
  obligation is discharged DIRECTLY because every readback is an atom of the infinite expansion — REMOVE
  the `hCapture`/`capFn` parameters entirely. Construct the ζ `canonExpand` from the surviving landed
  reconciliations (`atomMap = oldPred . g` from `ZetaAtomMapReconcile.lean`, `HasAttainedINF/SUP` from
  `ZetaPriorTransfer.lean`, lifted `psi` from `MonadicFormulaMap.lean`, carrier witness giving `hne :
  Nonempty N.carrier` per report 13). Re-point `kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery`; verify green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT; then **delete it LAST**; confirm `#print
  axioms completeness_discrete` no longer lists `sorryAx`. This is the ONLY live-path phase.
- **Landed-asset dependency (prose):** this phase consumes the landed reconciliations
  `ZetaAtomMapReconcile.lean`, `ZetaPriorTransfer.lean`, `MonadicFormulaMap.lean` — committed FILES, not
  phases of this plan (dependencies-in-fact in the task bullets, not the `Depends on` field).
- **Faithfulness anchor:** Rabinovich Thm 4.4 (PDF p.6, phi = OR_i phi_i, each ->Prop 3.5-> TL — the
  readback is automatically an atom of the infinite expansion, needs no `in F`) + Def 4.1 collapse note
  (p.6) + report 13 (`hne` mandatory) + report 19 / report 20 §2.2 / report 22 §3 (capture discharged
  directly, `hCapture`/`capFn` removed — FAITHFUL).
- **Tasks:**
  - [ ] Re-wire `ZetaUniformExtract` / `EFSatNegationGeneral` to discharge capture DIRECTLY (readback is
        an atom); remove the `hCapture`/`capFn` parameters from the uniform + non-uniform negation stack.
  - [ ] Verify the surviving landed `ZetaAtomMapReconcile` (`Sum.inl`/`Sum.inr` collapse),
        `ZetaPriorTransfer` (`HasAttainedINF/SUP`), and `MonadicFormulaMap` (`mapPreds`) type-check
        against the re-indexed `sigE` and re-state where the fresh summand's index type changed.
  - [ ] Construct the ζ `canonExpand` on the infinite E[Sigma] with `atomMap = oldPred . g` and the
        carrier witness giving `hne`.
  - [ ] Collapse the (now capture-free) beta / gamma / delta results — as re-encoded in Phase 4 — to
        UNCONDITIONAL; apply the (re-encoded) uniform extraction to obtain the single `M`-uniform formula;
        wire the semantic `MonadicFormula -> characteristic NormalForm` bridge into the live spine.
  - [ ] Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery`.
  - [ ] **Correct the STALE in-file audit block in `BXCanonical/Completeness.lean`** (carry-forward,
        report 20 §3.1): the axiom-audit block still cites rotted line refs (`:212/:361/:364`) and
        describes an already-discharged n=1 arm (`kampPrior_case1_arm_k1`) as still-sorry. Rewrite it to
        name `nf_nvar_exist_all_depths` (the `| _k+2` arm) by DECLARATION NAME as the sole residual — no
        line numbers, no task-number pointers (durable anchors only).
  - [ ] **Verify the new path is green with the `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT**
        (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths | _k+2` arm (the residual + its rationale
        block); update the in-file audit block to reflect its removal and any stale doc-comment refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Definition of Done:** `#print axioms completeness_discrete` no longer lists `sorryAx` (retains
  `propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`); full `lake
  build` EXIT 0; no new axiom/sorry anywhere on the proof term. The in-file audit block in
  `Completeness.lean` names `nf_nvar_exist_all_depths` by declaration name. Hand off to task 375 for the
  terminal audit.
- **Timing:** 12-20 hours (~400-700 lines), plus the `canonExpand` construction + direct capture
  discharge. ~1-2 agent runs (or split 5a/5b).
- **Depends on:** 4-flip.
- **Files to modify:**
  - `Kamp/ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean` (capture removal + ζ wire),
  - `KampPrior.lean` (delete the `nf_nvar_exist_all_depths | _k+2` arm — LAST),
  - `BXCanonical/Completeness.lean` (spine re-point + audit-block correction),
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files.
- **Prohibited:** no `sorry`/`def := True`/vacuous placeholder on the spine; no reset/checkout; do NOT
  delete the `nf_nvar_exist_all_depths | _k+2` arm until the new path is proven green end-to-end.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at the current job floor.
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phase 4-flip
      the axiom set is byte-identical to baseline (the pre-existing `nf_nvar_exist_all_depths | _k+2`
      `sorryAx` remains, carrying the spine). Target end-state after Phase 5: `[propext, Classical.choice,
      Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no `sorryAx`.
- [ ] The amended sorry gate holds: the only live sorries anywhere are `nf_nvar_exist_all_depths | _k+2`
      (until Phase 5), `EANegation.lean:1090`, and `EANegation.lean:1249`. No phase introduces any other
      sorry.
- [ ] Additive-bridge discipline: every Phase-4 sub-phase through 4a-4/4b is purely additive (Fin-variants
      alongside untouched total-type lemmas); 4c deletes the now-unconsumed total types + bridge; 4-flip
      makes `sigE` infinite. Each lands off the live import path and green BEFORE Phase 5 touches the spine.
- [ ] `Separation/KampTranslation.lean` is NEVER edited (git diff empty across the whole plan). The
      exists-forall chain's per-formula rendering is the NEW `unaryToFormulaFin`.
- [ ] No `def X := True`, vacuous placeholder, or full-alphabet `Finset.univ` re-introduced. A red render
      obligation at 4a-2, or a 4b tuple-skeleton failure needing the full alphabet, is a return-to-gate
      (`/research`), NOT a hole.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number or a
      Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page). The k>=2 blocker
      is referenced by declaration name `nf_nvar_exist_all_depths`, never by line.
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no `EANegation.lean:1090`/
      `:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks:
- [x] **Phase 1 (GATE)**: the per-formula-finite-atom Prop-3.5 equivalence for one readback compiles
      sorry-free, axiom-clean, off-path, WITHOUT a full-alphabet `Finset.univ`. **GO** (machine-checked).
- [x] **Phase 2**: `MonadicFO.lean` + `NormalForm.lean` build green with `[fintypePreds]`/`[decEqPreds]`
      removed; an infinite-alphabet signature is constructible. **DONE** (full green, cascade ground out).
- [x] **Phase 3 (retained scope)**: spine-safety grep EMPTY; `ZetaReadbackClosure`/`ZetaEngineClosure`
      deleted (vacuous); `OptionBLocalityProbe` preserved. **DONE**.
- [ ] **Phase 4a-2 (render MICRO-GATE)**: `translateProp35Fin` correct end-to-end through
      `unaryToFormulaFin_correct` on a nontrivial `n = 1` input, sorry-free, axiom-clean, off-path, no
      full-alphabet `Finset.univ`. **GO** required to proceed; NO-GO = STOP / `/research`.
- [ ] **Phase 4 (4a-0..4c + 4-flip)**: per-formula rep + bridge + NEW renderer landed; 17 consumers
      migrated one file per commit; `LiftPair` (4b) tuple skeleton re-encoded; total types + bridge
      deleted (4c); `sigE` summand flipped to `Formula` (4-flip); all sorry-free, axiom-clean, off-path;
      no `Finset.univ` over the alphabet; `Separation/KampTranslation.lean` untouched.
- [ ] **Phase 5 (ζ)**: capture discharged DIRECTLY (readback IS an atom), `hCapture`/`capFn` removed; the
      ζ `canonExpand` constructed; conditional beta/gamma/delta collapse to unconditional; the
      `Completeness.lean` in-file audit block corrected to name `nf_nvar_exist_all_depths` by declaration;
      the `_k+2` arm is DELETED LAST; `sorryAx` confirmed absent from `completeness_discrete`.

## Artifacts & Outputs

- plans/23_additive-bridge-migration-v3.md (this file)
- PRESERVED landed assets (do NOT rebuild): `OptionBLocalityProbe.lean` (the Option-B NO-GO record); the
  surviving-shape reconciliations `ZetaAtomMapReconcile.lean`, `ZetaPriorTransfer.lean`,
  `MonadicFormulaMap.lean`; `Section5Correspondence.lean`, `VecEANegFix.lean`; the `canonExpand` semantic
  core + `temporal_truth_canonExpand` conservativity in `ESigmaExpansion.lean`/`ESigmaCapture.lean`;
  `InfAlphabetProbe.lean` (Phase-1 GATE, off-path, promoted at 4a-0); `Separation/KampTranslation.lean`
  (`nf_depth0_char_formula` — NOT edited, keeps its ~40 finite-signature consumers).
- ALREADY DELETED in Phase 3 (vacuous under infinite E[Sigma]): `ZetaReadbackClosure.lean`,
  `ZetaEngineClosure.lean`.
- New / rewritten `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules:
  - Phase 1: `InfAlphabetProbe.lean` (landed; off-path gate).
  - Phase 2: edits to `MonadicFO.lean`, `NormalForm.lean` (+ ~43 downstream threading files).
  - Phase 3: deletions (`ZetaReadbackClosure.lean`, `ZetaEngineClosure.lean`).
  - Phase 4a-0: new `PerFormulaType.lean` (per-formula rep + `completions` bridge).
  - Phase 4a-1: new `PerFormulaRender.lean` (`unaryToFormulaFin`; `Separation/` untouched).
  - Phase 4a-2: render micro-gate (probe file).
  - Phase 4a-3: `ExistsForallFormulaFin` (in `PerFormulaType.lean` or adjacent).
  - Phase 4a-4..N: Fin-variants in `IntervalType.lean`, `ExistsForallLemmas.lean`, `ConjInterleave.lean`,
    `Prop35ExistsForall.lean`, `Prop35Assembly.lean`, `Prop35Chain.lean`, `Prop42ExistsForall.lean`,
    `EFSatNegationGeneral.lean`, `VeeSatNegation.lean`, `VVecEA2Collapse.lean`, `Prop43Translate.lean`.
  - Phase 4b: `LiftPair.lean` (Fin-variants; hardest site).
  - Phase 4c: exists-forall chain repoint + deletions of total-type lemmas + bridge.
  - Phase 4-flip: edits to `ESigmaExpansion.lean`, `ESigmaCapture.lean` (summand flip).
  - Phase 5: edits to `ZetaUniformExtract.lean`, `EFSatNegationGeneral.lean`, `KampPrior.lean` (arm
    deletion), `BXCanonical/Completeness.lean` (spine re-point + audit-block correction), the
    `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain.
- summaries/23_additive-bridge-migration-v3-summary.md (on completion)

## Rollback/Contingency

- **Phases 1-3:** DONE/landed. No rollback needed; probes stay as landed history.
- **Phase 4a-0/4a-1 (additive foundation + renderer):** purely additive/off-path; a failed attempt
  leaves last-green intact and resumable. `Separation/KampTranslation.lean` is never touched, so there is
  no foundational-file rollback risk.
- **Phase 4a-2 (render MICRO-GATE):** binary gate. NO-GO = STOP, do NOT proceed to migration; surface for
  `/research` to de-risk the render / partial-satisfaction obligation. No rollback (nothing landed beyond
  the probe).
- **Phase 4a-3 / 4a-4..N (consumer migration):** each file is its own additive green commit via the
  bridge; a failed file reverts to last-green with the old total-type lemmas intact and the bridge
  available. Migrate strictly in import order; the bridge decouples files so there is no cross-file
  cascade.
- **Phase 4b (`LiftPair.lean`):** additive/off-path; may split by direction (first-class fallback). If
  the tuple skeleton disjunction genuinely needs the full alphabet, that is the post-GATE risk
  materializing and is a return-to-gate / `/research` escalation, NOT a hole.
- **Phase 4c (switchover + deletions):** the repoint and deletions are the only non-additive step before
  4-flip; if the exists-forall chain fails on the Fin variants, revert the repoint to last-green (Fin
  variants present alongside total types, bridge intact) and resume. Do NOT delete total-type lemmas
  until the chain builds green on the Fin variants.
- **Phase 4-flip (summand flip):** if the flip surfaces a residual full-alphabet `Finset.univ` as RED,
  revert the flip (restore the finite `sigE`) to last-green and grep-guard for the offending
  `Finset.univ` before retrying. Decidability survives the flip.
- **Phase 5 regression:** incremental-with-fallback. Prove the new path green with the
  `nf_nvar_exist_all_depths | _k+2` residual STILL PRESENT; delete the arm LAST and verify immediately
  with `#print axioms`. If the spine re-point regresses the build or the axiom set, revert the Phase-5
  edits to last-green (all Phase 1-4 modules present, old residual carrying the spine). `sigE` never
  reaches the spine, so the blast radius of a Phase-5 revert is the three consumers + the
  `Completeness.lean` audit block only.
