# Teammate B Findings: Bilateral Pairs — Literature and Alternatives

**Task**: 93 - Complete BXCanonical embedding (forward_F sorry)
**Role**: Literature review and alternative approaches analysis
**Date**: 2026-04-14
**Round**: 19

## Key Findings

### Finding 1: No Published Bilateral Pairs Approach for Tense Logic
Literature search reveals **no published completeness proof for classical tense logic (with G/F/H/P operators) that uses bilateral pairs ⟨V, F⟩** as the primary completion mechanism. The bilateral semantics literature (Rumfitt, Restall, Wansing) operates at the proof-theoretic level (assertion/denial, signed formulas), not the model-theoretic level (sets of formulas forming world surrogates). Bilateral pairs are philosophically motivated and used for propositional connectives; extensions to G/H/F/P operators have not been developed.

### Finding 2: The Bilateral Pairs Idea Reduces to Standard MCS
The proposed bilateral pair ⟨V, F⟩ with:
- Consistency of V
- φ ∈ F iff ¬φ ∈ V
- MP closure of V
- Implication closure

...is equivalent to a maximal consistent set. If V is consistent, MP-closed, implication-closed, and satisfies φ ∈ F iff ¬φ ∈ V, then V is in fact a maximally consistent set (by classical bivalence: since ¬φ ∈ V iff φ ∉ V for all φ when V is Lindenbaum-saturated). The "negation closure" condition (φ ∈ F iff ¬φ ∈ V) combined with consistency and maximal closure is equivalent to `SetMaximalConsistent` in the current code. **The bilateral pairs approach does not escape Lindenbaum's lemma** — it *is* Lindenbaum's lemma under another name.

### Finding 3: The Extension Question
The key proposed advantage is that "any consistent set can be extended to a balanced pair." This is correct — it is just Lindenbaum's Lemma (Zorn's Lemma applied to consistent extensions). The balance condition (φ ∈ F iff ¬φ ∈ V) holds automatically in any MCS by classical logic. The bilateral framing adds no constraint beyond what MCS already provide. The Lindenbaum choice remains **unconstrained** in bilateral pairs just as in MCS.

### Finding 4: The Semantic-Syntactic Gap Persists Under Bilateral Pairs
The bilateral pair approach does not address the root problem: **the unconstrained Lindenbaum choice at each chain step**. Whether we call each chain point an MCS or a bilateral pair ⟨V, F⟩, the construction still requires:
- At each forward step, extending `{ψ} ∪ g_content(M)` to a maximal consistent set
- The choice is unconstrained — the extension may select `F(ψ) ∈ M'` over `ψ ∈ M'`

The bilateral framing provides no handle on this choice.

### Finding 5: Belnap-Dunn / Four-Valued Semantics
Belnap-Dunn four-valued modal logics (Odintsov-Wansing, Jansana, and others) use **two accessibility relations** R⁺ and R⁻ (for truth support and falsity support respectively). This is the natural bilateral extension to modal operators. For temporal operators:
- □φ is supported-true at w iff all R⁺-successors support φ as true
- □φ is supported-false at w iff some R⁻-successor supports φ as false

