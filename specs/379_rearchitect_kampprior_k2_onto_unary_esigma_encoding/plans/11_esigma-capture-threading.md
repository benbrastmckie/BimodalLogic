# Implementation Plan: E[Σ] Capture-Hypothesis Threading — Conditional Collapse Bridge + `hCapture` Discharge Prerequisite, Retiring `KampPrior.lean:562`

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: ~40-64 hours remaining across 5 not-started phases (10a conditional bridge, 10b β, 11 γ, 12 δ, 13 ζ) plus 1 HIGH-risk prerequisite phase (10P, `hCapture` discharge); Phases 0-9 + `vvecea2_collapse_of_perClause` COMPLETED, sorry-free and landed; ~1,400-2,400 new Lean lines. Phases 0-9 and `vvecea2_collapse_of_perClause` are PRESERVED — do NOT re-execute.
- **Dependencies**: None to start (Phases 0-9 landed; the 10a-ii assembly half `vvecea2_collapse_of_perClause` landed green). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 13; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here).
- **Research Inputs**: reports/11_esigma-capture-hypothesis-audit.md (AUTHORITATIVE for this revision — adversarially-verified divergence audit pinning the exact missing `hCapture` hypothesis at the IntervalType level and the ζ-only discharge obligation; supersedes both prior Phase-10 blocker diagnoses on the type-level question); reports/07_faithful-esigma-negation-path.md (authoritative phase-structure source for the negation spine; its R4 "true crux" = the E[Σ] atom-collapse (Def 4.1) is exactly the seam this revision threads); handoffs/phase-10-blocked-handoff-* and phase-10a-blocked-* (the two verified Phase-10 blocker strikes, now re-diagnosed by report 11); reports/09_conjinterleave-interval-type-audit.md (partial-interval adjudication, integrated in plan 09); reports/05_conjunction-closure-load-bearing-verdict.md (conjunction-closure load-bearing verdict); reports/06_phase4-unblock-construction.md (option-(b) engine, landed)
- **Artifacts**: plans/11_esigma-capture-threading.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 11_esigma-capture-hypothesis-audit.md, 07_faithful-esigma-negation-path.md, 09_conjinterleave-interval-type-audit.md, 05_conjunction-closure-load-bearing-verdict.md, 06_phase4-unblock-construction.md

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of `nf_nvar_exist_all_depths` at `KampPrior.lean:562`. Plan 08
turned report 07's faithful E[Σ] path (α→β→γ→δ→ζ) into a phased build and landed Phases 0-1
sorry-free plus Phase 2 (the `conjInterleave` merge apparatus) as a PARTIAL with one tracked
strategic sorry. Phase 2 surfaced a source-grounded DESIGN FINDING that the machine-checked
divergence audit (report 09) has now **CONFIRMED and adjudicated**: the landed
`UnaryType := NormalForm (sigE sig F) 0 1` interval encoding is a **complete** type, on which a full
`conjInterleave_iff` biconditional is **unattainable** (confirmed 2-point counterexample). The
faithful fix — grounded in Rabinovich Def 3.1 (PDF p.4) making αⱼ/βⱼ *quantifier-free formulas*,
plus Lemma 3.2(1)/3.4 (p.4-5) and Prop 3.5 (p.5) — is **Option (A)**: refine interval types to
**partial** types `IntervalType := Finset UnaryType`, with conjunction = intersection (∩), ⊥ = ∅
(forces the slot empty, vacuously satisfied), point types staying complete `UnaryType`. Options (B)
restricted-iff and (C) complete-type-plus-flag are refuted by the audit.

Plan 09 landed **Phases 0-9 sorry-free and green** on the partial-interval representation: the ε
interface (Prop 3.5 ∨-lift + `hcapture` discharge), the partial `IntervalType := Finset UnaryType`
migration of the ~3,000-line critical path (Phases 3-8), and the **full** `conjInterleave_iff` /
`veeConj_iff` biconditionals (Phase 9, `conjInterleave_forward` strategic sorry retired). Those
phases are **PRESERVED VERBATIM** in this plan and must NOT be re-executed.

**This revision (plan 11) finalizes the Phase-10 seam after a divergence-audit research dispatch
(report 11) pinned the exact missing hypothesis.** Phase 10 blocked **twice** on the same seam:
Strike 1 (plan 09) missed the four engine hypotheses `atomMap / h_surj / HasAttainedINF /
HasAttainedSUP`; Strike 2 (plan 10) added those four but discovered they are the *wrong four* — the
reverse `VVecEA2 → VeeExistsForall` collapse needs a **capture/definability** hypothesis, not
attainment/surjectivity facts. The adversarially-verified report 11 now resolves the twice-blocked
question decisively, with three findings this plan threads (does NOT re-derive):

1. **The exact missing hypothesis is at the `IntervalType` level, NOT `UnaryType`** (both prior
   blocker handoffs got the level wrong — a TL formula's truth set generally spans multiple
   complete-1-type cells, i.e. a *union* of cells, which is exactly what `IntervalType := Finset
   UnaryType` / `intervalHolds` expresses). It is the **literal reverse** of the landed
   `unaryToFormula_correct` (`Prop35ExistsForall.lean:75`), lifted to `IntervalType`:
   ```lean
   (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
       ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
   ```
   This is exactly what Phases 3-9 built `intervalHolds` for.
2. **Threading `hCapture` makes Phase 10a's bridge implementable next dispatch as a CONDITIONAL
   result**: the per-clause obligation 10a-i discharges via `hCapture` + the ALREADY-LANDED
   `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean`). Phases 11 (γ) and 12 (δ) already carry
   the same `N`-hypotheses, so `hCapture` threads through them cleanly (a fixed property of `N`,
   orthogonal to the structural induction; no consumer uses `¬hCapture`, so there is no polarity clash).
3. **`hCapture` is dischargeable ONLY at Phase 13 (ζ)**, against a `canonExpand` whose `F` is CLOSED
   under the negation engine's output formulas (`neg belowFormula`, `neg aboveFormula`, `negFix`).
   That F-closure is NOT established in-tree, and `canonExpand` is **never constructed in the live
   spine** (grep: it appears only inside `ESigmaExpansion.lean`; the spine imports only
   `ExistsForallNF`). Therefore a **NEW PREREQUISITE lemma** is required — an E[Σ] output-alphabet
   capture/closure lemma that discharges `hCapture` at the ζ `canonExpand`. This is a genuine, named
   new sub-goal, scheduled explicitly as **Phase 10P** (HIGH-risk, research-grounded), coupled to ζ.

**Fidelity note (record for the ζ / prerequisite implementer).** Rabinovich's `F` is
**closed-by-construction** at each stage: it *is* the set of `TL` formulas processed at that stage, so
every engine output is already a named E[Σ] predicate and the collapse is definitional. The Lean `F`
is an **opaque `Finset Formula` parameter with no closure invariant** tying it to the negation
engine's outputs. That is the exact gap; the Phase-10P prerequisite lemma supplies precisely that
missing invariant (faithful repair, not new mathematics).

**Historical two-axis diagnosis (superseded on the type-level question by report 11, retained for
provenance).** Phase 10 as written in plan 09 was not implementable, confirmed on two independent
axes: (Axis 1 — object-type seam) the mandated per-pair base case `prop42_efSat_negation_general`
(`Prop42NegationGeneral.lean`) is **`VVecEA2`-valued**
(`v'.holds N atomMap (env 0)(env 1) ↔ ¬ efSat …`), but Phase 10's target, its downstream consumers
(Phase 11 γ `veeSat_negation`, Phase 12 δ `translate`), and its flatten step (`veeSat_append`) are
all **`VeeExistsForall`/`veeSat`-valued** — and an exhaustive grep confirms **no
`VVecEA2 → VeeExistsForall` bridge exists anywhere under `Theories/`** (every translation, including
`translateVeeProp42`, runs FORWARD `VeeExistsForall → VVecEA2`). (Axis 2 — insufficient hypotheses)
Phase 10's stated signature carried only `ψ, env, StrictMono env`, missing the
`atomMap / h_surj / HasAttainedINF / HasAttainedSUP` the base-case engine requires. Report 11 shows
those four, once added (Strike 2), are still insufficient: the missing piece is `hCapture`.

