# Teammate B Findings: Alternative Proof Architectures (Round 22)

**Task**: 93 - Complete BXCanonical embedding
**Role**: Alternative approaches — bypass or redefine chain construction
**Date**: 2026-04-16
**Round**: 22

## Summary

This report re-examines the alternative architecture question with fresh eyes, building
directly on the round 21 synthesis (report `21_team-research.md`) and the codebase as it
currently stands. The round 21 synthesis confirmed:

1. Five alternatives were evaluated and all closed (FMP, tree unraveling, enriched seed,
   deficiency induction, BX12 reformulation).
2. The fold-order trick (target-last processing) is the one low-cost intervention not yet
   tested, with 35% confidence.
3. The buc/fuc sorries are closeable independently at 85% confidence.
4. Plan v18 (ordered-discharge chain with never-resolved count) remains the primary path.

This round focuses on three specific questions that the round 21 synthesis identified as
open gaps:

- **Gap 1**: Can the fold-order trick succeed at visit steps despite Case 2?
- **Gap 2**: Is there a structural reason why `resolving_enriched_fwd_exists` can be
  strengthened to guarantee target resolution (not just some formula's resolution)?
- **Gap 3**: Is there a way to exploit the dd_bfmcs families structure to bypass the chain
  construction entirely for the restricted coherence properties?

---

## Key Findings

### Finding 1: The Fold-Order Trick Has a Provably Unkillable Case 2

Reading `enriched_fwd_fold_with_witness` (RootScopedChain.lean:257-361) carefully:

The fold processes formulas left-to-right. At each step, BX11 (`temp_linearity_mcs`)
is applied between the current accumulated compound `beta` and the next formula `chi`.
Three cases:
- Case 1: F(beta ∧ chi) — witness preserved
- Case 2: F(beta ∧ F(chi)) — witness preserved, chi gets F-wrapped
- Case 3: F(F(beta) ∧ chi) — witness CHANGES to chi

If target is the LAST formula (rightmost), then at the final fold step, chi = target.
In Case 3: witness changes to target — target is directly resolved. GOOD.
In Case 1: beta ∧ target ∈ M' → target ∈ M' by rce_imp. GOOD.
In Case 2: beta ∧ F(target) ∈ M' → F(target) ∈ M' by rce_imp. BAD (target not direct).

The critical new analysis: **What does Case 2 mean structurally?**

Case 2 at the final fold step gives: `F(compound ∧ F(target)) ∈ M` where `compound` is
the result of folding all other formulas. This says: "there is a future time t where
compound holds AND target will hold even later."

Now consider the seed `{compound ∧ F(target)} ∪ g_content(M)` extended by Lindenbaum
to M'. We get compound ∈ M' and F(target) ∈ M'. So target ∉ M' (it may or may not be),
but F(target) ∈ M'. At the next visit step (step m + |sigma_list|), F(target) ∈ chain(m+1)
by `rr_fwd_chain_F_obligation_forward`. The same fold-with-target-last applies again.

The key question: can Case 2 fire infinitely often? Yes — there is no axiom that prevents
this. Case 2 from BX11 represents a genuine semantic possibility: there exist MCS contexts
where compound will happen BEFORE target. In that context, the Lindenbaum extension choosing
F(compound ∧ F(target)) is correct. No BX axiom rules this out.

**Conclusion**: The fold-order trick eliminates Case 3 displacement but NOT Case 2 deferral.
Case 2 can fire infinitely at every visit step, permanently deferring target. This confirms
the round 21 analysis: the fold-order trick is a partial fix (reduces failure modes from 2
to 1) but does not close forward_F.

**Critical new observation**: However, if Case 2 fires at visit step m (giving F(target) ∈
chain(m+1)), then F(compound ∧ F(target)) ∈ chain(m). This means compound's witness comes
before target's witness in an honest linear ordering. But at visit step m + |sigma_list|,
compound may not have F-obligation anymore (compound is not in sigma_list — it's a complex
conjunction), so the next fold may behave differently. This chain of reasoning does NOT
easily lead to a contradiction — it is exactly the kind of argument that prior research
found unprovable.

### Finding 2: The `resolving_enriched_fwd_exists` Strengthening Requires Seed Control

The proof of `resolving_enriched_fwd_exists` (lines 366-398) uses `enriched_fwd_fold_with_witness`
to compute a compound β', then calls `forward_temporal_witness_seed_consistent` to get the
seed `{β'} ∪ g_content(M)`, extends by Lindenbaum to M'. The direct witness w ∈ M' is
guaranteed by the fold.

The key constraint: w could be target OR any formula in others. The proof guarantees some
formula with F-obligation is directly resolved — it does NOT guarantee target specifically.

**New approach examined**: Can we define a variant where w = target is forced?

For w = target, we need the fold to produce a compound β' such that:
(a) F(β') ∈ M
(b) For any M' extending {β'} ∪ g_content(M): target ∈ M'

Property (b) means β' → target is a theorem (since β' ∈ M' and M' is MCS-closed under
derivation). If β' → target is a theorem, then β' must be inconsistent or β' is a
stronger version of target.

