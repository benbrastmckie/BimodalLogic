# Phase 7, nineteenth dispatch — copy deletion closed, frame-class family landed (26 → 31 of 34)

**Session**: `sess_1785337808_19a89c_165`. **Mode**: `--hard`, single-phase (7 only).
**Commits**: five, all at green.

## What was authorized, and what was executed

`reports/04_untlneg-snceneg-repair-verification.md` **refuted** the proposed passive-arm
co-decomposition diff on termination grounds and separately found a concrete bug in it. That
refusal was honoured: no `untlNeg`/`snceNeg` **arm** logic was touched. The report's *scoped*
authorization — deletion of the two remaining copy blocks, landed alone — was executed, together
with the probe hardening it specified and the frame-class work it recommended as the honest
alternative destination for the budget.

## 1. The authorized copy deletion

Deleted `untlNegProps` (`Tableau.lean:1053-1058`) and `snceNegProps` (`:1126-1131`) from the
**ACTIVE** arms of `.untlNeg`/`.snceNeg`, plus their uses in the two `autoProp` lists. Landed as
its own commit per the report's §4.4 attributability requirement.

| Gate | Before | After |
|---|---|---|
| `TableauConformance.lean`, 29 `#guard_msgs` rows | GREEN, 59.0 s | GREEN, 62.8 s, **zero rows changed** |
| `UntlSnceCopyProbe.lean` | GREEN | GREEN, **zero rows moved** |
| `TemporalWitnessProbe.lean` | GREEN | GREEN, **zero rows moved** |
| `lake build …Verified.Decidable` | — | GREEN, 1350 jobs |

`applyRule_untlNeg_closed` in `SubformulaProperty.lean` survived **unchanged**, confirming report
04 §2.7's prediction that shrinking the emitted set only makes that lemma easier.

**Unlike the `untlPos`/`sncePos` deletion, this one moved nothing** — and the reason is
structural, not luck. The ACTIVE arms are gated on `futureTimes.isEmpty && 0 < timeCount < 4`, so
the copies were dormant on every measured row. The deletion is necessary for
`RuleSound carrierBase .untlNeg`/`.snceNeg` under any future passive-arm design; it is not a
behaviour change on the current corpus. Recording the null result as a null result matters: the
previous deletion moved five verdicts and it would have been easy to expect the same here.

## 2. Probe hardening — and a report specification that did not survive measurement

Applied: `armsB` now reads **either** branching constructor (matching `.branching` alone would
silently empty it under the constructor switch a repair requires, making B4 read `false`
**vacuously** — indistinguishable from a genuine repair); new **B0** pins which constructor is
live; new **B6** pins the post-blocking pass, whose fresh-time rejection test reads `applyRule`'s
*outer* ordering and is blind to a fresh time hidden in a per-arm ordering.

**B5 was redesigned, and the redesign is the dispatch's most transferable result.** The report
specified a single count at fixed fuel, pinned, with any growth read as divergence. Measured,
that is un-pinnable: following `expandOnce`'s first arm from `bB` the known-time count is
`2 + k/4` and does **not** saturate through `k = 128`.

A control row decided the attribution and **reversed** the naive reading:

| `k` | 0 | 4 | 8 | 16 | 32 | 64 | 128 |
|---|---|---|---|---|---|---|---|
| triggered (`bB`) | 2 | 3 | 4 | 6 | 10 | 18 | 34 |
| control (`Until` deleted) | 1 | 3 | 4 | 7 | 12 | 23 | **44** |

The growth is ordinary seriality-driven witness minting, **not** `untlNeg` — the negative `Until`
slightly *slows* it. Without the control this would have been recorded as an `untlNeg` divergence
signature and been **wrong**. B5 is therefore pinned as a *differential* gate (both profiles,
plus **B5′** pinning triggered ≤ control at `k = 16,32,64,128`); a passive-arm repair that
re-fires reverses that inequality.

## 3. Frame-class rules: 26 → 31

Both blocking questions from the previous dispatch were settled, one by refuting its premise.

- **`carrierDiscrete` as an `Exists`** — `CarrierProp` returns `Prop`, `SuccOrder`/`PredOrder`
  are data. Destructure with **`letI`, not `haveI`**: `haveI` is opaque, so the installed
  instance is not defeq to the destructured one and the Archimedean fields fail against it.
- **Import edge verified, not assumed** — `Metalogic.Soundness` stays refused;
  `SoundnessLemmas.FrameClassVariants` has a disjoint closure and a grep over `Semantics/`,
  `ProofSystem/`, `SoundnessLemmas/`, `Syntax/` finds **zero** imports of `Decidability`.
  Landed `ruleSound_priorUZ`, `ruleSound_priorSZ`, `ruleSound_z1Rule`.
- **The Dedekind pair landed by LOCAL proof, because the cost estimate was wrong for them.**
  `prior_U_gap_valid`/`prior_S_gap_valid` are behind the refused edge, so reuse was unavailable —
  but `Soundness.lean`'s own docstring records that the argument consumes **only** the
  least-upper-bound hypothesis and the linear order. Each is a ~30-line supremum construction and
  both re-proved here elaborated **green on the first attempt**. The "several hundred lines"
  figure is right for the *discrete* `SuccOrder`/`PredOrder` descent — which is exactly why those
  three were reused instead — and was wrongly generalised to all six.

Two Lean facts worth carrying: the `z1Rule` matcher is a raw constructor pattern over derived
operators, needing four `split`s and then `rename_i` over the **last six** inaccessibles (naming
fewer silently binds the match equations and yields a confusing `Sign.pos = Sign.pos` mismatch);
and `Branch.contains` is a `List.any` over `==`, **not** `List.elem`, so
`List.mem_of_elem_eq_true` does not apply.

## 4. Final verification

| Check | Result |
|---|---|
| `lake build` (full) | **GREEN, 1983 jobs** — matches prior baseline exactly; the new import edge added no net cost |
| `lake build …Verified.Decidable` | GREEN, 1353 jobs |
| `lean-sorry-census.sh` over `Verified/` | `sorry_count: 0`, empty inventory |
| new axioms | **0** (both repo-wide `^axiom ` hits are prose inside Boneyard comments, not declarations) |
| vacuous definitions | 0 introduced (the single match is the pre-existing, legitimate `int_domain_universal`) |
| `grep -c '^theorem ruleSound_'` | **31** |

## 5. Ledger — three rules open, for three different reasons, none of them budget

| Rule | Why open |
|---|---|
| `untlNeg`, `snceNeg` | PASSIVE-arm repair REFUTED on termination (cross-formula divergence, not minimally repairable). Separate design-research fork. Copy blocks now gone — necessary, not sufficient. |
| `sepRule` | Needs `exists_countable_order_dense`, a substantial development in `SoundnessLemmas/Separability.lean`. A genuine dependency, not a thirty-line argument. |

Not attempted, per dispatch scope: 7.3, and any `untlNeg`/`snceNeg` arm restatement.
