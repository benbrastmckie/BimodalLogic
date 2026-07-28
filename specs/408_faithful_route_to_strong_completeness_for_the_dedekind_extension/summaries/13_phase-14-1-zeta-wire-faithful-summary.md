# Phase 14.1 — the ζ wire re-based onto the faithful eq (5.2) carrier

- **Task**: 408 — faithful route to strong completeness for the Dedekind extension
- **Plan**: `plans/08_strong-completeness-dedekind-v8.md`, Phase 14.1
- **Phase status**: `[PARTIAL]`
- **Build**: full `lake build` green at 1921 jobs; sorry census delta zero
- **Session**: `sess_1785261286_112e15`

## The gate, and what it actually returned

Phase 14.1's chartered first task was a gate: survey `ZetaUniformExtract.lean`'s fourteen
`HasAttained*` sites for destructure-vs-hypothesis use, with an explicit instruction to verify
rather than assume a fourth consecutive "pure signature swap" — `HasAttainedINF` is a strictly
stronger carrier than `HasFaithfulDedekindINF`, and `HasAttainedINF.toHasFaithfulDedekindINF`
runs the wrong way to rescue a site that needs the strength.

**Measured verdict** — neither of the two expected answers:

| Site class | Count | Detail |
|---|---:|---|
| **Consuming** | 1 | `:162`, `VVecEA2.negFix_iff` inside `prop42_efSat_negation_general_uniformFin` |
| **Constructing** | 2 | `:800`, `:802`, from `hUZ`/`hSZ` via `ZetaPriorTransfer.lean` |
| **Threading only** | 11 | `intro`-bound and passed unexamined to a sibling uniform lemma |

So the wire re-base was one genuine content change plus mechanical restatement — cheaper than
its 821 lines suggest, but not because the swap was free.

## Landed, sorry-free

`FormalSystem/Metalogic/WeakCanonical/Kamp/ZetaUniformExtractFaithful.lean` (595 lines, new).
Zero edits to `ZetaUniformExtract.lean` or any other attained original; zero removals, zero
renames (D11).

| Declaration | Character |
|---|---|
| `canonExpand_hasFaithfulDedekindINF` / `SUP` | New. The faithful carrier transfers to the canonical expansion. **No source** — original work, modelled on `canonExpand_hasAttainedINF`; the docstring says so. |
| `prop42_efSat_negation_general_uniformFin_faithful` | The one substantive change: witness `VVecEA2.negFixFaithful`, correctness `VVecEA2.negFixFaithful_iff`. |
| `efSat_negation_pair_uniformFin_faithful` | Proof body verbatim. |
| `efSat_negation_general_uniformFin_faithful` | Proof body verbatim. |
| `veeSat_negation_uniformFin_faithful` | Proof body verbatim. |
| `translate_uniformFin_faithful` | Proof body verbatim, `termination_by`/`decreasing_by` included. Rabinovich Thm 4.4, PDF p.6. |
| `kampArm_zeta_faithful` | The ζ wire at `HasFaithfulDedekindINF`/`SUP`. |
| `kampArm_zeta_faithful_covers_attained` | Machine-checks the re-base is a **weakening**, not a sideways move. |

The three carrier-free uniform lemmas of the original module —
`efSat_negation_diagonal_uniformFin`, `vvecea2_collapse_bridge_uniformFin`,
`ex_closure_translate_uniformFin` — are **reused**, not duplicated: they mention no carrier.

## Two findings

**1. At the faithful carrier the `SUP` half is not consumed at all.** `VVecEA2.negFix_iff` needs
`HasAttainedINF` *and* `HasAttainedSUP`; `VVecEA2.negFixFaithful_iff` needs
`HasFaithfulDedekindINF` alone. `HasFaithfulDedekindSUP` is threaded through all six new
statements — kept for shape-parallelism with the attained originals and with the consuming
obligation — but bound to `_h_SUP` and never used. Deleting it would strengthen every result.
That decision was deliberately left to the orchestrator, not taken here.

**2. One site genuinely needs the stronger carrier, exactly as the dispatch warned.**
`Lemma53Faithful.lean:545` (`prior_makes_faithful_disjunct2_unreachable`) derives `¬kplusOpen`
from `HasAttainedINF.first_occ`'s attained conclusion — `¬P` throughout `(z₀,r₀)` with no `kplus`
escape hatch. The faithful `first_occ` carries that hatch, so the lemma is **not re-basable and
must not be swapped**. It is an exclusion/anti-vacuity result about Prior structures rather than
a step on the correctness path, so it does not block the re-base; it simply does not carry over.

## Why `[PARTIAL]`

The charter's second clause — "then a faithful sibling of `kampPriorExpressiveCompleteness` at
that carrier" — is the spine *above* the wire. Measured: **110 hypothesis-binder sites across 22
live modules**, with `KampPrior.lean` (26) and fifteen `NfMultiAnchorBridge/` modules (~50)
being the bulk. Only four of those sites consume the carrier, and two of the four are the
non-carrying-over exclusion results, leaving `aggOdPopFold_iff` as the single real remaining
proof obligation. Breadth of restatement, not proof difficulty — but breadth on the scale of the
`EANegationFixFaithful/` re-base, not of one dispatch.

Chartered as **Phase 14.2** in plan v8, with its own gate (does `aggOdPopFold_iff` bottom out at
`VVecEA2.negFix_iff`?) and a suggested `NfMultiAnchorBridge/`-first seam.

## Sorry inventory

| File:line | Strategic | Owner |
|---|---|---|
| `PriorExpressivenessDense.lean:263` — `kampFaithfulExpressiveCompleteness_open` | yes | Phase 14.2 |
| `Transfer.lean:1242` | no — pre-existing, unrelated | out of scope (plan v8 Phase 15 records it is not to be attempted) |

Census delta for this dispatch: **zero**.

## Deviations

- Edited `kampFaithfulExpressiveCompleteness_open`'s **docstring**, not only its body, plus a
  dated additive `Update` paragraph in `PriorExpressivenessDense.lean`'s header. Leaving the
  prior text — "`ZetaUniformExtract.lean` contains zero occurrences of `HasFaithfulDedekindINF`",
  "the zeta wire ... does not reach it" — would have left a machine-checkably false measurement
  in the tree. The historical refutation record is kept verbatim; the update is additive.
- Phase 14.1's second clause not attempted; reported for plan revision rather than force-fit.

## Carry-forward constraints

- **D7**: no PIN-side `kplusOpen_of_kplus` touched.
- **D11**: zero removals, zero renames; attained originals byte-identical; the weakening is
  machine-checked by `kampArm_zeta_faithful_covers_attained`.
- **D13 / D16**: `Section5Correspondence.lean` and `PriorExpressiveness.lean` not edited.
  Re-flagged: `Section5Correspondence.lean:50` ("Every row above assumes
  `HasAttainedINF`/`HasAttainedSUP`") is now stale in a **third** way.
