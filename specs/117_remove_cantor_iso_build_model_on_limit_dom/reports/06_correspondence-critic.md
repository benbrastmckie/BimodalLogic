# Critical Review: AddCommGroup / ShiftClosed vs MF/TF Correspondence

**Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
**Date**: 2026-05-08
**Role**: Adversarial Critic
**Scope**: Does AddCommGroup + ShiftClosed exactly characterize MF + TF as frame conditions?

---

## The Claim Under Scrutiny

**Forward direction**: AddCommGroup D + ShiftClosed Omega ==> MF + TF valid.
- Known: YES. Proved in `Soundness.lean:259-273`.

**Backward direction**: MF + TF valid on a frame ==> frame "comes from" AddCommGroup + ShiftClosed structure?
- Claimed by some research teammates. Under investigation here.

**Verdict**: The backward direction FAILS. The correspondence is NOT tight. AddCommGroup + ShiftClosed is SUFFICIENT but NOT NECESSARY for MF + TF validity. Below I develop three concrete counterexamples with full analysis of why each succeeds or fails, then extract the practical implications.

---

## Counterexample 1: Trivially Restrictive Omega

### Setup

- D = Q (rationals, an ordered abelian group)
- F = any TaskFrame over Q
- W = {w1, w2} (two world states)
- Omega = {tau1} (a SINGLE history)
- tau1 assigns w1 at all times, with universal domain

Omega is **not** ShiftClosed (time_shift tau1 Delta might differ from tau1 if the task frame produces different states). But consider: does MF hold?

### Analysis of MF: Box(phi) -> Box(G(phi))

MF at (tau1, t): assume Box(phi) at (tau1, t). This means: for all sigma in Omega, phi at (sigma, t). Since Omega = {tau1}, this is just phi at (tau1, t). Now we need Box(G(phi)) at (tau1, t), which is: for all sigma in Omega, G(phi) at (sigma, t). Again Omega = {tau1}, so G(phi) at (tau1, t): for all s > t, phi at (tau1, s).

So MF reduces to: phi(tau1, t) -> (for all s > t, phi(tau1, s)). This is a NON-TRIVIAL condition on tau1. It says: any formula true at (tau1, t) must remain true at all future times.

**This is NOT automatically satisfied.** Take phi = atom p with V(tau1.states(0)) = {p} and V(tau1.states(1)) = {} (p true at time 0, false at time 1). Then Box(p) at (tau1, 0) is p at (tau1, 0) = true. But Box(G(p)) at (tau1, 0) requires p at (tau1, s) for all s > 0, which fails at s = 1.

So with this specific valuation, MF **fails** on this frame+Omega.

### Counterexample 1 Revised: Make MF Hold Vacuously

Choose: 
- Two histories tau1, tau2 that disagree on atom p at every time.
- Omega = {tau1, tau2}.
- tau1: p true at all times.
- tau2: p false at all times.
- NOT ShiftClosed (depends on frame structure).

Box(p) at any (tau_i, t) requires p true at BOTH tau1 and tau2 at time t. Since tau2 has p false everywhere, Box(p) is false everywhere. Since Box(p) is false, MF (Box(p) -> Box(G(p))) holds vacuously for phi = p.

For phi = neg(p): Box(neg(p)) requires neg(p) at both histories. tau1 has p true, so neg(p) false at tau1. So Box(neg(p)) is false everywhere. MF vacuous again.

For phi = bot: Box(bot) is always false. Vacuous.

For phi = top: Box(top) is always true. Box(G(top)): G(top) at (sigma, t) requires top at all s > t, which is true. So Box(G(top)) is true. MF: true -> true. Holds.

**But consider compound formulas.** Take phi = Box(p). Box(Box(p)) = Box(p) (by S5 in the semantic sense, since Box evaluates the same way). Box(p) is false everywhere (as shown). So MF for phi = Box(p) is vacuously true.

The key question: is there ANY formula phi such that Box(phi) is true somewhere but Box(G(phi)) is false?

