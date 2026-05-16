# Implementation Plan: Task #154 - Sum Preservation via Generalized Lifting (v5)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (Phase 1 carrier_order already completed; NormalForm.lean infrastructure complete)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/04_literature-approach.md
- **Artifacts**: plans/04_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `sum_preservation` (NEquivalence.lean) and `doets_lemma_1_4` (OrderedSum.lean): k-equivalence is preserved under ordered sums of monadic structures. This is plan v5, replacing the bootstrap sentence-level approach (v4) which compiled but left 4 sorries at the "lifting step" where 1-var NF matching fails to encode same-component order between multiple elements. The new approach implements a generalized lifting lemma `sum_nf_lift_gen` by induction on depth `d`, handling all variable counts `n` simultaneously. Witnesses are found via component conditional transfer (preserving indices), and `nf_agreement_from_shared_nf` provides the multi-var NF agreement needed for same-component order atoms. Definition of done: all 4 sorries in NEquivalence.lean closed, `lake build` passes, `doets_lemma_1_4` transitively sorry-free.

### Research Integration

- **Report 04** (literature-approach.md, round 4): Definitive root cause analysis. 1-var NF matching cannot encode same-component order. Correct approach: induction on depth `d` with all `n` simultaneously, budget `d+n` funded by component `(d+n)`-equivalence. The report identifies `nf_agreement_monotone` (NormalForm.lean:339-420) as the structural template and proves the budget is always sufficient (component `(d+n+1)`-equiv provides exactly enough peeling levels).

### Prior Plan Reference

Plan v4 implemented `sum_nf_agree_sentence` (bootstrap at n=0). It validated: (a) `atomKind_zero_elim` for vacuous base case, (b) component transfer machinery via `nf_characteristic_satisfies` + `nf_eval_unique`, (c) `sum_preservation_proof` delegation. The 4 sorries are all at identical locations: after finding `a`, `b` with matching depth-k 1-var component NFs, the proof cannot derive ordered-sum 1-var NF matching because the quantifier sub-step at n=2 introduces order atoms. Effort calibration: the component transfer and sentence-level scaffolding took ~3 hours and remain valid.

## Proof Architecture

### Root Cause (from report 04)

The 1-var NF matching hypothesis (`h_elem`) in all prior approaches (v2--v4) cannot encode same-component order between multiple elements. Two elements with identical 1-var NFs can be in either relative order. The quantifier step at `n >= 2` introduces `.order i j` atoms that 1-var matching cannot determine.

### Correct Approach: Generalized Lifting with Atom-Level Compatibility

Define `sum_nf_lift_gen` by induction on depth `d`, for all `n`, with hypotheses:

```lean
sum_nf_lift_gen (d : Nat) : ∀ (n : Nat) ...
  (h_comp : ∀ m, m ≤ d + n → ∀ i, ...) -- component sentence-level agreement
  (env_M : Fin n → (orderedSum sig I ms).carrier)
  (env_N : Fin n → (orderedSum sig I ms').carrier)
  (h_idx : ∀ j, (env_M j).1 = (env_N j).1) -- index matching
  (h_atoms : ∀ a : AtomKind sig n,
    atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a) -- atom compat
  (nf : NormalForm sig d n),
  nf_eval_nf (orderedSum ms) d n env_M nf ↔ nf_eval_nf (orderedSum ms') d n env_N nf
```

**Base case (d=0)**: `nf_eval_nf` at depth 0 is `∀ a, atom_eval M env a ↔ (nf a = true)`. Both sides satisfy the same atom conditions from `h_atoms`, so they share the same depth-0 NF. Apply `nf_agreement_from_shared_nf`.

**Inductive step (d+1)**: The NF decomposes into (atom_assgn, quant_assgn).
- *Atom part*: Follows directly from `h_atoms`.
- *Quantifier part*: For `sub_nf : NormalForm sig d (n+1)`, show existential transfer. Given witness `x = ⟨j,c⟩` in orderedSum ms:
  1. Find `c'` in `ms' j` via **component conditional transfer** -- using component `(d+n+1)`-equiv peeled to depth-d with `(r+1)` vars, where `r` = number of existing same-component elements. The conditional transfer is extracted from the component's multi-var NF agreement chain (built by iterating `nf_agreement_from_shared_nf` on the component from component `(d+n+1)`-equiv).
  2. Set `y = ⟨j, c'⟩`. Verify `h_atoms` for extended environments:
     - `.pred p 0`: from component NF matching of `c`, `c'`.
     - `.order 0 (k+1)` cross-component (`j ≠ (env_M k).1`): automatic from `h_idx` (order by index).
     - `.order 0 (k+1)` same-component (`j = (env_M k).1`): from component multi-var NF agreement at depth d, which includes order atoms. The conditional transfer guarantees this.
  3. Apply IH at depth d with extended environments and updated `h_atoms`.

