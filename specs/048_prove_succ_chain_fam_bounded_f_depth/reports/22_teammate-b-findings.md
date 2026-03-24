# Research Report: Task #48 — Comprehensive Solution Evaluation

**Task**: 48 — prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Role**: Teammate B — Solution Evaluation
**Session**: sess_1774315200_b2eval

---

## Solution Comparison Table

| Approach | Mathematical Soundness | Infrastructure Support | Primary Risk | Overall Rating |
|----------|----------------------|----------------------|-------------|----------------|
| **A. Lindenbaum Extension** | HIGH — uses DRM maximality correctly | STRONG — extendToMCS, transfer_back ALREADY PROVEN | Succ lifting to extensions (not yet proven) | RECOMMENDED |
| **B. Lexicographic Termination** | HIGH — correctly models g_content path | MODERATE — iter_F exists, need iter_G + lex induction | Significant restructuring of bounded_witness | BACKUP |
| **C. Modified Chain Construction** | LOW-MEDIUM — v9/v10 path already hit ceiling | WEAK — augmented_seed_consistent done but restricted_single_step_forcing still false | Approach is fundamentally wrong for this gap | NOT RECOMMENDED |

---

## How `bounded_witness` Works in `CanonicalTaskRelation.lean`

The working `bounded_witness` theorem (line 651) depends on exactly TWO lemmas:

1. **`single_step_forcing`**: `F(psi) ∈ u ∧ FF(psi) ∉ u ∧ Succ u v → psi ∈ v`
2. **`succ_propagates_F_not`**: `FF(psi) ∉ u ∧ Succ u v → F(psi) ∉ v`

Both lemmas work for UNRESTRICTED MCS because they rely on:
- `SetMaximalConsistent.negation_complete`: `phi ∈ u ∨ phi.neg ∈ u`
- `neg_FF_implies_GG_neg_in_mcs`: `neg(FF(psi)) ∈ u → GG(neg(psi)) ∈ u`

The second lemma uses proof-system reasoning: `neg(F(phi)) = G(neg(phi)).neg.neg`, so `G(G(neg(phi)).neg.neg) → G(G(neg(phi)))` via G-distributivity and DNE — proven via `temporal_necessitation` + `temp_k_dist` + `double_negation` (SuccRelation.lean:196–208).

**The gap**: For `DeferralRestrictedMCS`, `negation_complete` does NOT apply when `FF(psi) ∉ deferralClosure`. We cannot derive `neg(FF(psi)) ∈ u` because `neg(FF(psi)) ∉ deferralClosure` either, and DRM only has maximality within `deferralClosure`.

---

## Detailed Analysis of Each Approach

### Approach A: Lindenbaum Extension

**Core idea**: Instead of proving `restricted_succ_propagates_F_not` directly (which is false in the boundary case), lift each chain element to a full MCS and use the existing working `bounded_witness`.

**Infrastructure ALREADY PROVEN** (SuccChainFMCS.lean):
- `DeferralRestrictedSerialMCS.extendToMCS` (line 4185) — Lindenbaum extension via `set_lindenbaum`
- `extendToMCS_is_mcs` (line 4193) — extension is `SetMaximalConsistent`
- `extendToMCS_extends` (line 4202) — `M.world ⊆ M.extendToMCS`
- `extendToMCS_transfer_back` (line 4249) — **KEY**: if `psi ∈ deferralClosure ∧ psi ∈ extendToMCS(M)` then `psi ∈ M.world`
- `restricted_forward_chain_transfer_back` (line 4280) — same for chain elements

The `extendToMCS_transfer_back` proof is complete and correct (lines 4253–4272). It uses `DeferralRestrictedMCS.2` (maximality): `psi ∉ M.world → ¬SetConsistent(insert psi M.world)`, combined with the fact that `extendToMCS ⊇ M.world ∪ {psi}` is consistent.

**Proof obligations remaining**:

