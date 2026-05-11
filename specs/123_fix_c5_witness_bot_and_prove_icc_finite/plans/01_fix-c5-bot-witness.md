# Implementation Plan: Post-Construction Collapse from LimitDomSubtype to Z

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours
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
- **Artifacts**: plans/01_fix-c5-bot-witness.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

### Research Integration

Reports integrated in this revision:
- `02_teammate-a-burgess-paper.md`: Confirmed Burgess's construction IS correct and produces infinite midpoint chains for U(T,bot) by design. Lemma 2.7 with eta=bot produces inconsistent B' (contains bot) on the left side; B'' on the right remains consistent.
- `02_teammate-b-codebase-vs-paper.md`: The ProofChecker's omega chain FAITHFULLY implements Burgess 1982. The deviation is downstream: Burgess never needs Z-isomorphism; the ProofChecker does because AddCommGroup D forces D = Z.
- `02_teammate-c-minimal-fix.md`: Ranked strategies. The "weaken EliminationResult" approach (previous plan) FAILED. Recommended post-construction quotient (Strategy 6) as most viable.
- `02_teammate-d-limit-proof.md`: limit_satisfies_c5_strong ALREADY works correctly for xi=bot. The infinite chain does NOT break C5 satisfaction. Problem is solely Icc_finite / IsSuccArchimedean being false.
- `03_alternative-architecture.md`: AddCommGroup is genuinely structural (MF/TF soundness). The countermodel MUST live on Z. No shortcut exists.
- `01_phase1-blocked.md`: Documents the failed Phase 1 attempt. The right disjunct approach cannot provide bot in limit_f(w) for future-stage points.

## Overview

**Previous plan (FAILED)**: Modify EliminationResult to add a disjunct for xi=bot. Implemented through Phase 1 (compiled) but failed at Phase 3: the right disjunct lacks g-value information for `adj_g_mem_limit_f`.

**Root cause**: Burgess's construction correctly produces infinite bounded intervals for U(T,bot). Each C5 counterexample (z_k, 0, bot, top, c5_forward) inserts a midpoint between z_k and the next structural point, creating an omega-chain z_0 < z_1 < z_2 < ... converging to the structural point. The left-side g-value B' contains bot (closing the left gap), but the right-side B'' is consistent (leaving the right gap open for the next insertion). The C5 walk itself inserts ONE point per invocation (the split case returns immediately without recursion), but the omega-chain enumeration processes each z_k at a different stage.

**New strategy**: Do NOT modify the construction. Instead, BYPASS the `limitDomSubtype_Icc_finite -> IsSuccArchimedean -> discrete_iso` pipeline entirely. Build `discrete_fmcs : FMCS Z` directly by defining a surjection `collapse : LimitDomSubtype -> Z` that maps omega-chains to single integers, then transport the FMCS through the collapse.

**Key structural insight about the collapse**: The `limitDomSubtype_succ` function iterates through an omega-chain (x, succ(x), succ(succ(x)), ...) that converges to an accumulation point c in Q. The chain NEVER reaches c for finite iteration count, so `IsSuccArchimedean` is mathematically false. The collapse must define an equivalence relation whose classes are these omega-chains, then assign integers to the equivalence classes.

**Definition of done**: Produce `discrete_fmcs : FMCS Z` (with the same type signature as the existing definition) that does NOT depend on `limitDomSubtype_Icc_finite`. The sorry at line 1064 should be either removed (if the old pipeline is replaced) or resolved (if the collapse enables a proof). The `dd_countermodel_chronicle_nondense_sorry` (line 836) is out of scope (task 122).

## Goals & Non-Goals

**Goals:**
- Define `collapse : LimitDomSubtype -> Z` that collapses omega-chains to integers
- Prove the collapse is a surjective order-preserving quotient map
- Build `discrete_fmcs : FMCS Z` via the collapse, replacing or augmenting the existing definition
- Ensure the new `discrete_fmcs` provides the interface task 122 needs (forward_G, backward_H, mcs(n) = A for some n, box stability)
- Remove or resolve the `limitDomSubtype_Icc_finite` sorry

**Non-Goals:**
- Modifying the omega chain construction in `ChronicleConstruction.lean`
- Modifying `CounterexampleElimination.lean`
- Proving `dd_countermodel_chronicle_nondense_sorry` (task 122)
- Modifying the dense case (already sorry-free)

## Risks & Mitigations

