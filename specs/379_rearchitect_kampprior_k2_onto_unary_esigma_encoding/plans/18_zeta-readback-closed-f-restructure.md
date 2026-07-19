# Implementation Plan: ζ Readback-Closed-F Restructure — Replacing the BLOCKED Monolithic ζ Wire with an Option-(b) Readback-Closed `F` Construction + 𝔈-Bounded Stack Re-Derivation, Retiring `KampPrior.lean:562`

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: ~30-55 hours remaining across 3 not-started terminal sub-phases (13e-1 readback-closed `F` construction, 13e-2 𝔈-bounded stack re-derivation over the closed `F`, 13e-3 terminal ζ wire + `:562` retirement) plus ~500-1,200 new Lean lines. **Phases 0-12, 10a, 10b-i, 10b-ii, 10P, and 13a-13d are ALL COMPLETED, sorry-free, axiom-clean, off the live import path — PRESERVED VERBATIM; do NOT re-execute.** The B5 gating probe `ZetaEngineClosure.lean` is also PRESERVED (its conditional `*_of_closed` lemmas are the exact plumbing 13e-3 consumes once a readback-closed `F` exists).
- **Dependencies**: None to start (all β/γ/δ/capture machinery and B1-B4 reconciliations landed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 13e-3; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here).
- **Research Inputs**: reports/17_b5-capture-bound-audit.md (AUTHORITATIVE for this revision — the H5 divergence audit + H4 adversarial verification, verdict "B5 PARTIALLY-CONFIRMED", that isolated the whole severity of B5 to the single decidable question "is `F` readback-closable?" and prescribed the gating probe); the committed gating probe `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaEngineClosure.lean` (machine-checked RED verdict: completeness `F` is NOT readback-closable; `esigma_alphabet_strict_mono` / `readback_closure_step_grows_alphabet` / `readback_alphabet_indexes_F` prove the alphabet circularity; the conditional `*_of_closed` lemmas are the plumbing that closes B5 once a readback-closed `F` exists — Option (b) restructure required); reports/16_zeta-wire-blocker-probe.lean (the machine-checked B1-B4 blocker probe, driver of Phases 13a-13e); reports/15_exall-gap-monotone-pinning-verdict.md (the H5 conclusion-strengthening template consumed by Phase 12/13d); reports/14_exall-reordering-closure-resolution.md (path-(c) eval-side closure infrastructure); reports/13_c1-c2-negation-object-blueprint.md (arity-0/1 negation-object blueprint + mandatory `Nonempty N.carrier`); reports/11_esigma-capture-hypothesis-audit.md (the `hCapture`-at-`IntervalType`-level pin); reports/07_faithful-esigma-negation-path.md (authoritative α-ζ phase structure); reports/09_conjinterleave-interval-type-audit.md; reports/05_conjunction-closure-load-bearing-verdict.md; reports/06_phase4-unblock-construction.md
- **Artifacts**: plans/18_zeta-readback-closed-f-restructure.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 17_b5-capture-bound-audit.md, 16_zeta-wire-blocker-probe.lean, 15_exall-gap-monotone-pinning-verdict.md, 14_exall-reordering-closure-resolution.md, 13_c1-c2-negation-object-blueprint.md, 11_esigma-capture-hypothesis-audit.md, 07_faithful-esigma-negation-path.md, 09_conjinterleave-interval-type-audit.md, 05_conjunction-closure-load-bearing-verdict.md, 06_phase4-unblock-construction.md
- **plan_metadata**:
  ```json
  {
    "phases": 19,
    "total_effort_hours": 45,
    "complexity": "complex",
    "research_integrated": true,
    "plan_version": 13,
    "dependency_waves": [[15], [16], [17]],
    "reports_integrated": [
      {"path": "reports/17_b5-capture-bound-audit.md", "integrated_in_plan_version": 13, "integrated_date": "2026-07-19"},
      {"path": "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaEngineClosure.lean", "integrated_in_plan_version": 13, "integrated_date": "2026-07-19"},
      {"path": "reports/16_zeta-wire-blocker-probe.lean", "integrated_in_plan_version": 12, "integrated_date": "2026-07-19"},
      {"path": "reports/15_exall-gap-monotone-pinning-verdict.md", "integrated_in_plan_version": 12, "integrated_date": "2026-07-19"}
    ]
  }
  ```
  (`plan_version: 13` = predecessor plan-12's version + 1; the `dependency_waves` entries name the NEW active sub-phases 13e-1/13e-2/13e-3 using placeholder integers 15-17 for the machine-readable wave grouping — the human-readable wave table under `## Implementation Phases` is authoritative and uses the `13e-1`-`13e-3` labels.)

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) still carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of `nf_nvar_exist_all_depths` at `KampPrior.lean:562`. Across plans
08-12 the entire β/γ/δ/capture machinery landed sorry-free and axiom-clean OFF the live import path
(Phases 0-9, 10a, 10b-i, 10b-ii, 10P, 11, 12), and the plan-12 revision then landed the four B1-B4
ζ-wire reconciliations as off-path green lemmas: Phase 13a (`ZetaAtomMapReconcile.lean`, the B1
`atomMap` `Sum.inl`-vs-`Sum.inr` collapse-unwinding, option (b)), Phase 13b (`ZetaPriorTransfer.lean`,
the B2 `semantic_prior_UZ/SZ` + `HasAttainedINF/SUP` transfer), Phase 13c (`MonadicFormulaMap.lean`,
the B3 `MonadicFormula.mapPreds` + `mapPreds_eval` naturality), and Phase 13d
(`ZetaUniformExtract.lean`, the B4 per-`M` → `M`-uniform `translate_uniform` + full uniform negation
stack). Every one of these landed green, sorry-free, axiom-clean (`[propext, Classical.choice,
Quot.sound]`), and OFF the live spine, so `#print axioms completeness_discrete` remains byte-identical
to baseline (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`).

**This revision (plan 13) replaces the plan-12 monolithic terminal Phase 13e (ζ spine wire), which is
[BLOCKED] on a machine-confirmed structural blocker B5.** Plan 12's Phase 13e attempted to discharge the
landed β/γ/δ + `translate_uniform` stack's capture hypothesis directly against the ζ `canonExpand`. It
cannot, for a reason now confirmed by an adversarial audit AND a machine-checked probe:

- **The capture-bound mismatch (B5).** The reconciliation stack (`translate_uniform`,
  `translate_correct`, `veeSat_negation`, `efSat_negation_general`) binds an **unbounded** capture
  hypothesis `∀ A : Formula, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔ temporal_truth N
  atomMap y A`. The only discharge (10P `esigmaCapture_canonExpand`) is **𝔈-bounded** (`∀ A ∈ 𝔈` for a
  finite `𝔈 ⊆ F`). The unbounded form is genuinely **false** on `canonExpand … atomMap`: a TL formula
  with temporal reach outside `F` (`untl`/`snce`) is not a union of complete-1-type F-cells
  (`ESigmaCapture.lean:204-205`).

- **The audit (`reports/17_b5-capture-bound-audit.md`, verdict PARTIALLY-CONFIRMED).** The audit showed
  the unbounded binding is an **over-strong signature, never instantiated at any temporally-reaching
  `A ∉ F`**: capture is fed only (a) named atoms (already membership-free via `capType`), (b)
  `(translateProp35 …).neg`, and (c) bracket point/segment/endpoint `TemporalPred.formula` fields. The
  real fix is bounded plumbing (weaken ~5 signatures to `∀ A ∈ F`, prove ~4 engine-output closure
  lemmas, thread membership at ~7 sites) — **IF `F` is readback-closable**. The audit isolated the whole
  severity of B5 to that single question and prescribed a decidable gating probe.

- **The probe (`ZetaEngineClosure.lean`, committed, machine-checked RED).** The probe states the four
  target closure lemmas conditional on one hypothesis `ReadbackClosed`, then proves `ReadbackClosed` is
  **circular for the current architecture**: closing `F` under `translateProp35` readback **strictly
  enlarges the E[Σ] alphabet at every step**. Each readback formula's atoms name the ENTIRE F-indexed
  alphabet (`readback_alphabet_indexes_F`: `esigmaPred A ≠ oldPred q`), and adding any `B ∉ F` strictly
  grows the fresh-predicate carrier (`esigma_alphabet_strict_mono`: `F.card < (insert B F).card`), so
  the bottom-up readback closure never reaches a fixpoint **on the alphabet**
  (`readback_closure_step_grows_alphabet`). The completeness `F` currently threaded is a free `variable
  {F : Finset Formula}` with no readback-closure construction anywhere in the tree. **Standard
  Fischer–Ladner termination fails here on the ALPHABET, not the temporal depth.** Option (a) plumbing is
  therefore impossible; **Option (b) restructure is required.**

**The re-scoping strategy (this plan):** build `F` as a readback-closed set with a construction that
re-indexes the E[Σ] alphabet coherently (Phase **13e-1**, the highest-risk sub-phase), then re-derive
the negation/translate stack under the `∀ A ∈ F` bounded capture hypothesis and discharge the four
closure obligations via `ZetaEngineClosure.lean`'s conditional `*_of_closed` lemmas now that
`ReadbackClosed` holds (Phase **13e-2**), then perform the terminal live-path wire — feed
`esigmaCapture_canonExpand`'s 𝔈-bounded discharge into the bounded stack, construct the ζ `canonExpand`
from the landed 13a/13b/13c reconciliations, apply the uniform extraction, re-point the spine, verify
green with `:562` still present, and **delete `:562` LAST** (Phase **13e-3**). The completed phases
(0-12, 10a, 10b-i, 10b-ii, 10P, 11, 12, 13a-13d) and the probe `ZetaEngineClosure.lean` are
**PRESERVED VERBATIM** below and must NOT be re-executed.

**Definition of done (unchanged): `#print axioms completeness_discrete` no longer lists `sorryAx`**,
with the full `lake build` at EXIT 0 and no new axiom or non-permitted sorry anywhere on the proof term.
Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
Quot.sound]` — with `sorryAx` REMOVED (Phase 13e-3 deletes the sole on-path `KampPrior.lean:562` sorry).

### Research Integration

- **Report 17 (`reports/17_b5-capture-bound-audit.md`, AUTHORITATIVE for this revision, newly
  integrated)**: the H5 divergence audit + H4 adversarial verification of the B5 blocker. Verdict "B5
  PARTIALLY-CONFIRMED": the "unbounded form is mathematically FALSE" premise is TRUE-BUT-IRRELEVANT (the
  offending `untl`-outside-`F` witness is never fed by the stack); the genuine residual work is either
  bounded plumbing (Option (a)) IF `F` is readback-closable, or the Option (b) restructure otherwise. Its
  decisive contribution is isolating the entire severity of B5 to one decidable question — **is `F`
  readback-closable without alphabet circularity?** — and mandating a gating probe BEFORE any stack
  change. Its Section 3 enumerates the exact ~7 capture application sites
  (`EFSatNegationGeneral.lean:282,321`; `ZetaUniformExtract.lean:135,168,292,295,306-312`) and the ~5
  signatures to bound (`translate_uniform`, `efSat_negation_general_uniform`, `veeSat_negation_uniform`,
  `efSat_negation_pair/_diagonal/_existence_uniform`, plus the non-uniform mirrors) that Phase 13e-2
  re-derives over the closed `F`.
- **Probe `ZetaEngineClosure.lean` (committed, machine-checked RED, newly integrated as an
  authoritative artifact)**: the single decidable gate the audit prescribed, run and RED. It (1) states
  the four target closure lemmas (`translateProp35_mem_F_of_closed`,
  `translateProp35_neg_mem_F_of_closed`, `bracket_pointType_formula_mem_F_of_closed`,
  `bracket_segmentType_formula_mem_F_of_closed`, `endpoint_formula_mem_F_of_closed`) conditional on the
  isolated hypothesis `ReadbackClosed`; and (2) machine-checks the obstruction that `ReadbackClosed` is
  circular for the threaded `F`: `readback_alphabet_indexes_F` (`esigmaPred A hA ≠ oldPred q` — each
  readback formula names the entire F-indexed alphabet), `esigma_fresh_card`
  (`card {A // A ∈ F} = F.card`), `esigma_alphabet_strict_mono` (`F.card < (insert B F).card` for
  `B ∉ F`), and `readback_closure_step_grows_alphabet` (a readback that escapes `F` lands in a strictly
  larger alphabet, so no bottom-up iteration stabilizes). The probe's own recommended next action is
  exactly this `/revise` for the Option (b) restructure, "with the circularity below as the documented
  root cause." Its conditional `*_of_closed` lemmas are the exact plumbing Phase 13e-3 consumes once
  Phase 13e-1 delivers a `ReadbackClosed`-satisfying `F`.
