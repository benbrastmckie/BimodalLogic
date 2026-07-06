# Report 02 — Endpoint-Hook Discharge Blocker Research (task 309)

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Type**: lean4 (hard-mode blocker research; H2/H3/H4/H5)
- **Session**: sess_1783359214_93fd70
- **Focus**: blocker research / divergence audit — endpoint-hook discharge for `KampPrior.lean:351`
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 §5)
- **Inputs audited (source-read this session)**: `NfMultiAnchorBridge.lean`
  (`nf_char2_past_formula(_correct)` :987-1061, `nf_char2_future_formula(_correct)` :1185-1261,
  `A_diag(_correct)` :763-808, `nf_char3_endpoint_tl(_correct)` :891-947,
  `nf_zone_flatten_navigable(_correct)` :689-728, `nf_char2_diag_exist_tl(_correct)` :190-227,
  `nf_char2_zone_split5` :606-615, `nf_char3_deeper_split` :625-642), plan
  `plans/01_offdiag-fi-chain-plan.md` (Phase 6 `[BLOCKED]`), `reports/01_offdiag-fi-chain-research.md`,
  task 307 `reports/03_endpoint-hook-blocker-audit.md`, Rabinovich md:130-173.

## VERDICT: **BINDS** — recommend **route (a): revise the 309 plan** (add the missing recursive primitive as construction phases). Route (c) REFUTED with new, stronger evidence; route (b) acceptable fallback.

The `:351` blocker is real. Phases 1-5 landed the **outer** hook-parametric F_i-chain wrappers
sorry-free, but every one of them **defers** the off-diagonal `(x,t)` coupling to a
hook-correctness hypothesis (`h_quant` / `h_past` / `h_fut` / `h_diag`). Discharging those hooks
is the genuine Rabinovich Cor 5.4 core (~300-500 lines, recursion on `k`) and is **not** supplied
by any existing builder. New, decisive finding (§4): the specific residual-discharge mechanism the
landed scaffolding advertises — `nf_char3_deeper_split` / "depth-`k` IH one depth down" — provably
**grows the anchor set** (`arity 3→4`, anchors `{x,t}→{y,x,t}`), violating the Rabinovich ≤2 cap
(G2/G4). So route (c) is not merely "doesn't compose"; the advertised composition is anchor-tower
forbidden. The correct construction must keep every interior witness a **bracket witness** via the
navigable brick + a **non-trivial segment** (Rabinovich `β_i`), which does not yet exist.

---

## 1. The verbatim hook obligations (Lean types, source-read)

All three live-path `_correct` lemmas that the `:351` rewire must apply carry an undischarged
hook. These are the exact obligations the rewire cannot meet with current assets.

### 1.1 `nf_char2_past_formula_correct` — `h_quant` (NfMultiAnchorBridge.lean:1023-1026)

```lean
(h_quant : ∀ x : M.carrier, x < t →
  ((quantEnd.eval_at M atomMap x ∧ seg.holds M atomMap x t) ↔
    (∀ qnf : NormalForm sig k 3,
      (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true))))
```
`quantEnd : TemporalPred` and `seg : BracketFormula 0` are **free parameters** of the def
(:996-997); the theorem takes their joint correctness as a hypothesis. `zoneEnv3 w x t =
Fin.cons w (Fin.cons x (fun _ => t))` — a **two-anchor** `(x,t)` coupled arity-3 existential over
`w`, at **depth `k`**.

### 1.2 `nf_char2_future_formula_correct` — dual `h_quant` (NfMultiAnchorBridge.lean:1223-1226)

```lean
(h_quant : ∀ x : M.carrier, t < x →
  ((quantEnd.eval_at M atomMap x ∧ seg.holds M atomMap t x) ↔
    (∀ qnf : NormalForm sig k 3,
      (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true))))
```

### 1.3 `A_diag_correct` — `h_past` / `h_fut` / `h_diag` (NfMultiAnchorBridge.lean:787-795)

