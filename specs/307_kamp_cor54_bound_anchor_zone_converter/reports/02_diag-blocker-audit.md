# Report 02 — Phase-3 Diagonal Blocker Audit (task 307)

- **Task**: 307 — kamp_cor54_bound_anchor_zone_converter
- **Type**: lean4 (hard-mode blocker research; H2/H3/H4/H5)
- **Session**: sess_1783342946_dfd523
- **Focus**: blocker research — verify Phase-3 refutation and produce corrected route
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 §5)
- **Inputs audited**: `NfZoneFlattenNavigable.lean` (Phase-3 scaffolding + OBSTRUCTION note),
  `NfDepth0Generalized.lean:1646-1719`, `KampPrior.lean:256-394`, `NfZoneDepthK.lean:75-160,432-546`,
  `plans/01_bound-anchor-converter.md` Phase 3, Rabinovich md:120-169.

## Executive Verdict

- **Refutation verdict: BINDS at `:391`.** The arity-1-collapse route for the A_diag arm
  (`A_diag := char_k1 (diagCollapse sub_nf)`) is a genuine non-theorem, and it binds the *actual*
  `:391` obligation — because `sub_nf` there is **universally quantified**, not a pipeline-specific
  normal form. The mandate's escape hatch ("sub_nf may have exploitable structure at :391") is
  **closed**: there is no exploitable structure to use.
- **Chosen route: (iii) spawn a prerequisite task.** The missing object — a depth-graded
  **multi-anchor characteristic FORMULA builder** (the "multi-anchor bracket bridge" / task-305
  "Phase-11 crux") — is load-bearing not only for Phase 3 but for the *entire* construction
  (Phases 3, 4, 5, 6 all depend on it). It is ~400–700 lines by the codebase's own scoping,
  exceeds task 307's per-phase envelope, and is the same crux task 305's Phase-11b lineage has
  been circling. It is **not** the arity-tower obstruction and does **not** contradict VERDICT (a).

## 1. Does the refutation BIND at the real `:391` obligation?

### 1.1 `sub_nf` at `:391` is arbitrary (decisive)

The theorem being proved (`nf_nvar_exist_all_depths`, KampPrior.lean:254-263) has signature:

```
(k : Nat) → (n : Nat) → (sub_nf : NormalForm sig k (n + 1)) →
  ∃ (A : Formula), ∀ M h_UZ h_SZ t,
    temporal_truth M atomMap t A ↔
    ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf
```

The `:391` obligation is the arm `| k + 1, n, sub_nf =>` with `match n with | 1 => sorry`. Here
`sub_nf : NormalForm sig (k+1) 2` is a **bound parameter of the recursive definition** — the
theorem asserts a converter `A` exists for *every* such `sub_nf`. There is no translation-pipeline
value plugged in at `:391`; the obligation is genuinely "for arbitrary `sub_nf`".

**Consequence for the mandate's point 1.** The suggested repair ("restrict to diagonal-invariant
`sub_nf` reachable at :391, using the specific sub_nf shape") is unavailable: `sub_nf` is quantified
over *all* of `NormalForm sig (k+1) 2`, including the exact non-diagonal-invariant witnesses the
refutation uses. The refutation's "arbitrary sub_nf" hypothesis **is** the `:391` hypothesis.

### 1.2 The arity-1-collapse route is a genuine non-theorem (independently corroborated)

The Phase-3 route wanted `temporal_truth M t (char_k1 (diagCollapse sub_nf)) ↔ nf_eval_nf M (k+1) 2
[t,t] sub_nf`. By `char_k1_correct` this reduces to
`nf_eval_nf M (k+1) 1 (fun _=>t) (diagCollapse sub_nf) ↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf` —
i.e. the depth-`(k+1)` lift of the depth-0 base `diagDup_eval_zero`.

