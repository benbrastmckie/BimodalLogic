# Research-019: Strategic Reassessment -- All Viable Paths Forward

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773097577_9a8176
**Focus**: Comprehensive reassessment of all viable approaches given accumulated blockers

---

## 1. Executive Summary

After three iterations of Phase 8 (research-017, research-018, implementation-004), the current approach -- constructing D as `Additive (T ≃o T)` where T is a DenselyOrdered BidirectionalQuotient -- has hit two fundamental mathematical blockers:

1. **Countable BidirectionalQuotient is FALSE** (research-018): CanonicalR edges reach uncountably many MCSes, not countable branching.
2. **DenselyOrdered BidirectionalQuotient has 4 sorries** (research-017): Lindenbaum collapse prevents constructing intermediate MCSes between adjacent quotient elements.

These blockers are **not incremental difficulties** -- they reflect a fundamental mismatch between the automorphism-group construction and the available mathematical infrastructure.

**Recommendation**: **Strategy E (D = Rat, Direct Construction)** -- abandon the automorphism group approach entirely. Set D = Q (rationals), build canonical histories as functions `Q -> MCS`, define the task relation from histories, and prove completeness. This aligns with the JPL paper's approach (research-007) and bypasses ALL current blockers.

---

## 2. Blocker Root Cause Analysis

### 2.1 Blocker 1: Countable BidirectionalQuotient (research-018)

**Root cause**: `BidirectionalReachable` follows arbitrary `CanonicalR` edges, not just specific Lindenbaum witnesses. Since `CanonicalR M M'` only requires `GContent(M) ⊆ M'`, and uncountably many MCSes can extend any consistent set, the reachable fragment is uncountable.

**Impact**: Without `Countable BidirectionalQuotient`, the Mathlib theorem `Order.embedding_from_countable_to_dense` cannot embed the quotient into Q. The fallback plan (Approach C from research-017) is blocked.

**Could it be fixed?** Redefining `BidirectionalReachable` to follow only specific Lindenbaum witnesses (Alternative A/E from research-018) would make the fragment countable. But this requires proving the restricted fragment still has totality and density -- which reintroduces the same Lindenbaum collapse problems.

### 2.2 Blocker 2: DenselyOrdered BidirectionalQuotient (research-017)

**Root cause**: The Lindenbaum lemma is existential and provides no control over which MCS a consistent set extends to. Seeds like `{phi} UNION GContent(a)` can extend to `a.world` or `b.world` themselves, collapsing the intended intermediate element to an endpoint.

**Impact**: 4 sorries in DenseQuotient.lean (lines 347, 349, 351, 698). All proposed fixes (double-seed, G-enrichment, adjacency contradiction) run into the same collapse issue.

**Could it be fixed?** Possibly, but every approach attempted so far has failed. The "double-seed" approach from research-017 Section 7.2 requires handling 3 linearity sub-cases, and even in the most favorable case (Case 1 of linearity), the argument is incomplete. The problem is mathematically subtle: density of MCSes under CanonicalR does not trivially imply density of the quotient.

### 2.3 Blocker 3: Automorphism Group Properties (TranslationGroup.lean deferred items)

Even if Blockers 1 and 2 were resolved, the TranslationGroup approach requires:
- **AddCommGroup D**: Requires Holder's theorem (free ordered group actions are abelian)
- **LinearOrder D**: Requires freeness/rigidity of the group action
- **AddTorsor D T**: Requires homogeneity (transitivity) of the action
- **IsOrderedAddMonoid D**: Requires linear order + order compatibility

These are listed as "deferred to future tasks" in TranslationGroup.lean. Each is a substantial mathematical theorem requiring significant Lean formalization effort.

### 2.4 Overall Assessment

The automorphism group approach requires solving at minimum **5 hard problems** (countability, density, Holder, freeness, homogeneity), each of which is non-trivial. The approach was not taken from the JPL paper (research-007 established this clearly). It appears to be an independent mathematical construction that, while elegant in principle, does not match the available infrastructure or the paper's proof strategy.

