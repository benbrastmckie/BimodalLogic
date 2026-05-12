# Prior-UZ and the Gap-at-L Scenario

Task: 123 | Date: 2026-05-12

## 1. Exact Prior-UZ Statement and Location

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 377

```lean
| prior_UZ (φ : Formula) :
    Axiom (φ.some_future.imp (Formula.untl φ φ.neg))
```

**Expanded**: `F(φ) → U(φ, ¬φ)` for any formula φ, where:
- `F(φ) = ¬G(¬φ)` = "φ holds at some future time"
- `U(φ, ¬φ)` = "Until(φ, ¬φ)" = "φ holds at the nearest future transition, with ¬φ at all intermediate points"

**Companion**: `prior_SZ` at line 383: `P(φ) → S(φ, ¬φ)` (past dual).

**Frame class**: Both are `FrameClass.Discrete` (lines 401-402). They are the ONLY non-base axioms, meaning they're valid on discrete orders but NOT on dense orders.

**Semantic content**: "If φ holds at some future point, there is a NEAREST future point where φ holds." This is the well-ordering property for definable sets in the future direction. Reynolds (1994) shows Prior-UZ + Prior-SZ + U(⊤,⊥) + S(⊤,⊥) axiomatize exactly the logic of integers.

## 2. Usage in the Codebase

### Soundness (proofs that Prior-UZ is valid)

- `SoundnessLemmas.lean:2338`: `prior_UZ_is_valid` -- proves validity on discrete orders using `Nat.find` for well-founded descent on the succ chain. Requires `IsSuccArchimedean`.
- `Soundness.lean:944`: `prior_UZ_valid` -- wraps `prior_UZ_is_valid` for the soundness theorem.
- Multiple case-dispatches throughout `Soundness.lean` and `SoundnessLemmas.lean` where Prior-UZ/SZ are distinguished from dense-compatible axioms.

### Proof Search

- `ProofSearch.lean:372-382`: Automated proof search checks for Prior-UZ patterns (`F(φ)` matching `U(φ, ¬φ)`).
- `ProofSearch.lean:513-519`: Generates `Axiom.prior_UZ phi1` when the search finds an applicable instance.

### Chronicle / Completeness

**Prior-UZ is NEVER directly invoked in the chronicle construction or the countermodel pipeline.** This is the key finding. The only mention is in the docstring at line 827 of `ChronicleToCountermodel.lean`:

> "Prior-UZ axioms and IsSuccArchimedean infrastructure are now in place"

But no proof in the BXCanonical directory calls `Axiom.prior_UZ` or derives `U(φ, ¬φ)` from `F(φ)` for any φ. All uses of `U(⊤,⊥)` come from the `h_discrete` hypothesis directly.

## 3. How Prior-UZ Enters the Limit Structure

### The Derivability Chain

1. `Axiom.prior_UZ φ` is a constructor of `Axiom`, giving `Axiom (φ.some_future.imp (Formula.untl φ φ.neg))`.
2. `DerivationTree.axiom [] _ (Axiom.prior_UZ φ)` gives `DerivationTree [] (F(φ) → U(φ, ¬φ))`.
3. `theorem_in_mcs h_mcs deriv` (MaximalConsistent.lean:476) says: if `DerivationTree [] φ` exists, then `φ ∈ S` for any MCS S.
4. `limit_c0 A h_mcs x hx` (ChronicleConstruction.lean:590) says: `limit_f(x)` is an MCS for any domain point x.

**Conclusion**: For any formula φ and any domain point x in limit_dom:
```
F(φ) → U(φ, ¬φ) ∈ limit_f(x)
```

This means: if `F(φ) ∈ limit_f(x)`, then by `SetMaximalConsistent.implication_property`, `U(φ, ¬φ) ∈ limit_f(x)`.

### The F-to-witness chain

If `φ ∈ limit_f(y)` for some y > x in limit_dom, we can show `F(φ) ∈ limit_f(x)`:

1. If `G(¬φ) ∈ limit_f(x)`, then by `limit_forward_G`, `¬φ ∈ limit_f(y)`.
2. But `φ ∈ limit_f(y)`, giving both φ and ¬φ in the MCS at y. Contradiction with consistency.
3. So `G(¬φ) ∉ limit_f(x)`. By MCS completeness, `¬G(¬φ) ∈ limit_f(x)`.
4. `¬G(¬φ) = F(φ)` (by definition of some_future).

This gives us the CONVERSE of `limit_F_resolution`: not only does `F(φ)` in limit_f(x) imply a witness, but a witness implies `F(φ)` in limit_f(x).

## 4. Analysis of the Gap-at-L Scenario with Prior-UZ

### The scenario

The proof at line 1402 has established:
- Orbit {s^[n](a)} with values converging to L in R from below
- `h_below_L_is_orbit`: any domain point with value < L and >= a is an orbit element
- `h_pred_below_L_contradiction`: above-orbit point with pred.val < L implies False
- `h_pred_at_L_contradiction`: above-orbit point with pred.val = L implies False
- **Remaining**: all above-orbit points have pred.val > L

### Applying Prior-UZ with φ = ⊤

