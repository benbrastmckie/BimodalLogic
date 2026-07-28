# Phase 13 — Rabinovich Prop 4.2 re-based: `VecEANegFixFaithful` + `Prop42Faithful`

**Status**: COMPLETED. Full `lake build` green (1920 jobs), sorry-free and axiom-clean in this
territory, both regression canaries unchanged.

## What the phase did

Moved the top of the faithful chain onto `HasFaithfulDedekindINF` (`KPlusFaithful.lean:320`),
Rabinovich's eq (5.2) dichotomy stated at the **source's own** `K⁺` (his Definition (3), PDF p.3)
rather than at this tree's extra-conjunct `kplus`.

| Module | Change |
|---|---|
| `EANegationFixFaithful/VecEANegFixFaithful.lean` | 4 hypothesis binders swapped; shim re-routed to the direct composite `HasAttainedINF.toHasFaithfulDedekindINF`; 1 limit-gate hypothesis re-pointed `kplus → kplusOpen`; docstrings + `ADAPTED-FROM` |
| `Prop42Faithful.lean` | 1 hypothesis binder swapped; `prop42_contentful_of_faithful` and `prop42_faithful_covers_what_dedekind_excludes` landed; 2 corollaries re-pointed; 1 limit-gate hypothesis re-pointed; docstrings |
| `NfMultiAnchorBridge.lean` | 12 NOTE passages corrected across 6 edges. **Comment bytes only** — verified |

Declaration inventory against the phase base `9dc3466f9`: **0 removals, 0 renames** in all three
modules; 2 additions, both in `Prop42Faithful.lean`.

## The surveyed verdict held exactly

The plan surveyed both modules as a **pure signature swap** with **six hypothesis sites and no
destructure sites**. Both halves confirmed:

- **Zero proof steps changed.** Every tactic block in both modules is textually unchanged — the
  `rintro`/`rcases` three-way disjunct split, the `by_cases hl`/`hr` endpoint peel, the
  `List.foldr` induction, both `mem_cons` manipulations.
- **Zero failed proof attempts, zero proof-search tools invoked** at any point in the dispatch.
- **Both scoped builds green on the first attempt.**

The entire code-bearing delta is six binder/shim tokens, two hypothesis re-points with their one
retired coercion, and two new declarations.

## The cascade did not fire a third time

Phase 12.1 named both of this phase's cascade sites in advance and both behaved as predicted:
swapping `VecEANegFixFaithful.lean:105`'s binder deleted the `SCHEDULED FOR REMOVAL` coercion
automatically, and the definition-edge repair at `:295` was already in place. No new downstream
site fired — nothing outside this territory imports these modules except the aggregator, which
needed comment bytes only. The two-edge warning has now been validated three times and can be
treated as a settled property of this re-base.

## `prop42_contentful_of_faithful` and its guard

Landed at `HasFaithfulDedekindINF` alone — no `HasDedekindSUP`, no `HasDedekindINF`, no
`HasAttained*` — axiom-clean at `[propext, Classical.choice, Quot.sound]`.

The Rule 6 exclusion is **exhibited, not asserted**.
`prop42_faithful_covers_what_dedekind_excludes` produces `denseWindowFlow`
(`PriorDefsDense.lean:336`) with all five of: `SemanticPriorU`, `SemanticPriorS`,
`HasFaithfulDedekindINF`, `¬HasDedekindINF`, and `∀ v, Prop42Contentful M atomMap v`. So
Proposition 4.2 is available at that structure from the new carrier and **provably unavailable**
from the old one — the weakening is strict, and the last conjunct names `Prop42Contentful` itself,
so a future weakening of the negation chain breaks this declaration rather than merely the carrier
lemmas. That is the rot-prevention role the plan asked the faithful sibling to carry.

## CI-edge audit — recorded, passing

The transitive `import` closure of the default target's root `FormalSystem.lean` was computed
mechanically: **306 modules**. `lakefile.lean` declares `lean_lib FormalSystem` with
`roots := #[FormalSystem]` and no `globs`, so that closure *is* what `lake build` builds.

All thirteen probed modules are inside it — `NfMultiAnchorBridge`, `Prop42Faithful`, the five
`EANegationFixFaithful/` modules, `Lemma53Faithful`, `Lemma53FaithfulPast`, `KPlusFaithful`,
`PriorDefsDense`, `DedekindINFDense`, `Section5Correspondence`.

