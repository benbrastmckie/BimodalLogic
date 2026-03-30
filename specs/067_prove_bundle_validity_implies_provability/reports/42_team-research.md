# Team Research Report: g_content Sorry in boundary_implies_k_plus_d_bounded

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates, 1 failed - supplemented by lead)
**Session**: sess_1774889317_ce930b

## Summary

**CRITICAL FINDING**: The theorem `boundary_implies_k_plus_d_bounded` (and its caller `boundary_implies_k_lt_B`) is likely **mathematically FALSE** in the g_content/Lindenbaum case. The g_content sorry is not merely hard to prove — it's in a theorem whose statement is incorrect. A **much simpler proof** exists using the already-proven `restricted_forward_chain_F_resolves` lemma that makes the entire boundary analysis unnecessary.

## Key Findings

### 1. g_nesting_depth Infrastructure is Straightforward (Teammate A, High Confidence)

The definitions are simple analogs of existing f_nesting_depth:

```lean
def g_nesting_depth : Formula → Nat
  | .all_future inner => 1 + g_nesting_depth inner
  | _ => 0

def max_G_depth_in_closure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup g_nesting_depth

def iter_G : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.all_future (iter_G n phi)
```

Key properties:
- G is a **primitive constructor** (unlike F = ¬G¬), making the definition simpler
- `g_nesting_depth(iter_F d theta) = 0` (F-formulas are imp-patterns, not all_future)
- `max_G_depth_deferralClosure = max(max_G_depth_in_closure, 1)` (floor from G_neg_neg_bot)

### 2. The Backward-Trace Lemma is Unprovable (Teammate A + Lead, Low → Medium Confidence)

The proof sketch assumes: if `iter_F d theta ∈ chain(k'+1)` and `iter_F (d+1) theta ∉ chain(k')`, then the formula entered via g_content (i.e., `G(iter_F d theta) ∈ chain(k')`).

**This is FALSE.** Analysis of the seed structure `constrained_successor_seed_restricted` (SuccExistence.lean:356) shows 5 components:
1. `g_content(u)` — psi where G(psi) ∈ u
2. `deferralDisjunctions(u)` — chi ∨ F(chi) where F(chi) ∈ u
3. `p_step_blocking_formulas_restricted` — P-related
4. `boundary_resolution_set` — psi where F(psi) ∈ u, psi ∉ u
5. `f_content(u)` — psi where F(psi) ∈ u

