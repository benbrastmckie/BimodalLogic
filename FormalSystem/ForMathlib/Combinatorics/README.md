# ForMathlib/Combinatorics

Combinatorial results Mathlib does not carry, stated in Mathlib's own shape so that the
development can be upstreamed rather than kept as a local fork. At present this is the infinite
Ramsey theorem for pairs: every finite colouring of the increasing pairs of naturals is constant
on some strictly monotone subsequence. At pin `v4.33.0-rc1` Mathlib's `Combinatorics/` carries
Hindman's theorem and the Hales–Jewett theorem; the classical infinite Ramsey theorem is absent.

This directory imports nothing from `FormalSystem.*`. That is a hard constraint, not an
accident: a module intended for Mathlib may not depend on this repository.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib/Combinatorics -->
| File | Lines | Description |
|------|------:|-------------|
| `InfiniteRamseyPairs.lean` | 160 | Infinite Ramsey for pairs, proved from scratch: a descending chain of infinite sets chosen by `Exists.choose`, a pre-homogeneous sequence, pigeonhole on the finite colour type, and monotone enumeration by `Nat.Subtype.ofNat` |
<!-- END GENERATED -->

## Key Definitions

- `Nat.exists_strictMono_const_pair_colour` — **infinite Ramsey for pairs**: for every
  `c : ℕ → ℕ → C` with `C` finite there are a strictly monotone `g : ℕ → ℕ` and a colour `τ`
  with `c (g i) (g j) = τ` whenever `i < j`. The helpers (`ramseyNext`, `ramseyChain`,
  `ramseySeq`, `ramseyCol` and their specifications) are private to the file

## Related Documentation

- [FormalSystem README](../../README.md)
- [`ForMathlib/`](../README.md) — the parent, which states the dependency rule
- [`FormalSystem/Metalogic/WeakCanonical/GroupModel/`](../../Metalogic/WeakCanonical/GroupModel/README.md) —
  the first consumer: `RamseyFactorization.lean` keeps the theorem under its original name
  `infinite_ramsey_pairs` as an alias and spends it on the per-block inflation step of the
  companion-lemma chain

---

*Last verified: 2026-10-05*
