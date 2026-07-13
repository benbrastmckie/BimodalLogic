# Task 354 — Nested 2-Endpoint Bracket Re-Anchoring Converter: Research Report

**Agent**: lean-research-agent | **Date**: 2026-07-12 | **Task type**: lean4 | **Topic**: kamp_theorem_formalization
**Grounding tier**: Tier 1 (literature-backed — Rabinovich 2014 Lemma 5.1/5.3, Cor 5.4; task 352 report 03; task 353 report 01)
**All signatures below verified against LIVE source via Read + Lean LSP**; every line number reconciled and drift flagged.
**Well-posedness probe**: a scratch module (`ConverterProbe354.lean`) stating all four target signatures BUILT GREEN (sorry-only), then removed — tree left clean. This machine-confirms the signatures type-check (unlike task 353's flat `extF4`).

---

## VERDICT (Deliverable 6, up front): **GO — conditional-provable, F2 sidestepped by carrying (not overcoming) the realization bundle; one high-risk phase precisely flagged**

The Option-A nested re-anchoring converter **is buildable and closes the two `_complete` halves**, but only with the honest scoping the k=2 assembly already uses:

1. **The exterior `_complete` is provable as the REVERSE of the green `_sound`**, consuming the already-landed depth-`k` chain **destructor** `kvE_futChainDestructG` (`ExteriorNegationK.lean:293`, GREEN — the Cor 5.4 `Oₙ` re-anchoring engine) plus a **carried arity-5 pinned-env realization bundle** (the F2-blocked producer input). It is NOT a clean general-model converse.

2. **The F2 env-transfer wall is SIDESTEPPED, not overcome.** Exactly as the landed k=2 `bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`) carries `hrealI`/`hrealB`/`hexcl` as *hypotheses* discharged one level up (KampPrior:351), the depth-`k` exterior `_complete` carries an arity-5 realization hypothesis discharged by the outer recursion / task-349 provider. Task 352's NO-GO refuted an *additive* transfer lemma in a general model; it did **not** refute *carrying* the realization as a hypothesis. The nested re-anchoring structure is what lets us state and thread that hypothesis faithfully at depth `k`.

3. **The recursion is ALREADY GREEN.** Rabinovich's Lemma 5.3 induction on bracket **length `n`** (re-anchor `r0 = inf` as the next endpoint) is `kvE_futChainG`/`BuildG`/`DestructG` (green, consumed by `_sound`). The **depth `k`** dimension is externalized to the `ExistProviders` bundle `P` (built by KampPrior's `Nat.rec`, task-309 pattern). Task 354 adds **no new recursion**; it adds the reverse-direction assembly + bundle reconciliation.

4. **One high-risk phase**: the fiber-**backward** half (`∃ v` realizing `s` at the pinned env `[v,x1,w,x,t]` ⟹ `σ.2 s = true`) needs the reconstructed exterior anchor `x1` to be **saturated**. Whether `semantic_prior_UZ` (first-occurrence/infimum of a *single* formula) plus `nf_eval_unique` fully saturates `x1`'s depth-`k` joint type — or whether that residue must ALSO be carried up to the outer recursion (as k=2's `hexclExt` is) — is the one place a fresh sub-blocker can surface. It is characterized precisely in Deliverable 6 and isolated to Phase 3.

**Do NOT re-attempt the flat `extF4`** (task 353 permanently refuted it). **Do NOT add an additive transfer lemma** (task 352 machine-refuted it). The path below is the faithful Rabinovich mechanism.

---

## Deliverable 1 — Exact well-posed carrier signatures (verified against LIVE source)

**Machine-confirmed well-posed** by the `ConverterProbe354.lean` build (green, sorry-only, then removed). Contrast task 353: the flat `temporal_truth M atomMap t (extF4 s)` with a free-`x1,w,x` RHS is ill-posed; here `x1` is **quantified** inside the reconstruction, never pinned as a free variable under a `temporal_truth`.

### 1a. The primary deliverable — exterior `_complete` (reverse of the green `_sound`)

