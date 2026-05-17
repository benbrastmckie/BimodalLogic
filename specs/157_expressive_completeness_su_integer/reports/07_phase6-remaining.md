# Phase 6 Remaining Work: Junction-Depth Hierarchy for Axiom Elimination

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Report type**: Research (Phase 6A and 6B pre-implementation audit)
**Date**: 2026-05-17
**Prior reports consulted**: reports/10_ghr94-junction-depth-literature.md, reports/06_team-research.md, handoffs/phase-6-handoff-20260517T200000.md

---

## 1. Current Axiom Inventory

SeparationThm.lean contains exactly **9 axioms** (not 8 as the plan states):

```
Line  90: axiom all_past_separable
Line  94: axiom all_future_separable
Line  98: axiom untl_separable
Line 102: axiom snce_separable
Line 223: axiom all_past_properly_separable
Line 228: axiom all_future_properly_separable
Line 233: axiom untl_properly_separable
Line 239: axiom snce_properly_separable
Line 281: axiom proper_separation_preserves_atoms
```

The first four are temporal closure axioms for `is_separable`. The next four are their duals for `is_properly_separable`. The ninth, `proper_separation_preserves_atoms`, asserts that the atom set does not grow during separation.

DualEliminations.lean has additional sorries but is dead code and outside scope.

**What `multi_U_formula_separable` (Hierarchy.lean line 594-596) currently does:**

```lean
theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi :=
  all_separable phi
```

It calls `all_separable`, which in turn is a one-line structural induction that uses `snce_separable`, `untl_separable`, `all_past_separable`, and `all_future_separable` directly. There is no junction-depth logic anywhere in the call chain. Phase 6 must replace this shortcut with genuine well-founded reasoning.

---

## 2. GHR94 Proof Structure Mapping

### 2.1 Literature Source

**Source**: Gabbay, Hodkinson, Reynolds (1994), *Temporal Logic: Mathematical Foundations and Computational Aspects*, Chapter 10, Section 10.2, Lemmas 10.2.1–10.2.8 and Theorem 10.2.9.

**Proof strategy**: Iterative U/S elimination by junction-depth induction.

### 2.2 Step Map (GHR94 Section 10.2)

| Step | GHR94 Lemma | Description |
|------|-------------|-------------|
| 1 | 10.2.1 | Distributivity: `U(A∨B, C) ↔ U(A,C)∨U(B,C)` etc. Already in `Distributivity.lean`. |
| 2 | 10.2.2 | Negation equivalences for U/S over integers. Already in `NegationEquiv.lean` as `neg_until_equiv`. |
| 3 | 10.2.3 | Eight elimination cases (Cases 1-8). Cases 1-4 proved in Eliminations.lean; Cases 5-8 proved via `all_separable` in NormalForm.lean. |
| 4 | 10.2.4 | If U appears at top level only in S(C,F), then S(C,F) is separable. Currently proved trivially via `all_separable` in SeparationThm.lean. Must be reproved without axioms. |
| 5 | 10.2.5 | Single-U formula separable. In Hierarchy.lean as `single_U_formula_separable`. **Still uses `snce_separable` axiom** in the `snce` case. |
| 6 | 10.2.6 | Multi-U formula separable (no S in U). In Hierarchy.lean as `multi_U_formula_separable`, **currently shortcuts to `all_separable`**. Must be replaced. |
| 7 | 10.2.7 | No S nested in U → separable. Target theorem name: `no_S_nested_in_U_separable`. Does not exist as a proved theorem; only as axiom-backed shortcut. |
| 8 | 10.2.8 | Junction-depth induction: full separation. Does not exist as a proved theorem. |
| 9 | 10.2.9 | Every formula separable. Currently `all_separable` in SeparationThm.lean with axioms. |

### 2.3 The Core Inductive Argument (GHR94 Lemma 10.2.8)

The proof proceeds by strong induction on `junction_depth(D)`:

- **Base case (jd ≤ 1)**: The formula is already syntactically separated. After `expand_temporal` (which replaces `all_past`/`all_future` with `neg(snce ...)` / `neg(untl ...)`), the `expanded_jd_zero_imp_separated` lemma (already proved in TemporalClosure.lean at line 711) handles jd = 0. For jd = 1: every U-subformula has S-free arguments, and every S-subformula has U-free arguments — this is the definition of `is_syntactically_separated`.

