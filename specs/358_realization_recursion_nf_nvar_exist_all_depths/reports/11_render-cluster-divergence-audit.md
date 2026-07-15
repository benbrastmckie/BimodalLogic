# Task 358 — Divergence Audit (H5): the render/hreal/firing cluster

Session: sess_1784078566_52d1da · Agent: lean-research-hard-agent (H5 divergence-audit mode)
Date: 2026-07-14 · Focus: `divergence audit ambient-render-bridge`

## Verdict (headline)

**(C) NEITHER the transducer route (A) NOR the joint-production route (B) is constructible
from existing infrastructure.** Every path from the row-5 interior site to the `σ`-realizer
cycles through the mutually-derivable triple **{σ-realizer, `kvE_futPos` firing, deep render}**,
and *none* of the three has a landed base producer from the non-circular inputs available at the
site (`hAmb` syntactic guard, `igPtW@w` = AtW-zone-only lossy fold, `P : ExistProviders … k` =
depth-`k` saturation). The precise missing infrastructure is a **depth-`(k+1)` saturation firing
supply** (statement in §Corrected Target). Recommendation: `/spawn 358` a dedicated infra task
with that exact target. Do NOT re-dispatch Phase 5 against the current binder — it is provably
under-provisioned (F1 lossy-fold refutation).

---

## Divergence table (three prior dispatches: premise assumed vs. machine fact that refuted it)

| Dispatch | Premise it assumed | Machine fact that refuted it | Source |
|----------|--------------------|------------------------------|--------|
| **v07 / Phase 4** (`phase-4-handoff`) | The general-`m` rows-12-13 exterior exclusion supply can be discharged at its own site; render is a *precursor* available from `hAmb`+igPtW. | The render `nf_eval_nf M (k+2) 3 [w,x,t] qnf` is the **conclusion** of the interior realization, not a precursor: it is produced only by `bracketEndChar_kv_step_sound … (hreal)(hexcl)` — wave inversion. | `ExteriorGateAssembleK.lean:337-338`; `InteriorGateGeneralK.lean:1043` (step_sound produces `∃w render` from `hreal`/`hexcl`) |
| **v08 / render-adjudication** (`phase-5-handoff`) | The render can be produced **first** (a "cheap de-inverted root") from `hAmb` + igPtW + `kvE_ambientDeepAnchor_iff` + `P.correct` + fold bit. | `kvE_ambientDeepAnchor_iff` unfolds to a purely **syntactic EF-closure** (`∀τ∀ρ∃σ'…`) with no model `M`, no carrier; igPtW renders only the atom layer. Render provably not constructible from Phase-4-local hypotheses. | `ExteriorAmbientDeepAnchorK.lean:131` (readback is `Bool`/`Prop`, no `M`); `kvExt_gate_henv` atom-only, `ExteriorGateAssembleK.lean:61` |
| **v09 / Crux-A** (`phase-5-crux-a-handoff`) | The row-5 `hreal` can be fired by "fold bit fires `kvE_{fut,past}Pos`", drivers select `x1`, IH from `P` closes — a separable upstream root. | The only fold-bit→realizer bridge `igFoldBit_realize_iff` **requires the render** as hypothesis `h`; and the only `kvE_futPos` producer `kvE_futPos_of_realizer` **requires the `σ`-realizer** as hypothesis `hσ`. Both firing routes are circular. | `InteriorGateGeneralK.lean:563` (needs `h : nf_eval_nf M (k+1) 3 [w,x,t] qnf`); `ExteriorPinnedConverseK.lean:252` (needs `hσ`) |

---

## Postmortem — the single shared root cause

**All three dispatches assumed the interior `σ`-realizer (or its firing, or the render) is
recoverable from the carrier content exposed at the interior anchor `w` — but the `igFoldBit`
fold is lossy (finding F1), so the model witness for a specific arity-4 fiber `σ` is *not present*
in any hypothesis available at that site.**