```lean
(h_past : ∀ (qnf : NormalForm sig k 3) (w : M.carrier), w < t →
  ((pastEnd qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf))
(h_fut  : ∀ (qnf : NormalForm sig k 3) (w : M.carrier), t < w →
  ((futureEnd qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf))
(h_diag : ∀ (qnf : NormalForm sig k 3),
  temporal_truth M atomMap t (diagChar qnf) ↔ nf_eval_nf M k 3 (Fin.cons t (fun _ => t)) qnf)
```
`pastEnd futureEnd : NormalForm sig k 3 → TemporalPred`, `diagChar : NormalForm sig k 3 → Formula`
are free parameters (:784-785). Even the **diagonal** arm's `h_past`/`h_fut` demand an arity-3
navigated characteristic at `[w,t,t]` (`w≠t`, a genuine two-point `{w,t}` property at a **navigated**
`w`).

### 1.4 The single primitive all three reduce to

Every hook above is an instance of one missing object:

> **A closed (model-independent) builder `endChar : NormalForm sig k 3 → TemporalPred` with**
> **`(endChar qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`** for a **navigated**
> witness `w`, two fixed anchors `{a,b}` (`⊆ {x,t}`), by **recursion on `k`**, arity capped at 3.

`h_diag` is its `a=b=t` (diagonal) instance; `A_diag`'s `h_past`/`h_fut` its `[w,t,t]` instances;
the brick hooks inside `h_quant` its `[w,x,t]` instances. Once this primitive exists, all four hooks
discharge and `:351` becomes the planned ~40-80-line glue.

---

## 2. What Phases 1-5 actually landed (and what they deferred)

| Landed asset (green, sorry-free) | What it proves | What it DEFERS |
|---|---|---|
| `nf_char2_past_formula` :992 | `Formula.and (origin atom) (A_past seg (endpoint ∧ quantEnd))` | `seg`, `quantEnd` are **parameters** |
| `nf_char2_past_formula_correct` :1015 | past-arm iff **under `h_quant`** | the `(x,t)` coupling (§1.1) |
| `nf_char2_future_formula(_correct)` :1185 | future dual **under dual `h_quant`** | §1.2 |
| `A_diag(_correct)` :763 | diagonal arm **under `h_past`/`h_fut`/`h_diag`** | §1.3 |
| `nf_char3_endpoint_tl(_correct)` :891 | arity-3 endpoint `TemporalPred` **under `h_atom`/`h_inner`** | `innerConv : NormalForm sig k 4` + its correctness (arity **4**) |
| `nf_zone_flatten_navigable(_correct)` :689 | 5-zone flatten of `∃w …[w,x,t]` **under `h_past`/`h_fut`** | the two navigated endpoints (arity-3 navigated) + leaves interior `x<w<t` **raw** (:697) |

Phases 1-5 are the **outer wrapper** of the F_i chain and are correct as far as they go. But they are
uniformly hook-parametric: **not one of them closes the off-diagonal `(x,t)` coupling** — each pushes
it one interface out. The `:351` rewire is where the pushing stops and the primitive of §1.4 must be
produced. It has not been.

---

## 3. Rabinovich Cor 5.4 source-to-implementation mapping (H3, Tier 1)

