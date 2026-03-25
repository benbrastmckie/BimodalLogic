# Teammate C: New Approach Design

**Task**: 64 - Critical Path Review
**Date**: 2026-03-25
**Role**: Design new approach avoiding known dead ends

---

## Key Findings

### 1. The Landscape Has Narrowed Significantly

After reading all 9 research reports (task 58 + task 64), the situation is cleaner than it might appear:

- There are exactly **3 sorry-producing blockers** in SuccChainFMCS.lean (lines 1435, 1480, 1543)
- All three are in the **Strategy C (restricted chain)** code path
- All three relate to the same root cause: **proving that `constrained_successor_seed_restricted` is consistent**
- The alternative path — **Strategy A (ultrafilter F-witness with direct Int-indexed chain)** — has **none of its required infrastructure implemented yet** beyond the MCS-level witness theorems

### 2. The Two Real Options

The research has fully explored two options and ruled out a third:

**Strategy A (Ultrafilter Int-chain)**: Use `temporal_theory_witness_exists` (sorry-free F-witness at MCS level) and `past_theory_witness_exists` (sorry-free P-witness) to build a direct Int-indexed chain. Temporal coherence follows **by construction** — at each step, the witness was chosen to satisfy the F/P obligation. No nesting bound needed.

**Strategy C (Restricted chain dovetailing)**: Use the sorry-free `restricted_forward_chain_forward_F` and build a symmetric backward chain, then dovetail them into an FMCS over ℤ. F-nesting IS bounded within `deferralClosure`, so termination proofs hold. But 3 sorries block the current construction.

**Strategy B (Temporal shift automorphism τ)**: Proven impossible — G is deflationary and non-invertible, so there is no global algebraic shift. Definitively ruled out.

### 3. The Real Obstacle in Strategy C

The 3 sorries in Strategy C are NOT symmetric — they are all in the **Phase 3 consistency proof** for `constrained_successor_seed_restricted`. The issue:

The seed contains `boundary_resolution_set phi u` elements (formulas `psi` where `F(psi) ∈ u`). The consistency argument needs to show these don't create contradictions with `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted`.

The `neg_not_in_boundary_resolution_set` theorem (line 1412) has a sorry with a comment: **"The lemma may not be provable."** This is the mathematical root of the 3 sorries.

### 4. The Core Insight Being Missed

Here is what ALL prior research missed: **the `boundary_resolution_set` may not be needed at all**.

The proof goal is:
```
restricted_bounded_witness phi u : some chi is in some future restricted chain element
```

The existing `restricted_forward_chain_forward_F` already proves forward F-coherence for the FULL forward chain. The issue is only that `boxClassFamilies_temporally_coherent` needs an FMCS over ℤ (both directions), not just a forward Nat-indexed chain.

The `boundary_resolution_set` was introduced to enable forward chain steps to "resolve" pending F-obligations from the boundary. But `restricted_forward_chain_forward_F` does NOT need it — it uses a different construction path that terminates by the finiteness of `deferralClosure`.

---

## Failed Approach Analysis

### Strategy C (Restricted Chain + σ-Duality)

**Why it failed**: The `boundary_resolution_set` concept was added to ensure each forward step resolves at least one "boundary" F-obligation. The consistency proof requires showing `F(psi) ∈ u → psi.neg ∉ boundary_resolution_set phi u`. But `psi.neg` can be in `boundary_resolution_set` if `F(psi.neg) ∈ u` — and there is nothing preventing `F(psi)` and `F(psi.neg)` from both being in `u`.

**What to avoid**: The `boundary_resolution_set` definition and the `constrained_successor_seed_restricted` construction. These are the wrong level of abstraction.

### Strategy A (F-witness MCS chain → boxClassFamilies)

**Why it failed**: The existing `temporal_theory_witness_exists` gives MCS-level witnesses that are in the SAME BOX CLASS but NOT necessarily in the same FMCS chain. `boxClassFamilies` bundles ALL shifted SuccChainFMCS from all MCSes in the same box class. For temporal coherence, F(psi) at time t in family fam needs a witness at time s > t IN THE SAME FAMILY fam. MCS-level witnesses may land in different families.

**What to avoid**: Trying to prove `boxClassFamilies_temporally_coherent` — the entire `boxClassFamilies` + `SuccChainFMCS` combo cannot be made temporally coherent without either bounded F-nesting or per-family witness tracking.