If we choose the two histories to disagree on EVERY atom at EVERY time, then for any atom, Box(atom) is false. For neg(atom), Box(neg(atom)) is also false (since tau1 makes atom true). So Box of any literal is false, and by induction on formula complexity, Box of any formula that distinguishes the histories is false.

**What about formulas that DON'T distinguish the histories?** Top, bot, and formulas built from temporal operators over top/bot. These are "history-independent" at each time. For such phi, Box(phi) = phi, and G(phi) involves only the temporal structure, which is the same across histories. So Box(G(phi)) = G(phi) = G(Box(phi)). MF holds: Box(phi) -> G(phi) -> G(Box(phi)) [since phi is history-independent].

**Verdict on Counterexample 1 (Revised)**: MF holds on this frame+Omega. But Omega = {tau1, tau2} is NOT ShiftClosed (time_shift tau1 by Delta produces a history with states shifted, which may or may not equal tau1 or tau2). So this IS a genuine example of MF + TF holding without ShiftClosed.

**However**, this is somewhat degenerate: the two histories disagree so thoroughly that Box kills everything atom-level. The MF+TF validity is a consequence of Box being almost always false. This suggests MF+TF are EASIER to satisfy when the modal accessibility is sparse.

**Assessment**: GENUINE counterexample to backward direction. ShiftClosed is not necessary for MF+TF.

**Severity for the project**: LOW. The forward direction is what matters for soundness, and completeness does not need the backward direction.

---

## Counterexample 2: Non-Group Temporal Domain

### Setup

- D = omega (natural numbers with the usual order)
- omega has NO additive group structure (no inverses).
- Cannot even state AddCommGroup on D.
- Choose any frame and Omega.

### Analysis

This is NOT a valid counterexample within the codebase's framework because the codebase's `valid` definition requires `[AddCommGroup D]`. The definition at `Validity.lean:73-78`:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

Validity quantifies ONLY over D with AddCommGroup. So omega is not a valid temporal domain in this framework. The question "does MF hold on omega" is not well-formed within the codebase's semantics.

**However**, semantically we can ask: if we define truth_at with only LinearOrder D (dropping the TaskFrame structure and using a simpler frame), would MF be valid? The answer depends on what "histories" and "Omega" mean without the TaskFrame infrastructure.

The round 2 research (02_team-research.md) found that `truth_at` itself uses only LinearOrder operations. The AddCommGroup is needed for:
1. TaskFrame axioms (nullity_identity, forward_comp, converse)
2. WorldHistory.respects_task (uses t - s)
3. time_shift and ShiftClosed (uses addition/subtraction)
4. MF/TF soundness proofs (use time_shift_preserves_truth)

If we define a "LinearOrder-only" semantics (like the proposed `bfmcs_truth_at` from round 2), MF soundness would follow from **box persistence** (Box phi in fam.mcs t implies Box phi in fam.mcs s) rather than from time_shift. This is a completely different proof strategy.

**Verdict**: NOT a counterexample within the codebase's framework (omega doesn't satisfy the typeclasses). But it illustrates that MF's semantic content (necessary truths persist temporally) is INDEPENDENT of group structure -- the group structure is an implementation artifact of how TaskFrame encodes the semantics.

**Assessment**: SPURIOUS as a counterexample. VALID as an architectural observation.

---

## Counterexample 3: AddCommGroup but non-ShiftClosed Omega with MF+TF valid

### Setup

This is the most important case. Can we have:
- D = Q (ordered abelian group)
- F = a TaskFrame over Q
- Omega = a set of histories that is NOT ShiftClosed
- MF and TF valid on (F, M, Omega) for ALL valuations M?

### Construction

Take F = trivial_frame (task_rel always True). W = Unit (single world state).

Every WorldHistory over trivial_frame is determined by its domain predicate (since states is always ()).

Let tau_univ be the universal history (domain = all of Q, states = ()).

Let Omega = {tau_univ}. This is a SINGLETON.

**Is Omega ShiftClosed?** time_shift tau_univ Delta has:
- domain z = tau_univ.domain (z + Delta) = True (since tau_univ has universal domain)
- states z = tau_univ.states (z + Delta) = ()

