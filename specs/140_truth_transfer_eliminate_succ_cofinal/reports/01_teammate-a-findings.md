# Teammate A Findings: Task 140 -- Truth Transfer and succ_cofinal Elimination

**Task**: 140 - Truth transfer and succ_cofinal elimination
**Teammate**: A (Primary Approach)
**Date**: 2026-05-15

---

## Key Findings

1. **The `table` function body is the central blocker**: `Table.lean` has a `def table (sig : MonadicSignature) (_φ : Formula) : MonadicFormula sig 1 := by sorry`. This is not just a proof -- it is a missing *definition*. The body must translate each Formula constructor to the corresponding `MonadicFormula sig 1` expression, requiring a mapping from Formula atoms to `sig.preds`.

2. **The atom-to-predicate gap is a critical design problem**: The `table` function needs a way to map each `Formula.atom a` to a predicate symbol `p : sig.preds`. The current `mkSigFrom` in Transfer.lean uses `preds := Fin 1` (a single predicate placeholder). A real implementation must map each atom appearing in φ to a distinct predicate symbol. This requires either: (a) indexing `sig.preds` by Formula atoms appearing in φ, or (b) taking an explicit `atomMap : Atom → sig.preds` parameter.

3. **`table_correctness` requires a bridge between two evaluation systems**: The statement would be "for any temporal formula φ, any ordered monadic structure M, and any atom map, `eval M (fun _ => t) (table sig φ) ↔ truth_at M_temporal τ t φ`". The "two evaluation systems" are `eval` (Tarski for MonadicFormula, defined in NEquivalence.lean) and `truth_at` (bimodal semantics, defined in Truth.lean). These semantics must be shown equivalent via the table translation -- this is Reynolds 1994, Section 6.

4. **`table_depth_bound` is the simpler scope item**: Once `table` is defined, this follows by structural induction with `operator_depth` already defined in Table.lean. The `MonadicFormula.quantifier_depth` is also already defined in NEquivalence.lean. The proof just needs case analysis matching the `operator_depth` definition.

5. **The 6-step Reynolds pipeline in Transfer.lean already has the right structure**: The commented-out steps 1-6 in `doets_countermodel_discrete` are exactly right, but steps 3 (atomMap), 5 (truth transfer), and 6 (TaskFrame packaging) contain the key gaps. Step 4 (`chronicle_is_good`) is sorried but structurally wired. The fallback to `dd_countermodel_chronicle_discrete` works because that theorem uses `succ_cofinal` (itself sorried), but the `succ_cofinal` sorry propagates to `doets_countermodel_discrete` indirectly via this fallback delegation.

6. **Eliminating `succ_cofinal` from axioms requires activating the Reynolds pipeline**: The only way to eliminate `succ_cofinal` from `#print axioms doets_countermodel_discrete` is to stop delegating to `dd_countermodel_chronicle_discrete` (which chains through `succ_cofinal`). This requires: (a) a real `table` definition, (b) `table_correctness`, (c) `chronicle_is_good` proof, (d) Z-model packaging as `TaskFrame Int`.

7. **Several upstream sorries remain**: `chronicle_is_good` (IntegerModel.lean) depends on `very_good_implies_good` which depends on `sum_preservation` (Doets Lemma 1.4), and `finite_structures_good` (IntegerModel.lean) depends on Doets Theorem 1.1 (both Tasks 143+). These are NOT required for scope items 1-2 (table + table_depth_bound) but ARE required for scope items 3-4 (Reynolds pipeline activation).

---

## Literature-to-Code Mapping

### Reynolds 1994, Section 6: Table/Standard Translation

**Literature**: Reynolds defines `C_A(t)` for each temporal formula A. The atom case maps each temporal atom `p` to predicate `P(t)`. Negation: `¬C_A(t)`. Conjunction: `C_A(t) ∧ C_B(t)`. For `G(A)`: `∀s > t, C_A(s)` (i.e., `all (lt (1:Fin 2) (0:Fin 2) → C_A(0))`). For `U(A,B)`: `∃s > t, C_A(s) ∧ ∀u(t < u < s → C_B(u))`.

**Code sorry**: `def table` in `Table.lean:66` -- the entire body is `sorry`.

