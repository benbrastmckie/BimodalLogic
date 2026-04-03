# Teammate B Findings: Alternative Approaches and F-Resolution Analysis

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Focus**: F-resolution circularity, alternative completeness paths, backward Until truth lemma

## Executive Summary

The dovetailed chain's F-resolution is structurally sound but depends on Until persistence (`forward_dovetailed_until_persists`), which requires X-content propagation. I analyze five alternative approaches. The most promising finding is that **the restricted truth lemma itself has sorry in the Until/Since cases** (CanonicalConstruction.lean lines 940, 943), meaning that even if all DovetailedChain sorries were closed, `completeness_over_Int` would still be blocked. This makes the backward Until truth lemma the true critical bottleneck, not just F-resolution.

---

## 1. Bounded F-Resolution Analysis

### Current Architecture

The F-resolution argument in `forward_dovetailed_forward_F` (DovetailedChain.lean line 650) is:
1. `F(psi) in chain(t)` gives `(top U psi) in chain(t)` via `F_until_equiv`
2. Until persists until psi appears (via `forward_dovetailed_until_persists` -- **sorry**)
3. Fair scheduling gives `n >= t` with `schedule_formula(n) = psi`
4. At step n: `forward_step` resolves psi into `chain(n+1)`

**Key observation**: Step 4 does NOT have the interference problem I was asked to investigate. Looking at the actual code:

```lean
noncomputable def forward_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) : Set Formula :=
  if h_F : Formula.some_future phi in M then
    (temporal_theory_witness_with_g_exists M h_mcs phi h_F).choose
  else
    (temporal_theory_witness_with_g_exists M h_mcs (Formula.neg Formula.bot)
      (SetMaximalConsistent.contains_F_top h_mcs)).choose
```

The `forward_step` uses `temporal_theory_witness_with_g_exists`, which constructs a Lindenbaum extension of `{phi} union temporal_box_g_seed(M)`. This does NOT build a successor by adding phi to some existing x_content. Instead, it creates a fresh MCS containing phi by extending the seed `{phi} union G_theory(M) union box_theory(M) union g_content(M)`. The X(neg_psi) interference is irrelevant because the Lindenbaum extension chooses a maximally consistent completion of this seed -- if `{phi} union seed` is consistent (proven by `temporal_theory_witness_with_g_consistent`), then phi WILL be in the result regardless of what X-formulas exist.

**Conclusion**: The F-resolution step itself (step 4) is sound and sorry-free. The only blocker is step 2 (Until persistence), which depends on X-content propagation.

### Bounded Fuel Argument

The plan mentions "fuel = B*B+1" for bounded F-resolution. This is NOT needed for the dovetailed chain approach, which uses fair scheduling instead. The bounded fuel approach is an alternative in `SuccChainFMCS.lean` (`restricted_bounded_witness_fueled`). For the dovetailed chain, the argument is simpler: the `push_neg` branch in `forward_dovetailed_forward_F` assumes psi never appears at any step >= t, then finds a step n where it IS resolved -- contradiction. No fuel counting needed.

**Confidence**: HIGH that F-resolution itself is not the problem. The blocker is purely Until persistence.

---

## 2. Modifying forward_step to Unconditionally Include psi

**Not needed.** As analyzed above, `forward_step` already unconditionally includes the target formula phi when `F(phi) in M`. The seed `{phi} union temporal_box_g_seed(M)` is proven consistent via the G-lift argument, and the Lindenbaum extension ensures phi is in the result. There is no need to worry about X(neg_psi) interference because the construction is a fresh MCS extension, not a union with existing x_content.

**Confidence**: HIGH (this concern was based on a misunderstanding of the forward_step architecture).

---

## 3. FMP Completeness as Stepping Stone

### What FMP Gives Us

`fmp_completeness` (Correctness.lean line 100) states:
```lean
theorem fmp_completeness (phi : Formula) :
    (forall (S : FMP.ClosureMCSBundle phi), phi in S.carrier) ->
    Nonempty (DerivationTree [] phi)
```

