# Teammate D Findings — Round 11: Strategic and Creative Approaches

**Task**: 93 - Close BXCanonical embedding (sole remaining active-path sorry)
**Date**: 2026-04-13
**Role**: Strategic Horizons
**Prior round**: Report 10 (team research, round 10) — Plan v8 declared dead; quasimodel BFMCS (D's Approach 5) and root-parameterized chain (B's approach) identified as successors.

---

## Key Findings

### 1. Roadmap Position and Unlock Value

Task 93 closes the **sole remaining active-path sorry** in the 3,473-line BXCanonical module. The ROAD_MAP documents:

- Exactly 1 sorry at `Completeness.lean:154` (via `bx_countermodel`)
- Completing task 93 makes `bx_completeness` and `completeness_over_Int` fully sorry-free
- Unblocks task 95 (`#print axioms bx_completeness` audit confirming only `propext`, `Classical.choice`, `Quot.sound`)
- Dense completeness (task 68, D = Rat) is **independent** and cannot be reduced to the integer chain — it needs a separate dense canonical model. Task 93 does not block task 68 and vice versa.

The strategic value is high: completing task 93 transforms the project from "nearly complete" to "complete for the BX linear completeness theorem." This is a significant milestone for potential publication.

### 2. The 3 Active Sorry Sites

The 3 sorry sites at `CanonicalModel.lean` lines 603-627 (`bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc`) all reduce to two core obligations:

**Obligation A (forward_F)**: Given `F(ψ) ∈ (bx_fmcs M₀ h₀).mcs t`, prove `∃ s > t, ψ ∈ (bx_fmcs M₀ h₀).mcs s`.

**Obligation B (backward Until/Since step transfer)**: Given the right witness pattern, prove `(φ U ψ) ∈ fam.mcs t`. The `UntilSinceCoherence` module provides `backward_until_from_step` parameterized by a step-transfer hypothesis — but no chain construction has provided the hypothesis.

### 3. Why 10 Rounds of Research Converge on Two Paths

After reading all prior reports and the codebase, the mathematical barrier is clear and stable:

- The scheduling chain loses F-formulas at resolving steps (proven anti-pattern, dead end #3 in ROAD_MAP)
- Adding `untilCarry` to the resolving seed is inconsistent (counterexample: `{ψ, ¬α, αUψ}`, Report 10)
- BX12 (`F(ψ) → (⊤Uψ)`) cannot reduce forward_F to forward Until unless `(⊤Uψ)` is in `deferralClosure` — and it isn't with the current definition
- Full quasimodel replacement (Architecture C) hits the Realization.lean G-persistence obstacle at `Realization.lean:366-395`

**Two paths remain viable** (confirmed by round 10 synthesis):
1. **BX12 + quasimodel BFMCS** (D's Approach 5, report 10): extend `deferralClosure`, build BFMCS from quasimodel chains
2. **Root-parameterized chain** (B's approach, report 10): finite round-robin schedule over `deferralClosure(root)`

### 4. Literature Survey: How Standard Completeness Proofs Handle the F-Persistence Problem

**Burgess 1984 ("Basic Tense Logic")** and **Xu 1988** both use the **quasimodel with defect-discharge** technique. The key is that a quasimodel (finite Hintikka chain) discharges all eventualities by construction — there is no F-persistence problem in the finite setting. F-formulas are discharged before the chain ends. The infinite extension is handled by noting that the defect count reaches zero, so the tail can be a single repeated point with no pending eventualities.

**Reynolds 1996/2003** (cited in round 10 synthesis as the "Reynolds enrichment insight") uses enriched closures that include `(⊤Uψ)` for each `F(ψ)` in the closure. This directly corresponds to the BX12 reduction: `F(ψ) → (⊤Uψ)` is BX12. The Reynolds construction ensures forward_F is never a separate obligation — it is always an Until obligation.

**Goldblatt 1992 ("Logics of Time and Computation")** uses filtration over a finite set. The filtration ensures all F-eventualities are witnessed within a bounded range, avoiding the infinite chain problem. The codebase already has `Filtration/` infrastructure.

**Xu 1988** simplifies Burgess by showing that the axiom BX12 (`F(φ) → (⊤Uφ)`) is the key bridge. When the closure includes `(⊤Uψ)` whenever it includes `F(ψ)`, the forward Until coherence subsumes forward_F. This is the theoretical basis for extending `deferralClosure`.

**Conclusion**: Standard completeness proofs avoid forward_F as an independent obligation either by (a) working entirely with Until (enriched closure including `⊤Uψ` for each `F(ψ)`) or (b) using quasimodel defect-discharge where F-obligations are explicitly discharged in finite steps. The BX12 + quasimodel BFMCS approach follows path (a)+(b) simultaneously.

### 5. Scope Reduction Analysis

The question "can we close just one sorry independently?" deserves a direct answer:

**Can `bx_bfmcs_restricted_buc` be closed independently?**
Yes, in principle — but it requires backward Until step-transfer, which is the same hard problem. The `backward_until_from_step` wrapper in `UntilSinceCoherence.lean` accepts a step-transfer hypothesis but nothing provides it.

**Can `bx_bfmcs_restricted_tc` (forward_F) be closed independently?**
This IS the core blocker. Closing forward_F closes restricted_tc, which is then used by restricted_fuc (forward Until reduces to forward_F + Until persistence). So restricted_tc must come first.

**Minimal sorry endpoint**: If we accept a sorry-with-documented-blocker for `bx_bfmcs_restricted_buc` and close only restricted_tc + restricted_fuc, we would have:
- `bx_countermodel` still has a sorry (via restricted_buc)
- `bx_completeness` still has a sorry
- This is not a meaningful milestone

**Conclusion**: All 3 sorry sites must be closed together. There is no partial victory with fewer.

### 6. Feasibility Assessment of the Two Paths

**Path 1: BX12 + quasimodel BFMCS (D's Approach 5)**

Structure:
1. Extend `deferralClosure` to include `(⊤Uψ)` for each `F(ψ)` already in the closure (~20 lines in `SubformulaClosure.lean`)
2. Build `quasimodel_fmcs : Formula → MCS → FMCS Int` using the existing quasimodel defect-discharge infrastructure
3. Extend finite chain to Int with identity tail (MCS repeated after last defect-discharge step)
4. Prove restricted coherence from quasimodel properties

**Obstacles to clarify**:
- The identity tail: if chain is `[h_0, h_1, ..., h_n]` with all defects discharged by `h_n`, then `chain(k) = h_n` for all `k > n`. For restricted_tc, forward_F for any `ψ ∈ deferralClosure(root)` that is still in `h_n` as `F(ψ)` would need resolution — but if all defects are discharged, `F(ψ)` should not be in `h_n` (otherwise it is an unresolved defect). This needs verification.
- The Realization.lean G-persistence obstacle: round 10 Teammate A identified this obstacle for TRADITIONAL Architecture C (lifting Hintikka chains to BXPoint chains with g_content propagation). D's Approach 5 does NOT require g_content propagation through the Hintikka chain — it uses the chain directly as the FMCS mcs function. This bypasses the obstacle.
- The FMCS interface: `FMCS Int` requires `forward_G` and `backward_H` properties. The Hintikka chain has `hintikka_step` for G-propagation within Sigma, but full `forward_G` (for arbitrary `G(χ) ∈ chain(t)`) requires `G(χ) ∈ Sigma`. This is the Realization.lean obstacle. **However**, for RESTRICTED coherence, we only need forward_G for formulas in `deferralClosure(root)`, which IS bounded. If the Hintikka chain's sigma is `SubformulaClosure(root)`, then G-propagation within Sigma handles all `G(χ)` with `χ ∈ subformulaClosure(root) ⊆ deferralClosure(root)`.

**Key insight for Path 1**: The obstacle is only fatal for FULL forward_G (arbitrary formulas). For RESTRICTED coherence, G-propagation within `SubformulaClosure(root)` suffices. The existing `hintikka_step_g_prop` lemma at `Realization.lean:419+` provides exactly this.

Estimated effort: 300-400 lines. Confidence: MEDIUM-HIGH.

**Path 2: Root-parameterized chain with finite round-robin**

Structure: Modify the scheduling chain to use a finite round-robin schedule over `deferralClosure(root)`, ensuring every F-formula in `deferralClosure(root)` is targeted infinitely often. The non-resolving seed preserves F-formulas via `f_carry`.

**Obstacles**:
- F-formulas are lost at resolving steps: when resolving `ψ`, only `g_content(M) ∪ {ψ}` is the seed. F-formulas in `f_carry(M)` that conflict with `ψ` are lost. However, **restricted** forward_F only cares about F-formulas in `deferralClosure(root)`. If the schedule resolves each such formula eventually, restricted_tc can be proven.
- Step transfer for backward Until: Even with restricted carry, step transfer requires `(φUψ) ∈ chain(r+1) → (φUψ) ∈ chain(r)`. This needs `(φUψ) ∈ restrictedUntilCarry(chain(r))`, which requires `(φUψ) ∈ chain(r)`. Circular if applied naively. The BX4' + BX12 argument from plan v8 Phase 4 may apply: from `(φUψ) ∈ chain(r+1)`, derive `F(φUψ) ∈ chain(r)` via BX4' + backward H, then use BX12 + MCS maximality to derive `(φUψ) ∈ chain(r)`. This is NOT circular and may be the key step transfer mechanism.

Estimated effort: 250-350 lines. Confidence: MEDIUM.

### 7. The Step Transfer Problem: A Novel Approach

The step transfer obstacle is shared by both paths. Here is a new angle not explored in prior reports:

**Observation**: `(φUψ) ∈ chain(r+1)` means the seed for `chain(r+1)` included `(φUψ)` at step r. The seed for step r+1 includes `g_content(chain(r)) ∪ f_carry(chain(r)) ∪ [resolving target if applicable]`. So if `(φUψ) ∈ seed(r+1)`, either:
- `(φUψ) ∈ g_content(chain(r))` — meaning `G(φUψ) ∈ chain(r)`, so by BX T-axiom `(φUψ) ∈ chain(r)`. Done.
- `(φUψ) ∈ f_carry(chain(r))` — meaning `F(φUψ) ∈ chain(r)`. Then: `F(φUψ) → φ ∨ (φUψ)` is derivable? Not directly, but BX12: `F(φUψ) → (⊤U(φUψ))`, and BX9: `(⊤U(φUψ)) → ⊤ ∨ (φUψ) = ⊤`, which gives nothing. However, `F(φUψ) → F(φ ∨ ψ)` via BX9 + temporal K. This doesn't directly give `(φUψ)`.

Actually, the key is: `F(φUψ) ∈ chain(r)`. By BX12: `(⊤U(φUψ)) ∈ chain(r)` (if BX12 is in the axioms, which it is as `F_until_equiv`). By BX9: `⊤ ∨ (φUψ) ∈ chain(r)` — which is `⊤` (tautology). This fails.

Better route: `F(φUψ) ∈ chain(r)`. By BX10: `F(ψ) ∈ chain(r)` via `(φUψ) → Fψ` and temporal K: `G((φUψ) → Fψ)` is a theorem, so `G(F(φUψ) → F(ψ))` is a theorem by K. Wait, that doesn't follow. Instead: `F(φUψ)` means `F(φ ∨ ψ)` by `BX9 + temporal K`, hence there exists a future point where `φ ∨ ψ`. But we need `(φUψ) ∈ chain(r)`.

**Correct route**: Use BX4' `connect_past`: `φ → H(F(φ))`. So `(φUψ) ∈ chain(r+1)` → `H(F(φUψ)) ∈ chain(r+1)` → by backward H: `F(φUψ) ∈ chain(r)` for all earlier points. Then from `F(φUψ) ∈ chain(r)`, can we get `(φUψ) ∈ chain(r)`?

`F(φUψ) → (⊤U(φUψ))` by BX12 (axiom `F_until_equiv`). So `(⊤U(φUψ)) ∈ chain(r)` by MCS closure. By BX9: `(⊤U(φUψ)) → ⊤ ∨ (φUψ)` — tautological output. Not useful.

However: `(⊤U(φUψ))` means `∃s ≥ r, (φUψ) holds at s` and `⊤` holds on `[r, s)`. By BX8: `φUψ → ⊤U(φUψ)`. By BX9: `⊤U(φUψ) → ⊤ ∨ (φUψ)`. So `(⊤U(φUψ)) ↔ (φUψ)` only holds if BX9 collapses the left disjunct to ⊤ (always true). So `(⊤U(φUψ)) ∈ chain(r)` does NOT imply `(φUψ) ∈ chain(r)` by this route.

**Revised insight**: The step transfer cannot be derived purely from F-persistence. The g_content route (first bullet above) is the only clean route. This means: for step transfer to work, we need `G(φUψ) ∈ chain(r)` whenever `(φUψ) ∈ chain(r+1)`. This requires Until formulas to be "G-captured" — a strong property that is not generally true.

**Conclusion**: The step transfer for arbitrary Until formulas on the scheduling chain remains blocked. This is why the quasimodel approach is superior: in a quasimodel chain, step transfer is BUILT IN to the defect-discharge mechanism. When `(φUψ)` is a defect at step r, it stays a defect until it is discharged, so it persists by construction.

### 8. Alternative Decomposition: Accept Sorries with Documentation

After 10 rounds of research and 2 failed implementation attempts, consider whether a documented-sorry endpoint has value:

**Arguments for accepting sorries now:**
- The 3 sorry sites are mathematically well-understood — the obstacles are not mysterious
- The rest of the BXCanonical module (3,470+ lines) is sorry-free and represents substantial verified work
- The quasimodel infrastructure for Until/Since is complete and sorry-free (tasks 90-102)
- The truth lemma is complete for all operators including Until/Since
- The completeness theorem structure is correct — only the temporal coherence witness is missing

**Arguments against:**
- The project goal is a sorry-free `bx_completeness` theorem
- The roadmap marks this as "OPEN (task 93)" with no sorry being the definition of done
- Task 95 (`#print axioms` audit) is blocked
- The two viable paths (quasimodel BFMCS and root-parameterized chain) are well-scoped and estimated at 250-400 lines
- Accepting sorries at this stage would mean stopping ~94% complete

**Recommendation**: Do NOT accept sorries. Proceed to implementation with Path 1 (BX12 + quasimodel BFMCS). The scope is well-understood, the mathematical obstacles are identified, and the existing 2,289-line quasimodel infrastructure provides the needed building blocks.

### 9. Can We Avoid the Chain Construction Entirely?

**Direct countermodel from non-theorem**: Instead of a chain, build a single-point model directly. For a non-theorem `φ`, the MCS `M` containing `¬φ` is the countermodel point. The truth lemma works for `box`, `atom`, `bot`, `imp`. For `G(ψ) ∈ M`, we need `ψ ∈ M` (by BX1), and for `G` semantics we need a whole future. This is exactly the problem — a single-point model cannot support `G` semantics.

**Algebraic completeness via Lindenbaum algebra**: The `Algebraic/` directory has `ParametricRepresentation.lean` which bridges algebraic to semantic truth. This is the current path! The `fully_restricted_parametric_representation_from_neg_membership` theorem is used in `bx_countermodel`. The algebraic approach is already in use — we just need the temporal coherence witnesses.

**Compactness + finite model property**: FMP gives decidability but is explicitly listed as dead end #10 in ROAD_MAP — it does not provide a shortcut to completeness. Confirmed anti-pattern.

**Algebraic/topological approaches**: The `Algebraic/` directory has `TenseS5Algebra.lean`, `BooleanStructure.lean`, `InteriorOperators.lean` (legacy). These are not on the active path and do not resolve the temporal coherence problem.

**Conclusion**: No alternative to the FMCS/BFMCS chain construction is viable. The algebraic representation theorem (`ParametricRepresentation.lean`) is the bridge, and it REQUIRES a BFMCS with temporal coherence properties. The problem is irreducibly about providing those properties.

---

## Strategic Recommendations

### Immediate Action: Verify the Identity Tail Property (1-2 hours)

Before committing to Path 1 (quasimodel BFMCS), verify one key assumption:

Given a `QuasimodelChain` for `SubformulaClosure(root)` with all defects discharged by step `n`, does `chain(k) = chain(n)` for all `k > n` satisfy the FMCS forward_G and backward_H properties restricted to `deferralClosure(root)`?

Answer: YES, trivially. A constant sequence has `mcs t = mcs t' = M_n` for all `t, t'`. Forward_G: `G(φ) ∈ M_n → φ ∈ M_n` (by BX T-axiom). Forward_G for the FMCS requires `G(φ) ∈ mcs t → φ ∈ mcs s` for `t ≤ s` — but `mcs s = mcs t = M_n`, so this reduces to `G(φ) ∈ M_n → φ ∈ M_n`, which holds by BX1. Similarly for backward_H. The identity tail trivially satisfies all coherence conditions because a constant sequence has only one MCS and all facts about it are trivially reflexive.

**Conclusion**: The identity tail verification is trivial. This removes one of round 10's "gaps to verify."

### Primary Path: BX12 + Quasimodel BFMCS (Path 1)

**Phase 1** (~20 lines): Extend `deferralClosure` to include `(⊤Uψ)` for each `F(ψ)` in the base closure. Concretely, add to `baseDeferralClosure` in `SubformulaClosure.lean`:
```lean
∪ (closureWithNeg phi).image (fun psi => Formula.untl Formula.bot psi)
```
This adds `(⊤Uψ)` = `Formula.untl Formula.bot ψ` for each `ψ ∈ closureWithNeg(phi)`.

**Phase 2** (~150 lines): Define `quasimodel_fmcs (root : Formula) (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) : FMCS Int`:
- For `t ≥ 0`: use step `t` of the `QuasimodelChain` for `SubformulaClosure(root)` starting from a Hintikka point derived from `M₀`. After `n` (chain length), use the final point.
- For `t < 0`: use a symmetric backward Hintikka chain (or: use the initial point M₀ for all `t < 0` via a constant backward tail).
- Prove `forward_G` and `backward_H` within `deferralClosure(root)`.

**Phase 3** (~100 lines): Prove restricted coherence:
- `restricted_tc`: forward_F reduces to forward Until via BX12 (since `(⊤Uψ) ∈ deferralClosure(root)` by Phase 1). Forward Until holds because the quasimodel discharges all Until defects by construction.
- `restricted_buc`: backward Until holds via `backward_until_from_step` with step transfer provided by the Hintikka chain's defect-persistence property.
- `restricted_fuc`: forward Until holds from BX9 + forward_F + Until persistence (standard argument).

**Phase 4** (~50 lines): Wire `quasimodel_fmcs` into `bx_bfmcs` families and update `bx_countermodel` to use the new coherence proofs.

### Fallback: Root-Parameterized Chain with BX4' Step Transfer (Path 2)

If Path 1 hits the quasimodel-to-FMCS interface gap (insufficient Sigma coverage), fall back to:

Modify the scheduling chain with a finite round-robin over `deferralClosure(root)`. Prove step transfer via the BX4' argument: `(φUψ) ∈ chain(r+1)` implies `H(F(φUψ)) ∈ chain(r+1)` via BX4', then backward H gives `F(φUψ) ∈ chain(r)`, then use the extended closure property to get `(⊤U(φUψ)) ∈ chain(r)` via BX12. To close step transfer: need `(⊤U(φUψ)) → (φUψ)` in MCS context. This holds if `φ ∈ chain(r)`: then `⊤U(φUψ)` with `φ` holding everywhere on `[r, witness)` gives `φUψ` by MCS closure. The step transfer hypothesis for `backward_until_from_step` requires `(φUψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φUψ) ∈ chain(r)`.

This may be provable: from `F(φUψ) ∈ chain(r)` and `φ ∈ chain(r)`, derive `φUψ ∈ chain(r)`. Use BX5: `(φUψ) → ((φ ∧ (φUψ))Uψ)`. Wait, this goes forward, not backward.

Actually: from `φ ∈ chain(r)` and `F(ψ) ∈ chain(r)` (since `F(φUψ) → F(ψ)` by temporal K on BX10: `G((φUψ) → Fψ)` gives `F(φUψ) → F(ψ)` via `temp_k_dist` + BX10 + temporal necessitation), we need `(φUψ) ∈ chain(r)`. This doesn't directly follow from `φ ∈ chain(r) ∧ F(ψ) ∈ chain(r)` without knowing the witness is ordered correctly.

**Honest assessment**: Path 2's step transfer argument has the same unresolved gap as Plan v8 Phase 4. It is less clean than Path 1.

---

## Creative Alternatives

### Alternative 1: Minimal BFMCS from the Existing Quasimodel Chain (Most Promising)

Instead of building a new `quasimodel_fmcs` from scratch, adapt the existing `QuasimodelChain` from `Construction.lean` directly as the FMCS family. The key insight is:

- `QuasimodelChain` is a finite list of MCS (via Hintikka points realized to BXPoints)
- Extend it to `Int` by constant tails: before the chain, repeat the first point; after, repeat the last
- The constant tails satisfy forward_G/backward_H trivially (constant sequence)
- The finite chain segment satisfies G-propagation within `SubformulaClosure(root)` via `hintikka_step_g_prop`
- Until/Since defects are discharged by `defect_count` reaching 0

This avoids any new quasimodel machinery and directly uses the ~900-line `Construction.lean` infrastructure. The adapter code would be ~100-150 lines:
1. Map `QuasimodelChain` indices to `Int` via offset
2. Define constant past/future tails
3. Prove the 3 restricted coherence properties

This is the most aggressive reuse of existing infrastructure and should be the first concrete attempt.

### Alternative 2: Exploiting the Forward_F Non-Restriction

Notice that `bx_bfmcs_restricted_tc` only requires forward_F for `ψ ∈ deferralClosure(root)`. The current scheduling chain DOES resolve each formula eventually — the problem is proving that an arbitrary F(ψ) with `ψ ∈ deferralClosure(root)` gets resolved within the **restricted** chain.

Key observation: `deferralClosure(root)` is FINITE. The scheduling chain's surjectivity (`schedule_surjective_above`) guarantees that every formula is scheduled infinitely often. For any `ψ ∈ deferralClosure(root)`, there exist infinitely many steps where `schedule(n) = ψ`. At each such step, if `F(ψ) ∈ chain(n)`, the resolving branch puts `ψ ∈ chain(n+1)`.

The gap: between two resolving steps for ψ, `F(ψ)` may be lost (when resolving a different formula). But the restricted version only needs ONE such resolution from any time t onward, not from every time t.

**Proof attempt**: Given `F(ψ) ∈ chain(t)` with `ψ ∈ deferralClosure(root)`, find `s > t` with `ψ ∈ chain(s)`. By surjectivity, there exists `n > t` with `schedule(n) = ψ`. If `F(ψ) ∈ chain(n)`, then `ψ ∈ chain(n+1)` and we're done. If `F(ψ) ∉ chain(n)`, then... we need F(ψ) to have persisted from t to n.

This is the persistence gap. The f_carry mechanism preserves F(ψ) through non-resolving steps (`fwd_succ_f_carry`), but the resolving step for OTHER formulas may drop F(ψ). Specifically, `fwd_succ` in the resolving branch uses seed `forward_temporal_witness_seed M ψ'` for the OTHER formula ψ', and this seed does NOT include `f_carry(M)` explicitly.

**Checking the code**: Looking at `fwd_succ` (lines 74-81):
- Resolving branch (`h_F : F(ψ') ∈ M`): seed = `forward_temporal_witness_seed M ψ'`
- Non-resolving branch: seed = `g_content M ∪ f_carry M`

The resolving branch does NOT include `f_carry M`. So `F(ψ) ∈ f_carry M` is NOT guaranteed to be in `chain(n+1)` when resolving `ψ'`. This confirms the persistence gap is genuine.

**Fix**: Add `f_carry M` to the resolving branch seed too. But then the resolving branch consistency requires `{ψ'} ∪ g_content M ∪ f_carry M` is consistent. Report 07 Finding 2 showed `f_carry M` can be inconsistent with `{ψ'}` when `ψ' = G(¬χ)` and `F(χ) ∈ f_carry M`. This is the exact inconsistency documented in round 10 Teammate C's findings.

**Conclusion**: Alternative 2 faces the same wall. f_carry cannot be added to the resolving branch.

### Alternative 3: Two-Stage Chain (Surprising New Idea)

Build a two-stage construction:
- **Stage 1**: Run the existing scheduling chain (for all of F, producing the existing FMCS)
- **Stage 2**: For each formula `ψ ∈ deferralClosure(root)` that still has unresolved F(ψ), run a SEPARATE targeted chain starting from the current MCS that specifically resolves F(ψ)

The two-stage construction builds a "meta-chain" that first runs the generic scheduling chain, then runs targeted cleanup chains. The final BFMCS families include ALL these chains.

This avoids modifying the resolving branch entirely. The generic chain handles G/H propagation and modal saturation. The targeted cleanup chains handle F-persistence for the specific root.

**Feasibility**: Adding new families to `bx_bfmcs` is straightforward (the families field is a Set). The new families are indexed FMCS chains starting from various points with targeted seeds. Modal coherence is maintained if the new chains share the same Box-formula pattern as M₀.

**Obstacles**: Constructing the targeted cleanup chains and proving they have the right properties is essentially the same problem as the quasimodel FMCS (Alternative 1). This is not genuinely simpler.

**Assessment**: Alternative 3 is interesting but reduces to Alternative 1 (quasimodel BFMCS). It may be easier to state but not to prove.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Identity tail verification (trivial) | HIGH |
| BX12 + quasimodel BFMCS is viable (Path 1) | MEDIUM-HIGH |
| Path 1 estimated at 300-400 lines | MEDIUM |
| Step transfer via BX4' on root-param chain | LOW-MEDIUM |
| No alternative to FMCS/BFMCS construction | HIGH |
| Accepting sorries is strategically wrong | HIGH |
| Literature confirms quasimodel/enrichment as standard approach | HIGH |

**Overall recommendation confidence**: MEDIUM-HIGH. Path 1 (BX12 + quasimodel BFMCS) is the correct path. The main uncertainty is the Hintikka chain to FMCS interface — specifically whether `forward_G` for the FMCS can be proven using only within-Sigma G-propagation from `hintikka_step_g_prop`. This should be verified early in implementation.

---

## Summary for Synthesis

The 10 rounds of research have converged correctly. The mathematical barriers are stable and understood. The two viable paths are:

1. **Path 1** (BX12 + quasimodel BFMCS): Extend deferralClosure, build FMCS from existing QuasimodelChain infrastructure, prove restricted coherence. Estimated 300-400 lines. Main risk: FMCS forward_G proof within restricted Sigma.

2. **Path 2** (root-parameterized chain with BX4' step transfer): Modify scheduling chain, prove step transfer via BX4'. Less clean, same underlying gaps as Plan v8. Estimated 250-350 lines. Main risk: step transfer still blocked.

**The strategic recommendation is clear: implement Path 1. Do not accept sorries. Begin with the identity tail verification and the deferralClosure extension (~20 lines), then proceed to the quasimodel FMCS adapter.**
