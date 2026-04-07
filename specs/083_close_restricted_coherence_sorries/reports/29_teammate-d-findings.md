# First-Principles Problem Setup: The `forward_F` Blocker

**Task**: 83 - close_restricted_coherence_sorries
**Author**: Teammate D (First-Principles Analysis)
**Date**: 2026-04-07

---

## 1. The Logic TM: Complete Specification

### 1.1 Formula Type

The logic TM (Tense and Modality) has eight primitive constructors (from `Syntax/Formula.lean`):

```lean
inductive Formula : Type where
  | atom : Atom -> Formula           -- propositional variable
  | bot : Formula                    -- falsity (bottom)
  | imp : Formula -> Formula -> Formula  -- implication
  | box : Formula -> Formula         -- modal necessity (S5)
  | all_past : Formula -> Formula    -- H: "always in the past"
  | all_future : Formula -> Formula  -- G: "always in the future"
  | untl : Formula -> Formula -> Formula  -- Until (phi U psi)
  | snce : Formula -> Formula -> Formula  -- Since (phi S psi)
```

**Derived operators** (definitional abbreviations):

| Symbol | Name | Definition |
|--------|------|-----------|
| neg(phi) | negation | phi -> bot |
| and(phi,psi) | conjunction | neg(phi -> neg(psi)) |
| or(phi,psi) | disjunction | neg(phi) -> psi |
| diamond(phi) | possibility | neg(box(neg(phi))) |
| some_future(phi) | F ("finally") | neg(all_future(neg(phi))) |
| some_past(phi) | P ("previously") | neg(all_past(neg(phi))) |
| next(phi) | X ("next") | bot U phi |
| prev(phi) | Y ("yesterday") | bot S phi |
| weak_future(phi) | G'(phi) | phi and G(phi) |
| weak_past(phi) | H'(phi) | phi and H(phi) |
| always(phi) | triangle | H(phi) and phi and G(phi) |

The crucial derived operators for this analysis are:
- **X(phi) = bot U phi**: Next-step. Under discrete strict semantics, X(phi) at t means phi holds at t+1.
- **Y(phi) = bot S phi**: Previous-step. Y(phi) at t means phi holds at t-1.
- **F(phi) = neg(G(neg(phi)))**: "phi holds at some future time".

### 1.2 Semantics: Mixed Reflexive/Strict

Truth is evaluated at a model-history-time triple `(M, tau, t)` (from `Semantics/Truth.lean`):

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at ... phi -> truth_at ... psi
  | Formula.box phi => forall sigma in Omega, truth_at ... sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at ... s phi    -- REFLEXIVE
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at ... s phi  -- REFLEXIVE
  | Formula.untl phi psi => exists s : D, t < s /\                          -- STRICT
      truth_at ... s psi /\ forall r : D, t < r -> r < s -> truth_at ... r phi
  | Formula.snce phi psi => exists s : D, s < t /\                          -- STRICT
      truth_at ... s psi /\ forall r : D, s < r -> r < t -> truth_at ... r phi