Concretely: `igPtW@w` (def `InteriorGateGeneralK.lean:243`) carries only
`igLit (b igZAtW χ) (charK χ)` — the **AtW zone**, over depth-`k` **1-types** `χ : NF k 1`. The
future/past endpoint firings live in `igEpR@t` / `igEpL@x` as `Until(charK χ, top)` /
`Since(charK χ, top)` (`InteriorGateGeneralK.lean:209/219`) — again over **1-types `χ`**, the
*lossy fold projection* of `qnf`'s arity-4 fibers `σ`. Recovering the arity-4 `σ`-realizer from a
1-type firing is exactly what `igFoldBit_realize_iff` does, and it needs the render. The render
needs `hreal`. `hreal` needs the realizer. The cluster is closed with **no external base**.

The v08 and v09 handoffs' shared prescription — "produce `hreal`+`hexcl`+render **jointly**" —
does not dissolve the cycle: the render's fiber layer *is* the `hreal`/`hexcl` biconditional
(step_sound delegates `h.2 sub` entirely to them, `InteriorGateGeneralK.lean:1150-1165`), so
"joint" production still requires the missing `σ`-level firing/realizer. The missing ingredient is
orthogonal to *grouping*; it is a *level* ingredient (depth-`(k+1)` saturation) that no binder
currently threads.

---

## Machine-grounded answers to the four audit questions

### Q1 — Transducer feasibility: does a non-circular `igFoldBit → kvE_{fut,past}Pos` firing route exist?

**No.** Enumeration of every landed lemma that produces `kvE_{fut,past}Pos` or fires the fold bit,
with exact hypotheses:

| Lemma | Location | Produces | Required hypothesis | Avoids render/realizer? |
|-------|----------|----------|---------------------|-------------------------|
| `igFoldBit_realize_iff` | `InteriorGateGeneralK.lean:563` | `∃u, zoneHolds ∧ realize χ` from fold bit | `h : nf_eval_nf M (k+1) 3 [w,x,t] qnf` (= the deep render) | **NO** (render-gated) |
| `kvE_futPos_of_realizer` | `ExteriorPinnedConverseK.lean:252` | `temporal_truth M t (kvE_futPos P σ)` | `hσ : nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` (= the σ-realizer) | **NO** (realizer-gated) |
| `kvE_futGapD_of_realizer`, `kvE_futEnd_of_realizer` | `ExteriorPinnedConverseK.lean:267/291` | gap / endpoint truth | `hσ` (σ-realizer) | **NO** (realizer-gated) |
| `kampPrior_futRealizer_of_pos` (driver, consumer not producer) | `KampPrior.lean:1662` | σ-realizer | **`hpos : temporal_truth M t (kvE_futPos P σ)`** + depth-`k` `hreal`/`hsat` from `P` | driver itself avoids render, but **consumes the firing it cannot produce** |

A **grep for any theorem whose conclusion is `temporal_truth _ _ (kvE_futPos …)`** returns exactly
one producer, `kvE_futPos_of_realizer`, which is realizer-gated. **There is no producer of the
firing that avoids the realizer or the render.** So the transducer's *input* (`hpos`) is itself
unproduced. Q1 = negative.

The driver `kampPrior_futRealizer_of_pos` *does* route its type-realization inputs through the
depth-`k` IH (`P`): its `hreal`/`hsat` params are depth-`k` fiber facts dischargeable from
`P.correct` (`PriorInterface.lean:38-46`). But its firing input `hpos` is not — that is the whole
gap.

### Q2 — Joint-production feasibility, and how rows-8-9 actually get their render

**Rows-8-9 do NOT produce the render — they consume it.** Traced concretely:

- Rows-8-9 binders `hslicePast`/`hsliceFut` (`KampPrior.lean:990/997`) **lead with**
  `nf_eval_nf M (k+2) 3 [w,x,t] qnf →` and additionally take
  `temporal_truth M atomMap {t|x} (kvE_{fut,past}Pos Pbr σ) →` — i.e., **both the render and the
  firing are hypotheses**.