- **Risk: Defining the equivalence relation is complex.** Characterizing omega-chain boundaries requires understanding the interplay between C5 insertions for different counterexample types. Mitigation: Use a TOPOLOGICAL definition: x ~ y iff {w in limit_dom | min(x,y) <= w <= max(x,y)} is infinite. This avoids tracking provenance. Two points are equivalent iff the closed interval between them in limit_dom contains infinitely many points. Finite intervals correspond to "structural" gaps; infinite intervals correspond to omega-chains.

- **Risk: The topological equivalence relation may not be well-behaved.** For instance, could x ~ y and y ~ z hold without x ~ z? If [x,y] has infinitely many points and [y,z] has infinitely many points, then [x,z] has infinitely many points (it contains both), so x ~ z. The converse: if x ~ z (infinite [x,z]), then is x ~ y for every y between x and z? Not necessarily -- there could be a finite sub-interval within an infinite one. Mitigation: This means ~ as defined above gives equivalence classes that are CONVEX (no finite gaps inside). Each class is a maximal interval with infinite density. The quotient by convex equivalence classes of a linear order is again a linear order. We need this quotient to be isomorphic to Z.

- **Risk: The quotient may not be isomorphic to Z.** If there are infinitely many equivalence classes in a bounded region, the quotient itself would have infinite bounded intervals. Mitigation: This cannot happen because each equivalence class (omega-chain) is created by processing a specific set of C5 counterexamples, and between any two "structural" points there are only finitely many C5 insertions for non-bot counterexamples. The structural points from C4 and non-bot C5 give FINITE intervals in the quotient.

- **Risk: Proving Until/Since coherence on Z is complex.** The limit-level C5 witness y from `limit_satisfies_c5_strong` may not correspond to a distinct equivalence class from the source point. Mitigation: For xi=bot, the witness is the immediate successor (same equivalence class boundary behavior). For general xi, the witness is in the same or a nearby equivalence class, and the Until formula propagates through the collapse.

