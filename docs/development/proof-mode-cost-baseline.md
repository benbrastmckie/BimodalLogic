# Proof-mode cost baseline

[Back to Development](README.md)

What the derivation proof mode's scripts cost: the elaborated size of the term each builds, the
heartbeats and wall-clock milliseconds each takes, the axiom set each rests on, and how all four
grow with the length of a script.

**Audience**: anyone deciding whether the mode is usable on long scripts, or quoting a cost figure
in a report.

## Provenance

- **Measured surface commit**: `9dedc3977ec454a6c67d9f169df462ad414b3b74`
- **Toolchain**: Lean v4.33.0-rc1 (the `lean-toolchain` pin), Mathlib tag `v4.33.0-rc1`
  (resolved `79d0395a`)
- **Date**: 2026-11-23
- **Machine**: single host, library pre-built to completion, probe run under the shared
  `.lake/build-guard.lock` held to exit

The pinned commit is the head of the **measured surface** — the mode's elaborators
(`FormalSystem/Automation/ProofMode/`), its tactic-independent rules
(`FormalSystem/Theorems/ProofMode/`), the diagnostics library (`BimodalLib/Diagnostics/`) and the
probe itself — not of the whole repository. A change to how these figures are *reported* does not
invalidate them; a change to what is *measured* does.

## Reproduction

```
bash scripts/proof-mode-cost-baseline.sh
```

That is the whole command. Its **first** action is a staleness re-probe against the pin above: if
the measured surface has moved, it reports a stale baseline and exits non-zero without measuring
anything, because a figure taken against different code is worse than no figure. To re-measure
after a deliberate change, pass `--pin <new surface head>` and update the provenance line.

`bash scripts/proof-mode-cost-baseline.sh --json` is build-free, zeroes the stamp fields and the
two timing fields, and sorts the records by key. Two such runs from the same commit on the same
UTC day are byte-identical; `cmp` on their output is the determinism contract rather than a
restatement of it.

The script writes `data/proof-mode-diagnostics.jsonl` (75 records) and
`data/proof-mode-diagnostics_metadata.json`. **Neither is tracked**: this repository ignores
`/data` outright, and nothing under it is in git. The dataset is generated data whose provenance
is the tracked script plus the tracked schema, which is why one command reproduces it rather than
a checked-in file being consulted.

Measurement conditions in full: `specs/evidence/proof-mode-cost-baseline/README.md`. The schema
every field belongs to: [diagnostics.md](../reference/diagnostics.md).

## The headline: a long script is cheap to write and expensive to verify

`lintro` discharges through the deduction theorem, which transforms a whole derivation, so each
nested `lintro` re-walks what the previous ones built. Whether that makes a long script expensive
to *elaborate*, expensive to *check*, or both, was the open question. The answer is both parts,
and they differ:

| nesting `n` | term size | `5n² + 17n + 41` | residual | heartbeats |
|---:|---:|---:|---:|---:|
| 1 | 33 | (63) | (-30) | 20 |
| 2 | 95 | 95 | 0 | 37 |
| 3 | 137 | 137 | 0 | 48 |
| 4 | 189 | 189 | 0 | 58 |
| 5 | 251 | 251 | 0 | 68 |
| 6 | 323 | 323 | 0 | 78 |
| 7 | 405 | 405 | 0 | 89 |
| 8 | 497 | 497 | 0 | 99 |
| 9 | 599 | 599 | 0 | 110 |
| 10 | 711 | 711 | 0 | 120 |
| 11 | 833 | 833 | 0 | 130 |
| 12 | 965 | 965 | 0 | 141 |
| 13 | 1107 | 1107 | 0 | 151 |
| 14 | 1259 | 1259 | 0 | 162 |
| 15 | 1421 | 1421 | 0 | 172 |
| 16 | 1593 | 1593 | 0 | 183 |

**Term size is exactly `5n² + 17n + 41` for every `n` from 2 to 16, with residual zero at every
depth.** The `n = 1` row sits off the curve at 33 rather than 63, because a single `lintro` needs
no re-transform of an already-transformed derivation; the closed form describes the repeated case,
and the first step is the base case rather than a member of it.

**Heartbeats are linear**: 20 at depth 1 to 183 at depth 16, about 10.9 per level, with no
curvature.

The two together are the finding, and it is a two-part answer. The quadratic growth is in the term
the **kernel** must check; the **elaborator** pays only linearly, because the deduction theorem's
transform is structural rather than a re-elaboration. A long script is therefore cheap to write
and increasingly expensive to verify — the opposite of the usual tactic-cost shape, where a tactic
searches harder as the goal grows and the term it emits stays proportionate.