**Proof strategy**: Follow Reynolds Section 6 literally, case by case:
- `atom a` → `MonadicFormula.atom (atomMap a) (0 : Fin 1)` (requires `atomMap : Atom → sig.preds` parameter)
- `bot` → `MonadicFormula.not (MonadicFormula.atom p (0:Fin 1))` applied to itself, or use `not (and alpha (not alpha))` -- actually `not (not (lt 0 0))` where `lt i i` is always False by antisymmetry -- better: embed ⊥ directly as a false monadic formula
- `imp φ ψ` → `MonadicFormula.not (MonadicFormula.and (table φ) (MonadicFormula.not (table ψ)))`
- `all_future φ` → `MonadicFormula.all (MonadicFormula.not (MonadicFormula.and (MonadicFormula.lt (0:Fin 2) (1:Fin 2)) (MonadicFormula.not (table_shifted φ))))`
- `untl φ ψ` → the 2-quantifier formula from Reynolds: `∃s > t, C_φ(s) ∧ ∀u(t < u < u < s → C_ψ(u))`

Note: De Bruijn indexing needs careful tracking. When translating `table φ : MonadicFormula sig 1` and we quantify over `s` in `all_future`, the original free variable `t = var 0` shifts to `var 1` under the binder, and the new variable `s = var 0`. So the inner formula must use `Fin.castSucc` or similar to shift the free variable index.

**Confidence**: High that the translation is correct by Reynolds. Medium confidence on the exact De Bruijn encoding (needs careful Lean implementation).

### Reynolds 1994, Theorem 18: Full Completeness Pipeline

**Literature**: Reynolds Theorem 18 gives the full pipeline:
1. Given consistent formula A₀, find model M₀ via Burgess-Xu (Corollary 3)
2. Restrict to finite language (atoms of A₀ only)
3. Let k = quantifier depth of table(A₀) + 1
4. Apply Theorem 15 to get Z-structure with same k-type as M₀
5. Z satisfies ∃t(table(A₀)(t)) by k-equivalence
6. By table correctness, Z satisfies A₀

**Code sorry**: `doets_countermodel_discrete` in `Transfer.lean:110` -- currently falls back to chronicle construction

**Required gap**: Step 5 needs `k_equiv` to transfer truth of quantifier-depth-≤k sentences from chronicle to Z-structure. Step 6 needs `table_correctness`. Both require `table` to be defined.

**Confidence**: High that once `table` is defined and `chronicle_is_good` is proved, the pipeline can be activated.

### Reynolds 1994, Section 6: Table Correctness

**Literature**: "A simple induction (see for example [5]) establishes that all temporal formulas A have a corresponding monadic formula C_A in one free variable such that, for all structures (T, <), for all valuations h, for all t ∈ T: (T, <, h) |= A(t) iff (T, <, h) |= C_A(t)."

**Code sorry**: `table_correctness` -- this theorem doesn't exist yet, only `table_depth_bound` is mentioned in the module header.

**Proof strategy**: Structural induction on Formula. The key insight: the `eval` function in NEquivalence.lean and `truth_at` in Truth.lean must agree via the table translation. Specifically:
- For atom `a`: `truth_at M τ t (atom a) ↔ eval M (fun _ => t) (table sig (atom a))` requires `a ∈ atomMap⁻¹(p) ↔ M.interp p t` -- this is exactly the definition of the monadic structure built from the chronicle!
- For temporal operators: the quantifier structure of `eval` matches `truth_at` by the table's translation of Until/Since to FO quantifiers.

**Confidence**: High that the strategy is correct. The induction is standard (appears in textbooks as easy). The challenge is making it type-check in Lean with the De Bruijn encoding.

### Doets 1989, Lemma 1.1: Finite k-Types

**Literature**: "Up to logical equivalence, there are only finitely many first-order formulas of quantifier-rank ≤ n in the free variables x₀,...,x_{k-1} in each language." Proof by induction.

**Code sorry**: `finite_types` in `KEquivalenceFramework` instance, `NEquivalence.lean:346`.

**Mapping**: This is the `KType` finiteness needed for `very_good_implies_good` → `chronicle_is_good`. This is NOT in Task 140 scope -- it's Task 143.

**Confidence**: High that this is out of Task 140 scope.

### Doets 1989, Lemma 1.4: Ordered Sum Preserves k-Equivalence

**Literature**: "If for all i ∈ I m(i) =_n m'(i), then Σ_{i∈I} m(i) =_n Σ_{i∈I} m'(i)." Proof by describing a winning strategy in the Ehrenfeucht n-game.

**Code sorry**: `sum_preservation` in `KEquivalenceFramework` instance, `NEquivalence.lean:352`.

