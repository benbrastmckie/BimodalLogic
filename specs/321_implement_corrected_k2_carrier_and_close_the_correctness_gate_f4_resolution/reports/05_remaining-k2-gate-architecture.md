# Remaining k=2 Gate Architecture — Complete Prerequisite Map (Task 321)

**Task**: 321 — close the full k=2 `BracketCarrierCorrectVPrior` gate to GO (Stage C soundness +
Stage D completeness + Phase 15 F4 ℤ verdict)
**Dispatch**: hard-mode lean4 architectural scoping (H2/H3/H4/H5), `--lit` active
**Session**: sess_1783452940_63339e
**Date**: 2026-07-07
**Focus**: STOP the layer-by-layer prerequisite discovery — enumerate every missing engine/lemma NOW,
in dependency order, so the complete prerequisite set can be spawned at once. Scoping/enumeration
only; NOT an implementation pass.
**All file:line references verified against the CURRENT tree** (many prior-artifact line numbers were
stale; see the Stale-Reference Correction table at the end).

---

## Executive Verdict

The Phase-10 handoff identified ONE missing piece ("a general-j=1 quant-layer fold engine"). That
framing is **incomplete**. The full remaining architecture is **three layers deep**, not one, and the
top layer's clean-fold **provability is itself unestablished** (it is the same arity-4 → arity-3
re-bounding barrier that killed plan-v2 Phase 8, resurfacing at the outer quant layer):

1. **Layer 1 — the outer depth-2 quant-layer fold engine** (`nf_quant_layer_fold_k2_gate`,
   arity-4/depth-1 analog of the landed `nf_quant_layer_fold_k1_gate`). SHARED across Stage C and
   Stage D. **Provability UNCERTAIN** — a naive `0→1` textual lift is **blocked** (proof below).
2. **Layer 2 — the depth-1 split-kit** the engine builds on: `nfk_assemble` / `nfk_dropFresh` /
   `nfk_zoneSpec` + four round-trip lemmas + `nf_eval_nf1_cons_factor` (or, on the E[Σ] route,
   `efold_of_nfk` outer-fold transport). **None of these exist** — only the depth-0 `nf0_*` kit
   (NfEFold:153-283) and the *single-form* depth-1 transport (`efold_of_nf1` NfEFold:472,
   `nf_eval_nf1_iff_efold` NfEFold:490) are landed. This layer was NOT named in the handoff.
3. **Layer 3 — the non-interior 5-zone per-(zone,χ) dischargers** (soundness + completeness) for
   `zPastX / zAtX / zAtW / zAtT / zFutT`, carried by the carrier's **exterior since/until +
   boundary-point channels** (`epL`/`epR`/`ptW`), which are **structurally different** from both the
   task-326 pin route and the interior joint channel. Task 326's `sound_of_outer`/`complete`
   (7910 / 8159) cover only the **interior** zone `kvE_sub2_zXU` (their `hbelow`/`hgate` name only
   `kvE_sub2_zXU`). The 5 non-interior zones — three of which put x1 **outside** the pin's
   `(x, w_outer)` reach (`zPastX`: x1<x; `zFutT`: x1>t) — have **no landed discharger in either
   direction**. This layer was NOT named in the handoff.

**Phase 15 (F4 ℤ)** needs **no new infrastructure** — it is a concrete ℤ computation that only
requires the closed gate (Phases 10+14) and the completeness wiring's retained `σ.2` dependence
(guaranteed by Layer 1). It is a consumer, not a prerequisite.

**Recommended spawn set: 3 tasks** (P1 provability-gate, P2 engine, P3 non-interior dischargers),
topologically ordered `P1 → {P2, P3} → 321 v6`. **Completeness confidence: MEDIUM-HIGH** — the map
now bottoms out at landed generic assets (`nf_eval_unique` NormalForm:245, generic over k; the
depth-0 kit; the efold transport), and the one residual open question (does Layer 1 fold cleanly, and
by which route) is isolated into P1 as a cheap make-or-break gate BEFORE P2/P3 investment.

---

## H3 Reference-Grounding — Tier 1 (literature-backed: Rabinovich 2014 §5)

The missing infrastructure is the machine encoding of **Rabinovich's normal-form characterization at
one higher quantifier depth**. The construction is recursive in quantifier depth (Def 4.1 E[Σ]-fold,
PDF p.5-6), so a general-j fold engine has a faithful analog in the prior art — the zone-reconstruction
IS the normal-form characterization. The 5-column missing-infra map below IS the H3 mapping table
(name | signature | builds-on file:line | direction/coverage | which 321-phase it unblocks).

