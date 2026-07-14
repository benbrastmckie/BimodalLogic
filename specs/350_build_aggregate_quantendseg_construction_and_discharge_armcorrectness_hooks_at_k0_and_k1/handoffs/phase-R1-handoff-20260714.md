# Phase R1 Handoff — EANegationFix.lean split (task 350)

## Immediate Next Action

Phase 11 (De Morgan fold): create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix/VecEANegFix.lean`
importing `...EANegationFix.NegFix` and `...Kamp.VecEAConjFull`; add its import line to the shim
`Kamp/EANegationFix.lean`. Then `VecEA2.negFix` / `VVecEA2.negFix(_iff)` per the plan.

## Current State

- Phase R1 [COMPLETED]. 11/18 phases complete.
- `EANegationFix.lean` is now a 27-line import-only re-export shim; the kit lives in
  `Kamp/EANegationFix/{OnBuilder,BoundedFix,BoundedFixAnchored,ConcatPin,NegFixOne,NegFix}.lean`.
- Full `lake build` green: 1745 jobs (1739 pre-split + 6 new modules).
- Sorry count in scope: 0. Axioms on all six representative exports: exactly
  `[propext, Classical.choice, Quot.sound]`.
- `NfMultiAnchorBridge.lean:78` (`import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix`)
  byte-identical; task-358 territory files untouched.

## Key Decisions

- Extraction order = file order = the linear DAG order, one leaf per green commit (R1.1-R1.6).
- Section cut points against the live 2,907-ln file: OnBuilder 1-253 (incl. the Lemma 5.3 module
  docstring), BoundedFix 254-1102, BoundedFixAnchored 1103-1577, ConcatPin 1578-1689,
  NegFixOne 1690-2236 (incl. `NegFixGateProbe` namespace), NegFix 2237-2906.
- Per-leaf imports follow the plan spec exactly; ConcatPin imports only BoundedFix (its section has
  no anchored references — grep-verified before the move).
- NegFix.lean carries the plan's four imports (NegFixOne, ConcatPin, BoundedFixAnchored,
  VecEAConjFull).
- Verbatim guarantee: `diff` of the reconstructed leaf concatenation vs `git show HEAD~6` original
  is empty.

## Sorry Inventory

(empty)
