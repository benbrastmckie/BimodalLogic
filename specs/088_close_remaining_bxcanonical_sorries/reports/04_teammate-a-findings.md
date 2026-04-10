# Teammate A Research Findings: Primary Approach for Frame.lean Sorries

**Task**: 88 — Close remaining BXCanonical sorries
**Round**: 4
**Teammate**: A (Primary approach research)
**Date**: 2026-04-09
**Focus**: Primary approach for closing the 4 Frame.lean eventuality resolution sorries

---

## Key Findings

### 1. Exact Proof Obligations (from code reading)

**`bx_until_eventuality_resolution` (Frame.lean:632–653)**:
```
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```
Given `φ U ψ ∈ w`, `ψ ∉ w`, find v ≥ w with ψ ∈ v and φ at all strictly intermediate u ∈ (w,v).

**`bx_until_backward` (Frame.lean:664–675)**:
```
(w v: BXPoint) (h_wv: bx_le w v) (h_ψv: ψ ∈ v.formulas)
  (h_guard: ∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
  (h_not_psi: ψ ∉ w.formulas) → Formula.untl φ ψ ∈ w.formulas
```

**`bx_since_eventuality_resolution` (Frame.lean:683–690)**:
Mirror of forward Until in past direction.

**`bx_since_backward` (Frame.lean:697–704)**:
Mirror of backward Until in past direction.

**How they're used**: `TruthLemma.lean:281–358` — `until_iff_mcs` calls `bx_until_eventuality_resolution` for the forward ψ-not-in-w case and `bx_until_backward` for the backward ψ-not-in-w case. These are the only consumers.

### 2. The Fundamental Blocker (Confirmed Again)

The canonical ordering is `bx_le w v := g_content w.formulas ⊆ v.formulas`, where `g_content S := {φ | G(φ) ∈ S}`.

The blocker: `φ U ψ ∈ w` does NOT give `G(φ U ψ) ∈ w`.

- BX9: `φ U ψ → φ ∨ ψ` — gives φ or ψ at w, not persistence
- BX10: `φ U ψ → F(ψ)` — gives F(ψ) ∈ w, which is a forward witness, but not G
- BX4: `(φ U ψ) → G(P(φ U ψ))` — gives `P(φ U ψ) ∈ u` for every u ≥ w, i.e., `φ U ψ` has BEEN true before u. This is retrospective, not prospective
- BX5: `φ U ψ → (φ ∧ φ U ψ) U ψ` — self-accumulation: the enriched Until still requires the same X-vs-G bridge
- BX7: linearity of Until witnesses — orders Until-resolution times, not g_content inclusions

No BX axiom gives `G(φ U ψ) ∈ w` from `φ U ψ ∈ w`. This is confirmed across 5 rounds of research (tasks 83-88) and the implementation summary for plan v3.

### 3. Analysis of Formula-Specific Ordering (Question 1)

**What it would be**: `bx_le_φ w v` defined as "v is reachable from w along a chain of witnesses for φ". Specifically: for `φ U ψ`, define `bx_le_φ w v` as existence of an Until-witness chain `w = w₀, w₁, ..., wₙ = v` where each `wᵢ₊₁` is the MCS constructed by `bx_forward_witness` from `wᵢ` using `φ U ψ ∈ wᵢ`.

**What it gives**:
- On this formula-specific chain, `φ U ψ` does persist: if `φ U ψ ∈ wᵢ` and `ψ ∉ wᵢ`, then BX9 gives `φ ∈ wᵢ` and BX10 gives `F(ψ) ∈ wᵢ`, so the chain continues
- Guard propagation on this chain: at each `wᵢ < v` (where v is the ψ-witness), we can derive `φ ∈ wᵢ` using BX9 applied to `φ U ψ ∈ wᵢ`

**Critical limitation**: The guard in `bx_until_eventuality_resolution` quantifies over ALL `u` with `bx_le w u` and `bx_lt u v`. Even with a formula-specific chain from w to v, OTHER BXPoints u (not on this chain) might be bx_le-reachable from w and bx_le-less-than v. The guard requires φ ∈ u for ALL such u.

