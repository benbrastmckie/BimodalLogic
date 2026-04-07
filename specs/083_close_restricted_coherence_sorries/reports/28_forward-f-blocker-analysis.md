# Research Report: Forward-F Blocker Deep Analysis and Path Evaluation

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Type**: Deep technical analysis (solo)
**Session**: sess_1775583197_2ee140
**Artifact**: 28

---

## 0. Executive Summary

The completeness proof for bimodal logic TM is blocked by two leaf sorries: `deterministic_forward_F` and `deterministic_backward_P` (in DeterministicFMCS.lean), or equivalently `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` (in DovetailedChain.lean). All three completeness paths (succ_chain, dovetailed, deterministic) share the same fundamental obstruction.

**Key findings:**

1. `forward_dovetailed_until_persists` is genuinely unprovable in the DovetailedChain -- the X-vs-G mismatch is architectural, not a proof gap. The dovetailed chain uses Lindenbaum extension with g_content seed, but Until persistence requires x_content linkage.

2. The DeterministicChain solves Until persistence (x_content linkage, sorry-free `until_persists_chain`) but introduces a NEW circular dependency: proving forward_F requires backward_G, which requires forward_F.

3. The reflexive semantics switch (Plan v26, Phases 1-3 completed) does NOT resolve the forward_F blocker. It helps with seed consistency but NOT with Until persistence through Lindenbaum detours.

4. Plan v26 Phase 4 has a critical gap: the F_until_equiv axiom becomes unsound under mixed semantics (reflexive G/H with strict U/S), and Until persistence still breaks through Lindenbaum detours.

5. Rerouting completeness through DeterministicFMCS is possible but requires closing `deterministic_forward_F`, which has the same circularity.

6. The recommended path forward is the finite deferral cycle contradiction in FiniteDeferral.lean, working within the deterministic chain.

---

## 1. Analysis of `forward_dovetailed_until_persists`

### 1.1 Why It Is Genuinely Unprovable

The theorem states: if `(top U psi) in chain(n)` and `psi not in chain(n)`, then `(top U psi) in chain(n+1)`.

**The construction**: The dovetailed forward chain builds `chain(n+1)` via Lindenbaum extension of `{target} ∪ temporal_box_g_seed(chain(n))`. The resulting MCS contains g_content(chain(n)) as a subset.

**The gap**: `until_unfold` gives `X(psi ∨ (top ∧ (top U psi))) ∈ chain(n)`, so `psi ∨ (top ∧ (top U psi)) ∈ x_content(chain(n))`. But `chain(n+1) ⊇ g_content(chain(n))`, NOT `x_content(chain(n))`.

For `(top U psi)` to be in g_content(chain(n)), we would need `G(top U psi) ∈ chain(n)`. But `(top U psi) → G(top U psi)` is NOT derivable -- Until is existential while G is universal.

**Attempted workarounds (all fail)**:
- Modify forward_step to use x_content base: chain becomes deterministic, loses F-resolution capability
- Add Until formulas to Lindenbaum seed: consistency proof fails (Until deferrals are X-liftable but NOT G-liftable)
- Use until_induction instantiation: premise `G(psi -> top U psi)` underivable
- Prove F-persistence instead: `F(psi) = neg(G(neg(psi)))` not preserved through Lindenbaum extensions

**Verdict**: The sorry is NOT a proof gap -- it reflects a genuine architectural limitation of the dovetailed chain. The construction cannot propagate Until formulas.

### 1.2 Impact on Completeness

`DovetailedFMCS_forward_F` (line 1297) and `DovetailedFMCS_backward_P` (line 1305) both depend transitively on `forward_dovetailed_until_persists`. The current `completeness_over_Int` (Completeness.lean:473) delegates to `dovetailed_bundle_validity_implies_provability`, which calls `DovetailedFMCS_forward_F`.

**DovetailedChain.lean sorry count**: 6 direct sorries (lines 650, 1018, 1114, 1127, 1300, 1308), all from the same Until persistence issue.

---

## 2. State of DeterministicFMCS.lean

### 2.1 Architecture

