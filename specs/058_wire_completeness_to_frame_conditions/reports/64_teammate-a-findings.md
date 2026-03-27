# Teammate A Findings: boundary_resolution_set Blocker Analysis

**Task**: 58 - wire_completeness_to_frame_conditions
**Session**: sess_1774628958_89784c
**Date**: 2026-03-27
**Focus**: Verify and analyze the boundary_resolution_set consistency blocker

---

## Key Findings

1. **The blocker is real and confirmed**: `chi` and `chi.neg` CAN both appear in `boundary_resolution_set` simultaneously. The conditions are logically independent and both satisfiable at the same time in temporal logic.

2. **`neg_not_in_boundary_resolution_set` is not provable** as stated (SuccChainFMCS.lean:1412). The file itself documents this in the theorem's commentary at lines 1371-1409, showing all attempted proof paths fail.

3. **The seed CAN be inconsistent**: Because both `chi` and `chi.neg` can appear in `boundary_resolution_set`, and that set is included in `constrained_successor_seed_restricted`, the seed can contain a contradictory pair, making it inconsistent.

4. **The proof strategy in the plan is flawed**: The documented "replace chi with F(chi)" strategy (plan lines 104-111, echoed in blocker analysis) does not produce a valid consistency argument.

5. **A correct fix for Option A is possible** by strengthening the `boundary_resolution_set` definition with a mutual exclusion condition, but doing so correctly requires care to avoid defeating the set's purpose.

---

## Analysis of the Blocker

### The boundary_resolution_set Definition

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula)}
```

For `chi ∈ BRS`: two conditions must hold:
- `F(chi) ∈ u`
- `FF(chi) ∉ deferralClosure(phi)`

### Why Both chi and chi.neg Can Be in BRS

For `chi.neg ∈ BRS`, the analogous conditions must hold:
- `F(chi.neg) ∈ u`
- `FF(chi.neg) ∉ deferralClosure(phi)`

These conditions are **fully independent** from those for `chi`:

**Semantic independence**: In temporal logic, `F(chi)` means "chi holds at some future time t'" and `F(chi.neg)` means "chi fails at some future time t''". These can both be true (chi holds at t' but not at t'').

**Syntactic independence**: `chi.neg = chi.imp bot`. The formula `F(chi.neg) = some_future(chi.imp bot)` is syntactically distinct from `F(chi) = some_future chi`. The deferralClosure condition `FF(chi.neg) ∉ deferralClosure` is also independent of `FF(chi) ∉ deferralClosure`.

**MCS cannot prevent this**: The existing `drm_G_neg_implies_not_F` (RestrictedMCS.lean:1408) only shows that if `G(neg chi) ∈ u` then `F(chi) ∉ u`. But having `F(chi) ∈ u` and `F(chi.neg) ∈ u` simultaneously is consistent - there is no theorem in the codebase that rules it out, and there should not be one (it corresponds to a valid modal sentence `Fchi ∧ F(neg chi)`).

### Why the Proof Cannot Close

The sorry at SuccChainFMCS.lean:1543 asks us to prove:
```
SetConsistent(g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_restricted(phi,u) ∪ BRS(phi,u))
```

The strategy of "for each BRS element, show its negation is not in the seed" fails precisely because `chi.neg` CAN be in BRS when `chi` is also in BRS. The three provable lemmas (`neg_not_in_g_content_when_F_in`, `neg_not_in_deferralDisjunctions`, `neg_not_in_p_step_blocking_restricted`) only cover three of the four components. The fourth case (`neg_not_in_boundary_resolution_set`) is the one that fails.

The three proven lemmas do NOT suffice: even if `chi.neg ∉ g_content(u)` and `chi.neg ∉ deferralDisjunctions(u)` and `chi.neg ∉ p_step_blocking(...)`, we can have `chi.neg ∈ BRS(phi,u)`, making the seed `{..., chi, chi.neg, ...}` directly inconsistent.

---

## Potential Fixes for the Option A Path

### Fix A1: Mutual Exclusion Condition (Recommended)

Redefine `boundary_resolution_set` to add a mutual exclusion condition:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.some_future chi.neg ∉ u}   -- NEW: exclude when F(neg chi) also in u
```

**Rationale**: The third condition `F(chi.neg) ∉ u` ensures that if `chi ∈ BRS`, then `chi.neg ∉ BRS` (since `chi.neg ∈ BRS` requires `F(chi.neg) ∈ u`). This makes BRS mutually exclusive by construction.

**Impact on the purpose of BRS**: The purpose of BRS is to force chi into the successor when F(chi) ∈ u and we are at the F-depth boundary. If F(chi.neg) ∈ u, it means "eventually not-chi" also holds. In this case we do NOT force chi into the successor - which is appropriate since forcing chi would not be wrong per se, but the two-sided constraint makes the seed inconsistent. By excluding chi when F(neg chi) ∈ u, we allow the Lindenbaum extension process (maximality) to determine chi's status.

**Proof of consistency with this fix**: With the new condition, `neg_not_in_boundary_resolution_set` becomes provable:
- Assume `chi ∈ BRS`: then `F(chi) ∈ u` and `F(chi.neg) ∉ u` (new condition)
- If `chi.neg ∈ BRS`: then `F(chi.neg) ∈ u` is required
- But `F(chi.neg) ∉ u` from chi's membership. Contradiction.