The only way to guarantee β' → target from the fold is if the fold produces β' = target ∧ ...
(making target a conjunct). This requires the fold to always produce Case 1 or Case 3 for
target — which is exactly what we cannot guarantee (Case 2 is always possible).

**Alternative strengthening**: Can we modify `resolving_enriched_fwd_exists` so that when
target is the desired witness, we use `discharge_single_step` instead of the fold?

`discharge_single_step` (lines 975-982) directly gives an M' with target ∈ M' and g_content(M) ⊆ M'.
This always works when F(target) ∈ M. The issue: M' from `discharge_single_step` does NOT
provide `chi ∈ M' ∨ F(chi) ∈ M'` for other formulas in sigma_list. This is the F-preservation
gap.

**Crucial observation**: The downstream use of `enriched_fwd_step_preserves` in the proof of
`rr_fwd_chain_F_obligation_persists` (lines 1134-1142) requires: for each psi ∈ sigma_list
with F(psi) ∈ chain(n), either psi ∈ chain(n+1) OR F(psi) ∈ chain(n+1). This disjunctive
guarantee is what makes F-obligation constancy provable.

If we replace the fold with `discharge_single_step` at target's visit step, we lose the
preservation guarantee for other formulas. Then `rr_fwd_chain_F_obligation_persists` fails
for non-target formulas at that step.

**The only way to use `discharge_single_step` for target**: Prove that F-obligation constancy
follows from SOME SEPARATE ARGUMENT at the target's visit step, not from the fold. For example:
if chi ∈ sigma_list and F(chi) ∈ chain(m) where m is target's visit step, then:
- If chi = target: F(target) ∈ chain(m) and target ∈ chain(m+1) by discharge_single_step. Then F(target) ∈ chain(m+1) by phi_in_mcs_imp_F_phi. GOOD.
- If chi ≠ target: F(chi) ∈ chain(m). We need chi ∈ chain(m+1) OR F(chi) ∈ chain(m+1).

For chi ≠ target: the seed `{target} ∪ g_content(chain(m))` used by discharge_single_step
does NOT include F(chi). So chain(m+1) from discharge_single_step might have G(¬chi) in it
(via Lindenbaum), making F(chi) ∉ chain(m+1). This is the same problem.

**Verdict on Finding 2**: No known strengthening of `resolving_enriched_fwd_exists` avoids
the tension between target resolution and F-preservation for other formulas. The enriched
seed consistency obstacle remains the root cause.

### Finding 3: The dd_bfmcs Structure Offers No Bypass for Restricted TC

The `dd_bfmcs_restricted_tc` (line 1382) proof needs: for each FMCS in `dd_bfmcs.families`,
if F(psi) ∈ fam.mcs(t) for psi ∈ deferralClosure(root), then ∃ s > t with psi ∈ fam.mcs(s).

Each FMCS in `dd_bfmcs.families` is a `shifted_dd_fmcs N h_N sigma_list s` for some MCS N
with the same box-content as M₀. The `shifted_dd_fmcs` has mcs(t) = `dd_chain N h_N sigma_list (t-s)`,
which is `rr_fwd_chain N h_N sigma_list (t-s).toNat` for t ≥ s.

So `dd_bfmcs_restricted_tc` reduces to `rr_fwd_chain_forward_F` for each N in the families.
There is no structural shortcut: every family uses the round-robin chain as its time-indexed MCS,
and every family faces the same forward_F obstacle.

**Could the BFMCS modal coherence help?** The `modal_forward` property says: if box(phi) ∈
fam.mcs(t), then phi ∈ fam'.mcs(t) for all fam' in families. Box formulas are stable (same
in all chain steps, proved by `box_stable_dd_chain`). But F(psi) is NOT a box formula, so
modal coherence does not help.

