# Teammate A Findings: Deep Analysis of bx_le Non-Totality

**Task**: 102 - Implement defect-discharge chain and close Until/Since sorries
**Angle**: Why bx_le is non-total, and what mathematical structure would fix it
**Date**: 2026-04-11
**Confidence**: High (mathematical analysis), Medium (fix recommendations)

---

## 1. WHY bx_le IS NON-TOTAL

### 1.1 The Definition

From `Frame.lean:61`:
```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

where from `TemporalContent.lean:51`:
```lean
def g_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}
```

So `bx_le w v` iff: for every formula phi, if `G(phi) ∈ w` then `phi ∈ v`.

### 1.2 Concrete Non-Totality Example

**Confidence: HIGH**

Consider two MCSs w and v where:
- `G(p) ∈ w` but `p ∉ v` (so `bx_le w v` fails)
- `G(q) ∈ v` but `q ∉ w` (so `bx_le v w` fails)

This is consistent with BX axioms. Construct:
1. Start with seed `S_w = {G(p), ~q, ...}`. BX1 gives `p ∈ w` (from G(p)). The formula `~q` is freely choosable and does not contradict G(p). Extend to MCS w by Lindenbaum.
2. Start with seed `S_v = {G(q), ~p, ...}`. BX1 gives `q ∈ v` (from G(q)). The formula `~p` is freely choosable and does not contradict G(q). Extend to MCS v.

Now: `p ∈ g_content(w)` but `p ∉ v`, so `bx_le w v` fails.
And: `q ∈ g_content(v)` but `q ∉ w`, so `bx_le v w` fails.

The formulas creating incomparability can be ANY formulas -- even atomic propositions. The ordering `bx_le` only constrains the G-content, not arbitrary formula membership. Two MCSs whose G-contents point in "different directions" are incomparable.

### 1.3 Root Cause: bx_le is Really a Domain-Theoretic Ordering

The ordering `g_content(w) ⊆ v` is an **information ordering**: w sees v as "the future" if everything w commits to being always-true-in-the-future is indeed true at v. This is a preorder (reflexive by BX1, transitive by BX4/temp_4), but it is NOT total because two MCSs can make different G-commitments that are mutually exclusive.

In domain theory terms, bx_le is an **approximation ordering** on the space of MCSs projected through the G-lens. Two MCSs that make independent G-commitments are "incomparable information states" -- neither approximates the other.

### 1.4 Why This Matters for the Sorries

The four Frame.lean sorries all use the guard pattern:

```
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This quantifies over ALL BXPoints u satisfying `bx_le w u ∧ bx_le u v ∧ ¬bx_le v u` (i.e., strictly between w and v in the bx_le ordering).

