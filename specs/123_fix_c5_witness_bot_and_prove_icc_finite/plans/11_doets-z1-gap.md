# Implementation Plan: Doets/Z1 Gap Elimination for IsSuccArchimedean

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-a-irr-rule.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-b-z1-proofs.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-c-construction-dynamics.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-d-online-search.md
  - All prior reports from rounds 04-12 (integrated in plans v4-v10)
- **Artifacts**: plans/11_doets-z1-gap.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version (v11):**
- `13_team-research.md` (newly integrated in v11)
- `13_teammate-a-irr-rule.md` (newly integrated in v11)
- `13_teammate-b-z1-proofs.md` (newly integrated in v11)
- `13_teammate-c-construction-dynamics.md` (newly integrated in v11)
- `13_teammate-d-online-search.md` (newly integrated in v11)
- All reports from v4-v10 preserved

### Why Plan v11 Supersedes Plan v10

Plan v10 pursued a stage induction approach (`succ_reaches_dom_N`) with case analysis on boundary points. Implementation revealed that the boundary cases (above-max, below-min) are intractable: the stage induction cannot determine whether `succ(max_N_sub)` enters at stage N+1 or a later stage, blocking the `dom_new_unique` argument.

The current code state has:
- `succ_reaches_dom_N` with 2 sorry sites (lines 1295, 1448) -- boundary cases, no longer on critical path
- `succ_cofinal` with 1 sorry (line 1645) -- the `L <= pred(b).val` case
- `limitDomSubtype_isSuccArchimedean` calls `succ_cofinal + succ_orbit_convex` (not `succ_reaches_dom_N`)

Round 13 research (4 teammates) identified the correct gap-elimination mechanism: **Doets Claim 10 via the modified Lob axiom Z1**, derivable from Prior-UZ which is already in the axiom system. This is the first approach that uses the AXIOMS directly rather than construction dynamics. Prior-UZ forces non-constant models, guaranteeing a discriminating formula between orbit and above-orbit points. Z1 forces bounded definable sets to have maxima, which contradicts the gap-at-L scenario.

### Key Mathematical Insight

The sorry at line 1645 is in `succ_cofinal` for the case where the real-valued limit L of the succ-iterate sequence satisfies `L <= pred(b).val`. In this scenario, the succ-chain from `a` converges to L from below, and the pred-chain from `b` converges to L from above, with no limit_dom point at L -- an omega + omega* gap.

Doets Claim 10 (pp. 91-92) shows this is impossible when Z1 holds semantically: every bounded definable set must have a maximum. The set of limit_dom points where a discriminating formula phi holds is bounded above but has no maximum in the gap scenario, contradicting Z1.

## Overview

Close the remaining sorry in `succ_cofinal` (line 1645, the `L <= pred(b).val` case) by proving that the gap-at-L scenario contradicts the Z1 axiom (`G(Gp -> p) -> (FGp -> Gp)`), which is derivable from Prior-UZ. The approach adds a new proof path that uses axiom-level reasoning (Z1 semantic validity via `theorem_in_mcs` + truth lemma) rather than construction-specific dynamics.

**Strategy**: In the sorry branch, we have an increasing succ-chain `s^[n](a)` bounded by `pred(b)`, and a decreasing pred-chain `pred^[k](b)` bounded below, with no limit_dom at their common real limit L. We show this gap is impossible by:
1. Deriving Z1 from Prior-UZ in the proof system (new derivation)
2. Establishing Z1 holds semantically at all limit_dom points (via `theorem_in_mcs` + truth lemma)
3. Finding a discriminating formula phi that holds on one side of the gap but not the other (guaranteed by Prior-UZ forcing non-constant models)
4. Showing the phi-set is bounded with no maximum, contradicting Z1

