# Implementation Plan: ζ-Wire B1–B4 Reconciliation — Re-Scoping the BLOCKED Final Spine Wire into Prerequisite Green Lemmas, Retiring `KampPrior.lean:562`

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: ~30-55 hours remaining across 5 not-started prerequisite/wire phases (13a B1 atomMap reconciliation, 13b B2 prior-axiom lift, 13c B3 MonadicFormula signature lift, 13d B4 uniform-formula extraction, 13e final ζ wire) plus ~600-1,000 new Lean lines. **Phases 0-12, 10a, 10b-i, 10b-ii, 10P are ALL COMPLETED, sorry-free, axiom-clean, off the live import path — PRESERVED VERBATIM; do NOT re-execute.**
- **Dependencies**: None to start (all β/γ/δ/capture machinery landed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 13e; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here).
- **Research Inputs**: reports/16_zeta-wire-blocker-probe.lean (AUTHORITATIVE for this revision — the machine-checked, `lake env lean` EXIT 0 probe that proves `False` on the B1 `atomMap` incompatibility and enumerates B1-B4 as the four unlanded ζ-wire obligations); reports/15_exall-gap-monotone-pinning-verdict.md (the H5 divergence-audit verdict closing the Phase-12 δ ex/all cases via monotone pinning + conclusion-strengthening — the model for B4's conclusion-strengthening); reports/14_exall-reordering-closure-resolution.md (path-(c) eval-side closure infrastructure that landed the Phase-12 substrate); reports/13_c1-c2-negation-object-blueprint.md (the arity-0/1 negation-object blueprint + the mandatory `Nonempty N.carrier` signature correction, relevant to B4's `hne` threading); reports/11_esigma-capture-hypothesis-audit.md (the `hCapture`-at-`IntervalType`-level pin, carried forward from plan 11); reports/07_faithful-esigma-negation-path.md (authoritative α-ζ phase structure); reports/09_conjinterleave-interval-type-audit.md (partial-interval adjudication); reports/05_conjunction-closure-load-bearing-verdict.md; reports/06_phase4-unblock-construction.md
- **Artifacts**: plans/17_zeta-wire-b1-b4-reconciliation.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 16_zeta-wire-blocker-probe.lean, 15_exall-gap-monotone-pinning-verdict.md, 14_exall-reordering-closure-resolution.md, 13_c1-c2-negation-object-blueprint.md, 11_esigma-capture-hypothesis-audit.md, 07_faithful-esigma-negation-path.md, 09_conjinterleave-interval-type-audit.md, 05_conjunction-closure-load-bearing-verdict.md, 06_phase4-unblock-construction.md
- **plan_metadata**:
  ```json
  {
    "phases": 17,
    "total_effort_hours": 45,
    "complexity": "complex",
    "research_integrated": true,
    "plan_version": 12,
    "dependency_waves": [[13], [14, 15, 16], [17]],
    "reports_integrated": [
      {"path": "reports/16_zeta-wire-blocker-probe.lean", "integrated_in_plan_version": 12, "integrated_date": "2026-07-19"},
      {"path": "reports/15_exall-gap-monotone-pinning-verdict.md", "integrated_in_plan_version": 12, "integrated_date": "2026-07-19"},
      {"path": "reports/14_exall-reordering-closure-resolution.md", "integrated_in_plan_version": 12, "integrated_date": "2026-07-19"},
      {"path": "reports/13_c1-c2-negation-object-blueprint.md", "integrated_in_plan_version": 12, "integrated_date": "2026-07-19"}
    ]
  }
  ```
  (`plan_version: 12` = predecessor plan-11's version + 1; the `dependency_waves` entries name the NEW active phases 13a-13e using placeholder integers 13-17 for the machine-readable wave grouping — the human-readable wave table under `## Implementation Phases` is authoritative and uses the `13a`-`13e` labels.)

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) still carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of `nf_nvar_exist_all_depths` at `KampPrior.lean:562`. Plan 11 turned
report 07's faithful E[Σ] path (α→β→γ→δ→ζ) into a phased build and, across plans 08-11 plus the
subsequent implementation dispatches, **landed the entire β/γ/δ/capture machinery sorry-free and
axiom-clean off the live import path**: Phases 0-9 (the ε interface, the partial
`IntervalType := Finset UnaryType` migration, the full `conjInterleave_iff`/`veeConj_iff`
biconditionals), Phase 10a (the conditional `vvecea2_collapse_bridge` threading `hCapture`), Phases
10b-i/10b-ii (the `liftPair` arity-lift family + the `efSat_negation_general` β assembly), Phase 10P
(`esigmaCapture_canonExpand`, the `𝔈`-bounded `hCapture` discharge), Phase 11 (γ `veeSat_negation`),
and Phase 12 (δ `translate_correct`, now COMPLETE across all six connective cases including the ex/all
gap disjuncts via the monotone-pinning closure that report 15 prescribed). Every one of these landed
green, sorry-free, axiom-clean (`[propext, Classical.choice, Quot.sound]`), and OFF the live spine, so
`#print axioms completeness_discrete` is byte-identical to baseline
(`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`).

**This revision (plan 17) re-scopes the BLOCKED Phase 13 (ζ) — the final spine wire — after a
machine-checked blocker probe.** Phase 13 as written in plan 11 assumed the landed δ/ε/10P pieces
would compose directly on a single shared `canonExpand`. A dedicated off-graph probe
(`reports/16_zeta-wire-blocker-probe.lean`, compiled under `lake env lean` EXIT 0, which *proves
`False`* on the decisive incompatibility) shows they cannot as scoped. The probe enumerates FOUR
unlanded obligations — the first is a hard type-level incompatibility, not merely a missing proof:

- **B1 (decisive; the probe proves `False`) — `atomMap` incompatibility.** `translate_correct` and
  `prop35_vee_lift` require `h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p` — a
  surjection onto `sig.preds ⊕ {A // A ∈ F}`, so `atomMap` MUST hit `Sum.inr` (the fresh E[Σ] preds).
  But `esigmaCapture_canonExpand` / `temporal_truth_canonExpand` / `canonExpand_atom_named` require
  `atomMap φ = oldPred (g φ) = Sum.inl (g φ)` — `Sum.inl`-only. PROBE 1 derives `False` from `h_surj`
  applied to `esigmaPred A₀`: the witness equality is literally `Sum.inl (g (.atom a)) = Sum.inr ⟨A₀,hA₀⟩`,
  refuted by `Sum.inl_ne_inr`. No single `atomMap` on the shared `canonExpand` satisfies both. Two
  resolution options (the plan must pick/sequence): **(a)** weaken `translate_correct`/`prop35`'s
  `h_surj` to old-preds-only (`Sum.inl`) while still naming the internally-emitted fresh atoms; OR
  **(b)** a "p.6-collapse" unwinding lemma `temporal_truth N atomMap y A ↔ temporal_truth M g y A'`
  that rewrites fresh-pred atoms in the emitted `A` back into their named TL sub-formulas `A'` over
  `M`'s real atoms.