**Proof of `constrained_successor_seed_restricted_consistent`**: With mutual exclusion, BRS elements cannot be contradictory pairs. The seed's consistency follows by showing it is a subset of `u ∪ BRS`, and BRS adds no contradictions. The non-BRS part is already `⊆ u` (proven). For BRS pairs, mutual exclusion prevents `chi` and `chi.neg` from both appearing.

A full consistency proof would proceed by: for any finite subset L of the seed, replace each `chi ∈ L ∩ BRS` with `F(chi) ∈ u` (using the axiom `F(chi) → chi ∨ F(F(chi))` or the deferral disjunction). Since `F(chi) ∈ u` and the non-BRS part is in `u`, consistency of `u` is preserved.

**Risk**: If `F(chi) ∈ u` and `F(chi.neg) ∈ u` simultaneously, chi's F-obligation goes unresolved. The Lindenbaum extension will determine chi's truth value, but we need to verify that this does not break the F-witness property of the successor chain. Specifically: if we skip forcing chi into the successor (because F(chi.neg) ∈ u), we need chi ∨ F(chi) to be in u (from deferralDisjunctions), which ensures chi is either true now (in the successor) or the obligation is propagated.

### Fix A2: Add chi.neg ∉ BRS as Direct Axiom

Add a selector that picks only one of {chi, chi.neg} when both would otherwise qualify. For example, use a well-ordering on formulas and pick the smaller one:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         ¬(Formula.some_future chi.neg ∈ u ∧   -- if both qualify...
           Formula.some_future (Formula.some_future chi.neg) ∉ (deferralClosure phi : Set Formula) ∧
           someOrdering chi.neg chi)}            -- prefer chi over chi.neg
```

This is more complex but mathematically valid. Fix A1 is simpler.

### Fix A3: Strengthen to Require chi ∈ u (Reverts to Old Design)

The comment at SuccExistence.lean:261-264 reveals the original design included `chi ∈ u` to make consistency trivial:

> The chi ∈ u condition ensures augmented_seed ⊆ u, making consistency trivial.

Reverting to this design:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | chi ∈ u ∧
         Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula)}
```

**Problem**: This defeats the purpose. `chi ∈ u` is a very strong condition. If chi is in u already, it is already "in the MCS" and doesn't need to be forced into the seed. The BRS exists to force resolution of F-obligations for chi NOT yet in u. This fix makes BRS vacuous in the interesting case.

**Not recommended**: Fix A1 is the right approach.

---

## Confidence Level

**High** on the blocker analysis: The evidence is conclusive. The definitions, lemmas, and commentary in the file all converge on the same conclusion - `chi.neg` can be in BRS when `chi` is also in BRS.

**Medium** on Fix A1: The fix is logically sound and the consistency argument is sketched. However:
- The proof that the restricted successor construction STILL achieves F-witness propagation with the new BRS needs verification. When `F(chi) ∈ u` and `F(chi.neg) ∈ u`, chi is excluded from BRS. The deferralDisjunction `chi ∨ F(chi) ∈ u` is in the seed (since `F(chi) ∈ u` triggers `deferralDisjunction_chi ∈ deferralDisjunctions(u)`). By maximality of the Lindenbaum extension, the successor will contain chi or F(chi). This should suffice for F-witness existence.
- The formal proof machinery (showing no contradiction arises even with BRS elements contributing to consistency) still needs to be worked out carefully.

---

## Recommendations

1. **Implement Fix A1** for `boundary_resolution_set`: add the condition `Formula.some_future chi.neg ∉ u`. This is the minimal change that restores consistency while preserving the intent of the definition.

2. **After Fix A1**, the proof of `neg_not_in_boundary_resolution_set` becomes a 3-line proof by contradiction.

3. **The consistency proof `constrained_successor_seed_restricted_consistent`** then becomes a two-part argument:
   - Non-BRS part ⊆ u: already proven
   - BRS elements: mutual exclusion (from Fix A1) prevents contradictory pairs; consistency follows from u's consistency and the F-obligation structure

4. **Verify F-witness propagation** after Fix A1: when both `F(chi) ∈ u` and `F(chi.neg) ∈ u`, chi is excluded from BRS but `chi ∨ F(chi) ∈ u` (via deferralDisjunctions) ensures the successor contains chi or passes the obligation forward. Confirm this does not break `restricted_forward_chain_forward_F`.

5. **Do not pursue Fix A3** (adding `chi ∈ u`). It defeats the purpose of BRS.

6. **If Fix A1 is insufficient** to complete the downstream chain proofs, escalate to Option B (direct BFMCS_Bundle to TaskModel construction). Fix A1 is a necessary but possibly not sufficient correction.

---

## Source Locations

| File | Lines | Content |
|------|-------|---------|
| SuccExistence.lean | 284-286 | `boundary_resolution_set` definition |
| SuccExistence.lean | 261-264 | Comment on original chi ∈ u design |
| SuccChainFMCS.lean | 1412-1435 | `neg_not_in_boundary_resolution_set` (sorry, unprovable) |
| SuccChainFMCS.lean | 1371-1409 | Detailed commentary showing all proof paths fail |
| SuccChainFMCS.lean | 1507-1543 | `constrained_successor_seed_restricted_consistent` (sorry) |
| RestrictedMCS.lean | 1408-1415 | `drm_G_neg_implies_not_F` (does not help here) |
| RestrictedMCS.lean | 676-678 | `DeferralRestrictedMCS` definition |
