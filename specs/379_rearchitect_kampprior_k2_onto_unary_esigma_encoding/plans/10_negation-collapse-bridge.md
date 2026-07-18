# Implementation Plan: E[Σ] Collapse-Bridge Negation — Resolving the `VVecEA2 → VeeExistsForall` Seam, Retiring `KampPrior.lean:562`

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: ~35-56 hours remaining across 4 not-started phases (Phases 0-9 COMPLETED, sorry-free and landed); ~1,200-2,100 new Lean lines. Phases 0-9 are PRESERVED — do NOT re-execute.
- **Dependencies**: None to start (Phases 0-9 landed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 13; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here).
- **Research Inputs**: reports/07_faithful-esigma-negation-path.md (authoritative phase-structure source for the negation spine; its R4 "true crux" = the E[Σ] atom-collapse (Def 4.1) is exactly the seam this revision schedules); handoffs/phase-10-blocked-handoff-20260718T151013.md (GOVERNING for this revision — the verified two-axis Phase-10 blocker); reports/09_conjinterleave-interval-type-audit.md (partial-interval adjudication, integrated in plan 09); reports/05_conjunction-closure-load-bearing-verdict.md (conjunction-closure load-bearing verdict); reports/06_phase4-unblock-construction.md (option-(b) engine, landed)
- **Artifacts**: plans/10_negation-collapse-bridge.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

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

**This revision (plan 10) resolves the verified Phase-10 (β) blocker** recorded in
`handoffs/phase-10-blocked-handoff-20260718T151013.md`. Phase 10 as written in plan 09 was not
implementable, confirmed on two independent axes: (Axis 1 — object-type seam) the mandated per-pair
base case `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean`) is **`VVecEA2`-valued**
(`v'.holds N atomMap (env 0)(env 1) ↔ ¬ efSat …`), but Phase 10's target, its downstream consumers
(Phase 11 γ `veeSat_negation`, Phase 12 δ `translate`), and its flatten step (`veeSat_append`) are
all **`VeeExistsForall`/`veeSat`-valued** — and an exhaustive grep confirms **no
`VVecEA2 → VeeExistsForall` bridge exists anywhere under `Theories/`** (every translation, including
`translateVeeProp42`, runs FORWARD `VeeExistsForall → VVecEA2`). (Axis 2 — insufficient hypotheses)
Phase 10's stated signature carried only `ψ, env, StrictMono env`, missing the
`atomMap / h_surj / HasAttainedINF / HasAttainedSUP` the base-case engine requires.

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

Concretely, this revision **preserves Phases 0-9 verbatim** and **restructures Phase 10 (β)** so its
first component is the collapse bridge `vvecea2_collapse_bridge`
(`VVecEA2 → VeeExistsForall`, Def 4.1), with Phase 10's signature augmented by
`atomMap / h_surj / h_INF / h_SUP` (Axis 2). Phases 11 (γ), 12 (δ), and 13 (ζ) keep their plan-09
intent and numbering — **ζ remains the terminal Phase 13** retiring `KampPrior.lean:562`.

