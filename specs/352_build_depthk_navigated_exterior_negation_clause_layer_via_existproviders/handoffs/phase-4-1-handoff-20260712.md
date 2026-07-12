# Task 352 Phase 4.1 Handoff (Past side) — 2026-07-12

Per-side handoff (Wave 3, H7 Past territory). The orchestrator merges this with the Future-side
(Phase 3.1) result. NOT the shared `.orchestrator-handoff.json`.

## Status

**implemented** — Phase 4.1 (Past-side depth-`k` zone/admissibility navigation layer) green,
sorry-free, axiom-clean. Scoped `lake build` GREEN (1021 jobs). One dispatch.

- Session: `sess_1783887769_cb5be4`
- File OWNED/created: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationPastK.lean` (NEW, 178 lines)
- Commit (green milestone): see `task 352 phase 4.1` commit.

## Verification

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationPastK` — GREEN.
- Sorries: 0. Vacuous/placeholder defs: 0. `nf_char3_deeper_split`: 0 uses.
- Axioms (via `lean_verify`) exactly `[propext, Classical.choice, Quot.sound]` on every headline decl:
  `kvE_pastZoneClass`, `kvE_zoneHolds_of_atom`, `kvE_pastFreshProfile`, `kvE_pastAdmissible`,
  `kvE_pastRealizer_admissible`.
- `git diff --stat` EMPTY on all 7 frozen providers + KampPrior + ExteriorNegation(Past) +
  ExteriorBracketK + ExteriorFiberK + PriorInterface. ExteriorFiberK consumed UNCHANGED.
- G6: every decl is navigation-only (zone/order/fiber-membership reads); NO content-bearing
  formula is rendered in this file. Content stays on the `kvE_fiberPosOn` channel (Phase 1).

## Decls landed (all in namespace `Bimodal.Metalogic.WeakCanonical.Kamp`)

1. `kvE_pastPossibleZones : List (ZoneSpec 4)` — depth-`k` interface alias of the reachable
   public frozen `kvE2_pastPossibleZones` (depth-independent: `ZoneSpec 4`, no depth index).
2. `kvE_pastZoneClass M v x1 w x t hxw hwt hx1x zs hz : zs ∈ kvE_pastPossibleZones` — thin
   wrapper of the reachable public frozen `kvE2_pastZoneClass` (depth-independent).
3. `kvE_zoneHolds_of_atom M env v s (hv : nf_eval_nf M k 5 (Fin.cons v env) s) :
   zoneHolds M env (nfk_zoneSpec s) v` — **reusable navigation leaf**: reads a realized sub's
   zone back off its atom layer (`nf_eval_nf_atom_layer`). Used by admissibility below and
   available to 4.2/4.3.
4. `kvE_pastFreshProfile M σ x1 w x t hatomσ : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)`
   — realizer's fresh point (`x1`) carries σ's depth-0 atom fresh profile. Reduces to the
   reachable public `kvE2_futFreshProfile` via the depth-1 atom carrier `⟨σ.1, fun _ => false⟩`.
5. `kvE_pastAdmissible (σ : NormalForm sig (k+1) 4) : Bool` — the depth-`k` order-admissibility
   Bool: `(nf0_zoneSpec σ.1 = kvE2_sep_zPastX3)` ∧ (off-fiber: every positive fiber element has
   `nfk_dropFresh s = σ.1`) ∧ (order-possible: every positive fiber element's `nfk_zoneSpec s`
   ∈ `kvE_pastPossibleZones`). Reads the FULL fiber `NormalForm sig k 5` directly — NOT the
   depth-0-hardwired `σ.2 (nf0_assemble zs χ σ.1)` (F2-lossy at depth `k ≥ 1`).
6. `kvE_pastRealizer_admissible M σ x1 w x t hxw hwt hx1x hnf : kvE_pastAdmissible σ = true` —
   a realizer at exterior `x1 < x` FORCES admissibility. Order-bits only, no semantic
   hypothesis on `M`. Proof: `nf_eval_nfk_iff_efold` decomposition → (1) `kvE2_zoneBit_below`
   on the atom layer, (2) off-fiber clause, (3) `kvE_zoneHolds_of_atom` + `kvE_pastZoneClass`.

## Key decisions

