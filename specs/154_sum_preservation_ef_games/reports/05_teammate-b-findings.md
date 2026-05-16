# Teammate B Findings: Alternative Approaches for 15 Build Errors

**Task**: 154 - Sum Preservation EF Games
**Focus**: Alternative syntax/representation approaches for the 15 remaining build errors
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
**Date**: 2025-05-15

---

## Summary

Both error clusters have **confirmed, tested fixes** that require only localized syntax changes — no
restructuring of CompData, no elimination of CompData, no new axioms. All fixes verified via
`lean_run_code` calls against the actual Mathlib environment.

---

## Key Findings

### Error Cluster 1 (Category 2): Invalid `.1` projection on `Fin.cons (show T from ⟨j,c⟩)` (6 errors, lines 548-550, 629-631)

**Root cause**: `show T from ⟨j, c⟩` elaborates to `have this : T := ⟨j, c⟩; this`, an opaque
let-binding. When this appears as the head element in `Fin.cons (show T from ⟨j, c⟩) env_M`, the
resulting `Fin.cons ?x ?env p` has unknown sigma type, so `.1` projection fails with "Invalid
projection: Type of Fin.cons ... is not known; cannot resolve projection `1`".

**Fix**: Replace `show T from ⟨j, c⟩` with `(⟨j, c⟩ : T)` (type ascription form). These are
definitionally equal (`rfl` proves `Fin.cons (⟨j,c⟩ : T) env = Fin.cons (show T from ⟨j,c⟩) env`)
but the ascription form does not create the opaque `have this` wrapper, so Lean can reduce the sigma
type for `.1`.

**Verified** (both succeed in `lean_run_code`):
```lean
-- (⟨j, c⟩ : T) allows .1 projection
(Fin.cons (⟨j, c⟩ : (orderedSum sig I ms).carrier) env_M p).1 = j
-- proved by: simp [Fin.cons_zero]

-- h_idx' with type-ascription form
∀ p : Fin (n + 1),
  (Fin.cons (⟨j, c⟩ : (orderedSum sig I ms).carrier) env_M p).1 =
  (Fin.cons (⟨j, c'⟩ : (orderedSum sig I ms').carrier) env_N p).1
-- proved by: intro p; cases p using Fin.cases with
--   | zero => simp [Fin.cons_zero]
--   | succ k => simp [Fin.cons_succ, h_idx k]
```

**Sites to fix**: Every `show T from ⟨j, c⟩` in a `Fin.cons` context:
1. `extend_atoms` conclusion (lines 256-257): both `show (orderedSum sig I ms).carrier from ⟨j, c⟩` and `show (orderedSum sig I ms').carrier from ⟨j, c'⟩`
2. `BiCompat` definition (lines 169-173, 175-180): all four occurrences
3. `build_bicompat` `oracle_step` goal and `h_idx'` type (lines 494-498, 547-550, 629-632)
4. `build_bicompat` recursive `cd'` construction (lines 552-554, 632-635)
5. `sum_nf_lift_gen` `use_ih` (lines 712-721): all `show _ from`
6. `sum_lift_one_var` conclusion (lines 755-757): both `show` annotations
7. `sum_atoms_one_var` conclusion (lines 327-329): both `show` annotations

For `h_idx'` (lines 547-550 and 629-632), the current `Fin.cases rfl (fun k => h_idx k)` term proof
fails because the implicit sigma type can't be inferred. Replace with:
```lean
have h_idx' : ∀ p : Fin (n + 1),
    (Fin.cons (⟨j, c⟩ : (orderedSum sig I ms).carrier) env_M p).1 =
    (Fin.cons (⟨j, c'⟩ : (orderedSum sig I ms').carrier) env_N p).1 := by
  intro p; cases p using Fin.cases with
  | zero => simp [Fin.cons_zero]
  | succ k => simp [Fin.cons_succ, h_idx k]
```

---

### Error Cluster 2 (Category 4): Stuck `if j' = j' then 1 else 0` in `sum_lift_one_var`'s CompData (11 errors, lines 788-812)

**Root cause**: The `eM`/`eN` fields use:
```lean
eM := fun j' => if h : j' = i then
  (show Fin (if j' = i then 1 else 0) → (ms j').carrier from
    by rw [if_pos h, h]; exact fun q => (![a]) q)
  else ...
```
After `split` tactic in the `agree` proof, the `isTrue h` branch leaves `if j' = j' then 1 else 0`
unresolved in the NF type because the `show ... from by rw` wrapper is opaque. Additionally,
`simp only [show (if i = i then 1 else 0) = 1 from if_pos rfl]` at line 788 fails with "Unknown
identifier `i`" because after `subst h`, the name `j'` remains active in Lean's internal state
(not `i`), and the manual `show` lemma uses the wrong variable name.

The `bound` field at line 805 fails with "omega could not prove the goal" because `omega` can't
prove `if i = i then 1 else 0 < k + 1` without first reducing `if i = i then 1 else 0` to `1`.

The `consistent` field at line 812 fails because the witness type is `Fin (if i = i then 1 else 0)`
rather than `Fin 1`.