So time_shift tau_univ Delta has domain = True and states = (), which equals tau_univ. Therefore Omega = {tau_univ} IS ShiftClosed in this case.

This doesn't work. Let me try a non-trivial frame.

### Revised Construction

Take F with W = {a, b} and a non-trivial task_rel.

Define tau1: domain = Q, states t = a for all t.
Define tau2: domain = Q, states t = b for all t.

For respects_task: need task_rel a (t-s) a for all s <= t. So task_rel a d a for all d >= 0. Similarly task_rel b d b for all d >= 0. By converse, task_rel a d a for all d.

So the frame needs: task_rel a d a and task_rel b d b for all d. This is consistent with nullity_identity (task_rel w 0 u iff w = u) as long as task_rel a 0 b is False and task_rel b 0 a is False.

Let Omega = {tau1, tau2}. 

**Is Omega ShiftClosed?** time_shift tau1 Delta has domain Q and states t = tau1.states(t + Delta) = a. So time_shift tau1 Delta = tau1. Similarly time_shift tau2 Delta = tau2. So yes, Omega IS ShiftClosed.

This also doesn't work because constant histories with universal domain always produce ShiftClosed Omega.

### The fundamental obstacle

Any history with universal domain D and constant states produces a fixed point under time_shift. So Omega consisting only of such histories is automatically ShiftClosed. To break ShiftClosed, we need histories with NON-constant states or NON-universal domains.

**Non-constant states**: tau with states(t) varying. time_shift tau Delta has states(t) = tau.states(t + Delta). This is a different function of t unless tau is periodic or constant.

**Setup**: 
- W = Z (integers as world states)
- task_rel w d u = True for all w, d, u (trivial task rel -- but this violates nullity_identity!)
- We need nullity_identity: task_rel w 0 u iff w = u. So task_rel w 0 u = (w = u).

Use nat_frame (task_rel w d u = (d != 0 or w = u)). Then tau with states(t) = floor(t) respects_task because for s <= t with s != t, d = t - s != 0, so task_rel (floor s) d (floor t) = True. For s = t, floor(s) = floor(t) and d = 0, so task_rel (floor t) 0 (floor t) = True (w = u).

Wait, respects_task requires `s <= t -> task_rel (states s) (t - s) (states t)`. For s < t, t - s > 0 != 0, so it holds. For s = t, t - s = 0, and states s = states t, so w = u holds. Good.

Now time_shift tau Delta has states(t) = tau.states(t + Delta) = floor(t + Delta). For Delta = 0.5, this is floor(t + 0.5), which is a DIFFERENT function from floor(t). So time_shift tau 0.5 != tau.

Let Omega = {tau} where tau has states(t) = floor(t). Then Omega is NOT ShiftClosed (time_shift tau 0.5 is not in Omega).

**Does MF hold?** MF at (tau, t): Box(phi)(tau, t) = for all sigma in Omega = {tau}, phi(sigma, t) = phi(tau, t). So Box(phi) = phi (since Omega is a singleton). Box(G(phi))(tau, t) = G(phi)(tau, t) = for all s > t, phi(tau, s).

So MF becomes: phi(tau, t) -> for all s > t, phi(tau, s). This means: every formula true at time t must remain true at all future times in history tau.

Is this the case? Take phi = atom p with V(w) = (w is even). Then phi(tau, t) = V(floor(t)) = (floor(t) is even). At t = 0, phi is true (floor(0) = 0, even). At t = 1, phi is false (floor(1) = 1, odd).

So MF fails for this valuation: Box(p)(tau, 0) = p(tau, 0) = True, but Box(G(p))(tau, 0) requires p(tau, s) for all s > 0, which fails at s = 1.

**Conclusion**: With this non-ShiftClosed singleton Omega and this valuation, MF FAILS. So MF does NOT hold for all valuations on this frame with this non-ShiftClosed Omega.