- **Inductive step (jd ≥ 2)**: By duality, consider `S(D1, D2)`. The procedure is:
  1. Find maximal U-subformulas `U(Ai, Bi)` in `S(D1, D2)`.
  2. Since jd ≥ 2, some `U(Ai, Bi)` contain S-subformulas `S(Eij, Fij)`.
  3. Replace each `S(Eij, Fij)` by a fresh atom `zij` inside the U-arguments, yielding `U(A'i, B'i)`.
  4. Replace `U(Ai, Bi)` by `U(A'i, B'i)` throughout to get `D'`.
  5. `D'` has no S nested in U (property `no_S_nested_in_U`). Apply Lemma 10.2.7 (inner IH).
  6. The result `E'` is separated. Resubstitute `S(Eij, Fij)` for `zij`.
  7. The resubstituted `E` is equivalent to `D`. Apply the outer IH at lower jd.

  **Why jd decreases**: Each `S(Eij, Fij)` was inside `U(Ai, Bi)` which was inside the outer `S(D1, D2)`. This S-U-S chain contributes 2 to the junction depth, so `junction_depth(S(Eij,Fij)) ≤ jd - 2`.

### 2.4 Lean-Specific Translation Challenges

| GHR94 Step | Lean Challenge |
|------------|---------------|
| "Fresh atom not in formula" | Needs `p ∉ phi.atoms`. The `abstract_untl` function already handles this pattern (Hierarchy.lean line 277). A dual `abstract_snce` needs the same. |
| "Replace S inside U by fresh atom" | No `abstract_snce` exists yet. Must be implemented. |
| "Apply Lemma 10.2.7 to D'" | `no_S_nested_in_U_separable` does not exist as a proved theorem. Must be proved inside the induction. |
| "Resubstitute and apply IH" | Semantic correctness of resubstitution must be verified. Already shown for `abstract_untl` (line 334-396). Analog for S needed. |
| all_past/all_future transparency | GHR94 has no G/H constructors. Our primitive `all_past`/`all_future` nodes are transparent to `junction_depth` (Defs.lean lines 225-228), which is correct. But the IH application must cover these cases explicitly. `expand_temporal` (TemporalClosure.lean line 591) can eliminate them first. |

---

## 3. Existing Infrastructure Inventory

### 3.1 What EXISTS (can be used directly)

**In Defs.lean:**
- `junction_depth`, `junction_depth_U`, `junction_depth_S` (mutually recursive, lines 220-248)
- `count_U_subformulas` (line 265)
- `no_S_nested_in_U` (line 333)
- `is_U_free`, `is_S_free` (lines 109-128)
- `is_syntactically_separated`, `is_separable` (lines 143-156)

**In Hierarchy.lean:**
- `abstract_untl` definition (line 277) — replaces `untl A B` with atom `p`
- `abstract_subst_roundtrip` (line 294) — syntactic roundtrip after abstraction
- `abstract_untl_correct` (line 334) — semantic correctness of `abstract_untl`
- `abstract_untl_equiv` (line 392) — int_equiv form of roundtrip
- `abstract_untl_preserves_S_free` (line 401)
- `abstract_untl_preserves_no_S_nested` (line 429)
- `abstract_untl_makes_U_free` (line 450)
- `abstract_untl_count_le` (line 492)
- `count_U_zero_iff_U_free` (line 473)
- `multi_U_formula_separable` — EXISTS but uses axiom shortcut (line 594)
- `single_U_formula_separable` (line 153) — EXISTS but uses `snce_separable` axiom

**In TemporalClosure.lean:**
- `expand_temporal` (line 591) — eliminates `all_past`/`all_future` from formulas
- `expand_temporal_equiv` (line 632) — semantic equivalence
- `expand_has_no_allpast_allfuture` (line 687)
- `expanded_jd_zero_imp_separated` (line 711) — key base case lemma
- `replace_box_separated_no_S_nested` (line 181)
- `snce_of_boxfree_sep_no_S_nested` (line 330)
- `all_past_of_boxfree_sep_no_S_nested` (line 339)
- `junction_depth_S_zero_imp_U_free` (line 416)
- `junction_depth_U_zero_imp_S_free` (line 431)
- `s_free_junction_depth_zero` (line 446)
- `u_free_junction_depth_zero` (line 480)
- `snce_of_boxfree_sep_jd_le_one` (line 515)