`F(⊤) ∈ limit_f(x)` for any x (there always exists a future domain point by `limit_dom_no_max`). Prior-UZ gives `U(⊤, ¬⊤) = U(⊤, ⊥) = next_top`. This just recovers `h_discrete`. The C5 witness is `succ(x)`, the next orbit element. **Not useful** -- this is what all prior attempts already use.

### Applying Prior-UZ with a distinguishing formula

For Prior-UZ to help, we need φ such that:

(a) `F(φ) ∈ limit_f(x)` for some orbit element x (i.e., φ holds at some point after x)
(b) `¬φ ∈ limit_f(succ(x))` (φ fails at the immediate orbit successor)
(c) The C5 witness for `U(φ, ¬φ)` must land above the orbit (above L)

If (a)-(c) hold, the C5 witness y satisfies:
- y > x, φ ∈ limit_f(y), ¬φ at all domain points between x and y
- y is above the orbit (since all orbit elements between x and y have ¬φ, and the nearest φ-point is above L)
- y is an above-orbit element

Then apply the existing helpers:
- If pred(y).val < L: `h_pred_below_L_contradiction` gives False
- If pred(y).val = L: `h_pred_at_L_contradiction` gives False
- If pred(y).val > L: pred(y) is also above-orbit

### The critical question: does such φ exist?

For (a): we need φ to hold at some above-orbit point c. This requires `φ ∈ limit_f(c)`.

For (b): we need `¬φ ∈ limit_f(succ(x))` at orbit elements near L. Ideally, ¬φ at ALL orbit elements after x.

For (c): if ¬φ holds at every orbit element after x but φ holds at above-orbit c, then the nearest φ-point after x is above L.

**The problem**: We do NOT know a priori which formula φ distinguishes orbit from above-orbit points. The construction builds MCSs at each domain point, and two different points CAN have identical MCSs. If limit_f is constant (same MCS everywhere), no distinguishing formula exists.

### Can all MCSs be identical?

If limit_f(x) = limit_f(y) for all x, y in limit_dom, then every formula that holds at any point holds at every point. In particular:
- G(ψ) ∈ limit_f(x) for all ψ ∈ limit_f(x) (since ψ ∈ limit_f(y) for all y > x, by assumption, which means G(ψ) ∈ limit_f(x) by closure)
- H(ψ) ∈ limit_f(x) for all ψ ∈ limit_f(x)
- All temporal formulas collapse to their base formulas

This scenario is consistent with the logic. A "constant model" where every world is identical satisfies all BX axioms (including Prior-UZ). The Prior-UZ argument cannot distinguish orbit from above-orbit in this case.

**However**: the starting MCS is A (limit_f(0) = A), which might contain formulas that PREVENT constancy. If A contains `F(p)` for an atom p, and `¬p ∈ A`, then there exists y > 0 with `p ∈ limit_f(y)`, but `p ∉ limit_f(0)`. So limit_f is not constant. But this depends on what's in A.

### The universality problem

The gap-at-L argument must work for ANY starting MCS A. It must show IsSuccArchimedean regardless of what formulas A contains. If A is such that all MCSs are identical (which IS possible for certain A), then no formula distinguishes orbit from above-orbit, and Prior-UZ with a specific φ cannot help.

**Conclusion**: Prior-UZ with a specific distinguishing formula is NOT a universal approach to closing the gap.

## 5. The Stage-Walk Approach (Plan v9 Insight)

Report 11 and plan v9 identified the correct approach, which does NOT require a distinguishing formula. The argument is:

### Core insight (plan v9, lines 337-347)

For adjacent dom(N) points a_val < b_val where the C5-bot counterexample for U(⊤,⊥) at a_val was processed at stage M < N:

1. The C5-bot witness y enters at stage M+1, so y ∈ dom(M+1) ⊆ dom(N)
2. The bot-guard ensures no limit_dom between a_val and y. So succ(a_as_sub) = y
3. succ(a_as_sub) ≤ b_as_sub (by succ_le_iff, since a < b)
4. y is a dom(N) point with a_val < y ≤ b_val
5. Since a_val and b_val are adjacent in dom(N), and y ∈ dom(N) with a_val < y ≤ b_val, we must have y = b_val
6. Therefore succ(a_as_sub) = b_as_sub

This proves: for adjacent dom(N) points where C5-bot is resolved, succ steps between them directly.

### Induction on N

The full proof uses induction on N (plan v9, lines 597-698):

**Statement**: For all a, b ∈ LimitDomSubtype with a.val, b.val ∈ dom(N) and a ≤ b, ∃ k, succ^[k](a) = b.

**Base** (N = 0): dom(0) = {0}, so a = b = ⟨0, ...⟩. k = 0.

**Step** (N → N+1): Case split on whether a.val and b.val are in dom(N) or are the unique new point at stage N+1:
- Both in dom(N): apply IH directly
- One is the new point: the new point was inserted between two dom(N) points (or beyond max/below min). Use IH to reach the bracketing dom(N) points, then use `succ_orbit_convex` to factor through the new point
- Both new: impossible by `omega_chain_dom_new_unique` unless a = b

### Relationship to Prior-UZ

