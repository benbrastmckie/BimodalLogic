# Teammate B Findings: GHR94 Hierarchy Proof and Axiom Elimination

**Task**: 157 -- Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Focus**: GHR94 Ch 10.2 hierarchy proof structure, how task-116 circularity resolution
enables axiom elimination, specific proof strategy with well-founded measure.

---

## Key Findings

### 1. GHR94 Proof Structure (Ch 10.2)

The GHR94 argument for Z-separation has a clean 6-lemma chain:

| Lemma | Statement | Proof technique |
|-------|-----------|-----------------|
| 10.2.1 | Distributivity of U/S over ∨ and ∧ | Semantic |
| 10.2.2 | Negation of U/S over Z (uses G, H) | Semantic |
| 10.2.3 | 8 atomic elimination cases | Per-case semantic argument |
| 10.2.4 | S(C,F) with single U(A,B) at top-level is separable | Cases 1-8 + boolean closure |
| 10.2.5 | Formula with single U-type U(A,B), S-free A,B is separable | Induction on S-nesting depth k |
| 10.2.6 | Formula with multiple U-types (all S-free args) is separable | Induction on count of U-types n |
| 10.2.7 | Formula with no S nested inside U is separable | Reduces to 10.2.5-10.2.6 |
| 10.2.8 | ALL {U,S}-formulas are separable | Induction on junction_depth |

Theorem 10.2.9 and 10.2.10 follow immediately.

The key chain: `junction_depth` induction (10.2.8) reduces to `no_S_nested_in_U` (10.2.7),
which reduces to `count_U_subformulas` induction (10.2.6), which uses single-U induction
(10.2.5), which uses S-nesting induction (10.2.4), which uses the 8 atomic cases (10.2.3).

### 2. How Task 116 Resolves the Circularity

**The old problem (pre-task-116)**: `all_past` and `all_future` were primitive constructors.
The `is_syntactically_separated` predicate accepted them as separated
(`| .all_past φ => is_U_free φ`), so separated witnesses could contain `all_past`/`all_future`
nodes. The elimination cases 1-4 constructed witnesses using `.all_future (Formula.neg A)` and
`.all_past (Formula.neg a)`. When the substitution-back step in Lemma 10.2.6 placed `.untl A B`
(or `.snce A B`) for a fresh atom in a separated formula, the separated formula's `all_past`/
`all_future` nodes created match arms that didn't follow the `imp`/`snce`/`untl` constructors,
breaking the induction measure.

Concretely (from reports 08-10): `subst_in_separated_separable` called `no_S_nested_in_U_separable`
as a callback on substituted past-constituents, but those constituents could contain `all_past`/
`all_future` nodes. The predicate `no_S_nested_in_U_separable` required `has_no_allpast_allfuture`,
which was false for separated formulas containing `.all_past` terms. This created an impossible
combination of preconditions.

**The new situation (post-task-116)**: Formula now has exactly 6 constructors: `atom`, `bot`,
`imp`, `box`, `untl`, `snce`. The `all_past`, `all_future`, `some_past`, `some_future` are
`def` abbreviations:
```lean
def all_past (φ) := ((.snce (.imp φ .bot) (.imp .bot .bot)).imp .bot)
def all_future (φ) := ((.untl (.imp φ .bot) (.imp .bot .bot)).imp .bot)
```

This means:
- `is_syntactically_separated` has NO case for `all_past`/`all_future` (they expand to
  `imp`/`snce`/`untl`/`bot` before matching)
- Separated witnesses can NEVER contain `all_past`/`all_future` nodes (they don't exist
  as constructors)
- The substitution-back step in Lemma 10.2.6 only encounters `atom`, `bot`, `imp`, `box`,
  `untl`, `snce` -- the standard 6 cases
- `has_no_allpast_allfuture` is ALWAYS true after the repair (since there are no such
  constructors to fail)

