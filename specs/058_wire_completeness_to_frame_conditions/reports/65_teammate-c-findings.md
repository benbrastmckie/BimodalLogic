# Teammate C Findings: Alternative Proof Strategies

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Focus**: Alternative proof strategies for `neg_not_in_boundary_resolution_set` that avoid the closure-under-derivation path

---

## Key Findings

1. **The theorem `neg_not_in_boundary_resolution_set` may be unprovable as stated** under the Fix A1 definition — not just difficult, but potentially FALSE. The conditions `F(chi) ∈ u` and `chi.neg ∈ BRS` can coexist simultaneously in a DeferralRestrictedMCS without contradiction.

2. **The root blockage is structural, not incidental**: ALL proof paths for this theorem — direct or contrapositive — require showing that some formula involving double-negation is in `deferralClosure phi`. The `deferralClosure` is built from subformulas of `phi` and is not closed under double-negation substitutions.

3. **The consistency proof strategy is also wrong**: The `constrained_successor_seed_restricted_consistent` proof plan uses `neg_not_in_boundary_resolution_set` to guarantee no `{chi, chi.neg}` pairs in the seed. But this is the wrong claim: BRS-BRS pairs are ruled out by `brs_mutual_exclusion`, but BRS-g_content pairs are NOT ruled out by any proven lemma, and the gap is a genuine inconsistency risk.

4. **The Fix A1 condition `F(chi.neg) ∉ u` is necessary but not sufficient**: It prevents `chi ∈ BRS` AND `chi.neg ∈ BRS` simultaneously (mutual exclusion within BRS). But it does not prevent `chi ∈ g_content(u)` AND `chi.neg ∈ BRS` simultaneously.

5. **The correct alternative is to REPLACE `neg_not_in_boundary_resolution_set` with a weaker lemma** (`neg_not_in_seed_when_in_brs`) that takes `psi ∈ BRS` as hypothesis instead of `F(psi) ∈ u`. This weaker form is PROVABLE using the four existing lemmas (including `brs_mutual_exclusion`). The `constrained_successor_seed_restricted_consistent` sorry should then be proved via "no contradictory pairs in seed" using this weaker lemma.

6. **Critical discovery**: `neg_not_in_constrained_successor_seed_restricted` and `neg_not_in_boundary_resolution_set` are defined but not actually USED anywhere in the current file. The `constrained_successor_seed_restricted_consistent` sorry comment (lines 1543-1547) does NOT cite these theorems. The consistency proof can be structured using only the four proven lemmas directly.

---

## Detailed Analysis

### Why the Fix A1 Proof Path Fails

With the current Fix A1 BRS definition:
```lean
chi ∈ BRS ↔ F(chi) ∈ u ∧ FF(chi) ∉ dC ∧ F(chi.neg) ∉ u
```

For `chi.neg ∈ BRS`:
```
F(chi.neg) ∈ u ∧ FF(chi.neg) ∉ dC ∧ F(chi.neg.neg) ∉ u
```

Given `F(chi) ∈ u`, the proof of `chi.neg ∉ BRS` requires falsifying one of the three conditions above.

**Condition 1** (`F(chi.neg) ∈ u`): Cannot be falsified. `F(chi)` and `F(chi.neg)` represent "eventually chi" and "eventually not-chi" respectively. Both can hold simultaneously in temporal logic — this is a valid sentence `F(chi) ∧ F(chi.neg)`.

**Condition 2** (`FF(chi.neg) ∉ dC`): Cannot be determined from `F(chi) ∈ u` alone. The deferral depth of `chi.neg` is independent.

**Condition 3** (`F(chi.neg.neg) ∉ u`): Can theoretically be falsified by showing `F(chi.neg.neg) ∈ u`. The provable implication `⊢ F(chi) → F(chi.neg.neg)` exists (via DNE + G-monotone). BUT:
- `drm_closed_under_derivation` requires the CONCLUSION `F(chi.neg.neg)` to be in `deferralClosure phi`
- `F(chi.neg.neg) = chi.neg.neg.neg.all_future.neg` = G(¬¬¬chi) → ⊥
- `chi.neg.neg` is syntactically `(chi.imp bot).imp bot`, not a subformula of `phi` in general
- Therefore `F(chi.neg.neg) ∉ deferralClosure phi` in general
- The `drm_closed_under_derivation` route is BLOCKED