- **Report 16 (`reports/16_zeta-wire-blocker-probe.lean`, carried forward)**: the machine-checked B1-B4
  blocker probe that drove the plan-12 decomposition into Phases 13a-13d (all now landed). Its B1 PROBE 1
  `False`-derivation grounded Phase 13a's option-(b) collapse-unwinding
  (`ZetaAtomMapReconcile.temporal_truth_collapse`) that Phase 13e-3 uses to build the ζ `canonExpand`
  `atomMap = oldPred ∘ g`.
- **Report 15 (`reports/15_exall-gap-monotone-pinning-verdict.md`, carried forward)**: the H5
  conclusion-strengthening template ("the target was never blocked by missing mathematics; it was blocked
  by the correctness statement being one conjunct too weak"). This is the operating principle for Phase
  13e-2's re-derivation over the closed `F`: bound the capture hypothesis and thread membership, do not
  invent new mathematics. Also the model for Phase 13d's `N`-independence exposure (landed).
- **Report 14 (`reports/14_exall-reordering-closure-resolution.md`, carried forward)**: path-(c)
  eval-side closure infrastructure (`MonadicFormula.rename`/`eval_rename`, `subst0`/`eval_subst0`,
  `renamePin`/`veeSat_renamePin`) — the naturality-proof shape Phase 13c reused (landed).
- **Report 13 (`reports/13_c1-c2-negation-object-blueprint.md`, carried forward)**: the mandatory
  `Nonempty N.carrier` correction (`hne`) that Phase 13e-3 threads into the arity-0 existence-sentence
  collapse; confirms the reverse Prop 3.5 map is not needed.
- **Report 11 (`reports/11_esigma-capture-hypothesis-audit.md`, carried forward)**: pinned `hCapture` at
  the `IntervalType` level; its Q3/Q4 finding — `hCapture` is dischargeable ONLY at ζ against an
  `F`-closed `canonExpand` — is exactly what Phase 13e-1's readback-closed `F` construction arranges, and
  the reason the probe's circularity is the true crux.
- **Reports 07 / 09 / 05 / 06 (carried forward)**: the faithful α-ζ phase structure, the partial-interval
  adjudication, the conjunction-closure verdict, and the arbitrary-pin Prop 4.2 engine — all consumed by
  the now-complete β/γ/δ machinery and the B1-B4 reconciliations.

### Prior Plan Reference

Supersedes `plans/17_zeta-wire-b1-b4-reconciliation.md` (which superseded plans 11 → 10 → 09 → 08).
**Phases 0-12, 10a, 10b-i, 10b-ii, 10P, 11, 12, and 13a-13d are carried forward VERBATIM** (all
COMPLETED, sorry-free, axiom-clean, landed green off the live path), as is the committed B5 gating probe
`ZetaEngineClosure.lean`. Plan 12's monolithic Phase 13e (ζ) was recorded [BLOCKED] on the B5
capture-bound mismatch; the probe confirmed the mismatch is a genuine alphabet circularity (Option (b)
required). This plan **replaces the single blocked Phase 13e with the sequence 13e-1 → 13e-2 → 13e-3**,
each a bounded per-agent run, the last being the sole live-path phase. **Do NOT re-execute any completed
phase or the probe.**

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. No roadmap review/update phases are added.

## Goals & Non-Goals

**Goals**:
- **Preserve all landed sorry-free work VERBATIM** — Phases 0-12 (the ε interface, the partial
  `IntervalType` migration, the full `conjInterleave_iff`/`veeConj_iff`, the conditional
  `vvecea2_collapse_bridge`, the `liftPair` family, the `efSat_negation_general` β assembly, the
  `veeSat_negation` γ, the full `translate_correct` δ, and the `𝔈`-bounded `esigmaCapture_canonExpand`
  discharge), Phases 13a-13d (the B1 `ZetaAtomMapReconcile`, B2 `ZetaPriorTransfer`, B3
  `MonadicFormulaMap`, B4 `ZetaUniformExtract` reconciliations), and the B5 gating probe
  `ZetaEngineClosure.lean`. Do NOT re-execute them.
- **Construct a readback-closed `F` (Phase 13e-1, highest-risk)**: build `F` as a Fischer–Ladner-style
  readback-closed set with a fixpoint/enlargement construction that RE-INDEXES the `sigE` E[Σ] alphabet
  coherently — reaching a joint fixpoint of formula-set ∧ alphabet, or bounding the readback depth so the
  enlargement the probe identified terminates. Satisfy the probe's `ReadbackClosed` predicate.
- **Re-derive the 𝔈-bounded stack over the closed `F` (Phase 13e-2)**: restate `translate_uniform` + the
  β/γ/δ negation stack with the `∀ A ∈ F` capture hypothesis; discharge the four closure obligations via
  `ZetaEngineClosure.lean`'s `*_of_closed` conditionals now that `ReadbackClosed` holds; thread
  membership at the ~7 audit-enumerated capture sites.
- **Wire ζ (Phase 13e-3, terminal, live-path)**: feed `esigmaCapture_canonExpand`'s 𝔈-bounded discharge
  into the bounded stack; construct the ζ `canonExpand` (`atomMap = oldPred ∘ g` from 13a,
  `HasAttainedINF/SUP` from 13b, lifted `ψ` from 13c); apply the Phase-13d uniform extraction; re-point
  `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery`; verify green with `:562` still present, then **delete `:562` LAST**;
  confirm `#print axioms completeness_discrete` no longer lists `sorryAx`.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor headers
  only; Rabinovich cited by PDF page, never line number).

**Non-Goals**:
- Introducing any novel mathematics or Feferman-Vaught composition. The readback-closed `F` construction
  is Rabinovich's own Fischer–Ladner-style closure (Def 4.1 + Thm 4.4 apparatus), not new content.
- Any arity-4 realization engine, joint-type-over-a-tuple, or `chain_split` (NON-APPLICABLE).
- Touching `EANegation.lean:1090` / `:1249` (zero external consumers, off the proof term) or rebuilding
  `Kamp/NfEFold.lean`; no `nf_eval_efold` / `nf_eval_nfk_iff_efold`.
- The terminal `#print axioms` final-assembly audit (task 375) and arity-4 apparatus archival (task 359).
- Any `sorry` outside the amended sorry gate below, any `def X := True`, vacuous placeholder, or
  `Prop43Structural.lean`-style hole. In particular, **13e-1/13e-2/13e-3 must NOT be discharged with
  `sorry` on the spine** — if the joint fixpoint of Phase 13e-1 proves infeasible, STOP and surface for a
  further `/research` dispatch.

## Binding Constraints (carry into EVERY phase)

- **FAITHFULNESS TO RABINOVICH IS ESSENTIAL. NO NOVEL MATHEMATICS, NO FEFERMAN-VAUGHT.** Every
  construction traces to a report-17/16/15/14/13/11/09/07 finding, the probe's machine-checked findings,
  or a report H3 table row. The readback-closed `F` is Rabinovich's Fischer–Ladner closure, cited by PDF
  page.
- **Cite Rabinovich BY PDF PAGE ONLY**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
  The companion `.md` is CORRUPT and must not be used.
- **Anchor code by DECLARATION NAME, never line number. NO TASK-NUMBER POINTERS in `Theories/**/*.lean`.**
- **`chain_split` is NON-APPLICABLE.** Do NOT touch `EANegation.lean:1090` / `:1249`. Do NOT rebuild
  `Kamp/NfEFold.lean`.
- **AMENDED SORRY GATE.** The only permitted live sorries anywhere in the build are:
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 13e-3), `EANegation.lean:1090`, and
  `EANegation.lean:1249`. No phase may introduce any other sorry or any new axiom.
- **INCREMENTAL-WITH-FALLBACK.** Phases 13e-1 and 13e-2 land off-path and green (full `lake build` EXIT 0,
  `#print axioms completeness_discrete` byte-identical to baseline) BEFORE Phase 13e-3 touches the spine.
  In Phase 13e-3, the new path is proven green with the old `:562` sorry STILL PRESENT (spine carried by
  fallback); only then is the `nf_nvar_exist_all_depths` match deleted LAST.
- **`hCapture` is threaded 𝔈-bounded, not re-derived at unbounded strength.** The plan-12 β/γ/δ stack
  carried the *unbounded* `∀ A : Formula` hypothesis (the root of B5). Phase 13e-2 re-derives the stack
  with the `∀ A ∈ F` bounded form; Phase 13e-3 discharges it via the landed 𝔈-bounded
  `esigmaCapture_canonExpand` (`𝔈 := F`, `h𝔈 := subset_rfl`). This is a re-statement of the capture
  hypothesis, not a re-open of 10P (whose discharge is already 𝔈-bounded and reused verbatim).
- **Point types stay complete `UnaryType`; only interval types are partial `Finset UnaryType`.**

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 13e-1: no joint fixpoint of formula-set ∧ alphabet exists for this encoding (the readback-closed `F` cannot be constructed) | H | M | THIS is the decisive, highest-risk sub-phase — the probe (`readback_closure_step_grows_alphabet`, `esigma_alphabet_strict_mono`) proves the naive bottom-up closure does NOT terminate on the alphabet. Faithful resolutions to attempt in order: (i) a joint fixpoint reached by simultaneous formula-set + alphabet recursion (Rabinovich's own construction quantifies the alphabet over the *fixed target formula's* Fischer–Ladner set, not an unbounded readback — anchor to the PDF construction); (ii) bound the readback depth so the enlargement terminates at a fixed E[Σ] alphabet keyed on the input formula (the U/S chains `translateEF1` emits have bounded temporal depth). Size each construction attempt as one bounded agent run. If NEITHER yields a `ReadbackClosed`-satisfying `F`, STOP and surface for a `/research` dispatch — do NOT force with `sorry`. Flag explicitly that this sub-phase may surface a further, deeper gap (whether a joint fixpoint exists at all for this encoding). |
| Phase 13e-1's readback-closed `F` changes the `sigE sig F` alphabet, forcing re-work of the landed 13a-13d + β/γ/δ lemmas that thread the free `variable {F}` | M | M | The landed lemmas are polymorphic in `F` (all thread `variable {F : Finset Formula}`), so instantiating `F` at the readback-closed set is a specialization, not a re-derivation — the lemma bodies are unchanged. Phase 13e-2's re-derivation is only the *capture-hypothesis* bounding (`∀ A` → `∀ A ∈ F`) + membership threading, not a rebuild of the negation engine. Verify by instantiating a landed lemma at the concrete closed `F` and checking it type-checks before the full re-thread. |
| Phase 13e-2: the `∀ A ∈ F` re-derivation is larger than one agent run | M | M | It is the exact bounded-plumbing Option (a) the audit specified: ~5 signature weakenings + membership threading at ~7 sites, with the four closure obligations discharged by `ZetaEngineClosure.lean`'s `*_of_closed` conditionals (no new closure proof — `ReadbackClosed` is supplied by 13e-1). Split by stack layer if it overflows: (2a) `translate_uniform` + δ; (2b) the β/γ negation stack (`efSat_negation_*_uniform`, `veeSat_negation_uniform`). Each split lands green off-path. |
| Phase 13e-2 needs `F` `.neg`-closed for `translateProp35_neg_mem_F_of_closed` (the fed formula is `.neg`) | M | L | Known and scoped: the probe's `translateProp35_neg_mem_F_of_closed` takes `hNegClosed : ∀ A ∈ F, A.neg ∈ F` as an explicit extra hypothesis. Phase 13e-1's closure construction must additionally close `F` under `.neg` (Fischer–Ladner is standardly negation-closed) so `hNegClosed` is discharged from the construction, not assumed. |
| Phase 13e-3 live-path rewire regresses the spine or fails to remove `sorryAx` | H | M | Incremental-with-fallback (binding constraint): prove the new path green with `:562` still present; delete `nf_nvar_exist_all_depths` LAST and verify immediately with `#print axioms`. Rollback = revert the Phase-13e-3 spine re-point + match deletion to last-green (all 13e-1/13e-2 lemmas present, old sorry intact). |
| A `hCapture` 𝔈-boundedness mismatch persists at the ζ site after 13e-2 | M | L | Phase 13e-2's whole purpose is to eliminate this: after re-derivation the stack consumes `∀ A ∈ F`, which `esigmaCapture_canonExpand` discharges directly with `𝔈 := F, h𝔈 := subset_rfl`. Verify the bounded signature matches the discharge shape before 13e-3 wires it. |
| Off-paper mathematics or a task-number/line-number citation slips into a `Theories/` file | H | L | Per-phase faithfulness anchor to a named report finding or the probe; durable-anchor headers only; Rabinovich cited by PDF page; the readback-closure construction anchored to Rabinovich's Fischer–Ladner set (PDF), not invented. |

