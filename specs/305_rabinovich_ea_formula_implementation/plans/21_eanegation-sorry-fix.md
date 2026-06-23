# Implementation Plan: EANegation Sorry Fix (Rabinovich-Aligned)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (Lemma 5.3, VecEATranslation, EANegationClosure all sorry-free)
- **Research Inputs**: reports/20_eanegation-sorry-analysis.md, reports/17_faithful-bridge-design.md
- **Artifacts**: plans/21_eanegation-sorry-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Fix the two sorry stubs in EANegation.lean and the two in PriorComposition.lean by introducing an `EndpointBracketFormula` type that matches Rabinovich's bracket notation exactly — placing α₀ at the left endpoint rather than at an interior witness. This resolves the structural mismatch identified in report 20 as the root cause of both S1 (Lemma 5.1 backward, beta_0(r_0) case) and S2 (Corollary 5.4 backward, missing first segment).

The mismatch: Lean's `BracketFormula (n+1)` existentially quantifies over ALL interior witnesses including the first, creating a universal quantifier in the negation that no V-bracket disjunct can capture for arbitrary α₀ points. Rabinovich's bracket places α₀ at the fixed endpoint z₀, eliminating this universal. The model-dependent forward-only version (EANegationClosure.lean, sorry-free) avoids the issue because it only needs to produce SOME V-bracket for a given model, not a FIXED V-bracket for ALL models.

This plan supersedes plan v19 (witness-count restructure) by directly resolving the EANegation sorry stubs rather than working around them.

### Research Integration

- **Report 20**: Root cause analysis of S1 (decomposition mismatch with Rabinovich pp.9-10) and S2 (fChainPred omits segmentTypes(0)). Fix order and dependency analysis. Downstream sorry chain traced.
- **Report 17**: Confirmed all VecEA infrastructure is sorry-free. Model-dependent forward-only path documented.

### H3 Reference Mapping Table

| Rabinovich 2014 | Section | Current Lean | Status | This Plan |
|---|---|---|---|---|
| Bracket `[α₀,β₁,...,αₙ](z₀,z₁)` | Section 2 | `BracketFormula` (interior witnesses) | mismatch | Phase 1: `EndpointBracket` |
| F-chain F₀ from endpoint | p.8 | `fChainPred` (from 1st witness) | missing 1st seg | Phase 1: endpoint F-chain |
| Lemma 5.3: ordered negation | p.8 | `neg_orderedPointsExist_is_vbracket` | sorry-free | reused |
| Corollary 5.4: ¬∃z bracket | p.9 | `neg_partialBracketExist_is_vbracket` | **sorry (S2)** | Phase 1+2 |
| Lemma 5.1: bracket negation | pp.9-10 | `neg_bracket_is_vbracket` | **sorry (S1)** | Phase 1+2 |
| Prop 4.2: VVecEA2 neg | Section 4 | `neg_2var_vec_ea` (model-dep) | sorry-free | Phase 3 (model-indep) |
| 2-var transfer | implicit | `prior_2var_transfer_until/since` | **sorry** | Phase 4 |

## Goals & Non-Goals

**Goals**:
- Define `EndpointBracketFormula` matching Rabinovich's `[α₀,β₁,...,αₙ](z₀,z₁)` with α₀ at endpoint z₀
- Prove Lemma 5.1 and Corollary 5.4 for `EndpointBracketFormula` following Rabinovich's proof step-by-step
- Bridge to `BracketFormula`, eliminating S1 and S2 sorry stubs
- Build model-independent VVecEA2 negation closure (Prop 4.2 biconditional)
- Eliminate `prior_2var_transfer_until/since` sorry stubs using the model-independent VecEA → temporal transfer chain
- Verify `completeness_discrete` compiles sorry-free

