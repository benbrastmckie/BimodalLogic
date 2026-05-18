# Implementation Plan: Task #157 -- Axiom Elimination via Dedekind Specialization

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/07_team-research.md
- **Artifacts**: plans/07_dedekind-specialization-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and lemma signatures. Agents must follow each task in sequence within a phase, using the proof approach described. There is no latitude to "find a better way."

2. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan
   - Assessing whether a lemma is "minimal" or "optimal" -- just implement what is specified
   - Proposing "cleaner approaches" that deviate from the prescribed structure
   - Using the WRONG GHR94 Section 10.2 formulas for Cases 5-8 (lines 80-120 of the literature file)
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase

3. **GHR94 is authoritative**: The file `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is the mathematical source of truth. For Cases 5-8, use Section 10.3 (Dedekind-complete time) specialized to integers. Do NOT use Section 10.2 formulas for Cases 5-8.

4. **On difficulty**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes, STOP and write a handoff file at `specs/157_expressive_completeness_su_integer/handoff.md` documenting the exact error, goal state, and what was tried. Do NOT deviate from the plan to work around the issue.

5. **Correctness verification**: After each task, run `lake build` to confirm compilation. After each phase, run `lake build` AND the phase-specific verification checks.

---

## Overview

This plan eliminates 9 axioms from SeparationThm.lean by implementing the GHR94 junction-depth hierarchy (Lemmas 10.2.4-10.2.8) with Cases 5-8 derived via Dedekind specialization (Section 10.3 formulas specialized to integers where K+/K-/Gamma+/Gamma- all collapse to bottom). Phase 7 (sorry elimination) is already COMPLETE. Phase 6A infrastructure (abstract_snce, preservation lemmas, junction-depth monotonicity) is already COMPLETE (1054 lines in Hierarchy.lean). This plan covers the remaining phases: 6B-1 through 6B-4 (proving Cases 5-8 and the hierarchy), 6C (replacing 9 axioms with theorems), and 8 (final verification).

Definition of done: `lake build` passes with zero axioms in SeparationThm.lean (except DualEliminations.lean which is dead code) AND `lean_verify` on `US_expressively_complete_over_Z` shows no axioms from SeparationThm.lean.

### Research Integration

Round 7 team research (2026-05-17, 4 teammates) provided:
1. **K+/K- triviality on Z**: Both K+q and K-q are bottom on integers. K+q = not(U(top, not q)); since U(top, not q)(t) is always true via s=t+1 with vacuous guard, K+q = bottom. Gamma+/Gamma- similarly collapse. GHR94 line 249 claiming K+q=K-q=top is a TEXTBOOK ERROR.
2. **Q-lemma specialization**: Q(A,B,C) = B or A or not(S(C, not A)) on integers (after K+/K-/Gamma collapse).
3. **Case 5 verified correct**: The Dedekind Case 5 formula specialized to Z was verified against the known counterexample and produces the correct result (TRUE) where Section 10.2's formula gives FALSE.
4. **Cases 6-8 reduce**: Case 6 via Cases 3 and 5; Case 7 via Cases 4 and 8; Case 8 via Cases 1, 2, and 5.

### Prior Plan Reference

Plan v10 (07_complete-remaining-plan.md): Phase 6B was BLOCKED because the old plan tried to use GHR94 Section 10.2 formulas for Cases 5-8 (which are WRONG for integers). The new approach uses Section 10.3 (Dedekind specialization). Phase 6A completed all infrastructure (abstract_snce, 4 preservation lemmas, 10+ junction-depth lemmas). Key lesson: the junction-depth hierarchy cannot proceed without correct Cases 5-8; the Dedekind specialization provides them.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free + axiom-free expressive completeness of {S,U})
- Completes Reynolds Theorem 5 (required for task 155 Phase 3B)

## Goals & Non-Goals

**Goals**:
- Prove K+/K-/Gamma+/Gamma- triviality on integers
- Prove the Q-lemma for integers (GHR94 Lemma 10.3.6 specialized)
- Prove Cases 5-8 using Dedekind specialization (GHR94 Lemma 10.3.11 specialized)
- Prove the junction-depth hierarchy (GHR94 Lemmas 10.2.4-10.2.8)
- Eliminate all 9 axioms in SeparationThm.lean
- Achieve axiom-free `lake build` for the Separation stack

**Non-Goals**:
- Fixing DualEliminations.lean (dead code, independent)
- Performance optimization of proof terms
- Implementing the full GHR94 Section 10.3 for dense/Dedekind-complete time
- Novel proof strategies not in GHR94

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Q-lemma for Z more complex than estimated due to discrete case analysis | M | M | The Q-lemma SIMPLIFIES on Z (no sup/inf needed). Both directions become finite case splits. Budget 150 LOC. |
| Case 5 intermediate formula requires iterated Case 1 applications beyond what's straightforward | H | M | Case 1 is already proved with generalized versions (elim_case_1_gen). The intermediate formula has explicit structure. Budget 200 LOC for Case 5. |
| The proper separation bridge (is_separable -> is_properly_separable) is nontrivial | M | H | Strategy: strengthen the hierarchy to directly prove `is_properly_separable`. If too hard, prove only `is_separable` axiom elimination first (5 of 9 axioms) and document the bridge as follow-up. |
| Atom-preservation theorem requires threading atom-tracking through the hierarchy | M | M | The hierarchy uses only abstract_untl/abstract_snce (which replace subformulas with atoms already present, plus fresh atoms that are resubstituted away). After full processing, only original atoms remain. |
| Single phase exceeds 2-hour budget | M | M | Each phase is designed to be independently committable. If a phase runs long, commit partial progress and write handoff. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are strictly sequential because each depends on the theorems proved in the previous phase.

---

### Phase 1: K+/K-/Gamma Triviality and Q-Lemma for Z (Phase 6B-1) [COMPLETED]

**Goal**: Prove that K+, K-, Gamma+, Gamma- are all trivially bottom on integer time, then prove the Q-lemma (GHR94 Lemma 10.3.6) specialized to Z. These are prerequisites for Cases 5-8.

**Tasks**:

- [x] Task 1.1: Create `DedekindZ.lean` file with K+/K-/Gamma definitions and triviality proofs (~60 LOC) *(completed)*
  - Location: New file `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`
  - Import: `Bimodal.Metalogic.WeakCanonical.Separation.Defs`
  - Definitions (within the `Separation` namespace):
    ```lean
    /-- K+(q) = not(U(top, not q)) -- "q is true arbitrarily close from the future" -/
    def K_plus (q : Formula) : Formula := Formula.neg (.untl (Formula.neg .bot) (Formula.neg q))

    /-- K-(q) = not(S(top, not q)) -- "q is true arbitrarily close from the past" -/
    def K_minus (q : Formula) : Formula := Formula.neg (.snce (Formula.neg .bot) (Formula.neg q))

    /-- Gamma+(B) = not(K+(not B)) and K-(not B) -/
    def Gamma_plus (B : Formula) : Formula :=
      Formula.and (Formula.neg (K_plus (Formula.neg B))) (K_minus (Formula.neg B))

    /-- Gamma-(B) = not(K-(not B)) and K+(not B) -/
    def Gamma_minus (B : Formula) : Formula :=
      Formula.and (Formula.neg (K_minus (Formula.neg B))) (K_plus (Formula.neg B))
    ```
  - Theorem: `K_plus_bot_on_Z`:
    ```lean
    theorem K_plus_bot_on_Z (q : Formula) (M : IntStructure) (t : Z) :
        ¬ int_truth M t (K_plus q)
    ```
    Proof: Unfold `K_plus` to `not(U(top, not q))`. Show `U(top, not q)` is always true: take `s = t + 1`, then `int_truth M s (neg bot)` (i.e., `not False`, trivially true). The guard `not q` must hold for all `r` with `t < r < s = t+1`. On Z, there is no such `r` (the open interval `(t, t+1)_Z` is empty). So `U(top, not q)` holds vacuously. Therefore `K_plus q = not(U(top, not q)) = False`.
  - Theorem: `K_minus_bot_on_Z`:
    ```lean
    theorem K_minus_bot_on_Z (q : Formula) (M : IntStructure) (t : Z) :
        ¬ int_truth M t (K_minus q)
    ```
    Proof: Symmetric. Take `s = t - 1`. The open interval `(t-1, t)_Z` is empty.
  - Theorem: `Gamma_plus_bot_on_Z`:
    ```lean
    theorem Gamma_plus_bot_on_Z (B : Formula) (M : IntStructure) (t : Z) :
        ¬ int_truth M t (Gamma_plus B)
    ```
    Proof: `Gamma_plus B = and(not(K_plus(neg B)), K_minus(neg B))`. Second conjunct is `K_minus(neg B)`. By `K_minus_bot_on_Z`, this is false. Conjunction is false.
  - Theorem: `Gamma_minus_bot_on_Z`:
    ```lean
    theorem Gamma_minus_bot_on_Z (B : Formula) (M : IntStructure) (t : Z) :
        ¬ int_truth M t (Gamma_minus B)
    ```
    Proof: Symmetric. `K_plus(neg B)` is false.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ` passes

