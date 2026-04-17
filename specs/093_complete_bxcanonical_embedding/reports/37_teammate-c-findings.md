# Critic Findings: Task #93 (Round 37)

**Teammate**: C (Critic)
**Date**: 2026-04-17
**Mode**: Team Research (round 37)

---

## Key Findings

After reading Construction.lean, RootScopedChain.lean, Realization.lean, and the round 36
synthesis report, I have identified several important corrections to the ongoing narrative.

---

## Blocker Verification: Is the "Until propagation" framing accurate?

**Partially mischaracterized. The blocker is real, but the framing has shifted layers.**

### What `hintikka_step` ACTUALLY requires

Reading Construction.lean lines 45-52 precisely:

```
def hintikka_step {Sigma : Finset Formula} (h1 h2 : HintikkaPoint Sigma) : Prop :=
  (∀ χ : Formula, Formula.all_future χ ∈ h1.formulas → χ ∈ h2.formulas) ∧
  (∀ χ : Formula, Formula.all_past χ ∈ h2.formulas → χ ∈ h1.formulas) ∧
  (∀ φ ψ : Formula, Formula.untl φ ψ ∈ h1.formulas → ψ ∉ h1.formulas →
    φ ∈ h1.formulas ∧ Formula.untl φ ψ ∈ h2.formulas)
```

The Until propagation clause requires: if `(φ U ψ) ∈ h1` and `ψ ∉ h1`, then both
`φ ∈ h1` AND `(φ U ψ) ∈ h2`.

**Critical distinction**: `hintikka_step` is an ABSTRACT relation in Construction.lean.
The `HintikkaStepOracle` is what must be CONSTRUCTED -- it requires producing a next
HintikkaPoint `h2` such that `hintikka_step h1 h2` holds. The construction of this
oracle is where the Until propagation challenge lives.

**What the oracle needs specifically**: Given a HintikkaPoint `h1` with `(φ U ψ) ∈ h1`
and `ψ ∉ h1`, produce a `WitnessedHintikka` `wh'` such that:
1. `hintikka_step h1 wh'.point` holds (all three clauses)
2. Either `ψ ∈ wh'.point.formulas` or `(φ U ψ) ∈ wh'.point.formulas` with decreasing defect count

**The blocker is REAL**: To satisfy `hintikka_step h1 h2` via the BXPoint route, we need
h2 = sigma_signature(v, Sigma) for some BXPoint v. The G-propagation clause is
satisfied by `bx_le w v` (G(χ) ∈ w → χ ∈ v). The H-backward clause is satisfied by
`bx_H_forward`. But the Until clause requires `(φ U ψ) ∈ h2.formulas`, which requires
`(φ U ψ) ∈ v.formulas` AND `(φ U ψ) ∈ Sigma`. The `bx_forward_witness` construction
for the oracle target will get ψ ∈ v, but does NOT guarantee `(φ U ψ) ∈ v` for other
Until formulas (non-target defects that must propagate).

**However**: For the oracle to decrease defect count, it's satisfying the TARGET
defect `(φ U ψ)` -- this one goes to ψ ∈ h2 (discharged). For all OTHER Until defects
`(α U β) ∈ h1` with `β ∉ h1`, the oracle must put `(α U β) ∈ h2`. This is the challenge.

---

## Sorry Site Analysis

### The three sorry sites (lines 1517, 1522, 1527)

**Site 1 (line 1517)**: `dd_bfmcs_restricted_tc`
```
(dd_bfmcs M₀ h₀ sigma_list).restricted_temporally_coherent root
```
This requires: for each FMCS in the bundle, forward_F and backward_P hold for all
formulas in `deferralClosure(root)`.

`dd_bfmcs` is built from `shifted_dd_fmcs` which uses `rr_fwd_chain`. The forward_F
property (`rr_fwd_chain_forward_F`) has a sorry at its depth-0 base case (line 1413).
So `dd_bfmcs_restricted_tc` is blocked by the same depth-0 obstruction.

**The h_sub parameter** (`∀ ψ, ψ ∈ deferralClosure root → ψ ∈ sigma_list`) is correct
and appears in the call at line 1552-1553. This scopes forward_F to only deferralClosure.

**Site 2 (line 1522)**: `dd_bfmcs_restricted_buc`
```
(dd_bfmcs M₀ h₀ sigma_list).restricted_backward_until_since_coherent root
```
This requires: for formulas `(φ U ψ) ∈ subformulaClosure(root)`, if a witness s ≥ t
exists with ψ ∈ fam(s) and φ ∈ fam(r) for t ≤ r < s, then `(φ U ψ) ∈ fam(t)`.

