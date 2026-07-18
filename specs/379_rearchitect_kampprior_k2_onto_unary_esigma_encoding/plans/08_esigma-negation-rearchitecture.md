# Implementation Plan: Faithful E[Σ] Negation Re-Architecture — Retiring `KampPrior.lean:562`

- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: 51-83 hours (representative ~68 h across 8 phases; ~2,170-3,730 new Lean lines)
- **Dependencies**: None to start (Phase 0 is a self-contained cheap gate). Downstream: task 375 (final `#print axioms` audit, `deps:[379]`) consumes Phase 7; task 359 (Boneyard hygiene / arity-4 apparatus archival) owns the post-landing cleanup (out of scope here).
- **Research Inputs**: reports/07_faithful-esigma-negation-path.md (AUTHORITATIVE — supersedes earlier inventories); reports/03_esigma-path-to-completeness-roadmap.md (diagnosis only; asset inventory stale); reports/05_conjunction-closure-load-bearing-verdict.md (conjunction-closure load-bearing verdict); reports/06_phase4-unblock-construction.md (option-(b) engine, since landed)
- **Artifacts**: plans/08_esigma-negation-rearchitecture.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The completeness spine `Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`) carries exactly one live, on-path
`sorryAx`: the `| _k + 2 =>` arm of `nf_nvar_exist_all_depths` at
`KampPrior.lean:562`. Report 07 (authoritative, H2/H3/H4) establishes that the faithful Rabinovich
mechanism never forms an arity-≥2 joint type: atoms are unary (Def 3.1, PDF p.4), free variables
are pinned to a single ordered chain, Lemma 3.2(2) caps negation at two free variables, and E[Σ]
folds processed depth into **unary** atoms (Def 4.1, p.5). The K₄/arity-4 wall is a `NormalForm`
artifact (`AtomKind.order` on every pair, `NormalForm.lean:60`), which the `efSat` single-`StrictMono`-path
encoding dissolves. **Most of the re-architecture scaffold is already built sorry-free and off the
live import path** — the E[Σ] expansion (`sigE`, `esigma_descent`), the Def 3.1 object
(`ExistsForallFormula`/`efSat`), Lemmas 3.2(2)/(3) and 3.4(∨/∃), Prop 3.5 (`translateProp35`), and
the arbitrary-pin 2-variable negation engine (`prop42_efSat_negation_general`, report 06's option
(b), now landed green). The residual to retire `:562` is three concrete pieces plus the spine
rewire: conjunction closure (`conjInterleave`, the one truly-unbuilt combinatorial core), the
negation-case assembly reusing the landed engine, the structural Prop 4.3 `translate`, and the
`NormalForm`↔`MonadicFormula` spine rewire.

This plan turns report 07's phases α-ζ into a formal phased implementation. Per report 07's H4
adversarial pass, the **highest residual risk is the Phase ζ/ε spine-rewire seam** (the
`NormalForm`↔`MonadicFormula` object-language bridge and the `esigma_descent.hcapture` discharge),
NOT the negation mathematics — the older roadmap under-weighted this as "merely structural." The
plan therefore **front-loads a cheap de-risking spike (Phase 0) and the full ε discharge (Phase 1)
before the large `conjInterleave` build**, so a spine-rewire wall is discovered cheaply rather than
after ~800 lines of α are sunk. Every phase is independently green-committable, lands sorry-free,
and stays off the live import path until the Phase 7 (ζ) rewire.

**Definition of done**: `#print axioms completeness_discrete` no longer lists `sorryAx`, with the
full `lake build` at EXIT 0 (floor 1769 jobs) and no new axiom or sorry introduced anywhere on the
proof term. Target end-state axiom set: `[propext, Classical.choice, Lean.ofReduceBool,
Lean.trustCompiler, Quot.sound]` — with `sorryAx` REMOVED (Phase 7 deletes the sole pre-existing
`KampPrior.lean:562` sorry; no other pre-existing on-path sorry exists).

### Research Integration

- **Report 07 (authoritative)**: supplies the H3 reference-grounding table (Rabinovich PDF §/page →
  concept → target Lean signature → status/line-estimate), the faithful re-architecture phases α-ζ,
  and the H4 adversarial risk assessment. Its central corrections to the earlier inventory: the
  E[Σ] scaffold AND `prop42_efSat_negation_general` are already landed sorry-free; the genuine
  remainder is α (conjunction closure), β/γ (negation assembly), δ (structural Prop 4.3), ε (Prop
  3.5 lift + `hcapture` discharge), ζ (spine rewire). Its H4 elevation of ζ/ε to the true crux
  drives this plan's risk-ordering.
