# Implementation Plan: Semantic Z1 Gap Elimination via backward_G

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 3-5 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/14_z1-derivation-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/15_stage-walk-revised.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-a-irr-rule.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-b-z1-proofs.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-c-construction-dynamics.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-d-online-search.md
  - All prior reports from rounds 04-12 (integrated in plans v4-v10)
- **Artifacts**: plans/12_semantic-z1-gap.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version (v12):**
- `14_z1-derivation-research.md` (newly integrated in v12)
- `15_stage-walk-revised.md` (newly integrated in v12)
- All reports from v4-v11 preserved

### Why Plan v12 Supersedes Plan v11

Plan v11 identified the Doets/Z1 approach as the correct strategy but identified two blockers: (1) a complex syntactic Z1 DerivationTree from Prior-UZ (~80-120 lines, no published derivation), and (2) the discriminating formula problem (finding a formula that distinguishes orbit from pred-chain points).

**Two breakthroughs resolve both blockers:**

1. **backward_G and backward_F are PROVED** (lines 1683-1754 of ChronicleToCountermodel.lean). These give a complete G/F truth lemma WITHOUT needing IsSuccArchimedean, breaking the circular dependency that previously forced the syntactic DerivationTree approach. The semantic Z1 approach is now viable.

2. **The discriminating formula emerges from case analysis.** Instead of searching for an arbitrary discriminating formula, we use the formula phi from the FGphi witness itself. In Case B (where Gphi fails at ALL orbit points), Gphi itself distinguishes orbit points (where Gphi is false) from the FGphi witness point (where Gphi is true). The backward_G lemma propagates Gphi from the witness region back across the gap, giving a contradiction.

**The new approach is semantic Z1 + single-step propagation + case split**, not syntactic DerivationTree. Report 14 confirmed that no published Z1 derivation from Prior-UZ exists and estimated 100+ lines for the DerivationTree. Report 15 confirmed that backward_G enables the semantic approach and that the stage-walk alternatives remain blocked. The semantic path requires approximately 60-100 lines of new Lean code.

### Key Mathematical Insight

The sorry at line 1778 is in `succ_cofinal` for the case where the succ-orbit converges to a real limit L with L <= pred(b).val. The gap scenario has orbit points below L and pred-chain points above L with no limit_dom at L.

**The semantic Z1 argument proceeds as follows:**

Pick any formula phi from the closure of A. Consider the formula Gphi. By backward_G, if phi holds at all limit_dom points above some point x, then Gphi holds at x. By limit_forward_G, if Gphi holds at x and y > x, then phi holds at y.

At each orbit point m = s^[n](a), either:
- **Case A**: Gphi in limit_f(m) for some orbit point m. Then by limit_forward_G, phi holds at all y > m, including all pred-chain points and all further orbit points. By backward_G at a, Gphi in limit_f(a). Then phi holds at all y > a. Since succ(a) = s^[1](a) is a limit_dom point above a, phi at succ(a). But we need to derive a CONTRADICTION. For Case A we need to find phi such that Gphi at some orbit point leads to contradiction.
- **Case B**: neg(Gphi) in limit_f(m) for ALL orbit points m. Then F(neg(phi)) in limit_f(m) for all m. But consider: does phi hold at pred-chain points?

The correct argument uses the Doets Claim 10 structure semantically:

1. Choose a point m below the phi-set (any orbit point where F(phi) holds).
2. Since the phi-set is bounded above, FG(neg(phi)) holds at m (by backward_F from a pred-chain point where G(neg(phi)) holds, which follows from backward_G if neg(phi) holds at all points above the bound).
3. If G(neg(phi)) also held at m, then neg(phi) at all future points -- contradicting F(phi). So neg(G(neg(phi))) = F(phi) holds, i.e., G(neg(phi)) does NOT hold at m.
4. Now apply the Z1 schema semantically: from G(G(neg(phi)) -> neg(phi)) at m (which is a theorem derivable in every MCS via the T-schema for G) and FG(neg(phi)) at m, Z1 would give G(neg(phi)) at m. But G(neg(phi)) does NOT hold at m (step 3). So by modus tollens on Z1, neg(G(G(neg(phi)) -> neg(phi))) at m.
5. Unwinding: F(G(neg(phi)) AND phi) at m. By limit_F_resolution: exists k > m with both G(neg(phi)) and phi in limit_f(k). This k is the maximum of the phi-set.