---

## 3. Viable Strategies

### Strategy A: Fix Countability via Restricted Reachability

**Approach**: Redefine `BidirectionalReachable` to follow only specific Lindenbaum witnesses (the outputs of `canonical_forward_F` and `canonical_backward_P`). The restricted fragment is countable by construction (surjection from `List (Formula + Formula)`).

**Pros**:
- Countability is trivially provable
- Reuses existing BidirectionalReachable infrastructure
- Partial reuse of existing totality proofs

**Cons**:
- Must re-prove totality for the restricted fragment (the current totality proof uses arbitrary CanonicalR edges in `canonical_forward_reachable_linear`)
- Density problem remains: still need DenselyOrdered on the restricted quotient
- All downstream automorphism group problems (Holder, freeness, homogeneity) remain
- Estimated effort: 20+ hours for countability + density + downstream

**Risk**: HIGH -- density blocker likely persists in the restricted setting.

**Verdict**: Does not address the core problem. The density issue is independent of countability.

### Strategy B: Direct Q-Embedding Without DenselyOrdered

**Approach**: If countability could be established (via Strategy A), use `Order.embedding_from_countable_to_dense` to embed BidirectionalQuotient into Q. This requires only `Countable` and `LinearOrder` on the source, not `DenselyOrdered`.

**Pros**:
- Bypasses the DenselyOrdered proof entirely
- Mathlib's `Order.embedding_from_countable_to_dense` is proven and available
- Gives an `OrderEmbedding BQ Q`

**Cons**:
- Requires solving the countability blocker first (Strategy A)
- The embedding gives a non-surjective map into Q; the image is NOT dense in Q
- Downstream phases need `TaskFrame D` where D is a totally ordered abelian group. If D = `Additive (T ≃o T)` where T is the BQ image in Q, we still need the automorphism group properties
- Does not directly give us D as a group acting on T

**Risk**: MEDIUM-HIGH -- countability is the bottleneck, and the downstream group construction remains.

**Verdict**: Partially viable but still requires solving the countability problem and the group action problems.

### Strategy C: D = Z (Integer) Canonical Histories

**Approach**: Following the JPL paper exactly (research-007): set D = Z, build canonical histories as `Z -> MCS` functions, define the task relation from histories. This matches the paper's base logic TM (which uses Z as the canonical temporal order).

**Pros**:
- Directly follows the paper's proof
- Z has all required algebraic structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid) trivially from Mathlib
- `addGroupIsAddTorsor` gives `AddTorsor Z Z` for free
- `CanonicalChain` already exists in the codebase (sorry-free Z-indexed chains through MCSes)
- Bypasses ALL current blockers (no BidirectionalQuotient needed)
- The existing `TaskFrame Int` infrastructure is designed for this

**Cons**:
- Does NOT prove completeness for dense temporal logic (TM + DN). Z is discrete, and DN is invalid over Z (research-007 Section 5 notes this explicitly)
- Only proves completeness for the BASE logic TM (without density axiom DN)
- Requires building the full canonical model (canonical histories, truth lemma) -- significant new work but well-understood mathematically
- FragmentCompleteness.lean has 2 sorries related to the Int-chain approach (forward_F/backward_P persistence)

**Risk**: MEDIUM -- the mathematical path is clear but requires substantial implementation.

**Verdict**: Viable for base TM completeness. Does NOT address the dense case that task 956 is concerned with.

### Strategy D: D = Q (Rational) Canonical Histories

**Approach**: Similar to Strategy C but with D = Q instead of Z. The JPL paper's Section 5 (research-007 Section 2.5) notes that for TM^d (dense logic), the canonical model uses Q instead of Z, with the proof "carrying through unchanged."