This is the BACKWARD direction -- given a witness chain, derive that (φ U ψ) ∈ fam(t).
This follows from the BX8 axiom (ψ → φ U ψ if s = t; and from Until coherence otherwise).

**IMPORTANT**: `restricted_buc` is likely EASIER than `restricted_fuc`. It says:
if the semantic condition holds (witness exists with guard), then the formula is in fam(t).
This is the "backward" coherence -- it's derivable from BX axioms in the MCS.
The dd_bfmcs MCS families satisfy all BX axioms, so BX8 (refl_intro_until) gives
`(φ U ψ) ∈ fam(t)` whenever `ψ ∈ fam(t)`. For the general case (s > t), we need
the Until induction principle. This was identified as requiring the removed
`until_induction` axiom in the Boneyard.

**Wait**: Reading the definition more carefully (TemporalCoherence.lean lines 565-574),
restricted_buc says: if ∃ s ≥ t with ψ ∈ fam(s) and ∀ r ∈ [t,s), φ ∈ fam(r), then
(φ U ψ) ∈ fam(t). This is the Hintikka-style introduction of Until from a witness.
In BX, this is `BX7: (φ ∧ G(φ U ψ) → φ U ψ)` or similar induction scheme. Without the
`until_induction` axiom, this direction may genuinely be unprovable from BX1-BX12.

**Site 3 (line 1527)**: `dd_bfmcs_restricted_fuc`
```
(dd_bfmcs M₀ h₀ sigma_list).restricted_forward_until_since_coherent root
```
This requires: for `(φ U ψ) ∈ subformulaClosure(root)` with `(φ U ψ) ∈ fam(t)`,
find s ≥ t with ψ ∈ fam(s) and φ ∈ fam(r) for all t ≤ r < s.

The restricted_fuc has TWO parts:
1. The WITNESS: ∃ s ≥ t with ψ ∈ fam(s) -- this requires forward_F-style reasoning
2. The GUARD: ∀ r ∈ [t,s), φ ∈ fam(r) -- this requires guard preservation

Both parts are blocked. The witness requires forward_F (blocked at depth-0).
The guard requires that ALL intermediate points contain φ -- this is not guaranteed
by the round-robin chain construction.

### The REAL sorry at line 1413

The root sorry is `rr_fwd_chain_forward_F` line 1413 (depth-0 base case of the
f_nesting_depth induction). The three sorry sites at 1517, 1522, 1527 are DOWNSTREAM
consequences of this root sorry, plus additional obstacles.

### Two additional sorries at 1457 and 1464

- Line 1457: `dd_fmcs_forward_F` for t < 0 (backward chain case)
- Line 1464: `dd_fmcs_backward_P`

These two are also blocked by the same fundamental issue.

---

## Plan v36 Critique

Plan v36 proposes: Oracle Construction → hintikka_chain_exists → New BFMCS from
BXPoint chain → Full Until/Since coherence → Forward_F via BX12 → Wire into
dd_countermodel.

### What I agree with

1. `hintikka_chain_exists` IS sorry-free (Construction.lean lines 594-660). This is correct.
2. The oracle CAN be constructed from `bx_forward_witness` for the target defect.
3. BX12 (`F_imp_top_until_mcs`) IS sorry-free (CanonicalChain.lean lines 65-72).
4. The approach of building a NEW BFMCS (replacing dd_bfmcs) is correct in principle.

### What I challenge

**Challenge 1: The oracle's Until propagation for non-target defects**

The oracle needs to satisfy `hintikka_step h1 h2` which requires:
`∀ φ ψ, (φ U ψ) ∈ h1 ∧ ψ ∉ h1 → (φ U ψ) ∈ h2`

For the TARGET defect (α U β where the oracle resolves to β ∈ h2), the Until
clause is satisfied trivially (β ∈ h2 means the defect is discharged for the target).

But for all OTHER defects (φ U ψ ∈ h1 with ψ ∉ h1, for other φ, ψ): these must
also satisfy `(φ U ψ) ∈ h2`. This requires `(φ U ψ) ∈ v.formulas` where v is the
BXPoint backing h2. But `bx_forward_witness` produces v with ONLY ψ_target ∈ v
(plus g_content). There is no guarantee that other Until formulas from h1 appear in v.

**This is the REAL Until propagation blocker**: not just "Until formulas propagate"
abstractly, but specifically that ALL active Until defects from h1 must appear in h2.

