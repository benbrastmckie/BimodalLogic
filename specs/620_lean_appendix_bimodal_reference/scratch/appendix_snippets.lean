-- Scratch verification file for task 620 (Lean appendix, typst/chapters/ax-lean-appendix.typ).
-- Not part of the library or test suite. Run from the repo root:
--   lake env lean specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean
-- Every didactic snippet quoted (paraphrased, never copy-pasted verbatim) into the appendix
-- must appear here first and compile with zero errors and no `sorry`.

import FormalSystem

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics FormalSystem.Metalogic

-- ============================================================================
-- Section: What Lean Is / lake facts
-- ============================================================================

-- lean-toolchain: leanprover/lean4:v4.33.0-rc1
-- lakefile.toml: package "BimodalLogic", lean_lib "FormalSystem", lean_lib "BimodalTest"
--   (srcDir = "Tests"), mathlib rev "v4.33.0-rc1"

-- ============================================================================
-- Section: Types vs Props / #check examples
-- ============================================================================

#check (Formula : Type)
#check (DerivationTree : FrameClass → Context → Formula → Type)
#check (Derivable : FrameClass → Context → Formula → Prop)
#check (FrameClass : Type)
#check (Formula.atomS : String → Formula)

-- ============================================================================
-- Section: Formula construction
-- ============================================================================

#check (Formula.atomS "p").box
#check (Formula.atomS "p").imp (Formula.atomS "q")
#check (Formula.atomS "p").always
#check (Formula.atomS "p").sometimes

-- ============================================================================
-- Section: Type-vs-Prop contrast pair (DerivationTree vs. Derivable)
-- ============================================================================

-- A DerivationTree is data (a Type): the proof of `⊢ □p → p` via the modal_t axiom.
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial

-- Erasing that tree via `Nonempty` gives the Prop-valued fact -- `Derivable.ofTree`,
-- or the anonymous-constructor spelling `⟨d⟩`.
example : |-! (Formula.atomS "p").box.imp (Formula.atomS "p") :=
  Derivable.ofTree (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial)

example (d : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p")) :
    |-! (Formula.atomS "p").box.imp (Formula.atomS "p") := ⟨d⟩

-- ============================================================================
-- Section: Propositions-as-types -- term-mode proof of ⊢ □p → p, and modus ponens
-- ============================================================================

def boxPImpP : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial

-- Composing a derivation with modus_ponens: given a hypothetical derivation of `⊢ □p`,
-- discharge the antecedent of `boxPImpP` to derive `⊢ p`.
example (dBoxP : ⊢ (Formula.atomS "p").box) : ⊢ (Formula.atomS "p") :=
  DerivationTree.modus_ponens [] (Formula.atomS "p").box (Formula.atomS "p") boxPImpP dBoxP

-- ============================================================================
-- Section: Tactic proof of the same result
-- ============================================================================

example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by
  modal_search

-- `apply_axiom` is a zero-argument macro (`FormalSystem/Automation/Tactics/UserTactics.lean`),
-- expanding to `apply DerivationTree.axiom; refine ?_`. It does NOT search for the matching
-- `Axiom` constructor itself (its docstring claim to the contrary does not match its current
-- implementation) -- it only applies the `axiom` constructor and leaves the `h : Axiom _` and
-- `h_fc` side goals open, same as a bare `apply DerivationTree.axiom` would. A caller supplies
-- both by hand (the `apply_axiom MT p` argument spelling in an older doc draft does not
-- elaborate at all -- `apply_axiom` takes no arguments).
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by
  apply_axiom
  case h => exact Axiom.modal_t _
  case h_fc => trivial

-- ============================================================================
-- Section: Structures and classes
-- ============================================================================

-- `Atom` is a two-field structure with derived instances.
#check (Atom.mk "p" none : Atom)
example : (Atom.mk "p" none).base = "p" := rfl

-- `Formula` derives DecidableEq (among others); `inferInstance` resolves it.
example : DecidableEq Formula := inferInstance
example : DecidableEq Formula := by infer_instance

-- `TaskModel F` is a one-field structure: a valuation function over `F`'s world states.
example {F : TaskFrame} (M : TaskModel F) (w : F.WorldState) (p : Atom) : Prop :=
  M.valuation w p

-- ============================================================================
-- Section: Reading FormalSystem/ source -- soundness / completeness signatures
-- ============================================================================

#check @soundness
#check @FormalSystem.Metalogic.BXCanonical.completeness

-- #print axioms usage (trust-reading practice)
#print axioms soundness