**Mapping**: Required by `very_good_implies_good` and `chronicle_is_good`. Also NOT in Task 140 scope (Task 143+). The Task 140 fallback through the chronicle construction bypasses this.

**Confidence**: High that this is out of Task 140 scope.

---

## Recommended Approach

### Scope Item 1: Prove `table_correctness`

**Prerequisite**: Define `table` first (the sorry body in Table.lean:66).

**Key design decision**: The `table` function signature must be enriched with an explicit atom-to-predicate mapping parameter. Recommend:
```lean
def table (sig : MonadicSignature) (atomMap : Atom → sig.preds) (φ : Formula) : MonadicFormula sig 1
```

This avoids the current placeholder in `mkSigFrom` and `mkAtomMap` in Transfer.lean. With an explicit `atomMap`, the atom case becomes `MonadicFormula.atom (atomMap a) (0 : Fin 1)`.

**Translation (following Reynolds Section 6 exactly)**:
- `atom a` → `MonadicFormula.atom (atomMap a) (Fin.last 0)` where the free variable is `Fin 0 : Fin 1`
- `bot` → represent as `MonadicFormula.not (MonadicFormula.not (MonadicFormula.lt (0:Fin 1) (0:Fin 1)))` -- wait, `lt 0 0` might not be syntactically False. Better: use negation of identity: for ⊥ as `not (all (not (atom p_arbitrary (Fin.last 0))))` -- this is tricky.

  Actually, Reynolds works in a signature with *only* the predicates for atoms of φ. For ⊥, since `MonadicFormula` has `lt` constructor, we can use `lt (0:Fin 1) (0:Fin 1)` which is literally `t < t` (always false in a linear order). So `table sig atomMap bot = MonadicFormula.lt (0:Fin 1) (0:Fin 1)`.

- `imp φ ψ` → `MonadicFormula.not (MonadicFormula.and (table' φ) (MonadicFormula.not (table' ψ)))` where `table' = table sig atomMap`

- `box φ` → This is the modal box `□φ`. In the monadic FO setting, the box modality does NOT have a first-order translation (it quantifies over possible worlds, not over times). **Critical issue**: the `table` function is supposed to translate temporal formulas to monadic FO over time, but the bimodal logic has both box (S5) and temporal operators. Reynolds only handles the temporal fragment (U and S). The `box` constructor must either: (a) be handled by the MCS labeling in the chronicle (since in the canonical model, box-accessibility is handled by the atom map), or (b) require a different approach.

  Looking at the codebase: `truth_at ... (Formula.box φ) = ∀ σ ∈ Omega, truth_at ... σ t φ`. This is not a monadic FO formula over time. The standard translation for modal logic would require a *different* predicate for each box-formula. In the Reynolds pipeline context, the chronicle structure already handles the S5 component (via `fmcs` labeling), so `box` formulas are handled at the MCS level. The `table` in Reynolds only needs to handle the temporal operators; the `box` case in the bimodal setting requires extra infrastructure.

  **Recommendation**: Follow Reynolds and restrict `table` to the temporal fragment (no `box`). Alternatively, treat `box φ` as an atom (since in the canonical model context, `□φ ∈ MCS` is itself a fact about the MCS labeling). This is a significant design question that needs resolution before implementation.

- `all_future φ` → Reynolds gives `∀s > t, C_φ(s)`. In MonadicFormula with 1 free variable: we need `MonadicFormula.all (not (and (lt (0:Fin 2) (1:Fin 2)) (not (shift (table sig atomMap φ)))))` -- where `shift` increments the free variable index from `0:Fin 1` to `1:Fin 2`.

  The crucial operation is "shift" / weakening: given `α : MonadicFormula sig 1` with free variable `0:Fin 1`, produce `α' : MonadicFormula sig 2` with free variable `1:Fin 2` (the `t` variable after binding `s`). This requires a `weaken` function on `MonadicFormula`.

- `all_past φ` → Dual: `∀s < t, C_φ(s)` in monadic FO.

- `untl φ ψ` → `∃s > t, C_φ(s) ∧ ∀u(t < u < s → C_ψ(u))` -- two quantifiers, so 3 free variables needed at inner level. Requires `weaken` to lift both `table sig atomMap φ` and `table sig atomMap ψ` by appropriate amounts.

**The `weaken` operation is the key missing piece**. It needs to be defined:
```lean
def MonadicFormula.weaken {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → MonadicFormula sig (n + 1)
```
via structural recursion (shift all variable indices up by 1, i.e., compose with `Fin.castSucc`).