1. **Succ lifting**: Prove `Succ(chain(k), chain(k+1)) → Succ(extendToMCS(chain(k)), extendToMCS(chain(k+1)))`

   This is the ONLY significant missing piece. Lean needs:
   ```lean
   theorem extendToMCS_succ_lift (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) :
       Succ (restricted_forward_chain phi M0 k).extendToMCS
            (restricted_forward_chain phi M0 (k+1)).extendToMCS
   ```

   **Proof strategy**: `Succ u v` requires `g_content(u) ⊆ v` and f_content step property. For `Succ(ext(u), ext(v))`:
   - `g_content(ext(u)) ⊆ ext(v)`: If `G(chi) ∈ ext(u)`, need `chi ∈ ext(v)`. Since `G(chi) ∈ ext(u)` and `ext(u)` is full MCS, `chi ∈ ext(u)` (by T-axiom). But does `chi ∈ ext(v)`? Not directly from `Succ(u,v)`.

   **CRITICAL ISSUE**: `Succ(u,v)` only gives us `g_content(u) ⊆ v`, not `g_content(ext(u)) ⊆ ext(v)`. The full MCS extension can contain `G(chi)` for formulas `chi` that were NOT in `g_content(u)`. These extra G-formulas cannot be transferred via the original `Succ(u,v)`.

   **However**, there is a workaround: we don't need `Succ(ext(chain(k)), ext(chain(k+1)))` for ALL k. We only need to apply `bounded_witness` to the SAME full MCS, not a chain of extensions.

2. **Alternative: Single-extension approach**

   Instead of extending each chain element, extend M0 ONCE to get a full MCS M_ext, and build the forward chain from M_ext using the existing `CanonicalTask_forward_MCS` infrastructure.

   - `M_ext = M0.toSerialMCS` (already defined, line 4318)
   - The forward chain from `M_ext` is the UNRESTRICTED `forward_chain` from CanonicalTaskRelation
   - `bounded_witness` applies directly to M_ext's chain
   - Transfer back: `psi ∈ forward_chain(M_ext, k+d) ∧ psi ∈ deferralClosure → psi ∈ restricted_forward_chain(M0, k+d)`

   This is MORE PROMISING than lifting each element. The proof obligation becomes:
   ```lean
   theorem restricted_chain_subset_extended_chain (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) :
       restricted_forward_chain phi M0 k ⊆
       forward_chain (M0.toSerialMCS) k
   ```
   Or equivalently: an F-formula in the restricted chain must be in the extended chain.

**Assessment**: The `extendToMCS_transfer_back` theorem is already proven. The gap is showing that F-witnesses found in the full MCS chain also appear in the restricted chain. This follows from `extendToMCS_transfer_back` if we can show the full MCS chain elements extend the restricted chain elements.

---

### Approach B: Lexicographic Termination

**Core idea**: The current `restricted_bounded_witness` uses induction on a single depth `d`. When `F(psi)` propagates through `g_content` (i.e., `GF(psi) ∈ chain(k)` causes `F(psi) ∈ chain(k+1)` WITHOUT decreasing f_depth), the induction breaks.

The fix: induct on `(g_depth, f_depth)` lexicographically where `g_depth` = nesting depth of G before the F in question within `deferralClosure`.

**Infrastructure needed**:
- `iter_G : Nat → Formula → Formula` — analogous to `iter_F` (NOT currently defined)
- `g_depth_bound : ∃ n, ∀ m > n, iter_G m (F psi) ∉ deferralClosure` — needs proof
- Lexicographic well-founded induction on `ℕ × ℕ` — available via `Prod.Lex.wf`

**Why it's mathematically sound**: At `g_depth = 0`, `GF(psi) ∉ deferralClosure`, so `GF(psi) ∉ chain(k)` for any k (since chain ⊆ deferralClosure). This blocks the g_content path entirely. At g_depth > 0, any step that doesn't decrease f_depth MUST decrease g_depth (because the successor chain removes one layer of G from the nesting).

**Key proof obligation**:
```lean
theorem g_depth_decreases_on_persistence (phi psi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k g_depth : Nat)
    (h_Gpsi_in : iter_G g_depth (F psi) ∈ restricted_forward_chain phi M0 k)
    (h_F_persists : F psi ∈ restricted_forward_chain phi M0 (k+1)) :
    ∃ g' < g_depth, iter_G g' (F psi) ∈ restricted_forward_chain phi M0 (k+1)
```

**Risk**: This requires understanding when `GF(psi)` appears in the seed vs the MCS extension, and proving the g_depth measure actually decreases. The proof is non-trivial and requires significant new infrastructure.

---

### Approach C: Modified Chain Construction (boundary_resolution_set)

**Why this is NOT recommended**:

The code analysis reveals the root problem clearly: `restricted_succ_propagates_F_not` is **false as stated** when `FF(psi) ∈ deferralClosure` but `GG(neg(psi)) ∉ deferralClosure`. The DeferralRestrictedMCS lacks `negation_complete` for formulas at the boundary of `deferralClosure`.

Plans v9-v10 have already gone through multiple variants of strengthening the hypotheses. The current sorry at line 3012 in `restricted_succ_propagates_F_not` says:
```
-- The entire branch needs the neg(FF psi) → GG(neg psi) derivation.
-- TODO: Prove via the proof system
sorry
```

The issue is NOT about proof-system derivations — `neg_FF_implies_GG_neg_in_mcs` IS proven (SuccRelation.lean:142) and works for full MCS. The problem is getting `neg(FF(psi)) ∈ chain(k)` when `chain(k)` is a DRM. For that, we need `FF(psi) ∈ deferralClosure` AND DRM negation completeness within dc. But DRM negation completeness for `FF(psi)` requires `FF(psi).neg ∈ deferralClosure` as well — which fails at the boundary.

Patching this with `boundary_resolution_set` just moves the sorry to a different location.

---

## Recommended Path Forward

### RECOMMENDATION: Approach A (Single Extension Variant)

The cleanest solution uses `M0.toSerialMCS` — the existing `DeferralRestrictedSerialMCS.toSerialMCS` conversion (line 4318).

**The complete proof strategy**:

```
Goal: F^d(psi) ∈ restricted_forward_chain(M0, k) ∧ F^(d+1)(psi) ∉ restricted_forward_chain(M0, k)
   → psi ∈ restricted_forward_chain(M0, k+d)

Step 1: Let M_ext = M0.toSerialMCS  (full MCS extending M0)
Step 2: Show restricted_forward_chain(M0, 0) ⊆ forward_chain(M_ext, 0)  [both = M0.world ⊆ M_ext]
Step 3: Show restricted_forward_chain(M0, k) ⊆ extendToMCS(restricted_forward_chain(M0, k))
        (already proven: extendToMCS_extends)
Step 4: The KEY QUESTION: can we relate forward_chain(M_ext, k) and extendToMCS(chain(k))?
Step 5: Apply bounded_witness to M_ext's chain to get psi ∈ forward_chain(M_ext, k+d)
Step 6: Since psi ∈ deferralClosure and psi ∈ extendToMCS(chain(k+d)), use transfer_back
        to get psi ∈ restricted_forward_chain(M0, k+d)
```

**The fundamental question**: Are the SAME successors generated starting from `M_ext` as from extending the restricted successors?

Answer: **NOT necessarily** — `M_ext` generates unrestricted successors via `CanonicalFrame`, while the restricted chain uses `constrained_successor_restricted`. They differ.

**Revised strategy**: Don't compare chains from different starting points. Instead, use the already-proven `restricted_forward_chain_canonicalTask_forward_from` (line 2282) which shows:

```lean
theorem restricted_forward_chain_canonicalTask_forward_from :
    CanonicalTask_forward_MCS (restricted_forward_chain phi M0 start) n
                               (restricted_forward_chain phi M0 (start + n))
```

This connects RESTRICTED chain elements to `CanonicalTask_forward_MCS`! Now look at `bounded_witness` — it requires `SetMaximalConsistent u`. But `restricted_forward_chain phi M0 k` is a `DeferralRestrictedMCS`, NOT a full `SetMaximalConsistent`.

**The real gap**: `bounded_witness` requires `SetMaximalConsistent` for its intermediate steps (specifically `succ_propagates_F_not` needs full negation completeness). We CANNOT directly apply `bounded_witness` to restricted chain elements.

**Correct use of transfer-back**:

The `extendToMCS_transfer_back` theorem (line 4249) applies to a single element. The path is:

1. `F^d(psi) ∈ chain(k)` → `F^d(psi) ∈ extendToMCS(chain(k))` (by `extendToMCS_extends`)
2. We need: `CanonicalTask_forward_MCS extendToMCS(chain(k)) d extendToMCS(chain(k+d))`
   — requires Succ lifting (the hard part)