This is sorry-free. It says: if phi is in every closure MCS (a purely syntactic/proof-theoretic condition), then phi is provable.

### Can We Derive completeness_over_Int from FMP?

`completeness_over_Int` needs: `valid_over Int phi -> Nonempty ([] derives phi)`.

To use FMP, we would need: `valid_over Int phi -> forall S : ClosureMCSBundle phi, phi in S.carrier`.

This requires showing that every ClosureMCSBundle can be "realized" as a point in some Int-indexed task model. That is, we need a **model existence theorem**: given a ClosureMCSBundle S with phi not in S.carrier, construct a model over Int where phi fails.

This IS essentially the completeness theorem restated. The FMP completeness avoids semantic models entirely -- it works purely at the syntactic MCS level. The hypothesis `forall S : ClosureMCSBundle phi, phi in S.carrier` is equivalent to `phi is provable` (by Lindenbaum), making the theorem essentially `provable -> provable` with the real content in the contrapositive direction.

**Assessment**: Using FMP to derive Int-completeness would require proving that every consistent formula has a model over Int -- which is exactly the completeness theorem we're trying to prove. This is circular.

**Alternative framing**: Could we prove `valid_over Int phi -> forall S, phi in S.carrier` without building models? This would require showing that MCS membership captures Int-validity. But MCS membership is a purely syntactic concept (consistent + maximal), while Int-validity is semantic. The bridge between them IS the truth lemma, which is exactly what has sorry.

**Confidence**: HIGH that this path is not viable.

---

## 4. Canonical Model via Quotient of MCS Space

### Proposal

Instead of building a chain step by step, define the canonical temporal model directly on the space of all MCSes:
- Temporal relation: `u R v` iff `g_content(u) subset v` (and `x_content(u) subset v`)
- Modal relation: `box_class_agree(u, v)`

### Analysis

**Problem 1: R is not a linear order.** Given MCS u, there are many MCSes v with `g_content(u) subset v`. Two such v1, v2 may be incomparable. The temporal frame for TM requires a LINEAR order on times.

**Problem 2: R is not well-founded or discretely ordered.** Even if we quotient by some equivalence, we need the resulting order to be isomorphic to (a subset of) Int with SuccOrder structure.

**Problem 3: No seriality guarantee.** We need every world to have a successor AND a predecessor. While `temporal_theory_witness_with_g_exists` shows that for any F-formula in u, there exists a suitable v, we need a SINGLE successor that satisfies ALL obligations simultaneously.

**What this approach actually gives**: This is essentially the standard Kripke-style canonical model for basic modal logic. For temporal logic, it doesn't work because the temporal frame must be linear, not branching. The chain construction exists precisely to linearize the temporal structure.

**Partial recovery**: One could try to build a tree of MCSes (branching successor function) and then use Konig's lemma or a selection principle to extract a linear path. But this is essentially what the dovetailed chain already does, just with more indirection.

**Confidence**: HIGH that this approach is not viable for TM's linear temporal frame.

---

## 5. Backward Until Truth Lemma: Contrapositive Analysis

### The Problem

The restricted truth lemma (CanonicalConstruction.lean line 928) needs:
```
phi U psi in mcs(t) <-> exists s > t, psi(s) AND forall r in (t,s), phi(r)
```

**Forward direction** (MCS -> truth): Needs forward_F to find witness s, then Until persistence for intermediates. BLOCKED by X-content propagation.

**Backward direction** (truth -> MCS): Given semantic witnesses, need `phi U psi in mcs(t)`. This is the "backward Until wall" from the team research report.

### Contrapositive Approach

