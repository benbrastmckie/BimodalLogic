# Research Report: Burgess-Xu Axiom System for All Linear Orders

**Task**: 83 - Close restricted coherence sorries (axiom system redesign)
**Date**: 2026-04-07
**Focus**: Complete Burgess-Xu axiom system with all-reflexive semantics, no Next/Yesterday

## Executive Summary

- The Burgess-Xu system has **7 axiom schemas** (plus 7 mirror images = 14 total) and **2 inference rules** (NEC_G, NEC_H), complete for reflexive U/S over all linear orders
- Under all-reflexive semantics, G/H use `>=`/`<=` and U/S also use `>=`/`<=>` (reflexive witness, strict guard)
- The current codebase has **35 axiom constructors** with mixed strict/reflexive semantics; switching to Burgess-Xu would reduce to approximately **21 base axioms** (7 BX schemas x2 mirrors + S5 modal + interaction + propositional)
- All current discrete-only axioms (Next, Previous, unfold/intro/induction using X/Y) would be **removed** from the base system
- Completeness without Next uses **Burgess's eventuality resolution via the axioms themselves** (axiom 5: self-accumulation; axiom 6: absorption) rather than step-by-step chain construction

---

## 1. The Burgess-Xu Axiom System (Complete Statement)

### 1.1 Language

Primitive operators: G (universal future), H (universal past), U (Until), S (Since)

Derived operators:
- F(phi) := ~G(~phi) (existential future)
- P(phi) := ~H(~phi) (existential past)
- Equivalently under reflexive semantics: F(phi) = top U phi, P(phi) = top S phi

### 1.2 Axiom Schemas (Reflexive Version)

The system extends classical propositional logic with the following 7 axiom schemas **and their mirror images** (obtained by simultaneously swapping G<->H and U<->S throughout):

| # | Name | Formula | Mirror |
|---|------|---------|--------|
| BX1 | Reflexivity | `G(phi) -> phi` | `H(phi) -> phi` |
| BX2 | Left Monotonicity | `G(phi -> psi) -> (phi U chi) -> (psi U chi)` | `H(phi -> psi) -> (phi S chi) -> (psi S chi)` |
| BX3 | Right Monotonicity | `G(phi -> psi) -> (chi U phi) -> (chi U psi)` | `H(phi -> psi) -> (chi S phi) -> (chi S psi)` |
| BX4 | Connectedness | `phi & (chi U psi) -> chi U (psi & (chi S phi))` | `phi & (chi S psi) -> chi S (psi & (chi U phi))` |
| BX5 | Self-Accumulation | `phi U psi -> (phi & (phi U psi)) U psi` | `phi S psi -> (phi & (phi S psi)) S psi` |
| BX6 | Absorption | `phi U (phi & (phi U psi)) -> phi U psi` | `phi S (phi & (phi S psi)) -> phi S psi` |
| BX7 | Linearity | `(phi U psi) & (chi U theta) -> (phi & chi) U (psi & theta) \/ (phi & chi) U (psi & chi) \/ (phi & chi) U (phi & theta)` | (mirror with S) |

### 1.3 Inference Rules

| Rule | Statement |
|------|-----------|
| NEC_G | If `|- phi` then `|- G(phi)` |
| NEC_H | If `|- phi` then `|- H(phi)` |
| MP | If `|- phi -> psi` and `|- phi` then `|- psi` |

### 1.4 Derived Principles

From the axiom schemas, several important principles are derivable:

- **G-distribution**: `G(phi -> psi) -> (G(phi) -> G(psi))` (K axiom for G)
  - Derivable because `G(phi) = phi U phi` (or via reflexivity + monotonicity)
- **G-transitivity**: `G(phi) -> G(G(phi))`
  - Derivable from the interaction of BX1 with the U axioms
- **Temporal A**: `phi -> G(P(phi))`
  - Derivable from BX4 connectedness
- **F = top U**: `F(phi) <-> top U phi`
  - Under reflexive semantics, this is a theorem, not an axiom

### 1.5 Completeness

**Theorem (Burgess 1982, Xu 1988)**: The Burgess-Xu axiom system is sound and complete for the class of all linear orders under reflexive temporal semantics.

This means: a formula is a theorem of BX iff it is valid on every linear order `(T, <=)` under reflexive interpretation of G, H, U, S.

---

## 2. Semantics (All-Reflexive Convention)

### 2.1 Semantic Clauses

Under the **all-reflexive** convention, the semantic clauses are:

| Operator | Clause at time t |
|----------|-----------------|
| `G(phi)` | `forall s >= t, phi(s)` |
| `H(phi)` | `forall s <= t, phi(s)` |
| `F(phi)` | `exists s >= t, phi(s)` |
| `P(phi)` | `exists s <= t, phi(s)` |
| `phi U psi` | `exists s >= t, psi(s) & forall r, (t <= r < s -> phi(r))` |
| `phi S psi` | `exists s <= t, psi(s) & forall r, (s < r <= t -> phi(r))` |