**Pros**:
- Directly addresses the dense completeness requirement
- Q has all required algebraic structure: `LinearOrderedField Rat` provides `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`
- `addGroupIsAddTorsor` gives `AddTorsor Q Q` for free
- Q is DenselyOrdered (from `LinearOrderedField` or explicit instance)
- Bypasses ALL current blockers (no BidirectionalQuotient, no automorphism group)
- No need for Holder's theorem, freeness, or homogeneity

**Cons**:
- Cannot directly use `CanonicalChain` (which is Z-indexed). Need Q-indexed canonical histories
- Constructing Q-indexed histories is harder than Z-indexed ones: cannot use simple recursion on integers. Need a different construction (e.g., back-and-forth, or enumeration of a countable dense set)
- The paper hand-waves this ("proof carries through"), but the Q-indexed case requires genuine new work
- Must define canonical histories `Q -> MCS` with CanonicalR ordering between points
- The density axiom DN is needed to ensure the canonical histories can "fill in" intermediate points

**Risk**: MEDIUM -- mathematically sound but Q-indexed histories are harder to construct than Z-indexed ones.

**Verdict**: VIABLE and addresses the core requirement. See detailed analysis in Section 4.

### Strategy E: D = Q with Fragment-Based Construction (RECOMMENDED)

**Approach**: Combine the JPL paper's D = Q idea with the existing fragment infrastructure:

1. The BidirectionalFragment already has a sorry-free `fragmentFMCS` with forward_F and backward_P
2. The fragment has a total Preorder and LinearOrder on the quotient (proven, sorry-free)
3. Instead of constructing Q-indexed histories, use the fragment as an INTERMEDIATE timeline
4. Define the canonical TaskFrame with D = Q directly, WorldState = MCS (or fragment elements)
5. Define `task_rel w d u` using the fragment's ordering + the Q-parameterized canonical histories

**Key insight**: We do NOT need the BidirectionalQuotient to be countable or densely ordered. We only need it to be a LinearOrder. The task relation is defined using D = Q (which IS densely ordered), not using automorphisms of the quotient.

**Construction sketch**:
- WorldState = BidirectionalFragment M0 h_mcs0
- D = Rat (= Q)
- For each pair (w, d) where d in Q, define task_rel w d u iff there exists a canonical history tau : Q -> WorldState passing through w at time 0 and u at time d
- Canonical histories are built using the density of Q + Lindenbaum + the DN axiom

**Why this works**:
- Nullity: tau(0) = w, tau(0) = w. So task_rel w 0 w.
- Compositionality: tau(0) = w, tau(d1) = u, sigma(0) = u, sigma(d2) = v. Need combined history. The group structure of Q gives tau shifted by d1 at position d1+d2.
- The DN axiom ensures that between any two CanonicalR-related MCSes, there exists an intermediate MCS. This is used to construct the canonical history with the required density.

**Pros**:
- Bypasses ALL current blockers
- Q has full algebraic infrastructure from Mathlib
- `addGroupIsAddTorsor Q Q` gives torsor for free
- Fragment infrastructure (totality, forward_F, backward_P) is reused
- The density argument uses DN directly (as axiom) rather than trying to prove it as a property of the quotient
- No need for automorphism groups, Holder's theorem, freeness, or homogeneity
- Aligns with the JPL paper's approach

**Cons**:
- Requires new canonical history construction over Q (not trivial but well-understood)
- DenseQuotient.lean and TranslationGroup.lean become dead code (significant sunk cost)
- Need to define what "canonical history" means precisely in the Q-indexed case
- Compositionality proof may be non-trivial (the paper hand-waves this)

**Risk**: MEDIUM -- the construction is mathematically standard but requires careful Lean formalization.

**Estimated effort**: 15-25 hours for the full construction.

**Verdict**: RECOMMENDED. This is the simplest path that addresses ALL requirements.

### Strategy F: Axiomatic Bridge (sorry-backed)

**Approach**: Accept that the automorphism group properties cannot be proven, and introduce sorry-backed theorems (or axioms) for the missing properties (DenselyOrdered, Countable, etc.). Complete the downstream phases using these assumptions.

