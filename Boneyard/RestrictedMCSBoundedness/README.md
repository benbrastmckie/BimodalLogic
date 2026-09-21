# RestrictedMCSBoundedness

Archived from `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean`.

## Contents

| File | Lines | Declarations |
|------|------:|--------------|
| `Boundedness.lean` | 262 | `restricted_mcs_iter_F_bound`, `restricted_mcs_F_bounded`, `restricted_mcs_iter_P_bound`, `restricted_mcs_P_bounded` |

## Why archived

The four lemmas establish that `iterF`/`iterP` iterations eventually leave any `RestrictedMCS`,
and locate the boundary index where they do. They had **zero references** in `FormalSystem/`,
`Tests/`, or `docs/` outside their own declaration site.

The consumer they were written for — `succ_chain_fam`'s `f_nesting_is_bounded` and
`p_nesting_is_bounded` obligations — is itself archived, at
`../StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean`. Retiring the machinery alongside its
consumer was cheaper than refactoring 157 lines of live proof that nothing exercised.

## Relationship to active code

Every dependency is still live: `RestrictedMCS`, `ClosureRestricted`,
`restricted_mcs_is_closure_restricted`, `closureWithNeg`, `closureFBound` and `closurePBound` in
`FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean`; `iterF`, `iterP`,
`iter_F_leaves_closure`, `iter_P_leaves_closure`, `iter_F_one_eq_some_future` and
`iter_P_one_eq_some_past` in `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean`.

To resurrect: paste the declarations back beside `restricted_mcs_exists_containing` and remove
the `#exit`. Nothing else needs recovering.

A validated alternative to a verbatim resurrection: the four lemmas collapse onto a single
`Nat.find`-based `exists_boundary_of_one` plus two 14-line instantiations, absorbing the two
9-line `iter_*_bound` lemmas into an escape hypothesis (139 proof lines become 44). That rewrite
requires a local `classical` — `Nat.find` needs a `DecidablePred` and `_ ∈ M` for
`M : Set Formula` is not decidable — and deliberately no module-scope `open Classical`.

## Convention note

This directory postdates the guard-first migration in the sense that it never contained `untl` or
`snce` occurrences at all — the archived proofs are purely about `iterF`/`iterP` and closure
bounds. The root README's argument-swap warning therefore does not apply to anything here.