**Non-Goals**:
- Modifying existing sorry-free infrastructure (VecEAFormula, VecEAClosure, EANegationClosure, VecEATranslation, NfToVecEA)
- Restructuring the induction variable from NF depth to witness count (plan v19 — superseded)
- Fixing dead-code sorrys in PriorComposition.lean (lines 507, 555, 642, 647, 658)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `EndpointBracketFormula` to `BracketFormula` bridge is complex due to different witness counting (n endpoint vs n+1 interior) | M | M | The bridge is a single lemma: `BracketFormula (n+1).holds z₀ z₁ ↔ ∃x₀ ∈ (z₀,z₁), EndpointBracket n (with α₀ = pointTypes(0), endpoint at x₀).holds x₀ z₁ ∧ segTypes(0) on (z₀,x₀)`. This decomposition is already used implicitly in `h_bf_decomp` (EANegation.lean:861-881). |
| Lemma 5.1 for EndpointBracket case split on β₁ failure requires HasAttainedINF.first_occ, which may not work for segment types (interval conditions vs point conditions) | M | L | The first failure of β₁ is a POINT condition: ∃y with ¬β₁(y). HasAttainedINF.first_occ_tp finds the infimum. The interval condition "β₁ on (z₀,r₀)" follows from r₀ being the first failure. Already used in EANegationClosure.lean Case B2 (line 300-302). |
| Phase 3 model-independent Prop 4.2 is harder than the model-dependent version because VBracket must be fixed across all models | M | M | The model-dependent version (neg_2var_vec_ea, EANegationClosure:556) composes neg_interval_formula with VecEA closure. The model-independent version replaces neg_interval_formula with neg_bracket_is_vbracket (now fixed). The composition logic is identical — only the inner call changes from model-dependent to model-independent. |
| Phase 4 temporal transfer depth exceeds char_correct range | H | M | Plan v19 Phase 3 analysis (lines 186-229) established that zone-3 temporal formulas have depth ≤ K+1, within char_correct range. The first-occurrence minimality argument (lines 233-245) bounds transferred witnesses to the correct interval. |
| Phase 4 is substantially the same as plan v19 Phases 1-4 and may encounter the same blockers | H | L | The key difference: Phase 4 of THIS plan uses model-independent VVecEA2 negation (from Phase 3) instead of building ad-hoc zone-3 transfer machinery. The VecEA → temporal → char_correct chain is a clean, well-tested path. Plan v19 failed at the NF-to-VecEA bridge because it tried to work at depth 0; this plan works at arbitrary depth through the VecEA composition machinery. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: EndpointBracketFormula with Negation Theorems [NOT STARTED]

**Goal**: Define `EndpointBracketFormula` matching Rabinovich's bracket notation and prove Lemma 5.1 and Corollary 5.4 for this type, following the paper step-by-step. This is the mathematical core of the fix.