**Challenge 2: The oracle decrease condition requires specific defect tracking**

The oracle for the target defect `(α U β)` must either:
- Produce h2 with β ∈ h2 (discharge), OR
- Produce h2 with `(α U β) ∈ h2` AND `defect_count h2 < defect_count h1`

For the decrease case: the oracle must produce h2 where EXACTLY the same defects
exist MINUS the target defect AND some other defect. This requires very careful
seed construction to ensure `defect_mono: untilDefectSet h2 ⊆ untilDefectSet h1`.

**Challenge 3: The "guard for free" claim**

Round 36 synthesis claims "quasimodel chain provides Until guard for free" (Finding 6).
Let me verify: `hintikka_step h1 h2` with `(φ U ψ) ∈ h1` and `ψ ∉ h1` gives
`φ ∈ h1`. And `(φ U ψ) ∈ h2` (propagation). So for the HINTIKKA chain, φ appears
at each non-discharge step. But for the BXPOINT chain (which is what the BFMCS needs),
the guard requires `φ ∈ w_i.formulas` for each backing BXPoint. This is NOT guaranteed
by `phi ∈ h_i.formulas` alone -- we need `phi ∈ Sigma` AND `phi ∈ w_i.formulas` to get
`phi ∈ sigma_signature(w_i, Sigma) = h_i`. So the guard on BXPoints follows, but only
because of the sigma_signature relationship and the fact that Sigma is SubformulaClosure.

**Actually, this part IS sound**: Since h_i = sigma_signature(w_i, Sigma), and
φ ∈ h_i.formulas means φ ∈ Sigma ∧ φ ∈ w_i.formulas, the guard holds at the BXPoint
level too. So Finding 6 is correct.

**Challenge 4: The Int extension claim**

Round 36 proposes extending the finite quasimodel chain to Int by repeating the last
state. This is claimed to be trivial. But:

For the forward direction (past the last chain point k), we need the "last BXPoint"
to form a valid FMCS across all integer times. An FMCS requires `is_mcs t` for ALL
t ∈ D. If D = Int and we use the last chain BXPoint for all t ≥ k, we need to check:
- G-propagation (box formulas at t ≥ k): satisfied since bx_le w_k w_k (reflexive)
- H-backward (box formulas): likewise
- The MCS condition: w_k is an MCS, so this works

For t < 0, we need a backward chain. The Since formulas are not discharged by the
forward chain. A symmetric `hintikka_chain_exists_since` would need to be invoked
(it IS sorry-free in Construction.lean, lines 769-824). But this requires building
a separate oracle for the backward direction.

**The Int extension is non-trivial**: It requires stitching forward and backward chains
together and ensuring compatibility at t=0.

**Challenge 5: Full Until coherence vs. restricted**

The restricted_fuc requires:
1. For `(φ U ψ) ∈ subformulaClosure(root)`, NOT all Until formulas
2. The guard: ∀ r ∈ [t,s), φ ∈ fam(r) for ALL intermediate times

