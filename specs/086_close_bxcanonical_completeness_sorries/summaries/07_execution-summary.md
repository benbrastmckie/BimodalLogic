# Execution Summary: Task 86 - Proof-Theoretic Approach (Plan 07)

**Task**: 86 - Close BXCanonical completeness sorries
**Plan**: 07_proof-theoretic-plan.md
**Status**: BLOCKED at Phase 1 go/no-go gate
**Session**: sess_1775755919_ae30f5

## Outcome

Phase 1 (Proof-Theoretic Derivation of imp Case B) reached the **go/no-go gate with a NO-GO decision**. After exhaustive exploration of proof-theoretic approaches, no viable strategy was found to close the sorry at CanonicalEmbedding.lean:418. The sorry represents a genuine gap in the current formalization architecture.

## Approaches Explored

### 1. Flatten + Fragment Completeness

**Idea**: Define `flatten : Formula -> Formula` that strips G and H. Show `valid phi -> valid (flatten phi)` for USF phi, then use `fragment_completeness` to get `|- flatten(phi)`, then "unflatten" back to `|- phi`.

**Result**: The validity transfer `valid phi -> valid (flatten phi)` IS provable via a novel constant-model argument (see Finding 1 below). However, the unflatten direction `|- flatten(phi) -> phi` is NOT derivable. Specifically, `|- flatten(G(alpha)) -> G(alpha)` = `|- flatten(alpha) -> G(alpha)` requires `|- alpha -> G(alpha)`, which is not a theorem of BX logic (p true now does not imply G(p) always true).

### 2. Constant-Model Validity Transfer

**Idea**: Use `h_valid : valid (psi -> chi)` instantiated at a constant model through w to derive flatten(psi) in w -> flatten(chi) in w.

**Result**: This works! From `psi in w` and `|- psi -> flatten(psi)` (forward flatten, derivable via BX1), we get `flatten(psi) in w`. The constant-model argument then gives `flatten(chi) in w`. But `flatten(chi) in w` does NOT imply `chi in w` -- this is the same unflatten gap. For chi = G(alpha): flatten(G(alpha)) = flatten(alpha), so flatten(alpha) in w but G(alpha) not-in w is perfectly consistent (alpha true at w but not at all bx_le-successors).

### 3. Unflatten Theorem (with validity hypothesis)

**Idea**: Prove `valid phi -> |- flatten(phi) -> |- phi` for USF phi. The validity hypothesis might enable the unflatten.

**Result**: Works for G, H, box cases (validity reduces to sub-formula, IH gives `|- sub`, then necessitation gives `|- G(sub)`, etc.). FAILS for imp case: `valid (psi -> chi)` and `|- flatten(psi) -> flatten(chi)` does not give `|- psi -> chi`. The unflatten IH on chi requires `|- flatten(chi)` (not `|- flatten(psi) -> flatten(chi)`), and contextual unflatten `[psi] |- flatten(chi) -> [psi] |- chi` fails because temporal necessitation requires empty context.

### 4. Well-Founded Induction on Formula Size

**Idea**: Use size-based induction to apply the IH to formulas like `psi.imp bot` (negation) or `flatten(phi)`.

**Result**: `flatten(phi)` has strictly smaller temporal depth, so IH applies for validity. But the unflatten gap persists. The contrapositive `neg(chi) -> neg(psi)` has LARGER size than `psi -> chi`, so the IH doesn't apply.

### 5. FMP Contrapositive

**Idea**: Use `fmp_contrapositive` (sorry-free): if `psi.imp chi in S.carrier` for all ClosureMCSBundle S, then `|- psi.imp chi`.

**Result**: Circular. Showing `psi.imp chi in S.carrier` for every ClosureMCS is equivalent to showing `psi.imp chi` is derivable (by the contrapositive of `fmp_contrapositive` itself). This is confirmed by the team research (Finding 6 of report 07).

### 6. Contextual Strong Completeness

**Idea**: Prove `{psi} |= chi -> [psi] |- chi` (strong completeness) by IH on chi. Then deduction theorem gives `|- psi -> chi`.

**Result**: Requires full strong completeness for atomic formulas under assumptions, which is even harder than the weak completeness we're trying to prove. Also blocked by the same truth lemma gap.

### 7. Case Analysis on Chi's Structure