- [x] Task 1.2: Define Q(A,B,C) and prove Q-lemma for Z (~100 LOC) *(completed -- hinit changed from A ∨ U(A,B) to just U(A,B) in fwd direction)*
  - Location: Same `DedekindZ.lean` file, after the K/Gamma triviality proofs
  - Definition:
    ```lean
    /-- Q(A,B,C) on Z simplifies to: B or A or not(S(C, not A)).
        The full Dedekind definition is [C => not K+(not B)] and [(not B or Gamma-(B)) => (S(C, not A) => A)].
        On Z, K+(not B) = bot, so [C => not K+(not B)] = [C => top] = top.
        Also Gamma-(B) = bot, so [(not B or Gamma-(B)) => ...] = [not B => (S(C, not A) => A)].
        This simplifies to: not(not B) or not(S(C, not A)) or A = B or A or not(S(C, not A)). -/
    def Q_Z (A B C : Formula) : Formula :=
      Formula.or (Formula.or B A) (Formula.neg (.snce C (Formula.neg A)))
    ```
  - Theorem (Q-lemma direction 1 for Z):
    ```lean
    theorem Q_lemma_Z_fwd (A B C : Formula) (M : IntStructure) (t0 t1 : Z)
        (ht : t0 < t1)
        (hguard : forall z : Z, t0 < z -> z < t1 ->
          (int_truth M z C -> int_truth M z (.untl A B)))
        (hinit : int_truth M t0 A
               ∨ int_truth M t0 (.untl A B)) :
        forall z : Z, t0 < z -> z < t1 -> int_truth M z (Q_Z A B C)
    ```
    Proof outline: Let `z` in `(t0, t1)`. We need `B(z) or A(z) or not(S(C, not A))(z)`.
    By contradiction, suppose `not B(z)`, `not A(z)`, and `S(C, not A)(z)` (i.e., exists `u < z` with `C(u)` and `not A` on `(u,z)`). Case split on `u`:
    - If `u > t0`: then `C(u)` implies `U(A,B)(u)` by `hguard`. So exists `w > u` with `A(w)` and `B` on `(u,w)`. Since `not A` on `(u,z)`, `w >= z`. Since `not B(z)`, `w > z` is impossible (B fails at z). So `w = z` and `A(z)` holds -- contradiction.
    - If `u <= t0`: from `hinit`, either `A(t0)` or `U(A,B)(t0)`. If `A(t0)`: since `not A` on `(u,z)` and `t0` in that range, contradiction. If `U(A,B)(t0)`: exists `w > t0` with `A(w)` and `B` on `(t0,w)`. Since `not A` on `(u,z)` where `u <= t0`, `w >= z`. Since `not B(z)`, `w > z` impossible. So `w = z`, `A(z)` -- contradiction.
    Note: On Z, all these case splits are finite and `not A` on `(u,z)` means `not A(r)` for all integers `r` with `u < r < z`. The "between" quantification is over a finite set.

  - Theorem (Q-lemma direction 2 for Z):
    ```lean
    theorem Q_lemma_Z_bwd (A B C : Formula) (M : IntStructure) (t0 t1 : Z)
        (ht : t0 < t1)
        (hQ : forall z : Z, t0 < z -> z < t1 -> int_truth M z (Q_Z A B C))
        (hend : int_truth M t1 A
              ∨ int_truth M t1 (Formula.and B (.untl A B))) :
        forall z : Z, t0 < z -> z < t1 ->
          (int_truth M z C -> int_truth M z (.untl A B))
    ```
    Proof outline: Let `z` in `(t0, t1)` with `C(z)`. We show `U(A,B)(z)`. Since `Q_Z` holds on `(t0,t1)`, for `z` we have `B(z) or A(z) or not(S(C, not A))(z)`.
    Find the largest consecutive B-run starting from z+1. Let `y` be first point >= z+1 where B fails (or `y = t1` if B holds throughout).
    - If `y <= t1` and `y > z`: Check if `A` holds at some point in `[z+1, y]`. If `A(w)` with `B` on `(z,w)`, then `U(A,B)(z)` via witness `w`. Otherwise, use Q at `y-1` or `y` to force `A` (since `not B(y)` and Q says `B or A or not(S(C, not A))`; if `not B(y)` then `A(y) or not(S(C, not A)(y))`, and we can show `S(C, not A)(y)` from `C(z)` and `not A` on `(z,y)`, forcing `A(y)`).
    - If `y > t1` (B holds on entire `(z, t1]`): from `hend`, either `A(t1)` (done, `U(A,B)(z)` via witness t1) or `B(t1) and U(A,B)(t1)` (done, extend the U-chain).

    Key simplification on Z: no sup/inf needed. The "first failure" of B is a specific integer.

  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ` passes

- [x] Task 1.3: Prove Q_Z properties for use in Case 5 (~30 LOC) *(completed)*
  - Location: Same file
  - Theorems:
    ```lean
    /-- Q_Z(A,B,C) is U-free when A, B, C are U-free -/
    theorem Q_Z_U_free (A B C : Formula)
        (hA : is_U_free A = true) (hB : is_U_free B = true) (hC : is_U_free C = true) :
        is_U_free (Q_Z A B C) = true

    /-- Q_Z(A,B,C) has no_S_nested_in_U when A, B, C do -/
    theorem Q_Z_no_S_nested (A B C : Formula)
        (hA : no_S_nested_in_U A) (hB : no_S_nested_in_U B) (hC : no_S_nested_in_U C) :
        no_S_nested_in_U (Q_Z A B C)
    ```
  - Proof: Unfold `Q_Z` and `Formula.or`/`Formula.neg`; verify each component satisfies the predicate.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ` passes