Once `weaken` exists, the `table` definition becomes a clean structural recursion.

**`table_correctness` proof**: By structural induction on `φ`. Each case reduces to unfolding `truth_at` and `eval` and showing the `table` translation is equivalent. The key cases are:
- `all_future`: `truth_at M τ t (all_future φ) = ∀ s > t, truth_at M τ s φ` must equal `eval M (fun _ => t) (all (not (and (lt 1 0) (not (weaken (table φ))))))`. This requires showing `eval M (Fin.cons s (fun _ => t)) (weaken (table φ)) = eval M (fun _ => s) (table φ)`, which is the standard "weaken preserves eval under extension" lemma.
- `untl`: Two quantifiers, requires careful tracking of De Bruijn indices.

**Confidence**: Medium. The strategy is standard but the De Bruijn bookkeeping is fiddly in Lean 4.

### Scope Item 2: Close `table_depth_bound`

**Depends on**: `table` being defined.

**Strategy**: Straightforward structural induction. For each case of `table sig atomMap φ`:
- `atom a` → `MonadicFormula.atom p i` has `quantifier_depth = 0 = operator_depth (atom a)`
- `bot` → `lt i j` has `quantifier_depth = 0 = operator_depth bot`
- `imp φ ψ` → `not (and ...)` has `quantifier_depth = max (qd φ) (qd ψ) ≤ max (od φ) (od ψ) = od (imp φ ψ)`
- `all_future φ` → wraps in `all (...)`; `quantifier_depth` increases by 1; `operator_depth (all_future φ) = operator_depth φ + 1`, so the bound is tight.
- `untl φ ψ` → wraps in `ex (... all ...)` or similar 2-quantifier formula; quantifier depth is `max (qd φ, qd ψ) + 2` at most (for the two quantifiers), but `operator_depth (untl φ ψ) = max (od φ) (od ψ) + 1`. So this might fail if the until case uses 2 quantifiers but `operator_depth` only adds 1.

  **Re-reading Reynolds**: `C_{U(A,B)}(t) = ∃s > t(C_A(s) ∧ ∀u(t < u < s → C_B(u)))`. The quantifier depth of this formula is 2 (one `∃`, one `∀`), but `operator_depth (untl φ ψ) = max (operator_depth φ) (operator_depth ψ) + 1`. If φ and ψ are atoms (depth 0), then `operator_depth = 1`, but quantifier depth of the translation is 2. So the bound `table_depth_bound` as stated would be FALSE for Until.

  **This is a real issue**: The `operator_depth` in Table.lean adds only 1 for Until/Since, but the FO translation of Until uses 2 quantifiers. The bound should be `quantifier_depth ≤ 2 * operator_depth φ` or use a different measure.

  **Recommendation**: Redefine `operator_depth` to add 2 for Until/Since, making the bound tight:
  ```lean
  | .untl φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
  | .snce φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
  ```
  This would make `table_depth_bound` provable. Alternatively, the bound could be stated as `table_depth_bound : quantifier_depth (table sig atomMap φ) ≤ 2 * operator_depth φ`, but the existing definition adds only 1 for Until.

**Confidence**: High that `operator_depth` must be fixed for Until/Since before `table_depth_bound` can be proved as stated.

### Scope Item 3: Wire Reynolds Pipeline in Transfer.lean

**Prerequisites**: `table` defined, `table_correctness` proved, `chronicle_is_good` proved (but that requires Tasks 143+ for `sum_preservation` and `finite_structures_good`).

**The critical dependency chain**:
```
table (definition) -> table_correctness -> activate_reynolds_pipeline
finite_structures_good -> contemp_equiv_is_equiv (trans) -> one_class -> very_good_implies_good -> chronicle_is_good
sum_preservation -> very_good_implies_good (trans case)
Doets 1.1 -> finite_structures_good
Doets 1.4 -> sum_preservation
```

**For scope item 3 alone** (uncommenting the 6 steps in `doets_countermodel_discrete`), the minimal path is:
1. Define `mkSigFrom` properly (currently uses `Fin 1` placeholder)
2. Define `mkAtomMap` properly (currently returns `Formula.bot` for all predicates)
3. Prove `chronicle_is_good` (depends on Tasks 143+)
4. Extract Z-model from `good` (needs `ZIntervalStructure` extraction from `good sig k chronicle`)
5. Apply `table_correctness` to transfer truth from chronicle to Z-model
6. Package Z-model as `TaskFrame Int` / `TaskModel`

