# Report 03 — Phase-7 Endpoint-Hook Blocker Audit (task 307)

- **Task**: 307 — kamp_cor54_bound_anchor_zone_converter
- **Type**: lean4 (hard-mode blocker audit; H2/H3/H4/H5)
- **Session**: sess_1783353840_ba1b1d
- **Focus**: blocker audit — endpoint-hook construction for A_past/A_future (off-diagonal `x ≠ t`)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 §5)
- **Inputs audited**: `NfZoneFlattenNavigable.lean` (A_past/A_future + `_correct`, trichotomy),
  `NfMultiAnchorBridge.lean` (task-308 deliverables 1/2 + A_diag), `KampPrior.lean:254-354`
  (the `∃ A` binder + `:350`/`:353` obligations), `VecEA_m.lean:245-548` (existClosure family),
  `VecEADecomp.lean:760-810` (depth-0 arity-3 collisions), Rabinovich md:120-173.

## VERDICT: **BINDS** (route (iii): SPAWN a hard-mode prerequisite)

The claimed obstruction is **real and binding**, with a **stronger and more precise** grounding than
the handoff stated. Adversarial refutation (searching `nf_char2_*`, `bracketBuild*`, `existClosure*`,
`exist_tl_fn_k`, `nf_zone_*` across all of `Kamp/`) found **no** existing asset carrying the
off-diagonal `[x, t]` (`x ≠ t`) coupling as a closed endpoint. One **correction** to the handoff's
proposed resolution shape is required (see §2.3 / Contradiction Log): a bare closed
`pastEnd : TemporalPred` is *unsatisfiable* under the current **trivial-top** `A_past`; the spawn must
build the **non-trivial-segment** Rabinovich F_i chain, which entails **revising `A_past`/`A_future`
to take a segment argument** (they cannot stay `BracketFormula.trivial TemporalPred.top`).

## 1. The obstruction, grounded to the actual Lean binder

### 1.1 The decisive fact: `A` is chosen *before* `M` and `t` (model-independence)

`nf_nvar_exist_all_depths` (KampPrior.lean:254-263, `:350` is its `n = 1` arm) has the shape

```
∃ (A : Formula), ∀ (M) (h_UZ) (h_SZ) (t : M.carrier),
   temporal_truth M atomMap t A ↔ ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
```

The witness `A : Formula` is existentially bound **outside** the `∀ M … t`. Therefore `A` — and
every syntactic sub-part used to build it, including any `pastEnd : TemporalPred` fed to `A_past` — is
**model-independent closed syntax**. It **cannot depend on the semantic point `t : M.carrier`**.
(Via `ih_exist_1` + `h_env_eq`, KampPrior.lean:264-290, the RHS rewrites to
`∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` — exactly the LHS of
`nf_zone_exists_trichotomy_k1`, NfZoneFlattenNavigable.lean:188-196.)
[`lean_goal` at `:350` returns empty goals — match-arm/sorry artifact, as report 02 §R-D noted; the
obligation shape is read directly off the binder.]

### 1.2 The trivial-top segment severs the only `(x,t)` channel

`A_past` is defined with a **trivial (top) outer segment** (NfZoneFlattenNavigable.lean:332):

```
A_past pastEnd := bracketBuildLeft (BracketFormula.trivial TemporalPred.top) pastEnd
```

and `A_past_correct` (`:342-354`) discharges its RHS **only** through the hypothesis
`h_past : ∀ x, x < t → (pastEnd.eval_at M atomMap x ↔ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf)`.
By `navigated_bracket_reaches_exterior_past` (`:88-102`) the trivial segment makes `A_past` collapse to
the bare existential `∃ x, x < t ∧ pastEnd.eval_at x` — **no interval-coupling channel between `x` and
`t` survives**. So `h_past` demands a **`t`-independent, model-independent syntactic** `pastEnd`, whose
`.eval_at M atomMap x` (a property of `x` alone, `M`/`atomMap` fixed) equals
`nf_eval_nf M (k+1) 2 [x,t] sub_nf` — which genuinely depends on the **distinct** semantic `t`. For
arbitrary `sub_nf` (the `:350` binder is universal in `sub_nf`, precisely as report 02 §1.1 established
for `:391`) this is impossible: a closed formula at `x` cannot re-identify the specific origin `t`.
**The obstruction binds.** (`A_future`/`h_fut`, `:383-405`, is the exact Until-dual.)