### Landed foundation (ground truth — verified signatures)

| Landed asset | file:line | Role |
|---|---|---|
| `nf_quant_layer_fold_iff` | NfEFold:391 | depth-0 outer fold: `q : NormalForm sig 0 (n+1) → Bool`; reconstructs via `nf0_assemble zs χ r`; needs `nf_eval_nf0_cons_factor` + `nf_eval_unique` |
| `nf_quant_layer_fold_k1_gate` | NfEFold:525 | k=1 specialization (n=3): folds ∃x1 over **depth-0** subs `NormalForm sig 0 4`. Thin wrapper of the above. **This is exactly what must be lifted to depth-1 subs.** |
| `nf0_assemble` / `nf0_dropFresh` / `nf0_projFresh` / `nf0_zoneSpec` | NfEFold:180 / 171 / 162 / 153 | depth-0 split kit (the bijection making the fold work) |
| `nf0_zoneSpec_assemble` / `nf0_projFresh_assemble` / `nf0_dropFresh_assemble` / `nf0_split_assemble` | NfEFold:197 / 206 / 219 / 235 | the four round-trip lemmas |
| `nf_eval_nf0_cons_factor` | NfEFold:283 | **depth-0 3-way factorization** `nf_eval M 0 (n+1) (cons x env) sub ↔ zoneHolds(x) ∧ monadic(x) ∧ eval(dropFresh,env)` — the load-bearing lemma the fold rests on |
| `nf_eval_unique` | NormalForm:245 | **generic over k** (induction on k) — the off-fiber uniqueness ingredient; already available at depth 1 |
| `nf_eval_depth1_fold_iff` | NfMultiAnchorBridge:5344 | **single depth-1 form** factorization (atom layer + inner fold via `nf_quant_layer_fold_iff` on σ.1/σ.2). Reconstructs ONE form at FIXED env — NOT the outer ∃x1 fold. |
| `NormalFormEFold` / `nf_eval_efold` | NfEFold:77 / 102 | constant-arity E[Σ]-fold type + evaluator (`EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1`) |
| `efold_of_nf1` / `nf_eval_nf1_iff_efold` | NfEFold:472 / 490 | **single depth-1 form** → efold transport (dodges arity growth for one form) |
| `nfk_projFresh` | NfMultiAnchorBridge:3668 | depth-k fresh projection via `nfk_take` (exists!); `= nf0_projFresh` at k=0 |
| `nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` | — | **DO NOT EXIST** (grep-confirmed) |
| `kvE_subChain2V` | NfMultiAnchorBridge:6955 | interior joint channel; zones `zXU/zUW/zWT` (ZoneSpec 4). `charK : NormalForm sig 1 1 → Formula` |
| `kvE_subBracket2V_sound_of_outer` | NfMultiAnchorBridge:7910 | **INTERIOR-ONLY** soundness closer (task 326). `hbelow`/`hgate` name only `kvE_sub2_zXU` |
| `kvE_subBracket2V_sound_of_parts` | NfMultiAnchorBridge:7719 | interior parts→realization (task 326) |
| `kvE_subBracket2V_complete` | NfMultiAnchorBridge:8159 | **INTERIOR-ONLY** completeness consumer; order bits + `hcharK` + `∃x1` realization for the zXU zone |
| `kvE_consistentZones` / `kvE_pinArrangements` / `kvE_pinDisjunct` | NfMultiAnchorBridge:5507 / 5521 / 5531 | the 7 zones; pin family (one per zone); pin disjunct `[⟨charK (nfk_projFresh σ)⟩]` |
| `kvE_gate` | NfMultiAnchorBridge:5172 | per-sub two-conjunct gate (off-fiber falsity + order-conflict falsity) |
| `k1v_reconstruct_nf3` | NfMultiAnchorBridge:2425 | atom-layer reconstruction (discharges the k=2 atom conjunct, as noted in Phase 9) |
| `k1v_bracket_extract` | NfMultiAnchorBridge:2150 | bracket `.holds` → per-witness realization + `w<t` (forgets ordering) |
| `nf_eval_nf` / `NormalForm` | NormalForm:198 / 134 | recursion + type (`NormalForm sig 1 4 = (AtomKind 4 → Bool) × (NormalForm sig 0 5 → Bool)`) |

