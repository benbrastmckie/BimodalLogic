# Phase 4 — consumer census and edit list

All counts re-measured at implementation time (2026-08-18). Plan-time figures in parentheses.

## Arm-shape occurrence census (`identifyTime t₂ t₁`)

| File | actual (plan-time) | classification |
|------|--------------------|----------------|
| `Decidability/SignedFormula.lean` | 0 (0) | protected defs, untouched |
| `Decidability/Tableau.lean` | 1 (1) | **ARM-BOUND** — the arm itself, `Tableau.lean:1523` |
| `Verified/Termination/Fuel.lean` | 12 (12) | 1 prose (1886); **2 ARM-BOUND** shape lemmas (1907, 1937); 1 generically quantified (`knownTimes_card_lt_identifyTime`, 1973); **9 ARM-BOUND** fuel-figure arithmetic (2445-2457) |
| `Verified/Termination/MintBound.lean` | 69 (66) | **2 ARM-BOUND** (793 `expandOnceUnblocked_splitOrdered_shape`, 8012 `expandOnce_branch_shape_census`); the remaining 67 are **generically quantified** — `t₁`/`t₂` are bound variables and `identifyTime t₂ t₁` is naming convention only. +3 over plan-time is this task's own Phase 1-3 additions. |
| `Verified/Decidable.lean` | 1 (1) | **docstring prose only** (line 284) |
| `Verified/Termination/SubformulaProperty.lean` | 2 (2) | **docstring prose only** (57, 666); `applyRule_timeLinearity_closed`'s proof routes through the generically-quantified `identifyTime_formula_mem` |
| `Verified/Bridge/BranchOrder.lean` | 0 (0) | 5 `identifyTime` refs, all `#eval`/prose |
| `Tests/BimodalTest/UntlSnceCopyProbe.lean` | 0 (0) | 10 `nextTime` refs |
| `Decidability/Saturation.lean` | 0 (0) | **confirmed clean** — neither `nextTime` nor `identifyTime` |

Total 85 (plan-time 82); no row diverges by more than 5%.

The **decisive census finding**: only **14 of the 85** arm-shape occurrences are arm-bound
(1 Tableau + 11 Fuel + 2 MintBound). The 67 MintBound occurrences the plan sized Phase 7 around
are lemmas *generically quantified in `src`/`tgt`*; they are re-usable at the oriented arm by
instantiation, not by edit. Phase 7 is therefore much smaller than R4 anticipated.

## `Decidable.lean` scope question — ANSWERED: **NO proof edits required**

Its single `identifyTime t₂ t₁` occurrence (line 284) is inside the section docstring at 268-286.
Its 102 `Branch.nextTime` references consume `nextTime = maxTime + 1`, which the
byte-unchanged-definitions constraint preserves. `OrdWithin`, `lt_nextTime_of_mem_knownTimes`,
`OrdWithin.bound` and `OrdWithin.nextTime_not_mem` are stated as *membership* conditions precisely
because the numeric bound was already known non-inductive at this arm — so they are indifferent to
the orientation. Docstring update only; **no file-scope escalation needed**.

## `decide`/`#eval` sites depending on arm-3 behaviour

**Predicted UNCHANGED** (they call `Branch.identifyTime` / `TimeOrdering.identifyTime` *directly*,
not through the engine, so the arm's orientation is invisible to them):
- `Fuel.lean:1371` — `dualCheck (ord.identifyTime 2 1) [0,1,3]`
- `BranchOrder.lean:459, 465` — `branchOrderValid (chainBranch.identifyTime 2 1) ...`, `knownTimes`
- `MintBound.lean:7321` `nextTime_reissues_retired_time` — hand-assembled, historical record
- `Tests/BimodalTest/UntlSnceCopyProbe.lean` — 10 `nextTime` rows on hand-built branches with no
  identification step anywhere in the file
- `MintBound.lean:7578` `gate_is_reissue_hazard`, `7594` `gate_step_fires` — the gate's trigger is
  `some (2, 0)`, so `min = 0 = t₂` and `max = 2 = t₁`: **the oriented arm and the current arm are
  the same list at the gate**, already decided as `oriented_gate_invariants` conjunct 7

**Expected RED — the sites where a *successful* repair changes the value** (R5):
- `MintBound.lean:7370` `reuse_driven_through_engine` — drives the engine from `reuseWitnessState`
- `MintBound.lean:7797` `oriented_reuse_not_driven_through_engine`, `7816`
  `oriented_arm_is_not_inert` conjuncts 3-4 — likewise engine-driven

## Territory contract for the remaining phases

- Phase 5 → `Tableau.lean` (the arm + its comment block)
- Phase 6 → `Fuel.lean` (2 shape lemmas, `splitOrderedMeasure_lt_of_timeLinearity`, the fuel-figure
  arithmetic at 2436-2457, prose)
- Phase 7 → `MintBound.lean` (2 shape sites + ~15 `obtain ... := expandOnceUnblocked_splitOrdered_shape`
  destructuring sites at 816, 982, 1659, 1950, 3083, 3840, 4356, 4492, 4782, 4864, 5364, 5388,
  5485, 6135, 8013; plus the restated witnesses)
- Phase 8 → `SubformulaProperty.lean` + `Decidable.lean` (docstring) + `BranchOrder.lean` + probes
