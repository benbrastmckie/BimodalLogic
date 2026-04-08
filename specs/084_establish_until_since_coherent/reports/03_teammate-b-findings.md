# Teammate B Findings: Pull-Before-Push and Tuple Approaches from Task 83

**Task**: 84 -- Establish Until/Since Coherence for Bundle Completeness
**Author**: Teammate B (Task 83 Report Review)
**Date**: 2026-04-08

---

## Key Findings

1. **The "pull-before-push" concept is pervasive across task 83 research** but never appears as a named standalone approach. It is the *design philosophy* underlying both the tuple construction and the enriched-seed chain approach. The core insight: F/Until obligations must be actively *pulled* (witnesses placed directly into seeds) rather than passively *pushed* (hoping x_content/g_content propagation produces them).

2. **The tuple approach is a reinvention of the quasimodel method** (GHR 1994) with a novel constraint-satisfaction framing for duration resolution. It was analyzed in detail in reports 30 (team-research, teammate-c-findings, teammate-d-findings).

3. **The backward Until direction is the single hardest sub-problem** for both approaches. Forward Until is well-understood (85% confidence). Backward Until has no clean resolution -- the Boneyard's `backward_until_chain` (DeterministicFMCS.lean:340-395) is the closest existing proof but depends on `until_intro` / `since_intro` axioms that were **removed from the BX axiom system**.

4. **Two backward Until strategies were proposed**: (a) negation unfolding contradiction via BX6, and (b) deriving `until_intro` from BX axioms. Both remain unverified in Lean.

5. **BX5 self-accumulation is the key enabler** for both approaches (report 37). It ensures the guard formula persists through intermediate chain positions without needing G-liftability.

---

## Pull-Before-Push Approach (Full Technical Details)

### Origin and Identification

The push/pull distinction was first precisely articulated in report 30 (all four teammates independently confirmed it):

> **The deterministic chain is PUSH-based (x_content determines successor), but F-resolution is PULL-based (obligation needs future witness). The push doesn't guarantee the pull.**

The gap is between:
- **Meta-level**: `neg(psi) in chain(s) for all s > t` (set membership at every position)
- **Object-level**: `G(neg(psi)) in chain(t)` (specific formula in specific set)

This conversion requires the Truth Lemma, which assumes temporal coherence (including forward_F), creating the circularity that blocked all 38 iterations of task 83.

### The Enriched-Seed Solution (Reports 38, 39)

The pull-before-push philosophy is realized concretely as the **enriched-Succ chain construction**:

**Seed at step i (forward direction):**
```
seed(w_i, i) = g_content(w_i) U scheduled_target(w_i, i) U active_untils(w_i, i)
```

Where:
- `g_content(w_i) = {alpha : G(alpha) in w_i}` -- temporal persistence (the "push" component)
- `scheduled_target(w_i, i)` -- picks one active F-formula or Until-formula from w_i using round-robin scheduling (step i mod k, where k = |subformula closure|) and places its witness directly into the seed (the "pull" component)
- `active_untils(w_i, i)` -- Until formulas that must persist forward

**Why this resolves forward_F without backward_G circularity:**
1. F(phi) in w_0 means phi needs a future witness
2. Dovetailed scheduling eventually picks phi as the target at some step j
3. At step j, phi enters the Lindenbaum seed directly
4. Lindenbaum extension preserves the seed, so phi in w_j
5. No backward_G argument is needed -- the witness is constructed by direct seed inclusion

**Seed consistency proof:**
- All elements of the enriched seed are in w_i (an MCS, hence consistent)
- Under BX1 (G(phi) -> phi, reflexive G): g_content(w_i) subset w_i
- Active Until formulas are trivially in w_i by definition
- Scheduled targets from F(phi) in w_i: phi is consistent with g_content(w_i) by existing `targeted_g_content_seed_consistent` (SuccChainFMCS.lean:2040)
- The joint consistency of `{target} U g_content(w_i) U {active Untils in w_i}` needs a new argument: target is consistent with g_content(w_i) by the standard G-lift, and active Untils are all in w_i. The question is whether the THREE-WAY combination is consistent. Task 84 team research (report 02) flagged this as an open gap.