**Definition of done**: `#print axioms completeness_discrete` no longer lists `sorryAx`, with the
full `lake build` at EXIT 0 (floor 1769 jobs) and no new axiom or non-permitted sorry anywhere on
the proof term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool,
Lean.trustCompiler, Quot.sound]` — with `sorryAx` REMOVED (Phase 13 deletes the sole on-path
`KampPrior.lean:562` sorry).

### Research Integration

- **Phase-10 BLOCKED handoff (`handoffs/phase-10-blocked-handoff-20260718T151013.md`, GOVERNING for
  this revision; newly integrated)**: records the verified two-axis blocker — (Axis 1) the negation
  engine is `VVecEA2`-valued with no reverse bridge to `VeeExistsForall`; (Axis 2) Phase 10's
  signature lacks `atomMap / h_surj / h_INF / h_SUP`. Confirms the De Morgan half of β
  (`augTarget_iff` → ordered-pair disjunction + existence-sentence negation) is sound and reusable
  once the object type is fixed. Its unblock Option 1 (dedicated collapse bridge before β) is
  **adopted** here; Option 2 is rejected (see Overview adjudication).
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

Supersedes `plans/09_partial-interval-rearchitecture.md`. Plan 09's **Phases 0-9 are carried forward
VERBATIM** (all COMPLETED, sorry-free, landed green; `conjInterleave_iff` and `veeConj_iff` are full
biconditionals and the `conjInterleave_forward` strategic sorry is retired). Plan 09's Phase 10 (β)
was BLOCKED on the object-type seam; this plan **restructures Phase 10** to interpose the
`vvecea2_collapse_bridge` (Def 4.1 E[Σ] collapse) as its first component and augment its signature
with the four missing hypotheses, so β again produces a `VeeExistsForall` witness. Plan 09's Phases
11 (γ), 12 (δ), 13 (ζ) are **unchanged in intent and numbering** — the whole point of choosing
Option 1 is that no cascade reaches them. ζ remains the terminal Phase 13.

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. No roadmap review/update phases are added.

## Goals & Non-Goals

**Goals**:
- **Preserve all landed sorry-free work (Phases 0-9) VERBATIM** — the ε interface, the partial
  `IntervalType := Finset UnaryType` migration, and the full `conjInterleave_iff` / `veeConj_iff`
  biconditionals. Do NOT re-execute them.
- **Close the Phase-10 object-type seam** by proving the `vvecea2_collapse_bridge`
  (`VVecEA2 → VeeExistsForall`, Def 4.1 E[Σ] atom-collapse, PDF p.5-6) — the genuine reverse of the
  landed forward bridge `translateVeeProp42`, report 07 R4's "true crux".
- **Augment Phase 10's signature** with `atomMap / h_surj / HasAttainedINF / HasAttainedSUP` (Axis 2
  of the blocker) and thread them to `prop42_efSat_negation_general` and the collapse bridge.
- Assemble β (`efSat_negation_general`) at the `VeeExistsForall` type by lifting each per-pair
  `VVecEA2` engine output through the bridge, so γ (Phase 11) and δ (Phase 12) rest UNCHANGED on the
  landed `VeeExistsForall`-valued machinery (no `VVecEA2`-level rebuild) — the payoff of Option 1.
- Retire `KampPrior.lean:562` by DISSOLVING the `_k+2` arm (deleting `nf_nvar_exist_all_depths`) via
  the faithful E[Σ] structural-induction path (Phase 13 ζ, terminal).
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
| The `VVecEA2 → VeeExistsForall` collapse bridge (Phase 10a) is the E[Σ] atom-collapse (Def 4.1) — report 07 R4 "true crux", HIGH-risk; it may exceed one dispatch or hide a wall | H | M | Bound Phase 10a to the arity-2 `VVecEA2` shape only (a disjunction of endpoint-`TemporalPred` + `BracketFormula` clauses), reusing the landed Def 4.1 apparatus: `ESigmaExpansion.lean`'s atom-collapse facts (`atom_eval_new/_old`, `esigma_descent`), `HCaptureDischarge.lean`'s general `hcapture` discharge, and `Lemma53.lean`'s `VBracketFormula.toVVecEA2_holds` + the "bracket ≡ Lemma 5.3 `∃…∧⋀Pᵢ(xᵢ)`" note for the bracket-clause → Def-3.1 `∃∀` chain. Split contingency (H8): 10a-i = the single-`TemporalPred`-clause and single-`BracketFormula`-clause collapse lemmas + correctness; 10a-ii = disjunctive assembly over clauses via `veeSat_append` → the full `vvecea2_collapse_bridge`. Each green. If a wall appears, it is a genuine Def 4.1 obstruction to surface for a research dispatch, NOT to paper over with `sorry`. |
| δ `translate` structural induction larger than one run | M | H | Phase 12 sub-decomposes by connective case (atom / lt / and / or / not / ex); each independently green; `and`→Phase 9 `veeConj_iff`, `not`→Phase 11, `or`/`ex`→landed helpers; atom/`lt` emit partial intervals directly. |
| Phase 13 (ζ) live-path rewire regresses the spine or fails to remove `sorryAx` | H | M | Do the `nf_nvar_exist_all_depths` deletion LAST and verify immediately with `#print axioms`; keep the old sorry carrying the spine until the new path is wired green; rollback = revert the spine re-point + match deletion to last-green (migrated modules present, old sorry intact). |
| Off-paper mathematics or footnote-2 mis-citation persists | H | L | Per-phase faithfulness anchor to a report-09/07 H3 row; drop the `ConjInterleave.lean` docstring's footnote-2 citation on its next edit (Phase 9), replacing it with Def 3.1 + Lemma 3.2(1)/3.4 grounding per the audit's H4 correction. |

