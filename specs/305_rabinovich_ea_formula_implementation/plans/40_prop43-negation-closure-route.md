# Implementation Plan: Task #305 (v40 — Uniform-Prop-4.3 negation-closure route for KampPrior:391)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IN PROGRESS] (Phases 1-10 COMPLETED; Phase 11 [PARTIAL — flat-bracket route refuted, assets preserved]; Phases 12-14 [ABANDONED — bracket route refuted]; Phase 15 verification folded into new Phase 20; **new Phases 16-20 pivot onto the negation-closure route**)
- **Effort**: ~10-14 hours (4-6 dispatches; budget-constrained — see "Budget & Honest Verdict")
- **Dependencies**: None (resumes from build-GREEN HEAD `bce099aa8`; baseline 2 live sorries `KampPrior.lean:391`/`:394`, top-level axioms = 2)
- **Research Inputs**: reports/40_phase11b-divergence-audit.md (primary, Tier-1 literature-backed, H4-verified; recommends this route in §2.2/§4 and the handoff `next_action_hint`); reports/39_depth-k1-bridge-design.md (prior route, superseded for Phases 11-15); `.orchestrator-handoff.json` (D1 NO-GO refutation)
- **Artifacts**: plans/40_prop43-negation-closure-route.md (this file)
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/state-management.md, .claude/context/formats/plan-format.md, lean4.md, literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan **supersedes plan v39 for its remaining Phases 11-15**. Report 40 (Tier-1, H4-verified
against Rabinovich 2014) and the D1 go/no-go dispatch (`.orchestrator-handoff.json`, verdict NO-GO,
sorry-free) jointly closed the v39 crux route: **both** of v39's in-plan approaches to the depth-k
two-anchor zone converter are now refuted by sorry-free counterexample machinery —

1. **Projection `VecEA2`** (Phase 10 x=t diagnosis; `NfZoneDepthK.lean:41-52`): the coupled quant
   layer does not factor through per-variable projections (`liftIdx(totalUnskip)` non-injectivity).
2. **Flat single-interval bracket absorption** (D1 probe, `NfZoneDepthK1Probe.lean`): a
   `BracketFormula.holds M atomMap x t bf` with depth-0 **atomic** types is confined to the closed
   interval `[x,t]` and **cannot capture exterior-`w` realizability** (zones `w<x`, `t<w`) — proved
   by `interior_bracket_cannot_realize_exterior_sub_k1`.

**USER DECISION (SETTLED, do not re-litigate):** the v39 Phase 11 crux route is dead. Pivot **inside
task 305** onto the **Uniform-Prop-4.3 negation-closure route** and re-scope the remainder (old
Phases 11-15) as new Phases 16-20.

### Why this route is different (and why it is not just another recession)

The D1 refutation is precise about *what the flat route lacked*: **temporal navigation to exterior
points.** A flat atomic bracket on `(x,t)` supplies only interior witnesses and only local
valuations (no `Until`/`Since`). Rabinovich's actual Cor 5.4 construction reaches the exterior
via **past-of-`x` / future-of-`t` navigation** (nested `Until`/`Since`). The negation-closure route
supplies exactly this, and it rests on a **preserved sorry-free asset the flat route never used**:

> **`prior_hasAttainedINF` (PriorINF.lean:224, sorry-free):**
> `semantic_prior_UZ M atomMap → HasAttainedINF M atomMap`.

The live-path `:391` goal carries `h_UZ : semantic_prior_UZ M atomMap` in scope (KampPrior:305-311).
So `prior_hasAttainedINF h_UZ` gives `HasAttainedINF M atomMap`, which **unlocks the entire
model-dependent negation/INF-closure machinery on the live path**: `neg_interval_formula` (Lemma
5.1) and `neg_bounded_exists` (Cor 5.4 forward) — both sorry-free in `EANegationClosure.lean` — plus
`neg_vec_ea_m` (Prop 4.2 at arbitrary arity, `EAVecNegationClosure.lean`). These produce
`VBracketFormula`/`VVecEA_m` witnesses for **negated bounded existentials**, which is precisely how
Rabinovich expresses the exterior/"not-realized" content that a flat atomic interior bracket drops.

### The architecture (SETTLED for this route)

The `:391` obligation is a **uniform** (model-independent) `Formula` (built via `.choose` in
`nf_nvar_exist_all_depths`): `temporal_truth M t A ↔ ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`,
for **all** Prior `M` with `h_UZ, h_SZ`. The route splits this into two disjoint concerns:

- **The formula `A` is built model-independently** from `bracketBuildLeft`/`bracketBuildRight`
  (uniform, `Until`/`Since` chains), with the **depth-k IH formula** `exist_tl_fn_k` (in scope at
  `:391`, KampPrior:334-344) and its formula-level `¬` as the navigable endpoint/point `TemporalPred`
  types. Negation lives at the **formula level** (`temporal_truth M t (¬φ) = ¬temporal_truth M t φ`),
  which is model-independent and trivial — so the UNFIXABLE uniform *VecEA-level* negation
  (`NegationIndep.lean:340`, report 18) is **never needed to construct `A`**.
- **The correctness proof is discharged per Prior model** using `prior_hasAttainedINF h_UZ` to run
  the model-dependent INF/negation closures (`neg_bounded_exists`, `neg_interval_formula`) for the
  exterior/negated directions.

This resolves the exact tension in `Prop43.lean`'s BLOCKER note: that note (dated Phase 4b,
2026-06-24) declared the *uniform VecEA translation* blocked on (a) complete conjunction closure,
(b) leftward existential closure, and (c) uniform negation. But (b) **now exists** — Phase 7 landed
`existClosureLeft`+`_correct` (v39 Preserved Assets) — and (a)/(c) are **sidestepped** by keeping
negation at the formula level and building `A` from bracket builders rather than a uniform VecEA
negation. The genuine remaining crux is the **exterior-navigation correctness** of the zone
converter, which Phase 16 gates.

**Definition of done (whole plan, if the gate is GREEN):** `lake build` GREEN, `:391` cleared,
`:394` cleared-or-documented-off-path, live-path sorry count 2 → 0/1, axiom set unchanged (2
top-level axioms), zero new top-level `axiom`, no arity-tower reintroduction, no flat-bracket retry.

### Budget & Honest Verdict (mandated risk assessment)

**Budget: ~6 orchestration cycles remain.** This plan is 5 phases (16-20). Phases 17-18 (the zone
converter) are the genuine inductive step of Kamp's theorem and each may exceed one dispatch.

**Honest verdict on `:391` closability in budget: UNCERTAIN — gated on Phase 16.** My reading of
the assets supports the following, stated plainly per the risk mandate:

- **The route is materially more promising than the refuted flat route.** `prior_hasAttainedINF`
  + the sorry-free `neg_bounded_exists`/`neg_interval_formula`/`bracketBuildLeft/Right` closures are
  real, previously-unused assets that supply exactly the exterior navigation D1 proved the flat
  route lacked. This is not a re-run of a closed route.
- **But full closure of `:391` in ~6 dispatches is NOT assured.** The zone converter's
  exterior-navigation correctness (Phase 16 crux, generalized in 17-18) is unproven and is of the
  same difficulty class that has resisted 39 plan versions. The specific open risk: whether a
  temporal formula evaluated at a single anchor can encode the *coupling* of the quantified witness
  to a second anchor via `Since`/`Until` navigation (the multi-anchor single-point obstruction of
  report 40 §2.1-A) — plausibly yes (navigation *can* look back), but this is exactly what Phase 16
  exists to decide, not assume.
- **Sizing for maximal honest progress:** Phase 16 is a **1-dispatch decisive go/no-go gate**. If
  GREEN, Phases 17-20 have a genuine shot at `:391`. If NO-GO, the route STOPS with **bankable
  off-path assets** (the Prior→INF navigation wiring + single-zone converter lemmas) and the
  residual is a named `/spawn` candidate (see "Deferred / Follow-up"). Either outcome is decisive
  and leaves the baseline GREEN.

**Estimated probability `:391` fully closes within this plan's budget: ~40-50%, conditional on
Phase 16 GREEN (which itself is ~50-60%).** Recorded honestly so the orchestrator can decide
whether to continue past the gate.

### Preserved Assets

The following work is complete and **must not regress**. Phases 16-20 **consume** these; they do
not rebuild them. The "Consumed by" column marks which new phase(s) use each.

| Component | File | Status | Consumed by |
|-----------|------|--------|-------------|
| **Route asset — Prior→INF bridge** `prior_hasAttainedINF` (`h_UZ → HasAttainedINF`) | `Kamp/PriorINF.lean:224` | [PRESENT] sorry-free | 16, 17, 18 (unlocks the model-dependent closures on the live path) |
| **Route asset — Lemma 5.1** `neg_interval_formula` (neg of bracket → VBracket, model-dep) | `Kamp/EANegationClosure.lean:401` | [PRESENT] sorry-free | 16, 17, 18 |
| **Route asset — Cor 5.4 fwd** `neg_bounded_exists` (neg of bounded ∃ → VBracket, model-dep) | `Kamp/EANegationClosure.lean:492` | [PRESENT] sorry-free | 16, 17, 18 |
| **Route asset — Prop 4.2 arbitrary arity** `neg_vec_ea_m` / `neg_vecEA_m` (model-dep) | `Kamp/EAVecNegationClosure.lean:285,208` | [PRESENT] sorry-free | 17, 18 (as needed for negated clauses) |
| **Route asset — Prop 4.3 uniform blocks** `atomAt`/`ltAt`/`tt`/`ff` (+`_holds`) | `Kamp/Prop43.lean:45-109` | [PRESENT] sorry-free | 17, 18 |
| **Route asset — arity-m lift** `liftEndpoint`/`liftInterval` (+`_holds`) | `Kamp/EAVecNegationClosure.lean:70-179` | [PRESENT] sorry-free | 17, 18 |
| Bracket builders `bracketBuildLeft`/`bracketBuildRight` (+`_correct`), arbitrary `TemporalPred` | `Kamp/VecEATranslation.lean:50,234` | [PRESENT] sorry-free | 16, 17, 18 |
| Phase 7 leftward closure `existClosureLeft`+`_correct`/`_correct_rev`, `existClosure` | `Kamp/VecEATranslation.lean`, `VecEA_m.lean:208` | [COMPLETED] sorry-free, off-path | 17, 18 |
| Depth-k IH engine `exist_tl_fn_k` + `exist_tl_fn_k_correct` (in scope at `:391`) | `Kamp/KampPrior.lean:334-344` | [PRESENT] | 16, 17, 18, 19 |
| char_k1 template `nf_succ_char_formula` + `_correct` (formula-level `¬`) | `Kamp/KampPrior.lean:347-361`,107-177 | [PRESENT] sorry-free | 18 (diagonal), 19 (assembly) |
| Phase 10 `renameNF_eval_diag0` (depth-0 diagonal value-duplication congruence) | `NfDepth0Generalized.lean:1646` | [COMPLETED] sorry-free, off-path | 18 (x=t diagonal arm base) |
| `mergeNF_succ` (def) + `mergeNF_succ_atom` (atom layer) | `NfDepth0Generalized.lean:593,599` | [PRESENT] | 18 (x=t arm) |
| Phase 11a atom/order extraction: `nf_eval_atom_layer`, `zoneEnv3`, `nf3_order_{yx,yt,xy,xt,ty,tx}` | `Kamp/NfZoneDepthK.lean:190-286` | [COMPLETED] sorry-free, off-path | 17, 18 (zone forward direction) |
| Phase 11b outer y-split: `nf_eval_quant_layer`, `nf_zone_exists_iff_char`, `exists_trichotomy_split`, `nf_zone_partition5`, `nf_zone_exists_partition5` | `Kamp/NfZoneDepthK.lean:302-416` | [COMPLETED] sorry-free, off-path | 17, 18 (5-zone partition skeleton) |
| Phase 11b inner w-split + char interface: `nf_characteristic_atom_succ`, `nf_characteristic_quant_succ`, `nf_char_eq_iff_eval`, `exists_nested_split3`, `nf_characteristic_quant_split3`, `nf_char3_eq_succ_iff` | `Kamp/NfZoneDepthK.lean:418-550` | [COMPLETED] sorry-free, off-path | 16, 17, 18 (the coupled quant layer these decompose is the gate's input) |
| D1 obstruction lemmas: `nf0_4_order_w_lt_x`, `nf0_4_exterior_witness_is_exterior`, `intervalPattern_witnesses_interior`, `interior_bracket_cannot_realize_exterior_sub_k1` | `Kamp/NfZoneDepthK1Probe.lean` | [PRESENT] sorry-free, off-path | 16 (they define exactly what the navigable route must do differently; guard against flat-bracket regression) |

**Do NOT re-derive, revert, or overwrite any row above.**

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014 §3-5, verbatim-grounded)

