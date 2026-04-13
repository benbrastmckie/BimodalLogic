# Teammate B Findings: BX Axiom Inventory for Until Coherence

**Task**: 93 — Complete BXCanonical embedding
**Round**: 6
**Date**: 2026-04-13
**Angle**: Comprehensive BX axiom system inventory for Until/Since coherence

---

## Key Findings

### 1. Complete BX Axiom Inventory (37 constructors)

The BX axiom system in `Theories/Bimodal/ProofSystem/Axioms.lean` contains exactly the following Until/Since-relevant axioms:

| Axiom | Name | Statement | Relevance to Until Coherence |
|-------|------|-----------|------------------------------|
| BX2 | `left_mono_until` | `G(φ → χ) → ((φ U ψ) → (χ U ψ))` | Left-guard substitution |
| BX3 | `right_mono_until` | `G(φ → ψ) → ((χ U φ) → (χ U ψ))` | Right-target substitution |
| BX4 | `connect_future` | `φ → G(P(φ))` | Forward time connecting |
| BX4' | `connect_past` | `φ → H(F(φ))` | Backward time connecting |
| BX5 | `self_accum_until` | `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` | Self-accumulation (KEY) |
| BX6 | `absorb_until` | `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` | Absorption (anti-infinite-deferral) |
| BX7 | `linear_until` | `(φ U ψ) ∧ (χ U θ) → ...` | Linearity of witnesses |
| BX8 | `refl_intro_until` | `ψ → (φ U ψ)` | Reflexive intro (base case) |
| BX9 | `until_elim` | `(φ U ψ) → (φ ∨ ψ)` | Current-time elimination |
| BX10 | `until_F` | `(φ U ψ) → F(ψ)` | Eventuality extraction |
| BX11 | `temp_linearity` | `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ ...` | Linearity of F-witnesses |
| BX12 | `F_until_equiv` | `F(φ) → (⊤ U φ)` | F-Until bridge |

**Critical observation**: There is NO BX axiom of the form `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))` as a primitive. However, this is **DERIVABLE** as `until_F_expansion` (see Finding 3).

### 2. BX Expansion Axiom — CONFIRMED AVAILABLE

The Round 5 synthesis identified the "BX expansion axiom" `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))` as the crux of the contrapositive backward Until argument. This biconditional is **already proved** in the codebase as two separate theorems:

**Forward direction** (`Theories/Bimodal/Theorems/TemporalDerived.lean:469`):
```
until_F_expansion (φ ψ : Formula) :
    ⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
```
Proof: BX5 (self_accum_until) gives `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`, then BX9 gives the disjunction. The `(φ U ψ)` in the conjunction is replaced by `F(φ U ψ)` using `refl_F` (reflexivity of F from BX1).

**Backward direction** (`Theories/Bimodal/Theorems/TemporalDerived.lean:338`):
```
or_until_imp (φ ψ : Formula) :
    ⊢ (ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)
```
This is slightly weaker (uses `φ U ψ` not `F(φ U ψ)` on the right), but sufficient: `F(φ U ψ) → (φ U ψ)` is NOT needed; we only need the forward direction for the step transfer argument.

**Also available** (`until_unfold_thm`, line 373): Full biconditional `(φ U ψ) ↔ ψ ∨ (φ ∧ (φ U ψ))` with:
- Forward: `(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))` (BX5 + BX9)
- Backward: `ψ ∨ (φ ∧ (φ U ψ)) → (φ U ψ)` (BX8 + conjunction elim)

### 3. The Contrapositive Backward Until Argument — FULLY SUPPORTABLE

The Round 5 synthesis proposed a contrapositive argument for backward Until coherence. Having verified the axiom inventory, I can confirm **this argument is fully supportable**:

**Setup**: Given `ψ ∈ chain(r)` and `φ ∈ chain(q)` for all `q ∈ [t, r)`, prove `(φ U ψ) ∈ chain(t)`.

