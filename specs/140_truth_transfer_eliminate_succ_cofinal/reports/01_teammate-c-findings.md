# Task 140: Critic Findings
## Teammate C — Gap Analysis and Risk Assessment

- **Task**: 140 - truth_transfer_eliminate_succ_cofinal
- **Role**: Critic
- **Date**: 2026-05-15
- **Files Examined**:
  - `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean`
  - `Theories/Bimodal/Semantics/Truth.lean`
  - `Theories/Bimodal/Syntax/Formula.lean`
  - `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
  - `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
  - `literature/Doets_1987_Completeness_and_Definability_thesis.md`
  - `specs/141_canonical_truth_lemma_until_since/plans/02_revised-plan.md`

---

## 1. Assumptions Not Yet Validated

### 1.1 The `table` function does not exist

The `table` function in `Table.lean` has a fully sorried body. There is no partial implementation. The comment at line 66 states:

> "TODO: Implement table body in Task 140."

The `def table (sig : MonadicSignature) (_φ : Formula) : MonadicFormula sig 1 := by sorry`

This means:
- The function signature is present but the body produces no actual FO formula.
- Task 140's scope item 1 ("Prove `table_correctness`") requires `table` to be DEFINED before it can be proved correct. Correctness is a proof about the function's behavior, not a substitute for the function.
- `table_depth_bound` is also sorried and depends on the same function existing.

**Risk**: These are not just proof obligations but missing definitions. The task description says "prove table_correctness" but the prerequisite is defining `table` itself — a significantly harder implementation task that requires:
1. A mapping from temporal formula atoms to predicate symbols in `sig.preds` (placeholder `mkAtomMap` in Transfer.lean maps everything to `Formula.bot`).
2. The FO translation for each temporal operator (G, H, U, S, box).
3. Correct De Bruijn index management across operator nesting.

### 1.2 The atom map is a placeholder

`Transfer.lean` (lines 69-83) defines `mkSigFrom` and `mkAtomMap` as placeholders:
- `mkSigFrom` creates a signature with exactly one predicate (`Fin 1`), regardless of how many atoms appear in φ.
- `mkAtomMap` maps every predicate to `Formula.bot`.

These are non-functional stubs. Before truth transfer is possible, both need to be implemented with genuine atom extraction from φ. The atom extraction requires iterating over φ's subformulas to collect distinct atoms — non-trivial bookkeeping in Lean 4.

### 1.3 `chronicle_is_good` is sorried with documented hard dependencies

`IntegerModel.lean` line 211-214:
```
theorem chronicle_is_good (M : ChronicleAsPriorModel) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) (k : Nat) :
    good sig k (chronicleAsMonadicStructure M sig atomMap) := by
  sorry
```

The proof path for `chronicle_is_good` requires:
1. `very_good_implies_good` (sorried) — requires `sum_preservation`
2. `sum_preservation` (sorried in KEquivalenceFramework) — requires EF-game formalization (Doets Lemma 1.4)
3. `finite_structures_good` (sorried) — requires Doets Theorem 1.1 (finite structures have realizable k-types in Z-intervals)
4. `no_gaps_discrete` (sorried) — requires well-founded induction on the distance between chronicle points
5. `contemp_equiv_is_equiv` transitivity (sorried) — requires `sum_preservation`

This is a 4-lemma dependency chain, none of which are closed. Activating the Reynolds pipeline in Transfer.lean requires ALL of these.

### 1.4 The `table_correctness` theorem statement does not yet exist

There is no stub for `table_correctness` anywhere in the codebase. The task description mentions proving it, but there is no theorem statement to prove. The implementer must also define what `table_correctness` means — a non-trivial design decision involving:
- How to connect `eval` in `NEquivalence.lean` with `truth_at` in `Semantics/Truth.lean`
- What the "atom map" means in terms of predicate satisfaction
- How to relate `MonadicStructure` evaluation to temporal structure evaluation

---

## 2. Semantic Mismatch Risks (Irreflexive vs. Reflexive)

### 2.1 Reynolds assumes strictly irreflexive semantics; the project uses both

Reynolds 1994 (Section 2, page 1):
> "Thus they consist of a domain T, an **irreflexive** linear order < on T..."

The Reynolds paper's semantics for U and S uses strict `<`:
- `U(A, B)(t)`: ∃ s **> t** such that A(s) ∧ ∀ u ∈ (t, s), B(u)
- The FO table C_U(t) uses strict bounds: `∃s > t(P(s) ∧ ∀u(t < u ∧ u < s → Q(u)))`