Step 6 (packaging) is the most concrete: given `Z : ZStructure sig` and a formula φ with `eval (Z.toOrdered sig) (fun _ => (0:ℤ)) (table sig atomMap φ) = True`, construct `F : TaskFrame Int`, `TM : TaskModel F`, etc. such that `¬truth_at TM Omega τ 0 φ`. This requires building a `TaskModel` over ℤ from the Z-structure -- mapping `Z.interp p t` back to atom truth in the TM semantics.

**Confidence**: Medium-high that steps 1-2 (mkSigFrom/mkAtomMap) and 5-6 can be done, but step 3 (chronicle_is_good) is blocked by Tasks 143+.

### Scope Item 4: Eliminate `succ_cofinal`

**Depends on**: Full activation of the Reynolds pipeline (scope item 3), including `chronicle_is_good`.

**Strategy**: Once `doets_countermodel_discrete` no longer delegates to `dd_countermodel_chronicle_discrete`, the axiom set of `doets_countermodel_discrete` will only include axioms from the Reynolds pipeline (Doets 1.4, Doets 1.1), NOT `succ_cofinal`. The `#print axioms doets_countermodel_discrete` should then show no `succ_cofinal`.

**Confidence**: High that this follows automatically once the pipeline is activated. The primary gate is `chronicle_is_good`.

---

## Evidence / Examples

### Code paths for scope items 1-2

File: `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`
- Line 66: `def table (sig : MonadicSignature) (_φ : Formula) : MonadicFormula sig 1 := by sorry` -- the body to implement
- Line 79-81: `theorem table_depth_bound ...` -- proof needed after table definition
- Line 40-48: `def operator_depth` -- this needs an update for Until/Since (add 2, not 1)

File: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- Lines 217-224: `def eval` -- the Tarski evaluator for MonadicFormula
- Lines 64-71: `MonadicFormula` constructors -- what `table` must produce
- Lines 77-84: `MonadicFormula.quantifier_depth` -- what `table_depth_bound` reasons about

### Code path for scope item 3

File: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- Lines 119-136: The 6 steps of the Reynolds pipeline (all commented out)
- Lines 132-136: The fallback to chronicle construction (what we must replace)
- Lines 69-84: `mkSigFrom` (uses `Fin 1` placeholder) and `mkAtomMap` (maps everything to `bot`)

### Code path for scope item 4

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- Line 1559: `private theorem succ_cofinal` -- the sorry that must be bypassed
- Line 3285: `dd_countermodel_chronicle_discrete` -- the theorem that uses `succ_cofinal`

File: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- Lines 135-136: The fallback that pulls in `succ_cofinal` transitively

### The `weaken` operation (missing infrastructure)

The `MonadicFormula.weaken` function is not in the codebase. It is required for the `table` definition. Expected signature:
```lean
def MonadicFormula.weaken {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → MonadicFormula sig (n + 1)
  | .atom p i => .atom p i.castSucc
  | .lt i j => .lt i.castSucc j.castSucc
  | .not α => .not α.weaken
  | .and α β => .and α.weaken β.weaken
  | .all α => .all α.weaken  -- here weaken in context n+1 -> n+2
  | .ex α => .ex α.weaken
```

Wait, for `all α` where `α : MonadicFormula sig (n+1)`, we need `weaken α : MonadicFormula sig (n+2)`. The recursive call is fine since `weaken` is polymorphic in `n`.

The key property needed:
```lean
theorem weaken_eval (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier) 
    (x : M.carrier) (α : MonadicFormula sig n) :
    eval M (Fin.cons x env) (α.weaken) = eval M env α
```

This says: evaluating a weakened formula in an extended environment equals evaluating the original in the original environment.

---

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| `table` body requires `weaken` helper | High |
| `table` needs explicit `atomMap` parameter | High |
| `table_depth_bound` fails for Until/Since if `operator_depth` adds only 1 | High |
| `table_correctness` proof strategy (structural induction via `weaken_eval`) | High |
| `box` constructor requires special handling (not in Reynolds) | High |
| Reynolds pipeline activation depends on `chronicle_is_good` (Tasks 143+) | High |
| `succ_cofinal` elimination follows from pipeline activation | High |
| `weaken` property (`weaken_eval`) is the key bridge lemma for `table_correctness` | Medium-High |
| De Bruijn indexing details for `untl` case (2 quantifiers, 3 variables) | Medium |

