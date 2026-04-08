# Teammate C: Critical Analysis -- Risks, Blockers, and Mathematical Correctness

- **Task**: 83 - Close Restricted Coherence Sorries
- **Role**: Critical analysis of chain-based approach
- **Date**: 2026-04-07
- **Session**: sess_1775625087_9b0bc5
- **Sources**: Reports 34-37, codebase (Frame.lean, CanonicalConstruction.lean, Truth.lean, Axioms.lean, Bundle/, Boneyard/ChainCompleteness/), Burgess 1982/84, Xu 1988, Goldblatt 1992

## Executive Summary

The chain construction is the mathematically correct path forward, but the project faces significant risks in three areas: (1) the half-open guard convention creates subtle but manageable boundary conditions that differ from Burgess's strict semantics, requiring careful treatment at every step; (2) the existing two completeness architectures (BXCanonical and Bundle) create a coherence debt that must be resolved before or during the chain implementation; (3) prior Boneyard attempts failed not from fundamental impossibility but from attempting to resolve eventualities within restricted MCS (DRM) rather than full MCS, a mistake the new approach must avoid. Dense extension is architecturally feasible but requires a fundamentally different construction (not a chain), and the user should plan for this from the start rather than retrofit.

---

## Part 1: Mathematical Correctness Risks

### Risk 1.1: Half-Open Guard vs Strict Semantics in Chain Construction

**Severity**: HIGH
**Status**: Manageable with care

The codebase uses reflexive Until with half-open guard:
```
phi U psi at t  <->  exists s >= t, psi(s) AND forall r in [t, s), phi(r)
```

Burgess's original proof (1984) uses strict semantics:
```
phi U psi at t  <->  exists s > t, psi(s) AND forall r in (t, s), phi(r)
```

**The critical difference for chain construction**: In Burgess's strict case, the witness s is strictly future (s > t), so there is always at least one intermediate point to serve as the guard interval. In the reflexive case, the witness can be the current time (s = t), making the guard interval [t, t) empty.

**Analysis of the two sub-cases**:

**Case s = t (reflexive witness)**: psi(t) holds, guard [t, t) is vacuously satisfied. No chain needed. This case is handled by BX8 (`psi -> phi U psi`), which is already proved sound. In the truth lemma: if psi is in w, then phi U psi is in w by BX8 membership. **No risk here.**

**Case s > t (strict witness)**: The guard is [t, s), which INCLUDES t. This means phi(t) must hold. The chain construction's seed at step 0 must include phi. From BX9 (`phi U psi -> phi OR psi`) and the assumption psi not in w, we get phi in w. **The seed does guarantee phi at t.** This is safe.

**However**: at the witness point s, the guard is OPEN (does not require phi(s)). This is where Burgess's proof and ours diverge. In the strict case, the guard (t, s) also does not require phi(s), so the structures are isomorphic. **The chain construction works identically for both conventions at every step** because:
- At step 0: phi is in the seed (from BX9)
- At intermediate step i (0 < i < witness): phi U psi is in the seed, psi is not yet witnessed, so BX9 gives phi
- At the witness step: psi is witnessed, phi is not required (guard is open at witness)

**Conclusion**: The half-open convention does NOT break the chain construction. The only difference is that the reflexive case (s = t) provides a trivial base case not present in Burgess. **Risk is manageable.**

**Mitigation**: Implement the truth lemma as a two-case split: (1) psi in w (trivial by BX8), (2) psi not in w (chain construction). Document the case split explicitly.

### Risk 1.2: The Backward Direction (bx_until_backward)

**Severity**: HIGH
**Status**: Requires careful argument, not chain-based

The backward direction asks: given v >= w, psi in v, guard phi on [w, v), derive phi U psi in w.

**Critical observation**: This direction does NOT use the chain construction at all. The chain construction is for the FORWARD direction (phi U psi in w implies existence of witness). The backward direction is a DERIVABILITY argument within w's MCS.

**The standard proof technique** (Burgess, Goldblatt):