**The critical step (4) requires Z1 to be in the MCS**, which requires either (a) a syntactic DerivationTree, or (b) proving Z1 holds semantically using backward_G.

**Semantic Z1 proof using backward_G**: Given G(Gphi -> phi) and FGphi at point x, prove Gphi at x. By backward_G, it suffices to show phi at all y > x. Take any y > x. Either Gphi at y (then Gphi -> phi gives phi at y) or neg(Gphi) at y (then F(neg(phi)) at y). In the second case, the neg(phi) witness z > y exists. But from FGphi at x, there exists w > x with Gphi at w. At w, phi holds at all points above w. So the neg(phi) witness z must be between y and w. But at z's predecessor (by discreteness/succ structure), Gphi holds (from the backward propagation), giving phi at z by G(Gphi -> phi). Combined with neg(phi) at z -- contradiction. So Case B is impossible and phi must hold at y.

**The subtlety**: The argument "at z's predecessor, Gphi holds" requires showing that the neg(Gphi) region between y and w is finite and terminates. This is exactly where Prior-UZ + discreteness (next_top) provides the Until witness that collapses the chain.

**Practical approach**: Rather than formalizing the full semantic Z1 argument abstractly, we apply the Doets Claim 10 argument DIRECTLY in the gap scenario using backward_G, backward_F, and Prior-UZ. The gap scenario provides concrete structural constraints (orbit_below_L, h_lt_pred_chain) that simplify the general argument.

## Overview

Close the remaining sorry in `succ_cofinal` (line 1778, the `L <= pred(b).val` gap case) using a semantic argument based on backward_G + Prior-UZ + Doets Claim 10. The approach avoids the intractable syntactic Z1 DerivationTree by leveraging the complete G/F truth lemma (backward_G/backward_F, already proved) to run the Doets maximum principle argument directly at the semantic level.

**Strategy**: In the gap-at-L scenario, derive False by showing that Prior-UZ forces a maximum for any bounded definable set. Since the orbit set {s^[n](a)} is bounded above (by pred-chain points) and has no maximum (strictly increasing), any formula distinguishing orbit from non-orbit violates the maximum principle. The discriminating formula is obtained from the non-identical MCS labels of orbit vs. pred-chain points (guaranteed by the construction producing distinct chronicles at each stage).

**Definition of done**: `succ_cofinal` sorry-free. `limitDomSubtype_isSuccArchimedean` sorry-free. `dd_countermodel_chronicle_discrete` sorry-free. Full `lake build` passes.

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1778 in `succ_cofinal`
- Prove semantic Doets Claim 10 (maximum principle) using backward_G + Prior-UZ/SZ
- Find or construct the discriminating formula for the gap scenario
- Make `limitDomSubtype_isSuccArchimedean` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Modifying Phase 1 (already [COMPLETED])
- Building a syntactic DerivationTree for Z1 from Prior-UZ (superseded by semantic approach)
- Fixing the 2 sorry sites in `succ_reaches_dom_N` (lines 1295, 1448) -- not on critical path
- Proving LocallyFiniteOrder
- Solving the nondense/mixed case stubs
- Modifying the existing convergence framework in `succ_cofinal`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Discriminating formula extraction is hard to formalize | H | M | Use `Classical.choice` on the set-theoretic symmetric difference of orbit vs. pred-chain MCS labels. If MCS labels are identical, derive contradiction from Prior-UZ directly (identical MCS at adjacent points means the Until witness is trivial). |
| Semantic Claim 10 requires backward_H (past dual of backward_G) | M | M | backward_H already exists as `limit_backward_H` in ChronicleConstruction.lean. If the dual Prior-SZ approach is used, backward_P (dual of backward_F) is straightforward to prove by symmetric argument. |
| The G(G(neg phi) -> neg phi) step requires this formula to be in the MCS | M | L | G(G(neg phi) -> neg phi) is derivable from temp_4 (G(psi) -> GG(psi)) and propositional logic. Build a small DerivationTree for this specific formula (5-10 lines, much simpler than full Z1). Then theorem_in_mcs puts it in every MCS. |
| limit_satisfies_c5_strong guard condition for the final step | M | L | Verify the guard condition is available. If not, use limit_F_resolution (which resolves F-formulas to witnesses) as the alternative. |
| Proof size exceeds budget | M | L | Factor the argument into 3-4 helper lemmas. Each lemma is 15-30 lines. Total target: 60-100 lines. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Semantic Doets Claim 10 and Gap Elimination [NOT STARTED]