- Their sole application site is the **⇐ direction** of `bracketEndChar_kvExt_correct_prior`
  (`ExteriorGateAssembleK.lean:395-427`), where the render `h : nf_eval_nf M (k+2) 3 [w,x,t] qnf`
  is the **antecedent being characterized** (given, not built). There, the firing is produced by
  reading the realizer straight off the render: `obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit`
  (`ExteriorGateAssembleK.lean:401/420`). No non-circular producer is involved — the render is
  simply assumed on that branch.
- The only place the render is *built* is the **⇒ direction** (`step_sound`,
  `ExteriorGateAssembleK.lean:337`), which builds it from `(hreal hGuard)(hexcl hGuard)` — the
  rows-5-6 obligations. `step_sound` reconstructs only the render's **atom layer** from the
  endpoint depth-0 types (`hxT`/`htT`, `InteriorGateGeneralK.lean:1113-1140`) and delegates the
  entire **fiber layer** to `hreal`/`hexcl` (`:1150-1165`, `exact hreal w hxw hwt hptWe sub hmark`).

Therefore there is **no third, non-circular producer of the render**. "Joint production of
`hreal`+`hexcl`+render at `[w,x,t]`" collapses, mathematically, to *producing the fiber realizer*
— which is `hreal` itself — so it re-encounters the identical missing firing. No landed
`step_sound`-adjacent constructor produces the fiber layer independently. Q2 = negative for a
constructible joint route from existing infra.

### Q3 — Rabinovich fidelity (rabinovich_2014, Cor 5.4(1)⇐ chunk_0015; Lemma 5.3 chunk_0014)

The paper produces the witness by a **separable induction that fires directly off an `Until`
formula**, not via any folded/`kvE_futPos`-style intermediary:

> "By the inductive assumption there is `y1 ∈ (z0, xn+1)` such that
> `[…, (αn ∧ βn+1 Until αn+1)](z0, y1)`. In particular, `y1` satisfies `(αn ∧ βn+1 Until αn+1)`.
> **Hence, there is `y2 > y1` such that `y2` satisfies `αn+1`** and `βn+1` holds along `(y1, y2)`."
> — chunk_0015, lines 23-29

The future witness is extracted **directly from the `Until` formula's temporal semantics** — which
is precisely the shape carried by `igEpR@t = Until(charK χ, top)`
(`InteriorGateGeneralK.lean:219`). Rabinovich **never folds** the interior population into
zone×1-type bits; he carries the full ordered bracket sequence `[α0,β1,α1,…,βn,αn]`, so his `Until`
firing reconstitutes the *full* next type, not a lossy 1-type projection. Lemma 5.3 (chunk_0014) is
likewise a clean induction on `n` producing a `∨⃗∃∀` formula — no separate saturation oracle.

**Fidelity conclusion:** the plan's `kvE_futPos` firing layer is a **deviation** from the source.
The paper's route is the endpoint-`Until` firing (route toward (A)), but it is faithful **only
without the `igFoldBit` fold**. The Lean encoding's fold (F1-lossy) is exactly the divergence that
makes the paper's `Until`-firing insufficient to rebuild the arity-4 `σ`, forcing the render and
the cycle. This points the fix at *de-folding / carrying the full fiber* rather than at inventing a
new firing oracle.

### Q4 — Verdict: (C), with the precise missing infrastructure

See Corrected Target below.

---

## Corrected target definition — Verdict (C): missing infrastructure

The cycle has no landed base. Two structurally-distinct new lemmas can each break it; the audit
recommends the first (Rabinovich-faithful) and records the second as fallback.

### Missing lemma **M1** (recommended, Rabinovich-faithful): endpoint-`Until` firing supply

The `σ`-realizer must be produced from the **endpoint firing the carrier actually provides**
(`igEpR@t` / `igEpL@x`, the `Until`/`Since` formulas) plus the **depth-`(k+1)` saturation IH** of
the main recursion — NOT from `igPtW@w` alone and NOT from the render. This requires **enriching
the row-5 `hreal` binder** to carry the endpoint evals (which `step_sound` already destructs and
currently discards) and threading the recursion IH.

