# Teammate A Findings: Burgess's Proof Method for D0 Seed Consistency

## Key Findings

### 1. Burgess's "DCS" does NOT require consistency

In Section 1.3 (line 65 of the transcription), Burgess defines: "A is *deductively closed* if it contains all its consequences. We will be interested in deductively closed sets (DCSs)."

This is **explicitly** just "deductively closed" — no consistency requirement. MCSs are the consistent+maximal subset of DCSs. This directly contradicts the formalization's `SetDeductivelyClosed` which bundles consistency in.

### 2. Burgess's R-maximality quantifies over ALL DCSs (including inconsistent)

In Section 2.3 (line 142): "We write $R(A, B, C)$ to indicate that $B$ is maximal with respect to the property $r(A, \text{---}, C)$"

The "earlier remark" states: "whenever $R(A, B, C)$ holds and $\delta \notin B$ there must exist a $\beta \in B$ such that $r(A, \beta \wedge \delta, C)$ does not hold (else consider $B' =$ consequences of $B \cup \{\delta\}$)."

The argument works because **consequences(B ∪ {δ}) is always a DCS** (whether or not it's consistent), and if r(A, B', C) held for this B', it would be a proper extension of B contradicting maximality. Burgess does NOT need to case-split on consistency here.

### 3. The inconsistent case NEVER arises in Burgess

Because Burgess's maximality quantifies over ALL DCSs, when δ ∉ B:
- If {δ}∪B is consistent: consequences(B ∪ {δ}) is a consistent proper DCS extension
- If {δ}∪B is inconsistent: consequences(B ∪ {δ}) = Set.univ, which is still a DCS

In BOTH cases, the maximality argument produces the witness β₀ ∈ B, γ₀ ∈ C with ~U(γ₀, β₀∧δ) ∈ A. The proof then proceeds uniformly using A5a + A4a + A3a + 2.2 to establish the consistency of ζ.

**The inconsistent-case split is entirely a formalization artifact** caused by restricting maximality to consistent DCSs only.

### 4. Burgess does NOT use an irr_until axiom

The base system J₀ (Section 1.2) contains only A1a-A7a and their mirror images, plus truth-functional tautologies and temporal generalization. There is NO axiom of the form `G(φ.neg) → (untl(φ, ψ)).neg`. The density and discrete axiomatizations are treated separately later in the paper.

### 5. Burgess does NOT use density axioms for the base completeness

The base completeness proof (Sections 2.1-2.11) is for J₀ over K₀ = the class of ALL linear orders. No density or discreteness is assumed. The model is constructed over the rationals (line 238: "the order being the usual order on the rationals") but this is a CONSTRUCTION CHOICE, not a semantic requirement — he's showing every consistent formula is satisfiable over SOME linear order, and rationals happen to be convenient.

### 6. The Structural Fix: Align with Burgess's Definition

The correct fix is to make `BurgessR3Maximal` quantify over `ClosedUnderDerivation` sets (Burgess's DCSs) rather than `SetDeductivelyClosed` (which adds consistency). This was attempted previously (plan 56, Phase 1) but introduced an unprovable sorry in the Zorn proof because the Zorn chain is over CONSISTENT sets.

The tension: Zorn produces maximality among consistent DCSs, but Burgess needs maximality among ALL DCSs.

**Resolution**: The Zorn-maximal B IS actually maximal among all DCSs, because:
- Among consistent DCSs: direct from Zorn
- Among inconsistent DCSs: if D is an inconsistent DCS with r(A, D, C), then D = Set.univ (closure of inconsistency). If r(A, Set.univ, C) holds AND B ⊊ Set.univ, then any consistent DCS B' with B ⊆ B' satisfies r(A, B', C) too (since B' ⊆ Set.univ and r is monotone... wait, r is NOT monotone in the second argument upward; it requires membership in B for the universal).

Actually, r(A, B, C) = "∀ β ∈ B: ∀ γ ∈ C: U(γ, β) ∈ A". This is ANTI-monotone: if B ⊆ B' then r(A, B', C) is STRONGER. So r(A, Set.univ, C) IMPLIES r(A, B, C) for any B. If r(A, Set.univ, C) holds, then EVERY DCS has property r, and maximality is vacuous — B cannot be maximal unless B = Set.univ itself (contradicting B's consistency).

This means: **if R(A, B, C) holds and B is consistent, then r(A, Set.univ, C) CANNOT hold** (otherwise Set.univ would be a proper DCS extension of B with r). Therefore the inconsistent-case concern about "burgessR3(A, Set.univ, C) being satisfiable" is irrelevant when we ALREADY have R(A, B, C) with consistent B.

## Recommended Approach

**The formalization should re-align with Burgess by changing `BurgessR3Maximal` maximality to quantify over `ClosedUnderDerivation` (all DCSs)**. The Zorn proof's inconsistent case is resolved by:

The sorry at the Zorn construction asked to derive False from: B is Zorn-maximal consistent DCS, D is ClosedUnderDerivation with B ⊊ D, r(A, D, C), D inconsistent. Since D inconsistent + ClosedUnderDerivation means D = Set.univ. So r(A, Set.univ, C) holds. But r is anti-monotone: r(A, Set.univ, C) means ∀β, ∀γ∈C: U(γ,β) ∈ A. In particular for any consistent DCS B' ⊇ B: r(A, B', C) holds. This means B is NOT Zorn-maximal among consistent DCSs (we can always extend B while maintaining r) — **unless B itself is already an MCS**. 