**Budget**: Component `(d+n+1)`-equiv provides `d+n+1` peeling levels. At most `n+1` elements share a component (all of `env_M` plus the new witness), requiring `n+1` peelings. Since `n+1 ≤ d+n+1`, budget is sufficient for any `d ≥ 0`.

**Why `h_atoms` is maintainable**: The critical same-component order case is handled by the conditional transfer. Rather than finding `c'` via 1-var matching (which loses order information), we find `c'` via the component's multi-var quantifier extraction from the depth-`(d+n+1)` agreement chain. `nf_agreement_from_shared_nf` on the component guarantees that `c'` preserves the joint NF with all existing same-component elements, which encodes their relative order.

### Integration with `sum_nf_agree_sentence`

`sum_nf_agree_sentence(K+1)` calls `sum_nf_lift_gen(K, 1, ...)` with:
- `h_comp` at `m ≤ K+1` (from component `(K+1)`-equiv via the outer `h_comp'`)
- Single-element environments `![⟨i,a⟩]` and `![⟨i,b⟩]`
- `h_idx`: trivially `i = i`
- `h_atoms` at `n=1`: only pred atoms (no order atoms at `Fin 1`), follows from component NF matching

The call to `sum_nf_lift_gen` returns depth-K 1-var ordered-sum NF agreement, which closes the existential via `nf_agreement_from_shared_nf`.

### Key Lean Signatures

```lean
-- Main generalized lifting lemma (new)
private noncomputable def sum_nf_lift_gen (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    (h_atoms : ∀ a : AtomKind sig n,
      atom_eval (orderedSum sig I ms) env_M a ↔
      atom_eval (orderedSum sig I ms') env_N a)
    (nf : NormalForm sig d n),
    nf_eval_nf (orderedSum sig I ms) d n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') d n env_N nf := by
  intro d; induction d with
  | zero => ... -- atom verification via h_atoms
  | succ d ih => ... -- atom part + quantifier part with component conditional transfer

-- Existing (modified): sum_nf_agree_sentence calls sum_nf_lift_gen at d=K, n=1
-- Existing (unchanged): sum_preservation_proof, KEquivalenceFramework instance
```

## Goals & Non-Goals

**Goals**:
- Implement `sum_nf_lift_gen` proving depth-d n-var ordered-sum NF agreement from atom-level compatibility + component equivalence
- Use `sum_nf_lift_gen` to close all 4 remaining sorries in `sum_nf_agree_sentence`
- Verify `sum_preservation_proof`, `KEquivalenceFramework.sum_preservation`, and `doets_lemma_1_4` compile sorry-free
- Clean `lake build` with no new sorries

**Non-Goals**:
- Proving `doets_lemma_1_5` (type-matching variant, not on critical path)
- Closing downstream sorries beyond sum_preservation
- Implementing EF games or game-theoretic constructions
- Refactoring `KEquivalenceFramework` typeclass structure
- Modifying NormalForm.lean infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Component conditional transfer requires tracking which env elements share a component, involving Finset projections or dependent types | H | H | Avoid explicit projections: iterate `nf_agreement_from_shared_nf` on the component, building up the multi-var agreement one element at a time using `Fin.cons`. Each step peels one quantifier level from the component equivalence. |
| The `h_atoms` hypothesis at the extended environment (n+1 vars) is hard to establish for same-component order atoms | H | M | The conditional transfer finds `c'` via the component's multi-var quantifier extraction, guaranteeing order relative to existing same-component elements. `atom_agreement_from_nf` on the component derives order atom agreement. |
| Proof exceeds 300 lines and causes elaboration timeouts | M | M | Factor into 3 definitions: `sum_nf_lift_gen` (main, ~100 lines), `sum_nf_lift_extend` (witness finding + h_atoms extension, ~100 lines), `sum_nf_agree_sentence` (outer induction, existing ~150 lines). |
| The Sigma.Lex order coercion creates bureaucratic overhead in atom reasoning | L | H | Define simp lemma: `orderedSum_lt_iff : (⟨i,a⟩ : (orderedSum ..).carrier) < ⟨j,b⟩ ↔ i < j ∨ (i = j ∧ a < b)`. Use `show` to cast goals. |
| Budget calculation (component (d+n+1)-equiv vs d+n) off by 1 at boundary | M | L | `h_comp` gives `m ≤ d + n` in `sum_nf_lift_gen`. For the quantifier step at `d+1`, need `m ≤ d + n + 1` for extending. Adjust: `sum_nf_agree_sentence(K+1)` passes `h_comp` with `m ≤ K + 1 = d + n + 1` (since d=K, n=1). Verify boundary in Phase 1. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are sequential: each depends on the previous one.

