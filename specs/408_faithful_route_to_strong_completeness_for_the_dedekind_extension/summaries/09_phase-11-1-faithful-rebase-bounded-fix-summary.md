# Phase 11.1 — Faithful-carrier re-base: `BoundedFixFaithful` + `BoundedFixAnchoredFaithful`

**Status**: COMPLETED. Full `lake build` green (1919 jobs), sorry-free, axiom-clean.

## What landed

Rabinovich Corollary 5.4(1)/(2) — unanchored and anchored, PDF p.9 — now bind
`HasFaithfulDedekindINF` rather than `HasDedekindINF`. Four binders:

| Declaration | File:line | Change |
|---|---|---|
| `negBoundedRightFixFaithful_iff` | `BoundedFixFaithful.lean:204` | binder type only |
| `negBoundedLeftFixFaithful_iff` | `BoundedFixFaithful.lean:277` | binder type only |
| `negBoundedRightFixAnchoredFaithful_iff` | `BoundedFixAnchoredFaithful.lean:165` | binder type only |
| `negBoundedLeftFixAnchoredFaithful_iff` | `BoundedFixAnchoredFaithful.lean:248` | binder type only |

Not one proof step changed in any of the four. The eight call sites Phase 11 measured as red
(`BoundedFixFaithful.lean:215`, `:227`, `:281`, `:290`;
`BoundedFixAnchoredFaithful.lean:181`, `:193`, `:257`, `:266`) needed **no edit at all** — each
passes `h_INF` straight through to `negChainOnFaithful_iff`, so changing the binder fixed them.

The four `_of_attained` wrappers in the two modules gained an explicit second hop,
`h_INF.toHasDedekindINF.toHasFaithfulDedekindINF`.

## The shim is gone

`coeHasDedekindINFToFaithful` (`Lemma53Faithful.lean:596`) and its 33-line "Re-base compatibility
shim — ORIGINAL GLUE" section note are deleted. `Lemma53Faithful.lean` went 601 → 565 lines.

Confirmed by three independent checks, not by assertion:
- Declaration-inventory diff against the prior commit: **exactly one removal, nothing else**.
- `grep` over `FormalSystem/`: **no remaining reference** to the identifier.
- Full build green **without** it — so nothing was silently relying on the coercion firing.

## Carrier is not opened — the survey finding is confirmed

In all four `_iff` proofs, `h_INF` occurs *only* as an argument to `negChainOnFaithful_iff`. It is
never `rcases`d, never projected, never `h_INF.first_occ`. The v8 survey's "no destructure sites"
finding holds, and the Phase 11 fallback (re-base onto `HasDenseDedekindINF` with explicit endpoint
branches) is **not** triggered. Recorded in both module docstrings.

## Deviation D3 — five tokens outside territory

Swapping the binders reddened five transitive call sites one module further down:
`NegFixOneFaithful.lean:253` (Phase 12's territory) and `NegFixListFaithful.lean:368`, `:421`,
`:437`, `:500` (Phase 12.1's). All consume `negBoundedLeftFixAnchoredFaithful_iff`.

Phase 11's eight-error probe could not have seen these: it disabled the shim while leaving the four
binders in place, so it measured consumers of `negChainOnFaithful_iff`, not the transitive
consumers of the four Cor 5.4 `_iff`s. **That is a genuine blast-radius miss in the Faithful-Subtree
Survey**, recorded rather than absorbed.

Resolved by inserting `.toHasFaithfulDedekindINF` at each of the five argument positions. Nothing
else in those two modules changed — their binders, statements, docstrings and proofs are otherwise
untouched, so Phases 12 and 12.1 proceed exactly as planned.

The alternative — retaining the shim — would have kept the tree green with zero out-of-territory
edits, and would have violated this phase's own binding deletion charter. The charter's stated
reason for deletion is that the shim *"would let a later reader pass a needlessly strong carrier
without seeing that they had"*; an explicit, greppable coercion at each site is precisely the
visibility it asks for.

## Verification

| Gate | Result |
|---|---|
| Scoped build | green, first attempt, zero proof-search tool calls |
| Full `lake build` | green, 1919 jobs — no scoped-aggregator fallback needed |
| Sorry census outside `Boneyard/` | exactly `WeakCanonical/Transfer.lean:1242` — baseline unchanged |
| `#print axioms`, 9 touched declarations | `[propext, Classical.choice, Quot.sound]` throughout |
| Canary `completeness_dense` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| Canary `completeness_discrete` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| Canary `countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]` — unchanged |
| Pinned `consequence_completeness_dedekind_of_engine` | untouched; axioms unchanged |
| Vacuous definitions introduced | 0 |
| Axioms introduced | 0 |
| Declarations lost | 1, the chartered shim; no others |
| Conclusions weakened | 0 — hypothesis weakening only, which strengthens each theorem |
| Attained originals `EANegationFix/**` | byte-identical, not in the diff |
| `Decidability/`, `Automation/` | not edited, not staged |

## Route status

R11 remains held at the carrier and base-layer-consumer level, and now at the Corollary 5.4 layer:
four more consumers re-based with zero new proof branches. This still does **not** settle
`negFixOneFaithful_cover` (`NegFixOneFaithful.lean:422`) or `negFixListFaithful_iff`
(`NegFixListFaithful.lean:446`), whose Case1/Case2/Case3a/b/c shape is not a two-arm shape. Phases
12 and 12.1 must still transcribe Rabinovich's exhaustive case split (Lemma 5.1, PDF p.9) rather
than assume it collapses.

**Standing warning for Phases 12 and 12.1**: assume the one-module-further cascade recurs. Before
declaring either phase done, grep for transitive consumers of every re-based `_iff` — a
shim-disabled probe does not reveal them.