The project's `truth_at` in `Semantics/Truth.lean` (lines 127-130) also uses strict `<`:
```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s φ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r ψ
```

This appears consistent. However, the `reflCanTruth` in `TruthLemma.lean` uses `tempR_fwd` (which is `g_content x ⊆ y.val` — a **non-strict** subset inclusion with reflexivity) for the Until case:
```lean
| Formula.untl ψ₁ ψ₂ =>
    ∃ (y : ReflCanDomain), tempR_fwd x y ∧ reflCanTruth y ψ₁ ∧
      (∀ (z : ReflCanDomain), tempR_fwd x z → tempR_fwd z y → reflCanTruth z ψ₂)
```

This reflexive ordering in `reflCanTruth` means the canonical model truth for Until uses non-strict `≤` on MCS chains, while `truth_at` uses strict `<`. This mismatch is a pre-existing risk (Task 141 territory), but it becomes a problem for Task 140 when attempting to prove `table_correctness` by induction through the Until/Since cases, because the two semantics will not match up directly.

**Verdict**: This semantic mismatch between `reflCanTruth` (non-strict chain semantics) and `truth_at`/Reynolds FO semantics (strict `<`) is a REAL RISK for table_correctness. Any induction proof through Until/Since must resolve this discrepancy.

### 2.2 The Burgess convention for `untl` has argument order risk

`Formula.lean` lines 79-81 document the Burgess convention:
> "Until U(φ, ψ) — Burgess convention: φ = event (eventually true), ψ = guard (holds in between)."

So `Formula.untl φ ψ` means ∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r).

Reynolds 1994 (Section 2) writes U(A, B) with:
> "there is s > t such that (T, <, h) ⊨ A(s) and for all u ∈ T, if t < u < s then (T, <, h) ⊨ B(u)"

So Reynolds' U(A, B) has A = event, B = guard — matching the Burgess convention in the code.

However, Reynolds' table (Section 6, page 5):
> "C_{U(A,B)}(t) = ∃s > t(C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))"

In the code Table.lean comment (line 12):
> "C_{U(A,B)}(t) = ∃s > t(C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))"

This matches the Reynolds paper convention directly. So the table comment is correct. The risk is that when implementing the `table` function body, the De Bruijn index for `s` vs. the guard variable `u` could be mis-ordered. With `MonadicFormula sig 1` having one free variable (index 0 = the evaluation point t), the `∃s` quantifier in the Until translation adds an additional variable at index 0 (pushing t to index 1), and then `∀u` within the guard adds another variable. This De Bruijn bookkeeping is error-prone.

---

## 3. Missing Prerequisites (What Task 139 Has Not Delivered Yet)

### 3.1 Task 139 status: what is actually implemented in NEquivalence.lean

Task 139 is described as "IMPLEMENTING" (per the dependency field). Reading `NEquivalence.lean`:
- `eval` is **defined** and appears sorry-free (lines 217-224).
- `k_type_of` is defined as `noncomputable` via `Classical.dec`.
- `k_equiv` and `k_equiv_monotone` are proved sorry-free.
- `KEquivalenceFramework` instance has `finite_types` and `sum_preservation` sorried.
- `sum_preservation` also has `carrier_order := sorry` in the sigma type body (lines 314, 317).

So what Task 139 has delivered: the `eval` Tarski semantics, the k-type computation function, and the k-equivalence relation. These are correct and available.

What Task 139 has NOT delivered (and what Task 140 depends on):
- `finite_types` — the Fintype instance for depth-bounded sentences (needed for `KType` to be finite, needed for `chronicle_is_good` downstream).
- `sum_preservation` — EF-game theorem (needed for `very_good_implies_good` → `chronicle_is_good`).
- The `carrier_order` field for sigma types in `sum_preservation` — the lexicographic order on `Sigma fun i => (ms i).carrier` is not constructed; it's `sorry`.

**Key finding**: The claim in Transfer.lean's header that "All proofs carry sorry-propagation from `k_type_of` (monadic FO satisfaction)" is INCORRECT. `k_type_of` itself is sorry-free. The sorry propagation comes from `finite_types` and `sum_preservation`, which are structural gaps in `KEquivalenceFramework`.

### 3.2 The `satisfies` terminology is absent

The task description mentions "`eval`/`satisfies` will be available from task 139." Only `eval` exists. There is no `satisfies` definition. This may just be a naming confusion in the task description (using "satisfies" informally), but it is worth noting that any `table_correctness` theorem will need to use `eval` directly.

### 3.3 The `MonadicSentence` / `eval` path requires environment management