**Idea**: Case-split on chi = atom/bot (fragment_completeness), chi = G(alpha) (validity reduction), chi = imp(alpha, beta) (recursive IH).

**Result**: chi = atom/bot works via constant-model argument (flatten(chi) = chi, so flatten(chi) in w gives chi in w). chi = G(alpha) fails (flatten(G(alpha)) in w does not give G(alpha) in w). chi = imp reduces to recursive case with same problem.

### 8. Normal Form Reduction

**Idea**: Show every valid USF formula is provably equivalent to a temporal-free formula.

**Result**: Speculative, not viable. G(p -> q) is NOT equivalent to p -> q in general. The equivalence `phi <-> flatten(phi)` fails in the backward direction for formulas containing G/H.

## Key Finding: Constant-Model Validity Transfer Theorem

A novel result discovered during exploration:

**Theorem** (pen-and-paper): For USF phi, `valid phi -> valid (flatten phi)`.

**Proof sketch**: For any model (D, F, M, Omega, tau, t), construct the associated constant model where Omega' = {constant_history(sigma.states(t)) | sigma in Omega} and tau' = constant_history(tau.states(t)). On this constant model:
1. truth_at(phi) = truth_at(flatten(phi)) for USF phi (because G/H collapse to identity on constant models)
2. truth_at(flatten(phi)) on constant model = truth_at(flatten(phi)) on original model at time t (because flatten(phi) is temporal-free, and temporal-free truth depends only on current world state and modal alternatives, which are the same)
3. By valid(phi): truth_at(phi) on constant model = true
4. Combining: truth_at(flatten(phi)) on original model = true

This theorem is useful but insufficient to close the sorry because of the unflatten gap.

## Root Cause Analysis

All proof-theoretic approaches reduce to the same fundamental obstacle:

**The Contextual Necessitation Gap**: The BX proof system (like all Hilbert-style systems for modal/temporal logics) has necessitation rules that require derivation from the EMPTY context:
- Temporal necessitation: `|- alpha -> |- G(alpha)`
- Modal necessitation: `|- alpha -> |- box(alpha)`

But `[psi] |- alpha -> [psi] |- G(alpha)` is NOT valid (just because alpha is derivable from psi doesn't mean G(alpha) is). This means:
- From `|- flatten(psi) -> flatten(chi)`, we can derive `[psi] |- flatten(chi)` (by forward flatten + syllogism)
- But `[psi] |- flatten(chi)` does NOT give `[psi] |- chi` when chi contains G/H
- Because the unflatten `[psi] |- flatten(chi) -> [psi] |- chi` requires `[psi] |- alpha -> [psi] |- G(alpha)`, which is contextual necessitation

This is the same obstruction identified by the team research (Teammate A, Section 2b) but now with a more complete analysis showing it applies to ALL proof-theoretic approaches, not just the flatten reduction.

## Relationship to Semantic Approaches

The proof-theoretic gap is the DUAL of the semantic gap:
- **Semantic gap**: On constant-history canonical models, truth_at(G(alpha)) = truth_at(alpha), so the backward truth lemma fails (truth_at(alpha) does not imply G(alpha) in w)
- **Proof-theoretic gap**: `|- alpha` does not imply `|- G(alpha)` in context (contextual necessitation fails)

Both gaps arise from the same root cause: G(alpha) is STRONGER than alpha (it requires alpha at all future times, not just now), and there is no mechanism in the current framework to bridge this strength difference within the imp case.

## Recommendation

The sorry at CanonicalEmbedding.lean:418 requires one of:
1. **Non-constant-history canonical model construction** (needs bx_le linearity proof in Frame.lean -- the `bx_le` ordering must be proven linear on BXPoints to support a proper chain construction with forward_F)
2. **A fundamentally new proof technique** not yet identified in 40+ rounds of research

The task should be marked [BLOCKED] with a dependency on either closing the Frame.lean bx_le linearity sorries or discovering a novel proof approach.

## Artifacts

- Plan: `specs/086_close_bxcanonical_completeness_sorries/plans/07_proof-theoretic-plan.md` (updated to [BLOCKED])
- Summary: `specs/086_close_bxcanonical_completeness_sorries/summaries/07_execution-summary.md` (this file)
- No code changes (sorry remains as-is)