The green `_sound` (`ExteriorNegationK.lean:532`, verified verbatim):

```lean
kvE_extNegFut_sound … (σ : NormalForm sig (k+1) 4) (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE_extNegFut P σ)) :
    ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
```

The **new `_complete`** (well-posed, probe-confirmed), stated as the reverse WITH the carried bundle:

```lean
theorem kvE_extNegFut_complete
    (P : ExistProviders sig atomMap k) (M …) (h_UZ …) (h_SZ …)
    (σ : NormalForm sig (k+1) 4) (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    -- CARRIED arity-5 pinned-env realization bundle (the F2 producer input); pinned env [v,x1,w,x,t]:
    (hreal : ∀ x1 : M.carrier, t < x1 → ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v : M.carrier, nf_eval_nf M k 5
        (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hcl : ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE_extNegFut P σ)
```

- `kvE_extNegFut P σ = (kvE_futPos P σ).neg` (`ExteriorNegationK.lean:425`, verified). Unfolding, the contrapositive of `_complete` is exactly **"`kvE_futPos` at `t` ⟹ `∃ x1 > t` realizing `σ` at `[x1,w,x,t]`"** — the producer direction.
- `hreal` is the honest name for the arity-5 analog of the k=2 `hrealI`/`hrealB` (`OuterGate.lean:288-305`), one arity up (env `[v,x1,w,x,t] : Fin 5 → M.carrier`, `s : NormalForm sig k 5`).
- **Do not** attempt `hreal` inside this module (F2). It is discharged by the outer recursion / task-349 provider (Deliverable 3, Phase 5).

### 1b. The template being lifted — k=2 arity-3 2-endpoint carrier (verified)

`BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2` (`CarrierK1V.lean:365`, verified — the codomain is the 2-endpoint disjunction `VVecEA2`, **VecEAFormula:271-279**: `.holds` takes exactly `(z0 z1)`).

`BracketCarrierCorrectV` (`CarrierK1V.lean:374`, verified — unconditional shape):