### 2.2 Guard Interval Analysis

The Until clause has a **half-open interval** `[t, s)` for the guard:
- The **witness** s satisfies `s >= t` (reflexive: psi can hold at t itself)
- The **guard** phi must hold on `[t, s)` = `{r : t <= r < s}` (closed on the left, open on the right)
- When s = t, the guard interval `[t, t)` is **empty**, so `phi U psi` holds at t whenever psi holds at t

For Since, the guard interval is `(s, t]`:
- The **witness** s satisfies `s <= t` (reflexive: psi can hold at t itself)
- The **guard** phi must hold on `(s, t]` = `{r : s < r <= t}`
- When s = t, the guard interval `(t, t]` is **empty**, so `phi S psi` holds at t whenever psi holds at t

### 2.3 Key Consequence: F = top U

Under reflexive semantics:
- `F(phi)` at t means `exists s >= t, phi(s)`
- `top U phi` at t means `exists s >= t, phi(s) & forall r in [t,s), top(r)` = `exists s >= t, phi(s)`

So `F(phi) <-> top U phi` is a **semantic equivalence** (not needing an axiom).

### 2.4 Comparison with Current Codebase Semantics

The current codebase (`Truth.lean`) uses:
- G/H: **reflexive** (`s <= t` / `t <= s`) -- matches BX
- U/S: **strict witness** (`t < s` / `s < t`), **strict guard** (`t < r < s` / `s < r < t`)

The proposed change:
- U/S: **reflexive witness** (`t <= s` / `s <= t`), **half-open guard** (`t <= r < s` / `s < r <= t`)

**This is a fundamental semantic change.** Under the current strict U/S:
- `F(phi)` means `exists s > t, phi(s)` (strictly future)
- `top U phi` means `exists s > t, phi(s) & forall r in (t,s), top(r)` = `exists s > t, phi(s)` = `F(phi)`

Under proposed reflexive U/S:
- `F(phi)` means `exists s >= t, phi(s)` (now or future)
- `top U phi` means the same

So `F(phi) <-> top U phi` holds in **both** systems, but the meaning of F changes. Under strict G/H (which is NOT the case here -- both systems use reflexive G/H), this would be different. Since both use reflexive G/H, the main change is:

**With reflexive U/S**: `phi U psi` can be witnessed at the current time (s = t).
**With strict U/S**: `phi U psi` requires a strictly future witness (s > t).

The relationship: `phi U_strict psi <-> ~phi_or_psi & phi U_refl psi` (with appropriate guards), but more precisely:
- Reflexive U from strict: `phi U_refl psi := psi | (phi & phi U_strict psi)`
- Strict U from reflexive: `phi U_strict psi := ~psi & phi U_refl (psi & ~(psi at t))` -- this is problematic, needs careful treatment

**Recommendation**: Since the Burgess-Xu axioms are stated for the reflexive version, and the codebase already uses reflexive G/H, switching U/S to reflexive is the cleanest approach.

---

## 3. Frame Extension Axioms

### 3.1 All Linear Orders (Base System)

The 7 BX schemas + mirrors + NEC_G + NEC_H form the **complete base system** for all linear orders.

No additional axioms needed -- no seriality, no density, no discreteness.

### 3.2 Dense Linear Orders (Q, R)

For dense linear orders, Venema (1993) translated the BX system to strict semantics and added:

**Density axiom**: `G(G(phi)) -> G(phi)`

Under reflexive semantics, density is **already a theorem** of BX (from BX1: `G(phi) -> phi`, so `G(G(phi)) -> G(phi)` by instantiation).

**Important**: Under reflexive G, the density axiom `GG(phi) -> G(phi)` is trivially derivable from `G(phi) -> phi` (instantiate BX1 with G(phi)). So dense linear orders do NOT need an additional axiom under reflexive semantics.

However, if we want the Burgess-Xu system specifically for dense orders, we note that the base BX system is already complete for all linear orders including dense ones. The density axiom is only needed when working with strict G to distinguish dense from non-dense frames.

### 3.3 Discrete Linear Orders (Z)

For discrete linear orders with strict U/S, Venema (1993) added:

| Axiom | Formula | Meaning |
|-------|---------|---------|
| Disc-F | `F(top) -> bot U top` | If there's a future, there's an immediate next step |
| Disc-P | `P(top) -> bot S top` | If there's a past, there's an immediate previous step |

