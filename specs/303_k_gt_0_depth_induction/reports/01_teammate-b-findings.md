# Teammate B: Alternative Approaches for Task 303

## Task Summary

Close `existPart_succ_n1_bypass` at k>0 (KampBypass.lean:104 `sorry`) via Rabinovich Section 5 Lemma 5.1 interval-splitting induction. This is the sole remaining sorry blocking `completeness_discrete`.

---

## Key Findings

### 1. Boneyard Prior Art: What Was Tried and Abandoned

**RabinovichGeneralized.lean** (`Theories/Bimodal/Boneyard/RabinovichPath/RabinovichGeneralized.lean`, archived task 302) contains a nearly complete implementation of the mutual induction structure. Key findings:

- `existPart_succ` (line 399–471) implements the step case of the ExistPart induction, delegating to `existPart_succ_n1_bypass` for n=1 — the current sorry site. The n>=2 case also has sorry but is acknowledged to depend solely on the n=1 case.
- The `kamp_mutual_induction` theorem (line 479–491) correctly structures the full induction: `CharPart(0) + ExistPart(0) -> ... -> CharPart(k+1) + ExistPart(k+1)`.
- `nf_2var_exist_formula_prior_filled` (line 497–520) shows that once `kamp_mutual_induction` is complete, it directly fills the sorry in NfCharFormula.lean via `(kamp_mutual_induction atomMap h_surj k).2`.

**Critical insight**: The boneyard code is NOT on the critical path because RabinovichGeneralized.lean itself is archived and has `#exit`. The sorry in `existPart_succ_n1_bypass` in KampBypass.lean is the live site; the boneyard's ExistPart framework is an alternative integration point if we revive it. However, the boneyard path was specifically abandoned in task 302 as "dead code with no live downstream consumers."

**RabinovichNegation.lean** (`Theories/Bimodal/Boneyard/RabinovichPath/RabinovichNegation.lean`) contains `nf_exist_backward_prior` (the backward direction of nf_exist_formula) which also has a sorry at depth k+1 for the same mathematical obstacle (Prior composition property at depth k+1). This confirms the sorry at KampBypass.lean:104 is the correct site to target.

### 2. The Core Mathematical Obstacle

The sorry in `existPart_succ_n1_bypass` (`KampBypass.lean:104`) at `| succ k' => sorry` requires proving:

