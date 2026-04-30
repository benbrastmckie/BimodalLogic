# Teammate D Findings: Strategic Assessment + Lean Infrastructure Gaps

**Task**: 107
**Artifact**: 48 (teammate d)
**Date**: 2026-04-29
**Focus**: Horizons — Lean infrastructure gaps, type signature check, sorry site analysis, critical path

---

## Question 1: Reusable Lean Helpers and Patterns from lemma_2_6_splitting

### What the splitting proof does

`lemma_2_6_splitting` (PointInsertion.lean:913-938) is sorry-free. Its seed is:

```
{β.neg} ∪ g_content(A) ∪ h_content(C)
```

The consistency of this seed is proved by `splitting_seed_consistent` (PointInsertion.lean:894-911), which reduces to `dcs_neg_union_consistent` using:
1. `g_content_sub_B_of_BurgessR3Maximal` — gives `g_content(A) ⊆ B`
2. `h_content_sub_B_of_BurgessR3Maximal` — gives `h_content(C) ⊆ B`
3. The seed is then a subset of `{β.neg} ∪ B`, and `dcs_neg_union_consistent` closes it because `β ∉ B`.

After Lindenbaum, the proof extracts `β.neg ∈ D`, `g_content(A) ⊆ D`, `h_content(C) ⊆ D`, then derives `g_content(D) ⊆ C` from `h_content(C) ⊆ D` via `h_content_subset_implies_g_content_reverse`.

### Can the same pattern be adapted for Lemma 2.7?

**Partially, but not directly.** The key difference: Lemma 2.6 needs `β.neg ∈ D` (negated formula), while Lemma 2.7 needs `xi ∈ D` (positive formula). The consistency argument via `dcs_neg_union_consistent` exploits the negation structure — it shows `{β.neg} ∪ B` is consistent by using `β ∉ B`. There is no analogous helper for the positive case `{xi} ∪ B`.

The Lemma 2.7 proof needs a different seed consistency argument. The handoff's BX5+BX7+BX13 chain is the correct approach: derive `F(xi ∧ gamma₀) ∈ A` from the BX7 D3 disjunct, then use `forward_temporal_witness_seed_consistent` (from WitnessSeed.lean) to get `{xi ∧ gamma₀} ∪ g_content(A)` consistent. This seed gives `xi ∈ D` via conjunction elimination.

**Reusable infrastructure from lemma_2_6_splitting:**
- `burgessR3Maximal_from_g_content_sub` — can be called after Lindenbaum to get `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` from `g_content(A) ⊆ D` and `g_content(D) ⊆ C`.
- `h_content_subset_implies_g_content_reverse` — if we can show `h_content(C) ⊆ D`, we immediately get `g_content(D) ⊆ C`.
- The Lindenbaum-then-extract pattern is identical: `set_lindenbaum` + explicit membership extraction.

---

## Question 2: What Infrastructure Is Missing

### 2a. Finite conjunction consistency → seed consistency

**Does the codebase have this?** No general "finite conjunction consistency implies seed consistency" lemma exists in the Chronicle files. The closest is `splitting_seed_consistent` itself, which uses the ad hoc route via `B`-inclusion. For Lemma 2.7, a new argument is needed: show that any finite subset `L ⊆ {xi ∧ gamma₀} ∪ g_content(A)` is consistent, using `F(xi ∧ gamma₀) ∈ A` (from BX10 on the D3 disjunct). This argument flows through `forward_temporal_witness_seed_consistent`, which already handles the seed `{target} ∪ g_content(M)` when `F(target) ∈ M`. **This helper exists and is directly applicable.**

### 2b. MCS-level lemmas for A1a/A2a (conjunction elimination for Until)

**Does the codebase have this?** Yes. `conj_left_mcs` (PointInsertion.lean:289) and the symmetric right version provide conjunction elimination at MCS level. There is also `conj_mcs` (PointInsertion.lean:209) for conjunction introduction. These are sufficient for extracting `xi` from `xi ∧ gamma₀ ∈ D`.

### 2c. `U(p, q∧r) → U(p, q) ∧ U(p, r)` decomposition

