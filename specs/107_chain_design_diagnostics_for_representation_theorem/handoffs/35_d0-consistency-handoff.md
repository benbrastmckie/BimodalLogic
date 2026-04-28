# Handoff: D0 Consistency Proof (Task 107, Phase 1, Task 1.2)

## Status: Partial Progress

## What Was Accomplished

### Sorry-Free Theorems Added to PointInsertion.lean

1. **`F_mono_mcs`** (lines ~822-855): F-monotonicity at MCS level. If `|- X -> Y` and `F(X) in A` then `F(Y) in A`. Proof uses BX12 (F-Until equivalence), BX3 (right mono until), and BX10 (until implies F).

2. **`left_mono_contrapositive_neg_delta`** (lines ~863-920): The key intermediate result. Given `untl(beta,gamma) in A` and `untl(beta AND delta, gamma) not in A`, derives: `neg(delta) in A OR F(neg(delta)) in A`. Uses BX2 (left mono until) contrapositive, De Morgan in MCS, F_neg_of_G_not, and F_mono_mcs. The propositional step uses flip of pairing combinator + contrapositive.

### Derivation Chain Identified

From `BurgessR3Maximal_maximality_combined`: not both extension conditions hold. At least one fails.

WLOG Until condition fails: there exist beta0 in B, gamma0 in C such that `untl(beta0 AND delta, gamma0) not in A`.

From burgessR3: `untl(beta0, gamma0) in A`.

Apply `left_mono_contrapositive_neg_delta`: `neg(delta) in A OR F(neg(delta)) in A`.

Similarly for the Since side (symmetric argument): `neg(delta) in C OR P(neg(delta)) in C`.

## What Remains: The Mixed A/C Problem

### The Gap

D0 = {snce(beta,alpha) : alpha in A, beta in B} UNION B UNION {neg(delta)} UNION {untl(beta,gamma) : beta in B, gamma in C}

Elements partition into:
- B elements: in A AND C
- Until formulas: in A (not necessarily C)
- Since formulas: in C (not necessarily A)
- neg(delta): the "new" element

Even knowing `neg(delta) in A` or `F(neg(delta)) in A`, the proof needs to show that mixing elements from A (B + Until + possibly neg(delta)) with elements from C (B + Since) cannot derive bot.

### Why This Is Hard

1. There are NO axioms that directly combine Until and Since formulas to produce bot.
2. Propositional content extractable from Until/Since guards is all in B (consistent DCS).
3. But a formal proof requires either:
   - A structural induction on derivation trees showing Until-Since interaction is harmless
   - Or finding an MCS containing all of D0

### Approaches Not Yet Tried

1. **Derivation tree analysis**: Show that any derivation from D0 elements that reaches bot must pass through propositional content in B. Since B is consistent, bot is unreachable. This requires a deep structural argument about the derivation system.

2. **Semantic/model-theoretic shortcut**: Construct a model where all D0 formulas hold simultaneously, then use soundness. But we're INSIDE the completeness proof, so this is circular.

3. **Weaker seed**: Replace D0 with a smaller seed (e.g., B UNION {neg(delta)}) that IS provably consistent, then show the Lindenbaum extension satisfies burgessR3 anyway. This would require different lemmas for tasks 1.3-1.5.

4. **Two-seed approach**: Use `neg(delta) in A OR F(neg(delta)) in A` to construct D via the simpler `lemma_2_6` (g_content based), then show burgessR3(A,B,D) and burgessR3(D,B,C) hold for the resulting D. This bypasses D0 entirely but changes the plan structure.

### Plan Compliance Note

The plan specifies D0 as the seed with the full Since/Until/B/neg(delta) structure. The plan's proof strategy (BX5+BX7 chain) has a gap: BX7 cannot introduce delta or neg(delta) into formulas that don't already contain it. The BX2 contrapositive approach (implemented here) provides the neg(delta) derivation but leaves the mixed A/C consistency unresolved.

The plan may need revision to either:
- Provide a correct proof strategy for D0 consistency
- Or adopt the "two-seed" or "weaker seed" approach

## Recommendation

Run `/revise 107` to update the plan with the correct proof strategy. The `left_mono_contrapositive_neg_delta` result is a key building block regardless of which approach is used. The two-seed approach (approach 4 above) seems most promising: use `neg(delta) in A` case to get D = Lindenbaum({neg(delta)} UNION B), then prove burgessR3 directly.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`: Added `F_mono_mcs` and `left_mono_contrapositive_neg_delta` (sorry-free). `burgess_D0_consistent` still has sorry.

## Session

Session: sess_1777335149_b303e3
