# Research Report: bx_le Non-Totality Gap and Path Forward

- **Task**: 98 — Research filtration or quasimodel pivot for Until/Since truth lemma
- **Started**: 2026-04-10T23:27:18Z
- **Completed**: 2026-04-10
- **Mode**: Team Research (4 teammates)
- **Language**: logic
- **Scope**: Round 2 research — investigate the bx_le non-totality gap blocking 6 sorry locations in Realization.lean

---

## Executive Summary

**The 6 sorry locations in Realization.lean are UNPROVABLE within the current `bx_le` framework.** This is not a missing lemma — it is a structural mismatch between the definition of `bx_le` and the requirements of the Until/Since truth lemma. All 4 teammates converge on the same conclusion with high confidence (85-95%).

**Key finding**: `bx_le := g_content ⊆` propagates only `G(χ)`-formulas. The guard-lifting steps need arbitrary formula `φ` to propagate along `bx_le`, which is impossible by definition. Even if `bx_le` were total, totality alone would not close the sorries — arbitrary formula propagation is the real requirement, and no BX axiom provides it.

**Recommended path**: Complete the existing quasimodel scaffolding in `Construction.lean` and `HintikkaPoint.lean`. The `hintikka_step` relation (Construction.lean:44) has Until persistence *built into its definition*, making the guard proof trivial at the Hintikka level. The sole remaining hard sub-problem is **combined seed consistency** for the realization lifting lemma.

---

## Synthesized Findings

### 1. bx_le Non-Totality Is Real but Is the Wrong Diagnosis

**All teammates agree**: `bx_le` is provably non-total (countermodel: two MCSes with incomparable g_content). BX11 (temp_linearity) constrains F-witnesses within one MCS but cannot force g_content inclusion between distinct MCSes.

**Critical reframing (from Teammate C)**: The gap is NOT "bx_le needs to be total" but "bx_le is the wrong ordering for Until/Since guards." Even with totality:
- `bx_le u' u` only propagates `G(χ)`-formulas from `u'` to `u`
- The guard needs `φ ∈ u` from `φ ∈ u'`, where `φ` is an arbitrary formula (not `G(χ)`)
- **Totality gives comparability but neither direction propagates non-G formulas**

This explains why two implementation agents testing 5+ strategies all failed — they were searching for auxiliary lemmas about `bx_le` when the definition itself is structurally incapable of supporting the guard.

### 2. Standard Literature Uses Different Orderings (Total by Construction)

**Teammate B and C independently confirm**: Burgess 1984, Reynolds 1996, and Verbrugge 2007 do NOT use `g_content ⊆` as the canonical ordering for Until/Since. They use:
- **Type-sequence ordering**: Total by construction (explicit linear chain built via Lindenbaum)
- **Quasimodel ordering**: `hintikka_step*` (transitive closure) with Until persistence built in
- **Omega-sequence construction**: Each thread is linearly ordered by construction

The `g_content ⊆` definition was a shortcut that works for G/H but was never designed for Until/Since completeness.

### 3. No Shortcut Axiom Exists

**Teammate B disproves the BX13 shortcut** suggested by Teammate C:
- The candidate `(φ U ψ) → G((φ U ψ) ∨ ψ)` is **semantically false** (countermodel: ψ holds at s=1 only; at t=2, neither `(φ U ψ)` nor `ψ` holds)
- Task 96 already confirmed all natural Until-propagation axiom candidates are unsound over general linear orders
- Direct Until propagation via BX4+BX5 is impossible

### 4. The Quasimodel Guard Is Trivial by Definition

**Key insight (from Teammates A and B)**: The `hintikka_step` relation (Construction.lean:44-51) includes a third clause:
```
∀ φ ψ, (φ U ψ) ∈ h1.formulas → ψ ∉ h1.formulas → φ ∈ h1.formulas ∧ (φ U ψ) ∈ h2.formulas
```

This means: if `hintikka_step h1 h2` and `(φ U ψ) ∈ h1` and `ψ ∉ h1`, then `φ ∈ h1` **directly from the definition**. No propagation along `bx_le`, no totality, no auxiliary lemma. The guard is encoded into the structure.

When `h1` is realized as BXPoint `w1` via `sigma_signature`, `φ ∈ h1.formulas` implies `φ ∈ w1.formulas` directly (from `sigma_signature_mem` in HintikkaPoint.lean:154).

### 5. The Sole Remaining Hard Problem: Combined Seed Consistency

**All teammates identify**: The realization lifting lemma requires showing that for consecutive Hintikka chain steps `h_{i-1} → h_i`, the enriched Lindenbaum seed `h_i.formulas ∪ g_content(v_{i-1}.formulas)` is consistent. This is the "combined seed consistency" sub-problem.

**Current status**: `enriched_seed_consistent_until` and `enriched_seed_consistent_since` in Realization.lean are sorry-free (proved in the previous implementation round). The remaining gap is using these seeds to produce BXPoints with the correct `bx_le` relationship AND the correct sigma_signature.