**Adjudication — Option 1 (dedicated collapse-bridge before β) is CHOSEN over Option 2 (restate
β/γ/δ at the `VVecEA2` level).** Re-expressing a `VVecEA2` (a disjunction of endpoint-`TemporalPred`
+ `BracketFormula` clauses) as a `VeeExistsForall` (a disjunction of Def-3.1 `∃∀` chains with unary
E[Σ] point/interval types) **IS the E[Σ] atom-collapse (Def 4.1, PDF p.5-6)** — report 07's R4
"true crux", flagged HIGH-risk. That collapse is genuine, unavoidable content: Rabinovich's Prop 4.3
recursion stays uniformly in the `∨∃∀` object, so Prop 4.2's per-leaf output must re-enter as a
`∨∃∀` object. The only question is WHERE the collapse happens. Option 1 applies it ONCE, as an
explicit named lemma at the leaf, so β stays `VeeExistsForall`-valued and **Phases 11 (γ) and 12 (δ)
are unchanged** — they already rest on the `VeeExistsForall`-valued machinery landed in Phase 9
(`veeConj_iff`, `veeSat_append`, `veeSat_exists`). Option 2 was rejected because it **collides with
the already-landed Phase-9 assets**: γ reassembles negated disjuncts via `veeConj_iff`, which is
`VeeExistsForall`-valued, and δ's `not`-case consumes `veeSat_negation` (`VeeExistsForall →
VeeExistsForall`); keeping β at the `VVecEA2` level would force either a duplicate `VVecEA2`-level
conjunction-closure rebuild (wasting Phase 9 and departing from Rabinovich's Lemma 3.4 which is
stated on `∨∃∀`) or threading `VVecEA2` through the entire structural induction with a collapse at
every `not`-node — strictly more cascade and less faithful. Option 1 minimizes cascade, keeps each
phase bounded to ~one dispatch, and makes the genuine Def 4.1 content auditable.

Concretely, this revision **preserves Phases 0-9 and the landed `vvecea2_collapse_of_perClause`
verbatim** and **finalizes Phase 10 (β)** by threading `hCapture` as an explicit `IntervalType`-level
hypothesis: Phase 10a becomes a **CONDITIONAL** collapse bridge taking `hCapture` and discharging its
per-clause obligation through the already-landed `vvecea2_collapse_of_perClause` (this is the next
implementable dispatch). `hCapture` threads unchanged through Phase 10b (β assembly), Phase 11 (γ),
and Phase 12 (δ) — all conditional/orphan results gated on `hCapture`. A **new HIGH-risk prerequisite
phase (Phase 10P)** owns the E[Σ] output-alphabet capture/closure lemma that discharges `hCapture` at
the ζ `canonExpand`; it may run in **parallel** with 10a/10b/11/12 (they only *consume* `hCapture`
abstractly) but **gates Phase 13**. **ζ remains the terminal Phase 13**, which retires
`KampPrior.lean:562` AND discharges `hCapture` (via Phase 10P), collapsing every conditional result to
unconditional.

**Definition of done**: `#print axioms completeness_discrete` no longer lists `sorryAx`, with the
full `lake build` at EXIT 0 (floor 1769 jobs) and no new axiom or non-permitted sorry anywhere on
the proof term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool,
Lean.trustCompiler, Quot.sound]` — with `sorryAx` REMOVED (Phase 13 deletes the sole on-path
`KampPrior.lean:562` sorry). **Conditional-result caveat**: Phases 10a-12 land green + sorry-free but
**hypothesis-gated on `hCapture`** (off-path orphans, permitted). They become unconditional only when
Phase 13 (ζ) constructs the `canonExpand` and discharges `hCapture` via the Phase-10P prerequisite. No
new `sorry` reaches the trusted core (the spine's `KampPrior.lean:562`) before ζ.

### Research Integration

- **Report 11 (`reports/11_esigma-capture-hypothesis-audit.md`, AUTHORITATIVE + newly integrated for
  this revision)**: the adversarially-verified (H4) divergence-audit dispatch (H5, two strikes on the
  same seam) that pins the exact missing hypothesis. Its decision-grade findings, threaded verbatim
  by this plan: (Q1) the capture hypothesis is `hCapture : ∀ A, ∃ S : IntervalType sig F, ∀ y,
  intervalHolds N S y ↔ temporal_truth N atomMap y A` — the interval-level (NOT `UnaryType`-level;
  R4 correction to both prior handoffs) reverse of `unaryToFormula_correct`; (Q2) it is absent
  in-tree and must be threaded as a hypothesis (attainment ≠ definability; `hcapture_dischargeable`
  is the WRONG object — it captures a `NormalForm`, not a `TL` `Formula`); (Q3) it threads cleanly to
  Phases 11/12 and is dischargeable ONLY at Phase 13 (ζ) against a `canonExpand` with `F` closed
  under the engine's outputs — a closure not yet built; (Q4) the design is faithful to Def 4.1/Prop
  4.3, the sole discrepancy being the missing F-closure invariant; (Q5) verdict = **BOUNDED** bridge
  (conditional, next dispatch) **+ PREREQUISITE** (the F-closure discharge lemma, Phase 10P). This
  report SUPERSEDES the type-level diagnosis in the two prior Phase-10 blocker handoffs (which named
  the capture at `UnaryType`, refuted by report 11 R4).
- **Phase-10 BLOCKED handoffs (`handoffs/phase-10-blocked-*` and `phase-10a-blocked-*`; integrated,
  now re-diagnosed by report 11)**: record the verified two strikes — Strike 1 (Axis 1: the negation
  engine is `VVecEA2`-valued with no reverse bridge to `VeeExistsForall`; Axis 2: missing
  `atomMap / h_surj / h_INF / h_SUP`) and Strike 2 (the four added hyps are attainment/surjectivity,
  not definability). Both confirm the De Morgan half of β (`augTarget_iff` → ordered-pair disjunction
  + existence-sentence negation) is sound and reusable, and that the 10a-ii assembly half
  `vvecea2_collapse_of_perClause` landed green. Their unblock Option 1 (dedicated collapse bridge
  before β) is **adopted**; Option 2 is rejected (see Overview adjudication). Their `UnaryType`-level
  capture guess is corrected to `IntervalType` by report 11.
- **Report 07 (authoritative for the negation spine)**: supplies the faithful phase structure α-ζ
  and — decisively for this revision — its **R4 identifies the `VVecEA2 → VeeExistsForall`
  re-expression as the E[Σ] atom-collapse (Def 4.1, p.5-6), the "true crux", HIGH-risk.** That is
  exactly the content the new collapse-bridge component of Phase 10 schedules as an explicit lemma.
  Its H3 table anchors Phases 10-13. Its device-4 finding (Def 4.1: a TL(Until,Since)-over-E[Σ]
  formula collapses to a unary atom in the canonical expansion) is the mechanism the bridge realizes.
- **Report 09 (partial-interval adjudication; integrated in plan 09, carried forward)**: adjudicated
  **Option (A) partial interval types** (`IntervalType := Finset UnaryType`), which Phases 3-9 landed.
  This revision builds on that completed migration unchanged; its H4 footnote-2 correction was already
  applied in Phase 9.
- **Report 05 (build on)**: conjunction-closure (Lemma 3.2(1)/3.4-∧) is load-bearing INSIDE the
  Prop 4.3 negation case (p.6) — the reason the full `veeConj_iff` (landed Phase 9) is required, and
  the reason Option 2 (which would strand it) is rejected.
- **Report 06 (build on)**: the arbitrary-pin Prop 4.2 engine `prop42_efSat_negation_general` is
  LANDED (and Phase-6-migrated to partial intervals) and is reused as the per-pair base case in
  Phase 10 (β) — its `VVecEA2` output is now lifted to `VeeExistsForall` by the new collapse bridge.

**Grounded engine signature (verified in-tree for this revision).**
`prop42_efSat_negation_general` (`Prop42NegationGeneral.lean`):
```
theorem prop42_efSat_negation_general {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (ψ : ExistsForallFormula sig F 2) :
    ∃ v' : VVecEA2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSat N env ψ)
```
The forward bridge `translateVeeProp42 : VeeExistsForall sig F 2 → VVecEA2` with
`translateVeeProp42_correct : veeSat N env Ψ ↔ (translateVeeProp42 …).holds …` (endpoint-pinned +
attained) runs `VeeExistsForall → VVecEA2` only; the collapse bridge is its genuine reverse and does
not exist yet. `Lemma53.lean`'s `VBracketFormula.toVVecEA2_holds` and the "bracket collapses to
Lemma 5.3's `∃x₁…∃xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ Pᵢ(xᵢ)`" note are the reusable anchor for the
bracket-clause → Def-3.1 `∃∀` chain direction.

### Prior Plan Reference

Supersedes `plans/10_negation-collapse-bridge.md` (which itself superseded
`plans/09_partial-interval-rearchitecture.md`). **Phases 0-9 are carried forward VERBATIM** (all
COMPLETED, sorry-free, landed green; `conjInterleave_iff` and `veeConj_iff` are full biconditionals
and the `conjInterleave_forward` strategic sorry is retired). The plan-10 Phase-10a **10a-ii assembly
half `vvecea2_collapse_of_perClause`** (`VVecEA2Collapse.lean`) is ALSO carried forward VERBATIM — it
landed green, axiom-clean, off-path, and is the composition target the conditional bridge now feeds.
Plan 10's Phase 10 was BLOCKED on the 10a-i per-clause collapse; report 11 resolves it. This plan
**restates Phase 10a as a CONDITIONAL bridge taking `hCapture` at the `IntervalType` level** and
threads `hCapture` through 10b/11/12; it **adds the new prerequisite Phase 10P** (the `hCapture`
discharge / F-closure lemma). Phases 11 (γ), 12 (δ), 13 (ζ) keep their intent and numbering (now
carrying `hCapture` as one more threaded hypothesis) — **ζ remains the terminal Phase 13**, extended
to discharge `hCapture` (via Phase 10P) alongside retiring `KampPrior.lean:562`. **Do NOT re-execute
Phases 0-9 or `vvecea2_collapse_of_perClause`.**

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. No roadmap review/update phases are added.

## Goals & Non-Goals

**Goals**:
- **Preserve all landed sorry-free work (Phases 0-9 + `vvecea2_collapse_of_perClause`) VERBATIM** —
  the ε interface, the partial `IntervalType := Finset UnaryType` migration, the full
  `conjInterleave_iff` / `veeConj_iff` biconditionals, and the 10a-ii disjunctive-assembly half. Do
  NOT re-execute them.
- **Close the Phase-10 seam as a CONDITIONAL result** by proving the `vvecea2_collapse_bridge`
  (`VVecEA2 → VeeExistsForall`, Def 4.1 E[Σ] atom-collapse, PDF p.5-6) threading the exact missing
  hypothesis `hCapture` at the `IntervalType` level (report 11 Q1/Q5) and composing the landed
  `vvecea2_collapse_of_perClause`. This is the next implementable dispatch (Phase 10a).
- **Thread `hCapture` through β (10b), γ (11), δ (12)** as one more `N`-property hypothesis (report 11
  Q3/R3), keeping the `atomMap / h_surj / HasAttainedINF / HasAttainedSUP` augmentation from plan 10.
  These land as CONDITIONAL orphans gated on `hCapture` (permitted).
- **Schedule the NEW PREREQUISITE (Phase 10P)**: the E[Σ] output-alphabet capture/closure lemma that
  discharges `hCapture` at the ζ `canonExpand`, supplying the F-closure invariant Rabinovich has
  by-construction but the opaque Lean `F` lacks (report 11 Q4). HIGH-risk, research-grounded; runs in
  parallel with 10a-12; blocks ζ.
- Assemble β (`efSat_negation_general`) at the `VeeExistsForall` type by lifting each per-pair
  `VVecEA2` engine output through the conditional bridge, so γ (Phase 11) and δ (Phase 12) rest on the
  landed `VeeExistsForall`-valued machinery (no `VVecEA2`-level rebuild) — the payoff of Option 1.
- Retire `KampPrior.lean:562` by DISSOLVING the `_k+2` arm (deleting `nf_nvar_exist_all_depths`) AND
  DISCHARGING `hCapture` (via Phase 10P at the constructed `canonExpand`), collapsing the conditional
  β/γ/δ to unconditional — via the faithful E[Σ] structural-induction path (Phase 13 ζ, terminal).
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor
  headers only; Rabinovich cited by PDF page and sibling module names).

**Non-Goals**:
- Introducing any novel mathematics or Feferman-Vaught composition. The `Finset UnaryType`
  representation is the standard qf-formula normal form (set of satisfying complete 1-types) — the
  audit confirms it is faithful, not novel.
- Making point types partial. The audit establishes point types MAY remain complete `UnaryType`
  (merged points are real points; disjunctive point constraints lift soundly to the ∨ level); doing
  so halves the negation-engine re-proof. Uniformly-partial point types are equally faithful but
  larger — out of scope.
- Any arity-4 realization engine, joint-type-over-a-tuple, or `chain_split` (NON-APPLICABLE).
- Touching `EANegation.lean:1090` / `:1249` (zero external consumers, off the proof term) or
  rebuilding `Kamp/NfEFold.lean`.
- Adopting `nf_eval_efold` / `nf_eval_nfk_iff_efold` as a migration target.
- The terminal `#print axioms` final-assembly audit (task 375) and arity-4 apparatus archival
  (task 359).
- Any `sorry` outside the amended sorry gate below, any `def X := True`, vacuous placeholder, or
  `Prop43Structural.lean`-style hole.

## Binding Constraints (carry into EVERY phase)

- **FAITHFULNESS TO RABINOVICH IS ESSENTIAL. NO NOVEL MATHEMATICS, NO FEFERMAN-VAUGHT.** Every
  construction traces to a report-09 / report-07 H3 table row.
- **Cite Rabinovich BY PDF PAGE ONLY**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
  The companion `.md` is CORRUPT and must not be used.
- **Anchor code by DECLARATION NAME, never line number. NO TASK-NUMBER POINTERS in `Theories/**/*.lean`.**
- **`chain_split` is NON-APPLICABLE.** Do NOT touch `EANegation.lean:1090` / `:1249`. Do NOT rebuild
  `Kamp/NfEFold.lean`.
- **AMENDED SORRY GATE.** The only permitted live sorries anywhere in the build are:
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 13), `EANegation.lean:1090`, and
  `EANegation.lean:1249`. (The `conjInterleave_forward` continuation sorry was retired in the
  now-completed Phase 9 and is no longer part of the gate.) No phase may introduce any other sorry
  or any new axiom.
- **Point types stay complete `UnaryType`; only interval types become partial `Finset UnaryType`.**

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Field-type flip breaks all 225 consumer refs in one build (cannot stay green) | H | H | **Abstraction-first / widen-last.** Introduce `intervalHolds`/`ofComplete` (Phase 3), route `efSat`'s interval clauses through `intervalHolds (ofComplete …)` with a propositional-equality bridge lemma (Phase 4), migrate each consumer cluster to the bridge in isolation (Phases 5-7), then widen the stored field to genuine `Finset` LAST (Phase 8) — localized because every consumer already routes through `intervalHolds`. Each phase ends with full `lake build` EXIT 0. |
| A consumer cluster cannot migrate green in isolation because the `efSat` clause change is not definitionally transparent | H | M | Use the derived-accessor technique: keep the complete-typed field, add a derived `IntervalType` accessor + `intervalHolds_ofComplete_iff` bridge, and expose `efSat` interval-clause unfold lemmas so each downstream proof migrates via a one-line rewrite. Never change the stored field until Phase 8. |
| `Prop42NegationGeneral.lean` (1004 lines) interval-clause migration exceeds one agent run | M | H | Phase 6 is scoped to `efIntervalTP` generalization (complete type → set-disjunction of complete-type translations) + `belowFormula`/`aboveFormula`/`middleBracket` + their correctness lemmas; if it overflows, split into 6a (`efIntervalTP` + `belowFormula`) and 6b (`aboveFormula`/`middleBracket` + assembly), each green. Declared in the phase. |
| Full `conjInterleave_iff` still hides a wall on partial types | H | L | The audit gives the exact merge rule (merged interval = `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂`; empty slot vacuous; nonempty forces `S₁∩S₂≠∅` at each point) and both proof directions (forward realizes the intersection at each merged point; backward projects `e₁`/`e₂` and `intervalHolds (S₁∩S₂) → intervalHolds Sₖ`). Machine-checked feasibility: `Fintype`+`DecidableEq (NormalForm sig k n)` (`NormalForm.lean:167-182`) give `Finset UnaryType`, `∩`, `univ`, decidable `∃ τ ∈ S`. |
| The CONDITIONAL collapse bridge (Phase 10a), threading `hCapture`, hides a residual wall in the per-clause collapse | H | L | Report 11 (Q5) verifies the per-clause obligation 10a-i is dischargeable *given* `hCapture`: for each `VecEA2` clause, apply `hCapture` to `endpointLeft.formula`, `endpointRight.formula`, and each bracket `pointTypes`/`segmentTypes` formula to obtain capturing `IntervalType`s; supply the resulting `trans`/`htrans` to the ALREADY-LANDED `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean`) for the disjunctive assembly. `h_INF`/`h_SUP` remain needed only for the `negFix` (Lemma 5.1) middle-bracket INF/`K⁺` readback. The hard content (capture) is deferred to `hCapture`, so 10a is bounded glue over landed pieces. If a wall still appears it is a threading defect (fix the clause plumbing), NOT a `sorry` — the genuine Def 4.1 content lives in Phase 10P. |
| Phase 10P (E[Σ] output-alphabet capture/closure lemma discharging `hCapture` at the ζ `canonExpand`) is the genuine Def 4.1 content — HIGH-risk, research-grounded; it may exceed one dispatch or hide a deep expressiveness wall | H | M | This is the honest residual (report 11 Q3/Q5, "PREREQUISITE required for the unconditional close"). Two faithful shapes: **(P-a)** define `F` at the ζ rewire site as CLOSED under the engine's formula constructors (`neg`, `belowFormula`, `aboveFormula`, `negFix`), then discharge the finite `hCanon` form via `atom_eval_new` (`ESigmaExpansion.lean:122`, `Iff.rfl` on a `canonExpand`); **(P-b)** prove directly that on the ζ `canonExpand`, every engine-output `TL` formula's truth set equals some `IntervalType`'s `intervalHolds` extension (reverse of `unaryToFormula_correct` at the interval level, for the specific finite engine-output set `𝔈`). Bound the obligation to the FINITE `𝔈` (`neg belowFormula`, `neg aboveFormula`, `negFix` outputs), NOT all formulas — the `∀ A` form is only *threaded*, never discharged unconditionally. It may run in parallel with 10a-12 (they consume `hCapture` abstractly). If it cannot close, the obstruction is genuine Def 4.1 F-closure content — STOP and surface for a further `/research` dispatch; do NOT force ζ with `sorry`. |
| Threading `hCapture` through 10b/11/12 introduces a polarity clash or a consumer that needs `¬hCapture` | M | L | Report 11 Q3/R3 verifies: `hCapture` is a fixed property of `N`, orthogonal to the structural induction; 10b/11/12 already carry `N / atomMap / h_surj / h_INF / h_SUP` uniformly, so adding one Prop-valued hypothesis threads with no contradiction; no consumer uses `¬hCapture`. Add it as one more hypothesis on `efSat_negation_general` (β), `veeSat_negation` (γ), and `translate_correct` (δ); results stay conditional/orphan until ζ discharges. |
| δ `translate` structural induction larger than one run | M | H | Phase 12 sub-decomposes by connective case (atom / lt / and / or / not / ex); each independently green; `and`→Phase 9 `veeConj_iff`, `not`→Phase 11, `or`/`ex`→landed helpers; atom/`lt` emit partial intervals directly. |
| Phase 13 (ζ) live-path rewire regresses the spine or fails to remove `sorryAx` | H | M | Do the `nf_nvar_exist_all_depths` deletion LAST and verify immediately with `#print axioms`; keep the old sorry carrying the spine until the new path is wired green; rollback = revert the spine re-point + match deletion to last-green (migrated modules present, old sorry intact). |
| Off-paper mathematics or footnote-2 mis-citation persists | H | L | Per-phase faithfulness anchor to a report-09/07 H3 row; drop the `ConjInterleave.lean` docstring's footnote-2 citation on its next edit (Phase 9), replacing it with Def 3.1 + Lemma 3.2(1)/3.4 grounding per the audit's H4 correction. |