**Definition of done**: `succ_cofinal` sorry-free. `limitDomSubtype_isSuccArchimedean` sorry-free. `dd_countermodel_chronicle_discrete` sorry-free. Full `lake build` passes.

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1645 in `succ_cofinal`
- Derive Z1 from Prior-UZ in the proof system
- Establish Z1 semantic validity in the limit model
- Make `limitDomSubtype_isSuccArchimedean` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Modifying Phase 1 (already [COMPLETED] -- imports and order_succ/pred equality)
- Fixing the 2 sorry sites in `succ_reaches_dom_N` (lines 1295, 1448) -- no longer on critical path since `limitDomSubtype_isSuccArchimedean` uses `succ_cofinal` instead
- Proving LocallyFiniteOrder
- Solving the nondense/mixed case stubs
- Modifying the existing convergence framework in `succ_cofinal` (only closing the sorry branch)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Z1 derivation from Prior-UZ is complex | M | M | Standard derivation in temporal logic literature (Reynolds 1994, Doets 1987). May need intermediate lemmas (G-transitivity, Until-to-F properties). Factor into helper lemmas. |
| Finding the discriminating formula phi | H | M | Prior-UZ forces non-constant models: if phi holds everywhere, F(phi) holds, U(phi, neg phi) requires a point with neg phi -- contradiction. So for every phi, some point has neg phi. Use classical logic (`Classical.choice`) to extract phi from the symmetric difference of orbit vs above-orbit MCS labels. |
| Truth lemma for G/F may not be directly available | M | L | The truth lemma infrastructure exists (`RestrictedParametricTruthLemma`). Need to verify that G and F connectives have truth lemma components. If not directly available, derive from U/S truth lemma. |
| The "bounded with no maximum" argument is subtle | M | M | Need to show: (a) phi-set is bounded above (by some above-orbit point where neg phi holds), (b) phi-set has no maximum (every phi-orbit-point has a successor phi-orbit-point strictly below the gap). Both follow from the gap topology. |
| Proof size exceeds budget | M | L | The mathematical argument is clean (~10 lines of math). Lean formalization overhead is 10-20x. Target 100-200 lines total. Factor large case analyses into separate lemmas. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Z1 Derivation and Gap Elimination [NOT STARTED]

**Goal**: Close the sorry at line 1645 in `succ_cofinal` by proving the gap-at-L scenario contradicts Z1.

This phase has four sub-steps that build on each other.

#### Step 2a: Derive Z1 from Prior-UZ (~30-60 lines)

**Location**: New file `Theories/Bimodal/Theorems/Z1Derivation.lean` or inline in a new section of `ChronicleToCountermodel.lean` before `succ_cofinal`.

**Statement**:
```lean
/-- Z1 (modified Lob axiom): G(Gp -> p) -> (FGp -> Gp).
Derivable from Prior-UZ + basic temporal logic axioms. -/
theorem z1_derivable (φ : Formula) :
    DerivationTree [] (Formula.imp
      (Formula.all_future (Formula.imp (Formula.all_future φ) φ))
      (Formula.imp (Formula.some_future (Formula.all_future φ)) (Formula.all_future φ)))
```

**Derivation sketch**: The standard derivation uses Prior-UZ applied to `G(phi)`:
1. From `F(G(phi))`, Prior-UZ gives `U(G(phi), neg(G(phi)))`
2. `U(G(phi), neg(G(phi)))` provides a witness y > x with `neg(G(phi))` at y and `G(phi)` at all z in (x, y)
3. But `G(G(phi) -> phi)` at x means: for all z > x, `G(phi) -> phi` at z
4. At y: `neg(G(phi))` holds. At y-1 (predecessor): `G(phi)` holds (from step 2). So `phi` at y (from step 3 applied to y). And `G(phi) -> phi` at y gives `phi` at y.
5. The key: since `G(phi)` holds at all points between x and y, and `G(phi) -> phi` holds at all points > x (from `G(G(phi) -> phi)` at x), we get `phi` at all points > x.

Actually, the standard derivation is more subtle. An alternative approach: derive Z1 as a SEMANTIC consequence rather than a syntactic derivation. Since Prior-UZ is valid on the limit model (by soundness), and Z1 follows semantically from Prior-UZ on discrete linear orders, we can establish Z1 validity directly.

**Alternative (preferred if syntactic derivation is complex)**: Instead of deriving Z1 syntactically, prove Z1 holds semantically on the limit model directly, using the `prior_UZ_is_valid` theorem from `SoundnessLemmas.lean` (line 2338). This avoids building a `DerivationTree` and instead works at the semantic level.

```lean
/-- Z1 holds semantically at every limit_dom point. -/
theorem z1_semantic_validity (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (x : LimitDomSubtype A h_mcs) (φ : Formula)
    (h_G_imp : ∀ y, x < y → (φ.all_future ∈ limit_f A h_mcs y.val → φ ∈ limit_f A h_mcs y.val))
    (h_FG : ∃ y, x < y ∧ φ.all_future ∈ limit_f A h_mcs y.val) :
    φ.all_future ∈ limit_f A h_mcs x.val
```

