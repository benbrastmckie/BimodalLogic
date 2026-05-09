# Frame Correspondence for MF/TF Axioms

**Task**: 117 - Remove Cantor Iso, Build Model on Limit Domain
**Date**: 2026-05-08
**Focus**: Frame correspondence theory for the modal-temporal interaction axioms MF and TF

---

## 1. Setup and Definitions

### 1.1 The Logic TM

TM is a bimodal logic combining S5 modal logic (box/diamond) with linear tense logic (G/H/F/P plus Until/Since). The semantics uses:

- **Time domain**: `(D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- **Task frame**: `TaskFrame D` with world states, task relation, nullity identity, forward compositionality, and converse
- **World histories**: `WorldHistory F` -- functions from convex time domains to world states, respecting the task relation
- **Admissible histories**: `Omega : Set (WorldHistory F)` -- a designated set of histories
- **Truth**: `truth_at M Omega tau t phi` -- recursive on formula structure

### 1.2 The Axioms

From `Theories/Bimodal/ProofSystem/Axioms.lean`:

**MF (modal_future)**: `Box(phi) -> Box(G(phi))`
- "If phi is necessary (true in all histories at time t), then G(phi) is necessary (true in all histories at all future times)"

**TF (temp_future)**: `Box(phi) -> G(Box(phi))`
- "If phi is necessary at time t, then at all future times, phi is necessary"

### 1.3 ShiftClosed

From `Theories/Bimodal/Semantics/Truth.lean` (line 242):

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

Where `time_shift sigma Delta` produces a history tau with:
- `tau.domain z <-> sigma.domain (z + Delta)`
- `tau.states z = sigma.states (z + Delta)`

### 1.4 Validity

From `Theories/Bimodal/Semantics/Validity.lean` (line 73):

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

Validity quantifies over all D, all frames, all models, all **shift-closed** Omega, all histories in Omega, and all times.

---

## 2. Abstract Bimodal Kripke Frame Analysis

### 2.1 The Abstract Frame

To analyze MF and TF via standard correspondence theory, we view TM semantics as a bimodal Kripke frame. Define:

- **Points**: W = {(tau, t) | tau in Omega, t in D} -- history-time pairs
- **Temporal accessibility** (for G): (tau, t) R_G (tau', t') iff tau = tau' and t < t'
  (same history, strictly later time)
- **Modal accessibility** (for Box): (tau, t) R_Box (tau', t') iff t = t'
  (same time, any history in Omega)

Note: R_Box is the universal relation at each time slice (since Box quantifies over all sigma in Omega).

### 2.2 MF Correspondence: Box(phi) -> Box(G(phi))

**Claim**: MF corresponds to the frame condition:

> R_Box ; R_G  subset  R_G ; R_Box

That is: for all w, w', w'', if w R_Box w' and w' R_G w'', then there exists w''' such that w R_G w''' and w''' R_Box w''.

**Proof (frame condition -> axiom validity)**:

Suppose R_Box ; R_G subset R_G ; R_Box. Assume Box(phi) at (tau, t). We need Box(G(phi)) at (tau, t), i.e., for all sigma in Omega and all s > t, phi holds at (sigma, s).

Take any (sigma, s) with sigma in Omega and s > t. We have:
- (tau, t) R_Box (sigma, t)  [same time, different history]
- (sigma, t) R_G (sigma, s)  [same history, s > t]

By the frame condition, there exists (tau', s) such that:
- (tau, t) R_G (tau', s)  [which requires tau = tau' and t < s -- but this means tau' = tau]
- (tau', s) R_Box (sigma, s)  [same time s]

Wait -- this doesn't quite work because R_G requires the SAME history. The frame condition says there exists w''' with (tau, t) R_G w''' and w''' R_Box (sigma, s). Since R_G requires the same history, w''' = (tau, s). Then w''' R_Box (sigma, s) requires the same time s, which holds. So the condition becomes: phi holds at (tau, s), and then by Box(phi) at time s we get phi at (sigma, s).

But this requires Box(phi) to hold not just at time t but at all times s > t -- which is exactly what TF gives, not what MF gives.

**Let me redo this more carefully.**

#### 2.2.1 Formal Correspondence Calculation for MF

MF: Box(phi) -> Box(G(phi))

Unfolding truth at (tau, t):
- Box(phi) at (tau, t): for all sigma in Omega, phi at (sigma, t)
- Box(G(phi)) at (tau, t): for all sigma in Omega, G(phi) at (sigma, t)
  = for all sigma in Omega, for all s > t, phi at (sigma, s)

So MF says: [for all sigma, phi(sigma, t)] -> [for all sigma, for all s > t, phi(sigma, s)]

This is equivalent to: [for all sigma, phi(sigma, t)] -> [for all s > t, for all sigma, phi(sigma, s)]

Which is: Box_t(phi) -> for all s > t, Box_s(phi)

Where Box_t means "phi at all histories at time t."

**This is a NON-TRIVIAL semantic condition.** It says that truth at all histories at time t IMPLIES truth at all histories at all future times s > t.

In terms of frame conditions, this requires that the set of "points accessible from a given time slice" has a specific closure property under temporal shift.

#### 2.2.2 Standard Confluence Reading

In the standard product/fusion modal logic literature (Gabbay, Kurucz, Wolter, Zakharyaschev 2003), for two modalities [1] and [2] with accessibility relations R_1 and R_2:

**Commutativity axiom** [1][2]p -> [2][1]p corresponds to:
> for all x,y,z: (xR_1 y and yR_2 z) -> exists u: (xR_2 u and uR_1 z)

This is a "confluence" or "Church-Rosser" condition: R_1 ; R_2 subset R_2 ; R_1 (up to existential quantification).

**MF = [Box][G]phi -> [Box]phi is NOT this.** Let me re-read the axiom.

MF is: Box(phi) -> Box(G(phi)), which is [Box]p -> [Box][G]p.

This is NOT [Box][G]p -> [G][Box]p (which would be the commutativity axiom).

MF says: [Box]p -> [Box][G]p. In terms of accessibility relations:
- [Box]p at w: for all w' with w R_Box w', p at w'
- [Box][G]p at w: for all w' with w R_Box w', for all w'' with w' R_G w'', p at w''

So MF says: if p is true at all R_Box-successors, then p is true at all R_Box-then-R_G successors.

Frame condition: for all w, if (for all w', w R_Box w' -> p(w')) -> (for all w' w'', w R_Box w' and w' R_G w'' -> p(w''))

This holds iff: every R_Box;R_G successor is already an R_Box successor:

> **R_Box ; R_G  subset  R_Box**

That is: if w R_Box w' and w' R_G w'', then w R_Box w''.

**Interpretation**: If (tau, t) and (sigma, t) are at the same time (R_Box related), and (sigma, t) R_G (sigma, s) for s > t (temporal successor in sigma), then (tau, t) R_Box (sigma, s), which means t = s. But s > t, so this is impossible unless there are no temporal successors.

**This shows MF is NOT a standard frame condition on a standard Kripke frame.** The axiom [Box]p -> [Box][G]p cannot hold in any frame where R_G is nonempty and R_Box relates only same-time points, UNLESS we have additional structure.

#### 2.2.3 Why Standard Kripke Frames Fail

The key insight is that the TM semantics is NOT a standard Kripke frame. In a standard Kripke frame:
- Each point w has a fixed truth value for each atom
- Box(phi) at w means phi at all R-successors

But in TM semantics, the SAME history sigma evaluated at DIFFERENT times can give different truth values for atoms (because atoms depend on sigma.states(t)). The time-shift operation creates a NEW history from an old one, which is the mechanism by which MF and TF are validated.

The soundness proof (Soundness.lean lines 260-265) works as follows:

```
Given: Box(phi) at (tau, t) -- phi true at all sigma in Omega at time t
Goal: Box(G(phi)) at (tau, t) -- for all sigma in Omega, for all s > t, phi at (sigma, s)