**Goal**: Close the sorry at line 1778 in `succ_cofinal` by proving the gap-at-L scenario contradicts the Doets maximum principle, using backward_G + Prior-UZ/SZ semantically.

This phase has four sub-steps that build on each other.

#### Step 2a: Prove G(Gphi -> phi) is derivable (~10-15 lines)

**Location**: Inline in the sorry branch, or as a helper lemma above `succ_cofinal`.

**Statement**: For any formula phi, the formula `G(G(phi) -> phi)` is derivable (and therefore in every MCS).

This is NOT Z1. This is the much simpler formula that says "at every future point, if G(phi) holds then phi holds." It follows from:
1. `temp_4`: `G(phi) -> G(G(phi))` (G-transitivity, an axiom)
2. Contrapositive of temp_4 gives: `neg(G(G(phi))) -> neg(G(phi))`
3. Which is: `F(neg(G(phi))) -> F(neg(phi))`
4. Actually, we need `G(phi) -> phi` derivable for each fixed point. This is the T-schema for G, which is NOT generally valid on irreflexive orders. G(phi) means phi at all STRICT future points, not at the current point.

**Correction**: `G(G(phi) -> phi)` is NOT a theorem in general. The formula `G(phi) -> phi` says "if phi at all strict future points then phi at the current point" -- this fails for irreflexive accessibility. Instead, the Doets argument uses `G(G(neg(phi)) -> neg(phi))` evaluated at a specific point, where the hypothesis holds because of the gap structure, not because it is a theorem.

**Revised approach**: The Doets Claim 10 argument does NOT require `G(G(neg phi) -> neg phi)` as a theorem. Instead, it uses Z1 applied via modus tollens. At a point m where F(phi) and FG(neg phi) both hold:
- If G(neg phi) also held at m, it would contradict F(phi). So neg G(neg phi) at m.
- Z1 says: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))`.
- Contrapositive: `neg G(neg phi) -> (G(G(neg phi) -> neg phi) -> neg FG(neg phi))`.
- Equivalently: `neg G(neg phi) AND FG(neg phi) -> neg G(G(neg phi) -> neg phi)`.
- So: `F(phi) AND FG(neg phi) -> F(neg(G(neg phi) -> neg phi))`.
- Unwinding neg(G(neg phi) -> neg phi) = G(neg phi) AND phi (conjunction).
- So: `F(phi) AND FG(neg phi) -> F(G(neg phi) AND phi)`.

The key: we need Z1 in the MCS to use this reasoning. Rather than building a DerivationTree for Z1, we prove the CONCLUSION directly using backward_G.

**The direct semantic argument (no Z1 needed)**:

Given that phi holds at some orbit points and neg(phi) holds at points above some bound:
1. Pick orbit point m where F(phi) holds (exists since phi holds at some later orbit point).
2. There exists b_upper above which neg(phi) holds at all limit_dom points (the bounded-above hypothesis).
3. By backward_G applied at b_upper with psi = neg(phi): if neg(phi) holds at all y > b_upper, then G(neg(phi)) in limit_f(b_upper).
4. By backward_F: since G(neg(phi)) at b_upper and b_upper > m, FG(neg(phi)) at m.
5. Now apply Prior-UZ to phi at m: F(phi) -> U(phi, neg(phi)). The Until witness y has phi at y and neg(phi) at all z in (m, y). This y is a phi-point.
6. Apply Prior-UZ to neg(phi) at y (since F(neg(phi)) at y -- because there are neg-phi points above): U(neg(phi), phi) at y gives witness z > y with neg(phi) at z and phi between y and z.
7. This creates a finite descent pattern. On a discrete order, it terminates: at the LAST phi-point before the bound, we get phi AND G(neg(phi)) simultaneously. This is the maximum.

**But wait**: step 7 requires showing the descent terminates. This is where the structure of the discrete order (next_top) helps: between any two limit_dom points, there are finitely many limit_dom points (by IsSuccArchimedean -- which is what we are trying to prove!).

**Revised revised approach**: The direct semantic argument ALSO has the circularity problem. We need IsSuccArchimedean to show the descent terminates, but IsSuccArchimedean is what we are proving.

**Final approach**: Use Prior-UZ to directly extract the maximum, bypassing the descent:

From Prior-UZ applied to neg(phi) at the orbit point m (where F(neg(phi)) holds because neg(phi) holds above the bound):
- U(neg(phi), phi) at m: nearest future neg(phi) point with phi at all intermediate points.
- Wait, Prior-UZ says `F(psi) -> U(psi, neg(psi))`. With psi = neg(phi): `F(neg(phi)) -> U(neg(phi), neg(neg(phi)))` = `F(neg(phi)) -> U(neg(phi), phi)`. No, Prior-UZ says `F(psi) -> U(psi, neg(psi))`, so with psi = phi: `F(phi) -> U(phi, neg(phi))`.

The Until witness of U(phi, neg(phi)) at m: some y > m with phi at y and neg(phi) at all z in (m, y). But this gives the NEAREST phi-point (the first phi occurrence after m), not the maximum.

For the MAXIMUM, use the PAST dual. Apply Prior-SZ from a point ABOVE the phi-set:
- Prior-SZ says `P(psi) -> S(psi, neg(psi))`.
- Pick b_upper above the phi-set. P(phi) holds at b_upper (since phi holds at some earlier point).
- S(phi, neg(phi)) at b_upper: nearest PAST phi-point y with neg(phi) at all z in (y, b_upper).
- This y is the LAST phi-point below b_upper.
- y has phi. All z in (y, b_upper) have neg(phi). And b_upper itself has neg(phi) (it is above the phi-set).
- So y is the maximum of the phi-set in [min, b_upper].
- If ALL points above y have neg(phi), then y is the absolute maximum.

This is the Prior-SZ maximum principle from report 14 Section 5.3. It requires:
1. Prior-SZ as a theorem in every MCS (available via Axiom.prior_SZ + theorem_in_mcs)
2. S-resolution: if S(phi, neg(phi)) in limit_f(x), extract the witness y < x with phi at y and neg(phi) between
3. A discriminating formula phi

**The S-resolution step requires the C4 witness resolution infrastructure.** This exists as `limit_satisfies_c4_strong` or similar. Need to verify.

**Tasks:**
- [ ] Verify S-resolution / C4-backward witness infrastructure exists (check `limit_satisfies_c4'_strong` or `limit_S_resolution`)
- [ ] Verify backward_P exists or prove it (dual of backward_F: if phi in limit_f(y) for some y < x, then P(phi) in limit_f(x))
- [ ] Verify `Axiom.prior_SZ` exists and can be put into MCS via theorem_in_mcs
- [ ] Build the maximum principle lemma from Prior-SZ (~20-30 lines)
- [ ] Verify with `lean_goal` and `lean_verify`