### The "Per-Obligation" approach (Phase 1 from current plan)

**Why it's blocked**: Depends on `boundary_resolution_set` consistency (lines 1480, 1543). The approach tries to ensure each step "advances" F-obligations, but the measurement of "progress" breaks down when formulas and their negations are both future-obligated.

---

## Proposed New Approach

### Architecture: Direct Int-Chain from MCS Witnesses (Strategy A, Properly Implemented)

**Core idea**: Bypass `boxClassFamilies` entirely. Build a single FMCS over ℤ directly from a starting MCS using iterated F/P witnesses. Temporal coherence holds **by construction** because each chain step was chosen to satisfy the F/P obligation at that position.

This is what "Strategy A" SHOULD have been — not an ultrafilter-level construction, but a direct MCS-level construction using the already-proven sorry-free witness theorems.

### Key Steps

#### Step 1: Define the Int-indexed chain structure

```lean
structure DirectMCSChain where
  chain : Int → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (chain t)
  box_agree : ∀ t s, box_class_agree (chain t) (chain s)
  forward_witness : ∀ t phi, Formula.some_future phi ∈ chain t →
                              phi ∈ chain (t + 1)
  backward_witness : ∀ t phi, Formula.some_past phi ∈ chain t →
                               phi ∈ chain (t - 1)
```

This is STRONGER than needed (phi at exactly t+1, not just some s > t) but achievable with the existing witness theorems.

#### Step 2: Build forward half using `temporal_theory_witness_exists`

For each n : ℕ, define `chain_forward : ℕ → Set Formula` by:
- `chain_forward 0 = M₀` (the starting MCS with phi.neg)
- `chain_forward (n+1) = W` where W is obtained from `temporal_theory_witness_exists` applied to a **canonical witness** for chain_forward(n)

The challenge: `temporal_theory_witness_exists` gives existence but is not canonical (noncomputable choice). We need to pick ONE witness that satisfies ALL F-obligations at step n, not just one.

**Critical insight**: We don't need to resolve ALL F-obligations in one step. We only need eventual resolution. The F-witness at step n can be chosen to resolve ANY one F-obligation (using Lindenbaum from the union of ALL F-seeds simultaneously).

**Revised seed for step n+1**:
```
all_future_seed(M) = {phi | F(phi) ∈ M}  -- ALL F-obligations together
W_seed = {phi | F(phi) ∈ M} ∪ temporal_box_seed(M)
```

**Consistency of W_seed**: If F(phi₁) ∧ F(phi₂) ∧ ... are all in M, is `{phi₁, phi₂, ...} ∪ temporal_box_seed(M)` consistent?

Answer: **YES**. This follows from the seriality axiom `F⊤ ∈ M` and the TM axiom system. Specifically:
- `F(phi₁ ∧ phi₂) ← F(phi₁) ∧ G(phi₁ → H(phi₁)) ∧ F(phi₂)` — NO, this doesn't work directly.

**Better approach**: Don't resolve ALL obligations at once. Instead:

Use `temporal_theory_witness_exists` to get the G-theory-agreeing MCS W. This W satisfies:
- `phi ∈ W` (target formula)
- G-theory of M is preserved in W
- box_class_agree(M, W)

But W may NOT satisfy other F-obligations of M. The key is that W itself is an MCS, and IF F(psi) ∈ M and G(psi) ∉ M (i.e., psi is not already inevitable), then in W we have either psi ∈ W or F(psi) ∈ W (because psi ∨ F(psi) ∈ W from deferral).

Actually, the CORRECT insight is:

#### Step 2 (Revised): Use the existing `restricted_forward_chain` directly

The `restricted_forward_chain_forward_F` theorem (SuccChainFMCS.lean:2488) is **already sorry-free** and proves forward F-coherence. We have:

```lean
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m
```

This is exactly the forward_F coherence we need! The chain exists and works for the COMPLETENESS PROOF because:

1. Completeness only requires: "if phi is not provable, build a model falsifying phi"
2. We build phi-specific restricted chains where F-nesting IS bounded
3. The forward half is already done (sorry-free)
4. We need the backward half (P-direction)

#### Step 3: Build backward half symmetrically — WITHOUT `constrained_successor_seed_restricted`

