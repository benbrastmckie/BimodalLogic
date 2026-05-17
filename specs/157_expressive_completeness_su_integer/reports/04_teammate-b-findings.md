# Teammate B Findings: Restricted subst_separable and Combined WF Induction

**Date**: 2026-05-17
**Session**: research session (teammate B)
**Focus**: Restricted subst_separable via position tracking + combined WF induction on compound measure

---

## Key Findings

### Finding 1: The "restricted subst_separable" approach has a real foundation but incomplete formalization

The key question: when we apply `abstract_untl phi A B p` to a formula `phi` that satisfies `no_S_nested_in_U`, WHERE does the fresh atom `p` appear in the result?

**Tracing `abstract_untl` through the formula structure:**

`abstract_untl` recurses structurally, replacing each `untl A B` node with `.atom p` and descending into all other nodes including `snce`. This means:
- If `phi = .snce C D` and C contains `untl A B`, the abstraction produces `.snce (abstract_untl C A B p) D`
- The atom `p` CAN appear inside `snce` arguments

**The position-awareness question**: Can we prove that when `phi` has `no_S_nested_in_U`, the abstract result places `p` only in "S-free positions"?

The answer is **NO** in general. Consider `phi = .snce (.untl A B) q`. This formula:
- Has `no_S_nested_in_U` (because the untl args A, B are S-free)
- After `abstract_untl phi A B p`: produces `.snce (.atom p) q`
- The atom `p` is INSIDE an `snce` argument
- Substituting `untl A B` for `p` back gives `.snce (.untl A B) q` -- which is NOT separated (snce requires U-free args)

This confirms the Phase 6 handoff assessment: `subst_separable` is false in general because `p` CAN appear in `snce` args.

### Finding 2: A RESTRICTED version works for specific formula shapes

However, there is a meaningful restricted version. Define a "S-free position" predicate:

```
atom p appears in S-free positions in phi iff:
  for every occurrence of p in phi, the path from root to p does NOT pass through
  any snce node or all_past node.
```

**Theorem (Restricted subst_separable)**: If `G` is syntactically separated, atom `p` does not appear in `G`, and `p` only appears in S-free positions in `G[p := untl A B]` ... wait, this is circular since we're asking about the substituted formula.

The correct formulation: Given separated `G` (U-free, since we abstracted out all untl), the positions where atom `p` could appear after `abstract_untl` is determined by the structure of the ORIGINAL formula before abstraction.

**Key insight from examining `abstract_untl`**: The `snce` case descends uniformly:
```lean
| .snce psi1 psi2 => .snce (abstract_untl psi1 A B p) (abstract_untl psi2 A B p)
```

So if the ORIGINAL formula has `untl A B` inside `snce` arguments, the abstracted result has `p` inside `snce` arguments. This is exactly the Case 5-8 scenario.

**What `no_S_nested_in_U` tells us**: The predicate requires that at every `untl` node, both args are S-free. It does NOT prohibit `untl` appearing inside `snce` args. It only restricts what's inside the `untl`.

