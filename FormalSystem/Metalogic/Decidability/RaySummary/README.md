# RaySummary — the seam interface for `⊡` over the time axis

This directory is the decidability side's **interface** to the `k`-type summary substrate in
[`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`](../../WeakCanonical/KTypeSummary/README.md),
together with the **realizability device** that reads realized family triples off a finite
presentation. The substrate proper — Büchi's complementation chain transposed to monadic
`k`-types over the `ℤ` time axis — lives there; here are the seam interface (`Seam.lean`,
`SeamMulti.lean`) and the device (`Closure.lean`, `Trace.lean`, `Compose.lean`, `Present.lean`,
`HitOf.lean`).

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
| `Closure.lean` | 310 | B1: the closure alphabet `clSig φ` (one letter per subformula of `φ` plus the marker `clNow`; `Fintype`/`DecidableEq` by `inferInstanceAs`), HWZ 2000 Def 11's local run conditions on colourings of `ℤ` (`LocalRun`: `bot`, `imp`, `untl`, `snce` — exactly `PlusTruthAt`'s clauses), the anchors that fix what a run condition cannot (`Anchored`: `now` at `t`, atoms at states, `box` per time, `stab` per state), the closure trace `clTrace` of a history (its two-letter projection is `seamTrace`, `clTrace_proj`), `HitSig` over an arbitrary signature, and the signature-generic bridge `plusStab_iff_forall_hitSig`, of which `plusStab_iff_forall_hit` is the two-letter instance (`hitSig_twoLetter` by `rfl`). |
| `Trace.lean` | 336 | B2a, HWZ 2000 Thm 14 in the direction that reads types off a model: the closure trace satisfies every run condition and anchor (`clTrace_localRun`, `clTrace_anchored`, each clause `Iff.rfl`) and an anchored local run **is** the trace of its history (`eq_clTrace_of_localRun_anchored`, `clTrace_unique`, by structural induction on the closure formula). The realized set over the closure alphabet `HitCl` (finite), the bridge `plusStab_iff_forall_hitCl`, and `hitCl_eq_iUnion` (the union over the seam's ray pairs of their traces' family triples — a theorem, not a computation: `SeqPair` is not finite). The realization hypothesis `Presented M τ t φ lab step` (the seam's closure traces are exactly the presentation's run traces), `presented_localRun`, the per-model bridge `hit_eq_hitOf_of_presented` (`HitCl = ↑(hitOf …)` for `1 ≤ k`), and `plusStab_iff_forall_hitOf_of_presented`, which decides nothing. |
| `Compose.lean` | 297 | B3b, the composition half: the finite segment of a list of letters `listSeg` (carrier `Fin l.length`, computable instances, `kTypeOfFin_listSeg`), the letters of a decidable colouring on `[a, b)` (`labels`) with `kTypeOf_segZ_eq_listSeg` (a time-axis segment has the `k`-type of its label list, by `k_equiv_of_iso`), `listSeg_append_kEquiv` (a concatenation is the two-point ordered sum of its parts), and the congruence `kTypeOf_listSeg_append_congr` — the `k`-type of `l₁ ++ l₂` depends only on the `k`-types of the parts, the `I = J = Bool` instance of `kEquiv_orderedSum_of_kEquiv_colour`. No `compose` on bare `KType` values, by design: most `k`-types are the type of nothing. |
| `Present.lean` | 684 | B3b, the closure half: finite labelled presentations, unbundled (`Q` with `[Fintype Q] [DecidableEq Q]`, `lab`, `step`, `now`), their bi-infinite runs `IsRun` and decidable traces `runTrace`, finite paths `StepPath`/`stepPath_iff`, the representative-carrying closure `pathClosure` computing `pathTypes` (the `k`-types of `now`-free paths between two states) and `pathTypesNow` (paths reading `now` once) by `kTypeOfFin` on one stored label list per key, justified by the congruence (`mem_pathTypes_iff`, `mem_pathTypesNow_iff`; stationarity within `closureBound` rounds by `iterate_stabilizes`), and liveness as a greatest fixpoint (`live`, `live_iff`, `fwdLive`, `bwdLive`). `fwdLive`/`bwdLive` chain paths that share an endpoint and are **not** what `hitOf` reads (see `HitOf.lean`). |
| `HitOf.lean` | 810 | B3b, the read-out half: liveness over **disjoint** segments joined by one `step` (`fwdSepGraph`, `bwdSepGraph`, `fwdLiveSep`, `bwdLiveSep`, `fwdLiveSep_iff`, `bwdLiveSep_iff` — the graph a `SegmentFactorization` actually walks; with `Present.lean`'s shared-endpoint graph the characterization below is false, by a two-state counterexample `#eval`-witnessed in `KTypeFinEvalTest.lean`), the computable realized-triple set `hitOf lab step now k` (an image over state pairs of `pathTypesNow` types paired with live path types, never a filter over the triple product of `KType sig k`), and `mem_hitOf_iff`: for every anchor `t` and depth `k ≥ 1`, `hitOf` is exactly the family triples (`InFamily`) of the traces of the presentation's runs — the ⇒ direction splices runs of the presentation through a generic `ℤ`-indexed concatenation (`cutAt`, `exists_concat`, `isRun_concat`, `kTypeOf_segZ_concat`), the ⇐ direction reads a factorization's segments as `runSeg` paths and uses `k ≥ 1` through `doets_lemma_1_1` for the `k`-type visibility of nonemptiness and of a `now` state. |

## What it does not do

- **It does not compute `Hit` for a model.** `hitOf` is computable on a finite labelled
  presentation and is exactly the family triples of that presentation's runs (`mem_hitOf_iff`);
  a seam's realized set `HitCl` equals `hitOf` **only under the explicit realization hypothesis
  `Presented`** (`hit_eq_hitOf_of_presented`) — the closure traces of the seam's splices are
  exactly the presentation's run traces — and that hypothesis is discharged for **no**
  non-trivial model in this tree. Without it, `HitCl` is the image of the seam's ray pairs under
  the trace map (`hitCl_eq_iUnion`), a theorem and not a computation, and
  `presentsMulti_seamTrace`'s verdict is still `decide (⊡φ)` under `open Classical` — it carries
  the answer, it does not find it. The single-family bundle `Presents` is not a reduction at all:
  it is inhabited iff the seam is `⊡`-decided (`exists_presents_iff`), and a regular `ℤ`-frame
  seam with no inhabitant for any parameters is exhibited in the wired probe
  `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`.
- **It does not realize a presentation (B2b).** Discharging `Presented` for a model
  **constructed** from a presentation — HWZ 2000, Definition 12 / Theorem 14 ⇐, for this
  semantics' `⊡` fibre — is a successor record, and it is not a one-line mirror of `Trace.lean`
  for a reason that is a property of the semantics: the fibre is a **product**
  (`seamOmegaEquiv`: histories through `(t, s)` are pairs of a backward and a forward
  ω-step-sequence out of `s`), so the set of traces realized at a state is closed under splicing
  the backward half of one history with the forward half of another, and a per-state summary that
  claims a set of types `S` realizes the mixed set — HWZ Lemma 17's "realised type the model
  lacked", which here is a closure property of the fibre rather than an operation that may or may
  not be sound. A sound presentation must therefore carry a product `BwdSummary × FwdSummary` of
  the two one-sided atom-sequence languages, with types derived by the trace map; liveness cannot
  be enforced by a step graph on a finite slice (a presentation deferring an eventuality without
  bound is realized together with its limit path), so the constructed model needs an infinite
  committed-state slice; and `Saturation` is proved in this tree for `[Finite W]` only
  (`ofSlicedStep_saturation`), so a new regular-frame constructor for sliced frames with finitely
  many fibre shapes per time is a prerequisite. The wired probe `quasistate_does_not_determine_hit`
  (below) is the machine-checked verdict that HWZ's verbatim per-time quasistate shape cannot
  stand in for the hypothesis.
- **No decision procedure, no decidability result, no complexity bound.** Assembling a decidable
  `⊡` check on the path-space presentation is downstream work; `plusStab_iff_forall_hitOf_of_presented`
  restates the bridge over `hitOf` under `Presented` and decides nothing (the per-triple condition
  is the consumer's to make effective). The CTL⋆ 2EXPTIME lower bound (argued, not formalized) is
  a sanity ceiling only. `decide` on `KType sig k` is exponential in `|NormalForm sig k 0|`; the
  witnesses run at depth 1 on two-state presentations and 3-5 point segments.
- **No finite-fibre or finite-width assumption.** Everything is over the time axis with a finite
  alphabet of per-time letters under `[F.IsRegular]`; the only `[Finite W]` anywhere is the
  counterexample fixture's licence.

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

A fourth wired probe, `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`,
is the B2b verdict: two regular three-state `ℤ`-frame models (`a→a, a→b, b→b, d→d, d→b` and the
same graph without `a→b`; `p` at `b`; closure `{p, Fp}`) have equal per-time quasistates
`{∅, {Fp}, {p, Fp}}` (`quasiState_A_eq_B`) and equal consecutive-type relations
(`pairRel_A_eq_B`) at every time, yet the seam `(stayA, t)` satisfies `⊡¬Fp` in one and refutes
it in the other (`stab_notFp_B`, `stab_notFp_A`), so by `plusStab_iff_forall_hit` at `k = 1`
their `Hit` sets differ (`hit_ne`; headline `quasistate_does_not_determine_hit`). HWZ 2000 Defs
10-12 transcribed without the product repair cannot determine `Hit`; the realization hypothesis
must be the trace-set equality `Presented`. Forward-only (`¬Fp`); `[Finite W]` on the slice is the
counterexample's licence.

The permanent computability witnesses are `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`
(imported from `Tests/BimodalTest.lean`): thirteen `#guard`s at depth 1 over `twoLetter` that
`kTypeOfFin` (on `segZ` and `listSeg`), `allPathTypes`, `hitOf`, `fwdLiveSep` and `bwdLiveSep`
evaluate, including the two-state discriminator on which `fwdLive`/`bwdLive` are `true` and
`fwdLiveSep`/`bwdLiveSep` `false`. Every number there is a witness of computability and nothing
else.

## The consumer relation

The substrate is **built in `KTypeSummary/` and consumed downstream, never absorbed into the
consuming record**; this directory is the consumer-facing statement about `⊡` together with the
device that reads realized triples off a presentation, and the assembly of a decidable check is
the next consumer's. Headline axiom profiles — `plusStab_iff_seamSummary`, `exists_presents_iff`,
`plusStab_iff_forall_hit`, `plusStab_iff_presentsMulti`, `presentsMulti_seamTrace`,
`plusStab_iff_forall_hitSig`, `clTrace_localRun`, `eq_clTrace_of_localRun_anchored`,
`kTypeOf_listSeg_append_congr`, `mem_hitOf_iff`, `Presented`, `presented_localRun`,
`hit_eq_hitOf_of_presented`, `plusStab_iff_forall_hitOf_of_presented` — are pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, and `plusStab_iff_forall_hit`,
`plusStab_iff_forall_hitSig`, `mem_hitOf_iff` and `hit_eq_hitOf_of_presented` are additionally
pinned by C14 for their rows in `docs/theorem-index.md`.

## Two carried limits

1. The backward `⊡(Pp)` shape on the real formula is fixed by the asymmetric-fixture probe
   (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`), not
   re-proved here; no backward Bool-fixture bridge exists.
2. The identification of the substrate's chain with the Ramsey core of Büchi complementation is
   a proof-level reading of cslib's `IsRegular.compl`. The further question — whether
   MSO-over-`⟨ℤ,<⟩` *reduces* to it — is now sharpened rather than left at a confidence level:
   the substrate supplies the complementation half in full (`plusStab_iff_forall_hit` needs no
   hypothesis), and the realizability half is landed as far as a presentation (`hitOf`,
   `mem_hitOf_iff`, `hit_eq_hitOf_of_presented` under `Presented`); what remains is realizing a
   presentation by a constructed regular model (B2b, above). The exhibited undecided seam and the
   B2b verdict fixture are forward-only (`Fp`); limit 1 is unchanged.

## Dependencies

- **Imports from**: `../../WeakCanonical/KTypeSummary.lean` (including `KTypeSummary/KTypeFin.lean`), `../../WeakCanonical/MixedSum.lean`, `FormalSystem/PlusLanguage/PlusRayFibre.lean`, `FormalSystem/PlusLanguage/Subformulas.lean`
- **Imported by**: `../../Decidability.lean` (the sibling aggregator), via `../RaySummary.lean`

## Related Documentation

- [Decidability README](../README.md)
- [`KTypeSummary/`](../../WeakCanonical/KTypeSummary/README.md) — the substrate proper
- [`PlusSlicedCertificate/`](../PlusSlicedCertificate/README.md) — the finite-width route this
  sits beside

---

*Last verified: 2026-10-08*