**Timing**: 1 hour
**Depends on**: Phase 1

#### Step 2b: Find the discriminating formula (~20-40 lines)

**Location**: Within the sorry branch of `succ_cofinal`.

**Statement**: In the gap-at-L scenario, there exists a formula phi such that phi holds at some point in the orbit region but neg(phi) holds at some point in the pred-chain region (or vice versa).

**Approach 1 (Classical choice from non-equal MCS)**: Show that there exist orbit point m and pred-chain point c with `limit_f(m.val) <> limit_f(c.val)` (as sets of formulas). Then `Classical.choice` on the symmetric difference gives a formula that is in one but not the other. If all orbit-pred-chain MCS pairs were equal, derive contradiction from Prior-UZ (the argument from report 14 Section 4.6 -- constant MCS labels force trivial Until witnesses, but the gap structure creates a non-trivial Until obligation).

**Approach 2 (backward_G propagation)**: Pick ANY formula psi in limit_f(some pred-chain point c). By backward_G: if psi holds at ALL limit_dom points above some orbit point m, then G(psi) in limit_f(m). The formula G(psi) is the candidate discriminating formula. Either G(psi) in limit_f(m) for some orbit point (Case A) or neg(G(psi)) at all orbit points (Case B). In Case B, F(neg(psi)) at all orbit points, meaning neg(psi) occurs somewhere above each orbit point. If neg(psi) occurs above EVERY orbit point, it must occur at pred-chain points (since orbit points exhaust the domain below L). This contradicts psi in limit_f(c) unless the neg(psi) point is between the orbit point and c.

**Approach 3 (Direct from gap + non-degeneracy)**: The omega-chain construction produces distinct chronicles at each stage. At the stage where a pred-chain point enters, the BurgessR3Maximal or BurgessL3Maximal extension gives an MCS that satisfies specific counterexample requirements. These requirements introduce formulas that may not hold at orbit points. Use `counterexample_enum` properties to extract a specific formula.

