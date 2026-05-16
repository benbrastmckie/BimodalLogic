# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v10)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/06_team-research.md
- **Artifacts**: plans/06_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

NEquivalence.lean has zero sorries but 17 build errors concentrated in two code regions: the `build_bicompat` forward/backward oracle cd' construction (lines 551-588, 632-668) and the `sum_lift_one_var` cd0 construction (lines 772-812). Plans v8 and v9 attempted an `extend_CompData` helper function approach but were BLOCKED by two fundamental issues: (1) after `subst h : j' = j`, `ite (j' = j')` in TYPE positions (NormalForm, Fin arguments) is not definitionally reducible because `DecidableEq I` makes the decision opaque -- no tactic (`simp`, `rw`, `dsimp`, `change`, `conv`) can reduce it; (2) `CompData.bound` requires `sz j < budget` (strict), but extension adds 1, needing `cd.sz j + 1 < budget` which is not provable from `cd.sz j < budget` alone.

Plan v10 takes a fundamentally different approach: instead of using `if j' = j then ... else ...` patterns that produce irreducible `ite` in types, it avoids the conditional entirely by **separating the j-th component from others**. For the `bound` issue, it adds a `consistent_count` lemma deriving `cd.sz j <= n` from `consistent`, then combines with `hdn : d + 1 + n <= budget` to get the needed strict bound. Definition of done: `lake build` exits with code 0 and `doets_lemma_1_4` is sorry-free.

### Research Integration

- **06_team-research.md** (integrated in v8): 4-teammate research identifying fix approaches for both clusters.
- **Phase 1 handoffs** (integrated in v9 and v10): Root cause analysis from 17+ failed approaches across v8 and v9 attempts. Key findings: (a) `ite (j' = j')` in types is fundamentally irreducible with `DecidableEq`, (b) `CompData.bound` gap requires additional arithmetic context, (c) structure literal syntax inside `build_bicompat` is unfixable.

### Prior Plan Reference

Plans v8 and v9 attempted `extend_CompData` as a standalone helper with `if j' = j then ... else ...` for all fields. Both were BLOCKED by the same two fundamental issues (ite-in-types and bound-too-strict). This plan v10 abandons the conditional-per-field approach entirely. Instead of constructing a new CompData where every field branches on `j' = j`, it constructs the extension by directly providing the j-th component's new values and delegating everything else to the original cd. The key insight: avoid creating any term where `if j' = j then X else Y` appears in a TYPE position.

### Roadmap Alignment

This task advances the Reynolds pipeline for discrete completeness. From ROADMAP.md:
- 3 sorries in `NEquivalence.lean` (`ktype_finite`, `k_type_of`, `finite_types`) block the KEquivalenceFramework instance (task 139)
- `sum_preservation` is a prerequisite for activating the Reynolds pipeline
- Critical path: Task 129 (COMPLETED) -> 139 (FO satisfaction) -> 140 (truth transfer) -> sorry-free `bx_completeness`

## Goals & Non-Goals

**Goals**:
- Resolve all 17 build errors in NEquivalence.lean
- Achieve `lake build` exit code 0
- Verify `doets_lemma_1_4` is transitively sorry-free

**Non-Goals**:
- Modifying proof logic or architecture (all proofs are logically correct)
- Proving `doets_lemma_1_5` (unrelated sorry)
- Resolving the 3 KEquivalenceFramework sorries (task 139 scope)
- Optimizing elaboration performance beyond compilation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `consistent_count` lemma proof difficult due to injectivity requirement | H | M | The `consistent` field maps each `(p, j)` with `(env_M p).1 = j` to a unique `q : Fin (sz j)`. Use `Fin.card_le_of_injective` or explicit Fintype counting. If Lean's Fintype instances are missing, prove by contradiction: if `sz j > n` then some q has no preimage, contradicting surjectivity |
| `extend_CompData` with separated j-component still has dependent type issues in `agree` field | H | M | The agree field for the j-component needs to relate `Fin.cons c (cd.eM j)` to h_ext_agree. Since both use `Fin.cons` directly (no ite), this should be a direct `convert` or `exact`. If not, use `nf_agreement_monotone` bridge |
| Non-j components of `agree` field fail because `budget - sz j'` changes meaning | M | L | For non-j components, `sz j' = cd.sz j'` (unchanged), so `budget - sz j' = budget - cd.sz j'` exactly. The agree proof is `exact cd.agree j'` with no type mismatch |
| `sum_lift_one_var` cd0 still has ite-in-types issues | M | M | cd0 uses `if j' = i then 1 else 0` which has the same ite problem. Apply the same separation strategy: handle the i-component directly and use Fin.elim0 for others, constructing cd0 without conditionals in types |
| Downstream callers of `build_bicompat` break after restructuring | L | L | `build_bicompat` signature is unchanged; only internal oracle code changes. All relevant defs are private to the file |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phase 1 provides the core helper and bound lemma needed by both Phase 2 and Phase 3. Phases 2 and 3 modify non-overlapping code regions and can execute in parallel. Phase 4 is final verification.

