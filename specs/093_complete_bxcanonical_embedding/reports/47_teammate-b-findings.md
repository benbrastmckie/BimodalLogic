# Teammate B Findings — Round 47
# Boneyard Inventory and Irreflexive Semantics Analysis

## Key Findings

### 1. Complete Boneyard Inventory

#### `Theories/Bimodal/Boneyard/`

**StrictSemanticsLegacy/** (6 files)
- `BaseCompleteness.lean` — Framework for base TM completeness using D=Int. No independent sorry but references deprecated infrastructure. Documents why Int suffices for base logic.
- `DenseCompleteness.lean` — Dense completeness framework. Has gap: truth lemma proven for D=Int while `valid_dense` quantifies over all dense D.
- `DiscreteCompleteness.lean` — Discrete completeness framework. Blocked by DiscreteTimeline.lean sorries (SuccOrder/PredOrder proofs).
- `FrameConditions/Completeness.lean` — Wiring module with one isolated sorry in `bfmcs_from_mcs_temporally_coherent`. Notes explicitly that bundle-level coherence != family-level coherence. **HISTORICALLY IMPORTANT** as it documents the semantic gap that drove the current BXCanonical path.
- `Bundle/CanonicalConstruction.lean` — Direct TruthLemma at TaskFrame level for D=Int. Sorry-free canonical construction connecting MCS membership to `truth_at`. This is **sorry-free and sound** infrastructure.
- `Bundle/SuccChainFMCS.lean` — SuccChain FMCS construction. Contains sorries in forward_F/backward_P (`f_nesting_is_bounded` is mathematically FALSE for arbitrary MCS). Archived because nesting bound fails.
- `Algebraic/DovetailedChain.lean` — DEPRECATED. All 6 sorries are annotated as such. Blocked by Until/Since propagation through g_content (the X-vs-G mismatch).
- `Algebraic/RestrictedTruthLemma.lean` — Restricted bidirectional truth lemma for RestrictedTemporallyCoherentFamily. Partially sound, with dead code removed.
- `Algebraic/UltrafilterChain.lean` — R_G/R_Box temporal/modal accessibility on Lindenbaum ultrafilters. **Sorry-free** algebraic foundation. Phase 2 (box-class witness) is sound.

**ChainCompleteness/** (8 files)
- `Bundle/MCSWitnessChain.lean` — DRM chain with g_content propagation. **Sorry-free** for chain construction itself. Cannot close completeness because it lacks forward_G/backward_H for full MCS.
- `Bundle/SimplifiedChain.lean` — Simplified restricted seed without f_content. Phases 1-2 sorry-free. Phase 3 still needs sorry for forward_F.
- `Bundle/MCSWitnessSuccessor.lean` — Targeted successor construction. Sorry-free for DRM properties.
- `Bundle/ResolvingChain.lean`, `TargetedChain.lean`, `SuccChainTaskFrame.lean`, `SuccChainTruth.lean`, `SuccChainWorldHistory.lean` — Various chain approaches with varying sorry states.
- `Completeness/SuccChainCompleteness.lean` — Chain completeness attempt.
- `Algebraic/DeterministicChain.lean`, `DeterministicFMCS.lean`, `FiniteDeferral.lean` — Deterministic chain approaches.

**RoundRobinChain/** (2 files)
- `DRMChain.lean` — DRM chain for forward_F. Contains sorry-free `simplified_restricted_seed_subset_u` and `simplified_restricted_seed_consistent`. The DRMChain infrastructure in this file is **sorry-free** for the seed parts.
- `ProofSketch_Sections1to30.lean` — Mathematical sketch of round-robin approach.

**UltrafilterDeadCode/** (4 files)
- `ZChain.lean`, `CoherentZChain.lean`, `BidirectionalSeed.lean`, `FPreservingSeed.lean` — All dead code. Bundle-level coherence is semantically insufficient for TM (documented in BundleCode.lean).

**BundleTemporalCoherence/** (1 file)
- `BundleCode.lean` — Documentation only (no compilable code). Explains why bundle-level temporal coherence is WRONG for TM semantics. Critical reference document.

**TAxiomDependentCode/** (3 files)
- `CanonicalConstructionArchive.lean`, `TargetedChainArchive.lean`, `TruthPreservationArchive.lean` — Old code that depended on T-axiom (G(φ) → φ). Archived when semantics shifted.

**DiscreteXY/** (1 file)
- `Discreteness.lean` — Derives backward discreteness axiom DP from DF via `temporal_duality`. Has one sorry for `discreteness_forward` (the axiom was removed in BX refactor). Otherwise the derivation logic is sound.

#### `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/`

**OracleCoherence.lean** — Oracle-based FMCS coherence attempt (archived 2026-04-18, Plan v40 phases 3-4). Blocked at backward coherence: `φ ∧ F(φ U ψ) → φ U ψ` is semantically invalid. The `qm_oracle_step` / `qm_oracle_step_bwd` infrastructure is **preserved as reusable** with 0 sorries in this file.

**RoundRobinChain.lean** — Round-robin chain approach. Archived after 40 rounds: forward_F is blocked by BX11 perpetual deferral obstruction at depth-0. The round-robin schedule lemmas (`rrSchedule_visits`) and enriched step infrastructure are **sorry-free** but the forward_F theorem is not provable with this approach.

### 2. Current Sorry Sites in Active Code

The active code in `Metalogic/BXCanonical/` has 5 primary sorry sites (in `RootScopedChain.lean`):
1. `fwd_chain_forward_F` (line 1111) — Forward F eventuality via finite defect-discharge
2. `dd_bfmcs_restricted_tc` backward half (line 1138) — F(φ) in backward chain
3. `dd_bfmcs_restricted_tc` backward_P direction (line 1145) — P(φ) backward chain
4. `dd_bfmcs_restricted_buc` (line 1153) — Backward Until/Since step transfer
5. `dd_bfmcs_restricted_fuc` (line 1160) — Forward Until/Since coherence

Plus secondary sorries in `Quasimodel/OracleStep.lean` (general HintikkaStepOracle case, documented as not firing on actual completeness path) and one in `Frame.lean` (line 440, modal witness).

### 3. Irreflexive vs. Reflexive Semantics Analysis

**Current (Reflexive) Semantics:**
```
M,τ,x ⊨ G(φ) iff ∀ s ≥ x, M,τ,s ⊨ φ   (includes present)
M,τ,x ⊨ H(φ) iff ∀ s ≤ x, M,τ,s ⊨ φ   (includes present)
M,τ,x ⊨ φ U ψ iff ∃ s ≥ x, ψ(s) ∧ ∀ r ∈ [x,s), φ(r)
```

**Irreflexive Semantics (strict):**
```
M,τ,x ⊨ G(φ) iff ∀ s > x, M,τ,s ⊨ φ   (strictly future)
M,τ,x ⊨ H(φ) iff ∀ s < x, M,τ,s ⊨ φ   (strictly past)
M,τ,x ⊨ φ U ψ iff ∃ s > x, ψ(s) ∧ ∀ r ∈ (x,s), φ(r)  [one convention]
                   OR ∃ s ≥ x, ψ(s) ∧ ∀ r ∈ (x,s), φ(r) [another convention]
```

**Axiom Changes Under Irreflexive Switch:**
- **BX1 (G(φ) → φ) is DROPPED**: Under strict G, "all strictly future times" does not include now, so this is invalid.
- **BX1' (H(φ) → φ) is DROPPED**: Same reason.
- **BX8 (ψ → φ U ψ): interpretation changes**: Under strict Until (s > x), the reflexive base case ψ(x) → φ U ψ at x fails if witness must be strictly future. Must use s = x itself as witness (which would need s ≥ x, not s > x). Under strict Until with ≥-witness, BX8 is still valid.
- **BX11 (linearity) stays valid** on linear orders regardless.
- **BX4 (G(φ∧ψ) ↔ G(φ)∧G(ψ)) stays valid** since it's just about universals.
- **temp_4 (G(φ) → G(G(φ))) stays valid**: If φ holds at all t' > t, then at any t' > t and t'' > t', we have t'' > t, so φ(t''). Thus G(φ)(t') holds.

**What breaks in existing theorems:**

The `StrictSemanticsLegacy/` directory is EXACTLY the old irreflexive/strict semantics infrastructure. The files `BaseCompleteness.lean`, `DenseCompleteness.lean`, `DiscreteCompleteness.lean` were the completeness framework under STRICT semantics.

The key problematic sorry under reflexive semantics is `dd_bfmcs_restricted_buc` (backward Until/Since coherence), which requires:
```
(φ U ψ) ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs(r) → (φ U ψ) ∈ fam.mcs(r)
```

Under **irreflexive (strict) Until** (witness s > t), this step transfer has a clean proof: if `(φ U ψ)` holds at r+1 (meaning ∃s > r+1, ψ(s) ∧ φ on (r+1,s)), and `φ ∈ fam.mcs(r)`, then the same s works at r: s > r+1 > r, and (r, s) = {r} ∪ (r+1, s), so φ holds on (r, s) by combining `φ ∈ fam.mcs(r)` and φ on (r+1, s).

Under **reflexive Until** (witness s ≥ t), the step gives s ≥ r+1 and φ on [r+1, s). The interval at r is [r, s) = {r} ∪ [r+1, s), so φ on [r, s) by combining `φ ∈ fam.mcs(r)` and φ on [r+1, s). This is EXACTLY the same argument! But BX8 (ψ → φ U ψ) under reflexive semantics uses s = r as the base case (same time), while strict Until would use a chain argument. The actual difference is in whether `backward_until_reflexive` (BX8) handles the base case. Under irreflexive Until, the base case `ψ(s), s = t` does NOT give `φ U ψ` at t (since witness must be strictly future).

**The real problem**: The comment in `UntilSinceCoherence.lean` (line 31-35) says:
> Under BX reflexive semantics, (⊥ U α) ↔ α in any MCS, so the deterministic chain is constant and backward Until is trivially satisfied.

This means under reflexive semantics, the deterministic chain (archived to DiscreteXY) trivializes. The `DovetailedChain.lean` says its 6 sorries stem from "bot-Until-level consistency vs g_content-level propagation" — this is the X-vs-G mismatch.

### 4. Does the Boneyard Have Different Until/Since Approaches?

The `StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` documents the approach under strict semantics. Under strict semantics:
- `(⊥ U α)` at time t means ∃ s > t, α(s) ∧ (⊥ on (t,s)), which simplifies to ∃ s > t, α(s).
- So `(⊥ U α) ∈ chain(n)` ↔ `F(α) ∈ chain(n)` under strict semantics.
- This is NOT the same as `α ∈ chain(n)` (unlike under reflexive semantics where ⊥ U α ↔ α by BX8 with s=t).

This means under STRICT semantics, the deterministic chain (using bot-Until content) is NOT trivial — it provides the X-content linking needed for backward Until propagation. This is potentially why `StrictSemanticsLegacy` was more promising before it was abandoned.

### 5. Reusable Boneyard Infrastructure

**High-value sorry-free infrastructure:**
- `StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` — Direct TruthLemma; can potentially be revived under strict semantics
- `StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` — R_G/R_Box foundations
- `ChainCompleteness/Bundle/MCSWitnessChain.lean` — DRM chain with sorry-free properties
- `RoundRobinChain/DRMChain.lean` — Sorry-free seed subset and consistency theorems
- `BXCanonical/Boneyard/OracleCoherence.lean` — qm_oracle_step / qm_oracle_step_bwd infrastructure (0 sorries)
- `BXCanonical/Boneyard/RoundRobinChain.lean` — rrSchedule lemmas, enriched_fwd_step_spec

### 6. dd_chain Analysis (Current Active Approach)

The current active `dd_bfmcs` in `RootScopedChain.lean` uses a `fwd_chain_of_sigma` built from `preserving_fwd_step`. The `fwd_chain_forward_F` sorry (line 1111) says:
> "Termination argument requires well-founded induction on defect count or a pigeonhole argument."

This is structurally similar to the abandoned round-robin approach. The key difference is the `enriched_fwd_step` (which uses `resolving_enriched_fwd_exists` and the BX11 fold) to protect F-obligations. But the BX11 perpetual deferral obstruction documented in `BXCanonical/Boneyard/RoundRobinChain.lean` may apply here too.

## Recommended Approach

### Option A: Irreflexive Semantics Switch

**Assessment**: The user prefers this and it is likely the correct path.

**What changes:**
1. `Truth.lean`: Change `s ≤ t` to `s < t` for `all_past`, `t ≤ s` to `t < s` for `all_future`. For Until/Since: change witness condition (there are two sub-options — see below).
2. Remove `BX1 (temp_t_future)` and `BX1' (temp_t_past)` from `Axioms.lean` or keep them as separate axiom variants.
3. The existing `StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` was built under strict semantics and can potentially be revived.

**Until/Since under irreflexive semantics — two sub-options:**

Sub-option A1: Strict witness (s > t for U, s < t for S):
- BX8 (ψ → φ U ψ) becomes invalid (no strictly future witness at current time)
- Need a replacement base axiom for Until (e.g., ψ → (φ U ψ) only holds if we allow s = t)
- This is the "pure irreflexive" system

Sub-option A2: Reflexive witness, strict guards (current Truth.lean for Until/Since):
- Actually the current Truth.lean ALREADY uses reflexive witness: `t ≤ s` for Until witness
- The guard is open: `t ≤ r → r < s`
- Only G/H change to strict (<, >)
- BX8 remains valid: ψ(t), s = t, no r in [t, t) = empty, so φ U ψ holds

**Under Sub-option A2 (change only G/H to strict, keep Until/Since as-is):**
- BX1 (G(φ) → φ) is dropped
- The backward Until step transfer `(φ U ψ) ∈ fam(r+1) ∧ φ ∈ fam(r) → (φ U ψ) ∈ fam(r)` still uses BX8 for base case
- The DovetailedChain.lean X-vs-G mismatch: under strict G, `(⊥ U α)` ∈ chain(n) means ∃ s ≥ n, α(s) (since s = n works via BX8 with reflexive witness). So `(⊥ U α) ∈ chain(n) ↔ α ∈ chain(n)` still holds under G/H-strict with Until reflexive! The deterministic chain approach would still be trivially constant.

**Under Sub-option A1 (strict witness for Until/Since too):**
- `(⊥ U α)` at n means ∃ s > n, α(s) = `F(α)` (properly strict eventuality)
- The deterministic chain using bot-Until content becomes non-trivial
- `backward_until_step` becomes: at r, (φ U ψ) ∈ fam(r+1) means ∃ s > r+1, ψ(s) ∧ φ on (r+1,s). Since s > r+1 > r, φ on (r, s) uses φ ∈ fam(r) for the single new point. This works!
- This fully resolves the step transfer sorry

**Conclusion on irreflexive switch**: Sub-option A1 (strict G, H, U, S) is the most promising:
1. Eliminates BX1/BX1'
2. Makes backward Until step transfer provable
3. The `StrictSemanticsLegacy` directory was built for exactly this case
4. The "DovetailedChain X-vs-G mismatch" may be more tractable under strict semantics

### Option B: Stay With Reflexive Semantics

The `dd_bfmcs_restricted_buc` sorry is the hardest blocker under reflexive semantics. It requires a step transfer that is not directly available from standard Lindenbaum chain structure. Would need the deterministic chain (DiscreteXY) approach or enriched seeds. The `UntilSinceCoherence.lean` provides `backward_until_from_step` which is ready to use once the step transfer is proven.

## Evidence/Examples

**Key evidence for irreflexive switch:**
1. `StrictSemanticsLegacy/FrameConditions/Completeness.lean` comment (line 50):
   > "IMPORTANT (2026-03-31): The bundle construction provides BUNDLE-level temporal coherence, which is semantically INSUFFICIENT for TM task semantics."
   This was the reason the strict semantics path was abandoned in favor of BXCanonical — but the obstruction was semantic (bundle vs. family), not about irreflexive vs. reflexive.

2. `UntilSinceCoherence.lean` (line 31-35): "Under BX reflexive semantics, (⊥ U α) ↔ α in any MCS, so the deterministic chain is constant" — this is a known limitation specific to REFLEXIVE semantics.

3. `Boneyard/RoundRobinChain.lean` comment: "confirmed dead after 40 rounds" and "BX11 perpetual deferral obstruction blocks depth-0 base case permanently" — this obstruction is inherent to the reflexive G semantics (BX11 interacts with G to block F-discharge).

4. `DovetailedChain.lean` (line 43-46): "Lindenbaum seeds provide bot-Until-level consistency... but Until persistence through chain steps requires g_content-level propagation... not G-liftable — G(neg(⊤ U ψ)) ∈ chain(n) does not contradict (⊤ U ψ) ∈ chain(n) under strict semantics." This means the X-vs-G mismatch is specific to when strict semantics are applied to bot-Until content while the chain uses reflexive G.

**Key evidence against irreflexive switch:**
1. All existing theorems in `Theorems/` and `ProofSystem/` assume reflexive semantics (BX1-BX12 axiom system).
2. `Soundness.lean` proofs would need to be re-verified.
3. TaskFrame semantics (`nullity_identity`: `task_rel w 0 w`) is inherently reflexive — need to verify this is compatible with irreflexive temporal operators.

## Confidence Level

**Irreflexive switch (Sub-option A1) breaks the backward_until obstruction**: High, 85%
- The step transfer proof under strict Until is clean and follows directly from the semantics
- The DovetailedChain archive explicitly notes the strict vs. reflexive distinction

**Irreflexive switch is feasible overall**: Medium, 65%
- Requires significant refactoring (Truth.lean, Axioms.lean, all soundness proofs)
- The StrictSemanticsLegacy directory shows prior work in this direction but it was abandoned for different reasons (bundle vs. family coherence gap, not semantics-vs-axiomatics)
- Several axioms (BX8 under strict Until, BX12) would need semantic re-verification
- Need to check that TaskFrame's `nullity` (reflexivity) is not contradicted by irreflexive temporal operators (they can coexist — task completion semantics can remain reflexive while temporal reading windows are strict)

**Boneyard infrastructure reuse**: Medium-high, 70%
- `CanonicalConstruction.lean` (StrictSemanticsLegacy) has the right structure for strict semantics truth lemma revival
- `DRMChain.lean` seed infrastructure is sorry-free and likely reusable
- The oracle step infrastructure from `OracleCoherence.lean` is preserved and sorry-free