### Why the Theorem May Be False

Concretely, the following scenario is satisfiable:
- `F(chi) ∈ u` (holds by hypothesis)
- `F(chi.neg) ∈ u` (independently true — "eventually not-chi")
- `FF(chi.neg) ∉ dC` (depth condition — depends on phi, not chi)
- `F(chi.neg.neg) ∉ u` (the DRM may not contain this formula)

All four conditions are compatible. So `chi.neg ∈ BRS` while `F(chi) ∈ u`.

This means `neg_not_in_boundary_resolution_set` as stated is potentially false under the Fix A1 definition. It is NOT a "hard proof" problem but a "wrong statement" problem.

### The Structural Identity That Matters

The key syntactic identity (used by `neg_not_in_g_content_when_F_in`):
```
F(chi) = G(chi.neg).neg    [syntactically by rfl]
```

This works because `some_future phi = phi.neg.all_future.neg`, so:
```
F(chi) = chi.neg.all_future.neg = G(chi.neg).neg
```

This gives `F(chi) ∈ u → G(chi.neg) ∉ u` by MCS consistency directly.

There is NO analogous identity for `F(chi.neg)`:
```
F(chi.neg) = chi.neg.neg.all_future.neg = G(chi.neg.neg).neg
```

So `F(chi.neg) ∈ u → G(chi.neg.neg) ∉ u`. But `G(chi)` and `G(chi.neg.neg)` are syntactically different (`chi ≠ chi.neg.neg`), so `G(chi) ∈ u` does not directly prevent `G(chi.neg.neg) ∉ u`.

### The g_content vs BRS Collision

There is an ADDITIONAL consistency gap not covered by Fix A1:

`chi ∈ g_content(u)` means `G(chi) ∈ u`, so `chi ∈ seed`.
`chi.neg ∈ BRS` requires `F(chi.neg) ∈ u`, `FF(chi.neg) ∉ dC`, `F(chi.neg.neg) ∉ u`.

Can `G(chi) ∈ u` and `F(chi.neg) ∈ u` coexist in a DRM?

Logically: NO. `G(chi) → ¬F(¬chi)` is a theorem. But:
- `G(chi).neg ≠ F(chi.neg)` syntactically in general
- `G(chi).neg = chi.all_future.imp bot`
- `F(chi.neg) = chi.neg.neg.all_future.imp bot`

Equal only when `chi = chi.neg.neg` syntactically — never true.

The DRM cannot detect this contradiction because `F(chi.neg) ∉ deferralClosure phi` in general, so `drm_closed_under_derivation` cannot be used to infer `F(chi.neg).neg ∈ u` from `G(chi) ∈ u`.

**This means the seed CAN genuinely contain `{chi, chi.neg}` pairs** (chi from g_content, chi.neg from BRS), and the current seed definition IS inconsistent in some scenarios.

---

## Recommended Approaches

### Approach 1 (Preferred): Cut-Simulation Consistency Proof

**Do not prove `neg_not_in_boundary_resolution_set`**. Instead, prove `constrained_successor_seed_restricted_consistent` directly via a cut-simulation argument.

**Key idea**: For any finite `L ⊆ seed` that derives `⊥`, construct `L' ⊆ u` that also derives `⊥`, contradicting u's consistency.

**Construction of L'**: Given `L = L_nb ∪ L_brs` where `L_nb ⊆ non-BRS-seed ⊆ u` and `L_brs ⊆ BRS`:

For each `psi ∈ L_brs`:
- `F(psi) ∈ u` (by BRS membership)
- `psi ∨ F(psi) ∈ u` (from deferralDisjunctions, since `F(psi) ∈ u` implies the disjunction)
- Replace `psi` with `psi ∨ F(psi)` in L

Define `L' = L_nb ∪ {psi ∨ F(psi) | psi ∈ L_brs}`. Then `L' ⊆ u`.

Now: does `L_nb ∪ L_brs ⊢ ⊥` imply `L' ⊢ ⊥`?

