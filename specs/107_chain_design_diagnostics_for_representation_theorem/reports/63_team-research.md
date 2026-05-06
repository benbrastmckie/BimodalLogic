# Research Report: Task #107

**Task**: chain_design_diagnostics_for_representation_theorem
**Date**: 2026-05-06
**Mode**: Team Research (4 teammates)
**Session**: sess_1778083004_d8f182

## Summary

Only 2 sorry sites remain in the entire Chronicle construction — both in `ChronicleToCountermodel.lean` at lines 634 and 638 (Forward Until Coherence and Forward Since Coherence). All other Chronicle files are sorry-free. The root cause is that `lemma_2_4` (our Lean formalization of Burgess Lemma 2.4) does not produce guard ∈ B (the interval set), which Burgess's proof explicitly requires. The fix is a faithful alignment with Burgess: enrich `lemma_2_4`'s seed to include Since-obligations, use the existing `burgessR3Maximal_with_guard` theorem to get guard ∈ B, then propagate the guard through the omega chain to the limit via Burgess Lemma 2.5 (absorption). All required mathematical infrastructure exists in the codebase; no novel mathematics is needed.

## Key Findings

### 1. Root Cause Confirmed (Unanimous)

Burgess Lemma 2.4 (p.371) states: "Let A be an MCS and suppose U(γ,β) ∈ A. Then there exist B, C such that **β ∈ B**, γ ∈ C, and R(A,B,C) holds." In Burgess's notation, β is the guard (holds at intermediate points) and γ is the event (holds at endpoint). Under our convention mapping (`untl(guard=φ, event=ψ)` = Burgess `U(event=ξ, guard=η)`), Burgess's β = our guard φ. So **Burgess 2.4 guarantees guard ∈ B**.

Our `lemma_2_4` (PointInsertion.lean:158) seeds B via `burgessR3Maximal_from_g_content_sub` with `DC({top})`. This does NOT guarantee guard ∈ B. This is the single deviation from Burgess that causes both sorry sites.

### 2. Convention Mapping Verified

| Burgess | Our Code | Role |
|---------|----------|------|
| U(α, β) — α = 1st arg, β = 2nd arg | untl(φ, ψ) — φ = 1st arg, ψ = 2nd arg | |
| α = event (holds at endpoint) | ψ = event (2nd arg) | |
| β = guard (holds at intermediate points) | φ = guard (1st arg) | |
| S(α, β) — mirror | snce(φ, ψ) — mirror | |

All 4 teammates verified this mapping independently. The swapped convention is consistent throughout the codebase.

### 3. No Alternative to Modifying lemma_2_4

Teammate B exhaustively evaluated 8 alternative approaches (omega-chain tracking, axiomatic derivation at limit level, BX13 enrichment, density/infimum, separate C5_strong kind, etc.). All are blocked. The fundamental issue: under open guard semantics, `untl(φ,ψ) ∈ f(x)` does NOT force φ at intermediate points without construction-level evidence. The construction must explicitly place guard in the g-function, which requires modifying `lemma_2_4`.

### 4. Critical Infrastructure Already Exists

| Component | Location | Status |
|-----------|----------|--------|
| `burgessR3Maximal_with_guard` | RRelation.lean:~1582 | DONE, sorry-free |
| `iterated_enrichment` (BX13 chain) | PointInsertion.lean:~1388 | Available |
| `limit_c3_interval_subset_point` | ChronicleConstruction.lean:~888 | PROVED, sorry-free |
| `lemma_2_7` output includes guard ∈ B' | PointInsertion.lean:~3616 | PROVED (discarded with `_` at CE:~986) |
| `burgessRSince_implies_burgessR` (Lemma 2.3) | RRelation.lean | Needs verification — may need to be added |
| `lemma_2_5b` (absorption) | RRelation.lean | Needs verification — may need to be added |

### 5. The Guard Propagation Mechanism (Key Mathematical Insight)

**Conflict identified**: Teammate A claimed guard propagation via C3 is straightforward. Teammate C flagged that "C3 is NOT maintained as an invariant at finite stages." Teammate D resolved the conflict:

**Resolution via Burgess Lemma 2.5 (Absorption)**: When a point z is inserted between x and y via Lemma 2.6 splitting, the new g-values satisfy B = B' ∩ D ∩ B'' where B is the original g(x,y) and D = f(z). By Lemma 2.5, this equality is exact — g(x,y) is PRESERVED, not shrunk. Therefore:
- guard ∈ g_n(x,y) at stage n (when y was created) implies guard ∈ g_m(x,y) for ALL m ≥ n
- guard ∈ g_m(x,y) ⊆ f_m(z) for any z inserted between x and y at stage m (by the B ⊆ D component of B = B' ∩ D ∩ B'')
- At the limit: guard ∈ limit_f(w) for ALL w ∈ limit_dom between x and y

This does NOT require C3 as a separately tracked invariant. It uses Lemma 2.5 absorption directly on the g-values.

**However** (Critic's valid concern): This argument requires a new `omega_chain_g_stable` lemma showing g_n(x,y) = g_m(x,y) for m ≥ n. This is currently unproved and must be added (~50-80 lines using `lemma_2_5b`).

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| "C3 propagation is straightforward" (A) vs "C3 not tracked" (C) | Guard propagation uses Lemma 2.5 absorption, not C3 directly. C3 at the limit is definitionally true for `limit_g`. The finite-stage mechanism is Lemma 2.5. |
| "Walk Case B guard propagation works" (A) vs "Walk Case B has bootstrapping gap" (B) | Walk Case B calls `lemma_2_7` which ALREADY produces guard ∈ B' (currently discarded at CE:~986). Exposing this provides guard ∈ g(u_max, z). For x < u_max, the limit_g definition handles propagation automatically at the dense limit. |
| "g-values shrink" (D early) vs "g-values are preserved" (D late) | Lemma 2.5 absorption proves B = B' ∩ D ∩ B'' (equality, not just ⊆). g-values are STABLE across insertions for pairs where both endpoints predate the insertion. |

### Gaps Identified

1. **`burgessRSince_implies_burgessR`**: The (b)→(a) direction of Lemma 2.3. Must verify existence in RRelation.lean; if absent, must be proved (~30-50 lines).

2. **`omega_chain_g_stable`**: New lemma proving g_n(x,y) = g_m(x,y) for m ≥ n when both x,y ∈ dom(n). Uses Lemma 2.5 absorption. Estimated ~50-80 lines.

3. **Enriched seed consistency lemma**: New `until_witness_enriched_seed_consistent` proving {ψ} ∪ g_content(A) ∪ {snce(guard, α) : α ∈ A} consistent. Uses iterated BX13 enrichment (~100-150 lines, mirrors existing `lemma_2_7_seed_consistent`).

4. **Walk Case B guard exposure**: The `_` at CounterexampleElimination.lean:~986-989 discards `pc.ξ ∈ B'` from `lemma_2_7`. Must be exposed and threaded through EliminationResult.

5. **Plan v62 Phase 6 is stale**: The current plan's Phase 6 description understates the work. It assumes C3 at the limit suffices, but the actual dependency chain requires Phases 2-5 of the guard-in-B approach.

### Recommendations

**Recommended implementation strategy** (6 phases, estimated 8-12 hours):

**Phase 1** (DONE): `burgessR3Maximal_with_guard` in RRelation.lean ✓

**Phase 2** — Enrich `lemma_2_4` (PointInsertion.lean):
- Prerequisite: Verify/add `burgessRSince_implies_burgessR` in RRelation.lean
- Enrich C seed: add `{snce(guard, α) : α ∈ A}` to existing `{ψ} ∪ g_content(A)`
- Prove enriched seed consistency via iterated BX13 (existing `iterated_enrichment` infrastructure)
- Derive `burgessRSince(C, guard, A)` from seed membership
- Derive `burgessR(A, guard, C)` via Lemma 2.3 equivalence
- Apply `burgessR3Maximal_with_guard` to get B with guard ∈ B
- New output type: add `guard ∈ B` to existential

**Phase 3** — Update EliminationResult + callers (CounterexampleElimination.lean):
- Add `c5_forward_witness_with_guard` field (or strengthen `c5_forward_witness`)
- Update n=0 case (~line 670): destructure guard ∈ B from enriched `lemma_2_4`
- Update Walk Case A (~line 824): same pattern
- Expose `pc.ξ ∈ B'` from `lemma_2_7` in Walk Case B (~line 986-989): replace `_` with named binding
- Add mirror fields for Since direction

**Phase 4** — Prove `omega_chain_g_stable` (ChronicleConstruction.lean):
- Prerequisite: Verify/add `lemma_2_5b` (Burgess 2.5 absorption) in RRelation.lean
- Prove: for x,y ∈ dom(n), g_n(x,y) = g_m(x,y) for all m ≥ n
- Key tool: Lemma 2.5 ensures B = B' ∩ D ∩ B'' when z is inserted between x and y
- Corollary: guard ∈ g_n(x,y) ⊆ f_m(w) for any w inserted between x and y at stage m

**Phase 5** — Prove `limit_satisfies_c5_strong` (ChronicleConstruction.lean):
- Statement: `untl(ξ,η) ∈ limit_f(x) → ∃ y, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)`
- Proof: (1) `limit_satisfies_c5_weak` gives endpoint y. (2) From Phase 3, ξ ∈ g_{n+1}(x,y) at the elimination stage. (3) From Phase 4, ξ ∈ g_m(x,y) for all m. (4) For any w ∈ limit_dom with x < w < y, ξ ∈ f_m(w) by Lemma 2.5 absorption. (5) Therefore ξ ∈ limit_g(x,y).
- Mirror: `limit_satisfies_c5'_strong` for Since

**Phase 6** — Close FUC/FSC sorries (ChronicleToCountermodel.lean):
- Apply `limit_satisfies_c5_strong` + Cantor isomorphism transfer
- Same pattern as existing sorry-free `cantor_bfmcs_restricted_tc` (lines 456-501)
- Mirror for FSC using `limit_satisfies_c5'_strong`

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | high | Complete 6-phase implementation strategy with line-by-line code mapping |
| B | Alternatives | completed | high | Eliminated 8 alternative approaches, confirmed lemma_2_4 modification is unavoidable |
| C | Critic | completed | high | Identified 4 critical gaps: burgessRSince direction, enriched seed consistency, C3 not tracked, Phase 6 understated |
| D | Horizons | completed | high | Complete Burgess-to-Lean mapping, resolved C3/Lemma 2.5 conflict, defined omega_chain_g_stable approach |

## Effort Estimate

| Phase | Estimated Lines | Estimated Hours | Risk |
|-------|-----------------|-----------------|------|
| Phase 2 (enrich lemma_2_4) | 150-200 | 3-4h | Medium (seed consistency is the hardest part) |
| Phase 3 (EliminationResult + callers) | 80-120 | 2-3h | Low (pattern matching existing code) |
| Phase 4 (omega_chain_g_stable) | 50-80 | 1-2h | Medium (Lemma 2.5 application) |
| Phase 5 (limit_satisfies_c5_strong) | 60-80 | 1-2h | Low (assembles prior phases) |
| Phase 6 (close FUC/FSC) | 20-30 | 0.5-1h | Low (mirror of existing pattern) |
| **Total** | **360-510** | **8-12h** | |

## Prerequisites to Verify Before Starting

1. Does `burgessRSince_implies_burgessR` exist in RRelation.lean? (Lemma 2.3 (b)→(a) direction)
2. Does `lemma_2_5b` / `burgessR3_absorption` exist in RRelation.lean? (Burgess Lemma 2.5)
3. Does `NoUnivBurgessR3` parameter thread through `lemma_2_4`'s callers in CounterexampleElimination.lean?

## References

- Burgess, J. P. (1982). "Axioms for Tense Logic I: 'Since' and 'Until'." Notre Dame Journal of Formal Logic 23(4), pp. 367-374.
- Key sections: 2.4 (Until witness with guard ∈ B), 2.5 (absorption), 2.9-2.10 (C4/C5 elimination), 2.11 (truth lemma)
- Implementation plan: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/62_implementation-plan.md`
- Guard-in-B handoff: `specs/107_irr-until/handoffs/guard-in-B.md`
- Guard exposure analysis: `specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/guard-expose-final.md`