### 1.3 Why the diagonal escaped but the off-diagonal cannot

Task 308's assets all evaluate at the **single collapsed anchor `t`**, or keep `x,t` **explicit**:
`nf_char2_formula_correct` characterizes the **constant env `(fun _=>t)` = `[t,t]`**
(NfMultiAnchorBridge.lean:358-360) — eval at `t`, one anchor; `nf_char2_diag_exist_tl` (`:190`) is the
`x = t` three-zone converter — eval at `t`. On the diagonal the "re-identify `t` from `x`" problem
**vanishes** (`x` *is* `t`). The past/future arms are exactly the arms where `x ≠ t`, so the problem is
unavoidable and no diagonal asset covers them.

## 2. Adversarial refutation attempt (did NOT find a t-coupling asset)

Search targets per mandate: `nf_char2_*`, `bracketBuild*`, `existClosure*`, `exist_tl_fn_k`,
`nf_zone_*`. Every candidate fails to supply a closed off-diagonal `[x,t]` endpoint:

| Candidate asset | Location | Why it does NOT carry off-diagonal `[x,t]` coupling |
|---|---|---|
| `nf_char2_formula` / `_correct` | NfMultiAnchorBridge:327/345 | Diagonal only: `↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf` = `[t,t]`, eval at `t`. |
| `nf_char2_diag_exist_tl` / `_correct` | NfMultiAnchorBridge:190/205 | Diagonal (`x=t`) three-zone converter; eval at `t`; anchor `t` only. |
| `nf_zone_flatten_navigable` / `_brick` | NfMultiAnchorBridge:540/686 | **Prop, not a closed `TemporalPred`**: takes `x t : M.carrier` as *explicit* params; its bounded-interior zone (`:548`) is a **raw** `∃ w, x<w ∧ w<t ∧ nf_eval_nf … (zoneEnv3 w x t) q` still naming `x,t`; its `pastEnd/futureEnd` are hook *parameters* demanding the same coupling one depth down. Never bottoms into a closed endpoint. |
| `exist_tl_fn_k` / `nf_succ_char_formula` | KampPrior:293/107 | **Arity-1** only; single boundary = origin `t`; eval at `t`. No second anchor. |
| `VecEA_m.existClosure(_correct)` | VecEA_m:208/245 | Depth-0 StrictMono existential **closure/navigation**: yields `∃ z, env(last) < z ∧ …`. Navigation machinery (the `bracketBuild` engine), not a two-anchor endpoint. |
| `nf_3var_eq_yt` / `nf_3var_eq_yx` | VecEADecomp:771/798 | Depth-0 arity-3 **equality collisions** (`y=t` / `y=x`) — degenerate point cases, not open-zone off-diagonal `x≠t`. |

**Refutation fails ⇒ the blocker BINDS.** No asset converts `nf_eval_nf M (k+1) 2 [x,t] sub_nf`
(`x ≠ t`) into a closed `TemporalPred.eval_at x` (or any `t`-independent formula at `x`).

### 2.3 Correction to the handoff's resolution shape (H4 self-challenge)

The handoff proposes building "the general-anchor two-anchor navigated characteristic **TemporalPred
endpoint** builder … supplying `pastEnd`/`futureEnd`." §1.2 shows a bare closed `pastEnd : TemporalPred`
is **unsatisfiable** under the *current* trivial-top `A_past`. The correct object is a **non-trivial
segment**: with `A_past := bracketBuildLeft segment endpoint` and `segment ≠ trivial top`,
`bracketBuildLeft_correct` (VecEATranslation:503) gives
`∃ z0 < t, endpoint.eval_at z0 ∧ (segment holds along (z0,t))` — now the `(x,t)` coupling **is** carried
by "`segment` holds along `(x,t)`", a genuinely `t`-anchored condition (the whole formula is evaluated
at origin `t`), and the endpoint at `x` may stay closed. So the deliverable is the **(segment, endpoint)
F_i pair**, and `A_past`/`A_future` **must be revised** to accept a segment. This is the precise Rabinovich
Cor 5.4 realization the trivial-top skeleton discarded (see §3).