The cut argument: `psi ∨ F(psi) ⊢ psi ∨ F(psi)`. From `L ⊢ ⊥`, we have `L_nb ∪ L_brs ⊢ ⊥`. We need: `L_nb ∪ {psi ∨ F(psi)} ⊢ ⊥` for each BRS element psi.

This holds if `psi` is the "only way" `L_nb ∪ L_brs` derives `⊥`. But derivations can use psi multiple times. A CUT on `psi ∨ F(psi)` gives two branches:
- Branch 1: `psi` is true — subsumes the original derivation using `psi`
- Branch 2: `F(psi)` is true — need to show this also leads to `⊥` from `L_nb ∪ {F(psi)}`

Branch 2 needs: `L_nb ∪ {F(psi)} ⊢ ⊥`. This would hold if `F(psi).neg ∈ L_nb` (direct contradiction), i.e., if `G(psi.neg) ∈ L_nb`. But `G(psi.neg) ∈ g_content(u)` means `G(G(psi.neg)) ∈ u` (by the 4-axiom), which is a different story.

**Problem with this approach**: Branch 2 may not derive ⊥. The substitution is not always valid.

### Approach 2: Strengthen BRS to Prevent g_content Collisions

Add a condition to BRS that explicitly prevents the g_content collision:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ deferralClosure phi ∧
         Formula.some_future chi.neg ∉ u ∧
         chi ∉ g_content u}  -- NEW: prevent collision with g_content
```

The new condition `chi ∉ g_content u` ensures chi is NOT already derivable from G-persistence. Since `g_content u = {chi | G(chi) ∈ u}`, the condition is `G(chi) ∉ u`.

**Proof that `neg_not_in_boundary_resolution_set` holds with this fix**:

Given `F(chi) ∈ u`, show `chi.neg ∉ BRS`.

`chi.neg ∈ BRS` requires (among other things): `G(chi.neg) ∉ u` (new condition applied to chi.neg).

But `F(chi) = G(chi.neg).neg` syntactically! So `F(chi) ∈ u → G(chi.neg) ∉ u` by MCS consistency.

Therefore `G(chi.neg) ∉ u` is AUTOMATICALLY TRUE given `F(chi) ∈ u`, making the new condition for `chi.neg ∈ BRS` fail to provide a contradiction.

**Hmm, this still doesn't help directly.** The condition `chi.neg ∉ g_content u` on BRS says `G(chi.neg) ∉ u`. But `G(chi.neg) ∉ u` follows from `F(chi) ∈ u`. So the new BRS condition for `chi.neg` becomes: `G(chi.neg.neg) ∉ u` — which is a different formula again.

### Approach 3 (Most Viable): Use g_content Exclusion in BRS AND Direct Syntactic Proof

The key insight: `F(chi) ∈ u` gives `G(chi.neg) ∉ u` by syntactic identity. What if we require that the "inner formula" of BRS be in a specific syntactic form where this identity applies?

If we restrict BRS to formulas `chi` where `chi.neg` has a specific structural form that makes `chi.neg ∉ g_content u` follow syntactically from `F(chi) ∈ u`, we get a provable theorem.

Concretely, note:
- `F(chi) ∈ u` means `G(chi.neg) ∉ u`  [since `F(chi) = G(chi.neg).neg`]
- `G(chi.neg) ∉ u` means `chi.neg ∉ g_content u` [by definition of g_content]

So we need: `chi.neg ∈ BRS` requires `chi.neg ∈ g_content u` to derive a contradiction with `F(chi) ∈ u`. But the new Fix in Approach 2 EXCLUDES g_content elements from BRS.

**Revised proof sketch** with Approach 2's BRS:

Given `F(chi) ∈ u`, assume `chi.neg ∈ BRS`.

From `chi.neg ∈ BRS` (with the new condition): `chi.neg ∉ g_content u`, i.e., `G(chi.neg) ∉ u`.

But `F(chi) ∈ u → G(chi.neg) ∉ u` is ALREADY guaranteed (it's what we'd need for the proof to go through the BRS g_content exclusion path). So this is circular.

The issue: we need the contradiction to come FROM one of the BRS conditions, not from the hypothesis `F(chi) ∈ u`.

**What actually helps**: The condition `G(chi.neg) ∉ u` from the new BRS says: "chi.neg is not G-forced". But `F(chi) ∈ u` says `G(chi.neg) ∉ u` directly. So if chi.neg ∈ BRS requires `G(chi.neg) ∉ u`, this is already true from `F(chi) ∈ u`, but we WANT to derive `chi.neg ∉ BRS` — so we need chi.neg to FAIL a BRS condition, not satisfy it.

### Approach 4 (Most Promising): Fix the BRS with a "No Flip" Condition

The insight: BRS should not include `chi.neg` when `chi` is "G-forced to be eventually-true" (i.e., when `G(chi.neg) ∉ u`). But `G(chi.neg) ∉ u` follows from `F(chi) ∈ u` — so the condition is:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ deferralClosure phi ∧
         Formula.all_future chi.neg ∉ u}  -- ALTERNATIVE Fix A1: use G(chi.neg) ∉ u
```