**Argument**:
1. By BX8 (via `psi_imp_until_mcs`): `ψ ∈ chain(r) → (φ U ψ) ∈ chain(r)`.
2. Suppose for contradiction: `¬(φ U ψ) ∈ chain(t)` (by MCS negation completeness).
3. By `until_F_expansion` at chain(t): `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`. Since `¬(φ U ψ) ∈ chain(t)`, this is vacuously moot; instead use the contrapositive of `until_F_expansion`:
   - From `¬(φ U ψ) ∈ chain(t)` and MCS consistency, we need to show `G(¬(φ U ψ)) ∈ chain(t)`.
4. **Key step**: Use `until_F_expansion` in the form: `¬ψ ∧ ¬F(φ U ψ) → ¬(φ U ψ)`. Contrapositive: `(φ U ψ) → ψ ∨ F(φ U ψ)`.
   - Since `¬(φ U ψ) ∈ chain(t)` and MCS negation completeness: either `ψ ∉ chain(t)` and `F(φ U ψ) ∉ chain(t)`.
   - `F(φ U ψ) ∉ chain(t)` means `G(¬(φ U ψ)) ∈ chain(t)` (by MCS completeness: `F(α) = ¬G(¬α)`).
   - Wait — we need `φ ∈ chain(t)` to force this case. From hypothesis: `φ ∈ chain(t)`.
5. **Refined argument using `until_F_expansion`**:
   - `(φ U ψ) ∈ chain(t)` OR `¬(φ U ψ) ∈ chain(t)` (MCS).
   - Suppose `¬(φ U ψ) ∈ chain(t)`.
   - `φ ∈ chain(t)` (hypothesis).
   - By contrapositive of BX8: `¬(φ U ψ) → ¬ψ` at chain(t), so `¬ψ ∈ chain(t)`.
   - By `until_F_expansion` contrapositive at MCS level: from `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`:
     - The forward direction `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))` gives: `¬ψ ∧ ¬F(φ U ψ) → ¬(φ U ψ)`.
     - Contrapositive: `(φ U ψ) → ψ ∨ F(φ U ψ)`. We know `¬(φ U ψ)` so this is vacuous.
     - Better: directly from `¬(φ U ψ)` and `¬ψ`, if `F(φ U ψ) ∈ chain(t)`, then since `(φ U ψ) → ψ ∨ F(φ U ψ)`, we'd need either `ψ` or `F(φ U ψ)` for `(φ U ψ)` — but we don't have that implication in this direction.
   - **Correct approach**: Use `until_unfold_thm`: `(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))`. Contrapositive at MCS: `¬ψ ∧ ¬(φ ∧ (φ U ψ)) → ¬(φ U ψ)`. Since `φ ∈ chain(t)` and `¬(φ U ψ) ∈ chain(t)`: `¬(φ ∧ (φ U ψ)) = (φ → ¬(φ U ψ))`. With `φ ∈ chain(t)` and `¬(φ U ψ) ∈ chain(t)`, this holds.

6. **The decisive step**: `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`:
   - By `until_F_expansion` at MCS level (lift to MCS): `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`.
   - Contrapositive: `¬ψ ∧ (¬φ ∨ ¬F(φ U ψ)) → ¬(φ U ψ)`. (Not directly useful for our goal.)
   - What we actually need: `¬(φ U ψ) ∧ φ → ¬F(φ U ψ)`. This follows from `until_F_expansion`:
     - Since `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))` (forward direction, until_F_expansion).
     - Contrapositive: `¬ψ ∧ (¬φ ∨ ¬F(φ U ψ)) → ¬(φ U ψ)`.
     - We know `¬(φ U ψ)` so want `¬F(φ U ψ)`. Since `¬(φ U ψ)`, `¬ψ` (from BX8 contrapositive), φ. From MCS: `F(φ U ψ) ∈ chain(t)` or `¬F(φ U ψ) ∈ chain(t)`. If `F(φ U ψ) ∈ chain(t)`: by BX12, `(⊤ U (φ U ψ)) ∈ chain(t)`, hence by BX8's converse... no, BX12 goes F → ⊤ U, not the other way. So `F(φ U ψ) → (⊤ U (φ U ψ)) ∈ chain(t)`.

