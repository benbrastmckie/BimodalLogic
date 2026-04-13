# Teammate A Findings: Deep Analysis of Backward Until Step Transfer

**Date**: 2026-04-13
**Task**: 93 — Complete BXCanonical embedding
**Focus**: Backward Until coherence — the central unresolved blocker
**Files Examined**:
- `specs/093_complete_bxcanonical_embedding/handoffs/01_deferral-chain-handoff.md`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (sorry sites at lines 621, 627)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `Theories/Bimodal/Theorems/TemporalDerived.lean`
- `specs/093_complete_bxcanonical_embedding/reports/05_team-research.md`

---

## Key Findings

### 1. The Sorry Sites and Their Structure

The two active-path sorry sites for Until/Since coherence are:

**`bx_bfmcs_restricted_buc`** (line 621):
```lean
constructor <;> (intro t φ ψ _h_sub ⟨r, h_le, h_psi, h_guard⟩; sorry)
```
Goal after unfolding: given
- `N` : MCS, `s` : Int (the shift offset)
- `t` : Int (target time), `r` : Int with `t ≤ r`
- `ψ ∈ (shifted_bx_fmcs N h_N s).mcs r` = `ψ ∈ int_chain N h_N (r - s)`
- `∀ q, t ≤ q → q < r → φ ∈ (shifted_bx_fmcs N h_N s).mcs q`
  = `∀ q, t ≤ q → q < r → φ ∈ int_chain N h_N (q - s)`

Prove: `Formula.untl φ ψ ∈ int_chain N h_N (t - s)`

**`bx_bfmcs_restricted_fuc`** (line 627): symmetric forward Until case.

### 2. The Core Obstruction: `until_F_expansion` Has No Converse

The previous implementation attempt (handoff document) correctly identified:
- `until_F_expansion` (TemporalDerived.lean line 469) gives the FORWARD direction:
  `⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`
- The REVERSE direction `ψ ∨ (φ ∧ F(φ U ψ)) → (φ U ψ)` is **NOT a BX theorem**

Specifically the `φ ∧ F(φ U ψ)` branch says "φ holds now AND (φ U ψ) holds at some
future time", but this does NOT imply `(φ U ψ)` now if φ fails at intermediate times.

**However**, this analysis reveals a subtle error in how the contrapositive argument was formulated. Let me re-examine the correct chain of reasoning.

### 3. The Correct Contrapositive Argument — But It Has a Gap

The Round 5 team synthesis (05_team-research.md, lines 86-121) proposes:

1. Assume `¬(φ U ψ) ∈ chain(t)` [for contradiction]
2. `φ ∈ chain(t)` [given from guard]
3. By `until_F_expansion` (forward direction): `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`
   Contrapositive: `¬(ψ ∨ (φ ∧ F(φ U ψ))) → ¬(φ U ψ)`, i.e.,
   `¬ψ ∧ (¬φ ∨ ¬F(φ U ψ)) → ¬(φ U ψ)`
4. In chain(t): since `¬(φ U ψ) ∈ M` and `φ ∈ M` and M is an MCS:
   - From BX8 contrapositive: `¬(φ U ψ) → ¬ψ`, so `¬ψ ∈ chain(t)`
   - Since `φ ∈ chain(t)`, `¬φ ∉ chain(t)`, so the `¬φ` branch fails
   - Therefore `¬F(φ U ψ) ∈ chain(t)`, i.e., `G(¬(φ U ψ)) ∈ chain(t)`
5. By `int_chain_forward_G`: `¬(φ U ψ) ∈ chain(r)` for all r ≥ t
6. But `ψ ∈ chain(r)` and by BX8: `ψ → (φ U ψ)`, so `(φ U ψ) ∈ chain(r)`. Contradiction.

**The gap in step 4**: This derivation of `G(¬(φ U ψ)) ∈ chain(t)` from
`¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)` requires the REVERSE direction of
`until_F_expansion`:
- We need: `¬(φ U ψ) ↔ ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))`
- This is the BICONDITIONAL: `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))`
- Only the forward direction is available.

As the handoff document states: "the contrapositive argument IS the step transfer in disguise."

### 4. Deep Analysis: Why the Reverse Direction Cannot Be a BX Theorem

The reverse direction `ψ ∨ (φ ∧ F(φ U ψ)) → (φ U ψ)` says:
- If ψ holds now: `(φ U ψ)` follows from BX8. ✓
- If `φ ∧ F(φ U ψ)` holds now: φ now AND (φ U ψ) at some FUTURE s > t.
  But if φ fails on [t, s), the witnessing at s doesn't give (φ U ψ) at t.

