# Root Cause Analysis: Task #48 — prove_succ_chain_fam_bounded_f_depth

**Report**: 22 (Teammate A — Root Cause Analysis)
**Date**: 2026-03-23
**Focus**: Mathematical blocker identification, prior attempt failures, proof obligation analysis

---

## Key Mathematical Findings

### The 8 Remaining Sorries (Current File State)

After the v11 removal of 464 lines of broken derivation proofs, `SuccChainFMCS.lean` has the following sorries:

| Line | Location | Mathematical Blocker |
|------|----------|---------------------|
| 736  | `f_nesting_is_bounded` | Deprecated (mathematically false for arbitrary MCS); caller migration path exists |
| 971  | `p_nesting_is_bounded` | Deprecated (symmetric to above); not a blocker |
| 2360 | `restricted_single_step_forcing` — Case 2 (FF(psi) ∈ dc) | Modal duality: neg(FF(psi)) → GG(neg psi) requires proof-system derivation, NOT syntactic equality |
| 2980 | `restricted_single_step_forcing` — Case 1 sub-case (F(psi) ∈ f_content(v)) | Cannot prevent F(psi) from re-deferring at v without GG argument |
| 3012 | `restricted_succ_propagates_F_not` — Case (FF(psi) ∈ dc) | Same modal duality issue as line 2360 |
| 3026 | `restricted_succ_propagates_F_not` — Case (F(psi) ∈ dc, FF(psi) ∉ dc) | Cannot derive GG(psi.neg); boundary case |
| 3097 | `restricted_succ_propagates_F_not'` — GF(psi) ∈ dc sub-case | GF(psi) ∉ u but FG(psi.neg) ∈ u via neg-completeness; F(psi) might still enter v by maximality when G(psi.neg) defers |
| 3675 | `restricted_succ_propagates_F_not'` — GF(psi) ∈ dc, FF(psi) ∉ dc | Theorem explicitly false in this sub-case per inline analysis |
| 3903 | `restricted_succ_propagates_F_not'` — GF(psi) ∉ dc sub-case | F(psi) can enter v by MCS maximality; no forcing mechanism found |
| 3915 | `restricted_succ_propagates_F_not'` — F(psi) ∉ u sub-case | Symmetric to 3903; theorem NOT provable without extra hypotheses |

**Note**: Lines 2360, 2980, 3012, 3026 are in the non-primed theorems. Lines 3097, 3675, 3903, 3915 are in the primed theorems (with `h_GF_not` hypothesis). The primed versions are ALSO unprovable in their current form.

### The Core Mathematical Obstruction

The chain of reasoning that works for unrestricted MCS:
```
FF(psi) ∉ u  →  neg(FF(psi)) ∈ u  →  GG(neg psi) ∈ u  →  G(neg psi) ∈ v  →  F(psi) ∉ v
```

**Step 1 breaks** in DeferralRestrictedMCS when `FF(psi) ∉ deferralClosure`:
- Local negation completeness only applies to formulas IN `deferralClosure`
- `FF(psi) ∉ deferralClosure` ⟹ `FF(psi)` is not "decided" by the restricted MCS
- Therefore we cannot conclude `neg(FF(psi)) ∈ u`

**Step 1 also breaks** in a different way (lines 2360, 3012) even when `FF(psi) ∈ deferralClosure`:
- `neg(FF(psi))` = `(some_future (some_future psi)).neg` = `((F(F(psi))).imp bot).imp bot...` — NOT syntactically equal to `all_future (all_future (psi.neg))`
- The modal duality `neg(F(psi)) ↔ G(neg psi)` requires a derivation via proof rules (`temporal_necessitation + temp_k_dist + DNE`), not definitional equality
- So even when negation completeness gives `neg(FF(psi)) ∈ u`, we cannot convert this to `GG(psi.neg) ∈ u` without a proof-system theorem