## Implementation Phases

**Dependency Analysis** (Phases 0-12, 10a, 10b-i, 10b-ii, 10P, 11, 12, 13a-13d are LANDED/COMPLETED, and
the B5 gating probe `ZetaEngineClosure.lean` is COMMITTED — shown for provenance; the active waves are
the ζ restructure 13e-1 → 13e-2 → 13e-3):

| Wave | Phases | Blocked by | State |
|------|--------|------------|-------|
| 1 | 0 | -- | COMPLETED |
| 2 | 1, 2 | 0 | COMPLETED |
| 3 | 3 | 2 | COMPLETED |
| 4 | 4 | 3 | COMPLETED |
| 5 | 5, 6, 7 | 4 | COMPLETED |
| 6 | 8 | 5, 6, 7 | COMPLETED |
| 7 | 9 | 8 | COMPLETED |
| 8 | 10a, 10P | 9, 6 (10a); 1 (10P) | COMPLETED |
| 9 | 10b-i, 10b-ii (⇒ Phase 10 parent) | 10a | COMPLETED |
| 10 | 11 | 10 | COMPLETED |
| 11 | 12 | 11 | COMPLETED |
| 12 | 13a (B1 — decisive/gating) | 12, 10b, 10P | COMPLETED |
| 13 | 13b (B2), 13c (B3), 13d (B4) | 13a | COMPLETED |
| 14 | B5 gating probe (`ZetaEngineClosure.lean`) | 13a-13d, 10P | COMMITTED (RED verdict) |
| **15** | **13e-1 (readback-closed `F` construction — decisive/gating)** | probe (RED) | NOT STARTED (resumes here) |
| **16** | **13e-2 (𝔈-bounded stack re-derivation over the closed `F`)** | 13e-1 | NOT STARTED |
| **17** | **13e-3 (terminal ζ wire — live path)** | 13e-1, 13e-2, 13a, 13b, 13c, 13d, 10P, 12 | NOT STARTED |

Phases within the same wave can execute in parallel. **All phases through Phase 13d (including 10a,
10b-i, 10b-ii, 10P, and the B5 gating probe) are landed/committed — do NOT re-execute them.**
Implementation resumes at Wave 15. **The next implementable dispatch is Phase 13e-1** (the decisive
readback-closed `F` construction), which gates 13e-2 and 13e-3: its committed `ReadbackClosed`-satisfying
`F` is the fixed interface 13e-2's closure discharges build against and 13e-3 wires. Phase 13e-3 is the
ONLY live-path phase; through Phase 13e-2 the spine and `#print axioms completeness_discrete` are
UNCHANGED (the `KampPrior.lean:562` `sorryAx` remains the sole on-path sorry until Phase 13e-3 deletes
it).

---

### Phase 0: ζ/ε spine-rewire seam de-risking spike (viability gate) [COMPLETED]

**VERDICT: GO.** Both seams machine-checked viable, sorry-free (`lake env lean` EXIT 0; each
`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`), in
`reports/08_zeta-epsilon-seam-probe.lean`. Seam (b) `hcapture` is dischargeable
(`hcapture_dischargeable_minimal`) and feeds the landed `esigma_descent` verbatim
(`esigma_descent_composes_minimal`). Seam (a) bridge is VIABLE in the SEMANTIC direction
`MonadicFormula → characteristic NormalForm → truth-determined` (via `nf_characteristic` +
`doets_lemma_1_1`); there is no syntactic `NormalForm → MonadicFormula` translation and none is
needed. No `Theories/` edits; live spine and `#print axioms completeness_discrete` untouched.

- **Goal:** Prove cheaply, on a minimal case, that the two highest-risk ζ/ε seams are viable.
- **Faithfulness anchor:** report-07 H3 rows "Def 4.1 `hcapture` discharge" and "Thm 4.4, p.6".
- **Tasks:**
  - [x] Exhibit the `NormalForm`↔`MonadicFormula` bridge on a minimal case; record viable direction.
  - [x] Discharge `esigma_descent.hcapture` on the minimal case, sorry-free.
  - [x] Record an explicit GO / NO-GO verdict.
- **Definition of Done (binary):** GO iff both minimal probes compile sorry-free off-path. **Met.**
- **Timing:** 4-6 hours (~150-300 lines). ~1 agent run. **Complete.**
- **Depends on:** none.
- **Files modified:** `reports/08_zeta-epsilon-seam-probe.lean` (probe; not under `Theories/`).
- **Completed:** 2026-07-17.

---

### Phase 1: ε — Prop 3.5 ∨-lift + `esigma_descent.hcapture` discharge (off-path) [COMPLETED]

Delivered the ε-interface `prop35_vee_lift`, the genuinely-new `prop35_vee_lift_disjunctwise`
(each disjunct via `translateProp35`) and `prop35_vee_lift_append` (Def 3.3 disjunction
distributivity) in `Prop35VeeLift.lean`; and `hcapture_dischargeable`,
`hcapture_dischargeable_faithful`, `esigma_descent_composes` in `HCaptureDischarge.lean`. Both
modules off the live import path (grep-audited); `completeness_discrete` axiom set unchanged.

- **Goal:** Discharge the full ε content OFF the live path (Prop 3.5 ∨-lift + general `hcapture`).
- **Faithfulness anchor:** report-07 H3 rows "Prop 3.5, p.5" and "Def 4.1 `hcapture` discharge".
- **Tasks:**
  - [x] Establish the Prop 3.5 ∨-lift to `VeeExistsForall`.
  - [x] Prove the general `hcapture` discharge lemma, sorry-free.
  - [x] Keep all deliverables off-path; grep/import-audit the spine is untouched.
- **Timing:** 6-10 hours (~200-500 lines). **Complete.**
- **Depends on:** 0.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop35VeeLift.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/HCaptureDischarge.lean`.
- **Completed:** 2026-07-17.

---

### Phase 2: α (part 1) — `conjInterleave` def + order-preserving merge + forward direction [COMPLETED]

*(Completed hard-mode phase: `ConjInterleave.lean` green with one PERMITTED tracked
`conjInterleave_forward` strategic sorry under the amended sorry gate; its forward direction is
re-derived under partial intervals in Phase 9 — the sorry was RETIRED in Phase 9.)*

**CARRIED FORWARD FROM PLAN 08.** Landed `ConjInterleave.lean` (off live import path; full
`lake build` EXIT 0; spine untouched) with the merge apparatus sorry-free: `belowCount`,
`belowCount_le`, `intervalSlot`, `chainPointType`, `chainIntervalType`, `MergePair`
(+`Fintype`/`DecidableEq`), `MergePair.valid`, `MergePair.pointConsistent`, `mergedFormula`,
`conjInterleave`, `mergedSet`, `mergedSet_card_succ`, and the crux `pointConsistent_of_holds`. The
forward theorem `conjInterleave_forward` was stated TRUE with ONE documented mechanical
strategic-sorry (the sorted-union `orderEmbOfFin` rank-realization bookkeeping), retired in Phase 9.

- **Goal (as landed):** the definition + forward direction of the ∃∀×∃∀ → ∨∃∀ order-preserving
  merge (Lemma 3.2(1)), a single ordered chain with no arity growth.
- **Faithfulness anchor:** report-09/07 H3 row "Lemma 3.2(1) / Lemma 3.4 (∧), p.4-5".
- **Tasks:**
  - [x] Define the order-preserving merge datatype + `conjInterleave` (point-consistency filter).
  - [x] Forward direction of `conjInterleave_iff` — TRUE skeleton with one tracked strategic sorry;
        **re-derived and retired in Phase 9 on the partial representation.**
  - [x] Verify no arity growth (single `StrictMono` chain, unary types).
- **Timing:** 8-12 hours (landed); forward-direction discharge folded into Phase 9.
- **Depends on:** 0.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean`.
- **Completed:** 2026-07-18 (forward sorry retired in Phase 9).

---

### Phase 3: Partial interval type — `IntervalType := Finset UnaryType` + `ofComplete` + `intervalHolds` [COMPLETED]

- **Goal:** Introduce the partial interval representation as ADDITIVE new declarations, touching no
  existing field or consumer, so the build stays green trivially. Establishes the abstraction all
  later migration phases route through.
- **Faithfulness anchor:** report-09 §5 (Phase 2.5, first bullet) + H3 row "Def 3.1, p.4" — a qf
  1-formula IS its finite set of satisfying complete 1-types.
- **Tasks:**
  - [x] Define `IntervalType sig F := Finset (UnaryType sig F)` (admissible-completion set).
  - [x] Define `intervalHolds N (S : IntervalType) (y) : Prop := ∃ τ ∈ S, unaryHolds N τ y`.
  - [x] Define `intervalConj S₁ S₂ := S₁ ∩ S₂`, `intervalBot := (∅ : Finset _)`,
        `intervalTop := Finset.univ`.
  - [x] Define the embedding `ofComplete : UnaryType → IntervalType := ({·})` + the compatibility lemma
        `intervalHolds_ofComplete_iff`.
  - [x] Prove the basic algebra: `intervalHolds_mono`, `intervalHolds_inter_iff`,
        `intervalHolds_inter_left`/`_right`, and `intervalHolds_bot` (⊥/forced-empty vacuity lever).
- **Timing:** 3-5 hours (~135 lines). **Complete.**
- **Depends on:** 2.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/IntervalType.lean` (new).
- **Verification:** compiles sorry-free, axiom-clean; imported by nothing yet; full `lake build` EXIT 0;
  `#print axioms completeness_discrete` unchanged.
- **Completed:** 2026-07-18.

---

### Phase 4: `efSat` interval-clause abstraction — route through `intervalHolds ∘ ofComplete` [COMPLETED]