**In Eliminations.lean:**
- `elim_case_1_gen` (line 173) — COMPLETED, drops S-free req on a,q
- `elim_case_2_gen` (line 261) — COMPLETED, drops S-free req on a,q
- `elim_case_3`, `elim_case_4` — proved with full hypotheses
- `since_event_split` (line 553)

### 3.2 What is MISSING (must be implemented for Phase 6A)

| Missing Item | Where to Add | Reason Needed |
|--------------|-------------|---------------|
| `abstract_snce` (definition) | Hierarchy.lean after `abstract_untl` | Replace `snce A B` with atom `p`; dual of `abstract_untl` |
| `abstract_snce_correct` | Hierarchy.lean | Semantic correctness of `abstract_snce` |
| `abstract_snce_preserves_U_free` | Hierarchy.lean | S-free args stay S-free after abstraction |
| `abstract_snce_preserves_no_U_nested` | Hierarchy.lean | Dual of `abstract_untl_preserves_no_S_nested` |
| `abstract_snce_makes_S_free` | Hierarchy.lean | Analogous to `abstract_untl_makes_U_free` |
| `subformula_jd_le` | Hierarchy.lean | `jd(subformula) ≤ jd(formula)` |
| `jd_snce_inside_untl_lt` | Hierarchy.lean | `snce` inside `untl` arg → `jd(snce) < jd(untl)` |

### 3.3 What is MISSING for Phase 6B (main theorem + wiring)

| Missing Item | Where to Add | Reason Needed |
|--------------|-------------|---------------|
| `no_S_nested_in_U_separable_proved` (main theorem) | Hierarchy.lean | Proved version of Lemma 10.2.7; nested `Nat.strongRecOn` |
| Wire `multi_U_formula_separable` to use proved version | Hierarchy.lean line 594-596 | Eliminate axiom dependency |
| Replace 9 axioms with theorems | SeparationThm.lean | The final goal |

---

## 4. The `is_U_free` Purity Assessment

### 4.1 The Issue

`is_U_free` (Defs.lean line 109) currently passes transparently through `all_past` and `all_future`:

```lean
def is_U_free : Formula → Bool
  | .all_future φ => is_U_free φ
  ...
```

GHR94 treats `G(phi) = neg U(neg phi, top)`, so `G(S(p,q))` would NOT be U-free in GHR94 (it contains a hidden U). In our formalization, `all_future (snce p q)` IS U-free, meaning it could appear inside an S-argument and still satisfy `is_syntactically_separated`.

### 4.2 Does It Break the Hierarchy Proof?

The existing infrastructure in TemporalClosure.lean already handles this correctly through `expand_temporal`. The key insight: before applying the junction-depth induction, use `expand_temporal` to replace `all_future phi` with `neg(untl (neg phi) top)` and `all_past phi` with `neg(snce (neg phi) top)`. After expansion:

- No `all_past`/`all_future` constructors remain
- The formula is in the restricted fragment where `junction_depth = 0` truly implies `is_syntactically_separated` (proved at `expanded_jd_zero_imp_separated`)
- `is_U_free` on the expanded formula is correct (no hidden G/H)

**Verdict**: `is_U_free` does NOT need to be changed for the hierarchy proof. The `expand_temporal` pre-processing already handles the G/H problem. Task 6A.4 from the plan is NOT needed.

### 4.3 Does It Break Proper Separation?

For `is_properly_separated`, `all_future` inside S-args is already rejected by `is_future_only` (which `is_properly_separated` uses for snce-args). So `is_properly_separable` is already strict. No change needed there either.

**Conclusion**: The `is_U_free` purity concern is a non-issue for the junction-depth proof strategy. Teammate C's concern is valid for the weak-separation notion, but the `expand_temporal` approach already sidesteps it.

---

## 5. Detailed LOC Estimates for Missing Pieces

### 5.1 Phase 6A: Infrastructure

**Task 6A.1: `abstract_snce` (~120 LOC)**

Pure structural dual of `abstract_untl`. Requires:
- `abstract_snce` definition (8 cases, ~15 LOC)
- `abstract_snce_correct` (semantic correctness, ~30 LOC — same pattern as `abstract_untl_correct` at lines 334-390)
- `abstract_snce_preserves_U_free` (~20 LOC — analog of `abstract_untl_preserves_S_free`)
- `abstract_snce_makes_U_free` for same-type abstraction (~15 LOC)
- `abstract_snce_preserves_no_U_nested` (~20 LOC — analog of `abstract_untl_preserves_no_S_nested`)
- `abstract_snce_count_le` for `count_S_subformulas` or `count_U_subformulas` equivalents (~15 LOC)

