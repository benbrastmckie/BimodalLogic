# Teammate A Findings: Analyze v39 Implementation Failure and Validate Obstacle (Round 40)

## Summary

The v39 implementation failure is **confirmed and well-characterized**. The proposed derived rule `phi ∧ F(phi U psi) → phi U psi` is semantically invalid, and this is not a proof-engineering gap but a genuine logical impossibility. The obstacle at the backward Until inductive step is irreducible given the dd_chain's non-constant structure. The asymmetric difficulty assessment (buc=hard, tc=hard, fuc=medium) is more accurate than the v39 plan suggested: all three sorry sites are equally blocked by the same root tension.

---

## Key Findings

### Finding 1: `phi ∧ F(phi U psi) → phi U psi` is Semantically Invalid

**Confirmed** by direct examination of BX axioms. The axiom system (BX1-BX12) is sound on all linear temporal orders. The proposed rule is unsound:

- **Counter-model**: Linear order {0, 1, 2}. φ holds at 0, ψ holds at 2, φ holds at 0 but NOT at 1. Then F(φ U ψ) holds at t=0 (witness t=2: ψ holds there), but φ U ψ does NOT hold at t=0 because the guard fails at t=1.

This invalidates any derivation from BX1-BX12. The relevant BX axioms are:
- **BX8**: `ψ → (φ U ψ)` — requires ψ at current time, not useful here
- **BX9**: `(φ U ψ) → (φ ∨ ψ)` — goes in wrong direction
- **BX10**: `(φ U ψ) → F(ψ)` — goes in wrong direction
- **BX12**: `F(φ) → (⊤ U φ)` — bridges F to Until but wrong formula

None of BX1-BX12 can bridge `{φ, F(φ U ψ)}` to `φ U ψ`. This gap is provably irreducible because the counter-model witnesses genuine semantic invalidity.

### Finding 2: The dd_chain's Non-Constant Structure Is the Root Tension

The Boneyard proof (`backward_until_chain` in DeterministicFMCS.lean) proves backward Until coherence by induction using `x_mem_chain_general`:
```
φ ∈ chain(t+1) ↔ X(φ) ∈ chain(t)
```
This works because `X(φ) = ⊥ U φ ↔ φ` under reflexive Until (BX8), making the deterministic chain **constant**: `chain(t) = M₀` for all t. Backward Until at the inductive step is immediate because `phi U psi ∈ chain(t+1) = M₀ = chain(t)`.

The dd_chain is fundamentally different:
- `rr_fwd_chain` uses `enriched_fwd_step` which changes the MCS at each step to resolve F-defects
- The BX11 fold may add/remove formulas at resolving steps
- `phi U psi ∈ chain(t+1)` does NOT imply `phi U psi ∈ chain(t)`
- g_content/h_content propagation transfers only G-wrapped/H-wrapped formulas

From `phi U psi ∈ chain(t+1)`, using BX4' (`connect_past`: `α → H(F(α))`):
- `H(F(phi U psi)) ∈ chain(t+1)` by BX4'
- `F(phi U psi) ∈ chain(t)` by h_content backward propagation

This gives `{phi, F(phi U psi)} ⊆ chain(t)` — but as Finding 1 shows, this is insufficient to derive `phi U psi ∈ chain(t)`.

### Finding 3: All Three Sorry Sites Share the Same Root Obstacle

The v39 plan assessed difficulty as buc=easy, tc=hard, fuc=medium. This is inaccurate:

- **dd_bfmcs_restricted_buc** (line 1522): Requires backward Until coherence for dd_chain families. The inductive step is blocked by the invalid derived rule (Finding 1). **Hard** (same root obstacle as tc).

- **dd_bfmcs_restricted_tc** (line 1517): Requires forward_F/backward_P eventuality resolution. This is the deep rr_fwd_chain_forward_F obstacle (depth-0 base case, BX11 perpetual deferral). **Hard** (known obstacle since round 26).

- **dd_bfmcs_restricted_fuc** (line 1527): Requires forward Until/Since coherence. Given `phi U psi ∈ fam.mcs(t)`, need to find a witness `s ≥ t` with `ψ ∈ fam.mcs(s)` and guard on `[t, s)`. By BX10, `F(psi) ∈ fam.mcs(t)`, so forward_F is needed to get the witness. This depends on restricted_tc. **Medium-Hard** (depends on tc).