- **B2 — `semantic_prior_UZ/SZ (canonExpand …) atomMap` unlanded** (PROBE 2 GAP-A/A′). `translate_correct`
  needs `HasAttainedINF/SUP N atomMap`; `prior_hasAttainedINF/SUP` reduce these to
  `semantic_prior_UZ/SZ N atomMap`, which no landed lemma establishes for a `canonExpand`. Plausibly
  provable from `M`'s prior axioms + `sat = temporal_truth M g ·`, but unwritten.
- **B3 — no `MonadicFormula` signature lift `sig → sigE sig F`** (grep-clean). `translate_correct`
  consumes `φ : MonadicFormula (sigE sig F) 1`; the target `psi : MonadicFormula sig 1` needs a
  pred-relabelling `MonadicFormula.map (oldPred)` + an `eval`-compatibility (naturality) lemma. No
  `MonadicFormula.map`/`mapPreds` is landed.
- **B4 — per-`M` → `M`-uniform assembly.** `translate` + `prop35_vee_lift` yield an equivalence on ONE
  per-`M` `canonExpand` `N` (formula tied to `N` via chosen `hCapture` witnesses), but
  `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` return a SINGLE formula
  uniform over all `M`. Mitigating fact: the `IntervalType` witness `S = univ.filter (τ a₀ = true)` is
  model-independent, so the emitted formula is morally `N`-independent — but `translate`'s `∃ Ψ`
  statement does not expose that `N`-independence.

**Definition of done (unchanged): `#print axioms completeness_discrete` no longer lists `sorryAx`**,
with the full `lake build` at EXIT 0 and no new axiom or non-permitted sorry anywhere on the proof
term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
Quot.sound]` — with `sorryAx` REMOVED (Phase 13e deletes the sole on-path `KampPrior.lean:562` sorry).

**The re-scoping strategy (this plan):** resolve B1→B4 as **off-path green lemmas BEFORE any spine
edit**, then a single final wire phase. B1 (decisive, gating) is Phase **13a**; B2/B3/B4 (independent
of one another once B1 fixes the `atomMap` interface) run in **parallel** as Phases **13b/13c/13d**;
the terminal live-path wire is Phase **13e**, which constructs the `canonExpand`, discharges
`hCapture` via 10P (`𝔈`-bounded, supplying `𝔈 ⊆ F` + `hne`), collapses the conditional β/γ/δ orphans,
re-points the spine, and **deletes `KampPrior.lean:562` LAST** — only after the new path is proven
green end-to-end with the old sorry still present (incremental-with-fallback). The five landed
completed phases (0-12, 10a, 10b-i, 10b-ii, 10P) are **PRESERVED VERBATIM** below and must NOT be
re-executed.

### Research Integration

- **Report 16 (`reports/16_zeta-wire-blocker-probe.lean`, AUTHORITATIVE for this revision, newly
  integrated)**: the machine-checked ζ-wire viability probe (off-graph; `lake env lean` EXIT 0). PROBE
  1 *proves `False`* from the B1 `atomMap` `Sum.inl`-vs-`Sum.inr` incompatibility; PROBE 2 instantiates
  the per-`M` composition `translate_correct + prop35_vee_lift + esigmaCapture_canonExpand` on
  `N := canonExpand sig F M (temporal_truth M g)` and leaves the unlanded obligations as explicit holes
  (GAP-A/A′ = B2; the `MonadicFormula` arity note = B3; the per-`M` tie = B4). This report is the
  driver: it decomposes the old BLOCKED Phase 13 into the B1-B4 prerequisite phases below. Decisive
  finding: **B1 is a type-level impossibility on a single shared `atomMap`, not a proof gap** — it must
  be resolved by weakening `h_surj` (option a) or a collapse-unwinding lemma (option b) BEFORE the wire.
- **Report 15 (`reports/15_exall-gap-monotone-pinning-verdict.md`, newly integrated)**: the H5
  divergence audit that closed Phase 12's ex/all gap disjuncts. Its decisive move — **strengthen
  `translate_correct`'s conclusion to expose a structural invariant (`∀ ψ ∈ Ψ, StrictMono ψ.pin`) the
  IH already produces but the weaker conclusion hid** — is the exact template for B4 (Phase 13d):
  expose the `N`-independence of the emitted `IntervalType` witnesses by strengthening the correctness
  conclusion, rather than inventing new mathematics. Its postmortem ("the target was never blocked by
  missing mathematics; it was blocked by the correctness statement being one conjunct too weak") is the
  operating principle for the whole ζ re-scope.
- **Report 14 (`reports/14_exall-reordering-closure-resolution.md`, newly integrated)**: established
  path-(c), the eval-side closure infrastructure (`MonadicFormula.rename`/`eval_rename`, `size`/
  `size_rename`, `subst0`/`eval_subst0`, `renamePin`/`veeSat_renamePin`, `insertPerm`) that landed the
  Phase-12 substrate. Its `MonadicFormula.rename` (a `Fin`-arity reindexing with `eval`-naturality) is
  the closest landed analogue for B3's needed **predicate**-relabelling `MonadicFormula.map (oldPred)` +
  its `eval`-compatibility lemma (Phase 13c) — reuse its naturality-proof shape.
- **Report 13 (`reports/13_c1-c2-negation-object-blueprint.md`, newly integrated)**: the arity-0/1
  negation-object blueprint. Its **mandatory `Nonempty N.carrier` correction** (the arity-0 existence
  sentence's negation is provably FALSE without `hne`) is the reason Phase 13e must thread `hne` (a
  `Nonempty N.carrier`, supplied from the `canonExpand`'s carrier witness) into the collapse, alongside
  `𝔈 ⊆ F`. Confirms the reverse Prop 3.5 map is NOT needed — the reverse is discharged semantically by
  `hCapture`, which 10P already provides `𝔈`-boundedly.
- **Report 11 (`reports/11_esigma-capture-hypothesis-audit.md`, carried forward)**: pinned `hCapture` at
  the `IntervalType` level and identified Phase 10P as the discharge prerequisite. Now LANDED
  (`esigmaCapture_canonExpand`, `𝔈`-bounded). Its Q3 finding — `hCapture` is dischargeable ONLY at ζ
  against an `F`-closed `canonExpand` — is exactly what B1/13e must arrange (`𝔈 ⊆ F`).
- **Report 07 (carried forward)**: the faithful α-ζ phase structure; its "Thm 4.4, p.6" H3 row anchors
  Phase 13e's spine rewire + `nf_nvar_exist_all_depths` deletion.
- **Reports 09 / 05 / 06 (carried forward)**: the partial-interval adjudication (Option A, landed
  Phases 3-9), the conjunction-closure load-bearing verdict, and the landed arbitrary-pin Prop 4.2
  engine — all consumed by the now-complete β/γ/δ machinery.

### Prior Plan Reference

Supersedes `plans/11_esigma-capture-threading.md` (which superseded plans 10 → 09 → 08). **Phases 0-12,
10a, 10b-i, 10b-ii, and 10P are carried forward VERBATIM** (all COMPLETED, sorry-free, axiom-clean,
landed green off the live path). Plan 11's Phase 13 (ζ) was recorded [BLOCKED] on the four obligations
report 16 machine-checked; this plan **replaces the single Phase 13 with the sequence 13a → (13b ‖ 13c ‖
13d) → 13e**, each an off-path green lemma except the terminal live-path wire (13e). **Do NOT
re-execute any completed phase.**

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. No roadmap review/update phases are added.

## Goals & Non-Goals

**Goals**:
- **Preserve all landed sorry-free work (Phases 0-12, 10a, 10b-i, 10b-ii, 10P) VERBATIM** — the ε
  interface, the partial `IntervalType` migration, the full `conjInterleave_iff`/`veeConj_iff`, the
  conditional `vvecea2_collapse_bridge`, the `liftPair` family, the `efSat_negation_general` β assembly,
  the `veeSat_negation` γ, the full `translate_correct` δ (all six cases), and the `𝔈`-bounded
  `esigmaCapture_canonExpand` `hCapture` discharge. Do NOT re-execute them.
- **Resolve B1 (Phase 13a, decisive/gating)**: pick option (a) `h_surj` weakening to old-preds-only or
  option (b) the p.6-collapse unwinding lemma; land the exact new/weakened signature and the
  reconciliation of `atomMap` (`Sum.inl` vs the fresh-atom naming) as an off-path green lemma.
- **Resolve B2 (Phase 13b)**: land `semantic_prior_UZ/SZ (canonExpand …) atomMap` (whence
  `HasAttainedINF/SUP` via `prior_hasAttainedINF/SUP`) from `M`'s prior axioms.
- **Resolve B3 (Phase 13c)**: land the `MonadicFormula` signature lift `sig → sigE sig F`
  (`MonadicFormula.map`/`mapPreds` via `oldPred`) + its `eval`-naturality lemma.
- **Resolve B4 (Phase 13d)**: land the per-`M` → `M`-uniform formula extraction, exploiting the
  model-independent `IntervalType` witness `S = univ.filter (τ a₀ = true)`; if needed, strengthen
  `translate_correct`'s conclusion to expose the `N`-independent formula (the report-15 conclusion-
  strengthening technique).
- **Wire ζ (Phase 13e, terminal, live-path)**: construct the `canonExpand`, discharge `hCapture` via
  10P (`𝔈`-bounded; supply `𝔈 ⊆ F` + `hne`), collapse the conditional β/γ/δ orphans to unconditional,
  re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery`, and **delete `KampPrior.lean:562` LAST** — only after the new path
  is green with the old sorry still present. End with `#print axioms completeness_discrete` showing no
  `sorryAx`.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor headers
  only; Rabinovich cited by PDF page, never line number).

