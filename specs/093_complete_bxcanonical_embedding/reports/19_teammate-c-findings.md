# Teammate C Findings: Bilateral Pairs — Critic Analysis

## Key Findings

### 1. Bilateral Pairs ARE Maximally Consistent Sets in Disguise

The most fundamental problem with the bilateral pairs proposal: it does not escape MCS.

A "balanced pair" ⟨V, F⟩ satisfying the proposal's four properties:
- Negation closure: φ ∈ F iff ¬φ ∈ V; φ ∈ V iff ¬φ ∈ F
- MP closure: V closed under modus ponens
- Implication closure: if ¬φ ∈ V or ψ ∈ V, then φ → ψ ∈ V
- Consistency: V consistent

This is equivalent to an MCS. Proof sketch:
- V ∩ F = ∅ is forced: if φ ∈ V ∩ F, then ¬φ ∈ V (negation closure on F-side), so V derives ⊥ from {φ, ¬φ}, contradicting consistency of V.
- V ∪ F is "complete": for any formula φ, either φ ∈ V or φ ∈ F (since if φ ∉ V, can V ∪ {φ} derive ⊥? If yes, ¬φ ∈ V by MCS maximality argument; then negation closure gives φ ∈ F. If no, then φ ∈ V by MCS maximality — contradiction).
- Therefore V is an MCS, and F = {φ | ¬φ ∈ V} = the complement of V in the standard Boolean sense.

The bilateral framework is just an alternative notation: V is the positive component (what an MCS asserts), and F is the negative component (what it denies). No new mathematics.

### 2. The forward_F Problem Is Unchanged

The core issue: at each step of the Lindenbaum extension chain, `.choose` selects an MCS that contains `g_content(M)` but is otherwise unconstrained. The bilateral reformulation does not control this choice because:

- Extending a consistent set to a balanced pair requires the same Lindenbaum lemma as extending to an MCS.
- The choice of which balanced pair to extend to is still unconstrained.
- The same counterexample scenario applies: at every visit step for ψ, Lindenbaum can choose an extension where `G(¬ψ) ∈ V` (equivalently, `G(¬ψ) ∉ F`), permanently falsifying `F(ψ)`.
- Nothing in the bilateral closure properties constrains the forward temporal behavior.

In short: the bilateral pairs proposal relocates the names of the objects but leaves the mathematical obstruction intact.

### 3. The "Constructive-Friendly" Claim Is Incoherent for TM

The TM logic has Peirce's law `((φ → ψ) → φ) → φ` as an explicit axiom (see `Axioms.lean:81`). This is a non-constructive axiom equivalent to excluded middle in the presence of the other propositional axioms. Therefore:

- A constructive proof of the Lindenbaum lemma for TM is impossible: the lemma requires excluded middle to decide φ ∈ MCS vs φ ∉ MCS at each step.
- Bilateral semantics provides no constructive advantage for classical logic. If the goal is constructivism, TM's Peirce's law would need to be dropped.
- The "constructive-friendly" rationale is moot: we need `.choose` (classical choice) anyway, because the logic is classical.

### 4. The Bilateral Falsity Conditions for Temporal Operators Add No Value

The proposal defines histories τ: D → ⟨V, F⟩. Under the proposal's intended bilateral semantics:
- M,τ,x ⊨+ F(φ) iff ∃s > x, M,τ,s ⊨+ φ
- M,τ,x ⊨- F(φ) iff ∀s > x, M,τ,s ⊨- φ

The second clause is just `⊨+ G(¬φ)` in classical semantics (since M,τ,s ⊨- φ iff ¬φ ∈ V(s) iff M,τ,s ⊨+ ¬φ). So bilateral falsity of F(φ) reduces to classical truth of G(¬φ). This adds nothing beyond the existing Truth.lean semantics for G/H.

The critical question for `forward_F` is: given `F(ψ) ∈ V(n)` (= `F(ψ) ∈ M_n`), why must ψ ∈ V(s) for some s > n? This is exactly the sorry at line 1274 of RootScopedChain.lean. The bilateral framework does not answer this question — the same Lindenbaum non-determinism prevents it.

### 5. Infrastructure Cost Is Prohibitive Without Clear Gain

The existing codebase has:
- Frame.lean (673 lines, sorry-free): BXPoint as MCS, bx_le, bx_modal_equiv, canonical frame machinery
- TruthLemma.lean (320 lines, sorry-free): truth lemma for atom, bot, imp, box, G, H, Until/Since forward
- RootScopedChain.lean (~1400 lines, 6 sorry sites concentrated in forward_F and forward_P)
- Quasimodel infrastructure (2,289 lines, sorry-free)

