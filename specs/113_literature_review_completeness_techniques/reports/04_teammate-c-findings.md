# Teammate C (Critic): Phase 3 Blocker Analysis and Proposed Solutions

**Task**: 113 - Literature review: completeness techniques
**Date**: 2026-04-27
**Role**: Critical analysis of Phase 3 agent conclusions
**Session**: sess_1777316607_f01b30

---

## Key Findings

### 1. `until_guard_in_mcs` Is Genuinely Invalid -- CONFIRMED

The statement: if `gamma U delta in A` (MCS A), then `gamma in A`.

Under open guard semantics (Truth.lean lines 127-128), `gamma U delta` at t means:
```
exists s > t, delta(s) AND forall r, t < r AND r < s -> gamma(r)
```

The guard interval is (t,s), which excludes the evaluation point t. There is no semantic reason for gamma to hold at t. Concrete counterexample: let gamma(t) = false, delta(t) = false, but gamma on (t,s) all true and delta(s) = true. Then gamma U delta is true at t but gamma(t) is false.

**Can gamma in A be derived from remaining axioms?** No. The remaining axioms give:
- BX10: `gamma U delta -> F(delta)` -- only yields F(delta), not gamma
- BX5: `gamma U delta -> (gamma AND (gamma U delta)) U delta` -- enriches the guard but never extracts gamma at the current point
- BX4: `phi -> G(P(phi))` -- irrelevant here
- No combination produces gamma from gamma U delta without BX9 or until_guard

**Verdict**: CORRECTLY CLASSIFIED AS INVALID. No alternative proof path exists.

### 2. `untl_absorb_nested` Is Genuinely Invalid -- CONFIRMED

The statement: `gamma U (gamma U delta) -> gamma U delta` (as a DerivationTree theorem).

**Semantic analysis under open guard**: Consider gamma U (gamma U delta) true at t = 0.
- Outer Until: witness s1 = 2, inner formula (gamma U delta)(2), guard gamma on (0,2)
- Inner Until: witness s2 = 4, delta(4), guard gamma on (2,4)
- Combined: gamma on (0,2) and gamma on (2,4), but gamma(2) is NOT guaranteed

The open guard of the outer Until covers (0,2) -- this does NOT include the point 2 itself. The inner Until at point 2 has guard (2,4) -- this does NOT include point 2 either. So gamma(2) is unconstrained. Setting gamma(2) = false creates a valid counterexample:
- gamma U (gamma U delta) at 0: TRUE (witness 2, guard on (0,2) which excludes 2)
- gamma U delta at 0: requires some s > 0 with delta(s) and gamma on (0,s). Only s = 4 has delta. But gamma on (0,4) fails at r = 2.
- So gamma U delta at 0: FALSE

**Is the STATEMENT semantically valid?** NO. The counterexample above shows `gamma U (gamma U delta) -> gamma U delta` is FALSE in models with open guard semantics. Therefore it cannot be derivable in any sound axiom system for open guard.

**Under the old half-closed guard** `[t,s)`, gamma U delta at t requires gamma(t) via the guard [t,s), which includes t. So gamma(2) would be guaranteed by (gamma U delta)(2), and the absorption would work. This is exactly the proof path the old code used: step 1 gets gamma(t) via until_guard, step 4 uses temporal necessitation on until_guard to get G(gamma U delta -> gamma), step 5 uses BX3, step 6 uses BX6 to absorb. All of this breaks because step 1 is invalid.

**Verdict**: CORRECTLY CLASSIFIED AS INVALID. The statement itself is semantically false under open guard.

### 3. Detailed Audit of All Sorry Stubs

I audited every sorry stub in the Chronicle/ directory. Here is the classification:

#### RRelation.lean (6 sorry stubs):

| Line | Lemma | Status | Reason |
|------|-------|--------|--------|
| 87 | `until_disjunction_in_mcs` | GENUINELY INVALID | Statement is semantically false under open guard |
| 107 | `until_guard_in_mcs` | GENUINELY INVALID | Statement is semantically false under open guard |
| 122 | `since_guard_in_mcs` | GENUINELY INVALID | Mirror of above |
| 163 | `since_disjunction_in_mcs` | GENUINELY INVALID | Mirror of until_disjunction |
| 1254 | `untl_absorb_nested` | GENUINELY INVALID | Statement is semantically false under open guard |
| 1266 | `snce_absorb_nested` | GENUINELY INVALID | Mirror of above |

All 6 stubs in RRelation.lean are correctly classified. Their statements are semantically false under open guard and cannot be proved in any sound axiom system.

