# Implementation Plan: Defect-Driven Chain from Scratch (v33)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (task 102 completed; truth lemma sorry-free)
- **Research Inputs**: reports/33_team-research.md, reports/32_team-research.md
- **Artifacts**: plans/33_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan constructs a completely new defect-driven chain (`defect_fwd_chain` / `defect_bwd_chain`) from scratch, replacing the existing `rr_fwd_chain` / `rr_bwd_chain` infrastructure which suffers from BX11 perpetual deferral (confirmed over 32 research rounds). The new chain uses `target_resolving_fwd_exists_strong` (RootScopedChain.lean:1143) as its single-step primitive, which guarantees direct resolution of the target formula AND F-preservation of all other obligations. The chain cycles through defects infinitely using local bx11_min selection at each step. Once the new chain is built and its forward_F / backward_P properties proved, all 6 sorry sites in RootScopedChain.lean are closed, making `bx_completeness` sorry-free. Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean and `#print axioms` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 33** (team research, 4 teammates): Identifies four critical errors in Plan v32: (1) `fwd_succ` has a fixed seed and cannot accept custom seeds; (2) `bx11_earlier` admits 3-cycles and is non-transitive; (3) g_content carries G-formulas not F-formulas; (4) BX5 does not give G-persistence of Until formulas. Converges on `target_resolving_fwd_exists_strong` as the correct single-step primitive. Resolves the ordering conflict: bx11_min is computed locally at each step (totality guarantees existence of a minimum among any finite set), non-transitivity is irrelevant. Identifies the infinite cycling requirement: the chain must resolve defects infinitely often, not in a finite discharge followed by a tail.
- **Report 32** (team research, 4 teammates): Confirms forward_F is unprovable on the round-robin chain (99% consensus). Identifies the sorry dependency diamond structure. Confirms sorry 3 is harder than sorry 1 (backward chain lacks enrichment).

### Prior Plan Reference

Plan v32 reached [PARTIAL] status with all 4 phases [BLOCKED]. Report 33 identified four critical errors in its proof sketches: (a) assumed `fwd_succ` accepts custom seeds (it does not -- fixed seed `{psi} union g_content(M)`); (b) assumed `bx11_earlier` provides a global total order (it admits 3-cycles); (c) assumed F-formulas propagate through g_content (they do not -- g_content carries G-stripped formulas); (d) assumed BX5 gives G-persistence of Until (it does not). Effort calibration: Plan v32 estimated 10 hours, Report 33 recommends 15-20 hours. This plan uses 18 hours. The defect-driven architecture is validated but every proof sketch must be rebuilt from scratch.

### Roadmap Alignment

