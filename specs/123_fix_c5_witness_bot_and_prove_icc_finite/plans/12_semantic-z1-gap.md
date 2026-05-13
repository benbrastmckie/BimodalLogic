# Implementation Plan: Z1 Axiom and Doets Gap Elimination (v15)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/09_prior-uz-issucc-analysis.md (key finding: Prior-UZ requires IsSuccArchimedean, Z1 not derivable)
  - All prior reports from rounds 04-14 (integrated in plans v4-v14)
- **Artifacts**: plans/12_semantic-z1-gap.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version (v15):**
- `09_prior-uz-issucc-analysis.md` (newly integrated in v15 — key finding)
- All reports from v4-v14 preserved

### Why Plan v15 Supersedes Plan v14

Plan v14 attempted to derive Z1 syntactically from Prior-UZ + BX axioms. This was confirmed **impossible**: Z1 is not a theorem of the discrete logic. Counterexample: ω+ω* (and ℤ+ℤ) satisfies all BX axioms and Prior-UZ but Z1 fails. Z1 characterizes IsSuccArchimedean specifically.

**Further critical discovery**: Prior-UZ itself is invalid on ℤ+ℤ. The soundness proof `prior_UZ_is_valid` genuinely requires `[IsSuccArchimedean D]` (uses `exists_succ_iterate` to find nearest witnesses). This means the current "discrete logic" is actually the "integer logic" — it targets ℤ specifically, not all discrete linear orders.

