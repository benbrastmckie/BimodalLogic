# Teammate D Findings: Concrete Implementation Plan

**Task**: 109 — Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-21
**Role**: Horizons researcher — implementation plan design
**Confidence**: HIGH

## Executive Summary

The `until` branch already uses **full reflexive semantics** (G/H: `<=`, Until/Since witness: `<=`) with BX8 present. It has exactly **5 sorry sites on the critical path** to completeness (all in `RootScopedChain.lean`), plus auxiliary sorries in non-critical files. The `irr_until` branch uses irreflexive semantics (G/H: `<`, Until/Since witness: `<`) with BX8 removed.

The recommended strategy is: **(1) Complete reflexive completeness on the `until` branch by closing the 5 critical sorries, (2) Derive irreflexive completeness via conservative extension or operator translation.**

---

## Part 1: Reflexive Completeness — Sorry-by-Sorry Analysis

### Critical Path Sorry Inventory (until branch)

All 5 critical sorries are in `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (1681 lines). The completeness theorem in `Completeness.lean` is sorry-free and depends entirely on `dd_countermodel`, which calls three coherence theorems that contain the sorries.

| # | Line | Theorem | Type | Difficulty |
|---|------|---------|------|------------|
| 1 | 1111 | `fwd_chain_forward_F` | F-resolution termination | HARD |
| 2 | 1138 | `dd_bfmcs_restricted_tc` (backward case) | F in backward chain | MEDIUM |
| 3 | 1145 | `dd_bfmcs_restricted_tc` (P-resolution) | P-resolution symmetry | MEDIUM |
| 4 | 1153 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence | MEDIUM |
| 5 | 1160 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence | MEDIUM (depends on #1) |

### Key Finding: The `until` Branch Is Already Reflexive

The `until` branch Truth.lean already has:
- `all_future`: `t <= s` (reflexive G)
- `all_past`: `s <= t` (reflexive H)
- `untl` witness: `t <= s` (reflexive Until)
- `snce` witness: `s <= t` (reflexive Since)
- BX8 (`refl_intro_until`/`refl_intro_since`): present in Axioms.lean
- BX1 (`temp_t_future`): G(phi) -> phi is an axiom

This means the semantic change recommended in reports 09-10 is **already done** on the `until` branch. The work is purely about closing the 5 chain construction sorries.

### Key Finding: `until` Branch Has Strong Infrastructure

Already proved sorry-free on the `until` branch:
- `OrderedSeedConsistency.lean` (255 lines): The core mathematical lemma
- `enriched_resolving_seed_consistent`: If `F(psi /\ alpha) in M`, then `{psi, alpha} U g_content(M)` is consistent
- `defect_resolving_seed_consistent`: Wrapper for the chain construction
- `defect_fwd_step` / `defect_fwd_step_mcs`: Lindenbaum extension of enriched seed
- `discharge_single_step`, `discharge_two_step`, `discharge_multi_step`: Multi-target discharge
- `target_stays_direct_in_fold`: When target is BX11-earliest, it's guaranteed in the successor
- `preserving_fwd_step_F_preserved`: F-obligations preserved at each forward step
- `fwd_chain_F_persistent`: F(chi) in chain(m) implies F(chi) in chain(n) for m <= n
- `FF_imp_F` / `FF_imp_F_mcs`: F(F(psi)) -> F(psi) derivable in BX
- `phi_imp_F_phi`: phi -> F(phi) derivable in BX (uses reflexive T-axiom)
- `bx_le_refl`: Reflexivity of canonical ordering (uses BX1)
- `Frame.lean`: Entirely sorry-free
- `Completeness.lean`: Entirely sorry-free
- `Soundness.lean`: Entirely sorry-free (per comments)

### Sorry #1: `fwd_chain_forward_F` (Line 1111) — HARD

**Statement**: `F(phi) in chain(n) -> exists m > n, phi in chain(m)`

**Current state**: The `preserving_fwd_step` already resolves defects. At each step with active defects, `defect_step_choice_early` picks the BX11-earliest defect and resolves it. F-obligations for all sigma_list formulas are preserved (`preserving_fwd_step_F_preserved`).

**What's missing**: The termination/pigeonhole argument. The chain resolves at least one defect per step when defects exist. Since `|sigma_list|` is finite, within at most `|sigma_list|` steps, either phi is resolved directly, or the defect count has strictly decreased. After at most `|sigma_list|` rounds, all defects including phi must be resolved.

**Proof strategy under reflexive semantics**:
1. F(phi) persists to chain(n) and forward (by `fwd_chain_F_persistent`)
2. At each step with defects, `defect_step_choice_early` resolves some defect w
3. **Key insight under reflexive G**: `g_content(M) ⊆ M` (from T-axiom). This means the Lindenbaum seed is much richer — it contains the entire G-content of the current MCS, which under reflexive G includes everything that G guards.
4. The resolution at each step resolves one defect AND preserves all other F-obligations
5. Since `active_defects` is bounded by `|sigma_list|`, by strong induction on defect count, phi is eventually resolved

**Estimated effort**: 8-12 hours. This is the hardest sorry because it requires well-founded induction on the defect count over the chain. The key lemma is: `|active_defects(chain(n+1))| < |active_defects(chain(n))|` when defects exist (F-Defect Monotonicity from report 13, Section 2.3).

**Under reflexive G, F-Defect Monotonicity is simpler**: Since `g_content(M) ⊆ M`, the seed `{psi_j} ∪ g_content(M) ∪ {F(psi_k) | k != j}` already contains everything in `g_content(M)` which under reflexive G is a subset of M. New F-defects cannot arise because `F(alpha) not in M` implies `G(neg alpha) in M` implies `G(G(neg alpha)) in M` (temp_4) implies `G(neg alpha) in g_content(M) ⊆ seed ⊆ M'`. So `F(alpha) not in M'`.

### Sorry #2: `dd_bfmcs_restricted_tc` backward case (Line 1138) — MEDIUM

**Statement**: When `t - s < 0` (in backward chain region), `F(phi) in chain(t)` implies `exists u > t, phi in chain(u)`.

**Current state**: The backward chain uses `bwd_pred` with round-robin scheduling but lacks F-preservation infrastructure.

**Proof strategy**:
- When t < s (backward region), chain(t) = `bwd_chain_of_sigma(M₀, h₀, sigma_list, |t - s|)`.
- F(phi) in the backward chain at position t needs phi at some u > t.
- **Key observation**: Under reflexive G, phi -> F(phi). So if phi in M₀ (= chain(s)), then F(phi) in M₀. The forward chain resolves this by sorry #1.
- If phi not in M₀: F(phi) in the backward chain at t < s means F(phi) propagates forward through g_content. Since `g_content(M) ⊆ M` under reflexive G, F(phi) in chain(t) implies F(phi) in g_content(chain(t)) which appears in chain(t+1). F(phi) persists to chain(s) = M₀. Then sorry #1 gives the witness u > s > t.

**Alternative**: Build a symmetric `preserving_bwd_step` with F-preservation (dual of forward case). This may be cleaner but duplicates infrastructure.

**Estimated effort**: 4-6 hours (using the propagation-to-M₀ approach).

### Sorry #3: `dd_bfmcs_restricted_tc` P-resolution (Line 1145) — MEDIUM

**Statement**: `P(phi) in chain(t) -> exists u < t, phi in chain(u)`

**Proof strategy**: Symmetric to F-resolution. The backward chain should have a `preserving_bwd_step` that preserves P-obligations, with a symmetric pigeonhole argument. Under reflexive H: `h_content(M) ⊆ M` (from T-axiom for H), giving the same enrichment benefits.

**Estimated effort**: 4-6 hours (symmetric to #1 but leveraging the forward proof structure).

### Sorry #4: `dd_bfmcs_restricted_buc` (Line 1153) — MEDIUM

**Statement**: Backward Until/Since coherence. For `(phi U psi) in chain(t)`, when scanning backward, Until obligations propagate correctly.

**Proof strategy under reflexive semantics**:
1. BX8 is now available: `psi -> (phi U psi)` is an axiom
2. `psi_imp_until` is provable (direct BX8 application)
3. The base case of backward induction works: if psi in chain(r), then (phi U psi) in chain(r) by BX8
4. Step transfer: `(phi U psi) in chain(r+1), phi in chain(r) -> (phi U psi) in chain(r)` — under reflexive Until, witness s >= r+1 > r with psi(s) and guard phi on [r, s) = {r} ∪ [r+1, s); phi(r) given, phi on [r+1, s) from the Until at r+1
5. The step transfer is derivable via BX5 (self-accumulation) + BX6 (absorption) + reflexive Until semantics

**Estimated effort**: 5-8 hours.

### Sorry #5: `dd_bfmcs_restricted_fuc` (Line 1160) — MEDIUM

**Statement**: Forward Until/Since coherence. For `(phi U psi) in chain(t)`, there exists witness s >= t with psi in chain(s) and phi in chain(r) for all r in [t, s).

**Proof strategy**:
1. By BX10: `(phi U psi) -> F(psi)`. So F(psi) in chain(t).
2. By sorry #1 (once closed): exists s > t with psi in chain(s)
3. For the reflexive base case (s = t): if psi in chain(t), witness at s = t, guard [t, t) = vacuous. Done.
4. Guard phi on [t, s): By BX9 (until_elim), at any r with `(phi U psi) in chain(r)` and `psi not in chain(r)`, we get `phi in chain(r)`. Need to show (phi U psi) persists through [t, s).
5. (phi U psi) persistence: Under reflexive G, `(phi U psi) in chain(t)` gives `G(phi U psi) in chain(t)` only if we have the 4-axiom for Until, which we don't. Instead, use BX5: `(phi U psi) -> ((phi ∧ (phi U psi)) U psi)`. The self-accumulation ensures (phi U psi) is part of the guard at each intermediate step.

**Estimated effort**: 5-8 hours (reduces to sorry #1 + BX5/BX9 interaction).

### Non-Critical Sorries on the `until` Branch

| File | Sorry Count | Critical? | Notes |
|------|------------|-----------|-------|
| `Theorems/Perpetuity/Bridge.lean` | 13 | No | Perpetuity principles, not on completeness path |
| `Metalogic/ConservativeExtension/Lifting.lean` | 12 | No | Conservative extension infrastructure (useful for Phase 2) |
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | 9 | No | Extended derivation system |
| `Theorems.lean` | 7 | No | Re-exports with sorry'd imports |
| `Metalogic/Bundle/Construction.lean` | 3 | No | Old construction, superseded by RootScopedChain |
| `Metalogic/Algebraic/TenseS5Algebra.lean` | 3 | No | Algebraic infrastructure |
| `Metalogic/BXCanonical/CanonicalModel.lean` | 2 | No | Comments only (no actual sorry terms) |
| `Theorems/TemporalDerived.lean` | 4 | No | Comments with "sorry-free" in header (no actual sorry terms) |

**Key insight**: The 5 RootScopedChain.lean sorries are the ONLY ones on the critical path from `bx_completeness` down to leaf proofs.

---

## Part 2: Irreflexive Completeness — Approach Evaluation

### Option A: Conservative Extension (RECOMMENDED)

**Idea**: Show that the reflexive BX system (with BX1: G(phi) -> phi) is a conservative extension of the irreflexive BX system (without BX1) for formulas that don't use BX1.

**More precisely**: Define the irreflexive system BX^- = BX \ {BX1, BX1'}. Show that if `BX ⊢ phi` and phi doesn't mention the reflexivity axiom in its derivation, then `BX^- ⊢ phi`.

**Problem**: This is not quite right. Conservative extension means: if `BX ⊢ phi` and phi is valid under irreflexive semantics, then `BX^- ⊢ phi`. This requires showing that BX1 doesn't add new theorems that are irreflexively valid.

**The `until` branch already has ConservativeExtension/ infrastructure** (ExtFormula.lean, ExtDerivation.lean, Substitution.lean, Lifting.lean) with 21 sorries. This suggests the approach was already being explored.

**Concrete plan**:
1. Define the irreflexive semantic validity predicate `irr_valid`
2. Show `irr_valid phi -> valid phi` (every irreflexively valid formula is reflexively valid)
3. From reflexive completeness: `valid phi -> BX ⊢ phi`
4. Show that any derivation of an irreflexively valid phi can avoid BX1 (the key lemma)
5. Therefore: `irr_valid phi -> BX^- ⊢ phi`

**Risk**: Step 4 is the hard part. It's not obvious that BX1 can be eliminated from derivations of irreflexively valid formulas. This may require a cut-elimination-style argument or a model-theoretic argument (build an irreflexive model from a reflexive one).

**Estimated effort**: 25-40 hours.

### Option B: Semantic Translation (VIABLE ALTERNATIVE)

**Idea**: Define strict temporal operators in terms of reflexive ones:
- `G_strict(phi) = G(phi) ∧ ¬phi` (or equivalently `G(phi) ∧ F(¬phi)`)
- Wait, this doesn't work: G_strict(phi) should mean "phi at all strictly future times", which under reflexive G is `G(phi) ∧ (phi ∨ ¬phi)` — that's trivially G(phi).

**Better approach**: Define a translation tau from irreflexive formulas to reflexive formulas:
- `tau(G(phi)) = G(phi) ∧ ¬phi` ... no, this changes the meaning.

Actually, the standard approach is: an irreflexive linear order (D, <) can be embedded into a reflexive one (D, <=) since <= is the reflexive closure of <. For dense linear orders, < and <= give the same theory for many purposes. But for discrete orders or general linear orders, they differ.

**The key relationship**: For any linear order (D, <):
- `(D, <) |= G(phi) at t` iff `∀s > t, phi(s)` 
- `(D, <=) |= G(phi) at t` iff `∀s >= t, phi(s)` iff `phi(t) ∧ (D, <) |= G(phi) at t`

So `irr_G(phi) = refl_G(phi) ∧ phi` ... no: `refl_G(phi) at t` means `phi(t) ∧ irr_G(phi) at t`. So `irr_G(phi) = refl_G(phi)` restricted to `phi` not holding at t... this is getting circular.

**The correct translation** (Goldblatt 1992 approach): 
- Every reflexive model restricts to an irreflexive model by removing the identity from the ordering
- Validity under irreflexive semantics on all strict linear orders = Validity under reflexive semantics on all linear orders (they have the same validities for the G/H fragment without BX1)

This actually suggests that **BX minus BX1 is already complete for irreflexive semantics**, provided the frame class is the same (all linear orders). The reflexive completeness proof builds a model on (Z, <=). Restricting to (Z, <) gives an irreflexive model. The truth of formulas not involving BX1 is preserved.

**Estimated effort**: 15-25 hours (simpler than Option A if the frame restriction works cleanly).

### Option C: Frame Class Restriction (SIMPLEST)

**Idea**: The reflexive completeness proof builds a canonical model on (Z, <=). Show that all formulas valid on strict linear orders (Z, <) are also valid on reflexive linear orders (Z, <=), and vice versa for the BX^- fragment.

**Key lemma**: For any formula phi in the language without BX1-specific content:
`(Z, <) |= phi` iff `(Z, <=) |= phi`

This is FALSE in general: `G(phi) -> phi` is valid on (Z, <=) but not on (Z, <).

**But**: For formulas that are valid on ALL strict linear orders, they are also valid on all reflexive linear orders (since reflexive linear orders are a subclass of... no, they're different classes).

**Actual relationship**: The class of all strict linear orders and the class of all non-strict linear orders generate the same logic EXCEPT for BX1 (G -> phi) and its dual. So:
- `Th(strict linear orders) = Th(reflexive linear orders) ∩ {phi | BX1 not needed}`

This reduces to Option A.

### Option D: Direct Irreflexive Proof Reusing Infrastructure (FALLBACK)

If conservative extension proves too hard, use the chain construction infrastructure from the reflexive proof but modify it for irreflexive semantics:
1. Copy RootScopedChain.lean 
2. Change the semantic definitions back to strict
3. Remove BX8, replace BX10 with BX10'
4. The enriched-seed construction still works (Ordered Seed Consistency doesn't use T-axiom)
5. The F-resolution argument needs modification: without `g_content(M) ⊆ M`, F-defect monotonicity requires the enriched seed explicitly

This was the approach attempted on `irr_until` for 60+ rounds and failed due to the g_content opacity problem. NOT recommended.

---

## Part 3: Branch Strategy

### Recommended: Work on `until` Branch

1. **Switch to `until` branch** for Phase 1 work
2. The `until` branch already has all the reflexive infrastructure in place
3. After completing Phase 1 (sorry-free reflexive completeness), create a new branch `irr_completeness` from `until` for Phase 2

### What to Port from `irr_until`

The `irr_until` branch has some improvements worth cherry-picking:
- Any soundness improvements or bug fixes made during the 60+ rounds
- The `ConservativeExtension/` infrastructure (already on `until` branch)
- Review analysis from specs/ directory

### What NOT to Port

- The irreflexive semantic definitions (G: `<`, H: `<`)
- The removed BX8 axiom
- Any chain construction attempts under A2 semantics

---

## Part 4: Effort Estimate Table

### Phase 1: Reflexive Completeness (until branch)

| Task | Sorry | Hours | Dependencies | Risk |
|------|-------|-------|--------------|------|
| P1.1: F-Defect Monotonicity lemma | #1 prereq | 3-4 | None | Low |
| P1.2: Pigeonhole / WF induction for `fwd_chain_forward_F` | #1 | 5-8 | P1.1 | Medium |
| P1.3: Backward-to-forward F-propagation | #2 | 4-6 | P1.2 | Low |
| P1.4: Symmetric P-resolution via `preserving_bwd_step` | #3 | 4-6 | P1.1 (symmetric) | Low |
| P1.5: Step transfer + backward Until coherence | #4 | 5-8 | BX8 (available) | Medium |
| P1.6: Forward Until coherence via BX10 + #1 + BX5/BX9 | #5 | 5-8 | P1.2 | Medium |
| P1.7: Integration testing + `lake build` | — | 2-3 | All above | Low |
| **Phase 1 Total** | | **28-43 hours** | | |

### Phase 2: Irreflexive Completeness

| Task | Hours | Dependencies | Risk |
|------|-------|--------------|------|
| P2.1: Frame restriction lemma (irr valid -> refl valid) | 5-8 | Phase 1 complete | Low |
| P2.2: BX1 elimination (derivation without T-axiom) | 10-15 | P2.1 | High |
| P2.3: Irreflexive completeness theorem | 5-8 | P2.2 | Medium |
| P2.4: Complete ConservativeExtension/ sorries | 5-10 | P2.2 | Medium |
| **Phase 2 Total** | **25-41 hours** | | |

### Grand Total: 53-84 hours

---

## Part 5: Risk Assessment

### High Risk

| Risk | Impact | Mitigation |
|------|--------|------------|
| F-Defect Monotonicity formalization harder than expected | Blocks P1.1-P1.2 | The mathematical proof is clear (report 13, Section 2.3); complexity is in the Lean formalization of well-founded induction over `List.length (active_defects ...)` |
| BX5/BX9 interaction for guard persistence | Blocks P1.5-P1.6 | May need intermediate lemmas about Until persistence at chain steps; BX5 self-accumulation provides the core mechanism |
| BX1 elimination for Phase 2 | Blocks P2.2 | Fallback: prove completeness for the specific frame class (Z, <) directly, using the reflexive canonical model restricted to strict ordering |

### Medium Risk

| Risk | Impact | Mitigation |
|------|--------|------------|
| Step transfer proof complexity | Delays P1.5 | The argument is semantically clear under reflexive Until; the formal derivation chain (BX5 -> BX6 -> BX8) is well-understood |
| Backward chain symmetry | Delays P1.3-P1.4 | Can share infrastructure with forward chain via parameterization |
| `preserving_bwd_step` needs building | Delays P1.4 | Symmetric to existing `preserving_fwd_step`; mechanical duplication |

### Low Risk

| Risk | Impact | Mitigation |
|------|--------|------------|
| Soundness regression after changes | Would require rework | Soundness is already sorry-free on `until` branch; no changes to semantics needed |
| Ordered Seed Consistency breaks | Would block everything | Already proved sorry-free; no changes needed |
| Frame.lean sorry | None | Frame.lean is actually sorry-free on `until` (the "sorry" is in a comment only) |

---

## Part 6: Concrete Phase 1 Execution Order

### Step 1: Prove F-Defect Monotonicity (P1.1)

```
theorem active_defects_decrease (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (sigma_list : List Formula) (h_ne : active_defects M sigma_list ≠ []) :
    (active_defects (preserving_fwd_step M h_mcs sigma_list n) sigma_list).length <
    (active_defects M sigma_list).length
```

Key sub-lemmas:
- No new defects: `F(alpha) not in M -> F(alpha) not in preserving_fwd_step M ...` (via temp_4 + g_content propagation)
- Resolved defect gone: the target psi_j is in the successor, so not a defect even if F(psi_j) also in successor
- Under reflexive G: `g_content(M) ⊆ M` simplifies the no-new-defects proof significantly

### Step 2: Close Sorry #1 via WF Induction (P1.2)

Use `Nat.lt_wfRel` or `WellFoundedRelation` on `(active_defects ...).length`:
```
theorem fwd_chain_forward_F ... := by
  -- Well-founded induction on defect count
  -- At step n: if phi is a defect, defect_step_choice_early resolves some defect
  -- By F-Defect Monotonicity, defect count strictly decreases
  -- Within |sigma_list| steps, phi must be resolved (pigeonhole)
  -- OR: use Nat.strongRecOn on the defect count at chain(n)
```

### Step 3: Close Sorries #2-3 (P1.3-P1.4)

For #2 (backward F in backward chain): propagate F(phi) from backward chain position to M₀, then use sorry #1 resolution in the forward chain.

For #3 (P-resolution): build symmetric `preserving_bwd_step` with P-preservation, then mirror the forward F-resolution argument.

### Step 4: Close Sorry #4 (P1.5)

Backward Until coherence via BX8 + step transfer. The key derivation chain:
```
psi in chain(r) -> (phi U psi) in chain(r)   [by BX8]
(phi U psi) in chain(r+1), phi in chain(r) -> (phi U psi) in chain(r)  [step transfer]
```

### Step 5: Close Sorry #5 (P1.6)

Forward Until coherence: `(phi U psi) in chain(t)` -> witness exists.
- BX10 gives F(psi) in chain(t)
- Sorry #1 gives psi in chain(s) for some s > t
- Guard follows from BX5 + BX9 at intermediate positions

### Step 6: Verify (P1.7)

`lake build` should pass with 0 sorries on the completeness critical path.

---

## Confidence Assessment

| Aspect | Confidence |
|--------|-----------|
| Phase 1 is achievable | HIGH — all mathematical arguments are clear; the `until` branch has strong infrastructure |
| Phase 1 effort estimate (28-43 hours) | MEDIUM — Lean formalization often takes 2-3x longer than expected |
| Phase 2 via conservative extension | MEDIUM — the mathematical approach is standard but formalization is non-trivial |
| Phase 2 effort estimate (25-41 hours) | LOW — BX1 elimination is the main unknown; could be much harder |
| Overall strategy (reflexive-first) | VERY HIGH — aligns with all literature, builds on existing infrastructure |
