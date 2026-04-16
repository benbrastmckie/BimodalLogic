# Teammate D Findings: Horizons and Strategic Analysis for Task 93

**Task**: 93 - Complete BXCanonical embedding
**Role**: Horizons / Strategic researcher (Teammate D)
**Date**: 2026-04-16
**Artifact**: 29

## Key Findings

### 1. Literature Deep Dive: How Standard Proofs Handle Forward_F

**Confidence**: HIGH (based on established literature, though PDF extraction was limited)

The standard approach to proving completeness for temporal logics with Until/Since (and hence F/P) uses a construction fundamentally different from the one attempted in this project. The literature converges on three families of technique:

**Family A: Henkin-style step-by-step construction (Burgess 1982, Xu 1988, Venema 1993)**

Burgess's 1982 completeness proof for Since-Until tense logic over reflexive linear orderings builds the canonical model by a step-by-step extension of maximal consistent sets. The critical mechanism for eventuality fulfillment is:

1. Start with an MCS w0 containing F(psi).
2. At each step, choose a SINGLE pending eventuality (F or Until obligation) to resolve.
3. Build the successor MCS by including the witness formula in the seed, along with the G-content (universal future obligations).
4. The key insight: Burgess does NOT attempt to preserve ALL F-obligations simultaneously. Instead, F-obligations are re-derivable from the logic's own axioms. Specifically, if F(psi) is in w and G(phi) is in w, then F(psi) is in the successor (because G(phi) -> phi propagates forward, but F(psi) was derived from axioms that remain valid in the successor).

However, Burgess's proof operates over ARBITRARY reflexive linear orderings, not specifically over the integers. The bidirectional (Since + Until) case requires constructing BOTH forward and backward chains simultaneously, which Burgess handles by a careful interleaving argument.

**Family B: Quasimodel / Hintikka set approach (Gabbay, Hodkinson, Reynolds 1994)**

GHR 1994 uses a different strategy: build a "quasimodel" (a Hintikka structure) first, then extract a genuine model. The quasimodel handles eventualities by a defect-discharge mechanism -- precisely the approach already implemented sorry-free in this project's Quasimodel/ directory. GHR's technique:

1. Define a finite subformula closure (sigma-closure).
2. Build Hintikka points that are locally consistent within the closure.
3. Chain Hintikka points such that each "Until defect" (a formula phi U psi held at a point without psi) is resolved within finitely many steps.
4. The defect count strictly decreases at each step (well-founded on the finite closure).
5. Linearize the resulting quasimodel tree into a genuine model.

This is EXACTLY what the Quasimodel/ infrastructure does for Until/Since. The forward_F problem is a simpler variant (F(psi) = top U psi), but the existing infrastructure was not designed to handle the F case directly.

**Family C: Focus game / automata-theoretic (Lange and Stirling 2001)**

Lange and Stirling developed "focus games" for LTL satisfiability and completeness. The key idea: instead of building a canonical model and then proving properties about it, they define a two-player game where the existential player builds a model satisfying the formula, and the universal player challenges eventualities. Complete axiomatizations for LTL, CTL, and PDL can be extracted from the game rules. Completeness follows from winning strategy existence for consistent formulas. This entirely avoids the "chain construction" problem because model construction is implicit in the game tree.

### 2. The Core Mathematical Question: Does a Third Step Function Exist?

**Confidence**: MEDIUM-HIGH

The project has identified two step functions:
- `fwd_succ(M, target)`: resolves target, may kill F(other)
- `enriched_fwd_step(M)`: preserves all F-obligations, may not resolve target (BX11 hijacking)

**Answer: The literature suggests the right approach is NOT a third step function, but a different proof architecture entirely.**

The standard approach (Burgess, GHR, Goldblatt) does not try to build ONE chain that simultaneously resolves all eventualities and preserves all F-obligations. Instead, they use one of:

(a) **Per-formula chains with an outer induction**: For each F(psi), build a separate chain that resolves psi. The outer argument (typically induction on formula complexity or well-founded induction on defect count) shows that all eventualities are eventually resolved. The chains are then merged into a single model by a separate argument.