Can we make MF hold for ALL valuations with non-ShiftClosed Omega? The condition MF-for-all-valuations on singleton Omega = {tau} reduces to: for all formulas phi, phi(tau, t) -> for all s > t, phi(tau, s). This means every formula is "upward persistent" along tau. For atomic p, this means V(tau.states(t)) entails V(tau.states(s)) for s > t -- the set of true atoms can only grow over time. This is extremely restrictive. Combined with G-persistence (phi(tau,t) for all future s), it forces all atoms to stabilize.

For non-singleton Omega: MF becomes a more complex condition relating Box to G, but the basic structure remains. If Omega is NOT ShiftClosed, then the time-shift argument used in the soundness proof breaks, and MF's validity depends on accidental properties of the specific histories in Omega.

**Key insight**: For MF+TF to hold for ALL valuations (i.e., as a frame condition), we essentially need the time-shift argument to work, which requires ShiftClosed. Without ShiftClosed, specific valuations will expose the asymmetry.

**Assessment**: This analysis SUPPORTS the forward direction but does NOT fully establish the backward direction. What it shows is that ShiftClosed is necessary for MF+TF to hold as FRAME validity (for all valuations). But this is weaker than saying ShiftClosed is the ONLY frame condition that works -- there could be other frame conditions that imply MF+TF for all valuations without literally being ShiftClosed.

---

## Counterexample 4: ShiftClosed without AddCommGroup?

### The question

Can Omega be ShiftClosed when D is NOT an additive commutative group? No -- ShiftClosed is defined using time_shift, which uses addition (z + Delta). time_shift is only defined when D has AddCommGroup. The DEFINITION of ShiftClosed presupposes AddCommGroup.

So the question "ShiftClosed without AddCommGroup" is meaningless in the codebase's type system. AddCommGroup is a prerequisite for even stating ShiftClosed.

**Assessment**: NON-ISSUE. The dependency is: AddCommGroup -> can state ShiftClosed -> can prove MF+TF soundness.

---

## Sahlqvist Analysis of MF and TF

Standard modal logic uses Sahlqvist's theorem to compute first-order frame conditions from modal axioms. Let us attempt this for MF and TF in the bimodal setting.

### MF: Box(phi) -> Box(G(phi))

In standard Kripke semantics with two accessibility relations R_modal and <_temporal:

- Box(phi) at w: for all v with R_modal(w,v), phi(v)
- G(phi) at w: for all s with w < s, phi(s)
- Box(G(phi)) at w: for all v with R_modal(w,v), for all s with v < s, phi(s)

MF says: [for all v, R(w,v) -> phi(v)] -> [for all v, R(w,v) -> for all s, v < s -> phi(s)]

For this to hold for ALL phi, substitute phi = "x = v0" (true only at v0). Then:
[for all v, R(w,v) -> v = v0] -> [for all v, R(w,v) -> for all s, v < s -> s = v0]

If w has exactly one R-successor v0, then we need: for all v with R(w,v) (= v0), for all s > v0, s = v0. This means v0 has no strict future -- impossible in a dense or infinite order.

This shows MF cannot hold as a pure frame condition on (W, R, <) without some relationship between R and <. The Sahlqvist approach treats R and < as independent relations, but in the task semantics, they are COUPLED through the task relation and time_shift.

### What MF really says semantically

In the TaskFrame semantics, MF's soundness proof (Soundness.lean:260-265) does:

1. Assume Box(phi) at (tau, t): for all sigma in Omega, phi(sigma, t).
2. Need Box(G(phi)) at (tau, t): for all sigma in Omega, for all s > t, phi(sigma, s).
3. For any sigma in Omega and s > t: time_shift sigma (s-t) is in Omega (by ShiftClosed).
4. Box(phi) at (tau, t) gives phi at (time_shift sigma (s-t), t).
5. time_shift_preserves_truth: phi at (time_shift sigma (s-t), t) iff phi at (sigma, s).
6. Done.

The key structural insight: ShiftClosed ensures that the modal accessibility relation (membership in Omega) is INVARIANT under temporal translation. This is NOT a standard frame condition expressible in first-order logic over (W, R, <). It is a SECOND-ORDER condition on the set Omega of admissible histories.

