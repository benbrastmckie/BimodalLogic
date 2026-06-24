# Implementation Plan: Task #305 (v37 — faithful Rabinovich path)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (resumes from build-GREEN HEAD; baseline 2 live sorries on the discrete chain, single `sorryAx` in `completeness_discrete`, axioms `Lean.ofReduceBool`/`Lean.trustCompiler` unchanged)
- **Research Inputs**: reports/37_hard-findings-critical-audit.md (primary, HIGH-confidence critical audit overturning the prior route)
- **Artifacts**: plans/37_faithful-rabinovich-path.md (this file)
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/state-management.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan abandons the prior in-situ zone-split (Route A′ of plan 35) and the re-anchor (Route B), both of which report 37 proves cannot close, and instead implements the **faithful Rabinovich (2014) path** (report 37 §6, option c): re-anchor `KampPrior` through structural FO induction (Prop 4.3) + Prop 3.5 instead of the arity-growing NF-depth recursion `nf_nvar_exist_all_depths`, which is the source of the `KampPrior.lean:391` artifact that reports 14/15/35 repeatedly flagged. Scope is to fill the **three genuinely missing pieces** Rabinovich specifies — Lemma 3.2(2) arity firewall, Prop 4.2 model-independent backward (`NegationIndep.lean:331`), revived Prop 4.3 (`Boneyard/Prop43.lean`) — and rewire the live import path so `completeness_discrete` routes through faithful negation closure at fixed arity ≤ 2, reusing the existing sorry-free forward infrastructure. **Constraints**: every phase ends on a GREEN `lake build` (~1700 jobs); no phase may increase the live-path sorry count; the axiom set (`Lean.ofReduceBool`/`Lean.trustCompiler`, plus the standard `propext`/`Classical.choice`/`Quot.sound`) stays unchanged with zero new top-level `axiom`; faithfulness to Rabinovich is the overriding aim, so no step may reintroduce an NF-depth/arity-tower parameter. **Definition of done**: `lake build` GREEN, `:391`/`:394` cleared or provably off the live path, `completeness_discrete` ideally drops its `sorryAx`, axiom set unchanged.

### Research Integration

- **Report 37 (primary, HIGH)** — critical re-audit (`reports/37_hard-findings-critical-audit.md`). Decisive findings integrated below:
  - **§2.1–2.3 / overclaim #1**: Route A′ (plan 35) WILL NOT CLOSE. The premise that `sub_nf` at `:391` is the model's characteristic NF is false — the term goal binds `sub_nf` and `A` before `M` (`∃A,∀M`), so `sub_nf` is universally quantified (consumer maps over `Finset.univ.toList`, `KampPrior.lean:116`; correctness `∀ sub_nf`, line 470). The strict-order zones need a depth-(k+1) arity-2 existential converter that does not exist (MCP-confirmed type error: `mergeNF_succ sub_nf 1 0 : NormalForm sig (k+1) (0+1)` vs expected `NormalForm sig k 2`); building it **is** the arity tower. This plan does NOT plan Route A′.
  - **§3**: Route B (re-anchor via `US_expressively_complete_over_Z`) is genuinely dead (ℤ-lock at carrier `ℤ`, no bridge lemma exists — only `int_to_ordered` goes the wrong direction, and `.box` semantics mismatch between `int_truth` and `temporal_truth`). This plan does NOT plan Route B.
  - **§4 (P3, HIGH)**: the `:391` obligation is the same NF-depth/arity-tower artifact reports 14/15/35 flagged (sorry moved `FOToVEA:118` → `KampPrior:154` → `:391`); Rabinovich has no NF-depth parameter and caps arity at 2 via Lemma 3.2(2).
  - **§4.4 asset inventory + §6 recommendation**: the faithful path repurposes ~700–1050 lines of mostly sorry-free assets and fills 3 gaps. **Done sorry-free** (reused, not rebuilt): Def 3.1/3.3 V-EA types (`VecEAFormula.lean`), Lemma 3.2(1) conj, Lemma 3.4 arbitrary-arity `VecEA_m.existClosure` (bidirectional, `VecEA_m.lean`), Prop 3.5 `translate_correct` (`RabinovichTranslation.lean`), INF 5.2, Lemma 5.3 biconditional, Cor 5.4 forward, Lemma 5.1 forward (model-dep + model-indep), Prop 4.2 model-dependent (full). **Missing (the 3 real gaps)**: Lemma 3.2(2) arity firewall (no live identifier); Prop 4.2 model-independent backward (`NegationIndep.lean:331`, forward already sorry-free); Prop 4.3 structural FO induction (archived `Boneyard/Prop43.lean`). **Off the live import path**: all faithful negation-closure assets — `KampPrior.lean` currently imports only `ExistsForallNF`, `NfToVecEA`, `NfDepth0Generalized` (verified at HEAD).