(b) **Quasimodel-then-linearize**: Build the quasimodel (which resolves each defect independently), then show the quasimodel can be linearized into a model over the integers.

(c) **Semantic argument with truth lemma**: Prove the truth lemma first (by formula induction), and then derive forward_F as a CONSEQUENCE of the truth lemma rather than as a PREREQUISITE. This is what Goldblatt does: the truth lemma for F is proved by showing that if F(psi) is in an MCS w, then psi is in some MCS v with bx_le(w, v), and the truth lemma at v gives semantic satisfaction.

**Critical observation for this project**: The truth lemma (TruthLemma.lean) is already sorry-free. The problem is that `dd_countermodel` needs forward_F as a PROPERTY OF THE CHAIN (an Int-indexed family), not just as a PROPERTY OF THE CANONICAL FRAME. The gap is between "there exists some MCS v >= w with psi in v" (which bx_forward_witness gives for free) and "there exists a chain index s > t with psi in chain(s)" (which requires the chain to actually visit that MCS v).

### 3. What Do Published Formalizations Do?

**Confidence**: HIGH

**Doczkal and Smolka (2014, Coq)**: Proved completeness and decidability for CTL in Coq/Ssreflect. Their approach is tableau-based, dual to Brunnler and Lange's cut-free sequent calculus. They handle eventualities (EU/AU formulas) via a "fulfillment relation" combined with history-augmented tableaux. The construction obtains tree-shaped fragments using a "top-down" induction on the fulfillment relation. This avoids the chain construction problem entirely -- they never build a linear chain. Instead, they build branching tree models and extract finite witnesses. Their Coq formalization is available at github.com/coq-community/comp-dec-modal.

**From (2025, Isabelle/HOL, CPP)**: Asta Halkjaer From's framework for synthetic completeness proofs mechanizes an abstract transfinite Lindenbaum's lemma and builds witnessed MCSs for any logic satisfying abstract requirements. The framework separates the truth lemma into semantic and syntactic components. Applied to modal and hybrid logics, but NOT to temporal logic with Until/Since. The framework's abstract approach suggests that forward_F could potentially be handled by an appropriate instantiation of the abstract MCS witness construction, but this has not been done.

**LeanearTemporalLogic (Lean 4, WIP)**: A work-in-progress Lean 4 formalization of LTL syntax and semantics. Does NOT include completeness proofs or canonical models. Not relevant to the forward_F problem.

**FormalizedFormalLogic/Foundation (Lean 4)**: Formalizes propositional, first-order, and modal logics including completeness theorems. Does NOT include temporal logic with Until/Since.

**Key finding**: No published formalization has proved completeness for linear temporal logic with BOTH Until and Since operators (the bidirectional case). The closest is Doczkal's CTL formalization, which handles a branching-time logic. This project's formalization would be the FIRST to formalize completeness for bidirectional linear temporal logic with Since and Until, making it publishable even with the forward_F sorry -- as a partial result with a well-documented open problem.

### 4. Strategic Assessment

**Confidence**: HIGH

**After 28 rounds, is "close all sorries" achievable?**

Probability assessment:
- DRM chain approach (Path D from Report 28): **45-55%** success probability. The mathematical argument is sound in principle (bounded F-nesting in DRMs enables single_step_forcing), but the DRM-to-full-MCS lift has unexplored obstacles. The `DRMChain.lean` file (286 lines, 1 sorry) is already in place, suggesting this was identified as viable.
- Quasimodel bridge (Path B): **35-45%** success probability. Sound but costly (600-1000 LOC). The bx_le non-totality issue for Until guard conditions is a genuine risk.
- Total probability of eventually closing forward_F via SOME path: **60-70%** (given these are partially overlapping paths).

**Is the DRM approach (Plan 28) realistic?**

