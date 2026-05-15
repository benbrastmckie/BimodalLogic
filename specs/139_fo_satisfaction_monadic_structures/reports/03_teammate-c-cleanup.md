# Task 139 Cleanup Audit

- **Task**: 139 - FO Satisfaction / Monadic Structures
- **Auditor**: teammate-c
- **Date**: 2026-05-14
- **Scope**: WeakCanonical/ — NEquivalence, IntegerModel, OrderedSum, Table, Transfer, ChronicleExtraction
- **Format**: File-by-file audit -> Consolidated cleanup actions -> Priority ordering

---

## File-by-File Audit

### NEquivalence.lean

**Overall quality**: High. The redesign achieved by Task 139 is clean and well-documented. The De Bruijn `MonadicFormula`, `eval`, `k_type_of`, and `KEquivalenceFramework` are all sound.

**Issues found**:

1. **`ktype_finite` — DEAD CODE, WRONG SEMANTICS** (lines 353-355)
   ```lean
   noncomputable def ktype_finite (sig : MonadicSignature) (k : Nat) :
       Fintype (KType sig k) := by
     sorry
   ```
   This definition is never referenced anywhere in the entire codebase (confirmed by grep). It also has the wrong type: `KType sig k` is a function type `{s // depth ≤ k} → Bool`, which is NOT syntactically `Fintype` without first proving that the subtype domain is finite. The comment says "proved in Phase 3 (depends on Fintype for depth-bounded formulas)" but Phase 3 never proved it; instead `KEquivalenceFramework.finite_types` carries the same sorry directly. Two separate sorry stubs for the same unproven result, one of which is completely unreferenced.
   **Verdict**: Delete. It is unreferenced dead code with a misleading docstring.

2. **`k_equiv_iff_same_type` — TRIVIAL / VACUOUS** (lines 278-282)
   ```lean
   theorem k_equiv_iff_same_type ... :
       k_equiv sig k M N ↔ k_type_of sig k M = k_type_of sig k N := by
     rfl
   ```
   `k_equiv` is *defined* as `k_type_of sig k M = k_type_of sig k N`, so this iff is definitionally true and adds no mathematical content. It exists only to expose the definitional equality under a different name.
   **Verdict**: Marginal. Keep only if there are downstream callsites that need the `iff` lemma form. Currently there are none. Archive to Boneyard or delete.

3. **`Mathlib.Data.Fin.VecNotation` import — POSSIBLY UNUSED**
   `Fin.cons` (used in `eval`) is from `Mathlib.Data.Fin.Basic`, not `VecNotation`. `VecNotation` provides `![1,2,3]` matrix/vector literal notation. No such notation is used in the file. The import is likely a leftover from an earlier draft.
   **Verdict**: Remove the import. Verify the build still passes (`lake build Bimodal.Metalogic.WeakCanonical.NEquivalence`).

4. **`carrier_order := sorry` inside `KEquivalenceFramework.sum_preservation`** (lines 331-334)
   The two inline `carrier_order := sorry` in the struct literal inside the `sum_preservation` field are structurally necessary (the `OrderedMonadicStructure` constructor requires a `LinearOrder` field). These are not removable without redesigning the struct literal. They are correctly labeled with a TODO.
   **Verdict**: Keep as-is. These are load-bearing sorry placeholders for Task 141/142 scope.

5. **`OrderedSum` definition in this file vs. `OrderedSum.lean`**
   `def OrderedSum` is defined at line 194 of NEquivalence.lean and is used only in docstrings of `OrderedSum.lean`. The actual theorems in `OrderedSum.lean` (`doets_lemma_1_4`, `doets_lemma_1_5`) do NOT use `OrderedSum` by name — they inline the sigma-type constructor directly. This means `OrderedSum` is defined but never called.
   **Verdict**: Archive to Boneyard. The inline construction in `doets_lemma_1_4` is clearer for proof purposes, and the abstract `OrderedSum` adds indirection without benefit.

6. **`chronicleAsMonadicStructure_*` instance cluster** (lines 405-453)
   Six instances (`_countable`, `_no_max`, `_no_min`, `_succ`, `_pred`, `_nonempty`) registering properties of `chronicleAsMonadicStructure M sig atomMap`. These are never called by any downstream file (confirmed by grep). They would be needed when `chronicle_is_good` calls `chronicleAsMonadicStructure`, but that theorem is entirely sorry at this stage. When Task 140/141 activates those proofs, Lean's instance search will find them automatically.
   **Verdict**: Keep. Instance registration is passive (no call-site needed) and these will be needed once the downstream pipeline activates. Zero maintenance cost.