For the guard to be provable, we need either:
1. The formula-specific chain is the ONLY path from w to v (not guaranteed with any global ordering)
2. The guard is weakened to "u on the formula-specific chain" (but TruthLemma.lean:283–284 quantifies over ALL u with `bx_le w u ∧ bx_lt u v`)

**Conclusion**: Formula-specific ordering solves the persistence problem on chains but does not solve the universal guard quantification problem. The guard statement `∀ u, bx_le w u → bx_lt u v → φ ∈ u` requires φ at ALL intermediate BXPoints, and without global linearity, we cannot guarantee this for points not on the specific witness chain.

**However**, there is a key insight: the guard obligation in `until_iff_mcs` could potentially be refactored. If the semantics of Until in the TaskModel uses the formula-specific chain ordering rather than the universal bx_le ordering, the proof obligation changes. This requires changing the TaskModel definition, which is a larger architectural change.

### 4. Analysis of Temporal Coherence Integration (Question 2)

**What exists in the codebase**: `TemporalCoherence.lean` defines:
- `TemporalCoherentFamily`: FMCS with `forward_F` (F(φ) at t → ∃ s > t with φ ∈ fam.mcs s) and `backward_P`
- `BFMCS.restricted_temporally_coherent`: Restricted version for formulas within `deferralClosure(root)`
- `backward_until_from_step` and `backward_since_from_step` in `UntilSinceCoherence.lean`: prove backward Until/Since given a "step transfer" property

**The step transfer property needed**:
```
∀ r : Int, Formula.untl φ ψ ∈ fam.mcs (r + 1) → φ ∈ fam.mcs r → Formula.untl φ ψ ∈ fam.mcs r
```
This says: if `φ U ψ` holds at the next step and φ holds now, then `φ U ψ` holds now.

**This is derivable from BX axioms!** The derivation:
- BX8: `ψ → (φ U ψ)` (reflexive intro)
- The proof: given `φ U ψ ∈ fam.mcs (r+1)` and `φ ∈ fam.mcs r`, we need `φ U ψ ∈ fam.mcs r`.
- This is precisely what a backward Until induction step gives. On a discrete Int-indexed chain with successor structure, BX8 + the fact that `φ U ψ ∈ next(r)` should allow deriving `φ U ψ ∈ r` via the backward direction of the expansion axiom.
- BX: `(φ U ψ) ↔ ψ ∨ (φ ∧ X(φ U ψ))` — but BX doesn't have X (next) directly. The reflexive Until axioms give `φ U ψ ↔ ψ ∨ (φ ∧ F̃(φ U ψ))` where F̃ is a "strict F" or "next-or-later" combination.
- **Key problem**: The step transfer for discrete chains requires the X (next) operator or some discreteness axiom, which BX does NOT include. BX is for all linear orders, not just discrete ones. Without X, the step transfer is not directly provable from BX axioms alone on the Int-indexed chain.

**Alternative for TemporalCoherence integration**: The `RestrictedTemporallyCoherentFamily` could potentially be used for the canonical completeness proof via a different route:
- Build a restricted DRM chain for the target formula
- Use `backward_until_from_step` with the step transfer proved from the chain structure (if the chain has the right properties)
- Apply the restricted truth lemma to conclude validity

This is the approach mentioned in the Phase 3 summary for CanonicalEmbedding:418. But for Frame.lean, the issue is different: the BXPoint ordering is global and does not carry discrete chain structure.

**Conclusion**: Temporal coherence machinery cannot directly close the Frame.lean sorries without replacing the global BXPoint ordering with an Int-indexed chain structure. The existing `backward_until_from_step` requires discrete chain infrastructure that the BXPoint canonical model doesn't have.

### 5. Analysis of Direct Eventuality Resolution (Question 3)

**The question**: Can `bx_until_eventuality_resolution` be proved by induction on chain length from w to u?