Wait, Zorn-maximality among {consistent DCSs B' with B₀ ⊆ B' and r(A, B', C)} gives an MCS B. An MCS has no proper consistent DCS extension (it's already maximal consistent). So if r(A, Set.univ, C) held, every consistent DCS would satisfy r, and B being MCS means no proper consistent extension exists — so Zorn says B is maximal among consistent DCSs. But Set.univ is a proper INCONSISTENT DCS extension. The question is whether B is maximal among ALL DCSs.

Since B is MCS and B ⊊ Set.univ, and r(A, Set.univ, C) holds, the answer is NO — Set.univ IS a proper extension with r. So maximality among all DCSs FAILS in this case.

This means **we cannot simply change the definition back to ClosedUnderDerivation** without the Zorn proof breaking again. The previous attempt (plan 56) demonstrated exactly this problem.

### Revised Recommendation

The correct approach is one of:

1. **Keep `SetDeductivelyClosed` in maximality BUT add the lemma**: "If R(A,B,C) holds (maximality among SetDeductivelyClosed = consistent DCSs), then for all δ ∉ B, ∃β∈B, γ∈C: ~U(γ, β∧δ) ∈ A." This is provable by showing that consequences(B∪{δ}) either:
   - Is consistent → contradicts Zorn maximality directly
   - Is inconsistent → then r(A, Set.univ, C) would hold. But B being MCS + r(A, Set.univ, C) means every set satisfies r. In particular B∪{δ} → DC(B∪{δ}) = Set.univ satisfies r. Since every consistent DCS satisfies r too, and B is maximal among those, B is MCS. Since δ ∉ B (hypothesis) and B is MCS, δ.neg ∈ B. Then β₀ = δ.neg works: U(γ, δ.neg ∧ δ) = U(γ, ⊥). Since A is MCS and U(γ, ⊥) would require F(⊥)... 
   
   Actually this still needs U(γ, ⊥) ∉ A. Under open-guard semantics U(⊥, γ) IS satisfiable but U(γ, ⊥) means "there exists a future point where ⊥ holds AND γ holds at all intermediates" — ⊥ cannot hold at any point! So U(γ, ⊥) is UNSATISFIABLE and hence ~U(γ, ⊥) is a THESIS. Therefore ~U(γ, ⊥) ∈ A for any MCS A.

   So: If {δ}∪B inconsistent, take β₀ = δ.neg ∈ B (since B is MCS and δ ∉ B). Then β₀∧δ = δ.neg∧δ which is propositionally equivalent to ⊥. So U(γ, β₀∧δ) = U(γ, ⊥) (or rather, derives from it via left-mono). And ~U(γ, ⊥) ∈ A because U(γ, ⊥) is unsatisfiable (event = ⊥ requires a point where ⊥ is true).

2. **Key insight: U(γ, ⊥) is UNSATISFIABLE under ANY semantics** (the event/target position must satisfy ⊥, which is impossible). Therefore ~U(γ, ⊥) is valid and hence a thesis, and in every MCS.

## Evidence/Examples

- Burgess Section 1.3, line 65: DCS = deductively closed (no consistency)
- Burgess Section 2.3, line 142: R-maximality argument uses "consequences of B∪{δ}" without case-splitting
- Burgess Section 2.6, line 170: Proof uses the witness from the "earlier remark" uniformly
- U(γ, ⊥) semantics: "∃s>t: ⊥@s ∧ ∀r(t<r<s → γ@r)" — requires ⊥ to be true somewhere, impossible

## Confidence Level

**High** — The analysis of Burgess's definitions is directly from the text, and the U(γ, ⊥) unsatisfiability is a simple semantic observation. The key insight is that the inconsistent case β₀∧δ reduces to a propositional falsity in the Until's second argument (event/target), making the negation trivially derivable.