**Resolution**: Add Z1 as an axiom with soundness proved using `[IsSuccArchimedean D]` on abstract frames. No circularity — soundness is for abstract ℤ-like frames, not the limit model. The limit model has Z1 in every MCS (because it's an axiom → derivable → `theorem_in_mcs`), enabling the Doets maximum principle to prove IsSuccArchimedean of the limit model.

The frame hierarchy split (separating discrete from integer frame classes) is deferred to task 126.

**Confirmed blocked approaches (do NOT attempt):**
1. Z1 derivation from Prior-UZ (Z1 is NOT a theorem of the axiom system)
2. Stage-induction on `succ_reaches_dom_N` (boundary cases unprovable)
3. Direct semantic gap contradiction (constant-MCS case is consistent with temporal axioms)
4. Frozen succ-links invariant (already fully exploited for SuccOrder, cannot give IsSuccArchimedean)

## Overview

Close the remaining sorry in `succ_cofinal` by adding Z1 as an axiom with a soundness proof, then using Z1 in every MCS to apply the Doets maximum principle argument. Z1 is `G(Gφ→φ) → (FGφ→Gφ)`, valid on all IsSuccArchimedean discrete linear orders. Once Z1 is in every MCS, any bounded definable set has a maximum, which contradicts the gap scenario.

**Definition of done**: `succ_cofinal` sorry-free. `limitDomSubtype_isSuccArchimedean` sorry-free. `dd_countermodel_chronicle_discrete` sorry-free. Full `lake build` passes.

## Goals & Non-Goals

**Goals:**
- Add Z1 as an axiom constructor in `Axiom` inductive type
- Prove Z1 soundness with `[IsSuccArchimedean D]` (backward induction on succ chain)
- Update all axiom pattern matches (~8 theorems) to handle the new constructor
- Use Z1 + Doets maximum principle to close the sorry in `succ_cofinal`
- Make `limitDomSubtype_isSuccArchimedean` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Splitting DiscreteTemporalFrame into discrete + integer hierarchy (task 126)
- Deriving Z1 syntactically (confirmed impossible)
- Fixing stage-induction boundary cases (confirmed blocked)
- Fixing nondense/mixed sorry stubs
- Reynolds contemporaneous equivalence approach (unnecessary if Z1 works)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Adding axiom constructor requires updating many pattern matches | M | H | Systematic: grep for `cases.*Axiom` and `match.*Axiom`, add Z1 arm to each. Agent 2 found ~8 theorems with ~40 arms total. |
| Z1 soundness proof is complex | M | L | The backward induction argument is standard. Use `exists_succ_iterate` + `Nat.find` (same pattern as `prior_UZ_is_valid`). |
| Doets maximum principle needs discriminating formula | M | M | In the constant-MCS case, argue from construction properties that no gap can arise. In the non-constant case, extract discriminating formula via `Classical.choice` on MCS symmetric difference. |
| Constant-MCS gap case is hard to rule out | H | M | Use the fact that backward_G gives G(φ) for all φ in the constant MCS. Then G(Gφ→φ) is trivially in every MCS, and FGφ→Gφ follows. The gap scenario with constant MCS may actually be consistent with Z1 but contradicted by the construction producing identical succ-orbits. Alternative: show MCS can't be constant when orbit ≠ pred-chain. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Add Z1 Axiom and Prove Soundness [COMPLETED]

**Goal**: Add Z1 as a new axiom constructor and prove it sound on IsSuccArchimedean frames.

#### Step 2a: Add Z1 constructor to Axiom inductive (~5 lines)

**Location**: `Theories/Bimodal/ProofSystem/Axioms.lean`

Add a new constructor:
```lean
| z1 (φ : Formula) : Axiom ((φ.all_future.imp φ).all_future.imp (φ.all_future.some_future.imp φ.all_future))
```

This represents Z1: `G(Gφ→φ) → (FGφ→Gφ)`.

#### Step 2b: Update axiom classification (~10 lines)

In the same file, update:
- `Axiom.isDenseCompatible`: add `| z1 _ => False` (Z1 needs IsSuccArchimedean, like Prior-UZ)
- `Axiom.isDiscreteCompatible`: add `| z1 _ => True`
- `Axiom.isBase`: add `| z1 _ => False`
- `Axiom.frameClass`: add `| z1 _ => .Discrete`
- Any other classification predicates

#### Step 2c: Prove Z1 soundness (~30-50 lines)

**Location**: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`, near `prior_UZ_is_valid`.

```lean
theorem z1_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D ((φ.all_future.imp φ).all_future.imp
        (φ.all_future.some_future.imp φ.all_future)) := by
  intro F M Omega h_sc τ h_mem t
  simp only [truth_at]
  intro h_GGpIp h_FGp
  -- h_GGpIp : ∀ s > t, (∀ r > s, truth_at ... r φ) → truth_at ... s φ
  -- h_FGp : ¬(∀ s > t, ¬(∀ r > s, truth_at ... r φ))
  -- i.e., ∃ s > t, ∀ r > s, truth_at ... r φ
  -- Goal: ∀ s > t, truth_at ... s φ
  sorry -- backward induction from the Gφ witness
```

The proof uses backward induction:
1. From `FGφ` at t: ∃ s₀ > t with Gφ at s₀ (i.e., φ at all r > s₀)
2. By `[IsSuccArchimedean D]`: s₀ = succ^[n₀](succ(t)) for some n₀
3. At s₀: Gφ holds. By G(Gφ→φ): Gφ→φ at s₀, so φ at s₀.
4. At pred(s₀) = succ^[n₀-1](succ(t)): φ at s₀ and all r > s₀, so Gφ at pred(s₀). By G(Gφ→φ): φ at pred(s₀).
5. Repeat downward: φ at succ^[k](succ(t)) for all k ≤ n₀.
6. Therefore φ at all r > t, i.e., Gφ at t.

This is the same `Nat.find` + well-founded descent pattern as `prior_UZ_is_valid`.

#### Step 2d: Update all axiom pattern matches (~40-60 lines across ~8 theorems)

Every theorem that pattern-matches on `Axiom` needs a new arm for `z1`. Find them with:
```bash
grep -rn "cases.*h_ax\|cases.*h\b.*with\|match.*Axiom\|Axiom\." Theories/Bimodal/Metalogic/Soundness*.lean | grep -v "^--"
```

Key theorems to update:
- `axiom_locally_valid_general` (SoundnessLemmas.lean) — add `| z1 _ => by simp [Axiom.isDenseCompatible] at hdc`
- `axiom_swap_valid_general` (SoundnessLemmas.lean) — same
- `axiom_locally_valid_discrete` (SoundnessLemmas.lean) — add `| z1 φ => z1_is_valid φ`
- `axiom_swap_valid_discrete` (SoundnessLemmas.lean) — add Z1 swap case
- `axiom_base_valid` (Soundness.lean) — add absurd case (Z1 is not base)
- `axiom_valid_discrete` (Soundness.lean) — add Z1 case
- `axiom_valid_dense` (Soundness.lean) — add absurd case
- Any other `Axiom` matchers

Also update:
- `Axiom.swap_temporal` or related if it exists
- `Axiom.toString` or `repr` if it exists
- Any `Axiom.decEq` or decidability instances

#### Step 2e: Update DerivationTree compatibility (~5 lines)

If `DerivationTree.isDenseCompatible` or `isDiscreteCompatible` recurse into axioms, they should automatically handle Z1 via the updated `Axiom.isDenseCompatible`.

**Tasks:**
- [ ] Add `z1` constructor to `Axiom` inductive
- [ ] Update axiom classification predicates
- [ ] Prove `z1_is_valid` (backward induction with `exists_succ_iterate`)
- [ ] Prove Z1 swap validity (temporal duality)
- [ ] Update all pattern matches in SoundnessLemmas.lean (~4 theorems)
- [ ] Update all pattern matches in Soundness.lean (~4 theorems)
- [ ] Update any other Axiom matchers (search codebase)
- [ ] `lake build` passes

**Timing**: 3-4 hours
**Depends on**: Phase 1

---

### Phase 3: Doets Maximum Principle and Gap Elimination [BLOCKED]

**Goal**: Use Z1 (now an axiom, in every MCS) to close the sorry in `succ_cofinal`.

#### Step 3a: Remove z1_derivation sorry, replace with axiom-based approach (~10 lines)

Replace the current `z1_derivation` (sorry'd DerivationTree) with:
```lean
private def z1_in_mcs (φ : Formula) {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) :
    z1_formula φ ∈ S :=
  theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.z1 φ))
