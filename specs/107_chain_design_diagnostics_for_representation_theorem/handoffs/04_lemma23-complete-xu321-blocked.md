# Handoff: Task 107 -- Lemma 2.3 Complete, Xu 3.2.1 Blocked

## Session
- **Session ID**: sess_1777421333_01be16
- **Phases Completed**: 1 (Doc Cleanup), 2 (A3a/A3b Axioms+Soundness)
- **Phase 3**: PARTIAL (Lemma 2.3 proved, Xu 3.2.1 blocked)
- **Phases Remaining**: 3 (Xu 3.2.1), 4-6
- **Build Status**: `lake build` passes (1097 jobs)
- **Sorry Count in Chronicle/**: 13 (down from 15: Lemma 2.3 forward+backward closed)

## What Was Done This Session

### Burgess Lemma 2.3 (Forward and Backward) -- SORRY-FREE

Closed both Lemma 2.3 sorry sites using enrichment axioms A3a/A3b (BX13/BX13').

**Forward direction** (`burgessR_implies_burgessRSince`): burgessR(A, beta, C) implies burgessRSince(C, beta, A).

Goal: Given alpha in A and P(alpha) in C (already proved), derive snce(beta, alpha) in C.

Proof: By contradiction using A3a (enrichment_until).
1. Assume snce(beta, alpha) not in C. Then neg(snce(beta, alpha)) in C (MCS).
2. By burgessR: untl(beta, neg(snce(beta, alpha))) in A.
3. Conjunction: alpha AND untl(beta, neg(snce(beta, alpha))) in A.
4. Apply A3a: untl(beta, neg(snce(beta, alpha)) AND snce(beta, alpha)) in A.
5. BX10: F(neg(snce(beta,alpha)) AND snce(beta,alpha)) in A.
6. But neg(P) AND P -> bot is a BX theorem (prop_k + lce_imp + rce_imp).
7. G(neg(neg(P) AND P)) in A by temporal necessitation.
8. Contradiction: F(X) = neg(G(neg(X))) and G(neg(X)) both in A.

**Backward direction** (`burgessRSince_implies_burgessR`): Mirror using A3b and past_necessitation.

### Xu's Lemma 3.2.1 -- BLOCKED

**Root cause**: The `BurgessR3Maximal` definition requires DCS (consistent + deductively closed) extensions. Xu's proof uses "2.0(iii)" which gives a direct failure witness without requiring consistency of B union {delta}. Our maximality does not directly give this witness in the inconsistency case.

**Detailed analysis**:

The proof by contradiction has two sub-cases:
- Case 1 (B union {untl(beta,gamma)} is consistent): DC(B union {untl(beta,gamma)}) is a proper DCS extension of B. By `burgessR3_untl_conj_in_A` (sorry-free), it satisfies burgessR3. Contradicts maximality. This case WORKS.
- Case 2 (B union {untl(beta,gamma)} is inconsistent): neg(untl(beta,gamma)) in B. Need to derive a contradiction. After extensive analysis, this appears impossible with current BX axioms because `untl(bot, delta)` is consistent on discrete orders (where the guard interval can be empty). Without BX9 (removed as unsound under open guard), neg(untl(bot, delta)) is NOT derivable.

**Key observation**: `burgessR3Maximal_untl_mem_B` and `burgessR3Maximal_snce_mem_B` are NOT referenced by any downstream sorry site (CounterexampleElimination.lean, ChronicleToCountermodel.lean). They are infrastructure for potential future use.

### Resolution Options

1. **Strengthen BurgessR3Maximal definition** to directly encode Xu's 2.0(iii) witness property. This avoids the consistency gap.
2. **Prove B union {untl(beta,gamma)} is always consistent** using a model-theoretic argument or additional axiom infrastructure.
3. **Add a "guard non-vacuity" axiom** (e.g., untl(bot, phi) -> bot) which would make the inconsistency case derivably contradictory. This restricts to dense orders.
4. **Leave Xu 3.2.1 as sorry** since it's not used downstream. Focus on closing the 11 other sorry sites.

### Recommended Next Steps

Option 4 (leave as sorry, move on) is recommended for immediate progress. The 9 CounterexampleElimination sorry sites and 2 ChronicleToCountermodel sorry sites do NOT depend on Xu 3.2.1. A separate research task could investigate options 1-3.

## Remaining Sorry Sites (13 in Chronicle/)

### RRelation.lean (2)
- Line 1467: `burgessR3Maximal_untl_mem_B` (Xu 3.2.1(i)) -- BLOCKED
- Line 1480: `burgessR3Maximal_snce_mem_B` (Xu 3.2.1(ii)) -- BLOCKED

### CounterexampleElimination.lean (9)
- Lines 425, 543: C4/C4' hard case bridging (gamma not in g)
- Lines 792, 830, 870, 908, 944, 976: c2' construction for new adjacent pairs
- Line 1092: density self-pair case

### ChronicleToCountermodel.lean (2)
- Lines 615, 619: Forward Until/Since coherence

## Key Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
  - Lines 1210-1236: `burgessR_implies_burgessRSince` -- SORRY-FREE (was sorry)
  - Lines 1269-1295: `burgessRSince_implies_burgessR` -- SORRY-FREE (was sorry)
  - Lines 1467, 1480: Xu 3.2.1 -- still sorry