That lift is **already documented sorry-free as a non-theorem** at
`NfDepth0Generalized.lean:1691-1719` ("Depth lift of the diagonal congruence is BLOCKED at the
quant layer"). Its `←` direction fails because `liftIdx r` (`liftIdx (totalUnskip …)`) is
**non-injective**: a `sub_a` that is not diagonal-invariant is unrealizable on the diagonal env
`Fin.cons x E` (its `∃x …` is false), yet `nq` of its collapse can be true. This is *precisely* the
counterexample the Phase-3 OBSTRUCTION note re-derives for the constant env `[x,t,t]` (a `sub_a`
demanding `order 1 2`, i.e. `t < t`, false at every `x`; its collapse can still be realizable). The
refutation is therefore not a fresh conjecture — it instantiates an established, independently
sorry-free obstruction. **The refutation is sound.**

**Verdict: BINDS.** No arity-1-collapse repair of Phase 3 exists.

## 2. Is the proposed `nf_char2_formula` route legitimate, and how big?

### 2.1 It is NOT the arity-tower obstruction (R2)

R2 forbids "encoding a characteristic-type condition on a **third free anchor** at a single
navigable point" (naming/projecting a third anchor). The diagonal disjunct is
`nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf` — a condition on the **single** point `t` (both arity-2
anchor positions collapse onto `t`). Free-anchor count at the top is **1** (`t`), within
Rabinovich's ≤2 free-variable cap (Lemma 3.2.2, md:78). The deeper arity-3 quant layer
`∃ w, nf_eval M k 3 [w,t,t] q` binds `w` as a **navigated bracket witness** (Rabinovich Cor 5.4
`F_i` chain, md:154-157), never as a named env position. So `nf_char2_formula` is the two-endpoints-
collapsing-to-`t` case, *legitimate* — not the tower in disguise.

### 2.2 It is the recurring "multi-anchor bracket bridge" crux, and it is large

`nf_succ_char_formula` (arity-1, KampPrior.lean:107-118) is compact **only because** the quant layer
of a depth-`(k+1)` arity-1 NF is a *single-anchor* existential `∃x, nf_eval M k 2 [x,t] sub` — exactly
what the IH `exist_tl_fn`/`ih_exist_1` delivers. The arity-2 analog's quant layer is a **two-anchor
bounded** existential `∃w, nf_eval M k 3 [w,a,b] sub`, which the single-anchor IH engine
(`nf_nvar_exist_all_depths_fn`) cannot supply directly. This gap is stated verbatim in
`NfZoneDepthK.lean:118-143`: bridging single-anchor IH → multi-anchor bounded zone "is exactly the
`bracketBuildLeft`/`bracketBuildRight` assembly whose endpoint/segment `TemporalPred`s must
themselves encode `char[·] = qnf` via `nf_char3_eq_succ_iff` + `nf_characteristic_quant_split3` —
recursively, one depth down ... the honest unit of remaining work is the whole nested (outer-`y` /
inner-`w`) bracket-assembly body (Rabinovich Cor 5.4 `F_i` chain, ~400-700 lines)."

The split-level foundations already exist sorry-free (verified: `nf_char3_eq_succ_iff`,
`nf_characteristic_quant_split3` are theorems in NfZoneDepthK.lean). What is missing is the
**bracket-assembly body** that turns each open zone into a temporal formula. Even a diagonal-only
`nf_char2_formula` needs this recursive bridge (the diagonal env collapses the seven `w`-zones to
three but each zone still encodes a depth-`(k-1)` diagonal characteristic — the same machinery, one
depth down), so a narrow in-task version does **not** materially shrink the work.

### 2.3 The whole construction (Phases 3-6), not just Phase 3, depends on it

- Phase 4 (`nf_zone_flatten_navigable`): its endpoint `TemporalPred` at the navigated `w` must
  encode `nf_eval M k 3 [w,x,t] q` relative to anchors `(x,t)` — a depth-`k` multi-anchor
  characteristic. Same bridge.
- Phases 5/6 (`A_past`/`A_future`): built as `bracketBuild*` over the Phase-4 flattened endpoint —
  transitively the same bridge.

So task 307 is **entirely** blocked on this object: no arm (diagonal, past, or future) closes
without it. That is the signature of a *prerequisite*, not an in-task phase.

## 3. Route Decision

| Option | Assessment |
|--------|-----------|
| (i) repair Phase 3 in current plan | **Rejected.** Refutation binds; no arity-1-collapse repair exists (§1). |
| (ii) insert `nf_char2_formula` phases in-task | **Rejected.** The honest unit is the ~400-700-line multi-anchor bracket bridge; even a diagonal-only version needs the full recursive bridge (§2.2). Inserting it balloons task 307 past its 8-phase / 14-20h envelope and duplicates task 305's Phase-11b crux. |
| **(iii) spawn a prerequisite task** | **CHOSEN.** Task 307 is wholly blocked on the multi-anchor characteristic bridge; it is a large, self-contained, reusable object consumed by task-307 Phases 3/4/5/6 and by task-305 Phase 11b. Build once as a shared prerequisite. |
| (iv) global obstruction → outcome (b) | **Rejected.** No impossibility is exhibited — only mis-scoping. VERDICT (a) holds; the bridge is the constructive realization of `A`. Routing to (b) would contradict the still-valid research verdict without positive impossibility evidence (plan Rollback §Contingency demands such evidence). |

### Precise spawned-task description (for `/spawn 307`)

> **Build the depth-graded multi-anchor characteristic FORMULA builder (multi-anchor bracket
> bridge).** Off the live import path, sorry-free, axioms exactly `[propext, Classical.choice,
> Quot.sound]`. Deliverables:
> 1. `nf_char2_formula : NormalForm sig (k+1) 2 → Formula` with
>    `temporal_truth M atomMap t (nf_char2_formula sub_nf) ↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`
>    (diagonal/constant two-anchor env) — the analog of `nf_succ_char_formula` (arity-1), consuming
>    `nf_char3_eq_succ_iff` and `nf_characteristic_quant_split3` (both sorry-free in NfZoneDepthK.lean)
>    for the arity-3 quant layer, `renameNF_eval_diag0` for the diagonal depth-0 base, and
>    `bracketBuildLeft`/`bracketBuildRight` (+ `_correct`) for the `w`-zone navigation.
> 2. The general navigated bounded-existential corollary
>    (`nf_zone_flatten_navigable` at arbitrary depth `k`): `∃w, nf_eval M k 3 [w,x,t] q ↔`
>    `bracketBuild` disjunction over `w`'s zones relative to `(x,t)`, each depth-`k` residual
>    discharged by the IH, endpoints NAVIGATED, `w` a bracket witness (env arity never grows past
>    the `{w,x,t}=3 → {x,t}=2` reduction; anchor set stays `{x,t}`; R2 constraint).
> Both unblock task-307 Phases 3 (via 1) and 4/5/6 (via 2), and directly supply task-305's Phase-11b
> multi-anchor bracket bridge. Estimated ~400-700 lines; recursion on depth `k`. Constraints:
> follow Rabinovich Cor 5.4 `F_i` chains step-by-step (no simp/omega shortcut of a chain step); no
> projection-based `VecEA2` (refuted, Obstruction 1); no arity-1 collapse for the diagonal
> (refuted, this report §1). Preserve all task-307 assets; reuse the landed `diagDup` /
> `diagDup_eval_zero` (depth-0 duplication base) verbatim.

## 4. Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

| Source | Paper/Location | Lean Identifier | Type Signature (verified) | Status |
|--------|----------------|-----------------|---------------------------|--------|
| Cor 5.4 `F_n:=α_n`, `F_{i-1}:=α_{i-1}∧(β_i Until F_i)` | md:154-157 | `bracketBuildRight` / `_correct`, `bracketBuildLeft` / `_correct` | VecEATranslation.lean:50/234 (asset, sorry-free) | Available |
| Coupled quant layer `∃w, nf_eval M k (n+1) [w,env] sub` | md:154-157 | `nf_characteristic_quant_succ` | `NfZoneDepthK.lean:432` theorem | Available (sorry-free) |
| Inner `w`-zone split (7 zones at `y,x,t`) | md:159-169 (Lemma 5.1 case decomposition) | `nf_characteristic_quant_split3` | `NfZoneDepthK.lean:514` theorem | Verified (lean_local_search hit) |
| Full `char[y,x,t]=qnf` decomposition | md:159-169 | `nf_char3_eq_succ_iff` | `NfZoneDepthK.lean:537` theorem | Verified (lean_local_search hit) |
| Diagonal (endpoint collision) depth-0 base | md:154 (single-point degenerate) | `renameNF_eval_diag0` | `NfDepth0Generalized.lean:1646` theorem | Available (sorry-free) |
| Arity-1 characteristic (template for arity-2) | — (Lean scaffolding) | `nf_succ_char_formula` / `_correct` | `KampPrior.lean:107/121` | Available (template) |
| **Two-anchor characteristic builder (MISSING)** | md:154-157 (Cor 5.4 nested chain) | `nf_char2_formula` (to build) | `NormalForm sig (k+1) 2 → Formula` (proposed) | **Does not exist — spawn** |
| Depth-lift of diagonal congruence | — | (refuted) | non-theorem, `NfDepth0Generalized.lean:1691-1719` | Refuted (sorry-free) |

## Adversarial Self-Verification

Applied the Claim Verification Bar to every load-bearing claim. `Verification Method` uses the
lean4 domain values (`lean_local_search hit`, `source read of signature`, `sorry-free asset`).

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| `sub_nf` at `:391` is universally quantified (arbitrary), not pipeline-specific | KampPrior.lean:256 `(sub_nf : NormalForm sig k (n+1)) → ∃ A, …`; `:391` is match arm `k+1,1,sub_nf` | source read of theorem signature | High |
| Arity-1-collapse iff reduces to the depth-lift of `diagDup_eval_zero` | `char_k1_correct` (KampPrior.lean:350) + `diagDup_eval_zero` (NfZoneFlattenNavigable.lean:243) | source read | High |
| That depth-lift is a genuine non-theorem (← fails, non-injective `liftIdx r`) | NfDepth0Generalized.lean:1707-1713 (sorry-free documented crux); Phase-3 counterexample `order 1 2` at `[x,t,t]` | source read of sorry-free asset | High |
| Refutation therefore BINDS at `:391` | Combination of the above two: arbitrary `sub_nf` includes the counterexample witnesses | deductive from verified claims | High |
| `nf_char2_formula` is NOT the R2 arity-tower | free-anchor count = 1 (`t`); `w` bound as navigated bracket witness; Rabinovich ≤2 cap (md:78) | source read + Rabinovich md:78,154-157 | High |
| The missing brick is the multi-anchor bracket bridge, load-bearing for Phases 3-6 | NfZoneDepthK.lean:118-143 (verbatim gap statement); Phase-4/5/6 endpoint analysis | source read | High |
| Foundation assets for the spawn exist sorry-free | `nf_char3_eq_succ_iff`, `nf_characteristic_quant_split3` | lean_local_search hit (both theorems in NfZoneDepthK.lean) | High |
| Estimated size ~400-700 lines | NfZoneDepthK.lean:131-132 self-scoping | source read (codebase's own estimate) | Medium |
| Route (ii) narrow diagonal-only version does not shrink the work | Diagonal env still recurses through the depth-`(k-1)` diagonal characteristic bridge (§2.2) | deductive analysis | Medium |
| Does NOT contradict VERDICT (a) | plan §Design-Decisions-Settled; refutation kills a shortcut, not existence | source read of plan + logical analysis | High |

**Contradiction Log:** The refutation's phrasing ("Does NOT contradict VERDICT (a)") vs. the plan's
Rollback note ("outcome (b) would contradict research VERDICT (a) ... deemed unprovable because
false") — *resolved*, no contradiction. The refutation refutes a **construction route** (arity-1
collapse), not the **existence** of `A`. VERDICT (a) (existence) stands; only the plan's *phase
decomposition* was mis-scoped. Route (iv)/outcome (b) is correctly rejected.

**Forbidden-output check:** No "mathlib likely has this" style claim was made (this is a
codebase-internal construction, not a Mathlib lookup); no sorry-deferral or axiom introduction is
recommended; the spawned-task deliverable is a concrete sorry-free obligation.

**Recommendations modified after verification:** The mandate hypothesized an escape via `sub_nf`
structure at `:391`; verification (§1.1) closed it — that hypothesis is explicitly refuted, not
carried forward as a live repair option.

## Key Risks

- **R-A (Medium):** The spawned bridge is the same object task-305 Phase-11b has repeatedly failed
  to land; three prior refutations (projection `VecEA2`; atomic-bracket D1; arity-1 collapse) circled
  it. *Mitigation:* the spawn must run **hard-mode** (`--hard`) with H5 churn tracking; the three
  refuted routes are Postmortem-forbidden and must be encoded as its "Do NOT" list.
- **R-B (Low-Medium):** Size (~400-700 lines) may exceed one dispatch. *Mitigation:* the spawned
  task should itself phase-decompose (diagonal `nf_char2_formula` first — smallest, unblocks Phase 3
  — then the general navigated bridge).
- **R-C (Low):** Coupling to task 305. The bridge is task-305's crux; building it under task 307
  should hand back consumption notes so task 305 rewire reuses it rather than rebuilding.
- **R-D (Low):** `lean_goal` at `:391` returned empty goals (match-arm/sorry position artifact);
  the obligation shape was instead confirmed by direct source read of the theorem signature — no
  impact on the verdict.
