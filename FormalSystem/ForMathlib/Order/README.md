# ForMathlib/Order

Order-theoretic material this project needs and Mathlib happens not to carry, staged for
upstreaming. Two independent pieces live here:

- **`PFilter.lean`** — the filter side of Mathlib's `Order/Ideal.lean` and
  `Order/PrimeIdeal.lean`: proper, maximal and prime **filters** on a preorder, stated in the
  shape Mathlib states the ideal case, so that the development can be upstreamed rather than kept
  as a local fork.
- **`BallSpace.lean`** — the bottom of the Ćmiel–Kuhlmann–Kuhlmann **ball-space** hierarchy:
  nests, spherical completeness `S₁`, and the cofinal-nest reduction. Mathlib carries no
  ball-space API at all — a search for `spherically` returns nothing relevant — so the whole
  notion is supplied here, over an arbitrary ball predicate `P : Set W → Prop` with no structure
  on `W` beyond its being a type.

This directory imports nothing from `FormalSystem.*`. That is a hard constraint, not an
accident: a module intended for Mathlib may not depend on this repository.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib/Order -->
| File | Lines | Description |
|------|------:|-------------|
| `BallSpace.lean` | 129 | Nests, spherical completeness `S₁` over an arbitrary ball predicate, and the reduction of a whole family to a cofinal nest inside it. Mentions no relation, frame or duration type. |
| `PFilter.lean` | 270 | Proper, maximal and prime filters on a preorder — the filter side of Mathlib's `Order/Ideal.lean` and `Order/PrimeIdeal.lean`, in the shape Mathlib states the ideal case. |
<!-- END GENERATED -->

## Key Definitions

- `Order.PFilter.IsProper` — a proper filter: one that is not the whole preorder
- `Order.PFilter.IsMaximal` — a maximal proper filter
- `Order.PrimeFilter` — the prime condition, dual to `Order.PrimeIdeal`
- `Order.IsNest` — a **nest**: a nonempty `⊆`-chain of sets. The nonemptiness of the family is
  part of the notion; the nonemptiness of the *members* is a separate hypothesis wherever needed
- `Order.IsNest.exists_subset_inter` — a nest is `⊇`-directed in the members-witness sense. This
  is the entire mathematical content of the ball-space hierarchy's implication `S₁ᵈ → S₁`, stated
  so that an instantiation needs no directed-family definition of its own
- `Order.SphericallyComplete` — **spherical completeness `S₁`** over the ball space `{s | P s}`:
  every nest of nonempty balls has nonempty intersection
- `Order.HasCofinalNest` — a family of sets containing a nest that refines every member: the exact
  indexing property that makes the nest form as strong as the directed form **at one family**
- `Order.sInter_nonempty_of_sphericallyComplete` — **the reduction**: `S₁` plus a cofinal nest plus
  nonempty members gives a point common to the whole family

## Related Documentation

- [FormalSystem README](../../README.md)
- [`FormalSystem/Metalogic/Algebraic/`](../../Metalogic/Algebraic/README.md) — `PFilter.lean`'s
  consumer: the Lindenbaum–Tarski quotient and the ultrafilter/MCS correspondence
- [`FormalSystem/Semantics/TaskFrame.lean`](../../Semantics/TaskFrame.lean) — `BallSpace.lean`'s
  consumer: `TaskFrame.NestSaturation` instantiates `Order.SphericallyComplete` at the frame's own
  ball space of nonempty fibers and segments, and `nestSaturation_iff_sphericallyComplete` records
  that identification by `Iff.rfl`

---

*Last verified: 2026-09-24*