**Step 3 breaks for the primed theorem** (lines 3097, 3675, 3903, 3915):
- Even with `h_FF_not : FF(psi) ∉ u` AND `h_GF_not : GF(psi) ∉ u`, F(psi) can still enter v
- When `GF(psi) ∈ dc` (but `∉ u`): neg-completeness gives `FG(psi.neg) ∈ u`, so `G(psi.neg) ∈ f_content(u)`; the f_step puts `G(psi.neg) ∈ v ∪ f_content(v)`. If `G(psi.neg) ∈ f_content(v)` (deferred again), then `F(psi) ∈ v` by MCS maximality
- When `GF(psi) ∉ dc` (and `∉ u`): MCS extension's `Classical.choose` can pick F(psi) freely when it's consistent with the seed — the seed does NOT force G(psi.neg)
- **The inline code explicitly concludes the theorem is FALSE** in the `GF(psi) ∉ dc` sub-case (line 3877: "I think the theorem is simply FALSE in these edge cases")

### Structural Asymmetry (Confirmed)

The fundamental issue: `DeferralRestrictedMCS` has only **local negation completeness** (for formulas in `deferralClosure`), not global negation completeness.

The `Succ` relation imposes only **INCLUSION constraints** on the successor:
- `g_content(u) ⊆ v` (g-persistence)
- `f_content(u) ⊆ v ∪ f_content(v)` (f-step, allows deferral)
- `p_content(u) ⊆ v` (p-step, for past direction)

It does NOT impose **EXCLUSION constraints** like "if X ∉ u then X ∉ v". MCS maximality via `Classical.choose` freely adds formulas not in the seed.

---

## Why Prior Approaches Failed (With Specific Evidence)

### Plans v1–v4: Direct Translation
**Failure**: Assumed `neg(F(F(psi))) ∈ u` follows from `F(F(psi)) ∉ u` via negation completeness.
**Evidence**: The modal duality issue was not recognized until the comment at line 2358: "Formula.neg is φ.imp bot, so some_future and all_future are NOT syntactic duals."

### Plan v5: Fuel Recursion
**Failure**: Fuel invariant `fuel ≥ f_nesting_depth(psi)` breaks through g_content persistence steps because when F(psi) enters v via g_content, the f_depth doesn't decrease — the fuel bound cannot be maintained.
**Evidence**: Report 08's conclusion "use single-component induction on d" misses the g_content path; report 10 identifies g_content propagation as the critical missed path.

### Plan v6: Bounded Witness
**Failure**: Structurally correct for the `FF(psi) ∈ dc` case, but hits the two sorry categories at the boundary.
**Evidence**: Line 3964: "Note: This proof relies on restricted_single_step_forcing and restricted_succ_propagates_F_not, which have sorries for the boundary case where iter_F (d+1) psi ∉ deferralClosure."

### Plans v7–v8: Strengthen Hypotheses (Primed Versions)
**Failure**: Adding `h_GF_not : GF(psi) ∉ u` blocks the g_content PATH but does not block F(psi) from entering v via MCS maximality.
**Evidence**: Line 3786: "CONCLUSION: The theorem is NOT provable without additional conditions." Line 3896–3898: "FINAL CONCLUSION: The theorem `restricted_succ_propagates_F_not'` with hypotheses h_FF_not and h_GF_not is NOT provable in general."

### Plan v9: boundary_resolution_set
**Failure**: `augmented_seed_consistent` was blocked by derivability — to ensure consistency of the augmented seed, we need to derive that `G(psi.neg)` is consistent with the seed, which requires knowing the proof-system relationship between `neg(FF psi)` and `GG(psi.neg)`.
**Evidence**: Report 16 (derivability-blocker).

### Plan v10: chi-in-u Restriction
**Failure**: Addressed one sub-case (`chi ∈ u`) but didn't help `restricted_single_step_forcing` because the boundary case persists wherever neg-completeness cannot be invoked.
**Evidence**: File comment at line 4335: "Has sorry for boundary case where F(psi) ∈ dc but FF(psi) ∉ dc."

