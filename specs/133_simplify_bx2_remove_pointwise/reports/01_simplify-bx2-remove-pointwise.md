# Research Report: Simplify BX2 — Remove Pointwise Conjunct, Derive from BX2G

- **Task**: 133 - Simplify BX2: remove pointwise conjunct, derive from BX2G
- **Started**: 2026-05-13T20:57:00Z
- **Completed**: 2026-05-13T21:10:00Z
- **Effort**: 4-6 hours (estimated implementation)
- **Dependencies**: Task 115 (established BX2G subsumes BX2 under open-guard semantics)
- **Sources/Inputs**:
  - `Theories/Bimodal/ProofSystem/Axioms.lean` (BX2/BX2G definitions, lines 128-154)
  - `Theories/Bimodal/Metalogic/Soundness.lean` (validity proofs, lines 493-533)
  - `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (swap-validity match arms)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (canonical model usage)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (canonical model usage)
  - `Theories/Bimodal/ProofSystem/Substitution.lean` (substitution match arms)
  - `specs/115_replace_a4a_with_left_mono_until_g/reports/03_team-research.md` (task 115 findings)
- **Artifacts**: `specs/133_simplify_bx2_remove_pointwise/reports/01_simplify-bx2-remove-pointwise.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- BX2/BX2' (`left_mono_until`/`left_mono_since`) are axiom constructors encoding `(φ→χ) ∧ G(φ→χ) → untl(φ,ψ) → untl(χ,ψ)`. Under open-guard semantics, the pointwise conjunct `(φ→χ)` is redundant since `t ∉ (t,s)`.
- BX2G/BX2H (`left_mono_until_G`/`left_mono_since_H`) already exist as axiom constructors encoding the stronger `G(φ→χ) → untl(φ,ψ) → untl(χ,ψ)` — the "G-only" form.
- Every call site that uses BX2 already derives `G(φ→χ)` (via temporal necessitation from a theorem), making the pointwise conjunct mechanically obtainable but unnecessary. BX2G suffices at every site.
- Removing BX2/BX2' eliminates 2 axiom constructors, 2 soundness proofs, 20 match arms across Soundness/SoundnessLemmas/Substitution, and simplifies the canonical model helper theorems.
- The change is a pure axiom minimality improvement — no new proofs needed, no output types change, no downstream callers affected.

## Context & Scope

The ProofChecker formalizes bimodal logic TM combining S5 modal logic with linear temporal logic. The axiom system includes BX2/BX2' (guard monotonicity with pointwise conjunct) and BX2G/BX2H (guard monotonicity under G/H). Task 115 research (Section 4.1 of team report) established that BX2G subsumes BX2 under the open-guard semantics `(t,s)` used throughout the codebase.

This task removes BX2/BX2' as axiom constructors and derives them as theorems from BX2G/BX2H, achieving axiom minimality without changing any proof's correctness.

## Findings

### 1. Axiom Definitions (Axioms.lean:128-154)

**BX2** (`left_mono_until`): `(φ→χ) ∧ G(φ→χ) → untl(ψ,φ) → untl(ψ,χ)`
**BX2G** (`left_mono_until_G`): `G(φ→χ) → untl(ψ,φ) → untl(ψ,χ)`

BX2G is strictly weaker in its hypothesis (no pointwise conjunct). BX2 is derivable from BX2G since `G(φ→χ)` alone entails `(φ→χ) ∧ G(φ→χ)` (the conjunction is redundant when G already covers all strict future points, and the guard range `(t,s)` is strict).

### 2. Canonical Model Usage — `untl_left_mono_thm` (RRelation.lean:1073-1085)

The primary canonical model helper `untl_left_mono_thm` takes `h_impl : DerivationTree [] (β₁.imp β₂)` (a provable theorem) and uses BX2. Its proof:
1. `theorem_in_mcs h_mcs h_impl` → `(β₁→β₂) ∈ A` (pointwise)
2. `theorem_in_mcs h_mcs (temporal_necessitation h_impl)` → `G(β₁→β₂) ∈ A`
3. Forms conjunction, applies BX2

**Simplification with BX2G**: Steps 1 and 3 become unnecessary. Only step 2 is needed, then apply BX2G directly. The proof shrinks from 7 lines to 3 lines, matching the existing `untl_left_mono_G` (RRelation.lean:1110-1119).

Mirror: `snce_left_mono_thm` (RRelation.lean:1091-1103) similarly simplifiable using BX2H.

