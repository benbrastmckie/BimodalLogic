# Teammate B Findings: Alternative Proof Architectures

**Task**: 93 - Complete BXCanonical embedding (forward_F sorry)
**Role**: Alternative approaches analysis
**Date**: 2026-04-16
**Round**: 21

## Summary

This report investigates five alternative proof architectures for the BX completeness theorem
that avoid the core chain construction difficulty. The six remaining sorry sites all block
`rr_fwd_chain_forward_F` — the impossibility of proving that F(psi) ∈ chain(n) implies psi ∈
chain(s) for some s > n when using an unconstrained Lindenbaum extension.

**Bottom line**: None of the five alternative architectures cleanly avoids the core obstacle.
However, one approach — the **fold-order trick (target-last BX11 fold)** — offers the highest
probability of closing the specific forward_F sorry with minimal infrastructure cost. A second
approach — **direct consistency proof for the enriched resolving seed** — is mathematically
distinct from all 19+ prior attempts and merits serious investigation.

---

## Key Findings

### Finding 1: The Core Obstacle Is Localized to One Invariant

Reading `RootScopedChain.lean` lines 1254-1295 carefully, the obstacle is extremely specific:

The `rr_fwd_chain_forward_F` proof needs to show:

> Given F(psi) ∈ chain(n) with psi ∈ sigma_list, there exists s > n with psi ∈ chain(s).

The infrastructure already proves (lines 1132-1194):
- `rr_fwd_chain_F_obligation_persists`: F(psi) ∈ chain(n) → F(psi) ∈ chain(n+1)
- `rr_fwd_chain_F_obligation_forward`: F(psi) ∈ chain(n) → F(psi) ∈ chain(m) for all m ≥ n
- `rr_fwd_chain_F_preserved`: F(psi) ∈ chain(n) → psi ∈ chain(n+1) OR F(psi) ∈ chain(n+1)
- `rrSchedule_visits`: ψ is scheduled as target at step m for some m > n

