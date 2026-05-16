# Teammate D Findings: Strategic Horizons for Task 154

**Task**: 154 - sum_preservation_ef_games
**Artifact**: 05 (round 5), Teammate D
**Date**: 2026-05-15
**Focus**: Strategic analysis - criticality, refactoring, best practices, architecture alternatives, effort projection

---

## Key Findings

### 1. Criticality: What Task 154 Unblocks

Task 154 is on the **primary critical path to sorry-free `bx_completeness`**. The dependency chain from ROADMAP.md and Transfer.lean:

```
task 154 (sum_preservation)
  -> chronicle_is_good (via very_good_implies_good)
     -> contemp_equiv_is_equiv transitivity
        -> no_gaps_discrete
           -> one_class
              -> chronicle_is_good (closes the chain)
  -> task 155 (activate Reynolds pipeline)
     -> sorry-free bx_completeness
```

The `chronicle_is_good` theorem in IntegerModel.lean (line 211) has a sorry that explicitly says it depends on `very_good_implies_good`, which in turn requires `sum_preservation` (Doets 1.4). Transfer.lean Step 3 (line 104) is "SORRY" specifically waiting on `chronicle_is_good -> sum_preservation`.

**IntegerModel.lean sorries blocked by task 154**:
- `finite_structures_good` (line 84-90): sorry, needs Doets Theorem 1.1 (k-type realizability), but its usages depend on sum_preservation for transitivity
- `contemp_equiv_is_equiv` transitivity (line 125-128): sorry, explicitly "depends on sum_preservation for combining subintervals"
- `no_gaps_discrete` (line 140-145): sorry, "the genuine argument uses properties of good structures"
- `very_good_implies_good` (line 199-202): sorry, explicitly "requires sum_preservation (Doets Lemma 1.4)"
- `chronicle_is_good` (line 211-214): sorry, "depends on very_good_implies_good which depends on sum_preservation"

**Alternative paths**: There are NO alternative paths to `chronicle_is_good` or `bx_completeness` that bypass `sum_preservation`. The ROADMAP confirms the Chronicle fallback (`dd_countermodel_chronicle_discrete`) remains active in Transfer.lean, but this only provides a working proof, not a sorry-free one. The 1 remaining sorry that blocks `bx_completeness` on the critical path is `succ_cofinal` in ChronicleToCountermodel.lean; the Reynolds pipeline (tasks 154-155) bypasses that sorry. Without task 154, the Reynolds pipeline cannot be activated.

**Criticality verdict**: Task 154 is irreplaceable. There is no detour.

---

### 2. Factoring into SumPreservation.lean: Tradeoff Analysis

**Current situation**: `build_bicompat` (~300 lines) and `sum_lift_one_var` (~80 lines) are inside NEquivalence.lean (1133 lines total). These contain 15 build errors in `build_bicompat` and `sum_lift_one_var`.

**Case FOR factoring**:
- **Isolation of failure surface**: The 15 errors are all in these two definitions. A separate `SumPreservation.lean` would compile independently, allowing `lake build Bimodal.Metalogic.WeakCanonical.SumPreservation` to surface errors in isolation without the noise from other modules.
- **Faster iteration**: The current file has ~1133 lines. Lean elaboration runs on the whole file; a smaller file reduces elaboration time. Prototyped changes to `build_bicompat` would be testable in 5-15 seconds instead of 30+ seconds.
- **Cleaner separation of concerns**: NEquivalence.lean is nominally about the k-equivalence framework (KType, k_equiv, k_equiv_monotone, KEquivalenceFramework), not about internal proof machinery.
- **Plan rollback already recommends it**: Plan v6 Phase 2 risk mitigation states: "If elaboration times exceed 30 seconds, factor `build_bicompat` into a separate file `Theories/Bimodal/Metalogic/WeakCanonical/SumPreservation.lean`".

**Case AGAINST factoring**:
- **Adds a compilation dependency**: A new file means a new import in NEquivalence.lean and lake caching complexity.
- **Temporary complexity**: If the 15 errors are fixable in 1-2 implementation rounds, the overhead of refactoring outweighs the benefit.
- **Private declarations don't benefit**: `build_bicompat`, `sum_lift_one_var`, `CompData`, `orderedSum_order_fwd_via_comp`, `orderedSum_order_bwd_via_comp` are all `private`. They must live in the same file as their callers unless made non-private.