All three are blocked by the fundamental tension between:
- **F-resolution** requiring the chain to change (enriched_fwd_step introduces non-constant behavior)
- **Until coherence** relying on formulas persisting across chain steps

### Finding 4: The Boneyard's YX/XY Round-Trip Has Dead Sorries

The DeterministicFMCS.lean Boneyard proof depends on `x_det` and `y_det` axioms (lines 192-225), which are marked as `sorry` with the comment "removed in BX." These are X/Y determinism axioms for the discrete-time next/yesterday operators. Under BX (reflexive Until), X(φ) = ⊥ U φ and Y(φ) = ⊥ S φ are equivalent to φ (not to the next-step operator). The Boneyard proof of `YX_round_trip` and `XY_round_trip` is therefore INVALID as written — it uses removed axioms. However, this doesn't affect the main result: `backward_until_chain` (lines 341-396) does NOT use these round-trip lemmas and is actually sorry-free for the discrete deterministic chain.

### Finding 5: No BX1-BX12 Workaround Exists for the Backward Until Gap

Exhaustive analysis of available until/since infrastructure in TemporalDerived.lean:
- `psi_imp_until` (BX8): `ψ → (φ U ψ)` — base case only
- `until_imp_or` (BX9): `(φ U ψ) → (φ ∨ ψ)` — wrong direction
- `until_imp_F` (BX10): `(φ U ψ) → F(ψ)` — wrong direction
- `or_until_imp`: `(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)` — requires `φ U ψ` in premise
- `until_intro`: `X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)` — requires next-step operator X(·)
- `until_F_expansion`: `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))` — wrong direction

The `until_intro` rule is the closest match. It converts `X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)` into `(φ U ψ) ∈ chain(t)`. This would work if we could establish `ψ ∈ chain(t+1)` or `(φ ∧ (φ U ψ)) ∈ chain(t+1)`. But for the inductive step we have `(φ U ψ) ∈ chain(t+1)` and `φ ∈ chain(t)`, and X(·) = ⊥ U (·), so `X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)` iff `ψ ∨ (φ ∧ (φ U ψ)) ∈ chain(t+1)` — which would follow from `φ U ψ ∈ chain(t+1)` by taking the right branch. This IS a valid path if the dd_chain satisfies x_content/y_content membership — but it does NOT: the dd_chain is not a successor chain in the discrete sense.

### Finding 6: The Quasimodel Oracle Approach (Phase 2-4) Was Not Reached

v39 never got to Phase 2 (HintikkaStepOracle discharge). The oracle approach is potentially viable but untested. The critical question left unanswered from the v39 plan:
- Does `bx_le w v` give `h_content(v) ⊆ w`?
- Does the extended seed consistency argument work for Until defects?

---

## Evidence

### Code Evidence

1. **RootScopedChain.lean lines 1512-1527**: The three sorry sites exist with no implementation attempts.

2. **TemporalDerived.lean lines 335-413**: The `or_until_imp`, `until_intro` infrastructure exists and is sorry-free. `until_intro` takes `X(·)` form and cannot be applied without x_content/y_content membership on the dd_chain.

3. **DeterministicFMCS.lean lines 341-453**: `backward_until_chain` and `backward_since_chain` are sorry-free and work for constant chains using `x_mem_chain_general`/`y_mem_chain_general` which depend on chain step being equivalent to X(·)/Y(·)-membership. This proof pattern does NOT transfer to dd_chain.

4. **RootScopedChain.lean lines 1371-1385**: The `rr_fwd_chain_forward_F` theorem has a documented sorry at the depth-0 base case with extensive commentary (formerly Sections 1-30) explaining why direct approaches fail.

5. **BX Axioms verification**: No axiom among BX1-BX12 has the form `A ∧ F(A U B) → A U B` or anything semantically equivalent. The system is confirmed sound on all linear orders, so semantic invalidity proves non-derivability.

### Mathematical Evidence

