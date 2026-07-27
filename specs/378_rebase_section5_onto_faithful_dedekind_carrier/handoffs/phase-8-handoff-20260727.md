# Phase 8 handoff — the Prop 4.2 / 4.3 lift chain landed faithfully, in ONE run, first build

**Session**: `sess_1785164194_b6cbfb` | **Date**: 2026-07-27 | **Phase 8 status**: COMPLETED

## Immediate next action

Dispatch **Phase 9** (`Prop42Faithful.lean`): `prop42_contentful_of_dedekind`, the faithful analogue
of `prop42_contentful_of_attained` (`Section5Correspondence.lean:128`), plus the correspondence-table
extension and the final cumulative non-vacuity statement. Read PDF **p.6** directly first (PDF only)
— it is where Prop 4.2 is stated, and it states it **over Dedekind complete chains**, which is the
fidelity point the whole re-base turns on.

The consumable Phase 9 needs is `VVecEA2.negFixFaithful_iff`
(`EANegationFixFaithful/VecEANegFixFaithful.lean`), signature:

```
(M) (atomMap) (h_INF : HasDedekindINF M atomMap) (v : VVecEA2) (z0 z1) (h_lt : z0 < z1) :
  v.negFixFaithful.holds M atomMap z0 z1 ↔ ¬ v.holds M atomMap z0 z1
```

Re-confirm `Section5Correspondence.lean:128` and the correspondence table's current row numbering by
`grep -n` before editing — Phase 1 already rewrote six rows of that table, so it has moved once.

## What Phase 8 landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean`,
11 declarations, all axiom-clean, 0 sorries, **compiled on the first build**:

| Declaration | Role |
|---|---|
| `BracketFormula.negFixFaithful` / `_iff` | step 1 — the two-line wrapper over `negFixListFaithful`, closed by `BracketFormula.holds_iff_bracketOf` exactly as predicted |
| `VecEA2.negFixFaithful` / `_iff` | step 2 — Prop 4.2's three-way split `¬ψ₀ ∨ ¬ψ₁ ∨ ¬bracket` (PDF p.6) |
| `VVecEA2.negFixFaithful`, `vecEANegFixFaithfulFold_iff`, `VVecEA2.negFixFaithful_iff` | step 3 — Prop 4.3's De Morgan fold (PDF p.6) |
| `VecEA2.mem_negFixFaithful_disjuncts`, `VecEA2.negFixFaithful_of_bracket`, `VecEA2.negFixFaithful_carries_limit_gate` | the non-vacuity artifacts (see below) |
| `VVecEA2.negFixFaithful_iff_of_attained` | the attained → faithful shim, INF half only |

Plus one import edge + NOTE in `Kamp/NfMultiAnchorBridge.lean`.

## Key decisions / findings to carry forward

1. **The `map` in the attained lift is an artifact, and dropping it is the deviation.**
   `VecEA2.negFix` (`EANegationFix/VecEANegFix.lean:75`) maps its bracket leg under `⊤` endpoints
   because a `VBracketFormula` disjunct has no endpoint slots. The faithful bracket leg is already
   `List (Σ n, VecEA2 n)`, so the lift is `… :: vea.bracket.negFixFaithful.disjuncts` — **no map**.
   Reproducing the map would have `⊤`-erased `kplusLeftBlock`'s left-endpoint condition, i.e. would
   have deleted the limit gate at the lift. This is the Phase 4 canary's payoff appearing a second
   time, for the same structural reason. Recorded as Deviation 1 in the plan.
2. **`_iff` lemmas alone do NOT pin the construction.** All four biconditionals here would hold
   verbatim of a lift that dropped, merged or `⊤`-erased bracket-leg disjuncts, because their RHS
   mention only `¬ vea.holds`. Three carrier-free declarations close that gap and are the phase's
   non-vacuity content: `VecEA2.mem_negFixFaithful_disjuncts` (verbatim survival — a lemma the
   attained lift *cannot state*), `VecEA2.negFixFaithful_of_bracket` (semantic form, consumes no
   `_iff`), and `VecEA2.negFixFaithful_carries_limit_gate` (under `K⁺(¬β₁)(z₀)`, PDF p.9, the top of
   the chain is forced). **Phase 9 should extend this pattern, not drop it**: the final statement is
   equally capable of being true-but-hollow.