**Until resolution via enriched seeds (forward direction):**
1. Given phi U psi in w_0, psi not in w_0
2. By BX9: phi in w_0 (guard at origin)
3. By BX5: (phi AND (phi U psi)) U psi in w_0 (self-accumulation)
4. phi U psi is placed in seed(w_0), so phi U psi in w_1 (by Lindenbaum)
5. At w_1: if psi in w_1, done. If psi not in w_1: by BX9, phi in w_1. Repeat.
6. Eventually dovetailing schedules psi for forced resolution at step j
7. Guard verification: For all i in [0, j): phi U psi in w_i (by seed propagation), psi not in w_i (by construction), so phi in w_i by BX9.

**Key insight from report 37 (BX5 self-accumulation approach):** The self-accumulated formula `(phi AND (phi U psi)) U psi` propagates itself through the canonical model. At any intermediate u where psi not in u, BX9 extracts `phi AND (phi U psi) in u`, hence `phi U psi in u`. This means the Until formula persists at every intermediate step WITHOUT needing G-liftability. This eliminates the need for any interaction axiom (Burgess-Xu axiom 4 was proven semantically INVALID under the project's guard semantics in report 37).

### Infrastructure Available

| Component | Location | Status |
|-----------|----------|--------|
| `targeted_g_content_seed_consistent` | SuccChainFMCS.lean:2040 | Sorry-free, directly reusable |
| `g_content_closed_derivation` | Frame.lean | Sorry-free |
| DovetailedChain scheduling | DovetailedChain.lean | Pattern reusable (Nat.unpair) |
| BX5 self-accumulation | Axioms/BXCanonical | Available |
| BX9 elimination | Axioms/BXCanonical | Available |
| `until_unfold_in_mcs` | Various | Derived rule available |

---

## Tuple Approach (Full Technical Details)

### Origin

The tuple approach was proposed by the user and analyzed extensively in report 30 (teammate-c-findings). Teammate C identified it as a reinvention of the quasimodel approach (GHR 1994) with novel terminology and a constraint-satisfaction framing.

### Core Definitions

**Signed Formula**: A pair (phi, s) where s in {+, -}. Write +phi (asserted true) and -phi (asserted false).

**Tuple**: A pair T = (X, Y) where:
- X = "verifier set" (formulas asserted true)
- Y = "falsifier set" (formulas asserted false)
- Negation closure: neg(psi) in X implies psi in Y, and vice versa
- Consistency: X is set-consistent (no finite subset derives bot)
- Non-contradiction: X and Y are disjoint

**Timeline Sigma**: A partial function Z -> Tuple (boolean-saturated tuples placed at integer positions). Consecutive positions satisfy x_content temporal linkage.

**Timeline Collection kappa**: A set of timelines representing different possible worlds connected by modal accessibility. All timelines share the same box-class.

### Construction Process (8 Steps)

1. **Initial Tuple**: Lambda_0 = ({phi}, {}) for the target formula phi
2. **Boolean Unpacking**: Exhaustively decompose boolean connectives (terminates by formula complexity decrease)
3. **Modal Branching**: Each diamond(psi) generates a new timeline from {psi}
4. **Temporal Task Generation**: Each F(psi) generates Task(Lambda_a, d, Lambda_b) with d > 0 and Lambda_b generated from {psi}. Each P(psi) similarly with d < 0.
5. **Transitive Closure**: Compose task constraints
6. **Universal Propagation**: G(r) in Lambda_x propagates r to all Lambda_y with y >= x. Box(chi) propagates to all timelines.
7. **Duration Resolution**: Assign concrete integers to duration variables via difference constraint satisfaction (Bellman-Ford)
8. **Closure**: Close kappa under time-shifts

### The Key Innovation: Witness-First (Pull) Philosophy

The tuple construction directly resolves the push/pull mismatch:
- **Push** (deterministic chain): x_content determines successor; F-witnesses must "happen to appear"
- **Pull** (tuple construction): F-obligations explicitly generate tasks that ensure witnesses appear; construction is designed so pulls are always satisfiable

### Duration Resolution: Always Satisfiable

Teammate C proved (report 30, Section 3) that the constraint system is always satisfiable:

1. The constraints form a system of **difference constraints** over Z: `pos(Lambda_j) - pos(Lambda_i) >= 1` for F-tasks, `pos(Lambda_j) - pos(Lambda_i) <= -1` for P-tasks
2. The F-constraint graph is a **DAG**: each F(psi) generates a task to a tuple containing psi (strictly lower complexity), so no directed F-cycles exist
3. Systems of difference constraints with acyclic positive-weight graph are always satisfiable (Bellman-Ford)
4. G(F(psi)) propagation creates infinitely many task INSTANCES but only finitely many task TYPES (bounded by subformula closure)

### Identified Gaps

1. **Until/Since handling is underspecified**: The proposal focuses on F/P but Until requires intermediate-position constraints (phi must hold at ALL positions between origin and witness, not just endpoints). Report 30 Section 4.3 explicitly flagged this: "The user's proposal does not detail how Until persistence is maintained through the construction. This is precisely the same problem that blocks the deterministic chain approach."

2. **Universal-to-existential gap**: The tuple construction correctly handles existential temporal operators (F, P, witnesses) but the gap is in universal operators (G, H) -- converting meta-level "phi at all future times" to object-level "G(phi) in the tuple" remains the fundamental obstacle (report 30, Conflict 1 resolution).

3. **Implementation cost**: Estimated 1500-2000 LOC of new Lean code, substantially more than the enriched-seed approach (600-1000 LOC). The truth lemma alone is estimated at ~500 lines.

4. **Relationship to existing infrastructure**: The tuple approach would require building much from scratch (tuple type, boolean unpacking, task generation, duration resolution, new truth lemma). The enriched-seed approach reuses ~60% of existing Bundle infrastructure.

### Correspondence to Quasimodel

| Tuple Term | Quasimodel Term | Existing Lean Concept |
|-----------|----------------|----------------------|
| Tuple | Type/Atom | RestrictedMCS (RestrictedMCS.lean) |
| Task | Eventuality pointer | F-deferral (FiniteDeferral.lean) |
| Timeline | Run/Path | FMCS Int (FMCSDef.lean) |
| Duration resolution | Unraveling | Chain construction |
| kappa | Quasimodel | BFMCS (BFMCS.lean) |

---

## Viability Assessment for Current Blockers

### The Three Sorry Sites (Completeness.lean lines 322, 356, 450)

| Approach | Forward Until | Backward Until | Forward Since | Backward Since | Overall Viability |
|----------|:---:|:---:|:---:|:---:|:---:|
| Enriched-seed (pull-before-push) | HIGH (85%) | MEDIUM (55%) | HIGH (85%) | MEDIUM (55%) | **HIGH (75%)** |
| Tuple construction | HIGH (80%) | LOW-MEDIUM (40%) | HIGH (80%) | LOW-MEDIUM (40%) | **MEDIUM (45%)** |
| Boneyard DeterministicFMCS | BLOCKED (needs forward_F) | PROVED (modulo until_intro) | BLOCKED (needs backward_P) | PROVED (modulo since_intro) | **LOW (20%)** |

### The Backward Direction Problem

Both approaches face the same backward Until challenge. The critical question is: given phi at all intermediate positions and psi at the witness, can we derive (phi U psi) at the origin?

**Three strategies identified across task 83:**

**Strategy 1 -- Negation unfolding contradiction (reports 38, 39):**
1. Assume neg(phi U psi) in w_0 for contradiction
2. Derive: neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))
3. Since phi in w_0 (given guard), neg(phi) not in w_0, so G(neg(phi U psi)) in w_0
4. This propagates neg(phi U psi) to all future w_i via g_content
5. At witness w_j: neg(phi U psi) in w_j, but psi in w_j -> phi U psi in w_j by BX8. Contradiction.