**Resolution**: Factoring is worthwhile IF the errors prove resistant to 2+ more rounds. The `private` barrier is the key constraint. Making these definitions non-private (or `internal`) so they can live in `SumPreservation.lean` is a 5-minute change. The compilation speed benefit is real. Recommended trigger: if the next implementation round does not resolve all 15 errors, factor into `SumPreservation.lean` as a priority.

---

### 3. Lean 4 Dependent Type Best Practices

**The specific problems**:

The 15 errors fall into 4 categories (from build output):

**Category 1 (lines 548-550, 629-631): "Invalid projection on Fin.cons"**
```
Invalid projection: Type of Fin.cons (have this := ⟨j, c⟩; ?m) ?m p is not known; cannot resolve projection .1
```
The Lean elaborator cannot infer that `Fin.cons (show T from ⟨j, c⟩) env_M p` has type `Sigma (...)` when `T` is a metavariable. The `.1` projection fails because the type is not determined.

**Fix pattern**: Replace `(Fin.cons (show T from ...) env_M p).1` with a let-binding or explicit annotation:
```lean
-- BEFORE (fails): (Fin.cons (show T from ⟨j, c⟩) env_M p).1
-- AFTER (works): let x : T := ⟨j, c⟩; (Fin.cons x env_M p).1
-- OR: change the proof to use Fin.cases rfl (fun k => h_idx k)
-- instead of the lambda form that requires projection
```

The `h_idx'` construction (line 550) has a type mismatch: `h_idx k` has type `(env_M k).fst = (env_N k).fst` but Lean expects `?m.849 k.succ = ?m.850 k.succ`. This is because the metavariable types of the new environments are not resolved. The fix: annotate the `have h_idx'` with explicit types:
```lean
have h_idx' : ∀ p : Fin (n + 1),
    (Fin.cons (⟨j, c⟩ : (orderedSum sig I ms).carrier) env_M p).1 =
    (Fin.cons (⟨j, c'⟩ : (orderedSum sig I ms').carrier) env_N p).1 :=
  Fin.cases rfl (fun k => h_idx k)
```

**Category 2 (lines 788, 792, 794, 800, 802): "Unknown identifier i, funext fails, type mismatch in cd0"**
These are in `sum_lift_one_var`'s `agree` proof for the `j' = i` case. The core issue:
- Line 788: `i` is out of scope (not in the local context at that point in the by_cases branch)
- Lines 792, 794: The `convert ... using 2; funext q; ...` pattern fails because the goal is a Nat equality (`k = k + 1 - if j' = j' then 1 else 0`), not a function equality
- Lines 800, 802: Similarly, `simp [dif_neg h]` makes no progress

The `if_pos rfl`/`if_neg h` simp lemmas fire but leave residual goals because the `dif_pos`/`dif_neg` are in different if-branches than expected. The if-expressions in `sz`/`eM`/`eN` (conditioned on `j' = i`) are evaluated at `j' = i` (by `if_pos h`) but the `agree` goal still has an unresolved `if j' = i then 1 else 0` in the NF depth.

**Category 3 (line 805-806): omega failure, "No goals to be solved"**
The `omega` tactic at line 805 (`· simp [if_pos h]; omega`) fails because `if_pos h` in simp does not reduce `(if j' = i then 1 else 0)` in the goal to `1` -- it only fires for `if j' = j' then 1 else 0` when `j'` is literally the same as the conditional's LHS. The `h : j' = i` must first be used via `subst h` or `rw [if_pos h]` manually.

**Category 4 (line 812): "Type mismatch for rfl"**
`exact ⟨⟨0, rfl⟩, rfl, rfl⟩` fails with `rfl has type ?= ?` but expected `0 < if i = i then 1 else 0`. Again, the conditional is not reduced. Fix: `simp [if_pos rfl]` before the `exact`.

**Lean 4 community patterns for these issues**:

1. **if-then-else in dependent type indices**: Always reduce with `simp only [if_pos h]` / `simp only [if_neg h]` BEFORE forming the type, not after. The elaborator processes types left-to-right; an unreduced conditional in a type argument prevents subsequent projections from type-checking. Alternatively, use `dsimp only` with a set of if_pos/if_neg simp lemmas.

2. **Sigma type projections**: When working with `Fin.cons` over Sigma types, annotate the head element with its full concrete type, not a `show T from ...` where T contains metavariables. Use:
   ```lean
   set head_M : (orderedSum sig I ms).carrier := ⟨j, c⟩ with h_head_M
   ```
   then use `head_M` everywhere.

3. **dif_pos/dif_neg vs if_pos/if_neg**: In `CompData`'s `eM`/`eN` fields that use `if h : j' = i then ... else ...`, the relevant simp lemma is `dif_pos h` (for decidable-if with propositional proof), not `if_pos h` (for decidable-if with decidable instance). Using the wrong one leaves the if-expression unresolved.

