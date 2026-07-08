# Task 334 — Phase 3 Summary: Multi-anchor region-partition lift

- **Phase**: 3 of 9 (`k1v_sorted_realizationK`)
- **Status**: COMPLETED (green, sorry-free, axiom-clean)
- **File modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SubBracket2V.lean` (additive only)
- **Session**: sess_1783539835_7b6867

## What was built

Generalized the proven three-region `k1v_sorted_realization3` (SubBracket2V:379) to a **k-region**
partition, reusing the single-region engine `k1v_sorted_realization` (CarrierK1V:1447) verbatim per
region. Region skeleton encoded as `regions : List (lo × hi × S)` with anchors strictly ordered via
`hpos : loᵢ < hiᵢ` and boundary-linked via `hlink : List.Chain' (fun a b => a.2.1 = b.1)` (i.e.
`hiᵢ = loᵢ₊₁` — the shared interior anchor, Def 3.1 md:61-74).

| Lemma / def | Role |
|-------------|------|
| `interleaveK` | k-region interleave: blocks separated by interior anchors, final outer anchor dropped (exactly as `k1v_sorted_realization3` excludes `t`). For `[(x,x1,psXU),(x1,w,psUW),(w,t,psWT)]` yields `psXU.snd ++ x1 :: psUW.snd ++ w :: psWT.snd`. |
| `k1v_stitch_lowers_ge` (private) | Monotone-lower-bounds helper: a bound below the first region's lower anchor is below every region's lower anchor (via `hlink`+`hpos`). |
| `k1v_stitch_regions` | k-region stitch: `interleaveK regs` is `Pairwise (· < ·)` and every point exceeds the global left bound `lo`. The k-fold lift of the three-region "every UW point exceeds `x1`, every left-block point `< w`" stitch. |
| `k1v_realizationK_build` (private) | Folds `k1v_sorted_realization` once per region, producing the point-tagged arrangement list mirroring the region skeleton plus the anchor `Chain'`/positivity feeding the stitch. |
| `k1v_sorted_realizationK` | **Headline**: per-region point lists whose stitched concatenation `interleaveK ps` is `Pairwise (· < ·)`; per-region perm/sortedness/realization carried in a `List.Forall₂` correspondence. |
| `k1v_sorted_realizationK_regress_k3` | **Regression check**: instantiates `k1v_sorted_realizationK` at the 3-region list and recovers `k1v_sorted_realization3`'s exact conclusion shape (three perms + the `psXU.snd ++ x1 :: psUW.snd ++ w :: psWT.snd` Pairwise). |

## Verification

- `lake build …SubBracket2V` — green (1011 jobs).
- `lean_verify` on `k1v_sorted_realizationK`, `k1v_stitch_regions`, `k1v_sorted_realizationK_regress_k3`:
  all `[propext, Classical.choice, Quot.sound]`, **no `sorryAx`**.
- No new sorries; no vacuous definitions; no new axioms.
- Preserved assets (`k1v_sorted_realization3`, `k1v_sorted_realization`, and all downstream in the
  build graph) remain green — additive-only change, both engines untouched.

## Faithfulness invariants (all 7 preserved; actively exercised: F1, F3, F4, F7)

- **F1** (QF region types): region types unchanged; only an order-theoretic stitch on carriers added.
- **F3** (anchor cap): per-region interior witnesses; `x1,w,…` stay interior, no new free anchors.
- **F4** (no-nesting / LITMUS): no `x1 < e_i` literal — the stitch is purely order-theoretic on
  `M.carrier`, no formula nesting.
- **F7** (macro-side confinement): co-located with the region engine in `SubBracket2V.lean`
  (F7-preferred narrowest additive scope); `SubBracket2.lean`, `CarrierK1V.lean` unchanged.

## `.permutations`-as-disjunction reuse (Phase 3 task 3)

The `List.Forall₂` conclusion carries `List.Perm (p.2.2.map Prod.fst) r.2.2` **per region**, so each
region's selected arrangement is a permutation of that region's own type list — precisely what the
existing per-region `S_z.permutations` flatMap enumerates (`kvE_subBracket2V` SubBracket2V:249-251).
The k-region lift arranges each region independently: the machinery reuses per region with no
cross-owner coupling at anchors (distinctness stays type-driven via `nf_eval_unique`, NormalForm:245).

## Next

Phase 4 (closed-zone compat leaf + three-way segment-meet cut, LEFT) is now unblocked — it depends
on Phases 2 and 3, both complete. `k1v_sorted_realizationK` is the k-anchor region lift Phases 4/6/7
consume.