```lean
(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

`BracketCarrierCorrectVPrior` (`PriorInterface.lean:60-73`, verified — UZ/SZ-relativized variant, six order-atom hypotheses).

`bracketEndChar_kvE2 : (P : ExistProviders sig atomMap 1) → BracketEndCharCarrierV sig 2`
(`OuterGate.lean:70`, verified) — delegates to `kvE2_sepBody` (SharedWitness, frozen). This is the k=2 INTERIOR-bracket carrier. **Its ⇐ (`_complete`) is UNCONDITIONAL** (`bracketEndChar_kvE2_complete_two_prior`, `OuterGate.lean:147`); **its ⇒ (`_sound`) carries** `hrealI/hrealB/hexcl/hexclExt` (`OuterGate.lean:268`). The full ↔ is `bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`).

**Key architectural finding (drift flag)**: the depth-`k` arity-3 carrier `bracketEndChar_kvE` exists **only in `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean:269`** (DEAD/quarantined) — there is **no live** depth-`k` arity-3 carrier. **But the exterior `_complete` does NOT consume it**: the exterior clause is self-contained on the CHAIN infrastructure (`kvE_futChainG`, `ExteriorNegationK.lean:216`), which is the depth-`k` lift of `kvE2_futChain` (`ExteriorNegation.lean`), **not** of `bracketEndChar_kvE2`. The arity-3 carrier is the INTERIOR-gate object (consumed only by the frozen `ExteriorBracket.lean:1069`); it is a separate concern and **not on the exterior `_complete` critical path**. This is the single biggest simplification vs. the task's framing "lift the entire bracketEndChar_kvE2 assembly" — the exterior direction needs the chain lift, which already landed.

---

## Deliverable 2 — Recursion structure, base case, inductive step, mapped to Rabinovich

**Three orthogonal recursions; two are already green, one is externalized.**

| Recursion | On what | Where | Rabinovich | Status |
|---|---|---|---|---|
| **Bracket length `n`** | the fiber list `kvE_fiberZoneList σ zsₙ` | `kvE_futChainG`/`BuildG`/`DestructG` (`ExteriorNegationK.lean:216/229/293`) | Lemma 5.3 induction `n ↦ n+1` (chunk_0014:11) | **GREEN** |
| **Depth `k`** | the modal/normal-form depth | `ExistProviders` bundle `P` built by `KampPrior` `Nat.rec` (task-309) | Def 7.13 nesting `(z0,…,zk,∞)` (chunk_0023) | **externalized to `P`** |
| **Model order** | the actual increasing witness chain | consumed by `DestructG` | Cor 5.4(1) ⇐ (chunk_0015:9-41) | **GREEN** |

**Base case (`n = 0`, `DestructG` nil, `:306-310`)**: an empty chain at `s` is `Untl endF D`; destructs to the endpoint `x1 > s` with `endF` and the `D`-uniform gap — Rabinovich basis "¬∃x1 ≡ ∀y ¬P1" (chunk_0014:9).

**Inductive step (`n ↦ n+1`, `DestructG` cons, `:311-331`)**: the head `Untl (conj [itemF a, chain rest]) D` yields the **re-anchor point `r₀`** (`:314`, `hsr₀ : s < r₀`), the item occurrence `itemF a` at `r₀` (`:316`), and the recursive chain at `r₀` (`:317`). The IH re-anchors `r₀` as the new left endpoint of the length-`n` sub-chain (`ih r₀ …`, `:319`). **This is Rabinovich's re-anchoring verbatim** (Lemma 5.3 formula (3): `∃r0 [INF(z0,r0,z1,P1) ∧ On(P2,…,Pn, r0, z1)]`, chunk_0014:35): `r₀` becomes the endpoint of the recursive `Oₙ`. The uniqueness `INF` is supplied at the CONTENT level by `nf_eval_unique` (item distinctness `huniq`, consumed at `BuildG:234`) and the first-occurrence existence by `semantic_prior_UZ`/`SZ` threaded through `kvE_futItemShift_correct` (`:442`, which is `P.correct 4` + `kvE_anchorBridge`).

**What the exterior `_complete` construction does (the NEW glue, Future)**:
1. Assume `kvE_futPos P σ` at `t` (contrapositive; `admissible σ` via `kvE_futRealizer_admissible`).
2. `formula_disjList_iff` + `if_pos` peel a permutation `l`; apply **`kvE_futChainDestructG`** to get `x1 > t`, `kvE_futEnd` at `x1`, the `D`-gap on `(t,x1)`, and one `kvE_futItemShift`-occurrence per gap item.
3. Reconstruct `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` via **`nf_eval_nfk_iff_efold`** (`NfEFold.lean:627`): (a) atom layer at `[x1,w,x,t]`; (b) per-sub fiber biconditional.
4. **Fiber-forward** (`σ.2 s → ∃v at [v,x1,w,x,t] s`): supplied by the carried `hreal` bundle. (`DestructG` gives realizers over the `∃env` channel of `kvE_futItemShift_correct` — env FREE — which is exactly why the bundle must be carried; F2.)
5. **Fiber-backward** (`∃v at pinned → σ.2 s`): via `nf_eval_unique M k 5` on `x1`'s saturated characteristic. **← Phase-3 risk (Deliverable 6).**

**Past dual** (`kvE_extNegPast_complete`): mirror through the Past chain / `semantic_prior_SZ` (last-occurrence), consuming the Past `_sound` at `ExteriorNegationPastK.lean:539` as template.

---

## Deliverable 3 — Consumed-lemma inventory (verified file:line + signature) and NEW helpers

### Consumed UNCHANGED (all verified via Read/LSP this session)

| Symbol | Verified loc | Signature (verified) | Drift vs. task/report |
|---|---|---|---|
| `nf_eval_nf` | `NormalForm.lean:198-207` | depth-`k+1` = atom layer ∧ per-sub `(∃x, eval (cons x env) sub) ↔ quant sub` | none |
| `nf_eval_unique` | `NormalForm.lean:245-268` | two realizers at **same** env ⟹ equal (fixed-env determinacy) | none |
| `nf_eval_nfk_iff_efold` | `NfEFold.lean:627-632` | `nf_eval_nf (k+1) ↔ (nf_eval_efold_k ∧ off-fiber falsity)`; `nf_eval_efold_k`:608-613 | none |
| `nfk_dropFresh` | `NfEFold.lean:578-580` | `NormalForm sig k (n+1) → NormalForm sig 0 n` (depth-0 codomain — F2 root) | none |
| `kvE_subBit_iff` | `ExteriorBracketK.lean:314-321` | under `hσ`: `kvE_subBit σ zs4 χ = true ↔ ∃v, zoneHolds … ∧ nf_eval M k 1 …` | **task said ExteriorFiberK — actually ExteriorBracketK** (already flagged 353) |
| `semantic_prior_UZ` / `SZ` | `PriorDefs.lean:22-28 / 33-39` | first/last-occurrence existence of a single ψ (infimum, Lemma 5.3 Case 2 INPUT) | none |
| `temporal_truth` | `Table.lean:182-193` | single carrier point `t` | none |
| `VVecEA2.holds` / `VecEA2` | `VecEAFormula.lean:276-279 / 252` | 2-endpoint `(z0 z1)`; VecEA2 has exactly 2 free vars | none |
| `ExistProviders` | `PriorInterface.lean:38-45` | `existF n`; `correct`: `temporal_truth t (existF n sub) ↔ ∃env, nf_eval M k (n+1) (insertEnv env t) sub` | none |
| `BracketEndCharCarrierV` | `CarrierK1V.lean:365` | `NormalForm sig k 3 → VVecEA2` | (new find) |
| `BracketCarrierCorrectV` / `…Prior` | `CarrierK1V.lean:374` / `PriorInterface.lean:60` | `holds x t ↔ ∃w, nf_eval M k 3 [w,x,t] qnf` | none |
| `bracketEndChar_kvE2` (+ `_complete/_sound/_correct`) | `OuterGate.lean:70 / :147 / :268 / :359` | k=2 arity-3 carrier; ⇐ unconditional, ⇒ carries `hrealI/hrealB/hexcl/hexclExt` | line ranges ACCURATE |
| `bracketEndChar_kvE2Ext_correct_two_prior_frag` | `ExteriorBracket.lean:1069` | exterior nesting (task 348); `hexclExt` discharged INTERNALLY via per-side `kvE2_extBracket{Past,Fut}` | (new find — template for internal residue discharge) |

### Green depth-`k` chain infrastructure (the re-anchoring engine — verified, consumed by `_sound`)

| Symbol | Loc | Role |
|---|---|---|
| `kvE_futChainG` | `ExteriorNegationK.lean:216` | the `Oₙ` chain formula (nested `Untl` links = nested 2-endpoint brackets) |
| `kvE_futChainBuildG` | `:229` | build chain FROM realizer (used by `_sound`); consumes `nf_eval_unique` as `huniq` |
| `kvE_futChainDestructG` | `:293` | **destruct chain TO x1 + occurrences** (the `_complete` engine) |
| `kvE_futItemShift_correct` | `:442` | `temporal_truth r (kvE_futItemShift P s) ↔ ∃env, nf_eval M k 5 [r,env] s` (the `∃env` F2 channel) |
| `kvE_fiberZoneList_realized` | `:496` | realized σ + zoned point ⟹ listed fiber sub realized there (`_sound` producer) |
| `kvE_extNegFut` / `kvE_futPos` / `kvE_futEnd` | `:425 / :415 / :395` | the clause defs |
| `kvE_extNegFut_sound` | `:532` | the GREEN template to reverse |
| `kvE_extNegPast_sound` | `ExteriorNegationPastK.lean:539` | Past template |

### NEW helper lemmas the construction will require (proposed signatures)

1. **`kvE_futEnd_forces_atom`** (Phase 3, RISK): the reconstructed `x1` (endpoint of `DestructG`) satisfies `nf_eval_nf M 0 4 [x1,w,x,t] σ.1` — i.e. `kvE_futEnd`/self-zone content at `x1` pins σ's atom layer at the top coordinate. *This is where x1-saturation must be established.*
   ```lean
   (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ)) (htx1 : t < x1) (hxw …) (hwt …) →
     nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1
   ```
2. **`kvE_futFiber_backward`** (Phase 3, RISK): `(∃ v, nf_eval M k 5 [v,x1,w,x,t] s) → σ.2 s = true`, via `nf_eval_unique M k 5` given `x1` saturated. Mirrors the backward half of `kvE_subBit_iff` (`:345`) at the reconstructed anchor.
3. **`kvE_extNegFut_complete`** / **`kvE_extNegPast_complete`** (Phases 2/4): the target theorems (Deliverable 1 signature).
4. **`kvE_futReal_of_bundle`** (Phase 2): thin adapter routing the carried `hreal` bundle into the per-gap-item occurrence shape `DestructG` reconstruction needs (pins the `∃env` to `[x1,w,x,t]`).

---

## Deliverable 4 — Phase decomposition (each ≈ one implementation dispatch)

| Phase | Objective | Consumes | Size | Go/No-Go |
|---|---|---|---|---|
| **1** | Scaffold `ExteriorConverterK.lean` + `ExteriorConverterPastK.lean` (import `ExteriorNegationK` / `PastK`, namespace, `open`s). State `kvE_extNegFut_complete` + `kvE_extNegPast_complete` with the carried `hreal` bundle. Land the well-posed statements with the reconstruction skeleton (`intro`, `admissible`, `DestructG`). | chain defs, `_sound` template | S | **GO** (probe-confirmed well-posed) |
| **2** | Future `_complete` — atom-layer + fiber-**forward** reconstruction: `nf_eval_nfk_iff_efold` assembly; feed carried `hreal` into the per-item occurrences; discharge admissibility + `kvE_futPos` peel. | `nf_eval_nfk_iff_efold`, `kvE_futItemShift_correct`, `DestructG`, `hreal` | M-L | **GO** (reverse of green `_sound`) |
| **3** | Future fiber-**backward** + x1-saturation (`kvE_futEnd_forces_atom`, `kvE_futFiber_backward`). | `nf_eval_unique`, `semantic_prior_UZ`, `kvE_subBit_iff` | M | **CONDITIONAL** — the one fresh-sub-blocker candidate (Deliverable 6) |
| **4** | Past dual `kvE_extNegPast_complete` (mirror Phases 2-3 through `semantic_prior_SZ`). | Past `_sound`, Past chain | M-L | **GO if Phase 3 GO** (symmetric) |
| **5** | Bundle-shape reconciliation: align `hreal` with the task-349/`KampPrior:351` provider-discharge interface and the task-352 `hbelowFib`/`hexclExt` conventions; fold in **Option B** (below-`t`/at-anchor determinacy reader from `nf_eval_nfk_iff_efold` + `kvE_subBit_iff`) as the immediately-dischargeable slice. | task-352 handoff interface | M | **GO** (Option B provable now, per 353 Del 5) |
| **6** | Axiom/sorry audit: `lean_verify` both new decls → axioms exactly `[propext, Classical.choice, Quot.sound]`; `lake build` full; frozen-file `git diff` empty. | — | S | **GO** |

If Phase 3 surfaces the residue described in Deliverable 6, the honest fallback is to **carry it as a named hypothesis** (the k=2 `hexclExt` pattern) rather than sorry — Phases 2/4/5/6 still land, and the residue becomes an explicit outer-recursion obligation, not debt.

---

## Deliverable 5 — Frozen-file cleanliness + new-module compilation (verified)

- **Baseline git-clean** confirmed (`git status --porcelain` empty at session start and after probe removal).
- **Frozen files stay EMPTY on `git diff`**: `PriorInterface.lean`, `SharedWitness.lean`, `SubBracket2V.lean`, `OuterGate.lean`, `ExteriorBracket.lean`, `ExteriorZoneTriage.lean`, `ExteriorNegation.lean`, `ExteriorNegationPastK.lean`, `KampPrior.lean`, `ExteriorBracketK.lean` — all under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` (`KampPrior.lean` one level up). The construction only **applies** them.
  - **Note**: the task lists `ExteriorNegationPastK.lean` as frozen, yet the Past `_complete` target conceptually belongs beside `kvE_extNegPast_*`. Resolution: build `kvE_extNegPast_complete` in the **NEW** `ExteriorConverterPastK.lean` (importing `ExteriorNegationPastK`), leaving the frozen file byte-identical. Confirmed consistent with the task's "NEW sibling modules" mandate.