**Risk assessment**: This violates the zero-debt policy. Sorries are technical debt, not acceptable compromises.

**Verdict**: FORBIDDEN per proof-debt-policy. Not recommended under any circumstances.

---

## 4. Detailed Analysis of Strategy E (D = Q, Fragment-Based)

### 4.1 What We Keep

From the existing codebase, the following are reused as-is:

| Component | File | Status |
|-----------|------|--------|
| BidirectionalFragment | BidirectionalReachable.lean | Sorry-free |
| Fragment totality | BidirectionalReachable.lean | Sorry-free |
| Fragment LinearOrder (quotient) | BidirectionalReachable.lean | Sorry-free |
| fragmentFMCS | CanonicalCompleteness.lean | Sorry-free |
| forward_F_stays_in_fragment | BidirectionalReachable.lean | Sorry-free |
| backward_P_stays_in_fragment | BidirectionalReachable.lean | Sorry-free |
| canonical_forward_F | CanonicalFMCS.lean | Sorry-free |
| canonical_backward_P | CanonicalFMCS.lean | Sorry-free |
| TruthLemma | TruthLemma.lean | Sorry-free |
| ModalSaturation | ModalSaturation.lean | Sorry-free |
| CanonicalChain | CanonicalChain.lean | Sorry-free |
| CanonicalFrame (CanonicalR, temp_4, etc.) | CanonicalFrame.lean | Sorry-free |

### 4.2 What We Abandon

| Component | File | Reason |
|-----------|------|--------|
| DenseQuotient | DenseQuotient.lean | 4 sorries, fundamentally blocked |
| TranslationGroup | TranslationGroup.lean | Automorphism approach abandoned |
| Countable BidirectionalQuotient | (planned) | Mathematically false for current definition |

### 4.3 What We Build New

| Component | Description | Estimated Effort |
|-----------|-------------|------------------|
| Q-indexed canonical history | Function `Q -> BidirectionalFragment` with CanonicalR ordering | 6-8 hours |
| Canonical task relation | `task_rel w d u` defined via canonical histories | 2-3 hours |
| TaskFrame Q construction | Nullity + compositionality proofs | 3-4 hours |
| Dense completeness theorem | Connecting TaskFrame Q to validity | 4-6 hours |

### 4.4 Q-Indexed Canonical History Construction

The key new component. Given a root MCS M0 in the bidirectional fragment:

**Step 1**: Define `QHistory` as a structure:
```
structure QHistory where
  eval : Rat -> BidirectionalFragment M0 h_mcs0
  ordered : forall q1 q2 : Rat, q1 <= q2 -> eval q1 <= eval q2
  forward_F : forall q phi, F(phi) in (eval q).world ->
    exists r > q, phi in (eval r).world
  backward_P : forall q phi, P(phi) in (eval q).world ->
    exists r < q, phi in (eval r).world
```

**Step 2**: Construct a QHistory from a root MCS.

The construction uses the density of Q and the DN axiom:

1. Start with a "skeleton" at integer points using CanonicalChain
2. Use density of Q to "fill in" between integer points
3. The DN axiom ensures that between any two CanonicalR-related MCSes, there exists an intermediate one (via FF(phi) -> exists intermediate with F(phi))

**Alternative construction** (simpler, may be sufficient):

1. Build a countable dense subset of Q (e.g., dyadic rationals)
2. Enumerate and assign MCSes to each point by Lindenbaum extension
3. Use DN to ensure each new point can be placed consistently

**Step 3**: Define the canonical task relation:
```
task_rel w d u := exists tau : QHistory,
  exists t : Rat, tau.eval t = w /\ tau.eval (t + d) = u
```

**Step 4**: Prove nullity (trivial: t + 0 = t) and compositionality (from group structure of Q + history concatenation).

### 4.5 How DN is Used

The density axiom DN (F(phi) -> FF(phi)) is used in the canonical history construction:

Given `a < b` in the fragment (CanonicalR a b, NOT CanonicalR b a):
- Extract chi in b \ a. Then F(chi) in a.
- Apply DN: FF(chi) in a.
- This gives: there exists intermediate c with CanonicalR a c and F(chi) in c.
- Then there exists d with CanonicalR c d and chi in d.

The key difference from the DenselyOrdered approach: we do NOT need c to be distinct from a or b in the quotient. We only need the canonical history to "pass through" points that make the temporal formulas true. The history construction handles the assignment of Q-values to MCSes.

### 4.6 Mathlib Infrastructure Available

| Need | Mathlib Theorem/Instance | Module |
|------|-------------------------|--------|
| Q is AddCommGroup | `Rat.instAddCommGroup` | Mathlib.Data.Rat.Defs |
| Q is LinearOrder | `Rat.instLinearOrder` | Mathlib.Data.Rat.Order |
| Q is IsOrderedAddMonoid | From `LinearOrderedField Rat` | Mathlib.Data.Rat.Order |
| Q is DenselyOrdered | `Rat.instDenselyOrdered` or from field | Mathlib.Data.Rat.Order |
| Q is Countable | `Rat.instCountable` | Mathlib.Data.Rat.Encodable |
| AddTorsor Q Q | `addGroupIsAddTorsor Q` | Mathlib.Algebra.AddTorsor.Defs |
| Q has NoMinOrder | From `LinearOrderedField` | Mathlib.Data.Rat.Order |
| Q has NoMaxOrder | From `LinearOrderedField` | Mathlib.Data.Rat.Order |

All required instances are available in Mathlib. No new mathematical infrastructure needed for Q itself.

---

## 5. Comparison of Strategies

| Criterion | A (Restricted) | B (Q-Embed) | C (D=Z) | D (D=Q histories) | E (D=Q fragment) |
|-----------|---------------|-------------|---------|-------------------|-------------------|
| Addresses dense case | No (density blocked) | Partially | No (Z discrete) | Yes | Yes |
| Bypasses countability | No | No | Yes | Yes | Yes |
| Bypasses density proof | No | Yes | Yes | Yes | Yes |
| Bypasses automorphism | No | No | Yes | Yes | Yes |
| Reuses existing code | Partial | Partial | Partial | Partial | Maximal |
| New Lean code needed | 200-400 lines | 200-300 lines | 500-800 lines | 600-1000 lines | 400-700 lines |
| Estimated hours | 20+ | 15+ (if A works) | 20-30 | 20-30 | 15-25 |
| Risk level | HIGH | HIGH | MEDIUM | MEDIUM | MEDIUM |
| Paper alignment | No | No | Partial (base TM) | Yes (TM^d) | Yes (TM^d) |
| Zero-sorry feasible | Unlikely | Unlikely | Possible | Possible | Most likely |

---

## 6. Recommendation: Strategy E

### 6.1 Justification

Strategy E is recommended because:

1. **It addresses the core requirement** (dense temporal logic completeness) directly
2. **It bypasses ALL accumulated blockers** without introducing new mathematical difficulties
3. **It maximally reuses existing infrastructure** (fragment totality, forward_F, backward_P, truth lemma, modal saturation)
4. **It aligns with the JPL paper's approach** (D is a primitive group, not constructed from automorphisms)
5. **The mathematical argument is well-understood** (canonical model construction for tense logics is textbook material)
6. **All required Mathlib instances exist** for Q
7. **It has the highest probability of achieving zero sorries** among all strategies

### 6.2 What This Means for Task 956

Task 956's original objective ("Construct D as the group of order-preserving automorphisms of the canonical timeline of MCSes") should be **revised**:

**New objective**: Construct the canonical TaskFrame with D = Q and prove dense completeness for TM + DN.

