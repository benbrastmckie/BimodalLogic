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
| `Seam.lean` | 165 | `SeamSummary` (a family triple plus a `Bool` verdict), the four-field hypothesis bundle `Presents` (`colours`; `determined`; `realized` — joint realization through the seam; `verdict`), and the bridge `plusStab_iff_seamSummary`: under `Presents`, `⊡φ` holds at the seam iff the verdict is `true`. The bundle's declarations are pinned and unchanged; what `colours` says is characterized in `SeamMulti.lean`. |
| `SeamMulti.lean` | 344 | The characterization `exists_presents_iff` (`SeamDecided`): the single-family bundle is inhabited iff the seam is `⊡`-decided — so `Presents.colours` is a seam condition, not the MSO reduction. The two-letter interface (`twoLetter`, `seamTrace`, `nowPhi`, `stabTarget`, `stabTarget_determined` from `determinedByKType_eval`), the realized set `Hit` (finite: `hit_finite`), the hypothesis-free bridge `plusStab_iff_forall_hit`, and the multi-family bundle `PresentsMulti` with its bridge `plusStab_iff_presentsMulti` and its inhabitant `presentsMulti_seamTrace` (whose `Bool` is classical). |

## What it does not do

- **It does not compute `Hit`.** The hypothesis-free bridge `plusStab_iff_forall_hit` reduces
  `⊡φ` at a seam to a finite conjunction over the realized family triples `Hit`, but `Hit` is a
  semantic set that nothing in this tree computes, and `presentsMulti_seamTrace`'s verdict is
  `decide (⊡φ)` under `open Classical` — it carries the answer, it does not find it. The
  single-family bundle `Presents` is not a reduction at all: it is inhabited iff the seam is
  `⊡`-decided (`exists_presents_iff`), and a regular `ℤ`-frame seam with no inhabitant for any
  parameters is exhibited in the wired probe
  `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`.
- **No decision procedure, no decidability result, no complexity bound.** Computing `Hit` — the
  realizability direction (HWZ 2000, Definition 12 / Theorem 14, with the one-sided-liveness
  repair) together with effective `k`-type composition — and then assembling a decidable `⊡`
  check on the path-space presentation is downstream work. The CTL⋆ 2EXPTIME lower bound is a
  sanity ceiling only.
- **Two letters, not the closure.** The trace alphabet is `{now, φ}` for a single `φ`; widening
  it to a subformula-closure signature with local run conditions is a successor record's
  business, not done here.

## Evidence

The substrate this interface sits on is exercised by two wired evidence probes
(`specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean` and
`specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`; see the
[`KTypeSummary/` README](../../WeakCanonical/KTypeSummary/README.md) for what each establishes).
Neither inhabits `Presents`. A third wired probe,
`specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`, holds the
obstruction in place: on the E2 fixture (transcribed) the seam `(stayA c t, t)` is undecided on
`Fp` (`seam_undecided`), so no `Presents` inhabitant exists there for any `sig`, `k`, `T`, `S`
(`no_presents_on_fixture`, by the library's `seamDecided_of_presents`). It cites
`exists_presents_iff`, `plusStab_iff_forall_hit` and `presentsMulti_seamTrace` and re-proves
none of them.

## The consumer relation

The substrate is **built in `KTypeSummary/` and consumed downstream, never absorbed into the
consuming record**; this directory is the first consumer-facing statement, and the assembly of a
decidable check is the next. Headline axiom profiles — `plusStab_iff_seamSummary`, `exists_presents_iff`,
`plusStab_iff_forall_hit`, `plusStab_iff_presentsMulti`, `presentsMulti_seamTrace` — are pinned
in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, and `plusStab_iff_forall_hit` is
additionally pinned by C14 for its row in `docs/theorem-index.md`.

## Two carried limits

1. The backward `⊡(Pp)` shape on the real formula is fixed by the asymmetric-fixture probe
   (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`), not
   re-proved here; no backward Bool-fixture bridge exists.
2. The identification of the substrate's chain with the Ramsey core of Büchi complementation is
   a proof-level reading of cslib's `IsRegular.compl`. The further question — whether
   MSO-over-`⟨ℤ,<⟩` *reduces* to it — is now sharpened rather than left at a confidence level:
   the substrate supplies the complementation half in full (`plusStab_iff_forall_hit` needs no
   hypothesis), and the realizability half — computing `Hit` — is what remains. The exhibited
   undecided seam is forward-only (`Fp`); limit 1 is unchanged.

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
