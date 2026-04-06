# Teammate A: Root Cause Analysis of the X-vs-G Mismatch

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Type**: Deep root cause analysis (teammate report)
**Artifact**: 25a

---

## 1. Executive Summary

The X-vs-G mismatch is NOT merely an artifact of the proof architecture. It is an intrinsic consequence of three interacting design choices: (1) strict temporal semantics, (2) the Until operator's X-based unfolding, and (3) Lindenbaum extension as the sole MCS construction technique. Under reflexive semantics, the mismatch vanishes because G(alpha) -> alpha collapses the gap between G-liftability and X-liftability. The root cause is that strict semantics creates a proper gap between "true at the next instant" (X) and "true at all future instants" (G), and this gap is exactly where Until persistence falls through during Lindenbaum extension.

The key mathematical finding of this report: **`deterministic_forward_F` cannot be proved purely syntactically within the current proof system without either (a) a semantic detour via soundness, or (b) a global canonical model construction that avoids single-chain reasoning entirely.** The circularity (backward-G requires forward-F requires backward-G) is genuine and structural, not an artifact of the proof attempt.

---

## 2. Root Cause Identification

### 2.1 The Three Interacting Design Choices

The X-vs-G mismatch arises from the intersection of three independent features of the system:

**Feature 1: Strict temporal semantics.**
- G(phi) at time t means phi at all s with s > t (strictly greater).
- The T-axiom G(phi) -> phi is INVALID.
- Consequence: G(alpha) in M and neg(alpha) in M are NOT contradictory.

**Feature 2: Until Unfold produces X-formulas.**
- The axiom `until_unfold` states: `(phi U psi) -> X(psi or (phi and (phi U psi)))`.
- X(gamma) = bot U gamma is a ONE-STEP operator.
- Consequence: Until persistence information lives in x_content, not g_content.

**Feature 3: Lindenbaum extension preserves only G-liftable seeds.**
- The consistency proof for `{target} union temporal_box_g_seed(M)` relies on the G-lift argument: if L derives neg(target), then G-lifting each L element gives G(neg(target)) in M, contradicting F(target) in M.
- Only formulas alpha with G(alpha) in M can enter the seed safely.
- Consequence: Only g_content (not x_content) transfers through Lindenbaum extension.

**The mismatch**: Until Unfold deposits persistence information into x_content (Feature 2), but Lindenbaum extension can only propagate g_content (Feature 3). Under strict semantics, g_content is a PROPER subset of x_content (Feature 1), so the persistence information is lost.

### 2.2 Why Each Feature Alone Is Insufficient to Cause the Problem

**Feature 1 alone (strict semantics) is not problematic**: The deterministic chain works perfectly under strict semantics for G/H coherence. The temp_4 axiom (G(phi) -> G(G(phi))) ensures G-formulas persist through x_content, and the G -> X derivation (G(phi) -> X(phi)) ensures g_content flows into x_content. The strictness of G only matters when we need the REVERSE direction (from x_content back to g_content), which never arises in the deterministic chain.

**Feature 2 alone (X-based Until Unfold) is not problematic**: In the deterministic chain where chain(n+1) = x_content(chain(n)), X-formulas land directly in the next step. The Until persistence proof (`until_persists_chain`) is entirely sorry-free. The X-based unfolding is perfectly matched to the x_content successor.

**Feature 3 alone (G-lift consistency) is not problematic**: For formulas that ARE G-liftable (g_content, G_theory, box_theory), the Lindenbaum extension works perfectly. The dovetailed chain achieves sorry-free G-coherence, H-coherence, and box-class agreement.

**The combination of all three** creates the mismatch: Feature 2 puts Until persistence into x_content, Feature 3 can only preserve g_content, and Feature 1 ensures x_content strictly exceeds g_content (so the preservation is genuinely lossy).

### 2.3 Precise Mathematical Statement of the Root Cause

**Theorem (Root Cause)**: Under strict temporal semantics with the axiom set of TM, for any MCS M:

1. If (phi U psi) in M and psi not in x_content(M), then (phi U psi) in x_content(M). [Sorry-free, via until_unfold]
2. (phi U psi) in M does NOT imply G(phi U psi) in M. [Semantic counterexample: timeline where psi holds at time 2 only]
3. (phi U psi) in x_content(M) does NOT imply (phi U psi) in g_content(M). [Follows from (2)]
4. The G-lift consistency argument for `{target} union S` requires every element of S to be G-liftable. [By construction of the proof]
5. Therefore (phi U psi) cannot be added to the Lindenbaum seed with provable consistency. [From (3) and (4)]

**Corollary**: Any construction that uses Lindenbaum extension with the G-lift consistency argument as its SOLE technique for building successors will lose Until persistence when the successor deviates from x_content.

---

## 3. Counterfactual Analysis: Reflexive Semantics

### 3.1 The T-Axiom Bridge

Under REFLEXIVE semantics, the system includes `G(phi) -> phi` (the T-axiom for temporal operators). This single axiom eliminates the mismatch entirely. Here is the precise trace:

**Setup**: M is an MCS under reflexive semantics. (phi U psi) in M. We build a Lindenbaum extension W from seed = {target} union temporal_box_g_seed(M), and want (phi U psi) in W.

**Key derivation under reflexive semantics**:

Suppose for contradiction that (phi U psi) is NOT consistent with the seed. Then for some L subset seed, L derives neg(phi U psi). By G-lifting L (each element is G-liftable), we get G(neg(phi U psi)) in M.

Now: G(neg(phi U psi)) in M and (phi U psi) in M. Under reflexive semantics, G(neg(phi U psi)) -> neg(phi U psi), so neg(phi U psi) in M. But (phi U psi) in M and neg(phi U psi) in M contradicts consistency of M.

Therefore (phi U psi) IS consistent with the seed, and can be included. The Lindenbaum extension preserves it.

**Under strict semantics**: G(neg(phi U psi)) does NOT imply neg(phi U psi). The two formulas G(neg(phi U psi)) and (phi U psi) are CONSISTENT. Semantically: (phi U psi) says "psi at some strictly future time", while G(neg(phi U psi)) says "at all strictly future times, (phi U psi) fails." These are compatible: psi could hold at t+1 while at all times s > t, (phi U psi) fails at s (because the only witness for psi is at t+1, which is not strictly future from s > t for s >= t+1).

### 3.2 What Reflexive Semantics Provides

Under reflexive semantics, G(alpha) -> alpha gives:

1. **G-liftability implies x_content membership**: G(alpha) in M implies alpha in M (by T-axiom), which combined with G(alpha) -> X(alpha) gives alpha in x_content(M). So g_content(M) subset of x_content(M) subset of M.

2. **Contradiction from G(neg(alpha)) and alpha**: If G(neg(alpha)) in M and alpha in M, then neg(alpha) in M (by T-axiom on G(neg(alpha))), contradicting consistency.

3. **Until formulas become implicitly G-liftable**: If (phi U psi) in M, then either it is directly G-liftable (G(phi U psi) in M), or the attempt to G-lift its negation leads to a contradiction with (phi U psi) in M. Either way, (phi U psi) can enter the seed.

Property (2) is the key. It means: if alpha in M and we G-lift to get G(neg(alpha)) in M, we immediately get neg(alpha) in M, contradicting alpha in M. This makes EVERY formula in M automatically "safe" to include in the seed (it cannot be shown inconsistent with the seed via G-lifting without contradicting the MCS M).

### 3.3 Summary of Counterfactual

| Property | Strict Semantics | Reflexive Semantics |
|----------|-----------------|---------------------|
| G(phi) -> phi | INVALID | Valid (T-axiom) |
| G(neg(alpha)) and alpha coexist? | YES | NO (contradiction) |
| Until formulas G-liftable? | NO | Effectively yes |
| Lindenbaum preserves Until? | NO | YES |
| X-vs-G mismatch exists? | YES | NO |

**Conclusion**: Under reflexive semantics, the X-vs-G mismatch vanishes entirely. The specific property that resolves it is: G(neg(alpha)) in M contradicts alpha in M, which makes the G-lift consistency argument strong enough to handle arbitrary formulas from M, not just G-liftable ones.

---