The deterministic chain uses `chain(n+1) = x_content(chain(n))` and `chain(-(n+1)) = y_content(chain(-n))`. This gives:
- `phi ∈ chain(n+1) iff X(phi) ∈ chain(n)` (exact x_content linkage)
- Sorry-free Until persistence (`until_persists_chain`, DeterministicChain.lean:244)
- Sorry-free Since persistence (symmetric)
- Sorry-free G/H coherence (`forward_G_int`, `backward_H_int`)
- Sorry-free backward Until/Since introduction via `until_intro`/`since_intro` + induction

### 2.2 Sorry Inventory

| Theorem | Location | Status |
|---------|----------|--------|
| `deterministic_forward_F` | DeterministicFMCS.lean:64 | SORRY (leaf) |
| `deterministic_backward_P` | DeterministicFMCS.lean:71 | SORRY (leaf) |
| `usc` forward Until | DeterministicFMCS.lean:483 | SORRY (depends on forward_F) |
| `usc` forward Since | DeterministicFMCS.lean:495 | SORRY (depends on backward_P) |

All other infrastructure is sorry-free: FMCS construction, BFMCS bundle, modal coherence, temporal coherence (conditioned on forward_F/backward_P), backward Until/Since, and the completeness wiring through `deterministic_representation`.

### 2.3 The Forward_F Circularity

To prove `deterministic_forward_F`: if `F(psi) ∈ chain(t)` then `∃ s > t, psi ∈ chain(s)`.

**Proof attempt**: Assume psi never appears. Then `neg(psi) ∈ chain(s)` for all `s > t`. We want `G(neg(psi)) ∈ chain(t)`, which combined with `G_neg_kills_until` contradicts `(top U psi) ∈ chain(t)`.

**The gap**: To derive `G(neg(psi)) ∈ chain(t)` from "neg(psi) at all future positions", we use `temporal_backward_G_with_fwd_F` (TemporalCoherence.lean:213). But this requires `forward_F(neg(neg(psi)))` as a hypothesis -- exactly what we are trying to prove. The circularity is genuine.

**Well-founded induction attempt**: The formula sizes increase through the dependency chain: sizeof(neg(neg(psi))) = sizeof(psi) + 4 > sizeof(psi). This prevents a direct well-founded induction on formula complexity.

---

## 3. FiniteDeferral.lean: The Closest Approach

### 3.1 Sorry-Free Infrastructure

FiniteDeferral.lean has substantial sorry-free infrastructure:
- `F_to_until_in_chain`: `F(psi) → (top U psi)` in the chain (line 52)
- `until_persists_chain_general`: Until persistence for general integer positions (line 63)
- `until_persists_forward_steps`: `(top U psi)` persists for n steps if psi absent (line 83)
- `pigeonhole_restricted_theories`: restricted theories must cycle within `2^|deferralClosure|` steps (line 133)
- `G_neg_kills_until`: `G(neg(psi)) ∈ chain(t)` contradicts `(top U psi) ∈ chain(t)` (line 164)

### 3.2 The Gap: Cycle Contradiction

The single remaining sorry is `forward_F_via_deferral` (line 378). The gap is at the final step: deriving a contradiction from the restricted theory cycle.

Given: positions `i < j` where `restrictedTheory(t+i) = restrictedTheory(t+j)`, with `(top U psi)` persisting and psi never appearing.

**The standard argument** requires `G(neg(psi)) ∈ chain(t)`, which needs backward G, which needs forward_F (circular).

**The cycle-based argument** (described in report 24 Section 4.7) proposes building a RESTRICTED model from the cycle and deriving a semantic contradiction. This avoids backward_G by constructing temporal coherence directly from the periodic structure.

### 3.3 Why the Cycle Approach May Work

The restricted model built from the period-k cycle has:
- Finitely many states (at most 2^|deferralClosure|)
- Deterministic x_content linkage (inherited from the chain)
- All MCS properties within the deferralClosure
- `(top U psi)` at every position
- psi at NO position

In this restricted model, `(top U psi)` is semantically false everywhere (since psi is never satisfied in the future). If we can show that `(top U psi)` being in every chain position contradicts it being semantically false in the restricted model, we have our contradiction.

