import Bimodal.Syntax
import Std.Data.HashMap
import Std.Data.HashSet

/-!
# Atom-Permutation Canonicalization

This module implements canonical form for formulas under atom permutation.
Two formulas that are identical up to atom renaming (e.g., `U(q, p) → r`
and `U(p, q) → r`) are considered equivalent for dataset purposes. By
canonicalizing to a standard atom ordering, we can deduplicate the formula
space before labeling, yielding a measured 4.58x reduction.

## Main Definitions

- `collectAtomsDFS`: Extract all distinct atoms in left-to-right DFS order
- `canonicalAtomMap`: Build a renaming from DFS-ordered atoms to canonical names
- `applyAtomMap`: Recursively apply an atom renaming to a formula
- `canonicalize`: Compose the above into a single canonicalization function
- `deduplicateCanonical`: Canonicalize and deduplicate a list of formulas

## Design

The canonical ordering assigns atoms in the order they first appear during
a left-to-right depth-first traversal:
- First atom seen → p
- Second atom seen → q
- Third atom seen → r
- (and so on for s, t, u if more atoms are present)

This ensures that structurally isomorphic formulas (differing only in
atom names) map to the same canonical representative.

## References

- Task 267 research: 4.58x deduplication ratio measured at c7 and c8
-/

set_option autoImplicit false

namespace Bimodal.Automation.AtomCanonicalization

open Bimodal.Syntax

/-- The canonical atom ordering used for renaming.
    First-seen atom maps to index 0 (p), second to index 1 (q), etc. -/
def canonicalAtomNames : Array Atom :=
  #[ Atom.mk_base "p"
   , Atom.mk_base "q"
   , Atom.mk_base "r"
   , Atom.mk_base "s"
   , Atom.mk_base "t"
   , Atom.mk_base "u" ]

/--
Collect all distinct atoms from a formula in left-to-right DFS order.

The first occurrence of each atom determines its position in the result list.
Subsequent occurrences are skipped.
-/
def collectAtomsDFS (φ : Formula) : List Atom :=
  let (_, result) := go φ ({}, [])
  result.reverse
where
  /-- Recursive helper: accumulates (seen set, result list in reverse order). -/
  go : Formula → Std.HashSet Atom × List Atom → Std.HashSet Atom × List Atom
    | .atom a, (seen, acc) =>
      if seen.contains a then (seen, acc)
      else (seen.insert a, a :: acc)
    | .bot, state => state
    | .imp l r, state => go r (go l state)
    | .box child, state => go child state
    | .untl l r, state => go r (go l state)
    | .snce l r, state => go r (go l state)

/--
Build a renaming map from the DFS-ordered atoms to canonical names.

Returns a HashMap that maps each original atom to its canonical replacement.
If there are more distinct atoms than canonical names (unlikely with 3-atom
enumeration), excess atoms map to themselves.
-/
def canonicalAtomMap (dfsAtoms : List Atom) : Std.HashMap Atom Atom :=
  let (m, _) := dfsAtoms.foldl (fun (acc : Std.HashMap Atom Atom × Nat) a =>
    let (m, i) := acc
    match canonicalAtomNames[i]? with
    | some canonical => (m.insert a canonical, i + 1)
    | none => (m, i + 1)  -- more atoms than canonical names; leave unmapped
  ) ({}, 0)
  m

/--
Recursively apply an atom renaming map to a formula.

Atoms not in the map are left unchanged.
-/
def applyAtomMap (m : Std.HashMap Atom Atom) : Formula → Formula
  | .atom a => .atom (m[a]?.getD a)
  | .bot => .bot
  | .imp l r => .imp (applyAtomMap m l) (applyAtomMap m r)
  | .box child => .box (applyAtomMap m child)
  | .untl l r => .untl (applyAtomMap m l) (applyAtomMap m r)
  | .snce l r => .snce (applyAtomMap m l) (applyAtomMap m r)

/--
Canonicalize a formula under atom permutation.

Composes: collect atoms in DFS order → build renaming map → apply renaming.
The result is the canonical representative of the formula's atom-permutation
equivalence class.

Example: `U(q, p) → r` becomes `U(p, q) → r` because q is seen first (→ p),
p is seen second (→ q), and r is seen third (→ r).
-/
def canonicalize (φ : Formula) : Formula :=
  let atoms := collectAtomsDFS φ
  let m := canonicalAtomMap atoms
  applyAtomMap m φ

/--
Check if a formula is in canonical form (i.e., canonicalize is idempotent on it).
-/
def isCanonical (φ : Formula) : Bool :=
  canonicalize φ == φ

/--
Canonicalize and deduplicate a list of formulas.

Returns only the canonical representatives, preserving the order of first
occurrence. Uses a HashSet for O(1) membership checking.
-/
def deduplicateCanonical (formulas : List Formula) : List Formula :=
  let (_, result) := formulas.foldl (fun (acc : Std.HashSet Formula × Array Formula) φ =>
    let (seen, deduped) := acc
    let canonical := canonicalize φ
    if seen.contains canonical then (seen, deduped)
    else (seen.insert canonical, deduped.push canonical)
  ) ({}, #[])
  result.toList

end Bimodal.Automation.AtomCanonicalization