- **New modules compile in isolation**: the probe module (`import …ExteriorNegationK`) built GREEN through `[1023/1023]` — the full transitive closure (chain infra, `ExistProviders`, `VVecEA2`, `semantic_prior_*`, `nf_eval_*`) is available to a sibling importing `ExteriorNegationK` / `ExteriorNegationPastK`. Both new modules should import those two clause modules (each already imports `ExteriorFiberK`, transitively pulling `ExteriorBracketK → …`).

---

## Deliverable 6 — Explicit Go/No-Go per phase, with the one sub-blocker characterized

**Phases 1, 2, 5, 6: GO.** Reverse-of-`_sound` glue over green infrastructure; Option B provable now; audit mechanical.

**Phase 4 (Past): GO iff Phase 3 GO** — strictly symmetric (`SZ` for `UZ`, Past chain for Future).

**Phase 3: the sole CONDITIONAL — precisely characterized (do not paper over).**

The fiber-**backward** obligation `(∃ v, nf_eval M k 5 [v,x1,w,x,t] s) → σ.2 s = true` requires the reconstructed exterior anchor `x1` to be **saturated**: its full depth-`k` characteristic at coordinate 0 must be determined so `nf_eval_unique` can close. Two source-grounded facts bound the risk:

- **In favour (GO)**: `DestructG` pins `x1` as the chain endpoint with `kvE_futEnd` (self-zone + ray content) holding at `x1` and the `D`-gap failing on `(t,x1)`. `semantic_prior_UZ` refines `x1` to the *first* such point (infimum, Lemma 5.3 Case 2). The backward read is then the exact mirror of the **already-green** backward half of `kvE_subBit_iff` (`ExteriorBracketK.lean:345`) and of `kvE_fiberZoneList_realized` (`:496`), both of which close via `nf_eval_unique M k` at a *reconstructed* characteristic — so the machinery to saturate at a pinned witness **already exists and is green**, just consumed in the `_sound` direction.