Complexity: LOW. The `abstract_untl` proofs are all straightforward structural inductions. All the lemma bodies can be copied with U/S swapped.

**Task 6A.2: `subformula_jd_le` (~60 LOC)**

A property asserting that `junction_depth` of any subformula is at most that of the containing formula. This is needed to confirm the IH application in the main theorem. The definition of `junction_depth` is mutually recursive, so the proof requires a mutual induction or a size argument.

Actually, examining Defs.lean more carefully: `junction_depth` uses `max` at every constructor, so subformulas have ≤ junction depth. A direct structural induction works.

For the specific use case in Lemma 10.2.8, a more targeted lemma suffices:

```lean
theorem snce_arg_jd_le (phi psi : Formula) :
    junction_depth phi ≤ junction_depth (.snce phi psi)
```

This is immediate from the `max` in the definition. Similarly for other constructors. The general "subformula" relation is harder to formalize; the targeted per-constructor lemmas are sufficient and trivial.

Revised estimate: **~20 LOC** (just the targeted per-constructor lemmas, not a general subformula relation).

**Task 6A.3: `jd_snce_inside_untl_lt` (~50 LOC)**

The critical structural fact: if `S(E, F)` appears as an argument of `U(A, B)`, and `U(A, B)` appears as an argument of the outermost formula `D` at junction depth `d`, then `S(E, F)` has junction depth at most `d - 2`.

This is the key well-foundedness argument. Looking at the `junction_depth_U` definition:
```lean
| .snce phi psi => 1 + max (junction_depth phi) (junction_depth psi)
```

When `S(E, F)` appears inside a U-argument (as tracked by `junction_depth_U`), it contributes `1 + jd(S(E,F))` to `junction_depth_U` of the enclosing formula. Since `junction_depth(.untl ...)` = `max junction_depth_U(...)`, and the outer S adds another layer, the bound `jd(S(E,F)) ≤ jd(outer_D) - 2` holds.

The proof needs to be phrased carefully because the relationship between `S(E,F)` being "inside" a U-argument requires the `abstract_snce` abstraction machinery to be applied first. The actual lemma statement in the plan is:

```lean
theorem jd_snce_inside_untl_lt (phi psi : Formula) :
    junction_depth_U (.snce phi psi) = 1 + junction_depth (.snce phi psi)
```

or equivalently for the S node inside U:

```lean
-- After abstracting S-subformulas from inside U-args, junction_depth decreases
theorem abstract_snce_jd_lt (phi A B : Formula) (p : Atom)
    (h_snce : ∃ C D, phi = .snce C D) :
    junction_depth (abstract_snce phi A B p) < junction_depth phi
```

Wait — actually, for the main induction, the cleanest Lean formulation is a direct computation showing that after the S-inside-U replacement, junction depth of the subst formula is strictly less than the original. Looking at how `abstract_untl` works: after abstracting, the atom replaces a node, potentially reducing `junction_depth_U`. A straightforward lemma would be:

```lean
theorem abstract_snce_jd_le (phi A B : Formula) (p : Atom) :
    junction_depth (abstract_snce phi A B p) ≤ junction_depth phi
```

The strict decrease needs a hypothesis that `S(A, B)` actually appears in `phi`. ~50 LOC total for this and related helper lemmas.

### 5.2 Phase 6B: Main Theorem and Wiring

**Task 6B.1 + 6B.2: `no_S_nested_in_U_separable_proved` (~350-500 LOC)**

This is the hardest piece. The proof follows the GHR94 Lemma 10.2.7 argument (induction on U-nesting depth under S), implemented as a well-founded induction. The structure:

```lean
theorem no_S_nested_in_U_separable_proved (phi : Formula)
    (h : no_S_nested_in_U phi) : is_separable phi
```

Proof by induction on `U_depth_under_S phi` (already defined in Defs.lean line 253). This is exactly GHR94's Lemma 10.2.7.

The inner step: given U-depth `n > 0`, find the deepest U-subformulas (their U-depth is 1), replace their nested U-args by atoms, apply the lemma inductively (now U-depth = n-1), resubstitute. This requires the `abstract_untl` roundtrip lemmas already proved.

Wait — this is Lemma 10.2.7 (no S IN U), not Lemma 10.2.8 (junction depth). Let me re-examine. Lemma 10.2.7 takes `no_S_nested_in_U phi` as hypothesis, so it is about formulas where S never appears inside U-args. The induction is on U-nesting depth under S (`U_depth_under_S`).

