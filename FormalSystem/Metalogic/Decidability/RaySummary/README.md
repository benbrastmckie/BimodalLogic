# RaySummary — the seam interface for `⊡` over the time axis

This directory is the decidability side's **interface** to the `k`-type summary substrate in
[`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`](../../WeakCanonical/KTypeSummary/README.md).
It holds the seam interface only; the substrate proper — Büchi's complementation chain
transposed to monadic `k`-types over the `ℤ` time axis — lives there.

## Why this cluster exists beside `PlusSlicedCertificate/`

The time-sliced L⁺ certificate presents a frame on `ℤ × Fin n` with **finite fibres**, and the
finite-width finite model property for the sliced class is **refuted**
(`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`).
Checking `⊡φ` on the seam-gluing path-space presentation
(`FormalSystem.PlusLanguage.plusStab_iff_omega`: a backward ray glued to a forward ray at a seam)
therefore needs summaries over the **time axis** with a finite alphabet of per-time summaries,
not over states — pigeonhole-over-states lasso summaries are refuted on infinite acyclic fibres
(`not_lasso_sufficient_on_chain`, `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`).
The `KTypeSummary/` cluster is that time-axis device; this directory is where its consumer-facing
statement about `⊡` is made.

## What it holds

| File | Lines | Description |
|------|-------|-------------|
| `Seam.lean` | 158 | `SeamSummary` (a family triple plus a `Bool` verdict), the four-field hypothesis bundle `Presents` (`colours` — the unformalized MSO reduction, stated as a hypothesis; `determined`; `realized` — joint realization through the seam; `verdict`), and the bridge `plusStab_iff_seamSummary`: under `Presents`, `⊡φ` holds at the seam iff the verdict is `true`. |

## What it does not do

- **It discharges nothing.** `Presents.colours` is the MSO-to-ω-regular reduction, which has no
  formalization in any proof assistant (cslib has zero MSO); the confidence that the
  MSO-over-`⟨ℤ,<⟩` route reduces to the substrate is **Medium**. The bridge is a statement *about*
  any summary that presents a seam, not a construction of one.
- **No decision procedure, no decidability result, no complexity bound.** Assembling a decidable
  `⊡` check on the path-space presentation — producing a `SeamSummary` and discharging `Presents`
  for a concrete frame — is the consumer's work. The CTL⋆ 2EXPTIME lower bound is a sanity
  ceiling only.
- **One family per summary.** `Presents.colours` asserts every ray pair through the seam is
  summarised by a block of one family. A seam whose ray pairs spread over several families is
  summarised by finitely many triples (`finite_family_triples`, `target_eq_union_of_families` in
  the substrate); generalising the bundle to that shape is the consumer's option.

## Evidence

The substrate this interface sits on is exercised by two wired evidence probes
(`specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean` and
`specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`; see the
[`KTypeSummary/` README](../../WeakCanonical/KTypeSummary/README.md) for what each establishes).
Neither inhabits `Presents`: the substrate probe cites `plusStab_iff_seamSummary` and says in its
header that producing a seam summary for a concrete frame is the consumer's assembly work, and the
E2 probe is about stratification depth, not about this interface.

## The consumer relation

The substrate is **built in `KTypeSummary/` and consumed downstream, never absorbed into the
consuming record**; this directory is the first consumer-facing statement, and the assembly of a
decidable check is the next. Headline axiom profiles, including `plusStab_iff_seamSummary`'s, are
pinned in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

## Two carried limits

1. The backward `⊡(Pp)` shape on the real formula is fixed by the asymmetric-fixture probe
   (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`), not
   re-proved here; no backward Bool-fixture bridge exists.
2. The identification of the substrate's chain with the Ramsey core of Büchi complementation is
   a proof-level reading of cslib's `IsRegular.compl`; the further claim that MSO-over-`⟨ℤ,<⟩`
   *reduces* to it is Medium-confidence and is exactly what `Presents.colours` leaves as a
   hypothesis.

## Dependencies

- **Imports from**: `../../WeakCanonical/KTypeSummary.lean`, `FormalSystem/PlusLanguage/PlusRayFibre.lean`
- **Imported by**: `../../Decidability.lean` (the sibling aggregator), via `../RaySummary.lean`

## Related Documentation

- [Decidability README](../README.md)
- [`KTypeSummary/`](../../WeakCanonical/KTypeSummary/README.md) — the substrate proper
- [`PlusSlicedCertificate/`](../PlusSlicedCertificate/README.md) — the finite-width route this
  sits beside

---

*Last verified: 2026-10-08*
