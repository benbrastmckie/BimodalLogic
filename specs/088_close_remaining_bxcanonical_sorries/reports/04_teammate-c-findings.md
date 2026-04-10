# Teammate C Findings: Task #88 — BXCanonical Sorries (Round 4 Critic)

**Task**: 88 — Close remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Teammate C, Critic
**Session**: sess_1775820000_critic4

---

## Key Findings

### 1. Sorry Count and Locations — VERIFIED ACCURATE (high confidence)

Running `grep -rn sorry` on `Theories/Bimodal/Metalogic/BXCanonical/` confirms exactly **6 actual sorry tactics** (not in comments):

| File | Line | Name | Status |
|------|------|------|--------|
| `Frame.lean` | 653 | `bx_until_eventuality_resolution` | Forward Until guard |
| `Frame.lean` | 675 | `bx_until_backward` | Backward Until construction |
| `Frame.lean` | 690 | `bx_since_eventuality_resolution` | Forward Since guard |
| `Frame.lean` | 704 | `bx_since_backward` | Backward Since construction |
| `CanonicalEmbedding.lean` | 418 | `usf_completeness` imp Case B | G/H history gap |
| `Completeness.lean` | 160 | `bx_completeness` | Downstream of Frame.lean |

The plan's count is accurate. The implementation summary correctly notes that the BXCanonical sorry count is **unchanged at 6** after Phase 1 partial work (two non-BXCanonical sorries in SuccChainFMCS.lean were closed, but those were never in the BXCanonical module).

**Additional sorries found OUTSIDE BXCanonical** (not tracked in this task):
- `Bundle/SuccRelation.lean:548` — `until_persists_through_succ` (X-vs-G mismatch)
- `Bundle/SuccChainFMCS.lean:2174` — multi-BRS G-wrapping case
- `Algebraic/UltrafilterChain.lean:3936,3946` — `succ_chain_restricted_forward_F/backward_P`

These are on **different paths** and not on the critical path for BXCanonical.

---

### 2. Is the X-vs-G Mismatch Truly Fundamental? — YES, WITH NUANCE

The core claim — that `φ U ψ ∈ w` does NOT give `G(φ U ψ) ∈ w` — is correct and fundamental. However, I identify a subtle issue with how this has been framed across 5 rounds of research.

**What BX4 (connect_future) actually gives**: `φ → G(P(φ))`. Applied to `φ U ψ ∈ w`:
- BX4 gives `G(P(φ U ψ)) ∈ w`
- For any `u` with `bx_le w u`, this gives `P(φ U ψ) ∈ u`
- This means there EXISTS a past witness for `φ U ψ` at `u`, but NOT that `φ U ψ ∈ u`

The distinction between `P(φ U ψ) ∈ u` and `φ U ψ ∈ u` is exactly the X-vs-G mismatch: P-membership of Until ≠ membership of Until. BX4 is NOT a bridge; it only gives the weaker P-statement.

**Attempted axiom combinations NOT yet tried**:

Looking at the full axiom list for potential bridges between `φ U ψ ∈ w` and `G(φ U ψ) ∈ w`:

- BX5 (`self_accum_until`): `φ U ψ → (φ ∧ (φ U ψ)) U ψ` — gives a related Until formula but NOT G(Until)
- BX6 (`absorb_until`): `φ U (φ ∧ (φ U ψ)) → φ U ψ` — goes in the wrong direction
- BX7 (`linear_until`): constrains ordering of Until witnesses, not membership propagation
- BX12 (`F_until_equiv`): `F(φ) → ⊤ U φ` — direction is F→Until, not Until→G(Until)

**No BX axiom yields `φ U ψ ∈ w → G(φ U ψ) ∈ w`**. This is semantically FALSE in general: a formula that holds now under Until semantics need not hold at ALL future times. The mismatch is not proof-engineering; it is mathematically correct.

