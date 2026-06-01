# Implementation Summary: Temporal G/H/F/P Tableau Rules (Time-Indexed)

- **Task**: 234
- **Status**: Completed
- **Session**: sess_1748790000_orch234

## What Was Done

Replaced 4 unsound identity-collapse temporal rule placeholders with 8 correct time-indexed temporal tableau rules implementing strict-inequality semantics. Added TimeOrdering constraint tracking, time-specific Branch helpers, fixed broken decomposition helpers, and threaded temporal ordering through the entire expansion pipeline.

## Changes by Phase

### Phase 1: Time Branch Helpers and TimeOrdering Structure
- Added 7 Branch helper functions to `SignedFormula.lean`: `knownTimes`, `maxTime`, `nextTime`, `allFuturePosFormulas`, `someFutureNegFormulas`, `allPastPosFormulas`, `somePastNegFormulas`
- Added `TimeOrdering` structure with `empty`, `initWithTime0`, `addFuture`, `addPast`, `futureOf`, `pastOf` methods

### Phase 2: Fix Decomposition Helpers and Add F/P Rule Constructors
- Fixed `asSomeFuture?` and `asSomePast?` to match correct structural forms (`.some_future`/`.some_past` patterns instead of wrong double-negation patterns)
- Added `asAllFuture?` and `asAllPast?` decomposition helpers
- Added 4 new `TableauRule` constructors: `someFuturePos`, `someFutureNeg`, `somePastPos`, `somePastNeg`
- Updated `isApplicable` and `allRules` for all 4 new rules

### Phase 3: Thread TimeOrdering Through Expansion
- Changed `applyRule` to accept `TimeOrdering` and return `(RuleResult, TimeOrdering)` pairs
- Updated `findApplicableRule` to return `Option (TableauRule x RuleResult x TimeOrdering)`
- Updated `isExpanded`, `findUnexpanded`, `expandOnce` to accept `TimeOrdering`
- Updated `expandBranchWithFuel` in `Saturation.lean` to thread `TimeOrdering` through recursive calls
- All default parameters set to `TimeOrdering.empty` for backward compatibility

### Phase 4: Rewrite G/H Rules and Add F/P Rules
- **Universal/persistent rules** (propagate to all known times):
  - T(GA): uses `timeOrd.futureOf` to find future times, returns `.persistent`
  - F(FA): uses `timeOrd.futureOf` to find future times, returns `.persistent`
  - T(HA): uses `timeOrd.pastOf` to find past times, returns `.persistent`
  - F(PA): uses `timeOrd.pastOf` to find past times, returns `.persistent`
- **Existential/consumable rules** (introduce fresh time points):
  - F(GA): introduces fresh future time via `branch.nextTime`, updates `timeOrd.addFuture`, auto-propagates T(GA)/F(FA) formulas
  - T(FA): introduces fresh future time, updates ordering, auto-propagates future universals
  - F(HA): introduces fresh past time via `branch.nextTime`, updates `timeOrd.addPast`, auto-propagates T(HA)/F(PA) formulas
  - T(PA): introduces fresh past time, updates ordering, auto-propagates past universals

### Phase 5: Integration Testing
All 13 tests passed:
- VALID: `G p -> G p`, `G(p->q) -> (Gp->Gq)`, `H(p->q) -> (Hp->Hq)`, `Fp -> Fp`, `Fp -> ~G~p`, `~G~p -> Fp`, `Pp -> ~H~p`
- INVALID (strict semantics): `Gp -> p`, `Hp -> p`, `p -> Gp`, `~G(bot)`, `Fp -> p`, `Pp -> p`

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | +7 Branch helpers, +TimeOrdering structure |
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | Fixed decomposition helpers, +4 rule constructors, +4 isApplicable cases, rewrote 4 G/H rules, implemented 4 F/P rules, updated allRules, threaded TimeOrdering through applyRule/findApplicableRule/expandOnce |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | Threaded TimeOrdering through expandBranchWithFuel |

## Verification Results

- **sorry_count**: 0 (in modified files)
- **vacuous_count**: 0 (in modified files)
- **axiom_count**: 0 new
- **build_passed**: true (1679 jobs)
- **compliance_check**: passed

## Plan Deviations

- Parameter named `ord` instead of `to` in TimeOrdering methods (Lean 4 reserves `to` as keyword)
- `applyRule` returns `(RuleResult, TimeOrdering)` for ALL rules, not just temporal (simpler uniform API)
- `expandOnce` kept in Tableau.lean (not moved to Saturation.lean as plan suggested)
- `buildTableau` uses default parameter `TimeOrdering.empty` rather than explicit initialization
- Integration tests run via standalone lean file rather than embedded `#eval` in Tableau.lean
- `isApplicable` and `allRules` updates completed in Phase 2 rather than Phase 4
