# Research Report: Sub-Formula Finiteness and the Discriminating Formula Problem

Task: 123 | Date: 2026-05-13 | Round: 12

## Executive Summary

This report investigates whether sub-formula closure finiteness can resolve the discriminating formula problem in the `succ_cofinal` gap elimination (ChronicleToCountermodel.lean:1883). The key findings are:

1. **Sub-formula closure infrastructure exists and is substantial.** The codebase has `subformulaClosure : Formula -> Finset Formula` (Syntax/SubformulaClosure.lean), `SubformulaClosure` with G/H enrichment and negation pairing (Quasimodel/SubformulaClosure.lean), `closureWithNeg` for negation-extended closures, and `sigma_signature_formulas` for projecting MCS to finite Sigma-components (Quasimodel/HintikkaPoint.lean).

2. **MCS labels in the chronicle are over ALL formulas, not a finite closure.** `limit_f : Rat -> Set Formula` is a full MCS (`SetMaximalConsistent`) over the entire formula language. This is the standard Lindenbaum construction. The MCS is determined by `omega_chain_val(h.choose).f x` for the first stage where `x` enters the domain.

3. **Sub-formula finiteness does NOT directly solve the discriminating formula problem.** While restricting MCS labels to `SubformulaClosure(target)` makes the label space finite (at most `2^|SubformulaClosure(target)|` possible restrictions), the fundamental obstacle remains: on a discrete linear order, the restricted labels of orbit points and above-orbit points may be IDENTICAL for every formula in the closure. Prior-UZ forces non-constancy globally but the vacuous-guard problem (Section 4.3) means the forcing gives no discriminating power across the specific gap.

4. **Z1 is already an axiom** (Axiom.z1, added in plan v15). The soundness proof `z1_is_valid` in SoundnessLemmas.lean uses `IsSuccArchimedean`, which creates a potential circularity. However, `z1_in_mcs` places Z1 in every MCS via `theorem_in_mcs` (syntactic, no circularity). The obstacle is using Z1 SEMANTICALLY to eliminate the gap without already having `IsSuccArchimedean`.

5. **The correct path forward is the Doets Claim 10 argument using Z1 in every MCS, combined with a discriminating formula from the omega-chain construction dynamics** -- not from sub-formula finiteness alone.

---

## 1. Sub-Formula Closure Infrastructure in the Codebase

### 1.1 Syntax-Level Infrastructure

**File: `Theories/Bimodal/Syntax/Subformulas.lean`**
- `Formula.subformulas : Formula -> List Formula` -- all subformulas including the formula itself
- `Formula.self_mem_subformulas` -- a formula is in its own subformula list
- `Formula.subformulas_trans` -- transitivity of the subformula relation
- Membership lemmas for each constructor (imp, box, all_past, all_future, untl, snce)

**File: `Theories/Bimodal/Syntax/SubformulaClosure.lean`**
- `subformulaClosure : Formula -> Finset Formula` -- converts `List`-based subformulas to `Finset`
- `closureWithNeg : Formula -> Finset Formula` -- closure union with `Finset.image Formula.neg`
- `subformulaClosureCard`, `closureWithNegCard` -- cardinality functions
- `diamondSubformulas` -- filter for diamond formulas (used in BFMCS saturation)
- `extractDiamondInner`, `IsDiamondFormula` -- diamond formula detection

Key properties:
- `self_mem_subformulaClosure phi : phi in subformulaClosure phi`
- `subformulaClosure_subset_closureWithNeg` -- closure is subset of negation-extended closure
- `neg_mem_closureWithNeg` -- negation of closure member is in closureWithNeg
- `DecidablePred (. in subformulaClosure phi)` and `DecidablePred (. in closureWithNeg phi)`

### 1.2 Quasimodel-Level Infrastructure

**File: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean`**
- `subformulas : Formula -> Finset Formula` -- standalone Finset-based version
- `SubformulaClosure : Formula -> Finset Formula` -- full Sigma-closure with G/H enrichment and negation pairing: `ghEnrichment(subformulas target) union image neg`
- `ghEnrichment : Finset Formula -> Finset Formula` -- adds `G(f)` and `H(f)` for each `f`

**File: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean`**
- `sigma_signature_formulas : BXPoint -> Finset Formula -> Finset Formula` -- projects MCS to Sigma-component via `Sigma.filter (fun f => f in w.formulas)`
- `sigma_signature_consistent` -- the signature is locally consistent (no formula and its negation)
- `sigma_signature_maximal` -- the signature is locally maximal