- **Goal:** Reformulate `ExistsForallFormula.efSat`'s three interval clauses to satisfy
  `intervalHolds N (ofComplete (ψ.intervalType t)) y` while KEEPING the stored field complete-typed.
  Expose `efSat` interval-clause unfold/bridge lemmas so every downstream consumer migrates via a
  one-line rewrite. The stable target the field-flip (Phase 8) later widens without touching consumers.
- **Faithfulness anchor:** report-09 §5 (Phase 2.5, second/third bullets).
- **Tasks:**
  - [x] Add a derived accessor `ExistsForallFormula.intervalSet ψ t : IntervalType`. *(deviation:
        placed in `IntervalType.lean` to avoid an import cycle.)*
  - [x] Restate `efSat`'s three interval clauses through `intervalHolds N (ψ.intervalSet t) y`; prove
        `efSat_interval_iff`. *(`efSat` def body left unchanged so no consumer breaks — widen-last.)*
  - [x] Provide `efSat` unfold lemmas (`intervalSet_holds_iff` + `intervalSet_below_iff`/`_middle_iff`/`_above_iff`).
  - [x] Fix any breakage local to `ExistsForallFormula.lean` / `VeeExistsForall.lean`. *(no-op — additive-only.)*
- **Timing:** 5-8 hours (~90 added lines). **Complete.**
- **Depends on:** 3.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/IntervalType.lean` (Phase-4 bridge).
- **Verification:** compiles sorry-free, axiom-clean; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` UNCHANGED. Consumers still build because the `efSat` clause is untouched.
- **Completed:** 2026-07-18.

---

### Phase 5: `ExistsForallLemmas` migration — `augTarget` / `pairProject` / `existenceSentence` / `augTarget_iff` [COMPLETED]

- **Goal:** Migrate the `ExistsForallLemmas.lean` interval reasoning onto the `intervalHolds`
  abstraction (via Phase 4 bridge lemmas), keeping the field complete-typed. Territory: this file only.
- **Faithfulness anchor:** report-09 §4 + H3 row "Lemma 3.2(2)".
- **Tasks:**
  - [x] Re-point `augTarget`, `pairProject`, `existenceSentence` interval-type handling through the
        `intervalSet`/`intervalHolds` accessors.
  - [x] Migrate `augTarget_iff`'s interval-clause reasoning to `intervalHolds` via the Phase 4 bridge.
  - [x] Confirm no other declaration in the file directly unfolds the old interval clause. *(grep verified.)*
- **Timing:** 5-8 hours (~7 targeted edits). **Complete.**
- **Depends on:** 4.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean`.
- **Verification:** compiles sorry-free, axiom-clean; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` unchanged.
- **Completed:** 2026-07-18.

---

### Phase 6: `prop42_efSat_negation_general` interval-clause migration — `efIntervalTP` → set-disjunction [COMPLETED]

- **Goal:** Migrate `Prop42NegationGeneral.lean` (1004 lines, LANDED sorry-free) onto the partial
  satisfaction relation. Generalize `efIntervalTP` from translating a **complete** interval type to
  translating an admissible-completion **set** (a disjunction of complete-type translations), threaded
  through `belowFormula`/`aboveFormula`/`middleBracket` and their correctness proofs. Territory: this
  file only.
- **Faithfulness anchor:** report-09 §4 + H3 row "Prop 3.5, p.5".
- **Tasks:**
  - [x] Generalize `efIntervalTP` (landed as `efIntervalSetTP` + `efIntervalSetTP_eval`).
  - [x] Thread it through `belowFormula` / `aboveFormula` / `middleBracket` + their correctness proofs.
  - [x] Re-establish `prop42_efSat_negation_general` sorry-free on the migrated clauses.
- **Split contingency (H8):** if it exceeded one run, split 6a/6b (not needed — landed in one).
- **Timing:** 8-14 hours. **Complete.**
- **Depends on:** 4.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean`.
- **Verification:** compiles sorry-free, axiom-clean; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` unchanged.
- **Completed:** 2026-07-18.

---

### Phase 7: `Prop35Assembly` / `Prop35Chain` / `Prop42ExistsForall` re-point [COMPLETED]

- **Goal:** Migrate the remaining `efSat`/interval-clause consumers onto the `intervalHolds`
  abstraction via the Phase 4/6 bridges. Territory: these three files only.
- **Faithfulness anchor:** report-09 §4 (blast-radius list).
- **Tasks:**
  - [x] Re-point `Prop35Assembly.lean` interval-clause reasoning through the `intervalHolds`/
        `efSat_interval_iff` bridges.
  - [x] Re-point `Prop35Chain.lean` similarly. *(No-op: grep-verified zero interval-clause code.)*
  - [x] Re-point `Prop42ExistsForall.lean` similarly.
- **Timing:** 5-8 hours (~19 targeted edits + 1 import). **Complete** (2 migrated files, 1 verified no-op).
- **Depends on:** 4.
- **Files modified:** `Prop35Assembly.lean`, `Prop35Chain.lean` *(no change)*, `Prop42ExistsForall.lean`.
- **Verification:** all three compile sorry-free, axiom-clean; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` unchanged.
- **Completed:** 2026-07-18.

---

### Phase 8: Field-type flip — `ExistsForallFormula.intervalType : Fin (n+2) → IntervalType` (widen last) [COMPLETED]

- **Goal:** Widen the STORED interval field from `Fin (n+2) → UnaryType` to `Fin (n+2) → IntervalType`
  (genuine `Finset UnaryType`); point types stay `UnaryType`. Localized to the field declaration, the
  `intervalSet` accessor, the `efSat` interval clauses, and the constructors that BUILD
  `ExistsForallFormula`. No consumer proof changes.
- **Faithfulness anchor:** report-09 §5 (Phase 2.5, second bullet).
- **Tasks:**
  - [x] Change `ExistsForallFormula.intervalType` to `Fin (n+2) → IntervalType`; collapse `intervalSet`
        to the field. *(deviation: `IntervalType`/`intervalHolds` moved UP into `ExistsForallFormula.lean`
        to avoid an import cycle.)*
  - [x] Update every constructor / builder to store `ofComplete τ` (singleton). *(deviation: skipped —
        all producers auto-adapted; genuine `ofComplete` producers are emitted by later phases.)*
  - [x] Mechanically update `ConjInterleave.lean`'s `chainIntervalType`/`mergedFormula`. *(deviation:
        skipped — return type widened automatically.)*
  - [x] Confirm the amended sorry gate holds.
- **Prerequisite consumer migration (done here, committed green while field still complete-typed):**
  relocated `efIntervalSetTP`/`efIntervalSetTP_eval` up into `Prop35Assembly.lean`, routed the
  `Prop35Assembly`/`Prop42ExistsForall` interval clauses through `efIntervalSetTP ∘ ψ.intervalSet`
  (commits 8.1-8.3), then the atomic flip (8.4).
- **Timing:** 4-7 hours. **Complete.**
- **Depends on:** 5, 6, 7.
- **Files modified:** `ExistsForallFormula.lean`, `ConjInterleave.lean` (mechanical typecheck), builder sites.
- **Verification:** full `lake build` EXIT 0; `#print axioms completeness_discrete` unchanged; only the
  four permitted sorries present. The interval field is now genuinely partial.
- **Completed:** 2026-07-18.

---

### Phase 9: α (restated) — full `conjInterleave_iff` under partial intervals + `veeConj` / `veeConj_iff` [COMPLETED]

- **Goal:** On the partial representation, redefine the `conjInterleave` merge so the merged interval
  type is `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂` (via `intervalConj`), then prove the FULL
  biconditional `conjInterleave_iff`, discharging the carried Phase 2 forward strategic sorry. Then
  build `veeConj` + `veeConj_iff` (Lemma 3.4-∧) as a full biconditional — the ∨∃∀-closed-under-∧
  operation γ (Phase 11) and δ `and`-case (Phase 12) require.
- **Faithfulness anchor:** report-09 §5 (Phase 3 restated) + H3 rows "Lemma 3.2(1) / Lemma 3.4 (∧),
  p.4-5". Dropped the `ConjInterleave.lean` footnote-2 citation; grounded on Def 3.1 (p.4) + Lemma
  3.2(1)/3.4 per the H4 correction.
- **Tasks:**
  - [x] Redefine the merged interval type to `intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t)`;
        made `chainPointType` `Option`-valued + added `mergedPointType`; restored the module to green.
  - [x] Discharge the FORWARD direction (re-deriving + retiring the carried Phase 2 sorry) via the crux
        `strictMono_lt_iff_val_lt_filterCard`, `chain_interval_clause`, `chainIntervalType_eq_pointSlot`,
        `intervalHolds_conj_of_both`.
  - [x] Prove the BACKWARD direction (region decomposition + `crossConsistent`); assemble `conjInterleave_iff`.
  - [x] Define `veeConj` + prove `veeConj_iff` (full biconditional) via `veeSat_flatMap`.
  - [x] Update the module docstring: footnote-2 dropped; Def 3.1 + Lemma 3.2(1)/3.4 cited.
- **Timing:** 8-12 hours (~350-500 lines). **Complete.**
- **Depends on:** 8.
- **Files modified:** `ConjInterleave.lean` (redefine + full iff), `VeeConj.lean` (new).
- **Verification:** `conjInterleave_iff` (both directions), `veeConj`, `veeConj_iff` compile sorry-free,
  axiom-clean (`veeConj_iff` = `[propext, Classical.choice, Quot.sound]`); the `conjInterleave_forward`
  strategic sorry is GONE; off the live path; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` unchanged.
- **Completed:** 2026-07-18.

---

### Phase 10: β — conditional collapse bridge + single-∃∀ negation over unordered pairs [COMPLETED]

**RESOLUTION** (report 11, adversarially verified; the twice-blocked seam landed as a CONDITIONAL
result and the β assembly is now complete). The β target
(`efSat_negation_general … : ∃ Φ : VeeExistsForall …, ¬ efSat ↔ veeSat Φ`) is realized by interposing
the CONDITIONAL `vvecea2_collapse_bridge` (Def 4.1 E[Σ] collapse, taking `hCapture` at the `IntervalType`
level) so the `VVecEA2`-valued engine output is lifted to a `VeeExistsForall` disjunct before the
`veeSat_append` flatten, with the signature carrying `atomMap / h_surj / h_INF / h_SUP` AND `hCapture`.
The arity-2 → arity-r lift gap (surfaced mid-implementation) was resolved by the `liftPair` family
(Phase 10b-i) per report 12. Split: 10a (conditional collapse bridge) → 10b-i (`liftPair`) → 10b-ii
(`efSat_negation_general` assembly), with Phase 10P (`hCapture` discharge) in parallel. Each component
landed green + sorry-free + off the live import path. All conditional/orphan results are gated on
`hCapture` (permitted; discharged at ζ). **NOTE (B5 provenance):** the `hCapture` these β/γ/δ results
thread is the *unbounded* `∀ A : Formula` form — the root of blocker B5. Phase 13e-2 re-derives the
stack under the `∀ A ∈ F` bounded form; the Phase-10 bodies below are otherwise preserved.

- **Faithfulness anchor:** report-11 Q1/Q4/Q5 + report-07 R4 + H3 rows "Def 4.1 + collapse note, p.5-6",
  "Prop 4.3 ¬-case assembly", "Prop 4.2", "Lemma 3.2(2)", "Prop 3.5".

#### Phase 10a — CONDITIONAL `vvecea2_collapse_bridge` threading `hCapture` (Def 4.1 E[Σ] collapse) [COMPLETED]

Landed in `VVecEA2Collapse.lean`, axiom-clean `[propext, Classical.choice, Quot.sound]`, off the live
import path, full `lake build` EXIT 0. Proves the reverse bridge as a CONDITIONAL result taking
`hCapture` (`∀ A, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A`)
as an explicit argument — the reverse of the landed `translateVeeProp42`. Landed lemmas:
`intervalType_captures_temporalPred`, `intervalHolds_intervalTop`,
`vvecea2_collapse_of_perClauseList` (the list-valued generalization — one `VecEA2` clause expands into a
disjunction over point completions), `exists_piFinset_forall_iff`, and the crux `bracket_completion_iff`,
plus `collapseEF`/`collapseEF_translate`/`collapseEF_cap`. The landed `vvecea2_collapse_of_perClause`
(disjunctive assembly half, from plan 10) is composed through, untouched. `h_INF`/`h_SUP` carried; the
`negFix` readback was avoided because `hCapture` captures every engine-output formula directly.

- **Tasks:**
  - [x] `vvecea2_collapse_of_perClause` (disjunctive assembly, taking `trans`/`htrans`). *(landed plan 10.)*
  - [x] Add `hCapture` to `vvecea2_collapse_bridge`'s signature at the `IntervalType` level.
  - [x] Discharge the per-clause `trans`/`htrans` for the endpoint clauses via `hCapture`.
  - [x] Discharge the per-clause `trans`/`htrans` for a `BracketFormula` clause via `bracket_completion_iff`.
  - [x] Compose through the (list-valued) assembly lemma to conclude the full biconditional gated on `env 0 < env 1`.
- **Definition of Done:** compiles sorry-free, axiom-clean; a proved CONDITIONAL biconditional (orphan
  gated on `hCapture`, PERMITTED); off the live import path; full `lake build` EXIT 0. **Met.**
- **Timing:** 6-10 hours. **Complete.**
- **Depends on:** 9, the landed `vvecea2_collapse_of_perClause`, 6. Does NOT depend on Phase 10P.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean`.
- **Completed:** 2026-07-18.