Prior-UZ is NOT needed for this argument. The stage-walk induction uses only:
1. `h_discrete`: U(⊤,⊥) ∈ limit_f(x) for all x (gives succ/pred structure)
2. `omega_chain_dom_new_unique`: at most one new point per stage
3. `succ_orbit_convex`: orbit elements between a and succ^[n](a) are orbit elements
4. The C5-bot witness entering at the processing stage (from omega_chain_c5_witness)
5. The bot-guard preventing intermediate limit_dom points

Prior-UZ provides the "nearest witness" property semantically, but this is already captured by the C5 construction for `U(⊤,⊥)` (which is in every MCS by h_discrete). The Prior-UZ axiom ensures VALIDITY of this pattern on semantic models, but the CONSTRUCTION already builds the witnesses directly through counterexample elimination.

## 6. Why Prior-UZ Cannot Close the Gap Directly

### The fundamental obstacle

Prior-UZ with any formula φ gives `U(φ, ¬φ)` at orbit element x when `F(φ) ∈ limit_f(x)`. The C5 witness y satisfies φ ∈ limit_f(y) and ¬φ at all intermediate domain points. But:

1. **If φ = ⊤**: We get U(⊤, ⊥) = next_top. C5 witness = succ(x) = next orbit element. Does not cross the gap.

2. **If φ distinguishes orbit from above-orbit**: The C5 witness y is above the orbit. But we need pred(y).val ≤ L for the contradiction helpers. If pred(y).val > L, y and pred(y) are both above-orbit, and we have a SMALLER gap between L and pred(y).val. This is the same gap scenario at a smaller scale, with no termination argument.

3. **If no distinguishing φ exists**: Prior-UZ reduces to case 1 (every instance gives next_top or something equally trivial).

4. **The gap scenario is order-theoretically self-consistent**: An order of type omega + omega* (orbit converging to L from below, above-orbit converging from above) satisfies all discrete axioms locally. The contradiction must come from the CONSTRUCTION (which builds witnesses and fills gaps), not from abstract order-theoretic reasoning.

### Prior-UZ's actual role

Prior-UZ ensures that the SEMANTIC model satisfies "every definable future set has a least element." In the soundness proof, this is proved using `Nat.find` on the succ chain, which ASSUMES `IsSuccArchimedean`. So Prior-UZ's validity DEPENDS ON `IsSuccArchimedean`, not the other way around.

In the completeness direction, Prior-UZ instances are IN every MCS (as theorems), but the C5 witnesses they generate are the same witnesses that the omega-chain construction already provides for `U(⊤,⊥)`. Prior-UZ with other formulas creates C5 witnesses for `U(φ, ¬φ)`, but these witnesses don't necessarily help with the structural gap argument.

## 7. Recommended Approach

The stage-walk induction on N (plan v9, Section "Summary of the induction on N") is the correct approach. It avoids the gap-at-L scenario entirely by inducting on the construction stage rather than reasoning about convergence in R.

**Key advantages**:
- No real analysis (no iSup, no convergence, no gap scenarios)
- Works for ANY starting MCS A (no need for distinguishing formulas)
- Uses only construction-specific properties that are already proved sorry-free
- Orbit convexity handles all intermediate cases cleanly

**Remaining challenge**: The induction on N requires careful case analysis for the "new point at stage N+1" cases, including identifying how the new point relates to dom(N) points and which C5/C4 case inserted it. Plan v9 works through all cases in detail.

**Estimated formalization effort**: 150-250 lines of new Lean code, replacing the existing 200-line convergence proof body.

## 8. Confidence Assessment

| Aspect | Assessment |
|--------|-----------|
| Prior-UZ is in the axiom system | CONFIRMED (Axioms.lean:377) |
| Prior-UZ instances are in every MCS | CONFIRMED (via theorem_in_mcs + DerivationTree.axiom) |
| Prior-UZ has NEVER been used in any attempt | CONFIRMED (grep finds zero uses in BXCanonical/) |
| Prior-UZ can close the gap directly | NO -- it cannot distinguish orbit from above-orbit universally |
| Prior-UZ with specific φ works for SOME A | POSSIBLE but not universal -- depends on A's formulas |
| Stage-walk induction avoids the gap entirely | YES -- the correct approach |
| The sorry is provable | HIGH CONFIDENCE -- plan v9's analysis is sound |

## 9. Summary

Prior-UZ (`F(φ) → U(φ, ¬φ)`) is a powerful axiom that enforces "nearest witness" for definable sets, but it cannot directly close the gap-at-L scenario in the `limitDomSubtype_isSuccArchimedean` proof. The reason is twofold: (1) there is no universal formula φ that distinguishes orbit from above-orbit points for arbitrary starting MCS A, and (2) even when such φ exists, the C5 witness it produces does not necessarily have pred.val ≤ L, leading to an infinite regress.

The correct approach is the stage-walk induction on N from plan v9, which avoids the gap scenario entirely by reasoning about how the omega-chain construction builds the domain stage by stage. This approach uses `succ_orbit_convex` to handle intermediate points and never needs to reason about convergence, suprema, or formula discrimination.