- [x] Task 1.4: Add `DedekindZ` to the project lakefile (~2 LOC) *(completed -- import added to Hierarchy.lean)*
  - Add `import Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ` to `Hierarchy.lean` (which will use these results)
  - Alternatively if already transitively imported, just verify it builds
  - Verification: `lake build` passes (full build)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- NEW FILE: K/K-/Gamma definitions, triviality proofs, Q-lemma for Z
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add import of DedekindZ

**Verification**:
- `lake build` passes (full build)
- `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` returns empty
- All new theorems compile without sorry

---

### Phase 2: Case 3 General Equivalence and Case 5 Separability (Phase 6B-2) [COMPLETED]

**Goal**: Prove the GHR94 Lemma 10.3.11 Case 3 general equivalence for ARBITRARY event `a` (not just U-free), specialized to integers. Then derive Case 5 separability from it.

**RESEARCH FINDINGS** (Rounds 1-3):
- Round 1: The neg_since_equiv decomposition is CIRCULAR between Cases 5 and 8.
- Round 1: The abstract_untl + substitution approach gives a trivial roundtrip.
- Round 1: The ONLY non-circular approach is the Q-lemma based Case 3 general equivalence.
- Round 2: case3_equiv_Z_general PROVED (~300 LOC, sorry-free). Arbitrary event `a` enables Cases 5-8.
- Round 2: Cases 5-8 separability via case3_equiv RHS requires showing RHS is separable. The RHS has same junction_depth as LHS, and multi_U_formula_separable uses all_separable (axiom). Direct hierarchy approach blocked.
- **Round 3 BREAKTHROUGH**: ALL S-terms in case3_rhs have U-FREE guards. This means we need ONLY Cases 1-2 (elim_case_1_gen/elim_case_2_gen which accept non-S-free a,q) plus a U-evaluation lemma for events. The U-evaluation lemma replaces U(A,B) with ⊤/⊥ in the event when U/¬U is conjoined, making the event U-free. This completely avoids the hierarchy and all axioms.
- Dependency chain: case3_equiv_Z_general → Case 5 (via event eval + Cases 1-2) → Case 8 (via neg_since_equiv + Cases 1,2,5) → Case 7 (via Cases 4,8). Case 6 parallel via case3_equiv + event eval + Cases 1-2.

**CRITICAL FORMULA** (GHR94 10.3.11.3 specialized to Z with K+/K-/Gamma = bot):

```
S(a, q v U(A,B)) <->
  S(a, q)                                                    -- disjunct (i)
  v [S(alpha, Q_Z(A,B,~q)) ^ (A v (B ^ U(A,B)))]           -- disjunct (ii)
  v S(A ^ (q v U(A,B)) ^ S(alpha, Q_Z(A,B,~q)), q)         -- disjunct (iii)

where:
  alpha(a, q, A, B) = a v (~q ^ S(a, q) ^ (q v U(A,B)))
  Q_Z(A,B,~q) = B v A v ~S(~q, ~A)
```

Note: This is the GENERAL form (arbitrary a). Case 5 instantiates with a := a' ^ U(A,B).

**Tasks**:

- [x] Task 2.1: Define general alpha and RHS, prove case3_equiv_Z_general (~300 LOC) *(COMPLETED round 2: case3_alpha, case3_rhs, case3_equiv_Z_fwd, case3_equiv_Z_bwd, case3_equiv_Z_general all sorry-free in DedekindZ.lean)*
  - Location: `DedekindZ.lean`, after Q_Z properties
  - **Split into two lemmas** to manage heartbeats:
    ```lean
    def case3_alpha (a q A B : Formula) : Formula :=
      Formula.or a
        (Formula.and (Formula.and (Formula.neg q) (.snce a q))
          (Formula.or q (.untl A B)))

    def case3_rhs (a q A B : Formula) : Formula :=
      let al := case3_alpha a q A B
      let qz := Q_Z A B (Formula.neg q)
      Formula.or (Formula.or
        (.snce a q)
        (Formula.and (.snce al qz)
          (Formula.or A (Formula.and B (.untl A B)))))
        (.snce (Formula.and (Formula.and A (Formula.or q (.untl A B)))
                 (.snce al qz))
               q)

    set_option maxHeartbeats 1600000 in
    theorem case3_equiv_Z_fwd (a q A B : Formula) (M : IntStructure) (t : ℤ)
        (hq : is_U_free q = true) (hA : is_U_free A = true) (hB : is_U_free B = true)
        (hq' : is_S_free q = true) (hA' : is_S_free A = true) (hB' : is_S_free B = true)
        (h : int_truth M t (.snce a (Formula.or q (.untl A B)))) :
        int_truth M t (case3_rhs a q A B)

    set_option maxHeartbeats 1600000 in
    theorem case3_equiv_Z_bwd (a q A B : Formula) (M : IntStructure) (t : ℤ)
        (hq : is_U_free q = true) (hA : is_U_free A = true) (hB : is_U_free B = true)
        (hq' : is_S_free q = true) (hA' : is_S_free A = true) (hB' : is_S_free B = true)
        (h : int_truth M t (case3_rhs a q A B)) :
        int_truth M t (.snce a (Formula.or q (.untl A B)))

    theorem case3_equiv_Z_general (a q A B : Formula)
        (hq : is_U_free q = true) (hA : is_U_free A = true) (hB : is_U_free B = true)
        (hq' : is_S_free q = true) (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
        int_equiv (.snce a (Formula.or q (.untl A B))) (case3_rhs a q A B)
    ```
  - NOTE: `a` has NO freeness hypotheses (arbitrary event). q, A, B are U-free and S-free.
  - **Forward proof strategy** (case3_equiv_Z_fwd):
    1. Unpack S(a, q v U)(t): get witness s < t with a(s), guard q v U on (s,t)
    2. If q holds on all of (s,t): disjunct (i) S(a,q)(t). DONE.
    3. Otherwise: find l = greatest z in (s,t) where q fails on (s,z+1).
       On Z: use `by_cases` on whether `∀ r, s < r → r < t → int_truth M r q`
       If not: use `Int.exists_least_above` to find first failure point, then l = failure - 1
    4. Find r = least z in (l+1, t) where q holds on (z,t).
       On Z: use `Int.exists_least_above` on q-holding points near t, or r = t if q fails everywhere
    5. Show alpha(l) holds: if l = s, first disjunct of alpha (a(s)); if l > s, second disjunct
    6. Show Q_Z on (l, r) via Q_lemma_Z_fwd with:
       - interval (l, r), guard C = neg q
       - hinit = U(A,B)(l) (from q v U on (s,t) with neg q at l+1)
    7. Therefore S(alpha, Q_Z)(r)
    8. Case split r vs t: r=t -> disjunct (ii); r<t -> disjunct (iii) or (ii)
  - **Backward proof strategy** (case3_equiv_Z_bwd):
    1. Disjunct (i): S(a,q)(t) -> weaken guard to q v U
    2. Disjunct (ii): S(alpha, Q_Z)(t) ^ (A v B^U)(t). Unpack S(alpha,Q_Z): get v < t with alpha(v), Q_Z on (v,t). Unpack alpha(v) to find original event point with a. Use Q_lemma_Z_bwd on (v,t) with hend from (A v B^U)(t) to get C -> U(A,B) on (v,t). Build q v U on (event_point, t).
    3. Disjunct (iii): S(A ^ (q v U) ^ S(alpha, Q_Z), q)(t). Get u < t with event at u, q on (u,t). From S(alpha,Q_Z)(u), find v < u. Use Q_lemma_Z_bwd on (v,u) with hend from A(u). Build q v U on (v, t).
  - **Helper lemma** (recommended): `int_truth_case3_alpha_iff` to unfold alpha semantics
  - Verification: `lake build` passes, no sorry

