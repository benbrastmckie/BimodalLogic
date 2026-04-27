# Research Report: Task #113 (Round 2)

**Task**: Until/Since guard semantics — open vs. half-closed, Next/Previous definability
**Date**: 2026-04-27
**Mode**: Direct analysis (lead researcher)
**Session**: sess_1777310907_cf5ce7

## Summary

The Lean codebase uses **half-closed guard** semantics for Until/Since (`[t, s)` and `(s, t]`), while the paper (possible_worlds.tex lines 1182-1189), Burgess 1982, Xu 1988, Reynolds 1992, Venema 1993, and the entire standard temporal logic literature use **open guard** semantics (`(t, s)` and `(s, t)`). This discrepancy makes Next/Previous (defined as ⊥ U φ / ⊥ S φ) always false under the code's semantics, contradicting the paper's claim at line 1189 that these definitions work. Switching to open guard requires removing 4 axioms and reworking ~175 file references across ~15 files.

## Key Findings

### 1. The Semantics Are Different (CONFIRMED)

**Paper** (possible_worlds.tex:1182-1187):
```
(U) M,τ,x ⊨ φ U ψ iff M,τ,z ⊨ ψ for some z > x where M,τ,y ⊨ φ
    for all intermediate y ∈ D where x < y < z
(S) M,τ,x ⊨ φ S ψ iff M,τ,z ⊨ ψ for some z < x where M,τ,y ⊨ φ
    for all intermediate y ∈ D where z < y < x
```

Guard is on the **open interval** — strictly between, excluding both endpoints.

**Lean code** (Truth.lean:127-130):
```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

Guard is on the **half-closed interval** — `t ≤ r` includes the current point t.

**ROADMAP.md** (lines 186-189) describes the open guard (`∀ r, t < r ∧ r < s → φ@r`), **contradicting the actual code**. The ROADMAP was written assuming open guard but the code implements half-closed.

### 2. Next/Previous Are Broken Under Current Semantics (CONFIRMED)

**Paper** (line 1189): "we may define X(φ) := ⊥ U φ and Y(φ) := ⊥ S φ"

**Under open guard** (paper's semantics): ⊥ U φ at t requires ∃s > t, φ(s), and ⊥ at all r where t < r < s. On discrete orders, the interval (t, t+1) is empty, so ⊥ holds vacuously. X(φ) correctly means "φ at the immediate successor." On dense orders, (t, s) is never empty, so X(φ) is always false. This matches the paper's line 1190.

**Under half-closed guard** (code's semantics): ⊥ U φ at t requires ∃s > t, φ(s), and ⊥ at all r where t ≤ r < s. Since r = t is allowed (t ≤ t), ⊥ at t is required — which is always false. **Next is always false regardless of order type.** The definition at Formula.lean:330 (`def next (φ) := Formula.untl Formula.bot φ`) is semantically broken.

### 3. Literature Consensus: Open Guard Is Universal

| Source | Guard convention | BX9 valid? | Next = ⊥ U φ? |
|--------|-----------------|------------|---------------|
| Kamp 1968 | open (t, s) | No | Yes (discrete) |
| Burgess 1982 | open (t, s) | No | Yes (discrete) |
| Xu 1988 (line 31) | open: `t < t'' < t'` | No | Yes (discrete) |
| Reynolds 1992 | open | No | Yes (discrete) |
| Venema 1993 | open | No | Yes (discrete) |
| Paper (line 1186-7) | open: `x < y < z` | No | Yes (discrete) |
| **Lean code** | **half-closed [t, s)** | **Yes** | **No (always false)** |

No published temporal logic source uses the half-closed guard convention. The code's convention appears to be an implementation artifact.

### 4. Axioms That Depend on Half-Closed Guard

Four axioms are sound ONLY under the half-closed guard and would become unsound under open guard:

| Axiom | Statement | Soundness proof mechanism | Status if switched |
|-------|-----------|--------------------------|-------------------|
| `until_guard` | (φ U ψ) → φ | `le_refl t` extracts guard at t | **REMOVE** |
| `since_guard` | (φ S ψ) → φ | `le_refl t` extracts guard at t | **REMOVE** |
| `until_elim` / BX9 | (φ U ψ) → (φ ∨ ψ) | `le_refl t` at SoundnessLemmas.lean:720 | **REMOVE** |
| `since_elim` / BX9' | (φ S ψ) → (φ ∨ ψ) | `le_refl t` at SoundnessLemmas.lean:727 | **REMOVE** |

Note: `until_guard` (φ U ψ → φ) is STRONGER than BX9 (φ U ψ → φ ∨ ψ). Neither appears in Xu 1988's axiom system Σ4. Xu's completeness proof works without either axiom.