Target signature (lives in a new leaf downstream of `KampPrior`, e.g.
`NfMultiAnchorBridge/InteriorEndpointFiringSupplyK.lean`; `step_sound` and
`bracketEndChar_kv_step_correct` signatures grow the two endpoint hypotheses):

```
theorem kvE_futPos_supply_of_endpoint
    {sig : MonadicSignature} {k : Nat}
    (P : ExistProviders sig atomMap k)               -- depth-k fibers of σ
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (k + 2) 3) (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hepR : (igEpR (nf_depth0_char_formula atomMap h_surj) (charF (k+1)) qnf.1
              (igFoldBit qnf)).eval_at M atomMap t)   -- the Until firing at t (carrier-provided)
    (hAmb : kvE_ambientDeepAnchor qnf = true)         -- syntactic EF-closure (fiber consistency)
    (σ : NormalForm sig (k + 1) 4) (hmark : qnf.2 σ = true)
    (hcons : kvE_fiberConsistent σ = true) (hfut : kvE_futAdmissible σ = true) :
    temporal_truth M atomMap t (kvE_futPos P σ)
```

with the past mirror `kvE_pastPos_supply_of_endpoint` (using `hepL`/`igEpL`/`Since`). Given
**M1**, the row-5 `hreal` discharges with **zero new circularity**:

```
kampPrior_hreal_supply (enriched with hepL, hepR):
  intro … σ hmark hcons
  -- zone split on σ (fut / past / interior)
  · exact (kampPrior_futRealizer_of_pos P M h_UZ h_SZ σ w x t
             (hreal_depthk_from_P …)               -- depth-k, from P.correct  (no render)
             (hsat_depthk_from_P …)                -- depth-k, from P.correct  (no render)
             (kvE_futPos_supply_of_endpoint … hepR hAmb σ hmark hcons hfut)  -- M1 (no render)
          ).choose_spec …
```

**Dependency sketch (M1 route) — no cycle:**

```
  igEpR@t (Until, from `holds`, destructed by step_sound)
        │  M1 (new)                         P.correct  (depth-k IH, PriorInterface.lean:46)
        ▼                                        │
  kvE_futPos P σ  ────────────┐                  ▼
                              ▼           depth-k fiber realizers of σ
             kampPrior_futRealizer_of_pos (KampPrior.lean:1662, landed)
                              │
                              ▼
             σ-realizer  nf_eval_nf M (k+1) 4 [x1,w,x,t] σ     (row-5 hreal DISCHARGED)
                              │  step_sound (InteriorGateGeneralK.lean:1043, landed)
                              ▼
             render  nf_eval_nf M (k+2) 3 [w,x,t] qnf
```

No arrow re-enters `igEpR@t` from below: the render is a *sink*, the firing comes from the
carrier-provided `Until` (a genuine model fact on the `⇒` branch), and the depth-`k` realizers come
from `P`. **The cycle is broken because M1 sources the firing from `igEpR@t`, not from the render
or the σ-realizer.**

**Why M1 is non-trivial (the F1 obstruction it must overcome):** `igEpR@t` fires only the
**1-type** `charK χ`. M1's proof obligation is to show that under `hAmb` (EF-closure) +
`hcons`/`hmark` (fiber consistency), the 1-type witness the `Until` provides can be *upgraded* to a
witness of the full arity-4 `σ` — i.e., to bridge the fold loss using the deep-anchor closure and
the depth-`(k+1)` saturation of `M`. This upgrade is the genuine new mathematics and is the single
reason the task is not a mechanical re-wire.

### Fallback lemma **M2** (if the fold cannot be bridged at the endpoint): de-fold render kernel

If M1's 1-type→4-type upgrade is not provable from `hAmb` alone (i.e., the fold loss is
irreparable without more), the alternative is a **de-folded interior carrier** that keeps the full
arity-4 fiber content at the endpoints (a non-`igFoldBit` variant of `igEpR`/`igPtW`), making the
render's fiber layer directly readable. This is a larger refactor of `InteriorGateGeneralK.lean`
(carrier redesign) and should be scoped only if M1 is refuted.

