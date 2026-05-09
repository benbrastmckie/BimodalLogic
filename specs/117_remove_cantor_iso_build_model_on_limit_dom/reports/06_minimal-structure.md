# Research Report: Minimal Algebraic Structure for MF/TF Validation (Task 117)

**Task**: 117 - Minimal algebraic structure validating MF/TF
**Started**: 2026-05-08T12:00:00Z
**Completed**: 2026-05-08T13:30:00Z
**Task Type**: math

## Executive Summary

- The full additive group structure (including subtraction/inverse) is **load-bearing** for MF/TF validation; a monoid does not suffice.
- Commutativity is used but only in an eliminable way for MF/TF specifically; however it is essential for the `converse` axiom of TaskFrame.
- A group action formulation is possible and strictly weaker: any linear order (D, <) with a group G acting transitively by order automorphisms, with Omega closed under the G-action, validates MF/TF. This is the true minimal structure.
- Order-homogeneity of (D, <) is equivalent to having such a transitive group action. By Holder's theorem, every archimedean linearly ordered group is abelian and embeds into (R, +), so for archimedean D the group action formulation collapses back to an ordered abelian group.
- Non-commutative ordered groups exist (e.g., free groups with suitable orderings) but are never archimedean by Holder's theorem.

## Context & Scope

The bimodal logic TM uses axioms MF (Box phi -> Box(G phi)) and TF (Box phi -> G(Box phi)) connecting modal and temporal operators. Currently, the time domain D carries `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` -- a linearly ordered abelian group. The question is whether weaker algebraic structures suffice.

The investigation traces every use of group operations in the proof chain:
1. `WorldHistory.time_shift` (shift construction)
2. `TimeShift.time_shift_preserves_truth` (truth transport)
3. `ShiftClosed` (closure of Omega under shifts)
4. `modal_future_valid` / `temp_future_valid` (MF/TF soundness)

## Findings

### Q1: Does MF/TF validation require a GROUP or just a MONOID?

**Answer: A group is required. A monoid does not suffice.**

**Proof trace**: The MF proof at Soundness.lean:260-265 proceeds:

```
intro h_box_phi sigma h_sigma_mem s hts
have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift sigma (s - t)) (h_sc sigma h_sigma_mem (s - t))
exact (TimeShift.time_shift_preserves_truth M Omega h_sc sigma t s phi).mp h_phi_at_shifted
```

The shift amount is `s - t` where s > t. In a monoid, `s - t` does not exist -- subtraction requires additive inverse.

The TF proof at Soundness.lean:268-273 is structurally identical:

```
have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift sigma (s - t)) (h_sc sigma h_sigma_mem (s - t))
exact (TimeShift.time_shift_preserves_truth M Omega h_sc sigma t s phi).mp h_phi_at_shifted
```

Both MF and TF use `s - t` (subtraction) as the shift amount. Since s > t, the difference s - t > 0, so one might hope that only positive shifts are needed.

**However**, `time_shift_preserves_truth` (Truth.lean:369-437) in the Box case requires shifts in BOTH directions:

```lean
-- Forward direction: uses shift by (y - x)
have h_shifted_mem : WorldHistory.time_shift rho (y - x) in Omega := h_sc rho h_rho_mem (y - x)

-- Backward direction: uses shift by (x - y) = -(y - x)
have h_shifted_mem : WorldHistory.time_shift rho (x - y) in Omega := h_sc rho h_rho_mem (x - y)
```

When y > x (the case for MF/TF where s > t), the forward direction uses the positive shift y - x, but the backward direction of the biconditional uses x - y < 0, a negative shift. The backward direction is essential because `time_shift_preserves_truth` establishes an IFF, and the proof of MF uses the forward direction of this IFF, which internally relies on both directions being established.

Furthermore, the `truth_double_shift_cancel` lemma (Truth.lean:286-348) and `time_shift_time_shift_neg_domain_iff` (WorldHistory.lean:333-341) explicitly use:
- `neg_add_cancel`: -Delta + Delta = 0
- `add_assoc`: associativity
- `add_zero`: identity

These are group operations (specifically, the existence and properties of additive inverse).

**Conclusion**: Subtraction (additive inverse) is load-bearing. A monoid does not provide subtraction, so MF/TF cannot be validated over a mere ordered monoid with the current proof strategy.