The key requirement: a restricted truth lemma that works for the periodic model WITHOUT requiring full forward_F. Since the model is finite and periodic, restricted forward_F for formulas in the deferralClosure can potentially be established independently (every F-obligation either resolves within one period or creates a contradiction).

---

## 4. Completeness Rerouting Analysis

### 4.1 Current Path

```
completeness_over_Int (Completeness.lean:473)
  → dovetailed_bundle_validity_implies_provability (Completeness.lean:431)
    → dovetailed_bfmcs_restricted_temporally_coherent (Completeness.lean:402)
      → DovetailedFMCS_forward_F (DovetailedChain.lean:1297) ← SORRY
      → DovetailedFMCS_backward_P (DovetailedChain.lean:1305) ← SORRY
```

### 4.2 DeterministicFMCS Path (Available but Not Wired)

```
deterministic_representation (DeterministicFMCS.lean:524)
  → parametric_algebraic_representation_conditional (sorry-free)
    → construct_bfmcs_callback (DeterministicFMCS.lean:511)
      → tc (DeterministicFMCS.lean:458) → deterministic_forward_F ← SORRY
      → usc (DeterministicFMCS.lean:477) → deterministic_forward_F ← SORRY
```

### 4.3 Can Completeness Be Rerouted?

Yes, `completeness_over_Int` could be rerouted through DeterministicFMCS by:
1. Replace `dovetailed_bundle_validity_implies_provability` with a call to `deterministic_representation`
2. The `deterministic_representation` function already provides a countermodel for non-provable formulas
3. The wiring is structurally complete -- it only needs `deterministic_forward_F` and `deterministic_backward_P` to be closed

**Advantage of rerouting**: The deterministic chain has sorry-free Until persistence, sorry-free G/H coherence, and substantial FiniteDeferral.lean infrastructure. All sorry weight concentrates on the two leaf sorries.

**Cost**: Minimal -- the `deterministic_representation` function already exists and is fully wired.

### 4.4 UltrafilterChain Path (Oldest, Also Sorry'd)

```
bundle_validity_implies_provability (Completeness.lean, older path)
  → bfmcs_restricted_temporally_coherent (Completeness.lean:248)
    → succ_chain_restricted_forward_F ← SORRY
    → succ_chain_restricted_backward_P ← SORRY
```

This path has additional sorry complexity because SuccChainFMCS uses a different chain construction (not pure x_content). Not recommended.

---

## 5. Plan v26 Phase 4 Assessment

### 5.1 The Approach

Phase 4 proposes: close `succ_chain_restricted_forward_F` using seed consistency + Lindenbaum detour. Given `F(psi) ∈ chain(n)`, construct chain(n+1) via Lindenbaum extension of `{psi} ∪ g_content(chain(n))`.

### 5.2 Seed Consistency: Valid

Under reflexive semantics with T-axiom:
- `F(psi) ∈ M` means `G(neg(psi)) ∉ M` (by MCS)
- So `neg(psi) ∉ g_content(M)` (since g_content(M) = {phi | G(phi) ∈ M})
- Therefore `{psi} ∪ g_content(M)` does not contain both psi and neg(psi)

The consistency proof needs to show that no derivation from g_content(M) proves neg(psi), which follows from the G-lift argument: if g_content(M) ⊢ neg(psi), then G(neg(psi)) ∈ M (by temporal necessitation on the derivation and the fact that G distributes over conjunction), contradicting F(psi) ∈ M.

### 5.3 Until Persistence Through Detour: FAILS

If the chain takes a Lindenbaum detour at step n (chain(n+1) = Lindenbaum({psi} ∪ g_content(chain(n))) instead of x_content(chain(n))):

1. `(top U chi) ∈ chain(n)` gives `X(chi ∨ (top ∧ (top U chi))) ∈ chain(n)`
2. So `chi ∨ (top ∧ (top U chi)) ∈ x_content(chain(n))`
3. But `chain(n+1) ⊇ g_content(chain(n))`, NOT `x_content(chain(n))`
4. `(top U chi)` would need `G(top U chi) ∈ chain(n)`, which is not derivable

**This is the SAME X-vs-G mismatch as the DovetailedChain.**

### 5.4 F_until_equiv Unsoundness

