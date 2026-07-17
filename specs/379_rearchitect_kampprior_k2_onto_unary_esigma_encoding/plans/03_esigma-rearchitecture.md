# Implementation Plan: E[Σ] Re-Architecture of KampPrior onto Unary Signature Expansion

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: 36-52 hours (Phase 1 gate ~2-3 h; Phases 2-8 conditional on GO)
- **Dependencies**: None to start (Phase 1 is a self-contained gate). Downstream: task 375 (final axiom audit, `deps:[379]`) consumes Phase 8; task 359 (Boneyard hygiene) owns the post-landing cleanup (roadmap Phase I, out of scope here).
- **Research Inputs**: reports/03_esigma-path-to-completeness-roadmap.md (primary); reports/01_k2-sizing-verdict.md, reports/01_arity-growth-sizing-probe.lean, reports/02_consumption-walk-probe.lean (supporting, machine-checked)
- **Artifacts**: plans/03_esigma-rearchitecture.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:275`) carries exactly one live,
on-path `sorryAx`: the `| _k + 2 =>` arm of `nf_nvar_exist_all_depths` at
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:562`. Research (roadmap §1-2,
machine-checked by `rfl` in probe 01) has adjudicated that this hole is **not a missing lemma**:
`NormalForm sig (k+1) n` is definitionally `(AtomKind sig n → Bool) × (NormalForm sig k (n+1) →
Bool)`, so the quantifier-assignment domain grows arity `n → n+1` per depth descent, and two
descents from the live arity-2 entry force an arity-4 joint type that lives in the k=2
*statement's meaning*. Discharging it in the present architecture requires off-paper novel
mathematics (an arity-4 realization engine / Feferman-Vaught composition) that Rabinovich never
incurs. The faithful path is a **prerequisite re-architecture** onto Rabinovich's E[Σ]
unary-alphabet expansion (Def 4.1, PDF p.5), which folds processed depth into new atoms and caps
free-variable arity at 2 by Lemma 3.2(2).

**Definition of done**: `#print axioms completeness_discrete` no longer lists `sorryAx`, with the
full `lake build` at EXIT 0 (current floor 1765 jobs after task 381) and no new axiom or sorry
introduced anywhere on the proof term. The whole GO-side program (Phases 2-8) is gated on a
single cheap decision point (Phase 1). This plan owns roadmap Phases A-H; Phase I (Boneyard
cleanup) and the final `#print axioms` audit are cross-referenced but out of scope.

### Research Integration

- Roadmap §1 fixes the sole on-path sorry at `KampPrior.lean:562` and confirms via probe 02's
  14,466-dep proof-term walk that the chain `completeness_discrete → countermodel_discrete_reynolds_v2
  → no_gaps_discrete_model_surgery → US_expressively_complete_over_prior →
  kamp_prior_expressive_completeness → nf_characterizable_temporal_prior → nf_nvar_exist_all_depths`
  is value-reached. The two `EANegation.lean` sorries (`:1090`, `:1249`) are OFF the proof term
  (zero external consumers) and are explicitly NOT in scope.
- Roadmap §2 establishes the arity-4 obstruction is type-level (forced by `NormalForm`), not
  evaluator-level, so a local proof change cannot fix it — a statement-level migration is required.
- Roadmap §4 enumerates the confirmed-faithful reusable assets (`VVecEA2.translateRight/translateLeft`
  + `_correct`, `VVecEA2.negFix_iff`, `Prop42Contentful`) and flags the single most dangerous wrong
  turn: adopting the NfEFold evaluator (`nf_eval_efold`, `nf_eval_nfk_iff_efold`) as the migration
  target — axiom-clean but still arity n+1, buying nothing. Only the NfEFold zone/E-atom *vocabulary*
  is reusable.
- Roadmap §5 names the highest-risk unknown: Def 4.1's E[Σ] is countably infinite, but
  `MonadicSignature` (`MonadicFO.lean:41`) requires `Fintype` (load-bearing via `normalForm_fintype`,
  `NormalForm.lean:166`). A finite stage-indexed expansion is plausible but unproven — this is the
  pivot the Phase 1 gate exists to settle.