**Verdict on Finding 3**: The dd_bfmcs structure provides no bypass for restricted_tc. The
families structure is only useful for the modal (box) coherence conditions, not for temporal
(F/P) coherence.

### Finding 4: A New Analysis of the buc/fuc Sorries

The round 21 synthesis (Finding 3) identified that `dd_bfmcs_restricted_buc` and
`dd_bfmcs_restricted_fuc` are likely closeable at 85% confidence using quasimodel infrastructure.
This finding warrants deeper analysis.

**What `restricted_backward_until_since_coherent` requires** (from BFMCS definition):
For psi ∈ deferralClosure(root), if (phi U psi) ∈ fam.mcs(t), then:
∃ s ≥ t with psi ∈ fam.mcs(s) and forall t ≤ u < s, phi ∈ fam.mcs(u).

**What the quasimodel provides**:
`bx_until_eventuality_resolution'` (LocusControl.lean): Given (phi U psi) ∈ w.formulas and
psi ∉ w.formulas for BXPoint w, there exists BXPoint v with bx_le w v and psi ∈ v.formulas
and phi ∈ w.formulas.

The gap: `bx_until_eventuality_resolution'` works over BXPoints (abstract MCS with bx_le
ordering), not over the dd_chain (integer-indexed chain). To use it for dd_bfmcs, we need:
1. Turn the chain MCS at time t into a BXPoint (trivial: BXPoint = {formulas: chain(t), is_mcs: ...})
2. Apply `bx_until_eventuality_resolution'` to get BXPoint v with psi ∈ v.formulas
3. Show that v corresponds to some chain index s ≥ t

Step 3 is the gap. The abstract BXPoint v is constructed via Lindenbaum, not as a specific
chain member. `bx_le chain_point_t v` holds (g_content(chain(t)) ⊆ v.formulas by the
Lindenbaum construction), but v may not equal chain(s) for any s.

**New approach for buc**: Instead of using the abstract `bx_until_eventuality_resolution'`,
prove Until eventuality resolution DIRECTLY for the dd_chain using the chain's structure.

The key insight: (phi U psi) ∈ chain(t) implies F(psi) ∈ chain(t) by `defect_step_F_psi`
(DefectChain.lean:76). Then by `rr_fwd_chain_forward_F` (once proved!), there exists s > t
with psi ∈ chain(s). For the guard condition (phi ∈ chain(u) for t ≤ u < s): use g_content
propagation — (phi U psi) ∈ chain(t) propagates forward via g_content? No — (phi U psi) is
NOT a G-formula.

Wait: actually BX9 says (phi U psi) → (psi ∨ phi), and BX4/BX5 give propagation properties.
Specifically, if (phi U psi) ∈ chain(t) and psi ∉ chain(t), then phi ∈ chain(t) (by BX9
+ defect_step_phi). But for subsequent chain steps t < u < s, we need phi ∈ chain(u).

**Critical insight for buc**: The enriched forward step already guarantees `chi ∈ M' ∨ F(chi) ∈ M'`
for each chi ∈ sigma_list with F(chi) ∈ M. Since F(psi) ∈ chain(t) and psi ∈ sigma_list
(required by restricted coherence: psi ∈ deferralClosure(root) ⊆ sigma_list), the chain
guarantees F(psi) persists (by `rr_fwd_chain_F_obligation_forward`). But what about phi?

phi may or may not be in sigma_list. If phi ∈ sigma_list, then `enriched_fwd_step_preserves`
gives F(phi) ∈ chain(u) for all u ≥ t (since F(phi) ∈ chain(t) follows from phi ∈ chain(t)
by phi_in_mcs_imp_F_phi — but wait, phi ∈ chain(t) is only known if phi U psi ∈ chain(t)
and psi ∉ chain(t), which gives phi ∈ chain(t) by defect_step_phi). So phi ∈ chain(t) and
thus F(phi) ∈ chain(t). But we need phi ∈ chain(u) for t ≤ u < s, not F(phi).

**The buc gap is different from forward_F**: For Until coherence, we need to show EVERY
intermediate step u has phi ∈ chain(u), not just SOME step. This is a stronger requirement
than forward_F (which is existential). The guard condition phi ∈ chain(u) for all t ≤ u < s
requires that phi is propagated through ALL intermediate steps, which is provable only if
phi has a G-formula form (i.e., phi = G(something)) or via the structural property of the chain.

