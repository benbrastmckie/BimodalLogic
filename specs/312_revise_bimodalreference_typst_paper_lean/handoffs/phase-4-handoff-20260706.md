# Phase 4 Handoff (task 312)

- 01-syntax.typ rewritten: primitives {atom, bot, imp, box, untl, snce} with Burgess event/guard convention; Atom type (not String); F/P/G/H derived (some_future, some_past, all_future, all_past) transcribed from Formula.lean; diamond (not pos); swap_temporal updated to untl/snce recursion; paper H/G-primitive note (TM vs TM+ conservative).
- 02-semantics.typ targeted edits: Reflection constraint added to Task Frame def (paper form) + Lean field mapping (nullity_identity/converse/forward_comp, TaskFrame.lean:93); untl/snce truth clauses added (strict witness, open guard); H/G strict < clauses PRESERVED, now presented as derived characterizations (future_iff/past_iff) with F/P; Atom in task model; TF described as derived.
- notation/bimodal-notation.typ: additive macros leanNullityIdentity, leanForwardComp, leanConverse, leanReflection.
- Compile: clean.