### Prior Plan Reference

No prior plan in `plans/`. This is the first plan for task 379. The two prior research rounds
(reports 01, 02) plus the roadmap (report 03) are the inputs; three earlier off-plan attempts to
discharge `KampPrior.lean:562` in the present architecture all died on the arity-4 obstruction
(roadmap §2, strategic note at §6). This plan deliberately *dissolves* the arm rather than fills
it.

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. Phase-to-roadmap mapping (report 03 §6):
Phase 1 = roadmap A; Phase 2 = B; Phase 3 = C; Phase 4 = D; Phase 5 = E; Phase 6 = F; Phase 7 = G;
Phase 8 = H. Roadmap Phase I is owned by task 359; the terminal axiom audit is owned by task 375.

## Goals & Non-Goals

**Goals**:
- Decide, cheaply and decisively, whether a finite `Fintype`-respecting E[Σ] signature expansion
  admits an **arity-preserving** depth descent (Phase 1 GO/NO-GO gate).
- On GO: build the faithful E[Σ] expansion + Def 3.1 ∃∀-object + Lemmas 3.2/3.4 + Prop 3.5 + Prop
  4.2 + Prop 4.3, and re-wire the completeness spine so `nf_nvar_exist_all_depths` and its `_k+2`
  sorry are deleted (not filled).
- End state: `#print axioms completeness_discrete` free of `sorryAx`; `lake build` EXIT 0 at >= 1765
  jobs; no new axiom/sorry on the proof term.
- Reuse the confirmed-faithful assets from roadmap §4 rather than rebuilding them.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor
  headers only).

**Non-Goals**:
- Discharging the two off-path `EANegation.lean` sorries (`:1090`, `:1249`) — not on the proof term,
  three-strikes "do not touch".
- Adopting the NfEFold evaluator (`nf_eval_efold` / `nf_eval_nfk_iff_efold`) as the migration
  target — roadmap §4 flags this as the single most dangerous wrong turn (clean axioms, still
  arity n+1).
- Roadmap Phase I (arity-4 Fib DAG archival + Boneyard hygiene) — owned by task 359, becomes trivial
  only after Phase 8 lands.
- The terminal `#print axioms` final-assembly audit — owned by task 375 (`deps:[379]`).
- Any novel off-paper mathematics (arity-4 realization engine, Feferman-Vaught composition).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 1 NO-GO: `Fintype` cannot be derived for `sig.preds ⊕ F`, or descent forces n+1, or F must be infinite | H | M | This is a *designed* outcome, not a failure. Phase 1's DoD makes NO-GO a cheap, valid refutation → escalate task to [BLOCKED] for a user decision on a `MonadicSignature` redesign. No Theories/ edits are risked. |
| Accidentally migrating onto the NfEFold evaluator (arity n+1 trap) | H | M | Non-Goals + every phase's guardrails forbid `nf_eval_efold`/`nf_eval_nfk_iff_efold` as target; reuse zone/atom *vocabulary* only. Verify the new descent is arity-*preserving* by `rfl`/goal inspection, mirroring probe 01's method. |
| Build regression / added axiom during a mid-program phase | H | M | Guardrail on every phase: `lake build` stays EXIT 0 (>= 1765 jobs) and `#print axioms completeness_discrete` must not gain a new axiom. Commit only green sub-steps. New spine work may temporarily route through the old sorry until Phase 8. |
| Off-paper mathematics creeps in (arity-4 realization) | H | L | Faithfulness guardrail: cite Rabinovich by PDF page only (`.md` is corrupt); reuse roadmap §4 assets; Phase 7 inducts over formula structure so no arity-4 obligation can arise. |
| Phase 7 (Prop 4.3, the crux) proves larger than one agent run | M | H | Phase 7 is explicitly the crux; sub-decompose its four induction cases (Atomic / Disjunction / Negation via 3.2(2)+4.2 / ∃ via 3.4) into separate green commits; each case is independently checkable. |
| Stale doc-comment line refs (`Completeness.lean:358,369` cite `:361`/`:364`) mislead the implementer | L | M | Roadmap §1 flags these as stale; the single current site is `KampPrior.lean:562`. Anchor all work to `:562`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 3, 4 |
| 6 | 7 | 2, 3, 4, 5, 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel. **Phases 2-8 are CONDITIONAL ON Phase 1 =
GO** and must not be dispatched until the gate passes; on Phase 1 = NO-GO the task escalates to
[BLOCKED] and Phases 2-8 are not executed.