- **Against (residue risk)**: task 352 report 03 Deliverable 3 (H4-machine-grounded) established that `h_UZ`/`h_SZ` pin the first occurrence of a **single formula ψ** (depth-0 channel), **not** joint depth-`k` saturation at a fixed tuple. If the endpoint description `kvE_futEnd` does not constrain **every** bit of σ's atom layer at `x1` (only the realized fiber content), a residual atom bit could remain undetermined. The k=2 assembly hits the analogous residue as **`hexclExt`** (`OuterGate.lean:312-318`) and discharges it **internally** only via task-348's per-side exterior brackets `kvE2_extBracket{Past,Fut}` (`ExteriorBracket.lean:1069-1129`) — whose k=2 internal discharge **relies on env-free arity-1 profiles** (`kvE2_extGate_anyBit_iff`, SharedWitness pattern). Per task 352 report 03 Deliverable 2, that env-free profile structure **does NOT generalize to `k ≥ 1`** (arity-5 subs are env-dependent). 

**Precise sub-blocker statement (if it fires)**: *the depth-`k` internal discharge of the exterior-arrangement residue (`hexclExt` analog) may be impossible env-free; the residue must then be CARRIED as a named hypothesis to the outer recursion, exactly as k=2 carries `hexclExt` to `KampPrior:351` — NOT discharged in-module.* This is **not** an impossibility (nothing here re-opens F2 or the flat `extF4`); it is a scoping question resolved either way to a green, sorry-free module: `x1`-saturation either closes internally (full GO) or is carried as one more named outer-recursion obligation (GO-with-carried-residue). The determination is a Phase-3 LSP probe (attempt `kvE_futEnd_forces_atom` via `nf_eval_unique`; if the atom layer under-determines, add the carried residue binder). Either outcome lands Phases 1-6 sorry-free.