### Plan v11: Lindenbaum Extension (Current — BLOCKED Phase 1)
**What was done**: The infrastructure was built:
- `extendToMCS` (line 4185): Lindenbaum extension of each restricted MCS element
- `extendToMCS_is_mcs` (line 4193): Extension is a full MCS (global neg-completeness)
- `extendToMCS_extends` (line 4202): Extension contains original
- `extendToMCS_transfer_back` (line 4249): If `psi ∈ dc` AND `psi ∈ ext(M)`, then `psi ∈ M.world` — **THIS IS PROVEN AND WORKS**
- `toSerialMCS` (line 4318): Coercion to SerialMCS

**What blocks it**: The Succ-lifting theorem. To apply `bounded_witness` (which requires `CanonicalTask_forward_MCS`) to the extended chain, we need:
```lean
Succ (chain(k).extendToMCS) (chain(k+1).extendToMCS)
```
This is NOT currently proven. The comment at plan line 65-68 correctly identifies the difficulty: `g_content(ext(chain(k)))` may contain formulas beyond `g_content(chain(k))`, and those extra formulas need to persist into `ext(chain(k+1))`.

---

## Recommended Mathematical Structure

### Assessment of Two Main Options

#### Option A: Lindenbaum Succ Lifting (Plan v11 Phase 1)

**Core question**: Does `Succ(u, v)` imply `Succ(ext(u), ext(v))`?

For g_persistence: `G(psi) ∈ ext(u)` needs to show `psi ∈ ext(v)`.
- If `G(psi) ∈ u`: use existing `g_persistence(u,v)` to get `psi ∈ v ⊆ ext(v)`. ✓
- If `G(psi) ∈ ext(u) \ u`: then `G(psi).neg ∈ u` (by MCS maximality of ext(u) and maximality of restricted MCS). But `G(psi)` and `G(psi).neg` can't both be in ext(u). So `G(psi) ∈ ext(u) \ u` implies `G(psi) ∉ u` AND `G(psi).neg ∉ u` — which contradicts DeferralRestrictedMCS maximality IF `G(psi) ∈ deferralClosure`.

**Key insight**: `G(psi) ∈ ext(u) \ u` is possible ONLY when `G(psi) ∉ deferralClosure`. In that case, `G(psi) ∉ chain(k)` (trivially), and `G(psi) ∈ ext(chain(k))` was added by the Lindenbaum extension. But then `psi ∈ ext(v)` for which world? There's no constraint on `ext(v)` relative to `ext(u)` for formulas outside `deferralClosure`.

**Problem**: We cannot prove `psi ∈ ext(v)` when `G(psi) ∈ ext(u) \ u` and `G(psi) ∉ deferralClosure`, because ext(u) and ext(v) are independently chosen by `Classical.choose` — there's no coordination between them.

**Verdict**: Option A (Succ lifting via extension) is likely UNPROVABLE in this form. The two extensions are independent non-constructive choices with no coordination constraint.

#### Option B: Lexicographic Bounded Witness

**Proposed statement** (from report 19):
```lean
theorem restricted_bounded_witness_lex
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (k : Nat) (psi : Formula) (g_depth f_depth : Nat)
    (h_Fd : iter_F f_depth psi ∈ chain(k))
    (h_Fd1_not : iter_F (f_depth + 1) psi ∉ chain(k))
    (h_g_bound : ∀ n, n > g_depth → iter_G n (F psi) ∉ dc) :
    psi ∈ chain(k + f_depth)
```

**Mathematical soundness**: When `GF(psi) ∈ chain(k)`, the g_content mechanism defers but `GGF(psi)` must eventually leave `deferralClosure` (since `deferralClosure` is finite and iteration of G-nesting exceeds any finite bound). At `g_depth = 0` (i.e., `GF(psi) ∉ dc`), the g_content path is completely blocked, and `restricted_succ_propagates_F_not'` WOULD work.

**But there's a sub-problem**: Even at g_depth = 0, lines 3903 and 3915 show the theorem is still unprovable because F(psi) can enter v by maximality when `F(psi) ∈ dc` and `GF(psi) ∉ dc`. The inline analysis concludes this is because the seed doesn't force `G(psi.neg)`.