- **Report 05 (build on)**: conjunction-closure (Lemma 3.2(1)/3.4-∧) is load-bearing INSIDE the
  Prop 4.3 negation case, confirmed by the source (p.6). This is why Phase 2-3 (α) is on the
  critical path, not optional cleanup.
- **Report 06 (build on)**: option (b) — a direct arbitrary-pin Prop 4.2 rather than folding caps
  to trivial (option (a), unsound) — is confirmed and LANDED as `prop42_efSat_negation_general`.
  Reused verbatim as the per-pair base case in Phase 4 (β).
- **Report 03 (diagnosis only)**: its arity-4 diagnosis is faithful; its asset inventory and
  "Phase A gate must run first" framing are STALE (the gate has passed; the scaffold is built). Not
  used for phase structure.

### Prior Plan Reference

Supersedes `plans/03_esigma-rearchitecture.md`. Plan 03's diagnosis is faithful, but its asset
inventory is stale (report 07 corrects it) and its Phase 7 is BLOCKED precisely at the
arbitrary-pin negation seam that report 06's now-landed engine and report 07's phases β/γ resolve.
This plan does NOT re-plan already-landed assets (E[Σ] layer, Def 3.1 object, Lemmas 3.2(2)/(3),
3.4(∨/∃), Prop 3.5, Prop 4.2-general). Effort calibration reuses plan 03's per-phase timings where
the work overlaps (e.g. Prop 3.5 heavy-reuse ~4-6 h; the crux structural phase ~8-16 h) and its
sequencing discipline (green + sorry-free + off-path; no forcing `sorry`) verbatim. Lesson carried
forward: plan 03's Phase 7 block came from treating conjunction-closure as conditionally-off-path
and the spine rewire as "structural, no theorem content" — both corrected here (α on the critical
path; ζ/ε front-loaded as the true crux).

### Roadmap Alignment

No `ROADMAP.md` roadmap flag was set for this dispatch. No roadmap review/update phases are added.

## Goals & Non-Goals

**Goals**:
- Retire `KampPrior.lean:562` by DISSOLVING the `_k+2` arm (deleting `nf_nvar_exist_all_depths`),
  not filling it — via the faithful E[Σ] structural-induction path.
- Cheaply de-risk the `NormalForm`↔`MonadicFormula` spine-rewire seam and the
  `esigma_descent.hcapture` discharge EARLY (Phase 0 spike + Phase 1 full ε), before sinking effort
  into the large `conjInterleave` build.
- Build the one genuinely-unbuilt combinatorial core (`conjInterleave`, Lemma 3.2(1)/3.4-∧) as an
  order-preserving path merge — NO K₄, no arity growth.
- Assemble the Prop 4.3 negation case reusing the landed `prop42_efSat_negation_general` as the
  per-pair base case, with the `z₀<z₁` gate handled as a benign trichotomy over the total order.
- Build the structural `translate : MonadicFormula sig m → VeeExistsForall sig F m` (Prop 4.3) by
  induction over formula structure — no NF-depth, no arity tower.
- End state: `#print axioms completeness_discrete` free of `sorryAx`; `lake build` EXIT 0 at 1769
  jobs; no new axiom/sorry on the proof term.
- Keep every deliverable file outside `specs/**` free of task-number references (durable-anchor
  headers only, citing Rabinovich by PDF page and sibling module names).

**Non-Goals**:
- Reviving the BLOCKED `Prop43.lean` over `VVecEA_m` (`Prop43.lean:120-170`) — its uniform
  connective cases are documented blocked; the new `translate` is over the `efSat`/`VeeExistsForall`
  object where α/γ supply the missing pieces.
- Any arity-4 realization engine, Feferman-Vaught composition, or joint-type-over-a-tuple — the
  path never forms one (unary atoms + path merge).
- Adopting the NfEFold evaluator (`nf_eval_efold`/`nf_eval_nfk_iff_efold`) as the migration target
  (axiom-clean but retains arity n+1 — buys nothing).
- Discharging the two off-path `EANegation.lean` sorries (`:1090`, `:1249`) — zero external
  consumers, not on the proof term.