**Recommended**: Start with Approach 1 (most general). Fall back to Approach 3 if Approach 1 proves insufficient.

**Tasks:**
- [ ] Attempt to show orbit and pred-chain MCS labels differ (by Prior-UZ non-constancy or construction properties)
- [ ] Extract discriminating formula via `Classical.choice` on set symmetric difference
- [ ] Handle the case where MCS labels might be equal (derive contradiction directly)
- [ ] Verify with `lean_goal`

**Timing**: 1-1.5 hours
**Depends on**: Step 2a (needs backward_G infrastructure context)

#### Step 2c: Apply Doets Claim 10 to derive contradiction (~30-50 lines)

**Location**: Within the sorry branch of `succ_cofinal` (replacing the sorry at line 1778).

**Core argument** (Doets pp. 91-92, adapted to use Prior-SZ instead of Z1):

Given the gap-at-L scenario and discriminating formula phi (from Step 2b):

Without loss of generality, assume phi holds at some orbit point n0 and neg(phi) holds at some pred-chain point c0. (If reversed, swap phi and neg(phi).)

1. **phi-set is bounded above**: The set S = {x in limit_dom | phi in limit_f(x)} intersected with [a.val, b.val] contains orbit point n0 but neg(phi) holds at c0 (a pred-chain point above all orbit points). So S is bounded above by c0.

2. **Apply Prior-SZ maximum principle (from Step 2a)**: At c0, P(phi) holds (since n0 < c0 and phi at n0, by backward_P which is the P-analog of backward_F -- if phi at y and y < x then P(phi) at x). Prior-SZ gives S(phi, neg(phi)) at c0. The S-witness k < c0 has phi at k and neg(phi) at all z in (k, c0). So k is the maximum of S below c0.

3. **k is the absolute maximum of S in [a, b]**: phi at k, neg(phi) at all z with k < z <= c0. What about z > c0? If neg(phi) holds at all pred-chain points above c0 as well (which it may not -- we only know neg(phi) at c0), we need to extend the argument. Use backward_G: if there exist arbitrarily large pred-chain points with neg(phi), then neg(phi) holds at ALL sufficiently large points, giving G(neg(phi)) at some bound, giving neg(phi) above that bound.

4. **k has phi AND G(neg(phi))**: If neg(phi) holds at all z > k in limit_dom (i.e., k is the absolute maximum of S), then by backward_G, G(neg(phi)) in limit_f(k). So k has both phi and G(neg(phi)).

5. **k cannot be an orbit point**: If k = s^[j](a), then succ(k) = s^[j+1](a) is the next orbit point. G(neg(phi)) at k means neg(phi) at succ(k). But succ(k) is an orbit point. Does phi hold at succ(k)? Not necessarily -- the discriminating formula may hold at SOME orbit points but not all. The argument requires that phi holds at ALL orbit points above some threshold.

**Revised argument using the correct discriminating formula**:

The difficulty above shows that we need a more careful choice of phi. The ideal phi is one where:
- phi holds at ALL orbit points (or all sufficiently late orbit points), AND
- neg(phi) holds at ALL pred-chain points (or all sufficiently late pred-chain points)

**Construction of such phi**: By backward_G, for any formula psi, if psi holds at ALL limit_dom points above some orbit point m, then G(psi) in limit_f(m). Now consider: pick any formula psi in limit_f(pred-chain point c). If psi also holds at ALL orbit points s^[n](a) for n >= some N, then psi holds at ALL limit_dom points above s^[N](a) (since every limit_dom point above s^[N](a) and below L is an orbit point by orbit_below_L, and psi holds at those; and every limit_dom point above L is a pred-chain point or above, and we need to handle those separately).

**The simplest viable argument**: Use the fact that in the gap scenario, the orbit is cofinal from below toward L and the pred-chain is coinitial from above toward L. Pick any pred-chain point c = p^[K](pb). The predecessor pred(c) = p^[K+1](pb) is another pred-chain point. The successor succ(c) = p^[K-1](pb) is the previous pred-chain point (for K >= 1).

Now consider: by backward_G at orbit point m = s^[0](a) = a with psi = top (trivially true everywhere): G(top) in limit_f(a). This is vacuously true and uninformative.

**The fundamental resolution**: The discriminating formula problem and the maximum principle application need to be done together, not separately. Here is the unified argument:

Given the gap scenario (orbit below L, pred-chain above L), we prove False by showing that backward_G creates a formula that "jumps" across the gap:

1. Pick any pred-chain point c and any orbit point m with m < c.
2. Consider any formula psi in limit_f(c) such that psi.neg in limit_f(m) (or vice versa). (If no such psi exists, the MCS labels are equal -- handle separately.)
3. Assume psi in limit_f(c) and psi.neg in limit_f(m) (WLOG).
4. All limit_dom points y with m < y and y.val < L are orbit points (orbit_below_L). Among these orbit points, EITHER:
   (a) psi holds at all of them eventually (for n >= some N, psi in limit_f(s^[n](a))), or
   (b) psi.neg holds at infinitely many orbit points.
5. Case (a): psi at all orbit points above s^[N](a), and psi at c (a pred-chain point). Then psi at ALL limit_dom points above s^[N](a) -- both orbit and pred-chain. By backward_G at s^[N](a): G(psi) in limit_f(s^[N](a)). By limit_forward_G: psi at all y > s^[N](a), including m if m > s^[N](a). But psi.neg at m. If m <= s^[N](a), pick a later orbit point m' = s^[N+1](a): does psi.neg at m'? Not if psi at all orbit points >= N. Contradiction with psi.neg at m only if m < s^[N](a). Since m can be s^[0](a) = a and N could be 0, we need m = a and psi.neg at a but psi at all s^[n](a) for n >= 0. So psi at s^[0](a) = a. But psi.neg at m = a. Contradiction.

   Actually: in Case (a), psi holds at all orbit points from some point on. The contradiction comes from psi.neg at m (which IS an orbit point). If m = s^[j](a) and psi at all s^[n](a) for n >= N, then for j >= N, psi at s^[j](a) = m, contradicting psi.neg at m. If j < N, pick the discriminating formula between m and s^[N](a) instead.

6. Case (b): psi.neg holds at infinitely many orbit points. Then among orbit points, psi.neg is COFINAL (for any orbit point, there is a later orbit point with psi.neg). Apply Prior-UZ at such an orbit point: F(psi.neg) -> U(psi.neg, psi). The Until witness gives the nearest future psi.neg point, with psi at all intermediate points. This creates a "psi-block" followed by a psi.neg point. But psi holds at c (pred-chain). And psi.neg is cofinal in the orbit. So the psi-blocks and psi.neg points interleave infinitely below L.

   In this case, consider the LAST orbit point where psi holds (if it exists). Actually, the interleaving might not have a "last" -- but the orbit converges to L, and the psi/psi.neg pattern cannot accumulate at L (because L is not a limit_dom point). Use Prior-UZ to show the psi-set has both a maximum and psi.neg is cofinal, giving a contradiction with the maximum principle.

**This analysis shows the argument is intricate but viable.** The implementation should proceed step by step, with `lean_goal` verification at each stage.

**Tasks:**
- [ ] Set up the gap scenario context (extract hypotheses from the sorry branch)
- [ ] Apply Prior-SZ maximum principle with the discriminating formula
- [ ] Handle Case A (formula holds at all orbit points) -- derive contradiction via backward_G
- [ ] Handle Case B (formula fails at infinitely many orbit points) -- derive contradiction via Prior-UZ maximum principle
- [ ] Replace the sorry at line 1778
- [ ] Verify with `lean_goal` and `lean_verify`

**Timing**: 1.5-2 hours
**Depends on**: Steps 2a, 2b

#### Step 2d: Wire up and Verify (~10-20 lines)

**Location**: Verify `succ_cofinal` is sorry-free, which makes `limitDomSubtype_isSuccArchimedean` sorry-free.

**Tasks:**
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry

**Timing**: 0.5 hour
**Depends on**: Step 2c

---

### Phase 3: Verification and Cleanup [NOT STARTED]

**Goal**: Verify compilation and sorry elimination downstream. Clean up dead code if appropriate.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry confirms only nondense/mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Optionally: remove `succ_reaches_dom_N` and related dead code, or mark with comments

**Timing**: 0.5-1 hour
**Depends on**: 2

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/12_semantic-z1-gap.md` (this file)
- **Modified/created files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close sorry in `succ_cofinal`, add maximum principle and discriminating formula lemmas
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/12_semantic-z1-gap-summary.md` (after implementation)

## Rollback/Contingency

