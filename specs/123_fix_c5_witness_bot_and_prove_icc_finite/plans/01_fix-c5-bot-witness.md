# Implementation Plan: Discrete BFMCS Construction and Coherence on Z

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [IN PROGRESS]
- **Effort**: 18-25 hours
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
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/handoffs/01_phase1-blocked.md
  - specs/122_build_discrete_bfmcs_and_complete_countermodel/reports/01_discrete-bfmcs-research.md (cross-task)
- **Artifacts**: plans/01_fix-c5-bot-witness.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

### Research Integration

Reports integrated in this revision (v2):
- `02_teammate-a-burgess-paper.md`: Confirmed Burgess's construction IS correct and produces infinite midpoint chains for U(T,bot) by design. Lemma 2.7 with eta=bot produces inconsistent B' (contains bot) on the left side; B'' on the right remains consistent.
- `02_teammate-b-codebase-vs-paper.md`: The ProofChecker's omega chain FAITHFULLY implements Burgess 1982. The deviation is downstream: Burgess never needs Z-isomorphism; the ProofChecker does because AddCommGroup D forces D = Z.
- `02_teammate-c-minimal-fix.md`: Ranked strategies. The "weaken EliminationResult" approach (previous plan) FAILED. Recommended post-construction quotient (Strategy 6) as most viable.
- `02_teammate-d-limit-proof.md`: limit_satisfies_c5_strong ALREADY works correctly for xi=bot. The infinite chain does NOT break C5 satisfaction. Problem is solely Icc_finite / IsSuccArchimedean being false.
- `03_alternative-architecture.md`: AddCommGroup is genuinely structural (MF/TF soundness). The countermodel MUST live on Z. No shortcut exists.
- `01_phase1-blocked.md`: Documents the failed Phase 1 attempt. The right disjunct approach cannot provide bot in limit_f(w) for future-stage points.
- **NEW** `01_discrete-bfmcs-research.md` (task 122, cross-task): Identifies three sub-cases (purely discrete, mixed-from-A, dense-locally-discrete-elsewhere). The purely discrete case (`box(U(T,bot)) in A`) is feasible on Z. The mixed case (`not box(F'T) and not box(U(T,bot))`) is genuinely open and cannot use D=Q or D=Z for all families simultaneously. Recommends refining the case split and deferring the mixed case. Identifies that `discrete_embed` is NOT surjective and the three restricted coherence conditions are the main challenge.

## Overview

Task 123's original Phases 1, 2, and 5 were completed, establishing: (1) the collapse equivalence relation infrastructure on LimitDomSubtype, (2) `discrete_fmcs : FMCS Z` with forward_G/backward_H via a direct (non-surjective) embedding, and (5) cleanup of deprecated code paths.

Phases 3 and 4 (Until/Since coherence on Z, BFMCS construction) were NEVER implemented -- they were incorrectly marked [COMPLETED] when the implementation agent assessed them as "task 122 scope." This revision replaces those phases with a revised plan informed by the task 122 research, which clarified that:

- The current `discrete_embed` is too weak for coherence: witnesses from `limit_satisfies_c5_strong` etc. land on arbitrary limit domain points NOT in the image of the embedding.
- A surjection (or at minimum an embedding aligned with the successor structure) is required for coherence proofs.
- The nondense case covers both purely discrete (`box(U(T,bot)) in A`) and mixed sub-cases; the mixed case is genuinely open.
- The recommended approach is to handle the purely discrete case on Z and leave the mixed case as a more focused sorry.

**Definition of done**: Produce `dd_countermodel_chronicle_discrete` on Z for the purely discrete sub-case (`box(U(T,bot)) in A`), refine the case split in `bx_completeness`, and reduce the nondense sorry to cover only the mixed case.

## Goals & Non-Goals

**Goals:**
- Define `box_discrete_gives_discreteness` (mirror of `box_dense_gives_density`)
- Build the discrete BFMCS: shifted FMCS, rooted FMCS, box stability, family bundle on Z
- Prove the three restricted coherence conditions on Z (temporal, backward Until/Since, forward Until/Since)
- Wire everything into `dd_countermodel_chronicle_discrete`
- Refine the case split in `Completeness.lean` to separate purely discrete from mixed
- Reduce the remaining sorry from the full nondense case to just the mixed case

**Non-Goals:**
- Solving the mixed case (`not box(F'T) and not box(U(T,bot))`)
- Modifying the omega chain construction in `ChronicleConstruction.lean`
- Modifying `CounterexampleElimination.lean`
- Modifying the dense case (already sorry-free)
- Proving the collapse quotient is isomorphic to Z (the direct embedding is retained)

## Risks & Mitigations

