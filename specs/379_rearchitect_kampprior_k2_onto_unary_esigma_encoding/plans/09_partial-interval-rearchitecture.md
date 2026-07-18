# Implementation Plan: Partial-Interval E[Σ] Negation Re-Architecture — Retiring `KampPrior.lean:562`

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: ~75-110 hours remaining across 11 not-started phases (Phases 0-1 COMPLETED, Phase 2 PARTIAL); ~2,600-4,300 new/migrated Lean lines
- **Dependencies**: None to start (Phases 0-2 landed). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 13; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns post-landing cleanup (out of scope here).
- **Research Inputs**: reports/09_conjinterleave-interval-type-audit.md (GOVERNING — machine-checked design adjudication; the reason for this revision); reports/07_faithful-esigma-negation-path.md (authoritative phase-structure source for the negation spine); reports/05_conjunction-closure-load-bearing-verdict.md (conjunction-closure load-bearing verdict); reports/06_phase4-unblock-construction.md (option-(b) engine, landed); handoffs/phase-2-handoff-20260718T102303.md (Phase 2 state + DESIGN FINDING)
- **Artifacts**: plans/09_partial-interval-rearchitecture.md (this file)
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

This revision preserves Phases 0-2 verbatim, then **interposes a partial-type migration** (the
audit's "Phase 2.5", decomposed into six hard-mode-sized phases 3-8 by module cluster so the
~3,000-line landed critical path — `prop42_efSat_negation_general`, `ExistsForallLemmas`,
`Prop35Assembly`/`Prop35Chain`/`Prop42ExistsForall`, spanning 225 `.intervalType`/`.pointType` refs
across 13 files — migrates one green `lake build` at a time), and finally **restates Phases 9-13**
(the α-part-2 / β / γ / δ / ζ mathematics) on the partial-type representation. The full
`conjInterleave_iff` becomes provable, which unlocks the full `veeConj_iff` biconditional the
spine's γ and δ `and`-case consume.