**Actually**: looking at this more carefully, the semantics of Until in this context is:
`phi U psi` is true at t iff ∃ s ≥ t: psi holds at s AND forall t ≤ u < s: phi holds at u.

For the restricted_backward_until_since_coherent property of dd_bfmcs, we need:
if (phi U psi) ∈ dd_fmcs.mcs(t), then the BFMCS truth of (phi U psi) at t holds,
meaning the above semantic condition is satisfied in the parametric canonical model.

But the truth lemma (which connects MCS membership to semantic truth) already handles
Until via the restricted coherence infrastructure. The `restricted_backward_until_since_coherent`
predicate is defined in the BFMCS structure and must satisfy:
∀ t, ∀ phi psi, (phi U psi) ∈ fam.mcs(t) → phi ∈ deferralClosure(root) → psi ∈ deferralClosure(root)
→ [the Until eventuality resolution condition]

To prove this, the approach is:
1. (phi U psi) ∈ chain(t) → F(psi) ∈ chain(t) (by BX10 via defect_step_F_psi)
2. F(psi) ∈ chain(t) → ∃ s > t with psi ∈ chain(s) (by rr_fwd_chain_forward_F — NEEDS the sorry)
3. For guard: (phi U psi) ∈ chain(t) → G(P(phi U psi)) ∈ chain(t) (by defect_step_connect)
   and P(phi U psi) ∈ chain(u) for u ≥ t (by g_content propagation of G(P(phi U psi)))
   and phi U psi ∈ chain(u) (by some backward argument)... this is getting complex.

Actually: there is a simpler route. If (phi U psi) ∈ chain(t) and for all t ≤ u < s, psi ∉ chain(u),
then phi ∈ chain(u) for those u. But proving phi ∈ chain(u) from the chain structure is hard
because phi is not necessarily in sigma_list and the chain doesn't track general MCS members.

**Revised assessment of buc/fuc**: These sorries are dependent on forward_F in the following way:
- buc requires showing the Until witness s exists (needs forward_F for F(psi)) AND
- buc requires showing the guard phi holds at each intermediate step (needs a separate argument)

The 85% confidence from round 21 (Teammate D) may be optimistic. The guard condition for
buc is NOT addressed by the existing quasimodel infrastructure directly. However, looking at
the actual definition of `restricted_backward_until_since_coherent` in the BFMCS structure
is necessary to confirm this.

### Finding 5: Potential New Alternative — Two-Step Chain Modification

A previously unexamined approach: instead of modifying the chain to resolve target at visit
step m, prove forward_F by showing that among all formulas in sigma_list with F-obligations
at step n, at least ONE is resolved at each full round-robin cycle of |sigma_list| steps.
Then by induction on the number of remaining formulas to resolve, ALL formulas are eventually
resolved.

**Formalization**: Define the "never-resolved set" NRS(n) = {psi ∈ sigma_list | F(psi) ∈ chain(n)
∧ psi ∉ chain(k) for all n ≤ k ≤ n + m*|sigma_list|}. As m increases, if NRS shrinks by at
least 1 formula per full round-robin cycle, then NRS becomes empty in ≤ |sigma_list| full
cycles, meaning every formula is eventually resolved.

The question: is it provable that at least ONE formula from sigma_list is resolved per
|sigma_list| steps?

**Analysis**: By `enriched_fwd_step_resolves_one`, at each resolving step (when F(target) ∈ M
for the current target), at least one formula with F-obligation is directly resolved. Over
|sigma_list| steps, every formula in sigma_list is the target at least once (by `rrSchedule_visits`).
So at each of the ≤ |sigma_list| resolving steps, some formula is resolved.

But: the same formula could be resolved multiple times while another formula is never resolved.
The "at least one resolved per step" guarantee does NOT imply "each formula eventually resolved"
without the monotonicity of NRS.

And NRS is NOT monotone: as noted in the round 17 report and the comments in RootScopedChain.lean
(lines 1265-1272), "formulas can be resolved (chi ∈ chain(m+1)) but then lost again at a later
step (chi ∉ chain(m+2) while F(chi) persists)." So NRS can GROW between cycles.

**Verdict**: The two-step chain approach (per-cycle discharge) fails for the same reason as
deficiency induction. Closed.

---

## Recommended Approach

### Primary Recommendation: Fold-Order Trick with Precise Case 2 Analysis (Tier 1)

The fold-order trick (processing target LAST) is still the highest-probability low-cost
intervention. My updated analysis (Finding 1) confirms:
- Cases 1 and 3 are resolved by the trick
- Case 2 remains a gap