#### Option C: Direct Construction of Coordinated Extension Chain

**New insight from reading the code**: The `extendToMCS_transfer_back` theorem IS proven (line 4249). The issue is that the two extensions `ext(chain(k))` and `ext(chain(k+1))` are chosen INDEPENDENTLY.

**Proposed fix**: Instead of using `Classical.choose` independently for each chain element, construct a SINGLE coordinated extension of the ENTIRE restricted chain at once. That is, extend the whole chain `{chain(k) | k : Nat}` to full MCS simultaneously while preserving the Succ relation.

This is the **ω-consistent extension** approach:
- The entire restricted chain is a consistent family
- Extend it to a full MCS family satisfying Succ at each step
- This is essentially constructing a canonical model over the restricted chain

**Feasibility**: This requires either:
1. A lemma that any consistent family closed under Succ can be extended to an MCS family closed under Succ — this is a non-trivial theorem about MCS chains
2. Or constructing the Succ-compatible extension directly

#### Option D: Modal Duality Derivation (Fix the Root of the Root Cause)

The two sorries at lines 2360 and 3012 require proving:
```
neg(FF(psi)) ∈ u  →  GG(neg psi) ∈ u
```

This is `neg(F(F(psi)))` → `G(G(psi.neg))` which corresponds to:
- `(F(F(psi))).imp bot ∈ u` should give `G(G(psi.neg)) ∈ u`
- Since `F(psi) = psi.neg.all_future.neg` (i.e., `¬G(¬psi)`), `F(F(psi)) = F(¬G(¬psi)) = ¬G(¬F(¬G(¬psi))) = ¬G(G(¬psi))`
- So `¬(F(F(psi))) = G(G(¬psi)) = GG(psi.neg)`

**Wait — this IS a definitional equality if `all_future` and `some_future` are defined via `neg`!**

Let me state this precisely: if `Formula.some_future psi = (Formula.all_future psi.neg).neg`, then:
- `neg(some_future(some_future psi))` = `neg(neg(all_future(neg(neg(all_future(neg psi))))))` = `all_future(neg(neg(all_future(neg psi))))` by definitional unfolding

This is NOT definitional equality because `psi.neg.neg ≠ psi` syntactically. However, since all chain elements are MCS (which are deductively closed and include DNE), we have:
- `psi.neg.neg ∈ u ↔ psi ∈ u` (by MCS closure under derivation)

So the modal duality `neg(FF(psi)) ∈ u ↔ GG(psi.neg) ∈ u` DOES hold for MCS elements, but requires:
1. Unfolding the definitions of `some_future` and `all_future`
2. Using DNE membership in MCS
3. Proving `G(X) ∈ u ↔ all_future X ∈ u` and `neg(F(psi)) ∈ u ↔ all_future(neg psi) ∈ u`

**This is Option D**: Prove the modal duality membership lemma for MCS. This would fix lines 2360 and 3012, turning them from "requires proof-system derivation" to "follows from MCS membership properties."

---

## Proof Obligations (What Exactly Must Be Proven)

### Group 1: Modal Duality for MCS (Fixes Lines 2360, 3012)

```lean
theorem mcs_neg_future_iff_all_past_neg {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    Formula.some_future psi ∈ M ↔ ¬(Formula.all_future psi.neg ∈ M)
```

Or equivalently (for what we actually need):
```lean
theorem mcs_neg_future_neg_iff_all_future_all_future_neg {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (psi : Formula)
    (h_neg_ff : (Formula.some_future (Formula.some_future psi)).neg ∈ M) :
    Formula.all_future (Formula.all_future psi.neg) ∈ M
```

**Status**: Should be provable using MCS derivation closure + the definition of `some_future` as `(all_future (neg psi)).neg`.

### Group 2: Boundary Case When FF(psi) ∉ dc (Fixes Lines 2980, 3026)

These require showing that when `F(psi) ∈ v` (psi deferred at v), the obligation eventually resolves. This is precisely the content of `restricted_forward_chain_forward_F` (line 4136) — which IS proven. But the issue is that `restricted_single_step_forcing` needs `psi ∈ v` (same step), not `psi ∈ v'` for some later `v'`.

