# Phase 11 — Faithful-carrier re-base, base layer

- **Plan**: `plans/08_strong-completeness-dedekind-v8.md`, Phase 11
- **Status**: `[COMPLETED]`
- **Date**: 2026-07-28
- **Territory**: `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean`,
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53FaithfulPast.lean`
- **Commits**: `4e98b8b7c` (INF side), `59c349a61` (SUP side)

## Headline: R11's consumer-level verdict is HELD

Phase 10.1 settled R11 at the **carrier** level. Phase 11 was chartered to settle it at the
**consumer** level, at the smallest such site. It holds.

At `negChainOnFaithful_iff` the destructure

```lean
rcases h_INF.first_occ P.formula z0 z1 h_lt … with hk | ⟨r0, hr0a, hr0b, hnone, hPr0⟩
```

is **structurally unchanged** under `HasFaithfulDedekindINF`. Only `hk`'s type moved, from
`kplus M atomMap P.formula z0` to `kplusOpen M atomMap P.formula z0`. No third arm, no endpoint
`by_cases`, no new hypothesis. The mirror wrapper `HasFaithfulDedekindSUP.last_occ_tp` is likewise
two-arm. The chartered R11 fallback (re-base onto `HasDenseDedekindINF` with explicit `P(z₀)`
branches) is **not** triggered.

**Effort corroborates the verdict.** Zero failed proof attempts. Both scoped builds green on the
first attempt. No `lean_multi_attempt`, no `lean_state_search`, no `lean_hammer_premise` was
needed at any point.

## Scope limit, stated so it is not over-read

This settles the two base-layer destructure sites. It does **not** settle
`negFixOneFaithful_cover` (`NegFixOneFaithful.lean:422`) or `negFixListFaithful_iff`
(`NegFixListFaithful.lean:446`). Those have a `Case1 / Case2 / Case3a/b/c` shape, not a two-arm
shape, and Phase 11's evidence transfers to them as **encouragement, not proof** — Phases 12 and
12.1 must still transcribe Rabinovich's exhaustive case split rather than assume it collapses.

## THE MEASUREMENT (binding input to Phases 11.1-13)

### Per-declaration classification

`Lemma53Faithful.lean` (391 → 601 lines):

| Declaration | New anchor | Class | Detail |
|---|---|---|---|
| `kplusOpenPred` | `:140` | new primitive | `⟨Formula.kPlus P.formula⟩`; no new formula needed |
| `kplusOpenPred_eval` | `:145` | new primitive | one-liner via `kPlus_formula_correct` |
| `orderedPointsExist_combine_kplusOpen` | `:208` | **(b)** | binder + **one** proof line: `obtain ⟨-, hdense⟩ := hk` → `have hdense := hk`. Remaining 21 lines byte-identical |
| `orderedPointsExist_combine_kplus` | `:245` | retained, derived | statement verbatim; proof now a 1-line term via `kplusOpen_of_kplus` |
| `kplusOpenLeftBlock` | `:304` | new primitive | shape clone of `kplusLeftBlock` |
| `kplusOpenLeftBlock_holds` | `:309` | new primitive | shape clone, `kplusOpenPred_eval` substituted |
| `negChainOnFaithful` | `:340` | **(b)** | **one identifier**: `kplusLeftBlock` → `kplusOpenLeftBlock` |
| `negChainOnFaithful_iff` | `:365` | **(b)** | binder + 2 tactic-line renames. **Two-arm shape unchanged**; 66-line proof otherwise byte-identical |
| `lemma53Faithful` | `:460` | **(a)** | binder-type only; proof byte-identical |
| `lemma53Faithful_perPoint_is_VACUOUS` | `:496` | untouched | the failed-vacuity control, unchanged |
| `prior_makes_faithful_disjunct2_unreachable` | `:537` | **(c)**, new content | 5-line new proof; not re-base cost |
| `prior_makes_disjunct2_unreachable` | `:556` | retained, derived | statement verbatim; now derived from the line above |
| `coeHasDedekindINFToFaithful` | `:596` | original glue | 3 lines, **scheduled for deletion in 11.1** |
| `kplusPred`, `kplusPred_eval`, `kplusLeftBlock`, `kplusLeftBlock_holds`, `VVecEA2.prependAllVec(_holds)`, `orderedPointsExist_widen_left` | — | untouched | still consumed by Phases 12/12.1/13 |

`Lemma53FaithfulPast.lean` (364 → 491 lines):

| Declaration | New anchor | Class | Detail |
|---|---|---|---|
| `kminusOpenPred` | `:199` | new primitive | `⟨Formula.kMinus P.formula⟩` |
| `kminusOpenPred_eval` | `:203` | new primitive | one-liner via `kMinus_formula_correct` |
| `HasDedekindSUP.last_occ_tp` | `:221` | **untouched** | kept; see the deviation below |
| `HasFaithfulDedekindSUP.last_occ_tp` | `:254` | **(a)** | same 6-line unconditional two-arm proof at the faithful carrier |
| `orderedPointsExist_combine_kminusOpen` | `:343` | **(b)** | binder + the same one-line projection fix |
| `orderedPointsExist_combine_kminus` | `:380` | retained, derived | 1-line term via `kminusOpen_of_kminus` |
| `prior_makes_faithful_kminus_disjunct_unreachable` | `:464` | **(c)**, new content | 5-line new proof |
| `prior_makes_kminus_disjunct_unreachable` | `:482` | retained, derived | statement verbatim |
| `kminusFormula`, `kminus_formula_correct`, `kminusPred`, `kminusPred_eval`, `orderedPointsExist_combine_right`, `orderedPointsExist_widen_right`, `HasAttainedSUP.toHasDefinableSUP`, `hasDefinableSUP_excludes_kminus` | — | untouched | byte-identical |

### Counts

| Class | Count | Note |
|---|---|---|
| (a) binder-type only | 2 | `lemma53Faithful`, `HasFaithfulDedekindSUP.last_occ_tp` |
| (b) binder + projection/name fix | 4 | every one was a **one-line-or-one-token** fix |
| (c) genuinely new proof **attributable to the re-base** | **0** | — |
| (c) genuinely new proof, **new content** (honesty-charter exclusions) | 2 | 5 lines each |
| Mechanical new spelling-level primitives | 6 | `kplusOpen*` ×4, `kminusOpen*` ×2 |
| Retained-and-derived (statement verbatim, proof shortened) | 4 | nothing duplicated in substance |
| Original glue | 1 | the `Coe` shim |
| Destructure sites re-based | **2 of 2** | both kept their arm count |
| Failed proof attempts | **0** | both scoped builds green first try |

### What this schedules for 11.1-13

- **Phase 11.1** is now a **four-token binder swap plus one deletion**, machine-measured rather
  than estimated. Disabling the shim and rebuilding produced exactly eight
  `Application type mismatch` errors on the carrier argument —
  `BoundedFixFaithful.lean:215, :227, :281, :290` and
  `BoundedFixAnchoredFaithful.lean:181, :193, :257, :266` — and **no other error anywhere in the
  tree**. Neither module opens the carrier (an opened carrier would have produced a projection
  error, not a bare application-type mismatch). The plan's 4-hour estimate is generous by a wide
  margin; this is well under one agent run.
- **Phases 12 and 12.1** get their `K⁺` primitive cost **already paid**: `kplusOpenLeftBlock` and
  `kplusOpenPred` are landed, and Lemma 5.1's Case 1 site (`NegFixOneFaithful.lean:265`,
  `NegFixListFaithful.lean:279`) needs only to re-point at them. `kplusLeftBlock` and `kplusPred`
  were **deliberately retained** for exactly this. The residual risk in 12/12.1 is the
  `Case1/Case2/Case3a/b/c` exhaustiveness argument, which Phase 11 does not touch and does not
  settle.
- **Phase 13** (`VecEANegFixFaithful:295`, `Prop42Faithful`) consumes `kplusLeftBlock_holds`,
  retained and unchanged, so it remains a pure signature swap.

## Deviations

1. **`HasDedekindSUP.last_occ_tp` re-based additively, not in place.** The plan said "re-base";
   the change landed as `HasFaithfulDedekindSUP.last_occ_tp` beside a **kept, unchanged**
   `HasDedekindSUP.last_occ_tp`. Reason, and it is forced rather than chosen: the faithful carrier
   can only supply `kminusOpen P z₁` in the left disjunct, and `kminusOpen ↛ kminus`. An in-place
   re-base would therefore have strictly **weakened a landed conclusion**, which the phase's own
   `Done when` forbids. The two wrappers are incomparable (weaker hypothesis *and* weaker
   conclusion), so neither subsumes the other, and neither has a live consumer to disturb.
2. **An unplanned compatibility shim was required.** Not anticipated by the Faithful-Subtree
   Survey: re-basing `negChainOnFaithful_iff`'s binder reddens eight call sites inside Phase 11.1's
   territory, which Phase 11 may not edit. Resolved with `coeHasDedekindINFToFaithful`
   (`Lemma53Faithful.lean:596`), a `Coe` wrapper around the already-landed, sorry-free
   `HasDedekindINF.toHasFaithfulDedekindINF`. It runs in the safe direction only; the reverse edge
   does not exist and is not creatable. It is documented in-file as original glue with an explicit
   deletion charter, and Phase 11.1's task list now carries that deletion as a checklist item.

## Literature fidelity

Rabinovich 2014, Lemma 5.3 and eq (5.2), **PDF pp.8-9**, is the source for the base layer, and his
negation-chain discipline — *always take the infimum where the predicate fails* — is what disjunct
(2)'s re-gating restores. The printed `Oₙ₊₁` disjunct list and the printed subcase split
(*"Subcase `r₀ = z₀`" / "Subcase `r₀ ∈ (z₀,z₁)`"*) are quoted verbatim on `negChainOnFaithful_iff`
so a reader can check the transcription disjunct by disjunct. `K⁺`/`K⁻` are cited at Rabinovich's
Definitions (2) and (3), **PDF p.3**, and Reynolds 1992's abbreviation table, **printed p.168**.
Every docstring change carries either a printed-page citation or an explicit `ADAPTED-FROM` /
original-glue label.

## Verification

| Gate | Result |
|---|---|
| Scoped build, `Lemma53Faithful` | green, first attempt |
| Scoped build, `Lemma53FaithfulPast` | green, first attempt |
| Full `lake build` | green, 1919 jobs |
| Live sorries outside `Boneyard/` | exactly `Transfer.lean:1242`, unchanged |
| Vacuous definitions in territory | 0 |
| New axioms in territory | 0 |
| `#print axioms`, 21 territory declarations | `[propext, Classical.choice, Quot.sound]` or a subset; no `sorryAx` |
| Canary `completeness_dense` | `[propext, Classical.choice, Quot.sound]`, unchanged |
| Canary `completeness_discrete` | `[propext, Classical.choice, Quot.sound]`, unchanged |
| Canary `countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]`, unchanged |
| CI chain through `NfMultiAnchorBridge` | green |
| `KPlusFaithful.lean`, `DedekindINF.lean`, `PriorINF.lean`, `Lemma53.lean`, `EANegationFix/**`, `EANegationFixFaithful/**` | byte-identical |
| `consequence_completeness_dedekind_of_engine` | untouched |