### Recommended action

`/spawn 358` an infrastructure task: **"Interior endpoint-`Until` firing supply (M1): produce
`temporal_truth M t (kvE_futPos P σ)` from `igEpR@t` + deep-anchor closure + depth-`k` `P`,
bridging the `igFoldBit` 1-type→arity-4 fold loss; enrich `bracketEndChar_kv_step_sound` /
`bracketEndChar_kv_step_correct` binders with the `hepL`/`hepR` endpoint evals."** The current
`kampPrior_hreal_supply` statement (`InteriorHrealSupplyK.lean:60`) is retained and re-dispatched
only after M1 lands and the binder is enriched.

---

## Reference-grounding table (H3, Tier 1 — literature + landed source)

| # | Load-bearing claim | Source (lemma name + line, or corpus chunk) |
|---|--------------------|---------------------------------------------|
| 1 | `igFoldBit_realize_iff` requires the deep render as hypothesis `h` | `InteriorGateGeneralK.lean:563-567` (`h : nf_eval_nf M (k+1) 3 [w,x,t] qnf`), hover-confirmed |
| 2 | `step_sound` produces `∃w render` from `(hreal)(hexcl)`; delegates fiber layer to them | `InteriorGateGeneralK.lean:1043` (sig), `:1150-1165` (`exact hreal …`); applied `ExteriorGateAssembleK.lean:337` |
| 3 | `igPtW@w` carries only the AtW zone over 1-types | `InteriorGateGeneralK.lean:243` (`igLit (b igZAtW χ) (charK χ)`) |
| 4 | `igEpR@t` carries the FutT firing as `Until(charK χ, top)` (1-type); `igEpL@x` as `Since` | `InteriorGateGeneralK.lean:219` / `:209` |
| 5 | Only firing producer is `kvE_futPos_of_realizer`, realizer-gated (`hσ`) | `ExteriorPinnedConverseK.lean:252` |
| 6 | Rows-8-9 consume both render and firing as hypotheses; get them from the ⇐ render antecedent | `KampPrior.lean:990/997`; `ExteriorGateAssembleK.lean:395-427` (`(h.2 σ).mpr`) |
| 7 | `kvE_ambientDeepAnchor_iff` is a syntactic EF-closure with no `M` | `ExteriorAmbientDeepAnchorK.lean:131` (per handoffs; consistent with §Q divergence) |
| 8 | `P.correct` realizes depth-`k` arity-`(n+1)` types (the depth-`k` IH) | `PriorInterface.lean:38-46` (`ExistProviders.correct`) |
| 9 | Driver `kampPrior_futRealizer_of_pos` needs `hpos` firing + depth-`k` `hreal`/`hsat`; NOT the render | `KampPrior.lean:1662-1710` |
| 10 | Rabinovich Cor 5.4(1)⇐ fires the witness `y2` directly from `βn+1 Until αn+1` | rabinovich_2014 chunk_0015, lines 23-29 |
| 11 | Rabinovich carries the full ordered bracket sequence (no fold) — Lemma 5.3 induction on `n` | rabinovich_2014 chunk_0014, lines 5-41 |
| 12 | Fold is lossy (clean biconditional refuted at k≥2; ".holds but not the realizer") — F1 | `InteriorGateGeneralK.lean` section note ≈:1178-1188; `CarrierKv.lean:422` (`bracketEndChar_kv_factors`) |

---

## Adversarial Self-Verification (H4)

I attempted to refute my own (C) verdict — specifically, whether any proposed route actually avoids
the `render → hreal → render` cycle, and whether an existing lemma secretly closes it.