Semantically, the falsifying model is: T = {0, 1, 2}, φ = {0}, ψ = {2}, s = 2.
At time 0: F(φ U ψ) holds (since φ U ψ holds at time 2 where φ holds and ψ holds).
At time 1: φ ∉ chain(1), so the guard from 0 to 2 is broken. Thus (φ U ψ) ∉ chain(0).
But `φ ∧ F(φ U ψ)` holds at 0. So the reverse direction fails.

### 5. The P-Step Approach Analysis

The handoff document proposes the "P-step approach" using `constrained_successor_from_seed`
which provides `p_content(successor) ⊆ u ∪ p_content(u)`.

**Why it doesn't directly solve backward Until step transfer**:

The P-step property says: if `P(α) ∈ v` (successor), then either `α ∈ u` or `P(α) ∈ u`.
Now, `backward_until_from_step` needs: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`.

From BX4': `(φ U ψ) → H(F(φ U ψ))`, so `(φ U ψ) ∈ chain(r+1)` implies
`F(φ U ψ) ∈ chain(r+1)`, which by h_content gives `F(φ U ψ) ∈ chain(r+1-1) = chain(r)`.
So `P(F(φ U ψ)) ∈ chain(r+1)`... This just gives F-wrap not the Until formula itself.

Alternatively: `(φ U ψ) ∈ chain(r+1)` means BX10: `F(ψ) ∈ chain(r+1)`.
Then `P(ψ)` in some backward chain... but this doesn't reconstruct `(φ U ψ)` at chain(r).

The P-step approach handles `p_content` (P-wrapped formulas), but `(φ U ψ)` is NOT
a P-formula. There is no direct P-step property for Until formulas.

### 6. The `until_witness_seed_consistent` Analogy

The most important insight from reading `WitnessSeed.lean` (line 342-415):

When `(φ U ψ) ∈ M`, to prove `{ψ} ∪ g_content(M)` is consistent:
1. Assume for contradiction `G(¬ψ) ∈ M`
2. Apply BX10: `(φ U ψ) → F(ψ)`, so `F(ψ) ∈ M`
3. But `F(ψ) = ¬G(¬ψ)`, contradiction with `G(¬ψ) ∈ M`

**This suggests an analogous approach for backward Until**. Instead of step transfer,
use the FORWARD existence of a witness directly:

Given the hypothesis structure for `bx_bfmcs_restricted_buc`:
- We have `ψ ∈ chain(r)` and `φ ∈ chain(q)` for q ∈ [t, r)
- We want `(φ U ψ) ∈ chain(t)`

**Proposed approach**:
1. Use `canonical_forward_U` (CanonicalFrame.lean line 199) which says:
   If `(φ U ψ) ∈ M`, then `∃ W: ExistsTask M W ∧ ψ ∈ W`
   — This is the WRONG direction; we need the CONVERSE.

2. The actual approach needed: Show that `¬(φ U ψ) ∉ chain(t)`.
   - The seed consistency argument works: if `¬(φ U ψ) ∈ chain(t)`, we derive a contradiction.
   - But to derive a contradiction from `¬(φ U ψ) ∈ chain(t)` without the biconditional,
     we need to use the EXTERNAL witnesses (ψ at chain(r), φ on [t,r)).

### 7. Why the External Witness Argument Fails Without Chain Properties

The fundamental issue: **the chain is not complete with respect to semantic witnesses**.

Given:
- `¬(φ U ψ) ∈ chain(t)` [MCS-level hypothesis]
- `ψ ∈ chain(r)` [from the outer Until existence hypothesis]
- `φ ∈ chain(q)` for q ∈ [t, r) [guard]

The external semantic witnesses exist (ψ at r, φ on [t,r)), but the canonical chain
is not GUARANTEED to "know" these witnesses are coherent from the perspective of chain(t)'s MCS.

The chain is built by Lindenbaum extension from seeds that control:
- `g_content` forward propagation
- `h_content` backward propagation
- Schedule-based F/P resolution

Nothing in the chain construction forces: "if ψ holds at chain(r) and φ holds on
[t,r), then (φ U ψ) must be in chain(t)". That would require chain(t)'s MCS to
somehow "know" about future chain states — which is circular.

### 8. Structural Diagnosis: The Completeness Gap

This is a genuine **semantic-syntactic gap** in the canonical model:

The standard completeness proof for Until in temporal logic uses one of three approaches:

**(A) Filtration**: Build the canonical model using finite quasimodels (Hintikka points).
  The quasimodel construction ensures Until coherence by construction.
  → This is the Quasimodel approach already partially in the codebase (`Quasimodel/`).

**(B) Direct filtration with subformula closure**: Restrict to formulas in the closure
  of the formula being proved, ensuring finite state space where Until must terminate.
  The restricted version (`restricted_backward_until_since_coherent`) is exactly this.

**(C) Maximal consistent chain with augmented seeds**: Modify the chain construction
  so that Until formulas are "self-reinforcing" at each step.

### 9. Viable Path: Using BX5 (Self-Accumulation) + BX10 Together

Key BX axiom inventory for backward Until:
- **BX5**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` — self-accumulation
- **BX8**: `ψ → (φ U ψ)` — reflexive introduction
- **BX9**: `(φ U ψ) → (φ ∨ ψ)` — elimination
- **BX10**: `(φ U ψ) → F(ψ)` — eventuality extraction

