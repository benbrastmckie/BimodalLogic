# Implementation Plan: Task #157 -- Axiom Elimination via GHR94 Hierarchy

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/08_team-research.md
- **Artifacts**: plans/08_axiom-elimination-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and lemma signatures. Agents must follow each task in sequence within a phase, using the proof approach described. There is no latitude to "find a better way."

2. **GHR94 is the mathematical authority.** The file `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is the primary source for all proof strategies. Every proof in this plan follows a specific GHR94 section or lemma. When in doubt, re-read the literature file at the cited line range.

3. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan or backed by GHR94
   - Assessing whether a lemma is "minimal" or "optimal" -- just implement what is specified
   - Proposing "cleaner approaches" that deviate from the prescribed structure
   - Using `neg_until_equiv` for Case 7 (this is the WRONG strategy per research Finding 1)
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase
   - Using `all_separable` anywhere in new code (this is what we are eliminating)

4. **Literature citations in this plan**: Each phase references specific GHR94 sections. The implementation agent MUST consult the literature file at the cited lines before writing proof code. If the Lean encoding diverges from the literature, the agent must verify the divergence is justified by the integer-time specialization (K+/K-/Gamma = bot) and document it in a code comment.

5. **On difficulty**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes, STOP and write a handoff file at `specs/157_expressive_completeness_su_integer/handoffs/` documenting the exact error, goal state, and what was tried. Do NOT deviate from the plan to work around the issue.

6. **Correctness verification**: After each task, run `lake build` to confirm compilation. After each phase, run `lake build` AND the phase-specific verification checks.

---

## Overview

This plan eliminates all 9 axioms from SeparationThm.lean and removes all `sorry` and circular `all_separable` references from DedekindZ.lean, completing the formalization of GHR94 Theorem 10.2.9 (Separation Theorem) for integer time.

The remaining work is: (1) fix 2 sorry in Case 6, (2) prove Case 7 via GHR94's direct formula (item 7, lines 95-101 of the literature file) which avoids the failed `neg_until_equiv` approach, (3) prove the hierarchy theorem (GHR94 Lemmas 10.2.5-10.2.8) with constructive witnesses, and (4) replace all 9 axioms with proved theorems.

Definition of done: `lake build` passes with zero `sorry` in the Separation stack (except DualEliminations.lean dead code), zero `axiom` in SeparationThm.lean, and `lean_verify` on `US_expressively_complete_over_Z` shows no SeparationThm axioms.

### Research Integration

Round 8 team research (2026-05-18, 4 teammates) provided:
1. **Case 7 direct formula** (GHR94 10.2.3 item 7, literature lines 95-101): `S(a^U, q v ~U) <-> S(A^(q v ~U)^S(a,B^q), q v ~U) v S(a,B^q)^A v S(a,B^q)^B^U`. D2 and D3 are trivially separable. D1 reduces to Cases 4+8 via `since_distrib`. No `neg_until_equiv`, no second U-type.
2. **Case 6 sorry diagnosis**: 2 sorry at DedekindZ.lean L1617/L1625 in D3 of `case6_branchB_separable`. Can be fixed by completing the d21-style `sigma_B` approach or by switching to GHR94's direct formula (10.2.3 item 6, lines 88-93).
3. **Hierarchy root cause**: All 7+ prior hierarchy attempts failed because `is_separable` uses opaque existentials. GHR94's proof constructs separated equivalents directly and substitutes into PAST CONSTITUENTS independently.
4. **Hierarchy architecture**: Strictly non-circular chain 10.2.4 -> 10.2.5 -> 10.2.6 -> 10.2.7 -> 10.2.8. The key technique is "constituent substitution."
5. **Axiom structure**: All 9 axioms derive from `all_formulas_separable`. Proving it eliminates all 9.

### Prior Plan Reference

Plan v11 (07_dedekind-specialization-plan.md) covered 6 phases:
- **Phases 1-2**: COMPLETED (K+/K-/Gamma triviality, Q-lemma, Case 3 general equivalence, Case 5 proved non-circularly).
- **Phase 3**: PARTIAL (Cases 6/7 incomplete -- Case 6 has 2 sorry, Case 7 uses `all_separable` bootstrap).
- **Phases 4-6**: NOT STARTED (hierarchy, axiom elimination, final verification).

Key lessons from prior plan: (a) `neg_until_equiv` is wrong for Case 7 (introduces second U-type); (b) `subst_formula_preserves_separated` is FALSE (round 4 discovery); (c) the d21-style approach for Case 6 D3 is tractable but was deferred due to complexity.

This plan supersedes the prior plan's Phases 3-6 with corrected strategies based on round 8 research.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free + axiom-free expressive completeness of {S,U})
- Completes Reynolds Theorem 5 (required for task 155 Phase 3B)

## Goals & Non-Goals

**Goals**:
- Fix 2 sorry in Case 6 D3 (DedekindZ.lean L1617, L1625)
- Prove Case 7 via GHR94 10.2.3 item 7 direct formula (replace `all_separable _`)
- Prove the junction-depth hierarchy (GHR94 Lemmas 10.2.5-10.2.8) with constructive witnesses
- Eliminate all 9 axioms in SeparationThm.lean
- Achieve sorry-free, axiom-free `lake build` for the entire Separation stack

**Non-Goals**:
- Fixing DualEliminations.lean (dead code, independent)
- Performance optimization of proof terms
- Implementing the full GHR94 Section 10.3 for dense/Dedekind-complete time
- Novel proof strategies not in GHR94
- Refactoring Cases 1-4 (Eliminations.lean) or Case 5 (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case 7 direct formula equivalence proof harder than estimated | M | M | The formula has 3 disjuncts, each well-understood. D2/D3 trivial. D1 reduces to Cases 4+8 (both proved). Budget 200 LOC. |
| Constituent substitution infrastructure is complex to formalize | H | H | This is the hardest part. Mitigate by implementing the simplest possible version: define `SepForm` inductive or use structural lemmas. If blocked, document and defer. |
| `is_properly_separable` bridge is nontrivial | M | H | Fallback: prove only `is_separable` axiom elimination first (5 of 9 axioms). Document proper-separation bridge as follow-up. |
| Atom-preservation theorem requires threading atom-tracking through hierarchy | M | M | After full hierarchy, atom preservation follows from the construction. Can defer to follow-up if needed (1 of 9 axioms). |
| Case 6 sorry fix more complex than 150 LOC estimate | L | M | The 2 sorry are in a well-understood region (D3 U-branch and not-U-branch of case6_branchB). Alternative: rewrite using GHR94 item 6 formula. |
| Single phase exceeds 2-hour budget | M | M | Each phase is independently committable. Write handoff on overtime. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Case 6 Sorry (2 sorry -> 0) [NOT STARTED]

**Goal**: Eliminate the 2 remaining `sorry` in `case6_branchB_separable` (DedekindZ.lean L1617, L1625), making Case 6 fully proved.

**Literature Reference**: GHR94 Lemma 10.2.3 item 6 (literature file lines 88-93). The current implementation uses `neg_until_equiv` to decompose ~U(A,B) into G(~A) v U(~A^~B, ~A), then handles Branch B (the U' = U(~A^~B, ~A) case) via case3_equiv + U^U'=bot contradiction. The 2 sorry are in D3 of Branch B where the sigma_B reduction requires d21-style congruences.

**Strategy A (preferred -- complete existing approach)**: The 2 sorry are at L1617 (D3 U-branch) and L1625 (D3 not-U-branch). The comments in the code describe the needed steps:
- L1617: Build d21-equiv of S(alpha_B, Q_Z) to sigma_B, then reduce-when-U to psi1_uf v psi2, then apply `snce_combined_U_separable`.
- L1625: Triple event-split (on U, on U') giving 3 sub-cases, each tractable via d21-equiv + congruences.

**Strategy B (fallback -- GHR94 item 6 direct formula)**: If Strategy A takes >3 hours, switch to GHR94's direct formula:
```
S(a ^ ~U, q v U) <-> [S(a, q ^ ~A) ^ ~A ^ ~(B ^ U(A,B))]
                    v S(~B ^ ~A ^ (q v U) ^ S(a, q ^ ~A), q v U)