**Does the codebase have this?** Not as a named lemma. However, `right_mono_until_mcs` (PointInsertion.lean:973) can be applied twice: using `⊢ (q∧r) → q` and `⊢ (q∧r) → r` to extract each conjunct from the Until eventuality. These derivation tree witnesses can be built from `lce_imp` and `rce_imp`. **The decomposition is achievable with existing infrastructure, just not pre-packaged.**

### 2d. Converse of enrichment_until (BX13)

BX13 states: `p ∧ U(phi,psi) → U(phi, psi ∧ S(phi,p))`. The converse would be: `U(phi, psi ∧ S(phi,p)) → p ∧ U(phi,psi)` (or similar). **This does not exist and is not needed for Lemma 2.7.** The handoff's strategy uses BX13 in the forward direction to argue that `U(xi, beta ∧ eta) ∈ A` for each `beta ∈ g_content(A)`. The helper `untl_conj_eta_of_g_content` (PointInsertion.lean:990) already packages this using BX3 (right_mono_until), so BX13 is not even the direct route — BX3 + G(beta) suffices to get `U(xi, beta ∧ eta) ∈ A`.

### 2e. Missing infrastructure for the BX5+BX7 chain

The BX5 step is covered by `self_accum_until_mcs` (PointInsertion.lean:189). The BX7 step (linear_until) is **not present as an MCS-level lemma**. A `linear_until_mcs` helper does not appear in local search results. BX7 is a 4-clause disjunction axiom; applying it at MCS level requires chaining through `SetMaximalConsistent.disjunction_property` or negation completeness. This is a **missing helper that needs to be built**.

### 2f. The eta-in-B' gap: missing infrastructure

Getting `eta ∈ B'` (the second conjunct of the Lemma 2.7 conclusion) is the deeper missing piece. The handoff proposes:

> Step 9: `eta ∈ B'` from `U(xi, beta∧eta) ∈ A` for all beta ∈ B, plus maximality

The helper `untl_conj_eta_of_g_content` gives `U(xi, G(beta) ∧ eta) ∈ A` for `beta ∈ g_content(A)`, not for `beta ∈ B` directly. Since `g_content(A) ⊆ B` and `B` is BurgessR3Maximal (not negation-complete), the argument needs `burgessR3` or maximality of B' to conclude `eta ∈ B'`. **No lemma connects `U(xi, beta∧eta) ∈ A` (for beta ∈ B) to `eta ∈ B'`.** This is the principal missing piece.

---

## Question 3: Type Signature Check for lemma_2_7

The current theorem statement (PointInsertion.lean:1037-1050):

```lean
theorem lemma_2_7 {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta ∈ A)
    (h_eta_not_B : eta ∉ B) :
    ∃ B' D B'' : Set Formula,
      BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      SetMaximalConsistent D ∧
      xi ∈ D ∧
      eta ∈ B'
```

**Assessment: The signature is correct relative to Burgess's Lemma 2.7 conclusion.**

- `xi ∈ D`: matches Burgess (the splitting MCS contains the guard formula)
- `eta ∈ B'`: matches Burgess (the interval from A to D contains the eventuality formula)
- `BurgessR3Maximal A B' D` and `BurgessR3Maximal D B'' C`: produces two adjacent intervals via the splitting, consistent with the chronicle structure

The docstring also matches: "produce B', D, B'' with BurgessR3Maximal(A, B', D), BurgessR3Maximal(D, B'', C), xi ∈ D and eta ∈ B'."

One potential concern: the signature does not require `g_content(D) ⊆ C` or `g_content(A) ⊆ D` explicitly, but these are consequences of `BurgessR3Maximal A B' D` combined with `g_content A ⊆ C`. Downstream callers likely derive these from `BurgessR3Maximal` directly. **The type signature is correct and does not need revision.**

---

## Question 4: CounterexampleElimination.lean Sorry Sites

### Current sorry sites

CounterexampleElimination.lean has exactly **2 sorry sites** (confirmed by grep):

