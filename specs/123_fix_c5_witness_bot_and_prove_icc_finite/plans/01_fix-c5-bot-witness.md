# Implementation Plan: Prove succ_embed_surjective and Complete Discrete Coherence

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [IN PROGRESS]
- **Effort**: 14-20 hours
- **Dependencies**: None (all prerequisite infrastructure exists)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_blocker-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_teammate-a-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/01_team-research-reynolds.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-a-burgess-paper.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-b-codebase-vs-paper.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-c-minimal-fix.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-d-limit-proof.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/03_alternative-architecture.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-a-findings.md (round 2)
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/02_teammate-c-findings.md (round 2)
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_cofinality-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_surjectivity-false-verification.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_collapse-bfmcs-design.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/handoffs/01_phase1-blocked.md
  - specs/122_build_discrete_bfmcs_and_complete_countermodel/reports/01_discrete-bfmcs-research.md (cross-task)
- **Artifacts**: plans/01_fix-c5-bot-witness.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

### Research Integration

Reports integrated in this revision (v3):
- **v2 reports** (carried forward): `02_teammate-a-burgess-paper.md`, `02_teammate-b-codebase-vs-paper.md`, `02_teammate-c-minimal-fix.md`, `02_teammate-d-limit-proof.md`, `03_alternative-architecture.md`, `01_phase1-blocked.md`, `01_discrete-bfmcs-research.md` (task 122).
- **NEW** `02_team-research.md` (round 2, 4-teammate synthesis): All 4 teammates confirmed `succ_embed_surjective` is TRUE. The "irrational limit" counterargument is wrong. Recommended proof path: single-orbit argument via existing collapse infrastructure (~80-150 lines). Stage induction fails because `Classical.choose` picks from the FULL limit_dom (future stages included), but the theorem is mathematically true.
- **NEW** `02_teammate-a-findings.md` (round 2): Detailed Icc finiteness argument. Infinite bounded discrete set in Q leads to accumulation in R; the accumulation point forces domain points between consecutive no-gap elements. Recommends: Icc finiteness -> cofinality -> surjectivity via squeeze.
- **NEW** `02_teammate-c-findings.md` (round 2, critic): Confirmed truth of surjectivity. Identified gap in report 06's proof sketch (assumes "smallest limit_dom point z > L" exists without proving the minimum). The correct argument is the single-orbit approach: show orbit is unbounded (cofinal), then apply squeeze. The orbit being bounded leads to the interleaving contradiction (pred-chain from w enters gap between consecutive orbit elements).
- **NEW** `05_cofinality-research.md`, `06_surjectivity-false-verification.md` (correct conclusion, circular proof), `07_collapse-bfmcs-design.md` (confirmed collapse approach not needed).

## Overview

Phases 1-3 and 5 are completed, establishing: (1) the collapse equivalence infrastructure, (2) `discrete_fmcs` via direct embedding, (3) the succ-based BFMCS infrastructure (`succ_embed`, `succ_discrete_fmcs`, `rooted_succ_discrete_fmcs`, `cantor_bfmcs_discrete`), and (5) the case split wiring in Completeness.lean.

Phase 4 (coherence) is structurally complete: BUC is sorry-free, and TC and FUC are fully proved EXCEPT that they invoke `succ_embed_surjective`, which has two remaining sorry sites (lines 2060 and 2063 of `ChronicleToCountermodel.lean`). The round-2 team research (4 teammates, all HIGH confidence) unanimously confirmed that `succ_embed_surjective` is TRUE and provable via the single-orbit argument. This revision replaces the old Phase 4 with a focused phase that proves surjectivity by establishing the orbit is cofinal (unbounded), which combines with the existing `succ_embed_squeeze` to close the sorry.

**Definition of done**: Close the two sorry sites in `succ_embed_surjective` (lines 2060, 2063), making `dd_countermodel_chronicle_discrete` sorry-free. The only remaining sorry in the chronicle files should be the mixed-case stub (`dd_countermodel_chronicle_mixed_sorry`).

## Goals & Non-Goals

