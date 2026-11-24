/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Registry
import FormalSystem.ProofSystem.Substitution

/-!
# Registered theorems: enumerated by the tableau pipeline

Generated. Do not edit by hand; regenerate with:

```bash
bash scripts/theorem-library-pipeline.sh \
  --fragment Boolean --max-complexity 5 --atoms 2 \
  --frame-class Base --frame-class Dense --frame-class ZTime --frame-class RTime
```

The bound is 5 pattern-aware operator layers in
`Formula.complexity`'s measure, not primitive nodes, over an atom pool of 2.
The fragment is `Boolean` and the frame class is `Base`, where proof
extraction produces derivations. The full command line, with every path, is in each
record's `command` field and in the dataset sidecar.
-/

-- A fully explicit concrete derivation runs to hundreds of lines, so this generated module
-- exceeds the package's 1500-line limit. The long-file baseline is the one file-level
-- linter option the package sanctions; it is pinned to this file's own length, so growth
-- past it trips the linter rather than passing silently. It sits AFTER the module
-- docstring, which the style linter requires to be the first command after the imports.
set_option linter.style.longFile 2100

open FormalSystem.Syntax
open FormalSystem.ProofSystem

namespace BimodalLib.Theorems.Enumerated
/-- The derivation the tableau extracted for `(p → (q → p))`, over its own concrete atoms.
Generated; do not edit by hand. -/
private def enumerated0Concrete : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.atom (Atom.mk "q" none))
    (Formula.atom (Atom.mk "p" none)))) :=
  (DerivationTree.axiom [] (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.atom (Atom.mk "q" none)) (Formula.atom (Atom.mk "p" none)))) (Axiom.prop_s
  (Formula.atom (Atom.mk "p" none)) (Formula.atom (Atom.mk "q" none))) (by decide))

/-- The substitution generalizing `enumerated0Concrete`'s atoms to schema variables. Generated; do
not edit by hand. -/
private def enumerated0Subst (A B : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else if q = (Atom.mk "q" none) then B else
  Formula.atom q

/-- `(A → (B → A))` — admitted by the theorem-library pipeline at `Base`. Generated; do not edit
by hand. -/
def enumerated0 (A B : Formula) : DerivationTree FrameClass.Base []
    (Formula.imp A (Formula.imp B A)) := by
  have h := DerivationTree.substNil (enumerated0Subst A B) enumerated0Concrete
  simp only [substF, enumerated0Subst, reduceIte] at h
  exact h

register_theorem BimodalLib.Theorems.Enumerated.enumerated0

/-- The derivation the tableau extracted for `(□⊥ → p)`, over its own concrete atoms. Generated;
do not edit by hand. -/
private def enumerated1Concrete : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk "p" none))) :=
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.box (Formula.bot)) (Formula.bot))
  (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk "p" none)))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.box (Formula.bot)) (Formula.imp
  (Formula.bot) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk
  "p" none)))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.box (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.box (Formula.bot))
  (Formula.atom (Atom.mk "p" none))))) (Axiom.prop_k (Formula.box (Formula.bot)) (Formula.bot)
  (Formula.atom (Atom.mk "p" none))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.bot) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none)))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none))) (Formula.imp
  (Formula.box (Formula.bot)) (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none)))))
  (Axiom.prop_s (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none))) (Formula.box
  (Formula.bot))) (by decide)) (DerivationTree.axiom [] (Formula.imp (Formula.bot) (Formula.atom
  (Atom.mk "p" none))) (Axiom.ex_falso (Formula.atom (Atom.mk "p" none))) (by decide))))
  (DerivationTree.axiom [] (Formula.imp (Formula.box (Formula.bot)) (Formula.bot)) (Axiom.modal_t
  (Formula.bot)) (by decide)))

/-- The substitution generalizing `enumerated1Concrete`'s atoms to schema variables. Generated; do
not edit by hand. -/
private def enumerated1Subst (A : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else Formula.atom q

/-- `(□⊥ → A)` — admitted by the theorem-library pipeline at `Base`. Generated; do not edit by
hand. -/
def enumerated1 (A : Formula) : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.bot)) A) := by
  have h := DerivationTree.substNil (enumerated1Subst A) enumerated1Concrete
  simp only [substF, enumerated1Subst, reduceIte] at h
  exact h

register_theorem BimodalLib.Theorems.Enumerated.enumerated1

/-- The derivation the tableau extracted for `(□p → p)`, over its own concrete atoms. Generated;
do not edit by hand. -/
private def enumerated2Concrete : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atom (Atom.mk "p" none))) (Formula.atom (Atom.mk "p"
    none))) :=
  (DerivationTree.axiom [] (Formula.imp (Formula.box (Formula.atom (Atom.mk "p" none)))
  (Formula.atom (Atom.mk "p" none))) (Axiom.modal_t (Formula.atom (Atom.mk "p" none)))
  (by decide))