Under mixed semantics (reflexive G/H, strict U/S):
- `F(psi)` = `neg(G(neg(psi)))` means psi at some s >= t (includes present)
- `(top U psi)` means psi at some s > t (strict future only)
- So `F(psi) → (top U psi)` is FALSE when the F-witness is t itself

The axiom `F_until_equiv` becomes unsound. This breaks many existing proofs that rely on converting between F and Until.

### 5.5 Assessment

Phase 4 as currently specified will NOT work:
- Until persistence breaks through Lindenbaum detours (same problem as DovetailedChain)
- F_until_equiv unsoundness creates cascading issues throughout the proof

---

## 6. Recommendations

### 6.1 Recommended Path: Finite Deferral on Deterministic Chain

**Target**: Close `deterministic_forward_F` and `deterministic_backward_P` in DeterministicFMCS.lean via the finite deferral cycle contradiction.

**Why this is the best path**:
1. The deterministic chain has sorry-free Until persistence (x_content linkage)
2. FiniteDeferral.lean provides substantial infrastructure (pigeonhole, Until persistence for n steps, G_neg_kills_until)
3. The completeness wiring through `deterministic_representation` already exists
4. Only the cycle contradiction step needs to be formalized
5. Does NOT require the reflexive semantics switch (avoids F_until_equiv unsoundness)

**The cycle contradiction approach** (from Report 24 Section 4.7):
1. Assume F(psi) in chain(t), psi never appears
2. (top U psi) persists forever via `until_persists_forward_steps` (sorry-free)
3. Pigeonhole gives cycle: positions i < j with same restricted theory
4. Build a periodic restricted model from the cycle
5. Show the restricted model satisfies a restricted truth lemma for formulas in deferralClosure(psi)
6. In the restricted model, psi is never true, so (top U psi) is semantically false
7. But (top U psi) is in the restricted theory at every position
8. By the restricted truth lemma, (top U psi) should be semantically true -- contradiction

**Key new work needed**: Step 5 (restricted truth lemma for the periodic model). The critical sub-problem is proving restricted forward_F for the periodic model. In a finite periodic model, every F-obligation for a formula chi in deferralClosure(psi) either:
- Resolves within one period (chi appears somewhere in the cycle)
- Never resolves (chi never appears)

For the second case, we can apply the SAME finite deferral argument recursively on chi. Since deferralClosure(psi) is finite, this recursion terminates.

**Estimated effort**: 600-900 lines of new Lean 4 code.

### 6.2 Alternative: Revert Reflexive Semantics, Work Purely in Deterministic Chain

If the reflexive semantics switch creates too many cascading issues (F_until_equiv unsoundness, derived theorem breakage), consider:

1. Revert Phases 1-3 of Plan v26 (return to strict semantics)
2. Focus entirely on closing `deterministic_forward_F` via finite deferral
3. Reroute `completeness_over_Int` through `deterministic_representation`

This avoids all the reflexive semantics complications while targeting the same fundamental problem.

### 6.3 What NOT to Do

- Do NOT continue with Plan v26 Phase 4 as specified (Lindenbaum detour approach). Until persistence breaks through detours regardless of reflexive/strict semantics.
- Do NOT try to fix the DovetailedChain. Its architecture (g_content seed) is fundamentally incompatible with Until propagation.
- Do NOT attempt well-founded induction on formula complexity for forward_F. The formula sizes increase through the dependency chain.
- Do NOT introduce new axioms or modify the proof system to work around the gap.

---

## 7. Key Type Signatures and Locations

### Leaf Sorries (Deterministic Path)

```lean
-- DeterministicFMCS.lean:64
theorem deterministic_forward_F (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_F : Formula.some_future psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ psi ∈ deterministic_chain M₀ s

-- DeterministicFMCS.lean:71
theorem deterministic_backward_P (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_P : Formula.some_past psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, s < t ∧ psi ∈ deterministic_chain M₀ s
```

### Leaf Sorries (Dovetailed Path)