Source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`,
§5. Cor 5.4 (md:154-157): `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`; `[α_0,…,α_n](z_0,z)`
holds iff there is an increasing sequence in `(z_0,z_1)` with `F_0(z_0)`. The endpoint coupling
`z_0 ↔ z_1` rides the **non-trivial** segment types `β_i` inside the Until nesting; the intermediate
witnesses are bracket witnesses bound by the Until, never named env anchors (≤2 free-variable cap,
Lemma 3.2.2 / Notation 5.2, md:78, md:130).

| Source (Rabinovich 2014) | Prop/Location | Lean identifier | Type signature (verified) | Status |
|---|---|---|---|---|
| `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` non-trivial segment coupling | md:154-157 | `bracketBuildLeft`/`_correct`, `bracketBuildRight`/`_correct` | VecEATranslation:273/:503, :50/:234 (`↔ ∃ z0<t, end.eval z0 ∧ seg.holds z0 t`) | Available; segment currently forced trivial-top on the off-diagonal arms |
| Segment-carrying outer arm | md:154-157 | `A_past`/`A_future`/`_correct` | NfZoneFlattenNavigable:335/:386, `(seg : BracketFormula 0)(pastEnd : TemporalPred)` | **Landed P1** (now segment-carrying, green) |
| Off-diagonal endpoint atom layer (`order 0 1 = true`) | md:154-157 | `nf_char2_atom_offdiag_{origin,endpoint,correct}` | NfMultiAnchorBridge:364/:375/:391 | **Landed P2** (green) |
| Arity-3 endpoint characteristic shape | md:154-157 | `nf_char3_endpoint_tl`/`_correct` | NfMultiAnchorBridge:891/:907, needs `innerConv : NormalForm sig k 4` | **Landed P3 but hook-parametric**; `innerConv` = arity-4, undischarged |
| `F_i` chain past/future arm (outer wrapper) | md:154-157 | `nf_char2_{past,future}_formula`/`_correct` | NfMultiAnchorBridge:992/:1015, :1185/… | **Landed P4/P5 but under `h_quant`** (§1.1/1.2) |
| Coupled inner `∃w` five-zone flatten (Lemma 5.1 interior) | md:134-152, md:159-171 | `nf_zone_flatten_navigable(_brick)`/`_correct` | NfMultiAnchorBridge:689/:709 | Available, hook-parametric; interior left raw (:697) |
| Interval split at new point | md:168-171 | `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Available (sorry-free) |
| **Navigated arity-3 endpoint characteristic (the F_i primitive, §1.4)** | md:154-157 | `endChar : NormalForm sig k 3 → TemporalPred` (**to build**) | `.eval_at w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`, recursion on `k`, anchors ≤2 | **DOES NOT EXIST — the blocker** |
| Base of recursion (depth-0, all arities off-diagonal) | md:143-152 (Lemma 5.3 base) | `nf_nvar_exist_depth0_tl_fn`/`_correct` | NfDepth0Generalized:1615/:1622 | Available, but **existential-at-origin**, not navigated-point (§4.3) |
| ≤2 free-variable cap (no third anchor tower) | md:78 (Lemma 3.2.2), md:130 (Notation 5.2) | guard G2/G4 | — | Binding constraint the primitive must respect |

---

## 4. Adversarial evaluation of the three routes (H4)

### 4.1 Route (c) — cheaper discharge with existing builders: **REFUTED (stronger than the handoff stated)**