---

## Literature Proof Structure

**Source**: Reynolds 1994, Section 6 (Standard Translation) and Theorem 18 (Completeness)
**Strategy**: Standard translation + k-equivalence transfer

### Step Map (Theorem 18 proof)

1. Given consistent A₀, apply Burgess-Xu (Corollary 3) to get temporal structure M₀ -- [Reynolds] Corollary 3
2. Restrict to finite language (atoms of A₀ only) -- [Reynolds] Theorem 18 paragraph 2
3. Let k = quantifier depth of C_{A₀}(t) + 1 -- [Reynolds] Theorem 18 "Let k be one greater"
4. Apply Theorem 15 to get Z-structure Z with M₀ ≡_k Z -- [Reynolds] Theorem 15
5. Z satisfies ∃t(C_{A₀}(t)) since M₀ satisfies it and C_{A₀}(t) has depth ≤ k -- [Reynolds] k-equivalence
6. By table correctness C_{A₀}(t) ↔ A₀(t), hence Z satisfies A₀ -- [Reynolds] Section 6 induction

### Dependencies

- Step 4 depends on Steps 1-3 (inputs)
- Step 5 depends on Step 4 (k-equivalence) and Step 3 (depth bound)
- Step 6 depends on Step 5 and `table_correctness`

### Potential Formalization Challenges

- Step 2: "Restricting to finite language" means the sig must be finite; currently `MonadicSignature.preds` is a type with `Fintype` -- OK
- Step 3: Quantifier depth of `C_{A₀}(t)` is `operator_depth A₀` (after fixing Until/Since to +2 instead of +1)
- Step 4 (Theorem 15): Currently `chronicle_is_good` is sorried -- the main blocker
- Step 6: `table_correctness` does not yet exist -- the main Task 140 deliverable

---

## Quantifier Depth Verification

Concrete verification that `operator_depth` must add 2 for Until/Since:

The Reynolds translation of `U(A,B)` at position t is:
```
∃s(lt(t,s) ∧ C_A(s) ∧ ∀u(lt(t,u) ∧ lt(u,s) → C_B(u)))
```

In `MonadicFormula sig 1` (one free variable for t):
- `ex (and (lt 1 0) (and (shift C_A) (all (not (and (and (lt 2 0) (lt 0 1)) (shift₂ C_B))))))`
- Outer `ex` adds quantifier depth 1
- Inner `all` adds quantifier depth 1
- Total extra depth: 2 (from `ex` + `all`)

For atoms A, B: `operator_depth U(A,B) = max(0,0)+1 = 1` but `quantifier_depth = 2`. The bound `quantifier_depth ≤ operator_depth` fails.

**Fix required**: Change `operator_depth` in Table.lean lines 47-48:
```lean
-- Current (wrong for table_depth_bound):
| .untl φ ψ => max (operator_depth φ) (operator_depth ψ) + 1
| .snce φ ψ => max (operator_depth φ) (operator_depth ψ) + 1

-- Corrected (matches actual quantifier depth of Reynolds translation):
| .untl φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
| .snce φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
```

The corresponding change in `k` in Transfer.lean (`phi.complexity + 1`) may also need adjustment but `operator_depth` is already distinct from `Formula.complexity`, so the fix is isolated to Table.lean.

---

## Summary of Action Items

The minimal path to making progress on Task 140 without being blocked by Tasks 143+ is:

**Unblocked work** (can be done now):
1. Define `MonadicFormula.weaken` and prove `weaken_eval`
2. Fix `operator_depth` for Until/Since (add 2 instead of 1)
3. Add `atomMap` parameter to `table` and implement the definition
4. Prove `table_depth_bound` by structural induction
5. Prove `table_correctness` by structural induction (the main theorem)

**Blocked work** (requires Tasks 143+):
6. Prove `chronicle_is_good` (requires Doets 1.1 and 1.4)
7. Activate the Reynolds pipeline in `doets_countermodel_discrete`
8. Eliminate `succ_cofinal` from axioms

The `box` case in `table_correctness` needs careful design: since the bimodal semantics has box as S5-modality over world histories (not a temporal operator), the standard Reynolds translation doesn't apply. The most likely approach: treat `□φ` at the MCS level (since in the canonical model, `□φ ∈ MCS A` means φ is in every S5-accessible world), and the atom map captures this. This needs more investigation in a follow-up.