Even with "full Until coherence" from the quasimodel, the transition to BFMCS
requires that the Int-indexed chain has this property. For times between the finite
chain and infinity, the last point (w_k) is repeated. If `(φ U ψ) ∈ w_k` and
`ψ ∉ w_k` (a discharged defect AFTER the chain), then BX8: `ψ → φ U ψ`, but
if ψ ∉ w_k then we'd need another forward step. But w_k is supposed to have all
defects discharged (it's the last chain point with ψ ∈ w_k by `hintikka_chain_exists`).

Wait -- hintikka_chain_exists guarantees ψ ∈ c.last.formulas for THE TARGET defect
`(φ U ψ)`. But what about ALL other Until formulas in sigma? Each one needs its own
chain via a separate oracle invocation. The quasimodel handles ONE target defect at
a time.

**This is a fundamental gap**: The new BFMCS construction from a single quasimodel
chain only resolves ONE target defect. To resolve ALL until defects in subformulaClosure,
we'd need multiple chains -- one per Until formula -- which must be combined coherently.

---

## Overlooked Infrastructure

### 1. `resolving_enriched_fwd_exists` (RootScopedChain.lean ~line 400)

This function is sorry-free and handles MULTIPLE F-obligations simultaneously via BX11
fold. It gives: `target ∈ M' OR F(target) ∈ M'` AND `∀ χ ∈ others, χ ∈ M' OR F(χ) ∈ M'`.

This is actually the seed that the round-robin chain uses! The perpetual deferral issue
is that it gives `χ ∈ M' OR F(χ) ∈ M'` (disjunction) -- not `χ ∈ M'` (definitely).

**Could this be combined with the quasimodel approach?** The quasimodel approach uses
`bx_forward_witness` directly (getting ψ ∈ v) rather than going through fold. But
`resolving_enriched_fwd_exists` could potentially be used to build the oracle step with
ALL Until formulas as "others" that must be preserved.

### 2. `defect_fwd_step` (RootScopedChain.lean ~line 1601)

This is a custom Lindenbaum extension `{target, guard} ∪ g_content(M)` built from
`enriched_resolving_seed_consistent`. This seed guarantees `target ∈ M'` AND `guard ∈ M'`.

**Could the oracle use this?** If we set guard = `(α₁ U β₁) ∧ ... ∧ (αk U βk)` (big
conjunction of all active Until formulas), and use `F(ψ ∧ guard) ∈ w` (from BX11 fold),
we could build a step where ψ ∈ h2 AND all Until formulas ∈ h2. This would satisfy
the Until propagation clause of hintikka_step!

**This is a potentially viable oracle construction that has been overlooked.**

### 3. `F_imp_top_until_mcs` (CanonicalChain.lean line 65)

BX12: F(ψ) ∈ w → (⊤ U ψ) ∈ w. This is sorry-free.

For restricted_fuc: if `(φ U ψ) ∈ subformulaClosure(root)` and we handle ONLY standard
Until formulas (not ⊤ U ψ), the BX12 bridge converts forward_F obligations to Until
obligations, potentially reusing the quasimodel.

### 4. `bx_until_eventuality_resolution` (Frame.lean lines 623-644)

This is the ONLY sorry-free eventuality resolution we have. It gives:
- `bx_le w v` with `ψ ∈ v` and `φ ∈ w`

But it only resolves ONE Until formula. The h_not_psi parameter means we know
`ψ ∉ w`, so this is precisely the oracle step for a single target defect.

---

## Mathematical Errors Found

### Error 1: "defect_mono hypothesis is discharged in Phase 5" (over-optimistic)

Construction.lean docstring (lines 227-231) says:
> The monotonicity hypothesis is required because the abstract hintikka_step relation does not
> force h2.formulas ⊆ h1.formulas; without the hypothesis, unrelated Until-formulas could enter
> h2 and cancel the target discharge. The hypothesis is discharged at the realization-lifting
> level in Phase 5, where the lifted v_{i+1} is constructed from a seed that includes
> h_i.formulas and thus carries forward all defects that were not explicitly discharged.

This is **aspirational**, not actual Lean proof. Phase 5 has not been implemented.
The plan notes Phase 5 is "chain realization infrastructure" that is NOT sorry-free
(Realization.lean Phase 5 section has obstacles identified, no proofs completed).

If the new oracle construction does not explicitly include all active Until formulas in
the seed, the defect_mono hypothesis will NOT be satisfied automatically.

### Error 2: "The oracle construction is feasible from bx_forward_witness"

Round 36 Finding 4 (Teammate A) claims H-backward and G-propagation work but glosses
over the Until propagation clause for NON-TARGET defects. The synthesis (Finding 7)
says the oracle takes 200-300 LOC. My analysis shows that satisfying ALL THREE clauses
of hintikka_step simultaneously requires careful seed construction that has not been
worked out, and may require a different seed than `{ψ} ∪ g_content(w)`.

### Error 3: "Full Until coherence avoids closure gap"

The synthesis claims full Until/Since coherence avoids the subformulaClosure membership
check. But `restricted_fuc` is stated in terms of `subformulaClosure(root)`, which is
what the truth lemma (RestrictedParametricTruthLemma.lean) requires. Even with "full
coherence", you'd need to DERIVE the restricted version. The derivation at line 550-556
shows that `full implies restricted` -- so IF we prove full coherence, restricted_fuc
follows trivially. This part is correct.

But the transition from the quasimodel chain to full Until/Since coherence of the
NEW BFMCS is the remaining gap.

### Error 4: "hintikka_chain_exists" resolves the problem

`hintikka_chain_exists` gives a finite chain with `ψ ∈ c.last.formulas` for ONE target
defect `(φ U ψ)`. The Until coherence for a BFMCS requires resolving ALL Until formulas
that appear in fam(t) for arbitrary t. A single invocation of `hintikka_chain_exists`
handles only one target.

The synthesis (Finding 7, step 3) says "the backing BXPoints form an FMCS" -- but this
only works if ALL Until defects are discharged, not just one.

---

## Confidence Level

**HIGH confidence** on the specific blocker identification (non-target Until propagation).
**HIGH confidence** on the error identification (hintikka_chain_exists handles one target).
**MEDIUM confidence** on the `defect_fwd_step` / big-conjunction seed as a possible oracle.
**MEDIUM confidence** on the claim that the int extension is non-trivial (it requires
coordinating forward AND backward chains).

---

## Recommendations

### Priority 1: Work out the oracle seed construction concretely

The oracle for the HintikkaStepOracle needs to satisfy hintikka_step for ALL three
clauses simultaneously. The proposed seed is:

```
seed = {ψ, (α₁ U β₁), ..., (αk U βk)} ∪ g_content(w)
```

where ψ is the target and (αᵢ U βᵢ) are all OTHER active Until defects.

Verify: Is the consistency of this seed provable from BX axioms?

Key fact: The Until defects (αᵢ U βᵢ) ∈ h1.formulas ⊆ w.formulas. So all elements
of the seed are in w.formulas (αᵢ U βᵢ ∈ w via the WitnessedHintikka property).
The target ψ comes from bx_forward_witness (F(ψ) ∈ w → ∃ v ≥ w with ψ ∈ v).

But this seed is NOT `{ψ} ∪ g_content(w)` -- it's `{ψ, α₁ U β₁, ...} ∪ g_content(w)`.
Consistency: since all elements are in w.formulas (ψ ∈ v but v ≥ w, so we need
ψ ∈ w? No, ψ ∉ w is the premise). So this approach breaks down because ψ ∉ w.

The correct seed is: `{ψ} ∪ g_content(w) ∪ {(αᵢ U βᵢ) | defects}`.
But ψ ∉ w, and the (αᵢ U βᵢ) ∈ w. The g_content(w) ⊆ w. So the seed has
ψ ∉ w as the "new" element. Consistency: via `bx_forward_witness`'s seed
`{ψ} ∪ g_content(w)` -- we know THIS is consistent (that's exactly what
`forward_temporal_witness_seed_consistent` proves). Adding more elements from w.formulas
to a consistent set keeps it consistent (all added elements are in w which is MCS).

**THEREFORE**: The seed `{ψ, α₁ U β₁, ..., αk U βk} ∪ g_content(w)` IS consistent
(by subset-of-MCS argument: the original seed {ψ} ∪ g_content(w) is consistent, and
the additional elements are all in the Lindenbaum extension M' ⊇ {ψ} ∪ g_content(w),
but that's circular).

Actually, the consistency proof is: assume L ⊢ ⊥ with L ⊆ seed. Case on whether ψ ∈ L.
If ψ ∉ L: all of L ⊆ g_content(w) ∪ {αᵢ U βᵢ} ⊆ w.formulas. Since w is MCS and
consistent, L ⊢ ⊥ is impossible.
If ψ ∈ L: similar to `forward_temporal_witness_seed_consistent` -- derive F(ψ) ∈ w from
F(ψ) ∈ w (premise), then ψ ∉ w is the hypothesis. The rest of L ⊆ w.formulas.
This gives: L' ⊢ ¬ψ → w derives ¬¬ψ, then ψ ∈ w, contradiction with ψ ∉ w.
This is EXACTLY the `forward_temporal_witness_seed_consistent` proof structure!

**CONCLUSION**: The seed `{ψ} ∪ g_content(w) ∪ {active Until defects}` IS consistent,
provable by the same argument as `forward_temporal_witness_seed_consistent`.

### Priority 2: After building the oracle, verify hintikka_step satisfaction

With the extended seed, the Lindenbaum extension M' has:
- ψ ∈ M' (target is discharged)
- G(χ) ∈ w → χ ∈ M' (by g_content ⊆ M')
- All active Until defects ∈ M'
- H-backward: need to check...

H-backward for hintikka_step: `H(χ) ∈ h2 → χ ∈ h1`. Here h2 = sigma_signature(M', Sigma).
If H(χ) ∈ M' (and H(χ) ∈ Sigma), then H(χ) ∈ h2. We need χ ∈ w and χ ∈ Sigma → χ ∈ h1.
But H(χ) ∈ M': we need H(χ) ∈ w to conclude χ ∈ w via bx_H_forward.
Since M' ⊇ g_content(w) but is NOT ⊇ w (M' is reachable from w, not a superset of w),
H(χ) ∈ M' does NOT imply H(χ) ∈ w in general.

**The H-backward clause remains an obstacle** for the extended-seed oracle.

The key question: how does `bx_forward_witness` guarantee H-backward?

Answer: `bx_le w v` means `g_content(w) ⊆ v`. And `bx_H_forward(bx_le w v)(H(χ) ∈ v)` gives
χ ∈ w. So if we use the BXPoint v from `bx_forward_witness` as the backing witness for h2,
then H(χ) ∈ v → χ ∈ w. This means we need h2's backing witness v to satisfy `bx_le w v`.

`bx_forward_witness` gives EXACTLY this: v with `bx_le w v` and `ψ ∈ v`. The extended seed
`{ψ, α₁ U β₁, ...} ∪ g_content(w)` -- when Lindenbaum-extended to MCS M'' -- satisfies
`g_content(w) ⊆ M''`, which means `bx_le w (⟨M'', ...⟩)`.

**So H-backward IS satisfied** by extending the seed with g_content(w).

### Priority 3: The big-conjunction oracle is the path forward

The oracle step:
1. Let Sigma_defects = all (αᵢ U βᵢ) ∈ h1.formulas with βᵢ ∉ h1.formulas, excluding target
2. Use `bx_forward_witness w ψ h_F` to get v with ψ ∈ v and bx_le w v
3. Build seed `{ψ} ∪ g_content(w) ∪ Sigma_defects`
4. Prove consistent (above)
5. Lindenbaum extend to MCS v'
6. Let h2 = sigma_signature(v', Sigma)
7. Prove hintikka_step h1 h2:
   - G-propagation: G(χ) ∈ h1 → G(χ) ∈ w → χ ∈ v' (via g_content(w) ⊆ v')
   - H-backward: H(χ) ∈ h2 → H(χ) ∈ v' → H(χ) ∈ w? NO -- v' is not v.

**WAIT**: Step 3-6 replaces bx_forward_witness. We need v' with BOTH ψ ∈ v' AND
g_content(w) ⊆ v'. This is exactly what `forward_temporal_witness_seed_consistent`
plus Lindenbaum gives. The resulting v' has bx_le w v' by construction.

For H-backward: H(χ) ∈ v' and bx_le w v' → χ ∈ w ✓ (by bx_H_forward).

**CONCLUSION**: The oracle construction IS viable using the extended seed. The
`defect_fwd_step` infrastructure (line 1601) provides exactly this pattern!

### Priority 4: Do NOT try to build a new full BFMCS from scratch

The 1500-2000 LOC estimate for replacing dd_bfmcs is excessive. The more targeted approach:

1. Build the oracle (100-200 LOC) using extended seed from Point 3
2. Use `hintikka_chain_exists` (already sorry-free) to build ONE chain per Until defect
3. Wire multiple chains together into a BFMCS by handling each defect independently

But step 3 is still complex. An alternative: show that dd_bfmcs with enriched steps
DOES satisfy Until coherence IF the enriched_fwd_step includes Until formulas in the seed.

The REAL fix may be: modify `rr_fwd_seed` to include active Until defects alongside
the round-robin target, using the extended seed consistency proof from Priority 1.

This would fix `rr_fwd_chain_forward_F` at the depth-0 case by ensuring Until formulas
survive each round-robin step, preventing perpetual deferral of the Until witness.

---

## Summary

The blocker is REAL but mischaracterized. It is not just "Until formulas need to
propagate" -- it is specifically that ALL active Until defects must appear in h2
simultaneously, while also placing ψ (the target) in h2 and maintaining the bx_le
relationship. This requires an EXTENDED seed that includes ALL active Until defects.

The good news: this extended seed IS consistent (by subset-of-MCS argument), and the
existing `forward_temporal_witness_seed_consistent` proof structure handles it directly.

The key overlooked insight: the oracle can use `{ψ} ∪ g_content(w) ∪ {active Until defects}`
as its Lindenbaum seed, producing a v' that:
1. Contains ψ (discharges the target)
2. Contains all active Until defects (satisfies Until propagation)
3. Satisfies bx_le w v' (enables H-backward via bx_H_forward)
4. Contains g_content(w) (enables G-propagation)

This has not been tried in any previous round. It does not require modifying dd_bfmcs
or building a new BFMCS. The oracle can be built as a standalone construction of ~100-200 LOC.

The BFMCS-level Until coherence still needs to be connected to the oracle-level Hintikka
chain. This requires the Int extension and the quasimodel-to-BFMCS lifting (~300-500 LOC).
But the oracle itself is closer to solved than previous rounds suggest.