---

### IntegerModel.lean

**Overall quality**: Acceptable. Definitions are genuine. Proofs that depend on `sum_preservation` are correctly sorry'd with TODO markers. The comment documentation is honest about the deferred chain.

**Issues found**:

1. **`ZIntervalStructure.carrierSet` — DEAD CODE** (lines 47-48)
   ```lean
   def ZIntervalStructure.carrierSet {sig} (Z : ZIntervalStructure sig) : Set ℤ := ...
   ```
   Defines the carrier as a `Set ℤ`, but `ZIntervalStructure.toOrdered` ignores bounds entirely — it creates an `OrderedMonadicStructure` with carrier `ℤ` (all integers, not just the interval). The `carrierSet` definition is never referenced anywhere in the project.
   **Verdict**: Archive to Boneyard. The `Set ℤ` approach was the correct design intention (bounded carriers), but since `toOrdered` uses unbounded `ℤ`, `carrierSet` is orphaned scaffolding for a design that was not completed. It documents a known tension but adds confusion without being used.

2. **`ZStructure.toZInterval` — DEAD CODE** (lines 64-68, in IntegerModel.lean)
   Converts a full-`ℤ` `ZStructure` to a `ZIntervalStructure` with `lo := none, hi := none`. Never referenced anywhere. Only exists to express the conceptual subset relationship.
   **Verdict**: Archive to Boneyard. The conceptual relationship is obvious (a full-ℤ structure is an interval with no bounds) and the conversion function is never called.

3. **`finite_structures_good` sorry chain is correctly labeled** (lines 95-101)
   The sorry is genuinely deferred (Doets Theorem 1.1 / Task 141 scope) with accurate TODO documentation. No cleanup needed.

4. **`contemp_equiv_is_equiv.trans` sorry** (line 139)
   Correctly deferred with TODO. The symmetric and reflexive cases are proven. The transitivity sorry is the right blocker for Task 141.

5. **`no_gaps_discrete` sorry** (line 156)
   Correctly labeled as requiring well-founded induction. The TODO is accurate.

6. **`very_good_implies_good` and `chronicle_is_good` sorries** (lines 213, 225)
   Both correctly labeled as depending on `sum_preservation`. The dependency chain documentation is accurate and honest.

**No dead code deletion needed beyond `ZIntervalStructure.carrierSet` and `ZStructure.toZInterval`.**

---

### OrderedSum.lean

**Overall quality**: Low. The file is mostly sorry scaffolding. Two of the three theorems are entirely inert.

**Issues found**:

1. **`finite_structures_k_equiv_to_Z_interval` — MISLEADING TRIVIAL PROOF** (lines 82-86)
   ```lean
   theorem finite_structures_k_equiv_to_Z_interval (sig) (k) (M) [Fintype M.carrier] :
       ∃ (N : OrderedMonadicStructure sig), k_equiv sig k M N := by
     exact ⟨M, rfl⟩
   ```
   The docstring claims this says M is k-equivalent to "some structure" — that structure is M itself (reflexivity). This is a trivially true statement that says nothing about Z-interval realizability. The name `_k_equiv_to_Z_interval` is actively misleading since the witness `N = M` is not a Z-interval. The TODO says it requires "genuine k-equivalence reasoning (finite decomposition into ordered sum + doets_lemma_1_4)" which would yield a different, non-trivial witness. The current "proof" is semantically vacuous.
   **Verdict**: Boneyard. This is the kind of aspirational stub that looks proven but proves nothing useful. Keeping it risks future code treating it as a genuine result.

2. **`finite_structures_k_equiv_for_all_k` — DEAD WRAPPER OF TRIVIAL RESULT** (lines 91-94)
   Only used internally to wrap `finite_structures_k_equiv_to_Z_interval`. Never called externally. Since the wrapped theorem is already being sent to the Boneyard, this wrapper goes with it.
   **Verdict**: Delete (goes with `finite_structures_k_equiv_to_Z_interval`).

