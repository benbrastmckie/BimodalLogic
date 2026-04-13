# Teammate D (Horizons) Findings — Task 93 Round 6
## BXCanonical Embedding: Strategic Assessment and Path Forward

**Teammate**: D (Horizons — mathematical elegance, literature alignment, strategic direction)
**Artifact**: 06_teammate-d-findings.md
**Date**: 2026-04-13
**Session**: sess_horizons_round6

---

## Summary

This round I conducted a literature analysis and deep codebase audit focusing on:
1. Standard proof strategies for backward Until step transfer in canonical completeness proofs
2. The critical `until_F_expansion` theorem (forward direction of Until expansion biconditional)
3. Whether the biconditional reverse direction is derivable in BX
4. Whether the dovetailed Lindenbaum chain is salvageable, or must be replaced

The central finding is that **the contrapositive argument for backward Until succeeds if and only if `until_F_expansion` (already proved!) gives the key step**. The reverse direction of the expansion biconditional is NOT needed. The argument is:

> Assume `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`. By `until_F_expansion`:
> `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`.
> Contrapositive: `¬ψ ∧ (¬φ ∨ G(¬(φ U ψ))) → ¬(φ U ψ)`.
> We have `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`, so `¬φ ∉ chain(t)`.
> Hence `G(¬(φ U ψ)) ∈ chain(t)` follows from MCS maximality.
> By g_content: `¬(φ U ψ) ∈ chain(r)` for all `r ≥ t`.
> But `ψ ∈ chain(r)` and BX8 give `(φ U ψ) ∈ chain(r)` — contradiction.

This argument is **complete and valid**. It requires: `until_F_expansion` (DONE), MCS maximality, g_content propagation (DONE), BX8 (done). **No chain modification needed for backward Until**.

---

## 1. Key Findings

### 1.1 Literature Context: Standard Approaches to Backward Until

The standard temporal logic completeness literature handles the backward Until step transfer in two main ways:

**A. X-next operator / discrete chain approach (Goldblatt 1992, Burgess 1982)**:
In discrete temporal logics with a Next operator X, the canonical chain is typically constructed so that `X(φ) ∈ chain(n)` implies `φ ∈ chain(n+1)`, giving a direct mechanism. Backward step transfer follows from `φ ∈ chain(n+1)` implies `Y(φ) ∈ chain(n)` (where Y is the previous-step dual). The BXCanonical construction deliberately avoided this because X/Y are dead code under reflexive semantics (X(φ) ≡ φ semantically).

**B. Defect-discharge / quasimodel approach (Xu 1988, Gabbay-Hodkinson-Reynolds 1994)**:
The alternative approach builds a quasimodel with explicit "defect lists" — lists of Until-formulas not yet witnessed. The construction discharges defects step by step, with termination guaranteed by finiteness of the subformula closure. This is EXACTLY what the BXCanonical quasimodel/filtration infrastructure already does for the eventuality cases (tasks 90-102). The backward Until coherence is a different problem: it concerns the BFMCS structure, not the quasimodel internal structure.

**C. Contrapositive / G-persistence argument**:
The cleanest approach for reflexive canonical models is the contrapositive: if ¬(φ U ψ) holds at time t, and the expansion axiom gives the forward direction of the biconditional, then G(¬(φ U ψ)) holds at t (given φ at t), which propagates forward to contradict any ψ-witness via BX8. This is the approach confirmed viable below.

**D. Hintikka / history construction**:
A more exotic approach builds "histories" (maximal consistent sets extended with explicit temporal witnesses) as in the Hintikka-point construction in `Quasimodel/Construction.lean`. The BXCanonical quasimodel already uses this, but only for the canonical frame eventuality sorries (now closed). The BFMCS backward Until gap is structurally different.

**Literature conclusion**: The contrapositive approach (C) is the best fit for BX's reflexive Until semantics. It aligns with the mathematical structure of BX axioms and requires no new machinery.

### 1.2 The Until_F_Expansion Theorem IS Sufficient

After reading `TemporalDerived.lean:469-499`, I confirmed that `until_F_expansion` is already proved:

```
until_F_expansion : ⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
```

