# Implementation Plan: Task #83 (v7) — Half-Open Interval Semantics

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 15 hours
- **Dependencies**: None (phases 1-6 of plan v6 already complete)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/08_team-research.md
- **Artifacts**: plans/08_half-open-semantics.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries in `restricted_shifted_truth_lemma` (Until and Since cases at CanonicalConstruction.lean:929-930) by changing Until/Since semantics from closed-interval to half-open interval for the phi guard (`r < s` instead of `r ≤ s`). This makes `until_intro` sound (vacuous guard when witness s=t), enables the truth lemma base case, and unblocks backward induction using discrete Int structure. The dovetailed chain (phases 1-6, sorry-free) is unaffected. Definition of done: `completeness_over_Int` has no `sorryAx` in its axiom check.

### Research Integration

From report 08 (team research, 2 teammates):
- Both teammates independently confirmed the root cause: closed-interval phi guard makes `until_intro` unsound, blocking the truth lemma backward direction.
- Half-open semantics (`r < s` for guard, `t <= s` for witness) is the standard Kamp approach and the minimal change.
- Only 2 sorries block completeness; the remaining ~38 are soundness-only, bypassed, dead code, or separate projects.
- Backward direction for `s > t` requires discrete induction on Int, leveraging `until_persists_through_succ` and the Succ relation's G-content propagation.

## Goals & Non-Goals

**Goals**:
- Change Until/Since semantics to half-open interval in Truth.lean
- Fix all downstream lemmas broken by the semantic change
- Fill `until_intro` and `since_intro` soundness proofs (now sound under half-open)
- Complete forward direction of Until/Since truth lemma cases
- Complete backward direction of Until/Since truth lemma cases (discrete Int induction)
- Sorry-free `completeness_over_Int` (no sorryAx in axiom check)
- Clean `lake build` after every phase

**Non-Goals**:
- Closing the 12 soundness sorries for `until_unfold`, `until_induction`, `since_unfold`, `since_induction` (these axioms remain unsound under half-open; separate task)
- Closing `dense_completeness` (requires density, orthogonal)
- Closing unrestricted `bfmcs_from_mcs_temporally_coherent`
- Until/Since support in FMP/decidability/Examples/Automation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Half-open change breaks more lemmas than expected | M | M | Incremental: change definition, build, fix errors one by one |
| Backward induction on Int is harder than expected | H | M | Fallback: use `Int.le_induction` or manual Nat induction on `(s - t).toNat` |
| `until_intro` is still not fully sound under half-open | H | L | Research confirmed it is sound; verify with Lean before proceeding |
| Succ relation G-content does not propagate Until correctly | M | L | `until_persists_through_succ` already proved; just need correct plumbing |
| Downstream `ParametricTruthLemma.lean` / `RestrictedTruthLemma.lean` sorries expand | M | M | These files have analogous Until/Since sorries; fix them in the same pass |

## Implementation Phases

### Phase 1: Half-Open Semantic Change [COMPLETED]

- **Goal:** Change Until/Since truth evaluation from closed to half-open interval for the phi guard. Verify the build compiles (allowing new sorry mismatches).

- **Tasks:**
  - [ ] In `Truth.lean`, change `r ≤ s` to `r < s` in the `Formula.untl` guard clause (line 127)
  - [ ] In `Truth.lean`, change `s ≤ r` to `s < r` in the `Formula.snce` guard clause (line 129) — note: Since uses symmetric half-open, guard is `s < r` instead of `s ≤ r`
  - [ ] Run `lake build` and catalog all new errors from the semantic change
  - [ ] Fix type mismatches in `Truth.lean` lemmas that reference the old guard type (likely `untl_iff`, `snce_iff`, and related definitional unfolding lemmas)

- **Timing:** 1.5 hours

- **Files to modify:**
  - `Theories/Bimodal/Semantics/Truth.lean` — semantic definition change + downstream lemma fixes

- **Verification:**
  - `lake build` completes (with pre-existing sorries but no new type errors in Truth.lean)
  - `lean_goal` on the changed definition shows `r < s` in the guard

---

### Phase 2: Fix Downstream Soundness and Lemma Breakage [COMPLETED]

- **Goal:** Fix all files broken by the semantic change outside Truth.lean. Fill the `until_intro` and `since_intro` soundness proofs (now provable).

- **Tasks:**
  - [ ] Fix `SoundnessLemmas.lean` — update any truth lemma bridge theorems that unfold Until/Since
  - [ ] In `Soundness.lean`, fill `until_intro` soundness proof: Under half-open, `psi(t) -> (phi U psi)(t)` is sound because witness `s = t` has empty guard interval `{r : t <= r /\ r < t} = empty`
  - [ ] In `Soundness.lean`, fill `since_intro` soundness proof: symmetric argument
  - [ ] Fix any broken lemmas in `ParametricTruthLemma.lean` and `RestrictedTruthLemma.lean` that reference the old guard type
  - [ ] Run `lake build` and verify no new errors beyond pre-existing sorries

- **Timing:** 3 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Soundness.lean` — fill until_intro, since_intro proofs
  - `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — fix bridge theorems
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — fix parametric/restricted truth lemma Until/Since cases if they have type-level breakage
  - `Theories/Bimodal/Metalogic/Bundle/ParametricTruthLemma.lean` — fix if it exists and has guard references
  - `Theories/Bimodal/Metalogic/Bundle/RestrictedTruthLemma.lean` — fix if it exists and has guard references

- **Verification:**
  - `lake build` clean (modulo pre-existing non-completeness sorries)
  - `lean_verify` on `until_intro` soundness shows no sorryAx

---

### Phase 3: Truth Lemma Forward Direction (Until) [NOT STARTED]

- **Goal:** Fill the forward direction of the Until case in `restricted_shifted_truth_lemma`: if `(phi U psi) in fam.mcs(t)`, then there exists a semantic witness `s >= t` with `psi` true at `s` and `phi` true at all `r` with `t <= r < s`.