**Impact on existing files**:
- `DenseQuotient.lean`: Archive or delete (4 sorries, approach abandoned)
- `TranslationGroup.lean`: Archive or delete (automorphism approach abandoned)
- `BidirectionalReachable.lean`: Keep as-is (fragment infrastructure reused)
- `CanonicalCompleteness.lean`: Keep fragmentFMCS, adapt for Q-based construction
- `FragmentCompleteness.lean`: 2 sorries may become irrelevant (Int-chain approach superseded)

### 6.3 Concrete Next Steps

1. **Create new implementation plan** (implementation-005.md) for Strategy E
2. **Phase 1**: Define `QCanonicalHistory` structure (Q -> BidirectionalFragment)
3. **Phase 2**: Construct Q-canonical histories using DN + Lindenbaum
4. **Phase 3**: Define canonical task relation from Q-histories
5. **Phase 4**: Prove TaskFrame Q properties (nullity, compositionality)
6. **Phase 5**: Prove dense completeness theorem
7. **Phase 6**: Archive DenseQuotient.lean and TranslationGroup.lean

### 6.4 Key Technical Challenge

The hardest part of Strategy E is **Phase 2: constructing Q-indexed canonical histories**. The Z-indexed case (CanonicalChain.lean) uses simple recursion on integers. The Q-indexed case cannot use recursion because Q is dense.

**Proposed approach for Q-indexed histories**:

Use a **back-and-forth construction** on an enumeration of Q:
1. Enumerate Q as q_0, q_1, q_2, ... (Q is countable)
2. Assign MCSes to each q_i in enumeration order
3. At step i, when assigning MCS to q_i:
   - Find the closest already-assigned points q_L < q_i < q_R
   - Use DN + Lindenbaum to find an MCS between the MCSes at q_L and q_R
   - This uses the density argument (DN gives FF(phi), which provides the intermediate)
4. The construction maintains the invariant that assigned MCSes are CanonicalR-ordered

This is essentially the standard back-and-forth construction for countable dense linear orders, specialized to MCSes with CanonicalR.

**Alternatively**: Use Mathlib's `Order.embedding_from_countable_to_dense` in reverse: embed the countable MCS fragment into Q, then extend the embedding to a full history using density.

---

## 7. Open Questions

1. **Is DN sufficient for the Q-history construction?** The DN axiom gives `F(phi) -> FF(phi)`, but the construction needs to find intermediate MCSes between ANY two CanonicalR-related MCSes, not just for specific formulas. This needs careful analysis.

2. **Can compositionality be proven without hand-waving?** The JPL paper's proof of compositionality (Theorem `thm:canonical-compositionality`) is sketchy. The Lean formalization needs a precise argument.

3. **What happens to the Int-chain sorries?** FragmentCompleteness.lean has 2 sorries related to Int-chain forward_F/backward_P persistence. These may become irrelevant if the Q-based approach supersedes the Int-chain approach.

4. **Should DenseQuotient.lean be archived or deleted?** It represents significant effort (700 lines) but is fundamentally blocked. Archiving to Boneyard preserves the mathematical work for reference.

---

## 8. References

- research-017.md: Phase 8 DenselyOrdered blocker analysis (4 approaches evaluated)
- research-018.md: Phase 8a Countable BidirectionalQuotient blocker (proven FALSE)
- research-007.md: JPL paper analysis (D = Z approach, canonical histories)
- implementation-004.md: Current blocked plan (hybrid B+C approach)
- BidirectionalReachable.lean: Sorry-free fragment infrastructure (888 lines)
- TranslationGroup.lean: Automorphism group construction (281 lines, to be archived)
- DenseQuotient.lean: Blocked density proof (700 lines, 4 sorries)
- CanonicalChain.lean: Z-indexed chains (sorry-free)
- CanonicalCompleteness.lean: Fragment-level FMCS (sorry-free)
- Mathlib `Order.embedding_from_countable_to_dense`: Countable -> dense embedding
- Mathlib `Order.iso_of_countable_dense`: Cantor's theorem for countable DLOs
- Mathlib `addGroupIsAddTorsor`: Group is torsor over itself