- The terminal `#print axioms` final-assembly audit (task 375) and the arity-4 apparatus archival
  (task 359).
- Any `sorry`, `def X := True`, vacuous placeholder, or `Prop43Structural.lean`-style hole in the
  negation/assembly/spine cases.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **ζ/ε spine-rewire seam is not viable** (`NormalForm`↔`MonadicFormula` bridge or `hcapture` discharge hides a wall) — the H4 highest-risk item | H | M | **Phase 0 front-loads a cheap minimal-case spike** proving the seam viable BEFORE the α sink. NO-GO escalates to [BLOCKED] after ~4-6 h, not after ~800 lines of α. Phase 1 then discharges the full ε off-path, retiring the crux risk before α completes. |
| Phase 4 (β) `z₀<z₁` orientation/trichotomy seam mishandled (R2, Medium confidence — genuinely new glue) | H | M | Enumerate ALL ordered pairs `(k,l)` + diagonal; route `pin k = pin l` diagonal to the 1-free-var Prop 3.5 negation (NOT the pair engine); the engine already internally covers the reversed `m ≥ k` branch (`prop42_efSat_negation_general:995`). Assemble the trichotomy as an explicit lemma, not ad-hoc at the call site. |
| `conjInterleave` (α) combinatorial proof volume exceeds one agent run (R1 — effort, not a wall) | M | H | Split α into Phase 2 (def + order-preserving-merge datatype + forward `→`) and Phase 3 (backward `←` + `veeConj`/`veeConj_iff`); template the type-merge bookkeeping on `BracketFormula.conjFull` (`VecEAConjFull.lean:325`); verify no arity growth by goal inspection (merge of two `StrictMono` chains is one `StrictMono` chain). |
| Phase 6 (δ) structural induction larger than one run | M | H | Sub-decompose by connective case (atom / lt / and / or / not / ex); each case is independently green-committable; the `not` case delegates entirely to Phase 5 (γ), the `and` case to Phase 3 (α). |
| Build regression or added axiom mid-program | H | M | Per-phase invariant: `lake build` EXIT 0 at 1769 jobs; `#print axioms completeness_discrete` gains no axiom/sorry. New modules are additive and off-path until Phase 7, so the spine keeps the old `:562` sorry and stays green throughout Phases 0-6. |
| Off-paper mathematics creeps in | H | L | Faithfulness invariant: cite Rabinovich by PDF page only (`.md`/`.md.bak` corrupt); every construction traces to a report-07 H3 table row (per-phase faithfulness anchor); induction is over formula structure so no arity-4 obligation can arise. |
| Phase 7 (ζ) live-path rewire regresses the spine or fails to remove `sorryAx` | H | M | Do the `nf_nvar_exist_all_depths` deletion LAST and verify immediately with `#print axioms`; keep the old sorry carrying the spine until the new path is wired and green; rollback = revert the spine re-point + match deletion to the last-green state (new modules present, old sorry intact). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 2 | 0 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3, 4 |
| 6 | 6 | 3, 4, 5 |
| 7 | 7 | 1, 6 |

Phases within the same wave can execute in parallel. Wave 2 front-loads the full ε discharge
(Phase 1) alongside the start of the α build (Phase 2): both are unblocked once the Phase 0 spike
returns GO, and running ε early retires the H4 highest-risk (ζ/ε) crux before the α combinatorial
sink completes. Phases 1-6 are all off the live import path; only Phase 7 touches the spine.

---

### Phase 0: ζ/ε spine-rewire seam de-risking spike (viability gate) [COMPLETED]

**VERDICT: GO.** Both seams machine-checked viable, sorry-free (`lake env lean` EXIT 0; each
`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`), in
`reports/08_zeta-epsilon-seam-probe.lean`. Seam (b) `hcapture` is dischargeable
(`hcapture_dischargeable_minimal`) and feeds the landed `esigma_descent` verbatim
(`esigma_descent_composes_minimal`). Seam (a) bridge is VIABLE in the SEMANTIC direction
`MonadicFormula → characteristic NormalForm → truth-determined` (via `nf_characteristic` +
`doets_lemma_1_1`) — there is no syntactic `NormalForm → MonadicFormula` translation and none is
needed. Phases 1/7 must wire through this semantic bridge. No `Theories/` edits; live spine and
`#print axioms completeness_discrete` untouched. The α (`conjInterleave`) build is authorized.

