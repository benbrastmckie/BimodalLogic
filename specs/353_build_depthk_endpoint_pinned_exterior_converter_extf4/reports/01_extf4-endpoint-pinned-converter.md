# Task 353 — Depth-k Endpoint-Pinned Exterior Converter `extF4`: Research Report

**Agent**: lean-research-agent | **Date**: 2026-07-12 | **Task type**: lean4 | **Topic**: kamp_theorem_formalization
**Grounding tier**: Tier 1 (literature-backed — Rabinovich 2014 Lemma 5.1/5.3, Cor 5.4; task 352 report 03)
**All signatures below verified against LIVE source** (Read + grep; line numbers reconciled, drift flagged).

---

## VERDICT (Deliverable 5, up front): **NO-GO as scoped** — the target surfaces a fresh, source-grounded blocker

The `extF4` / `extF4_correct` deliverable as written in task 352 report 03 Deliverable 4 is **not
buildable as a converter** at the current infrastructure, for a reason one level deeper than the F2
env-transfer impossibility that report 03 already proved:

1. **The literal signature is ill-posed** (unprovable as a `∀`-closed lemma). Written with
   `temporal_truth M atomMap t (extF4 s)` as the LHS, the LHS is a predicate of the SINGLE carrier
   point `t` only (`temporal_truth : … → M.carrier → Formula → Prop`, `Table.lean:182-193`,
   verified). The RHS `∃ y, nf_eval_nf M k 5 (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s`
   depends on the free variables `x1, w, x`. Fixing `t` and varying `x1/w/x`: LHS constant, RHS
   varies ⟹ the `↔` fails in any model where `s` distinguishes the anchor coordinates. **This is
   exactly the F2 impossibility report 03 machine-proved** (`transfer_probe` → residual `⊢ env4 = env'`;
   report 03 §Deliverable 3, lines 143-171). The `temporal_truth` phrasing in Deliverable 4 (report
   03 line 213) contradicts report 03's own transfer_probe result.

2. **The well-posed 4-anchor carrier reformulation contradicts the frozen 2-endpoint architecture.**
   The honest generalization would replace `temporal_truth M atomMap t` with a 4-anchor carrier
   predicate `(extF4 s).holds M atomMap x1 w x t` (mirroring the k=2 carrier, which uses the
   **2-anchor** `VVecEA2.holds M atomMap x t`, NOT `temporal_truth` — see Deliverable 1). But **no
   4-endpoint carrier primitive exists**, and building one is architecturally impossible: the entire
   bracket machinery is fundamentally **2-endpoint** (`VecEA2` has exactly two free variables
   `z0, z1`; `VVecEA2.holds` takes exactly `z0 z1`, `VecEAFormula.lean:252-279`). Even the **arity-4**
   sub-bracket `kvE_subBracket2` exposes only 2 explicit endpoints `(z0, z)` with the interior
   anchors `x1, w` **quantified by the temporal semantics** (Amendment F3, `SubBracket2.lean:336`:
   "the anchor positions are the bracket witnesses, quantified by the temporal semantics"). This is
   Rabinovich's design invariant (Lemma 5.1: point-types quantifier-free; Def 3.1: interior points
   temporally quantified between the two fixed endpoints). A linear-time temporal formula evaluated
   in `M` exposes **1 point** (`temporal_truth … t`) or, as a bracket, **2 endpoints**
   (`.holds … z0 z1`) — never 4 independent pinned points.

3. **The faithful mechanism is NESTED re-anchoring, not a flat arity-5 converter.** Rabinovich pins
   the interior witness as `r0 = inf{z ∈ (z0,z1) | P1(z)}` (Lemma 5.3 Case 2/3) and **re-anchors it as
   the endpoint** of the recursive sub-bracket `On(P2,…,Pn, r0, z1)`. Depth is carried by **nesting
   2-endpoint brackets**, not by a flat 4-anchor object. A flat `extF4 : NormalForm sig k 5 → Formula`
   with all four `[x1,w,x,t]` pinned misrepresents this recursion; the faithful object is a recursive
   nested-bracket construction (much larger than "build a converter").