When `iter_F (d+1) theta ∉ chain(k')`:
- f_content: ✗ (requires F(iter_F d theta) = iter_F (d+1) theta ∈ chain(k'))
- boundary_resolution_set: ✗ (same reason)
- deferralDisjunctions: ✗ (structural mismatch: iter_F d theta is `.imp(.all_future ..)..`, not `.imp(.imp ..)(.imp ..)`)
- p_step_blocking: ✗ (structural mismatch: all_past vs imp)
- g_content: possible — but also **Lindenbaum extension** can add it!

Lindenbaum extends the seed to an MCS within deferralClosure. `iter_F d theta ∈ deferralClosure`, so Lindenbaum can add it **without** G(iter_F d theta) being in chain(k').

### 3. boundary_implies_k_plus_d_bounded is Likely FALSE (Lead Analysis, High Confidence)

**Counterexample sketch**: phi = F(p), theta = p, d = 1.

- `closure_F_bound(F(p)) = max(1, 1) + 1 = 2`
- `iter_F 1 p = F(p) ∈ deferralClosure(F(p))` ✓
- `iter_F 2 p = F(F(p)) ∉ deferralClosure(F(p))` (f_depth 2 > max 1)
- Boundary condition is trivially satisfied for all k

The theorem claims: `k + 1 ≤ max(1, 1) = 1`, i.e., `k = 0`.

But **F(p) can be in chain(k) for any k** via Lindenbaum:
- chain(k+1) seed always includes `p` (via f_content if F(p) ∈ chain(k))
- Lindenbaum can independently choose F(p) ∈ chain(k+1) (F(p) and p are consistent)
- This gives k = 2 with k + d = 3 > 1, violating the bound

**Corroboration**: Line 3682 of SuccChainFMCS.lean explicitly documents: "restricted_bounded_witness (depended on FALSE theorems)" — the original version was already known to be flawed and was removed in task 56.

### 4. A MUCH Simpler Proof Exists (Lead Analysis, Very High Confidence)

The lemma `restricted_forward_chain_F_resolves` (line 2741) already proves:

```lean
theorem restricted_forward_chain_F_resolves (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1)
```

**If F(psi) ∈ chain(k), then psi ∈ chain(k+1).** This is already proven!

The bounded witness follows by simple induction on d:

```lean
theorem iter_F_resolves_in_d_steps (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
    (h_d_ge : d ≥ 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
    theta ∈ restricted_forward_chain phi M0 (k + d) := by
  induction d generalizing k with
  | zero => omega
  | succ n ih =>
    have h_resolved := restricted_forward_chain_F_resolves phi M0 k (iter_F n theta)
      (by rw [← iter_F_succ]; exact h_iter_in)
    match n with
    | 0 => simpa [iter_F_zero] using h_resolved
    | m + 1 =>
      have := ih (k + 1) (by omega) h_resolved
      convert this using 1; omega
```

Then `restricted_forward_chain_forward_F` becomes trivial:

```lean
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m :=
  ⟨n + 1, by omega, restricted_forward_chain_F_resolves phi M0 n psi h_F⟩
```

### 5. Dependency Chain to Remove

The following theorems become unnecessary:

| Theorem | Lines | Status | Replacement |
|---------|-------|--------|-------------|
| `boundary_implies_k_plus_d_bounded` | 2807-2949 | sorry (g_content) | DELETE |
| `boundary_implies_k_lt_B` | 2961-2998 | depends on above | DELETE |
| `restricted_bounded_witness_wf` | 3197-3353 | uses k_lt_B | REPLACE with simple induction |
| `restricted_bounded_witness` | 3362-3378 | wrapper | REPLACE |
| `restricted_forward_chain_iter_F_witness` | 3385-3459 | uses above | REPLACE |

Replace with: `iter_F_resolves_in_d_steps` (~15 lines) and trivial `restricted_forward_chain_forward_F` (~3 lines).

**Net change**: Remove ~350 lines of complex fuel-based proof with sorry, replace with ~20 lines of clean inductive proof.

## Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Teammate A says g_nesting_depth infrastructure is needed | NOT needed — the entire approach changes |
| Previous plans assumed backward tracing viable | Backward tracing is unnecessary with F_resolves |
| Plan 14 focuses on completing the sorry | The sorry should be DELETED, not completed |

## Recommendations

### Primary Recommendation: Replace, Don't Fix

1. **DELETE** `boundary_implies_k_plus_d_bounded` and `boundary_implies_k_lt_B`
2. **REPLACE** `restricted_bounded_witness_wf` with `iter_F_resolves_in_d_steps`
3. **SIMPLIFY** `restricted_forward_chain_forward_F` to use F_resolves directly
4. **DO NOT** add g_nesting_depth infrastructure (unnecessary for this task)
5. **Verify** all callers of `restricted_forward_chain_forward_F` still work (signature unchanged)

### Secondary: Keep g_nesting_depth for Future Use

If G-depth infrastructure is needed elsewhere (e.g., backward chain P-analysis), the definitions from Teammate A's findings are ready. But they're not needed for task 67.

### Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Callers break with signature change | M | L | restricted_forward_chain_forward_F signature is UNCHANGED |
| iter_F_resolves_in_d_steps harder than sketched | L | L | restricted_forward_chain_F_resolves does the heavy lifting |
| Other theorems depend on boundary_implies_k_lt_B | H | L | Grep confirms only restricted_bounded_witness_wf uses it |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | g_nesting_depth definitions | completed | high | Exact Lean definitions, Lindenbaum entry path warning |
| B | G-propagation bound | failed (API error) | N/A | Supplemented by lead analysis |
| Lead | Proof viability analysis | completed | very high | Discovered F_resolves shortcut, counterexample |

## References

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2741` — restricted_forward_chain_F_resolves
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2807-2949` — boundary_implies_k_plus_d_bounded (sorry)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:3682` — dead code documentation
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:356` — seed definition
- `specs/067_prove_bundle_validity_implies_provability/reports/42_teammate-a-findings.md` — Teammate A report