- **Risk: The non-surjective embedding breaks coherence proofs.** The current `discrete_embed` picks arbitrary increasing points via `exists_gt`, so witnesses from `limit_F_resolution`, `limit_satisfies_c5_strong`, etc. land on arbitrary limit domain points NOT in the embedding image.
  - Mitigation: Replace `discrete_embed` with a succ-based embedding that maps `n : Z` to `succ^n(root)` for positive n and `pred^|n|(root)` for negative n. When `box(U(T,bot)) in A`, all domain points have `U(T,bot)`, so `limitDomSubtype_succ` gives deterministic successors. Witnesses from C5 for `U(T,bot)` are immediate successors, which ARE in the embedding image.

- **Risk: Forward Until/Since coherence for general formulas (not just U(T,bot)).** Even with a succ-based embedding, the C5 witness for a general Until formula `U(phi, psi)` may land between two embedded points.
  - Mitigation: For the purely discrete case, U(T,bot) holds everywhere, meaning every domain point has an immediate successor (no points between). The C5 guard quantifies over points BETWEEN the source and witness. Since the succ-based embedding covers ALL points reachable by succ/pred iteration, and between any two successive embedded points there are no limit domain points (by the discrete property), the guard is either vacuously satisfied or can be verified point-by-point.

- **Risk: Proving `IsSuccArchimedean` on `LimitDomSubtype` to justify the succ-based embedding covering all points.** The original plan identified this as hard.
  - Mitigation: We do NOT need `IsSuccArchimedean` for the BFMCS construction. The succ-based embedding is injective and strictly monotone, which suffices for forward_G/backward_H. For coherence, we exploit the fact that when `U(T,bot)` holds everywhere, between any two successive embedded points there are no domain points -- this is STRONGER than what we need and avoids the IsSuccArchimedean proof entirely.

- **Risk: The mixed case sorry may concern reviewers.**
  - Mitigation: The mixed case is a well-defined, narrowly-scoped open problem. The sorry is reduced from "entire nondense case" to "mixed modal class case only," which is a significant improvement. A clear docstring documents the open problem.

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

### Phase 3: Succ-Based Embedding and Discrete BFMCS Infrastructure [NOT STARTED]

**Goal:** Replace or augment the direct embedding with a succ-based embedding for the purely discrete case (`box(U(T,bot)) in A`), and build the BFMCS family bundle on Z mirroring `cantor_bfmcs_dense`.

**Tasks:**
- [ ] Define `box_discrete_gives_discreteness` (mirror of `box_dense_gives_density`): from `box(U(T,bot)) in N`, derive that `U(T,bot) in limit_f(x)` for all x in N's limit domain. Proof pattern: `box(U(T,bot)) -> G(box(U(T,bot)))` via `temp_future`, then at each domain point `box(U(T,bot)) -> U(T,bot)` via `modal_t`. Past direction via `box_to_past` + `modal_4`.
- [ ] Define `succ_embed : Z -> LimitDomSubtype` for the discrete case: map 0 to `root`, positive n to `succ^n(root)`, negative n to `pred^|n|(root)`. This uses `limitDomSubtype_succ`/`limitDomSubtype_pred` which are well-defined when `U(T,bot)` holds everywhere.
- [ ] Prove `succ_embed_strictMono : StrictMono succ_embed`. Follows from `Order.succ_lt_succ` / pred analogues.
- [ ] Prove `succ_embed_no_gap`: between `succ_embed n` and `succ_embed (n+1)`, there are no limit domain points. This is the KEY property of the discrete case -- `U(T,bot)` means each point has an immediate successor with no intermediate domain points.
- [ ] Define `succ_discrete_f : Z -> Set Formula` as `fun n => limit_f (succ_embed n).val`.
- [ ] Define `succ_discrete_fmcs : FMCS Z` with forward_G/backward_H (same proof pattern as `discrete_fmcs`).
- [ ] Prove `succ_discrete_fmcs_at_zero : succ_discrete_fmcs.mcs 0 = A` (since `succ_embed 0 = root` and `limit_f(root) = A`).
- [ ] Prove `box_stable_in_succ_discrete_f`: `box phi in succ_discrete_f n <-> box phi in A`. Uses `box_stable_in_limit_f`.
- [ ] Define `shifted_succ_discrete_fmcs (offset : Z) : FMCS Z` as `mcs t := succ_discrete_f (t + offset)`.
- [ ] Define `rooted_succ_discrete_fmcs (N : Set Formula) (h_N : SetMaximalConsistent N) (h_box_disc : box(U(T,bot)) in N) (s : Z) : FMCS Z` -- builds chronicle for N, applies succ embedding, shifts to place N at time s.
- [ ] Prove `rooted_succ_discrete_fmcs_at_s : (rooted ... s).mcs s = N`.
- [ ] Prove `box_stable_in_rooted_succ_discrete_fmcs`.
- [ ] Define `discrete_bfmcs : BFMCS Z` with families indexed by box-equivalent MCSs (mirror `cantor_bfmcs_dense`). Prove `modal_forward` and `modal_backward`.