The 3 sorries are all in the Strategy C **forward chain's Phase 3** (the seed consistency proof for `constrained_successor_seed_restricted`). But `restricted_forward_chain_forward_F` does NOT use these sorried theorems!

Let me verify: `restricted_forward_chain_forward_F` calls `restricted_forward_chain_iter_F_witness` (line 2412), which calls `restricted_forward_chain_F_step_witness` (line 2239), which calls `restricted_forward_chain_succ` (line 2153), which calls `constrained_successor_restricted` (line 1554).

I need to check if `constrained_successor_restricted` uses the sorried theorems...

Actually, looking at the sorry locations: lines 1435, 1480, 1543 are in Phase 3 theorems (`neg_not_in_boundary_resolution_set`, `augmented_seed_consistent`, `constrained_successor_seed_restricted_consistent`). The `constrained_successor_restricted` (Phase 4) likely DEPENDS on these.

**This is the critical question**: Does `restricted_forward_chain_forward_F` actually USE any of the 3 sorry theorems, or does it go through a different code path?

#### Step 4: If forward chain is sorry-free, build a minimal backward chain

The **minimal backward chain** for completeness purposes:

Since we only need the EXISTENCE of a countermodel for phi (not phi), and the truth lemma works backward through time, we need P-coherence: if P(psi) ∈ chain(t), then psi ∈ chain(s) for some s < t.

The `past_theory_witness_exists` (line 1380) gives a P-witness at MCS level. We can use this to build a backward chain in the same way `restricted_forward_chain` uses `temporal_theory_witness_exists`.

**The backward chain seed** (symmetric to forward):
```
past_temporal_box_seed(M) = H_theory(M) ∪ box_theory(M)
predecessor_seed(M, phi_P) = {phi_P} ∪ past_temporal_box_seed(M)
```

This is consistent by `past_theory_witness_consistent` (line ~1320) when P(phi_P) ∈ M.

But does the backward chain need to stay within `deferralClosure`? For the COMPLETENESS PROOF — only for the formula phi we're proving — we can use `deferralClosure(phi)` which includes BOTH future and past deferral disjunctions (as confirmed by research report 02).

### Why This Avoids Known Dead Ends

| Dead End | How Avoided |
|----------|-------------|
| `f_nesting_is_bounded` (FALSE for arbitrary MCS) | We work within `deferralClosure(phi)` where nesting IS bounded (sorry-free theorem) |
| `boundary_resolution_set` consistency (sorried) | BYPASS the entire `boundary_resolution_set` / `constrained_successor_seed_restricted` apparatus entirely |
| `boxClassFamilies_temporally_coherent` (sorry) | Don't use `boxClassFamilies` at all — build a single FMCS directly |
| `τ global shift automorphism` (impossible) | Not used — we build chains step by step |
| `neg_not_in_boundary_resolution_set` (unprovable) | Bypassed by abandoning `boundary_resolution_set` |

### The Concrete Proposal: Lean Past `constrained_successor_seed_restricted`

**Investigation needed**: Verify whether `restricted_forward_chain_forward_F` calls through the sorried theorems or uses a different code path.

If `restricted_forward_chain_forward_F` is truly sorry-free (which is asserted in the file), then the path forward is:

1. **Build `restricted_backward_chain`** using the SAME architecture as `restricted_forward_chain` but with:
   - `past_theory_witness_consistent` instead of `temporal_theory_witness_consistent`
   - `past_temporal_box_seed` instead of `temporal_box_seed`
   - `p_nesting_is_bounded_restricted` (sorry-free) for termination
   - Use `predecessor_from_deferral_seed` structure from SuccExistence.lean

2. **Prove `restricted_backward_chain_backward_P`** (symmetric to `restricted_forward_chain_forward_F`)

3. **Dovetail into FMCS over ℤ**:
   ```lean
   noncomputable def restricted_succ_chain_fam (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) : Int → Set Formula
     | .ofNat n => restricted_forward_chain phi M0 n
     | .negSucc n => restricted_backward_chain phi M0 (n + 1)
   ```

4. **Prove temporal coherence** of the combined chain:
   - forward_F: delegate to `restricted_forward_chain_forward_F`
   - backward_P: delegate to `restricted_backward_chain_backward_P`

5. **Convert to FMCS and BFMCS**:
   ```lean
   noncomputable def restricted_chain_to_fmcs (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) : FMCS Int
   ```
   Using `DeferralRestrictedSerialMCS.toSerialMCS` to coerce each chain element to a full MCS.

