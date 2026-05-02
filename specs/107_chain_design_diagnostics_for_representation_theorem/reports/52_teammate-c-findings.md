# Teammate C: Cruft Audit and Code Quality Assessment
## Task 107 — Burgess Chronicle Construction

**Date**: 2026-05-02
**Auditor**: Teammate C (Critic)
**Session**: sess_1777758350_184c2f

---

## Key Findings

1. **PointInsertion.lean is massively oversized** at 2189 lines, containing dense proof commentary, extended design discussions in inline comments, and significant sections of exploratory reasoning that belong in reports rather than source code.

2. **5 active sorry sites** in PointInsertion.lean (lines 1573, 1581, 1584, 1614, 2050), of which 4 are in `burgess_D0_finite_subset_consistent` and 1 is in `lemma_2_7_seed_consistent`. These are all on the critical path.

3. **`collect_guards_mem_of_B` is defined but never called** outside its own recursive proof body. It was apparently written to support the sorry at line 1573 but was never wired in.

4. **`and_left_impl`/`and_right_impl` are trivial wrappers** (private defs) around `lce_imp`/`rce_imp` that add no value.

5. **`until_implies_F_mcs` duplicates `until_F_mcs`** — they have the same statement. `until_implies_F_mcs` is a private alias introduced redundantly.

6. **Previous agent's changes were structurally sound** but introduced an asymmetry: `iterated_enrichment` was refactored to return `EnrichedEvent` struct (improvement), but `burgess_zeta_consistent` was changed from `∃` to `Σ` return type. This is correct since `DerivationTree` fields are in `Type`, but the comment explaining this was added inline rather than in a docstring.

7. **Long inline design commentary** throughout `burgess_D0_seed_consistent` (lines 1633–1860) constitutes about 250 lines of exploratory reasoning that should be in a report, not source code.

---

## Dead Code Inventory

| File | Line | Name | Reason Dead |
|------|------|------|-------------|
| PointInsertion.lean | 1047–1049 | `and_left_impl` | Trivial wrapper around `lce_imp`. Only used at lines 1744, 1748, 1752 where `lce_imp` could be called directly. |
| PointInsertion.lean | 1052–1054 | `and_right_impl` | Trivial wrapper around `rce_imp`. Only used at lines 1744, 1748. |
| PointInsertion.lean | 1000–1004 | `until_implies_F_mcs` | Private alias for the already-defined public `until_F_mcs`. Both have identical statements. The alias only exists to give a shorter local name. |
| PointInsertion.lean | 1432–1444 | `collect_guards_mem_of_B` | Defined but never called in any proof. Was intended to support the sorry at line 1573 but was never connected. |
| ChronicleConstruction.lean | ~941 | `limit_c2'_vacuous`, `limit_g_is_mcs_vacuous` | Deleted (comment at line 941 says "deleted"). No code present but the comment is a stale reference. |

**Note**: No commented-out code blocks were found. Previous agents correctly left removal notices as inline comments rather than dead Lean syntax, which is good practice.

---

## Consistency Issues

### Naming Conventions

The file uses both `_mcs` suffix style (e.g., `conj_mcs`, `until_F_mcs`) and inline description style (e.g., `G_implies_F_mcs`, `H_implies_P_mcs`). This is minor and deliberate — `_mcs` suffix is used when the theorem is a direct MCS-level lift of an axiom.

More problematic: `until_F_mcs` (public, line 179) and `until_implies_F_mcs` (private alias, line 1000) are identical in statement but different names. The private alias is confusing.

### Multiple Seed-Like Structures

There are two seed-construction patterns in the same file:
- `burgess_D0_seed` (line 880): The Lemma 2.6 seed
- `lemma_2_7_seed` (line 2024): The Lemma 2.7 seed

These are structurally very similar (both are `B ∪ {formula} ∪ Until-formulas ∪ Since-formulas`), and `lemma_2_7_seed` has an additional component. The proof strategies for their consistency should also be similar, but the consistency proof for `lemma_2_7_seed` is entirely sorry'd at line 2050.

No duplicate definitions of the same concept. The `BurgessR3Maximal` vs `R3Maximal` distinction is intentional and clearly documented.

### Unused Imports

`PointInsertion.lean` imports `RRelation.lean` which imports `TemporalDerived.lean`. The PointInsertion file opens `Bimodal.Theorems.TemporalDerived` but does not import it directly — this comes through transitively. This is acceptable.

### BX Chain Lemmas (lines ~966–1100)

The BX helper lemmas at lines ~916–1201 have consistent naming and structure: all are `private theorem X_mcs` or `private noncomputable def X_deriv`. Naming is consistent. Documentation comments are present and accurate.