## Implementation Phases

**Dependency Analysis** (Phases 0-9 are LANDED/COMPLETED — shown for provenance; the active waves
are 8-12 covering Phases 10a, 10P, 10b, 11, 12, 13):
| Wave | Phases | Blocked by | State |
|------|--------|------------|-------|
| 1 | 0 | -- | COMPLETED |
| 2 | 1, 2 | 0 | COMPLETED |
| 3 | 3 | 2 | COMPLETED |
| 4 | 4 | 3 | COMPLETED |
| 5 | 5, 6, 7 | 4 | COMPLETED |
| 6 | 8 | 5, 6, 7 | COMPLETED |
| 7 | 9 | 8 | COMPLETED |
| — | 10a-ii (`vvecea2_collapse_of_perClause`) | 9 | COMPLETED (landed in plan 10) |
| 8 | **10a (conditional bridge)**, **10P (prerequisite)** | 10a: 9, 6, 10a-ii · 10P: 1 (ESigmaExpansion/`canonExpand` apparatus) | NOT STARTED (resumes here) |
| 9 | 10b (β assembly) | 10a, 9, 6 | NOT STARTED |
| 10 | 11 (γ) | 10b | NOT STARTED |
| 11 | 12 (δ) | 11 | NOT STARTED |
| 12 | 13 (ζ) | 12, **10P** | NOT STARTED |

Phases within the same wave can execute in parallel. **Phases 0-9 and the landed
`vvecea2_collapse_of_perClause` are sorry-free — do NOT re-execute them.** Implementation resumes at
Wave 8. **The next implementable dispatch is Phase 10a** (the CONDITIONAL collapse bridge threading
`hCapture`), which depends on landed Phase 9 (`veeConj_iff`), the Phase-6-migrated
`prop42_efSat_negation_general` engine, and the landed `vvecea2_collapse_of_perClause` — all
COMPLETED. **Phase 10P (the `hCapture` discharge prerequisite) sits in Wave 8 too**: it may start
immediately and run in PARALLEL with 10a/10b/11/12 (which only *consume* `hCapture` abstractly), and
it depends only on the landed Def 4.1 / `canonExpand` apparatus (`ESigmaExpansion.lean`, Phase 1). Its
result is **coupled to Phase 13**: ζ is the ONLY consumer that discharges `hCapture`, so Phase 13
depends on Phase 10P. Phases 10a-12 stay OFF the live import path as **conditional/orphan results
gated on `hCapture`**; only Phase 13 touches the spine, so `#print axioms completeness_discrete` is
UNCHANGED at every boundary through Phase 12 (the pre-existing `KampPrior.lean:562` `sorryAx` remains
the sole on-path sorry until Phase 13 deletes it). Hypothesis-gated (orphan) conditional results are
PERMITTED to remain un-discharged until ζ.

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
re-derived under partial intervals in Phase 9 — see the Continuation item below.)*

**CARRIED FORWARD FROM PLAN 08.** Landed `ConjInterleave.lean` (off live import path; full
`lake build` EXIT 0; spine untouched) with the merge apparatus sorry-free: `belowCount`,
`belowCount_le`, `intervalSlot`, `chainPointType`, `chainIntervalType`, `MergePair`
(+`Fintype`/`DecidableEq`), `MergePair.valid`, `MergePair.pointConsistent`, `mergedFormula`,
`conjInterleave`, `mergedSet`, `mergedSet_card_succ`, and the crux `pointConsistent_of_holds`. The
forward theorem `conjInterleave_forward` is stated TRUE with ONE documented mechanical
strategic-sorry (the sorted-union `orderEmbOfFin` rank-realization bookkeeping).

**Continuation item (explicit):** the tracked `conjInterleave_forward` strategic sorry is one of the
four permitted live sorries in the amended sorry gate. It is NOT discharged on the current
complete-`UnaryType` object; instead the forward direction is re-derived on the partial
representation as part of **Phase 9** (the merged interval type changes from "chain-1 only" to
`chainIntervalType ψ₁ ∩ chainIntervalType ψ₂`, so the definition and its forward proof are restated
together). Until Phase 9, this sorry persists and is accounted for by the gate.

**Superseded design note:** the module docstring's citation of Rabinovich footnote 2 (p.5) as
grounding the forced-empty mechanism is INCORRECT per report 09's H4 correction; it must be dropped
and replaced with Def 3.1 (p.4) + Lemma 3.2(1)/3.4 (p.4-5) grounding on the next edit (Phase 9).

- **Goal (as landed):** the definition + forward direction of the ∃∀×∃∀ → ∨∃∀ order-preserving
  merge (Lemma 3.2(1)), a single ordered chain with no arity growth.
- **Faithfulness anchor:** report-09/07 H3 row "Lemma 3.2(1) / Lemma 3.4 (∧), p.4-5".
- **Tasks:**
  - [x] Define the order-preserving merge datatype + `conjInterleave` (point-consistency filter).
  - [ ] Forward direction of `conjInterleave_iff` — TRUE skeleton with one tracked strategic sorry;
        **re-derived in Phase 9 on the partial representation** (do not discharge on complete types).
  - [x] Verify no arity growth (single `StrictMono` chain, unary types).
- **Timing:** 8-12 hours (landed); forward-direction discharge folded into Phase 9.
- **Depends on:** 0.
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean`.
- **Started:** 2026-07-18. Status: PARTIAL (merge apparatus green; forward strategic-sorry tracked).

---

### Phase 3: Partial interval type — `IntervalType := Finset UnaryType` + `ofComplete` + `intervalHolds` [COMPLETED]

- **Goal:** Introduce the partial interval representation as ADDITIVE new declarations, touching no
  existing field or consumer, so the build stays green trivially. Establishes the abstraction all
  later migration phases route through.
- **Faithfulness anchor:** report-09 §5 (Phase 2.5, first bullet) + H3 row "Def 3.1, p.4" — a qf
  1-formula IS its finite set of satisfying complete 1-types.
- **Tasks:**
  - [x] Define `IntervalType sig F := Finset (UnaryType sig F)` (admissible-completion set).
  - [x] Define `intervalHolds N (S : IntervalType) (y) : Prop := ∃ τ ∈ S, unaryHolds N τ y` (decidable
        via the landed `Fintype`/`DecidableEq (NormalForm sig k n)`, `NormalForm.lean`).
  - [x] Define `intervalConj S₁ S₂ := S₁ ∩ S₂`, `intervalBot := (∅ : Finset _)`,
        `intervalTop := Finset.univ`.
  - [x] Define the embedding `ofComplete : UnaryType → IntervalType := ({·})` and prove the
        compatibility lemma `intervalHolds_ofComplete_iff : intervalHolds N {τ} y ↔ unaryHolds N τ y`.
  - [x] Prove the basic algebra needed downstream: `intervalHolds` monotone in `S`
        (`intervalHolds_mono`), `intervalHolds (S₁ ∩ S₂) y ↔ (∃ τ, (τ ∈ S₁ ∧ τ ∈ S₂) ∧ …)`
        (`intervalHolds_inter_iff`) plus the `intervalHolds_inter_left`/`_right` projection
        directions, and `intervalHolds ∅ y ↔ False` (`intervalHolds_bot`, ⊥/forced-empty) — the
        vacuity lever Phase 9 uses.
- **Timing:** 3-5 hours (~150-250 lines). **Complete** (~135 lines; delivered `IntervalType`,
  `intervalHolds`, `intervalConj`, `intervalBot`, `intervalTop`, `ofComplete`,
  `intervalHolds_ofComplete_iff`, `intervalHolds_bot`, `intervalHolds_mono`,
  `intervalHolds_inter_iff`, `intervalHolds_inter_left`, `intervalHolds_inter_right`).
- **Depends on:** 2.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/IntervalType.lean` (new; name provisional).
- **Verification:** New module compiles sorry-free, axiom-clean (every new declaration
  `#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`); imported by nothing
  yet (grep-audited); full `lake build` EXIT 0 at 1769 jobs; `#print axioms completeness_discrete`
  unchanged (no existing module imports the new file, so the spine proof term is byte-identical).
- **Completed:** 2026-07-18.

---

### Phase 4: `efSat` interval-clause abstraction — route through `intervalHolds ∘ ofComplete` [COMPLETED]

- **Goal:** Reformulate `ExistsForallFormula.efSat`'s three interval clauses to satisfy
  `intervalHolds N (ofComplete (ψ.intervalType t)) y` (propositionally equal, via
  `intervalHolds_ofComplete_iff`, to the landed `unaryHolds N (ψ.intervalType t) y`), while KEEPING
  the stored field complete-typed. Expose `efSat` interval-clause unfold/bridge lemmas so every
  downstream consumer migrates via a one-line rewrite. This is the stable target the field-flip
  (Phase 8) later widens without touching consumers.
- **Faithfulness anchor:** report-09 §5 (Phase 2.5, second/third bullets — rewrite the `efSat`
  interval clauses to use `intervalHolds`; provide the `ofComplete` compatibility lemma).
- **Tasks:**
  - [x] Add a derived accessor `ExistsForallFormula.intervalSet ψ t : IntervalType := ofComplete (ψ.intervalType t)`. *(deviation: altered — placed in `IntervalType.lean`, not `ExistsForallFormula.lean`; the latter is imported by `IntervalType.lean`, so hosting `intervalHolds`/`ofComplete`-based declarations there would be an import cycle. Co-located with the Phase-3 point-level bridge `intervalHolds_ofComplete_iff`.)*
  - [x] Restate `efSat`'s three interval clauses through `intervalHolds N (ψ.intervalSet t) y`;
        prove they are propositionally equal to the landed clauses (bridge lemma `efSat_interval_iff`). *(Landed as `efSat_interval_iff`, an iff between `efSat` and its partial-relation form; `efSat` def body left unchanged so no consumer breaks — the widen-last discipline.)*
  - [x] Provide `efSat` unfold lemmas (below/above/middle interval clause accessors) that downstream
        proofs can rewrite through, so Phases 5-7 migrate independently. *(Landed: `intervalSet_holds_iff` (general per-slot) + `intervalSet_below_iff`/`_middle_iff`/`_above_iff`.)*
  - [x] Fix any breakage local to `ExistsForallFormula.lean` / `VeeExistsForall.lean` so the build is
        green with the field still complete-typed. *(deviation: no-op — additive-only; `efSat` unchanged, so neither file needed edits. Full `lake build` EXIT 0 confirms no breakage anywhere.)*
- **Timing:** 5-8 hours (~200-350 lines). **Complete** (~90 added lines in `IntervalType.lean`;
  `intervalSet`, `intervalSet_holds_iff`, `intervalSet_below_iff`/`_middle_iff`/`_above_iff`,
  `efSat_interval_iff`).
- **Depends on:** 3.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/IntervalType.lean` (Phase-4 bridge section
    appended; `ExistsForallFormula.lean` / `VeeExistsForall.lean` untouched — additive-only, see
    task deviations above).
- **Verification:** `efSat_interval_iff` + unfold lemmas compile sorry-free, axiom-clean
  (each `#print axioms` = `[propext, Classical.choice, Quot.sound]`); full `lake build` EXIT 0 at
  1769 jobs; `#print axioms completeness_discrete` UNCHANGED
  (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
  the sole `KampPrior.lean:562` `sorryAx`, no new axiom). Consumers still build because the
  `efSat` clause is untouched; the bridge is additive.
- **Completed:** 2026-07-18.

---

### Phase 5: `ExistsForallLemmas` migration — `augTarget` / `pairProject` / `existenceSentence` / `augTarget_iff` [COMPLETED]

- **Goal:** Migrate the `ExistsForallLemmas.lean` interval reasoning onto the `intervalHolds`
  abstraction (via the Phase 4 bridge lemmas), keeping the field complete-typed. Territory: this
  file only (parallel-safe with Phases 6, 7).
- **Faithfulness anchor:** report-09 §4 (blast-radius: `augTarget`/`pairProject`/`existenceSentence`
  copy interval types through and `augTarget_iff` reasons about the interval clauses via `unaryHolds`
  — all move to the partial satisfaction relation) + H3 row "Lemma 3.2(2)".