- **Goal:** Prove, cheaply and on a MINIMAL case, that the two highest-risk ζ/ε seams are viable:
  (a) the `NormalForm sig k n`↔`MonadicFormula sig m` object-language bridge at the completeness
  interface, and (b) the `esigma_descent.hcapture` discharge (folding one existential into a fresh
  E[Σ] atom evaluated at the anchor). This is the front-loaded cheap probe: a GO here authorizes the
  large α build; a NO-GO escalates to [BLOCKED] before any combinatorial effort is sunk.
- **Faithfulness anchor:** report-07 H3 rows "Def 4.1 `hcapture` discharge" and "Thm 4.4, p.6"
  (minimal slice). Realizes the seam Rabinovich's Thm 4.4 assembly presumes.
- **Tasks:**
  - [x] On a minimal formula (e.g. a single atom or a one-connective `MonadicFormula`), exhibit the
        `NormalForm`↔`MonadicFormula` bridge: either a `NormalForm → MonadicFormula` translation at
        the interface, or a restatement of the spine's completeness claim over `MonadicFormula`,
        whichever the seam admits. Record which direction is viable. *(done: the SEMANTIC direction
        `MonadicFormula → characteristic NormalForm → truth-determined` via `nf_characteristic` +
        `doets_lemma_1_1` is viable — `seam_a_characteristic_records`, `seam_a_bridge_atom`,
        `seam_a_bridge_lt`; no syntactic `NormalForm → MonadicFormula` exists or is needed.)*
  - [x] Discharge `esigma_descent.hcapture` on the minimal case: capture the folded existential by a
        fresh E[Σ] atom evaluated at the anchor (the Prop 3.5 / Lemma 3.2(2) instance), sorry-free.
        *(done: `hcapture_dischargeable_minimal` + `esigma_descent_composes_minimal`.)*
  - [x] Record an explicit **GO / NO-GO verdict** as the phase deliverable, with the viable bridge
        direction noted for Phases 1 and 7. *(done: **GO** — see verdict block under the phase
        heading and the `## VERDICT` section of the probe.)*
- **Definition of Done (binary):** **GO** iff both the minimal bridge and the minimal `hcapture`
  discharge compile sorry-free on a scratch/off-path probe. **NO-GO** on an irreducible
  object-language mismatch or an `hcapture` instance that cannot be discharged without new
  mathematics.
- **On NO-GO:** escalate the task to **[BLOCKED]** with the refutation for a user decision. Do NOT
  proceed to Phases 1-7. This is a successful cheap refutation, not a failure.
- **Timing:** 4-6 hours (~150-300 lines, scratch/minimal). ~1 agent run.
- **Depends on:** none.
- **Files to modify:**
  - `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/08_zeta-epsilon-seam-probe.lean` (new probe; NOT under `Theories/`)
- **Verification:** Probe compiles EXIT 0 via `lake env lean`; both seams sorry-free on the minimal
  case; GO/NO-GO verdict recorded. No `Theories/` edits, so the live `lake build` and
  `#print axioms completeness_discrete` are untouched.

---

### Phase 1: ε — Prop 3.5 ∨-lift + `esigma_descent.hcapture` discharge (off-path) [COMPLETED]

- **Goal:** Discharge the full ε content OFF the live path: (a) the ∨-lift of Prop 3.5
  (`VeeExistsForall` with one free var → TL, disjunct-wise via `translateProp35`), and (b) the
  general `esigma_descent.hcapture` discharge as a standalone lemma over the relevant Prop 3.5 /
  Lemma 3.2(2) instance. Front-loaded (Wave 2) to retire the H4 highest-risk crux before α
  completes. Produced as off-path lemmas; Phase 7 (ζ) wires them into the live spine.