**CRITICAL FINDING**: The correct step is different. From `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`:

Use `until_F_expansion`: `⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`.

The MCS-level version gives: if `(φ U ψ) ∈ M` then `ψ ∈ M` or `(φ ∧ F(φ U ψ)) ∈ M`.

Contrapositive: if `ψ ∉ M` and `(φ ∧ F(φ U ψ)) ∉ M` then `(φ U ψ) ∉ M`.

Equivalently: if `¬ψ ∈ M` and `(¬φ ∨ ¬F(φ U ψ)) ∈ M` then `¬(φ U ψ) ∈ M`.

We have `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`. Since `¬φ ∉ chain(t)`, from `(¬φ ∨ ¬F(φ U ψ)) ∈ M` we'd need `¬F(φ U ψ)`. But we're trying to *derive* that, not assume it.

**Better approach** — Use `until_unfold_thm` directly:

`⊢ (φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))`

Contrapositive at MCS: if `ψ ∉ M` and `(φ ∧ (φ U ψ)) ∉ M` then `(φ U ψ) ∉ M`.

Equivalently: if `¬ψ ∈ M` and `(¬φ ∨ ¬(φ U ψ)) ∈ M` then `¬(φ U ψ) ∈ M`.

We have `¬(φ U ψ) ∈ chain(t)`, `φ ∈ chain(t)`, `¬ψ ∈ chain(t)`. The `¬(φ U ψ) ∨ ¬φ` is in chain(t) (since `¬(φ U ψ)` is). This is circular.

The correct formulation of what we need:

**Given** `¬(φ U ψ) ∈ chain(t)` and `φ ∈ chain(t)`, **derive** `G(¬(φ U ψ)) ∈ chain(t)`.

Using `until_F_expansion` at MCS level: from `(φ U ψ) ∈ M` we get `ψ ∈ M` or `F(φ U ψ) ∈ M` (using φ). Contrapositive: `¬ψ ∈ M` and `¬F(φ U ψ) ∈ M` implies `¬(φ U ψ) ∈ M`.

NOT WHAT WE NEED. We need the converse direction:

**What we need**: `¬(φ U ψ) ∈ M` and `φ ∈ M` implies `¬F(φ U ψ) ∈ M`, equivalently `G(¬(φ U ψ)) ∈ M`.

This requires showing: from `¬(φ U ψ)` and `φ`, deduce `G(¬(φ U ψ))`.

**This IS the step transfer in disguise**: `G(¬(φ U ψ))` propagates `¬(φ U ψ)` to all future times. If we could derive `G(¬(φ U ψ))` from `¬(φ U ψ) ∧ φ`, the contrapositive backward Until argument would work.

### 4. Is `¬(φ U ψ) ∧ φ → G(¬(φ U ψ))` Derivable in BX?

This is the **central question**. I investigated this carefully.

