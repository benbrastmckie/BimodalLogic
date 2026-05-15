# Teammate A Findings: Code vs Plan Audit for Task 129

**Date**: 2026-05-14
**Angle**: Primary — systematic audit of Lean source code against plan claims
**Confidence**: HIGH

## Key Findings

- **BUILD IS BROKEN**: `IntegerModel.lean` fails to compile due to duplicate `ZStructure` and `ZStructure.toMonadic` declarations (already defined in `NEquivalence.lean`, which is transitively imported). The plan claims "Phase 7: lake build passes (1644 jobs)" — this is FALSE as of the current codebase state.
- **Transfer.lean has 0 sorry occurrences** in proof bodies (the plan says "sorried body"). It delegates to the chronicle fallback `dd_countermodel_chronicle_discrete`, so it has 0 direct sorries but inherits `succ_cofinal` transitively. The plan's Phase 6 status of [PARTIAL] is accurate — the Reynolds pipeline is commented out, not wired.
- **ChronicleExtraction.lean is genuinely sorry-free** (Phase 2 COMPLETED claim is accurate).
- **NEquivalence.lean has 3 sorries**, all clean and expected (Phase 3 accurately described).
- **OrderedSum.lean has 3 sorries** (Phase 4 accurately described).
- **IntegerModel.lean has 9 sorries + 2 build errors** (Phase 5 claims are inaccurate due to build breakage).
- **Table.lean has 3 sorries** (supporting file, not on critical path).
- The `KEquivalenceFramework` includes a `z_model_exists` axiomatized field that essentially axiomatizes the entire Theorem 15 conclusion. This may be mathematically convenient but is architecturally dubious — it makes the framework into a circular assumption.
- **Total sorry count across target files**: 18 (matching plan claim), but 2 build errors make some inaccessible.

## Per-File Audit

### ChronicleExtraction.lean (Phase 2) — 210 lines, 0 sorries
**Status: COMPLETED (plan claim ACCURATE)**

| Declaration | Type | Status |
|-------------|------|--------|
| `DiscreteHypothesis` | def | Non-vacuous (predicate over limit domain) |
| `prior_UZ_in_limit_domain` | theorem | Sorry-free (uses `theorem_in_mcs`) |
| `prior_SZ_in_limit_domain` | theorem | Sorry-free (uses `theorem_in_mcs`) |
| `ChronicleAsPriorModel` | structure | Well-defined, 14 fields |
| `extract_chronicle_as_prior` | def | Sorry-free, noncomputable |
| `chronicle_prior_domain_linear_order` | instance | Sorry-free |
| `chronicle_prior_domain_countable` | instance | Sorry-free |
| `chronicle_no_endpoints_forward` | theorem | Sorry-free (`exists_gt`) |
| `chronicle_no_endpoints_backward` | theorem | Sorry-free (`exists_lt`) |
| `chronicle_discrete_succ` | def | Sorry-free (`Order.succ`) |
| `chronicle_discrete_pred` | def | Sorry-free (`Order.pred`) |

**Builds successfully**: Yes (1583 jobs)

---

### NEquivalence.lean (Phase 3) — 394 lines, 3 sorries
**Status: COMPLETED per plan — claim is MOSTLY ACCURATE**