`eval` takes an environment `Fin n → M.carrier` for the `n` free variables. The `table` function produces `MonadicFormula sig 1` — one free variable. To close a sentence (for `k_type_of`), the formula must be closed via existential/universal quantification in the table itself. When evaluating `table sig φ` for truth transfer, the implementer must pass `env = fun _ => t₀` where `t₀` is the evaluation point in the chronicle. This parametric application is non-trivial to formalize.

---

## 4. Integration Risks (Pipeline Component Mismatches)

### 4.1 The Reynolds pipeline in Transfer.lean is entirely commented out

Transfer.lean lines 121-129 show the intended pipeline:
```lean
-- Step 1: Extract chronicle
-- let M := extract_chronicle_as_prior A h_mcs h_box_discrete
-- Step 2: Build signature and atom map
-- let sig := mkSigFrom φ
-- let atomMap := mkAtomMap sig φ
-- Step 3: Prove chronicle is good...
-- Step 4: Extract Z-interval structure
-- Step 5: Transfer truth from chronicle to Z-model (requires table correctness)
-- Step 6: Package Z-model as TaskFrame Int / TaskModel
```

ALL of this is commented out. The actual proof falls back to the chronicle construction. Activating the pipeline requires:
1. Making `mkSigFrom` extract actual atoms from φ (currently placeholder: `Fin 1`).
2. Making `mkAtomMap` map predicates to the correct atomic formulas (currently maps everything to `Formula.bot`).
3. `chronicle_is_good` must be genuine (currently sorried, depends on `sum_preservation`).
4. Extract and use a `ZIntervalStructure` from `good`.
5. `table_correctness` must connect monadic FO truth in the Z-interval to temporal truth of φ.
6. Build a `TaskFrame Int / TaskModel` from the `ZIntervalStructure`.

### 4.2 The `good` definition does not expose the Z-interval

`IntegerModel.lean` line 65-67:
```lean
def good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig) : Prop :=
  ∃ (Z : ZIntervalStructure sig),
    k_equiv sig k M (Z.toOrdered sig)
```

`good` is an existential — it asserts a Z-interval exists but provides no way to extract it computably. Step 4 of the pipeline (`obtain ⟨Z, h_equiv⟩ := h_good`) will work propositionally but:
- The Z-interval `Z` extracted is not canonical/unique.
- The proof that `¬ truth_at Z t₀ φ` must refer to a SPECIFIC Z-interval, not a generically chosen one.
- This requires the transfer of the SPECIFIC SENTENCE `∃t, C_φ(t)` (the table applied to φ) from the chronicle to the Z-model. This is exactly what k-equivalence gives, but the chain of reasoning needs careful formalization.

### 4.3 Type universe mismatch between `truth_at` and `eval`

`truth_at` in `Semantics/Truth.lean` operates on:
- `TaskFrame D` (with `D : Type*`, instances `AddCommGroup D`, `LinearOrder D`, etc.)
- `TaskModel F`
- `WorldHistory F`

`eval` in `NEquivalence.lean` operates on:
- `OrderedMonadicStructure sig` (with `carrier : Type`, `LinearOrder carrier`)

Converting a `ZIntervalStructure sig` (carrier = `ℤ`) into a `TaskFrame Int / TaskModel` requires:
- A `TaskFrame Int` — which requires defining a `WorldHistory Int` structure (states, time domain, etc.)
- A `TaskModel F` — which requires a valuation from states to atomic truth
- The connection between the `interp p : ℤ → Prop` in `ZStructure` and the valuation in `TaskModel`

This universe-crossing is non-trivial. There is no existing bridge between `MonadicStructure` and `TaskFrame/TaskModel`. Creating this bridge for Task 140 may be significant new work not accounted for in the task scope.

### 4.4 The chronicle fallback has a sorry in `dd_countermodel_chronicle_discrete`

Transfer.lean uses the fallback:
```lean
exact Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete
  A h_mcs φ h_neg_in h_box_discrete_chronicle
```

The chronicle path itself goes through `succ_cofinal`, which is sorried in `ChronicleToCountermodel.lean`. So even the current "working" state of `doets_countermodel_discrete` carries a sorry transitively via the fallback. The task description's goal to "eliminate succ_cofinal" is achieved only if the Reynolds pipeline is BOTH activated AND complete — the fallback to chronicle does not eliminate succ_cofinal, it just pushes it one level deeper in the proof tree.

---

## 5. succ_cofinal Elimination Risks

### 5.1 succ_cofinal is declared a "genuine limitation" — not a missing proof step