- **Faithfulness anchor:** report-07 H3 rows "Prop 3.5, p.5" and "Def 4.1 `hcapture` discharge".
- **Tasks:**
  - [x] Establish the Prop 3.5 ∨-lift to `VeeExistsForall` *(deviation: altered — the core
        one-free-var lift `translateVeeProp35`/`translateVeeProp35_correct` was found already landed
        sorry-free in `Prop35Assembly.lean`, so no disjunct was incomplete; delivered the ε-interface
        `prop35_vee_lift` plus the genuinely-new `prop35_vee_lift_disjunctwise` (each disjunct via
        `translateProp35`) and `prop35_vee_lift_append` (Def 3.3 disjunction distributivity) in the
        new off-path `Prop35VeeLift.lean`).*
  - [x] Prove the general `hcapture` discharge lemma (each folded existential captured by a fresh
        E[Σ] atom evaluated at the anchor), generalizing the Phase 0 minimal case, sorry-free.
        *(done: `hcapture_dischargeable` (arbitrary depth/arity, injective-naming discharge),
        `hcapture_dischargeable_faithful` (point-indexed anchored existential at the Lemma 3.2(2)
        cap, generalizing the minimal `(fun _ => a)` device over depth), and `esigma_descent_composes`
        feeding the landed `esigma_descent` verbatim — in the new off-path `HCaptureDischarge.lean`.)*
  - [x] Keep all deliverables in new off-path module(s); assert (by grep / import audit) that
        `KampPrior.lean` does not import them and the spine is untouched. *(done: grep audit confirms
        no `Theories/` file imports the new modules; `completeness_discrete` axiom set unchanged
        `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.)*
- **Timing:** 6-10 hours (~200-500 lines).
- **Depends on:** 0.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop35VeeLift.lean` (new; name provisional)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/HCaptureDischarge.lean` (new; name provisional)
- **Verification:** Both lemmas compile sorry-free, axiom-clean `[propext, Classical.choice,
  Quot.sound]`; off the live import path; `lake build` EXIT 0 at 1769 jobs; `completeness_discrete`
  axiom set unchanged.

---

### Phase 2: α (part 1) — `conjInterleave` def + order-preserving merge + forward direction [NOT STARTED]

- **Goal:** Build the definition and forward (`→`) direction of the one genuinely-unbuilt
  combinatorial core: `conjInterleave (ψ₁ ψ₂ : ExistsForallFormula sig F r) : VeeExistsForall sig F r`
  — the ∃∀×∃∀ → ∨∃∀ order-preserving-merge closure (Lemma 3.2(1)). Two `efSat` chains live in one
  carrier under one linear order; enumerate order-preserving merges of `Fin(n₁+1) ⊎ Fin(n₂+1)` (a
  PATH merge, not a joint type), conjoining unary point/interval types per merged slot. The merged
  object is again a single ordered chain — NO arity growth, NO K₄.
- **Faithfulness anchor:** report-07 H3 row "Lemma 3.2(1) / Lemma 3.4 (∧), p.4-5". Template:
  `BracketFormula.conjFull` recursion (`VecEAConjFull.lean:325`) for type-merge bookkeeping.
- **Tasks:**
  - [ ] Define the order-preserving merge datatype over `Fin(n₁+1) ⊎ Fin(n₂+1)` (the interleaving
        enumeration) and `conjInterleave` producing a `VeeExistsForall`.
  - [ ] Prove the forward direction of `conjInterleave_iff`: `efSat ψ₁ ∧ efSat ψ₂ → veeSat
        (conjInterleave ψ₁ ψ₂)` — from two satisfying chains, exhibit the merged chain and its
        conjoined per-slot types.
  - [ ] Verify by goal inspection that the merge introduces no arity growth (single `StrictMono`
        chain, unary types).
- **Timing:** 8-12 hours (~350-450 lines; highest combinatorial density).
- **Depends on:** 0.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean` (new; name provisional)
- **Verification:** `conjInterleave` + forward direction compile sorry-free, axiom-clean; off the
  live import path; `lake build` EXIT 0 at 1769 jobs; `completeness_discrete` axiom set unchanged.

---

### Phase 3: α (part 2) — `conjInterleave_iff` backward + `veeConj` + `veeConj_iff` [NOT STARTED]

- **Goal:** Complete α: the backward (`←`) direction of `conjInterleave_iff` (from a merged
  disjunct, recover both original chains), then `veeConj` + `veeConj_iff` distributing ∧ over ∨
  (Lemma 3.4-∧) — the ∨∃∀-closed-under-conjunction operation the Prop 4.3 negation case (p.6)
  requires.
- **Faithfulness anchor:** report-07 H3 row "Lemma 3.2(1) / Lemma 3.4 (∧), p.4-5" (completing the
  row Phase 2 began).
- **Tasks:**
  - [ ] Prove the backward direction of `conjInterleave_iff`: `veeSat (conjInterleave ψ₁ ψ₂) →
        efSat ψ₁ ∧ efSat ψ₂` (short once the merge datatype is right, per report 06 §1).
  - [ ] Define `veeConj (Φ₁ Φ₂ : VeeExistsForall sig F r) : VeeExistsForall sig F r` by distributing
        ∧ over the disjunctions and applying `conjInterleave` per pair.
  - [ ] Prove `veeConj_iff : veeSat (veeConj Φ₁ Φ₂) ↔ veeSat Φ₁ ∧ veeSat Φ₂`.
- **Timing:** 6-10 hours (~270-380 lines).
- **Depends on:** 2.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ConjInterleave.lean` (extend)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VeeConj.lean` (new; name provisional)
- **Verification:** `conjInterleave_iff` (both directions), `veeConj`, `veeConj_iff` compile
  sorry-free, axiom-clean; off the live import path; `lake build` EXIT 0 at 1769 jobs.

---

### Phase 4: β — single-∃∀ negation over unordered pairs [NOT STARTED]

- **Goal:** Prove `efSat_negation_general (ψ : ExistsForallFormula sig F r) : ∃ Φ : VeeExistsForall
  sig F r, ∀ env, StrictMono env → (¬ efSat N env ψ ↔ veeSat N env Φ)` — the single-∃∀ negation,
  reusing the LANDED `prop42_efSat_negation_general` as the per-pair base case. Faithful to Prop
  4.3's single-∃∀ negation sub-case (p.6): `¬efSat ψ ↔ ¬augConjSat (augTarget ψ)` (via `augTarget_iff`,
  Lemma 3.2(2), landed) ↔ `(∨_{(k,l)} ¬efSat (pairProject ψ k l)) ∨ ¬efSat (existenceSentence ψ)`,
  each per-pair term discharged by the landed engine.