**What induction would need**:
- A well-founded relation on chains from w to u in the BXCanonical model
- Inductive step: if φ ∈ u for all u at distance < n from w, then φ ∈ u for all u at distance n

**The fundamental difficulty**: In the BXCanonical model, the "distance" from w to u is not well-defined. BXPoints don't carry a discrete chain structure. The ordering `bx_le` is a general preorder on all MCSes, without a notion of "one step" or "distance".

**What BX4 gives**: `φ U ψ → G(P(φ U ψ))`. So for any u ≥ w: `P(φ U ψ) ∈ u`, meaning there exists t ≤ u with `φ U ψ ∈ t`. But t might be w itself (the original point), not a point strictly between w and u. This doesn't give `φ U ψ ∈ u` itself.

**What BX5 gives**: Self-accumulation: `φ U ψ → (φ ∧ φ U ψ) U ψ`. This enriches the guard but doesn't help propagate `φ U ψ` forward through bx_le steps.

**What BX7 gives**: If `φ U ψ ∈ w` and `χ U θ ∈ w`, the witnesses are linearly ordered. But this is about ordering between two concurrent Until obligations at the same point w, not about propagating one obligation through bx_le.

**Induction on BX7**: Could we use BX7 to do a "finite descending chain" argument? For example:
- `φ U ψ ∈ w`, `ψ ∉ w`, so BX9 gives `φ ∈ w`
- BX10 gives `F(ψ) ∈ w`, so `∃ v ≥ w` with `ψ ∈ v` via `bx_forward_witness`
- Now for any u ∈ (w, v), we need `φ ∈ u`
- If `φ U ψ ∈ u` (from some chain argument), then BX9 gives `φ ∈ u` or `ψ ∈ u`. But we need to EXCLUDE ψ ∈ u first (which would make u = v), so we'd get `φ ∈ u`.
- The problem is proving `φ U ψ ∈ u` for intermediate u.

**BX4 partial success**: We know `P(φ U ψ) ∈ u` for all u ≥ w (from BX4 applied at w). This gives `∃ t ≤ u` with `φ U ψ ∈ t`. But t could equal u (i.e., `φ U ψ ∈ u` itself) — so if we assume by contradiction that `¬(φ U ψ) ∈ u`, then from `P(φ U ψ) ∈ u` we get `∃ t < u` with `φ U ψ ∈ t`. This IS a descending chain argument!