From `until_witness_seed_consistent`: when `(φ U ψ) ∈ M` and we assume `{ψ} ∪ g_content(M)`
is inconsistent, we get `G(¬ψ) ∈ M`, which contradicts `F(ψ) ∈ M` (from BX10).

**Analogous argument for backward Until**: to show `(φ U ψ) ∈ chain(t)`:
- Assume `¬(φ U ψ) ∈ chain(t)`
- We need a contradiction. We have external witnesses but cannot "inject" them into chain(t).
- The `canonical_forward_U` lemma would give us a witness IF we already had `(φ U ψ) ∈ chain(t)`.
  So this is circular.

**The canonical completeness proof genuinely requires a different chain construction
or additional axioms to close this gap.**

### 10. BX Axiom System Completeness vs. Chain Properties

Examining the BX axiom system (Axioms.lean, lines 22-34):
- BX5+BX6+BX7 (self-accumulation, absorption, linearity) are specifically designed
  to handle eventuality discharge in the Burgess-Xu tradition
- These axioms make BX complete for **linear orders** (the semantic target)
- But the canonical chain construction using dovetailed Lindenbaum chains is not
  the same as the direct construction from a quasimodel (filtration)

The tension: the dovetailed chain is well-suited for proving forward_F (via schedule)
but the backward Until coherence requires the chain to have a "semantic memory" of
the external witnesses.

---

## Recommended Approach

Based on thorough analysis, there are two viable paths, ordered by confidence:

### Path 1: Quasimodel/Hintikka Point Approach (HIGH CONFIDENCE, HIGH EFFORT)

The `Quasimodel/` directory already has partial infrastructure:
- `HintikkaPoint.lean`
- `Construction.lean`
- `Realization.lean`

The Hintikka point construction ensures backward Until by construction: a point satisfies
`(φ U ψ)` iff there is a REACHABLE point satisfying ψ with φ on the path. The
truth lemma for quasimodels is exact and doesn't require step transfer.

**Key advantage**: This bypasses the dovetailed chain entirely for the Until/Since cases.
The `fully_restricted_parametric_representation_from_neg_membership` already takes
`restricted_backward_until_since_coherent` as a hypothesis — if we can build a BFMCS
that satisfies this property via quasimodel instead of dovetailed chain, the proof goes through.

**Implementation sketch**:
1. Show that `bx_bfmcs` (already sorry-free for G/H coherence) also satisfies backward Until
   by showing the dovetailed chain CAN be augmented to be Until-coherent
   -- OR --
2. Build an alternative BFMCS from quasimodel points where Until coherence is definitional.

### Path 2: Augmented Seed with Until Persistence (MEDIUM CONFIDENCE, MEDIUM EFFORT)

**Modify `fwd_succ`** to include Until persistence formulas in the seed:

When building `chain(r+1)` from `chain(r)`, if `(φ U ψ) ∈ chain(r)` and `¬ψ ∈ chain(r)`,
add `(φ U ψ)` directly to the seed for `chain(r+1)`.