/-- The substitution generalizing `enumerated2Concrete`'s atoms to schema variables. Generated; do
not edit by hand. -/
private def enumerated2Subst (A : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else Formula.atom q

/-- `(□A → A)` — admitted by the theorem-library pipeline at `Base`. Generated; do not edit by
hand. -/
def enumerated2 (A : Formula) : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box A) A) := by
  have h := DerivationTree.substNil (enumerated2Subst A) enumerated2Concrete
  simp only [substF, enumerated2Subst, reduceIte] at h
  exact h

register_theorem BimodalLib.Theorems.Enumerated.enumerated2

/-- The derivation the tableau extracted for `□(□⊥ → p)`, over its own concrete atoms. Generated;
do not edit by hand. -/
private def enumerated3Concrete : DerivationTree FrameClass.Base []
    (Formula.box (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk "p" none)))) :=
  (DerivationTree.necessitation (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk
  "p" none))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.box (Formula.bot))
  (Formula.bot)) (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk "p" none)))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.box (Formula.bot)) (Formula.imp
  (Formula.bot) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.box (Formula.bot)) (Formula.atom (Atom.mk
  "p" none)))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.box (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.box (Formula.bot))
  (Formula.atom (Atom.mk "p" none))))) (Axiom.prop_k (Formula.box (Formula.bot)) (Formula.bot)
  (Formula.atom (Atom.mk "p" none))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.bot) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none)))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none))) (Formula.imp
  (Formula.box (Formula.bot)) (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none)))))
  (Axiom.prop_s (Formula.imp (Formula.bot) (Formula.atom (Atom.mk "p" none))) (Formula.box
  (Formula.bot))) (by decide)) (DerivationTree.axiom [] (Formula.imp (Formula.bot) (Formula.atom
  (Atom.mk "p" none))) (Axiom.ex_falso (Formula.atom (Atom.mk "p" none))) (by decide))))
  (DerivationTree.axiom [] (Formula.imp (Formula.box (Formula.bot)) (Formula.bot)) (Axiom.modal_t
  (Formula.bot)) (by decide))))