The suggestion from report 13 is:
1. Prove forward direction: `phi U psi in mcs(t) => truth(phi U psi, t)`
2. By MCS maximality: `neg(phi U psi) in mcs(t) OR (phi U psi) in mcs(t)`
3. If `neg(phi U psi) in mcs(t)`, use forward truth lemma on negation to get `truth(neg(phi U psi), t)`, i.e., `not truth(phi U psi, t)`
4. Contrapositive: `truth(phi U psi, t) => phi U psi in mcs(t)`

**Critical dependency check**: This approach requires the forward direction to be proven FIRST. The forward direction requires:
- `forward_F` to find the witness s where psi holds
- Until persistence from t to s-1 (to show phi holds at intermediates via the Until formula persisting and being unfolded)

The forward direction is EQUALLY blocked by X-content propagation. So the contrapositive approach does NOT bypass the X-content propagation problem -- it merely reduces the backward direction to the forward direction.

**However**, there is a subtlety. The forward direction for NEGATION is different:
- `neg(phi U psi) in mcs(t) => truth(neg(phi U psi), t)` means `neg(phi U psi) in mcs(t) => not truth(phi U psi, t)`
- `not truth(phi U psi, t)` means: for all s > t, either not psi(s) or there exists r in (t,s) with not phi(r)
- By IH on phi and psi (subformulas), we can convert `not phi(r)` to `neg(phi) in mcs(r)` and `not psi(s)` to `neg(psi) in mcs(s)` -- but this uses the BACKWARD direction of the truth lemma for phi and psi!

**Circular dependency**: The contrapositive approach for `phi U psi` backward uses:
1. Forward direction for `phi U psi` (needs X-content propagation)
2. Forward direction for `neg(phi U psi)` (needs backward direction for phi, psi as subformulas)

Since phi and psi are strict subformulas, the structural induction handles (2). But (1) remains blocked.

### True Structure of the Dependency

The Until truth lemma has this actual dependency structure:
- **Forward** (`phi U psi in mcs(t) -> truth(phi U psi, t)`): Needs restricted_forward_F + Until persistence
- **Backward** (`truth(phi U psi, t) -> phi U psi in mcs(t)`): Can be derived from forward + negation + MCS maximality, IF forward is solved

The backward direction is NOT the true bottleneck. The forward direction is, and it depends on:
1. `DovetailedFMCS_forward_F` (sorry at line 1235) -- needs Until persistence
2. Until persistence (`forward_dovetailed_until_persists`, sorry at line 600) -- needs X-content propagation

**Confidence**: HIGH that the contrapositive approach is sound but does not bypass the X-content propagation requirement.

---

## 6. The True Critical Path (Updated)

After analyzing all sorries in the completeness path, the dependency chain is:

```
completeness_over_Int (Completeness.lean:472)
  |
  v
dovetailed_bundle_validity_implies_provability (Completeness.lean:430)
  |
  +-- restricted_shifted_truth_lemma (CanonicalConstruction.lean:812)
  |     |
  |     +-- Until/Since cases (line 940, 943) -- SORRY
  |           |
  |           +-- Forward: needs restricted_forward_F + Until persistence
  |           +-- Backward: reducible to forward via contrapositive
  |
  +-- dovetailed_bfmcs_restricted_temporally_coherent (Completeness.lean:401)
        |
        +-- DovetailedFMCS_forward_F (DovetailedChain.lean:1235) -- SORRY
        |     |
        |     +-- forward_dovetailed_until_persists (line 600) -- SORRY
        |           |
        |           +-- X-content propagation (no infrastructure exists)
        |
        +-- DovetailedFMCS_backward_P (DovetailedChain.lean:1243) -- SORRY
              |
              +-- backward_dovetailed_since_persists (line 966) -- SORRY
                    |
                    +-- Y-content propagation (symmetric)
```

**Root blocker**: X-content propagation. All 8 critical sorries trace back to this single missing piece of infrastructure.

**The X-content propagation problem**: Under strict semantics, `until_unfold` gives:
```
phi U psi -> X(psi or (phi and (phi U psi)))
```
where `X(chi) = bot U chi`. So `(phi U psi) in mcs(t)` and `psi not in mcs(t)` gives `X(psi or (phi and (phi U psi))) in mcs(t)`. We need `psi or (phi and (phi U psi)) in mcs(t+1)`, i.e., X-content propagation.

