# Task 352 Phase 3.2/3.3 (Future side) Handoff — 2026-07-12

Per-side handoff (Wave 4/5, H7 Future territory). NOT the shared `.orchestrator-handoff.json`.
File owned: `ExteriorNegationK.lean` (additive tail). Did NOT touch the sibling's
`ExteriorNegationPastK.lean` or any frozen file.

## Status

**PARTIAL — headline `_sound`/`_complete` BLOCKED on a genuine missing shared bridge.**
The clause-form definitions and the model-side chain device landed GREEN, sorry-free,
axiom-clean, committed. The two headline theorems (`kvE_extNegFut_sound`, `kvE_extNegFut_complete`)
are blocked on a content-channel↔fold variable-slot reconciliation that requires shared
infrastructure (H7 → orchestrator escalation, not in-side construction). No `sorry`, no vacuous
def landed (`sorry_count = 0`, scoped `lake build` GREEN, frozen diffs EMPTY).

## Decls landed (GREEN, `Bimodal.Metalogic.WeakCanonical.Kamp`, in `ExteriorNegationK.lean`)

Generic model-side Cor 5.4 `O_n` chain device (commit `d27eed7a6`):
1. `kvE_futChainG (itemF : α → Formula) (endF D) : List α → Formula` — abstract `D`-guarded
   `Until` chain; generalizes frozen `kvE2_futChain` (:1108) with the per-item rendering `itemF`
   abstracted (content routed through it, G6).
2. `kvE_futChainBuildG` — chain construction; port of `kvE2_futChainBuild` (:1180). The frozen
   distinctness `nf_profile_unique` is abstracted to a parameter `huniq : Q a r → Q a' r → a=a'`,
   plus `hQF : Q a r → temporal_truth r (itemF a)`. Min-pick via shared `kvE_minPick`.
   `[DecidableEq α]` for `List.erase`. Axioms `[propext, Classical.choice, Quot.sound]`.
3. `kvE_futChainDestructG` — chain destruction; port of `kvE2_futChainDestruct` (:1435). Axioms
   exactly `[propext, Classical.choice, Quot.sound]`.

Depth-`k` Future clause-form defs, content via `kvE_fiberPosOn P` (commit `782d8764c`):
4. `kvE_futGapZone`/`kvE_futRayZone : ZoneSpec 4` — gap `(true,false)` / ray `(false,true)` over
   `kvE2_sep_zFutT3`.
5. `kvE_futGapD P σ`/`kvE_futRayD P σ` — `kvE_fiberPosOn P (kvE_fiberZoneList σ ·)` (`P.existF 4`
   over the gap/ray fiber zone lists). Frozen templates :1072/:1079.
6. `kvE_futRayForm P σ` (:1088 template), `kvE_futEnd P σ` (:1098; self-zone fiber content +
   ray form), `kvE_futChain P σ l := kvE_futChainG (P.existF 4) (kvE_futEnd P σ) (kvE_futGapD P σ) l`
   (:1108).
7. `kvE_futPos P σ` (:1124; admissibility-gated `formula_disjList` over permutations of
   `kvE_fiberZoneList σ kvE_futGapZone`), `kvE_extNegFut P σ := (kvE_futPos P σ).neg` (:1136).

Parameterization: `{atomMap : Formula → sig.preds} {k} (P : ExistProviders sig atomMap k)
(σ : NormalForm sig (k+1) 4)`. `h_surj` DROPPED (unused — content is `P.existF`, not
`nf_depth0_char_formula`).

## THE BLOCKER (four-element; empirically grounded, `lean_goal` 2026-07-12)

- **Counterexample/mismatch**: `P.existF`'s correctness (`PriorInterface.lean:41-45`) evaluates a
  sub's *last* variable (index 4, `insertEnv env t`) at the eval point; σ's fold quant layer
  (`nf_eval_efold_k`, `NfEFold.lean:608-613`) binds the fresh/quantified variable at *index 0*
  (`Fin.cons x env`). At the right anchor `t` these coincide (index 4 = `t`), so
  `kvE_fiberPos P σ` wires to a realizer AT `t`. But the chain's INTERIOR gap points `r` need the
  gap variable rendered at `r` (index 4), whereas σ realizes those subs with the gap point at
  index 0 and `t` at index 4.