**Timing:** 6-8 hours

**Depends on:** 1

### Phase 4: Restricted Coherence Conditions on Z [NOT STARTED]

**Goal:** Prove the three restricted coherence conditions for `discrete_bfmcs`: temporal coherence (F/P), backward Until/Since (C4/C4'), and forward Until/Since (C5/C5'). These are the hardest components, as identified by the task 122 research.

**Tasks:**
- [ ] **Restricted temporal coherence** (`discrete_bfmcs_restricted_tc`): If `F(phi) in fam.mcs(t)`, find `s > t` with `phi in fam.mcs(s)`.
  - Strategy: Apply `limit_F_resolution` at `succ_embed(t)` to get witness y in limit_dom with `phi in limit_f(y)`. Since `U(T,bot)` holds everywhere, y is reachable from `succ_embed(t)` by finitely many succ steps (every point has an immediate successor, so the domain is a discrete chain). Define `s = collapse_to_Z(y)` where collapse_to_Z maps y to the integer count of succ-steps from root. Since the embedding IS the succ iteration, `s` is the unique integer with `succ_embed(s) = y` (or the closest integer if y is between embedded points -- but in the purely discrete case, there are no points between embedded points by `succ_embed_no_gap`).
  - Alternative (simpler): Since `succ_embed` covers all reachable points, `y` must equal `succ_embed(m)` for some `m`. This needs `succ_embed` to be surjective, which requires `IsSuccArchimedean`. If we cannot prove this, fall back: use `limit_forward_G` to propagate `phi` from y to a later embedded point.
  - **FALLBACK STRATEGY** (if surjectivity is hard): F(phi) at embedded point t means there exists y > embed(t) with phi at y. We cannot guarantee y is embedded. But G(phi) holds at embed(t) (since F(phi) implies G(phi) is not needed -- F just means "some future point"). Actually F(phi) does NOT imply G(phi). So we need a different approach. Use the limit-level F resolution: there exists y with phi. Then find the LARGEST embedded point m such that embed(m) <= y. At embed(m), forward_G from embed(t) to embed(m) gives G-formulas but not F. But phi is at y, which is beyond embed(m) (or at embed(m)). If y = embed(m), done. If y > embed(m), then y is between embed(m) and embed(m+1). But by `succ_embed_no_gap`, there are no domain points between consecutive embedded points. So y cannot exist between them. Therefore y must be some embed(m), and `s = m`.
  - Mirror argument for P direction using `limit_P_resolution`.
- [ ] **Restricted backward Until/Since coherence** (`discrete_bfmcs_restricted_buc`): Contrapositive via C4/C4'. If `neg(U(phi,psi)) in fam.mcs(t)` and there exists u > t with phi at u and psi in the guard, derive contradiction.
  - Strategy: Mirror `cantor_bfmcs_dense_restricted_buc` exactly. Apply `limit_satisfies_c4` at the embedded points to get a guard-failing witness z between embed(t) and embed(u). Map z back to an integer via the no-gap property. The psi-guard contradiction follows.
- [ ] **Restricted forward Until/Since coherence** (`discrete_bfmcs_restricted_fuc`): The hardest condition. If `U(phi,psi) in fam.mcs(t)`, find u > t with phi at u and psi-guard satisfied.
  - Strategy: Apply `limit_satisfies_c5_strong` at `succ_embed(t)` to get witness y with phi at y and psi in the guard between embed(t) and y. Map y to integer u via the no-gap property. The guard covers all integers between t and u: for any integer s with t < s < u, `succ_embed(s)` is between `succ_embed(t)` and `succ_embed(u)`, and by the no-gap property `succ_embed(s)` IS a domain point between embed(t) and y, so `psi in limit_f(succ_embed(s))` by the C5 guard.
  - **CRITICAL SUBTLETY for psi=bot**: When `U(T,bot) in fam.mcs(t)`, the C5 witness y is the immediate successor of embed(t), so y = embed(t+1). The guard is vacuous (no integers between t and t+1). Top is in every MCS, so `T in fam.mcs(t+1)` is trivially true. This case works cleanly.
  - **For general Until formulas**: The C5 witness y from the limit satisfies phi at y and psi-guard between embed(t) and y. By the no-gap property, y = embed(m) for some m, and the guard covers all embedded points between t and m.
  - Mirror for Since direction using `limit_satisfies_c5'_strong`.
- [ ] Verify `lake build ChronicleToCountermodel` compiles after all three coherence proofs.

**Timing:** 6-8 hours

**Depends on:** 2, 3

### Phase 5: Case Split Refinement and Final Wiring [NOT STARTED]

**Goal:** Wire `discrete_bfmcs` and its coherence proofs into `dd_countermodel_chronicle_discrete`, refine the case split in `Completeness.lean`, and reduce the nondense sorry to the mixed case only.

