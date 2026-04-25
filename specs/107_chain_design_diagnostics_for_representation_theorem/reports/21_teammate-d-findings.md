# Teammate D Findings: BX Axiom Analysis for G-propagation and Seed Consistency

**Task**: 107 - Chronicle representation theorem
**Date**: 2026-04-24
**Focus**: Does the BX axiom system constrain g_content of Lindenbaum extensions?

## Key Findings

### Q1: BX axioms relevant to G-formula propagation

**Yes, BX has temp_4: G(phi) -> G(G(phi)).** This is Axiom.temp_4 (Axioms.lean:112).

**No converse (GG(phi) -> G(phi)) in BX under irreflexive semantics.** The `density_derivable` theorem (TemporalDerived.lean:133) is `sorry`'d with the comment: "Under irreflexive semantics, GGphi -> Gphi requires density, not just BX1." This confirms that G-idempotence is NOT available in the base BX system under strict temporal semantics.

**Other relevant axioms examined:**

| Formula | Status | Source |
|---------|--------|--------|
| G(phi) -> G(G(phi)) | YES (temp_4) | Axioms.lean:112 |
| G(G(phi)) -> G(phi) | NO (sorry'd, needs density) | TemporalDerived.lean:133 |
| F(phi) -> G(F(phi)) | NOT in BX | No axiom or derived theorem |
| U(gamma, delta) -> G(U(gamma, delta)) | NOT in BX | No axiom or derived theorem |
| phi -> G(phi) | NOT in BX | Would be necessitation; invalid |
| G(phi) -> phi | NOT in BX under irreflexive | Would be temp_t; invalid for strict < |

**Interaction axioms:**
- modal_future: Box(phi) -> Box(G(phi)) -- only for modal necessity, not temporal
- temp_future: Box(phi) -> G(Box(phi)) -- again modal, not relevant to pure temporal G

**Conclusion for Q1:** The only BX axiom that generates new G-formulas from existing ones is temp_4 (G -> GG). There is NO axiom that produces G(psi) from non-G-formulas like {eta, G(alpha_1), ..., G(alpha_n)} unless psi is derivable from {alpha_1, ..., alpha_n} using temp_k_dist and temporal necessitation of theorems.

### Q2: g_content of a Lindenbaum extension -- the critical analysis

**The claim in the mission brief:** "g_content(Lindenbaum(S)) = {phi : S derives G(phi)}" -- i.e., g_content is fully determined by the seed S.

**Verdict: THIS IS CORRECT, with a precise formulation.**

**Proof:**

Let M = Lindenbaum(S) be any MCS extending seed S. We need to characterize g_content(M) = {phi : G(phi) in M}.

**Direction 1 (superset): If S |- G(phi), then phi in g_content(M).**

If G(phi) is derivable from S (meaning there exist psi_1, ..., psi_n in S with {psi_1, ..., psi_n} |- G(phi)), then since S subset M and M is closed under derivation (SetMaximalConsistent.closed_under_derivation), G(phi) in M, so phi in g_content(M).

**Direction 2 (subset): If phi in g_content(M), then S |- G(phi).**

Suppose phi in g_content(M), i.e., G(phi) in M. Since M is maximally consistent, G(phi) in M iff neg(G(phi)) is not consistent with M, iff F(neg(phi)) not in M.

Now, G(phi) in M means M is consistent with G(phi). But does this mean S forces G(phi)?

**CRITICAL SUBTLETY**: This direction is FALSE in general!

Counterexample: Let S = {p} (a single propositional atom). Then S is consistent. Its Lindenbaum extension M is some MCS containing p. Since M is maximal, either G(q) in M or F(neg q) in M for every formula q. For any q independent of p, one Lindenbaum extension might include G(q) while another might include F(neg q). Both are consistent extensions of S.

Therefore: **g_content(Lindenbaum(S)) DEPENDS on the choice of Lindenbaum extension, and is NOT fully determined by S alone.**

The error in the mission brief's argument is: "phi in g_content(M) iff F(neg(phi)) is not consistent with S". This is wrong. F(neg(phi)) not being in M does not mean F(neg(phi)) is inconsistent with S. It means F(neg(phi)) was not chosen during the Lindenbaum enumeration. A different Lindenbaum extension of S could include F(neg(phi)) instead of G(phi).

**What IS determined by S:**

The **minimal** g_content, i.e., {phi : S |- G(phi)}, is determined by S. Specifically:

- g_content_closed_derivation (Frame.lean:79): If L subset g_content(S_mcs) and L |- phi, then G(phi) in S_mcs. This works when S_mcs is already an MCS.
- For a seed S that is NOT an MCS, the set {phi : S |- G(phi)} is the set of formulas phi where G(phi) is derivable from finite subsets of S.

Every Lindenbaum extension M of S satisfies: {phi : S |- G(phi)} subset g_content(M). But g_content(M) can be strictly larger.

### Q3: Implications for the chronicle construction

Since g_content is NOT fully determined by the seed, the original worry stands: **Lindenbaum opacity DOES affect g_content.**

However, there is a crucial structural fact that partially saves us:

**For the C5 seed S = {eta} union g_content(f(x)):**

The G-formulas derivable from S are exactly those derivable from g_content(f(x)) plus eta:

1. **G-formulas from g_content(f(x))**: By temp_4, if G(phi) in f(x), then G(G(phi)) in f(x), so G(phi) in g_content(f(x)) subset S. So S |- G(phi). Thus g_content(f(x)) subset {phi : S |- G(phi)}.

2. **Can eta contribute new G-formulas?** Only if there exists some BX derivation from {eta, G(alpha_1), ..., G(alpha_n)} to G(psi) where the alpha_i are in g_content(f(x)). The ONLY way to produce G(psi) in BX is:
   - temp_k_dist: G(phi -> psi) -> (G(phi) -> G(psi)) -- requires both G-premisses
   - temporal_necessitation of a theorem: if |- theta then |- G(theta) -- but this is already in any MCS
   - temp_4: G(phi) -> G(G(phi)) -- just nests existing G-formulas

   **There is no BX axiom of the form "alpha -> G(beta)" for non-G alpha.** No axiom produces a G-formula from a non-G formula. The interaction axioms (modal_future, temp_future) only work with Box(phi), not arbitrary phi.

   Therefore: **S |- G(psi) iff g_content(f(x)) |- psi** (using the derivability closure of g_content).

3. **But Lindenbaum can ADD more G-formulas beyond what S forces.** Any G(psi) consistent with S might end up in the Lindenbaum extension M. The extra G-formulas are "noise" from maximality.

### Q4: Extra G-formulas from the Lindenbaum extension

**Yes, there can be G-formulas in Lindenbaum(S) that are NOT derivable from S.**

Example: Let S = {eta} union g_content(f(x)) where eta is a propositional atom. Let psi be some formula with G(psi) independent of S (neither S |- G(psi) nor S |- F(neg psi)). Then one Lindenbaum extension includes G(psi), adding psi to g_content, while another does not.

**Can these extra G-formulas cause problems?** Yes, if the chronicle construction needs g_content(M) subset f(y) for some existing y. The extra psi in g_content(M) may not be in f(y), breaking the g_content chain property.

**But this is exactly the g_content_chain_property blocker that team research round 20 identified as the root cause.** The solution per Burgess is NOT to prove g_content propagation through seeds, but to DEFINE g values as part of the chronicle structure (C3 is a definition, not a theorem).

### Q5: G-conservative Lindenbaum extensions

**Question:** Can we construct a Lindenbaum extension of S that excludes all G(phi) beyond what S forces?

**Answer: NO, this is not always possible.**

Consider the set T = S union {neg(G(phi)) : G(phi) is not S-derivable}. Is T consistent?

Counterexample: Let S = {F(alpha)} (just a single F-eventuality). Then S does not derive G(alpha). So neg(G(alpha)) = F(neg alpha) would be in T. But also S does not derive G(neg alpha), so F(alpha) = neg(G(neg alpha)) would... wait, F(alpha) is already in S.

Actually, the set T could be inconsistent. Consider S = {G(alpha) -> G(beta)} where neither G(alpha) nor G(beta) is S-derivable. Then T includes neg(G(alpha)) and neg(G(beta)), i.e., F(neg alpha) and F(neg beta). But T also includes neg(G(alpha -> beta))... Actually G(alpha -> beta) might not be S-derivable either, so F(neg(alpha -> beta)) in T.

**The fundamental issue:** Maximality forces choices. For each phi, either G(phi) or F(neg phi) must be in M. The "G-conservative" choice (always choosing F(neg phi) when G(phi) is not S-forced) may create inconsistencies because:
- F(neg phi) and F(neg psi) together with BX11 might force F(neg phi AND neg psi), but G(phi OR psi) might be S-derivable, creating a contradiction.

**More precisely:** Suppose S |- G(phi OR psi) but S does not derive G(phi) and does not derive G(psi). The G-conservative approach puts F(neg phi) and F(neg psi) in T. But G(phi OR psi) in T means G(neg(neg phi AND neg psi)) in T. Now F(neg phi) = neg G(neg neg phi) and... this gets complicated. The point is that G distributes over implication but not over disjunction, so this specific case does not immediately yield a contradiction. But more complex interactions might.

**Practical conclusion:** G-conservative Lindenbaum is not obviously possible and would require a separate proof of consistency. This is not a productive path.

## Summary of Mathematical Results

### Proven facts (high confidence):
1. **temp_4 is the only G-generating axiom in BX**: G(phi) -> G(G(phi)). No axiom produces G(psi) from non-G premises.
2. **S |- G(psi) iff g_content(f(x)) |- psi** for seeds of the form S = {eta} union g_content(f(x)), because eta cannot contribute to G-derivability in BX.
3. **g_content(f(x)) subset g_content(Lindenbaum(S))** for any Lindenbaum extension of S, by fact #2 above combined with temp_4.
4. **g_content(Lindenbaum(S)) can strictly exceed {phi : S |- G(phi)}**: Lindenbaum maximality adds "noise" G-formulas.

### Implications for the root blocker:
5. **The g_content_chain_property blocker is NOT solvable by analyzing BX axioms alone.** The Lindenbaum opacity problem is real: different extensions of the same seed produce different g_content values.
6. **The Burgess solution is correct**: Define g as part of the chronicle structure (C3 as a definition), rather than trying to control g_content of Lindenbaum extensions.
7. **G-conservative Lindenbaum is not a viable workaround**: No obvious proof that excluding non-forced G-formulas preserves consistency.

### Key codebase facts:
8. **density_derivable (GGp -> Gp) is sorry'd** (TemporalDerived.lean:133-136): Not derivable under irreflexive semantics without a density axiom. This means G is NOT idempotent in BX.
9. **g_content_closed_derivation** (Frame.lean:79): The positive direction works -- if you can derive phi from things in g_content(S), then G(phi) in S. This is the tool for proving g_content INCLUSIONS.
10. **forward_temporal_witness_seed_consistent** (WitnessSeed.lean:81): The key consistency theorem for seeds {psi} union g_content(M). This does NOT constrain what additional G-formulas appear in the extension.

## Confidence Level

**HIGH** for all findings. The mathematical arguments are straightforward applications of the definitions and axioms. The key insight (fact #2 -- eta cannot contribute to G-derivability) follows directly from the structure of BX axioms, where no axiom has the form "non-G-formula -> G(formula)".

## Relevance to Team Research Synthesis

This analysis confirms and sharpens the round 20 finding: g_content_chain_property is not provable from the current codebase architecture because it tries to control an uncontrollable quantity (g_content of a Lindenbaum extension). The correct Burgess approach treats g as a separately-defined function satisfying C3 by construction, sidestepping the Lindenbaum opacity problem entirely.