3. **`kplusLeftBlock` (`Lemma53Faithful.lean:189`) now has a FOURTH consumer** —
   `negChainOnFaithful`, `negFixOneCase1`, `negFixListFaithful` Case 1, and now
   `VecEA2.negFixFaithful_carries_limit_gate`. It is the standard carrier for the limit gate. Keep
   it; do not re-derive it.
4. **`kplusLeftBlock_holds` is an unconditional biconditional** (`(kplusLeftBlock P).holds M atomMap
   z0 z1 ↔ kplus M atomMap P.formula z0`, no side conditions, no `z0 < z1`), which is why the limit
   gate artifact is three lines. Useful if Phase 9 wants an analogous exhibit.
5. **Binding Constraint 3 held with room to spare.** No attempt at the model-independent backward
   direction was made or needed. `EANegation.lean` and `Boneyard/EANegationVBracketBackward.lean`
   were not read, not referenced, not edited. `BracketFormula.negFix_iff` (`NegFix.lean:694`) was
   cited only as the mirror whose *shape* was followed. The constraint is no longer live after
   Phase 9 either — Phase 9 is a statement assembly over `VVecEA2.negFixFaithful_iff`.
6. **All quoted line numbers were current**, but the plan's *path* for one was wrong: the file is
   `EANegationFix/VecEANegFix.lean`, not `Kamp/VecEANegFix.lean`; `find` was needed. Phase 9 should
   keep re-confirming — it has stayed cheap and has now caught a path error as well as line drift.

## `HasDedekindSUP`: FIFTH consecutive drop

Confirmed, not re-litigated. The lift is a De Morgan fold plus two endpoint legs; no step touches a
supremum, a `K⁻`, or a last-occurrence point. `HasDedekindSUP`, `orderedPointsExist_combine_kminus`
and `HasDedekindSUP.last_occ_tp` remain unconsumed after Phases 4, 5, 6, 7 and 8. **Phase 9 is not a
plausible consumer either** — its carrier is inherited from `VVecEA2.negFixFaithful_iff`, so it
should state `HasDedekindINF` alone; adding `HasDedekindSUP` "for symmetry" would be an unused
hypothesis and a strengthening that buys nothing. Phase 2 retains its independent value. Report the
drop in the Phase 9 / final summary; do not contrive a use.

## Measured results (actual, not asserted)

| Gate | After Phase 7 | After Phase 8 |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 1890 | **1891** (+1) |
| Live modules from `FormalSystem.lean` | 276 | **277** (+1) |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** |
| Tactic-position sorries in the new module | — | **0** |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** |
| `AggregateOffDiagK1` explicit build | 1098 jobs, EXIT 0 | **1098 jobs, EXIT 0** |

Census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. Liveness by
transitive `import` walk from `FormalSystem.lean`; `lake build BoneyardArchive` never run or cited.
All 11 new declarations verify as subsets of `[propext, Classical.choice, Quot.sound]` — no
`sorryAx`.

**The recurring axiom-count note, carry it forward.** Bare `grep -c '^axiom ' FormalSystem/`
returns **2**; both are prose continuation lines inside `Boneyard/` comments
(`Boneyard/DiscreteXY/Discreteness.lean:40`;
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration. Real
axiom count: **0**.

## Cumulative delta going into Phase 9

Documented plan baseline was 1883 jobs / 269 live modules. Now **1891 / 277** — 8 new live modules
across Phases 1-8, exactly +1 each, no Phase 7 re-split. Phase 9 adds the ninth
(`Prop42Faithful.lean`), so the plan's projected terminal figure of **1892 jobs / 278 live modules**
is one higher than its written expectation of 1891/277, which was stated before Phase 5's anchored
mirrors were counted as their own module. Use 1892/278 as the Phase 9 target and record the
discrepancy rather than silently matching the older number.

## Sizing

Closed in one agent run, first build, no re-split, no internal boundaries needed.