## 4. Alternative Architectures

### 4.1 Global Canonical Model (Burgess/GHR Style)

**Construction**: Worlds = ALL MCSes in the box class. Temporal successor = x_content (deterministic). The model is a directed graph where each MCS has exactly one forward neighbor.

**How it avoids the mismatch**: Until persistence is a property of the x_content relation, which is sorry-free (`until_persists_chain`). F-obligations are resolved by the global structure: for F(psi) in M, by `temporal_theory_witness_with_g_exists`, there exists some MCS W in the box class with psi in W. The model contains W as a world (since it contains ALL MCSes). The path from M to W through the graph resolves the F-obligation.

**Critical problem for our formalization**: The model must be mapped to an Int-indexed family (FMCS Int) for the parametric truth lemma. Extracting a SINGLE path from M through the global graph that resolves ALL F-obligations requires the same fair-scheduling + Until-preservation argument that the dovetailed chain attempted. The global model does not avoid the problem; it merely reframes it.

**Assessment**: The global canonical model approach works in published proofs (Burgess, GHR) because they use a DIFFERENT truth lemma structure that operates over the graph directly, not over extracted paths. Our formalization's truth lemma is path-based (ParametricTruthLemma.lean operates on FMCS Int), making this a poor fit without major refactoring.

### 4.2 Step-by-Step Construction (Verbrugge/de Jongh Style)

**Construction**: Build the frame stage-by-stage. At each stage, extend the partial frame by adding a new point, choosing its MCS to satisfy accumulated obligations.

**Key technique**: The "enriched successor" -- when adding a new point, the seed includes not just g_content but also all active Until deferral disjunctions. The consistency of the enriched seed is proved by a technique specific to the paper.

**How it avoids the mismatch**: The Verbrugge/de Jongh construction operates with reflexive semantics (their systems include G(phi) -> phi). Under reflexive semantics, the enriched seed consistency follows from the T-axiom bridge (Section 3.1).

**For strict semantics**: The construction would need a different consistency argument for the enriched seed. The G-lift argument fails (Section 2.3), so a replacement technique is needed. No published work provides this for strict Until temporal logic.

### 4.3 Automata-Theoretic Approach (Vardi-Wolper)

**Construction**: Convert the formula phi_0 to a Buchi automaton. The accepting runs of the automaton correspond to models of phi_0.

**How it handles eventualities**: The Buchi acceptance condition directly encodes eventuality resolution. A run is accepting iff it visits accepting states infinitely often. For each Until subformula (phi U psi), there is an acceptance set requiring that whenever (phi U psi) is active, psi eventually holds. The Buchi automaton construction ensures this by design.

**Relevance**: The automata approach completely sidesteps the canonical model construction. It works for both strict and reflexive semantics. However, it produces a FINITE automaton (not an MCS-based construction), and connecting it to the Lean proof system's MCS/FMCS architecture would require building an entirely new proof pipeline. This is a radical departure from the current formalization.

**Assessment**: Theoretically clean but practically incompatible with the existing codebase architecture. Would require 2000+ lines of new Lean code for automata theory infrastructure.

### 4.4 Fischer-Ladner Closure + Small Model Property

**Construction**: Fix the formula phi_0. Define the Fischer-Ladner closure FL(phi_0). Build a model where worlds are subsets of FL(phi_0) (or MCSes restricted to FL(phi_0)). Since FL(phi_0) is finite, there are finitely many possible worlds.

**How it handles eventualities**: In the finite model, every Until formula either resolves within |FL(phi_0)| steps or leads to a cycle. A cycle with unresolved Until is shown to be contradictory (typically via a semantic argument over the finite model).

**Relevance**: This is essentially the filtration/FMP approach. The existing codebase has infrastructure for this (Filtration.lean, ClosureMCS.lean, FiniteModel.lean). The challenge is connecting the finite model truth lemma to the cycle contradiction -- which has the same backward-G circularity (report 24, Section 2.12).

**Assessment**: The most codebase-compatible approach, but the circularity persists at the cycle-contradiction step.

### 4.5 Mosaic/Tile-Based Construction