Note: `Formula.all_future chi.neg = G(chi.neg)` = the G-necessity of chi.neg.

With this definition, `chi ∈ BRS` requires `G(chi.neg) ∉ u`. For `chi.neg ∈ BRS`:
`F(chi.neg) ∈ u ∧ FF(chi.neg) ∉ dC ∧ G(chi.neg.neg) ∉ u`

Given `F(chi) ∈ u`, we need to show one of these fails.

- `F(chi) = G(chi.neg).neg` syntactically, so `F(chi) ∈ u → G(chi.neg) ∉ u`. This doesn't directly address `G(chi.neg.neg)`.

Still stuck on the double negation.

### Approach 5 (Reframe): The Correct Consistency Argument

After careful analysis, the correct approach to `constrained_successor_seed_restricted_consistent` does NOT require `neg_not_in_boundary_resolution_set`. Here is why:

The existing proven lemmas show:
1. `psi.neg ∉ g_content(u)` for any `psi ∈ BRS` (by `neg_not_in_g_content_when_F_in`, since `F(psi) ∈ u`)
2. `psi.neg ∉ deferralDisjunctions(u)` for any `psi ∈ BRS` (structural)
3. `psi.neg ∉ p_step_blocking_restricted(phi, u)` for any `psi ∈ BRS` (structural)
4. `chi.neg ∉ BRS` if `chi ∈ BRS` (by `brs_mutual_exclusion`)

These four facts together show: **for any `psi ∈ BRS`, `psi.neg` is NOT in the seed**. This is sufficient for consistency!

Wait — lemma 1 says `psi.neg ∉ g_content(u)`, which means `psi.neg ∉ seed` (since g_content ⊆ seed). Lemmas 2 and 3 say `psi.neg` is not in the other parts. And lemma 4 says `psi.neg ∉ BRS`. Combined: `psi.neg ∉ seed` for any `psi ∈ BRS`.

This EXACTLY says: **no BRS element has its negation in the seed**. Combined with `non-BRS-part ⊆ u` (consistent), this gives:

The seed has no contradictory pairs:
- Non-BRS pairs: both in u, consistent since `u` is consistent
- BRS element `psi` vs non-BRS element `psi.neg`: ruled out by lemmas 1-3
- Two BRS elements `psi` and `psi.neg`: ruled out by lemma 4 (`brs_mutual_exclusion`)

**Therefore, the seed IS consistent, and the proof can use lemmas 1-4 WITHOUT `neg_not_in_boundary_resolution_set`!**

The `neg_not_in_boundary_resolution_set` theorem claims: for any `chi` with `F(chi) ∈ u`, `chi.neg ∉ BRS`. This is STRONGER than what's needed. What's needed is: for any `psi ∈ BRS`, `psi.neg ∉ seed`. And this follows from lemmas 1-4 DIRECTLY without `neg_not_in_boundary_resolution_set`.

