# Task 352 Phase 3.2-3.3 (Future re-close) Handoff — 2026-07-12

Per-side handoff (H7 Future territory, re-close dispatch after the shared reindex bridge landed).
File owned: `ExteriorNegationK.lean` (content-swap + additive tail). Did NOT touch the sibling's
`ExteriorNegationPastK.lean` or any frozen file. Session `sess_1783887769_cb5be4`.

## Status

**PARTIAL.** `kvE_extNegFut_sound` re-closed GREEN via the shared reindex bridge (the original
content-channel↔fold-slot blocker is RESOLVED). `kvE_extNegFut_complete` remains [BLOCKED] on a
DISTINCT, empirically-confirmed obstruction (env-existential↔env-specific realizability transfer)
that the reindex bridge does NOT resolve. `sorry_count = 0`; no vacuous/placeholder landed; scoped
`lake build` GREEN; frozen diffs EMPTY.

## Resolution mechanism (applies to both directions' content)

The 5 content-bearing clause defs were swapped from the plain endpoint channel (`kvE_fiberPosOn P`
/ `P.existF 4`) to the **shifted** channel:
- `kvE_futItemShift P s := P.existF 4 (renameNF rot5Fwd rot5Bwd s)` (NEW; the re-anchored item),
- `kvE_futGapD` / `kvE_futRayD` → `kvE_fiberPosOnShift P (kvE_fiberZoneList σ ·)`,
- `kvE_futRayForm` per-element → `Formula.untl (kvE_futItemShift P s) Formula.top`,
- `kvE_futEnd` self content → `kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futSelfZone)`,
- `kvE_futChain` itemF → `kvE_futItemShift P`.

The signatures of `kvE_futPos` / `kvE_extNegFut` are UNCHANGED (`(P σ)`), so downstream consumers
(349 Phase 2, Phase 5/6) are unaffected structurally — only the internal content rendering
re-anchors. `kvE_futChainG/BuildG/DestructG` and the admissibility layer are reused unchanged.

## Glue landed (GREEN, `ExteriorNegationK.lean`)

- `kvE_futItemShift_correct` : `temporal_truth r (kvE_futItemShift P s) ↔ ∃ env, nf_eval_nf M k 5
  (Fin.cons r env) s` — `P.correct 4` ∘ `kvE_anchorBridge` (the exact hs→goal discharge report 02
  predicted; `r` at the FRESH index-0 fold slot).
- `kvE_futZone4_of_above` — Future-named replica of the frozen private `kvE2_futZone4_of_above`
  (point `> t` sits in `Fin.cons p0 kvE2_sep_zFutT3`).
- `kvE_futZoneHolds_of_atom` — atom-layer zone read-back (`nf_eval (Fin.cons v env) s →
  zoneHolds M env (nfk_zoneSpec s) v`); Future-named to avoid a same-namespace clash with the
  Past sibling's side-agnostic `kvE_zoneHolds_of_atom` at final assembly.
- `kvE_fiberZoneList_realized` — the `_sound`-direction content producer (realizer + zoned point
  ⟹ a listed fiber sub realized at the fresh slot; `v`'s characteristic, mirrors the backward
  half of `kvE_subBit_iff`).

## Decls closed

- **`kvE_extNegFut_sound`** — GREEN, axioms exactly `[propext, Classical.choice, Quot.sound]`
  (`lake env lean` authoritative). Commit `d6f7784e1`. Cor 5.4 `O_n` build via
  `kvE_futChainBuildG` with occurrence predicate `Q s r := nf_eval (Fin.cons r [x1,w,x,t]) s`;
  gap/ray/self content discharged via `kvE_fiberPosOnShift_correct` / `kvE_futItemShift_correct`
  supplying σ's own realizer env `[x1,w,x,t]`.
- **`kvE_extNegFut_complete`** — **NOT closed. [BLOCKED]** on the realizability-transfer gap below.
  A fresh implementation dispatch (39 tool calls) ported the full 9-zone reconstruction, proved
  the atom layer + below-t zones + off-fiber + the two helper replicas (`kvE_futCharZone4`,
  `kvE_futSigma_atom`) GREEN, and isolated the blocker to two symmetric gap/self/ray obligations,
  then reverted (file byte-identical to the green `_sound`-only state).

## `kvE_extNegFut_complete` — BLOCKER (four-element, empirically grounded)

Distinct from the (resolved) bridge blocker.

- **Failing `lean_goal`** (backward gap; self/ray identical): given
  `sub : NormalForm sig k 5`, `nfk_dropFresh sub = σ.1`, `σ.2 sub = true`,
  `nfk_zoneSpec sub = Fin.cons (true,false) kvE2_sep_zFutT3`,
  `env4 := Fin.cons x1 (Fin.cons w (Fin.cons x fun _ => t))`,
  `hoccl : ∀ a ∈ l, ∃ r, t<r ∧ r<x1 ∧ temporal_truth r (kvE_futItemShift P a)` —
  `⊢ ∃ z, nf_eval_nf M k 5 (Fin.cons z env4) sub`. Forward gap is the dual
  (`hv : nf_eval (Fin.cons v env4) sub`, gap zone ⊢ `σ.2 sub = true`).
