# Research Report: Task #107

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-29
**Session**: sess_1777507213_35f648
**Mode**: Team Research (4 teammates)
**Type**: lean4

## Summary

Team research identifies two critical findings that reshape the remaining work: (1) The codebase's BX7 axiom has **different disjuncts** from Burgess's A7a — this is the fundamental reason Burgess's Lemma 2.7 proof doesn't translate directly; (2) The Zorn sorry is fixable by reverting `BurgessR3Maximal`'s maximality clause from `ClosedUnderDerivation` back to `SetDeductivelyClosed` — this eliminates the sorry at RRelation.lean:772 without density axioms. The C4 sorry sites (lines 412, 510) need `c2'` + `lemma_2_6_splitting`, NOT `lemma_2_7`. Lemma 2.7 is needed only for C5 n>0 sub-case 3, which may not yet have a sorry site.

## Key Findings

### 1. BX7 ≠ Burgess A7a — Root Cause of Lemma 2.7 Difficulty (A)

**CRITICAL DISCOVERY**: The codebase axiom `Axiom.linear_until` (BX7) has a different form from Burgess's A7a:

| Axiom | Disjunct 1 | Disjunct 2 | Disjunct 3 |
|-------|-----------|-----------|-----------|
| **Burgess A7a** | U(p∧r, **q∧s**) | U(**p∧s**, **q∧s**) | U(**q∧r**, **q∧s**) |
| **Codebase BX7** | U(p∧r, **q∧s**) | U(**p∧r**, **q∧r**) | U(**p∧r**, **p∧s**) |

Burgess A7a has **varying guards, fixed event** (always q∧s). Codebase BX7 has **fixed guard** (always p∧r), **varying events**.

**Why this matters**: Burgess's Lemma 2.7 proof rules out D1 and D2 using `¬U(γ₀, β₀∧η) ∈ A`. In Burgess's A7a, both D1 and D2 have event `β₀∧η`, so the ruling-out works. In codebase BX7, D2 has event `β₀∧(ξ∧U(ξ,η))` which does NOT imply `β₀∧η` (because `U(ξ,η) ↛ η`). So D2 cannot be ruled out using the codebase BX7.

**Resolution options**:
- **Option 1**: Derive Burgess A7a form as a lemma from codebase axioms (BX7 + BX1/BX2). ~20-30 lines. If successful, Burgess's proof works verbatim.
- **Option 2**: Use Xu's Lemma 2.4 which avoids the A7a application entirely (see Finding 3).
- **Option 3**: Adapt the proof to work with codebase BX7's D3 disjunct (guard p∧r, event p∧s = φ₁∧η), extracting `U(ξ, η) ∈ A` (but this is just the hypothesis back — circular).

### 2. Zorn Sorry Is Fixable: Revert to DCS Maximality (B, C)

**The Zorn sorry (RRelation.lean:772) disappears if `BurgessR3Maximal` uses `SetDeductivelyClosed` instead of `ClosedUnderDerivation` in the maximality clause.**

Current definition:
```lean
∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C
```

Proposed fix:
```lean
∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

**Why this works**: `SetDeductivelyClosed D` requires `SetConsistent D`. In the Zorn construction, the inconsistent case (`¬SetConsistent D`) never arises because D must be a DCS. The sorry at line 772 (proving `¬burgessR3(A, Set.univ, C)` for inconsistent Set.univ) disappears entirely.

**Impact on `g_content_sub_B_of_BurgessR3Maximal`**: The inconsistent extension case (Phase 5b-ii, lines 835-839) used `Set.univ` as the ClosedUnderDerivation witness. With DCS maximality, this proof path breaks. **However**, Teammate C identifies an alternative: when `{φ} ∪ B` is inconsistent, `φ.neg ∈ B` (by DCS closure). Then `G(φ) ∈ A` gives `¬F(φ.neg) ∈ A`, but `burgessR3(A, B, C)` with `φ.neg ∈ B` and `⊤ ∈ C` gives `U(⊤, φ.neg) ∈ A`, hence `F(φ.neg) ∈ A` — contradiction in MCS A. **No density axioms needed.**

**This matches Burgess's original definition** (B confirms from paper text). The `ClosedUnderDerivation` maximality was introduced in Phase 5b-i as a workaround; reverting aligns with Burgess.

### 3. Xu's Lemma 2.4 Avoids BX7/A7a Entirely (B, D)

Xu's Lemma 2.4 provides a simpler splitting that works with the codebase's existing infrastructure:

> Given `r(A, B, C)`, `¬U(γ, β) ∈ A` and `γ ∈ C`: produce D with `B ∪ {¬β} ⊆ D`, `R(A, B', D)`, `R(D, B'', C)`.

The proof uses only:
- Extend B to B* (maximal DCS with r(A, B*, C))
- Show β ∉ B* (from ¬U(γ,β) ∈ A and γ ∈ C)
- B* ∪ {¬β} is consistent → Lindenbaum → D
- Xu's Lemma 2.3 gives r(A, ⊤, D) and r(D, ⊤, C)

**No BX7/A7a application needed.** This bypasses the BX7≠A7a discrepancy entirely.

### 4. C4 Sorry Sites Need c2' + lemma_2_6, NOT lemma_2_7 (C, D)