However: the `expand_temporal` function and `has_no_allpast_allfuture` predicate in
`TemporalClosure.lean` currently STILL have match arms for `.all_past` and `.all_future`
(because Defs.lean hasn't been repaired yet -- build is broken). After repair, these
will need to be removed or simplified.

### 3. Current Build State

`Defs.lean` does NOT compile. The build shows "Redundant alternative" errors for all
`| .all_past φ =>` and `| .all_future φ =>` arms (confirmed by running
`lake build Bimodal.Metalogic.WeakCanonical.Separation.Defs`). All 12 downstream
Separation files and `ExpressiveCompleteness.lean` are also broken.

The main build (`lake build`) succeeds because the Separation module is NOT imported
by `WeakCanonical.lean` (it's an isolated sub-module).

### 4. The 9 Axioms in SeparationThm.lean: Post-Repair Status

| # | Axiom | Post-repair status | Reason |
|---|-------|--------------------|--------|
| 1 | `all_past_separable` | **Trivially eliminable** | `all_past φ` is `imp (snce ...) bot`; handled by `imp_separable` + `snce_separable` |
| 2 | `all_future_separable` | **Trivially eliminable** | Same via `imp_separable` + `untl_separable` |
| 3 | `untl_separable` | **Requires hierarchy proof** | Core of 10.2.3-10.2.8 |
| 4 | `snce_separable` | **Requires hierarchy proof** | Core of 10.2.3-10.2.8 |
| 5 | `all_past_properly_separable` | **Trivially eliminable** | Same as #1 |
| 6 | `all_future_properly_separable` | **Trivially eliminable** | Same as #2 |
| 7 | `untl_properly_separable` | **Requires proof** | Proper version of #3 |
| 8 | `snce_properly_separable` | **Requires proof** | Proper version of #4 |
| 9 | `proper_separation_preserves_atoms` | **Requires proof** | Follows from constructive hierarchy |

But wait -- post-repair, axioms 1 and 2 don't even make sense as axioms anymore. After
removing `| .all_past` and `| .all_future` branches from all functions, `all_past φ` is
no longer a term Lean's pattern matcher sees. The `all_separable` theorem's
`| all_past φ ih => exact all_past_separable φ ih` branch will ALSO be redundant and
must be removed. The `all_separable` proof reduces to:

```lean
theorem all_separable (phi : Formula) : is_separable phi := by
  induction phi with
  | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | imp φ ψ ih1 ih2 => exact imp_separable ih1 ih2
  | box φ _ih => exact ⟨.box φ, rfl, int_equiv_refl _⟩
  | untl φ ψ ih1 ih2 => exact untl_separable φ ψ ih1 ih2
  | snce φ ψ ih1 ih2 => exact snce_separable φ ψ ih1 ih2
```

So only 2 axioms remain after the repair: `untl_separable` and `snce_separable`. The
proper versions (7, 8, 9) similarly reduce. The "9 axioms" count is pre-repair; post-repair
it's effectively 2 core axioms (plus proper variants).

### 5. The 8 Dual Elimination Sorries in DualEliminations.lean

All 8 are `sorry`. The dual cases prove `is_S_free psi = true` for U-formulas containing
S(A,B). The comment in Case 1 dual identifies the blocker: the swap/duality approach gives
`is_syntactically_separated` but not `is_S_free` (which is stronger).

**Post-repair resolution**: These 8 sorries can be proved by:
- For cases 1-4 dual: Direct semantic argument, constructing an explicit S-free witness
  (mirroring what the primary cases do for U-free witnesses), OR using `swap_temporal` on
  the primary case result and then verifying S-freeness of the swapped separated formula.
  The key fact: `is_S_free(swap(ψ)) = is_U_free(ψ)` (from Duality.lean). So if the
  primary case produces a U-free witness, the dual produces an S-free witness via swap.
  The primary cases 1-4 DO produce separated witnesses, but are they U-free? For cases
  where U(A,B) is absorbed into S-only form, yes.
- For cases 5-8 dual: Use `all_separable` (the master theorem) since these have the same
  form as cases 5-8 primary but with roles swapped.

### 6. Proposed Hierarchy Proof Strategy (Post-Repair)

**Step 0: Repair Defs.lean** (mechanical, ~2-4 hours)

Remove all `| .all_past` and `| .all_future` match arms from the ~15 definitions.
The semantics are automatically preserved because Lean expands `all_past φ` to
`imp (snce (imp φ bot) top) bot` before matching -- which falls into the `imp` arm.

Key functions to fix:
- `int_truth`: Remove `| .all_past φ` and `| .all_future φ` arms (6 lines)
- `formula_atoms`, `is_U_free`, `is_S_free`, `is_syntactically_separated`: same (2 lines each)
- `is_future_only`, `is_past_only`, `is_properly_separated`: same
- `junction_depth`, `U_depth_under_S`, etc.: same
- `no_S_nested_in_U`, `u_appearances_top_level_only`, etc.: same
- `abstract_untl` (Hierarchy.lean): same
- `subst_formula` (FormulaOps.lean): same
- `expand_temporal`, `has_no_allpast_allfuture` (TemporalClosure.lean): these become
  trivial/deletable since there are no `all_past`/`all_future` constructors to expand

**Step 1: Repair downstream files** (mechanical, ~4-6 hours)

Fix the induction proofs in TemporalClosure.lean, Hierarchy.lean, Duality.lean, etc.
by removing `| all_past` and `| all_future` match branches from `induction phi with`
calls.

**Critical simplification for Hierarchy.lean**: The `has_no_allpast_allfuture` predicate
and all its propagation lemmas become REDUNDANT. Every formula trivially has no
`all_past`/`all_future` (since they're not constructors). The `expand_temporal` function
becomes an identity (or near-identity). The `no_S_nested_in_U_separable` theorem loses
its `hexp : has_no_allpast_allfuture φ = true` precondition entirely:

```lean
-- BEFORE (with all_past/all_future constructors):
theorem no_S_nested_in_U_separable (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true)   -- THIS PRECONDITION
    (h : no_S_nested_in_U φ) :
    is_separable φ

-- AFTER (with 6-constructor Formula):
theorem no_S_nested_in_U_separable (φ : Formula)
    (h : no_S_nested_in_U φ) :
    is_separable φ
```

**Step 2: Prove `no_S_nested_in_U_separable`** (~150-200 LOC)

Well-founded induction on the lexicographic pair `(count_U_subformulas φ, Formula.sizeOf φ)`.

**Case `atom`/`bot`/`box`**: Trivially separable (already separated).

**Case `imp φ₁ φ₂`**: `no_S_nested_in_U` decomposes. Both subformulas are strictly smaller
by `sizeOf`. Apply IH, then `imp_separable`.

**Case `untl φ₁ φ₂`**: `no_S_nested_in_U (.untl φ₁ φ₂)` forces `is_S_free φ₁` and
`is_S_free φ₂`. An untl with S-free arguments is already syntactically separated.

**Case `snce C F`**: The key case. `no_S_nested_in_U (.snce C F)` gives
`no_S_nested_in_U C ∧ no_S_nested_in_U F`. Sub-cases:

- If `is_U_free C ∧ is_U_free F`: `.snce C F` with U-free args is syntactically separated. Done.
- If C or F contains U-occurrences: Since `no_S_nested_in_U`, every `untl α β` node in C or F
  has S-free α, β. Pick the first U-type `U(A,B)` in C or F. Apply `lemma_10_2_4`
  (NormalForm.lean) via boolean decomposition. This gives a separated equivalent. The S-parts
  in the separated equivalent have `count_U_subformulas < count_U_subformulas(.snce C F)`.
  Apply IH.

  For multiple U-types, use the `abstract_untl` infrastructure (Hierarchy.lean:310) to
  reduce to single U-type, then apply single-U lemma recursively.

  **The substitution-back step** (no longer circular): `ψ` is a separated formula with
  no `all_past`/`all_future` nodes (guaranteed by the 6-constructor type). Substituting
  `.untl A B` for fresh atom `p` in `ψ`:
  - `untl` args are S-free in `ψ`; substituting S-free `.untl A B` keeps them S-free
  - `snce` args are U-free in `ψ`; substituting `.untl A B` adds U -- but with S-free
    args, so `no_S_nested_in_U` holds for each new past constituent
  - `count_U_subformulas` of each past constituent is strictly less than the original
    (only n-1 U-types remain after abstracting U(A,B))
  - Apply IH to each past constituent

  No `all_past`/`all_future` node can appear in `ψ` to break the case analysis.
  This was the ENTIRE source of circularity in prior attempts.

**Step 3: Prove `junction_depth_separable`** (~80 LOC)

`Nat.strongRecOn` on `junction_depth φ`:

- JD = 0: formula is syntactically separated (no S-U alternation). `separated_imp_separable`.
- JD ≤ 1: `no_S_nested_in_U` holds (each `.untl` in S-args has S-free inner args since
  JD ≤ 1). Apply Step 2.
- JD ≥ 2: `snce D₁ D₂` has maximal U-subformulas with S-subformulas inside. Abstract
  the inner S-terms in U-args with fresh atoms (using a dual `abstract_snce` function),
  get a formula with `no_S_nested_in_U`. Apply Step 2. Substitute S-terms back into past
  constituents. Each past constituent now has `junction_depth < JD(φ)`. Apply IH.

**Step 4: Eliminate axioms** (~30 LOC)

```lean
-- Core axioms become one-liners:
theorem untl_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) :
    is_separable (.untl φ ψ) := all_separable _

theorem snce_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) :
    is_separable (.snce φ ψ) := all_separable _
```

**Step 5: Prove `is_properly_separable`** (~100 LOC)

A properly separated formula requires `is_future_only` for untl/all_future args and
`is_past_only` for snce/all_past args. After repair, `is_future_only` has no
`all_past`/`all_future` branches and matches the GHR94 notion of "no past operators."
The properly_separable analogue of Step 2-3 follows the same structure with tightened
purity predicates.

**Step 6: Prove dual eliminations** (~100 LOC)

The 8 `sorry` sites in DualEliminations.lean: use `swap_temporal` on the primary
case result. The key fact is that `swap_temporal` on a syntactically separated formula
gives a syntactically separated formula (proved in Duality.lean). For `is_S_free`, use
`dual_S_free_iff_U_free` to transfer from the primary case.

### 7. Well-Founded Relation for `no_S_nested_in_U_separable`

The correct measure is the lexicographic product `(count_U_subformulas φ, Formula.sizeOf φ)`:

```lean
-- Lean formulation:
termination_by (count_U_subformulas φ, Formula.sizeOf φ)
decreasing_by
  -- For imp subformulas: count same, sizeOf strictly smaller
  -- For snce subformulas after abstraction: count strictly smaller
  -- For snce subformulas after lemma_10_2_4 application: count smaller in past parts
```

For `junction_depth_separable`, the measure is simply `junction_depth φ` (a natural number),
using `Nat.strongRecOn`.

### 8. Infrastructure Already Available

Much of the required infrastructure already exists in the 6-file Hierarchy.lean:
- `abstract_untl` (line 310): replace U(A,B) with fresh atom
- `abstract_subst_roundtrip` (line 327): roundtrip correctness
- `has_single_U_type` and lemmas (lines 36-163)
- `single_U_formula_separable` (Lemma 10.2.5 skeleton, line 192)
- `subst_correctness` (FormulaOps.lean, line 51): semantic substitution
- All 8 Cases 1-4 primary in Eliminations.lean (proved)
- `lemma_10_2_4` in NormalForm.lean (Cases 5-8 used via `all_separable`)
- `replace_box_equiv`, `replace_box_preserves_separated` (TemporalClosure.lean)

What is MISSING:
- `subst_S_free_preserves_S_free`: substituting S-free for atom into S-free formula
- `subst_U_free_gives_no_S_nested`: the key bridging lemma
- `subst_in_separated_separable`: the central non-circular substitution bridge
- `abstract_snce` (dual of `abstract_untl`): for junction_depth induction
- A `no_S_nested_in_U_separable` proof without `has_no_allpast_allfuture` precondition

---

## Recommended Approach

### Approach: Direct 6-Constructor Proof (Option A)

Work entirely with 6 constructors throughout. Do NOT introduce a local `SepFormula` type
(that would reintroduce the complexity task 116 removed). The proof follows GHR94 exactly.

**Phase 1 (repair, ~6-8 hours total)**:
1. Fix Defs.lean: remove ~30 `all_past`/`all_future` match arms across ~15 definitions
2. Fix FormulaOps.lean, Duality.lean, TemporalClosure.lean, Hierarchy.lean, NormalForm.lean,
   DualEliminations.lean, DedekindZ.lean, SeparationThm.lean: remove match arms
3. Simplify/delete the `expand_temporal` and `has_no_allpast_allfuture` infrastructure
   (now trivial since all_past/all_future are not constructors)
4. Update `all_separable` to use only 6 cases
5. Verify build: `lake build Bimodal.Metalogic.WeakCanonical.Separation`

**Phase 2 (hierarchy proof, ~10-14 hours)**:
1. Prove helper lemmas: `subst_S_free_preserves_S_free` (~30 LOC), 
   `subst_U_free_gives_no_S_nested` (~40 LOC)
2. Prove `subst_in_separated_separable` (~100 LOC) -- the central bridge
3. Prove `no_S_nested_in_U_separable` by WF induction (~150 LOC)
4. Prove `junction_depth_separable` by strong induction (~80 LOC)
5. Derive `untl_separable`, `snce_separable` as one-liners from `all_separable`

**Phase 3 (axiom elimination, ~4-6 hours)**:
1. Replace axioms 3, 4 in SeparationThm.lean with theorems
2. Remove axioms 1, 2, 5, 6 (no longer needed; `all_past`/`all_future` not constructors)
3. Prove axioms 7, 8 (proper versions) from the hierarchy
4. Prove axiom 9 (atom preservation) from the constructive hierarchy
5. Close 8 sorries in DualEliminations.lean using swap_temporal + the primary proofs

**Total estimate**: 20-28 hours. Lower than pre-task-116 estimate because the
`has_no_allpast_allfuture` machinery is eliminated entirely.

### Key Simplification over Prior Attempts

The crucial simplification: `no_S_nested_in_U_separable` in prior attempts had
a `hexp : has_no_allpast_allfuture φ = true` precondition that could NOT be
discharged in the substitution-back step (because separated formulas could contain
`all_past`/`all_future` nodes). With 6-constructor Formula, the precondition is
vacuously true (no such constructors exist), so it can be dropped entirely. The
substitution-back step only encounters `atom`, `bot`, `imp`, `box`, `untl`, `snce` --
the 6 cases -- and the inductive argument closes cleanly.

---

## Evidence/Examples

**GHR94 text** (literature/GHR94_ch10.md lines 37-121): The 8 elimination cases in Lemma
10.2.3 are stated for atoms `a`, `q`, `A`, `B`. The proof of separability constructs
explicit witnesses in closed form (e.g., `case1_psi` in Eliminations.lean:78).

**Existing proof** (Eliminations.lean:84-174): `elim_case_1` is fully proved (~90 LOC).
The structure is: explicit witness + semantic verification via `int_truth_and_iff`,
`int_truth_or_iff`, case analysis on `lt_trichotomy u t`. This approach scales to all 8
cases and the hierarchy.

**Build error** (confirmed): `lake build Bimodal.Metalogic.WeakCanonical.Separation.Defs`
gives 14+ "Redundant alternative" errors for `all_past`/`all_future` arms -- exactly as
predicted by the task-116 architectural change.

**Prior reports**: Reports 08-10 accurately diagnosed the circularity in the substitution
step. Report 09 (hierarchy-strategy.md) provides a nearly complete implementation plan
for `no_S_nested_in_U_separable` that is now directly applicable with one change: remove
the `hexp` precondition throughout.

---

## Confidence Level: High

The mathematical analysis is sound. The circularity diagnosis from reports 08-10 is
correct, and task 116 genuinely resolves it. The implementation plan follows GHR94
exactly. The key risks are:

1. **Heartbeat limits** on large inductive proofs (~Medium): Mitigation: split into
   per-constructor lemmas, use `set_option maxHeartbeats 800000` as seen in Eliminations.lean.

2. **Junction-depth induction requiring `abstract_snce`** (~Low): The dual abstraction
   function is structurally identical to `abstract_untl` already in Hierarchy.lean.

3. **Proper separability bridge** (~Low-Medium): The `is_properly_separated` predicate
   uses `is_future_only`/`is_past_only` which have `all_past`/`all_future` arms to remove.
   After repair these are 6-arm predicates and the proper separability proof follows the
   same structure as regular separability.

No sorry deferral is needed. The GHR94 proof is fully constructive, all 8 elimination
cases (primary) are proved, and the remaining work is mechanical repair followed by
implementing the standard 4-step hierarchy.
