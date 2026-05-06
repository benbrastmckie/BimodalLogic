# Phase 5 Handoff: c2' Co-Construction (Final)

## Session
- Session: sess_1778014444_dca927
- Date: 2026-05-05

## Progress Summary

### Completed
1. **C5 forward c2' sorry CLOSED for n=0 case** (line ~872 → removed). When pc.x = max(dom), the construction now:
   - Places y after all domain points
   - Uses lemma_2_4 to get (B, C) with BurgessR3Maximal(f(pc.x), B, C) and η ∈ C
   - Updates g'(max_old, y) = B
   - Proves c2' for all adjacent pairs (new pair from lemma_2_4, old pairs from h_c2')

2. **C5' backward c2' sorry CLOSED for n=0 case** (line ~910 → removed). Mirror:
   - Places y before all domain points
   - Uses past_temporal_witness_seed + Lindenbaum for C with η ∈ C and h_content(f(pc.x)) ⊆ C
   - Uses new helper `burgessR3Maximal_from_h_content_sub` to get B for pair (y, min_old)
   - Updates g'(y, min_old) = B
   - Proves c2' similarly

3. **New helper theorem added**: `burgessR3Maximal_from_h_content_sub`
   - Backward mirror of `burgessR3Maximal_from_g_content_sub`
   - Given h_content(C) ⊆ A and both MCS, produces BurgessR3Maximal(A, B, C)
   - Uses BX4' (connect_past) for the forward Until direction
   - Uses contrapositive of h_content for the backward Since direction

### Remaining Sorries in CounterexampleElimination.lean (6 total)

| Line | Location | Type | Difficulty |
|------|----------|------|------------|
| 586 | eliminate_C4_counterexample | C4 hard case (γ ∈ f(x) ∧ γ ∈ f(y)) | HARD (pre-existing) |
| 684 | eliminate_C4'_counterexample | C4' hard case (mirror) | HARD (pre-existing) |
| 990 | eliminate_potential_counterexample (C5 forward) | n≥1 sub-case of c2' | HARD (Burgess 2.10 induction) |
| 1104 | eliminate_potential_counterexample (C5' backward) | n≥1 sub-case of c2' | HARD (mirror of 990) |
| 1215 | eliminate_potential_counterexample (C4 forward) | c2' for entire case | HARD (needs inline restructuring) |
| 1253 | eliminate_potential_counterexample (C4' backward) | c2' for entire case | HARD (mirror of 1215) |

### Key Technical Obstacles

#### C5 n≥1 (Burgess 2.10 induction, lines 990/1104)
When pc.x is not the extreme point (max for forward, min for backward), the construction needs Burgess 2.10's induction argument:
- **Case n=0** (pc.x = extreme): Proven. lemma_2_4 or burgessR3Maximal_from_h_content_sub provides BurgessR3Maximal for the single new pair.
- **Case n=m+1**: Requires checking conditions (i) and (ii) at the successor of pc.x:
  - (i) If ξ ∧ untl(ξ,η) ∈ f(succ) and η ∈ g(x,succ): reduce to case n=m
  - (ii) If ξ ∈ f(succ) and η ∈ g(x,succ): impossible (contradicts no_witness)
  - Neither: use lemma_2_7 or lemma_2_8 to split (x, succ)

**Mathematical status**: lemma_2_7 is formalized and ready. lemma_2_8 is NOT formalized ("may be recoverable but not needed" per PointInsertion.lean). The induction itself needs to be over the finite set of domain points after pc.x, which requires Lean `Finset` induction machinery.

#### C4 forward/backward (lines 1215/1253)
Same g-unchanged issue. The `eliminate_C4_counterexample` returns g unchanged, so c2' for new adjacent pairs is unprovable. Solution: restructure inline like C5, using lemma_2_6_splitting on the adjacent pair containing z.

**Key challenge**: Need ξ ∉ g(a, b) for splitting to produce ξ.neg ∈ D. When ξ ∈ g (possible in the "hard case" scenario), splitting with β = ξ doesn't work because D ⊇ B ∋ ξ implies ξ ∈ D (not ξ.neg).

**Approach for C4**: 
1. Easy case (ξ.neg ∈ f(pc.x) or ξ.neg ∈ f(pc.y)):
   - If ξ ∉ g for the relevant adjacent pair: use splitting with β = ξ. Done.
   - If ξ ∈ g: need a different construction (possibly lemma_2_7 with appropriate params).
2. Hard case (ξ ∈ f(pc.x) and ξ ∈ f(pc.y)): already has its own sorry (lines 586/684).

### Irreflexive Semantics Impact
This codebase uses IRREFLEXIVE temporal semantics (strict <). Key consequence: G(φ) does NOT imply φ at the current point. Therefore:
- `g_content_subset_mcs` (G(φ) ∈ A → φ ∈ A) has a sorry and is INVALID
- Self-referential BurgessR3Maximal(A, _, A) cannot be proven via g_content_subset
- f'(z) = f(existing_point) approach for C4 easy cases FAILS for the pair involving z and the existing_point

### Architecture
The key pattern established: for each elimination case, DON'T use the eliminate_* helper functions (which leave g unchanged). Instead, construct the chronicle INLINE with updated g-values:
1. Find the adjacent pair affected by the new point
2. Use lemma_2_4 / lemma_2_6_splitting / burgessR3Maximal_from_g/h_content_sub to get B values
3. Define g' with updated values for new pairs
4. Prove c2' by case analysis on adjacent pairs

### File Locations
- CounterexampleElimination.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- PointInsertion.lean (lemma_2_4, lemma_2_6_splitting, lemma_2_7): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- RRelation.lean (burgessR3Maximal_from_g_content_sub, burgessR3Maximal_exists_from_seed): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
- ChronicleTypes.lean (BurgessR3Maximal, c2', Adjacent): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