```
Then apply eliminations (3) and (5) per GHR94.

**Tasks**:

- [ ] Task 1.1: Fix sorry at L1617 (D3 U-branch of case6_branchB_separable) (~80 LOC)
  - Location: `DedekindZ.lean` around line 1617
  - Strategy: Build the d21-equiv congruence chain:
    1. At event where U holds: `S(alpha_B, Q_Z)(s)` is equivalent to sigma_B(s)
    2. sigma_B with U(s): reduces to `psi1_uf v psi2` (U-evaluation)
    3. Full event `A^(q v U)^(psi1_uf v psi2)^U` satisfies `untl_under_bool_only` for (A,B)
    4. Apply `snce_combined_U_separable`
  - Verification: `lake build`, `grep -n "sorry" DedekindZ.lean` shows only L1625

- [ ] Task 1.2: Fix sorry at L1625 (D3 not-U-branch of case6_branchB_separable) (~100 LOC)
  - Location: `DedekindZ.lean` around line 1625
  - Strategy: Triple event-split on U and U':
    1. Sub-case U^U': contradicts U^U'=bot (already proved in D2)
    2. Sub-case U^not-U': single U-type U, apply snce_combined_U_separable
    3. Sub-case not-U^not-U': all U-free after sigma_B reduction, separable trivially
  - Verification: `lake build`, `grep -n "sorry" DedekindZ.lean` returns empty

- [ ] Task 1.3: Verify Case 6 is sorry-free and non-circular
  - Run: `lake build`
  - Run: `grep -n "sorry\|all_separable" DedekindZ.lean` -- should show only Case 7's `all_separable _`
  - Confirm `case6_separable_Z` compiles without sorry

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- fix 2 sorry in case6_branchB_separable D3

**Verification**:
- `lake build` passes
- `grep -n "sorry" DedekindZ.lean` returns empty (no sorry remaining)
- `case6_separable_Z` compiles without sorry or `all_separable`

---

### Phase 2: Case 7 via GHR94 Direct Formula [NOT STARTED]

**Goal**: Replace the circular `all_separable _` in `case7_separable_Z` (DedekindZ.lean L1659) with a real proof using GHR94 10.2.3 item 7's direct decomposition.

**Literature Reference**: GHR94 Lemma 10.2.3 item 7 (literature file lines 95-101):
```
S(a ^ U(A,B), q v ~U(A,B))
<-> [S(A ^ (q v ~U) ^ S(a, B ^ q), q v ~U)]          -- D1
  v [S(a, B ^ q) ^ A]                                  -- D2
  v [S(a, B ^ q) ^ B ^ U(A,B)]                         -- D3