#### Phase 10b-i — `liftPair` (arity-2 → arity-r completion-expansion lift, report 12 §c) [COMPLETED]

Additive sub-phase (report 12, Option 2): lift each ≤2-free-variable negation disjunct to arity `r` via
an order-preserving chain-merge (Lemma 3.2(1)), disjoining over insertions and inserted-point
completions. Landed green, sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]` in the new
orphan file `LiftPair.lean`: `charType`/`unaryHolds_charType`/`exists_unaryHolds`, `intervalHolds_top`,
`skelDisjunct`/`skelR`/`skelR_sat`, `LiftMergePair` (`eξ`/`eS` embeddings; `valid` with `k,l`-only pin
coincidence; `validS`; `crossConsistent`), `liftMergedPointType` (+ `_xi`/`_skel` readback),
`liftMergedFormula`, `liftPair` + membership + `exists_liftMergePair_of_mem`, `liftPair_forward`,
`liftPair_backward`, `liftPair_iff`, `liftPairV` + `liftPairV_iff`, `liftSentence` +
`liftSentence_forward`/`_backward`/`_iff`. The merge machinery generalized to arbitrary source arity `s`
so the arity-0 sentence lift reuses it.

- **Tasks:**
  - [x] Reuse-viability spike (custom merge required; scalar helpers reusable; skelR is `VeeExistsForall`).
  - [x] `skelR` / `skelR_sat` type-disjunction skeleton.
  - [x] `LiftMergePair` / `liftMergedFormula` / `liftPair` definition.
  - [x] `liftPair_iff` forward + backward directions.
  - [x] `liftPairV` / `liftSentence` wrappers + their `_iff` lemmas.
- **Timing:** ~2-3 dispatches (~1,100 lines). **Complete.**
- **Depends on:** 10a, 9.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean` (new).
- **Verification:** full `lake build` EXIT 0; `completeness_discrete` axioms byte-identical to baseline.
- **Completed:** 2026-07-18.

#### Phase 10b-ii — `efSat_negation_general` assembly [COMPLETED]

The β assembly composing the landed `efSat_negation_pair` (engine ∘ 10a bridge), the `liftPairV` /
`liftSingleV` / `liftSentenceV` lifts (10b-i), the diagonal reduction (`diagProject` +
`diagProject_efSat_iff`), the `pairProject_swap_efSat` symmetry fold, and the two low-arity negation
objects (`efSat_negation_diagonal` arity-1, `efSat_negation_existence` arity-0 — each threading
`hCapture`, and the arity-0 object carrying the mandatory `Nonempty N.carrier` hypothesis per report 13).
`efSat_negation_general` is landed sorry-free as the CONDITIONAL trichotomy (`k<l` pair / `k=l` diagonal
/ `k>l` symmetry + existence-sentence disjunct), an orphan gated on `hCapture` until ζ.

- **Goal (as landed):**
  ```lean
  theorem efSat_negation_general {sig : MonadicSignature} {F : Finset Formula}
      (N : OrderedMonadicStructure (sigE sig F))
      (atomMap : Formula → (sigE sig F).preds)
      (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
      (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
      (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,          -- threaded, not discharged
          ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
      {r : Nat} (ψ : ExistsForallFormula sig F r) :
      ∃ Φ : VeeExistsForall sig F r, ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ efSat N env ψ ↔ veeSat N env Φ)
  ```
- **Faithfulness anchor:** Prop 4.3 single-∃∀ ¬-case (p.6); report 13 (arity-0/1 objects + `hne`).
- **Tasks:**
  - [x] De Morgan the migrated `augTarget_iff` decomposition (`efSat_negation_demorgan`).
  - [x] `k < l` pair disjunct: `efSat_negation_pair` (`vvecea2` engine ∘ bridge) + `liftPairV`.
  - [x] `k > l` symmetry fold: `pairProject_swap_efSat`.
  - [x] `k = l` diagonal reduction to arity 1: `diagProject` + `diagProject_efSat_iff`; 1-pin `liftSingle`/`liftSingleV`.
  - [x] Disjunctive sentence lift: `liftSentenceV` + `liftSentenceV_iff`.
  - [x] Arity-1 diagonal negation object `efSat_negation_diagonal` (report 13 c1).
  - [x] Arity-0 existence-sentence negation object `efSat_negation_existence` (report 13 c2; carries `Nonempty N.carrier`).
  - [x] `efSat_negation_general` trichotomy assembly consuming the two objects + the `pairwiseProjections` reindex.
- **Definition of Done:** `efSat_negation_general` compiles sorry-free, axiom-clean (a CONDITIONAL orphan
  gated on `hCapture`, PERMITTED); off the live import path; full `lake build` EXIT 0. **Met.**
- **Timing:** ~2-3 dispatches (~800 lines across `EFSatNegation.lean` / `EFSatNegationGeneral.lean`).
- **Depends on:** 10a, 10b-i, 9, 6.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegationGeneral.lean` (new).
- **Prohibited (honored):** no `sorry`/`def := True`/vacuous placeholder; `hCapture` threaded, never discharged.
- **Completed:** 2026-07-18/19.

- **Phase 10 parent — Definition of Done:** β (`efSat_negation_general`) is a proved CONDITIONAL result
  at the `VeeExistsForall` type; γ (Phase 11) and δ (Phase 12) rest on it and on the landed
  `VeeExistsForall`-valued machinery with no `VVecEA2`-level rebuild (the Option-1 payoff). **Met.**

---

### Phase 10P: PREREQUISITE — E[Σ] output-alphabet capture/closure lemma (discharges `hCapture` at the ζ `canonExpand`) [COMPLETED] [HIGH-RISK, RESEARCH-GROUNDED]

**LANDED (P-a shape) in `ESigmaCapture.lean`, sorry-free, axiom-clean `[propext, Classical.choice,
Quot.sound]`, off the live import path; full `lake build` EXIT 0; `completeness_discrete` spine axiom
set byte-identical to baseline.** Five lemmas: `intervalCapture_of_atomNamed` (reverse of
`unaryToFormula_correct` at the `IntervalType` level, via the `S := {τ | τ names A = true}` filter +
`nf_characteristic`), `intervalCapture_forall_mem` (the `𝔈`-bounded packaging),
`temporal_truth_canonExpand` (conservativity of `temporal_truth` under `canonExpand` when `atomMap`
factors through `oldPred`), `canonExpand_atom_named` (the finite `hCanon` via `atom_eval_new` +
conservativity), and `esigmaCapture_canonExpand` (assembled `𝔈`-bounded `hCapture` on the concrete
`canonExpand`). No genuine Def 4.1 obstruction hit: the F-closure is the explicit requirement `𝔈 ⊆ F`,
which ζ arranges by construction (now via the Phase-13e-1 readback-closed `F`).

**Phase-13e interface note (LOAD-BEARING for Phase 13e-2/13e-3):** the discharge is `𝔈`-bounded
(`∀ A ∈ 𝔈`); the *plan-12* landed β signature threads the unbounded `∀ A : Formula`. The full `∀ A` form
is genuinely undischargeable for temporally-reaching `A ∉ F` (report R1; report 17 §2) — this is exactly
blocker B5. Phase 13e-2 re-states the β/γ/δ stack with the `∀ A ∈ F` form so this discharge feeds
directly (`𝔈 := F`, `h𝔈 := subset_rfl`). **The `atomMap` this discharge requires is `oldPred ∘ g`
(`Sum.inl`-only)** — reconciled against `translate`/`prop35`'s `h_surj` by the landed Phase-13a
`ZetaAtomMapReconcile` (option (b) collapse-unwinding).

- **Goal (as landed):** the forward E[Σ]-capture / output-alphabet-closure lemma discharging `hCapture`
  at the concrete `canonExpand` used by ζ, in the finite `𝔈`-membership form.
- **The F-closure invariant (report 11 Q4):** established as the explicit `𝔈 ⊆ F` requirement +
  conservativity (`temporal_truth_canonExpand`), so `atom_eval_new` names each engine output.
- **Tasks:**
  - [x] Fix the discharge shape (P-a, output-alphabet closure) with `𝔈` = the finite engine-output set.
  - [x] Establish the F-closure invariant (explicit `𝔈 ⊆ F` + conservativity).
  - [x] Derive `hCapture` (interval-level, `𝔈`-bounded) on the `canonExpand` via `atom_eval_new`.
  - [x] Keep the module off the live import path (confirmed: nothing imports `ESigmaCapture`).
- **Definition of Done:** compiles sorry-free, axiom-clean; yields `𝔈`-bounded `hCapture` for the ζ
  `canonExpand`; off the live import path; full `lake build` EXIT 0. **Met.**
- **Timing:** 10-18 hours. **Complete.**
- **Depends on:** 1. May run in parallel with 10a/10b/11/12. **Blocks Phase 13e-3.**
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaCapture.lean` (new).
- **Completed:** 2026-07-18.

---

### Phase 11: γ — ∨∃∀ negation [COMPLETED]

Landed `veeSat_negation` in `VeeSatNegation.lean`, sorry-free, axiom-clean `[propext, Classical.choice,
Quot.sound]`, off the live import path, threading the same `N / atomMap / h_surj / h_INF / h_SUP` AND
`hCapture` hypotheses β carries (a CONDITIONAL orphan until ζ). Faithful to Prop 4.3's
disjunction-negation sub-case (p.6): `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by β (via the 10a
collapse bridge); reassembled via the landed `veeConj_iff` (Phase 9). No `VVecEA2`-level rebuild
(the Option-1 payoff). **(B5 provenance: threads the unbounded `hCapture`; re-derived `∀ A ∈ F` in 13e-2.)**

- **Faithfulness anchor:** report-07/09 H3 rows "Prop 4.3 ¬-case assembly" + "Lemma 3.4 (∧)".
- **Tasks:**
  - [x] De Morgan `¬veeSat (∨φᵢ)` into `⋀ᵢ ¬φᵢ` (via `veeSat_cons` + `not_or`; induction on the disjunct list).
  - [x] Apply `efSat_negation_general` (β) per disjunct (empty base case via `efArb` tautological top).
  - [x] Reassemble via `veeConj_iff` (Phase 9); fold over the disjuncts.
- **Timing:** 3-5 hours (~110 lines). **Complete.**
- **Depends on:** 9, 10.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VeeSatNegation.lean` (new).
- **Verification:** compiles sorry-free, axiom-clean; off the live import path; full `lake build` EXIT 0.
- **Completed:** 2026-07-19.