**Critical observation**: The round 1 claim "BX5 + BX6 resolve Until-eventualities axiomatically" is misleading. BX5 gives self-accumulation (the guard holds alongside the Until formula) but this is about what holds AT THE SAME TIME, not about propagating the Until formula to future MCS points. The self-accumulation is relevant for the Zorn-based eventuality argument within a single chain, not for the g_content-based ordering.

---

### 3. Is the CanonicalEmbedding:418 Approach Actually Viable?

**Claim in the implementation summary**: "Viable approach using RestrictedTemporallyCoherentFamily + restricted parametric truth lemma (12-18h)"

**Assessment: PARTIALLY VIABLE, but faces a significant dependency on sorry'd infrastructure**.

The proposed approach (summary line 26-31):
1. Use `RestrictedTemporallyCoherentFamily` from SuccChainFMCS to build a DRM chain
2. Extend each position to full MCS via Lindenbaum
3. Prove restricted version of parametric truth lemma for sub-formulas
4. Apply contradiction to `ψ.imp χ`

**What I found in RestrictedTruthLemma.lean and SuccChainFMCS.lean**:

- `RestrictedTemporallyCoherentFamily` exists in `Bundle/SuccChainFMCS.lean`
- `RestrictedTruthLemma.lean` imports it and begins building the truth lemma
- **BUT**: `SuccChainFMCS.lean` itself has **18 sorry occurrences** (counted) and the key ones block the approach:
  - `succ_chain_restricted_forward_F` (line 3936): SORRY — "key remaining gap for canonical completeness"
  - `succ_chain_restricted_backward_P` (line 3946): SORRY — symmetric
  - Multi-BRS G-wrapping case (line 2174): SORRY

These are the SAME type of forward-F eventuality resolution problem. The summary's "viable approach" punts the hard work to infrastructure that is itself sorry'd. The claim that CanonicalEmbedding:418 is closable in "12-18 hours" should be qualified as: **12-18 hours IF the SuccChainFMCS infrastructure sorries can be closed first**, which is itself an open problem.

**The CanonicalEmbedding:418 sorry is NOT independent** in the strong sense the round 3 report claimed. It is independent of the Frame.lean sorries (different path), but it depends on SuccChainFMCS infrastructure that is itself sorry'd. Closing CanonicalEmbedding:418 via the RestrictedTemporallyCoherentFamily route requires first closing those infrastructure sorries.

**Alternative**: A direct proof-theoretic approach for USF completeness may exist that bypasses the restricted chain entirely. For `imp Case B` specifically: given `ψ ∈ w.formulas` and `χ ∉ w.formulas` where `untilSinceFree (imp ψ χ)`, we need a model where `ψ → χ` is false. For USF formulas (no Until/Since), the BXPoint canonical model itself works as the countermodel without needing chain construction — the truth lemma for G/H is already available via `G_iff_mcs`/`H_iff_mcs` in TruthLemma.lean (both sorry-free). The gap is only in connecting `BXPoint membership ↔ truth on a non-constant history`, which is the specific constant-history collapse issue. A two-point history (w, v) where v is a successor of w might suffice without the full SuccChainFMCS machinery.

---

### 4. Is the BX11/BX12 Addition Correct?

Round 1 research concluded temp_linearity and F_until_equiv were "missing" and recommended re-adding them. Round 3 research concluded they are present but "not used in BXCanonical."

**Current state of axioms (verified)**:
- BX11 (`temp_linearity`): `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)` — PRESENT (Axioms.lean:240)
- BX11' (`temp_linearity_past`): PRESENT (Axioms.lean:249)
- BX12 (`F_until_equiv`): `F(φ) → ⊤ U φ` — PRESENT (Axioms.lean:258)
- BX12' (`P_since_equiv`): PRESENT (Axioms.lean:263)