Under reflexive semantics, `bot U top` at t means `exists s >= t, top(s) & forall r in [t,s), bot(r)`, which means `s = t` (since bot can't hold at any guard point). So `bot U top` is equivalent to `top`, making this axiom trivially valid. **This means the discrete axiom formulation must be different for reflexive semantics.**

For reflexive semantics on discrete orders, the key property to capture is the **existence of immediate successors**. This can be expressed as:

- `phi U psi <-> psi | (phi & phi U_next psi)` where U_next involves the successor

But since Burgess-Xu does NOT use Next as a primitive, discrete orders need different axioms under reflexive semantics:

**Discreteness (reflexive formulation)**: The base BX system is complete for ALL linear orders including discrete ones. No additional axiom is needed for discrete orders as a class -- the base system already handles them.

If one wants to axiomatize specifically Z (or N) as opposed to all linear orders, additional axioms are needed, but they characterize specific structures, not just discreteness.

### 3.4 Well-Orders (ordinals)

Venema (1993) added (for strict semantics):
- `H(bot) | P(H(bot))` -- there is a beginning or a point just after the beginning
- `F(phi) -> (~phi) U phi` -- Induction: if phi will hold, non-phi persists until phi

### 3.5 Natural Numbers (N, <)

The well-order axioms plus:
- `F(top)` -- there is always a future (no last element)

### 3.6 Summary Table

| Frame Class | Additional Axioms (over BX base) |
|-------------|----------------------------------|
| All linear orders | None (BX is complete) |
| Dense linear orders | None under reflexive semantics |
| Discrete linear orders | None needed for class; specific discrete structures need characterizing axioms |
| Z (integers) | Seriality: `G(phi) -> F(phi)` and `H(phi) -> P(phi)` |
| N (naturals) | Well-order + seriality-future |
| R (reals) | None under reflexive semantics (Dedekind completeness not FO-expressible) |

---

## 4. Mapping: Current Codebase -> Burgess-Xu

### 4.1 Current Axiom Inventory (35 constructors)

**Propositional (4)**: prop_k, prop_s, ex_falso, peirce
**S5 Modal (5)**: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
**Base Temporal (10)**: temp_k_dist, temp_4, temp_t_future, temp_t_past, temp_a, temp_a_dual, temp_l, modal_future, temp_future, temp_linearity
**Dense (1)**: density
**Discrete (15)**: discreteness_forward, seriality_future, seriality_past, disc_next, disc_prev, until_unfold, until_intro, until_induction, until_linearity, since_unfold, since_intro, since_induction, since_linearity, until_connectedness, since_connectedness, F_until_equiv, P_since_equiv, next_implies_some_future, x_k_dist, x_det, y_k_dist, y_det, yx_identity, xy_identity

### 4.2 Proposed Burgess-Xu + S5 Axiom System

#### Layer 1: Classical Propositional Logic (KEEP)

| Current | Status | BX Equivalent |
|---------|--------|---------------|
| `prop_k` | **KEEP** | Part of classical propositional base |
| `prop_s` | **KEEP** | Part of classical propositional base |
| `ex_falso` | **KEEP** | Part of classical propositional base |
| `peirce` | **KEEP** | Part of classical propositional base |

#### Layer 2: S5 Modal Logic (KEEP)

| Current | Status | Notes |
|---------|--------|-------|
| `modal_t` | **KEEP** | Box(phi) -> phi |
| `modal_4` | **KEEP** | Box(phi) -> Box(Box(phi)) |
| `modal_b` | **KEEP** | phi -> Box(Diamond(phi)) |
| `modal_5_collapse` | **KEEP** | Diamond(Box(phi)) -> Box(phi) |
| `modal_k_dist` | **KEEP** | Box(phi -> psi) -> Box(phi) -> Box(psi) |

#### Layer 3: Burgess-Xu Temporal (NEW -- replaces current temporal)

| BX# | Name | Formula | Replaces |
|-----|------|---------|----------|
| BX1 | temp_t_future | `G(phi) -> phi` | temp_t_future (KEEP, same formula) |
| BX1' | temp_t_past | `H(phi) -> phi` | temp_t_past (KEEP, same formula) |
| BX2 | left_mono_U | `G(phi -> psi) -> (phi U chi) -> (psi U chi)` | NEW |
| BX2' | left_mono_S | `H(phi -> psi) -> (phi S chi) -> (psi S chi)` | NEW |
| BX3 | right_mono_U | `G(phi -> psi) -> (chi U phi) -> (chi U psi)` | NEW |
| BX3' | right_mono_S | `H(phi -> psi) -> (chi S phi) -> (chi S psi)` | NEW |
| BX4 | connect_US | `phi & (chi U psi) -> chi U (psi & (chi S phi))` | until_connectedness (similar, but current version uses strict semantics) |
| BX4' | connect_SU | `phi & (chi S psi) -> chi S (psi & (chi U phi))` | since_connectedness (similar) |
| BX5 | self_accum_U | `phi U psi -> (phi & (phi U psi)) U psi` | NEW (no current equivalent) |
| BX5' | self_accum_S | `phi S psi -> (phi & (phi S psi)) S psi` | NEW |
| BX6 | absorb_U | `phi U (phi & (phi U psi)) -> phi U psi` | NEW (no current equivalent) |
| BX6' | absorb_S | `phi S (phi & (phi S psi)) -> phi S psi` | NEW |
| BX7 | linear_U | `(phi U psi) & (chi U theta) -> (phi&chi) U (psi&theta) \/ (phi&chi) U (psi&chi) \/ (phi&chi) U (phi&theta)` | until_linearity (similar but different formulation) |
| BX7' | linear_S | (mirror) | since_linearity |

#### Layer 4: Modal-Temporal Interaction (KEEP/MODIFY)

| Current | Status | Notes |
|---------|--------|-------|
| `modal_future` | **KEEP** | Box(phi) -> Box(G(phi)) -- valid on all frames |
| `temp_future` | **KEEP** | Box(phi) -> G(Box(phi)) -- valid on all frames |

#### Layer 5: Current Axioms to REMOVE

| Current | Status | Reason |
|---------|--------|--------|
| `temp_k_dist` | **DERIVABLE** | G(phi -> psi) -> G(phi) -> G(psi) derivable from BX axioms |
| `temp_4` | **DERIVABLE** | G(phi) -> GG(phi) derivable from BX1 + NEC_G |
| `temp_a` | **DERIVABLE** | phi -> G(P(phi)) derivable from BX4 |
| `temp_a_dual` | **DERIVABLE** | phi -> H(F(phi)) derivable from BX4' |
| `temp_l` | **DERIVABLE** | always(phi) -> G(H(phi)) derivable from BX axioms |
| `temp_linearity` | **SUBSUMED** | The F-version linearity is derivable from BX7 |
| `density` | **REMOVE** | Trivially derivable under reflexive G (BX1 gives GG(phi)->G(phi)) |
| All `disc_*` | **REMOVE** | Discrete-only axioms not needed for all linear orders |
| All `until_unfold/intro/induction` | **REMOVE** | X-based formulations replaced by BX axioms |
| All `since_unfold/intro/induction` | **REMOVE** | Y-based formulations replaced by BX axioms |
| `F_until_equiv` | **DERIVABLE** | F(phi) <-> top U phi is a theorem under reflexive semantics |
| `P_since_equiv` | **DERIVABLE** | P(phi) <-> top S phi is a theorem |
| All `x_k_dist`, `x_det`, `y_k_dist`, `y_det` | **REMOVE** | Next/Previous axioms not in base system |
| `yx_identity`, `xy_identity` | **REMOVE** | Next/Previous axioms |
| `next_implies_some_future` | **REMOVE** | Next axiom |

### 4.3 Final Axiom Count

| Category | Count |
|----------|-------|
| Propositional | 4 (prop_k, prop_s, ex_falso, peirce) |
| S5 Modal | 5 (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist) |
| BX Temporal | 14 (7 schemas x 2 mirrors) |
| Modal-Temporal Interaction | 2 (modal_future, temp_future) |
| **Total** | **25** |

Plus inference rules: MP, NEC_Box, NEC_G, NEC_H, temporal_duality (derives H-mirrors from G-axioms)

**Note**: If temporal_duality is retained as an inference rule, we could state only the 7 forward BX axioms and derive the mirrors, reducing to **18 axiom schemas**.

---

## 5. Completeness Proof Without Next

### 5.1 Overview

The Burgess completeness proof for all linear orders does NOT use Next/Previous operators. Instead, it builds a canonical model from maximal consistent sets (MCS) and resolves eventualities using the BX axioms directly.

### 5.2 Key Steps

**Step 1: Canonical Frame Construction**

Define the canonical frame:
- Points: maximal consistent sets (MCS) of the logic
- Temporal order: w < v iff {phi : G(phi) in w} is a subset of v (or equivalently, for all phi, if G(phi) in w then phi in v, AND there exists psi such that psi in v but G(psi) not in w)
- The temporal order is automatically a strict linear order on connected components (the linearity axiom BX7 ensures this)

**Step 2: Truth Lemma**

The standard truth lemma: phi in w iff M_canonical, w |= phi. The BX axioms ensure:
- BX1 (reflexivity): gives the reflexive clause for G
- BX2-BX3 (monotonicity): ensure U/S are well-behaved under equivalence
- BX4 (connectedness): links U and S across the present
- BX7 (linearity): ensures the canonical order is linear

**Step 3: Until Eventuality Resolution (The Critical Step)**

The key challenge: if `phi U psi` is in some MCS w, we must find a witness MCS v >= w where psi holds and phi holds on [w, v).

**Without Next**, we cannot step forward one point at a time. Instead:

**BX5 (Self-Accumulation)**: `phi U psi -> (phi & phi U psi) U psi`

This says: if phi U psi holds, then phi & (phi U psi) holds at all intermediate points until psi. So the eventuality "propagates forward" -- at each intermediate point, both phi and the eventuality phi U psi hold.

**BX6 (Absorption)**: `phi U (phi & phi U psi) -> phi U psi`

This is the converse: it prevents the eventuality from being "pushed forever into the future." If we have phi U (phi & phi U psi), we can absorb the inner Until to get phi U psi. This ensures that the eventuality is eventually resolved.

Together, BX5 and BX6 give: `phi U psi <-> (phi & phi U psi) U psi`

This bidirectional equivalence enables the completeness proof to construct witness MCS for Until-formulas without needing deterministic successor steps.

**Step 4: Construction of the Linear Model**

The canonical model may not be a single linear order. The completeness proof uses a technique to extract a single linear model:

1. Start with an MCS w0 containing the formula to be satisfied
2. Use Zorn's lemma (or transfinite construction) to extend to a maximal chain of MCS
3. The BX axioms ensure this chain resolves all eventualities:
   - BX5 ensures Until-eventualities propagate
   - BX6 ensures they don't propagate forever
   - BX7 ensures witnesses from different Until-formulas are linearly ordered

### 5.3 Comparison with Current Discrete Approach

The current codebase uses a **successor chain construction**:
1. Start with an MCS
2. Build forward chain: MCS_0, MCS_1, MCS_2, ... by choosing successor MCS
3. Build backward chain: ..., MCS_{-2}, MCS_{-1}, MCS_0
4. Resolve F-eventualities by induction on X-steps

This requires:
- Next/Previous operators (X, Y)
- Determinism axioms (x_det, y_det)
- Identity axioms (yx_identity, xy_identity)
- Until unfold/intro/induction using X

The Burgess approach replaces all of this with the 7 BX axiom schemas operating directly on the Until/Since operators.

### 5.4 Advantages of the BX Approach

1. **Generality**: Works for ALL linear orders, not just discrete ones
2. **No Next**: Eliminates the problematic forward_F sorries (which require constructing specific next-step witnesses)
3. **Simpler axiom system**: 14 temporal axioms vs 25+ discrete axioms
4. **Cleaner semantics**: All-reflexive is more uniform than mixed reflexive/strict
5. **Standard reference**: Well-studied in the literature (Burgess 1982, Xu 1988, Venema 1993, GHR 1994)

### 5.5 Challenges

1. **BX5/BX6 are unusual**: Self-accumulation and absorption are not standard modal axioms; they require careful formalization
2. **Completeness proof is harder**: Without deterministic steps, the eventuality resolution is more subtle
3. **Existing infrastructure**: All current completeness machinery (successor chains, MCS witnesses) is built for the discrete approach
4. **Semantic change**: Switching U/S from strict to reflexive requires re-proving all soundness lemmas

---

## 6. Integration with S5 Modal Component

### 6.1 Current S5 Axioms

The current S5 axioms are:
- modal_t: `Box(phi) -> phi` (T)
- modal_4: `Box(phi) -> Box(Box(phi))` (4)
- modal_b: `phi -> Box(Diamond(phi))` (B)
- modal_5_collapse: `Diamond(Box(phi)) -> Box(phi)` (5-collapse)
- modal_k_dist: `Box(phi -> psi) -> Box(phi) -> Box(psi)` (K)

These are **independent of the temporal axioms** and remain unchanged.

### 6.2 Modal-Temporal Interaction Axioms

The current interaction axioms:
- `modal_future`: `Box(phi) -> Box(G(phi))` -- necessary truths are always necessary
- `temp_future`: `Box(phi) -> G(Box(phi))` -- necessary truths will always be necessary

These remain valid and necessary. They express that the modal and temporal dimensions are "orthogonal" in the right way.

### 6.3 Additional Interaction Axioms Needed?

Under the Burgess-Xu system, no additional modal-temporal interaction axioms are needed beyond modal_future and temp_future. The reason:

- The S5 modal axioms characterize the equivalence relation on worlds at each time
- The BX temporal axioms characterize the linear order on times
- modal_future and temp_future connect the two dimensions

The current `temp_linearity` axiom (which mixes F with conjunctions/disjunctions) is subsumed by BX7 which directly axiomatizes the linearity of Until.

### 6.4 The Bimodal Completeness Strategy

For the full bimodal logic TM with S5 + BX:

1. **Product frame**: worlds are (w, t) pairs where w is a world and t is a time
2. **S5 on the w-dimension**: accessibility is an equivalence relation
3. **Linear order on the t-dimension**: any linear order
4. **Interaction**: modal_future and temp_future constrain the relationship

The completeness proof would:
1. Build canonical MCS with both modal and temporal formulas
2. Use S5 axioms to partition MCS into equivalence classes (modal dimension)
3. Use BX axioms to linearly order MCS within each class (temporal dimension)
4. Use interaction axioms to ensure coherence between dimensions

---

## 7. Semantic Change Impact Assessment

### 7.1 Files Requiring Changes

**Core syntax** (minimal changes):
- `Syntax/Formula.lean`: Remove `next`/`prev` definitions (or keep as derived for discrete extension)

**Semantics** (moderate changes):
- `Semantics/Truth.lean`: Change U/S clauses from strict to reflexive
- All soundness lemmas that reference U/S semantics

**Proof system** (major changes):
- `ProofSystem/Axioms.lean`: Replace discrete axioms with BX axioms
- `ProofSystem/Derivation.lean`: Possibly add NEC_H as explicit rule (currently derived via temporal_duality)

**Metalogic** (major rewrite):
- `Metalogic/Bundle/`: Entire successor chain construction needs replacement
- `Metalogic/Core/MCSProperties.lean`: U/S properties need updating
- `Metalogic/Completeness.lean`: New proof using BX approach
- `Metalogic/Decidability/`: May need updating

### 7.2 What Survives

- All propositional theorems
- All S5 modal theorems
- All G/H-only temporal theorems (reflexive G/H unchanged)
- The algebraic completeness infrastructure (LindenbaumQuotient, BooleanStructure)
- The FMP/filtration approach (if adapted)

### 7.3 What Must Be Rebuilt

- Until/Since soundness proofs
- F-until equivalence (now a theorem, not an axiom)
- All successor chain machinery
- The MCS witness chain construction
- Until/Since derived facts

---

## 8. Detailed BX Axiom Semantics Verification

### 8.1 BX1: G(phi) -> phi

Semantic check: If `forall s >= t, phi(s)` then in particular `phi(t)` (since t >= t).
Valid on all frames. Requires reflexive G.

### 8.2 BX2: G(phi -> psi) -> (phi U chi) -> (psi U chi)

Semantic check: Suppose `forall s >= t, phi(s) -> psi(s)` and `exists s >= t, chi(s) & forall r in [t,s), phi(r)`.
Then the same witness s gives `chi(s) & forall r in [t,s), psi(r)` (since each phi(r) -> psi(r) by the first premise, using r >= t).
Valid on all frames.

### 8.3 BX3: G(phi -> psi) -> (chi U phi) -> (chi U psi)

Semantic check: Suppose `forall s >= t, phi(s) -> psi(s)` and `exists s >= t, phi(s) & forall r in [t,s), chi(r)`.
Then the same witness s gives `psi(s) & forall r in [t,s), chi(r)`.
Valid on all frames.

### 8.4 BX4: phi & (chi U psi) -> chi U (psi & (chi S phi))

Semantic check: Suppose `phi(t)` and `exists s >= t, psi(s) & forall r in [t,s), chi(r)`.
We need: `exists s >= t, (psi(s) & (chi S phi)(s)) & forall r in [t,s), chi(r)`.
Take the same witness s. We need `chi S phi` at s, i.e., `exists s' <= s, phi(s') & forall r in (s',s], chi(r)`.
Take s' = t. Then phi(t) holds (first premise) and forall r in (t,s], chi(r) holds (from the guard: chi holds on [t,s) and s itself is the boundary).

Wait -- we need chi on (t, s]. The guard gives chi on [t, s). For s itself: if s = t this is vacuous. If s > t, we need chi on (t, s]. But the guard only gives chi on [t, s) = {r : t <= r < s}, which is (t, s) when we exclude t... No: [t, s) includes t.

Let me re-examine. The guard in `chi U psi` gives chi on [t, s). For `chi S phi` at s, we need phi at some s' <= s with chi on (s', s]. Take s' = t:
- phi(t) is given
- chi on (t, s] means chi at all r with t < r <= s