### 3. Call Site Inventory

**`untl_left_mono_thm` call sites** (18 total across 2 files):
- RRelation.lean: 7 calls (lines 1177, 1190, 1444, 1490, and 3 in definition/comments)
- PointInsertion.lean: 11 calls (lines 670, 1573, 1666, 2210, 2540, 2547, 3215, 3599, 4012, and 2 more)

**`snce_left_mono_thm` call sites** (12 total):
- RRelation.lean: 2 calls
- PointInsertion.lean: 10 calls

All 30 call sites pass a `DerivationTree [] (β₁.imp β₂)` — a closed theorem. None pass a non-theorem hypothesis. This confirms BX2G suffices universally.

### 4. Direct BX2 Axiom Constructor Usage (8 sites)

Beyond `untl_left_mono_thm`/`snce_left_mono_thm`, BX2/BX2' axiom constructors are referenced directly:

| Location | Line | Context | Can Use BX2G? |
|----------|------|---------|---------------|
| RRelation.lean | 658 | `c4_hard_case_G_neg_delta` — already has `G(top→γ) ∈ A` | Yes |
| RRelation.lean | 697 | `c4'_hard_case_H_neg_delta` — already has `H(top→γ) ∈ A` | Yes |
| RRelation.lean | 1083 | `untl_left_mono_thm` definition (to be rewritten) | Yes |
| RRelation.lean | 1101 | `snce_left_mono_thm` definition (to be rewritten) | Yes |
| RRelation.lean | 1461 | Complex self-accum proof — already derives G form | Yes |
| PointInsertion.lean | 1343 | `untl_left_mono_deriv` — builds both pointwise and G | Yes |
| PointInsertion.lean | 1362 | `snce_left_mono_deriv` — builds both pointwise and H | Yes |
| Substitution.lean | 294, 297 | Match arms in `axiom_subst_closed` | Removed with constructor |

Every direct usage site already constructs or has available the `G(φ→χ)` form. The pointwise conjunct is always a byproduct of the same derivation that produces the G form.

### 5. Match Arms to Remove (22 arms across 3 files)

**Soundness.lean** (10 arms):
- `axiom_valid`: lines 921-922 (`left_mono_until_valid`, `left_mono_since_valid`)
- `axiom_valid_dense`: lines 972-973
- `axiom_valid_discrete`: lines 1024-1025
- `axiom_valid_at`: lines 1130-1131
- `axiom_valid_at` (second): lines 1306-1307

**SoundnessLemmas.lean** (8 arms across 4 functions):
- `axiom_swap_valid`: lines 543, 551
- `axiom_swap_valid` (second instance): lines 1146, 1154
- Two more functions: lines 1609, 1617, 1898, 1906

**Substitution.lean** (2 arms):
- `axiom_subst_closed`: lines 292-297

Plus the 2 validity proof theorems to remove:
- `left_mono_until_valid` (Soundness.lean:493-501)
- `left_mono_since_valid` (Soundness.lean:505-513)

### 6. Existing `untl_left_mono_G`/`snce_left_mono_H` Already Formalized

The BX2G-based helpers already exist (RRelation.lean:1110-1134):
- `untl_left_mono_G`: takes `(β₁.imp β₂).all_future ∈ A` (G hypothesis)
- `snce_left_mono_H`: takes `(β₁.imp β₂).all_past ∈ A` (H hypothesis)

These prove the same conclusion as `untl_left_mono_thm`/`snce_left_mono_thm` but via BX2G/BX2H. After removing BX2/BX2', the "thm" variants can be rewritten to internally use the "G"/"H" variants (or simply redirect to them after temporal necessitation).

### 7. Derivability of BX2 from BX2G (Theorem, not Axiom)

After removing the constructors, BX2 becomes a derived theorem:

```lean
theorem left_mono_until_derived (φ ψ χ : Formula) :
    DerivationTree [] (Formula.and (φ.imp χ) (φ.imp χ).all_future |>.imp
      ((Formula.untl ψ φ).imp (Formula.untl ψ χ))) := by
  -- From (φ→χ) ∧ G(φ→χ), extract G(φ→χ)
  -- Apply BX2G: G(φ→χ) → untl(ψ,φ) → untl(ψ,χ)
  -- Chain implications
```

This theorem preserves backward compatibility: any existing code that relied on BX2 as a theorem (not as a pattern match on the constructor) continues to work via the derived version.