**File: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean`**
- `enrichedClosure : Formula -> Finset Formula` -- Fisher-Ladner enriched closure
- Includes G-neg-bigconj and H-neg-bigconj formulas for every subset of the base closure
- `enrichedClosure_neg_closed_on_core` -- negation closure property

### 1.3 Mathlib Support for Finiteness Arguments

**Relevant Mathlib lemmas (verified available)**:
- `Finset.powerset : Finset alpha -> Finset (Finset alpha)` -- subsets of a Finset form a Finset
- `Finite.exists_ne_map_eq_of_infinite` -- pigeonhole: infinite domain to finite codomain implies collision
- `Set.Infinite.exists_ne_map_eq_of_mapsTo` -- pigeonhole for maps between sets
- `Set.Finite.exists_lt_map_eq_of_forall_mem` -- ordered pigeonhole: with `LinearOrder` and `Infinite`, gives `a < b` with `f(a) = f(b)` (from `Mathlib.Order.Preorder.Finite`)

---

## 2. How MCS Labels Are Constructed in the Chronicle

### 2.1 The Limit Construction

The limit chronicle is built from the omega-chain construction (ChronicleConstruction.lean:235-568):

```
limit_dom A h_mcs : Set Rat
  = { x | exists n, x in (omega_chain_val A h_mcs n).dom }

limit_f A h_mcs : Rat -> Set Formula
  = fun x => if (exists n, x in dom(n)) then (omega_chain_val h.choose).f x else empty
```

**Critical fact**: `limit_f A h_mcs x : Set Formula` is a FULL maximal consistent set over all formulas, proved by `limit_c0`:

```lean
theorem limit_c0 (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x in limit_dom A h_mcs) :
    SetMaximalConsistent (limit_f A h_mcs x)
```

### 2.2 MCS Label Type

Each `limit_f(x)` is a `Set Formula` satisfying `SetMaximalConsistent`. This is an INFINITE set (every MCS over a countable language is infinite -- it contains either `phi` or `phi.neg` for every formula `phi`). The set of all possible MCS labels is uncountably many in general (2^aleph_0 subsets, though only countably many are MCS).

### 2.3 No Finite Restriction in the Chronicle

The chronicle does NOT restrict MCS labels to any finite sub-formula closure. The `SubformulaClosure` infrastructure is used in the quasimodel construction (for the FMP and decidability) but NOT in the Burgess omega-chain construction that produces the limit model.

---

## 3. The Pigeonhole Argument: What Works and What Does Not

### 3.1 What Works: Restricted Label Collision

For any fixed target formula `target`, define:
```
restricted_label(x) := limit_f(x) ∩ SubformulaClosure(target)
```
This takes values in `Finset.powerset (SubformulaClosure target)`, which has at most `2^|SubformulaClosure(target)|` elements. By pigeonhole (`Set.Finite.exists_lt_map_eq_of_forall_mem`), for any infinite set of limit_dom points, two must have the same restricted label.

**Available infrastructure for this**:
- `subformulaClosure target : Finset Formula` (already defined)
- `Finset.powerset` gives `Finset (Finset Formula)` of all subsets
- Pigeonhole: if `f : N -> Finset.powerset S` and `S` is finite, then `exists n1 < n2, f(n1) = f(n2)`

### 3.2 What Does NOT Work: Discriminating Formula from Restricted Collision

The pigeonhole collision gives: there exist orbit indices `n1 < n2` such that `limit_f(s^[n1](a))` and `limit_f(s^[n2](a))` agree on every formula in `SubformulaClosure(target)`. This means the orbit labels are REPETITIVE when restricted to any fixed finite closure.

But we need the OPPOSITE: a formula that DISTINGUISHES orbit from above-orbit points. The restricted collision shows sameness within the orbit, not difference between orbit and above-orbit.

### 3.3 What Would Work: Cross-Gap Disagreement

To find a discriminating formula, we would need to show: for some formula `phi`:
- `phi in limit_f(m)` for some orbit point `m`
- `phi.neg in limit_f(c)` for some pred-chain point `c`

Sub-formula finiteness could help if we could show: the restricted labels on the orbit side MUST differ from the restricted labels on the pred-chain side. But this requires an argument that the gap structure FORCES a label change, which is exactly the unsolved problem.

### 3.4 The Constant-MCS Obstacle

As analyzed in reports 14 and 15, the fundamental obstacle is the constant-MCS case: all limit_dom points might have the SAME MCS label. In this scenario:
- Every formula `phi` is either in ALL limit_f(x) or in NO limit_f(x)
- No formula distinguishes orbit from above-orbit points
- Prior-UZ at any point gives `U(phi, neg phi)`, but the Until is vacuously satisfied by discrete adjacency (no intermediate points between succ-adjacent points)
- Z1 at any point gives `G(G(phi) -> phi) -> (FG(phi) -> G(phi))`, but with constant labels, either `G(phi)` holds everywhere (if phi is in every MCS, hence G(phi) by backward_G) or nowhere

Sub-formula finiteness does not resolve this obstacle because it concerns the NUMBER of distinct labels, not whether labels change across a gap.

---

## 4. Analysis of Key Arguments

### 4.1 Z1 in Every MCS (No Circularity)

Z1 is an axiom (`Axiom.z1`), so `z1_in_mcs` places it in every MCS via `theorem_in_mcs` + `z1_derivation`. This is purely syntactic and does NOT require `IsSuccArchimedean`:

```lean
private def z1_derivation (phi : Formula) :
    DerivationTree [] (z1_formula phi) :=
  DerivationTree.axiom [] _ (Axiom.z1 phi)

