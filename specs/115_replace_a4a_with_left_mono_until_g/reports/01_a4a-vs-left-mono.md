# Research Report: A4a (separation_until) vs left_mono_until_G -- Axiom Comparison

**Task**: 115 - Replace A4a with left_mono_until_G (Xu path alternative)
**Date**: 2026-04-29
**Session**: sess_1777479139_de118c
**Type**: lean4

## Summary

This report compares two axiom approaches for the Burgess chronicle construction under irreflexive (open-guard) temporal semantics:

- **A4a approach** (current, task 107): `separation_until` / `separation_since` axioms enabling Burgess Lemma 2.6 directly
- **left_mono_until_G approach** (proposed, task 115): `G(phi -> chi) -> (U(phi, psi) -> U(chi, psi))` enabling Xu Lemma 2.4 path

The two axioms solve different problems and are NOT substitutes for each other in a simple sense. A4a enables Burgess's seed consistency argument for Lemma 2.6 splitting. left_mono_until_G enables Xu's guard-strengthening for Lemma 2.3/2.4 splitting. Both are semantically valid under open-guard semantics, both are sound, and both lead to complete axiom systems.

## 1. The Two Axioms

### 1.1 A4a: separation_until (BX14)

```
untl(q, p) AND NOT untl(r, p) -> untl(q, q AND NOT r)
```

**Burgess convention**: `U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)`

This is a separation principle: given two Until formulas with the same event `p` -- one holding, one not -- you can separate out a witness where the guard `q` holds but the guard `r` does not.

**Semantic validity** (open guard): From `untl(q,p)` at t, get witness s0 with p(s0) and q on (t,s0). From `NOT untl(r,p)` applied to s0, get u0 in (t,s0) with NOT r(u0). Then u0 witnesses `untl(q, q AND NOT r)` with guard q on (t,u0) inherited from the original.

**Soundness proof in codebase**: 20 lines in `Soundness.lean` (lines 605-624). Clean, direct.

### 1.2 left_mono_until_G (proposed)

```
G(phi -> chi) -> (untl(phi, psi) -> untl(chi, psi))
```

This is guard weakening using only G-information: if G guarantees phi implies chi at all future times, and Until holds with guard phi, then Until holds with guard chi. This is a weakened version of BX2 (`left_mono_until`), which currently requires BOTH the pointwise condition `(phi -> chi)` AND `G(phi -> chi)`.

**Semantic validity** (open guard): From `untl(phi, psi)` at t, get witness s with psi(s) and phi on (t,s). From `G(phi -> chi)`, get (phi -> chi) at all u > t, including all u in (t,s). So chi on (t,s), giving `untl(chi, psi)`.

**Soundness proof**: Would be approximately 10 lines -- even simpler than A4a. The argument is essentially: the guard interval (t,s) is a subset of the G-interval (t, infinity), so G-information always covers the open guard.

## 2. What Each Axiom Enables

### 2.1 A4a Enables: Burgess Lemma 2.6 (Seed Consistency)

Burgess Lemma 2.6 constructs a splitting point D between A and C when `beta not in B` and `BurgessR3Maximal(A, B, C)`. The critical step is proving consistency of the seed `{beta.neg} UNION g_content(A) UNION h_content(C)`.

**Where A4a is used** (exactly one step in the proof):

1. From `beta not in B` and R3-maximality, extract failure witnesses: there exist beta0 in B, gamma0 in C with `NOT untl(beta0 AND beta, gamma0) in A`.
2. From `burgessR3`, we have `untl(beta0, gamma0) in A`.
3. **A4a applied**: `untl(beta0, gamma0) AND NOT untl(beta0 AND beta, gamma0) -> untl(beta0, beta0 AND NOT(beta0 AND beta))`.
4. Simplify: this gives `untl(beta0, NOT beta)` in A (modulo propositional reasoning).
5. Use BX13 (enrichment_until) and BX3 (right_mono_until) to enrich the seed.

**Current status**: The `splitting_seed_consistent` sorry at PointInsertion.lean line 306 is the sole remaining sorry for this approach. The structural proof surrounding it (lemma_2_6_splitting, lines 308-339) is complete and type-checks.

### 2.2 left_mono_until_G Enables: Xu Lemma 2.3 (Guard Strengthening)

Xu's Lemma 2.3 proves: if `R(A, B, C)`, then `S(alpha, top) in B` for all `alpha in A` and `U(gamma, top) in B` for all `gamma in C`.

