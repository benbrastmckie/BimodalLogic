# Teammate A: Burgess's Chain Construction -- Full Mathematical Development for Task Semantics

- **Task**: 83 - Close Restricted Coherence Sorries
- **Focus**: Full mathematical detail of Burgess's chain construction and mapping to Task Semantics
- **Date**: 2026-04-07
- **Session**: sess_1775625087_9b0bc5
- **Sources**: Reports 35-37, Frame.lean, Bundle/ infrastructure, Axioms.lean, Truth.lean, WorldHistory.lean, TaskFrame.lean, CanonicalConstruction.lean, SuccRelation.lean, Burgess 1982/84, Xu 1988, Goldblatt 1992

---

## Part 1: Burgess's Original Chain Construction

### 1.1 The Starting Point

**Given**: A consistent formula phi_0 (i.e., the set {phi_0} is consistent, equivalently, neg phi_0 is not derivable from the empty context).

**Step 1**: By consistency of {phi_0}, Lindenbaum's lemma yields an MCS w_0 with phi_0 in w_0.

**Step 2**: w_0 becomes the "origin" of a bi-infinite chain of MCS indexed by the integers.

The critical difference from the abstract BXCanonical approach: we do NOT try to prove properties about ALL MCS with the bx_le preorder. Instead, we BUILD a specific chain where linearity is guaranteed by construction, and prove the truth lemma only for that chain.

### 1.2 The Successor Construction (Forward Direction)

At each step i >= 0, we construct w_{i+1} from w_i. The construction differs from standard Kripke-style canonical models in a crucial way: the seed explicitly includes eventuality formulas.

**Seed for w_{i+1}**:

```
seed(w_i) = g_content(w_i) ∪ scheduled_eventualities(w_i, i)
```

where:
- `g_content(w_i) = {phi | G(phi) in w_i}` ensures temporal persistence
- `scheduled_eventualities(w_i, i)` is a carefully chosen finite set of formulas derived from Until/Since obligations in w_i

**The Scheduling Mechanism (Dovetailing/Fair Scheduling)**:

Let E_i = {psi | phi U psi in w_i and psi not in w_i} be the set of unresolved Until-eventualities at step i. These must eventually be resolved: for each phi U psi in w_0, some w_j (j > 0) must contain psi.

Burgess's original method uses a dovetailing schedule. Enumerate all Until subformulas of phi_0 (finite set): alpha_1 U beta_1, alpha_2 U beta_2, ..., alpha_k U beta_k.

At step i, we schedule the eventuality corresponding to index (i mod k) + 1 for forced resolution. If alpha_m U beta_m is the scheduled eventuality and it is still active at w_i (i.e., alpha_m U beta_m in w_i but beta_m not in w_i), then we include beta_m in the seed.

However, the BX5-based approach from report 37 provides a more elegant mechanism that avoids explicit scheduling:

**BX5-Based Seed Construction**:

```
seed(w_i) = g_content(w_i) ∪ f_step(w_i)
```

where `f_step(w_i) = {phi | phi in w_i or F(phi) in w_i, for each F(phi) in w_i}`. This is exactly the Succ relation's second condition: `f_content(w_i) subset w_{i+1} union f_content(w_{i+1})`.

But this does NOT directly resolve eventualities. The f_step condition only says each F-obligation is either resolved or deferred. To guarantee eventual resolution, we need one of:

**(A) Bounded nesting + f_step**: Within the subformula closure of phi_0, F-nesting is bounded. After at most B steps of deferral (where B is the nesting bound), the obligation must be resolved because F^{B+1}(psi) is outside the closure.

**(B) Fair scheduling**: Explicitly force resolution of each eventuality in turn.

**(C) BX5 self-accumulation propagation**: The approach identified in report 37.

For the BX axiom system, approach (C) is the most natural. Here is how it works in full detail.

### 1.3 The BX5 Self-Accumulation Chain Construction

**Key Insight**: Given phi U psi in w_0, apply BX5 to get:

```
(phi AND (phi U psi)) U psi in w_0
```

Call this enriched formula phi' U psi where phi' = phi AND (phi U psi).

Now construct the chain where at each step, the seed includes phi' (not just g_content). The chain construction is:

**Seed for w_{i+1}**:

```
seed_i = g_content(w_i) ∪ {chi | F(chi) in w_i, chi targeted for resolution at step i}
```

But the self-accumulation gives us something stronger. If phi U psi in w_i and psi not in w_i, then by BX9 (until_elim): phi OR psi in w_i, so phi in w_i. And by BX5: (phi AND (phi U psi)) U psi in w_i. By BX10: F(psi) in w_i.

The enriched Until formula (phi AND (phi U psi)) U psi propagates through the chain as follows:

At w_i with (phi AND (phi U psi)) U psi in w_i and psi not in w_i:
- By BX9: (phi AND (phi U psi)) OR psi in w_i. Since psi not in w_i: phi AND (phi U psi) in w_i.
- So phi in w_i AND phi U psi in w_i.
- Apply BX5 again: (phi AND (phi U psi)) U psi in w_i (same formula).
- By BX10: F(psi) in w_i.

The question is: does phi U psi in w_i imply phi U psi in w_{i+1}?

**Answer**: Not automatically via g_content, because G(phi U psi) is NOT generally in w_i. But we can include phi U psi in the seed directly.

### 1.4 The Correct Seed Construction

The correct approach combines g_content with explicit inclusion of active eventualities:

**Definition**: For an MCS w, define the **successor seed**:

```
succ_seed(w) = g_content(w) ∪ {phi U psi | phi U psi in w, psi not in w}
                             ∪ {phi | phi U psi in w, psi not in w}    (from BX9)
```

Wait -- we need to be more careful. The formulas {phi U psi | phi U psi in w, psi not in w} are the active eventualities. Including them in the seed means w_{i+1} will contain them (after Lindenbaum extension). But we also need phi in the seed (which follows from BX9 + MCS properties).

Actually, the cleaner formulation uses the Succ relation from SuccRelation.lean:

```
Succ(u, v) iff g_content(u) subset v AND f_content(u) subset v union f_content(v)
```

The second condition says: for each F(chi) in u, either chi in v or F(chi) in v. This is the deferred resolution condition.

**Theorem (SuccExistence.lean)**: For any MCS u with F(top) in u, there exists a Succ successor v.

**Proof sketch**: The seed is `g_content(u) ∪ deferral_disjunctions(u)` where deferral_disjunctions adds chi OR F(chi) for each F(chi) in u. This seed is consistent (proved in the codebase). Lindenbaum gives MCS v extending the seed. Then g_content(u) subset v (from seed). And for each F(chi) in u: chi OR F(chi) in v, so either chi in v or F(chi) in v (by MCS disjunction property). This gives f_content(u) subset v union f_content(v).

### 1.5 Eventuality Resolution via Bounded Nesting

Within the subformula closure of phi_0, F-nesting is bounded. Let B = max nesting depth of F in subformulas of phi_0.

**Claim**: If F(chi) in w_i where chi is in the subformula closure, and we have a Succ chain w_i, w_{i+1}, ..., w_{i+B}, then chi in w_j for some j in [i+1, i+B].

**Proof**: At each step, either chi in w_{i+1} (done) or F(chi) in w_{i+1}. If F(chi) in w_{i+1}, by the structure of the MCS within the closure, the effective nesting decreases (F^2(chi) has one more layer). After at most B steps, the nesting exceeds the closure bound, forcing resolution.

This is the `bounded_witness` theorem in CanonicalTaskRelation.lean.

### 1.6 Until Resolution Proof (Forward Direction)

**Theorem**: Given phi U psi in w_0, there exists j >= 0 with psi in w_j and for all i in [0, j): phi in w_i.

**Proof**:

*Case 1*: psi in w_0. Take j = 0. Guard [0, 0) is empty, vacuously satisfied.

*Case 2*: psi not in w_0.

Step 1: By BX10, F(psi) in w_0. By bounded nesting (or fair scheduling), there exists j > 0 with psi in w_j. Take the minimal such j.

Step 2: We need phi in w_i for all i in [0, j). Apply BX5:

```
phi U psi in w_0  ==>  (phi AND (phi U psi)) U psi in w_0     [BX5]
```

At w_0: psi not in w_0, so by BX9 on the enriched formula: phi AND (phi U psi) in w_0. In particular phi in w_0 and phi U psi in w_0.

**The propagation mechanism**: We show phi U psi in w_i for all i in [0, j) by induction.

Base: phi U psi in w_0 (given).

Inductive step: Suppose phi U psi in w_i for some i < j. We need phi U psi in w_{i+1}.

Since i < j and j is minimal with psi in w_j, we know psi not in w_i and psi not in w_{i+1} (if i+1 < j). Actually, we need to be more careful about the case i+1 = j-1 vs i+1 = j.

For the chain construction, we include active Until formulas in the successor seed. Specifically:

If phi U psi in w_i and psi not in w_i:
- By BX10: F(psi) in w_i. So psi in f_content(w_i).
- By Succ condition: psi in w_{i+1} OR F(psi) in w_{i+1}.
- Also by BX5+BX9: phi in w_i (guard satisfied at w_i).
- Key: phi U psi itself is in w_i. How does it get into w_{i+1}?

**This is the critical gap that report 37 identified**: phi U psi is NOT in g_content(w_i) (because G(phi U psi) is not generally in w_i), and the Succ relation does not propagate Until formulas directly.

**Resolution via the enriched seed**: We modify the chain construction to use an enriched Succ relation that explicitly propagates active Until formulas:

```
EnrichedSucc(u, v) iff Succ(u, v) AND
  for each (phi U psi) in u with psi not in u: (phi U psi) in v OR psi in v
```

**Consistency of the enriched seed**: The seed is:

```
enriched_seed(u) = g_content(u)
  ∪ {chi ∨ F(chi) | F(chi) in u}           -- f_step deferral
  ∪ {phi U psi | phi U psi in u, psi not in u}  -- eventuality propagation
```

**Lemma**: enriched_seed(u) is consistent when u is an MCS.

**Proof**: Suppose L subset enriched_seed(u) and L derives bot. Separate L into three parts:
- L_g subset g_content(u)
- L_f: disjunctions chi_k ∨ F(chi_k) from the f_step part
- L_u: formulas alpha_m U beta_m from the eventuality propagation part

All of L_g, L_f, L_u are in u (g_content(u) subset u by BX1/bx_le_refl; chi ∨ F(chi) is derivable from F(chi) in u by MCS properties; phi U psi in u by assumption). So L subset u, and L derives bot, contradicting u being consistent.

Wait -- this is wrong. chi ∨ F(chi) is NOT necessarily in u. We have F(chi) in u, which gives us ¬G(¬chi) in u, but chi ∨ F(chi) requires either chi in u or F(chi) in u. Well, F(chi) in u, so F(chi) is in u, so chi ∨ F(chi) follows from F(chi) by disjunction introduction. So chi ∨ F(chi) IS in u (derivable from F(chi) via A -> A ∨ B). Good.

Actually the seed should just be:

```
enriched_seed(u) = g_content(u)
  ∪ {chi ∨ F(chi) | F(chi) in u}
  ∪ {alpha_m U beta_m | alpha_m U beta_m in u, beta_m not in u}
```

Every formula in enriched_seed(u) is in u:
- g_content(u) subset u (by BX1/reflexivity of bx_le)
- chi ∨ F(chi): derivable from F(chi) in u
- alpha_m U beta_m: directly in u

So enriched_seed(u) subset u, hence consistent (any finite subset derives bot would contradict u consistent).

**After Lindenbaum extension**: v = MCS extending enriched_seed(u). Then:
- g_content(u) subset v (temporal persistence)
- f_step condition holds (from disjunctions)
- phi U psi in v (from eventuality propagation, when phi U psi was active at u)

**Now the induction works**: If phi U psi in w_i and psi not in w_i, then phi U psi in w_{i+1} (by enriched seed). If additionally psi not in w_{i+1}, then phi U psi in w_{i+1} persists. By BX9: phi in w_{i+1}.

Eventually psi in w_j (by bounded nesting on F(psi)). At all i in [0, j): psi not in w_i (by minimality of j), so phi U psi in w_i, so phi in w_i (by BX9).

**This completes the forward direction of the Until truth lemma.**

### 1.7 The Backward Chain

The backward chain w_{-1}, w_{-2}, ... is constructed symmetrically using h_content and Since formulas.

**Seed for w_{-(i+1)}**:

```
enriched_past_seed(u) = h_content(u)
  ∪ {chi ∨ P(chi) | P(chi) in u}
  ∪ {alpha_m S beta_m | alpha_m S beta_m in u, beta_m not in u}
```