**Why this might work**: BX5 gives `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. This means
at intermediate points, `(φ ∧ (φ U ψ))` holds. If we carry `(φ U ψ)` in the seed,
we get `(φ U ψ) ∈ chain(r+1)` whenever `(φ U ψ) ∈ chain(r)` and `¬ψ ∈ chain(r)`.

This provides the FORWARD step transfer for backward induction:
`(φ U ψ) ∈ chain(r) ∧ ¬ψ ∈ chain(r) → (φ U ψ) ∈ chain(r+1)`

Wait — backward induction goes from `chain(r)` to `chain(r-1)`, so we'd need the
BACKWARD direction. The forward chain step transfer says:
`(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`

which is what `backward_until_from_step` needs. This cannot be established by
forward propagation of Until formulas in seeds.

**Revised Path 2**: Add h_content-style BACKWARD propagation for Until formulas.

The BX4' axiom: `φ → H(F(φ))`. This gives `(φ U ψ) → H(F(φ U ψ))`.
So if `(φ U ψ) ∈ chain(r+1)`, then `F(φ U ψ) ∈ chain(r)` via H-propagation.
But `F(φ U ψ) ∈ chain(r)` does NOT give `(φ U ψ) ∈ chain(r)` unless we use
the BX expansion biconditional (which we don't have).

### Path 3: The BX5 + Until-Carrying Seed (NOVEL, REQUIRES VERIFICATION)

**Key observation**: BX5 `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` guarantees that
in the SEMANTIC model, `(φ U ψ)` persists at EVERY intermediate point.

The canonical chain construction can leverage this if we add:
- When `(φ U ψ) ∈ chain(r)`, add `(φ U ψ)` to the seed for `chain(r+1)`
  (call this "Until carry")
- Prove the seed is consistent: `(φ U ψ)` is consistent with g_content because
  if `G(¬(φ U ψ)) ∈ chain(r)`, then `¬(φ U ψ) ∈ chain(r)`, contradicting `(φ U ψ) ∈ chain(r)`.

If Until formulas are carried FORWARD in seeds, then backward induction works as follows:
- We have `ψ ∈ chain(r)`, so `(φ U ψ) ∈ chain(r)` by BX8
- For `chain(r-1)`: if we can show `(φ U ψ) ∈ chain(r)` means chain(r) was built with
  `(φ U ψ)` in its SEED (from chain(r-1)), then... this is again circular.

**The fundamental obstacle**: Until carry in the seed is a FORWARD property
(from chain(n) to chain(n+1)), but backward Until needs a BACKWARD property.

---

## Evidence/Examples

### Evidence for the Gap Being Real

The `until_persists_through_succ` theorem in SuccRelation.lean (line 542) is BLOCKED:
```lean
theorem until_persists_through_succ (u v : Set Formula)
    (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v) (h_succ : Succ u v)
    (φ ψ : Formula) (h_U : Formula.untl φ ψ ∈ u) (h_neg_psi : Formula.neg ψ ∈ u) :
    Formula.untl φ ψ ∈ v := by
  -- BLOCKED: requires X-content propagation infrastructure.
  sorry
```

The comment at line 529-540 explains precisely why: the BX system gives
`(⊥ U (ψ ∨ (φ ∧ (φ U ψ))))` from BX5+BX9+BX8, but there is NO G-wrapped Until
formula to propagate via g_content. This is the same obstacle we face.

### Evidence for Path 1 Being Viable

The `Quasimodel/Construction.lean` file exists and contains a Hintikka point construction.
The `Quasimodel/Realization.lean` presumably gives a completeness argument.
The truth lemma approach (fully_restricted_parametric_representation_from_neg_membership)
in RestrictedParametricTruthLemma.lean takes `restricted_backward_until_since_coherent` as
a parameter — so if we can provide this from ANY BFMCS (not necessarily the dovetailed chain),
the proof goes through.

---

## Confidence Level

**Diagnosis (Gap is real, forward chain cannot give backward Until step transfer)**: HIGH (95%)

**Path 1 (Quasimodel)**: HIGH confidence that it's mathematically correct.
Implementation effort: HIGH (requires understanding Quasimodel infrastructure and linking it to bx_bfmcs).

**Path 2/3 (Augmented seeds)**: MEDIUM confidence that it's even formulable correctly.
The fundamental direction mismatch (forward construction, backward step needed) is a serious obstacle.

**Novel observation**: The `until_witness_seed_consistent` proof in WitnessSeed.lean
shows that FORWARD Until (finding the witness) uses `BX10 + G(¬ψ) ∉ M` argument.
There is a SYMMETRIC argument for backward Until: if we had the canonical forward U
construction (canonical_forward_U), we could prove backward Until coherence by showing
the chain eventually resolves (φ U ψ) — but this requires the chain to be complete
in the sense of Until witnesses, which is exactly forward Until coherence.

This confirms: **forward Until coherence (forward_F + schedule) is a PREREQUISITE
for backward Until coherence in the dovetailed chain construction**.

The critical dependency chain is:
1. Deferral seed modification → restricted forward_F (Phase 2/3A)
2. Restricted forward_F → forward Until witness existence → backward Until coherence

If this dependency is correct, then backward Until IS provable AFTER forward_F is established,
using the argument: `¬(φ U ψ) ∈ chain(t)` leads to contradiction via:
- From BX10: `¬(φ U ψ) → ¬F(ψ) = G(¬ψ)` [NOT VALID — only (φ U ψ) → F(ψ), not converse]

So this path also fails. **Backward Until in the dovetailed chain fundamentally requires
either chain modification or a different approach to Until coherence entirely.**

**Best recommendation**: Focus the next implementation round on understanding the
Quasimodel construction and whether it can be wired to the algebraic truth lemma directly.
This is mathematically cleaner and avoids the fundamental obstacle of until step transfer.