| Declaration | Type | Status | Line |
|-------------|------|--------|------|
| `MonadicSignature` | structure | Non-vacuous | 38 |
| `MonadicSentence` | inductive | Non-vacuous | 48 |
| `MonadicSentence.quantifier_depth` | def | Complete | 55 |
| `MonadicStructure` | structure | Non-vacuous | 68 |
| `OrderedMonadicStructure` | structure | Non-vacuous (extends MonadicStructure) | 79 |
| `OrderedMonadicStructure.toMonadic` | def | Complete | 91 |
| `OrderedMonadicStructure.subinterval` | def | Non-vacuous (Subtype carrier) | 105 |
| `subinterval_singleton_finite` | theorem | **Sorry-free** (Fintype construction) | 117 |
| `subinterval_two_element_finite` | theorem | **Sorry-free** (by_cases + SuccOrder) | 141 |
| `OrderedSum` | def | Non-vacuous (Sigma carrier, component-wise interp) | 172 |
| `ZStructure` | structure | Non-vacuous (carrier = ℤ) | 185 |
| `ZStructure.toMonadic` | def | Complete | 192 |
| `KType` | def | Non-vacuous (Finset of MonadicSentence) | 210 |
| `ktype_finite` | theorem | **SORRY** (line 229) | 227 |
| `k_type_of` | def | **SORRY** (line 242) | 241 |
| `k_equiv` | def | Non-vacuous (equality of k-types) | 251 |
| `k_equiv_iff_same_type` | theorem | Sorry-free (`rfl`) | 258 |
| `k_equiv_monotone` | theorem | **SORRY** (line 271) | 269 |
| `KEquivalenceFramework` | class | 6 fields (equiv_at, equiv_is_equiv, equiv_monotone, finite_types, sum_preservation, **z_model_exists**) | 290 |
| `chronicleAsMonadicStructure` | def | Non-vacuous | 334 |
| 6 instances (countable, no_max, no_min, succ, pred, nonempty) | instance | All sorry-free | 344-392 |

**Note on `KEquivalenceFramework`**: The plan says 5 fields, but the actual code has 6 — `z_model_exists` was added, which axiomatizes Theorem 15's conclusion directly. This is architecturally problematic: the framework is supposed to axiomatize k-equivalence properties from Doets 1989, but `z_model_exists` axiomatizes the theorem we're trying to prove. This makes the construction potentially circular.

**Builds successfully**: Yes (1584 jobs)

---

### OrderedSum.lean (Phase 4) — 163 lines, 3 sorries
**Status: COMPLETED per plan — claim PARTIALLY ACCURATE**

| Declaration | Type | Status | Line |
|-------------|------|--------|------|
| `doets_lemma_1_4` | theorem | **SORRY** (line 66) | 62 |
| `doets_lemma_1_4_finite` | theorem | Sorry-free (dispatches to `sum_preservation`) | 76 |
| `doets_lemma_1_5` | theorem | **SORRY** (line 113) — documented deferred | 110 |
| `finite_structures_k_equiv_to_Z_interval` | theorem | **SORRY** (line 150) | 146 |
| `finite_structures_k_equiv_for_all_k` | theorem | Sorry-free (wrapper around above) | 158 |

**Plan says**: "`doets_lemma_1_4` is sorry-free (trivial from axiomatized interface)" — **FALSE**. `doets_lemma_1_4` is still sorried. Only `doets_lemma_1_4_finite` (which takes an explicit `KEquivalenceFramework` instance) is sorry-free.

**Plan says**: "`finite_structures_k_equiv_to_Z_interval` is sorry-free (inductive proof)" — **FALSE**. It is fully sorried.

**Builds successfully**: Yes (1585 jobs)

---

### Table.lean (Supporting) — 106 lines, 3 sorries

| Declaration | Type | Status | Line |
|-------------|------|--------|------|
| `Formula.complexity` | def | Complete (structural recursion) | 34 |
| `table` | def | **SORRY** (line 62) | 61 |
| `table_depth_bound` | theorem | **SORRY** (line 74) | 72 |
| `reflCanToMonadic` | def | **VACUOUS** (`interp _ _ := True` at line 87) | 84 |
| `table_correctness` | theorem | **SORRY** + conclusion is `True` (placeholder, line 104) | 100 |

**Note**: `reflCanToMonadic` has a vacuous body — `interp _ _ := True`. The plan claims "No vacuous definitions remain" but this one exists in Table.lean.

**Builds successfully**: Yes (1586 jobs)

---

### IntegerModel.lean (Phase 5) — 293 lines, 9 sorries + 2 BUILD ERRORS
**Status: [COMPLETED] per plan — claim is INACCURATE (does not compile)**

