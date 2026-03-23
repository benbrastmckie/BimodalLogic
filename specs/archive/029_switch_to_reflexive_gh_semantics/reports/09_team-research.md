# Research Report: Task #29 — CanonicalTask/Succ Plan Improvement Analysis

**Task**: 29 - switch_to_reflexive_gh_semantics
**Date**: 2026-03-22
**Mode**: Team Research (2 teammates)
**Session**: sess_1774214920_224ff5
**Focus**: Can Phase 5 plan be improved by reframing in terms of CanonicalTask/Succ instead of ExistsTask (CanonicalR)?

## Executive Summary

**Both teammates converge on the same conclusion**: Phase 5 is correctly framed at the ExistsTask level. Succ and CanonicalTask cannot shortcut the fresh G-atom approach. The plan v3 structure is sound; the real work is resolving 2 specific `sorry`s in the already-implemented `existsTask_strict_fresh_atom`.

**Critical finding**: A **derivation substitution lemma** is the key missing infrastructure. Without it, the "fresh atom" argument cannot close the seed consistency proof.

## Key Findings

### 1. Phase 5 Is Correctly at ExistsTask Level — NOT a Framing Error (HIGH confidence)

The quotient ordering `StagedPoint.le` is defined directly via `CanonicalR` (= ExistsTask):
```
[M] < [W] ↔ ExistsTask(M, W) ∧ ¬ExistsTask(W, M)
```

NoMaxOrder, NoMinOrder, and DenselyOrdered all operate on this quotient. CanonicalTask/Succ are step-indexed abstractions for the **discrete** track — inapplicable to the dense timeline quotient. The "CanonicalTask-centric paradigm shift" in plan v3 correctly means: CanonicalTask for Phase 6 (discrete seeds), ExistsTask for Phase 5 (quotient ordering).

### 2. Succ Does NOT Give Strictness (HIGH confidence)

| Question | Answer | Reason |
|----------|--------|--------|
| `Succ M W → ¬CanonicalR W M`? | **NO** | Succ adds F-step, not backward-exclusion |
| `CanonicalTask n≥1 → ¬CanonicalR backward`? | **NO** | CanonicalR W W holds by T-axiom regardless |
| Is fresh G-atom the only path? | **YES** | Per-witness construction is required |

Succ implies CanonicalR forward (proven: `Succ_implies_CanonicalR`) but says nothing about backward CanonicalR. Under reflexive semantics, `CanonicalR W W` holds for all W via T-axiom, so chain length alone cannot establish asymmetry.

### 3. Two `sorry`s Are the Real Blockers (HIGH confidence)

The fresh G-atom infrastructure is **already partially implemented** in `CanonicalIrreflexivity.lean`:

| Component | Status | Location |
|-----------|--------|----------|
| `canonicalR_reflexive` | PROVEN | Line 1206 |
| `canonicalR_past_reflexive` | PROVEN | Line 1218 |
| `existsTask_strict_fresh_atom` | 2 SORRIES | Line 1435 |
| `exists_strict_fresh_atom` | 2 SORRIES | Lines 1283, 1294 |
| `fresh_Gp_seed_consistent` | 1 SORRY | Line 1405 |

**Sorry 1-2** (`exists_strict_fresh_atom`): Finding atom q with `¬q ∈ M ∧ G(¬q) ∉ M`.

The argument: Choose q fresh for M (not appearing in any formula of M). Then:
- `q ∉ M` (freshness) → `¬q ∈ M` (MCS maximality)
- `G(¬q) ∉ M`: because q is fresh for M, no formula mentioning q exists in M, so `G(¬q)` cannot be derived from M's content. This requires a **substitution argument**: if q doesn't appear in the context, replacing q with any other atom preserves derivability.

**Sorry 3** (`fresh_Gp_seed_consistent` Case 1): When `G(q) ∈ L ⊆ g_content(M) ∪ {G(q)}` and `L ⊢ ⊥`.