**Non-Goals**:
- Introducing any novel mathematics or Feferman-Vaught composition. B1-B4 are interface-reconciliation
  and uniformity-exposure work over the already-landed faithful machinery, not new content.
- Any arity-4 realization engine, joint-type-over-a-tuple, or `chain_split` (NON-APPLICABLE).
- Touching `EANegation.lean:1090` / `:1249` (zero external consumers, off the proof term) or rebuilding
  `Kamp/NfEFold.lean`; no `nf_eval_efold` / `nf_eval_nfk_iff_efold`.
- The terminal `#print axioms` final-assembly audit (task 375) and arity-4 apparatus archival (task 359).
- Any `sorry` outside the amended sorry gate below, any `def X := True`, vacuous placeholder, or
  `Prop43Structural.lean`-style hole. In particular, **B1-B4 must NOT be discharged with `sorry` on the
  spine** — if a prerequisite cannot close, STOP and surface for a further `/research` dispatch.

## Binding Constraints (carry into EVERY phase)

- **FAITHFULNESS TO RABINOVICH IS ESSENTIAL. NO NOVEL MATHEMATICS, NO FEFERMAN-VAUGHT.** Every
  construction traces to a report-16/15/14/13/11/09/07 finding or a report H3 table row.
- **Cite Rabinovich BY PDF PAGE ONLY**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
  The companion `.md` is CORRUPT and must not be used.
- **Anchor code by DECLARATION NAME, never line number. NO TASK-NUMBER POINTERS in `Theories/**/*.lean`.**
- **`chain_split` is NON-APPLICABLE.** Do NOT touch `EANegation.lean:1090` / `:1249`. Do NOT rebuild
  `Kamp/NfEFold.lean`.
- **AMENDED SORRY GATE.** The only permitted live sorries anywhere in the build are:
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 13e), `EANegation.lean:1090`, and
  `EANegation.lean:1249`. No phase may introduce any other sorry or any new axiom.
- **INCREMENTAL-WITH-FALLBACK.** Every B1-B4 lemma lands off-path and green (full `lake build` EXIT 0,
  `#print axioms completeness_discrete` byte-identical to baseline) BEFORE Phase 13e touches the spine.
  In Phase 13e, the new path is proven green with the old `:562` sorry STILL PRESENT (spine carried by
  fallback); only then is the `nf_nvar_exist_all_depths` match deleted LAST.