**Rabinovich Reference**: Sections 2, 5 (pp.4-5, 7-11). The bracket `[α₀,β₁,α₁,...,βₙ,αₙ](z₀,z₁)` places α₀ at endpoint z₀. Negation follows from case-splitting on first β₁ failure.

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointBracket.lean` (NEW)

**Tasks**:
- [ ] Define `EndpointBracketFormula (n : Nat)` with:
  - `endpointType : TemporalPred` — the type at the left endpoint (α₀ in Rabinovich)
  - `interiorTypes : Fin n → TemporalPred` — types at interior witnesses (α₁,...,αₙ)
  - `segmentTypes : Fin (n + 1) → TemporalPred` — segment types (β₁,...,βₙ₊₁)
- [ ] Define `EndpointBracketFormula.holds M atomMap z₀ z₁`:
  ```
  endpointType.eval_at M atomMap z₀ ∧
  ∃ w : Fin n → M.carrier,
    (∀ i j, i < j → w i < w j) ∧        -- strictly monotone
    (∀ i, z₀ < w i ∧ w i < z₁) ∧        -- in (z₀,z₁)
    (∀ i, (interiorTypes i).eval_at M atomMap (w i)) ∧   -- point types
    (∀ y, z₀ < y → y < w ⟨0,_⟩ → (segmentTypes ⟨0,_⟩).eval_at M atomMap y) ∧   -- first segment
    (∀ (j : Fin (n-1)) y, w j < y → y < w (j+1) → segmentTypes(j+1).eval_at M atomMap y) ∧   -- mid segments
    (∀ y, w ⟨n-1,_⟩ < y → y < z₁ → (segmentTypes ⟨n,_⟩).eval_at M atomMap y)   -- last segment
  ```
  Handle n=0 case separately: holds = endpointType(z₀) ∧ segmentTypes(0) on (z₀,z₁).
- [ ] Define `EndpointBracketFormula.tail`: drop endpointType and first segment, promote first interior type to endpoint:
  ```
  tail.endpointType = interiorTypes ⟨0, _⟩
  tail.interiorTypes i = interiorTypes ⟨i+1, _⟩
  tail.segmentTypes i = segmentTypes ⟨i+1, _⟩
  ```
- [ ] Prove `tail_satisfiable`: if endpointType(z₀) ∧ segmentTypes(0) on (z₀,r₀) ∧ tail.holds(r₀,z₁) then holds(z₀,z₁). (Mirrors `bracket_tail_satisfiable`.)
- [ ] Define `EndpointBracketFormula.fChainFrom` starting from the endpoint (including the first segment in F₀). This matches Rabinovich's F-chain exactly.
- [ ] Prove `endpoint_bracket_implies_fChain`: if holds(z₀,z₁), then ∃x₁ with segmentTypes(0) on (z₀,x₁) ∧ fChainPred(x₁). (The first segment is now captured.)
- [ ] Prove `neg_endpoint_bracket_is_vbracket` (Lemma 5.1 for EndpointBracket): by induction on n.
  - **Base (n=0)**: holds = endpointType(z₀) ∧ seg(0) on (z₀,z₁). Negation: ¬endpointType(z₀) ∨ ∃y ∈ (z₀,z₁) with ¬seg(0)(y). V-bracket: trivial when ¬endpointType(z₀); use neg_bracket_zero when seg(0) fails.
  - **Step (n+1)**: Case-split per Rabinovich pp.9-10:
    - Assume endpointType(z₀) holds (otherwise trivial V-bracket from ¬endpointType).
    - Find first β₁ failure: `HasAttainedINF.first_occ_tp segmentTypes(0).neg z₀ z₁`.
    - **Case B (seg(0) holds everywhere)**: Negation reduces to ¬∃x₁ ∈ (z₀,z₁) with interiorTypes(0)(x₁) ∧ tail.holds(x₁,z₁). Apply Cor 5.4 (proved below for EndpointBracket) to `tail`.
    - **Case C (seg(0) fails at first r₀)**: seg(0) on (z₀,r₀), ¬seg(0)(r₀). Any bracket witness x₁ with seg(0) on (z₀,x₁) must have x₁ ≤ r₀. Sub-split:
      - (i) ¬seg(0)(r₀): bracket witnesses restricted to (z₀,r₀). Use `inf_formula_is_vbracket` or construct the V-bracket directly using ¬seg(0) at r₀.
      - (ii) The tail bracket fails on (r₀,z₁): Apply IH to tail at n.
    - No beta_0(r_0) problem because α₀ is at the FIXED endpoint z₀, not existentially quantified.
- [ ] Prove `neg_partialEndpointExist_is_vbracket` (Corollary 5.4 for EndpointBracket): `¬∃z ∈ (z₀,z₁), eb.holds z₀ z` is a V-bracket.
  - Construction: the F-chain from the endpoint includes seg(0). Apply Lemma 5.3 (`neg_orderedPointsExist_is_vbracket`) to the endpoint F-chain.
  - Forward: V.holds → ¬orderedPointsExist fChain → ¬∃z, eb.holds z₀ z (via `endpoint_bracket_implies_fChain`)
  - Backward: ¬∃z, eb.holds z₀ z → ¬orderedPointsExist fChain → V.holds. The contrapositive (fChain → ∃z, eb.holds) works because the endpoint F-chain INCLUDES seg(0) on (z₀,x₁), so the fChain witnesses reconstruct a complete bracket.
  - **This is where the endpoint encoding resolves S2**: the fChain from the endpoint inherently captures the first segment, making the backward direction provable.

**Mutual induction structure**: Lemma 5.1 at step n+1 uses Cor 5.4 for size n (tail). Cor 5.4 at size n+1 uses Lemma 5.1 at size n+1. Implement as a combined `neg_endpoint_mutual n`:
```lean
theorem neg_endpoint_mutual (n : Nat) :
  (∀ eb : EndpointBracketFormula n, ∃ v : VBracketFormula, ∀ M atomMap h_INF z₀ z₁, z₀ < z₁ →
    (v.holds M atomMap z₀ z₁ ↔ ¬eb.holds M atomMap z₀ z₁)) ∧
  (∀ eb : EndpointBracketFormula n, ∃ v : VBracketFormula, ∀ M atomMap h_INF z₀ z₁, z₀ < z₁ →
    (v.holds M atomMap z₀ z₁ ↔ ¬∃ z, z₀ < z ∧ z < z₁ ∧ eb.holds M atomMap z₀ z))