The forward_step constructs mcs(t+1) via Lindenbaum extension of `{target} union G_theory(M) union box_theory(M) union g_content(M)`. X-formulas from mcs(t) are NOT in this seed. The successor is a fresh MCS that agrees on G-theory, box-theory, and g_content, but has NO obligation to satisfy X-formulas from the predecessor.

**Teammate A's investigation** (adding X-K axiom) addresses exactly this -- the question is whether X distributes over implication, allowing X-content to be included in the seed while maintaining consistency.

---

## 7. Recommendations

### Immediate Priority: X-Content Propagation via X -> F Derivation

The most promising fix: derive `X(alpha) -> F(alpha)` as a theorem. This is the axiom `next_implies_some_future` which already exists:
```lean
| next_implies_some_future (phi : Formula) :
    Axiom ((Formula.untl Formula.bot phi).imp (Formula.some_future phi))
```

With this axiom, `X(alpha) in mcs(t)` gives `F(alpha) in mcs(t)`. Then `forward_step` with target alpha will put alpha in the successor. But wait -- forward_step uses a SCHEDULED target, not arbitrary F-formulas. The target at step n is `schedule_formula(n)`, which may not be alpha.

**Better approach**: Instead of relying on forward_step's scheduling, observe that `F(alpha) in mcs(t)` means `alpha` will eventually be resolved by fair scheduling. But for Until persistence, we need alpha in mcs(t+1) SPECIFICALLY, not at some future step.

**The real fix**: Enrich the seed in `temporal_theory_witness_with_g_exists` to include x_content. Define:
```
x_content(M) = {phi | X(phi) in M} = {phi | (bot U phi) in M}
```
Then the seed becomes `{target} union G_theory(M) union box_theory(M) union g_content(M) union x_content(M)`.

The consistency argument needs: if `L derives bot` and `L subset {target} union seed`, then contradiction. The G-lift argument works for G_theory and g_content elements (G(a) in M). For x_content elements, we need a different argument: if phi in x_content(M), then X(phi) in M. Can we "X-lift" from a set of x_content formulas to derive X(negation)?

This requires `X(phi1), ..., X(phi_n) derives X(phi1 and ... and phi_n)`, which needs X distributing over conjunction (X-K axiom). This is exactly Teammate A's investigation.

### Alternative: Weaken the Completeness Goal

If X-content propagation proves intractable, consider:
1. Prove completeness for the X-free fragment (formulas without Until/Since)
2. This would give completeness for the G/H/F/P fragment
3. Until/Since completeness could be left as future work

This is NOT recommended as it defeats the purpose of having Until/Since axioms, but it would give a publishable partial result.

### Alternative: Direct Semantic Argument

Instead of proving Until persistence through the chain construction, prove it semantically: build a model, show truth(phi U psi, t) in the model, use soundness of Until axioms. This circular-sounding approach actually works if we use the TRUTH LEMMA's structural induction carefully -- but it still needs the truth lemma's Until case, bringing us back to the same problem.

---

## Summary Table

| Approach | Feasibility | Blocks Remaining | Confidence |
|----------|-------------|------------------|------------|
| Fix X-content in forward_step seed | HIGH | X-K axiom proof needed | MEDIUM-HIGH |
| Bounded fuel argument | N/A | Not needed for dovetailed chain | HIGH |
| Modify forward_step | N/A | Already works as designed | HIGH |
| FMP -> Int completeness | NOT VIABLE | Circular dependency | HIGH |
| Quotient of MCS space | NOT VIABLE | Non-linear temporal frame | HIGH |
| Contrapositive Until backward | Sound but insufficient | Still needs X-content for forward | HIGH |
| Weaken to X-free fragment | Fallback only | Loses Until/Since | HIGH |