- **`hCapture` is threaded, not re-derived.** The β/γ/δ results carry `hCapture` as an explicit
  hypothesis; Phase 13e discharges it via the landed `𝔈`-bounded `esigmaCapture_canonExpand`. Relax the
  β/γ/δ `hCapture` argument to the `𝔈`-bounded (`∀ A ∈ 𝔈`, or `∀ A ∈ F`) form at the ζ application site
  — this is a Phase-13e wiring concern, not a re-open of 10P (see Phase 10P's Phase-13 interface note).
- **Point types stay complete `UnaryType`; only interval types are partial `Finset UnaryType`.**

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| B1 has no faithful resolution (both option (a) `h_surj` weakening and option (b) collapse-unwinding fail) | H | M | This is the decisive, highest-risk phase (Phase 13a). Report 16 PROBE 1 proves the incompatibility is real, so a naive single-`atomMap` wire is impossible — but BOTH options are faithful repairs, not new math: (a) `translate`/`prop35` only ever *name* fresh atoms internally; the `h_surj` requirement can be split into "old preds are named by real atoms" (kept) + "fresh preds are named by the engine's own emission" (internal, not a caller obligation). (b) the p.6-collapse is exactly Rabinovich's definitional atom-collapse (Def 4.1) at the wire seam. Prefer (a) if the internal fresh-atom naming is already available from `esigmaPred`; fall back to (b). If NEITHER closes, STOP and surface for a `/research` dispatch — do NOT force with `sorry`. Bound each sub-lemma to one agent run. |
| B1's chosen resolution changes the `atomMap` interface that B2/B3/B4 target, forcing rework | M | M | 13a GATES 13b/13c/13d precisely to avoid this: B1's landed signature (weakened `h_surj` shape, or the collapse-unwinding target) is the fixed interface B2/B3/B4 build against. Do NOT start 13b/13c/13d until 13a's signature is committed green. |
| B2 (`semantic_prior_UZ/SZ` on `canonExpand`) hides a deep expressiveness wall | M | L | Report 16 PROBE 2 marks it "plausibly provable from `M`'s prior axioms + `sat = temporal_truth M g ·`". The `canonExpand`'s order is `M`'s order and its interpretation factors through `oldPred`, so the prior axioms transfer along `sat`. If it does not close directly, it is a transfer-plumbing defect, not new math — fix the transfer, do NOT add `sorry`. |
| B3 (`MonadicFormula.map`/`mapPreds` + eval-naturality) is larger than one run | M | L | It mirrors the landed `MonadicFormula.rename`/`eval_rename` (report 14, path-(c)): a structural recursion over `MonadicFormula` relabelling the predicate slot via `oldPred`, with an `eval`-naturality proof by the same induction. Reuse that proof shape verbatim. Split into `map` def + `map_eval` lemma if it overflows. |
| B4 (per-`M` → uniform) needs a genuine uniformity argument the new path does not expose | H | M | Report 15's postmortem is the operating model: the obstruction is a too-weak conclusion, not missing math. The `IntervalType` witness `S = univ.filter (τ a₀ = true)` IS model-independent (report 16 B4 "encouraging"). Mitigation: strengthen `translate_correct`'s conclusion (analogous to report 15's `StrictMono ψ.pin` strengthening) to expose an `N`-independent `Ψ`, then extract the single uniform formula. If the `N`-independence cannot be exposed by conclusion-strengthening, STOP and surface — do NOT force uniformity with `sorry`. |
| Phase 13e live-path rewire regresses the spine or fails to remove `sorryAx` | H | M | Incremental-with-fallback (binding constraint): prove the new path green with `:562` still present; delete `nf_nvar_exist_all_depths` LAST and verify immediately with `#print axioms`. Rollback = revert the Phase-13e spine re-point + match deletion to last-green (all B1-B4 lemmas present, old sorry intact). |
| A `hCapture` `𝔈`-boundedness mismatch at the ζ site (β threads `∀ A`, 10P discharges `∀ A ∈ 𝔈`) | M | L | Known and scoped (Phase 10P's Phase-13 interface note): the full `∀ A` form is undischargeable for temporally-reaching `A ∉ F`; ζ consumes the `𝔈`-bounded form. Phase 13e relaxes the β/γ/δ `hCapture` argument to `∀ A ∈ 𝔈` (or `∀ A ∈ F`) at the application site, or wraps. Plumbing, not a 10P re-open. |
| Off-paper mathematics or a task-number/line-number citation slips into a `Theories/` file | H | L | Per-phase faithfulness anchor to a named report finding; durable-anchor headers only; Rabinovich cited by PDF page. |

## Implementation Phases

**Dependency Analysis** (Phases 0-12, 10a, 10b-i, 10b-ii, 10P are LANDED/COMPLETED — shown for
provenance; the active waves are the ζ re-scope 13a → (13b ‖ 13c ‖ 13d) → 13e):

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
| **12** | **13a (B1 — decisive/gating)** | 12, 10b, 10P (landed) | NOT STARTED (resumes here) |
| **13** | **13b (B2), 13c (B3), 13d (B4)** | 13a | NOT STARTED |
| **14** | **13e (final ζ wire — live path)** | 13a, 13b, 13c, 13d, 10P, 12 | NOT STARTED |

Phases within the same wave can execute in parallel. **All phases through Phase 12 (including 10a,
10b-i, 10b-ii, 10P) are sorry-free and landed — do NOT re-execute them.** Implementation resumes at Wave
12. **The next implementable dispatch is Phase 13a** (the decisive B1 `atomMap` reconciliation), which
gates everything: its committed signature is the fixed interface Phases 13b/13c/13d build against.
Phases 13b/13c/13d are mutually independent and run in PARALLEL once 13a lands. Phase 13e is the ONLY
live-path phase; through Phase 13d the spine and `#print axioms completeness_discrete` are UNCHANGED
(the `KampPrior.lean:562` `sorryAx` remains the sole on-path sorry until Phase 13e deletes it).

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
`hCapture` (permitted; discharged at ζ).

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
which ζ arranges by construction.

**Phase-13 interface note (LOAD-BEARING for Phase 13a/13e):** the discharge is `𝔈`-bounded
(`∀ A ∈ 𝔈`); the landed β signature threads `∀ A : Formula`. The full `∀ A` form is genuinely
undischargeable for temporally-reaching `A ∉ F` (report R1), so ζ must consume the `𝔈`-bounded form —
relax the β/γ/δ `hCapture` argument to `∀ A ∈ 𝔈` (or `∀ A ∈ F`) at the ζ application site, or wrap.
**Critically, the `atomMap` this discharge requires is `oldPred ∘ g` (`Sum.inl`-only)** — which is
exactly the B1 incompatibility Phase 13a must reconcile against `translate`/`prop35`'s `h_surj`.

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
- **Depends on:** 1. May run in parallel with 10a/10b/11/12. **Blocks Phase 13e.**
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaCapture.lean` (new).
- **Completed:** 2026-07-18.

---

### Phase 11: γ — ∨∃∀ negation [COMPLETED]

Landed `veeSat_negation` in `VeeSatNegation.lean`, sorry-free, axiom-clean `[propext, Classical.choice,
Quot.sound]`, off the live import path, threading the same `N / atomMap / h_surj / h_INF / h_SUP` AND
`hCapture` hypotheses β carries (a CONDITIONAL orphan until ζ). Faithful to Prop 4.3's
disjunction-negation sub-case (p.6): `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by β (via the 10a
collapse bridge); reassembled via the landed `veeConj_iff` (Phase 9). No `VVecEA2`-level rebuild
(the Option-1 payoff).

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
same arity `m`; the only arity change is the ex/all binder's `m+1 → m` drop).

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

- **Goal:** Resolve the decisive B1 incompatibility (report 16 PROBE 1, which proves `False`): no single
  `atomMap` on the shared `canonExpand` can satisfy both `translate_correct`/`prop35_vee_lift`'s
  `h_surj` (surjection onto `sig.preds ⊕ {A // A ∈ F}`, requiring `Sum.inr` hits) and
  `esigmaCapture_canonExpand`/`temporal_truth_canonExpand`'s `atomMap = oldPred ∘ g` (`Sum.inl`-only).
  Land the reconciliation as an OFF-PATH green lemma whose committed signature becomes the fixed
  interface for Phases 13b/13c/13d. This is the highest-risk phase; size each sub-lemma as one bounded
  agent run.
- **Decision (pick one; sequence within this phase):**
  - **Option (a) — weaken `h_surj` to old-preds-only.** Generalize `translate_correct` and
    `prop35_vee_lift` to require `h_surj` only on the `Sum.inl` old preds (`∀ p : sig.preds, ∃ a,
    atomMap (.atom a) = oldPred p`), while the internally-emitted fresh E[Σ] atoms are named by the
    engine's own `esigmaPred` emission (not a caller obligation). Verify `translate`/`prop35` never
    actually use `h_surj` at a `Sum.inr` pred (grep + goal inspection at each `h_surj` use site).
  - **Option (b) — p.6-collapse unwinding lemma.** Prove
    `temporal_truth N atomMap y A ↔ temporal_truth M g y A'`, rewriting fresh-pred atoms in the emitted
    `A` back into their named TL sub-formulas `A'` over `M`'s real atoms (Rabinovich Def 4.1 atom-collapse
    at the wire seam), so the `Sum.inl`-only `atomMap` suffices end-to-end.
- **Faithfulness anchor:** report-16 B1 (PROBE 1 `False`, the two named resolution options) + report-11
  Q3/Q4 (`hCapture` at a closed-`F` `canonExpand`) + Rabinovich Def 4.1 atom-collapse (PDF p.5-6).
- **Tasks:**
  - [x] Audit every `h_surj` use site in `translate_correct` / `prop35_vee_lift` (grep + `lean_goal`);
        determine whether any consumes `h_surj` at a `Sum.inr` pred. Record the verdict.
        *(VERDICT: genuine `Sum.inr` use EXISTS. The top-level elimination site
        `Prop43Translate.lean:568` applies `h_surj` to a generic `p : (sigE sig F).preds`; the
        decisive unavoidable consumption is deeper — `translateProp35 → efIntervalTP/efPointTP →
        unaryToFormula → nf_depth0_char_formula → nfPred` NAMES every predicate of a
        `UnaryType`/`IntervalType`, including the fresh `Sum.inr` E[Σ] atoms. → option (b).)*
  - [ ] ~~If no `Sum.inr` use exists → option (a)~~ *(not taken: option (a) INFEASIBLE — a
        weakened old-preds-only `h_surj` cannot supply naming atoms for the fresh E[Σ] atoms the
        emitted-formula construction genuinely renders; `Sum.inr ⟨A,hA⟩ ≠ oldPred q`.)*
  - [x] Pursue **option (b)**: state and prove the p.6-collapse unwinding lemma
        `temporal_truth N atomMap y A ↔ temporal_truth M g y (collapseSubst θ A)` for the emitted `A`.
        *(landed as `temporal_truth_collapse` in `ZetaAtomMapReconcile.lean`, sorry-free.)*
  - [x] Land the reconciliation as a named off-path lemma; commit its signature (the fixed B2/B3/B4
        interface). *(`collapseSubst`, `temporal_truth_collapse`, `collapse_leaf_atom_oldPred`,
        `collapse_leaf_fresh`, `reconciled_no_surj_onto_inr` — the committed interface.)*
  - [x] Re-run report 16's PROBE 1 shape against the new signature to confirm the `False` derivation
        no longer type-checks. *(`reconciled_no_surj_onto_inr`: the reconciled `Sum.inl`-only
        `atomMap = oldPred∘g` captures each fresh pred by unwinding to the named formula via
        `canonExpand_atom_named`, imposing no surjectivity-onto-`Sum.inr` obligation; PROBE 1's
        `Sum.inl_ne_inr` `False` is never instantiated.)*
- **Definition of Done:** the reconciliation lemma / generalized signatures compile sorry-free,
  axiom-clean (`[propext, Classical.choice, Quot.sound]` or subset); off the live import path; full
  `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline. If NEITHER
  option closes, STOP and surface for a further `/research` dispatch — do NOT add `sorry`.
- **Timing:** 10-18 hours (~200-450 lines; highest-risk, per-sub-lemma bounded runs).
- **Depends on:** 12, 10b (β/δ signatures), 10P (the `oldPred∘g` `atomMap` shape). GATES 13b/13c/13d.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean` and/or `Prop35VeeLift.lean`
    (generalized `h_surj`, option a), OR a new `ZetaAtomMapReconcile.lean` (the unwinding lemma, option b).
- **Prohibited:** no `sorry`/`def := True`/vacuous placeholder; no spine edit (off-path only).

---

### Phase 13b: B2 — `semantic_prior_UZ/SZ (canonExpand …) atomMap` [COMPLETED]

- **Goal:** Land `semantic_prior_UZ (canonExpand sig F M sat) atomMap` and
  `semantic_prior_SZ (canonExpand sig F M sat) atomMap` (report 16 PROBE 2 GAP-A/A′), whence
  `HasAttainedINF/SUP (canonExpand …) atomMap` follow via the landed `prior_hasAttainedINF/SUP`. These
  are the `HasAttainedINF/SUP` hypotheses `translate_correct` consumes.
- **Mechanism (report 16 "plausibly provable"):** transport `M`'s prior axioms along
  `sat = temporal_truth M g ·` and the `canonExpand`'s order (= `M`'s order) + interpretation (factors
  through `oldPred`, the `atomMap` fixed by Phase 13a). No new expressiveness content — a transfer proof.
- **Faithfulness anchor:** report-16 B2 (PROBE 2 GAP-A/A′) + the landed `PriorINF` `prior_hasAttainedINF/SUP`.
- **Tasks:**
  - [x] State `semantic_prior_UZ (canonExpand sig F M sat) atomMap` for the Phase-13a `atomMap`.
        *(landed as `canonExpand_semantic_prior_UZ`, `ZetaPriorTransfer.lean`)*
  - [x] Prove it by transporting `M`'s `semantic_prior_UZ` along `sat`/`oldPred`.
        *(transport via `temporal_truth_canonExpand`; carrier+order inherited verbatim)*
  - [x] Do the same for `semantic_prior_SZ`. *(`canonExpand_semantic_prior_SZ`)*
  - [x] Derive `HasAttainedINF/SUP (canonExpand …) atomMap` via `prior_hasAttainedINF/SUP`; expose as
        the two named lemmas Phase 13e feeds to β/δ.
        *(`canonExpand_hasAttainedINF` / `canonExpand_hasAttainedSUP`)*
- **Outcome (COMPLETED):** New off-path module
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaPriorTransfer.lean` (imports `ESigmaCapture` +
  `PriorINF`). Four lemmas sorry-free, axioms `[propext, Classical.choice, Quot.sound]` (no
  `sorryAx`). Nothing imports the module (off-path); `KampPrior.lean:562` spine untouched. Full
  `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.
- **Definition of Done:** both prior-axiom lemmas + the two `HasAttained*` derivations compile
  sorry-free, axiom-clean; off the live import path; full `lake build` EXIT 0; `#print axioms
  completeness_discrete` unchanged. If the transfer does not close, it is a plumbing defect — fix the
  transfer, do NOT add `sorry`.
- **Timing:** 6-10 hours (~150-300 lines).
- **Depends on:** 13a (the fixed `atomMap` interface). Parallel with 13c, 13d.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaCapture.lean` (extend) or a new
    `ZetaPriorTransfer.lean` (name provisional).
- **Prohibited:** no `sorry`/vacuous placeholder; off-path only.

---

### Phase 13c: B3 — `MonadicFormula` signature lift `sig → sigE sig F` + eval-naturality [COMPLETED]

- **Goal:** Land the predicate-relabelling lift `MonadicFormula.map`/`mapPreds : (sig.preds →
  (sigE sig F).preds) → MonadicFormula sig m → MonadicFormula (sigE sig F) m` (specialized at `oldPred`)
  + its `eval`-naturality lemma, so the target `psi : MonadicFormula sig 1` moves into
  `translate_correct`'s domain `MonadicFormula (sigE sig F) 1` with truth preserved (report 16 B3,
  grep-clean gap).
- **Mechanism (reuse the landed path-(c) shape, report 14):** structural recursion over `MonadicFormula`
  relabelling the predicate slot via the given map, with `eval`-naturality proved by the same induction
  as the landed `MonadicFormula.rename`/`eval_rename`. `eval M env psi ↔ eval (canonExpand …)
  env (psi.mapPreds oldPred)` (up to the `oldPred`/`sat` conservativity `temporal_truth_canonExpand`
  already landed in 10P).
- **Faithfulness anchor:** report-16 B3 + report-14 path-(c) `MonadicFormula.rename`/`eval_rename` (the
  naturality-proof template).
- **Tasks:**
  - [x] Define `MonadicFormula.mapPreds` (structural recursion; relabels the atom/predicate slot).
  - [x] Prove `mapPreds_eval` (eval-naturality) by induction, mirroring `eval_rename`.
  - [x] Specialize at `oldPred` and connect to the `canonExpand` conservativity
        (`temporal_truth_canonExpand`, landed 10P) so `eval M env psi` transfers to the lifted formula on `N`. *(Landed as `mapPreds_eval` (`=` form) + `mapPreds_eval_iff` (`↔` form) in `MonadicFormulaMap.lean`; old-predicate conservativity is definitional (`interp (oldPred p) = M.interp p`), the syntactic face of `temporal_truth_canonExpand`'s temporal-atom collapse.)*
- **Definition of Done:** `mapPreds` + `mapPreds_eval` compile sorry-free, axiom-clean; off the live
  import path; full `lake build` EXIT 0; `#print axioms completeness_discrete` unchanged.
- **Timing:** 6-10 hours (~150-300 lines; split `map` def / `map_eval` lemma if it overflows one run).
- **Depends on:** 13a (the fixed `atomMap`/`oldPred` interface). Parallel with 13b, 13d.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` — extend the `MonadicFormula` module hosting
    `rename`/`eval_rename`, or a new `MonadicFormulaMap.lean` (name provisional).
- **Prohibited:** no `sorry`/vacuous placeholder; off-path only.

---

### Phase 13d: B4 — per-`M` → `M`-uniform formula extraction [COMPLETED]

**COMPLETED (session sess_1784446774_b4ac7c):** N-independence VERDICT recorded and machine-checked
(task 1 DONE); the full `∃Ψ`-outside-`∀N` uniform `translate` (tasks 2-4) is now landed green,
sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`, off-path in
`Kamp/ZetaUniformExtract.lean`. The re-thread went through the *entire* negation stack as a bounded
mechanical copy: `prop42_efSat_negation_general_uniform` (model-independent `VVecEA2` witness) →
`vvecea2_collapse_bridge_uniform` (per-clause reverse translation inlined) →
`efSat_negation_pair_uniform` → `efSat_negation_general_uniform` (De Morgan trichotomy) →
`veeSat_negation_uniform` (γ) → `ex_closure_translate_uniform` → `translate_uniform` (δ,
well-founded recursion on `MonadicFormula.size`). Atoms use the model-independent `capType` base
case (`atomEmit_capType_iff`); all model-dependence (`hCapFn`/`h_INF`/`h_SUP`/`hne`) threaded inside
`∀N`. Commits `7e055cafa` (13d.1), `0f4f71b21` (13d.2), `a7c601fc9` (13d.3), `5f5198d85` (13d.4).
Full `lake build` EXIT 0; `#print axioms completeness_discrete` byte-identical to baseline;
`KampPrior.lean:562` spine UNTOUCHED. Phase 13e (terminal ζ wire) remains: discharge `capFn`
`𝔈`-boundedly via `esigmaCapture_canonExpand` and wire `translate_uniform` into the spine.

- **Goal:** Bridge the uniformity gap (report 16 B4): `translate` + `prop35_vee_lift` yield an
  equivalence on ONE per-`M` `canonExpand` `N`, but `kamp_prior_expressive_completeness` /
  `US_expressively_complete_over_prior` return a SINGLE formula uniform over all `M`
  (`{ A : Formula // ∀ M … }`). Land the extraction of the `M`-uniform formula as an off-path green
  lemma, exploiting that the emitted `IntervalType` witness `S = univ.filter (τ a₀ = true)` is
  model-independent.
- **Mechanism (report 15 conclusion-strengthening technique):** the obstruction is a too-weak
  conclusion, not missing math. Strengthen `translate_correct`'s (and/or `prop35_vee_lift`'s) conclusion
  to expose an `N`-independent `Ψ` (the emitted formula's `IntervalType` witnesses are chosen by
  `univ.filter`, which does not mention `N`), analogous to report 15's `∀ ψ ∈ Ψ, StrictMono ψ.pin`
  strengthening for the Phase-12 ex/all closure. From the `N`-independent `Ψ`, extract the single
  `{ A : Formula // ∀ M … }` formula and prove its cross-`M` correctness.