```

**Timing**: 3 hours

**Depends on**: none

**Expected output**: ~350-450 lines

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EndpointBracket` succeeds
- `grep -n sorry EndpointBracket.lean` returns 0

---

### Phase 2: Bridge to BracketFormula, Fix S1 and S2 [NOT STARTED]

**Goal**: Prove the equivalence between `BracketFormula (n+1)` and an existential over `EndpointBracketFormula n`, then use this bridge to eliminate the S1 and S2 sorry stubs in EANegation.lean.

**Rabinovich Reference**: Implicit in the notation — Rabinovich's bracket with n+1 types has α₀ at the endpoint and n interior witnesses. Lean's BracketFormula with n+1 witnesses has all n+1 at interior positions. The bridge: `BracketFormula (n+1).holds z₀ z₁ ↔ ∃x₀ ∈ (z₀,z₁), eb_x₀.holds x₀ z₁ ∧ segTypes(0) on (z₀,x₀)`.

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` (MODIFY)

**Tasks**:
- [ ] Define the bridge function `BracketFormula.toEndpointAt (bf : BracketFormula (n+1)) (i : Fin (n+1))`: construct an `EndpointBracketFormula n` that captures the bracket with witness i as the "endpoint" and the remaining n witnesses as interior.
  For i = 0: `endpointType = bf.pointTypes(0)`, `interiorTypes(j) = bf.pointTypes(j+1)`, `segmentTypes(j) = bf.segmentTypes(j+1)`. The first segment bf.segmentTypes(0) is factored out.
- [ ] Prove `bracket_endpoint_bridge`: `BracketFormula (n+1).holds z₀ z₁ ↔ ∃x₀ ∈ (z₀,z₁), (bf.toEndpointAt 0).holds x₀ z₁ ∧ (∀ y, z₀ < y → y < x₀ → bf.segmentTypes(0).eval_at M atomMap y)`
  - Forward: extract first witness x₀ from bracket, construct EndpointBracket evaluation at x₀
  - Backward: from EndpointBracket at x₀ plus first segment, reconstruct full bracket
  - This is closely related to the existing `h_bf_decomp` at EANegation.lean:861-881.
- [ ] Fix S1 (`neg_bracket_is_vbracket`, succ case):
  Replace the sorry at line 1047 with:
  1. Express ¬bf.holds z₀ z₁ via the bridge: ¬∃x₀ ∈ (z₀,z₁), eb.holds x₀ z₁ ∧ seg(0) on (z₀,x₀)
  2. Case-split on seg(0) behavior in (z₀,z₁):
     - seg(0) fails at some point r₀: any bracket witness x₀ > r₀ has seg(0) on (z₀,x₀) failing. For x₀ ≤ r₀: use existing CaseC/CaseD logic (¬seg(0)(r₀) blocks witnesses past r₀).
     - seg(0) holds everywhere: ¬bf.holds = ¬∃x₀ with alpha_0(x₀) ∧ eb.holds(x₀,z₁). This is `¬partialEndpointExist` for EndpointBracket. Apply Phase 1's `neg_partialEndpointExist_is_vbracket`.
  3. Combine cases into a single VBracketFormula.
- [ ] Fix S2 (`neg_partialBracketExist_is_vbracket`, n+1 case):
  Replace the sorry at line 1172 with:
  1. `¬partialBracketExist bf z₀ z₁` = `∀z ∈ (z₀,z₁), ¬bf.holds z₀ z`
  2. By the fixed S1: `¬bf.holds z₀ z ↔ v_bf.holds z₀ z` for a FIXED v_bf
  3. So `¬partialBracketExist ↔ ∀z ∈ (z₀,z₁), v_bf.holds z₀ z`
  4. Express this universal as a V-bracket on (z₀,z₁): use `neg_partialEndpointExist_is_vbracket` applied to each disjunct of v_bf as an endpoint bracket with z as the right endpoint.
  5. Alternatively: use the bridge directly — `partialBracketExist bf z₀ z₁ ↔ partialEndpointExist (bf.toEndpointAt 0) z₀ z₁` (modulo the seg(0) condition), then apply Phase 1's Cor 5.4 result.
- [ ] Verify both sorry stubs are eliminated

**Timing**: 2.5 hours

**Depends on**: 1

**Expected output**: ~150-250 lines of changes to EANegation.lean

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegation` succeeds
- `grep -n sorry EANegation.lean` returns 0
- `lean_verify` on `neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket` reports no sorryAx