However, there is one additional angle worth testing: **Does Case 2 firing at a visit step
imply an eventual Case 1 or Case 3?**

When Case 2 fires at visit step m (giving F(compound ∧ F(target)) ∈ chain(m)), we get:
- F(target) ∈ chain(m+1) (by rce_imp from compound ∧ F(target) ∈ chain(m+1))
- The new compound at step m+1 will involve target being folded at the END again
- BX11 between the new accumulated compound beta' and F(target): three cases again
  - Case 1': F(beta' ∧ F(target)) ∈ chain(m+1) → F-protected, Case 2 fires again
  - Case 2': this would be F(beta' ∧ F(F(target))) ∈ chain(m+1), using FF_imp_F → F(target)
  - Case 3': F(F(beta') ∧ F(target)) ∈ chain(m+1), then target is F-wrapped twice

Wait — at step m+1, target is NOT the scheduled formula. The fold uses ALL formulas in sigma_list
with F-obligations, and the schedule determines which is TARGET (the primary argument to the fold).
Target's next visit step is m + |sigma_list|. Between visits, target appears only in "others".

This means Case 2 at visit step m leaves F(target) ∈ chain(m+1), and between m+1 and the
next visit m + |sigma_list|, target's F-obligation is maintained (by `rr_fwd_chain_F_obligation_forward`),
but target may not be resolved at intermediate steps (those steps target different formulas).

**The fold-order trick gives exactly this guarantee at EVERY visit step**: target is in
Cases 1 or 3 (resolved) OR Case 2 (F-protected for next cycle). If Case 2 fires at every
visit step, target is never resolved. This is still the core problem.

**Confidence for fold-order trick**: 35% (unchanged from round 21 — no new information
closes the Case 2 gap mathematically).

### Secondary Recommendation: Plan v18 Ordered-Discharge Chain (Tier 2)

The Plan v18 approach — replacing `enriched_fwd_step` with a `target_resolving_fwd_step`
that uses `discharge_single_step` and a "never-resolved count" history — remains the most
structurally sound path. This was established in rounds 18-21 and is unchanged.

Key clarification from Finding 2: The never-resolved count must be part of the CHAIN STATE
(carried as an additional argument), not a property of a single chain step. The chain becomes:

```
rr_fwd_chain_with_history M₀ h₀ sigma_list : (n : Nat) →
  { M : Set Formula // SetMaximalConsistent M } ×
  { ever_resolved : Finset Formula // ever_resolved ⊆ sigma_list.toFinset }
```

The termination argument is: `sigma_list.length - ever_resolved.card` strictly decreases
whenever a new formula is resolved (enters ever_resolved for the first time). Since this
count decreases by at least 1 per "true resolution event" and is bounded below by 0,
the chain must resolve every formula with F-obligation within |sigma_list| true resolution
events.

The cost: ~30 downstream theorems need re-proof, 25-35 hours total.

### Independent Recommendation: Close buc/fuc via Restricted Coherence Analysis (Tier 1)

Finding 4 identifies that buc/fuc depend on forward_F for the witness existence part
(∃ s with psi ∈ chain(s)) but the guard part (phi ∈ chain(u) for intermediate u) requires
a separate argument. The guard condition may be provable from the chain structure independently:

**Guard argument sketch**: If (phi U psi) ∈ chain(t) and psi ∉ chain(u) for t ≤ u < s, then
by BX9 (Until elimination: phi U psi → psi ∨ phi) applied at each u, phi ∈ chain(u) follows.
But this requires proving psi ∉ chain(u) as a hypothesis — which is exactly what we'd be
using as an induction hypothesis.

Actually the parametric truth lemma handles Until: if (phi U psi) ∈ fam.mcs(t) AND the
truth lemma holds for phi and psi (by induction), then the Until condition holds semantically.
So the buc/fuc sorries may reduce to: prove that the parametric truth lemma's Until case
is satisfied by the dd_bfmcs construction. This is handled by `fully_restricted_parametric_representation_from_neg_membership` if restricted coherence holds.

