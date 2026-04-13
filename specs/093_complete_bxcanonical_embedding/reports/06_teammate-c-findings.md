# Teammate C Findings: Critical Validation of Backward Until Alternatives

## Session: sess_1744562000_c3b7d1
## Date: 2026-04-13
## Role: Critic — validate alternatives and identify hidden assumptions

---

## 1. Key Findings

### 1.1 What the Blocker Actually Is

The backward Until coherence (`bx_bfmcs_restricted_buc`) needs to prove the **step transfer property**:

```
(φ U ψ) ∈ fam.mcs (r + 1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

This is needed because `backward_until_from_step` (UntilSinceCoherence.lean:111-138) is already proved and parameterizes over exactly this step transfer. The sorry at CanonicalModel.lean:621 reads:
```lean
constructor <;> (intro t φ ψ _h_sub ⟨r, h_le, h_psi, h_guard⟩; sorry)
```

The sorry is in the Until and Since case simultaneously. The Until case requires step transfer; the Since case requires an analogous past step transfer.

### 1.2 Current Chain Construction (int_chain)

The `int_chain` builds forward via `fwd_succ` (which seeds `{ψ} ∪ g_content(M)` or `g_content(M) ∪ f_carry(M)`) and backward via `bwd_pred` (which seeds `{ψ} ∪ h_content(M)` or `h_content(M) ∪ p_carry(M)`). The chain provides:
- **G-persistence**: `g_content(chain(r)) ⊆ chain(r+1)` (CanonicalModel.lean:245)
- **H-persistence**: `h_content(chain(r+1)) ⊆ chain(r)` (CanonicalModel.lean:269)

G-persistence means: if `G(φ U ψ) ∈ chain(r)`, then `(φ U ψ) ∈ chain(r+1)`. But for step transfer, we need to go BACKWARD: `(φ U ψ) ∈ chain(r+1) → (φ U ψ) ∈ chain(r)` (when `φ ∈ chain(r)`). H-persistence doesn't help because `φ U ψ` is not an H-formula.

---

## 2. Critical Analysis of Alternative 1: P-Step Approach

**Claim in handoff**: Use `constrained_successor_from_seed` which gives the P-step property: `p_content(successor) ⊆ u ∪ p_content(u)`.

### 2.1 What constrained_successor_from_seed Actually Provides

From `SuccExistence.lean` (lines 506-624), `constrained_successor_from_seed u h_mcs h_F_top` provides:

1. **G-persistence**: `g_content(u) ⊆ successor` (line 545)
2. **F-step**: `f_content(u) ⊆ successor ∪ f_content(successor)` (line 555)
3. **Succ relation**: both above jointly = `Succ u successor` (line 576)
4. **P-step**: `p_content(successor) ⊆ u ∪ p_content(u)` (line 596)

The P-step property says: if `P(φ) ∈ successor`, then `φ ∈ u` OR `P(φ) ∈ u`.

**What we need for backward Until step transfer**:
If `(φ U ψ) ∈ successor` and `φ ∈ u`, then `(φ U ψ) ∈ u`.

### 2.2 Fatal Gap in Alternative 1

The P-step property gives information about `P`-formulas in the successor. But `(φ U ψ)` is an **Until formula**, not a P-formula. The P-step property says nothing about Until formulas in the successor.

The handoff's description of this approach is:
> `P(phi U psi) in chain(r+1)` gives `(phi U psi) in chain(r) v P(phi U psi) in chain(r)`. Iterate backward.

This is mathematically valid IF we can establish `P(φ U ψ) ∈ chain(r+1)`. But where does `P(φ U ψ)` come from?

**Hidden assumption**: To apply P-step, we need `P(φ U ψ) ∈ successor`. But the hypothesis gives us `(φ U ψ) ∈ successor`. We'd need `(φ U ψ) ∈ successor → P(φ U ψ) ∈ successor`. This is NOT guaranteed — P-step only tells us about formulas of the form `P(χ)`, not how to derive them.

Moreover, even if we could derive `P(φ U ψ) ∈ successor`, P-step gives: `(φ U ψ) ∈ u ∨ P(φ U ψ) ∈ u`. The right disjunct just pushes the problem one step earlier — we get an infinite regress.

**The handoff acknowledges this**: "needs a bounded witness or termination argument". There is no termination argument available: the backward chain is infinite, and `P(φ U ψ)` could propagate indefinitely without resolving.

**Additionally**: `constrained_successor_from_seed` requires `Formula.some_future (Formula.neg Formula.bot) ∈ u` (i.e., `F(⊤) ∈ u`). This is a non-trivial prerequisite: it holds when the chain position is not "maximal" in the temporal order, but for the BX canonical chain (which ranges over all of Int), this needs to be verified at every backward step. This is a second hidden assumption.

**Verdict on Alternative 1**: The P-step approach does NOT directly provide backward Until step transfer. It addresses P-formula propagation, not Until-formula propagation. The "iterate backward" argument has no termination and the approach conflates P-formulas with Until-formulas.

---

## 3. Critical Analysis of Alternative 2: Until-Induction Axiom

**Claim**: Add a BX-derivable Until induction axiom that gives the biconditional `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))`.

### 3.1 Status of until_induction in the Codebase

The `until_induction` axiom was **removed** from BX. Evidence from:
- `Soundness.lean:794`: Lists `until_induction_valid` as explicitly removed
- `FiniteDeferral.lean:325`: Contains `sorry /- until_induction removed in BX -/`
- The `Axiom` inductive type (Axioms.lean) has 37 constructors and NO `until_induction`

The current BX axiom set does have `self_accum_until` (BX5) and `absorb_until` (BX6) which together handle eventuality resolution. But the classical `until_induction` schema `G(ψ→χ) ∧ G((φ∧χ)→G(χ)) → ((φ U ψ) → χ)` is absent.

### 3.2 Can the Biconditional Be Derived from BX?

The handoff proves `until_F_expansion: (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))` (forward direction).

The REVERSE direction `ψ ∨ (φ ∧ F(φ U ψ)) → (φ U ψ)`:
- `ψ → (φ U ψ)`: YES, this is BX8 (`refl_intro_until`)
- `φ ∧ F(φ U ψ) → (φ U ψ)`: means "φ now and (φ U ψ) at some future time implies (φ U ψ) now"

**Is `φ ∧ F(φ U ψ) → (φ U ψ)` valid semantically?** Under reflexive Until semantics:
- `F(φ U ψ)` at t means ∃s ≥ t, (φ U ψ) holds at s
- `(φ U ψ)` at s means ∃r ≥ s, ψ(r) and φ on [s, r)
- If φ(t) holds and (φ U ψ) holds at some s ≥ t, then ψ(r) for some r ≥ s ≥ t, and φ on [s, r)
- We need φ on [t, r): we have φ(t) but NOT necessarily φ on (t, s)

So the reverse direction is **semantically invalid**. Consider: t < s, φ fails at t+1, ψ holds at s. Then F(φ U ψ) holds at t (via s), φ holds at t, but (φ U ψ) does NOT hold at t because φ fails at t+1 before the witness s.

**Verdict on "Until-induction axiom" alternative**: The biconditional is not valid in all BX models. Adding it would make the system unsound. Furthermore, even if the reverse direction were derivable, obtaining `G(neg(phi U psi)) ∈ M` from `neg(phi U psi) ∈ M` still requires the full biconditional as an MCS-level equivalence, not just an implication. This approach is **mathematically incorrect**.

---

## 4. Critical Analysis of Alternative 3: Chain Reconstruction via Quasimodel

**Claim**: Use `Quasimodel/Construction.lean`'s Hintikka point construction instead of the dovetailed Lindenbaum chain.

### 4.1 What the Quasimodel Infrastructure Provides

The quasimodel construction (Construction.lean) provides:
- `hintikka_step`: G-propagation + H-backward + Until defect propagation (lines 46-52)
- `UntilDefect`: Tracks unresolved Until formulas (line 58)
- `defect_count`: Decreasing measure for termination (line 75)

Critically, `hintikka_step` includes: "if `φ U ψ ∈ h1` and `ψ ∉ h1`, then `φ ∈ h1` and `φ U ψ ∈ h2`" (line 51). This is **FORWARD Until propagation** (defect propagation from h1 to h2 in the forward direction), not backward step transfer.

### 4.2 Does Quasimodel Work at the int_chain Level?

The quasimodel infrastructure operates over **finite Hintikka points** within a fixed `Sigma : Finset Formula`. The `BXPoint` type lives in the BXCanonical frame (a preorder on MCS). The Realization.lean file (lines 20-36) explicitly states:

> "The sorry root cause analysis has been moved to `CanonicalChain.lean`. The key insight: the guard property in these signatures is mathematically correct but appears unprovable from BX1-BX12 due to non-totality of the `bx_le` preorder."

The quasimodel construction in this codebase is designed to prove **forward** eventuality resolution (`until_eventuality_resolution` in Frame.lean:623-644 and its delegate in LocusControl.lean). It does NOT address backward step transfer at all.

### 4.3 Hidden Assumptions in Alternative 3

1. **Compatibility assumption**: The quasimodel is over a finite signature `Sigma`. The `int_chain` is over all formulas. Projecting to a finite signature loses information that may be needed for backward Until.

2. **Direction confusion**: `hintikka_step` propagates Until formulas FORWARD (if `φ U ψ ∈ h1` and `ψ ∉ h1`, the defect propagates to `h2`). Backward step transfer needs propagation BACKWARD. These are different requirements.

3. **Integration assumption**: Replacing `int_chain` with a quasimodel-based chain would break all downstream lemmas (`box_stable_in_int_chain`, `int_chain_forward_G`, `int_chain_h_content`, etc.) which are built specifically on the `fwd_succ`/`bwd_pred` structure.

**Verdict on Alternative 3**: The quasimodel infrastructure in this codebase is designed for forward Until resolution, not backward step transfer. Using it for backward Until would require fundamentally different construction.

---

## 5. Fourth Approach: Directly Enrich Backward Seeds with Until-Formulas

### 5.1 The Core Insight

The backward step transfer `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)` is exactly what an enriched `bwd_pred` seed could provide, if we add `(φ U ψ) ∈ chain(r+1)` as a "backward Until carry" to the seed at position r.

**New Approach**: Modify `bwd_pred` to carry Until formulas backward under the guard condition. Specifically:

Define `until_carry(M) = {(φ U ψ) | (φ U ψ) ∈ M}` — all Until formulas in M. Then for backward seeds, include `until_carry(successor) ∩ {φ U ψ | φ ∈ predecessor_candidate}`.

But this is circular (we need φ ∈ predecessor to know what to include in the predecessor seed).

### 5.2 A Cleaner Version: BX12 + Step via F

BX12 states: `F(φ) → (⊤ U φ)`. And BX10: `(φ U ψ) → F(ψ)`.

If `(φ U ψ) ∈ chain(r+1)`, then by BX10: `F(ψ) ∈ chain(r+1)`. Since `F(ψ) ∈ chain(r+1)`, the backward step construction (via `bwd_pred`) could resolve `P(F(ψ))` backward... but this brings us back to P-step territory, not Until territory.

### 5.3 The Genuine Fourth Approach: Contrapositive via BX5 + BX6

There IS a potentially valid approach using BX5 (self-accumulation) and the MCS completeness:

In an MCS M where `φ ∈ M` and `neg(φ U ψ) ∈ M`:
- By BX5: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. Contrapositive: `neg((φ ∧ (φ U ψ)) U ψ) → neg(φ U ψ)`.
- By BX9: `(φ U ψ) → φ ∨ ψ`. So `neg(φ U ψ)` at current time, combined with `φ` at current time, forces `neg(ψ)` at current time.
- By BX10+BX1: if also `F(ψ) ∈ M` (which follows from `(φ U ψ) ∈ chain(r+1)` via BX10 and bwd chain construction)...

Actually this approach also stalls. The fundamental issue: standard BX axioms characterize linear-order Until axiomatically but do NOT include a backward propagation rule like `(φ U ψ)(t+1) ∧ φ(t) → (φ U ψ)(t)`.

---

## 6. Recommended Approach

After critical analysis, **Alternative 2 (Until-induction axiom) is wrong**. **Alternative 1 (P-step)** misidentifies what the P-step provides. **Alternative 3 (Quasimodel)** addresses the wrong direction.

The correct path is:

### 6.1 Approach: Enrich bwd_pred Seed Directly with Until-Content

Instead of trying to use the P-step property or Until-induction, directly add Until formulas from the successor to the backward seed, as follows:

Define `until_back_carry(M_succ, M_pred_candidate)` = those Until formulas `(φ U ψ) ∈ M_succ` such that `φ` is in the `h_content` extension of M_pred_candidate.

This is still circular. A cleaner breaking of the circularity:

**Approach A**: Build the backward chain as a sequence where EACH backward step uses a seed of the form:
```
h_content(M) ∪ p_carry(M) ∪ {(φ U ψ) | (φ U ψ) ∈ M ∧ φ ∈ hContent-seed}
```

The consistency of this enriched seed requires proving that adding Until formulas that are "inherited" from M (and satisfy the guard at the new position) is consistent. This requires a new proof analogous to `forward_temporal_witness_seed_consistent` but for backward Until carry.

**Critical observation**: If `(φ U ψ) ∈ M_succ` and `φ ∈ M_pred`, then in any MCS where both are in, we need to derive `(φ U ψ) ∈ M_pred`. This derivability depends on whether the BX axioms support it — and the answer from Soundness.lean:794 is that the removed `until_induction` (which would provide this) is NOT in BX.

### 6.2 The Correct Resolution: Use BX Self-Accumulation to Discharge the Guard

The cleanest resolution that's actually provable from BX axioms is:

**If we can show that in the chain, every position where `(φ U ψ)` is absent is a "witness position" (ψ holds there)**, then backward step transfer is vacuous (ψ already resolves it). This is possible when we RESTRICT to formulas in `subformulaClosure(root)` — the restricted coherence condition.

For `restricted_backward_until_since_coherent`, we only need step transfer for formulas `(φ U ψ) ∈ subformulaClosure(root)`. The restriction does NOT by itself make the proof easier — we still need the step.

### 6.3 The Most Promising Approach: Reuse until_witness_seed (Phase 3 alternative)

The until witness seed proof (`until_witness_seed_consistent`) already exploits `until_induction` indirectly via the `until_F` axiom (BX10) + the argument that `{ψ} ∪ g_content(M)` is consistent when `(φ U ψ) ∈ M`.

For backward step transfer, an analogous argument would be: given `(φ U ψ) ∈ chain(r+1)` and `φ ∈ chain(r)`, can we prove `(φ U ψ) ∈ chain(r)` by consistency? The answer requires proving that `{(φ U ψ)} ∪ h_content(chain(r))` is consistent, which requires:
- Assume inconsistent: then `H(neg(φ U ψ)) ∈ chain(r)` (by generalized temporal K argument)
- Since `h_content(chain(r)) ⊆ chain(r+1)` (via H-persistence)... WAIT: `H(neg(φ U ψ))` is an H-formula, so `neg(φ U ψ) ∈ chain(r+1)` (by H-persistence applied backward)
- But `(φ U ψ) ∈ chain(r+1)` — contradiction!

**This argument WORKS!**

More precisely: if `{(φ U ψ)} ∪ h_content(chain(r))` is inconsistent, derive `H(neg(φ U ψ)) ∈ chain(r)` (by generalized temporal K). Since `H(neg(φ U ψ))` is an H-formula, `int_chain_backward_H` gives `neg(φ U ψ) ∈ chain(r+1)`. But `(φ U ψ) ∈ chain(r+1)` is our hypothesis. Contradiction.

**Wait — this proves that `{(φ U ψ)} ∪ h_content(chain(r))` is consistent**. By Lindenbaum, there's an MCS extending it. But we need `(φ U ψ) ∈ chain(r)` in the SPECIFIC chain position, not just some extension.

The problem is that `h_content(chain(r))` is a proper subset of `chain(r)`. Adding `(φ U ψ)` to `h_content(chain(r))` is consistent, but `chain(r)` may have already decided `neg(φ U ψ)`. However! If `{(φ U ψ)} ∪ h_content(chain(r))` is consistent, and `chain(r)` is an MCS extending `h_content(chain(r))`, then... it's possible that `chain(r)` has `neg(φ U ψ)`. We'd need the seed to INCLUDE `(φ U ψ)`.

This circles back to the seed enrichment problem. The correct fix is at the seed level.

---

## 7. Hidden Assumptions Summary

| Alternative | Hidden Assumption | Status |
|-------------|------------------|--------|
| P-step (Alt 1) | P(φ U ψ) ∈ successor from (φ U ψ) ∈ successor | NOT derivable |
| P-step (Alt 1) | Termination of backward P(φ U ψ) propagation | No bounded witness |
| P-step (Alt 1) | F(⊤) ∈ u holds at all backward chain positions | Needs verification |
| Until-induction (Alt 2) | Biconditional reverse direction is valid | SEMANTICALLY FALSE |
| Quasimodel (Alt 3) | Hintikka step provides backward step transfer | DIRECTIONALLY WRONG |
| Quasimodel (Alt 3) | Quasimodel compatible with int_chain structure | INCOMPATIBLE |

---

## 8. Most Viable New Approach

**Enrich `bwd_pred` seed with carried-backward Until formulas**:

Define `until_backward_carry(M) = {(φ U ψ) ∈ M | ...}` and prove consistency of `h_content(M_pred_seed) ∪ p_carry(M_pred_seed) ∪ until_backward_carry(M_succ)`.

The consistency proof would use: if this seed is inconsistent, derive a contradiction using the fact that `(φ U ψ) ∈ M_succ` and `h_content` is backward closed.

However, the GUARD condition `φ ∈ chain(r)` creates a circularity: we don't know what's in chain(r) until we build it, but we need to know the guard to select which Until formulas to carry.

**Resolution**: Carry ALL Until formulas from chain(r+1) backward (without the guard filter). Then step transfer holds vacuously for those where `φ ∉ chain(r)` (since `neg(φ) ∈ chain(r)` would contradict `φ U ψ ∈ chain(r)` via BX9, which forces `φ ∨ ψ` at current time). Wait — actually BX9 gives `φ ∨ ψ` at the WITNESS position, not at current position.

The cleanest approach that avoids all these issues: **Prove that the int_chain already satisfies step transfer by an indirect argument that doesn't modify the seed**.

Specifically: given `(φ U ψ) ∈ chain(r+1)` and `φ ∈ chain(r)`, use BX10 to get `F(ψ) ∈ chain(r+1)`, then via p_carry or the temporal structure, derive `P(F(ψ)) ∈ chain(r+1)`, then H-persistence gives... no, this doesn't help.

**Actual conclusion**: No clean alternative avoids seed modification. The most structurally sound approach remains the **seed enrichment** of `bwd_pred` with Until-carry formulas, with a proof that the enriched seed is consistent. The consistency proof DOES work (as outlined above in Section 6.3), and the chain position issue can be resolved by including Until-carry in the seed at construction time rather than trying to derive it afterward.

---

## 9. Confidence Level

| Assessment | Confidence |
|-----------|-----------|
| Alternative 1 (P-step) is insufficient as described | HIGH |
| Alternative 2 (Until-induction) is semantically unsound | VERY HIGH |
| Alternative 3 (Quasimodel) addresses wrong direction | HIGH |
| Seed enrichment approach is the correct path | MEDIUM |
| Seed consistency proof sketched in 6.3 is sound | MEDIUM-HIGH |
| No approach derives step transfer without seed modification | HIGH |

The fundamental insight: the BX axiom system does NOT include a backward-propagation rule for Until (this would be a discrete/step axiom). Therefore, step transfer cannot be proved at the MCS level from BX axioms alone. It must be **built into the chain construction** via appropriately enriched seeds.

---

## Evidence and References

- `CanonicalModel.lean:617-622` — sorry location for `bx_bfmcs_restricted_buc`
- `UntilSinceCoherence.lean:111-138` — `backward_until_from_step` (already proved, needs step transfer hypothesis)
- `SuccExistence.lean:596-624` — `successor_p_step` (P-step for P-formulas, NOT Until-formulas)
- `Axioms.lean:67-264` — Complete BX axiom set (37 constructors, no until_induction)
- `Soundness.lean:794` — Explicit note that `until_induction` was removed
- `Truth.lean:128-129` — Until semantics: `∃ s ≥ t, ψ(s) ∧ ∀r ∈ [t,s), φ(r)`
- `WitnessSeed.lean:342-377` — `until_witness_seed_consistent` proof technique (model for seed consistency proofs)