This approach yields **completeness theorems** (with soundness proved via the dual semantics). However:
- It applies to paraconsistent/four-valued semantics, not classical tense logic
- The BX system is classical (uses excluded middle via Peirce's law `peirce`)
- Adopting four-valued semantics would require a fundamental redesign of the semantics layer

### Finding 6: Quasimodel Approach with Characteristic Formulas χ⁺(w) and χ⁻(w)
The quasimodel literature (Gödel temporal logic, Gabbay-Hodkinson-Reynolds style) uses **two characteristic formulas per world**: χ⁺(w) characterizing positive information and χ⁻(w) characterizing negative information. This is a bilateral flavor but operates differently:
- χ⁺(w) and χ⁻(w) are FORMULAS encoding a world's positive/negative content
- They support unwinding procedures (quasimodel → bi-relational model → linear model)
- The eventuality problem is handled via the **finite quasimodel property**: if a formula is satisfiable, it is satisfiable in a finite quasimodel where eventuality discharge can be checked exhaustively

This approach IS the quasimodel strategy already explored in the ProofChecker codebase (Quasimodel/ directory). It does not introduce bilateral pairs at the chain construction level.

## Alternative Approaches Compared

### Bilateral Pairs vs. Ordered-Discharge Chain (Plan v18 / Teammate D)

| Dimension | Bilateral Pairs | Ordered-Discharge Chain |
|-----------|-----------------|------------------------|
| Core insight | Dual truth/falsity semantics | Control Lindenbaum choice via discharge ordering |
| Gap addressed | None (reduces to MCS) | Direct: never-resolved count termination |
| Lean cost | High (semantics redesign) | Medium (30 theorem re-proofs) |
| Confidence | 5% | 55-65% (Teammate D) |
| New infrastructure needed | Extensive | Moderate |
| Reuses existing proofs | No | Yes (6400+ lines preserved) |

The ordered-discharge chain is strictly superior. Bilateral pairs do not attack the root cause.

### Bilateral Pairs vs. Quasimodel Approach

The quasimodel approach (which closed the Until/Since sorries) works by:
1. Building finite quasimodels over a finite formula closure
2. Exhaustively checking eventuality discharge on the finite structure
3. Unwinding into a linear model

This is precisely the bilateral/dual approach — it was already tried and succeeded for Until/Since. The forward_F problem is harder because F(ψ) in a quasimodel state does not force ψ in a quasimodel successor (quasimodels are nondeterministic). The same obstacle appears whether the state is an MCS or a bilateral pair.

### Until Reformulation via BX12 (Approach 21, Teammate B prior)

`F(ψ) → ⊤ U ψ` via BX12, then apply proved `bx_until_eventuality_resolution`. This approach is bilateral in spirit (uses dual Until/F relationship) but:
- `bx_until_eventuality_resolution` produces an abstract BXPoint, not a chain index
- The obstacle is the same chain-vs-abstract-world gap

**No progress possible from bilateral framing.**

## Evidence and Technical Details

### Why Classical Bilateral Pairs = MCS (Formal Argument)

A pair ⟨V, F⟩ satisfying the proposed conditions in classical logic:
1. V consistent (¬⊢ ⊥ from V)
2. φ ∈ F iff ¬φ ∈ V
3. V closed under MP
4. V closed under implications derivable from V

In classical logic (with excluded middle), any consistent set maximally extended by Lindenbaum satisfies:
- For all φ: φ ∈ V or ¬φ ∈ V (not both, by consistency)
- So: φ ∉ V iff ¬φ ∈ V iff φ ∈ F

This is exactly the negation-complete property of MCS (`SetMaximalConsistent.negation_complete`). The bilateral pair ⟨V, F⟩ carries no more information than V alone. F is uniquely determined by V.

### Why the Extension Requires Choice (Fundamental Obstacle)

Any consistent set S can be extended to a balanced pair ⟨V, F⟩ (= an MCS extending S) by Zorn's Lemma / Lindenbaum's Lemma. However:
- This extension is **non-unique** — exponentially many MCS extend S
- Classical choice (`Classical.choice`) selects one arbitrarily
- No bilateral constraint forces the extension to contain ψ when F(ψ) ∈ M

The forward_F problem requires that SOME specific formula ψ is in the extension when F(ψ) ∈ M. The bilateral framing does not constrain which extension is chosen.

### Comparison with Restall/Rumfitt Bilateral Semantics

Restall's bilateral framework works with signed formulas `+φ` (assertion) and `-φ` (denial) in a sequent calculus. The key property is:
- Rules are symmetric between assertion and denial
- Classical logic emerges from the bilateral rules

For modal/temporal operators, bilateral rules would require:
- `+G(φ)` assertion introduction: from asserting φ at all future states
- `-G(φ)` denial introduction: from denying φ at some future state

This is semantically equivalent to standard Kripke semantics for G and ¬◇¬φ. No new insight for the forward_F proof.

### Belnap-Dunn Modal Temporal Logic (Odintsov-Wansing)

In BK and BS4 (Belnap-Dunn modal logics with strong negation):
- Two accessibility relations R⁺ (trust in assertions) and R⁻ (trust in denials)
- Completeness proofs use canonical models with **pairs** (T, F) of formula sets per world
- For temporal extensions: separate R⁺_G and R⁻_G for the G operator

This is the most technically developed bilateral approach for modal logic. However:
- It is designed for paraconsistent/four-valued logics (truth-value gluts and gaps)
- BX is classical: the 37-axiom system uses `peirce` (classical excluded middle)
- The forward_F problem exists in this setting too, since F-witnesses are still constructed by Lindenbaum extension
- **No published bilateral completeness proof avoids the eventuality witness problem**

### Nelson's N4 and Temporal Extensions

Nelson's N4 logic uses bilateral semantics with:
- V(φ) = truth conditions
- F(φ) = falsity conditions
- Strong negation: V(¬φ) = F(φ), F(¬φ) = V(φ)

Temporal extensions of N4 (BS4 with temporal operators) handle G/F via:
- V(G(φ)) = all future states have φ in V
- F(G(φ)) = some future state has φ in F

This is sound for paraconsistent temporal semantics. Completeness proofs (when they exist) still rely on Lindenbaum extension for individual chain steps. The forward_F obligation in N4-style temporal logic faces the same obstacle: extending `{ψ} ∪ g_content(M)` to a maximal V-set may place F(ψ) in V (= ¬ψ in F-component), violating the eventuality witness requirement.

**No existing formalization of N4 temporal logic in Lean 4 / Mathlib found.**

## Assessment of the Bilateral Pairs Proposal

### Claim 1: "Bilateral pairs avoid Lindenbaum's lemma"
**FALSE.** Bilateral pairs are Lindenbaum-saturated consistent sets. The extension requires Zorn's Lemma / Classical.choice. The bilateral framing is syntactic sugar.

### Claim 2: "φ ∈ F iff ¬φ ∈ V provides tighter control"
**FALSE** for classical logic. This condition holds automatically in any MCS. It constrains nothing beyond consistency. In paraconsistent logics (where ¬φ ∈ V does not force φ ∉ V), the condition adds content, but BX is classical.

### Claim 3: "Bilateral semantics handle G/H/F/P differently"
**TRUE** in the sense that one can define V(G(φ)) and F(G(φ)) independently. But for classical G:
- V(G(φ)) = all futures have φ ∈ V
- F(G(φ)) = some future has φ ∈ F = some future has ¬φ ∈ V

This is equivalent to standard G (V(G(φ)) = ¬V(F(¬φ))). Classical equivalences (¬G(φ) ↔ F(¬φ)) hold and make the bilateral extension redundant.

### Claim 4: "Balanced extension preserves classical equivalences"
**TRUE.** Any MCS preserves ¬G(φ) ↔ F(¬φ) (they are equivalent in MCS by BX axioms and negation completeness). This is not new.

### Claim 5: "Constructive version possible"
**POTENTIALLY.** If one moves to intuitionistic logic (dropping peirce), bilateral pairs genuinely add content. But BX requires classical logic. Moving to constructive logic would require removing peirce and redesigning the entire semantics.

## Confidence Level

**Low (10-15%)** that bilateral pairs, as a new mathematical framework, can resolve the forward_F sorry.

**Reasoning:**
1. In classical logic, bilateral pairs are definitionally equivalent to MCS — no new mathematical structure
2. The forward_F obstacle is about **choice control at Lindenbaum extension**, which bilateral pairs do not address
3. No published literature uses bilateral pairs to handle eventuality witnesses in classical tense logic
4. The Belnap-Dunn four-valued approach is the closest match but requires fundamental redesign
5. Lean 4 formalization of bilateral temporal semantics from scratch would cost 50+ hours with uncertain outcome

**High (95%)** that the core architectural analysis from Report 18 is correct: the forward_F gap is a Lindenbaum choice control problem, and the ordered-discharge chain (Teammate D's approach) is the most viable path.

## Recommendations

**Primary**: Reject bilateral pairs as a shortcut approach for the classical BX system. The idea is mathematically equivalent to MCS and provides no new leverage.

**Secondary**: The quasimodel approach already implemented in the codebase IS the most sophisticated bilateral-flavored approach (using finite quasimodels with explicit positive/negative content). The Until/Since sorries were closed this way. If quasimodel/defect-chain machinery can be adapted for F (not just U), this is the bilateral approach most likely to succeed. See `Quasimodel/Construction.lean` and `Filtration/DefectChain.lean`.

**If bilateral semantics is desired**: The only viable path is adopting Belnap-Dunn four-valued semantics for BX, which would require:
1. Redesigning `Truth.lean` to use paired semantics (V, F) per world-history-time triple
2. Proving soundness of BX under the four-valued semantics
3. Reconstructing the canonical model with bilateral pairs
4. This would likely require 100+ hours and is not recommended.

**Fallback recommendation (consistent with Report 18)**: Implement ordered-discharge chain with never-resolved count (Teammate D's approach). This directly controls the Lindenbaum choice problem and has 55-65% confidence.

## Sources

- [Bilateralism in proof-theoretic semantics (Academia.edu)](https://www.academia.edu/3387957/Bilateralism_in_proof_theoretic_semantics)
- [Notion of validity for bilateral classical logic (arXiv 2310.13376)](https://arxiv.org/html/2310.13376)
- [Belnap-Dunn Modal Logics (Cambridge Core)](https://www.cambridge.org/core/journals/review-of-symbolic-logic/article/abs/belnapdunn-modal-logics-truth-constants-vs-truth-values/B67AEA04085BDCCD8F90ABC859645813)
- [Modal logics with Belnapian truth values (Odintsov-Wansing, Tandfonline)](https://www.tandfonline.com/doi/abs/10.3166/jancl.20.279-301)
- [Belnap-Dunn Modal Logic with Value Operators (Studia Logica)](https://link.springer.com/article/10.1007/s11225-020-09925-y)
- [Paraconsistent Gödel modal logic on bi-relational frames (arXiv 2303.14164)](https://arxiv.org/abs/2303.14164)
- [A Gödel Calculus for Linear Temporal Logic (arXiv 2205.05182)](https://arxiv.org/pdf/2205.05182)
- [Bilateral Relevant Logic (Nissim Francez, Academia.edu)](https://www.academia.edu/5682899/Bilateral_Relevant_Logic)
- [Bilateral base-extension semantics (arXiv 2510.16763)](https://arxiv.org/html/2510.16763v1)
- [Finite Model Property in Weakly Transitive Tense Logics (Studia Logica)](https://link.springer.com/article/10.1007/s11225-022-10027-0)
- [Constructive linear-time temporal logic: Proof systems and Kripke semantics (ScienceDirect)](https://www.sciencedirect.com/science/article/pii/S0890540111001416)
- [Strong negation and normal modal substructural logics (Springer)](https://link.springer.com/article/10.1023/B:LOGI.0000003928.44012.57)
- [Nelson's paraconsistent logics proof theory (ScienceDirect)](https://www.sciencedirect.com/science/article/pii/S0304397511008978)