**Potential approach via well-founded descent**:
1. Assume by contradiction that some u ∈ (w, v) has `φ ∉ u` AND `ψ ∉ u`
2. Since `ψ ∉ u`, we need `φ U ψ ∉ u` (otherwise BX9 gives `φ ∈ u` contradiction)... wait, BX9 gives `φ ∨ ψ`, and if `ψ ∉ u` then `φ ∈ u`.
3. Actually: BX9 says `φ U ψ → φ ∨ ψ`. If `φ U ψ ∈ u` then either `φ ∈ u` (and we're done) or `ψ ∈ u`.
4. So if `φ ∉ u` and `ψ ∉ u`, then by contrapositive of BX9, `φ U ψ ∉ u`.
5. Now from `P(φ U ψ) ∈ u` and `φ U ψ ∉ u`: there exists `t < u` (strictly) with `φ U ψ ∈ t`.
6. And w ≤ t < u ≤ v (if we know w ≤ t)...

**The w ≤ t problem**: Step 5 gives `t < u`, but does `w ≤ t` hold? This is the SAME linearity gap. `bx_backward_witness` gives `t ≤ u`, but not necessarily `w ≤ t`. We need `w ≤ t` to conclude t ∈ [w, v).

**Conclusion for direct induction**: The descent argument shows promise (it reduces the problem from proving φ at u to finding φ U ψ at some t < u), but collapses at the same linearity gap: we cannot guarantee that the t ≤ u satisfying `φ U ψ ∈ t` also satisfies `w ≤ t`.

### 6. The Actual Viable Approach: Formula-Specific Chains with Modified Semantics

After ruling out the above approaches in the BXCanonical model as-is, there IS a viable mathematical path, but it requires an architectural change:

**Core insight from the 03_implementation_summary.md Phase 2 NO-GO**:
> "The problem is NOT the ordering definition but the guard quantification. Any single global ordering faces the same issue: the guard requires the formula at ALL intermediate points, but Until formulas don't propagate through any global ordering."

The viable path is to change the SEMANTICS used in the truth lemma — not the ordering on BXPoints directly, but the structure of the canonical model used for completeness.

**Two realistic approaches found**:

#### Approach A: Restrict to Formula-Specific Chains (Most Promising)

Instead of proving `∀ u (bx_le w u) (bx_lt u v) → φ ∈ u` over ALL BXPoints, restrict to a SPECIFIC formula-φ-U-ψ-chain that is:
1. Int-indexed
2. Has the Until formula `φ U ψ` present at every point (from BX9 propagation)
3. Linear by construction (it's an Int-indexed sequence)

This is essentially the parametric BFMCS approach from `parametric_algebraic_representation_relative`. The idea:
- Build a SuccChainFMCS starting from w, where the chain is constructed to resolve the φ U ψ obligation
- Use `backward_until_from_step` (from UntilSinceCoherence.lean) with the step transfer proved from the chain structure
- The step transfer `φ U ψ ∈ chain(r+1) ∧ φ ∈ chain(r) → φ U ψ ∈ chain(r)` requires the discrete chain to use a step structure — derivable if chain construction uses `ψ ∪ g_content` seeds

**Key question**: Does this require adding discreteness/next axioms? No — because the Int-indexed chain itself is discrete; the step transfer is about this specific chain, not about BX axioms for all structures.

**Step transfer for SuccChain**: Given that `chain(r)` has `g_content` included in `chain(r+1)`, and `φ U ψ ∈ chain(r+1)`:
- Since `g_content(chain(r)) ⊆ chain(r+1)`, any G-formula from r is in r+1
- But we need to go BACKWARD: φ U ψ in r+1 does NOT give G(φ U ψ) in r+1 (same X-vs-G mismatch)
- So we still cannot derive φ U ψ in chain(r) from φ U ψ in chain(r+1)

The step transfer requires something like: if the chain at r+1 is EXPLICITLY constructed to resolve φ U ψ, then by the construction process (using φ U ψ as a seed), φ U ψ should be in the seed for chain(r) as well. But this is circular — the chain at r is constructed BEFORE r+1, so it can't know about φ U ψ ∈ chain(r+1).

**Verdict for Approach A**: Blocked by the same X-vs-G mismatch even on discrete Int-indexed chains.

#### Approach B: Modified Canonical Model (Quasimodel/Filtration)

Replace the canonical model entirely with a finite quasimodel (model for a finite formula set). This approach:
1. Works on the closure of the formula (finite)
2. Does NOT need global linearity of the canonical ordering
3. Uses the FILTRATION technique: quotient the canonical model by logical equivalence on the closure
4. The filtration of a linear order is linear (this uses finite filtration theory)

**Evidence in codebase**: `parametric_algebraic_representation_relative` (Algebraic/ParametricRepresentation.lean:184) is sorry-free and gives `valid φ → ∀ S : ClosureMCSBundle φ, φ ∈ S.carrier`. The FMP approach (Decidability/FMP) is also sorry-free. The bridge `valid φ → ∀ S : ClosureMCSBundle φ, φ ∈ S.carrier` is the key missing link.

**What fails**: `TruthPreservation.lean:247-249` — temporal operator cases are archived to Boneyard. The filtration truth lemma for Until/Since on the finite closure fails at the same step: need to prove Until in the filtration from Until in the original model.

#### Approach C: Two-Step Canonical Model

Instead of a single canonical model, use a two-step construction:
1. Build the canonical model for G/H/Box (done — bx_completeness structure in Completeness.lean:124)
2. Within this, construct formula-specific linear chains for each Until/Since obligation
3. Apply the parametric truth lemma on these chains

This is closest to the standard proof for Until-Since completeness in textbooks (Burgess 1984, Goldblatt 1992). The key difference from what's been tried: instead of a single Int-indexed chain, use one chain PER Until obligation, assembled into the canonical model structure.

**What exists**: The `canonical_forward_U` in CanonicalFrame.lean gives a SINGLE-STEP witness for each φ U ψ. For the truth lemma, we need not just one step but a full linear chain from w to the ψ-witness with φ at every intermediate step. The intermediate steps require Until formula propagation — the same blocker.

---

## Evidence Analysis

### What the Proof Structure Actually Needs

Tracing through `TruthLemma.lean:281–296`, the forward case of `until_iff_mcs` reduces to `bx_until_eventuality_resolution`. The guard statement:
```
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```
is the "for all strictly intermediate u in the canonical ordering, φ holds".

**If we weakened the guard**: If the semantics used "on this specific chain" rather than "for all bx_le intermediate", the problem becomes tractable. But this would require changing `TruthLemma.lean` and the underlying TaskModel semantics.

### BX Axioms Relevant to the Guard

Looking at what BX axioms could give φ at intermediate u:
- **BX5 self-accumulation**: `φ U ψ → (φ ∧ φ U ψ) U ψ`. This shows that φ AND φ U ψ hold on the guard interval. But it requires knowing that the guard interval IS the interval for the enriched Until, which is a circular argument.
- **BX6 absorption**: `φ U (φ ∧ φ U ψ) → φ U ψ`. Converse of BX5 in some sense.
- **BX7 linearity**: If `φ U ψ ∈ w` and `χ U θ ∈ w`, the witnesses are ordered. Applied with `χ = φ`, `θ = ψ`, this orders the witness for `φ U ψ` with itself (trivially). Applied with a second formula, it orders two distinct witnesses.

### The BX5+BX6 Induction Strategy

BX5 and BX6 together give a form of "eventuality fixpoint": φ U ψ is the MINIMAL formula satisfying `ψ ∨ (φ ∧ X(·))` (where X is a "next time" placeholder). In the BX system without X, this is expressed via the combination of BX5 (unwinding) and BX6 (absorption/minimality).

**Attempted approach** (mentioned in Frame.lean:628): "blocked on Until-induction derivation from BX5+BX6+BX7". This suggests that BX5+BX6 together form a weak induction principle for Until, but it's not strong enough to derive the universal guard condition without X or linearity.

**Mathematical analysis**: In Burgess (1982), completeness for Until-Since over linear orders uses the following key lemma: "If φ U ψ ∈ M and ψ ∉ M, then there exists v > M with ψ ∈ v and ∀ u ∈ (M, v), φ U ψ ∈ u." The proof uses the Burges-Xu induction principle `G(¬ψ ∧ G(step)) → ¬(φ U ψ)` — a form of Until-induction that was explicitly removed from BX (as confirmed by WitnessSeed.lean comments).

Without Until-induction (removed in BX refactoring), BX5+BX6 are insufficient to derive the eventuality resolution.

---

## Recommended Approach

Based on the analysis, the most viable approach is **Approach B: Restricted Completeness via Parametric Truth Lemma**, specifically:

### Phase A (Near-term, 12-18h): Close CanonicalEmbedding:418

This is achievable via the approach documented in 03_implementation-summary.md:
1. Use `RestrictedTemporallyCoherentFamily` to build a DRM chain for sub-formulas of the target
2. Prove restricted parametric truth lemma for USF (Until/Since-free) sub-formulas
3. Apply to derive contradiction for `usf_completeness` imp Case B

This is independent of the Frame.lean sorries and yields `usf_completeness`.

### Phase B (Long-term, 20-40h): Close Frame.lean sorries via Quasimodel

The most mathematically viable path for Frame.lean sorries is:

**Novel approach not tried**: Use the BX AXIOMS DIRECTLY as a rewriting system.

Instead of working in the canonical model and trying to propagate formulas, work PURELY proof-theoretically:

`bx_until_eventuality_resolution` is used to prove `until_iff_mcs`, which is used to prove `bx_completeness`. For `bx_completeness`, we need: if `¬φ` is consistent, then φ is not valid. The canonical model construction for this uses the truth lemma.

**Alternative proof of completeness not through canonical model**:
- **Henkin-style proof**: Extend to MCS where Until is directly witnessed, using a scheduled construction that explicitly resolves eventualities turn by turn
- **Filtered model**: Use the finite model property (already proved!) to give completeness for the FINITE fragment, then use compactness for the infinite case... but this doesn't work for temporal logic

**Most concrete actionable path**: The Henkin-style scheduled construction. Build an ω-chain of MCSes:
- `chain(0)` = initial MCS containing `¬φ`
- `chain(n+1)` = Lindenbaum extension of `chain(n) ∪ {witness for the n-th Until obligation}`
- Use a FAIR SCHEDULING: enumerate all pairs (w, φ U ψ) and resolve each one at some finite stage
- This is the "Henkin-Bernays construction" for temporal logic

**What makes this work**: The fair scheduling ensures that every Until obligation `φ U ψ ∈ chain(n)` gets a resolution at some `chain(m)` with m > n. The Int-indexed chain is NOT needed — the ω-chain suffices for the Until direction.

**What the codebase already has**:
- `canonical_forward_U` (CanonicalFrame.lean:199): gives a single-step Until witness
- `backward_until_from_step` (UntilSinceCoherence.lean:111): proves backward Until given step transfer
- The `SuccChainFMCS` construction: builds ω-chains but without fairness/scheduling

**What's missing**: Fair scheduling to ensure EVERY Until obligation gets resolved, not just one at a time. Without fairness, the chain might ignore some Until obligations forever.

This matches the known literature: Burgess (1984) uses "companion" sequences to ensure fairness. The Lean proof would require:
1. An enumeration of all formula pairs (w, φ U ψ) over the countable chain
2. A construction that resolves each pair at a scheduled step
3. A proof that the resulting chain satisfies all Until obligations (using the scheduling fairness)
4. The step transfer for this specific chain (provable because the chain is constructed to include Until witnesses)

---

## Confidence Level

**High confidence (95%)**: The X-vs-G mismatch is fundamental and prevents any proof based on g_content propagation. The 4 Frame.lean sorries cannot be closed by any approach that:
- Works entirely within the existing `bx_le` ordering
- Uses only BX1-BX12 without additional construction structure

**High confidence (90%)**: CanonicalEmbedding:418 can be closed using the restricted parametric truth lemma approach (12-18h estimate from previous plan is realistic).

**Medium confidence (60%)**: A Henkin-style fair scheduling construction can close the Frame.lean sorries. This requires:
- Implementing a fair scheduling mechanism (new infrastructure, ~30-50h)
- Proving step transfer for the scheduled chain (novel, ~10-20h)
- Adapting Frame.lean and TruthLemma.lean (~10-20h)

**Low confidence (30%)**: Any approach based solely on modifying the bx_le definition or adding lemmas to the current BXCanonical structure will close the sorries without the fair scheduling construction.

---

## Summary Table

| Approach | Confidence | Effort | Status |
|----------|-----------|--------|--------|
| Formula-specific ordering | Low | - | BLOCKED: universal guard quantification |
| Temporal coherence integration | Low | - | BLOCKED: step transfer requires discreteness not in BX |
| Direct BX5+BX6+BX7 induction | Low | - | BLOCKED: same linearity gap, confirmed in Frame.lean comments |
| Henkin fair scheduling chain | Medium (60%) | 50-90h | VIABLE but requires substantial new infrastructure |
| CanonicalEmbedding:418 (independent) | High (90%) | 12-18h | VIABLE, well-scoped, independent of Frame.lean |
| Architecture spike: modify TaskModel semantics | Medium (50%) | 30-60h | Requires changing guard quantification semantics |
