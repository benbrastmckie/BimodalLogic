# Phase 14.3 — The spine re-base completed; the route is unconditional

**Task**: 408 — Faithful route to strong completeness for the Dedekind extension
**Phase**: 14.3 (plan v8, `plans/08_strong-completeness-dedekind-v8.md`)
**Session**: `sess_1785261286_112e15`
**Status**: `[COMPLETED]`
**Date**: 2026-07-28

## Outcome

`uSExpressivelyCompleteOverDensePrior` — Reynolds 1992, §5 Theorem 3, printed p.176 — is now
**unconditional and axiom-clean** at `[propext, Classical.choice, Quot.sound]`. The single
strategic sorry that the whole route rested on, `kampFaithfulExpressiveCompleteness_open`
(`PriorExpressivenessDense.lean`), is discharged.

Verified by `#print axioms` over fourteen declarations, not asserted. `sorryAx` appears in none
of them.

## What was built

952 lines across two new modules, 25 declarations, all sorry-free and axiom-clean.

| Module | Lines | Decls | Contents |
|---|---:|---:|---|
| `Kamp/NfMultiAnchorBridge/ArmLemmasFaithful.lean` | 455 | 17 | The three `k = 0` trichotomy arms, `aggPosDiagK1_correct_faithful`, `kampArm_diag_k1_correct_faithful`, the `CAggInt` / `CAggOd` / `CAggOdSwap` dispatcher clause iffs, the `negFixFaithful` population folds `aggPop1Faithful` / `aggPop1FFaithful` with their correctness, and the two off-diagonal `k = 1` arms |
| `Kamp/KampPriorFaithful.lean` | 497 | 8 | `nf_succ_char_formula_correct_faithful`, both per-depth arm closures, `nf_nvar_exist_all_depths_faithful`, its wrapper + correctness, `nfCharacterizableTemporalPriorFaithful`, `kampPriorExpressiveCompletenessFaithful` |

Plus, in `PriorExpressivenessDense.lean`: one added import, the sanctioned replacement of the
strategic sorry's body, and the new `kampFaithfulExpressiveCompleteness`.

## The chain, end to end

```
uSExpressivelyCompleteOverDensePrior                    ← unconditional
  └─ uSExpressivelyCompleteOverDensePrior_of_faithful   ← was already sorry-free
       └─ kampFaithfulExpressiveCompleteness            ← THIS DISPATCH
            └─ kampPriorExpressiveCompletenessFaithful  ← KampPriorFaithful.lean
                 └─ nfCharacterizableTemporalPriorFaithful
                      ├─ nf_succ_char_formula_correct_faithful
                      └─ nf_nvar_exist_all_depths_faithful
                           ├─ k = 0 arm  →  the three k=0 arms      ┐
                           ├─ k = 1 arm  →  the three k=1 arms      ├ ArmLemmasFaithful.lean
                           │                 └─ aggOdPopFold_iff_faithful  ← phase 14.2
                           │                 └─ bracketEndChar_kv_correct_one_prior_faithful ← 14.2
                           └─ k ≥ 2 arm  →  kampArm_zeta_faithful   ← phase 14.1
```

## Verification

| Gate | Result |
|---|---|
| Full `lake build` | **green**, 1926 jobs |
| Live-tree `sorry` count | **1** (was 2) — census delta **−1** |
| Remaining sorry | `Transfer.lean:1242`, pre-existing and unrelated; plan v8 Phase 15 records it is not to be attempted. Untouched. |
| Vacuous definitions introduced | 0 |
| Axioms introduced | 0 |
| Declarations removed | 0 |
| Declarations renamed | 0 |
| Existing Lean declarations edited | 0 |

## 14.2's verdict is confirmed, not corrected

Phase 14.2 found that the spine re-base above the ζ wire has **no remaining proof content**. That
held at every site on the live path. No site required `HasAttainedINF`'s extra strength, so no
swap had to be forced and no correction to 14.2's verdict is needed.

## Four corrections to the phase's own scope model

These concern the *measurement*, not the mathematics.