The `h_quant` obligation (§1.1) needs, per `qnf`, the two-anchor existential
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` characterized at `x` by `(quantEnd, seg)`. Tracing every
candidate builder:

- **`nf_zone_flatten_navigable_correct` (:709)** flattens exactly that existential into 5 zones — but
  under hooks `h_past`/`h_fut` that are themselves arity-3 **navigated** characteristics (`(pastEnd q).eval_at w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) q`). Those are the §1.4 primitive. Unmet — recurses into itself.
- **`nf_char3_endpoint_tl_correct` (:907)** produces the arity-3 navigated `TemporalPred` shape, but
  its `h_inner` hook (:915-917) demands `innerConv : NormalForm sig k 4` with
  `∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` — **arity 4, three fixed points `y,x,t`**.
- **`nf_char3_deeper_split` (:625-642)** — the mechanism the landed Phase-3/5 comments name for
  "residual discharge one depth down" — provably rewrites a depth-`(k+1)` arity-3 characteristic into
  depth-`k` **arity-4** inner existentials over **seven** zones relative to **three** anchors `y,x,t`
  (:630-637). Its interior zones (e.g. `x<w<t`, :635) have **all four points distinct** ⇒ **three fixed
  anchors**.
- **depth-`k` IH `nf_nvar_exist_all_depths` (KampPrior:211)** yields characterizations of the
  existential **at the origin `t`** (`insertEnv env t`), not `.eval_at` at a **navigated** witness with
  **fixed** anchors. Wrong shape.

**Decisive new finding.** The advertised composition (`nf_zone_flatten_navigable` + `nf_char3_endpoint_tl`
/ `nf_char3_deeper_split` for residuals) does **not** keep the anchor set at `{x,t}`. Each depth-descent
**adds** an anchor (`{x,t} → {y,x,t} → …`), so at depth 0 it would require an arity-`(k+3)`
navigated characteristic pinning `k+2` fixed external anchors — a depth-0 point formula cannot express
that, and it violates the Rabinovich ≤2 cap (G2/G4). The plan's Phase-3/5 route-audit comments
(NfMultiAnchorBridge:661, :676-678) assert these residuals stay "arity ≤3, anchor set `{x,t}`"; that
claim is **false against `nf_char3_deeper_split`'s own statement**. Route (c) is not viable — and worse,
naively pursuing it builds the forbidden anchor tower. (This corroborates task 307 report 03 §2's
exhaustive grep-refutation, and strengthens it: the failure is structural, not merely "asset absent".)

### 4.2 The correct construction (why route a/b is nonetheless feasible)

Rabinovich Cor 5.4 is a **theorem** over Dedekind-complete chains, so the object exists; no
impossibility is exhibited (307 report 03 route (iv), still stands). The construction that keeps
anchors ≤2 does **not** use `nf_char3_deeper_split`'s anchor-growing decomposition. Instead:

- the interior witness `w` stays a **bracket witness** collapsed by the navigable brick (G4);
- the interior interval `(x,t)` type is encoded in a **non-trivial segment** `seg` (Rabinovich `β_i`),
  evaluated as part of the whole-formula-at-origin-`t` via `bracketBuildLeft seg` — **not** left raw
  as `nf_zone_flatten_navigable` currently does (:697), and **not** trivial-top as the exterior
  brackets are;
- recursion is on **`k`** with arity strictly capped at 3 (2 fixed anchors + 1 witness), bottoming out
  at `k=0`.

This is the ~300-500 line core. It is genuinely unbuilt: the landed brick uses **trivial** segments and
leaves the interior **raw**; the segment-based interior encoding that closes `h_quant` within the ≤2
cap has never been constructed.

### 4.3 Base-case risk (must be scoped in the revision)

The depth-0 base `nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized:1615) is an
**existential-at-origin** converter, whereas the §1.4 primitive needs a **navigated-point** arity-3
characteristic at `k=0`. Whether the depth-0 navigated arity-3 atom characteristic is directly
available or needs a small dedicated base lemma is the primary open sub-question the construction
phase must resolve. Flagged Medium risk.

### 4.4 Route (a) vs (b)