**Tasks:**
- [ ] Define `dd_countermodel_chronicle_discrete` in `ChronicleToCountermodel.lean`: given MCS A with `neg(phi) in A` and `box(U(T,bot)) in A`, build a countermodel on Z where phi is false. Mirror `dd_countermodel_chronicle_dense` exactly, using `discrete_bfmcs` + three restricted coherence conditions + `fully_restricted_parametric_representation_from_neg_membership`.
- [ ] Define `dd_countermodel_chronicle_mixed_sorry`: the residual sorry for the mixed case (`not box(F'T) and not box(U(T,bot))`). Add a detailed docstring explaining the open problem and why it cannot use D=Q or D=Z for all families.
- [ ] Modify `bx_completeness` in `Completeness.lean` to use a three-way case split:
  1. `box(F'T) in M` -- dense case (existing, sorry-free)
  2. `box(U(T,bot)) in M` -- purely discrete case (new, sorry-free)
  3. `not box(F'T) and not box(U(T,bot))` -- mixed case (new, sorry)
  - Implementation: after the existing `rcases ... negation_complete ... next_top.neg`, add a nested case split on `box next_top` (= `box(U(T,bot))`) in the non-dense branch. From `not box(F'T) in M` (= `neg(box(next_top.neg)) in M`), case-split on `box(next_top)` vs `neg(box(next_top))`.
- [ ] Add docstrings to all new definitions and theorems.
- [ ] Verify full `lake build` passes.
- [ ] Grep for sorry in Chronicle files and Completeness.lean; confirm the only remaining sorry is the mixed-case stub.

**Timing:** 3-4 hours

**Depends on:** 4

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phases 3 and 4
- [ ] `lake build Completeness` passes after Phase 5
- [ ] Full `lake build` passes after Phase 5
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry dependencies
- [ ] `lean_verify` on `discrete_bfmcs` confirms no sorry dependencies
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only the mixed-case stub
- [ ] Grep for sorry in `Completeness.lean` shows only the mixed-case usage
- [ ] The sorry count on the critical path for `bx_completeness` is reduced from 1 (broad nondense) to 1 (narrow mixed-case)

## Artifacts & Outputs

- **Plan**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/01_fix-c5-bot-witness.md (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phases 3, 4, 5)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (Phase 5)
- **Summary**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/01_fix-c5-bot-summary.md

## Rollback/Contingency

Phases 3-5 are ADDITIVE (new definitions and lemmas). The existing construction, limit definitions, dense case, and Phase 1/2 work are untouched. Reverting: delete the new discrete BFMCS section and restore the original `dd_countermodel_chronicle_nondense_sorry` in Completeness.lean.

If the succ-based embedding approach proves too complex:
1. **Fallback A**: Keep the existing `discrete_embed` (non-surjective) and prove coherence by showing that for the purely discrete case, witnesses from limit resolution functions always happen to land on embedded points. This may be hard to prove but is mathematically true.
2. **Fallback B**: Use the collapse quotient infrastructure (Phase 1) to define a surjection `LimitDomSubtype -> Z` and build the FMCS through the surjection. This avoids the succ-embedding approach but requires proving `IsSuccArchimedean` on the quotient.
3. **Fallback C**: Leave `dd_countermodel_chronicle_nondense_sorry` as-is and let task 122 handle all nondense sub-cases. This preserves the status quo and delays the work.

## Critical Notes for Implementation

1. **The succ-based embedding is the key innovation.** Unlike the current `discrete_embed` which picks arbitrary increasing points, the succ-based embedding follows the deterministic successor structure. When `U(T,bot)` holds everywhere, `succ` gives an IMMEDIATE successor with no intermediate domain points. This means the embedding is "gap-free" in the sense that between `embed(n)` and `embed(n+1)` there are no limit domain points.

2. **The no-gap property is what makes coherence proofs work.** In the dense case, the Cantor isomorphism is a BIJECTION (every rational is a domain point), so witnesses automatically land in the image. In the discrete case, we don't have a bijection, but we have the next best thing: every domain point IS an embedded point (no gaps). This gives the same guarantee as surjectivity for coherence purposes.

3. **The mixed case is a genuine open problem.** U(T,bot) is always TRUE on Z (immediate integer successor) and always FALSE on Q (dense rationals between any two points). Families with different temporal structures cannot coexist in a single BFMCS on either D=Q or D=Z. Novel techniques (ultraproducts, enriched frames, or new BX theorems) may be needed.

4. **Task 122 relationship**: Once task 123 provides `dd_countermodel_chronicle_discrete`, task 122 can wire it into the completeness proof and focus on the mixed case (or leave it as an open sorry). The two tasks have clean separation: task 123 builds the discrete infrastructure, task 122 integrates it and handles the case split.
