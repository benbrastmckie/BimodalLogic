# Critical Path Wiring: bx_completeness → sorry-free

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Actual dependency chain from bx_completeness to sorry sites

---

## 1. The Sorry Chain

```
completeness_discrete (= bx_completeness)
  ├── sorry (dense case, line 281) — out of scope
  ├── sorry (mixed case, line 290) — out of scope
  └── countermodel_discrete_enriched (sorry, line 227)
       └── [should delegate to] countermodel_discrete (Transfer.lean:481)
            └── dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:3285)
                 ├── fully_restricted_parametric_completeness_from_neg_membership — SORRY-FREE ✓
                 ├── cantor_bfmcs_discrete — SORRY-FREE ✓
                 ├── cantor_bfmcs_discrete_restricted_buc — SORRY-FREE ✓
                 ├── cantor_bfmcs_discrete_restricted_tc — has sorryAx
                 │    └── succ_embed_surjective — has sorryAx
                 │         └── limitDomSubtype_isSuccArchimedean — has sorryAx
                 │              └── succ_cofinal — ROOT SORRY (line 1508)
                 └── cantor_bfmcs_discrete_restricted_fuc — has sorryAx
                      └── succ_embed_surjective (same chain)
```

## 2. The Root Sorry: succ_cofinal

`succ_cofinal` (ChronicleToCountermodel.lean:1508) claims: for any a < b in LimitDomSubtype, there exists n such that succ^[n](a) ≥ b. This is IsSuccArchimedean for the limit domain.

The sorry is genuine — the limit domain CAN have gaps between succ iterates (the succ_cofinal section comments explain this). Task 129 was the original plan to close it; task 155 (Reynolds pipeline) was designed to BYPASS it.

## 3. Two Independently Sorry'd Entry Points

`completeness_discrete` has TWO separate sorry paths to `sorryAx`:

1. **countermodel_discrete_enriched** (Completeness.lean:227) — directly sorry'd. This is supposed to use `countermodel_discrete` from Transfer.lean but doesn't.

2. **Dense/mixed case sorries** (Completeness.lean:281, 290) — out of scope for task 155 (these are separate completeness variants).

## 4. The Fix: Wire countermodel_discrete_enriched

`countermodel_discrete_enriched` at Completeness.lean:227 is just `sorry`. It needs to call `countermodel_discrete` from Transfer.lean. The types may not match exactly (enriched returns `∃ (F : TaskFrame Int)...` while countermodel_discrete returns `∃ (D : Type)...`).

**Fix**: Replace the sorry with a call to `countermodel_discrete`, specializing D = Int from the existential.

BUT: `countermodel_discrete` itself carries `sorryAx` from `succ_cofinal`. So even after wiring, `completeness_discrete` still has `sorryAx`.

## 5. The Reynolds Bypass

To eliminate `succ_cofinal`, `countermodel_discrete` must NOT delegate to `dd_countermodel_chronicle_discrete`. Instead, it should use:

1. The chronicle's MCS family (sorry-free)
2. `chronicle_is_good` (sorry-free) → the chronicle IS a Z-interval structure
3. The Z-interval countermodel (IntegerModel.lean) → TaskFrame Int

The Z-interval countermodel construction is already sorry-free (`chronicle_is_good` gives an OrderIso to Z, which gives a TaskFrame Int directly).

The MISSING piece is: the truth transfer. `dd_countermodel_chronicle_discrete` proves that the countermodel falsifies φ using `fully_restricted_parametric_completeness_from_neg_membership` + coherence conditions (TC, BUC, FUC). The coherence conditions for TC and FUC carry `succ_cofinal`.

**The Reynolds bypass must provide alternative proofs of TC and FUC** that don't use `succ_cofinal`. Two approaches:

### Approach A: Bypass succ_embed_surjective entirely

If `chronicle_is_good` gives OrderIso to Z, then we have a direct map from Z to the chronicle domain (and back). Use this OrderIso instead of `succ_embed` for the coherence proofs. The OrderIso is sorry-free and automatically surjective.

### Approach B: Prove succ_cofinal using gap elimination

Use the gap elimination theorem (Reynolds Theorem 14) to show the limit domain has no gaps between succ iterates. This would close succ_cofinal directly. But Theorem 14 requires the full Reynolds pipeline (Phases 5-6B) which is NOT formalized.

## 6. Minimum Changes for Sorry-Free bx_completeness

| Change | File | Lines | Difficulty |
|--------|------|-------|-----------|
| Wire countermodel_discrete_enriched → countermodel_discrete | Completeness.lean | ~10 | Easy |
| Replace dd_countermodel_chronicle_discrete delegation with OrderIso-based construction | Transfer.lean | ~100-200 | Medium |
| Prove TC/FUC coherence via OrderIso (not succ_embed) | Transfer.lean or new file | ~200-300 | Medium-Hard |
| **Total** | | ~310-510 | Medium-Hard |

**Key insight**: The OrderIso from `chronicle_is_good` (sorry-free) provides a DIRECT bijection between Z and the chronicle domain. This makes `succ_embed_surjective` trivial (the OrderIso IS surjective). The coherence conditions (TC, FUC) can be proved by composing the OrderIso with the limit_F/P_resolution lemmas.

## 7. What About EFGames.lean Sorry Sites?

`stavi_expressive_completeness` and `ghr93_decomposition_implies_game` are **orphaned** — not referenced by `dd_countermodel_chronicle_discrete` or any code on the critical path. They are standalone theorems that formalize GHR93 but aren't wired into the completeness proof.

The Reynolds pipeline as originally conceived would:
1. Use `stavi_expressive_completeness` to get temporal formulas for any monadic property
2. Use gap elimination (Theorem 14) to show gaps don't exist in Prior structures
3. Construct countermodel without succ_cofinal

But the SIMPLER bypass (Approach A above) doesn't need any of this. It just uses `chronicle_is_good` (already sorry-free) + OrderIso for the coherence proofs.

## 8. Summary

| Finding | Detail |
|---------|--------|
| Root sorry | `succ_cofinal` (ChronicleToCountermodel.lean:1508) |
| Propagation chain | succ_cofinal → IsSuccArchimedean → succ_embed_surjective → TC/FUC → dd_countermodel → countermodel → completeness |
| countermodel_discrete_enriched | Directly sorry'd (not wired to countermodel_discrete) |
| EFGames sorry sites | ORPHANED (not on critical path) |
| Minimum fix | OrderIso-based coherence proofs (~310-510 lines) bypass succ_cofinal |
| chronicle_is_good | Already sorry-free — provides the OrderIso |
| **Recommendation** | Approach A: Use chronicle_is_good OrderIso for coherence, bypass succ_embed entirely |