6. **New `construct_bfmcs_restricted`**:
   ```lean
   noncomputable def construct_bfmcs_restricted (phi : Formula)
       (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
       Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
          (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
          M = fam.mcs t
   ```
   This is phi-specific but sufficient for completeness.

7. **Wire to `parametric_algebraic_representation_conditional`**

### Risk Analysis

**Risk 1 (HIGH)**: `restricted_forward_chain_forward_F` may secretly depend on the sorried theorems through the call chain. **Mitigation**: Verify with `#print axioms restricted_forward_chain_forward_F` before implementing the backward chain. If it has sorries, we need a completely fresh approach.

**Risk 2 (MEDIUM)**: The backward chain termination may require a different well-founded relation than the forward chain. **Mitigation**: `p_nesting_is_bounded_restricted` is already proven; the termination argument should mirror the forward case exactly.

**Risk 3 (MEDIUM)**: The dovetailing join point (position 0) may not satisfy both F-coherence (delegated to forward) and P-coherence (delegated to backward) simultaneously. **Mitigation**: Both chains start from M₀ at position 0 and they are indexed separately — there's no actual conflict at position 0.

**Risk 4 (LOW)**: `DeferralRestrictedSerialMCS.toSerialMCS` conversion may lose properties needed for the FMCS structure. **Mitigation**: The conversion extends to a FULL MCS via Lindenbaum, which is a superset. The restricted chain membership `psi ∈ restricted_chain(n)` transfers to the extension since chain elements are WITHIN `deferralClosure` and the extension is maximal.

**Risk 5 (LOW)**: Phi-specific BFMCS vs parametric-D BFMCS type mismatch. **Mitigation**: `parametric_algebraic_representation_conditional` takes a FUNCTION `construct_bfmcs`, not a fixed phi. We pass a function that ignores phi and just uses M₀ (which comes from Lindenbaum extension of {phi.neg}).

---

## Alternative Proposals

### Alternative A: Completely Fresh Direct MCS Chain (No Restricted MCS)

Abandon both `restricted_forward_chain` and `constrained_successor_seed_restricted`. Build a fresh Int-indexed chain using ONLY the minimal sorry-free machinery:

- Start with M₀ (MCS with phi.neg)
- Forward: iterate `temporal_theory_witness_exists` targeting ALL F-obligations simultaneously via the union seed `{psi | F(psi) ∈ M} ∪ temporal_box_seed(M)`
- Backward: iterate `past_theory_witness_exists` symmetrically

**Temporal coherence proof**: By construction — at step n+1, we have ALL formulas psi where F(psi) ∈ chain(n) are IN chain(n+1) (because we used the union seed). This is NOT bounded F-nesting — it's direct resolution.

**Challenge**: The union seed consistency. Is `{psi₁, psi₂, ..., psik} ∪ temporal_box_seed(M)` consistent when F(psi₁), ..., F(psiK) ∈ M?

**Proof**: By induction on k. For k=1, this is `temporal_theory_witness_consistent`. For k>1, use the fact that if F(psi₁), ..., F(psiK) ∈ M and G(psi₁), ..., G(psiK) ∉ M (otherwise psi would already be in M), then by MCS properties we can show the combined seed is consistent.

Actually this might be tricky for k > 1 because we need F(psi₁ ∧ psi₂) ∈ M, which doesn't follow from F(psi₁) ∈ M and F(psi₂) ∈ M separately.

**Verdict**: Promising but requires new mathematical work to prove union seed consistency. NOT the easy path.

### Alternative B: Fix the 3 Existing Sorries Directly

Re-examine whether `neg_not_in_boundary_resolution_set` is truly unprovable or just hard to prove with the CURRENT definition of `boundary_resolution_set`.

The comment at line 1434 says "The lemma may not be provable." But the reason given is about `chi.neg` in `boundary_resolution_set` requiring `F(chi.neg) ∈ u`. If BOTH `F(chi)` and `F(chi.neg)` can be in `u`...