- **Faithfulness anchor:** report-16 B4 (the model-independent `S = univ.filter (τ a₀ = true)` witness)
  + report-15 §5 (the conclusion-strengthening postmortem: "one conjunct too weak").
- **Tasks:**
  - [x] Verify (grep + `lean_goal`) that every `IntervalType`/point-type witness `translate`/`prop35`
        emits is chosen `N`-independently (via `univ.filter` on the characteristic-type predicate).
        *(DONE — VERDICT: YES. Every witness is an `S` from `hCapture`; `intervalCapture_of_atomNamed`
        always chooses `S = univ.filter (τ a₀ = true)`. Machine-checked at the predicate level as
        `intervalHolds_capType` (generic over every `N` over `sigE`), sorry-free.)*
  - [x] Strengthen the correctness conclusion to expose the `N`-independent `Ψ` *(DONE for the atom
        base case (`atomEmit_capType_iff`) and the negation leaves (`efSat_negation_diagonal_uniform`,
        `efSat_negation_existence_uniform`): `∃Ψ`-outside-`∀N` via a functional capture `capFn`.)*
  - [ ] Re-thread the strengthened conclusion through the landed β/γ/δ cases *(deviation: PARTIAL —
        leaves done; the full `efSat_negation_pair`/`_general`/`veeSat_negation`/`translate` re-thread
        remains, a bounded mechanical copy larger than one safe dispatch.)*
  - [ ] Extract the single `M`-uniform formula and prove its `∀ M` correctness (cross-`M` transfer).
        *(deviation: blocked on the previous item; not the math — the N-independence is proven.)*