**Definition of done**: `#print axioms completeness_discrete` no longer lists `sorryAx`, with the
full `lake build` at EXIT 0 (floor 1769 jobs) and no new axiom or non-permitted sorry anywhere on
the proof term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool,
Lean.trustCompiler, Quot.sound]` — with `sorryAx` REMOVED (Phase 13 deletes the sole on-path
`KampPrior.lean:562` sorry).

### Research Integration

- **Report 09 (GOVERNING — machine-checked audit; newly integrated in this revision)**: CONFIRMS
  the refutation (empty-interval mismatch + irreducible disjunctive-∀), adjudicates **Option (A)
  partial interval types** as the sole faithful and downstream-sufficient fix, establishes the
  blast radius (RE-SCOPE: 225 refs / 13 files / ~3,000 lines), and prescribes the corrected
  sequencing: interpose a partial-type migration before a restated Phase 3, with the merged interval
  type = `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂` and empty slots vacuously satisfied. Its H3
  reference-grounding table maps each Rabinovich locus (Def 3.1 p.4, Lemma 3.2(1)/3.4 p.4-5, Prop
  3.5 p.5, Prop 4.3 p.6, Thm 4.4 p.6) to the target Lean identifier. Its H4 correction: the
  forced-empty mechanism is grounded on Def 3.1 + Lemma 3.2(1)/3.4, **not** footnote 2 (which is
  about `P Until Q`'s negation); the module docstring's footnote-2 citation is to be dropped on the
  next edit.
- **Report 07 (authoritative for the negation spine)**: supplies the faithful phase structure α-ζ
  and the H4 elevation of the ζ/ε seam to the true crux (retired by the landed Phases 0-1). Its
  H3 table anchors the restated Phases 9-13.
- **Report 05 (build on)**: conjunction-closure (Lemma 3.2(1)/3.4-∧) is load-bearing INSIDE the
  Prop 4.3 negation case (p.6) — why the α restatement is on the critical path, and why the full
  (not directional) `veeConj_iff` is required.
- **Report 06 (build on)**: the arbitrary-pin Prop 4.2 engine `prop42_efSat_negation_general` is
  LANDED and reused as the per-pair base case in Phase 10 (β) — after Phase 6 migrates its
  interval clauses to partial types.

### Prior Plan Reference

Supersedes `plans/08_esigma-negation-rearchitecture.md`. Plan 08's Phases 0-2 are carried forward
unchanged (0-1 COMPLETED, 2 PARTIAL). Plan 08's Phase 2 DESIGN FINDING correctly identified that the
backward/iff direction needs partial interval types but deferred the representation choice to "an
orchestrator/user decision"; report 09 has now made that decision (Option (A), `Finset UnaryType`)
and established the migration is a re-scope, not a Phase-3-local change. Plan 08's Phases 3-7 (the
α-part-2 / β / γ / δ / ζ mathematics) are **restated** here as Phases 9-13 on the partial-type
representation; their shape is largely preserved (γ and ζ unchanged in intent), with the α
restatement now targeting the FULL biconditional and δ's atom/`lt` base cases now emitting partial
intervals directly — the case that was impossible on complete types.

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. No roadmap review/update phases are added.

## Goals & Non-Goals

**Goals**:
- Preserve all landed sorry-free work (Phases 0-1) and the Phase 2 merge apparatus; carry the single
  tracked `conjInterleave_forward` strategic sorry forward as an explicit continuation item,
  discharged on the partial representation in Phase 9.
- Refine the interval representation to **partial** types `IntervalType := Finset UnaryType`
  (admissible-completion sets), faithful to Rabinovich Def 3.1 (PDF p.4); point types stay complete
  `UnaryType`.
- Migrate the ~3,000-line landed critical path to the partial satisfaction relation in
  cluster-scoped, individually-green phases (3-8), ending with the field-type flip localized because
  every consumer already routes through the `intervalHolds`/`ofComplete` abstraction.
- Prove the **full** `conjInterleave_iff` biconditional under partial-interval satisfaction (merged
  interval = `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂`, empty slots vacuously satisfied),
  unlocking the full `veeConj_iff` the spine's γ (Phase 11) and δ `and`-case (Phase 12) require.
- Assemble β/γ/δ on the partial-type `efSat`/`veeSat` layer, with δ's atom/`lt` base cases emitting
  partial intervals directly.
- Retire `KampPrior.lean:562` by DISSOLVING the `_k+2` arm (deleting `nf_nvar_exist_all_depths`) via
  the faithful E[Σ] structural-induction path.
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
  `nf_nvar_exist_all_depths | _k+2` (retired in Phase 13), `EANegation.lean:1090`,
  `EANegation.lean:1249`, and the single tracked `conjInterleave_forward` continuation sorry
  (retired in Phase 9). No phase may introduce any other sorry or any new axiom.
- **Point types stay complete `UnaryType`; only interval types become partial `Finset UnaryType`.**

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Field-type flip breaks all 225 consumer refs in one build (cannot stay green) | H | H | **Abstraction-first / widen-last.** Introduce `intervalHolds`/`ofComplete` (Phase 3), route `efSat`'s interval clauses through `intervalHolds (ofComplete …)` with a propositional-equality bridge lemma (Phase 4), migrate each consumer cluster to the bridge in isolation (Phases 5-7), then widen the stored field to genuine `Finset` LAST (Phase 8) — localized because every consumer already routes through `intervalHolds`. Each phase ends with full `lake build` EXIT 0. |
| A consumer cluster cannot migrate green in isolation because the `efSat` clause change is not definitionally transparent | H | M | Use the derived-accessor technique: keep the complete-typed field, add a derived `IntervalType` accessor + `intervalHolds_ofComplete_iff` bridge, and expose `efSat` interval-clause unfold lemmas so each downstream proof migrates via a one-line rewrite. Never change the stored field until Phase 8. |
| `Prop42NegationGeneral.lean` (1004 lines) interval-clause migration exceeds one agent run | M | H | Phase 6 is scoped to `efIntervalTP` generalization (complete type → set-disjunction of complete-type translations) + `belowFormula`/`aboveFormula`/`middleBracket` + their correctness lemmas; if it overflows, split into 6a (`efIntervalTP` + `belowFormula`) and 6b (`aboveFormula`/`middleBracket` + assembly), each green. Declared in the phase. |
| Full `conjInterleave_iff` still hides a wall on partial types | H | L | The audit gives the exact merge rule (merged interval = `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂`; empty slot vacuous; nonempty forces `S₁∩S₂≠∅` at each point) and both proof directions (forward realizes the intersection at each merged point; backward projects `e₁`/`e₂` and `intervalHolds (S₁∩S₂) → intervalHolds Sₖ`). Machine-checked feasibility: `Fintype`+`DecidableEq (NormalForm sig k n)` (`NormalForm.lean:167-182`) give `Finset UnaryType`, `∩`, `univ`, decidable `∃ τ ∈ S`. |
| δ `translate` structural induction larger than one run | M | H | Phase 12 sub-decomposes by connective case (atom / lt / and / or / not / ex); each independently green; `and`→Phase 9 `veeConj_iff`, `not`→Phase 11, `or`/`ex`→landed helpers; atom/`lt` emit partial intervals directly. |
| Phase 13 (ζ) live-path rewire regresses the spine or fails to remove `sorryAx` | H | M | Do the `nf_nvar_exist_all_depths` deletion LAST and verify immediately with `#print axioms`; keep the old sorry carrying the spine until the new path is wired green; rollback = revert the spine re-point + match deletion to last-green (migrated modules present, old sorry intact). |
| Off-paper mathematics or footnote-2 mis-citation persists | H | L | Per-phase faithfulness anchor to a report-09/07 H3 row; drop the `ConjInterleave.lean` docstring's footnote-2 citation on its next edit (Phase 9), replacing it with Def 3.1 + Lemma 3.2(1)/3.4 grounding per the audit's H4 correction. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 2 | 0 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6, 7 | 4 |
| 6 | 8 | 5, 6, 7 |
| 7 | 9 | 8 |
| 8 | 10 | 9 |
| 9 | 11 | 10 |
| 10 | 12 | 11 |
| 11 | 13 | 12 |

