# Research Report: Task 140 — Truth Transfer and succ_cofinal Elimination

- **Task**: 140 - truth_transfer_eliminate_succ_cofinal
- **Started**: 2026-05-15T14:16:00Z
- **Completed**: 2026-05-15T14:55:00Z
- **Effort**: 4 teammates, ~15 min each
- **Dependencies**: 129 (COMPLETED), 139 (IMPLEMENTING)
- **Sources/Inputs**:
  - literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md (Section 6, Theorem 18)
  - literature/Doets_1989_Monadic_Pi11_Theories.md (Lemma 1.1, 1.4)
  - literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md
  - literature/Blackburn_deRijke_Venema_2002_Modal_Logic_ch4_completeness.md
  - literature/Venema_1991_Many_Dimensional_Modal_Logics_ch2.md
  - literature/Venema_1993_Since_and_Until (validates reflexive-to-strict approach)
  - literature/Obendrauf_2024_Lean_Formalization_Coalition_Logic.md (proof patterns)
  - literature/Caleiro_Vigano_Volpe_2013_Mosaic_Method_Tense_Modal.md (alternative, not recommended)
  - Theories/Bimodal/Metalogic/WeakCanonical/Table.lean
  - Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean
  - Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean
  - Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean
  - Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean
  - Theories/Bimodal/Semantics/Truth.lean
  - Theories/Bimodal/Syntax/Formula.lean
- **Artifacts**:
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_team-research.md (this file)
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_teammate-a-findings.md
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_teammate-b-findings.md
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_teammate-c-findings.md
  - specs/140_truth_transfer_eliminate_succ_cofinal/reports/01_teammate-d-findings.md
- **Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md
- **Mode**: Team Research (4 teammates)

---

## Executive Summary

- **Follow Reynolds 1994 Section 6 directly** — all 4 teammates agree no alternative is better. The standard translation is specified by Reynolds as "a simple induction" and the table correctness proof is near-definitional.
- **Task scope must be narrowed**: the full pipeline wiring and `succ_cofinal` elimination are BLOCKED by `sum_preservation` (Doets Lemma 1.4, EF-game formalization) via `chronicle_is_good`. Achievable scope: implement `table`, prove `table_depth_bound`, state+prove `table_correctness`.
- **Three critical infrastructure gaps** must be filled before `table` can be implemented: (1) `MonadicFormula.weaken` function for De Bruijn index shifting, (2) genuine `mkSigFrom`/`mkAtomMap` replacing `Fin 1` placeholder, (3) `operator_depth` fix for Until/Since (add 2, not 1).
- **The `box` constructor requires special handling** — Reynolds only covers temporal operators; S5 box is not FO-expressible over linear time. Must be treated as an atom via the MCS labeling.
- **Net sorry reduction achievable**: 2 sorries (`table`, `table_depth_bound`) plus the new `table_correctness` theorem. Full `succ_cofinal` elimination requires follow-up work on `sum_preservation`.

---

## Context & Scope

Task 140 sits at the critical-path fulcrum: task 129 built the Reynolds pipeline structure, task 139 provides FO satisfaction infrastructure, and task 140 must provide the semantic glue (standard translation) connecting temporal truth to monadic FO truth. The 4 stated scope items are:

1. Prove `table_correctness` (standard translation preserves truth)
2. Close `table_depth_bound` (quantifier depth bounded by operator depth)
3. Replace chronicle fallback in `doets_countermodel_discrete` with Reynolds pipeline
4. Verify `succ_cofinal` elimination from axiom set

**Critical finding**: Items 1-2 are achievable. Items 3-4 are blocked by `chronicle_is_good` → `very_good_implies_good` → `sum_preservation` (all sorried, dependency chain of 4 lemmas). The task description should be revised to reflect this split.

---

## Findings

### 1. The `table` function body is the central deliverable

`Table.lean:66` has `def table (sig : MonadicSignature) (_φ : Formula) : MonadicFormula sig 1 := by sorry`. This is a missing *definition*, not a missing proof. The body must translate each `Formula` constructor to the corresponding `MonadicFormula sig 1` expression following Reynolds 1994 Section 6:

| Formula case | Reynolds FO translation | MonadicFormula encoding |
|-------------|------------------------|------------------------|
| `atom a` | `P_a(t)` | `MonadicFormula.atom (atomMap a) 0` |
| `bot` | `t < t` (always false) | `MonadicFormula.lt 0 0` |
| `imp φ ψ` | `¬(C_φ ∧ ¬C_ψ)` | `not (and (table φ) (not (table ψ)))` |
| `box φ` | Atom-like (see below) | `MonadicFormula.atom (atomMap (box φ)) 0` |
| `all_future φ` | `∀s > t, C_φ(s)` | `all (not (and (lt 1 0) (not (weaken (table φ)))))` |
| `all_past φ` | `∀s < t, C_φ(s)` | `all (not (and (lt 0 1) (not (weaken (table φ)))))` |
| `untl φ ψ` | `∃s>t(C_φ(s) ∧ ∀u(t<u<s → C_ψ(u)))` | 2 quantifiers, 3 var levels |
| `snce φ ψ` | Symmetric to Until | 2 quantifiers, 3 var levels |