```

GHR94 says: "By considering when A is true we deduce..." and "The first disjunct can be further eliminated by eliminations (8) and (4)."

**CRITICAL**: This approach does NOT use `neg_until_equiv`. No second U-type is introduced. This is the corrected strategy from the round 8 research.

**Tasks**:

- [ ] Task 2.1: Prove the Case 7 semantic equivalence (~150 LOC)
  - Location: `DedekindZ.lean`, replace the current `case7_separable_Z` proof body
  - Define the Case 7 RHS:
    ```lean
    def case7_rhs (a q A B : Formula) : Formula :=
      let Sa_Bq := Formula.snce a (Formula.and B q)
      let D1_event := Formula.and (Formula.and A (Formula.or q (Formula.neg (.untl A B)))) Sa_Bq
      let D1 := Formula.snce D1_event (Formula.or q (Formula.neg (.untl A B)))
      let D2 := Formula.and Sa_Bq A
      let D3 := Formula.and (Formula.and Sa_Bq B) (.untl A B)
      Formula.or (Formula.or D1 D2) D3
    ```
  - Prove:
    ```lean
    theorem case7_equiv_Z (a q A B : Formula) :
        int_equiv (.snce (Formula.and a (.untl A B))
                         (Formula.or q (Formula.neg (.untl A B))))
                  (case7_rhs a q A B)
    ```
  - **Forward proof** (S(a^U, q v ~U)(t) -> RHS(t)):
    Get witness s < t with a(s), U(A,B)(s), and (q v ~U) on (s,t).
    From U(A,B)(s): exists w > s with A(w) and B on (s,w).
    Case split on w vs t:
    - w > t or w = t: B on (s,t), so B^q on (s,t) (from guard: each r in (s,t) has q(r) or ~U(r); if ~U(r) then... but B holds on (s,w) with w >= t). Actually need careful analysis.
    - w <= t: A(w) holds. Case split on w:
      - w = t: not possible (w > s, but need A at w and w in (s,t])
      - w in (s,t): A(w) in the interval. S(a, B^q) from a(s) and B^q on (s,w). Then D2 or D1.
    The key insight from GHR94: "by considering when A is true" -- find the FIRST time A is true after s.
  - **Backward proof**: Each disjunct implies S(a^U, q v ~U):
    - D2: S(a, B^q)(t) ^ A(t). Unpack S: s < t, a(s), B^q on (s,t). U(A,B)(s) via A(t) and B on (s,t). Guard: q on (s,t) implies q v ~U on (s,t).
    - D3: S(a, B^q)(t) ^ B(t) ^ U(A,B)(t). Unpack S: s < t, a(s), B^q on (s,t). U(A,B)(s) via U(A,B)(t) and B on (s,t). Guard: q on (s,t) implies q v ~U.
    - D1: S(event, q v ~U)(t) where event = A ^ (q v ~U) ^ S(a, B^q). Get r < t with event(r), guard on (r,t). From S(a,B^q)(r): s < r, a(s), B^q on (s,r). From A(r) and B on (s,r): U(A,B)(s). Build S(a^U, q v ~U)(t).
  - Verification: `lake build`, `case7_equiv_Z` compiles without sorry

- [ ] Task 2.2: Prove Case 7 separability from the equivalence (~80 LOC)
  - Location: `DedekindZ.lean`, replace `case7_separable_Z` body
  - Strategy: Apply `is_separable_of_equiv (case7_equiv_Z ...)` then show each disjunct is separable:
    - **D2** = `S(a, B^q) ^ A`: `S(a, B^q)` is U-free (a, B, q all U-free and S-free). `A` is an atom (S-free and U-free). Product is separable via `and_separable`.
    - **D3** = `S(a, B^q) ^ B ^ U(A,B)`: `S(a, B^q)` is U-free (past). `B ^ U(A,B)` is S-free (future). Product is separable (boolean of separated terms).
    - **D1** = `S(A ^ (q v ~U) ^ S(a, B^q), q v ~U)`: The event contains `~U(A,B)` and `S(a,B^q)`, the guard has `~U(A,B)`. Use `since_distrib_or_left` on the guard `q v ~U`:
      - `S(event, q)`: event contains `(q v ~U)` factor. When guard is q (U-free), the S-formula has ~U in event. Factor out:
        - `S(A ^ q ^ S(a,B^q), q)`: U-free event and guard -> already separated (Case 0)
        - `S(A ^ ~U ^ S(a,B^q), q)`: ~U in event, q U-free guard -> Case 2 form (handled by `elim_case_2_gen`)
      - `S(event, ~U)`: both event and guard contain ~U -> **Case 8** form (already proved via `case8_separable_Z`)
    - Apply `or_separable` to combine. Each sub-case uses only Cases 2, 4, 8 (all proved).
  - Remove old `case7_separable_Z` body (the `all_separable _` line) and replace with real proof.
  - Verification: `lake build`, `grep -n "all_separable" DedekindZ.lean` returns empty

**Timing**: 2 hours

**Depends on**: none (Cases 2, 4, 8 already proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- replace case7_separable_Z with real proof

**Verification**:
- `lake build` passes
- `grep -n "sorry\|all_separable" DedekindZ.lean` returns empty
- All 8 cases (1-4 in Eliminations.lean, 5-8 in DedekindZ.lean) compile without sorry or all_separable
- `case7_separable_Z` has no axiom dependency

---

### Phase 3: Hierarchy Theorem (GHR94 Lemmas 10.2.5-10.2.8) [NOT STARTED]

**Goal**: Prove `all_formulas_separable` by implementing the GHR94 hierarchy with constructive witnesses, replacing the circular `all_separable` in Hierarchy.lean.

**Literature Reference**: GHR94 Lemmas 10.2.5-10.2.8 (literature file lines 140-220). The hierarchy is strictly non-circular:
- **10.2.5** (lines 145-155): Single U-type by S-nesting induction
- **10.2.6** (lines 159-171): Multi U-type by count induction, constituent substitution (line 169)
- **10.2.7** (lines 175-187): no_S_nested_in_U by U-nesting depth, constituent substitution (line 185)
- **10.2.8** (lines 189-220): All formulas by junction_depth, constituent substitution (line 218)

**KEY TECHNIQUE** (GHR94 lines 169, 185, 218): After abstracting and separating, the separated form E' is a boolean combination of atoms, pure-future terms (U-formulas), and pure-past terms (S-formulas). Substitute back into each PAST CONSTITUENT of E' independently, then apply the induction hypothesis to each. This works because each constituent has strictly lower complexity. **Never substitute into the whole formula.**

**CRITICAL ROOT CAUSE FIX**: Prior hierarchy attempts used opaque existentials (`is_separable = exists psi, ...`). The correct approach constructs the separated equivalent DIRECTLY. This phase must use constructive witnesses throughout.

**Tasks**:

- [ ] Task 3.1: Define constituent extraction infrastructure (~100 LOC)
  - Location: `Hierarchy.lean`, after the existing infrastructure (after line 1054)
  - Define types for tracking separated structure:
    ```lean
    /-- A separated decomposition: boolean combination of atoms, future terms, past terms.
        The key property is that we can substitute into past terms independently. -/
    structure SepDecomp where
      formula : Formula
      is_sep : is_syntactically_separated formula = true
      equiv_to : Formula  -- the original formula this is equivalent to
      equiv_proof : int_equiv equiv_to formula
    ```
  - Define past-constituent substitution:
    ```lean
    /-- Substitute φ for atom p in all past (S-containing) constituents of a
        separated formula, leaving future constituents unchanged. -/
    def subst_past_constituents (sep : Formula) (p : Atom) (φ : Formula) : Formula
    ```
  - Prove: `subst_past_constituents` preserves the boolean structure and only affects S-terms containing `p`.
  - Key lemma: when `sep` is syntactically separated and `p` only appears in past terms, substituting a past formula for `p` yields a formula whose past constituents can be individually separated by the IH.
  - Verification: `lake build`

- [ ] Task 3.2: Prove single-U-type separability (GHR94 Lemma 10.2.5) (~150 LOC)
  - Location: `Hierarchy.lean`
  - Type:
    ```lean
    theorem single_U_type_separable (phi A B : Formula)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hsingle : has_single_U_type phi A B) :
        is_separable phi
    ```
  - Proof by induction on k = max S-nesting depth above U(A,B) in phi.
    - k=0: phi has U(A,B) not under any S. phi is already a boolean combination of atoms and U(A,B). This is syntactically separated.
    - k>0: Find the deepest S(C,F) containing U(A,B). This matches one of Cases 1-8 (Lemma 10.2.4). Apply the case. The result has lower k. Apply IH.
  - Uses Cases 1-8 from Eliminations.lean and DedekindZ.lean (all proved non-circularly).
  - Does NOT use `all_separable` or any temporal closure axiom.
  - Verification: `lake build`, `lean_verify single_U_type_separable` shows no SeparationThm axioms

- [ ] Task 3.3: Prove multi-U-type separability (GHR94 Lemma 10.2.6) (~200 LOC)
  - Location: `Hierarchy.lean`
  - Type:
    ```lean
    theorem multi_U_type_no_S_in_U_separable (phi : Formula)
        (h : no_S_nested_in_U phi) :
        is_separable phi
    ```
  - Proof by induction on n = number of distinct U-types in phi.
    - n=0: phi is U-free, hence syntactically separated.
    - n=1: Apply `single_U_type_separable`.
    - n>1: Per GHR94 line 167-169:
      1. Pick one U-type U(An, Bn).
      2. Replace all other U(Ai, Bi) (i < n) with fresh atoms qi to get phi'.
      3. phi' has single U-type -> apply `single_U_type_separable` -> separated E'.
      4. E' is a boolean combination of atoms (including qi), U(An,Bn) (future), and S-terms (past).
      5. Substitute U(Ai,Bi) back for qi in each PAST CONSTITUENT of E'. Each constituent now has n-1 U-types.
      6. Apply IH to each past constituent. Result is separable.
      7. Reassemble the boolean combination.
  - The constituent-substitution step is the critical one. Use `subst_past_constituents` from Task 3.1.
  - Verification: `lake build`, `lean_verify multi_U_type_no_S_in_U_separable` shows no SeparationThm axioms

- [ ] Task 3.4: Prove no_S_nested_in_U separability (GHR94 Lemma 10.2.7) (~150 LOC)
  - Location: `Hierarchy.lean`
  - Type:
    ```lean
    theorem no_S_nested_in_U_separable_v2 (phi : Formula)
        (h : no_S_nested_in_U phi) :
        is_separable phi
    ```
  - Proof by induction on max depth of U-nesting beneath S.
    - depth 1: All U-args are S-free/U-free atoms/booleans. Apply `multi_U_type_no_S_in_U_separable`.
    - depth >1: Per GHR94 line 180-185:
      1. Find maximal U(Ai, Bi) where Ai, Bi contain nested U-subformulas U(Xij, Yij).
      2. Replace each U(Xij, Yij) in Ai, Bi with fresh atoms zij -> get U(A'i, B'i).
      3. Replace U(Ai, Bi) with U(A'i, B'i) in phi -> phi' satisfies `multi_U_type_no_S_in_U` -> separate to E'.
      4. Substitute U(Xij, Yij) back for zij in past constituents of E'. Each has lower U-nesting depth.
      5. Apply IH to each. Reassemble.
  - NOTE: This may be combined with Task 3.3 into a single well-founded induction to reduce complexity. The implementation agent may merge 10.2.6 and 10.2.7 into a single lemma if that simplifies the Lean formalization, provided the result is equivalent.
  - Verification: `lake build`

- [ ] Task 3.5: Prove junction-depth separability (GHR94 Lemma 10.2.8) (~200 LOC)
  - Location: `Hierarchy.lean`
  - Type:
    ```lean
    theorem junction_depth_separable_aux (phi : Formula)
        (hexp : has_no_allpast_allfuture phi = true) :
        is_separable phi
    ```
  - Proof by `Nat.strongRecOn` on `junction_depth phi`. Per GHR94 lines 189-220:
    - jd = 0 or 1: phi is syntactically separated -> `separated_imp_separable`.
    - jd >= 2: Per GHR94 line 212-218:
      - phi = S(D1, D2). Find S(E,F) nested inside a U-argument of some U(Ai, Bi).
      - Use `abstract_snce` to replace S(E,F) with fresh atom zij -> get U(A'i, B'i).
      - Replace U(Ai,Bi) with U(A'i,B'i) -> phi' has `no_S_nested_in_U`.
      - Apply `no_S_nested_in_U_separable_v2` -> separated E'.
      - Substitute S(E,F) back for zij in past constituents. Each has junction_depth < jd (strict decrease from `abstract_snce_inside_untl_jd_lt`, already proved in Hierarchy.lean infrastructure).
      - Apply IH to each constituent. Reassemble.
    - Symmetric case: U(E,F) nested inside S-argument. Use `abstract_untl` (dual).
  - Uses the junction_depth decrease lemmas already in Hierarchy.lean (lines 900-1054).
  - Does NOT call `all_separable` or any temporal closure axiom.
  - Verification: `lake build`, `lean_verify junction_depth_separable_aux` shows no SeparationThm axioms

- [ ] Task 3.6: Prove `all_formulas_separable` wrapper (~20 LOC)
  - Location: `Hierarchy.lean`
  - Type:
    ```lean
    theorem all_formulas_separable (phi : Formula) : is_separable phi
    ```
  - Proof: Apply `expand_temporal_equiv` to get `int_equiv phi (expand_temporal phi)`. The expanded formula has `has_no_allpast_allfuture = true`. Apply `junction_depth_separable_aux`. Compose with `is_separable_of_equiv`.
  - Verification: `lake build`, `lean_verify all_formulas_separable` shows no SeparationThm axioms

- [ ] Task 3.7: Replace `multi_U_formula_separable` and friends (~10 LOC)
  - Location: `Hierarchy.lean` line 858-860
  - Replace `all_separable phi` with `all_formulas_separable phi` in `multi_U_formula_separable` and all corollaries that currently use `all_separable`.
  - Verification: `lake build`, `grep -n "all_separable" Hierarchy.lean` returns empty (except comments)

**Timing**: 6 hours

**Depends on**: Phase 1 (Case 6 sorry-free), Phase 2 (Case 7 proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- hierarchy theorem, constituent infrastructure, all_formulas_separable

**Verification**:
- `lake build` passes
- `lean_verify all_formulas_separable` shows NO SeparationThm axioms
- `lean_verify junction_depth_separable_aux` shows NO SeparationThm axioms
- `grep -n "sorry" Hierarchy.lean` returns empty
- `grep -n "all_separable" Hierarchy.lean` returns empty (except comments)

---

### Phase 4: Replace 9 Axioms with Theorems [NOT STARTED]

**Goal**: Replace all 9 `axiom` declarations in SeparationThm.lean with `theorem` proofs derived from `all_formulas_separable`.

**Literature Reference**: GHR94 Theorem 10.2.9 (literature line 222). Once `all_formulas_separable` is proved, every formula is separable, which trivially implies temporal closure.

**Tasks**:

- [ ] Task 4.1: Replace 4 `is_separable` temporal closure axioms (~20 LOC)
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
  - Note: The hypothesis `h` becomes unused (prefix with `_`).
  - Verification: `lake build`

- [ ] Task 4.2: Replace 4 `is_properly_separable` temporal closure axioms (~60 LOC)
  - Location: `SeparationThm.lean` lines 223-241
  - Strategy: Prove bridge lemma `syntactically_separated_implies_properly`:
    ```lean
    theorem syntactically_separated_implies_properly (phi : Formula)
        (hexp : has_no_allpast_allfuture phi = true)
        (hsep : is_syntactically_separated phi = true) :
        is_properly_separated phi = true
    ```
    Proof: By induction on phi. Key cases:
    - `untl a b`: `is_syntactically_separated` gives `is_S_free a ^ is_S_free b`. With `hexp` (no all_past/all_future), S-free = is_future_only.
    - `snce a b`: Dually, U-free = is_past_only.
    - `all_past`/`all_future`: impossible by `hexp`.
  - Then prove `all_properly_separable_v2 (phi : Formula) : is_properly_separable phi` by composing `expand_temporal_equiv` + `junction_depth_separable_aux` + bridge.
  - Replace each axiom with theorem using `all_properly_separable_v2`.
  - Verification: `lake build`

- [ ] Task 4.3: Replace `proper_separation_preserves_atoms` axiom (~80 LOC)
  - Location: `SeparationThm.lean` lines 281-283
  - Strategy: Thread atom-preservation through the hierarchy construction:
    1. `expand_temporal` preserves atoms (introduces only `neg bot` = `top`).
    2. Cases 1-8 use only atoms from input formulas.
    3. `abstract_untl`/`abstract_snce` introduce fresh atom then resubstitute, removing it.
    4. Boolean closure preserves atoms.
  - Prove:
    ```lean
    theorem proper_separation_preserves_atoms (phi : Formula) :
        exists psi : Formula, is_properly_separated psi = true ^ int_equiv phi psi ^
        formula_atoms psi <= formula_atoms phi
    ```
  - If full atom-tracking is too complex, use the simpler fact: `all_formulas_separable` produces a witness whose atoms are a subset (by construction, since no new atoms are introduced). This may require modifying `all_formulas_separable` to return an explicit witness with atoms tracked.
  - **Fallback**: If this task takes >2 hours, leave it as the sole remaining axiom and document as follow-up. The other 8 axiom eliminations are still high value.
  - Verification: `lake build`

- [ ] Task 4.4: Verify SeparationThm.lean is axiom-free
  - Run: `grep -rn "^axiom" SeparationThm.lean`
  - Expected: empty output
  - Run: `lake build` -- must pass
  - Run: `lean_verify all_separable` -- should show no axioms

- [ ] Task 4.5: Remove `all_separable` import cycle
  - `Hierarchy.lean` currently imports `SeparationThm.lean` (for `all_separable`). After Phase 3 replaces all uses, remove this import if no longer needed.
  - Update `SeparationThm.lean` to import `Hierarchy.lean` instead (for `all_formulas_separable`).
  - This reverses the dependency direction: SeparationThm now depends on Hierarchy, not vice versa.
  - Verification: `lake build`

**Timing**: 4 hours

**Depends on**: Phase 3 (needs `all_formulas_separable`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 9 axioms with theorems, update imports
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- possibly remove SeparationThm import

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" SeparationThm.lean` returns empty
- `lean_verify all_separable` shows no axioms
- `lean_verify all_properly_separable` shows no axioms
- `lean_verify proper_separation_preserves_atoms` shows no axioms