Axioms that **remain sound** under open guard: BX2/BX2' (left_mono), BX3/BX3' (right_mono), BX4/BX4' (connect), BX5/BX5' (self_accum), BX6/BX6' (absorb), BX7/BX7' (linear), BX10/BX10' (until_F/since_P), BX11/BX11' (temp_linearity), BX12/BX12' (F_until_equiv/P_since_equiv), seriality, and all S5 modal axioms.

### 5. Blast Radius Assessment

**Tier 1 — Direct changes (minimal effort)**:
- `Truth.lean:128`: Change `t ≤ r` to `t < r` (1 character)
- `Truth.lean:130`: Change `r ≤ t` to `r < t` (1 character)
- `Axioms.lean`: Remove 4 axiom constructors (until_guard, since_guard, until_elim, since_elim)

**Tier 2 — Soundness rework (significant effort)**:
- `SoundnessLemmas.lean`: ~50 match arms on the Axiom type must be updated (4 arms deleted, remaining U/S arms need proof adjustment from `le_of_lt`/`le_trans` to `lt_trans`)
- `Soundness.lean`: ~30 match arms updated across soundness, soundness_dense, soundness_discrete theorems
- Estimated: ~80 match arm adjustments across 2 files

**Tier 3 — Chronicle r-relation infrastructure (critical path)**:
- `RRelation.lean:86-104`: `until_guard_in_mcs` and `since_guard_in_mcs` theorems (used 10+ times) — **must be replaced**
- `RRelation.lean:1176-1193`: Proof that η ∈ A from burgessR(A, η, C) uses `until_guard_in_mcs` — needs alternative derivation
- `RRelation.lean:1218-1260`: Additional until_guard/since_guard uses in r-relation lemmas
- `PointInsertion.lean:652-673`: Uses `until_guard_in_mcs` for ⊥ U bot contradiction

**Tier 4 — Quasimodel/Filtration audit**:
- The 2,289-line quasimodel infrastructure uses the guard at various points. Full audit needed.
- `Frame.lean`, `TruthLemma.lean`, `Construction.lean`, `Realization.lean` may reference guard properties.

**Tier 5 — Derived theorems and examples**:
- Any derived theorem using BX9, until_guard, or guard extraction at current point.
- Example files (Demo.lean, etc.) that use these axioms.

**Total**: ~175 references across ~15 files. The soundness rework (Tier 2) is mechanical. The critical risk is Tier 3 — whether the r-relation infrastructure can be rebuilt without `until_guard_in_mcs`.

### 6. The Literature Provides the Alternative Path

Xu 1988 Lemma 2.3(i) gives the replacement for `until_guard_in_mcs`:

> For R(A, B, C): S(α, ⊤) ∈ B for every α ∈ A

This means every formula in A is "seen" by B through the Since modality — the r-relation itself encodes guard information without needing the until_guard axiom. The proof uses axioms (1) and (3) (= BX2 and BX4 in the codebase), both of which remain sound under open guard.

Specifically, where the current code does:
```
-- U(γ, δ) ∈ A implies γ ∈ A (by until_guard)
have h : γ ∈ A := until_guard_in_mcs h_mcs_A h_utl
```

The replacement under open guard would derive γ ∈ A through the r-relation structure: if R(A, B, C) and U(γ, δ) ∈ A, then by BX5 (self_accum_until) applied in A, `U(γ ∧ (γ U δ), δ) ∈ A`, and by BX10 (until_F), `F(δ) ∈ A`. The guard γ propagates through the r-relation's intermediate DCS, not through direct extraction at the current point.

### 7. Self-Accumulation (BX5) Under Open Guard

BX5: (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)

Under open guard, this says: if ∃s > t, ψ(s) and φ at all r ∈ (t, s), then ∃s > t, ψ(s) and (φ ∧ (φ U ψ)) at all r ∈ (t, s).

The soundness proof (SoundnessLemmas.lean:598-607) uses `le_trans hqr hrt` for the inner Since guard. Under open guard, this becomes `lt_trans` — still valid. BX5 remains sound. However, the proof needs adjustment: the inner Until `⟨s, hrs, h_ψs, ...⟩` uses `le_trans htr hqr` which would become `lt_trans` under strict inequalities. This is a mechanical fix.

## Recommendations

### Option A: Switch to Open Guard (Recommended)

Match the paper and all published literature. This enables Next/Previous definability and aligns the formalization with Burgess-Xu theory.

**Steps**:
1. Change Truth.lean (2 characters)
2. Remove 4 axioms from Axioms.lean
3. Rework soundness proofs (~80 match arms, mechanical)
4. Replace `until_guard_in_mcs` with Xu Lemma 2.3(i)-based derivation
5. Audit and fix Quasimodel/Chronicle code
6. Update ROADMAP (already describes open guard — just fix the "discrepancy" note)