---

### Phase 12: δ — structural Prop 4.3 `translate` (MonadicFormula → VeeExistsForall) [COMPLETED]

**COMPLETE across all six connective cases** (atom / lt / and / or-derived / not / ex / all). The four
straightforward cases (atom via `atomEmit_iff` + `hCapture` + `h_surj`; lt index-decided under
`StrictMono`; and via `veeConj_iff`; not via `veeSat_negation`) landed first. The ex/all gap disjuncts
— which had been tracked strategic sorries at `Prop43Translate.lean:439`/`:448` — were CLOSED via the
report-15 monotone-pinning verdict + path-(c) eval-side substrate (report 14): `translate_correct`'s
conclusion was strengthened with the structural invariant `∀ ψ ∈ Ψ, StrictMono ψ.pin`, which the IH
already produces (from `LiftMergePair.valid.eS`, `MergePair.valid.e₁`, `skelDisjunct.pin = id`), so the
unconditional `veeSat_exists` gap witness is forced into its gap by `env = x ∘ ψ.pin` StrictMono; the
`efArb` nil-branch exception was neutralized by a one-witness swap to an identity-pinned tautological
disjunct. The eval-side substrate (`MonadicFormula.rename`/`eval_rename`, `size`/`size_rename`,
`subst0`/`eval_subst0`, `renamePin`/`veeSat_renamePin`, `insertPerm`/`eval_insertNth_rename`) is landed
axiom-clean. `translate_correct` carries `hCapture` (threaded, not discharged) — a CONDITIONAL orphan
gated on it until ζ. No arity growth (every case's emitted object is a `VeeExistsForall sig F m` at the
same arity `m`; the only arity change is the ex/all binder's `m+1 → m` drop). **(B5 provenance: threads
the unbounded `hCapture`; re-derived `∀ A ∈ F` in 13e-2.)**

- **Goal (as landed):** `translate : MonadicFormula sig m → VeeExistsForall sig F m` (delivered as the
  existential-by-induction `translate_correct`, model-dependent via `hCapture`/choice, as β/γ are)
  + `translate_correct` with the strengthened conclusion
  `∃ Ψ, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧ (∀ env, StrictMono env → (veeSat N env Ψ ↔ eval N env φ))`.
- **Faithfulness anchor:** report-07/09 H3 row "Prop 4.3, p.6"; report 15 (monotone-pinning closure);
  report 14 (path-(c) eval-side closure infrastructure).