**Tasks:**
- [ ] Investigate whether syntactic Z1 derivation or semantic Z1 validity is more tractable
- [ ] If syntactic: build `DerivationTree` for Z1 from Prior-UZ
- [ ] If semantic: prove Z1 holds directly on the limit model using `prior_UZ_is_valid` and the succ/pred structure
- [ ] Verify with `lean_goal` and `lean_verify`

**Timing**: 1-2 hours
**Depends on**: Phase 1

#### Step 2b: Establish Non-Constant MCS Labels (~20-40 lines)

**Location**: Before or within the sorry branch in `succ_cofinal`.

**Statement**: In the gap-at-L scenario, there exists a formula phi such that phi holds at some orbit points but neg(phi) holds at some above-orbit points (or vice versa).

**Proof sketch**:
1. Assume for contradiction that all limit_dom points in a neighborhood of L have the same MCS restricted to Sub(A) (for the relevant closure set A)
2. Then for every formula psi in Sub(A): psi is in limit_f(x) iff psi is in limit_f(y) for all x, y near L
3. In particular, for any psi: F(psi) holds at every point near L (since there are infinitely many future points with psi)
4. Prior-UZ at any such point gives U(psi, neg psi), requiring a nearest future point with neg psi
5. But if psi holds at ALL points near L, this nearest neg-psi point is far away, creating a "constant interval" that Prior-UZ forbids
6. Formally: pick any atom p in Sub(A). If p holds at all points near L, then F(p) holds and Prior-UZ gives U(p, neg p), requiring neg p somewhere after. But between the current point and the neg-p point, p holds everywhere -- including at the gap. Since no domain point is AT L, there must be a transition from p to neg-p at some definite point, not at the gap. This gives a specific formula that changes value near L.

**Alternative (simpler)**: Use the fact that limit_f labels on the orbit side and above-orbit side come from different stages of the omega-chain construction. The MCS at orbit points are determined by the root MCS A and forward-chain extensions, while above-orbit MCS labels are determined by backward-chain extensions. These need not agree on all formulas. Show that if they did agree on all formulas, the gap would be "invisible" to the logic, contradicting the existence of distinct limit_dom points on both sides.

**Tasks:**
- [ ] Prove existence of discriminating formula phi in the gap scenario
- [ ] Handle the classical logic extraction (use `Classical.choice` or `Decidable` instances)
- [ ] Verify with `lean_goal`

**Timing**: 1 hour
**Depends on**: Step 2a

#### Step 2c: Apply Doets Claim 10 to Derive Contradiction (~40-80 lines)

**Location**: Within the sorry branch of `succ_cofinal` (replacing the `sorry` at line 1645).

**Core argument** (formalized from Doets pp. 91-92):

Given the gap-at-L scenario:
- Orbit points `s^[n](a)` converge to L from below
- Pred-chain points `pred^[k](b)` converge to L from above
- No limit_dom point at L
- Discriminating formula phi: phi in limit_f(orbit points), neg phi in limit_f(above-orbit points near gap) (or vice versa)

Without loss of generality, assume phi holds at orbit points and neg phi holds at above-orbit points near the gap. Then:

1. **phi-set is bounded above**: The set S = {x in limit_dom : phi in limit_f(x)} intersected with [a.val, b.val] contains all orbit points s^[n](a) but excludes above-orbit points near the gap. S is bounded above by some above-orbit point.

2. **phi-set has no maximum in [a.val, b.val]**: For any orbit point s^[n](a) in S, s^[n+1](a) is also in S (since all orbit points have phi). And s^[n+1](a) > s^[n](a). So S has no maximum -- every element has a larger element in S.