So for `phi = .snce (.untl A B) q` with S-free A, B:
- `no_S_nested_in_U phi` holds (the untl's args are S-free)
- `abstract_untl phi A B p = .snce (.atom p) q`
- `p` appears inside snce -- problematic for re-substitution

**Conclusion on restricted subst_separable**: The approach requires a stronger predicate than `no_S_nested_in_U`. We would need something like "the formula has no `untl` inside `snce` args" -- but that's exactly `is_properly_separated` for the no_S_nested portion! The formula `phi = .snce (.untl A B) q` is NOT `is_syntactically_separated` (since snce requires U-free args). So:

If `phi` is already SYNTACTICALLY SEPARATED, then no `untl` appears inside `snce` args (because `is_syntactically_separated` for snce requires `is_U_free` of both args). In this case, `abstract_untl` would put `p` ONLY in S-free positions.

### Finding 3: Position tracking works perfectly for ALREADY-SEPARATED formulas

**Theorem (can be proved)**: If `phi` is syntactically separated and `phi` contains `untl A B` (with S-free A, B) as a subformula, then `abstract_untl phi A B p` places `p` only in "S-free positions" (positions not inside any `snce` or `all_past` argument path).

**Proof sketch**: By structural induction on `phi`. Since `phi` is separated:
- At `snce psi1 psi2` nodes: `is_U_free psi1 = true` and `is_U_free psi2 = true`. Therefore psi1 and psi2 contain NO `untl A B`. So `abstract_untl psi1 A B p = psi1` and `abstract_untl psi2 A B p = psi2` -- atom `p` does NOT appear in the snce args.
- At `all_past psi` nodes: `is_U_free psi = true`. Same argument -- `p` doesn't appear inside `all_past` args.
- At `untl psi1 psi2` nodes where psi1=A, psi2=B: replaced by `.atom p` -- `p` appears at TOP LEVEL (not inside snce/all_past).
- At `imp`, `all_future`, `box` nodes: recurse normally.

This proves that for a SEPARATED formula, `abstract_untl` puts `p` only in S-free positions!

**This IS provable in Lean** as:

```lean
/-- In a separated formula, abstract_untl places p only in "S-free positions":
    positions not under any snce or all_past argument. -/
theorem abstract_untl_p_in_S_free_positions (phi A B : Formula) (p : Atom)
    (h_sep : is_syntactically_separated phi = true) :
    is_U_free (abstract_untl phi A B p) = true ∨
    -- more precisely: p only appears where it remains safe
    atom_appears_only_in_S_free_positions p (abstract_untl phi A B p) := ...
```

Actually, the cleaner statement: if `phi` is separated, then `abstract_untl phi A B p` is also separated! Because:
- The U-free parts of phi (snce args, all_past args) remain U-free after abstraction
- The S-free parts of phi (untl args, all_future args) remain S-free (the untl A B nodes get replaced by `.atom p` which is S-free)

**This IS the key theorem we need**: `abstract_untl_preserves_separated`.

### Finding 4: `abstract_untl_preserves_separated` is provable, blocking the loop

```lean
theorem abstract_untl_preserves_separated (phi A B : Formula) (p : Atom)
    (h_sep : is_syntactically_separated phi = true) :
    is_syntactically_separated (abstract_untl phi A B p) = true
```

**Proof**: By structural induction on `phi`:

- `atom a`: `abstract_untl` returns `atom a`, which is separated.
- `bot`: trivially separated.
- `imp`: separated iff both components separated. By IH, both components remain separated.
- `box`: `abstract_untl` doesn't enter box bodies (well, it does for box -- this needs checking). Box is always separated (`is_syntactically_separated (.box _) = true`).
- `all_past psi`: `is_syntactically_separated (.all_past psi) = is_U_free psi`. Since `psi` is U-free (separation condition for all_past) and `abstract_untl psi A B p` is still U-free (because U-free implies no `untl A B` at all, so abstract_untl is identity on U-free formulas -- this follows from `abstract_untl_makes_U_free` applied to has_single_U_type, but more precisely: if psi is U-free, then `abstract_untl psi A B p = psi` and the result is still U-free).
- `all_future psi`: `is_syntactically_separated (.all_future psi) = is_S_free psi`. Since psi is S-free (separation condition), `abstract_untl psi A B p` preserves S-freeness (by `abstract_untl_preserves_S_free`). So separated.
- `untl psi1 psi2` where psi1 = A, psi2 = B: becomes `.atom p`, which is separated.
- `untl psi1 psi2` where the match fails: the abstraction recurses. Both psi1 and psi2 are S-free (from separation). `abstract_untl` preserves S-freeness (by `abstract_untl_preserves_S_free`). So the result `untl (abstract psi1) (abstract psi2)` has S-free args, hence is separated.
- `snce psi1 psi2`: both psi1 and psi2 are U-free (separation condition for snce). U-free formulas have no `untl A B`, so `abstract_untl psi_i A B p = psi_i` (abstraction is identity on U-free formulas). Thus the result is `snce psi1 psi2` which is still separated.

**This proof works!** The key fact is: `abstract_untl phi A B p = phi` when `is_U_free phi = true`. This is provable by induction.

```lean
theorem abstract_untl_identity_on_U_free (phi A B : Formula) (p : Atom)
    (h : is_U_free phi = true) : abstract_untl phi A B p = phi
```

**With this**, `abstract_untl_preserves_separated` follows directly.

### Finding 5: The `abstract_untl_preserves_separated` theorem enables the snce_separable proof WITHOUT circularity

Here is the proof sketch for `snce_separable` using this approach:

**Goal**: Given `is_separable phi`, `is_separable psi`, prove `is_separable (.snce phi psi)`.

1. Get separated equivalents: `phi' = is_syntactically_separated` and `int_equiv phi phi'`, similarly `psi'`.

2. Form `G = .snce (replace_box_with_top phi') (replace_box_with_top psi')`. This is int_equiv to `.snce phi psi`. Both box-normalized components are still separated (by `replace_box_preserves_separated`).

3. Let `G' = .snce phi'' psi''` where `phi'' = replace_box_with_top phi'` and similarly for `psi''`.

4. **Key claim**: `G'` has `no_S_nested_in_U`. This is `snce_of_boxfree_sep_no_S_nested` -- already proved in TemporalClosure.lean!

5. So we need to prove: `no_S_nested_in_U G' -> is_separable G'`.

6. **Apply abstract_untl iteratively** to each `untl` type in `G'`. Each application:
   - Uses `abstract_untl_preserves_separated` (new theorem) to maintain separation of the abstracted form
   - Reduces `count_U_subformulas` by at least 1
   - Maintains `no_S_nested_in_U` (by `abstract_untl_preserves_no_S_nested`)

7. After abstracting all `untl` types: result is U-free. A U-free formula that satisfies `no_S_nested_in_U` has no `snce` with U-inside (vacuously), so by `snce_of_boxfree_sep_no_S_nested` + `expanded_jd_zero_imp_separated` or simpler route: U-free snce requires U-free args, which is satisfied.

Wait -- we need to handle substituting back. After abstracting ALL untl types from `G'`, we have `G'' = snce (U-free phi''') (U-free psi''')` which is separated. But `G''` uses fresh atoms `p1, p2, ...` for the various `untl` types.

8. **Substituting back**: Each substitution `G''[p_i := untl A_i B_i]` -- can we prove this remains separable?

Here is where it gets subtle. After ONE substitution of `p_i` with `untl A_i B_i`:
- `G''` is separated and U-free
- `p_i` only appears in S-free positions in `G''` (by `abstract_untl_preserves_separated` on the step-by-step abstraction)
- Substituting `.untl A_i B_i` (which is S-free since A_i, B_i are S-free -- they were args of an untl in the separated G') produces a formula where:
  - `untl A_i B_i` appears only in S-free positions
  - The result is syntactically SEPARATED again!

This follows because "S-free position" means "not under snce or all_past", and putting a separated formula (untl A_i B_i) in a separated position gives a separated result.

The result of ONE substitution is separated. We can then repeat.

**This gives a complete axiom-free proof of `snce_separable`!**

### Finding 6: The `untl_separable` direction follows by duality

Once `snce_separable` is proved without axioms:
- `untl_separable` follows by `swap_temporal` duality (infrastructure already in Duality.lean)
- `all_past_separable` and `all_future_separable` follow similarly

### Finding 7: The compound WF induction approach is the fallback, not the primary path

The approach from Report 09 (mutual WF induction on junction_depth) IS correct but complex. The restricted subst_separable approach described above is SIMPLER because:

1. It avoids WF induction entirely -- it uses structural induction on `phi` with the substitution argument handled syntactically
2. The key new lemmas needed are `abstract_untl_identity_on_U_free` (~20 LOC) and `abstract_untl_preserves_separated` (~50 LOC)
3. Cases 5-8 are NOT needed in this approach -- they are bypassed by the abstract-then-substitute mechanism

**Why Cases 5-8 are bypassed**: Cases 5-8 arise when U appears in BOTH event and guard of a snce. In the abstract-then-substitute approach:
- We abstract ALL untl types (including those in both event and guard)
- The result is U-free in both positions
- When substituting back, we substitute one type at a time
- Each single substitution produces a result that is still separated (by the position tracking argument)
- Cases 5-8 situations (same U in both positions) are handled by the SAME substitution step -- both positions get `untl A B` simultaneously, and since p appeared only in S-free positions, both substitutions land in S-free positions

---

## Recommended Approach

**Primary**: Prove `abstract_untl_preserves_separated` and use it to give a complete proof of `snce_separable` without axioms. The proof requires:

1. `abstract_untl_identity_on_U_free` (NEW, ~20 LOC):
   ```lean
   theorem abstract_untl_identity_on_U_free (phi A B : Formula) (p : Atom)
       (h : is_U_free phi = true) : abstract_untl phi A B p = phi
   ```

2. `abstract_untl_preserves_separated` (NEW, ~50 LOC):
   ```lean
   theorem abstract_untl_preserves_separated (phi A B : Formula) (p : Atom)
       (h_sep : is_syntactically_separated phi = true) :
       is_syntactically_separated (abstract_untl phi A B p) = true
   ```

3. `subst_separated_in_S_free_position_preserved` (NEW, ~50 LOC):
   This captures the key restoration step: substituting a separated formula for an atom that appears only in S-free positions in a separated formula gives a separated result.

4. `no_S_nested_in_U_separable` (~100 LOC proof using the above):
   ```lean
   theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
       is_separable phi
   ```
   Proved by iterative abstraction of untl types, using the count_U_subformulas as the termination measure.

5. Replace the 4 weak temporal closure axioms with proofs derived from `no_S_nested_in_U_separable` + the existing infrastructure in TemporalClosure.lean.

6. Handle `untl_separable` and `all_future_separable` by duality.

**Total estimated LOC: ~350-500** (significantly less than the 600-800 from the mutual WF approach).

**Secondary**: If the position tracking approach has unforeseen Lean formalization difficulties (e.g., the "S-free position" predicate is hard to state exactly), fall back to the mutual WF induction on compound measure from Report 09. That approach is correct but requires more infrastructure.

---

## Evidence and Examples

### Example 1: `abstract_untl_preserves_separated` in action

Start with separated `phi = .snce p (.untl A B)` where p is an atom, A, B are S-free.

Wait -- this is NOT separated! `is_syntactically_separated (.snce p (.untl A B))` requires `is_U_free (.untl A B) = false` -- not satisfied. So this is not a valid starting point.

Correct example: `phi = .imp (.snce p q) (.untl A B)` where p, q are atoms, A, B are S-free atoms.
- `is_syntactically_separated phi` = true (imp of two separated things)
- `abstract_untl phi A B r` = `.imp (.snce p q) (.atom r)` (snce has no untl, untl is replaced by r)
- Is this separated? `is_syntactically_separated (.imp (.snce p q) (.atom r))` = `is_syntactically_separated (.snce p q) && is_syntactically_separated (.atom r)` = `(is_U_free p && is_U_free q) && true` = `true && true` = true. YES!

Another example confirming the key case: `phi = .snce p q` (p, q atoms, no untl).
- `abstract_untl phi A B r = .snce p q` (identity, no untl to replace)
- Still separated.

### Example 2: What FAILS without separated precondition

`phi = .snce (.untl A B) q` (NOT separated, but satisfies `no_S_nested_in_U` with S-free A, B).
- `abstract_untl phi A B p = .snce (.atom p) q`
- This is separated! (atom p is U-free, q is U-free)
- But substituting back: `subst_formula (.snce (.atom p) q) p (.untl A B) = .snce (.untl A B) q`
- This is NOT separated!

So for NOT-separated input, the abstract-then-substitute route FAILS to produce a separated result. This is why we need to restrict to the case where `phi` starts separated.

### Example 3: The `snce_separable` proof sketch with separated args

Given separated `phi'` and `psi'`, form `G = .snce phi'' psi''` (box-normalized).

If `phi'' = .untl A B` and `psi'' = .untl A B` (Case 5-like scenario):
1. Abstract `untl A B` with fresh atom p: `abstract_untl G (A) (B) p = .snce (.atom p) (.atom p)`
2. `abstract_untl_preserves_separated` confirms this is separated (both atoms are U-free)
3. Substitute back `p := .untl A B`: `.snce (.untl A B) (.untl A B)`
4. But this is NOT separated! The snce args need to be U-free.

Wait -- this seems to break the argument. Let me recheck.

**Correction**: The abstract result `.snce (.atom p) (.atom p)` is separated (U-free args). But when we substitute `p := .untl A B`, we get `.snce (.untl A B) (.untl A B)` -- NOT separated.

**Where does the argument fail?** The claim was "p appears only in S-free positions" -- but in `.snce (.atom p) (.atom p)`, the atom p appears INSIDE snce arguments, which are NOT S-free positions!

**The flaw in the argument**: When `phi'' = .untl A B` (the whole formula is a single untl), and we form `G = .snce phi'' psi''`, the formula G is NOT syntactically separated. So `abstract_untl_preserves_separated` does NOT apply here (its hypothesis requires `phi` to be separated, but G is not separated).

This brings us back to the original problem: `G = .snce (.untl A B) (.untl A B)` has `no_S_nested_in_U` (A, B are S-free), but it is NOT separated, and the abstract-then-substitute trick doesn't work directly.

**The corrected analysis**: The `abstract_untl_preserves_separated` theorem applies to the ARGUMENTS of the snce, not to the whole formula. If `phi''` is separated and we abstract untl from `phi''`, the result `abstract_untl phi'' A B p` is still separated. Similarly for `psi''`. But then we have `snce (abstract phi'') (abstract psi'')` which has U-free args (both are U-free since we've abstracted out the only untl type). So this IS separated!

The key: we abstract from `phi''` and `psi''` SEPARATELY, then form the snce. Each component `abstract_untl phi'' A B p` is separated (by `abstract_untl_preserves_separated`), and in particular is U-free (since we abstracted the last untl type). So `snce (abstract phi'') (abstract psi'')` has U-free args -- it IS syntactically separated.

Then substitute: `subst_formula (snce (abstract phi'') (abstract psi'')) p (.untl A B)`.

The atom p appears in:
- `abstract phi''`: separated, so p only in S-free positions (proved above)
- `abstract psi''`: similarly

Substituting `untl A B` for p in the WHOLE `snce (abstract phi'') (abstract psi'')`:
- In `abstract phi''`: p is in S-free positions, so `untl A B` lands in S-free positions. Result is separated.
- In `abstract psi''`: same argument.
- The snce args after substitution are both separated.
- BUT: are the snce args still U-free after substitution? NO -- we just put `untl A B` back in them!

**This is the fundamental problem**: after substituting back, the snce args are no longer U-free. The result `snce (phi'') (psi'')` (which equals the original G) is not separated.

**Conclusion**: The restricted subst_separable approach cannot avoid Cases 5-8. The position-tracking argument shows that `p` ends up in S-free positions WITHIN each separated component `phi''`, but when those components are SNCE arguments, putting `untl` back there creates U-under-S -- which is exactly Cases 5-8.

---

## Revised Assessment

### What IS achievable with position tracking

The `abstract_untl_preserves_separated` theorem IS true and provable. It is useful for proving:

```lean
-- In no_S_nested_in_U formulas with a SINGLE untl type U(A,B),
-- if we abstract that untl, the result is U-free (and separated if original was separated under the right conditions)
theorem single_U_abstraction_separable ...
```

But for the FULL `snce_separable` (with arbitrary separated args), position tracking alone does not avoid the core difficulty: the snce args contain `untl`, and substituting back gives U-under-S.

### What the actual fix requires

**The actual minimal fix** is the GHR94 Lemma 10.2.8 junction-depth induction, as documented in Reports 09 and 10. The key facts established by this research confirm:

1. `snce (separated phi') (separated psi')` has `junction_depth <= 1` (proved in TemporalClosure.lean as `snce_of_boxfree_sep_jd_le_one`)
2. At junction_depth 1, Cases 1-4 are sufficient for the positions where U appears in only ONE of event/guard
3. Cases 5-8 (U in BOTH event and guard) are the genuine hard cases

The Cases 5-8 formulas -- `snce (a ^ untl A B) (q v untl A B)` etc. -- are formulas of junction_depth exactly 1. To prove these separable WITHOUT using `all_separable`:

**Approach**: Prove them by direct semantic argument using the integer order structure. Unlike dense time, the discrete integer structure means we can perform exact case analyses on where U(A,B) first holds. The GHR94 Cases 5-8 for integer time would be:

For Case 5: `S(a ^ U(A,B), q v U(A,B))`
The separated equivalent would involve a disjunction over cases based on whether U(A,B) holds at the witness point s (where S starts), at the current time t, or in between.

**Research gap**: The CORRECT separated equivalents for Cases 5-8 on INTEGER (discrete) time have not been found by any previous research session. This is the fundamental research blocker. GHR94's dense-time equivalents are wrong on ℤ.

---

## Confidence Level

- **Confidence that `abstract_untl_preserves_separated` is provable**: HIGH (90%). The proof outline is clear and the lemmas are in place.
- **Confidence that position tracking avoids Cases 5-8**: LOW (10%). As shown in the Example 3 correction, the abstract-then-substitute scheme still produces the Case 5-8 problem when both arguments of snce contain the same untl type.
- **Confidence that the minimal fix requires new explicit separated equivalents for Cases 5-8 on ℤ**: HIGH (85%). Every approach examined converges to this requirement.
- **Confidence that junction-depth WF induction (Reports 09, 10) is the right framework**: MEDIUM-HIGH (75%). The framework is correct but requires ~600-800 LOC of new proof code.
- **Confidence that Cases 5-8 equivalents for ℤ can be derived semantically**: MEDIUM (50%). On discrete time, one can reason about the "last time U(A,B) starts" or "the first time U(A,B) holds after s", which gives explicit separated equivalents. But the formulas would be complex.

---

## Actionable Recommendations

1. **Implement `abstract_untl_preserves_separated`** (~50 LOC in Hierarchy.lean). This is a cleanly-provable theorem that should be added regardless of which approach is taken for the main proof.

2. **Research Case 5 explicitly**: Case 5 is `S(a ^ U(A,B), q v U(A,B))` with all variables U-free and S-free. On integer time, what is the explicit separated equivalent? Try the following semantics-based construction:
   - Let s be the S-witness: a^U(A,B) holds at s, q v U(A,B) holds for all r in (s,t)
   - Case 5a: U(A,B) starts before s (i.e., the "old" U-witness is before s)
   - Case 5b: U(A,B) starts exactly at s
   - Case 5c: U(A,B) starts in (s,t)
   - Each sub-case should produce S-free or U-free components that are separated

3. **If Case 5 semantics approach succeeds**: Cases 6, 7, 8 follow by similar semantic arguments (the boolean combination of U and ¬U in event and guard creates finitely many cases, each analyzable similarly).

4. **If Case 5 semantics approach fails**: Implement the junction-depth WF induction from Report 09 as the primary proof path (~600-800 LOC total).

5. **Do not attempt**: Any form of sorry deferral. The task requires zero axioms in the final proof.