**Could we reformulate to avoid subtraction?** Only if we restructure the semantics so that ShiftClosed uses only forward shifts and truth_at for Box does not require the bijective correspondence. But this would fundamentally change the proof architecture, because `time_shift_preserves_truth` for Box requires showing that truth at one time implies truth at another time FOR ALL histories in Omega, which requires the ability to "undo" shifts. Without inverse, you can shift histories forward but cannot shift them back, breaking the Box biconditional.

### Q2: Does commutativity matter?

**Answer: Commutativity is used in the proofs but is partially eliminable for MF/TF. However, it is essential for TaskFrame itself.**

**Uses of commutativity in time_shift**:

In `WorldHistory.time_shift` (WorldHistory.lean:238-260), the convexity proof uses:
```lean
have hxy' : x + Delta <= y + Delta := by rw [add_comm x, add_comm y]; exact add_le_add_right hxy Delta
```

This rewrites `x + Delta` to `Delta + x` to apply `add_le_add_right`. In a non-commutative group, we would need `add_le_add_left` instead (order compatibility on the correct side).

The `respects_task` proof uses:
```lean
have h_duration : (t + Delta) - (s + Delta) = t - s := by rw [add_sub_add_right_eq_sub]
```

The lemma `add_sub_add_right_eq_sub` states (t + c) - (s + c) = t - s. This holds in any group (commutative or not): it follows from associativity and inverse properties alone: (t + c) + (-(s + c)) = (t + c) + (-c + (-s)) = t + (c + (-c)) + (-s) = t + 0 + (-s) = t - s. But this derivation uses that -(s + c) = -c + (-s) (inverse reversal), which holds in any group.

In `time_shift_preserves_truth` (Truth.lean:369-437), commutativity appears in the Past/Future cases:
```lean
calc s' + (y - x) = (y - x) + s' := add_comm s' (y - x)
```

This could be avoided by choosing a different shift convention (left-shift vs right-shift). With a right-shift convention tau_Delta(r) = tau(r + Delta), commutativity is used to convert between `s + Delta` and `Delta + s`. With a left-shift convention tau_Delta(r) = tau(Delta + r), the order-compatibility direction changes.