private theorem z1_in_mcs (phi : Formula) {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) :
    z1_formula phi in S :=
  theorem_in_mcs h_mcs (z1_derivation phi)
```

The circularity concern was with the SOUNDNESS proof (`z1_is_valid` uses `IsSuccArchimedean`), but this is only needed for soundness of the overall system, not for placing Z1 in MCS for the completeness direction.

### 4.2 The Doets Claim 10 Argument with Z1

Doets Claim 10 (thesis pp. 91-92): if `phi^S = {x | phi in limit_f(x)}` is non-empty and bounded above, then `phi^S` has a maximum.

The proof uses Z1 with `neg phi`:
1. Choose `m` below the phi-set. `F(phi)` holds at m (backward_F gives this).
2. `FG(neg phi)` holds at m (bounded above means neg phi eventually always).
3. Since `neg G(neg phi)` at m (equivalently `F(phi)` at m, from step 1):
   - Z1 instance: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))`
   - `FG(neg phi)` holds (step 2) but `G(neg phi)` fails (step 1 contradicts).
   - So the antecedent `G(G(neg phi) -> neg phi)` must fail at m.
   - Therefore: `F(neg(G(neg phi) -> neg phi))` at m, i.e., `F(G(neg phi) AND phi)` at m.
4. By `limit_F_resolution`: exists `k > m` with `G(neg phi) AND phi` at k.
5. `k` is the maximum: `phi` at k, and `G(neg phi)` means `neg phi` at all points above k.

**Status of each step in the codebase**:
- Step 1: `backward_F` is proved (line 1752)
- Step 2: Requires showing `FG(neg phi)` at orbit points -- needs the "bounded above" hypothesis formalized
- Step 3: Uses `z1_in_mcs` + MCS implication properties (available)
- Step 4: Uses `limit_F_resolution` (available, line 689)
- Step 5: Uses `limit_forward_G` (available, line 1035) to verify maximality

The argument is mathematically sound and all infrastructure exists EXCEPT: (a) establishing "bounded above" (i.e., `neg phi` at all points above some bound), and (b) having a discriminating formula `phi` in the first place.

### 4.3 The Vacuous-Guard Problem with Prior-UZ

In the gap-at-L scenario with discrete order: orbit points `s^[n](a)` are succ-adjacent (no limit_dom between consecutive orbit points). If `phi in limit_f(s^[n](a))` for all n, then Prior-UZ gives `U(phi, neg phi) in limit_f(s^[n](a))`. The Until witness `y` has `phi at y` and `neg phi` at all intermediate points. But by discrete adjacency, the immediate successor `s^[n+1](a)` is the nearest limit_dom point above `s^[n](a)`. If `y = s^[n+1](a)`, the guard interval `(s^[n](a), y)` contains NO limit_dom points, so the guard is vacuously satisfied regardless of what `neg phi` means. The Until is trivially satisfied even if `phi` holds everywhere.

This means Prior-UZ gives NO information about whether labels change across the gap. The formula `phi` could be constant across all limit_dom points and all Prior-UZ instances would be vacuously satisfied.

### 4.4 Where Sub-Formula Finiteness Could Still Help

Sub-formula finiteness is relevant in one scenario: if we could show that the omega-chain construction MUST assign different MCS labels to points on opposite sides of the gap (using construction dynamics rather than axiom-level reasoning), then restricting to a finite closure would give a concrete formula witnessing the difference.