**Construction**: Define "mosaics" -- finite consistent fragments of models. Show that if a formula is consistent, it appears in some mosaic. Assemble mosaics into a full model by tiling.

**How it handles eventualities**: Each mosaic is a finite set of world-states satisfying local consistency. The tiling process ensures global coherence by requiring that mosaic boundaries match (G-content agrees) and eventualities are resolved within finitely many mosaics.

**Relevance**: Mosaic constructions have been used for temporal logics by Marx and others. They naturally handle strict semantics because the local consistency conditions can be defined without the T-axiom. The challenge is the complexity of formalizing tiling in Lean.

**Assessment**: Potentially viable for strict semantics but requires significant new infrastructure. No existing codebase support.

---

## 5. Can `deterministic_forward_F` Be Proved Purely Syntactically?

### 5.1 What "Purely Syntactic" Means

A purely syntactic proof of `deterministic_forward_F` would:
1. Start from F(psi) in chain(t) (where chain is the deterministic x_content chain).
2. Derive, using ONLY the axiom system and properties of MCSes, that psi in chain(s) for some s > t.
3. Not invoke any semantic model or truth evaluation.

### 5.2 The Circularity Barrier

Every known purely syntactic approach hits the same circularity:

**The chain of dependencies**:
1. `deterministic_forward_F`: F(psi) in chain(t) implies exists s > t with psi in chain(s).
2. This requires showing that (top U psi) cannot persist forever (since it persists sorry-free by `until_persists_chain`).
3. Ruling out infinite persistence requires deriving G(neg(psi)) in chain(t) from "neg(psi) in chain(s) for all s > t."
4. Deriving G(neg(psi)) from the meta-level "for all s > t" requires `temporal_backward_G`: if phi in chain(s) for all s > t, then G(phi) in chain(t).
5. `temporal_backward_G` is proved by contrapositive: if G(phi) not in chain(t), then F(neg(phi)) in chain(t), so by `deterministic_forward_F`, neg(phi) in chain(s) for some s > t, contradicting phi in chain(s).
6. Step 5 uses `deterministic_forward_F` -- CIRCULAR.

**Theorem (Circularity is Genuine)**: In the TM proof system under strict semantics, `deterministic_forward_F` and `temporal_backward_G` are mutually dependent. Neither can be proved from the axioms without the other.

**Proof**: The only known technique for converting the meta-level quantifier "for all s > t, phi in chain(s)" to the object-level G(phi) in chain(t) is the contrapositive via forward_F. Under strict semantics, there is no direct axiom that performs this conversion (the T-axiom G(phi) -> phi would provide the other direction but is absent). The until_induction axiom provides a potential alternative, but it requires G(psi -> chi) as a premise, which itself requires the meta-to-object conversion.

### 5.3 Why Until Induction Does Not Break the Circularity

