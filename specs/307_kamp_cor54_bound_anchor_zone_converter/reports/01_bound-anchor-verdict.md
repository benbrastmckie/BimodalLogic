# Report 01 — Bound-Anchor Zone Converter: Research Verdict (Kamp Cor 5.4, `:391`)

- **Task**: 307 (kamp_cor54_bound_anchor_zone_converter, lean4)
- **Type**: Research / decisive go-no-go verdict (H2 anti-analysis, H3 Tier-1 literature grounding, H4 adversarial verification, H5 divergence-aware). No `.lean` files edited.
- **Session**: sess_1783342946_dfd523
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014 "A Proof of Kamp's Theorem", `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`)
- **Residual of**: task 305 Phase 16 GO/NO-GO gate (NO-GO, free-anchor case) — plan v40.

---

## Executive Verdict

**OUTCOME (a): a uniform (model-independent) navigable Formula `A` EXISTS for the bound-anchor case at `KampPrior.lean:391`. The Phase-16 free-anchor obstruction does NOT recur under existential binding. Outcome (b) — "no such uniform navigable `A` exists" — is not merely unproven but *unprovable*, because it is false.**

Three independent grounds converge on (a):

1. **The codebase already performs bound-anchor existential closure one depth down.** The in-scope induction hypothesis `exist_tl_fn_k` (`KampPrior.lean:334-344`) realizes exactly `∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _=>t)) sub'` as a temporal formula. `:391` is the **depth-lift** of this same shape (k → k+1), i.e. an induction *step*, not a new impossibility. If the free-anchor obstruction blocked bound-anchor closure, this IH could not exist — yet it is present and correct (`choose`/`choose_spec`).

2. **The Phase-16 refutation's load-bearing lemma is vacuous under binding.** `no_x_independent_formula_captures_future_zone_k1` (`NfZoneNavProbe.lean:165`) is built on `gate_forces_x_independence` (`:136`), whose hypothesis is `∀ x, x < t → (temporal_truth t A ↔ ∃ y, t<y ∧ nf_eval M 1 3 (zoneEnv3 y x t) qnf)` — it **quantifies over a free anchor `x`** and derives a contradiction from `A` being unable to see it. The bound-anchor gate `temporal_truth t A ↔ ∃ x, nf_eval M (k+1) 2 [x,t] sub` has **no free `x`**; the `∀ x` premise cannot even be stated, so the pillar is inapplicable. Concretely, in the *very* counterexample model where the free-anchor gate fails, the bound RHS is simply `True` (the realizing anchor `x₁` witnesses `∃x`), and `A ≡ ⊤` satisfies the bound gate there — **no contradiction can be manufactured**. No bound-anchor analog of the refutation can be proven.

3. **Kamp's theorem guarantees the mathematical object exists.** `∃ x, nf_eval_nf M (k+1) 2 [x,t] sub` is a monadic first-order condition on the single free point `t`. Over Dedekind-complete linear orders — which Prior structures satisfying `semantic_prior_UZ` are, via `prior_hasAttainedINF` (`PriorINF.lean:224`) supplying INF/infimum attainment — `Until`/`Since` are expressively complete (Kamp 1968; Rabinovich 2014 §5). Hence a `U/S` formula capturing this condition provably exists. The `:391` `sorry` is an artifact of the chosen NF-encoding recursion, **not** evidence of non-existence.