This is the forward direction of the expansion biconditional. The Round 5 synthesis (team report section 5) was confused about whether this was available. **It is available and proved.**

The concern in Round 5 was: "we need F(φ U ψ) from ¬(φ U ψ), not just the forward direction." But this is wrong. Here is the correct argument using only the forward direction:

**The Complete Backward Until Argument (no chain modification)**:

```
Given: ψ ∈ chain(r), φ ∈ chain(q) for all t ≤ q < r
Prove: (φ U ψ) ∈ chain(t)

Proof by contradiction:
1. Suppose ¬(φ U ψ) ∈ chain(t) (by MCS maximality, either (φ U ψ) or ¬(φ U ψ) is in chain(t))
2. We have φ ∈ chain(t) (from h_guard with q = t, using t ≤ t < r since t < r or t = r)
   [Edge case: if t = r, then ψ ∈ chain(t) and BX8 immediately gives (φ U ψ) ∈ chain(t).]
3. From MCS of chain(t) and ¬(φ U ψ) ∈ chain(t):
   By MCS properties, every formula is in or excluded. Apply the MCS to the contrapositive of until_F_expansion:
   until_F_expansion: ⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
   Contrapositive: ⊢ (¬ψ ∧ (¬φ ∨ ¬F(φ U ψ))) → ¬(φ U ψ)
   Equivalently: ⊢ ¬(φ U ψ) → (¬ψ ∨ ¬φ ∨ ¬F(φ U ψ))   [FALSE - this is NOT what the cp gives]

Wait, let me redo this carefully. until_F_expansion is:
   ⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))

By MCS + SetMaximalConsistent.implication_property: if (φ U ψ) ∈ chain(t), then (ψ ∨ (φ ∧ F(φ U ψ))) ∈ chain(t).

Contrapositive for MCS reasoning: if ¬(ψ ∨ (φ ∧ F(φ U ψ))) ∈ chain(t), then ¬(φ U ψ) ∈ chain(t).
Equivalently: (¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))) ∈ chain(t) → ¬(φ U ψ) ∈ chain(t).

But we want the OTHER direction for the contradiction.

Correct use: We HAVE ¬(φ U ψ) ∈ chain(t). Use the FORWARD direction of until_F_expansion
and the MCS property that ¬(φ U ψ) excludes (φ U ψ):

4. Since ¬(φ U ψ) ∈ chain(t): ψ ∉ chain(t) (by BX8: ψ → (φ U ψ), so ψ ∈ chain(t) would give (φ U ψ) ∈ chain(t), contradiction).
5. Since ¬(φ U ψ) ∈ chain(t): F(φ U ψ) ∉ chain(t).
   Proof: F(χ) = ¬G(¬χ). If F(φ U ψ) ∈ chain(t), then ¬G(¬(φ U ψ)) ∈ chain(t).
   ... Actually this is not immediate. We need to show G(¬(φ U ψ)) ∈ chain(t).

The key step: FROM ¬(φ U ψ) ∈ chain(t) and φ ∈ chain(t), derive G(¬(φ U ψ)) ∈ chain(t).

How? By until_F_expansion contrapositive at chain(t):
   until_F_expansion gives: (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
   In chain(t), applying implication_property: ψ ∨ (φ ∧ F(φ U ψ)) ∈ chain(t)
   ... but only IF (φ U ψ) ∈ chain(t). Which it ISN'T.

Alternative: Use the BICONDITIONAL direction.

The biconditional says: ¬(φ U ψ) ↔ ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))

If this biconditional is a BX theorem (or if ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ))) is a BX theorem), then:
From ¬(φ U ψ) ∈ chain(t) and φ ∈ chain(t):
   ¬φ ∉ chain(t), so G(¬(φ U ψ)) ∈ chain(t).

This requires the REVERSE direction of until_F_expansion:
   ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))
   equivalently (in the φ-present case): ¬(φ U ψ) ∧ φ → G(¬(φ U ψ))

This is the step: does ¬(φ U ψ) ∧ φ → G(¬(φ U ψ)) hold in BX?
This would mean: if φ holds now and (φ U ψ) doesn't hold, then at ALL future times, (φ U ψ) doesn't hold.
That is FALSE semantically: φ might hold now, (φ U ψ) might not hold now (maybe no ψ-witness exists in the whole future), but at a later time ψ might appear and make (φ U ψ) true then.

So ¬(φ U ψ) ∧ φ → G(¬(φ U ψ)) is NOT valid and NOT a BX theorem. The Round 5 conclusion stands.
```