3. Apply `bounded_witness` on the EXTENSIONS
4. Get `psi ∈ extendToMCS(chain(k+d))`
5. Since `psi ∈ deferralClosure` (it's a subformula, and the closure is closed downward), use `extendToMCS_transfer_back` to get `psi ∈ chain(k+d)`

**The EXACT obligation**: Prove Succ lifting for consecutive chain extensions:
```lean
theorem restricted_chain_ext_succ (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) :
    Succ (restricted_forward_chain phi M0 k).extendToMCS
         (restricted_forward_chain phi M0 (k+1)).extendToMCS
```

**Is this provable?** Let `u = chain(k)`, `v = chain(k+1)`, `u' = extendToMCS(u)`, `v' = extendToMCS(v)`.

`Succ(u, v)` gives: `g_content(u) ⊆ v` and f_step property.

For `Succ(u', v')`, we need `g_content(u') ⊆ v'`:
- Take `G(chi) ∈ u'` (full MCS extension of u)
- Need `chi ∈ v'`
- From `G(chi) ∈ u'` (full MCS): by T-axiom, `chi ∈ u'`... but this gives `chi ∈ u'`, not `chi ∈ v'`
- `G(chi) ∈ u' ⊇ u` — but `G(chi)` may NOT be in `u`! It was added by Lindenbaum.

**CRITICAL FAILURE**: The Succ lifting is NOT provable in general. The Lindenbaum extension for `u` can freely add `G(chi)` formulas that `u` doesn't have, and these G-formulas need NOT be in `v'`. The two extensions are INDEPENDENT Zorn's lemma applications with no coordination.

This is the gap identified in report 19 (line 118): "Lindenbaum Succ lifting needs verification."

---

## Reformulated Recommendation: Direct Modal Duality Proof

After full analysis, the ACTUAL missing piece is surprisingly SMALL.

The sorry at line 3012 in `restricted_succ_propagates_F_not` says:
```
-- The entire branch needs the neg(FF psi) → GG(neg psi) derivation.
-- TODO: Prove via the proof system
sorry
```

But `neg_FF_implies_GG_neg_in_mcs` IS proven in SuccRelation.lean:142. The reason it can't be applied directly is: it requires `(FF psi).neg ∈ M` where M is a FULL MCS with `negation_complete`. For DRM `u`, we only have negation completeness for formulas IN `deferralClosure`.

**The proof CAN work if**: `FF(psi) ∈ deferralClosure` (which is the case branch we're in, line 3002–3012). We have:
- `FF(psi) ∈ deferralClosure` (case hypothesis)
- `FF(psi) ∉ u` (hypothesis `h_FF_not`)
- `u` is DRM

But DRM negation completeness states: for `chi ∈ deferralClosure`, either `chi ∈ u` or `chi.neg ∈ u`... **WAIT**: does it?

Let me recheck. `DeferralRestrictedMCS` maximality (RestrictedMCS.lean:680):
```
∀ psi ∈ deferralClosure phi, psi ∉ S → ¬SetConsistent (insert psi S)
```

This says: if `psi ∈ dc` and `psi ∉ u`, then `insert psi u` is inconsistent. This is EXACTLY negation completeness within dc! If `FF(psi) ∈ dc` and `FF(psi) ∉ u`, then `insert (FF psi) u` is inconsistent. This means `u ⊢ ¬FF(psi)`, i.e., `neg(FF psi) ∈ u` (by MCS properties... but `u` is NOT a full MCS).

**The subtlety**: For a FULL MCS, `¬SetConsistent(insert psi u)` implies `neg(psi) ∈ u` by `SetMaximalConsistent.negation_complete`. But for DRM, it only means `insert (FF psi) u` is inconsistent — NOT that `neg(FF psi) ∈ u`.

For `neg(FF psi) ∈ u`, we'd need `neg(FF psi) ∈ deferralClosure` AND DRM to force it in. But `neg(FF psi)` may not be in `deferralClosure`.

**This is the TRUE root cause**: DRM maximality within dc does NOT imply `neg(psi) ∈ u` even when `psi ∈ dc ∧ psi ∉ u`, because `neg(psi)` may itself not be in `dc`.

---

## Specific Next Steps (What to Prove First)

### Step 1: Verify whether `neg(FF psi) ∈ deferralClosure` when `FF psi ∈ deferralClosure`

```lean
lemma neg_FF_in_deferralClosure_iff (phi psi : Formula) :
    (Formula.some_future (Formula.some_future psi)).neg ∈ (deferralClosure phi : Set Formula) ↔
    Formula.some_future (Formula.some_future psi) ∈ (deferralClosure phi : Set Formula)
```

Check `deferralClosure` definition: it's `closureWithNeg ∪ deferrals`. The `closureWithNeg` is closed under negation by definition. So if `FF(psi) ∈ closureWithNeg`, then `neg(FF psi) ∈ closureWithNeg ⊆ deferralClosure`.

**This may already be provable** — check if `some_future_in_deferralClosure_is_in_closureWithNeg` implies the neg is also in `deferralClosure`.

### Step 2: If Step 1 holds, complete `restricted_succ_propagates_F_not`

The proof would be:
1. `FF(psi) ∈ deferralClosure` (case hypothesis)
2. `FF(psi) ∉ u` (h_FF_not)
3. By DRM maximality: `insert (FF psi) u` is inconsistent
4. **Need**: `neg(FF psi) ∈ u` — requires DRM negation completeness WITH neg in dc
   - If `neg(FF psi) ∈ deferralClosure` (Step 1), and `neg(FF psi) ∉ u`, then `insert (neg FF psi) u` is inconsistent
   - But `insert (FF psi) u` AND `insert (neg FF psi) u` both inconsistent doesn't help directly
   - We need: `u` plus `FF(psi)` is inconsistent → `neg(FF psi)` is derivable from `u`
   - For DRM: there's a **Lindenbaum-style negation completeness** needed:
     `psi ∈ dc ∧ psi ∉ u ∧ neg(psi) ∈ dc → neg(psi) ∈ u`

   **Check RestrictedMCS.lean for this lemma**.

### Step 3: Search for existing DRM negation completeness lemma

```bash
grep -n "negation_complete\|neg_in_drm\|drm_neg" Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean
```

If this lemma exists, the sorry at line 3012 is directly fillable by following the same pattern as `succ_propagates_F_not` in CanonicalTaskRelation.lean:617–629, replacing `SetMaximalConsistent.negation_complete` with the DRM version.

### Step 4: Handle the second sorry (line 3026)

The case `F(psi) ∈ dc ∧ FF(psi) ∉ dc` — this is the truly hard boundary case. Here:
- We cannot get `neg(FF psi) ∈ u` (since `FF(psi) ∉ dc`)
- We cannot block `F(psi) ∈ v` via g_content blocking
- Use Approach B (lexicographic) for this specific sub-case

**Key insight**: When `FF(psi) ∉ deferralClosure`, `F(psi) ∈ chain(k)` means `F(psi)` is at the MAXIMUM F-depth in `deferralClosure`. This is the situation where the F-nesting bound `restricted_forward_chain_F_bounded` applies most directly.

Check `restricted_forward_chain_F_bounded` (line 2267) to see if it provides the bound needed.

---

## Confidence Assessment

| Sub-problem | Confidence | Reasoning |
|-------------|------------|-----------|
| `restricted_succ_propagates_F_not` when `FF(psi) ∈ dc` (line 3012) | **HIGH** | DRM negation completeness likely provable; `neg_FF_implies_GG_neg_in_mcs` already works once we have `neg(FF psi) ∈ u` |
| `restricted_succ_propagates_F_not` when `F(psi) ∈ dc, FF(psi) ∉ dc` (line 3026) | **MEDIUM** | Needs lexicographic argument or F-bounded argument |
| Succ lifting for Lindenbaum extensions | **LOW** | Fundamentally broken — independent Zorn applications cannot be coordinated |
| Overall `restricted_bounded_witness` completion | **MEDIUM-HIGH** | Once the two sorries in `restricted_succ_propagates_F_not` are fixed |

**Overall recommendation**: Do NOT pursue Lindenbaum Succ lifting. The transfer-back property IS proven. Focus on filling the sorrys in `restricted_succ_propagates_F_not` directly:

1. **Line 3012 (FF ∈ dc)**: Find or prove DRM negation completeness for formulas whose negation is also in dc, then apply `neg_FF_implies_GG_neg_in_mcs` + existing G-persistence chain.

2. **Line 3026 (F ∈ dc, FF ∉ dc)**: Use `restricted_forward_chain_F_bounded` to show this case forces `psi ∈ chain(k+1)` directly via the F-step property.

**First concrete action**: Search `RestrictedMCS.lean` for a lemma of the form `DeferralRestrictedMCS phi u → psi ∈ deferralClosure → neg psi ∈ deferralClosure → psi ∉ u → neg psi ∈ u`. If it doesn't exist, prove it — it's the core missing piece for line 3012.