1. Assume phi U psi not in w. Then neg(phi U psi) in w (MCS completeness).
2. By contrapositive of BX8: neg(phi U psi) implies neg(psi) (since psi -> phi U psi, contrapositive gives neg(phi U psi) -> neg(psi)).
3. So neg(psi) in w. Fine so far.
4. Now we need a contradiction. We have: v >= w, psi in v, phi on [w, v), but neg(phi U psi) in w.
5. From BX4: neg(phi U psi) -> G(P(neg(phi U psi))). So P(neg(phi U psi)) propagates to all points above w, including v.
6. P(neg(phi U psi)) in v: there exists u <= v with neg(phi U psi) in u.

**The gap in the abstract BXCanonical model**: We need u to satisfy w <= u to use it within the interval [w, v). But P(neg(phi U psi)) in v only gives u <= v, not w <= u. In the abstract (non-linear) g_content preorder, u could be "sideways" from w.

**In a chain construction**: If the chain is w = w_0 <= w_1 <= ... <= w_n = v (linear by construction), then u <= v means u = w_j for some j <= n. And w_0 <= w_j by the chain ordering. So w <= u follows from linearity. Then neg(phi U psi) in u with w <= u < v contradicts the guard (we have phi on [w, v) and BX9 gives: neg(phi U psi) in u and phi in u, which means... actually neg(phi U psi) and phi are consistent -- phi U psi failing doesn't preclude phi).

**Wait -- the contradiction is subtler.** Having neg(phi U psi) in u and phi in u is not a contradiction. We need to propagate neg(phi U psi) forward to v and derive neg(psi) in v (contradicting psi in v).

Let me re-examine. From neg(phi U psi) in u:
- By BX4: G(P(neg(phi U psi))) in u. So P(neg(phi U psi)) in v.
- This does NOT give neg(phi U psi) in v. It gives a backward witness from v.

**Alternative approach**: Use the chain construction for the backward direction too. Given the chain w_0, ..., w_n with w_0 = w and w_n = v, we argue:
- At w_n = v: psi in v. By BX8: phi U psi in v. Done for the base.
- At w_{n-1}: phi in w_{n-1} (from guard). And phi U psi in w_n (the next step). We need phi U psi in w_{n-1}. But phi U psi in the successor does NOT directly give phi U psi in the predecessor.

**The correct backward argument**: This is actually done by induction on the chain length, using an unfolding equivalence:

phi U psi <-> psi OR (phi AND X(phi U psi))

where X is "at the next step." But X requires discrete time. On general linear orders, the unfolding is:

phi U psi <-> psi OR (phi AND F(phi U psi))    (NOT a theorem in general!)

Actually the correct equivalence on reflexive linear orders is:

phi U psi <-> psi OR (phi AND (phi U psi) at some strictly later time)

This is essentially BX5 (self-accumulation) read in the reverse direction combined with BX6 (absorption).

**The real backward proof in Burgess**: Uses contradiction. Assume neg(phi U psi) in w. The chain through w has phi U psi at later points (by the forward direction applied to them). Using BX7 (linearity), the neg(phi U psi) at w and phi U psi at some later w_i create a BX7-resolvable configuration. The key is that BX7 operates within a SINGLE MCS -- and w is such an MCS containing both neg(phi U psi) and information about the chain.

**Assessment**: The backward direction is genuinely harder than the forward direction. It requires either (a) an Until unfolding principle derivable from BX5+BX6, or (b) a BX7-based linearity argument within w. Both are non-trivial. Prior reports have not fully worked through this direction.

**Mitigation**: Prioritize proving the derived theorem `phi AND F(phi U psi) -> phi U psi` from BX6 (absorption). If this is derivable, the backward direction follows by: phi in w (from guard), F(phi U psi) in w (from BX8 applied to psi in v, then backward propagation via the chain), hence phi U psi in w.

### Risk 1.3: Box/Modal Interaction with Chain Construction

**Severity**: MEDIUM
**Status**: Manageable with existing infrastructure

The logic is bimodal: Box quantifies over all histories in Omega. The chain construction builds a single history. For Box phi in w_0 at time 0, every history through w_0 must satisfy phi at 0.

**Key question**: Does the chain construction interact with the Box truth lemma?

**Analysis**: The chain construction is used for the TEMPORAL truth lemma (Until/Since cases). The Box truth lemma is handled separately via modal saturation -- for each Diamond phi in some MCS, there must exist a history in Omega visiting an MCS containing phi. This is the standard canonical model argument for S5 and does not involve chains.

The interaction point is: when building Omega, each history is a chain (or some construction extending an MCS to a full Z-indexed sequence). For Box phi in w_0, we need phi in w_0 on EVERY history. Since phi in w_0 is a property of the MCS w_0 (not the history), and Box phi in w_0 means phi in every modally-equivalent MCS, the chain construction does not interfere -- different chains through w_0 all have the same w_0 at time 0.

**Modal equivalence in Task Semantics**: Two histories sigma, tau are distinguished by Box at time t when they visit different world-states at t. Box phi at t in (M, Omega, tau, t) means: for all sigma in Omega, truth_at M Omega sigma t phi. Since histories can differ at time t, Box looks at ALL possible world-states at t across Omega.

**Does the chain construction preserve this?** Yes, IF Omega contains enough histories. Each chain starts from a different MCS (or the same MCS with different successors), providing the variety needed for Box. The existing `CanonicalOmega` construction in CanonicalConstruction.lean already handles this by taking the set of all BFMCS family histories.

**Conclusion**: No novel risk. The Box case and the Until case are orthogonal in the truth lemma proof.

### Risk 1.4: Since Direction Symmetry

**Severity**: LOW
**Status**: Symmetric with minor mechanical differences

Since is the temporal mirror of Until. The chain construction extends backward (w_{-1}, w_{-2}, ...) using h_content instead of g_content, BX4' instead of BX4, BX5' instead of BX5, etc.

**Potential asymmetry**: The Int-indexed chain is naturally bi-infinite (Z-indexed). The forward chain uses g_content seeds; the backward chain uses h_content seeds. The construction is:
- Forward (n > 0): g_content(w_{n-1}) subset seed for w_n
- Backward (n < 0): h_content(w_{n+1}) subset seed for w_n
- Central (n = 0): w_0 is the starting MCS

**Risk**: At the junction n = 0, the forward and backward chains must agree. If w_0 is the starting MCS, then g_content(w_0) goes into w_1 and h_content(w_0) goes into w_{-1}. There is no asymmetry at the junction -- each direction independently extends from w_0.

**Conclusion**: The Since direction is a mechanical mirror. All dual infrastructure (h_content, BX primed axioms, bx_backward_witness) exists. No novel risk.

### Risk 1.5: Consistency of Enriched Seeds with Multiple Eventualities

**Severity**: HIGH
**Status**: Requires dovetailing -- the known hard part

When building the chain, each step's seed must include formulas to resolve eventualities. If w_0 contains phi_1 U psi_1, phi_2 U psi_2, ..., phi_k U psi_k, ALL of these must eventually be resolved.

**The seed at step i**: g_content(w_{i-1}) UNION {target_i}

where target_i is the formula being resolved at step i. The question is: can we include the target without creating an inconsistent seed?

**The standard argument (Lindenbaum)**: The seed is consistent because g_content(w_{i-1}) is consistent (it is a subset of the consistent MCS w_{i-1}), and adding target_i preserves consistency IF g_content(w_{i-1}) UNION {target_i} is consistent.

**For a single Until formula**: phi U psi in w_0 gives F(psi) in w_0 (by BX10), hence F(psi) in g_content(w_0) (via BX4: G(P(phi U psi)) so... wait, F(psi) is NOT in g_content. g_content = {alpha : G(alpha) in w}. G(F(psi)) is not derivable from phi U psi in general.

**Correction**: The seed consistency for the eventual resolution step uses a different argument. At step n, where we want to resolve psi (put psi into w_n), the seed is g_content(w_{n-1}) UNION {psi}. This is consistent because:
1. If it were inconsistent: g_content(w_{n-1}) derives neg(psi)
2. By g_content_closed_derivation: G(neg(psi)) in w_{n-1}
3. Hence neg(psi) in all successors of w_{n-1}
4. But phi U psi was in w_0, giving F(psi) in w_0, hence psi must occur somewhere
5. The chain must reach a point where psi is consistent with the seed

**This argument is INCOMPLETE as stated.** Step 4-5 requires that psi is not globally false along the chain, which needs to be shown by an explicit consistency argument.

**The proper consistency argument** (Burgess): At the step where we resolve F(psi), the previous MCS w_{n-1} contains F(psi) (either propagated from w_0 via g_content, or still unresolved from deferral). The seed {psi} UNION g_content(w_{n-1}) is consistent because:
- If inconsistent: g_content(w_{n-1}) |- neg(psi)
- By g_content_closed_derivation: G(neg(psi)) in w_{n-1}
- But F(psi) in w_{n-1} and G(neg(psi)) in w_{n-1} contradicts consistency of w_{n-1}

**This works for one eventuality.** For MULTIPLE simultaneous eventualities, the dovetailing schedule ensures each is resolved in turn, and at each resolution step, only ONE target formula is added to the seed. The other eventualities may be deferred (their F-obligations persist in g_content).

**The interference risk**: Could resolving one eventuality (putting psi_1 into w_n) make another eventuality (phi_2 U psi_2) unsatisfiable? No, because:
- phi_2 U psi_2 is propagated via the self-accumulation argument (it or phi_2 holds at each step)
- F(psi_2) persists in g_content until resolved
- The seed for resolving psi_2 at a later step is g_content(w_{m-1}) UNION {psi_2}, and the consistency argument is independent of whether psi_1 was resolved earlier

**Conclusion**: Multiple eventualities do NOT interfere. The dovetailing construction handles them sequentially, and each resolution step's consistency is independent. **Risk is manageable.**

**Mitigation**: Use round-robin scheduling over all Until/Since subformulas. The existing `TargetedChain.lean` in the codebase already implements this pattern.

---

## Part 2: Architecture Risks

### Risk 2.1: Two Completeness Architectures

**Severity**: CRITICAL
**Status**: Must be resolved -- recommend converging on Bundle

The project has TWO parallel completeness paths:

**BXCanonical** (BXCanonical/Frame.lean, BXCanonical/TruthLemma.lean, BXCanonical/Completeness.lean):
- Points are abstract MCS (BXPoint)
- Ordering is g_content inclusion (bx_le)
- 4 sorries in Frame.lean (the ones we are trying to close)
- 5 sorries in Completeness.lean
- Total: ~9 sorries

**Bundle** (Bundle/CanonicalConstruction.lean, Bundle/Construction.lean):
- Points are FMCS families indexed by Int
- Ordering is the natural Z ordering
- 9 sorries in CanonicalConstruction.lean (6 Until/Since, 3 other)
- Many sorries in subsidiary files (SuccChainFMCS: 22, SuccExistence: 9, etc.)
- Total: ~50+ sorries

**The chain construction plugs into Bundle**, not BXCanonical. The BXCanonical architecture was designed around abstract MCS and cannot support chain construction (its ordering is not linear by construction, which is precisely the gap identified in report 37).

**The dilemma**: Should we:
(a) Abandon BXCanonical and invest fully in Bundle?
(b) Keep BXCanonical for non-Until/Since cases and use Bundle for Until/Since?
(c) Port the chain construction into BXCanonical by modifying it?

**Analysis**:
- Option (a) is cleanest but discards working BXCanonical infrastructure (G/H truth lemma, Box truth lemma are sorry-free there)
- Option (b) creates an awkward split where completeness depends on BOTH architectures
- Option (c) fundamentally changes BXCanonical to BE a chain construction, at which point it IS the Bundle approach

**Recommendation**: Option (a) -- converge on Bundle. The BXCanonical G/H and Box arguments are standard and can be re-proved in the Bundle framework (they are not the hard part). The hard part is Until/Since, which requires chains, which requires Bundle.

**Mitigation**: Do NOT delete BXCanonical immediately. Keep it as reference. Build the chain-based Until/Since truth lemma in Bundle and close completeness there. Mark BXCanonical as deprecated after Bundle completeness is achieved.

### Risk 2.2: Prior Boneyard Failures

**Severity**: HIGH
**Status**: Root causes identified -- avoidable

The Boneyard contains 6 chain-related files with a combined 56 sorries. Analysis of the three main attempts:

**TargetedChain.lean** (5 sorries): Builds forward successors that resolve F-obligations. The approach is fundamentally sound (sorry-free DRM chains). The failure point is lifting from DRM (restricted MCS within deferralClosure) to full MCS for modal properties. The DRM is a restricted universe that cannot reason about formulas outside deferralClosure.

**ResolvingChain.lean** (1 sorry): Uses bounded_witness from DRM chains. The single sorry is the final wiring -- connecting the chain to the FMCS/BFMCS structure needed by CanonicalConstruction. The chain IS built correctly; the failure is INTEGRATION, not construction.

**MCSWitnessChain.lean** (7 sorries): Most ambitious -- attempts to build full MCS chains from DRM chains. The sorries are in the lifting step: showing that properties proved for the DRM chain transfer to the full MCS chain.

**Common failure pattern**: All three attempts build chains within DeferralRestrictedMCS (DRM) and then struggle to lift to full MCS. The DRM restriction means formulas like Box phi that are outside deferralClosure cannot be reasoned about.

**Why the new approach must differ**: Instead of building DRM chains and lifting, build FULL MCS chains directly. Each step uses Lindenbaum extension of g_content UNION {target} to a FULL MCS (not DRM). The consistency argument works at the full MCS level. Modal saturation is handled separately via Omega construction.

**Mitigation**: The new chain construction should:
1. Work with full SetMaximalConsistent, NOT DeferralRestrictedMCS
2. Use `canonical_forward_F` (which gives full MCS successors) rather than `build_targeted_successor` (which gives DRM successors)
3. NOT route through the simplified_restricted_seed / DRM infrastructure
4. Build the FMCS directly as a Z-indexed function from Int to MCS

### Risk 2.3: truth_at Level vs MCS Level Gap

**Severity**: MEDIUM
**Status**: Bridge exists but requires careful wiring

The truth lemma connects MCS membership to truth_at evaluation:
```
phi in fam.mcs t  <->  truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

The chain gives MCS-level facts (phi U psi in w_0, psi in w_n, phi in w_i for 0 <= i < n). The truth_at definition requires:
- A WorldHistory (function from D to WorldState with domain predicate)
- Membership in Omega
- The truth_at recursive evaluation

**Potential circular dependency**: The truth lemma at time j uses induction on formula complexity. The chain construction at step j uses formulas from w_0. Is there a well-foundedness issue?

**Analysis**: No circularity. The truth lemma is proved by structural induction on the formula phi. At the Until case (`phi U psi`), the IH gives the truth lemma for phi and psi (which are structurally smaller). The chain construction produces witnesses at MCS level, and the IH converts these to truth_at level. The chain construction itself does NOT invoke the truth lemma -- it uses only MCS properties (BX axioms, Lindenbaum, consistency). The truth lemma merely INTERPRETS the chain's output.

**The real gap**: Converting the chain to a valid WorldHistory requires:
1. The chain IS a function Z -> MCS (direct from construction)
2. Wrapping in to_history gives a WorldHistory (straightforward)
3. The WorldHistory IS in Omega (requires showing it belongs to BFMCS)
4. The BFMCS requires temporal coherence (forward_F, backward_P)

Step 4 is where the chain construction's dovetailing guarantees come in: the chain resolves all F-obligations (forward_F) and all P-obligations (backward_P) by construction.

**Conclusion**: No circularity. The gap is in Step 4, which requires the chain's dovetailing to be complete (all eventualities resolved). This is the dovetailing argument from Risk 1.5.

---

## Part 3: Dense Extension Risks

### Risk 3.1: Dense Linear Orders

**Severity**: CRITICAL for extension goal
**Status**: Fundamentally incompatible with chain construction

For D = Q (rationals), the chain construction DOES NOT WORK. Between any two chain points w_i and w_{i+1}, there must be infinitely many intermediate points. The discrete step w_i -> w_{i+1} via Succ does not exist on dense orders.

**What changes for dense orders**:
- No successor function (Succ is undefined)
- No step-by-step chain building
- No finite dovetailing schedule (infinitely many intermediate points need content)
- The Until witness is not reached in finitely many steps

**Standard approaches for dense completeness**:

1. **Quasimodels / Mosaics** (Hodkinson, Reynolds): Build finite combinatorial objects (mosaics) that encode local consistency. Then glue them together via a compactness argument. This is fundamentally different from chain construction.

2. **Filtration + unraveling**: Build a finite model from the canonical model by identifying equivalent states. Works for decidability but not directly for completeness.

3. **Dedekind completion**: Build the chain on Z (discrete), then embed Z into Q via a dense embedding. The truth_at evaluation on Q is defined by limits/completions. This is technically demanding.

4. **Step-by-step with "filling"** (Gabbay, Hodkinson, Reynolds 1994): Build the chain on Z, then between each pair of adjacent points, insert a dense sub-chain using Zorn's lemma. This is the closest to extending the chain approach but adds an entire layer of complexity.

**Assessment**: The chain approach for Z and the dense approach for Q are fundamentally different constructions. Designing the chain construction with "extensibility to dense" as a goal is a category error -- the dense case needs different mathematics, not a parameterized version of the same mathematics.

**Mitigation**: Design the chain construction for Z (Int) cleanly and modularly. For dense extension, plan a SEPARATE construction that may share some infrastructure (MCS properties, Lindenbaum, g_content) but NOT the chain-building logic. Use a typeclass `[LinearOrder D]` for shared lemmas and specialize chain-building to `[Succ D]` or `[DiscreteLinearOrder D]`.

### Risk 3.2: CanonicalTask Relation for Dense D

**Severity**: MEDIUM for extension goal
**Status**: Feasible but deferred

The existing canonical task relation uses:
```
d > 0: g_content(M) subset N
d = 0: M = N
d < 0: h_content(N) subset M   (converse)
```

For D = Q, this STILL works (g_content inclusion is independent of the time domain). The issue is not the task relation but the HISTORY construction -- how to define a function Q -> MCS with the right properties.

For dense orders, the history would need to assign an MCS to every rational number, with g_content propagation between adjacent rationals (which don't exist -- "adjacent" is meaningless in Q). Instead, g_content propagation is replaced by: for all s < t in Q, g_content(history(s)) subset history(t). This is an uncountable family of inclusion constraints.

**Conclusion**: Feasible in principle but requires fundamentally different construction methods. Defer to a separate task.

---

## Part 4: Verification Challenges

### Risk 4.1: Lean 4 Formalization Difficulty

**Severity**: HIGH
**Status**: Substantial but tractable

**Estimated components and LOC**:

| Component | LOC | Difficulty | Sorries Closed |
|-----------|-----|------------|----------------|
| Chain construction (Z -> MCS) | 200-300 | Medium | 0 (infrastructure) |
| Dovetailing scheduler | 100-200 | Medium | 0 (infrastructure) |
| Seed consistency at each step | 150-250 | High | 0 (infrastructure) |
| Forward Until truth lemma | 200-400 | Very High | 2 (forward Until + Since) |
| Backward Until truth lemma | 200-350 | Very High | 2 (backward Until + Since) |
| FMCS/BFMCS integration | 150-300 | High | 4-6 (CanonicalConstruction sorries) |
| Total | 1000-1800 | | ~8 |

**Mathlib infrastructure needed**:
- `Int` as `LinearOrder` with `Succ` -- exists in Mathlib
- `Finset` for subformula enumeration -- exists
- Induction on `Int` / `Nat` -- standard
- `SetMaximalConsistent` and Lindenbaum -- already in codebase
- `Set.Finite` for subformula finiteness -- exists
- No universe issues: `Set Formula` lives in `Type`, `Int -> Set Formula` lives in `Type`, all in the same universe

**The hardest Lean-specific challenges**:
1. **Dependent type wrangling**: The chain at step n depends on the chain at step n-1. This is a recursive function `Nat -> MCS` where the MCS at each step is constructed from the previous one. Lean handles this via `Nat.rec`, but the proofs at each step carry dependencies that make the recursion non-trivial.
2. **Classical reasoning**: The Lindenbaum extension and MCS completion are inherently classical (Zorn's lemma). The codebase already uses `Classical.choice` extensively, so this is not a new issue.
3. **Decidability instances**: Subformula enumeration requires decidable equality on Formula, which exists.

### Risk 4.2: Dovetailing Complication

**Severity**: MEDIUM
**Status**: Standard technique, existing partial infrastructure

Dovetailing requires:
1. Enumerating all Until/Since subformulas of the root formula
2. A round-robin schedule assigning each eventuality to a specific step
3. Proving that every eventuality is resolved within finitely many steps

**In the codebase**: `SubformulaClosure.lean` provides subformula enumeration. `deferralClosure` captures the relevant formulas. The existing `TargetedChain.lean` implements a scheduling pattern (though in the DRM context).

**The proof obligation**: Given k eventualities, the schedule resolves each within at most k steps. So after k steps, all eventualities from step 0 are resolved. New eventualities may be introduced by the resolution process (e.g., resolving phi U psi might introduce phi U psi again at a later step via BX5). But the set of DISTINCT Until subformulas is finite (bounded by the subformula closure), so the dovetailing terminates.

**Complication**: Burgess's chain resolves eventualities "on demand" -- when phi U psi is in w_i and psi is not, the next step targets psi. With multiple eventualities, a priority queue or round-robin is needed. The proof that the queue is fair (every eventuality eventually served) is the key lemma.

**Mitigation**: Use the simplest possible scheduling: enumerate all Until/Since subformulas as a list, cycle through them. At each cycle position, if the eventuality needs resolution, resolve it; otherwise, take a default successor. This is exactly what `TargetedChain.lean` does.

### Risk 4.3: Existing Sorry Landscape

**Severity**: MEDIUM
**Status**: Chain construction does not increase sorry count

**Non-Boneyard sorry count** (files that matter for completeness):

| File | Sorries | Category |
|------|---------|----------|
| BXCanonical/Frame.lean | 9 | 4 Until/Since + 5 modal |
| BXCanonical/Completeness.lean | 5 | Completeness wiring |
| Bundle/CanonicalConstruction.lean | 9 | 6 Until/Since + 3 other |
| Bundle/SuccChainFMCS.lean | 22 | Chain infrastructure |
| Bundle/SuccExistence.lean | 9 | Successor existence |
| Soundness.lean | 4 | Density constraints |
| ConservativeExtension/ | 39 | Substitution/Lifting |

**Will the chain construction introduce NEW sorries?** It should NOT, if implemented correctly. The chain construction replaces the sorry stubs in Frame.lean (or CanonicalConstruction.lean) with actual proofs. It may also close some Bundle infrastructure sorries (SuccChainFMCS, SuccExistence) by providing a working chain construction.

**The path to sorry-free completeness** requires closing:
1. Until/Since truth lemma (4-6 sorries) -- chain construction
2. Completeness wiring (5 sorries) -- integration
3. Soundness density constraints (4 sorries) -- separate refactoring
4. Modal sorries (5 in Frame.lean) -- standard S5 argument
5. ConservativeExtension (39 sorries) -- separate effort

The chain construction addresses items 1-2. Items 3-5 are independent.

---

## Part 5: Quality Assessment

### Risk 5.1: Is Chain Construction the Right Foundation?

**Severity**: Assessment (not a risk)
**Verdict**: YES -- it is the standard approach

**Literature consensus**: Every published completeness proof for Until/Since on linear orders uses either:
- Chain construction (Burgess 1984, Goldblatt 1992, Xu 1988)
- Step-by-step construction (same idea, different presentation)
- Quasimodels (for decidability, not directly for completeness)

**Other formalizations**: None exist for Until/Since completeness (confirmed by report 35). The closest are:
- FormalizedFormalLogic/Foundation (Lean 4): Modal logic only
- Isabelle generic MCS framework (CPP 2025): Not applied to Until
- LeanearTemporalLogic (Lean 4): LTL semantics only

So there is no existing formalization to compare against. The chain approach is the standard paper proof technique.

**Alternative approaches**:
- **Quasimodels** (Venema 1993): More elegant for decidability, but the completeness connection requires an additional step (quasimodel to model). Not simpler for formalization.
- **Algebraic/coalgebraic** approaches: Theoretically cleaner but require heavy categorical infrastructure not present in Mathlib for temporal logics.
- **Step-by-step from GHR 1994**: This IS the chain construction, just presented differently.

### Risk 5.2: Extensibility Assessment

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Clean separation of base/dense/discrete | MEDIUM | Base (linear order) and discrete (Int) share chain construction. Dense requires separate construction. Shared MCS infrastructure enables partial reuse. |
| Reuse across extensions | MEDIUM | MCS properties, Lindenbaum, g_content, soundness are fully reusable. Chain building is discrete-specific. |
| Mathematical elegance | HIGH | Chain construction is the canonical (pun intended) approach. Well-understood, well-documented. |
| Formalization tractability | MEDIUM-HIGH | Standard inductive arguments. No exotic mathematics. Main difficulty is the sheer volume of cases (Until, Since, forward, backward, reflexive witness, strict witness). |

---

## Risk Summary Table

| # | Risk | Severity | Blocks? | Mitigation |
|---|------|----------|---------|------------|
| 1.1 | Half-open vs strict guards | HIGH | No | Two-case split (reflexive/strict witness); works identically at each chain step |
| 1.2 | Backward direction proof | HIGH | Partially | Derive `phi AND F(phi U psi) -> phi U psi` from BX6; or use BX7 within w |
| 1.3 | Box/modal interaction | MEDIUM | No | Orthogonal to chain; handled by Omega construction |
| 1.4 | Since direction symmetry | LOW | No | Mechanical mirror; dual infrastructure exists |
| 1.5 | Multiple eventuality consistency | HIGH | No | Sequential dovetailing; independence of resolution steps |
| 2.1 | Two completeness architectures | CRITICAL | Yes | Converge on Bundle; keep BXCanonical as reference |
| 2.2 | Boneyard failure patterns | HIGH | No | Use full MCS chains, NOT DRM chains |
| 2.3 | truth_at vs MCS bridge | MEDIUM | No | No circularity; gap is in BFMCS temporal coherence |
| 3.1 | Dense order extension | CRITICAL (for Q) | Yes (for Q) | Separate construction; not a parametric extension of chains |
| 3.2 | Dense task relation | MEDIUM | No (for Q) | g_content approach works; history construction changes |
| 4.1 | Lean formalization difficulty | HIGH | No | ~1000-1800 LOC; standard techniques; no universe issues |
| 4.2 | Dovetailing complexity | MEDIUM | No | Round-robin over finite subformula set; existing infrastructure |
| 4.3 | Sorry landscape | MEDIUM | No | Chain addresses 4-6 sorries; does not introduce new ones |
| 5.1 | Right foundation? | Assessment | N/A | YES -- standard approach, no better alternative |
| 5.2 | Extensibility | Assessment | N/A | MEDIUM-HIGH -- good for discrete; dense needs separate work |

## Top Recommendations

1. **Resolve the architecture question FIRST** (Risk 2.1). Choose Bundle as the target. Do not try to fill the BXCanonical sorries -- they are unfillable in that framework (proven in report 37).

2. **Build full MCS chains, not DRM chains** (Risk 2.2). This is the single most actionable lesson from the Boneyard. The DRM-to-MCS lifting is where all prior attempts died.

3. **Work through the backward direction on paper before coding** (Risk 1.2). This is the direction where the proof technique is least clear. Derive `phi AND F(phi U psi) -> phi U psi` from BX5+BX6 as a prerequisite.

4. **Do NOT design for dense extensibility in the chain construction** (Risk 3.1). Build for Int. Dense orders need a fundamentally different approach. Share the MCS/Lindenbaum/g_content infrastructure but not the chain builder.

5. **Start with the forward Until direction** (Risk 1.1). It is the best understood and provides the template for the other three directions.