4. **Fin.cases vs lambda for h_idx'**: The `Fin.cases rfl (fun k => h_idx k)` pattern is idiomatic and avoids the projection problem entirely. The `show (fun p => ...) p` form forces elaboration of the function body.

**Mathlib precedent**: Search for `Sigma.Lex` in Mathlib shows that well-formed proofs always extract the equality hypothesis from `Sigma.Lex.lt_def` before projecting. The pattern `obtain ⟨h, hlt⟩ := ...` is used universally, not `.1`/`.2` projections on the existential.

---

### 4. Could the NormalForm/BiCompat/CompData Architecture Be Simplified?

**Mathematic options examined**:

**Option A: Use Finset instead of Fin n for environments**

This would eliminate the variable-size projection problem (tracked per-component element counts become Finset membership). However, Lean 4's `Finset`-indexed functions require `Fintype` instances and `DecidableEq`, which adds bureaucracy. More critically, `nf_eval_nf` is defined with `Fin n -> M.carrier` environments -- changing this would require modifying `NormalForm.lean`, which is fully sorry-free and would need to be reproved.

Verdict: Not worth the disruption. The `Fin n` indexing is load-bearing for `NormalForm.lean`.

**Option B: Work with sentence-level (n=0) equivalence throughout**

The 4 sorry sites are in `sum_nf_agree_sentence`, which proves n=0 ordered-sum NF agreement. The difficulty is that the quantifier step at depth k+1 requires finding witnesses that satisfy sub-NFs at depth k with n=1. A "sentence-level-only" proof would need to avoid this, which is impossible -- quantifier semantics inherently requires working at n>0 internally.

Verdict: Mathematically impossible without changing the NF formalism.

**Option C: Avoid per-component projection by tracking only index matching**

The `CompData` structure exists precisely to track per-component NF state. One could attempt to replace it with a weaker hypothesis -- but Teammate C's analysis confirms that without some form of per-component state, the quantifier witness oracle cannot be constructed. The EF game argument IS the per-component tracking.

Verdict: Not viable.

**Option D: Replace the BiCompat/CompData architecture with a simpler formulation**

Teammate C's deep analysis (round 5) shows that `nf_agreement_monotone` provides the template for an alternative: a single induction on d without separating BiCompat from the main proof. The core insight: instead of pre-building a witness oracle (BiCompat) and then consuming it (sum_nf_lift_gen), merge the oracle construction and consumption into one proof by induction on d.

The current `build_bicompat` + `sum_nf_lift_gen` split is the source of complexity: BiCompat must be constructed BEFORE the induction, requiring explicit per-component state tracking. If the construction and the induction were merged, the per-component state would be naturally available at each step.

**Concrete alternative**: Replace `sum_lift_one_var`'s call to `build_bicompat` with an inline `have h_bc := ...` that constructs BiCompat recursively using `sum_nf_lift_gen`'s own proof structure -- but this is circular. The only non-circular alternative is to eliminate BiCompat as a separate type and fold its construction into `sum_nf_lift_gen` via a more general induction hypothesis.

This alternative would require significant refactoring (~200 lines) and carries high risk of introducing new errors. Given that `build_bicompat` and `sum_lift_one_var` already type-check logically (the errors are elaborator/tactic failures, not conceptual failures), the refactoring cost is not justified at this stage.

Verdict: The architecture is correct and appropriate for the mathematical proof. The 15 errors are fixable within the existing architecture. Do not refactor the architecture.

---

### 5. Time/Effort Analysis: Remaining Rounds and Error Resolution

**Current state**: 15 build errors, 0 sorries. All errors are in `build_bicompat` (lines 548-669) and `sum_lift_one_var`'s `agree` proof (lines 784-812).

**Error category breakdown** (from build output):