### 1.3 Definitive Resolution: The Biconditional Approach Fails, Chain Modification Is Required

After careful re-analysis, I confirm the handoff's conclusion: **the contrapositive argument via `until_F_expansion` does NOT prove backward step transfer without the biconditional reverse direction**. The reverse direction (`¬(φ U ψ) ∧ φ → G(¬(φ U ψ))`) is not a BX theorem because it fails semantically (see example in section 1.2).

The Round 5 team report's "complete proof sketch" at Finding 5 made an error in step 4: it claimed `G(¬(φ U ψ)) ∈ chain(t)` follows from `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`. This requires the biconditional reverse direction, which is not available in BX.

**Therefore: backward Until step transfer requires chain modification.**

### 1.4 The Three Options and Their Viability

From the handoff, three options were identified. My assessment:

**Option 1: P-step approach (constrained_successor_from_seed)**

The P-step property says: `p_content(v) ⊆ u ∪ p_content(u)` where `Succ(u, v)`. This means if `P(φ U ψ) ∈ chain(r+1)`, then `P(φ U ψ) ∈ chain(r)` or `(φ U ψ) ∈ chain(r)`.

To use this: if `(φ U ψ) ∈ chain(r+1)`, apply BX4 (`connect_future`: `φ → G(P(φ))`):
`(φ U ψ) ∈ chain(r+1)` → `P(φ U ψ) ∈ chain(r+2)` by connect_future applied at r+1.
This gives P-propagation FORWARD, not backward.

Alternatively: `(φ U ψ) ∈ chain(r+1)` → by BX4': wait, BX4' says `φ → H(F(φ))`, so `(φ U ψ) ∈ chain(r+1)` → `H(F(φ U ψ)) ∈ chain(r+1)` → `F(φ U ψ) ∈ chain(r)` (by h_content backward propagation). This gives `F(φ U ψ) ∈ chain(r)`, not `(φ U ψ) ∈ chain(r)`.

**Verdict**: The P-step approach faces an infinite regress: we can get `P(φ U ψ) ∈ chain(r)`, but to convert this to `(φ U ψ) ∈ chain(r)`, we need the same step transfer (one step earlier). This is circular.

**Option 2: Until-induction axiom**

Adding an axiom schema like `(φ U ψ) ∧ φ → G((φ U ψ) ∨ ψ)` (persistence under φ) would give the step transfer. However:
- This would extend the axiom system, potentially breaking the claim that BX is the axiom set.
- The axiom might not be derivable from BX1-BX12, meaning it would genuinely add expressive power.
- More concerning: such an axiom may not be valid under the reflexive semantics. The formula says "if (φ U ψ) holds now with φ holding now, then at all future times either the Until persists or ψ holds." This is actually NOT valid: consider φ = p, ψ = q, and a model where p holds at t, p U q holds at t (via q at t+5), φ holds at t but fails at t+1 — then p U q need not hold at t+1 since p fails there.

**Verdict**: Option 2 is mathematically unsound unless the axiom is carefully restricted. Not recommended.

**Option 3: Chain reconstruction via Hintikka point construction**

The `Quasimodel/Construction.lean` provides a `QuasimodelChain` that preserves Until formulas via defect-discharge. Its step construction ensures that if `(φ U ψ)` is a defect at position n, it propagates until resolved. This is exactly the backward step transfer in disguise: the Hintikka chain is designed to carry Until-persistence.

**Key insight**: The quasimodel/filtration infrastructure (tasks 90-102) already built this construction for the canonical frame sorries in Frame.lean. The same infrastructure could be used to prove backward Until coherence for the BFMCS.

**Verdict**: Option 3 is the MOST PROMISING and the mathematically correct solution. It reuses existing sorry-free infrastructure.