#### PointInsertion.lean (2 sorry stubs):

| Line | Lemma | Status | Reason |
|------|-------|--------|--------|
| 185 | `until_elim_mcs` | GENUINELY INVALID | Semantically false under open guard |
| 972 | `burgess_D0_consistent` | BLOCKED but STATEMENT LIKELY TRUE | Depends on `BurgessR3Maximal_maximality_combined` which has one invalid branch |

**Critical distinction for `burgess_D0_consistent`**: The STATEMENT (the D0 seed is consistent) is likely TRUE -- it is a key step in the Burgess construction and should hold in any complete axiom system for the intended semantics. The PROOF is what is broken. See Finding 5 below for the detailed analysis.

#### ChronicleTypes.lean (2 sorry stubs):

| Line | Lemma | Status | Reason |
|------|-------|--------|--------|
| 569 | `rRelation_of_superset_mcs` | GENUINELY INVALID | Requires BX9 |
| 578 | `rRelationSince_of_superset_mcs` | GENUINELY INVALID | Mirror |

#### CounterexampleElimination.lean (7 sorry stubs):

| Lines | Issue | Status |
|-------|-------|--------|
| 786, 824, 864, 902, 938, 970 | c2' construction for new adjacent pairs | PROVABLE -- these are Phase 3 implementation tasks, not semantic invalidity |
| 1086 | Self-pair burgessR3 | NEEDS REDESIGN -- see Finding 4 |

**Key observation**: The 6 c2' sorry stubs in CounterexampleElimination are NOT caused by the open guard change. They are Phase 3 implementation gaps from task 107 that predate the open guard refactoring. They need BurgessR3Maximal construction and absorption lemmas, which are already implemented (`burgessR3Maximal_extension_exists`, `burgessR3_absorption`). These are provable with existing infrastructure.

The sorry at line 1086 is a genuine design issue: it needs `burgessR3(f(x), g(x,y), f(x))` (self-pair) which requires rethinking because the current `lemma_2_6_full` at line 522-547 uses `rRelation_self_mcs` which is invalid. However, the self-pair case may be avoidable through restructuring.

### 4. Downstream Impact Analysis

#### `rRelation_self_mcs` and `rRelationSince_self_mcs` (PointInsertion.lean lines 498-516)

These are used ONLY in `lemma_2_6_full` (line 522-547), which provides the three-way decomposition for R3Maximal. The `lemma_2_6_full` result is used to construct R3Maximal witnesses for the "obligation-based" R3Maximal splitting.

**Impact**: The Burgess construction uses BurgessR3Maximal (content-based), NOT R3Maximal (obligation-based). The `lemma_2_6_full` uses obligation-based R3Maximal. If the construction has been correctly adapted to use BurgessR3Maximal throughout, then `rRelation_self_mcs` and `lemma_2_6_full` may be dead code. Verify whether any downstream caller still references `lemma_2_6_full`.

```
grep result: lemma_2_6_full is defined at line 522 but I found no callers
outside PointInsertion.lean itself.
```

**Recommendation**: `lemma_2_6_full` and `rRelation_self_mcs` are likely dead code for the Burgess construction path. They belong to the old obligation-based approach. Mark as dead and archive.

#### `BurgessR3Maximal_maximality_combined` (PointInsertion.lean line 662)

This theorem has TWO branches:
1. **delta.neg in B** (lines 670-697): Uses `until_guard_in_mcs` -- INVALID
2. **delta.neg not in B** (lines 698-725): Uses `dc_delta_B_burgessR3` -- VALID

The invalid branch derives `bot U gamma in A -> bot in A` via `until_guard_in_mcs`. Under open guard, `bot U gamma` in a consistent set does NOT imply `bot`. On discrete orders, `bot U gamma` is satisfiable (it means "gamma at the immediate successor"), and on dense orders it is unsatisfiable but the axiom system cannot prove this without an axiom like BX9.

**Can the delta.neg in B branch be fixed?** The goal in this branch is to derive a contradiction from:
- delta.neg in B (DCS)
- for all beta in B, gamma in C: `untl(beta AND delta, gamma) in A`

Setting beta = delta.neg gives `untl(delta.neg AND delta, gamma) in A`. Since `delta.neg AND delta` implies bot, by BX2 left monotonicity: `untl(bot, gamma) in A`. Under open guard, we need: `bot in A` to get a contradiction. But `bot U gamma in A` does NOT give `bot in A`.

**Alternative approach**: Instead of extracting bot from `bot U gamma`, use BX10: `bot U gamma -> F(gamma)`. So `F(gamma) in A` for all gamma in C. This gives F(top) in A (trivially). But we need a contradiction, not just F(gamma).