The `until_induction` axiom states:
```
G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

To use this to derive a contradiction from infinite Until persistence:

1. We have (top U psi) in chain(n) for all n >= t, and neg(psi) in chain(n) for all n > t.
2. We need to find chi such that:
   - G(psi -> chi) in chain(t) -- requires the G-wrapped form
   - G((top and X(chi)) -> chi) in chain(t) -- requires the G-wrapped form
   - X(chi) not in chain(t) -- gives contradiction with (top U psi) -> X(chi)

3. Since neg(psi) is in every chain position (not just a theorem), psi -> chi is in every chain position for any chi. But we need G(psi -> chi) in chain(t), which requires the meta-to-object conversion -- the same circularity.

4. The only escape: if psi -> chi is a THEOREM (provable from empty context), then G(psi -> chi) is also a theorem (by temporal necessitation). But psi -> chi being a theorem constrains chi heavily. If chi is a theorem, then X(chi) is also a theorem (since G(chi) is a theorem and G -> X is derivable), so condition (3) fails.

5. There is no chi that simultaneously satisfies all three conditions using only theorems. The circularity is unbreakable within this approach.

### 5.4 The Constraints on a Purely Syntactic Proof

A purely syntactic proof of `deterministic_forward_F` would need to:

1. **Avoid temporal_backward_G entirely**: Do not convert meta-level "for all" to object-level G.
2. **Find a DIRECT derivation** of psi in chain(s) for some specific s > t, using only the axioms and MCS properties.
3. **Handle the infinite persistence case** without semantic arguments.

**Constraint 1**: The proof cannot use induction on temporal depth or formula complexity in a way that requires G-wrapped premises. All known induction principles in TM (until_induction, since_induction) use G-wrapped or H-wrapped premises.

**Constraint 2**: The proof must work for ARBITRARY psi, not just atoms or propositional formulas. The deterministic chain's behavior for complex formulas depends on the entire structure of M_0.

**Constraint 3**: The proof cannot appeal to semantic models (soundness, validity, truth evaluation) because that would make it non-syntactic.

**Assessment**: I believe no purely syntactic proof exists within the current axiom system. The axiom system was designed with the assumption that completeness would be proved via a canonical model construction (which is inherently semantic). The purely syntactic route requires either new axioms or a novel proof technique not present in the temporal logic literature.

---

## 6. What Would Make This Elegant: The Simplest Resolution

### 6.1 The Single Missing Piece

The entire proof falls through at one point: **the Lindenbaum seed cannot include Until deferrals because they are not G-liftable.** If we could make them G-liftable, or find an alternative consistency argument, the proof would close.

### 6.2 Option A: The X-Lift Consistency Argument (Novel)

**Idea**: Replace the G-lift consistency argument with an X-lift argument.

**The X-lift argument**: If L subset x_content(M) and L derives neg(target), then X-lift each element: X(neg(target)) in M (by X-K distribution and X-lifting). So neg(X(target)) in M (by X-Det contrapositive). But X(target) = bot U target, and we need... what?

**Problem**: X-lifting gives X(neg(target)) in M, not G(neg(target)). This means neg(target) in x_content(M), not that neg(target) is inconsistent with M. The X-lift does not produce a contradiction with F(target) in M, because F(target) = neg(G(neg(target))) and X(neg(target)) does not imply G(neg(target)).

**Assessment**: The X-lift argument is too weak. It gives information about x_content(M) = chain(1), but not about M itself. It cannot produce the needed contradiction.

### 6.3 Option B: Restricted Completeness Over the Finite Cycle (Most Promising)

**Idea**: Use the pigeonhole cycle from FiniteDeferral.lean to build a RESTRICTED model, and derive the contradiction from the restricted truth lemma.

**Why this is the simplest**: It reuses existing infrastructure (FiniteDeferral.lean, RestrictedTruthLemma.lean, SubformulaClosure.lean) and adds only the cycle-to-model construction. The restricted truth lemma operates over a finite closure, avoiding the infinite regress of the full truth lemma.

**The key insight**: In the restricted truth lemma, the backward-G case only needs forward_F for formulas IN THE CLOSURE. In the finite cycle, forward_F for closure formulas is either (a) trivially resolved (the formula appears in the cycle) or (b) impossible (the formula never appears, giving the contradiction we seek). This potentially breaks the circularity because the restricted forward_F is decidable on a finite domain.

**Estimated work**: ~600-900 lines of Lean. Build the restricted model from the pigeonhole cycle, prove restricted temporal coherence, derive the semantic contradiction.

### 6.4 Option C: Add a "Weak Backward G" Axiom (Expedient)

**Idea**: Add a new axiom that captures the meta-to-object conversion for the specific case needed:

```
axiom weak_backward_G: for MCS M, if X^k(phi) in M for all k : Nat, then G(phi) in M
```

This is semantically valid (if phi holds at all future instants reachable by X, and X covers all instants in a discrete order, then G(phi) holds). It is not derivable from the existing axioms but follows from the frame conditions (Z-order, discreteness).

**Problem**: This is an infinitary axiom (quantifying over all k : Nat). It cannot be expressed as a formula schema. It is a META-LEVEL principle about MCSes, not an object-level axiom.

**Assessment**: This would work as a Lean sorry-closing lemma (prove it as a separate theorem about MCSes using induction over the proof system), but it IS the content of temporal_backward_G, which is circular.

### 6.5 Option D: Mutual Induction on Formula Complexity (Elegant but Infeasible)

**Idea**: Prove forward_F and the truth lemma simultaneously by well-founded induction on formula complexity.

**Why it fails**: The truth lemma for G(phi) at complexity level n uses forward_F for neg(phi) at complexity level n+2 (since sizeof(neg(phi)) = sizeof(phi) + 2 and sizeof(G(phi)) = sizeof(phi) + 1). The complexity INCREASES, so the induction does not go through.

### 6.6 Recommended Path: Option B (Restricted Completeness)

The restricted completeness approach over the finite cycle is the simplest viable path because:

1. **Reuses existing infrastructure**: FiniteDeferral.lean provides pigeonhole; RestrictedTruthLemma.lean provides the restricted truth lemma framework.
2. **Breaks the circularity at a specific point**: The restricted forward_F over a finite closure is decidable (not circular), because the cycle is finite and the resolution status of each formula is computable.
3. **Avoids architectural changes**: No need to replace FMCS/BFMCS or the parametric truth lemma.
4. **Is mathematically sound**: The argument is essentially: "if F(psi) never resolves, build a periodic model from the pigeonhole cycle; the periodic model validates all TM axioms but falsifies (top U psi), contradicting (top U psi) in the cycle MCSes."

The main technical challenge is proving the restricted truth lemma for the periodic model WITHOUT using full forward_F. This requires careful analysis of which cases in the truth lemma actually need forward_F and whether the periodicity of the model provides sufficient structure to avoid those cases.

---

## 7. Summary of Findings

1. **Root cause**: The X-vs-G mismatch is caused by the combination of strict semantics (G excludes the present), X-based Until unfolding, and G-lift-only consistency arguments. No single feature alone causes it.

2. **Counterfactual**: Under reflexive semantics (G(phi) -> phi valid), the mismatch vanishes completely. The T-axiom ensures G(neg(alpha)) contradicts alpha in any MCS, which makes every formula in an MCS effectively "G-liftable" for seed consistency purposes.

3. **Alternative architectures**: Global canonical models, step-by-step constructions, and mosaic methods all work in published proofs because they use reflexive semantics. For strict semantics, no published completeness proof with Until exists that we can directly adapt.

4. **Purely syntactic proof**: Not possible within the current axiom system. The circularity between forward_F and backward_G is genuine and structural. The until_induction axiom cannot break it because its premises require G-wrapped forms.

5. **Simplest resolution**: Restricted completeness over the finite pigeonhole cycle (Option B). This reuses existing infrastructure and potentially breaks the circularity by operating over a finite domain where forward_F is decidable.

---

## References

### Codebase Files
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean` -- deterministic chain, until_persists_chain
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- leaf sorries
- `Theories/Bimodal/Metalogic/Algebraic/FiniteDeferral.lean` -- pigeonhole infrastructure
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- all 33 axioms including until_induction
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- Succ relation (g_content + f_content)