- **Definition of Done:** the uniformity-extraction lemma compiles sorry-free, axiom-clean; off the live
  import path; full `lake build` EXIT 0; `#print axioms completeness_discrete` unchanged. If the
  `N`-independence cannot be exposed by conclusion-strengthening, STOP and surface — do NOT force
  uniformity with `sorry`.
- **Timing:** 8-14 hours (~200-400 lines; may require re-threading the strengthened conclusion through
  several landed cases).
- **Depends on:** 13a (the fixed `atomMap` interface). Parallel with 13b, 13c. (Consumes the shapes of
  13b/13c results conceptually, but its own proof is independent; final composition is Phase 13e.)
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean` / `Prop35VeeLift.lean`
    (conclusion strengthening) and/or a new `ZetaUniformExtract.lean` (name provisional).
- **Prohibited:** no `sorry`/vacuous placeholder; off-path only.

---

### Phase 13e: ζ — final spine wire + retire `KampPrior.lean:562` (terminal, live-path) [BLOCKED]

**BLOCKER** (Phase 13e — capture-hypothesis bound mismatch; machine-checked, no spine edit made):

- **What failed**: The terminal wire cannot feed the discharged `hCapture` into the landed β/γ/δ +
  `translate_uniform` stack (mission step 3). The landed lemmas require an **unbounded** capture
  hypothesis; the only discharge available (10P) is **𝔈-bounded**; the unbounded form is
  mathematically **false** on the target `canonExpand`.
- **Exact type mismatch** (verbatim from source):
  - `translate_uniform` (ZetaUniformExtract.lean:638), `translate_correct` (Prop43Translate.lean:552),
    `veeSat_negation` (VeeSatNegation.lean:99), `efSat_negation_general` (EFSatNegationGeneral.lean:377)
    all bind
    `hCapture : ∀ A : Formula, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A`
    (unbounded over **all** `A : Formula`; for `translate_uniform` the functional `capFn` form threaded inside `∀N`).
  - `esigmaCapture_canonExpand` (ESigmaCapture.lean:207) yields only
    `∀ A ∈ 𝔈, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A`
    for a finite `𝔈 ⊆ F`. `∀ A ∈ 𝔈, P A` does not yield `∀ A : Formula, P A`.
- **Why the unbounded form is false (not merely unproven)**: `intervalHolds N S` is exactly membership
  in a union of complete-1-type F-cells. A TL formula `A` with genuine temporal reach outside `F`
  (`untl`/`snce`) has a truth set that is not such a union (documented in ESigmaCapture.lean:204-205,
  report R1). So no `capFn`/`S` realizes the biconditional for all `A`, on `canonExpand … atomMap`
  with `atomMap = oldPred∘g` (13a). The unbounded `hCapture` is unsatisfiable on the target model.
- **Why the plan's "relax to ∀ A ∈ 𝔈 (or wrap)" is not a wrap**: the formulas the uniform stack feeds
  to `hCapFn` internally (ZetaUniformExtract.lean:135,168,292,295,306-312,351,440-449) are
  `TemporalPred.formula` fields. `TemporalPred` (ExistsForallNF.lean:49) is
  `structure TemporalPred where formula : Formula` — a bare `Formula` with **no `∈ F` witness** —
  and the De Morgan negation stack (`.neg`/`.conj`) plus the bracket point/segment/endpoint types
  (themselves temporal predicates) produce composites that are **not** members of `F`. No
  engine-output-closure membership lemma exists (grep for `… ∈ F` on `translateProp35` /
  `bracket.pointTypes.formula` / `segmentTypes.formula` returned nothing). Relaxing the signatures to
  `∀ A ∈ 𝔈` therefore fails at every internal application site for lack of a threadable membership
  proof.
- **What was tried (read-only, no spine edit)**: full spine-chain map
  (`completeness_discrete → countermodel_discrete_reynolds_v2 → limitdom_is_good →
  no_gaps_discrete_model_surgery → …gap_formula_R… → US_expressively_complete_over_prior →
  kamp_prior_expressive_completeness → nf_characterizable_temporal_prior → nf_nvar_exist_all_depths_fn →
  :562`); verbatim signatures of all 13a/13b/13c/13d/10P lemmas + β/γ/δ + `canonExpand`; confirmation
  that `translate_uniform` has no consumers yet (13e is first); confirmation `TemporalPred` carries no
  membership; confirmation no closure lemmas exist. Cleanest splice point identified:
  `US_expressively_complete_over_prior` (PriorExpressiveness.lean:359, one-line delegator) or
  `nf_characterizable_temporal_prior` (KampPrior.lean:614).
- **Root cause**: the landed 13d/12/11/10b stack was proven against the **unbounded** capture
  hypothesis, which is strictly stronger than (and on `canonExpand` false relative to) what 10P can
  discharge. Faithful retirement of `:562` requires **re-deriving** the uniform negation+translate
  stack (ZetaUniformExtract, VeeSatNegation, EFSatNegationGeneral, Prop43Translate) under an
  **𝔈-bounded** capture hypothesis, plus new engine-output-closure infrastructure so every formula
  reaching the capture is a **named `∈ F` atom** carrying its membership (i.e. `TemporalPred` — or the
  bracket/point/segment carriers — must thread an `A ∈ F` witness). This is a multi-file re-derivation,
  not a single-dispatch terminal wire, and could surface further gaps (whether each engine construction
  is provably `∈ F` under a constructible finite closure `F`).
- **What is needed to unblock**: a new planning round that adds, as prerequisites BEFORE the ζ wire,
  (1) an 𝔈-bounded restatement of `translate_uniform` and the β/γ/δ stack (capture hypothesis
  `∀ A ∈ 𝔈` with `𝔈 ⊇` every formula the stack feeds to capture), and (2) engine-output-closure
  membership lemmas threading `∈ F` witnesses through `TemporalPred`/bracket/De-Morgan constructions.
  Only then can 13e feed 10P's discharge in. Do NOT relax by weakening any correctness statement or by
  a `sorry`.
- **Prohibited / respected**: no `sorry`, no `def := True`, no vacuous placeholder added; `:562` NOT
  deleted; NO `.lean` file modified; build remains at the committed green baseline; `#print axioms
  completeness_discrete` unchanged from baseline `[propext, sorryAx, Classical.choice,
  Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.

- **Goal:** With B1-B4 resolved off-path (Phases 13a-13d), perform the terminal live-path wire:
  construct the ζ `canonExpand`, DISCHARGE `hCapture` via the landed 10P `esigmaCapture_canonExpand`
  (`𝔈`-bounded; supply `𝔈 ⊆ F` and `hne : Nonempty N.carrier` from the carrier witness), collapse the
  conditional β (10b) / γ (11) / δ (12) results to UNCONDITIONAL, re-point
  `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` onto the Phase-12 `translate` + Phase-1 Prop 3.5 lift + Phase-1
  `hcapture` (NormalForm) discharge + the Phase-0 semantic `MonadicFormula → characteristic NormalForm`
  bridge, all via the B1-B4 reconciliations, and **delete `KampPrior.lean:562` LAST**. This is the ONLY
  live-path phase and the sole consumer that discharges `hCapture`.
- **Faithfulness anchor:** report-16 (B1-B4 discharged) + report-11 Q3/Q4 (`hCapture` at a closed-`F`
  `canonExpand`) + report-13 (`hne` mandatory) + report-07/09 H3 row "Thm 4.4, p.6".
- **Tasks:**
  - [ ] Construct the ζ `canonExpand` with `F` closed under the engine outputs (`𝔈 ⊆ F`, 10P P-a shape),
        the `atomMap = oldPred ∘ g` fixed by Phase 13a, and the carrier witness giving `hne`.
  - [ ] Discharge `hCapture` (`𝔈`-bounded) via `esigmaCapture_canonExpand`; relax the β/γ/δ `hCapture`
        argument to the `∀ A ∈ 𝔈` (or `∀ A ∈ F`) form at the application site (or wrap).
  - [ ] Feed the Phase-13b `HasAttainedINF/SUP`, the Phase-13a-reconciled `h_surj`/collapse, the
        Phase-13c lifted `psi`, and the discharged `hCapture` into the conditional β/γ/δ results,
        collapsing every orphan to an unconditional fact.
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
- **Timing:** 10-18 hours (~300-600 lines), plus the `canonExpand` construction + `hCapture` discharge wiring.
- **Depends on:** 13a, 13b, 13c, 13d, 10P, 12, and transitively 10b/11 (the conditional results it collapses).
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (delete the match + `:562` sorry)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-wire + audit block)
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files
- **Prohibited:** no `sorry`/`def := True`/vacuous placeholder on the spine; no reset/checkout; do NOT
  delete `:562` until the new path is proven green end-to-end.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at 1769 jobs (or the current floor).
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phases 0-12
      and 13a-13d the axiom set is unchanged (the pre-existing `KampPrior.lean:562` `sorryAx` remains,
      carrying the spine). Target end-state after Phase 13e:
      `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no `sorryAx`.
- [ ] The amended sorry gate holds: the only live sorries anywhere are `nf_nvar_exist_all_depths | _k+2`
      (until Phase 13e), `EANegation.lean:1090`, and `EANegation.lean:1249`. No phase introduces any
      other sorry. **No new sorry reaches the trusted core (the spine's `KampPrior.lean:562`) before ζ.**
- [ ] **Conditional-result invariant**: the landed β/γ/δ results carrying `hCapture` as an explicit
      hypothesis are PERMITTED to remain hypothesis-gated (orphan, un-discharged) until Phase 13e
      discharges `hCapture` via 10P. This is NOT a sorry and NOT a gate violation.
- [ ] **Incremental-with-fallback**: Phases 13a-13d land off the live import path and green BEFORE Phase
      13e touches the spine; Phase 13e proves the new path green with `:562` still present, then deletes
      the match LAST. Verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, or `Prop43Structural.lean`-style hole is introduced.
      **B1-B4 must not be discharged with `sorry`** — an unresolvable prerequisite is a STOP-and-surface,
      not a hole.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number or
      a Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page).
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks (Phases 0-12, 10a, 10b-i, 10b-ii, 10P already passed and are landed):
- [ ] Phase 13a (B1): the `atomMap` reconciliation lemma / generalized `h_surj` signatures compile
      sorry-free, axiom-clean, off-path; report 16's PROBE 1 `False` derivation no longer type-checks
      against the new signature; the committed signature is the fixed B2/B3/B4 interface.
- [ ] Phase 13b (B2): `semantic_prior_UZ/SZ (canonExpand …) atomMap` + the derived `HasAttainedINF/SUP`
      compile sorry-free, axiom-clean, off-path.
- [ ] Phase 13c (B3): `MonadicFormula.mapPreds` + `mapPreds_eval` (eval-naturality) compile sorry-free,
      axiom-clean, off-path; `psi : MonadicFormula sig 1` transfers into `translate_correct`'s domain.
- [x] Phase 13d (B4): the per-`M` → `M`-uniform extraction lemma (`translate_uniform` + full uniform
      negation stack) compiles sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`,
      off-path; the emitted formula is confirmed `N`-independent (`capType`/`univ.filter` witnesses,
      `∃Ψ`-outside-`∀N`).