The DRM approach has the strongest mathematical foundation among all explored paths. The key theorem `drm_fwd_chain_forward_F` at DRMChain.lean:273 has a clear proof sketch: DRM restricts F-nesting to `closure_F_bound`, so `single_step_forcing` applies (its precondition "iter_F(d+1, psi) NOT in state" is satisfied in the DRM). The sorry at line 284 is the gap. The main risks are:
1. The DRM chain's `Succ` relation needs formal verification.
2. Lifting from DRM to full MCS chains requires modal coherence.
3. The DRM-BFMCS wiring has not been attempted.

**Should the project pivot?**

No. The project has 5,669 lines of sorry-free infrastructure across 16 files, with a novel quasimodel/defect-discharge construction that is a genuine contribution. Two viable paths remain (DRM, quasimodel bridge). A pivot would abandon significant proven infrastructure.

**Publication strategy**: The project is publishable NOW as a partial result:
- Complete soundness (sorry-free)
- Novel quasimodel/defect-discharge formalization for Until/Since (2,289 lines, sorry-free)
- Full truth lemma (sorry-free)
- Canonical frame construction (sorry-free)
- Well-documented forward_F obstruction with 26 dead ends catalogued
- Venues: ITP, CPP, or LICS workshop. The forward_F problem could be presented as an open formalization challenge.

### 5. Novel Mathematical Ideas

**Confidence**: MEDIUM (speculative, but grounded in literature)

**Idea A: Game-theoretic completeness proof**

Lange and Stirling's focus game approach could bypass the chain construction entirely. Instead of building an Int-indexed family and proving forward_F as a chain property, define a two-player satisfiability game where:
- The existential player builds model states incrementally
- The universal player challenges eventualities by picking F-formulas to resolve
- Winning strategies correspond to satisfying models
- Completeness = every consistent formula has a winning strategy

The game-theoretic approach handles eventualities NATURALLY through the game's winning condition (the universal player loses if an eventuality is never resolved). The BX11 hijacking problem vanishes because the existential player CHOOSES which formula to resolve (not the BX11 fold ordering).

**Formalizability risk**: HIGH. This would require a completely new proof architecture, abandoning most existing infrastructure. Estimated 3000+ new LOC.

**Idea B: Automata-theoretic / Buchi approach**

Vardi's automata-theoretic approach (1994) translates LTL formulas to Buchi automata and uses nonemptiness for satisfiability. For completeness, the reverse direction gives: if a formula has no proof of negation, then the corresponding Buchi automaton is nonempty, hence the formula is satisfiable. Buchi automata handle eventualities via their acceptance condition (infinitely many visits to accepting states).

**Formalizability risk**: VERY HIGH. Buchi automata formalization in Lean 4 would be a massive undertaking, and the connection to the BX axiom system would need to be established from scratch.

**Idea C: Exploit the integer structure**

The temporal domain is the integers Z, which has special properties not shared by arbitrary linear orders:
- Every element has an IMMEDIATE successor and predecessor (discreteness)
- Z is order-isomorphic to Z (homogeneity)
- Z has no endpoints

Under STRICT semantics, these properties would enable a next-step operator X with F(phi) equivalent to "there exists n >= 1 such that X^n(phi)". But the project uses REFLEXIVE semantics where X(phi) = phi (dead code, as documented in ROAD_MAP). So the integer structure provides no additional leverage under the current semantics.

However, one unexploited property: Z is a GROUP under addition. The canonical frame could be constructed as a torsor for (Z, +), with each MCS assigned to an integer and the temporal ordering given by the natural ordering on Z. The group structure might simplify the backward-chain construction (just translate the forward chain by -1).

**Formalizability risk**: MEDIUM. The group structure does not directly address forward_F, but the homogeneity might simplify the DRM chain construction.

**Idea D: Topological / Stone duality perspective**

The canonical frame is the Stone space of the Lindenbaum-Tarski algebra. The MCSs are ultrafilters. The temporal ordering induces a continuous map on the Stone space. Forward_F asks whether this map has a "reachability" property. In the Stone topology, this might be expressible as a compactness argument: "F(psi) belongs to the ultrafilter w" means "the set of MCSs containing psi is in every neighborhood of w's future cone". If the future cone is compact, some MCS in the cone contains psi.