---

## File Structure Assessment

### PointInsertion.lean (2189 lines) — TOO LARGE

The file should be split. Current logical sections:

| Lines | Content |
|-------|---------|
| 1–68 | Module doc (accurate and valuable) |
| 69–134 | G/H negation helpers (`F_neg_of_G_not`, `P_neg_of_H_not`) |
| 135–218 | Lemma 2.4 and BX MCS-level tools |
| 219–242 | Lemma 2.5 |
| 243–498 | Lemma 2.6 basic + R3Maximal properties + DCS helpers |
| 499–815 | BurgessR3Maximal helpers (consistency, ex-falso, duality) |
| 816–970 | Lemma 2.6 Splitting infrastructure |
| 971–1201 | Lemma 2.7 BX chain helpers (15 private defs/theorems) |
| 1202–1590 | `burgess_D0_finite_subset_consistent` (consistent case, WITH 3 sorry sites) |
| 1591–1957 | `burgess_D0_seed_consistent` (the massive orchestrator with inline design commentary) |
| 1959–2015 | `lemma_2_6_splitting` (the actual public theorem, now sorry-free!) |
| 2016–2189 | `lemma_2_7` with sorry'd seed consistency |

**Split recommendation**: Lines 971–1201 (the private BX chain helpers) could be extracted to a `PointInsertionHelpers.lean` file, reducing the main file by ~230 lines. However, since these are all `private`, this would require making them `internal` or moving the consumers too. **Priority: low** — the split doesn't unblock any sorry sites.

### Other Files

| File | Lines | Sorry Count | Notes |
|------|-------|-------------|-------|
| ChronicleTypes.lean | 656 | 0 | Clean. Well-organized. |
| RRelation.lean | 1534 | 0 | Clean. No sorries. |
| CounterexampleElimination.lean | 934 | 2 | Lines 412, 510: both marked "Phase 8" blockers needing c2' |
| ChronicleConstruction.lean | 1248 | 0 | Clean. No sorries. |
| ChronicleToCountermodel.lean | 667 | 2 | Lines 615, 619: forward Until/Since guard coherence |

---

## Refactoring Recommendations

### High Priority (unblocks sorry sites)

1. **Fix sorry at line 1573** (`φ ∈ B` case in `h_event_implies_L`):
   The plan is clearly laid out in the comment (lines 1558–1572). `collect_guards_mem_of_B` exists and proves the needed lemma. The proof needs:
   - Call `collect_guards_mem_of_B h_B_dcs β L hL φ hφ h_B` to get `φ ∈ (collect_guards ...).val`
   - Show `φ ∈ b_list` (since `b_list = β₀ :: b_list_raw` and `φ ∈ b_list_raw` from above)
   - Use `list_conj_implies_elem b_list φ h_φ_b_list` to get `⊢ b → φ`
   - Chain: `event → b → φ` using `h_ev_b`

2. **Fix sorry at line 1581** (`untl(β', γ')` case):
   The plan says "via left_mono (⊢ b → β') and right_mono (⊢ γ_hat → γ')".
   - `b → β'`: `list_conj_implies_elem b_list β'` where `β' ∈ b_list` because the guard for `untl(β', γ')` is `β'` (by `d0_guard` definition), and `β' ∈ b_list_raw` (similar to case 1)
   - `γ_hat → γ'`: `list_conj_implies_elem c_list γ'` where `γ'` is in `c_list_raw` (by `d0_c_event_list` construction)
   - Chain: `event → untl(b, γ_hat) → untl(β', γ_hat) → untl(β', γ')` via `untl_left_mono_deriv` + `right_mono_until_mcs`

3. **Fix sorry at line 1584** (`snce(β', α')` case):
   Similar to line 1581. `event → snce(b, α') → snce(β', α')` via `snce_left_mono_deriv` with `⊢ b → β'`.

4. **Fix sorry at line 1614** (`burgess_D0_finite_subset_consistent_incons`):
   This is the "β.neg ∈ B" sub-case. When `β.neg ∈ B`, `D₀ = B ∪ untl-formulas ∪ snce-formulas`. The comment at lines 1953–1956 correctly identifies the fix: the inconsistent case doesn't need the BX14 separation step. Instead, use the simpler argument:
   - Take any `β₀ ∈ B` (e.g., `⊤ ∈ B`), `γ₀ ∈ C` (from seriality or burgessR3)
   - `untl(β.neg, γ₀) ∈ A` from burgessR3 (since `β.neg ∈ B`)
   - BX5: `untl(β.neg ∧ untl(β.neg, γ₀), γ₀) ∈ A`
   - The Burgess compression then works without BX14 (no need for the maximality witnesses)
   - This is just `burgess_D0_finite_subset_consistent` with `β₀ = β.neg`, `γ₀ = any C element`