- [ ] Phase 13e (ζ): the `canonExpand` is constructed, `hCapture` is DISCHARGED (`𝔈`-bounded) via 10P,
      the conditional β/γ/δ results collapse to unconditional, the `nf_nvar_exist_all_depths` match
      (incl. `:562`) is DELETED, and `sorryAx` is confirmed absent.

## Artifacts & Outputs

- plans/17_zeta-wire-b1-b4-reconciliation.md (this file)
- LANDED (Phases 0-12, 10a, 10b-i, 10b-ii, 10P — PRESERVED, do NOT re-execute): `Prop35VeeLift.lean`,
  `HCaptureDischarge.lean`, `ConjInterleave.lean`, `IntervalType.lean`, `VeeConj.lean`,
  `VVecEA2Collapse.lean` (10a bridge + 10a-ii assembly half), `LiftPair.lean`, `EFSatNegation.lean`,
  `EFSatNegationGeneral.lean`, `ESigmaCapture.lean` (10P), `VeeSatNegation.lean` (γ),
  `Prop43Translate.lean` (δ, all six cases), plus the Phase 3-8 partial-interval migration of
  `ExistsForallFormula.lean` / `VeeExistsForall.lean` / `ExistsForallLemmas.lean` /
  `Prop42NegationGeneral.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean` / `Prop42ExistsForall.lean`.