## Implementation Phases

**Dependency Analysis** (Phases 0-9 are LANDED/COMPLETED — shown for provenance; the active waves
are 8-11 covering Phases 10-13):
| Wave | Phases | Blocked by | State |
|------|--------|------------|-------|
| 1 | 0 | -- | COMPLETED |
| 2 | 1, 2 | 0 | COMPLETED |
| 3 | 3 | 2 | COMPLETED |
| 4 | 4 | 3 | COMPLETED |
| 5 | 5, 6, 7 | 4 | COMPLETED |
| 6 | 8 | 5, 6, 7 | COMPLETED |
| 7 | 9 | 8 | COMPLETED |
| 8 | 10 | 9, 6 | NOT STARTED (resumes here) |
| 9 | 11 | 10 | NOT STARTED |
| 10 | 12 | 11 | NOT STARTED |
| 11 | 13 | 12 | NOT STARTED |

Phases within the same wave can execute in parallel. **Phases 0-9 are landed sorry-free — do NOT
re-execute them.** Implementation resumes at Wave 8 (Phase 10 β). Phase 10 depends on the landed
Phase 9 (`veeConj_iff`) and the Phase-6-migrated `prop42_efSat_negation_general` engine (both
COMPLETED). Phase 10 carries an internal H8 split (10a collapse bridge → 10b β assembly); the split
is within one phase, not a new wave. Phases 10-12 stay OFF the live import path; only Phase 13
touches the spine, so `#print axioms completeness_discrete` is UNCHANGED at every boundary through
Phase 12 (the pre-existing `KampPrior.lean:562` `sorryAx` remains the sole on-path sorry until Phase
13 deletes it).

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

### Phase 10: β — collapse bridge + single-∃∀ negation over unordered pairs [BLOCKED]

**BLOCKER** (Phase 10a — the E[Σ] collapse crux, verified 2026-07-18):
- **What failed**: `vvecea2_collapse_bridge` cannot be discharged at the stated signature (general
  `N`, `atomMap`, `h_surj`, `HasAttainedINF`, `HasAttainedSUP`). The per-clause reverse translation
  it requires — `VecEA2` clause → `ExistsForallFormula sig F 2` with `efSat ↔ vea.holds` — is the
  genuine Def 4.1 atom-collapse (report 07 R4 "true crux") and has no discharge under these
  hypotheses.
- **What was tried / verified (source-grounded, not speculative)**:
  1. `prop42_efSat_negation_general` emits
     `v' = (negLeftClauseTL).disj ((middleBracket).negFix) |>.disj (negRightClauseTL)`
     (`Prop42NegationGeneral.lean:997-1004`). Every non-trivial disjunct carries an **arbitrary
     `TL(Until,Since)` `Formula`** at its endpoint: `negLeftClauseTL = ⟨Formula.neg (belowFormula …)⟩`
     (`:919`), `negRightClauseTL = ⟨Formula.neg (aboveFormula …)⟩` (`:950`), and
     `(middleBracket …).negFix` (the Lemma 5.1 INF/`K⁺` engine). **None** is a `unaryToFormula`-image
     of a `UnaryType`.
  2. A `VeeExistsForall`'s atomic content is `UnaryType`/`IntervalType`
     (`ExistsForallFormula.lean:57,87`), i.e. a truth assignment to the **unary E[Σ] predicates at a
     single point** (`unaryHolds_iff`, `ExistsForallFormula.lean:67`). A `UnaryType` can express only
     conjunctions of E[Σ] atomic literals at the point — capturing an arbitrary `TL` formula requires
     the E[Σ] atom-collapse of a **processed** formula, i.e. `ESigmaExpansion.atom_eval_new`
     (`ESigmaExpansion.lean:122`), which holds **on `canonExpand …`** — a *definability/capture*
     property that the bridge's general `N` does not carry.
  3. The revised signature's added hypotheses do NOT supply capture: `HasAttainedINF`/`HasAttainedSUP`
     are first-occurrence **attainment** facts (`PriorINF.lean:202,254`), not definability; `h_surj`
     names each `pred` with an `Atom`, not each `TL` formula with a `pred`. An exhaustive grep found
     **no reverse translation** (`TL → ∃∀`, `Formula → UnaryType`, `translateProp35`-inverse) anywhere
     under `Theories/`; every `ExistsForallFormula` producer builds from existing `UnaryType`s.