At the five-step threshold the question was originally posed at, the absolute cost is small: 251
term nodes and 68 heartbeats. Extrapolating the fit, a 50-deep script would be about 13,400 nodes
and a 100-deep one about 51,700 — large but not prohibitive. **On cost grounds the mode is usable
on long scripts and no rule change is called for.** That is the figure an adequacy gate can quote,
and the quadratic is the figure to quote with it: the cost is in checking, so a script that is
merely long is fine while a script that is long *and* re-elaborated often is not.

## The nested logical rewrite

The merged congruence kit (`lrewrite` / `lsimp`) promised a cost baseline and recorded none. This
is it: one implication transported through `d` nested scopes, the scope stack read outside-in.

| nested scopes `d` | scope stack | term size | Δ | heartbeats | axioms |
|---:|---|---:|---:|---:|---|
| 0 | (current point) | 1543 | — | 102 | `[propext]` |
| 1 | `□` | 1889 | +346 | 115 | `[propext]` |
| 2 | `□ G` | 2235 | +346 | 128 | `[propext]` |
| 3 | `□ G H` | 2581 | +346 | 143 | `[propext]` |
| 4 | `□ G H □` | 2927 | +346 | 153 | `[propext]` |

**Exactly +346 term nodes per nested scope level, linear, zero residual over `d = 0..4`.**
Heartbeats are linear too, about +13 per level.

Both halves of the finding matter, and the contribution's intuition was half right.

A single congruence certificate **is** large in absolute terms: 1543 nodes at depth 0, against 87
for a three-tactic modus-ponens script and 33 for a single `lintro`. That is roughly 18× a basic
script before any nesting at all, and it is the cost of assembling a certificate from proved
scope-transport rules rather than from a reflection principle.

But composition is **linear, not compounding**, so the certificates do not blow up. Each scope
adds a fixed 346 nodes regardless of how many are already there. Taking the two laws together,
`lintro`'s quadratic overtakes a nested rewrite at around depth 20: below that, nesting a rewrite
is the more expensive thing to do; above it, nesting introductions is.

The kit is also **foundation-light where its rules are**: every row rests on `[propext]` alone.
The certificate is built from constructors and proved rules, and nothing in the transport reaches
a classical principle.

## The simplifier

| row | term size | heartbeats | axioms |
|---|---:|---:|---|
| `lsimp only` with 1 rule, 1 reduction | 1061 | 115 | `[propext, Classical.choice, Quot.sound]` |
| `lsimp only` with 2 rules, 2 reductions | 2413 | 249 | `[propext, Classical.choice, Quot.sound]` |

`lsimp` is the most expensive single step measured, which matches its bounded-search design: it
roughly doubles in both size and heartbeats between one rule and two.

Its classical axioms come from the **rule list**, not from the simplifier. `doubleNegationIff`
reaches classical machinery on its own, while `lrewrite` through four nested scopes — the same
congruence engine, driven by a user-supplied map instead of a rule set — stays at `[propext]`.
That attribution is checkable rather than asserted, because
`Tests/BimodalTest/Automation/ProofModeAxioms.lean` pins both rows.

## Cost per tier

The architecture record asserts a separation between the views tier, which produces the same
judgment up to definitional equality or a cast, and the derivation tier, which builds a
derivation. The separation is measurable.

| tier | representative | term size | heartbeats | axioms |
|---|---|---:|---:|---|
| Views | `lfold diamond at provider` | 55 | 33 | `[propext]` |
| Views | `lfold diamond at provider; lunfold diamond` | 89 | 46 | `[propext]` |
| Derivation | `lstart; lapply; lexact` | 87 | 45 | `[propext]` |
| Derivation | `lintro; lexact` | 33 | 20 | `[propext, Classical.choice, Quot.sound]` |
| Derivation | `lrewrite` at depth 0 | 1543 | 102 | `[propext]` |
| Derivation | `lsimp only` with 1 rule | 1061 | 115 | `[propext, Classical.choice, Quot.sound]` |
| Derivation | `lsimp only` with 2 rules | 2413 | 249 | `[propext, Classical.choice, Quot.sound]` |

A views-tier step costs 55 to 89 nodes and stays at `[propext]`, because it changes how a formula
is presented rather than what has been derived. A derivation-tier step costs 33 to 2413 nodes at a
family-dependent axiom set. The ratio between the cheapest views step and the most expensive
derivation step measured is about 44×.