```

Remove the old `z1_derivation` definition.

#### Step 3b: Doets maximum principle helper (~20-30 lines)

**Location**: Before `succ_cofinal` in ChronicleToCountermodel.lean.

```lean
/-- Doets maximum principle: if φ ∈ limit_f(m) and G(¬φ) ∈ limit_f(n) for some n > m,
    then ∃ k with φ ∈ limit_f(k) and G(¬φ) ∈ limit_f(k). -/
private lemma doets_maximum (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (m n : LimitDomSubtype A h_mcs) (hmn : m < n)
    (h_phi_m : φ ∈ limit_f A h_mcs m.val)
    (h_Gneg_n : φ.neg.all_future ∈ limit_f A h_mcs n.val) :
    ∃ k : LimitDomSubtype A h_mcs,
      φ ∈ limit_f A h_mcs k.val ∧
      φ.neg.all_future ∈ limit_f A h_mcs k.val := by
  -- Case split on G(¬φ) at m
  have h_mcs_m := limit_c0 A h_mcs m.val m.property
  rcases SetMaximalConsistent.negation_complete h_mcs_m φ.neg.all_future with h_Gn | h_nGn
  · -- Case 1: G(¬φ) at m. Then k := m.
    exact ⟨m, h_phi_m, h_Gn⟩
  · -- Case 2: ¬G(¬φ) at m, i.e. F(φ) at m. Also FG(¬φ) at m (by backward_F from n).
    -- Z1 with ¬φ: G(G(¬φ)→¬φ) → (FG(¬φ) → G(¬φ))
    -- Modus tollens: ¬G(¬φ) ∧ FG(¬φ) → ¬G(G(¬φ)→¬φ) = F(G(¬φ) ∧ φ)
    -- limit_F_resolution gives k > m with G(¬φ) ∧ φ at k.
    sorry
```

The proof uses:
1. Z1 in MCS of m (via `z1_in_mcs`)
2. `backward_F` to get FG(¬φ) at m
3. Modus tollens via `implication_property` and `negation_complete`
4. `limit_F_resolution` to extract the witness k

#### Step 3c: Close the sorry in succ_cofinal (~30-50 lines)

At the sorry site (line ~1872):

1. **Constant-MCS case**: If all limit_dom points have identical MCS, argue that the construction would not produce a gap (the omega-chain with constant MCS has no counterexamples to resolve between orbit and pred-chain, so no new points are added between them, contradicting the gap geometry). Alternatively, show backward_G gives G(φ) for all φ in the constant MCS, making Gφ→φ trivially true at all points, and Z1 reduces to FGφ→Gφ which is also trivially true.

2. **Non-constant MCS case**: Extract discriminating formula φ (holds at some orbit point, fails at some pred-chain point) via `Classical.choice` on the MCS symmetric difference. The set {x | φ ∈ limit_f(x)} contains orbit points and is bounded above by the pred-chain point. Apply `doets_maximum` to get a maximum k with φ ∧ G(¬φ) at k. But succ(k) is the next limit_dom point, and G(¬φ) at k gives ¬φ at succ(k). If k is an orbit point, succ(k) is also an orbit point — but does φ hold at succ(k)? Not necessarily for arbitrary discriminating formulas.

   The refined approach: pick φ so that φ holds at ALL orbit points (or all sufficiently late ones). This can be done if the MCS labels eventually stabilize on the orbit. If they don't stabilize, use `Classical.choice` on the symmetric difference between consecutive orbit MCS labels to get finer and finer discriminating formulas, eventually reaching a formula that stabilizes. The finiteness of the formula closure (the MCS is over a finite set of sub-formulas of A) ensures this terminates.

**Tasks:**
- [ ] Remove old `z1_derivation`, replace with `z1_in_mcs` using axiom
- [ ] Prove `doets_maximum` helper
- [ ] Handle constant-MCS case in gap scenario
- [ ] Handle non-constant MCS case with discriminating formula + Doets
- [ ] Close sorry in `succ_cofinal`
- [ ] Verify `limitDomSubtype_isSuccArchimedean` is sorry-free
- [ ] `lake build` passes

**Timing**: 2-4 hours
**Depends on**: Phase 2

---

### Phase 4: Verification and Cleanup [NOT STARTED]

**Goal**: Verify compilation, sorry elimination, and clean up dead code.

**Tasks**:
- [ ] `lake build` passes (full project)
- [ ] `lean_verify` on `succ_cofinal` — no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` — no sorry
- [ ] `lean_verify` on `succ_embed_surjective` — no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` — no sorry
- [ ] Grep for sorry confirms only nondense/mixed stubs remain
- [ ] Remove dead code: old stage-induction attempts, convergence analysis comments
- [ ] Remove old `z1_derivation` sorry if still present
- [ ] Clean up gap analysis comments (keep concise documentation)

**Timing**: 0.5-1 hour
**Depends on**: Phase 3

## Testing & Validation

- [ ] `lake build` passes (full project)
- [ ] `lean_verify` on `succ_cofinal` — no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` — no sorry
- [ ] `lean_verify` on `succ_embed_surjective` — no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` — no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] No new axioms beyond Z1 (verify with `lean_verify --axioms`)

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/12_semantic-z1-gap.md` (this file, v15)
- **Modified files**:
  - `Theories/Bimodal/ProofSystem/Axioms.lean` — add Z1 constructor
  - `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — Z1 soundness proof
  - `Theories/Bimodal/Metalogic/Soundness.lean` — update pattern matches
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — Doets maximum principle, close sorry
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/12_semantic-z1-gap-summary.md`
- **Follow-up task**: Task 126 — split discrete/integer frame hierarchy

## Rollback/Contingency

Adding Z1 as an axiom is non-destructive — it only adds, never modifies existing axioms. Rollback: revert the Axiom constructor and all pattern match additions.

If the Doets maximum principle argument (Phase 3) proves intractable:
1. **Reynolds contemporaneous equivalence** (200-300 lines): adapt Reynolds 1994's argument using Prior-UZ/SZ to prove no gaps. Deferred to task 126 if needed.
2. **Leave sorry with Z1 infrastructure**: Z1 axiom + soundness is independently useful. Leave the sorry in `succ_cofinal` with Z1 available for future gap elimination attempts.

### Implementation Guidance for the Agent

**Phase 2 is mechanical**: adding an axiom constructor and updating pattern matches is systematic. Use `grep -rn "cases.*Axiom\|Axiom\." Theories/` to find all match sites. The Z1 soundness proof follows the same pattern as `prior_UZ_is_valid` — backward induction using `exists_succ_iterate` and `Nat.find`.

**Phase 3 is the creative work**: the Doets maximum principle helper is straightforward (~20 lines), but applying it in the gap scenario requires handling the constant-MCS vs non-constant MCS cases. The non-constant case needs a discriminating formula — use `Classical.choice` on the symmetric difference of two unequal MCS labels.

**Key codebase APIs** (verified available):
- `backward_G` (~line 1700): φ at all y > x → G(φ) at x
- `backward_F` (~line 1745): φ at y > x → F(φ) at x
- `limit_F_resolution`: F(φ) at x → ∃ y > x, φ at y
- `theorem_in_mcs`: derivable → in every MCS
- `SetMaximalConsistent.implication_property`: modus ponens in MCS
- `SetMaximalConsistent.negation_complete`: φ or ¬φ in MCS
- `set_consistent_not_both`: ¬(φ ∈ S ∧ ¬φ ∈ S)
- `prior_UZ_is_valid` (SoundnessLemmas.lean:2338): pattern for Z1 soundness proof

**No circularity**: Z1 soundness uses `[IsSuccArchimedean D]` on abstract frames. The limit model gets Z1 in every MCS because Z1 is an axiom (derivable from empty context). The Doets argument then uses Z1 semantically in the limit model to prove IsSuccArchimedean. Soundness is for the abstract frame class; completeness constructs a specific model and proves it belongs to the frame class.