**Where left_mono_until_G is needed**: The proof of Xu Lemma 2.3 uses Xu's axiom (1): `G(p -> q) -> (U(r, p) -> U(q, r)) AND (U(r, p) -> U(r, q))`. The FIRST conjunct is a guard/event SWAP:

```
G(p -> q) -> U(r, p) -> U(q, r)
```

Under open-guard semantics, this swap is INVALID (knowing r(s) at the endpoint does NOT give r at all interior points). However, the proof only needs the SECOND conjunct for the right-monotonicity part, which is our BX3. The first conjunct is needed specifically for the guard-strengthening step where alpha in A and `untl(beta, gamma) in A` are combined to get `untl(beta AND snce(top, alpha), gamma)` -- strengthening the guard with Since information.

The key derivation needs:
1. From `alpha in A`, derive `G(snce(top, alpha)) in A` (via BX4 + BX12')
2. From `G(snce(top, alpha))`, derive `G(beta -> beta AND snce(top, alpha))`
3. Apply left_mono_until_G: `G(beta -> beta AND snce(top, alpha)) -> untl(beta, gamma) -> untl(beta AND snce(top, alpha), gamma)`

Step 3 fails with current BX2 because BX2 requires the pointwise condition `(beta -> beta AND snce(top, alpha))` at the current time, but `snce(top, alpha)` at the current time is NOT available under irreflexive semantics.

**With left_mono_until_G**: Step 3 succeeds because the axiom only requires the G-condition, not the pointwise condition. This is sound because the guard interval (t,s) is strictly in the future of t, and G-information covers all of it.

### 2.3 How Xu Lemma 2.4 Avoids A4a

Given `r(A, B, C)`, `NOT U(gamma, beta) in A`, and `gamma in C`:

1. Extend B to B* with `R(A, B*, C)` (Zorn's lemma)
2. `beta not in B*` (if beta in B*, then `U(gamma, beta) in A` by r-relation, contradiction)
3. `B* UNION {neg beta}` is consistent (B* is DCS, beta not in it)
4. D := MCS extending `B* UNION {neg beta}`
5. By Lemma 2.3: `S(alpha, top) in B*` for all `alpha in A`, and `U(gamma', top) in B*` for all `gamma' in C`
6. Since `B* subset D`: `r(A, top, D)` and `r(D, top, C)` by Lemma 2.1
7. Apply 2.0 (Zorn) to get `R(A, B', D)` and `R(D, B'', C)`

The argument is clean: 6 steps, no case analysis, no complex seed construction. A4a is completely absent.

In the codebase's BurgessR3Maximal formulation, step 6 becomes: verify g_content(A) subset D (for the A-to-D direction), then apply `burgessR3Maximal_from_g_content_sub`. Similarly for D-to-C.

## 3. Cost Comparison

### 3.1 Lines of Code

| Item | A4a Approach | left_mono_until_G Approach |
|------|-------------|---------------------------|
| Axiom constructors | 2 (separation_until, separation_since) -- 14 lines | 2 (left_mono_until_G, left_mono_since_H) -- 8 lines |
| Soundness proofs | 2 -- ~40 lines total | 2 -- ~20 lines total |
| SoundnessLemmas.lean match arms | ~20 match arms updated | ~20 match arms updated (same overhead) |
| Key splitting lemma | splitting_seed_consistent: ~60-100 lines (estimated) | Xu Lemma 2.3 + 2.4: ~40-60 lines (estimated) |
| Downstream impact | No changes to BX2 users | BX2 pointwise conjunct becomes redundant (BX2 derivable from left_mono_until_G) |
| Total new/changed lines | ~180-240 | ~120-160 |

### 3.2 Proof Complexity

**A4a approach**:
- Soundness proof is straightforward (6 semantic steps)
- The splitting_seed_consistent proof is HARD: it requires careful manipulation of maximality failure witnesses, A4a application, BX13 enrichment, BX3 right-monotonicity, and a finiteness argument over the bidirectional seed
- The handoff file (02_phase5b-seed-consistency.md) documents the difficulty: g_content and h_content elements live in DIFFERENT MCSes, and cannot be collapsed under irreflexive semantics
- Estimated difficulty: HIGH (this is the gating sorry for task 107)

**left_mono_until_G approach**:
- Soundness proof is trivial (3 semantic steps)
- Xu Lemma 2.3 is a moderate proof using contradiction + enrichment (BX13) + guard strengthening (left_mono_until_G)
- Xu Lemma 2.4 is structurally simple: extend B to R-maximal B*, use DCS consistency, extend to MCS D, apply Lemma 2.3 + Lemma 2.1, Zorn
- The codebase already has `burgessR3Maximal_from_g_content_sub` and `burgessR3Maximal_exists_from_seed` -- the Xu approach naturally uses these
- Estimated difficulty: MEDIUM

### 3.3 Sorry Sites Impact

Both approaches address the same 10 sorry sites:
- 1 sorry in PointInsertion.lean (splitting_seed_consistent)
- 7 sorries in CounterexampleElimination.lean (c2' fields)
- 2 sorries in ChronicleToCountermodel.lean (FUC/FSC)

The choice of axiom does NOT change the downstream sorry sites (Phases 6-11 of task 107's plan). The difference is only in how `splitting_seed_consistent` / the equivalent Xu splitting lemma is proved.

**Important**: Lemma 2.7 (Until-formula splitting for C5 n>0 case) does NOT depend on either A4a or left_mono_until_G. It uses only BX5 + BX7 + BX13, which are already in the system. This was confirmed in task 107 Phase 5a.

## 4. Naturalness for Open-Guard Semantics

### 4.1 left_mono_until_G is More Natural

Under open-guard semantics, `U(phi, psi)` at t means: there exists s > t with psi(s) and phi at all u in the open interval (t,s). The guard interval (t,s) is strictly to the future of t. Therefore:

- **G-information covers the guard by default**: `G(X)` at t means X at all u > t. Every point in (t,s) is > t. So G-information is automatically available throughout the guard interval.
- **Pointwise information at t does NOT cover the guard**: The current time t is NOT in the guard interval (t,s). So knowing `(phi -> chi)` at t tells you nothing about the guard points.

This means left_mono_until_G captures the exact semantic relationship: G-information is the right tool for reasoning about open-guard intervals. The pointwise conjunct in BX2 is semantically unnecessary under open-guard semantics -- it is a vestige of closed-guard `[t,s)` or reflexive `[t,s]` semantics where t IS in the guard interval.

**Consequence**: Adding left_mono_until_G makes BX2 redundant. BX2 says `(phi -> chi) AND G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)`. With left_mono_until_G, the `(phi -> chi)` conjunct is superfluous -- left_mono_until_G alone suffices for all uses of BX2 in the codebase (verified: `untl_left_mono_thm` in RRelation.lean uses BX2, but only after establishing the implication as a theorem, which gives G-information via temporal necessitation).

### 4.2 A4a is Less Natural but More Powerful

A4a (separation) is a more complex axiom that manipulates the internal structure of Until formulas. It extracts a failure witness from a negated Until and constructs a new Until with modified guard/event. This is a clever Hilbert-style construction, but it does not correspond to a simple semantic principle.

Under open-guard semantics, A4a is valid but its proof requires reasoning about the interval containment (t,u0) subset (t,s0). This is similar to left_mono_until_G's semantic argument, but more involved because A4a also reasons about the negation of an Until formula.

**A4a IS strictly more powerful than left_mono_until_G**: A4a cannot be derived from left_mono_until_G (it operates on negated Until formulas, which no monotonicity axiom can handle). left_mono_until_G cannot be derived from A4a either (A4a requires two Until formulas with the same event, while left_mono_until_G works with a single Until). They address orthogonal needs.

### 4.3 Relationship to BX2

BX2 (left_mono_until) currently has the form:
```
(phi -> chi) AND G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)
```

Under open-guard semantics, the `(phi -> chi)` conjunct is semantically unnecessary. The three options are:

1. **Keep BX2 as-is, add A4a**: BX2 is slightly redundant (pointwise conjunct unnecessary) but harmless. A4a adds separation power. System has 2 "extra" axioms.

2. **Replace BX2 with left_mono_until_G**: Strictly cleaner. BX2 becomes derivable (since left_mono_until_G implies BX2: given (phi -> chi) AND G(phi -> chi), just use the G-conjunct with left_mono_until_G). No A4a needed for splitting.

3. **Keep BX2, add left_mono_until_G, remove A4a**: BX2 becomes redundant but is kept for backward compatibility. A4a is not needed since Xu's path avoids it.

## 5. Xu Path vs Burgess Path: Full Comparison

### 5.1 Burgess Path (A4a, current plan v29)

**Phases affected**: 5b (add A4a, prove Lemma 2.6 splitting)

**Proof chain**:
1. BurgessR3Maximal(A, B, C) + beta not in B
2. Maximality failure: extract beta0, gamma0 with NOT untl(beta0 AND beta, gamma0) in A
3. **A4a**: untl(beta0, gamma0) AND NOT untl(beta0 AND beta, gamma0) -> untl(beta0, beta0 AND NOT(beta0 AND beta))
4. Simplify to untl(beta0, NOT beta) in A
5. BX13 enrichment: fold in alpha from A
6. BX3 right-mono: fold in g_content elements
7. Show seed `{neg beta} UNION g_content(A) UNION h_content(C)` is consistent
8. Lindenbaum -> MCS D
9. burgessR3Maximal_from_g_content_sub for both directions

**Difficulty**: The main challenge is step 7 -- proving consistency of the bidirectional seed. The handoff document identifies an open question about whether h_content(C) elements actually land in D from the enrichment (the gap between P(h_j) in D and h_j in D under irreflexive semantics).

### 5.2 Xu Path (left_mono_until_G, proposed)

**Phases affected**: 5b (add left_mono_until_G, prove Xu Lemma 2.3 + 2.4)

**Proof chain**:
1. BurgessR3Maximal(A, B, C) + beta not in B
2. beta not in B follows from: if beta in B, burgessRSet gives untl(gamma, beta) in A for all gamma in C, contradicting neg untl(gamma, beta) in A
3. `dcs_neg_union_consistent`: B is DCS, beta not in B, so B UNION {neg beta} consistent
4. Lindenbaum -> MCS D extending B UNION {neg beta}
5. **Xu Lemma 2.3**: R(A, B, C) implies S(alpha, top) in B for all alpha in A, U(gamma, top) in B for all gamma in C
   - Proof uses left_mono_until_G for guard strengthening
6. B subset D, so g_content(A) subset D and h_content(C) subset D follow from Lemma 2.3 properties
7. burgessR3Maximal_from_g_content_sub for A-to-D
8. h_content(C) subset D gives g_content(D) subset C by duality
9. burgessR3Maximal_from_g_content_sub for D-to-C

**Difficulty**: The main challenge is Xu Lemma 2.3 (step 5). This is a standard contradiction argument using enrichment (BX13) and guard strengthening (left_mono_until_G), and the existing `BurgessR3Maximal_extension_fails` infrastructure. It is structurally simpler than the A4a seed consistency argument because it avoids the bidirectional seed problem entirely -- B is already between A and C by hypothesis, so D inherits both g_content and h_content membership from B.

### 5.3 Key Structural Difference

The fundamental difference is in HOW consistency is established:

**Burgess (A4a)**: Constructs a seed from scratch containing elements from three different sources (neg beta, g_content(A), h_content(C)) and must prove this combination is consistent. This is hard because g_content(A) lives in A's G-future and h_content(C) lives in C's H-past, and under irreflexive semantics these are different directions.

**Xu (left_mono_until_G)**: Extends an EXISTING consistent set B (which already mediates between A and C) by adding neg beta. Consistency is trivial (DCS + element not in it). The g_content/h_content properties are inherited from B's membership in the R3-maximal structure.

## 6. Feasibility Assessment

### 6.1 A4a Path (Current Task 107)

- **Axiom already added**: separation_until and separation_since are in Axioms.lean
- **Soundness already proved**: In Soundness.lean and SoundnessLemmas.lean
- **Remaining work**: splitting_seed_consistent (1 sorry, estimated 4-6 hours)
- **Risk**: The bidirectional seed consistency argument has an identified open question (h_content in D gap)
- **Status**: [PARTIAL] in task 107 Phase 5b

### 6.2 left_mono_until_G Path (Task 115)

- **Axiom not yet added**: Would be 2 new constructors in Axioms.lean
- **Soundness not yet proved**: Would be ~20 lines
- **Required work**: Add axiom, prove soundness, formalize Xu Lemma 2.3, formalize Xu Lemma 2.4 adaptation, remove A4a
- **Additional cleanup**: Update all SoundnessLemmas.lean match arms, remove A4a references
- **Risk**: The Xu Lemma 2.3 proof in the BurgessR3Maximal setting needs careful verification (step 5-6 from Section 5.2)
- **Estimated effort**: 8-12 hours total

### 6.3 Can Both Coexist?

Yes. The axioms are independent:
- A4a cannot derive left_mono_until_G (different structures)
- left_mono_until_G cannot derive A4a (different structures)

Having both would give maximum flexibility. However, the task description explicitly asks to REPLACE A4a with left_mono_until_G, so coexistence is not the stated goal.

## 7. Recommendations

### 7.1 If Task 107 Succeeds with A4a

If splitting_seed_consistent is proved using A4a in task 107, then task 115 becomes a REFACTORING task:
- Add left_mono_until_G for axiom system cleanliness
- Rewrite splitting to use Xu's simpler path
- Remove A4a (now redundant)
- Clean up BX2 (pointwise conjunct becomes derivable)
- Net improvement: simpler axiom system, simpler splitting proof

### 7.2 If Task 107 Gets Stuck on A4a

If the bidirectional seed consistency gap in splitting_seed_consistent proves intractable, task 115 becomes the UNBLOCKING path:
- Add left_mono_until_G
- Implement Xu Lemma 2.3 + 2.4 directly
- This avoids the seed consistency problem entirely
- A4a can be removed since it is no longer needed

### 7.3 Preferred Approach

The Xu path via left_mono_until_G is the PREFERRED approach for the following reasons:

1. **Simpler axiom**: left_mono_until_G has a transparent semantic justification (G-info covers open guard). A4a is more complex and less transparent.
2. **Simpler proof**: Xu Lemma 2.4 avoids the bidirectional seed problem. The consistency argument is trivial (extend a DCS by an element not in it).
3. **More natural for open-guard semantics**: left_mono_until_G directly captures the key semantic fact about open intervals. A4a is valid but does not directly correspond to a simple semantic principle.
4. **Makes BX2 redundant**: Adding left_mono_until_G subsumes BX2, simplifying the axiom system. A4a does not simplify any existing axiom.
5. **Lower risk**: The Xu approach has no identified open questions. The A4a approach has the h_content(C) gap documented in the Phase 5b handoff.

### 7.4 Dependency on Task 107

Task 115 should be sequenced AFTER task 107's current Phase 5b attempt, regardless of outcome:
- If 107 succeeds: task 115 refactors to the cleaner Xu path
- If 107 gets stuck: task 115 provides the alternative unblocking path
- In both cases, task 115 benefits from the infrastructure already built in task 107 (BX13, burgessR3Maximal_from_g_content_sub, etc.)

## 8. Implementation Outline (Task 115)

If task 115 proceeds:

**Phase 1**: Add left_mono_until_G / left_mono_since_H axiom constructors
- 2 constructors in Axioms.lean (~8 lines)
- Soundness proofs in Soundness.lean (~20 lines)
- Update all SoundnessLemmas.lean match arms (~20 locations)

**Phase 2**: Formalize Xu Lemma 2.3 in RRelation.lean
- Prove: R(A, B, C) implies S(alpha, top) in B for all alpha in A
- Prove: R(A, B, C) implies U(gamma, top) in B for all gamma in C
- Uses: BurgessR3Maximal_extension_fails + contradiction + left_mono_until_G + BX13

**Phase 3**: Formalize Xu Lemma 2.4 splitting in PointInsertion.lean
- Replace splitting_seed_consistent with Xu's DCS extension argument
- Keep lemma_2_6_splitting signature unchanged (same output type)
- Uses: Xu Lemma 2.3 + dcs_neg_union_consistent + burgessR3Maximal_from_g_content_sub

**Phase 4**: Remove A4a (separation_until / separation_since)
- Remove constructors from Axioms.lean
- Remove soundness proofs from Soundness.lean
- Remove match arms from SoundnessLemmas.lean
- Update documentation

**Phase 5**: Optionally simplify BX2
- left_mono_until_G subsumes BX2 (pointwise conjunct is redundant)
- Could remove BX2 and derive it as a theorem, or keep for backward compatibility

## References

- Burgess 1982: "Basic Tense Logic", Section 2 (Lemmas 2.4-2.8)
- Xu 1988: "On some U,S-tense logics", Section 2 (Lemmas 2.1-2.4)
- Task 107 plan v29: specs/107_chain_design_diagnostics_for_representation_theorem/plans/44_implementation-plan.md
- Task 107 handoff (Phase 5b blocker): specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/02_phase5b-blocker.md
- Task 107 handoff (seed consistency): specs/107_chain_design_diagnostics_for_representation_theorem/handoffs/02_phase5b-seed-consistency.md
- Task 107 report 44 (team research): specs/107_chain_design_diagnostics_for_representation_theorem/reports/44_team-research.md
