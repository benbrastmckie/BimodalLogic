# Research Report: Task #956 - Trajectory Review and Path Forward

**Task**: 956 - construct_d_as_translation_group_from_syntax
**Date**: 2026-03-13
**Mode**: Team Research (3 teammates - run 047)
**Session**: sess_1773425380_20431
**Focus**: Evaluate implementation trajectory, viability, and ideal forward path without sunk-cost reasoning

---

## Executive Summary

- **Verdict**: The current approach (Pattern C - fuel-based iteration) is **structurally blocked**, not merely complex to implement.
- **Root cause**: The `seriality_escape` mechanism has an unaddressed and possibly-unprovable precondition (`h_indep`) that prevents constructing a guaranteed-distinct escape MCS.
- **Cycling pattern confirmed**: The same obstruction has been restated 10+ times across 46 research reports without resolution.
- **Recommended pivot**: Prove density **directly on the quotient** (`TimelineQuot` / `Antisymmetrization`), where reflexive clusters collapse to points and strictness is automatic.
- **Do not continue Pattern C**: 23 plan versions and 40+ research reports targeting the same gap is sufficient evidence that a different path is needed.

---

## Summary of Teammate Findings

### Teammate A: Progress & Trajectory Analysis

**Verdict**: Classic research cycling detected.

**Key evidence**:
- 148 commits over 7 days, 46 research reports, 23 plans, 29+ summaries
- Sorry count **oscillates** (not monotonically decreasing): 0 → 3 → 14 → 10 → 12 → 9 → 17 → **25 current**
- The reflexive cluster escape obstruction was correctly identified on **Day 3** (research-003/004) and has been restated in every subsequent research cycle
- Strategy "evolution" (Translation Group → Cantor Pipeline → Pattern A/B/C) is lateral movement — all require the same unimplemented core: well-founded iteration
- The five "Pattern C" recommendations (research-043 through 046) are identical in mathematical content

**What IS proven (sorry-free)**:
- `density_frame_condition` (non-strict version) ✓
- `density_frame_condition_caseA` ✓
- Supporting lemmas: `caseB_M_not_reflexive`, `irreflexive_mcs_has_strict_future`, reflexivity/equivalence helpers ✓
- Infrastructure: TranslationGroup, BidirectionalReachable, DenseTimeline, CantorPrereqs ✓

**What is NOT proven**:
- `density_frame_condition_strict` — the main goal, 25 sorries remain after 7 days

**Assessment**: The task is cycling on a structural mathematical gap, not progressing toward resolution.

---

### Teammate B: Alternative Mathematical Approaches (Independent Research)

**Approach A — Quotient-First (Antisymmetrization)** [RECOMMENDED, HIGH feasibility]

The core insight: The reflexive cluster obstruction arises from working at the **representative level** where equivalence classes contain multiple mutually-accessible MCSs. In the quotient, these clusters collapse to single points.

```
AntiMCS := Antisymmetrization MCS CanonicalR
```

1. Inherit `PartialOrder AntiMCS` from Mathlib (`instPartialOrderAntisymmetrization`)
2. Prove `DenselyOrdered AntiMCS` — find witness class `[W]` between `[M]` and `[M']`
3. Strictness is **automatic**: `[M] < [W] < [M']` in quotient means no reflexive loops
4. Representative-level strictness follows from quotient-level density

Mathlib support: Strong. `Antisymmetrization`, `toAntisymmetrization_le_toAntisymmetrization_iff`, `AntisymmRel.lt_congr`, `Order.iso_of_countable_dense`.

**Confidence**: 90% mathematically sound, 85% Mathlib is sufficient, 30% current approach can succeed.

**Other approaches considered**:
- B. Cantor Back-and-Forth: MEDIUM feasibility — direct embedding of Q witnesses density, but requires constructing midpoint function
- C. Segerberg Transformation: MEDIUM-LOW — replace clusters with Q copies, but requires major new infrastructure
- D. Strict accessibility relation: LOW — changes the logic, unclear consequences

---

### Teammate C: Viability Assessment of Pattern C

**Verdict**: BLOCKED — Structural mathematical gap, not implementation complexity.

**Critical Blocker: `h_indep` precondition (line 1509-1510)**

The `reflexive_seriality_escape_via_seed` theorem requires:
```lean
(h_indep : forall L : List Formula, (forall phi in L, phi in GContent M') ->
           NOT Nonempty (DerivationTree L (Formula.some_future psi)))
```

This hypothesis requires proving `F(psi)` is NOT derivable from `GContent(M')`. It:
1. Has no constructive witness anywhere in the codebase
2. Cannot be established for arbitrary formulas
3. May be false for some configurations

Without `h_indep`, the escape seed `{G(¬psi)} ∪ GContent(M')` may be inconsistent — no escaping MCS M'' can be constructed.

**Secondary blockers**:
- `strictDensityIterWithFuel` returns `none` in escape cases — no actual escape logic implemented
- Lindenbaum extension is non-deterministic: even with consistent seed, the resulting M'' may be equivalent to M' (no guarantee of different equivalence class)
- `fuel_suffices` termination proof is NEVER PROVEN — no measure decrease lemma exists