The argument: Take `L' = L \ {G(q)} ⊆ g_content(M)`. Then `L' ⊢ G(q) → ⊥`. Since q is fresh for all formulas in L', by substitution, `L' ⊢ G(r) → ⊥` for any atom r. This means `G(r) ∉ M` for all atoms r. But `G(⊤) ∈ M` (from T-axiom on tautologies), giving a contradiction.

### 4. The Missing Infrastructure: Derivation Substitution Lemma (HIGH confidence)

Both teammates identify the same gap. The proof requires:
```lean
-- If atom q doesn't appear in any formula of Γ, then
-- Γ ⊢ φ implies Γ[r/q] ⊢ φ[r/q] for any atom r
lemma derivation_atom_substitution (Γ : Set Formula) (φ : Formula)
    (q r : Atom) (h_fresh : q ∉ atoms_of_set Γ)
    (h_deriv : Γ ⊢ φ) : (Γ.image (subst q r)) ⊢ (φ.subst q r)
```

This is standard proof theory but needs formalization for the bimodal Hilbert calculus. It is the KEY ingredient that makes "fresh atom" arguments work.

### 5. Call Site Design Tension (MEDIUM confidence)

The call sites currently use:
```lean
canonicalR_strict M N hM hN h_R : ¬CanonicalR N M
```
given an existing witness N from seriality/density. But `existsTask_strict_fresh_atom` gives an **existential** witness W (not the seriality witness).

**Resolution options**:
- **Option A** (plan v3 intent): Replace seriality witness entirely with fresh-atom witness. `existsTask_strict_fresh_atom` IS the new NoMaxOrder witness.
- **Option B**: Prove the conditional `CanonicalR M N → M ≠ N → ¬CanonicalR N M`. This requires universal antisymmetry-on-distinct-MCS, which may be FALSE under reflexive semantics.
- **Option C**: Each seriality construction already builds witnesses with inherent freshness properties; extract the fresh atom from the construction.

Option A is cleanest and matches the plan.

### 6. DenselyOrdered May Need Compound Seed (MEDIUM confidence)

Given `[M] < [N]`, constructing intermediate W requires:
- `ExistsTask(M, W)` and `ExistsTask(W, N)` — W must carry both M's and N's g_content
- Seed: `g_content(M) ∪ g_content(N) ∪ {G(q)}`
- Consistency harder to prove (two g_content sets plus fresh atom)

The plan budgets "May need two fresh atoms" — this is realistic.

## Synthesis

### No Conflicts Between Teammates

Both teammates independently confirm:
1. ExistsTask is the correct abstraction for Phase 5
2. Succ/CanonicalTask cannot shortcut the approach
3. The 2-3 sorries are the real work items
4. A substitution lemma is the key missing piece

### What "Overcome CanonicalR Inertia" Means Here

The user's guidance to focus on CanonicalTask/Succ is best interpreted as:
- **Phase 5**: ExistsTask IS the right level (not inertia, but correct engineering)
- **Phase 6**: Succ IS the right level (this is where CanonicalTask-centric thinking applies)
- **Post-completion**: New CanonicalTask theorems (`CanonicalTask_no_positive_cycle`, `Succ_step_changes_content`) strengthen the theory

### Recommended Plan Improvements

1. **Add Phase 5.0: Substitution Lemma** (NEW, 2-3h)
   - Formalize `derivation_atom_substitution` for the bimodal calculus
   - This unblocks both sorry sites in `exists_strict_fresh_atom` and `fresh_Gp_seed_consistent`

2. **Clarify Phase 5.2**: The existential `existsTask_strict_fresh_atom` IS the NoMaxOrder witness (not a separate theorem applied to a seriality witness)

3. **Phase 5.3 DenselyOrdered**: Budget for compound seed consistency proof (g_content(M) ∪ g_content(N) ∪ {G(q)})

4. **Phase 5.4**: Most call sites can use `existsTask_strict_fresh_atom` directly; the `canonicalR_strict` wrapper is deprecated

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Abstraction level analysis | completed | high | Phase 5 is correctly at ExistsTask level; 3 sorries are the work |
| B | Succ simplification | completed | high | Succ gives no strictness; substitution lemma is key missing piece |

## References

- `specs/029_switch_to_reflexive_gh_semantics/reports/09_teammate-a-findings.md` — Full abstraction analysis
- `specs/029_switch_to_reflexive_gh_semantics/reports/09_teammate-b-findings.md` — Succ/substitution analysis
- `specs/025_rename_canonicalr_to_existstask/reports/01_team-research.md` — Task 25 architecture audit
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — Partial implementation with sorries
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` — Call site patterns
