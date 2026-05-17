# Phase 7 Handoff: Quantifier Elimination Proof Architecture Complete

**Date**: 2026-05-17 (fourth attempt)
**Session**: sess_1779003456_c5b522
**Status**: BLOCKED (proof architecture fully identified, technical elaboration issue)

## What Was Accomplished This Session

1. **Proved reduceElimLast_correct architecture works**: Verified in lean_run_code that the invariant-based approach compiles for all key building blocks:
   - `env_H1_propagate`: `Fin.castSucc_zero` + `castSucc_succ_comm` + `Fin.cons_succ/cons_zero`
   - `env_H2_propagate`: `Fin.last (n+1) = Fin.succ (Fin.last n)` + `Fin.cons_succ`
   - Binding case: `Fin.cons_snoc_eq_snoc_cons` gives the key commutation

2. **Proved extAtomMap_injective compiles**: By exhaustive cases on `ExtPred sig` (4 constructors) x 4 constructors = 16 cases. Most closed by `simp [extAtomMap, Atom.mk_fresh]; exact absurd hab.1 (by decide)` using the fact that different base strings in mk_fresh give different atoms.

3. **Designed expressiveness_by_depth**: Using Nat recursion on quantifier_depth with explicit pattern matching on (d, sig, atomMap, hinj, psi, hd). The quantifier cases use:
   - `qdepth_reduceElimLast_le` for depth decrease
   - `reduceElimLast_correct_at_one` for variable elimination
   - `q_exists_correct` for existential quantification
   - IH at `extSignature sig` with `extAtomMap atomMap`
   
4. **Key insight: NO atom elimination needed**: The formula `q_exists ihExt.val` works DIRECTLY in `to_int_struct (extIntStruct M t) (extAtomMap atomMap)` because the int_truth evaluation at the extended model is equivalent via reduceElimLast_correct. The formula uses extended atoms but that's OK because `to_int_struct` interprets ALL atoms.

## Technical Blocker

The implementation fails to compile due to a Lean 4 elaboration issue:

**Problem**: In a `noncomputable def` with structural recursion:
```lean
noncomputable def reduceElimLast_correct {sig} :
    (m : Nat) → (alpha : MonadicFormula sig (m+1+1)) →
    ∀ (M : ...) (ef : ...) (es : ...) (t : Int),
    (∀ i, ef (castSucc i) = es i) →  -- NON-DEPENDENT arrow
    (ef (last (m+1)) = t) →           -- NON-DEPENDENT arrow  
    eval ... ef alpha ↔ eval ... es (reduceElimLast ...)
  | m, .atom p i => fun M ef es t => by intro H1 H2; ...
```

Lean 4 refuses to elaborate `fun M ef es t => by intro H1 H2` because it tries to make H1 and H2 dependent on each other (inferring `H2 : ?m.74 H1`), which conflicts with the non-dependent arrows in the target type.

**Solution** (not yet implemented): Restructure as either:
- (A) A `theorem` proved entirely in tactic mode with `induction` on a custom WF relation
- (B) Replace the `noncomputable def` with `def ... := by` using `match` inside tactic mode
- (C) Use explicit `Iff.intro` term-mode proofs for each case, avoiding `by intro`

## Immediate Next Action

Implement `reduceElimLast_correct` using approach (B):
```lean
private theorem reduceElimLast_correct {sig} (m : Nat) (alpha : MonadicFormula sig (m+1+1))
    (M : IntStructureFromSig sig) (ef : Fin (m+1+1) → Int) (es : Fin (m+1) → Int) (t : Int)
    (H1 : ∀ i : Fin (m+1), ef (Fin.castSucc i) = es i)
    (H2 : ef (Fin.last (m+1)) = t) :
    eval (int_to_ordered sig M) ef alpha ↔
    eval (int_to_ordered (extSignature sig) (extIntStruct M t)) es (reduceElimLast (m+1) alpha) := by
  -- Use well_founded_tactics to allow recursion
  -- Or: change to a nested induction that Lean accepts
```

The key is that `alpha : MonadicFormula sig (m+1+1)` where `m` appears in the type index means standard `induction alpha` won't generalize `m`. Instead, use structural recursion via a `match` inside the tactic proof, or use `MonadicFormula.recOn`.

## Files

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (unchanged, 2 sorries)

## Proof Summary (for implementor)

For `.ex alpha` (alpha : MonadicFormula sig 2), the proof is:
1. `reduceElimLast 1 alpha` has qdepth <= alpha.qdepth
2. IH gives `ihExt : { A_ext // ... }` at extSignature
3. Result formula = `q_exists ihExt.val`
4. Correctness:
   - (→) Given `⟨z, hz⟩` where `hz : eval M (Fin.cons z (fun _ => t)) alpha`:
     - By `reduceElimLast_correct_at_one`: get eval at extSig
     - By `ihExt.property`: get int_truth at extModel  
     - Conclude: `⟨z, ...⟩` witnesses q_exists
   - (←) Given `⟨z, hz⟩` where `hz : int_truth extModel z A_ext`:
     - By `ihExt.property.mpr`: get eval at extSig
     - By `reduceElimLast_correct_at_one.mpr`: get eval at sig
     - Conclude: `⟨z, ...⟩` witnesses the existential

For `.all alpha`, the result formula = `Formula.neg (q_exists (Formula.neg ihExt.val))`.