Rewriting BXPoint as a bilateral pair would require:
1. Replacing every `SetMaximalConsistent` in Frame.lean with a bilateral-pair predicate.
2. Re-proving all canonical frame properties (bx_le_refl, bx_le_trans, bx_modal_equiv properties) in terms of the new definition.
3. Re-proving the truth lemma for all connectives — approximately 320 lines of work.
4. Re-proving all quasimodel infrastructure that uses MCS properties.

This is a ~1000+ line rewrite with no certainty of success, because (per Finding #1) the bilateral pair IS the MCS. The rewrite would end with the same Lindenbaum non-determinism problem.

### 6. The Proposal Conflates Proof-Theoretic and Model-Theoretic Approaches

Bilateral proof systems (Gentzen, Dunn's gaggle theory) are proof-theoretic in nature — they give cut-free sequent calculi. The `forward_F` problem is a model-theoretic construction problem: we need to BUILD a linear chain of MCS with the right temporal properties. These are orthogonal concerns.

A bilateral proof system for TM would give us: if ψ is not derivable from Γ, then there exists a bilateral model separating them. But we already have this via the classical canonical model. The bilateral framing helps with proof search and cut elimination, not with the Lindenbaum chain construction.

## Potential Showstoppers

1. **Bilateral pairs = MCS (dispositive)**: The proposal is formally equivalent to the existing approach. Zero gain, maximum cost. This alone kills the bilateral pairs idea as a path forward.

2. **No constraint on Lindenbaum choice**: The bilateral closure properties do not force the Lindenbaum extension to resolve F-obligations. The same 3-way BX11 disjunction applies, and `.choose` is still unconstrained.

3. **Constructive claim is vacuous**: TM is classical (Peirce's law). Constructive extensions of Lindenbaum are impossible without changing the logic.

4. **Bilateral falsity reduces to classical truth**: No new semantic leverage for temporal operators.

5. **Cost without benefit**: ~1000+ lines of re-proof to arrive at mathematically equivalent infrastructure.

## Evidence / Examples

### Bilateral Pair ↔ MCS Isomorphism

Let M be an MCS. Define:
```
V = M
F = {φ | ¬φ ∈ M}
```

Verify all bilateral closure properties:
- **Negation closure**: φ ∈ F iff ¬φ ∈ M = V. ✓
  φ ∈ V = M iff ¬φ ∉ M (by MCS consistency + completeness) iff ¬φ ∈ F. ✓
- **MP closure**: V = M is MCS, so closed under derivation, hence under MP. ✓
- **Implication closure**: If ¬φ ∈ V or ψ ∈ V, then ¬φ ∈ M or ψ ∈ M. In either case, φ → ψ ∈ M (by `imp_iff_mcs` at TruthLemma.lean:75: `φ.imp ψ ∈ S ↔ (φ ∈ S → ψ ∈ S)`). ✓
- **Consistency**: M consistent. ✓

So every MCS gives a balanced pair. The converse: given ⟨V, F⟩ balanced, V is consistent and for every φ, φ ∈ V or ¬φ ∈ V (since if φ ∉ V, negation closure forces φ ∈ F, meaning ¬φ ∈ V). So V is an MCS. The correspondence is bijective.

### The Unchanged Counterexample for forward_F

Using the counterexample from report 18 (Team Research):
- σ_list = [ψ, χ]
- At every visit step for ψ: BX11 Case 3 fires, choosing F(ψ) over ψ.

In bilateral language:
- At every step n: F(ψ) ∈ V(n), ψ ∉ V(n), ψ ∈ F(n).
- This is syntactically consistent with all bilateral closure properties.
- The balanced pair ⟨V(n), F(n)⟩ at each step is a valid MCS, just one where ψ is always in the F-component.
- Nothing in the bilateral framework prevents this perpetual assignment.

### Temporal Operator Reduction

Bilateral falsity of F(ψ):
```
M,τ,x ⊨- F(ψ)
iff ∀s > x, M,τ,s ⊨- ψ
iff ∀s > x, ¬ψ ∈ V(s)   [by negation closure]
iff ∀s > x, M,τ,s ⊨+ ¬ψ
iff M,τ,x ⊨+ G(¬ψ)
```

This is exactly the classical condition. The bilateral notation adds no new constraint.

## Confidence Level

**High confidence (90%+) that the bilateral pairs approach has fatal issues as described.**

The core mathematical argument (bilateral pair = MCS) is elementary and I am confident it is correct. The consequence — that the bilateral framework provides zero advantage over the existing approach — follows directly. The remaining findings (constructive claim vacuous, temporal reduction, infrastructure cost) are secondary but consistent.

**The bilateral pairs proposal should be rejected.** The team's existing recommendation (ordered-discharge chain with "never-resolved count" termination measure) remains the most viable path. The infrastructure cost of bilateral pairs (~1000+ lines of re-proof) is larger than the cost of the ordered-discharge chain fix (~30 theorem re-proofs), and bilateral pairs offer no mathematical advantage.
