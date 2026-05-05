# Full Audit Report: Task 107 — Burgess Chronicle Construction

**Date**: 2026-05-05
**Branch**: `irr_until`
**Build status**: FAILING (1 error in PointInsertion.lean:2894)

---

## 1. Sorry Inventory

**Total sorry sites**: 10 executable sorries across 3 files.

| # | File | Line | Function | What It Proves | Plan Phase |
|---|------|------|----------|----------------|------------|
| 1 | PointInsertion.lean | 1891 | `burgess_D0_finite_subset_consistent_incons` | Pos sub-case: `untl(b /\ beta, gamma_hat) in A` leads to contradiction (since `b -> beta.neg`, so `(b /\ beta) -> bot`) | Phase 2 |
| 2 | PointInsertion.lean | 2483 | `lemma_2_7_seed_consistent` | Full body: consistency of the Lemma 2.7 D0 seed (B union {eta} union untl-formulas union snce-formulas union snce(beta /\ xi, alpha)-formulas) | Phase 3 |
| 3 | PointInsertion.lean | 2922 | `lemma_2_7` (within `have h_xi_consistent`) | Inconsistent case (`{xi} union B` inconsistent): needs `exfalso` but proof is incomplete. Currently causes build error. | Phase 3 |
| 4 | CounterexampleElimination.lean | 412 | `eliminate_C4_counterexample` | C4 hard case: gamma in f(x) AND gamma in f(y), needs BurgessR3 bridging from c2' for adjacent pair (w, w_next) | Phase 5 (C4 co-construction) |
| 5 | CounterexampleElimination.lean | 510 | `eliminate_C4'_counterexample` | C4' hard case: mirror of #4 for Since direction, needs BurgessR3 bridging from c2' for (w_prev, w) | Phase 5 (C4 co-construction) |
| 6 | CounterexampleElimination.lean | 756 | `eliminate_potential_counterexample` (c5_forward) | `c2'` field for EliminationResult after C5 forward elimination | Phase 4 (c2' maintenance) |
| 7 | CounterexampleElimination.lean | 794 | `eliminate_potential_counterexample` (c5_backward) | `c2'` field for EliminationResult after C5' backward elimination | Phase 4 (c2' maintenance) |
| 8 | CounterexampleElimination.lean | 834 | `eliminate_potential_counterexample` (c4_forward) | `c2'` field for EliminationResult after C4 forward elimination | Phase 4 (c2' maintenance) |
| 9 | CounterexampleElimination.lean | 872 | `eliminate_potential_counterexample` (c4_backward) | `c2'` field for EliminationResult after C4' backward elimination | Phase 4 (c2' maintenance) |
| 10 | CounterexampleElimination.lean | 918 | `eliminate_potential_counterexample` (density) | `c2'` field for EliminationResult after density insertion | Phase 4 (c2' maintenance) |
| 11 | ChronicleToCountermodel.lean | 615 | `cantor_bfmcs_restricted_fuc` (forward Until) | Forward Until coherence: `U(phi, psi) in mcs(t) -> exists s > t, psi in mcs(s) /\ guard` — requires full C5 with guard via limit_g | Phase 6 (FUC/FSC) |
| 12 | ChronicleToCountermodel.lean | 619 | `cantor_bfmcs_restricted_fuc` (forward Since) | Forward Since coherence: mirror, requires full C5' with guard | Phase 6 (FUC/FSC) |

**Note**: Sorry #1 and #3 were introduced/modified by the recent convention fix. Sorry #3 causes a build error.

### Sorry Dependency Graph

```
Sorry 1 (Phase 2: pos sub-case) ─────────────┐
Sorry 2 (Phase 3: 2.7 seed consistency) ──────┤
Sorry 3 (Phase 3: 2.7 inconsistent case) ─────┤
                                               ▼
Sorries 4-5 (Phase 5: C4 hard cases) ─── need c2' from upstream
                                               │
Sorries 6-10 (Phase 4: c2' maintenance) ◄──────┘
                                               │
Sorries 11-12 (Phase 6: FUC/FSC) ◄────────────┘
```

Sorries 1, 2, 3 are independent of each other. Sorries 4-10 depend on solving the c2' co-construction problem. Sorries 11-12 depend on everything upstream.

---

## 2. Convention Audit

### Convention Summary

The codebase uses `Formula.untl guard event` (first arg = guard, second = event). Burgess uses `U(event, guard)` (first arg = event, second = guard). So `untl(xi, eta)` in our code equals `U(eta, xi)` in Burgess.

### File-by-File Convention Check

#### PointInsertion.lean

**lemma_2_4** (line 153): `untl gamma beta` where gamma is passed as first arg. The docstring says "U(gamma, beta) in A". The BX10 application extracts F(beta) -- beta is the event (second arg). Convention: **CORRECT** (gamma = guard, beta = event).

**self_accum_until_mcs** (line 189): `untl gamma beta` produces `untl(gamma /\ untl(gamma, beta), beta)`. Guard is enriched, event preserved. Convention: **CORRECT**.

**lemma_2_6_splitting** (line 2375): Uses `burgess_D0_seed A B C beta` where beta is the formula not in B. The seed components include `untl(beta', gamma)` for beta' in B, gamma in C. Here beta' = guard (B-element), gamma = event (C-element). Convention: **CORRECT**.

**lemma_2_7_seed** (line 2436): `B union {eta} union {untl(beta, gamma) : beta in B, gamma in C} union {snce(beta, alpha) : beta in B, alpha in A} union {snce(beta /\ xi, alpha) : beta in B, alpha in A}`. The docstring (lines 2430-2435) explicitly states convention alignment. `eta` = event (Burgess xi), `xi` = guard (Burgess eta). Convention: **CORRECT** (recently fixed).

**lemma_2_7** (line 2492): Hypothesis `h_until : Formula.untl xi eta in A` with `h_xi_not_B : xi not in B`. Output: `eta in D, xi in B'`. Docstring clearly states `xi = guard, eta = event`. Convention: **CORRECT** (recently fixed).

**burgess_D0_seed** (line 1560 area): The D0 seed for Lemma 2.6 includes `{beta.neg} union B union {untl(beta', gamma) : beta' in B, gamma in C} union {snce(beta', alpha) : beta' in B, alpha in A}`. Here beta' in B = guard, gamma in C = event. Convention: **CORRECT**.

**burgess_zeta_consistent** (line 1265): Takes `b gamma` parameters from B and C respectively, with `h_untl_bg : untl(b, gamma) in A` and `h_neg_until : (untl(b /\ beta, gamma)).neg in A`. b = guard (B-element), gamma = event (C-element). Convention: **CORRECT**.

#### CounterexampleElimination.lean

**C5Counterexample** (line 48): `until_mem : Formula.untl xi eta in f(x)`. The witness condition requires `eta in f(y)` (event at y) and `xi in f(z)` (guard at intermediate z). Convention: **CORRECT** (xi = guard, eta = event).

**C5'Counterexample** (line 61): `since_mem : Formula.snce xi eta in f(x)`. Mirror. Convention: **CORRECT**.

**C4Counterexample** (line 260): `neg_until_mem : (Formula.untl gamma delta).neg in f(x)` with `event_mem : delta in f(y)`. The witness is `gamma.neg in f(z)` (negated guard at intermediate point). Convention: **CORRECT** (gamma = guard, delta = event).

**C4'Counterexample** (line 279): Mirror. Convention: **CORRECT**.

**eliminate_C5_counterexample** (line 167): Calls `lemma_2_4 h_mcs_x ce.xi ce.eta ce.until_mem`. This passes xi (guard) as first arg, eta (event) as second. Since `lemma_2_4` has signature `(gamma beta : Formula)` where gamma = guard, beta = event, this is **CORRECT**.

**eliminate_potential_counterexample** (line 731): Uses `untl pc.xi pc.eta` and `snce pc.xi pc.eta` uniformly. Convention: **CORRECT**.

#### ChronicleTypes.lean

**c4** (line 401): `(Formula.untl gamma delta).neg in f(x)` with `delta in f(y)` and witness `gamma.neg in f(z)`. Convention: **CORRECT** (gamma = guard, delta = event).

**c5** (line 427): `Formula.untl gamma delta in f(x)` with witness `delta in f(y)` and guard `gamma in f(z)`. Convention: **CORRECT**.

#### ChronicleConstruction.lean

Uses the structures from ChronicleTypes and CounterexampleElimination. No direct `untl`/`snce` construction beyond what's delegated. Convention: **CORRECT** (inherited).

#### ChronicleToCountermodel.lean

**cantor_bfmcs_restricted_fuc** (line 604): `intro t phi psi _h_sub h_until` where the sorry needs to prove Until/Since coherence. The function takes `phi` and `psi` generically. Convention alignment depends on the caller (parametric representation theorem). No direct convention issue here -- the sorry is about proving the property, not about argument ordering.

#### RRelation.lean

**until_implies_F_in_mcs** (line 84): `Formula.untl gamma delta in A -> F(delta) in A`. Delta = event (second arg). Convention: **CORRECT**.

**until_self_accum_in_mcs** (line 96): `Formula.untl gamma delta -> untl(gamma /\ untl(gamma, delta), delta)`. Convention: **CORRECT**.

**untl_left_mono_thm** (line 1027): Takes derivation `phi -> chi` and `untl(phi, psi) in A`, produces `untl(chi, psi) in A`. First arg = guard. Convention: **CORRECT**.

### Convention Audit Verdict

**No remaining convention misalignments found.** The recent fix to lemma_2_7_seed, lemma_2_7_seed_consistent, and lemma_2_7 correctly aligned all argument positions. All other functions in Chronicle/ already used the correct convention (guard = first arg, event = second arg).

---

## 3. Build Status

**Build result**: FAILING

**Error** (1 total):
```
error: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean:2894:6: Type mismatch
  SetConsistent_of_subset Set.subset_union_left h_cons
has type
  SetConsistent {xi}
but is expected to have type
  False
```

**Root cause**: Inside `have h_xi_consistent : SetConsistent ({xi} : Set Formula) := by` (line 2581), the proof body uses `intro L hL <d>` which destructs `SetConsistent` into a proof of `False`. The `by_cases` at line 2893 branches on `SetConsistent ({xi} union B)`, and in the positive branch, the code tries to return `SetConsistent {xi}` via `SetConsistent_of_subset`, but the current goal is `False` (from the `intro` destruction). The proof structure is fundamentally broken at this point.

**Fix**: The `by_cases h_cons : SetConsistent ({xi} union B)` block at lines 2893-2922 needs restructuring. Either:
- (a) Move it before the `have h_xi_consistent` block and use the result, or
- (b) Inside the `False` goal from `intro L hL <d>`, show that if `{xi} union B` is consistent, then `{xi}` is consistent (contrapositive: `{xi}` inconsistent implies `{xi} union B` inconsistent), and derive the contradiction from there.

**Warnings** (non-blocking):
- Unused variable `h_mcs_C` (line 249)
- Unused simp args (lines 1121, 1177)
- Unused variable `h_F_beta_neg` (line 1270)
- Various other unused variables

---

## 4. Infrastructure Audit

### Existing Infrastructure (what exists and works)

| Function | File | Line | Status | Signature Summary |
|----------|------|------|--------|-------------------|
| `BurgessR3Maximal_extension_fails` | PointInsertion.lean | 567 | Sorry-free | Given R3Maximal(A,B,C), delta not in B, {delta} union B consistent -> not burgessR3(A, DC({delta} union B), C) |
| `BurgessR3Maximal_neg_or_ext_fails` | PointInsertion.lean | 708 | Sorry-free | delta not in B -> delta.neg in B OR (consistent and not burgessR3) |
| `dc_delta_B_controlled` | PointInsertion.lean | 512 | Sorry-free | For phi in DC({delta} union B): either phi in B, or exists beta in B with derivation (beta /\ delta) -> phi |
| `burgess_zeta_consistent` | PointInsertion.lean | 1265 | Sorry-free | Constructs event formula from BX5+BX14+BX13 chain; produces consistency proof |
| `iterated_enrichment` | PointInsertion.lean | 1232 | Sorry-free | Iteratively applies BX13 to pack snce-formulas into Until event |
| `self_accum_until_mcs` | PointInsertion.lean | 189 | Sorry-free | BX5 at MCS level: untl(gamma, beta) in A -> untl(gamma /\ untl(gamma, beta), beta) in A |
| `separation_until_mcs` | PointInsertion.lean | 990 | Sorry-free | BX14 at MCS level |
| `enrichment_until_mcs` | PointInsertion.lean | 1002 | Sorry-free | BX13 at MCS level |
| `until_implies_F_mcs` (also `until_F_mcs`) | PointInsertion.lean | 1014, 179 | Sorry-free | BX10 at MCS level |
| `untl_left_mono_deriv` | PointInsertion.lean | 1182 | Sorry-free | Builds DerivationTree for left_mono_until from phi -> chi derivation |
| `untl_right_mono_deriv` | PointInsertion.lean | 1214 | Sorry-free | Builds DerivationTree for right_mono_until from phi -> psi derivation |
| `untl_left_mono_thm` | RRelation.lean | 1027 | Sorry-free | BX2 at MCS level with theorem-level implication |
| `snce_left_mono_thm` | RRelation.lean | 1045 | Sorry-free | BX2' at MCS level |
| `burgess_D0_seed_consistent` | PointInsertion.lean | 2032 | Sorry-free | Consistency of Lemma 2.6 D0 seed (dispatches to consistent/inconsistent sub-cases) |
| `burgess_D0_finite_subset_consistent` | PointInsertion.lean | 1615 | Sorry-free | Consistent case of D0 seed consistency |
| `burgess_D0_finite_subset_consistent_incons` | PointInsertion.lean | 1825 | **1 sorry** (line 1891) | Inconsistent case: pos sub-case `untl(b /\ beta, gamma_hat) in A` |
| `lemma_2_6_splitting` | PointInsertion.lean | 2375 | Sorry-free | Full Lemma 2.6: produces B', D, B'' with BurgessR3Maximal relations |
| `burgessR3Maximal_from_g_content_sub` | (in RRelation.lean or Frame.lean) | - | Sorry-free | Zorn extension from g_content subset |
| `burgessR3Maximal_extension_exists` | RRelation.lean | - | Sorry-free | Zorn's lemma for extending burgessR3 to maximal |

### Missing Infrastructure (what's needed)

| Function | Needed By | Purpose | Difficulty |
|----------|-----------|---------|------------|
| `linear_until_mcs` | Phase 3 (Lemma 2.7 seed consistency) | BX7 at MCS level: untl(phi, psi) /\ untl(chi, theta) in A -> three-way disjunction in A | Low (pattern follows self_accum_until_mcs) |
| `F_bot_contradiction` or equivalent | Phase 2 (pos sub-case) | Show `F(bot) in A` contradicts MCS consistency: `F(bot) = neg(G(neg bot)) = neg(G(top))`, and `G(top)` is a theorem, so `G(top) in A` and `neg(G(top)) in A` contradicts consistency | Low-Medium |
| `untl_bot_to_F_bot` or `left_mono_until_bot` | Phase 2 (pos sub-case) | From `untl(bot, gamma) in A`, derive `F(gamma) in A` (already available as BX10), but also need the left_mono step from `(b /\ beta) -> bot` | Low (composition of existing tools) |
| c2' co-construction helpers | Phase 4 | For each elimination type (C5, C5', C4, C4', density), construct g-values for new adjacent pairs created by insertion | High (5 cases, each needs seed construction + Zorn) |
| `limit_satisfies_c5_full` | Phase 6 (FUC/FSC) | Full C5 with guard at intermediate points (not just endpoint witness) | Medium-High (needs C3 + limit_g interaction) |

### Infrastructure Assessment

The BX axiom MCS-level wrappers are complete except for `linear_until_mcs` (BX7). All other needed axiom wrappers exist. The main infrastructure gap is the c2' co-construction for the 5 elimination types (sorries 6-10), and the limit C5 full proof (sorries 11-12).

---

## 5. Recommended Order of Operations

### Step 0: Fix Build Error (BLOCKING, 30 min)

**File**: `PointInsertion.lean`, lines 2581-2922
**Issue**: The `have h_xi_consistent` proof body has a structural error where a `by_cases` produces `SetConsistent {xi}` inside a goal that expects `False`.
**Fix**: Restructure the proof. The `by_cases h_cons : SetConsistent ({xi} union B)` should be OUTSIDE the `have h_xi_consistent` block. Pattern:

```lean
by_cases h_cons : SetConsistent ({xi} ∪ B)
· -- Consistent case: {xi} consistent trivially
  have h_xi_consistent : SetConsistent ({xi} : Set Formula) :=
    SetConsistent_of_subset Set.subset_union_left h_cons
  -- ... rest of proof using h_xi_consistent ...
· -- Inconsistent case: xi.neg in B, handle separately
  sorry  -- This is sorry #3, the real mathematical challenge
```

This fix will make the build pass again (with sorries), unblocking all other work.

### Step 1: Add `linear_until_mcs` wrapper (1 hour)

**File**: `PointInsertion.lean` (near line 189, with other BX MCS wrappers)
**Signature**:
```lean
theorem linear_until_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) (phi psi chi theta : Formula)
    (h_untl1 : Formula.untl phi psi ∈ A)
    (h_untl2 : Formula.untl chi theta ∈ A) :
    Formula.untl (Formula.and phi chi) (Formula.and psi theta) ∈ A ∨
    Formula.untl (Formula.and phi chi) (Formula.and psi chi) ∈ A ∨
    Formula.untl (Formula.and phi chi) (Formula.and phi theta) ∈ A
```
**Why**: Needed by Phase 3 (Lemma 2.7 seed consistency). Pattern follows existing MCS wrappers.

### Step 2: Close Sorry #1 — Phase 2 pos sub-case (2-3 hours)

**File**: `PointInsertion.lean`, line 1891
**Function**: `burgess_D0_finite_subset_consistent_incons`, pos sub-case
**Approach**: Plan 57 Phase 2 strategy (Sub-case B):

1. From `b -> beta.neg` (since `beta.neg` is first element of `b_list`), derive `(b /\ beta) -> bot`.
2. Apply `left_mono_until_G` with `(b /\ beta) -> bot`: `untl(b /\ beta, gamma_hat) -> untl(bot, gamma_hat)`.
3. So `untl(bot, gamma_hat) in A`.
4. Apply BX10: `F(gamma_hat) in A`.
5. But also need to show this leads to `F(bot) in A` or a direct contradiction.

Actually, the simpler argument from Plan 57: `(b /\ beta) -> bot` means `b /\ beta` is inconsistent as a guard. BX2 (left_mono_until) with G((b /\ beta) -> bot) (which is G(top) after simplification) gives `untl(b /\ beta, gamma_hat) -> untl(bot, gamma_hat)`. Then `untl(bot, gamma_hat) in A`. Now BX10 gives `F(gamma_hat) in A`, which is not a contradiction.

The CORRECT approach: `untl(bot, gamma_hat)` is semantically unsatisfiable on dense orders because the guard interval (t,s) is nonempty and bot can never hold. But we cannot use this semantic argument directly in the proof system.

**Alternative (from report 58)**: Show `F(bot) in A` by applying BX10 differently. Actually, from `untl(bot, gamma_hat) in A`, apply left_mono with `bot -> any_formula`: `untl(any, gamma_hat) in A`. This means ALL `untl(q, gamma_hat) in A` for any q. In particular, `untl(gamma_hat, gamma_hat) in A`. BX6 absorption: `untl(gamma_hat, gamma_hat /\ untl(gamma_hat, gamma_hat)) -> untl(gamma_hat, gamma_hat)`. This doesn't help.

**Best approach**: Actually, the comment at line 1884 already has the right idea. From `b -> beta.neg` and `untl(b /\ beta, gamma_hat) in A`:
- `(b /\ beta) -> bot` is derivable (since `b -> beta.neg` and `beta /\ beta.neg -> bot`).
- `G((b /\ beta) -> bot)` is a thesis (TG on a theorem).
- BX2G: `G((b /\ beta) -> bot) -> (untl(b /\ beta, gamma_hat) -> untl(bot, gamma_hat))`.
- So `untl(bot, gamma_hat) in A`.
- Left_mono with `bot -> q` for ANY q (explosion): `untl(q, gamma_hat) in A` for any q.
- In particular: `untl(b, gamma_hat) in A` and `untl(b /\ beta, gamma_hat) in A` (already known).
- This gives us the same Until formulas we'd get from the neg sub-case!
- We can then use the SAME Burgess compression argument as the neg sub-case.

This is implementable using existing infrastructure.

### Step 3: Close Sorry #2 — lemma_2_7_seed_consistent (6-9 hours)

**File**: `PointInsertion.lean`, line 2483
**Function**: `lemma_2_7_seed_consistent`
**Approach**: Follow Burgess 1982 p.372 exactly, using BX5+BX7+BX13+BX14:

1. From `xi not in B` + maximality, extract `beta0 in B, gamma0 in C` with `neg(untl(beta0 /\ xi, gamma0)) in A` (via `BurgessR3Maximal_extension_fails` or `BurgessR3Maximal_neg_or_ext_fails`).
2. BX5 on `untl(xi, eta)`: `untl(xi /\ untl(xi, eta), eta) in A`.
3. BX5 on `untl(beta0, gamma0)`: `untl(beta0 /\ untl(beta0, gamma0), gamma0) in A`.
4. BX7 (`linear_until_mcs`): three-way disjunction D1 or D2 or D3.
5. Eliminate D1 and D2 using left_mono + right_mono to produce `untl(beta0 /\ xi, gamma0) in A`, contradicting the negation from step 1.
6. D3 survives: `untl(g1 /\ g2, g1 /\ gamma0) in A` (or the phi-theta form).
7. Apply BX14 separation with `neg(untl(beta0 /\ xi, gamma0))`.
8. Apply BX13 iterated enrichment to pack snce-formulas.
9. Apply BX10 to get `F(event) in A`, proving consistency.

**Dependencies**: Needs `linear_until_mcs` from Step 1.

### Step 4: Close Sorry #3 — lemma_2_7 inconsistent case (2-3 hours)

**File**: `PointInsertion.lean`, line 2922
**Function**: `lemma_2_7`, within `have h_xi_consistent` (after Step 0 restructuring)
**Issue**: When `{xi} union B` is inconsistent, `xi.neg in B`. Then `xi in B'` is unprovable because xi cannot be in any consistent set if xi is itself inconsistent.

**Resolution options**:
- (a) **Add hypothesis**: Add `SetConsistent ({xi} union B)` as a precondition to `lemma_2_7`. Then the inconsistent case is eliminated. Check that the call site (`eliminate_C5_counterexample` or wherever lemma_2_7 is called) can supply this.
- (b) **Prove from hypotheses**: Show that `untl(xi, eta) in A` and `xi not in B` with `BurgessR3Maximal(A, B, C)` implies `{xi} union B` is consistent. This would require showing that `xi.neg in B` leads to a contradiction with the other hypotheses.
- (c) **Case split at call site**: At the C5 elimination call site, if `{xi} union B` is inconsistent, handle it directly without calling lemma_2_7 (e.g., the guard failure is already witnessed by xi.neg in B).

**Recommendation**: Option (a) is safest. The hypothesis `SetConsistent ({xi} union B)` is natural (it's exactly the condition under which BurgessR3Maximal_extension_fails applies). At the call site, the case where `{xi} union B` is inconsistent (i.e., xi.neg in B) means the guard xi is already negated in the interval, which may mean the C5 counterexample doesn't actually require lemma_2_7.

### Step 5: Close Sorries #4-5 — C4 hard cases (3-5 hours)

**File**: `CounterexampleElimination.lean`, lines 412, 510
**Functions**: `eliminate_C4_counterexample`, `eliminate_C4'_counterexample`
**Issue**: Hard case where gamma in f(x) AND gamma in f(y). Need BurgessR3Maximal bridging from c2' for adjacent pair.
**Approach**: From c2' (which gives `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`), and gamma in f(w) and gamma in f(w_next):
- If gamma not in g(w,w_next): use `BurgessR3Maximal_extension_fails` to get negation witness, which gives us the needed MCS D with gamma.neg.
- If gamma in g(w,w_next): gamma in all intermediate MCS (from c2' properties), so we can use the interval function to find or construct D.
**Dependencies**: Needs c2' to be available (which it is via the omega_chain invariant that threads c2').

### Step 6: Close Sorries #6-10 — c2' maintenance (8-12 hours)

**File**: `CounterexampleElimination.lean`, lines 756, 794, 834, 872, 918
**Function**: `eliminate_potential_counterexample`, `c2'` field
**Issue**: After each elimination step (C5, C5', C4, C4', density), must prove that the resulting chronicle still satisfies c2' (BurgessR3Maximal for all adjacent pairs).
**Approach**: For each elimination type:
1. **C5/C5' elimination** (insert point beyond/before all domain points): The new point creates one new adjacent pair. Construct g-value for this pair using `lemma_2_4`'s interval DCS output or `burgessR3Maximal_from_g_content_sub`.
2. **C4/C4' elimination** (insert midpoint between x and y): Breaks one adjacency (x,y) into two: (x,z) and (z,y). Need to construct g(x,z) and g(z,y) from g(x,y) using `lemma_2_6_splitting`.
3. **Density insertion** (insert midpoint): Same as C4 case structurally.

Each case requires modifying the elimination function to co-construct g-values alongside the new f-values. This is the core of Plan 57's Phase 4-5.

**Dependencies**: Sorries 1-3 should be closed first (they are in PointInsertion.lean which provides the lemma_2_6_splitting and lemma_2_7 tools).

### Step 7: Close Sorries #11-12 — FUC/FSC (6-9 hours)

**File**: `ChronicleToCountermodel.lean`, lines 615, 619
**Function**: `cantor_bfmcs_restricted_fuc`
**Issue**: Need full C5 with guard at intermediate points, not just the weak C5 (endpoint witness only).
**Approach**: 
1. Prove `limit_satisfies_c5_full`: From limit_c5_weak (endpoint exists) + limit_c3 (interval decomposition) + limit_g (interval function), show that the guard holds at all intermediate domain points.
2. Transfer through Cantor isomorphism.
**Dependencies**: All upstream sorries must be closed first (c2' maintenance enables limit_c3 and limit_g to work correctly).

---

## 6. Risk Assessment

### Critical Blockers

1. **Build error at line 2894** (BLOCKING): Must be fixed first. Straightforward restructuring.

2. **Sorry #3 — inconsistent case in lemma_2_7** (HIGH RISK): The mathematical question is whether `{xi} union B` can be inconsistent when `untl(xi, eta) in A` and `xi not in B`. If it CAN be inconsistent (which the extensive comments in the code suggest is possible on discrete orders), then lemma_2_7 as stated may need an additional hypothesis. This affects the entire C5 elimination pathway.

3. **c2' co-construction (sorries #6-10)** (HIGH EFFORT): This is the largest block of work. Each of the 5 elimination types needs g-value co-construction. Plan 57 addresses this but estimates 10-14 hours for Phases 4-5 combined.

### Medium Risks

4. **D2 elimination in lemma_2_7_seed_consistent**: The comments at lines 2456-2462 question whether `beta0 /\ untl(beta0, gamma0) -> gamma0` is derivable for the right_mono step. If not, the BX7 three-way argument may need a different path to eliminate D2.

5. **FUC/FSC dependency chain**: Sorries 11-12 depend on ALL upstream work being completed. Any blocker in Steps 2-6 cascades to FUC/FSC.

### Low Risks

6. **Convention alignment**: Audit found NO remaining misalignments. This is resolved.

7. **BX axiom availability**: All needed axioms (BX2, BX3, BX5, BX7, BX10, BX13, BX14) have sorry-free soundness proofs. Only `linear_until_mcs` (BX7 MCS wrapper) is missing, and it's a straightforward wrapper.

### Unknowns

- Whether the pos sub-case in Sorry #1 can be closed with the `untl(bot, gamma_hat)` approach (the guard becomes trivially satisfiable on all orders after left_mono with explosion).
- Whether the inconsistent case in Sorry #3 arises in practice at the C5 elimination call site, and if so, whether it can be handled without lemma_2_7.
- The exact interaction between c2' maintenance and the omega_chain construction — the current `omega_chain` signature requires `c0 /\ c2'` but the c2' fields are all sorry.

---

## Summary

- **12 executable sorries** across 3 files (3 in PointInsertion, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel)
- **1 build error** (type mismatch in lemma_2_7, line 2894)
- **0 convention misalignments** remaining (recent fix was correctly applied)
- **1 missing BX wrapper** (`linear_until_mcs`)
- **Critical path**: Fix build -> Step 1 (linear_until_mcs) -> Steps 2-3 (PointInsertion sorries) -> Step 4 (inconsistent case) -> Steps 5-6 (CounterexampleElimination sorries) -> Step 7 (FUC/FSC)
- **Estimated total effort**: 25-40 hours