### Phase 1: E[Σ] feasibility gate [COMPLETED]

**VERDICT: GO.** All three NO-GO conditions machine-checked FALSE; the arity-preserving descent
theorem `esigma_descent` compiles sorry-free (`#print axioms` → `[propext, Classical.choice,
Quot.sound]`, no `sorryAx`) at arity `n` on both sides. Deliverable: `reports/04_esigma-gate-probe.lean`
(compiles EXIT 0 via `lake env lean`). Phases 2-8 are UNBLOCKED.

- **Goal:** Decide GO/NO-GO for a finite, `Fintype`-respecting E[Σ] expansion that admits an
  arity-*preserving* depth descent. Self-contained probe; no `Theories/` edits. This is the single
  decision point on which the entire GO-side program depends.
- **Tasks:**
  - [x] Create a new probe `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/04_esigma-gate-probe.lean` (probe only; NOT under `Theories/`). *(completed)*
  - [x] Define `sigE (sig) (F : Finset Formula) : MonadicSignature` as `sig.preds ⊕ F`, with derived `Fintype` and `DecidableEq` instances that must typecheck (respecting the `MonadicSignature` `Fintype` constraint at `MonadicFO.lean:41`; cross-check `normalForm_fintype` at `NormalForm.lean:166`). *(completed — `sigE := sig.preds ⊕ {A // A ∈ F}`; both instances by `inferInstance`, compiles)*
  - [x] Define the canonical expansion of an `OrderedMonadicStructure` interpreting each new atom `A ∈ F` as `{a | M,a ⊨ A}` (Def 4.1, PDF p.5). *(completed — `canonExpand` with env-independent `sat`)*
  - [x] State and prove the ONE arity-preserving descent theorem: `depth-(k+1) obligation over sig at arity n ↔ depth-k obligation over (sigE sig F) at arity n` — **arity n on BOTH sides, not n+1**. *(completed — `esigma_descent`; arity-(n+1) `Fin.cons x env` replaced by arity-n `sat (Aσ σ) (env anchor)`; sorry-free)*
  - [x] Run the probe to EXIT 0; confirm sorry-free at equal arity by goal/`rfl` inspection (mirror probe 01's method for detecting arity growth). *(completed — EXIT 0; arity facts `rfl`-checked; `#print axioms` shows no `sorryAx`)*
  - [x] Record the explicit **GO / NO-GO verdict** as the phase deliverable. *(completed — GO, recorded in probe header and here)*
- **Definition of Done (binary):** **GO** iff the descent theorem states and compiles **sorry-free at equal arity** on both sides. **NO-GO** on unavoidable `n+1`, an underivable `Fintype`, or an `F` that must be infinite. The GO/NO-GO verdict is the explicit deliverable of this phase. *(MET → GO)*
- **On NO-GO:** escalate the task to **[BLOCKED]** for a user decision on a `MonadicSignature`
  redesign. This is a legitimate structural escalation and a successful cheap refutation — NOT a
  sorry deferral, NOT a failure. Do not proceed to Phase 2.
- **Timing:** 2-3 hours (~1 agent run).
- **Depends on:** none.
- **Files to modify:**
  - `specs/379_.../reports/04_esigma-gate-probe.lean` (new probe; no `Theories/` edits)
- **Guardrails:** No `Theories/` edits, so `lake build` and `#print axioms completeness_discrete`
  are untouched by this phase. Cite Rabinovich by PDF page only.
- **Verification:** Probe compiles EXIT 0; descent theorem is arity-preserving (n on both sides)
  and sorry-free; verdict recorded.

---

### Phase 2: E[Σ] Expansion Layer (roadmap B) [COMPLETED] — CONDITIONAL ON Phase 1 = GO

- **Goal:** Land the stage-indexed finite E[Σ] expansion + canonical-expansion semantics + the
  atom-collapse lemma (a TL-over-E[Σ] formula ≡ an atom), realizing Def 4.1 (p.5) and the p.6
  collapse-to-atom note.
- **Tasks:**
  - [x] Create module(s) under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` (e.g. `ESigmaExpansion.lean`) promoting the Phase-1 probe's `sigE`/canonical-expansion into first-class definitions. *(completed — `ESigmaExpansion.lean`: `sigE`, `esigmaPred`, `oldPred`, `canonExpand`, `esigma_descent` promoted; sorry-free, axioms `[propext, Classical.choice, Quot.sound]`)*
  - [x] Touch `MonadicFO.lean` **only if** the Phase-1 gate showed the expansion must be a first-class signature operation. *(deviation: skipped — `sigE` is definable as a `MonadicSignature` value without any change to `MonadicFO.lean`; the gate showed no first-class signature-operation was required)*
  - [x] Prove the stage-indexed finite expansion respects `Fintype` at every stage (finitely many atoms added per stage per Prop 4.3). *(completed — `sigE_fintypePreds` instance + `finite_F_suffices_per_stage` def)*
  - [x] Prove the atom-collapse lemma: TL(Until,Since)-over-E[Σ] formula ≡ atomic formula in the canonical expansion (p.6). *(completed — `atom_eval_new` (fresh atom for `A ∈ F` ≡ `sat A` at anchor), with conservativity facts `atom_eval_old`/`atom_eval_order`)*
  - [x] Adopt the NfEFold zone/E-atom *vocabulary* (`NormalFormEFold`, `EAtomDom`, `ZoneSpec`, `zoneHolds` in `Kamp/NfEFold.lean`) where convenient — but NOT the fold evaluator. *(deviation: altered — kept module minimal/self-contained (imports only `NormalForm` + `Formula`); NfEFold vocabulary referenced in the design-notes docstring rather than imported, to avoid a heavy dependency; the fold evaluator `nf_eval_efold` is not routed through, per guardrail)*
- **Timing:** 4-6 hours.
- **Depends on:** 1.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaExpansion.lean` (new)
  - `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` (only if gate required first-class op)
- **Guardrails:** `lake build` EXIT 0 (>= 1765 jobs); no new axiom/sorry on `completeness_discrete`;
  do NOT adopt `nf_eval_efold`/`nf_eval_nfk_iff_efold`; durable-anchor headers only (no task numbers).
- **Verification:** New module compiles; `Fintype` derivation holds at each stage; atom-collapse
  lemma sorry-free; full build green.

---

### Phase 3: Def 3.1 ∃∀-Formula Object (roadmap C) [COMPLETED] — CONDITIONAL ON Phase 1 = GO

- **Goal:** Introduce the Def 3.1 (p.4) object — ordered existential prefix `∃xₙ…∃x₀` with strict
  ordering, unary QF point types `αⱼ(xⱼ)`, and interval types `βⱼ` on `(x_{j-1}, xⱼ)` — with atoms
  drawn from E[Σ]. This replaces `NormalForm sig k n` on the completeness spine.
- **Tasks:**
  - [x] Define the new ∃∀-formula type (ordered-existential-prefix / unary-α / β-interval), with atoms drawn from the Phase-2 E[Σ] alphabet. *(completed — `ExistsForallFormula sig F r`: `n` (points), `pointType : Fin (n+1) → UnaryType`, `intervalType : Fin (n+2) → UnaryType`; `UnaryType := NormalForm (sigE sig F) 0 1` faithfully encodes Def 3.1's "QF formula with one variable" over the E[Σ] alphabet)*
  - [x] Encode free-variable pinning to existentials by indices `i₀…i_m ∈ {0..n}` (Def 3.1) so free vars are NOT independent arity. *(completed — `pin : Fin r → Fin (n+1)`; `efSat`'s pinning clause `∀ k, env k = x (ψ.pin k)`; the arity cap is structural — every point/interval type is arity 1)*
  - [x] Provide the semantics (satisfaction) of the object over an `OrderedMonadicStructure`. *(completed — `efSat`: `∃` strictly-monotone witness points, pinning, point types via `unaryHolds`, before/between/after interval types on open intervals — the literal Def 3.1 reading; basic facts `efSat_strictMono`, `efSat_pinned`)*
- **Timing:** 4-6 hours.
- **Depends on:** 2.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallFormula.lean` (new; name provisional)
- **Guardrails:** `lake build` EXIT 0; no new axiom/sorry on the spine; the new object's arity is
  capped by construction (free vars pinned, not independent); durable-anchor headers only.
- **Verification:** New type + semantics compile sorry-free; free-variable pinning encoded; full
  build green.

---

### Phase 4: Lemma 3.2 + Lemma 3.4 (roadmap D) [PARTIAL] — CONDITIONAL ON Phase 1 = GO

**PARTIAL (advanced across three dispatches).** Landed sorry-free:
- `VeeExistsForall.lean`: Def 3.3 ∨∃∀ layer (`VeeExistsForall`, `veeSat`, `veeSat_append` =
  Lemma 3.4 ∨-closure).
- `ExistsForallLemmas.lean` §§1-5: the **conjunctive dual** `ConjExistsForall`
  (≤2-free-var target) + `conjSat` with nil/cons/append closure; `pairProject` (2-free-var
  projection); **Lemma 3.2(2) forward direction** (`lemma_32_2_forward`); **Lemma 3.2(3)**
  (`dropPin` + `lemma_32_3`, existential closure of the ∃∀ fragment); **Lemma 3.4 ∃-closure**
  (`veeSat_exists`).
- `ExistsForallLemmas.lean` §6 (this dispatch): **Lemma 3.2(2) backward infrastructure** —
  `pairwiseProjections_sat` (extract any pair's projection), `pairProject_pins` (unfold pins of a
  projection chain), `env_lt_of_pin_lt` / `env_eq_of_pin_eq` (**order reflection**: `env` respects
  the strict/eq order of the pin map), `pointType_holds_at_env` (point type holds at a pinned env
  value), `unaryHolds_subinterval` (**intrinsic sub-interval monotonicity** — the key fact that a
  unary type holding on `(a,b)` holds on any narrower `(a',b')`, because `unaryHolds` depends only
  on the carrier point).
- `ExistsForallLemmas.lean` §7 (this dispatch): the **augmented backward target** —
  `existenceSentence` (0-free-var chain-existence content, the r=0 fix), `AugConjExistsForall` /
  `augConjSat` / `augTarget`, `existenceSentence_of_efSat`, **`augTarget_forward`** (forward into
  the augmented target), and **`augTarget_backward_zero`** (backward at arity 0, the base case the
  pure pairwise conjunction could not supply).

All axiom-clean `[propext, Classical.choice, Quot.sound]`; full build EXIT 0 at 1769 jobs;
`completeness_discrete` axiom set unchanged.

- `ExistsForallLemmas.lean` §8 (this dispatch): **Lemma 3.2(2) backward direction, general `r`**
  (`augTarget_backward`) + the full biconditional (`augTarget_iff`) — the load-bearing ≤2-free-var
  cap is now a proved theorem. The piecewise chain gluing: `pinnedPositions`/`idxOf`,
  `loPos`/`hiPos` (nearest bracketing pins, clamped), `chainOf` (the pairwise-projection chain of a
  pair), `gluedChain` (reads each position from its bracket chain), `consecChain` (consecutive
  positions share one bracket chain), discharging all six `efSat` clauses sorry-free, axiom-clean
  `[propext, Classical.choice, Quot.sound]`.

**Still remaining** (both OFF the completeness critical path — Phase 7's Prop 4.3 induction uses
the basis {Atomic, Disjunction/∨, Negation/¬, ∃}, consuming Lemma 3.2(2) + Lemma 3.4 ∨/∃-closure
only, never a conjunction case; these two are Rabinovich-Lemma-3.4-faithfulness extras, not spine
dependencies): **Lemma 3.2(1)** (conjunction of two ∃∀-formulas ≡ disjunction of ∃∀-formulas via
order-preserving interleavings of the two ordered chains — a large self-contained combinatorial
construction, ~500+ lines: enumerate the interleavings, merge point/interval types by conjunction
per pattern) and **Lemma 3.4 ∧-closure** (distributes over disjunction, then applies 3.2(1)). No
sorry introduced; un-proved lemmas simply do not yet exist.

- **Goal:** Prove Lemma 3.2(1)(2)(3) (p.4) and Lemma 3.4 closure under ∨/∧/∃ (p.5) on the Phase-3
  object. **Lemma 3.2(2)'s ≤2-free-variable cap is the load-bearing arity bound** — the whole point
  of the re-architecture.
- **Tasks:**
  - [ ] Prove Lemma 3.2(1), (2), (3) on the Phase-3 ∃∀-object. *(deviation: partial — 3.2(3) PROVED (`lemma_32_3` via `dropPin`); 3.2(2) FULLY PROVED (`augTarget_iff`, both directions); 3.2(1) still deferred (interleavings — off the completeness critical path: Phase 7's Prop 4.3 induction uses the basis {Atomic, ∨, ¬, ∃}, so it consumes 3.2(2) + 3.4 ∨/∃-closure only, never a conjunction case). Foundation: `VeeExistsForall`/`veeSat` (∨-target) and `ConjExistsForall`/`conjSat` (∧-target) both exist)*
  - [x] Prove Lemma 3.2(2) explicitly: every ∃∀-formula ≡ a conjunction of ∃∀-formulas with **at most two free variables** (this is what caps arity at 2). *(completed — the load-bearing ≤2-free-var cap is now a proved biconditional `augTarget_iff : efSat N env ψ ↔ augConjSat N env (augTarget ψ)`. Forward `augTarget_forward`; backward `augTarget_backward` (general `r`) landed this dispatch via the §8 piecewise chain gluing: `gluedChain` reads each position from the pairwise-projection chain of its bracketing pins (`loPos`/`hiPos`), and consecutive positions share one bracket chain (`consecChain`), so StrictMono + interval types transfer directly. Sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`.)*
  - [ ] Prove Lemma 3.4 closure under ∨, ∧, ∃ on the Phase-3 object. *(deviation: partial — ∨-closure PROVED (`veeSat_append`); ∃-closure PROVED this dispatch (`veeSat_exists` via 3.2(3)); ∧-closure (needs 3.2(1)) still deferred)*
- **Timing:** 6-8 hours.
- **Depends on:** 3.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean` (new; name provisional)
- **Guardrails:** `lake build` EXIT 0; no new axiom/sorry on the spine; the ≤2-free-var cap must be
  a proved theorem about the Phase-3 object (not asserted); durable-anchor headers only.
- **Verification:** Lemmas 3.2(1)(2)(3) and 3.4 compile sorry-free; the 2-free-var cap is
  established as a theorem; full build green.

---

### Phase 5: Prop 3.5 (∨∃∀, one free var → TL) (roadmap E) [IN PROGRESS] — CONDITIONAL ON Phase 1 = GO

- **Goal:** Build the faithful replacement for `nf_nvar_exist_all_depths` on the Phase-3 object,
  realizing Prop 3.5 (p.5) — the `A_k ∧ (B_{k+1} Until …)` chain and its `Since` mirror — with heavy
  reuse.
- **Tasks:**
  - [ ] Realize Prop 3.5's right/future chain, reusing `VVecEA2.translateRight` + `_correct` (`NfToVecEA.lean:413,447,451`).
  - [ ] Realize Prop 3.5's left/past mirror, reusing `VVecEA2.translateLeft` + `_correct` (`VecEATranslation.lean:515,541,549`).
  - [ ] Confirm the reused chain builders already match the Phase-3 target shape; re-target where the object differs.
- **Timing:** 4-6 hours (heavy reuse).
- **Depends on:** 3, 4.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop35ExistsForall.lean` (new; name provisional)
- **Guardrails:** `lake build` EXIT 0; no new axiom/sorry on the spine; reuse the confirmed-faithful
  `translateRight`/`translateLeft` assets rather than rebuilding; durable-anchor headers only.
- **Verification:** Prop 3.5 chains compile sorry-free on the Phase-3 object; reuse wired; full build
  green.

---

### Phase 6: Prop 4.2 (closure under negation, ≤2 free vars) (roadmap F) [NOT STARTED] — CONDITIONAL ON Phase 1 = GO

- **Goal:** Realize Prop 4.2 (p.6/§5) on the Phase-3 object by re-targeting the sorry-free, on-path
  negation-closure engine.
- **Tasks:**
  - [ ] Re-target `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`) to the Phase-3 ∃∀-object.
  - [ ] Reuse the `Prop42Contentful` packaging + its sorry-free instance (`Prop42Contentful.lean:139,281`) for the structural induction Prop 4.3 needs.
  - [ ] Confirm no dependence on the off-path bare `EANegation.lean:1090/1249` variants (zero external consumers; leave untouched).
- **Timing:** 3-4 hours (reuse / re-target; likely least-changed asset).
- **Depends on:** 3, 4.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ExistsForall.lean` (new; name provisional)
- **Guardrails:** `lake build` EXIT 0; no new axiom/sorry on the spine; reuse `VVecEA2.negFix_iff` /
  `Prop42Contentful` (sorry-free today); do NOT touch `EANegation.lean:1090/1249`; durable-anchor
  headers only.
- **Verification:** Prop 4.2 compiles sorry-free on the Phase-3 object; full build green.

---

### Phase 7: Prop 4.3 (structural induction over formulas) (roadmap G) [NOT STARTED] — CONDITIONAL ON Phase 1 = GO

- **Goal:** THE CRUX. Build the faithful replacement for `nf_characterizable_temporal_prior` —
  induction over **formula structure**, not depth; processed content becomes an E[Σ] atom at each
  step, so **no arity growth, no per-k arms, and no arity-4 obligation ever arises**. Realizes Prop
  4.3 (p.6): Atomic / Disjunction / Negation (via 3.2(2)+4.2) / ∃ (via 3.4).
- **Tasks:**
  - [ ] Prove the Atomic case (an E[Σ] atom is directly an ∃∀-formula, quantifier depth 0).
  - [ ] Prove the Disjunction case (via Lemma 3.4 ∨-closure).
  - [ ] Prove the Negation case (via Lemma 3.2(2) ≤2-free-var cap + Prop 4.2 negation closure).
  - [ ] Prove the ∃ case (via Lemma 3.4 ∃-closure).
  - [ ] Assemble the structural induction so processed depth folds into E[Σ] atoms (Phase 2), never accumulating as joint arity.
  - [ ] Commit each case as a separate green sub-step (crux phase; sub-decompose).
- **Timing:** 8-12 hours (the crux; sub-decompose into the four induction cases).
- **Depends on:** 2, 3, 4, 5, 6.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Structural.lean` (new; name provisional)
- **Guardrails:** `lake build` EXIT 0; no new axiom/sorry on the spine; induction is over formula
  structure (NOT depth) so the arity-4 obligation cannot arise; no off-paper mathematics; cite
  Rabinovich by PDF page; durable-anchor headers only.
- **Verification:** All four Prop 4.3 cases compile sorry-free; the assembled induction introduces
  no arity growth (verify by goal inspection); full build green.

---

### Phase 8: Re-wire the Spine and Retire the Sorry (roadmap H) [NOT STARTED] — CONDITIONAL ON Phase 1 = GO

- **Goal:** Re-wire the completeness spine onto the Phase 2-7 structural path and **delete** the
  entire `nf_nvar_exist_all_depths` `match` (arms + the `_k+2` sorry at `KampPrior.lean:562`),
  realizing Thm 4.4 (p.6) = Prop 4.3 + Prop 3.5. This is what makes the sorry *disappear* rather than
  be filled.
- **Tasks:**
  - [ ] Re-point `kamp_prior_expressive_completeness` and `US_expressively_complete_over_prior` at the Phase-7 Prop 4.3 replacement.
  - [ ] Re-wire `no_gaps_discrete_model_surgery` and, transitively, `completeness_discrete` (`Completeness.lean:275`) onto the new spine.
  - [ ] Delete the entire `nf_nvar_exist_all_depths` `match` (all arms + the `_k+2` sorry at `KampPrior.lean:562`, rationale block `:507-561`).
  - [ ] Update the in-file axiom-audit block (`Completeness.lean:341-372`) and fix the stale doc-comment refs (`:358`, `:369` citing `:361`/`:364`).
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is gone.
- **Timing:** 3-4 hours.
- **Depends on:** 7.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (delete the match + sorry)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-wire + audit block)
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files
- **Guardrails:** `lake build` EXIT 0 (>= 1765 jobs); **the goal of this phase is to REMOVE `sorryAx`
  from `#print axioms completeness_discrete`** — it must not ADD any axiom or sorry; durable-anchor
  headers only (no task numbers in `Theories/`).