**Confidence**: HIGH on translation structure. MEDIUM on De Bruijn index bookkeeping (especially for Until/Since with 2 quantifiers).

### 2. Missing infrastructure: `MonadicFormula.weaken`

The `table` definition requires lifting formulas under quantifier binders. A `weaken` function shifts all variable indices up by 1:

```lean
def MonadicFormula.weaken {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → MonadicFormula sig (n + 1)
  | .atom p i => .atom p i.castSucc
  | .lt i j => .lt i.castSucc j.castSucc
  | .not α => .not α.weaken
  | .and α β => .and α.weaken β.weaken
  | .all α => .all α.weaken
  | .ex α => .ex α.weaken
```

The key property for `table_correctness` is `weaken_eval`:
```
eval M (Fin.cons x env) (α.weaken) = eval M env α
```

This says evaluating a weakened formula in an extended environment equals evaluating the original in the base environment. This is the standard substitution lemma for De Bruijn indices.

### 3. `mkSigFrom` and `mkAtomMap` are non-functional placeholders

`Transfer.lean:69-83`: `mkSigFrom` creates a signature with `preds := Fin 1` (single predicate), `mkAtomMap` maps everything to `Formula.bot`. Both must be replaced with genuine atom extraction.

**Recommended design**: `preds := φ.atoms` (the finite set of atoms appearing in φ), with `atomMap : Atom → sig.preds` mapping each atom to its predicate symbol. Requires a `Formula.atoms : Formula → Finset Atom` function (probably ~20 lines, structural induction on `Formula`). For the `box` case, the atom map must additionally map `box`-subformulas to predicate symbols (since `□φ` truth in the chronicle is determined by MCS membership, functioning like an atom).

### 4. `operator_depth` bug for Until/Since

**All teammates confirmed**: `Table.lean:47-48` adds only 1 for Until/Since, but Reynolds' translation uses 2 quantifiers (∃s, ∀u). For atoms A, B: `operator_depth (untl A B) = 1` but `quantifier_depth(table(untl A B)) = 2`. The bound `table_depth_bound` as stated is FALSE.

**Fix**: Change lines 47-48:
```lean
| .untl φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
| .snce φ ψ => max (operator_depth φ) (operator_depth ψ) + 2
```

### 5. `box` constructor: not in Reynolds, needs special handling

Reynolds 1994 only covers temporal operators (G, H, U, S). The bimodal `□φ` quantifies over S5-accessible worlds — not FO-expressible over linear time. In the Reynolds pipeline context, the chronicle handles S5 via MCS labeling: `□φ ∈ MCS` is a fact about the label, not a temporal quantifier.

**Resolution**: Treat `box φ` as an atom in the `table` translation. The `atomMap` must map both base atoms and `box`-subformulas to predicate symbols. In the chronicle-as-monadic-structure, `interp (atomMap (box φ)) t = (box φ ∈ fmcs t)`. This makes the atom case of `table_correctness` for `box` equivalent to the truth definition `truth_at ... t (box φ) = ∀ σ ∈ Omega, truth_at ... σ t φ`, which must be handled via properties of maximal consistent sets, not by the standard translation alone.

**Alternative**: Restrict `table` to the temporal fragment and handle `box` separately in the pipeline. This may be cleaner architecturally.

### 6. Reynolds pipeline is BLOCKED by `chronicle_is_good` dependency chain

The dependency chain to activate the pipeline (all sorried):
```
chronicle_is_good (IntegerModel.lean)
  → very_good_implies_good
    → sum_preservation (Doets Lemma 1.4, EF-game) ← HARD BLOCKER
    → finite_structures_good (Doets Theorem 1.1)   ← Task 143
  → no_gaps_discrete                               ← May be analogous to succ_cofinal
  → contemp_equiv_is_equiv (transitivity)
    → sum_preservation
```

**Critic's warning**: `no_gaps_discrete` ("requires well-founded induction on the distance between a and b") may be the same difficulty as `succ_cofinal` — both require showing the discrete successor function is cofinal. If so, the Reynolds pipeline relocates rather than resolves the fundamental difficulty. This needs investigation.

**Horizons' mitigation**: For the single-class case (which `one_class` proves for the chronicle), `very_good_implies_good` might be specializable to avoid the full `sum_preservation`. But `finite_structures_good` is still needed, blocking this path too.

### 7. Semantic mismatch: reflexive vs strict

The Critic identified that `reflCanTruth` in `TruthLemma.lean` uses non-strict `tempR_fwd` (content chain inclusion, ≤-like) while `truth_at` uses strict `<`. This discrepancy matters for the Until/Since cases. However, `table_correctness` relates `eval` to `truth_at` (both strict), not to `reflCanTruth`. The mismatch is a task 141 concern, not task 140.

### 8. Task independence: 141 and 142 can proceed in parallel