**Risk**: The r-relation infrastructure rework (step 4) is the critical path. If Xu's Lemma 2.3(i) is already implicitly proved in the codebase (via `burgessRSet` properties), this is straightforward. If not, it needs ~50 lines of new infrastructure.

**Estimated effort**: 20-40 hours depending on Quasimodel audit findings.

### Option B: Keep Half-Closed Guard, Define Next Differently

Keep the current semantics but abandon Next = ⊥ U φ. Define Next via a separate semantic clause (not as a derived operator). This preserves all existing proofs but means Next/Previous are NOT definable from Until/Since.

**Downside**: Contradicts the paper's definition at line 1189. Diverges from all published literature. The paper explicitly says "we may define X(φ) := ⊥ U φ" — if the formalization doesn't support this, the paper's claim is unsubstantiated.

### Option C: Hybrid — Open Guard with Replacement Axioms

Switch to open guard but add replacement axioms that recover some of BX9's proof-theoretic power without depending on the closed guard:
- Replace BX9 with a weaker axiom derivable under open guard, such as: (φ U ψ) ∧ F(ψ) → F(φ) (guard propagation to some future point)
- This would require identifying which downstream proofs actually need BX9 vs. just the r-relation structure

**Assessment**: Likely unnecessary — Xu's completeness proof works without BX9 at all, suggesting the axiom is not needed for the representation theorem.

## Interaction with Task 107 (Plan v21)

Task 107's implementation plan (artifact 34) has 5 phases for closing 9 chronicle sorry sites. The guard semantics change interacts with exactly one step.

### Independent Phases (no wasted work if refactored later)

- **Phase 1** (Lemma 2.6 seed consistency): Uses BX5, BX6, BX7, BX4. None depend on the guard convention.
- **Phase 2** (7 c2' sorry sites): Constructs g-values via BurgessR3Maximal and the r-relation. The DCS construction is about r-relation structure, not guard extraction at the current point.
- **Phase 3** (g-immutability): Pure structural properties about g-values across omega-chain stages.
- **Phase 5** (cleanup): No axiom dependency.

### One Interaction Point in Phase 4

Phase 4.1 (guard-at-intermediate-points lemma) contains:

> "from U(xi, eta) in f(t), by BX9 (until_elim), xi or eta in f(t)"

BX9 is one of the 4 axioms that would be removed under open guard. This single derivation step would need replacement. The rest of Phase 4 (C3 interval containment, limit_g_contains_finite_stage, Cantor isomorphism transfer) is independent.

**Replacement under open guard**: Instead of extracting the guard at the current point via BX9, derive guard membership in g(t,s) through the r-relation at the finite stage where C5 elimination occurs. Xu Lemma 2.3(i) — `S(α, ⊤) ∈ B for every α ∈ A` when `R(A, B, C)` — provides the mechanism. The guard enters g_n(t,s) through the BurgessR3Maximal construction, then lifts to limit_g via Phase 3.3's `limit_g_contains_finite_stage`.

### Existing Infrastructure Dependency

`until_guard_in_mcs` in RRelation.lean (lines 86-104) is used ~10 times in the r-relation infrastructure that plan v21 builds on top of. Plan v21 does NOT add new calls to `until_guard_in_mcs` in Phases 1-3 — the Lemma 2.6 and c2' constructions work through BurgessR3Maximal, not guard extraction. One existing use in PointInsertion.lean:673 (⊥ U ⊥ contradiction) would need a different contradiction argument under open guard, but this is existing code that plan v21 does not modify.

### Recommended Sequencing

**Finish plan v21 first, then refactor to open guard as a separate task.**

1. Phases 1-3 produce no wasted work regardless of guard convention.
2. Phase 4 has exactly one step using BX9. When later refactoring, replace that step with an r-relation derivation — the surrounding 95% of Phase 4 survives intact.
3. Doing both simultaneously doubles risk — two large cross-cutting changes interacting unpredictably.
4. Closing the chronicle sorries first yields a working completeness theorem under current semantics. The guard refactor becomes a clean follow-up.

A note has been added to plan v21 Phase 4.1 flagging the BX9 dependency for future replacement.

## References

- Xu, M. (1988). "On some U,S-tense logics." JPL 17(2), 181-202. Section 2, line 31 (open guard semantics), Lemma 2.3(i) (r-relation guard propagation).
- Burgess, J. P. (1982). "Axioms for tense logic. I." NDJFL 23(4), 367-374. Open guard convention.
- Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." Studia Logica 51, 165-193. Open guard convention.
- Kamp, H. (1968). "Tense Logic and the Theory of Linear Order." PhD thesis, UCLA. Original Until/Since definitions with open guard.
