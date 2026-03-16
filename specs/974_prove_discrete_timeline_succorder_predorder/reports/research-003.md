# Research Report: Task 974 — Strategic Blocker Analysis

**Task**: 974 - prove_discrete_timeline_succorder_predorder
**Date**: 2026-03-16
**Mode**: Team Research (3 teammates)
**Session**: sess_1742181000_r9l4s
**Focus**: Blocker analysis in context of tasks 973/977/978; refactor-first vs results-first strategy

---

## Summary

The Phase 4 blocker in task 974 has two layers. The **architectural layer** is that
`buildStagedTimeline` unconditionally inserts density intermediates at odd stages via
`processDensity` → `density_of_canonicalR`, which invokes the DN (density) axiom. For a
discrete root MCS (where DN is not derivable), these witnesses are `Classical.choose`
artifacts with no semantic meaning — but they exist in the construction. The **semantic
layer** is that the `isDiscreteCompatible` predicate is a classification tool only: it
does NOT constrain the derivation relation, so `theorem_in_mcs` may still apply DN.

All three teammates independently converge on **Option B (discrete staged construction)**
as the correct resolution. **Task 978 (refactor-first) does NOT help** — the 974 blocker
is at the algorithmic/construction level, while 978 is at the typeclass/type-system level.
**Task 973 is effectively complete** (no code-level sorries remain).

---

## Key Findings

1. **Two DN dependencies, not one.** The blocker involves:
   - (Primary) `processDensity` → `density_of_canonicalR` at odd stages
   - (Secondary) `staged_timeline_has_future` → `iterated_future_in_mcs` → `density_F_to_FF`
   Both must be fixed for Option B.

2. **The discrete/dense construction diverges at the right place — but not far enough.**
   Dense timeline uses `denseTimelineUnion` + `denseStage` (a richer enrichment layer).
   Discrete timeline uses only `buildStagedTimeline.union`. However, `buildStagedTimeline`
   itself still runs `oddStage` → `processDensity` at every even-numbered Nat step.

3. **Option A (quotient collapse) is infeasible.** `DenseTimeline.lean` lines 551–591
   documents the non-constructive Lindenbaum obstacle — the G-formula content of
   density intermediates cannot be controlled. The same obstruction defeats Option A.

4. **Option C (bypass staged construction) reduces to Option B.** DF under reflexive
   semantics is trivially valid on all frames and provides no frame condition constraint.
   The "constructive variant" of Option C is exactly: remove DN-using stages from the
   construction — i.e., Option B.

5. **Task 978 does NOT unblock 974.** The 974 sorries require order-theoretic proofs
   (`succFn a > a`, finite intervals). Typeclasses don't provide these facts. 978 operates
   at the axiom-organization level; 974 needs a finiteness argument about staged construction.

6. **Task 973 is effectively complete.** Code inspection finds no code-level sorries in
   `ConstructiveFragment.lean` (grep returns empty). The implementations at lines 585–649
   are complete. What remains is build verification and status update only.

7. **977 Phases 1–5 are fully executable without 974.** Phase 6 (discrete completeness)
   needs 974 for a full proof but a skeleton statement can be written now.

---

## Detailed Analysis

### The Blocker Structure

```
DiscreteTimelineElem = { p : StagedPoint // p ∈ buildStagedTimeline.union }

buildStagedTimeline
  stagedBuild n+1:
    if n % 2 = 0: evenStage   -- F/P witnesses (fine for discrete)
    else:         oddStage    -- processDensity ← density_of_canonicalR ← Axiom.density (DN)
```

For a discrete MCS (where DN may not be derivable), `density_of_canonicalR` cannot be
constructively satisfied. But since `processDensity` → `densityWitnessForPoint` is
`noncomputable` (uses `Classical.choose`), Lean type-checks it regardless. The witnesses
produced are arbitrary MCSs with no density guarantee — but they exist in the construction,
and their presence defeats `discrete_timeline_lt_succFn` (the GLB of `Set.Ioi a` cannot
be proven strictly greater than `a` if unknown intermediates may lie between).

**Secondary dependency**: `staged_timeline_has_future` uses `iterated_future_in_mcs` to find
an encoding-sufficient stage. This uses `density_F_to_FF` (DN axiom) to generate arbitrarily
nested `F^n(¬⊥)` formulas. Without DN, a different encoding sufficiency argument is needed.

### Option A: Quotient Collapse — INFEASIBLE

Density intermediates `W` satisfy `CanonicalR M W` and `CanonicalR W N`. For them to
"collapse" in the Antisymmetrization quotient, we need `CanonicalR W M` or `CanonicalR N W`.
The documented obstruction (`DenseTimeline.lean` lines 551–591): the Lindenbaum extension is
non-constructive, and the G-formula content of `W` cannot be controlled. This makes the
collapse claim unprovable. **Reject.**

### Option B: Discrete Staged Construction — HIGH FEASIBILITY ✓

Define `discreteStagedBuild` by skipping odd stages:

```lean
noncomputable def discreteStagedBuild : Nat → Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := discreteStagedBuild n
    if n % 2 = 0 then
      evenStage prev (n / 2) (n + 1)   -- process F/P obligations (unchanged)
    else
      prev                              -- SKIP: no density insertion
```

**Also required**: A DN-free `discrete_staged_has_future` proof using MCS richness
(every MCS contains infinitely many formulas, so encoding-sufficient formulas exist)
instead of iterated F-nesting.