---

### Phase 5: Final Integration and Verification [NOT STARTED]

**Goal**: End-to-end verification that the entire proof chain is sorry-free and axiom-free, plus documentation cleanup.

**Tasks**:

- [ ] Task 5.1: Run full `lake build` and verify clean build
  - Expected: zero errors, zero warnings about axioms in the Separation stack

- [ ] Task 5.2: Verify sorry-free Separation stack
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` -- should return only DualEliminations.lean (dead code)
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty

- [ ] Task 5.3: Verify axiom-free SeparationThm
  - `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty

- [ ] Task 5.4: Verify with `lean_verify`
  - `lean_verify` on `US_expressively_complete_over_Z`: no sorry, no SeparationThm axioms
  - `lean_verify` on `all_formulas_separable`: no SeparationThm axioms
  - `lean_verify` on `case7_separable_Z`: no SeparationThm axioms
  - `lean_verify` on `case6_separable_Z`: no SeparationThm axioms

- [ ] Task 5.5: Update documentation comments
  - In SeparationThm.lean: Update module docstring to indicate all axioms are now theorems
  - In Hierarchy.lean: Update module docstring to describe the complete hierarchy
  - Remove outdated comments about "axioms will be eliminated in Phase 6"

- [ ] Task 5.6: Clean up unused imports and dead code
  - Check for unused imports in Hierarchy.lean (especially `SeparationThm` if removed)
  - Remove dead helper lemmas introduced during development