**Goals:**
- Prove `succ_embed_surjective` by establishing that the succ-orbit of root is cofinal (unbounded) in `LimitDomSubtype`
- Close the two sorry sites at lines 2060 and 2063 of `ChronicleToCountermodel.lean`
- Make `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Modifying the omega-chain construction in `ChronicleConstruction.lean`
- Modifying BUC (already sorry-free)
- Solving the mixed case (`dd_countermodel_chronicle_mixed_sorry`)
- Modifying the dense case
- Proving `IsSuccArchimedean` or `LocallyFiniteOrder` as separate typeclass instances (these are stronger than needed)

## Risks & Mitigations

- **Risk: Formalizing the convergence/interleaving argument in Lean 4.** The mathematical argument requires showing that two bounded monotone sequences of rationals converging to the same limit L eventually interleave, placing a pred-chain element between consecutive orbit members.
  - Mitigation: Three concrete formalization strategies are available (see Phase 4 details). The simplest avoids real analysis entirely by using contradiction on a single pred step: if w is not in root's orbit and w > root, then pred(w) is not in root's orbit (by separation), so root's orbit is bounded above by pred(w). Repeating gives an infinite descending chain bounded below by the orbit, which by Icc finiteness (if provable) is impossible. Alternatively, bypass convergence entirely using a direct combinatorial argument on the omega-chain stages.

- **Risk: The Icc finiteness argument may be hard to formalize.** Showing that any bounded interval in `LimitDomSubtype` is finite requires either real analysis (completeness of R) or a combinatorial argument about the omega-chain construction.
  - Mitigation: The orbit-unboundedness approach may NOT require Icc finiteness as a separate lemma. Instead, one can prove orbit cofinality directly by contradiction: if the orbit is bounded, apply `collapse_orbit_bounded` to the bound, then analyze the pred-chain from the bound to get a contradiction via interleaving with the orbit. This avoids general Icc finiteness.

- **Risk: The "gap between L1 and L2" case (orbit limit differs from pred-chain limit).** Teammate C identified that the interleaving contradiction only fires cleanly when L1 = L2 (both sequences converge to the same real limit).
  - Mitigation: If L1 < L2, the gap (L1, L2) contains no domain points, which means `NoMaxOrder` applied to orbit elements near L1 would produce successors that must jump past L2 (since nothing is between), placing orbit elements above L2 and contradicting the bound. This secondary argument closes the L1 < L2 case.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Define the Collapse Equivalence and Quotient Map [COMPLETED]

**Goal:** Define an equivalence relation on `LimitDomSubtype` whose classes are the omega-chains, and prove it is a valid equivalence. Define `CollapseClass` as the quotient type with `LinearOrder`.

**Tasks:**
- [x] Define `collapse_equiv` using succ-orbit reachability
- [x] Prove `collapse_equiv` is reflexive, symmetric, transitive
- [x] Define `collapse_setoid` and `CollapseClass`
- [x] Prove `CollapseClass` has `LinearOrder`
- [x] Prove orbit convexity and class separation lemmas

**Timing:** 6-8 hours

**Depends on:** none

**Completed:** 2026-05-10

### Phase 2: Define FMCS on Z via Direct Embedding [COMPLETED]

**Goal:** Define `discrete_fmcs : FMCS Z` using the direct embedding approach, with forward_G and backward_H proved via `limit_forward_G`/`limit_backward_H`.

**Tasks:**
- [x] Define `embed_forward`, `embed_backward`, `discrete_embed`
- [x] Prove `discrete_embed` is strictly monotone
- [x] Define `discrete_f`, `discrete_fmcs`
- [x] Prove `discrete_f_at_zero` and `discrete_f_is_mcs`
- [x] Verify `lake build` compiles

**Timing:** 4-6 hours

**Depends on:** 1

**Completed:** 2026-05-10

### Phase 3: Succ-Based Embedding and Discrete BFMCS Infrastructure [COMPLETED]

**Goal:** Build the succ-based embedding, discrete BFMCS, and the full family bundle on Z mirroring `cantor_bfmcs_dense`.

**Tasks:**
- [x] Define `box_discrete_gives_discreteness`
- [x] Define `succ_embed` via `succ^n(root)` / `pred^|n|(root)`
- [x] Prove `succ_embed_strictMono`, `succ_embed_no_gap`
- [x] Define `succ_discrete_f`, `succ_discrete_fmcs`, `shifted_succ_discrete_fmcs`
- [x] Define `rooted_succ_discrete_fmcs` with `rooted_succ_discrete_fmcs_at_s`
- [x] Prove `box_stable_in_rooted_succ_discrete_fmcs`
- [x] Define `cantor_bfmcs_discrete : BFMCS Z` with `modal_forward` and `modal_backward`

**Timing:** 6-8 hours

**Depends on:** 1

**Completed:** 2026-05-10

### Phase 4: Prove succ_embed_surjective via Single-Orbit Argument [PARTIAL]

**Partial status**: BUC is sorry-free. TC and FUC are structurally complete but invoke `succ_embed_surjective`, which has sorry at lines 2060 and 2063 (the "above all old points" and "below all old points" subcases in the stage induction). This phase replaces the failing stage-induction proof with the single-orbit argument.

**Goal:** Prove `succ_embed_surjective` by showing every `LimitDomSubtype` element is in root's succ-orbit. The proof proceeds by contradiction: assume w is not in root's orbit, derive that root's orbit is bounded, then show a bounded orbit leads to contradiction via the interleaving/no-gap argument.

**Tasks:**

- [ ] **Step 1: Prove orbit cofinality (positive direction).** Define and prove `succ_orbit_cofinal_above`: for any `w : LimitDomSubtype`, there exists `n : Nat` with `succ_embed(n) >= w`. Proof by contradiction:
  - Assume `succ_embed(n) < w` for all `n : Nat` (orbit bounded above by w).
  - Case A: w is in root's orbit (collapse_equiv root w). Then w = succ^k(root) for some k, so succ_embed(k) = w, contradicting the bound assumption.
  - Case B: w is NOT in root's orbit. By `collapse_class_sep`, all orbit elements are strictly below w. Consider `pred(w)` (the immediate predecessor in LimitDomSubtype). Either pred(w) is in root's orbit (then succ(pred(w)) = w, so w is in the orbit -- contradiction with Case B), or pred(w) is also NOT in root's orbit and `succ_embed(n) < pred(w)` for all n (orbit bounded by pred(w) too).
  - Continue: `pred^k(w)` for all k is either in the orbit (giving contradiction) or bounds the orbit from above. This produces an infinite descending chain `w > pred(w) > pred^2(w) > ...` all above all orbit elements.
  - Now use the interleaving contradiction: the orbit `succ_embed(0) < succ_embed(1) < ...` increases toward the descending chain. Between any `succ_embed(n)` and `succ_embed(n+1)`, no domain points exist (`succ_embed_no_gap`). Between any `pred^k(w)` and `pred^(k-1)(w)`, no domain points exist (immediate predecessor property). Both sequences are bounded and monotone (one increasing, one decreasing), with all orbit elements below all pred-chain elements. For the contradiction: by `succ_embed_no_gap`, the gap `succ_embed(n+1).val - succ_embed(n).val` is the distance between consecutive domain-free intervals. Since the orbit is bounded above and strictly increasing in Q, the orbit values form a Cauchy sequence. Similarly the pred-chain values decrease. Eventually a pred-chain element falls between consecutive orbit elements, contradicting no-gap.
  - **Lean formalization strategy** (preferred, avoids real analysis): Use contradiction on `NoMaxOrder`. The orbit being bounded means all orbit elements are below w. But `NoMaxOrder` on `LimitDomSubtype` gives a domain point above any orbit element -- that point is `succ_embed(n+1)` (the immediate successor, which IS the next orbit element by definition of `limitDomSubtype_succ`). So `succ_embed(n+1) > succ_embed(n)` for all n, and the orbit is strictly increasing. The orbit being bounded above by w means `succ_embed(n) < w` for all n. Consider the element `succ(succ_embed(n))` -- this is `succ_embed(n+1)` by definition. We need: is `succ_embed(n)` eventually >= w? The answer relies on showing bounded infinite discrete sets cannot exist. The cleanest Lean approach: show `Set.Icc (succ_embed 0) w` has finitely many LimitDomSubtype elements (by the accumulation contradiction), then the orbit, being infinite and contained in this interval, gives contradiction.
  - **Alternative Lean formalization** (if Icc finiteness is hard): Use `Finset`-level reasoning on omega-chain stages. Every orbit element `succ_embed(n)` enters `limit_dom` at some finite stage `K(n)`. If the orbit is bounded above by w (which entered at stage K_w), then for all n, `succ_embed(n).val < w.val`. Since each stage adds finitely many points and the orbit values are strictly increasing rationals below `w.val`, the orbit elements are spread across infinitely many stages. But at each stage, the domain grows by at most a finite number of points. The key insight: at the stage when w is added, w.val > all orbit elements added so far. After that stage, `succ_embed(n)` for n beyond the orbit length at that stage will have values determined by future stages, but still below w.val. The contradiction comes from the fact that `succ(max_orbit_at_stage_K)` must be some domain point, and if it's below w, it must be an orbit point (by no-gap + squeeze). This eventually forces the orbit to reach w.

- [ ] **Step 2: Prove orbit cofinality (negative direction).** Define and prove `succ_orbit_cofinal_below`: for any `w : LimitDomSubtype`, there exists `n : Nat` with `succ_embed(-n) <= w`. Symmetric to Step 1 using `pred` instead of `succ`.

- [ ] **Step 3: Derive surjectivity from cofinality.** Replace the current proof body of `succ_embed_surjective` with:
  - Given `w : LimitDomSubtype`, obtain `n_hi` from `succ_orbit_cofinal_above` with `succ_embed(n_hi) >= w`.
  - Obtain `n_lo` from `succ_orbit_cofinal_below` with `succ_embed(n_lo) <= w`.
  - `succ_embed(n_lo) <= w <= succ_embed(n_hi)`, so by `succ_embed_squeeze`, `w = succ_embed(k)` for some `k` between `n_lo` and `n_hi`.

- [ ] **Step 4: Verify `lake build ChronicleToCountermodel` compiles sorry-free** (except the mixed-case stub).

**Detailed proof sketch for Step 1 (the core mathematical argument):**

The key lemma is `icc_limitdom_finite`: for any `a b : LimitDomSubtype` with `a <= b`, the set `{w : LimitDomSubtype | a <= w /\ w <= b}` is finite. We prove this by contradiction.

Assume the set is infinite. Extract an infinite strictly increasing sequence `c_0 < c_1 < c_2 < ...` all in `[a, b]`. Each `c_i` has value `c_i.val : Q` with `a.val <= c_i.val <= b.val`. Between consecutive `c_i` and `c_{i+1}`, there are no domain points (since `c_{i+1}` is the immediate successor of `c_i` -- WAIT, this is not guaranteed; the `c_i` need not be consecutive in `LimitDomSubtype`).

Correction: the `c_i` are an infinite subset of `[a,b]` in LimitDomSubtype. We need a different approach. Since LimitDomSubtype has a SuccOrder where each element has an immediate successor with no domain points between them, any two elements `c_i < c_{i+1}` have `succ(c_i) <= c_{i+1}`. So `c_{i+1} >= succ(c_i) > c_i`. The values `c_i.val` form a strictly increasing bounded sequence in Q.

Now use the Archimedean property of Q (or equivalently, the completeness of R): the sequence `c_i.val` has a supremum `L` in R with `L <= b.val`. For any `eps > 0`, eventually `c_i.val > L - eps`.

Pick any domain point `z` with `z.val > L` (exists because there are domain points above b, and b.val >= L). The immediate predecessor `pred(z)` satisfies `pred(z).val < z.val` with no domain points between. For large enough `i`, `c_i.val > pred(z).val` (since `c_i.val -> L` and we can find z close enough to L). Then `pred(z) < c_i < z` in LimitDomSubtype, contradicting no domain points between pred(z) and z.

If no domain point z with z.val > L and z.val close enough to L exists (i.e., the smallest domain point above L has predecessor value < L), then for large i, c_i is between that predecessor and z. If pred(z).val < L - delta for some delta, then we need c_i.val in (pred(z).val, z.val) and c_i being a domain point there. Since c_i.val -> L and pred(z).val < L < z.val, for large i, pred(z).val < c_i.val < z.val. This places c_i between pred(z) and z, contradicting no domain points between them.

The subtlety (identified by Teammate C) is that the "smallest domain point z > L" may not exist directly. However, we can avoid this by choosing z more carefully: take z = c_{i+1} for some large i. Then pred(c_{i+1}) is the immediate predecessor of c_{i+1}. For i large enough, pred(c_{i+1}) may or may not be c_i. If pred(c_{i+1}) = c_i, then c_{i+1} = succ(c_i), and the sequence is just following the successor chain. If all c_{i+1} = succ(c_i), then the c_i ARE the orbit starting from c_0, and the orbit is cofinal up to b. In this case, `succ_embed_squeeze` gives that any point in [c_0, b] is an orbit point of c_0, which (combined with collapse_equiv) means it's in root's orbit.

If at some point c_{i+1} > succ(c_i) (i.e., there's a domain point between c_i and c_{i+1} that we skipped), then we can refine the sequence. But an infinite subset of a discrete set (where between any consecutive pair nothing exists) in a bounded interval leads to the convergence contradiction above.

**Formalization approach (most promising for Lean 4):**

Rather than the general Icc finiteness, prove orbit cofinality directly:

```
theorem succ_orbit_cofinal_above (w : LimitDomSubtype) :
    ∃ n : Nat, w ≤ succ_embed n