**Fix**: Replace the `show ... from by rw [if_pos h, h]` pattern in `eM`/`eN` with `h ▸ expr`
(equality transport), and update the proofs to use `simp only [if_pos rfl, dif_pos rfl,
Nat.succ_sub_one]`.

**Verified** (all succeed in `lean_run_code`):
```lean
-- New eM/eN definition (replaces the show ... from by rw pattern)
eM := fun j' => if h : j' = i then h ▸ Fin.cons a Fin.elim0 else Fin.elim0
eN := fun j' => if h : j' = i then h ▸ Fin.cons b Fin.elim0 else Fin.elim0

-- New agree proof (replaces lines 784-802)
agree := fun j' => by
  by_cases h : j' = i
  · subst h
    simp only [if_pos rfl, dif_pos rfl, Nat.succ_sub_one]
    exact fun nf => h_agree_comp nf  -- (or: intro nf; exact h_agree_comp nf)
  · simp only [if_neg h, dif_neg h, Nat.sub_zero]
    exact fun nf => h_comp (k + 1) le_rfl j' nf

-- New bound proof (replaces lines 803-806)
bound := fun j' => by
  by_cases h : j' = i
  · simp only [if_pos h]; omega
  · simp only [if_neg h]; omega

-- New consistent proof (replaces lines 807-812)
consistent := fun p j' hj' => by
  fin_cases p
  simp only [h_envM, h_envN] at hj'
  subst hj'
  simp only [dif_pos rfl, if_pos rfl]
  exact ⟨0, by simp [Fin.cons_zero], by simp [Fin.cons_zero]⟩
```

---

## Answers to the Five Alternative Approach Questions

**1. Eliminate CompData for n=1 case**: Possible in theory. Since `sum_lift_one_var` has a fixed
single-element environment `⟨i, a⟩` / `⟨i, b⟩`, a specialized `build_bicompat_one_var` that takes
`(i : I)`, `(a : (ms i).carrier)`, `(b : (ms' i).carrier)`, and `h_agree_comp` directly would
avoid needing CompData at all for this call site. The witness oracle at each depth step would use
`component_extend_fwd/bwd` on the single component. However, this is a much larger refactor (new
definition + proof) and NOT needed — the current CompData works once Fix B is applied.

**2. Replace `show T from x` with `id x` or direct coercion**: `id x` does not work (same opacity
as `show`). Direct coercion `(x : T)` is exactly Fix A above — **this works and is the right fix**.
Verified by `rfl`-equality and projection tests.

**3. `Fin.cons` with explicit function type annotation**: `(Fin.cons x env : Fin (n+1) → T)` does
NOT help because the projection `.1` on the *application* `(Fin.cons x env p)` still can't be
resolved without knowing `T` is a sigma type at the elaboration site. The annotation must be on
the element `x`, not the function.

**4. Rewrite CompData to use `Sigma` projections / avoid dif_pos/dif_neg opacity**: **YES — Fix B
above.** Using `h ▸ Fin.cons a Fin.elim0` (the `▸` transport) instead of `show ... from by rw`
makes the term transparent to `simp only [dif_pos rfl]`.

**5. Use `set`/`let` bindings for envM'**: The `set envM := Fin.cons ⟨i,a⟩ Fin.elim0` approach
was already present in `sum_lift_one_var` (lines 759-765) and partially works for the `h_atoms`
proof. It does NOT resolve the CompData `agree` field issues — those require Fix B.

---

## Recommended Approach

Apply two purely syntactic fixes requiring approximately 40-60 lines of changes total:

**Fix A** (Category 2, 6 errors): Replace all `show T from ⟨j,c⟩` with `(⟨j,c⟩ : T)` in
`extend_atoms`, `BiCompat`, `build_bicompat`, `sum_nf_lift_gen`, `sum_lift_one_var`,
`sum_atoms_one_var`. Update `h_idx'` to a tactic proof.

**Fix B** (Category 4, 11 errors): In `sum_lift_one_var`'s CompData, replace the
`show ... from by rw [if_pos h, h]` pattern in `eM`/`eN` with `h ▸ Fin.cons a Fin.elim0` and
rewrite `agree`, `bound`, `consistent` proofs to use `simp only [if_pos rfl, dif_pos rfl,
Nat.succ_sub_one]` followed by direct application.

These are independent fixes addressing separate error clusters. No CompData elimination, no new
axioms, no sorry deferral.

---

## Confidence Level

**HIGH**. All individual proof obligations verified via `lean_run_code`:
- `(⟨j,c⟩ : T)` vs `show T from ⟨j,c⟩` definitional equality confirmed with `rfl`
- `.1` projection works with ascription form, fails with `show` form (confirmed)
- `h_idx'` tactic proof succeeds with ascription form (confirmed)
- Full `agree`, `bound`, `consistent` proofs with `h ▸` and `simp only [if_pos rfl, dif_pos rfl]` all succeed (confirmed)

Estimated implementation time for an implementer with access to `lean_goal`: 2-3 hours.