**BUILD ERRORS**:
- Line 49: `Bimodal.Metalogic.WeakCanonical.ZStructure has already been declared`
- Line 66: `Bimodal.Metalogic.WeakCanonical.ZStructure.toMonadic has already been declared`

These duplicate declarations exist because IntegerModel.lean imports OrderedSum (which imports NEquivalence, which already defines `ZStructure` and `ZStructure.toMonadic`). IntegerModel then re-defines them identically.

**Fix required**: Delete lines 42-68 (the duplicate `ZStructure`, `ZStructure.toOrderedMonadic`, and `ZStructure.toMonadic` definitions) from IntegerModel.lean. The NEquivalence definitions will be in scope via the import chain. May also need to add `ZStructure.toOrderedMonadic` to NEquivalence.lean (it's only in IntegerModel currently).

| Declaration | Type | Status | Line |
|-------------|------|--------|------|
| `ZStructure` (DUPLICATE) | structure | **BUILD ERROR** | 49 |
| `ZStructure.toOrderedMonadic` | def | May be unique to this file | 56 |
| `ZStructure.toMonadic` (DUPLICATE) | def | **BUILD ERROR** | 66 |
| `good` | def | Non-vacuous (∃ ZStructure, k_equiv) | 83 |
| `very_good` | def | Non-vacuous (∀ a b, a ≤ b → good subinterval) | 95 |
| `finite_structures_good` | theorem | **SORRY** (line 102) | 99 |
| `contemp_equiv` | def | Non-vacuous (very_good of subinterval) | 117 |
| `contemp_equiv_is_equiv` | theorem | **SORRY** (line 136) | 134 |
| `no_gaps_discrete` | theorem | **SORRY** (line 164) | 157 |
| `no_boundary_at_successor` | theorem | **SORRY** (line 183) | 179 |
| `one_class` | theorem | **SORRY** (line 210) | 206 |
| `very_good_implies_good` | theorem | **SORRY** (line 235) | 232 |
| `chronicle_is_good` | theorem | **SORRY** (line 276) | 273 |
| `canonical_model_is_good` (DEPRECATED) | theorem | **2 SORRIES** (lines 290-291) | 283 |

**Plan verification discrepancies**:
- Plan says "all 5 previously vacuous definitions have non-vacuous bodies" — TRUE for `good`, `very_good`, `contemp_equiv`, but the file doesn't compile, so this can't be verified at build time.
- Plan says "`one_class` is sorry-free (uses only gap-elimination lemmas)" — **FALSE**, it is sorried.
- Plan says "Gap-elimination lemmas are sorry-free" — **FALSE**, both `no_gaps_discrete` and `no_boundary_at_successor` are sorried.
- Plan says "`chronicle_is_good` type-checks with `ChronicleAsPriorModel` input" — cannot verify (build fails).

**Builds successfully**: NO (error code 1)

---

### Transfer.lean (Phase 6) — 113 lines, 0 sorries (directly)
**Status: [PARTIAL] per plan — claim is ACCURATE**

| Declaration | Type | Status | Line |
|-------------|------|--------|------|
| `doets_countermodel_discrete` | theorem | **Sorry-free** but delegates to `dd_countermodel_chronicle_discrete` | 86 |

The Reynolds pipeline (lines 95-102) is entirely commented out. The proof uses the old chronicle fallback with `h_next_top_eq : next_top = Chronicle.next_top := rfl` coercion. This means the theorem transitively inherits the `succ_cofinal` sorry from the chronicle construction.

Phase 6's actual status: The structural wiring exists but is commented out. Until `chronicle_is_good` and the truth transfer machinery are proven, this file correctly falls back to the chronicle path.

**Builds successfully**: NO (depends on IntegerModel which fails)

---

### ReflexiveCanonical.lean — 2 sorries (for reference)

| Declaration | Line | Status |
|-------------|------|--------|
| `reflCanR_linear` | 144 | **SORRY** (confirmed dead code per plan) |
| `canS5R_symm` | 424 | **SORRY** (documented, not needed for discrete completeness) |

---

## Plan vs Reality Discrepancy Table

| Plan Claim | Reality | Severity |
|------------|---------|----------|
| "Phase 7: lake build passes (1644 jobs)" | **BUILD FAILS** — IntegerModel.lean has duplicate ZStructure declarations | CRITICAL |
| "one_class is sorry-free" | SORRY at line 210 | HIGH |
| "Gap-elimination lemmas are sorry-free" | Both `no_gaps_discrete` and `no_boundary_at_successor` are SORRY | HIGH |
| "doets_lemma_1_4 is sorry-free (trivial from axiomatized interface)" | Only `doets_lemma_1_4_finite` is sorry-free; the main `doets_lemma_1_4` is SORRY | MEDIUM |
| "finite_structures_k_equiv_to_Z_interval is sorry-free" | SORRY at line 150 | MEDIUM |
| "No vacuous definitions remain" | `reflCanToMonadic` in Table.lean has `interp _ _ := True` | LOW |
| "KEquivalenceFramework has 5 axiomatized fields" | Has 6 fields (includes `z_model_exists` which axiomatizes Theorem 15's conclusion) | MEDIUM (architectural) |
| "18 sorries in target files (Phases 3-6)" | 18 sorries confirmed, but 2 build errors on top | ACCURATE (count), INACCURATE (build status) |

## Realistic Remaining Work Estimate

### Immediate (to restore compilability): ~30 minutes
1. Delete duplicate `ZStructure` + `ZStructure.toMonadic` from IntegerModel.lean (lines 42-68)
2. Move `ZStructure.toOrderedMonadic` to NEquivalence.lean
3. Verify `lake build` passes

### Critical Path Sorries (to complete Reynolds pipeline): ~20-40 hours
The 18 sorries fall into two tiers:

**Tier 1 — Proofs that could be completed with current infrastructure** (8 sorries):
- `no_boundary_at_successor`: Should follow from `subinterval_two_element_finite` + `finite_structures_good` — but `finite_structures_good` is itself sorry'd
- `contemp_equiv_is_equiv`: Reflexivity and symmetry are straightforward; transitivity needs Lemma 1.4
- `finite_structures_good`: Needs `finite_structures_k_equiv_to_Z_interval` which is sorry'd
- `one_class`: Straightforward from `no_gaps_discrete` + `no_boundary_at_successor` once both are proved
- `chronicle_is_good`: Follows from `one_class` + cofinal sequence + Lemma 1.4

**Tier 2 — Requires monadic FO satisfaction machinery** (7 sorries):
- `ktype_finite`, `k_type_of`, `k_equiv_monotone` (NEquivalence.lean)
- `doets_lemma_1_4`, `doets_lemma_1_5`, `finite_structures_k_equiv_to_Z_interval` (OrderedSum.lean)
- `table`, `table_depth_bound`, `table_correctness` (Table.lean)

**Tier 3 — Could bypass via KEquivalenceFramework** (alternative path):
If `z_model_exists` is kept as an axiom in `KEquivalenceFramework`, then `chronicle_is_good` can be proved by constructing a `KEquivalenceFramework` instance (with `z_model_exists` as an axiom) and dispatching. This would make the pipeline "work" but with the entire Theorem 15 as an axiom — defeating the purpose.

### Architectural Concern: `z_model_exists` in `KEquivalenceFramework`
The `z_model_exists` field in `KEquivalenceFramework` axiomatizes exactly what Theorem 15 is trying to prove. Including it in the framework makes the entire Reynolds pipeline trivially provable by assuming its own conclusion. This should either:
- Be removed from the framework and proved as a theorem using the other 5 fields
- Or be documented as a temporary axiom with a clear plan to prove it

## Confidence Level

**HIGH** — All findings are based on direct source code reading, `grep` for sorry, and actual `lake build` verification. The build failure is reproducible.