Paper (ground truth, read verbatim this dispatch):
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` (245 lines).
5-column mapping: each Prop-4.3 / Cor-5.4 clause (exact quote) → existing Lean asset → new
identifier/phase → route mechanism → faithfulness check.

| Source clause (Rabinovich 2014, exact quote + loc) | Existing Lean asset | New identifier (phase) | Route mechanism | Faithfulness check |
|---|---|---|---|---|
| **Prop 4.3** (`md:104`): *"Every first-order formula is equivalent **over Dedekind complete chains** to a disjunction of exists-forall formulas."* Structural induction: *"Atomic: Immediate. Disjunction: Immediate. Negation: Uses Proposition 4.2. Exists-quantifier: Follows from Lemma 3.4."* (`md:106-110`) | `Prop43.atomAt`/`ltAt`/`tt`/`ff` (atomic); `VVecEA_m.conj`/`disj` (∧/∨); `existClosure`/`existClosureLeft` (∃) | overall `:391` engine `exist_tl_fn_{k+1}` (19) | atom/order/∨/∃ cases are the uniform blocks; the equivalence is **over Dedekind complete chains**, i.e. discharged per-model | **KEY**: "over Dedekind complete chains" ⇒ the negation case is model-CLASS-dependent, NOT a uniform syntactic function. See divergence row in Risks. |
| **Prop 3.5** (`md:87-94`): one free variable at `z_k` ⟺ *"A_k AND (B_{k+1} Until (A_{k+1} AND …)) ; A_k AND (B_{k-1} Since (A_{k-1} AND …))"* — *"the interval decomposition directly maps to nested Until/Since"* | `bracketBuildRight` (`Until`), `bracketBuildLeft` (`Since`) + `_correct` (VecEATranslation:50,234) | `A_fut_k1` gate (16); zone converters `nf_zone_nav_*` (17,18) | future-of-`z_k` = `Until` from `z_k`; past-of-`z_k` = `Since` from `z_k` — the exterior navigation D1's flat bracket lacked | Direct: Prop 3.5 IS the "past-of-x/future-of-t navigation" the plan builds. `bracketBuildRight/Left` are its Lean image. |
| **Cor 5.4** (`md:154-157`): *"Define F_n := alpha_n and F_{i-1} := alpha_{i-1} AND (beta_i Until F_i). Then […] holds iff there is an increasing sequence in (z_0, z_1) with F_0(z_0) holding. The negation reduces via Lemma 5.3 and the observation that **F_i are TL-definable**."* | `bracketBuildRight` chain (`chainHolds`, VecEATranslation:30-60) | `nf_zone_nav_depthk` full converter (18) | the `F_i` = nested `Until` chain over depth-k IH types; *"F_i are TL-definable"* = **model-independent formula** | Direct: `F_i` TL-definable ⇒ `A` is built model-independently (bracket builders + IH formula); only the *negation* is per-model. This is v40's architecture verbatim. |
| **Lemma 5.3 / 5.1** (`md:134-152`): negation of the bracket/bounded-∃ is V-exists-forall *"over Dedekind complete chains"*; *"r_0 = inf{z … | P_1(z)}; Key use of Dedekind completeness: r_0 exists"* via `INF(z_0,r_0,z_1,P_1)` (`md:149`) | `neg_bounded_exists` (Cor 5.4 fwd, EANegationClosure:492); `neg_interval_formula` (Lemma 5.1 fwd, :401); `HasAttainedINF.first_occ` (PriorINF:207) | consumed in correctness proofs of 16,17,18 | discharge exterior/"not-realized" directions per-model under `prior_hasAttainedINF h_UZ` | Direct: the paper's Dedekind completeness = `HasAttainedINF`; the INF point = `first_occ`. `prior_hasAttainedINF` supplies it from `h_UZ`. |
| **Key Insight §3** (`md:221-222`): *"Dedekind completeness is used in exactly one place: the INF formula (5.2)… guaranteed to exist by completeness."* | `prior_hasAttainedINF` (`h_UZ → HasAttainedINF`, PriorINF:224) | — (the de-risking asset) | the ONLY model-dependence is the INF point; everything else (`F_i` chains) is uniform | Direct: confirms negation is model-dependent in exactly one spot, unlocked on the live path by `prior_hasAttainedINF`. |
| **Def 3.1 / Key Insight §2** (`md:65-74,213-219`): interval decomposition; *"which i the new point corresponds to"*; split into `A_i^-(z_0,z)` and `A_i^+(z,z_1)` | preserved `nf_zone_partition5`/`nf_zone_exists_partition5` (NfZoneDepthK:366,397); inner `nf_characteristic_quant_split3` (:514) | zone assembly (17,18) | outer `y`-split into 5 zones = the "which i" position split; inner `w`-split = sub-interval typing | Direct: the landed 11a/11b splits ARE Rabinovich's position/sub-interval split. |
| diagonal (x=t) arity collapse restricted to realizable forms (specialization, not a distinct paper clause) | `renameNF_eval_diag0` (NfDepth0Generalized:1646); `mergeNF_succ`/`_atom` | x=t arm via `char_k1 ∘ mergeNF_succ` (18) | depth-0 diagonal congruence base + realizability from the zone machinery | Lean-specific bookkeeping arm; no paper divergence. |

## Goals & Non-Goals

**Goals**:
- Decide, in one dispatch (Phase 16), whether the **exterior-navigation** encoding
  (`bracketBuildLeft/Right` + IH-formula type + `prior_hasAttainedINF`) captures the exterior-zone
  coupled existential that the flat atomic bracket provably could not (D1). This is the make-or-break
  gate for the whole route.
- If GREEN: build the depth-k two-anchor zone converter (Phases 17-18), assemble
  `exist_tl_fn_{k+1}`, and rewire `KampPrior.lean:391` (Phase 19), dropping live sorry count 2 → 1.
- Verify `:394` cleared/off-path and audit axioms/`sorryAx` (Phase 20, absorbs v39 Phase 15).
- Keep `A` model-independent (built from bracket builders + IH formula); keep all negation at the
  formula level or in the per-model correctness proof (never a uniform VecEA negation).

**Non-Goals** (see Postmortem Constraints for the binding "Do NOT" list):
- No flat single-interval atomic bracket absorption (D1 refuted — `interior_bracket_cannot_realize_exterior_sub_k1`).
- No projection-based `VecEA2` per-variable factoring (refuted at depth k+1).
- No arity-tower / NF-depth parameter beyond `k`; no arity-4+ existential converter.
- No **uniform** (model-independent) VecEA-level negation (UNFIXABLE, `NegationIndep.lean:340`); no
  per-model existential translation bridge (vacuous).
- No De Morgan / positive-NF restructure of Prop 4.3 as a *construction* requirement (negation stays
  at the formula level).

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from v39's Postmortem Constraints (carried
**verbatim**), report 40's D1 refutation, and this task's 39+ prior-plan churn history.

**Do NOT**:
- Wire `VecEA_m.existClosure`/`existClosureLeft`/`disj` (or any `VecEA_m.holds`-typed combinator)
  directly into `:391` as the *object* of the iff. Report 39 root-caused this as the Phase 8
  BLOCKER: those lemmas relate `VecEA_m.holds`, but the `:391` goal is `nf_eval_nf M (k+1) 2 …`; no
  NF(k+1)↔VecEA_m iff exists. (These combinators MAY be used inside the per-model correctness proof,
  but the `:391` object stays `nf_eval_nf`.)
- Ship a **per-model** existential bridge (`∃ vea : VecEA_m 2, nf_eval ↔ vea.holds env`) — VACUOUS,
  closed by `⟨tt, tt_holds⟩`/`⟨ff,…⟩` for any input. Every converter built here must be a **uniform
  total function** `NormalForm sig … → Formula` with `A` quantified OUTSIDE `∀ M`, and a
  model-independent iff, exactly like `nf_succ_char_formula`/`exist_tl_fn_k`.
- **Ship an `∃ formula, iff` vacuous statement.** Any go/no-go gate or converter lemma must DEFINE a
  concrete formula (`bracketBuildLeft/Right …`) and prove the named iff. `∃ A, ∀ M, …` is acceptable
  ONLY when `A` is constructed explicitly first and the `∃` is `⟨A_concrete, proof⟩`; a bare
  `∃ A, …` closed opaquely is forbidden.
- Depend on a **uniform Prop 4.2/4.3** (model-independent VecEA negation) to *construct* `A`. The
  model-independent backward negation is UNFIXABLE at the `BracketFormula` level (`NegationIndep.lean:340`,
  report 18). Negation stays at the formula level (`¬` on the depth-k IH temporal formula) or in the
  per-model proof via `neg_bounded_exists`/`neg_interval_formula` under `prior_hasAttainedINF`.
- De Morgan / positive-NF restructure of Prop 4.3 as a construction requirement (relocates the
  obstruction from `not` to `all`).
- Reintroduce any NF-depth / arity-tower parameter beyond `k`, arity-4+ existential converter, `k+2`
  NF-disjunction, or `mutual` char/exist def. **The durable failure mode across plans 11-39** (sorry
  moved `FOToVEA:118` → `KampPrior:154` → `:391`); do not re-create it.
- **Retry projection-based `VecEA2`** for the x=t or any zone arm — refuted as a NON-theorem at
  depth k+1 (`NfZoneDepthK.lean:41-52`; `liftIdx(totalUnskip)` non-injectivity).
- **[NEW — D1] Build a flat single-interval bracket absorption** — a `BracketFormula.holds M atomMap
  x t bf` with depth-0 atomic point/segment types, as the RHS of a zone existential. Refuted:
  `interior_bracket_cannot_realize_exterior_sub_k1` (`NfZoneDepthK1Probe.lean`) proves such a bracket
  is confined to `[x,t]` and drops exterior-`w` realizability (`w<x`, `t<w`). Exterior zones MUST use
  navigation (`bracketBuildLeft`/`bracketBuildRight` reaching past-of-`x`/future-of-`t`), NOT a flat
  interior disjunction.
- Use `renameNF_eval_iff` (`NfDepth0Generalized:440`) for the x=t collapse — it requires a bijection
  the non-injective merge violates. Use the diagonal-specialized `renameNF_eval_diag0` instead.
- Add any `sorry` to the live import path. Off-path scaffolding (Phases 16-18) may not carry sorries
  either (each phase ends GREEN sorry-free); nothing new lands on the `completeness_discrete` path
  except a sorry-free discharge at Phase 19.
- Revert or overwrite any Preserved Asset.

**MUST preserve**:
- Build GREEN at every phase boundary.
- Top-level axiom set exactly the baseline (2 top-level `axiom`s; `[propext, Classical.choice,
  Quot.sound]` on every new decl unless a preserved asset already carries `Lean.ofReduceBool`/
  `Lean.trustCompiler`); zero **new** top-level `axiom`.
- The sorry-free `bracketBuildLeft`/`bracketBuildRight`, `prior_hasAttainedINF`, `neg_bounded_exists`,
  `neg_interval_formula`, `exist_tl_fn_k`, char_k1, `mergeNF_succ`/`_atom`, and all Phase-10/11/D1
  landed lemmas as reused bricks.
- `:391` and `:394` stay as the two baseline sorries until Phase 19 (`:391`) and Phase 20 (`:394`).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The v39 flat/projection routes are DEAD (two independent sorry-free refutations). Do not reopen.
- The `:391` goal is depth **k+1** arity-2 `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`
  (`insertEnv env t = Fin.cons (env 0) (fun _=>t)`, KampPrior:482).
- `A` is built model-independently from bracket builders + `exist_tl_fn_k` + formula-level `¬`;
  correctness is discharged per Prior model via `prior_hasAttainedINF h_UZ`. This is the SETTLED
  architecture that sidesteps Prop43's uniform-negation blocker.
- Exterior zones require temporal navigation (past-of-`x`/future-of-`t`), not a flat interval. The
  navigable encoding is the untested crux; Phase 16 decides it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **[DIVERGENCE — mis-transcription class that caused the last 3 recessions]** Prop43.lean's BLOCKER note demands a **model-INDEPENDENT** uniform VecEA negation and declares it UNFIXABLE. But Rabinovich's **Prop 4.2/4.3 are stated *"over Dedekind complete chains"*** (`md:101,104`) and Key Insight §3 (`md:221`) says completeness is used *"in exactly one place: the INF formula"* — i.e. the paper's negation is **model-class-dependent**, realized via the INF point, NEVER a uniform syntactic function. **Prior plans over-transcribed** the paper by demanding model-independent negation to *construct* the formula; this forced the arity tower / flat-bracket dead ends. | H | (now mitigated) | v40's SETTLED architecture matches the paper verbatim: build `A` model-independently from the TL-definable `F_i` chains (Cor 5.4: *"F_i are TL-definable"*), and discharge negation **per-model** via `prior_hasAttainedINF h_UZ → neg_bounded_exists`/`neg_interval_formula` (= Lemma 5.3/5.1 over Dedekind complete chains). Prop43.lean is NOT wrong — its `atomAt`/`ltAt`/`tt`/`ff` blocks are faithful; only its *uniform-negation* framing over-reaches the paper. Do NOT reopen the uniform-negation goal (Postmortem). |
| **Phase 16 gate is NO-GO** — the multi-anchor single-point obstruction (report 40 §2.1-A) recurs even with navigation: a formula at one anchor cannot encode the witness's coupling to the second anchor. | H | M | This is the honest open risk. If NO-GO: STOP, land the Prior→INF navigation wiring + single-zone lemma off-path GREEN, document the obstruction as the definitive record, and `/spawn` (see Deferred). Do NOT recede to a new framing. 1-dispatch cost; decisive. |
| Phase 17/18 (zone converter) exceeds one dispatch each. | M | H | Report 40 sizes the converter body at ~400-700 lines. Phase 17 = past + interior arms; Phase 18 = future + diagonal + assembly. Split further at dispatch time (17a/17b) if a single dispatch cannot land GREEN; each sub-phase ends GREEN off-path. Do not churn one dispatch past budget. |
| The per-model correctness proof needs `neg_bounded_exists`/`neg_interval_formula` at a shape they do not directly provide (e.g. a two-sided or nested exterior). | M | M | These are the exact Cor 5.4 / Lemma 5.1 forward closures; feed them `prior_hasAttainedINF h_UZ`. If a shape mismatch surfaces, the missing glue is a small bracket-prepend lemma (`BracketFormula.prepend_holds` exists, EANegationClosure:453); prove it declaration-by-declaration rather than reaching for a uniform negation. |
| Phase 19 assembly surfaces a `Fin.cons`/`insertEnv` index-ordering mismatch. | H | M | Prove the assembled iff against `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` as a standalone off-path lemma first (rewrite via KampPrior:482 identity); `lake build` GREEN before touching `:391`. |
| `:394` (n≥2) reachable on the live path needing general-m closure this plan does not build. | M | L | Phase 20 runs `lean_verify completeness_discrete`. If off-path, document non-blocking (final count 1). If reachable requiring general-m closure, STOP, document, `/spawn`; do NOT reintroduce an arity tower. |
| Regressing the GREEN baseline or the axiom set. | H | L | `lake build` GREEN + `#print axioms completeness_discrete` + `grep '^axiom ' Theories/` at every phase boundary; off-path scaffolding stays quarantined until Phase 19 consumes it sorry-free. |