**Key mathematical claim**: In `discreteStagedBuild`, for any `a ≤ b` in the quotient,
`[a, b]` is finite. Argument: without odd stages, the only new MCSs added are F/P witnesses.
Each witness is between existing points (by linearity). The construction produces a
well-ordered tree of witnesses bounded by formula encodings. This gives `LocallyFiniteOrder`,
from which `succFn a > a`, `predFn a < a`, and `IsSuccArchimedean` all follow.

**Estimated effort**: 3–4 hours
- Define `discreteStagedBuild` and verify StagedTimeline structure: 1h
- DN-free `has_future`/`has_past` proofs: 1h
- Prove local finiteness → discreteness sorries: 1.5h

**Main risk (medium)**: The "finite intervals" proof for `discreteStagedBuild` requires
showing F/P witnesses don't generate infinite strictly-between chains. This is sound
mathematically but the Lean formalization may require careful Finset arithmetic.

### Option C: Bypass Staged Construction — REDUCES TO OPTION B

DF under reflexive semantics is trivially valid (`s = t` as witness). No frame condition
constraint can be derived from DF validity. The "constructive bypass" — removing DN-using
stages from the construction — is precisely Option B.

---

## Synthesis: Conflicts and Gaps

### Conflicts Between Teammates
- **None significant.** All three teammates converge on Option B as the fix and on
  results-first as the strategy.

### Gaps Identified
- **How does `isDiscreteCompatible` constrain MCS membership?** Teammate B identifies
  that `theorem_in_mcs` may apply DN even for "discrete" MCSs if DN is in the base TM
  proof system. This needs clarification during implementation: is the root MCS provably
  DN-free, or does `DiscreteTimeline.lean` assume a restricted proof system?

- **CantorPrereqs density dependency for NoMaxOrder**: The existing sorry-free NoMaxOrder
  proof in `DiscreteTimeline.lean` uses `staged_timeline_has_future` which invokes DN via
  `density_F_to_FF`. Under Option B, these proofs must be updated to use the DN-free variant.

---

## Recommendations

### Primary: Results-First with Option B

**Do not refactor first.** Continue results-first strategy. Resolve 974 via:

1. Define `discreteStagedBuild` (skip odd stages) in `StagedExecution.lean` or new file
2. Prove `StagedTimeline` structure lemmas for `discreteStagedBuild`
3. Prove DN-free `discrete_staged_has_future` via MCS richness (encoding sufficiency)
4. Redefine `DiscreteTimelineElem` to use `buildDiscreteStagedTimeline`
5. Update NoMaxOrder/NoMinOrder proofs to use DN-free `has_future`/`has_past`
6. Prove local finiteness of intervals in `discreteStagedBuild`
7. Derive the 3 remaining sorries from `LocallyFiniteOrder`

### Recommended Execution Order

```
Step 1 (immediate): Verify task 973 builds, mark complete
  → lake build target; update state.json 973 -> completed

Step 2 (parallel tracks):
  Track A: 977 Phases 1–3 (docs, soundness, FrameClass) — independent of 974
  Track B: 974 Option B — discrete staged construction

Step 3 (after Track B): 977 Phase 4 (dense completeness wiring)
Step 4 (after Phase 4): 977 Phase 5 (base completeness statement)
Step 5 (after 974 + Phase 5): 977 Phase 6 (discrete completeness — now unblocked)
Step 6 (after Phase 6): 977 Phase 7 (logic variants summary)
Step 7 (after 977 complete): 978 (typeclass architecture refactor)
```

**Total estimated active work**: 14–20 hours

### If Option B's Key Challenge Stalls (contingency)

If proving finite intervals for `discreteStagedBuild` is harder than expected, consider
temporarily introducing an axiom:
```lean
axiom discrete_staged_finite_intervals :
    ∀ (a b : DiscreteTimelineQuot ...), a < b → Finite (Set.Ioo a b)
```
This allows completing the pipeline (SuccOrder → PredOrder → IsSuccArchimedean → orderIsoIntOf...)
while deferring the full proof. This is analogous to how `canonicalR_irreflexive` was
initially axiomatized and later proven. Mark it as technical debt requiring structural proof.

### Decision Points

1. **After Step 1** (973 build): If 973 does NOT build, resolve gap before 977 Phase 4
2. **After Track B attempt** (discrete build): If > 4h, switch to contingency axiom
3. **After 977 Phase 4** (dense completeness): If domain mismatch intractable, mark BLOCKED
   and deliver Phases 1–3 + 5 as partial
4. **Before starting 978**: Confirm 977 is fully complete

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Architecture (refactor-first?) | completed | high | Confirmed Option B; identified Classical.choose mechanism |
| B | Concrete resolution paths | completed | high | Identified second DN dependency in staged_has_future; infeasibility proof for Option A |
| C | Dependencies / roadmap | completed | high | 973 effectively complete; 977 Phases 1–5 unblocked; 978 cannot help 974 |

### Conflicts Found: 0
### Gaps Identified: 2 (isDiscreteCompatible scope; NoMaxOrder DN dependency)

---

## References

- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` — `buildStagedTimeline`, `processDensity`, `oddStage`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` — 3 sorry locations, NoMaxOrder proofs
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` — `iterated_future_in_mcs`, `density_F_to_FF`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` — lines 551–591: Option A obstruction
- `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean` — `density_of_canonicalR`
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` — lines 585–649: 973 complete
- `specs/974_.../reports/research-003-teammate-a-findings.md`
- `specs/974_.../reports/research-003-teammate-b-findings.md`
- `specs/974_.../reports/research-003-teammate-c-findings.md`