```

Proof by contradiction. Assume `forall n, succ_embed n < w`. Then `w` is not in the orbit (since `succ_embed(k) < w` for all k). By `collapse_class_sep`, w's entire orbit is above root's entire orbit. Consider `pred(w)`: not in root's orbit (otherwise w = succ(pred(w)) would be, since pred(w) ~ root implies succ(pred(w)) ~ root... actually this needs care since collapse_equiv is defined by succ-reachability, not succ-closure of the equivalence class).

Actually the simplest proof structure for Lean may be:

1. Assume orbit bounded above by w (not in orbit).
2. Show `Set.Finite {x : LimitDomSubtype | succ_embed 0 ≤ x ∧ x ≤ w}` using the stage-counting argument: limit_dom is a union of finite stages. For the interval [root, w], at each stage only finitely many points are added. The total is countable but not obviously finite -- however, we need to show it IS finite by the accumulation argument.
3. The orbit gives infinitely many distinct elements in [root, w]. Contradiction with finiteness.

For step 2, the Lean proof would use: assume infinite, extract a strictly increasing subsequence (by BolzanoWeierstrass or manual extraction), show the subsequence converges in R (by Mathlib's `isLUB_csSup` or `tendsto_of_monotone_of_bddAbove`), then derive the predecessor contradiction.

**Mathlib lemmas likely needed:**
- `Rat.instArchimedean` or `Rat.denseRange_natCast`
- `Set.Finite` / `Set.Infinite` API
- `Monotone.tendsto_atTop_atTop` or `StrictMono.tendsto_atTop`
- Possibly `Real.isCauSeq_iff_tendsto` or `Filter.Tendsto`
- `Subtype.val_injective` for extracting Q values

**Estimated lines:** 80-150 lines for the cofinality proof, plus 10-20 lines to restructure `succ_embed_surjective` to use it.

**Timing:** 6-10 hours (the formalization of the convergence/accumulation argument is the main effort)

**Depends on:** 2, 3

### Phase 5: Case Split Refinement and Final Wiring [COMPLETED]

**Goal:** Wire `discrete_bfmcs` and its coherence proofs into `dd_countermodel_chronicle_discrete`, refine the case split in `Completeness.lean`, and reduce the nondense sorry to the mixed case only.

**Tasks:**
- [x] Define `dd_countermodel_chronicle_discrete`
- [x] Define `dd_countermodel_chronicle_mixed_sorry`
- [x] Modify `bx_completeness` with three-way case split
- [x] Verify `lake build` compiles

**Timing:** 3-4 hours

**Depends on:** 4

**Completed:** 2026-05-10

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phase 4
- [ ] `lake build Completeness` passes after Phase 4
- [ ] Full `lake build` passes
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only the mixed-case stub
- [ ] Grep for sorry in `Completeness.lean` shows only the mixed-case usage

## Artifacts & Outputs

- **Plan**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/01_fix-c5-bot-witness.md (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phase 4: replace sorry in `succ_embed_surjective`)
- **Summary**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/01_fix-c5-bot-summary.md

## Rollback/Contingency

Phase 4 modifies only the proof body of `succ_embed_surjective`. The theorem statement, all downstream definitions (TC, FUC, discrete countermodel), and all other phases are untouched. Reverting: restore the sorry at lines 2060 and 2063.

If the single-orbit argument proves too hard to formalize in Lean:
1. **Fallback A (stage-counting):** Instead of the convergence argument, prove Icc finiteness using a counting argument on omega-chain stages. Between any two domain points a < b, the number of domain points added at each stage is bounded by the number of counterexample eliminations in that interval. Since the counterexample enumeration is fixed and each formula is eliminated at most once per interval, the total is bounded.
2. **Fallback B (Nat.find):** If the orbit is bounded by w, use `Nat.find` to find the FIRST stage K where some domain point q >= w appears. At stage K-1, max_K-1 < w. At stage K, q >= w was added. By the stage-K IH, max_K-1 = succ_embed(j). Then q >= w > succ_embed(j), so q is in the "above max" case at stage K. If q = succ_embed(j+1), then succ_embed(j+1) >= w, contradicting the bound. This is essentially the original stage-induction approach but with a more carefully chosen stage K.
3. **Fallback C:** Leave the sorry and document it as a known formalization gap with a confirmed mathematical proof. The discrete case would be "sorry-free modulo succ_embed_surjective," with detailed documentation of why it's true.

## Critical Notes for Implementation

1. **Do NOT modify the stage-induction structure.** The current proof at lines 2008-2095 has the correct base case and "between old points" case. Only the two sorry sites (lines 2060, 2063) need to be filled. The preferred approach is to prove the cofinality lemma separately and use it to close these sorry sites, rather than rewriting the entire proof.

2. **The interleaving contradiction is the mathematical core.** All 4 teammates converged on this: if root's orbit is bounded above by w (not in the orbit), then pred(w), pred^2(w), ... are all above the orbit, and the two sequences (orbit ascending, pred-chain descending) eventually interleave, placing a pred-chain element between consecutive orbit elements, contradicting no-gap. The Lean formalization must capture this.

3. **Alternative to the full convergence argument:** Rather than proving the general real-analysis convergence, it may suffice to prove: if `succ_embed(n) < w` for all n, and `w` is not in root's orbit, then `succ(succ_embed(n)) = succ_embed(n+1) < w` for all n (from `collapse_orbit_bounded`). But also `pred(w) >= succ_embed(n+1)` for all n (from `collapse_class_sep` applied to pred(w), which is in w's orbit). So `succ_embed(n) < succ_embed(n+1) <= pred(w) < w` for all n. Now apply the same argument to pred(w): it bounds the orbit and is closer to the orbit. Iterate: `pred^k(w)` all bound the orbit. The pred-chain is infinite and strictly decreasing, all above the orbit. But between `pred^k(w)` and `pred^{k-1}(w)`, no domain points. And between `succ_embed(n)` and `succ_embed(n+1)`, no domain points. If eventually `pred^k(w) < succ_embed(n+1)` for some k, n, then `pred^k(w)` is between `succ_embed(n)` and `succ_embed(n+1)`, contradiction. The key claim is that such k, n exist. This may require the Archimedean property of Q or Icc finiteness.

4. **Restructuring the proof vs. adding lemmas.** The cleanest approach is:
   - Add `succ_orbit_cofinal_above` and `succ_orbit_cofinal_below` as separate lemmas before `succ_embed_surjective`.
   - Rewrite `succ_embed_surjective` to use these two lemmas + `succ_embed_squeeze`, abandoning the stage-induction approach entirely.
   - This is a DROP-IN replacement: the theorem statement is unchanged, only the proof body changes.