```lean
-- DovetailedChain.lean:1297
theorem DovetailedFMCS_forward_F (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (t : Int) (psi : Formula) (h_F : Formula.some_future psi ∈ (DovetailedFMCS M_0 h_mcs_0).mcs t) :
    ∃ s : Int, t < s ∧ psi ∈ (DovetailedFMCS M_0 h_mcs_0).mcs s

-- DovetailedChain.lean:1305
theorem DovetailedFMCS_backward_P (M_0 : Set Formula) (h_mcs_0 : SetMaximalConsistent M_0)
    (t : Int) (psi : Formula) (h_P : Formula.some_past psi ∈ (DovetailedFMCS M_0 h_mcs_0).mcs t) :
    ∃ s : Int, s < t ∧ psi ∈ (DovetailedFMCS M_0 h_mcs_0).mcs s
```

### Sorry-Free Infrastructure (FiniteDeferral)

```lean
-- FiniteDeferral.lean:52
theorem F_to_until_in_chain (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (h_F : Formula.some_future ψ ∈ deterministic_chain M₀ t) :
    Formula.untl (Formula.neg Formula.bot) ψ ∈ deterministic_chain M₀ t

-- FiniteDeferral.lean:83
theorem until_persists_forward_steps (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (n : ℕ)
    (h_U : Formula.untl (Formula.neg Formula.bot) ψ ∈ deterministic_chain M₀ t)
    (h_no_psi : ∀ i : ℕ, 1 ≤ i → i ≤ n → ψ ∉ deterministic_chain M₀ (t + ↑i)) :
    Formula.untl (Formula.neg Formula.bot) ψ ∈ deterministic_chain M₀ (t + ↑n)

-- FiniteDeferral.lean:133
theorem pigeonhole_restricted_theories (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (root : Formula) (t : ℤ) :
    let bound := 2 ^ (deferralClosure root).card
    ∃ i j : ℕ, i < j ∧ j ≤ bound ∧
      restrictedTheory M₀ root (t + ↑i) = restrictedTheory M₀ root (t + ↑j)

-- FiniteDeferral.lean:164
theorem G_neg_kills_until (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula)
    (h_G_neg : Formula.all_future (Formula.neg ψ) ∈ deterministic_chain M₀ t) :
    Formula.untl (Formula.neg Formula.bot) ψ ∉ deterministic_chain M₀ t
```

### Completeness Wiring (Deterministic Path)

```lean
-- DeterministicFMCS.lean:524
noncomputable def deterministic_representation {φ : Formula}
    (h_not_prov : ¬Nonempty ([] ⊢ φ)) :=
  parametric_algebraic_representation_conditional φ h_not_prov construct_bfmcs_callback
```

---

## 8. File Location Summary

| File | Role | Sorry Count |
|------|------|-------------|
| `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean` | Chain construction, x_content linkage | 0 |
| `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` | FMCS/BFMCS from deterministic chain | 4 (2 leaf + 2 derived) |
| `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` | DEPRECATED chain with g_content seed | 6 |
| `Theories/Bimodal/Metalogic/Algebraic/FiniteDeferral.lean` | Cycle contradiction infrastructure | 1 |
| `Theories/Bimodal/FrameConditions/Completeness.lean` | Completeness theorem wiring | 0 (delegates) |
| `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` | x_content, g_content definitions | 0 |
| `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` | temporal_backward_G_with_fwd_F | 0 |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` | Conditional truth lemma | 0 |

---

## 9. Conclusion

The forward_F blocker is a genuine mathematical challenge, not a simple proof gap. Twenty-four prior research reports have established that the standard approaches (quasimodel, filtration, well-founded induction, enriched seeds) all fail for TM with strict Until semantics. The reflexive semantics switch (Plan v26 Phases 1-3) resolves seed consistency but not Until persistence through detours, and introduces F_until_equiv unsoundness.

The most promising remaining approach is the finite deferral cycle contradiction on the deterministic chain, using the existing infrastructure in FiniteDeferral.lean. This requires building a restricted truth lemma for the periodic model that avoids the backward-G circularity. The completeness path should be rerouted through `deterministic_representation` in DeterministicFMCS.lean.

Estimated remaining effort: 600-900 lines of new Lean 4 code for the cycle contradiction + restricted periodic model, plus minor wiring changes in Completeness.lean.