- **Tasks:**
  - [x] Define the translation by well-founded recursion on `MonadicFormula.size`; atom/`lt` emit
        partial `IntervalType` sets directly.
  - [x] Prove `translate_correct` case-by-case, each an independent green sub-step: atom, lt, and, not,
        ex, all. *(ex/all closed via the report-15 conclusion-strengthening + `efArb` one-witness swap;
        the `or` constructor does not arise — `MonadicFormula`'s 6 constructors are atom/lt/not/and/all/ex.)*
  - [x] Verify by goal inspection that the assembled induction introduces no arity growth.
- **Timing:** 10-16 hours across several dispatches (~600-900 lines). **Complete.**
- **Depends on:** 9, 10, 11.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean` (new),
  `VeeSatNegation.lean` (the `efArb` → identity-pinned witness swap, report 15 T2).
- **Verification:** `translate` + all six connective cases of `translate_correct` compile sorry-free,
  axiom-clean; no arity growth; off the live import path; full `lake build` EXIT 0.
- **Completed:** 2026-07-19.

---

### Phase 13a: B1 — `atomMap` `Sum.inl`-vs-`Sum.inr` reconciliation (decisive, gating) [COMPLETED]

**LANDED (option (b) collapse-unwinding) in `ZetaAtomMapReconcile.lean`, sorry-free.** Resolved the
decisive B1 incompatibility (report 16 PROBE 1, which proves `False`): no single `atomMap` on the shared
`canonExpand` can satisfy both `translate_correct`/`prop35_vee_lift`'s `h_surj` (surjection onto
`sig.preds ⊕ {A // A ∈ F}`, requiring `Sum.inr` hits) and
`esigmaCapture_canonExpand`/`temporal_truth_canonExpand`'s `atomMap = oldPred ∘ g` (`Sum.inl`-only).
VERDICT recorded: genuine `Sum.inr` use EXISTS (the `translateProp35 → efIntervalTP/efPointTP →
unaryToFormula → nf_depth0_char_formula → nfPred` chain NAMES every predicate including fresh `Sum.inr`
E[Σ] atoms), so option (a) is INFEASIBLE and option (b) was taken. Landed: `collapseSubst`,
`temporal_truth_collapse` (the p.6-collapse unwinding `temporal_truth N atomMap y A ↔ temporal_truth M g
y (collapseSubst θ A)`), `collapse_leaf_atom_oldPred`, `collapse_leaf_fresh`, and
`reconciled_no_surj_onto_inr` (the reconciled `Sum.inl`-only `atomMap` captures each fresh pred by
unwinding to the named formula via `canonExpand_atom_named`, so PROBE 1's `Sum.inl_ne_inr` `False` is
never instantiated). This is the committed interface Phases 13b/13c/13d built against and Phase 13e-3
uses to construct the ζ `canonExpand`.

- **Faithfulness anchor:** report-16 B1 (PROBE 1 `False`, the two named resolution options) + report-11
  Q3/Q4 (`hCapture` at a closed-`F` `canonExpand`) + Rabinovich Def 4.1 atom-collapse (PDF p.5-6).
- **Tasks:**
  - [x] Audit every `h_surj` use site (`Prop43Translate` / `Prop35VeeLift`); VERDICT: genuine `Sum.inr` use EXISTS → option (b).
  - [x] Land the p.6-collapse unwinding lemma `temporal_truth_collapse` for the emitted `A`.
  - [x] Commit the reconciliation signature (the fixed B2/B3/B4 interface).
  - [x] Re-run report 16's PROBE 1 shape; confirm the `False` derivation no longer type-checks
        (`reconciled_no_surj_onto_inr`).
- **Definition of Done:** the reconciliation lemmas compile sorry-free, axiom-clean; off the live import
  path; full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline. **Met.**
- **Timing:** 10-18 hours (~200-450 lines). **Complete.**
- **Depends on:** 12, 10b, 10P.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaAtomMapReconcile.lean` (new).
- **Completed:** 2026-07-19.

---

### Phase 13b: B2 — `semantic_prior_UZ/SZ (canonExpand …) atomMap` [COMPLETED]

Landed `canonExpand_semantic_prior_UZ`, `canonExpand_semantic_prior_SZ`, `canonExpand_hasAttainedINF`,
`canonExpand_hasAttainedSUP` in `ZetaPriorTransfer.lean` (imports `ESigmaCapture` + `PriorINF`), four
lemmas sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`. Transported `M`'s prior axioms
along `sat = temporal_truth M g ·` + the `canonExpand`'s order (= `M`'s order) via
`temporal_truth_canonExpand`; carrier+order inherited verbatim. These are the `HasAttainedINF/SUP`
hypotheses `translate_correct` consumes, fed by Phase 13e-3. Nothing imports the module (off-path);
`KampPrior.lean:562` spine untouched; full `lake build` EXIT 0; `#print axioms completeness_discrete`
byte-identical to baseline.

- **Faithfulness anchor:** report-16 B2 (PROBE 2 GAP-A/A′) + the landed `PriorINF` `prior_hasAttainedINF/SUP`.
- **Tasks:**
  - [x] State + prove `canonExpand_semantic_prior_UZ` (transport via `temporal_truth_canonExpand`).
  - [x] Same for `canonExpand_semantic_prior_SZ`.
  - [x] Derive `canonExpand_hasAttainedINF` / `canonExpand_hasAttainedSUP` via `prior_hasAttainedINF/SUP`.
- **Definition of Done:** both prior-axiom lemmas + the two `HasAttained*` derivations compile sorry-free,
  axiom-clean; off-path; full `lake build` EXIT 0; `#print axioms completeness_discrete` unchanged. **Met.**
- **Timing:** 6-10 hours (~150-300 lines). **Complete.**
- **Depends on:** 13a. Ran parallel with 13c, 13d.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaPriorTransfer.lean` (new).
- **Completed:** 2026-07-19.

---

### Phase 13c: B3 — `MonadicFormula` signature lift `sig → sigE sig F` + eval-naturality [COMPLETED]

Landed `MonadicFormula.mapPreds` (structural recursion relabelling the atom/predicate slot) +
`mapPreds_eval` (`=` form) + `mapPreds_eval_iff` (`↔` form) in `MonadicFormulaMap.lean`, sorry-free,
axiom-clean, off the live import path, mirroring the landed `MonadicFormula.rename`/`eval_rename`
(report 14 path-(c)) naturality-proof shape. Specialized at `oldPred`, old-predicate conservativity is
definitional (`interp (oldPred p) = M.interp p`), the syntactic face of `temporal_truth_canonExpand`'s
temporal-atom collapse. This moves the target `psi : MonadicFormula sig 1` into `translate_correct`'s
domain `MonadicFormula (sigE sig F) 1` with truth preserved. Full `lake build` EXIT 0; `#print axioms
completeness_discrete` unchanged.

- **Faithfulness anchor:** report-16 B3 + report-14 path-(c) `MonadicFormula.rename`/`eval_rename`.
- **Tasks:**
  - [x] Define `MonadicFormula.mapPreds` (structural recursion; relabels the atom/predicate slot).
  - [x] Prove `mapPreds_eval` (eval-naturality) by induction, mirroring `eval_rename`.
  - [x] Specialize at `oldPred`; connect to `canonExpand` conservativity so `eval M env psi` transfers.
- **Definition of Done:** `mapPreds` + `mapPreds_eval` compile sorry-free, axiom-clean; off-path; full
  `lake build` EXIT 0; `#print axioms completeness_discrete` unchanged. **Met.**
- **Timing:** 6-10 hours (~150-300 lines). **Complete.**
- **Depends on:** 13a. Ran parallel with 13b, 13d.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/MonadicFormulaMap.lean` (new).
- **Completed:** 2026-07-19.

---

### Phase 13d: B4 — per-`M` → `M`-uniform formula extraction [COMPLETED]

**COMPLETED.** N-independence VERDICT recorded and machine-checked; the full `∃Ψ`-outside-`∀N` uniform
`translate` is landed green, sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`, off-path
in `Kamp/ZetaUniformExtract.lean`. The re-thread went through the *entire* negation stack as a bounded
mechanical copy: `prop42_efSat_negation_general_uniform` (model-independent `VVecEA2` witness) →
`vvecea2_collapse_bridge_uniform` (per-clause reverse translation inlined) →
`efSat_negation_pair_uniform` → `efSat_negation_general_uniform` (De Morgan trichotomy) →
`veeSat_negation_uniform` (γ) → `ex_closure_translate_uniform` → `translate_uniform` (δ, well-founded
recursion on `MonadicFormula.size`). Atoms use the model-independent `capType` base case
(`atomEmit_capType_iff`); all model-dependence (`hCapFn`/`h_INF`/`h_SUP`/`hne`) threaded inside `∀N`.
Full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline;
`KampPrior.lean:562` spine UNTOUCHED. **(B5 provenance: `translate_uniform` and the uniform stack thread
the unbounded `capFn : Formula → IntervalType` / `∀ A, …` form — the root of blocker B5. Phase 13e-2
re-derives them with the `∀ A ∈ F` bounded capture.)**

- **Goal:** Bridge the uniformity gap (report 16 B4): a SINGLE formula uniform over all `M`
  (`{ A : Formula // ∀ M … }`), exploiting that the emitted `IntervalType` witness
  `S = univ.filter (τ a₀ = true)` is model-independent.
- **Mechanism (report 15 conclusion-strengthening technique):** the obstruction is a too-weak
  conclusion, not missing math; expose an `N`-independent `Ψ` and extract the single formula.
- **Faithfulness anchor:** report-16 B4 (the model-independent `S = univ.filter (τ a₀ = true)` witness)
  + report-15 §5 (the conclusion-strengthening postmortem).
- **Tasks:**
  - [x] Verify every `IntervalType`/point-type witness is chosen `N`-independently (`univ.filter`);
        machine-checked as `intervalHolds_capType` (generic over every `N` over `sigE`), sorry-free.
  - [x] Strengthen the correctness conclusion to expose the `N`-independent `Ψ` (`∃Ψ`-outside-`∀N` via `capFn`).
  - [x] Re-thread the strengthened conclusion through the entire β/γ/δ uniform stack.
  - [x] Land `translate_uniform` (δ, well-founded recursion) — the `M`-uniform formula source.
- **Definition of Done:** the uniform stack compiles sorry-free, axiom-clean; off-path; full `lake build`
  EXIT 0; `#print axioms completeness_discrete` unchanged; the emitted formula confirmed `N`-independent. **Met.**
- **Timing:** 8-14 hours across several dispatches (~600-900 lines). **Complete.**
- **Depends on:** 13a. Ran parallel with 13b, 13c.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaUniformExtract.lean` (new).
- **Completed:** 2026-07-19.

---

### Phase 13e-0 (reference only): B5 gating probe `ZetaEngineClosure.lean` (RED verdict, PRESERVED) [COMPLETED]

**COMMITTED (`685ff3e97`), machine-checked, RED. PRESERVED — do NOT re-run or delete.** The single
decidable gate the report-17 audit prescribed for B5. States the four target closure lemmas conditional
on the isolated hypothesis `ReadbackClosed` (`translateProp35_mem_F_of_closed`,
`translateProp35_neg_mem_F_of_closed` — the latter taking `hNegClosed : ∀ A ∈ F, A.neg ∈ F`,
`bracket_pointType_formula_mem_F_of_closed`, `bracket_segmentType_formula_mem_F_of_closed`,
`endpoint_formula_mem_F_of_closed`), all sorry-free and axiom-clean — **the exact plumbing that closes
B5 once a readback-closed `F` exists (Phase 13e-1 delivers `ReadbackClosed`; Phase 13e-2/13e-3 consume
these `*_of_closed` lemmas).** Then machine-checks the obstruction (`ReadbackClosed` is circular for the
threaded free `variable {F}`): `readback_alphabet_indexes_F` (`esigmaPred A hA ≠ oldPred q`),
`esigma_fresh_card` (`card {A // A ∈ F} = F.card`), `esigma_alphabet_strict_mono`
(`F.card < (insert B F).card`), `readback_closure_step_grows_alphabet` (a readback escaping `F` lands in
a strictly larger alphabet — no bottom-up fixpoint). Off-path (imports only `ZetaUniformExtract`;
imported by nothing); `KampPrior.lean:562` untouched.

- **Verdict:** RED — B5 CONFIRMED as a restructure, not plumbing. Option (a) bottom-up closure fails on
  the ALPHABET (not depth). Recommended next action (executed by this plan): `/revise` for the Option (b)
  restructure, Phases 13e-1 → 13e-2 → 13e-3.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaEngineClosure.lean` (committed probe).
- **Completed:** 2026-07-19 (`685ff3e97`).

---

### Phase 13e-1: ζ — readback-closed `F` construction (decisive, gating, highest-risk) [NOT STARTED]

- **Goal:** Build `F` as a readback-closed (Fischer–Ladner-style) set with a fixpoint/enlargement
  construction that RE-INDEXES the `sigE` E[Σ] alphabet coherently, satisfying the probe's
  `ReadbackClosed` predicate (`ZetaEngineClosure.ReadbackClosed`) AND `hNegClosed : ∀ A ∈ F, A.neg ∈ F`.
  This is the crux the probe identified: the readback closure grows the alphabet
  (`esigma_alphabet_strict_mono`, `readback_closure_step_grows_alphabet`), so a naive bottom-up
  `F ↦ F ∪ {readbacks over F}` never reaches a fixpoint. The construction must instead reach a JOINT
  fixpoint of formula-set ∧ alphabet, or bound the readback depth so the enlargement terminates at an
  alphabet keyed on the input formula. **This is the highest-risk sub-phase; it may surface a further,
  deeper gap (whether a joint fixpoint exists at all for this encoding).**
- **Design (attempt in order; each a bounded agent run):**
  - **(i) Joint fixpoint keyed on the target formula.** Rabinovich's construction quantifies the E[Σ]
    alphabet over the *fixed target formula's* Fischer–Ladner set, NOT an unbounded readback of an
    arbitrary `F`. Define `F` as the Fischer–Ladner closure of the specific input formula (finite, by
    Rabinovich's own bound), so `sigE sig F` is fixed once and the readbacks `translateProp35 ξ` for `ξ`
    over that `F` land back in it by construction. The probe's `readback_alphabet_indexes_F` is then not
    a circularity but the intended coherent indexing: the alphabet is `F` re-typed
    (`esigma_fresh_card : card {A // A ∈ F} = F.card`), fixed for the fixed `F`.
  - **(ii) Depth-bounded readback termination (fallback).** If the joint fixpoint is not directly
    constructible, bound the readback temporal depth: the U/S chains `translateEF1` emits
    (`Prop35Assembly.translateProp35`) have bounded temporal depth, so a depth-`d` closure terminates at a
    fixed alphabet. Prove termination at the fixed `d` for the completeness input.
- **Faithfulness anchor:** Rabinovich's Fischer–Ladner closure construction (PDF; the finite
  closure-set + fixed E[Σ] alphabet, Def 4.1 / Thm 4.4 apparatus — cite by PDF page) + the probe's
  `readback_alphabet_indexes_F` / `esigma_alphabet_strict_mono` / `readback_closure_step_grows_alphabet`
  (the machine-checked reason a bottom-up closure fails, which the joint-fixpoint construction avoids).
- **Tasks:**
  - [ ] Define the readback-closed `F` (Fischer–Ladner closure of the input formula) as a concrete
        `Finset Formula` with a decidable/constructive membership; prove finiteness.
  - [ ] Prove `ReadbackClosed atomMap h_surj` for this `F` (discharge the three conjuncts:
        `translateProp35 ξ ∈ F`, `(efPointTP τ).formula ∈ F`, `(efIntervalSetTP S).formula ∈ F`).
  - [ ] Prove `hNegClosed : ∀ A ∈ F, A.neg ∈ F` (Fischer–Ladner is standardly negation-closed).
  - [ ] Confirm the construction re-indexes `sigE sig F` coherently (the alphabet is fixed once `F` is
        fixed; `esigma_fresh_card` holds by construction, no strict-mono enlargement is triggered because
        every readback stays in `F`).
  - [ ] Verify the landed 13a-13d + β/γ/δ lemmas (polymorphic in `variable {F}`) instantiate at the
        concrete closed `F` and type-check (specialization, not re-derivation).
- **Definition of Done:** a concrete readback-closed `F` with `ReadbackClosed` + `hNegClosed` proven
  sorry-free, axiom-clean (`[propext, Classical.choice, Quot.sound]` or subset); off the live import
  path; full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline. **If
  neither (i) nor (ii) yields a `ReadbackClosed`-satisfying `F` — i.e. no joint fixpoint of formula-set ∧
  alphabet exists for this encoding — STOP and surface for a further `/research` dispatch; do NOT force
  with `sorry` or a vacuous `F`.**
- **Timing:** 12-24 hours (~200-500 lines; highest-risk, per-attempt bounded runs). GATES 13e-2/13e-3.
- **Depends on:** the B5 probe (`ZetaEngineClosure.lean`), 13a-13d, 10P.
- **Files to modify:** a new `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaReadbackClosure.lean`
  (name provisional) hosting the closed-`F` construction + the `ReadbackClosed`/`hNegClosed` discharges.
- **Prohibited:** no `sorry`/`def := True`/vacuous `F := ∅` placeholder; no spine edit (off-path only).

---

### Phase 13e-2: ζ — 𝔈-bounded stack re-derivation over the closed `F` [NOT STARTED]

- **Goal:** Restate `translate_uniform` + the β/γ/δ negation stack with the `∀ A ∈ F` bounded capture
  hypothesis (replacing the unbounded `∀ A : Formula` form that is the root of B5), and discharge the
  four engine-output closure obligations via `ZetaEngineClosure.lean`'s `*_of_closed` conditionals now
  that Phase 13e-1 supplies `ReadbackClosed` (and `hNegClosed`). Thread membership at the ~7 capture
  application sites the audit enumerated. This is the bounded-plumbing Option (a) the audit specified,
  now UNBLOCKED by the readback-closed `F`.
- **Mechanism (report 17 §3 Option (a), executed over the closed `F`):**
  - Weaken the capture hypothesis in the ~5 uniform signatures (`translate_uniform`,
    `efSat_negation_general_uniform`, `veeSat_negation_uniform`,
    `efSat_negation_pair/_diagonal/_existence_uniform`) and their non-uniform mirrors
    (`translate_correct`, `veeSat_negation`, `efSat_negation_general/_diagonal/_existence`) from
    `∀ (A : Formula), P A` to `∀ A ∈ F, P A`. `F : Finset Formula` is already a section `variable` in
    every one of these files, so no new parameter is introduced; `capFn` stays total, only the proof
    obligation is bounded.
  - At each of the ~7 capture application sites — `EFSatNegationGeneral.lean:282,321` (fed
    `(translateProp35 …).neg`); `ZetaUniformExtract.lean:135,168` (readback·neg),
    `:292,295,306-312` (bracket `.pointTypes/.segmentTypes/.endpoint*.formula`) — supply the membership
    proof as the extra `∈ F` argument, discharged by the probe's conditional lemmas
    (`translateProp35_neg_mem_F_of_closed` with `hNegClosed`, `bracket_pointType_formula_mem_F_of_closed`,
    `bracket_segmentType_formula_mem_F_of_closed`, `endpoint_formula_mem_F_of_closed`), fed the
    Phase-13e-1 `ReadbackClosed`. The leaf proof bodies are otherwise unchanged.
- **Faithfulness anchor:** report-17 §3 Option (a) (the 5-signature weakening + ~7-site membership
  threading) + the probe's `*_of_closed` conditional lemmas (the discharge, now that `ReadbackClosed`
  holds) + report-15 (conclusion-strengthening operating principle: bound the hypothesis, do not invent
  math).
- **Tasks:**
  - [ ] Weaken the ~5 uniform capture signatures to `∀ A ∈ F`; keep `capFn` total.
  - [ ] Weaken the non-uniform mirrors (`translate_correct`, `veeSat_negation`, `efSat_negation_*`) to `∀ A ∈ F`.
  - [ ] Thread membership at the diagonal/existence readback·neg sites via
        `translateProp35_neg_mem_F_of_closed` (+ `hNegClosed`).
  - [ ] Thread membership at the bracket point/segment/endpoint sites via the three bracket `*_of_closed` lemmas.
  - [ ] Re-establish `translate_uniform` + the full uniform stack green under the bounded hypothesis.
- **Split contingency (H8):** if larger than one run, split (2a) `translate_uniform` + δ; (2b) the β/γ
  negation stack (`efSat_negation_*_uniform`, `veeSat_negation_uniform`). Each split lands green off-path.
- **Definition of Done:** the re-derived stack (`translate_uniform` + β/γ/δ, bounded to `∀ A ∈ F`)
  compiles sorry-free, axiom-clean; off the live import path; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` byte-identical to baseline. The bounded signature matches
  `esigmaCapture_canonExpand`'s discharge shape (`𝔈 := F`). If a membership site cannot be discharged by
  the probe's `*_of_closed` lemmas (i.e. Phase 13e-1's `F` is not actually `ReadbackClosed` at that
  site), STOP and surface — do NOT add `sorry`.
- **Timing:** 10-18 hours (~300-600 lines; may split by stack layer).
- **Depends on:** 13e-1 (the readback-closed `F` + `ReadbackClosed`/`hNegClosed`), the B5 probe, 13d
  (the uniform stack being re-derived), 10P.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaUniformExtract.lean` (uniform stack, capture bound),
  - `Prop43Translate.lean`, `VeeSatNegation.lean`, `EFSatNegationGeneral.lean` (non-uniform mirrors),
  - possibly a thin adapter module if in-place weakening is cleaner as an overlay.
- **Prohibited:** no `sorry`/vacuous placeholder; off-path only; do NOT weaken any correctness statement
  or drop a conjunct to force a fit.

---

### Phase 13e-3: ζ — terminal spine wire + retire `KampPrior.lean:562` (terminal, live-path) [NOT STARTED]

- **Goal:** With the readback-closed `F` (13e-1) and the 𝔈-bounded stack (13e-2) landed off-path,
  perform the terminal live-path wire: construct the ζ `canonExpand` (`atomMap = oldPred ∘ g` reconciled
  by Phase-13a `ZetaAtomMapReconcile`, `HasAttainedINF/SUP` from Phase-13b `ZetaPriorTransfer`, lifted
  `psi` from Phase-13c `MonadicFormulaMap`, carrier witness giving `hne : Nonempty N.carrier`); DISCHARGE
  the now-`∀ A ∈ F` capture via the landed 10P `esigmaCapture_canonExpand` (`𝔈 := F`,
  `h𝔈 := subset_rfl`); collapse the conditional β (10b) / γ (11) / δ (12) results — as re-derived in
  13e-2 — to UNCONDITIONAL; apply the Phase-13d uniform extraction to obtain the single `M`-uniform
  formula; wire the Phase-0 semantic `MonadicFormula → characteristic NormalForm` bridge into the live
  spine; re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery`; verify green with `:562` STILL PRESENT; then **delete
  `KampPrior.lean:562` LAST**. This is the ONLY live-path phase and the sole consumer that discharges the
  capture hypothesis.
- **Faithfulness anchor:** report-16 (B1-B4 discharged) + report-17 (B5 bounded resolution over the
  closed `F`) + report-11 Q3/Q4 (`hCapture` at a closed-`F` `canonExpand`) + report-13 (`hne` mandatory)
  + report-07/09 H3 row "Thm 4.4, p.6".
- **Tasks:**
  - [ ] Construct the ζ `canonExpand` on the Phase-13e-1 readback-closed `F` (`𝔈 ⊆ F` = `F ⊆ F`), the
        `atomMap = oldPred ∘ g` from 13a, and the carrier witness giving `hne`.
  - [ ] Discharge the `∀ A ∈ F` capture via `esigmaCapture_canonExpand` (`𝔈 := F, h𝔈 := subset_rfl`);
        feed it into the 13e-2 bounded β/γ/δ + `translate_uniform` stack.
  - [ ] Feed the Phase-13b `HasAttainedINF/SUP`, the Phase-13a-reconciled `atomMap`/collapse, the
        Phase-13c lifted `psi`, and the discharged capture into the conditional results, collapsing every
        orphan to an unconditional fact.
  - [ ] Apply the Phase-13d uniform-extraction lemma to obtain the single `M`-uniform formula.
  - [ ] Wire the Phase-0 semantic object-language bridge into the live spine; re-point
        `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery`.
  - [ ] **Verify the new path is green with the old `:562` sorry STILL PRESENT** (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths` match (all arms + the `:562` sorry + its
        rationale block); update the in-file axiom-audit block and any stale doc-comment refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Definition of Done:** `#print axioms completeness_discrete` no longer lists `sorryAx` (retains
  `propext`, `Classical.choice`, `Quot.sound`, `Lean.ofReduceBool`, `Lean.trustCompiler`); full
  `lake build` EXIT 0; no new axiom/sorry anywhere on the proof term. Hand off to task 375 for the
  terminal audit.
- **Timing:** 10-18 hours (~300-600 lines), plus the `canonExpand` construction + capture-discharge wiring.
- **Depends on:** 13e-1, 13e-2, 13a, 13b, 13c, 13d, 10P, 12, and transitively 10b/11.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (delete the match + `:562` sorry)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-wire + audit block)
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files
- **Prohibited:** no `sorry`/`def := True`/vacuous placeholder on the spine; no reset/checkout; do NOT
  delete `:562` until the new path is proven green end-to-end.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at the current job floor.
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phases 0-12,
      13a-13d, the B5 probe, and Phases 13e-1/13e-2 the axiom set is unchanged (the pre-existing
      `KampPrior.lean:562` `sorryAx` remains, carrying the spine). Target end-state after Phase 13e-3:
      `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no `sorryAx`.
- [ ] The amended sorry gate holds: the only live sorries anywhere are `nf_nvar_exist_all_depths | _k+2`
      (until Phase 13e-3), `EANegation.lean:1090`, and `EANegation.lean:1249`. No phase introduces any
      other sorry. **No new sorry reaches the trusted core before ζ.**
- [ ] **Conditional-result invariant**: the landed β/γ/δ results carrying the capture hypothesis are
      PERMITTED to remain hypothesis-gated (orphan) until Phase 13e-3 discharges it via 10P. After Phase
      13e-2 the gating hypothesis is `∀ A ∈ F` (bounded); this is NOT a sorry and NOT a gate violation.
- [ ] **Incremental-with-fallback**: Phases 13e-1/13e-2 land off the live import path and green BEFORE
      Phase 13e-3 touches the spine; Phase 13e-3 proves the new path green with `:562` still present, then
      deletes the match LAST. Verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, vacuous `F`, or `Prop43Structural.lean`-style hole is
      introduced. **13e-1/13e-2/13e-3 must not be discharged with `sorry`** — an unresolvable prerequisite
      (e.g. no joint fixpoint for the closed `F`) is a STOP-and-surface, not a hole.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number or
      a Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page).
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks (Phases 0-12, 10a, 10b-i, 10b-ii, 10P, 11, 12, 13a-13d already passed and are landed;
the B5 probe is committed RED):
- [ ] Phase 13e-1 (readback-closed `F`): a concrete `F` with `ReadbackClosed` + `hNegClosed` compiles
      sorry-free, axiom-clean, off-path; the alphabet is coherently re-indexed (no strict-mono
      enlargement is triggered because every readback stays in `F`); the landed 13a-13d + β/γ/δ lemmas
      instantiate at the concrete `F`.
- [ ] Phase 13e-2 (𝔈-bounded stack): `translate_uniform` + the β/γ/δ stack, bounded to `∀ A ∈ F`, compile
      sorry-free, axiom-clean, off-path; the four closure obligations are discharged by the probe's
      `*_of_closed` lemmas; the bounded signature matches `esigmaCapture_canonExpand`'s `𝔈 := F` shape.
- [ ] Phase 13e-3 (ζ): the `canonExpand` is constructed, the `∀ A ∈ F` capture is DISCHARGED via 10P, the
      conditional β/γ/δ results collapse to unconditional, the `nf_nvar_exist_all_depths` match (incl.
      `:562`) is DELETED, and `sorryAx` is confirmed absent.

## Artifacts & Outputs

- plans/18_zeta-readback-closed-f-restructure.md (this file)
- LANDED (Phases 0-12, 10a, 10b-i, 10b-ii, 10P, 11, 12, 13a-13d — PRESERVED, do NOT re-execute):
  `Prop35VeeLift.lean`, `HCaptureDischarge.lean`, `ConjInterleave.lean`, `IntervalType.lean`,
  `VeeConj.lean`, `VVecEA2Collapse.lean`, `LiftPair.lean`, `EFSatNegation.lean`,
  `EFSatNegationGeneral.lean`, `ESigmaCapture.lean` (10P), `VeeSatNegation.lean` (γ),
  `Prop43Translate.lean` (δ), `ZetaAtomMapReconcile.lean` (13a), `ZetaPriorTransfer.lean` (13b),
  `MonadicFormulaMap.lean` (13c), `ZetaUniformExtract.lean` (13d), plus the Phase 3-8 partial-interval
  migration of `ExistsForallFormula.lean` / `VeeExistsForall.lean` / `ExistsForallLemmas.lean` /
  `Prop42NegationGeneral.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean` / `Prop42ExistsForall.lean`.
- COMMITTED probe (PRESERVED, RED verdict, do NOT re-run/delete): `ZetaEngineClosure.lean` (the
  conditional `*_of_closed` lemmas + the alphabet-circularity findings).
- New `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules for THIS revision (names provisional):
  the readback-closed `F` construction + `ReadbackClosed`/`hNegClosed` discharge
  (`ZetaReadbackClosure.lean`, Phase 13e-1); the 𝔈-bounded re-derivation of `translate_uniform` + the
  β/γ/δ stack (in-place edits to `ZetaUniformExtract.lean` / `Prop43Translate.lean` /
  `VeeSatNegation.lean` / `EFSatNegationGeneral.lean`, or an overlay module, Phase 13e-2).
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 13e-3 — `canonExpand` construction + capture discharge +
  spine re-point + `nf_nvar_exist_all_depths` deletion).