**Formalizability risk**: VERY HIGH. Stone duality for temporal algebras is a research-level topic, and connecting it to the BX axiom system would require substantial new theory.

**Idea E (MOST PROMISING NOVEL IDEA): Semantic forward_F from bx_forward_witness**

The sorry-free `bx_forward_witness` (Frame.lean:164) already proves: if F(psi) in w, there exists v with bx_le(w, v) and psi in v. This is the SEMANTIC forward_F -- it works at the level of BXPoints, not chain indices.

The gap is converting this to CHAIN forward_F. But what if the chain were DEFINED to visit bx_forward_witness outputs?

Construction:
```
chain(0) = M0
For chain(n), enumerate all F-defects: {psi | F(psi) in chain(n), psi not in chain(n)}.
For each defect psi, let v_psi = bx_forward_witness(chain(n), psi).
Set chain(n+1) = v_{psi_n} where psi_n is the round-robin selected defect.
```

This chain has bx_le(chain(n), chain(n+1)) at resolving steps, giving forward_G for free. The question is whether forward_F holds.

At chain(n)'s visit step for psi: chain(n+1) = bx_forward_witness(chain(n), psi), so psi in chain(n+1) -- IF F(psi) is still in chain(n). The persistence question: does F(psi) survive from the step where it was first seen to psi's visit step?

This faces the SAME F-persistence problem as all linear chain approaches. But there is a key difference: bx_forward_witness gives bx_le(chain(n), chain(n+1)), which means g_content(chain(n)) subset chain(n+1). If G(neg(psi)) is NOT in chain(n), then neg(psi) is NOT forced into chain(n+1), leaving room for F(psi) to survive.

The argument would need: if F(psi) is in chain(n) and psi is never resolved, then eventually G(neg(psi)) must enter the chain (by the contrapositive of forward_F applied to neg(psi) via backward_G). But this is again the CIRCULARITY (Path F from Report 28).

The circularity might be breakable by a SIMULTANEOUS INDUCTION on the number of unresolved depth-0 defects + the formula depth. This is unexplored territory and warrants pen-and-paper investigation.

## Recommended Approach

**Primary**: Continue with the DRM chain approach (DRMChain.lean, 1 sorry remaining). This has the strongest mathematical foundation and uses existing infrastructure.

**Secondary**: If DRM fails, attempt the quasimodel bridge (Path B from Report 28), using the sorry-free Quasimodel infrastructure to build Int-indexed families directly.

**Parallel**: Prepare a partial-result publication targeting ITP or CPP. The forward_F obstruction is a genuine formalization challenge that the community would benefit from seeing.

**Long-term**: Investigate the game-theoretic approach (Idea A) as a fundamentally different proof architecture that avoids the chain construction problem entirely.

## Evidence/Examples

- `bx_forward_witness` (Frame.lean:164-171): Sorry-free semantic forward_F at BXPoint level
- `DRMChain.lean` (286 lines, 1 sorry at line 284): DRM chain construction with forward_F as the sole gap
- `single_step_forcing` (SuccRelation.lean:232): The key lemma that DRM forward_F would invoke
- Doczkal/Smolka CTL in Coq: Published formalization using tableau + fulfillment, avoiding linear chains
- Lange/Stirling focus games: Published game-theoretic alternative to canonical model completeness
- From CPP 2025 synthetic completeness: Framework for abstract MCS construction, potentially extensible

## Confidence Level

- Literature findings: **HIGH** (well-established results, multiple independent sources)
- DRM approach viability: **MEDIUM-HIGH** (sound mathematics, 1 sorry remaining, clear proof sketch)
- Publication readiness: **HIGH** (substantial sorry-free infrastructure, novel contributions)
- Game-theoretic alternative: **MEDIUM** (theoretically sound, massive implementation cost)
- Probability of eventually closing all sorries: **60-70%** across all viable paths