```

**The mixed semantics precisely**:
- **G(phi) at t**: phi holds at ALL s with t <= s (reflexive: includes t itself).
- **H(phi) at t**: phi holds at ALL s with s <= t (reflexive: includes t itself).
- **phi U psi at t**: there EXISTS s with t < s (strict) such that psi holds at s, and phi holds at all r with t < r < s.
- **phi S psi at t**: there EXISTS s with s < t (strict) such that psi holds at s, and phi holds at all r with s < r < t.

This means:
- G(phi) -> phi is valid (the T-axiom for G, because t <= t).
- H(phi) -> phi is valid (the T-axiom for H).
- F(phi) at t means exists s > t with phi at s (strict future, not including t).

### 1.3 Axiom System

The proof system has 35 axiom schemata organized as:

**Propositional** (4): prop_k, prop_s, ex_falso, peirce (making the logic classical).

**Modal S5** (5): modal_t (box phi -> phi), modal_4 (box phi -> box box phi), modal_b (phi -> box diamond phi), modal_5_collapse (diamond box phi -> box phi), modal_k_dist (box(phi -> psi) -> (box phi -> box psi)).

**Temporal Base** (9):
- temp_k_dist: G(phi -> psi) -> (G(phi) -> G(psi))
- temp_4: G(phi) -> G(G(phi))
- temp_t_future: G(phi) -> phi (reflexive T-axiom)
- temp_t_past: H(phi) -> phi (reflexive T-axiom)
- temp_a: phi -> G(P(phi)) (connectedness)
- temp_a_dual: phi -> H(F(phi)) (dual connectedness)
- temp_l: always(phi) -> G(H(phi))
- temp_linearity: F(phi) /\ F(psi) -> F(phi /\ psi) \/ F(phi /\ F(psi)) \/ F(F(phi) /\ psi)
- modal_future/temp_future: modal-temporal interaction

**Discrete Extension** (16):
- **seriality_future**: G(phi) -> F(phi) (no last time)
- **seriality_past**: H(phi) -> P(phi) (no first time)
- **until_unfold**: (phi U psi) -> X(psi \/ (phi /\ (phi U psi)))
- **until_intro**: X(psi \/ (phi /\ (phi U psi))) -> (phi U psi)
- **until_induction**: G(psi -> chi) /\ G(phi /\ X(chi) -> chi) -> ((phi U psi) -> X(chi))
- **until_linearity**, **since_unfold**, **since_intro**, **since_induction**, **since_linearity**
- **until_connectedness**, **since_connectedness**
- **F_until_equiv**: F(psi) -> (neg bot) U psi (i.e., F(psi) -> top U psi)
- **P_since_equiv**: P(psi) -> (neg bot) S psi
- **x_k_dist**: X(phi -> psi) -> (X(phi) -> X(psi))
- **x_det**: neg X(phi) -> X(neg phi) (determinism of successor)
- **y_k_dist**, **y_det** (symmetric for Y)

**Inference Rules**: modus_ponens, necessitation (phi => box phi), temporal_necessitation (phi => G phi), temporal_duality (phi => swap_temporal(phi)).

### 1.4 Key Axioms for This Analysis

The three axioms directly relevant to the `forward_F` problem are:

1. **until_induction**: `G(psi -> chi) /\ G(phi /\ X(chi) -> chi) -> ((phi U psi) -> X(chi))`

   This is the temporal analog of mathematical induction. If psi implies chi (base case), and if phi together with "chi holds at the next step" implies chi (inductive step), and both hold at all future times, then phi U psi implies X(chi). This axiom is what should ultimately kill an Until-obligation that can never be resolved.

2. **F_until_equiv**: `F(psi) -> (top U psi)`

   Every F-obligation is an Until-obligation with a trivial guard. This converts the problem of resolving F(psi) into resolving (top U psi).

3. **x_det**: `neg X(phi) -> X(neg phi)` (determinism)

   The successor is unique: either phi holds at t+1 or neg(phi) holds at t+1. This is what makes x_content an MCS.

---

## 2. Maximal Consistent Sets (MCS)

### 2.1 Definitions

From `MaximalConsistent.lean`:

```lean
def Consistent (Gamma : Context) : Prop := neg Nonempty (DerivationTree Gamma Formula.bot)

def SetConsistent (S : Set Formula) : Prop :=
  forall L : List Formula, (forall phi in L, phi in S) -> Consistent L

def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S /\ forall phi : Formula, phi notin S -> neg SetConsistent (insert phi S)
```

### 2.2 Key Properties (All Proven Sorry-Free)

For any MCS `M`:

1. **Deductive Closure**: If M derives phi (via any finite subset), then phi in M. (`closed_under_derivation`)
2. **Negation Completeness**: For every phi, either phi in M or neg(phi) in M. (`negation_complete`)
3. **Theorem Membership**: Every theorem (derivable from []) is in M. (`theorem_in_mcs`)
4. **Implication Property**: If (phi -> psi) in M and phi in M, then psi in M. (`implication_property`)
5. **Consistency**: bot notin M. (`bot_not_in_mcs`)
6. **Non-contradiction**: phi and neg(phi) cannot both be in M. (`set_consistent_not_both`)

### 2.3 Lindenbaum's Lemma

```lean
theorem set_lindenbaum (S : Set Formula) (hS : SetConsistent S) :
    exists M : Set Formula, S subset M /\ SetMaximalConsistent M
```

Every consistent set extends to an MCS. Proven via Zorn's lemma. This is sorry-free.

---

## 3. The Deterministic Chain

### 3.1 Definition

From `DeterministicChain.lean`, given an MCS M_0:

```lean
noncomputable def iterate_x_content (M : Set Formula) : Nat -> Set Formula
  | 0 => M
  | n + 1 => x_content (iterate_x_content M n)