## Implementation Phases

**Dependency Analysis (wave map)**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | **16 (GO/NO-GO GATE)** | -- |
| 2 | 17 (past + interior converter arms) | 16 (GREEN) |
| 3 | 18 (future + diagonal + full converter assembly) | 16 (GREEN), 17 |
| 4 | 19 (assemble `exist_tl_fn_{k+1}` + rewire `:391`) | 17, 18 |
| 5 | 20 (verify `:394`, axiom/`sorryAx` audit) | 19 |

**Every phase in Waves 2-5 is CONDITIONAL on Phase 16 GREEN.** A NO-GO at Phase 16 terminates the
route into the Deferred `/spawn` closeout.

### Historical Phase Ledger (plans 37/38/39 — closed, do not re-execute)

| Phase | Name | Terminal Status | Disposition |
|---|---|---|---|
| 1-9 (plans 37/38) | Boneyard triage … leftward closure … verification | terminal | Context only; Phase 7 leftward closure is a Preserved Asset. |
| 10 (plan 39) | `renameNF_eval_diag0` depth-0 diagonal congruence | [COMPLETED] | Sorry-free, off-path; Preserved Asset (Phase 18 base). |
| 11 (plan 39) | Depth-k two-anchor zone converter | **[PARTIAL — ROUTE REFUTED, ASSETS PRESERVED]** | 11a/11b splits + D1 gate landed sorry-free off-path (all in Preserved Assets); the flat/projection converter is a refuted non-theorem. Superseded by Phases 16-18. |
| 12 (plan 39) | x<t past arm via `bracketBuildLeft` | **[ABANDONED — bracket route refuted]** | Presupposed the refuted flat converter. Reconstituted as Phase 17. |
| 13 (plan 39) | t<x future arm via `bracketBuildRight` | **[ABANDONED — bracket route refuted]** | Reconstituted as Phase 18. |
| 14 (plan 39) | Assembly + rewire `:391` | **[ABANDONED — depended on 11-13]** | Reconstituted as Phase 19. |
| 15 (plan 39) | Verification | **[FOLDED INTO PHASE 20]** | Carried forward: `:394` reachability + `sorryAx` audit. |

