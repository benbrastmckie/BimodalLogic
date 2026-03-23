# Team Research Synthesis: Preorder Semantics Conformance with TaskFrame

**Task 39**: Study preorder semantics conformance with Task Semantics specifications
**Date**: 2026-03-23
**Team**: 1 teammate (Teammate A; Teammate B did not execute)

---

## Summary

The preorder semantics adopted for the FMCS/CanonicalMCS construction **does NOT need to conform** to TaskFrame semantics requirements — and this is by design. The two structures serve entirely different roles in the completeness proof pipeline.

---

## Core Answer to the Research Question

**Does the Preorder FMCS conform to TaskFrame semantics?** No, and it is not supposed to.

The FMCS/CanonicalMCS construction is a **proof-theoretic intermediate** used solely to establish the TruthLemma. It lives at a different level of abstraction from TaskFrame semantics. The actual TaskFrame-conforming model is `CanonicalTaskTaskFrame` in `SuccChainTaskFrame.lean`, which uses `TaskFrame Int` with the CanonicalTask (Succ-chain) relation.

---

## Key Architectural Facts

### Two-Layer Architecture

| Layer | Structure | Order | Purpose |
|-------|-----------|-------|---------|
| Layer 1 (Proof-theoretic) | `FMCS CanonicalMCS` | Preorder only | TruthLemma proof |
| Layer 2 (Semantic) | `CanonicalTaskTaskFrame` | `TaskFrame Int` (AddCommGroup + LinearOrder) | Completeness model |

This separation is explicitly documented in `FMCSDef.lean`, `CanonicalFMCS.lean`, and `Bundle/README.md`.

### Why Preorder Suffices for Layer 1

The FMCS temporal coherence conditions use only reflexive `≤`:
- `forward_G`: G φ at t propagates to all t' ≥ t (uses T-axiom for t' = t)
- `backward_H`: H φ at t propagates to all t' ≤ t (uses T-axiom for t' = t)

Reflexivity is the key — the T-axioms (`G φ → φ`, `H φ → φ`) handle the reflexive case, so Preorder (reflexive + transitive) is exactly what is needed. Totality and group structure are not required for the TruthLemma.

### Why the SuccChain Track Satisfies TaskFrame

The `CanonicalTask` relation (integer-indexed Succ chains) satisfies all three TaskFrame axioms:
1. **nullity_identity**: `CanonicalTask u 0 v ↔ u = v` — PROVEN
2. **forward_comp**: Chain concatenation for non-negative indices — PROVEN
3. **converse**: `CanonicalTask u n v ↔ CanonicalTask v (-n) u` — PROVEN

These are packaged into `CanonicalTaskTaskFrame : TaskFrame Int` in `SuccChainTaskFrame.lean`.

---

## Semantic Gap Assessment

There is a **semantic gap** between the two layers, but it is bridged correctly:

1. The FMCS/CanonicalMCS construction produces a satisfying model for the TruthLemma
2. The SuccChain construction produces a `TaskFrame Int` satisfying model for the completeness theorem
3. The completeness proof (`succ_chain_completeness`) uses the SuccChain model (Layer 2), not the FMCS model (Layer 1)

The FMCS (Layer 1) is used internally during the proof, but the final completeness statement is phrased in terms of the `succ_chain_model` over `CanonicalTaskTaskFrame`, which is a proper `TaskFrame Int`.

---

## Remaining Formal Gaps

Two sorries remain in the SuccChain track:

| Location | Sorry | Impact on Completeness |
|----------|-------|----------------------|
| `CanonicalTaskRelation.lean` | `backward_witness` | Does not block forward completeness |
| `SuccChainTruth.lean` | Box backward direction | Not used in `succ_chain_completeness` |

The forward truth direction (`succ_chain_truth_forward`) is sorry-free and sufficient for `succ_chain_completeness`.

---

## Confidence Level: HIGH

The architecture is internally consistent, explicitly documented, and mathematically sound. The Preorder choice for FMCS is justified and does not create a semantic gap with respect to TaskFrame conformance — because conformance is established via a separate construction (SuccChain/CanonicalTask) that fully satisfies all TaskFrame axioms.

---

## Recommendation

No corrective action needed. The preorder semantics adoption is architecturally sound. If full formal completeness is desired, the two remaining sorries (`backward_witness` and Box-backward) should be addressed — these are the subject of Task 35 (prove remaining SuccChain sorries) and Task 38 (Box backward direction).