**The consistent-state problem**: All 25 sorries occur where `exfalso` is attempted on configurations that are mathematically consistent (W ~ M, M ~ M'). These cases CANNOT be discharged by contradiction. Iteration cannot fix this because it just moves to a different (also consistent) configuration.

**Confidence**: 90% that Pattern C is structurally blocked.

---

## Synthesis

### Conflict Resolution

**Teammate A vs C**: A says "implementation complexity is the bottleneck"; C says "structural gap is the bottleneck."

**Resolution: C is more precise**. The `h_indep` precondition IS the specific structural gap that explains WHY every implementation attempt fails with new sub-cases. Complexity is the observable symptom; the unaddressable precondition is the cause. This is not merely "hard Lean formalization" — it is a genuine open problem in the proof strategy.

### Gaps Identified

1. **Quotient-level density proof burden**: The quotient-first approach shifts proof obligation to `DenselyOrdered AntiMCS`. This needs verification — does the density axiom DN in the logic force this? (Likely yes, but needs confirmation.)

2. **Lifting mechanism**: Does quotient-level density give us exactly what CantorApplication needs? The `Order.iso_of_countable_dense` theorem operates on the quotient already, so this should be direct.

3. **`CantorApplication.lean` compatibility**: The 3 sorries there directly call `density_frame_condition_strict`. If we replace the proof strategy, do these call sites change? Likely yes — they would call quotient-level density instead.

### The Fundamental Assessment

The mathematics is clear:
- **Non-strict density** (the non-quotient version) is provable and proven ✓
- **Strict density at the MCS representative level** faces a genuine structural gap that 7 days of attempts have not resolved
- **Density at the quotient level** (Antisymmetrization) sidesteps the problem entirely because the quotient collapses reflexive clusters to points

The current 2559-line `DensityFrameCondition.lean` with 25 sorries is **technical debt that should not be extended**. A new, smaller proof targeting the quotient structure directly is the correct path.

---

## Recommendations

### Primary: PIVOT to Quotient-First Density

**Recommended action**: Stop extending `DensityFrameCondition.lean`. Design a new proof strategy around `DenselyOrdered (Antisymmetrization MCS CanonicalR)`.

**Rationale**:
1. The reflexive cluster obstruction **does not exist** in the quotient — clusters are single points
2. Mathlib has all needed infrastructure (`Antisymmetrization`, `PartialOrder`, `DenselyOrdered`, `Order.iso_of_countable_dense`)
3. CantorApplication already operates on `TimelineQuot` (the quotient) — this is where density needs to hold
4. A fresh proof in ~300-500 lines should suffice vs. a 2559-line file that hasn't converged

**Prototype first**: Before a full plan revision, write a 50-line proof sketch showing:
```lean
def AntiMCS := Antisymmetrization (Set Formula) CanonicalR
instance : DenselyOrdered AntiMCS := ⟨fun [M] [M'] hlt => ...⟩
```
If this compiles, the path is clear.

### Secondary: Assess DensityFrameCondition.lean status

Two options for the existing file:
- **Archive to Boneyard**: The 2559-line file with 25 sorries represents a fundamentally flawed approach — precisely the condition for boneyard archival per project policy
- **Preserve non-strict theorems**: `density_frame_condition` and supporting lemmas are proven sorry-free and may be needed as input to the quotient proof

**Recommendation**: Move the strict density attempt to Boneyard; keep non-strict `density_frame_condition` and its sorry-free support lemmas in a smaller dedicated file.

### Do NOT pursue

1. **Further Pattern C iteration** — `h_indep` is unaddressable without either a mathematical breakthrough or a change of approach
2. **Axiomatizing strict density** — the quotient approach avoids the need entirely; axioms are unnecessary
3. **More research reports on the current approach** — sufficient evidence exists; more research will produce the same answer

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (trajectory-analyst) | Progress/cycling analysis | Completed | HIGH |
| B (alternative-approaches) | Independent alternative research | Completed | HIGH (quotient-first) |
| C (viability-assessor) | Pattern C structural viability | Completed | 90% blocked |

**Conflicts**: 1 (complexity vs. structural gap — resolved in favor of structural gap)
**Wave 2 triggered**: No (convergence on quotient-first recommendation is clear)

---

## Action Items for Next Phase

1. **Prototype** `DenselyOrdered (Antisymmetrization (Set Formula) CanonicalR)` in isolation
2. **Verify** that `CantorApplication.lean` uses the quotient structure (confirm 3 sorries are about TimelineQuot density)
3. **Plan revision** (`/revise 956`): New Phase 6 targeting quotient-level density
4. **Boneyard decision**: Decide fate of `DensityFrameCondition.lean` (archive strict density attempt, preserve non-strict lemmas)

---

## Technical Evidence

### Current Sorry Locations in `DensityFrameCondition.lean`

Lines: 622, 624, 717, 721, 723, 773, 778, 785, 1065, 1084, 1113, 1173, 1918, 2003, 2260, 2279, 2321, 2340, 2446, 2478, 2534, 2555 (+ more, total ~25)

All in iteration cases where `exfalso` is attempted on mathematically consistent configurations.

### Key Infrastructure That Remains Valid

| Component | Location | Status |
|-----------|----------|--------|
| `density_frame_condition` | DensityFrameCondition.lean:191 | ✓ Sorry-free |
| `caseB_M_not_reflexive` | DensityFrameCondition.lean:72 | ✓ Sorry-free |
| `irreflexive_mcs_has_strict_future` | DensityFrameCondition.lean:249 | ✓ Sorry-free |
| TranslationGroup infrastructure | TranslationGroup.lean | ✓ Sorry-free |
| BidirectionalReachable | BidirectionalReachable.lean | ✓ Sorry-free |
| DenseTimeline | DenseTimeline.lean | ✓ Sorry-free |
| CantorPrereqs | CantorPrereqs.lean | ✓ Sorry-free |

### Mathlib References for Quotient-First Approach

- `Antisymmetrization` — `Mathlib.Order.Antisymmetrization`
- `instPartialOrderAntisymmetrization` — automatic PartialOrder from Antisymmetrization
- `toAntisymmetrization_le_toAntisymmetrization_iff` — lifting criterion
- `Order.iso_of_countable_dense` — Cantor's theorem (already used in CantorApplication)
- `DenselyOrdered.exists_between` — the key typeclass instance needed