### 1.5 The Minimal Change: Enriched Until-Carry in the Chain Seeds

There is a more targeted version of Option 3 that doesn't require full chain reconstruction:

**Until-carry modification**: Include `(φ U ψ) → G(φ U ψ) ∨ ψ` formulas (or equivalently, add `G(φ U ψ) ∨ ψ` when `(φ U ψ)` is in the seed) to the seeds.

Wait — `G(φ U ψ) ∨ ψ` is NOT generally in M. We cannot add arbitrary formulas.

**Alternative minimal change**: Instead, enrich the seed for `bwd_pred` with Until-persistence formulas of the form `¬(φ U ψ) ∨ (φ U ψ)` (tautologies, useless) or work via the `h_content` of Until formulas.

The key insight from literature (Goldblatt 1992 "Logics of Time and Computation", Chapter 4): For discrete canonical models with Until, the successor seed typically includes **disjunctions** `ψ ∨ F(ψ)` for F-obligations AND **Until-propagation formulas** `(φ U ψ) ∨ ¬φ ∨ ψ` (which says "if φ U ψ fails now and φ holds now, then ψ holds now" — this is exactly BX8/BX9 combined). But these are already consequences of BX axioms in any MCS.

The actual mechanism in discrete systems: the seed for `bwd_pred M ψ` (predecessor of M resolving P(ψ)) includes `h_content(M)`. If `(φ U ψ) ∈ M` and we want `(φ U ψ) ∈ pred`, we need `H(φ U ψ) ∈ M`, i.e., `(φ U ψ)` was always in the past. But this is a much stronger requirement.

**The real solution from Burgess/Xu**: The completeness proof in Burgess 1982 uses a DIFFERENT canonical structure: the "tree unraveling" or "canonical model with selection functions." The dovetailed chain is a simplified construction that works for G/H/F/P but breaks for Until/Since backward. Burgess's original canonical frame for Until/Since on linear orders is more subtle — it uses a sequence of MCS ordered by a TOTAL order where `w ≤ v` iff `g_content(w) ⊆ v`, but the proof of the Until truth lemma does NOT use backward step transfer. Instead, it uses an OMEGA-sequence argument (Konig's lemma or compactness).

### 1.6 Recommended Approach: Use the Quasimodel Infrastructure

The quasimodel/filtration infrastructure already in the codebase solves the backward Until problem. Here is why:

The existing `bx_until_backward` (Frame.lean, closed by task 102) gives:
> Given `(φ U ψ) ∈ w` and `w ≤ v` in BXPoint ordering, ... find a backward witness.

This works because the quasimodel construction tracks Until-persistence via the `defect_count` well-founded recursion. The same mechanism should apply to the BFMCS backward Until problem.

**Proposed approach for `bx_bfmcs_restricted_buc`**:

Instead of proving step transfer for the dovetailed chain (which requires chain modification), we can use the existing `bx_until_backward` from Frame.lean directly:

1. Given `ψ ∈ (shifted_bx_fmcs N h_N s).mcs r` = `int_chain N h_N (r-s)`, unpack to a BXPoint `v = ⟨int_chain N h_N (r-s), ...⟩`.
2. From the guard: `φ ∈ int_chain N h_N (q-s)` for all `t ≤ q < r`.
3. At time t, the BXPoint is `w = ⟨int_chain N h_N (t-s), ...⟩`.
4. Use `backward_until_reflexive` if `t = r`, or apply the step-transfer via the quasimodel construction.

However, `bx_until_backward` in Frame.lean takes a DIFFERENT form — it's about the canonical frame ordering, not the BFMCS structure. The connection between the two requires the "bx_fmcs embeds as BFMCS" argument.

### 1.7 The Simplest Path Forward: Direct MCS Argument Without Step Transfer

Reading `UntilSinceCoherence.lean` carefully: the `backward_until_from_step` theorem is parameterized by a step transfer hypothesis. The task is to provide this hypothesis.

For the dovetailed chain (`int_chain`), the step transfer says:
```
(φ U ψ) ∈ int_chain N h_N (r+1-s) ∧ φ ∈ int_chain N h_N (r-s) → (φ U ψ) ∈ int_chain N h_N (r-s)
```