For the junction-depth hierarchy (Lemma 10.2.8), the induction is on `junction_depth` itself. The implementation in plan v9 uses nested `Nat.strongRecOn`.

One key insight from Report 10 (section 6.2) that simplifies the implementation: once we have `expand_temporal` handling `all_past`/`all_future`, the entire proof reduces to strong induction on `junction_depth`:

```lean
theorem junction_depth_separable_proved (phi : Formula) : is_separable phi := by
  apply expand_temporal_separable  -- reduce to expanded formula
  -- Now prove is_separable (expand_temporal phi) by strong induction on junction_depth
  induction junction_depth (expand_temporal phi) using Nat.strongRecOn with
  | _ d ih =>
    ...
```

Where `expand_temporal_separable` follows from `expand_temporal_equiv` + the IH.

Cases in the induction:
- `atom`, `bot`, `box`: Direct.
- `imp`: Boolean closure.
- `snce phi psi` (after expansion, no `all_past`/`all_future`):
  - jd = 0: `junction_depth_S_zero_imp_U_free` gives U-free args → `is_syntactically_separated` directly.
  - jd = 1: U-args of S-args are S-free → already separated.
  - jd ≥ 2: Find maximal U-subformulas in args. If none have S inside (no S-U-S), done. Else apply `abstract_snce` to extract deepest S, reducing jd by 2, apply IH.
- `untl phi psi`: Dual (find S-in-U, apply `abstract_untl`, reduce jd by 2, apply IH).

The tricky part is the formalization of "find maximal U-subformula" and "replace its S-args". This is exactly what `abstract_snce` provides: for each U-arg of the S, replace nested S-subformulas.

LOC estimate: 350-500 LOC for the full induction, including all case handling.

**Task 6B.3: Wire to Axiom Elimination (~80 LOC)**

- `multi_U_formula_separable`: Change line 596 from `all_separable phi` to `junction_depth_separable_proved phi` (~5 LOC change)
- `single_U_formula_separable`: Change the `snce` case to use `junction_depth_separable_proved` instead of `snce_separable` axiom (~5 LOC change)
- SeparationThm.lean: Replace 9 `axiom` declarations with `theorem` proofs. Each proof routes through the hierarchy. (~80-100 LOC total including docstrings)

---

## 6. Recommended Implementation Order

### Phase 6A (2-3 hours, ~260 LOC total)

1. `abstract_snce` definition and all its preservation lemmas (~120 LOC)
   - This is pure copy-with-swap from `abstract_untl`
   - Verify with `lake build` after each definition/lemma group

2. Per-constructor junction-depth monotonicity lemmas (~20 LOC)
   - `snce_jd_le_arg`, `untl_jd_le_arg`, etc.
   - Trivial proofs via `Nat.le_max_left`, `Nat.le_max_right`

3. `jd_snce_inside_untl_lt` and related decrease lemmas (~50 LOC)
   - Critical for well-foundedness in the main induction
   - Key lemma: replacing a snce-node inside untl-arg with an atom reduces `junction_depth_U`

4. **Skip Task 6A.4** (`is_U_free` fix) — not needed per Section 4 analysis above.

### Phase 6B (4-5 hours, ~500 LOC total)

5. `no_S_nested_in_U_separable_proved` (Lemma 10.2.7 analog, ~200 LOC)
   - Induction on `U_depth_under_S`
   - Uses existing `abstract_untl` machinery
   - Must NOT call any axiom from SeparationThm.lean

6. `junction_depth_separable_proved` (Lemma 10.2.8 analog, ~200 LOC)
   - Strong induction on `junction_depth (expand_temporal phi)`
   - Uses `no_S_nested_in_U_separable_proved` for the simplified case
   - Handles the `abstract_snce` reduction for the inductive step

7. Wire `multi_U_formula_separable` → `junction_depth_separable_proved` (~5 LOC change)

8. Derive all 9 axioms as theorems in SeparationThm.lean (~80 LOC)
   - The 4 `is_separable` axioms each reduce to `junction_depth_separable_proved phi`
   - The 4 `is_properly_separable` axioms require bridging from weak to strong separation
   - `proper_separation_preserves_atoms` requires showing the hierarchy doesn't introduce fresh atoms (provable from `abstract_untl`/`abstract_snce` using `abstract_subst_roundtrip`)