Take any sigma in Omega and s > t.
Let sigma' = time_shift(sigma, s - t).
By ShiftClosed: sigma' in Omega.
By Box(phi) at t: phi at (sigma', t).
By time_shift_preserves_truth: phi at (sigma', t) <-> phi at (sigma, s).
Therefore: phi at (sigma, s). QED.
```

The proof uses the **bijection** between "histories at time t" and "histories at time s" provided by time-shifting. ShiftClosed ensures this bijection maps Omega to Omega.

### 2.3 TF Correspondence: Box(phi) -> G(Box(phi))

TF: Box(phi) -> G(Box(phi))

Unfolding: [for all sigma, phi(sigma, t)] -> [for all s > t, for all sigma, phi(sigma, s)]

This is the same propositional content as MF! Both say: Box_t(phi) -> for all s > t, Box_s(phi).

**The difference is purely in the order of quantifiers in the SYNTAX**, but the semantic content is identical because:
- Box(G(phi)) = for all sigma, for all s > t, phi(sigma, s) = for all s > t, for all sigma, phi(sigma, s) = G(Box(phi))

Wait -- actually this is subtle. Let me be precise about which history the G quantifier ranges over.

**MF**: Box(phi) -> Box(G(phi))
- Antecedent at (tau, t): for all sigma in Omega, phi at (sigma, t)
- Consequent at (tau, t): for all sigma in Omega, [G(phi) at (sigma, t)]
  = for all sigma in Omega, for all s > t, phi at (sigma, s)

**TF**: Box(phi) -> G(Box(phi))
- Antecedent at (tau, t): for all sigma in Omega, phi at (sigma, t)
- Consequent at (tau, t): for all s > t, [Box(phi) at (tau, s)]
  = for all s > t, for all sigma in Omega, phi at (sigma, s)

Both consequents say: for all sigma in Omega, for all s > t, phi(sigma, s). They differ only in the order of universal quantifiers, which commute. So **MF and TF have IDENTICAL semantic content** at any given point (tau, t).

This means MF and TF are semantically equivalent (they are valid in exactly the same models).

---

## 3. The Frame Condition: What Does ShiftClosed Mean?

### 3.1 ShiftClosed as a Group Action Property

ShiftClosed(Omega) says: for all sigma in Omega and all Delta in D, time_shift(sigma, Delta) in Omega.

This means: the additive group (D, +) acts on the set of world histories via time-shifting, and Omega is **closed under this action** (i.e., Omega is a union of orbits, or equivalently, Omega is invariant under the group action).

More precisely, define the action:
- For Delta in D, define T_Delta : WorldHistory(F) -> WorldHistory(F) by T_Delta(sigma) = time_shift(sigma, Delta)
- ShiftClosed(Omega) says: for all Delta, T_Delta(Omega) subset Omega
- Since T_{-Delta} is the inverse of T_Delta (up to history equality), this is equivalent to: for all Delta, T_Delta(Omega) = Omega

### 3.2 ShiftClosed Implies MF and TF

The codebase proves (Soundness.lean lines 260-273) that ShiftClosed(Omega) implies both MF and TF are valid. The proof mechanism:

1. Given Box(phi) at time t: phi holds at all sigma in Omega at time t
2. For any sigma in Omega and s > t, consider time_shift(sigma, s-t) in Omega (by ShiftClosed)
3. By the time-shift truth preservation lemma: phi at (time_shift(sigma, s-t), t) iff phi at (sigma, s)
4. Since time_shift(sigma, s-t) in Omega, Box(phi) at t gives phi at (time_shift(sigma, s-t), t)
5. Therefore phi at (sigma, s)

### 3.3 Is ShiftClosed EXACTLY What MF+TF Require?

**ShiftClosed is STRONGER than what MF+TF require for validity.**

Here is why:

**MF+TF only constrain formulas that begin with Box.** They say: "if something holds at ALL histories at a given time, then it holds at all histories at all future/past times." This is a condition about **uniform truth across all of Omega at a time**.

ShiftClosed provides a much stronger structural guarantee: **every individual history can be shifted to any time offset, and the result stays in Omega**. This is a per-history, per-offset closure condition.

**Counterexample showing ShiftClosed is strictly stronger:**

Consider D = Z (integers), and a frame where Omega = {tau_0, tau_1} with exactly two histories. Suppose:
- tau_0 and tau_1 agree on all atoms at every time (i.e., they have the same domain and the same states at every time)

Then MF and TF are trivially valid for this Omega (since all histories agree, Box(phi) at time t means phi at (tau_0, t) and phi at (tau_1, t), and since they agree at all times, phi holds at both histories at all times).

But ShiftClosed may fail: time_shift(tau_0, 1) might be neither tau_0 nor tau_1 (it's a different history object), so it might not be in Omega.

However, this counterexample is somewhat degenerate because the shifted history is "observationally equivalent" to a history in Omega. The real question is whether there are cases where ShiftClosed fails, yet the truth conditions for MF/TF are still satisfied.

**A more illuminating analysis:** ShiftClosed is used in the truth preservation lemma (`time_shift_preserves_truth`) not just for MF/TF, but crucially for the **Box case** of the induction. When proving truth preservation for Box(psi), we need: if sigma in Omega, then time_shift(sigma, Delta) in Omega. This is needed to establish that the bijection T_Delta : Omega -> Omega is well-defined.

So ShiftClosed is the **semantic condition that makes time-shift a truth-preserving automorphism for the Box modality**. It's stronger than just MF+TF because:

1. It works for ALL formulas (not just atomic ones)
2. It works for ALL time offsets (not just future ones)
3. It ensures a structural bijection, not just truth-value agreement

### 3.4 Precise Frame Condition for MF+TF

The exact frame condition for MF+TF validity (in the abstract bimodal Kripke frame of Section 2.1) is:

> For any phi, if phi is true at all points (sigma, t) with sigma in Omega (i.e., at the entire time-t slice), then phi is true at all points (sigma, s) with sigma in Omega and s > t (i.e., at all future time slices).

This is a **semantic condition on Omega** (it talks about truth of formulas, not just frame structure). By the Sahlqvist theory, first-order frame conditions correspond to modal axioms, but MF and TF are not standard Sahlqvist formulas in the bimodal language because:

1. The "frame" is not a standard Kripke frame (it has product structure)
2. The axioms mix the two modalities in a non-Sahlqvist pattern

In the **product frame** setting (Gabbay et al. 2003), MF corresponds to the condition:

> **Left commutativity**: R_Box ; R_G subset R_Box

But as shown in Section 2.2.2, this is unsatisfiable for nonempty R_G with standard same-time R_Box. The resolution is that TM semantics does NOT use a standard product frame: the time-shift mechanism creates a non-standard interaction.

**The correct first-order frame condition (in the product frame language) is:**

> For all time slices T_t = {(sigma, t) | sigma in Omega} and T_s = {(sigma, s) | sigma in Omega} with t < s, there exists a **bijection** f: T_t -> T_s such that for any formula phi, phi is true at (sigma, t) iff phi is true at f(sigma, t).

ShiftClosed provides exactly such a bijection (namely, f = T_{s-t}), but it is stronger because it specifies a CANONICAL bijection with additional structural properties (preservation of the task relation, domain shifting, etc.).

---

## 4. Relationship Between AddCommGroup and MF/TF

### 4.1 What Algebraic Structure Does the Proof Actually Use?

Examining the soundness proof for MF/TF, the key ingredients are:

1. **time_shift construction**: Needs `z + Delta` to be well-defined -> requires addition
2. **time_shift_preserves_truth (atom case)**: Uses `x + (y - x) = y` -> requires group axioms (subtraction)
3. **time_shift_preserves_truth (box case)**: Uses ShiftClosed, which requires time_shift for arbitrary Delta, and the double-shift cancellation `time_shift(time_shift(sigma, Delta), -Delta) = sigma` -> requires inverse (negation)
4. **time_shift_preserves_truth (past/future cases)**: Uses `s < t iff s - (y-x) < t - (y-x)` -> requires order-compatibility with addition
5. **Commutativity**: The proof uses `x + (y - x) = y`, `add_sub_cancel`, etc., which rely on commutativity of addition

### 4.2 Can We Weaken the Algebraic Structure?

**Ordered monoid (addition but no subtraction)?**

NO. The time_shift construction fundamentally requires subtraction: `time_shift sigma (s - t)` computes s - t. The truth preservation proof uses the identity `t + (s - t) = s`, which requires group cancellation. Without inverses, we cannot define the shift offset `s - t`.

Moreover, the box case of time_shift_preserves_truth requires the INVERSE shift `time_shift(sigma, -(s-t))` to establish the backward direction of the bijection. This requires negation.

**Ordered group (not necessarily commutative)?**

MOSTLY YES, but with care. The proof uses:
- `add_sub_cancel_left`, `add_sub_cancel_right` -- these assume commutativity
- `add_comm` explicitly in the time_shift construction (convexity proof, respects_task proof)
- `add_sub, add_sub_cancel_left` in the truth preservation lemma

In a non-commutative group, `x + (y - x)` would be `x + (y + (-x))`, which is NOT necessarily `y`. So the fundamental identity breaks.

However, if we formulate time-shifting as a RIGHT action (or consistently use left/right conventions), a non-commutative group could work. The key identity needed is: shifting by `s - t` and evaluating at `t` gives the same as evaluating the original at `s`. This requires `t + (s - t) = s`, which in a non-commutative group would need `s - t` defined as `(-t) + s` (left difference) rather than `s + (-t)` (right difference).

**Conclusion**: Commutativity is used for convenience and cleanliness, but a non-commutative ordered group could in principle suffice with a more careful formulation of time_shift. The essential requirement is:

> **(D, +, <=) is an ordered group (not necessarily abelian)** with a well-defined time-shift that satisfies `eval(shift(sigma, d), t) = eval(sigma, t + d)` and the group law `t + (s - t) = s` for the chosen convention of subtraction.

**Just a set with a group action on world histories?**

YES, in principle. The most abstract formulation would be:

> Let G be a group acting on the set of world histories, and let D be a linearly ordered set. If there is a compatible G-action on D (i.e., G acts on D by order-preserving bijections, and the history shift is compatible with the temporal shift), then ShiftClosed holds and MF+TF are valid.

The AddCommGroup structure on D bundles two roles:
1. D is the temporal order (linear order)
2. D is the group that acts on histories via time-shift

These could in principle be separated: have an external group G acting on both the time domain and the history space. But in TM, D itself IS the group, which is the simplest and most natural choice.

### 4.3 Is AddCommGroup the WEAKEST Structure?

**No.** AddCommGroup is NOT the weakest structure that validates MF+TF. As shown above:

- A non-commutative ordered group would suffice
- An abstract group action could suffice
- Even without group structure, if Omega happens to satisfy the "uniform truth preservation across time slices" condition, MF+TF hold

**But AddCommGroup IS the weakest NATURAL structure** for the TM paper's framework, where:
1. Time differences `t - s` must be well-defined (group)
2. The temporal order must be compatible (ordered group)
3. Time-shift must be unambiguous regardless of direction (commutativity)
4. The paper explicitly specifies a "totally ordered abelian group" (matching AddCommGroup + LinearOrder + IsOrderedAddMonoid)

---

## 5. Can MF/TF Be Validated Without Group Structure?

### 5.1 The Minimal Semantic Condition

MF and TF are valid over (F, M, Omega) at time t iff:

> For all phi: if phi is true at all (sigma, t) with sigma in Omega, then phi is true at all (sigma, s) with sigma in Omega and s > t.

This is equivalent to:

> **For every t < s, the truth sets at the time-t slice and time-s slice are "equivalent."**

More precisely, define the truth profile at time t as the function:
```
Profile_t : Omega -> (Formula -> Prop)
Profile_t(sigma) = lambda phi => truth_at M Omega sigma t phi
```

MF+TF hold iff: for all t < s, for all phi, (for all sigma, Profile_t(sigma)(phi)) -> (for all sigma, Profile_s(sigma)(phi)).

This is equivalent to:

> **The multiset of truth profiles {Profile_t(sigma) | sigma in Omega} is "monotonically weakening" as t increases.** Specifically, every property that is UNIVERSAL at time t remains universal at time s > t.

### 5.2 ShiftClosed Implies Profile Equivalence

ShiftClosed provides something much stronger: it gives a BIJECTION T_{s-t}: Omega -> Omega such that Profile_t(sigma) = Profile_s(T_{s-t}(sigma)) for all sigma and phi. This means the multiset of profiles at each time is IDENTICAL (not just weakening).

### 5.3 Frame Conditions Without Group Structure

In a pure Kripke frame (W, R_Box, R_G) where:
- R_G is irreflexive, transitive, and linear (within each R_Box-equivalence class)
- R_Box is an equivalence relation

MF ([Box]p -> [Box][G]p) corresponds to the first-order condition:

> for all w, w', w'': w R_Box w' and w' R_G w'' implies w R_Box w''

That is: **R_Box is forward-closed under R_G** (equivalently, R_Box ; R_G subset R_Box).

This is NOT the standard commutativity condition R_Box ; R_G subset R_G ; R_Box, but rather a STRONGER condition that says the R_Box-equivalence classes are closed under moving forward in time.

Similarly, TF ([Box]p -> [G][Box]p) corresponds to:

> for all w, w': w R_G w' implies (for all w'': w R_Box w'' implies w' R_Box w'')

That is: **R_G preserves R_Box-equivalence classes** (if w and w'' are R_Box-related, and w R_G w', then w' and any point at time t(w') R_Box-related to something R_G-accessible from w'' are related).

Given that R_Box relates all points at the same time, BOTH conditions reduce to:

> **All time slices have the same "size" (cardinality of Omega-restricted time slice) and the SAME truth profile multiset.**

This is a semantic condition, not a first-order frame condition. The axioms MF and TF are NOT Sahlqvist in the product frame.

---

## 6. Comparison: ShiftClosed vs. MF+TF Validity

| Property | ShiftClosed | MF+TF Validity |
|----------|-------------|----------------|
| Structural level | Per-history, per-offset | Per-formula, per-time-pair |
| Quantifier structure | forall sigma, Delta: shift(sigma,Delta) in Omega | forall phi, t, s: uniform truth preserved |
| Requires group structure | Yes (needs Delta = s - t) | No (can be stated without group) |
| Requires bijection between time slices | Yes (canonical bijection via shift) | No (only requires truth preservation) |
| Preserved under model restriction | Not necessarily | Yes (if Omega' subset Omega satisfies it) |
| Implies time_shift_preserves_truth | Yes (used in proof) | Not directly |
| Standard in correspondence theory | No (specific to TM) | Partially (related to product frame conditions) |

**Key finding**: ShiftClosed is strictly stronger than MF+TF validity. ShiftClosed is the condition that makes the GENERAL time-shift truth preservation lemma work (which is needed for ALL temporal reasoning, not just MF+TF). MF+TF are consequences of this more general property.

---

## 7. Literature Context

### 7.1 Product Modal Logics (Gabbay, Kurucz, Wolter, Zakharyaschev 2003)

In the theory of products of modal logics, two key interaction axioms are:

- **com** (commutativity): [1][2]p -> [2][1]p, corresponding to: R_1;R_2 subset R_2;R_1 (confluence/Church-Rosser)
- **chr** (Church-Rosser): <1>[2]p -> [2]<1>p, corresponding to: R_1^{-1};R_2 subset R_2;R_1^{-1}

MF and TF are NOT instances of com or chr. Instead:
- MF is [Box]p -> [Box][G]p, which is more like a "monotonicity" or "persistence" axiom
- TF is [Box]p -> [G][Box]p, similarly

In the product logic literature, MF would correspond to: R_Box ; R_G subset R_Box (the modal equivalence classes grow when moving forward in time). TF would correspond to: R_G ; R_Box subset R_Box ; R_G... but actually both MF and TF have the same semantic content (Section 2.3).

### 7.2 T x W Frames (Thomason 1984, Zanardo 1990, Di Maio & Zanardo 1998)

The T x W framework combines tense and modal logic on branching time structures. Key points:

- T x W frames have moments ordered by < and histories (maximal chains)
- The modal operator quantifies over histories passing through a given moment
- Interaction axioms like P(phi) -> Box(P(phi)) ("necessity of the past") are studied

The TM framework differs from T x W in that:
- Histories are NOT branches of a tree; they are independent functions
- The modal accessibility is NOT determined by "passing through the same moment"
- Time-shift provides a group action absent from T x W

### 7.3 Finger & Gabbay (1992) on Combining Temporal and Modal Logics

Finger and Gabbay study "temporalization" -- adding temporal structure to a logic. Their framework includes interaction axioms between the temporal and non-temporal modalities. However, their interaction axioms are typically of the "commutativity" form, not the "persistence" form of MF/TF.

---

## 8. Conclusions and Recommendations

### 8.1 Summary of Findings

1. **MF and TF are semantically equivalent**: Both express "Box-truth at time t implies Box-truth at all future times s > t." They differ only in syntactic quantifier order.

2. **ShiftClosed is strictly stronger than MF+TF**: ShiftClosed provides a per-history structural bijection between time slices, while MF+TF only require truth-value agreement at the universal level.

3. **The frame condition for MF+TF is non-standard**: It is NOT a first-order Sahlqvist condition on a standard Kripke frame. In the product frame, it corresponds to R_Box;R_G subset R_Box (modal classes are forward-closed), but this condition is trivially unsatisfiable for standard same-time R_Box with nonempty R_G. The resolution is that TM uses time-shift as a non-standard mechanism.

4. **AddCommGroup is not the weakest structure**: A non-commutative ordered group would suffice. Even more abstractly, any group action on histories compatible with temporal ordering would work. But AddCommGroup is the natural choice for the paper's framework.

5. **ShiftClosed is necessary for the general architecture**: While MF+TF could hold without ShiftClosed, the broader TM semantics (particularly the time_shift_preserves_truth lemma used throughout soundness) requires ShiftClosed. It is the right condition for the overall logical framework, not just for MF+TF.

### 8.2 Implications for the Codebase

- **ShiftClosed is correctly placed in validity**: The definition of `valid` quantifies over ShiftClosed Omega, which is the right semantic condition for the full TM logic (not just MF+TF).
- **No weakening is possible without restructuring**: To weaken ShiftClosed to "just MF+TF validity," one would need to restructure the entire truth preservation machinery. This is not advisable.
- **AddCommGroup can potentially be weakened**: If future work requires non-abelian time domains, the time_shift construction could be adapted. But for the current scope (Int, Rat, Real), AddCommGroup is correct and sufficient.

### 8.3 Relationship to Task 117

For the model construction on limit domains (task 117's main goal), the key insight is:
- ShiftClosed is the semantic glue that makes MF+TF valid
- Any model construction must ensure the constructed Omega is ShiftClosed
- The AddCommGroup structure on D provides the group action needed for ShiftClosed
- When building models on limit domains, the challenge is ensuring ShiftClosed holds for the specific Omega constructed during completeness proofs

---

## Appendix A: Proof Sketch for MF+TF Semantic Equivalence

**Claim**: For any (M, Omega, tau, t), truth_at M Omega tau t (Box(phi) -> Box(G(phi))) iff truth_at M Omega tau t (Box(phi) -> G(Box(phi))).

**Proof**: Both sides have the same antecedent (Box(phi) at (tau, t)). For the consequent:

Box(G(phi)) at (tau, t)
= forall sigma in Omega, forall s > t, phi(sigma, s)
= forall s > t, forall sigma in Omega, phi(sigma, s)  [quantifier swap]
= forall s > t, Box(phi) at (tau, s)  [note: Box does not depend on tau]
= G(Box(phi)) at (tau, t)

The key step is that universal quantifiers commute. QED.

## Appendix B: Search Queries and Sources

### Codebase Files Examined
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- MF, TF axiom definitions (lines 326-329)
- `Theories/Bimodal/Semantics/Truth.lean` -- truth_at, ShiftClosed, time_shift_preserves_truth
- `Theories/Bimodal/Semantics/Validity.lean` -- valid definition
- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame structure
- `Theories/Bimodal/Semantics/WorldHistory.lean` -- WorldHistory, time_shift
- `Theories/Bimodal/Metalogic/Soundness.lean` -- modal_future_valid, temp_future_valid (lines 259-273)
- `Theories/Bimodal/FrameConditions/` -- parameterized validity, soundness, compatibility

### Literature References
- Gabbay, Kurucz, Wolter, Zakharyaschev (2003). Many-Dimensional Modal Logics: Theory and Applications. Elsevier.
- Thomason (1984). Combinations of Tense and Modality. Handbook of Philosophical Logic.
- Di Maio & Zanardo (1998). A Gabbay-Rule Free Axiomatization of T x W Validity. J. Philosophical Logic.
- Finger & Gabbay (1992). Adding a Temporal Dimension to a Logic. J. Logic, Language and Information.
- Sahlqvist (1975). Completeness and correspondence in the first and second order semantics for modal logic.
- Venema (1993). Temporal Logic survey.
- Burgess (1982/84). Until-Since temporal logic axiomatization.
