# Task 352 Phase 2 Handoff — 2026-07-12

## Immediate Next Action (Wave 3: Phases 3.1 and 4.1, parallelizable under H7)

Both sides now consume the FROZEN `ExteriorFiberK.lean`. Dispatch Phase 3.1
(`ExteriorNegationK.lean`, NEW) and Phase 4.1 (`ExteriorNegationPastK.lean`, NEW) — each owns
exactly its own file, must NOT touch the other side's file or `ExteriorFiberK.lean` (H7
territory). Phase 3.1 first task: depth-k analogs of the zone/admissibility layer on the
`kvE2_futPos` cone (`kvE_futPossibleZones`, `kvE_futZoneClass`, `kvE_futAdmissible`,
`kvE_futFreshProfile`, `kvE_futRealizer_admissible`; templates ExteriorNegation.lean
:902/:915/:983/:996/:1010), navigation reads via Phase-2 buckets + landed core only (G6).

## Current State

- **Phases 1-2 [COMPLETED].** Phases 3-6 [NOT STARTED]. `phases_completed: 2 / 6`.
- `ExteriorFiberK.lean` is now FROZEN for waves 3-5 (any needed shared addition escalates to
  the orchestrator; never edited concurrently by a side).
- Sorry count: 0. Scoped `lake build` of `...ExteriorFiberK` green (1020 jobs).
- Axioms exactly `[propext, Classical.choice, Quot.sound]` on all Phase-2 headline decls
  (`kvE_fiberBucket_nonempty_iff`, `kvE_fiber_dropFresh`, `kvE_minPick`, all mem/nodup decls).
- Frozen diffs EMPTY on all 7 providers + KampPrior + ExteriorNegation(Past) + ExteriorBracketK
  at the commit.
- Commit: `57b2e3219` (phase 2).

## Landed Phase-2 interface (what waves 3-5 consume from `ExteriorFiberK.lean`)

All in namespace `Bimodal.Metalogic.WeakCanonical.Kamp`:

- `kvE_fiber_dropFresh M env σ hσ s hs : nfk_dropFresh s = σ.1` — realized σ pins every
  positive fiber element onto σ's atom fiber (off-fiber clause of `nf_eval_nfk_iff_efold`).
- `kvE_fiber_nodup σ : (kvE_fiber σ).Nodup`.
- `kvE_fiberBucket σ (zs4 : ZoneSpec 4) (χ : NormalForm sig k 1) : List (NormalForm sig k 5)`
  — fiber elements with `nfk_zoneSpec s = zs4 ∧ nfk_projFresh s = χ`.
  - `kvE_fiberBucket_mem σ zs4 χ s : s ∈ ... ↔ σ.2 s = true ∧ nfk_zoneSpec s = zs4 ∧
    nfk_projFresh s = χ`
  - `kvE_fiberBucket_nodup σ zs4 χ`
  - `kvE_fiberBucket_nonempty_iff M env σ hσ zs4 χ : (∃ s, s ∈ kvE_fiberBucket σ zs4 χ) ↔
    ∃ v, zoneHolds M env zs4 v ∧ nf_eval_nf M k 1 (fun _ => v) χ` — the bucket-honesty pin
    (reduces to `kvE_subBit_iff`; navigation-only, G6). CONTENT is separately rendered by
    `kvE_fiberPosOn P (kvE_fiberBucket σ zs4 χ)` (Phase-1 decl).
- `kvE_fiberZoneList σ (zs4 : ZoneSpec 4) : List (NormalForm sig k 5)` — zone-only bucket, the
  depth-k `kvE2_futGapList`/`kvE2_futRayList` analog. `_mem`, `_nodup` provided. Instantiate
  with each side's gap/ray/self zone specs (Future gap head-coupling `(true,false)`, ray
  `(false,true)`, self `(false,false)` over `kvE2_sep_zFutT3` — see `kvE2_futPossibleZones`,
  ExteriorNegation.lean:902; Past is the mirror).
- `kvE_minPick M (P : α → M.carrier → Prop) l hne hocc : ∃ a₀ ∈ l, ∃ r₀, P a₀ r₀ ∧ ∀ a ∈ l,
  ∃ r, P a r ∧ r₀ ≤ r` — generic min-witness pick (feeds the chain builder, Phase 3.2/3.3).

## Key Decisions

1. **Bucket keyed by `(nfk_zoneSpec, nfk_projFresh)`** matching `kvE_subBit`'s key exactly, so
   the honesty lemma is a direct `kvE_subBit_iff` reduction — the only extra ingredient is the
   atom-fiber label, supplied by `kvE_fiber_dropFresh` (off-fiber clause). No new determinacy
   reasoning; the landed core is consumed verbatim (postmortem rule 6).
2. **Honesty stated as bucket-nonemptiness ↔ zone/profile fact** (not content) — G6 compliant.
   Content is `kvE_fiberPosOn` on the bucket sub-list, kept a separate channel.
3. **`kvE_fiberZoneList` left side-agnostic** (zone-only, no future/past commitment) so both
   Phase 3 and Phase 4 instantiate it — honors the H7 side-shared/no-concurrent-edit contract.
4. **`kvE_minPick` replicated verbatim** (it is already `{α : Type}`-generic in the frozen
   file), non-private, one shared copy for both sides.

## Q4 record

CONFIRMED atom-layer-only: every zone read in the Phase-2 code is `nfk_zoneSpec s` on a fiber
element `s : NormalForm sig k 5`, and `nfk_zoneSpec s := nf0_zoneSpec s.atom_assgn`
(NfEFold.lean:586-588) reads the atom layer only. No `nf0_zoneSpec` is applied to any quant
layer; the sole textual `nf0_zoneSpec` is in the section docstring.

## Sorry Inventory

`[]` (empty — clean phase).

## References

- Plan: specs/352_.../plans/01_depthk-clause-layer.md (Phase 3/4 sections; Postmortem
  Constraints + Constraints bind all dispatches).
- Determinacy core consumed: ExteriorBracketK.lean (kvE_subBit :302, kvE_subBit_iff :314,
  kvE_fiber Phase-1 :52). Fold bridge: NfEFold.lean nf_eval_nfk_iff_efold :627.
- Templates (read-only, NOT imported): ExteriorNegation.lean kvE2_futGapList :890,
  kvE2_futPossibleZones :902, kvE2_futMinPick :1146.