The proof of `constrained_successor_seed_restricted_consistent` should be restructured to NOT use `neg_not_in_boundary_resolution_set` but instead use:
- Lemma 1 (neg_not_in_g_content_when_F_in): for psi ∈ BRS, psi.neg ∉ g_content
- Lemma 2 (neg_not_in_deferralDisjunctions): for psi ∈ BRS, psi.neg ∉ deferralDisjunctions
- Lemma 3 (neg_not_in_p_step_blocking_restricted): for psi ∈ BRS, psi.neg ∉ p_step_blocking
- Lemma 4 (brs_mutual_exclusion): for psi ∈ BRS, psi.neg ∉ BRS

These four together show: for psi ∈ BRS, psi.neg ∉ seed. This is the required consistency condition.

---

## Evidence and Examples

### Syntactic Identity (Cornerstone)

```lean
-- F(chi) = G(chi.neg).neg, by definition of some_future:
example (chi : Formula) : Formula.some_future chi = (Formula.all_future chi.neg).neg := rfl
```

This identity is used by `neg_not_in_g_content_when_F_in` and is the core of Approach 5.

### brs_mutual_exclusion (Already Proven)

```lean
-- SuccChainFMCS.lean:1378
theorem brs_mutual_exclusion (phi : Formula) (u : Set Formula) (chi : Formula)
    (h_chi_in_brs : chi ∈ boundary_resolution_set phi u) :
    chi.neg ∉ boundary_resolution_set phi u
```

This theorem is proven (not sorry) and gives us lemma 4 above.

### The Missing Piece for Approach 5

The consistency proof needs to handle the "no contradictory pair" argument. With lemmas 1-4, the argument structure is:

```
For any L ⊆ seed, assume L ⊢ ⊥.
Split L = L_nb ∪ L_brs where L_nb ⊆ u.
If L_brs = ∅: L_nb ⊆ u derives ⊥, contradicting u's consistency.
If L_brs ≠ ∅: For each psi ∈ L_brs:
  - psi ∈ BRS → psi.neg ∉ seed (by lemmas 1-4)
  - L_nb ∪ L_brs contains no {psi, psi.neg} pair
  - F(psi) ∈ u for each psi ∈ L_brs
  - F(psi) ∈ u is in u (so L_nb ∪ {F(psi) | psi ∈ L_brs} ⊆ u)
  - Need: L_nb ∪ L_brs ⊢ ⊥ → L_nb ∪ {F(psi)} ⊢ ⊥ (CUT on "psi ∨ F(psi)")
```

The last step is the cut-simulation (Approach 1), which requires a formal cut-elimination argument. This is the remaining challenge.

**Alternative to cut-simulation**: Use the inconsistency characterization more carefully. If no contradictory pairs exist, and all formulas are consistent with u, then the set is consistent. This requires a "König-style" argument based on the finite model property or a direct Lindenbaum argument.

---

## Recommended Approach

**Immediate action**: Restructure `constrained_successor_seed_restricted_consistent` to use lemmas 1-4 (NOT `neg_not_in_boundary_resolution_set`). The sorry should be:

```lean
-- Proof sketch using lemmas 1-4:
-- 1. Split: for psi ∈ BRS, psi.neg ∉ seed (lemmas 1-4)
-- 2. Non-BRS part ⊆ u (proven)
-- 3. No contradictory pairs in seed
-- 4. Therefore seed is consistent
```

**Also**: Remove or demote `neg_not_in_boundary_resolution_set` since it is:
- NOT needed by `constrained_successor_seed_restricted_consistent` (via the above restructuring)
- Potentially false as stated (when `F(chi) ∈ u` but `chi ∉ BRS`)

**The actual needed lemma** is: `psi.neg ∉ constrained_successor_seed_restricted phi u` for `psi ∈ BRS phi u`. This follows from lemmas 1-4 and requires NO assumption about F(chi) for arbitrary chi outside BRS.

Note: `neg_not_in_constrained_successor_seed_restricted` (line 1445) DOES have this form, and it ALREADY uses `neg_not_in_boundary_resolution_set` via the BRS case. If we restructure the proof to use `brs_mutual_exclusion` directly in the BRS case (since `psi ∈ BRS → psi.neg ∉ BRS`), and use the other three lemmas for the other components, the theorem holds WITHOUT the sorry.