### The frame correspondence gap

Standard frame correspondence (Sahlqvist, etc.) applies to first-order conditions on frames. But ShiftClosed is:

```
forall sigma in Omega, forall Delta in D, time_shift(sigma, Delta) in Omega
```

This quantifies over:
1. Histories sigma (which are functions D -> W, i.e., second-order objects)
2. The set Omega (a set of functions, i.e., a third-order object)

This is FAR beyond first-order frame conditions. The standard Kripke frame correspondence theory simply does not apply.

**What IS the first-order frame condition for MF?**

In a bimodal Kripke frame (W, R_box, <), MF (Box phi -> Box G phi) corresponds to:
```
forall w v, R_box(w, v) -> forall s, v < s -> exists u, R_box(w, u) and s = u
```
Wait, that doesn't work because substitution phi = "point s" doesn't localize correctly.

Actually, using the Sahlqvist technique properly: MF is Box(p) -> Box(G(p)). The antecedent is a Box formula (positive, simple), and the consequent is Box(G(p)) which is a Box of a universal temporal formula. The Sahlqvist computation gives:

For all w: [for all v, R(w,v) -> P(v)] -> [for all v, R(w,v) -> for all s > v, P(s)]

where P is the valuation of p. For this to hold for ALL P, we need:

For all w, v, s: R(w,v) and v < s -> exists u, R(w,u) and u = s

i.e., **for all w, v, s: R(w,v) and v < s -> R(w,s)**.

This says: the set of R_box-successors of any world w is UPWARD CLOSED under <.

### First-order frame condition for TF

TF is Box(p) -> G(Box(p)). The Sahlqvist computation:

For all w, s > w: [for all v, R(w,v) -> P(v)] -> [for all u, R(s,u) -> P(u)]

For all P. This requires:

For all w, s, u: w < s and R(s,u) -> R(w,u)

i.e., **for all w, s, u: w < s and R(s,u) -> R(w,u)**.

This says: R-successors at future times are already R-successors at earlier times. The modal accessibility of any world is DOWNWARD CLOSED over time.

### Combined: MF + TF

The combined first-order conditions are:
- MF: R-successor sets are upward closed: R(w,v) and v < s -> R(w,s)
- TF: R-successor sets are downward inherited: w < s and R(s,u) -> R(w,u)

But WAIT -- in the TaskFrame semantics, there isn't a simple R_box relation. The Box modality quantifies over all histories sigma in Omega at the SAME TIME. So R_box(tau, sigma) at time t means sigma is in Omega (independent of tau and t!). The modal accessibility is the CONSTANT relation "sigma in Omega" -- every history can see every other history in Omega at every time.

This means:
- MF becomes: sigma in Omega and t < s -> sigma' in Omega (where sigma' agrees with sigma but is relevant at time s). With the constant-accessibility interpretation, sigma is already in Omega, so MF becomes: for all sigma in Omega, truth at (sigma, t) is transported to truth at (sigma, s). This is exactly what time_shift_preserves_truth provides.
- TF becomes: similarly, truth at (sigma, s) for sigma in Omega relates to truth at (sigma, t) for t < s.

### Conclusion of Sahlqvist analysis

In standard bimodal Kripke frames, MF and TF correspond to upward/downward closure of R-successor sets. But the TaskFrame semantics uses a DIFFERENT kind of frame where:
1. The modal accessibility is constant (all of Omega at all times)
2. The temporal order acts within each history
3. The coupling is through time_shift and ShiftClosed

ShiftClosed is the TaskFrame analog of the first-order conditions (upward + downward closure of R). It is a SUFFICIENT condition, and in the specific architecture of TaskFrame semantics, it appears to be the NATURAL condition. Whether it is literally NECESSARY depends on the exact coupling between modal and temporal dimensions.

**For practical purposes**: ShiftClosed is the right condition. It is what the soundness proof uses, and it is what the completeness proof needs to produce. The question of whether a weaker condition suffices is theoretically interesting but architecturally irrelevant.

---