/-- The substitution generalizing `enumerated3Concrete`'s atoms to schema variables. Generated; do
not edit by hand. -/
private def enumerated3Subst (A : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else Formula.atom q

/-- `□(□⊥ → A)` — admitted by the theorem-library pipeline at `Base`. Generated; do not edit by
hand. -/
def enumerated3 (A : Formula) : DerivationTree FrameClass.Base []
    (Formula.box (Formula.imp (Formula.box (Formula.bot)) A)) := by
  have h := DerivationTree.substNil (enumerated3Subst A) enumerated3Concrete
  simp only [substF, enumerated3Subst, reduceIte] at h
  exact h

register_theorem BimodalLib.Theorems.Enumerated.enumerated3

/-- The derivation the tableau extracted for `□(□p → p)`, over its own concrete atoms. Generated;
do not edit by hand. -/
private def enumerated4Concrete : DerivationTree FrameClass.Base []
    (Formula.box (Formula.imp (Formula.box (Formula.atom (Atom.mk "p" none))) (Formula.atom
    (Atom.mk "p" none)))) :=
  (DerivationTree.necessitation (Formula.imp (Formula.box (Formula.atom (Atom.mk "p" none)))
  (Formula.atom (Atom.mk "p" none))) (DerivationTree.axiom [] (Formula.imp (Formula.box
  (Formula.atom (Atom.mk "p" none))) (Formula.atom (Atom.mk "p" none))) (Axiom.modal_t
  (Formula.atom (Atom.mk "p" none))) (by decide)))

/-- The substitution generalizing `enumerated4Concrete`'s atoms to schema variables. Generated; do
not edit by hand. -/
private def enumerated4Subst (A : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else Formula.atom q

/-- `□(□A → A)` — admitted by the theorem-library pipeline at `Base`. Generated; do not edit by
hand. -/
def enumerated4 (A : Formula) : DerivationTree FrameClass.Base []
    (Formula.box (Formula.imp (Formula.box A) A)) := by
  have h := DerivationTree.substNil (enumerated4Subst A) enumerated4Concrete
  simp only [substF, enumerated4Subst, reduceIte] at h
  exact h

register_theorem BimodalLib.Theorems.Enumerated.enumerated4

/-- The derivation the tableau extracted for `(p → □(□(p → ⊥) → ⊥))`, over its own concrete atoms.
Generated; do not edit by hand. -/
private def enumerated5Concrete : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.box (Formula.imp (Formula.box
    (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) :=
  (DerivationTree.weakening [] [] (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Axiom.prop_k (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Axiom.prop_s (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.atom (Atom.mk "p" none))) (by decide))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))))) (Axiom.prop_k (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Axiom.prop_s
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot))) (by decide)) (DerivationTree.modus_ponens []
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Axiom.prop_k
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Axiom.prop_s (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))) (by decide))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)))) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Axiom.peirce (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (by decide)))) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (DerivationTree.modus_ponens []
  (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))))
  (Axiom.prop_k (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))) (DerivationTree.axiom [] (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.bot)
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))))
  (Axiom.prop_s (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Formula.imp
  (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))))) (by decide)) (DerivationTree.axiom [] (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot)
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Axiom.prop_k (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot) (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (by decide))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.bot) (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.bot)
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))))) (Axiom.prop_s (Formula.imp (Formula.bot) (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))) (by decide)))
  (DerivationTree.axiom [] (Formula.imp (Formula.bot) (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Axiom.ex_falso
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (by decide)))))) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))) (DerivationTree.modus_ponens []
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (Axiom.prop_k (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot))))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))))))) (Axiom.prop_k (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (DerivationTree.axiom [] (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))))) (Axiom.prop_s (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (by decide))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))))) (Axiom.prop_k (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (by decide)))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))))) (Axiom.prop_k
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (by decide)) (DerivationTree.modus_ponens []
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))))
  (Axiom.prop_s (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))))) (Axiom.prop_k (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))))
  (Axiom.prop_s (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))
  (by decide)) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Axiom.prop_k
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))) (by decide))))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))
  (Axiom.prop_s (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (by decide)))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))))) (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))))))) (Axiom.prop_s (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (by decide)) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))))
  (Axiom.prop_s (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (by decide))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (DerivationTree.modus_ponens []
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))))
  (Axiom.prop_k (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (by decide))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot))
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot)))))) (Axiom.prop_s (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.bot)))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (by decide))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))
  (Formula.bot)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.bot))))
  (Axiom.prop_k (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (by decide))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot)))) (Axiom.prop_s (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)) (Formula.imp (Formula.box
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (Formula.bot))) (by decide)))) (DerivationTree.axiom [] (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.bot))) (Formula.bot)) (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Axiom.modal_5_collapse (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (by decide)))))) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))))) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot)))))) (Axiom.prop_k (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (by decide))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))
  (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))) (Axiom.prop_k (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))))
  (Axiom.prop_s (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (by decide))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.imp (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Axiom.prop_k (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))) (by decide)))) (DerivationTree.modus_ponens [] (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))
  (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))))) (Formula.imp (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))) (Axiom.prop_k
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot)))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot))))))) (Axiom.prop_s (Formula.imp
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom
  (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.bot))))) (Formula.imp (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Axiom.prop_k (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (by decide)) (DerivationTree.modus_ponens [] (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot))))) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.imp
  (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none))) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))))) (Axiom.prop_s (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p"
  none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.bot)))) (Formula.atom (Atom.mk "p"
  none))) (by decide)) (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))
  (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (Formula.bot)))) (Axiom.prop_k (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none)) (Formula.bot)) (by decide))))))
  (DerivationTree.axiom [] (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))))) (Axiom.prop_s (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.atom (Atom.mk "p" none))) (by decide))))) (DerivationTree.modus_ponens
  [] (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))))
  (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none))))) (DerivationTree.axiom []
  (Formula.imp (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p"
  none)))) (Formula.imp (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))))) (Axiom.prop_s (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))) (Formula.imp (Formula.box
  (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot)))) (by decide)) (DerivationTree.axiom [] (Formula.imp
  (Formula.atom (Atom.mk "p" none)) (Formula.imp (Formula.box (Formula.imp (Formula.atom (Atom.mk
  "p" none)) (Formula.bot))) (Formula.atom (Atom.mk "p" none)))) (Axiom.prop_s (Formula.atom
  (Atom.mk "p" none)) (Formula.box (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot))))
  (by decide)))) (DerivationTree.axiom [] (Formula.imp (Formula.box (Formula.imp (Formula.atom
  (Atom.mk "p" none)) (Formula.bot))) (Formula.imp (Formula.atom (Atom.mk "p" none))
  (Formula.bot))) (Axiom.modal_t (Formula.imp (Formula.atom (Atom.mk "p" none)) (Formula.bot)))
  (by decide)))) (List.nil_subset _))

/-- The substitution generalizing `enumerated5Concrete`'s atoms to schema variables. Generated; do
not edit by hand. -/
private def enumerated5Subst (A : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else Formula.atom q

/-- `(A → □(□(A → ⊥) → ⊥))` — admitted by the theorem-library pipeline at `Base`. Generated; do
not edit by hand. -/
def enumerated5 (A : Formula) : DerivationTree FrameClass.Base []
    (Formula.imp A (Formula.box (Formula.imp (Formula.box (Formula.imp A (Formula.bot)))
    (Formula.bot)))) := by
  have h := DerivationTree.substNil (enumerated5Subst A) enumerated5Concrete
  simp only [substF, enumerated5Subst, reduceIte] at h
  exact h

register_theorem BimodalLib.Theorems.Enumerated.enumerated5

end BimodalLib.Theorems.Enumerated