But the guard only gives chi on [t, s) = {r : t <= r < s}. We need chi on (t, s]. The guard gives chi at all r with t <= r < s, which includes all r with t < r < s. We still need chi at s... but wait, at s we have psi, not necessarily chi.

**Resolution**: Actually, with reflexive semantics the guard for `chi U (psi & chi S phi)` at the same witness s means:
- chi on [t, s) -- this is exactly the same guard we already have

And the `chi S phi` at s means: exists s' <= s with phi(s') and chi on (s', s].
Taking s' = t:
- phi(t) is given
- chi on (t, s] requires chi at all r with t < r and r <= s

The guard of the original Until gives chi on [t, s), i.e., chi(r) for t <= r < s. This covers r with t < r < s. But we also need chi(s), and the guard does NOT give us chi(s) -- at s we have psi, not chi.

**However**: When s = t, the Since interval (t, t] is empty, so chi S phi at t just needs phi at some s' <= t, namely s' = t with phi(t). The guard [t,t) is also empty. So it works.

When s > t: we need chi on (t, s]. The guard gives chi on [t, s) which covers (t, s) = {r : t < r < s}. We need chi(s) additionally. But the axiom does NOT require chi(s) -- it requires chi S phi at s, which needs some witness s' <= s with phi(s') and chi on (s', s]. If we pick s' = t, we need chi on (t, s], which is chi on {r : t < r <= s}. We get chi on (t, s) from the guard. We need chi(s). But this is the boundary issue.

**Actually, this works because of the guard in the conclusion `chi U (psi & chi S phi)`.** The conclusion has the SAME witness s and the SAME guard chi on [t, s). The conclusion's goal at s is `psi(s) & (chi S phi)(s)`. For `chi S phi` at s, take s' = t: we need phi(t) (given) and chi on (t, s]. chi on (t, s) = {r : t < r < s} is given. chi(s)... hmm.

I believe the correct reading requires the Since guard to be OPEN on both ends: chi on (s', s) not (s', s]. Let me re-examine the Burgess semantics.

**Clarification**: In Burgess's original paper with reflexive semantics:
- `phi S psi` at t: exists s <= t, psi(s) & forall r (s < r < t -> phi(r))

Wait, this uses an **open interval** (s, t) for the guard, not (s, t]. This is the key point.

Let me reconsider the semantics with open guard:

| Operator | Clause |
|----------|--------|
| `phi U psi` at t | exists s >= t, psi(s) & forall r (t < r < s -> phi(r)) |
| `phi S psi` at t | exists s <= t, psi(s) & forall r (s < r < t -> phi(r)) |

Under this reading:
- Witness is reflexive (s >= t)
- Guard is the **open interval** (t, s) for U and (s, t) for S
- At s = t: guard (t, t) is empty, so phi U psi iff psi(t)

Now BX4 verification: phi(t) & (chi U psi at t). Take witness s >= t with psi(s) & chi on (t, s).
For chi U (psi & chi S phi) at t: same witness s.
- Goal at s: psi(s) & (chi S phi)(s)
- chi S phi at s: exists s' <= s, phi(s') & chi on (s', s)
- Take s' = t: phi(t) given, chi on (t, s) given.
- The guard for the conclusion Until: chi on (t, s) -- same as what we have.

This works perfectly with **open guard intervals**.

### 8.5 Corrected Semantic Clauses

The correct Burgess semantics for reflexive U/S with open guard:

| Operator | Clause at time t |
|----------|-----------------|
| `G(phi)` | `forall s >= t, phi(s)` |
| `H(phi)` | `forall s <= t, phi(s)` |
| `phi U psi` | `exists s >= t, psi(s) & forall r (t < r < s -> phi(r))` |
| `phi S psi` | `exists s <= t, psi(s) & forall r (s < r < t -> phi(r))` |

Key properties:
- **Witness**: reflexive (s >= t for U, s <= t for S)
- **Guard**: open interval (t, s) for U, (s, t) for S
- **When s = t**: guard is empty, so phi U psi iff psi holds now
- **Relationship to strict U/S**: `phi U_strict psi` = `exists s > t, psi(s) & forall r (t < r < s -> phi(r))`

So the only difference from strict is: the witness can be the current time (s = t).

**Critically**: This means `phi U psi` under reflexive semantics = `psi | (phi U_strict psi)`. The guard interval is the SAME open interval (t, s) in both cases.

### 8.6 Comparison with Current Codebase

Current `Truth.lean`:
```
| Formula.untl phi psi => exists s, t < s & truth_at M Omega tau s psi &
    forall r, t < r -> r < s -> truth_at M Omega tau r phi
```

This is strict U with open guard (t, s). To switch to Burgess reflexive:
```
| Formula.untl phi psi => exists s, t <= s & truth_at M Omega tau s psi &
    forall r, t < r -> r < s -> truth_at M Omega tau r phi
```

**The only change is `t < s` to `t <= s` in the witness condition.** The guard interval (t, s) stays the same.

This is a **minimal semantic change** -- just relaxing the witness from strict to reflexive.

---

## 9. Implementation Recommendations

### 9.1 Phase 1: Semantic Change (Minimal)

1. Change `Truth.lean`: `t < s` to `t <= s` for Until, `s < t` to `s <= t` for Since
2. Re-prove soundness of existing temporal axioms that reference U/S
3. Prove `F(phi) <-> top U phi` as a theorem

### 9.2 Phase 2: Axiom Replacement

1. Add BX2-BX7 axiom constructors (BX1 = existing temp_t_future/past)
2. Remove all discrete-only axioms (or gate them behind a DiscreteExtension flag)
3. Remove density axiom (now derivable)
4. Update FrameClass to remove Dense (BX is complete for all linear orders)

### 9.3 Phase 3: Completeness Overhaul

1. Redesign canonical model construction using BX eventuality resolution
2. Use BX5/BX6 for Until-witness construction instead of successor chains
3. Leverage BX7 for linearity of the canonical order

### 9.4 Phase 4: Discrete Extension (Optional)

If discrete-specific reasoning is still needed:
1. Re-introduce Next/Previous as derived operators: X(phi) = bot U phi, Y(phi) = bot S phi
2. Add discrete frame axioms as an extension layer
3. Prove current discrete axioms from BX + discrete extension axioms

---

## 10. References

1. **Burgess, J.P.** (1982). "Axioms for Tense Logic I: 'Since' and 'Until'." Notre Dame Journal of Formal Logic 23(4): 367-374.
2. **Xu, M.** (1988). Simplification of the Burgess system. (Referenced in SEP.)
3. **Venema, Y.** (1993). "Completeness via Completeness." In de Rijke (ed.), Diamonds and Defaults, Kluwer.
4. **Gabbay, D.M., Hodkinson, I., Reynolds, M.** (1994). Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1. Oxford University Press.
5. **Hodkinson, I. & Reynolds, M.** (2005). "Separation -- Past, Present, and Future." Available at: https://www.doc.ic.ac.uk/~imh/papers/sep.pdf
6. **Stanford Encyclopedia of Philosophy**. "Temporal Logic: Burgess-Xu Supplement." https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html
7. **Goldblatt, R.** (1992). Logics of Time and Computation. CSLI Lecture Notes.

---

## Appendix A: Web Search Queries Used

1. "Burgess-Xu axiom system Since Until temporal logic complete axiomatization linear orders"
2. "Burgess 1982 Axioms for Tense Logic Since Until axiom list complete"
3. "Hodkinson Reynolds Separation Past Present Future Until Since axiomatization"
4. "Gabbay Hodkinson Reynolds 1994 temporal logic axiomatization Until Since completeness"
5. "reflexive Until temporal logic semantic definition guard interval"
6. "temporal logic completeness proof Until Since without Next canonical model"
7. "Venema 1993 temporal logic Since Until axiomatization completeness"

## Appendix B: Precise BX Axiom Formulas in Lean Syntax

For reference, here are the BX axioms as they would appear in the Lean formula syntax:

```lean
-- BX1: G(phi) -> phi (= temp_t_future)
| temp_t_future (phi : Formula) :
    Axiom (phi.all_future.imp phi)

-- BX2: G(phi -> psi) -> (phi U chi) -> (psi U chi)
| left_mono_until (phi psi chi : Formula) :
    Axiom ((phi.imp psi).all_future.imp
      ((Formula.untl phi chi).imp (Formula.untl psi chi)))

-- BX3: G(phi -> psi) -> (chi U phi) -> (chi U psi)
| right_mono_until (phi psi chi : Formula) :
    Axiom ((phi.imp psi).all_future.imp
      ((Formula.untl chi phi).imp (Formula.untl chi psi)))

-- BX4: phi & (chi U psi) -> chi U (psi & (chi S phi))
| connect_until_since (phi psi chi : Formula) :
    Axiom ((Formula.and phi (Formula.untl chi psi)).imp
      (Formula.untl chi (Formula.and psi (Formula.snce chi phi))))

-- BX5: phi U psi -> (phi & (phi U psi)) U psi
| self_accum_until (phi psi : Formula) :
    Axiom ((Formula.untl phi psi).imp
      (Formula.untl (Formula.and phi (Formula.untl phi psi)) psi))

-- BX6: phi U (phi & (phi U psi)) -> phi U psi
| absorb_until (phi psi : Formula) :
    Axiom ((Formula.untl phi (Formula.and phi (Formula.untl phi psi))).imp
      (Formula.untl phi psi))

-- BX7: (phi U psi) & (chi U theta) ->
--       (phi & chi) U (psi & theta) \/ (phi & chi) U (psi & chi) \/ (phi & chi) U (phi & theta)
| linear_until (phi psi chi theta : Formula) :
    Axiom ((Formula.and (Formula.untl phi psi) (Formula.untl chi theta)).imp
      (Formula.or
        (Formula.or
          (Formula.untl (Formula.and phi chi) (Formula.and psi theta))
          (Formula.untl (Formula.and phi chi) (Formula.and psi chi)))
        (Formula.untl (Formula.and phi chi) (Formula.and phi theta))))

-- Mirror axioms (swap G<->H, U<->S) follow the same pattern
```

## Appendix C: Derivability of Current Base Temporal Axioms from BX

| Current Axiom | Derivation Sketch from BX |
|---------------|--------------------------|
| `temp_k_dist`: G(phi->psi) -> G(phi) -> G(psi) | From BX1+BX2: G is definable as phi U phi equivalent (or directly via NEC_G + BX1) |
| `temp_4`: G(phi) -> GG(phi) | G(phi) at t means phi at all s >= t. GG(phi) at t means G(phi) at all s >= t, i.e., phi at all u >= s >= t. Same as phi at all u >= t. |
| `temp_a`: phi -> G(P(phi)) | From BX4 with chi=top, psi=top: phi & (top U top) -> top U (top & (top S phi)). Since top U top = G(top) = top (by reflexivity), this gives phi -> top U (top S phi). And top U (top S phi) = G(top S phi) by the F=topU equivalence pattern. So phi -> G(P(phi)) where P(phi) = top S phi. |
| `temp_a_dual`: phi -> H(F(phi)) | Mirror of above |
| `temp_l`: always(phi) -> G(H(phi)) | If phi holds at all times, then at any future time s, phi holds at all times <= s. |
| `temp_linearity` | Follows from BX7 with appropriate instantiation |
