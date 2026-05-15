# Implementation Plan: Task #141

- **Task**: 141 - canonical_truth_lemma_until_since
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (tasks 139/140 are parallel, not prerequisites)
- **Research Inputs**: specs/141_canonical_truth_lemma_until_since/reports/01_team-research.md
- **Artifacts**: plans/01_truth-lemma-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 8 sorries in the WeakCanonical module: 2 in ReflexiveCanonical.lean (canS5R_symm, reflCanR_linear) and 6 in TruthLemma.lean (until/since forward/backward + truth lemma cases). The two ReflexiveCanonical sorries are immediately solvable with existing infrastructure. The six TruthLemma sorries face a fundamental blocker: the removal of BX8/BX9 under open-guard semantics broke the standard chain construction for the Until/Since guard condition. The plan proceeds in order of increasing difficulty, with an early critical-path verification to calibrate investment in the harder phases.

### Research Integration

Key findings from team research (4 teammates, high confidence):
- **Group A** (ReflexiveCanonical, 2 sorries): `canS5R_symm` is a clean 20-line proof via modal_b + negation completeness. `reflCanR_linear` requires porting F_from_witness pattern + BX11 case analysis (~50 lines).
- **Group B** (TruthLemma, 6 sorries): All trace to the intermediate guard condition for Until/Since forward, which cannot use `until_F_expansion` (itself sorry'd due to BX8/BX9 removal). Two approaches identified: Burgess enriched seed (BX13) or direct BX5 chain.
- **Critical warning**: DovetailingChain.lean does not exist; `until_F_expansion` is sorry'd; `diamond_box_duality` lives in Completeness.lean (not imported by ReflexiveCanonical.lean).
- The truth_lemma sorries DO propagate into `bx_completeness` (confirmed: `doets_countermodel_discrete` is the discrete case handler, and the fallback chronicle path still has sorries). However, the truth_lemma is not currently called by the fallback -- it will be needed once truth transfer (task 140) is complete.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Directly advances: "Canonical truth lemma: 8 sorries in Until/Since and ReflexiveCanonical infrastructure (task 141)" from ROADMAP.md critical path
- On the critical path: Task 129 (COMPLETED) -> 139 -> 140 -> **141** -> 142 -> sorry-free `bx_completeness`
- Closing these 8 sorries reduces the total sorry count blocking `bx_completeness` from 14 to 6

## Goals & Non-Goals

**Goals**:
- Close `canS5R_symm` sorry in ReflexiveCanonical.lean
- Close `reflCanR_linear` sorry in ReflexiveCanonical.lean
- Close all 4 Until/Since helper sorries in TruthLemma.lean (until_forward_mcs, until_backward_mcs, since_forward_mcs, since_backward_mcs)
- Close the 2 truth_lemma case sorries (Until and Since cases, lines 548 and 563)
- Verify sorry propagation via `#print axioms bx_completeness` before and after

**Non-Goals**:
- Fixing `until_F_expansion` in TemporalDerived.lean (sorry'd due to BX8/BX9 removal; not needed for this task)
- Addressing BXCanonical pipeline sorries (dead code under irreflexive semantics)
- Completing the Reynolds truth transfer (task 140)
- Modifying axiom definitions or adding new axioms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard condition proof (until_forward_mcs) may be fundamentally blocked under open-guard semantics | H | M | Two independent approaches identified (Burgess enriched seed via BX13, direct BX5 chain). If both fail, document the obstacle and mark phase BLOCKED. |
| `diamond_box_duality` import may cause build issues | L | L | Completeness.lean has no WeakCanonical imports, so adding the import is safe. Alternatively, re-derive the 5-line duality inline. |
| BX5 self-accumulation may not suffice without BX8/BX9 for chain propagation | H | M | BX5 gives U(psi1,phi) -> U(psi1, phi AND U(psi1,phi)), which enriches the guard. Combined with BX13 enrichment, this may provide the needed propagation without BX8/BX9. |
| Since/Until backward direction is contrapositive of what truth_lemma needs | M | L | The existing backward signatures already have the correct contrapositive form. The truth_lemma Until/Since backward cases at lines 548/563 need the contrapositive applied to the induction hypotheses. |
| Time overrun on Group B phases | M | M | Group A phases are quick wins (1.5h). If Group B takes longer than estimated, mark partial and document progress. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Critical Path Verification and canS5R_symm [NOT STARTED]

**Goal**: Verify sorry propagation into bx_completeness, then close the easiest sorry (canS5R_symm).

**Tasks**:
- [ ] Run `#print axioms bx_completeness` to confirm `sorryAx` appears and identify which sorries propagate
- [ ] Run `#print axioms Bimodal.Metalogic.WeakCanonical.truth_lemma` to check if truth_lemma sorries are independent or connected
- [ ] Add `import Bimodal.Metalogic.Completeness` to ReflexiveCanonical.lean (needed for `SetMaximalConsistent.diamond_box_duality`). Alternatively, if import causes issues, re-derive the duality inline (~5 lines using `neg_box_implies_diamond_neg` from MCSProperties)
- [ ] Prove `canS5R_symm` at ReflexiveCanonical.lean:424 using the following proof sketch:
  ```
  Given: canS5R x y (∀χ, □χ ∈ x.val → χ ∈ y.val) and □φ ∈ y.val
  Goal: φ ∈ x.val
  By contradiction: suppose φ ∉ x.val
  1. ¬φ ∈ x.val (negation completeness)
  2. modal_b on ¬φ: ¬φ → □◇(¬φ) is a theorem, so □◇(¬φ) ∈ x.val
  3. ◇(¬φ) = (¬φ).neg.box.neg = ¬□(¬¬φ). Need to show □◇(¬φ) ∈ x → ◇(¬φ) ∈ y → ¬□φ ∈ y
     Actually: ◇(¬φ) = (¬φ).diamond = (¬φ).neg.box.neg
     □◇(¬φ) ∈ x, so by canS5R x y: ◇(¬φ) ∈ y
     ◇(¬φ) = ¬□(¬¬φ). Use diamond_box_duality or unfold definitions.
     Need: ◇(¬φ) ∈ y implies ¬□(¬¬φ) ∈ y. Then □(¬¬φ) ∉ y.
     But □φ ∈ y. Show □φ → □(¬¬φ) is a theorem (double negation intro under box).
     Then □(¬¬φ) ∈ y. Contradiction.
  ```
- [ ] Verify `lake build` succeeds after the change

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Add import + prove canS5R_symm

**Verification**:
- `lake build` succeeds
- `grep -c 'sorry' ReflexiveCanonical.lean` shows 1 (only reflCanR_linear remains)

---

### Phase 2: reflCanR_linear (Forward Linearity) [NOT STARTED]

**Goal**: Close the second ReflexiveCanonical sorry by proving forward linearity of tempR_fwd using BX11.

**Tasks**:
- [ ] Create helper `F_from_witness_refl`: If G(ψ) ∉ x.val, then F(¬ψ) ∈ x.val. This follows from negation completeness: G(ψ) ∉ x → ¬G(ψ) ∈ x → F(¬ψ) ∈ x (since F(¬ψ) = ¬G(¬¬ψ) = ¬G(ψ) by double negation, but need to verify Formula.some_future definition). Actually F(α) = ¬G(¬α), so F(¬ψ) = ¬G(¬¬ψ). Need to show ¬G(ψ) = ¬G(¬¬ψ) is provable, or use a different encoding.
  Simpler approach: G(ψ) ∉ x → ¬G(ψ) ∈ x (negation completeness). Since ¬G(ψ) = F(¬ψ) by definition of some_future (F(α) = ¬G(¬α), so ¬G(ψ) = F(¬(¬ψ))... no). Let's be precise:
  - F(α) = Formula.some_future α = α.neg.all_future.neg = (α → ⊥).all_future → ⊥
  - ¬G(ψ) = G(ψ) → ⊥ = ψ.all_future.neg
  - These are syntactically different from F(¬ψ) = (¬ψ).neg.all_future.neg = ((ψ→⊥)→⊥).all_future.neg
  - Actually: ¬G(ψ) IS F(ψ) when ψ is NOT double-negated. No: ¬G(ψ) = G(ψ).neg = ψ.all_future → ⊥. F(ψ) = ψ.neg.all_future.neg = (ψ→⊥).all_future → ⊥.
  - These are DIFFERENT: ¬G(ψ) vs F(ψ). Need: ¬G(ψ) ↔ F(ψ) as a derived theorem, then work in MCS.
  - Better approach: work directly with negation completeness. From ¬tempR_fwd y z, get ψ with G(ψ) ∈ y.val and ψ ∉ z.val. Since ψ ∉ z.val, ¬ψ ∈ z.val. Since tempR_fwd x z, we need G(¬ψ) ∉ x.val (otherwise ¬ψ ∈ y.val, but we also need ψ ∈ y.val from G(ψ)... need to think more carefully about the BX11 argument).
  - The actual BX11 argument: show F(¬ψ) ∈ x.val and F(¬χ) ∈ x.val, then apply BX11.
  - From ψ ∉ z.val and tempR_fwd x z: if G(ψ) ∈ x.val, then ψ ∈ z.val (contradiction). So G(ψ) ∉ x.val. Then ¬G(ψ) ∈ x.val (negation completeness). Need to convert ¬G(ψ) to F(¬ψ) in MCS -- this requires proving ¬G(ψ) ↔ F(¬ψ) as formulas in the logic, or showing they are propositionally equivalent.
  - Key insight: ¬G(ψ) = G(ψ)→⊥. F(¬ψ) = ((ψ→⊥)→⊥).all_future → ⊥. These are NOT syntactically equal. But propositionally: ¬G(ψ) ↔ F(¬ψ) requires ψ ↔ ¬¬ψ under G, i.e., G(ψ) ↔ G(¬¬ψ). This follows from G being a normal modal operator and ψ ↔ ¬¬ψ being a tautology.
  - Simpler: just use ¬G(ψ) directly in the BX11 argument. BX11 is about F(φ) ∧ F(ψ), where F is some_future. We need to produce something of the form `Formula.some_future α ∈ x.val`. Since some_future α = α.neg.all_future.neg, we need (α.neg.all_future → ⊥) ∈ x.val.
  - The cleanest approach: prove a helper `neg_G_imp_F_neg` showing that if G(ψ) ∉ x.val (MCS), then F(¬ψ) ∈ x.val in the MCS. Proof: G(ψ) ∉ x → ¬G(ψ) ∈ x. Need ¬G(ψ) → F(¬ψ) as a theorem. ¬G(ψ) = G(ψ)→⊥. F(¬ψ) = (¬ψ).neg.all_future.neg = ((ψ→⊥)→⊥).all_future → ⊥. Proving G(ψ)→⊥ → ((ψ→⊥)→⊥).all_future → ⊥ requires double negation. Actually need the converse: prove ¬G(ψ) → F(¬ψ). We have ¬G(ψ). F(¬ψ) = ¬G(¬¬ψ). We need G(¬¬ψ) → G(ψ) (then contrapositive gives ¬G(ψ) → ¬G(¬¬ψ) = F(¬ψ)). G(¬¬ψ) → G(ψ) follows from ¬¬ψ → ψ (double negation) via temp_k_dist + temporal_necessitation.
- [ ] Implement the BX11 proof for reflCanR_linear at line 144:
  ```
  By contradiction: assume ¬tempR_fwd y z and ¬tempR_fwd z y
  1. Get ψ: G(ψ) ∈ y.val, ψ ∉ z.val (from ¬tempR_fwd y z via g_content witness)
  2. Get χ: G(χ) ∈ z.val, χ ∉ y.val (from ¬tempR_fwd z y)
  3. G(ψ) ∉ x.val (else ψ ∈ z.val via tempR_fwd x z, contradiction)
  4. G(χ) ∉ x.val (else χ ∈ y.val via tempR_fwd x y, contradiction)
  5. F(¬ψ) ∈ x.val (from step 3, using neg_G_imp_F_neg helper)
  6. F(¬χ) ∈ x.val (from step 4)
  7. F(¬ψ) ∧ F(¬χ) ∈ x.val (MCS conjunction)
  8. BX11 (temp_linearity): F(¬ψ) ∧ F(¬χ) → F(¬ψ ∧ ¬χ) ∨ F(¬ψ ∧ F(¬χ)) ∨ F(F(¬ψ) ∧ ¬χ)
  9. Case analysis on three disjuncts, each leading to contradiction:
     - F(¬ψ ∧ ¬χ): get witness w with ¬ψ,¬χ ∈ w and tempR_fwd x w. But G(ψ)∈y, tempR_fwd x y, tempR_fwd x w — need to connect y and w.
     - Actually the contradiction comes from: in each case, derive that either ψ ∈ z or χ ∈ y, contradicting our assumptions.
  ```
  Note: The exact proof may require careful treatment of the three BX11 disjuncts. Follow the pattern from BXCanonical if available.
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Add helper lemma(s) + prove reflCanR_linear

**Verification**:
- `lake build` succeeds
- `grep -c 'sorry' ReflexiveCanonical.lean` shows 0

---

### Phase 3: until_backward_mcs and since_backward_mcs [NOT STARTED]

**Goal**: Close the backward direction sorries for Until and Since. These are contrapositives: if U(psi1,psi2) not in x, then no semantic Until witness exists.

**Tasks**:
- [ ] Prove `until_backward_mcs` at TruthLemma.lean:443. Proof sketch:
  ```
  Given: U(ψ₁,ψ₂) ∉ x.val
  Goal: ¬∃y, tempR_fwd x y ∧ ψ₁ ∈ y.val ∧ (∀z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val)
  
  By contradiction: assume ∃y with the semantic Until condition.
  Obtain y, h_fwd, h_psi1_y, h_guard.
  
  Approach: Use BX6 (absorb_until) + negation completeness.
  Since U(ψ₁,ψ₂) ∉ x.val, ¬U(ψ₁,ψ₂) ∈ x.val.
  From h_guard: every z between x and y has ψ₂ ∈ z.val.
  
  Key idea: Show G(¬U(ψ₁,ψ₂)) ∈ x.val is impossible (it would make ¬U propagate
  to y, but then U(ψ₁,ψ₂) ∉ y... but we don't know U ∈ y either).
  
  Alternative: Direct construction. ¬U(ψ₁,ψ₂) ∈ x.val. This means
  G(¬ψ₁ ∨ F(¬ψ₂)) ∈ x.val (by the contrapositive of Until semantics in the logic).
  But this requires until_F_expansion which is sorry'd.
  
  Cleanest approach: Since the truth_lemma only needs the contrapositive form
  that is already stated (¬U → ¬semantic), and the truth lemma backward case
  at line 548 needs: semantic → U ∈ x.val, we can use the contrapositive:
  ¬U ∈ x.val → ¬semantic. The truth lemma backward case can then be proved
  by contraposition using until_backward_mcs.
  
  Proof of until_backward_mcs itself:
  Assume for contradiction that ∃y with tempR_fwd x y, ψ₁ ∈ y.val, and guard.
  Since U(ψ₁,ψ₂) ∉ x, ¬U(ψ₁,ψ₂) ∈ x (negation completeness).
  Since tempR_fwd x y, g_content x ⊆ y. So G(¬U(ψ₁,ψ₂)) ∈ x → ¬U ∈ y.
  But we don't know G(¬U) ∈ x, only ¬U ∈ x.
  
  Need: show that the guard condition + ψ₁ ∈ y + ¬U ∈ x leads to contradiction.
  Use self-accumulation BX5: U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)).
  Contrapositive: ¬U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) → ¬U(ψ₁,ψ₂). No, wrong direction.
  
  Actually, this proof direction may be simpler than it appears:
  The hypothesis gives us a concrete semantic witness (y, with guard).
  We need to derive U(ψ₁,ψ₂) ∈ x.val from this, contradicting ¬U ∈ x.
  This is essentially proving the FORWARD direction of the truth lemma for Until!
  
  So until_backward_mcs (contrapositive: semantic → formula) is equivalent to
  the truth lemma backward case. We should prove it as part of the truth lemma
  directly, using induction on formula complexity. The helper until_backward_mcs
  should be restated or proved using the induction hypothesis from truth_lemma.
  
  REVISED APPROACH: Prove the truth_lemma Until backward case (line 548) directly
  by rewriting until_backward_mcs to use the induction hypotheses ih_φ, ih_ψ.
  The standalone until_backward_mcs (without IH) may not be provable.
  ```
- [ ] If standalone until_backward_mcs is not provable without IH, restructure: move the proof logic into the truth_lemma case directly, using ih_φ and ih_ψ to convert between semantic truth and formula membership. Mark the standalone theorem as a corollary.
- [ ] Prove `since_backward_mcs` at TruthLemma.lean:494 using the mirror argument (past direction).
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Prove backward directions or restructure

**Verification**:
- `lake build` succeeds
- Backward direction sorries closed (2 of 6 TruthLemma sorries)

---

### Phase 4: until_forward_mcs and since_forward_mcs (Guard Condition) [NOT STARTED]

**Goal**: Close the hardest sorries -- the intermediate guard condition for Until/Since forward direction. This is the core technical challenge of the task.

**Tasks**:
- [ ] Investigate approach 1 (Burgess enriched seed via BX13):
  - Enrich the witness seed from `{ψ₁} ∪ g_content(x)` to `{ψ₁} ∪ {S(α, ψ₂) | α ∈ x.val} ∪ g_content(x)`
  - Use BX13 (enrichment_until): `p ∧ U(ψ,φ) → U(ψ ∧ S(p,φ), φ)` to show the enriched seed is consistent
  - If seed is consistent, Lindenbaum gives MCS y with the enriched formulas
  - The Since formulas `S(α, ψ₂) ∈ y` encode the guard: for any intermediate z with tempR_fwd x z and tempR_fwd z y, the S formula forces ψ₂ ∈ z.val
  - Challenge: proving the enriched seed is consistent requires showing no finite subset derives ⊥
- [ ] If approach 1 fails, investigate approach 2 (direct BX5 chain):
  - Use BX5 (self_accum_until): `U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂))`
  - This gives: at every intermediate point, both ψ₂ holds AND U(ψ₁,ψ₂) persists
  - Apply BX5 to get U(ψ₁, ψ₂) ∈ x.val → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val
  - The enriched guard `ψ₂ ∧ U(ψ₁,ψ₂)` propagates through g_content to intermediate MCS
  - The key is: if z has tempR_fwd x z and tempR_fwd z y, does the enriched Until at x force ψ₂ ∈ z?
  - Need: U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)) ∈ x.val, and g_content x ⊆ z.val. But U is not a G-formula, so it doesn't propagate via g_content.
  - This approach requires converting U membership to G membership, which is the core obstacle.