From `BXCanonical/Chronicle/ChronicleToCountermodel.lean` (lines 1139-1148):
> "Status: Blocked. The sorry at `succ_cofinal` represents a genuine limitation of the Burgess chronicle construction under strict (irreflexive) temporal semantics. The gap scenario (orbit converging to L, pred-chain from above, no limit_dom at L) is consistent with all temporal axioms (Z1, Prior-UZ) in the constant-MCS case."

And from `StageInductionGapAnalysis/README.md`:
> "The sorry at `succ_cofinal` represents a genuine limitation of the Burgess chronicle construction under strict (irreflexive) temporal semantics, not a missing proof step. Extensive analysis (12+ research rounds, 4-teammate investigation) confirmed..."

This is the critical finding. `succ_cofinal` is not provable within the chronicle construction under strict semantics. The gap scenario is MODEL-THEORETICALLY CONSISTENT — it cannot be ruled out by the available axioms.

The proposed fix is to use the Reynolds pipeline entirely, bypassing the chronicle's `succ_cofinal` dependency. But as documented above, the Reynolds pipeline itself depends on multiple sorried lemmas (Doets 1.4, finite_types, very_good_implies_good).

**Key question**: Does the Reynolds pipeline actually bypass `succ_cofinal`, or does it implicitly require the same argument elsewhere?

The Reynolds argument for `one_class` in `IntegerModel.lean` uses:
1. `no_boundary_at_successor` — proved via finite subintervals (genuine)
2. `no_gaps_discrete` — sorried ("requires well-founded induction on the distance between a and b")
3. `finite_structures_good` — sorried ("requires Doets Theorem 1.1")

The `no_gaps_discrete` sorry ("distance between a and b") may be analogous to `succ_cofinal` — both require showing that the discrete successor function is cofinal (covers all points). Whether this is the same difficulty or a genuinely different one needs investigation.

### 5.2 succ_cofinal appears only in the chronicle path — not in WeakCanonical

The `succ_cofinal` sorry is located exclusively in `BXCanonical/Chronicle/ChronicleToCountermodel.lean`. The WeakCanonical module does NOT reference `succ_cofinal` anywhere in its files. So the elimination of `succ_cofinal` from the axiom set of `doets_countermodel_discrete` means eliminating the use of `dd_countermodel_chronicle_discrete` as a fallback — the goal is achieved by completing the Reynolds pipeline so the fallback is no longer needed.

This is correct — but it means the task requires completing the Reynolds pipeline entirely, not just removing a dependency.

### 5.3 Other paths to `succ_cofinal`

A search of the codebase shows `succ_cofinal` appears in:
- `ChronicleToCountermodel.lean` (definition + uses)
- `StageInductionGapAnalysis/` (boneyard analysis)
- `WeakCanonical/WeakCanonical.lean` header (mentions as what is being bypassed)
- `WeakCanonical/Transfer.lean` header (cites as bypassed)
- `WeakCanonical/ReflexiveCanonical.lean` header (same)

The sorry does NOT propagate into WeakCanonical directly — it is only in the chronicle path. If the Reynolds pipeline can be activated, `doets_countermodel_discrete` will stop depending on `dd_countermodel_chronicle_discrete`, and `succ_cofinal` will not be in its axiom set. But this requires the Reynolds pipeline to be complete and sorry-free itself.

---

## 6. Questions That Should Be Asked

1. **Is `no_gaps_discrete` (IntegerModel.lean:136) actually easier than `succ_cofinal`?**
   Both require showing that in a discrete linear order, every point is reachable from any other by iterating the successor function. The gap analysis for `succ_cofinal` found this impossible under strict semantics. Does `no_gaps_discrete` require the same argument? If so, the Reynolds pipeline does not actually resolve the fundamental difficulty — it relocates it.

2. **What does "truth transfer" mean formally in the Lean sense?**
   The task description says "prove table_correctness: standard translation preserves truth." But what is the statement type? It must bridge `eval` (NEquivalence.lean) and `truth_at` (Semantics/Truth.lean). No such bridge theorem statement exists. Before implementing, the exact statement must be designed.

3. **Can `mkSigFrom φ` be implemented with genuine atom extraction?**
   The current `Fin 1` placeholder is non-functional. Genuine atom extraction requires collecting the finite set of distinct atoms in φ and providing a `Fintype` instance for this set. Is there existing infrastructure for this in `Subformulas.lean` or `SubformulaClosure.lean`?

4. **Does the `carrier_order := sorry` in KEquivalenceFramework block all downstream uses?**
   In NEquivalence.lean lines 314-317, the `sum_preservation` field has `carrier_order := sorry` for the sigma type. This sorry is inside a structure field, not a theorem. Can this be fixed independently of proving `sum_preservation`? The lexicographic order on `Sigma fun i => (ms i).carrier` should be constructible from `LinearOrder I` and `LinearOrder (ms i).carrier` using `Lex.instLE`.