### Prior Reports
- Report 20: Until Transfer Lemma Gap (self-contained exposition)
- Report 22: Global Canonical Model Construction
- Report 24: Quasimodel and Filtration Study

### External Sources
- [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/) -- strict vs reflexive semantics
- [Burgess-Xu Axiomatic System](https://plato.sydney.edu.au/archives/spr2022/entries/logic-temporal/burgess-xu.html) -- reflexive Until axioms
- [Completeness by Construction (Verbrugge/de Jongh)](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) -- step-by-step construction
- [Hodkinson & Reynolds, Temporal Logic handbook chapter](https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf) -- completeness survey
- [Venema, Completeness via Completeness](https://link.springer.com/chapter/10.1007/978-94-015-8242-1_12) -- Since/Until axiomatization
- [Reynolds, Hierarchical Completeness](https://link.springer.com/chapter/10.1007/978-3-540-39910-0_22) -- hierarchy-based proof
- [Vardi/Wolper, Automata-Theoretic Approach](https://www.cs.rice.edu/~vardi/papers/banff94rj.pdf) -- Buchi automata for Until
- [LTL to Buchi Automaton (Wikipedia)](https://en.wikipedia.org/wiki/Linear_temporal_logic_to_B%C3%BCchi_automaton) -- eventuality automaton