**However**, commutativity is essential for `TaskFrame.converse`:
```lean
converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

The `backward_comp` theorem (TaskFrame.lean:143-159) uses commutativity via:
```lean
have h4 : -y + -x = -(x + y) := by simp [neg_add_rev, add_comm]
```

Here `neg_add_rev` gives -(x + y) = -y + -x, and `add_comm` is used implicitly. In a non-commutative group, -(x + y) = -y + -x (this is true in any group, commutative or not), but the forward_comp argument composes in order (v, u, w) with durations (-y, -x), getting task_rel v (-y + -x) w, and we need this to equal -(x + y). Since -y + -x = -(x + y) in any group, this specific step does not require commutativity.

**Net assessment**: The proofs use commutativity in several places, but in most cases it could be refactored away by choosing consistent conventions. The deepest use is in order compatibility: `add_le_add_right` requires `a <= b -> a + c <= b + c` (right-translation preserves order). In a non-commutative ordered group, left-translation and right-translation preserving order are independent conditions. The proofs need at least one-sided translation-invariance of the order.

### Q3: Group action formulation

**Answer: A group action formulation is strictly weaker and works.**

**Definition**: A *temporal action frame* consists of:
- A linear order (D, <) (no algebraic structure on D itself)
- A group G
- A group action alpha: G -> Aut(D, <) (action by order automorphisms)
- The action is *transitive*: for any t1, t2 in D, there exists g in G with alpha(g)(t1) = t2

**ShiftClosed reformulation**: For tau in Omega and g in G, the shifted history tau_g defined by tau_g(r) = tau(alpha(g)(r)) is in Omega.

**MF validation**: Given Box(phi) at (tau, t), need Box(G(phi)) at (tau, t). Take any sigma in Omega and s > t. By transitivity, there exists g in G with alpha(g)(t) = s. The shifted sigma_g is in Omega (by closure). Box(phi) at (sigma_g, t) gives phi at (sigma_g, t), which by the shift equals phi at (sigma, s). Done.

**Why this is weaker**: D need not be a group. For example:
- D = {0, 1, 2, ...} (natural numbers) with the usual order does NOT admit a transitive order-automorphism group (0 has no predecessor, but 1 does).
- D = Q with the usual order has Aut(Q, <) acting transitively (translations q -> q + r).
- D = R with the usual order likewise.
- D could be an exotic dense linear order (like a Suslin line, if one exists under appropriate set-theoretic axioms).

**Relationship to ordered groups**: If G acts *regularly* (transitively and freely: for each t1, t2 there is exactly one g with g(t1) = t2) on D, then choosing a basepoint d0 in D gives a bijection G -> D via g -> alpha(g)(d0). The order on D pulls back to an order on G making G an ordered group. So regular transitive actions on linear orders are equivalent to ordered groups.

For merely transitive (not necessarily free) actions, there is a quotient: G/Stab(d0) is in bijection with D, and the order on D makes G/Stab(d0) an ordered set with G acting on it.

### Q4: Order-homogeneous linear orders

**Answer: A linear order (D, <) admits a transitive automorphism group iff it is order-homogeneous. Order-homogeneous linear orders are either uniformly dense (no covers) or uniformly discrete (every element has an immediate successor and predecessor).**

**Theorem (Order homogeneity dichotomy)**: Let (D, <) be a linear order with transitive Aut(D, <). Then either:
1. D is densely ordered (between any two elements there is a third), or
2. D is discrete (every element has an immediate successor and predecessor).

**Proof sketch**: Suppose a in D has an immediate successor b (i.e., a < b and there is no c with a < c < b). For any x in D, by transitivity there exists sigma in Aut(D, <) with sigma(a) = x. Since sigma preserves order and the covering relation, sigma(b) is the immediate successor of x. So every element has an immediate successor. By applying the same argument to the predecessor (using the automorphism mapping a to any target), every element has an immediate predecessor. So D is uniformly discrete.

Conversely, if no element has an immediate successor, then D is dense.

**Characterization**:
- If D is order-homogeneous, dense, without endpoints, and countable, then D is order-isomorphic to (Q, <) by Cantor's theorem.
- If D is order-homogeneous, discrete, without endpoints, and countable, then D is order-isomorphic to (Z, <).
- The real line (R, <) is order-homogeneous and dense but uncountable.

**Relevance to Mathlib**: The theorem `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` in Mathlib (module `Mathlib.GroupTheory.ArchimedeanDensely`) states:

```
forall (G : Type) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G],
  Nonempty (G iso+o Z) or DenselyOrdered G