### The 7 consistent zones (verified — `kvE2_body` NfMultiAnchorBridge:8618-8624)

`ltz=(true,false)`, `eqz=(false,false)`, `gtz=(false,true)`; `mk3 pw px pt = ⟨pw,px,pt⟩` (order of the
sub's fresh var vs `[w,x,t]`):

| # | Name | Zone spec | Interior? | Carrier channel that stores it |
|---|---|---|---|---|
| 1 | `zPastX` | `mk3 ltz ltz ltz` | **Exterior (x1 < x)** | `epL` **Since** wrapper `snce (charK χ) ⊤` |
| 2 | `zAtX` | `mk3 ltz eqz ltz` | Boundary (x1 = x) | `epL` **point** `charK χ` |
| 3 | `zXW` | `mk3 ltz gtz ltz` | **Interior (x < x1 < w)** | joint `kvE_subChain2V` + pins → **task 326** |
| 4 | `zAtW` | `mk3 eqz gtz ltz` | Boundary (x1 = w) | `ptW` channel |
| 5 | `zWT` | `mk3 gtz gtz ltz` | Interior (w < x1 < t) | joint `kvE_subChain2V` |
| 6 | `zAtT` | `mk3 gtz gtz eqz` | Boundary (x1 = t) | `epR` **point** `charK χ` |
| 7 | `zFutT` | `mk3 gtz gtz gtz` | **Exterior (x1 > t)** | `epR` **Until** wrapper `untl (charK χ) ⊤` |

**This table is the crux of Layer 3.** Task 326 (pins + `kvE_subChain2V`) covers only rows 3 & 5
(interior). Rows 1-2, 4, 6-7 are carried by structurally different channels and have **no landed
per-zone discharger**. Rows 1 (`zPastX`, x1<x) and 7 (`zFutT`, x1>t) are the sharpest: their honest
witness lies OUTSIDE the pin's `(x, w_outer)` reach, so the pin route cannot possibly cover them —
they need the `epL`/`epR` since/until exterior channels.

---

## The Missing-Infrastructure Map (H3 5-column)

### Layer 1 — the outer depth-2 fold engine (SHARED Stage C ⇄ Stage D)

| Name (proposed) | Full signature (Lean-precise) | Builds on (file:line) | Direction / coverage | Unblocks (321 phase) |
|---|---|---|---|---|
| `nf_quant_layer_fold_k2_gate` | `theorem nf_quant_layer_fold_k2_gate {sig} (M) (w x t : M.carrier) (qnf : NormalForm sig 2 3) (h_atom : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1) : (∀ sub : NormalForm sig 1 4, (∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub) ↔ qnf.2 sub = true) ↔ ((∀ (zs : ZoneSpec 3) (χ : NormalForm sig 1 1), (∃ x1, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs x1 ∧ nf_eval_nf M 1 1 (fun _ => x1) χ) ↔ qnf.2 (nfk_assemble zs χ qnf.1) = true) ∧ (∀ sub, nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false))` | NfEFold:391/525 (template); NfMultiAnchorBridge:3668 (`nfk_projFresh`); NormalForm:245 (`nf_eval_unique`, generic); **Layer 2 (missing)** | BOTH directions; all 7 zones (zone-generic). **Note χ : NormalForm sig 1 1 (depth-1 monadic) — matches the carrier's `charK` domain, confirmed by `sound_of_parts`.** | Phases 9-10 (soundness), 11-14 (completeness) — the outer quant-layer assembly both directions presume this |

**Difficulty: HIGH. Provability UNCERTAIN — a naive `0→1` lift is BLOCKED (proof below).** This is the
make-or-break and MUST be gated by P1 before P2 investment.

### Layer 2 — the depth-1 split-kit (Layer 1's foundation; NONE landed)

| Name (proposed) | Full signature (Lean-precise) | Builds on (file:line) | Direction / coverage | Unblocks (321 phase) |
|---|---|---|---|---|
| `nfk_zoneSpec` | `def nfk_zoneSpec {sig}{k n} (sub : NormalForm sig k (n+1)) : ZoneSpec n` | NfEFold:153 (`nf0_zoneSpec` template) | reconstruction data | Layer 1 |
| `nfk_dropFresh` | `noncomputable def nfk_dropFresh {sig}{k n} (sub : NormalForm sig k (n+1)) : NormalForm sig k n` | NfEFold:171 (`nf0_dropFresh` template) | reconstruction data | Layer 1 |
| `nfk_assemble` | `def nfk_assemble {sig}{k n} (zs : ZoneSpec n) (χ : NormalForm sig k 1) (r : NormalForm sig k n) : NormalForm sig k (n+1)` | NfEFold:180 (`nf0_assemble` template) | the bijection inverse | Layer 1 |
| `nfk_zoneSpec_assemble` / `nfk_projFresh_assemble` / `nfk_dropFresh_assemble` / `nfk_split_assemble` | four round-trips, depth-k analogs of NfEFold:197/206/219/235 | NfEFold:197-235 | bijection round-trips | Layer 1 |
| `nf_eval_nf1_cons_factor` (**HIGH-RISK — may be FALSE in clean form**) | `theorem nf_eval_nf1_cons_factor {sig}(M){n}(env)(x)(sub : NormalForm sig 1 (n+1)) : nf_eval_nf M 1 (n+1) (Fin.cons x env) sub ↔ zoneHolds M env (nfk_zoneSpec sub) x ∧ nf_eval_nf M 1 1 (fun _ => x) (nfk_projFresh sub) ∧ nf_eval_nf M 1 n env (nfk_dropFresh sub)` | NfEFold:283 (`nf_eval_nf0_cons_factor` template) | **the load-bearing factorization** | Layer 1 |
| **ALT route β**: `efold_of_nfk` + `nf_eval_efold_cons_factor` | outer-fold transport over the landed `NormalFormEFold`/`efold_of_nf1` constant-arity representation | NfEFold:77/102/472/490 | dodges the arity-4 barrier | Layer 1 (if factor route blocked) |

**Difficulty: MED-HIGH.** The split-kit defs + round-trips are mechanical lifts of NfEFold:153-235
(`nfk_projFresh` at 3668 already exists and matches at k=0). **The single high-risk item is
`nf_eval_nf1_cons_factor`** — see the blocked-lift proof; if it fails cleanly, route β (efold outer
fold) is the fallback, MED-HIGH but plausible (the efold's `zoneHolds`-coupled constant-arity quant
clause is designed exactly to avoid arity growth).

### Layer 3 — non-interior 5-zone dischargers (Stage C soundness + Stage D completeness)

| Name (proposed) | Full signature (sketch) | Builds on (file:line) | Direction / coverage | Unblocks (321 phase) |
|---|---|---|---|---|
| `kvE_sub2V_exterior_sound_of_outer` | for `zs ∈ {zPastX, zFutT}`: outer `epL`/`epR` since/until `.holds` + gate → per-(zone,χ) realization `∃ x1 (x1<x or x1>t), zoneHolds ∧ nf_eval M 1 1 χ` | NfMultiAnchorBridge:5595-5605 (`epL`/`epR` since/until literals); `k1v_bracket_extract`:2150 | **soundness**, exterior zones (x1 ∉ (x,t)) | Phase 10 |
| `kvE_sub2V_boundary_sound_of_outer` | for `zs ∈ {zAtX, zAtW, zAtT}`: `epL`/`ptW`/`epR` point `charK χ` `.holds` + gate → per-zone realization at the boundary point | NfMultiAnchorBridge `epL`/`ptW`/`epR` point channels | **soundness**, boundary zones | Phase 10 |
| `kvE_sub2V_exterior_complete` / `kvE_sub2V_boundary_complete` | honest realization at zone z (z ∈ the 5) → the z-specific carrier channel `.holds` | `kvE_subBracket2V_complete`:8159 (interior template) | **completeness**, 5 non-interior zones | Phases 12-13 |

**Difficulty: MED-HIGH.** These are the structural analogs of task-326's interior closers but for the
exterior/boundary channels. The exterior zones (`zPastX`/`zFutT`) are the highest-risk: their witness
is outside `(x,t)`, reconstructed via Since/Until reach, faithful to Rabinovich Cor 5.4
evaluation-point positioning (the since/until wrapper positions x1 by the reach relation, never an
`x1 < e_i` literal — **litmus PASS**). Depends on Layer 1's exact per-(zone,χ) obligation shape (so
the discharger targets match the engine's RHS).

### Non-prerequisites (consumers — no new infra)

| Item | Why no new infra |
|---|---|
| Phase 15 F4 ℤ LHS-FALSE | concrete ℤ computation vs the closed gate; discrimination already landed at construction level (Phase 7 `kvE_subBracket_ne_of_witnessCount_ne`); only needs the σ.2 dependence retained by Layer 1 |
| Phase 9 reduction prefix | VERIFIED green, reusable verbatim (handoff `verified_green_progress`) |
| Phase 10 atom layer | `k1v_reconstruct_nf3`:2425 discharges it (as k1v) |
| Interior zones (zXW, zWT) | task 326 `sound_of_outer`:7910 / `complete`:8159 (LANDED, do-not-edit) |

---

## Why the naive `0 → 1` lift of the fold engine is BLOCKED (structural, machine-grounded)

`nf_quant_layer_fold_iff` (NfEFold:391) rests on `nf_eval_nf0_cons_factor` (NfEFold:283), the clean
3-way split of a **depth-0** sub's evaluation into `zoneHolds(x) ∧ monadic(x) ∧ eval(dropFresh, env)`.
For **depth-1** subs the analogous `nf_eval_nf1_cons_factor` does **not** split cleanly:

- Apply `nf_eval_depth1_fold_iff` (5344) to `sub : NormalForm sig 1 (n+1)` at env `Fin.cons x env`.
  Its RHS is `atom-layer(cons x env) ∧ innerFold(cons x env)`.
- The **atom layer** factors fine (via `nf_eval_nf0_cons_factor` on `sub.1`).
- The **inner fold** `∀ zs χ, (∃v, zoneHolds M (Fin.cons x env) zs v ∧ …) ↔ sub.2(nf0_assemble …)`
  references `x` INSIDE `zoneHolds (Fin.cons x env) zs v` — the inner witness `v`'s zone relative to
  `x` is genuine cross-content. Distributing the outer `∃x1` across this does **not** collapse to
  `monadic(x1) ∧ innerFold(env)`.

This is **the same arity-4 → arity-3 re-bounding obstruction documented at NfMultiAnchorBridge:1622-1646**
(the "irreducible arity-4 residual… no `VecEA2 1` monadic component can supply it; requires a NAVIGATED
arity-3 characteristic — exactly what G6 bars") that killed the plan-v2 Phase-8 direct carrier. It
resurfaces here at the **outer** quant layer. Consequence: **the engine cannot be a verbatim lift; it
needs route β (the E[Σ] `efold_of_nfk` outer fold), which the landed `efold_of_nf1`/`nf_eval_nf1_iff_efold`
(NfEFold:472/490) make plausible but do not yet provide.** This is why P1 (provability gate) is
mandatory and cheap-first.

**Counter-evidence that it IS provable (why MEDIUM-HIGH not LOW):** (a) `nf_quant_layer_fold_k1_gate`
folds ∃x1 over depth-0 subs successfully DESPITE the same fresh-var/zoneHolds coupling — because
depth-0 content is exhausted by the atom layer. The depth-1 obstruction is confined to the *extra*
quant layer, which `efold_of_nf1` already renders at constant arity. (b) `nf_eval_unique` is already
generic over k (NormalForm:245), so the off-fiber clause lifts for free. (c) the carrier is already
typed for depth-1 monadic χ (`charK : NormalForm sig 1 1 → Formula`), so there is no type barrier at
the consumption site — confirmed by `kvE_subBracket2V_sound_of_parts`.

---

## Dependency-Ordered Prerequisite Task List

```
P1 (provability gate, SMALL)  ─────────────┐
                                            ▼
P2 (engine, MED-HIGH) ────────┐     [GO from P1 required]
                              ▼
P3 (5-zone dischargers) ──────┼──► 321 v6 Phases 9-14 ──► Phase 15 (F4, no new infra) ──► GO
     (consumes P2 statement)  │
Task 326 (LANDED, interior) ──┘
```

| Task | Title | Type | Depends | Difficulty | Spawn vs 321-phase |
|---|---|---|---|---|---|
| **P1** | Provability determination for the depth-2 outer quant-layer fold: does `nf_quant_layer_fold_k2_gate` fold cleanly, and by which route (naive `nfk`-split-kit vs E[Σ] `efold_of_nfk` vs new argument)? Deliverable: a proven proof-of-concept skeleton OR a machine-grounded NO-GO. | lean4 (research+PoC) | — | HIGH (uncertain), SMALL scope | **MUST SPAWN** — cheap make-or-break BEFORE P2/P3 |
| **P2** | Build the depth-1 split-kit (Layer 2) + land `nf_quant_layer_fold_k2_gate` (Layer 1), both directions, per P1's chosen route. | lean4 (impl) | P1 (GO) | MED-HIGH | **MUST SPAWN** — reusable engine, out of 321's reuse budget |
| **P3** | Non-interior 5-zone per-(zone,χ) dischargers (Layer 3): `zPastX/zAtX/zAtW/zAtT/zFutT`, soundness + completeness, via `epL`/`epR`/`ptW` since-until/point channels. | lean4 (impl) | P2 (statement) | MED-HIGH | **MUST SPAWN** — substantial novel content (5 zones × 2 directions), structurally distinct from 326 |
| 321 v6 | Insert an engine-consumption phase before Phase 10; Phases 9-14 consume P2 + P3 + 326; Phase 15 unchanged. | lean4 (impl) | P2, P3 | MED | 321-internal (v6 revision) |

**"Separate task" vs "321 v6 phase" determination:**
- P1, P2, P3 are **separate spawned tasks** — each a bounded, reusable lean4 deliverable outside
  321's "reuse landed assets" budget (matching the Phase-10 F-house finding "plan-level scope gap,
  NOT inside Phase 10's reuse-landed budget").
- The engine *consumption* (feeding qnf, threading the 7 per-zone dischargers into the outer `∀ sub`
  statement, assembling `bracketEndChar_kvE2_sound` / the completeness half) **stays inside 321 v6**
  as Phases 9-14, since it is plumbing over landed statements.

---

## Adversarial Self-Verification (H4, MANDATORY)

I attempted to REFUTE "this prerequisite set is COMPLETE" — actively hunting for a fourth hidden
layer beneath P1/P2/P3.

### Claim Verification Table

| Claim | Source / Counterexample tried | Verification Method | Verdict / Confidence |
|---|---|---|---|
| The handoff's single "fold engine" is the ONLY missing piece | Grep for `nfk_assemble`/`nfk_dropFresh`/`nfk_zoneSpec` → **none exist**; only `nf0_*` + `nfk_projFresh`. The engine has no foundation. | `lean_local_search`/grep miss | **REFUTED** — Layer 2 (split-kit) is a second missing layer. High |
| The fold engine is a mechanical `0→1` lift | Traced `nf_eval_depth1_fold_iff`:5344 → the inner fold couples x1 to `zoneHolds (cons x env)`; matches the documented arity-4 barrier :1622-1646 | signature trace + doc cross-ref | **REFUTED** — naive `nf_eval_nf1_cons_factor` likely FALSE; needs E[Σ] route. High |
| Task 326 covers the whole quant layer | Read `sound_of_outer`:7910 `hbelow`/`hgate` — name ONLY `kvE_sub2_zXU`; `sound_of_parts`:7719 `hbelow` restricted to `nf0_assemble kvE_sub2_zXU`. | `lean_hover_info`-confirmed signature | **REFUTED** — 5 non-interior zones uncovered (Layer 3). High |
| The 5 non-interior zones are all pin-reachable | Zone table: `zPastX` (x1<x) and `zFutT` (x1>t) are OUTSIDE the pin's `(x,w_outer)⊂(x,t)` reach (task-326 report §Make-or-Break: pins are LEFT witnesses `<w_outer`) | zone-spec `mk3` decode + 326 report | **CONFIRMED counterexample** — exterior zones provably need since/until channels, NOT pins. High |
| There is a fourth hidden layer beneath the split-kit | Split-kit bottoms out at `nf_eval_unique` (NormalForm:245, **generic over k** by induction — read the proof) + the depth-0 kit (landed) + efold transport (landed). No further missing primitive. | `nf_eval_unique` proof read (generic) | **NOT FOUND** — recursion bottoms out at landed generic assets. Medium-High |
| The engine's depth-1 monadic χ needs a further sub-fold | χ : `NormalForm sig 1 1`; `nf_eval_nf M 1 1 (fun_=>v) χ` unfolds via `nf_eval_depth1_fold_iff` at n=1 — **already landed**; carrier `charK`domain matches (`sound_of_parts`) | signature match | **NOT a new layer** — recursion bottoms out on landed `depth1_fold_iff`. Medium-High |
| Stage D needs something beyond `_complete` + the engine | `_complete`:8159 is interior-only (same zXU restriction as soundness); Stage D forward direction needs the engine + Layer-3 completeness dischargers | signature trace | **CONFIRMED** — same Layer-1 + Layer-3 pair; no NEW layer beyond soundness's. High |
| Phase 15 F4 needs new infrastructure | Phase 15 tasks = concrete ℤ instantiation vs the closed gate; discrimination landed Phase 7; only needs σ.2 retention (Layer 1 guarantees) | plan Phase 15 read | **REFUTED** (of "needs infra") — F4 is a consumer, no new engine. High |
| The engine is SHARED across Stage C and Stage D | Soundness: engine backward (bits→realization). Completeness: engine forward (realization→bits). Same `nf_quant_layer_fold_k2_gate` Iff, both directions. | fold-Iff structure | **CONFIRMED** (handoff claim verified). High |
| P1/P2/P3 route risks an F4-flattening relapse | The blocked-lift proof shows forcing a naive factor re-invokes the navigated arity-4 characteristic G6 bars. P1's job is to certify route β (efold, constant-arity) avoids it BEFORE P2. | doc :1622-1646 + efold design | **PARTIALLY SUPPORTED (Medium)** — the relapse risk is REAL and is precisely why P1 is a gate; not retired, isolated |

### Contradiction Log

**Contradiction with the Phase-10 handoff (RESOLVED by machine evidence).** The handoff
(`next_action_hint`, `what_is_needed`) frames the remaining work as a SINGLE "general-j=1
quant-layer fold engine." Machine evidence (grep: `nfk_assemble`/`nfk_dropFresh`/`nfk_zoneSpec`
absent; `sound_of_outer`/`complete` interior-only; exterior zones outside pin reach) shows the
remaining work is **three layers** (engine + split-kit + 5-zone dischargers). **Resolution via
precedence (machine source > prior handoff summary):** the handoff correctly identified Layer 1 as
the proximate blocker but under-counted the depth beneath it and the breadth beside it. No UNRESOLVED
contradiction remains; the residual uncertainty is confined to P1 (does Layer 1 fold cleanly, and by
which route).

### Recommendations modified after verification

- **Initial instinct** (spawn one "fold engine" task per the handoff hint). **Retracted** — the
  engine has no landed foundation (Layer 2) and does not cover 5 of 7 zones (Layer 3). One task
  would re-hit prerequisites one layer at a time — exactly the pattern this pass exists to break.
- **Revised to 3 tasks** with P1 as a cheap provability gate FIRST, because the engine's clean-fold
  provability is unestablished and a naive lift is blocked (risking an F4-flattening relapse). Gating
  P2/P3 investment behind P1 prevents the largest wasted-effort failure mode.

### Completeness confidence

**MEDIUM-HIGH.** The map now bottoms out at landed generic assets (`nf_eval_unique` generic over k;
depth-0 kit; `efold_of_nf1`/`nf_eval_nf1_iff_efold`; `nf_eval_depth1_fold_iff` for the inner monadic
recursion), and I actively searched for a fourth layer and did not find one. The single open question
— whether Layer 1 folds cleanly and by which route (naive vs efold vs new) — is deliberately isolated
into P1 as a make-or-break gate rather than left as a hidden risk. The two residual MEDIUM risks are
named and localized: (a) `nf_eval_nf1_cons_factor` clean-form provability (mitigated by route β), and
(b) the exterior-zone (`zPastX`/`zFutT`) since/until dischargers in Layer 3. Neither is a NEW layer;
both are scoped inside P1/P3.

---

## Recommendation — concrete spawn plan + v6 shape

**Spawn 3 prerequisite tasks, topologically ordered:**

1. **P1 first (gate)** — `/spawn 321 'provability determination: does nf_quant_layer_fold_k2_gate
   (arity-4/depth-1 outer quant-layer fold) fold cleanly, via naive nfk-split-kit, E[Σ] efold_of_nfk,
   or a new argument? Deliver a proven PoC skeleton or a machine-grounded NO-GO with the exact
   failing goal.'` — HARD, `--lit`. Cheap, decisive; do NOT start P2/P3 until P1 returns GO + a route.
2. **P2 (engine)** — depends on P1 GO. Build Layer 2 (depth-1 split-kit or `efold_of_nfk`) + land
   `nf_quant_layer_fold_k2_gate` both directions.
3. **P3 (5-zone dischargers)** — depends on P2's statement. Non-interior exterior/boundary
   per-(zone,χ) closers, soundness + completeness.

**Task 321 v6 revision shape** (via `/revise 321` after P2 lands, or after P1 GO to lock the phase
skeleton):
- Insert **Phase 9.5 "engine consumption"** before Phase 10: fold `qnf.2` via
  `nf_quant_layer_fold_k2_gate` to reduce the outer `∀ sub` conjunct to the per-(zone,χ) obligations
  across all 7 zones.
- **Phase 10** becomes: discharge the 7 per-zone obligations — 2 interior via task 326
  `sound_of_outer` (unchanged), 5 non-interior via P3's `..._sound_of_outer` closers, off-fiber via
  `kvE_gate`/`nf_eval_unique` — then assemble `bracketEndChar_kvE2_sound`.
- **Phases 11-14** (Stage D): engine forward direction + P3's `..._complete` closers +
  `kvE_subBracket2V_complete` (interior) → GO.
- **Phase 15** unchanged (F4 ℤ; no new infra).
- **Binding constraints carried:** all P2/P3 infrastructure is PURELY ADDITIVE; `kvE2_body` /
  `bracketEndChar_kvE2` / `kvE_subChain2V` splice byte-identical to `8448ea135`; task-325 VVecEA2 /
  task-326 pin-slot lemmas / `BracketCarrierCorrectVPrior` / EANegation / F1-F4 records untouched;
  every proposed discharger's reconstruction rides evaluation-point/structural position (since/until
  reach, bracket monotonicity, zone spec), **never an `x1 < e_i` literal** (litmus enforced).

