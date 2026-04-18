# Phase 2 Validation Results: Derived Rules and Key Lemmas

- **Task**: 93 - Complete BXCanonical embedding
- **Phase**: 2 (Validate Derived Rules and Key Lemmas)
- **Date**: 2026-04-18
- **Plan**: plans/40_bxcanonical-embedding.md Phase 2

## Summary

All 6 validation items PASS. The mathematical preconditions for the qm_bfmcs approach are confirmed. No blocking obstacles found.

---

## Item 1: Validate `bx_le` gives h_content backward

**Result**: PASS

**Evidence**:

`bx_le w v` is defined as `g_content(w.formulas) ⊆ v.formulas` (Frame.lean:61-62).

The theorem `g_content_subset_implies_h_content_reverse` in `WitnessSeed.lean:511-537` states:
```
theorem g_content_subset_implies_h_content_reverse
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_GC : g_content M ⊆ M') :
    h_content M' ⊆ M
```

Setting `M = w.formulas` and `M' = v.formulas` with `h_GC = h_le : bx_le w v`, we get:
`h_content(v.formulas) ⊆ w.formulas`.

This is exactly the H-backward clause needed by `hintikka_step`: if `bx_le w v` (w steps to v), then `H(χ) ∈ v → χ ∈ w`. The theorem is already used in Frame.lean at line 269 in `bx_H_forward`:

```lean
theorem bx_H_forward {w v : BXPoint} {φ : Formula}
    (h_le : bx_le v w) (h_H : Formula.all_past φ ∈ w.formulas) :
    φ ∈ v.formulas :=
  g_content_subset_implies_h_content_reverse v.formulas w.formulas
    v.is_mcs w.is_mcs h_le h_H
```

**Implication for Phase 3**: The `hintikka_step` H-backward clause is satisfiable by the bx_le-related BXPoints. No forward-only variant needed. The oracle can use both G-propagation (g_content forward) and H-backward (h_content backward) from the same `bx_le` relation.

---

## Item 2: Validate Until introduction rule is NOT needed

**Result**: PASS

**Evidence**:

The semantically invalid rule `φ ∧ F(φ U ψ) → φ U ψ` was the blocker in plan v39 Phase 1. This rule is NOT required by the qm_bfmcs approach.

In the quasimodel approach, `restricted_buc` (backward Until coherence) holds by the constructive chain property of the oracle:

1. The `HintikkaStepOracle` (Construction.lean:477-483) guarantees that at each chain step where `φ U ψ ∈ h` and `ψ ∉ h`, the oracle produces h' with `hintikka_step h h'` and either `ψ ∈ h'` or `φ U ψ ∈ h' ∧ defect_count h' < defect_count h`.

2. The `hintikka_chain_guard_step` lemma (Construction.lean:842-848) derives `φ ∈ h` from `hintikka_step h h'` and `φ U ψ ∈ h` and `ψ ∉ h` -- purely from the `hintikka_step` Until-propagation clause: `(h_step.2.2 φ ψ h_target h_not).1`.

3. The backward direction `restricted_buc` will follow by induction on chain length: at the base case `ψ ∈ mcs(t)` gives `φ U ψ ∈ mcs(t)` via `refl_intro_until_mcs` (Construction.lean:157-162). For the step case, the oracle's defect-propagation gives `φ U ψ ∈ mcs(t+1)` directly, and combined with `φ ∈ mcs(t)` (from hintikka_chain_guard_step), we derive `φ U ψ ∈ mcs(t)` by BX7 (the actual valid Step Until axiom: `φ ∧ (φ U ψ)_future → φ U ψ`), not the invalid introduction rule.

The valid approach uses only: BX8 (reflexivity), BX7 (step rule), and the oracle's constructive guard property.

---

## Item 3: Pencil-proof of `until_defects_seed_consistent`

**Result**: PASS

**Mathematical argument**:

Let M be a BXPoint (MCS). Define:
- `g_content(M)` = `{φ | G(φ) ∈ M.formulas}`
- Until-defects of M = `{φ U ψ | φ U ψ ∈ M.formulas ∧ ψ ∉ M.formulas}`
- Oracle seed = `g_content(M) ∪ {Until-defects of M}`

**Claim**: The oracle seed is a subset of `M.formulas`.

**Proof**:
- `g_content(M) ⊆ M.formulas`: For any `φ ∈ g_content(M)`, we have `G(φ) ∈ M.formulas`. By axiom BX1 (temp_t_future: `G(φ) → φ`), `φ ∈ M.formulas`. This is exactly `bx_le_refl` (Frame.lean:140-146).
- Until-defects `⊆ M.formulas`: If `φ U ψ ∈ M.formulas`, then `φ U ψ ∈ M.formulas` by hypothesis. The defect set consists of Until-formulas *from* M.formulas, so they are all in M.formulas by definition.

**Corollary**: Any finite `L ⊆ oracle_seed` is a finite subset of `M.formulas`. Since M is an MCS (hence consistent), `L` cannot derive `⊥`. So the seed is consistent.

This argument is a one-line proof via `SetMaximalConsistent.1` (consistency) applied to the witness `M`. The formal proof mirrors `chain_step_seed_consistent` (Construction.lean:676-690) but with the explicit subset demonstrated above.