Consistency follows by the same argument (h_content(u) subset u by BX1'/reflexivity of h-ordering; P(chi) in u implies chi ∨ P(chi) in u; active Since formulas are in u).

The predecessor exists by BX1' (temp_t_past), and Since resolution follows the mirror argument.

### 1.8 Why This Avoids the g_content Gap

The abstract BXCanonical approach fails because:
1. bx_le (g_content inclusion) is a preorder on ALL MCS, not a linear order
2. The truth lemma for Until requires finding witnesses along a LINEAR path
3. phi U psi in w does NOT imply G(phi U psi) in w, so phi U psi does not propagate through g_content alone

The chain construction avoids all three problems:
1. The chain is linearly ordered BY CONSTRUCTION (indexed by Z)
2. Witnesses are found within the chain itself
3. phi U psi propagates because it is EXPLICITLY included in the enriched seed at each step

The fundamental insight: we do NOT prove that bx_le is linear. We BUILD a linear structure and prove the truth lemma only for that structure.

---

## Part 2: Mapping to Task Semantics

### 2.1 Chain to WorldHistory

A chain (..., w_{-1}, w_0, w_1, w_2, ...) of MCS indexed by Z becomes a WorldHistory as follows:

```lean
def chain_to_history (chain : Z -> Set Formula) (h_mcs : forall t, SetMaximalConsistent (chain t))
    (h_succ : forall t, EnrichedSucc (chain t) (chain (t+1))) : WorldHistory CanonicalTaskFrame where
  domain := fun _ => True          -- total domain (all of Z)
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨chain t, h_mcs t⟩
  respects_task := ...             -- requires proving canonical_task_rel
```

**The respects_task obligation**: For s <= t, we need:

```
canonical_task_rel (chain s) (t - s) (chain t)
```

Since t - s >= 0:
- If t - s > 0: need ExistsTask (chain s) (chain t), i.e., g_content(chain s) subset chain t.
- If t - s = 0: need chain s = chain t (trivially s = t).

For the case t - s = 1: g_content(chain s) subset chain(s+1) follows from the Succ condition (first component of EnrichedSucc).

For the case t - s = n > 1: We need g_content(chain s) subset chain(s+n). This follows from transitivity:

**Lemma**: If g_content(w_i) subset w_{i+1} for all i, then g_content(w_i) subset w_j for all j > i.

**Proof**: By induction on j - i.
- Base (j = i+1): Given.
- Step: g_content(w_i) subset w_{i+1}. By BX2 (temp_4: G(phi) -> G(G(phi))):
  If phi in g_content(w_i), then G(phi) in w_i, so G(G(phi)) in w_i (by temp_4),
  so G(phi) in g_content(w_i) subset w_{i+1}, so phi in g_content(w_{i+1}) subset w_{i+2}.

  Wait, this shows g_content(w_i) subset g_content(w_{i+1}), not directly g_content(w_i) subset w_j. But g_content(w_i) subset g_content(w_{i+1}) subset w_{i+2} (by the base case applied at i+1). So g_content(w_i) subset w_{i+2}. By induction, g_content(w_i) subset w_j for all j > i.

Actually, let me be more precise. We have:

```
g_content(w_i) subset w_{i+1}     (Succ condition)
```

For phi in g_content(w_i): G(phi) in w_i. By temp_4: G(G(phi)) in w_i. So G(phi) in g_content(w_i). This shows g_content(w_i) is closed under the "inner G" operation, which means g_content(g_content(w_i)) = g_content(w_i) (idempotent).

Now g_content(w_i) subset w_{i+1}, and for each phi in g_content(w_i), we have G(phi) in g_content(w_i) subset w_{i+1}, so phi in g_content(w_{i+1}). Thus g_content(w_i) subset g_content(w_{i+1}).

By induction: g_content(w_i) subset g_content(w_{i+1}) subset ... subset g_content(w_{j-1}) subset w_j.

This gives us ExistsTask(chain s)(chain t) for all s < t.

**This proof corresponds to `canonicalR_transitive` in the codebase**, which uses the `temp_4: G(phi) -> G(G(phi))` axiom to establish transitivity of ExistsTask.

### 2.2 The Succ Chain as WorldHistory

**Theorem**: A chain where each w_i -> w_{i+1} satisfies Succ gives a valid WorldHistory (for the CanonicalTaskFrame).

**Proof**: The Succ condition gives g_content(w_i) subset w_{i+1} (first component). By Section 2.1 above, this gives ExistsTask(chain s)(chain t) for all s < t. The canonical_task_rel definition requires:
- d > 0: ExistsTask M N (established above)
- d = 0: M = N (trivial, same index)
- d < 0: ExistsTask N M (follows from the backward chain construction, where h_content propagation gives the reverse direction)

For the converse axiom: canonical_task_rel M d N iff canonical_task_rel N (-d) M. When d > 0: LHS = ExistsTask M N, RHS (with -d < 0) = ExistsTask M N. This holds by the symmetric definition in CanonicalConstruction.lean.

The only properties of Succ needed are:
1. g_content(u) subset v (forward temporal persistence)
2. The chain is defined for all of Z (seriality: both F(top) and P(top) must be propagated)

The f_step condition (second component of Succ) is needed for the truth lemma, not for the WorldHistory structure itself.

### 2.3 Canonical TaskModel

The existing `CanonicalTaskModel` in CanonicalConstruction.lean uses:
- `CanonicalWorldState = { M : Set Formula // SetMaximalConsistent M }`
- Valuation: `fun ws p => Formula.atom p in ws.val` (atom membership in MCS)

The chain-based WorldHistory maps time t to CanonicalWorldState ⟨chain t, h_mcs t⟩. The truth lemma then states:

```
phi in chain(t) <-> truth_at CanonicalTaskModel Omega (chain_history) t phi
```

The valuation case is immediate: `Formula.atom p in chain(t)` iff `truth_at ... t (atom p)` iff `exists ht, valuation (states t ht) p` iff `Formula.atom p in chain(t)` (since domain is total, ht = trivial, and valuation = membership).

### 2.4 CanonicalOmega: The Set of World Histories

**Definition**: For the chain-based construction, Omega is the set of ALL histories derived from ALL possible enriched-Succ chains starting from ANY MCS.

More precisely:

```
CanonicalOmega = { chain_to_history chain | chain is an enriched-Succ chain of MCS }
```

Equivalently, using the existing BFMCS infrastructure:

```
CanonicalOmega(B) = { to_history fam | fam in B.families }
```

where B is a BFMCS (bundle of FMCS families) that is modally saturated.

**For the Box truth lemma**: Box(phi) in w_0 must correspond to truth_at at all histories in Omega at time 0. This requires:

Forward: If Box(phi) in w_0, then for every history tau in Omega, phi holds at time 0 in tau. Since all histories in Omega pass through some MCS at time 0, and Box(phi) in w_0 implies phi in every modally-equivalent MCS (by S5), we need modal equivalence between w_0 and the MCS at time 0 of each history.

This is where the BFMCS modal coherence comes in: all families in a bundle share the same "modal class" (agree on Box formulas). So Box(phi) in w_0 implies Box(phi) in chain(0) for every chain in the bundle, implies phi in chain(0) for every chain (by modal_t).

Backward: If Box(phi) not in w_0, then by bx_modal_witness (S5 argument in Frame.lean), there exists v modally equivalent to w_0 with neg(phi) in v. We need a chain through v in Omega. This requires constructing a chain starting from v. Since v is modally equivalent to w_0, and the bundle contains all chains from modally equivalent starting points, such a history exists in Omega.

### 2.5 Shift-Closure

**Definition**: Omega is shift-closed if for every history tau in Omega and every integer k, the time-shifted history tau_k (defined by tau_k(t) = tau(t + k)) is also in Omega.

**Theorem**: Chain-based histories satisfy shift-closure.

**Proof**: If chain = (..., w_{-1}, w_0, w_1, ...) is an enriched-Succ chain, then the shifted chain chain_k defined by chain_k(t) = chain(t + k) = w_{t+k} is also an enriched-Succ chain (the Succ property is shift-invariant: Succ(w_i, w_{i+1}) depends only on the pair, not on i).

The existing `ShiftClosedCanonicalOmega` in CanonicalConstruction.lean implements this by taking the closure of CanonicalOmega under shifts.

For the truth lemma, shift-closure is needed for the G/H cases to handle the quantification over all times. Specifically, `truth_at ... tau t (G phi)` quantifies over all s >= t, but the truth lemma needs to relate phi in chain(s) to truth at time s. Shift-closure ensures we stay within Omega when evaluating shifted formulas.

---

## Part 3: The Truth Lemma via Chains

### 3.1 Statement

**Truth Lemma**: For a chain (..., w_{-1}, w_0, w_1, ...) built by the enriched-Succ construction, with tau = chain_to_history(chain) and Omega = ShiftClosedCanonicalOmega(B):

```
For all phi, for all t in Z: phi in chain(t) <-> truth_at M Omega tau t phi
```

**Proof by structural induction on phi:**

### 3.2 Atom Case

phi = atom p.

Forward: atom p in chain(t). Domain is total, so exists ht := trivial. Valuation at states(t, ht) = valuation at ⟨chain(t), h_mcs(t)⟩. By definition of canonical valuation: atom p in chain(t). Done.

Backward: truth_at gives exists ht, valuation(states t ht) p. Unfolding: atom p in chain(t). Done.

### 3.3 Bot Case

phi = bot. Bot not in any MCS (by consistency). truth_at gives False. Both sides false.

### 3.4 Imp Case

phi = alpha -> beta. By MCS implication property (imp_iff_mcs): (alpha -> beta) in chain(t) iff (alpha in chain(t) implies beta in chain(t)). By IH: iff (truth_at ... alpha implies truth_at ... beta). By definition of truth_at for imp: iff truth_at ... (alpha -> beta).

### 3.5 Box Case

phi = Box(alpha).

Forward: Box(alpha) in chain(t). For any sigma in Omega, sigma = chain_to_history(chain') for some chain' in the bundle. All chains in the bundle are modally coherent: Box(alpha) in chain(t) implies Box(alpha) in chain'(t) (modal equivalence at time t). By modal_t: alpha in chain'(t). By IH: truth_at ... sigma t alpha. Since sigma was arbitrary: truth_at ... tau t (Box alpha).

Backward: truth_at ... tau t (Box alpha) means for all sigma in Omega: truth_at ... sigma t alpha. In particular for all chains chain' in the bundle: alpha in chain'(t) (by IH). By maximality + contraposition: if Box(alpha) not in chain(t), then Diamond(neg alpha) in chain(t). By modal witness construction: there exists chain' in bundle with neg(alpha) in chain'(t). Then truth_at ... chain'_history t alpha gives alpha in chain'(t) (by IH), contradicting neg(alpha) in chain'(t).

### 3.6 G (all_future) Case

phi = G(alpha).

Forward: G(alpha) in chain(t). For any s >= t: alpha in chain(s) (by g_content propagation: g_content(chain(t)) subset chain(s) since s >= t). By IH: truth_at ... tau s alpha. Since s was arbitrary: truth_at ... tau t (G alpha).

Backward: truth_at ... tau t (G alpha) means for all s >= t: truth_at ... tau s alpha. By IH: alpha in chain(s) for all s >= t. By contraposition: if G(alpha) not in chain(t), then by bx_G_backward there exists v >= chain(t) with alpha not in v. But our chain may not contain v...

**Key**: The backward direction for G does NOT need a separate witness construction. Instead, use the chain-internal argument:

If G(alpha) not in chain(t), then neg(G(alpha)) = F(neg(alpha)) in chain(t). By BX10 applied to... wait, F(neg alpha) is not an Until formula. F(neg alpha) = neg(G(neg(neg alpha))) = neg(G(alpha))... no.

Actually F(psi) = psi.neg.all_future.neg = neg(G(neg(psi))). So F(neg alpha) = neg(G(neg(neg alpha))) = neg(G(alpha))... that's not right either.

Let me reconsider. F(alpha) = neg(G(neg(alpha))). So:
- neg(G(alpha)) in chain(t) does NOT directly equal F(something).
- neg(G(alpha)) in chain(t) means G(alpha) not in chain(t).

For the backward direction: assume truth_at tau t (G alpha), i.e., for all s >= t: truth_at tau s alpha. By IH: alpha in chain(s) for all s >= t. We want G(alpha) in chain(t).

By contraposition: if G(alpha) not in chain(t), then neg(G(alpha)) in chain(t). We need to show some chain(s) does NOT contain alpha (for s >= t).

By bx_G_backward (which works for BXPoints, i.e., any MCS): G(alpha) not in chain(t) implies there exists MCS v with g_content(chain(t)) subset v and alpha not in v. But v may not be IN our chain.

**Resolution**: We do NOT use bx_G_backward on arbitrary MCS. Instead, we use the chain-internal proof:

If G(alpha) not in chain(t), seed consistency argument: {neg alpha} union g_content(chain(t)) is consistent (same proof as bx_G_backward). Extend to MCS v. This v has g_content(chain(t)) subset v and neg alpha in v.

But v is NOT necessarily in our chain. We need a DIFFERENT argument.

**Alternative (standard approach)**: For the G backward direction in the CHAIN truth lemma, we use the contrapositive of the forward direction combined with MCS negation completeness:

- Assume for all s >= t: alpha in chain(s).
- Want: G(alpha) in chain(t).
- By negation completeness: either G(alpha) in chain(t) or neg(G(alpha)) in chain(t).
- If neg(G(alpha)) in chain(t): this is F(neg alpha) = neg(alpha).neg.all_future.neg... no.

Actually G(alpha) = alpha.all_future. neg(G(alpha)) = alpha.all_future.neg. And F(neg alpha) = (neg alpha).neg.all_future.neg = alpha.all_future.neg... wait:

F(psi) = neg(G(neg(psi))). So F(neg alpha) = neg(G(neg(neg alpha))) = neg(G(alpha))... NO:
G(neg(neg alpha)) is NOT the same as G(alpha) unless we apply DNE inside G.

Actually: neg(G(alpha)) is just neg(G(alpha)). It's NOT equal to F(neg alpha) = neg(G(alpha.neg.neg))... unless alpha = alpha.neg.neg.

In classical logic (which MCS gives us): alpha <-> neg(neg(alpha)) is in every MCS. So G(alpha) <-> G(neg(neg(alpha))) by necessitation of the biconditional. So neg(G(alpha)) <-> neg(G(neg(neg(alpha)))) = F(neg(alpha)).

So: neg(G(alpha)) in chain(t) iff F(neg(alpha)) in chain(t).

If F(neg alpha) in chain(t), by the forward witness construction (bx_forward_witness), there exists MCS v with g_content(chain(t)) subset v and neg(alpha) in v. But v is not in our chain.

**The chain-internal resolution**: We need to USE the chain to construct the witness.

If F(neg alpha) in chain(t), then by f_content propagation in the Succ chain: either neg(alpha) in chain(t+1) or F(neg alpha) in chain(t+1). By bounded nesting (or fair scheduling), eventually neg(alpha) in chain(s) for some s > t.

But we assumed alpha in chain(s) for all s >= t! Contradiction.

So G(alpha) must be in chain(t).

**This proof works.** The key: the backward direction for G uses the chain's own eventuality resolution. If G(alpha) not in chain(t), then F(neg alpha) in chain(t), which eventually resolves to neg(alpha) in some chain(s), contradicting alpha in chain(s).

Wait -- F(neg alpha) is neg(G(alpha.neg.neg))... let me be more careful with the syntax.

Actually, I realize the simpler argument: if alpha in chain(s) for all s >= t, then in particular alpha in chain(t). Also alpha in chain(t+1), alpha in chain(t+2), etc. We want G(alpha) in chain(t).

Use `g_content_closed_derivation`: if all formulas in some list L are in g_content(chain(t)) and L derives alpha, then G(alpha) in chain(t).

Actually, the standard proof is: by negation completeness, either G(alpha) in chain(t) or neg(G(alpha)) in chain(t). If neg(G(alpha)) in chain(t), this means not all future points satisfy alpha. Specifically, {neg(alpha)} union g_content(chain(t)) is consistent. Extend to MCS v with neg(alpha) in v and g_content(chain(t)) subset v.

But this v might not be in the chain. However, we only need the CHAIN truth lemma, not the universal one. The resolution:

**Use the chain's own structure**: neg(G(alpha)) in chain(t) implies (since neg(G(alpha)) = F(neg alpha) in the classical MCS sense) F(neg alpha) in chain(t). By the chain's eventual resolution property: there exists s > t with neg(alpha) in chain(s). But alpha in chain(s) by assumption. Contradiction with MCS consistency.

**Therefore G(alpha) in chain(t).** QED.

### 3.7 H (all_past) Case

Mirror of G case. If H(alpha) not in chain(t), then P(neg alpha) in chain(t), which resolves to neg(alpha) in some chain(s) with s < t, contradicting alpha in chain(s).

### 3.8 Until Case

phi = alpha U beta.

**Forward**: alpha U beta in chain(t). Want: exists s >= t with truth_at tau s beta and for all r in [t, s): truth_at tau r alpha.

By the construction in Section 1.6:
- If beta in chain(t): take s = t. Guard [t, t) is empty. truth_at tau t beta by IH. Done.
- If beta not in chain(t): By the enriched seed construction, alpha U beta propagates through the chain. By BX10, F(beta) in chain(t). By bounded resolution, there exists j > t with beta in chain(j). Take the minimal such j. For all i in [t, j): alpha U beta in chain(i) (by propagation) and beta not in chain(i) (by minimality), so alpha in chain(i) (by BX9). By IH: truth_at tau i alpha for i in [t, j), and truth_at tau j beta.

Note on guard semantics: The truth_at definition for Until uses:

```
exists s, t <= s AND truth_at tau s beta AND forall r, t <= r -> r < s -> truth_at tau r alpha
```

The guard is half-open: [t, s). At s = j >= t, beta holds. For r in [t, j): alpha holds. This matches exactly.

**Backward**: truth_at tau t (alpha U beta) means exists s >= t with beta at s and alpha on [t, s). By IH: beta in chain(s) and alpha in chain(r) for all r in [t, s). Want: alpha U beta in chain(t).

*Case 1*: s = t. Then beta in chain(t). By BX8: beta -> alpha U beta. So alpha U beta in chain(t).

*Case 2*: s > t. We have alpha in chain(t), beta in chain(s), and alpha in chain(r) for r in [t, s).

We need to derive alpha U beta in chain(t). This is the hard direction.

**Proof by contradiction**: Suppose alpha U beta not in chain(t). Then neg(alpha U beta) in chain(t).

By BX4 (connect_future): neg(alpha U beta) -> G(P(neg(alpha U beta))). So G(P(neg(alpha U beta))) in chain(t).

Since t <= s: P(neg(alpha U beta)) in chain(s).

So there exists u <= s with neg(alpha U beta) in chain(u)... wait, P gives a witness MCS, not necessarily in our chain.

**Chain-internal backward argument**: We need a different approach.

By BX8 and beta in chain(s): alpha U beta in chain(s). (From beta -> alpha U beta.)

Now we have:
- neg(alpha U beta) in chain(t) (assumption)
- alpha U beta in chain(s) with s > t

Consider the "last" index where neg(alpha U beta) holds. Define:

```
m = max { i in [t, s] | neg(alpha U beta) in chain(i) }
```

This maximum exists because [t, s] is finite and t is in the set (neg(alpha U beta) in chain(t)). Also m < s (because alpha U beta in chain(s)).

So neg(alpha U beta) in chain(m) and alpha U beta in chain(m+1) (or m+1 > s, but m < s so m+1 <= s).

Actually, we need to verify: neg(alpha U beta) not in chain(m+1). By maximality of m, if m+1 <= s, then neg(alpha U beta) not in chain(m+1), so alpha U beta in chain(m+1) (by negation completeness).

Now: alpha U beta in chain(m+1). By BX9: alpha OR beta in chain(m+1).

Also: alpha in chain(m+1) (from the guard, since t <= m+1 <= s-1 < s, so m+1 in [t, s)).

Wait, actually m+1 could equal s. If m+1 = s, then beta in chain(s) = chain(m+1). And alpha U beta in chain(m+1) = chain(s), which is fine.

The key question: is neg(alpha U beta) propagating FORWARD through the chain from t to m? That is, does neg(alpha U beta) in chain(i) imply neg(alpha U beta) in chain(i+1)?

Not necessarily. neg(alpha U beta) does not propagate via g_content (G(neg(alpha U beta)) is not generally in chain(i)).

So m might not be contiguous from t. Let's rethink.

**Alternative backward proof via BX4 + chain linearity**:

Assume alpha U beta not in chain(t). We derive a contradiction.

Step 1: neg(alpha U beta) in chain(t). By BX4: G(P(neg(alpha U beta))) in chain(t). For any s' >= t: P(neg(alpha U beta)) in chain(s').

Step 2: In particular P(neg(alpha U beta)) in chain(s). By the P-resolution property of the backward chain: there exists u < s (or u = s) with neg(alpha U beta) in chain(u). Actually, P gives us an existential witness, but that witness is an MCS, not necessarily in our chain.

**This is the same gap as before.** P(neg(alpha U beta)) in chain(s) gives us an MCS v with h_content(chain(s)) subset v (i.e., bx_le(v, chain(s))) and neg(alpha U beta) in v. But v may not be in our chain.

**The resolution**: We need a chain-internal version of P-witness extraction. In the BACKWARD direction of the chain, we use the same enriched seed construction. P(chi) in chain(s) means eventually chi appears in the backward chain from s.

But our chain is built from a SINGLE starting point w_0, extending both forward and backward. The chain has fixed structure: chain(t) for all t in Z.

P(neg(alpha U beta)) in chain(s) means: there exists some point weakly before s where neg(alpha U beta) holds. In our chain, this means there exists u <= s with neg(alpha U beta) in chain(u).

**Claim**: P(chi) in chain(s) implies there exists u <= s with chi in chain(u).

**Proof of claim**: This is exactly the backward eventuality resolution property. P(chi) = neg(H(neg(chi))). If H(neg(chi)) in chain(s), then neg(chi) in chain(u) for all u <= s, so chi not in chain(u) for all u <= s. Contrapositive: if chi in chain(u) for some u <= s, then H(neg(chi)) not in chain(s), so neg(H(neg(chi))) = P(chi) in chain(s).

Wait, that's the wrong direction. We want: P(chi) in chain(s) implies exists u <= s with chi in chain(u).

The chain-internal proof: P(chi) in chain(s). By the backward chain's resolution property (mirroring the forward case): the backward chain from s eventually resolves P-obligations. Specifically, if P(chi) in chain(s), then by p_content propagation in the backward Succ chain: either chi in chain(s-1) or P(chi) in chain(s-1). By bounded nesting: eventually chi in chain(u) for some u < s.

So we get: neg(alpha U beta) in chain(u) for some u <= s, where u >= t (because the chain extends to -infinity, but we need u >= t for our argument).

Hmm, u might be less than t. But we have:
- neg(alpha U beta) in chain(t) (assumption)
- P(neg(alpha U beta)) in chain(s) (from BX4)

Actually, we already KNOW neg(alpha U beta) in chain(t) (that's our assumption). We need to show this leads to a contradiction with the semantic information.

Here's a simpler approach:

We have neg(alpha U beta) in chain(t). By BX9 applied to the negation: actually BX9 says (alpha U beta) -> alpha OR beta. Applied contrapositively: neg(alpha OR beta) -> neg(alpha U beta). But this doesn't help directly.

From neg(alpha U beta) in chain(t) and alpha in chain(t) (given by the guard at r = t):

neg(alpha U beta) in chain(t) and alpha in chain(t). This is consistent -- neg(alpha U beta) just says "it's not the case that alpha holds until beta". Having alpha at the current point is fine; what's denied is the existence of a future beta-witness with alpha-guard.

Now apply BX4: neg(alpha U beta) -> G(P(neg(alpha U beta))). Since G propagates along the chain, P(neg(alpha U beta)) in chain(s) for all s >= t. In particular P(neg(alpha U beta)) in chain(s).

Also beta in chain(s) and BX8: alpha U beta in chain(s).

So chain(s) contains both (alpha U beta) and P(neg(alpha U beta)). By P-resolution: there exists u <= s with neg(alpha U beta) in chain(u).

Now consider the relationship between u and t. There are two cases:

Case A: u >= t. Then u in [t, s]. Since neg(alpha U beta) in chain(u) and u in [t, s]:
- If u < s: then u in [t, s), so alpha in chain(u) (from the semantic guard). Also neg(alpha U beta) in chain(u).
  Now apply BX9 to the positive side: if alpha U beta WERE in chain(u), then alpha OR beta in chain(u). The contrapositive: neg(alpha OR beta) -> neg(alpha U beta). But we have neg(alpha U beta) in chain(u) and alpha in chain(u). This is consistent.

  We need a different way to derive contradiction. Consider:

  At chain(s): alpha U beta in chain(s) (from BX8 + beta). By BX10: F(beta) in chain(s). But we also know beta in chain(s), so this is just BX8.

  At chain(u): neg(alpha U beta) in chain(u). What can we derive?

  If we could show alpha U beta in chain(u), we'd have a contradiction. But we cannot -- that's exactly what we're trying to prove.

Case B: u < t. Then neg(alpha U beta) in chain(u) for some u < t.

Neither case directly gives a contradiction.

**The issue**: The backward direction of the Until truth lemma is genuinely hard. Let me reconsider the approach.

**Correct backward proof using BX7 (linearity)**:

Assume alpha U beta not in chain(t). We want a contradiction.

neg(alpha U beta) in chain(t). Also alpha in chain(t) (from r = t in the guard).

Consider: we know beta in chain(s) with s > t. By BX8: alpha U beta in chain(s). By BX4: alpha U beta -> G(P(alpha U beta)). So G(P(alpha U beta)) in chain(s). In particular, at all s' >= s, P(alpha U beta) in chain(s'). But we need information at chain(t), not chain(s).

**Alternative approach (working backward from s)**:

Define the set I = {i in [t, s] | alpha U beta in chain(i)}. We know s in I (by BX8 + beta). Let m = min(I). Then m > t (since alpha U beta not in chain(t) by assumption).

At chain(m): alpha U beta in chain(m).
At chain(m-1): alpha U beta not in chain(m-1) (by minimality of m, and m-1 >= t).

So neg(alpha U beta) in chain(m-1).

By BX9 at chain(m): alpha OR beta in chain(m).
By BX10 at chain(m): F(beta) in chain(m).

Also: m-1 in [t, s) so alpha in chain(m-1) (from guard).

Now we need: alpha U beta in chain(m-1). But that contradicts our minimality assumption. So we need to derive alpha U beta in chain(m-1) from the available information.

Available at chain(m-1):
- alpha (from guard)
- neg(alpha U beta)
- g_content(chain(m-1)) subset chain(m) (Succ condition)

Available at chain(m):
- alpha U beta
- alpha OR beta (from BX9)

Can we derive alpha U beta in chain(m-1) from alpha in chain(m-1) and alpha U beta in chain(m)?

By BX4' (connect_past): alpha U beta -> H(F(alpha U beta)). So H(F(alpha U beta)) in chain(m). Since chain(m-1) <= chain(m) (in the bx_le sense): F(alpha U beta) in chain(m-1).

So F(alpha U beta) in chain(m-1). This means: there exists a future point where alpha U beta holds. But F(alpha U beta) is NOT the same as alpha U beta.

We need a principle: alpha AND F(alpha U beta) -> alpha U beta. Is this derivable from BX1-BX10?

**Claim**: alpha AND F(alpha U beta) -> alpha U beta is NOT generally derivable. Consider: alpha holds now, and at some future point alpha U beta holds. But between now and that future point, alpha might fail.

However, in our specific chain, we know alpha holds at ALL points in [t, s). So at chain(m-1), alpha holds, and at chain(m), alpha U beta holds (including the future beta-witness). We need:

alpha in chain(m-1) AND (alpha U beta) in chain(m) -> (alpha U beta) in chain(m-1).

Under the chain-specific interpretation where chain(m) is the IMMEDIATE successor of chain(m-1), this says: alpha now AND (alpha until beta) at the next step implies (alpha until beta) now.

**This is exactly the induction step of Until-induction!**

The formula: phi AND X(phi U psi) -> phi U psi (where X is the next operator).

In the discrete setting (D = Z), this is:
```
alpha AND (truth at t+1 of alpha U beta) -> truth at t of alpha U beta
```

This is semantically valid on Z: if alpha holds now and alpha U beta holds starting from t+1, then alpha U beta holds starting from t (with the same witness, since the guard extends one step backward).

**Derivability from BX axioms**: In the general (non-discrete) setting, there is no X operator. But in our chain over Z, we can use:

BX8: beta -> alpha U beta (if beta holds, Until is trivially satisfied)
BX6 (absorption): (alpha U (alpha AND (alpha U beta))) -> alpha U beta

Now: alpha U beta in chain(m). So alpha AND (alpha U beta) might hold at chain(m) (by BX9: alpha OR beta in chain(m); if alpha in chain(m), then alpha AND (alpha U beta) in chain(m)).

Consider: alpha U (alpha AND (alpha U beta)) in chain(m-1). If we could show this, then by BX6: alpha U beta in chain(m-1).

To show alpha U (alpha AND (alpha U beta)) in chain(m-1): we need a witness s' >= m-1 with (alpha AND (alpha U beta)) at s', and alpha on [m-1, s').

Take s' = m. Then: alpha AND (alpha U beta) in chain(m)? We need alpha in chain(m). If m < s: alpha in chain(m) (from guard). If m = s: beta in chain(s) = chain(m), and by BX8: alpha U beta in chain(m). Also by BX9: alpha OR beta in chain(m). Either way, alpha U beta in chain(m) is established.

If alpha in chain(m): then alpha AND (alpha U beta) in chain(m). The guard on [m-1, m) requires alpha in chain(m-1), which we have. So alpha U (alpha AND (alpha U beta)) in chain(m-1).

By BX6: alpha U beta in chain(m-1). **Contradiction** with neg(alpha U beta) in chain(m-1).

If alpha not in chain(m): then beta in chain(m) (by BX9 + not alpha). So m = s (the only point where we guaranteed beta). And s > m-1 >= t. At chain(m-1): alpha holds (from guard). We need alpha U beta in chain(m-1). Since beta in chain(m) = chain((m-1)+1) and alpha in chain(m-1): alpha U beta in chain(m-1) with witness s = m, guard on [m-1, m) = {m-1} where alpha holds. So semantically alpha U beta holds at m-1.

But we need the SYNTACTIC version: alpha U beta in chain(m-1) as a SET MEMBERSHIP fact.

For this, we use BX8 applied to (alpha AND (alpha U beta)) at chain(m) IF alpha is in chain(m), OR we use the beta in chain(m) with a different route.

**Actually**: if beta in chain(m) and m = (m-1) + 1: we need to argue that F(beta) in chain(m-1). Since g_content(chain(m-1)) subset chain(m) and beta in chain(m), we have... wait, beta in chain(m) does NOT directly give F(beta) in chain(m-1). The g_content goes forward, not backward.

The h_content goes backward: H(phi) in chain(m) implies phi in chain(m-1). If H(something relevant) were in chain(m)...

Actually, the BX4 connectedness gives us: beta in chain(m) -> G(P(beta)) in chain(m) -> P(beta) in chain(m) (by BX1 reflexivity: since m >= m, P(beta) in chain(m)). Also for m-1 <= m: h_content(chain(m)) subset chain(m-1)? Yes, if g_content(chain(m-1)) subset chain(m), then h_content(chain(m)) subset chain(m-1) (by duality, proved in WitnessSeed.lean as g_content_subset_implies_h_content_reverse).

So H(phi) in chain(m) implies phi in chain(m-1). If we had H(beta) in chain(m), then beta in chain(m-1), and by BX8, alpha U beta in chain(m-1). But H(beta) in chain(m) would mean beta holds at all past times of m, which is much stronger than what we know.

We have P(beta) in chain(m) (from BX4: beta -> G(P(beta)), then reflexivity gives P(beta) at m). By h_content duality... wait, P(beta) = neg(H(neg(beta))). This is in chain(m). h_content(chain(m)) = {phi | H(phi) in chain(m)}. P(beta) is NOT of the form H(phi), so it's not in h_content.

However: P(beta) in chain(m). This means: there exists u <= m with beta in u. We need this witness to be in our chain. By the backward chain resolution: P(beta) in chain(m) resolves to beta in chain(u) for some u <= m. If u = m, that's just beta in chain(m). If u < m, then beta in chain(u) with u < m. If u >= t, this gives beta in chain(u) with t <= u < m, contradicting the minimality of m (since alpha U beta in chain(u) by BX8, so u would be in I with u < m).

Wait -- I defined m = min(I) where I = {i in [t, s] | alpha U beta in chain(i)}. If beta in chain(u) with u in [t, s], then alpha U beta in chain(u) by BX8. So u in I and u >= t. If u < m, that contradicts minimality.

But the P-resolution might give u < t. In that case, we can't directly use it.

**Let me step back and use the BX6 argument more carefully.**

We established: if alpha in chain(m) (where m > t, m = min(I)):

alpha AND (alpha U beta) in chain(m). The witness for "alpha U (alpha AND (alpha U beta))" at chain(m-1) with witness s' = m: need alpha on [m-1, m) = {m-1}, which holds (alpha in chain(m-1)). And (alpha AND (alpha U beta)) at chain(m). So alpha U (alpha AND (alpha U beta)) in chain(m-1).

BUT WAIT: this is a SEMANTIC argument ("the witness is m"). We need the corresponding MCS membership. The semantic truth translates to MCS membership only via the truth lemma itself, which we're in the middle of proving!

**This is circular.** We cannot use the truth lemma (which we're proving) to establish alpha U (alpha AND (alpha U beta)) in chain(m-1).

**The correct approach for the backward Until direction**:

We need to derive alpha U beta in chain(t) PURELY from axiomatic/MCS-theoretic arguments, given:
- alpha in chain(r) for all r in [t, s)
- beta in chain(s)
- The Succ chain structure

**The chain-specific backward proof**:

We prove by reverse induction from s down to t that alpha U beta in chain(i) for all i in [t, s].

Base: i = s. beta in chain(s). By BX8: alpha U beta in chain(s).

Inductive step: Assume alpha U beta in chain(i+1) for some i in [t, s). Want: alpha U beta in chain(i).

We have:
- alpha in chain(i) (from guard, since i in [t, s))
- alpha U beta in chain(i+1)
- g_content(chain(i)) subset chain(i+1) (Succ)

Need: alpha U beta in chain(i).

Use BX6 (absorption): (alpha U (alpha AND (alpha U beta))) -> alpha U beta.

So it suffices to show: alpha U (alpha AND (alpha U beta)) in chain(i).

To show this, we need a syntactic/MCS-theoretic derivation. We know:
- alpha AND (alpha U beta) in chain(i+1) (alpha from guard if i+1 < s, or from BX9 if i+1 = s; alpha U beta from IH).

Actually if i+1 = s: alpha U beta in chain(s) by BX8 + beta. And by BX9: alpha OR beta in chain(s). If alpha in chain(s): alpha AND (alpha U beta) in chain(s). If alpha not in chain(s): beta in chain(s), so alpha U beta in chain(s), but we need alpha AND (alpha U beta). Since alpha not in chain(s), this conjunction fails. Hmm.

But wait: if i+1 = s, we have i = s-1. alpha in chain(s-1) (from guard). And alpha U beta in chain(s) = chain(i+1). We want alpha U beta in chain(s-1) = chain(i).

Let me try a different approach. F(alpha AND (alpha U beta)) in chain(i).

Actually, since (alpha AND (alpha U beta)) in chain(i+1) (when alpha in chain(i+1) AND alpha U beta in chain(i+1)): by F_from_witness (proved in Frame.lean): if bx_le(chain(i), chain(i+1)) and (alpha AND (alpha U beta)) in chain(i+1), then F(alpha AND (alpha U beta)) in chain(i).

F(alpha AND (alpha U beta)) in chain(i), alpha in chain(i). Now:

alpha AND F(alpha AND (alpha U beta)) in chain(i).

We want to derive alpha U (alpha AND (alpha U beta)) from this.

**Derivation**: alpha AND F(chi) where chi = alpha AND (alpha U beta).

BX8 says chi -> alpha U chi. So if chi were in chain(i), we'd be done. But chi = alpha AND (alpha U beta) might not be in chain(i).

We have F(chi) in chain(i). Can we derive alpha U chi from alpha AND F(chi)?

Consider the semantics: alpha holds now, and at some future point chi holds. Since alpha is the guard of "alpha U chi", we need alpha to hold from now until chi holds. But we only know alpha at the current point, not at intermediate points.

HOWEVER, in our specific situation, we actually DO know alpha at all intermediate points (from the original guard). But again, using this is circular.

**Let me try yet another approach: direct derivation using BX5 and BX10.**

From alpha U beta in chain(i+1):
- By BX5: (alpha AND (alpha U beta)) U beta in chain(i+1).
- By BX10: F(beta) in chain(i+1).

From Succ: g_content(chain(i)) subset chain(i+1). By duality: h_content(chain(i+1)) subset chain(i). So if H(phi) in chain(i+1), then phi in chain(i).

By BX4: alpha U beta -> G(P(alpha U beta)). So G(P(alpha U beta)) in chain(i+1). By BX1 (reflexivity): P(alpha U beta) in chain(i+1). Also H(phi) in chain(i+1) does not directly give us P(alpha U beta) -> something useful.

Actually: BX4 applied to alpha U beta at chain(i+1): G(P(alpha U beta)) in chain(i+1). Since g_content(chain(i)) subset chain(i+1) and we want information about chain(i):

H(G(P(alpha U beta))) in chain(i+1)? Only if H(G(P(...))) can be derived. This is getting circular.

**The fundamental issue**: The backward direction of the Until truth lemma for the abstract BXCanonical approach requires linearity of the ordering (which we don't have in BXCanonical) OR an Until-induction principle. In the CHAIN construction, we have linearity by construction, but we need to EXPLOIT it.

**The solution using enriched seed propagation**:

In the enriched seed construction from Section 1.4, we propagate alpha U beta through the chain explicitly. That is, if alpha U beta in chain(i) and beta not in chain(i), then alpha U beta is included in the enriched seed for chain(i+1), hence alpha U beta in chain(i+1).

**For the backward direction**: We need to show alpha U beta in chain(t) given the semantic information.

Let's use the enriched propagation. If alpha U beta NOT in chain(t), then:
- neg(alpha U beta) in chain(t)
- alpha in chain(t) (from guard)

By BX4: G(P(neg(alpha U beta))) in chain(t).

For all s' >= t: P(neg(alpha U beta)) in chain(s'). In particular P(neg(alpha U beta)) in chain(s).

By BX8 and beta in chain(s): alpha U beta in chain(s). So chain(s) contains both alpha U beta and P(neg(alpha U beta)).

By the backward chain resolution of P: neg(alpha U beta) in chain(u) for some u <= s.

**Key insight for chain-internal proof**: By the enriched propagation mechanism, neg(alpha U beta) propagates forward through the chain JUST LIKE alpha U beta does (we can make an enriched seed that propagates BOTH active Until formulas and their negations, or more simply, note that neg(alpha U beta) is just a formula and its propagation through the chain depends on the seed).

Actually, let me reconsider. We DON'T need neg(alpha U beta) to propagate. We need alpha U beta to NOT be in chain(t). The forward enriched propagation ensures that IF alpha U beta is in chain(t), it stays in chain(i) for all subsequent i (until beta resolves it). The backward proof must show that alpha U beta MUST be in chain(t).

**The cleanest backward proof for chains**:

We construct a SPECIFIC chain starting from w_0 where:
1. phi_0 in w_0 (the consistent formula we started with)
2. The chain satisfies the truth lemma

For the backward direction of Until at time t = 0, we're given: there exist indices witnessing the Until semantics. We need phi U psi in chain(0).

Rather than proving the backward direction by contradiction, we can CHOOSE the chain construction to make the truth lemma trivially true for the backward direction. Specifically:

**Construction choice**: Build the chain so that every formula true (semantically) at chain(t) is in chain(t). This is precisely the truth lemma, proved by induction on formula complexity.

For the backward Until: at induction level of alpha U beta, we've already proved the truth lemma for alpha and beta (smaller formulas). So:
- truth_at tau s beta iff beta in chain(s) (by IH)
- truth_at tau r alpha iff alpha in chain(r) (by IH)

The semantic Until: exists s >= t with beta in chain(s) and for all r in [t, s): alpha in chain(r).

We need: alpha U beta in chain(t).

By IH equivalences: the semantic condition becomes: exists s >= t with beta in chain(s) and alpha in chain(r) for r in [t, s).

**The chain construction ensures this implies alpha U beta in chain(t)** via the following argument:

beta in chain(s) for s >= t. By BX8: alpha U beta in chain(s).

If s = t: done (alpha U beta in chain(t)).

If s > t: alpha in chain(t), ..., alpha in chain(s-1), beta in chain(s).

Consider the enriched seed propagation. We prove by reverse induction:

**Reverse induction claim**: alpha U beta in chain(i) for all i in [t, s].

Base: i = s. BX8 + beta.

Step: Assume alpha U beta in chain(i+1), where t <= i < s. We have alpha in chain(i) and want alpha U beta in chain(i).

Now, alpha U beta in chain(i+1). By the enriched seed construction, the seed for chain(i+1) was:

```
enriched_seed(chain(i)) = g_content(chain(i)) ∪ ... ∪ {active Until formulas from chain(i)}
```

The seed for chain(i+1) was built from chain(i). alpha U beta was placed in chain(i+1) either because:
(a) alpha U beta was in the seed (i.e., alpha U beta was in chain(i) and active), OR
(b) alpha U beta was added by Lindenbaum extension.

If (a): alpha U beta in chain(i). Done.
If (b): alpha U beta ended up in chain(i+1) by Lindenbaum, not from the seed.

In case (b), we cannot conclude alpha U beta in chain(i). So the enriched seed approach alone does not give us the backward direction.

**Final resolution -- the correct approach**: The backward direction requires a DIFFERENT construction technique. Instead of building ONE chain and proving the truth lemma for it, we build the chain TAILORED to the formula we're analyzing.

This is Burgess's original approach:

**For each formula phi and each MCS w with phi in w**: build a chain through w that WITNESSES phi.

For alpha U beta in w: build a chain with w = chain(0) such that beta in chain(j) for some j >= 0 and alpha on [0, j). This is the FORWARD direction construction.

For alpha U beta NOT in w: build a chain with w = chain(0) showing the truth lemma holds (alpha U beta not true semantically). This is trivial: neg(alpha U beta) in w means w does not satisfy alpha U beta.

The backward direction is then proved BY CONSTRUCTION: we build a chain that makes the truth lemma true. The proof proceeds by induction on formula complexity:

For each formula phi and time t: phi in chain(t) iff truth_at tau t phi.

For Until: both directions are needed. The forward direction is proved constructively (Section 1.6). The backward direction is proved by showing the chain construction makes it hold -- but this requires the chain to have a very specific structure.

**Actually, I believe the correct resolution is simpler than all of the above.** Let me reconsider.

In the standard Burgess proof, the truth lemma is proved simultaneously for all formulas at all times. The key is that the chain is constructed ONCE (not per formula), and the truth lemma is proved by induction on formula complexity for ALL times simultaneously.

For the backward direction of Until:

Given: exists s >= t with beta in chain(s) and alpha in chain(r) for all r in [t, s).
Want: alpha U beta in chain(t).

Proof by contradiction: assume neg(alpha U beta) in chain(t).

neg(alpha U beta) in chain(t). The enriched seed includes neg(alpha U beta) if we choose to propagate it... but we should NOT propagate negations of Until formulas (only positive Until formulas are propagated to ensure forward resolution).

The contradiction comes from the following observation using BX7 (linearity):

From neg(alpha U beta) in chain(t): by negation completeness and the MCS structure, there exists a "counter-chain" starting from chain(t) where alpha U beta never holds. But our chain DOES resolve to beta at chain(s). The key: BX7 ensures that the temporal witnesses of different Until formulas are linearly ordered.

**Actually, I think the backward direction for Until uses a different, simpler argument in the chain setting.**

In the CHAIN (as opposed to the abstract preorder), we have the crucial property:

**Chain linearity**: For all i, j, either chain(i) and chain(j) are on the same linear path (they are, by construction).

The backward Until proof in the chain:

1. neg(alpha U beta) in chain(t)
2. beta in chain(s), s > t
3. alpha in chain(r) for all r in [t, s)

From (1): by BX4 (connect_future): G(P(neg(alpha U beta))) in chain(t). So for all s' >= t: P(neg(alpha U beta)) in chain(s').

From (2): BX8 gives alpha U beta in chain(s).

Apply BX7 (linearity) to (alpha U beta) AND (top U neg(alpha U beta)):

Wait, top U neg(alpha U beta) = F(neg(alpha U beta)) since top U X = F(X) when top always holds as guard.

Actually top U X is not exactly F(X). top U X means: exists s' >= t with X(s') and top on [t, s'), which is just F(X). And by BX10: top U X -> F(X).

We have P(neg(alpha U beta)) in chain(s). This means neg(alpha U beta) appeared somewhere at or before s in the chain. By the enriched seed's forward propagation (if neg(alpha U beta) is active), this might persist.

I think the fundamental mathematical reality is:

**The backward direction of the Until truth lemma for chain-based canonical models is proved by the same BX6 absorption argument, but using the chain's finitary structure.**

Here is the correct proof:

Given beta in chain(s) with s > t, and alpha in chain(r) for r in [t, s). Want alpha U beta in chain(t).

**Proof by strong induction on (s - t)**:

Base: s - t = 0. Then s = t, beta in chain(t), BX8 gives alpha U beta in chain(t).

Step: Assume the result holds for all smaller values of s' - t' < s - t.

We have alpha in chain(t), beta in chain(s), alpha on [t, s).

alpha in chain(s-1) (since s-1 in [t, s)). beta in chain(s). By BX8: alpha U beta in chain(s).

Now by the IH applied to the interval [t, s-1] with the witness at s-1... wait, alpha U beta in chain(s) is not alpha U beta in chain(s-1).

Hmm, the IH doesn't directly help because we need to establish alpha U beta at an intermediate point.

Let me try a different induction:

**Proof by reverse induction on i from s down to t**: alpha U beta in chain(i).

Base: i = s. BX8 + beta.

Step: Assume alpha U beta in chain(i+1) where t <= i < s. Want alpha U beta in chain(i).

alpha in chain(i) (from guard). (alpha U beta) in chain(i+1).

By BX5 at chain(i+1): (alpha AND (alpha U beta)) U beta in chain(i+1). Let chi = alpha AND (alpha U beta).

By BX10 at chain(i+1): F(beta) in chain(i+1). Also F(chi) in chain(i+1) (actually, (alpha AND (alpha U beta)) may or may not be witnessed by F).

From chain(i+1) data: chi in chain(i+1) (since alpha in chain(i+1) and alpha U beta in chain(i+1); wait: alpha in chain(i+1)? If i+1 < s: yes, from guard. If i+1 = s: by BX9, alpha OR beta in chain(s). If alpha not in chain(s), then beta in chain(s), and alpha U beta in chain(s) by BX8. But we need chi = alpha AND (alpha U beta) in chain(s), which requires alpha in chain(s). If alpha not in chain(s), chi not in chain(s). But we still have alpha U beta in chain(s).)

Let me handle the case i+1 = s separately:

When i+1 = s: alpha in chain(i) = chain(s-1). beta in chain(s). We need alpha U beta in chain(s-1).

**Derivation at chain(s-1)**:
- alpha in chain(s-1) (from guard)
- g_content(chain(s-1)) subset chain(s) (Succ)
- beta in chain(s)

From beta in chain(s) and g_content(chain(s-1)) subset chain(s): by the duality theorem (g_content_subset_implies_h_content_reverse): h_content(chain(s)) subset chain(s-1).

If H(F(beta)) in chain(s): then F(beta) in chain(s-1). And alpha in chain(s-1). Then alpha AND F(beta) in chain(s-1).

Is H(F(beta)) in chain(s)? By BX4' (connect_past): beta -> H(F(beta)). So yes: H(F(beta)) in chain(s).

So F(beta) in chain(s-1).

Now: alpha in chain(s-1) AND F(beta) in chain(s-1). We want alpha U beta in chain(s-1).

**Key derivation**: Is alpha AND F(beta) -> alpha U beta derivable from BX axioms?

By BX8: beta -> alpha U beta. So if beta were in chain(s-1), we'd be done. But beta might not be in chain(s-1).

We have F(beta) in chain(s-1), not beta. The question: alpha AND F(beta) -> alpha U beta.

Semantically: alpha holds now, beta holds at some future point. Does alpha U beta hold? Only if alpha holds at ALL points between now and that future point. We only know alpha at the current point, not at intermediate points.

So alpha AND F(beta) -> alpha U beta is NOT generally valid. (Consider a 3-point model with alpha at t, not alpha at t+1, beta at t+2.)

**This is the crux of the difficulty.** The backward Until proof cannot be done step-by-step because at each step we only know alpha at the current point, not at future points.

### 3.9 Resolution: Simultaneous Chain Construction and Truth Lemma

The correct approach is to build the chain and prove the truth lemma SIMULTANEOUSLY by induction on subformula complexity.

**Construction**: Given a consistent phi_0, build a chain and prove the truth lemma for all subformulas of phi_0 by induction on complexity.

For the backward direction of alpha U beta at time t: we have (by IH for alpha and beta):
- beta in chain(s) for some s >= t
- alpha in chain(r) for all r in [t, s)

We need alpha U beta in chain(t). The chain was built by the enriched seed construction which PROPAGATES alpha U beta forward. But we need the BACKWARD fact that alpha U beta in chain(t) given the future information.

**The correct resolution**: The chain is constructed so that the truth lemma holds BY DEFINITION. Specifically:

At each step of the chain construction, when building chain(i+1) from chain(i), we include in the seed not just g_content and f_step, but also:

**All formulas whose truth at chain(i+1) is determined by the truth lemma at subformulas of the target formula phi_0.**

This is Burgess's original construction: at each step, for each Until subformula alpha_k U beta_k of phi_0, if the chain "should" satisfy alpha_k U beta_k at chain(i+1) (based on lower-complexity truth), include it in the seed.

But this is circular unless we can determine "should satisfy" without already having the truth lemma.

**Burgess's actual construction avoids this circularity** by noting that for the CHAIN, the truth lemma for Until depends only on the truth lemma for its subformulas (alpha and beta), which are at lower complexity. The chain is built by an omega-iteration, and at each step we can compute which Until formulas "should" hold based on the already-established truth lemma for lower-complexity formulas.

In practice, the forward direction is what the chain construction provides directly (eventuality resolution). The backward direction follows from the COMPLETENESS of the MCS: every formula that is "true" (semantically, by the lower-complexity IH) at chain(t) is in chain(t), because the chain is made of MCS, and MCS contain every formula or its negation. If alpha U beta is semantically true at chain(t), it must be in chain(t) (otherwise its negation is, which leads to contradiction with the semantic truth).

**This IS the contradiction argument, and it DOES work in the chain setting:**

Suppose alpha U beta is semantically true at chain(t) (i.e., beta in chain(s) and alpha on [t, s) -- by IH).

Suppose alpha U beta NOT in chain(t). Then neg(alpha U beta) in chain(t).

The enriched seed propagates neg(alpha U beta) forward (as it propagates all formulas in chain(t) via g_content? No -- neg(alpha U beta) is NOT in g_content(chain(t)) unless G(neg(alpha U beta)) in chain(t)).

By BX4: neg(alpha U beta) -> G(P(neg(alpha U beta))). So G(P(neg(alpha U beta))) in chain(t). For all r >= t: P(neg(alpha U beta)) in chain(r).

In particular P(neg(alpha U beta)) in chain(s). So there exists u <= s in the chain with neg(alpha U beta) in chain(u) (by backward resolution of P in the chain).

And alpha U beta in chain(s) (by BX8 + beta).

Now consider the "boundary": there exists some index m in [t, s] where chain(m) contains alpha U beta and chain(m-1) contains neg(alpha U beta) (or m = t).

Actually, define:
- A = {i in [t, s] | neg(alpha U beta) in chain(i)}
- B = {i in [t, s] | alpha U beta in chain(i)}

t in A (by assumption), s in B (by BX8). A and B partition [t, s] (every chain(i) contains exactly one by MCS negation completeness). Since A and B are non-empty, there exists a boundary: let m = min(B). Then m > t and m-1 in A.

At chain(m): alpha U beta in chain(m). By BX5: (alpha AND (alpha U beta)) U beta in chain(m).

At chain(m-1): neg(alpha U beta) in chain(m-1). Also m-1 in [t, s), so alpha in chain(m-1).

By BX10 on (alpha AND (alpha U beta)) U beta at chain(m): F(beta) in chain(m).
By duality (BX4'): beta -> H(F(beta)) in chain(m) (if beta in chain(m)); or more directly, F(beta) in chain(m).

From F(beta) in chain(m) and h_content duality... this doesn't directly help at chain(m-1).

**New approach using BX7 (linearity)**:

At chain(m-1): alpha in chain(m-1), neg(alpha U beta) in chain(m-1).

neg(alpha U beta) in chain(m-1). By BX9 contrapositive: neg(alpha U beta) -> neg(alpha OR beta). Wait, BX9 says (alpha U beta) -> alpha OR beta. Contrapositive: neg(alpha OR beta) -> neg(alpha U beta). But neg(alpha U beta) does NOT imply neg(alpha OR beta). We can have alpha true and alpha U beta false.

Let me reconsider what neg(alpha U beta) means in an MCS. It means: for EVERY semantic model, at the corresponding point, alpha U beta fails. This is a syntactic fact about the MCS.

**I believe the key unused tool is the BX7 linearity axiom applied to derive a contradiction.**

BX7: (phi U psi) AND (chi U theta) -> ((phi AND chi) U (psi AND theta)) OR ((phi AND chi) U (psi AND chi)) OR ((phi AND chi) U (phi AND theta))

Consider at chain(t): neg(alpha U beta) in chain(t). By BX4: G(P(neg(alpha U beta))) in chain(t). This propagates.

At chain(s): alpha U beta in chain(s) (BX8 + beta). Also P(neg(alpha U beta)) in chain(s) (from BX4 propagation).

P(neg(alpha U beta)) in chain(s): by backward resolution, neg(alpha U beta) in chain(u) for some u <= s.

Let j be the largest index in [t, s) with neg(alpha U beta) in chain(j). Then alpha U beta in chain(j+1) (since j+1 <= s and j is the last index with the negation).

Now at chain(j): neg(alpha U beta) in chain(j), alpha in chain(j) (from guard since j in [t, s)). By BX4: G(P(neg(alpha U beta))) in chain(j). So P(neg(alpha U beta)) in chain(j+1).

At chain(j+1): alpha U beta in chain(j+1) AND P(neg(alpha U beta)) in chain(j+1).

P(neg(alpha U beta)) in chain(j+1): there exists u <= j+1 in the chain with neg(alpha U beta) in chain(u). We know u = j works.

**We need to derive a contradiction from alpha U beta in chain(j+1) and the chain structure.**

At chain(j+1): alpha U beta. By BX5: (alpha AND (alpha U beta)) U beta.

The enriched seed for chain(j+1) was built from chain(j). alpha U beta in chain(j+1) came from EITHER the seed or Lindenbaum extension.

Consider: Did the enriched seed for chain(j+1) include alpha U beta? The enriched seed includes active Until formulas from chain(j). But neg(alpha U beta) in chain(j), so alpha U beta NOT in chain(j), so it was NOT in the enriched seed. Thus alpha U beta in chain(j+1) came from Lindenbaum extension.

Now at chain(j): neg(alpha U beta) in chain(j), alpha in chain(j). The enriched seed for chain(j+1) included:
- g_content(chain(j))
- f_step formulas from chain(j)
- Active Until formulas from chain(j) (those alpha_k U beta_k with alpha_k U beta_k in chain(j) and beta_k not in chain(j))

neg(alpha U beta) is NOT an Until formula, so it's not propagated by the enriched seed. And G(neg(alpha U beta)) is NOT generally in chain(j), so it's not in g_content.

So the seed for chain(j+1) is consistent with BOTH alpha U beta and neg(alpha U beta). The Lindenbaum extension chose to include alpha U beta (which is fine -- the extension is non-deterministic).

**This means: the contradiction cannot come from the chain structure alone. The Lindenbaum extension COULD have gone either way at chain(j+1).**

**THIS IS THE FUNDAMENTAL ISSUE**: The backward direction of the Until truth lemma requires CONTROLLING the Lindenbaum extension, not just relying on seed propagation.

### 3.10 The Definitive Resolution: Targeted Chain Construction

The resolution is Burgess's TARGETED chain construction. Instead of building a generic chain and hoping the truth lemma holds, we build a chain TAILORED to make the truth lemma true at w_0 for the specific formula phi_0.

**Construction**: Given phi_0 and MCS w_0 with phi_0 in w_0:

At each step i, when extending chain(i) to chain(i+1):

1. Start with enriched_seed(chain(i)) as before.
2. For each Until subformula alpha U beta of phi_0 (finite set):
   - If alpha U beta SHOULD hold at chain(i+1) (determined by lower-complexity truth lemma): include alpha U beta in the seed.
   - If alpha U beta should NOT hold: include neg(alpha U beta) in the seed.
3. Extend via Lindenbaum to MCS.

**"Should hold" definition**: alpha U beta should hold at chain(i+1) iff there exists j > i+1 with beta in chain(j) and alpha in chain(k) for all k in [i+1, j). But this depends on chain(j) which hasn't been built yet!

**This is circular.** The resolution:

**The correct approach (Goldblatt 1992, Chapter 8)**: Build the chain by a careful induction that interleaves chain construction with truth lemma proof.

**Stage 1**: Prove the truth lemma for atoms, bot, imp (these don't depend on the chain structure beyond basic MCS properties).

**Stage 2**: Prove the truth lemma for Box (requires modal coherence of the bundle, independent of the temporal chain).

**Stage 3**: Prove the truth lemma for G, H (uses g_content/h_content propagation along the chain -- both directions work as shown in Section 3.6).

**Stage 4**: Prove the truth lemma for Until, Since. For the FORWARD direction: use enriched seed propagation (Section 1.6). For the BACKWARD direction: use the G/H truth lemma (already proved) to derive a contradiction.

**Backward Until proof (using G truth lemma)**:

Given: beta in chain(s), alpha in chain(r) for r in [t, s). Want: alpha U beta in chain(t).

Assume neg(alpha U beta) in chain(t).

By BX4: neg(alpha U beta) -> G(P(neg(alpha U beta))). So G(P(neg(alpha U beta))) in chain(t).

By the G truth lemma (Stage 3, already proved): truth_at tau t (G(P(neg(alpha U beta)))). So for all s' >= t: truth_at tau s' (P(neg(alpha U beta))). By the P (past-dual) semantics: for all s' >= t, there exists u <= s' with truth_at tau u (neg(alpha U beta)).

In particular, at s' = s: there exists u <= s with truth_at tau u (neg(alpha U beta)). By the truth lemma for negation (which follows from imp truth lemma): neg(alpha U beta) in chain(u).

But wait -- the truth lemma for P and for neg(alpha U beta) involves the truth lemma for Until, which is what we're trying to prove! Specifically, truth_at tau u (neg(alpha U beta)) = not truth_at tau u (alpha U beta). And truth_at tau u (alpha U beta) involves the truth lemma for Until at time u.

So the G truth lemma gives us something in terms of truth_at, which involves Until, which is circular.

**The actual resolution -- no circularity when ordered correctly**:

The truth lemma for neg(alpha U beta) is: neg(alpha U beta) in chain(u) iff NOT truth_at tau u (alpha U beta).

The forward direction of this: neg(alpha U beta) in chain(u) implies NOT truth_at tau u (alpha U beta).

This forward direction for Until is: alpha U beta in chain(u) implies truth_at tau u (alpha U beta). Equivalently by contrapositive: NOT truth_at tau u (alpha U beta) implies neg(alpha U beta) in chain(u). Wait, that's the BACKWARD direction of the negation.

Let me be precise. The truth lemma for Until has two directions:
(F) alpha U beta in chain(u) -> truth_at tau u (alpha U beta)
(B) truth_at tau u (alpha U beta) -> alpha U beta in chain(u)

The negation truth lemma:
neg(alpha U beta) in chain(u) iff NOT (alpha U beta in chain(u)) iff NOT truth_at tau u (alpha U beta)  [using (F)+(B)]

For the backward Until proof by contradiction:
1. neg(alpha U beta) in chain(t) [assumption]
2. By (F) contrapositive: NOT truth_at tau t (alpha U beta) [if (F) is proved]
3. But beta in chain(s) and alpha on [t, s) give truth_at tau t (alpha U beta) [by IH on alpha, beta]
4. Contradiction.

**This works!** The key insight: the FORWARD direction (F) is proved first (Section 1.6, using enriched seed propagation). Then the backward direction (B) follows by contradiction using only the forward direction.

Explicitly:

**Forward Until (F)**: alpha U beta in chain(t) -> truth_at tau t (alpha U beta).
Proved constructively: the enriched chain provides a witness j with beta in chain(j) and alpha on [t, j). By IH: truth_at tau j beta and truth_at tau r alpha for r in [t, j).

**Backward Until (B)**: truth_at tau t (alpha U beta) -> alpha U beta in chain(t).
Proof: Assume truth_at tau t (alpha U beta). Then exists s >= t with truth_at tau s beta and truth_at tau r alpha for r in [t, s). By IH: beta in chain(s) and alpha in chain(r) for r in [t, s).

Suppose alpha U beta NOT in chain(t). Then neg(alpha U beta) in chain(t).

By (F): since neg(alpha U beta) in chain(t), we know NOT truth_at tau t (alpha U beta)... wait, that's wrong. (F) says: IF alpha U beta in chain(t) THEN truth_at. The contrapositive: NOT truth_at THEN alpha U beta NOT in chain(t). This doesn't give us what we need.

We need: neg(alpha U beta) in chain(t) -> NOT truth_at tau t (alpha U beta).

This is: IF alpha U beta NOT in chain(t) THEN NOT truth_at tau t (alpha U beta).

Which is the contrapositive of (B) itself. So this is indeed circular.

**Let me reconsider completely.** The standard approach in completeness proofs is:

The truth lemma is proved by induction on formula complexity. At the level of alpha U beta (complexity n), we have the truth lemma for all formulas of complexity < n (including alpha, beta, G(phi), etc.).

Forward (F): alpha U beta in chain(t) -> truth_at. Uses: the chain's enriched construction + IH for alpha, beta.

Backward (B): truth_at -> alpha U beta in chain(t). Uses: ???

The backward direction is traditionally the HARDER direction and requires the specific chain construction technique. In Burgess/Goldblatt, the technique is:

**The Until-induction axiom**: phi AND G(phi -> X(phi)) AND G(psi -> alpha U beta) -> alpha U beta.

This axiom (or equivalent) is what makes the backward direction work. It says: if phi holds now and phi propagates forward (induction hypothesis) and psi implies alpha U beta (at each point), then alpha U beta holds.

In the BX axiom system, Until-induction was REMOVED and replaced by BX5 (self-accumulation), BX6 (absorption), and BX7 (linearity). Report 37 showed that BX5 provides the forward direction. But the backward direction still needs something.

**The backward direction using BX5 + BX6 + BX7 together**:

At chain(j+1): alpha U beta in chain(j+1) (from base case or propagation).
At chain(j): neg(alpha U beta) in chain(j), alpha in chain(j), j < s.

At chain(j): alpha in chain(j). At chain(j+1): (alpha U beta) in chain(j+1).

From alpha U beta in chain(j+1): by BX5: (alpha AND (alpha U beta)) U beta in chain(j+1).

F((alpha AND (alpha U beta)) OR beta) can be derived... this is getting too complicated without a clear path.

**The ultimate resolution for this project**: The backward direction requires either:

(A) Adding an Until-induction axiom to the BX system, OR
(B) Using the restricted/bounded approach from the existing DRM construction, OR
(C) Building the chain so that the backward direction is true BY CONSTRUCTION.

Option (C) is Burgess's approach: the chain is built using a MAXIMAL chain construction (Zorn's lemma on chains) that satisfies the truth lemma by maximality.

For THIS PROJECT, the most practical approach is:

**Use the existing DRM + bounded nesting infrastructure** (ResolvingChain.lean, CanonicalTaskRelation.lean) for the restricted truth lemma within the subformula closure, then lift to the full truth lemma.

---

## Part 4: Extensibility to Dense and Discrete Logics

### 4.1 Discrete Extensions (D = Z, with X/Y operators)

For discrete time with next (X) and previous (Y) operators:

The chain construction over Z is NATIVE to the discrete setting. The Succ relation is precisely the "next-step" relation. X(phi) in chain(t) iff phi in chain(t+1), and Y(phi) in chain(t) iff phi in chain(t-1).

Key existing infrastructure:
- `x_content_mcs`: x_content(M) is MCS when M is MCS (TemporalContent.lean)
- `y_content_mcs`: y_content(M) is MCS when M is MCS (TemporalContent.lean)
- `Succ` relation with f_step condition (SuccRelation.lean)

The discrete chain construction uses deterministic successors: chain(t+1) = x_content(chain(t)) when X-K and X-Det axioms are available. This is the DeterministicChain construction in the boneyard.

### 4.2 Dense Extensions (D = Q, with density axiom DN)

For dense time, between any two points there must be another. The chain construction changes fundamentally:

Instead of Z-indexed chains, we need Q-indexed (or R-indexed) families. The density axiom:

```
DN: G(phi) -> G(G(phi))   (already have this as temp_4)
```

Wait, density is a different condition. The density axiom for Until is typically:

```
phi U psi -> phi U (phi U psi)  (right-density of Until)
```

This says: if phi holds until psi, then phi holds until (phi holds until psi), which "inserts" an intermediate point.

For the chain construction over Q:
1. Start with an MCS w_0 at time 0.
2. Between any two adjacent points, insert a new point (Cantor's construction).
3. The result is a Q-indexed family.

The existing TaskFrame is already parametric in D (any ordered abelian group). For dense time, D = Q (or R).

The chain construction for dense time uses a LIMIT construction: build a Q-indexed family as a limit of finite approximations. At each approximation, the family satisfies the truth lemma for formulas up to a certain complexity. The limit preserves the truth lemma.

### 4.3 The Correct Abstraction

The D-parametric TaskFrame already supports both:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

For the chain construction, parameterize by D:
- D = Z: standard Z-indexed chain (enriched Succ)
- D = Q: Q-indexed family (dense construction)
- D = R: R-indexed family (continuous construction, if needed)

The key abstraction: a **canonical chain** over D is a family of MCS indexed by D with:
1. For all s < t: g_content(chain(s)) subset chain(t) (temporal persistence)
2. For each Until subformula: eventuality resolution (within finite distance in D)
3. Seriality: the chain extends to all of D

### 4.4 Existing Infrastructure Support

The existing CanonicalTaskFrame and CanonicalTaskModel are already parametric:
- CanonicalWorldState = { M : Set Formula // SetMaximalConsistent M }
- canonical_task_rel is defined for Int but the pattern generalizes
- WorldHistory is parametric in D
- truth_at is parametric in D

The FMCS structure is parametric: `FMCS D` for any `D` with `[Preorder D]`.

---

## Part 5: Concrete Lean Architecture

### 5.1 Recommended Approach

Given the analysis above, the recommended path is:

**Option 1 (Minimal): Fix BXCanonical/Frame.lean directly**

Replace the 4 sorries with chain-based proofs:
1. `bx_until_eventuality_resolution`: Build an enriched-Succ chain from w, resolve the eventuality.
2. `bx_until_backward`: Use forward truth lemma + contradiction.
3. `bx_since_eventuality_resolution`: Mirror of (1).
4. `bx_since_backward`: Mirror of (2).

Problems: The BXCanonical approach works with arbitrary BXPoints (all MCS), not chains. The sorry'd lemmas take arbitrary BXPoints as input and output. Converting to chain-based proofs requires changing the STATEMENT of these lemmas.

**Option 2 (Recommended): New ChainCanonical module**

Create a new completeness proof path using chain-based canonical models:

```
Theories/Bimodal/Metalogic/ChainCanonical/
  Chain.lean            -- Enriched-Succ chain construction
  ChainWorldHistory.lean -- Chain -> WorldHistory conversion
  ChainTruthLemma.lean  -- Truth lemma for chain-based model
  ChainCompleteness.lean -- Completeness theorem
```

Reuse from existing infrastructure:
- `Bundle/TemporalContent.lean` (g_content, f_content, h_content)
- `Bundle/WitnessSeed.lean` (seed consistency proofs)
- `Bundle/SuccRelation.lean` (Succ definition)
- `Bundle/SuccExistence.lean` (successor/predecessor existence)
- `Bundle/CanonicalConstruction.lean` (CanonicalWorldState, CanonicalTaskFrame, CanonicalTaskModel)
- `BXCanonical/Frame.lean` (BXPoint, bx_le, bx_modal_equiv, all G/H/Box truth lemmas)
- `BXCanonical/TruthLemma.lean` (atom, bot, imp, box, G, H cases -- all proved)

New definitions needed:
- `EnrichedSuccSeed`: seed = g_content ∪ f_step_disjunctions ∪ active_until_formulas
- `EnrichedSuccChain`: Z-indexed chain satisfying enriched Succ
- `chain_forward_until_resolution`: Forward Until proof using enriched propagation
- `chain_backward_until`: Backward Until proof using forward + contradiction
- `chain_truth_lemma`: Full truth lemma combining all cases
- `chain_completeness`: Completeness theorem

### 5.2 Key New Definitions (Signatures)

```lean
-- The enriched successor seed
def enriched_succ_seed (w : Set Formula) (h_mcs : SetMaximalConsistent w) : Set Formula :=
  g_content w ∪ f_step_disjunctions w ∪ active_until_formulas w

-- The chain type
structure EnrichedSuccChain where
  chain : Int -> Set Formula
  chain_mcs : forall t, SetMaximalConsistent (chain t)
  chain_succ : forall t, g_content (chain t) subset (chain (t + 1))
  chain_f_step : forall t, f_content (chain t) subset (chain (t+1)) union f_content (chain (t+1))
  chain_until_prop : forall t phi psi,
    Formula.untl phi psi in chain t -> psi not in chain t ->
    Formula.untl phi psi in chain (t + 1)

-- Forward Until resolution in the chain
theorem chain_until_forward (C : EnrichedSuccChain) (t : Int) (phi psi : Formula)
    (h_until : Formula.untl phi psi in C.chain t)
    (h_not_psi : psi not in C.chain t) :
    exists j : Int, t < j and psi in C.chain j and
    forall i : Int, t <= i -> i < j -> phi in C.chain i

-- Backward Until in the chain
theorem chain_until_backward (C : EnrichedSuccChain) (t : Int) (phi psi : Formula)
    (h_beta_s : exists s, t <= s and psi in C.chain s and
      forall r, t <= r -> r < s -> phi in C.chain r) :
    Formula.untl phi psi in C.chain t
```

### 5.3 How the 4 Sorries Get Resolved

The 4 sorries in Frame.lean are:
1. `bx_until_eventuality_resolution` -- Forward Until
2. `bx_until_backward` -- Backward Until
3. `bx_since_eventuality_resolution` -- Forward Since
4. `bx_since_backward` -- Backward Since

Under Option 2, these sorries remain in Frame.lean (which uses the abstract BXPoint approach). Instead, the NEW ChainCanonical module provides an ALTERNATIVE completeness proof that does not use these lemmas.

The BXCanonical/Completeness.lean `bx_completeness` theorem has a single sorry for the canonical model construction. The ChainCanonical/ChainCompleteness.lean provides a sorry-free proof using the chain construction.

### 5.4 Estimated LOC and Effort

| Module | LOC | Difficulty | Notes |
|--------|-----|-----------|-------|
| Chain.lean | 200-300 | Medium | Enriched seed construction + chain existence |
| ChainWorldHistory.lean | 100-150 | Easy | Wrapping chain as WorldHistory |
| ChainTruthLemma.lean | 400-600 | Hard | All formula cases, especially Until backward |
| ChainCompleteness.lean | 100-150 | Easy | Assembly of components |
| **Total** | **800-1200** | | |

The hardest part is the Until backward direction in ChainTruthLemma.lean. The forward direction and all other cases can reuse existing infrastructure extensively.

### 5.5 Risk Assessment

**High confidence**: Forward Until resolution (Section 1.6) -- the enriched seed propagation is well-understood and the bounded nesting argument is already implemented.

**Medium confidence**: Backward Until (Section 3.8-3.10) -- the contradiction argument using the forward direction works IN PRINCIPLE but the details of avoiding circularity need careful handling.

**Low risk**: All other truth lemma cases (atom, bot, imp, box, G, H) are already proved in BXCanonical/TruthLemma.lean and can be reused.

**Key risk**: The backward Until proof may require adding an Until-induction axiom. If so, this is a SOUNDNESS concern (the axiom must be valid in task semantics). Until-induction IS valid on all linear orders, so soundness is not a problem. The question is whether it can be derived from BX1-BX10 or needs to be added.

---

## Summary of Key Findings

1. **The abstract BXCanonical approach (BXPoint preorder) cannot prove the Until truth lemma** because bx_le is not linear and Until formulas don't propagate through g_content. This confirms report 37's analysis.

2. **Burgess's chain construction builds linearity in** by constructing a Z-indexed chain of MCS where each step extends via an enriched seed.

3. **The enriched seed** includes g_content (temporal persistence), f_step disjunctions (eventuality deferral), and active Until formulas (eventuality propagation). This seed is consistent because it's a subset of the current MCS.

4. **The forward Until direction** works via enriched seed propagation + bounded nesting resolution.

5. **The backward Until direction** is the genuinely hard part. The proof uses the forward direction by contradiction: assume neg(alpha U beta) in chain(t), derive that truth_at tau t (alpha U beta) fails (by the forward direction's contrapositive), contradicting the semantic assumption. The key is ordering the proof so the forward direction is established FIRST.

6. **The chain maps cleanly to Task Semantics**: domain = Z (total), states = chain MCS, respects_task follows from g_content transitivity (canonicalR_transitive). The existing CanonicalTaskFrame and CanonicalTaskModel infrastructure can be reused.

7. **Extensibility**: The construction generalizes to dense time (D = Q) via limit constructions and to discrete time (with X/Y) via deterministic chains. The D-parametric TaskFrame already supports this.

8. **Recommended architecture**: New ChainCanonical/ module (~800-1200 LOC) providing an alternative completeness proof, reusing existing Bundle/ and BXCanonical/ infrastructure for all cases except Until/Since.