5. **Fix sorry at line 2050** (`lemma_2_7_seed_consistent`):
   The comment (lines 2029–2040) gives the plan: BX5+BX14+BX13+BX10 chain. This is structurally identical to `burgess_D0_finite_subset_consistent` but for a different seed. Once the sorry sites 1573–1584 are fixed, the same machinery (`burgess_zeta_consistent` + `collect_guards` pattern) should apply here. The key difference is that `lemma_2_7_seed` includes `snce(β∧eta, α)` formulas which need a modified guard handling.

### Medium Priority (code quality)

6. **Remove `until_implies_F_mcs`** (line 1000) and replace its 2 call sites with `until_F_mcs`. Net savings: 5 lines.

7. **Remove `and_left_impl`/`and_right_impl`** (lines 1047–1054) and replace the 4 call sites with direct `lce_imp`/`rce_imp`. Net savings: 8 lines.

8. **Clean up inline design commentary** in `burgess_D0_seed_consistent` (lines 1633–1900 is roughly 80% comment). These reflective notes (e.g., "Hmm, this doesn't work directly", "OK, the fundamental insight") belong in task reports, not source code. Reducing to concise proof comments would save ~180 lines and make the file significantly more readable.

### Low Priority (structure)

9. No import cycle issues. All imports are clean and directed.
10. Naming convention for BX lemmas is consistent; no action needed.

---

## Previous Agent Changes Assessment

The last agent's changes (visible in `git diff HEAD~1 -- Theories/`) performed:

1. **Docstring relocation**: Moved the docstring for `burgess_D0_finite_subset_consistent` (consistent case) from before the private helper defs to after them. This is cosmetically neutral.

2. **`iterated_enrichment` return type refactor**: Changed from `{ event' : Formula // ... }` (Subtype) to `EnrichedEvent A guard event alphas` (named structure). This is a **genuine improvement** — it makes field access readable (`evt.h_untl`, `evt.h_impl`, `evt.h_snce`) vs the destructuring syntax required for subtypes.

3. **`burgess_zeta_consistent` return type change**: Changed from `∃ event : Formula, ... ∧ ...` to `Σ event : Formula, ... × ...`. This is **correct** — `DerivationTree` fields live in `Type`, not `Prop`, so `∃` (which lives in `Prop`) cannot be used to extract computation. The `Σ` (Sigma type in `Type`) is appropriate here. The comment "Use Sigma type since fields are Type-valued" accurately documents this.

4. **Call site updates**: Updated all callers of `iterated_enrichment` and `burgess_zeta_consistent` consistently. No call sites were missed.

**Assessment**: The previous agent's changes are correct and improve code quality. The `Σ/×` pattern in `burgess_zeta_consistent` is the right approach and correctly documented. The `EnrichedEvent` struct is a clean improvement. No problems introduced.

**One concern**: The `iterated_enrichment` base case uses `EnrichedEvent.mk event h_untl (identity event) (...)`. The `identity` combinator here is `⊢ event → event` which is correct, but this is calling `identity` from `Bimodal.Theorems.Combinators`. This should work but is worth verifying compiles cleanly.

---

## Risk Assessment

### What could go wrong in the final push

**Risk 1 (HIGH)**: The 3 sorry sites in `burgess_D0_finite_subset_consistent` (lines 1573, 1581, 1584) all require connecting `collect_guards` output to `b_list`. The connection requires reasoning about `d0_guard`'s classical choice behavior. Since `d0_guard` uses `by_cases` with classical decidability, the proof that `φ ∈ collect_guards output` when `φ ∈ B` requires unfolding the classical choice through `d0_guard`. This might require `simp [d0_guard, h_B]` or explicit unfolding. The `collect_guards_mem_of_B` theorem was written precisely for this, but its body itself uses `simp [collect_guards]` and `unfold d0_guard; simp [h_B]`. This should work but is the trickiest part.

