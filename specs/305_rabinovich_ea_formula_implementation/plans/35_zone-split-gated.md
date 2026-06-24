# Implementation Plan: Task #305 (v35, HARD MODE — gated zone-split)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: None (resumes from build-GREEN HEAD; baseline 2 sorries, 2 axioms)
- **Research Inputs**: reports/35_team-research.md (primary, HIGH-confidence team synthesis); handoffs/v34-phase-1-blocked.md (continuation context)
- **Artifacts**: plans/35_zone-split-gated.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, lean4.md, literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false
- **Mode**: HARD (H3 reference grounding, H6 convergence policing, H8 phase sizing, H9 wrap-up discipline)

## Overview

This plan eliminates the two remaining `sorry` in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (line 391, n=1, **critical path**;
line 394, n>=2, off-path) — the sole blockers for a sorry-free `completeness_discrete` — by the
**faithful, bounded zone-split** route that report 35's four teammates converged on with HIGH
confidence. The blocker is **self-inflicted** (an induction-on-NF-depth-with-growing-arity
architecture absent from Rabinovich), not a real mathematical obstacle, and the previously-planned
Approach-5 single pair-formula is **provably impossible** (report 35; a temporal `Formula` is
evaluated at one point and cannot carry a free `x` slot). Because one of the two faithful exits
(re-anchoring through the already sorry-free `US_expressively_complete_over_Z`) may make the bulk
construction **unnecessary**, the plan opens with a **cheap decision gate (Phase 0)** that settles
the route with minimal spike work *before* committing hundreds of lines. The chosen route then
executes leaf-by-leaf, each phase build-GREEN at its boundary, ending by rewiring KampBypass `k>0`
to the single-structure path and discharging the PriorComposition sorry. **Definition of done**:
`lake build` GREEN, zero live `sorry` on the `completeness_discrete` chain, no new axioms (baseline
2 preserved), no regression of build-GREEN at any phase boundary.

### Research Integration