### 6. Five Alternative Approaches All Fail

| Approach | Viable? | Reason for Failure |
|----------|---------|-------------------|
| BX11 → bx_le totality | No | BX11 is formula-level F-witness linearity within one MCS, not BXPoint-level ordering |
| Proof restructuring (minimal witness) | No | Cannot select "gap-free" witness from existing axiom set |
| Empty-interval trick | No | Requires successor axiom; TM targets dense orders |
| Redefine bx_le with until_compatible | Partial | Transitivity fails in `ψ ∈ u` case; seed-consistency cascade |
| Direct Until propagation (BX4+BX5) | No | Target formula `(φ U ψ) → G((φ U ψ) ∨ ψ)` is semantically false |

---

## Conflicts Resolved

### Conflict 1: Is BX13 = `(φ U ψ) → G((φ U ψ) ∨ ψ)` worth checking?

- **Teammate C** (lower confidence, 50%): Suggested checking this axiom as a potential shortcut
- **Teammate B** (high confidence, 85%): Provided explicit countermodel disproving semantic validity
- **Resolution**: Teammate B's countermodel is conclusive. The axiom is unsound. Task 96 also confirmed all natural candidates are unsound. **Shortcut rejected.**

### Conflict 2: Should bx_le be redefined?

- **Teammate B** (medium confidence, 65%): `until_compatible` redefinition is "partially viable" with transitivity gap
- **Teammate D** (high confidence, 90%): bx_le should NOT be changed — cascades across 440 LOC
- **Resolution**: Even the partial viability requires solving the transitivity gap and auditing all seed-consistency lemmas. The quasimodel approach avoids all of this by working at a different level. **Keep bx_le unchanged; use quasimodel.**

---

## Gaps Identified

1. **Combined seed consistency proof strategy**: The exact proof technique for showing `h_i.formulas ∪ g_content(v_{i-1}.formulas)` is consistent needs detailed design. The enriched seed lemmas are sorry-free but the full realization chain construction is not yet assembled.

2. **Sigma_signature realizability**: The proof that a Lindenbaum extension of a Hintikka point produces a BXPoint whose sigma_signature equals the original Hintikka point needs careful handling of the Sigma-closure's enrichment (G/H formulas included for locus control).

3. **Since standalone construction**: Per Phase 0 Probe 6, Since is NOT a dual of Until and requires its own standalone proof using H-propagation and backward ordering. The budget must account for this.

---

## Recommendations

### Primary: Restructure Realization.lean to Use Quasimodel Chain

The current Realization.lean tries to prove Until/Since at the BXPoint level using `bx_le`. This is the wrong approach. Instead:

1. **Build the defect-discharge chain at the Hintikka level** using `hintikka_step` from Construction.lean
2. **Prove the guard at the Hintikka level** — trivial from `hintikka_step`'s third clause
3. **Realize the chain to BXPoints** via enriched Lindenbaum seeds (the lifting lemma)
4. **Transfer the guard from Hintikka to BXPoints** via `sigma_signature_mem`

This changes the proof architecture from:
```
BXPoint-level proof → needs bx_le propagation → BLOCKED
```
to:
```
Hintikka-level proof (guard trivial) → realize to BXPoints → transfer membership
```

### Secondary: Phase 4 Gate Check

The realization lifting lemma (combined seed consistency) is the go/no-go gate. If it fails within 8h of investigation, escalate to the global quasimodel fallback (40-60h).

### Non-Recommendation: Do Not Pursue

- Changing `bx_le` definition (cascade cost too high, transitivity gap unresolved)
- New axioms (all candidates unsound over general linear orders)
- Proof restructuring within current framework (5 strategies exhausted)

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary (BX11 analysis) | completed | high (95%) | Proved BX11 cannot make bx_le total; showed even totality wouldn't close sorries |
| B | Alternatives | completed | high (85%) | Disproved BX13 shortcut; confirmed hintikka_step has correct structure |
| C | Critic | completed | high (90%) | Reframed gap as "wrong definition" not "missing lemma"; confirmed standard lit uses different orderings |
| D | Horizons | completed | high (85-90%) | Strategic confirmation: task 98 is sole viable path; bx_le should not change |

---

## References

- Burgess 1984 §4: Quasimodel/Hintikka-set construction for Until/Since completeness
- Reynolds 1996: Explicit quasimodel realization for linear-time Until/Since
- Verbrugge 1992/2007: "Completeness by Construction" — direct Hintikka-chain technique
- Xu 1988: Simplified Burgess proof (origin of "BX" name)
- Goldblatt 1992: Standard reference; uses Hintikka for LTL/Until (not filtration)
- LIPIcs.ITP.2024.28: Coalition Logic filtration in Lean 4 (NOT applicable to TM-BX)
- specs/092.../reports/04_spawn-analysis.md: Root-cause analysis of g_content propagation obstruction
- specs/098.../reports/01_filtration-quasimodel-pivot.md: Round 1 research (CONDITIONAL GO)
