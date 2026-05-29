# succ_cofinal Dependency Trace

**Task**: 202 — Reynolds Theorem 14 (no-gaps)
**Date**: 2026-05-29
**Purpose**: Trace exactly where and why `succ_cofinal` enters the discrete completeness pipeline

## 1. Definition and Type Signature

`succ_cofinal` is at `ChronicleToCountermodel.lean:1553`:

```lean
private theorem succ_cofinal (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
    ∃ n, b ≤ (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a
```

**Status**: sorry (line 1885). The proof attempt runs ~340 lines using a real-analysis convergence argument but fails to close the gap.

## 2. Semantic Meaning

In the discrete `LimitDomSubtype` (the chronicle's ordered domain embedded in the rationals), for any two points `a < b`, finitely many applications of the successor function starting from `a` will reach or surpass `b`. Equivalently: **the successor orbit of any point is cofinal** — the domain is a single omega-chain (isomorphic to ℤ) with no inaccessible elements above any successor orbit.

## 3. Exact Dependency Chain

```
succ_cofinal (sorry, line 1885)
  └─> limitDomSubtype_isSuccArchimedean (line 1893)
       ├─> succ_embed_surjective (line 2817)
       │    ├─> cantor_bfmcs_discrete_restricted_tc (line 3142) [TC coherence]
       │    └─> cantor_bfmcs_discrete_restricted_fuc (line 3197) [FUC coherence]
       │         └─> dd_countermodel_chronicle_discrete (line 3285) [OLD pipeline]
       └─> extract_chronicle_as_prior (ChronicleExtraction.lean:178) [field: domain_succ_archimedean]
            └─> countermodel_discrete_reynolds (Transfer.lean:803) [REYNOLDS pipeline]
```

## 4. Entry Points by Pipeline

### Old BFMCS Pipeline
- `cantor_bfmcs_discrete` itself (line 2997) is **sorry-free** — it builds the families without needing IsSuccArchimedean.
- `cantor_bfmcs_discrete_restricted_buc` (line 3066) is **sorry-free** — uses squeeze lemma, not surjectivity.
- `cantor_bfmcs_discrete_restricted_tc` (line 3142) **uses `succ_embed_surjective`** — needs sorry.
- `cantor_bfmcs_discrete_restricted_fuc` (line 3197) **uses `succ_embed_surjective`** — needs sorry.
- **Conclusion**: The sorry enters through **coherence proofs** (TC, FUC), not the family construction.

### Reynolds Pipeline
- `extract_chronicle_as_prior` (ChronicleExtraction.lean:178) fills `domain_succ_archimedean` with `limitDomSubtype_isSuccArchimedean` — **carries the sorry from Step 1**.
- `chronicle_is_good_direct` (ShiftAndGlue.lean:937) calls `one_class_archimedean` which requires `[IsSuccArchimedean M.carrier]` — **consumes the sorry**.
- The docstring claims "Sorry-free" but this is **relative to its input**. The sorry is baked into the `ChronicleAsPriorModel`.
- **Conclusion**: Steps 1-7 of the Reynolds pipeline already carry `succ_cofinal` through `extract_chronicle_as_prior`.

## 5. Avoidability Analysis

| Path | Avoids `succ_cofinal`? | Alternative Sorry |
|------|----------------------|-------------------|
| Old BFMCS pipeline | No (needs TC, FUC) | N/A |
| Reynolds via `one_class_archimedean` | No (needs `IsSuccArchimedean`) | N/A |
| Reynolds via `no_gaps_discrete` | **Yes** | `no_gaps_discrete` (GoodStructures.lean:820) |

The `no_gaps_discrete` path (Reynolds Theorem 14) would bypass `succ_cofinal` entirely — it proves `chronicle_is_good` via the gap-formula argument rather than the archimedean shortcut. But `no_gaps_discrete` itself has a sorry, which is exactly what task 202 aims to discharge.

## 6. Key Insight

Both pipelines ultimately need the same thing: that the chronicle domain is "well-behaved" enough to support countermodel construction. The two ways to establish this are:

1. **Archimedean path** (`succ_cofinal` → `IsSuccArchimedean` → `one_class_archimedean`): Prove the domain has no gaps directly.
2. **Model surgery path** (`no_gaps_discrete` → Reynolds Theorem 14): Prove that k-equivalence classes have boundary points, enabling surgery to produce a ℤ-interval model.

Task 202's plan v6 pursues path (2). If successful, `no_gaps_discrete` is proved, `succ_cofinal` becomes dead code, and both pipelines can be made sorry-free (Reynolds directly; BFMCS could also be updated but is superseded).