3. **`doets_lemma_1_5` — ACKNOWLEDGED BYPASS** (lines 59-71)
   The docstring says it is "bypassed in the discrete case by the one_class argument" and "only needed if dense completeness is pursued." This is correct — the discrete completeness path (Task 139's scope) never needs this lemma. However, it is a correctly formulated sorry stub that represents genuine mathematical content (Doets 1989 Lemma 1.5). It belongs in the file as a placeholder for the dense completeness path.
   **Verdict**: Keep, but update the docstring to explicitly state it is NOT on the discrete completeness critical path. Add a comment: `-- Not needed for discrete completeness. Needed only for dense case (future work).`

4. **`doets_lemma_1_4` — CORRECTLY SORRIED** (lines 37-47)
   The two `carrier_order := sorry` are structurally necessary (same situation as NEquivalence). The outer proof is correctly deferred to EF-game formalization. The sorry is legitimate and properly documented.
   **Verdict**: Keep as-is.

---

### Table.lean

**Overall quality**: Good structure, but contains a significant naming hazard.

**Issues found**:

1. **`Formula.complexity` — NAMING COLLISION RISK** (lines 35-43)
   ```lean
   def Formula.complexity : Formula → Nat
     | .atom _ => 0  -- gives 0 for atoms
   ```
   `Bimodal.Syntax.Formula` already has `def complexity : Formula → Nat` in `Formula.lean` (inside `namespace Formula`, inside `namespace Bimodal.Syntax`) that gives `atom => 1`. The Table.lean definition is inside `namespace Bimodal.Metalogic.WeakCanonical` with `open Bimodal.Syntax`, so it creates `Bimodal.Metalogic.WeakCanonical.Formula.complexity` — a different constant with different semantics.

   Since Table.lean is imported by WeakCanonical.lean which is imported by Completeness.lean (which opens `Bimodal.Syntax`), downstream code that writes `φ.complexity` in a context where both `Bimodal.Syntax.Formula.complexity` and `Bimodal.Metalogic.WeakCanonical.Formula.complexity` are in scope will prefer the Bimodal.Syntax one. But the Table.lean function itself uses the local version, meaning `table_depth_bound` asserts a bound using a DIFFERENT complexity measure than the rest of the system.

   When Task 140 implements `table`, the bound in `table_depth_bound` will need to be consistent with either the Syntax complexity or a freshly named measure. The current local redefinition of `Formula.complexity` with different semantics (0 vs 1 for atoms) is a latent bug.
   **Verdict**: Rename to `Formula.table_complexity` or `Formula.operator_depth` to avoid shadowing. Document that it differs from `Formula.complexity` in `Syntax/Formula.lean` (which counts connectives, not operators).

2. **`table` and `table_depth_bound` sorries** — Task 140 scope. Correctly labeled. No action needed.

---

### Transfer.lean

**Overall quality**: Clean. The file is a well-structured pipeline stub with an honest fallback.

**Issues found**:

1. **`mkSigFrom` placeholder** (lines 69-73)
   ```lean
   noncomputable def mkSigFrom (_φ : Formula) : MonadicSignature where
     preds := Fin 1  -- placeholder: single predicate
   ```
   This is a stub with `Fin 1` as a placeholder for the genuine atom-indexed signature. It is referenced only in commented-out code inside `doets_countermodel_discrete` (lines 122-123). It is never called by live code. The `_φ` parameter (underscore-prefixed) is unused, confirming placeholder status.
   **Verdict**: Acceptable as-is. The placeholder serves as a type-correct stub for the commented-out Reynolds pipeline wiring. The comment structure makes it clear this is Task 140 scope. No action needed unless the commented-out lines are removed.

2. **`mkAtomMap` placeholder** (lines 82-85)
   Same situation as `mkSigFrom` — stub, only in commented-out code, correctly labeled. Acceptable as-is.

3. **`doets_countermodel_discrete` fallback** (lines 117-136)
   The `have h_next_top_eq : next_top = ...` + `rw` dance is necessary to bridge the namespace. This is clean and correct. The commented-out Reynolds pipeline steps are well-organized and properly explain the future activation path.
   **Verdict**: No action needed.

---

### ChronicleExtraction.lean

**Overall quality**: Excellent. Zero sorries. Clean design.

**Issues found**:

1. **`DiscreteHypothesis` — DEAD DEFINITION** (lines 44-45)
   ```lean
   def DiscreteHypothesis (A : Set Formula) (h_mcs : SetMaximalConsistent A) : Prop :=
     ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x
   ```
   This definition is never referenced anywhere outside the file in which it is defined. The `extract_chronicle_as_prior` function uses the underlying condition directly through `box_discrete_gives_discreteness`, never invoking `DiscreteHypothesis` by name. It was likely created as an intermediate abstraction that was then bypassed.
   **Verdict**: Delete. The mathematical content (discrete hypothesis) is captured in the `ChronicleAsPriorModel.next_top_everywhere` field. Having a separate named predicate that is never used adds confusion.

2. **`chronicle_discrete_succ` and `chronicle_discrete_pred`** (lines 199-208)
   ```lean
   def chronicle_discrete_succ (M : ChronicleAsPriorModel) (t : M.domain) : M.domain := Order.succ t
   def chronicle_discrete_pred (M : ChronicleAsPriorModel) (t : M.domain) : M.domain := Order.pred t
   ```
   These are two thin wrappers around `Order.succ` and `Order.pred` that provide no additional information. They are never called anywhere outside the file. Since `domain_succ : SuccOrder domain` is registered as an `[instance]`, any code that needs `Order.succ` on a `ChronicleAsPriorModel.domain` can use it directly via instance inference.
   **Verdict**: Delete. Pure wrapping dead code.

3. **`chronicle_no_endpoints_forward` and `chronicle_no_endpoints_backward`** (lines 183-191)
   These delegate to `exists_gt` and `exists_lt` via the typeclass instances. They are never called externally.
   **Verdict**: Marginal. These at least give named forward-and-backward seriality results that a future proof might cite. Keep — low cost, mild documentary value.

4. **`chronicle_prior_domain_linear_order` and `chronicle_prior_domain_countable`** (lines 169-177)
   These are named instances that duplicate what `attribute [instance]` already provides on the structure fields. Since `domain_lo` and `domain_countable` are already `[instance]` attributes, these explicit instance declarations are redundant.
   **Verdict**: Delete. The `[attribute instance]` declarations at lines 121-127 make these redundant.

---

## Consolidated Cleanup Actions

### Delete (safe — confirmed dead, adds confusion)

| File | Item | Lines | Reason |
|------|------|--------|--------|
| NEquivalence.lean | `ktype_finite` | 353-355 | Dead code, same sorry as `finite_types`, never referenced |
| NEquivalence.lean | `Mathlib.Data.Fin.VecNotation` import | 4 | VecNotation not used; `Fin.cons` comes from `Mathlib.Data.Fin.Basic` |
| ChronicleExtraction.lean | `DiscreteHypothesis` | 44-45 | Never referenced; condition captured by `next_top_everywhere` |
| ChronicleExtraction.lean | `chronicle_discrete_succ` | 199-202 | Thin wrapper on `Order.succ`, never called |
| ChronicleExtraction.lean | `chronicle_discrete_pred` | 204-208 | Thin wrapper on `Order.pred`, never called |
| ChronicleExtraction.lean | `chronicle_prior_domain_linear_order` instance | 169-171 | Redundant with `attribute [instance] ChronicleAsPriorModel.domain_lo` |
| ChronicleExtraction.lean | `chronicle_prior_domain_countable` instance | 173-177 | Redundant with `attribute [instance] ChronicleAsPriorModel.domain_countable` |

### Archive to Boneyard (valuable but currently inert or misleading)

| File | Item | Reason |
|------|------|--------|
| NEquivalence.lean | `k_equiv_iff_same_type` | Definitionally trivial (`rfl`), no callers; borderline but adds no proof value |
| NEquivalence.lean | `def OrderedSum` | Defined but never called; sigma-type inline is used directly in `doets_lemma_1_4` |
| IntegerModel.lean | `ZIntervalStructure.carrierSet` | Orphaned design scaffolding; `toOrdered` ignores bounds, making this dead |
| IntegerModel.lean | `ZStructure.toZInterval` | Never called; conceptual subset of `ZIntervalStructure` never operationalized |
| OrderedSum.lean | `finite_structures_k_equiv_to_Z_interval` | Trivial `exact ⟨M, rfl⟩` proof is semantically vacuous; the name is actively misleading |
| OrderedSum.lean | `finite_structures_k_equiv_for_all_k` | Wrapper of the above; goes with it |

### Fix (non-trivial correction needed)

| File | Item | Fix Required |
|------|------|-------------|
| Table.lean | `Formula.complexity` definition | Rename to `Formula.operator_depth` (or similar) to avoid shadowing `Bimodal.Syntax.Formula.complexity` which gives different values (atom => 1 vs 0). Update `table_depth_bound` to use the new name. |
| OrderedSum.lean | `doets_lemma_1_5` docstring | Add explicit note: "Not on discrete completeness critical path. Required only for dense case (future work)." |

### Keep As-Is

| File | Item | Reason |
|------|------|--------|
| NEquivalence.lean | `chronicleAsMonadicStructure_*` instances (×6) | Passive instance registration; needed when Reynolds pipeline activates |
| NEquivalence.lean | `carrier_order := sorry` in `sum_preservation` | Load-bearing placeholder; Task 141/142 scope |
| NEquivalence.lean | `KEquivalenceFramework.finite_types := sorry` | Correctly deferred; Task 141 scope |
| IntegerModel.lean | All sorry proofs with TODO markers | All correctly scoped to Task 141/142 |
| OrderedSum.lean | `doets_lemma_1_4` with `carrier_order := sorry` | Correctly deferred; EF-game scope |
| Table.lean | `table` and `table_depth_bound` sorries | Task 140 scope; correctly labeled |
| Transfer.lean | `mkSigFrom`, `mkAtomMap` stubs | Correctly placed in commented-out pipeline code; Task 140 scope |
| Transfer.lean | `doets_countermodel_discrete` fallback | Working bridge to chronicle; correct |
| ChronicleExtraction.lean | `chronicle_no_endpoints_forward/backward` | Low cost, documentary value |

---

## Priority Order

**Priority 1 — Do now (safe deletions, no downstream risk)**
1. Delete `DiscreteHypothesis`, `chronicle_discrete_succ/pred`, two redundant instances from `ChronicleExtraction.lean`
2. Remove `Mathlib.Data.Fin.VecNotation` import from `NEquivalence.lean` (verify build)
3. Delete `ktype_finite` from `NEquivalence.lean`

**Priority 2 — Do now (Boneyard moves)**
4. Archive `OrderedSum` def from `NEquivalence.lean` to Boneyard
5. Archive `finite_structures_k_equiv_to_Z_interval` + `finite_structures_k_equiv_for_all_k` from `OrderedSum.lean` to Boneyard (or delete the file if nothing remains of value)
6. Archive `ZIntervalStructure.carrierSet` and `ZStructure.toZInterval` from `IntegerModel.lean` to Boneyard

**Priority 3 — Fix before Task 140 activates**
7. Rename `Formula.complexity` in `Table.lean` to avoid shadow collision. This MUST happen before Task 140 implements the `table` body, since the renamed function feeds `table_depth_bound`.

**Priority 4 — Optional polish**
8. Archive `k_equiv_iff_same_type` from `NEquivalence.lean` (trivial, no callers)
9. Update `doets_lemma_1_5` docstring in `OrderedSum.lean`

---

## Confidence Assessment

| Finding | Confidence | Basis |
|---------|------------|-------|
| `ktype_finite` is dead code | High | grep confirms zero external references |
| `VecNotation` import is unnecessary | High | `Fin.cons` is not from VecNotation; no `![...]` syntax in file |
| `DiscreteHypothesis` is dead | High | Only defined, never called anywhere |
| `chronicle_discrete_succ/pred` are dead | High | grep confirms no external callers; instances cover the functionality |
| `finite_structures_k_equiv_to_Z_interval` is vacuous | High | `exact ⟨M, rfl⟩` proves M ≡_k M (reflexivity), not Z-interval realizability |
| `ZIntervalStructure.carrierSet` is orphaned | High | `toOrdered` uses full `ℤ` not the bounded set; no callers |
| `Formula.complexity` naming collision risk | Medium-High | The two defs have different semantics (atom: 0 vs 1); in scope together via Completeness.lean import chain; current code is safe but Task 140 activation could expose the collision |
| `k_equiv_iff_same_type` is vacuous | High | `k_equiv` is definitionally `k_type_of M = k_type_of N`; the iff is `rfl` |
| `OrderedSum` def is dead | Medium | No callers found; `doets_lemma_1_4` inlines the sigma type directly; could become useful if OrderedSum theorems are proved |
| `ZStructure.toZInterval` is dead | High | No callers anywhere |