---

## Literature Grounding (`--lit`) — Rabinovich 2014 §5

- **Normal-form characterization / Cor 5.4 (md:154-157), Prop 4.3 E[Σ]-fold (PDF p.6).** The
  general-j fold engine (Layer 1) IS the machine encoding of Rabinovich's normal-form characterization
  at one higher quantifier depth. The construction is **recursive in quantifier depth**, so a
  depth-2 outer fold has a faithful analog — the zone reconstruction (`nfk_assemble`) is precisely
  the Def-3.1/Def-4.1 "each existential point pinned by its zone + type" characterization lifted one
  level. **The quant-layer fold across zones DOES have a faithful analog in the prior art.**
- **Lemma 5.1 point-insertion (md:169-171) + Lemma 5.3 INF splitting (md:137-152).** Underwrite the
  per-zone dischargers (Layer 3): the exterior since/until and boundary-point channels realize the
  "boundedness via a structural/shared endpoint" principle (the pin route's basis, task-326 report
  §Literature), now extended to the 5 non-interior zones. The exterior zones' witnesses are positioned
  by since/until REACH (Cor 5.4 evaluation-point positioning), faithful to the prior art and **not** a
  relative-position assertion.
- **No proposed piece departs from the prior art.** The one place a departure could sneak in is a
  forced naive factorization (Layer 2 `nf_eval_nf1_cons_factor`) that re-introduces a navigated
  arity-4 characteristic — which Rabinovich's constant-arity E[Σ]-fold (Def 4.1) explicitly avoids.
  P1 exists to certify the E[Σ] route and keep the construction faithful (no F4-flattening relapse).