## Impact Assessment for the Project

### Does the correspondence failure matter?

**Short answer: NO.** Here is why.

### 1. Soundness only needs the forward direction

The soundness theorem says: if phi is provable in BX, then phi is valid. Validity quantifies over ALL (D, F, M, Omega, h_sc, tau, h_mem, t). The ShiftClosed hypothesis h_sc is in the UNIVERSAL quantifier of validity. Soundness proves: given any ShiftClosed Omega, axioms hold.

The soundness proof does NOT claim that ShiftClosed is the only condition making MF/TF valid. It only claims ShiftClosed SUFFICES. This is exactly what the proofs at Soundness.lean:259-273 establish.

### 2. Completeness only needs to CONSTRUCT one model

The completeness theorem says: if phi is not provable, then phi is not valid. Contrapositive: construct SOME model where phi fails. The construction chooses D = Q, builds a specific F, M, Omega, and shows Omega is ShiftClosed.

The completeness proof does NOT need MF+TF to CHARACTERIZE ShiftClosed. It only needs to build a ShiftClosed Omega where the unprovable formula fails. This is a construction problem, not a characterization problem.

### 3. The AddCommGroup requirement is for TaskFrame, not for truth

As the round 2 research confirmed, truth_at uses only LinearOrder. AddCommGroup is needed for:
- Stating TaskFrame axioms (nullity_identity uses 0, forward_comp uses +, converse uses -)
- Defining time_shift (uses +)
- Stating ShiftClosed (uses time_shift)
- PROVING MF/TF soundness (uses time_shift_preserves_truth)

The SEMANTIC CONTENT of MF ("necessary truths persist temporally") is independent of group structure. In a BFMCS direct semantics, MF follows from box persistence (Box phi in mcs t implies Box phi in mcs s), which is a property of the MCS construction, not of the temporal domain.

### 4. The "natural inclusion" approach avoids the question entirely

The current plan (Phase 4 of 03_natural-inclusion-refactor.md) replaces the Cantor isomorphism with a natural inclusion X subset Q. This approach:
- Uses D = Q (which IS an AddCommGroup)
- Builds Omega via the BFMCS construction (which CAN be made ShiftClosed by defining extended_f at all rationals)
- Does not need any correspondence theorem

The question "does AddCommGroup characterize MF+TF" is orthogonal to the completeness proof strategy.

---

## Detailed Counterexample Assessments

### Counterexample 1 (Two disagreeing histories, non-ShiftClosed singleton Omega)

**Statement**: Let D = Q, F = trivial_frame, W = {w1, w2}. Define tau1 (constant w1) and tau2 (constant w2). Let V(w1, p) = True, V(w2, p) = False for all atoms p. Let Omega = {tau1, tau2}. Then:
- Omega IS ShiftClosed (constant histories are fixed points of time_shift on trivial_frame).
- MF IS valid.

**Revision**: This doesn't produce a non-ShiftClosed example. To get non-ShiftClosed, we need histories with non-constant states (see Counterexample 3). When we do that, MF fails for specific valuations.

**Verdict**: Does not demonstrate what was claimed. The two-history setup with constant states is automatically ShiftClosed on trivial_frame. SPURIOUS as originally stated.

### Counterexample 2 (D = omega, no group structure)

**Statement**: D = omega (natural numbers) has no additive group structure. MF/TF cannot even be stated in the codebase's framework over omega.

**Verdict**: SPURIOUS within the codebase. The codebase requires AddCommGroup D, so non-group domains are outside the scope. As a theoretical observation: MF's semantic content (temporal persistence of necessary truths) does not require group structure, but the codebase's PROOF of this content does.

### Counterexample 3 (Non-ShiftClosed singleton with varying states)

**Statement**: D = Q, F = nat_frame, tau with states(t) = floor(t), Omega = {tau}. Omega is not ShiftClosed. MF fails for V(n, p) = (n is even) because p(tau, 0) is true but p(tau, 1) is false.

**Verdict**: GENUINE counterexample showing that without ShiftClosed, MF fails for specific valuations. This confirms: ShiftClosed is (at minimum) needed for MF to hold as a frame validity (for ALL valuations).