- **Tasks:**
  - [x] Re-point `augTarget`, `pairProject`, `existenceSentence` interval-type handling through the
        `intervalSet`/`intervalHolds` accessors. *(The `pairProject`/`existenceSentence`/`dropPin`
        defs keep their `intervalType := ψ.intervalType` field-copies — correct and field-agnostic:
        they copy the stored field, which stays complete-typed in Phase 5 and copies the widened
        field in Phase 8. The interval-clause REASONING migrated: `pairProject_pins` and
        `chainOf_spec` now expose `intervalHolds N (ψ.intervalSet ·)` clauses (routed via
        `rw [efSat_interval_iff] at h`), and `gluedChain_before`/`_between`/`_after` conclude in the
        `intervalHolds`/`intervalSet` form.)*
  - [x] Migrate `augTarget_iff`'s interval-clause reasoning to `intervalHolds` via the Phase 4 bridge.
        *(`augTarget_backward` builds the final `efSat` through `rw [efSat_interval_iff]`, so its six
        clause obligations are the partial-relation form the migrated `gluedChain_*` lemmas supply;
        `augTarget_forward`/`augTarget_backward_zero`/`existenceSentence_of_efSat` are field-agnostic
        pass-throughs needing no change. `augTarget_iff = ⟨augTarget_forward, augTarget_backward⟩`
        green.)*
  - [x] Confirm no other declaration in the file directly unfolds the old interval clause.
        *(grep verified: zero surviving `unaryHolds N (… intervalType …)` interval clauses; the only
        remaining `.intervalType` occurrences are the three `def` field-copies. Point-type clauses
        correctly stay `unaryHolds N (ψ.pointType ·)`; `unaryHolds_subinterval` is a generic-`τ`
        helper, not a field interval clause.)*
- **Timing:** 5-8 hours (702-line file; ~200-400 migrated lines). **Complete** (~7 targeted edits:
  1 import + 6 interval-clause migrations; no proof-term regressions).