---

## 7. Key Structural Observations

### 7.1 The Main Theorem Statement

The plan's recommended target is `no_S_nested_in_U_separable_proved` as a stepping stone. However, based on Report 10's analysis, a cleaner path is the unified:

```lean
theorem junction_depth_separable_proved : ∀ phi, is_separable phi
```

proved by `Nat.strongRecOn` on `junction_depth (expand_temporal phi)`. This single theorem eliminates ALL temporal closure axioms directly. The `no_S_nested_in_U_separable_proved` can be derived as a corollary.

### 7.2 The Nested Recursion Problem

The plan v9 proposes nested `Nat.strongRecOn` on `(junction_depth, count_U)`. This is NOT needed and overcomplicates the proof. Report 10's analysis shows that strong induction on `junction_depth` alone is sufficient because:

1. GHR94 Lemma 10.2.7 (no S in U) can be proved by induction on `U_depth_under_S` (a completely different measure from `junction_depth`).
2. GHR94 Lemma 10.2.8 calls 10.2.7 as a subroutine — no nesting of the same induction.
3. The outer junction-depth induction never needs an inner count_U induction.

**Recommendation**: Use single-layer strong induction on `junction_depth (expand_temporal phi)` for the main theorem, and a separate induction on `U_depth_under_S` for the subroutine lemma. This avoids the complexity of lexicographic product orders in Lean.

### 7.3 The Proper Separation Bridge

Converting from `is_separable` to `is_properly_separable` (needed for axioms 5-9) requires:

```lean
theorem separable_implies_properly_separable (phi : Formula) :
    is_separable phi → is_properly_separable phi
```

This is provable via: take the separated witness `psi` (from `is_separable`), observe that its `all_past`/`all_future` nodes use U-free/S-free arguments (by `is_syntactically_separated`), then `is_future_only` and `is_past_only` hold for those arguments because U-free implies no future-temporal-operators, and S-free implies no past-temporal-operators — EXCEPT when `all_future`/`all_past` appear inside S/U arguments.

This is actually the residual purity problem. The cleanest resolution: prove `junction_depth_separable_proved` using `is_properly_separated` as the target from the start, not `is_syntactically_separated`. This avoids the bridge entirely.

However, the existing Cases 1-8 in Eliminations.lean produce `is_syntactically_separated` outputs, not `is_properly_separated`. The bridge would need to be applied to those outputs.

**Alternative**: Accept that `is_properly_separable` axioms are harder to eliminate than the `is_separable` axioms, and phase the work: eliminate the 4 `is_separable` axioms first (higher priority), then the 5 `is_properly_separable` + atoms axioms.

---

## 8. Summary Table

| Piece | Status | LOC | Priority |
|-------|--------|-----|----------|
| `abstract_snce` + lemmas | MISSING | ~120 | HIGH — blocks 6B |
| `subformula_jd_le` (targeted) | MISSING | ~20 | MEDIUM — needed for IH |
| `jd_snce_inside_untl_lt` | MISSING | ~50 | HIGH — well-foundedness |
| `is_U_free` fix | NOT NEEDED | 0 | N/A |
| `no_S_nested_in_U_separable_proved` (Lemma 10.2.7) | MISSING | ~200 | HIGH |
| `junction_depth_separable_proved` (Lemma 10.2.8) | MISSING | ~200 | HIGH |
| Wire `multi_U_formula_separable` | MISSING | ~5 | LOW (mechanical) |
| Derive `is_separable` axioms as theorems | MISSING | ~40 | HIGH |
| Derive `is_properly_separable` axioms as theorems | MISSING | ~80 | MEDIUM |
| `proper_separation_preserves_atoms` as theorem | MISSING | ~30 | MEDIUM |
| **TOTAL Phase 6A+6B** | | **~745 LOC** | |

The plan v9's LOC budget of 500-700 LOC for the hierarchy is approximately correct, though actual implementation tends to run 20-30% higher.

---

## 9. Build Status Caveat

The current build has ~10 errors in `ExpressiveCompleteness.lean` (from the Phase 7 work in the latest handoff). These are in the `expressiveness_inner` function and involve `String.append_left_cancel` and type mismatches — they predate Phase 6 and do not affect the Separation/ stack. Phase 6 can proceed independently on the `Separation/` files while Phase 7 remains in PARTIAL state.

The command `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` should be used to verify Phase 6 work in isolation.