## 3. Literature faithfulness (H3 Tier 1 — Rabinovich 2014, Cor 5.4 §5)

Rabinovich Cor 5.4 (md:154-157): `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`;
`[α_0,…,α_n](z_0,z)` holds iff there is an increasing sequence in `(z_0,z_1)` with `F_0(z_0)`. The
**endpoint coupling `z_0 ↔ z_1`** is carried by the **Until nesting through the NON-TRIVIAL segment
types `β_i`**. The current `A_past`/`A_future` use `BracketFormula.trivial TemporalPred.top` — i.e.
`β = True` — which **severs** exactly this coupling. The proposed non-trivial-segment F_i chain **is**
the paper's construction; the trivial-top brackets are a simplification sound **only** when there is no
genuine interval coupling (the diagonal, where the interval collapses to a point). **Faithful.**

**No third anchor / no arity tower.** In the F_i chain the intermediate witnesses (the inner `w`) are
laid as **bracket witnesses** bound by the Until nesting, never as named `nf_eval` env positions; the
top anchor set stays `{x, t}` (arity ≤ 2, Rabinovich Lemma 3.2.2 free-variable cap, md:78). This is the
same distinction upheld in report 02 §2.1 and specs/305 report 40 (projection `VecEA2` / third-free-
anchor tower — refuted). The proposal does **not** smuggle a third anchor.

### H3 Tier-1 mapping table