| | Route (a): revise 309 plan | Route (b): spawn new task, block 309 |
|---|---|---|
| Landed P1-5 wrappers | preserved in-task, are the natural consumers of the primitive | orphaned across a task boundary; new task must re-consume |
| Definition of done | single (close `:351`) stays in one convergent task | split across two tasks |
| Mis-scope risk | fixed by a **corrected decomposition** (the reviser's job) | 307→309 already spawned once; the mis-scope was in the **decomposition**, not the task boundary — spawning again does not itself prevent recurrence |
| H5 churn isolation | shared with existing 309 history | cleaner per-task counters |
| Precedent | — | 307 report 03 chose SPAWN (produced 309) |

**Recommendation: route (a).** The decisive lever in either route is the **corrected decomposition**
that makes the navigated-endpoint primitive (§1.4) the *deliverable*, not a hook parameter. `/revise`
delivers exactly that inside 309 while preserving the green P1-5 consumers. Route (b) is acceptable if
the orchestrator prefers task-boundary isolation for the ~300-500-line core, but it re-introduces the
fragmentation that arguably enabled the current deferral.

---

## 5. Divergence audit (H5): why 307 P7 and 309 P6 both hit this

| Stage | What it concluded/did | Root divergence |
|---|---|---|
| task 305 P11b | projection `VecEA2` tower refuted | anchor tower forbidden (G2) |
| task 307 P3 → task 308 | built diagonal `[t,t]` chain + hook-parametric brick | diagonal escapes the `(x,t)` re-identification (307 rpt 03 §1.3) |
| task 307 P7 | BINDS; **SPAWN** the off-diagonal F_i chain (→ task 309) | closed `pastEnd` under trivial-top unsatisfiable; needs non-trivial segment (G3) |
| task 309 P1-5 | landed segment-carrying wrappers + `nf_char2_{past,future}_formula` + `A_diag`, **all hook-parametric** | **re-built the outer wrapper 307 already identified; deferred the SAME coupling one interface out** |
| task 309 P6 | BLOCKED: `h_quant`/`h_past`/`h_fut`/`h_diag` discharge is the core, not glue | plan scoped P6 as 40-80 lines glue; the discharge is the ~300-500-line primitive (§1.4) |

**Churn count on the single target** (the off-diagonal navigated arity-3 endpoint characteristic /
`(x,t)` coupling): **4 strikes** (305 P11b, 307 P3, 307 P7, 309 P6). H5 three-strikes is exceeded — this
report IS the dedicated audit dispatch.

**Root cause.** The recurring failure is treating the arity-3 navigated endpoint characteristic as
*dischargeable at the call site by the local IH*. It is not: the local IH (`exist_tl_fn_k`, arity-2,
existential-at-origin) and the anchor-growing `nf_char3_deeper_split` cannot produce a navigated-point
fixed-anchor characteristic within the ≤2 cap. Each dispatch has parametrized the hook and moved on;
none has built the recursive **segment-based** primitive that actually closes it. The plan's own
route-audit comments assert a discharge mechanism (`nf_char3_deeper_split`, "arity ≤3") that its
statement contradicts (§4.1) — that false internal claim is what let each dispatch believe the hook was
"routine IH".

### Sorry inventory (live path)

| Identifier | State | Type / obligation | Why stuck |
|---|---|---|---|
| `KampPrior.lean:351` (`n=1` arm) | live `sorry` | `∃ A, temporal_truth t A ↔ ∃ env:Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` | needs the §1.4 primitive to discharge `h_quant`/`h_past`/`h_fut`/`h_diag` |
| `KampPrior.lean:354` (`n≥2` arm) | live `sorry` | arity-`(n+1)` general recursion | **out of scope** (task 305) |

### Type-mismatch analysis

| Consumer needs | Existing supplier gives | Mismatch |
|---|---|---|
| `(endChar qnf).eval_at w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` (navigated, fixed `{x,t}`) | `nf_nvar_exist_all_depths`: `temporal_truth t A ↔ ∃ env, nf_eval … (insertEnv env t)` | navigated-point vs existential-at-origin; fixed anchors vs all-anchors-existential |
| arity 3, anchors `{x,t}` (≤2 cap) | `nf_char3_deeper_split`: arity 4, anchors `{y,x,t}` (:630-637) | **anchor growth** — forbidden tower (G2/G4) |
| `innerConv` closing `nf_char3_endpoint_tl.h_inner` | none | arity-4 converter with 3 fixed anchors — unbuilt & tower-forbidden |

---

## 6. Concrete phase decomposition for the reviser (route (a))

Revise `plans/01_offdiag-fi-chain-plan.md`: keep Phases 1-5 `[COMPLETED]`, replace the single
`[BLOCKED]` Phase 6 with the following. All phases inherit guards G1-G5 verbatim and cite Rabinovich
md:154-157 at each `F_i` step (G5; no simp/omega/aesop on a chain step).

- **Phase 6 — depth-0 navigated arity-3 endpoint base + interface** (~80-150 lines).
  Resolve §4.3: build (or adapt from `nf_nvar_exist_depth0_tl_fn`) the closed depth-0 navigated
  characteristic `endChar0 : NormalForm sig 0 3 → TemporalPred` with `.eval_at w ↔ nf_eval_nf M 0 3
  (zoneEnv3 w a b)` for `{a,b} ⊆ {x,t}`, and fix the `endChar : NormalForm sig k 3 → TemporalPred`
  interface (§1.4) the step recurses on. Verification: `lake build` green; `_correct` typechecks at
  `k=0`. Guards: G1, G4. **Owns the base-case risk.**

- **Phase 7 — non-trivial interior segment builder + `holds` correctness** (~120-200 lines).
  Build the Rabinovich `β_i` segment `seg : BracketFormula 0` whose `seg.holds M atomMap x t` encodes
  the **bounded-interior** zone `∃ w, x<w<t ∧ nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` with `w` a bracket
  witness (NOT `nf_char3_deeper_split`; NOT trivial-top; NOT raw as `nf_zone_flatten_navigable:697`).
  Verification: `holds`-correctness lemma green; anchors provably `{x,t}` (G4). Guards: G3, G4, G5.
  **The load-bearing sub-piece.** If it overruns H8, split at the (per-`qnf` clause) / (interval
  assembly) seam into 7a/7b.

- **Phase 8 — the recursive navigated endpoint primitive `endChar`(_correct)** (~120-200 lines).
  Assemble `endChar` by recursion on `k`: base = Phase 6; step = navigable-brick flatten of each sub's
  `∃w'` with Phase-7 segments for the interior and Phase-6/8 endpoints for the exteriors, keeping
  arity ≤3. Prove `_correct`: `(endChar qnf).eval_at w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`.
  Verification: green; `#print axioms` clean. Guards: G1, G2, G4, G5.

- **Phase 9 — discharge the four hooks + `:351` rewire + full-tree axiom check** (~60-120 lines).
  At the KampPrior call site, instantiate `quantEnd`/`seg`/`pastEnd`/`futureEnd`/`diagChar` from
  Phases 6-8 and **prove** `h_quant` (past+future), `h_past`/`h_fut`/`h_diag` via `endChar_correct` +
  `nf_zone_flatten_navigable_correct`. Then `A := nf_char2_past_formula … ∨ A_diag … ∨
  nf_char2_future_formula …`, `rw [nf_zone_exists_trichotomy_k1]`, three-way `or_congr`. Close `:351`
  (live sorries 2→1). Verification (definition of done): full `lake build` GREEN; `#print axioms` on
  the rewired live-path theorem = exactly `[propext, Classical.choice, Quot.sound]`; `:354` remains.
  Guards: D1 (import edge already landed P6.1), final sorry+axiom discipline.

Total added: ~380-670 lines over 4 phases (each one agent run per H8). The pre-existing "Phase 6 rewire"
becomes Phase 9; the import-edge sub-task (P6.1, already committed green) is preserved.

---

## Adversarial Self-Verification

Claim Verification Bar applied to every load-bearing claim. `Verification Method` uses lean4 domain
values (`source read of signature/binder`, `grep-confirmed`, `literature read`).

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| `nf_char2_past_formula_correct` defers the `(x,t)` coupling to `h_quant` over `∃w, nf_eval M k 3 (zoneEnv3 w x t) qnf` | NfMultiAnchorBridge:1023-1026 — source read | Confirmed |
| `nf_char2_future_formula_correct` carries the dual `h_quant` | NfMultiAnchorBridge:1223-1226 — source read | Confirmed |
| `A_diag_correct` carries `h_past`/`h_fut`/`h_diag` over arity-3 navigated `[w,t,t]` chars | NfMultiAnchorBridge:787-795 — source read | Confirmed |
| `quantEnd`/`seg` (past/future) and `pastEnd`/`futureEnd`/`diagChar` (diag) are free def parameters, not built | NfMultiAnchorBridge:996-997, :784-785 — source read | Confirmed |
| All four hooks reduce to one primitive: navigated arity-3 endpoint char, anchors ≤2, recursion on `k` | §1.4 synthesis of the three signatures | Confirmed (analytic) |
| `nf_zone_flatten_navigable_correct` flattens the `∃w` but under arity-3 navigated hooks + leaves interior raw | NfMultiAnchorBridge:697, :714-719 — source read | Confirmed |
| `nf_char3_endpoint_tl_correct`'s `h_inner` demands `innerConv : NormalForm sig k 4` (arity 4, 3 fixed pts) | NfMultiAnchorBridge:911-917 — source read | Confirmed |
| `nf_char3_deeper_split` grows arity 3→4 and anchors `{x,t}→{y,x,t}` (7 zones, interior all-distinct) | NfMultiAnchorBridge:628-637 — source read | Confirmed |
| Plan/comments claim residuals stay "arity ≤3, anchor `{x,t}`" — contradicted by deeper_split's statement | NfMultiAnchorBridge:661,:676-678 vs :628-637 — source read | Confirmed (internal inconsistency) |
| depth-`k` IH gives existential-**at-origin**, not navigated-point fixed-anchor | KampPrior:211-222 (`insertEnv env t`) — source read | Confirmed |
| No existing builder composes to close `h_quant` within the ≤2 cap | §4.1 trace + task 307 rpt 03 §2 grep-refutation | Confirmed |
| Object exists (no impossibility): Rabinovich Cor 5.4 is a theorem over Dedekind-complete chains | Rabinovich md:154-157 — literature read | Confirmed |
| Correct construction = brick witness-collapse + non-trivial segment, recursion on `k`, arity ≤3 | Rabinovich md:154-157 (F_i, β_i Until) + G4 — literature + source | Confirmed |
| The non-trivial segment / interior encoding is unbuilt (brick uses trivial segs, interior raw) | NfMultiAnchorBridge:695-700 — source read | Confirmed |
| Live-path sorries are exactly `:351` (in scope) and `:354` (task 305, out of scope) | plan Phase 6 handoff + KampPrior — cross-ref | Confirmed |
| Churn on this target = 4 strikes (305 P11b, 307 P3, 307 P7, 309 P6) | reports 305/307 + this plan — cross-ref | Confirmed |
| depth-0 navigated arity-3 base availability (vs existential-at-origin) | NfDepth0Generalized:1615-1622 — source read | Open (flagged §4.3, Phase-6 risk) |
| Route (a) preferred over (b); decisive lever is corrected decomposition | §4.4 analysis | Recommendation (Medium-High) |
| Phase line estimates (~380-670 total) | parity with task 308 (701 lines / 5 phases) + component sizing | Estimate (Medium) |

**Contradiction Log.**
- *Landed plan/comments "residuals discharged via `nf_char3_deeper_split`, arity ≤3, anchor `{x,t}`"
  (NfMultiAnchorBridge:661,:676-678) vs. `nf_char3_deeper_split`'s statement (arity 4, anchors
  `{y,x,t}`, :628-637).* **Resolved** by precedence "actual Lean signature > prose comment": the
  comment is false; `nf_char3_deeper_split` grows anchors and is NOT a valid residual-discharge route
  within the ≤2 cap. This is the root technical error behind the 4-strike churn. Downstream risk: any
  future dispatch that trusts the comment will re-attempt the forbidden tower. The revision (Phase 7/8)
  must use the brick+segment mechanism instead. **Not** an impossibility — the F_i chain still exists.
- *307 report 03 chose SPAWN vs. this report's route (a) revise.* **Resolved**: both agree the object
  must be BUILT (BINDS); they differ only on task boundary. The decisive lever (corrected decomposition
  making the primitive the deliverable) is identical either way; (a) is preferred only to preserve the
  landed P1-5 consumers in-task. No contradiction on substance.

**Forbidden-output check.** No "mathlib likely has this" (codebase-internal; every asset cited with
file:line, source-read this session). No sorry-deferral or axiom-introduction recommended — the
recommendation is a concrete sorry-free construction with axioms pinned to `[propext, Classical.choice,
Quot.sound]`. Guards G1-G5 carried forward. The one open claim (depth-0 navigated base availability) is
explicitly flagged as a Phase-6 risk, not asserted.

**Recommendations modified after verification.** The Phase-6 handoff's framing ("route (c): instantiate
hooks with existing builders `nf_char3_endpoint_tl` / depth-`k` IH / `nf_char3_deeper_split`") is
**refuted and corrected**: those builders grow the anchor set (§4.1) and cannot discharge the hooks
within G2/G4. The corrected mechanism (brick witness-collapse + non-trivial segment) is encoded into
the Phase 7/8 decomposition.
