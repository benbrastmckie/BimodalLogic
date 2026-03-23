# Research Report: Task #29 - CanonicalTask-Centric Blocker Resolution

**Task**: 29 - switch_to_reflexive_gh_semantics
**Date**: 2026-03-22
**Mode**: Team Research (2 teammates, math domain focus)
**Focus**: Shift from CanonicalR to CanonicalTask perspective for Phase 5-6 blockers

## Executive Summary

The Phase 5 blocker was misframed. The question "is `canonicalR_antisymmetric` provable?" is the wrong question in Task Semantics. CanonicalR (better named ExistsTask) is a derived notion — the existential projection of the three-place CanonicalTask relation. The correct approach is **local distinctness witnesses via fresh G-atoms**, which both teammates independently confirm as the path forward. CanonicalTask provides the conceptual scaffolding; the fresh atom lemma provides the concrete mechanism.

## Key Findings

### 1. CanonicalR is Derived, CanonicalTask is Primary (HIGH confidence)

| Concept | Definition | Role |
|---------|-----------|------|
| **CanonicalTask(u, n, v)** | Ternary: `MCS → ℤ → MCS → Prop` (Succ-chains of length n) | Primary — directly instantiates TaskFrame |
| **CanonicalR(u, v)** (ExistsTask) | Binary: `g_content(u) ⊆ v` | Derived — `∃ n ≥ 1, CanonicalTask(u, n, v)` |
| **Succ(u, v)** | `g_content(u) ⊆ v ∧ f_content(u) ⊆ v ∪ f_content(v)` | Atomic unit of CanonicalTask |

CanonicalR is duration-blind. CanonicalTask is duration-precise. The F-step condition in Succ tracks existential obligations that CanonicalR ignores entirely.

### 2. Reflexivity is Definitional and Harmless in CanonicalTask (HIGH confidence)

| Framework | Reflexivity | Strictness | Problem? |
|-----------|------------|------------|----------|
| CanonicalR | `CanonicalR M M` is TRUE (T-axiom) | Breaks irreflexivity axiom | YES — inconsistency |
| CanonicalTask | `CanonicalTask(M, 0, M)` = `M = M` | Duration n > 0 carries strictness | NO — by design |

The entire reflexivity/irreflexivity/antisymmetry debate dissolves in the CanonicalTask framework. Reflexivity at zero is the identity; strict ordering is captured by positive duration.

### 3. The Correct Question: Per-Witness Distinctness (HIGH confidence)

The Phase 5 blocker was: "prove `canonicalR_antisymmetric`" (universally, for all MCSes).

The correct question is: **For each seriality/density witness W constructed from source M, prove `¬CanonicalR(W, M)`** (locally, for the specific W).

This is a fundamentally different and much more tractable question. It does not require universal antisymmetry (which is false). It requires showing that one specific formula in `g_content(W)` is not in M.

### 4. The Fresh G-Atom Mechanism (HIGH confidence)

Both teammates converge on **Option D from report 07** as the concrete mechanism:

```
1. Choose atom p fresh for M (p ∉ atoms(M))
2. Construct seed: g_content(M) ∪ {G(p)}
3. Prove seed is consistent (fresh atom argument)
4. Extend to MCS W via Lindenbaum
5. CanonicalR(M, W): g_content(M) ⊆ W ✓ (from seed)
6. G(p) ∈ W (from seed), so p ∈ g_content(W)
7. p ∉ M (freshness), so g_content(W) ⊄ M
8. Therefore ¬CanonicalR(W, M) — strict ordering
```

In CanonicalTask terms: this gives `CanonicalTask(M, 1, W)` (W is a Succ-successor carrying G(p)) and `¬∃ n ≥ 1, CanonicalTask(W, n, M)` (because p propagates through g_content at every Succ step but never reaches M).

### 5. F-Step Distinctness (Succ-Chain Perspective) (MEDIUM confidence)

The Succ relation's F-step condition (`f_content(u) ⊆ v ∪ f_content(v)`) provides an additional distinctness mechanism beyond the fresh atom approach:

- **Single-Step Forcing**: If `F(φ) ∈ u` and `FF(φ) ∉ u`, every Succ-successor v has `φ ∈ v`
- **Bounded Witness**: If `Fⁿ(φ) ∈ u` but `Fⁿ⁺¹(φ) ∉ u`, φ is reached within n steps

This provides intrinsic distinctness: adjacent Succ-chain positions have different F-obligation content. However, making this concrete requires defining `f_content` and `Succ` in Lean, which is straightforward but additional infrastructure.

## Synthesis

### Conflicts: None

Both teammates independently converge on the same conclusion:
1. CanonicalR antisymmetry is the wrong question
2. Fresh G-atom (Option D) is the correct mechanism
3. CanonicalTask provides better conceptual framing
4. The concrete proof work is the same regardless of framing