The six deep aggregator edges the plan names by line number (`:238`, `:252`, `:275`, `:297`,
`:320`, `:345`) are **real `import` lines**, each preceded by its long `--` NOTE block rather than
being inside one — checked explicitly, because a naive grep for the module name matches both. The
`KPlusFaithful` edge was already landed by Phase 10.1 at `WeakCanonical.lean:22`. **Nothing had to
be added.**

## Literature fidelity

PDF p.6 extracted verbatim with `pdftotext -f 6 -l 6 -layout` before any transcription; the
companion `.md` conversion is documented as corrupt and was not consulted. Rabinovich's Prop 4.2
sentence is now quoted verbatim in two docstrings. The Prop 4.3 **Negation:** case and De Morgan
fold paragraph, already quoted in `VecEANegFixFaithful.lean`, were checked against the extracted
page and are accurate as they stood.

What has no source says so: the carrier is this tree's reconstruction, and the entire non-vacuity
apparatus — the `perPoint_is_VACUOUS` control, the witness-exposure lemmas, the limit-gate
artifacts, the new coverage guard — has no counterpart in Rabinovich. Each docstring states that.

## Deviations

- **D11 (method choice, reported not silently annotated).** Five of six binders swapped in place.
  The sixth, `prop42_contentful_of_dedekind`, was NOT swapped: its name asserts its carrier, and
  swapping it in place is jointly unsatisfiable with two other items in the same phase (it would
  make the name false, would leave "land `prop42_contentful_of_faithful`" with nothing to be but a
  duplicate alias, and a rename would violate the declaration-preservation item). Instead the new
  faithful headline was landed under its honest name and the old pin retained unweakened as its
  one-line corollary. The module now carries a three-rung ladder — faithful < dedekind < attained —
  each rung named for the carrier it binds.
- **D12 (chartered by Phase 12.1, executed here).** Two limit-gate indispensability artifacts
  re-pointed `kplus → kplusOpen`, the gate the definitions actually read. **Does not violate D7**:
  the retired coercion was hypothesis-side, applied to the theorems' own hypotheses; no pin-side
  `kplusOpen_of_kplus` was touched anywhere, and `NegFixListFaithful.lean` is byte-identical.
- **D13 (frozen asset, stale prose, deliberately not edited).** `Section5Correspondence.lean`'s
  faithful re-base table now understates the chain by one carrier step. Every row remains *true*;
  the file is required byte-identical by this phase's Done-when, so it was left alone and flagged
  for whichever phase next owns it. Phase 14 does not automatically cover it.

## Block D re-base checkpoint — reached

The whole faithful chain runs on a carrier that dense Prior structures actually inhabit, and
`prior_hasFaithfulDedekindINF_dense` connects it to `SemanticPriorU`. The deferral recorded at
`DedekindINF.lean:87-103` is closed, and the aggregator NOTE that recorded it now says so instead
of asserting the opposite.

Chain carrier verified declaration by declaration. The single remaining `h_INF : HasDedekindINF`
binder anywhere in the chain is `HasDedekindINF.first_occ_tp` itself
(`NegFixOneFaithful.lean:230`), the additively-retained incomparable sibling from Phase 12's D5 —
correct and intentional, not a missed site.

**What remains open**: exactly one strengthening step — deriving the carrier from order
completeness of the chain rather than assuming it of the structure. Not attempted anywhere in this
tree, and `Prop42Faithful.lean`'s module docstring says so.

## Verification

| Check | Result |
|---|---|
| Full `lake build` | green, 1920 jobs (same count as Phase 12.1) |
| Scoped builds | 1126 / 1129 / 1192 jobs, all green, all first attempt |
| Sorry census | 163, unchanged from baseline; **0 in this territory** |
| `#print axioms` (12 declarations) | all `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |
| `completeness_discrete` | unchanged |
| `countermodel_discrete_reynolds_v2` | unchanged |
| Vacuous definitions | 1, pre-existing, outside territory, untouched |
| Read-only modules byte-identical | `EANegationFix/`, `Section5Correspondence.lean`, `KPlusFaithful.lean`, `NegFixListFaithful.lean` |