- New / extended `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules for THIS revision (names
  provisional): B1 reconciliation (generalized `Prop43Translate.lean`/`Prop35VeeLift.lean` signatures or
  new `ZetaAtomMapReconcile.lean`, Phase 13a); B2 prior transfer (extend `ESigmaCapture.lean` or new
  `ZetaPriorTransfer.lean`, Phase 13b); B3 `MonadicFormula.mapPreds` + naturality (extend the
  `MonadicFormula` module or new `MonadicFormulaMap.lean`, Phase 13c); B4 uniform extraction (new
  `ZetaUniformExtract.lean` or conclusion strengthening, Phase 13d).
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 13e — `canonExpand` construction + `hCapture` discharge
  + spine re-point + `nf_nvar_exist_all_depths` deletion).
- summaries/17_zeta-wire-b1-b4-reconciliation-summary.md (on completion)

## Rollback/Contingency

- **Landed Phases 0-12, 10a, 10b-i, 10b-ii, 10P:** already green and committed; not re-executed. If a
  later phase surfaces a regression in a landed module, revert to the last-green commit — do NOT re-plan
  the completed phases.
- **Phase 13a (B1) failure:** THIS is the decisive, highest-risk phase. It is additive/off-path (new
  lemma or generalized signature), so a failed attempt leaves last-green intact. If BOTH option (a) and
  option (b) fail to close, the obstruction is a genuine wire-seam incompatibility beyond faithful
  repair — STOP and surface for a further `/research` dispatch; do NOT force with `sorry`. Because 13a
  gates 13b/13c/13d, no downstream prerequisite is committed against an unresolved interface.
- **Phases 13b / 13c / 13d failure:** additive/off-path; each is independent, so a failed one leaves the
  others and all last-green intact and resumable. B2/B3 are transfer/naturality plumbing (fix the
  transfer, do NOT add `sorry`); B4 is a conclusion-strengthening / uniformity-exposure task (if
  `N`-independence cannot be exposed, STOP and surface). None blocks the others; all block only Phase 13e.
- **Phase 13e regression:** incremental-with-fallback. The new path is proven green with the old `:562`
  sorry still present; the `nf_nvar_exist_all_depths` deletion is done LAST and verified immediately with
  `#print axioms`. If the spine re-wire regresses the build or the axiom set, revert the Phase-13e edits
  (spine re-point + match deletion) to restore the last-green state where all B1-B4 lemmas exist but the
  old sorry still carries the spine.