### Phase 1: Add consistent_count Lemma and extend_CompData Helper [NOT STARTED]

**Goal**: Prove that `cd.sz j <= n` (the number of environment variables) follows from `cd.consistent`, solving the bound gap. Then define `extend_CompData` using a design that avoids `if j' = j then ... else ...` in type positions.

**Tasks**:

- [ ] **Task 1.1**: Prove `consistent_count` lemma. From CompData.consistent, for each `j : I`, the function `fun p h => (cd.consistent p j h).choose` maps the set `{p : Fin n | (env_M p).1 = j}` injectively into `Fin (cd.sz j)`. Therefore `|{p | (env_M p).1 = j}| <= cd.sz j`. But we actually need the reverse direction: `cd.sz j <= n`. The consistent field says every pair `(p, j, h)` maps to some `q : Fin (cd.sz j)`. For the bound, the key observation is that `cd.sz j` counts the component-j elements tracked in the local environment. Since `d + 1 + n <= budget` and `cd.sz j < budget`, we need `cd.sz j + 1 < budget`. This follows from `cd.sz j <= n` combined with `d + 1 + n <= budget` (giving `cd.sz j + 1 <= n + 1 <= d + 1 + n <= budget`, so `cd.sz j + 1 <= budget`, and since `d >= 0` we get `cd.sz j + 1 < budget` when `d >= 1`). The lemma statement:
  ```lean
  private lemma consistent_count_le {sig : MonadicSignature}
      {I : Type} [LinearOrder I] [DecidableEq I]
      {ms ms' : I → OrderedMonadicStructure sig}
      {budget n : Nat}
      {env_M : Fin n → (orderedSum sig I ms).carrier}
      {env_N : Fin n → (orderedSum sig I ms').carrier}
      {h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1}
      (cd : CompData sig I ms ms' budget env_M env_N h_idx)
      (j : I) : cd.sz j ≤ n
  ```
  Proof strategy: The `consistent` field provides, for each `(p : Fin n, h : (env_M p).1 = j)`, a `q : Fin (cd.sz j)` such that `h ▸ (env_M p).2 = cd.eM j q`. Different `p` values with `(env_M p).1 = j` yield different `q` values (since `h ▸ (env_M p).2 = cd.eM j q` and `h' ▸ (env_M p').2 = cd.eM j q` would mean the env entries at p and p' map to the same component element, but they are distinct Fin n indices). Actually, the injectivity is not directly from distinct p but from the construction of cd: at initialization (cd0), sz i = 1 with 1 env entry mapping to q=0, and each extension adds exactly one env entry and one sz increment. Rather than proving this inductively, note that for the bound we only need `cd.sz j + 1 < budget` at call sites in `build_bicompat` where `hdn : d + 1 + n <= budget` with `d >= 1`. Since `cd.sz j < budget` (from cd.bound), we need `cd.sz j + 1 <= budget`. If `cd.sz j = budget - 1`, then `cd.sz j + 1 = budget` and we need strict `<`. The safe approach: pass `hdn` to extend_CompData and prove the bound from `d + 1 + n <= budget` combined with `cd.sz j <= n`. If the counting lemma is too complex, use **Option C**: add `h_bound_ext : cd.sz j + 1 < budget` as an explicit parameter to `extend_CompData`, proven at the call site using `omega` from `hdn` and a `have : cd.sz j < n := ...` or similar arithmetic.

  **Fallback**: If the general counting lemma is too hard, instead add a `sz_le_n` field directly to CompData:
  ```lean
  sz_le : ∀ j : I, sz j ≤ n
  ```
  This is trivially maintained: at cd0 initialization, `sz j' = if j' = i then 1 else 0` and `n = 1`, so `sz j' <= 1`; at each extension, `n` increases by 1 and `sz j` increases by 1 for the extended component (others unchanged). This avoids needing a separate lemma.

- [ ] **Task 1.2**: Define `extend_CompData` helper. The key design change from v9: instead of `fun j' => if j' = j then X else Y` for every field, split the construction so that the j-th component is handled by direct substitution (no conditionals in types). Strategy:

  **Approach A (Preferred): Use Function.update**

  The `sz` field becomes `Function.update cd.sz j (cd.sz j + 1)`. The `eM` field becomes `Function.update cd.eM j (Fin.cons c (cd.eM j))` (with appropriate cast). The advantage: `Function.update` has simp lemmas `Function.update_same` and `Function.update_noteq` that Lean can apply without creating ite-in-types.

  However, `Function.update` still uses `if j' = j then ... else ...` internally. The critical question is whether simp can reduce `Function.update f j v j` to `v` in type positions. If `DecidableEq I` is classical, this may have the same issue.

  **Approach B (Alternative): Rewrite cd' as a tactic proof using match instead of if**

  Use `match (decEq j' j)` instead of `if j' = j`. With `match`, Lean's equation compiler can produce iota-reducible case splits. The `decEq` call returns `isTrue rfl` or `isFalse h`, and pattern matching on `isTrue rfl` performs substitution at the term level, avoiding the ite wrapper entirely.

  ```lean
  sz := fun j' => match decEq j' j with
    | .isTrue rfl => cd.sz j + 1
    | .isFalse _ => cd.sz j'
  eM := fun j' => match decEq j' j with
    | .isTrue rfl => Fin.cons c (cd.eM j)
    | .isFalse _ => cd.eM j'
  ```

  With `match`, the `isTrue rfl` branch directly substitutes `j' := j`, so `cd.sz j'` becomes `cd.sz j` definitionally. No `ite` wrapper. The agree field for the j branch sees `sz j = cd.sz j + 1` (from the match reduction) directly, without needing `simp [if_pos rfl]`.

  **Approach C (Fallback): Avoid helper entirely, inline match in cd' body**

  If the standalone helper still has issues, inline the `match decEq` pattern directly in the cd' structure literal inside `build_bicompat`. This avoids the overhead of a separate function while still using match instead of if.

  The signature (for Approach A or B):
  ```lean
  private noncomputable def extend_CompData {sig : MonadicSignature}
      {I : Type} [LinearOrder I] [DecidableEq I]
      {ms ms' : I → OrderedMonadicStructure sig}
      {budget n : Nat}
      {env_M : Fin n → (orderedSum sig I ms).carrier}
      {env_N : Fin n → (orderedSum sig I ms').carrier}
      {h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1}
      (cd : CompData sig I ms ms' budget env_M env_N h_idx)
      (j : I) (c : (ms j).carrier) (c' : (ms' j).carrier)
      (h_ext_agree : ∀ nf : NormalForm sig (budget - cd.sz j - 1) (cd.sz j + 1),
        nf_eval_nf (ms j) (budget - cd.sz j - 1) (cd.sz j + 1)
          (Fin.cons c (cd.eM j)) nf ↔
        nf_eval_nf (ms' j) (budget - cd.sz j - 1) (cd.sz j + 1)
          (Fin.cons c' (cd.eN j)) nf)
      (h_bound_ext : cd.sz j + 1 < budget) :
      CompData sig I ms ms' budget
        (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M)
        (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N)
        (Fin.cases rfl (fun k => h_idx k))
  ```

  Note `h_bound_ext : cd.sz j + 1 < budget` is now an explicit parameter (resolving Blocker 2 at the call site rather than inside the helper).

- [ ] **Task 1.3**: Implement the body of `extend_CompData`. For each field, use `match decEq j' j` (Approach B):

  - **sz**: `fun j' => match decEq j' j with | .isTrue rfl => cd.sz j + 1 | .isFalse _ => cd.sz j'`
  - **eM**: `fun j' => match decEq j' j with | .isTrue rfl => Fin.cons c (cd.eM j) | .isFalse _ => cd.eM j'`
  - **eN**: `fun j' => match decEq j' j with | .isTrue rfl => Fin.cons c' (cd.eN j) | .isFalse _ => cd.eN j'`
  - **agree**: For `j' = j` (the `isTrue rfl` branch), the goal type should reduce to `NormalForm sig (budget - (cd.sz j + 1)) (cd.sz j + 1)` directly (no ite). Then `h_ext_agree` with a `nf_agreement_monotone` bridge closes it. For `j' /= j`, `exact cd.agree j'`.
  - **bound**: For `j' = j`, use `h_bound_ext`. For `j' /= j`, use `cd.bound j'`.
  - **consistent**: Case analysis on `Fin.cases` for the env index, then `match decEq j' j` for the component. The zero case (new element) maps to `Fin 0` in the cons. The succ case delegates to `cd.consistent`.

- [ ] **Task 1.4**: Verify `extend_CompData` type-checks in isolation. Run `lake build` and confirm no errors in the new definition. If `match decEq` still produces opaque terms in downstream fields, try:
  - Replace `match decEq j' j` with `if h : j' = j then (by subst h; exact ...) else ...` but with the critical difference that each branch is a complete `by` block that resolves the type before returning
  - Or use `@decidable.byCases` with explicit type annotations

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add `consistent_count_le` lemma and `extend_CompData` def before `build_bicompat` (~line 470)

**Verification**:
- `lake build` shows zero errors in the new definitions
- `extend_CompData` and `consistent_count_le` (or the `sz_le` field approach) compile without sorry

---

### Phase 2: Replace cd' in build_bicompat with extend_CompData Calls [NOT STARTED]

**Goal**: Replace both the forward oracle cd' block (lines 551-588) and backward oracle cd' block (lines 632-668) in `build_bicompat` with calls to `extend_CompData`, proving `h_bound_ext` at each call site.

**Tasks**:

- [ ] **Task 2.1**: Prove `h_bound_ext : cd.sz j + 1 < budget` at the forward oracle call site (around line 546). Available hypotheses:
  - `hdn : d + 1 + n <= budget` (from build_bicompat parameters, where d >= 1 in the d+1 case)
  - `cd.bound j : cd.sz j < budget`
  - `consistent_count_le cd j : cd.sz j <= n` (from Phase 1)

  Derivation: `cd.sz j <= n` and `d + 1 + n <= budget` with `d >= 0` gives `cd.sz j + 1 <= n + 1 <= d + 1 + n <= budget`. But we need STRICT `<`. Since we are in the `d + 1` branch, `d + 1 >= 1`, so `cd.sz j + 1 <= n + 1 <= 1 + n <= d + 1 + n <= budget`. For strict: `cd.sz j + 1 <= n + 1 <= d + 1 + n <= budget`, so `cd.sz j + 1 <= budget`. We need `cd.sz j + 1 < budget`. From `d + 1 + n <= budget` and `cd.sz j <= n`: `cd.sz j + 1 <= n + 1` and `n + 1 + d <= d + 1 + n <= budget`, so `cd.sz j + 1 + d <= budget`, meaning `cd.sz j + 1 <= budget - d`. Since `d >= 0`: if `d = 0` this gives `cd.sz j + 1 <= budget`, which is NOT strict. But in `build_bicompat`, the recursion is on `d + 1`, so the depth parameter in the pattern match is `d + 1`, meaning `d` in the recursive variable is the predecessor, and the recursive call uses depth `d`. The actual `hdn` is `(d + 1) + n <= budget`, so `d + 1 + n <= budget`, which gives `n + 1 <= budget - d`, and `cd.sz j + 1 <= n + 1 <= budget - d`. Since `d >= 0`, `budget - d >= budget`, wait -- that is wrong. Let me re-derive: `d + 1 + n <= budget` means `n <= budget - d - 1`. So `cd.sz j <= n <= budget - d - 1`, giving `cd.sz j + 1 <= budget - d`. Since `d >= 0`, `cd.sz j + 1 <= budget`. For strict: `cd.sz j + 1 <= budget - d <= budget`. Strict iff `d > 0` or `cd.sz j < n`. Since `d` is the predecessor depth in the `d+1` match, `d` can be 0. But the recursive call is `build_bicompat d (n+1) ...`, and the new hdn would need `d + (n+1) <= budget`, i.e., `d + n + 1 <= budget`, which follows from `d + 1 + n <= budget`. The bound for the NEW cd is `cd'.sz j' < budget`, and for `j' = j`, `cd'.sz j = cd.sz j + 1`, needing `cd.sz j + 1 < budget`. From `d + 1 + n <= budget` and `cd.sz j <= n`: `cd.sz j + 1 <= n + 1 <= d + 1 + n <= budget`. This gives `cd.sz j + 1 <= budget`. For strict `<`: we also know `d >= 0`, so `d + 1 >= 1`, meaning `d + 1 + n >= 1 + n >= n + 1 >= cd.sz j + 1`. And `d + 1 + n <= budget`. So `cd.sz j + 1 <= d + 1 + n <= budget`. Strict iff `cd.sz j + 1 < budget`. If `cd.sz j + 1 = budget`, then `d + 1 + n = budget` and `cd.sz j = n`, `d = 0`. This is the edge case. In this case the recursive call needs `d + (n+1) <= budget`, i.e., `0 + n + 1 <= budget = n + 1`, which holds. But `cd'.bound j : cd.sz j + 1 < budget` needs `n + 1 < n + 1`, which is false.

  This means we CANNOT always prove `cd.sz j + 1 < budget` at the call site using just `cd.sz j <= n` and `hdn`. We need `d >= 1` in the recursive call context, OR we need `cd.sz j < n`.

  **Resolution**: In `build_bicompat`, the recursion is `| d + 1, n, hdn, ... =>`. The bound for the CURRENT call is `(d+1) + n <= budget`. The recursive call is `build_bicompat d (n+1) (by omega) ...`. The cd' passed to the recursive call needs `cd'.bound j' : cd'.sz j' < budget`. For `j' = j`: `cd'.sz j = cd.sz j + 1`. We need `cd.sz j + 1 < budget`. From `(d+1) + n <= budget`: `budget >= d + 1 + n >= 1 + n >= n + 1 >= cd.sz j + 1`. So `cd.sz j + 1 <= budget`. Strict requires `cd.sz j + 1 < budget`, equivalently `cd.sz j <= budget - 2` or equivalently that the inequality is not tight. Since `d + 1 + n <= budget` and `cd.sz j <= n`, if `d >= 1` then `budget >= d + 1 + n >= 2 + n >= n + 2 > n + 1 >= cd.sz j + 1`, so `cd.sz j + 1 < budget`. If `d = 0` and `cd.sz j = n` and `budget = n + 1`, then `cd.sz j + 1 = budget` (not strict).

  **The d = 0 edge case**: When `d = 0`, the recursive call is `build_bicompat 0 (n+1) ...`, and `build_bicompat 0` returns `trivial` immediately without using cd'. So the bound field of cd' is NEVER inspected. We can therefore pass a proof by `omega` that works when `d >= 1` and handle `d = 0` specially (return trivial without constructing cd' at all).

  Implementation: Add `by omega` as the bound proof, relying on `hdn : d + 1 + n <= budget`, `cd.sz j <= n` (from consistent_count or sz_le), and the fact that Lean's omega can handle it when `d >= 1`. For `d = 0`, short-circuit the recursive BiCompat branch to `trivial`. Actually, looking at the code (line 588): `exact build_bicompat d (n + 1) (by omega) _ _ _ h_atoms_ext cd'`. When `d = 0`, this resolves to `trivial` immediately. So cd' is fully constructed but never inspected. Lean still needs it to TYPE-CHECK though. So `cd'.bound j` must still be provable.

  **Alternative**: Use `Nat.lt_of_le_of_lt` with a witness. Or change the approach: instead of requiring strict `<` for ALL j', require it only for j' where the field is actually used. Since Lean's type checker needs the field to exist regardless, we need another approach.

  **Best approach**: Pass `hdn` directly to `extend_CompData` and prove the bound internally:
  ```lean
  (hdn : d + 1 + n <= budget) (hd_pos : d >= 1 ∨ cd.sz j < n)
  ```
  But this is awkward. Simpler: just make the bound field use `by omega` with all available context. Actually, re-examining: `omega` should be able to close `cd.sz j + 1 < budget` from `d + 1 + n <= budget` and `cd.sz j <= n` when those are in the local context, REGARDLESS of whether `d = 0`, because `d + 1 + n <= budget` and `cd.sz j <= n` gives `cd.sz j + 1 <= n + 1 <= d + 1 + n <= budget`. Wait, this gives `<=` not `<`. omega gives `cd.sz j + 1 <= budget`, but the field requires `cd.sz j + 1 < budget`. So omega CANNOT close this in the d=0, cd.sz j = n case.

  **Final resolution**: The cleanest fix is to weaken CompData.bound from `<` to `<=`. Alternatively, add an explicit `d` parameter to `extend_CompData` and split: when `d >= 1`, prove bound by omega; when `d = 0`, don't construct cd' at all (return trivial for the recursive BiCompat).

  Let the implementation agent determine the best approach at this point. The plan provides three options ordered by preference:
  1. **Short-circuit d=0**: Before constructing cd', check if `d = 0`. If so, the recursive `build_bicompat 0 ...` returns `trivial`, so skip cd' construction entirely.
  2. **Add sz_le field to CompData + use (d+1) arithmetic**: If CompData has `sz_le : ∀ j, sz j <= n` and we pass `hdn : d + 1 + n <= budget`, then `cd.sz j + 1 <= n + 1 <= (d+1) + n <= budget`. Since the CURRENT depth is `d+1 >= 1`, we get `cd.sz j + 1 <= budget`. Still `<=` not `<`. But `d + 1 >= 1` means `budget >= d + 1 + n >= 1 + n` and `cd.sz j + 1 <= n + 1`. If `n + 1 = budget` then `d + 1 + n >= budget + d >= budget`, so `d = 0`, meaning actual depth is `0 + 1 = 1`. The recursive call depth is `d = 0`. For the cd' to have `bound : cd.sz j + 1 < budget`, we need `n + 1 < budget` i.e. `budget > n + 1`. From `1 + n <= budget`, `budget >= n + 1`. Strict iff `budget > n + 1` iff `d + 1 + n > n + 1` iff `d > 0`. When d = 0 (actual depth = 1), `budget = n + 1` is possible and bound fails.
  3. **Change CompData.bound to `<=`**: Replace `sz j < budget` with `sz j + 1 <= budget` or `sz j <= budget - 1`. This requires updating omega calls in downstream proofs but may be the most principled fix. The `agree` field uses `budget - sz j`, and `sz j < budget` ensures this is positive. With `sz j + 1 <= budget`, `budget - (sz j + 1) >= 0` which is still fine since NormalForm at depth 0 is valid.

- [ ] **Task 2.2**: Replace the forward oracle cd' block (lines 551-588) with `extend_CompData` call:
  ```lean
  have cd' := extend_CompData cd j c c' h_ext_agree h_bound_ext
  ```
  Keep h_idx' as-is (it is used by extend_atoms and the recursive call).

- [ ] **Task 2.3**: Replace the backward oracle cd' block (lines 632-668) with the same pattern.

- [ ] **Task 2.4**: Run `lake build`. Verify zero errors in the build_bicompat region. If the bound issue is not resolvable with omega at the call site, implement the short-circuit approach: wrap the cd' construction in a depth check.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 546-588 (forward cd'), lines 627-668 (backward cd'), possibly CompData structure (if adding sz_le field)

**Verification**:
- `lake build` shows zero errors in `build_bicompat`
- No errors mentioning "Invalid projection", "type mismatch", or "failed to synthesize" at the replaced lines
- The recursive `build_bicompat` call still type-checks with the new cd'

---

### Phase 3: Fix sum_lift_one_var cd0 [NOT STARTED]

**Goal**: Resolve all build errors in `sum_lift_one_var` (lines 772-816) by applying the same `match decEq` strategy to the cd0 construction, or by using the extend_CompData pattern.

**Tasks**:

- [ ] **Task 3.1**: Rewrite the cd0 block (lines 772-813) using `match decEq j' i` instead of `if j' = i then ... else ...` for the sz, eM, eN fields. For cd0, the structure is simpler than cd' because it is the initial CompData (not an extension):
  ```lean
  have cd0 : CompData sig I ms ms' (k + 1) envM envN h_idx_1 := {
    sz := fun j' => match decEq j' i with | .isTrue rfl => 1 | .isFalse _ => 0
    eM := fun j' => match decEq j' i with
      | .isTrue rfl => fun q => (![a]) q
      | .isFalse _ => Fin.elim0
    eN := fun j' => match decEq j' i with
      | .isTrue rfl => fun q => (![b]) q
      | .isFalse _ => Fin.elim0
    agree := fun j' => by ...
    bound := fun j' => by ...
    consistent := fun p j' hj' => by ...
  }
  ```

  With `match decEq`, the `.isTrue rfl` branch substitutes `j' := i`, so:
  - `sz i` reduces to `1` definitionally
  - `eM i` reduces to `fun q => (![a]) q` definitionally
  - `eN i` reduces to `fun q => (![b]) q` definitionally
  - The `agree` field for `j' = i` sees `budget - 1` depth and 1 var, directly matching `h_agree_comp`
  - The `agree` field for `j' /= i` sees 0 vars and full depth, matching `h_comp`

- [ ] **Task 3.2**: Implement the `agree` field for cd0. For the `isTrue rfl` branch: the goal type is `NormalForm sig (k + 1 - 1) 1 -> ...` which reduces to `NormalForm sig k 1 -> ...`. The hypothesis `h_agree_comp` provides exactly this. For the eM/eN match: in the rfl branch, `eM i = fun q => (![a]) q`. Need to show this equals `Fin.cons a Fin.elim0` (which `h_agree_comp` uses). This may require `funext q; fin_cases q; rfl` or `convert`.

  For the `isFalse` branch: the goal involves `NormalForm sig (k + 1 - 0) 0` which is `NormalForm sig (k + 1) 0`. The eM/eN are `Fin.elim0`. Use `h_comp (k + 1) le_rfl j'` directly.

- [ ] **Task 3.3**: Implement the `bound` field. For `isTrue rfl`: need `1 < k + 1`, which is `by omega`. For `isFalse _`: need `0 < k + 1`, which is `by omega`.

- [ ] **Task 3.4**: Implement the `consistent` field. There is exactly one env entry (p = 0) with `(envM 0).1 = i`. In the `isTrue rfl` branch (j' = i): produce `q = 0 : Fin 1` with `h ▸ (envM 0).2 = eM i 0 = a`. In the `isFalse` branch: `(envM 0).1 = i /= j'`, so this case is vacuously impossible (contradiction with `hj' : (envM 0).1 = j'` and `(envM 0).1 = i`).

- [ ] **Task 3.5**: If the `match decEq` approach has issues in cd0 (e.g., `agree` field still can't relate the match-reduced eM/eN to h_agree_comp's Fin.cons form), try alternative: construct cd0 WITHOUT any branching. Since cd0 has exactly one nontrivial component (i), define:
  ```lean
  sz := fun j' => if j' = i then 1 else 0  -- keep original
  ```
  But change eM/eN to use `dite` with explicit casts:
  ```lean
  eM := fun j' => dite (j' = i)
    (fun h => Fin.cast (by rw [if_pos h]) ∘ (h ▸ fun q => (![a]) q))
    (fun h => Fin.cast (by rw [if_neg h]) ∘ Fin.elim0)
  ```
  Or factor cd0 out as a separate definition entirely.

- [ ] **Task 3.6**: Run `lake build`. Verify zero errors in sum_lift_one_var. If errors remain, iterate on the specific failing field.

**Timing**: 1 hour

**Depends on**: 1 (for the match decEq pattern; technically cd0 does not use extend_CompData, but the same approach)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 772-813 (`sum_lift_one_var` cd0 block)

**Verification**:
- `lake build` shows zero errors in `sum_lift_one_var`
- No new errors in `sum_nf_agree_sentence` or other callers
- `bound` field provable (1 < k+1 and 0 < k+1 both hold by omega)

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Confirm the full project builds cleanly, `doets_lemma_1_4` is sorry-free, and no regressions exist.

**Tasks**:
- [ ] **Task 4.1**: Run `lake build` and confirm exit code 0
- [ ] **Task 4.2**: Verify `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` returns zero matches
- [ ] **Task 4.3**: Verify `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free (grep or `lean_verify`)
- [ ] **Task 4.4**: Verify no downstream regressions in files importing NEquivalence.lean
- [ ] **Task 4.5**: Update docstrings in `extend_CompData`, `sum_lift_one_var`, and `build_bicompat` to reflect final implementation
- [ ] **Task 4.6**: If CompData was modified (e.g., added `sz_le` field), verify all existing CompData constructions (cd0 in sum_lift_one_var) provide the new field

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Docstring updates only
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Verify only (no modifications expected)

**Verification**:
- `lake build` exit code 0
- Zero sorries in NEquivalence.lean
- `doets_lemma_1_4` sorry-free
- All downstream files build

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero matches
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5`
- [ ] `lean_verify` on `sum_preservation_proof` shows no sorry axiom
- [ ] No downstream regressions in files importing NEquivalence.lean or OrderedSum.lean

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/06_sum-preservation-plan.md` (this file, v10)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (add `consistent_count_le` or `sz_le` field, add `extend_CompData` helper, replace cd' blocks in `build_bicompat`, rewrite cd0 in `sum_lift_one_var`)

## Rollback/Contingency

- Git revert to current HEAD restores the zero-sorries-17-errors state
- If `match decEq` approach fails (Lean's equation compiler produces opaque terms), try `Decidable.byCases` with explicit type annotations: `@Decidable.byCases (j' = j) (instDecidableEq j' j) (fun h => ...) (fun h => ...)`
- If `consistent_count_le` is too complex, add `sz_le : ∀ j, sz j <= n` directly as a CompData field and maintain it at every construction site
- If the bound issue cannot be resolved for the d=0 edge case, short-circuit the recursive BiCompat branch: check `d` before constructing cd' and return `trivial` when `d = 0`
- If `extend_CompData` as a standalone def still has issues, inline the `match decEq` body directly in the cd' structure literal inside `build_bicompat`
- If all approaches to avoid ite-in-types fail, consider changing CompData to separate the j-th component entirely: add `ext_j : I`, `ext_sz : Nat`, `rest_sz : (j' : I) -> j' /= ext_j -> Nat` to avoid any branching
- If Phase 3 cd0 rewrite fails after 2 iterations, factor cd0 into a separate `mk_initial_CompData` helper using the same approach