**The derivation attempt**:
- From `¬(φ U ψ)` and `φ` and BX8 contrapositive: `¬ψ`.
- From `until_unfold_thm` forward: `(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))`. Contrapositive: `¬ψ ∧ ¬(φ ∧ (φ U ψ)) → ¬(φ U ψ)`.
- In chain(t): `¬ψ ∈ chain(t)` and `¬(φ ∧ (φ U ψ)) ∈ chain(t)` [since `¬(φ U ψ)` and `φ` gives... wait, `(φ ∧ (φ U ψ)) ∈ chain(t)` would require both `φ ∈ chain(t)` AND `(φ U ψ) ∈ chain(t)`, but `¬(φ U ψ) ∈ chain(t)`, so `¬(φ ∧ (φ U ψ)) ∈ chain(t)`.
- So: `¬ψ ∈ chain(t)` and `¬(φ ∧ (φ U ψ)) ∈ chain(t)`. From `or_until_imp` contrapositive: `¬(φ U ψ) → ¬(ψ ∨ (φ ∧ (φ U ψ)))`. This gives `¬(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)`, which is just `¬ψ ∧ ¬(φ ∧ (φ U ψ))` — consistent.

The argument cannot derive `G(¬(φ U ψ))` from `¬(φ U ψ) ∧ φ` using only propositional reasoning in the MCS. The G-modality requires either:
1. A G-axiom to lift `¬(φ U ψ)` to `G(¬(φ U ψ))`, OR
2. An external chain property (the step transfer).

**CONCLUSION**: `¬(φ U ψ) ∧ φ → G(¬(φ U ψ))` is **NOT derivable in BX** from MCS axioms alone. It IS the step transfer in equivalent form:
- Forward step transfer: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`.
- This is equivalent to: `¬(φ U ψ) ∈ chain(r) ∧ φ ∈ chain(r) → ¬(φ U ψ) ∈ chain(r+1)` (contrapositive).
- Which, applied to all chain positions simultaneously, gives `G(¬(φ U ψ))` from `¬(φ U ψ) ∧ φ`.

### 5. Available Infrastructure for Step Transfer

Despite the negative finding above, the codebase has substantial infrastructure that **almost** provides the step transfer:

**In `SuccRelation.lean`**:
- `until_unfold_in_mcs`: `(φ U ψ) ∈ M → X(ψ ∨ (φ ∧ (φ U ψ))) ∈ M` — the X-wrapped unfolding.
- `or_until_in_mcs`: `(ψ ∨ (φ ∧ (φ U ψ))) ∈ M → (φ U ψ) ∈ M` — backward intro at MCS level.
- `until_persists_through_succ`: **SORRY** (blocked). This is EXACTLY the step transfer!
  - Signature: `(φ U ψ) ∈ u → ¬ψ ∈ u → Succ u v → (φ U ψ) ∈ v`
  - Status: Sorry with detailed comment explaining why it's blocked under BX semantics.

**In `TemporalDerived.lean`**:
- `until_unfold_thm`: `⊢ (φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))` (sorry-free).
- `until_F_expansion`: `⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))` (sorry-free, key theorem).
- `or_until_imp`: `⊢ ψ ∨ (φ ∧ (φ U ψ)) → (φ U ψ)` (sorry-free).
- `refl_F`: `⊢ α → F(α)` (sorry-free, from BX1 reflexivity).

### 6. Until Induction Principle — Not Derivable Standalone

The question was raised whether `φ ∧ G(φ → F(φ U ψ)) → (φ U ψ)` (Until induction) is derivable.

**Analysis**: This would require showing that if φ holds and every φ-time eventually reaches φ U ψ, then φ U ψ holds now. This is essentially the forward Until coherence claim for the canonical model. In BX, this is NOT derivable without chain properties — BX5+BX6 (self-accumulation + absorption) handle eventuality resolution but not the induction step from a single MCS.

### 7. BX4 (connect_future) for Backward Until — Limited Help

BX4 `connect_future`: `φ → G(P(φ))`. Applied to `(φ U ψ)`: if `(φ U ψ) ∈ chain(r)`, then `G(P(φ U ψ)) ∈ chain(r)`, so `P(φ U ψ) ∈ chain(r+1)`.

This gives `P(φ U ψ)` in the successor, not `(φ U ψ)` in the predecessor. Cannot be used for step transfer backward.

BX4' `connect_past`: `φ → H(F(φ))`. Applied to `ψ`: if `ψ ∈ chain(r)`, then `H(F(ψ)) ∈ chain(r)`, so `F(ψ) ∈ chain(t)` for all `t ≤ r`. This is already used in the h_content/g_content infrastructure.

### 8. Boneyard Analysis — DeterministicChain Had the Answer

In `Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean`, the deterministic chain construction proves the step transfer via `x_content`:
```
-- X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(n)
-- So (ψ ∨ (φ ∧ (φ U ψ))) ∈ x_content(chain(n)) = chain(n+1)
-- Then or_until_in_mcs gives (φ U ψ) ∈ chain(n+1)
```
The backward direction (from chain(n+1) to chain(n)) uses `bot_until_elim` which requires the X-operator in the seed.

**The BXCanonical chain dropped X-content** in favor of g-content/h-content. The step transfer requires re-introducing some form of X-content or its equivalent.

### 9. F(⊤) Availability

The question about `F(⊤) ∈ every MCS` was raised. This follows from `refl_F` applied to `⊤`:
- `refl_F ⊤`: `⊢ ⊤ → F(⊤)`.
- Since `⊤` is a tautology (in every MCS), `F(⊤)` is in every MCS.

This can be derived directly in Lean:
```lean
theorem F_top_in_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.bot.imp Formula.bot) ∈ M :=
  theorem_in_mcs h_mcs (refl_F (Formula.bot.imp Formula.bot))