**Consequence for task 352**: the two `_complete` halves (`kvE_extNegFut_complete`,
`kvE_extNegPast_complete`) **cannot** be unblocked by an `extF4` of the specified shape. The
determinacy the reconstruction needs (`hbelowFib`, the per-sub biconditional at the pinned env
`[x1,w,x,t]`) IS expressible and IS partially available (`nf_eval_nfk_iff_efold`, `kvE_subBit_iff`) —
but only as a **determinacy reader conditioned on σ already being realized at `[x1,w,x,t]`**, which is
precisely what the above-`t` gap/self/ray zones lack (`hnorel`). See Deliverable 5 for the two
survivable re-scopes.

---

## Deliverable 1 — Exact signatures, reconciled against live source

### 1a. The k=2 carrier this is supposed to generalize (LANDED, GREEN)

The task description says extF4 generalizes the "k=2 carrier `bracketEndChar_kvE2_*_two_prior` at
`OuterGate.lean:147-359`" and references `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60-73`).
**Both line ranges are ACCURATE.** Reconciled:

**`BracketCarrierCorrectVPrior`** (`PriorInterface.lean:60-73`, verified verbatim). Its correctness
core is (arity-3, **2 anchors pinned, 1 witness quantified**):

```lean
(carrier qnf).holds M atomMap x t ↔
  ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

**CRITICAL RECONCILIATION**: the LHS is `(carrier qnf).holds M atomMap x t` — a `VVecEA2.holds`
predicate taking **BOTH** explicit endpoints `x t` (`VVecEA2.holds : … → (z0 z1 : M.carrier) → Prop`,
`VecEAFormula.lean:276-279`). It is **NOT** `temporal_truth M atomMap t`. Report 03 Deliverable 4's
use of `temporal_truth M atomMap t (extF4 s)` for the arity-5 analog is therefore an **imprecise
transcription** — the faithful analog must use a carrier `.holds` predicate, and the number of
explicit anchors is the crux (see Verdict).

**`bracketEndChar_kvE2_complete_two_prior`** (`OuterGate.lean:147-179`, verified). The ⇐ half,
UNCONDITIONAL:

```lean
(∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
  (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t
```

**`bracketEndChar_kvE2_sound_two_prior_frag`** (`OuterGate.lean:268-334`, verified). The ⇒ half. Note
its interior realization hypotheses `hrealI`/`hrealB` already use the arity-4 pinned env
`Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))` for the SUB `σ : NormalForm sig 1 4`
(`OuterGate.lean:288-311`) — i.e. the `[x1,w,x,t]` tuple already appears, but as a **hypothesis fed
in**, discharged by the 309 Phase-14 provider, NOT produced by the carrier.

**`bracketEndChar_kvE2_correct_two_prior_frag`** (`OuterGate.lean:359+`, verified head): assembled
`holds ↔ ∃ w` gate; mirrors `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`).

### 1b. The requested extF4 (report 03 Deliverable 4, transcribed + reconciled)

Literal (report 03 line 213-215) — **ILL-POSED, see Verdict §1**:

```lean
extF4 : NormalForm sig k 5 → Formula
extF4_correct : temporal_truth M atomMap t (extF4 s) ↔
  ∃ y, nf_eval_nf M k 5 (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s
--                       ^ y quantified; x1,w,x,t PINNED (4 anchors)
```

Well-posed carrier reformulation (what report 03 *meant*, by analogy to 1a) —
**architecturally blocked, see Verdict §2**:

```lean
extF4 : NormalForm sig k 5 → (some 4-anchor carrier type)   -- DOES NOT EXIST
extF4_correct : (extF4 s).holds M atomMap x1 w x t ↔
  ∃ y, nf_eval_nf M k 5 (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s
```

`nf_eval_nf` verified (`NormalForm.lean:198-207`): env has length `n`; at arity 5 the env is
`Fin 5 → M.carrier`, here `Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))`, so
coordinate order is `[y, x1, w, x, t]` (y at fold index 0, t as the constant tail). Confirmed
consistent with the handoff's `hbelowFib` env (`phase-3-reclose-handoff:110`).

---

## Deliverable 2 — Proof strategy mapped to k=2 and to Rabinovich (and where it breaks)

| Step | k=2 carrier (LANDED) | Rabinovich | extF4 attempt at depth-k arity-5 | Status |
|---|---|---|---|---|
| Pin the endpoints | `.holds M atomMap x t` exposes `x,t` as the 2 bracket endpoints (`VVecEA2.holds`) | `[α0,β1,…](z0,z1)` — 2 fixed endpoints (Lemma 5.1) | Would need `.holds … x1 w x t` — **4 endpoints; no primitive** | **BLOCKED** |
| Quantify the interior | `∃ w` — one witness inside `(x,t)`, temporally quantified | interior `x1<…<xn` quantified between `z0,z1` | `∃ y` fresh + `x1,w` would be *pinned*, not quantified | **inverts the design** |
| Realize an on-fiber sub | `hrealI`/`hrealB` fed as hypotheses; discharged by 309 Phase-14 provider | interior witness `r0 = inf{…}` UNIQUE (Lemma 5.3 Case 2/3) | `nf_eval_nfk_iff_efold` gives per-sub `↔` **only if σ realized at env4** | **conditional** |
| Re-anchor for recursion | (k=2 terminal; no deeper nesting) | `r0` BECOMES endpoint of `On(P2,…,Pn,r0,z1)` — NESTED bracket | flat arity-5 has no nesting slot | **mechanism absent** |
| Read zone facts back | `kvE_subBit_iff` (`ExteriorBracketK.lean:314`) from an EXISTING realizer | quantifier-free point-types read env-free | `kvE_subBit_iff` needs `hσ : nf_eval_nf M (k+1) 4 env σ` | **reader, not producer** |

The chain breaks at the first row: there is no 4-endpoint carrier and the architecture forbids one.
Every downstream step (`kvE_subBit_iff`, `nf_eval_nfk_iff_efold`) is a determinacy **reader** that
consumes a realizer of `σ` at `env4 = [x1,w,x,t]`; none **produces** that realizer from the
env-existential content channel (`P.existF`/`kvE_fiberPosOnShift_correct`), which is the entire
`_complete` gap (`phase-3-reclose-handoff:56-82`).

---

## Deliverable 3 — Supporting-lemma inventory (verified signatures, drift flagged)

| Symbol | Claimed loc | Verified loc | Signature (verified) | Drift |
|---|---|---|---|---|
| `nf_eval_nf` | — | `NormalForm.lean:198-207` | `(k n)(env : Fin n → M.carrier)(NormalForm sig k n) → Prop`; depth-`k+1` = atom layer ∧ per-sub `(∃x, nf_eval (Fin.cons x env) sub) ↔ quant sub` | none |
| `nf_eval_unique` | `NormalForm.lean:245` | `NormalForm.lean:245-267` | two realizers at **same** env ⟹ `nf1 = nf2`. Fixed-env determinacy; cannot bridge two envs | none (matches report 03) |
| `nf_eval_nfk_iff_efold` | `NfEFold.lean:627` | `NfEFold.lean:627-669` | `nf_eval_nf M (k+1) n env qnf ↔ (nf_eval_efold_k … ∧ off-fiber falsity)`. `nf_eval_efold_k` 2nd conjunct = the per-sub `(∃x …) ↔ qnf.2 sub`. **Extracting the `↔` requires `nf_eval_nf … env qnf` to HOLD** | none |
| `nfk_dropFresh` | `NfEFold.lean:578-580` | `NfEFold.lean:578-580` | `NormalForm sig k (n+1) → NormalForm sig 0 n` (**depth-0 codomain** — root of the F2 impossibility) | none |
| `kvE_subBit_iff` | ExteriorFiberK (task) | `ExteriorBracketK.lean:314-344` | under `hσ : nf_eval_nf M (k+1) 4 env σ`: `kvE_subBit σ zs4 χ = true ↔ ∃ v, zoneHolds M env zs4 v ∧ nf_eval_nf M k 1 (fun _ => v) χ`. **Requires realizer `hσ`** | **task said ExteriorFiberK — actually ExteriorBracketK** |
| `semantic_prior_UZ` | `PriorDefs.lean:22` | `PriorDefs.lean:22-28` | first-occurrence existence of a **single** formula ψ (infimum existence, Lemma 5.3 Case 2 INPUT) | none |
| `semantic_prior_SZ` | `PriorDefs.lean:33` | `PriorDefs.lean:33-39` | last-occurrence existence, dual | none |
| `BracketCarrierCorrectVPrior` | `PriorInterface.lean:60-73` | `PriorInterface.lean:60-73` | 2-anchor `.holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` | none |
| `bracketEndChar_kvE2_complete_two_prior` | `OuterGate.lean:147` | `OuterGate.lean:147-179` | ⇐ half, unconditional | none |
| `bracketEndChar_kvE2_sound_two_prior_frag` | `OuterGate.lean:…` | `OuterGate.lean:268-334` | ⇒ half; `hrealI`/`hrealB` at pinned `[x1,w,x,t]` env | none |
| `VVecEA2` / `VVecEA2.holds` | — | `VecEAFormula.lean:271-279` | **2-endpoint** carrier; `.holds … (z0 z1 : M.carrier)` | none |
| `VecEA2` | — | `VecEAFormula.lean:252-258` | exactly 2 free variables (z0,z1) | none |
| `kvE_subBracket2` (arity-4) | — | `SubBracket2.lean:139`,`336` | arity-4 sub-bracket; `.holds z0 z` (**2 endpoints**), interior anchors temporally quantified (Amendment F3) | none |
| `temporal_truth` | — | `Table.lean:182-193` | takes a **single** `t : M.carrier` | none |

**Nothing critical is missing or drifted except one path label**: the task said the determinacy core
`kvE_subBit_iff` is in `ExteriorFiberK.lean`; it is actually in **`ExteriorBracketK.lean:314`**
(`ExteriorFiberK.lean` holds the reindex bridge `rot5*`/`kvE_anchorBridge`/`kvE_fiberPosOnShift`). No
symbol needed for extF4 is absent; the blocker is architectural, not a missing lemma.

---

## Deliverable 4 — Module location + frozen-file git-clean confirmation

- **Baseline is git-clean** (`git status --porcelain` empty, verified 2026-07-12).
- **Frozen files** (must stay EMPTY on `git diff`): `PriorInterface.lean` (`ExistProviders.existF`/
  `.correct`, `P.correct`), `SharedWitness.lean`, `SubBracket2V.lean`, `OuterGate.lean`,
  `ExteriorBracket.lean`, `ExteriorZoneTriage.lean`, `ExteriorNegation.lean`,
  `ExteriorNegationPastK.lean`, `KampPrior.lean`, `ExteriorBracketK.lean`. All present under
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` (+ `KampPrior.lean` one level
  up). A NEW sibling module (e.g. `NfMultiAnchorBridge/ExteriorConverterK.lean`) would keep all of
  these clean — **IF** there were code to write. Given the NO-GO, no module is created this round.