The gap: `rr_fwd_chain_F_preserved` gives a disjunction at each step, and
`rrSchedule_visits` guarantees psi is eventually the target. But at the visit step,
we need `enriched_fwd_step` with target=psi to put psi in chain(m+1). The resolving
case of `enriched_fwd_step` (when F(target) ∈ M) gives target ∈ M' OR F(target) ∈ M'.
This is not strong enough — we need the direct case (target ∈ M').

The fundamental issue: `resolving_enriched_fwd_exists` (via `enriched_fwd_fold_with_witness`)
guarantees that SOME formula with F-obligation is directly resolved, but not necessarily
target. In BX11 Case 3 (the fold produces F(beta) ∧ chi from F(beta) and F(chi)),
the "direct witness" becomes chi (the newly folded formula), not the original target.

### Finding 2: Existing Infrastructure Is Substantial

The codebase has already built (sorry-free):
- `HintikkaPoint` + local consistency/maximality (Quasimodel/HintikkaPoint.lean)
- `hintikka_step` one-step relation (Quasimodel/Construction.lean)
- `sigma_defect_count` + defect discharge lemmas (Filtration/DefectChain.lean)
- `sigma_le`, `sigma_strict`, `sigma_equiv` ordering predicates (Filtration/SigmaOrdering.lean)
- `enriched_fwd_fold_with_witness` with direct-witness tracking (RootScopedChain.lean)
- `rr_fwd_chain_F_obligation_forward` and backward (RootScopedChain.lean)
- Entire Quasimodel/ directory (2,289+ lines) handling Until/Since discharge

This means any alternative approach MUST either reuse this infrastructure or provide a
separate path that does not require re-proving the parametric truth lemma, restricted
coherence, and BFMCS framework.

### Finding 3: The Active Sorry Path Is Narrow

The active completeness path in `dd_countermodel` (RootScopedChain.lean:1400-1427):
1. `dd_bfmcs_restricted_tc` (sorry) -- needs forward_F and backward_P
2. `dd_bfmcs_restricted_buc` (sorry) -- Until/Since backward coherence
3. `dd_bfmcs_restricted_fuc` (sorry) -- Until/Since forward coherence

`dd_bfmcs_restricted_tc` delegates to `dd_fmcs_forward_F` which delegates to
`rr_fwd_chain_forward_F`. So the chain of sorries is:

```
dd_countermodel
  → dd_bfmcs_restricted_tc
    → dd_fmcs_forward_F
      → rr_fwd_chain_forward_F  [PRIMARY BLOCKER]
  → dd_bfmcs_restricted_buc    [SECONDARY]
  → dd_bfmcs_restricted_fuc    [SECONDARY]
```

The secondary sorries (buc/fuc) are Until/Since coherence; these likely follow from
the quasimodel machinery in Quasimodel/ once forward_F is proved.

---

## Alternative Architectures Evaluated

### Architecture 1: Fold-Order Trick (Target-Last BX11 Processing)

**Concept**: In `enriched_fwd_fold_with_witness`, the direct witness changes to chi
(the right operand) when BX11 fires Case 3 (F(beta) ∧ chi). If target is always
processed LAST in the fold, then chi (the newly added formula) IS target at the final
step. Case 3 makes the direct witness chi = target, which is exactly what we need.

**Mathematical justification**:
BX11 (`temp_linearity_mcs`): given F(A) ∈ M and F(B) ∈ M, exactly one holds:
- Case 1: F(A ∧ B) ∈ M — both conjuncts resolve
- Case 2: F(A ∧ F(B)) ∈ M — A resolves, F(B) remains
- Case 3: F(F(A) ∧ B) ∈ M — F(A) remains, B resolves

In `enriched_fwd_fold_with_witness`, the direct witness is:
- Cases 1 and 2: direct witness stays as the LEFT element (beta's witness)
- Case 3: direct witness changes to chi (the RIGHT element = newly folded formula)

If target is the LAST formula folded (rightmost in the list), then at the final
step, chi = target. Whether Case 3 fires or not:
- Case 1 (F(beta ∧ target)): from beta ∧ target ∈ M', target ∈ M' by right conjunct
- Case 2 (F(beta ∧ F(target))): F(target) ∈ M'; but we need target ∈ M'. NOT sufficient.
- Case 3 (F(F(beta) ∧ target)): target is the direct witness. target ∈ M'. SUFFICIENT.

So this trick only works in Cases 1 and 3. In Case 2, F(target) is what we get,
not target itself. The direct witness remains left-biased.

However: there is a key asymmetry. At step m where target = psi (the formula with
F(psi) ∈ chain(n)):
- F(psi) ∈ chain(m) by `rr_fwd_chain_F_obligation_forward`
- target = psi is folded last in `enriched_fwd_fold_with_witness`
- `resolving_enriched_fwd_exists` applies BX11 with F(beta) ∈ M and F(psi) ∈ M
- At the LAST fold step: chi = psi

In Case 3: psi is the direct witness → psi ∈ chain(m+1). Done!
In Case 1: beta ∧ psi is the compound. From this, rce_imp gives psi ∈ chain(m+1). Done!
In Case 2: F(beta ∧ F(psi)) ∈ M. From beta ∧ F(psi) ∈ chain(m+1), we get F(psi) ∈ chain(m+1).
  But we need psi ∈ chain(m+1), not F(psi). Case 2 is the problem case.

**Critical question**: Can Case 2 be ruled out when F(psi) ∈ M?

Looking at `temp_linearity_mcs` (the underlying BX11 statement): given F(beta) ∈ M
and F(psi) ∈ M, the three cases correspond to the three conclusions of BX11. The
question is whether there's an additional derivation that rules out Case 2 when both
F(beta) ∈ M and F(psi) ∈ M (as opposed to F(beta) ∈ M and F(F(psi)) ∈ M).

In Case 2, the conclusion is F(beta ∧ F(psi)) ∈ M. But since F(psi) ∈ M and
phi_in_mcs_imp_F_phi gives F(F(psi)) ∈ M, BX11 applied to F(beta) ∈ M and F(psi) ∈ M
gives three cases depending on which ordering the Lindenbaum choice makes. We cannot
rule out Case 2 in general without additional constraints on the Lindenbaum choice.

**Verdict**: The fold-order trick reduces the problem from "some formula with F-obligation
is resolved" to "psi is resolved in Cases 1 and 3, but only F(psi) in Case 2." This is
strictly better than the current situation. However, Case 2 remains a gap. The trick is
worth trying (2 hours) as it may simplify the proof search significantly.

**Confidence**: Low-medium (35%). The Case 2 gap may require a separate argument.

### Architecture 2: Direct Consistency of the Enriched Resolving Seed

**Concept**: Prove that the seed `{psi} ∪ g_content(M) ∪ f_carry(M)` is consistent
when F(psi) ∈ M. This would allow a single forward step that BOTH resolves psi
(psi ∈ M') AND preserves all F-formulas (f_carry(M) ⊆ M').

The existing code already handles:
- `{psi} ∪ g_content(M)` is consistent when F(psi) ∈ M (via `forward_temporal_witness_seed_consistent`)
- `g_content(M) ∪ f_carry(M)` is consistent when M is MCS (via `enriched_seed_consistent`)

The target: `{psi} ∪ g_content(M) ∪ f_carry(M)` is consistent when F(psi) ∈ M.

**The prior counterexample** (from CanonicalModel.lean comment at line 503-506):
> Enriching the resolving seed with f_carry is INVALID: the enriched seed
> `{chi} union g_content(M) union f_carry(M)` can be inconsistent.
> Counterexample: G(F(alpha) -> neg psi) in M, F(alpha) in M, F(psi) in M.

Let me verify this counterexample:
- M contains: G(F(alpha) → ¬psi), F(alpha) = ¬G(¬alpha), F(psi) = ¬G(¬psi)
- f_carry(M) contains: F(alpha), F(psi)
- g_content(M) contains: F(alpha) → ¬psi (from G(F(alpha) → ¬psi) by BX1)
- Enriched seed for chi = psi: {psi} ∪ g_content(M) ∪ f_carry(M)
  Contains: psi, F(alpha) → ¬psi, F(alpha)
  From F(alpha) → ¬psi and F(alpha): ¬psi follows by MP.
  So {psi, ¬psi} ⊆ closure — INCONSISTENT. Counterexample confirmed.

**Is there a way to salvage this?** The counterexample uses G(F(alpha) → ¬psi) ∈ M.
This formula says "always, if alpha will eventually happen, then psi is false."
It is compatible with F(psi) ∈ M only if psi happens BEFORE alpha's eventuality is
resolved. The counterexample shows that when we add psi AND carry F(alpha) to the
same step, we create a contradiction with the G-formula.

This counterexample is decisive. The enriched resolving seed `{psi} ∪ g_content(M) ∪ f_carry(M)`
is not always consistent. **This avenue is closed.**

However: a weaker version might work. Instead of carrying ALL of f_carry(M), carry only
the F-formulas that are "compatible" with psi being in M'. That is, compute:

```
compatible_carry = {F(chi) ∈ f_carry(M) | {psi, F(chi)} ∪ g_content(M) is consistent}
```

The seed `{psi} ∪ g_content(M) ∪ compatible_carry` is consistent (psi ∪ g_content(M)
is consistent by hypothesis, and we add only consistent extensions). After Lindenbaum
extension to M', we have psi ∈ M', F-carry formulas that are compatible with psi, and
g_content(M) ⊆ M'. The incompatible F-carry formulas (like F(alpha) in the counterexample)
are dropped — but they can be recovered at later steps when psi is no longer the target.

**Problem**: The incompatible F-formulas may be permanently lost (G(¬chi) enters M')
for the same reason as the original obstacle. This selective carry does not solve
the termination argument.

**Verdict**: The enriched resolving seed is provably inconsistent in general. Selective
variants have the same termination obstacle. Closed.

### Architecture 3: Finite Model Property via Filtration

**Concept**: Instead of an infinite chain construction, use filtration to build a
finite model. For the formulas in the sigma-closure (extendedDeferralClosure phi),
the filtration quotient has finitely many worlds. Prove FMP holds for BX, then
derive completeness from FMP.

**What exists in the codebase**:
- `Filtration/SigmaOrdering.lean`: sigma_le, sigma_strict ordering predicates
- `Quasimodel/HintikkaPoint.lean`: HintikkaPoint over finite Sigma
- `Quasimodel/SubformulaClosure.lean`: subformulaClosure (finite closure)
- `Quasimodel/EnrichedClosure.lean`: enrichedClosure

**The FMP obstacle for temporal logic**: The classic result is that LTL (linear temporal
logic with U, S, G, H, F, P) does NOT in general have the finite model property under
the standard model class (dense linear orders over infinite time). A formula satisfiable
in some model is not necessarily satisfiable in a finite model.

BX (bimodal temporal-modal logic) inherits this: G(phi) → F(phi) would be vacuously
true in a one-step model (no future), defeating the intended semantics. The canonical
completeness proofs for LTL-like systems use infinite models (typically omega-sequences
for discrete time, or dense chains for dense time).

The existing `Filtration/` directory has machinery for RESTRICTED models (sigma-restricted
ordering), not for full finite models. These are designed to support the quasimodel
approach, not FMP.

**The bi-quasimodel variant**: There is a notion of "quasi-FMP" where satisfiability
in any model implies satisfiability in a quasi-finite model (a finite "quasimodel" with
defects that can be unrolled). The Quasimodel/ directory IS this approach — it constructs
finite Hintikka structures. The forward_F problem in the quasimodel setting translates to:
in a Hintikka structure, if F(psi) holds at a Hintikka point, does some successor have psi?

The answer in the quasimodel setting is the SAME obstacle: the one-step relation
`hintikka_step` (Construction.lean:40-52) requires G-propagation and Until-discharge
but does NOT require F-eventuality resolution at each step. F(psi) at a Hintikka
point means "psi eventually" but the finite quasimodel may loop without reaching psi.

**Verdict**: FMP does not hold for BX with the standard temporal semantics. The
filtration/quasimodel direction transforms the obstacle but does not eliminate it.
Closed as an alternative to the chain approach.

### Architecture 4: Tree Unraveling with Eventuality Tracking

**Concept**: Instead of a linear chain, build a tree of MCS where each branch
satisfies its temporal obligations. A formula F(psi) at a node forces psi to appear
on every branch above that node. This avoids the "wrong successor" problem.

**Formalization challenge**: Tree models for temporal logic with PAST operators
are unusual. BX has H (historical necessity) and P (past possibility), which require
a unique past for each world. In a tree model, the past of any node is the unique
path from the root to that node — so tree models DO work for temporal-modal logics.

**Standard construction** (Goldblatt 1992, Chapter 6 for tense logics):
1. Take a consistent formula phi
2. Build the "canonical tree" where nodes are finite paths through the canonical model
3. At each leaf, use BX4 (connect_past: phi → H(F(phi))) to ensure F-eventualities
   are carried along all paths
4. Prove that eventualities are discharged along every infinite branch

**Why this does not obviously help**: The tree construction still requires, at each
step, extending an MCS N containing F(psi) to a successor MCS M with psi ∈ M. This
is the same Lindenbaum choice problem. The tree structure records the choice but does
not constrain it.

One difference: in a tree, when F(psi) is at node v and psi is not resolved at
immediate successor v', we create MULTIPLE children of v' — one where F(psi) is
carried (consistent: F(F(psi)) → F(psi) by FF_imp_F) and one where psi is resolved
(consistent: {psi} ∪ g_content(N) by forward_temporal_witness_seed_consistent).
Then the axioms of BX force EVERY branch to eventually have psi (because F(psi) persists
until psi is true, and the branch cannot go on forever deferring it — but wait,
this is exactly the termination argument needed for forward_F!).

**The tree termination argument**:
- Each node in the tree corresponds to one step of the chain
- A "defective" branch is one where F(psi) holds at the current node but psi has
  not appeared in the branch so far
- BX11 (`temp_linearity_mcs`) ensures that at each resolving step, at least one formula
  gets directly resolved (not just F-protected)
- Over k = |sigma_list| steps (one full round-robin cycle), every formula in sigma is
  the scheduled target at least once
- If psi is scheduled at step m and F(psi) ∈ chain(m), then at the resolving step,
  one of the three BX11 cases applies. The tree branches: in Case 1, psi is resolved
  directly. In Cases 2/3, psi or beta is directly resolved.

**Key insight**: In the TREE model, we can branch at each BX11 ambiguity. The tree
is finite-branching (at most 3 choices per BX11 application). An infinite branch
must contain an infinite sequence of BX11 Cases 2 (F(beta ∧ F(psi))) or Cases 3
(F(F(beta) ∧ psi)). In Cases 1 and 3 for psi's visit step, psi IS directly resolved.
In Case 2 for psi's visit step, psi remains F-protected. But Case 2 means the compound
becomes F(beta ∧ F(psi)) — psi's F-obligation is in the RIGHT conjunct. At the NEXT
visit to psi (step m + |sigma_list|), the same applies. If Case 2 fires infinitely
often, the tree branch has F(psi) at every step and psi is never resolved.

This is still the same obstacle in tree form. An infinite branch where F(psi) ∈ chain(n)
for all n but psi ∉ chain(s) for any s exists. Such a branch is INVALID (BX-inconsistent
in the limit) but that invalidity is what we're trying to prove.

**Verdict**: Tree unraveling transforms the problem but does not solve it. The
termination argument requires exactly the same invariant as `rr_fwd_chain_forward_F`.
Medium cost (~15 hours) with no clear advantage. Not recommended.

### Architecture 5: Deficiency-Based Well-Founded Induction

**Concept**: Define a deficiency measure on a chain that strictly decreases, then
use well-founded induction to find a finite witness.

The existing deficiency analysis in `Filtration/DefectChain.lean` defines:
```
sigma_defect_count w Sigma = |{f ∈ Sigma | f = phi U psi ∈ w.formulas ∧ psi ∉ w.formulas}|
```
This counts Until-defects (proven bounded by |Sigma|).

**Attempt for F-defects**: Define:
```
f_defect_count M sigma_list = |{psi ∈ sigma_list | F(psi) ∈ M ∧ psi ∉ M}|
```

The problem from `rr_fwd_chain_forward_F` comments (lines 1265-1272):
> The F-obligation set {χ ∈ sigma_list | F(χ) ∈ chain(m)} is STABLE: it never
> grows (by `no_new_f_defects`) and never shrinks (because χ ∈ M → F(χ) ∈ M
> for any MCS M, by contrapositive of temp_t). This means:
> - Every formula that ever gains an F-obligation keeps it forever
> - The "defect set" {χ | F(χ) ∈ chain(m) ∧ χ ∉ chain(m)} can fluctuate:
>   formulas can be resolved (χ ∈ chain(m+1)) but then lost again at a later
>   step (χ ∉ chain(m+2) while F(χ) persists)
> So the defect count is NOT a valid well-founded measure for induction.

This observation is correct. After psi is resolved at step m+1 (psi ∈ chain(m+1)),
at step m+2 the target is a different formula chi. The resolving step for chi uses
the seed {chi} ∪ g_content(chain(m+1)), which does NOT include psi or F(psi).
The Lindenbaum extension of chain(m+2) may not include psi. Since F(psi) ∈ chain(m+1)
(by phi_in_mcs_imp_F_phi, since psi ∈ chain(m+1)), and F(psi) ∈ g_content only if
G(F(psi)) ∈ chain(m+1) (not guaranteed), psi can be lost.

The defect count fluctuates: it decreases when psi is resolved, then increases again
when psi is lost. No monotone measure exists over the chain.

**Potential fix**: Use a "never-resolved" count — count formulas that have NEVER
been resolved across all steps so far. This is strictly decreasing: once psi is
resolved at ANY step, it is removed from the never-resolved count permanently.
But "never-resolved" requires tracking history, which is not a property of a single
chain state — it depends on the entire chain prefix.

To make this work, the chain definition would need to carry the history:
`rr_fwd_chain_with_history M₀ h₀ sigma_list n : {M : Set Formula // SetMaximalConsistent M} × Set Formula`
where the second component is the set of formulas "ever resolved" up to step n.

Then the defect measure for `forward_F` would be:
```
never_resolved(n, psi) = psi ∉ ever_resolved(n)
```
This is monotone: once resolved, stays resolved. But proving forward_F from this
requires showing that psi is eventually in ever_resolved(n), which is essentially
the same as proving forward_F directly.

**Verdict**: Deficiency-based induction does not provide a termination argument
without the enriched seed consistency that was already ruled out. Closed.

---

## Recommended Approach

### Primary Recommendation: Fold-Order Trick (2 hours, 35% confidence)

Modify `enriched_fwd_fold_with_witness` and `enriched_fwd_step` so that the target
formula is always the LAST (rightmost) element folded. This ensures:
- BX11 Case 3 (which puts the right element as direct witness) always selects target
  as the direct witness when it fires
- BX11 Case 1 (F(beta ∧ target)) gives target ∈ M' by right conjunct extraction

The only failure case is BX11 Case 2 (F(beta ∧ F(target))), which gives F(target) ∈ M'
rather than target ∈ M'. This case fires when the temporal ordering between beta and
target happens to put target "later" in some sense.

**Lean implementation**: In `rr_fwd_seed` and `enriched_fwd_step`, replace:
```lean
let others := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
resolving_enriched_fwd_exists h_mcs target h_F others ...
```
with:
```lean
let others := (sigma_list.filter (fun χ => χ ≠ target ∧ Formula.some_future χ ∈ M))
resolving_enriched_fwd_exists h_mcs (others.headD target) ... [... , target]
```
where target is moved to the last position in the fold. The fold processes others
first, accumulating the compound, then folds in target last. By `enriched_fwd_fold_with_witness`,
the direct witness at the last step is:
- target if Case 1 (F(accum ∧ target)) or Case 3 (F(F(accum) ∧ target))
- accum's direct witness (carried through) if Case 2

In Case 1: target ∈ M' by rce_imp(accum, target)(conjunction ∈ M' → right conjunct ∈ M').
In Case 3: target is the new direct witness, so target ∈ M'.
In Case 2: F(target) ∈ M' (from rce_imp applied to F(accum ∧ F(target))). Not resolved.

**New insight for Case 2**: If Case 2 fires at step m (giving F(target) ∈ chain(m+1)),
then F(target) ∈ chain(m+2) by persistence. At step m+k (next visit to target), the
same argument applies. If Case 2 fires every visit, we have an infinite sequence where
F(target) ∈ chain(n) for all n but target ∉ chain(n) for any n.

But this contradicts BX-consistency in a deep sense: target ∈ M iff F(target) ∈ M
(by phi_imp_F_phi + BX1). Wait — this is NOT a contradiction. F(target) ∈ M means
"eventually target" but target might never be in the MCS. The BX axioms do not require
every F-formula to be witnessable within the Lindenbaum construction itself.

**Verdict**: The fold-order trick reduces the work but Case 2 remains a genuine gap.
However, it may be that in the RESOLVING step for target specifically (when F(target)
∈ chain(m)), BX11 Case 2 is impossible. Case 2 gives F(accum ∧ F(target)) ∈ M.
From F(accum) ∈ M and F(target) ∈ M, if we could show that Cases 1 or 3 MUST hold
when target is the current schedule target, we would be done. This requires additional
mathematical investigation.

### Secondary Recommendation: Analyze Case 2 Impossibility at Visit Steps

The key mathematical question that would unlock forward_F without any infrastructure
changes:

> When F(target) ∈ M and target is scheduled (the round-robin visit step for target),
> must BX11 Case 2 be impossible?

BX11 Case 2 gives F(beta ∧ F(target)) ∈ M (from F(beta) ∈ M and F(target) ∈ M).
This says "eventually, both beta and then target will happen." Combined with
F(target) ∈ M (just "eventually target"), can we derive a contradiction?

F(beta ∧ F(target)) → F(F(target)) by F-monotonicity (right projection).
F(F(target)) → F(target) by FF_imp_F.
So F(beta ∧ F(target)) → F(target). No contradiction.

What if we use the fact that target is BOTH in the schedule (F(target) ∈ chain(m))
and target ∈ sigma_list? There is no axiom that distinguishes the scheduled step
for target from any other step.

**Verdict**: Case 2 impossibility cannot be derived from BX axioms alone. The Lindenbaum
choice can always select Case 2. No easy fix here.

---

## Evidence and Supporting Analysis

### What the Quasimodel Infrastructure Provides

The Quasimodel/ directory (2,289+ lines, all sorry-free) contains exactly the tools
needed for a SEPARATE completeness proof route. Specifically:

- `HintikkaPoint`: Finitary approximation to MCS over subformula closure
- `hintikka_step`: One-step relation (G-propagation, H-backward, Until-discharge)
- `defect_count`: Bounded termination measure for Until chains

The quasimodel approach for Until worked because Until-defects have a FINITE discharge
property: by BX5 (`self_accum_until`: phi U psi → (phi ∧ phi U psi) U psi), the Until
formula carries forward with a stronger guard. The defect count decreases at each step.

For F-formulas, the analogous property would need: at each step where F(psi) holds and
psi does not, the Hintikka step introduces a SUCCESSOR where psi holds. This is
exactly what `hintikka_step` does NOT guarantee (it only propagates G-formulas,
not F-formulas). Extending `hintikka_step` to include F-resolution would require
modifying the quasimodel definition — a significant but potentially tractable change.

### The BX12 Approach (Approach 21 from Prior Research)

The idea: BX12 gives F(psi) → Top U psi (where Top = ¬bot). Then
`bx_until_eventuality_resolution` (Frame.lean:622-644, sorry-free) gives a BXPoint v
with psi ∈ v.formulas and bx_le chain(n) v. The obstacle: v is an abstract BXPoint
from Lindenbaum, not necessarily a chain member.

This does not solve the chain-embedding problem. Closed.

### No New Inconsistency Arguments

The enriched seed `{psi} ∪ g_content(M) ∪ f_carry(M)` is provably inconsistent in
general (counterexample confirmed above). No variant that adds psi to f_carry can be
shown consistent without additional constraints on M.

---

## Confidence Levels

| Approach | Status | Confidence |
|----------|--------|------------|
| Fold-order trick | Worth trying (2h) | 35% |
| Enriched seed consistency | Closed (counterexample) | 0% |
| FMP via filtration | Closed (LTL has no FMP) | 5% |
| Tree unraveling | Same obstacle | 10% |
| Deficiency induction | Closed (measure fluctuates) | 5% |

**Overall assessment**: The fold-order trick is the only alternative approach
with non-negligible probability of closing forward_F with minimal infrastructure
cost. If Case 2 can be ruled out at visit steps (which I believe requires a
mathematical insight not yet identified), it succeeds immediately.

The Plan v18 approach (ordered-discharge chain with never-resolved count) remains
the most structurally sound path at ~55-65% confidence, as established in prior
research rounds. No alternative architecture examined here provides a clearly
superior path.

---

## Actionable Recommendations

1. **Try fold-order trick first (2 hours)**: Modify `enriched_fwd_fold_with_witness`
   to process target last. If Case 2 does not fire at visit steps in practice (or if
   an additional BX-derivation rules it out), this closes forward_F with zero new
   infrastructure.

2. **Investigate Case 2 impossibility (2 hours)**: Check whether there is a BX axiom
   or derivation that prevents F(accum ∧ F(target)) ∈ M when F(target) ∈ M and M is
   an MCS in the canonical chain at a visit step for target. This is the key open
   mathematical question.

3. **If both fail, proceed with Plan v18**: The ordered-discharge chain with history
   tracking is the most rigorous path to closing rr_fwd_chain_forward_F.