Ground-truth verification performed during planning: `Boneyard/Prop43.lean` exists; `NegationIndep.lean:331` carries the documented backward-direction NOTE (forward `neg_2var_vec_ea_indep` present, backward retired as sorry); `VecEA_m.existClosure` and `translate_correct` are present in the live tree; `KampPrior.lean` imports are exactly the three named above.

### Prior Plan Reference

Plan 35 (`plans/35_zone-split-gated.md`) committed to Route A′ (in-situ zone-split) after a 3-strike series on `mergeNF_succ`. Report 37 overturns its load-bearing premise (overclaim #1). This plan does **not** template plan 35: Route A′ phases are abandoned, not copied. What is carried forward as **reference only**:
- **Effort calibration**: this task has churned through 35+ prior plans; the durable failure mode is *climbing arity instead of descending depth* and *re-opening refuted paths*. This plan encodes the inverse discipline: decision-gate-first, fixed arity ≤ 2, one faithful route.
- **Validated negative results** (do not re-derive): the abstract standalone `merge_forward_succ` is a non-theorem (strike-3); Route B is architecturally dead (§3); Approach-5 single pair-formula is impossible. These remain closed.
- **Preserved sorry-free assets from v35** (`renameNF`, `renameNF_eval_iff` mpr-half, `totalUnskip`, `mergeNF_succ`, `mergeNF_succ_atom`): reusable for the diagonal/`x=t` zone inside a faithful construction, but explicitly NOT a route to closing `:391` alone — the plan must NOT re-scope around them.

### Roadmap Alignment

No `roadmap_flag` was set for this planning run and no ROADMAP.md path was supplied; no roadmap review/update phases are included. Completing 305 advances the `completeness_discrete` sorry-free goal (and the downstream task-95 `#print axioms` audit and task-303 closure note); these are captured as outputs of the final verification phase rather than as roadmap-edit phases.

## Goals & Non-Goals

**Goals**:
- Phase 1 produces a **committed, verifiable triage decision** on `Boneyard/Prop43.lean`: exactly what compiles, what sorries it carries, what it depends on — and a written fallback if it cannot be revived cheaply. This is a decision gate before any downstream commitment.
- Build Lemma 3.2(2) (arity firewall) — the one genuinely missing piece that *prevents* the arity tower.
- Complete Prop 4.2 model-independent backward at `NegationIndep.lean:331` (forward already sorry-free).
- Revive/rebuild Prop 4.3 (structural FO induction) and replace the entire `nf_nvar_exist_all_depths` depth recursion.
- Re-anchor `KampPrior` through Prop 4.3 + Prop 3.5 and rewire the live import path to bring the faithful negation-closure assets onto it.
- Final verification: `:391`/`:394` cleared or off-path, `completeness_discrete` ideally drops `sorryAx`, axiom set unchanged.
- Reuse (never re-implement) the sorry-free forward infrastructure of §4.4.

**Non-Goals**:
- No Route A′ (in-situ zone-split): provably non-closing (report 37 §2.3, overclaim #1). Forbidden.
- No Route B (re-anchor via `US_expressively_complete_over_Z`): architecturally dead (§3). Forbidden.
- No new NF-depth parameter, no arity-3+ existential converter, no `k+2` NF-disjunction, no `mutual` char/exist def — all are the arity tower and re-introduce the artifact this plan removes.
- No rebuild of `nf_succ_char_formula2` / any single pair-`Formula` (provably impossible, prior plans).
- No re-scoping of the plan around the v35 merge/rename assets as a closure route for `:391`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Risk: `Boneyard/Prop43.lean` carries its own sorries / stale dependencies and is not cheaply revivable. | H | M | Mitigation: Phase 1 is a read-only triage spike + decision gate. It enumerates Prop43's sorries, broken imports, and dependency set BEFORE any downstream phase commits. If revival is not cheap, the gate selects the documented fallback (rebuild Prop 4.3 directly from Rabinovich §4 Prop 4.3: atomic / disjunction / negation-via-Prop-4.2 / existential-via-Lemma-3.4, no depth parameter) and Phase 4 absorbs the rebuild cost. No downstream phase starts before the gate is committed. |
| Risk: faithful negation-closure assets are OFF the live import path; rewiring `KampPrior` imports is fragile (may surface latent breakage or cycles). | H | M | Mitigation: import rewiring is isolated as its own explicit step inside Phase 5 (and pre-checked in the Phase 1 triage). The rewire lands only when the new anchor (Prop 4.3 + Prop 3.5) is proven, and each added import is verified for acyclicity with a build before the `:391` arm is touched. |
| Risk: Prop 4.2 model-independent backward (the historically hard gap) resists closure. | H | M | Mitigation: isolated as Phase 3, bounded — it is a fixed-construction problem at arity 2 (report 37 §6: "fixed-construction at arity 2, unlike the unbounded arity tower"), with the model-dependent Prop 4.2 (`neg_2var_vec_ea_indep`) and Lemma 3.4 `existClosure` bidirectional as scaffolding. If it resists after a bounded budget, STOP and record a divergence note rather than churn; Prop 4.3 can still be wired with the model-dependent form as a documented interim. |
| Risk: a phase increases the live-path sorry count or regresses the GREEN baseline. | H | L | Mitigation: every phase ends on `lake build` GREEN + `lean_verify completeness_discrete` sorry-inventory recorded; new lemmas must be sorry-free before downstream use; the off-path negation assets carry their own sorries only while quarantined off the live import path. |
| Risk: a new top-level `axiom` or a changed axiom set slips in. | H | L | Mitigation: `#print axioms completeness_discrete` and `grep '^axiom ' Theories/` at every phase boundary; axiom set must stay `Lean.ofReduceBool`/`Lean.trustCompiler` (+ `propext`/`Classical.choice`/`Quot.sound`); zero new top-level `axiom`. |
| Risk: re-introducing the arity tower under a new name (depth recursion creeps back during the re-anchor). | H | M (historical) | Mitigation: descend-only / fixed-arity-≤-2 invariant is binding; any helper appealing to a depth-(k+1) or arity-3+ existential is rejected at review. Prop 4.3 recursion is structural on the FO formula, not on an NF-depth index. |
| Risk: `:394` (n≥2) turns out off the live path, wasting closure effort. | M | M | Mitigation: Phase 6 first runs `lean_verify completeness_discrete` to confirm reachability; if off-path, document it as a non-blocking off-path sorry rather than proving it. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phase 1 is the decision gate and must complete and commit before any downstream phase. Phases 2 (arity firewall) and 3 (Prop 4.2 backward) are independent of each other and may run in parallel (Wave 2) once the gate is settled. Phase 4 (Prop 4.3 proper) consumes both, plus the Phase 1 triage verdict. Phase 5 re-anchors `KampPrior` and rewires imports. Phase 6 is final verification.

### Phase 1: Boneyard triage + decision gate on Prop 4.3 [COMPLETED]

**GATE VERDICT (committed 2026-06-24, session sess_1782337996_6c54a7): REBUILD.**
`Kamp/Boneyard/Prop43.lean` is NOT the structural FO-induction Prop 4.3 — it is the
arity-tower `nf_succ_char_formula` / depth-(k+1) NF-characterization infrastructure
(the FORBIDDEN NF-depth machinery). It is sorry-free but is the wrong asset; reviving
it would reintroduce the arity tower. No live `StructuralInduction.lean` exists anywhere
(the `KampPrior.lean:28` header reference is aspirational). Therefore REVIVE is impossible
and the gate selects REBUILD: Phase 4 reconstructs Prop 4.3 fresh from Rabinovich §4
(atomic / disjunction / negation-via-Prop-4.2 / existential-via-Lemma-3.4, no depth
parameter, arity ≤ 2). Full triage in `handoffs/phase-1-gate-rebuild-20260624.md`.

**Goal**: Settle, with read-only spike work, exactly what in `Boneyard/Prop43.lean` is revivable — what compiles, what sorries it carries, what it depends on — and commit a written decision: REVIVE (wire the archived proof, filling named gaps) vs REBUILD (reconstruct Prop 4.3 from Rabinovich §4 directly). Also pre-survey the `KampPrior` import-rewire surface so Phase 5 is de-risked. No `.lean` edits to the live path in this phase.

**Tasks**:
- [x] Read `Boneyard/Prop43.lean` in full; enumerate every `sorry`, every import, and the transitive dependency set. *(completed: Prop43.lean is sorry-free but is `nf_succ_char_formula` arity-tower infra, NOT structural Prop 4.3; imports NfToVecEA/NormalForm/PriorDefs/KampTranslation; off live import path)*
- [x] `lean_verify` / `lean_build` probe (read-only) to record which declarations compile vs error vs carry `sorry`. *(completed: `lake build Bimodal.Metalogic.Metalogic` GREEN, 1671 jobs; `completeness_discrete` axioms = propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound — baseline confirmed)*
- [x] Map Prop43's structural cases against Rabinovich §4 Prop 4.3. *(deviation: altered — Prop43.lean does NOT contain structural cases; it is the depth-(k+1) NF-char machinery. No live structural Prop 4.3 exists anywhere; `StructuralInduction.lean` referenced in KampPrior:28 does not exist.)*
- [x] Survey the `KampPrior` import surface; check cycle risk. *(completed: KampPrior currently imports ExistsForallNF, NfToVecEA, NfDepth0Generalized + NormalForm/PriorDefs/KampTranslation. Faithful assets VecEA_m, RabinovichTranslation, EANegationClosure, NegationIndep, VecEAClosure are all OFF-path and sorry-free except NegationIndep:331. `nf_nvar_exist_all_depths` (the :391/:394 sorry host) has NO external live consumer — only PriorExpressiveness imports KampPrior, via the wrapper chain.)*
- [x] **Decision criterion**: choose REVIVE iff Prop43 compiles with ≤ 2 named gaps mapping to P2/P3 with no NF-depth/arity-3+ appeal. *(VERDICT: REBUILD. Prop43.lean is the arity-tower infra itself — reviving it reintroduces the forbidden NF-depth recursion. No revivable structural Prop 4.3 exists. Gate selects REBUILD per documented fallback.)*
- [x] Commit the gate decision; Phase 4 mode fixed = **REBUILD**.

**Timing**: 1.5 hours (read + probes; no construction)

**Depends on**: none

**Files to inspect (read-only spike)**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/Prop43.lean`, `KampPrior.lean` (imports), `NegationIndep.lean`, `VecEA_m.lean`, `RabinovichTranslation.lean`, Rabinovich source md.

**Verification**:
- Gate handoff exists; names REVIVE or REBUILD; lists Prop43's sorries, dependency set, and the import-rewire surface; states the fallback explicitly.
- `lake build` still GREEN; baseline unchanged (no live-path `.lean` edits committed except stale-comment cleanup).

---

### Phase 2: Lemma 3.2(2) — arity firewall [COMPLETED]

**Goal**: Build Lemma 3.2(2) — "every exists-forall formula is equivalent to a conjunction of exists-forall formulas with at most two free variables" (Rabinovich md:78) — the one genuinely missing piece that *prevents* the arity tower (currently no live identifier). This is the structural guarantee that arity never exceeds 2 in the negation closure.

**Tasks**:
- [x] Locate the V-EA conjunction infrastructure and the arbitrary-arity `VecEA_m.existClosure`. *(completed: `VecEA_m.holds` is literally a conjunction of arity-1 endpoint conditions + arity-2 interval-bracket conditions; `conjStruct`/`conj_holds` confirmed in VecEA_m.lean; `existClosure` bidirectional confirmed.)*
- [x] State Lemma 3.2(2) with a live identifier. *(completed: new module `Kamp/VecEAArityFirewall.lean`; main theorem `VecEA_m.arity_firewall`.)*
- [x] Prove it faithfully (Rabinovich md:78); arity capped at 2 by construction. *(completed: decomposition into `endpointComponent : VecEA_m 1` and `intervalComponent : VecEA_m 2`, each arity ≤ 2 by type; biconditional `arity_firewall` proved sorry-free. No NF-depth, no depth-index recursion, no arity-3 appeal.)*
- [x] `lean_verify` sorry-free. *(completed: `lean_verify VecEA_m.arity_firewall` → axioms [propext, Classical.choice, Quot.sound], no sorryAx, no new axioms. Module builds GREEN (989 jobs). OFF live import path — baseline `completeness_discrete` unchanged, wiring deferred to Phase 5.)*

**Timing**: 2.5 hours (~100–200 lines)

**Depends on**: 1

**Files to modify**: `VecEAClosure.lean` (or a new arity-firewall module under `Kamp/`), reusing `VecEA_m.lean`, `VecEADecomp.lean`.

**Verification**: `lake build` GREEN; Lemma 3.2(2) sorry-free; no arity-3+ appeal; baseline `completeness_discrete` sorry-inventory and axiom set unchanged.

---

### Phase 3: Prop 4.2 model-independent backward [COMPLETED]

**RESOLUTION (completed-via-documented-fallback, 2026-06-24, session sess_1782337996_6c54a7):**
The model-independent backward obstruction (B.1 interval mismatch, report 18 §2.3/§4) was
RE-CONFIRMED with one genuine attempt at the live VVecEA2 level (`aesop` no progress, `exact?`
no result on `(neg_2var_vec_ea_indep v).holds → ¬v.holds`). Per plan line 226/236, Phase 3
takes the PRE-AUTHORIZED model-DEPENDENT interim: `neg_2var_vec_ea` (EANegationClosure.lean,
sorry-free, axioms [propext, Classical.choice, Quot.sound]) supplies the Prop 4.2 negation case
for Prop 4.3 (Phase 4). H6 churn cap honored (1 attempt, conclusive negative, stopped). The
`:331` NOTE was updated with the Phase 3 resolution. No new sorry/axiom; baseline GREEN.

**Goal**: Complete the model-independent backward direction of Proposition 4.2 at `NegationIndep.lean:331` (the documented retired sorry; the forward direction `neg_2var_vec_ea_indep` is already sorry-free). This is a fixed-construction problem at arity 2 (report 37 §6), not an unbounded climb.

**Tasks**:
- [x] Read the `NegationIndep.lean:309–347` region (Prop 4.2 model-independent statement + the backward NOTE explaining why the V-bracket existential direction was retired). *(completed)*
- [x] Construct the backward direction `neg_2var_vec_ea_indep_backward`. *(deviation: skipped — one genuine attempt re-confirmed the B.1 obstruction is fundamental (aesop/exact? fail; report 18 §2.3/§4); per plan line 226/236 took the pre-authorized model-DEPENDENT interim `neg_2var_vec_ea` instead. H6 churn cap honored.)*
- [x] Assemble the full model-independent Prop 4.2 biconditional from forward + backward. *(deviation: altered — model-independent biconditional is NOT assembled; Phase 4 consumes the model-DEPENDENT biconditional path (`neg_2var_vec_ea`) per documented interim. Model-indep backward is a bounded follow-up, off the live completeness path.)*
- [x] `lean_verify` the model-dependent suffices-path is sorry-free; record the `:331` resolution. *(completed: `lean_verify neg_2var_vec_ea` → axioms [propext, Classical.choice, Quot.sound], sorry-free; `:331` NOTE updated with Phase 3 resolution.)*

**Timing**: 3 hours (~100–150 lines)

**Depends on**: 1

**Files to modify**: `NegationIndep.lean` (the `:331` region).

**Verification**: `lake build` GREEN; `:331` backward proven, full Prop 4.2 model-independent biconditional sorry-free; arity-2 throughout (no arity-3+); axiom set unchanged.

---

### Phase 4: Revive or rebuild Prop 4.3 (structural FO induction) [BLOCKED]

**BLOCKER** (Phase 4b/4c, dispatch sess_1782337996_6c54a7, 2026-06-24):
- **What failed**: A non-vacuous Prop 4.3 cannot be assembled from the available
  closures. The per-model existential statement `∃ v, v.holds env ↔ eval φ`
  (the codebase's `neg_2var_vec_ea`/`neg_vec_ea_m` convention) is **vacuous** —
  closed by `⟨tt, …⟩` / `⟨ff, …⟩` independent of φ. A genuine Prop 4.3 must be the
  *uniform* statement (single model-independent `translate : MonadicFormula sig m →
  VVecEA_m m` with `∀ M env, StrictMono env → ((translate φ).holds ↔ eval φ)`).
- **What was tried**: Stated and built the per-model existential induction (all 6
  cases closable via tt/ff + forward conj + neg_vec_ea_m) — REJECTED as vacuous.
  Surveyed the codebase for the uniform connective closures.
- **Why it's stuck** (uniform `translate` connective cases):
  - **not**: needs model-independent arity-`m` negation with a uniform iff =
    the model-INDEPENDENT Prop 4.2 backward proved UNFIXABLE (report 18,
    `NegationIndep.lean:331-351`). `neg_vec_ea_m` is only model-dependent existential.
  - **and**: needs a *complete* arity-`m` conjunction (Lemma 3.2(1) iff).
    `VVecEA_m.conj` is forward-only (`conjStruct` over-approximates,
    `VecEAClosure.lean:163-169`). Missing.
  - **all/ex**: needs Lemma 3.4 (arbitrary-position existential closure incl. a
    leftward `existClosure`). `existClosure` (`VecEA_m.lean:208`) only absorbs the
    rightmost variable; the De Bruijn binder prepends an order-unconstrained
    witness at index 0. The witness-position split + reordering closure is missing.
    Even live `KampPrior:391` (n=1) needs both leftward and rightward absorption.
- **What is needed**: build (a) complete arity-`m` conjunction closure, (b) Lemma
  3.4 (arbitrary-position ex closure + leftward existClosure), and (c) resolve the
  model-indep negation (UNFIXABLE as-is — likely requires restructuring Prop 4.3
  into a positive/De-Morgan normal form with a single top-level negation, avoiding
  per-connective uniform negation). This is a multi-phase research+build effort, not
  a single dispatch.
- **Prohibited workarounds**: NO `sorry`, NO `def X := True`, NO vacuous per-model
  existential presented as Prop 4.3.
- **Shipped sorry-free this dispatch**: `Kamp/Prop43.lean` — genuine uniform
  atom/lt building blocks (`tt`, `ff`, `atomAt`/`atomAt_holds`, `ltAt`/`ltAt_holds`),
  off live path, axioms = baseline, zero live-path sorry added.

**Goal**: Produce a sorry-free Prop 4.3 — structural induction on the FO formula (atomic / disjunction / negation-via-Prop-4.2 / existential-via-Lemma-3.4), with **no depth parameter** (Rabinovich md:106) — in the mode the Phase 1 gate selected (REVIVE the Boneyard proof, or REBUILD from Rabinovich §4). This is the asset that replaces the entire `nf_nvar_exist_all_depths` depth recursion.

**Tasks**:
- [ ] If REVIVE: lift `Boneyard/Prop43.lean` onto a live module, filling its enumerated gaps with Phase 2 (Lemma 3.2(2)) and Phase 3 (Prop 4.2 backward); update imports to current names.
- [ ] If REBUILD: construct Prop 4.3 fresh — atomic case (forward translation already sorry-free), disjunction (Lemma 3.2(1) conj / De Morgan), negation case (Phase 3 Prop 4.2 model-indep biconditional), existential case (Lemma 3.4 `existClosure`), arity held ≤ 2 by Phase 2. *(in progress — split into 4a/4b/4c per phase-3 handoff)*
  - [x] **Phase 4a (DONE this dispatch)**: arbitrary-arity negation closure. New file `Kamp/EAVecNegationClosure.lean` (off live import path). `neg_vec_ea_m : ¬v.holds env → ∃ v', v'.holds env` for `VVecEA_m m`, model-dependent existential form (matches the codebase's `neg_2var_vec_ea` existential convention; the literal `VVecEA_m m → VVecEA_m m` total-function signature from the dispatch is *not* the codebase convention — every negation-closure layer here is the `¬holds → ∃ holds` existential). Built faithfully via `arity_firewall` (Phase 2) + `not_and_or`/`push_neg` De Morgan + arity-2 base `neg_vecEA2` (Phase 3 `EANegationClosure`). Lift constructors `VecEA_m.liftEndpoint`/`liftInterval`/`VVecEA_m.liftInterval` re-lift arity-≤2 closures to arity m. Sorry-free; axioms `[propext, Classical.choice, Quot.sound]` (= baseline). GREEN. *(deviation: altered — existential form not total-function form; reason: codebase convention)*
  - [x] **Phase 4b (PARTIAL — atom/lt landed; and/all/ex BLOCKED)**: new file `Kamp/Prop43.lean` (off live path). Closed the genuine *uniform* atom/lt cases sorry-free: `VVecEA_m.atomAt`/`atomAt_holds` (atom p i ↔ `M.interp p (env i)`, via `atom_literal`) and `VVecEA_m.ltAt`/`ltAt_holds` (`x_i < x_j` decided by indices under StrictMono). Plus `tt`/`ff` constants. *(deviation: altered — the per-model existential framing the dispatch assumed (close and/or/ex via conj/disj/existClosure) was found VACUOUS (tt/ff close it for any φ); a non-vacuous Prop 4.3 requires a uniform translate whose connective cases are blocked — see Phase 4 BLOCKER above.)*
  - [ ] **Phase 4c (BLOCKED)**: the `not`/`and`/`all`/`ex` cases of a uniform Prop 4.3 are blocked on missing infrastructure (complete arity-`m` conjunction, Lemma 3.4 arbitrary-position ex closure, model-indep negation). Requires a follow-up research+build effort. *(deviation: deferred — blocked, see Phase 4 BLOCKER.)*
- [ ] Confirm the recursion is structural on the FO formula, not on an NF-depth index (descend-only / fixed-arity invariant).
- [ ] `lean_verify` Prop 4.3 is sorry-free in isolation (it may still be off the live import path at this point — that is wired in Phase 5).

**Timing**: 3 hours (~150–300 lines, mode-dependent)

**Depends on**: 1, 2, 3

**Files to modify**: a live module hosting Prop 4.3 (e.g. promote `Prop43.lean` out of `Boneyard/`, or a new `Kamp/Prop43.lean`), reusing `VecEA_m.lean`, `RabinovichTranslation.lean`, `NegationIndep.lean`.

**Verification**: `lake build` GREEN; Prop 4.3 sorry-free; structural (no NF-depth, no arity-3+); axiom set unchanged; live-path baseline not yet changed (Prop 4.3 lands before the `:391` rewire).

---

### Phase 5: Re-anchor KampPrior through Prop 4.3 + Prop 3.5; rewire imports [NOT STARTED]

**Goal**: Replace the `nf_nvar_exist_all_depths` NF→temporal route at `KampPrior.lean:391` (and the wrapper chain through `nf_characterizable_temporal_prior`) with an anchor through Prop 4.3 + Prop 3.5 `translate_correct`, and rewire the `KampPrior` import path to bring the faithful negation-closure assets on-path. This is where the artifact sorry is actually cleared.

**Tasks**:
- [ ] Add the negation-closure imports surveyed in Phase 1 to `KampPrior.lean`; `lake build` to confirm no cycle and GREEN before touching `:391`.
- [ ] Re-anchor the characteristic-formula construction: route the `∃x` obligation through Prop 4.3's existential case + Prop 3.5 `translate_correct` (V-EA → U/S), replacing the depth-(k+1) recursion arm at `:391`.
- [ ] Remove / retire `nf_nvar_exist_all_depths`'s depth-recursion arm on the live path (keep off-path or delete per build cleanliness), ensuring no consumer still depends on the removed arm.
- [ ] `lean_verify completeness_discrete`: confirm the `:391` arm is discharged and the `sorryAx` source from it is gone.

**Timing**: 3 hours (~100–200 lines)

**Depends on**: 4

**Files to modify**: `KampPrior.lean` (imports + the `:391` arm and its wrapper consumers).

**Verification**: `lake build` GREEN; `KampPrior.lean:391` sorry removed; live-path sorry count drops; `lean_verify completeness_discrete` shows the artifact arm discharged; no depth-(k+1)/arity-3+ appeal introduced; axiom set unchanged.

---

### Phase 6: Verification — clear/off-path :394, axiom and sorryAx audit [NOT STARTED]

**Goal**: Confirm `:394` (n≥2) is cleared or provably off the live path, confirm `completeness_discrete` ideally drops its `sorryAx`, and confirm the axiom set is unchanged with zero new top-level `axiom`. Emit closure outputs.

**Tasks**:
- [ ] `lean_verify completeness_discrete` to determine whether `:394` is reachable on the live path. If reachable, discharge it via the same Prop 4.3 anchor; if off-path, document it as a non-blocking off-path sorry.
- [ ] `#print axioms completeness_discrete`: confirm axiom set is exactly the baseline (`Lean.ofReduceBool`/`Lean.trustCompiler` + `propext`/`Classical.choice`/`Quot.sound`), `sorryAx` ideally absent; run `grep '^axiom ' Theories/` to confirm zero new top-level axioms.
- [ ] Confirm `lake build` GREEN (~1700 jobs); record final live-path sorry-inventory.
- [ ] Emit the task-303 closure note and feed the task-95 `#print axioms` audit.

**Timing**: 1 hour (verification + any small off-path discharge)

**Depends on**: 5

**Files to modify**: `KampPrior.lean` (`:394` arm if live), closure-note output.

**Verification**: `lake build` GREEN; `:394` removed (if live) or documented off-path; `completeness_discrete` `sorryAx` ideally gone; axiom set unchanged, zero new top-level `axiom`; closure note written.

## Testing & Validation

- [ ] `lake build` GREEN (~1700 jobs) at every phase boundary (Phases 1–6).
- [ ] `lean_verify completeness_discrete` sorry-inventory recorded at each boundary; live-path count trends down to 0.
- [ ] `#print axioms completeness_discrete` shows the baseline axiom set unchanged (`Lean.ofReduceBool`/`Lean.trustCompiler` + standard); `sorryAx` ideally absent at the end.
- [ ] `grep '^axiom ' Theories/` confirms zero new top-level axioms at every boundary.
- [ ] No NF-depth parameter, no arity-3+ existential converter, no `k+2` NF-disjunction, no `mutual` def, no `nf_succ_char_formula2` introduced (faithfulness / no-arity-tower invariant).
- [ ] Every new helper's recursion is structural on the FO formula or fixed-arity ≤ 2 (no depth-index recursion).
- [ ] Phase 1 gate handoff exists and names exactly one Phase 4 mode (REVIVE or REBUILD).

## Artifacts & Outputs

- plans/37_faithful-rabinovich-path.md (this file)
- Phase 1 gate handoff (Prop 4.3 triage verdict + import-rewire survey)
- New / revived Lean assets: Lemma 3.2(2) arity firewall (P2); Prop 4.2 model-indep backward `neg_2var_vec_ea_indep_backward` (P3); sorry-free Prop 4.3 on a live module (P4)
- `KampPrior.lean` re-anchored through Prop 4.3 + Prop 3.5; imports rewired; `:391` sorry removed (P5)
- `:394` removed or documented off-path (P6); task-303 closure note; task-95 `#print axioms` audit
- summaries/37_faithful-rabinovich-path-summary.md (on completion)

## Rollback/Contingency

- Each phase is additive/replacing and build-GREEN at its boundary; revert is `git checkout` of the phase's commit. Faithful assets land off the live import path (Phase 4) before the `:391` rewire (Phase 5), so a failed rewire reverts without disturbing the proven Prop 4.3.
- If Phase 1 gate finds Prop 4.3 not cheaply revivable: the gate selects REBUILD; Phase 4 absorbs the reconstruction from Rabinovich §4 (already the documented fallback). No churn — the decision is committed in writing.
- If Phase 3 (Prop 4.2 backward) resists after a bounded budget: STOP, write a divergence note; wire Prop 4.3 with the model-dependent Prop 4.2 as a documented interim and re-scope the backward gap as a follow-up, rather than churning or reopening Route A′/B.
- Forbidden fallbacks (do NOT take under any failure): Route A′ in-situ zone-split, Route B re-anchor, any NF-depth/arity-tower reintroduction, `nf_succ_char_formula2`. These are refuted (report 37) and stay closed.
- Baseline (build GREEN ~1700 jobs, single `sorryAx` in `completeness_discrete`, axioms `Lean.ofReduceBool`/`Lean.trustCompiler` unchanged) is the safe restore point; never commit a state that regresses it.