**Risk 2 (MEDIUM)**: `burgess_D0_finite_subset_consistent_incons` (line 1614) needs to avoid the BX14 step. The comment correctly identifies that `β.neg ∈ B` simplifies things, but the proof still needs an event formula with `F(event) ∈ A`. The simplest path: use `untl(β.neg, γ₀) ∈ A` (from burgessR3 since `β.neg ∈ B`) → BX5 → BX10 to get `F(γ₀) ∈ A`... but we need `F(β.neg) ∈ A`, not `F(γ₀)`. Looking more carefully: in this case the entire seed consistency reduces to showing `burgess_D0_seed A B C β ⊆ known_consistent_set`. Since `β.neg ∈ B`, `{β.neg} ∪ B = B`, and D₀ = B ∪ untl-formulas ∪ snce-formulas. The untl-formulas are in A (by burgessR3), the snce-formulas are in C (by burgessR3). This is the exact structure that the `consistent_case` proof with `β₀ = β.neg` handles. The simplest fix may be to just reuse `burgess_D0_finite_subset_consistent` directly with appropriate witnesses.

**Risk 3 (MEDIUM)**: `lemma_2_7_seed_consistent` (line 2050) is sorry'd in its entirety. The seed is more complex than `burgess_D0_seed` (it has the extra `snce(β∧eta, α)` component). The BX5+BX14+BX13+BX10 chain for this seed requires that `eta ∉ B` be exploited via the BurgessR3Maximal maximality argument — but `eta` plays a different role than `β` in Lemma 2.6. The sorry comment says the proof strategy is the same, but the extra `snce(β∧eta, α)` component needs guard handling. This is new territory.

**Risk 4 (LOW)**: The 2 sorries in `CounterexampleElimination.lean` (lines 412, 510) are marked "Phase 8" and flagged as requiring c2' which was removed from the omega_chain invariant. These affect `eliminate_C4_counterexample` and `eliminate_C4'_counterexample` in the "hard case" (γ ∈ f(x) and γ ∈ f(y) simultaneously). However, looking at `ChronicleConstruction.lean`, these functions ARE called via `eliminate_potential_counterexample`. If the hard case is sorry'd, the C4/C4' conditions may not hold at the limit. This requires further analysis of whether C4/C4' are needed for the final `chronicle_model_exists` theorem.

**Risk 5 (LOW)**: The 2 sorries in `ChronicleToCountermodel.lean` (lines 615, 619) affect guard coherence for Until/Since. These are the final blockers for the completeness theorem and are well-understood (they need C3 + limit_g for intermediate guard points).

### Sorry Dependency Chain

```
dd_countermodel_chronicle (ChronicleToCountermodel.lean, line 640)
  └─ cantor_bfmcs_restricted_fuc (lines 615, 619) [2 sorries]
       └─ Requires: limit_satisfies_c5_full (C3 + guard at intermediate points)

eliminate_C4_counterexample (CounterexampleElimination.lean, line 412) [1 sorry]
eliminate_C4'_counterexample (line 510) [1 sorry]
  └─ Called by: eliminate_potential_counterexample (line 727)
       └─ Called by: omega_chain (ChronicleConstruction.lean)
            └─ Called by: chronicle_model_exists

lemma_2_6_splitting (PointInsertion.lean, line 1966) [0 sorries - COMPLETE]
  └─ Depends on: burgess_D0_seed_consistent (lines 1623-1957)
       └─ Depends on: burgess_D0_finite_subset_consistent (3 sorries: 1573, 1581, 1584)
       └─ Depends on: burgess_D0_finite_subset_consistent_incons (1 sorry: 1614)

lemma_2_7 (line 2052) [depends on lemma_2_7_seed_consistent, 1 sorry: 2050]
  └─ NOT YET CALLED by any downstream code (no callers found in ChronicleConstruction)
```

**Important discovery**: `lemma_2_6_splitting` and `lemma_2_7` have NO callers yet in `ChronicleConstruction.lean` or `CounterexampleElimination.lean`. These theorems are proved (or partially proved) in PointInsertion.lean but are not yet wired into the construction. The immediate sorries in `CounterexampleElimination.lean` (the "hard cases" in C4/C4' elimination) are where these lemmas need to be applied.

---

## Confidence Level

**High confidence** in:
- The sorry count and locations (verified by direct grep)
- The dead code identification (verified by searching all call sites)
- The previous agent change assessment (verified by reading diff)
- The sorry dependency chain (verified by tracing callers)

**Medium confidence** in:
- The proof strategy for sorry at line 1573 (the `collect_guards_mem_of_B` connection seems right but classical choice reasoning in Lean 4 can be finicky)
- Whether the inconsistent case at 1614 can reuse the consistent case machinery directly

**Low confidence** in:
- Whether `lemma_2_7_seed_consistent` proof strategy will be straightforward once the Lemma 2.6 machinery is complete
- Whether the C4/C4' sorry sites in CounterexampleElimination.lean are truly "blocking" for the final theorem (depends on whether c2' is needed at the limit)