---

### Phase 16: GO/NO-GO GATE — exterior-navigation capture at k=1 [PARTIAL]

> **GATE VERDICT: NO-GO** (2026-07-06, sess_1783315428_d370a2). Landed sorry-free, off-path, in
> `Kamp/NfZoneNavProbe.lean` (4 theorems, axioms `[propext, Classical.choice, Quot.sound]`, `lake
> build` GREEN, live sorry baseline unchanged at 2). The gate as stated (free anchor `x`) is a
> **non-theorem**: `no_x_independent_formula_captures_future_zone_k1` proves that for *every*
> candidate formula `A` (not just `bracketBuildRight`), the future-zone gate iff is contradictory in
> any non-degenerate model. Root cause — the *free-anchor identification obstruction*: the RHS
> `∃ y, t<y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` pins `x`'s local monadic type
> (`future_zone_pins_x_pred`), but an `x`-independent formula at `t` has one fixed truth value
> (`gate_forces_x_independence`) — navigation from `t`/`y` can quantify over past points but cannot
> *name* the specific free anchor `x`. This is the future-navigable sibling of D1's interior
> confinement and report 40 §2.1-A's arity tower; all three converge. Per the GATE DECISION below:
> **STOP. Do not attempt Phases 17-20.** `/spawn` the residual (Deferred section). Full divergence
> note (Rabinovich §5 verbatim) is in-file at `NfZoneNavProbe.lean`.

**THE MAKE-OR-BREAK GATE.** One dispatch. Decisive. Tests the single unverified premise on which the
whole route rests: **does temporal navigation (`bracketBuildRight`/`bracketBuildLeft` + depth-k IH
formula endpoint type, correct via `prior_hasAttainedINF`) capture the EXTERIOR-zone coupled
existential that a flat atomic bracket provably cannot (D1)?**

**The concrete falsifiable claim (Postmortem-compliant — `A` is DEFINED, not `∃`-opaque):**

Work at `k = 1` (the minimal case with a real quant layer: the inner sub-form is `NormalForm sig 0
4`, depth-0 concrete). Take the **future exterior zone `t < y`** — the mirror of the case D1 refuted
for the flat encoding. In a new off-path sibling module `Kamp/NfZoneNavProbe.lean`:

```lean
-- CONCRETE construction (NOT a bare `∃ A`): A_fut_k1 is DEFINED explicitly via bracketBuildRight,
-- with the depth-0 IH realizability formula (exist_tl_fn_0 = nf characterizer at depth 0) as the
-- navigable endpoint/point TemporalPred. Anchored at t, reaching future points y > t.
noncomputable def A_fut_k1 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3) : Formula :=
  bracketBuildRight
    (bf_of_zone_future atomMap h_surj qnf)     -- concrete BracketFormula whose types are IH formulas
    (endRight_of_zone_future atomMap h_surj qnf) -- concrete endpoint TemporalPred (IH realizability)

-- The named iff, A_fut_k1 quantified OUTSIDE ∀ M (uniform), correctness via prior_hasAttainedINF:
theorem A_fut_k1_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) (hxt : x < t) :
    temporal_truth M atomMap t (A_fut_k1 atomMap h_surj qnf) ↔
      (∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf) := by
  -- Forward/backward via bracketBuildRight_correct (VecEATranslation:234) for the ∃-side,
  -- and prior_hasAttainedINF h_UZ ▸ neg_bounded_exists / neg_interval_formula for the
  -- not-realized / exterior directions. Feed the depth-0 IH realizability (exist_tl_fn_0)
  -- as the endpoint type; decompose the coupled quant layer via the preserved
  -- nf_characteristic_quant_split3 / nf_char3_eq_succ_iff.
  sorry  -- ← the dispatch either CLOSES this sorry-free (GO) or refutes the iff (NO-GO)
```

**Note on `x`**: if the future-zone iff for a *free* anchor `x` cannot be stated with `A_fut_k1`
model-independent (because `A` at `t` cannot see a free `x`), that IS the NO-GO signal — the
multi-anchor single-point obstruction (report 40 §2.1-A) has recurred. The GREEN path requires the
navigable encoding to express `y`'s coupling to `x` via `Since` from `y` (looking back to `x`),
which is the exact capability the flat atomic bracket lacked. The dispatch must determine whether the
IH-formula endpoint type can carry this coupling. Pin the exact env/anchor indices against the live
`nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` goal via `lean_goal` before committing the statement shape.

**Reference grounding (H3, Tier 1)**: report 40 §4 (low-confidence flag on absorption — this gate
resolves it); Rabinovich §5 exterior navigation (`md:119-157`); `bracketBuildRight_correct`
(VecEATranslation:234-241); `prior_hasAttainedINF` (PriorINF:224); `neg_bounded_exists`
(EANegationClosure:492); D1 obstruction (`NfZoneDepthK1Probe.lean`) as the exact contrast case.

**Tasks**:
- [x] Read `bracketBuildRight`/`bracketBuildRight_correct` (VecEATranslation:50,234),
  `nf_char3_eq_succ_iff`/`nf_characteristic_quant_split3` (NfZoneDepthK:514,537), D1 probe
  (`NfZoneDepthK1Probe.lean`), Rabinovich §5 Cor 5.4, and report 40 §2.1-A.
- [x] `nf_eval_atom_layer` at the k=1 future-zone existential to pin exact env indices *(deviation:
  altered — used the sorry-free `nf_eval_atom_layer` atom-layer extraction rather than a fresh
  `lean_goal` probe; it directly exposes that `zoneEnv3` index 1 = `x` and `atom_eval (.pred p 1) =
  M.interp p x`, which is the load-bearing fact)*.
- [x] Attempt `A_fut_k1_correct` → **refuted (NO-GO)** *(deviation: altered — instead of a sorried
  `A_fut_k1`, proved the stronger sorry-free obstruction that NO `x`-independent `A` can satisfy the
  gate iff. Building a doomed `A_fut_k1` with a `sorry` would violate the zero-debt / off-path
  constraint; the obstruction lemma is the sanctioned NO-GO artifact "mirroring D1")*.
- [x] `lean_verify` all four probe theorems: sorry-free, axioms `[propext, Classical.choice,
  Quot.sound]`. ✓