The one row that looks out of place is instructive: `lintro; lexact` is **smaller** than either
views row at 33 nodes, and it is the only cheap row that is not `[propext]`. Size and foundation
are independent axes. A step can be tiny and still reach the deduction theorem, and a step can be
large and reach nothing beyond `propext`.

## The acceptance corpus

All 48 positive acceptance scripts, measured as a corpus.

| | |
|---|---|
| Scripts | 48 |
| Term size, min / median / max | 15 / 335 / 4437 |
| Heartbeats, min / median / max | 25 / 80 / 491 |
| Total wall-clock elaboration | 389 ms |
| Closed by the mode's rules alone | 45 |
| Closed with a term-mode escape | 3 |

Axiom sets across the corpus:

| axiom set | scripts |
|---|---:|
| `[propext]` | 18 |
| `[propext, Classical.choice, Quot.sound]` | 26 |
| `[propext, Quot.sound]` | 4 |

The `[propext]`-only scripts are the ones built from `lstart`/`lapply`/`lexact`/`lsplit` and the
congruence kit; the classical ones are those that pass through `lintro`, `lcases` on a
disjunction, or a scope introduction. The four lighter `[propext, Quot.sound]` scripts are the TM⁺
ones, which measure *lighter* than their TM counterparts. Every one of these sets is pinned by a
`#guard_msgs` row in `Tests/BimodalTest/Automation/ProofModeAxioms.lean`, so this table cannot go
stale silently.

The spread is wide — 15 nodes to 4437, a factor of about 300 — and the top of it is entirely
rewriting across modal and temporal scopes: the three largest scripts are all from
`ProofModeModalTemporalBooleanTest.lean`, at 4437, 3917 and 3127 nodes. That is the nested
congruence certificate again, several at once in one fixture. The smallest, at 15 nodes, is a
single `lrewrite` with an explicit path and nothing else.

**48, not 52.** `grep -c '^example'` over the five fixture modules reports 52, and four of those
are `#guard_msgs`-guarded negative fixtures whose `example` also begins at column 0. A script
asserted to fail has no cost worth recording. The breakdown is in
`specs/evidence/proof-mode-cost-baseline/README.md`.

## Script against hand proof

One COMPARE record, for the only judgment in the corpus with both a proof-mode script and a
hand-built derivation of the same statement:

| | |
|---|---|
| Script length | 3 tactic invocations |
| Hand-proof length | 3 constructor applications |
| Length ratio | 1.0 |
| Derivation built by the script | 3 nodes, height 1 |
| Reference derivation | 3 nodes, height 1 |

The script and the hand proof build the **same derivation**, node for node — which is what the
mode's own constraint requires: every tactic assembles native constructors and proved rules, and
nothing semantic stands in for a derivation. At this size the mode costs nothing in brevity and
nothing in the derivation it produces; the 87-node elaborated term against the hand proof's
smaller one is the cost of the elaboration machinery, not of the derivation.

One row is not a distribution of length ratios, and this document does not claim it is. A real
distribution needs a reference proof per statement, which is what the tableau pipeline's Extract
stage will supply.

## What this document does not claim

- **No semantic-tier figure.** A semantic mode is not in merged state, and the task this baseline
  answers names exactly the views and derivation tiers. There is nothing measured to report.
- **No cross-machine timing comparison.** `elab_ms` is wall clock on one host. It is reported so
  the figures are legible, never so two machines' numbers are compared. `heartbeats` is the
  reproducible figure.
- **No cross-instrument heartbeat comparison.** A heartbeat figure taken by `#reprove_record`
  includes the wrapper's own record assembly, and runs consistently larger than the same script
  measured by Mathlib's `#count_heartbeats in` — roughly twice as large on the `lintro` ladder.
  What is instrument-independent is the *shape* of the growth, and the shape is what every claim
  above rests on: exactly quadratic in term size for `lintro`, exactly linear in term size for
  nested rewriting, linear in heartbeats for both.
- **No pinned number.** Not one figure on this page is asserted by a `#guard_msgs` anywhere.
  Neither term sizes nor heartbeats are stable across a Lean or Mathlib bump, and a pinned timing
  figure is a brittle test dressed up as a measurement. Only the axiom sets are pinned, in the
  test library. This page is regenerated, not guarded.

## Related

- [diagnostics.md](../reference/diagnostics.md) — the record schema every figure here is carried
  in, field for field
- `specs/evidence/proof-mode-cost-baseline/README.md` — measurement conditions and the probe
- `Tests/BimodalTest/Automation/ProofModeAxioms.lean` — the pinned axiom sets

---

[Back to Development](README.md)