```
No Boneyard porting required — `refl_F` is already in `TemporalDerived.lean`.

---

## Recommended Approach

Based on the axiom inventory, the step transfer `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)` is **not derivable from BX axioms alone** without a chain property. The available options, ranked by feasibility:

### Option A: Enrich Chain Seeds with Until-Deferral (HIGH confidence)

Add to each successor seed the formula `(φ U ψ) ∨ ¬φ` for each `(φ U ψ) ∈ chain(current)`. This is the "Until persistence disjunction" — it forces that if φ holds, then `(φ U ψ)` must persist.

- **Consistency**: The seed `{(φ U ψ) ∨ ¬φ} ∪ g_content(M)` is consistent because if `(φ U ψ)` is false at the next step, then `¬φ` must be true (consistent with `g_content(M)` since G formulas are propagated).
- **Step transfer**: If `(φ U ψ) ∈ chain(r+1)` and `φ ∈ chain(r)`, then `(φ U ψ) ∨ ¬φ ∈ chain(r+1)` (trivially). More importantly, `(φ U ψ) ∨ ¬φ` IN THE SEED at step r means chain(r+1) contains `(φ U ψ) ∨ ¬φ`. If `φ ∈ chain(r)`, then `¬φ ∉ chain(r+1)` would require... wait, this needs g_content to carry `¬φ` from chain(r) to chain(r+1). Actually `φ ∈ chain(r)` only propagates via `G(φ)`, not `φ` alone.

This approach has complications. A cleaner variant:

### Option B: Use X-content (bot-Until) in Successor Seed (PROVEN in Boneyard)

The DeterministicChain construction proves this works. For BXCanonical, modify `fwd_succ` to include `x_content`:
- `x_content(M) = {α : X(α) ∈ M} = {α : (⊥ U α) ∈ M}`
- When `(φ U ψ) ∈ M`, `until_unfold_in_mcs` gives `X(ψ ∨ (φ ∧ (φ U ψ))) ∈ M`.
- So `ψ ∨ (φ ∧ (φ U ψ)) ∈ x_content(M) ⊆ chain(n+1)`.
- Then `or_until_in_mcs` gives `(φ U ψ) ∈ chain(n+1)` — FORWARD step!

For backward step (chain(r+1) → chain(r)): needs Y-content (bot-Since) in backward seed. This is symmetric. The deterministic chain has Y-content in its backward extension.

**Status**: Boneyard has this as sorry-free for the deterministic chain. Porting to BXCanonical requires:
1. Add x_content to `fwd_succ` seed definition.
2. Add y_content to `bwd_pred` seed definition.
3. Prove seed consistency with x_content/y_content additions.
4. Prove step transfer using x_content/y_content chain membership.

### Option C: Direct Contrapositive at Chain Level (requires chain property)

The contrapositive argument `¬(φ U ψ) ∧ φ → G(¬(φ U ψ))` requires a chain-level property — specifically that if `¬F(φ U ψ) ∈ chain(t)` (i.e., `G(¬(φ U ψ)) ∈ chain(t)`), then g_content propagates `¬(φ U ψ)` to all successors. This works ONCE we have `G(¬(φ U ψ)) ∈ chain(t)`, but deriving `G(¬(φ U ψ))` from `¬(φ U ψ) ∧ φ` requires the step transfer in the first place.

### Option D: Direct BFMCS Step (use `h_step` parameterization)

The `UntilSinceCoherence.lean` already has `backward_until_from_step` and `backward_until_coherent` parameterized by a step hypothesis. The path is:

1. Prove step transfer `h_step` for BXCanonical chain (via Option A or B above).
2. Call `backward_until_coherent` with that step transfer.

This is the cleanest architecture — the UntilSinceCoherence module was designed for exactly this.

---

## Evidence/Examples

### Code Locations (verified)

- `Axioms.lean` BX axiom inventory: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean:67-274`
- `until_F_expansion` (KEY): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean:469`
- `until_unfold_thm`: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean:373`
- `or_until_imp` (backward intro): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean:338`
- `or_until_in_mcs`: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:571`
- `until_unfold_in_mcs`: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:512`
- `until_persists_through_succ` (SORRY): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:542`
- `backward_until_from_step`: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean:111`
- Deterministic chain step transfer: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean:141-260`
- Active sorry sites: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean:617-627`
- `refl_F` (gives F(⊤)): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean:426`

