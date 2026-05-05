# Research Report: Inconsistent Case Resolution (Task 107)

## Session: sess_1777963326_517d4e
## Date: 2026-05-05

---

## Executive Summary

The two sorries at PointInsertion.lean:1886-1887 (`h_ev_b` and `h_ev_untl`) are in `burgess_D0_finite_subset_consistent_incons` -- the inconsistent sub-case of Lemma 2.6 seed consistency. After thorough analysis of Burgess's proof, the axiom system, and the formalization's definition choices, I identify the root cause and recommend a fix.

**Root Cause**: The formalization's `SetDeductivelyClosed` includes a consistency requirement (unlike Burgess's original "deductively closed" which does not). This forces a case split on `SetConsistent ({beta} union B)` that doesn't exist in Burgess's proof. The inconsistent case lacks the BX14 (separation) step because the maximality witness `neg_until(b AND beta, gamma_hat) in A` is not obtainable via the current `BurgessR3Maximal_extension_fails`.

**Recommended Fix**: Case-split on `(untl(b AND beta, gamma_hat)).neg in A` inside the inconsistent case. The neg sub-case calls `burgess_zeta_consistent` directly. The pos sub-case uses BX7 (linearity) to obtain an event whose target includes `q = b AND untl(b, gamma_hat)`.

---

## 1. Burgess's Original Proof (Section 2.6)

Burgess proves: if R(A, B, C) and delta not in B, then D0 is consistent.

His proof (for the formula zeta = S(alpha, beta) AND beta AND ~delta AND U(gamma, beta)):

1. From R-maximality: since delta not in B, there exist beta0 in B, gamma0 in C with ~U(gamma0, beta0 AND delta) in A.
2. WLOG: replace beta, gamma by beta AND beta0, gamma AND gamma0 so that ~U(gamma, beta AND delta) in A.
3. U(gamma, beta) in A (from r-relation).
4. A5a (BX5): U(gamma, beta AND U(gamma, beta)) in A.
5. A4a (BX14): U(beta AND U(gamma, beta) AND ~delta, beta) in A.
6. A3a (BX13): U(beta AND U(gamma, beta) AND ~delta AND S(alpha, beta), beta) in A.
7. 2.2: zeta is consistent.

**Key observation**: Burgess's proof works uniformly because his "DCS" = deductively closed (NO consistency requirement). So the maximality witness (step 1) is ALWAYS available -- even when {delta} union B is inconsistent, because the deductive closure of an inconsistent set IS still a "DCS" in Burgess's sense, hence a valid competitor for maximality.

---

## 2. Why the Formalization Has Two Cases

The formalization defines:
```lean
def SetDeductivelyClosed (S : Set Formula) : Prop :=
  SetConsistent S ∧ ClosedUnderDerivation S
```