- **Depends on:** 4.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean`
- **Verification:** File compiles sorry-free, axiom-clean; full `lake build` EXIT 0 at 1770 jobs;
  `#print axioms completeness_discrete` unchanged
  (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`).
- **Completed:** 2026-07-18.

---

### Phase 6: `prop42_efSat_negation_general` interval-clause migration — `efIntervalTP` → set-disjunction [COMPLETED]

- **Goal:** Migrate `Prop42NegationGeneral.lean` (1004 lines, LANDED sorry-free) onto the partial
  satisfaction relation. The core is generalizing `efIntervalTP` from translating a **complete**
  interval type to translating an admissible-completion **set** (a disjunction of complete-type
  translations), and threading it through `belowFormula`/`aboveFormula`/`middleBracket` and their
  correctness proofs. Territory: this file only (parallel-safe with Phases 5, 7).
- **Faithfulness anchor:** report-09 §4 (`efIntervalTP` translates a complete interval type; a
  partial (set) type requires translating a disjunction, re-proving the engine) + H3 row "Prop 3.5,
  p.5" (a set = disjunction of the complete-type TL translations).
- **Tasks:**
  - [x] Generalize `efIntervalTP` to accept an `IntervalType` (set), producing the disjunction of the
        per-completion translations; prove its correctness lemma against `intervalHolds`.
        *(Landed as a new local `efIntervalSetTP` + `efIntervalSetTP_eval` in `Prop42NegationGeneral.lean`:
        `efIntervalTP` itself lives in `Prop35Assembly.lean` (Phase-7 territory, not touched), so the
        set-level generalization is defined here as a `List.foldr TemporalPred.disj TemporalPred.bot`
        over `S.toList.map (efIntervalTP …)`, reading back exactly as `intervalHolds`.)*
  - [x] Thread the generalized `efIntervalTP` through `belowFormula` / `aboveFormula` /
        `middleBracket` and their correctness proofs. *(All three constructors now build interval
        slots via `efIntervalSetTP ∘ ψ.intervalSet`; the forward proofs (`belowFormula_of_efSat`,
        `aboveFormula_of_efSat`, `middleBracket_of_efSat`) and the backward `efSat_of_decompose_tl`
        `rw [efSat_interval_iff]` at the `efSat` seam and swap `efIntervalTP_eval` → `efIntervalSetTP_eval`.
        Point clauses stay `efPointTP`/`unaryHolds`.)*
  - [x] Re-establish `prop42_efSat_negation_general` sorry-free on the migrated clauses (field still
        complete-typed, so every call site currently passes `ofComplete τ` = a singleton set —
        semantics unchanged). *(`efSat_decompose_tl` / `prop42_efSat_negation_general` unchanged —
        they reference the constructors, not `efIntervalTP`; lemma statements untouched.)*
- **Split contingency (H8):** if this exceeds one agent run, split into **6a** (`efIntervalTP`
  generalization + correctness + `belowFormula`) and **6b** (`aboveFormula` / `middleBracket` +
  `prop42_efSat_negation_general` re-assembly), each ending green.
- **Timing:** 8-14 hours (~300-600 migrated lines; largest single file).
- **Depends on:** 4.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean`
- **Verification:** `efIntervalTP` (generalized) + `prop42_efSat_negation_general` compile
  sorry-free, axiom-clean; full `lake build` EXIT 0 at 1769 jobs; `#print axioms
  completeness_discrete` unchanged.

---

### Phase 7: `Prop35Assembly` / `Prop35Chain` / `Prop42ExistsForall` re-point [COMPLETED]

- **Goal:** Migrate the remaining `efSat`/interval-clause consumers onto the `intervalHolds`
  abstraction via the Phase 4/6 bridges. Territory: these three files only (parallel-safe with
  Phases 5, 6).
- **Faithfulness anchor:** report-09 §4 (blast-radius list: `Prop35Assembly` (~397),
  `Prop35Chain` (~231), `Prop42ExistsForall` (~448) consume `efSat` and the interval clauses).
- **Tasks:**
  - [x] Re-point `Prop35Assembly.lean` interval-clause reasoning through the `intervalHolds`/
        `efSat_interval_iff` bridges. *(`translateProp35_correct`: forward destructure now
        `rw [efSat_interval_iff] at h`, its six interval-clause use sites bridged via
        `intervalSet_holds_iff .mp`; backward build now `rw [efSat_interval_iff]` before `refine`,
        each interval obligation prefixed `rw [ψ.intervalSet_holds_iff]` back to the landed
        `unaryHolds` proof term. Added `import …Kamp.IntervalType`. Field stays complete-typed;
        `efIntervalTP`/`efPointTP` machinery and point clauses untouched.)*
  - [x] Re-point `Prop35Chain.lean` similarly. *(No-op: grep-verified zero interval-clause code —
        the file is a `List.finRange` chain-spec/witness-function bridge whose only `efSat`
        references are docstrings. Nothing unfolds `efSat`'s interval clauses, so there is no
        `unaryHolds N (ψ.intervalType ·)` reasoning to migrate. Mirrors Phase 5's "confirm no
        declaration unfolds the old interval clause" completion; file unchanged, builds green.)*
  - [x] Re-point `Prop42ExistsForall.lean` similarly. *(`translateProp42_forward` destructure now
        `rw [efSat_interval_iff] at h`, its four `hbetween` use sites prefixed
        `rw [← ψ.intervalSet_holds_iff]` before `refine hbetween`; `translateProp42_backward` both
        `rcases` branches now `rw [efSat_interval_iff]` before `refine`, with before-cap / between /
        after-cap obligations prefixed `rw [ψ.intervalSet_holds_iff]`. `IntervalType` reached
        transitively via `Prop35Assembly`. Field stays complete-typed; trivial caps
        `capTrivialLeft`/`capTrivialRight` and point clauses stay `unaryHolds`.)*
- **Timing:** 5-8 hours (~1076 lines across three files; ~200-400 migrated lines). **Complete**
  (2 migrated files, 1 verified no-op; ~19 targeted edits + 1 import).
- **Depends on:** 4.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop35Assembly.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop35Chain.lean` *(no change required)*
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ExistsForall.lean`
- **Verification:** All three files compile sorry-free, axiom-clean; full `lake build` EXIT 0 at
  1770 jobs; `#print axioms completeness_discrete` unchanged
  (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
  the sole `KampPrior.lean:562` `sorryAx`, no new axiom).
- **Completed:** 2026-07-18.

---

### Phase 8: Field-type flip — `ExistsForallFormula.intervalType : Fin (n+2) → IntervalType` (widen last) [COMPLETED]

- **Goal:** Widen the STORED interval field from `Fin (n+2) → UnaryType` to `Fin (n+2) → IntervalType`
  (genuine `Finset UnaryType`); point types stay `UnaryType`. Because every consumer now routes
  through `intervalHolds`/`intervalSet` (Phases 4-7), this widening is localized to the field
  declaration, the `intervalSet` accessor (now the identity/field), the `efSat` interval clauses, and
  the constructors that BUILD `ExistsForallFormula` (which pass `ofComplete τ` = singletons until a
  later phase emits genuine sets). No consumer proof changes.
- **Faithfulness anchor:** report-09 §5 (Phase 2.5, second bullet — change the field type; point
  types may stay `UnaryType`).
- **Tasks:**
  - [x] Change `ExistsForallFormula.intervalType` to `Fin (n+2) → IntervalType`; collapse
        `intervalSet` to the field directly. *(deviation: altered — `IntervalType`/`intervalHolds`
        moved UP from `IntervalType.lean` into `ExistsForallFormula.lean` because the widened field
        and `efSat` now reference them and `IntervalType.lean` imports `ExistsForallFormula`; a
        reverse reference would be an import cycle.)*
  - [x] Update every `ExistsForallFormula` constructor / builder to store `ofComplete τ` (singleton)
        where it previously stored a complete `τ`. *(deviation: skipped — no from-scratch UnaryType
        producers exist on the migrated path; every interval-field value flows from a field copy
        (`pairProject`/`dropPin`/`existenceSentence`) or from `ConjInterleave.chainIntervalType`
        which reads the field, so all producers auto-adapted to the widened type with no `ofComplete`
        wrapping needed. The genuine `ofComplete` producers are emitted by later phases.)*
  - [x] Mechanically update `ConjInterleave.lean`'s `chainIntervalType` / `mergedFormula` to the
        widened field. *(deviation: skipped — `chainIntervalType` reads `ψ.intervalType`, so its
        inferred return type widened automatically; the module typechecks unchanged with its tracked
        `conjInterleave_forward` strategic sorry intact.)*
  - [x] Confirm the amended sorry gate holds (only the permitted sorries remain).
- **Prerequisite consumer migration (done in this phase, committed green while the field was still
      complete-typed):** relocated `efIntervalSetTP`/`efIntervalSetTP_eval` up into
      `Prop35Assembly.lean` (upstream of its consumers), then routed the `Prop35Assembly` and
      `Prop42ExistsForall` interval clauses (and `EndpointPinnedCapTrivial` caps) through
      `efIntervalSetTP ∘ ψ.intervalSet` / `intervalHolds`, dropping the `intervalSet_holds_iff`
      bridge. These landed as commits 8.1-8.3 before the atomic flip (8.4) so each was a green
      checkpoint; the stale `intervalSet_holds_iff` family was then removed in the flip.
- **Timing:** 4-7 hours (~100-300 lines, mostly mechanical constructor updates).
- **Depends on:** 5, 6, 7.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallFormula.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean` (mechanical typecheck only)
  - any builder sites surfaced by the compiler across the migrated files
- **Verification:** Full `lake build` EXIT 0 at 1769 jobs; `#print axioms completeness_discrete`
  unchanged; only the four permitted sorries present. The interval field is now genuinely partial.

---

### Phase 9: α (restated) — full `conjInterleave_iff` under partial intervals + `veeConj` / `veeConj_iff` [COMPLETED]

**PARTIAL (dispatch 2026-07-18).** The Phase-8 field widening had left `ConjInterleave.lean` RED
(the `chainPointType`/`chainIntervalType`/`mergedFormula` declarations no longer typechecked against
the widened `Finset`-valued interval field — the module is an orphan, excluded from the default
`lake build` target, so the Phase-8 "EXIT 0" never exercised it). This dispatch **restored it green**
and **redefined the merge on the partial representation** (plan Task 1), landing sorry-free:
`chainPointType` (now `Option`-valued: `none` at interior points), `mergedPointType`,
`chainIntervalType : … → IntervalType`, `mergedFormula` with interval slots
`intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t) = S₁ ∩ S₂`, `conjInterleave`,
`MergePair.pointConsistent` (agreement where both chains pin a point) + its `Decidable` instance,
`pointConsistent_of_holds`, and the point-type readback lemmas `mergedPointType_left`/`_right`. The
module docstring was rewritten (Task 5: footnote-2 citation dropped; grounded on Def 3.1 p.4 +
Lemma 3.2(1)/3.4 p.4-5). `conjInterleave_forward` remains the single tracked strategic sorry.
Full `lake build` EXIT 0 (1770 jobs); scoped `ConjInterleave` green; `#print axioms
completeness_discrete` unchanged.

**NOT yet landed (continuation):** the forward-direction rank-realization proof (retiring the sorry),
the backward direction, `conjInterleave_iff`, and `veeConj`/`veeConj_iff` (Tasks 2-4). No `VeeConj.lean`
was created (would be an empty stub — prohibited).

**DESIGN FINDING (surfaced for adjudication — do not silently implement).** The plan's Task 1 says
"keep point-consistency as the point filter." That is necessary but **not sufficient** for the
BACKWARD direction. A merged existential point of chain 2 that lies strictly *interior* to one of
chain 1's open intervals (`x₁ᵢ < e₂-point < x₁_{i+1}`) is, in `efSat ψ₁`, an interior point that must
satisfy `ψ₁`'s interval type there. The merged formula records only its complete point type
(`mergedPointType = ψ₂.pointType`), so a model satisfying the merged disjunct forces only that point
type — NOT that this complete type is admissible to `ψ₁`'s interval set at the covering slot. Hence
the merge needs an additional decidable **point-vs-interval cross-consistency** filter: at every
merged existential point pinned by chain `k` and interior to chain `(3-k)`, the pinning complete type
must lie in the other chain's `IntervalType` at `intervalSlot` (a `Finset` membership). This is the
exact analog of the Phase-2 design finding (interval-vs-interval), on the orthogonal point-vs-interval
axis, and the audit's backward sketch ("project e₁/e₂; `intervalHolds (S₁∩S₂) → intervalHolds Sₖ`")
does not cover it. Recommended: extend `MergePair.pointConsistent` (or add `crossConsistent`) to the
`conjInterleave` filter, then prove both directions. Micro-counterexample without the filter: `ψ₁ =`
"point `α`, everything after is `β`", `ψ₂ =` "point `γ`" with `γ ∉ {β}`; the `(α,γ)` merge with `γ`
after `α` is point-consistent but backward-unsound.

- **Goal:** On the partial representation, redefine the `conjInterleave` merge so the merged interval
  type is `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂` (BOTH chains, via `intervalConj`), then prove
  the FULL biconditional
  `conjInterleave_iff : veeSat N env (conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin) ↔ efSat N env ψ₁ ∧ efSat N env ψ₂`,
  discharging the carried Phase 2 forward strategic sorry on the new representation. Then build
  `veeConj` + `veeConj_iff` (Lemma 3.4-∧) as a full biconditional — the ∨∃∀-closed-under-conjunction
  operation the spine's γ (Phase 11) and δ `and`-case (Phase 12) require.
- **Faithfulness anchor:** report-09 §5 (Phase 3 restated) + H3 rows "Lemma 3.2(1) / Lemma 3.4 (∧),
  p.4-5". Drop the `ConjInterleave.lean` footnote-2 citation; ground the forced-empty mechanism on
  Def 3.1 (p.4) + Lemma 3.2(1)/3.4 per the H4 correction.
- **Tasks:**
  - [x] Redefine the merged interval type to `intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t)`
        (= `S₁ ∩ S₂`); keep point-consistency as the point filter; do NOT filter interval slots on
        mismatch — a mismatched slot carries `S₁ ∩ S₂` (possibly `∅`), vacuously satisfied when empty.
        *(Done + restored the module to green: also fixed the Phase-8-induced type errors by making
        `chainPointType` `Option`-valued and adding `mergedPointType`. Sorry-free.)*
  - [x] Discharge the FORWARD direction (re-deriving the carried Phase 2 sorry): the realized
        rank-merge realizes `S₁ ∩ S₂` at each merged interval point (each witness realizes both
        chains' interval types → a common completion). Retire the tracked `conjInterleave_forward`
        strategic sorry here. *(DONE 2026-07-18, sub-step 9(cont)-b — LANDED sorry-free. The
        `belowCount`↔position slot correspondence is the crux lemma `strictMono_lt_iff_val_lt_filterCard`
        (`x a < y ↔ a.val < #{i | x i < y}`, initial-segment cardinality of a strict-mono down-set);
        built on it: `chain_interval_clause` (routes efSat before/between/after into a uniform point
        slot), `chainIntervalType_eq_pointSlot` + `intervalSlot_eq_pointSlot` (count-match bridges),
        `intervalHolds_conj_of_both` (both chains' completions collapse to a common `S₁∩S₂` witness via
        `nf_eval_unique`). Assembly uses the 9(cont)-a rank helpers + `crossConsistent_of_holds`.
        Full `lake build` EXIT 0 (1770 jobs); `#print axioms completeness_discrete` unchanged from
        baseline `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.)*
  - [x] Prove the BACKWARD direction: from a merged disjunct, project `e₁`/`e₂` to recover both
        chains; `intervalHolds (S₁ ∩ S₂)` at every point of every ψₖ-interval gives `intervalHolds Sₖ`
        (monotonicity, Phase 3 algebra), discharging each chain's interval clause.
        *(DONE 2026-07-18, sub-step 9(cont)-c — LANDED sorry-free as `conjInterleave_backward`, then
        assembled into `conjInterleave_iff`. Region decomposition per reports/10 §5: project
        `xₖ i := w (eₖ i)`; at each point `y` of a ψₖ-open interval, a two-case split — (a) `y` not a
        merged point ⇒ merged interval clause + `intervalHolds_inter_left`/`_right` +
        `chainIntervalType_eq_pointSlot`; (b) `y = w j` a merged interior existential point of the
        OTHER chain ⇒ `crossConsistent` membership + `mergedPointType_left`/`_right` +
        `intervalSlot_eq_pointSlot`. New reusable helpers: `exists_mergePair_of_mem` (reverse
        membership extraction) and `regions_of_pointSlot` (point-slot clause → 3 efSat regions, mirror
        of `chain_interval_clause`). `veeConj_iff` axioms = `[propext, Classical.choice, Quot.sound]`
        — no `sorryAx`.)*
  - [x] Define `veeConj (Φ₁ Φ₂ : VeeExistsForall …)` by distributing ∧ over the disjunctions applying
        `conjInterleave` per pair; prove `veeConj_iff : veeSat (veeConj Φ₁ Φ₂) ↔ veeSat Φ₁ ∧ veeSat Φ₂`
        (full biconditional). *(DONE 2026-07-18, sub-step 9(cont)-c — new `VeeConj.lean`:
        `veeConj := Ψ₁.flatMap (fun ψ => Ψ₂.flatMap (fun φ => conjInterleave ψ φ ψ.pin φ.pin))`;
        `veeConj_iff` proved via `veeSat_flatMap` (push `veeSat` through both `flatMap`s) +
        `conjInterleave_iff` pointwise. Sorry-free.)*
  - [x] Update the module docstring: remove the footnote-2 citation; cite Def 3.1 (p.4) + Lemma
        3.2(1)/3.4 (p.4-5).
- **Timing:** 8-12 hours (~350-500 lines).
- **Depends on:** 8.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean` (redefine merge + full iff)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VeeConj.lean` (new; name provisional)
- **Verification:** `conjInterleave_iff` (both directions), `veeConj`, `veeConj_iff` compile
  sorry-free, axiom-clean; the `conjInterleave_forward` strategic sorry is GONE; off the live import
  path; full `lake build` EXIT 0 at 1769 jobs; `#print axioms completeness_discrete` unchanged.

---

### Phase 10: β — conditional collapse bridge + single-∃∀ negation over unordered pairs [COMPLETED]

**RESOLUTION** (report 11, adversarially verified — the twice-blocked seam is now unblocked as a
CONDITIONAL result). The plan-10 blocker was: `vvecea2_collapse_bridge` could not be discharged
because its per-clause obligation is the genuine Def 4.1 atom-collapse and neither Strike-1's nor
Strike-2's hypotheses supplied *capture/definability*. Report 11 pins the exact missing hypothesis and
re-scopes Phase 10 so it is implementable next dispatch:

- **The missing hypothesis (thread it, do not re-derive)** is `hCapture` at the **`IntervalType`**
  level (report 11 R4 correction — a `TL` formula's truth set is a *union* of complete-type cells, not
  a single `UnaryType`):
  ```lean
  (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
      ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
  ```
  It is the literal reverse of the landed `unaryToFormula_correct` (`Prop35ExistsForall.lean:75`),
  lifted to `IntervalType` — exactly what Phases 3-9 built `intervalHolds` for.
- **Why the seam is now bounded (report 11 Q2/Q5)**: the engine emits (`Prop42NegationGeneral.lean:997-1004`)
  `v' = (⟨neg (belowFormula …)⟩).disj ((middleBracket …).negFix) |>.disj (⟨neg (aboveFormula …)⟩)` —
  arbitrary `TL(Until,Since)` formulas at every endpoint (`:919`, `:950`), NOT `unaryToFormula`-images.
  `hCapture` is exactly the capture that turns each such `TL` endpoint formula into a capturing
  `IntervalType`. With `hCapture` threaded, the per-clause obligation 10a-i is discharged and composed
  through the **already-landed** `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean`, plan 10) to
  obtain the full bridge. `h_INF`/`h_SUP` remain needed only for the `negFix` (Lemma 5.1) middle-bracket
  INF/`K⁺` readback.
- **What is NOT closed here (report 11 Q3)**: `hCapture` is dischargeable only at Phase 13 (ζ) against a
  `canonExpand` whose `F` is closed under the engine's output formulas — a closure not yet built and
  handled by the new **Phase 10P** prerequisite. Phases 10a-12 are therefore **conditional/orphan
  results gated on `hCapture`** (permitted, off-path, no spine sorry).
- **Landed and preserved (do NOT re-execute)**: the sorry-free, axiom-clean, off-path **10a-ii
  assembly half** `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean`) — the `map`-over-disjuncts
  reduction taking the per-clause `trans`/`htrans` as inputs (`#print axioms` = `[propext,
  Classical.choice, Quot.sound]`, no `sorryAx`). The conditional 10a bridge composes 10a-i (now
  discharged via `hCapture`) through this landed lemma.
- **Prohibited (honored, carry forward)**: NO `sorry`, `def X := True`, or vacuous placeholder. The
  spine axiom set stays byte-identical to baseline
  (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`) through
  Phase 12.

The β target (`efSat_negation_general … : ∃ Φ : VeeExistsForall …, ¬ efSat ↔ veeSat Φ`) is retained;
the object-type seam is closed by interposing the CONDITIONAL **`vvecea2_collapse_bridge`** (Def 4.1
E[Σ] collapse, now taking `hCapture`) so the `VVecEA2`-valued engine output is lifted to a
`VeeExistsForall` disjunct BEFORE the `veeSat_append` flatten, with the signature carrying
`atomMap / h_surj / h_INF / h_SUP` AND `hCapture`. **Declared split**: 10a (conditional collapse
bridge) → 10b (β assembly), with **Phase 10P** (the `hCapture` discharge prerequisite) scheduled in
parallel and coupled to ζ. Each component ends green + sorry-free + off the live import path.

- **Faithfulness anchor:** report-11 Q1/Q4/Q5 (the exact `hCapture` at `IntervalType` level; F-closure
  discrepancy) + report-07 R4 + H3 rows "Def 4.1 + collapse note, p.5-6" (the
  `VVecEA2 → VeeExistsForall` re-expression IS the atom-collapse), "Prop 4.3 ¬-case assembly"
  (single-∃∀), "Prop 4.2" (reused engine), "Lemma 3.2(2)" (`augTarget_iff`), "Prop 3.5" (diagonal
  1-free-var negation).

#### Phase 10a — CONDITIONAL `vvecea2_collapse_bridge` threading `hCapture` (Def 4.1 E[Σ] collapse) [COMPLETED]

**PROGRESS (this dispatch, all in `VVecEA2Collapse.lean`, all axiom-clean
`[propext, Classical.choice, Quot.sound]`, off live import path, full `lake build` EXIT 0 at 1770
jobs, `completeness_discrete` axioms byte-identical to baseline):**

Five green reusable lemmas — the mathematical core of the Def 4.1 collapse — are landed and
committed:
1. `intervalType_captures_temporalPred` — lifts `hCapture` (formula-level) to any `TemporalPred`.
2. `intervalHolds_intervalTop` — every point realizes its own depth-0 characteristic, so the two
   unbounded `ExistsForallFormula` caps are vacuous (Rabinovich trivial caps).
3. `vvecea2_collapse_of_perClauseList` — the **list-valued** generalization of the landed
   single-EF `vvecea2_collapse_of_perClause`. **KEY FINDING:** the single-EF interface cannot carry
   the reverse bridge, because (a) `hCapture` is a non-constructive `∃`, so the pure `trans` cannot
   realize the capture — it must be built via `Classical.choice` inside the bridge; and (b) an
   `ExistsForallFormula` point type is a *single* complete `UnaryType` while a captured truth set is
   a *union* of complete types, so one `VecEA2` clause expands into a **disjunction** over point
   completions (a `List` of EFs, flattened by `List.flatMap`), not one EF.
4. `exists_piFinset_forall_iff` — finite-choice distribution for interior-witness completion tuples.
5. `bracket_completion_iff` — **the crux**: the bracket half of the atom-collapse, proved by cases
   on witness count reusing (4) + `efPointTP`/`efIntervalSetTP` readback.

**REMAINING (well-scoped assembly plumbing, de-risked by the 5 lemmas):** construct the per-tuple
endpoint-pinned EF `ψ` (via `Fin.cons`/`Fin.snoc` point/interval fields, `pin = ![0, last]`, caps
`intervalTop`), prove `EndpointPinnedCapTrivial` (from lemma 2), obtain `efSat ψ ↔ (translateProp42
ψ).holds` (landed `translateProp42_correct`), compute `translateProp42 ψ`'s fields to the completed
clause, then assemble: 3-way `∃`-distribution over the `S_L ×ˢ S_R ×ˢ piFinset Sp` product +
lemma 5 (bracket) + lemma 1 (endpoints) → `vea.holds`; flatten with lemma 3. The `cap : Formula →
IntervalType` is obtained by `choose … using hCapture`. Estimated ~120-180 further lines; the only
real risk is the `ψ`-field dite/`Fin.snoc` reduction inside `translateProp42`.

Original task checklist (for the full bridge):

*(Report 11 re-scopes this from BLOCKED to a bounded, CONDITIONAL result. The hard capture content is
deferred to the explicit `hCapture` hypothesis; the disjunctive-assembly half
`vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean`) is ALREADY LANDED green and is composed
through — do NOT re-prove it.)*

- **Goal:** Prove the reverse bridge as a CONDITIONAL result, taking `hCapture` (the exact missing
  hypothesis, report 11 Q1/Q5) as an explicit `IntervalType`-level argument:
  ```lean
  theorem vvecea2_collapse_bridge {sig : MonadicSignature} {F : Finset Formula}
      (N : OrderedMonadicStructure (sigE sig F))
      (atomMap : Formula → (sigE sig F).preds)
      (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
      (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
      (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,          -- the missing hypothesis (report 11)
          ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
      (v' : VVecEA2) :
      ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1))
  ```
  This is the reverse of the landed forward bridge `translateVeeProp42` (`VeeExistsForall → VVecEA2`);
  `hCapture` supplies the capture/definability the reverse direction needs. The `∀ A` form is threaded
  here, NOT discharged (its discharge is Phase 10P, at ζ).
- **Mechanism (faithful, report 11 Q5 + Def 4.1 p.5-6):** for each `VecEA2` clause of `v'`, apply
  `hCapture` to `endpointLeft.formula`, `endpointRight.formula`, and each bracket
  `pointTypes`/`segmentTypes` formula to obtain capturing `IntervalType`s; enumerate their completions
  into an `ExistsForallFormula` disjunct (point-pins at `z0`/`z1`, interval slots for the bracket
  segments). This yields the per-clause `trans`/`htrans` (reverse translation + its `efSat ↔ vea.holds`
  correctness). Assemble the disjunction over clauses by supplying `trans`/`htrans` to the
  **already-landed** `vvecea2_collapse_of_perClause`. `h_INF`/`h_SUP` are consumed only for the
  `negFix` (Lemma 5.1) middle-bracket INF/`K⁺` readback.
- **Reuse anchors (existing, sorry-free — compose, do NOT rebuild):** `vvecea2_collapse_of_perClause`
  (`VVecEA2Collapse.lean:70`, the landed assembly half); `intervalHolds` / `IntervalType`
  (`ExistsForallFormula.lean:87,93`); `Lemma53.lean` `VBracketFormula.toVVecEA2_holds` + the Lemma-5.3
  bracket readback; `VeeExistsForall.lean` `veeSat_append`; `PriorINF` `HasAttainedINF/SUP` for the
  `negFix` clause.
- **Tasks:**
  - [x] State `vvecea2_collapse_of_perClause` (disjunctive assembly, taking `trans`/`htrans`); module
        `VVecEA2Collapse.lean`. *(DONE, landed green in plan 10 — PRESERVED; do NOT re-execute.)*
  - [x] Add `hCapture` to `vvecea2_collapse_bridge`'s signature at the `IntervalType` level exactly as
        above. *(DONE — `vvecea2_collapse_bridge` in `VVecEA2Collapse.lean`.)*
  - [x] Discharge the per-clause `trans`/`htrans` for the endpoint clauses via `hCapture` on
        `endpointLeft.formula`/`endpointRight.formula`. *(DONE — `hcap` applied directly at the endpoints;
        `intervalHolds`-`eval_at` bridge.)*
  - [x] Discharge the per-clause `trans`/`htrans` for a `BracketFormula` clause via `hCapture` on each
        `pointTypes`/`segmentTypes` formula + the bracket readback. *(DONE — via the landed
        `bracket_completion_iff` + `collapseEF`/`collapseEF_translate`/`collapseEF_cap`. Deviation from
        the plan's `VBracketFormula.toVVecEA2_holds`/`h_INF`/`h_SUP` route: `hCapture` captures every
        engine-output formula directly, so the `negFix` readback is not needed and `h_INF`/`h_SUP` are
        carried but unused here — they thread on to 10b as specified.)*
  - [x] Compose the per-clause results through the assembly lemma to conclude the full biconditional
        gated on `env 0 < env 1`. *(DONE — via the list-valued `vvecea2_collapse_of_perClauseList`
        rather than the single-EF `vvecea2_collapse_of_perClause`: one `VecEA2` clause expands into a
        List of EFs over point completions, so the flatMap vehicle is required. Verified plan correction,
        carried from the prior dispatch.)*
- **Definition of Done:** `vvecea2_collapse_bridge` compiles sorry-free, axiom-clean (`#print axioms`
  = `[propext, Classical.choice, Quot.sound]` or subset, no `sorryAx`); it is a proved CONDITIONAL
  biconditional (an orphan gated on `hCapture`, PERMITTED); off the live import path (grep-audited);
  full `lake build` EXIT 0. NO `sorry`/`def := True` placeholder — if a clause cannot close *given*
  `hCapture`, it is a threading/plumbing defect to fix, not the deferred capture content.
- **Timing:** 6-10 hours (~250-450 lines; bounded glue over `hCapture` + the landed assembly half).
- **Depends on:** 9 (for `VeeExistsForall`/`veeSat_append` machinery), the landed
  `vvecea2_collapse_of_perClause`, 6 (engine clause shapes). Does NOT depend on Phase 10P (consumes
  `hCapture` abstractly).
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean` (extend with the conditional
    `vvecea2_collapse_bridge`; the landed `vvecea2_collapse_of_perClause` stays untouched).

#### Phase 10b — `efSat_negation_general` assembly [component; consumes conditional 10a] [PARTIAL — resolution additive via Phase 10b-i below]

**BLOCKER (Phase 10b) — arity-2 → arity-r lift is an unplanned encoding gap:**

- **What landed (green, sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`)**, in the
  new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean` (orphan, off the live
  import path):
  - `efSat_negation_pair` — per-pair negation to `∨∃∀`: composes `prop42_efSat_negation_general`
    (engine) with `vvecea2_collapse_bridge` (10a bridge), giving, for any `ξ : ExistsForallFormula
    sig F 2`, `∃ Φ : VeeExistsForall sig F 2, ∀ env, env 0 < env 1 → (veeSat N env Φ ↔ ¬ efSat N env ξ)`.
    Threads `hCapture`. This is plan task 2 (the per-pair half) fully realized.
  - `efSat_negation_demorgan` — plan task 1: De Morgan of `augTarget_iff` into
    `¬ efSat N env ψ ↔ (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2) ∨
    ¬ efSat N ![] (existenceSentence ψ)`. Pure classical propositional; no lift needed.
- **What is stuck (plan tasks 3-4 and the final `efSat_negation_general`):** the final target type is
  `∃ Φ : VeeExistsForall sig F r, ∀ env, StrictMono env → (¬ efSat N env ψ ↔ veeSat N env Φ)`, and
  `veeSat_append` flattens only disjuncts of the SAME arity `r`. So every per-pair disjunct
  (`VeeExistsForall sig F 2`, from `efSat_negation_pair`) and the existence-sentence disjunct
  (arity 0) must be LIFTED to `VeeExistsForall sig F r`. There is no `liftPair`/dummy-variable lemma
  in the codebase, and the lift is **not** an identity/plumbing step.
- **Why the lift is a genuine gap (root cause — encoding, not `hCapture`):** Rabinovich's Prop 4.3
  ¬-case (PDF p.6) reads "by Lemma 3.2(2) φ ≡ a conjunction of ∃∀-formulas *with at most two free
  variables*; hence ¬φ ≡ a disjunction of ¬ψ_i". His ψ_i are ≤2-free-variable formulas over the same
  variable set z₀…z_m — variables that do not occur are simply **absent** (a FOMLO formula need not
  mention every variable). The Lean `ExistsForallFormula sig F r` instead has a **total**
  `pin : Fin r → Fin (n+1)`: every one of the r free variables is pinned to an existential point, so
  a "dummy" (non-occurring) free variable becomes a genuine constraint `env k' = x (pin k')`.
  Verified analysis of the candidate lift of a pair-`(k,l)` negation object `ξ` (endpoint-pinned:
  `env k = x 0`, `env l = x (last)`, negation content on the interior, trivial `intervalTop` caps
  outside):
  - free variables `k' < k` and `k' > l` land in `ξ`'s **trivial caps** — insertable with trivial
    types, no obstruction;
  - a free variable with `k < k' < l` is forced by `StrictMono env` into `ξ`'s **non-trivial interior**.
    Inserting `env k'` as a witness point with a trivial point type gives the **forward** implication
    but breaks the **reverse** (`ξ`'s interior interval type at `env k'` is not recovered). Assigning
    the interior interval type as the inserted point's type would fix the reverse, but `ξ`'s interior
    witness points are **existentially chosen**, so which interior sub-interval `env k'` lands in is
    not statically known — the completion cannot be assigned. Neither a one-directional relaxation
    helps: the final iff needs the lift's forward direction for soundness AND its reverse for
    completeness on the SAME lifted disjunct.
- **What is needed to unblock (needs plan/design input, one of):**
  1. **Encoding primitive:** a partial-pin `ExistsForallFormula` variant (pin defined on a *subset*
     of `Fin r`), faithfully representing Rabinovich's ≤2-free-variable conjuncts, plus a lift lemma
     to the total-pin object; OR
  2. **Completion-expansion lift lemma (`liftPair`):** for pair `(k,l)`, disjoin over all
     interleavings of the middle free variables `{k' : k < k' < l}` with `ξ`'s interior points and all
     `IntervalType` completions they land in (finite, in the `collapseEF` style) — a new sub-phase of
     ~several hundred lines with its own correctness proof; OR
  3. **Restate the target** so the per-pair negations need not be lifted to total-pin arity-r objects.
- **Prohibited (honored):** no `sorry`, no `def X := True`, no vacuous placeholder was introduced.
  `hCapture` is threaded, never discharged. `efSat_negation_general` itself is NOT stated (stating it
  with a hole would require `sorry`); only the two green precursor lemmas were landed.
- **Verification at handoff:** full `lake build` EXIT 0 at 1770 jobs; `completeness_discrete` axioms
  byte-identical to baseline `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]`; both landed lemmas `[propext, Classical.choice, Quot.sound]`.

#### Phase 10b-i — `liftPair` (arity-2 → arity-r completion-expansion lift, report 12 §c) [COMPLETED]

Additive sub-phase inserted per the adversarially-verified resolution (report
`reports/12_arity-lift-encoding-resolution.md`, Option 2): lift each ≤2-free-variable negation
disjunct to arity `r` via an order-preserving chain-merge (Rabinovich Lemma 3.2(1)), disjoining
over insertions and inserted-point completions. Sits between the two landed precursors and the
Phase 10b-ii assembly; β/γ/δ/ζ signatures unchanged.

- **Landed (green, sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`)** in the new
  orphan file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean`:
  - `charType` / `unaryHolds_charType` / `exists_unaryHolds` — the characteristic complete unary
    type of a point; every point realizes some complete type.
  - `intervalHolds_top` — the ⊤ interval `intervalTop = univ` holds at every point.
  - `skelDisjunct` / `skelR` / `skelR_sat` — the universally-satisfiable arity-`m+1` skeleton as a
    `VeeExistsForall`, satisfied by every `StrictMono env`.
- **Spike finding (resolves report-12 Medium-risk driver):** `conjInterleave`/`mergedFormula`/
  `MergePair` are **not** reusable verbatim (they bake all-`r` pin-compatibility; `liftPair` needs
  pin coincidence only at `k,l`), but the scalar merge helpers (`mergedSet`, rank round-trip,
  `strictMono_lt_iff_val_lt_filterCard`, `chain_interval_clause`, `regions_of_pointSlot`,
  `chainIntervalType_eq_pointSlot`, `intervalSlot_eq_pointSlot`, `belowCount`/`intervalSlot`) ARE.
  A custom `LiftMergePair`/`liftMergedFormula` is required. **Report-12 `skelR : ExistsForallFormula`
  with "⊤ point types" is not constructible** (complete point types admit no ⊤); the faithful
  skeleton is the `VeeExistsForall` `skelR` landed here, and the same disjoin-over-completions
  device is mandatory at each inserted context point of `liftPair`.
- **Remaining (blueprint in `handoffs/phase-10b-i-liftpair-handoff-20260718T000000.md`):**
  `LiftMergePair` + `liftMergedFormula` + `liftPair` def; `liftPair_iff` (forward+backward, adapted
  from the landed `conjInterleave_forward`/`_backward`); then `liftPairV`/`liftSentence` wrappers.
- **Prohibited (honored):** no `sorry`, no `def X := True`, no vacuous placeholder. `liftPair_iff`
  is NOT stated (stating it with a hole would need `sorry`); only fully-proven lemmas landed.
- **Tasks:**
  - [x] Reuse-viability spike (custom merge required; scalar helpers reusable; skelR is `VeeExistsForall`).
  - [x] `skelR` / `skelR_sat` type-disjunction skeleton (green, axiom-clean).
  - [x] `LiftMergePair` / `liftMergedFormula` / `liftPair` definition (green, axiom-clean).
  - [x] `liftPair_iff` forward direction (`liftPair_forward`, green, axiom-clean).
  - [x] `liftPair_iff` backward direction (`liftPair_backward` + `liftPair_iff`, green, axiom-clean).
  - [x] `liftPairV` / `liftSentence` wrappers + their `_iff` lemmas (`liftPairV_iff`,
    `liftSentence_iff`, green, axiom-clean).
- **Landed this dispatch (green, sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`):**
  `LiftMergePair` (`eξ`/`eS` embeddings; `valid` with `k,l`-only pin coincidence; `validS` sentence
  variant; `crossConsistent` completion filter), `liftMergedPointType` (+ `_xi`/`_skel` readback),
  `liftMergedFormula`, `liftPair` + membership + `exists_liftMergePair_of_mem`, `liftPair_forward`,
  `liftPair_backward`, `liftPair_iff`, `liftPairV` + `liftPairV_iff`, `liftSentence` + membership +
  `exists_liftMergePairS_of_mem` + `liftSentence_forward`/`_backward`/`_iff`. The merge machinery
  (`crossConsistent`/`liftMergedFormula`/`liftMergedPointType`) was generalized to arbitrary source
  arity `s` (none reference `ξ.pin`) so the arity-0 sentence lift reuses it. Full `lake build`
  EXIT 0 at 1770 jobs; `completeness_discrete` axioms byte-identical to baseline.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean` (new; landed this dispatch).

#### Phase 10b-ii — `efSat_negation_general` assembly [component; consumes 10b-i] [PARTIAL — (a)+(b) landed sorry-free + axiom-clean; (c) strategic-sorry skeleton]

**Dispatch status (10b-ii):** (a) `pairProject_swap_efSat` and (b) the `liftSingle`/`liftSingleV`
1-pin family landed green + axiom-clean (`EFSatNegation.lean`, `LiftPair.lean`). (c) assembly landed
as a strategic-sorry skeleton in new `EFSatNegationGeneral.lean`: `diagProject` +
`diagProject_efSat_iff` (arity-1 diagonal reduction) and `liftSentenceV` + `liftSentenceV_iff` are
sorry-free; the two genuinely-unmapped low-arity negation objects (`efSat_negation_diagonal` arity-1,
`efSat_negation_existence` arity-0) and the `efSat_negation_general` trichotomy assembly consuming them
are documented strategic sorries. A bounded lean-search/loogle/grep pass confirmed no arity-0/1
`VeeExistsForall`-valued negation engine and no reverse Prop 3.5 exist in the tree. `hCapture` threaded,
never discharged; off the live import path; full `lake build` EXIT 0 at 1770 jobs; `completeness_discrete`
axioms byte-identical to baseline.

**Dependency status:** 10b-i is now COMPLETE — `liftPairV`/`liftPairV_iff` and
`liftSentence`/`liftSentence_iff` are landed green + axiom-clean in `LiftPair.lean`. The remaining
work is the pure-glue assembly composing the landed lemmas. Precise blueprint in
`handoffs/phase-10b-ii-assembly-<TS>.md`.

Original phase spec (retained for the resuming dispatch):

- **Goal:** Prove β at the `VeeExistsForall` type as a CONDITIONAL result threading `hCapture`:
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
  **Note the augmented signature**: `atomMap`, `h_surj`, `h_INF`, `h_SUP` (Axis 2, added in plan 10)
  AND `hCapture` (report 11, the definability piece) are all carried, threaded to
  `prop42_efSat_negation_general` and the conditional `vvecea2_collapse_bridge` (10a). The result is an
  orphan gated on `hCapture` until ζ.
- **Mechanism (faithful, Prop 4.3 single-∃∀ ¬-case, p.6):** De Morgan the migrated `augTarget_iff`
  (Lemma 3.2(2), landed Phase 5): `¬efSat ψ ↔ (∃ (k,l) ∈ pairwiseProjections, ¬efSat ![env k, env l]
  (pairProject ψ k l)) ∨ ¬efSat ![] (existenceSentence ψ)`. Discharge each per-pair
  `¬efSat (pairProject ψ k l)` via `prop42_efSat_negation_general` (landed Phase 6, `VVecEA2`-valued),
  then **lift each `VVecEA2` witness to a `VeeExistsForall` disjunct via `vvecea2_collapse_bridge`
  (10a)** — this is the step that was impossible in plan 09. Assemble the trichotomy explicitly:
  `pin k ≠ pin l ⟹ env k ≠ env l` (one orientation matches the engine's `env 0 < env 1` gate);
  `pin k = pin l` diagonal routes to the 1-free-var Prop 3.5 negation, NOT the pair engine. Negate the
  existence sentence (`r=0`) via the same engine + bridge at arity 0/1. Flatten all `VeeExistsForall`
  disjuncts into one via `veeSat_append` (landed).
- **Tasks:**
  - [x] De Morgan the migrated `augTarget_iff` decomposition (`efSat_negation_demorgan`, landed prior).
  - [x] `k < l` pair disjunct: `efSat_negation_pair` (`vvecea2` engine ∘ bridge) + `liftPairV` (landed).
  - [x] `k > l` symmetry fold: `pairProject_swap_efSat` *(landed this dispatch — milestone (a))*.
  - [x] `k = l` diagonal 1-pin lift: `liftSingle`/`liftSingleV` family *(landed this dispatch — (b))*.
  - [x] `k = l` diagonal reduction to arity 1: `diagProject` + `diagProject_efSat_iff` *(landed (c))*.
  - [x] Disjunctive sentence lift: `liftSentenceV` + `liftSentenceV_iff` *(landed (c))*.
  - [ ] Arity-1 diagonal negation object `efSat_negation_diagonal` *(strategic sorry — reverse Prop 3.5
        at arity 1 genuinely unmapped; follow-up sub-phase)*.
  - [ ] Arity-0 existence-sentence negation object `efSat_negation_existence` *(strategic sorry — reverse
        Prop 3.5 at arity 0 genuinely unmapped; follow-up sub-phase)*.
  - [ ] `efSat_negation_general` trichotomy assembly *(strategic sorry — consumes the two negation
        objects + the `pairwiseProjections` reindex; blocked only on the two objects above)*.
- **Definition of Done:** `efSat_negation_general` compiles sorry-free, axiom-clean (a CONDITIONAL
  result gated on `hCapture`, PERMITTED orphan); the trichotomy is a proved lemma; off the live import
  path; full `lake build` EXIT 0 at 1769 jobs.
- **Timing:** 6-10 hours (~300-500 lines; trichotomy/pin bookkeeping + existence-sentence negation +
  the per-pair bridge plumbing).
- **Depends on:** 10a (conditional bridge), 9, 6. Does NOT depend on Phase 10P (threads `hCapture`
  abstractly).
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean` (new; name provisional).
- **Prohibited:** Do NOT use `sorry`, `def X := True`, or a vacuous placeholder. `hCapture` is threaded
  (a hypothesis), never discharged here; the result stays conditional. Do NOT attempt to discharge
  `hCapture` in this phase — that is Phase 10P / ζ.

---

### Phase 10P: PREREQUISITE — E[Σ] output-alphabet capture/closure lemma (discharges `hCapture` at the ζ `canonExpand`) [COMPLETED] [HIGH-RISK, RESEARCH-GROUNDED]

**LANDED (P-a shape) in `ESigmaCapture.lean`, sorry-free, axiom-clean `[propext, Classical.choice,
Quot.sound]`, off the live import path; full `lake build` EXIT 0 @1770 jobs; `completeness_discrete`
spine axiom set byte-identical to baseline.** Five lemmas:
`intervalCapture_of_atomNamed` (reverse of `unaryToFormula_correct` at the `IntervalType` level,
via the `S := {τ | τ names A = true}` filter + `nf_characteristic`), `intervalCapture_forall_mem`
(the `𝔈`-bounded packaging), `temporal_truth_canonExpand` (conservativity of `temporal_truth`
under `canonExpand` when `atomMap` factors through `oldPred`), `canonExpand_atom_named` (the finite
`hCanon` via `atom_eval_new` + conservativity), and `esigmaCapture_canonExpand` (assembled
`𝔈`-bounded `hCapture` on the concrete `canonExpand`). No genuine Def 4.1 obstruction hit: the
F-closure is the explicit requirement `𝔈 ⊆ F`, which ζ arranges by construction.
**Phase-13 interface note:** the discharge is `𝔈`-bounded (`∀ A ∈ 𝔈`); the landed β signature
threads `∀ A : Formula`. The full `∀ A` form is genuinely undischargeable for temporally-reaching
`A ∉ F` (report R1), so ζ must consume the `𝔈`-bounded form — relax the β/γ/δ `hCapture` argument
to `∀ A ∈ 𝔈` (or `∀ A ∈ F`) at the ζ application site, or wrap. This is a Phase-13 wiring concern,
not a 10P sorry.

**This is a genuine, named new sub-goal (report 11 Q3/Q4/Q5 "PREREQUISITE required for the
unconditional close").** It is placed here (adjacent to Phase 10a, where `hCapture` is born) but in
dependency order it is **coupled to Phase 13 (ζ)**: it may start immediately and run in PARALLEL with
Phases 10a/10b/11/12 (which only *consume* `hCapture` abstractly), and its result is consumed ONLY at
ζ, so **Phase 13 depends on it** (see the wave table). Without it, ζ cannot remove `sorryAx` even
after 10a-12 land — the conditional results stay hypothesis-gated.

- **Goal:** Prove the forward E[Σ]-capture / output-alphabet-closure lemma that discharges `hCapture`
  at the concrete `canonExpand` used by ζ. The discharge target is the finite, F-membership form
  `hCanon` (report 11 Q1), from which `hCapture` follows on the engine-output set `𝔈` by unfolding
  `atom_eval_new`:
  ```lean
  -- discharge obligation (finite form) at the ζ canonExpand
  (hCanon : ∀ A ∈ 𝔈, ∃ hA : A ∈ F,
      ∀ y : N.carrier, N.interp (esigmaPred A hA) y ↔ temporal_truth N atomMap y A)
  -- whence, for the canonExpand model, hCapture : ∀ A, ∃ S : IntervalType sig F,
  --   ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A     (S := {τ | τ (esigmaPred A) = true})
  ```
  where `𝔈` is the FINITE set of engine-output `TL` formulas (`neg (belowFormula …)`,
  `neg (aboveFormula …)`, `negFix` outputs). Bound the obligation to `𝔈`, NOT all formulas — the
  `∀ A` form is only threaded through 10a-12, never discharged unconditionally.
- **The F-closure invariant it must establish (report 11 Q4):** Rabinovich's `F` is
  **closed-by-construction** — it *is* the set of `TL` formulas processed at the stage, so every engine
  output is already a named E[Σ] predicate and the collapse is definitional. The Lean `F` is an
  **opaque `Finset Formula` parameter with no closure invariant**. This lemma supplies exactly that
  missing invariant: `F` (at the ζ rewire site) must contain (up to equivalence) every engine-output
  formula so that `atom_eval_new` (`ESigmaExpansion.lean:122`, `Iff.rfl` on a `canonExpand`) names it.
- **Two faithful shapes (report 11 Q5 P-a / P-b) — pick per what the ζ `canonExpand` construction
  supports:**
  - **(P-a) Output-alphabet closure**: define/require `F` at the ζ rewire site to be CLOSED under the
    engine's formula constructors (`neg`, `belowFormula`, `aboveFormula`, `negFix`), then discharge
    `hCanon` via `atom_eval_new`. The faithful "E[Σ] is closed at the stage" invariant.
  - **(P-b) Semantic definability lemma**: prove directly that on the ζ `canonExpand`, every
    engine-output `TL` formula's truth set equals some `IntervalType`'s `intervalHolds` extension — the
    reverse of `unaryToFormula_correct` at the interval level, established for the specific finite `𝔈`.
- **Reuse anchors (existing, sorry-free):** `ESigmaExpansion.lean` `canonExpand` / `esigmaPred` /
  `sigE` (`:100,69,63`) and `atom_eval_new` (`:122`, `Iff.rfl`); `IntervalType` / `intervalHolds`
  (`ExistsForallFormula.lean:87,93`); the FORWARD `unaryToFormula_correct` (`Prop35ExistsForall.lean:75`)
  as the template to reverse. **Do NOT reuse `hcapture_dischargeable` (`HCaptureDischarge.lean:58`) —
  report 11 verified it is the WRONG object (it captures a `NormalForm σ`, not a `TL` `Formula`).**
- **Tasks:**
  - [x] Fix the discharge shape (**P-a**, output-alphabet closure) against the intended ζ `canonExpand`
        construction; state the lemma with `𝔈` = the finite engine-output set (`intervalCapture_forall_mem`,
        `esigmaCapture_canonExpand`).
  - [x] Establish the F-closure invariant (P-a): explicit `𝔈 ⊆ F` requirement + conservativity
        (`temporal_truth_canonExpand`) so the fresh atom names each engine output; discharged uniformly
        for every `A ∈ 𝔈` (no per-constructor case split needed — `atom_eval_new` + conservativity
        handle `neg (belowFormula …)`, `neg (aboveFormula …)`, `negFix` alike).
  - [x] Derive `hCapture` (interval-level form) on the `canonExpand` from `hCanon` via `atom_eval_new`
        (`S := {τ | τ (esigmaPred A) = true}`, `intervalCapture_of_atomNamed`), sorry-free.
        *(deviation: `𝔈`-bounded, not the full `∀ A : Formula` form — the full form is undischargeable
        for temporally-reaching `A ∉ F` per report R1; Phase 13 threads the `𝔈`-bounded form.)*
  - [x] Keep the module off the live import path until ζ consumes it; grep/import-audit (confirmed:
        nothing imports `ESigmaCapture`).
- **Definition of Done:** the capture/closure lemma compiles sorry-free, axiom-clean; it yields
  `hCapture` for the ζ `canonExpand` over the finite `𝔈`; off the live import path; full `lake build`
  EXIT 0. If it cannot close, the obstruction is genuine Def 4.1 F-closure content — STOP and surface
  for a further `/research` dispatch; do NOT force with `sorry`.
- **Timing:** 10-18 hours (~400-800 lines; the genuine Def 4.1 content, HIGH-risk per report 11 Q5).
- **Depends on:** 1 (the landed `ESigmaExpansion` / `canonExpand` / `atom_eval_new` apparatus). May run
  in parallel with 10a/10b/11/12. **Blocks Phase 13.**
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaCapture.lean` (new; name provisional).

---

### Phase 11: γ — ∨∃∀ negation [COMPLETED]

- **Goal:** Prove `veeSat_negation (Φ : VeeExistsForall sig F r) : ∃ Φ', ∀ env, StrictMono env →
  (¬ veeSat N env Φ ↔ veeSat N env Φ')` (carrying the same `N / atomMap / h_surj / h_INF / h_SUP` AND
  `hCapture` hypotheses that β now threads — see Phase 10b; γ already carried the `N`-hypotheses
  uniformly, so adding `hCapture` as one more Prop is clean per report 11 Q3/R3). Faithful to Prop
  4.3's disjunction-negation sub-case (p.6): `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by the
  conditional β (`VeeExistsForall`-valued via the Phase-10a collapse bridge); reassemble `⋀` of ∨∃∀
  into ∨∃∀ via the full `veeConj_iff` (landed Phase 9). **Unchanged in shape from plan 10** — the
  Option-1 choice keeps γ resting directly on the landed `VeeExistsForall`-valued `veeConj_iff`, with
  no `VVecEA2`-level rebuild. The result stays a CONDITIONAL orphan gated on `hCapture` until ζ.
- **Faithfulness anchor:** report-07/09 H3 rows "Prop 4.3 ¬-case assembly" (∨∃∀ part) + "Lemma 3.4
  (∧)" (`veeConj_iff`).
- **Tasks:**
  - [x] De Morgan `¬veeSat (∨φᵢ)` into `⋀ᵢ ¬φᵢ` *(via `veeSat_cons` + `not_or`; induction on the
        disjunct list rather than a bespoke conjunction fold).*
  - [x] Apply `efSat_negation_general` (β) per disjunct *(cons head via β; empty base case reuses β
        on an arbitrary `efArb` witness so `Gd ++ [d]` is the tautological top by excluded middle —
        no `Fintype` disjunction over point-type assignments needed).*
  - [x] Reassemble via `veeConj_iff` (Phase 9); fold over the disjuncts *(cons step reassembles
        `veeSat Gψ ∧ veeSat Φrest` as `veeConj Gψ Φrest`).*
- **Timing:** 3-5 hours (~100-200 lines; glue). *(Landed: ~110 lines.)*
- **Depends on:** 9, 10.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VeeSatNegation.lean` (new) *(landed: `veeSat_cons`,
    `efArb`, `veeSat_negation`; sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`,
    off the live import path).*
- **Verification:** `veeSat_negation` compiles sorry-free, axiom-clean; off the live import path;
  full `lake build` EXIT 0 at 1769 jobs.

---

### Phase 12: δ — structural Prop 4.3 `translate` (MonadicFormula → VeeExistsForall) [NOT STARTED]

- **Goal:** Build `translate : MonadicFormula sig m → VeeExistsForall sig F m` + `translate_correct
  (∀ M atomMap env, StrictMono env → (veeSat (translate φ) ↔ eval φ))` by structural induction over
  the FORMULA. On partial intervals the **atom** and **lt** base cases now emit partial interval
  types DIRECTLY (`∀y P(y)` → interval `S = {τ : τ ⊨ P}`) — the case that was impossible on complete
  types (report 09 §5, "this is where (A) pays off"). Cases: atom (partial-interval emit); lt
  (index-decided under `StrictMono`, partial-interval emit); and (`veeConj`, Phase 9); or
  (`veeSat_append`, landed); not (`veeSat_negation`, Phase 11 — carrying the `atomMap / h_surj /
  h_INF / h_SUP` AND `hCapture` hypotheses threaded from β); ex (`veeSat_exists`, landed).
  `translate_correct` therefore carries `hCapture` (threaded, not discharged) and stays a CONDITIONAL
  orphan gated on it until ζ. Do NOT revive the BLOCKED `Prop43.lean` over `VVecEA_m`.
- **Faithfulness anchor:** report-07/09 H3 row "Prop 4.3, p.6" (structural induction FO → ∨∃∀; δ base
  cases emit partial intervals directly).
- **Tasks:**
  - [ ] Define `translate` by recursion on `MonadicFormula` structure; atom/`lt` emit partial
        `IntervalType` sets directly.
  - [ ] Prove `translate_correct` case-by-case, each an independent green sub-step: atom, lt, and,
        or, not, ex.
  - [ ] Verify by goal inspection that the assembled induction introduces no arity growth (processed
        content folds into E[Σ] atoms).
- **Timing:** 10-16 hours (~500-800 lines; the crux — sub-decompose by connective case).
- **Depends on:** 9, 10, 11.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean` (new; name provisional —
    NOT `Prop43Structural.lean` and NOT the BLOCKED `Prop43.lean`)
- **Verification:** `translate` + all six connective cases of `translate_correct` compile sorry-free,
  axiom-clean; no arity growth (goal inspection); off the live import path; full `lake build` EXIT 0
  at 1769 jobs.

---

### Phase 13: ζ — spine rewire + retire `KampPrior.lean:562` [NOT STARTED]

- **Goal:** Re-express `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
  `nf_characterizable_temporal_prior` through Thm 4.4 = Prop 4.3 (δ) + Prop 3.5 (ε); **construct the
  `canonExpand` and DISCHARGE `hCapture`** via the Phase-10P capture/closure lemma, thereby collapsing
  the conditional β (10b) / γ (11) / δ (12) results to UNCONDITIONAL; wire in the Phase 1 `hcapture`
  (NormalForm) discharge and the Phase 0 semantic `MonadicFormula → characteristic NormalForm` bridge;
  and **delete the entire `nf_nvar_exist_all_depths` match including the `:562` sorry.** The sole
  live-path phase; the H4 highest-risk interface, de-risked by Phases 0, 1, and now Phase 10P. This is
  the ONLY consumer that discharges `hCapture` (report 11 Q3) — hence Phase 13 depends on Phase 10P.
- **Faithfulness anchor:** report-11 Q3/Q4 (`hCapture` dischargeable only at ζ against a closed-`F`
  `canonExpand`) + report-07/09 H3 row "Thm 4.4, p.6" (rewire + delete `nf_nvar_exist_all_depths`
  incl. `:562`).
- **Tasks:**
  - [ ] Construct the ζ `canonExpand` with `F` closed under the engine outputs (per Phase 10P's P-a
        shape) or the model against which Phase 10P's P-b definability holds.
  - [ ] Apply the Phase-10P capture/closure lemma to discharge `hCapture` for the constructed
        `canonExpand`; feed the discharged `hCapture` into the conditional β/γ/δ results (10b/11/12),
        collapsing every orphan to an unconditional fact.
  - [ ] Wire the Phase 0 semantic object-language bridge into the live spine.
  - [ ] Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery` onto the Phase 12 `translate` + Phase 1 Prop 3.5 lift +
        Phase 1 `hcapture` (NormalForm) discharge, now with `hCapture` discharged.
  - [ ] Verify the new path is green with the old sorry still present (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths` match (all arms + the `:562` sorry +
        its rationale block); update the in-file axiom-audit block and any stale doc-comment refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Timing:** 8-14 hours (~300-600 lines), plus the `canonExpand` construction + `hCapture` discharge
  wiring.
- **Depends on:** 1, 12, **10P** (`hCapture` discharge), and transitively 10b/11 (the conditional
  results it collapses).
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (delete the match + `:562` sorry)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-wire + audit block)
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files
- **Verification:** `#print axioms completeness_discrete` no longer lists `sorryAx` (retains
  `propext`, `Classical.choice`, `Quot.sound`, and the `native_decide`-sourced `Lean.ofReduceBool` /
  `Lean.trustCompiler`); full `lake build` EXIT 0 at 1769 jobs; no new axiom/sorry anywhere on the
  proof term. Hand off to task 375 for the terminal audit.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at 1769 jobs.
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phases
      0-12 the axiom set is unchanged (the pre-existing `KampPrior.lean:562` `sorryAx` remains,
      carrying the spine). Target end-state after Phase 13:
      `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no `sorryAx`.
- [ ] The amended sorry gate holds: the only live sorries anywhere are `nf_nvar_exist_all_depths | _k+2`
      (until Phase 13), `EANegation.lean:1090`, and `EANegation.lean:1249`. (The
      `conjInterleave_forward` sorry was retired in the completed Phase 9.) No phase introduces any
      other sorry. **No new sorry reaches the trusted core (the spine's `KampPrior.lean:562`) before ζ.**
- [ ] **Conditional-result invariant**: Phases 10a-12 results carrying `hCapture` as an explicit
      hypothesis are PERMITTED to remain hypothesis-gated (orphan, un-discharged) until Phase 13 (ζ).
      This is NOT a sorry and NOT a gate violation — `hCapture` is a genuine threaded hypothesis whose
      discharge is Phase 10P applied at ζ.
- [ ] Phases 10a-12 and 10P deliverables stay OFF the live import path (`KampPrior.lean` does not import
      them); verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, or `Prop43Structural.lean`-style hole is introduced.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number
      or a Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page).
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks (Phases 0-9 and `vvecea2_collapse_of_perClause` already passed and are landed):
- [ ] Phase 10a (CONDITIONAL collapse bridge): `vvecea2_collapse_bridge` compiles sorry-free,
      axiom-clean, off the live import path; its signature carries `hCapture` at the `IntervalType`
      level exactly as `∀ A, ∃ S : IntervalType sig F, ∀ y, intervalHolds N S y ↔ temporal_truth N
      atomMap y A`; it is a proved `VVecEA2 → VeeExistsForall` biconditional gated on `env 0 < env 1`,
      composing the landed `vvecea2_collapse_of_perClause` — NOT a `sorry`/`def := True` placeholder.
- [ ] Phase 10b (β): `efSat_negation_general` returns a `VeeExistsForall` witness; its signature
      carries `atomMap / h_surj / h_INF / h_SUP` AND `hCapture`; the `z₀<z₁` trichotomy is a proved
      lemma; the `pin k = pin l` diagonal routes to Prop 3.5 negation, not the pair engine.
- [x] Phase 10P (PREREQUISITE): the E[Σ] output-alphabet capture/closure lemma compiles sorry-free,
      axiom-clean, off the live import path; it yields `hCapture` for the ζ `canonExpand` over the
      finite engine-output set `𝔈` (P-a F-closure via `atom_eval_new`). Does NOT reuse
      `hcapture_dischargeable`. NOT a `sorry`/placeholder. LANDED in `ESigmaCapture.lean`.
- [ ] Phases 11-12: γ/δ compile sorry-free with no `VVecEA2`-level rebuild (they consume the landed
      `VeeConj`/`veeConj_iff` and the Phase-10 `VeeExistsForall`-valued negation directly), threading
      `hCapture` (conditional orphans until ζ). *(γ LANDED: `veeSat_negation` in `VeeSatNegation.lean`,
      sorry-free, axiom-clean, off the live path, threads `hCapture`/`hne`, no `VVecEA2` rebuild.
      δ (Phase 12) remains.)*
- [ ] Phase 13 (ζ): the `canonExpand` is constructed, `hCapture` is DISCHARGED via Phase 10P (the
      conditional β/γ/δ results collapse to unconditional), the `nf_nvar_exist_all_depths` match (incl.
      `:562`) is DELETED, and `sorryAx` is confirmed absent.

## Artifacts & Outputs

- plans/11_esigma-capture-threading.md (this file)
- LANDED (Phases 0-9 + `vvecea2_collapse_of_perClause`, preserved — do NOT re-execute):
  `Prop35VeeLift.lean`, `HCaptureDischarge.lean`, `ConjInterleave.lean`, `IntervalType.lean`,
  `VeeConj.lean`, `VVecEA2Collapse.lean` (the 10a-ii `vvecea2_collapse_of_perClause` assembly half),
  plus the Phase 3-8 partial-interval migration of `ExistsForallFormula.lean` / `VeeExistsForall.lean`
  / `ExistsForallLemmas.lean` / `Prop42NegationGeneral.lean` / `Prop35Assembly.lean` /
  `Prop35Chain.lean` / `Prop42ExistsForall.lean`.
- New / extended `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules for THIS revision (names
  provisional): `VVecEA2Collapse.lean` (EXTENDED with the CONDITIONAL `vvecea2_collapse_bridge`
  threading `hCapture`, Phase 10a), `ESigmaCapture.lean` (Phase 10P — the `hCapture` discharge /
  E[Σ] output-alphabet capture-closure lemma), `EFSatNegation.lean` (Phase 10b), `VeeSatNegation.lean`
  (Phase 11), `Prop43Translate.lean` (Phase 12)
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 13 — including `canonExpand` construction + `hCapture`
  discharge)
- summaries/11_esigma-capture-threading-summary.md (on completion)

## Rollback/Contingency

- **Landed Phases 0-9 + `vvecea2_collapse_of_perClause`:** already green and committed; not
  re-executed. If a later phase surfaces a regression in a landed module, revert to the last-green
  commit — do not re-plan Phases 0-9 or the landed assembly half.
- **Phase 10a (CONDITIONAL collapse bridge) failure:** now bounded glue over `hCapture` + the landed
  `vvecea2_collapse_of_perClause`; it EXTENDS `VVecEA2Collapse.lean` additively/off-path, so a failed
  attempt leaves last-green intact. Because the hard capture content is deferred to `hCapture`, a
  failure here is a threading/plumbing defect, not a Def 4.1 wall — fix the clause plumbing, do NOT
  add `sorry`. Phase 10b is blocked on 10a, so no partial-β is committed against a missing bridge.
- **Phase 10P (`hCapture` discharge prerequisite) failure:** THIS is now the highest-risk residual
  (genuine Def 4.1 F-closure content, report 11 Q5). Additive/off-path in a fresh `ESigmaCapture.lean`,
  so a failed attempt leaves last-green intact and does NOT block 10a/10b/11/12 (they consume
  `hCapture` abstractly and land conditional). If P-a and P-b both fail to close, the obstruction is
  genuine Def 4.1 output-alphabet-closure content — STOP and surface for a further `/research` dispatch
  (do NOT force ζ with `sorry`). Phase 13 is blocked on 10P, so `sorryAx` removal waits on it.
- **Phases 10b, 11, 12 failure:** additive/off-path; a failed phase leaves last-green intact and
  resumable. They land as CONDITIONAL orphans gated on `hCapture` — permitted, not a gate violation.
  No new sorry is ever introduced under the amended gate.
- **Phase 13 regression:** the `nf_nvar_exist_all_depths` deletion is done LAST and verified
  immediately with `#print axioms`. If the spine re-wire regresses the build or the axiom set, revert
  the Phase-13 edits (spine re-point + match deletion) to restore the last-green state where the
  migrated modules exist but the old sorry still carries the spine.