noncomputable def iterate_y_content (M : Set Formula) : Nat -> Set Formula
  | 0 => M
  | n + 1 => y_content (iterate_y_content M n)

noncomputable def deterministic_chain (M_0 : Set Formula) : Int -> Set Formula
  | (n : Nat) => iterate_x_content M_0 n
  | Int.negSucc n => iterate_y_content M_0 (n + 1)
```

**In mathematical notation**:
- chain(0) = M_0
- chain(n+1) = x_content(chain(n)) for n >= 0
- chain(-(n+1)) = y_content(chain(-n)) for n >= 0

### 3.2 Content Extractors

From `TemporalContent.lean`:

```
x_content(M) = { phi | X(phi) in M } = { phi | (bot U phi) in M }
y_content(M) = { phi | Y(phi) in M } = { phi | (bot S phi) in M }
g_content(M) = { phi | G(phi) in M }
h_content(M) = { phi | H(phi) in M }
f_content(M) = { phi | F(phi) in M }
```

### 3.3 Key Theorem: x_content Preserves MCS

```lean
theorem x_content_mcs {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : SetMaximalConsistent (x_content M)
```

**Proof sketch** (sorry-free):
- **Consistency**: If x_content(M) were inconsistent, some finite L subset x_content(M) derives bot. By x_lift_derivation (using x_k_dist), X(bot) in M. But neg X(bot) is a theorem (from X_bot_absurd), so neg X(bot) in M. Contradiction.
- **Maximality**: If phi notin x_content(M), then X(phi) notin M. By MCS negation completeness, neg X(phi) in M. By x_det, X(neg phi) in M, so neg phi in x_content(M). Then {phi, neg phi} subset insert phi (x_content M), making it inconsistent.

This is the crucial result that makes the chain deterministic: no Lindenbaum extension is needed at each step.

### 3.4 Fundamental Linkage

For ALL integers n (not just naturals):

```lean
theorem x_mem_chain_general (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (n : Int) (phi : Formula) :
    phi in deterministic_chain M_0 (n + 1) <->
    Formula.untl Formula.bot phi in deterministic_chain M_0 n
```

**In words**: phi in chain(n+1) if and only if X(phi) in chain(n).

This is trivial for n >= 0 (definitional). For n < 0, it requires the YX_round_trip lemma using the yx_identity axiom.

### 3.5 MCS at Every Position

```lean
theorem deterministic_chain_mcs (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0) :
    forall n : Int, SetMaximalConsistent (deterministic_chain M_0 n)
```

Sorry-free. By induction using x_content_mcs and y_content_mcs.

### 3.6 G-persistence and Forward G Coherence

```lean
-- G(phi) in chain(n) implies G(phi) in chain(n+1)   (via temp_4 + G->X)
-- G(phi) in chain(n) implies phi in chain(m) for all m > n  (by induction)
theorem forward_G_int : ... -- sorry-free
theorem backward_H_int : ... -- sorry-free
```

This gives us the FMCS structure (forward_G and backward_H coherence).

### 3.7 Until Persistence

```lean
theorem until_persists_chain_general (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (n : Int) (phi psi : Formula)
    (h_U : Formula.untl phi psi in deterministic_chain M_0 n)
    (h_neg_psi : psi notin deterministic_chain M_0 (n + 1)) :
    phi in deterministic_chain M_0 (n + 1) /\
    Formula.untl phi psi in deterministic_chain M_0 (n + 1)
```

**In words**: If (phi U psi) is in chain(n) and psi is NOT in chain(n+1), then BOTH phi and (phi U psi) are in chain(n+1). The Until-obligation persists forward, carrying the guard phi along.

**Proof**: By until_unfold, X(psi \/ (phi /\ (phi U psi))) in chain(n). So (psi \/ (phi /\ (phi U psi))) in chain(n+1). Since psi notin chain(n+1), we get (phi /\ (phi U psi)) in chain(n+1) by disjunction elimination.

---

## 4. The Blocker: `deterministic_forward_F`

### 4.1 Precise Statement

```lean
theorem deterministic_forward_F (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (t : Int) (psi : Formula) (h_F : Formula.some_future psi in deterministic_chain M_0 t) :
    exists s : Int, t < s /\ psi in deterministic_chain M_0 s
```

**In plain mathematics**: If F(psi) is in chain(t), then there exists s > t such that psi is in chain(s).

### 4.2 Why This Is Needed

The completeness proof requires building a `TemporalCoherentFamily`, which is an FMCS with two additional coherence properties:

```lean
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : forall t : D, forall phi : Formula,
    Formula.some_future phi in mcs t -> exists s : D, t < s /\ phi in mcs s
  backward_P : forall t : D, forall phi : Formula,
    Formula.some_past phi in mcs t -> exists s : D, s < t /\ phi in mcs s
```

Without forward_F, the canonical model does not validate the truth of F-formulas (backward direction of the truth lemma).

The forward_F property is also essential for the **backward G lemma** (`temporal_backward_G`): to show that if phi holds at all s > t in the chain, then G(phi) in chain(t). The proof goes by contraposition:
1. Assume G(phi) notin chain(t)
2. Then neg G(phi) in chain(t) (negation completeness)
3. Then F(neg phi) in chain(t) (temporal duality)
4. By forward_F: exists s > t with neg(phi) in chain(s)
5. But phi in chain(s) by hypothesis. Contradiction.

### 4.3 What the Proof Attempt Looks Like

The most natural approach:

1. F(psi) in chain(t) implies (top U psi) in chain(t) by F_until_equiv.
2. If psi in chain(t+1), we are done (witness s = t+1).
3. If psi notin chain(t+1), then by until_persists, (top U psi) in chain(t+1). Repeat.
4. Either psi appears at some chain(t+k) (done), or (top U psi) persists forever.
5. If (top U psi) persists forever without psi ever appearing, we need a contradiction.

Step 5 is where the proof gets stuck.

### 4.4 WHERE EXACTLY It Gets Stuck

To derive a contradiction from "(top U psi) persists forever but psi never appears", the natural approach uses the `until_induction` axiom:

```
G(psi -> chi) /\ G(phi /\ X(chi) -> chi) -> ((phi U psi) -> X(chi))
```

Instantiate with phi = top (= neg bot), chi = bot:
```
G(psi -> bot) /\ G(top /\ X(bot) -> bot) -> ((top U psi) -> X(bot))
```

Simplify:
- psi -> bot = neg psi
- G(neg psi) is what we need
- top /\ X(bot) -> bot simplifies to: X(bot) -> bot, which is a theorem (X_bot_absurd)
- G(X(bot) -> bot) follows from temporal necessitation of X_bot_absurd
- X(bot) = bot U bot, and (top U psi) -> X(bot) = (top U psi) -> (bot U bot)
- Since neg X(bot) is a theorem, if (top U psi) in chain(t), we'd get X(bot) in chain(t), contradiction.

So the until_induction argument works IF we can establish **G(neg psi) in chain(t)**.

And THIS is exactly the blocker: establishing G(neg psi) in chain(t) requires the backward G lemma, which requires forward_F. Circularity.

### 4.5 The Precise Lean Goal State at the Sorry

The sorry is at line 67 of `DeterministicFMCS.lean`:

```lean
theorem deterministic_forward_F (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (t : Int) (psi : Formula) (h_F : Formula.some_future psi in deterministic_chain M_0 t) :
    exists s : Int, t < s /\ psi in deterministic_chain M_0 s := by
  sorry
```

The equivalent sorry in `FiniteDeferral.lean` (line 381):

```lean
theorem forward_F_via_deferral (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (t : Int) (psi : Formula) (h_F : Formula.some_future psi in deterministic_chain M_0 t) :
    exists s : Int, t < s /\ psi in deterministic_chain M_0 s := by
  sorry
```

---

## 5. The Circularity

### 5.1 Dependency Chain

The circularity is:

```
forward_F
  needs: "neg psi in chain(s) for all s > t" implies "G(neg psi) in chain(t)"
  which is: temporal_backward_G
  which needs: forward_F (for the contrapositive argument with F(neg(neg psi)))
```

### 5.2 `temporal_backward_G_with_fwd_F`

From `TemporalCoherence.lean`:

```lean
theorem temporal_backward_G_with_fwd_F {D : Type*} [Preorder D]
    (fam : FMCS D) (t : D) (phi : Formula)
    (h_forward_F_neg : Formula.some_future (Formula.neg phi) in fam.mcs t ->
      exists s : D, t < s /\ (Formula.neg phi) in fam.mcs s)
    (h_all : forall s : D, t < s -> phi in fam.mcs s) :
    Formula.all_future phi in fam.mcs t
```

This takes forward_F as an EXPLICIT HYPOTHESIS. The proof is by contraposition:
1. If G(phi) notin chain(t), then neg G(phi) in chain(t)
2. neg G(phi) = neg(all_future phi). By temporal duality: F(neg phi) in chain(t)
3. By h_forward_F_neg: exists s > t with neg(phi) in chain(s)
4. But h_all says phi in chain(s). Contradiction.

### 5.3 Is This a Logical or Proof-Engineering Circularity?

**This is a PROOF ENGINEERING circularity, not a logical one.** The theorem `deterministic_forward_F` IS semantically true: in the intended model (integers with standard ordering), the chain construction does produce a model where F-obligations are resolved. The question is purely how to prove it syntactically.

**Evidence that it is not a logical circularity**:
1. The soundness of the axiom system is proven (sorry-free).
2. The axioms include until_induction, which is specifically designed to ensure Until-obligations terminate.
3. The chain is deterministic (unique successor), so if (top U psi) persists forever, the restricted theories must cycle (pigeonhole), and the cycle contradicts until_induction.

The difficulty is that the standard proof technique requires establishing G(neg psi) at the cycle point, and the only known way to do that in this formalization uses forward_F itself.

---

## 6. Deferral Closure and Restricted Theories

### 6.1 deferralClosure

From `SubformulaClosure.lean`:

```lean
def baseDeferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas

def deferralClosure (phi : Formula) : Finset Formula :=
  baseDeferralClosure phi
```

This is a FINITE set (it is a `Finset Formula`). It contains:
- All subformulas of phi and their negations (`closureWithNeg`)
- Deferral disjunctions for F-formulas
- Backward deferral for P-formulas
- Fixed seriality formulas (F(top), P(top), etc.)

The key property: **deferralClosure is finite** (it is literally a Finset -- finiteness is a type-level guarantee).

### 6.2 Restricted Theory

From `FiniteDeferral.lean`:

```lean
noncomputable def restrictedTheory (M_0 : Set Formula) (root : Formula) (n : Int) :
    Finset Formula :=
  (deferralClosure root).filter (fun phi => phi in deterministic_chain M_0 n)
```

This is the set of formulas from deferralClosure(root) that are in chain(n). Since deferralClosure is finite, there are at most 2^|deferralClosure(root)| possible restricted theories.

### 6.3 Pigeonhole Theorem

```lean
theorem pigeonhole_restricted_theories (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (root : Formula) (t : Int) :
    let bound := 2 ^ (deferralClosure root).card
    exists i j : Nat, i < j /\ j <= bound /\
      restrictedTheory M_0 root (t + i) = restrictedTheory M_0 root (t + j)
```

**In words**: Among any `bound + 1` consecutive chain positions starting from t, two must have the same restricted theory. This is sorry-free.

### 6.4 G_neg_kills_until

```lean
theorem G_neg_kills_until (M_0 : Set Formula) (h_mcs : SetMaximalConsistent M_0)
    (t : Int) (psi : Formula)
    (h_G_neg : Formula.all_future (Formula.neg psi) in deterministic_chain M_0 t) :
    Formula.untl (Formula.neg Formula.bot) psi notin deterministic_chain M_0 t
```

**In words**: If G(neg psi) is in chain(t), then (top U psi) cannot be in chain(t). This is sorry-free, using until_induction with chi = bot.

### 6.5 Available Infrastructure Summary

| Theorem | Status | What It Says |
|---------|--------|-------------|
| F_to_until_in_chain | sorry-free | F(psi) in chain(t) => (top U psi) in chain(t) |
| until_persists_forward_steps | sorry-free | (top U psi) persists for n steps if psi absent |
| pigeonhole_restricted_theories | sorry-free | Restricted theories must cycle |
| G_neg_kills_until | sorry-free | G(neg psi) in chain(t) kills (top U psi) |
| forward_F_via_deferral | SORRY | The actual forward_F theorem |

---

## 7. The Key Mathematical Question

### 7.1 Pure Mathematical Formulation

**Given**:
- An omega-sequence of MCS: M_0, M_1, M_2, ... where M_{n+1} = x_content(M_n)
- (top U psi) in M_0
- psi notin M_n for all n >= 1

**Question**: Derive a contradiction.

**What we know**:
1. By until_persists: (top U psi) in M_n for all n >= 0 (since psi never appears and top is always present).
2. By pigeonhole: there exist i < j such that restrictedTheory(M_i) = restrictedTheory(M_j) (where the restricted theory is with respect to deferralClosure(psi)).
3. neg(psi) in M_n for all n >= 1 (by negation completeness, since psi notin M_n).

**What we need**: A way to derive G(neg psi) in M_0 (or at any chain position), which combined with G_neg_kills_until gives a contradiction.

### 7.2 The Gap

The gap is precisely: **how to get from "neg(psi) in M_n for all n >= 1" to "G(neg psi) in M_0"**.

In the semantics, this is trivially true: if neg(psi) holds at all future times, then G(neg psi) holds. But syntactically, the backward G lemma (`temporal_backward_G`) requires forward_F to convert neg(G(neg psi)) to F(neg(neg psi)) = F(psi) and then find a witness -- which is what we are trying to prove.

### 7.3 Can the Cycle Help Directly?

The insight that SHOULD work: the restricted theory cycle means that the chain is "eventually periodic" in the formulas from deferralClosure. Specifically, if restrictedTheory(M_i) = restrictedTheory(M_j) with i < j, then the period is k = j - i. Now:

- (top U psi) in M_i (and in M_j, since the restricted theories agree and (top U psi) is in deferralClosure(psi))
- neg(psi) in M_{i+1}, ..., M_j (since psi never appears)
- The restricted theories at positions i, i+1, ..., j-1, j cycle with period k

The until_induction axiom says:
```
G(neg psi) /\ G(step_formula) -> ((top U psi) -> X(bot))
```

where step_formula is a derivable theorem (established sorry-free in G_neg_kills_until).

So we need G(neg psi) at position i. If we could show that the cycle FORCES G(neg psi) to be in M_i, we would be done.

But G(neg psi) in M_i means: for all s >= i, neg(psi) in M_s (under the reflexive semantics of G). We know neg(psi) is in M_n for all n >= 1, but establishing this AS A G-formula in the MCS requires the backward G inference, which requires forward_F.

### 7.4 Alternative: Direct Cycle Contradiction via Until Induction

The most promising approach avoids backward_G entirely. Instead of trying to establish G(neg psi) globally, use the cycle structure directly with until_induction.

**Key idea**: The until_induction axiom works locally. If we can show that within the cycle [i, j], the premises of until_induction hold at every position, then we get X(bot) at position i from (top U psi) at position i.

The until_induction axiom says (instantiated with phi = top, chi = bot):
```
G(neg psi) /\ G(top /\ X(bot) -> bot) -> ((top U psi) -> X(bot))
```

The second conjunct G(top /\ X(bot) -> bot) follows from G of a theorem. The first conjunct G(neg psi) is the hard part.

**But what if we use a different instantiation of chi?** Instead of chi = bot, use chi = some formula that captures "we are still in the cycle". This is the approach hinted at in the quasimodel literature.

### 7.5 The Quasimodel Alternative

The standard resolution in the literature (Gabbay-Hodkinson-Reynolds 1994, Reynolds 2003) uses a fundamentally different construction:

Instead of building a single deterministic chain and then trying to prove it has the right properties, the **quasimodel approach** builds the canonical model globally:

1. Start with a "quasimodel" -- a set of MCS with explicit witness pointers for each F-obligation.
2. Use filtration/finite model techniques to ensure all eventualities are resolved.
3. The key difference: witnesses for F(psi) are BUILT INTO the construction, not derived after the fact.

In the quasimodel approach:
- You enumerate all F-obligations in the root formula's closure.
- You build a finite graph of MCS where each F-obligation has an explicit witness edge.
- The induction axiom ensures this graph can be "unfolded" into a linear model.

This avoids the circularity entirely because forward_F is guaranteed by construction, not proven after the fact.

---

## 8. Published Proof Techniques

### 8.1 Overview of Standard Approaches

The completeness proof for temporal logic with Until over discrete linear time (integers) has been addressed by several authors:

1. **Burgess (1984)**: In the *Handbook of Philosophical Logic*, Vol. II. Uses a canonical model construction with a modified filtration. The key technique is to build the canonical model and then FILTER it to a finite model where all eventualities are resolved. The filtration uses the subformula closure.

2. **Gabbay-Hodkinson-Reynolds (1994)**: *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1. Uses the "quasimodel" technique. A quasimodel is a set of MCS with successor/predecessor functions and explicit witness functions for each Until/Since formula. The completeness proof first builds a quasimodel from the consistent formula, then shows it can be "unraveled" into a linear model.

3. **Goldblatt (1992)**: *Logics of Time and Computation*. Uses canonical models with filtration for decidability. The completeness proof for the basic temporal logic (without Until) uses standard canonical models. For Until, additional machinery is needed.

4. **Reynolds (2003)**: "A Hierarchical Completeness Proof for Propositional Temporal Logic". Uses a hierarchical approach with induction on formula complexity to handle nested temporal operators.

5. **Venema (Chapter in *Handbook of Modal Logic*, 2007)**: Provides a comprehensive treatment of temporal logic completeness with step-by-step canonical model construction.

### 8.2 The Standard Resolution

The standard way to handle forward_F in completeness proofs for discrete temporal logic with Until is one of:

**(A) Build witnesses into the construction (quasimodel approach)**:
- For each F(psi) in the root MCS, explicitly construct a chain segment that resolves it.
- The chain is not a single deterministic chain but a carefully assembled sequence of MCS.
- At each step, choose the successor MCS to resolve the "most urgent" F-obligation.
- The pigeonhole argument ensures this terminates.

**(B) Use well-founded induction on formula complexity (Reynolds approach)**:
- Prove forward_F by induction on the complexity of psi.
- For atomic psi: the chain either contains psi or doesn't; if F(psi) in M_0 but psi never appears, use the cycle + induction axiom with simpler formulas.
- For compound psi: reduce to simpler cases.
- The key: the induction hypothesis gives forward_F for SIMPLER formulas, which suffices for backward_G for those formulas, breaking the circularity.

**(C) Use filtration (Burgess approach)**:
- Build the full canonical model (which is correct for G/H but not for Until).
- Apply a filtration that identifies MCS agreeing on the subformula closure.
- The filtered model is finite, so Until-obligations must resolve (pigeonhole).
- Show the filtration preserves truth.

### 8.3 Why the Current Approach Gets Stuck

The current ProofChecker approach builds a single deterministic chain via x_content iteration. This is elegant and gives forward_G/backward_H for free. But it makes forward_F hard because:

1. The chain is built without regard to F-obligations -- x_content just takes the "next-step content" of the current MCS.
2. Whether psi eventually appears in the chain depends on the GLOBAL structure of the MCS M_0, not just its local properties.
3. The only tool to force psi to appear is the until_induction axiom, but using it requires G(neg psi), which requires forward_F.

The fundamental issue: **the deterministic chain construction is a PUSH-based construction** (each MCS determines its successor), but **F-resolution is a PULL-based property** (an obligation at time t needs a witness at some future time s). The push doesn't guarantee the pull.

### 8.4 Recommended Approaches (Ordered by Feasibility)

**Approach 1: Well-Founded Induction on Formula Complexity** (estimated ~200-400 lines)

The key observation: `temporal_backward_G_with_fwd_F` takes forward_F as an explicit hypothesis. If we prove forward_F by strong induction on `psi.complexity`, then when proving forward_F for psi, we can use forward_F for all formulas SIMPLER than psi. This gives us backward_G for simpler formulas.

The question is whether F(psi) in chain(t) with psi never appearing can be contradicted using backward_G only for formulas simpler than psi. The answer depends on whether the until_induction argument can be instantiated with chi of lower complexity than psi.

**Problem**: F(psi) has the SAME complexity as G(neg psi) (both are one level of temporal nesting around psi). So the standard induction doesn't obviously work. The complexity of neg(psi) equals the complexity of psi plus a constant, and F(neg(neg(psi))) would have comparable complexity. The well-founded measure needs careful choice.

**Approach 2: Direct Cycle Argument** (estimated ~300-500 lines)

Use the pigeonhole cycle directly without backward_G. The idea:
1. Establish that restricted theories cycle: restrictedTheory(M_i) = restrictedTheory(M_j).
2. Show that (top U psi) in M_i and (top U psi) in M_j.
3. Show that neg(psi) in M_n for i < n <= j (finite conjunction).
4. Use the finiteness of deferralClosure to build a FINITE conjunction capturing the restricted theory, and show this conjunction implies G(neg psi) within the cycle via a local argument.

The challenge: formalizing "G(neg psi) holds within the cycle" without invoking backward_G globally.

**Approach 3: Quasimodel Construction** (estimated ~1000+ lines)

Build a completely new canonical model construction that resolves F-obligations by design. This is the "nuclear option" but is guaranteed to work because it follows the standard literature.

---

## 9. Summary: The Root Cause and the Path Forward

### 9.1 Root Cause

The `deterministic_forward_F` sorry exists because the deterministic chain construction (chain(n+1) = x_content(chain(n))) builds each successor MCS purely from the previous one's next-step content, without any mechanism to ensure F-obligations are eventually resolved. The chain may "defer" an F-obligation indefinitely, and proving that this cannot happen requires establishing G(neg psi), which in turn requires forward_F (circularity).

### 9.2 What Exactly Is Missing

One of:
- A way to derive G(neg psi) in chain(t) from "neg psi in chain(s) for all s > t" WITHOUT using forward_F. (This would break the circularity.)
- A well-founded induction measure that makes the circularity vanish.
- A completely different canonical model construction where F-witnesses are built in.

### 9.3 The Clean Mathematical Question

**Question**: Let T be the axiom system of TM (35 axiom schemata + 4 inference rules). Let M_0 be a set-maximal consistent set with respect to T. Define chain(n) = x_content^n(M_0) for n >= 0. Suppose F(psi) in chain(0) and psi notin chain(n) for all n >= 1. Derive a contradiction using only the axioms of T and properties of MCS.

**Known infrastructure**: (top U psi) persists in all chain(n). The restricted theories cycle. G(neg psi) in chain(0) would give a contradiction via until_induction. But deriving G(neg psi) from "neg psi in all chain(n) for n >= 1" requires forward_F for neg(neg(psi)).

**The question reduces to**: Can until_induction be applied directly to the cycle structure without first establishing G(neg psi) as an MCS membership? Specifically: can the FINITE conjunction of "neg psi at positions i+1, ..., j" (the cycle) be used to instantiate until_induction in a way that produces a contradiction with (top U psi) at position i?

---

## Appendix: File Reference

| File | Content | Lines |
|------|---------|-------|
| `Syntax/Formula.lean` | Formula type, derived operators | 551 |
| `ProofSystem/Axioms.lean` | 35 axiom schemata | ~700 |
| `Semantics/Truth.lean` | Truth evaluation (mixed semantics) | ~180 |
| `Metalogic/Core/MaximalConsistent.lean` | MCS definitions, Lindenbaum | 523 |
| `Metalogic/Bundle/TemporalContent.lean` | x/y/g/h/f_content, x_content_mcs | 441 |
| `Metalogic/Algebraic/DeterministicChain.lean` | Chain definition, G/H persistence | ~700 |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | FMCS/BFMCS bundle, forward_F sorry | 528 |
| `Metalogic/Algebraic/FiniteDeferral.lean` | Deferral infrastructure, pigeonhole | 383 |
| `Metalogic/Bundle/TemporalCoherence.lean` | backward_G, backward_G_with_fwd_F | 481 |
| `Syntax/SubformulaClosure.lean` | deferralClosure definition | ~800 |

## Appendix: Search Queries Used

- Codebase: Glob for `*.lean` in Metalogic/Algebraic/ and Metalogic/Bundle/
- Codebase: Grep for `forward_F`, `deferralClosure`, `until_induction`, `temporal_backward_G`
- Web: "canonical model completeness temporal logic Until operator" (Gabbay, Hodkinson, Reynolds)
- Web: "Burgess 1984 completeness proof Until temporal logic canonical model"
- Web: "Goldblatt Logics of Time and Computation completeness Until"
- Web: "Reynolds 2003 temporal logic completeness Until discrete integer time"
- Web: Venema temporal logic chapter (PDF at staff.science.uva.nl)

## Appendix: Published References

- Burgess, J.P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic*, Vol. II.
- [Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1. Oxford University Press.](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI Publications.](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [Reynolds, M. (2003). "A Hierarchical Completeness Proof for Propositional Temporal Logic." In *Advances in Modal Logic*, Vol. 4.](https://link.springer.com/chapter/10.1007/978-3-540-39910-0_22)
- [Venema, Y. (2007). "Temporal Logic." Chapter in *Handbook of Modal Logic*.](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Hodkinson, I. and Reynolds, M. (2007). "Separation -- past, present, and future."](https://www.doc.ic.ac.uk/~imh/papers/sep.pdf)
- [Stanford Encyclopedia of Philosophy: Temporal Logic.](https://plato.stanford.edu/entries/logic-temporal/)