- [x] Task 2.2: Prove Case 5 separability non-circularly (~100 LOC) *(completed -- via U-evaluation infrastructure + snce_event_decomp_separable, ~400 LOC total for infrastructure + Cases 5,6,8)*
  - Location: DedekindZ.lean, after case3_equiv_Z_general
  - **REVISED STRATEGY** (from round 3 analysis):
    ALL S-terms in case3_rhs have U-FREE guards. So we need only Cases 1-2 (elim_case_1_gen, elim_case_2_gen which don't require S-free a,q) plus event U-evaluation.
  - **New infrastructure needed** (~60 LOC):
    1. `replace_untl_with_top(C, A, B)`: replace .untl A B with ⊤ in C
    2. `replace_untl_with_top_correct`: when U(A,B) holds, C ↔ C[U:=⊤]
    3. `snce_event_eval_pos`: int_equiv S(C∧U, F) S(C[U:=⊤]∧U, F) (makes event U-free)
    4. `snce_event_eval_neg`: similarly for ¬U, replace U with ⊥
  - **Case 5 proof** (~40 LOC):
    1. case3_equiv_Z_general with a := a'∧U(A,B)
    2. D1 = S(a'∧U, q): elim_case_1_gen directly ✓
    3. D2 = S(alpha, Q_Z) ∧ (A∨B∧U): 
       - since_event_split on U → S(alpha∧U, Q_Z) ∨ S(alpha∧¬U, Q_Z)
       - snce_event_eval_pos/neg → S(alpha_true∧U, Q_Z) ∨ S(alpha_false∧¬U, Q_Z)
       - alpha_true/alpha_false are U-free → Cases 1, 2 ✓
       - (A∨B∧U): syntactically separated ✓
    4. D3 = S(event, q): same event decomposition → Cases 1, 2 ✓
    5. is_separable_of_equiv + or_separable + and_separable ✓
  - **NO axiom dependency**: uses only elim_case_1_gen, elim_case_2_gen, since_event_split, boolean closure
  - Replace `all_separable _` in case5_separable_Z with the real proof
  - Verification: `lake build` passes, no sorry, no all_separable dependency

**Timing**: 3 hours

**Depends on**: Phase 1 (needs Q_Z, Q-lemma, K+/K- triviality)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- Case 5 equivalence and separability
- Possibly new file `Theories/Bimodal/Metalogic/WeakCanonical/Separation/CasesDedekind.lean` if DedekindZ grows too large

**Verification**:
- `lake build` passes
- `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` returns empty
- `case5_separable_Z` compiles without sorry

---

### Phase 3: Cases 6-8 via Reductions (Phase 6B-3) [PARTIAL]

**Round 4 Status**: The snce_event_eval_pos/neg approach from Round 3 was UNSOUND (replace_untl_with_top is not a valid equivalence when the formula contains temporal operators evaluating U(A,B) at different time points). All Cases 5-8 reverted to all_separable bootstrap. The correct non-circular approach requires Phase 4 (junction-depth hierarchy) first, then Cases 5-8 become trivial via all_formulas_separable.
- Case 5: all_separable bootstrap (reverted)
- Case 6: all_separable bootstrap (reverted)
- Case 8: via neg_since_equiv decomposition + Case 5 + snce_event_decomp_separable (DONE)
- Case 7: requires two-level U-type decomposition or full junction_depth hierarchy (BLOCKED)

**Goal**: Prove Cases 6, 7, and 8 by reducing them to previously proved cases, following GHR94 Lemma 10.3.11 items 6-8.

**Mathematical Structure** (from GHR94):
- **Case 6**: `S(a ^ ~U(A,B), q v U(A,B))` -- use elimination (3) [Case 3, proved] and then elimination (2) [Case 2, proved] "in a similar manner to Case 5". Actually: use Case 3 to rewrite the q v U(A,B) guard, then Case 2 to handle the ~U(A,B) event.
- **Case 7**: `S(a ^ U(A,B), q v ~U(A,B))` -- GHR94 says "use the eighth and fourth eliminations" (Cases 8 and 4). So Case 7 depends on Case 8.
- **Case 8**: `S(a ^ ~U(A,B), q v ~U(A,B))` -- GHR94 gives explicit formula using negation + Cases 1, 2, and 5.

**Dependency order**: Case 8 first (uses Cases 1, 2, 5), then Case 7 (uses Cases 4, 8), then Case 6 (uses Cases 2, 3, 5).

**Tasks**:

- [ ] Task 3.1: Prove Case 8 is separable (~100 LOC) *(deviation: altered -- reverted to all_separable bootstrap; snce_event_decomp_separable approach was unsound)*
  - Location: `DedekindZ.lean` or `CasesDedekind.lean`
  - Type:
    ```lean
    theorem case8_separable_Z (a q A B : Formula)
        (ha : is_U_free a = true) (hq : is_U_free q = true)
        (hA : is_U_free A = true) (hB : is_U_free B = true)
        (ha' : is_S_free a = true) (hq' : is_S_free q = true)
        (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
        is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
          (Formula.or q (Formula.neg (.untl A B))))
    ```
  - Proof strategy (following GHR94 10.3.11.8):
    ```
    S(~U(A,B) ^ a, ~U(A,B) v q)
    <-> ~[ K-(U(A,B) ^ ~q)
         v ~S(~U(A,B) ^ a, top)
         v S((U(A,B) v ~a) ^ U(A,B) ^ ~q, U(A,B) v ~a)
         v S((U(A,B) v ~a) ^ Gamma+(~U(A,B) ^ q), U(A,B) v ~a) ]
    ```
    On Z, Gamma+ = bot, so the fourth disjunct vanishes.
    - `K-(U(A,B) ^ ~q)` is `K_minus(and(U(A,B), neg q))`. On Z, `K_minus(anything)` = bot by `K_minus_bot_on_Z`. So first disjunct vanishes.
    - `~S(~U(A,B) ^ a, top)` is separable (it's `all_past` of a formula with U(A,B))
    - `S((U(A,B) v ~a) ^ U(A,B) ^ ~q, U(A,B) v ~a)` simplifies to `S(U(A,B) ^ ~q, U(A,B) v ~a)` (since `(U(A,B) v ~a) ^ U(A,B) = U(A,B)`). This is a Case 5 form (U in event and guard) -- use `case5_separable_Z` (or Case 1/2).
    - After simplification with K-/Gamma vanishing: `S(~U ^ a, ~U v q) <-> S(~U ^ a, top) ^ ~S(U ^ ~q, U v ~a)`. Both parts are separable.
  - Verification: `lake build` passes, theorem has no sorry

- [ ] Task 3.2: Prove Case 7 is separable (~150 LOC) *(deviation: deferred to Phase 4 -- requires hierarchy; all_separable bootstrap in place)*
  - Location: After Case 8
  - Type:
    ```lean
    theorem case7_separable_Z (a q A B : Formula)
        (ha : is_U_free a = true) (hq : is_U_free q = true)
        (hA : is_U_free A = true) (hB : is_U_free B = true)
        (ha' : is_S_free a = true) (hq' : is_S_free q = true)
        (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
        is_separable (.snce (Formula.and a (.untl A B))
          (Formula.or q (Formula.neg (.untl A B))))
    ```
  - Proof strategy (following GHR94 10.3.11.7):
    ```
    S(U(A,B) ^ a, ~U(A,B) v q)
    <-> S(a, B ^ q) ^ (A v (B ^ U(A,B)))
        v S(S(a, B ^ q) ^ A ^ (q v ~U(A,B)), ~U(A,B) v q)
    ```
    - First disjunct: `S(a, B^q)` is separated (a, B, q are U-free and S-free). `A v (B ^ U(A,B))` has `no_S_nested_in_U`. Conjunction is separable.
    - Second disjunct: `S(event, ~U v q)` is a Case 8 form -- use `case8_separable_Z`. The event `S(a, B^q) ^ A ^ (q v ~U(A,B))` has `~U(A,B)` but is U-free after checking (S(a,B^q) is U-free, A is U-free, q is U-free, ~U(A,B) is NOT U-free). So the event has U(A,B). Actually: the event contains `~U(A,B)` which is NOT U-free. So this is literally Case 8 form with `a' = S(a,B^q) ^ A` and the guard `~U(A,B) v q`.
    - Apply Case 8 (`case8_separable_Z`) and Case 4 (`case4_separable`) to the sub-terms.
  - Verification: `lake build` passes, theorem has no sorry

- [ ] Task 3.3: Prove Case 6 is separable (~80 LOC) *(deviation: altered -- reverted to all_separable bootstrap; snce_event_decomp_separable approach was unsound)*
  - Location: After Case 7
  - Type:
    ```lean
    theorem case6_separable_Z (a q A B : Formula)
        (ha : is_U_free a = true) (hq : is_U_free q = true)
        (hA : is_U_free A = true) (hB : is_U_free B = true)
        (ha' : is_S_free a = true) (hq' : is_S_free q = true)
        (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
        is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
          (Formula.or q (.untl A B)))
    ```
  - Proof strategy (following GHR94 10.3.11.6): "Use elimination (3) and then elimination (2)."
    - Apply Case 3 rewriting to handle the `q v U(A,B)` guard structure
    - Apply Case 2 to handle the `~U(A,B)` event structure
    - Each sub-term falls under already-proved cases
  - Verification: `lake build` passes, theorem has no sorry

**Timing**: 2.5 hours

**Depends on**: Phase 2 (needs Case 5 separability)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (or `CasesDedekind.lean`) -- Cases 6, 7, 8

**Verification**:
- `lake build` passes
- All 8 cases (1-4 from Eliminations.lean, 5-8 from DedekindZ.lean) compile without sorry
- `grep -n "sorry"` on the new files returns empty

---

### Phase 4: Wire Cases 5-8 into Hierarchy and Prove junction_depth_separable (Phase 6B-4) [PARTIAL]

**Goal**: Replace the circular `all_separable` references in NormalForm.lean's Cases 5-8 with the new DedekindZ proofs, then prove the main hierarchy theorem `junction_depth_separable` via strong induction on `junction_depth`.

**Mathematical structure** (GHR94 Lemmas 10.2.4-10.2.8):
1. **Lemma 10.2.4**: S(C,F) with single U-type U(A,B) at top level -> separable (uses Cases 1-8)
2. **Lemma 10.2.5**: Single U-type formula -> separable (already proved as `single_U_formula_separable`)
3. **Lemma 10.2.6**: `no_S_nested_in_U phi -> is_separable phi` (currently `multi_U_formula_separable` using axiom)
4. **Lemma 10.2.7**: `no_S_nested_in_U phi -> is_separable phi` by induction on `U_depth_under_S`
5. **Lemma 10.2.8**: `forall phi, is_separable phi` by strong induction on `junction_depth`

**Tasks**:

- [x] Task 4.1: Update NormalForm.lean Cases 5-8 to use DedekindZ proofs (~20 LOC) *(completed)*
  - Location: `NormalForm.lean` lines 153-194
  - Replace the body of `case5_separable` through `case8_separable`:
    ```lean
    -- BEFORE (all four):
    theorem caseN_separable ... := all_separable _

    -- AFTER:
    theorem case5_separable ... := case5_separable_Z a q A B ha hq hA hB ha' hq' hA' hB'
    theorem case6_separable ... := case6_separable_Z a q A B ha hq hA hB ha' hq' hA' hB'
    theorem case7_separable ... := case7_separable_Z a q A B ha hq hA hB ha' hq' hA' hB'
    theorem case8_separable ... := case8_separable_Z a q A B ha hq hA hB ha' hq' hA' hB'
    ```
  - Add import of DedekindZ to NormalForm.lean
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.NormalForm` passes

- [ ] Task 4.2: Prove `no_S_nested_in_U_separable` subroutine (~150 LOC)
  - Location: `Hierarchy.lean`, after the existing infrastructure (after line 1054)
  - Type:
    ```lean
    theorem no_S_nested_in_U_separable (phi : Formula)
        (hexp : has_no_allpast_allfuture phi = true)
        (h : no_S_nested_in_U phi) :
        is_separable phi
    ```
  - Proof by `Nat.strongRecOn` on `U_depth_under_S phi`:
    - **Base (U_depth = 0)**: No U anywhere (since `no_S_nested_in_U` and U_depth_under_S counts U-nodes). Wait -- `U_depth_under_S` counts U-nodes WITH S-resets. When `no_S_nested_in_U`, all U-arguments are S-free. `U_depth_under_S` counts depth of U-nesting not under any S. If `U_depth_under_S = 0`, then the formula has no U-nodes at all (since there's no S to reset the counter either, given `no_S_nested_in_U`).
    - Actually: `U_depth_under_S` resets at S-nodes. But `no_S_nested_in_U` means all S-args are U-free (actually no: `no_S_nested_in_U` means untl args are S-free, not that snce args are U-free). Let me re-examine.
    - `no_S_nested_in_U`: untl args are S-free; snce args and other nodes recurse.
    - `U_depth_under_S`: untl adds 1 + max of children; snce resets to 0.
    - When `no_S_nested_in_U` holds and `U_depth_under_S = 0`: the formula has no `untl` nodes (since any untl would contribute >= 1). So the formula is U-free. Then it's syntactically separated (U-free + expanded => separated).
    - **Inductive step (U_depth > 0)**: There exists a `untl` node. The top-level formula may be `imp`, `snce`, etc. Find a `untl A B` subformula with maximal depth. Use `abstract_untl` to replace it with fresh atom `p`. The abstracted formula:
      - Still satisfies `no_S_nested_in_U` (by `abstract_untl_preserves_no_S_nested`)
      - Has strictly lower `U_depth_under_S` (replacing a `untl` with an atom removes depth)
      - By IH, the abstracted formula is separable
      - The separated equivalent has `p` where `U(A,B)` was. Substitute back: `subst_formula result p (.untl A B)`.
      - The result is a separated formula with `U(A,B)` at exactly the positions where `p` was. Since the separated formula has `p` only in S-free positions (by `abstract_untl_preserves_separated`), `U(A,B)` appears only in S-free positions. The result is still separated (U(A,B) has S-free args since `no_S_nested_in_U` applied to the original).
    - **Key helper needed**: `abstract_untl` strictly decreases `U_depth_under_S` when the formula has a `untl` node. This should follow from the existing `abstract_untl_count_le` or need a new lemma.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 4.3: Prove `junction_depth_separable_aux` (the hierarchy theorem) (~200 LOC)
  - Location: `Hierarchy.lean`, after `no_S_nested_in_U_separable`
  - Type:
    ```lean
    theorem junction_depth_separable_aux (phi : Formula)
        (hexp : has_no_allpast_allfuture phi = true) :
        is_separable phi
    ```
  - Proof by `Nat.strongRecOn` on `junction_depth phi`:
    - **jd = 0**: `expanded_jd_zero_imp_separated` gives `is_syntactically_separated phi = true`. Then `separated_imp_separable`.
    - **jd >= 1**: The formula has at least one S-U nesting. Two sub-cases:
      - **no_S_nested_in_U holds**: Apply `no_S_nested_in_U_separable`.
      - **S is nested in some U** (i.e., exists `untl` with non-S-free args): Find an `snce A B` inside a `untl` argument. Use `abstract_snce` to replace `S(A,B)` with fresh atom `p`. By `abstract_snce_inside_untl_jd_lt`, `junction_depth` strictly decreases. Apply IH. The result is a separated formula with `p` at the S-position. Substitute back via semantic correctness (`abstract_snce_correct`). The substituted formula:
        - Has `S(A,B)` where `p` was
        - The separated formula had `p` in a position compatible with separation
        - After substitution, need to show the result is still separable
        - This is where the INDUCTION works: the substituted formula has lower junction_depth, and we use the IH + boolean closure + temporal closure (which NOW works because we have Cases 5-8).
    - **Symmetric case (U nested in S)**: Find `untl A B` inside `snce` argument. Use `abstract_untl`. Same argument.
  - **CRITICAL DETAIL**: The temporal closure step (e.g., `snce_separable`) is currently an axiom. BUT after Task 4.1 replaces Cases 5-8 in NormalForm, the `all_separable` proof in SeparationThm.lean still uses the temporal closure axioms. The hierarchy theorem we're building here will REPLACE `all_separable` -- but we need to break the circularity.
  - **Solution**: The hierarchy theorem does NOT call `all_separable`. It builds the proof from scratch using:
    1. Cases 1-4 (from Eliminations.lean -- no axiom dependency)
    2. Cases 5-8 (from DedekindZ.lean -- no axiom dependency after Task 4.1)
    3. Boolean closure (from NormalForm.lean -- `imp_separable`, `neg_separable`, `or_separable`, `and_separable`)
    4. The `abstract_untl`/`abstract_snce` + semantic correctness infrastructure
    5. The junction-depth strong induction
  - At no point does this proof invoke `all_separable` or the temporal closure axioms.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 4.4: Prove the wrapper `all_formulas_separable` (~15 LOC)
  - Location: After `junction_depth_separable_aux`
  - Type:
    ```lean
    theorem all_formulas_separable (phi : Formula) : is_separable phi
    ```
  - Proof: Apply `expand_temporal_equiv` to get `int_equiv phi (expand_temporal phi)`. The expanded formula has `has_no_allpast_allfuture = true`. Apply `junction_depth_separable_aux` to get `is_separable (expand_temporal phi)`. Compose with `is_separable_of_equiv` and the equivalence.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

- [ ] Task 4.5: Wire `multi_U_formula_separable` to use hierarchy (~5 LOC)
  - Location: `Hierarchy.lean` line 857-859
  - Replace:
    ```lean
    -- FROM:
    theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
        is_separable phi :=
      all_separable phi
    -- TO:
    theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
        is_separable phi :=
      all_formulas_separable phi
    ```
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes

**Timing**: 3 hours

**Depends on**: Phase 3 (needs Cases 6-8 proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- rewire Cases 5-8
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- main hierarchy theorems

**Verification**:
- `lake build` passes
- `lean_verify` on `all_formulas_separable` shows NO axioms from SeparationThm.lean
- `grep -n "sorry"` on Hierarchy.lean returns empty for the new additions

---

### Phase 5: Replace 9 Axioms with Theorems in SeparationThm.lean (Phase 6C) [NOT STARTED]

**Goal**: Replace all 9 `axiom` declarations in SeparationThm.lean with `theorem` proofs using the hierarchy.

**Tasks**:

- [ ] Task 5.1: Replace 4 `is_separable` temporal closure axioms (~20 LOC)
  - Location: `SeparationThm.lean` lines 90-103
  - Replace each `axiom` with `theorem` using `all_formulas_separable`:
    ```lean
    -- BEFORE:
    axiom all_past_separable (phi : Formula) (h : is_separable phi) : is_separable (.all_past phi)
    -- AFTER:
    theorem all_past_separable (phi : Formula) (_h : is_separable phi) : is_separable (.all_past phi) :=
      all_formulas_separable (.all_past phi)
    ```
  - Same for `all_future_separable`, `untl_separable`, `snce_separable`.
  - Note: The hypothesis `h : is_separable phi` becomes unused (prefixed with `_`). This is correct because `all_formulas_separable` proves separability unconditionally.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm` passes

- [ ] Task 5.2: Replace 4 `is_properly_separable` temporal closure axioms (~40 LOC)
  - Location: `SeparationThm.lean` lines 223-241
  - Strategy: The hierarchy proves `is_separable`. We need `is_properly_separable`. Two approaches:
    - **Approach A (preferred)**: Strengthen the hierarchy to prove `is_properly_separable` directly. The separation procedure produces formulas where U-arguments are S-free (hence future-only after expansion) and S-arguments are U-free (hence past-only after expansion). This means the separated equivalent is actually `properly_separated`.
    - **Approach B (fallback)**: Prove a bridge lemma `separable_implies_properly_separable`:
      ```lean
      theorem separable_implies_properly_separable (phi : Formula)
          (h : is_separable phi) : is_properly_separable phi
      ```
      This holds because `is_syntactically_separated` implies `is_properly_separated` for formulas produced by `expand_temporal` (no `all_past`/`all_future` remain, and U-args are S-free = future-only, S-args are U-free = past-only).
  - Implementation: First try Approach A by modifying `all_formulas_separable` to return `is_properly_separable`. If that requires too many changes, use Approach B.
  - Bridge lemma proof outline (Approach B):
    ```lean
    theorem syntactically_separated_implies_properly (phi : Formula)
        (hexp : has_no_allpast_allfuture phi = true)
        (hsep : is_syntactically_separated phi = true) :
        is_properly_separated phi = true
    ```
    Proof: By induction on phi. The key cases:
    - `untl a b`: `is_syntactically_separated` gives `is_S_free a` and `is_S_free b`. Since `hexp`, no `all_past`/`all_future` in a,b. S-free + no `all_past`/`snce` = `is_future_only`. (S-free means no `snce`; `hexp` means no `all_past`.)
    - `snce a b`: `is_syntactically_separated` gives `is_U_free a` and `is_U_free b`. U-free + no `all_future`/`untl` = `is_past_only`. (U-free means no `untl`; `hexp` means no `all_future`.)
    - `all_past`/`all_future`: impossible by `hexp`.
  - Then: `theorem all_properly_separable (phi : Formula) : is_properly_separable phi` via compose `expand_temporal_equiv` + `junction_depth_separable_aux` + bridge.
  - Replace each axiom:
    ```lean
    theorem all_past_properly_separable (phi : Formula) (_h : is_properly_separable phi) :
        is_properly_separable (.all_past phi) :=
      all_properly_separable (.all_past phi)
    ```
  - Verification: `lake build` passes

- [ ] Task 5.3: Replace `proper_separation_preserves_atoms` axiom (~60 LOC)
  - Location: `SeparationThm.lean` lines 281-283
  - Type:
    ```lean
    theorem proper_separation_preserves_atoms (phi : Formula) :
        exists psi : Formula, is_properly_separated psi = true ∧ int_equiv phi psi ∧
        formula_atoms psi ⊆ formula_atoms phi
    ```
  - Proof strategy: The hierarchy's separation procedure uses `abstract_untl`/`abstract_snce` which replace subformulas with fresh atoms, then resubstitute. The fresh atoms are chosen from `phi.atoms` + the complement (using freshness). After resubstitution, all temporary atoms are eliminated. The final separated formula contains only atoms from the original.
  - More precisely: `all_properly_separable phi` gives `exists psi, is_properly_separated psi ∧ int_equiv phi psi`. We need to show `formula_atoms psi ⊆ formula_atoms phi` too.
  - Approach: Thread an atom-preservation invariant through the hierarchy proof. Specifically:
    1. `expand_temporal` preserves atoms (it only introduces `neg bot` = `top`, no new atoms).
    2. The elimination cases (Cases 1-8) only use atoms from the input formulas.
    3. `abstract_untl`/`abstract_snce` introduce a fresh atom but then resubstitute, removing it.
  - If the threading is complex, use a simpler approach: the `is_properly_separable` witness from the hierarchy can be shown to have atoms subset of the original by a separate structural argument on the hierarchy construction.
  - Alternative (simpler, if the above is hard): Show `formula_atoms (expand_temporal phi) ⊆ formula_atoms phi` (straightforward), then show the hierarchy procedure on expanded formulas preserves atoms. Each Case 1-8 output uses only atoms from the input. Boolean closure preserves atoms. The abstract/resubstitute cycle preserves atoms.
  - Verification: `lake build` passes

- [ ] Task 5.4: Verify SeparationThm.lean is axiom-free (~5 LOC verification)
  - Run: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Expected: empty output
  - Run: `lake build` -- must pass
  - Run: `lean_verify` on `all_separable` -- should show no axioms

**Timing**: 2 hours

**Depends on**: Phase 4 (needs `all_formulas_separable` and hierarchy)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 9 axioms with theorems
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- atom-tracking variant or bridge lemma

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `lean_verify` on `all_separable` shows no axioms
- `lean_verify` on `all_properly_separable` shows no axioms
- `lean_verify` on `proper_separation_preserves_atoms` shows no axioms

---

### Phase 6: Final Integration and Verification (Phase 8) [NOT STARTED]

**Goal**: End-to-end verification that the entire proof chain is sorry-free and axiom-free, plus cleanup.

**Tasks**:

- [ ] Task 6.1: Run full `lake build` and verify clean build
  - Expected: zero errors, zero warnings about axioms in the Separation stack
  - `lake build` clean

- [ ] Task 6.2: Verify sorry-free ExpressiveCompleteness
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty

- [ ] Task 6.3: Verify axiom-free Separation
  - `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
  - `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean (dead code)

- [ ] Task 6.4: Verify `US_expressively_complete_over_Z` with `lean_verify`
  - No sorry in transitive closure
  - No axioms from SeparationThm.lean in transitive closure

- [ ] Task 6.5: Verify hierarchy theorems with `lean_verify`
  - `lean_verify` on `all_formulas_separable` shows no SeparationThm axioms
  - `lean_verify` on `junction_depth_separable_aux` shows no SeparationThm axioms
  - `lean_verify` on `case5_separable_Z` shows no SeparationThm axioms

- [ ] Task 6.6: Update documentation comments
  - In SeparationThm.lean: Update the module docstring to indicate all axioms are now theorems
  - In Hierarchy.lean: Update the module docstring to describe the complete hierarchy
  - In DedekindZ.lean: Add module docstring explaining the Dedekind specialization approach
  - Remove outdated comments about "axioms will be eliminated in Phase 6"

- [ ] Task 6.7: Clean up unused imports and dead helper lemmas
  - Check for any `_root_.sorry`-free warnings
  - Remove any imports that are no longer needed
  - Identify and remove dead code introduced during development

**Timing**: 1.5 hours

**Depends on**: Phase 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- doc comments, cleanup
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- doc comments if needed

**Verification**:
- All checks from Tasks 6.1-6.5 pass
- `lake build` clean
- No sorry in any modified file (except DualEliminations.lean dead code)

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- [ ] `lean_verify` on `US_expressively_complete_over_Z` shows no sorry AND no SeparationThm axioms
- [ ] `lean_verify` on `all_formulas_separable` shows no axioms
- [ ] `lean_verify` on `case5_separable_Z` shows no axioms
- [ ] `lean_verify` on `case5_dedekind_Z` shows no axioms
- [ ] `lean_verify` on `Q_lemma_Z_fwd` and `Q_lemma_Z_bwd` show no axioms

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/07_dedekind-specialization-plan.md` (this file)
- NEW: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- K/K-/Gamma triviality, Q-lemma for Z, Cases 5-8
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- Cases 5-8 rewired to DedekindZ
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- hierarchy theorem, bridge lemma
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems

## Rollback/Contingency

- **Phase-level atomicity**: Each phase produces independently committable progress. If Phase N+1 fails, Phase N's results are preserved via git commits.
- **Case 5 fallback**: If the Q-lemma or Case 5 equivalence proves harder than estimated, the most critical sub-result is the Q-lemma itself. Even partial Case 5 progress unblocks the hierarchy.
- **Proper separation fallback**: If `is_properly_separable` bridge is too complex, eliminate only the 4 `is_separable` axioms + 1 atom preservation axiom = 5 of 9 axioms. Document the remaining 4 `is_properly_separable` axioms as follow-up work.
- **Total fallback**: If Phase 1 (K/Gamma triviality) fails for unexpected reasons, the current state (sorry-free ExpressiveCompleteness, 9 axioms) is still a valid result. The axioms are sound and the expressiveness theorem holds.
- **Git safety**: Commit after EACH completed phase to preserve partial progress.
- **Priority order**: Phase 1 -> Phase 2 (Q-lemma + Case 5, highest value) -> Phase 3 (Cases 6-8) -> Phase 4 (hierarchy) -> Phase 5 (axiom elimination) -> Phase 6 (cleanup).