| Source | Paper/Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (non-trivial segment coupling) | md:154-157 | `bracketBuildLeft` / `_correct`, `bracketBuildRight` / `_correct` | VecEATranslation:503 / :234 (asset, sorry-free) | Available (segment currently forced trivial) |
| Trivial-segment degenerate reach (β = True) | md:154 (point-collapse) | `navigated_bracket_reaches_exterior_past` / `_future` | NfZoneFlattenNavigable:88 / :66 (sorry-free) | Available (diagonal-sound only) |
| Coupled inner `∃ w` five-zone flatten | md:159-171 (Lemma 5.1 case split) | `nf_zone_flatten_navigable(_brick)` | NfMultiAnchorBridge:540 / :686 (sorry-free, hook-parametric) | Available (endpoints are hooks) |
| Diagonal (`x=t`) three-zone converter | md:154 (degenerate interval) | `nf_char2_diag_exist_tl` / `_correct` | NfMultiAnchorBridge:190 / :205 (sorry-free) | Available |
| Diagonal characteristic FORMULA (`[t,t]`) | md:154-157 | `nf_char2_formula` / `_correct` | NfMultiAnchorBridge:327 / :345 (sorry-free) | Available (feeds A_diag) |
| Trichotomy of the `:350` RHS on `t` | md:168-171 (interval split at new point) | `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 (sorry-free) | Available |
| Depth-`k` arity-1 IH (endpoint bottom-out) | — (recursion base) | `nf_nvar_exist_all_depths` / `exist_tl_fn_k` | KampPrior:254 / :293 | Available |
| **Off-diagonal two-anchor navigated characteristic (`x≠t`) — F_i non-trivial-segment chain** | md:154-157 | `nf_char2_past_formula` / `nf_char2_future_formula` (to build) | `NormalForm sig (k+1) 2 → Formula` (proposed) | **Does NOT exist — SPAWN** |
| Arity-1 collapse of the off-diagonal | — | (refuted, report 02 §1) | non-theorem | Refuted (sorry-free, NfDepth0Generalized:1691-1719) |

## 4. Scope of the spawned prerequisite

Same lineage/scale as task 308 (which came in as `nf_char2_formula` + `nf_zone_flatten_navigable`,
5 phases, ~701 lines). Estimated **~400-700 lines, recursion on `k`**. Concrete deliverables:

1. **Segment-carrying outer arms** — revise `A_past`/`A_future` (NfZoneFlattenNavigable:332/383) to
   `A_past seg pastEnd := bracketBuildLeft seg pastEnd` (drop the forced `trivial top`), with `_correct`
   via `bracketBuildLeft_correct`/`bracketBuildRight_correct` directly (not the trivial-top pillars).
   *Consumes:* `bracketBuildLeft/Right_correct`. *Size:* ~80-120 lines (refactor + generalized `_correct`).
2. **`nf_char2_past_formula` / `nf_char2_future_formula`** (`NormalForm sig (k+1) 2 → Formula`) with
   `temporal_truth M atomMap t (nf_char2_past_formula … sub_nf) ↔`
   `∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` (future dual with `t < x`).
   The F_i chain: outer **non-trivial-segment** bracket from `t` to `x`; endpoint at `x` = the arity-2
   characteristic of `sub_nf` at `[x,t]`, whose quant layer (per `qnf : NormalForm sig k 3`) flattens
   via `nf_zone_flatten_navigable_brick`, its residual arity-3 zones discharged by the **depth-`k` IH**.
   *Consumes:* `nf_char2_zone_split5`, `nf_char2_atom_part(_correct)`, `nf_quant_clause_tl`,
   `nf_zone_flatten_navigable_brick`, `exist_tl_fn_k`/`nf_nvar_exist_all_depths`,
   `bracketBuildLeft/Right_correct`. *Size:* ~300-500 lines (the load-bearing new object).
3. **Phase-7 rewire of `KampPrior.lean:350`** — `A := nf_char2_past_formula … ∨ A_diag … ∨
   nf_char2_future_formula …`; prove via `nf_zone_exists_trichotomy_k1` disjunction-elim + the three
   `_correct` lemmas. Replaces the `:350` sorry (live-path sorries 2 → 1). *Size:* ~40-80 lines glue.

**Goal state for the `:350` rewire** (target after spawn lands): produce `A : Formula` with
`temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`, obtained by
`rw [nf_zone_exists_trichotomy_k1]` then three-way `or_congr` discharged by
`nf_char2_past_formula_correct` / `A_diag_correct` / `nf_char2_future_formula_correct`.

**Preserved assets to consume (do NOT rebuild):** all of task 308 (`NfMultiAnchorBridge`) — deliverables
1/2, `A_diag`/`_correct`, `nf_zone_flatten_navigable(_brick)`, `nf_char2_zone_split5`,
`nf_char2_atom_part`, `nf_quant_clause_tl`; the trichotomy `nf_zone_exists_trichotomy_k1`; the depth-0
bases `diagDup`/`diagDup_eval_zero`/`renameNF_eval_diag0`; the navigated pillars (as the *diagonal-only*
degenerate case). The relocation (commit 69998c02d) that broke the import cycle is already landed.

**Obstruction guards (Postmortem forbidden-route list for the spawn):**
- **G1** — no arity-1 collapse of the off-diagonal (refuted, report 02 §1; NfDepth0Generalized:1691-1719).
- **G2** — no projection-based `VecEA2` / third-free-anchor tower (refuted, specs/305 report 40; R2).
- **G3** — no **trivial-top** segment on the off-diagonal arms (this report §1.2/§2.3): the segment MUST
  be non-trivial (Rabinovich `β_i`); a closed `pastEnd` under a trivial segment is unsatisfiable.
- **G4** — `w` stays a **bracket witness** (env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor set
  `{x,t}`; Rabinovich ≤2 cap).
- **G5** — follow Cor 5.4 F_i chains step-by-step; no `simp`/`omega`/`aesop` shortcut of a chain step
  (literature-fidelity policy).

## 5. Route decision

| Option | Assessment |
|---|---|
| (i) inline Phase-7 re-dispatch | **Rejected.** The endpoint interface as typed (closed `pastEnd` under trivial-top `A_past`) is unsatisfiable off-diagonal (§1.2); no asset supplies the coupling (§2). Not a wiring task. |
| (ii) revise the 307 plan only | **Insufficient alone.** The plan does need a note (A_past/A_future gain a segment param), but the missing object is a ~400-700-line recursive construction — that is a prerequisite, not a plan edit. The segment-param revision is folded into the spawn's deliverable 1. |
| **(iii) spawn a hard-mode prerequisite** | **CHOSEN.** Build the off-diagonal two-anchor navigated characteristic (non-trivial-segment F_i chain), §4. Same recurring crux as 305 P11b / 307 P3→308; large, self-contained, reusable. Run `--hard` with H5 churn tracking and G1-G5 as the forbidden-route list. |
| (iv) impossibility → outcome (b) | **Rejected.** No impossibility of `A`'s existence is exhibited — only that the *trivial-top skeleton* is the wrong realization. Research VERDICT (a) stands; the F_i chain is the constructive `A`. |

### Precise spawned-task description (ready for `/spawn 307` / `/task`)

> **Build the off-diagonal two-anchor navigated characteristic (Rabinovich Cor 5.4 non-trivial-segment
> F_i chain) for the `:350` past/future arms.** Off the live import path, sorry-free, axioms exactly
> `[propext, Classical.choice, Quot.sound]`. Deliverables (see report 03 §4): (1) segment-carrying
> `A_past`/`A_future` + `_correct` (drop `trivial top`; via `bracketBuildLeft/Right_correct`);
> (2) `nf_char2_past_formula` / `nf_char2_future_formula : NormalForm sig (k+1) 2 → Formula` with
> `temporal_truth M atomMap t · ↔ ∃ x, x<t (resp. t<x) ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t))
> sub_nf`, the outer non-trivial-segment bracket from `t` to `x` with endpoint = arity-2 char at `[x,t]`,
> quant layer flattened by `nf_zone_flatten_navigable_brick`, residuals by the depth-`k` IH
> (`exist_tl_fn_k`); (3) rewire `KampPrior.lean:350` to `A_past ∨ A_diag ∨ A_future` via
> `nf_zone_exists_trichotomy_k1` + the three `_correct` lemmas (live-path sorries 2 → 1). Consume all of
> task 308 verbatim; preserve `diagDup`/`renameNF_eval_diag0` and the navigated pillars (diagonal case).
> Forbidden routes (G1-G5): no arity-1 collapse; no projection `VecEA2`/third-anchor tower; **no
> trivial-top segment off-diagonal**; `w` a bracket witness (anchor set `{x,t}`); step-by-step Cor 5.4
> (no simp/omega shortcut of a chain step). Estimated ~400-700 lines, recursion on `k`; run `--hard`.

## Adversarial Self-Verification

Claim Verification Bar applied to every load-bearing claim. `Verification Method` uses lean4 domain
values (`source read of binder/signature`, `lean_goal`, `grep-confirmed absence`, `sorry-free asset`).

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `A : Formula` is chosen before `∀ M … t` (model-independent) | KampPrior:254-263 `∃ A, ∀ M h_UZ h_SZ t, …`; `:350` is its `n=1` arm | source read of binder | High |
| `A_past` uses a trivial (top) outer segment | NfZoneFlattenNavigable:332 `bracketBuildLeft (BracketFormula.trivial TemporalPred.top) pastEnd` | source read | High |
| `h_past` demands a `t`-independent formula at `x` equal to a `t`-dependent target | NfZoneFlattenNavigable:347-349 (`h_past`) + :350-351 target `nf_eval_nf … [x,t] sub_nf` | source read of hypothesis + goal | High |
| No existing asset carries off-diagonal `[x,t]` coupling as a closed endpoint | §2 table: all of `nf_char2_*` diagonal/eval-at-`t`; `nf_zone_flatten_navigable` keeps `x,t` explicit (`:548` raw `∃w`); arity-1 IH single-anchor; existClosure = navigation; VecEADecomp = collisions | grep across `Kamp/*.lean` + source read of each signature | High |
| `nf_char2_formula` is diagonal-only (`[t,t]`) | NfMultiAnchorBridge:358-360 `↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf` | source read | High |
| `nf_zone_flatten_navigable` is a Prop with explicit `x t`, not a closed `TemporalPred` | NfMultiAnchorBridge:540-551 (`x t : M.carrier` params; `:548` raw interior `∃w`) | source read of def | High |
| Trivial-top = Rabinovich `β = True`; coupling needs non-trivial `β_i` | Rabinovich md:154-157 (`F_{i-1}:=α_{i-1}∧(β_i Until F_i)`) vs NfZoneFlattenNavigable:332 | source read + literature | High |
| Proposal does not add a third anchor / arity tower | `w` bracket witness, anchor set `{x,t}`, ≤2 cap (md:78); report 02 §2.1 | literature + source read | High |
| Live-path sorries are exactly `:350`,`:353`; assets off-path sorry-free | grep: KampPrior sorries only at `:350`/`:353`; NfMultiAnchorBridge/NfZoneFlattenNavigable "sorry" only in docstrings | grep-confirmed | High |
| A closed `pastEnd` becomes satisfiable under a **non-trivial** segment | `bracketBuildLeft_correct` (VecEATranslation:503): `∃ z0<t, end.eval z0 ∧ seg holds (z0,t)` | source read of `_correct` + deduction | Medium-High |
| Estimated ~400-700 lines | Parity with task 308 (701 lines, 5 phases); same crux family | analogy to shipped 308 | Medium |

**Contradiction Log.**
- *Handoff resolution ("supply a `TemporalPred` endpoint `pastEnd`/`futureEnd`") vs. §1.2 (a closed
  endpoint under trivial-top is unsatisfiable).* **Resolved** by precedence "actual Lean binder + asset
  types > handoff prose": the handoff correctly identifies the *missing coupling* and the F_i-chain
  remedy, but under-specifies the interface — the segment must be non-trivial and `A_past`/`A_future`
  must be revised to accept it. No contradiction on the VERDICT (both agree: BINDS, spawn the F_i chain);
  the correction is folded into spawn deliverable 1 (§4) and guard G3.
- *This report's BINDS vs. research VERDICT (a) (a uniform navigable `A` exists).* **Resolved** (as in
  report 02): BINDS refutes a *realization shape* (trivial-top skeleton), not the *existence* of `A`.
  The non-trivial-segment F_i chain is the constructive `A`. Route (iv)/outcome (b) correctly rejected.

**Forbidden-output check.** No "mathlib likely has this" claim (codebase-internal construction); no
sorry-deferral or axiom introduction recommended; the spawn deliverable is a concrete sorry-free
obligation with axioms pinned to `[propext, Classical.choice, Quot.sound]`.

**Recommendations modified after verification.** The handoff's "closed `pastEnd`/`futureEnd`" interface
is corrected to a **(non-trivial segment, endpoint) pair** requiring an `A_past`/`A_future` revision
(§2.3, guard G3) — not carried forward as-is.

## Key Risks

- **R-A (Medium-High):** This is the same crux lineage that 305 P11b and 307 P3 (→308) circled; three
  routes already refuted (projection `VecEA2`; atomic D1; arity-1 collapse) — now a fourth interface
  trap (trivial-top endpoint). *Mitigation:* spawn `--hard` with H5 churn tracking; encode G1-G5.
- **R-B (Medium):** ~400-700 lines may exceed one dispatch. *Mitigation:* phase-decompose (segment-arms
  refactor → `nf_char2_past_formula` past → future dual → `:350` rewire).
- **R-C (Low):** `A_past`/`A_future` revision touches task-307-landed defs. *Mitigation:* the spawn owns
  those files; the trivial-top pillars stay as the diagonal-case lemmas (`nf_char2_diag_exist_tl` still
  uses them correctly at `x=t`).