These were restored in Plan v1, Phase 1 (implementation summary confirms). They are present in the axiom system but grep confirms they are **NOT referenced anywhere in BXCanonical/** files.

**Why they don't help** (confirmed by direct analysis of Frame.lean sorries):
- The guard condition requires φ at ALL intermediate BXPoints u with `bx_le w u` and `bx_lt u v`
- BX11 constrains when two future eventualities have a common witness — not useful here
- BX12 gives `F(φ) → ⊤ U φ`, which means any F-statement gives an Until-statement — but already known from BX10+BX8

The round 3 Critic's 85% confidence assessment that "BX11/BX12 do not help" is **confirmed at 95%+ confidence** after direct analysis.

---

### 5. Circular Dependencies in Research

After reading all reports across rounds 1-4, I identify the following patterns:

**Pattern 1: Recurring rediscovery of X-vs-G mismatch** (5 times):
- Round 1: "The removal was based on incorrect reasoning that BX7 subsumes temp_linearity"
- Round 2: "interval linearity is derivable from BX7 + BX12" (CLAIMED)
- Round 3: "interval linearity claim demolished" by Critic
- Plan v3: Architecture spike as Phase 2
- Implementation summary: "Phase 2 NO-GO — architecture change doesn't help either"

Each round's innovation is demolished by the next round's analysis.

**Pattern 2: Over-optimistic time estimates**:
- Round 1: "8-16 hours" for re-adding axioms
- Round 2: "4-8 hours" for interval linearity approach
- Round 3: "12-18 hours" for CanonicalEmbedding via restricted truth lemma
- Each estimate has proven wrong because it underestimates sorry-dependence in upstream infrastructure

**Pattern 3: Consistent correct diagnosis, inconsistent conclusions**:
All rounds correctly identify: (a) the X-vs-G mismatch, (b) that no BX axiom bridges it, (c) that bx_le is g_content-based. But different rounds draw different conclusions about what to do next. The round 1 axiom restoration was correct and completed (BX11/BX12 added). The follow-on conclusions about what these additions enable have been repeatedly wrong.

---

## Assessment of Prior Claims

### Round 3 Synthesis Report Claims

1. **"CanonicalEmbedding:418 is NOT on the critical path for bx_completeness"** — CONFIRMED CORRECT. Completeness.lean imports TruthLemma, not CanonicalEmbedding.

2. **"BX11/BX12 are used nowhere in BXCanonical"** — CONFIRMED CORRECT.

3. **"Backward Until is NOT simpler"** — CONFIRMED CORRECT. The forward and backward sorries both fail at interval linearity.

4. **"4-6 hours" for CanonicalEmbedding:418 via WorldHistory infrastructure** — INCORRECT. The preferred approach depends on SuccChainFMCS infrastructure that itself has sorries. A direct proof-theoretic route may exist as an alternative but was not fully explored.

5. **"FMP bridge not viable"** — CONFIRMED CORRECT.

### Implementation Summary Claims

1. **"Phase 2 NO-GO is definitive: any single global ordering faces the same issue"** — CONFIRMED CORRECT and this is the most important finding of the implementation attempts.

2. **"Viable approach using RestrictedTemporallyCoherentFamily"** — PARTIALLY INCORRECT. The approach is conceptually valid but depends on sorry'd infrastructure, making the 12-18h estimate unreliable.

---

## Overlooked Possibilities

### 1. Direct Two-Point History for CanonicalEmbedding:418

The existing sorry at CanonicalEmbedding:418 is for `imp Case B`: given `ψ ∈ w.formulas`, `χ ∉ w.formulas`, `untilSinceFree (ψ.imp χ)`, need to construct a model where `ψ → χ` is false.

For USF formulas, `G_iff_mcs` and `H_iff_mcs` are both sorry-free in TruthLemma.lean. The issue is only the "backward truth bridge" direction: given `truth_at G(α)`, need `G(α) ∈ w`. On a constant history, `truth_at G(α) = truth_at α` (since the single point is its own future), so the bridge fails.

**Unexplored approach**: Use `bx_forward_witness` to find `v ≥ w` (or use `w` itself if `G(α) ∉ w`), then build a 2-element TaskModel with times {0, 1} where history(0) = w and history(1) = v. On this model:
- `truth_at G(α) at 0` means `α ∈ v` (time 1 is the future)
- If `G(α) ∉ w`, then `¬G(α) ∈ w`, then using bx_G_backward: `∃ v ≥ w, α ∉ v.formulas`, which would give `¬truth_at G(α) at 0`

This is a more direct route than the RestrictedTemporallyCoherentFamily approach and avoids the sorry'd infrastructure entirely. It requires:
- Defining a finite 2-time TaskModel
- Proving the truth bridge for USF formulas on this 2-point model
- Using the bidirectional G/H IFF from TruthLemma.lean

Estimated viability: **HIGH** (uses only sorry-free infrastructure). Estimated effort: **4-8 hours** (consistent with original estimate for the direct WorldHistory route).

### 2. Formula-Specific Ordering for Frame.lean

All past research has considered **global** orderings (g_content-based bx_le, Until-witness chains). The implementation summary correctly identifies that "any single global ordering" faces the same guard-quantification issue.

**Under-explored**: Per-Until-formula orderings. For each `φ U ψ ∈ w`, define a separate ordering `bx_le_{φ U ψ}` that specifically orders points with respect to resolving THAT particular Until obligation. The guard condition would then be stated in terms of the formula-specific ordering.

This is essentially what the quasimodel approach does — each eventuality has its own "resolution path." The standard reference for this is Gabbay-Hodkinson-Reynolds (1994), which the Boneyard files reference. This approach has been noted but not investigated for BXCanonical specifically.

### 3. Filtration Model for Full Completeness

Standard completeness for propositional temporal logics on linear orders often uses filtration rather than canonical models. Filtration creates a finite model from the subformula closure. For TM logic with Until/Since, the filtration approach would:
- Use `closureWithNeg` or `deferralClosure` as the formula set
- Define truth on the filtration model
- Prove filtration preserves truth

This approach is mentioned in `DeterministicFMCS.lean` as "the quasimodel approach (GHR 1994)" but has not been attempted for BXCanonical. The FMP (finite model property) is already proved sorry-free, which means the filtration concept is partially available.

---

## Confidence Assessment

| Claim | Confidence | Basis |
|-------|-----------|-------|
| Sorry count is exactly 6 in BXCanonical | 100% | Direct grep |
| X-vs-G mismatch is mathematically fundamental | 99% | Semantic counterargument + 5 failed proofs |
| BX11/BX12 do not help Frame.lean sorries | 95% | Direct analysis of what they give |
| CanonicalEmbedding:418 via RestrictedTC depends on sorry'd infra | 90% | Traced SuccChainFMCS dependencies |
| Two-point history approach for CanonicalEmbedding:418 is viable | 75% | Logical sketch; needs implementation verification |
| No "axiom combination" bridges Until-membership to G-membership | 99% | Exhaustive analysis of 37 axiom constructors |
| Quasimodel/filtration is the correct approach for Frame.lean sorries | 70% | Standard literature + failed alternatives exhausted |

---

## Summary

The research history for task 88 is genuinely circular: the same X-vs-G mismatch has been rediscovered 5 times. The implementation summary's "Phase 2 NO-GO is definitive" conclusion is the most important finding and should be trusted.

The key open question for practical progress is: **Can CanonicalEmbedding:418 be closed using sorry-free infrastructure (direct two-point history), or does it require the sorry'd SuccChainFMCS path?** My analysis suggests the two-point history route is viable and avoids the sorry'd dependencies entirely — this has NOT been fully explored despite being the most direct route.

For Frame.lean, the correct conclusion is that they require either (B) quasimodel/filtration or (C) accepting as open problems. No incremental fix to bx_le or axiom additions will resolve them.

---

## References

- `Theories/Bimodal/ProofSystem/Axioms.lean` — Full BX axiom list (37 constructors)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:585-622` — X-vs-G mismatch analysis
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` — sorry-free G/H IFF lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:3920-3946` — sorry'd forward_F/backward_P
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean:542-548` — sorry'd until_persists_through_succ
- `specs/088_close_remaining_bxcanonical_sorries/summaries/03_implementation-summary.md` — Phase 2 NO-GO assessment
- Round 3 report: `specs/088_close_remaining_bxcanonical_sorries/reports/03_team-research.md`