Wait — can both `F(chi)` and `F(chi.neg) = neg(G(chi))` be in a consistent MCS? That would require both `neg(G(neg chi))` and `neg(G(chi))` in M, i.e., both `G(chi)` and `G(neg chi)` NOT in M. This is perfectly consistent (G(chi) doesn't need to be in M when F(chi) ∈ M).

So YES, the lemma is unprovable as stated. The `boundary_resolution_set` architecture is fundamentally broken because `chi` and `chi.neg` can both be in it.

**Verdict**: NOT viable. The sorry is correct that the lemma is unprovable.

### Alternative C: Prove Completeness Without Full BFMCS

The `parametric_algebraic_representation_conditional` requires a full BFMCS. But what if we directly prove completeness at a lower level?

Looking at `parametric_algebraic_representation_relative` (ParametricRepresentation.lean:184):
```lean
theorem parametric_algebraic_representation_relative
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (phi : Formula) (h_not_prov : ¬Nonempty (DerivationTree [] phi))
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : phi.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) ...
```

We need a BFMCS. But actually we only need:
1. A single FMCS (the `fam`) with `phi.neg` in it somewhere
2. A BFMCS wrapper around that FMCS (which is trivial: just a bundle with one family)
3. Proof that the single-family bundle is temporally coherent (= forward_F + backward_P for our one family)

The "trivial bundle" approach: define a BFMCS with exactly ONE family — our restricted chain FMCS. Temporal coherence for this single family is exactly what `restricted_forward_chain_forward_F` + `restricted_backward_chain_backward_P` provides.

**This is essentially the same as the main proposal but stated differently**: a singleton BFMCS {our-chain} that is trivially modally coherent (no inter-family relations to check) and temporally coherent by our chain construction.

---

## Effort Estimate

### Primary Approach (restricted forward chain + new backward chain)

| Phase | Description | Lines | Confidence |
|-------|-------------|-------|------------|
| 0 | Verify `restricted_forward_chain_forward_F` has no sorries | 0 (just `#print axioms`) | Required |
| 1 | Implement `restricted_backward_chain` (symmetric to forward) | ~200 | High |
| 2 | Prove `restricted_backward_chain_backward_P` | ~200 | High |
| 3 | Dovetail into Int-indexed `restricted_succ_chain_fam` | ~100 | High |
| 4 | Build `restricted_chain_to_fmcs` + temporal coherence | ~100 | High |
| 5 | `construct_bfmcs_restricted` + wire to completeness | ~150 | High |
| **Total** | | **~750** | **Medium-High** |

Estimated calendar time: **6-10 hours** (mostly mechanical, symmetric to existing code)

### If forward chain has sorries (contingency)

If `#print axioms restricted_forward_chain_forward_F` shows sorries, then we must pivot to Alternative A (fresh direct MCS chain) which requires:
- Proving union seed consistency (~100 lines new math)
- Building the direct Int-chain (~300 lines)
- Temporal coherence (~150 lines)
- Estimated: **10-15 hours** at higher difficulty

---

## Confidence Level

**PRIMARY APPROACH**: MEDIUM-HIGH

**Why high**: The backward chain construction is genuinely symmetric to the forward chain. `p_nesting_is_bounded_restricted` is already proven (sorry-free). The sorry-free infrastructure is substantial.

**Why not high**: The key assumption — that `restricted_forward_chain_forward_F` is truly sorry-free — must be verified. If it turns out to depend on the 3 sorry theorems through the call chain, the entire restricted chain approach needs to be rethought.

**Critical prerequisite**: Before implementing ANYTHING, run:
```bash
lake build
# Then in Lean:
#print axioms restricted_forward_chain_forward_F
```

If the output includes `sorryAx`, we pivot to Alternative A. If not, we proceed with the primary approach.

---

## Summary of Recommendation

1. **IMMEDIATELY**: Verify `#print axioms restricted_forward_chain_forward_F`
2. If sorry-free: Implement the restricted backward chain (symmetric to forward chain, ~750 lines)
3. If has sorries: Pivot to Alternative A (fresh direct MCS Int-chain, ~600 lines but harder math)
4. **IN EITHER CASE**: Abandon `boundary_resolution_set`, `constrained_successor_seed_restricted`, and `neg_not_in_boundary_resolution_set` — these are dead ends
5. Build a singleton BFMCS around the phi-specific FMCS and wire to `parametric_algebraic_representation_conditional`

The key architectural shift: **FMCS-first, then wrap in BFMCS**, rather than building BFMCS (via boxClassFamilies) and hoping temporal coherence falls out.