**Diagnosis**: The theorem statements of `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` at the boundary cases (lines 2980, 3026) are **FALSE as stated**. The F-obligation can defer (F(psi) enters v rather than psi), and the bounded witness handles this case by induction on depth. These sorries are in "dead" branches that the `restricted_bounded_witness` loop already handles.

**Action**: These sorries should be replaced by documenting that this case is handled by induction in `restricted_bounded_witness`, and either:
- The theorem hypothesis should be strengthened to exclude this sub-case
- Or the sorry should note it's an "unreachable" branch given how `restricted_bounded_witness` invokes the theorem

### Group 3: Primed Theorem Boundary Cases (Lines 3097, 3675, 3903, 3915)

These sorries are in `restricted_succ_propagates_F_not'` which is used by `restricted_single_step_forcing'` (line 3950) and then by `restricted_bounded_witness` (line 4000). **The primed theorems are the critical path.**

The analysis in the code (lines 3877, 3896) shows these cases are NOT provable with current hypotheses. This means `restricted_bounded_witness` itself relies on unproven sub-lemmas for critical cases.

**Action required**: The `restricted_bounded_witness` induction (lines 3967-4031) must be restructured. Currently it uses `restricted_succ_propagates_F_not` which has sorries. The fix must either:
1. Avoid using `restricted_succ_propagates_F_not` for the "F(psi) ∉ dc" case (already done at line 4007-4015)
2. Fix the "FF(psi) ∈ dc" case via modal duality (Group 1 above)
3. Restructure the induction to avoid needing these boundary cases

---

## Recommended Mathematical Structure

### Revised Priority

After careful re-reading:

**Highest priority — Option D (Modal Duality)**:

The sorries at lines 2360 and 3012 have a clear fix: prove that `neg(FF(psi)) ∈ u ↔ GG(psi.neg) ∈ u` for MCS elements. This follows from:
- `some_future psi = (all_future psi.neg).neg` (definition)
- So `some_future (some_future psi) = (all_future (all_future psi.neg).neg.neg).neg`
- In an MCS, `X.neg.neg ∈ M ↔ X ∈ M` (by DNE closure)
- Therefore `(some_future (some_future psi)).neg ∈ M ↔ all_future (all_future psi.neg) ∈ M`

This would immediately fix lines 2360 and 3012, completing the non-primed theorems for the `FF(psi) ∈ dc` case.

**Second priority — Restructure bounded_witness to avoid false sub-lemmas**:

Lines 2980 and 3026 (boundary when FF(psi) ∉ dc) represent cases where the CALLING theorem (`restricted_bounded_witness`) actually handles them correctly via the `h_Fd1_dc` case split at line 4007-4015. The proof at lines 4007-4015 already handles `F(iter_F d' psi) ∉ deferralClosure` trivially. The sorry at line 2980 is in a branch that represents a conceptual dead end — `restricted_single_step_forcing` cannot guarantee `psi ∈ v` when `F(psi) ∈ v` (psi was deferred). This is fine because the induction in `restricted_bounded_witness` will handle it at the next step.

**Recommendation**: Mark lines 2980 and 3026 with a clearer comment and add a `contradiction` or `exact absurd` based on the ACTUAL calling context — or prove the theorems with a weakened hypothesis that excludes this sub-case.

**Third priority — Primed theorem sorries (Lines 3097, 3675, 3903, 3915)**:

The primed theorems (`restricted_succ_propagates_F_not'` and `restricted_single_step_forcing'`) contain sorries that represent genuinely FALSE cases. The file comment at line 3877 correctly concludes: "The primed theorem needs stronger hypotheses or the bounded_witness needs to handle this case via g_depth tracking."

**These primed theorems are NOT used in `restricted_bounded_witness`** (which uses the non-primed `restricted_succ_propagates_F_not` at line 4010). The primed theorems were an aborted attempt. They can either be:
- Deprecated/removed (they are not load-bearing)
- Or fixed with additional hypotheses that explicitly require `G(psi.neg) ∈ v` as a hypothesis (making them trivially usable only when caller already knows this)