Phases within the same wave can execute in parallel. Wave 5 (Phases 5, 6, 7) is a **territory-split
(H7)**: each migrates a disjoint file cluster and can run concurrently. Phases 0-12 stay OFF the live
import path; only Phase 13 touches the spine, so `#print axioms completeness_discrete` is UNCHANGED
at every boundary through Phase 12 (the pre-existing `KampPrior.lean:562` `sorryAx` remains the sole
on-path sorry until Phase 13 deletes it).

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

### Phase 9: α (restated) — full `conjInterleave_iff` under partial intervals + `veeConj` / `veeConj_iff` [NOT STARTED]

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
  - [ ] Redefine the merged interval type to `intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t)`
        (= `S₁ ∩ S₂`); keep point-consistency as the point filter; do NOT filter interval slots on
        mismatch — a mismatched slot carries `S₁ ∩ S₂` (possibly `∅`), vacuously satisfied when empty.
  - [ ] Discharge the FORWARD direction (re-deriving the carried Phase 2 sorry): the realized
        rank-merge realizes `S₁ ∩ S₂` at each merged interval point (each witness realizes both
        chains' interval types → a common completion). Retire the tracked `conjInterleave_forward`
        strategic sorry here.
  - [ ] Prove the BACKWARD direction: from a merged disjunct, project `e₁`/`e₂` to recover both
        chains; `intervalHolds (S₁ ∩ S₂)` at every point of every ψₖ-interval gives `intervalHolds Sₖ`
        (monotonicity, Phase 3 algebra), discharging each chain's interval clause.
  - [ ] Define `veeConj (Φ₁ Φ₂ : VeeExistsForall …)` by distributing ∧ over the disjunctions applying
        `conjInterleave` per pair; prove `veeConj_iff : veeSat (veeConj Φ₁ Φ₂) ↔ veeSat Φ₁ ∧ veeSat Φ₂`
        (full biconditional).
  - [ ] Update the module docstring: remove the footnote-2 citation; cite Def 3.1 (p.4) + Lemma
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

### Phase 10: β — single-∃∀ negation over unordered pairs [NOT STARTED]

- **Goal:** Prove `efSat_negation_general (ψ : ExistsForallFormula sig F r) : ∃ Φ : VeeExistsForall
  sig F r, ∀ env, StrictMono env → (¬ efSat N env ψ ↔ veeSat N env Φ)`, reusing the Phase-6-migrated
  `prop42_efSat_negation_general` as the per-pair base case. Faithful to Prop 4.3's single-∃∀
  negation sub-case (p.6) via `augTarget_iff` (Lemma 3.2(2), migrated Phase 5).
- **Faithfulness anchor:** report-07/09 H3 rows "Prop 4.3 ¬-case assembly" (single-∃∀), "Prop 4.2"
  (reused engine), "Lemma 3.2(2)" (`augTarget_iff`), "Prop 3.5" (diagonal 1-free-var negation).
- **Tasks:**
  - [ ] De Morgan the `augTarget_iff` decomposition: `¬efSat ψ` into the disjunction over all ordered
        pairs `(k,l)` plus the existence-sentence negation.
  - [ ] Discharge each per-pair `¬efSat (pairProject ψ k l)` via `prop42_efSat_negation_general` in
        the `StrictMono`-forced orientation; assemble the **trichotomy lemma** explicitly
        (`pin k ≠ pin l ⟹ env k ≠ env l`, one orientation matches the engine's gate; `pin k = pin l`
        diagonal routes to Prop 3.5 negation, NOT the pair engine).
  - [ ] Negate the existence sentence (`r=0`) via the same engine at arity 0/1.
  - [ ] Flatten all disjuncts into one `VeeExistsForall` via the landed `veeSat_append`.
- **Timing:** 6-10 hours (~300-500 lines; trichotomy/pin bookkeeping + existence-sentence negation).
- **Depends on:** 9, 6.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean` (new; name provisional)
- **Verification:** `efSat_negation_general` compiles sorry-free, axiom-clean; the trichotomy is a
  proved lemma; off the live import path; full `lake build` EXIT 0 at 1769 jobs.

---

### Phase 11: γ — ∨∃∀ negation [NOT STARTED]

- **Goal:** Prove `veeSat_negation (Φ : VeeExistsForall sig F r) : ∃ Φ', ∀ env, StrictMono env →
  (¬ veeSat N env Φ ↔ veeSat N env Φ')`. Faithful to Prop 4.3's disjunction-negation sub-case
  (p.6): `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by β; reassemble `⋀` of ∨∃∀ into ∨∃∀ via the
  full `veeConj_iff` (Phase 9). Unchanged in shape from plan 08 — now rests on the genuine full
  biconditional.
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
  (`veeSat_append`, landed); not (`veeSat_negation`, Phase 11); ex (`veeSat_exists`, landed). Do NOT
  revive the BLOCKED `Prop43.lean` over `VVecEA_m`.
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
      (until Phase 13), `EANegation.lean:1090`, `EANegation.lean:1249`, and the tracked
      `conjInterleave_forward` sorry (until Phase 9). No phase introduces any other sorry.
- [ ] Phases 3-12 deliverables stay OFF the live import path (`KampPrior.lean` does not import them);
      verified by grep / import audit each phase.
- [ ] No `def X := True`, vacuous placeholder, or `Prop43Structural.lean`-style hole is introduced.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number
      or a Rabinovich line number (durable-anchor headers only; Rabinovich cited by PDF page).
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold`, no `chain_split`, no
      `EANegation.lean:1090`/`:1249` edits, no `NfEFold.lean` rebuild.

Phase-gate checks:
- [ ] Phases 3-8 (migration): each ends with full `lake build` EXIT 0 and `#print axioms
      completeness_discrete` UNCHANGED; the field is genuinely `Finset UnaryType` after Phase 8.
- [ ] Phase 9 (α restated): `conjInterleave_iff` is a FULL biconditional; the `conjInterleave_forward`
      strategic sorry is retired; the footnote-2 docstring citation is dropped.
- [ ] Phase 10 (β): the `z₀<z₁` trichotomy is a proved lemma; the `pin k = pin l` diagonal routes to
      Prop 3.5 negation, not the pair engine.
- [ ] Phase 13 (ζ): the `nf_nvar_exist_all_depths` match (incl. `:562`) is DELETED and `sorryAx` is
      confirmed absent.

## Artifacts & Outputs

- plans/09_partial-interval-rearchitecture.md (this file)
- New `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules (names provisional):
  `IntervalType.lean` (Phase 3), `VeeConj.lean` (Phase 9), `EFSatNegation.lean` (Phase 10),
  `VeeSatNegation.lean` (Phase 11), `Prop43Translate.lean` (Phase 12)
- Migrated existing modules: `ExistsForallFormula.lean`, `VeeExistsForall.lean`,
  `ExistsForallLemmas.lean`, `Prop42NegationGeneral.lean`, `Prop35Assembly.lean`,
  `Prop35Chain.lean`, `Prop42ExistsForall.lean`, `ConjInterleave.lean` (Phases 4-9)
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 13)
- summaries/09_partial-interval-rearchitecture-summary.md (on completion)

## Rollback/Contingency

- **Migration phases (3-8) failure:** each phase commits only green sub-steps and (through Phase 7)
  keeps the stored field complete-typed, so a failed phase leaves the last green state intact and
  resumable. The live spine keeps the old `:562` sorry and builds EXIT 0 throughout. Phase 8 (the
  flip) is the one structural break; if it regresses, revert the field-type change (consumers already
  route through `intervalHolds`, so the revert is localized to the field + accessor + constructors).
- **Restated math phases (9-12) failure:** additive/off-path; a failed phase leaves last-green
  intact. The `conjInterleave_forward` sorry (retired in Phase 9) or, if Phase 9 fails, the tracked
  sorry persists under the amended gate — never a new sorry.
- **Phase 13 regression:** the `nf_nvar_exist_all_depths` deletion is done LAST and verified
  immediately with `#print axioms`. If the spine re-wire regresses the build or the axiom set, revert
  the Phase-13 edits (spine re-point + match deletion) to restore the last-green state where the
  migrated modules exist but the old sorry still carries the spine.