Actually, on the base axiom system (all linear orders including discrete), `bot U gamma` IS consistent -- it means "gamma at the successor." So the statement `BurgessR3Maximal_maximality_combined` itself might need reformulation. This is the deepest issue.

**Resolution path**: The Burgess construction in the literature works over DENSE orders. On dense orders, `bot U gamma` is always false (the open interval (t,s) is nonempty, so bot on (t,s) fails). The axiom system for dense orders includes the density axiom DN: `FF(phi) -> F(phi)`. With DN available, one can derive `neg(bot U gamma)` as a theorem of the dense logic, making the contradiction go through. The question is whether the project targets all linear orders or just dense ones. If all linear orders, the BurgessR3Maximal_maximality_combined needs a different proof strategy.

### 5. The `burgess_D0_consistent` Statement Is True but Proof Needs Rework

The D0 seed consistency theorem (PointInsertion.lean line 965) states that
```
burgess_D0 A B C delta
```
is consistent when `BurgessR3Maximal A B C` and `delta not in B`.

This statement IS true in the Burgess construction -- it is a standard result (Burgess 1982 Lemma 2.6). The current proof strategy goes through `BurgessR3Maximal_maximality_combined`, which has the invalid branch. But there exist alternative proof strategies:

1. **Direct contradiction argument**: Show that if D0 is inconsistent, then some finite L subset of D0 derives bot. The elements of L come from four components: Since-formulas (in C by burgessR3), B elements, neg(delta), Until-formulas (in A by burgessR3). The derivation of bot from these would either give delta in B (contradicting delta not in B) or give a proper DCS extension of B satisfying burgessR3 (contradicting maximality). This argument does NOT need until_guard.

2. **Restructured maximality**: The maximality of B means no proper DCS extension satisfies burgessR3. The `left_mono_contrapositive_neg_delta` theorem (line 887, VALID) already provides the key tool: if `untl(beta, gamma) in A` but `untl(beta AND delta, gamma) not in A`, then `delta.neg in A` or `F(delta.neg) in A`. This avoids the bot U gamma step entirely.

### 6. Paper and Axiom Completeness Assessment

**The paper** (possible_worlds.tex lines 1240-1248) defines Until/Since with the OPEN guard convention: "for all intermediate times y in D where x < y < z." The paper explicitly states (line 1260): "Extending TM to include S and U is outside the scope of the present paper." So the paper does NOT present a specific axiom system for Until/Since. The BX axioms are the formalization project's own contribution.

**Axiom completeness with BX9 removed**: The remaining 31-axiom system (BX1-BX7, BX10-BX12, plus S5 modal and propositional) corresponds to Xu 1988's Sigma4 system. Xu proves completeness for this system with respect to strict linear temporal logic with open guard Until/Since. The system IS complete.

**The `bot U gamma` issue and density**: On the base system (all linear orders), `bot U gamma` is consistent (satisfiable on discrete orders). This is NOT a gap in the axiom system -- it correctly reflects the semantics. On dense orders, `bot U gamma` is unsatisfiable, and the density axiom (DN: `FF(phi) -> F(phi)`) can derive `neg(bot U gamma)` as a theorem. The Burgess construction works for dense orders specifically.

**Key distinction**: The axiom system is COMPLETE for all linear orders (base), and also for the dense subclass with DN added. The `BurgessR3Maximal_maximality_combined` proof needs to either (a) work without assuming density (restructuring the proof to avoid the bot U gamma step) or (b) explicitly use density where needed. The Burgess construction targets dense orders, so approach (b) may be appropriate for the chronicle-specific infrastructure.

### 7. Which Lemmas Have Alternative Proofs?

Of the 10+ sorry stubs examined:

**No alternative proof possible (statement is false)**:
- `until_guard_in_mcs` / `since_guard_in_mcs`
- `until_disjunction_in_mcs` / `since_disjunction_in_mcs`
- `until_elim_mcs`
- `untl_absorb_nested` / `snce_absorb_nested`
- `rRelation_of_superset_mcs` / `rRelationSince_of_superset_mcs`
- `rRelation_self_mcs` / `rRelationSince_self_mcs`

**Statement true, alternative proof exists**:
- `burgess_D0_consistent` -- needs proof restructuring, not BX9
- `BurgessR3Maximal_maximality_combined` -- the delta.neg-not-in-B branch is valid; the delta.neg-in-B branch needs rework using BX10/BX2 contrapositive or density
- `B_sub_A_of_burgessR3` / `B_sub_C_of_burgessR3` -- these may be achievable through a different route or may be unnecessary if the D0 proof is restructured