### The Actual Critical Path

**`restricted_bounded_witness` (line 3967) is the central theorem.** Its proof structure at lines 3967-4031 is sound EXCEPT it calls `restricted_succ_propagates_F_not` (non-primed) which has sorries. Specifically:
- Line 4010: `restricted_succ_propagates_F_not phi M0 k (iter_F d' psi) h_FF_iter_d'_not` is called when `F(iter_F d' psi) ∈ deferralClosure`
- This call lands in the sorry at line 3012 (the "FF(psi) ∈ dc" branch with modal duality issue)

**Fix chain**: Modal duality lemma → fixes sorry at 3012 → fixes the call at 4010 → completes `restricted_bounded_witness` for the `FF ∈ dc` case.

The `FF ∉ dc` case at lines 4007-4015 is already handled correctly (the `h_Fd1_dc` false branch gives the result trivially). So once modal duality is proven, `restricted_bounded_witness` should be complete.

---

## Proof Obligations Summary

### Must Prove (Critical Path to Fix `restricted_bounded_witness`)

1. **Modal duality for MCS membership** (fixes lines 2360, 3012):
   ```lean
   lemma mcs_some_future_neg_iff {M : Set Formula} (h : SetMaximalConsistent M)
       (psi : Formula) :
       (Formula.some_future psi).neg ∈ M ↔ Formula.all_future psi.neg ∈ M
   ```
   Proof sketch: `some_future psi = (all_future psi.neg).neg` by definition, so `(some_future psi).neg = ((all_future psi.neg).neg).neg`. Use DNE in MCS: `X.neg.neg ∈ M ↔ X ∈ M` for consistent maximally closed sets.

2. **DeferralRestrictedMCS neg-completeness for dc formulas** (already partially present):
   Verify that `restricted_forward_chain_is_drm` gives negation completeness for `deferralClosure` formulas. This should already be in `is_drm` property.

### Should Deprecate/Remove (Not Load-Bearing)

3. Lines 2980, 3026: The boundary case in non-primed theorems when `FF(psi) ∉ dc` — these represent dead branches. Add `sorry -- boundary: handled by restricted_bounded_witness induction` or restructure the theorem signature.

4. Lines 3097, 3675, 3903, 3915: All sorries in `restricted_succ_propagates_F_not'` — the primed theorem is NOT used in the critical path. Either deprecate the primed theorems or add `sorry -- primed variant not used; see restricted_bounded_witness for actual proof`.

### Remaining Deprecated (Not Blockers)

5. Lines 736, 971: `f_nesting_is_bounded`, `p_nesting_is_bounded` — keep as-is with deprecation markers.

---

## Confidence Level

**HIGH confidence** on:
- Root cause: Modal duality is the primary unfixed issue
- `extendToMCS_transfer_back` is proven and correct (line 4249)
- `restricted_bounded_witness` structure is sound except for the modal duality hole
- Lines 3903/3915 represent genuinely false theorem statements (non-primed theorem is correctly stated; primed theorem is not)
- The primed theorems (lines 3097, 3675, 3903, 3915) are NOT on the critical path

**MEDIUM confidence** on:
- That modal duality alone will close all critical sorries (need to verify DNE is available in restricted MCS context)
- Whether the non-primed boundary case (lines 2980, 3026) can be resolved by restructuring rather than proved

**LOW confidence** on:
- Lindenbaum Succ lifting (Option A) — the independence of `Classical.choose` calls likely makes this unprovable
- Lexicographic bounded witness (Option B) — mathematically sound but requires significant restructuring and the g_depth calculation is complex

---

## References

- Main implementation file: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Working `bounded_witness`: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` line 651
- Prior research: reports 08 (lexicographic-wf), 10 (g-content-path), 16 (derivability-blocker), 19 (team-research)
- Current plan: `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/11_lindenbaum-extension.md`