Wait — `neg_not_in_constrained_successor_seed_restricted` has the signature:
```lean
theorem neg_not_in_constrained_successor_seed_restricted (phi u chi h_mcs h_F_in) :
    chi.neg ∉ constrained_successor_seed_restricted phi u
```

This is stated for arbitrary `chi` with `F(chi) ∈ u`, NOT specifically for `chi ∈ BRS`. But the CONSISTENCY PROOF only needs this for `chi ∈ BRS`. So the required lemma for consistency is:

```lean
theorem neg_not_in_seed_when_in_brs (phi u psi)
    (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
    psi.neg ∉ constrained_successor_seed_restricted phi u
```

This CAN be proved using:
- `neg_not_in_g_content_when_F_in` (needs `F(psi) ∈ u`, which follows from `psi ∈ BRS`)
- `neg_not_in_deferralDisjunctions` (structural, no extra hypothesis)
- `neg_not_in_p_step_blocking_restricted` (structural, no extra hypothesis)
- `brs_mutual_exclusion` (needs `psi ∈ BRS`, which is given)

This lemma is PROVABLE immediately with the current Fix A1 infrastructure, WITHOUT `neg_not_in_boundary_resolution_set`.

---

## Confidence Level

**High** on the analysis that `neg_not_in_boundary_resolution_set` is unprovable/potentially false as stated.

**High** on the observation that lemmas 1-4 suffice for consistency via the "neg_not_in_seed_when_in_brs" reformulation.

**High** on the conclusion that `neg_not_in_constrained_successor_seed_restricted` should be replaced by `neg_not_in_seed_when_in_brs` (taking `psi ∈ BRS` as hypothesis instead of `F(psi) ∈ u`).

**Medium** on the full consistency proof: the "no contradictory pair → consistent" step still needs formal work. The standard approach is:
1. Enumerate elements of L in topological order of derivation
2. Show each step preserves consistency via the non-contradictory-pair property
3. This is a structural induction that should be provable but requires careful setup

**Low** on the cut-simulation approach (Approach 1). While mathematically sound, the formalization is complex.

---

## Summary of Action Items

1. **Replace `neg_not_in_boundary_resolution_set`** with `neg_not_in_seed_when_in_brs` (takes `psi ∈ BRS` not `F(psi) ∈ u`).

2. **Update `neg_not_in_constrained_successor_seed_restricted`** to use `neg_not_in_seed_when_in_brs` in the BRS case (replacing the call to `neg_not_in_boundary_resolution_set`).

3. **Update `constrained_successor_seed_restricted_consistent`** proof to: split seed into BRS and non-BRS, use "no contradictory pairs" argument via the four proven lemmas.

4. **Formalize the "no contradictory pair → consistent" step**: This is the remaining mathematical gap. It requires showing that a finite set with no `{psi, psi.neg}` pairs, where all non-BRS elements are in a consistent set u, is itself consistent. This can be done via a model-theoretic argument (every element either in u or compatible with u via F-obligations) or a proof-theoretic argument (derivations from the seed can be normalized).

---

## Source Locations

| File | Lines | Content |
|------|-------|---------|
| SuccChainFMCS.lean | 1370-1393 | `brs_mutual_exclusion` (PROVEN — key lemma for restructuring) |
| SuccChainFMCS.lean | 1411-1440 | `neg_not_in_boundary_resolution_set` (SORRY — should be REMOVED/REPLACED) |
| SuccChainFMCS.lean | 1445-1456 | `neg_not_in_constrained_successor_seed_restricted` (uses sorry — should use new lemma) |
| SuccChainFMCS.lean | 1512-1548 | `constrained_successor_seed_restricted_consistent` (SORRY — needs restructuring) |
| SuccChainFMCS.lean | 1306-1324 | `neg_not_in_g_content_when_F_in` (PROVEN — use for BRS elements) |
| SuccChainFMCS.lean | 1332-1346 | `neg_not_in_deferralDisjunctions` (PROVEN — use for BRS elements) |
| SuccChainFMCS.lean | 1356-1366 | `neg_not_in_p_step_blocking_restricted` (PROVEN — use for BRS elements) |
| SuccExistence.lean | 284-287 | `boundary_resolution_set` definition (Fix A1 as currently coded) |