**Forward direction problem**: We can construct a backward witness u' (via BX9, getting `phi ∈ u'` from `phi U psi ∈ u'`). But given an arbitrary u with `bx_le w u`, we need `phi ∈ u`. The only propagation mechanism is through G-formulas: `bx_le` transmits `G(phi)` but not `phi` itself. So from `phi ∈ u'` and `bx_le u' u`, we CANNOT derive `phi ∈ u` unless `G(phi) ∈ u'` -- which is a much stronger condition.

**Backward direction problem**: We construct an enriched seed with the right properties and extend to an MCS u. We can show `bx_le w u` and `bx_le u v`, but we CANNOT show `¬bx_le v u` because the Lindenbaum extension may have added formulas that make `g_content(v) ⊆ u` true. The non-totality means `bx_le u v ∧ ¬bx_le v u` is a "strict inequality" that is NOT guaranteed for two related points.

---

## 2. THE PRECISE MATHEMATICAL GAP

### 2.1 What Standard Completeness Proofs Do Differently

**Confidence: HIGH**

In Burgess (1984) and Goldblatt (1992), the canonical model for temporal logic is NOT the raw collection of MCSs with the g_content ordering. Instead, they construct a **specific linear model** -- typically one of:

**(A) Finite chain model (Burgess)**: For a specific formula phi to be falsified, build a finite sequence of Hintikka sets (finite consistent fragments) h_0, h_1, ..., h_k where:
- The ordering is the chain index (total by construction)
- Each h_i is a fragment of an MCS restricted to a finite closure set Sigma
- The defect count decreases along the chain, ensuring termination
- The guard phi holds at each intermediate point by BX9 (until_elim)

**(B) Step-by-step construction (Goldblatt)**: Build MCSs one at a time, extending each using Lindenbaum. The ordering is again positional (total by construction).

**In both cases, the ordering used is NOT g_content inclusion. It is positional: point i comes before point j iff i < j in the construction sequence.** The g_content inclusion is then a CONSEQUENCE of the construction (each step propagates G-formulas), not the definition.

### 2.2 Why This Codebase's Approach Diverges

This codebase defines `bx_le` as `g_content ⊆` FIRST, then tries to prove Until/Since properties of this ordering. This is backwards from the standard approach:

- **Standard**: Build linear model first, THEN verify it satisfies G-content propagation
- **This codebase**: Define ordering as G-content propagation, THEN try to prove linearity-dependent properties

The codebase's approach works perfectly for G and H truth (which are exactly about G-content propagation). It also works for box (modal equivalence is preserved along bx_le, proved in `box_preserved_along_bx_le`). But Until/Since truth requires the ordering to have a property (totality or at minimum comparability along witnesses) that g_content inclusion does NOT have.

### 2.3 The Soundness Proof Reveals the Gap

The soundness proof for BX7 (linear_until) in `SoundnessLemmas.lean:1249` uses:

```lean
rcases le_or_lt s1 s2 with h_le | h_lt
```

This is `le_or_lt` on the time domain D, which is a **linear order**. The case split is: either the first Until witness comes before the second, or vice versa. This is the essential use of totality.

In the canonical model with bx_le, we do NOT have `bx_le s1 s2 ∨ bx_le s2 s1` for arbitrary BXPoints s1, s2. This is precisely why the canonical model approach cannot mimic the soundness argument.

---

## 3. CAN bx_le BE STRENGTHENED TO BE TOTAL?

### 3.1 Simple Strengthening: Union with h_content

**Confidence: LOW (likely fails)**

One might try:
```
def bx_le' w v := g_content w ⊆ v ∨ h_content v ⊆ w
```

But this does NOT give totality either. Two MCSs can have incomparable g_content AND incomparable h_content.

Moreover, adding conditions via disjunction typically destroys transitivity. If `bx_le' w u` holds via the left disjunct and `bx_le' u v` holds via the right disjunct, we cannot combine them.

### 3.2 Well-Ordering the MCSs

**Confidence: MEDIUM (theoretically possible, practically expensive)**

Since Formula is countable (proved in the codebase), the set of MCSs is a subset of `Set Formula` and can be well-ordered by the axiom of choice. We could define `bx_le_total w v := well_order w v` for some arbitrary well-ordering. But this completely destroys the connection to G-content, so the G/H truth lemma would need to be reproved from scratch.

### 3.3 Restrict to a Total Sub-ordering

**Confidence: HIGH (this is the standard approach)**

Rather than making bx_le total on ALL BXPoints, restrict attention to a specific finite chain of BXPoints where the ordering IS total by construction. This is the Burgess defect-discharge chain approach. The chain is built by:

1. Start at w_0 (the point with `phi U psi`)
2. At each step, if the current point has `psi`, stop. Otherwise, use BX5 (self-accumulation) and BX10 (eventuality) to construct the next point.
3. The ordering is the chain index. Totality is trivial.

**What breaks**: The truth lemma in TruthLemma.lean is stated for ALL BXPoints, not just chain members. So the statement `until_iff_mcs` as currently written CANNOT be proved using a chain-based argument, because the guard quantifies over ALL u with `bx_le w u`, not just chain members.

---

## 4. WEAKER FORMS OF TOTALITY

### 4.1 Witness-Restricted Totality

**Confidence: MEDIUM-HIGH**

Could we prove: "for any w with `phi U psi ∈ w` and `psi ∉ w`, there exists v with `bx_le w v`, `psi ∈ v`, and for all u with `bx_le w u` and `bx_le u v` and `¬bx_le v u`, `phi ∈ u`?"

This is exactly the statement of `bx_until_eventuality_resolution`. The question is whether we can find a SPECIFIC v such that the guard works.

Key insight: Using BX10, `F(psi) ∈ w`, so there exists some v with `bx_le w v` and `psi ∈ v` (via `bx_forward_witness`). The question is whether we can CHOOSE this v such that all intermediate points satisfy phi.

**The problem is the Lindenbaum lemma**: when we extend a seed to an MCS, we have NO control over which of the (uncountably many) possible extensions we get. Different extensions may or may not be bx_le-comparable with other points.

### 4.2 Reformulating the Guard

**Confidence: HIGH (this is the key insight)**

The guard `∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → phi ∈ u` is asking about ALL BXPoints. But the semantic truth condition asks about all time points in a LINEAR model. The mismatch is fundamental.

**The correct canonical-model approach for Until/Since does NOT prove the biconditional with this guard over all BXPoints.** Instead, it:

1. Builds a specific finite linear model (chain of Hintikka sets)
2. Proves the truth lemma IN that finite model
3. Shows the finite model falsifies the same formulas as the canonical model

This is the **filtration** or **quasimodel** approach. The existing infrastructure in `Quasimodel/` is precisely this approach.

### 4.3 Bypassing the Guard Entirely

**Confidence: HIGH**

If `until_iff_mcs` and `since_iff_mcs` are truly NOT consumed downstream (confirmed in Round 2 research, Finding A2), then we have freedom to:

1. Delete the current `until_iff_mcs`/`since_iff_mcs` statements
2. Replace them with equivalent statements using the quasimodel chain
3. Use those in the completeness theorem

The completeness theorem only needs: "if phi is consistent, there exists a model and a point where phi is true." It does NOT need the biconditional form of `until_iff_mcs` -- it only needs the forward direction.

---

## 5. RELATIONSHIP BETWEEN bx_le AND SEMANTIC ORDERING

### 5.1 Semantic Setup

From `Truth.lean:128`:
```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```

The time domain D has a **total linear order** (`≤` and `<`). The guard is over `r : D` with `t ≤ r ∧ r < s` -- all points STRICTLY between t and s.

### 5.2 Canonical-Semantic Correspondence

In the canonical model:
- Points are BXPoints (MCSs)
- The ordering is `bx_le` (g_content inclusion)
- The valuation is formula membership

The correspondence for G/H is exact:
- `G(phi) ∈ w` iff `∀ v, bx_le w v → phi ∈ v` (reflexive universal future)
- This matches `truth_at ... (all_future phi) = ∀ s, t ≤ s → truth_at ... s phi`
- Here `bx_le w v` corresponds to `t ≤ s`

For Until, the correspondence SHOULD be:
- `phi U psi ∈ w` iff `∃ v, bx_le w v ∧ psi ∈ v ∧ ∀ u, bx_le w u → bx_lt u v → phi ∈ u`
- This matches `∃ s, t ≤ s ∧ psi(s) ∧ ∀ r, t ≤ r → r < s → phi(r)`
- Here `bx_lt u v` corresponds to `r < s`

### 5.3 WHERE THE CORRESPONDENCE BREAKS

In the semantic model, `r < s` means `r ≤ s ∧ ¬(s ≤ r)`, which in a total order is equivalent to `r ≤ s ∧ r ≠ s`. The guard `∀ r, t ≤ r → r < s → phi(r)` quantifies over a LINEAR INTERVAL [t, s).

In the canonical model, `bx_lt u v` means `bx_le u v ∧ ¬bx_le v u`. But because bx_le is NOT total, the "interval" `{u | bx_le w u ∧ bx_lt u v}` is NOT a linearly ordered set -- it can contain incomparable points. The guard asks for phi at ALL of them, but we can only derive phi at specific points (those constructible from the axioms).

**The fundamental mismatch**: The semantic model has a LINEAR interval [t, s) where the guard must hold. The canonical model has a PARTIALLY ORDERED "interval" where the guard must hold. The partial order admits points that have no semantic counterpart -- "junk" BXPoints that arise from Lindenbaum extensions of unrelated seeds.

### 5.4 Why This Gap Does NOT Affect Soundness

Soundness goes FROM semantic truth TO derivability. The semantic model's linearity is GIVEN. We verify that BX axioms are sound on linear orders. No problem.

Completeness goes FROM derivability TO semantic truth. We build a model and show it satisfies the right things. The canonical model's bx_le ordering is too weak (non-total) for this. The fix is not to repair bx_le but to build a DIFFERENT model -- a finite linear model where the ordering IS total.

---

## 6. RECOMMENDED APPROACH

### 6.1 The Quasimodel Path (Highest Confidence)

**Confidence: HIGH (80%+)**

The existing Quasimodel infrastructure (`HintikkaPoint`, `hintikka_step`, `defect_count`, etc.) is designed for exactly this purpose. The approach:

1. For a given formula chi to be falsified, compute the subformula closure Sigma
2. Build a finite chain of Hintikka points (Sigma-restricted consistent fragments)
3. Each Until-defect gets discharged along the chain
4. The chain IS linearly ordered (by construction index)
5. Prove the truth lemma on this finite linear model
6. Show chi is false at some point in the model

This approach never needs bx_le to be total. The ordering on the chain is positional.

### 6.2 What to Do About Frame.lean

**Option 1 (Recommended)**: Delete the 4 Frame.lean sorries and reformulate `until_iff_mcs`/`since_iff_mcs` to not quantify over all BXPoints. Instead, state the truth lemma only for the quasimodel chain.

**Option 2**: Keep the Frame.lean sorries but mark them as `axiom` (acknowledging they are NOT provable with the current bx_le definition). Use the quasimodel approach for the actual completeness proof.

**Option 3 (Not Recommended)**: Try to prove the sorries as stated. This requires either (a) making bx_le total (breaks everything), or (b) finding a subtle argument that avoids totality (no one has found one after extensive investigation).

### 6.3 Why the Guard Cannot Be Fixed Within bx_le

Any attempt to fix the guard while keeping bx_le as the ordering faces the same obstacle: the guard quantifies over ALL BXPoints in the "interval", but BXPoints are constructed by Lindenbaum extension which gives no control over bx_le-comparability. The only way to control comparability is to control the construction -- which means building a specific chain, not quantifying over all possible MCSs.

---

## 7. CONFIDENCE LEVELS SUMMARY

| Finding | Confidence | Reasoning |
|---------|------------|-----------|
| bx_le is non-total | VERY HIGH | Concrete counterexample constructed |
| Standard proofs use total order by construction | HIGH | Verified against Burgess/Goldblatt descriptions |
| bx_le cannot be made total while preserving G/H truth | HIGH | Would need to redefine the ordering, breaking existing proofs |
| The 4 sorries are not provable as stated | HIGH | The guard quantifies over too many points |
| Quasimodel approach bypasses the problem | HIGH | Existing infrastructure confirms feasibility |
| until_iff_mcs can be safely reformulated | MEDIUM-HIGH | Round 2 confirmed it's not consumed downstream; needs re-verification |
| Reformulated truth lemma suffices for completeness | MEDIUM | Completeness theorem structure needs examination |