So `SetDeductivelyClosed` = consistent + closed under derivation. The maximality clause:
```lean
∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

only quantifies over CONSISTENT extensions. When {beta} union B is inconsistent, `deductiveClosure({beta} union B)` is NOT `SetDeductivelyClosed` (it's inconsistent). So `BurgessR3Maximal_extension_fails` cannot be called -- it requires `h_cons : SetConsistent ({delta} union B)`.

This creates the case split at line 2018:
- **Consistent case** (line 2019-2302): Gets maximality witness, uses BX14, calls `burgess_zeta_consistent`. Works.
- **Inconsistent case** (line 2304-2333): No maximality witness available. Current approach skips BX14, uses BX5 directly with enrichment starting from gamma_hat. FAILS because event does not imply b or untl(b, gamma_hat).

---

## 3. Analysis of the Inconsistent Case Code

The current code (lines 1866-1887):
```lean
let q := Formula.and b (Formula.untl b γ_hat)
let evt := iterated_enrichment h_mcs_A q a_list ha_list γ_hat h_bx5
let event := evt.event'
have h_event_impl_γhat : DerivationTree [] (event.imp γ_hat) := evt.h_impl
-- ...
have h_ev_b : DerivationTree [] (event.imp b) := sorry       -- LINE 1886
have h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat)) := sorry  -- LINE 1887
```

The enrichment is called with guard = q and initial event = gamma_hat. It produces:
- event = gamma_hat AND snce(q, alpha1) AND snce(q, alpha2) AND ...
- untl(q, event) in A
- event -> gamma_hat (h_impl)
- event -> snce(q, alpha_i) (h_snce)

The event does NOT naturally imply b or untl(b, gamma_hat) because:
- gamma_hat is a conjunction of C-formulas
- snce(q, alpha_i) are since-formulas
- Neither type implies B-elements

In contrast, the consistent case uses BX14 to get `untl(q, q AND (b AND beta).neg)`. The initial event is `q AND (b AND beta).neg` which CONTAINS q = b AND untl(b, gamma_hat), so event -> q -> b and event -> q -> untl(b, gamma_hat) are trivial.

---

## 4. Key Discovery: `h_F_beta_neg` is UNUSED

The function `burgess_zeta_consistent` (lines 1265-1359) declares parameter `h_F_beta_neg : Formula.some_future beta.neg in A` at line 1270. However, this parameter is **never referenced** in the function body. It can be safely removed or ignored.

This means `burgess_zeta_consistent` only truly requires:
- h_mcs_A, h_r3m (structural)
- b in B, gamma in C, alpha_list in A (component data)
- **h_neg_until: (untl(b AND beta, gamma)).neg in A** (the critical input)

---

## 5. Recommended Fix: Case-Split on neg_until

### Step 1: Inside `burgess_D0_finite_subset_consistent_incons`, after constructing b and gamma_hat, add:

```lean
-- Case split: is neg_until(b AND beta, gamma_hat) in A?
rcases SetMaximalConsistent.negation_complete h_mcs_A
  (Formula.untl (Formula.and b β) γ_hat) with h_pos | h_neg
```

### Step 2: Neg sub-case (h_neg : (untl(b AND beta, gamma_hat)).neg in A)

Call `burgess_zeta_consistent` directly:
```lean
obtain ⟨event, h_F_event, h_ev_b, h_ev_beta_neg, h_ev_untl, h_ev_snce⟩ :=
  burgess_zeta_consistent h_mcs_A _h_mcs_C h_r3m β h_β_not_B h_F_dummy
    b hb_B a_list ha_list γ_hat hγ_C h_neg