- The two `_complete` targets live in `ExteriorNegationK.lean` (`kvE_extNegFut_complete`, currently
  reverted/absent — the green state is `_sound`-only) and `ExteriorNegationPastK.lean`
  (`kvE_extNegPast_*`, `sound` at `:539`). Both `_sound` halves are GREEN and consumer-ready.

---

## Deliverable 5 — Two survivable re-scopes (do NOT re-dispatch the flat extF4)

The flat/pinned `extF4` is a dead end (Verdict). Two faithful alternatives, in preference order:

**Option A — Nested-bracket re-anchoring converter (faithful, LARGE).** Build the depth-k converter as
Rabinovich actually does it: a **recursive 2-endpoint** construction where the interior witness
`r0 = inf{…}` (supplied by `semantic_prior_UZ`/`SZ`) is re-anchored as the endpoint of a
sub-bracket. This respects the 2-endpoint architecture (each rung is a `VVecEA2.holds z0 z1`) and the
frozen files. It is **not** a single new lemma — it is the depth-k lift of the entire k=2
`bracketEndChar_kvE2` assembly, and should be scoped as a multi-phase task (arity climbs by nesting,
not by widening the anchor tuple). **Recommended if the completeness direction must be closed
in-tree.**

**Option B — Per-sub determinacy interface, conditioned on realization (SMALL, provable now).** Do not
attempt to *produce* a realizer. Instead expose the determinacy the reconstruction can actually use:
for the below-`t` and at-anchor zones where `σ` IS realized at `[x1,w,x,t]`, package
`nf_eval_nfk_iff_efold` + `kvE_subBit_iff` into the exact `hbelowFib`-shaped per-sub biconditional
(`phase-3-reclose-handoff:107-111`) and hand it to `_complete` as a discharged (not hypothesized)
bundle field. This is provable, sorry-free, frozen-file-clean. It does **not** close the above-`t`
gap/self/ray zones — those remain genuinely blocked by the F2 env-transfer impossibility (report 03,
NO-GO confirmed and re-confirmed here) and must stay `[BLOCKED]` pending Option A. **Recommended as the
immediate, honest partial** that maximizes what 349/352 can consume without misrepresenting the gap.

