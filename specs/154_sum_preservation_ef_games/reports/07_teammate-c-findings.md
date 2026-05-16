# Teammate C Findings: Can build_bicompat Avoid CompData Extension?

**Task**: 154 - sum_preservation_ef_games
**Teammate**: C (Restructuring Alternatives)
**Date**: 2026-05-16
**Confidence**: HIGH for diagnosis, MEDIUM for proposed solution

## Key Findings

### Finding 1: The if/ite-in-types Problem is Fundamental to CompData's Architecture

The blocker is NOT a tactic limitation — it's a **structural property of dependent records with cross-referencing fields through branching expressions**. CompData has:

```
sz : I → Nat                                          -- branches on j' = j
eM : (j' : I) → Fin (sz j') → carrier j'             -- TYPE depends on sz
eN : (j' : I) → Fin (sz j') → carrier j'             -- TYPE depends on sz
agree : ∀ j', NormalForm (budget - sz j') (sz j') → …  -- TYPE depends on sz, REFERENCES eM/eN
```

When `sz j'` uses `if j' = j then ... else ...`, the types of eM, eN, and agree all contain this branching. You CANNOT simplify the branching in one field without simultaneously simplifying it in all others. No single Lean tactic does cross-field dependent type rewriting.

**Verified via `lean_run_code`**: `simp` CAN reduce `if j = j then a else b` in type positions (both `ite` and `dite`). BUT when the goal contains both `if j' = j'` in NormalForm types AND references to `eM j'` whose own type has `Fin (if j' = j' then ...)`, simp rewrites the goal's NormalForm types but leaves eM's type unchanged, causing a type mismatch.

### Finding 2: Function.update Doesn't Help

Using `Function.update cd_sz j (cd_sz j + 1)` instead of `fun j' => if j' = j then cd_sz j + 1 else cd_sz j'` was tested. `Function.update_apply` expands to the same `if/ite` pattern. The pattern `subst h; rw [Function.update_apply, if_pos rfl]` works for INDIVIDUAL fields proved separately, but fails when fields cross-reference each other through the branching sz.

### Finding 3: CompData Extension IS Mathematically Necessary

`build_bicompat` recurses on depth `d`, each step adding one variable (`n → n+1`). The recursive call needs per-component tracking of:
- How many elements per component (`sz`)
- The per-component environments (`eM`/`eN`)
- NF agreement at per-component level (`agree`)
- Consistency with the global environment (`consistent`)

This tracking (CompData or equivalent) is necessary because `component_extend_fwd/bwd` needs the per-component environments to find matching witnesses. Without tracking, each recursion level would need to independently rediscover all previously-added elements.

### Finding 4: The ONLY Path Forward is Structural Redesign of Per-Component State

Tested approaches that DON'T work:
| Approach | Why it fails |
|----------|-------------|
| `Function.update` for sz | Same if/ite issue after `update_apply` |
| Tactic-mode eM/eN outside structure | Opaque terms, agree can't reference |
| `subst h; rw [Function.update_apply, if_pos rfl]` on agree | Works ONLY when eM/eN aren't in the goal |
| `simp` to reduce `if j' = j'` | Rewrites goal types but not term types |
| `Eq.mpr`/`cast` at top level | Can't compute valid motive for cross-field deps |

## Recommended Approach: Per-Component State as Separate Records

**Instead of one CompData with `sz : I → Nat` that branches**, track per-component state using a separate record for each component:

```lean
structure ComponentState (sig : MonadicSignature) (ms ms' : I → OrderedMonadicStructure sig) 
    (budget : Nat) (j : I) where
  sz : Nat
  eM : Fin sz → (ms j).carrier
  eN : Fin sz → (ms' j).carrier
  agree : ∀ nf : NormalForm sig (budget - sz) sz, nf_eval_nf (ms j) ... (eM) nf ↔ ...
  bound : sz < budget
```

Then CompData becomes:
```lean
structure CompDataV2 ... where
  state : (j : I) → ComponentState sig ms ms' budget j
  consistent : ∀ (p : Fin n) (j : I) (h : (env_M p).1 = j),
    ∃ q : Fin (state j).sz, ...
```

**Extending component j** means replacing `state j` with a new `ComponentState` that has `sz + 1`, `Fin.cons c eM`, etc. — NO BRANCHING ON j' = j needed. The update is:
```lean
new_state := fun j' => if j' = j then new_component_state else state j'
```

BUT — the same if/ite appears in `new_state`! The difference is that `ComponentState` is NOT a dependent type on sz. Each `ComponentState` is self-contained. The `consistent` field references `(state j).sz` which is a plain Nat projection, not a branching expression.

Actually, this doesn't fully escape the problem either — `consistent` for the extended CompDataV2 still needs to branch on j' = j to handle the new element.

### Finding 5: The Cleanest Escape — Avoid CompData Extension in build_bicompat

The most promising restructuring:

1. **Change `build_bicompat`'s signature** to take `h_agree_per_component` as a SEPARATE argument (not inside CompData's agree field). CompData becomes "CompDataLite" with just sz, eM, eN, bound, consistent.

2. **The extension** only needs to update CompDataLite (no agree field to worry about). The if/ite in sz, eM, eN is manageable because these fields don't cross-reference each other's types through branching. The `rw [if_pos h]`/`rw [if_neg h]` pattern works for individual fields.

3. **Pass the extended agree separately** as `∀ j', ...`, proved by `by_cases h : j' = j` outside any structure literal. This works because `subst h; rw [Function.update_apply, if_pos rfl]` successfully reduces sz in the NormalForm type, and eM/eN aren't referenced in the agree TYPE (only in its PROOF, where they can be handled).

**Key insight**: The agree field TYPE only depends on `sz` (through NormalForm types), NOT on eM/eN directly. The eM/eN appear only in the agree PROOF (the body of the Iff). If agree is a separate hypothesis rather than a structure field, its type can be rewritten independently.

This requires changing `build_bicompat` and `sum_lift_one_var` but preserves the mathematical content. Estimated effort: moderate refactor of ~200 lines.

## Evidence

All claims verified via `lean_run_code`:

| Test | Result | Implication |
|------|--------|------------|
| `simp` reduces `if j = j then a else b` | ✅ Works | simp CAN handle ite in types |
| `simp` reduces `dite (j = j) f g` | ✅ Works | simp CAN handle dite |
| `subst h; rw [if_pos rfl]` in Function.update | ✅ Works | Individual field rewrites work |
| `rw` in goal with eM/eN cross-referencing sz | ❌ Motive failure | Cross-field rewriting fails |
| `Function.update_apply + if_pos h` pattern | ✅ for single fields | Works when fields are independent |
| eM defined by tactic, referenced in agree | ❌ Opaque | Tactic-defined terms block downstream |
| simp on goal with both NormalForm types AND eM | ❌ Type mismatch | Can't rewrite types and terms independently |

## Confidence Level

- **HIGH** that the blocker is structural (CompData's cross-referencing dependent fields)
- **HIGH** that no tactic-level fix exists within the current architecture
- **MEDIUM** that the CompDataLite + separate agree approach works (not yet tested end-to-end)
- **MEDIUM** that the refactor is ~200 lines (could be more if consistent field is tricky)