3. **Z1 contradiction**: At orbit point m = s^[n](a):
   - `F(G(neg phi))` holds at m: above-orbit points near the gap eventually have `G(neg phi)` (since all of them and their successors have neg phi beyond the gap)
   - `G(G(neg phi) -> neg phi)` holds at m: for any future point y, if `G(neg phi)` at y then `neg phi` at y (this is just the T-axiom for G, or derivable from G-transitivity: G(neg phi) implies neg phi at the next point)
   - Z1 with `neg phi`: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))`. Both antecedents hold. So `G(neg phi)` at m.
   - But m is an orbit point with phi in limit_f(m). `G(neg phi)` at m means neg phi at all future points. But s^[n+1](a) > m is a future orbit point with phi. Contradiction.

**Tasks:**
- [ ] Set up the gap-at-L scenario with the discriminating formula phi
- [ ] Prove that the phi-set is bounded above with no maximum
- [ ] Prove `F(G(neg phi))` at orbit points (from above-orbit structure)
- [ ] Prove `G(G(neg phi) -> neg phi)` at orbit points (from G-transitivity / truth lemma)
- [ ] Apply Z1 to get `G(neg phi)` at orbit point m
- [ ] Derive contradiction with phi at future orbit point
- [ ] Replace the `sorry` at line 1645

**Timing**: 1.5-2 hours
**Depends on**: Steps 2a, 2b

#### Step 2d: Wire up and Verify (~10-20 lines)

**Location**: Verify `succ_cofinal` is sorry-free, which makes `limitDomSubtype_isSuccArchimedean` sorry-free.

**Tasks:**
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry

**Timing**: 0.5 hour
**Depends on**: Step 2c

---

### Phase 3: Verification and Cleanup [NOT STARTED]

**Goal**: Verify compilation and sorry elimination downstream. Clean up dead code if appropriate.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry confirms only nondense/mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Optionally: remove `succ_reaches_dom_N` and `limit_dom_points_are_succ_iterates` if they are dead code (not called from any non-sorry path). Or leave them with a comment that they are superseded.

**Timing**: 0.5-1 hour
**Depends on**: 2

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/11_doets-z1-gap.md` (this file)
- **Modified/created files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close sorry in `succ_cofinal`, add Z1 semantic validity lemma
  - Optionally: `Theories/Bimodal/Theorems/Z1Derivation.lean` -- Z1 syntactic derivation from Prior-UZ (if the syntactic approach is chosen)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/11_doets-z1-gap-summary.md` (after implementation)

## Rollback/Contingency

Theorem statements unchanged. Rollback: `git checkout` the modified files.

If the Doets/Z1 approach proves intractable:

1. **Fallback A: Direct gap-at-L elimination via succ_cofinal infinite descent** (50% confidence, 50-100 lines): In the `L <= pred(b).val` case, show that the pred-chain `pred^[k](b)` eventually produces a point below L. Since `pred^[k](b).val` is strictly decreasing and all values are rationals, the sequence descends through rationals. If it stays above L, the infimum of `pred^[k](b).val` in R is some R_inf >= L. Show that R_inf is a limit_dom point (by the "first limit_dom >= R_inf" argument), giving a point between the succ-chain and pred-chain, reducing to a smaller gap.

2. **Fallback B: Stage induction boundary cases** (40% confidence, 100-200 lines): Return to the `succ_reaches_dom_N` approach from plan v10. Close the boundary sorry sites (lines 1295, 1448) using the bot-guard adjacency argument from report 10. Then rewire `limitDomSubtype_isSuccArchimedean` to use `succ_reaches_dom_N` instead of `succ_cofinal`.

3. **Last resort**: Leave sorry with detailed documentation of the gap.

### Implementation Guidance for the Agent

**Preferred approach order**: Try semantic Z1 validity first (Step 2a alternative). If semantic Z1 is hard to establish directly, try the syntactic derivation. The semantic approach avoids building `DerivationTree` objects and works directly with the truth lemma.

**Key codebase APIs**:
- `theorem_in_mcs` (MaximalConsistent.lean:476): derivable formulas are in every MCS
- `limit_c0` (ChronicleConstruction.lean:590): `limit_f(x)` is SetMaximalConsistent for every x in limit_dom
- `prior_UZ_is_valid` (SoundnessLemmas.lean:2338): Prior-UZ is valid on discrete orders
- `Axiom.prior_UZ` (Axioms.lean:377): `F(phi) -> U(phi, neg phi)`
- `succ_orbit_convex` (ChronicleToCountermodel.lean:1112): orbit passes through intermediates
- `limitDomSubtype_succ_lt` (ChronicleToCountermodel.lean:1718): `a < succ(a)`
- `limitDomSubtype_pred_lt` (ChronicleToCountermodel.lean): `pred(b) < b`
- `limitDomSubtype_succ_pred` (ChronicleToCountermodel.lean): `succ(pred(b)) = b`

**Where to insert code**: The sorry is at line 1645 in the `else` branch of `succ_cofinal`. The branch has `h_case : L <= (pb.val : R)` in scope, plus all the convergence setup. Insert the Z1-based contradiction argument here.

**Classical logic**: Use `Classical.em`, `Classical.choice`, or `by_contra` freely. The codebase already uses classical reasoning throughout.