5. **Is `finite_types` truly needed for `chronicle_is_good`?**
   `finite_types` is needed for `KType sig k` to be `Fintype` (required for finiteness of k-equivalence classes). But `chronicle_is_good` uses `good`, which is just an existential `∃ Z, k_equiv M (Z.toOrdered)`. The `k_equiv` definition does not require `Fintype KType` — it's just function equality. Might `chronicle_is_good` be provable via `very_good_implies_good` without needing `finite_types`?

6. **Why is the Until/Since intermediate guard condition closed in BXCanonical but not in WeakCanonical?**
   Task 141 found this condition "structurally impossible in ReflCanDomain." The BXCanonical chronicle has this infrastructure (DovetailingChain.lean). Does table_correctness need to go through the chronicle's truth lemma (BXCanonical path) rather than the WeakCanonical path?

---

## 7. Confidence Levels Per Risk Area

| Risk Area | Confidence | Assessment |
|-----------|------------|------------|
| `table` function not implemented (Scope 1 prerequisite) | HIGH | Confirmed: body is `sorry` |
| Atom map placeholder blocks all atom-related truth | HIGH | Confirmed: maps to `Formula.bot` |
| `chronicle_is_good` depends on 4 sorried lemmas | HIGH | Confirmed: traceable dependency chain |
| Semantic mismatch in Until/Since: `reflCanTruth` vs `truth_at` | MEDIUM | Structural analysis: non-strict vs strict order |
| Reynolds `no_gaps_discrete` may repeat `succ_cofinal` difficulty | MEDIUM | Analogous gap scenario suspected; needs expert verification |
| Type mismatch between MonadicStructure and TaskFrame | HIGH | No bridge code exists; significant new work |
| `table_correctness` has no theorem statement to prove | HIGH | Confirmed: statement must be designed from scratch |
| Activating Reynolds pipeline requires all 4 sorry chains closed | HIGH | Confirmed from code inspection |
| succ_cofinal is NOT in WeakCanonical's direct proof path | HIGH | Confirmed: only in BXCanonical/Chronicle |
| `finite_types` blocking `chronicle_is_good` (may be independent) | MEDIUM | Needs analysis of dependency chain |

---

## 8. Summary Assessment

Task 140 as described is a substantial multi-week research and implementation effort, not a cleanup task. The scope as written (4 items) underestimates the actual work by a factor of 5-10x. The key blockers are:

**Hard blockers (cannot proceed without resolving)**:
1. `table` function body must be implemented (De Bruijn FO translation of all 8 formula constructors with correct index management).
2. `mkSigFrom` must genuinely extract atoms from φ.
3. `mkAtomMap` must genuinely map each predicate to its corresponding atom formula.
4. `table_correctness` theorem statement must be designed (bridging `eval` and `truth_at`).
5. Either `sum_preservation` must be proved (requires Doets Lemma 1.4 EF-game formalization) OR a direct argument for `chronicle_is_good` must be found that bypasses `sum_preservation`.
6. A bridge from `ZIntervalStructure` to `TaskFrame Int / TaskModel` must be built.

**Soft blockers (significant but potentially parallelizable)**:
- `no_gaps_discrete` sorry needs assessment to determine if it is the same difficulty as `succ_cofinal`.
- The reflexive/strict semantics mismatch in Until/Since must be handled in the truth transfer proof.

**What is actually achievable in a bounded effort**:
- Implementing the `table` function body (several hours, mechanical but error-prone).
- Designing and stating `table_correctness` (requires literature study of Reynolds Section 6).
- Proving `table_depth_bound` once `table` is implemented (by structural induction on φ).
- Implementing genuine `mkSigFrom` and `mkAtomMap`.
- Fixing the `carrier_order := sorry` in `sum_preservation` (constructing the lexicographic order).

**What is likely to remain sorried after Task 140 without additional sub-tasks**:
- `chronicle_is_good` (blocked on Doets 1.4 / EF-game).
- `very_good_implies_good` (same).
- `no_gaps_discrete` (potential `succ_cofinal` analog).
- Full activation of the Reynolds pipeline (blocked on the above + `table_correctness`).

The recommendation is to scope Task 140 more narrowly: define `table`, prove `table_depth_bound`, design `table_correctness`, and implement the atom extraction infrastructure — but explicitly mark the full pipeline activation and `succ_cofinal` elimination as dependent on follow-up tasks for Doets Lemma 1.4 and the `no_gaps_discrete` gap analysis.