- **Report 35 (primary, HIGH)** — team synthesis of 4 teammates. Establishes: (1) the
  `KampPrior.lean:391` blocker is self-inflicted by arity-growing depth induction with no Rabinovich
  counterpart; (2) the Approach-5 pair-formula `nf_succ_char_formula2` is **provably impossible** and
  the entire Approach-5 family is dead; (3) two faithful exits exist — fix-in-place 3-way zone split
  (Teammate A == Teammate B "A1", independently derived) and re-anchor through
  `US_expressively_complete_over_Z` (Teammate C, contradicting report 24's "non-viable" verdict);
  (4) the synthesis **mandates a cheap decision gate** (its Phase 1) before construction because the
  re-anchor route may make construction moot. Its §"Recommendations" supplies the staged plan this
  document implements; its zone-split skeleton table (H1-H3 + wire) is the construction backbone.
- **handoffs/v34-phase-1-blocked.md (continuation context)** — confirms the live sorries are
  KampPrior.lean:391 (critical) and :394 (off-path), build is GREEN, baseline unchanged. Supplies the
  concrete obstacle decomposition (Obstacle 1 joint x-t coupling; Obstacle 2 missing depth-k merge)
  and the dependency-ordered construction steps reused below (`mergeNF_succ` first, then zone
  endpoints, then bind/wire).

### Prior Plan Reference

Plan v34 (`plans/34_approach5-arity2-char.md`) committed to building `nf_succ_char_formula2`, a
single `Formula` characterizing the pair `(x,t)`. **Report 35 proves this is impossible** and kills
the whole Approach-5 family. This plan does **not** replicate v34: `nf_succ_char_formula2` is
explicitly **forbidden** (see H6 anti-churn guardrails). What v34 leaves usable is its **Preserved
Assets accounting** (sorry-free infrastructure inventory), reproduced and corrected below. Effort
calibration across 34 prior plans: the recurring failure mode is *re-opening refuted paths* and
*climbing arity instead of descending depth*; the single durable lesson is "one live route, descend
only, gate before bulk." This plan encodes that lesson structurally.

### Roadmap Alignment

No `roadmap_flag` was set for this planning run and no ROADMAP.md path was supplied; no roadmap
review/update phases are included. Report 35 §Horizons notes that completing 305 advances three
roadmap-adjacent items at once (closes the sole sorry blocking `completeness_discrete`; emits the
task-303 closure note; feeds the task-95 `#print axioms` audit). These are captured as outputs of
the final phase rather than as roadmap-edit phases.

## Preserved Assets (DO NOT RE-PLAN, DO NOT DESTABILIZE)

Sorry-free and build-passing at HEAD. Inputs to this plan; MUST NOT be re-implemented or regressed.

| Asset | Location | Role in this plan |
|-------|----------|-------------------|
| `nf_2var_exist_depth0_tl` (4-arm zone match) | NfToVecEA.lean:702 | The depth-0 zone-split **template** to lift one depth up (true/true=>bot; true/false=>Until; false/true=>Since; false/false=>x=t) |
| `mergeNF` / `merge_forward` | NfDepth0Generalized.lean:157/168 | Depth-0 position-merge to **generalize** to depth-k (x=t zone) |
| `nf_characterizable_temporal_prior` (now sorry-free) | KampPrior.lean | Depth-(k+1) arity-1 endpoint characteriser; its own dependency is `exist k 1` (strictly below) |
| `char_k1` / `exist_tl_fn_k` (+ correctness) | KampPrior.lean:333-361 | In scope at the `k+1` arm; reused as-is for endpoints |
| `nf_nvar_exist_all_depths` `\| 0` arm + `k+1, n=0` sub-case | KampPrior.lean:264-267, 375-386 | DONE base/n=0 cases; untouched |
| `translateEF1` (+ `_correct`) (Prop 3.5) | Translation.lean:243 | Interval -> Until/Since; backbone of the future/past zone endpoints |
| `VecEA_m.existClosure` (+ `_correct`, `_correct_rev`, bidirectional) | VecEA_m.lean:208/251/314 | **FALLBACK** x-binder for the strict zones if H2/H3 telescoping resists (dormant; wire only if needed) |
| `insertEnv` (+ `_zero`/`_last`/`_init`) | NfDepth0Generalized.lean:42-56 | Environment-splicing identities for the Fin-2 bridge |
| Fin-1 telescoping bridge (`h_env_eq`) | KampPrior.lean:317-331, 497-513 | Trivial Fin-1 -> exists-x reduction template, already proved twice in-file |
| `US_expressively_complete_over_Z` (sorry-free, via Separation Theorem) | ExpressiveCompleteness/Theorem.lean:357 | The **re-anchor target** evaluated in Phase 0 G1 |
| `completeness_discrete` chain | BXCanonical/Completeness.lean:356-357 | The live top consumer; `lean_verify` target at every boundary |

**Baseline to preserve**: 2 code sorries (KampPrior.lean:391, 394), 2 axioms in `Theories/`,
`lake build` GREEN (1700 jobs). No phase may regress any of these except by *removing* sorries.

## Goals & Non-Goals

**Goals**:
- Phase 0 produces a **committed, verifiable route decision** (Route A fix-in-place zone-split vs
  Route B re-anchor) using only cheap spike work — no large construction.
- Eliminate `sorry` at KampPrior.lean:391 (n=1, critical) via the chosen route.
- Eliminate `sorry` at KampPrior.lean:394 (n>=2) **only if** `lean_verify` shows it on the live path.
- Rewire KampBypass `k>0` to the single-structure path and discharge the PriorComposition sorry,
  **only after** the n=1 critical arm clears.
- Final state: `lake build` GREEN, zero live sorry on `completeness_discrete`, axiom count == 2.

**Non-Goals**:
- No rebuild of `nf_succ_char_formula2` or any single pair-formula (PROVABLY IMPOSSIBLE — forbidden).
- No full separation theorem in Lean; no Gabbay-1993 gap connectives; no `mutual` char/exist def;
  no `k+2` NF-disjunction (each recreates the genuine 2-cycle — all refuted in report 35).
- No reactivation of the 8 dormant files as the *primary* route (VecEA_m is fallback-only).
- No refactor/banner-demote work beyond what a phase explicitly authorizes (out of scope here).

## H6 Convergence Policing — Anti-Churn Guardrails (BINDING)

This task has churned through 34 plans. The following are **binding constraints** on every dispatch:

1. **Single live route after the gate.** Phase 0 commits to exactly one of Route A / Route B in
   writing (`handoffs/v35-gate-decision.md`). Once committed, the other route is closed; reopening
   it requires a *new* gate with explicit written justification overturning the gate evidence.
2. **Forbidden paths (do not implement, do not "probe"):** `nf_succ_char_formula2` / any single
   pair-`Formula`; `mutual` char/exist; `k+2` NF-disjunction; full Lean separation theorem; vacuous
   `def X := True` or leaf-`sorry` placeholders standing in for steps 1-3.
3. **Descend-only invariant.** Every new helper's recursive/IH appeal must be at depth `<= k`
   (strictly `< k+1`). Any construction that appeals to depth `k+1` or `k+2` content is a
   convergence violation and must be rejected at review.
4. **Three-strikes per leaf.** If a single leaf (e.g. `mergeNF_succ`) fails to close after 3
   dispatches, STOP and write a divergence note; do not silently switch leaves or reopen Approach-5.
5. **Refutation ledger.** Every dispatch states which prior premise (if any) it overturns; silent
   reversion of a gate decision or a refuted path is prohibited.
6. **One hole per dispatch.** Implementers touch one named leaf at a time; `lean_verify
   completeness_discrete` sorry-inventory recorded at each boundary.

## H3 Reference Grounding — Rabinovich §3/§5 Mapping (faithfulness ground truth)

Ground truth: `specs/literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(also `.pdf`). Each construction step must trace to the cited source location; deviations are
flagged in the phase's verification.

| Plan step / artifact | Rabinovich (2014) anchor | What is transcribed |
|-----------------------|--------------------------|---------------------|
| 3-way zone disjunction (`x<t / x=t / t<x`) | §5 interval splitting; §3 Def 3.1 (V-EA at a point) | Inserted points handled by interval/zone split, never by a higher-depth characteristic formula |
| Future-zone endpoint via Until | Prop 3.5 (V-EA -> U/S), eq for the `<` order bracket | `translateEF1` realizes the V-EA -> Until direction at the future zone |
| Past-zone endpoint via Since | Prop 3.5 (V-EA -> U/S), `>` order bracket | `translateEF1`/`buildLeft` realizes the Since direction at the past zone |
| Equal-zone (`x=t`) collapse | §3 atom-conjunction at a single point; Lemma 3.4 (closure) | `mergeNF_succ` collapses the arity-3 quant NF (y,x,t) at the merged position |
| Forward-only per layer (no V-EA negation needed at inner layers) | Lemma 5.1 forward construction; top-level neg is free (Formula.neg + NF uniqueness) | Each layer needs only a forward construction; the recursion descends in depth |
| INF / first-occurrence faithfulness (G2) | §5 eq 5.2 (INF), Prop 4.2 | Decide `semantic_prior_UZ` "first occurrence" vs `HasAttainedINF` infimum adequacy for the discrete target |
| Re-anchor through US-complete-over-Z (G1) | (Route B) Gabbay ch.9/ch.12 expressive completeness via separation | Whether the discrete target routes through the finished Z-proof, bypassing the construction |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Gate is mis-decided (picks construction when re-anchor was viable, or vice-versa) | H | M | Phase 0 decision criterion is explicit & verifiable (below); both G1 and G2 must be answered with a `lean_verify`/chain-read spike, not asserted; decision committed to a handoff file before any construction |
| H2 `mergeNF_succ` quant-layer commutation does not close (the make-or-break) | H | M | Isolated as its own phase (smallest self-contained piece) with a 3-strikes budget; `VecEA_m.existClosure` fallback pre-identified for the strict zones; if H2 fails after 3 strikes, escalate to gate re-eval rather than churn |
| Re-opening a refuted path (Approach-5, mutual def, k+2) | H | M (historical) | H6 guardrails make these explicitly forbidden; review rejects any depth-(k+1)/(k+2) appeal |
| Introducing a new axiom or regressing baseline sorries | H | L | `lean_verify` + `grep '^axiom ' Theories/` at every phase boundary; axiom count must stay == 2 |
| n>=2 arm (:394) turns out off-path, wasting effort | M | M | Phase gated on `lean_verify completeness_discrete` showing :394 reachable; skip if dead |
| Dormant VecEA_m wiring drags in new sorries | M | L | Fallback-only; wired sub-lemma must itself be sorry-free before use; otherwise stay on translateEF1 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |
| 6 | 5 | 4 |

Phases are sequential: the gate (0) selects the route; construction phases (1-3) only run if Route A
is retained; the critical-arm clearance (3) gates the off-path arm (4) and the rewire (5). Within
Route B, Phases 1-3 are replaced by the re-anchor execution as noted in Phase 1.

### Phase 0: Decision Gate — Route A (zone-split) vs Route B (re-anchor) [COMPLETED]

> **DECISION (committed): Route A.** G1 re-anchor is non-viable (circular: the Z->discrete bridge
> presupposes `no_gaps_discrete_model_surgery`; structure-type gap `OrderedMonadicStructure`/`temporal_truth`
> vs `IntStructureFromSig`/`int_truth`; no existing bridging lemma). G2: `semantic_prior_UZ` adequate
> (sorry-free `prior_UZ_first_transition` already delivers first-occurrence on `SuccOrder`/`PredOrder`).
> Bonus: only arity n=1 is live; :394 (n+2) is off-path -> Phase 4 verification-only. Evidence:
> handoffs/v35-gate-decision.md. Overturns no prior premise; confirms report 24.

- **Goal:** Settle, with cheap spike work and no large construction, whether
  `completeness_discrete` can be routed through the sorry-free `US_expressively_complete_over_Z`
  (Route B), or whether the bounded zone-split construction is required (Route A). Produce a
  committed, verifiable decision.
- **Tasks:**
  - [ ] **G1 (re-anchor viability):** Read the `completeness_discrete` chain
    (BXCanonical/Completeness.lean:356-357) and `US_expressively_complete_over_Z`
    (ExpressiveCompleteness/Theorem.lean:357). Determine whether the discrete target can be routed
    through the finished Z-proof + a Z->countermodel transfer. Explicitly re-examine report 24's
    "non-viable (HIGH)" verdict against Teammate C's F2 evidence. Use `lean_verify` and a *type-level
    spike only* (state the bridge lemma signature; do NOT prove it).
  - [ ] **G2 (hypothesis faithfulness):** Decide whether `semantic_prior_UZ` ("first occurrence")
    is honestly adequate for the discrete target, or whether the live path must use
    `HasAttainedINF`/infimum (Prop 4.2). Record the answer against the H3 INF anchor.
  - [ ] **Decision criterion (explicit, verifiable):** Choose **Route B (re-anchor)** iff G1 yields
    a *type-checkable* bridge-lemma signature whose only obligations are at depth 0 or reuse
    `US_expressively_complete_over_Z` directly (no depth-(k+1) construction obligation). Otherwise
    choose **Route A (zone-split)**. Tie / ambiguity defaults to **Route A** (bounded, faithful,
    independently corroborated). Record the chosen route, the G1/G2 findings, and which prior premise
    (if any) is overturned in `handoffs/v35-gate-decision.md`.
  - [ ] Commit the gate decision; from here exactly one route is live (H6 guardrail 1).
- **Timing:** 1.5 hours (read + two spikes; no construction)
- **Depends on:** none
- **Files to inspect (read-only spike):** `BXCanonical/Completeness.lean`,
  `ExpressiveCompleteness/Theorem.lean`, `KampPrior.lean`, `PriorDefs.lean`
- **Verification:**
  - `handoffs/v35-gate-decision.md` exists, names exactly one route, states the decision criterion
    outcome and the overturned premise (if any).
  - `lake build` still GREEN; baseline unchanged (2 sorries, 2 axioms); no `.lean` edits committed
    in this phase except removing/replacing stale comments.

> **Branch note:** If Phase 0 selects **Route B**, Phases 1-3 below are REPLACED by a single
> re-anchor execution: state and prove the Z->discrete countermodel bridge, route
> `completeness_discrete` through `US_expressively_complete_over_Z`, and delete the
> Prior/Dedekind framing from the live path. That execution is itself H8-sized (<=500 lines,
> build-GREEN boundary) and feeds directly into Phase 4/5. The phase decomposition below is
> written for **Route A** (the corroborated default); a Route-B selection collapses Wave 3-4 into
> one re-anchor phase with the same verification discipline.

### Phase 1: `mergeNF_succ` — depth-k position merge (x=t zone) [BLOCKED]

> **STRIKE 3 of 3 — CAP REACHED; CONCLUSIVE NEGATIVE** (handoffs/v35-phase-1-strike-3.md).
> The value-duplication route was carried out and yielded a conclusive verdict: **the Phase-1
> leaf `merge_forward_succ` is not a theorem as specified.** Two independent obstructions:
> (1) any renaming-mediated env-congruence bridging the wide (`full_val`) and narrow (`env'`)
> existentials needs BOTH index sections (the merge-roundtrip forces `f∘r=id` AND `r∘f=id`); the
> merge supplies only `r∘f=id` — re-confirming the bijectivity obstruction now at the env level and
> single-directionally, not just the index level. (2) The conclusion's quant `←` direction would
> manufacture a model witness from an ARBITRARY `Bool` quantifier assignment `sub_nf.2`; at depth
> `k+1` (unlike depth 0, which has no quant layer) the forward lemma is FALSE for abstract `sub_nf`
> and demands a quant-merge-compatibility no atom-level `h_pred`/`h_ord` supplies. **Landed
> sorry-free reusable assets**: `totalUnskip`/`totalUnskip_skipFin`, `mergeNF_succ` (the merge
> *definition*) + `mergeNF_succ_atom`, and the full `renameNF` infra — all in the build path, GREEN.
> Per H6 the 3-strike budget is exhausted with a mathematical (not tactical) verdict → **re-run the
> Phase 0 gate** weighing Route A′ (discharge x=t in situ at KampPrior:391 using the model's
> characteristic NF, NOT a standalone forward lemma) vs Route B (re-anchor through
> `US_expressively_complete_over_Z`). Do NOT retry a fourth merge encoding; do NOT reopen Approach-5.
> *(BLOCKED — strike cap; leaf mis-specified; gate re-eval required)*
>
> **STRIKE 2 of 3** (handoffs/v35-phase-1-strike-2.md). The strike-1 retraction-functor plan was
> implemented **in full and proven sorry-free**: `renameNF` (retraction-carrying, with the new
> collision→`false` idea making precomposition total along non-injective maps), `renameNF_roundtrip`,
> and the bidirectional semantic congruence `renameNF_eval_iff` (induction on k). **Conclusive
> negative result**: `renameNF_eval_iff` intrinsically REQUIRES the index maps to be mutually
> inverse (BIJECTIVE — both `f∘r=id` and `r∘f=id`), forced by the contravariant quant layer
> (the recursion swaps `(f,r)`; the `∀ qnf` clauses at differing arities correspond only under a
> bijection). The merge map `skipFin j` is injective-not-surjective (has `r∘f=id` but VIOLATES
> `f∘r=id` at the dropped position j), so the functor is **structurally insufficient for the merge**
> — closing strike-1's open Obstacle 2 as a negative verdict for BOTH syntactic encodings.
> Strike-3 next action: handle the dropped position `j` by the **bespoke value-duplication**
> argument (depth-0 `merge_forward`-style, using `h_pred`/`h_ord` at j) lifted through the quant
> layer, reusing the proven `renameNF_eval_iff` `mpr` direction (needs only `r∘f=id`, which the
> merge has) for the bijection-free half. Proven `renameNF` block saved at
> handoffs/v35-phase-1-strike-2-renameNF-proven.lean.txt. Build GREEN preserved (0 `.lean` changes;
> the proven work is in a `.lean.txt` reference, not the build path). Descend-only respected; no
> forbidden path touched. *(in progress — handoff; 2 of 3 strikes used on this leaf)*
>
> **STRIKE 1 of 3** (handoffs/v35-phase-1-strike-1.md): single-variance `renameNF` along `skipFin j`
> failed to type-check (contravariant quant layer needs a retraction). Superseded by strike 2.

- **Goal:** Generalize `mergeNF` / `merge_forward` (NfDepth0Generalized.lean:157/168) from
  `NormalForm sig 0 (m+1)` to `NormalForm sig k (m+1)`, mapping the quant layer (depth-k) through the
  position drop. This is the x=t zone (collapse `(y,x,t) -> (y,t)`) and the smallest self-contained
  piece. **Make-or-break leaf** (Obstacle 2 + quant-layer commutation).
- **Tasks:**
  - [x] Add `mergeNF_succ` + `merge_forward_succ` (and correctness) BEFORE the recursive
    `nf_nvar_exist_all_depths` (KampPrior.lean:252) or in NfDepth0Generalized.lean. Non-recursive in
    `k`; appeals only to depth-`k` content (descend-only invariant). *(deviation: altered —
    `mergeNF_succ` definition + `mergeNF_succ_atom` + `totalUnskip` landed sorry-free;
    `merge_forward_succ` proven to be a non-theorem as specified, see strike-3 handoff)*
  - [ ] Prove the forward direction maps the quant clause through the merged position.
    *(deviation: BLOCKED — conclusively impossible as a standalone leaf; quant `←` direction is
    false for abstract `sub_nf`, and any renaming bridge needs a bijection the merge lacks)*
  - [x] `lean_verify` the new lemmas are sorry-free. *(landed assets verified: `mergeNF_succ_atom`
    = [propext, Quot.sound])*
- **Timing:** 1.5 hours (~80-150 lines)
- **Depends on:** 0
- **Owner:** lean-implementation-hard-agent (one hole)
- **Files to modify:** `NfDepth0Generalized.lean` (or top of `KampPrior.lean`)
- **Verification:** `lake build` GREEN; `mergeNF_succ`/`merge_forward_succ` sorry-free; baseline
  sorries unchanged at 2 (391/394 still present); axiom count == 2. Three-strikes budget applies.

### Phase 2: Depth-(k+1) future/past zone endpoints [NOT STARTED]

- **Goal:** Build the two strict-order zone arms (`t<x` future via Until; `x<t` past via Since),
  each a one-point formula at `t`, carrying the cross-clause x-t coupling (Obstacle 1) — the
  genuinely new content vs. the depth-0 case (which used a trivial `TemporalPred.top` bracket).
- **Tasks:**
  - [ ] Add `nf_succ_exist_future` / `nf_succ_exist_past` (+ correctness), built from `translateEF1`
    (Prop 3.5) and the in-scope arity-3 IH `nf_nvar_exist_all_depths ... k 2` plus the sorry-free
    `nf_characterizable_temporal_prior` endpoint at depth `k+1`.
  - [ ] Encode the interval bracket carrying the cross-clause coupling (H3: §5 splitting + Prop 3.5).
  - [ ] If the `translateEF1` telescoping resists after the 3-strikes budget on a sub-step, switch
    the strict-zone endpoints to the **bidirectional** `VecEA_m.existClosure` fallback (wire only the
    sorry-free sub-lemma; record the fallback in the dispatch note).
  - [ ] `lean_verify` both endpoints sorry-free.
- **Timing:** 2 hours (~150-250 lines)
- **Depends on:** 1
- **Owner:** lean-implementation-hard-agent (one hole)
- **Files to modify:** `KampPrior.lean` (helpers before line 252), possibly `Translation.lean` usage
- **Verification:** `lake build` GREEN; both endpoint lemmas sorry-free; appeals at depth `<= k`
  only (descend-only check); baseline 391/394 still present; axiom count == 2.

### Phase 3: Assemble 3-way zone match + bind x + wire `| 1` arm (CRITICAL) [NOT STARTED]

- **Goal:** Assemble `A := zoneEqual (x=t) | zoneFuture (t<x) | zonePast (x<t)` as a `match` on
  `sub_nf`'s order booleans (positions 0,1), bind the outer `exists x` via the Fin-2 generalization of
  the in-file Fin-1 bridge, and **replace the `sorry` at KampPrior.lean:391**. This clears the n=1
  critical-path arm.
- **Tasks:**
  - [ ] Assemble the four-arm match mirroring `nf_2var_exist_depth0_tl` (true/true=>bot;
    true/false=>Until via Phase 2; false/true=>Since via Phase 2; false/false=>x=t via Phase 1).
  - [ ] Generalize the Fin-1 telescoping bridge (KampPrior.lean:317-331) to Fin 2 using `insertEnv`
    identities; reduce `exists env:Fin 1` to `exists x`.
  - [ ] Replace `| 1 => sorry` at line 391 with the assembled construction using
    `nf_nvar_exist_all_depths_fn k 2` + `_fn_correct` for the IH.
  - [ ] `lean_verify completeness_discrete` and `lean_verify nf_nvar_exist_all_depths`.
- **Timing:** 2 hours (~120-200 lines)
- **Depends on:** 2
- **Owner:** lean-implementation-hard-agent (one hole)
- **Files to modify:** `KampPrior.lean` (line 391 arm + bridge)
- **Verification:** `lake build` GREEN; KampPrior.lean:391 sorry **removed**; live sorry count drops
  from 2 to 1 (only :394 remains); `lean_verify completeness_discrete` shows the n=1 arm discharged;
  axiom count == 2; no depth-(k+1)/(k+2) appeal introduced.

### Phase 4: Discharge n>=2 arm (:394) IF on the live path [NOT STARTED]

- **Goal:** Eliminate the `sorry` at KampPrior.lean:394 (n>=2) via the n-ary generalization of the
  n=1 binder over `mergeNF_succ`, **only if** `lean_verify` shows :394 reachable from
  `completeness_discrete`.
- **Tasks:**
  - [ ] `lean_verify completeness_discrete` to confirm whether :394 is on the live path. If dead,
    record that and skip the proof (leave as documented off-path sorry, baseline-neutral).
  - [ ] If live: generalize the n=1 result through `mergeNF_succ`'s arity merge to n>=2 and replace
    the sorry.
- **Timing:** 1 hour (~80-150 lines if needed; otherwise verification-only)
- **Depends on:** 3
- **Owner:** lean-implementation-hard-agent (one hole)
- **Files to modify:** `KampPrior.lean` (line 394 arm)
- **Verification:** `lake build` GREEN; either :394 removed (live) or documented dead (off-path);
  axiom count == 2.

### Phase 5: Rewire KampBypass `k>0`, discharge PriorComposition sorry, emit closure notes [NOT STARTED]

- **Goal:** Route KampBypass `k>0` to the single-structure path now that the n=1 critical arm is
  clear, eliminate the PriorComposition sorry (per task description), and emit roadmap-adjacent
  closure outputs. **Only after** Phase 3 (and Phase 4 if live) clears.
- **Tasks:**
  - [ ] Rewire KampBypass `k>0` to the single-structure path produced by Phases 1-3.
  - [ ] Eliminate the PriorComposition `sorry`.
  - [ ] `lean_verify completeness_discrete` shows zero live sorry; run the task-95 `#print axioms`
    audit; confirm axiom count == 2 (no new axioms).
  - [ ] Emit the **task-303 closure note** (305 was the sole sorry blocking `completeness_discrete`).
- **Timing:** 1.5 hours (~100-200 lines)
- **Depends on:** 4
- **Owner:** lean-implementation-hard-agent
- **Files to modify:** KampBypass file, PriorComposition file
- **Verification:** `lake build` GREEN; zero live sorry on `completeness_discrete`;
  `#print axioms completeness_discrete` shows no new axioms (count == 2); task-303 closure note
  written.

## Testing & Validation

- [ ] `lake build` GREEN at every phase boundary (Phases 0-5).
- [ ] `lean_verify completeness_discrete` sorry-inventory recorded at each boundary; trends
  2 -> 1 (after P3) -> 0 (after P5).
- [ ] `grep -c '^axiom ' Theories/**` == 2 (baseline) at every boundary; no new axioms.
- [ ] No `nf_succ_char_formula2` / pair-formula / mutual-def / k+2 construct introduced (H6).
- [ ] Every new helper's IH appeal is at depth `<= k` (descend-only invariant).
- [ ] `handoffs/v35-gate-decision.md` exists and names exactly one live route.
- [ ] `#print axioms completeness_discrete` clean at the end (task-95 audit).

## Artifacts & Outputs

- plans/35_zone-split-gated.md (this file)
- handoffs/v35-gate-decision.md (Phase 0 committed route decision)
- New Lean lemmas: `mergeNF_succ`/`merge_forward_succ` (P1), `nf_succ_exist_future`/`_past` (P2)
- KampPrior.lean:391 sorry removed (P3); :394 removed or documented dead (P4)
- KampBypass rewired + PriorComposition sorry removed (P5)
- summaries/35_zone-split-gated-summary.md (on completion)
- task-303 closure note (P5)

## Rollback/Contingency

- Each phase is additive and build-GREEN at its boundary; revert is `git checkout` of the phase's
  commit. No phase rewrites Preserved Assets.
- If Phase 1 (`mergeNF_succ`) fails after the 3-strikes budget: STOP, write a divergence note, and
  **re-run Phase 0 gate** with the new evidence (do NOT reopen Approach-5). The re-anchor Route B
  remains the documented alternative.
- If the gate (Phase 0) selects Route B: Phases 1-3 collapse into the single re-anchor execution
  (see Phase 0 branch note); Phases 4-5 proceed unchanged.
- Baseline (2 sorries, 2 axioms, build GREEN) is the safe restore point; never commit a state that
  regresses it.