---

## Stale-Reference Correction (for downstream artifacts)

Prior-artifact line numbers were stale after tree renumbering. Verified current lines:

| Symbol | Stale ref (prior artifacts) | **Verified current** |
|---|---|---|
| `nf_eval_depth1_fold_iff` | :5187 / :5344 (mixed) | **NfMultiAnchorBridge:5344** (only decl) |
| `kvE_subBracket2V_complete` | :7717 / :7783 | **:8159** |
| `kvE_subBracket2V_sound_of_parts` | :7449 | **:7719** |
| `kvE_subBracket2V_sound_of_outer` | :7910 | **:7910** (correct) |
| `kvE_subChain2V` | :6757 | **:6955** |
| `kvE_consistentZones` / `kvE_pinArrangements` / `kvE_pinDisjunct` | :5364 / :5364-5366 / :5374 | **:5507 / :5521 / :5531** |
| `kvE2_body` (+ zone block) | :5602-5607 | **:8608** (zones :8618-8624; :5602-5607 is `kvE'_body`'s `epR`) |
| `kvE_consistent` | :5157 | **:5157** (correct) |
| `nf_quant_layer_fold_iff` / `_k1_gate` | NfEFold:391 / :525 | **NfEFold:391 / :525** (correct) |
| `nf0_assemble` | — | **NfEFold:180** |
| `nfk_projFresh` | :3511 | **:3668** |
| `nf_eval_unique` | — | **NormalForm:245** (generic over k) |
| `nf_eval_nf` / `NormalForm` | :198 | **NormalForm:198 / :134** |