**Formal witness**: The subset proof follows the same pattern as `g_content_set_consistent` (Frame.lean:122-133) which already proves `SetConsistent (g_content S)` for any MCS S, using the same BX1 reflexivity argument.

---

## Item 4: Validate vacuous interval guard

**Result**: PASS

**Evidence from `lean_run_code` test**:

```lean
-- Test strict open interval: t < r < t + 1 has no integer solutions
example (t r : Int) (h1 : t < r) (h2 : r < t + 1) : False := by
  omega  -- SUCCEEDS

-- Test: the only integer in [t, t+1) is r = t
example (t r : Int) (h1 : t ≤ r) (h2 : r < t + 1) : r = t := by
  omega  -- SUCCEEDS
```

Both tests pass. `omega` confirms:
- The half-open interval `[t, t+1)` contains exactly `r = t` for integers.
- The open interval `(t, t+1)` contains no integers.

**Application to `restricted_fuc`**: The guard condition for `restricted_fuc` is:
```
∀ r : Int, t ≤ r → r < s → φ ∈ mcs(r)
```
When `s = t + 1` (the immediate next step in the oracle), this reduces to `φ ∈ mcs(t)` only (since `r = t` is the only integer in `[t, t+1)`). This single obligation is discharged by `hintikka_chain_guard_step` which gives `φ ∈ h` at any chain point carrying `φ U ψ` with `ψ ∉ h`.

When `s = t + k` for `k > 1`, each intermediate step is handled by the oracle's chain structure with the guard propagated at each oracle step.

---

## Item 5: Validate `SubformulaClosure_untl_closed`

**Result**: PASS

**Evidence**:

The theorem exists and is proved in `Realization.lean:586-595`:

```lean
/-- If `(φ U ψ) ∈ SubformulaClosure target`, then `φ, ψ ∈ SubformulaClosure target`. -/
theorem SubformulaClosure_untl_closed {target φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ SubformulaClosure target) :
    φ ∈ SubformulaClosure target ∧ ψ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, _, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, _, hfeq⟩ | ⟨f, _, hfeq⟩
    · obtain ⟨l, r⟩ := subformulas_untl_unwrap h_sub
      exact ⟨subformula_mem l, subformula_mem r⟩
    · cases hfeq -- (φ U ψ) = G(f) impossible
    · cases hfeq -- (φ U ψ) = H(f) impossible
  · simp [Formula.neg] at hg_eq -- (φ U ψ) = neg(g) impossible
```

This theorem is sorry-free and confirmed working. It proves both `φ ∈ SubformulaClosure target` and `ψ ∈ SubformulaClosure target` when `φ U ψ ∈ SubformulaClosure target`.

**Key for the oracle**: When the oracle steps and needs to ensure `ψ` (the Until-right-side) is within the Sigma-closure for the next Hintikka point, `SubformulaClosure_untl_closed` guarantees that `ψ ∈ SubformulaClosure(root)`. Combined with the negation pairing property of `SubformulaClosure`, every oracle step stays within the finite Sigma-closure.

---

## Item 6: Design Decision - qm_bfmcs Integration Strategy

**Result**: RECOMMENDATION CONFIRMED

**Decision**: Replace `dd_bfmcs` definition in place (do NOT create a separate `qm_bfmcs` type).

**Rationale**:

1. **`dd_countermodel` wiring is correct**: The existing `dd_countermodel` function in `RootScopedChain.lean` wires `dd_bfmcs` into `bx_completeness`. Replacing the `dd_bfmcs` internals (how the chain is constructed) while keeping the same type name avoids touching `dd_countermodel` or `bx_completeness`.

2. **Type compatibility**: The `dd_bfmcs` type (or its BFMCS interface) is what `dd_countermodel` expects. If we introduce a separate `qm_bfmcs` type with the same BFMCS interface, we need to update `dd_countermodel` to use it. This is unnecessary churn.

3. **The three sorry sites** (`dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`) are the exact holes that need filling. Modifying `dd_bfmcs`'s internal chain construction from `dd_chain` to the oracle-based chain addresses all three simultaneously.

4. **Alternative**: If the `dd_chain` definition is tightly coupled to the sorry targets (i.e., if changing the chain construction requires significant surgery around the sorry sites), introducing `qm_bfmcs` as a separate replacement is acceptable -- but only create it if in-place modification becomes too invasive. The plan specifies "modify `dd_bfmcs` in place" as the primary path.

**Action for Phase 4**: Replace the `dd_chain` construction inside `dd_bfmcs` with the oracle-based chain from Phase 3. Keep `dd_bfmcs`, `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc` as the target names.

---

## Overall Assessment

All 6 validation items PASS. Phase 2 is complete. The implementation path is clear:

| Item | Status | Implication |
|------|--------|-------------|
| bx_le gives h_content backward | PASS | Full hintikka_step (both G-forward and H-backward) is valid |
| Until introduction NOT needed | PASS | Use BX8+BX7+oracle guard instead |
| until_defects_seed_consistent | PASS | Oracle seed construction is sound |
| Vacuous interval guard | PASS | `omega` closes restricted_fuc base case |
| SubformulaClosure_untl_closed | PASS | Sorry-free; oracle always reaches witnesses |
| qm_bfmcs integration strategy | DECIDED | Modify dd_bfmcs in place, reuse dd_countermodel |

**Next**: Phase 3 -- Build `qm_oracle_step` and prove seed consistency (plan section Phase 3).
