# Task 352 Phase 3.1 (Future side) Handoff — 2026-07-12

Per-side handoff (Wave 3, H7 Future territory). The orchestrator merges this with the Past-side
(Phase 4.1) result; this is NOT the shared `.orchestrator-handoff.json`.

## Status

**COMPLETED (zone/admissibility layer)** — all 5 named decls green, sorry-free, axiom-clean.
Commit `c738b9236`. File owned: `ExteriorNegationK.lean` (NEW, 199 lines). Frozen diffs EMPTY
(incl. ExteriorFiberK.lean). Did NOT touch the sibling's `ExteriorNegationPastK.lean`.

## Decls landed (`Bimodal.Metalogic.WeakCanonical.Kamp`, in `ExteriorNegationK.lean`)

1. `kvE_futPossibleZones : List (ZoneSpec 4) := kvE2_futPossibleZones` — depth-independent.
2. `kvE_futZoneClass … : zs ∈ kvE_futPossibleZones` — reuses the frozen public
   `kvE2_futZoneClass` (pure `ZoneSpec 4` geometry, no fold-depth dependence).
3. `kvE_futSelfZone : ZoneSpec 4 := Fin.cons (false, false) kvE2_sep_zFutT3` (self point = `x1`).
4. `kvE_futAdmissible (σ : NormalForm sig (k+1) 4) : Bool` — 4 conjuncts (see design note).
5. `kvE_futFreshProfile … : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)` — atom-layer
   fresh profile, same statement as frozen `kvE2_futFreshProfile` (`σ.1` is depth-0 at every k).
6. `kvE_futRealizer_admissible … : kvE_futAdmissible σ = true` — a realizer forces admissibility.

## Key design decisions (grounded in the depth-k core, not re-derived)

- **`kvE2_futPossibleZones`/`kvE2_futZoneClass` are already in scope.** `ExteriorNegation.lean` is
  in `ExteriorFiberK`'s transitive import closure (via `ExteriorBracketK → ExteriorBracket → …`),
  so its PUBLIC geometry decls are reachable with no new import and no edit (git diff stays empty).
  The private geometry helpers (`kvE2_futZone4_of_above/CharZone4/BelowClass`) are NOT reachable,
  but are not needed because the public `kvE2_futZoneClass` is reused whole.
- **`NormalForm sig (k+1) n = ⟨.1 : NormalForm sig 0 n (atom layer), .2 : NormalForm sig k (n+1)
  → Bool⟩`.** So `σ.1 : NormalForm sig 0 4` is the depth-0 atom layer at EVERY fold depth. That is
  why the base-zone-marking (conjunct 1) and the fresh profile are depth-0 objects, provable from
  the realizer's atom layer exactly as frozen.
- **Admissibility swaps `nf0_assemble` for `kvE_subBit`** (postmortem rule 1; `nf0_assemble` is
  lossless only at depth 0). Conjunct 2 (off-fiber) uses the fold off-fiber clause of
  `nf_eval_nfk_iff_efold`; conjunct 3 (order-impossible zones) uses `kvE_subBit_iff` + reused
  `kvE_futZoneClass`. All are navigation reads (G6): content is NOT rendered here.
- **Conjunct 4 reformulated as self-zone profile UNIQUENESS.** The frozen conjunct 4 pins the
  self-zone bit to `decide (χ = nf0_projFresh σ.1)`. At depth k the self point's profile is a
  DEPTH-k object `nfk_projFresh s : NormalForm sig k 1`, not determined by `σ.1` (the atom layer
  only). So the faithful, realizer-derivable depth-k statement is "all self-zone-prescribed
  profiles coincide" (proved via `kvE_subBit_iff` → self point `= x1` → `nf_eval_unique M k`).
  This keeps the endpoint fresh profile well-defined without a `σ.1` marginal read (G6-safe).

## Verification

- Scoped `lake build …ExteriorNegationK` GREEN (1021 jobs). 0 sorries. No vacuous defs.
- `#print axioms` on `kvE_futZoneClass`, `kvE_futAdmissible`, `kvE_futFreshProfile`,
  `kvE_futRealizer_admissible` = exactly `[propext, Classical.choice, Quot.sound]`.
- `git diff --stat` on all 7 frozen providers + KampPrior + ExteriorBracketK + ExteriorFiberK:
  EMPTY. Only new untracked file is `ExteriorNegationK.lean`.

## Q3 record (propagated hypothesis shape)

- `kvE_futRealizer_admissible`: needs NO `h_UZ`/`h_SZ` — order-bits only (mirrors frozen).
- `kvE_futFreshProfile`: needs only the atom-layer realization `hatomσ` (no Prior hypotheses).
- `h_UZ`/`h_SZ` will enter at the CONTENT layer (3.2/3.3) through `kvE_fiberPosOn_correct` /
  `P.correct 4`, exactly as the frozen `kvE2_*_sound/_complete` consume them.

## What Phase 3.2/3.3 (chain builder) consumes from this dispatch

- `kvE_futAdmissible σ` as the positive-form GUARD (`kvE_futPos := if kvE_futAdmissible σ then …
  else ⊥`, template :1124), and `kvE_futRealizer_admissible` to discharge the guard from a
  realizer in `_complete` (and its contrapositive — inadmissible ⟹ no realizer — in `_sound`).
- `kvE_futZoneClass` / `kvE_futPossibleZones` for the exhaustive zone case-split in the chain
  soundness argument (Cor 5.4 y1/y2 split).
- `kvE_futSelfZone` + the uniqueness conjunct for the endpoint (`kvE_futEnd`) fresh-profile pin:
  the endpoint content is `kvE_fiberPosOn P (kvE_fiberBucket σ kvE_futSelfZone χ*)` for the unique
  self profile `χ*` (G6 — content on the `kvE_fiberPosOn` channel, navigation via the bucket).
- Gap/ray zone lists: instantiate the Phase-2 `kvE_fiberZoneList σ zs4` with the Future gap
  head-coupling `(true,false)` / ray `(false,true)` over `kvE2_sep_zFutT3` (per Phase-2 handoff).

## Deferred (NOT in this sub-dispatch scope; flagged for follow-up 3.1 or 3.2)

- Clause-form defs (`kvE_futGapD`/`RayD`/`RayForm`/`End`/`Chain`/`Pos`/`extNegFut`, templates
  :1072–:1136), parameterized `(atomMap) (h_surj) (P : ExistProviders sig atomMap k) (σ)`, content
  via `kvE_fiberPosOn` (postmortem rule 3). These were not part of the zone/admissibility scope.

## Sorry Inventory

`[]` (empty — clean dispatch).

## References

- Plan: `specs/352_.../plans/01_depthk-clause-layer.md` (Phase 3 section; Postmortem Constraints +
  Constraints bind).
- Template (read-only, already transitively imported): `ExteriorNegation.lean` :902/:915/:983/
  :996/:1010.
- Consumed core: `ExteriorBracketK.lean` (`kvE_subBit` :302, `kvE_subBit_iff` :314); fold bridge
  `NfEFold.lean` `nf_eval_nfk_iff_efold` :627; zone-bit transfer `ExteriorZoneTriage.lean`
  `kvE2_zoneBit_above` :80. Phase-2 fiber interface: `ExteriorFiberK.lean` (FROZEN, consumed).