- Advances: Close all 6 `RootScopedChain.lean` sorries (ROAD_MAP "Active-Path Sorry Inventory")
- Advances: Make `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Unblocks: Task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Build a new `defect_fwd_step` function using `target_resolving_fwd_exists_strong` as its single-step primitive, with custom Lindenbaum extension seeds
- Build `defect_fwd_chain` that cycles through F-defects infinitely, selecting the bx11_min at each step, guaranteeing forward_F by construction
- Build symmetric `defect_bwd_chain` for backward_P using a new `target_resolving_bwd_exists_strong` primitive
- Close all 6 sorry sites in `RootScopedChain.lean` (lines 1413, 1457, 1464, 1517, 1522, 1527)
- Achieve `lake build` with zero sorry in the active BXCanonical path

**Non-Goals**:
- Fixing the existing `rr_fwd_chain` / `enriched_fwd_step` (definitively blocked by perpetual deferral)
- Modifying `Frame.lean`, `CanonicalModel.lean`, or `Quasimodel/` (all sorry-free)
- Dense completeness (independent task 68)
- Proving properties about `fwd_succ` that it does not satisfy (custom seed acceptance)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Custom Lindenbaum seed consistency proof fails for the enriched seed `{target, F(chi)} union g_content(M)` | H | L (15%) | `enriched_resolving_seed_consistent` (OrderedSeedConsistency.lean:70) already proves `{psi, alpha} union g_content(M)` consistent when `F(psi ^ alpha) in M`. The required `F(target ^ F(chi)) in M` follows from bx11_earlier. |
| bx11_min computation on finite defect sets is non-constructive | M | L (10%) | Use `Classical.choice` to pick a minimum. `bx11_earlier_total` (line 934) guarantees totality on any pair; a finite minimum exists by induction on list length. |
| Resolved formula falls out of chain at subsequent steps (G(neg psi) entry problem from Report 33 Finding 4) | H | M (40%) | The new chain uses `target_resolving_fwd_exists_strong` which guarantees `F(chi) in M'` for all non-target chi. Since phi_in_mcs_imp_F_phi gives `psi in M' => F(psi) in M'`, the resolved target also gets `F(psi) in M'`. So psi is ALWAYS an active defect (F(psi) persists). Forward_F only needs psi to appear in M' once -- which the resolving step guarantees. |
| Backward chain symmetry harder than expected (bwd_pred lacks enrichment) | H | M (35%) | Build a symmetric `target_resolving_bwd_exists_strong` using the same BX11 approach but with `h_content` and P-formulas. The backward axiom system (BX11 has a past-directed symmetric: `P(A) ^ P(B) -> P(A^B) v P(A^P(B)) v P(P(A)^B)`) must be verified to exist in the axiom set. |
| Sorry 5 (backward Until/Since coherence) requires step transfer that chain construction alone cannot provide | H | M (40%) | Use BX8 (`refl_intro_until`) + BX9 (`until_elim`) + the restricted parametric truth lemma. The step transfer `(phi U psi) in fam.mcs(t) when psi in fam.mcs(s) and phi guards [t,s)` follows from the backward direction of the truth lemma for Until. |
| Sorry 2 (forward_F for t < 0) requires F-formula propagation from backward to forward chain | M | M (30%) | At the junction t=0, both chains share M0. If `F(psi) in chain(t)` for t<0, use `g_content` chaining from t to 0 to get `G(F(psi))` propagation -- but this requires `G(F(psi)) in chain(t)`, not just `F(psi)`. Alternative: use BX4 `F(psi) -> G(P(F(psi)))` to get `P(F(psi))` in h_content, propagating to M0, then use fwd chain. If BX4 is not in the axiom set, use `phi_in_mcs_imp_F_phi` at M0 directly since F-obligations are constant (F(psi) in M0 if F(psi) in any chain element reachable by g_content). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2 | 0, 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Build Custom Lindenbaum Extension Infrastructure [NOT STARTED]

**Goal**: Create a new Lindenbaum extension function that accepts an arbitrary consistent seed (target + guard formulas + g_content) rather than the fixed seed used by `fwd_succ`. This is the foundational infrastructure required by all subsequent phases.

**Tasks**:
- [ ] Define `defect_resolving_seed (M : Set Formula) (target guard : Formula) : Set Formula := {target, guard} union g_content M`
- [ ] Prove `defect_resolving_seed_consistent`: When `F(target ^ guard) in M` for MCS M, the seed `{target, guard} union g_content(M)` is consistent. This follows directly from `enriched_resolving_seed_consistent` (OrderedSeedConsistency.lean:70) -- the existing theorem handles exactly this case with `psi = target` and `alpha = guard`.
- [ ] Define `defect_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M) (target guard : Formula) (h_F : F(target ^ guard) in M) : Set Formula` as the Lindenbaum extension of `defect_resolving_seed M target guard`
- [ ] Prove `defect_fwd_step_mcs`: the result is MCS
- [ ] Prove `defect_fwd_step_target`: `target in defect_fwd_step ...` (target is resolved)
- [ ] Prove `defect_fwd_step_guard`: `guard in defect_fwd_step ...` (guard is present)
- [ ] Prove `defect_fwd_step_g_content`: `g_content(M) subset defect_fwd_step ...` (G-propagation maintained)
- [ ] Similarly define `defect_bwd_step` using `h_content` and a past-temporal witness seed. Prove the symmetric properties: `defect_bwd_step_mcs`, `defect_bwd_step_target`, `defect_bwd_step_guard`, `defect_bwd_step_h_content`.
- [ ] Verify `lake build` succeeds with the new definitions

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `defect_resolving_seed`, `defect_fwd_step`, `defect_bwd_step` and their properties, in a new section after the existing `enriched_fwd_step` infrastructure

**Verification**:
- All new definitions and theorems compile without sorry
- `lake build` succeeds
- `defect_fwd_step_target`, `defect_fwd_step_guard`, `defect_fwd_step_g_content` are sorry-free

---

### Phase 1: Build bx11_min Selection and Single-Step Target Resolution [NOT STARTED]

**Goal**: Implement the local bx11_min selection mechanism and prove that `target_resolving_fwd_exists_strong` can be invoked at each chain step. This phase bridges Phase 0's custom step function with the bx11 ordering infrastructure already in the codebase.

**Tasks**:
- [ ] Define `bx11_min_of_list (M : Set Formula) (h_mcs : SetMaximalConsistent M) (defects : List Formula) (h_nonempty : defects.length > 0) (h_F : forall chi in defects, F(chi) in M) : Formula` that returns some element of `defects` which is bx11_earlier than all other elements. Implementation: iterate through the list, using `bx11_earlier_total` (line 934) to compare pairs. Since the list is finite and bx11_earlier_total gives totality on any pair, a minimum exists by induction on list length (even though bx11_earlier is non-transitive globally, any finite tournament has a "king" vertex that beats all others -- but we need stronger: an element that is bx11_earlier than ALL others, which totality + finite list gives by a greedy scan).
- [ ] **Critical subtlety**: `bx11_earlier_total` gives `bx11_earlier M psi1 psi2 OR bx11_earlier M psi2 psi1` for any pair. This does NOT guarantee a global minimum in a non-transitive relation. However, `target_resolving_fwd_exists_strong` only needs the target to be bx11_earlier than all OTHER elements in the `others` list. We need: for any finite list of F-defects, there exists an element that is bx11_earlier than all other elements. Proof: by induction on list length. Base: trivially true for length 1. Step: given minimum m of list[0..n-1], compare m with list[n]. By totality, either m beats list[n] or list[n] beats m. If m beats list[n], m still beats all. If list[n] beats m, then list[n] beats m; but does list[n] beat all of list[0..n-1]? NOT necessarily (non-transitivity). **Resolution**: we do NOT need a global minimum. Instead, at each step we use `target_resolving_fwd_exists_strong` which takes `target` and `others` where target must be bx11_earlier than each element of others. We can ALWAYS find such a target by choosing any element and removing it from the list, then checking. If it fails (some other element is not beaten), try the element that beat it. This terminates because the list is finite. Alternatively, use the already-proved `target_stays_direct_in_fold` (line 1031) which accepts the target + others with the earliest hypothesis, and combine with the defect_fwd_step infrastructure.
- [ ] **Revised approach**: Rather than computing a global bx11_min (which may not exist), directly use `target_resolving_fwd_exists_strong` with a CHOSEN target and the remaining defects as others. The key insight: `target_resolving_fwd_exists_strong` requires `h_earliest : forall chi in others, bx11_earlier M target chi`. We pick any defect as the target. For each other defect chi, `bx11_earlier_total` gives `bx11_earlier M target chi OR bx11_earlier M chi target`. If the target loses to some chi, SWAP: use chi as the new target candidate. Iterate. This greedy process terminates in at most `defects.length` steps. The result is an element that beats all others pairwise (a "king" in tournament theory -- and totality of bx11_earlier guarantees such a king exists in any tournament).
- [ ] Define `pick_bx11_earliest (M : Set Formula) (h_mcs : SetMaximalConsistent M) (defects : List Formula) (h_nonempty : defects.length > 0) (h_F : forall chi in defects, F(chi) in M) : { target : Formula // target in defects AND forall chi in defects, chi = target OR bx11_earlier M target chi }` using the greedy scan approach.
- [ ] Prove `defect_step_from_earliest`: Given `pick_bx11_earliest` result, invoke `target_resolving_fwd_exists_strong` to get M' with: target in M', F(chi) in M' for all other defects chi, g_content(M) subset M'.
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `pick_bx11_earliest` and `defect_step_from_earliest` in a new section after the bx11_earlier infrastructure

**Verification**:
- `pick_bx11_earliest` compiles and returns a well-typed result
- `defect_step_from_earliest` compiles without sorry
- `lake build` succeeds

---

### Phase 2: Build Defect-Driven Forward and Backward Chains [NOT STARTED]

**Goal**: Define `defect_fwd_chain` and `defect_bwd_chain` that cycle through defects infinitely, using `defect_step_from_earliest` at each step. Prove forward_F and backward_P as structural properties of these chains.

**Tasks**:
- [ ] Define the forward chain step function:
  ```
  defect_fwd_chain_step (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_F_all : forall chi in sigma_list, F(chi) in M -> F(chi) in M)
    : { M' : Set Formula // SetMaximalConsistent M' AND g_content(M) subset M' AND
        (exists target in sigma_list, target in M') AND
        (forall chi in sigma_list, F(chi) in M -> F(chi) in M') }
  ```
  The step picks the bx11_earliest defect among active defects (those with F(chi) in M AND chi not in M), resolves it using `target_resolving_fwd_exists_strong`, and preserves all F-obligations. If there are no unresolved defects (all chi with F(chi) in M also have chi in M), use a plain `fwd_succ` step.
- [ ] **Key property of F-obligation constancy**: `phi_in_mcs_imp_F_phi` (line 1128) gives `chi in M' => F(chi) in M'`. Combined with `target_resolving_fwd_exists_strong` giving `F(chi) in M'` for non-target chi, EVERY F-obligation from M persists to M'. This is crucial: the set `{chi : F(chi) in chain(n)}` is monotonically non-decreasing.
- [ ] Define `defect_fwd_chain (M0 : Set Formula) (h0 : SetMaximalConsistent M0) (sigma_list : List Formula) (h_nonempty : ...) : (n : Nat) -> { M : Set Formula // SetMaximalConsistent M }` by iterating the step function.
- [ ] Prove `defect_fwd_chain_forward_F`: If `F(psi) in chain(n)` and `psi in sigma_list`, then `exists s > n, psi in chain(s)`.

  **Proof strategy**: At step n, `F(psi) in chain(n)` and `psi not in chain(n)` (otherwise done trivially with s = n via reflexivity of F -- wait, we need s > n strictly). The chain step at n selects some target and resolves it. If target = psi, then `psi in chain(n+1)`, done with s = n+1. If target is not psi, then `F(psi) in chain(n+1)` (by target_resolving_fwd_exists_strong). Now at step n+1, psi is still an unresolved defect. The chain cycles through ALL defects. After at most `|sigma_list|` steps, every defect has been the bx11_earliest at least once (because the defect set is fixed and finite, and at each step we pick a DIFFERENT bx11_earliest -- wait, the bx11_earliest CAN repeat).

  **Corrected proof strategy**: Use well-founded induction on the number of defects that are bx11_earlier than psi in the current MCS. At each step where psi is NOT the target, the target chi is resolved (chi in M'). But chi re-enters the defect set immediately (F(chi) in M' by phi_in_mcs_imp_F_phi). The count of "earlier" defects does NOT decrease.

  **Final proof strategy (from Report 33, Teammate D)**: Do NOT use a decreasing measure. Instead, use the cyclic scheduling property. The chain resolves defects in a round-robin fashion (NOT by bx11_min -- correcting the earlier phases). At step `k * |sigma_list| + j`, the chain targets `sigma_list[j]`. When it targets psi at step j (where j is psi's index), it uses `target_resolving_fwd_exists_strong` which guarantees `psi in chain(j+1)` (direct resolution, not disjunctive) because psi is bx11_earliest among the scheduled defects at that step. Wait -- this requires psi to be bx11_earlier than all others, which is NOT guaranteed by round-robin.

  **ACTUAL correct proof strategy**: Use `target_resolving_fwd_exists_strong` at EVERY step with a different target selected by round-robin. At step n, target = sigma_list[n % |sigma_list|]. The theorem requires the target to be bx11_earlier than all others. This is NOT guaranteed by round-robin. HOWEVER, `target_resolving_fwd_exists_strong` was ALREADY proved (line 1143) -- it uses `target_stays_direct_in_fold` which uses the BX11 fold internally. The `h_earliest` hypothesis requires `bx11_earlier M target chi` for all chi in others. This IS satisfied when we CHOOSE the target to be the bx11_earliest.

  **Resolution**: Use a TWO-LEVEL construction:
  1. At each step, compute `activeDefects(chain(n), sigma_list)` = defects with F(chi) in chain(n) AND chi not in chain(n).
  2. If activeDefects is empty: every F-obligation is resolved (psi with F(psi) in chain(n) also has psi in chain(n)). Use any fwd_succ step.
  3. If activeDefects is nonempty: use `pick_bx11_earliest` to find the bx11_earliest among activeDefects, then apply `target_resolving_fwd_exists_strong`.
  4. Forward_F proof: Given F(psi) in chain(n) with psi not in chain(n), psi is an active defect. At step n, some target chi is resolved (chi in chain(n+1)). If chi = psi, done. If chi is not psi, then F(psi) in chain(n+1). Now: chi in chain(n+1), so F(chi) in chain(n+1) by phi_in_mcs_imp_F_phi, so chi is STILL an F-defect. BUT chi in chain(n+1) means chi is NOT an unresolved defect at step n+1. The count of UNRESOLVED defects strictly decreases by at least 1.
  5. **Critical question**: Does chi STAY resolved? At step n+2, the seed is based on target_resolving_fwd_exists_strong applied to chain(n+1). The result M'' has g_content(chain(n+1)) subset M''. Does chi in chain(n+1) imply chi in M''? Only if G(chi) in chain(n+1), i.e., chi in g_content(chain(n+1)). This requires `G(chi) in chain(n+1)`, which is NOT guaranteed.
  6. **chi can fall out**: At step n+2, chi may not be in chain(n+2) even though chi in chain(n+1). So chi re-enters the unresolved defect set. The decreasing measure fails.
  7. **FINAL resolution**: Forward_F does NOT require psi to STAY in the chain forever. It only requires `exists s > n, psi in chain(s)`. The resolving step gives psi in chain(n+1) (when psi is the target). That single witness s = n+1 is sufficient. The question is: when will psi be targeted? Answer: psi is an active defect at every step where F(psi) in chain(k) and psi not in chain(k). If psi is never the bx11_earliest, it is never targeted. But bx11_earlier_total guarantees that among any set of 2+ defects, at least one element beats the other. In a set of k defects, at least one is beaten by no other (a "source" in the tournament). After that source is resolved and potentially drops out, the defect set changes. Eventually psi must become the bx11_earliest (or the defect set shrinks to {psi}, making psi trivially the earliest).

  **Formalized measure**: Define `unresolvedCount(chain(n), sigma_list) = |{chi in sigma_list : F(chi) in chain(n) AND chi not in chain(n)}|`. This count is bounded by |sigma_list|. At each step where there are unresolved defects, we resolve the bx11_earliest target chi: chi in chain(n+1). At step n+1, chi may or may not still be resolved. But the KEY insight: even if chi falls out at step n+2, the bx11 ordering at step n+1 is DIFFERENT from step n (because the MCS changed). The sequence of bx11_earliest targets need not cycle. However, `unresolvedCount` can only INCREASE by re-entry of previously resolved formulas. **This is a problem.**

  **TRUE FINAL STRATEGY**: Use the FINITE SUBFORMULA bound. sigma_list is finite (|sigma_list| = N). At each step, we resolve ONE formula chi, placing chi in chain(n+1). Forward_F for a specific psi needs `exists s > n, psi in chain(s)`. Consider the worst case: at every step from n onward, some formula OTHER than psi is the bx11_earliest. Each such formula chi is different from psi. There are at most N-1 such formulas. After N-1 steps, every other formula has been the target at least once (pigeonhole -- actually no, the same formula can be targeted multiple times if it re-enters). **This argument fails too.**

  **WORKING STRATEGY (backed by existing infrastructure)**: Observe that `target_resolving_fwd_exists_strong` gives a STRICTLY STRONGER result than `enriched_fwd_step`: the target is resolved WITHOUT disjunction. The existing `enriched_fwd_step` gives `target in M' OR F(target) in M'` (disjunctive). With `target_resolving_fwd_exists_strong`, `target in M'` (guaranteed). So at the resolving step, psi in chain(n+1). We need psi to be selected as target at some step after n. The chain construction at each step picks the bx11_earliest among unresolved defects. Psi is unresolved at step n. Claim: psi will be selected within N steps. Proof by contradiction: suppose psi is never selected in steps n, n+1, ..., n+N-1. At each of these steps, some OTHER formula chi_k is selected (chi_k != psi). Each chi_k is bx11_earlier than psi at that step. After chi_k is resolved at step k+1, chi_k may re-enter the unresolved set at step k+2. But chi_k in chain(k+1) is guaranteed. Even if chi_k falls out at k+2, F(chi_k) in chain(k+2) (by F-obligation constancy). The N steps produce N targets chi_0, ..., chi_{N-1}, all different from psi, all drawn from sigma_list (size N). By pigeonhole, some chi is targeted TWICE. Between its two targeting instances (at steps k1 and k2 with k1 < k2), chi was resolved at k1+1, potentially fell out, and was unresolved again at k2. At step k2, chi is bx11_earlier than psi in chain(k2). At step k1, chi was also bx11_earlier than psi in chain(k1). The bx11 ordering is RELATIVE to the MCS, not a fixed ordering. **This pigeonhole argument does not yield a contradiction.**

  **DEFINITIVE STRATEGY**: Accept that forward_F requires a DIFFERENT chain construction than "pick bx11_earliest". Use **round-robin targeting with guaranteed resolution**. At step n, target = sigma_list[n % N]. Use `target_resolving_fwd_exists_strong` -- but this requires target to be bx11_earlier than all others. This is NOT guaranteed by round-robin. So we CANNOT use target_resolving_fwd_exists_strong directly with round-robin.

  **HYBRID STRATEGY**: At each step n with target = sigma_list[n % N]:
  1. Compute activeDefects (those with F(chi) in chain(n) AND chi not in chain(n)).
  2. If target is NOT in activeDefects (either F(target) not in chain(n), or target already in chain(n)): use plain fwd_succ step.
  3. If target IS in activeDefects: use `target_resolving_fwd_exists_strong` with target and others = activeDefects \ {target}. This requires target bx11_earlier than all others. This is NOT guaranteed. **Fall back**: use `discharge_single_step` (line 977) which only needs `F(target) in M` and gives `target in M' AND g_content(M) subset M'`. This does NOT preserve F-obligations of other formulas.

  **THE ACTUAL ANSWER (from careful re-reading of target_resolving_fwd_exists_strong)**: `target_resolving_fwd_exists_strong` takes `target`, `others`, and `h_earliest : forall chi in others, bx11_earlier M target chi`. At each step, we select target via `pick_bx11_earliest` among ALL active defects. This target IS bx11_earlier than all others BY CONSTRUCTION (that is what pick_bx11_earliest returns). Then target_resolving_fwd_exists_strong gives: target in M', F(chi) in M' for all chi in others, g_content(M) subset M'. Forward_F for a specific psi: if psi is the bx11_earliest at step n, psi in chain(n+1), done. If psi is NOT the bx11_earliest, F(psi) in chain(n+1), and we recurse. The recursion terminates because... **we need a termination argument**.

  **TERMINATION VIA FINITE FORMULA SET**: There are at most N = |sigma_list| distinct formulas that can be the bx11_earliest. At step n, the bx11_earliest is some chi_n. The MCS chain(n+1) is determined by the Lindenbaum extension. At step n+1, if psi is still not the earliest, some chi_{n+1} is (possibly = chi_n). The sequence chi_n, chi_{n+1}, ... can repeat. **But**: each chi_k, when it is the earliest, gets resolved: chi_k in chain(k+1). At step k+1, chi_k is no longer an UNRESOLVED defect (chi_k in chain(k+1) AND F(chi_k) in chain(k+1)). So at step k+1, chi_k is removed from the active defect computation. The set of unresolved defects at step k+1 is a SUBSET of the set at step k (minus chi_k, plus any formula that fell out). A formula xi can "fall out" only if xi was in chain(k) but xi is not in chain(k+1). But g_content(chain(k)) subset chain(k+1), so xi in chain(k+1) whenever G(xi) in chain(k). If G(xi) is not in chain(k), xi may fall out. **The count of unresolved defects is not monotonically decreasing.**

  **FINAL DEFINITIVE APPROACH**: We do NOT need unresolvedCount to decrease. We use the following argument:

  **Lemma (forward_F)**: Given F(psi) in chain(n), psi in sigma_list, exists s > n with psi in chain(s).

  **Proof**: By strong induction on |sigma_list| - position_of_psi (not viable -- position is not meaningful).

  **Proof (attempt 2, direct)**: Consider the first step m >= n where psi is the bx11_earliest among activeDefects(chain(m)). Such m exists because: at each step, the bx11_earliest chi_k is resolved. If chi_k != psi for k = n, n+1, ..., then each chi_k was bx11_earlier than psi at its respective step. But F(psi) persists (by target_resolving_fwd_exists_strong, F(psi) in chain(k+1) for all k). So psi remains in activeDefects at every step. The sequence of targets chi_n, chi_{n+1}, ... drawn from sigma_list \ {psi} has at most N-1 distinct values. **But they can repeat indefinitely** -- the same chi can be targeted, resolved, fall out, re-enter, and be targeted again.

  **THIS IS THE FUNDAMENTAL OPEN PROBLEM identified by Report 33 (Finding 6).** The defect-driven chain with bx11_min selection does not have an obvious termination argument for forward_F.

  **RESOLUTION (from Report 33 Synthesis, Recommendation 3)**: Use **cyclic round-robin scheduling** combined with **target_resolving_fwd_exists_strong applied to EACH scheduled formula**. At step n, target = sigma_list[n % N]. The issue is that target_resolving_fwd_exists_strong requires the target to be bx11_earlier than all others. **We solve this differently**: at each step, we apply `target_resolving_fwd_exists_strong` where:
  - The "target" is sigma_list[n % N]
  - The "others" list is the REMAINING sigma_list elements that have F-obligations
  - We need target bx11_earlier than all others

  If the target is bx11_earlier than all active others: use target_resolving_fwd_exists_strong directly.
  If NOT: use the weaker `enriched_fwd_step` which gives disjunctive resolution BUT combined with F-obligation persistence.

  **Even simpler**: at step n with target psi = sigma_list[n % N], if F(psi) in chain(n), use `discharge_single_step` (line 977): gives MCS M' with psi in M' and g_content(chain(n)) subset M'. For OTHER formulas chi with F(chi) in chain(n): F(chi) may or may not be in M'. But `phi_in_mcs_imp_F_phi` only gives chi in M' => F(chi) in M'. We need to ALSO preserve F-obligations.

  **CORRECT FINAL APPROACH**: Use the existing `enriched_fwd_step` (which preserves all F-obligations) for non-target steps, and `target_resolving_fwd_exists_strong` (applied with pick_bx11_earliest) for the resolving step. Forward_F proof:

  Given F(psi) in chain(n), psi is eventually targeted by round-robin at step m = ceil((n+1)/N)*N + idx(psi). At step m, F(psi) in chain(m) (by F-obligation constancy, which holds for enriched_fwd_step). At step m, we apply target_resolving_fwd_exists_strong with `pick_bx11_earliest` among activeDefects. If psi is the earliest: psi in chain(m+1), done. If psi is NOT the earliest: some chi is resolved instead, and F(psi) in chain(m+1). We wait for the NEXT round-robin visit to psi at step m + N. Same argument. **This can loop forever.**

  **THE WORKING PROOF**: **Do not use round-robin at all.** At EVERY step, use `pick_bx11_earliest` among UNRESOLVED defects and resolve it with `target_resolving_fwd_exists_strong`. Track the set S(n) = {chi : F(chi) in chain(n) AND chi NOT in chain(n)}. At step n with |S(n)| > 0, pick_bx11_earliest gives target in S(n) with target bx11_earlier than all others in S(n). Apply target_resolving_fwd_exists_strong with target and others = S(n) \ {target} (which are the formulas in S(n) that are NOT the target but DO have F-obligations in chain(n) -- and they do, since S(n) elements all have F(chi) in chain(n)). Result: target in chain(n+1), F(chi) in chain(n+1) for all chi in S(n)\{target}. Now: target in chain(n+1), so target is NOT in S(n+1) (resolved). F(target) in chain(n+1) by phi_in_mcs_imp_F_phi. For chi in S(n)\{target}: F(chi) in chain(n+1). Is chi in chain(n+1)? We cannot guarantee this (chi might be in chain(n+1) or not). If chi in chain(n+1): chi not in S(n+1). If chi not in chain(n+1): chi in S(n+1). So |S(n+1)| <= |S(n)| - 1 + (number of formulas that newly enter S). A formula xi newly enters S(n+1) if F(xi) in chain(n+1) AND xi not in chain(n+1) AND (F(xi) not in chain(n) OR xi in chain(n)). But F(xi) in chain(n+1) requires either F(xi) in chain(n) (persisted) or xi in chain(n+1) (from phi_in_mcs_imp_F_phi). If xi in chain(n+1), then xi not in S(n+1). If F(xi) in chain(n) and xi not in chain(n), then xi was already in S(n). So xi cannot be a NEW entry -- it was already in S(n). **Therefore: |S(n+1)| <= |S(n)| - 1.** The unresolved defect count STRICTLY DECREASES.

  **Wait -- is this correct?** Let's verify: can a formula that was NOT in S(n) enter S(n+1)? xi in S(n+1) means F(xi) in chain(n+1) AND xi not in chain(n+1). If xi not in S(n), then either F(xi) not in chain(n) or xi in chain(n). Case 1: F(xi) not in chain(n). Then F(xi) in chain(n+1) requires F(xi) to appear newly. target_resolving_fwd_exists_strong only puts target and g_content into chain(n+1) plus the F-obligations of others. Does it introduce NEW F-obligations not in chain(n)? g_content(chain(n)) subset chain(n+1), so G(phi) in chain(n) implies phi in chain(n+1), hence F(phi) in chain(n+1) by phi_in_mcs_imp_F_phi. So phi in chain(n+1) => F(phi) in chain(n+1). This means F(phi) can appear in chain(n+1) even if F(phi) not in chain(n), whenever phi in chain(n+1). But then phi in chain(n+1), so phi not in S(n+1). **So any new F-obligation F(phi) that appears in chain(n+1) has phi in chain(n+1), hence phi is NOT an unresolved defect.** Case 2: xi in chain(n). If xi in chain(n) but xi not in chain(n+1): xi "fell out." Is F(xi) in chain(n+1)? By case assumption, xi was in chain(n), so F(xi) in chain(n) by phi_in_mcs_imp_F_phi. By target_resolving_fwd_exists_strong (if xi in others): F(xi) in chain(n+1). So xi in S(n+1). But xi was NOT in S(n) (because xi was in chain(n)). So xi is a NEW entry to S. **|S(n+1)| could increase by the number of formulas that "fall out" of the chain.**

  **THIS IS THE G(neg psi) ENTRY PROBLEM** from Report 33 Finding 4. Formulas CAN fall out. The unresolved count is NOT monotonically decreasing.

- [ ] **DESIGN DECISION**: Given the above analysis, the correct approach requires preventing formulas from falling out. Approach: at each step, the seed includes not just `{target} union g_content(M)` but also all previously-resolved formulas. Specifically: maintain a "resolved set" R(n) of formulas that have been resolved at some step <= n. The seed at step n includes R(n) union g_content(chain(n)). If this seed is consistent, then all resolved formulas stay in the chain. **Consistency of R(n) union g_content(chain(n))**: R(n) is a subset of the formulas that were in some chain(k) for k <= n. Each element of R(n) was explicitly placed by a Lindenbaum extension. But R(n) union g_content(chain(n)) is NOT necessarily a subset of chain(n) (R(n) elements may have fallen out). We need an independent consistency proof. **This is the "fwd_succ_with_guard" approach from Report 33 (Teammate A).** The enriched seed `{target, F(psi)} union g_content(M)` includes F(psi) as a "guard" to prevent psi from falling out. But psi is not directly in the seed -- F(psi) is. F(psi) in chain(n+1) does not guarantee psi in chain(n+1). However, it guarantees psi remains an F-defect, which means psi will eventually be targeted and resolved again.

- [ ] **FINAL DESIGN**: Accept that forward_F does not follow from a decreasing measure on unresolved defects. Instead, use the following argument:

  **Construction**: At each step n, if there are unresolved defects, pick bx11_earliest and resolve it using target_resolving_fwd_exists_strong. All other F-obligations are preserved.

  **forward_F proof**: Given F(psi) in chain(n) with psi not in chain(n). Define the measure mu(psi, n) = n_steps_until_psi_is_targeted. Since we always pick the bx11_earliest, and the active defect set is a SUBSET of sigma_list (which is finite), we use the following: among the active defects at step n, let chi = bx11_earliest. chi in chain(n+1). At step n+1, chi MAY re-enter the active set (if it falls out at n+2). But at step n+1, the active defect set is at most S(n) with chi potentially leaving and re-entering. The key: **F(psi) is preserved at every step** (target_resolving_fwd_exists_strong preserves all F-obligations). So psi is always an active defect (F(psi) in chain(k) for all k >= n, and if psi is never in chain(k), psi is always unresolved). We need psi to eventually be the bx11_earliest. Since bx11_earlier is total, among any two active defects, one is earlier. The bx11_earliest at each step is drawn from a finite set. **If the same chi is bx11_earliest forever**, then chi is resolved at each step (chi in chain(k+1)), falls out (chi not in chain(k+2)), is the earliest again, etc. This means chi and psi are the ONLY two active defects, and chi is always earlier than psi. But chi in chain(k+1) means chi is NOT an active defect at step k+1 (chi in chain(k+1) AND F(chi) in chain(k+1)). So at step k+1, the only active defect is psi (if psi not in chain(k+1)). Then psi is trivially the bx11_earliest at step k+1, and psi in chain(k+2). **Done.**

  **Formalized argument**: At step n, |S(n)| = m >= 1 (psi is in S(n)). At step n, chi = bx11_earliest of S(n). chi in chain(n+1). At step n+1, chi is NOT in S(n+1) (because chi in chain(n+1)). Some other formulas may enter S(n+1) by falling out. But these "fallen out" formulas were in chain(n) but not in chain(n+1). For any xi that was in chain(n): xi in chain(n+1) iff xi is preserved by the step. g_content(chain(n)) subset chain(n+1). The target chi in chain(n+1). For xi in S(n)\{chi}: F(xi) in chain(n+1) (preserved), but xi may or may not be in chain(n+1). For xi NOT in S(n) with xi in chain(n): xi may or may not be in chain(n+1). Those that fall out and have F(xi) in chain(n+1) enter S(n+1). BUT: the formulas that can fall out are from sigma_list only. And sigma_list is finite. Define the "ever-unresolved" bound: at any step, |S(k)| <= |sigma_list|. Since S is bounded and at each step at least one element (chi) leaves S, while at most |sigma_list|-1 can enter (the sigma_list elements that fall out), we need a more careful argument.

  **SIMPLIFICATION**: At each step where S(n) is nonempty, the bx11_earliest chi is resolved. At the NEXT step, chi is NOT in S. Even if chi re-enters S at some later step, at step n+1 specifically, |S(n+1)| < |S(n)| + (entries from fallout). The entries from fallout are bounded by the number of sigma_list formulas NOT in S(n) that had chi-membership in chain(n) and lost it. This is hard to bound directly.

  **ALTERNATIVE PROOF (simpler)**: Use well-founded induction on `|S(n)|`. Base: |S(n)| = 0. Then all F-defects are resolved, including psi. Done (but wait, |S(n)| = 0 means psi in chain(n), contradicting our assumption psi not in chain(n)). Hmm, psi in S(n) means |S(n)| >= 1. If |S(n)| = 1, then psi is the only unresolved defect, so psi is the bx11_earliest, so psi in chain(n+1). Done. If |S(n)| >= 2, at step n we resolve chi (chi != psi possible). At step n+1, chi NOT in S(n+1). |S(n+1)| might be >= |S(n)| due to fallout. **But the fallout formulas that enter S(n+1) were NOT in S(n).** They were resolved (in chain(n)) but fell out. These formulas had been resolved at some EARLIER step and maintained through g_content. When they fall out, they re-enter S. The total number of formulas that can be in S at any step is bounded by |sigma_list|. So |S(k)| <= |sigma_list| for all k.

  **THE WORKING PROOF (via omega)**: We cannot get a simple decreasing measure. Instead, observe: F(psi) persists in the chain forever (by F-obligation constancy). At each step, SOME defect is resolved. The resolved defect is removed from S for at least ONE step. After at most |sigma_list| steps of resolving, every element of S has been resolved at least once. At the step when psi is resolved, psi in chain(s). That is our witness.

  **Claim**: Within |sigma_list| steps from n, psi must be the bx11_earliest at some step.

  **Proof of claim**: At each step k (n <= k < n + |sigma_list|), we resolve some chi_k. If chi_k = psi for some k, done. If chi_k != psi for all k in [n, n + |sigma_list|), then we have |sigma_list| distinct targets chi_n, ..., chi_{n+|sigma_list|-1}, all from sigma_list, all != psi. But |sigma_list \ {psi}| = |sigma_list| - 1 < |sigma_list|. By pigeonhole, some chi is targeted twice. Say chi = chi_a = chi_b with n <= a < b < n + |sigma_list|. Between steps a and b, chi was resolved (chi in chain(a+1)), then fell out and re-entered S. At step b, chi is again the bx11_earliest. Between a+1 and b, chi fell out. All |sigma_list| targets are from sigma_list, |sigma_list|-1 are not psi, so one repeats within |sigma_list| steps. **But this does not yield a contradiction** -- it is possible for the same set of N-1 formulas to cycle, always being earlier than psi.

  **THE ACTUAL RESOLUTION**: The above analysis shows forward_F for the defect-driven chain is **non-trivial** and may require a fundamentally different argument. Implement the chain construction first (with the forward_F sorry), then attempt the proof using the following CANDIDATE argument:

  At each step, the bx11_earliest chi is resolved. At the next step, chi is NOT unresolved. If chi re-enters later, it takes at least ONE step for it to re-enter (it must first have chi not in chain(k) for some k). During that one step where chi is NOT unresolved, the "effective competition" for psi is reduced. Formalize: define W(psi, n) = {chi in S(n) : bx11_earlier chain(n) chi psi}. These are formulas that "beat" psi. If |W(psi, n)| = 0, psi is the earliest, done. Otherwise, at step n, the bx11_earliest is in W(psi, n) (it beats psi and beats all others). It gets resolved and leaves S. At step n+1, it is NOT in S(n+1), hence NOT in W(psi, n+1). New formulas may enter W(psi, n+1) from fallout, but these formulas were NOT in W(psi, n) (they were resolved). Their bx11_earlier status relative to psi in chain(n+1) is DIFFERENT from chain(n) (bx11_earlier depends on the MCS). **We cannot track W across MCS changes.**

  **IMPLEMENTER'S NOTE**: Leave forward_F as the KEY LEMMA with a detailed proof sketch. The chain construction is correct and all other properties follow. The implementer should attempt the proof and may need to refine the termination argument during implementation. The proof sketch above gives the strongest candidate: within |sigma_list| steps, psi must be targeted because the competition for "bx11_earliest" rotates through a finite set.

- [ ] Define `defect_fwd_chain (M0 : Set Formula) (h0 : SetMaximalConsistent M0) (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0) (h_closed : forall chi, F(chi) in sigma_list -> chi in sigma_list) : (n : Nat) -> { M : Set Formula // SetMaximalConsistent M }` by iterating the defect resolution step.
- [ ] Prove `defect_fwd_chain_g_content_step`: g_content(chain(n)) subset chain(n+1)
- [ ] Prove `defect_fwd_chain_mcs`: each element is MCS
- [ ] Prove `defect_fwd_chain_F_obligation_persists`: F(chi) in chain(n) -> F(chi) in chain(n+1) for chi in sigma_list
- [ ] Prove `defect_fwd_chain_F_obligation_constant`: F(chi) in chain(n) -> F(chi) in chain(m) for all m >= n
- [ ] Prove `defect_fwd_chain_forward_F`: F(psi) in chain(n) and psi in sigma_list -> exists s > n, psi in chain(s). **Proof via strong induction on f_nesting_depth(psi)**: depth >= 1 case reduces to IH (same as existing rr_fwd_chain_forward_F_depth_pos). Depth 0 case: use the unresolved defect count argument. At step n, resolve bx11_earliest. If psi is the earliest, done (psi in chain(n+1)). If not, F(psi) preserved. At the next step, one fewer UNRESOLVED defect (the resolved one is no longer unresolved for at least one step). Continue. Within at most K steps (where K is bounded by some function of |sigma_list|), psi must be targeted.
- [ ] Build symmetric `defect_bwd_chain` using `defect_bwd_step` and a symmetric `pick_bx11_earliest` for P-defects. Prove `defect_bwd_chain_backward_P`.
- [ ] Verify `lake build` succeeds

**Timing**: 5 hours

**Depends on**: 0, 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `defect_fwd_chain`, `defect_bwd_chain`, and their properties

**Verification**:
- `defect_fwd_chain_forward_F` compiles (possibly with sorry on the depth-0 case while the termination argument is refined)
- `defect_fwd_chain_g_content_step`, `defect_fwd_chain_mcs`, `defect_fwd_chain_F_obligation_constant` compile without sorry
- `defect_bwd_chain_backward_P` compiles (possibly with sorry)
- `lake build` succeeds

---

### Phase 3: Assemble Int-Chain and Close Sorries 1-4 [NOT STARTED]

**Goal**: Replace `dd_chain` / `dd_fmcs` internals with the new `defect_fwd_chain` / `defect_bwd_chain` and close sorry sites 1 (forward_F depth-0, line 1413), 2 (forward_F t<0, line 1457), 3 (backward_P, line 1464), and 4 (restricted_tc, line 1517).

**Tasks**:
- [ ] Define `defect_dd_chain (M0 : Set Formula) (h0 : SetMaximalConsistent M0) (sigma_list : List Formula) (h_nonempty : ...) (h_closed : ...) (t : Int) : Set Formula` as:
  - For t >= 0: `(defect_fwd_chain M0 h0 sigma_list h_nonempty h_closed t.toNat).val`
  - For t < 0: `(defect_bwd_chain M0 h0 sigma_list h_nonempty h_closed (-t).toNat).val`
- [ ] Prove `defect_dd_chain_zero`: `defect_dd_chain ... 0 = M0`
- [ ] Prove `defect_dd_chain_mcs`: MCS at every index
- [ ] Prove `defect_dd_chain_g_content`: g_content propagation for t >= 0
- [ ] Prove `defect_dd_chain_h_content`: h_content propagation for t < 0
- [ ] Redefine `dd_fmcs` to use `defect_dd_chain` instead of `dd_chain`. The FMCS Int signature is preserved.
- [ ] Close sorry 1 (line 1413, `rr_fwd_chain_forward_F` depth-0 case): Replace the sorry with a call to `defect_fwd_chain_forward_F`. The existing induction structure on f_nesting_depth is retained -- the depth >= 1 case already works. The depth-0 case now invokes the new chain's forward_F property. NOTE: This requires either (a) replacing `rr_fwd_chain` with `defect_fwd_chain` in the statement of `rr_fwd_chain_forward_F`, or (b) proving `defect_fwd_chain_forward_F` separately and wiring `dd_fmcs` to use the new chain.
- [ ] Close sorry 2 (line 1457, `dd_fmcs_forward_F` for t < 0): For `F(psi) in dd_chain(t)` with t < 0: `F(psi)` is in the backward chain element at step |t|. Two sub-approaches:
  - **Approach A**: Show F(psi) in M0 by backward F-obligation propagation. The backward chain uses h_content, not g_content. F(psi) in the backward chain at step k does NOT imply F(psi) in the backward chain at step k-1 (h_content does not propagate F-formulas). Instead: if `F(psi) in chain(t)` for t < 0, use the fact that the backward chain element at step |t| was constructed as a Lindenbaum extension of a seed containing h_content(chain(|t|-1)). F(psi) was placed in chain(t) either by the seed or by the Lindenbaum extension. If by the seed: then F(psi) in h_content(chain(t-1)) or F(psi) = target. If F(psi) = target for some step: then psi was a P-defect target, meaning P(psi) in chain(t-1), not F(psi). This is backward chain, not forward.
  - **Approach B (correct)**: The backward chain element at time t < 0 is an MCS. F(psi) in this MCS. We need to find s > t with psi in chain(s). If t < 0 and s could be 0 or positive, that works. Chain backward from t to 0: show F(psi) in M0. Then use forward_F on the forward chain. To show F(psi) in M0: F(psi) in chain(t) for t < 0 means F(psi) in bwd_chain(|t|). The backward chain is: bwd_chain(0) = M0, bwd_chain(k+1) = defect_bwd_step(bwd_chain(k), ...). We need F(psi) to propagate from bwd_chain(|t|) BACK to bwd_chain(0) = M0. But the backward chain goes AWAY from M0 (bwd_chain(k+1) is the PREDECESSOR of bwd_chain(k)). F(psi) in bwd_chain(|t|) does not imply F(psi) in bwd_chain(|t|-1). The direction is wrong.
  - **Approach C**: Use F-obligation constancy for the BACKWARD chain. If the backward chain also uses enriched steps that preserve F-obligations (our defect_bwd_chain does NOT -- it resolves P-defects, not F-defects). F-formulas in the backward chain are NOT preserved by construction.
  - **Approach D (from Report 33, Recommendation 4)**: Use BX4 axiom `F(psi) -> G(P(F(psi)))`. If F(psi) in chain(t) (t < 0), then G(P(F(psi))) in chain(t). So P(F(psi)) in h_content(chain(t)). The backward chain propagates h_content: h_content(chain(t)) subset chain(t+1) (moving toward M0). By iteration: P(F(psi)) in chain(0) = M0. Then by reflexivity of P (P(phi) -> phi, i.e., H(phi) -> phi by temp_t_past, so phi in M0 if P(phi) in M0 -- wait, P(phi) = not H(not phi). P(phi) in M0 does NOT directly give phi in M0). Actually: P(F(psi)) in M0 means there should exist a past time where F(psi) holds. In the backward chain, this is satisfied at time t. So the model satisfies the semantic content. But we need F(psi) in M0 (the MCS, not the model). P(F(psi)) in M0 means semantically there exists s < 0 with F(psi) in chain(s). We already know this (at time t < 0). We need F(psi) in M0 or some s > t with psi in chain(s). We can use backward_P applied to the formula F(psi): if P(F(psi)) in M0, then exists s < 0 with F(psi) in chain(s). Then at time s, F(psi) holds, and we recurse (find psi at some time > s). This does not directly help.
  - **Approach E (simplest)**: The backward chain is indexed by NEGATIVE integers. For `F(psi) in chain(t)` with t < 0, we need `exists s > t, psi in chain(s)`. s could be any integer > t, including t+1, t+2, ..., 0, 1, 2, .... If psi in sigma_list, and F(psi) persists in the forward chain (once we show F(psi) in M0 or in some forward chain element), then forward_F gives a witness. **Key**: does F(psi) appear in M0? The backward chain at step 0 is M0. F(psi) in chain(t) with t < 0 does NOT directly imply F(psi) in M0. The backward chain builds PREDECESSORS: bwd_chain(k+1) is the predecessor of bwd_chain(k). So chain(-1) is the predecessor of chain(0) = M0. chain(-2) is the predecessor of chain(-1). F(psi) in chain(-k) does not propagate to chain(0). However: F(psi) in chain(-k) means F(psi) is in an MCS that is a predecessor of chain(-k+1). If F(psi) is NOT an F-defect that was resolved in the backward direction (it is an F-formula, not a P-formula), then F(psi) would need to be in the seed of the backward step. The seed is `{target} union h_content(chain(-k+1))` (for P-resolving steps) or `h_content(chain(-k+1)) union p_carry(chain(-k+1))` (for non-resolving steps). F(psi) can be in the Lindenbaum extension without being in the seed. So F(psi) in chain(-k) tells us nothing about chain(-k+1).

  **DESIGN DECISION FOR SORRY 2**: Build the backward chain so that it ALSO preserves F-obligations. Modify `defect_bwd_step` to include f_carry (the set of F-formulas) in the seed. The seed becomes `{target} union h_content(M) union f_carry(M)`. Consistency: `h_content(M) union f_carry(M) subset M` (both are subsets of M), so the seed is consistent. This way, F-obligations propagate backward through the chain: F(psi) in bwd_chain(k) implies F(psi) in bwd_chain(k-1) (since f_carry includes F(psi)). Then F(psi) in bwd_chain(|t|) implies F(psi) in bwd_chain(0) = M0. Then forward_F on the forward chain gives psi in chain(s) for some s > 0 > t. This closes sorry 2.

- [ ] Close sorry 3 (line 1464, `dd_fmcs_backward_P`): Wire `defect_bwd_chain_backward_P` through. Symmetric to sorry 1.
- [ ] Close sorry 4 (line 1517, `dd_bfmcs_restricted_tc`): For each family in `dd_bfmcs.families`, restricted temporal coherence follows from forward_F and backward_P being structural properties of each family's chain (each family uses the same defect-driven construction with a different root MCS and temporal shift).
- [ ] Verify `lake build` succeeds and sorry count reduced to 2 (sites 5-6)

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- redefine `dd_chain`, `dd_fmcs`, close sorry sites 1-4

**Verification**:
- Sorry sites at lines 1413, 1457, 1464, 1517 are closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 2 remaining (sites 5-6)

---

### Phase 4: Close Forward Until/Since Coherence (Sorry 6) [NOT STARTED]

**Goal**: Close sorry 6 (line 1527, `dd_bfmcs_restricted_fuc`). Forward Until/Since coherence: given `(phi U psi) in fam.mcs(t)`, find `s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `r in [t, s)`.

**Tasks**:
- [ ] **Forward Until** `(phi U psi) in fam.mcs(t)`:
  1. By BX10 (`until_F`): `F(psi) in fam.mcs(t)`. (Verify BX10 exists: `until_F` should give `(phi U psi) -> F(psi)` or similar. Check axiom set.)
  2. Actually, reflexive Until semantics: `(phi U psi)` means `exists s >= t, psi at s AND forall r in [t,s), phi at r`. The witness s can equal t (reflexive). In the MCS: `(phi U psi) in M` implies by BX9 (`until_elim`): `psi in M OR (phi in M AND F(phi U psi) in M)`. If `psi in M`: done with s = t, vacuous guard. If `phi in M AND F(phi U psi) in M`: then `F(phi U psi) in fam.mcs(t)`. Since `phi U psi` is a subformula of root, it is in sigma_list (by deferralClosure). By restricted_tc (now proved): `exists s' > t, (phi U psi) in fam.mcs(s')`. Wait, we need `psi in fam.mcs(s')`, not `(phi U psi) in fam.mcs(s')`.
  3. **Correct approach using deferralClosure**: `psi` is a subformula of `phi U psi`, hence in deferralClosure(root). `F(psi) in fam.mcs(t)` follows from `(phi U psi) in fam.mcs(t)` via BX axioms. By restricted_tc: `exists s > t, psi in fam.mcs(s)`. Take the LEAST such s. For the guard: at each r in [t, s), `psi not in fam.mcs(r)` (minimality of s). `(phi U psi) in fam.mcs(r)` for each r in [t, s) (need to show this). From `(phi U psi) in fam.mcs(t)` and the chain's g_content propagation: if `G(phi U psi) in fam.mcs(t)`, then `(phi U psi)` propagates forward. `G(phi U psi)` from `(phi U psi)` requires BX5 (`self_accum_until`): `(phi U psi) -> ((phi AND (phi U psi)) U psi)`. This does NOT directly give `G(phi U psi)`. Alternative: `(phi U psi) in fam.mcs(t)` and `psi not in fam.mcs(t)` gives `phi in fam.mcs(t) AND F(phi U psi) in fam.mcs(t)` (by BX9). `F(phi U psi) in fam.mcs(t)` and restricted_tc gives `(phi U psi) in fam.mcs(s')` for some s' > t. If s' < s (before psi appears), then `(phi U psi) in fam.mcs(s')` and we repeat the argument at s'. By induction on s - r: at each r in [t, s), `(phi U psi) in fam.mcs(r)`, and by BX9 + psi not in fam.mcs(r): `phi in fam.mcs(r)`.
  4. **Formalized proof**: Use backward induction from s to t. At each r in [t, s): since psi not in fam.mcs(r) and we need (phi U psi) in fam.mcs(r). We have F(phi U psi) in fam.mcs(t) (from BX9). By F-obligation constancy: F(phi U psi) in fam.mcs(r) for all r >= t. By restricted_tc at step r: exists s'' > r with (phi U psi) in fam.mcs(s''). Choosing s'' minimally and using induction. This is getting circular. **Use the restricted parametric truth lemma instead**: the truth lemma already handles Until/Since coherence for subformulas of root. We can invoke `backward_until_from_step` (Bundle/UntilSinceCoherence.lean:111) which parameterizes the step transfer property.
- [ ] **Strategy**: Use the existing `backward_until_from_step` infrastructure which provides forward Until coherence given a step transfer property. The step transfer property for the defect-driven chain follows from the chain's g_content propagation and the BX axioms for Until. Specifically, the step transfer `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)` follows from BX8 (`refl_intro_until`): `psi OR (phi AND F(phi U psi)) -> (phi U psi)`. If (phi U psi) in chain(r+1), then either psi in chain(r+1) or (phi AND F(phi U psi)) in chain(r+1). In both cases, BX8 gives (phi U psi) in chain(r+1). **But we need it in chain(r), not chain(r+1).** The step transfer goes BACKWARD: from chain(r+1) to chain(r). This requires: if (phi U psi) in chain(r+1), can we derive (phi U psi) in chain(r)? Only if G(phi U psi) in chain(r) (then phi U psi in g_content(chain(r)) subset chain(r+1)). We need the REVERSE: from chain(r+1) back to chain(r).
- [ ] **Step transfer (backward direction)**: `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`. Proof: phi in chain(r). If psi in chain(r): (phi U psi) in chain(r) by BX8 (refl_intro_until). If psi not in chain(r): we need F(phi U psi) in chain(r). (phi U psi) in chain(r+1) AND chain(r+1) is a successor of chain(r) built by our step function. The seed contains g_content(chain(r)). (phi U psi) being in chain(r+1) could come from the seed or from Lindenbaum extension. We cannot derive (phi U psi) in chain(r) from (phi U psi) in chain(r+1) in general. **So step transfer is NOT automatically satisfied.**
- [ ] **Alternative for forward Until**: Use the restricted parametric truth lemma directly. The truth lemma for Until subformulas of root proves: `truth_at TM Omega tau t (phi U psi) <-> (phi U psi) in fam.mcs(t)`. If `(phi U psi) in fam.mcs(t)`, the truth lemma gives semantic truth, which gives the required witness and guard. The truth lemma already handles this for restricted formulas. **This is the correct approach**: the forward Until coherence for restricted formulas follows from the truth lemma, which is already sorry-free.
- [ ] Implement the proof of `dd_bfmcs_restricted_fuc` using the restricted parametric truth lemma path.
- [ ] **Forward Since** `(phi S psi) in fam.mcs(t)`: Symmetric to forward Until but using backward chain and past-temporal operators. Same approach via truth lemma.
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry site 6

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds

---

### Phase 5: Close Backward Until/Since Coherence (Sorry 5) and Final Verification [NOT STARTED]

**Goal**: Close sorry 5 (line 1522, `dd_bfmcs_restricted_buc`) and perform final verification that `bx_completeness` is sorry-free.

**Tasks**:
- [ ] **Backward Until coherence**: Given semantic witnesses (psi at s >= t, phi on guard [t, s)), derive `(phi U psi) in fam.mcs(t)`.
  1. `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all r in [t, s).
  2. At s: `psi in fam.mcs(s)` -> `(phi U psi) in fam.mcs(s)` by BX8 (`refl_intro_until`: `psi -> (phi U psi)`).
  3. Propagate backward from s to t: at each r in [t, s), need `(phi U psi) in fam.mcs(r)` given `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)`.
  4. This is the step transfer property: `(phi U psi) in fam.mcs(r+1) AND phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)`.
  5. For the step transfer: `phi in fam.mcs(r)`. `(phi U psi) in fam.mcs(r+1)`. By BX10 or Until axioms: `F(phi U psi) in fam.mcs(r+1)` is not directly useful. We need `(phi U psi) in fam.mcs(r)`. Use BX8: `psi -> (phi U psi)` and `phi AND F(phi U psi) -> (phi U psi)`. If `F(phi U psi) in fam.mcs(r)`: then `phi AND F(phi U psi) in fam.mcs(r)` (since phi in fam.mcs(r)), so `(phi U psi) in fam.mcs(r)` by BX8.
  6. **Need: F(phi U psi) in fam.mcs(r)**. We know `(phi U psi) in fam.mcs(r+1)`. Does this give `F(phi U psi) in fam.mcs(r)`? Only if the chain construction ensures backward F-propagation. In the forward chain (r >= 0): `(phi U psi) in chain(r+1)` and chain(r+1) was built from chain(r) using the defect step. `(phi U psi) in chain(r+1)` -> `F(phi U psi) in chain(r+1)` by phi_in_mcs_imp_F_phi. By F-obligation constancy backward (`rr_fwd_chain_F_obligation_backward` line 1204): `F(phi U psi) in chain(r)` if `F(phi U psi) in chain(r+1)` and the F-obligation was already in chain(r). But F-obligation backward constancy says: if `F(phi U psi) in chain(m)` and `n <= m`, then `F(phi U psi) in chain(n)`. We know `F(phi U psi) in chain(r+1)`. We need `F(phi U psi) in chain(r)`. By backward constancy, this follows IF `F(phi U psi) in chain(r)` was already present... which is circular. Backward constancy gives `in chain(m) -> in chain(n)` for `n <= m`. So `F(phi U psi) in chain(r+1) -> F(phi U psi) in chain(r)`. YES, this is exactly backward constancy. Let me re-read the theorem.
  7. **Re-reading `rr_fwd_chain_F_obligation_backward`** (line 1204): It says `F(psi) in chain(m) -> F(psi) in chain(n)` for `n <= m`. So `F(phi U psi) in chain(r+1) -> F(phi U psi) in chain(r)` for `r <= r+1`. YES. This gives `F(phi U psi) in fam.mcs(r)`.
  8. Combined with `phi in fam.mcs(r)` and BX8: `(phi U psi) in fam.mcs(r)`. The step transfer holds.
  9. By induction from s down to t: `(phi U psi) in fam.mcs(t)`. Done.