| Category | Lines | Count | Root Cause | Estimated Fix Complexity |
|----------|-------|-------|------------|--------------------------|
| Invalid projection on Fin.cons (h_idx') | 548-550, 629-631 | 6 | Sigma type head not concretely typed | Small: annotate types |
| `i` out of scope in agree | 788 | 2 | by_cases branching loses `i` | Small: reorder with `subst h` first |
| funext goal mismatch (Nat vs function) | 792, 794 | 2 | `convert using 2` applied to Nat goal | Small: simp only before convert |
| dif_pos/simp makes no progress | 800, 802 | 2 | dif_neg not in simp normal form | Small: use `rw [dif_neg h]` |
| omega on unreduced if-expr | 805 | 1 | if_pos fires in wrong scope | Small: subst + simp first |
| No goals after omega | 806 | 1 | Follow-on from 805 | Follows from fixing 805 |
| Type mismatch rfl | 812 | 1 | if-expr not reduced before exact | Small: simp [if_pos rfl] |

**Critical observation**: ALL 15 errors are in the same two proof blocks. None require new definitions or lemmas. They are all tactical/elaboration failures, not logical gaps. The proof logic has already been verified via `lean_multi_attempt` in prior rounds.

**Projected effort**:
- If each category is fixed with a targeted edit: 15 errors -> 4-5 distinct fix patterns -> estimate 2-4 hours for a skilled agent
- Risk: Fixing one error may reveal a previously-hidden downstream error (elaboration proceeds further after a fix). However, since the proof logic is correct, the downstream errors should be minor.

**Estimated rounds**: 1-2 implementation rounds should close all 15 errors. The current rate of "2 errors per round" was observed when each round was exploring the proof architecture. Now that the architecture is fixed and errors are purely tactical, the rate should be much higher: 5-8 errors per round.

**Most efficient approach**: Address all errors in a single targeted round:
1. Fix `h_idx'` at lines 548-550 and 629-631 by using `set` to name the head elements.
2. Fix `agree` at lines 784-812 by `subst h` before the `simp only [...]` calls in the `j' = i` case, and `rw [if_neg h]` before `simp [dif_neg h]` in the `j' != i` case.
3. Verify `lake build` after each fix block.

---

## Strategic Recommendations

**Immediate (next implementation round)**:
1. Fix the 15 errors as a single-pass targeted edit. The errors cluster into 4 fix patterns (annotate Sigma head type, subst before simp, rw before dif, simp before exact). Assign a single implementer to address all 15 in one round.
2. Do NOT attempt architectural changes (no BiCompat elimination, no SumPreservation.lean split) in this round. The architecture is correct.

**If the next round fails to close all errors**:
3. Factor `build_bicompat`, `CompData`, and `sum_lift_one_var` into `SumPreservation.lean` to enable isolated compilation and faster iteration. Make these definitions non-private in NEquivalence.lean (or move them to the new file with `internal` visibility if supported).
4. Write a minimal compile-test harness: a small `#check build_bicompat` file importing only `SumPreservation.lean` to verify the definitions compile before integrating.

**After task 154**:
5. Immediately progress to task 155 (activate Reynolds pipeline). IntegerModel.lean's 5 sorries are directly unblocked by task 154.
6. The `finite_structures_good` sorry needs Doets Theorem 1.1 (k-type realizability), which is separate from Lemma 1.4. This may require a new task if not addressed in task 155.

---

## Long-term Alignment

Task 154 is structurally well-aligned with the completeness roadmap. Completing it directly enables:

- **task 155**: The Reynolds pipeline becomes activatable, eliminating `succ_cofinal` via a detour. This is the primary value of task 154.
- **IntegerModel.lean cleanup**: The 5 sorries in `contemp_equiv_is_equiv` (transitivity), `no_gaps_discrete`, `very_good_implies_good`, `chronicle_is_good`, and `finite_structures_good` all become tractable once `sum_preservation` is sorry-free.
- **Phase 2 (frame hierarchy)**: After completeness, task 126 (frame hierarchy cleanup) is in the roadmap. The Doets 1.4 formalization is also needed for the Lemma 1.5 variant (non-identical index sets), which is relevant for the algebraic representation theorem (task 125).

The `CompData`/`BiCompat`/`build_bicompat` architecture, once debugged, provides a reusable pattern for future EF game formalizations in the project. The investment in getting it right pays dividends for any future `sum_preservation`-style results.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Task 154 is irreplaceable on the critical path | High - ROADMAP and Transfer.lean comments confirm no alternative |
| Factoring into SumPreservation.lean is beneficial but not urgent | High - the plan itself recommends this as a fallback |
| All 15 errors are tactical (not conceptual) | High - error messages confirm elaboration failures, not type logic failures |
| 1-2 more rounds should close all errors | Medium-High - fixing categorical elaboration issues is predictable, but cascading effects are possible |
| Architecture is correct, no simplification needed | High - Teammate C's exhaustive alternative analysis confirms BiCompat is necessary |
| Lean 4 fix patterns identified are correct | High - patterns match Mathlib precedent for Sigma.Lex and Fin.cons elaboration |