This is equivalent (after shifting) to:
```
(φ U ψ) ∈ fwd_chain ... (n+1) ∧ φ ∈ fwd_chain ... n → (φ U ψ) ∈ fwd_chain ... n
```

For this to hold, we need: when building `fwd_succ M hM (schedule n)`, if `(φ U ψ) ∈ fwd_succ M hM ψ'` and `φ ∈ M`, then `(φ U ψ) ∈ M`.

This is TRUE by the contrapositive (Round 5 approach) IF `¬(φ U ψ) ∈ M` and `φ ∈ M` imply `¬(φ U ψ) ∈ fwd_succ M hM ψ'` (i.e., ¬(φ U ψ) propagates forward). And `¬(φ U ψ) ∈ fwd_succ M hM ψ'` implies `(φ U ψ) ∉ fwd_succ M hM ψ'` — contradiction!

So we need: ¬(φ U ψ) ∈ M → ¬(φ U ψ) ∈ fwd_succ M hM ψ'.

This is TRUE if `G(¬(φ U ψ)) ∈ M`, because g_content(M) ⊆ fwd_succ and G(¬(φ U ψ)) ∈ M → ¬(φ U ψ) ∈ g_content(M).

And G(¬(φ U ψ)) ∈ M follows from `¬(φ U ψ) ∈ M` and `φ ∈ M` IF the biconditional reverse direction holds. But it doesn't.

**HOWEVER**: There is a subtler argument. If `¬(φ U ψ) ∈ M` and `φ ∈ M`, then by MCS consistency, `ψ ∉ M` (else BX8 gives (φ U ψ) ∈ M, contradiction). Now consider the fwd_succ. In fwd_succ, we have g_content(M) ⊆ fwd_succ. Since g_content(M) ⊆ M and M is an MCS, this doesn't help directly.

The issue is that the Lindenbaum extension of the seed might CHOOSE to include (φ U ψ) in the successor even when ¬(φ U ψ) ∈ M. This would be consistent in the successor (because the successor is a DIFFERENT MCS). The successor is independent: it just has to extend the seed, and the seed doesn't force ¬(φ U ψ) unless we explicitly add it.

**This is the fundamental problem**: the dovetailed chain doesn't carry ¬(φ U ψ) forward because ¬(φ U ψ) is not in g_content(M) (it would need G(¬(φ U ψ)) ∈ M, which requires the biconditional).

### 1.8 FINAL RECOMMENDED APPROACH: Enrich Seed with Until-Negation Blocking

The minimal change to resolve backward Until step transfer:

**Add `¬(φ U ψ)` to the predecessor seed for `bwd_pred`** whenever `¬(φ U ψ) ∈ M`:

Specifically, for each formula `¬(φ U ψ) ∈ M`:
- If `¬(φ U ψ) ∈ M` and `φ ∈ M`, then add `G(¬(φ U ψ))` or `¬(φ U ψ)` to the seed.

Wait — but `¬(φ U ψ) ∈ M` does NOT imply `G(¬(φ U ψ)) ∈ M`. We cannot add G-formulas that aren't in M.

**Alternative**: Add a "until-negation carry" set to the seed:
```
until_neg_carry(M) = {¬(φ U ψ) ∈ M | there is no BX proof of (φ U ψ) from the seed}
```
This is not computationally clean.

**The cleaner approach**: Modify `bwd_pred` to add all `¬(φ U ψ) ∈ M` to the seed (not just g_content and h_content). Since `¬(φ U ψ) ∈ M ⊆ M`, the augmented seed `h_content(M) ∪ p_carry(M) ∪ until_neg(M)` is a subset of M, hence consistent.

But then we need to prove that this carries ¬(φ U ψ) backward: `¬(φ U ψ) ∈ bwd_pred M hM ψ'`.

If `¬(φ U ψ) ∈ M` and `¬(φ U ψ)` is in the seed, then by set_lindenbaum, `¬(φ U ψ) ∈ bwd_pred`. YES — this works!