**Risk**: Step 2 requires deriving `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))` from BX1-BX10. Report 39 states this follows from BX6 (absorption) contrapositive, but this was PROVEN SEMANTICALLY INVALID by countermodel in the task 83 implementation summary (p true at 0, false at 1; q false everywhere except true at 2: neg(p U q) holds at 0 but neither neg(p) nor G(neg(p U q)) holds). **This strategy is INVALID as stated.**

**Strategy 2 -- Derive until_intro from BX axioms (reports 38, 39, Boneyard):**
The Boneyard `backward_until_chain` (DeterministicFMCS.lean:340-395) has backward Until/Since ALREADY PROVED using `until_intro : X(psi OR (phi AND (phi U psi))) -> phi U psi` and induction on the chain distance s - t. The proof is fully structured -- only the `until_intro` sorry remains at lines 371 and 395.

If `until_intro` can be derived from BX axioms (specifically, the pattern `X(psi OR (phi AND (phi U psi))) -> phi U psi`), the backward direction is immediately available. However, the BX system has no explicit Next operator X. Deriving X-based rules requires going through the deterministic chain's `x_mem_chain_general` which provides X-like behavior for chain members.

**Strategy 3 -- BX4 + BX8 + Int linearity (report 02, teammate A):**
Uses BX4 (phi -> G(P(phi))) and backward_P from temporally_coherent. Task 84 team research showed this has a gap: the P-witness u satisfies u <= s but we need u >= t, and the forward propagation of neg(phi U psi) via BX4 only gives G(P(neg(phi U psi))) which is existential-backward, not the needed universal-forward.