---

### Phase 3: Model-Independent VVecEA2 Negation (Prop 4.2) [NOT STARTED]

**Goal**: Build the model-independent biconditional VVecEA2 negation closure using the fixed `neg_bracket_is_vbracket` (S1). The model-dependent forward-only version exists in EANegationClosure.lean; this phase upgrades it to biconditional.

**Rabinovich Reference**: Proposition 4.2 (Section 4). "The class of V-EA₂ formulas is closed under negation."

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` (APPEND) or new section in same file

**Tasks**:
- [ ] Prove `neg_vbracket_is_vbracket`: for any VBracketFormula v, there exists v' such that `v'.holds ↔ ¬v.holds` on HasAttainedINF structures. This follows from:
  - v.holds = ∃ bf ∈ v.disjuncts, bf.holds
  - ¬v.holds = ∀ bf ∈ v.disjuncts, ¬bf.holds
  - By S1: ¬bf.holds ↔ v_bf.holds for each bf
  - ∀ bf, v_bf.holds = conjunction → expressible as V-bracket intersection
  - On HasAttainedINF: intersection of V-brackets is a V-bracket (via VecEAClosure's intersection lemma, if available, or construct directly)
- [ ] Prove `neg_vvecEA2_is_vvecEA2`: for any VVecEA2 v, there exists v' such that `v'.holds ↔ ¬v.holds`. Compose:
  - VVecEA2 = list of (VBracketFormula × VBracketFormula) pairs
  - v.holdsLeft = ∃ pair ∈ v.pairs, pair.fst.holds ∧ pair.snd.holds (on sub-intervals)
  - ¬v.holdsLeft = ∀ pair, ¬pair.fst.holds ∨ ¬pair.snd.holds
  - Use neg_vbracket_is_vbracket to handle each negation
  - Combine via VecEAClosure composition lemmas
- [ ] Verify model-independent Prop 4.2 signature matches the model-dependent version

**Timing**: 2 hours

**Depends on**: 2

**Expected output**: ~150-200 lines

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegation` succeeds
- `grep -n sorry EANegation.lean` returns 0
- `lean_verify` on `neg_vvecEA2_is_vvecEA2` reports no sorryAx

---

### Phase 4: Eliminate PriorComposition Sorry Stubs [NOT STARTED]

**Goal**: Replace the sorry at PriorComposition.lean:131 (`prior_2var_transfer_until`) and line 162 (`prior_2var_transfer_since`) with proofs using the model-independent VecEA2 → temporal formula transfer chain.

**Rabinovich Reference**: The transfer theorem is implicit in Rabinovich's proof — it follows from the expressive completeness of temporal logic over Prior structures. The VecEA2 negation closure (Prop 4.2) guarantees that every 2-var existential has a temporal characterization.

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (MODIFY), potentially with a helper file

**Proof Strategy**: The 2-var NF agreement `nf_eval_nf M (K+2) 2 (x,t) sub_nf ↔ nf_eval_nf M₀ (K+2) 2 (x₀,t₀) sub_nf` decomposes into atom agreement (existing, sorry-free) + quantifier condition agreement. Each quantifier condition is a depth-(K+1) 3-var existential. By zone decomposition:
- Zones 1,2,4,5 (w outside (t,x) or at endpoints): transfer via endpoint 1-var agreement (existing, sorry-free)
- Zone 3 (t < w < x): express via VecEA2 → temporal formula A of depth ≤ K+1 → transfer A via h_t at depth K+2 via char_correct at d ≤ K+1

The zone-3 transfer uses:
1. **NF → VecEA2**: existing `NfToVecEA.nf_depth0_existential_decomp` for depth 0; for depth K+1, use the inductive structure of ExistPart(K+1) at arity 1 (from CharPart)
2. **VecEA2 → temporal**: `VVecEA2.translateLeft/Right` (sorry-free)
3. **Temporal transfer**: `char_correct` at d ≤ K+1 + h_t at depth K+2
4. **HasAttainedINF first-occurrence**: bounds transferred witnesses to the correct interval

**Tasks**:
- [ ] Add import for EndpointBracket and the model-independent negation theorems
- [ ] Implement the zone-3 transfer for the Until case (`prior_2var_transfer_until`):
  - Decompose `sub_nf` into atom part + quantifier conditions
  - For each zone-3 quantifier condition chi:
    - Construct the temporal formula A via VecEA2 translation of chi
    - Transfer A from M₀ at t₀ to M at t using h_t and char_correct
    - Use first-occurrence minimality to bound the transferred witness to (t,x)
  - Assemble the full 2-var agreement
- [ ] Mirror for the Since case (`prior_2var_transfer_since`)
- [ ] Verify both sorry stubs are eliminated

**Timing**: 2.5 hours

**Depends on**: 3

**Expected output**: ~200-350 lines of proof in PriorComposition.lean + potentially ~100-150 lines in a helper file

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds
- `grep -n sorry PriorComposition.lean` shows only dead-code sorrys at lines 507, 555, 642, 647, 658
- `lean_verify` on `prior_2var_transfer_until` and `prior_2var_transfer_since` reports no sorryAx

---

### Phase 5: Integration Verification [NOT STARTED]

**Goal**: Verify that the sorry elimination propagates through the full call chain to `completeness_discrete`. Run full build and sorry audit.

**Tasks**:
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` — verify compiles
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` — verify compiles
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` — verify compiles
- [ ] `lean_verify` on `completeness_discrete` — confirm no sorryAx
- [ ] Full `lake build` — verify clean project build
- [ ] Sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` — catalog remaining sorrys. Expected: only dead-code sorrys in PriorComposition.lean (lines 507, 555, 642, 647, 658).
- [ ] Document sorry status in a brief summary

**Timing**: 1.5 hours

**Depends on**: 4

**Files to verify** (no modifications expected):
- All files in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`
- Full project via `lake build`

**Verification**:
- `lake build` succeeds with no errors
- `lean_verify` on `completeness_discrete` reports no sorryAx
- Only dead-code sorrys remain in the Kamp directory

## Testing & Validation

- [ ] Phase 1: `EndpointBracket.lean` compiles sorry-free
- [ ] Phase 1: `neg_endpoint_mutual` verified via `lean_verify`
- [ ] Phase 2: Both S1 and S2 sorry stubs eliminated in EANegation.lean
- [ ] Phase 2: `lean_verify` on `neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket` — no sorryAx
- [ ] Phase 3: `neg_vvecEA2_is_vvecEA2` compiles sorry-free
- [ ] Phase 4: `prior_2var_transfer_until` and `_since` compile sorry-free
- [ ] Phase 5: `completeness_discrete` — no sorryAx
- [ ] Phase 5: Full `lake build` succeeds

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/21_eanegation-sorry-fix.md` — this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointBracket.lean` (NEW, ~350-450 lines) — Rabinovich-faithful endpoint bracket with Lemma 5.1 + Cor 5.4
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` (MODIFIED, ~150-250 lines changed) — S1, S2 eliminated via bridge; Prop 4.2 biconditional added
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (MODIFIED, ~200-350 lines changed) — transfer sorry eliminated

## Postmortem Constraints (from v9-v19 and 20 research rounds)

1. **The beta_0(r_0) problem is structural, not tactical** — no amount of case-splitting within the current BracketFormula encoding can fix it. The V-bracket forward direction fails because multiple alpha_0 points create an unblockable universal. The EndpointBracketFormula eliminates this by fixing α₀ at the endpoint.
2. **Do NOT attempt Option A (modified fChainPred) for S2** — the backward direction fails because nested Until witnesses can escape past z₁, and the contrapositive (orderedPointsExist → partialBracketExist) is FALSE when witnesses are unbounded. Only the endpoint F-chain (which inherently includes the first segment) makes the contrapositive hold.
3. **The mutual induction between Lemma 5.1 and Cor 5.4 is essential** — Rabinovich's proof structure is mutually inductive (Lemma 5.1 at n+1 uses Cor 5.4 at n; Cor 5.4 at n+1 uses Lemma 5.1 at n+1). Implement as a combined induction in Phase 1.
4. **Do NOT modify existing sorry-free infrastructure** — VecEAFormula, VecEAClosure, EANegationClosure, VecEATranslation, NfToVecEA are all sorry-free and must remain untouched.
5. **Use HasAttainedINF first-occurrence minimality for interval bounding** — this is the key mechanism that makes the temporal transfer work in Phase 4 (same insight as plan v19).
6. **Work through VecEA2 → temporal formula for zone-3 transfer** — do not try direct NF-level transfer (17 research rounds confirm this is irreducible).
7. **Additive-only except at sorry sites** — create EndpointBracket.lean (new), modify EANegation.lean (fix sorry + add Prop 4.2), modify PriorComposition.lean (fix sorry + add import). No other modifications.

## Rollback/Contingency

- **Phase 1**: New file. Rollback = delete `EndpointBracket.lean`.
- **Phase 2**: Modifies EANegation.lean. Rollback = `git checkout -- EANegation.lean`.
- **Phase 3**: Extends EANegation.lean. Rollback = revert to Phase 2 state.
- **Phase 4**: Modifies PriorComposition.lean. Rollback = `git checkout -- PriorComposition.lean`.
- **Phase 5**: Verification only — no rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If EndpointBracketFormula approach is blocked**: Fall back to the model-dependent forward-only path (already sorry-free in EANegationClosure.lean) combined with plan v19's witness-count restructure for PriorComposition. This bypasses S1/S2 entirely but doesn't fix the biconditional theorems.