> For `sub_nf : NormalForm sig (k'+2) 2`, given `char_kp1` (characteristic formulas for all depth-(k'+2) 1-var NFs), there exists a temporal formula A such that `temporal_truth M t A ↔ ∃ x, nf_eval_nf M (k'+2) 2 (Fin.cons x (fun _ => t)) sub_nf` on Prior structures.

The k=0 case (`existPart_succ_n1_bypass_k0`) succeeds because depth-1 sub-NFs have **depth-0 3-var quantifier conditions** (purely atomic), which can be encoded using zone-aware VecEA2 formulas. The key machinery (KampBypassUntil/Since.lean) works by:
1. Taking `nf_x = nf_characteristic M 1 1 (fun _ => x)`
2. Showing x's 1-var NF + zone determines all quantifier conditions via `ssn_xt_compatible` + `ssn_zone_until`
3. Building a VecEA2 with correct backward direction from zone decomposition

At k>0, the 3-var quantifier conditions are depth-k NFs (NOT purely atomic), so the zone decomposition approach breaks: `ssn_xt_compatible` only checks depth-0 predicates and order atoms.

### 3. Alternative Approach: Depth Induction on the Enriched Formula

**Most Promising Alternative (High Confidence)**

The k=0 bypass proof (KampBypassUntil/Since.lean) works by exploiting the fact that depth-0 3-var NFs are purely atomic. For k>0, we need to handle depth-k 3-var NFs. The `char_kp1` argument already provides:

```lean
char_kp1 : NormalForm sig (k' + 2) 1 → Formula
char_kp1_correct : temporal_truth M t (char_kp1 nf_1) ↔ nf_eval_nf M (k'+2) 1 (fun _ => t) nf_1
```

**The key insight**: At depth k+2 (k' >= 0), the sub-NF `sub_nf : NormalForm sig (k'+2) 2` has quantifier conditions of the form `ssn : NormalForm sig (k'+1) 3`. These are depth-(k'+1) 3-var NFs. To characterize `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn`, we would need ExistPart(k'+1) at n=2, which in turn requires ExistPart(k') at n=2, etc.

This is exactly the **mutual induction structure** in RabinovichGeneralized.lean. The alternative is to **revive the mutual induction approach** as a new file (not boneyard), letting it call `existPart_succ_n1_bypass_k0` for the base case and building the depth-k characterization recursively.

### 4. Restructuring the Dispatch: Eliminate the k>0 Sorry Entirely

**Alternative (Medium Confidence)**

Looking at `NfCharFormula.lean:634–651`, the dispatch currently:
- k=0: `nf_2var_exist_depth0_tl` (VecEA2-based, sorry-free)
- k=1: `existPart_succ_n1_bypass_k0` directly (sorry-free)
- k+2: `existPart_succ_n1_bypass` (hits sorry)

The k=1 case already bypasses the sorry by calling `existPart_succ_n1_bypass_k0` directly. **Could the k=2 case be handled similarly?** At k=2 (`sub_nf : NormalForm sig 2 2`), the quantifier conditions are `ssn : NormalForm sig 1 3`. ExistPart(1) at n=2 would be needed; but `existPart_succ_n1_bypass_k0` only handles arity-2 NFs at depth-1.

This approach **does not generalize** without the full induction. It could only extend by 1 depth level at a time, requiring `existPart_succ_n1_bypass_k1`, `existPart_succ_n1_bypass_k2`, etc. — an infinite family.

### 5. Composition Property Approach

**Alternative (Low-Medium Confidence)**

The `nf_exist_backward_prior` sorry (`NfCharFormula.lean:542`) requires the "Prior composition property": on Prior structures, the depth-k 3-var NF of (y,x,t) is determined by x's depth-(k+1) 1-var NF + t's predicates + y's position + Prior-UZ/SZ. This is the content of what Rabinovich calls "negation closure."

`NfComposition.lean` already has partial infrastructure:
- `nf_drop_last`: projection for (n+1)-var NFs
- `nf_1var_from_2var_agree`: 2-var implies 1-var agreement
- `intra_structure_extend`: depth-K n-var agreement implies depth-(K-1) (n+1)-var agreement in the same structure

However, the comment in NfComposition.lean explicitly notes that `generalized_composition` is **FALSE for n >= 2** on general linear orders. On **Prior** structures, the situation is different because UZ/SZ give definable infima/suprema (already proved in `PriorINF.lean`), but connecting this to the 3-var NF composition is the same mathematical content as the sorry.

### 6. Rabinovich Section 5 Literature Alignment

The Rabinovich 2014 paper (Lemma 5.1, Corollary 5.4, The Full Proof) gives:

**Lemma 5.1**: The negation of an interval pattern `[alpha_0, beta_1, ..., alpha_n](z_0, z_1)` is equivalent to a V-exists-forall formula over Dedekind complete chains.

**Proof structure** (induction on n):
1. Case n=1: handled by INF formula (5.2) + three sub-cases
2. Inductive step: split the interval at a new point z using A_i^-(z_0,z) and A_i^+(z,z_1), then apply IH

The **Prior analog**: Prior-UZ/SZ provide definable infima/suprema (attained, not just limit points), simplifying the three sub-cases of Lemma 5.1 to just Case 1 (endpoint failure, direct) and Case 3 (first occurrence at r0, Prior-UZ gives attained r0). This is already encoded in `PriorINF.lean`:

```
prior_hasDefinableINF  -- UZ -> attained first occurrence  
prior_hasDefinableSUP  -- SZ -> attained last occurrence
```

**The formalization gap**: The Lean NF framework uses a different representation than Rabinovich's interval patterns. The translation from "depth-(k+1) 2-var NF with quantifier conditions = depth-k 3-var NFs" to "interval pattern with n points in (z_0, z_1)" is the bridge that needs to be built.

---

## Recommended Approach

**Approach: Revive the Mutual Induction (RabinovichGeneralized pattern) in a live file**

The boneyard `RabinovichGeneralized.lean` demonstrates the correct overall structure but was archived because it depended on `existPart_succ_n1_bypass` which had sorry. Now that `existPart_succ_n1_bypass_k0` is sorry-free, the following plan fills the remaining sorry:

1. **Create `KampMutualInduction.lean`** with `CharPart` and `ExistPart` definitions (as in boneyard)
2. **Base cases**: Use existing sorry-free results:
   - `charPart_zero`: uses `nf_depth0_char_formula` (already proved)
   - `existPart_zero`: uses `nf_2var_exist_depth0_tl` for n=1 and `bool_eq_of_iff_same` for n>=2
3. **Step case ExistPart(k+1) at n=1**: This is exactly `existPart_succ_n1_bypass` — the recursive call uses `char_kp1` (which comes from `charPart_succ` applied to `ExistPart(k)`) and `existPart_succ_n1_bypass_k0` for the base
4. **Fill `existPart_succ_n1_bypass`** by extracting from the mutual induction

The key observation is that `existPart_succ_n1_bypass` takes `char_kp1` as an argument (the characteristic formula map for depth k+1 NFs). In the mutual induction, `char_kp1` comes from `charPart_succ ih_char ih_exist`, which is already sorry-free. So **the sorry in `existPart_succ_n1_bypass` at `succ k'` should be filled by induction**, calling `existPart_succ_n1_bypass_k0` at the base and recursing through the mutual induction for higher k.

**Concrete strategy for `existPart_succ_n1_bypass` at `succ k'`**:

The recursive case requires: given depth-(k'+2) 2-var NF `sub_nf`, find a temporal formula A.

The depth-(k'+2) 2-var NF `sub_nf` has:
- `sub_nf.1 : AtomKind sig 2 → Bool` (atom conditions at x and t)
- `sub_nf.2 : NormalForm sig (k'+1) 3 → Bool` (quantifier: for each depth-(k'+1) 3-var NF ssn, does ∃y with that NF hold?)

The depth-(k'+1) 3-var existentials `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn` need to be characterized temporally. These are **ExistPart(k'+1) at n=2** (arity-3 existentials) — but the current `existPart_succ_n1_bypass` only handles n=1 (arity-2 existentials). This means the approach requires ExistPart at all n, not just n=1.

**This is why the mutual induction is unavoidable**: ExistPart at all n is needed, and the n>=2 case reduces to n=1 via the `bool_eq_of_iff_same` projection (as done in boneyard `existPart_zero` for the depth-0 case, lines 190–364 of RabinovichGeneralized.lean).

---

## Evidence / File Paths

| File | Line | Content |
|------|------|---------|
| `KampBypass.lean:100–104` | sorry site | `existPart_succ_n1_bypass` at `succ k'` |
| `KampBypass.lean:35–74` | k=0 sorry-free base | `existPart_succ_n1_bypass_k0` |
| `NfCharFormula.lean:634–651` | dispatch pattern | k=0/1 sorry-free, k+2 calls sorry |
| `NfCharFormula.lean:503–542` | nf_exist_backward_prior | same mathematical obstacle, sorry |
| `Boneyard/RabinovichPath/RabinovichGeneralized.lean:88–127` | CharPart/ExistPart definitions | exact abstraction needed |
| `Boneyard/RabinovichPath/RabinovichGeneralized.lean:399–471` | existPart_succ | ExistPart step case pattern |
| `Boneyard/RabinovichPath/RabinovichGeneralized.lean:479–520` | kamp_mutual_induction | fills sorry via `.2` |
| `KampBypassUntil.lean:25–54` | backward_holdsLeft_of_nf_eval | k=0 backward direction pattern |
| `PriorINF.lean:141–193` | prior_hasDefinableINF/SUP | INF/SUP for Prior structures |
| `NfComposition.lean:22–36` | Note on generalized_composition | FALSE for n>=2 without Prior |
| `Literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md:134–173` | Lemma 5.1 proof | interval-splitting induction structure |

---

## Confidence Levels

| Approach | Confidence | Reason |
|----------|------------|--------|
| Mutual induction (revive boneyard pattern) | **High** | Boneyard already has full structure; base cases are sorry-free; only new work is ExistPart(k+1) n>=2 projection |
| Dispatch restructuring (k+1 bypass at each depth) | **Low** | Does not generalize; would require infinite family of bypass lemmas |
| Composition property (direct Prior composition) | **Low-Medium** | Same mathematical content as sorry; no additional infrastructure to leverage |
| Direct Rabinovich Lemma 5.1 formalization | **Medium** | Requires bridging Lean NF representation to interval patterns; prior INF infrastructure helps but gap is large |

---

## Critical Notes

1. **The n>=2 case** in `existPart_succ` is NOT a separate sorry — it depends on the n=1 case and uses the `bool_eq_of_iff_same` projection. Once n=1 is closed, the boneyard pattern shows n>=2 follows. This is documented in RabinovichGeneralized.lean:445–471.

2. **ExistPart(k) at n=2** (arity 3) is needed inside `existPart_succ_n1_bypass` at k'>0: the depth-(k'+1) 3-var conditions `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn` must be encoded temporally. This is not just ExistPart at n=1.

3. **Induction structure**: The correct induction is `∀ k, CharPart(k) ∧ ExistPart(k)` where ExistPart(k) covers **all n >= 1**. The k=0 case is entirely sorry-free. The k+1 step for n=1 requires ExistPart(k) at n=2 (for the 3-var quantifier conditions), which in turn reduces to n=1 via projection. So the dependency chain is well-founded.

4. **No sorry-deferral patterns are needed** — the mutual induction path, once set up, should be completely sorry-free at each stage, following the same pattern as the boneyard (which had sorry only at the sites that are now closed).