- **Faithfulness anchor:** report-07 H3 rows "Prop 4.3 ¬-case assembly" (single-∃∀), "Prop 4.2"
  (reused engine), "Lemma 3.2(2)" (`augTarget_iff`), "Prop 3.5" (diagonal 1-free-var negation).
- **Tasks:**
  - [ ] De Morgan the `augTarget_iff` decomposition: `¬efSat ψ` into the disjunction over all
        ordered pairs `(k,l)` plus the existence-sentence negation.
  - [ ] Discharge each per-pair `¬efSat (pairProject ψ k l)` via `prop42_efSat_negation_general` in
        the orientation the `StrictMono` pins force; assemble the **trichotomy lemma** explicitly:
        `pin k ≠ pin l ⟹ env k ≠ env l` (one of `(k,l)`/`(l,k)` matches the engine's `env 0 < env 1`
        gate); `pin k = pin l ⟹ env k = env l` (degenerate 1-free-var, routed to Prop 3.5 negation,
        NOT the pair engine).
  - [ ] Negate the existence sentence (`r=0`) via the same engine at arity 0/1.
  - [ ] Flatten all disjuncts into one `VeeExistsForall` via the landed `veeSat_append`.
- **Timing:** 6-10 hours (~300-500 lines; mostly trichotomy/pin bookkeeping + existence-sentence
  negation — the R2 Medium-confidence seam).