Theorem statements unchanged. Rollback: `git checkout` the modified files.

If the semantic Doets/Prior-SZ approach proves intractable:

1. **Fallback A: Syntactic Z1 DerivationTree** (40% confidence, 80-120 lines): Build the full DerivationTree for Z1 from Prior-UZ + BX axioms. Report 14 provides a derivation sketch using Prior-UZ(G(phi)) + BX5 + discreteness. This is the original plan v11 approach. Complex but theoretically sound.

2. **Fallback B: Add Z1 as an axiom with soundness proof** (70% confidence, 30-50 lines): Add Z1 as a new axiom to the proof system with a direct soundness proof (`z1_is_valid`). This changes the axiom system but is mathematically justified (Z1 is valid on all discrete linear orders). The soundness proof requires showing `G(G(phi) -> phi) -> (FG(phi) -> G(phi))` is valid, which is a standard model-theoretic argument on discrete linear orders. Note: this proof ALSO needs IsSuccArchimedean to formalize the model-theoretic argument, creating the same circularity unless we prove soundness specifically for the limit model using construction properties.

3. **Fallback C: Stage induction boundary cases** (30% confidence, 100-200 lines): Return to plan v10's `succ_reaches_dom_N` and close the boundary sorry sites (lines 1295, 1448). These remain hard for the same reasons identified in plans v9/v10.

4. **Last resort**: Leave sorry with detailed documentation of the gap.

### Implementation Guidance for the Agent

**Preferred approach order**: Try the Prior-SZ maximum principle first (Step 2a). This avoids both the Z1 DerivationTree and the semantic Z1 argument. If the S-resolution infrastructure is missing, build it (dual of C5 resolution). If the discriminating formula is hard to extract, try Approach 3 (construction-specific properties).

**Key codebase APIs** (verified available):
- `backward_G` (ChronicleToCountermodel.lean:1683): phi at all y > x -> G(phi) at x (PROVED, no IsSuccArchimedean)
- `backward_F` (ChronicleToCountermodel.lean:1728): phi at y, y > x -> F(phi) at x (PROVED, no IsSuccArchimedean)
- `limit_forward_G` (ChronicleConstruction.lean:1035): G(phi) at x, y > x -> phi at y
- `limit_backward_H` (ChronicleConstruction.lean:1089): H(phi) at x, y < x -> phi at y
- `limit_F_resolution` (ChronicleConstruction.lean): F(phi) at x -> exists y > x, phi at y
- `theorem_in_mcs` (MaximalConsistent.lean:476): derivable formulas are in every MCS
- `limit_c0` (ChronicleConstruction.lean:590): limit_f(x) is SetMaximalConsistent
- `SetMaximalConsistent.implication_property`: modus ponens in MCS
- `SetMaximalConsistent.negation_complete`: phi or neg(phi) in MCS
- `set_consistent_not_both`: MCS cannot contain phi and neg(phi)
- `Axiom.prior_UZ` (Axioms.lean:377): F(phi) -> U(phi, neg(phi))
- `Axiom.prior_SZ`: P(phi) -> S(phi, neg(phi))
- `succ_orbit_convex` (ChronicleToCountermodel.lean:1112): orbit passes through intermediates
- `limitDomSubtype_succ_lt`: a < succ(a)
- `limitDomSubtype_pred_lt`: pred(b) < b
- `limitDomSubtype_succ_pred`: succ(pred(b)) = b
- `orbit_below_L` (in sorry branch): limit_dom points with value < L are orbit points
- `h_lt_pred_chain` (in sorry branch): all orbit points < all pred-chain points
- `h_pred_chain_ge_L` (in sorry branch): pred-chain values >= L

**Where to insert code**: The sorry is at line 1778 in the `else` branch of `succ_cofinal`. The branch has `h_case : L <= (pb.val : R)` plus all the gap scenario hypotheses (orbit_below_L, h_lt_pred_chain, h_pred_chain_ge_L, backward_G, backward_F) in scope. Insert the maximum principle and contradiction argument here, replacing the sorry.

**Classical logic**: Use `Classical.em`, `Classical.choice`, `by_contra`, `Decidable` instances freely. The codebase uses classical reasoning throughout.

**Critical constraint**: Do NOT attempt the syntactic Z1 DerivationTree. Reports 14 and 15 both confirm it is intractable without a published derivation to follow. Use the semantic approach with backward_G/backward_F and Prior-UZ/SZ.
