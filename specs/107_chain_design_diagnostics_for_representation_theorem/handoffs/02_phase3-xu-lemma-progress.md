# Handoff: Task 107 -- Phase 3 Xu's Lemma Progress

## Session
- **Session ID**: sess_1777387372_ae0206
- **Phases Completed**: 1 (Review), 2 (Cleanup)
- **Phase 3**: IN PROGRESS (BX5 core helper sorry-free, Lemma 2.3 and main theorems sorry'd)
- **Phases Remaining**: 3 (finish), 4-8
- **Build Status**: `lake build` passes (1097 jobs)
- **Sorry Count**: 15 (was 11, added 4 new theorem stubs)

## What Was Done This Session

### Phase 3 Progress: Xu's Lemma 3.2.1 Infrastructure

1. **Convention Analysis**: Resolved the Xu/Burgess notation confusion.
   - Xu's `U(phi, psi)` = `untl(psi, phi)` in our code (EVENT first, GUARD second in Xu)
   - Our `untl(phi, psi)` has GUARD first, EVENT second
   - The handoff from the previous agent incorrectly stated `untl(gamma, beta) in B` 
   - The CORRECT claim is `untl(beta, gamma) in B` (guard=beta from B, event=gamma from C)
   
2. **Identified Critical Dependency**: Burgess Lemma 2.3 equivalence
   - `burgessR(A, beta, C) <=> burgessRSince(C, beta, A)` for MCS A, C
   - Uses BX4 (connect_future) / BX4' (connect_past)
   - Required because our `BurgessR3Maximal` uses bidirectional `burgessR3`
   - Xu's proof uses only forward maximality (unidirectional)
   - The equivalence bridges the gap

3. **Implemented Sorry'd Theorems in RRelation.lean**:
   - `burgessR_implies_burgessRSince` (Lemma 2.3 forward) -- sorry
   - `burgessRSince_implies_burgessR` (Lemma 2.3 backward) -- sorry
   - `burgessRSet_iff_burgessRSetSince` (corollary, proved from above two)
   - `burgessR3_untl_conj_in_A` -- **SORRY-FREE** (the core BX5 argument!)
   - `burgessR3Maximal_untl_mem_B` (Xu 3.2.1(i)) -- sorry
   - `burgessR3Maximal_snce_mem_B` (Xu 3.2.1(ii)) -- sorry

4. **The Core BX5 Argument is Sorry-Free**: `burgessR3_untl_conj_in_A` proves:
   ```
   burgessR3(A, B, C), beta in B, gamma in C, beta' in B, delta in C
   => untl(beta' AND untl(beta, gamma), delta) in A
   ```
   Proof chain: burgessRSet -> BX5 (self_accum) -> BX2 (left_mono) -> BX3 (right_mono).

## Current Sorry Sites (15 total)

### RRelation.lean (4 NEW sorry sites)
1. **Line 1190**: `burgessR_implies_burgessRSince` (Lemma 2.3 forward)
2. **Line 1202**: `burgessRSince_implies_burgessR` (Lemma 2.3 backward)
3. **Line 1374**: `burgessR3Maximal_untl_mem_B` (Xu 3.2.1 Until)
4. **Line 1387**: `burgessR3Maximal_snce_mem_B` (Xu 3.2.1 Since)

### CounterexampleElimination.lean (9 sorries, unchanged)
5. Line 425: C4 hard case nested bridging (Until) -- Phase 4
6. Line 543: C4' hard case nested bridging (Since) -- Phase 4
7. Line 792: c2' for C5 forward elimination -- Phase 5
8. Line 830: c2' for C5 backward elimination -- Phase 5
9. Line 870: c2' for C4 forward elimination -- Phase 4
10. Line 908: c2' for C4 backward elimination -- Phase 4
11. Line 944: c2' for G-propagation elimination -- Phase 5
12. Line 976: c2' for density elimination -- Phase 5
13. Line 1092: c2' for general case (density self-pair) -- Phase 5

### ChronicleToCountermodel.lean (2 sorries, unchanged)
14. Line 615: Forward Until coherence (FUC)
15. Line 619: Forward Since coherence (FUC)

## Proof Strategy for Remaining Phase 3 Work

### Burgess Lemma 2.3 Equivalence (highest priority)

The key missing piece. Two approaches:

**Approach A (Direct BX4 proof)**:
- burgessR(A, beta, C) => burgessRSince(C, beta, A)
- Need: for all alpha in A, snce(beta, alpha) in C
- Have: for all gamma in C, untl(beta, gamma) in A
- Key axiom: BX4 (connect_future): phi -> G(P(phi))
- Strategy: From untl(beta, gamma) in A and alpha in A, derive snce(beta, alpha) in C
- The proof likely uses BX4 to connect A-membership to C-membership through the temporal structure

**Approach B (Change BurgessR3Maximal to forward-only)**:
- Change the maximality condition to use only burgessRSet (forward direction)
- Xu's proof then works directly without Lemma 2.3
- Risk: breaks downstream code that depends on BurgessR3Maximal having both directions
- Would require plan revision

**Recommended**: Approach A. Implement Lemma 2.3 using BX4/BX4'. The proof should use:
1. BX4: alpha -> G(P(alpha)). With alpha in A: G(P(alpha)) in A.
2. BX3' (right_mono_since): G applied to implications gives Since weakening.
3. Some combination of BX4 + untl(beta, gamma) in A to derive snce(beta, alpha) in C.

The semantic intuition: if beta holds throughout (x, y) and alpha holds at x, then snce(beta, alpha) holds at y. BX4 formalizes "alpha is in the past of all future points."

### Xu's Lemma 3.2.1 (depends on Lemma 2.3)

Once Lemma 2.3 is proved, Xu's Lemma follows by:
1. Assume untl(beta, gamma) not in B.
2. Show DC(B union {untl(beta,gamma)}) is consistent and properly extends B.
   - If inconsistent: neg(untl(beta,gamma)) in B, derive contradiction via BX5 + Lemma 2.3.
   - If consistent: B' = DC(B union {untl(beta,gamma)}) is a proper DCS extension.
3. Show burgessRSet(A, B', C) using `burgessR3_untl_conj_in_A` (sorry-free).
4. Show burgessRSetSince(C, B', A) using Lemma 2.3 equivalence.
5. So burgessR3(A, B', C), contradicting BurgessR3Maximal.

The inconsistent case (neg(untl(beta,gamma)) in B) needs careful handling:
- neg(untl(beta,gamma)) in B, beta in B, gamma in C
- From burgessRSet: untl(neg(untl(beta,gamma)), delta) in A for all delta in C
- BX7 on untl(beta, gamma) and untl(neg(untl(beta,gamma)), gamma) in A
- Should derive a contradiction, possibly using the BX5 argument on the conjoined guard

### Since Mirror (Xu 3.2.1(ii))

Symmetric proof using BX5' (self_accum_since), BX2' (left_mono_since), BX3' (right_mono_since).
The helper `burgessR3_snce_conj_in_C` needs to be implemented (mirror of `burgessR3_untl_conj_in_A`).

## Key Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
  - Added Lemma 2.3 equivalence stubs (lines 1168-1215)
  - Added `burgessR3_untl_conj_in_A` sorry-free helper (lines 1234-1325)
  - Added Xu 3.2.1 stubs (lines 1327-1387)

## Design Decisions

1. **Convention clarification**: untl(beta, gamma) is the CORRECT form for Xu 3.2.1(i), NOT untl(gamma, beta) as the previous handoff stated. Guard=beta from B, Event=gamma from C.

2. **Lemma 2.3 as prerequisite**: The Burgess Lemma 2.3 equivalence (burgessR <=> burgessRSince) is REQUIRED for Xu's proof to work with our bidirectional BurgessR3Maximal definition. This was not identified in the plan.

3. **The BX5 core is sorry-free**: The mathematical heart of Xu's proof (the BX5 + BX2 + BX3 chain) is fully formalized. What remains is the maximality argument infrastructure.

## Notes for Next Agent

- `lake build` passes (1097 jobs). No regressions.
- The core mathematical insight is implemented: `burgessR3_untl_conj_in_A` proves that untl(beta' AND untl(beta,gamma), delta) in A for any beta' in B, delta in C. This is the BX5 argument from Xu.
- The remaining work for Phase 3 is primarily the Lemma 2.3 equivalence (the bridge between forward and backward directions). Once this is proved, the main theorem should follow relatively mechanically.
- The Lemma 2.3 proof likely uses BX4/BX4' but the exact derivation needs to be worked out. The semantic intuition is clear (see above) but the syntactic proof through the BX axiom system is non-trivial.
- Do NOT attempt to prove untl(gamma, beta) in B (with gamma from C as guard). The CORRECT claim is untl(beta, gamma) in B (beta from B as guard, gamma from C as event).