- **Current behavior**: the content channel yields **env-existential** realizations
  `∃ env', nf_eval (Fin.cons r env') s` (`kvE_fiberPosOnShift_correct`), `env'` genuinely free
  (Rabinovich Lemma 5.3 interior quantification — report 02 Deliverable 3.3).
- **Required behavior**: `nf_eval_nfk_iff_efold`'s per-sub biconditional pins anchors to the
  **specific** `env4 = [x1,w,x,t]`. Depth 0 coincides (atom-only subs, env-independent,
  `nf_profile_unique` closes); depth `k ≥ 1` subs carry env-dependent interior content, so
  `∃env', nf_eval (Fin.cons r env') s` does NOT imply `nf_eval (Fin.cons r env4) s`.
- **Isolation / what is needed**: a **realizability-transfer / canonical-model-homogeneity
  (saturation)** lemma: for on-fiber `s`, `r` in the target zone of `env4`, `env4` realizing
  `σ.1`: `(∃env', nf_eval (Fin.cons r env') s) ↔ nf_eval (Fin.cons r env4) s`. NOT in the tree;
  NOT derivable from `h_UZ`/`h_SZ` (`PriorDefs.lean:22/33` = first/last-occurrence only). Ruled
  out: (a) determinacy pin (`env'` free); (b) all-zone `hbelowFib` extension (∀x1 all-zone pin is
  false/undischargeable + vacuous; below-t works because x1-independent); (c) dropping forward
  (fold biconditional forces the env-specific backward realizer). **Recommended discharge: task
  349 Phase 2** supplies the transfer as a bundle hypothesis; escalate `/spawn 352` (or fold into
  349 Phase 2 interface design).

## Signature exposed for Phase 5/6 + task 349 Phase 2

```
-- content-swapped defs (signatures unchanged from Phase 3.1):
kvE_futPos    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k+1) 4) : Formula
kvE_extNegFut (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k+1) 4) : Formula
  := (kvE_futPos P σ).neg

-- AVAILABLE (GREEN, axiom-clean):
kvE_extNegFut_sound
    (P : ExistProviders sig atomMap k) (M) (h_UZ h_SZ)
    (σ : NormalForm sig (k+1) 4) (w x t) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE_extNegFut P σ)) :
    ∀ x1, t < x1 → ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ

-- NOT AVAILABLE (blocked); attempted interface shape 349 Phase 2 should design around
-- (hbelowFib covers the 6 below-t zones; ADD the realizability-transfer lemma for gap/self/ray):
kvE_extNegFut_complete
    (P : ExistProviders sig atomMap k) (M) (h_UZ h_SZ)
    (qnf : NormalForm sig (k+1) 3) (σ : NormalForm sig (k+1) 4) (w x t) (hxw hwt)
    (henv : ∀ a : AtomKind sig 3,
       atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbase : nf0_dropFresh σ.1 = qnf.1)
    (hbelowFib : ∀ x1, t < x1 → ∀ zs3 : ZoneSpec 3,
       (zs3 = kvE2_sep_zPastX3 ∨ … ∨ zs3 = kvE2_sep_zAtT3) →
       ∀ s, nfk_dropFresh s = σ.1 → nfk_zoneSpec s = Fin.cons (true,false) zs3 →
         ((∃ z, nf_eval_nf M k 5 (Fin.cons z (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
           ↔ σ.2 s = true))
    (hnorel : ∀ x1, t < x1 → ¬ nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE_extNegFut P σ)
```

## Sorry Inventory

`[]` (empty — `_complete` is BLOCKED and escalated with a precise four-element record, not stubbed).

## Verification

- Scoped `lake build …ExteriorNegationK` GREEN (1022 jobs). `sorry_count = 0`. No vacuous defs.
- `#print axioms kvE_extNegFut_sound` (via `lake env lean`) = exactly `[propext, Classical.choice, Quot.sound]`.
- `git diff --stat` on all 7 frozen providers + KampPrior + ExteriorBracketK + ExteriorFiberK +
  PriorInterface + ExteriorNegation.lean + the sibling `ExteriorNegationPastK.lean`: EMPTY.
- Commit `d6f7784e1` (Future `_sound` + glue + content swap). No sorry ever committed.

## References

- Report: `reports/02_reindex-bridge-blocker.md` (bridge design, verdict GO; Deliverable 3.3 on
  existential-env faithfulness — the same channel property that blocks `_complete` reconstruction).
- Bridge (consumed, frozen): `ExteriorFiberK.lean:315-380` (`rot5*`, `kvE_anchorBridge`,
  `kvE_fiberPosOnShift`, `kvE_fiberPosOnShift_correct`).
- Prior obstruction handoff: `phase-3-2-3-handoff-20260712.md`.
- Frozen templates: `ExteriorNegation.lean:1243` (`_sound`), `:1484` (`_complete`), `:1351`
  (`kvE2_futSigma_atom`), `:374` (`kvE2_futCharZone4`).