**Escalation**: keep `kvE_extNegFut_complete` / `kvE_extNegPast_complete` `[BLOCKED]`. The correct
unblock is Option A (nested re-anchoring), not the flat `extF4`. Recommend `/spawn 353` (or a task-349
interface redesign) scoping Option A as a multi-phase nested-bracket lift, and landing Option B now as
the partial determinacy interface.

---

## Adversarial self-check

- **Ill-posedness is type-level, not a proof-search failure**: `temporal_truth … t φ` provably ignores
  `x1,w,x` (`Table.lean:182-193`); report 03's own `transfer_probe` reduces the `↔` to `env4 = env'`
  (report 03:158-171). Two independent confirmations.
- **Architecture claim is grounded, not assumed**: `VecEA2`/`VVecEA2` are 2-free-var by definition
  (`VecEAFormula.lean:252,271`); the arity-4 `kvE_subBracket2` still exposes only `(z0,z)`
  (`SubBracket2.lean:336`, Amendment F3). No 4-endpoint carrier grep-hits anywhere in
  `NfMultiAnchorBridge/`.
- **Not a false "mathlib has this"**: every object is repo-local; the blocker is a proven structural
  insufficiency, not a lookup gap.
- **No sorry / axiom / placeholder recommended.** Option B is genuinely provable; Option A is honestly
  scoped as large; the residual gap is honestly left `[BLOCKED]`.

## Files / anchors
- `Table.lean:182-193` (`temporal_truth`, single-anchor); `NormalForm.lean:198-207` (`nf_eval_nf`),
  `:245-267` (`nf_eval_unique`).
- `NfEFold.lean:578-580` (`nfk_dropFresh`, depth-0 codomain), `:608-669` (`nf_eval_efold_k` /
  `nf_eval_nfk_iff_efold`).
- `VecEAFormula.lean:252-279` (`VecEA2`/`VVecEA2`/`.holds`, 2-endpoint).
- `PriorInterface.lean:38-45` (`ExistProviders`, single-anchor `∃ env`), `:60-73`
  (`BracketCarrierCorrectVPrior`, 2-anchor).
- `OuterGate.lean:147-179` / `:268-334` / `:359+` (k=2 carrier halves).
- `ExteriorBracketK.lean:302-344` (`kvE_subBit`/`kvE_subBit_iff`, realizer-conditioned reader).
- `SubBracket2.lean:139,336` (arity-4 sub-bracket, 2-endpoint, Amendment F3).
- `PriorDefs.lean:22-39` (`semantic_prior_UZ`/`SZ`).
- Task 352: `reports/03_realizability-transfer-blocker.md`, `handoffs/phase-3-reclose-handoff-20260712.md`
  (`hbelowFib` interface :107-111; blocker :56-82), `handoffs/phase-4-reclose-handoff-20260712.md`.
- Rabinovich 2014: chunk_0013 (Lemma 5.1), chunk_0014 (Lemma 5.3 Case 2/3 `r0=inf`, re-anchoring),
  chunk_0015 (Cor 5.4 ⇐).