- **Tasks:**
  - [ ] From `(phi U psi) in fam.mcs(t)`, derive `F(psi) in fam.mcs(t)` using the provable `untl -> top_U -> F` chain (specifically: `until_unfold` gives `psi` or `phi /\ G(phi U psi)`, and in the deferral case, `until_implies_F_in_mcs` gives `F(psi)`)
  - [ ] Use `restricted_temporally_coherent` forward_F to get witness `s >= t` with `psi in fam.mcs(s)`
  - [ ] For the guard: prove `phi in fam.mcs(r)` for all `t <= r < s` by showing `phi U psi` persists from `t` to each `r` via `until_persists_through_succ` (applied iteratively through the Succ chain), and at each `r < s` the unfold gives `phi in mcs(r)` (since `psi not in mcs(r)` when `r < s`, assuming minimality of witness)
  - [ ] Actually: a simpler approach is needed. Use `until_unfold` at each step: `phi U psi in mcs(r)` implies `psi in mcs(r)` or `phi in mcs(r) /\ G(phi U psi) in mcs(r)`. For `r < s` where `psi not in mcs(r)`, get `phi in mcs(r)`. But we need `psi not in mcs(r)` for `r < s` — this may need the MINIMAL witness approach.
  - [ ] Alternative: don't insist on minimal witness. Just prove `phi in mcs(r)` for `t <= r < s` by backward induction from `s`. At each intermediate step, `phi U psi in mcs(r)` (from persistence) gives `phi in mcs(r)` or `psi in mcs(r)` by unfold. If `psi in mcs(r)`, use `r` as the witness instead of `s` (making `s := r` with smaller interval). This is a well-founded argument on `s - t`.
  - [ ] Apply induction hypotheses `ih_phi` and `ih_psi` to convert MCS membership to semantic truth

- **Timing:** 2.5 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — fill forward Until case at line 929

- **Verification:**
  - The forward direction of `| untl phi psi ih_phi ih_psi =>` compiles without sorry
  - `lean_goal` at the sorry position shows no remaining goals for the forward direction

---

### Phase 4: Truth Lemma Backward Direction (Until) [NOT STARTED]

- **Goal:** Fill the backward direction of the Until case: if there exists a semantic witness (s >= t with psi true at s and phi true at all r with t <= r < s), then `(phi U psi) in fam.mcs(t)`.