**Simpler path for buc**: If forward_F is proved (reducing active sorries to 5, then 4 via
backward_P and restricted_tc), then buc/fuc follow from the quasimodel infrastructure via:
1. (phi U psi) ∈ chain(t) → F(psi) ∈ chain(t) (by defect_step_F_psi)
2. F(psi) ∈ chain(t) → ∃ s > t with psi ∈ chain(s) (by forward_F)
3. (phi U psi) ∈ chain(t) → (phi U psi) ∈ chain(u) for each t ≤ u (this needs G(P(phi U psi)) ∈ chain(t) which... hmm, G(P(X)) is the connect_future axiom output — yes, `defect_step_connect` gives G(P(phi U psi)) ∈ chain(t), and then by g_content propagation, P(phi U psi) ∈ chain(u) for u ≥ t, and from P(phi U psi) ∈ chain(u) and backward_H propagation, phi U psi ∈ chain(u-1)... this is getting complicated)

**The cleanest path for buc/fuc**: The restricted coherence properties may follow more easily
from the parametric truth lemma machinery once forward_F is closed, because the truth lemma
itself handles Until/Since in terms of forward_F and backward_P. Attempting buc/fuc
independently (before forward_F) requires reconstructing the Until semantics argument
from chain primitives, which is equivalent effort to what the truth lemma already does.

**Revised confidence for buc/fuc independent closure**: 55% (reduced from 85% — the guard
condition requires careful handling that the round 21 analysis underestimated).

---

## Evidence and Code Examination

### Code structure of the sorry sites

The sorry at line 1391 (`dd_bfmcs_restricted_buc`):
```lean
theorem dd_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_backward_until_since_coherent root := by
  sorry
```

The field `restricted_backward_until_since_coherent` is defined in BFMCS (Bundle/UntilSinceCoherence.lean).
This needs examination to understand exactly what proof obligation it creates. The definition
likely mirrors what the parametric truth lemma needs for the Until case.

### The fold-order trick requires a one-line change in enriched_fwd_step

Current code (line 584-586):
```lean
let others := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
(resolving_enriched_fwd_exists h_mcs target h_F others ...).choose
```

With fold-order trick:
```lean
let others_no_target := (sigma_list.filter (fun χ => χ ≠ target ∧ decide (Formula.some_future χ ∈ M)))
(resolving_enriched_fwd_exists h_mcs (others_no_target.headD target) h_F
  (others_no_target.tail ++ [target]) ...).choose
```

This change is ~5 LOC. The downstream proofs that depend on `enriched_fwd_step_spec` would
need verifying that the new spec is compatible — specifically, the "resolves_one" property
would guarantee target is the witness in Cases 1 and 3 (since target is the last element),
while in Case 2, some other formula is the witness.

The fold-order trick should be the FIRST implementation attempt (2 hours) as recommended by
both rounds 21 and 22 analysis.

---

## Confidence Levels

| Approach | Status | Confidence | Notes |
|----------|--------|------------|-------|
| Fold-order trick (target last) | Worth trying (2h) | 35% | Closes Cases 1, 3; Case 2 gap remains |
| buc/fuc independent closure | Requires careful handling | 55% | Guard condition harder than expected |
| Two-step chain (per-cycle NRS) | Closed | 0% | Same obstacle as deficiency induction |
| dd_bfmcs families bypass | Closed | 0% | Reduces to rr_fwd_chain_forward_F |
| Plan v18 ordered-discharge chain | Primary path | 55-65% | As established in rounds 18-21 |

**Overall assessment**: No new alternative architecture has been identified in this round.
The conclusion from round 21 stands: the fold-order trick is worth 2 hours of implementation
testing, and Plan v18 is the primary path if it fails. The buc/fuc independent closure
confidence is revised downward to 55% due to the guard condition complexity, but it remains
worth attempting (5-10 hours) as it may reduce active sorries from 6 to 4 even if forward_F
remains unsolved.

---

## Actionable Recommendations

**Recommended execution order**:

1. **Try fold-order trick (2 hours)**: Modify `enriched_fwd_step` to process target last.
   Test if the Case 2 gap actually fires in practice by examining concrete examples with the
   Lean LSP goal state inspection at the sorry site.

2. **Attempt buc/fuc closure via chain structure (5-10 hours)**: Read `restricted_backward_until_since_coherent`
   definition in UntilSinceCoherence.lean. Try to prove the buc sorry directly:
   (phi U psi) ∈ chain(t) + sigma_list coverage + forward_F (as hypothesis or via BX10) → Until condition.

3. **Proceed with Plan v18 if fold-order trick fails (25-35 hours)**: Replace `enriched_fwd_step`
   with `target_resolving_fwd_step` carrying a never-resolved history, prove forward_F via
   well-founded induction on |sigma_list| - |ever_resolved|, re-prove ~30 downstream theorems.