**No fresh impossibility. No re-proposal of the refuted flat `extF4`. No additive transfer lemma.**

---

## Adversarial self-check

- **Well-posedness is machine-confirmed, not asserted**: `ConverterProbe354.lean` built GREEN (`[1023/1023]`, sorry-only warnings), then removed; tree left clean (`git status --porcelain` empty). The four target signatures type-check — the failure mode that killed task 353's flat `extF4` (ill-posed `temporal_truth … t (extF4 s)`) is absent because `x1` is quantified.
- **Recursion claim is grounded**: `kvE_futChainDestructG` (`:293`) IS the `Oₙ` destructor; its cons case (`:311-331`) re-anchors the head witness `r₀` as the recursive endpoint — verbatim Lemma 5.3 formula (3) (chunk_0014:35, read this session).
- **F2 is sidestepped by the SAME mechanism k=2 uses** (carry the realization as a hypothesis; `OuterGate.lean:268` `hrealI/hrealB/hexcl`), not overcome — no contradiction with task 352's NO-GO (which refuted an *additive general-model transfer*, a different object).
- **The one risk is named, sourced, and bounded to Phase 3** (env-free profile non-generalization, task 352 Del 2), with a green fallback (carry the residue) — not hidden.
- **Not a false "mathlib/tree has this"**: the live depth-`k` arity-3 carrier does NOT exist (only Boneyard); the exterior `_complete` path correctly bypasses it via the green chain lift.
- **No sorry / axiom / placeholder recommended.** Option B lands now; the residue (if it fires) is a carried hypothesis, not debt.