| Claim | Source / Counterexample tried | Verification method | Verdict |
|-------|-------------------------------|---------------------|---------|
| No landed lemma produces `temporal_truth M t (kvE_futPos P σ)` except realizer-gated ones | Grepped all theorems concluding `kvE_futPos`; found only `kvE_futPos_of_realizer` | `lean_hover_info`-confirmed signature (`hσ` required), grep exhaustive | **Holds** (High) |
| The M1 route avoids the cycle | Tried to find a hidden back-edge from `igEpR@t` to the render | Traced: `igEpR@t` comes from `holds` (destructed by step_sound), independent of the render output | **Holds** — render is a sink; M1 sources firing from carrier `Until`, not render (High) |
| "Joint production" (B) is not a real escape | Checked whether a joint lemma could produce the render without the fiber biconditional | step_sound's fiber layer = `hreal`/`hexcl` verbatim (`:1150-1165`); no independent fiber producer exists | **Holds** (High) |
| The render for rows-8-9 has NO non-circular upstream producer | Searched all `hsliceFut`/`hslicePast` application sites | Only site is the ⇐ branch where render is the given antecedent (`ExteriorGateAssembleK.lean:395`) | **Holds** (High) |
| M1 is genuinely constructible (not itself blocked) | **Could not fully verify** — M1's 1-type→arity-4 upgrade from `hAmb` is unproven | Attempted `lean_multi_attempt` reasoning deferred; `hAmb` is syntactic, upgrade needs saturation | **UNRESOLVED RISK** — see below (Medium) |
| Rabinovich fires from `Until`, not a saturation oracle | Re-read chunk_0015 inductive step | Direct quote lines 23-29 | **Holds** (High) |
| The fold (`igFoldBit`) is the divergence point | F1 note + Rabinovich carries full sequence | Cross-checked `CarrierKv.lean:422` note against chunk_0014 | **Holds** (High) |

**UNRESOLVED RISK (downstream):** I could not machine-verify that M1's core obligation — upgrading
the `igEpR@t` 1-type `Until` witness to a full arity-4 `σ`-witness using only `hAmb` (syntactic
EF-closure) + `hcons` + depth-`(k+1)` saturation — is *provable*. If it is **not** provable (the
fold loss is irreparable at the endpoint), verdict shifts from "(C) with M1 recommended" to "(C)
with **M2** (de-folded carrier) required", a substantially larger refactor. The `/spawn 358` infra
task must therefore **first adjudicate M1's upgrade obligation** (a bounded `lean_multi_attempt`
gate on the 1-type→4-type step under `hAmb`) before committing to the enrichment wiring. This is
the resolving check not yet performed; it does not affect the (C) verdict (no existing infra
closes the gap either way) but determines which corrected target (M1 vs M2) the next dispatch
pursues.

**Recommendations modified after verification:** the original crux-A handoff's memory candidate
("produce interior realizer + render jointly") is **downgraded** — jointness is not the missing
ingredient; the missing ingredient is a *level* ingredient (endpoint-`Until` firing supply bridging
the fold), and it must be a *separate* new lemma (M1), not a re-grouping of the existing three
obligations.

---

## Files inspected (machine grounding)

- `Theories/.../NfMultiAnchorBridge/InteriorHrealSupplyK.lean` (landed crux-A leaf, `:60`/`:116`)
- `Theories/.../NfMultiAnchorBridge/InteriorGateGeneralK.lean` (`:209/:219/:243` ig defs, `:563` fold bridge, `:1043` step_sound, `:1150-1165` delegation, F1 note)
- `Theories/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` (`:337` render production, `:395-427` ⇐ render antecedent)
- `Theories/.../NfMultiAnchorBridge/ExteriorPinnedConverseK.lean` (`:252` `kvE_futPos_of_realizer`)
- `Theories/.../Kamp/KampPrior.lean` (`:964-970` rows 5-6, `:990/997` rows 8-9, `:1662/1721` drivers, `:1140` ExistProviders shim, `:505-525` main-recursion sorries)
- `Theories/.../NfMultiAnchorBridge/PriorInterface.lean` (`:38-46` `ExistProviders.correct`)
- rabinovich_2014 chunk_0014 (Lemma 5.3), chunk_0015 (Cor 5.4(1)⇐)