- [ ] If both approaches are blocked, attempt a direct proof using the existing seed structure:
  - The current seed is `{ψ₁} ∪ g_content(x)`. The MCS y already satisfies g_content(x) ⊆ y.val.
  - For intermediate z with g_content(x) ⊆ z.val and g_content(z) ⊆ y.val:
  - Need ψ₂ ∈ z.val. Since U(ψ₁,ψ₂) ∈ x.val and z shares g_content with x, does U propagate?
  - BX5 gives U(ψ₁,ψ₂) → U(ψ₁, ψ₂ ∧ U(ψ₁,ψ₂)). So the enriched guard holds at the witness.
  - But we need ψ₂ at INTERMEDIATE points, not the witness.
  - Key: G(ψ₂ → ψ₂) is trivially in x. So G(ψ₂) ∈ x → ψ₂ propagates. But we don't know G(ψ₂) ∈ x.
- [ ] Implement the working approach for `until_forward_mcs` (guard condition at line 426)
- [ ] Mirror the proof for `since_forward_mcs` at line 479 (past direction using BX5'/BX6'/BX13')
- [ ] If all approaches fail: document the blocker precisely, identify what lemma or axiom would unblock it, and mark the phase [BLOCKED]

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Prove forward guard conditions (or mark blocked)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Helper lemmas if needed

**Verification**:
- `lake build` succeeds
- Forward direction sorries closed (4 of 6 TruthLemma sorries, or phase marked BLOCKED with documentation)

---

### Phase 5: truth_lemma Until/Since Cases [NOT STARTED]

**Goal**: Wire the helper lemmas into the main truth_lemma proof for the Until and Since cases (lines 548, 563).

**Tasks**:
- [ ] Close truth_lemma Until backward case (line 548): `reflCanTruth x (untl φ ψ) → untl φ ψ ∈ x.val`
  - From `h_truth: ∃y, tempR_fwd x y ∧ reflCanTruth y φ ∧ (∀z, ...)`, use ih_φ/ih_ψ to convert reflCanTruth to formula membership
  - Apply until_backward_mcs (contrapositive) or prove directly using the induction hypotheses
  - Proof sketch: by_contra h_not. Then ¬U(φ,ψ) ∈ x. Apply until_backward_mcs to get ¬semantic. But we have h_truth (semantic). Contradiction.
- [ ] Close truth_lemma Since backward case (line 563): `reflCanTruth x (snce φ ψ) → snce φ ψ ∈ x.val`
  - Mirror of Until case using since_backward_mcs
- [ ] Verify `lake build` succeeds
- [ ] Run `#print axioms Bimodal.Metalogic.WeakCanonical.truth_lemma` to confirm no `sorryAx`

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Wire helper lemmas into truth_lemma cases

**Verification**:
- `lake build` succeeds
- `grep -c 'sorry' TruthLemma.lean` shows 0
- `#print axioms truth_lemma` shows no `sorryAx`

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify all sorries are closed, check critical path impact, and clean up documentation.

**Tasks**:
- [ ] Run full `lake build` to confirm no regressions
- [ ] Run `#print axioms bx_completeness` to check if sorry count decreased
- [ ] Count remaining sorries: `grep -rn 'sorry' Theories/Bimodal/Metalogic/WeakCanonical/`
- [ ] Update docstrings in TruthLemma.lean and ReflexiveCanonical.lean to reflect sorry-free status
- [ ] Remove or update "DOCUMENTED SORRY" comments that are no longer applicable
- [ ] Update the Status section in TruthLemma.lean module docstring
- [ ] If any phases were BLOCKED, document what remains and what would unblock it

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Update docstrings

**Verification**:
- `lake build` succeeds with zero sorries in WeakCanonical/
- All docstrings accurately reflect current sorry status

## Testing & Validation

- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn 'sorry' Theories/Bimodal/Metalogic/WeakCanonical/` returns 0 matches (or documents remaining blockers)
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.truth_lemma` shows no `sorryAx`
- [ ] `#print axioms bx_completeness` still shows `sorryAx` (expected -- other tasks have remaining sorries) but with fewer transitive dependencies from WeakCanonical
- [ ] No regressions in existing sorry-free proofs

## Artifacts & Outputs

- `specs/141_canonical_truth_lemma_until_since/plans/01_truth-lemma-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` (2 sorries closed)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` (6 sorries closed)

## Rollback/Contingency

- If Phase 4 (guard condition) is blocked, close only Group A sorries (Phases 1-2) and the backward directions (Phase 3). This still reduces sorry count from 8 to 2-4 and provides value.
- All changes are in 2 files only. Git revert of those files restores the prior state.
- If the import of Completeness.lean causes issues, the `diamond_box_duality` can be re-derived inline (it is a 5-line consequence of negation completeness and MCS properties already available).
- If BX11 proof is harder than expected, the `reflCanR_linear` sorry can be left for a follow-up while still closing canS5R_symm.