## Files / anchors (verified this session)
- `ExteriorNegationK.lean:216/229/293` (chain G/Build/Destruct), `:415/425/532` (`kvE_futPos`/`extNegFut`/`_sound`), `:442` (`kvE_futItemShift_correct`, `∃env`), `:496` (`kvE_fiberZoneList_realized`).
- `ExteriorNegationPastK.lean:539` (`kvE_extNegPast_sound`).
- `OuterGate.lean:70/147/268/359` (k=2 carrier + halves); `ExteriorBracket.lean:1069` (task-348 exterior nesting, `hexclExt` internal discharge).
- `CarrierK1V.lean:365/374` (`BracketEndCharCarrierV`/`BracketCarrierCorrectV`); `PriorInterface.lean:38-45/60-73` (`ExistProviders`/`…Prior`); `VecEAFormula.lean:252-279` (2-endpoint).
- `NfEFold.lean:578-580/608-613/627-632` (`nfk_dropFresh`/`efold_k`/`iff_efold`); `NormalForm.lean:198-207/245-268` (`nf_eval_nf`/`unique`); `ExteriorBracketK.lean:314-345` (`kvE_subBit_iff`); `PriorDefs.lean:22-39`; `Table.lean:182-193`.
- `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean:269` (DEAD depth-`k` arity-3 `bracketEndChar_kvE`).
- Rabinovich 2014: chunk_0014 (Lemma 5.3 Case 2/3, `r0=inf`, formula (3) re-anchoring), chunk_0015 (Cor 5.4(1) ⇐ induction on `n`).
- Prior: `specs/353_.../reports/01_extf4-endpoint-pinned-converter.md` (Option A spec), `specs/352_.../reports/03_realizability-transfer-blocker.md` (F2 NO-GO, `hbelowFib` interface).