```

Where `h_β_not_B : β ∉ B` is derivable (since beta.neg in B and B is consistent, beta cannot also be in B). And `h_F_dummy` can be any value since the parameter is unused (or remove it from the signature).

This sub-case then proceeds exactly like the consistent case proof.

### Step 3: Pos sub-case (h_pos : untl(b AND beta, gamma_hat) in A)

From h_pos with b AND beta inconsistent (b contains beta.neg): by BX2G (left_mono_until_G) with G((b AND beta) -> psi) for any psi: `untl(psi, gamma_hat) in A` for ALL psi.

Apply BX7 to `untl(q, gamma_hat)` and `untl(gamma_hat.neg, gamma_hat)`:
- D2 = untl(q AND gamma_hat.neg, gamma_hat AND gamma_hat.neg) -- target inconsistent, RULED OUT
- D1 OR D3 must hold

Case split again on D3 = `untl(q AND gamma_hat.neg, q AND gamma_hat)`:
- **D3 in A**: Use enrichment starting from `q AND gamma_hat`. Since event -> q AND gamma_hat -> b (left extraction of q) and event -> q AND gamma_hat -> untl(b, gamma_hat) (right extraction of q). PROBLEM SOLVED.
- **D3 not in A**: Then D1 in A. Use alternative approach (see Section 6 for options).

### D3-not-in-A fallback

If D3 is not in A (meaning (D3).neg in A), we can iterate:
- Apply BX7 with `untl(q AND gamma_hat.neg, gamma_hat)` (= D1) and `untl(gamma_hat.neg, gamma_hat)` to get another three-way split. The analysis shows more guards accumulate but the target structure repeats.

**Alternative for D3-not-in-A**: Use BX14 on D1 with neg(D3):
- D1 = untl(q AND gamma_hat.neg, gamma_hat) in A (guard = q AND gamma_hat.neg, target = gamma_hat)
- neg(D3) = neg(untl(q AND gamma_hat.neg, q AND gamma_hat)) in A (target = q AND gamma_hat)
- BX14 requires SAME target in both formulas. These have DIFFERENT targets (gamma_hat vs q AND gamma_hat). NOT directly applicable.

**Recommended fallback**: If D3 is unreachable in specific contexts, investigate whether BurgessR3Maximal forces D3 to hold. Alternatively, consider restructuring to start the BX7 application with different initial formulas.

---

## 6. Alternative Approaches (if Section 5 proves insufficient)

### 6A: Remove unused parameter and refactor

Remove `h_F_beta_neg` from `burgess_zeta_consistent` signature (it's unused). Then the inconsistent case just needs `h_neg_until` which comes from the neg sub-case.

For the pos sub-case: investigate if BurgessR3Maximal creates a contradiction. Key insight: if untl(psi, gamma_hat) in A for ALL psi, this is a very strong condition that may conflict with maximality for specific gamma choices. This requires careful analysis of how gamma_hat's components interact with the MCS A.

### 6B: Modify BurgessR3Maximal definition

Add a helper lemma:
```lean
theorem burgessR3_univ_implies_false {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_all_until : ∀ γ ∈ C, ∀ ψ : Formula, Formula.untl ψ γ ∈ A) : False
```

If provable, this would show the pos sub-case is unreachable (since pos gives untl(psi, gamma_hat) for all psi, and gamma_hat -> gamma_i for each gamma_i in c_list, giving all-untl for c_list elements but not all of C).

### 6C: Use irr_until axiom (branch-specific)

The branch is named `irr_until`. An axiom `G(phi.neg) -> (untl(phi, psi)).neg` would make `(untl(b AND beta, gamma_hat)).neg in A` derivable when b AND beta is inconsistent. This would make the pos sub-case unreachable (the neg sub-case always holds), eliminating the problem entirely.

**Note**: This axiom IS sound for dense orders (where untl with an impossible guard is always false). It is NOT sound for arbitrary linear orders (where immediate successors make untl(bot, psi) satisfiable). If the formalization targets dense orders or has density as an axiom, this is valid.

---

## 7. Verification Checklist

- [ ] Check if `h_F_beta_neg` can be removed from `burgess_zeta_consistent` without breaking callers
- [ ] Derive `h_β_not_B : β ∉ B` in the inconsistent case (from beta.neg in B + B consistent)
- [ ] Implement neg sub-case calling `burgess_zeta_consistent`
- [ ] For pos sub-case: verify BX7 D3 analysis in Lean (D2 ruled out by BX10 + target inconsistency)
- [ ] If D3 not always in A: implement fallback or prove pos sub-case impossible

---

## 8. Complexity Assessment

- **Neg sub-case**: LOW complexity. Direct application of existing `burgess_zeta_consistent` after case-split. ~30 lines.
- **Pos sub-case (D3 path)**: MEDIUM complexity. BX7 application + D2 elimination + enrichment restart from q AND gamma_hat. ~80 lines.
- **Pos sub-case (D3 fallback)**: HIGH complexity. Requires either proving unreachability or a novel proof technique. May require irr_until axiom.
- **Alternative 6C (irr_until)**: LOW complexity if axiom is added, but changes the logic.

---

## 9. File Paths

- Sorry sites: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` lines 1886-1887
- BurgessR3Maximal definition: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` lines 320-323
- `burgess_zeta_consistent`: PointInsertion.lean lines 1265-1359
- `BurgessR3Maximal_extension_fails`: PointInsertion.lean lines 567-581
- Burgess paper: `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` Section 2.6

---

## 10. Encoding Clarification

The Lean encoding reverses Burgess's argument order for Until/Since:
- **Burgess**: U(target, guard) -- first arg = what eventually holds, second = what holds in between
- **Lean**: `Formula.untl guard target` -- first arg = guard (intermediate), second = target (eventual)
- **BX10**: untl(guard, target) -> F(target) -- extracts the TARGET (second arg)