Specifically: the omega-chain processes counterexamples in a dovetailed enumeration. Each C4/C5 counterexample involves specific formulas. If the construction places a C4 witness (guard-negation point) between orbit and pred-chain regions, the witness point has `neg gamma` for some guard formula `gamma`, while nearby orbit points have `gamma`. This `gamma` would be the discriminating formula.

**But formalizing this requires**: showing that the omega-chain construction places at least one C4 witness in the gap region. This is the "construction dynamics" approach from report 15 Section 6.4.

---

## 5. The Restricted-Label Approach: Detailed Feasibility

### 5.1 Definition of Restricted Label

For a fixed formula `target` (e.g., the formula being falsified in the completeness theorem), define:

```lean
def restricted_label (A : Set Formula) (h_mcs : SetMaximalConsistent A) 
    (target : Formula) (x : Rat) (hx : x in limit_dom A h_mcs) : Finset Formula :=
  (subformulaClosure target).filter (fun f => f in limit_f A h_mcs x)
```

This takes values in `Finset.powerset (subformulaClosure target)`.

### 5.2 Pigeonhole Application

```lean
-- The orbit has infinitely many points
-- The restricted labels take finitely many values
-- By pigeonhole: exists n1 < n2, restricted_label(s^[n1](a)) = restricted_label(s^[n2](a))
```

Infrastructure needed:
- Prove orbit is infinite (follows from strict monotonicity of s^[n](a))
- `Finset.powerset (subformulaClosure target)` is finite (built-in)
- Apply `Set.Finite.exists_lt_map_eq_of_forall_mem` or equivalent

### 5.3 What the Collision Gives

The collision `restricted_label(s^[n1](a)) = restricted_label(s^[n2](a))` means: for every `phi in SubformulaClosure(target)`:
```
phi in limit_f(s^[n1](a)) <-> phi in limit_f(s^[n2](a))
```

This is "the orbit labels are periodic (mod SubformulaClosure(target))". It does NOT give a discriminating formula between orbit and above-orbit points.

### 5.4 What Would Be Needed Beyond Pigeonhole

To get a discriminating formula, one would need to show that the restricted labels on the pred-chain side DIFFER from those on the orbit side. This requires either:
(a) An axiom-level argument (Z1, Prior-UZ) that forces different labels -- but as shown in Section 4.3, the vacuous-guard problem blocks this.
(b) A construction-level argument showing the omega-chain assigns different MCS at different stages -- this is the "construction dynamics" approach.

---

## 6. Assessment and Recommendations

### 6.1 Sub-Formula Finiteness Alone Is Insufficient

Sub-formula finiteness gives useful pigeonhole results (label collision on the orbit) but does NOT solve the discriminating formula problem. The fundamental obstacle is that the gap-at-L scenario is compatible with constant MCS labels everywhere, and sub-formula finiteness cannot distinguish this case.

### 6.2 The Discriminating Formula Must Come from Construction Dynamics

The only way to find a formula that differs across the gap is to use properties specific to the omega-chain construction:
- Which counterexamples are processed at each stage
- What MCS labels are assigned to new domain points
- How C4/C5 witnesses interact with the gap region

### 6.3 Recommended Next Steps

**Option A: Doets Claim 10 with construction-derived discriminating formula (~150-250 lines)**

1. Show that in the gap scenario, the omega-chain construction processes a counterexample that places a C4 witness point with a different MCS label in the gap region.
2. The formula from the C4 counterexample serves as the discriminating formula.
3. Apply Doets Claim 10 (using Z1 already in MCS) to derive contradiction.

Difficulty: High. Requires deep interaction with omega-chain construction internals.

**Option B: Direct contradiction from backward_G + construction dynamics (~100-150 lines)**

The gap-at-L scenario has orbit converging to L from below and pred-chain converging to L from above. Using `backward_G` and construction dynamics, show that some formula propagates from the pred-chain side to an orbit point, contradicting the orbit MCS.

Difficulty: Medium-High. Requires showing backward_G reaches across the gap (not clear it does, since backward_G requires phi at ALL future points, including those beyond the gap).

**Option C: Prove the gap is impossible at the construction level (~200-300 lines)**