**Timing**: 2 hours

**Depends on**: Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- doc comments, cleanup
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- doc comments if needed

**Verification**:
- All checks from Tasks 5.1-5.4 pass
- `lake build` clean
- No sorry in any modified file (except DualEliminations.lean dead code)

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` returns empty
- [ ] `grep -rn "all_separable" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` returns empty
- [ ] `grep -rn "all_separable" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` returns only comments
- [ ] `lean_verify` on `US_expressively_complete_over_Z` shows no sorry AND no SeparationThm axioms
- [ ] `lean_verify` on `all_formulas_separable` shows no axioms
- [ ] `lean_verify` on `case7_separable_Z` shows no axioms
- [ ] `lean_verify` on `case6_separable_Z` shows no axioms

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/08_axiom-elimination-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- Case 6 sorry fix, Case 7 real proof
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- hierarchy theorem, constituent infrastructure, all_formulas_separable
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- import updates if needed

## Rollback/Contingency

- **Phase-level atomicity**: Each phase produces independently committable progress. If Phase N+1 fails, Phase N's results are preserved via git commits.
- **Case 6 fallback**: If Strategy A (fix existing d21-style approach) takes >3 hours, switch to GHR94 item 6 direct formula (Strategy B).
- **Case 7 confidence**: HIGH. The direct formula from GHR94 is explicitly decomposed into D1/D2/D3. D2/D3 are trivially separable. D1 reduces to Cases 4+8 (both already proved).
- **Hierarchy fallback**: If the full 4-layer hierarchy (10.2.5-10.2.8) proves too complex to formalize in one phase, implement a simplified 2-layer version (10.2.7 direct + 10.2.8). This sacrifices modularity but achieves the same end result.
- **Proper separation fallback**: If `is_properly_separable` bridge is too complex, eliminate only the 4 `is_separable` axioms first (highest value). Document the remaining 4 `is_properly_separable` + 1 atom preservation as follow-up.
- **Minimum viable target**: Cases 6+7 sorry-free (Phases 1-2) is independently valuable even if hierarchy/axiom elimination is deferred.
- **Git safety**: Commit after EACH completed phase to preserve partial progress.