1. **Import chain reality (supersedes the plan's "frozen NOT imported" default).** `ExteriorFiberK`
   already transitively imports `ExteriorBracket → ExteriorNegationPast → ExteriorNegation`, so the
   frozen files' **public** depth-independent decls are directly reachable. The depth-independent
   navigation facts (`kvE2_pastPossibleZones`, `kvE2_pastZoneClass`, `kvE2_zoneBit_below`,
   `kvE2_futFreshProfile`) are REUSED verbatim rather than replicated — importing is not editing;
   frozen `git diff` stays EMPTY. The private zone helpers (`kvE2_pastAboveClass`,
   `kvE2_pastCharZone4`, …) are inaccessible but NOT needed (they are internal to the reused
   public `kvE2_pastZoneClass`).
2. **Full-fiber navigation (G6).** `kvE_pastAdmissible` reads `σ.2 s` directly on full fiber
   elements `s : NormalForm sig k 5` through their navigation coordinates (`nfk_dropFresh`,
   `nfk_zoneSpec`), never through `nf0_assemble` marginals (postmortem rules 2-3).
3. **Q3 (hypothesis shape).** For the zone/admissibility layer: `kvE_pastRealizer_admissible`
   needs NO `h_UZ`/`h_SZ` (order-bits only); `kvE_pastFreshProfile` needs only the atom-layer
   realization. `h_UZ`/`h_SZ` will enter at the CONTENT layer (4.2/4.3) via `P.correct` /
   `kvE_fiberPosOn_correct`, as expected. (Matches the sibling's Future-side Q3 note.)

## CROSS-SIDE DIVERGENCE — orchestrator action required (Wave-3 reconciliation)

The frozen k=2 admissibility has FOUR conjuncts; conjunct (4) is the self-zone bit pattern
`kvE2_pastSelfBit σ χ = decide (χ = nf0_projFresh σ.1)` (a CONTENT-pinning condition — it fixes
the self point's profile). At depth `k` the self point's profile is fiber-borne
(`nfk_projFresh s : NormalForm sig k 1`, model-determined) with NO σ-syntactic depth-`k` target,
so it does not translate as a σ-marginal pin.

- **This Past side (4.1)** landed a **3-conjunct order-admissibility** (marking + off-fiber +
  order-possible-zones). The self zone is simply one of the nine `kvE_pastPossibleZones`; its
  content is carried downstream by the full-fiber channel `kvE_fiberBucket σ (self zone) χ` +
  `kvE_fiberPosOn` in 4.2/4.3. `kvE_pastFreshProfile` is exposed for the self-point atom-profile
  identification 4.2/4.3 needs.
- **The Future side (3.1)**, per the sibling's plan-file note, KEPT a 4th conjunct, reformulated
  as "self-zone profile UNIQUENESS at depth `k`".

**Recommendation.** The orchestrator should standardize the two sides' admissibility contract
before Phase 5 (k=0 recovery agreement) and before 349's re-dispatch consumes both. If the
Future side's 4th self-zone-uniqueness conjunct is retained, dispatch a short symmetrizing
follow-up to add the mirror conjunct here: the Past self zone is
`Fin.cons (false, false) kvE2_sep_zPastX3`; uniqueness is provable from
`kvE_zoneHolds_of_atom` (self zone forces `v = x1`) + `nf_eval_projFresh` +
`nf_eval_unique M k 1`. The 3-conjunct core landed here is a strict prefix, so adding the
conjunct is additive (no rework). Alternatively, confirm both sides settle on order-only
admissibility with the self point handled purely by the fiber channel (my current design).

## What Phase 4.2 / 4.3 (past chain builder) will consume from this layer

- `kvE_pastPossibleZones` / `kvE_pastZoneClass` — the zone universe + classification for the
  `Since`-chain zone buckets (instantiate `kvE_fiberZoneList σ zs4` with the Past gap zone
  `Fin.cons (false, true) kvE2_sep_zPastX3`, ray `Fin.cons (true, false) kvE2_sep_zPastX3`, self
  `Fin.cons (false, false) kvE2_sep_zPastX3` — the frozen `kvE2_pastPossibleZones` couplings).
- `kvE_pastAdmissible` / `kvE_pastRealizer_admissible` — the admissibility gate for `kvE_pastPos`
  (positive form is `⊥` when inadmissible; a realizer forces admissibility, so `_sound` is
  unconditional). Mirror of the frozen `kvE2_pastPos` `if kvE2_pastAdmissible σ then … else ⊥`.
- `kvE_zoneHolds_of_atom` — the realizer→zone read-back for every chain-step zone obligation.
- `kvE_pastFreshProfile` — the endpoint (self-point `x1`) profile identification.
- Phase-2 buckets (`kvE_fiberBucket` + `_mem`/`_nonempty_iff`, `kvE_fiberZoneList`,
  `kvE_fiber_dropFresh`, `kvE_minPick`) + content channel `kvE_fiberPosOn P bucket` +
  `kvE_fiberPosOn_correct` (Phase 1) — CONTENT rendering (G6: `P.existF` on full elements).
- Chain shape template: frozen `kvE2_pastChain`/`kvE2_pastPos`/`kvE2_extNegPast`
  (`ExteriorNegationPast.lean:446/461/473`), `Since` for `Until`, content disjuncts swapped from
  `nf_depth0_char_formula χ` to `kvE_fiberPosOn P bucket`. `_sound` template `:581`,
  `_complete` template `:855` (full-fiber `hbelow`-pin shape).

## Sorry Inventory

`[]` (empty — clean phase).

## Blockers

None.

## References

- Plan: `specs/352_.../plans/01_depthk-clause-layer.md` (Phase 4 section; Postmortem Constraints
  + Constraints bind).
- Phase-2 handoff: `specs/352_.../handoffs/phase-2-handoff-20260712.md` (consumable interface).
- Determinacy core: `ExteriorBracketK.lean` (`kvE_subBit_iff :314`, `nf_eval_projFresh :163`,
  `nf_eval_unique`). Fold bridge: `NfEFold.lean` (`nf_eval_nfk_iff_efold :627`,
  `nf_eval_nf_atom_layer :593`, `nfk_zoneSpec :586`, `nfk_dropFresh :578`).
- Reused public frozen decls: `kvE2_pastPossibleZones`/`kvE2_pastZoneClass`
  (`ExteriorNegationPast.lean:250/264`), `kvE2_zoneBit_below` (`ExteriorZoneTriage.lean:65`),
  `kvE2_futFreshProfile` (`ExteriorNegation.lean:996`), zone constants (`SharedWitness.lean:71+`).