- **Task 141** (canonical truth lemma Until/Since): architecturally independent. The parametric truth lemma in the Algebraic module handles completeness; task 141's TruthLemma.lean sorries are dead code relative to `bx_completeness`.
- **Task 142** (mixed-case countermodel): the mixed case is a different logical problem from the discrete Reynolds compression. Research can begin immediately.

---

## Synthesis

### Conflicts Resolved

1. **Scope of achievable work**: Teammate C characterized full scope as "multi-week"; Teammates A, B, D estimated 2-5h for table implementation alone. **Resolution**: Both are right — the narrowed scope (table + table_depth_bound + table_correctness) is achievable in 8-12h. The full pipeline wiring + succ_cofinal elimination requires sum_preservation (separate task). The task description should be revised.

2. **`table_correctness` difficulty**: Teammate D suggested ~50-100 lines, near-definitional; Teammate A rated medium confidence on De Bruijn details; Teammate C flagged the `eval`/`truth_at` bridge. **Resolution**: the mathematical content is thin (standard induction per Reynolds) but the Lean formalization work is real — `weaken` + `weaken_eval` + careful index tracking for Until/Since add ~4-6h of work.

3. **`box` handling**: Teammate A suggested treating as atom; Teammate B suggested restricting `table` to temporal fragment. **Resolution**: Both are viable. Treating `box` as atom is simpler for the `table` definition but requires the atom map to handle subformula-atoms. Restricting to temporal fragment is cleaner but requires separate `box` handling in the pipeline. Recommend: treat `box` as atom (consistent with how the chronicle works).

### Gaps Identified

1. **`Formula.atoms` function** does not exist in the codebase — needed for genuine `mkSigFrom`. Must collect the finite set of atoms (and box-subformulas if treating box as atom) from a formula.

2. **`weaken_eval` lemma** is the key bridge for `table_correctness` — not in codebase.

3. **No bridge from `ZIntervalStructure` to `TaskFrame Int / TaskModel`** — needed for pipeline step 6. Significant new type-level work.

4. **`no_gaps_discrete` vs `succ_cofinal` equivalence** — unresolved. If they are equivalent, the Reynolds pipeline does not truly resolve the discrete case.

5. **The exact `table_correctness` theorem statement** does not exist — must be designed. Approximate form: `∀ φ M t, truth_at M Ω τ t φ ↔ eval (toMonadic M atomMap) (fun _ => t) (table sig atomMap φ)`.

### Recommendations

**Narrow task 140 scope** to what is achievable:

1. Fix `operator_depth` for Until/Since (add 2, not 1)
2. Define `MonadicFormula.weaken` + prove `weaken_eval`
3. Add `Formula.atoms` or equivalent; fix `mkSigFrom`/`mkAtomMap`
4. Add `atomMap` parameter to `table`; implement body following Reynolds Section 6
5. Prove `table_depth_bound` (structural induction)
6. State and prove `table_correctness` (structural induction via `weaken_eval`)
7. Partially activate Transfer.lean pipeline (fill `table`-using steps, leave `chronicle_is_good` as sorry with blocker note)

**Explicitly defer**:
- Full pipeline activation (blocked on `sum_preservation`)
- `succ_cofinal` elimination (blocked on pipeline activation)
- `chronicle_is_good` proof (requires Doets 1.4 EF-game)

**Net sorry reduction**: 2 existing sorries (`table`, `table_depth_bound`) closed + 1 new theorem (`table_correctness`) proved. Pipeline sorries (`chronicle_is_good`, `sum_preservation`, `finite_structures_good`) remain unchanged.

**Recommended task description update**: Remove "eliminate succ_cofinal" from the title/DoD. Reframe as "implement standard translation and prove table correctness."

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary | completed | high | `weaken` infrastructure, `box` handling, Reynolds case-by-case mapping |
| B | Alternatives | completed | high | Confirmed Reynolds is best; `atomInj` design; Obendrauf proof patterns |
| C | Critic | completed | high | Dependency chain analysis; `no_gaps_discrete` risk; scope underestimate |
| D | Horizons | completed | high | Strategic scoping; task independence; single-class bypass idea |

---

## References

- Reynolds, M. (1994). "Axiomatising first-order temporal logic: Until and Since over linear time." Section 6 (standard translation), Theorem 18 (completeness pipeline).
- Doets, K. (1989). "Monadic Π₁¹-theories of Π₁¹-properties." Lemma 1.1 (finite k-types), Lemma 1.4 (sum preservation).
- Blackburn, P., de Rijke, M., Venema, Y. (2002). "Modal Logic." Ch. 4 (completeness), Appendix A (standard translation).
- Venema, Y. (1993). "Derivation Rules as Anti-Axioms in Modal Logic." (Validates reflexive-to-strict approach.)
- Obendrauf, J. (2024). "Lean Formalization of Coalition Logic." (Lean 4 proof patterns for structural induction on formulas.)
- Hodkinson, I., Reynolds, M. (2006). "Temporal Logic." Handbook of Modal Logic, Ch. 11. (Overview of completeness techniques.)