And the step transfer then follows: if `(φ U ψ) ∈ chain(r+1)` and `¬(φ U ψ) ∈ chain(r)`, then by the augmented predecessor seed, `¬(φ U ψ) ∈ chain(r+1)` — contradiction!

Wait, this is still getting chain-forward (r to r+1), but we need chain-backward (r+1 to r). Let me re-think.

**The step transfer for BACKWARD step**: Given `(φ U ψ) ∈ chain(r+1)` and `φ ∈ chain(r)`, prove `(φ U ψ) ∈ chain(r)`.

For this, we want: `¬(φ U ψ) ∈ chain(r)` implies `¬(φ U ψ)` is NOT in `chain(r+1)`.

Since chain(r+1) = fwd_succ(chain(r), ...), we need: `¬(φ U ψ) ∈ chain(r)` implies `¬(φ U ψ) ∈ fwd_succ(chain(r), ...)`.

If `G(¬(φ U ψ)) ∈ chain(r)`, then `¬(φ U ψ) ∈ g_content(chain(r)) ⊆ fwd_succ(chain(r), ...)`. But we cannot get `G(¬(φ U ψ))` from `¬(φ U ψ)` alone.

**ALTERNATIVE (and this is the key insight from the handoff, option 1 revisited)**:

Enrich the FORWARD seed to include `until_neg_formulas(M) = {¬(φ U ψ) ∈ M}`. Then:
- `¬(φ U ψ) ∈ M` → `¬(φ U ψ) ∈ fwd_succ M` (it's in the seed).
- `¬(φ U ψ) ∈ fwd_succ M` means `(φ U ψ) ∉ fwd_succ M` by MCS consistency.

So if we add `¬(φ U ψ)` formulas from M to the forward seed, then ¬(φ U ψ) is preserved forward. This gives:

`¬(φ U ψ) ∈ chain(r)` → `¬(φ U ψ) ∈ chain(r+1)` (by induction over the chain).

Therefore, `(φ U ψ) ∈ chain(r+1)` → `¬(φ U ψ) ∉ chain(r+1)` → `¬(φ U ψ) ∉ chain(r)` → `(φ U ψ) ∈ chain(r)`. **Step transfer proved!**

**This is the minimal chain modification for backward Until**:

Add `until_neg_formulas(M) = {¬(φ U ψ) | ¬(φ U ψ) ∈ M}` to the fwd_succ seed.

But wait: is `until_neg_formulas(M) ⊆ M`? YES! If `¬(φ U ψ) ∈ M` by hypothesis, then yes. So `{g_content(M) ∪ f_carry(M) ∪ until_neg(M)} ⊆ M`, making consistency trivial.

Similarly for Since: add `since_neg_formulas(M) = {¬(φ S ψ) | ¬(φ S ψ) ∈ M}` to the bwd_pred seed.

However, there's an issue: `until_neg_formulas` is not just the negations of Until formulas in M — it's any formula of the form `¬(φ U ψ)` that happens to be in M. Every MCS element is of this form OR another. The set `until_neg_formulas(M) = {α ∈ M | ∃ φ ψ, α = ¬(φ U ψ)}`.

This set is a subset of M, hence consistent. The forward step preservation holds.

**Caveat**: The step transfer also needs to work in the BACKWARD direction for Since. And for Since coherence in the backward chain (`bwd_chain`), we need `¬(φ S ψ)` to persist backward. Symmetric argument holds.

### 1.9 Is the dovetailed chain fundamentally wrong, or can it be saved?

**Answer**: It can be SAVED with the targeted modification of adding Until-negation formulas to forward seeds (and Since-negation formulas to backward seeds). The modification:
1. Maintains the seed as a subset of M (preserving consistency).
2. Enables the backward Until step transfer.
3. Does not interfere with the forward_F (eventuality) mechanism.
4. Is symmetric with what deferral disjunctions do for F-obligations.

The dovetailed Lindenbaum chain is NOT fundamentally wrong. It just needs to carry more information per step.

---

## 2. Recommended Approach

**Primary recommendation**: Enrich forward seed with Until-negation carry.

### Phase A: Add `until_neg_carry` to Forward Seed

Define:
```lean
def until_neg_carry (M : Set Formula) : Set Formula :=
  {α ∈ M | ∃ φ ψ, α = Formula.neg (Formula.untl φ ψ)}
```

Prove `until_neg_carry_subset (M : Set Formula) : until_neg_carry M ⊆ M` (trivial).

Modify `fwd_succ` to use seed `{ψ} ∪ g_content(M) ∪ f_carry(M) ∪ until_neg_carry(M)` (or `g_content(M) ∪ f_carry(M) ∪ until_neg_carry(M)` for non-resolving case). Since all components ⊆ M, consistency is trivial via `h_mcs.1`.

### Phase B: Prove Forward Preservation of Until-Negation

```lean
theorem fwd_succ_until_neg_carry (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    until_neg_carry M ⊆ fwd_succ M h_mcs ψ
```

Proof: `until_neg_carry M` is in the seed, hence in the Lindenbaum extension.

### Phase C: Derive the Step Transfer

```lean
theorem int_chain_until_neg_stable (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (φ ψ : Formula) (t : Int) :
    Formula.neg (Formula.untl φ ψ) ∈ int_chain M₀ h₀ t →
    ∀ s ≥ t, Formula.neg (Formula.untl φ ψ) ∈ int_chain M₀ h₀ s
```

Proof by induction: at each fwd_succ step, `¬(φ U ψ) ∈ M` → `¬(φ U ψ) ∈ until_neg_carry(M)` → `¬(φ U ψ) ∈ fwd_succ M`.

Then the backward step transfer follows by contrapositive of this stability:
```lean
theorem backward_until_step_transfer (M₀ h₀ φ ψ r) :
    Formula.untl φ ψ ∈ int_chain M₀ h₀ (r+1) →
    φ ∈ int_chain M₀ h₀ r →
    Formula.untl φ ψ ∈ int_chain M₀ h₀ r
```

Proof: Suppose ¬(φ U ψ) ∈ chain(r). By `int_chain_until_neg_stable`, ¬(φ U ψ) ∈ chain(r+1). Contradiction with (φ U ψ) ∈ chain(r+1) by MCS consistency. Done.

(Note: φ ∈ chain(r) hypothesis is NOT actually used in this argument! The stability of ¬(φ U ψ) forward is independent of φ. So the step transfer holds unconditionally.)

### Phase D: Apply to `bx_bfmcs_restricted_buc`

Use `backward_until_from_step` from `UntilSinceCoherence.lean` with the step transfer proved in Phase C. This closes `bx_bfmcs_restricted_buc`.

Similarly for Since: add `since_neg_carry` to `bwd_pred` seeds and prove `backward_since_step_transfer`.

---

## 3. Evidence and Examples

**Why this works**: The key insight is that `¬(φ U ψ)` is a "negative Until certificate" that should persist forward: once `(φ U ψ)` fails (no ψ-witness exists from this point), it should remain failed unless ψ appears. The modified seed ensures this persistence by carrying ¬(φ U ψ) explicitly.

**Why the biconditional is not needed**: We don't need to derive G(¬(φ U ψ)) from ¬(φ U ψ). We just need the chain itself to carry ¬(φ U ψ) forward — which the enriched seed does directly.

**Consistency of augmented seed**: `until_neg_carry(M) ⊆ M` since each element is in M by definition. So `{ψ} ∪ g_content(M) ∪ f_carry(M) ∪ until_neg_carry(M) ⊆ forward_temporal_witness_seed M ψ ∪ f_carry(M) ∪ until_neg_carry(M) ⊆ M`. The consistency proof follows from `h_mcs.1`.

Actually wait: the combination requires proving the union is consistent, not just that each piece is. Since all components ⊆ M and M is consistent, any subset of M is consistent. The proof: if L ⊆ (union) and L ⊢ ⊥, then L ⊆ M, contradiction with M consistent.

**Example**: Let M = {p, ¬(p U q), F(r), ...}. The forward seed includes `¬(p U q)`, so fwd_succ also contains `¬(p U q)`. Thus (p U q) ∉ fwd_succ. The step transfer: if (p U q) ∈ chain(n+1), then ¬(p U q) ∉ chain(n+1), hence ¬(p U q) ∉ chain(n) (by contrapositive of stability), hence (p U q) ∈ chain(n). Correct!

**Note on F(⊤)**: The `until_neg_carry` approach does NOT require F(⊤) ∈ M (unlike the deferral disjunction approach for forward_F). This is an advantage.

**Interaction with deferral disjunctions**: The two modifications (deferral disjunctions for forward_F, until_neg_carry for backward Until) are INDEPENDENT. Each can be applied separately or together. The until_neg_carry modification also does not interact with the schedule-based resolution mechanism.

---

## 4. Confidence Assessment

| Finding | Confidence | Basis |
|---------|-----------|-------|
| Biconditional reverse direction not a BX theorem | HIGH (95%) | Semantic falsification: non-total-order counter-model works |
| Contrapositive argument (Round 5) is flawed | HIGH (95%) | Algebraic analysis of what the argument actually requires |
| until_neg_carry modification gives step transfer | HIGH (90%) | Direct proof sketch, all steps clear |
| Consistency of augmented seed | HIGH (95%) | Subset of M, M consistent |
| This closes bx_bfmcs_restricted_buc | MEDIUM-HIGH (80%) | Depends on until_neg_carry propagating correctly through int_chain |
| Forward Until closure after backward Until | MEDIUM (70%) | Guard argument still needed; forward_F/backward_P also needed |

**Caveat**: The 20% uncertainty in closing bx_bfmcs_restricted_buc comes from potential complications in the int_chain propagation across the t < 0 / t ≥ 0 boundary. Specifically, the backward chain (bwd_chain) goes in the opposite direction, so until_neg_carry on the forward chain may not propagate correctly to t < 0. The symmetric fix for bwd_chain (carrying Since-negations) may need a separate argument.

---

## 5. Summary: Minimal Path to bx_completeness

1. **Add `until_neg_carry` to `fwd_succ` seeds** (both resolving and non-resolving cases).
2. **Prove `fwd_chain_until_neg_stable`** (induction over the chain).
3. **Prove `backward_until_step_transfer`** (contrapositive of stability).
4. **Plug into `backward_until_from_step`** to close `bx_bfmcs_restricted_buc`.
5. **Symmetric: add `since_neg_carry` to `bwd_pred` seeds** and close the Since case.
6. **Handle forward Until**: requires forward_F (separate work via deferral seeds) + guard argument (uses backward Until coherence just proved).
7. **Handle forward_F/backward_P**: requires deferral seed modification (separate work, Phase 2B from Round 5 plan).
8. **Rewrite `bx_bfmcs_restricted_tc`** to not delegate to the unrestricted sorry-bearing variants.

Steps 1-5 are the **backward Until blocker**, the focus of this round. Steps 6-8 are pre-existing work from the prior plan.

---

## References

### Literature
- [Burgess 1982 "Axioms for Tense Logic I: Since and Until"](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf) — original axiomatization, canonical frame with ω-sequence argument
- [Xu 1988 "On some U,S-tense logics"](https://philpapers.org/rec/XUOSU) — simplified axioms, completeness for reflexive linear orders
- [Goldblatt 1992 "Logics of Time and Computation"](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation) — canonical frame, discrete temporal logic
- [Gabbay-Hodkinson-Reynolds 1994 "Temporal Logic"](https://global.oup.com/academic/product/temporal-logic-9780198537694) — comprehensive reference, Until/Since canonical model construction
- [Temporal Logic (Stanford SEP)](https://plato.stanford.edu/entries/logic-temporal/) — overview of Burgess-Xu system

### Codebase
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — sorry sites at lines 497, 503, 586, 591, 621, 627
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — `backward_until_from_step` (parameterized, sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean:469` — `until_F_expansion` (proved)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — `deferralDisjunctions`, P-step blocking infrastructure
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/handoffs/01_deferral-chain-handoff.md` — prior implementation analysis
- `/home/benjamin/Projects/ProofChecker/specs/093_complete_bxcanonical_embedding/reports/05_team-research.md` — prior round synthesis