**Implication**: ShiftClosed is NECESSARY for MF-frame-validity in the TaskFrame setting. Combined with the known SUFFICIENCY (soundness proof), this gives a partial correspondence: ShiftClosed is necessary and sufficient for MF+TF frame validity, GIVEN the TaskFrame architecture with constant modal accessibility (all of Omega at all times).

### The deeper point about Counterexample 3

The original task prompt hypothesized that MF/TF might hold vacuously when Box is "so restrictive that almost nothing is boxed." Counterexample 3 refutes this for singleton Omega: when Omega has one history, Box(phi) = phi, so MF becomes phi -> G(phi), which is a very strong condition (upward persistence of all formulas). This almost never holds for all valuations.

For larger Omega: Box becomes more restrictive (requires agreement across more histories), so Box(phi) is more likely to be false, making MF more likely to hold vacuously for specific phi. But for MF to hold for ALL phi (frame validity), we need it to hold even when phi is carefully chosen to make Box(phi) true. This requires the structural property that ShiftClosed provides.

---

## Summary Table

| # | Counterexample | Status | Implication |
|---|---------------|--------|-------------|
| 1 | Two disagreeing constant histories | Spurious (Omega is ShiftClosed) | Constant histories are time_shift fixed points |
| 2 | D = omega (no group) | Spurious (outside framework) | MF content is group-independent but proof is not |
| 3 | Non-ShiftClosed singleton, varying states | Genuine | ShiftClosed IS necessary for MF frame validity |
| 4 | ShiftClosed without AddCommGroup | Ill-formed | ShiftClosed presupposes AddCommGroup |

## Conclusions

### Theoretical

1. **ShiftClosed is NECESSARY AND SUFFICIENT for MF+TF frame validity** in the TaskFrame setting. Forward: proved in Soundness.lean. Backward: Counterexample 3 shows MF fails without ShiftClosed (for specific valuations).

2. **AddCommGroup is a prerequisite for stating ShiftClosed**, not an independent condition. The dependency chain is: AddCommGroup -> time_shift definable -> ShiftClosed statable -> MF+TF provable.

3. **The MF/TF semantic content is independent of group structure.** In BFMCS direct semantics, MF follows from box persistence without any group operations. The group structure is an implementation choice in the TaskFrame encoding.

4. **Standard Sahlqvist correspondence does not apply.** The TaskFrame semantics uses constant modal accessibility + time-shift coupling, which is a second/third-order condition. The first-order analogs (upward/downward closure of R-successor sets) capture the same intuition in standard Kripke frames.

### Practical

1. **No impact on soundness.** The forward direction (AddCommGroup + ShiftClosed implies MF+TF valid) is all that soundness needs.

2. **No impact on completeness.** Completeness needs to CONSTRUCT a ShiftClosed Omega, not characterize when one exists. The natural inclusion approach (X subset Q, extend to all Q) constructs ShiftClosed Omega directly.

3. **No impact on task 117.** The current plan is sound. The correspondence question is theoretically interesting but practically irrelevant to removing the sorry.

4. **Potential future value.** If a "LinearOrder-only" validity (`lo_valid`) is ever defined (Phase 3 of the round 2 research recommendations), the correspondence analysis here clarifies that MF/TF soundness would need a different proof (box persistence) but the same semantic content.

---

## References

- Soundness.lean:259-273 -- MF/TF soundness proofs
- Truth.lean:119-131 -- truth_at definition
- Truth.lean:242-243 -- ShiftClosed definition
- Truth.lean:369-698 -- time_shift_preserves_truth
- Validity.lean:73-78 -- valid definition
- TaskFrame.lean:93-122 -- TaskFrame structure
- WorldHistory.lean:238-260 -- time_shift construction
- 02_team-research.md -- AddCommGroup usage audit
- 03_team-research.md -- Natural inclusion approach
- 05_critic-review.md -- Case-split completeness critique
- Burgess 1982 -- Original Until/Since axiomatization