---

### Phase 1: Design and Validate Signatures [COMPLETED]

**Goal**: Define `sum_nf_lift_gen` and helper lemma signatures with sorry bodies, validate they type-check, and verify the sorry sites in `sum_nf_agree_sentence` can be closed by calling them.

**Tasks**:
- [x] **Task 1.1**: Use `lean_goal` at each of the 4 sorry sites to capture exact goal states *(completed)*
- [x] **Task 1.2**: Define `sum_nf_lift_gen` with sorry-free body *(deviation: altered -- redesigned with BiCompat witness oracle instead of h_atoms-only approach; see architecture notes below)*
- [ ] **Task 1.3**: Define helper `orderedSum_lt_iff` simp lemma for Sigma.Lex order reasoning *(deviation: skipped -- Sigma.Lex.lt_def from Mathlib suffices, inline show/cases suffice)*
- [x] **Task 1.4**: Verify `sum_nf_lift_gen` type-checks and can be called at sorry sites *(completed -- verified signature compatibility)*
- [x] **Task 1.5**: Adjust `h_comp` budget parameter *(completed -- m <= d+n confirmed)*
- [x] **Task 1.6**: Run `lake build` to confirm no type errors *(completed -- build passes)*
- [x] **Task 1.7**: Define `BiCompat` recursive witness oracle predicate *(added -- not in original plan)*
- [x] **Task 1.8**: Prove `component_extend_fwd` and `component_extend_bwd` *(added -- key helpers for BiCompat construction)*
- [x] **Task 1.9**: Define `atomKind_one_pred_only` helper *(completed)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add `sum_nf_lift_gen` signature (sorry body), helper lemmas

**Verification**:
- `sum_nf_lift_gen` type-checks with sorry body
- At least one sorry site can be replaced by a call to `sum_nf_lift_gen` + `nf_agreement_from_shared_nf`
- `lake build` passes

---

### Phase 2: Base Case and Atom Handling [PARTIAL]

**Goal**: Prove the d=0 base case and the atom part of the d+1 inductive step of `sum_nf_lift_gen`.

**Tasks**:
- [ ] **d=0 base case**: Show depth-0 n-var NF agreement from `h_atoms`. The depth-0 NF is an atom assignment `AtomKind sig n → Bool`. Both environments satisfy the same atoms (from `h_atoms`), so their depth-0 characteristics are equal. Apply `nf_agreement_from_shared_nf` (or prove directly by `funext` on the atom assignment).
- [ ] **d+1 atom part**: Show the atom_assgn component of the depth-(d+1) n-var NF matches. Extract atom agreement from `h_atoms` using `atom_agreement_from_nf`.
- [ ] **AtomKind sig 1 has no order atoms**: Prove helper lemma `atomKind_one_pred_only` showing every `a : AtomKind sig 1` is `.pred p 0` for some `p`. Use this in Phase 4 when constructing `h_atoms` for n=1 from component NF matching.
- [ ] Verify partial proof compiles (remaining sorry at quantifier part only)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Fill in base case and atom parts

**Verification**:
- d=0 case of `sum_nf_lift_gen` is sorry-free
- d+1 atom part is sorry-free
- Only remaining sorry is the quantifier part of d+1
- `lake build` passes

---

### Phase 3: Quantifier Step with Component Conditional Transfer [NOT STARTED]

**Goal**: Prove the quantifier part of the d+1 inductive step: given witness `⟨j,c⟩` satisfying a sub-NF at depth d with n+1 vars in orderedSum ms, find a matching witness `⟨j,c'⟩` in orderedSum ms' and show the extended environments satisfy `h_atoms` at n+1 vars, enabling the IH application at depth d.

**Tasks**:
- [ ] **Witness construction via component transfer**: From component `(d+n+1)`-equiv, extract depth-d 1-var transfer for component j. Find `c'` in `ms' j` sharing the same depth-d 1-var component NF as `c`.
- [ ] **Strengthen to conditional transfer for same-component elements**: For each existing element `env_M(k)` with `(env_M k).1 = j` (same component as the new witness), strengthen `c'` to share a joint multi-var component NF with all same-component existing elements. Build the multi-var agreement chain by iterating: start from component `(d+n+1)` 0-var agreement, peel quantifiers once per same-component element (using `nf_agreement_from_shared_nf` at each step), ending with the conditional transfer that preserves order relative to all existing same-component elements.
- [ ] **Establish h_atoms for extended environments**: Show `∀ a : AtomKind sig (n+1), atom_eval ... ↔ ...` for `Fin.cons ⟨j,c⟩ env_M` vs `Fin.cons ⟨j,c'⟩ env_N`:
  - `.pred p 0`: from component NF matching of c, c' (via `atom_agreement_from_nf`)
  - `.pred p (k+1)`: from `h_atoms` at the existing level
  - `.order 0 (k+1)` with `j ≠ (env_M k).1`: `j < idx ↔ j < idx` from `h_idx` (cross-component order automatic)
  - `.order 0 (k+1)` with `j = (env_M k).1`: `c < (env_M k).2 ↔ c' < (env_N k).2` from multi-var component NF agreement (conditional transfer guarantees this)
  - `.order (k+1) (l+1)`: from `h_atoms` at the existing level