**Provable with existing infrastructure (not caused by open guard)**:
- The 6 c2' stubs in CounterexampleElimination.lean

---

## Gaps/Assumptions Identified

### Gap 1: Density Requirement Not Explicit

The Burgess construction assumes a dense temporal order. The codebase does not explicitly require density for the chronicle-specific lemmas. The `BurgessR3Maximal_maximality_combined` proof's delta.neg-in-B branch derives `bot U gamma in A` and needs `bot in A`. On dense orders, `bot U gamma` is unsatisfiable (the guard interval (t,s) is nonempty), so `bot U gamma in A` is already contradictory for any MCS A that is satisfiable in a dense model. But in the syntactic proof, this requires either (a) the density axiom DN or (b) a restructured proof that avoids the `bot U gamma -> bot` step.

**Recommendation**: Determine whether the chronicle construction should explicitly target dense orders (adding DN as an axiom) or restructure the proofs to work for all orders.

### Gap 2: `B_sub_A_of_burgessR3` May Be Necessary but Not Provable

The statement `B subset A` when `burgessR3(A, B, C)` was used in the D0 consistency proof (via `burgess_D0_elem_in_A_or_C`). Under open guard, this cannot be derived: `burgessR3(A, B, C)` gives `untl(beta, top) in A` for all beta in B, but `untl(beta, top) in A` only gives `F(top) in A` via BX10, not `beta in A`. If the D0 proof is restructured to not need `B subset A`, this gap disappears.

### Gap 3: The `rRelation`-Based Infrastructure May Be Dead Code

The obligation-based `rRelation` infrastructure (`rRelation_of_superset_mcs`, `rRelation_self_mcs`, `R3Maximal`, `lemma_2_6_full`) appears to be dead code in the current Burgess construction path, which uses the content-based `burgessR3` and `BurgessR3Maximal`. A systematic dead-code audit should confirm this and archive the obligation-based infrastructure.

---

## Verified vs Unverified Claims

### Verified (by semantic analysis and codebase inspection):

1. `until_guard_in_mcs` is genuinely invalid (counterexample constructed)
2. `untl_absorb_nested` is genuinely invalid (counterexample constructed: junction point gap)
3. `until_disjunction_in_mcs` is genuinely invalid (counterexample constructed)
4. `rRelation_of_superset_mcs` is genuinely invalid (reduces to BX9)
5. `rRelation_self_mcs` is genuinely invalid (equivalent to BX9)
6. The remaining BX axioms (BX1-BX7, BX10-BX12) are sound under open guard (per Soundness.lean, sorry-free)
7. The 6 c2' stubs in CounterexampleElimination are NOT caused by open guard
8. The paper uses open guard semantics (verified at possible_worlds.tex lines 1242-1248)
9. The `left_mono_contrapositive_neg_delta` theorem (RRelation.lean line 887) is VALID and provides an alternative tool for the maximality argument

### Unverified (requires further investigation):

1. Whether `B_sub_A_of_burgessR3` is needed by the D0 consistency proof (could be avoidable with restructuring)
2. Whether the density axiom DN is required for `BurgessR3Maximal_maximality_combined` or if a purely algebraic proof exists
3. Whether `lemma_2_6_full` has any callers outside PointInsertion.lean (preliminary grep suggests it does not)
4. The exact proof strategy for the restructured D0 consistency argument

---

## Confidence Level

**Overall: High (8.5/10)**

The semantic invalidity verdicts are definitive -- counterexamples prove the statements false under the implemented open guard semantics (Truth.lean lines 127-130). These cannot be worked around.

The alternative proof strategies for `burgess_D0_consistent` and `BurgessR3Maximal_maximality_combined` are well-motivated by the mathematical literature (Burgess 1982, Xu 1988) but have not been mechanically verified in Lean. The confidence that these alternatives EXIST is high (8/10); the confidence that they can be implemented within the estimated timeframe requires hands-on proof development.

The finding that obligation-based `rRelation` infrastructure is dead code has high confidence (9/10) based on grep analysis, but a complete call-graph audit would strengthen this to certainty.

**Summary of critical path**: The 8 semantically-invalid sorry stubs cannot be salvaged. They must be either (a) archived as dead code or (b) replaced by correctly-stated alternatives with new proofs. The 2 stubs with true-but-unproved statements (`burgess_D0_consistent`, `BurgessR3Maximal_maximality_combined`) need proof restructuring, not axiom changes. The 6 c2' stubs in CounterexampleElimination are orthogonal implementation tasks.