- **Why stuck (root cause)**: this is the same **class** as the original Phase-10 Axis-2 gap
  (insufficient hypotheses). The revision added `atomMap/h_surj/h_INF/h_SUP`, but the reverse E[Σ]
  collapse actually needs an **E[Σ]-definability/capture hypothesis** on `N` — that a `TL` formula over
  the processed alphabet is realized by a `UnaryType` in `N` (the `canonExpand` property) — which is
  still absent. Building the reverse `TL → ∃∀` translation from scratch is Kamp's hard expressiveness
  direction, out of scope for a bridge dispatch reusing existing anchors.
- **What is needed (concrete)**: a research dispatch to (a) determine the exact E[Σ]-capture
  hypothesis the collapse requires (likely: `N` is a `canonExpand`, or a `∀ A, ∃ τ : UnaryType,
  ∀ y, unaryHolds N τ y ↔ temporal_truth N atomMap y A`-style definability assumption over the
  relevant finite formula set), (b) verify it is available where β is consumed (Phases 11-13), and
  (c) re-scope Phase 10a with that hypothesis threaded. The reusable anchors named in the plan
  (`atom_eval_new`, `esigma_descent`, `hcapture`) all presuppose the canonical expansion, confirming
  the capture hypothesis is the missing piece.
- **Prohibited (honored)**: NO `sorry`, `def X := True`, or vacuous placeholder was introduced. The
  spine axiom set is byte-identical to baseline
  (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`).
- **Delivered green this dispatch**: the sorry-free, axiom-clean, off-path **10a-ii assembly half**
  `vvecea2_collapse_of_perClause` (`VVecEA2Collapse.lean`) — the `map`-over-disjuncts reduction that
  isolates the blocker as the explicit `trans`/`htrans` per-clause obligation (`#print axioms` =
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`). Whoever discharges the capture hypothesis
  (10a-i) composes it through this lemma to obtain the full bridge.

Restructured from the plan-09 BLOCKED phase. The plan-09 β target
(`efSat_negation_general … : ∃ Φ : VeeExistsForall …, ¬ efSat ↔ veeSat Φ`) is retained, but the
object-type seam is closed by interposing the **`vvecea2_collapse_bridge`** (Def 4.1 E[Σ]
atom-collapse) so the `VVecEA2`-valued engine output is lifted to a `VeeExistsForall` disjunct
BEFORE the `veeSat_append` flatten, and the signature is augmented with the four hypotheses the
engine requires. **Declared H8 split**: 10a (collapse bridge) → 10b (β assembly). Each component ends
green + sorry-free + off the live import path.

- **Faithfulness anchor:** report-07 R4 + H3 rows "Def 4.1 + collapse note, p.5-6" (the
  `VVecEA2 → VeeExistsForall` re-expression IS the atom-collapse), "Prop 4.3 ¬-case assembly"
  (single-∃∀), "Prop 4.2" (reused engine), "Lemma 3.2(2)" (`augTarget_iff`), "Prop 3.5" (diagonal
  1-free-var negation).

#### Phase 10a — `vvecea2_collapse_bridge` (Def 4.1 E[Σ] collapse) [component; H8 split point] [BLOCKED]

*(BLOCKED on the 10a-i per-clause E[Σ] collapse — see the Phase 10 BLOCKER block above. The 10a-ii
disjunctive-assembly half landed green as `vvecea2_collapse_of_perClause` in `VVecEA2Collapse.lean`,
isolating the blocker as the explicit `trans`/`htrans` per-clause obligation.)*

- **Goal:** Prove the reverse bridge that the engine's `VVecEA2` output requires — the genuine E[Σ]
  atom-collapse content (report 07 R4 "true crux"):
  ```
  theorem vvecea2_collapse_bridge {sig : MonadicSignature} {F : Finset Formula}
      (N : OrderedMonadicStructure (sigE sig F))
      (atomMap : Formula → (sigE sig F).preds)
      (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
      (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
      (v' : VVecEA2) :
      ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSat N env Φ ↔ v'.holds N atomMap (env 0) (env 1))
  ```
  This is the reverse of the landed forward bridge `translateVeeProp42` (`VeeExistsForall → VVecEA2`);
  no reverse bridge exists yet (exhaustive grep confirmed), so this is genuine new content, NOT glue.
- **Mechanism (faithful, Def 4.1 p.5-6):** a `VVecEA2` is a disjunction of clauses, each an endpoint
  `TemporalPred` (a TL(Until,Since) formula over E[Σ] predicates) or a `BracketFormula`. By the Def
  4.1 collapse note (p.6), a TL(Until,Since)-over-E[Σ] formula collapses to an atomic formula in the
  canonical expansion — i.e. re-enters a Def-3.1 `∃∀` object as a unary E[Σ] point/interval atom. The
  `BracketFormula` bracket is exactly Lemma 5.3's `∃x₁…∃xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ Pᵢ(xᵢ)`, a
  Def-3.1 `∃∀` chain. Assemble the per-clause `∃∀` objects into one `VeeExistsForall` by disjunction
  (`veeSat_append`, landed).
- **Reuse anchors (existing, sorry-free):** `ESigmaExpansion.lean` atom-collapse facts
  (`atom_eval_new`/`atom_eval_old`, `esigma_descent`); `HCaptureDischarge.lean` general `hcapture`
  discharge (Phase 1); `Lemma53.lean` `VBracketFormula.toVVecEA2_holds` + the Lemma-5.3 bracket
  readback; `VeeExistsForall.lean` `veeSat_append`.
- **Split contingency (H8):** if 10a exceeds one dispatch, split into **10a-i** (the
  single-`TemporalPred`-clause and single-`BracketFormula`-clause collapse lemmas + their
  `↔ v'.holds` correctness) and **10a-ii** (disjunctive assembly over clauses → the full
  `vvecea2_collapse_bridge`), each ending green.
- **Tasks:**
  - [x] State `vvecea2_collapse_bridge` at the signature above; introduce a new module
        `VVecEA2Collapse.lean`. *(deviation: altered — the module was created and the disjunctive
        assembly `vvecea2_collapse_of_perClause` was stated/proved instead of the full bridge, which
        is BLOCKED; see below.)*
  - [ ] Prove the single-clause collapse for a `TemporalPred` clause (Def 4.1 collapse note → unary
        E[Σ] atom on a Def-3.1 chain), correctness `↔ clause.holds`. *(BLOCKED — verified no discharge
        under the stated hypotheses; needs an E[Σ]-capture hypothesis. See the Phase 10 BLOCKER.)*
  - [ ] Prove the single-clause collapse for a `BracketFormula` clause (Lemma 5.3 bracket → Def-3.1
        `∃∀` chain), correctness `↔ clause.holds`, reusing `VBracketFormula.toVVecEA2_holds`.
        *(BLOCKED — same root cause: the bracket's `pointTypes`/`segmentTypes` are arbitrary
        `TemporalPred`s in the engine output, not `UnaryType` images.)*
  - [x] Assemble the disjunction over all clauses into one `VeeExistsForall`; conclude the full
        biconditional gated on `env 0 < env 1`, **conditional on the per-clause translation**. *(Landed
        green as `vvecea2_collapse_of_perClause` — the assembly half, taking `trans`/`htrans` as inputs.)*
- **Definition of Done:** `vvecea2_collapse_bridge` compiles sorry-free, axiom-clean (`#print axioms`
  = `[propext, Classical.choice, Quot.sound]` or subset, no `sorryAx`); off the live import path
  (grep-audited); full `lake build` EXIT 0.
- **Timing:** 10-16 hours (~400-700 lines; the genuine Def 4.1 content, HIGH-risk per report 07 R4).
- **Depends on:** 9 (for `VeeExistsForall`/`veeSat_append` machinery), 1 (`hcapture` discharge).
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean` (new; name provisional).

#### Phase 10b — `efSat_negation_general` assembly [component; consumes 10a]

- **Goal:** Prove β at the `VeeExistsForall` type, now reachable:
  ```
  theorem efSat_negation_general {sig : MonadicSignature} {F : Finset Formula}
      (N : OrderedMonadicStructure (sigE sig F))
      (atomMap : Formula → (sigE sig F).preds)
      (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
      (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
      {r : Nat} (ψ : ExistsForallFormula sig F r) :
      ∃ Φ : VeeExistsForall sig F r, ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ efSat N env ψ ↔ veeSat N env Φ)
  ```
  **Note the augmented signature** (Axis 2 of the blocker): `atomMap`, `h_surj`, `h_INF`, `h_SUP`
  are now carried (they were absent in plan 09), threaded to `prop42_efSat_negation_general` and
  `vvecea2_collapse_bridge`.
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
  - [ ] De Morgan the migrated `augTarget_iff` decomposition into the ordered-pair disjunction plus
        the existence-sentence negation (the sound half verified in the plan-09 blocked dispatch).
  - [ ] Per pair: invoke `prop42_efSat_negation_general` (orientation forced by `StrictMono`), then
        `vvecea2_collapse_bridge` to obtain a `VeeExistsForall` disjunct.
  - [ ] Prove the trichotomy lemma explicitly; route the `pin k = pin l` diagonal to Prop 3.5
        negation (NOT the pair engine).
  - [ ] Negate the existence sentence; bridge it; flatten all disjuncts via `veeSat_append`.
- **Definition of Done:** `efSat_negation_general` compiles sorry-free, axiom-clean; the trichotomy is
  a proved lemma; off the live import path; full `lake build` EXIT 0 at 1769 jobs.
- **Timing:** 6-10 hours (~300-500 lines; trichotomy/pin bookkeeping + existence-sentence negation +
  the per-pair bridge plumbing).
- **Depends on:** 10a, 9, 6.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean` (new; name provisional).
- **Prohibited:** Do NOT use `sorry`, `def X := True`, or a vacuous placeholder to paper over any
  residual seam. If 10a cannot close (a genuine Def 4.1 obstruction), STOP and surface it for a
  research dispatch rather than forcing β.

---

### Phase 11: γ — ∨∃∀ negation [NOT STARTED]

- **Goal:** Prove `veeSat_negation (Φ : VeeExistsForall sig F r) : ∃ Φ', ∀ env, StrictMono env →
  (¬ veeSat N env Φ ↔ veeSat N env Φ')` (carrying the same `N / atomMap / h_surj / h_INF / h_SUP`
  hypotheses that β now threads — see Phase 10b). Faithful to Prop 4.3's disjunction-negation
  sub-case (p.6): `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by β (now `VeeExistsForall`-valued via
  the Phase-10a collapse bridge); reassemble `⋀` of ∨∃∀ into ∨∃∀ via the full `veeConj_iff` (landed
  Phase 9). **Unchanged in shape from plan 09** — the Option-1 choice keeps γ resting directly on the
  landed `VeeExistsForall`-valued `veeConj_iff`, with no `VVecEA2`-level rebuild.
- **Faithfulness anchor:** report-07/09 H3 rows "Prop 4.3 ¬-case assembly" (∨∃∀ part) + "Lemma 3.4
  (∧)" (`veeConj_iff`).
- **Tasks:**
  - [ ] De Morgan `¬veeSat (∨φᵢ)` into `⋀ᵢ ¬φᵢ`.
  - [ ] Apply `efSat_negation_general` (β) per disjunct.
  - [ ] Reassemble via `veeConj_iff` (Phase 9); fold over the disjuncts.
- **Timing:** 3-5 hours (~100-200 lines; glue).
- **Depends on:** 9, 10.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VeeSatNegation.lean` (new; name provisional)
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
  h_INF / h_SUP` hypotheses threaded from β); ex (`veeSat_exists`, landed). Do NOT revive the BLOCKED
  `Prop43.lean` over `VVecEA_m`.
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
  `nf_characterizable_temporal_prior` through Thm 4.4 = Prop 4.3 (δ) + Prop 3.5 (ε), wire in the
  Phase 1 `hcapture` discharge and the Phase 0 semantic `MonadicFormula → characteristic NormalForm`
  bridge, and **delete the entire `nf_nvar_exist_all_depths` match including the `:562` sorry.** The
  sole live-path phase; the H4 highest-risk interface, de-risked by Phases 0 and 1.
- **Faithfulness anchor:** report-07/09 H3 row "Thm 4.4, p.6" (rewire + delete
  `nf_nvar_exist_all_depths` incl. `:562`).
- **Tasks:**
  - [ ] Wire the Phase 0 semantic object-language bridge into the live spine.
  - [ ] Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery` onto the Phase 12 `translate` + Phase 1 Prop 3.5 lift +
        Phase 1 `hcapture` discharge.
  - [ ] Verify the new path is green with the old sorry still present (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths` match (all arms + the `:562` sorry +
        its rationale block); update the in-file axiom-audit block and any stale doc-comment refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Timing:** 8-14 hours (~300-600 lines).
- **Depends on:** 1, 12.
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
      other sorry.
- [ ] Phases 10-12 deliverables stay OFF the live import path (`KampPrior.lean` does not import them);
      verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, or `Prop43Structural.lean`-style hole is introduced.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number
      or a Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page).
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks (Phases 0-9 already passed and are landed):
- [ ] Phase 10a (collapse bridge): `vvecea2_collapse_bridge` compiles sorry-free, axiom-clean, off
      the live import path; it is a proved `VVecEA2 → VeeExistsForall` biconditional gated on
      `env 0 < env 1` — NOT a `sorry`/`def := True` placeholder.
- [ ] Phase 10b (β): `efSat_negation_general` returns a `VeeExistsForall` witness; its signature
      carries `atomMap / h_surj / h_INF / h_SUP`; the `z₀<z₁` trichotomy is a proved lemma; the
      `pin k = pin l` diagonal routes to Prop 3.5 negation, not the pair engine.
- [ ] Phases 11-12: γ/δ compile sorry-free with no `VVecEA2`-level rebuild (they consume the landed
      `VeeConj`/`veeConj_iff` and the Phase-10 `VeeExistsForall`-valued negation directly).
- [ ] Phase 13 (ζ): the `nf_nvar_exist_all_depths` match (incl. `:562`) is DELETED and `sorryAx` is
      confirmed absent.

## Artifacts & Outputs

- plans/10_negation-collapse-bridge.md (this file)
- LANDED (Phases 0-9, preserved): `Prop35VeeLift.lean`, `HCaptureDischarge.lean`,
  `ConjInterleave.lean`, `IntervalType.lean`, `VeeConj.lean`, plus the Phase 3-8 partial-interval
  migration of `ExistsForallFormula.lean` / `VeeExistsForall.lean` / `ExistsForallLemmas.lean` /
  `Prop42NegationGeneral.lean` / `Prop35Assembly.lean` / `Prop35Chain.lean` / `Prop42ExistsForall.lean`.
- New `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules for THIS revision (names provisional):
  `VVecEA2Collapse.lean` (Phase 10a), `EFSatNegation.lean` (Phase 10b),
  `VeeSatNegation.lean` (Phase 11), `Prop43Translate.lean` (Phase 12)
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 13)
- summaries/10_negation-collapse-bridge-summary.md (on completion)

## Rollback/Contingency

- **Landed Phases 0-9:** already green and committed; not re-executed. If a later phase surfaces a
  regression in a landed module, revert to the last-green commit — do not re-plan Phases 0-9.
- **Phase 10a (collapse bridge) failure:** the highest-risk new content (Def 4.1, report 07 R4). It
  is additive/off-path in a fresh `VVecEA2Collapse.lean`, so a failed attempt leaves last-green
  intact. If the H8 split 10a-i/10a-ii still cannot close, the obstruction is genuine Def 4.1
  content — STOP and surface it for a `/research` dispatch (do NOT force with `sorry`). Phase 10b and
  everything after it are blocked on 10a, so no partial-β is committed against a missing bridge.
- **Phases 10b, 11, 12 failure:** additive/off-path; a failed phase leaves last-green intact and
  resumable. No new sorry is ever introduced under the amended gate.
- **Phase 13 regression:** the `nf_nvar_exist_all_depths` deletion is done LAST and verified
  immediately with `#print axioms`. If the spine re-wire regresses the build or the axiom set, revert
  the Phase-13 edits (spine re-point + match deletion) to restore the last-green state where the
  migrated modules exist but the old sorry still carries the spine.