- **Depends on:** 3.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean` (new; name provisional)
- **Verification:** `efSat_negation_general` compiles sorry-free, axiom-clean; the trichotomy is a
  proved lemma (not ad-hoc); off the live import path; `lake build` EXIT 0 at 1769 jobs.

---

### Phase 5: γ — ∨∃∀ negation [NOT STARTED]

- **Goal:** Prove `veeSat_negation (Φ : VeeExistsForall sig F r) : ∃ Φ', ∀ env, StrictMono env →
  (¬ veeSat N env Φ ↔ veeSat N env Φ')` — the ∨∃∀ negation. Faithful to Prop 4.3's disjunction
  negation sub-case (p.6): `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by β; reassemble the `⋀` of
  ∨∃∀ into ∨∃∀ via `veeConj_iff` (Phase 3) — the paper's "closed under conjunction (Lemma 3.4)"
  step.
- **Faithfulness anchor:** report-07 H3 row "Prop 4.3 ¬-case assembly" (∨∃∀ part) + "Lemma 3.4 (∧)"
  (`veeConj_iff`).
- **Tasks:**
  - [ ] De Morgan `¬veeSat (∨φᵢ)` into `⋀ᵢ ¬φᵢ`.
  - [ ] Apply `efSat_negation_general` (β) per disjunct to get each `¬φᵢ` as ∨∃∀.
  - [ ] Reassemble the conjunction of ∨∃∀ into a single ∨∃∀ via `veeConj_iff` (Phase 3); fold over
        the disjuncts.
- **Timing:** 3-5 hours (~100-200 lines; glue).
- **Depends on:** 3, 4.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VeeSatNegation.lean` (new; name provisional)
- **Verification:** `veeSat_negation` compiles sorry-free, axiom-clean; off the live import path;
  `lake build` EXIT 0 at 1769 jobs.

---

### Phase 6: δ — structural Prop 4.3 `translate` (MonadicFormula → VeeExistsForall) [NOT STARTED]

- **Goal:** Build `translate : MonadicFormula sig m → VeeExistsForall sig F m` + `translate_correct
  (∀ M atomMap env, StrictMono env → (veeSat (translate φ) ↔ eval φ))` by structural induction over
  the FORMULA (no NF-depth, no arity tower). Cases: **atom** (endpoint predicate); **lt** (decided
  by indices under `StrictMono`); **and** (`veeConj`, Phase 3); **or** (`veeSat_append`, landed);
  **not** (`veeSat_negation`, Phase 5); **ex** (`veeSat_exists`, landed). Processed content enters as
  an E[Σ] atom (Def 4.1) — no arity growth ever arises. Do NOT revive the BLOCKED `Prop43.lean` over
  `VVecEA_m`.
- **Faithfulness anchor:** report-07 H3 row "Prop 4.3, p.6" (structural induction FO → ∨∃∀).
- **Tasks:**
  - [ ] Define `translate` by recursion on `MonadicFormula` structure.
  - [ ] Prove `translate_correct` case-by-case, each an independent green sub-step: atom, lt, and,
        or, not, ex.
  - [ ] Verify by goal inspection that the assembled induction introduces no arity growth (processed
        content folds into E[Σ] atoms, never joint arity).
- **Timing:** 10-16 hours (~500-800 lines; the crux — sub-decompose by connective case, each
  green-committable).
- **Depends on:** 3, 4, 5.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43Translate.lean` (new; name provisional —
    NOT `Prop43Structural.lean` and NOT the BLOCKED `Prop43.lean`)
- **Verification:** `translate` + all six connective cases of `translate_correct` compile sorry-free,
  axiom-clean; no arity growth (goal inspection); off the live import path; `lake build` EXIT 0 at
  1769 jobs.

---

### Phase 7: ζ — spine rewire + retire `KampPrior.lean:562` [NOT STARTED]

- **Goal:** Re-express `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior`
  / `nf_characterizable_temporal_prior` through Thm 4.4 = Prop 4.3 (δ) + Prop 3.5 (ε), wire in the
  Phase 1 `hcapture` discharge and the Phase 0-chosen `NormalForm`↔`MonadicFormula` bridge, and
  **delete the entire `nf_nvar_exist_all_depths` match including the `:562` sorry.** This is what
  makes the sorry DISAPPEAR rather than be filled. The sole live-path phase; the H4 highest-risk
  interface, de-risked by Phases 0 and 1.
- **Faithfulness anchor:** report-07 H3 row "Thm 4.4, p.6" (rewire + delete `nf_nvar_exist_all_depths`
  incl. `:562`).
- **Tasks:**
  - [ ] Wire the Phase 0-chosen object-language bridge (`NormalForm → MonadicFormula` translation at
        the interface, or the `MonadicFormula` restatement) into the live spine.
  - [ ] Re-point `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` /
        `no_gaps_discrete_model_surgery` onto the Phase 6 `translate` (Prop 4.3) + Phase 1 Prop 3.5
        lift + Phase 1 `hcapture` discharge.
  - [ ] Verify the new path is green with the old sorry still present (spine carried by fallback).
  - [ ] **LAST:** delete the entire `nf_nvar_exist_all_depths` match (all arms + the `:562` sorry +
        its rationale block); update the in-file axiom-audit block and any stale doc-comment line refs.
  - [ ] Run `#print axioms completeness_discrete` and confirm `sorryAx` is GONE.
- **Timing:** 8-14 hours (~300-600 lines).
- **Depends on:** 1, 6.
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (delete the match + `:562` sorry)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (spine re-wire + audit block)
  - the `US_expressively_complete_over_prior` / `no_gaps_discrete_model_surgery` chain files
- **Verification:** `#print axioms completeness_discrete` no longer lists `sorryAx` (retains
  `propext`, `Classical.choice`, `Quot.sound`, and the `native_decide`-sourced `Lean.ofReduceBool`
  / `Lean.trustCompiler`); full `lake build` EXIT 0 at 1769 jobs; no new axiom/sorry anywhere on the
  proof term. Hand off to task 375 for the terminal audit.

## Testing & Validation

Plan-wide invariants (checked at EVERY phase):
- [ ] `lake build` returns EXIT 0 at 1769 jobs.
- [ ] `#print axioms completeness_discrete` gains no new axiom and no new `sorryAx`. Through Phases
      0-6 the axiom set is unchanged (the pre-existing `KampPrior.lean:562` `sorryAx` remains, as the
      sole sorry, carrying the spine). Target end-state after Phase 7:
      `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — **no
      `sorryAx`** (no other pre-existing on-path sorry exists to document).
- [ ] Phases 1-6 deliverables stay OFF the live import path (`KampPrior.lean` does not import them);
      verified by grep / import audit each phase.
- [ ] No `sorry`, `def X := True`, vacuous placeholder, or `Prop43Structural.lean`-style hole is
      introduced in any phase.
- [ ] No deliverable file under `Theories/` (or anywhere outside `specs/**`) references a task
      number (durable-anchor headers only).
- [ ] Every construction traces to its report-07 H3 table row (per-phase faithfulness anchor);
      Rabinovich cited by PDF page only (`.md`/`.md.bak` corrupt).
- [ ] No use of `nf_eval_efold` / `nf_eval_nfk_iff_efold` as a migration target anywhere.

Phase-gate checks:
- [ ] Phase 0: seam-probe compiles EXIT 0; both seams sorry-free on the minimal case; explicit
      GO/NO-GO verdict recorded. NO-GO → [BLOCKED], do not proceed.
- [ ] Phases 2-3 (α): merge introduces no arity growth (single `StrictMono` chain, unary types) —
      verified by goal inspection.
- [ ] Phase 4 (β): the `z₀<z₁` trichotomy is a proved lemma; the `pin k = pin l` diagonal routes to
      Prop 3.5 negation, not the pair engine.
- [ ] Phase 7 (ζ): the `nf_nvar_exist_all_depths` match (incl. `:562`) is DELETED and `sorryAx` is
      confirmed absent.

## Artifacts & Outputs

- plans/08_esigma-negation-rearchitecture.md (this file)
- specs/379_.../reports/08_zeta-epsilon-seam-probe.lean (Phase 0 spike; GO/NO-GO deliverable)
- New `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` modules (Phases 1-6; names provisional):
  `Prop35VeeLift.lean`, `HCaptureDischarge.lean`, `ConjInterleave.lean`, `VeeConj.lean`,
  `EFSatNegation.lean`, `VeeSatNegation.lean`, `Prop43Translate.lean`
- Edits to `KampPrior.lean`, `Completeness.lean`, and the `US_expressively_complete_over_prior` /
  `no_gaps_discrete_model_surgery` chain (Phase 7)
- summaries/08_esigma-negation-rearchitecture-summary.md (on completion)

## Rollback/Contingency

- **Phase 0 NO-GO:** no `Theories/` edits were made (probe is under `specs/`); escalate to [BLOCKED]
  with the refutation (irreducible object-language mismatch or undischargeable `hcapture`) for a
  user decision. Nothing to revert; the α sink is never entered.
- **Phases 1-6 failure:** each phase commits only green sub-steps and is additive/off-path, so a
  failed phase leaves the last green state intact and resumable. The live spine keeps the old `:562`
  sorry and builds EXIT 0 throughout — it is never degraded mid-program.
- **Phase 7 regression:** the `nf_nvar_exist_all_depths` deletion is done LAST and verified
  immediately with `#print axioms`. If the spine re-wire regresses the build or the axiom set,
  revert the Phase-7 edits (spine re-point + match deletion) to restore the last-green state where
  the new modules exist but the old sorry still carries the spine. The deletion is the only step
  that removes the fallback, so it is isolated and reversible.