- **Verification:** `#print axioms completeness_discrete` no longer lists `sorryAx` (still lists
  `propext`, `Classical.choice`, `Quot.sound`, and the `native_decide`-sourced
  `Lean.ofReduceBool`/`Lean.trustCompiler`); full `lake build` EXIT 0. Hand off to task 375 for the
  terminal audit.

## Testing & Validation

- [ ] Phase 1: probe `04_esigma-gate-probe.lean` compiles EXIT 0; descent theorem arity-preserving
      (n on both sides) and sorry-free; explicit GO/NO-GO verdict recorded.
- [ ] Every GO-side phase: `lake build` returns EXIT 0 at >= 1765 jobs.
- [ ] Every GO-side phase: `#print axioms completeness_discrete` gains no new axiom or `sorryAx`
      (new work may temporarily route through the old sorry until Phase 8).
- [ ] Phase 8 (terminal): `#print axioms completeness_discrete` no longer lists `sorryAx`.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task number.
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold` as a migration target anywhere in the new
      spine.
- [ ] Rabinovich citations are by PDF page only (companion `.md` is corrupt).

## Artifacts & Outputs

- plans/03_esigma-rearchitecture.md (this file)
- specs/379_.../reports/04_esigma-gate-probe.lean (Phase 1 probe; GO/NO-GO deliverable)
- New `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules (Phases 2-7; names provisional:
  `ESigmaExpansion.lean`, `ExistsForallFormula.lean`, `ExistsForallLemmas.lean`,
  `Prop35ExistsForall.lean`, `Prop42ExistsForall.lean`, `Prop43Structural.lean`)
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 8)
- summaries/03_esigma-rearchitecture-summary.md (on completion)

## Rollback/Contingency

- **Phase 1 NO-GO:** no `Theories/` edits were made; escalate the task to [BLOCKED] with the
  refutation (unavoidable n+1 / underivable Fintype / infinite F) for a user decision on a
  `MonadicSignature` redesign. Nothing to revert.
- **GO-side phase failure:** each phase commits only green sub-steps; a failed phase leaves the last
  green state intact and resumable. New modules are additive (Phases 2-7 do not touch the live spine
  until Phase 8), so an incomplete GO-side program still builds EXIT 0 with the old `_k+2` sorry in
  place — the spine is not degraded mid-program.
- **Phase 8 regression:** if the spine re-wire regresses the build or the axiom set, revert the
  Phase-8 edits (spine re-point + match deletion) to restore the last-green state where the new
  modules exist but the old sorry still carries the spine; the deletion is the only step that removes
  the fallback, so it is done last and verified immediately.