### Key Clarification

Teammate A emphasizes that CanonicalTask sidesteps the entire reflexivity debate. Teammate B clarifies that while CanonicalTask doesn't eliminate the work, it correctly reframes the problem from "universal relation property" to "local witness construction."

### Gaps Identified

1. **Fresh atom consistency proof** (`fresh_atom_Gp_seed_consistent`): Not yet mechanically verified. The mathematical argument is standard but the Lean formalization requires checking what infrastructure exists for fresh atom arguments.

2. **f_content definition**: Not yet defined in the codebase. Needed for Succ, which in turn enables the F-step distinctness path. However, this is NOT required for the fresh G-atom approach (which works purely through g_content).

3. **NoMinOrder**: The fresh G-atom gives a strict successor (for NoMaxOrder). For NoMinOrder (strict predecessor), an analogous `H(p)` approach is needed: `h_content(M) ∪ {H(p)}` with fresh p, giving a predecessor W where `H(p) ∈ W`, `p ∈ h_content(W)`, `p ∉ M`.

4. **DenselyOrdered**: Requires intermediate witness between two ordered MCSes. The fresh atom approach needs adaptation for this case.

## Recommended Implementation Path

### Phase 5 Revised (8-12 hours total)

**Step 1: Fresh Atom Infrastructure (2-3h)**
- Prove `fresh_atom_Gp_seed_consistent`: `g_content(M) ∪ {G(p)}` is consistent for fresh p
- Prove `fresh_atom_Hp_seed_consistent`: `h_content(M) ∪ {H(p)}` is consistent for fresh p
- Key proof idea: fresh atom p is not mentioned in any formula in g_content(M), so G(p) adds no constraints derivable from g_content(M)

**Step 2: Strict Witness Theorems (1-2h)**
- `canonicalR_strict_successor`: ∃ W, CanonicalR M W ∧ ¬CanonicalR W M (using fresh G-atom)
- `canonicalR_strict_predecessor`: ∃ W, CanonicalR W M ∧ ¬CanonicalR M W (using fresh H-atom)
- These replace `canonicalR_strict` (which depended on the false irreflexivity axiom)

**Step 3: Update CantorApplication.lean (3-4h)**
- Replace NoMaxOrder proof: use `canonicalR_strict_successor` instead of `canonicalR_strict`
- Replace NoMinOrder proof: use `canonicalR_strict_predecessor`
- Replace DenselyOrdered proof: construct intermediate witness with fresh atom

**Step 4: Update Remaining Call Sites (3-4h)**
- Fix ~20 remaining call sites across 10 files
- Pattern: replace `canonicalR_irreflexive M h_mcs h_R` with fresh-atom-based `¬CanonicalR` proof
- `inl` cases (MCS equality) need per-construction distinctness arguments

**Step 5: Remove Axiom (30min)**
- Delete `canonicalR_irreflexive_axiom`
- Verify `lake build` passes

### Phase 6 (Independent, 2-3h)
- `discreteImmediateSuccSeed_consistent_axiom`: provable using T-axiom simplification of Case 2
- Independent of Phase 5 — can be attempted in parallel

## Conceptual Shift Summary

| Prior Framing | Corrected Framing |
|---------------|-------------------|
| "Prove canonicalR_antisymmetric" | "Prove per-witness ¬CanonicalR(W, M)" |
| CanonicalR is the primary object | CanonicalTask is primary; CanonicalR is derived |
| Universal relation property needed | Local witness construction needed |
| Gabbay naming set adaptation | Fresh G-atom seed construction |
| Antisymmetry theorem (FALSE) | Strict successor/predecessor existence (TRUE) |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | CanonicalTask theory from reports 17-20 | completed | high | Full CanonicalTask vs CanonicalR comparison table; CanonicalTask sidesteps reflexivity debate |
| B | Blocker re-analysis via CanonicalTask | completed | high | Confirmed fresh G-atom as correct path; 5-step implementation plan with effort estimates |

## References

- `specs/006_canonical_taskframe_completeness/reports/17_three-place-canonical-task-relation.md` — CanonicalTask definition, Succ, Single-Step Forcing
- `specs/006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md` — Dense variant
- `specs/006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md` — Representation theorem role
- `specs/006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md` — Succ bypass
- `specs/029_switch_to_reflexive_gh_semantics/reports/07_team-research.md` — Prior blocker analysis (Option D origin)
- `specs/029_switch_to_reflexive_gh_semantics/reports/08_teammate-a-findings.md` — Full Teammate A analysis
- `specs/029_switch_to_reflexive_gh_semantics/reports/08_teammate-b-findings.md` — Full Teammate B analysis