### Recommendation for Task 84

**Primary path: Enriched-seed chain (pull-before-push) targeting line 450 (dovetailed path).**

Reasons:
1. Forward Until/Since are HIGH confidence (85%) via BX5 self-accumulation + BX9 guard extraction + dovetailed scheduling
2. Line 450 already has sorry-free temporally_coherent, reducing dependencies
3. Infrastructure reuse is ~60% (vs ~20% for tuple approach)
4. Implementation cost is 600-1000 LOC (vs 1500-2000 for tuple)

**The backward direction remains the key risk.** The negation unfolding strategy (Strategy 1) was invalidated by countermodel. The until_intro derivation (Strategy 2) is the most promising but requires either:
- Deriving `until_intro` from BX axioms (unknown if possible)
- Adding `until_intro` as a new axiom (sound, but changes the axiom system)
- Finding a novel backward argument using BX5+BX6+BX8

**The tuple approach is a valid fallback** if the enriched-seed approach fails, but it carries higher implementation cost and the same unsolved backward Until problem. Its main advantage is conceptual clarity (witness-first, constraint satisfaction), and it could provide a cleaner architecture for future extensions to dense orders.

---

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| Push/pull mismatch is the root cause | HIGH (confirmed by all task 83 teammates) |
| Enriched-seed resolves forward Until | HIGH (85%) |
| Enriched-seed resolves forward Since | HIGH (85%) |
| Tuple approach is quasimodel reinvention | HIGH (confirmed by teammate C, report 30) |
| Duration resolution is always satisfiable | HIGH (proven by teammate C) |
| Backward Until is the critical unknown | HIGH (confirmed by all task 84 teammates) |
| Negation unfolding (Strategy 1) is invalid | HIGH (countermodel exists) |
| until_intro derivability from BX1-BX10 | LOW (unknown, no evidence either way) |
| BX5 self-accumulation enables guard verification | HIGH (proven in report 37) |
| Tuple handles Until persistence | LOW (explicitly flagged as gap in report 30) |