- **Current behavior (exact goal)**: for the item-content obligation
  `temporal_truth r (P.existF 4 s)` from a realizer, after `rw [P.correct 4 s M h_UZ h_SZ r]`:
  `⊢ ∃ env, nf_eval_nf M k (4+1) (insertEnv env r) s`, hypothesis
  `hs : nf_eval_nf M k 5 (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ ↦ t)))) s`.
  `insertEnv env r = Fin.cons r [x1,w,x,t]` forces `r = t` (false for a gap point). Unprovable.
- **Required behavior**: one of — (a) a `NormalForm` variable-permutation relabel with semantic
  transport `nf_eval M k 5 env (relabel s) ↔ nf_eval M k 5 (env ∘ perm) s` (index-0 ↔ index-last);
  or (b) a provider variant evaluating at index 0; or (c) re-architect the clause so ALL content
  is anchored at the fixed right anchor `t` (index 4) with interior ordering by marginal
  navigation only.
- **Isolation**: NO such reindex/relabel bridge exists in the active tree (only Boneyard has
  cross-*model* `∘ skipIdx` transport — different purpose; grep 2026-07-12). The bridge is SHARED
  (Past side Phase 4.2/4.3 needs the mirror), so per H7 it belongs in the FROZEN
  `ExteriorFiberK.lean` (or `PriorInterface.lean` convention), NOT a concurrently-edited side
  file. `kvE_futChainG`'s abstracted `huniq`/`hQF` confirm the CHAIN device is NOT the obstruction
  — it is strictly the content-channel↔fold slot reconciliation.

## What is needed (escalation)

Orchestrator decision + a spawned dependency (`/spawn 352`): add the index-permutation relabel +
semantic-transport lemma to the shared FROZEN `ExteriorFiberK.lean` (unfreeze for a controlled
shared addition), OR re-scope the clause architecture to anchor content at `t`. Then re-dispatch
3.2/3.3 (and symmetrically inform Past 4.2/4.3, which will hit the mirror blocker). The already-
green `kvE_futChainG`/`BuildG`/`DestructG` + clause defs are consumed unchanged by the re-dispatch.

## What Phase 5/6 (final assembly) consumes from the Future clause layer

- `kvE_extNegFut P σ` / `kvE_futPos P σ` (the negative/positive clause formulas) — DEFS landed;
  349 Phase 2 cites these to build `kvE_extBracketFut`.
- `kvE_extNegFut_sound` / `kvE_extNegFut_complete` — NOT yet available (blocked); Phase 5 interface
  exposition and Phase 6 axiom audit cannot list them until the bridge lands and 3.2/3.3 re-close.
- The generic `kvE_futChainG`/`BuildG`/`DestructG` are reusable by both the re-dispatch and (via a
  Past mirror or shared lift) Phase 4.

## Q3 record (propagated hypothesis shape, refined)

`_sound`/`_complete` will take `h_UZ`/`h_SZ` (Prior UZ/SZ) as hypotheses — confirmed: the content
obligation goes through `P.correct 4 … = kvE_fiberPosOn_correct`, which needs them, exactly as the
zone/admissibility Q3 note predicted. Order/navigation (`kvE_futRealizer_admissible`,
`kvE_futFreshProfile`) need neither.

## Verification

- Scoped `lake build …ExteriorNegationK` GREEN (1021 jobs). `sorry_count = 0`. No vacuous defs.
- `#print axioms` (`lean_verify`) on `kvE_futChainBuildG`, `kvE_futChainDestructG` = exactly
  `[propext, Classical.choice, Quot.sound]`.
- `git diff --stat` on all 7 frozen providers + KampPrior + ExteriorBracketK + ExteriorFiberK +
  the sibling `ExteriorNegationPastK.lean`: EMPTY.
- Commits: `d27eed7a6` (chain combinators), `782d8764c` (clause defs). No sorry ever committed.

## Sorry Inventory

`[]` (empty — no sorry/vacuous landed; the two headline theorems are BLOCKED and escalated, not
stubbed).

## References

- Plan: `specs/352_.../plans/01_depthk-clause-layer.md` (Phase 3 section — now `[BLOCKED]` with the
  four-element BLOCKER record).
- Prior handoffs: `phase-3-1-handoff-20260712.md` (zone/admissibility consumed),
  `phase-2-handoff-20260712.md` (fiber navigation consumed).
- Frozen templates: `ExteriorNegation.lean` :1072–:1140 (defs), :1180/:1435/:1243/:1484 (chain +
  sound/complete). Interface: `PriorInterface.lean:38-46`; fold bridge `NfEFold.lean:608-632`.