**File targets**: new off-path module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneNavProbe.lean`.

**Estimated output**: ~200-350 lines. **Done when** (GO): `A_fut_k1_correct` sorry-free,
`lean_verify`-clean; `lake build` GREEN; live sorry count UNCHANGED at 2 (new decls off-path).
**Done when** (NO-GO): the iff is refuted by a concrete sorry-free obstruction lemma (mirroring D1's
`interior_bracket_cannot_realize_exterior_sub_k1` but for the navigable encoding), a divergence note
written, and the route STOPS into the Deferred `/spawn` closeout.

**Confidence**: MEDIUM (~50-60% GREEN). **Timing**: ~3 hours. **Depends on**: none.

**GATE DECISION**:
- **GREEN** → proceed to Phase 17.
- **NO-GO** → STOP. Land the Prior→INF navigation wiring + obstruction lemma off-path GREEN, write
  the divergence note, mark this plan [PARTIAL], and `/spawn` (see Deferred). Do NOT attempt Phases
  17-20; do NOT recede to a new framing.

**Verification**: `lake build` GREEN; `lean_verify` baseline axioms, no `sorryAx`; `grep '^axiom '`
zero new; live sorry count unchanged at 2; no flat-bracket / projection / arity-tower construction.

---

### Phase 17: Depth-k zone converter — past + interior arms [NOT STARTED]

*(CONDITIONAL on Phase 16 GREEN. Generalizes the k=1 gate to depth k for the `y<x` past and
`x<y<t` interior zones. MEDIUM-LOW confidence — the genuine inductive step.)*

**Goal**: Build the depth-k two-anchor arity-3 zone converter for the **past (`y<x`)** and
**interior (`x<y<t`)** zones: convert `∃ y, (y<x ∨ x<y<t) ∧ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`
into concrete `bracketBuildLeft` (past navigation, `Since`) / interior-bracket formulas whose
endpoint/point types are the depth-k IH formula `exist_tl_fn_k` (and its formula-level `¬`), proving
the iff against `nf_eval_nf` via `prior_hasAttainedINF` + the preserved `nf_zone_partition5` outer
split and `nf_char3_eq_succ_iff` inner split. This is Rabinovich Cor 5.4 lifted to depth-k
characteristic types, past/interior half.

**Reference grounding (H3, Tier 1)**: Rabinovich §5/Cor 5.4 (`md:119-157`); Phase-16 gate as the
proven template; `bracketBuildLeft` (VecEATranslation:50); `exist_tl_fn_k` (KampPrior:334);
preserved `nf_zone_partition5`/`nf_zone_exists_partition5` (NfZoneDepthK:366,397);
`prior_hasAttainedINF`, `neg_bounded_exists`.

**Tasks**:
- [ ] Define `nf_zone_nav_past` (`y<x` via `bracketBuildLeft`) and `nf_zone_nav_interior`
  (`x<y<t` via an interior bracket) as concrete uniform functions `NormalForm sig k 3 → Formula`,
  types = `exist_tl_fn_k _` / `¬`.
- [ ] Prove each zone iff against `nf_eval_nf M k 3 (zoneEnv3 y x t) qnf` restricted to its zone,
  mirroring the Phase-16 gate proof, discharging exterior/not-realized directions via
  `prior_hasAttainedINF h_UZ`.
- [ ] `lean_verify` each new decl sorry-free; off the live path.

**File targets**: `Kamp/NfZoneNavProbe.lean` (extend) or a new sibling `Kamp/NfZoneNav.lean`. Off-path.

**Estimated output**: ~350-500 lines. **Done when**: past + interior zone converters + iffs
sorry-free, `lean_verify`-clean; `lake build` GREEN; live sorry count unchanged at 2. **Split
fallback**: if one dispatch cannot land both, 17a = past (`bracketBuildLeft`), 17b = interior; each
ends GREEN off-path.

**Confidence**: MEDIUM-LOW. **Timing**: ~4-6 hours (may be 2 dispatches). **Depends on**: 16 (GREEN).

**Verification**: `lake build` GREEN; `lean_verify` baseline axioms, no `sorryAx`; zero new axioms;
live sorry count unchanged; no flat-bracket / arity-tower construction.

---

### Phase 18: Depth-k zone converter — future + diagonal arms + full assembly [NOT STARTED]

*(CONDITIONAL on Phase 16 GREEN. Mirror of Phase 17 for the future zone, plus the x=t diagonal arm,
plus the 5-zone converter assembly. MEDIUM-LOW confidence.)*

**Goal**: (a) Build the **future (`t<y`)** zone converter via `bracketBuildRight` (Until navigation),
mirror of Phase 17 (direct lift of the Phase-16 gate). (b) Build the **`y=x` / `y=t` point-zone**
arms via the preserved `renameNF_eval_diag0` (depth-0 diagonal congruence) — diagonal collapse
restricted to realizable forms. (c) Assemble all five zones (`y<x`, `y=x`, `x<y<t`, `y=t`, `t<y`)
via the preserved `nf_zone_partition5` into the full depth-k zone converter `nf_zone_nav_depthk` with
its complete iff against `∃ y, nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`. (d) Build the **x=t diagonal
arm** (`char_k1 ∘ mergeNF_succ`) needed by the Phase-19 assembly, using `renameNF_eval_diag0` +
`mergeNF_succ_atom` + the zone realizability structure.

**Reference grounding (H3, Tier 1)**: as Phase 17, plus `bracketBuildRight` (VecEATranslation:50);
`renameNF_eval_diag0` (NfDepth0Generalized:1646); `mergeNF_succ`/`_atom` (NfDepth0Generalized:593,599);
`char_k1`/`nf_succ_char_formula` (KampPrior:347); preserved `nf_zone_exists_partition5`.

**Tasks**:
- [ ] Define + prove `nf_zone_nav_future` (`t<y` via `bracketBuildRight`), mirror of Phase 17.
- [ ] Define + prove the `y=x` / `y=t` point-zone arms via `renameNF_eval_diag0`.
- [ ] Assemble `nf_zone_nav_depthk` over all 5 zones via `nf_zone_partition5`; prove the full
  converter iff.
- [ ] Build the x=t diagonal arm (`char_k1 (mergeNF_succ sub_nf 0 0)`) + its iff (restricted to
  realizable forms), reusing `renameNF_eval_diag0` for the atom layer + the zone realizability.
- [ ] `lean_verify` each new decl sorry-free; off the live path.

**File targets**: `Kamp/NfZoneNav.lean` (extend). Off-path.

**Estimated output**: ~350-500 lines. **Done when**: future + point-zone converters, full
`nf_zone_nav_depthk` iff, and the x=t arm iff all sorry-free, `lean_verify`-clean; `lake build`
GREEN; live sorry count unchanged at 2. **Split fallback**: 18a = future + assembly; 18b = x=t
diagonal arm; each ends GREEN off-path.

**Confidence**: MEDIUM-LOW. **Timing**: ~4-6 hours (may be 2 dispatches). **Depends on**: 16, 17.

**Verification**: as Phase 17.

---

### Phase 19: Assemble `exist_tl_fn_{k+1}` + rewire KampPrior:391 [NOT STARTED]

*(CONDITIONAL on Phases 17-18 GREEN. MEDIUM-HIGH confidence, contingent on the converter.)*

**Goal**: Assemble the uniform `exist_tl_fn_{k+1} : NormalForm sig (k+1) 2 → Formula` via a
**decidable compile-time 3-way case split on `sub_nf.1`** order atoms — `A(0<1)=false ∧
A(1<0)=false` → x=t arm (Phase 18); `A(0<1)=true` → x<t arm (Phase 17 past/interior fed through the
converter); `A(1<0)=true` → t<x arm (Phase 18 future); both true → `A := ⊥`. Prove the combined iff
against `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` as a standalone off-path lemma,
then **rewire `KampPrior.lean:391`** (`| 1 =>` arm), dropping live sorry count 2 → 1.

**Reference grounding (H3, Tier 1)**: report 39 D1 (decidable order-atom split, `⊥` arm); verified
`:391` goal (`insertEnv env t = Fin.cons (env 0) (fun _=>t)`, KampPrior:482); Phases 17/18 converter
+ x=t arm; `nf_eval_atom_layer` (NfZoneDepthK:190) for the order-atom decidability.

**Tasks**:
- [ ] Build `exist_tl_fn_{k+1}` with the decidable `sub_nf.1` order-atom 3-way split (+ `⊥` arm);
  prove the standalone iff against `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` as a
  named off-path lemma; `lake build` GREEN before touching `:391`.
- [ ] Add imports required by the assembly to `KampPrior.lean`; `lake build` to confirm no cycle and
  GREEN **before** editing the arm.
- [ ] Replace the `sorry` at `KampPrior.lean:391` (`| 1 =>` arm) with the assembled construction
  (rewrite `insertEnv env t` → `Fin.cons (env 0) (fun _=>t)` via the KampPrior:482 identity);
  `lake build` GREEN.
- [ ] `lean_verify completeness_discrete`: confirm the `:391` arm discharged, its `sorryAx` source
  gone; live sorry count now 1 (only `:394`).

**File targets**: `Kamp/KampPrior.lean` (imports + `:391` arm); assembly lemma in `Kamp/NfZoneNav.lean`.

**Estimated output**: ~250-400 lines. **Done when**: `:391` sorry removed, `lake build` GREEN,
`lean_verify completeness_discrete` shows the `:391`-sourced `sorryAx` gone, live sorry count 2 → 1,
baseline axioms unchanged.

**Confidence**: MEDIUM-HIGH (contingent on 17/18). **Timing**: ~3 hours. **Depends on**: 17, 18.

**Verification**: `lake build` GREEN; `grep -n sorry KampPrior.lean` shows only `:394` on the live
path; `lean_verify completeness_discrete` → `:391`-sourced `sorryAx` gone, live count 2 → 1;
`#print axioms completeness_discrete` = baseline; `grep '^axiom ' Theories/` = zero new; no
flat-bracket / projection / arity-tower / uniform-VecEA-negation appeal on the live path.