The semantic counter-model for `φ ∧ F(φ U ψ) → φ U ψ`:
- Frame: ℤ with standard order
- Valuation: φ holds at 0 and 2+; ψ holds at 2; φ fails at 1
- At t=0: φ holds (the antecedent's left conjunct is satisfied)
- F(φ U ψ) holds at t=0: the witness is t=2 where ψ holds, and we only need ψ at the witness (not guard satisfaction from 0 to 2)

Wait: F(φ U ψ) says ∃s ≥ 0, (φ U ψ)(s). At s=2: (φ U ψ)(2) requires ∃r ≥ 2, ψ(r) ∧ ∀q ∈ [2,r), φ(q). Take r=2, then ψ(2) holds and the guard [2,2) is empty. So (φ U ψ)(2) holds. So F(φ U ψ)(0) holds via witness s=2.

But (φ U ψ)(0) requires ∃r ≥ 0, ψ(r) ∧ ∀q ∈ [0,r), φ(q). For r=2: ψ(2) holds but φ(1) is required and fails. No other witness works. So (φ U ψ)(0) fails.

Counter-model confirmed.

---

## Confidence Level

**High confidence** on all core findings:

1. Semantic invalidity of `φ ∧ F(φ U ψ) → φ U ψ`: **verified by explicit counter-model** (no ambiguity)
2. g_content/h_content insufficient for backward Until: **verified by analysis of propagation mechanism**
3. Boneyard proof inapplicable to dd_chain: **verified by examining why x_mem_chain_general works only for constant chains**
4. No BX1-BX12 workaround: **high confidence** (exhaustive check of all 12 BX axioms and known derived theorems; no semantic route exists)
5. All three sorry sites equally hard: **high confidence** (tc and buc have same root tension; fuc depends on tc)

**Low confidence** (not examined in v39):
- Whether the quasimodel oracle approach (Phases 2-4) can succeed — not reached in v39

---

## Recommended Next Steps

### Immediate: Abandon the Direct dd_chain Backward Until Approach

The backward Until coherence proof on the existing dd_chain is provably impossible via the BX derivation path attempted in v39. No BX-derived rule bridges `{φ, F(φ U ψ)} → φ U ψ`.

### Path 1: Quasimodel Oracle (Most Promising, Untested)

The v39 plan's Phases 2-4 (quasimodel oracle approach) were never reached. The corrected argument for extended seed consistency (Until defects bypass G-lifting, come from w.formulas directly) is plausible. This requires:
- Phase 2: Verify `HintikkaStepOracle` discharge for SubformulaClosure(root)
- Phase 3: Build Chain-to-FMCS bridge with bidirectional coherence
- Phase 4: Wire into dd_countermodel

The critical unknowns to resolve at the start of Phase 2:
1. Does `bx_le w v` give `h_content(v) ⊆ w`? If yes, `hintikka_step` H-backward is satisfied trivially.
2. Does `until_eventuality_resolution` provide a witness `v` with explicit structural properties beyond bare `bx_le`?

### Path 2: New BFMCS Construction with Unified Coherence

Build a completely new BFMCS (not dd_bfmcs) where:
- Each family uses a single MCS (constant chain structure)
- F-witnesses are provided by a separate oracle mechanism
- Backward Until is trivial (constant chain + BX8)
- Forward Until reduces to forward_F via BX10

This avoids the tension entirely but requires ~800-1200 LOC.

### Path 3: Restricted BUC via Weaker Seed

Investigate whether `dd_bfmcs_restricted_buc` alone can be proved by constructing a DIFFERENT chain where:
- The backward chain uses bwd_pred (h_content propagation, already sorry-free)
- Backward Until coherence holds because h_content propagation is the right direction

The rr_bwd_chain already has `h_content(chain(n)) ⊆ chain(n+1)` (backward direction). For backward Since coherence on the backward chain, this IS the right direction. But backward Until coherence (time-reversed forward direction) still requires the same gap.

### Anti-Recommendation

Do NOT attempt:
- Any derived rule from BX1-BX12 that uses `φ` and `F(φ U ψ)` to prove `φ U ψ` — semantically impossible
- Seed augmentation with Until formulas — consistency argument fails (G-necessitation doesn't apply to Until formulas)
- Adapting the Boneyard deterministic chain proof — requires constant chain structure absent in dd_chain