Show that the omega-chain construction cannot produce a gap-at-L scenario directly, without any axiom-level reasoning. The argument: at each finite stage, `dom(N)` is finite. The C5-bot witnesses create succ/pred structure. In the limit, the succ/pred structure must be well-founded (each point enters at a finite stage). The gap would require infinitely many stages for the orbit and independently infinitely many stages for the pred-chain, but the dovetailed enumeration processes all counterexamples, eventually bridging the gap.

Difficulty: High. This is essentially the stage-walk approach (plan v9) which was blocked.

**Option D: Accept Z1 soundness gap and proceed (~20 lines)**

Since Z1 is an axiom and its soundness on `IsSuccArchimedean` frames is proved, the only gap is that the limit model's `IsSuccArchimedean` depends on `succ_cofinal`. If we accept that the SOUNDNESS direction (Z1 is valid on frames with `IsSuccArchimedean`) is separate from the COMPLETENESS direction (Z1 in every MCS), we can potentially restructure the proof to establish `IsSuccArchimedean` via a different mechanism and then verify Z1 soundness separately.

Difficulty: Requires architectural restructuring of the completeness proof.

### 6.4 Available Infrastructure Summary

| Component | Location | Status |
|-----------|----------|--------|
| `subformulaClosure : Formula -> Finset Formula` | Syntax/SubformulaClosure.lean:55 | Available |
| `closureWithNeg : Formula -> Finset Formula` | Syntax/SubformulaClosure.lean:90 | Available |
| `Finset.powerset` | Mathlib | Available |
| `Set.Finite.exists_lt_map_eq_of_forall_mem` | Mathlib | Available (ordered pigeonhole) |
| `sigma_signature_formulas` | Quasimodel/HintikkaPoint.lean:85 | Available |
| `z1_in_mcs` | ChronicleToCountermodel.lean:1533 | Available |
| `backward_G` | ChronicleToCountermodel.lean:1707 | Available (inside sorry branch) |
| `backward_F` | ChronicleToCountermodel.lean:1752 | Available (inside sorry branch) |
| `backward_P` | ChronicleToCountermodel.lean:1827 | Available (inside sorry branch) |
| `limit_forward_G` | ChronicleConstruction.lean:1035 | Available |
| `limit_backward_H` | ChronicleConstruction.lean:1089 | Available |
| `limit_F_resolution` | ChronicleConstruction.lean:689 | Available |
| `limit_P_resolution` | ChronicleConstruction.lean:710 | Available |
| `Axiom.prior_UZ`, `Axiom.prior_SZ` | Axioms.lean:377-384 | Available |
| `Axiom.z1` | Axioms.lean:397 | Available |
| `z1_is_valid` | SoundnessLemmas.lean:2425 | Available (uses IsSuccArchimedean) |
| `orbit_below_L` | ChronicleToCountermodel.lean:1643 | Available (inside sorry branch) |
| `h_lt_pred_chain` | ChronicleToCountermodel.lean:1672 | Available (inside sorry branch) |
| `h_pred_chain_ge_L` | ChronicleToCountermodel.lean:1695 | Available (inside sorry branch) |

### 6.5 Estimated Line Counts for New Infrastructure

| Component | Lines | Needed For |
|-----------|-------|------------|
| Restricted label definition + pigeonhole lemma | ~30 | Showing orbit labels are periodic (not directly useful) |
| Discriminating formula from construction dynamics | ~80-120 | Doets Claim 10 application |
| Doets Claim 10 formalized | ~50-80 | Gap elimination |
| Prior-SZ maximum principle | ~40-60 | Alternative to Doets Claim 10 |
| Gap elimination glue | ~30-50 | Connecting everything to close sorry |

---

## 7. Key Definitions and Types

For reference, the exact Lean types of the main objects:

```lean
-- Formula type (inductive, infinite, DecidableEq)
inductive Formula where
  | atom : Nat -> Formula
  | bot : Formula
  | imp : Formula -> Formula -> Formula
  | box : Formula -> Formula
  | all_past : Formula -> Formula
  | all_future : Formula -> Formula
  | untl : Formula -> Formula -> Formula
  | snce : Formula -> Formula -> Formula

-- Sub-formula closure as Finset
def subformulaClosure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset

-- MCS label type (Set Formula, infinite)
def limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) : Rat -> Set Formula

-- Each limit_f(x) is an MCS
theorem limit_c0 ... : SetMaximalConsistent (limit_f A h_mcs x)

-- The succ_cofinal sorry
private theorem succ_cofinal ...
    (a b : LimitDomSubtype A h_mcs) (hab : a < b) :
    exists n, b <= (limitDomSubtype_succ ...)^[n] a
```