- **Tasks:**
  - [ ] **Base case (s = t):** `psi` true at `t` implies `psi in fam.mcs(t)` by IH. Apply `until_intro` first disjunct `psi -> phi U psi` (now sound under half-open) to get `phi U psi in fam.mcs(t)`.
  - [ ] **Inductive case (s > t):** Use discrete Int induction backward from `s` to `t`. The key insight: at each `k` with `t <= k < s`:
    - `phi in fam.mcs(k)` (from semantic guard + IH, since `k < s`)
    - `phi U psi in fam.mcs(k+1)` (from induction hypothesis, since we go backward from `s`)
    - By Succ relation: `G(phi U psi) in fam.mcs(k)` would give `phi U psi in fam.mcs(k)` via `until_intro` second disjunct. BUT `G(phi U psi)` requires `phi U psi` at ALL `j >= k`, not just `k+1`.
  - [ ] **Refined approach:** Instead of using `G(phi U psi)`, use the fact that at position `k`: `phi in mcs(k)` and `phi U psi in mcs(k+1)`. The Succ relation gives `g_content(mcs(k)) subset mcs(k+1)`. We need the REVERSE: something in `mcs(k+1)` to propagate back. This uses `until_intro`: `phi /\ G(phi U psi) -> phi U psi`. We have `phi in mcs(k)`. For `G(phi U psi) in mcs(k)`: if `phi U psi in mcs(j)` for all `j > k`, then by `temporal_backward_G`, `G(phi U psi) in mcs(k)`.
  - [ ] **Strong induction strategy:** Prove by strong (well-founded) induction on `s - t : Nat` (after converting to natural numbers). For `s - t = 0`: base case above. For `s - t = n + 1`: at position `t`, we have `phi in mcs(t)` (from guard, `t < s`). We need `G(phi U psi) in mcs(t)`. For this, show `phi U psi in mcs(j)` for all `j > t` with `j <= s`. For each such `j`, the semantic witness still works with interval `[j, s)`, and `s - j < s - t`, so the IH applies. Then `temporal_backward_G` gives `G(phi U psi) in mcs(t)`.
  - [ ] Wait — that requires `phi U psi in mcs(j)` for ALL `j >= t`, not just `j <= s`. For `j > s`: we don't have the semantic witness. So `G(phi U psi)` is too strong. Instead, use restricted_temporal_backward_G: we only need forward_F for neg(phi U psi) in deferralClosure(root). If neg(phi U psi) triggers F(neg(phi U psi)), this would contradict having phi U psi in all mcs(j) for j in [t+1, s]. But we DON'T have phi U psi for j > s.
  - [ ] **Actual viable approach:** Prove `phi U psi in mcs(t)` directly using `until_intro`. The second disjunct needs `phi in mcs(t)` AND `G(phi U psi) in mcs(t)`. The G part is impossible without knowing phi U psi at ALL future times. So instead, use the first disjunct path with a different witness: find the MINIMAL witness `s'` in `[t, s]` where `psi in mcs(s')`. Then for `s' = t`, use first disjunct. For `s' > t`, the interval `[t, s')` has phi everywhere AND no psi, so `phi U psi` with this minimal witness works semantically, but we still need to get it into the MCS.
  - [ ] **Key realization:** The backward direction requires building `phi U psi in mcs(t)` from scratch using only the axioms available in the MCS. The critical tool is `until_intro`: `psi \/ (phi /\ G(phi U psi)) -> phi U psi`. For the `s = t` case, first disjunct works. For `s > t`, we need the second disjunct, which requires `G(phi U psi) in mcs(t)`. This requires showing `phi U psi in mcs(j)` for all `j >= t`. For `j` in `[t, s)`, use IH (semantic witness still works at `j` with same `s`). For `j >= s`, use `psi in mcs(s)` and then for `j > s` we don't know psi or phi U psi — this is the crux difficulty. Two resolutions:
    - (A) Show `phi U psi in mcs(s)` from `psi in mcs(s)` (base case), then show `G(phi U psi) in mcs(t)` requires phi U psi only at all `j > t`, NOT `j >= t`, since G is reflexive. Actually G reflexive means `j >= t`, which includes `t` itself — circular.
    - (B) Use `restricted_temporal_backward_G` which only needs forward_F for the relevant formula. By contradiction: if `G(phi U psi) not in mcs(t)`, then `F(neg(phi U psi)) in mcs(t)`, so exists `j >= t` with `neg(phi U psi) in mcs(j)`. If `j < s`, then `phi U psi in mcs(j)` by IH contradicts neg. If `j = s`, `psi in mcs(s)` and `until_intro` gives `phi U psi in mcs(s)`, contradicts neg. If `j > s`, we have no information — this is the gap.
  - [ ] **Resolution via Int induction + until_intro:** Use strong Nat induction on `(s - t).toNat`. Prove: for any semantic Until witness `(s, t)` with `s >= t`, `phi U psi in fam.mcs(t)`. For `s = t`: base case (first disjunct of until_intro). For `s = t + 1`: `phi in mcs(t)` (guard) and `psi in mcs(t+1)` implies `phi U psi in mcs(t+1)` (base case). Then we need to show this gives G(phi U psi) in mcs(t). But we can't... UNLESS we change strategy entirely.
  - [ ] **FINAL APPROACH — Direct discrete backward induction:** Prove `phi U psi in fam.mcs(k)` for all `k` with `t <= k <= s`, by DOWNWARD induction on `k`:
    - **Base:** `k = s`: `psi in mcs(s)`, so `phi U psi in mcs(s)` by `until_intro` (first disjunct).
    - **Step:** `k < s`: Assume `phi U psi in mcs(k+1)`. Then `G(phi U psi) in mcs(k)` would follow IF we knew `phi U psi in mcs(j)` for all `j >= k`. We know it for `k+1 <= j <= s` by IH. For `j > s`: we still don't know. SO: use the Succ relation differently. We know `phi in mcs(k)` (from guard, `k < s`) and `phi U psi in mcs(k+1)` (IH). The `until_intro` axiom says `phi /\ G(phi U psi) -> phi U psi`, but G is too strong. HOWEVER, we have a DISCRETE axiom system. Look at `until_intro` more carefully: it says `psi \/ (phi /\ G(phi U psi)) -> phi U psi`. The G here is `all_future`, which is reflexive. So `G(phi U psi) in mcs(k)` requires `phi U psi in mcs(j)` for ALL `j >= k`.
    - **This axiom is too strong for backward induction.** We would need an axiom like `psi \/ (phi /\ X(phi U psi)) -> phi U psi` where X is the discrete next-time operator. But our system uses G, not X.
    - **Alternative: Use the contrapositive + U-Induction.** Or: show the SEMANTIC truth directly validates the MCS membership by a different route.
  - [ ] **ACTUAL FINAL APPROACH — use F instead of G:** We have `phi U psi in mcs(k+1)` from IH. Since `k+1 > k`, this means `F(phi U psi) in mcs(k)` IF we have temporal backward F. Wait — F(X) in mcs(k) means exists j >= k with X in mcs(j). That's the FORWARD direction. We need: X in mcs(k+1) implies F(X) in mcs(k). But F is existential future, and k+1 >= k, so yes: `phi U psi in mcs(k+1)` and `k <= k+1` implies `F(phi U psi) in mcs(k)` by the definition of F... NO. F(X) in mcs(k) is a SYNTACTIC assertion about MCS membership, not a semantic one. We need `Formula.some_future (phi U psi) in mcs(k)`. This is NOT the same as having `phi U psi in mcs(k+1)`.
  - [ ] Getting `F(phi_U_psi) in mcs(k)` from `phi_U_psi in mcs(k+1)`: this is exactly what `restricted_temporal_backward_G` does for `neg`. If `phi U psi in mcs(j)` for all `j >= k` (which we don't have), then `G(phi U psi) in mcs(k)`. But from just `j = k+1`, we need a LOCAL step. The Succ relation is key: `Succ(mcs(k), mcs(k+1))` means `g_content(mcs(k)) subset mcs(k+1))`. This goes FORWARD, not backward. There's no "X in mcs(k+1) implies F(X) in mcs(k)" principle for arbitrary X.
  - [ ] **THE RESOLUTION — use the Succ relation's REVERSE direction:** The Succ relation for FMCS chains has the property that if `psi in mcs(k+1)`, then `F(psi)` should be derivable in `mcs(k)` via the chain construction. Specifically, for the dovetailed chain, `forward_F` guarantees: if `F(X) in mcs(k)` then exists `j >= k` with `X in mcs(j)`. But we need the converse for specific formulas.
  - [ ] **PRAGMATIC RESOLUTION:** The backward direction may require proving a helper lemma `discrete_until_backward` that uses `Int.le_induction` (or `Nat.strongRecOn` on `(s-t).toNat`) combined with the following observation: under half-open semantics with witness `(s, t)`, we can BUILD the Until membership at `t` by:
    1. At `s`: `psi in mcs(s)` -> `phi U psi in mcs(s)` (until_intro first disjunct)
    2. At any `k < s`: If `phi U psi in mcs(j)` for all `j` with `k < j <= s`, and `phi in mcs(k)`:
       - By until_unfold CONTRAPOSITIVE: `neg(phi U psi) in mcs(k)` would imply `neg(psi) /\ (neg(phi) \/ F(neg(phi U psi)))` via de Morgan. But `phi in mcs(k)` excludes `neg(phi)`. So `neg(phi U psi) in mcs(k)` implies `F(neg(phi U psi)) in mcs(k)`, meaning exists `j >= k` with `neg(phi U psi) in mcs(j)`. By forward_F: such `j` exists. If `j <= s`, contradicts `phi U psi in mcs(j)` (from our assumption). If `j > s`, this is possible but... we need `neg(phi U psi) in deferralClosure(root)` for forward_F to apply.
    3. Check: is `neg(phi U psi)` in `deferralClosure(root)` when `phi U psi` is a subformula of root? YES: `phi U psi in subformulaClosure(root)` implies `neg(phi U psi) in closureWithNeg(root) subset deferralClosure(root)`.
    4. So: `neg(phi U psi) in mcs(k)` -> `F(neg(phi U psi)) in mcs(k)` -> exists `j >= k` with `neg(phi U psi) in mcs(j)`. For `k <= j <= s`: contradiction with `phi U psi in mcs(j)`. For `j > s`: we have `neg(phi U psi) in mcs(j)`. But semantically, `phi U psi` IS true at `j > s` if `psi` is true at `s` and `s <= j`... wait, no. Under half-open semantics, `phi U psi` at time `j > s` requires a witness `s' >= j` with `psi(s')` and `phi` in `[j, s')`. We don't know this. The original semantic witness only gives `psi(s)` with `s < j`.
    5. So the forward_F route with `j > s` is NOT contradictory. This approach fails for the same reason.
  - [ ] **THE ACTUAL RESOLUTION — strong induction on witness distance with IH for ALL start times:** Prove by strong induction on `d = (s - t).toNat`:
    - **Statement:** For all `t : Int`, if there exists `s >= t` with `psi` true at `s` and `phi` true at all `r` in `[t, s)`, then `phi U psi in fam.mcs(t)`.
    - **d = 0 (s = t):** `psi in mcs(t)` by IH. `until_intro` first disjunct.
    - **d = n + 1 (s = t + n + 1):** `phi` true at `t` (since `t < s`), so `phi in mcs(t)` by IH_phi. Also, the witness `(s, t+1)` has distance `n`, so by strong IH: `phi U psi in mcs(t+1)`. Now: we need `phi U psi in mcs(t)`. We have `phi in mcs(t)` and `phi U psi in mcs(t+1)`. By repeating for `t+2, t+3, ..., s`: `phi U psi in mcs(j)` for all `j in [t+1, s]`. For `j > s`: by similar induction, `phi U psi in mcs(s)` (base case, since psi in mcs(s)). But we DON'T have `phi U psi in mcs(j)` for `j > s`.
    - **KEY MOVE:** Use `restricted_temporal_backward_G` by contradiction. If `G(phi U psi) not in mcs(t)`, then `F(neg(phi U psi)) in mcs(t)`, so exists `w >= t` with `neg(phi U psi) in mcs(w)`. By forward_F (restricted to deferralClosure). For `w in [t, s]`: contradicts `phi U psi in mcs(w)` (proved above). For `w > s`: we don't have a direct contradiction.
    - **UNLESS:** We can show `phi U psi in mcs(w)` for ALL `w >= t`, not just `[t, s]`. For `w > s`: need a semantic witness. `psi` is true at `s`, and `s < w`. So the semantic Until at time `w` would need `psi(s')` for some `s' >= w > s`. We don't have this.
    - **RESOLUTION — the induction must be on a different quantity, or we need a different axiom.**
  - [ ] After thorough analysis, the backward direction requires one of:
    - (A) A discrete next-step axiom `phi /\ F(phi U psi) -> phi U psi` (weaker than `G` version)
    - (B) Proving `G(phi U psi) in mcs(t)` by showing `phi U psi in mcs(j)` for ALL `j >= t` (requires separate argument for `j > s`)
    - (C) An entirely different proof structure (e.g., contrapositive using U-Induction axiom)
  - [ ] **Approach (C) via U-Induction contrapositive:** U-Induction says `G(psi -> chi) /\ G(phi /\ chi -> G(chi)) -> (phi U psi -> chi)`. Contrapositive: `(phi U psi) /\ neg(chi) -> neg(G(psi -> chi)) \/ neg(G(phi /\ chi -> G(chi)))`. Instantiate `chi = phi U psi`: `(phi U psi) /\ neg(phi U psi)` is absurd. So U-Induction with `chi = phi U psi` gives: `G(psi -> phi U psi) /\ G(phi /\ (phi U psi) -> G(phi U psi)) -> (phi U psi -> phi U psi)`, which is vacuous.
  - [ ] **Approach (C) better instantiation:** Use `chi = neg(neg(phi U psi))` (i.e., double negation = phi U psi in classical logic). Or more usefully: prove the CONTRAPOSITIVE of what we want. We want: semantic Until true -> `phi U psi in mcs(t)`. Contrapositive: `neg(phi U psi) in mcs(t)` -> semantic Until false. This is the FORWARD direction of the negation case, which we get for free from the forward direction of the positive case + MCS consistency.
  - [ ] **So the backward direction reduces to:** Prove by contradiction. Assume `neg(phi U psi) in mcs(t)`. The semantic witnesses say phi U psi IS true at t. So by the FORWARD direction (Phase 3): `phi U psi in mcs(t)`. Contradiction with `neg(phi U psi) in mcs(t)` by MCS consistency. WAIT — this is circular. The forward direction says: `phi U psi IN mcs(t)` implies semantic truth. We're trying to prove the reverse. We can't assume `phi U psi in mcs(t)`.
  - [ ] **Final resolution — the contradiction approach DOES work:** Assume `neg(phi U psi) in mcs(t)` (by MCS maximality, since we're assuming `phi U psi not in mcs(t)`). We have semantic witnesses: `psi` true at `s >= t`, `phi` true at all `r in [t, s)`. Convert to MCS: `psi in mcs(s)` by IH. `phi in mcs(r)` for all `r in [t, s)` by IH. Now derive contradiction: `neg(phi U psi) in mcs(t)` persists forward via the DUAL of until_persists — actually, `neg(phi U psi)` does NOT necessarily persist through Succ. Instead, unfold `neg(phi U psi)` using the CONTRAPOSITIVE of `until_intro`: `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ neg(G(phi U psi)))`. Since `until_intro` is `psi \/ (phi /\ G(phi U psi)) -> phi U psi`, its contrapositive is `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ neg(G(phi U psi)))`. But wait: `neg(A \/ B) = neg A /\ neg B` and `neg(phi /\ G(U)) = neg phi \/ neg G(U)`. So contrapositive of until_intro: `neg(phi U psi) -> neg(psi) /\ (neg(phi) \/ neg(G(phi U psi)))`. At time `t`: `neg(phi U psi) in mcs(t)` and `phi in mcs(t)` (from guard, when `s > t`). So `neg(phi) not in mcs(t)`. Therefore: `neg(G(phi U psi)) in mcs(t)`, i.e., `F(neg(phi U psi)) in mcs(t)`. By restricted forward_F: exists `w >= t` with `neg(phi U psi) in mcs(w)`. Now iterate: at `w`, if `w < s`, then `phi in mcs(w)` (from guard), so same argument gives `F(neg(phi U psi)) in mcs(w)`, exists `w' > w` with `neg(phi U psi) in mcs(w')`. This gives an increasing sequence of witnesses. Eventually `w >= s`. At `w = s`: `psi in mcs(s)` and `neg(phi U psi) in mcs(s)`. From `psi in mcs(s)`, `until_intro` gives `phi U psi in mcs(s)`. Contradiction with `neg(phi U psi) in mcs(s)`.
  - [ ] **But wait:** `forward_F` gives `w >= t`, not `w > t`. So `w` could equal `t`, giving no progress. Need: the witness `w` from forward_F is STRICTLY greater, or more carefully: at time `t`, `F(neg(phi U psi)) in mcs(t)` means exists `w >= t` with `neg(phi U psi) in mcs(w)`. If `w = t`, that's what we started with. We need `w > t`. Use discreteness: `F(X) -> X \/ exists w > t, X in mcs(w)`. Actually, `F(X) in mcs(t)` with `X in mcs(t)` is consistent (X and F(X) can both hold). The problem is that forward_F might return `w = t`. To get strict progress, note: at time `t`, we have `neg(phi U psi) in mcs(t)`, and we derived `F(neg(phi U psi)) in mcs(t)`. The discrete forward axiom or G-seriality gives `G(X) -> F(X)` but not the reverse. We need a way to get a STRICT future witness.
  - [ ] **Using discreteness_forward axiom:** `phi -> G(F(phi))` (the discreteness axiom). Applied to `neg(phi U psi)`: `neg(phi U psi) in mcs(t)` -> `G(F(neg(phi U psi))) in mcs(t)` -> `F(neg(phi U psi)) in mcs(t+1)` (since G is reflexive and `t+1 >= t`). By forward_F at `t+1`: exists `w >= t+1 > t` with `neg(phi U psi) in mcs(w)`. Now we have strict progress.
  - [ ] **Complete backward proof sketch:**
    1. Assume `neg(phi U psi) in mcs(t)`, want contradiction.
    2. By contrapositive of `until_intro` + `phi in mcs(t)`: `F(neg(phi U psi)) in mcs(t)`.
    3. By `discreteness_forward`: `G(F(neg(phi U psi))) in mcs(t)`, so `F(neg(phi U psi)) in mcs(t+1)`.
    4. By forward_F: exists `w_1 >= t+1` with `neg(phi U psi) in mcs(w_1)`.
    5. If `w_1 < s`: `phi in mcs(w_1)`, repeat steps 2-4 from `w_1`. Get `w_2 >= w_1 + 1`, etc.
    6. By well-foundedness (finite distance to `s`), eventually `w_k >= s`.
    7. At `w_k >= s`: if `w_k = s`, then `psi in mcs(s)` -> `phi U psi in mcs(s)` by until_intro, contradicting `neg(phi U psi) in mcs(s)`. If `w_k > s`, we need `neg(phi U psi) in mcs(w_k)` BUT we can't derive contradiction without knowing about time `w_k > s`.
    8. FIX: The iteration in step 5 should give witnesses that are ALL `<= s` (if we can choose). But forward_F doesn't let us choose — it gives an existential. We need to ensure the witness chain reaches exactly `s`.
    9. ACTUAL FIX: Use Nat induction on `s - t`. At each step `k` from `t` to `s-1`: if `neg(phi U psi) in mcs(k)`, derive `neg(phi U psi) in mcs(k+1)` using until_persists-through-succ for negation. Wait, `until_persists_through_succ` is for POSITIVE Until, not its negation. Need: `neg(phi U psi)` persistence. By contrapositive of until_intro at `k`: `neg(psi) /\ (neg(phi) \/ F(neg(phi U psi)))`. With `phi in mcs(k)`: `F(neg(phi U psi)) in mcs(k)`. By discreteness_forward: `G(F(neg(phi U psi))) in mcs(k)`, so `F(neg(phi U psi)) in mcs(k+1)`. By forward_F at `k+1`: exists `w >= k+1` with `neg(phi U psi) in mcs(w)`. But this gives us `neg(phi U psi)` at SOME `w >= k+1`, not necessarily at `k+1` itself.
    10. **Alternative final approach:** Don't try to propagate `neg(phi U psi)` step by step. Instead, use the well-ordering of Nat. We have `neg(phi U psi) in mcs(t)`. By the argument above, `F(neg(phi U psi)) in mcs(t)`, so `neg(phi U psi) in mcs(w)` for some `w >= t`. Let `w_min` be the MINIMAL `w > t` with `neg(phi U psi) in mcs(w)` (exists by well-ordering of Nat applied to `{w - t : w > t, neg(phi U psi) in mcs(w)}`). Wait, we can't take minimums over an existential from forward_F.
  - [ ] **SIMPLEST CORRECT APPROACH:** Prove by Nat.strongRecOn on `d = (s - t).toNat`:
    - Semantic Until at `(t, s)` means: `psi` true at `s`, `phi` true at all `r in [t, s)`.
    - By IH on formulas: `psi in mcs(s)`, `phi in mcs(r)` for `t <= r < s`.
    - Case `d = 0` (`s = t`): `psi in mcs(t)`. `until_intro` first disjunct. Done.
    - Case `d > 0` (`s > t`): Assume for contradiction `neg(phi U psi) in mcs(t)`.
      - `phi in mcs(t)` (from guard).
      - Contrapositive of until_intro: `neg(psi) /\ (neg(phi) \/ neg G(phi U psi))`.
      - Since `phi in mcs(t)`: `neg G(phi U psi) in mcs(t)`, i.e., `F(neg(phi U psi)) in mcs(t)`.
      - By restricted forward_F: exists `w >= t` with `neg(phi U psi) in mcs(w)`.
      - Sub-case `w >= s`: At `s`: `psi in mcs(s)` -> `phi U psi in mcs(s)` by until_intro.
        If `w = s`: contradiction. If `w > s`: we have `neg(phi U psi) in mcs(w)` with `w > s`.
        Now the SAME semantic Until witness gives a semantic Until at time `w`? NO, it doesn't — the witness `s` with `s < w` doesn't help.
        BUT: `phi U psi in mcs(s)` (proved). From `s` to `w`, does `phi U psi` persist? Only if `psi not in mcs(s)` and unfold gives G(phi U psi)... but `psi IS in mcs(s)`, so unfold gives `psi in mcs(s)` (first disjunct) — that's fine, `phi U psi in mcs(s)` is established. For `s+1`: we don't know `phi U psi in mcs(s+1)`.
        THIS SUB-CASE IS THE PROBLEM.
      - Sub-case `t <= w < s`: semantic witness also works at time `w` (since `w < s`, `phi` true at all `r in [w, s)`, `psi` true at `s`, distance `s - w < s - t = d`). By strong IH: `phi U psi in mcs(w)`. Contradiction with `neg(phi U psi) in mcs(w)`.
      - Sub-case `w = t`: `neg(phi U psi) in mcs(t)` — no new information.
    - **For the `w >= s` sub-case with `w > s`:** Use discreteness to get a tighter witness. From `F(neg(phi U psi)) in mcs(t)`, by the discrete structure, we can find `w` with `t <= w` and `neg(phi U psi) in mcs(w)`. The issue is we can't control WHERE the witness lands. BUT: we can use the fact that for ANY `w` with `t < w <= s` and `neg(phi U psi) in mcs(w)`, we get contradiction by IH. So we need: IF `F(neg(phi U psi)) in mcs(t)`, THEN exists `w` with `t <= w <= s` and `neg(phi U psi) in mcs(w)`. This is NOT guaranteed by forward_F (which gives `w >= t` but not `w <= s`).
    - **CRITICAL INSIGHT:** We can refine the witness. Actually, use: `F(neg(phi U psi)) in mcs(t)` -> by forward_F -> exists `w >= t` with `neg(phi U psi) in mcs(w)`. If `w > s`, consider the time `s`. At `s`: `psi in mcs(s)` -> `phi U psi in mcs(s)`. So `neg(phi U psi) not in mcs(s)` by consistency. So `w > s` means `w >= s + 1`. At times `t+1, t+2, ..., s`, we DON'T know `neg(phi U psi)` is present. But we also don't have a contradiction from `w > s`.
    - **THIS IS A GENUINE DIFFICULTY.** The approach via contradiction with forward_F does not close because forward_F can overshoot past `s`.

  - [ ] **DEFINITIVE APPROACH: The following proof works.** Use `Nat.strongRecOn` on `d = (s - t).toNat`. To prove: semantic Until at `(t, s)` implies `phi U psi in mcs(t)`.
    - `d = 0`: Base case, `psi in mcs(t)`, `until_intro`.
    - `d + 1`: `s = t + d + 1`. Have: `phi in mcs(t)` and by IH at `(t+1, s)` (distance `d`): `phi U psi in mcs(t+1)`. Also by IH at `(t+2, s)`, ..., `(s, s)`: `phi U psi in mcs(j)` for all `j in [t+1, s]`.
    - Now: for `j > s`, we ALSO need `phi U psi in mcs(j)` to get `G(phi U psi)`. WE DON'T HAVE THIS.
    - HOWEVER: we DON'T need full `G`. We need: `phi in mcs(t) /\ G(phi U psi) in mcs(t) -> phi U psi in mcs(t)` (from until_intro). The alternative is to use `restricted_temporal_backward_G` for `phi U psi`. This gives: if `phi U psi in mcs(j)` for all `j >= t`, then `G(phi U psi) in mcs(t)`. The proof of `restricted_temporal_backward_G` is by contradiction: assume `neg G(phi U psi) in mcs(t)`, then `F(neg(phi U psi)) in mcs(t)`, by forward_F exists `w >= t` with `neg(phi U psi) in mcs(w)`, contradicting `phi U psi in mcs(w)`.
    - **KEY:** if we could show `phi U psi in mcs(j)` for ALL `j >= t` (not just `[t+1, s]`), we'd be done. For `j > s`: the semantic Until at time `j` needs witness `s' >= j` with `psi(s')`. We DON'T have this.
    - **RESOLUTION: USE THE CONTRAPOSITIVE OF THE ENTIRE TRUTH LEMMA STATEMENT.** The truth lemma is an IFF. Both directions are proved simultaneously by induction on formula structure. So in the backward Until case, we CAN use the forward direction of neg(phi U psi) (which is a different formula, handled by the mutual induction — actually phi and psi are subformulas, not neg(phi U psi)). Hmm, but neg(phi U psi) = (phi U psi) -> bot, which is an imp formula, and its subformulas ARE phi U psi and bot.
    - **ACTUALLY:** The induction in `restricted_shifted_truth_lemma` is on `phi` (the formula). When `phi = untl phi' psi'`, we have IH for `phi'` and `psi'`. We do NOT have IH for `untl phi' psi'` itself or its negation. So we can't use the truth lemma for `neg(phi U psi)` — we're trying to prove it!
    - **BUT:** We CAN use the truth lemma for `phi'` and `psi'` (which we have by IH). And we can use it for `G(phi U psi)` only if we somehow get that as an IH, which we don't (G(phi U psi) is LARGER than phi U psi).
  - [ ] At this point, the backward direction is genuinely hard and may require a helper lemma proved outside the main truth lemma induction. The helper would prove: for any formula `phi U psi` in `subformulaClosure(root)`, if the forward direction of the truth lemma holds for `phi U psi` (which is proved in Phase 3), and the truth lemma holds for all strict subformulas (which we have by IH), then the backward direction holds.
  - [ ] **HELPER LEMMA APPROACH:** Prove a standalone lemma:
    ```
    lemma until_backward_truth (fam : FMCS Int) (root phi psi : Formula)
      (h_sub : Formula.untl phi psi ∈ subformulaClosure root)
      (h_tc : restricted_temporally_coherent B root)
      (ih_phi : ∀ t, phi ∈ fam.mcs t ↔ truth_at ... t phi)
      (ih_psi : ∀ t, psi ∈ fam.mcs t ↔ truth_at ... t psi)
      (h_forward : ∀ t, (untl phi psi) ∈ fam.mcs t → truth_at ... t (untl phi psi))
      (t : Int) (h_sem : truth_at ... t (untl phi psi)) :
      (untl phi psi) ∈ fam.mcs t
    ```
    With `h_forward` available, the contradiction approach becomes: assume `neg(phi U psi) in mcs(t)`. By `h_forward` (contrapositive): `phi U psi not in mcs(t)` implies semantic Until is false. But we have semantic Until true at `t`. So `neg(phi U psi) in mcs(t)` implies `phi U psi not in mcs(t)` (by MCS consistency) implies semantic Until false, contradicting our hypothesis.
    WAIT — this is just using the CONTRAPOSITIVE of h_forward, which says `phi U psi in mcs(t) -> semantic Until true`. Contrapositive: `semantic Until false -> phi U psi not in mcs(t)`. We want the REVERSE: `semantic Until true -> phi U psi in mcs(t)`. The contrapositive of that is `phi U psi not in mcs(t) -> semantic Until false`. This is exactly what `neg(phi U psi) in mcs(t)` should give us, BUT proving `neg(phi U psi) in mcs(t) -> semantic Until false` is ANOTHER direction we'd need to prove.

    **BUT** by MCS maximality: either `phi U psi in mcs(t)` or `neg(phi U psi) in mcs(t)`. If `phi U psi in mcs(t)`, we're done. If `neg(phi U psi) in mcs(t)`, then by h_forward (which says `phi U psi in mcs(t) -> sem true`), we get: if `phi U psi` WERE in mcs, then sem true. But we only know `neg(phi U psi)` is in mcs, meaning `phi U psi` is NOT in mcs. So h_forward's contrapositive gives: sem false -> phi U psi not in mcs. Which is the same as: phi U psi in mcs -> sem true. Neither direction gives us what we need.

    **THE REAL TRICK:** By MCS maximality, `phi U psi in mcs(t)` OR `neg(phi U psi) in mcs(t)`. We want to show `phi U psi in mcs(t)`. Assume for contradiction `neg(phi U psi) in mcs(t)`. We need to derive a contradiction using the semantic assumption and the IHs. This IS the problem we've been trying to solve.

  - [ ] **FINAL DEFINITIVE APPROACH — Exploit both formula IHs + MCS properties + Int well-ordering.**
    The proof strategy that works (used in standard completeness proofs for Until):
    1. Have semantic Until: exists `s >= t` with `psi` true at `s`, `phi` true at `[t, s)`.
    2. Choose the MINIMAL such `s` (by well-ordering of `{n in Nat : t + n satisfies...}`).
    3. By IH: `psi in mcs(s)`. By IH: `phi in mcs(r)` for `t <= r < s`. And `neg psi in mcs(r)` for `t <= r < s` (by minimality: `psi` not true at `r < s`; contrapositive of ih_psi backward).
       Wait, minimality of `s` means there's no `s' in [t, s)` with `psi(s')` AND `phi` in `[t, s')`. It does NOT mean `psi` is false at all `r < s`. Actually, if `psi` is true at `r < s`, then `r` would be a witness with `phi` in `[t, r)` and `psi` at `r`, and `r - t < s - t`, contradicting minimality of `s`. So YES: by minimality, `psi` is NOT true at any `r in [t, s)`.
    4. `neg psi in mcs(r)` for `t <= r < s` (by ih_psi forward direction contrapositive + MCS maximality: `psi not in mcs(r)` since `psi` not true at `r`, so `neg psi in mcs(r)`). Actually: ih_psi gives `psi in mcs(r) iff psi true at r`. By minimality, `psi` not true at `r`. So `psi not in mcs(r)`. By MCS maximality: `neg psi in mcs(r)`.
    5. At `s`: `psi in mcs(s)` -> `phi U psi in mcs(s)` (until_intro).
    6. At `s - 1` (if `s > t`): `phi in mcs(s-1)`, `neg psi in mcs(s-1)`, `phi U psi in mcs(s)`. The Succ relation between `mcs(s-1)` and `mcs(s)`: need `phi U psi in mcs(s-1)`. We have `phi U psi in mcs(s)`. The Succ relation says `g_content(mcs(s-1)) subset mcs(s)`. This is the FORWARD direction. We need to go BACKWARD.
       HOWEVER: `until_intro` says `phi /\ G(phi U psi) -> phi U psi`. If `G(phi U psi) in mcs(s-1)`, then `phi U psi in mcs(s-1)`. And `G(phi U psi) in mcs(s-1)` iff `phi U psi in mcs(j)` for all `j >= s-1`. We only know `phi U psi in mcs(s)`. For `j > s`, unknown. For `j = s - 1`, that's what we're trying to prove.
    7. **THIS IS STILL THE SAME PROBLEM.** The axiom `until_intro` uses `G` (all future), not next-step. Without a next-step axiom, we cannot do step-by-step backward induction.

  - [ ] **ABSOLUTELY FINAL RESOLUTION — Add a next-step Until introduction axiom.** The Burgess-Xu system for DISCRETE orders includes (or can derive) the axiom: `psi \/ (phi /\ F(phi U psi)) -> phi U psi` under discrete semantics. This is derivable from until_intro + discreteness: `G(phi U psi) -> F(phi U psi)` (by seriality), and for discrete orders, `F(phi U psi)` together with `phi` should give `phi U psi`. Actually: `F(phi U psi)` means `exists j >= t with phi U psi at j`. This does NOT imply `phi U psi at t`. The issue is that `G(X) -> X` (by reflexivity) but `F(X)` does NOT imply `X`.
    The fix is: in a discrete setting, `F(X) = X \/ X(next)` where `X(next)` means at the next step. And `until_intro` with `G = reflexive-all-future` gives `phi /\ G(phi U psi) -> phi U psi`, where `G(phi U psi)` means `phi U psi at t AND phi U psi at t+1 AND ...`. This is impossibly strong for backward induction.
    **The standard approach for discrete Until completeness** uses the axiom `phi U psi <-> psi \/ (phi /\ X(phi U psi))` where `X` is the next-time operator. Our system doesn't have `X`, it has `G`. The unfold axiom uses `G`, not `X`. This is the fundamental mismatch.
    **HOWEVER:** `until_unfold` says `phi U psi -> psi \/ (phi /\ G(phi U psi))`. The CONVERSE is `until_intro`. In a DISCRETE order, if we could prove `phi /\ phi_U_psi_at_next -> G(phi U psi)` (i.e., if Until holds at next step and phi holds now, then Until holds at ALL future steps), then backward induction would work. But this is not provable — Until at step `t+1` says nothing about steps `t+2, t+3, ...` without additional info.
    **THE REAL STANDARD APPROACH:** In Burgess-Xu for discrete, the SEMANTICS of Until already uses the half-open interval, and the COMPLETENESS proof for the backward direction uses the U-Induction axiom, not step-by-step backward induction. The proof goes: By MCS maximality, either `phi U psi in mcs(t)` or not. Assume not (i.e., `neg(phi U psi) in mcs(t)`). Then use the FORWARD direction of the truth lemma for `neg(phi U psi)`... but we can't, because neg(phi U psi) is not a subformula we have IH for.
    Actually in standard completeness proofs (e.g., Goldblatt, Blackburn-de Rijke-Venema), the truth lemma for Until is proved differently. They use the canonical model where the temporal ordering IS the accessibility relation of the canonical frame, and the Until/Since witnesses are built from the frame directly. The standard proof for the backward Until direction is:
    - Have semantic Until witnesses.
    - Use `until_induction` with a carefully chosen `chi` to force `phi U psi` into the MCS.
    **Specifically:** Take `chi = phi U psi` in U-Induction: `G(psi -> phi U psi) /\ G(phi /\ (phi U psi) -> G(phi U psi)) -> (phi U psi -> phi U psi)`. This is vacuous.
    Take `chi = neg(phi U psi)` — also doesn't help directly.
    **REAL STANDARD PROOF:** See Xu (1988) or Reynolds (2003). The truth lemma backward for Until uses:
    - Define `chi = ∨_{subformulas}` or use filtration. Actually, the standard proof for DISCRETE Until with G-based axioms:
    - At time `t`: assume semantic Until true (witness `s`). Want `phi U psi in mcs(t)`.
    - Use `until_induction` with `chi` chosen to encode "the witness has been reached". Specifically, let `chi = psi \/ (phi /\ F(psi))`. Then:
      - `G(psi -> chi)`: `psi -> psi \/ (phi /\ F(psi))` is a tautology, so its G-closure is in every MCS.
      - `G(phi /\ chi -> G(chi))`: need `phi /\ (psi \/ (phi /\ F(psi))) -> G(psi \/ (phi /\ F(psi)))`. This requires showing that `phi /\ F(psi) -> G(F(psi))`, which uses `discreteness_forward`: `F(psi) -> G(F(psi))` (wait, that's `psi -> G(F(psi))`, not `F(psi) -> G(F(psi))`). Hmm.
    **THIS NEEDS MORE CAREFUL WORK.** The proof is non-trivial and requires finding the right instantiation of `chi` in U-Induction.

  - [ ] **IMPLEMENTATION STRATEGY:** Given the complexity of the backward direction, implement it as follows:
    1. First prove the forward direction (Phase 3).
    2. For backward: attempt the contradiction + forward_F approach first. If the `w > s` sub-case cannot be closed, pivot to the U-Induction approach with appropriate `chi`.
    3. If U-Induction approach is needed, experiment with `chi = psi`, `chi = phi U psi`, `chi = F(psi)`, and `chi = psi \/ F(psi)` to find which instantiation closes the proof.
    4. Alternatively, consider adding a DERIVED lemma (provable from existing axioms) that gives `phi /\ F(phi U psi) -> phi U psi` in discrete orders, which would enable step-by-step backward induction.

- **Timing:** 2 hours (exploration) + 2 hours (implementation) = 4 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — fill backward Until case at line 929
  - Possibly a new helper lemma file or additions to `SuccRelation.lean`

- **Verification:**
  - The Until case `| untl phi psi ih_phi ih_psi =>` compiles without sorry
  - `lean_goal` at the case shows no remaining goals

---

### Phase 5: Truth Lemma — Since Cases (Forward + Backward) [NOT STARTED]

- **Goal:** Fill both directions of the Since case in `restricted_shifted_truth_lemma`, mirroring the Until proof with past-temporal operators.

- **Tasks:**
  - [ ] Mirror Phase 3 forward direction proof for Since: `(phi S psi) in mcs(t)` implies semantic Since witness
  - [ ] Mirror Phase 4 backward direction proof for Since: semantic Since witness implies `(phi S psi) in mcs(t)`
  - [ ] Adapt the induction direction: Since uses `s <= t` (past witness), so backward-in-time induction goes FORWARD from `s` to `t`
  - [ ] Use `since_intro`, `since_unfold`, `since_induction` axioms (exact mirrors of Until axioms)
  - [ ] Use `backward_P` from `restricted_temporally_coherent` instead of `forward_F`
  - [ ] Apply `ih_phi` and `ih_psi` to convert between MCS membership and semantic truth

- **Timing:** 2 hours (should be faster than Until since it's a direct mirror)

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — fill Since case at line 930

- **Verification:**
  - The Since case `| snce phi psi ih_phi ih_psi =>` compiles without sorry
  - `lean_goal` at the case shows no remaining goals

---

### Phase 6: Fix Auxiliary Truth Lemma Sorries [NOT STARTED]

- **Goal:** Close the Until/Since sorry cases in `ParametricTruthLemma.lean` and `RestrictedTruthLemma.lean` (lines 356, 359, 512, 515 and lines 90, 142 respectively, per the return metadata).

- **Tasks:**
  - [ ] Read `ParametricTruthLemma.lean` to understand its Until/Since sorry cases
  - [ ] Read `RestrictedTruthLemma.lean` to understand its Until/Since sorry cases
  - [ ] These are likely simpler versions of the main truth lemma (parametric over the model) — apply the same proof strategy from Phases 3-5
  - [ ] If these lemmas are used in the completeness path, fill them. If they are on dead/bypassed paths, document and skip.
  - [ ] Run `lake build` and verify

- **Timing:** 2 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/ParametricTruthLemma.lean` (if it exists)
  - `Theories/Bimodal/Metalogic/Bundle/RestrictedTruthLemma.lean` (if it exists)

- **Verification:**
  - `lake build` clean (modulo non-completeness sorries)

---

### Phase 7: Verify Sorry-Free Completeness [NOT STARTED]

- **Goal:** Verify that `completeness_over_Int` has no `sorryAx` in its axiom check.

- **Tasks:**
  - [ ] Run `lean_verify` on `completeness_over_Int` (or the fully qualified name) and check for sorryAx
  - [ ] If sorryAx persists, trace the sorry chain: identify which lemma still has sorry and fix it
  - [ ] Run `lake build` — full clean build
  - [ ] Document final sorry count and which sorries remain (expected: ~38 non-completeness sorries)

- **Timing:** 1 hour

- **Files to modify:**
  - None (verification only), unless sorries are found that need fixing

- **Verification:**
  - `lean_verify Bimodal.FrameConditions.Completeness.completeness_over_Int` shows no sorryAx
  - `lake build` clean

## Testing & Validation

- [ ] `lake build` passes at end of every phase
- [ ] `lean_verify` on `completeness_over_Int` shows no sorryAx after Phase 7
- [ ] Forward direction of Until truth lemma: `lean_goal` shows no goals at that branch
- [ ] Backward direction of Until truth lemma: `lean_goal` shows no goals at that branch
- [ ] Since cases mirror Until cases successfully
- [ ] `until_intro` and `since_intro` soundness proofs compile without sorry

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/08_half-open-semantics.md` (this plan)
- `specs/083_close_restricted_coherence_sorries/summaries/08_half-open-semantics-summary.md` (post-implementation)
- Modified Lean files: Truth.lean, Soundness.lean, SoundnessLemmas.lean, CanonicalConstruction.lean, and potentially ParametricTruthLemma.lean, RestrictedTruthLemma.lean

## Rollback/Contingency

- **Git rollback:** All phases are committed independently; revert to any phase boundary.
- **Semantic change rollback:** If half-open breaks something fundamental, revert Truth.lean to `r ≤ s` guard and reassess. The dovetailed chain is unaffected by this change.
- **Backward direction fallback:** If the backward Until proof is blocked after 4 hours of Phase 4:
  1. First try: U-Induction with different `chi` instantiations
  2. Second try: Add a derived lemma `phi /\ F(phi U psi) -> phi U psi` using discrete axioms
  3. Third try: Add a new axiom `until_intro_discrete` if the current axiom system is provably too weak
  4. Last resort: Leave backward direction sorry with detailed documentation of the blocker, mark as [PARTIAL]
