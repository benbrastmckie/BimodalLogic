/-!
# BX1-Dependent Code Extracted from Realization.lean

Archived: Task 130 (2026-05-20)
Source: Metalogic/BXCanonical/Quasimodel/Realization.lean

These definitions require BX1 (G(phi) -> phi) or BX1' (H(phi) -> phi),
which were removed when the project moved to irreflexive (strict) temporal
semantics under task 113. They are preserved here for documentation only.

This file is NOT imported by any active module.
-/

/-! ## F_of_mem and P_of_mem

F_of_mem proves F(psi) in w from psi in w. The proof relies on:
  if G(neg psi) in w, then neg psi in w (BX1), contradicting psi in w.
  So G(neg psi) not in w, hence F(psi) = neg G(neg psi) in w.

Without BX1, G(neg psi) in w does NOT imply neg psi in w, so the
argument breaks at the critical step.

Original signatures:

```
theorem F_of_mem {w : BXPoint} {psi : Formula}
    (h : psi in w.formulas) : Formula.some_future psi in w.formulas

theorem P_of_mem {w : BXPoint} {psi : Formula}
    (h : psi in w.formulas) : Formula.some_past psi in w.formulas
```

P_of_mem is the dual (past direction) with the same BX1' dependency.
-/

/-! ## enriched_seed_consistent_until/since (sorry-bearing branches)

These theorems prove consistency of enriched Lindenbaum seeds:
  {neg(phi U psi)} union g_content(w) union h_content(v)
  {neg(phi S psi)} union h_content(w) union g_content(v)

The sorry occurs in the branch where alpha in g_content(w) (for Until)
or alpha in h_content(w) (for Since):
  - g_content(w) subset w.formulas requires BX1: G(chi) in w -> chi in w
  - h_content(w) subset w.formulas requires BX1': H(chi) in w -> chi in w

The rest of the proof (non-g_content/h_content branches and the case
split on neg(phi U/S psi) in L) is fully proved and remains in
Realization.lean.

Original sorry locations:
  enriched_seed_consistent_until: line 196 (g_content branch)
  enriched_seed_consistent_since: line 248 (h_content branch)
-/