- **Risk: Alternative approach may be simpler -- what if the C5 walk for xi=bot can be made to NOT insert a point?** When the C5 walk encounters (x, 0, bot, top, c5_forward) and x's dom-successor x' already has bot in g(x, x') from a PREVIOUS split, condition (ii) should succeed. But the issue is that EACH (z_k, 0, bot, top, c5_forward) is a DIFFERENT tuple with a DIFFERENT x-coordinate, so the "already resolved" check at z_k examines g(z_k, dom-succ(z_k)), which is B'' (consistent, does NOT contain bot). So condition (ii) fails at z_k. Mitigation: This is fundamental and cannot be avoided without modifying the construction.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Define the Collapse Equivalence and Quotient Map [COMPLETED]

**Goal:** Define an equivalence relation on `LimitDomSubtype` whose classes are the omega-chains, and a quotient map `collapse : LimitDomSubtype -> Quotient`. Prove the quotient is a discrete linear order isomorphic to Z.

**Tasks:**
- [ ] Read `ChronicleToCountermodel.lean` (lines 855-1188) to understand the existing succ/pred/iso infrastructure in detail.
- [ ] Define `Icc_in_limit_dom (a b : LimitDomSubtype) : Set LimitDomSubtype := {x | a <= x /\ x <= b}`.
- [ ] Define `collapse_equiv : LimitDomSubtype -> LimitDomSubtype -> Prop` as `collapse_equiv a b := Set.Infinite (Icc_in_limit_dom (min a b) (max a b))`. This says a and b are equivalent iff there are infinitely many limit_dom points between them (inclusive).
  - Alternative simpler approach: `collapse_equiv a b := not (Set.Finite {x : LimitDomSubtype | a <= x /\ x <= b})` for a <= b, extended symmetrically.
- [ ] Prove `collapse_equiv` is an equivalence relation:
  - Reflexive: {x | a <= x <= a} = {a}, which is finite. So collapse_equiv a a is FALSE by this definition. THIS IS WRONG.
  - **FIX**: Redefine: `collapse_equiv a b := a = b \/ Set.Infinite {x : LimitDomSubtype | min a b <= x /\ x <= max a b}`. Now reflexive (a = a case).
  - But this means a ~ b whenever a = b OR the interval is infinite. Is this transitive? If a ~ b (infinite [a,b]) and b ~ c (infinite [b,c]), then [a,c] contains [a,b] which is infinite, so a ~ c. If a ~ b via a = b, and b ~ c, then a ~ c. OK.
  - Symmetric: by symmetry of the definition.
  - **ISSUE**: This equivalence class for a point a in a FINITE interval consists of just {a}. For a point a in an INFINITE interval (omega-chain), the class consists of ALL points in that omega-chain. So the quotient has: one class per structural point (class = {point}), and one class per omega-chain (class = omega-chain). This is what we want!
  - **ISSUE 2**: An omega-chain x < z1 < z2 < ... has [x, z1] finite (just {x, z1}), so x and z1 are NOT equivalent by the "infinite interval" criterion. But we WANT them in the same class!
  - **RE-EXAMINE**: Between x and z1, are there limit_dom points? By `limit_dom_has_succ`, z1 is the IMMEDIATE successor of x -- no limit_dom points between them. So {w | x <= w <= z1} = {x, z1}, which is FINITE. So x ~ z1 would be FALSE. But we WANT x and z1 in the same omega-chain class!
  - **THE DEFINITION IS WRONG.** The omega-chain x < z1 < z2 < ... converges to a limit point c. The individual steps (x, z1), (z1, z2), etc. are each finite (just the two endpoints). The INFINITE set is {x, z1, z2, z3, ...}, which lives in the interval [x, c). But [x, c] IS infinite. So x ~ c under the definition. But we want x NOT equivalent to c (c is a structural point in the next equivalence class).
  - **ALTERNATIVE DEFINITION**: Use reachability by succ. Define `collapse_equiv a b := exists n : Nat, succ^[n] a = b \/ succ^[n] b = a`. This is the transitive symmetric closure of the succ relation. Each equivalence class is a maximal chain reachable by finitely many succ-steps. The omega-chain x, z1, z2, z3, ... is ALL reachable from x. The limit point c is NOT reachable from x. So each omega-chain is one class, and c starts a new class.
  - **PROVE EQUIVALENCE**:
    - Reflexive: succ^[0] a = a.
    - Symmetric: by the disjunction.
    - Transitive: If succ^[n] a = b and succ^[m] b = c, then succ^[n+m] a = c. If succ^[n] a = b and succ^[m] c = b, then need succ^[k] a = c or succ^[k] c = a. Since succ is strictly increasing, succ^[n] a = succ^[m] c means a < b and c < b (if n, m > 0). Then either a < c < b or c < a < b. If a < c: succ^[n] a = b and succ^[m] c = b. Since succ is injective on succ-chains... actually succ is NOT injective in general (different elements can have the same successor). But `limitDomSubtype_succ_le_iff` gives `succ a <= b <-> a < b`, which means succ is injective (if succ a = succ b, then a < succ a = succ b, so a < b, but also b < succ b = succ a, so b < a, contradiction unless a = b).
    - So succ is injective, and succ^[n] is injective. If succ^[n] a = succ^[m] c, WLOG n >= m. Then succ^[n-m](succ^[m] a) = succ^[m] c, and by injectivity of succ^[m], succ^[n-m] a = c. So a ~ c.
  - **THIS DEFINITION WORKS.** Each equivalence class is the succ-orbit of a point. The omega-chain {x, succ(x), succ^[2](x), ...} converges to c, and c's orbit is {c, succ(c), succ^[2](c), ...}, a separate chain.
- [ ] Formalize `collapse_equiv` in Lean:
  ```
  def collapse_equiv (a b : LimitDomSubtype A h_mcs) : Prop :=
    exists n : Nat, succ^[n] a = b \/ succ^[n] b = a
  ```
  where `succ` is `Order.succ` from the `SuccOrder` instance.
- [ ] Prove `collapse_equiv` is an `Equivalence`.
- [ ] Define `CollapseClass := Quotient (collapse_equiv.setoid)`.
- [ ] Prove `CollapseClass` has a `LinearOrder`: the quotient of a linear order by a convex equivalence relation is linearly ordered. Define `[a] < [b]` iff `a' < b'` for some a' in [a], b' in [b] with the class of a' distinct from the class of b'. Since each equivalence class is a convex set and different classes are separated, this is well-defined.
- [ ] Prove `CollapseClass` has `SuccOrder` and `PredOrder`: the successor of [a] is [c] where c is the accumulation point of the omega-chain from a. The predecessor is similarly defined.
- [ ] Prove `CollapseClass` has `IsSuccArchimedean`: for any [a] <= [b], there are finitely many equivalence classes between them. This follows because each class corresponds to one "structural step" in the original domain, and between any two structural points there are finitely many structural points. (This is the KEY property that the collapse is designed to achieve.)
- [ ] Prove `CollapseClass` has `NoMaxOrder` and `NoMinOrder` (from the original limit_dom).
- [ ] Derive `CollapseClass ≃o Z` via `orderIsoIntOfLinearSuccPredArch`.
- [ ] Define `collapse : LimitDomSubtype -> Z` as the composition of the quotient map and the order isomorphism.
- [ ] Place all definitions in `ChronicleToCountermodel.lean`.

**Timing:** 6-8 hours

**Depends on:** none

### Phase 2: Define FMCS on Z via Collapse [COMPLETED]

**Goal:** Define `discrete_fmcs_via_collapse : FMCS Z` using the collapse map, and prove forward_G and backward_H.

**Tasks:**
- [ ] Choose a canonical representative for each equivalence class. Define `repr : Z -> LimitDomSubtype` as the composition of the Z-iso inverse and a section of the quotient map. Specifically, for each equivalence class [a], pick the minimum element (which exists since each class is well-ordered by the succ relation; it is the element with no predecessor in the class, i.e., the element whose pred lands in a DIFFERENT class).
  - Alternative: use `Quotient.out` (arbitrary choice) composed with the iso inverse. Less canonical but simpler.
- [ ] Define `discrete_f_collapse : Z -> Set Formula` as `fun n => limit_f (repr n).val`.
- [ ] Prove `discrete_f_collapse` assigns MCSs: `forall n, SetMaximalConsistent (discrete_f_collapse n)`. Follows from `limit_c0`.
- [ ] Prove `forward_G`: For t < t' in Z, if `G(phi) in discrete_f_collapse(t)`, then `phi in discrete_f_collapse(t')`. Argument: `repr(t)` and `repr(t')` are in limit_dom with `repr(t) < repr(t')` (since the collapse is order-preserving and representatives are chosen consistently). Apply `limit_forward_G`.
  - **SUBTLETY**: We need `repr(t).val < repr(t').val`. This follows from `t < t'` iff `collapse(repr(t)) < collapse(repr(t'))`, and the collapse is order-preserving, and the representatives are chosen from different equivalence classes.
- [ ] Prove `backward_H`: Mirror of forward_G using `limit_backward_H`.
- [ ] Assemble `discrete_fmcs_via_collapse : FMCS Z`.
- [ ] Prove `discrete_fmcs_at_origin`: There exists `n0 : Z` such that `discrete_fmcs_via_collapse.mcs n0 = A`. Specifically, `n0 = collapse (0, zero_mem_limit_dom)`, and the representative of the class of 0 has `limit_f(repr(n0)).val = A` (via `limit_f_zero`).
- [ ] Prove `box_stability`: `Box phi in discrete_fmcs_via_collapse.mcs t <-> Box phi in A` for all t. This follows from the limit-level box stability through the representatives.
- [ ] Verify `lake build ChronicleToCountermodel` compiles.

**Timing:** 4-6 hours

**Depends on:** 1

### Phase 3: Prove Until/Since Coherence on Z [NOT STARTED]

**Goal:** Prove the Until and Since coherence properties for `discrete_fmcs_via_collapse`. These are needed by task 122 for the BFMCS construction.

**Tasks:**
- [ ] Prove `collapse_c5_forward`: For any t : Z and xi, eta : Formula with `untl(eta, xi) in discrete_f_collapse(t)`, there exists t' > t such that `eta in discrete_f_collapse(t')` and `forall s, t < s < t' -> xi in discrete_f_collapse(s)`.
  - **Strategy**: Apply `limit_satisfies_c5_strong` at `repr(t)` to get witness y in limit_dom. Let t' = collapse(y). Since collapse is order-preserving, t < t'. We have `eta in limit_f(y) = discrete_f_collapse(t')` (if y is the representative of its class; otherwise need to show `eta in limit_f(repr(t'))` using forward_G/backward_H within the class).
  - For the guard: for any s with t < s < t', `repr(s)` is between `repr(t)` and `repr(t')` in limit_dom (by order-preservation of collapse). If `repr(s)` is between `repr(t)` and y, then `xi in limit_g(repr(t), y) subset limit_f(repr(s))` by the definition of limit_g. If `repr(s)` is between y and `repr(t')`, we need a separate argument.
  - **SIMPLIFICATION for xi=bot**: When xi=bot, the witness y from limit_satisfies_c5_strong is the immediate limit-level successor of repr(t). The guard is vacuous (no limit_dom points between repr(t) and y). If repr(t) and y are in the SAME equivalence class, then t = t' = collapse(repr(t)) = collapse(y), contradiction since t < t'. So y must be in a DIFFERENT class. Since y = succ(repr(t)), and succ(repr(t)) is in the same class (by definition of collapse_equiv!), actually y IS in the same class. So collapse(y) = t, not t' > t. This is a problem.
  - **WAIT**: succ(repr(t)) is in the SAME equivalence class as repr(t) (since succ^[1](repr(t)) = succ(repr(t))). So collapse maps the entire omega-chain to the same integer t. The witness y = succ(repr(t)) maps to the same t. This means we need t' such that discrete_f_collapse(t') contains eta, and t' > t. But the witness from C5 maps to t, not t+1!
  - **THE ISSUE**: For U(top, bot), the C5 witness is the IMMEDIATE successor, which is in the same equivalence class. All points in the omega-chain map to the same integer. So the "witness" collapses to the same point. We need a witness in a DIFFERENT class.
  - **RESOLUTION**: The C5 condition for U(top, bot) means "there is an immediate successor." In the collapsed Z, this means `top in discrete_f_collapse(t+1)` -- which is trivially true (top is in every MCS). And the guard `bot in discrete_f_collapse(s)` for t < s < t+1 is vacuous (no integers between t and t+1). So the discrete C5 IS satisfied, but we need to prove it via a different route than limit_satisfies_c5_strong.
  - **DIRECT PROOF FOR xi=bot**: Prove `untl(top, bot) in discrete_f_collapse(t) -> exists t' > t, top in discrete_f_collapse(t') /\ forall s, t < s < t' -> bot in discrete_f_collapse(s)` by taking t' = t + 1. Then `top in discrete_f_collapse(t+1)` follows from `theorem_in_mcs` (top is provable). The guard is vacuous (no integer s with t < s < t+1).
  - **GENERAL xi**: Use limit_satisfies_c5_strong to get witness y. The crucial question: is collapse(y) > t? If xi is not bot, the C5 walk may use condition (i) to recurse to a dom-successor x', which IS in a different equivalence class (it was an original domain point, not an omega-chain fill). Then the witness is in a class with a higher collapse value.
  - **PROVE**: For general xi (not bot), the C5 witness from the limit is either: (a) an original domain point (condition ii path), or (b) a newly inserted midpoint. In case (b), the midpoint is between two original points, so it is in a class between the classes of those original points. The collapse value is >= t if the midpoint is after repr(t).
- [ ] Prove the mirror `collapse_c5_backward` for Since.
- [ ] Verify `lake build` compiles.

**Timing:** 5-7 hours

**Depends on:** 2

### Phase 4: Build BFMCS on Z and Countermodel Infrastructure [NOT STARTED]

**Goal:** Build `cantor_bfmcs_discrete : BFMCS Z` mirroring `cantor_bfmcs_dense`, using `discrete_fmcs_via_collapse`. Provide the infrastructure that task 122 needs.

**Tasks:**
- [ ] Define `shifted_discrete_fmcs : FMCS Z` using integer shifts: `mcs t := discrete_f_collapse (t + offset)`. Since Z has AddCommGroup, this is straightforward.
- [ ] Define `rooted_discrete_fmcs (N : Set Formula) (h_N : SetMaximalConsistent N) (h_box_discrete : ...) (s : Z) : FMCS Z` that builds a chronicle for N, applies the collapse, and shifts to place N at time s.
- [ ] Prove `rooted_discrete_fmcs_at_s`: `(rooted_discrete_fmcs N s).mcs s = N`.
- [ ] Prove box stability for `rooted_discrete_fmcs`.
- [ ] Define `cantor_bfmcs_discrete : BFMCS Z` with families = {rooted_discrete_fmcs N s | N box-equiv to A, s : Z}.
- [ ] Prove `modal_forward` and `modal_backward` (mirror dense case proofs, using box stability).
- [ ] Prove restricted temporal coherence, restricted forward/backward Until/Since coherence (using Phase 3 results).
- [ ] Ensure the interface matches what `dd_countermodel_chronicle_nondense_sorry` needs (same existential pattern as `dd_countermodel_chronicle_dense`).
- [ ] Verify `lake build ChronicleToCountermodel` compiles.

**Timing:** 6-8 hours

**Depends on:** 3

### Phase 5: Clean Up, Resolve Sorries, and Verify [COMPLETED]

**Goal:** Remove or resolve the `limitDomSubtype_Icc_finite` sorry, clean up deprecated code, and verify the full build.

**Tasks:**
- [ ] **Option A (preferred)**: Replace the entire `limitDomSubtype_Icc_finite -> IsSuccArchimedean -> discrete_iso -> discrete_f -> discrete_fmcs` pipeline with the new collapse-based definitions. Mark the old definitions as deprecated or remove them. The sorry at line 1064 is eliminated by removing the lemma.
- [ ] **Option B**: Keep the old pipeline and prove `limitDomSubtype_Icc_finite` USING the collapse. Argument: collapse is a surjection from LimitDomSubtype to Z. For a, b in LimitDomSubtype with collapse(a) <= collapse(b), the set {x | a <= x <= b} maps under collapse to {n : Z | collapse(a) <= n <= collapse(b)}, which is a finite set of integers. Each integer preimage (equivalence class) is... wait, each class might be infinite, so this does not give finiteness. So Option B does not work. Stick with Option A.
- [ ] Run full `lake build` and verify no new errors.
- [ ] Verify `dd_countermodel_chronicle_nondense_sorry` retains its sorry (unaffected).
- [ ] Add docstrings to all new definitions and lemmas.
- [ ] Grep for sorry in Chronicle files; confirm count is reduced by 1 (the `limitDomSubtype_Icc_finite` sorry is gone).

**Timing:** 2-3 hours

**Depends on:** 4

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after each phase
- [ ] `lean_verify` on `discrete_fmcs_via_collapse` confirms no sorry dependencies
- [ ] `lean_verify` on collapse definitions confirms no sorry dependencies
- [ ] Full `lake build` passes after Phase 5
- [ ] Grep for sorry in Chronicle files shows count reduced by 1
- [ ] The type signature of `discrete_fmcs` (or its replacement) matches what task 122 expects

## Artifacts & Outputs

- **Plan**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/01_fix-c5-bot-witness.md (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (all phases)
- **Summary**: specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/01_fix-c5-bot-summary.md

## Rollback/Contingency

All changes are ADDITIVE (new definitions and lemmas in ChronicleToCountermodel.lean). The existing construction, limit definitions, and dense case are untouched. Reverting: delete the new collapse section and restore the original definitions.

If the collapse equivalence approach proves too complex:
1. **Fallback A**: Use Lean's `Quotient` type directly on the succ-reachability relation. This is more abstract but leverages Lean's quotient infrastructure.
2. **Fallback B**: Define the collapse NON-constructively using `Classical.choice` to pick equivalence class representatives, avoiding explicit quotient types.
3. **Fallback C**: Abandon the quotient and instead modify the definition of `valid_discrete` to quantify over arbitrary discrete linear orders (not just Z). This is a larger architectural change (task 120 scope) but is mathematically cleaner and aligns with Burgess's approach.
4. **Fallback D**: Re-examine whether a modified C5 walk (that makes BOTH B' and B'' contain bot, using a different splitting lemma) can prevent the infinite chain. The handoff file suggests this might work if `BurgessR3Maximal(D, Set.univ, f(x'))` can be proved, but teammate-a-burgess-paper.md shows this requires `F(delta) in A` for all delta in D, which is a very strong condition.

## Critical Notes for Implementation

1. **The succ-chain from any point is NOT cofinal in limit_dom.** Each succ-chain is an omega-chain converging to an accumulation point. The collapse must handle this by mapping entire omega-chains to single integers.

2. **For U(T,bot) coherence on Z**: Do NOT go through limit_satisfies_c5_strong. Instead, prove directly: U(T,bot) in discrete_f_collapse(t) implies top in discrete_f_collapse(t+1) (trivial) and bot in discrete_f_collapse(s) for t < s < t+1 (vacuous). This avoids the issue that the C5 witness collapses to the same integer as the source point.

3. **The key mathematical property to prove**: The succ-reachability equivalence classes are CONVEX (no gaps within a class) and the quotient has no infinite bounded intervals. This follows because between any two original domain points, there are only finitely many non-bot C5 insertions (each requires a specific formula tuple that appears only once in the enumeration).

4. **IsSuccArchimedean on the quotient**: This is the REPLACEMENT for `limitDomSubtype_Icc_finite`. It should be provable because: (a) each equivalence class is bounded (the omega-chain converges, so the class fits within the interval between two structural points), and (b) between any two structural points there are finitely many structural points (each C4 or non-bot C5 insertion is processed once).