## Decisions

- **Remove `left_mono_until` and `left_mono_since` constructors** from the `Axiom` inductive type
- **Derive BX2/BX2' as theorems** from BX2G/BX2H for backward compatibility
- **Rewrite `untl_left_mono_thm`/`snce_left_mono_thm`** to use BX2G/BX2H internally (simpler proofs)
- **Rewrite `c4_hard_case_G_neg_delta`/`c4'_hard_case_H_neg_delta`** to use BX2G/BX2H directly
- **Rewrite `untl_left_mono_deriv`/`snce_left_mono_deriv`** to use BX2G/BX2H
- **Remove 22 match arms** across Soundness.lean, SoundnessLemmas.lean, Substitution.lean
- **Remove 2 validity proofs** (`left_mono_until_valid`, `left_mono_since_valid`)

## Recommendations

### Phase 1: Rewrite Internal Helpers (~1 hour)
1. Rewrite `untl_left_mono_thm` to use BX2G: derive `G(β₁→β₂) ∈ A` via temporal necessitation + `theorem_in_mcs`, then apply `untl_left_mono_G` (or inline BX2G directly)
2. Rewrite `snce_left_mono_thm` analogously using BX2H
3. Rewrite `c4_hard_case_G_neg_delta` (line 658) to use `Axiom.left_mono_until_G` instead of `Axiom.left_mono_until` — already has `G(top→γ) ∈ A`
4. Rewrite `c4'_hard_case_H_neg_delta` (line 697) analogously
5. Rewrite `untl_left_mono_deriv` / `snce_left_mono_deriv` (PointInsertion.lean:1335-1363) to use BX2G/BX2H
6. Rewrite the complex BX2 usage in the self-accum proof (RRelation.lean:1461)
7. Verify `lake build` passes

### Phase 2: Remove Constructors and Match Arms (~2 hours)
1. Remove `left_mono_until` and `left_mono_since` from `Axiom` inductive (Axioms.lean:128-140)
2. Remove `left_mono_until_valid` and `left_mono_since_valid` (Soundness.lean:493-513)
3. Remove 10 match arms in Soundness.lean
4. Remove 8 match arms in SoundnessLemmas.lean
5. Remove 2 match arms in Substitution.lean
6. Optionally add derived theorems for backward compat
7. Verify `lake build` passes

### Phase 3: Cleanup and Verification (~1 hour)
1. Update docstrings referencing "BX2" to note it's now derived from BX2G
2. Update comments in `untl_left_mono_thm` and related functions
3. Run full `lake build` to ensure no broken references
4. Verify soundness and completeness proofs still compile

## Risks & Mitigations

- **Risk**: Some match arm removal may cause non-exhaustive pattern errors if Lean doesn't recognize the constructor is gone. **Mitigation**: Remove constructor first, then let compiler errors guide which match arms need updating.
- **Risk**: The `isDenseCompatible` check on axioms might reference BX2/BX2'. **Mitigation**: Check `Axiom.isDenseCompatible` definition and update if needed.
- **Risk**: Tests may reference BX2 constructor directly. **Mitigation**: Check `Tests/BimodalTest/` for references.

## Appendix

### Full File Impact Summary

| File | Changes | Lines Affected |
|------|---------|----------------|
| Axioms.lean | Remove 2 constructors | ~14 lines removed |
| Soundness.lean | Remove 2 proofs + 10 match arms | ~30 lines removed |
| SoundnessLemmas.lean | Remove 8 match arms | ~40 lines removed |
| Substitution.lean | Remove 2 match arms | ~6 lines removed |
| RRelation.lean | Rewrite 4 functions | ~20 lines simplified |
| PointInsertion.lean | Rewrite 2 functions | ~15 lines simplified |
| **Total** | Net deletion ~100 lines | 6 files modified |

### BX2 vs BX2G Semantic Comparison

```
BX2:  (φ→χ) ∧ G(φ→χ) → untl(ψ,φ) → untl(ψ,χ)
BX2G: G(φ→χ)          → untl(ψ,φ) → untl(ψ,χ)

Semantics (open guard (t,s)):
- untl(ψ,φ) = ∃s>t. ψ(s) ∧ ∀r∈(t,s). φ(r)
- G(φ→χ) covers all r>t, which includes (t,s)
- (φ→χ) at t is irrelevant since t ∉ (t,s)
- Therefore BX2G ⊨ BX2 (BX2 has a redundant conjunct)
```