**Line 412** (in `eliminate_C4_counterexample`, sub-case 1a — C4 hard case):
```
-- Hard case: γ ∈ f(x) and γ ∈ f(y). Need BurgessR3 bridging from c2'.
-- Phase 8: Restore this proof once c2' is re-established at finite stages
-- (currently c2' is removed from omega_chain invariant per Phase 7).
-- The proof requires BurgessR3Maximal for (f(w), g(w,w_next), f(w_next)).
sorry
```

**Line 510** (in `eliminate_C4'_counterexample`, sub-case 1a — C4' hard case, mirror):
```
-- Hard case: γ ∈ f(x) and γ ∈ f(y). Need BurgessR3 bridging from c2' (Since direction).
-- Phase 8: Restore this proof once c2' is re-established at finite stages
sorry
```

### What these sorries require

Both are in the "hard case" of C4/C4' counterexample elimination: when the guard formula `γ` is present at both `f(x)` and `f(y)`, the proof needs `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))` for an adjacent pair `(w, w_next)`. This is the `c2'` chronicle invariant that was removed in Phase 7.

**These are C4/C4' sites, not C5 sites.** They do not call `lemma_2_7`. They call `lemma_2_6_splitting` (via BurgessR3 bridging) conceptually, but the actual proof uses `burgessR3_gamma_not_in_B` or similar lemmas to derive `¬γ ∈ f(z)` for some intermediate MCS.

### Can these be closed without Lemma 2.7?

**Yes, potentially.** The C4 hard case has already laid out the structural argument:
1. Find `w_max = max {w ∈ dom | x ≤ w < y ∧ neg(untl(γ,δ)) ∈ f(w)}` (done)
2. Find `w_next = succ(w_max)` in dom (done)
3. At `(w_max, w_next)`, need `BurgessR3Maximal(f(w_max), g(w_max, w_next), f(w_next))`
4. From BurgessR3Maximal + `untl(γ,δ) ∈ f(w_next)` + `δ ∈ f(y)`, derive `¬γ ∈ B` for some B
5. Use `lemma_2_6_splitting` (already sorry-free) to produce D with `¬γ ∈ D`

Steps 3 and 4 require `c2'` (the chronicle invariant that adjacent pairs have a BurgessR3Maximal witness). The sorry is blocked by `c2'` removal, not by any missing Lean lemma.

**The path forward is**: restore `c2'` in the omega-chain construction (Phase 8 as labeled in the comments), not prove new lemmas.

---

## Question 5: Is Lemma 2.7 on the Critical Path?

### Dependency trace

The critical path for `dd_countermodel_chronicle` (ChronicleToCountermodel.lean:640) flows:

```
dd_countermodel_chronicle
  -> cantor_bfmcs_restricted_fuc (2 sorries: FUC forward Until/Since guard)
     -> limit_satisfies_c5_full (needs C3 + limit_g guard propagation)
        -> ChronicleConstruction.lean (limit construction, sorry-free)
           -> omega_chain invariant (needs c2' for BurgessR3 bridging)
              -> eliminate_C4_counterexample (2 sorries: c2' missing)
```

Separately:
```
dd_countermodel_chronicle
  <- (not directly)
  -> cantor_bfmcs_restricted_buc (sorry-free via C4 contrapositive)
```

**Does anything actually call `lemma_2_7`?** Searching all Chronicle files for `lemma_2_7` references shows it is defined in PointInsertion.lean but **has no callers in the current codebase.** The only references are the theorem definition itself and the docstring comments.

### What Lemma 2.7 is needed for

Burgess uses Lemma 2.7 in the proof of Lemma 2.10 (C5 counterexample elimination), specifically for the case where the C5 counterexample occurs at a non-initial step with `eta ∉ B` for all intervals in the chain. This is the sub-case 3 of C5 elimination that requires the full splitting with `xi ∈ D` AND `eta ∈ B'`.

**Currently**, `eliminate_C5_counterexample` (CounterexampleElimination.lean:167) uses `lemma_2_4` (the simpler splitting from PointInsertion.lean) and is sorry-free. It only produces `eta ∈ C` (the endpoint MCS), not `eta ∈ B'` (the interval DCS).

### Critical path assessment

**Lemma 2.7 is NOT on the current critical path** to close the 4 remaining sorries. The 4 open sorry sites are:

| # | File | Site | Blocks |
|---|------|------|--------|
| 1 | RRelation.lean:772 | Zorn inconsistent ClosedUnderDerivation case | BurgessR3Maximal existence |
| 2 | CounterexampleElimination.lean:412 | C4 hard case (c2' missing) | eliminate_C4 |
| 3 | CounterexampleElimination.lean:510 | C4' hard case (c2' missing) | eliminate_C4' |
| 4 | ChronicleToCountermodel.lean:615,619 | FUC/FSC guard at intermediate points | dd_countermodel_chronicle |

None of these 4 sorry sites calls `lemma_2_7`. The FUC/FSC sorry sites (4) need C3 + limit_g (the g-function for intervals in the limit chronicle), which is independent of Lemma 2.7.

**However**, Lemma 2.7 would become relevant if the C5 elimination is strengthened to handle sub-case 3 (where `eta ∉ B` for all adjacent pairs in the current chain). The current `eliminate_C5_counterexample` using `lemma_2_4` may not produce a strong enough witness for the full C5 condition with guard propagation. When Phase 8 restores `c2'` and the FUC guard proof attempts to establish intermediate point membership, it will likely need Lemma 2.7 (or at minimum, the full BurgessR3Maximal splitting with `eta ∈ B'`).

---

## Summary of Findings

**Strategic assessment:**

1. **The 4 current sorry sites do not depend on Lemma 2.7.** Lemma 2.7 has zero callers. Phase 6 (implementing Lemma 2.7) is not on the critical path for the next unblocking step.

2. **The critical next unblocking step is Phase 8: restoring `c2'`.** The C4/C4' sorry sites (2 of 4) are blocked purely by `c2'` removal from the omega-chain invariant. Restoring it would close 2 sorries. The Zorn technicality (RRelation.lean:772) is a 3rd blocker that is independent. The FUC/FSC sorry (4th) requires the full C3+limit_g treatment.

3. **The lemma_2_7 type signature is correct.** It matches Burgess's Lemma 2.7: `xi ∈ D` and `eta ∈ B'`, with two BurgessR3Maximal witnesses splitting the interval. No revision needed.

4. **Missing Lean infrastructure for Lemma 2.7** (when Phase 6 is attempted): the main gaps are (a) `linear_until_mcs` — a BX7 at MCS level via disjunction property — and (b) a lemma connecting `U(xi, beta∧eta) ∈ A` for all `beta ∈ B` to `eta ∈ B'`. The BX5 step is covered by `self_accum_until_mcs`. Seed consistency for D can use `forward_temporal_witness_seed_consistent` once `F(xi ∧ gamma₀) ∈ A` is established via BX10.

5. **Reusable patterns**: after getting `g_content(A) ⊆ D` and `g_content(D) ⊆ C`, the `burgessR3Maximal_from_g_content_sub` + `h_content_subset_implies_g_content_reverse` combination from lemma_2_6_splitting applies verbatim. The Lindenbaum + extraction pattern is identical.

6. **No sorry deferral recommended.** Phase 6 (Lemma 2.7) should be deferred until after Phase 8 (c2' restoration) succeeds, since Lemma 2.7 has no current callers and Phase 8 is the lower-hanging fruit. If Phase 8 reveals that Lemma 2.7 is needed for the full FUC guard proof, it should be implemented then with the full BX5+BX7+BX13 chain (Option A from handoff), not with a sorry placeholder.

---

## Key Files Referenced

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — `lemma_2_7` (line 1037), `self_accum_until_mcs` (line 189), `right_mono_until_mcs` (line 973), `untl_conj_eta_of_g_content` (line 990), `lemma_2_6_splitting` (line 913)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — sorry sites at lines 412, 510 (C4/C4' hard cases)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — sorry sites at lines 615, 619 (FUC/FSC)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — sorry site at line 772 (Zorn inconsistent case)
- `/home/benjamin/Projects/ProofChecker/specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/08_phase6-burgess-seed-handoff.md`