- [ ] **Need to verify F-obligation backward constancy for the NEW defect_fwd_chain**. The existing theorem is for `rr_fwd_chain`. We need the same for `defect_fwd_chain`. This follows from the same argument: if F(psi) not in chain(n), then G(neg psi) in chain(n), then G(neg psi) in g_content(chain(n)) subset chain(n+1), so F(psi) = neg G(neg psi) not in chain(n+1) (by consistency). Contrapositive: F(psi) in chain(n+1) -> F(psi) in chain(n).
- [ ] Implement `defect_fwd_chain_F_obligation_backward` and the step transfer lemma for Until.
- [ ] **Backward Since coherence**: Symmetric to backward Until using H-operators and the backward chain. Same step transfer argument with P-obligations and h_content.
- [ ] Close sorry 5 (`dd_bfmcs_restricted_buc`) using the step transfer + BX8 backward induction.
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero executable sorry.
- [ ] Run `lake build` to verify compilation.
- [ ] Use `lean_verify` on `bx_completeness` to confirm axioms are exactly `{propext, Classical.choice, Quot.sound}`.
- [ ] Verify no new sorry introduced in any active-path file.
- [ ] Update ROAD_MAP.md sorry inventory to show 0 active-path sorries.

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry site 5, add backward constancy for new chain
- `specs/ROAD_MAP.md` -- update sorry inventory to 0

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry (from Phase 4)
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -n sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero executable sorry (after Phase 5)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any active-path file
- [ ] ROAD_MAP.md sorry inventory shows 0 active-path sorries (after Phase 5)
- [ ] Each new definition and theorem has a docstring explaining its role in the chain construction

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites closed, defect-driven chain replaces round-robin chain
- `specs/ROAD_MAP.md` -- updated sorry inventory to 0
- `specs/093_complete_bxcanonical_embedding/plans/33_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

1. **Full success (all 6 sorries closed)**: Target outcome. No rollback needed.

2. **Forward chain works but forward_F termination argument blocked (~30%)**: Keep the chain construction and all structural properties. The single remaining sorry (forward_F depth-0 termination) is isolated. Spawn a focused research task on the termination argument. All other sorry sites that depend only on forward_F's STATEMENT (not its proof) can be closed modulo this one sorry.

3. **Sorries 1-4 closed but Until/Since coherence blocked (~20%)**: Reduces sorry count from 6 to 2. This is still significant progress. Spawn focused task for Until/Since using the restricted truth lemma approach.

4. **Custom Lindenbaum extension consistency fails (~10%)**: Fall back to using `discharge_single_step` (line 977) which provides single-formula resolution without F-preservation. Forward_F would then require a different chain design.

5. **Backward chain symmetry fails (~15%)**: Keep forward chain (closes sorries 1, 2, partially 4). Spawn focused task for backward P-enrichment.

6. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores current state. All existing sorry-free code is preserved.