- summaries/18_zeta-readback-closed-f-restructure-summary.md (on completion)

## Rollback/Contingency

- **Landed Phases 0-12, 10a, 10b-i, 10b-ii, 10P, 11, 12, 13a-13d and the B5 probe:** already green and
  committed; not re-executed. If a later phase surfaces a regression in a landed module, revert to the
  last-green commit — do NOT re-plan the completed phases.
- **Phase 13e-1 (readback-closed `F`) failure:** THIS is the decisive, highest-risk sub-phase. It is
  additive/off-path (a new construction module), so a failed attempt leaves last-green intact. If NEITHER
  construction (i) joint fixpoint nor (ii) depth-bounded closure yields a `ReadbackClosed`-satisfying `F`
  — i.e. no joint fixpoint of formula-set ∧ alphabet exists for this encoding — the obstruction is a
  genuine encoding-level gap beyond faithful repair: STOP and surface for a further `/research` dispatch;
  do NOT force with `sorry` or a vacuous `F`. Because 13e-1 gates 13e-2/13e-3, no downstream work is
  committed against an unreached closure.
- **Phase 13e-2 (𝔈-bounded stack) failure:** additive/off-path; if a membership site cannot be
  discharged by the probe's `*_of_closed` lemmas, that means 13e-1's `F` is not actually `ReadbackClosed`
  at that site — return to 13e-1, do NOT add `sorry`. The signature-weakening is mechanical; a failed
  attempt leaves last-green intact and resumable.
- **Phase 13e-3 regression:** incremental-with-fallback. The new path is proven green with the old `:562`
  sorry still present; the `nf_nvar_exist_all_depths` deletion is done LAST and verified immediately with
  `#print axioms`. If the spine re-wire regresses the build or the axiom set, revert the Phase-13e-3 edits
  (spine re-point + match deletion) to restore the last-green state where all 13e-1/13e-2 lemmas exist but
  the old sorry still carries the spine.