1. **The "72 binder lines across 15 modules" figure over-scoped the obligation.** Only seven
   declarations in `KampPrior.lean` and nine in the bridge lie on the live dependency path from
   `kampPriorExpressiveCompleteness` (`:672`). `KampPrior.lean`'s own site/coverage-probe block
   *below* `:672` — `kampPrior_site_*`, `kampPriorExistProviders*`, `kampPrior_fChain_*` — is
   consumed by nothing on that path, and neither are the exterior/pinned-converse bridge modules.
   They were not re-based, and re-basing them was not required.
2. **The plan's grep metric was never a complete inventory.**
   `grep -cE '(_?h_UZ|hUZ) *: *SemanticPriorUZ'` counts only the named-binder form and misses the
   arrow form `SemanticPriorUZ M atomMap →` entirely. There are six arrow-form sites in the live
   tree and **five of the six are on the live path** (the `k = 0` / `k = 1` arm lemmas). The "72"
   over-counted off-path sites and under-counted on-path ones simultaneously.
3. **Under D11 the UZ/SZ binder count can never decrease.** D11 forbids editing the attained
   originals, so a faithful re-base adds faithful binders *beside* the UZ/SZ ones. The UZ/SZ count
   is now 115, up from 85, purely for that reason. It measures remaining restatement work, not
   progress. The sorry census is the metric that moved, and it moved the right way.
4. **The `private` obstruction was largely a non-issue on the live path.** Exactly one private
   helper mattered — `AggregateHookDischarge.lean`'s `agg2_cons_diag_env` (`:1447`), a four-line
   arity-2 env identity, restated visibly as `aggDiagEnv2_const_faithful`. `ExteriorBracket.lean`'s
   `kvE2_extGate_anyBit_iff` (`:837`), which 14.2 diagnosed as forcing a ~265-line in-file
   duplication, is not on the live path and was never touched.

## Deviation, stated rather than absorbed

The phase goal's first clause — "re-base the remaining 72 binder lines across 15 modules" — is
**not fully executed**. Its second clause, and the phase's own "Done when", are. The off-path
sites remain at `SemanticPriorUZ` / `SemanticPriorSZ`. They are sorry-free, pinned at the strictly
stronger carrier, and no live result depends on them at the faithful carrier, so leaving them costs
nothing. Any future re-base of them should be chartered on its own merits, not carried as a
completion obligation of this route.

## Name discipline (D11)

`kampFaithfulExpressiveCompleteness` is the new proved declaration.
`kampFaithfulExpressiveCompleteness_open` is **retained** at the same type as an unweakened alias,
so every consumer written against the open obligation typechecks unchanged — and no longer
inherits `sorryAx`.

## Source grounding

The construction is Rabinovich, *A Proof of Kamp's Theorem* (2014): Def 3.1 (PDF p.4) for the
normal-form stratification, Lemmas 3.2(2) and 3.4 (pp.4-5) for the characteristic assembly,
Def 4.1 / Prop 4.3 / Thm 4.4 (pp.5-6) for the ζ wire, Prop 4.2 (p.6) for the negated population
clauses, eq (5.2) (p.8) for the faithful carrier itself. The target theorem is Reynolds 1992
§5 Theorem 3 (printed p.176).

**Explicitly without a source**: the *choice* of carrier. Rabinovich draws no distinction between
the attained first-occurrence property and his own eq (5.2) dichotomy, so the re-basing — the
entire content of phases 14.1 through 14.3 — is this tree's own work and is documented as such in
each new module's header.

## Re-flagged, not edited

**D16** is now more pressing than before. It concerns `uSExpressivelyCompleteOverPrior`'s Reynolds
Theorem 3 citation in `PriorExpressiveness.lean`. As of this dispatch,
`uSExpressivelyCompleteOverDensePrior` — the declaration that genuinely *is* Reynolds Theorem 3 —
is unconditional, which sharpens the mis-citation. `PriorExpressiveness.lean` was not edited.
**D13** (`Section5Correspondence.lean`'s stale re-base table) also remains open and was not edited.