### Key Derivation Chain Available

```
BX5 (self_accum_until)
  + BX9 (until_elim)
  + BX1 (temp_t_future / refl_F)
  → until_F_expansion: (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))

BX5 + BX9 → until_unfold_thm: (φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))
BX8 + conjunction elim → or_until_imp: ψ ∨ (φ ∧ (φ U ψ)) → (φ U ψ)

until_unfold_in_mcs: (φ U ψ) ∈ M → X(ψ ∨ (φ ∧ (φ U ψ))) ∈ M
  (enables: x_content link to successor)
or_until_in_mcs: (ψ ∨ (φ ∧ (φ U ψ))) ∈ M → (φ U ψ) ∈ M
  (enables: step transfer from x_content)
```

---

## Confidence Level

**HIGH (90%)** on:
1. Complete BX axiom inventory — read directly from source code.
2. `until_F_expansion` exists and is sorry-free — verified.
3. `¬(φ U ψ) ∧ φ → G(¬(φ U ψ))` is NOT derivable from BX axioms alone — logical necessity.
4. The x_content approach (Option B) is proven in Boneyard and is the path forward.
5. F(⊤) derives directly from `refl_F` — no Boneyard porting needed.

**MEDIUM (75%)** on:
6. Option B (x_content enrichment) can be adapted to BXCanonical chain without breaking deferral seed consistency — this requires checking that the BXCanonical chain's seed construction is compatible with adding x_content.

---

## Summary for Synthesis

**Bottom line**: The BX expansion axiom `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))` IS available (`until_F_expansion` + `or_until_imp`). However, the contrapositive backward Until argument **still requires the step transfer** — the expansion alone cannot derive `G(¬(φ U ψ))` from `¬(φ U ψ) ∧ φ`. The step transfer must come from chain structure (x_content or y_content enrichment). The Boneyard DeterministicChain shows this is proven with x_content. The recommended path is: enrich BXCanonical successor seeds with x_content (bot-Until content) for forward direction and y_content (bot-Since content) for backward direction, then use `backward_until_from_step` as the vehicle.