**Critical clarification**: The 2 remaining sorry sites in CounterexampleElimination.lean (lines 412, 510) are C4/C4' cases. They need:
1. `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))` for an adjacent pair — this is `c2'`
2. `lemma_2_6_splitting` applied to that BurgessR3Maximal to get the splitting point

These do NOT need `lemma_2_7`. Lemma 2.7 is needed for C5 n>0 sub-case 3 (Burgess Lemma 2.10), but that code path may not yet have a sorry site if C5 elimination was implemented with only the easy cases.

**Implication**: The C4 sorry sites can potentially be closed by restoring c2' as an omega_chain invariant (reversing part of Phase 7) OR by proving c2' at each finite stage via a different mechanism.

### 5. Missing Lean Infrastructure (D)

| Helper | Status | Purpose |
|--------|--------|---------|
| `forward_temporal_witness_seed_consistent` | EXISTS | Seed consistency from `F(target) ∈ A` |
| `self_accum_until_mcs` | EXISTS | BX5 at MCS level |
| `right_mono_until_mcs` | EXISTS | BX2 at MCS level |
| `conj_mcs` / `conj_left_mcs` | EXISTS | Conjunction intro/elim at MCS level |
| `burgessR3Maximal_from_g_content_sub` | EXISTS | BurgessR3Maximal from g_content inclusion |
| `linear_until_mcs` | MISSING | BX7 at MCS level (3-way disjunction) |
| `burgessA7a_from_BX7` | MISSING | Derive Burgess A7a form from codebase BX7 |
| Connection: `U(xi,β∧η)∈A` for β∈B → `η∈B'` | MISSING | Maximality argument for eta inclusion |

### 6. Lemma 2.7 Type Signature Is Correct But Incomplete (C, D)

The current `lemma_2_7` signature correctly produces `ξ ∈ D` and `η ∈ B'` and both `BurgessR3Maximal` pairs. It is missing `B = B' ∩ D ∩ B''` (Lemma 2.5 decomposition), which will be needed when connecting to `eliminate_C5_counterexample`. This is a minor addition.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Can Burgess A7a be derived from BX7? | UNCLEAR — A says it may require ~20-30 lines; B and D suggest Xu's approach avoids the need entirely |
| Are C4 sorry sites related to Lemma 2.7? | NO — C and D independently confirm C4 needs `c2'` + `lemma_2_6`, not `lemma_2_7` |
| Is the Zorn sorry fixable? | YES — B and C agree: revert to DCS maximality. The g_content_sub_B inconsistent case has an alternative proof via `G(φ)∈A` → `¬F(φ.neg)∈A` contradiction. |

### Recommended Action Plan

**Priority 1: Fix BurgessR3Maximal definition (closes Zorn sorry)**
- Revert maximality clause from `ClosedUnderDerivation` to `SetDeductivelyClosed`
- Fix `g_content_sub_B_of_BurgessR3Maximal` inconsistent case with G(φ)/F(φ.neg) contradiction
- Fix `h_content_sub_B_of_BurgessR3Maximal` dual
- This closes RRelation.lean:772 and removes a load-bearing sorry from the entire construction

**Priority 2: Close C4 sorry sites (lines 412, 510)**
- These need `c2'` for the adjacent pair. Two sub-options:
  - (a) Restore c2' as omega_chain invariant for the specific pairs needed
  - (b) Prove c2' for the newly-inserted adjacent pairs using `lemma_2_6_splitting` + the extended return type
- Use `lemma_2_6_splitting` (already sorry-free and extended) to produce the splitting

**Priority 3: Lemma 2.7 (for C5 n>0, non-blocking)**
- Either derive Burgess A7a from BX7 (Option 1) or use Xu's Lemma 2.4 (Option 2)
- Not on the critical path for the C4 sorry sites
- Needed eventually for full C5 elimination

**Priority 4: FUC/FSC coherence (Phase 10)**
- Depends on all sorry sites in the construction being closed
- ChronicleToCountermodel.lean:615, 619

### Gaps Identified

1. Whether Burgess A7a is derivable from codebase BX7 — needs a proof attempt or countermodel
2. Whether c2' can be restored for specific adjacent pairs without re-introducing the Phase 7 architectural issues
3. The exact sorry chain from C5 elimination to `dd_countermodel_chronicle` — is Lemma 2.7 actually invoked?

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | High | BX7≠A7a discovery; exact Burgess proof reconstruction |
| B | Alternatives | completed | High | Zorn fix via DCS revert; Xu avoids A7a; C4≠C5 clarification |
| C | Critic | completed | High | Handoff blockers partially flawed; G(φ)/F(φ.neg) proof for g_content_sub |
| D | Horizons | completed | High | Infrastructure inventory; forward_temporal_witness_seed exists; linear_until_mcs missing |

## References

- Burgess 1982: Lemma 2.6 (p. 370), Lemma 2.7 (p. 371-372), A7a definition
- Xu 1988: Lemma 2.4, Lemma 2.3
- PointInsertion.lean: lemma_2_7 (line 1037), lemma_2_6_splitting (line 913)
- RRelation.lean: burgessR3Maximal_extension_exists (line 760), Zorn sorry (line 772)
- Axioms.lean: linear_until/BX7 (line 226)
- CounterexampleElimination.lean: C4 sorry sites (lines 412, 510)