---

### Phase 20: Verification — clear/off-path :394, axiom + sorryAx audit [NOT STARTED]

*(CONDITIONAL on Phase 19. Carries forward v39 Phase 15 verbatim. MEDIUM-HIGH confidence.)*

**Goal**: Confirm `:394` (n≥2) cleared or provably off the live path with documentation, confirm
full GREEN and the baseline axiom set, and record the final live-path sorry inventory. Emit closure
outputs.

**Tasks**:
- [ ] `lean_verify completeness_discrete` to determine whether `:394` (`| n+2 =>` arm) is reachable
  on the live path. If off-path, document as a non-blocking off-path sorry (final live count = 1). If
  reachable and dischargeable via the phases-17-19 machinery at `m ≤ existing arity`, discharge it;
  if it would require general-m arbitrary-position closure, STOP and record a divergence note
  recommending the `/spawn` uniform-Prop-4.3 task (do NOT reintroduce an arity tower).
- [ ] `#print axioms completeness_discrete`: confirm exactly the baseline; note whether `sorryAx` is
  now absent (final live count 0) or still present via `:394` only (documented off-path).
- [ ] `grep '^axiom ' Theories/` → zero new top-level axioms.
- [ ] Confirm `lake build` GREEN; record the final live-path sorry inventory.
- [ ] Emit the task-303 closure note and feed the task-95 `#print axioms` audit.

**File targets**: `KampPrior.lean` (`:394` arm if live) + closure-note output.

**Estimated output**: ~50-150 lines. **Done when**: `:394` removed (final count 0, `sorryAx` gone)
OR documented off-path (final count 1, `sorryAx` retained via `:394` only); baseline axioms
confirmed; closure note written.

**Confidence**: MEDIUM-HIGH. **Timing**: ~2 hours. **Depends on**: 19.

**Verification**: `lake build` GREEN; `:394` removed OR documented off-path with a written
reachability note; `#print axioms completeness_discrete` = baseline; `grep '^axiom ' Theories/` =
zero new; closure note written; task-95 audit fed.

## Deferred / Follow-up Task Recommendation (candidate `/spawn`)

**Primary `/spawn` trigger — Phase 16 NO-GO.** If the gate refutes the navigable exterior-zone
capture (the multi-anchor single-point obstruction recurs even with `Since`/`Until` navigation),
STOP and `/spawn` a standalone task: *"Kamp Cor 5.4 depth-k zone converter — resolve the multi-anchor
single-point coupling: express the coupling of the quantified zone witness to the second anchor as a
uniform navigable temporal formula, or establish the definitive obstruction."* Carry forward the
bankable off-path assets (Prior→INF navigation wiring, `A_fut_k1` gate lemma or its obstruction
lemma) and the full Preserved Assets list. This new task depends on task 305.

**Secondary `/spawn` (unchanged from v39).** Uniform standalone Prop 4.3 (complete conjunction
closure `conjComplete` iff + bidirectional Prop 4.2 + general-m `existClosureAll`) — LOW-MEDIUM,
OFF the completeness path; wanted only as a standalone library asset. Does not gate
`completeness_discrete`.

## Testing & Validation

- [ ] `lake build` GREEN at every phase boundary (16-20).
- [ ] `lean_verify` on each new off-path declaration → baseline axioms, no `sorryAx`, no new axioms.
- [ ] `lean_verify completeness_discrete` sorry-inventory recorded at each boundary; live-path count
  2 (through Phase 18) → 1 (after Phase 19) → 0 or 1 (after Phase 20).
- [ ] `#print axioms completeness_discrete` shows the baseline axiom set unchanged.
- [ ] `grep '^axiom ' Theories/` confirms zero new top-level axioms at every boundary.
- [ ] No flat single-interval atomic bracket absorption, no projection `VecEA2`, no per-model
  existential bridge, no uniform VecEA negation, no arity-tower reintroduction, on the live path.
- [ ] Preserved assets unchanged.

## Artifacts & Outputs

- plans/40_prop43-negation-closure-route.md (this file)
- Phase 16 [GATE]: `A_fut_k1` + `A_fut_k1_correct` (or the obstruction lemma) in `Kamp/NfZoneNavProbe.lean` — sorry-free, off-path
- Phase 17: past + interior zone converters in `Kamp/NfZoneNav.lean` — sorry-free, off-path
- Phase 18: future + point-zone converters, full `nf_zone_nav_depthk`, x=t arm — sorry-free, off-path
- Phase 19: `exist_tl_fn_{k+1}` assembly; `KampPrior.lean:391` discharged; live sorry count 2 → 1
- Phase 20: `:394` cleared or documented off-path; `#print axioms` audit; task-303 closure note; task-95 audit fed
- summaries/40_prop43-negation-closure-route-summary.md (on completion)

## Rollback/Contingency

- Each phase is additive/append-only and build-GREEN at its boundary; revert is `git checkout` of the
  phase's commit. Phases 16-18 land off the live import path, so a failed Phase 19 rewire reverts
  without disturbing the proven converter.
- **Phase 16 NO-GO** is not a failure — it is a decisive, bankable outcome: land the off-path assets
  GREEN, document the obstruction, `/spawn` (see Deferred), keep `:391` as the baseline sorry.
- If Phase 17/18 (converter) resists after a bounded budget: split (17a/17b, 18a/18b), each GREEN
  off-path; do not churn a single dispatch. If it remains blocked, STOP, record a divergence note,
  keep `:391` baseline — do NOT force it via a flat bracket, projection, or arity tower.
- If Phase 19's `insertEnv` index-ordering resists: STOP, record a divergence note, keep the
  assembled iff off-path GREEN, re-scope the arm rewrite as the sole remaining sub-item.
- If Phase 20 finds `:394` reachable and needing general-m closure: STOP, document, recommend the
  `/spawn` uniform-Prop-4.3 task; do NOT reintroduce an arity tower.
- **Forbidden fallbacks** (do NOT take under any failure): flat single-interval atomic bracket
  absorption (D1 refuted), projection `VecEA2` (refuted), `VecEA_m.holds`-wiring as the `:391`
  object, per-model existential bridge, uniform VecEA negation, De Morgan / positive-NF construction,
  NF-depth / arity-tower reintroduction. All refuted (reports 18/37/38/39/40, plans 37/38/39) and closed.
- Baseline (build GREEN, 2 live sorries `:391`/`:394`, top-level axioms = 2) is the safe restore
  point; never commit a state that regresses it.