**Why the four prior refutations do not settle (b).** Every proven obstruction targets the construction class *"keep exactly 2 anchors and absorb the deeper witness as a single-point / atomic type that must NAME or PROJECT a third anchor."* The bound-anchor construction is categorically different: it **navigates** to each bound witness and lays a **chain** (Rabinovich's `F_i` nesting), where each link's type references only its two neighbours and the chain structure — not a named third anchor — encodes the coupling. The refutations are of the wrong construction class (see §3).

**Decisiveness / non-deferral.** The research question ("does `A` exist / does the obstruction recur?") is answered decisively: **A exists; the obstruction does not recur.** The remaining difficulty is purely *constructive engineering* (building the depth-graded flattening brick), not a mathematical obstruction — and it is explicitly scoped in §4, not deferred.

---

## 1. The exact `:391` obligation (goal shape, read from source)

`nf_nvar_exist_all_depths` (`KampPrior.lean:255-263`) returns, for the `k+1`, `n=1` arm:

```
∃ (A : Formula), ∀ (M) (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap) (t : M.carrier),
    temporal_truth M atomMap t A ↔
      ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
```

which (via `insertEnv env t = Fin.cons (env 0) (fun _=>t)`, the identity proved at `:317-331`) is exactly the task's

```
temporal_truth M atomMap t A  ↔  ∃ x : M.carrier, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf
```

`sub_nf : NormalForm sig (k+1) 2` (depth `k+1`, arity 2). The `x` is **existentially bound** (position-0 anchor of a 2-anchor NF), and `t` is the fixed evaluation origin. Unfolding one quant layer (`nf_eval_nf` succ-case):

```
∃ x, nf_eval M (k+1) 2 [x,t] sub_nf
  = ∃ x, ( atom_layer[x,t]  ∧  ∃ w, nf_eval M k 3 [w,x,t] sub_nf.quant )
```

Both `x` and `w` are bound. The depth-`k` arity-3 core `nf_eval M k 3 [w,x,t]` is **structurally identical** to the free-anchor probe's RHS `nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` (`NfZoneNavProbe.lean:107`) — but there `x` was **free**; here both `w` and `x` are **bound**. That single difference is the whole verdict.

*(The `lean_goal` MCP returns an empty goal at the bare `sorry` term-position, as expected for a term-mode `match` arm; the obligation is the arm's expected type quoted above, read directly from the `def` signature `:257-263` and the `n=1` comment `:388`.)*

---

## 2. The three proven obstructions vs. the bound anchor (non-transfer analysis)

| # | Proven obstruction | What it refutes | Transfers to bound `∃x`? | Why / why not |
|---|--------------------|-----------------|--------------------------|---------------|
| 1 | **Projection VecEA2 non-injectivity** (`NfZoneDepthK.lean`, Phase 10; `liftIdx(totalUnskip)` non-injective) | Per-variable *projection* of the coupled quant layer for the `x=t` diagonal | **No** | Concerns **projection/factorization**, not existence. The `x=t` diagonal contributes ONE disjunct handled by `renameNF_eval_diag0` (`NfDepth0Generalized.lean:1646`) + `char_k1`; the bound construction never projects. |
| 2 | **D1 flat-bracket interior confinement** (`interior_bracket_cannot_realize_exterior_sub_k1`, `NfZoneDepthK1Probe.lean:49`) | A **depth-0 ATOMIC** `(x,t)`-bracket capturing exterior-`w` (`w<x`, `t<w`) realizability | **No (refutes the wrong endpoint type)** | Refutes only **atomic, non-navigating** types (`temporal_truth` on `.atom`/`.box` is purely local, no `Until`/`Since`). The bound construction uses **navigated** `bracketBuildLeft`/`Right` types that DO reach exterior `w`. D1 kills the atomic simplification, not navigation. |
| 3 | **Phase-16 free-anchor identification** (`no_x_independent_formula_captures_future_zone_k1`, `NfZoneNavProbe.lean:165`) | A model-independent `A` at `t` capturing `∃y,t<y ∧ nf_eval M 1 3 [y,x,t] qnf` for a **FREE** anchor `x` | **No (vacuous under binding)** | Load-bearing lemma `gate_forces_x_independence` (`:136`) requires the `∀ x, x<t → …` free-anchor gate. The bound gate has no free `x`; the premise is unstatable. In the free-anchor counterexample model the bound RHS is `True` and `A≡⊤` works — no contradiction exists. |

**Net.** None of the three obstructions blocks the **navigable, existentially-bound** construction. Obstructions 1–3 collectively establish a robust wall for the class *"2 anchors + single-point/atomic type that names or projects a third anchor"* — a wall the bound construction does not touch because it uses a **navigated chain of bound witnesses** (§3).

---

## 3. Why the bound case is genuinely different — and constructible (outcome (a))

Rabinovich's Cor 5.4 (`md:154-157`) builds `∃ x_0<…<x_n in (z_0,z_1) with types α_j,β_j` via the chain

```
F_n := α_n ,    F_{i-1} := α_{i-1} ∧ (β_i Until F_i)
```

The nesting **is** the sequence of bound witnesses; each `F_i` link references only its immediate successor via `Until`/`Since`, and coupling to the interval endpoints is carried by the chain *structure*, not by naming a third point. Free variables stay `≤ 2` (Lemma 3.2.2, `md:78`); deeper quantifier structure is absorbed as **additional bracket witnesses in one interval**, never as new anchors (the KEY ARCHITECTURAL FACT in the task brief).

This is precisely what existential binding unlocks and free exposure forbids:

- **Free anchor `x`** (Phase-16): the gate must hold for *every* `x`, so `A` would have to *name* a specific `x` — impossible for a single-point endpoint (`ExistsForallNF.lean:49-56`). Obstruction #3.
- **Bound anchor `x`** (this task): we get to *quantify* over `x`. Navigation "`∃` a past/future point of type τ such that …" is exactly a `bracketBuild` chain link. The witness is **laid down**, not **named**. Rabinovich's `F_i` chain applies.

### 3.1 The construction `A` (decomposition for the implementer)

Split `∃x` by the position of the bound anchor relative to `t` (the single free anchor), then apply the chain per zone:

```
A  :=  A_past  ∨  A_diag  ∨  A_future
```

- **`A_diag` (x = t)** — `nf_eval M (k+1) 2 [t,t] sub_nf`. Value-duplication collapses arity 2 → 1: `renameNF_eval_diag0` (depth-0 base) composed with `char_k1` (`KampPrior.lean:347`, `char_k1_correct :350`). **Assets only, no new math.**
- **`A_past` (x < t)** — `bracketBuildLeft` (`VecEATranslation.lean:50`, `_correct`): a `Since` chain from `t` reaching the bound witness `x`, whose endpoint type is the depth-`(k+1)` arity-2 type of `[x,t]` **after flattening its one extra quant layer** `∃w, nf_eval M k 3 [w,x,t]` into navigated bracket witnesses on the `(x,t)` interval and its exterior segments (via nested `bracketBuildLeft`/`Right` from `x`), with the depth-`k` residual discharged by the **IH** `exist_tl_fn_k` (`:334`, `exist_tl_fn_k_correct :337`).
- **`A_future` (t < x)** — dual of `A_past` with `bracketBuildRight` (`Until` chain).

### 3.2 The iff lemma decomposition

1. **x-trichotomy split** of the RHS existential (past / diagonal / future) — the single-anchor analog of `nf_zone_exists_partition5` (`NfZoneDepthK.lean`), a routine unconditional split. *[asset-shaped]*
2. **Diagonal arm**: `renameNF_eval_diag0` + `char_k1_correct`. *[assets]*
3. **Past/future arms**: `bracketBuildLeft_correct` / `bracketBuildRight_correct` with the flattened navigable endpoint; residual depth-`k` closure by `exist_tl_fn_k_correct` (the IH). *[assets + one new brick]*
4. **The one new brick — depth-graded navigable flattening** (`nf_zone_flatten_navigable_k1`, generalising by induction on `k`): for the coupled core `∃w, nf_eval M k 3 [w,x,t] q`, an equivalence to a `bracketBuild` disjunction over `w`'s zones whose endpoint types are **depth-graded / navigated (NOT atomic)** — the corrected sibling of the refuted D1. Report 40 §3.2 sized the depth-induction (D2) at ~300–450 lines. This is the load-bearing constructive obligation and the recommended first implementation gate.

Correctness of the packaged iff then follows by disjunction elimination over the trichotomy, each arm discharged by 2–4.

---

## 4. Risk register (honest, for the planner)

- **R1 — the flattening brick is un-built (medium-high).** Step 4 (`nf_zone_flatten_navigable_k1`, depth-graded) is the only genuinely new mathematics. D1 refuted its *atomic* simplification (interior confinement); the *navigated* version is not refuted but is **unverified**. Mitigation: begin implementation with a **depth-graded flattening probe at `k=1` with navigated endpoint types** as a GO/NO-GO gate — categorically distinct from the already-run atomic D1 (which used purely-local `.atom`/`.box` types). A NO-GO here (navigation still cannot express the coupling) would be the *first* evidence toward an obstruction — but it has not been produced, and Kamp's theorem argues it will not be.
- **R2 — arity-tower temptation (medium).** The naive route (feed the depth-`k` characteristic type into a single-point endpoint) reproduces the banned env-arity tower (report 40 §2.1-A). Mitigation: the construction must lay `w` as a **navigated bracket witness** keeping the anchor set `{x,t}`, never as a new `nf_eval` env position. This is the plan's standing Postmortem Constraint.
- **R3 — scope of `:394` (n≥2) (low, off critical path).** The n≥2 arm reduces to n=1 by iterated existential closure once `:391` lands; it is off the live completeness path and inherits the same verdict.
- **R4 — build/axiom invariants.** Baseline (documented in `40_phase16-gate-no-go-summary.md`, verified there): `lake build` GREEN (1700 jobs), live-path sorries = 2 (`:391`,`:394`), top-level axioms = 2 (`propext, Classical.choice, Quot.sound` transitively; zero domain axioms). Any implementation of (a) must preserve axiom count and reduce the sorry baseline 2 → 1.

---

## 5. Reference Grounding (H3, Tier 1) — paper ↔ Lean mapping

| Paper statement | Paper location | Lean target / asset | Status | File:line |
|-----------------|----------------|---------------------|--------|-----------|
| Lemma 3.2.2 — every ∃∀ formula ≡ conjunction of ∃∀ with **≤ 2 free variables** | `rabinovich…md:78` | Governs the anchor budget `{x,t}`; forbids env-arity growth | Constraint (honored) | policy, plan v40 Postmortem |
| Cor 5.4 — `F_n:=α_n`, `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`; witnesses in one interval | `…md:154-157` | `bracketBuildLeft`/`bracketBuildRight` (+`_correct`) — the `F_i` chain mechanism | Asset (sorry-free) | `VecEATranslation.lean:50,234` |
| Prop 3.5 — single free var at `z_k`, nested `Until`/`Since` over point/segment types | `…md:87-94` | Navigable endpoint type carrying the flattened core (Step 4) | To build (navigated) | `nf_zone_flatten_navigable_k1` (new) |
| Lemma 5.1 (fwd) — interval-negation closure | `…md:134-152` | `neg_interval_formula` | Asset (sorry-free) | `EANegationClosure.lean:401` |
| Cor 5.4 (fwd) — bounded-∃ / INF closure | `…md:154-157` | `neg_bounded_exists`; `prior_hasAttainedINF` supplies Dedekind-completeness | Asset (sorry-free) | `EANegationClosure.lean:492`; `PriorINF.lean:224` |
| Depth-0 diagonal congruence (x=t arm) | (encoding-specific) | `renameNF_eval_diag0` | Asset (sorry-free) | `NfDepth0Generalized.lean:1646` |
| Depth-`k` arity-2 **bound-anchor existential** (the IH) | Kamp completeness, `md:119-157` | `exist_tl_fn_k` / `exist_tl_fn_k_correct` | Asset (IH, in scope at `:391`) | `KampPrior.lean:334-344` |

---

## 6. Adversarial Self-Verification (H4)

Applied the Claim Verification Bar to every load-bearing claim. Methods: `Read`-confirmed source line, literature-chunk quote, or structural trace. `lean_verify` results for the Phase-16 obstruction decls are cited from the documented Phase-16 run (`40_phase16-gate-no-go-summary.md`), not re-executed (no edits this dispatch).

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|-----------------------|---------------------|------------|
| `:391` obligation is `temporal_truth t A ↔ ∃x, nf_eval M (k+1) 2 [x,t] sub_nf` | `def` return type + `n=1` arm | `Read` `KampPrior.lean:257-263,388` | High |
| The bound anchor `x` is existentially bound (position-0 of a 2-anchor NF), `t` is the fixed origin | `Fin.cons x (fun _=>t)`, `insertEnv` identity | `Read` `KampPrior.lean:317-331,388` | High |
| IH `exist_tl_fn_k` realizes bound-anchor closure `∃x, nf_eval M k 2 [x,t] sub'` at depth k, in scope at `:391` | `let exist_tl_fn_k … choose`; `_correct … choose_spec` | `Read` `KampPrior.lean:334-344` | High |
| IH is the structurally-decreasing recursive call (depth k, n=1), legitimately available in the k+1 step | recursion on `(k,n)`; k=0 arm proven `:264-267` | `Read` `KampPrior.lean:255-268,305-316` | High |
| Phase-16 refutation's core lemma requires a FREE-anchor `∀x` gate | `hgate : ∀ x, x<t → (…↔ ∃y,t<y ∧ …zoneEnv3 y x t…)` | `Read` `NfZoneNavProbe.lean:136-145,172-174` | High |
| Bound gate has no free `x`, so `gate_forces_x_independence` is unstatable → obstruction #3 does not transfer | RHS is `∃x,…`, closed in `x` | Structural trace over `NfZoneNavProbe.lean:165` vs `:391` shape | High |
| In the free-anchor counterexample model the bound RHS is `True` and `A≡⊤` satisfies the bound gate | `hx₁` realizes ⇒ `∃x` holds; `⊤` matches | Structural trace over `no_x_independent_…:170,179` | High |
| D1 refutes only the depth-0 **atomic** `(x,t)`-bracket (purely local, no navigation) | `.atom`/`.box` `temporal_truth` is local; witnesses interior | `Read` `NfZoneDepthK1Probe.lean:33-53` | High |
| Navigable `bracketBuildRight`/`Left` reach exterior `w` (Until future, Since past), unlike atomic D1 | builder semantics (`Until`/`Since` chains) | `Read` `VecEATranslation.lean:50,234` + report 40 §3.2 | Medium |
| Projection non-injectivity (#1) concerns factorization of the `x=t` diagonal, not existence; diagonal handled by `renameNF_eval_diag0`+`char_k1` | Phase-10 diagnosis; diagonal arm assets | `Read` report 40 §2.1, `KampPrior.lean:347`; prior finding | Medium |
| Prior structures with `semantic_prior_UZ` are Dedekind-complete (INF attainment) ⇒ Kamp U/S-completeness applies | `prior_hasAttainedINF : semantic_prior_UZ → HasAttainedINF` | `Read` task brief + `PriorINF.lean:224` (asset) | Medium |
| Rabinovich caps free vars ≤ 2; couples witnesses to interval endpoints only, never a third anchor | *"…at most two free variables"*; `F_{i-1}:=α_{i-1}∧(β_i Until F_i)` | Literature quote `md:78,154-157` | High |
| Phase-16 obstruction decls are sorry-free, axioms `[propext,Classical.choice,Quot.sound]`, build GREEN | documented `lean_verify` + `lake build` (1700 jobs) | `Read` `40_phase16-gate-no-go-summary.md:52-60` (not re-run) | Medium |
| **A uniform navigable `A` EXISTS (outcome a); (b) is false** | grounds 1–3 combined; no bound-anchor analog of #3 is provable | Convergent structural + meta-mathematical argument (not machine-checked) | Medium-High |
| The depth-graded flattening brick (Step 4) **succeeds** in this NF encoding | Kamp is true, but the encoding's non-injectivity refuted projection & atomic D1 | NOT verified — the single open constructive risk (R1); Kamp argues success | Low-Medium |

**Contradiction Log.** One apparent contradiction surfaced and is resolved.

- *Prior artifacts* (four refutations; phase-16 NO-GO; report 40 "the bridge is NO-GO") **vs.** *this verdict* ("A exists, outcome (a)"). **Resolution** (precedence: primary-source + structural trace over inherited handoff framing): every prior refutation targets a construction that **names or projects a third anchor at a single point** (free-anchor gate, atomic flat bracket, per-variable projection, env-arity tower). None refutes a **navigated chain of existentially-bound witnesses** (Rabinovich `F_i`). The refutations are decisive *for their class* and simultaneously *irrelevant to* the bound-anchor navigated construction. No unresolved contradiction remains. The one genuinely open item is **not** a contradiction but an unverified constructive premise (R1), explicitly flagged Low-Medium and scoped as the first implementation gate — never overclaimed as done.

**Honest low-confidence flag.** The single claim deliberately not overclaimed: that the depth-graded flattening (Step 4) *lands sorry-free in this specific `NormalForm` encoding*. It might hit the same non-injectivity that refuted projection. That risk is why the implementation must open with a navigated-flattening `k=1` probe (R1). It does **not** move the existence verdict — `A` exists mathematically (ground 3) regardless of which Lean encoding-path realizes it — but it does bound the implementation reachability.

---

## 7. References

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:255-394` (`nf_nvar_exist_all_depths`; IH `exist_tl_fn_k:334-344`; `char_k1:347`; sorries `:391`,`:394`).
- `…/Kamp/NfZoneNavProbe.lean` (Phase-16 free-anchor refutation; `gate_forces_x_independence:136`, `no_x_independent_formula_captures_future_zone_k1:165`).
- `…/Kamp/NfZoneDepthK1Probe.lean` (D1 atomic-bracket refutation; `interior_bracket_cannot_realize_exterior_sub_k1:49`).
- `…/Kamp/NfZoneDepthK.lean` (projection non-injectivity; zone-split assets).
- `…/Kamp/VecEATranslation.lean:50,234` (`bracketBuildLeft`/`bracketBuildRight` + `_correct`); `…/Kamp/PriorINF.lean:224` (`prior_hasAttainedINF`); `…/Kamp/EANegationClosure.lean:401,492`; `…/NfDepth0Generalized.lean:1646` (`renameNF_eval_diag0`).
- `specs/305_…/reports/40_phase11b-divergence-audit.md` (§2.1-A single-point endpoint / arity tower; §3.2 flattening probe sizing); `specs/305_…/summaries/40_phase16-gate-no-go-summary.md` (baseline, verdict).
- Rabinovich 2014 "A Proof of Kamp's Theorem": Lemma 3.2.2 (`md:78`), Prop 3.5 (`md:87-94`), Lemma 5.1 (`md:134-152`), Cor 5.4 (`md:154-157`), Key Insights (`md:208-230`). Local: `~/Projects/Literature/sources/rabinovich_2014/`.