```

This confirms that archimedean linearly ordered abelian groups are either isomorphic to Z or densely ordered -- exactly the dichotomy above, but stated for groups rather than abstract linear orders.

### Q5: Exact frame class for MF/TF validity

**Answer**: MF and TF are valid over a frame (D, Omega) if and only if Omega is "shift-adequate" -- meaning that for any sigma in Omega and any t1, t2 in D, there exists sigma' in Omega such that truth_at(sigma', t1, phi) iff truth_at(sigma, t2, phi) for all phi.

More precisely, the condition used in the codebase is:

```
ShiftClosed(Omega) := forall sigma in Omega, forall Delta : D, time_shift(sigma, Delta) in Omega
```

This is a SUFFICIENT condition. The necessary condition is weaker: we only need that for each sigma in Omega and each pair (t, s), there exists some sigma' in Omega (not necessarily a time-shift of sigma) that agrees with sigma on the truth of all formulas with the appropriate time offset.

However, ShiftClosed is the natural and clean sufficient condition that arises from the group structure on D. Without group structure on D, the time_shift construction itself is not well-defined (since tau_Delta(r) = tau(r + Delta) requires addition on D).

**Alternative formulation without group structure**: Replace ShiftClosed with a condition on (D, Omega) directly:

```
AutClosed(Omega, G) := forall sigma in Omega, forall g in G, sigma . g in Omega
```

where G <= Aut(D, <) acts transitively and sigma.g is the history sigma composed with g.

**Minimal frame condition (model-theoretic)**: MF (Box phi -> Box G phi) is valid at (tau, t) iff: whenever phi holds at all worlds at time t, phi holds at all worlds at all times s > t. This is a property of the SET Omega: it must be "temporally saturated" in the sense that knowing phi at all histories at one time t forces phi at all histories at all future times.

### Q6: Relationship to ordered abelian groups

**Claim**: If (D, <) is an order-homogeneous linear order with a transitive automorphism group G, then D admits an ordered group structure IF G acts regularly (= simply transitively, = free + transitive).

**Proof**: Choose a basepoint d0. The map f: G -> D given by f(g) = g(d0) is a bijection (by regularity). Define d1 + d2 := f(f^{-1}(d1) . f^{-1}(d2)). This makes (D, +) a group isomorphic to G. The order on D makes this an ordered group.

**Converse**: Any ordered group (D, +, <) has Aut(D, <) containing all translations t -> t + d, which act regularly. So (D, <) is order-homogeneous with a regular transitive automorphism group.

**Non-regular case**: If G acts transitively but not freely, then Stab(d0) is nontrivial, meaning there are non-identity automorphisms fixing d0. For linear orders, order automorphisms fixing a point must fix everything between any two fixed points, so the fixed-point set is a union of intervals. A nontrivial automorphism fixing d0 must move some points, creating a complex structure.

**Key result (Holder's theorem for ordered groups)**:
- Every archimedean linearly ordered group is abelian (commutativity is forced by the archimedean property).
- Every archimedean linearly ordered group embeds into (R, +, <=) as an ordered subgroup.
- Consequence: for archimedean D, the group action formulation collapses to the ordered abelian group formulation.

**Non-archimedean examples**: Non-archimedean linearly ordered groups exist. For instance, Z x Z with lexicographic order: (a, b) <= (c, d) iff a < c, or a = c and b <= d. This is an ordered abelian group that is not archimedean ((0, 1) is infinitesimal relative to (1, 0)). By the Hahn embedding theorem, every linearly ordered abelian group embeds into a product of copies of R with lexicographic order.

Non-abelian linearly ordered groups also exist (e.g., the free group on two generators admits a bi-invariant linear order), but by Holder's theorem they are never archimedean.

## Dependency Analysis: What Would Break if We Weakened the Structure

### Removing AddCommGroup -> AddMonoid (dropping inverse/subtraction)

**Would break**:
1. `WorldHistory.time_shift` definition: uses `sigma.domain(z + Delta)` -- this is fine, but all the cancellation lemmas (`time_shift_time_shift_neg_domain_iff`, `time_shift_time_shift_neg_states`, `time_shift_inverse_domain`) use `neg_add_cancel`, which requires inverse.
2. `TimeShift.time_shift_preserves_truth`, Box case backward direction: uses shift by `x - y` (negative when y > x).
3. `ShiftClosed`: quantifies over ALL Delta including negative ones.
4. `TaskFrame.converse`: uses `-d` (negation).
5. `TaskFrame.backward_comp`: derived from forward_comp + converse using negation.
6. `WorldHistory.respects_task`: uses `t - s` (subtraction).

**Count**: At least 6 critical dependencies on inverse/subtraction.

### Removing commutativity (AddCommGroup -> AddGroup)

**Would break**:
1. `WorldHistory.time_shift` convexity proof: uses `add_comm` to convert `x + Delta` to `Delta + x` for `add_le_add_right`.
2. `TimeShift.time_shift_preserves_truth`, Past/Future cases: uses `add_comm` to reorder additions.
3. `WorldHistory.respects_task` in time_shift: uses `add_sub_add_right_eq_sub` which in non-commutative groups requires careful side management.

**Fixable?**: Mostly yes, by choosing a consistent left-action or right-action convention throughout. The key lemma `add_sub_add_right_eq_sub` : (t + c) - (s + c) = t - s holds in any group. The order-compatibility `add_le_add_right` requires right-translation monotonicity, which is the standard condition for a right-ordered group. Most of the `add_comm` uses are cosmetic reformulations.

However, `IsOrderedAddMonoid` in Lean/Mathlib assumes commutativity in practice (it is defined for `OrderedAddCommMonoid`). Switching to a non-commutative ordered group would require different Mathlib typeclasses.

## Recommendations

### For the current project (practical)

**Keep `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`**. This is the right level of generality for the following reasons:
1. It matches the JPL paper's specification exactly (D is a totally ordered abelian group).
2. It is well-supported by Mathlib typeclasses.
3. Weakening to non-commutative groups would require substantial refactoring of typeclass usage throughout the codebase with no practical benefit.
4. All concrete time domains used (Int, Rat, Real) are commutative.

### For mathematical understanding

The true minimal structure for MF/TF validation is:
1. A linear order (D, <)
2. A group G acting on D by order automorphisms
3. The action is transitive
4. Omega is closed under the G-action

This is equivalent to (D, <) being order-homogeneous and Omega being G-invariant.

For archimedean D, this is equivalent to D being an ordered abelian group (by Holder's theorem). So the current formalization captures the minimal structure for archimedean time domains, which includes all practically relevant cases (Z, Q, R).

### For potential future generalization

If one wanted to support non-archimedean time domains (e.g., hyperreal time, lexicographic products), the group action formulation would be cleaner. But this is a significant architectural change with no current use case.

## Risks & Mitigations

- **Risk**: Attempting to weaken the algebraic structure could break the proof chain in subtle ways.
  **Mitigation**: This report identifies every dependency point. Any weakening should be tested by locally changing the typeclass constraints and checking which files fail to build.

- **Risk**: The group action formulation introduces complexity without practical benefit.
  **Mitigation**: Keep it as mathematical context for the documentation/paper, not as a code change.

## Appendix

### Group operations inventory (complete list)

| Operation | Location | Purpose |
|-----------|----------|---------|
| `s - t` (subtraction) | Soundness.lean:264,272 | Shift amount for MF/TF proof |
| `neg_add_cancel` | WorldHistory.lean:279,284,312,337,350 | Double-shift cancellation |
| `add_assoc` | WorldHistory.lean:279,284,312,337,350 | Associativity in cancellation |
| `add_zero` | WorldHistory.lean:279,284,312,328,337,350 | Identity after cancellation |
| `add_comm` | WorldHistory.lean:245,246,255; Truth.lean:464,505,507,536,538,619 | Commutativity for order compat |
| `add_le_add_right` | WorldHistory.lean:245,246,255 | Order compatibility of translation |
| `neg_sub` | Truth.lean:430 | y - x = -(x - y) |
| `sub_sub_cancel` | Truth.lean:449,452,488,491,551,555,559,571,575 | Subtraction cancellation |
| `add_sub_cancel_left` | Truth.lean:379,467,470,510,541,592,598 | Addition-subtraction cancellation |
| `sub_lt_sub_right` | Truth.lean:448,487,551,555,571 | Order compatibility of subtraction |
| `add_lt_add_right` | Truth.lean:463,501 | Order compat for past/future |
| `-d` (negation) | TaskFrame.lean:122 | Converse axiom |
| `neg_nonneg` | TaskFrame.lean:152,153 | Sign of negation |
| `neg_add_rev` | TaskFrame.lean:157 | Inverse of sum |

### Mathlib theorems referenced

- `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`: Archimedean linearly ordered abelian groups are Z-isomorphic or densely ordered.
- `OrderIso.addRight`: Right-translation by element a is an order isomorphism in ordered groups.
- `AddTorsor`: An ordered group acts on itself as an ordered torsor.
- Holder's theorem (classical, not directly in Mathlib as named theorem): Every archimedean linearly ordered group is abelian and embeds into (R, +).

### Search queries used

- lean_leansearch: "ordered additive group acts on itself by translation preserving order"
- lean_leansearch: "every archimedean linearly ordered group is either isomorphic to integers or densely ordered"
- lean_leanfinder: "linearly ordered additive commutative group subtraction preserves order"
- lean_leanfinder: "ordered monoid without inverse additive cancellative"
- lean_leanfinder: "group action on linearly ordered set by order isomorphisms transitively"
- lean_loogle: "OrderIso.addRight"
- WebSearch: Holder theorem, archimedean groups, order-homogeneous linear orders

### References

- Otto Holder, "Die Axiome der Quantitat und die Lehre vom Mass" (1901)
- [Archimedean group - Wikipedia](https://en.wikipedia.org/wiki/Archimedean_group)
- [Linearly ordered group - Wikipedia](https://en.wikipedia.org/wiki/Linearly_ordered_group)
- [Hahn embedding theorem - Wikipedia](https://en.wikipedia.org/wiki/Hahn_embedding_theorem)
- Mathlib module `Mathlib.GroupTheory.ArchimedeanDensely`
- Mathlib module `Mathlib.Algebra.Order.Group.OrderIso`
