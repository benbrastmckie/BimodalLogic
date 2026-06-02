# Bypass Surjectivity Research — Task 155, Phase 2 Blocker

## Sorry Chain (Verified)

```
completeness_discrete (Completeness.lean:309)
  → countermodel_discrete_reynolds (Transfer.lean:1203)
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1993)
    → cantor_bfmcs_discrete_restricted_fuc (ChronicleToCountermodel.lean:2049)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1667)
        → limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:790)
          → succ_cofinal (ChronicleToCountermodel.lean:776)
            → chronicle_gap_contradiction (ChronicleToCountermodel.lean:475) [SORRY]
```

Note: the docstring at ChronicleToCountermodel.lean:55-73 claims these are "dead BX code." This is INCORRECT — `succ_embed_surjective` IS called by the active Reynolds pipeline via `restricted_tc/fuc`. The docstring was written when a different countermodel path was planned.

## Why Surjectivity Is Needed

The ℤ-indexed BFMCS families define `fam.mcs(t) = limit_f(succ_embed(t+offset))`. When `limit_F_resolution` produces a witness `y ∈ limit_dom` with `y > succ_embed(t+offset)`, `succ_embed_surjective` converts `y` back to integer `m` so the temporal coherence statement `∃ s : ℤ, s > t ∧ φ ∈ fam.mcs(s)` can be satisfied.

The dense case avoids this by using the Cantor isomorphism `cantor_iso_dense : ℚ ≃o LimitDomSubtype` (bijective by construction). The discrete case has only `succ_embed : ℤ →o LimitDomSubtype` (injective but not proven surjective).

## Path Analysis

### Path A: Multi-predicate model surgery — NOT VIABLE

Model surgery (Reynolds Lemmas 6-13) proves no gaps between DIFFERENT equivalence classes. The `one_class` theorem (NoGapsDiscreteProof.lean:88, sorry-free) already proves all points are in a SINGLE class. The succ-orbit coverage issue is about reachability WITHIN that single class, not about distinguishing classes. Additional predicates don't help.

### Path C: Bypass surjectivity — NOT VIABLE without major restructuring

`ChronicleAsPriorModel` (ChronicleExtraction.lean:85) already proves temporal coherence directly on `LimitDomSubtype` WITHOUT surjectivity (lines 200-215: wraps `limit_satisfies_c5_strong` witnesses in `Subtype.mk`). However:

- `valid_discrete` (Validity.lean:180) quantifies over `D : Type` with `[AddCommGroup D] [IsSuccArchimedean D]`. The countermodel must live in such a D.
- `LimitDomSubtype` is a subtype of `ℚ` — NOT an additive group. Cannot serve as D directly.
- Building a `BFMCS LimitDomSubtype` instead of `BFMCS ℤ` avoids surjectivity for temporal coherence, but still needs `LimitDomSubtype ≅o ℤ` to produce the final countermodel on ℤ — which IS surjectivity.

Estimated effort: 800-1200 lines to restructure, and STILL requires `IsSuccArchimedean` at the end. Dead end.

### Path D: Axiomatize `IsSuccArchimedean` — RECOMMENDED (immediate)

Replace the sorry in `chronicle_gap_contradiction` with a clean axiom at the `limitDomSubtype_isSuccArchimedean` level:

```lean
-- Axiom: The discrete chronicle limit domain is succ-archimedean.
-- Mathematical justification: The omega-chain construction builds limit_dom
-- as a union of finite stages. Each stage extends by resolving C4/C5
-- violations, inserting points between existing ones. The successor
-- operation (from next_top) ensures adjacent points are succ-linked.
-- The limit of a chain of succ-connected orders is succ-connected.
-- Formal proof requires induction on the chronicle construction stages.
axiom limitDomSubtype_isSuccArchimedean_axiom ...
```

**Effort**: ~30 lines. Replaces the sorry without adding a new `sorryAx` (one already exists in the dependency chain). Makes the assumption explicit and well-documented.

### Path E: Omega-chain stage induction — RECOMMENDED (long-term)

Prove `IsSuccArchimedean` by induction on chronicle construction stages:
- **Base**: Stage 0 domain is `{0}` — trivially archimedean
- **Step**: Stage n+1 adds points to resolve C4/C5 violations. New points become immediate successors/predecessors of existing points (via `next_top` discreteness). If stage-n domain is succ-connected, stage-(n+1) domain is also succ-connected.
- **Limit**: Countable union of succ-connected orders is succ-connected (needs proof)

**Effort**: 300-600 lines. Requires deep understanding of `omega_chain_stage` internals in ChronicleConstruction.lean. This is the "right" proof but a significant undertaking.

## Recommendation

**Immediate**: Path D. Axiomatize `limitDomSubtype_isSuccArchimedean` to unblock `completeness_discrete`. Document the mathematical justification. This replaces the existing sorry with a cleaner axiom at a higher level.

**Long-term**: Path E. Prove the axiom by induction on the chronicle construction. This would make `completeness_discrete` fully sorry-free.

**Estimated effort**: Path D: 1 hour. Path E: 20-40 hours.