- [ ] **Apply IH**: Call `sum_nf_lift_gen` at depth d with n+1 vars, passing the extended environments and the established `h_atoms`.
- [ ] **Factor into sub-lemmas**: If the proof exceeds 100 lines, extract the witness construction + h_atoms verification into a helper `sum_nf_lift_extend_env`.

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Complete `sum_nf_lift_gen` quantifier step, add helpers

**Verification**:
- `sum_nf_lift_gen` compiles sorry-free
- `lake build` passes

---

### Phase 4: Close Sorries and Final Verification [NOT STARTED]

**Goal**: Use `sum_nf_lift_gen` to close the 4 remaining sorries in `sum_nf_agree_sentence`, verify the full dependency chain is sorry-free, and run a clean build.

**Tasks**:
- [ ] **Construct h_atoms for n=1 from component NF matching**: At each sorry site in `sum_nf_agree_sentence`, `h_agree_comp` gives component depth-K 1-var NF agreement between `a` and `b`. Construct `h_atoms : ∀ a : AtomKind sig 1, ...` by case-splitting: every atom at n=1 is `.pred p 0` (no order atoms at `Fin 1`), so atom agreement follows from component pred agreement via `atom_agreement_from_nf`.
- [ ] **Call sum_nf_lift_gen at d=K, n=1**: Replace each sorry with:
  ```
  have h_lift := sum_nf_lift_gen sig K 1 I ms ms' h_comp' (![⟨i,a⟩]) (![⟨i,b⟩]) h_idx h_atoms
  exact ⟨⟨i, a⟩, (h_lift sub_nf).mpr hb_eval⟩  -- or .mp for the other direction
  ```
- [ ] **Verify sum_preservation_proof compiles** (delegates to `sum_nf_agree_sentence`)
- [ ] **Verify KEquivalenceFramework instance compiles** (sum_preservation field)
- [ ] **Verify doets_lemma_1_4** in OrderedSum.lean is transitively sorry-free
- [ ] **Run verification commands**:
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- expect zero
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- expect only `doets_lemma_1_5`
  - `lake build` -- expect exit code 0
- [ ] **Update docstrings**: Remove "4 remaining sorries" and "blocker" references from `sum_nf_agree_sentence` and `KEquivalenceFramework` comments

**Timing**: 2.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Close sorries, update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Verify build, update docstrings if needed

**Verification**:
- `lake build` succeeds with exit code 0
- `doets_lemma_1_4` is sorry-free (transitively)
- Only remaining sorry in these two files is `doets_lemma_1_5` (explicitly out of scope)
- No new sorries introduced anywhere in the project
- Sorry count decreased by 4

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero sorries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5` sorry
- [ ] `grep -rn "carrier_order := sorry" Theories/` returns no matches
- [ ] No downstream regressions: files importing NEquivalence.lean and OrderedSum.lean continue to build

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md` (this file, v5)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (new `sum_nf_lift_gen`, updated `sum_nf_agree_sentence`, closed 4 sorries)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (doets_lemma_1_4 transitively sorry-free, updated docstrings)

## Rollback/Contingency

- Git revert to pre-implementation commit restores all files
- If `h_atoms`-based approach is intractable for the same-component conditional transfer, try the **component projection approach**: define `componentProj` as `{j : Fin n | (env_M j).1 = idx}` and state compatibility as per-component multi-var NF agreement (more complex but mathematically equivalent)
- If the full proof exceeds 500 lines, factor into a dedicated helper file `Theories/Bimodal/Metalogic/WeakCanonical/SumPreservation.lean`
- If the multi-var conditional transfer chain is too complex, try the **n=1 specialization**: prove lifting only for single-element environments (where `AtomKind sig 1` has no order atoms) and handle inner recursion by a separate well-founded argument
- As a last resort, restrict to `[Fintype I]` -- sufficient for the Reynolds pipeline since the condensation quotient is finite
